-- Test harness: öğretmen sınıf raporu migration'larının bağımlılıklarının minimal taklidi.
-- Yalnızca migration'ların okuduğu/yazdığı nesneler. Gerçek tanımlar: profiles, questions,
-- user_answers (initial_schema), is_admin / require_admin / set_updated_at (Hupolingo çekirdeği).
-- questions FK'si bilerek atlanır: rapor yalnızca user_answers'ı toplar.

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
  id          uuid primary key default gen_random_uuid(),
  role        text,
  full_name   text,
  created_at  timestamptz not null default now()
);

create or replace function public.set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.profiles
     where id = (select auth.uid()) and role = 'admin'
  );
$$;

create or replace function public.require_admin() returns void
language plpgsql stable security definer set search_path = '' as $$
begin
  if not public.is_admin() then
    raise exception 'Bu işlem için admin yetkisi gerekir' using errcode = '42501';
  end if;
end $$;

create table public.user_answers (
  id                     uuid primary key default gen_random_uuid(),
  student_id             uuid not null references public.profiles (id) on delete cascade,
  question_id            uuid not null,
  dogru_mu               boolean not null,
  deneme_sayisi          integer not null default 1 check (deneme_sayisi >= 1),
  dogru_sayisi           integer not null default 0 check (dogru_sayisi >= 0),
  son_cevap_tarihi       timestamptz not null default now(),
  sonraki_tekrar_tarihi  timestamptz not null default now(),
  constraint user_answers_unique_pair unique (student_id, question_id),
  constraint user_answers_dogru_le_deneme check (dogru_sayisi <= deneme_sayisi)
);
