// Ücretsiz deneme fırsatı: 20261130 (P1) + 20261134 gerçek migration'ları, PGlite üzerinde.
// Sınır tetikleyicileri 20261125 ile aynı kalıpta, test için kurulur.
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
const MIG_F = path.resolve(HERE, '../../migrations/20261134000000_ucretsiz_deneme_fircasi.sql');
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

// Veliler
const V_FREE = '00000000-0000-4000-8000-0000000000a1';
const V_TAM = '00000000-0000-4000-8000-0000000000a2';
const V_SORU = '00000000-0000-4000-8000-0000000000a3';
const V_DENEME = '00000000-0000-4000-8000-0000000000a4';
// Çocuklar
const C_FREE = '00000000-0000-4000-8000-0000000000b1';
const C_TAM = '00000000-0000-4000-8000-0000000000b2';
const C_SORU = '00000000-0000-4000-8000-0000000000b3';
const C_DENEME = '00000000-0000-4000-8000-0000000000b4';

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`
  create table public.deneme_donemleri (
    id uuid primary key default gen_random_uuid(),
    veli_id uuid not null, baslangic timestamptz not null, bitis timestamptz not null);
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
    id uuid primary key default gen_random_uuid(), exam_id uuid, student_id uuid not null,
    veli_id uuid, kayit_zamani timestamptz not null default now());

  -- Yaşam stub'ları: premium değil, deneme sahibi = çocuğun velisi, deneme pencereleri tablodan
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
  -- Legacy deneme sınırları (20261125 varsayılanının kelime_evreni karşılığı: 2/gün)
  create or replace function public._deneme_sinir(p_ogrenci uuid, p_ozellik text) returns jsonb
  language sql stable as $$
    select case when p_ozellik = 'kelime_evreni' then '{"sinir":2,"pencere":"gunluk"}'::jsonb else null end
  $$;
`);
for (const [id, mail] of [[V_FREE, 'f'], [V_TAM, 't'], [V_SORU, 's'], [V_DENEME, 'd']]) {
  await db.query('insert into auth.users (id, email) values ($1, $2)', [id, `${mail}@x.test`]);
}
for (const [id, mail] of [[C_FREE, 'cf'], [C_TAM, 'ct'], [C_SORU, 'cs'], [C_DENEME, 'cd']]) {
  await db.query('insert into auth.users (id, email) values ($1, $2)', [id, `${mail}@x.test`]);
}
await db.exec(`
  insert into public.profiles (id, role) values
    ('${V_FREE}', 'veli'), ('${V_TAM}', 'veli'), ('${V_SORU}', 'veli'), ('${V_DENEME}', 'veli');
  insert into public.profiles (id, role, parent_id) values
    ('${C_FREE}', 'ogrenci', '${V_FREE}'), ('${C_TAM}', 'ogrenci', '${V_TAM}'),
    ('${C_SORU}', 'ogrenci', '${V_SORU}'), ('${C_DENEME}', 'ogrenci', '${V_DENEME}');
`);
await db.exec(fs.readFileSync(MIG_P1, 'utf8'));
await db.exec(`
  insert into public.plans (kod, ad, fiyat_kurus, sure_gun, tip_kod, paket_kod) values
    ('t_tam', 'T Tam', 100, 365, 'premium', 'tam'),
    ('t_soru', 'T Soru', 100, 365, 'premium', 'soru');
  insert into public.subscriptions (veli_id, plan_kod, durum, bitis) values
    ('${V_TAM}', 't_tam', 'aktif', now() + interval '30 days'),
    ('${V_SORU}', 't_soru', 'aktif', now() + interval '30 days');
  insert into public.deneme_donemleri (veli_id, baslangic, bitis) values
    ('${V_DENEME}', now() - interval '1 day', now() + interval '10 days');
`);
// Yeni fonksiyon gövdeleri (sınır tetikleyicilerinin çağırdığı) önce yüklenir
await db.exec(fs.readFileSync(MIG_F, 'utf8'));
// Sınır tetikleyicileri (20261125 ile aynı bağlantılar; prod'da zaten var)
await db.exec(`
  create trigger trg_deneme_sinir_kelime after insert on public.kelime_denemeleri
    for each row execute function public.deneme_sinir_tetik('ogrenci_id', 'created_at', 'kelime_evreni', 'Kelime Evreni');
  create trigger trg_deneme_sinir_carpim after insert on public.carpim_deneme_log
    for each row execute function public.deneme_sinir_tetik('user_id', 'created_at', 'carpim_sifresi', 'Çarpım şifreleri');
  create trigger trg_deneme_sinir_okuma after insert on public.okuma_oturumlari
    for each row execute function public.deneme_sinir_tetik('ogrenci_id', 'baslangic_at', 'okuma_hikayesi', 'Okuma hikâyesi');
  create trigger trg_deneme_sinir_deneme_sinavi after insert on public.deneme_sinavi_katilimlari
    for each row execute function public.deneme_sinir_tetik('student_id', 'kayit_zamani', 'deneme_sinavi', 'Deneme sınavı');
  create trigger trg_deneme_sinav_kapisi after insert on public.deneme_sinavi_katilimlari
    for each row execute function public.deneme_sinav_kapisi();
`);
// Yardımcı: istemci olarak kelime kaydı ekle
const kelimeEkle = async (uid, n = 1) => {
  await istemci(uid);
  for (let i = 0; i < n; i++) {
    await db.query('insert into public.kelime_denemeleri (ogrenci_id) values ($1)', [uid]);
  }
  await servis();
};
const kelimeDene = (uid) => hataBul(async () => {
  await istemci(uid);
  try { await db.query('insert into public.kelime_denemeleri (ogrenci_id) values ($1)', [uid]); }
  finally { await servis(); }
});

