#!/usr/bin/env node
// ChatGPT tasarım klasöründeki görselleri uygulamaya hazırlar (WebP + ikon boyutları).
//
// Kullanım (mobile-app klasöründen):
//   node tool/gorsel_aktar.mjs                 -> hepsi
//   node tool/gorsel_aktar.mjs karakter ifade  -> yalnızca seçilen gruplar
//   Gruplar: karakter, ifade, uygulama, ikon, marka
//
// Kaynak klasör: HUPO_TASARIM_DIZINI ortam değişkeni ya da varsayılan masaüstü yolu.

import sharp from 'sharp';
import { readdir, mkdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const kokDizin = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const KAYNAK =
  process.env.HUPO_TASARIM_DIZINI ??
  'C:/Users/cengi/OneDrive/Desktop/Hupo Tasarım/ChatGPT Tasarımları';

const KARAKTER_DIZINI = path.join(KAYNAK, 'Hupo Karakter Koleksiyonu');
const IFADE_DIZINI = path.join(KAYNAK, 'İfade Pozları');
const UYGULAMA_DIZINI = path.join(KAYNAK, 'Hupo App İçi Pozlar');

const CIKTI_KARAKTER = path.join(kokDizin, 'assets', 'characters');
const CIKTI_IFADE = path.join(kokDizin, 'assets', 'hupo', 'ifade');
const CIKTI_UYGULAMA = path.join(kokDizin, 'assets', 'hupo', 'uygulama');

// Sıra numarası (kaynak dosya adındaki "N.M") -> DB'deki `ikon` kodu (character_system.sql ile aynı).
const SINIFLAR = [
  ['ozgur_ruhlar', ['ozgur_ruh', 'kivilcim', 'ateskanat', 'gece_kartali', 'oba_muhafizi']],
  ['firtina', ['ruzgar_ciragi', 'ruzgar_kosucusu', 'simsek', 'firtina_binicisi', 'firtina_ustasi']],
  ['kasifler', ['iz_surucu', 'yol_bulucu', 'sir_avcisi', 'buyuk_kasif', 'dunya_kasifi']],
  ['bozkir', ['bozkir_yoldasi', 'bozkir_izci', 'bozkir_kurdu', 'bozkir_kartali', 'bozkir_reisi']],
  ['zihin_ustalari', ['fikir_kivilcimi', 'bilgi_avcisi', 'bulmaca_ustasi', 'akil_ustasi', 'zihin_simsegi']],
  ['muhafizlar', ['genc_muhafiz', 'kale_bekcisi', 'gok_muhafizi', 'ates_muhafizi', 'bas_muhafiz']],
  ['ustalar', ['genc_kemankes', 'usta_kemankes', 'gok_akincisi', 'ustalar_firtina', 'buyuk_usta']],
  ['efsaneler', ['ay_kasifi', 'gunes_muhafizi', 'goklerin_akincisi', 'simsek_kagani', 'efsaneler_efsanesi']],
];

// Kaynakta yanlış numaralanan/adlanan dosyalar için elle eşleme (şu an yok).
const KAYNAK_ISTISNA = {};

// İfade pozu dosya adı -> uygulamadaki poz kodu. "Bir daha dene" bilerek yok:
// farklı çizim stilinde (arayüz kırpıntısı), Master Hupo ile tutarsız.
const IFADELER = {
  'Acele Et - Hupo.png': 'acele',
  'Adım adım gidelim - Hupo.png': 'adim_adim',
  'Ahaaa - Hupo.png': 'ahaaa',
  'Çok yaklaştın - Hupo.png': 'cok_yaklastin',
  'Çözüm - Hupo.png': 'cozum',
  'Doğru - Hupo.png': 'dogru',
  'Düşünüyor - Hupo.png': 'dusunuyor',
  'Günlük hedef tamamlandı - Hupo.png': 'gunluk_hedef',
  'Harika - Hupo.png': 'harika',
  'Hazır mısın - Hupo.png': 'hazir_misin',
  'Hoşgeldin - Hupo.png': 'hosgeldin',
  'İp ucu ister misin - Hupo.png': 'ipucu_ister',
  'İpucu Buldu - Hupo.png': 'ipucu_buldu',
  'Konu tamamlandı - Hupo.png': 'konu_tamamlandi',
  'Merak Ediyor - Hupo.png': 'merak_ediyor',
  'Seri Devam Ediyor - Hupo.png': 'seri_devam',
  'Seri Tehlikede - Hupo.png': 'seri_tehlikede',
  'Zor soruydu - Hupo.png': 'zor_soruydu',
  'Şaşırmış - Hupo.png': 'sasirmis',
  'Üzgün - Hupo.png': 'uzgun',
};

// Saydam 1.1–1.3: kaynak çizimin saydam olduğu karakterler için zemin gradyanı.
const SAYDAM_ZEMIN = {
  ozgur_ruh: ['#FFD9A8', '#8CC8F2'],
  kivilcim: ['#FFB04A', '#4A3A5E'],
  ateskanat: ['#8A2A12', '#1E0A0A'],
};

async function klasorOlustur(d) {
  await mkdir(d, { recursive: true });
}

async function webpYaz(girdi, cikti, genislik, kalite, yukseklik) {
  await klasorOlustur(path.dirname(cikti));
  const bilgi = await sharp(girdi)
    .resize(genislik, yukseklik ?? genislik, { fit: 'cover' })
    .webp({ quality: kalite, effort: 5 })
    .toFile(cikti);
  return Math.round(bilgi.size / 1024);
}

function gradyanSvg(boyut, [orta, kenar]) {
  return Buffer.from(
    `<svg width="${boyut}" height="${boyut}"><defs><radialGradient id="g" cx="50%" cy="45%" r="75%">` +
      `<stop offset="0%" stop-color="${orta}"/><stop offset="100%" stop-color="${kenar}"/></radialGradient></defs>` +
      `<rect width="100%" height="100%" fill="url(#g)"/></svg>`,
  );
}

async function karakterler() {
  const dosyalar = await readdir(KARAKTER_DIZINI);
  let toplam = 0;
  for (const [sinifSira, [sinif, kodlar]] of SINIFLAR.entries()) {
    for (const [i, kod] of kodlar.entries()) {
      const onek = `${sinifSira + 1}.${i + 1}`;
      const ad =
        KAYNAK_ISTISNA[kod] ?? dosyalar.find((f) => f.startsWith(onek + ' ') || f.startsWith(onek + '.'));
      if (!ad) {
        console.error(`  EKSIK  ${onek} -> ${kod}`);
        continue;
      }
      const girdi = path.join(KARAKTER_DIZINI, ad);
      const cikti = path.join(CIKTI_KARAKTER, sinif, `${kod}.webp`);
      let kaynakGirdi = girdi;
      if (SAYDAM_ZEMIN[kod]) {
        const ham = await sharp(girdi).resize(1024, 1024, { fit: 'cover' }).png().toBuffer();
        kaynakGirdi = await sharp(gradyanSvg(1024, SAYDAM_ZEMIN[kod]))
          .composite([{ input: ham }])
          .png()
          .toBuffer();
      }
      const kb = await webpYaz(kaynakGirdi, cikti, 1024, 80);
      toplam += kb;
      console.log(`  ${onek.padEnd(4)} ${sinif}/${kod}.webp  ${kb} KB  <- ${ad}`);
    }
  }
  console.log(`  Karakterler toplam: ${(toplam / 1024).toFixed(1)} MB`);
}

async function ifadeler() {
  let toplam = 0;
  for (const [ad, kod] of Object.entries(IFADELER)) {
    const girdi = path.join(IFADE_DIZINI, ad);
    if (!existsSync(girdi)) {
      console.error(`  EKSIK  ${ad}`);
      continue;
    }
    const kb = await webpYaz(girdi, path.join(CIKTI_IFADE, `${kod}.webp`), 512, 82);
    toplam += kb;
    console.log(`  ifade/${kod}.webp  ${kb} KB`);
  }
  console.log(`  İfadeler toplam: ${toplam} KB`);
}

async function uygulamaPozlari() {
  const dosyalar = await readdir(UYGULAMA_DIZINI);
  const bul = (parca, haric) =>
    dosyalar.find((f) => f.includes(parca) && (!haric || !f.includes(haric)));

  const hero = bul('Hero-Splash');
  const rehber = bul('soru ekranı ana pozu', 'sola bakan');
  const rehberSol = bul('sola bakan');
  const liste = [
    [hero, 'hero_splash', 1080, 1350, 80],
    [rehber, 'rehber', 600, 750, 82],
    [rehberSol, 'rehber_sol', 600, 800, 82],
  ];
  for (const [ad, kod, g, y, k] of liste) {
    if (!ad) {
      console.error(`  EKSIK  ${kod}`);
      continue;
    }
    const kb = await webpYaz(path.join(UYGULAMA_DIZINI, ad), path.join(CIKTI_UYGULAMA, `${kod}.webp`), g, k, y);
    console.log(`  uygulama/${kod}.webp  ${kb} KB`);
  }
}

// Kaynak ikonun köşeleri siyah (alfa yok); kenardan %7.5 içeri kırpıp tam kare dolduruyoruz.
async function ikonKaynakKare(boyut) {
  const girdi = path.join(UYGULAMA_DIZINI, 'App İkonu.png');
  const m = await sharp(girdi).metadata();
  const pay = Math.round(m.width * 0.075);
  return sharp(girdi)
    .extract({ left: pay, top: pay, width: m.width - 2 * pay, height: m.height - 2 * pay })
    .resize(boyut, boyut)
    .removeAlpha();
}

function yuvarlakMaske(boyut, oran) {
  const r = Math.round(boyut * oran);
  return Buffer.from(
    `<svg width="${boyut}" height="${boyut}"><rect width="${boyut}" height="${boyut}" rx="${r}" ry="${r}" fill="#fff"/></svg>`,
  );
}

async function ikonlar() {
  // Android uyarlanabilir ikon: düz mavi gradyan zemin + kenarı yumuşatılmış ön plan (dikiş görünmesin).
  const yogunluk = { mdpi: 108, hdpi: 162, xhdpi: 216, xxhdpi: 324, xxxhdpi: 432 };
  const eski = { mdpi: 48, hdpi: 72, xhdpi: 96, xxhdpi: 144, xxxhdpi: 192 };
  const res = path.join(kokDizin, 'android', 'app', 'src', 'main', 'res');

  for (const [d, boyut] of Object.entries(yogunluk)) {
    const kare = await (await ikonKaynakKare(boyut * 2)).png().toBuffer();
    // Zemin: ikonun kendi mavisi (bulanık resim sarı/yeşile kayıyordu).
    const zemin = await sharp(gradyanSvg(boyut, ['#4FC3F7', '#1E9BE6'])).png().toBuffer();
    // Ön plan güvenli alana (108dp tuvalin ortadaki ~72dp'si) sığsın diye küçültülür.
    const icBoyut = Math.round(boyut * 0.62);
    const ic = await sharp(kare).resize(icBoyut, icBoyut).png().toBuffer();
    const yumusak = await sharp(
      Buffer.from(
        `<svg width="${icBoyut}" height="${icBoyut}"><defs><radialGradient id="m"><stop offset="90%" stop-color="#fff"/>` +
          `<stop offset="100%" stop-color="#000"/></radialGradient></defs><rect width="100%" height="100%" fill="url(#m)"/></svg>`,
      ),
    )
      .greyscale()
      .png()
      .toBuffer();
    const onPlan = await sharp(ic).joinChannel(yumusak).png().toBuffer();
    const o = Math.round((boyut - icBoyut) / 2);
    const klasor = path.join(res, `mipmap-${d}`);

    await sharp({ create: { width: boyut, height: boyut, channels: 4, background: { r: 0, g: 0, b: 0, alpha: 0 } } })
      .composite([{ input: onPlan, left: o, top: o }])
      .png()
      .toFile(path.join(klasor, 'ic_launcher_foreground.png'));
    await sharp(zemin).png().toFile(path.join(klasor, 'ic_launcher_background.png'));

    // Eski (adaptive olmayan) ikon: yuvarlatılmış kare.
    const eskiBoyut = eski[d];
    const eskiKare = await (await ikonKaynakKare(eskiBoyut)).png().toBuffer();
    await sharp(eskiKare)
      .joinChannel(await sharp(yuvarlakMaske(eskiBoyut, 0.2)).greyscale().png().toBuffer())
      .png()
      .toFile(path.join(klasor, 'ic_launcher.png'));
  }
  console.log('  android mipmap ikonları yazıldı');

  // iOS: kare, alfasız, tam dolu (sistem maskeler).
  const iosDizin = path.join(kokDizin, 'ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset');
  const iosBoyutlar = [
    ['Icon-App-20x20@1x.png', 20], ['Icon-App-20x20@2x.png', 40], ['Icon-App-20x20@3x.png', 60],
    ['Icon-App-29x29@1x.png', 29], ['Icon-App-29x29@2x.png', 58], ['Icon-App-29x29@3x.png', 87],
    ['Icon-App-40x40@1x.png', 40], ['Icon-App-40x40@2x.png', 80], ['Icon-App-40x40@3x.png', 120],
    ['Icon-App-60x60@2x.png', 120], ['Icon-App-60x60@3x.png', 180],
    ['Icon-App-76x76@1x.png', 76], ['Icon-App-76x76@2x.png', 152],
    ['Icon-App-83.5x83.5@2x.png', 167], ['Icon-App-1024x1024@1x.png', 1024],
  ];
  for (const [ad, b] of iosBoyutlar) {
    await (await ikonKaynakKare(b)).flatten({ background: '#ffffff' }).png().toFile(path.join(iosDizin, ad));
  }
  console.log('  ios AppIcon yazıldı');

  // Web: favicon, 192/512 ve maskable (maskable için içerik güvenli alana küçültülür).
  const web = path.join(kokDizin, 'web');
  await (await ikonKaynakKare(32)).png().toFile(path.join(web, 'favicon.png'));
  for (const b of [192, 512]) {
    await (await ikonKaynakKare(b)).png().toFile(path.join(web, 'icons', `Icon-${b}.png`));
    const kare = await (await ikonKaynakKare(b)).png().toBuffer();
    const zemin = await sharp(kare).blur(b / 14).png().toBuffer();
    const ic = Math.round(b * 0.8);
    await sharp(zemin)
      .composite([{ input: await sharp(kare).resize(ic, ic).png().toBuffer(), gravity: 'center' }])
      .png()
      .toFile(path.join(web, 'icons', `Icon-maskable-${b}.png`));
  }
  console.log('  web ikonları yazıldı');
}

async function marka() {
  const girdi = path.join(KAYNAK, 'Hupo Marka Karakter Tasarım Panosu.png');
  const hedef = path.join(kokDizin, 'docs', 'marka', 'hupo_marka_panosu.webp');
  await klasorOlustur(path.dirname(hedef));
  const bilgi = await sharp(girdi).webp({ quality: 85 }).toFile(hedef);
  console.log(`  docs/marka/hupo_marka_panosu.webp  ${Math.round(bilgi.size / 1024)} KB`);
}

const GRUPLAR = { karakter: karakterler, ifade: ifadeler, uygulama: uygulamaPozlari, ikon: ikonlar, marka };
const secilen = process.argv.slice(2);
const calisacak = secilen.length ? secilen : Object.keys(GRUPLAR);

if (!existsSync(KAYNAK)) {
  console.error(`HATA: kaynak klasör yok: ${KAYNAK}`);
  process.exit(1);
}
for (const g of calisacak) {
  if (!GRUPLAR[g]) {
    console.error(`Bilinmeyen grup: ${g} (geçerli: ${Object.keys(GRUPLAR).join(', ')})`);
    process.exit(1);
  }
  console.log(`\n[${g}]`);
  await GRUPLAR[g]();
}
