// Mobil kota gösterimi: 20261130 → 20261134 → 20261135 gerçek migration'ları (PGlite).
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
  path.resolve(HERE, '../../migrations/20261134000000_ucretsiz_deneme_fircasi.sql'),
  path.resolve(HERE, '../../migrations/20261135000000_kota_durumu.sql'),
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
const istemci = (uid) => db.exec(`set request.jwt.claims = '{"sub":"${uid}"}';`);
const servis = () => db.exec(`set request.jwt.claims = '';`);
const kota = async (uid) => (await tek('select public.my_kota_durumu() as k')).k;

const V_FREE = '00000000-0000-4000-8000-0000000000c1';
const V_TAM = '00000000-0000-4000-8000-0000000000c2';
const V_DENEME = '00000000-0000-4000-8000-0000000000c3';
const C_FREE = '00000000-0000-4000-8000-0000000000d1';
const C_TAM = '00000000-0000-4000-8000-0000000000d2';
const C_DENEME = '00000000-0000-4000-8000-0000000000d3';

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`
  create table public.deneme_donemleri (
    id uuid primary key default gen_random_uuid(),
    veli_id uuid not null, baslangic timestamptz not null, bitis timestamptz not null);
  create table public.answer_events (
    id uuid primary key default gen_random_uuid(), student_id uuid not null,
    created_at timestamptz not null default now());
  create table public.kelime_denemeleri (
    id uuid primary key default gen_random_uuid(), ogrenci_id uuid not null,
    created_at timestamptz not null default now());
  create table public.carpim_deneme_log (
    id uuid primary key default gen_random_uuid(), user_id uuid not null,
    created_at timestamptz not null default now());
  create table public.okuma_oturumlari (
    id uuid primary key default gen_random_uuid(), ogrenci_id uuid not null,
    baslangic_at timestamptz not null default now());
  create table public.deneme_sinavi_katilimlari (
    id uuid primary key default gen_random_uuid(), student_id uuid not null,
    kayit_zamani timestamptz not null default now());
  -- Yaşam stub'ları (20261125 ile aynı imza)
  create or replace function public.is_premium(p_uid uuid) returns boolean
  language sql stable as $$ select false $$;
  create or replace function public._deneme_sahibi(p_uid uuid) returns uuid
  language sql stable as $$
    select coalesce((select parent_id from public.profiles where id = p_uid and role = 'ogrenci'), p_uid)
  $$;
  create or replace function public._deneme_aktif(p_uid uuid) returns boolean
  language sql stable as $$
    select exists (select 1 from public.deneme_donemleri d
                    where d.veli_id = public._deneme_sahibi(p_uid) and d.bitis > now())
  $$;
  create or replace function public._deneme_sinir(p_ogrenci uuid, p_ozellik text) returns jsonb
  language sql stable as $$
    select case when p_ozellik = 'kelime_evreni' then '{"sinir":2,"pencere":"gunluk"}'::jsonb else null end
  $$;
`);
for (const [id, mail] of [[V_FREE, 'f'], [V_TAM, 't'], [V_DENEME, 'd'], [C_FREE, 'cf'], [C_TAM, 'ct'], [C_DENEME, 'cd']]) {
  await db.query('insert into auth.users (id, email) values ($1, $2)', [id, `${mail}@x.test`]);
}
await db.exec(`
  insert into public.profiles (id, role) values ('${V_FREE}', 'veli'), ('${V_TAM}', 'veli'), ('${V_DENEME}', 'veli');
  insert into public.profiles (id, role, parent_id) values
    ('${C_FREE}', 'ogrenci', '${V_FREE}'), ('${C_TAM}', 'ogrenci', '${V_TAM}'), ('${C_DENEME}', 'ogrenci', '${V_DENEME}');
`);
for (const f of MIGS) await db.exec(fs.readFileSync(f, 'utf8'));
await db.exec(`
  insert into public.plans (kod, ad, fiyat_kurus, sure_gun, tip_kod, paket_kod) values
    ('t_tam', 'T Tam', 100, 365, 'premium', 'tam');
  insert into public.subscriptions (veli_id, plan_kod, durum, bitis) values
    ('${V_TAM}', 't_tam', 'aktif', now() + interval '30 days');
  insert into public.deneme_donemleri (veli_id, baslangic, bitis) values
    ('${V_DENEME}', now() - interval '1 day', now() + interval '10 days');
`);

console.log('\n== 1. Ücretsiz çocuk: tüm sınırlı modüller, kullanım 0 ==');
await istemci(C_FREE);
let k = await kota(C_FREE);
await servis();
ok('soru 20, kelime 30, çarpma 40, okuma 2, deneme 1 döner',
  k.soru_cevap?.gunluk_kota === 20 && k.kelime_evreni?.gunluk_kota === 30 &&
  k.carpma?.gunluk_kota === 40 && k.okuma?.gunluk_kota === 2 && k.deneme?.gunluk_kota === 1, JSON.stringify(k));
ok('kullanım başta 0, kalan = kota', k.kelime_evreni.kullanilan === 0 && k.kelime_evreni.kalan === 30, JSON.stringify(k.kelime_evreni));

console.log('\n== 2. Kullanım sayılır: 3 kelime → kalan 27 ==');
await db.exec(`insert into public.kelime_denemeleri (ogrenci_id) values ('${C_FREE}'), ('${C_FREE}'), ('${C_FREE}')`);
await istemci(C_FREE);
k = await kota(C_FREE);
await servis();
ok('kelime kullanılan 3, kalan 27', k.kelime_evreni.kullanilan === 3 && k.kelime_evreni.kalan === 27, JSON.stringify(k.kelime_evreni));
ok('diğer modüller etkilenmez (okuma kalan 2)', k.okuma.kalan === 2, JSON.stringify(k.okuma));

console.log('\n== 3. Dünkü kayıt sayılmaz ==');
await db.exec(`insert into public.okuma_oturumlari (ogrenci_id, baslangic_at) values ('${C_FREE}', now() - interval '2 days')`);
await istemci(C_FREE);
k = await kota(C_FREE);
await servis();
ok('2 gün önceki okuma kullanımda sayılmaz', k.okuma.kullanilan === 0 && k.okuma.kalan === 2, JSON.stringify(k.okuma));

console.log('\n== 4. Tam abonelik: gösterilecek kota yok ==');
await istemci(C_TAM);
k = await kota(C_TAM);
await servis();
ok('tam abone için harita boş (sınırsız, kota gösterilmez)', Object.keys(k).length === 0, JSON.stringify(k));

console.log('\n== 5. Deneme penceresi: legacy kelime 2/gün ==');
await db.exec(`insert into public.kelime_denemeleri (ogrenci_id) values ('${C_DENEME}')`);
await istemci(C_DENEME);
k = await kota(C_DENEME);
await servis();
ok('deneme penceresinde kelime sınırı legacy (2) ve kalan 1',
  k.kelime_evreni?.gunluk_kota === 2 && k.kelime_evreni.kalan === 1, JSON.stringify(k.kelime_evreni));

console.log('\n== 6. Girişsiz çağrı ==');
const h = await hataBul(() => db.query('select public.my_kota_durumu()'));
ok('girişsiz reddedilir (42501)', h?.kod === '42501', JSON.stringify(h));

console.log(`\nSonuç: ${pass} geçti, ${fail} kaldı`);
process.exit(fail === 0 ? 0 : 1);
