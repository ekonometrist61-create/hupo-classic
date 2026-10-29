// P1 paket/modül erişim: gerçek migration (20261130000000) PGlite üzerinde.
// Zincir: yaşam stub (profiles, plans, subscriptions, auth.uid, require_admin) → bu testin stub'ları → migration.
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const require = createRequire(import.meta.url);
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite', {
  paths: [HERE, path.resolve(HERE, '../ab_deney'), path.resolve(HERE, '../kartsiz_deneme')],
})).href);

const MIG = path.resolve(HERE, '../../migrations/20261130000000_paket_modul_erisim.sql');
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
const istemci = (uid) => db.exec(`set request.jwt.claims = '{"sub":"${uid}"}';`);
const servis = () => db.exec(`set request.jwt.claims = '';`);
const erisim = async (uid, modul) =>
  (await tek('select public.has_access($1::uuid, $2) as a', [uid, modul])).a;

const VELI = '00000000-0000-4000-8000-000000000002';
const COCUK = '00000000-0000-4000-8000-000000000003';
const VELI2 = '00000000-0000-4000-8000-000000000004';
const YONETICI = '00000000-0000-4000-8000-000000000005';
const VELI3 = '00000000-0000-4000-8000-000000000006';
const VELI4 = '00000000-0000-4000-8000-000000000007';
const VELI5 = '00000000-0000-4000-8000-000000000008';

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`
  create table public.test_deneme (uid uuid primary key);
  create or replace function public._deneme_aktif(p_uid uuid) returns boolean
  language sql stable as $$ select exists (select 1 from public.test_deneme where uid = p_uid) $$;
  create or replace function public.log_admin_action(p_islem text, p_detay jsonb default '{}'::jsonb)
  returns void language plpgsql as $$ begin end $$;
`);
for (const [id, mail] of [[VELI, 'v1'], [COCUK, 'c1'], [VELI2, 'v2'], [YONETICI, 'y'], [VELI3, 'v3'], [VELI4, 'v4'], [VELI5, 'v5']]) {
  await db.query('insert into auth.users (id, email) values ($1, $2)', [id, `${mail}@x.test`]);
}
await db.exec(`
  insert into public.profiles (id, role) values
    ('${VELI}', 'veli'), ('${VELI2}', 'veli'), ('${YONETICI}', 'admin'),
    ('${VELI3}', 'veli'), ('${VELI4}', 'veli'), ('${VELI5}', 'veli');
  insert into public.profiles (id, role, parent_id) values ('${COCUK}', 'ogrenci', '${VELI}');
`);
await db.exec(fs.readFileSync(MIG, 'utf8'));
// Satış kalemleri: fiyat ve eşleme test içinde (migration fiyat eklemez)
await db.exec(`
  insert into public.plans (kod, ad, fiyat_kurus, sure_gun, tip_kod, paket_kod) values
    ('t_tam',  'T Tam',  100, 365, 'premium', 'tam'),
    ('t_read', 'T Read', 100, 365, 'premium', 'hupo_read'),
    ('t_eski', 'T Eski', 100, 365, 'premium', null);
`);

console.log('\n== 1. Tohum ==');
const sayim = await tek(`select
  (select count(*) from public.moduller where durum = 'yayinda')::int as modul,
  (select count(*) from public.paketler where durum = 'yayinda' and surum = 1)::int as paket,
  (select count(*) from public.paket_surum)::int as surum,
  (select count(*) from public.plans where paket_kod is not null and kod not like 't\\_%')::int as sahte_plan`);
ok('5 modül yayında', sayim.modul === 5, JSON.stringify(sayim));
ok('7 paket yayında, sürüm 1', sayim.paket === 7);
ok('7 sürüm anlık görüntüsü', sayim.surum === 7);
ok('migration fiyat/plan satırı eklemedi', sayim.sahte_plan === 0);

console.log('\n== 2. Ücretsiz taban ==');
let a = await erisim(VELI2, 'soru_cevap');
ok('aboneliksiz veli: soru-cevap sınırlı, kota 20', a.erisim === 'sinirli' && a.gunluk_kota === 20 && a.kaynak === 'ucretsiz', JSON.stringify(a));
a = await erisim(VELI2, 'okuma');
ok('aboneliksiz veli: okuma önizleme', a.erisim === 'onizleme', JSON.stringify(a));

console.log('\n== 3. Tam abonelik ve çocuğa miras ==');
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
  values ('${VELI}', 't_tam', 'aktif', now() + interval '30 days')`);
const damga = await tek(`select paket_surum from public.subscriptions where veli_id = '${VELI}'`);
ok('abonelik satın alma anındaki sürümü damgaladı (1)', damga.paket_surum === 1, JSON.stringify(damga));
a = await erisim(VELI, 'kelime_evreni');
ok('veli: tam abonelik → kelime evreni tam', a.erisim === 'tam' && a.kaynak === 'abonelik' && a.paket_kod === 'tam', JSON.stringify(a));
a = await erisim(COCUK, 'carpma');
ok('çocuk velisinin paketini miras alır', a.erisim === 'tam', JSON.stringify(a));

console.log('\n== 4. Modül paketi + ücretsiz taban alt sınırı ==');
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
  values ('${VELI3}', 't_read', 'aktif', now() + interval '30 days')`);
