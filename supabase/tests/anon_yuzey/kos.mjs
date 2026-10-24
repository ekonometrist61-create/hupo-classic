// GÖR-003 SQL doğrulaması: anonim RPC yetkileri PGlite (Postgres WASM) üzerinde. Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node kos.mjs
//
// Adımlar: musteri_360 stubs (roller, Supabase varsayılan yetkileri) → growth_crm_core
//          → musteri_360 → growth_web_olaylari → iletisim_izni_iptal_et taklidi
//          → ÖNCE: anon çağırabiliyor (kanıt) → 20261080000000 → SONRA: anon çağıramıyor,
//            service_role çağırabiliyor.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migrasyonKlasoru = path.resolve(here, '../../migrations');
const m360Klasoru = path.resolve(here, '../musteri_360');

const zincir = [
  path.join(migrasyonKlasoru, '20261014000000_growth_crm_core.sql'),
  path.join(migrasyonKlasoru, '20261027000000_musteri_360_veri_toplama.sql'),
  path.join(migrasyonKlasoru, '20261028000000_growth_web_olaylari.sql'),
];
const hedefMigration = path.join(migrasyonKlasoru, '20261080000000_anon_izleme_ve_iptal_servis.sql');

// iletisim_izni_iptal_et gerçek tanımı (20261015000000) bu zincirin dışındaki tablolara bağlı.
// Burada yalnızca yetki kontrolü için var olan bir imza taklit edilir; mantık test edilmez.
const iletisimTaklidi = `
create or replace function public.iletisim_izni_iptal_et(p_email text, p_kanal text default 'eposta')
returns void language plpgsql security definer set search_path = '' as $$ begin null; end $$;
`;

const FONKSIYONLAR = [
  'growth_web_olay_kaydet',
  'growth_web_kimlik_bagla',
  'iletisim_izni_iptal_et',
];

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

async function yetkiler() {
  const r = await db.query(
    `select p.proname,
            has_function_privilege('anon', p.oid, 'EXECUTE') as anon,
            has_function_privilege('authenticated', p.oid, 'EXECUTE') as auth,
            has_function_privilege('service_role', p.oid, 'EXECUTE') as svc
       from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = any($1::text[])`,
    [FONKSIYONLAR],
  );
  return new Map(r.rows.map((x) => [x.proname, x]));
}

const pgcryptoSatiri = /^\s*create extension if not exists pgcrypto;\s*$/gim;

await adim('stubs', () => db.exec(fs.readFileSync(path.join(m360Klasoru, 'stubs.sql'), 'utf8')));
for (const m of zincir) {
  const sql = fs.readFileSync(m, 'utf8').replace(pgcryptoSatiri, '-- pgcrypto: PGlite harness\'ta atlandı');
  await adim(path.basename(m), () => db.exec(sql));
  console.log(`zincir: ${path.basename(m)} tamam`);
}
await adim('iletisim-taklidi', () => db.exec(iletisimTaklidi));

const onceki = await yetkiler();
let gecen = 0;
const sonuc = [];
function kontrol(senaryo, kosul, detay = '') {
  if (kosul) gecen++;
  sonuc.push({ no: sonuc.length + 1, senaryo, gecti: kosul, detay });
}

// 1. Kanıt: değişiklik öncesi anon çağırabiliyor (aksi halde test bir şey kanıtlamaz).
for (const f of FONKSIYONLAR) {
  const y = onceki.get(f);
  kontrol(`ÖNCE ${f}: anon çalıştırabiliyor (taban kanıt)`, y?.anon === true, `anon=${y?.anon}`);
}

await adim('hedef-migration', () => db.exec(fs.readFileSync(hedefMigration, 'utf8')));
console.log('hedef: 20261080000000 tamam');

const sonra = await yetkiler();
for (const f of FONKSIYONLAR) {
  const y = sonra.get(f);
  kontrol(`SONRA ${f}: anon çalıştıramaz`, y?.anon === false, `anon=${y?.anon}`);
  kontrol(`SONRA ${f}: authenticated çalıştıramaz`, y?.auth === false, `auth=${y?.auth}`);
  kontrol(`SONRA ${f}: service_role çalıştırabilir`, y?.svc === true, `svc=${y?.svc}`);
}

for (const r of sonuc) {
  console.log(`${String(r.no).padStart(2)}. [${r.gecti ? 'OK  ' : 'FAIL'}] ${r.senaryo}`);
  if (!r.gecti || process.env.DETAY) console.log(`      detay: ${r.detay}`);
}
console.log(`\nSONUÇ: ${gecen}/${sonuc.length} senaryo geçti`);
process.exit(gecen === sonuc.length && sonuc.length > 0 ? 0 : 1);
