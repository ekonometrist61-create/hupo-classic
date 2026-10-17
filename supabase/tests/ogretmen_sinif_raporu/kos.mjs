// Öğretmen sınıf raporu SQL doğrulaması: PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node kos.mjs
//
// Adımlar: stubs.sql (Supabase taklitleri) → 20261003000010 (siniflar, sinif_uyelikleri)
//          → 20261041000000 (ogretmen_siniflarim) → testler.sql (pg_temp.ogretmen_sinif_raporu_testleri) → sonuç.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migrasyonlar = [
  path.resolve(here, '../../migrations/20261003000010_ogretmen_ve_siniflar.sql'),
  path.resolve(here, '../../migrations/20261041000000_ogretmen_sinif_raporu.sql'),
];
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
for (const m of migrasyonlar) {
  await adim(path.basename(m), () => db.exec(fs.readFileSync(m, 'utf8')));
  console.log(`migration: ${path.basename(m)} tamam`);
}
await adim('test-yukleme', () => db.exec(fs.readFileSync(testDosyasi, 'utf8')));
const sonuc = await adim('testler', () => db.query('select * from pg_temp.ogretmen_sinif_raporu_testleri()'));

let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 300)}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.rows.length} senaryo geçti`);
process.exit(gecen === sonuc.rows.length && sonuc.rows.length > 0 ? 0 : 1);
