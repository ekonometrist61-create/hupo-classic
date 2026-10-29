// Kelime veri tabanı migration'ını üretir (idempotent yenileme).
// Çalıştırma: node docs/kelime-evreni/veritabani/uret-migration.mjs
// Çıktı: supabase/migrations/20261053000000_kelime_meb_sozlugu_yenile.sql
//
// Yaptığı iş:
//   1. kelime_iliskileri'ne sinif ve kazanim_kodlari sütunları ekler.
//   2. MEB kazanım sözlüğünü kelime_mufredat_kazanimlari tablosuna yazar (RLS açık, istemci yetkisi yok).
//   3. Eski taslağı (20261022000001 tohumu: 93 anlam, 49 ilişki, 48 soru) kaldırır.
//   4. MEB veri setini anlam ve ilişki olarak yükler; mevcut satırlar atlanır, sınıf/kazanım güncellenir.
// Önkoşul: dogrula.mjs geçmeli.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const klasor = dirname(fileURLToPath(import.meta.url));
const kokDizin = join(klasor, "..", "..", "..");
const CIKTI = join(kokDizin, "supabase", "migrations", "20261053000000_kelime_meb_sozlugu_yenile.sql");

// Tek tırnağı SQL'de kaçır
const s = (metin) => `'${String(metin).replaceAll("'", "''")}'`;

// --- Kazanım sözlüğü ---
const mufredat = JSON.parse(readFileSync(join(klasor, "mufredat.json"), "utf8"));
const kazanimAnahtarlari = Object.keys(mufredat).filter((k) => !k.startsWith("_"));
const kazanimSatirlari = kazanimAnahtarlari.map((kod) => {
  const k = mufredat[kod];
  return `  (${s(kod)}, ${k.sinif}, ${s(k.alan)}, ${s(k.metin)}, ${s(k.kaynak)}, ${k.ortak_kazanim ? s(k.ortak_kazanim) : "null"})`;
});

// --- Anlam ve ilişki verisi ---
const anlamlar = new Map(); // "kelime|anlam" -> sozcuk_turu
const iliskiler = [];
for (let sinif = 1; sinif <= 8; sinif++) {
  const veri = JSON.parse(readFileSync(join(klasor, `sinif-${sinif}.json`), "utf8"));
  for (const r of veri.iliskiler) {
    for (const taraf of [r.a, r.b]) {
      const anahtar = `${taraf.kelime}|${taraf.anlam}`;
      if (!anlamlar.has(anahtar)) anlamlar.set(anahtar, taraf);
    }
    const kodlar = [r.kazanim, ...(r.kazanim_ek ?? [])].filter(Boolean);
    iliskiler.push({
      sinif,
      tur: r.tur,
      a: r.a,
      b: r.b,
      kodlar,
    });
  }
}

const anlamSatirlari = [...anlamlar.values()].map(
  (t) => `  (${s(t.kelime)}, ${s(t.anlam)}, ${s(t.sozcuk_turu)})`,
);
const girdiSatirlari = iliskiler.map((r) => {
  const dizi = r.kodlar.length
    ? `array[${r.kodlar.map(s).join(", ")}]::text[]`
    : `'{}'::text[]`;
  return `  (${s(r.a.kelime)}, ${s(r.a.anlam)}, ${s(r.b.kelime)}, ${s(r.b.anlam)}, ${s(r.tur)}, ${r.sinif}, ${dizi})`;
});

