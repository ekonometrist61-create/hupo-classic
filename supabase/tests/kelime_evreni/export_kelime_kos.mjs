// GÖR-048: export_my_data kelime bölümünün GERÇEK kelime migrasyonlarıyla PGlite sınaması.
// Kullanım (bu klasörde, npm install yapılmış olmalı):  node export_kelime_kos.mjs
// Yükleme: Supabase taklitleri (stubs.sql) → taban taklitler (export_taban_stubs.sql) →
//          gerçek migrasyonlar 20261022, 20261045, 20261046 → export_kelime_tests.sql.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const mig = (ad) => path.resolve(here, '../../migrations', ad);
const adimlar = [
  path.join(here, 'stubs.sql'),
  path.join(here, 'export_taban_stubs.sql'),
  mig('20261022000000_kelime_evreni.sql'),
  mig('20261045000000_kelime_veli_ozeti_riza_kapisi.sql'),
  mig('20261046000000_export_my_data_kelime.sql'),
  path.join(here, 'export_kelime_tests.sql'),
];

const db = new PGlite();

for (const dosya of adimlar) {
  try {
    await db.exec(fs.readFileSync(dosya, 'utf8'));
    console.log(`tamam: ${path.basename(dosya)}`);
  } catch (e) {
    console.log(`HATA [${path.basename(dosya)}]: ${e.message}`);
    if (e.position) console.log(`  konum: ${e.position}`);
    process.exit(1);
  }
}

const sonuc = await db.query('select * from pg_temp.export_kelime_testleri()');
let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 300)}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.rows.length} senaryo geçti`);
process.exit(gecen === sonuc.rows.length && sonuc.rows.length > 0 ? 0 : 1);
