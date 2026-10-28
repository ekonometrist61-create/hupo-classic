// Haftalık rapor taslağı zamanlı üretim: gerçek migration zinciri PGlite üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
// Zincir: stubs (growth_yasam_dongusu) → core → musteri_360 → web → analitik_huni → yasam_dongusu
//         → harcama → kohort → veri_kalitesi → rapor_taslak → rapor_zamanli.
// Bu dosya gönderim yapmaz; yalnız taslak üretimini ve yetkileri doğrular.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const STUBS = path.resolve(HERE, '../growth_yasam_dongusu/stubs.sql');
const ZINCIR = [
  '20261014000000_growth_crm_core.sql',
  '20261027000000_musteri_360_veri_toplama.sql',
  '20261028000000_growth_web_olaylari.sql',
  '20261105000000_growth_analitik_huni.sql',
  '20261104000000_growth_yasam_dongusu.sql',
  '20261113000000_growth_harcama.sql',
  '20261114000000_growth_kohort_cac.sql',
  '20261115000000_growth_veri_kalitesi.sql',
  '20261116000000_growth_rapor_taslak.sql',
  '20261118000000_growth_rapor_zamanli.sql',
];

const eklentiSatiri = /^\s*create extension if not exists (pgcrypto|pg_cron)\b[^;]*;\s*$/gim;
const oku = (f) => fs.readFileSync(path.join(MIG, f), 'utf8')
  .replace(eklentiSatiri, "-- eklenti PGlite harness'ta atlandı");

const db = new PGlite();

let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const hataBekle = async (ad, fn, parca) => {
  try {
    await fn();
    fail++;
    console.log('  ✗', ad, '(hata bekleniyordu)');
  } catch (e) {
    const m = String(e.message ?? e);
    if (parca && !m.includes(parca)) { fail++; console.log('  ✗', ad, `beklenen "${parca}", gelen: ${m}`); }
    else { pass++; console.log('  ✓', ad, '→', m.slice(0, 90)); }
  }
};
const kur = async (ad, fn) => {
  try { await fn(); }
  catch (e) { console.log(`HATA [${ad}]: ${e.message}`); process.exit(1); }
};
const tek = async (sql, params = []) => (await db.query(sql, params)).rows[0];
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const postgres = () => db.exec('reset role;');
const rolle = (rol) => db.exec(`reset role; set role ${rol};`);
const oturum = (id) => db.exec(`set request.jwt.claims = '{"sub":"${id}"}';`);
const oturumKapat = () => db.exec(`set request.jwt.claims = '';`);

const ADMIN = '00000000-0000-4000-8000-000000000001';
const VELI = '00000000-0000-4000-8000-000000000002';

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await kur('stubs', () => db.exec(fs.readFileSync(STUBS, 'utf8')));
await kur('log stub', () => db.exec(`
  create table if not exists public.test_admin_log (aksiyon text, detay jsonb);
  create or replace function public.log_admin_action(p_aksiyon text, p_detay jsonb) returns void
  language sql as $$ insert into public.test_admin_log values (p_aksiyon, p_detay) $$;`));
for (const f of ZINCIR) await kur(f, () => db.exec(oku(f)));
ok('migration zinciri hatasız (… → rapor_zamanli)', true);

await postgres();
await db.exec(`
  insert into auth.users (id, email) values ('${ADMIN}', 'a@test.local'), ('${VELI}', 'v@test.local');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin'), ('${VELI}', 'veli');
`);
await db.exec(`insert into public.growth_households (id, parent_name, email, lifecycle)
  values ('00000000-0000-4000-9300-000000000001', 'R1', 'r1@test.local', 'registered');`);

