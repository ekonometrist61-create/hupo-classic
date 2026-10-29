// admin_journey_adim_kaydet e-posta adımı doğrulaması (20261103100000): PGlite, zincir 20261103100000'a kadar.
// Kullanım: node adim_kontrol.mjs
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migDir = path.resolve(here, '../../migrations');
const SON = '20261112000000_journey_adim_email_sablon.sql';
const dosyalar = fs.readdirSync(migDir).filter((f) => f.endsWith('.sql')).sort().filter((f) => f <= SON);

const eklenti = /^\s*create extension (if not exists )?(pgcrypto|pg_cron|pg_net|supabase_vault|pgsodium|moddatetime|pg_stat_statements|http|pg_graphql)\b[^;]*;\s*$/gim;
// kos.mjs ile aynı iskelet: roller, auth, storage, cron taklitleri.
const STUB = fs.readFileSync(path.join(here, 'kos.mjs'), 'utf8').match(/const STUB = `([\s\S]*?)`;/)[1];

const db = new PGlite();
await db.exec(STUB);
for (const dosya of dosyalar) {
  const sql = fs.readFileSync(path.join(migDir, dosya), 'utf8').replace(eklenti, '-- eklenti atlandı;');
  try { await db.exec(sql); } catch (e) { /* zincir koşusundaki eski hatalar; bu test için yeterli */ }
}

let gecen = 0, kalan = 0;
const kontrol = (ad, kosul, detay = '') => {
  if (kosul) { gecen++; console.log('  ✓', ad); } else { kalan++; console.log('  ✗', ad, detay); }
};

// Admin kullanıcı: is_admin profil rolüne bakar.
const ADMIN = '00000000-0000-4000-8000-000000000001';
try {
  await db.query(`insert into auth.users (id, email) values ($1, 'admin@test.local') on conflict do nothing`, [ADMIN]);
  await db.query(`insert into public.profiles (id, role) values ($1, 'admin') on conflict (id) do update set role = 'admin'`, [ADMIN]);
} catch (e) { console.log('admin kurulum hatası:', e.message); process.exit(1); }
await db.query(`select set_config('request.jwt.claim.sub', $1, false)`, [ADMIN]);
await db.exec('set role authenticated;');

const journey = (await db.query(`select public.admin_journey_kaydet($1::jsonb) as id`, [JSON.stringify({ name: 'Test journey' })])).rows[0].id;

const dene = async (adimlar) => {
  try {
    const r = await db.query(`select public.admin_journey_adim_kaydet($1::uuid, $2::jsonb) as s`, [journey, JSON.stringify(adimlar)]);
    return { ok: true, sonuc: r.rows[0].s };
  } catch (e) { return { ok: false, mesaj: e.message }; }
};

console.log('Senaryolar:');
let r = await dene([{ step_type: 'email', label: 'Hoş geldin', config: {} }]);
kontrol('e-posta, config boş → reddedilir', !r.ok && r.mesaj.includes('şablon anahtarı'), JSON.stringify(r));

r = await dene([{ step_type: 'email', label: 'Hoş geldin', config: { sablon: '   ' } }]);
kontrol('e-posta, boş boşluklu sablon → reddedilir', !r.ok, JSON.stringify(r));

r = await dene([{ step_type: 'email', label: 'Hoş geldin', config: { sablon: 5 } }]);
kontrol('e-posta, sablon sayı → reddedilir', !r.ok, JSON.stringify(r));

r = await dene([{ step_type: 'email', label: 'Hoş geldin', config: { sablon: 'hosgeldin' } }]);
kontrol('e-posta, geçerli sablon → kabul', r.ok && r.sonuc.adim_sayisi === 1, JSON.stringify(r));

r = await dene([{ step_type: 'delay', label: 'Bekle', config: { saat: 24 } }, { step_type: 'email', label: 'Takip', config: { sablon: 'takip' } }]);
kontrol('delay + geçerli e-posta birlikte → kabul', r.ok && r.sonuc.adim_sayisi === 2, JSON.stringify(r));

r = await dene([{ step_type: 'delay', label: 'Bekle', config: { saat: 24 } }, { step_type: 'email', label: 'Takip', config: {} }]);
kontrol('bir geçersiz e-posta varsa tüm kayıt reddedilir (yazma yok)', !r.ok, JSON.stringify(r));

// Reddedilen çağrı önceki geçerli adımları silmemeli: son başarılı kayıt (1 adım) hâlâ duruyor olmalı.
await db.exec('reset role;');
const kalan_adim = (await db.query(`select count(*)::int as n from public.growth_journey_steps where journey_id = $1`, [journey])).rows[0].n;
kontrol('reddedilen çağrı mevcut adımları değiştirmedi', kalan_adim === 2, `adım sayısı ${kalan_adim}`);

console.log(`\nSONUÇ: ${gecen} geçti, ${kalan} kaldı`);
process.exit(kalan === 0 ? 0 : 1);
