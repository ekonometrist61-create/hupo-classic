// P7 orantılı mahsup: gerçek 20261133 migration'ı, yaşam stub'ları üzerinde (PGlite).
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const require = createRequire(import.meta.url);
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite', {
  paths: [HERE, path.resolve(HERE, '../ab_deney'), path.resolve(HERE, '../kartsiz_deneme')],
})).href);

const MIG = path.resolve(HERE, '../../migrations/20261133000000_paket_gecis_mahsup.sql');
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
const veli = (uid) => db.exec(`set request.jwt.claims = '{"sub":"${uid}"}';`);
const servis = () => db.exec(`set request.jwt.claims = '';`);

const V1 = '00000000-0000-4000-8000-000000000002';
const V2 = '00000000-0000-4000-8000-000000000004';
const V3 = '00000000-0000-4000-8000-000000000006';

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
for (const [id, mail] of [[V1, 'a'], [V2, 'b'], [V3, 'c']]) {
  await db.query('insert into auth.users (id, email) values ($1, $2)', [id, `${mail}@x.test`]);
}
await db.exec(fs.readFileSync(MIG, 'utf8'));
await db.exec(`
  insert into public.plans (kod, ad, fiyat_kurus, sure_gun, aktif, tip_kod) values
    ('eski_365', 'Eski 365', 36500, 365, true, 'premium'),
    ('yeni_365', 'Yeni 365', 79900, 365, true, 'premium'),
    ('kucuk_30', 'Küçük 30', 9000, 30, true, 'premium'),
    ('pasif',    'Pasif',    10000, 365, false, 'premium');
  insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
    values ('${V1}', 'eski_365', 'aktif', now() + interval '91 days');
  insert into public.subscriptions (veli_id, plan_kod, durum, bitis)
    values ('${V2}', 'eski_365', 'aktif', now() - interval '1 day');
`);

console.log('\n== 1. Aktif abonelik: orantılı mahsup ==');
await veli(V1);
let r = await tek(`select public.my_gecis_mahsubu('yeni_365') as m`);
const m = r.m;
ok('kaynak abonelik', m.kaynak === 'abonelik', JSON.stringify(m));
ok('kalan gün 91', m.kalan_gun === 91, JSON.stringify(m));
ok('mahsup = 36500 × 91 / 365 = 9100 kuruş', m.mahsup_kurus === 9100, JSON.stringify(m));
ok('ödenecek = 79900 − 9100 = 70800', m.odenecek_kurus === 70800, JSON.stringify(m));
ok('hedef tutarı plans tablosundan geldi', m.hedef_kurus === 79900);
await servis();

console.log('\n== 2. Mahsup hedefi aşarsa ödenecek 0, fazla iade yok ==');
await veli(V1);
r = await tek(`select public.my_gecis_mahsubu('kucuk_30') as m`);
// Kural: kalan değer MEVCUT planın süresine göre hesaplanır (365 gün): 36500 × 91 / 365 = 9100.
// 9100 > 9000 → hedef tamamen karşılanır, fazla 100 kuruş iade edilmez.
ok('mahsup (9100) hedef planı (9000) aşar → ödenecek 0, fazla iade yok',
  r.m.kalan_gun === 91 && r.m.mahsup_kurus === 9100 && r.m.odenecek_kurus === 0, JSON.stringify(r.m));
await servis();

console.log('\n== 3. Abonelik yok ==');
await veli(V3);
r = await tek(`select public.my_gecis_mahsubu('yeni_365') as m`);
ok('abonelik yoksa tam tutar ödenir', r.m.kaynak === 'yok' && r.m.odenecek_kurus === 79900 && r.m.mahsup_kurus === 0, JSON.stringify(r.m));
await servis();

console.log('\n== 4. Süresi dolmuş abonelik mahsup üretmez ==');
await veli(V2);
r = await tek(`select public.my_gecis_mahsubu('yeni_365') as m`);
ok('süresi dolmuş → kaynak yok', r.m.kaynak === 'yok' && r.m.mahsup_kurus === 0, JSON.stringify(r.m));
await servis();

console.log('\n== 5. Hatalar ==');
await veli(V1);
let h = await hataBul(() => db.query(`select public.my_gecis_mahsubu('pasif')`));
ok('pasif plan hedef olamaz (P0002)', h?.kod === 'P0002', JSON.stringify(h));
h = await hataBul(() => db.query(`select public.my_gecis_mahsubu('yok')`));
ok('bilinmeyen plan P0002', h?.kod === 'P0002', JSON.stringify(h));
await servis();
h = await hataBul(() => db.query(`select public.my_gecis_mahsubu('yeni_365')`));
ok('girişsiz çağrı reddedilir (42501)', h?.kod === '42501', JSON.stringify(h));

console.log(`\nSonuç: ${pass} geçti, ${fail} kaldı`);
process.exit(fail === 0 ? 0 : 1);
