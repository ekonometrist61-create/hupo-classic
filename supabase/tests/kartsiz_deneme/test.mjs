// Kartsız ücretsiz deneme + deneme sınırları: gerçek migration zinciri PGlite üzerinde.
// Zincir: yaşam stub → 20261018010000 (deneme) → özellik tabloları (stub) → 20261125000000.
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import fs from 'node:fs';
import path from 'node:path';

const HERE = import.meta.dirname;
const require = createRequire(import.meta.url);
const { PGlite } = await import(pathToFileURL(require.resolve('@electric-sql/pglite', {
  paths: [HERE, path.resolve(HERE, '../ab_deney')],
})).href);

const MIG = path.resolve(HERE, '../../migrations');
const STUBS = path.resolve(HERE, '../growth_yasam_dongusu/stubs.sql');

const db = new PGlite();
let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const tek = async (sql, p = []) => (await db.query(sql, p)).rows[0];
// Hata kodu/mesajı: hata yoksa null
const hataBul = async (fn) => {
  try { await fn(); return null; }
  catch (e) { return { kod: e.code ?? '', mesaj: String(e.message ?? e) }; }
};
const istemci = (uid) => db.exec(`set request.jwt.claims = '{"sub":"${uid}"}';`);
const servis = () => db.exec(`set request.jwt.claims = '';`);

const VELI = '00000000-0000-4000-8000-000000000002';
const COCUK = '00000000-0000-4000-8000-000000000003';
const VELI2 = '00000000-0000-4000-8000-000000000004';
const YONETICI = '00000000-0000-4000-8000-000000000005';
const COCUK3 = '00000000-0000-4000-8000-000000000006';
const COCUK5 = '00000000-0000-4000-8000-000000000007';
const COCUK_BIT = '00000000-0000-4000-8000-000000000008';

console.log('\n== Kurulum ==');
await db.exec(fs.readFileSync(STUBS, 'utf8'));
await db.exec(`
  create table public.app_settings (
    key        text primary key,
    value      jsonb not null,
    updated_at timestamptz not null default now()
  );
  create table public.answer_events (
    id         uuid primary key default gen_random_uuid(),
    student_id uuid not null,
    created_at timestamptz not null default now()
  );
  create or replace function public.is_premium(p_uid uuid) returns boolean
  language sql stable as $$ select false $$;
  -- Gating açık, normal kota 3: deneme yokken bu değer görülmeli.
  create or replace function public._gating() returns table (aktif boolean, limit_gun integer)
  language sql stable as $$ select true, 3 $$;
  -- Yönetici kontrolü ve log: bu testte her çağrı kabul edilir.
  create or replace function public.require_admin() returns void language plpgsql as $$ begin end $$;
  create or replace function public.log_admin_action(p_aksiyon text, p_detay jsonb) returns void
  language plpgsql as $$ begin end $$;

  -- Özellik tabloları (yalnız sınırın okuduğu kolonlar)
  create table public.kelime_denemeleri (
    id uuid primary key default gen_random_uuid(), ogrenci_id uuid not null,
    created_at timestamptz not null default now());
  create table public.carpim_deneme_log (
    id uuid primary key default gen_random_uuid(), user_id uuid not null,
    created_at timestamptz not null default now());
  create table public.deneme_sinavi_katilimlari (
    id uuid primary key default gen_random_uuid(), student_id uuid not null, veli_id uuid,
    kayit_zamani timestamptz not null default now());
  create table public.okuma_oturumlari (
    id uuid primary key default gen_random_uuid(), ogrenci_id uuid not null,
    baslangic_at timestamptz not null default now());
  create table public.meydan_okumalar (
    id uuid primary key default gen_random_uuid(), davet_eden uuid,
    olusturulma timestamptz not null default now());
`);
await db.exec(fs.readFileSync(path.join(MIG, '20261018010000_deneme_suresi.sql'), 'utf8'));
await db.exec(fs.readFileSync(path.join(MIG, '20261125000000_kartsiz_deneme_kayitta.sql'), 'utf8'));
await db.exec(fs.readFileSync(path.join(MIG, '20261126000000_deneme_yonetim_ve_gorunurluk.sql'), 'utf8'));
ok('migration zinciri yüklendi', true);

await db.exec(`insert into auth.users (id, email) values
  ('${VELI}', 'v@t'), ('${COCUK}', 'c@t'), ('${VELI2}', 'v2@t'), ('${YONETICI}', 'y@t'),
  ('${COCUK3}', 'c3@t'), ('${COCUK5}', 'c5@t'), ('${COCUK_BIT}', 'cb@t')`);

console.log('\n== Veli profili ve kayıtta deneme ==');
await db.exec(`insert into public.profiles (id, role, full_name) values ('${VELI}', 'veli', 'Veli Bir')`);
const d1 = await tek(`select veli_id, olusturan,
                             round(extract(epoch from (bitis - now())) / 86400.0, 3) as kalan_gun
                        from public.deneme_donemleri where veli_id = $1`, [VELI]);
