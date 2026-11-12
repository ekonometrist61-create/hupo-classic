// Güvenlik sertleştirme (K-0257) testi: 20261217000000 PGlite (gerçek Postgres) üzerinde çalışır.
// Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.
//
// Kapsam:
// - site-gorselleri kovasında SVG izni kalmaz
// - anon üç tabloda yazamaz, character_definitions'ı okuyabilir
// - SMS tavanı: numara başına 1 saatte 3, 24 saatte 6; proje geneli 24 saatte 500; hata kodu P0001
// - sayaç, kod satırları silinse de (başarılı doğrulama) düşmez; numara düz yazılmaz
// - 2 günden eski sayaç satırları temizlenir
// - anon/authenticated sayaç tablosuna ve tetikleyici fonksiyonuna erişemez
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';

const MIG = path.resolve(import.meta.dirname, '../../migrations');
const YENI = '20261217000000_guvenlik_sertlestirme.sql';

const db = new PGlite();
let pass = 0;
let fail = 0;
const ok = (ad, kosul, detay = '') => {
  if (kosul) { pass++; console.log('  ✓', ad); }
  else { fail++; console.log('  ✗', ad, detay); }
};
const hatayiAl = async (fn) => {
  try { await fn(); return null; }
  catch (e) { return { kod: String(e.code ?? ''), mesaj: String(e.message ?? e) }; }
};
const tek = async (sql, params = []) => (await db.query(sql, params)).rows[0];

// Taban: yalnızca migration'ın dokunduğu nesneler (Supabase şemasının küçük taklidi).
await db.exec(`
  do $$ begin
    if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
    if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  end $$;
  create schema if not exists extensions;
  create schema if not exists storage;
  -- PGlite'ta pgcrypto yok: digest(text,'sha256') yerleşik sha256 ile taklit edilir.
  create function extensions.digest(t text, alg text) returns bytea
    language sql immutable as $$ select sha256(convert_to(t, 'UTF8')) $$;
  grant usage on schema public, extensions, storage to anon, authenticated;
  create table storage.buckets (id text primary key, public boolean, allowed_mime_types text[]);
  insert into storage.buckets values
    ('site-gorselleri', true, array['image/webp','image/png','image/jpeg','image/svg+xml']);
  create table public.character_definitions (id text primary key, ad text);
  create table public.user_characters (student_id uuid, character_id text);
  create table public.identity_merge_candidates (id bigint primary key);
  alter table public.character_definitions enable row level security;
  create policy herkese_acik on public.character_definitions for select using (true);
  grant all on public.character_definitions, public.user_characters, public.identity_merge_candidates
    to anon, authenticated;
  create table public.telefon_dogrulama_kodlari (
    id bigint generated always as identity primary key, user_id uuid, telefon text,
    kod_salt text, kod_hash text, deneme_sayisi int default 0,
    son_kullanma timestamptz, olusturma timestamptz default now());
`);

const sql = fs.readFileSync(path.join(MIG, YENI), 'utf8');
await db.exec(sql);
await db.exec(sql); // iki kez çalışabilmeli (yeniden uygulama güvenli)
ok('migration iki kez hatasız uygulanır', true);

const kova = await tek(`select allowed_mime_types::text m from storage.buckets where id = 'site-gorselleri'`);
ok('kovada SVG izni yok', !kova.m.includes('svg'), kova.m);

const yetki = await tek(`select
  has_table_privilege('anon','public.character_definitions','INSERT') a1,
  has_table_privilege('anon','public.user_characters','UPDATE') a2,
  has_table_privilege('anon','public.identity_merge_candidates','DELETE') a3,
  has_table_privilege('anon','public.character_definitions','SELECT') s1,
  has_table_privilege('authenticated','public.user_characters','INSERT') au,
  has_table_privilege('anon','public.user_characters','SELECT') s2,
  has_table_privilege('authenticated','public.user_characters','SELECT') s3,
  has_table_privilege('anon','public.identity_merge_candidates','SELECT') s4,
  has_table_privilege('authenticated','public.identity_merge_candidates','SELECT') s5`);
ok('anon user_characters okuyamaz, öğrenci okur', yetki.s2 === false && yetki.s3 === true);
ok('identity_merge_candidates istemciye kapalı', yetki.s4 === false && yetki.s5 === false);
ok('anon üç tabloda yazamaz', !yetki.a1 && !yetki.a2 && !yetki.a3, JSON.stringify(yetki));
ok('anon character_definitions okur', yetki.s1 === true);
ok('authenticated yetkisi değişmez', yetki.au === true);

const kodEkle = (tel) => db.query(
  `insert into public.telefon_dogrulama_kodlari (user_id, telefon) values (gen_random_uuid(), $1)`, [tel]);

for (let i = 0; i < 3; i++) await kodEkle('+905550000001');
let h = await hatayiAl(() => kodEkle('+905550000001'));
ok('aynı numaraya saatte 4. kod P0001', h?.kod === 'P0001', JSON.stringify(h));
ok('başka numara etkilenmez', (await hatayiAl(() => kodEkle('+905550000002'))) === null);

// Başarılı doğrulama kod satırlarını siler; sayaç düşmemeli.
await db.exec(`delete from public.telefon_dogrulama_kodlari where telefon = '+905550000001'`);
h = await hatayiAl(() => kodEkle('+905550000001'));
ok('kod satırları silinse de numara tavanı korunur', h?.kod === 'P0001', JSON.stringify(h));

// 24 saat sınırı: eski satırları 2 saat geriye çek, 3 kod daha (toplam 6), 7. reddedilir.
await db.exec(`update public.telefon_sms_gunlugu set olusturma = now() - interval '2 hours'`);
for (let i = 0; i < 3; i++) await kodEkle('+905550000001');
h = await hatayiAl(() => kodEkle('+905550000001'));
ok('aynı numaraya 24 saatte 7. kod P0001', h?.kod === 'P0001', JSON.stringify(h));

const duz = await tek(`select count(*)::int n from public.telefon_sms_gunlugu where telefon_ozet like '+90%'`);
ok('numara düz yazılmaz', duz.n === 0);

// Temizlik: 3 günlük satır silinir.
await db.exec(`update public.telefon_sms_gunlugu set olusturma = now() - interval '3 days'`);
await kodEkle('+905550000003');
const kalan = await tek(`select count(*)::int n from public.telefon_sms_gunlugu`);
ok('2 günden eski sayaç satırları silinir', kalan.n === 1, String(kalan.n));

// Proje geneli tavan: 499 satır daha ekle (toplam 500), sonraki her numara reddedilir.
await db.exec(`insert into public.telefon_sms_gunlugu (telefon_ozet)
  select 'x' || g from generate_series(1, 499) g`);
h = await hatayiAl(() => kodEkle('+905550000099'));
ok('24 saatte 500 kod sonrası genel tavan P0001', h?.kod === 'P0001', JSON.stringify(h));

const erisim = await tek(`select
  has_table_privilege('anon','public.telefon_sms_gunlugu','SELECT') t1,
  has_table_privilege('authenticated','public.telefon_sms_gunlugu','INSERT') t2,
  has_function_privilege('authenticated','public.telefon_sms_tavan_kontrol()','EXECUTE') f1`);
ok('sayaç tablosu ve fonksiyonu istemciye kapalı', !erisim.t1 && !erisim.t2 && !erisim.f1, JSON.stringify(erisim));

console.log(`\n${pass} geçti, ${fail} başarısız`);
process.exit(fail ? 1 : 0);
