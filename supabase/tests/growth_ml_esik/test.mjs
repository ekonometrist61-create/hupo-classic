// ML eşik sayımı: gerçek migration PGlite üzerinde çalışır. Docker yok; uzak DB'ye dokunmaz.
// Zincir: yaşam stub (profiles, require_admin) → payments/subscriptions şema taklidi → 20261119.
// payments/subscriptions tabloları yalnız bu testte, gerçek 20260920000900 tanımındaki kolonlarla kurulur.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const STUBS = path.resolve(HERE, '../growth_yasam_dongusu/stubs.sql');
const YENI = '20261119000000_growth_ml_esik.sql';

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
const tek = async (sql) => (await db.query(sql)).rows[0];
const modeller = (v) => Object.fromEntries(v.modeller.map((m) => [m.model, m]));
const ADMIN = '00000000-0000-4000-8000-000000000001';
const VELI = '00000000-0000-4000-8000-000000000002';

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`
  drop table if exists public.payments cascade;
  drop table if exists public.subscriptions cascade;
  create table public.payments (
    id uuid primary key default gen_random_uuid(),
    veli_id uuid, subscription_id uuid,
    tutar_kurus integer not null default 0,
    para_birimi text not null default 'TRY',
    durum text not null check (durum in ('beklemede','basarili','basarisiz','iade')),
    saglayici text not null default 'manuel', saglayici_ref text, aciklama text,
    created_at timestamptz not null default now());
  create table public.subscriptions (
    id uuid primary key default gen_random_uuid(),
    veli_id uuid not null, plan_kod text not null default 'x',
    durum text not null check (durum in ('aktif','iptal','suresi_doldu','beklemede')),
    baslangic timestamptz not null default now(), bitis timestamptz not null default now(),
    created_at timestamptz not null default now());
`);
await db.exec(fs.readFileSync(path.join(MIG, YENI), 'utf8'));
ok('migration yüklendi', true);
await db.exec(`insert into auth.users (id, email) values ('${ADMIN}', 'a@t'), ('${VELI}', 'v@t');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin'), ('${VELI}', 'veli');`);

console.log('\n== Eşik altı (az veri) ==');
await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);
// 3 ücretli veli, ilk ödeme 3 ay önce
const v1 = await tek(`select public.admin_growth_ml_esik() as v`);
let m = modeller(v1.v);
ok('B: ücretli veli sayısı 0 (veri yok)', m.B.mevcut === 0 && m.B.durum === 'bekliyor', JSON.stringify(m.B));
ok('C: iptal ve döngü 0, bekliyor', m.C.mevcut_iptal === 0 && m.C.durum === 'bekliyor', JSON.stringify(m.C));
ok('D: gelir geçmişi yok → 0 ay, bekliyor', m.D.gelir_gecmisi_ay === 0 && m.D.durum === 'bekliyor', JSON.stringify(m.D));

await db.exec(`
  insert into public.payments (veli_id, durum, created_at) values
    ('00000000-0000-4000-9000-000000000001', 'basarili', now() - interval '90 days'),
    ('00000000-0000-4000-9000-000000000002', 'basarili', now() - interval '60 days'),
    ('00000000-0000-4000-9000-000000000003', 'basarili', now() - interval '30 days'),
    ('00000000-0000-4000-9000-000000000003', 'basarili', now() - interval '10 days'),
    ('00000000-0000-4000-9000-000000000004', 'basarisiz', now() - interval '5 days');
  insert into public.subscriptions (veli_id, durum) values
    ('00000000-0000-4000-9000-000000000001', 'iptal'),
    ('00000000-0000-4000-9000-000000000002', 'aktif'),
    ('00000000-0000-4000-9000-000000000002', 'iptal');
`);
const v2 = (await tek(`select public.admin_growth_ml_esik() as v`)).v;
m = modeller(v2);
ok('B: başarılı ödemesi olan 3 veli (tekil; başarısız ödeme sayılmaz)', m.B.mevcut === 3, JSON.stringify(m.B));
ok('C: iptal eden 2 veli, döngü (2+ abonelik) 1 veli', m.C.mevcut_iptal === 2 && m.C.yenileme_donemi === 1, JSON.stringify(m.C));
ok('D: ilk ödeme 90 gün önce → ~3.0 ay, bekliyor', Number(m.D.gelir_gecmisi_ay) > 2.9 && Number(m.D.gelir_gecmisi_ay) < 3.1 && m.D.durum === 'bekliyor', JSON.stringify(m.D));
ok('model B ve C eşikleri doğru ve hepsi bekliyor', m.B.esik === 500 && m.C.esik_iptal === 200 && m.B.durum === 'bekliyor' && m.C.durum === 'bekliyor');
ok('not: eşikler sezgisel olduğu belirtilir', /sezgisel/.test(v2.not));

console.log('\n== Eşik sağlanınca durum değişir (bağımsız doğrulama) ==');
await db.exec(`
  insert into public.payments (veli_id, durum, created_at)
    select gen_random_uuid(), 'basarili', now() - interval '200 days' from generate_series(1, 500);
  insert into public.subscriptions (veli_id, durum)
    select gen_random_uuid(), 'iptal' from generate_series(1, 200);
`);
const v3 = (await tek(`select public.admin_growth_ml_esik() as v`)).v;
m = modeller(v3);
ok('B: 500+ ücretli veli → esik_saglandi', m.B.durum === 'esik_saglandi', JSON.stringify(m.B));
ok('C: 200+ iptal ama döngü 1 → hâlâ bekliyor (iki koşul birlikte)', m.C.durum === 'bekliyor', JSON.stringify(m.C));
ok('D: ilk ödeme 200 gün önce → 6+ ay → esik_saglandi', m.D.durum === 'esik_saglandi', JSON.stringify(m.D));
ok('ML eğitimi yapılmaz: çıktıda model artefaktı veya skor yok',
  !/skor|weights|model_dosya|agirlik/i.test(JSON.stringify(v3)));

console.log('\n== Yetki ==');
await db.exec(`set request.jwt.claims = '{"sub":"${VELI}"}';`);
await hataBekle('veli eşik sayımını göremez', () => tek(`select public.admin_growth_ml_esik()`), 'Yetkisiz');
await db.exec(`reset role; set role anon;`);
await hataBekle('anon çağıramaz', () => tek(`select public.admin_growth_ml_esik()`), 'permission denied');
await db.exec('reset role;');

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
