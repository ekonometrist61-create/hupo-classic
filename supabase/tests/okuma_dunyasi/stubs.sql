-- Test harness: Okuma Dünyası migration'larının bağımlılıklarının hafif taklidi.
-- Gerçek tanımlar: profiles / is_parent_of / current_user_role / student_stats (20260920000000),
-- is_admin / require_admin / log_admin_action (20260920000900), award_xp_and_streak (20260920000800),
-- subscriptions / _premium_kaynak / is_premium / _gating (20260920001100), deneme_donemleri (20261018010000),
-- consents / _veli_riza_durumu (20261013000000). Burada yalnızca çağrı sözleşmesi taklit edilir.

create schema if not exists auth;
create table if not exists auth.users (
  id uuid primary key default gen_random_uuid(),
  email text,
  raw_user_meta_data jsonb not null default '{}'::jsonb
);

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

create or replace function public.require_admin() returns void
language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then
    raise exception 'Bu işlem için admin yetkisi gerekir' using errcode = '42501';
  end if;
end $$;
revoke execute on function public.require_admin() from public, anon, authenticated;

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

-- Seri tablosu ve award_xp_and_streak taklidi (10/20/30 XP; seri mantığı gerçeğe paralel)
create table public.student_stats (
  student_id       uuid primary key references public.profiles (id) on delete cascade,
  xp               integer not null default 0,
  level            integer not null default 1,
  streak_count     integer not null default 0,
  last_active_date date,
  en_uzun_seri     integer not null default 0,
  seri_kalkani     integer not null default 0
);

create table public.stub_xp_cagrilari (
  id bigserial primary key,
  student_id uuid not null,
  zorluk smallint not null,
  xp_ver boolean not null,
  xp integer not null,
  created_at timestamptz not null default now()
);

create or replace function public.award_xp_and_streak(p_student_id uuid, p_zorluk smallint, p_xp_ver boolean default true)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_today date := (now() at time zone 'Europe/Istanbul')::date;
  v_xp integer := case p_zorluk when 1 then 10 when 2 then 20 when 3 then 30 end;
  s record;
  v_seri integer;
begin
  if v_xp is null then raise exception 'Geçersiz zorluk' using errcode = '22023'; end if;
  if not p_xp_ver then v_xp := 0; end if;
  insert into public.student_stats (student_id) values (p_student_id) on conflict do nothing;
  select * into s from public.student_stats where student_id = p_student_id for update;
  if s.last_active_date = v_today then v_seri := greatest(s.streak_count, 1);
  elsif s.last_active_date = v_today - 1 then v_seri := s.streak_count + 1;
  else v_seri := 1; end if;
  update public.student_stats
     set xp = xp + v_xp, level = ((xp + v_xp) / 100) + 1, streak_count = v_seri,
         last_active_date = v_today, en_uzun_seri = greatest(en_uzun_seri, v_seri)
   where student_id = p_student_id returning * into s;
  insert into public.stub_xp_cagrilari (student_id, zorluk, xp_ver, xp) values (p_student_id, p_zorluk, p_xp_ver, v_xp);
  return jsonb_build_object('kazanilan_xp', v_xp, 'xp', s.xp, 'level', s.level, 'streak_count', s.streak_count,
                            'last_active_date', s.last_active_date, 'seri_kalkani', s.seri_kalkani);
end $$;
revoke execute on function public.award_xp_and_streak(uuid, smallint, boolean) from public, anon, authenticated;

-- premium_gating / abonelik / deneme (gerçek gövdelerin aynısı)
create table public.app_settings (
  key text primary key,
  value jsonb not null
);
insert into public.app_settings (key, value) values
  ('premium_gating', '{"aktif": false, "ucretsiz_gunluk_soru": 20}'::jsonb);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  veli_id uuid not null references public.profiles (id) on delete cascade,
  plan_kod text not null default 'aylik',
  durum text not null default 'aktif',
  bitis timestamptz not null
);

create table public.deneme_donemleri (
  id uuid primary key default gen_random_uuid(),
  veli_id uuid not null references public.profiles (id) on delete cascade,
  baslangic timestamptz not null default now(),
  bitis timestamptz not null
);

create or replace function public._premium_kaynak(p_uid uuid)
returns table (sahip uuid, kaynak text, plan_kod text, bitis timestamptz)
language sql stable security definer set search_path = '' as $$
  with me as (select id, role, parent_id from public.profiles where id = p_uid),
  hedef as (
    select case when role = 'ogrenci' then parent_id else id end as sahip_id,
           case when role = 'ogrenci' then 'veli' else 'kendi' end as k
      from me where role in ('veli', 'ogrenci'))
  select h.sahip_id, h.k, s.plan_kod, s.bitis
    from hedef h join public.subscriptions s on s.veli_id = h.sahip_id
   where s.durum = 'aktif' and s.bitis > now()
   order by s.bitis desc limit 1;
$$;

create or replace function public.is_premium(p_uid uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles where id = p_uid and role = 'admin')
      or exists (select 1 from public._premium_kaynak(p_uid));
$$;

create or replace function public._gating()
returns table (aktif boolean, limit_gun integer)
language sql stable security definer set search_path = '' as $$
  select coalesce((select (value ->> 'aktif')::boolean from public.app_settings where key = 'premium_gating'), false),
         coalesce((select (value ->> 'ucretsiz_gunluk_soru')::integer from public.app_settings where key = 'premium_gating'), 20);
$$;

create or replace function public._deneme_sahibi(p_uid uuid)
returns uuid language sql stable security definer set search_path = '' as $$
  select case when p.role = 'ogrenci' then p.parent_id else p.id end
    from public.profiles p where p.id = p_uid and p.role in ('veli', 'ogrenci');
$$;

create or replace function public._deneme_aktif(p_uid uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.deneme_donemleri d
                  where d.veli_id = public._deneme_sahibi(p_uid) and d.bitis > now());
$$;

revoke execute on function public._premium_kaynak(uuid), public.is_premium(uuid), public._gating(),
  public._deneme_sahibi(uuid), public._deneme_aktif(uuid) from public, anon, authenticated;

-- Veli rızası (20261013000000 gövdesi aynen)
create table public.consents (
  id uuid primary key default gen_random_uuid(),
  cocuk_id uuid,
  tur text not null,
  created_at timestamptz not null default now()
);

create or replace function public._veli_riza_durumu(p_cocuk_id uuid)
returns text language plpgsql stable security definer set search_path = '' as $$
declare v_tur text;
begin
  select c.tur into v_tur from public.consents c
   where c.cocuk_id = p_cocuk_id and c.tur in ('veli_acik_riza', 'veli_riza_geri_cekildi')
   order by c.created_at desc, c.id desc limit 1;
  return case when v_tur is null then 'yok' when v_tur = 'veli_acik_riza' then 'verildi' else 'geri_cekildi' end;
end $$;
revoke execute on function public._veli_riza_durumu(uuid) from public, anon, authenticated;
