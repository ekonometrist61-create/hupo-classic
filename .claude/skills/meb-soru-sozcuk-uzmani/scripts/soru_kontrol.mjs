// Soru kümesi için nesnel kontroller (kazanım kapsamı, dayanak birebirliği,
// kanıt düzeyi kuralı, şık uzunluğu, benzerlik). Yazar değil, denetim aracıdır.
//
// Kullanım:
//   node soru_kontrol.mjs --sorular <json> --pasaj <json> --kazanim <json> --meb <txt> [--mevcut <json,json,...>] [--etiket <ad>]
//
// --sorular   Dizi (her öğe: id, pasaj_id, kazanim_kodu, kazanim_metni, dayanak, soru_metni, siklar, dogru_sik, kanit_duzeyi)
// --pasaj     { "pasajlar": [ { "id", "metin" } ] }
// --kazanim   { "kazanimlar": [ { "kod", "metin" } ] }
// --meb       Resmî program metni (düz metin); kazanım metni burada aranır
// --mevcut    Benzerlik için mevcut soru dosyaları (virgülle ayrılmış); içinden sınıf eşleşen kayıtlar alınır

import fs from 'node:fs';

const args = Object.fromEntries(process.argv.slice(2).reduce((acc, v, i, arr) => {
  if (v.startsWith('--')) acc.push([v.slice(2), arr[i + 1]]);
  return acc;
}, []));

