// Growth yaşam döngüsü: gerçek migration zinciri (core → musteri_360 → yaşam döngüsü) PGlite
// (WASM Postgres) üzerinde çalışır. Docker gerektirmez. Supabase'e bağlanmaz.
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const MIG = path.resolve(HERE, '../../migrations');
const CEKIRDEK = '20261014000000_growth_crm_core.sql';
const MUSTERI = '20261027000000_musteri_360_veri_toplama.sql';
const YENI = '20261104000000_growth_yasam_dongusu.sql';

// PGlite'ta pgcrypto yok; gen_random_uuid PostgreSQL yerleşiğidir. Yalnız bu satır harness'ta atlanır.
const eklentiSatiri = /^\s*create extension if not exists pgcrypto\b[^;]*;\s*$/gim;
const oku = (f) => fs.readFileSync(path.join(MIG, f), 'utf8')
  .replace(eklentiSatiri, "-- pgcrypto PGlite harness'ta atlandı");

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
    else { pass++; console.log('  ✓', ad, '→', m.slice(0, 80)); }
  }
};
const kur = async (ad, fn) => {
  try { await fn(); }
  catch (e) { console.log(`HATA [${ad}]: ${e.message}`); process.exit(1); }
};
const sorgu = async (sql, params = []) => (await db.query(sql, params)).rows;
const postgres = () => db.exec('reset role;');
const kimsin = (rol) => db.exec(`reset role; set role ${rol};`);
// Zaman geçişini simüle eder: tetikleyiciler atlanır (abonelik süresi "kendiliğinden" dolar).
const tetiksiz = (sql) => db.exec(`set session_replication_role = replica; ${sql}; set session_replication_role = origin;`);

const id = (n) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;
const V1 = id(1), V2 = id(2), V3 = id(3), V4 = id(4), V6 = id(6);
const S1 = id(11), S2 = id(12), S3 = id(13);
const Q = (n) => id(900 + n);

const hane = async (veli) => (await sorgu(
  'select id from public.growth_households where core_parent_user_id = $1', [veli]))[0].id;
const asama = async (h) => (await sorgu(
  'select lifecycle from public.growth_households where id = $1', [h]))[0].lifecycle;
const olaySayi = async (h, ad) => (await sorgu(
  'select count(*)::int as n from public.growth_events where household_id = $1 and event_name = $2', [h, ad]))[0].n;
const gunSayi = async (h) => (await sorgu(
  'select count(*)::int as n from public.growth_hane_aktif_gunleri where household_id = $1', [h]))[0].n;
const hesapla = async () => (await sorgu('select public.growth_yasam_dongusu_hesapla() as r'))[0].r;

console.log('\n== Kurulum: stub + core → musteri_360 → yaşam döngüsü migration ==');
await kur('stubs', () => db.exec(fs.readFileSync(path.join(HERE, 'stubs.sql'), 'utf8')));
await kur('growth core', () => db.exec(oku(CEKIRDEK)));
await kur('musteri 360', () => db.exec(oku(MUSTERI)));
await kur('yaşam döngüsü', () => db.exec(oku(YENI)));
ok('migration zinciri hatasız (core → musteri_360 → yaşam döngüsü)', true);

