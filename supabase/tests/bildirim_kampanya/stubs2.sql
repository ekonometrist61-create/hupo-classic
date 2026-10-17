-- CRM migration'ları (20261007000010/000020) için bağımlılık stub'ları (yalnızca test).
alter table public.profiles add column if not exists sinif smallint;

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

-- auth.users: kayıt trigger'ları (20261015, 20261020000300, 20261037) için
create table auth.users (id uuid primary key default gen_random_uuid(), email text, raw_user_meta_data jsonb not null default '{}'::jsonb, email_confirmed_at timestamptz);

-- growth CRM bastırma listesi (20261015 iptal RPC'si ve trigger'ı için kolonlar)
create table public.growth_prospect_suppressions (id uuid primary key default gen_random_uuid(), email_hash text, channel text, reason text, source text, expires_at timestamptz, created_at timestamptz not null default now());
