// Kelime Evreni SQL doğrulaması: PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node pglite-kos.mjs ../../migrations/20261022000000_kelime_evreni.sql kelime_evreni_tests.sql
//
// Adımlar: stubs.sql (Supabase taklitleri) → migration → test fonksiyonu → sonuç tablosu.
// Taklitler gerçek bağımlılıkların çağrı sözleşmesini taşır; tam migration zinciri değildir.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
// Son argüman test dosyasıdır; öncekiler sırayla uygulanan migration'lardır.
const args = process.argv.slice(2);
const testsArg = args.pop();
const migrationArgs = args;
if (!testsArg || migrationArgs.length === 0) {
  console.log('Kullanım: node pglite-kos.mjs <migration.sql> [...] <tests.sql>');
  process.exit(2);
}

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
for (const m of migrationArgs) {
  await adim(path.basename(m), () => db.exec(fs.readFileSync(path.resolve(m), 'utf8')));
  console.log(`migration: ${path.basename(m)} tamam`);
}
await adim('test-yukleme', () => db.exec(fs.readFileSync(path.resolve(testsArg), 'utf8')));
const sonuc = await adim('testler', () => db.query('select * from pg_temp.kelime_evreni_testleri()'));

let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 300)}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.rows.length} senaryo geçti`);
process.exit(gecen === sonuc.rows.length ? 0 : 1);
