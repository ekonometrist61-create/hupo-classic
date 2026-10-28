// Growth kohort (D1/D7/D30) ve CAC: gerçek migration zinciri PGlite üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
// Zincir: stubs (growth_analitik_huni) → core → musteri_360 → web → analitik_huni → yasam_dongusu
//         → harcama → kohort. Eklenti satırları (pgcrypto, pg_cron) harness'ta atlanır.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
// Yaşam döngüsü testinin stub'ı: veli_adaylari, user_answers, answer_events ve roller burada.
const STUBS = path.resolve(HERE, '../growth_yasam_dongusu/stubs.sql');
const ZINCIR = [
  '20261014000000_growth_crm_core.sql',
  '20261027000000_musteri_360_veri_toplama.sql',
  '20261028000000_growth_web_olaylari.sql',
  '20261105000000_growth_analitik_huni.sql',
  '20261104000000_growth_yasam_dongusu.sql',
  '20261113000000_growth_harcama.sql',
  '20261114000000_growth_kohort_cac.sql',
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
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const tek = async (sql, params = []) => (await sorgu(sql, params))[0];
const postgres = () => db.exec('reset role;');
const rolle = (rol) => db.exec(`reset role; set role ${rol};`);
const adminOl = (evet) => db.exec(`set test.admin = '${evet ? 'evet' : 'hayir'}';`);
const ADMIN = '00000000-0000-4000-8000-000000000001';

// Kayıtlı hane oluşturur (created_at: "gun_once" gün önce, Istanbul günü kg olarak SQL'de hesaplanır).
let sira = 0;
const hane = async (lifecycle, gunOnce) => {
  sira++;
  const id = `00000000-0000-4000-9000-${String(sira).padStart(12, '0')}`;
  await db.exec(`insert into public.growth_households (id, parent_name, email, lifecycle, created_at)
    values ('${id}', 'Test ${sira}', 'h${sira}@test.local', '${lifecycle}', now() - interval '${gunOnce} days');`);
  return id;
};
// Hanenin kg'sine göre N. günde aktiflik (Istanbul takvimi, oluşturma ile aynı kural).
const aktif = (id, n) => db.exec(`insert into public.growth_hane_aktif_gunleri (household_id, gun)
  select h.id, (h.created_at at time zone 'Europe/Istanbul')::date + ${n}
    from public.growth_households h where h.id = '${id}';`);

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await kur('stubs', () => db.exec(fs.readFileSync(STUBS, 'utf8')));
for (const f of ZINCIR) await kur(f, () => db.exec(oku(f)));
ok('migration zinciri hatasız (core → … → kohort)', true);
await postgres();
// Yönetici: auth.users + profiles.role = 'admin' (yaşam döngüsü stub'ının require_admin kuralı).
const YETKISIZ = '00000000-0000-4000-8000-000000000002';
await db.exec(`
  insert into auth.users (id, email) values ('${ADMIN}', 'admin@test.local');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin');
`);
await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);

console.log('\n== Veri ==');
// Kohort A: 40 gün önce, 10 kayıtlı hane. D1: 8, D7: 6, D30: 5 aktif.
const A = [];
for (let i = 0; i < 10; i++) A.push(await hane('registered', 40));
for (let i = 0; i < 8; i++) await aktif(A[i], 1);
for (let i = 0; i < 6; i++) await aktif(A[i], 7);
for (let i = 0; i < 5; i++) await aktif(A[i], 30);
// Kohort B: 2 gün önce, 3 kayıtlı hane. Yalnız D1 olgun. D1: 2 aktif.
const B = [];
for (let i = 0; i < 3; i++) B.push(await hane('activated', 2));
for (let i = 0; i < 2; i++) await aktif(B[i], 1);
// Dışlananlar: lead ve visitor (kayıtlı değil), 120 gün önce (pencere dışı).
for (let i = 0; i < 4; i++) await hane('lead', 40);
await hane('visitor', 40);
await hane('registered', 120);

// Harcama: pencerede TRY 1000 + USD 200; pencere dışında TRY 5000 (200 gün önce).
await db.exec(`
  insert into public.growth_harcama (tarih, kanal, tutar, para_birimi) values
    (current_date - 5, 'meta', 900, 'TRY'),
    (current_date - 1, 'google_ads', 100, 'TRY'),
    (current_date - 2, 'google_ads', 200, 'USD'),
    (current_date - 200, 'meta', 5000, 'TRY');
`);

console.log('\n== Kohort ==');
const k = (await tek(`select public.admin_growth_kohort(90) as v`)).v;
const d1 = k.ozet.find((x) => x.gun === 1);
const d7 = k.ozet.find((x) => x.gun === 7);
const d30 = k.ozet.find((x) => x.gun === 30);