const sql = `-- =====================================================================
-- KELİME EVRENİ — MEB'e göre 1–8. sınıf söz varlığı (yenileme)
--
-- Kaynak: docs/kelime-evreni/veritabani (MEB Türkçe programı kazanımları; dilbilgisi.net teyidi).
--
-- 1. kelime_iliskileri: sinif ve kazanim_kodlari (MEB kazanım kodları) sütunları.
-- 2. kelime_mufredat_kazanimlari: kazanım sözlüğü. İstemci yetkisi yok (RLS açık, politika yok).
-- 3. Eski taslak kaldırılır: 20261022000001 tohumundaki 48 soru, 49 ilişki, 93 anlam.
--    Bu tohum kullanıcı onayıyla kaldırılmıştır. Bağlı kayıtlar (denemeler, ustalıklar)
--    ON DELETE CASCADE ile silinir.
-- 4. MEB veri seti yüklenir. Mevcut (kelime, anlam) ve ilişki satırları yeniden kullanılır;
--    sınıf ve kazanım bilgisi güncellenir. Tüm ilişkiler ONAYSIZ (öğrenciye çıkmaz).
-- =====================================================================

set client_encoding = 'UTF8';

-- 1. Sütunlar
alter table public.kelime_iliskileri
  add column if not exists sinif smallint check (sinif between 1 and 12),
  add column if not exists kazanim_kodlari text[] not null default '{}';

comment on column public.kelime_iliskileri.sinif is
  'İlişkinin ait olduğu sınıf (MEB 1–8). Eski taslakta boş.';
comment on column public.kelime_iliskileri.kazanim_kodlari is
  'İlişkiyle eşleşen MEB kazanım alt madde kodları (kelime_mufredat_kazanimlari.kod).';

-- 2. Kazanım sözlüğü
create table if not exists public.kelime_mufredat_kazanimlari (
  kod           text primary key check (length(kod) between 3 and 20),
  sinif         smallint not null check (sinif between 1 and 8),
  alan          text not null check (alan in ('Okuma', 'Konuşma', 'Yazma')),
  metin         text not null check (length(btrim(metin)) > 0),
  kaynak        text not null,
  ortak_kazanim text
);

alter table public.kelime_mufredat_kazanimlari enable row level security;
revoke all on public.kelime_mufredat_kazanimlari from public, anon, authenticated;

insert into public.kelime_mufredat_kazanimlari (kod, sinif, alan, metin, kaynak, ortak_kazanim) values
${kazanimSatirlari.join(",\n")}
on conflict (kod) do update set
  sinif = excluded.sinif,
  alan = excluded.alan,
  metin = excluded.metin,
  kaynak = excluded.kaynak,
  ortak_kazanim = excluded.ortak_kazanim;

-- 3. Eski taslağı kaldır (sıra önemli: sorular → ilişkiler → anlamlar)
delete from public.kelime_sorulari where id::text like '00000000-0000-4000-8000-%';
delete from public.kelime_iliskileri where id::text like '00000000-0000-4000-8000-%';
delete from public.kelime_anlamlari where id::text like '00000000-0000-4000-8000-%';

-- 4. MEB veri seti
create temp table kelime_meb_anlam (
  kelime      text not null,
  anlam       text not null,
  sozcuk_turu text not null
) on commit drop;

insert into kelime_meb_anlam (kelime, anlam, sozcuk_turu) values
${anlamSatirlari.join(",\n")};

create temp table kelime_meb_girdi (
  ka    text not null,
  kan   text not null,
  ha    text not null,
  han   text not null,
  tur   text not null,
  sinif smallint not null,
  kz    text[] not null
) on commit drop;

insert into kelime_meb_girdi (ka, kan, ha, han, tur, sinif, kz) values
${girdiSatirlari.join(",\n")};

insert into public.kelime_anlamlari (kelime, anlam, sozcuk_turu)
select distinct kelime, anlam, sozcuk_turu from kelime_meb_anlam
on conflict (kelime, anlam) do nothing;

insert into public.kelime_iliskileri (kaynak_anlam_id, hedef_anlam_id, iliski_turu, sinif, kazanim_kodlari)
select ka.id, ha.id, g.tur, g.sinif, g.kz
from kelime_meb_girdi g
join public.kelime_anlamlari ka on ka.kelime = g.ka and ka.anlam = g.kan
join public.kelime_anlamlari ha on ha.kelime = g.ha and ha.anlam = g.han
on conflict do nothing;

-- Mevcut ilişkilerin sınıf ve kazanım bilgisini güncelle (çift yönlü eşleşme)
update public.kelime_iliskileri i
set sinif = g.sinif, kazanim_kodlari = g.kz
from kelime_meb_girdi g
join public.kelime_anlamlari ka on ka.kelime = g.ka and ka.anlam = g.kan
join public.kelime_anlamlari ha on ha.kelime = g.ha and ha.anlam = g.han
where i.iliski_turu = g.tur
  and ((i.kaynak_anlam_id = ka.id and i.hedef_anlam_id = ha.id)
    or (i.kaynak_anlam_id = ha.id and i.hedef_anlam_id = ka.id));
`;

writeFileSync(CIKTI, sql, "utf8");
console.log(`Yazıldı: ${CIKTI}`);
console.log(`Kazanım: ${kazanimSatirlari.length}, anlam: ${anlamSatirlari.length}, ilişki: ${girdiSatirlari.length}`);
