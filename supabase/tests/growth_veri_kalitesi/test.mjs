// Growth veri kalitesi ve izin özeti: gerçek migration zinciri PGlite üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
// Zincir: stubs (growth_yasam_dongusu) → core → musteri_360 → web → analitik_huni → yasam_dongusu → veri_kalitesi.
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
  '20261115000000_growth_veri_kalitesi.sql',
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
const postgres = () => db.exec('reset role;');
const rolle = (rol) => db.exec(`reset role; set role ${rol};`);

const ADMIN = '00000000-0000-4000-8000-000000000001';
const YETKISIZ = '00000000-0000-4000-8000-000000000002';
const veliId = (n) => `00000000-0000-4000-7000-${String(n).padStart(12, '0')}`;

console.log('\n== Kurulum: stub + gerçek migration zinciri ==');
await kur('stubs', () => db.exec(fs.readFileSync(STUBS, 'utf8')));
for (const f of ZINCIR) await kur(f, () => db.exec(oku(f)));
ok('migration zinciri hatasız (core → … → veri_kalitesi)', true);

await postgres();
await db.exec(`
  insert into auth.users (id, email) values ('${ADMIN}', 'admin@test.local'), ('${YETKISIZ}', 'v@test.local');
  insert into public.profiles (id, role) values ('${ADMIN}', 'admin');
`);
await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);

console.log('\n== Veri ==');
// 7 veli profili (veli_toplam = 7). Tercihler:
//   eposta: 1-5 açık, 6 kapalı; (7 için kayıt yok)  → açık 5, kapalı 1, kayıt_yok 1
//   push  : 1-3 açık                                → açık 3 (gizli), kapalı 0, kayıt_yok 4
//   sms   : kayıt yok                               → açık 0, kapalı 0, kayıt_yok 7
//   uygulama_ici: 1-6 açık                          → açık 6, kapalı 0, kayıt_yok 1
for (let i = 1; i <= 7; i++) {
  await db.exec(`insert into auth.users (id, email) values ('${veliId(i)}', 'v${i}@test.local') on conflict do nothing;
                 insert into public.profiles (id, role) values ('${veliId(i)}', 'veli') on conflict do nothing;`);
}
const tercih = async (i, kanal, izin) => db.exec(`insert into public.iletisim_tercihleri (veli_id, kanal, izin)
  values ('${veliId(i)}', '${kanal}', ${izin});`);
for (let i = 1; i <= 5; i++) await tercih(i, 'eposta', true);
await tercih(6, 'eposta', false);
for (let i = 1; i <= 3; i++) await tercih(i, 'push', true);
for (let i = 1; i <= 6; i++) await tercih(i, 'uygulama_ici', true);

// Hane kalitesi: 6 hanede e-posta boş metin (email NOT NULL; boşluk/boş metin kontrol edilir).\n// 7 aktive hane: 2'sinde activated_at dolu, 5'inde boş (aktif_tarihsiz = 5, eşik üstü).
await db.exec(`
  insert into public.growth_households (id, parent_name, email, lifecycle) values
    ('00000000-0000-4000-9100-000000000001', 'A1', '', 'lead'),
    ('00000000-0000-4000-9100-000000000002', 'A2', ' ', 'lead'),
    ('00000000-0000-4000-9100-000000000003', 'A3', '  ', 'lead'),
    ('00000000-0000-4000-9100-000000000004', 'A4', '   ', 'lead'),
    ('00000000-0000-4000-9100-000000000005', 'A5', '    ', 'lead'),
    ('00000000-0000-4000-9100-000000000006', 'A6', '     ', 'lead');
  insert into public.growth_households (id, parent_name, email, lifecycle) values
    ('00000000-0000-4000-9200-000000000001', 'B1', 'b1@test.local', 'activated'),
    ('00000000-0000-4000-9200-000000000002', 'B2', 'b2@test.local', 'engaged'),
    ('00000000-0000-4000-9200-000000000003', 'B3', 'b3@test.local', 'paid'),
    ('00000000-0000-4000-9200-000000000004', 'B4', 'b4@test.local', 'at_risk'),
    ('00000000-0000-4000-9200-000000000005', 'B5', 'b5@test.local', 'winback'),
    ('00000000-0000-4000-9200-000000000006', 'B6', 'b6@test.local', 'activated'),
    ('00000000-0000-4000-9200-000000000007', 'B7', 'b7@test.local', 'paid');
  update public.growth_households set activated_at = now()
   where id in ('00000000-0000-4000-9200-000000000001', '00000000-0000-4000-9200-000000000002');
`);

console.log('\n== Sayılar (bağımsız SQL ile karşılaştırma) ==');
const sqlEposta = (await tek(`select count(*)::int n from public.growth_households where email is null or btrim(email) = ''`)).n;
const sqlTarihsiz = (await tek(`select count(*)::int n from public.growth_households
  where lifecycle in ('activated','engaged','paid','at_risk','winback') and activated_at is null`)).n;
ok('SQL: e-postası eksik hane en az 6', sqlEposta >= 6, String(sqlEposta));
ok('SQL: aktive tarihsiz hane tam 5', sqlTarihsiz === 5, String(sqlTarihsiz));

const v = (await tek(`select public.admin_growth_veri_kalitesi() as v`)).v;
const kal = Object.fromEntries(v.kalite.map((k) => [k.kod, k.sayi]));
ok('kalite eposta_eksik = SQL sayımı', kal.eposta_eksik === sqlEposta, JSON.stringify(v.kalite));
ok('kalite aktif_tarihsiz = SQL sayımı', kal.aktif_tarihsiz === sqlTarihsiz, JSON.stringify(v.kalite));
ok('veli_toplam = 7 (5 eşik üstü, görünür)', v.veli_toplam === 7, JSON.stringify(v.veli_toplam));

const izin = Object.fromEntries(v.izin.map((i) => [i.kanal, i]));
ok('eposta: açık 5 görünür, kapalı 1 gizli (eşik), kayıt_yok 1 gizli',
  izin.eposta.acik === 5 && izin.eposta.kapali === null && izin.eposta.kayit_yok === null, JSON.stringify(izin.eposta));
ok('push: açık 3 gizli (eşik), kayıt_yok 4 gizli',
  izin.push.acik === null && izin.push.kayit_yok === null, JSON.stringify(izin.push));
ok('sms: hiç kayıt yok → kayit_yok 7 görünür, açık/kapalı 0 gizli',
  izin.sms.kayit_yok === 7 && izin.sms.acik === null && izin.sms.kapali === null, JSON.stringify(izin.sms));
ok('uygulama_ici: açık 6 görünür, kayıt_yok 1 gizli',
  izin.uygulama_ici.acik === 6 && izin.uygulama_ici.kayit_yok === null, JSON.stringify(izin.uygulama_ici));
ok('kanal sırası sabit (eposta, push, sms, uygulama_ici)',
  v.izin.map((i) => i.kanal).join() === 'eposta,push,sms,uygulama_ici', v.izin.map((i) => i.kanal).join());

console.log('\n== Yetki ==');
await db.exec(`set request.jwt.claims = '{"sub":"${YETKISIZ}"}';`);
await hataBekle('admin olmayan veri kalitesini okuyamaz', () => tek(`select public.admin_growth_veri_kalitesi()`), 'Yetkisiz');
await db.exec(`set request.jwt.claims = '{"sub":"${ADMIN}"}';`);
await rolle('anon');
await hataBekle('anon çalıştıramaz', () => tek(`select public.admin_growth_veri_kalitesi()`), 'permission denied');
await postgres();

console.log(`\nSONUÇ: ${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
