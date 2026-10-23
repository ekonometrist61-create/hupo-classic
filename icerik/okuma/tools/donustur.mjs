// HupoRead: ChatGPT hikâye metinlerini Okuma Dünyası DSL'ine (.hikaye.md) çevirir.
// Metin kelimesi kelimesine korunur. Eklenenler: ad token'ları ({kahraman}, {yoldas}),
// sözlük işaretleri ({kelime}, {atasozu}), deyim kartı ([[deyim]]), vurgu (**), ikon ({isaret}),
// sayfa bölünmesi ve sorular. Anlatı içeriğine dokunulmaz.
//
// Kullanım:
//   node tools/donustur.mjs govde <kaynak.md> <HR-kodu>     → temiz gövdeyi paragraf numarasıyla yazar
//   node tools/donustur.mjs uret <anotasyon.json>            → .hikaye.md, sözlük parçası, görsel listesi, derleyici doğrulaması

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const OKUMA = path.resolve(HERE, "..");
const KAYNAK = path.join(OKUMA, "kaynak");
const HIKAYE = path.join(OKUMA, "hikaye");
const SOZLUK = path.join(OKUMA, "sozluk");
const GORSEL = path.join(OKUMA, "gorsel");
const PAKET = path.join(OKUMA, "paket");
// Derleyici: prototip atolye (yalnız okunur; derleme yazılımı başka ajanın işi).
const CLI = "C:\\Dev\\Senin Hikayen - HupoRead\\atolye\\src\\cli.ts";

const esc = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
const kelimeSay = (s) => s.split(/\s+/).filter(Boolean).length;
const norm = (s) => s.replace(/’/g, "'");

