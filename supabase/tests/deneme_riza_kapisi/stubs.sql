-- Deneme veli rıza kapısı testi için Supabase ve şema taklitleri (PGlite).
-- Gerçek migration'lar bu dosyanın ÜZERİNE uygulanır: 20261013000000 (_veli_riza_durumu),
-- 20261138000000 (_deneme_puan_gorunur), 20261150000000 (rıza kapısı, test edilen).
-- Bu dosya yalnızca bu zincirin okuduğu nesnelerin asgari kopyasıdır; tam şema değildir.
--   auth.uid                : Supabase taklidi (request.jwt.claims -> sub)
--   profiles                : 20260920000000 + telefon/sinif (asgari kolonlar)
--   is_parent_of            : 20260920000000 tanımının birebir gövdesi
--   deneme_ana_profil       : 20261020001000 tanımının birebir gövdesi
--   consents                : 20260920000800 tanımı (tür kısıtı ESKİ hali: 3 değer)
--   deneme_sinavlari        : 20260927000140 kolonlarının asgari hali
--   deneme_sinavi_denemeleri: 20260927000140 + teslim_turu (20261020000900)
--   deneme_sinavi_katilimlari: 20261019 / 20261040 kolonları (get_upcoming'in left join'i)

create schema if not exists auth;

create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select (nullif(current_setting('request.jwt.claims', true), '')::json ->> 'sub')::uuid
$$;

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then create role anon nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then create role authenticated nologin; end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then create role service_role nologin bypassrls; end if;
end
$$;

grant usage on schema public, auth to anon, authenticated, service_role;

create table public.profiles (
  id          uuid primary key,
  role        text not null default 'veli',
  full_name   text,
  parent_id   uuid references public.profiles (id) on delete set null,
  sinif       smallint,
  telefon     text,
  created_at  timestamptz not null default now()
);

create table public.identity_merge_log (
  kaynak_id uuid primary key,
  hedef_id  uuid not null
);

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

revoke execute on function public.is_parent_of(uuid) from public, anon;
grant  execute on function public.is_parent_of(uuid) to authenticated;

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

create table public.deneme_sinavi_denemeleri (
  id            uuid primary key default gen_random_uuid(),
  exam_id       uuid not null references public.deneme_sinavlari (id) on delete cascade,
  student_id    uuid not null references public.profiles (id) on delete cascade,
  sinif         smallint not null,
  puan          numeric not null default 0,
  dogru_sayisi  smallint not null default 0,
  yanlis_sayisi smallint not null default 0,
  bos_sayisi    smallint not null default 0,
  bitis_zamani  timestamptz,
  teslim_turu   text check (teslim_turu in ('elle', 'sure_doldu', 'otomatik')),
  created_at    timestamptz not null default now(),
  unique (exam_id, student_id)
);

create table public.deneme_sinavi_katilimlari (
  id           uuid not null default gen_random_uuid(),
  exam_id      uuid not null,
  student_id   uuid not null,
  veli_id      uuid not null,
  telefon      text not null,
  kayit_zamani timestamp with time zone not null default now(),
  constraint deneme_sinavi_katilimlari_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES deneme_sinavlari(id) ON DELETE CASCADE,
  constraint deneme_sinavi_katilimlari_exam_id_student_id_key UNIQUE (exam_id, student_id),
  constraint deneme_sinavi_katilimlari_pkey PRIMARY KEY (id),
  constraint deneme_sinavi_katilimlari_student_id_fkey FOREIGN KEY (student_id) REFERENCES profiles(id) ON DELETE CASCADE,
  constraint deneme_sinavi_katilimlari_veli_id_fkey FOREIGN KEY (veli_id) REFERENCES profiles(id) ON DELETE CASCADE
);
