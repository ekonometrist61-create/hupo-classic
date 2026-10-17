-- Supabase ortamını taklit eden minimum iskelet (yalnızca test için).
-- Supabase gibi: public tablolarında anon/authenticated/service_role varsayılan yetkileri var;
-- migration'lar REVOKE ile daraltır. Bu, yetki testlerinin gerçekçi olmasını sağlar.
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

-- admin_role_and_payments / log: gerçek fonksiyonların imzası yeterli
create function public.require_admin() returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.profiles where id = auth.uid() and role = 'admin') then
    raise exception 'Yetkisiz' using errcode = '42501';
  end if;
end $$;

create function public.log_admin_action(p_tur text, p_detay jsonb) returns void
language plpgsql as $$ begin null; end $$;

-- 20260920000700_leagues_progress_notifications.sql içindeki notifications tablosunun birebir DDL'i
create table public.notifications (
  id          uuid primary key default gen_random_uuid(),
  alici_id    uuid not null references public.profiles (id) on delete cascade,
  tur         text not null check (tur in ('rozet', 'seviye', 'lig', 'bilgi')),
  baslik      text not null,
  mesaj       text not null,
  ikon        text not null default 'notifications',
  okundu      boolean not null default false,
  created_at  timestamptz not null default now()
);
create index notifications_alici_time_idx on public.notifications (alici_id, created_at desc);
create index notifications_unread_idx on public.notifications (alici_id) where okundu = false;
alter table public.notifications enable row level security;
create policy "notifications_select_own" on public.notifications for select to authenticated
  using (alici_id = (select auth.uid()));
revoke all on public.notifications from anon;
revoke insert, update, delete on public.notifications from authenticated;
