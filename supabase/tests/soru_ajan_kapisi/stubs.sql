-- Soru ajan kapısı testi için taklitler: yalnız migration'ın bağımlı olduğu nesneler.
-- Gerçek şema değildir; kapının kendi mantığı gerçek migration dosyasından çalışır.
create role anon nologin;
create role authenticated nologin;
create role service_role nologin;

create schema if not exists auth;

create or replace function public.require_admin()
returns void language plpgsql as $$ begin null; end; $$;

create or replace function public.log_admin_action(p_islem text, p_detay jsonb)
returns void language plpgsql as $$ begin null; end; $$;

create or replace function public.tr_normalize(p text)
returns text language sql immutable as $$ select lower(p) $$;

create table public.questions (
  id               uuid primary key default gen_random_uuid(),
  okul             text not null default 'ilkokul',
  sinif            smallint not null default 4,
  ders             text not null default 'Matematik',
  konu             text not null default 'Bölme',
  alt_konu         text,
  zorluk           smallint not null default 1 check (zorluk between 1 and 3),
  soru_metni       text not null default 'Soru',
  siklar           jsonb not null default '{"A":"1","B":"2"}',
  dogru_sik        text not null default 'A',
  cozum_adimlari   jsonb not null default '[]',
  onay_durumu      text not null default 'beklemede'
                     check (onay_durumu in ('beklemede', 'onaylandi', 'reddedildi')),
  inceleme_gerekli boolean not null default false,
  created_by       uuid,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

-- Gerçek tanım: 20260920000900_admin_role_and_payments.sql (değişmeden kopyalandı).
create or replace function public.admin_set_question_status(p_ids uuid[], p_durum text)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_adet integer;
begin
  perform public.require_admin();
  if p_durum not in ('beklemede', 'onaylandi', 'reddedildi') then
    raise exception 'Geçersiz durum' using errcode = '22023';
  end if;
  update public.questions set onay_durumu = p_durum where id = any (coalesce(p_ids, '{}'));
  get diagnostics v_adet = row_count;
  perform public.log_admin_action('soru_durumu_degisti',
    jsonb_build_object('durum', p_durum, 'adet', v_adet));
  return v_adet;
end;
$$;

create table public.question_reports (
  id          uuid primary key default gen_random_uuid(),
  question_id uuid references public.questions (id) on delete cascade,
  durum       text not null default 'acik'
);

grant usage on schema public to anon, authenticated, service_role;
grant select, insert, update, delete on all tables in schema public to authenticated, service_role;
