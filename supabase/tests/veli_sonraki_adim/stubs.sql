-- Supabase ortamını taklit eden minimum iskelet (yalnızca test için).
-- Kolon adları ve kısıtlar üretimdeki tanımla aynıdır; yalnızca kullanılmayan kolonlar atıldı.
create role anon nologin;
create role authenticated nologin;
create role service_role nologin;

create schema auth;
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

grant usage on schema auth to anon, authenticated, service_role;
grant usage on schema public to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;

create table public.profiles (
  id        uuid primary key default gen_random_uuid(),
  role      text not null check (role in ('veli', 'ogrenci', 'admin', 'ogretmen')),
  parent_id uuid references public.profiles (id) on delete set null,
  full_name text,
  constraint profiles_parent_only_for_student check (role = 'ogrenci' or parent_id is null)
);

-- Üretim: 20261016000000_veli_eslestirme_kodu.sql
create table public.parent_link_codes (
  kod                  text primary key,
  veli_id              uuid not null references public.profiles (id) on delete cascade,
  olusturuldu_at       timestamptz not null default now(),
  son_kullanma         timestamptz not null,
  kullanildi_at        timestamptz,
  kullanan_ogrenci_id  uuid references public.profiles (id) on delete set null
);

create table public.questions (
  id uuid primary key default gen_random_uuid()
);

-- Üretim: 20260920000000_initial_schema.sql (user_answers) — yalnızca student_id kullanılır
create table public.user_answers (
  id            uuid primary key default gen_random_uuid(),
  student_id    uuid not null references public.profiles (id) on delete cascade,
  question_id   uuid not null references public.questions (id) on delete cascade,
  secilen_sik   text not null default 'A',
  dogru_mu      boolean not null default false,
  created_at    timestamptz not null default now(),
  constraint user_answers_unique_pair unique (student_id, question_id)
);

create table public.plans (
  kod text primary key,
  ad  text not null
);

-- Üretim: 20260920000900_admin_role_and_payments.sql
create table public.subscriptions (
  id            uuid primary key default gen_random_uuid(),
  veli_id       uuid not null references public.profiles (id) on delete cascade,
  plan_kod      text not null references public.plans (kod),
  durum         text not null check (durum in ('aktif', 'iptal', 'suresi_doldu', 'beklemede')),
  baslangic     timestamptz not null default now(),
  bitis         timestamptz not null,
  saglayici     text,
  saglayici_ref text,
  created_at    timestamptz not null default now()
);

-- Üretim: 20261014000000_growth_crm_core.sql (growth_households; yalnızca okunan kolonlar)
create table public.growth_households (
  id                 uuid primary key default gen_random_uuid(),
  core_parent_user_id uuid references public.profiles (id) on delete set null,
  parent_name        text not null default '',
  email              text not null default '',
  trial_started_at   timestamptz
);
