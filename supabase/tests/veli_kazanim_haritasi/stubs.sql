-- Test harness: veli_kazanim_haritasi migration'ının bağımlılıklarının minimal taklidi.
-- Yalnızca migration'ın okuduğu nesneler. Gerçek tanımlar: auth.uid (initial_schema / Supabase),
-- is_parent_of (20260920000000), user_answers (tekrar_sayisi dahil, 20260920000000),
-- answer_events (20260920000200), questions (20260920000000), mufredat_* (20261083 / 20261085),
-- _veli_riza_durumu (20261013; consents yerine test_riza tablosu kullanılır).

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

create table public.questions (
  id             uuid primary key default gen_random_uuid(),
  ders           text not null,
  sinif          smallint not null,
  konu           text,
  kazanim_kodu   text,
  kazanim_metni  text,
  onay_durumu    text not null default 'beklemede'
);

create table public.answer_events (
  id           uuid primary key default gen_random_uuid(),
  student_id   uuid not null,
  question_id  uuid not null,
  dogru_mu     boolean not null,
  sure_ms      integer,
  created_at   timestamptz not null default now()
);

create table public.user_answers (
  id                     uuid primary key default gen_random_uuid(),
  student_id             uuid not null,
  question_id            uuid not null,
  dogru_mu               boolean not null,
  deneme_sayisi          integer not null default 1 check (deneme_sayisi >= 1),
  dogru_sayisi           integer not null default 0 check (dogru_sayisi >= 0),
  tekrar_sayisi          integer not null default 0 check (tekrar_sayisi >= 0),
  son_cevap_tarihi       timestamptz not null default now(),
  sonraki_tekrar_tarihi  timestamptz not null default now(),
  constraint user_answers_unique_pair unique (student_id, question_id),
  constraint user_answers_dogru_le_deneme check (dogru_sayisi <= deneme_sayisi)
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

-- Veli rıza kaydı taklidi: 'verildi' | 'geri_cekildi'. Kayıt yoksa _veli_riza_durumu 'yok' döner.
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

create table public.mufredat_ders_eslesme (
  soru_ders      text primary key,
  mufredat_ders  text not null
);

-- Kazanım özeti: gerçekte view (20261085); burada tablo. Kolonlar view ile aynı.
create table public.mufredat_kazanim_ozet (
  ders           text not null,
  sinif          smallint not null,
  kazanim_kodu   text not null,
  ilk_hafta      smallint not null,
  son_hafta      smallint not null,
  kazanim_metni  text,
  unite_tema     text,
  konu           text,
  primary key (ders, sinif, kazanim_kodu)
);

create or replace function public.mufredat_bugun_hafta(p_tarih date default null)
returns smallint
language sql
stable
set search_path = ''
as $$
  select 12::smallint
$$;
