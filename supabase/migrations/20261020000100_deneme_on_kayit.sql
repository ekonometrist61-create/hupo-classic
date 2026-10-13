-- =====================================================================
-- Herkese açık deneme sınavı ön kaydı (kayıtsız veliyi müşteriye çevirme kanalı)
--   * Giriş gerektirmez. Yazım yalnızca service_role'den (Edge Function, captcha doğrulandıktan sonra).
--   * İzinler kanal bazında ayrıdır: e-posta, SMS, telefon. KVKK aydınlatma sürümü saklanır.
--   * deneme_on_kayit_izin_logu append-only'dir: KVKK ispatı için her izin olayı ayrı satır.
-- =====================================================================

set client_encoding = 'UTF8';

create table if not exists public.deneme_sinavi_on_kayitlari (
  id              uuid primary key default gen_random_uuid(),
  exam_id         uuid not null references public.deneme_sinavlari (id) on delete cascade,
  veli_ad         text not null check (char_length(btrim(veli_ad)) between 2 and 120),
  cocuk_ad        text not null check (char_length(btrim(cocuk_ad)) between 2 and 120),
  cocuk_ad_norm   text generated always as (lower(btrim(cocuk_ad))) stored,
  sinif           smallint not null check (sinif between 1 and 12),
  eposta          text not null check (char_length(eposta) between 5 and 254 and eposta like '%@%.%'),
  eposta_norm     text generated always as (lower(btrim(eposta))) stored,
  telefon         text not null check (telefon ~ '^\+[0-9]{10,15}$'),
  izin_eposta     boolean not null default false,
  izin_sms        boolean not null default false,
  izin_telefon    boolean not null default false,
  kvkk_surum      text not null,
  izin_surum      text not null,
  durum           text not null default 'beklemede'
                  check (durum in ('beklemede', 'hesap_baglandi', 'iptal')),
  olusturma       timestamptz not null default now(),
  guncelleme      timestamptz not null default now(),

  constraint deneme_on_kayit_tekil unique (exam_id, eposta_norm, sinif, cocuk_ad_norm)
);

create index if not exists deneme_on_kayit_telefon_idx
  on public.deneme_sinavi_on_kayitlari (telefon);
create index if not exists deneme_on_kayit_eposta_idx
  on public.deneme_sinavi_on_kayitlari (eposta_norm);

create table if not exists public.deneme_on_kayit_izin_logu (
  id          bigint generated always as identity primary key,
  on_kayit_id uuid not null references public.deneme_sinavi_on_kayitlari (id) on delete cascade,
  tur         text not null check (tur in ('kvkk', 'eposta', 'sms', 'telefon')),
  verildi     boolean not null,
  surum       text not null,
  zaman       timestamptz not null default now()
);

create index if not exists deneme_on_kayit_izin_logu_kayit_idx
  on public.deneme_on_kayit_izin_logu (on_kayit_id);

alter table public.deneme_sinavi_on_kayitlari enable row level security;
alter table public.deneme_on_kayit_izin_logu enable row level security;

revoke all on table public.deneme_sinavi_on_kayitlari from public, anon, authenticated;
revoke all on table public.deneme_on_kayit_izin_logu from public, anon, authenticated;
grant  select, insert, update on table public.deneme_sinavi_on_kayitlari to service_role;
grant  select, insert on table public.deneme_on_kayit_izin_logu to service_role;

create or replace function public.deneme_on_kayit_ekle(
  p_exam_id       uuid,
  p_veli_ad       text,
  p_cocuk_ad      text,
  p_sinif         smallint,
  p_eposta        text,
  p_telefon       text,
  p_kvkk_onay     boolean,
  p_kvkk_surum    text,
  p_izin_surum    text,
  p_izin_eposta   boolean,
  p_izin_sms      boolean,
  p_izin_telefon  boolean
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_exam  public.deneme_sinavlari%rowtype;
  v_tel   text := regexp_replace(coalesce(p_telefon, ''), '[^0-9+]', '', 'g');
  v_id    uuid;
  v_eposta_ham text := lower(btrim(coalesce(p_eposta, '')));
begin
  if p_kvkk_onay is distinct from true then
    raise exception 'KVKK aydınlatma onayı zorunlu' using errcode = '22023';
  end if;

  select * into v_exam from public.deneme_sinavlari where id = p_exam_id;
  if not found or not v_exam.aktif or now() >= v_exam.baslangic_zamani then
    raise exception 'Bu sınav için kayıt kapalı' using errcode = 'P0002';
  end if;

  if p_sinif is null or not (p_sinif = any (v_exam.siniflar)) then
    raise exception 'Bu sınav seçilen sınıf için açık değil' using errcode = '22023';
  end if;

  if v_tel ~ '^0[0-9]{10}$' then v_tel := '+90' || substr(v_tel, 2); end if;
  if v_tel ~ '^90[0-9]{10}$' then v_tel := '+' || v_tel; end if;
  if v_tel ~ '^5[0-9]{9}$' then v_tel := '+90' || v_tel; end if;
  if v_tel !~ '^\+[0-9]{10,15}$' then
    raise exception 'Geçerli bir telefon numarası girin' using errcode = '22023';
  end if;

  insert into public.deneme_sinavi_on_kayitlari (
    exam_id, veli_ad, cocuk_ad, sinif, eposta, telefon,
    izin_eposta, izin_sms, izin_telefon, kvkk_surum, izin_surum
  ) values (
    p_exam_id, btrim(p_veli_ad), btrim(p_cocuk_ad), p_sinif, v_eposta_ham, v_tel,
    coalesce(p_izin_eposta, false), coalesce(p_izin_sms, false), coalesce(p_izin_telefon, false),
    p_kvkk_surum, p_izin_surum
  )
  on conflict (exam_id, eposta_norm, sinif, cocuk_ad_norm) do update set
    veli_ad      = excluded.veli_ad,
    telefon      = excluded.telefon,
    izin_eposta  = excluded.izin_eposta,
    izin_sms     = excluded.izin_sms,
    izin_telefon = excluded.izin_telefon,
    kvkk_surum   = excluded.kvkk_surum,
    izin_surum   = excluded.izin_surum,
    guncelleme   = now()
  returning id into v_id;

  insert into public.deneme_on_kayit_izin_logu (on_kayit_id, tur, verildi, surum) values
    (v_id, 'kvkk',    true,                          p_kvkk_surum),
    (v_id, 'eposta',  coalesce(p_izin_eposta, false), p_izin_surum),
    (v_id, 'sms',     coalesce(p_izin_sms, false),    p_izin_surum),
    (v_id, 'telefon', coalesce(p_izin_telefon, false), p_izin_surum);

  return v_id;
end;
$$;

revoke execute on function public.deneme_on_kayit_ekle(uuid, text, text, smallint, text, text, boolean, text, text, boolean, boolean, boolean)
  from public, anon, authenticated;
grant  execute on function public.deneme_on_kayit_ekle(uuid, text, text, smallint, text, text, boolean, text, text, boolean, boolean, boolean)
  to service_role;
