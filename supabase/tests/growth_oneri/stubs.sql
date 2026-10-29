-- Growth öneri testi için dış bağımlılık iskeleti (yalnızca test; gerçek migration'lar değiştirilmez).
-- Yalnız growth migration'larının (20261014, 20261027) CREATE anında ya da backfill'inde
-- ihtiyaç duyduğu çekirdek nesneleri taklit eder. Sütun adları gerçek DDL ile aynıdır.

-- Roller ve auth iskeleti
create role anon nologin;
create role authenticated nologin;
create role service_role nologin;

create schema auth;
create table auth.users (
  id    uuid primary key,
  email text
);
create function auth.uid() returns uuid language sql stable as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

-- Supabase gibi: public tablolarında varsayılan yetkiler; migration'lar REVOKE ile daraltır.
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
grant usage on schema public to anon, authenticated, service_role;

-- pg_cron taklidi (bildirim_kampanya ile aynı kalıp): cron.job + cron.schedule
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
  on conflict (jobname) do update set schedule = excluded.schedule, command = excluded.command
  returning jobid into v;
  return v;
end $$;

-- Core: profiller (veli / öğrenci / admin)
create table public.profiles (
  id          uuid primary key default gen_random_uuid(),
  role        text not null check (role in ('veli', 'ogrenci', 'admin', 'ogretmen')),
  parent_id   uuid references public.profiles (id),
  full_name   text not null default '',
  username    text,
  sinif       smallint,
  created_at  timestamptz not null default now()
);

-- Core: öğrenci istatistikleri (growth_customer_360 view'u okur)
create table public.student_stats (
  student_id       uuid primary key references public.profiles (id) on delete cascade,
  xp               int not null default 0,
  level            int not null default 1,
  streak_count     int not null default 0,
  last_active_date date
);

-- Core: planlar ve abonelikler (20260920000900 ile aynı sütunlar)
create table public.plans (
  kod          text primary key,
  ad           text not null,
  aciklama     text,
  fiyat_kurus  integer not null check (fiyat_kurus >= 0),
  para_birimi  text not null default 'TRY' check (para_birimi = 'TRY'),
  sure_gun     integer not null check (sure_gun > 0),
  aktif        boolean not null default true,
  sira         integer not null default 0
);

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

create table public.payments (
  id              uuid primary key default gen_random_uuid(),
  veli_id         uuid references public.profiles (id) on delete set null,
  subscription_id uuid references public.subscriptions (id) on delete set null,
  tutar_kurus     integer not null check (tutar_kurus >= 0),
  para_birimi     text not null default 'TRY' check (para_birimi = 'TRY'),
  durum           text not null check (durum in ('beklemede', 'basarili', 'basarisiz', 'iade')),
  saglayici       text not null default 'manuel',
  saglayici_ref   text,
  aciklama        text,
  created_at      timestamptz not null default now()
);

-- Core: iletişim tercihleri (20261007000010 ile aynı sütunlar ve kısıtlar)
create table public.iletisim_tercihleri (
  veli_id         uuid not null references public.profiles (id) on delete cascade,
  kanal           text not null,
  izin            boolean not null,
  kaynak          text not null default 'admin',
  guncelleyen_id  uuid references public.profiles (id) on delete set null,
  updated_at      timestamptz not null default now(),
  primary key (veli_id, kanal),
  constraint iletisim_tercihleri_kanal_check
    check (kanal in ('eposta', 'push', 'sms', 'uygulama_ici')),
  constraint iletisim_tercihleri_kaynak_check
    check (kaynak in ('veli', 'admin', 'web_form', 'sistem'))
);

-- Core: deneme dönemleri (20261018010000 ile aynı sütunlar)
create table public.deneme_donemleri (
  id          uuid primary key default gen_random_uuid(),
  veli_id     uuid not null references public.profiles (id) on delete cascade,
  baslangic   timestamptz not null default now(),
  bitis       timestamptz not null,
  olusturan   uuid references public.profiles (id) on delete set null,
  created_at  timestamptz not null default now(),
  constraint deneme_bitis_sonra check (bitis > baslangic)
);

-- Landing adayı ve deneme ön kaydı: 20261027 tetikleyicileri ve geri doldurması yalnız tablo + sütunlara bakar
create table public.veli_adaylari (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now()
);

create table public.deneme_sinavi_on_kayitlari (
  id        uuid primary key default gen_random_uuid(),
  olusturma timestamptz not null default now()
);
