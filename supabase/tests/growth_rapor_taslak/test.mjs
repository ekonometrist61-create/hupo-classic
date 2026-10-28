// Growth haftalık rapor taslağı: gerçek migration zinciri PGlite üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
// Zincir: stubs (growth_yasam_dongusu) → core → musteri_360 → web → analitik_huni → yasam_dongusu
//         → harcama → kohort → veri_kalitesi → rapor_taslak.
// Bu dosya gönderim yapmaz; test de yalnız taslak ve karar akışını doğrular.
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

const ADMIN = '00000000-0000-4000-8000-000000000001';
const VELI = '00000000-0000-4000-8000-000000000002';

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await kur('stubs', () => db.exec(fs.readFileSync(STUBS, 'utf8')));
// Test yardımcısı: denetim kaydı (gerçek log_admin_action, admin_audit_log'a yazar; burada tabloya).
await kur('log stub', () => db.exec(`
  create table if not exists public.test_admin_log (aksiyon text, detay jsonb);
  create or replace function public.log_admin_action(p_aksiyon text, p_detay jsonb) returns void
  language sql as $$ insert into public.test_admin_log values (p_aksiyon, p_detay) $$;`));
for (const f of ZINCIR) await kur(f, () => db.exec(oku(f)));
ok('migration zinciri hatasız (core → … → rapor_taslak)', true);

await postgres();
await db.exec(`
  insert into auth.users (id, email) values ('${ADMIN}', 'admin@test.local'), ('${VELI}', 'v@test.local');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin');
`);
// Kohort/CAC girdisi için birkaç kayıtlı hane (boş veriyle de çalışır; yalnız yapı doğrulanır).
await db.exec(`insert into public.growth_households (id, parent_name, email, lifecycle)
  values ('00000000-0000-4000-9300-000000000001', 'R1', 'r1@test.local', 'registered');`);

console.log('\n== Taslak üretimi ==');
await oturum(ADMIN);
const id1 = (await tek(`select public.admin_rapor_taslak_olustur() as id`)).id;
ok('admin taslak oluşturur ve id döner', typeof id1 === 'string' && id1.length === 36);
const r1 = await tek(`select durum, icerik, karar_zamani from public.growth_rapor_taslagi where id = $1`, [id1]);
ok('durum = taslak, karar_zamani boş', r1.durum === 'taslak' && r1.karar_zamani === null, JSON.stringify(r1));
ok('içerik kohort, cac, veri_kalitesi bölümlerini taşır',
  r1.icerik && 'kohort' in r1.icerik && 'cac' in r1.icerik && 'veri_kalitesi' in r1.icerik, JSON.stringify(Object.keys(r1.icerik ?? {})));

const id2 = (await tek(`select public.admin_rapor_taslak_olustur() as id`)).id;
ok('aynı hafta ikinci çağrı yeni satır açmaz (idempotent)', id2 === id1);
const [{ n }] = await sorgu(`select count(*)::int n from public.growth_rapor_taslagi`);
ok('tabloda tek taslak var', n === 1, String(n));

console.log('\n== Karar ==');
await hataBekle('geçersiz karar reddedilir', () => sorgu(`select public.admin_rapor_karar($1, 'gonder')`, [id1]), 'Karar geçersiz');
await sorgu(`select public.admin_rapor_karar($1, 'onayla', 'Okundu, uygun')`, [id1]);
const r2 = await tek(`select durum, karar_veren, karar_zamani, karar_notu from public.growth_rapor_taslagi where id = $1`, [id1]);
ok('onay: durum onaylandi, karar_veren admin, karar_zamani dolu',
  r2.durum === 'onaylandi' && r2.karar_veren === ADMIN && r2.karar_zamani !== null, JSON.stringify(r2));
ok('karar notu kaydedilir', r2.karar_notu === 'Okundu, uygun', String(r2.karar_notu));
await hataBekle('karara bağlanmış rapor ikinci kez karara bağlanamaz',
  () => sorgu(`select public.admin_rapor_karar($1, 'reddet')`, [id1]), 'zaten karara bağlanmış');

// Red yolu: ikinci dönem (doğrudan ekleme, yalnız test için).
await postgres();
await db.exec(`insert into public.growth_rapor_taslagi (donem_anahtari, icerik) values ('test-red', '{}'::jsonb);`);
const idRed = (await tek(`select id from public.growth_rapor_taslagi where donem_anahtari = 'test-red'`)).id;
await oturum(ADMIN);
await hataBekle('karar notu 300 karakteri aşamaz', () =>
  sorgu(`select public.admin_rapor_karar($1, 'reddet', $2)`, [idRed, 'a'.repeat(301)]), 'check');
await sorgu(`select public.admin_rapor_karar($1, 'reddet', null)`, [idRed]);
const r3 = await tek(`select durum from public.growth_rapor_taslagi where id = $1`, [idRed]);
ok('red: durum reddedildi', r3.durum === 'reddedildi', JSON.stringify(r3));

console.log('\n== Listeleme ve denetim ==');
const liste = (await tek(`select public.admin_rapor_listele(20) as v`)).v;
ok('listede iki rapor var, her biri icerik taşır', liste.length === 2 && liste.every((x) => 'icerik' in x), JSON.stringify(liste.map((x) => x.durum)));
const log = await sorgu(`select aksiyon from public.test_admin_log order by aksiyon`);
const akis = log.map((l) => l.aksiyon);
ok('denetim: taslak ve karar işlemleri kaydedilir',
  akis.includes('rapor_taslak_olustur') && akis.filter((a) => a === 'rapor_karar').length === 2, JSON.stringify(akis));

console.log('\n== Yetki ==');
await oturum(VELI);
await hataBekle('admin olmayan taslak üretemez', () => sorgu(`select public.admin_rapor_taslak_olustur()`), 'Yetkisiz');
await hataBekle('admin olmayan karar veremez', () => sorgu(`select public.admin_rapor_karar($1, 'onayla')`, [id1]), 'Yetkisiz');
await hataBekle('admin olmayan listeyi okuyamaz', () => sorgu(`select public.admin_rapor_listele(5)`), 'Yetkisiz');
await oturum(ADMIN);
await rolle('anon');
await hataBekle('anon taslak üretemez', () => sorgu(`select public.admin_rapor_taslak_olustur()`), 'permission denied');
await hataBekle('anon tabloyu okuyamaz', () => sorgu(`select * from public.growth_rapor_taslagi`), 'permission denied');
await postgres();

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