ok('veli profili açılınca deneme kaydı oluşur', !!d1, JSON.stringify(d1));
ok('süre varsayılan 14 gün', d1 && Math.abs(Number(d1.kalan_gun) - 14) < 0.01, JSON.stringify(d1));
ok('kayıt sistem tarafından yazılır (olusturan boş)', d1 && d1.olusturan === null);

console.log('\n== Çocuklar hane denemesinden yararlanır ==');
await db.exec(`insert into public.profiles (id, role, parent_id, full_name, sinif) values
  ('${COCUK}', 'ogrenci', '${VELI}', 'Çocuk', null),
  ('${COCUK3}', 'ogrenci', '${VELI}', 'Çocuk Üç', 3),
  ('${COCUK5}', 'ogrenci', '${VELI}', 'Çocuk Beş', 5)`);
const cocukKayit = await tek(`select count(*)::int as n from public.deneme_donemleri where veli_id = $1`, [COCUK]);
ok('çocuk profili kendi denemesini açmaz', cocukKayit.n === 0);
const aktifCocuk = await tek(`select public._deneme_aktif($1) as a`, [COCUK]);
ok('çocuk, velinin aktif denemesini görür', aktifCocuk.a === true);

console.log('\n== Soru kotası (sınıf bazlı, varsayılan 20) ==');
const kotaCocuk = await tek(`select public.remaining_free_questions($1) as k`, [COCUK]);
ok('sınıfsız çocuk: varsayılan soru sınırı 20', kotaCocuk.k === 20, JSON.stringify(kotaCocuk));

console.log('\n== Yönetici ve ayar değişikliği ==');
await db.exec(`insert into public.profiles (id, role, full_name) values ('${YONETICI}', 'admin', 'Yönetici')`);
const dYonetici = await tek(`select count(*)::int as n from public.deneme_donemleri where veli_id = $1`, [YONETICI]);
ok('veli dışı rol için deneme açılmaz', dYonetici.n === 0);

await db.exec(`update public.app_settings set value = '{"gun": 7, "gunluk_soru": 20}' where key = 'deneme'`);
await db.exec(`insert into public.profiles (id, role, full_name) values ('${VELI2}', 'veli', 'Veli İki')`);
const d2 = await tek(`select round(extract(epoch from (bitis - now())) / 86400.0, 3) as kalan_gun
                        from public.deneme_donemleri where veli_id = $1`, [VELI2]);
ok('ayar 7 gün yapılınca yeni veli 7 gün alır', d2 && Math.abs(Number(d2.kalan_gun) - 7) < 0.01, JSON.stringify(d2));
await db.exec(`update public.app_settings set value = '{"gun": 14, "gunluk_soru": 20}' where key = 'deneme'`);

console.log('\n== Sınıf sınırı: soru (override) ==');
await db.exec(`update public.app_settings set value = jsonb_set(value, '{siniflar}',
  '{"3": {"soru": {"sinir": 5, "pencere": "gunluk"}}}'::jsonb) where key = 'deneme_sinirlari'`);
const kotaC3 = await tek(`select public.remaining_free_questions($1) as k`, [COCUK3]);
const kotaC5 = await tek(`select public.remaining_free_questions($1) as k`, [COCUK5]);
ok('sınıf 3 soru sınırı override ile 5', kotaC3.k === 5, JSON.stringify(kotaC3));
ok('sınıf 5 soru sınırı varsayılan 20', kotaC5.k === 20, JSON.stringify(kotaC5));

console.log('\n== Kelime Evreni: günlük 20 (20261126 düzeltmesi) ==');
await istemci(COCUK5);
for (let i = 0; i < 20; i++) {
  await db.query(`insert into public.kelime_denemeleri (ogrenci_id) values ($1)`, [COCUK5]);
}
const kelime21 = await hataBul(() => db.query(`insert into public.kelime_denemeleri (ogrenci_id) values ($1)`, [COCUK5]));
ok('21. kelime denemesi P0402 ile reddedilir', kelime21 && kelime21.kod === 'P0402', JSON.stringify(kelime21));
ok('mesaj özelliği ve günlük pencereyi söyler', kelime21 && /Bugünlük Kelime Evreni hakkın doldu\. Yarın yeniden açılır\./.test(kelime21.mesaj), kelime21 && kelime21.mesaj);
// Hata sonrası satır geri alınmış olmalı: sayım hâlâ 20
const kelimeSayi = await tek(`select count(*)::int as n from public.kelime_denemeleri where ogrenci_id = $1`, [COCUK5]);
ok('reddedilen satır kalıcı olmaz (sayı 20)', kelimeSayi.n === 20, JSON.stringify(kelimeSayi));

