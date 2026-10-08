// soru-bankasi/sinif-N/*.md dosyalarından TEK bir migration üretir.
// Çalıştır: node tools/soru_bankasi_sql_tum_siniflar.mjs
//
// Fark (mevcut 5. sınıf script'inden):
//   - soru-bankasi/sinif-1 ... sinif-8 klasörlerini tarar
//   - sınıf numarasını klasör adından okur
//   - okul alanını sınıfa göre belirler (1-4 ilkokul, 5-8 ortaokul)
//   - mevcut 5. sınıf sorularına DOKUNMAZ (idempotent: aynı ders+soru_metni varsa atlar)
//
// Doğrulama: her maddede 4 şık, A-D arası cevap, çözüm metniyle alan tutarlılığı.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const kok = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const dizin = path.join(kok, "soru-bankasi");
const cikti = path.join(
  kok,
  "supabase",
  "migrations",
  "20261012000000_soru_bankasi_tum_siniflar.sql",
);

/** Sınıf numarasına göre okul seviyesi. */
function okul(sinif) {
  if (sinif >= 1 && sinif <= 4) return "ilkokul";
  if (sinif >= 5 && sinif <= 8) return "ortaokul";
  throw new Error(`Desteklenmeyen sınıf: ${sinif}`);
}

/** 1-3. sınıfta Hayat Bilgisi vardır; bu bir pedagojik eşlemedir. */
const sorular = [];
const hatalar = [];
const sayim = {}; // `${sinif}/${ders}` -> adet

