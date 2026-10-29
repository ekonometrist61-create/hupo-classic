-- Supabase ortamını taklit eden minimum iskelet (yalnızca test için).
-- bildirim_kampanya/stubs.sql + stubs2.sql'in birebir kopyasıdır; ek olarak growth CRM
-- çekirdeğinin (20261014000000) bu testin kullandığı iki tablosu eklenmiştir.
create role anon nologin;
create role authenticated nologin;
create role service_role nologin;

create schema auth;
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
grant usage on schema public to anon, authenticated, service_role;

create schema cron;
create table cron.job (
  jobid    bigserial primary key,
  jobname  text unique,
  schedule text,
  command  text
);
create function cron.schedule(job_name text, schedule text, command text) returns bigint
language plpgsql as $$
declare v bigint;
begin
  insert into cron.job (jobname, schedule, command) values (job_name, schedule, command)
    returning jobid into v;
  return v;
end $$;

create table public.profiles (
  id        uuid primary key default gen_random_uuid(),
  role      text not null check (role in ('veli', 'ogrenci', 'admin', 'ogretmen')),
  parent_id uuid references public.profiles (id),
  full_name text not null default ''
);
alter table public.profiles add column if not exists sinif smallint;

create table public.consents (
  id        uuid primary key default gen_random_uuid(),
  cocuk_id  uuid references public.profiles (id),
  tur       text not null,
  created_at timestamptz not null default now()
);

create table public.anketler (
  id          uuid primary key default gen_random_uuid(),
  durum       text not null default 'taslak',
  yuzeyler    text[] not null default '{}',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create function public.require_admin() returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.profiles where id = auth.uid() and role = 'admin') then
    raise exception 'Yetkisiz' using errcode = '42501';
  end if;
end $$;

create function public.log_admin_action(p_tur text, p_detay jsonb) returns void
language plpgsql as $$ begin null; end $$;

-- 20261007000020 ve 20261020 zincirinin kullandığı abonelik ve öğrenci tabloları
create table public.subscriptions (
  id       uuid primary key default gen_random_uuid(),
  veli_id  uuid not null references public.profiles (id) on delete cascade,
  plan_kod text not null default 'free',
  durum    text not null default 'aktif',
  bitis    timestamptz not null default now() + interval '30 days'
);

create table public.student_stats (
  student_id       uuid primary key references public.profiles (id) on delete cascade,
  last_active_date date
);

create table public.user_answers (
  id          uuid primary key default gen_random_uuid(),
  student_id  uuid not null references public.profiles (id) on delete cascade
);

create table public.olay_kutusu (
  id          uuid primary key default gen_random_uuid(),
  tur         text not null,
  payload     jsonb not null default '{}'::jsonb,
  created_at  timestamptz not null default now()
);

create table public.admin_audit_log (id uuid primary key default gen_random_uuid(), aksiyon text, detay jsonb default '{}'::jsonb, created_at timestamptz not null default now());

-- auth.users: kayıt trigger'ları (20261015, 20261020000300) için
create table auth.users (id uuid primary key default gen_random_uuid(), email text, raw_user_meta_data jsonb not null default '{}'::jsonb, email_confirmed_at timestamptz);

-- growth CRM bastırma listesi (20261015 iptal RPC'si ve ticari_iletisim_engelli_mi için)
create table public.growth_prospect_suppressions (id uuid primary key default gen_random_uuid(), email_hash text, channel text, reason text, source text, expires_at timestamptz, created_at timestamptz not null default now());

-- growth CRM çekirdeği (20261014000000'ın bu testin kullandığı birebir alt kümesi).
-- Yabancı anahtarlar growth_campaigns / growth_journeys yerine düz uuid bırakıldı (bu testte kullanılmıyor).
create table public.growth_households (
  id                  uuid primary key default gen_random_uuid(),
  core_parent_user_id uuid references public.profiles (id) on delete set null,
  parent_name         text not null,
  email               text not null
);

create table public.growth_message_log (
  id                  uuid primary key default gen_random_uuid(),
  household_id        uuid not null references public.growth_households (id) on delete cascade,
  campaign_id         uuid,
  journey_id          uuid,
  channel             text not null,
  status              text not null,
  provider_message_id text,
  consent_snapshot    jsonb not null,
  payload_hash        text,
  sent_at             timestamptz,
  opened_at           timestamptz,
  clicked_at          timestamptz,
  converted_at        timestamptz,
  error               text,
  created_at          timestamptz not null default now()
);