console.log('\n== Çarpım şifreleri: sınıf 3 override (günlük 2), sınıf 5 varsayılan (30) ==');
await db.exec(`update public.app_settings set value = jsonb_set(value, '{siniflar,3,carpim_sifresi}',
  '{"sinir": 2, "pencere": "gunluk"}'::jsonb) where key = 'deneme_sinirlari'`);
await istemci(COCUK3);
await db.query(`insert into public.carpim_deneme_log (user_id) values ($1)`, [COCUK3]);
await db.query(`insert into public.carpim_deneme_log (user_id) values ($1)`, [COCUK3]);
const carpim3 = await hataBul(() => db.query(`insert into public.carpim_deneme_log (user_id) values ($1)`, [COCUK3]));
ok('sınıf 3: 3. çarpım adımı P0402', carpim3 && carpim3.kod === 'P0402', JSON.stringify(carpim3));
await istemci(COCUK5);
for (let i = 0; i < 3; i++) {
  await db.query(`insert into public.carpim_deneme_log (user_id) values ($1)`, [COCUK5]);
}
ok('sınıf 5: 3 çağrı varsayılan 20 içinde kalır', true);

console.log('\n== Deneme sınavı: deneme süresi boyunca 2 ==');
await istemci(COCUK5);
await db.query(`insert into public.deneme_sinavi_katilimlari (student_id, veli_id) values ($1, $2)`, [COCUK5, VELI]);
await db.query(`insert into public.deneme_sinavi_katilimlari (student_id, veli_id) values ($1, $2)`, [COCUK5, VELI]);
const sinav3 = await hataBul(() => db.query(
  `insert into public.deneme_sinavi_katilimlari (student_id, veli_id) values ($1, $2)`, [COCUK5, VELI]));
ok('3. deneme sınavı katılımı P0402 (deneme penceresi)', sinav3 && sinav3.kod === 'P0402', JSON.stringify(sinav3));
ok('mesaj deneme penceresini söyler', sinav3 && /Bu denemedeki Deneme sınavı hakkın doldu\./.test(sinav3.mesaj), sinav3 && sinav3.mesaj);

console.log('\n== Okuma hikâyesi: günlük 2 ==');
await istemci(COCUK5);
await db.query(`insert into public.okuma_oturumlari (ogrenci_id) values ($1)`, [COCUK5]);
await db.query(`insert into public.okuma_oturumlari (ogrenci_id) values ($1)`, [COCUK5]);
const okuma3 = await hataBul(() => db.query(`insert into public.okuma_oturumlari (ogrenci_id) values ($1)`, [COCUK5]));
ok('aynı gün 3. hikâye oturumu P0402', okuma3 && okuma3.kod === 'P0402', JSON.stringify(okuma3));

console.log('\n== Servis yazımları sınırlanmaz ==');
await servis();
for (let i = 0; i < 3; i++) {
  await db.query(`insert into public.okuma_oturumlari (ogrenci_id) values ($1)`, [COCUK5]);
}
ok('oturumsuz (servis) yazımı sınırı atlar', true);

console.log('\n== Deneme bitince sınır kalkar (gating kuralına dönülür) ==');
await db.exec(`insert into public.profiles (id, role, parent_id, full_name, sinif)
               values ('${COCUK_BIT}', 'ogrenci', '${VELI2}', 'Çocuk Bitti', 5)`);
await db.query(`update public.deneme_donemleri
                   set baslangic = now() - interval '2 days', bitis = now() - interval '1 day'
                 where veli_id = $1`, [VELI2]);
await istemci(COCUK_BIT);
let bitisHata = null;
for (let i = 0; i < 25; i++) {
  bitisHata = bitisHata ?? await hataBul(() => db.query(`insert into public.kelime_denemeleri (ogrenci_id) values ($1)`, [COCUK_BIT]));
}
ok('deneme bitmiş hanede kelime sınırı uygulanmaz', bitisHata === null, JSON.stringify(bitisHata));
const kotaBitti = await tek(`select public.remaining_free_questions($1) as k`, [COCUK_BIT]);
ok('deneme bitince soru kotası gating değerine döner (3)', kotaBitti.k === 3, JSON.stringify(kotaBitti));
await servis();

console.log('\n== Görünürlük: deneme_hak_durumu ==');
await istemci(COCUK5);
const durumCocuk = await tek(`select public.deneme_hak_durumu() as d`);
const satirKelime = durumCocuk.d.ozellikler.find((s) => s.ozellik === 'kelime_evreni');
const satirSinav = durumCocuk.d.ozellikler.find((s) => s.ozellik === 'deneme_sinavi');
ok('çocuk kendi durumunu görür: deneme aktif', durumCocuk.d.deneme === true, JSON.stringify(durumCocuk.d));
ok('kelime evreni: kullanılan 20, kalan 0', satirKelime && satirKelime.kullanilan === 20 && satirKelime.kalan === 0, JSON.stringify(satirKelime));
ok('deneme sınavı: deneme penceresi, kullanılan 2, kalan 0',
  satirSinav && satirSinav.pencere === 'deneme' && satirSinav.kullanilan === 2 && satirSinav.kalan === 0, JSON.stringify(satirSinav));