const norm = (s) => String(s ?? '').toLocaleLowerCase('tr-TR').replace(/[’‘`]/g, "'").replace(/\s+/g, ' ').trim();
const loose = (s) => norm(s).replace(/[^\p{L}\p{N} ]/gu, ' ').replace(/\s+/g, ' ').trim();

const items = JSON.parse(fs.readFileSync(args.sorular, 'utf8'));
const { pasajlar: pasajDizi } = JSON.parse(fs.readFileSync(args.pasaj, 'utf8'));
const pasaj = Object.fromEntries(pasajDizi.map((p) => [p.id, p.metin]));
const { kazanimlar } = JSON.parse(fs.readFileSync(args.kazanim, 'utf8'));
// Bazı kazanım dosyaları ana cümlenin ardına " | a) ..." süreç bileşenlerini ekler; yalnız ana cümle karşılaştırılır.
const kazanimMap = Object.fromEntries(kazanimlar.map((k) => [k.kod, String(k.metin).split(' | ')[0].trim()]));
const meb = loose(fs.readFileSync(args.meb, 'utf8'));

// Kanıt kuralı (SKILL.md "Kanıt düzeyi ve kapı eşlemesi" tablosu):
// B-only kazanımlar: yazma (T.Y.*), tahmin, yorum, anahtar kelime, şiir biçimi, söz varlığı geliştirme.
// A için ek koşul: dayanak pasajda birebir geçmeli ve kazanım metni resmî metinde bulunmalı.
const B_ONLY = /^T\.Y\./;
const B_METIN = /tahminde bulunabilme|Metni yorumlayabilme|anahtar kelimelerini|biçim özelliklerini|söz varlığını geliştirmeye|Yazısında|Yazısını|Yazım ve noktalama|Uygun bağlantı|açık ve örtük|kullanarak metni yapılandırabilme/;

const kuralSeviye = (it) => {
  const pm = pasaj[it.pasaj_id] ?? '';
  const dayanakPasajda = pm && loose(pm).includes(loose(it.dayanak ?? ''));
  const resmi = meb.includes(loose(kazanimMap[it.kazanim_kodu] ?? '\u0000'));
  if (B_ONLY.test(it.kazanim_kodu ?? '') || B_METIN.test(it.kazanim_metni ?? '')) return 'B';
  // SKILL.md kanıt tablosu: A adayı yalnız okuma çözümlemesi kazanımları (T.O.*). Diğer dersler B (2026-10-27, GÖR-070).
  if (!/^T\.O\./.test(it.kazanim_kodu ?? '')) return 'B';
  if (dayanakPasajda && resmi) return 'A';
  return 'B';
};

const stats = {
  n: items.length, kapsam_disi: 0, kazanim_metni_farkli: 0, kazanim_metni_resmi_yok: 0,
  dayanak_birebir: 0, siklar_eksik: 0, hepsi_hicbiri: 0, dogru_sik_en_uzun: 0,
  olumsuz_kok: 0, metne_referans: 0, kanit_asiri_iddia: 0, kanit_kural_ile_A: 0,
  cevap: { A: 0, B: 0, C: 0, D: 0 }, kapsam: new Set(), pasaj: {}, sorunlar: [],
};

for (const it of items) {
  const id = it.id ?? '?';
  if (!(it.kazanim_kodu in kazanimMap)) { stats.kapsam_disi++; stats.sorunlar.push(`${id}: kod kapsamda yok`); }
  else {
    stats.kapsam.add(it.kazanim_kodu);
    if (norm(it.kazanim_metni) !== norm(kazanimMap[it.kazanim_kodu])) { stats.kazanim_metni_farkli++; stats.sorunlar.push(`${id}: kazanım metni kaynakla farklı`); }
    if (!meb.includes(loose(kazanimMap[it.kazanim_kodu]))) { stats.kazanim_metni_resmi_yok++; stats.sorunlar.push(`${id}: kazanım metni resmî metinde yok`); }
  }

  const pm = pasaj[it.pasaj_id] ?? '';
  if (pm && loose(pm).includes(loose(it.dayanak ?? ''))) stats.dayanak_birebir++;
  else stats.sorunlar.push(`${id}: dayanak pasajda birebir yok`);

  const s = it.siklar ?? {};
  if (!['A', 'B', 'C', 'D'].every((k) => typeof s[k] === 'string')) { stats.siklar_eksik++; continue; }
  if (/\b(hepsi|hiçbiri|a ve b|b ve c|c ve d|yukarıdakilerin)\b/i.test(Object.values(s).join(' '))) stats.hepsi_hicbiri++;
  const sirali = ['A', 'B', 'C', 'D'].map((k) => [k, s[k].length]).sort((a, b) => b[1] - a[1]);
  if (sirali[0][0] === it.dogru_sik) stats.dogru_sik_en_uzun++;
  if (/değildir|yer almaz|olamaz|dışında/.test(norm(it.soru_metni))) stats.olumsuz_kok++;
  if (/metin|metne|şiir|öykü|pasaj|anlatı/.test(norm(it.soru_metni))) stats.metne_referans++;
  if (it.dogru_sik in stats.cevap) stats.cevap[it.dogru_sik]++;
  stats.pasaj[it.pasaj_id] = (stats.pasaj[it.pasaj_id] ?? 0) + 1;

  const seviye = kuralSeviye(it);
  if (seviye === 'A') stats.kanit_kural_ile_A++;
  if (it.kanit_duzeyi === 'A' && seviye !== 'A') { stats.kanit_asiri_iddia++; stats.sorunlar.push(`${id}: A iddiası kural ile uyuşmuyor (kural: B)`); }
}

// Benzerlik: 6-gram Jaccard, mevcut kayıtlarla (aynı sınıf)
const grams = (t) => { const w = loose(t).split(' '); const g = new Set(); for (let i = 0; i + 6 <= w.length; i++) g.add(w.slice(i, i + 6).join(' ')); return g; };
const mevcutMetin = [];
const walk = (node, sinif) => {
  if (Array.isArray(node)) node.forEach((x) => walk(x, sinif));
  else if (node && typeof node === 'object') {
    if (('soru_metni' in node || 'stem' in node) && String(node.sinif) === String(sinif)) {
      mevcutMetin.push([node.soru_metni ?? node.stem, ...Object.values(node.siklar ?? node.options ?? {})].join(' '));
    }
    Object.values(node).forEach((x) => walk(x, sinif));
  }
};
const sinifTahmin = items.length ? (items[0].sinif ?? null) : null;
for (const f of (args.mevcut ?? '').split(',').filter(Boolean)) {
  try { walk(JSON.parse(fs.readFileSync(f, 'utf8')), sinifTahmin); } catch { stats.sorunlar.push(`benzerlik kaynağı okunamadı: ${f}`); }
}
const mevcutG = mevcutMetin.map(grams);
let maxJ = 0;
for (const it of items) {
  const g = grams([it.soru_metni, ...Object.values(it.siklar ?? {})].join(' '));
  for (const eg of mevcutG) {
    let inter = 0; for (const x of g) if (eg.has(x)) inter++;
    const j = inter / (g.size + eg.size - inter || 1);
    if (j > maxJ) maxJ = j;
  }
}

console.log(JSON.stringify({
  etiket: args.etiket ?? '',
  soru_sayisi: stats.n,
  kapsanan_kod: `${stats.kapsam.size}`,
  kapsam_disi_kod: stats.kapsam_disi,
  kazanim_metni_farkli: stats.kazanim_metni_farkli,
  kazanim_metni_resmi_metinde_yok: stats.kazanim_metni_resmi_yok,
  dayanak_birebir: `${stats.dayanak_birebir}/${stats.n}`,
  kanit_kural_ile_A: `${stats.kanit_kural_ile_A}/${stats.n}`,
  kanit_asiri_iddia: stats.kanit_asiri_iddia,
  dogru_sik_en_uzun: `${stats.dogru_sik_en_uzun}/${stats.n}`,
  hepsi_hicbiri: stats.hepsi_hicbiri,
  olumsuz_kok: stats.olumsuz_kok,
  metne_referans: `${stats.metne_referans}/${stats.n}`,
  cevap_dagilimi: stats.cevap,
  pasaj_dagilimi: stats.pasaj,
  benzerlik_max_jaccard_6gram: Number(maxJ.toFixed(3)),
  sorunlar: stats.sorunlar.slice(0, 60),
}, null, 2));