console.log('\n== Zamanlı üretim (oturum yok, cron benzeri) ==');
await oturumKapat();
const id1 = (await tek(`select public.growth_rapor_zamanli_uret() as id`)).id;
ok('oturumsuz zamanlı üretim id döner', typeof id1 === 'string' && id1.length === 36, String(id1));
const r1 = await tek(`select durum, icerik from public.growth_rapor_taslagi where id = $1`, [id1]);
ok('durum taslak (gönderim yok)', r1.durum === 'taslak', JSON.stringify(r1));
ok('icerik kaynak = zamanli ve üç bölüm var',
  r1.icerik.kaynak === 'zamanli' && 'kohort' in r1.icerik && 'cac' in r1.icerik && 'veri_kalitesi' in r1.icerik,
  JSON.stringify(Object.keys(r1.icerik)));
const id2 = (await tek(`select public.growth_rapor_zamanli_uret() as id`)).id;
ok('aynı hafta ikinci zamanlı çağrı aynı kaydı döndürür', id2 === id1);

console.log('\n== Manuel üretim ile aynı dönem anahtarı ==');
await oturum(ADMIN);
const id3 = (await tek(`select public.admin_rapor_taslak_olustur() as id`)).id;
ok('yönetici üretimi aynı haftanın kaydını döndürür (çift kayıt yok)', id3 === id1, `${id3} vs ${id1}`);
const [{ n }] = await sorgu(`select count(*)::int n from public.growth_rapor_taslagi`);
ok('tabloda tek taslak var', n === 1, String(n));

console.log('\n== Sarmalayıcılar hâlâ yönetici denetimi yapar ==');
const k = (await tek(`select public.admin_growth_kohort(30) as v`)).v;
ok('yönetici admin_growth_kohort çalıştırabilir (ozet var)', Array.isArray(k.ozet) && k.ozet.length === 3);
const c = (await tek(`select public.admin_growth_cac(30) as v`)).v;
ok('yönetici admin_growth_cac çalıştırabilir', 'yeni_hane' in c);
const vk = (await tek(`select public.admin_growth_veri_kalitesi() as v`)).v;
ok('yönetici admin_growth_veri_kalitesi çalıştırabilir', Array.isArray(vk.kalite));

await oturum(VELI);
await hataBekle('veli admin_growth_kohort çağıramaz', () => tek(`select public.admin_growth_kohort(30)`), 'Yetkisiz');
await hataBekle('veli admin_growth_cac çağıramaz', () => tek(`select public.admin_growth_cac(30)`), 'Yetkisiz');
await hataBekle('veli admin_growth_veri_kalitesi çağıramaz', () => tek(`select public.admin_growth_veri_kalitesi()`), 'Yetkisiz');

console.log('\n== Çekirdek ve zamanlı fonksiyonlar anon/authenticated için kapalı ==');
await rolle('anon');
await hataBekle('anon zamanlı üretimi çalıştıramaz', () => tek(`select public.growth_rapor_zamanli_uret()`), 'permission denied');
await hataBekle('anon kohort çekirdeğini çalıştıramaz', () => tek(`select public._growth_kohort_veri(30)`), 'permission denied');
await hataBekle('anon CAC çekirdeğini çalıştıramaz', () => tek(`select public._growth_cac_veri(30)`), 'permission denied');
await hataBekle('anon veri kalitesi çekirdeğini çalıştıramaz', () => tek(`select public._growth_veri_kalitesi_veri()`), 'permission denied');
await postgres();
await oturum(VELI);
await rolle('authenticated');
await hataBekle('authenticated (veli) zamanlı üretimi çalıştıramaz', () => tek(`select public.growth_rapor_zamanli_uret()`), 'permission denied');
await hataBekle('authenticated (veli) çekirdeği çalıştıramaz', () => tek(`select public._growth_kohort_veri(30)`), 'permission denied');
await postgres();

console.log('\n== Zamanlayıcı: pg_cron yokken hata vermez ==');
const cronYok = !(await tek(`select exists(select 1 from pg_extension where extname='pg_cron') as v`)).v;
ok('harness pg_cron olmadan kurulum başarılı (zamanlayıcı yalnız not düşer)', cronYok);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