a = await erisim(VELI3, 'okuma');
ok('HupoRead: okuma tam', a.erisim === 'tam' && a.paket_kod === 'hupo_read', JSON.stringify(a));
a = await erisim(VELI3, 'carpma');
ok('HupoRead: çarpma yalnız ücretsiz taban (önizleme)', a.erisim === 'onizleme' && a.kaynak === 'ucretsiz', JSON.stringify(a));
a = await erisim(VELI3, 'soru_cevap');
ok('HupoRead: soru-cevap ücretsiz taban kotası (sınırlı 20)', a.erisim === 'sinirli' && a.gunluk_kota === 20, JSON.stringify(a));

console.log('\n== 5. Eski plan (paket eşlemesi yok) = bugünkü premium ==');
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
  values ('${VELI4}', 't_eski', 'aktif', now() + interval '30 days')`);
a = await erisim(VELI4, 'deneme');
ok('eski plan: tüm yayındaki modüllere tam', a.erisim === 'tam' && a.kaynak === 'eski_plan', JSON.stringify(a));

console.log('\n== 6. Süresi dolmuş abonelik ==');
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
  values ('${VELI5}', 't_tam', 'aktif', now() - interval '1 day')`);
a = await erisim(VELI5, 'okuma');
ok('süresi dolan abonelik ücretsiz tabana düşer', a.erisim === 'onizleme' && a.kaynak === 'ucretsiz', JSON.stringify(a));

console.log('\n== 7. Deneme ==');
await db.exec(`insert into public.test_deneme (uid) values ('${VELI2}')`);
a = await erisim(VELI2, 'okuma');
ok('deneme aktif: okuma tam (deneme paketi)', a.erisim === 'tam' && a.kaynak === 'deneme', JSON.stringify(a));
await db.exec(`delete from public.test_deneme`);

console.log('\n== 8. Taslak modül, bilinmeyen modül, yönetici ==');
await db.exec(`insert into public.moduller (kod, ad) values ('yeni_modul', 'Yeni Modül')`);
a = await erisim(VELI, 'yeni_modul');
ok('taslak modül: tam aboneye bile kapalı', a.erisim === 'yok', JSON.stringify(a));
a = await erisim(VELI, 'olmayan');
ok('bilinmeyen modül kapalı', a.erisim === 'yok', JSON.stringify(a));
a = await erisim(YONETICI, 'yeni_modul');
ok('yönetici taslak modülü de görür (tam)', a.erisim === 'tam' && a.kaynak === 'admin', JSON.stringify(a));

console.log('\n== 9. Kazanılmış hak: yeni modül sonradan yayınlanır ==');
// Yeni modül yayına alınır ve Tam paketine eklenir → sürüm 2. Eski abonelik sürüm 1'de kalır.
await db.exec(`
  update public.moduller set durum = 'yayinda', yayin_tarihi = now() where kod = 'yeni_modul';
  insert into public.paket_modul (paket_kod, modul_kod, erisim) values ('tam', 'yeni_modul', 'tam');
`);
await istemci(YONETICI);
const yeniSurum = await tek(`select public.admin_paket_yayinla('tam') as s`);
await servis();
ok('Tam paketi sürüm 2 oldu', yeniSurum.s === 2, JSON.stringify(yeniSurum));
a = await erisim(VELI, 'yeni_modul');
ok('eski abone (sürüm 1) yeni modülü OTOMATİK almaz (fail-closed)', a.erisim === 'yok', JSON.stringify(a));
await db.exec(`insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
  values ('${VELI2}', 't_tam', 'aktif', now() + interval '30 days')`);
a = await erisim(VELI2, 'yeni_modul');
ok('yeni abone (sürüm 2) yeni modülü alır', a.erisim === 'tam', JSON.stringify(a));
const dmg2 = await tek(`select paket_surum from public.subscriptions where veli_id = '${VELI2}'`);
ok('yeni abonelik sürüm 2 damgalı', dmg2.paket_surum === 2, JSON.stringify(dmg2));

console.log('\n== 10. İstemci yetkileri ==');
const anonHata = await hataBul(async () => { servis(); await db.query('select public.my_access()'); });
ok('girişsiz my_access reddedilir (42501)', anonHata?.kod === '42501', JSON.stringify(anonHata));
await istemci(VELI);
const benim = await tek('select public.my_access() as m');
ok('my_access yayındaki modülleri döndürür (6)', Object.keys(benim.m).length === 6, JSON.stringify(Object.keys(benim.m)));
ok('my_access: kelime evreni tam', benim.m.kelime_evreni.erisim === 'tam');

await db.exec('set role authenticated');
const tabloHata = await hataBul(() => db.query('select * from public.paket_modul'));
ok('authenticated paket_modul tablosunu doğrudan okuyamaz', tabloHata !== null, JSON.stringify(tabloHata));
const rpcHata = await hataBul(() => db.query('select public.has_access($1::uuid, $2)', [VELI, 'okuma']));
ok('authenticated iç has_access fonksiyonunu çağıramaz', rpcHata !== null, JSON.stringify(rpcHata));
const yayinHata = await hataBul(() => db.query(`select public.admin_paket_yayinla('tam')`));
ok('yönetici olmayan admin_paket_yayinla yapamaz (42501)', yayinHata?.kod === '42501', JSON.stringify(yayinHata));
await db.exec('reset role');

console.log(`\nSonuç: ${pass} geçti, ${fail} kaldı`);
process.exit(fail === 0 ? 0 : 1);
