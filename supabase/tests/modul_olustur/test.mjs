// Modül oluştur / arşivle: 20261130 → 20261131 → 20261137 gerçek migration'ları (PGlite).
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
  path.resolve(HERE, '../../migrations/20261137000000_modul_olustur_arsivle.sql'),
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
const erisim = async (uid, modul) =>
  (await tek('select public.has_access($1::uuid, $2) as a', [uid, modul])).a;

const YONETICI = '00000000-0000-4000-8000-0000000000e1';
const VELI = '00000000-0000-4000-8000-0000000000e2';
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
for (const [id, mail] of [[YONETICI, 'y'], [VELI, 'v']]) {
  await db.query('insert into auth.users (id, email) values ($1, $2)', [id, `${mail}@x.test`]);
}
await db.exec(`insert into public.profiles (id, role) values ('${YONETICI}', 'admin'), ('${VELI}', 'veli')`);
for (const f of MIGS) await db.exec(fs.readFileSync(f, 'utf8'));

const surumler = async () => (await db.query('select kod, surum from public.paketler order by kod')).rows;
const oncekiSurumler = JSON.stringify(await surumler());

console.log('\n== 1. Oluştur: taslak olarak eklenir ==');
await yonetici();
const r = await tek(`select public.admin_modul_olustur('deneme_modul', 'Deneme Modülü', '  test açıklaması ') as r`);
await servis();
ok('durum taslak', r.r.durum === 'taslak' && r.r.kod === 'deneme_modul', JSON.stringify(r.r));
ok('sira mevcut en büyük + 1 (6)', r.r.sira === 6, JSON.stringify(r.r));
const satir = await tek(`select durum, aciklama from public.moduller where kod = 'deneme_modul'`);
ok('açıklama kırpıldı', satir.aciklama === 'test açıklaması', JSON.stringify(satir));

console.log('\n== 2. Taslak modül erişim vermez ==');
let a = await erisim(VELI, 'deneme_modul');
ok('veli: taslak modül kapalı', a.erisim === 'yok', JSON.stringify(a));

console.log('\n== 3. Doğrulama ve yetki ==');
await yonetici();
let h = await hataBul(() => db.query(`select public.admin_modul_olustur('deneme_modul', 'Tekrar')`));
ok('aynı kod → 23505', h?.kod === '23505', JSON.stringify(h));
h = await hataBul(() => db.query(`select public.admin_modul_olustur('Kötü Kod', 'Ad')`));
ok('geçersiz kod biçimi reddedilir (check)', h !== null, JSON.stringify(h));
h = await hataBul(() => db.query(`select public.admin_modul_olustur('baska', 'a')`));
ok('çok kısa ad reddedilir (check)', h !== null, JSON.stringify(h));
await servis();
await veli();
h = await hataBul(() => db.query(`select public.admin_modul_olustur('yetkisiz', 'Yetkisiz')`));
ok('yönetici olmayan oluşturamaz (42501)', h?.kod === '42501', JSON.stringify(h));
h = await hataBul(() => db.query(`select public.admin_modul_arsivle('deneme_modul')`));
ok('yönetici olmayan arşivleyemez (42501)', h?.kod === '42501', JSON.stringify(h));
await servis();

console.log('\n== 4. Yayın: karar olmadan reddedilir ==');
await yonetici();
h = await hataBul(() => db.query(`select public.admin_modul_yayinla('deneme_modul')`));
ok('kararsız yayın P0422', h?.kod === 'P0422', JSON.stringify(h));

console.log('\n== 5. Yayın: tüm paketler yeni_paket → yayınlanır, paket sürümleri değişmez ==');
for (const p of PAKETLER) {
  await db.query(`select public.admin_modul_karar_kaydet('deneme_modul', $1, 'yeni_paket')`, [p]);
}
const y = await tek(`select public.admin_modul_yayinla('deneme_modul') as r`);
await servis();
ok('yayınlandı', y.r.durum === 'yayinda', JSON.stringify(y.r));
ok('yeni_paket kararı paket sürümü üretmez', JSON.stringify(await surumler()) === oncekiSurumler, JSON.stringify(await surumler()));
a = await erisim(VELI, 'deneme_modul');
ok('yayında ama hiçbir pakete dahil değil → veli erişimi yok', a.erisim === 'yok', JSON.stringify(a));

console.log('\n== 6. Arşivle ==');
await yonetici();
const ars = await tek(`select public.admin_modul_arsivle('deneme_modul') as r`);
ok('arşivlendi', ars.r.durum === 'arsiv', JSON.stringify(ars.r));
const my = await tek('select public.my_access() as m');
await servis();
ok('arşivlenen modül my_access listesinde yok', !('deneme_modul' in my.m) || my.m.deneme_modul === undefined, JSON.stringify(Object.keys(my.m)));
await yonetici();
h = await hataBul(() => db.query(`select public.admin_modul_arsivle('olmayan')`));
ok('olmayan modül arşivlenemez (P0002)', h?.kod === 'P0002', JSON.stringify(h));
await servis();

console.log(`\nSonuç: ${pass} geçti, ${fail} kaldı`);
process.exit(fail === 0 ? 0 : 1);
