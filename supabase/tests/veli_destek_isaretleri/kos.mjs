// Veli destek isaretleri SQL dogrulamasi: PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanim (bu klasorde bir kez: npm install):
//   node kos.mjs
//
// Adimlar: stubs.sql (bagimlilik taklitleri) -> 20261145000000 (veli_destek_isaretleri)
//          -> testler.sql (pg_temp.veli_destek_testleri) -> sonuc.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migrasyon = path.resolve(here, '../../migrations/20261145000000_veli_destek_isaretleri.sql');
const testDosyasi = path.join(here, 'testler.sql');

const db = new PGlite();

async function adim(ad, fn) {
  try {
    return await fn();
  } catch (e) {
    console.log(`HATA [${ad}]: ${e.message}`);
    if (e.position) console.log(`  konum: ${e.position}`);
    process.exit(1);
  }
}

await adim('stubs', () => db.exec(fs.readFileSync(path.join(here, 'stubs.sql'), 'utf8')));
console.log('stubs: tamam');
await adim('migration', () => db.exec(fs.readFileSync(migrasyon, 'utf8')));
console.log(`migration: ${path.basename(migrasyon)} tamam`);
await adim('test-yukleme', () => db.exec(fs.readFileSync(testDosyasi, 'utf8')));
const sonuc = await adim('testler', () => db.query('select * from pg_temp.veli_destek_testleri()'));

let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 300)}`);
}
console.log(`\nSONUC: ${gecen}/${sonuc.rows.length} senaryo gecti`);
process.exit(gecen === sonuc.rows.length && sonuc.rows.length > 0 ? 0 : 1);