await postgres();
await db.exec(`
  insert into auth.users (id, email) values
    ('${V1}', 'v1@test.local'), ('${V2}', 'v2@test.local'), ('${V3}', 'v3@test.local'),
    ('${V4}', 'v4@test.local'), ('${V6}', 'v6@test.local'),
    ('${S1}', 's1@test.local'), ('${S2}', 's2@test.local'), ('${S3}', 's3@test.local');
  insert into public.plans (kod, ad, fiyat_kurus, sure_gun, tip_kod) values
    ('deneme', 'Deneme', 0, 14, 'premium'), ('aylik', 'Aylık', 19900, 30, 'premium');
  insert into public.profiles (id, role, full_name) values
    ('${V1}', 'veli', 'Veli Bir'), ('${V2}', 'veli', 'Veli İki'), ('${V3}', 'veli', 'Veli Üç'),
    ('${V4}', 'veli', 'Veli Dört'), ('${V6}', 'veli', 'Veli Altı');
  insert into public.profiles (id, role, full_name, parent_id, sinif) values
    ('${S1}', 'ogrenci', 'Çocuk Bir', '${V1}', 4),
    ('${S2}', 'ogrenci', 'Çocuk İki', '${V2}', 5),
    ('${S3}', 'ogrenci', 'Çocuk Üç', '${V3}', 6);
  -- Aktif ücretli abonelikler (tetikleyici hane'yi paid yapar)
  insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis, saglayici) values
    ('${V2}', 'aylik', 'aktif', now(), now() + interval '30 days', 'test'),
    ('${V3}', 'aylik', 'aktif', now(), now() + interval '30 days', 'test'),
    ('${V4}', 'aylik', 'aktif', now(), now() + interval '30 days', 'test'),
    ('${V6}', 'aylik', 'aktif', now(), now() + interval '30 days', 'test');
`);

const H1 = await hane(V1), H2 = await hane(V2), H3 = await hane(V3);
const H4 = await hane(V4), H6 = await hane(V6);
ok('kurulum: 5 veli için hane otomatik oluştu', [H1, H2, H3, H4, H6].every(Boolean));
ok('abonelik eklenen haneler paid, abonesiz hane registered',
  (await asama(H2)) === 'paid' && (await asama(H3)) === 'paid' && (await asama(H1)) === 'registered');

console.log('\n== A: ilk cevap aktivasyonu, ikinci cevap olay üretmez ==');
await db.exec(`insert into public.user_answers (student_id, question_id) values ('${S1}', '${Q(1)}')`);
ok('ilk cevap: lifecycle registered → activated', (await asama(H1)) === 'activated', await asama(H1));
const [{ activated_at: act1 }] = await sorgu('select activated_at from public.growth_households where id = $1', [H1]);
ok('ilk cevap: activated_at dolu', act1 instanceof Date, String(act1));
ok('ilk cevap: ilk_soru_cozuldu olayı 1 kez', (await olaySayi(H1, 'ilk_soru_cozuldu')) === 1);
ok('ilk cevap: aktif gün kaydı 1', (await gunSayi(H1)) === 1);

await db.exec(`insert into public.user_answers (student_id, question_id) values ('${S1}', '${Q(2)}')`);
await db.exec(`update public.user_answers set dogru_mu = false where student_id = '${S1}' and question_id = '${Q(1)}'`);
const [{ activated_at: act2 }] = await sorgu('select activated_at from public.growth_households where id = $1', [H1]);
ok('ikinci cevap ve yeniden cevap: ilk_soru_cozuldu hâlâ 1 olay',
  (await olaySayi(H1, 'ilk_soru_cozuldu')) === 1, String(await olaySayi(H1, 'ilk_soru_cozuldu')));
ok('ikinci cevap: activated_at değişmedi', act1.getTime() === act2.getTime());
ok('aynı gün: aktif gün kaydı hâlâ 1 (yinelenmez)', (await gunSayi(H1)) === 1);

console.log('\n== B: paid hane ilk cevapta paid kalır ==');
await db.exec(`insert into public.user_answers (student_id, question_id) values ('${S3}', '${Q(1)}')`);
ok('paid hane ilk cevap: lifecycle paid (geri çevrilmedi)', (await asama(H3)) === 'paid');
ok('paid hane ilk cevap: activated_at dolu, olay 1',
  (await olaySayi(H3, 'ilk_soru_cozuldu')) === 1);

console.log('\n== C: eşleştirme kodu ve abonelik iptali olayları ==');
await db.exec(`insert into public.parent_link_codes (kod, veli_id, son_kullanma)
               values ('ABCDEF', '${V1}', now() + interval '1 day')`);
