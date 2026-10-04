#!/usr/bin/env node
// Hupo karakter koleksiyonu gorsel uretici.
// Fal.ai FLUX image-to-image ile referans Hupo'dan karakter varyantlari uretir.
//
// Kullanim:
//   $env:FAL_API_KEY = "fal_sk_..."
//   node tool/generate_characters.mjs --class ozgur_ruhlar
//   node tool/generate_characters.mjs --chars ozgur_ruh,oba_muhafizi
//   node tool/generate_characters.mjs --all
//   node tool/generate_characters.mjs --all --dry-run

import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { fal } from '@fal-ai/client';

const kokDizin = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const PROMPT_DOSYASI = path.join(kokDizin, 'tool', 'character_prompts.json');
const REFERANS_GORSEL = path.join(kokDizin, 'assets', 'hupo', 'ayakta.png');
const CIKTI_DIZINI = path.join(kokDizin, 'assets', 'characters');

// .env.local'den API key oku (dotenv yok, elle okuyoruz)
async function envYukle() {
  const envYolu = path.join(kokDizin, '.env.local');
  if (!existsSync(envYolu)) return;
  const icerik = await readFile(envYolu, 'utf8');
  for (const satir of icerik.split(/\r?\n/)) {
    const esit = satir.indexOf('=');
    if (esit < 0 || satir.trim().startsWith('#')) continue;
    const anahtar = satir.slice(0, esit).trim();
    const deger = satir.slice(esit + 1).trim();
    if (anahtar && !process.env[anahtar]) process.env[anahtar] = deger;
  }
}

// Fal.ai modeli: FLUX Canny ControlNet — Hupo'nun silueti/edge'ini kilitler,
// kostum/efekt prompt'tan tam serbestce gelir. Cartoon mascot icin ideal.
const FAL_MODEL = 'fal-ai/flux-control-lora-canny';

function argumanlariOku() {
  const argv = process.argv.slice(2);
  const sonuc = { sinif: null, hepsi: false, kuruCalisma: false, chars: null };

  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === '--class') {
      sonuc.sinif = argv[i + 1];
      i++;
    } else if (argv[i] === '--chars') {
      sonuc.chars = argv[i + 1].split(',').map((s) => s.trim());
      i++;
    } else if (argv[i] === '--all') {
      sonuc.hepsi = true;
    } else if (argv[i] === '--dry-run') {
      sonuc.kuruCalisma = true;
    }
  }
  return sonuc;
}

// Kompakt anchor — Hupo kimliği + kid-friendly cazibe + canli parlak gozler
const KOMPAKT_ANCHOR =
  'Adorable chibi cartoon owl hero mascot designed to appeal to kids ages 7-14 (both boys and girls will love this character). CRITICAL FIXED FEATURES: warm golden-yellow (#F5C842) body plumage; TWO POINTED EAR TUFTS on top of head MUST BE BRIGHT LEAF-GREEN (#6DA940) — never yellow, never gold, never brown, always vivid green; cream-ivory heart-shaped face mask; LARGE ROUND SPARKLING BLUE IRIS EYES (#4EA9D9) with deep navy pupils, bright white specular highlights, lively and alert expression (never droopy, never sad, never dead-looking); small amber-orange triangular beak; orange three-toed feet; bold dark outline, polished cel-shaded vector illustration.';

const KOMPAKT_STIL =
  'Premium Brawl Stars / Clash Royale splash art style, modern mobile game character card illustration, cel-shaded 2D with rich 3D shading depth, bold confident outlines, dramatic three-quarter hero lighting with warm rim light, charming cute hero energy that kids immediately connect with, 4K quality, centered full body visible with heroic confident posture, square 1:1 framing, clean radial gradient background matching costume palette.';

const KOMPAKT_NEGATIVE =
  'droopy eyes, sad eyes, half-closed eyes, dead eyes, small eyes, yellow ear tufts, gold ear tufts, brown ear tufts, missing green ear tufts, green eyes, red eyes, yellow eyes, changed eye color, realistic owl, feather realism, horror, scary, menacing, religious symbols, cross, star of david, extra limbs, two characters, text, watermark, logo, cheap plastic toy, flat shading, 3D clay render, soft focus, ugly, dull colors.';

