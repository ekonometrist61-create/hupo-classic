// Teyit düzeltmelerini uygulayan migration'ı üretir (Gemini teyidi sonrası).
// Çalıştırma: node docs/kelime-evreni/veritabani/uret-duzeltme-migration.mjs
// Çıktı: supabase/migrations/20261056000000_kelime_teyit_duzeltmeleri.sql
//
// Bölümler:
//   1. Anlam metinlerinin düzeltilmesi (yalnızca metin; kimlik değişmez).
//   2. Örnek / hatırlatıcı güncellemesi (uret-icerik-migration.mjs gövdesi).
//   3. Yalnızca TASLAK soruların yeniden üretilmesi (yayında soru yoktur; durum kontrolü ile).
import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync, unlinkSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";

const klasor = dirname(fileURLToPath(import.meta.url));
const kokDizin = join(klasor, "..", "..", "..");
const CIKTI = join(kokDizin, "supabase", "migrations", "20261056000000_kelime_teyit_duzeltmeleri.sql");

// Anlam düzeltmeleri: [kelime, eski anlam, yeni anlam]
const ANLAM_DUZELTMELERI = [
  ["mühim", "Önemli, değerli, ehemmiyetli", "Kendisine özen gösterilmesi gereken, dikkate değer, ehemmiyetli"],
  ["sol", "Müzikte yedi nottan biri", "Müzikte yedi ana notadan biri"],
  ["düş", "Uyurken zihinde beliren görüntü, rüya", "Zihinde canlanan, gerçek olmayan imge"],
];
const s = (metin) => `'${String(metin).replaceAll("'", "''")}'`;

const gecici = (ad) => join(tmpdir(), `kelime-${ad}-${process.pid}.sql`);
const altGenerator = (betik, cikti) => {
  execFileSync(process.execPath, [join(klasor, betik)], {
    env: { ...process.env, CIKTI_YOLU: cikti },
    stdio: "pipe",
  });
  const govde = readFileSync(cikti, "utf8");
  unlinkSync(cikti);
  return govde;
};

const icerikGovde = altGenerator("uret-icerik-migration.mjs", gecici("icerik"));
const soruGovde = altGenerator("uret-soru-migration.mjs", gecici("soru"));

const anlamBolumu = ANLAM_DUZELTMELERI.map(
  ([kelime, eski, yeni]) => `update public.kelime_anlamlari set anlam = ${s(yeni)}
where kelime = ${s(kelime)} and anlam = ${s(eski)}
  and not exists (select 1 from public.kelime_anlamlari x where x.kelime = ${s(kelime)} and x.anlam = ${s(yeni)});`,
).join("\n\n");

const sql = `-- =====================================================================
-- KELİME EVRENİ — Gemini teyidi sonrası düzeltmeler
--
-- 1. Anlam metinleri (mühim, sol, düş): döngüsel tanım ve yazım düzeltmesi.
-- 2. Örnek ve hatırlatıcı metinleri: kaynak sinif-*.json (uret-icerik-migration gövdesi).
-- 3. Yalnızca TASLAK soruların yeniden üretimi. Yayında soru yoktur (kontrol edilir).
-- Üretici: uret-duzeltme-migration.mjs. Teyit: teyit-gemini.json.
-- =====================================================================

-- 1. Anlamlar
${anlamBolumu}

-- 2. Örnek ve hatırlatıcılar
${icerikGovde.replace(/^-- =+[\s\S]*?set client_encoding = 'UTF8';\n/, "")}

-- 3. Taslak soruların yeniden üretimi (yayında olan varsa dur)
do $$
begin
  if exists (select 1 from public.kelime_sorulari where durum = 'yayinda') then
    raise exception 'Yayında kelime sorusu var; taslak yeniden üretimi durduruldu';
  end if;
end $$;

delete from public.kelime_sorulari where durum = 'taslak';

${soruGovde.replace(/^-- =+[\s\S]*?set client_encoding = 'UTF8';\n/, "")}`;

writeFileSync(CIKTI, sql, "utf8");
console.log(`Yazıldı: ${CIKTI}`);
