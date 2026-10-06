// soru-bankasi/*-bolum-1.md dosyalarından tek bir migration üretir.
// Çalıştır: node tools/soru_bankasi_sql.mjs
// Doğrulama: her maddede 4 şık, A-D arası cevap, "Doğru cevap X" metniyle alan tutarlılığı.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const kok = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const dizin = path.join(kok, "soru-bankasi");
const cikti = path.join(kok, "supabase", "migrations", "20261006030000_soru_bankasi_5_ders_onayli.sql");

const dosyalar = [
  "turkce-bolum-1.md",
  "fen-bilimleri-bolum-1.md",
  "sosyal-bilgiler-bolum-1.md",
  "din-kulturu-bolum-1.md",
  "ingilizce-bolum-1.md",
];

const sorular = [];
const hatalar = [];

for (const ad of dosyalar) {
  const metin = fs.readFileSync(path.join(dizin, ad), "utf8").replace(/\r\n/g, "\n");
  const bloklar = metin.split(/^### Soru /m).slice(1);
  for (const blok of bloklar) {
    const kod = blok.split("\n", 1)[0].trim();
    const alan = (anahtar) => {
      const m = blok.match(new RegExp(`^- \\*\\*${anahtar}:\\*\\*[ \\t]*(.*)$`, "m"));
      return m ? m[1].trim() : "";
    };
    const q = {
      kod,
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
    if (!"ABCD".includes(q.dogru) || q.dogru.length !== 1) hatalar.push(`${kod}: cevap ${q.dogru}`);
    if (new Set(Object.values(q.siklar)).size !== 4) hatalar.push(`${kod}: tekrar eden şık`);
    if (q.adimlar.length === 0) hatalar.push(`${kod}: çözüm adımı yok`);
    const son = q.adimlar.join(" ");
    const beyan = son.match(/Doğru cevap ([A-D]) seçeneğidir/);
    if (beyan && beyan[1] !== q.dogru) hatalar.push(`${kod}: alan=${q.dogru} ama çözüm metni=${beyan[1]}`);
    if (!beyan) hatalar.push(`${kod}: çözüm metninde cevap beyanı yok (uyarı)`);
    for (const t of [q.soru, ...Object.values(q.siklar), q.ipucu, ...q.adimlar, q.konu, q.altKonu]) {
      if (t.includes("$$")) hatalar.push(`${kod}: '$$' içeriyor`);
    }
    sorular.push(q);
  }
}

const dq = (s) => `$$${s}$$`;
const satir = (q) => `(
  'ortaokul', 5, ${dq(q.ders)}, ${dq(q.konu)}, ${q.altKonu ? dq(q.altKonu) : "null"}, ${q.zorluk},
  ${dq(q.soru)},
  jsonb_build_object('A', ${dq(q.siklar.A)}, 'B', ${dq(q.siklar.B)}, 'C', ${dq(q.siklar.C)}, 'D', ${dq(q.siklar.D)}),
  '${q.dogru}',
  to_jsonb(ARRAY[
    ${[`İpucu: ${q.ipucu}`, ...q.adimlar].map(dq).join(",\n    ")}
  ]::text[])
)`;

const sayim = {};
for (const q of sorular) sayim[q.ders] = (sayim[q.ders] || 0) + 1;

const sql = `-- =====================================================================
--  SORU BANKASI: 5 ders (${sorular.length} soru) + Matematik seed onayı — onay_durumu = 'onaylandi'
--  Üretici : node tools/soru_bankasi_sql.mjs   (kaynak: soru-bankasi/*-bolum-1.md)
--  Dağılım : ${Object.entries(sayim).map(([d, n]) => `${d} ${n}`).join(", ")}
--
--  KARAR (2026-10-06, ürün sahibi): bu örnek sorular, kaynak/sınav yılı/okul adı
--  doğrulanmadan 'onaylandi' olarak yayına alınır. İçerik 4. sınıf kazanımlarına göre
--  hazırlanmış ÖRNEK sorulardır; çıkmış sınav sorusu olarak sunulmaz.
--
--  İdempotent: aynı (ders, soru_metni) varsa yeniden eklenmez. Matematik'in 50 sorusu zaten
--  20261003000001 ile 'beklemede' eklendi; burada yalnızca onaylanır (seed satırları 'İpucu:' ile başlar).
-- =====================================================================

set client_encoding = 'UTF8';

create temporary table _soru_bankasi_5_ders (
  okul text, sinif smallint, ders text, konu text, alt_konu text, zorluk smallint,
  soru_metni text, siklar jsonb, dogru_sik text, cozum_adimlari jsonb
) on commit drop;

insert into _soru_bankasi_5_ders
values
${sorular.map(satir).join(",\n")}
;

insert into public.questions
  (okul, sinif, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu, cozum_adimlari)
select v.okul, v.sinif, v.ders, v.konu, v.alt_konu, v.zorluk, v.soru_metni, v.siklar, v.dogru_sik,
       'onaylandi', v.cozum_adimlari
  from _soru_bankasi_5_ders v
 where not exists (
   select 1 from public.questions q where q.ders = v.ders and q.soru_metni = v.soru_metni
 );

update public.questions q
   set onay_durumu = 'onaylandi'
  from _soru_bankasi_5_ders v
 where q.ders = v.ders
   and q.soru_metni = v.soru_metni
   and q.onay_durumu = 'beklemede';

-- Matematik seed (20261003000001): 50 soru, yalnızca 'beklemede' olanlar onaylanır.
update public.questions
   set onay_durumu = 'onaylandi'
 where ders = 'Matematik'
   and onay_durumu = 'beklemede'
   and created_by is null
   and cozum_adimlari ->> 0 like 'İpucu:%';
`;

console.log(`Toplam ${sorular.length} soru:`, sayim);
const kritik = hatalar.filter((h) => !h.includes("(uyarı)"));
const uyari = hatalar.filter((h) => h.includes("(uyarı)"));
console.log(`Hata: ${kritik.length}, uyarı: ${uyari.length}`);
for (const h of kritik) console.log("  HATA", h);
for (const h of uyari.slice(0, 10)) console.log("  uyarı", h);
if (kritik.length) {
  console.log("Hatalar giderilmeden SQL yazılmadı.");
  process.exit(1);
}
fs.writeFileSync(cikti, sql, "utf8");
console.log("Yazıldı:", path.relative(kok, cikti), `(${(sql.length / 1024).toFixed(0)} KB)`);
