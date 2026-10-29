// Migration zinciri koşucusu: TÜM supabase/migrations dosyalarını ad sırasıyla (Supabase sırası)
// tek bir PGlite (WASM Postgres) veritabanında uygular. Hata veren dosya kaydedilir ve zincir devam eder;
// böylece yeni migration'ların önceki zincir üstünde çalışıp çalışmadığı görülür.
// Uzak veritabanına dokunmaz. Docker gerekmez.
//
// Kullanım (bu klasörde bir kez: npm install):
//   node kos.mjs
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const migDir = path.resolve(here, '../../migrations');
const dosyalar = fs.readdirSync(migDir).filter((f) => f.endsWith('.sql')).sort();

// PGlite'ta olmayan eklentiler: yalnız harness'ta atlanır, migration dosyaları değişmez.
const eklenti = /^\s*create extension (if not exists )?(pgcrypto|pg_cron|pg_net|supabase_vault|pgsodium|moddatetime|pg_stat_statements|http|pg_graphql)\b[^;]*;\s*$/gim;

const STUB = `
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
create schema if not exists extensions;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to public, anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
grant usage on schema public to anon, authenticated, service_role;
create schema if not exists auth;
grant usage on schema auth to anon, authenticated, service_role;
create table if not exists auth.users (
  id uuid primary key default gen_random_uuid(),
  email text, phone text,
  email_confirmed_at timestamptz,
  raw_user_meta_data jsonb not null default '{}'::jsonb,
  raw_app_meta_data jsonb not null default '{}'::jsonb,
  created_at timestamptz default now()
);
grant select on auth.users to service_role;
create or replace function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
create or replace function auth.role() returns text language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claim.role', true), ''), 'anon') $$;
create or replace function auth.jwt() returns jsonb language sql stable as $$
  select coalesce(nullif(current_setting('request.jwt.claims', true), ''), '{}')::jsonb $$;
create schema if not exists storage;
create table if not exists storage.buckets (id text primary key, name text, public boolean default false);
create table if not exists storage.objects (id uuid primary key default gen_random_uuid(), bucket_id text, name text, owner uuid, metadata jsonb);
create schema if not exists cron;
create table if not exists cron.job (jobid bigserial primary key, jobname text unique, schedule text, command text);
create or replace function cron.schedule(job_name text, schedule text, command text) returns bigint
language plpgsql as $$ declare v bigint; begin
  insert into cron.job (jobname, schedule, command) values (job_name, schedule, command)
  on conflict (jobname) do update set schedule = excluded.schedule, command = excluded.command
  returning jobid into v; return v; end $$;
create or replace function cron.unschedule(job_name text) returns boolean
language plpgsql as $$ begin delete from cron.job where jobname = job_name; return true; end $$;
`;

const db = new PGlite();
await db.exec(STUB);

const sonuclar = [];
for (const dosya of dosyalar) {
  const sql = fs.readFileSync(path.join(migDir, dosya), 'utf8').replace(eklenti, '-- eklenti PGlite harness\'ta atlandı;');
  try {
    await db.exec(sql);
    sonuclar.push({ dosya, durum: 'OK' });
  } catch (e) {
    sonuclar.push({ dosya, durum: 'HATA', mesaj: String(e.message ?? e).slice(0, 160), konum: e.position ?? '' });
  }
}

const hatali = sonuclar.filter((s) => s.durum === 'HATA');
console.log(`Zincir: ${sonuclar.length} dosya, ${sonuclar.length - hatali.length} OK, ${hatali.length} HATA`);
for (const s of hatali) console.log(`  HATA ${s.dosya}${s.konum ? ` (konum ${s.konum})` : ''}: ${s.mesaj}`);

// Yeni (2026-10-27 ve sonrası, 20261098+) migration'ların fonksiyon varlığı smoke kontrolü.
const beklenen = [
  'growth_iletisim_uygun_mu', 'growth_journey_ilerlet', 'admin_journey_adim_kaydet',
  'growth_yasam_dongusu_hesapla', 'admin_growth_funnel', 'admin_growth_hane_anonimlestir',
  'giris_olayi_kaydet', 'veli_sonraki_adim', 'growth_saklama_temizle', 'kullanim_olaylari_gonder',
  'admin_growth_hane_birlestir', 'admin_giris_ozet',
];
const fn = await db.query(`select proname from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public'`);
const var_ = new Set(fn.rows.map((r) => r.proname));
console.log('\nFonksiyon varlığı:');
for (const ad of beklenen) console.log(`  ${var_.has(ad) ? 'VAR ' : 'YOK '} ${ad}`);

// Sonuç dosyası (scratchpad'e değil, koşucunun yanına yazılır; .gitignore'a girmesin diye JSON değil metin).
fs.writeFileSync(path.join(here, 'SONUC.txt'), [
  `Zincir: ${sonuclar.length} dosya, ${sonuclar.length - hatali.length} OK, ${hatali.length} HATA`,
  ...hatali.map((s) => `HATA ${s.dosya}: ${s.mesaj}`),
].join('\n') + '\n', 'utf8');
