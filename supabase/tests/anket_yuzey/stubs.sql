-- Anket yüzey testi için minimum Supabase taklidi (PGlite).
-- Gerçek bağımlılıkların yalnız çağrı sözleşmesini taşır; tam şema değildir.
-- Kaynak: profiles (rol + çocuk bağı), auth.uid() (oturum), require_admin, log_admin_action.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
end
$$;

create schema if not exists auth;

create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

create table if not exists public.profiles (
  id          uuid primary key,
  role        text not null default 'veli',
  full_name   text,
  parent_id   uuid references public.profiles (id) on delete set null,
  created_at  timestamptz not null default now()
);

create or replace function public.require_admin()
returns void
language plpgsql
as $$
begin
  null;  -- test yalnız veli ve kısıt davranışını sınar; admin kapısı ayrı testlerde
end;
$$;

create or replace function public.log_admin_action(p_tur text, p_detay jsonb default '{}'::jsonb)
returns void
language plpgsql
as $$
begin
  null;
end;
$$;