ok('soru satırı var ve kalan 20', durumCocuk.d.ozellikler.some((s) => s.ozellik === 'soru' && s.kalan === 20));
ok('kalan gün 14’e yakın', durumCocuk.d.kalan_gun >= 13 && durumCocuk.d.kalan_gun <= 14, JSON.stringify(durumCocuk.d));
await istemci(VELI);
const durumVeli = await tek(`select public.deneme_hak_durumu($1) as d`, [COCUK5]);
ok('veli kendi çocuğunun durumunu görür', durumVeli.d.deneme === true && durumVeli.d.ozellikler.length === 6);
await istemci(VELI2);
const yetkisiz = await hataBul(() => db.query(`select public.deneme_hak_durumu($1)`, [COCUK5]));
ok('ilgisiz veli başka çocuğun durumunu göremez (42501)', yetkisiz && yetkisiz.kod === '42501', JSON.stringify(yetkisiz));
await servis();
const oturumsuz = await hataBul(() => db.query(`select public.deneme_hak_durumu()`));
ok('oturumsuz çağrı reddedilir (42501)', oturumsuz && oturumsuz.kod === '42501', JSON.stringify(oturumsuz));
const yonetimOku = await tek(`select public.admin_get_deneme_sinirlari() as v`);
ok('yönetici okuması varsayılan kelime sınırını 20 döndürür',
  yonetimOku.v.varsayilan.kelime_evreni.sinir === 20 && yonetimOku.v.varsayilan.carpim_sifresi.sinir === 20,
  JSON.stringify(yonetimOku.v.varsayilan));

console.log('\n== Yönetici ayarı: doğrulama ==');
const yanlisSinir = await hataBul(() => db.query(
  `select public.admin_set_deneme_sinirlari($1::jsonb)`,
  ['{"varsayilan": {"soru": {"sinir": 2000, "pencere": "gunluk"}}}']));
ok('sınır 1000 üstü reddedilir (22023)', yanlisSinir && yanlisSinir.kod === '22023', JSON.stringify(yanlisSinir));
const yanlisPencere = await hataBul(() => db.query(
  `select public.admin_set_deneme_sinirlari($1::jsonb)`,
  ['{"varsayilan": {"soru": {"sinir": 5, "pencere": "haftalik"}}}']));
ok('bilinmeyen pencere reddedilir (22023)', yanlisPencere && yanlisPencere.kod === '22023', JSON.stringify(yanlisPencere));
const yanlisSinif = await hataBul(() => db.query(
  `select public.admin_set_deneme_sinirlari($1::jsonb)`,
  ['{"varsayilan": {"soru": {"sinir": 5, "pencere": "gunluk"}}, "siniflar": {"13": {}}}']));
ok('sınıf 13 reddedilir (22023)', yanlisSinif && yanlisSinif.kod === '22023', JSON.stringify(yanlisSinif));
const dogru = await hataBul(() => db.query(
  `select public.admin_set_deneme_sinirlari($1::jsonb)`,
  ['{"varsayilan": {"soru": {"sinir": 20, "pencere": "gunluk"}}, "siniflar": {"4": {"soru": {"sinir": 15, "pencere": "gunluk"}}}}']));
ok('geçerli ayar kabul edilir', dogru === null, JSON.stringify(dogru));

console.log('\n== Tetikleyiciler ve yetki ==');
const tetik = await tek(`select count(*)::int as n from pg_trigger where tgname like 'trg_deneme_sinir_%'`);
ok('5 özellik tablosunda sınır tetikleyicisi var', tetik.n === 5, JSON.stringify(tetik));
const kayit = await tek(`select count(*)::int as n from pg_trigger where tgname = 'trg_deneme_veli_profili_ekle'`);
ok('kayıt tetikleyicisi profiles tablosuna bağlı', kayit.n === 1);
const anonYetki = await tek(`select has_function_privilege('anon', 'public.deneme_veli_profili_ekle()', 'EXECUTE') as y`);
ok('anon kayıt fonksiyonunu çalıştıramaz', anonYetki.y === false);
const anonSinir = await tek(`select has_function_privilege('anon', 'public.deneme_sinir_tetik()', 'EXECUTE') as y`);
ok('anon sınır tetikleyicisini çalıştıramaz', anonSinir.y === false);

console.log(`\n${pass} geçti, ${fail} başarısız`);
if (fail > 0) process.exit(1);
