// Growth KVKK SQL doğrulaması: PGlite (Postgres WASM). Docker gerekmez; uzak veritabanına dokunmaz.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node kos.mjs
//
// Adımlar: musteri_360/stubs.sql → stubs_ek.sql → growth_crm_core → growth_crm_rpcs
//          → musteri_360 (20261027) → growth_kvkk (20261106) → testler.sql → sonuç tablosu.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const mig = (ad) => path.resolve(here, '../../migrations', ad);
const adimlar = [
  path.resolve(here, '../musteri_360/stubs.sql'),
  path.join(here, 'stubs_ek.sql'),
  mig('20261014000000_growth_crm_core.sql'),
  mig('20261014000100_growth_crm_rpcs.sql'),
  mig('20261027000000_musteri_360_veri_toplama.sql'),
  mig('20261106000000_growth_kvkk_birlestirme.sql'),
];
const testDosyasi = path.join(here, 'testler.sql');

// PGlite'ta pgcrypto yok; gen_random_uuid PostgreSQL yerleşiğidir. Yalnızca bu satır harness'ta atlanır.
const eklentiSatiri = /^\s*create extension if not exists pgcrypto;\s*$/gim;

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

for (const dosya of adimlar) {
  const sql = fs.readFileSync(dosya, 'utf8').replace(eklentiSatiri, '-- pgcrypto: PGlite harness\'ta atlandı');
  await adim(path.basename(dosya), () => db.exec(sql));
  console.log(`tamam: ${path.basename(dosya)}`);
}
await adim('testler-yukleme', () => db.exec(fs.readFileSync(testDosyasi, 'utf8')));
const sonuc = await adim('testler', () => db.query('select * from pg_temp.growth_kvkk_testleri()'));

let gecen = 0;
for (const r of sonuc.rows) {
  if (r.gecti) gecen++;
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${String(r.detay).slice(0, 300)}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.rows.length} senaryo geçti`);
process.exit(gecen === sonuc.rows.length && sonuc.rows.length > 0 ? 0 : 1);