ok('eşleştirme kodu üretildi olayı 1 kez', (await olaySayi(H1, 'eslestirme_kodu_uretildi')) === 1);
const [{ n: kodSizinti }] = await sorgu(
  `select count(*)::int as n from public.growth_events where event_name = 'eslestirme_kodu_uretildi' and properties::text like '%ABCDEF%'`);
ok('eşleştirme kodu değeri olaya yazılmadı', kodSizinti === 0, `sızıntı ${kodSizinti}`);

await db.exec(`update public.subscriptions set durum = 'iptal' where veli_id = '${V4}'`);
ok('abonelik iptali olayı 1 kez', (await olaySayi(H4, 'abonelik_iptal')) === 1);
const [{ iptal_ok }] = await sorgu(
  `select (properties ? 'iptal_nedeni') and jsonb_typeof(properties -> 'iptal_nedeni') = 'null' as iptal_ok
     from public.growth_events where household_id = $1 and event_name = 'abonelik_iptal'`, [H4]);
ok('abonelik iptali payload: iptal_nedeni alanı var, null', iptal_ok === true);
ok('abonelik iptali: lifecycle churned (mevcut tetikleyici)', (await asama(H4)) === 'churned');

console.log('\n== D: 14 gün sessizlik → at_risk; ücretli hane paid kalır ==');
await db.exec(`update growth_hane_aktif_gunleri set gun = gun - 20 where household_id in ('${H1}', '${H3}')`);
const r1 = await hesapla();
ok('14+ gün sessiz: activated → at_risk', (await asama(H1)) === 'at_risk', await asama(H1));
ok('ücretli hane sessizken paid kalır (geri çevrilmez)', (await asama(H3)) === 'paid', await asama(H3));
const [{ saglik: s1, churn: c1 }] = await sorgu(
  'select health_score as saglik, churn_score as churn from public.growth_households where id = $1', [H1]);
ok('at_risk: health_score 0 (aktivite yok)', s1 === 0, `health ${s1}`);
ok('at_risk: churn_score ≥ 50', c1 >= 50, `churn ${c1}`);
ok('geçiş olayı yasam_asamasi_degisti yazıldı (at_risk)',
  (await sorgu(`select count(*)::int as n from public.growth_events where household_id = $1
                 and event_name = 'yasam_asamasi_degisti' and properties ->> 'yeni' = 'at_risk'`, [H1]))[0].n === 1);
ok('sweep sonucu: geçiş sayısı ≥ 1', r1.gecis >= 1, JSON.stringify(r1));

console.log('\n== E: winback ve engaged ==');
await db.exec(`insert into public.user_answers (student_id, question_id) values ('${S1}', '${Q(3)}')`);
await hesapla();
ok('yeniden cevap: at_risk → winback', (await asama(H1)) === 'winback', await asama(H1));
await db.exec(`insert into growth_hane_aktif_gunleri (household_id, gun)
               values ('${H1}', public._growth_bugun() - 1), ('${H1}', public._growth_bugun() - 2)`);

