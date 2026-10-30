// Deneme veli rıza kapısı SQL doğrulaması: PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node kos.mjs
//
// Adımlar: stubs.sql (Supabase taklitleri) → gerçek migration'lar
//          20261013000000 (_veli_riza_durumu) → 20261138000000 (_deneme_puan_gorunur)
//          → 20261150000000 (rıza kapısı, test edilen) → testler.sql → sonuç.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const mig = (ad) => path.resolve(here, '../../migrations', ad);
const adimlar = [
  path.join(here, 'stubs.sql'),
  mig('20261013000000_veli_riza_kapisi.sql'),
  mig('20261138000000_deneme_1_4_puan_sira_gizle.sql'),
  mig('20261150000000_veli_deneme_riza_kapisi.sql'),
  path.join(here, 'testler.sql'),
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

const sonuc = await db.query('select * from pg_temp.deneme_riza_kapisi_testleri()');
let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 300)}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.rows.length} senaryo geçti`);
process.exit(gecen === sonuc.rows.length && sonuc.rows.length > 0 ? 0 : 1);