// ---------- 1. Gövde çıkarma ----------
export function govdeCikar(kaynak, id) {
  const satirlar = kaynak.split(/\r?\n/);
  const basRe = new RegExp(`^#{1,2} ${id}\\b`);
  const s = satirlar.findIndex((l) => basRe.test(l));
  if (s < 0) throw new Error(`Başlık bulunamadı: ${id}`);
  let e = satirlar.length;
  for (let i = s + 1; i < satirlar.length; i++) {
    if (/^#{1,2} HR-\d{3}\b/.test(satirlar[i])) {
      e = i;
      break;
    }
  }
  const blok = satirlar.slice(s + 1, e);
  let govde;
  const bas = blok.findIndex((l) => l.includes("<!-- STORY_START -->"));
  if (bas >= 0) {
    const son = blok.findIndex((l, i) => i > bas && l.includes("<!-- STORY_END -->"));
    govde = blok.slice(bas + 1, son < 0 ? blok.length : son);
  } else {
    const hik = blok.findIndex((l) => /^#{1,4}\s+Hikâye\s*$|^#{1,4}\s+Hikaye\s*$/.test(l));
    if (hik >= 0) govde = blok.slice(hik + 1);
    else {
      // Meta satırlarını (kalın etiketler, tablo, liste) atla; ilk düz paragrafta başla.
      const ilk = blok.findIndex((l) => /^(?!#|\||<|`|>|\*\*|- |\s*$)\S/.test(l));
      govde = ilk < 0 ? [] : blok.slice(ilk);
    }
  }
  // Başlık metninin başında arar ("Öğrenmesi" gibi anlatı başlıklarını not sanmamak için; büyük/küçük harf duyarlı).
  const notBas = govde.findIndex((l) => /^#{1,4}\s+(Hikâye sonrası|Öğrenme notları|Editör|Yayın notları|Künye|Kontrol|Denetim|Ajan)/.test(l));
  if (notBas >= 0) govde = govde.slice(0, notBas);
  return govde;
}

// Paragrafa böl: boş satır paragraf sınırıdır; başlık ve --- sayfa kırılımıdır (br).
export function paragrafla(satirlar) {
  const cikti = [];
  let tampon = [];
  const bosalt = () => {
    if (tampon.length) {
      cikti.push({ t: "p", v: tampon.join(" ").replace(/\s+/g, " ").trim() });
      tampon = [];
    }
  };
  for (const ham of satirlar) {
    const l = ham.trim();
    if (l === "") {
      bosalt();
      continue;
    }
    if (/^#{1,6}\s/.test(l) || /^-{3,}$/.test(l)) {
      bosalt();
      cikti.push({ t: "br" });
      continue;
    }
    if (/^(\||<!--|`)/.test(l)) {
      bosalt();
      continue;
    }
    // ChatGPT'nin kalın/italik süslemesi kaldırılır; vurgu yalnız annotasyonla eklenir.
    tampon.push(l.replace(/\*\*|__/g, "").replace(/(^|\s)\*([^*\s][^*]*)\*(?=\s|$|[.,;:!?])/g, "$1$2"));
  }
  bosalt();
  return cikti.filter((x, i, a) => !(x.t === "br" && (i === 0 || a[i - 1].t === "br")));
}

// ---------- 2. Ad token'ları ----------
// Türkçe hâl ekleri: ad + kesme işareti + ek. Ek yoksa yalın hâl.
const HAL_EKLERI = [
  ["ilgi", /^(nun|nın|nin|nün|un|ün|in|ın)$/],
  ["belirtme", /^(nu|nı|ni|nü|yu|yı|yi|yü|u|ı|i|ü)$/],
  ["yonelme", /^(na|ne|ya|ye|a|e)$/],
  ["bulunma", /^(nda|nde|da|de|ta|te)$/],
  ["ayrilma", /^(ndan|nden|dan|den|tan|ten)$/],
];
// Yedek ifade (ad bilinmediğinde): yol arkadaşı her hâlde doğal okunmalı.
const YEDEK_ARKADAS = {
  yalin: "bir arkadaş",
  belirtme: "bir arkadaşı",
  yonelme: "bir arkadaşa",
  bulunma: "bir arkadaşta",
  ayrilma: "bir arkadaştan",
  ilgi: "bir arkadaşın",
};

function adTokenlestir(metin, ad, yoldasMi, sayac) {
  const re = new RegExp(`(?<![\\p{L}])${esc(ad)}(?:(['’])(\\p{L}+))?(?![\\p{L}])`, "gu");
  return metin.replace(re, (m, ap, ek) => {
    let hal = "yalin";
    if (ap) {
      const bulunan = HAL_EKLERI.find(([, r]) => r.test(ek));
      if (!bulunan) throw new Error(`Ad ekini çözemedim (elle bakın): "${m}"`);
      hal = bulunan[0];
    }
    sayac.n++;
    if (yoldasMi) return `{yoldas:${hal}|${YEDEK_ARKADAS[hal]}}`;
    return hal === "yalin" ? "{kahraman}" : `{kahraman:${hal}}`;
  });
}

// ---------- 3. Sayfa bölme ----------
const wordCount = (p) => kelimeSay(p);

export function sayfalaraBol(paragraflar, hedef) {
  const sayfalar = [];
  let cur = [];
  let sayac = 0;
  const bitir = () => {
    if (cur.length) sayfalar.push(cur);
    cur = [];
    sayac = 0;
  };
  for (const b of paragraflar) {
    if (b.t === "br") {
      bitir();
      continue;
    }
    const w = wordCount(b.v);
    if (sayac > 0 && sayac + w > hedef * 1.5) bitir();
    cur.push(b.v);
    sayac += w;
    if (sayac >= hedef) bitir();
  }
  bitir();
  return sayfalar;
}

// Sayfa sayısı 3–40 aralığında kalacak en küçük hedef kelime sayısını bulur.
function sayfaPlani(paragraflar, sinif) {
  let hedef = sinif <= 4 ? 80 : sinif <= 6 ? 110 : 130;
  let sayfalar = sayfalaraBol(paragraflar, hedef);
  while (sayfalar.length > 40) {
    hedef += 10;
    sayfalar = sayfalaraBol(paragraflar, hedef);
  }
  return sayfalar;
}

// ---------- 4. Vurgu, sözlük ve ikon işaretleri ----------
function ilkGecis(sayfalar, bul, sinirli) {
  for (let i = 0; i < sayfalar.length; i++) {
    for (let j = 0; j < sayfalar[i].length; j++) {
      const p = sayfalar[i][j];
      const idx = sinirli
        ? [...p.matchAll(new RegExp(`(?<![\\p{L}])${esc(bul)}`, "gu"))].map((m) => m.index)[0]
        : p.indexOf(bul);
      if (idx !== undefined && idx >= 0) return { i, j, idx };
    }
  }
  return null;
}

function uygula(sayfalar, sp, bilgi) {
  if (sp.paragraf) {
    // İkon: paragrafın sonuna eklenir.
    for (const s of sayfalar) for (let j = 0; j < s.length; j++) {
      if (s[j].includes(sp.paragraf)) {
        s[j] = `${s[j]} {isaret:${sp.kod}}`;
        return;
      }
    }
    throw new Error(`İkon paragrafı bulunamadı: "${sp.paragraf}"`);
  }
  if (sp.deyim) {
    const yer = ilkGecis(sayfalar, sp.bul, false);
    if (!yer) throw new Error(`Deyim cümlesi bulunamadı: "${sp.bul}"`);
    const p = sayfalar[yer.i][yer.j];
    const cumleler = [...p.matchAll(/[^.!?…]*[.!?…]+["”’')\]]*/g)];
    const c = cumleler.find((m) => m.index <= yer.idx && yer.idx < m.index + m[0].length);
    if (!c) throw new Error(`Deyim için cümle sınırı bulunamadı: "${sp.bul}"`);
    const cumle = c[0].trim();
    bilgi.deyimCumleleri[sp.deyim] = cumle;
    sayfalar[yer.i][yer.j] = p.slice(0, c.index) + `[[deyim:${sp.deyim}]]` + p.slice(c.index + c[0].length);
    return;
  }
  const yer = ilkGecis(sayfalar, sp.bul, sp.sinirli !== false);
  if (!yer) throw new Error(`Vurgu/sözlük metni bulunamadı: "${sp.bul}"`);
  const p = sayfalar[yer.i][yer.j];
  sayfalar[yer.i][yer.j] = p.slice(0, yer.idx) + sp.yerine + p.slice(yer.idx + sp.bul.length);
}

// ---------- 5. Ana akış ----------
function yazFrontMatter(a, sinifAlt, sinifUst, bilgiSozluk, hedefler, sorular) {
  const j = (x) => JSON.stringify(x);
  const e = a.etiketler;
  const satir = [];
  satir.push("---");
  satir.push(`baslik: ${j(a.baslik)}`);
  satir.push(`slug: ${j(a.slug)}`);
  satir.push(`fis_kodu: ${j(a.id)}`);
  satir.push(`tur: ${a.tur}`);
  satir.push(`konu: ${a.konu}`);
  satir.push(`sinif_alt: ${sinifAlt}`);
  satir.push(`sinif_ust: ${sinifUst}`);
  satir.push(`okuma_bandi: ${a.okuma_bandi ?? (sinifAlt <= 2 ? 1 : sinifAlt <= 5 ? 2 : 3)}`);
  satir.push(`dunya_tipi: ${a.dunya_tipi ?? "gercekci"}`);
  satir.push(`izinli_turler: [${a.izinli_turler.join(", ")}]`);
  satir.push(`deger_anahtarlari: [${a.deger_anahtarlari.join(", ")}]`);
  satir.push(`yetiskin_uygun: false`);
  satir.push(`tanitim: ${j(a.tanitim)}`);
  satir.push(`durum: taslak`);
  satir.push(`uretim_kaynak: llm_taslak`);
  satir.push(`tarih: "2026-10-22"`);
  satir.push(`etiketler:`);
  satir.push(`  ana_sinif: ${sinifAlt}`);
  satir.push(`  okuma_zorlugu: ${e.okuma_zorlugu}`);
  satir.push(`  kavram_zorlugu: ${e.kavram_zorlugu}`);
  satir.push(`  ilgi_egilimi: ortak`);
  satir.push(`  temalar: [${e.temalar.join(", ")}]`);
  satir.push(`  ders_baglantisi: [${e.ders_baglantisi.join(", ")}]`);
  satir.push(`  maarif:`);
  satir.push(`    ana_deger: ${e.ana_deger}`);
  if (e.yardimci_deger) satir.push(`    yardimci_deger: ${e.yardimci_deger}`);
  satir.push(`  ogrenme_hedefleri:`);
  for (const h of hedefler) {
    const parca = [`id: ${h.id}`, `tur: ${h.tur}`, `etiket: ${j(h.etiket)}`];
    if (h.yuva) parca.push(`yuva: ${h.yuva}`);
    parca.push(`islev: ${h.islev}`);
    satir.push(`    - {${parca.join(", ")}}`);
  }
  satir.push(`  kanit_duzeyi: ${e.kanit_duzeyi ?? "C"}`);
  satir.push(`  program_surumu: ${j(e.program_surumu)}`);
  satir.push(`  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}`);
  satir.push(`sorular:`);
  for (const q of sorular) {
    const sec = q.secenekler.map((s) => `{id: ${s.id}, metin: ${j(s.metin)}}`).join(", ");
    const parca = [
      `id: ${q.id}`,
      `beceri: ${q.beceri}`,
      `dayanak_sayfa: ${q.dayanak_sayfa}`,
      ...(q.hedef_id ? [`hedef_id: ${q.hedef_id}`] : []),
      `metin: ${j(q.metin)}`,
      `secenekler: [${sec}]`,
      `dogru: ${q.dogru}`,
      `aciklama: ${j(q.aciklama)}`,
    ];
    satir.push(`  - {${parca.join(", ")}}`);
  }
  satir.push("---");
  return satir;
}

function sozlukYaz(a, sozlukDosya, iliskiDosya) {
  const s = a.sozluk ?? { yuvalar: [], kavramlar: [] };
  const girdiler = [];
  const yuvalar = [];
  const iliski = {};
  for (const y of s.yuvalar) {
    yuvalar.push({ ad: y.ad, tur: y.tur, adaylar: y.adaylar.map((g) => ({ girdi: g.id })) });
    for (const g of y.adaylar) {
      if (!g.id.startsWith(a.kisa + "_")) throw new Error(`Sözlük kimliği "${a.kisa}_" ile başlamalı: ${g.id}`);
      if (!girdiler.find((x) => x.id === g.id)) {
        girdiler.push({
          id: g.id,
          tur: g.tur,
          yazim: g.yazim,
          anlam: g.anlam,
          sinif_alt: g.sinif_alt,
          sinif_ust: g.sinif_ust,
          kaynak_turu: "editor_onerisi",
          kazanim_kodu: null,
          durum: "taslak",
        });
      }
      if (g.es || g.zit) iliski[g.id] = { es: g.es ?? [], zit: g.zit ?? [] };
    }
  }
  const dosya = { sozluk_surumu: 1, girdiler, yuvalar, kavramlar: s.kavramlar ?? [] };
  fs.writeFileSync(sozlukDosya, JSON.stringify(dosya, null, 2) + "\n", "utf8");
  fs.writeFileSync(iliskiDosya, JSON.stringify(iliski, null, 2) + "\n", "utf8");
}

export function uret(a) {
  if (!a.kisa || !/^hr\d{3}$/.test(a.kisa)) throw new Error("kisa alanı hrNNN biçiminde olmalı (ör. hr063)");
  const kaynak = fs.readFileSync(path.join(KAYNAK, a.kaynak), "utf8");
  const govde = govdeCikar(kaynak, a.id);
  const paragraflar = paragrafla(govde);
  if (!paragraflar.some((x) => x.t === "p")) throw new Error(`Gövde boş: ${a.id}`);

  const sinifAlt = a.sinif_alt ?? a.sinif;
  const sinifUst = a.sinif_ust ?? a.sinif;

  // (a) Ham metinde sayfa bölme; dayanak aramaları bu ham metinde yapılır.
  let sayfalar = sayfaPlani(paragraflar, sinifUst);
  const toplamKelime = paragraflar.filter((x) => x.t === "p").reduce((t, x) => t + wordCount(x.v), 0);

  // (b) Sorular: dayanak metni sayfa numarasına çevrilir.
  const sorular = (a.sorular ?? []).map((q) => {
    let dayanakSayfa = q.dayanak_sayfa;
    if (!dayanakSayfa) {
      const idx = sayfalar.findIndex((s) => s.some((p) => norm(p).includes(norm(q.dayanak))));
      if (idx < 0) throw new Error(`Soru ${q.id}: dayanak metin bulunamadı: "${q.dayanak}"`);
      dayanakSayfa = idx + 1;
    }
    return { ...q, dayanak_sayfa: dayanakSayfa };
  });

  // (b2) Elle düzeltme: ad + ek birleşimleri (ör. "Erkin'di") otomatik çözülemez; anotasyonda açıkça yazılır.
  for (const e of a.elle ?? []) {
    let bulunan = 0;
    sayfalar = sayfalar.map((s) =>
      s.map((p) => {
        if (!p.includes(e.bul)) return p;
        bulunan += p.split(e.bul).length - 1;
        return p.split(e.bul).join(e.yerine);
      }),
    );
    if (!bulunan) throw new Error(`Elle düzeltme metinde bulunamadı: "${e.bul}"`);
  }

  // (c) Ad token'ları: hikâye kahramanı ve yol arkadaşı.
  const sayac = { n: 0 };
  sayfalar = sayfalar.map((s) =>
    s.map((p) => {
      let t = p;
      if (a.kahraman) t = adTokenlestir(t, a.kahraman, false, sayac);
      if (a.yoldas) t = adTokenlestir(t, a.yoldas, true, sayac);
      return t;
    }),
  );

  // (d) Sözlük, vurgu, deyim ve ikon işaretleri.
  const bilgi = { deyimCumleleri: {} };
  for (const sp of a.spans ?? []) uygula(sayfalar, sp, bilgi);

  // (e) Çıktı.
  const onYuz = yazFrontMatter(a, sinifAlt, sinifUst, null, a.hedefler ?? [], sorular);
  const hikayeYol = path.join(HIKAYE, `${a.slug}.hikaye.md`);
  // Derleyici: ön yüzden sonra sayfalar gelir; her sayfa "@omurga" ile başlar, '---' ile ayrılır.
  let cikti = onYuz.join("\n") + "\n" + sayfalar.map((s) => `@omurga\n${s.join("\n\n")}`).join("\n---\n") + "\n";
  if (Object.keys(bilgi.deyimCumleleri).length) {
    // Deyim cümleleri ön yüze eklenir (derleyici `deyim_cumleleri` alanını ön yüzden okur).
    const satirlar = [];
    satirlar.push("deyim_cumleleri:");
    for (const [k, v] of Object.entries(bilgi.deyimCumleleri)) satirlar.push(`  ${k}: ${JSON.stringify(v)}`);
    cikti = cikti.replace(/\n---\n@omurga/, "\n" + satirlar.join("\n") + "\n---\n@omurga");
  }
  fs.mkdirSync(HIKAYE, { recursive: true });
  fs.writeFileSync(hikayeYol, cikti, "utf8");

  // Sözlük ve görseller.
  fs.mkdirSync(SOZLUK, { recursive: true });
  fs.mkdirSync(GORSEL, { recursive: true });
  const sozlukYol = path.join(SOZLUK, `${a.slug}.sozluk.json`);
  sozlukYaz(a, sozlukYol, path.join(SOZLUK, `${a.slug}.iliski.json`));
  const gorseller = (a.gorseller ?? []).map((g, n) => {
    let sayfa = g.sayfa;
    if (!sayfa && g.dayanak) {
      const idx = sayfalar.findIndex((s) => s.some((p) => norm(p).includes(norm(g.dayanak))));
      sayfa = idx < 0 ? 1 : idx + 1;
    }
    return { sayfa: sayfa ?? 1, dosya: `assets/okuma/sahneler/${a.slug}-${n + 1}.jpg`, prompt: g.prompt, alt: g.alt };
  });
  fs.writeFileSync(path.join(GORSEL, `${a.slug}.gorsel.json`), JSON.stringify(gorseller, null, 2) + "\n", "utf8");

  // Derleyici doğrulaması (yalnız okur; paket prototipte yazılmaz, icerik/okuma/paket'e yazılır).
  fs.mkdirSync(PAKET, { recursive: true });
  const sonuc = spawnSync(process.execPath, ["--experimental-strip-types", CLI, "derle", hikayeYol, "--sozluk", sozlukYol, "--cikti", PAKET], { encoding: "utf8" });

  console.log(`${a.id} · ${a.baslik}`);
  console.log(`  kelime (gövde, ham): ${toplamKelime} · sayfa: ${sayfalar.length} · soru: ${sorular.length} · görsel: ${gorseller.length}`);
  sayfalar.forEach((s, i) => console.log(`  s${i + 1} (${kelimeSay(s.join(" "))} kelime): ${s[0].slice(0, 70)}…`));
  console.log(`  derleyici çıktısı:\n${(sonuc.stdout || "").trim().split("\n").map((l) => "    " + l).join("\n")}`);
  if (sonuc.stderr && sonuc.stderr.trim()) console.log(`  stderr: ${sonuc.stderr.trim().slice(0, 800)}`);
  return { hikayeYol, derleme: sonuc.status };
}

// ---------- CLI ----------
const [komut, arg1, arg2] = process.argv.slice(2);
if (komut === "govde") {
  const kaynak = fs.readFileSync(path.join(KAYNAK, arg1), "utf8");
  const parca = paragrafla(govdeCikar(kaynak, arg2));
  parca.forEach((x, i) => console.log(x.t === "br" ? `[${i}] ---- sayfa kırılımı ----` : `[${i}] ${x.v}`));
} else if (komut === "uret") {
  const a = JSON.parse(fs.readFileSync(path.resolve(arg1), "utf8"));
  uret(a);
} else {
  console.error("Kullanım: govde <kaynak.md> <HR-kodu> | uret <anotasyon.json>");
  process.exit(2);
}
