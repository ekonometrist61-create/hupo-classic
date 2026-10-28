// Her ilişkiden bir TASLAK soru üretir (yayınlamaz). Çıktı migration SQL'idir.
// Çalıştırma: node docs/kelime-evreni/veritabani/uret-soru-migration.mjs
// Çıktı: supabase/migrations/20261055000000_kelime_taslak_sorular.sql
//
// Kurallar:
//   * Eş anlamlı / zıt anlamlı: "X sözcüğünün ... hangisidir?" — doğru şık ilişkinin karşı sözcüğü.
//   * Eş sesli: "X sözcüğünün anlamlarından biri hangisidir?" — şıklar anlam metinleri.
//   * Çeldiriciler, sorunun sözcüğüyle ilişkisi olmayan sözcüklerden seçilir (dolaylı ilişki dahil).
//   * Yalnızca durum = 'taslak'. Yayın ayrı bir karardır.
//   * İpucu boş: hatırlatıcı cevabı açabilir.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const klasor = dirname(fileURLToPath(import.meta.url));
const kokDizin = join(klasor, "..", "..", "..");
const CIKTI = process.env.CIKTI_YOLU ?? join(kokDizin, "supabase", "migrations", "20261055000000_kelime_taslak_sorular.sql");

const s = (metin) => `'${String(metin).replaceAll("'", "''")}'`;
const kucuk = (metin) => metin.toLocaleLowerCase("tr-TR");

// Veri
const iliskiler = [];
const anlamListesi = new Map(); // "kelime|anlam" -> {kelime, anlam, sozcuk_turu}
for (let sinif = 1; sinif <= 8; sinif++) {
  const veri = JSON.parse(readFileSync(join(klasor, `sinif-${sinif}.json`), "utf8"));
  for (const r of veri.iliskiler) {
    iliskiler.push({ id: r.id, sinif, tur: r.tur, a: r.a, b: r.b, ornek: r.ornek, kazanim: r.kazanim ?? null });
    for (const t of [r.a, r.b]) {
      const k = `${t.kelime}|${t.anlam}`;
      if (!anlamListesi.has(k)) anlamListesi.set(k, t);
    }
  }
}

// Sözcük ilişki komşulukları (her türlü ilişki)
const komsu = new Map();
const komsuEkle = (x, y) => {
  if (!komsu.has(kucuk(x))) komsu.set(kucuk(x), new Set());
  komsu.get(kucuk(x)).add(kucuk(y));
};
for (const r of iliskiler) {
  komsuEkle(r.a.kelime, r.b.kelime);
  komsuEkle(r.b.kelime, r.a.kelime);
}
const komsuMu = (x, y) => kucuk(x) === kucuk(y) || komsu.get(kucuk(x))?.has(kucuk(y));

// Sözcük havuzu (tür bilgisiyle)
const sozcukHavuzu = [...new Map([...anlamListesi.values()].map((t) => [kucuk(t.kelime), t])).values()];
const anlamHavuzu = [...anlamListesi.values()];

// Deterministik seçim
const hash = (metin) => {
  let h = 2166136261;
  for (const c of metin) h = Math.imul(h ^ c.codePointAt(0), 16777619) >>> 0;
  return h;
};
const dondur = (liste, tohum) => {
  if (liste.length === 0) return liste;
  const basla = hash(tohum) % liste.length;
  return [...liste.slice(basla), ...liste.slice(0, basla)];
};

const zorlukDuzeyi = (sinif) => (sinif <= 4 ? 1 : sinif <= 6 ? 2 : 3);

// Sözcüğün göründüğü sınıflar (çeldirici yaş uygunluğu için)
const sozcukSiniflari = new Map();
for (const r of iliskiler) {
  for (const k of [r.a.kelime, r.b.kelime]) {
    const anahtar = kucuk(k);
    if (!sozcukSiniflari.has(anahtar)) sozcukSiniflari.set(anahtar, new Set());
    sozcukSiniflari.get(anahtar).add(r.sinif);
  }
}
// Önce aynı sınıf, sonra en yakın sınıflar; her grup içinde tohuma göre döndürülür
const sinifaGoreSirala = (liste, sinif, tohum, sozcukFn) => {
  const mesafe = (x) => {
    const sinifler = sozcukSiniflari.get(kucuk(sozcukFn(x))) ?? new Set([sinif]);
    return Math.min(...[...sinifler].map((s) => Math.abs(s - sinif)));
  };
  const gruplar = new Map();
  for (const x of liste) {
    const d = mesafe(x);
    if (!gruplar.has(d)) gruplar.set(d, []);
    gruplar.get(d).push(x);
  }
  return [...gruplar.keys()]
    .sort((a, b) => a - b)
    .flatMap((d) => dondur(gruplar.get(d), `${tohum}|${d}`));
};