// Karakter prompt'undan sadece COSTUME + EFFECTS kisimlarini cek, oz bilgiyi al
function karakterOzeti(karakterPrompt) {
  // "COSTUME ..." ile baslayan ve bir sonraki buyuk basliga kadar olan kismi al
  const bolumler = karakterPrompt.split(/\n\n(?=[A-Z][A-Z ]+:)/);
  const ozet = [];
  for (const b of bolumler) {
    // Sadece COSTUME, POSE & EXPRESSION ve PALETTE basliklarini al; EFFECTS'in sadece baslangicini
    if (b.startsWith('COSTUME')) ozet.push(b);
    else if (b.startsWith('POSE')) ozet.push(b.slice(0, 250)); // poz kisaltilmis
    else if (b.startsWith('EFFECTS')) ozet.push(b.slice(0, 200));
    else if (b.startsWith('PALETTE')) ozet.push(b.slice(0, 150));
  }
  return ozet.join('\n');
}

// Anchor-reminder — kritik renkleri + canli gozleri sonda bir kez daha vurgula
const ANCHOR_HATIRLATMA =
  'MUST HAVE: BRIGHT GREEN ear tufts on top of head (not yellow/brown/gold); golden-yellow body; LARGE SPARKLING BLUE eyes with lively bright expression and white highlights (never droopy, never sad); cream-ivory face mask; amber beak. The character must look cute, charming, and appeal to kids 7-14 of both genders.';

function promptBirlestir(veri, karakter) {
  const ozet = karakterOzeti(karakter.prompt);
  // SANDWICH yapi: anchor basta (kimlik oturur) + kostum ortada + anchor-hatirlatma sonda
  // Her tier icin ayni yapi — tier farki prompt icerigiyle (ozet) olusur
  if (karakter.nadirlik <= 2) {
    return `${KOMPAKT_ANCHOR}\n\n${ozet}\n\n${ANCHOR_HATIRLATMA}\n\n${KOMPAKT_STIL}`;
  }
  // Epic+: kostum once (zenginligi vurgulamak icin) + sonra anchor + reminder
  return `${ozet}\n\nFIXED CHARACTER IDENTITY: ${KOMPAKT_ANCHOR}\n\n${ANCHOR_HATIRLATMA}\n\n${KOMPAKT_STIL}`;
}

async function gorselUret(tamPrompt, referansBuffer, nadirlik) {
  // Image'i base64 data URL olarak kodla
  const base64 = referansBuffer.toString('base64');
  const imageDataUrl = `data:image/png;base64,${base64}`;

  // Tier bagimli ControlNet gucu:
  // Common (1): 0.80 (siluet siki, basit kostum icin kimlik net)
  // Rare (2): 0.82 (yesil tufler korunsun — en yuksek, kimlik oncelikli)
  // Epic+ (3-5): 0.60 (zengin kostum ozgurlugu)
  const controlStrength = nadirlik === 1 ? 0.80 : nadirlik === 2 ? 0.82 : 0.60;

  const sonuc = await fal.subscribe(FAL_MODEL, {
    input: {
      prompt: tamPrompt,
      control_lora_image_url: imageDataUrl,
      control_lora_strength: controlStrength,
      image_size: 'square_hd',
      num_inference_steps: 35,
      guidance_scale: 6, // Yuksek: prompt'a cok sadik, kritik renkler tutar
      num_images: 1,
      enable_safety_checker: true,
      output_format: 'png',
    },
    logs: false,
  });

  const url = sonuc?.data?.images?.[0]?.url;
  if (!url) throw new Error('Fal.ai yanitinda gorsel URL yok: ' + JSON.stringify(sonuc?.data).slice(0, 300));

  const yanit = await fetch(url);
  if (!yanit.ok) throw new Error(`Gorsel indirilemedi: ${yanit.status}`);
  return Buffer.from(await yanit.arrayBuffer());
}

