-- Test harness: veli_destek_isaretleri migration'inin bagimliliklarinin minimal taklidi.
-- Yalnizca migration'in okudugu nesneler. Gercek tanimlar: auth.uid (initial_schema / Supabase),
-- is_parent_of (20260920000000), profiles (initial_schema), _veli_riza_durumu (20261013; consents
-- yerine test_riza tablosu kullanilir).

create schema if not exists auth;

create or replace function auth.uid() returns uuid
language sql stable as $$
  select (nullif(current_setting('request.jwt.claims', true), '')::json ->> 'sub')::uuid
$$;

do $$ begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin bypassrls; end if;
end $$;

grant usage on schema public, auth to anon, authenticated, service_role;

create table public.profiles (
  id         uuid primary key default gen_random_uuid(),
  role       text,
  parent_id  uuid,
  sinif      smallint,
  full_name  text
);

create or replace function public.is_parent_of(p_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = p_student_id and parent_id = (select auth.uid())
  );
$$;

-- Veli riza kaydi taklidi: 'verildi' | 'geri_cekildi'. Kayit yoksa _veli_riza_durumu 'yok' doner.
create table public.test_riza (
  id          uuid primary key default gen_random_uuid(),
  cocuk_id    uuid not null,
  durum       text not null,
  created_at  timestamptz not null default now()
);

create or replace function public._veli_riza_durumu(p_cocuk_id uuid)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select t.durum from public.test_riza t
      where t.cocuk_id = p_cocuk_id
      order by t.created_at desc, t.id desc
      limit 1),
    'yok');
$$;