const sorular = [];
const metinler = new Set();

for (const r of iliskiler) {
  let stem, dogruMetin, dogruKelime, dogruAnlam, anlamKelime, anlamMetin, aciklama, anlamKayit, secenekler;

  if (r.tur === "es_sesli") {
    // Şıklar anlam metinleri; doğru = a anlamı; çeldirici = başka sözcüklerin anlamları
    const aday = sinifaGoreSirala(
      anlamHavuzu.filter((t) => kucuk(t.kelime) !== kucuk(r.a.kelime) && t.anlam !== r.a.anlam),
      r.sinif,
      r.id,
      (t) => t.kelime,
    );
    const celdiriciler = aday.slice(0, 2).map((t) => t.anlam);
    if (celdiriciler.length < 2) throw new Error(`${r.id}: çeldirici anlam yetersiz`);
    stem = `“${r.a.kelime}” sözcüğünün anlamlarından biri hangisidir?`;
    dogruMetin = r.a.anlam;
    secenekler = [dogruMetin, ...celdiriciler];
    dogruKelime = r.a.kelime;
    dogruAnlam = r.a.anlam;
    anlamKelime = r.a.kelime;
    anlamMetin = r.a.anlam;
    aciklama = `“${r.a.kelime}” sözcüğünün iki anlamı vardır: “${r.a.anlam}” ve “${r.b.anlam}”.`;
  } else {
    const hedefTur = r.tur === "es_anlamli" ? "eş anlamlısı" : "zıt anlamlısı";
    const hariç = new Set([kucuk(r.a.kelime), kucuk(r.b.kelime), ...(komsu.get(kucuk(r.a.kelime)) ?? [])]);
    const tur = r.b.sozcuk_turu;
    const uygun = sozcukHavuzu.filter((t) => !hariç.has(kucuk(t.kelime)) && t.sozcuk_turu === tur);
    const yedek = sozcukHavuzu.filter((t) => !hariç.has(kucuk(t.kelime)));
    const siraliAday = sinifaGoreSirala([...uygun, ...yedek], r.sinif, r.id, (t) => t.kelime)
      .filter((t, i, dizi) => dizi.findIndex((x) => kucuk(x.kelime) === kucuk(t.kelime)) === i);
    // İkinci çeldirici, birincinin eş/zıt anlamlısı olmamalı
    const secilen = [];
    for (const t of siraliAday) {
      if (secilen.length === 2) break;
      if (secilen.some((c) => komsuMu(c, t.kelime))) continue;
      secilen.push(t.kelime);
    }
    if (secilen.length < 2) throw new Error(`${r.id}: çeldirici sözcük yetersiz`);
    stem = `“${r.a.kelime}” sözcüğünün ${hedefTur} hangisidir?`;
    dogruMetin = r.b.kelime;
    secenekler = [dogruMetin, ...secilen];
    dogruKelime = r.b.kelime;
    dogruAnlam = r.b.anlam;
    anlamKelime = r.a.kelime;
    anlamMetin = r.a.anlam;
    const iliskiAdi = r.tur === "es_anlamli" ? "eş anlamlıdır" : "zıt anlamlıdır";
    aciklama = `“${r.a.kelime}” ile “${r.b.kelime}” ${iliskiAdi}: “${r.a.anlam}” / “${r.b.anlam}”.`;
  }

  // Şık karıştırma: doğru şıkkın konumu tohuma göre
  const konum = hash(r.id) % secenekler.length;
  const sirali = [...secenekler];
  const dogruIlk = sirali[0];
  const diger = sirali.slice(1);
  const sonuc = [];
  let di = 0;
  for (let i = 0; i < sirali.length; i++) {
    if (i === konum) sonuc.push(dogruIlk);
    else sonuc.push(diger[di++]);
  }
  const dogruIndeks = sonuc.indexOf(dogruIlk);

  if (metinler.has(stem)) throw new Error(`${r.id}: yinelenen soru metni: ${stem}`);
  metinler.add(stem);
  if (aciklama.length > 500 || stem.length > 400) throw new Error(`${r.id}: uzunluk sınırı`);
  if (new Set(sonuc.map(kucuk)).size !== sonuc.length) throw new Error(`${r.id}: yinelenen şık`);

  // Çeldirici kontrolü (sözcük türleri)
  if (r.tur !== "es_sesli") {
    for (const c of sonuc.filter((x) => x !== dogruMetin)) {
      if (komsuMu(r.a.kelime, c) && kucuk(c) !== kucuk(dogruMetin)) {
        throw new Error(`${r.id}: çeldirici “${c}” sorunun sözcüğüyle ilişkili`);
      }
    }
  }

  sorular.push({
    id: r.id,
    anlamKelime,
    anlamMetin,
    tur: r.tur,
    sinif: r.sinif,
    kazanim: r.kazanim,
    zorluk: zorlukDuzeyi(r.sinif),
    stem,
    secenekler: sonuc,
    dogruIndeks,
    dogruKelime: r.tur === "es_sesli" ? anlamKelime : dogruKelime,
    dogruAnlam,
    aciklama,
  });
}

