// P3 yönetim görünümü: 20261130 → 20261131 → 20261132 gerçek migration'ları PGlite üzerinde.
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const require = createRequire(import.meta.url);
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite', {
  paths: [HERE, path.resolve(HERE, '../ab_deney'), path.resolve(HERE, '../kartsiz_deneme')],
})).href);

const MIGS = [
  path.resolve(HERE, '../../migrations/20261130000000_paket_modul_erisim.sql'),
  path.resolve(HERE, '../../migrations/20261131000000_modul_yayin_kurali.sql'),
  path.resolve(HERE, '../../migrations/20261132000000_paket_admin_gorunum.sql'),
];
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
const veli = () => db.exec(`set request.jwt.claims = '{"sub":"${VELI}"}';`);
const servis = () => db.exec(`set request.jwt.claims = '';`);

const YONETICI = '00000000-0000-4000-8000-000000000005';
const VELI = '00000000-0000-4000-8000-000000000002';
const VELI2 = '00000000-0000-4000-8000-000000000004';
const YENI = 'yeni_modul';

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`
  create table public.test_deneme (uid uuid primary key);
  create or replace function public._deneme_aktif(p_uid uuid) returns boolean
  language sql stable as $$ select exists (select 1 from public.test_deneme where uid = p_uid) $$;
  create or replace function public.log_admin_action(p_islem text, p_detay jsonb default '{}'::jsonb)
  returns void language plpgsql as $$ begin end $$;
`);
for (const [id, mail] of [[VELI, 'v1'], [VELI2, 'v2'], [YONETICI, 'y']]) {
  await db.query('insert into auth.users (id, email) values ($1, $2)', [id, `${mail}@x.test`]);
}
await db.exec(`insert into public.profiles (id, role) values
  ('${VELI}', 'veli'), ('${VELI2}', 'veli'), ('${YONETICI}', 'admin')`);
for (const f of MIGS) await db.exec(fs.readFileSync(f, 'utf8'));
await db.exec(`
  insert into public.plans (kod, ad, fiyat_kurus, sure_gun, tip_kod, paket_kod)
    values ('t_tam', 'T Tam', 100, 365, 'premium', 'tam');
  insert into public.moduller (kod, ad) values ('${YENI}', 'Yeni Modül');
  insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
    values ('${VELI}', 't_tam', 'aktif', now() + interval '30 days');
  insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
    values ('${VELI2}', 't_tam', 'aktif', now() + interval '30 days');
`);

console.log('\n== 1. Matris görünümü ==');
await yonetici();
const mat = await tek('select public.admin_paket_matris() as m');
await servis();
ok('5 modül (taslak dahil) listelenir', mat.m.moduller.length === 6, JSON.stringify(mat.m.moduller.length));
ok('7 paket listelenir', mat.m.paketler.length === 7);
const tamPaket = mat.m.paketler.find((p) => p.kod === 'tam');
ok('Tam paketinde aktif abone sayısı 2', tamPaket.aktif_abone === 2, JSON.stringify(tamPaket));
ok('hücreler paket_modul satırlarını taşır', mat.m.hucreler.some((h) => h.paket === 'tam' && h.modul === 'okuma' && h.erisim === 'tam'));

console.log('\n== 2. Etki önizlemesi: karar eksikken ==');
await yonetici();
let on = await tek(`select public.admin_modul_etki_onizleme('${YENI}') as o`);
await servis();
ok('eksik karar → yayinlanabilir=false', on.o.yayinlanabilir === false, JSON.stringify(on.o.yayinlanabilir));
ok('eksik karar listesi 7 paketi içerir', on.o.eksik_kararlar.length === 7, JSON.stringify(on.o.eksik_kararlar));

console.log('\n== 3. Kararlar sonrası önizleme: kapsam seçilmediğinde 0 etkilenen ==');
await yonetici();
await db.exec(`
  select public.admin_modul_karar_kaydet('${YENI}', 'ucretsiz', 'haric');
  select public.admin_modul_karar_kaydet('${YENI}', 'deneme', 'haric');
  select public.admin_modul_karar_kaydet('${YENI}', 'hupo_read', 'haric');
  select public.admin_modul_karar_kaydet('${YENI}', 'soru', 'haric');
  select public.admin_modul_karar_kaydet('${YENI}', 'tam', 'dahil', null, false, 'yeni abonelere');
  select public.admin_modul_karar_kaydet('${YENI}', 'aile2', 'haric');
  select public.admin_modul_karar_kaydet('${YENI}', 'aile3', 'yeni_paket');
`);
on = await tek(`select public.admin_modul_etki_onizleme('${YENI}') as o`);
ok('tüm kararlar → yayinlanabilir=true', on.o.yayinlanabilir === true, JSON.stringify(on.o));
const tamOn = on.o.paketler.find((p) => p.paket === 'tam');
ok('Tam: karar dahil, kapsam=false → etkilenen 0 (aktif 2)', tamOn.karar === 'dahil' && tamOn.etkilenen_abone === 0 && tamOn.aktif_abone === 2, JSON.stringify(tamOn));
await servis();

console.log('\n== 4. Kapsam seçilince etkilenen abone sayısı görünür ==');
await yonetici();
await db.exec(`select public.admin_modul_karar_kaydet('${YENI}', 'tam', 'dahil', null, true, 'kapsa')`);
on = await tek(`select public.admin_modul_etki_onizleme('${YENI}') as o`);
const tamKapsa = on.o.paketler.find((p) => p.paket === 'tam');
ok('kapsam=true → etkilenen 2', tamKapsa.etkilenen_abone === 2, JSON.stringify(tamKapsa));
// Önizleme yazma yapmaz: yayın henüz yok, durum hâlâ taslak
ok('önizleme modülü yayınlamaz (taslak kalır)', on.o.modul_durum === 'taslak', JSON.stringify(on.o.modul_durum));
await servis();

console.log('\n== 5. Yetki ==');
await veli();
const h1 = await hataBul(() => db.query('select public.admin_paket_matris()'));
ok('veli matris göremez (42501)', h1?.kod === '42501', JSON.stringify(h1));
const h2 = await hataBul(() => db.query(`select public.admin_modul_etki_onizleme('${YENI}')`));
ok('veli etki önizlemesi göremez (42501)', h2?.kod === '42501', JSON.stringify(h2));
await servis();
const h3 = await hataBul(() => db.query('select public.admin_paket_matris()'));
ok('kimliksiz matris reddedilir', h3?.kod === '42501', JSON.stringify(h3));

console.log('\n== 6. Bilinmeyen modül ==');
await yonetici();
const h4 = await hataBul(() => db.query(`select public.admin_modul_etki_onizleme('yok')`));
ok('bilinmeyen modül P0002', h4?.kod === 'P0002', JSON.stringify(h4));
await servis();

console.log(`\nSonuç: ${pass} geçti, ${fail} kaldı`);
process.exit(fail === 0 ? 0 : 1);
