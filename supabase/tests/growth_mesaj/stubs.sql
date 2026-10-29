-- Growth CRM (20261014000000_growth_crm_core.sql) ve mesaj günlüğü migration'ı için
-- dış bağımlılık stub'ları (yalnızca test). Growth migration'ları değiştirilmeden yüklenir.
-- Supabase gibi: public tablolarında anon/authenticated/service_role varsayılan yetkileri var;
-- migration'lar REVOKE ile daraltır. Bu, yetki testlerinin gerçekçi olmasını sağlar.

create role anon nologin;
create role authenticated nologin;
-- Supabase'te service_role BYPASSRLS taşır (sunucu tarafı RPC'ler RLS'e takılmaz).
create role service_role nologin bypassrls;

alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to public, anon, authenticated, service_role;
grant usage on schema public to anon, authenticated, service_role;

-- Core tablolar: growth core view'ları ve FK'ları bu kolonlarla analiz eder.
create table public.profiles (
  id        uuid primary key default gen_random_uuid(),
  role      text not null check (role in ('veli', 'ogrenci', 'admin', 'ogretmen')),
  parent_id uuid references public.profiles (id),
  full_name text not null default '',
  username  text,
  sinif     smallint
);

create table public.student_stats (
  student_id       uuid primary key references public.profiles (id) on delete cascade,
  xp               int not null default 0,
  level            int not null default 1,
  streak_count     int not null default 0,
  last_active_date date
);

create table public.plans (
  kod         text primary key,
  ad          text not null,
  fiyat_kurus int not null default 0
);

create table public.subscriptions (
  id          uuid primary key default gen_random_uuid(),
  veli_id     uuid not null references public.profiles (id) on delete cascade,
  plan_kod    text not null references public.plans (kod),
  durum       text not null default 'aktif',
  baslangic   timestamptz not null default now(),
  bitis       timestamptz not null default now() + interval '30 days',
  saglayici   text
);

create table public.iletisim_tercihleri (
  veli_id     uuid not null references public.profiles (id) on delete cascade,
  kanal       text not null check (kanal in ('eposta', 'push', 'sms', 'uygulama_ici')),
  izin        boolean not null default false,
  kaynak      text,
  updated_at  timestamptz not null default now(),
  primary key (veli_id, kanal)
);
