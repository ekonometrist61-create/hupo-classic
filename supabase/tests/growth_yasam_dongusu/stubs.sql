-- Test harness: Growth yaşam döngüsü migration'ının bağımlılıklarının minimal taklidi.
-- Müşteri 360 stub'larıyla aynı tanımlar (musteri_360/stubs.sql) + user_answers ve parent_link_codes.
-- Gerçek tanımlar Hupolingo çekirdeğindedir; burada yalnızca okunan/yazılan sütunlar bulunur.

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
grant select on auth.users to service_role;
-- Supabase varsayılan yetkileri: yeni tablo/fonksiyon/sequence anon ve authenticated'a açık gelir.
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;

create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  role        text,
  parent_id   uuid references public.profiles (id) on delete set null,
  full_name   text,
  username    text,
  sinif       smallint,
  created_at  timestamptz not null default now()
);

-- Admin kontrolü: 20261027 admin RPC'leri çalışma anında çağırır (bu testte admin RPC yok).
create or replace function public.require_admin() returns void
language plpgsql stable security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.profiles where id = (select auth.uid()) and role = 'admin') then
    raise exception 'Yetkisiz' using errcode = '42501';
  end if;
end $$;

-- Arama deseni: 20261027 migration'ı arama metnini ILIKE deseni yapmak için çağırır.
create or replace function public._growth_like_desen(p_metin text) returns text
language sql immutable as $$
  select '%' || replace(replace(replace(btrim(p_metin), '\', '\\'), '%', '\%'), '_', '\_') || '%'
$$;

create table public.student_stats (
  student_id       uuid primary key references public.profiles (id) on delete cascade,
  xp               integer not null default 0,
  level            integer not null default 1,
  streak_count     integer not null default 0,
  last_active_date date
);

create table public.plans (
  kod         text primary key,
  ad          text not null,
  fiyat_kurus int not null,
  sure_gun    int not null,
  aktif       boolean not null default true,
  tip_kod     text not null default 'premium'
);

create table public.subscriptions (
  id            uuid primary key default gen_random_uuid(),
  veli_id       uuid,
  plan_kod      text,
  durum         text,
  baslangic     timestamptz default now(),
  bitis         timestamptz,
  saglayici     text,
  saglayici_ref text,
  created_at    timestamptz not null default now()
);

create table public.payments (
  id              uuid primary key default gen_random_uuid(),
  veli_id         uuid,
  subscription_id uuid,
  tutar_kurus     int,
  para_birimi     text not null default 'TRY',
  durum           text,
  saglayici       text not null default 'manuel',
  saglayici_ref   text,
  aciklama        text,
  created_at      timestamptz not null default now()
);

create table public.iletisim_tercihleri (
  veli_id    uuid not null,
  kanal      text not null,
  izin       boolean not null,
  kaynak     text not null default 'admin',
  updated_at timestamptz not null default now(),
  primary key (veli_id, kanal)
);

create table public.veli_adaylari (
  id              uuid primary key default gen_random_uuid(),
  email           text,
  ad              text,
  telefon         text,
  kaynak          text not null default 'web_form',
  asama           text not null default 'yeni',
  pazarlama_izni  boolean not null default false,
  veli_id         uuid,
  created_at      timestamptz not null default now()
);

create table public.deneme_sinavi_on_kayitlari (
  id             uuid primary key default gen_random_uuid(),
  exam_id        uuid,
  veli_ad        text,
  cocuk_ad       text,
  cocuk_ad_norm  text generated always as (lower(btrim(cocuk_ad))) stored,
  sinif          smallint,
  eposta         text,
  eposta_norm    text generated always as (lower(btrim(eposta))) stored,
  telefon        text,
  izin_eposta    boolean default false,
  izin_sms       boolean default false,
  izin_telefon   boolean default false,
  kvkk_surum     text,
  izin_surum     text,
  olusturma      timestamptz default now()
);

-- Cevap tablosu: submit_answer, soru başına tek satır tutar (on conflict do update).
create table public.user_answers (
  id               uuid primary key default gen_random_uuid(),
  student_id       uuid not null references public.profiles (id) on delete cascade,
  question_id      uuid not null,
  secilen_sik      text not null default 'A',
  dogru_mu         boolean not null default true,
  son_cevap_tarihi timestamptz not null default now(),
  created_at       timestamptz not null default now(),
  unique (student_id, question_id)
);

-- Eşleştirme kodu tablosu (20261016): veli başına tek kullanımlık kodlar.
create table public.parent_link_codes (
  kod                  text primary key,
  veli_id              uuid not null references public.profiles (id) on delete cascade,
  olusturuldu_at       timestamptz not null default now(),
  son_kullanma         timestamptz not null,
  kullanildi_at        timestamptz,
  kullanan_ogrenci_id  uuid references public.profiles (id) on delete set null
);