async function main() {
  await envYukle();
  const { sinif, hepsi, kuruCalisma, chars } = argumanlariOku();

  if (!sinif && !hepsi && !chars) {
    console.error('Kullanim:');
    console.error('  node tool/generate_characters.mjs --class <slug>');
    console.error('  node tool/generate_characters.mjs --chars slug1,slug2');
    console.error('  node tool/generate_characters.mjs --all');
    console.error('  (--dry-run eklersen API cagrisi yapmaz, sadece prompt yazar)');
    process.exit(1);
  }

  const API_KEY = process.env.FAL_API_KEY;
  if (!kuruCalisma && !API_KEY) {
    console.error('HATA: FAL_API_KEY ortam degiskeni yok.');
    console.error('  .env.local dosyasina yaz: FAL_API_KEY=fal_sk_...');
    process.exit(1);
  }

  if (!kuruCalisma) {
    fal.config({ credentials: API_KEY });
  }

  if (!existsSync(PROMPT_DOSYASI)) {
    console.error(`HATA: prompt dosyasi bulunamadi: ${PROMPT_DOSYASI}`);
    process.exit(1);
  }

  const veri = JSON.parse(await readFile(PROMPT_DOSYASI, 'utf8'));

  let referansBuffer = null;
  if (!kuruCalisma) {
    if (!existsSync(REFERANS_GORSEL)) {
      console.error(`HATA: referans gorsel yok: ${REFERANS_GORSEL}`);
      process.exit(1);
    }
    referansBuffer = await readFile(REFERANS_GORSEL);
  }

  // Hangi karakterleri uretecegiz?
  const hedefler = []; // { sinifSlug, karakter }
  if (chars) {
    // Belirli karakter slug'larini bul
    const bulundu = new Set();
    for (const [sinifSlug, sinifVeri] of Object.entries(veri.siniflar)) {
      for (const k of sinifVeri.karakterler) {
        if (chars.includes(k.slug)) {
          hedefler.push({ sinifSlug, sinifVeri, karakter: k });
          bulundu.add(k.slug);
        }
      }
    }
    const eksik = chars.filter((s) => !bulundu.has(s));
    if (eksik.length > 0) {
      console.error(`HATA: su slug'lar bulunamadi: ${eksik.join(', ')}`);
      process.exit(1);
    }
  } else {
    const siniflar = hepsi ? Object.keys(veri.siniflar) : [sinif];
    for (const sinifSlug of siniflar) {
      const sinifVeri = veri.siniflar[sinifSlug];
      if (!sinifVeri) {
        console.error(`HATA: sinif bulunamadi: ${sinifSlug}`);
        console.error(`Mevcut: ${Object.keys(veri.siniflar).join(', ')}`);
        process.exit(1);
      }
      for (const k of sinifVeri.karakterler) {
        hedefler.push({ sinifSlug, sinifVeri, karakter: k });
      }
    }
  }

  let basarili = 0;
  let basarisiz = 0;

  let oncekiSinif = null;
  for (const { sinifSlug, sinifVeri, karakter } of hedefler) {
    if (oncekiSinif !== sinifSlug) {
      console.log(`\n${sinifVeri.emoji}  ${sinifVeri.ad}`);
      oncekiSinif = sinifSlug;
    }

    const hedefDizin = path.join(CIKTI_DIZINI, sinifSlug);
    await mkdir(hedefDizin, { recursive: true });

    const tamPrompt = promptBirlestir(veri, karakter);
    const yildiz = '*'.repeat(karakter.nadirlik).padEnd(5, '.');

    if (kuruCalisma) {
      const promptYolu = path.join(hedefDizin, `${karakter.slug}.prompt.txt`);
      await writeFile(promptYolu, tamPrompt, 'utf8');
      console.log(`  [${yildiz}] ${karakter.ad.padEnd(18)} -> ${path.relative(kokDizin, promptYolu)}`);
      basarili++;
      continue;
    }

    process.stdout.write(`  [${yildiz}] ${karakter.ad.padEnd(18)} uretiliyor...`);
    const basladi = Date.now();
    try {
      const gorsel = await gorselUret(tamPrompt, referansBuffer, karakter.nadirlik);
      const hedefYol = path.join(hedefDizin, `${karakter.slug}.png`);
      await writeFile(hedefYol, gorsel);
      const sure = ((Date.now() - basladi) / 1000).toFixed(1);
      console.log(` tamam (${Math.round(gorsel.length / 1024)} KB, ${sure}s)`);
      basarili++;
    } catch (hata) {
      console.log(' BASARISIZ');
      console.error(`     ${hata.message}`);
      if (hata.body) console.error(`     body: ${JSON.stringify(hata.body).slice(0, 500)}`);
      if (hata.validation_errors) console.error(`     val: ${JSON.stringify(hata.validation_errors).slice(0, 500)}`);
      basarisiz++;
    }
  }

  console.log(`\nBitti: ${basarili} basarili, ${basarisiz} basarisiz.`);
  if (basarisiz > 0) process.exit(1);
}

main().catch((hata) => {
  console.error(`Beklenmeyen hata: ${hata.message}`);
  if (hata.stack) console.error(hata.stack);
  process.exit(1);
});
