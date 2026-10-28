// Kelime ilişkilerine örnek cümle, hatırlatıcı ve hafıza tekniği alanlarını ekleyen migration'ı üretir.
// Çalıştırma: node docs/kelime-evreni/veritabani/uret-icerik-migration.mjs
// Çıktı: supabase/migrations/20261054000000_kelime_icerik_ornek_hatirlatici.sql
// Önkoşul: uret-migration.mjs ile üretilmiş ve uygulanmış 20261053000000 migration'ı.
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const klasor = dirname(fileURLToPath(import.meta.url));
const kokDizin = join(klasor, "..", "..", "..");
const CIKTI = process.env.CIKTI_YOLU ?? join(kokDizin, "supabase", "migrations", "20261054000000_kelime_icerik_ornek_hatirlatici.sql");

const s = (metin) => `'${String(metin).replaceAll("'", "''")}'`;

const satirlar = [];
for (let sinif = 1; sinif <= 8; sinif++) {
  const veri = JSON.parse(readFileSync(join(klasor, `sinif-${sinif}.json`), "utf8"));
  for (const r of veri.iliskiler) {
    if (!r.ornek || !r.hatirlatici || !r.teknik) {
      throw new Error(`${r.id}: ornek/hatirlatici/teknik eksik`);
    }
    satirlar.push(
      `  (${s(r.a.kelime)}, ${s(r.a.anlam)}, ${s(r.b.kelime)}, ${s(r.b.anlam)}, ${s(r.tur)}, ${s(r.ornek)}, ${s(r.hatirlatici)}, ${s(r.teknik)})`,
    );
  }
}

const sql = `-- =====================================================================
-- KELİME EVRENİ — ilişkilere örnek cümle, hatırlatıcı ve hafıza tekniği
--
-- Kaynak: docs/kelime-evreni/veritabani/sinif-*.json (dogrula.mjs geçti).
-- Her alan ilişki bazındadır. Yalnızca eşleşen satırlar güncellenir; yeni satır eklenmez.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.kelime_iliskileri
  add column if not exists ornek text check (ornek is null or length(btrim(ornek)) between 5 and 300),
  add column if not exists hatirlatici text check (hatirlatici is null or length(btrim(hatirlatici)) between 5 and 300),
  add column if not exists teknik text check (teknik is null or length(btrim(teknik)) between 2 and 40);

comment on column public.kelime_iliskileri.ornek is 'İlişkiyi gösteren örnek cümle (öğrenciye gösterim).';
comment on column public.kelime_iliskileri.hatirlatici is 'Çocuk için hafıza ipucu.';
comment on column public.kelime_iliskileri.teknik is 'Kullanılan hafıza tekniği etiketi (çağrışım, hikâye, görsel, hareket, ses, eşleştirme, karşıtlık).';

create temp table kelime_icerik_girdi (
  ka text not null, kan text not null, ha text not null, han text not null, tur text not null,
  ornek text not null, hatirlatici text not null, teknik text not null
) on commit drop;

insert into kelime_icerik_girdi (ka, kan, ha, han, tur, ornek, hatirlatici, teknik) values
${satirlar.join(",\n")};

update public.kelime_iliskileri i
set ornek = g.ornek, hatirlatici = g.hatirlatici, teknik = g.teknik
from kelime_icerik_girdi g
join public.kelime_anlamlari ka on ka.kelime = g.ka and ka.anlam = g.kan
join public.kelime_anlamlari ha on ha.kelime = g.ha and ha.anlam = g.han
where i.iliski_turu = g.tur
  and ((i.kaynak_anlam_id = ka.id and i.hedef_anlam_id = ha.id)
    or (i.kaynak_anlam_id = ha.id and i.hedef_anlam_id = ka.id));
`;

writeFileSync(CIKTI, sql, "utf8");
console.log(`Yazıldı: ${CIKTI} (${satirlar.length} ilişki)`);