console.log('\n== 1. Ücretsiz taban: her ürün sınırlı erişimli ==');
let a = await erisim(C_FREE, 'kelime_evreni');
ok('kelime evreni artık sınırlı (önizleme değil)', a.erisim === 'sinirli' && a.gunluk_kota === 30, JSON.stringify(a));
a = await erisim(C_FREE, 'deneme');
ok('deneme sınavı ücretsiz taban: sınırlı 1', a.erisim === 'sinirli' && a.gunluk_kota === 1, JSON.stringify(a));
a = await erisim(C_FREE, 'okuma');
ok('okuma ücretsiz: sınırlı 2', a.erisim === 'sinirli' && a.gunluk_kota === 2, JSON.stringify(a));
a = await erisim(C_FREE, 'carpma');
ok('çarpma ücretsiz: sınırlı 40', a.erisim === 'sinirli' && a.gunluk_kota === 40, JSON.stringify(a));

console.log('\n== 2. Ücretsiz çocuk: kelime kotası (30/gün) ==');
await kelimeEkle(C_FREE, 30);
const otuzbirinci = await kelimeDene(C_FREE);
ok('31. kelime P0402 ile durdurulur', otuzbirinci?.kod === 'P0402', JSON.stringify(otuzbirinci));

console.log('\n== 3. Ücretsiz çocuk: deneme sınavı 1/gün ==');
await istemci(C_FREE);
await db.query('insert into public.deneme_sinavi_katilimlari (student_id) values ($1)', [C_FREE]);
const ikinciDeneme = await hataBul(() => db.query('insert into public.deneme_sinavi_katilimlari (student_id) values ($1)', [C_FREE]));
await servis();
ok('ilk deneme sınavı açılır, ikinci P0402', ikinciDeneme?.kod === 'P0402', JSON.stringify(ikinciDeneme));

console.log('\n== 4. Ücretsiz çocuk: okuma 2/gün ==');
await istemci(C_FREE);
await db.query('insert into public.okuma_oturumlari (ogrenci_id) values ($1)', [C_FREE]);
await db.query('insert into public.okuma_oturumlari (ogrenci_id) values ($1)', [C_FREE]);
const ucuncuOkuma = await hataBul(() => db.query('insert into public.okuma_oturumlari (ogrenci_id) values ($1)', [C_FREE]));
await servis();
ok('üçüncü okuma P0402', ucuncuOkuma?.kod === 'P0402', JSON.stringify(ucuncuOkuma));

console.log('\n== 5. Tam abonelik: sınırsız (kelime 35 kayıt) ==');
await kelimeEkle(C_TAM, 35);
const tamSayi = await tek(`select count(*)::int as n from public.kelime_denemeleri where ogrenci_id = '${C_TAM}'`);
ok('tam abone 35 kelime kaydı yaptı', tamSayi.n === 35, JSON.stringify(tamSayi));

console.log('\n== 6. Yalnız Soru paketi: kelime ücretsiz tabandan sınırlı (30), deneme tam ==');
// Ücretsiz taban tüm ürünleri kapsar; abonelik üstüne eklenir (en yüksek erişim kazanır).
const soruKelimeErisim = await erisim(C_SORU, 'kelime_evreni');
ok('soru paketi + ücretsiz taban: kelime sınırlı 30', soruKelimeErisim.erisim === 'sinirli' && soruKelimeErisim.gunluk_kota === 30, JSON.stringify(soruKelimeErisim));
const soruDenemeErisim = await erisim(C_SORU, 'deneme');
ok('soru paketi: deneme sınavı tam', soruDenemeErisim.erisim === 'tam', JSON.stringify(soruDenemeErisim));
await istemci(C_SORU);
const soruDeneme = await hataBul(() => db.query('insert into public.deneme_sinavi_katilimlari (student_id) values ($1)', [C_SORU]));
await servis();
ok('soru paketinde deneme sınavı açık (tam)', soruDeneme === null, JSON.stringify(soruDeneme));

console.log('\n== 7. Deneme penceresi: legacy sınır (kelime 2/gün) ==');
await kelimeEkle(C_DENEME, 2);
const ucuncuDeneme = await kelimeDene(C_DENEME);
ok('deneme penceresinde 3. kelime P0402 (legacy)', ucuncuDeneme?.kod === 'P0402' && ucuncuDeneme?.mesaj.includes('bugünkü'), JSON.stringify(ucuncuDeneme));

console.log('\n== 8. Servis yazımı sınırlanmaz ==');
await servis();
let sNo = null;
try {
  for (let i = 0; i < 35; i++) {
    await db.query('insert into public.kelime_denemeleri (ogrenci_id) values ($1)', [C_FREE]);
  }
} catch (e) { sNo = String(e.message ?? e); }
ok('servis (JWT yok) yazımında kota uygulanmaz', sNo === null, sNo ?? '');

console.log(`\nSonuç: ${pass} geçti, ${fail} kaldı`);
process.exit(fail === 0 ? 0 : 1);
