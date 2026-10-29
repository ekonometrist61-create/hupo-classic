// Veli kazanım haritası SQL doğrulaması: PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node kos.mjs
//
// Adımlar: stubs.sql (bağımlılık taklitleri) → 20261139000000 (veli_kazanim_haritasi)
//          → testler.sql (pg_temp.veli_kazanim_haritasi_testleri) → sonuç.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migrasyon = path.resolve(here, '../../migrations/20261139000000_veli_kazanim_haritasi.sql');
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
const sonuc = await adim('testler', () => db.query('select * from pg_temp.veli_kazanim_haritasi_testleri()'));

let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 300)}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.rows.length} senaryo geçti`);
process.exit(gecen === sonuc.rows.length && sonuc.rows.length > 0 ? 0 : 1);
