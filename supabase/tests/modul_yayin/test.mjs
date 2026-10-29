// P2 yeni modül kuralı: 20261130 (P1) + 20261131 (P2) gerçek migration'ları PGlite üzerinde.
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const require = createRequire(import.meta.url);
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite', {
  paths: [HERE, path.resolve(HERE, '../ab_deney'), path.resolve(HERE, '../kartsiz_deneme')],
})).href);

const MIG_P1 = path.resolve(HERE, '../../migrations/20261130000000_paket_modul_erisim.sql');
const MIG_P2 = path.resolve(HERE, '../../migrations/20261131000000_modul_yayin_kurali.sql');
const STUBS = path.resolve(HERE, '../growth_yasam_dongusu/stubs.sql');

const db = new PGlite();
let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const tek = async (sql, p = []) => (await db.query(sql, p)).rows[0];
const hataBul = async (fn) => {
  try { await fn(); return null; }
  catch (e) { return { kod: e.code ?? '', mesaj: String(e.message ?? e) }; }
};
const yonetici = () => db.exec(`set request.jwt.claims = '{"sub":"${YONETICI}"}';`);
const servis = () => db.exec(`set request.jwt.claims = '';`);
const erisim = async (uid, modul) =>
  (await tek('select public.has_access($1::uuid, $2) as a', [uid, modul])).a;

const YONETICI = '00000000-0000-4000-8000-000000000005';
const VELI = '00000000-0000-4000-8000-000000000002';
const VELI2 = '00000000-0000-4000-8000-000000000004';
const VELI3 = '00000000-0000-4000-8000-000000000006';
const YENI_MODUL = 'yeni_modul';
const PAKETLER = ['ucretsiz', 'deneme', 'hupo_read', 'soru', 'tam', 'aile2', 'aile3'];

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`
  create table public.test_deneme (uid uuid primary key);
  create or replace function public._deneme_aktif(p_uid uuid) returns boolean
  language sql stable as $$ select exists (select 1 from public.test_deneme where uid = p_uid) $$;
  create or replace function public.log_admin_action(p_islem text, p_detay jsonb default '{}'::jsonb)
  returns void language plpgsql as $$ begin end $$;
`);
for (const [id, mail] of [[VELI, 'v1'], [VELI2, 'v2'], [YONETICI, 'y'], [VELI3, 'v3']]) {
  await db.query('insert into auth.users (id, email) values ($1, $2)', [id, `${mail}@x.test`]);
}
await db.exec(`
  insert into public.profiles (id, role) values
    ('${VELI}', 'veli'), ('${VELI2}', 'veli'), ('${YONETICI}', 'admin'), ('${VELI3}', 'veli');
`);
await db.exec(fs.readFileSync(MIG_P1, 'utf8'));
await db.exec(fs.readFileSync(MIG_P2, 'utf8'));
await db.exec(`
  insert into public.plans (kod, ad, fiyat_kurus, sure_gun, tip_kod, paket_kod) values
    ('t_tam', 'T Tam', 100, 365, 'premium', 'tam');
  insert into public.moduller (kod, ad) values ('${YENI_MODUL}', 'Yeni Modül');
`);
// Test: mevcut abone (sürüm 1 damgalı), yeni modül ön yayın öncesi
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
  values ('${VELI}', 't_tam', 'aktif', now() + interval '30 days')`);
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
  values ('${VELI3}', 't_tam', 'aktif', now() + interval '30 days')`);

console.log('\n== 1. Karar olmadan yayın reddedilir ==');
await yonetici();
let h = await hataBul(() => db.query(`select public.admin_modul_yayinla('${YENI_MODUL}')`));
ok('eksik karar → P0422', h?.kod === 'P0422', JSON.stringify(h));
ok('hata tüm eksik paketleri listeler', PAKETLER.every((p) => h?.mesaj.includes(p)), h?.mesaj);
let durum = await tek(`select durum from public.moduller where kod = '${YENI_MODUL}'`);
ok('reddedilen yayında modül taslak kaldı', durum.durum === 'taslak');
await servis();

console.log('\n== 2. Kısmi karar hâlâ reddedilir ==');
await yonetici();
await db.exec(`select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'tam', 'dahil')`);
h = await hataBul(() => db.query(`select public.admin_modul_yayinla('${YENI_MODUL}')`));
ok('6 paket eksikken hâlâ P0422', h?.kod === 'P0422' && !h?.mesaj.includes(' tam'), h?.mesaj);
await servis();

