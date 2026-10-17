-- Sınav katılım onayı testi için Supabase taklidi (PGlite).
-- Canlı zincirdeki ilgili nesneler birebir taşınır: consents (ESKİ tür kısıtıyla),
-- deneme_sinavlari, deneme_sinavi_katilimlari, identity_merge_log, deneme_ana_profil,
-- is_parent_of ve set_exam_marketing_consent (20261019000300 tanımı).
-- Tam şema değildir; yalnız bu migration'ın bağımlılıklarını taşır.

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin; end if;
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
  sinif       smallint,
  telefon     text,
  created_at  timestamptz not null default now()
);

create table if not exists public.identity_merge_log (
  kaynak_id uuid primary key,
  hedef_id  uuid not null
);

-- Canlı tanım (20261020001000_kimlik_profil_birlestirme.sql ile aynı gövde).
create or replace function public.deneme_ana_profil(p_ogrenci uuid)
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    (select l.hedef_id from public.identity_merge_log l where l.kaynak_id = p_ogrenci),
    p_ogrenci
  );
$$;

revoke execute on function public.deneme_ana_profil(uuid) from public, anon, authenticated, service_role;

-- Veli-çocuk bağı (initial_schema tanımının sınamaya yeten karşılığı).
create or replace function public.is_parent_of(p_student_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
     where p.id = p_student_id and p.parent_id = (select auth.uid())
  );
$$;

revoke execute on function public.is_parent_of(uuid) from public, anon;
grant  execute on function public.is_parent_of(uuid) to authenticated;

-- Canlı onay tablosu: tür kısıtı YALNIZCA üç değer kabul eder (migration öncesi durum).
create table public.consents (
  id          uuid primary key default gen_random_uuid(),
  cocuk_id    uuid not null references public.profiles (id) on delete cascade,
  veli_id     uuid references public.profiles (id) on delete set null,
  tur         text not null
                check (tur in ('aydinlatma_okundu', 'veli_acik_riza', 'veli_riza_geri_cekildi')),
  surum       text not null,
  created_at  timestamptz not null default clock_timestamp()
);

create table public.deneme_sinavlari (
  id               uuid primary key default gen_random_uuid(),
  ad               text not null,
  baslangic_zamani timestamptz not null,
  sure_dakika      integer not null default 40,
  siniflar         smallint[] not null default '{}',
  aktif            boolean not null default true
);

create table public.deneme_sinavi_katilimlari (
  id uuid not null default gen_random_uuid(),
  exam_id uuid not null,
  student_id uuid not null,
  veli_id uuid not null,
  telefon text not null,
  kayit_zamani timestamp with time zone not null default now(),
  constraint deneme_sinavi_katilimlari_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES deneme_sinavlari(id) ON DELETE CASCADE,
  constraint deneme_sinavi_katilimlari_exam_id_student_id_key UNIQUE (exam_id, student_id),
  constraint deneme_sinavi_katilimlari_pkey PRIMARY KEY (id),
  constraint deneme_sinavi_katilimlari_student_id_fkey FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE,
  constraint deneme_sinavi_katilimlari_telefon_uzunluk CHECK (((length(TRIM(BOTH FROM telefon)) >= 7) AND (length(TRIM(BOTH FROM telefon)) <= 20))),
  constraint deneme_sinavi_katilimlari_veli_id_fkey FOREIGN KEY (veli_id) REFERENCES profiles(id) ON DELETE CASCADE
);

-- Canlı tanım (20261019000300_canli_sema_eksik_nesneler.sql): pazarlama onayı (migration öncesi).
CREATE OR REPLACE FUNCTION public.set_exam_marketing_consent(p_cocuk_id uuid, p_surum text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null or not public.is_parent_of(p_cocuk_id) then
    raise exception 'Yalnızca çocuğun velisi bu onayı verebilir' using errcode = '42501';
  end if;
  if p_surum is null or length(trim(p_surum)) = 0 then
    raise exception 'Sürüm gerekli' using errcode = '22023';
  end if;

  insert into public.consents (cocuk_id, veli_id, tur, surum)
  values (p_cocuk_id, v_uid, 'sinav_pazarlama_izni', p_surum);
end;
$function$;