const satirlar = sorular.map(
  (q) =>
    `  (${s(q.anlamKelime)}, ${s(q.anlamMetin)}, ${s(q.tur)}, ${q.sinif}, ${q.kazanim ? s(q.kazanim) : "null"}, ${q.zorluk}, ${s(q.stem)}, ${s(JSON.stringify(q.secenekler))}, ${q.dogruIndeks}, ${s(q.dogruKelime)}, ${s(q.dogruAnlam)}, ${s(q.aciklama)})`,
);

const sql = `-- =====================================================================
-- KELİME EVRENİ — MEB'e göre TASLAK sorular (${sorular.length} adet, her ilişkiden bir soru)
--
-- Kaynak: docs/kelime-evreni/veritabani (sinif-*.json). Üretici: uret-soru-migration.mjs.
-- durum = 'taslak': öğrenciye çıkmaz. Yayın, dört göz kuralına uygun ayrı bir karardır.
-- Sorular ipucu içermez (hatırlatıcı cevabı açabileceği için).
-- Yinelenmeyi önlemek için aynı soru metni varsa atlanır.
-- =====================================================================

set client_encoding = 'UTF8';

insert into public.kelime_sorulari
  (anlam_id, iliski_turu, sinif, kazanim_kodu, zorluk, soru_metni, secenekler, dogru_indeks, dogru_anlam_id, aciklama, durum)
select ka.id, v.tur, v.sinif, v.kz, v.zorluk, v.soru, v.sec::jsonb, v.dogru, da.id, v.aciklama, 'taslak'
from (values
${satirlar.join(",\n")}
) as v(ka_kelime, ka_anlam, tur, sinif, kz, zorluk, soru, sec, dogru, da_kelime, da_anlam, aciklama)
join public.kelime_anlamlari ka on ka.kelime = v.ka_kelime and ka.anlam = v.ka_anlam
join public.kelime_anlamlari da on da.kelime = v.da_kelime and da.anlam = v.da_anlam
where not exists (select 1 from public.kelime_sorulari q where q.soru_metni = v.soru);
`;

writeFileSync(CIKTI, sql, "utf8");
// Teyit (Gemini) ve izleme için aynı soruların JSON dökümü
writeFileSync(
  join(klasor, "sorular-taslak.json"),
  JSON.stringify(
    sorular.map((q) => ({
      iliski_id: q.id,
      sinif: q.sinif,
      tur: q.tur,
      kazanim: q.kazanim,
      soru: q.stem,
      secenekler: q.secenekler,
      dogru_indeks: q.dogruIndeks,
      aciklama: q.aciklama,
    })),
    null,
    2,
  ),
  "utf8",
);
console.log(`Yazıldı: ${CIKTI}`);
console.log(`Soru: ${sorular.length}`);
for (const tur of ["es_anlamli", "zit_anlamli", "es_sesli"]) {
  console.log(`  ${tur}: ${sorular.filter((q) => q.tur === tur).length}`);
}