console.log('\n== 3. Tüm kararlar: dahil (Tam), sınırlı (Soru), hariç diğerleri, yeni_paket (Aile3) ==');
await yonetici();
await db.exec(`
  select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'ucretsiz', 'haric');
  select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'deneme', 'haric');
  select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'hupo_read', 'haric');
  select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'soru', 'sinirli', 10);
  select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'aile2', 'haric');
  select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'aile3', 'yeni_paket');
`);
const ilk = await tek(`select public.admin_modul_yayinla('${YENI_MODUL}') as r`);
ok('tüm kararlarla yayın başarılı', ilk.r.durum === 'yayinda', JSON.stringify(ilk));
durum = await tek(`select durum from public.moduller where kod = '${YENI_MODUL}'`);
ok('modül yayında', durum.durum === 'yayinda');
const mtrx = await tek(`select count(*)::int as n from public.paket_modul where modul_kod = '${YENI_MODUL}'`);
ok('matris: Tam ve Soru (sınırlı) var, Aile3 yeni_paket matriste yok (2 satır)', mtrx.n === 2, JSON.stringify(mtrx));
await servis();

console.log('\n== 4. Kazanılmış hak: mevcut abone (kapsamadı) yeni modülü almaz ==');
let a = await erisim(VELI, YENI_MODUL);
ok('mevcut Tam abone (kapsam=false) yeni modüle erişmez', a.erisim === 'yok', JSON.stringify(a));
a = await erisim(VELI3, YENI_MODUL);
ok('ikinci mevcut Tam abone de erişmez', a.erisim === 'yok', JSON.stringify(a));

console.log('\n== 5. Yeni abone (yeni sürüm) alır ==');
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
  values ('${VELI2}', 't_tam', 'aktif', now() + interval '30 days')`);
a = await erisim(VELI2, YENI_MODUL);
ok('yeni Tam abone yeni modüle tam erişir', a.erisim === 'tam' && a.paket_kod === 'tam', JSON.stringify(a));
a = await erisim(VELI2, 'soru_cevap');
ok('abonelik bağımsız: diğer modüller hâlâ çalışır', a.erisim === 'tam', JSON.stringify(a));

console.log('\n== 6. Karar değişikliği: modül yayınında kapsam=true, aboneler yeni sürüme taşınır ==');
await yonetici();
// Kapsam seçeneği açıkça verilerek yeni karar (yeni modül Tam'da zaten; sürüm yenilenmesi için değişiklik)
await db.exec(`select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'tam', 'dahil', null, true, 'mevcut aboneleri kapsa')`);
const yeniTamSurum = await tek(`select public.admin_modul_yayinla('${YENI_MODUL}') as r`);
ok('yeniden yayın etkilenen paketleri raporlar', (yeniTamSurum.r.etkilenen_paketler ?? []).some((x) => x.startsWith('tam@')), JSON.stringify(yeniTamSurum));
await servis();
const surumler = await tek(`select
  (select paket_surum from public.subscriptions where veli_id = '${VELI}') as eski,
  (select max(surum) from public.paket_surum where paket_kod = 'tam') as son`);
ok('kapsam=true: mevcut abone yeni sürüme geçti', surumler.eski === surumler.son, JSON.stringify(surumler));
a = await erisim(VELI, YENI_MODUL);
ok('kapsam=true sonrası mevcut abone yeni modüle erişir', a.erisim === 'tam', JSON.stringify(a));

console.log('\n== 7. Yetki ve doğrulama ==');
await servis();
h = await hataBul(() => db.query(`select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'tam', 'dahil')`));
ok('yönetici olmayan karar kaydedemez (42501)', h?.kod === '42501', JSON.stringify(h));
h = await hataBul(() => db.query(`select public.admin_modul_yayinla('${YENI_MODUL}')`));
ok('yönetici olmayan yayınlayamaz (42501)', h?.kod === '42501', JSON.stringify(h));
await yonetici();
h = await hataBul(() => db.query(`select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'tam', 'sinirli')`));
ok('sinirli karar kota ister (check)', h !== null, JSON.stringify(h));
h = await hataBul(() => db.query(`select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'olmayan_paket', 'haric')`));
ok('olmayan paket reddedilir (P0002)', h?.kod === 'P0002', JSON.stringify(h));
h = await hataBul(() => db.query(`select public.admin_modul_karar_kaydet('${YENI_MODUL}', 'tam', 'gecersiz')`));
ok('geçersiz karar değeri reddedilir', h !== null, JSON.stringify(h));
await servis();

console.log(`\nSonuç: ${pass} geçti, ${fail} kaldı`);
process.exit(fail === 0 ? 0 : 1);