ok('D1 uygun hane = A(10) + B(3) = 13 (lead/visitor/120 gün dışlandı)', d1.uygun_hane === 13, JSON.stringify(d1));
ok('D1 tutulan = 8 + 2 = 10', d1.tutulan === 10, JSON.stringify(d1));
ok('D1 oran = 10/13 = 76.9', Number(d1.oran) === 76.9, JSON.stringify(d1));
ok('D7 olgunluk: B olgun değil; uygun = 10 (A)', d7.uygun_hane === 10, JSON.stringify(d7));
ok('D7 oran = 6/10 = 60', Number(d7.oran) === 60, JSON.stringify(d7));
ok('D30 uygun = 10, oran = 5/10 = 50', d30.uygun_hane === 10 && Number(d30.oran) === 50, JSON.stringify(d30));

const haftaA = k.haftalik.find((w) => w.boyut === 10);
ok('haftalık: A haftası boyut 10 ve D1 oranı 80 (8/10)', haftaA && Number(haftaA.d1_oran) === 80, JSON.stringify(k.haftalik));
const haftaB = k.haftalik.find((w) => w.boyut === null);
ok('haftalık: 3 kişilik B haftası gizli (boyut null, 5 eşiği)', !!haftaB, JSON.stringify(k.haftalik));

console.log('\n== Gizlilik eşiği (kohort) ==');
// Yalnız 3 hane içeren pencere: ozet uygun_hane null olmalı.
const kucuk = (await tek(`select public.admin_growth_kohort(5) as v`)).v;
const kD1 = kucuk.ozet.find((x) => x.gun === 1);
ok('5 günlük pencere: yalnız B (3 hane) kalır, uygun_hane gizli (null)', kD1.uygun_hane === null && kD1.oran === null, JSON.stringify(kD1));

console.log('\n== CAC ==');
const c = (await tek(`select public.admin_growth_cac(90) as v`)).v;
ok('yeni_hane = 13 (kayıtlı, pencere içi)', c.yeni_hane === 13, JSON.stringify(c));
const cTry = c.satirlar.find((s) => s.para_birimi === 'TRY');
const cUsd = c.satirlar.find((s) => s.para_birimi === 'USD');
ok('TRY harcama pencere içi toplam 1000 (200 günlük 5000 dışlandı)', cTry && Number(cTry.harcama) === 1000, JSON.stringify(cTry));
ok('TRY CAC = 1000/13 = 76.92', cTry && Number(cTry.cac) === 76.92 && cTry.durum === 'hesaplandi', JSON.stringify(cTry));
ok('USD ayrı satır, CAC = 200/13 = 15.38 (TRY ile karışmaz)', cUsd && Number(cUsd.cac) === 15.38, JSON.stringify(cUsd));
ok('durum ok', c.durum === 'ok', c.durum);

const cDar = (await tek(`select public.admin_growth_cac(1) as v`)).v;
ok('1 günlük pencere: yeni hane yok → gizli, CAC null, durum veri_az', cDar.yeni_hane === null && cDar.satirlar.length === 1 && cDar.satirlar[0].cac === null && cDar.satirlar[0].durum === 'veri_az', JSON.stringify(cDar));

await postgres();
await db.exec(`delete from public.growth_harcama;`);
const cYok = (await tek(`select public.admin_growth_cac(90) as v`)).v;
ok('harcama yoksa durum harcama_yok, satır listesi boş (uydurma CAC yok)', cYok.durum === 'harcama_yok' && cYok.satirlar.length === 0, JSON.stringify(cYok));

console.log('\n== Yetki ==');
await db.exec(`set request.jwt.claims = '{"sub":"${YETKISIZ}"}';`);
await hataBekle('admin olmayan (veli) kohort okuyamaz', () => tek(`select public.admin_growth_kohort(90)`), 'Yetkisiz');
await hataBekle('admin olmayan (veli) CAC okuyamaz', () => tek(`select public.admin_growth_cac(90)`), 'Yetkisiz');
await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);
await rolle('anon');
await hataBekle('anon kohort çalıştıramaz', () => tek(`select public.admin_growth_kohort(90)`), 'permission denied');
await hataBekle('anon CAC çalıştıramaz', () => tek(`select public.admin_growth_cac(90)`), 'permission denied');
await hataBekle('anon gizlilik yardımcısını çalıştıramaz', () => tek(`select public._growth_kayitli_hane('registered')`), 'permission denied');
await postgres();

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
