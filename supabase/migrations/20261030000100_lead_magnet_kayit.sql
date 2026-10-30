-- =====================================================================
-- Lead magnet kaydı (hesapsız veli: e-posta + sınıf + ayrı pazarlama izni)
--   * Giriş gerektirmez. Yazım yalnızca service_role'den (Edge Function, captcha sonrası).
--   * Çocuk adı ve telefon TUTULMAZ. Pazarlama izni içerik şartı değildir.
--   * lead_magnet_izin_logu append-only: her gönderimde KVKK ve e-posta izni ayrı satır (ispat).
--   * dogrulandi_zaman: çift doğrulama gönderim motoru hazır olunca doldurulur; o zamana dek
--     izin_eposta=true olsa da pazarlama gönderimi YAPILMAZ (hukuk onayı + doğrulama bekler).
-- =====================================================================

set client_encoding = 'UTF8';

create table if not exists public.lead_magnet_kayitlari (
  id               uuid primary key default gen_random_uuid(),
  magnet           text not null check (magnet ~ '^[a-z0-9-]{3,60}$'),
  eposta           text not null check (char_length(eposta) between 5 and 254 and eposta like '%@%.%'),
  eposta_norm      text generated always as (lower(btrim(eposta))) stored,
  sinif            smallint not null check (sinif between 3 and 7),
  izin_eposta      boolean not null default false,
  kvkk_surum       text not null,
  izin_surum       text not null,
  kaynak           jsonb not null default '{}'::jsonb,
  dogrulandi_zaman timestamptz,
  olusturma        timestamptz not null default now(),
  guncelleme       timestamptz not null default now(),

  constraint lead_magnet_kayit_tekil unique (magnet, eposta_norm)
);

create index if not exists lead_magnet_kayit_eposta_idx
  on public.lead_magnet_kayitlari (eposta_norm);

create table if not exists public.lead_magnet_izin_logu (
  id         bigint generated always as identity primary key,
  kayit_id   uuid not null references public.lead_magnet_kayitlari (id) on delete cascade,
  tur        text not null check (tur in ('kvkk', 'eposta')),
  verildi    boolean not null,
  surum      text not null,
  zaman      timestamptz not null default now()
);

create index if not exists lead_magnet_izin_logu_kayit_idx
  on public.lead_magnet_izin_logu (kayit_id);

alter table public.lead_magnet_kayitlari enable row level security;
alter table public.lead_magnet_izin_logu enable row level security;

revoke all on table public.lead_magnet_kayitlari from public, anon, authenticated;
revoke all on table public.lead_magnet_izin_logu from public, anon, authenticated;
grant  select, insert, update on table public.lead_magnet_kayitlari to service_role;
grant  select, insert on table public.lead_magnet_izin_logu to service_role;

create or replace function public.lead_magnet_kayit_ekle(
  p_magnet      text,
  p_eposta      text,
  p_sinif       smallint,
  p_kvkk_onay   boolean,
  p_kvkk_surum  text,
  p_izin_surum  text,
  p_izin_eposta boolean,
  p_kaynak      jsonb
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id    uuid;
  v_eposta text := lower(btrim(coalesce(p_eposta, '')));
begin
  if p_kvkk_onay is distinct from true then
    raise exception 'KVKK aydınlatma onayı zorunlu' using errcode = '22023';
  end if;

  if p_sinif is null or p_sinif not between 3 and 7 then
    raise exception 'Geçerli bir sınıf seçin' using errcode = '22023';
  end if;

  insert into public.lead_magnet_kayitlari (
    magnet, eposta, sinif, izin_eposta, kvkk_surum, izin_surum, kaynak
  ) values (
    p_magnet, v_eposta, p_sinif, coalesce(p_izin_eposta, false),
    p_kvkk_surum, p_izin_surum, coalesce(p_kaynak, '{}'::jsonb)
  )
  on conflict (magnet, eposta_norm) do update set
    sinif       = excluded.sinif,
    -- Aynı kişi sonradan izni geri çekebilir: son beyan geçerli, geçmiş logda kalır.
    izin_eposta = excluded.izin_eposta,
    kvkk_surum  = excluded.kvkk_surum,
    izin_surum  = excluded.izin_surum,
    guncelleme  = now()
  returning id into v_id;

  insert into public.lead_magnet_izin_logu (kayit_id, tur, verildi, surum) values
    (v_id, 'kvkk',   true,                          p_kvkk_surum),
    (v_id, 'eposta', coalesce(p_izin_eposta, false), p_izin_surum);

  return v_id;
end;
$$;

revoke execute on function public.lead_magnet_kayit_ekle(text, text, smallint, boolean, text, text, boolean, jsonb)
  from public, anon, authenticated;
grant  execute on function public.lead_magnet_kayit_ekle(text, text, smallint, boolean, text, text, boolean, jsonb)
  to service_role;