for (let sinif = 1; sinif <= 8; sinif++) {
  const klasor = path.join(dizin, `sinif-${sinif}`);
  if (!fs.existsSync(klasor)) {
    // 5. sınıf zaten canlıda (20261003000001 + 20261006030000); klasörü olması gerekmez.
    console.log(`  atlandı: sinif-${sinif} (klasör yok)`);
    continue;
  }
  const dosyalar = fs
    .readdirSync(klasor)
    .filter((f) => f.endsWith(".md"))
    .sort();

  for (const ad of dosyalar) {
    const metin = fs
      .readFileSync(path.join(klasor, ad), "utf8")
      .replace(/\r\n/g, "\n");
    const bloklar = metin.split(/^### Soru /m).slice(1);

    for (const blok of bloklar) {
      const kod = blok.split("\n", 1)[0].trim();
      const alan = (anahtar) => {
        const m = blok.match(new RegExp(`^- \\*\\*${anahtar}:\\*\\*[ \\t]*(.*)$`, "m"));
        return m ? m[1].trim() : "";
      };
      const q = {
        kod,
        sinif,
        okul: okul(sinif),
        ders: alan("Ders"),
        konu: alan("Konu"),
        altKonu: alan("Alt Konu"),
        zorluk: Number(alan("Zorluk")),
        soru: alan("Soru"),
        siklar: { A: alan("A"), B: alan("B"), C: alan("C"), D: alan("D") },
        dogru: alan("Doğru Cevap").toUpperCase(),
        ipucu: alan("İpucu"),
        adimlar: [],
      };
      const izah = blok.split(/^- \*\*Öğretici İzah:\*\*\s*$/m)[1] || "";
      for (const satir of izah.split("\n")) {
        const m = satir.match(/^\s+(\d+)\.\s*Adım:\s*(.+)$/);
        if (m) q.adimlar.push(`Adım ${m[1]}: ${m[2].trim()}`);
      }

      if (!q.ders || !q.konu || !q.soru) hatalar.push(`${kod}: ders/konu/soru eksik`);
      if (![1, 2, 3].includes(q.zorluk)) hatalar.push(`${kod}: zorluk ${q.zorluk}`);
      if (Object.values(q.siklar).some((s) => !s)) hatalar.push(`${kod}: şık eksik`);
      if (!"ABCD".includes(q.dogru) || q.dogru.length !== 1)
        hatalar.push(`${kod}: cevap ${q.dogru}`);
      if (new Set(Object.values(q.siklar)).size !== 4)
        hatalar.push(`${kod}: tekrar eden şık`);
      if (q.adimlar.length === 0) hatalar.push(`${kod}: çözüm adımı yok`);
      const son = q.adimlar.join(" ");
      const beyan = son.match(/Doğru cevap ([A-D]) seçeneğidir/);
      if (beyan && beyan[1] !== q.dogru)
        hatalar.push(`${kod}: alan=${q.dogru} ama çözüm metni=${beyan[1]}`);
      if (!beyan) hatalar.push(`${kod}: çözüm metninde cevap beyanı yok (uyarı)`);
      for (const t of [q.soru, ...Object.values(q.siklar), q.ipucu, ...q.adimlar, q.konu, q.altKonu]) {
        if (t.includes("$$")) hatalar.push(`${kod}: '$$' içeriyor`);
      }
      const anahtar = `${sinif}/${q.ders}`;
      sayim[anahtar] = (sayim[anahtar] || 0) + 1;
      sorular.push(q);
    }
  }
}

const dq = (s) => `$$${s}$$`;
const satir = (q) => `(
  '${q.okul}', ${q.sinif}, ${dq(q.ders)}, ${dq(q.konu)}, ${q.altKonu ? dq(q.altKonu) : "null"}, ${q.zorluk},
  ${dq(q.soru)},
  jsonb_build_object('A', ${dq(q.siklar.A)}, 'B', ${dq(q.siklar.B)}, 'C', ${dq(q.siklar.C)}, 'D', ${dq(q.siklar.D)}),
  '${q.dogru}',
  to_jsonb(ARRAY[
    ${[`İpucu: ${q.ipucu}`, ...q.adimlar].map(dq).join(",\n    ")}
  ]::text[])
)`;

const sinifOzet = {};
for (const q of sorular) sinifOzet[q.sinif] = (sinifOzet[q.sinif] || 0) + 1;

const sql = `-- =====================================================================
--  SORU BANKASI: 1-8. sınıflar (${sorular.length} soru) — onay_durumu = 'onaylandi'
--  Üretici : node tools/soru_bankasi_sql_tum_siniflar.mjs
--  Kaynak  : soru-bankasi/sinif-{1..8}/*.md
--  Dağılım : ${Object.entries(sinifOzet).map(([s, n]) => `${s}. sınıf ${n}`).join(", ")}
--
--  KARAR (2026-10-07, ürün sahibi): bu örnek sorular TEST AMAÇLI üretilmiştir.
--  MEB kazanımlarına uygun, tek cevaplı ve seviyeye göre hazırlanmıştır; ancak
--  çıkmış sınav sorusu DEĞİLDİR. Test/demo amacıyla 'onaylandi' olarak yayına alınır.
--
--  NOT: 5. sınıf soruları (20261003000001 + 20261006030000) korunur; bu dosya
--  onlara dokunmaz. Idempotent: aynı (ders, sinif, soru_metni) varsa eklenmez.
-- =====================================================================

set client_encoding = 'UTF8';

create temporary table _soru_bankasi_tum_siniflar (
  okul text, sinif smallint, ders text, konu text, alt_konu text, zorluk smallint,
  soru_metni text, siklar jsonb, dogru_sik text, cozum_adimlari jsonb
) on commit drop;

insert into _soru_bankasi_tum_siniflar
values
${sorular.map(satir).join(",\n")}
;

insert into public.questions
  (okul, sinif, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu, cozum_adimlari)
select v.okul, v.sinif, v.ders, v.konu, v.alt_konu, v.zorluk, v.soru_metni, v.siklar, v.dogru_sik,
       'onaylandi', v.cozum_adimlari
  from _soru_bankasi_tum_siniflar v
 where not exists (
   select 1 from public.questions q
    where q.ders = v.ders and q.sinif = v.sinif and q.soru_metni = v.soru_metni
 );
`;

console.log(`Toplam ${sorular.length} soru:`, sinifOzet);
const kritik = hatalar.filter((h) => !h.includes("(uyarı)"));
const uyari = hatalar.filter((h) => h.includes("(uyarı)"));
console.log(`Hata: ${kritik.length}, uyarı: ${uyari.length}`);
for (const h of kritik) console.log("  HATA", h);
for (const h of uyari.slice(0, 20)) console.log("  uyarı", h);
if (kritik.length) {
  console.log("Hatalar giderilmeden SQL yazılmadı.");
  process.exit(1);
}
fs.writeFileSync(cikti, sql, "utf8");
console.log("Yazıldı:", path.relative(kok, cikti), `(${(sql.length / 1024).toFixed(0)} KB)`);