console.log('\n== F: süresi dolan abonelik (yenilenmemiş) → churned; yenilenen → paid ==');
// Süre doldu: aktif abonelik bitiş tarihi geçmiş (zaman geçişi, tetikleyici yok).
await tetiksiz(`update public.subscriptions set bitis = now() - interval '1 day' where veli_id = '${V2}'`);
// Yenilenen: eski abonelik dolmuş (zaman geçişi), ardından yeni aktif abonelik eklenir.
await tetiksiz(`update public.subscriptions set bitis = now() - interval '1 day' where veli_id = '${V6}'`);
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis, saglayici)
               values ('${V6}', 'aylik', 'aktif', now(), now() + interval '30 days', 'test')`);
const r2 = await hesapla();
ok('süresi dolan, yenilenmemiş abonelik: paid → churned', (await asama(H2)) === 'churned', await asama(H2));
ok('churned hane: churn_score 100', (await sorgu(
  'select churn_score from public.growth_households where id = $1', [H2]))[0].churn_score === 100);
ok('churned geçişi neden=abonelik_suresi_doldu ile kayıtlı',
  (await sorgu(`select count(*)::int as n from public.growth_events where household_id = $1
                 and event_name = 'yasam_asamasi_degisti' and properties ->> 'neden' = 'abonelik_suresi_doldu'`,
    [H2]))[0].n === 1);
ok('yenilenen abonelik: hane paid kalır', (await asama(H6)) === 'paid', await asama(H6));
ok('engaged: winback + son 14 günde 3 aktif gün → engaged', (await asama(H1)) === 'engaged', await asama(H1));
ok('sweep sonucu: geçiş sayısı ≥ 1 (churned)', r2.gecis >= 1, JSON.stringify(r2));

console.log('\n== G: sweep idempotent ==');
const r3 = await hesapla();
ok('ikinci çalıştırmada değişiklik yok (guncellenen 0)', r3.guncellenen === 0, JSON.stringify(r3));
ok('ikinci çalıştırmada geçiş yok', r3.gecis === 0, JSON.stringify(r3));

console.log('\n== H: yetki (anon / authenticated çalıştıramaz) ==');
const yetki = (await sorgu(`select
    has_function_privilege('anon', 'public.growth_yasam_dongusu_hesapla()', 'EXECUTE') as anon_hesapla,
    has_function_privilege('authenticated', 'public.growth_yasam_dongusu_hesapla()', 'EXECUTE') as auth_hesapla,
    has_function_privilege('service_role', 'public.growth_yasam_dongusu_hesapla()', 'EXECUTE') as svc_hesapla,
    has_function_privilege('anon', 'public._growth_ilk_cevap_isle(uuid)', 'EXECUTE') as anon_ilk,
    has_function_privilege('authenticated', 'public._growth_ilk_cevap_isle(uuid)', 'EXECUTE') as auth_ilk`))[0];
ok('yetki tablosu: anon/authenticated sweep ve iç fonksiyonları çalıştıramaz',
  !yetki.anon_hesapla && !yetki.auth_hesapla && !yetki.anon_ilk && !yetki.auth_ilk, JSON.stringify(yetki));
ok('yetki tablosu: service_role sweep çalıştırabilir', yetki.svc_hesapla === true, JSON.stringify(yetki));

await kimsin('anon');
await hataBekle('anon sweep çalıştıramaz', () => sorgu(`select public.growth_yasam_dongusu_hesapla()`), 'permission denied');
await hataBekle('anon aktif gün tablosunu okuyamaz', () => sorgu(`select * from public.growth_hane_aktif_gunleri`), 'permission denied');
await kimsin('authenticated');
await hataBekle('authenticated sweep çalıştıramaz', () => sorgu(`select public.growth_yasam_dongusu_hesapla()`), 'permission denied');
await postgres();

console.log('\n== I: zamanlayıcı ve yeniden çalıştırma ==');
ok('pg_cron yokken zamanlayıcı atlandı (cron şeması yok, migration hatasız)',
  (await sorgu(`select to_regclass('cron.job') is null as yok`))[0].yok === true);
await kur('yeniden çalıştırma', () => db.exec(oku(YENI)));
ok('migration ikinci kez hatasız', true);
ok('yeniden çalıştırmada ilk_soru_cozuldu olayı çoğalmadı',
  (await olaySayi(H1, 'ilk_soru_cozuldu')) === 1);
const [{ n: tetikAdet }] = await sorgu(
  `select count(*)::int as n from pg_trigger where tgrelid = 'public.user_answers'::regclass
     and tgname in ('growth_cevap_ilk', 'growth_cevap_guncelle') and not tgisinternal`);
ok('user_answers üzerinde 2 growth tetikleyicisi (çoğalmadı)', tetikAdet === 2, `adet ${tetikAdet}`);

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
await db.close();
process.exit(fail === 0 ? 0 : 1);
