// Duyuru / anket arşiv testleri: PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install — kelime_evreni'nin PGlite sürümünü kullanır):
//   node run.mjs
//
// Zincir: kelime_evreni/stubs.sql → stubs_arsiv.sql → duyuru ve anket migration'ları
//         → duyuru_anket_arsiv_tests.sql
// Taklitler gerçek bağımlılıkların çağrı sözleşmesidir; tam migration zinciri değildir.
import { createRequire } from 'node:module';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, '..', '..', '..');
const kelime = path.resolve(here, '..', 'kelime_evreni');

const require = createRequire(path.join(kelime, 'package.json'));
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite')).href);

const migrasyonlar = [
  path.join(repo, 'supabase/migrations/20261026000000_site_duyurulari.sql'),
  path.join(repo, 'supabase/migrations/20261029000000_anket_yuzeyler.sql'),
  path.join(repo, 'supabase/migrations/20261030000000_duyuru_yuzeyler.sql'),
  path.join(repo, 'supabase/migrations/20261032000000_duyuru_anket_arsiv_ve_sil.sql'),
];
// Anket zinciri: 20261007000030 anketler / anket_yanitlari tablolarını ve admin_anket_* RPC'lerini kurar.
const anketTemel = path.join(repo, 'supabase/migrations/20261007000030_anket_otomasyon_analitik_ve_mutabakat.sql');

const db = new PGlite();

async function calistir(ad, dosya) {
  try {
    await db.exec(fs.readFileSync(dosya, 'utf8'));
    console.log(`tamam: ${ad}`);
    return true;
  } catch (e) {
    console.log(`HATA [${ad}]: ${e.message}`);
    if (e.position) console.log(`  konum: ${e.position}`);
    return false;
  }
}

if (!(await calistir('stubs', path.join(kelime, 'stubs.sql')))) process.exit(1);
if (!(await calistir('stubs_arsiv', path.join(here, 'stubs_arsiv.sql')))) process.exit(1);
if (!(await calistir('anket-temel', anketTemel))) process.exit(1);
for (const m of migrasyonlar) {
  if (!(await calistir(path.basename(m), m))) process.exit(1);
}
if (!(await calistir('testler', path.join(here, 'duyuru_anket_arsiv_tests.sql')))) process.exit(1);

const sonuc = await db.query('select * from pg_temp.arsiv_testleri()');
let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 300)}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.rows.length} senaryo geçti`);
process.exit(gecen === sonuc.rows.length ? 0 : 1);
