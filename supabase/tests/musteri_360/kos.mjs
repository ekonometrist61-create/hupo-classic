// Müşteri 360 veri toplama SQL doğrulaması: PGlite (Postgres WASM). Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node kos.mjs
//
// Adımlar: stubs.sql (Supabase taklitleri) → growth_crm_core → musteri_360 migration
//          → testler.sql (pg_temp.musteri360_testleri) → sonuç tablosu.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migrasyonlar = [
  path.resolve(here, '../../migrations/20261014000000_growth_crm_core.sql'),
  path.resolve(here, '../../migrations/20261027000000_musteri_360_veri_toplama.sql'),
  path.resolve(here, '../../migrations/20261028000000_growth_web_olaylari.sql'),
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
// PGlite'ta pgcrypto eklentisi yok. Growth CRM migration'ı pgcrypto fonksiyonu kullanmaz
// (gen_random_uuid PG 13+ yerleşik), bu yüzden yalnızca o satır harness'ta atlanır; dosya değişmez.
const eklentiSatiri = /^\s*create extension if not exists pgcrypto;\s*$/gim;
for (const m of migrasyonlar) {
  const sql = fs.readFileSync(m, 'utf8').replace(eklentiSatiri, '-- pgcrypto: PGlite harness\'ta atlandı');
  await adim(path.basename(m), () => db.exec(sql));
  console.log(`migration: ${path.basename(m)} tamam`);
}
await adim('test-yukleme', () => db.exec(fs.readFileSync(testDosyasi, 'utf8')));
const sonuc = await adim('testler', () => db.query('select * from pg_temp.musteri360_testleri()'));

let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 300)}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.rows.length} senaryo geçti`);
process.exit(gecen === sonuc.rows.length && sonuc.rows.length > 0 ? 0 : 1);
