-- Test harness: Supabase'in gerekli parçalarının hafif taklidi.
-- Gerçek tanımlar: 20260920000000 (profiles, is_parent_of, current_user_role),
-- 20260920000900 (is_admin, log_admin_action), 20260920000700 (xp_events),
-- 20260920000100/800 (award_xp_and_streak). Burada yalnızca çağrı sözleşmesi taklit edilir:
-- award_xp_and_streak zorluk 1 + xp_ver=true → 10 XP, xp_ver=false → 0 XP (ve çağrı kaydı).

create schema if not exists auth;
create table if not exists auth.users (
  id uuid primary key default gen_random_uuid(),
  email text,
  raw_user_meta_data jsonb not null default '{}'::jsonb
);

-- Supabase'in gerçek auth.uid() tanımı: JWT 'sub' talebi
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
grant select on auth.users to service_role;
-- Supabase varsayılan yetkileri: yeni tablo/fonksiyonlar anon ve authenticated'a açık gelir.
-- Migration'ın REVOKE'ları bu varsayılanı kapatmalı; test bunu doğrular.
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;

create or replace function public.set_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin new.updated_at := now(); return new; end $$;

create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  role        text not null check (role in ('veli', 'ogrenci', 'admin', 'ogretmen')),
  parent_id   uuid references public.profiles (id) on delete set null,
  full_name   text,
  sinif       smallint check (sinif between 1 and 12),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create or replace function public.current_user_role() returns text
language sql stable security definer set search_path = '' as $$
  select role from public.profiles where id = (select auth.uid());
$$;

create or replace function public.is_parent_of(p_student_id uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles
                 where id = p_student_id and parent_id = (select auth.uid()));
$$;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles
                 where id = (select auth.uid()) and role = 'admin');
$$;

create table public.admin_audit_log (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid,
  islem text not null,
  detay jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.log_admin_action(p_islem text, p_detay jsonb default '{}'::jsonb)
returns void language sql security definer set search_path = '' as $$
  insert into public.admin_audit_log (admin_id, islem, detay)
  values ((select auth.uid()), p_islem, coalesce(p_detay, '{}'::jsonb));
$$;
revoke execute on function public.log_admin_action(text, jsonb) from public, anon, authenticated;

-- XP çağrılarını kaydeden taklit
create table public.stub_xp_cagrilari (
  id bigserial primary key,
  student_id uuid not null,
  zorluk smallint not null,
  xp_ver boolean not null
);

create or replace function public.award_xp_and_streak(p_student_id uuid, p_zorluk smallint, p_xp_ver boolean default true)
returns jsonb language plpgsql security definer set search_path = '' as $$
begin
  insert into public.stub_xp_cagrilari (student_id, zorluk, xp_ver) values (p_student_id, p_zorluk, p_xp_ver);
  return jsonb_build_object('kazanilan_xp',
    case when p_xp_ver then (case p_zorluk when 1 then 10 when 2 then 20 when 3 then 30 end) else 0 end);
end $$;
revoke execute on function public.award_xp_and_streak(uuid, smallint, boolean) from public, anon, authenticated;

