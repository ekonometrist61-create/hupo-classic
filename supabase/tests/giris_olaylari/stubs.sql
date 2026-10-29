-- Test harness: giriş olayları ve çocuk kodu sınırının bağımlılıklarının minimal taklidi.
-- Gerçek migration dosyaları değiştirilmeden yüklenir. Yalnız okunan/yazılan sütunlar bulunur.
-- Fonksiyon gövdeleri (is_admin, require_admin, _veli_bagla_hata, veli_cocuk_sayisi) canlı tanımla birebir aynıdır.

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

-- pg_cron taklidi (yalnız schedule; test ortamında pg_extension'da pg_cron yoktur, dal atlanır)
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

-- Profil tablosu: yalnız bu testin okuduğu/yazdığı sütunlar
create table public.profiles (
  id                      uuid primary key references auth.users (id) on delete cascade,
  role                    text,
  full_name               text,
  parent_id               uuid references public.profiles (id) on delete set null,
  sinif                   smallint,
  sosyal_ozellikler_acik  boolean not null default false,
  arkadas_ekleme_acik     boolean not null default false
);

-- Kayıt sırasında profil oluşturma (gerçek projede handle_new_user; rol meta veriden gelir)
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, role, full_name)
  values (new.id, new.raw_user_meta_data ->> 'role', new.raw_user_meta_data ->> 'full_name');
  return new;
end $$;
create trigger auth_user_profil after insert on auth.users
  for each row execute function public.handle_new_user();

-- Canlı tanım: 20260920000900 (birebir)
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
revoke execute on function public.require_admin() from public, anon, authenticated;

-- Ayar tablosu (20260920001100 ile aynı anahtar/değer şeması)
create table public.app_settings (
  key         text primary key,
  value       jsonb not null,
  updated_at  timestamptz not null default now()
);

-- Çocuk bağlama kodları (sütunlar 20261019000300 canlı tanımından)
create table public.ogrenci_baglanti_kodlari (
  id            bigint generated always as identity primary key,
  kod           text not null,
  ogrenci_id    uuid not null references public.profiles (id) on delete cascade,
  son_gecerlilik timestamptz not null,
  kullanildi_at timestamptz,
  kullanan_veli uuid references public.profiles (id) on delete set null
);

-- Hatalı bağlama denemeleri (20261019000300 canlı tanımı)
create table public.veli_baglama_hatalari (
  id         bigint not null generated always as identity,
  veli_id    uuid not null,
  created_at timestamptz not null default now(),
  constraint veli_baglama_hatalari_pkey primary key (id),
  constraint veli_baglama_hatalari_veli_id_fkey foreign key (veli_id) references profiles (id) on delete cascade
);
create index veli_baglama_hatalari_veli_idx on public.veli_baglama_hatalari (veli_id, created_at desc);
revoke all on table public.veli_baglama_hatalari from public, anon, authenticated, service_role;
grant insert, select, update, delete, truncate, references, trigger, maintain on table public.veli_baglama_hatalari to service_role;

-- Canlı tanım: 20261019000300 (birebir)
CREATE OR REPLACE FUNCTION public._veli_bagla_hata(p_veli uuid, p_mesaj text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
begin
  insert into public.veli_baglama_hatalari (veli_id) values (p_veli);
  -- HTTP 200 ile döner (hata fırlatılmaz): başarısız deneme kaydı her koşulda kalıcı olsun.
  -- İstemci gövdedeki 'hata' alanına bakar.
  return jsonb_build_object(
    'code', 'P0001', 'message', p_mesaj, 'details', null, 'hint', null, 'hata', p_mesaj);
end;
$function$;

CREATE OR REPLACE FUNCTION public.veli_cocuk_sayisi(p_veli uuid)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select count(*)::integer from public.profiles
   where parent_id = p_veli and role = 'ogrenci';
$function$;
