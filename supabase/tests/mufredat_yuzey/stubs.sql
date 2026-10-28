-- Müfredat yüzey testi için minimum Supabase + şema taklidi (PGlite).
-- Zincirin tamamı çalışmaz (GÖR-009); yalnız WP1/WP2 migration'larının
-- dokunduğu nesnelerin çağrı sözleşmesi kurulur. Kopyalar:
--   my_sinif()        ← 20260927000080_sinif_sorgu_ve_veli_degisikligi.sql (birebir)
--   question_revisions← 20260927000110_soru_revizyon_gecmisi.sql (birebir DDL)
--   require_admin / is_admin ← 20260920000900 (aynı desen)
--   questions RLS     ← 20261011000000 (questions_select_approved) + 20260920000300 (dogru_sik gizli)

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin; end if;
end
$$;

grant usage on schema public to anon, authenticated, service_role;
create schema if not exists auth;
grant usage on schema auth to anon, authenticated, service_role;

create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid
$$;

-- profiles (rol + sınıf)
create table public.profiles (
  id         uuid primary key,
  role       text not null default 'ogrenci' check (role in ('veli', 'ogrenci', 'admin')),
  sinif      smallint,
  full_name  text,
  parent_id  uuid
);
alter table public.profiles enable row level security;
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles for select to authenticated
  using (id = (select auth.uid()));
revoke all on public.profiles from public, anon, authenticated;
grant select on public.profiles to authenticated;

create or replace function public.my_sinif()
returns smallint
language sql
stable security definer
set search_path = ''
as $function$
  select sinif from public.profiles where id = (select auth.uid());
$function$;

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
    raise exception 'Yetkisiz erişim' using errcode = '42501';
  end if;
end;
$$;

-- Gerçek imza: 20260920000900 (p_islem text, p_detay jsonb)
create table public.admin_audit_log (
  id bigint generated always as identity primary key,
  islem text not null,
  detay jsonb not null default '{}'::jsonb
);
create or replace function public.log_admin_action(p_islem text, p_detay jsonb default '{}'::jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.admin_audit_log (islem, detay) values (p_islem, coalesce(p_detay, '{}'::jsonb));
end;
$$;

-- questions: canlı şemanın ilgili kolonları (sinif NOT NULL, kazanim kolonları 20261047)
create table public.questions (
  id                 uuid primary key default gen_random_uuid(),
  okul               text not null default 'ilkokul',
  sinif              smallint not null,
  ders               text not null,
  konu               text not null,
  alt_konu           text,
  zorluk             smallint not null default 1 check (zorluk between 1 and 3),
  soru_metni         text not null,
  siklar             jsonb not null,
  dogru_sik          text not null,
  onay_durumu        text not null default 'beklemede'
                       check (onay_durumu in ('beklemede', 'onaylandi', 'reddedildi')),
  kazanim_kodu       text,
  kazanim_metni      text,
  inceleme_gerekli   boolean not null default false,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

alter table public.questions enable row level security;
drop policy if exists questions_select_approved on public.questions;
create policy questions_select_approved on public.questions for select to authenticated
  using (onay_durumu = 'onaylandi' and sinif = public.my_sinif());

revoke all on public.questions from public, anon, authenticated;
-- Canlı yetki (katalog dökümü): sinif SELECT var; kazanim_kodu/kazanim_metni YOK.
grant select (id, okul, sinif, ders, konu, alt_konu, zorluk, soru_metni, siklar,
              onay_durumu, created_at, updated_at) on public.questions to authenticated;

-- user_answers (öğrenci kendi satırlarını okur)
create table public.user_answers (
  id                    uuid primary key default gen_random_uuid(),
  student_id            uuid not null references public.profiles (id) on delete cascade,
  question_id           uuid not null references public.questions (id) on delete cascade,
  secilen_sik           text not null,
  dogru_mu              boolean not null,
  sonraki_tekrar_tarihi timestamptz not null default now(),
  constraint user_answers_unique_pair unique (student_id, question_id)
);
alter table public.user_answers enable row level security;
drop policy if exists user_answers_select on public.user_answers;
create policy user_answers_select on public.user_answers for select to authenticated
  using (student_id = (select auth.uid()));
revoke all on public.user_answers from public, anon, authenticated;
grant select on public.user_answers to authenticated;

-- question_revisions (20260927000110 DDL birebir)
create table if not exists public.question_revisions (
  id              uuid primary key default gen_random_uuid(),
  question_id     uuid not null references public.questions (id) on delete cascade,
  revised_by      uuid references public.profiles (id) on delete set null,
  old_data        jsonb not null,
  degisen_alanlar text[] not null default '{}',
  changed_at      timestamptz not null default clock_timestamp()
);
create index if not exists question_revisions_question_time_idx
  on public.question_revisions (question_id, changed_at desc);
alter table public.question_revisions enable row level security;
drop policy if exists "question_revisions_select" on public.question_revisions;
create policy "question_revisions_select" on public.question_revisions for select to authenticated
  using (public.is_admin());
revoke all on public.question_revisions from anon;
revoke insert, update, delete on public.question_revisions from authenticated;
-- Supabase varsayılan yetkisi: public tablolarda authenticated SELECT (RLS süzer).
grant select on public.question_revisions to authenticated;
