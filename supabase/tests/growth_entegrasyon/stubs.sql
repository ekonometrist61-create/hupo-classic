-- Growth entegrasyon testi için Supabase iskeleti (yalnızca test). Gerçek migration'lar bunun üstünde
-- çalışır ve HİÇBİR fonksiyon taklit edilmez: pazarlama kapısı (20261101) gerçek kodla sınanır.
-- growth_journey/stubs.sql'den farkı: test_uygunluk / require_admin / growth_iletisim_uygun_mu taklidi YOK.

create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;

alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to public, anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;
grant usage on schema public to anon, authenticated, service_role;

create schema if not exists auth;
grant usage on schema auth to anon, authenticated, service_role;
create table if not exists auth.users (
  id                 uuid primary key default gen_random_uuid(),
  email              text,
  email_confirmed_at timestamptz,
  raw_user_meta_data jsonb not null default '{}'::jsonb
);
grant select on auth.users to service_role;

create or replace function auth.uid() returns uuid
language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

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

-- 20261007000010 kanal listesi (1020000300 sonrası ile aynı).
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

-- 20261007000020: sessiz saat ve haftalık sınır satırı (tek satır).
create table public.iletisim_ayarlari (
  id               boolean primary key default true check (id),
  haftalik_limit   int not null default 3,
  sessiz_baslangic time not null default '21:00',
  sessiz_bitis     time not null default '09:00',
  zaman_dilimi     text not null default 'Europe/Istanbul'
);
insert into public.iletisim_ayarlari (id) values (true);

-- 20261042 eposta_outbox şeması (1099 alici_id'yi gevşetir, growth kolonlarını ekler).
create table public.eposta_outbox (
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

-- 20261015 _kayit_iletisim_izni tetikleyicisinin çağırdığı yardımcı (rıza yazımı burada test edilmez).
create or replace function public._tercih_yaz(p_veli uuid, p_kanal text, p_izin boolean, p_kaynak text, p_guncelleyen uuid, p_not text)
returns void language plpgsql as $$ begin null; end $$;
