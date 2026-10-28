-- Test harness: growth analitik huni migration'ının bağımlılıklarının minimal taklidi.
-- Yalnızca 20261014000000 (growth core), 20261028000000 (web olayları) ve 20261105000000 (bu paket)
-- dosyalarının okuduğu/yazdığı sütunlar. Gerçek Hupolingo tabloları bunlar değildir.

-- Supabase auth şeması
create schema if not exists auth;
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
-- Supabase varsayılan yetkileri: yeni tablo/fonksiyon anon ve authenticated'a açık gelir.
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;

create table public.profiles (
  id         uuid primary key default gen_random_uuid(),
  role       text,
  parent_id  uuid references public.profiles (id) on delete set null,
  full_name  text,
  username   text,
  sinif      smallint,
  created_at timestamptz not null default now()
);

-- Gerçek tanım: 20260920000900_admin_role_and_payments.sql (aynen).
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
     where id = (select auth.uid()) and role = 'admin'
  );
$$;

create or replace function public.require_admin()
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_admin() then
    raise exception 'Bu işlem için admin yetkisi gerekir' using errcode = '42501';
  end if;
end;
$$;

revoke execute on function public.is_admin() from public, anon;
grant  execute on function public.is_admin() to authenticated;
revoke execute on function public.require_admin() from public, anon, authenticated;

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

-- Ödeme tablosu (20260920000900): huni "ücretli" ve UTM "ücretli" adımları bunu okur.
create table public.payments (
  id              uuid primary key default gen_random_uuid(),
  veli_id         uuid references public.profiles (id) on delete set null,
  subscription_id uuid,
  tutar_kurus     integer not null check (tutar_kurus >= 0),
  para_birimi     text not null default 'TRY',
  durum           text not null check (durum in ('beklemede', 'basarili', 'basarisiz', 'iade')),
  saglayici       text not null default 'manuel',
  saglayici_ref   text,
  aciklama        text,
  created_at      timestamptz not null default now()
);

create table public.questions (
  id uuid primary key default gen_random_uuid()
);

-- user_answers (20260920000000): yalnız huni/analitik okumalarının kullandığı sütunlar.
create table public.user_answers (
  id                     uuid primary key default gen_random_uuid(),
  student_id             uuid not null references public.profiles (id) on delete cascade,
  question_id            uuid not null references public.questions (id) on delete cascade,
  secilen_sik            text not null default 'A',
  dogru_mu               boolean not null,
  son_sure_ms            integer,
  son_cevap_tarihi       timestamptz not null default now(),
  deneme_sayisi          integer not null default 1,
  dogru_sayisi           integer not null default 0,
  sonraki_tekrar_tarihi  timestamptz not null default now(),
  created_at             timestamptz not null default now()
);

-- answer_events (20260920000200): her cevabın zaman damgalı kaydı. Bu testte trigger yok; satırlar doğrudan yazılır.
create table public.answer_events (
  id           uuid primary key default gen_random_uuid(),
  student_id   uuid not null references public.profiles (id) on delete cascade,
  question_id  uuid not null references public.questions (id) on delete cascade,
  dogru_mu     boolean not null,
  sure_ms      integer,
  created_at   timestamptz not null default now()
);
