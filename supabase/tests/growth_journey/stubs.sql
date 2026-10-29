-- Test harness: Growth journey migration'ının bağımlılıklarının minimal taklidi.
-- Yalnızca 20261014000000 (growth core), 20261015000000 (ticari izin) ve 20261099000000
-- (journey motoru) dosyalarının okuduğu/yazdığı sütunlar. Gerçek Hupolingo tabloları bunlar değildir.

-- Supabase auth şeması
create schema if not exists auth;
create table if not exists auth.users (
  id                 uuid primary key default gen_random_uuid(),
  email              text,
  email_confirmed_at timestamptz,
  raw_user_meta_data jsonb not null default '{}'::jsonb
);

create or replace function auth.uid() returns uuid
language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

-- Supabase rolleri. service_role bypassrls taşır (Supabase'deki gibi).
do $$ begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin bypassrls; end if;
end $$;

grant usage on schema public, auth to anon, authenticated, service_role;
grant select on auth.users to service_role;
-- Supabase varsayılan yetkileri: yeni tablo/fonksiyon anon ve authenticated'a açık gelir.
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;

-- pg_cron taklidi: cron.job tablosu ve 3 parametreli schedule.
create schema if not exists cron;
create table if not exists cron.job (
  jobid    bigserial primary key,
  jobname  text unique,
  schedule text,
  command  text
);
create or replace function cron.schedule(job_name text, schedule text, command text) returns bigint
language plpgsql as $$
declare v bigint;
begin
  insert into cron.job (jobname, schedule, command) values (job_name, schedule, command)
    returning jobid into v;
  return v;
end $$;

create table public.profiles (
  id         uuid primary key default gen_random_uuid(),
  role       text,
  parent_id  uuid references public.profiles (id) on delete set null,
  full_name  text,
  username   text,
  sinif      smallint
);

create table public.student_stats (
  student_id       uuid primary key references public.profiles (id) on delete cascade,
  xp               integer not null default 0,
  level            integer not null default 1,
  streak_count     integer not null default 0,
  last_active_date date
);

create table public.plans (
  kod         text primary key,
  ad          text not null,
  fiyat_kurus int not null,
  sure_gun    int not null,
  aktif       boolean not null default true,
  tip_kod     text not null default 'premium'
);

create table public.subscriptions (
  id            uuid primary key default gen_random_uuid(),
  veli_id       uuid,
  plan_kod      text,
  durum         text,
  baslangic     timestamptz default now(),
  bitis         timestamptz,
  saglayici     text,
  saglayici_ref text,
  created_at    timestamptz not null default now()
);

-- Kanal kısıtı 20261020000300 sonrası iletisim_tercihleri ile aynı.
create table public.iletisim_tercihleri (
  veli_id        uuid not null references public.profiles (id) on delete cascade,
  kanal          text not null,
  izin           boolean not null,
  kaynak         text not null default 'admin',
  guncelleyen_id uuid,
  updated_at     timestamptz not null default now(),
  primary key (veli_id, kanal),
  constraint iletisim_tercihleri_kanal_check
    check (kanal in ('eposta', 'push', 'sms', 'telefon', 'uygulama_ici')),
  constraint iletisim_tercihleri_kaynak_check
    check (kaynak in ('veli', 'admin', 'web_form', 'sistem'))
);

-- === P4 kapısı (20261101) test taklidi: gerçek fonksiyon growth_uygunluk paketinde sınanır. ===
-- Kayıt yoksa uygun=true. Kayıt varsa test, kapının cevabını belirler.
create table if not exists public.test_uygunluk (
  household_id  uuid primary key,
  uygun         boolean not null,
  neden         text,
  sonraki_uygun timestamptz
);
create or replace function public.growth_iletisim_uygun_mu(p_household_id uuid, p_channel text, p_simdi timestamptz default now())
returns jsonb language sql stable as $$
  select coalesce(
    (select jsonb_build_object('uygun', t.uygun, 'neden', t.neden, 'sonraki_uygun', t.sonraki_uygun)
       from public.test_uygunluk t where t.household_id = p_household_id),
    jsonb_build_object('uygun', true, 'neden', null, 'sonraki_uygun', p_simdi));
$$;

-- === Yönetici kapısı ve denetim izi taklidi (P7) ===
create table if not exists public.test_admin_log (aksiyon text, detay jsonb);
create or replace function public.require_admin() returns void language plpgsql as $$
begin
  if coalesce(current_setting('test.admin', true), '') <> 'evet' then
    raise exception 'Yönetici yetkisi gerekli.' using errcode = '42501';
  end if;
end $$;
create or replace function public.log_admin_action(p_aksiyon text, p_detay jsonb) returns void language sql as $$
  insert into public.test_admin_log values (p_aksiyon, p_detay);
$$;
-- W9: e-posta adımı eposta_outbox'a yazar (20261042 şeması; alici_id 20261099'da gevşetilir).
create table if not exists public.eposta_outbox (
  id            uuid primary key default gen_random_uuid(),
  alici_id      uuid not null references public.profiles (id) on delete cascade,
  konu          text not null check (char_length(konu) between 1 and 200),
  govde         text not null check (char_length(govde) between 1 and 4000),
  durum         text not null default 'bekliyor' check (durum in ('bekliyor', 'gonderildi', 'basarisiz')),
  deneme        integer not null default 0 check (deneme >= 0),
  son_hata      text,
  created_at    timestamptz not null default now(),
  gonderildi_at timestamptz
);
