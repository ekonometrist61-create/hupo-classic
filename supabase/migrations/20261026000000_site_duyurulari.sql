-- =====================================================================
--  Web sitesi duyuruları (landing sayfası üst şeridi)
--  Tablo : public.duyurular
--  RPC   : get_aktif_duyuru()          — anon/authenticated; en yeni aktif ve süresi
--                                        dolmamış duyuruyu döndürür (yoksa null)
--          admin_list_duyurular()      — yönetici listesi (son 100)
--          admin_save_duyuru(...)      — yeni oluşturur (p_id null) veya düzenler
--  Not   : Bitiş tarihi geçen duyuru otomatik pasife dönmez; herkese açık okuma
--          yalnızca süresi dolmamış aktif duyuruyu verir.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Tablo
-- ---------------------------------------------------------------------
create table if not exists public.duyurular (
  id          uuid primary key default gen_random_uuid(),
  baslik      text not null check (char_length(trim(baslik)) between 1 and 120),
  metin       text not null check (char_length(trim(metin)) between 1 and 500),
  aktif       boolean not null default false,
  bitis_at    timestamptz,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table public.duyurular enable row level security;
-- Politika yok: tabloya yalnızca aşağıdaki security definer RPC'ler erişir.
revoke all on public.duyurular from anon, authenticated;

-- ---------------------------------------------------------------------
-- 2. get_aktif_duyuru — herkese açık okuma (landing üst şeridi)
-- ---------------------------------------------------------------------
create or replace function public.get_aktif_duyuru()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select (
    select jsonb_build_object(
             'id', d.id,
             'baslik', d.baslik,
             'metin', d.metin,
             'bitis_at', d.bitis_at)
      from public.duyurular d
     where d.aktif
       and (d.bitis_at is null or d.bitis_at > now())
     order by d.created_at desc, d.id
     limit 1
  );
$$;

comment on function public.get_aktif_duyuru() is
  'Web sitesinde gösterilecek en yeni aktif ve süresi dolmamış duyuruyu döndürür. Girişsiz çağrılabilir.';

revoke execute on function public.get_aktif_duyuru() from public;
grant  execute on function public.get_aktif_duyuru() to anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. admin_list_duyurular — yönetici listesi
-- ---------------------------------------------------------------------
create or replace function public.admin_list_duyurular()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  perform public.require_admin();

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id)
      from (
        select d.id, d.baslik, d.metin, d.aktif, d.bitis_at, d.created_at, d.updated_at
          from public.duyurular d
         order by d.created_at desc, d.id
         limit 100
      ) x
  ), '[]'::jsonb);
end;
$$;

comment on function public.admin_list_duyurular() is
  'Yönetici için son 100 web sitesi duyurusunu döndürür.';

revoke execute on function public.admin_list_duyurular() from public, anon;
grant  execute on function public.admin_list_duyurular() to authenticated;

-- ---------------------------------------------------------------------
-- 4. admin_save_duyuru — oluştur / düzenle
--    p_id null → yeni duyuru; dolu → o duyuru güncellenir.
--    Aktif duyurunun bitiş tarihi gelecekte olmalı (geçmiş tarihli aktif duyuru
--    hiç görünmeyeceği için reddedilir).
-- ---------------------------------------------------------------------
create or replace function public.admin_save_duyuru(
  p_id       uuid,
  p_baslik   text,
  p_metin    text,
  p_aktif    boolean,
  p_bitis_at timestamptz default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_baslik text := trim(coalesce(p_baslik, ''));
  v_metin  text := trim(coalesce(p_metin, ''));
  v_aktif  boolean := coalesce(p_aktif, false);
  v_id     uuid;
begin
  perform public.require_admin();

  if char_length(v_baslik) not between 1 and 120 then
    raise exception 'Başlık 1-120 karakter olmalı' using errcode = '22023';
  end if;
  if char_length(v_metin) not between 1 and 500 then
    raise exception 'Metin 1-500 karakter olmalı' using errcode = '22023';
  end if;
  if v_aktif and p_bitis_at is not null and p_bitis_at <= now() then
    raise exception 'Aktif duyurunun bitiş tarihi gelecekte olmalı' using errcode = '22023';
  end if;

  if p_id is null then
    insert into public.duyurular (baslik, metin, aktif, bitis_at)
    values (v_baslik, v_metin, v_aktif, p_bitis_at)
    returning id into v_id;
  else
    update public.duyurular
       set baslik     = v_baslik,
           metin      = v_metin,
           aktif      = v_aktif,
           bitis_at   = p_bitis_at,
           updated_at = now()
     where id = p_id
    returning id into v_id;

    if v_id is null then
      raise exception 'Duyuru bulunamadı' using errcode = 'P0002';
    end if;
  end if;

  perform public.log_admin_action('duyuru_kaydedildi', jsonb_build_object(
    'id', v_id, 'aktif', v_aktif, 'bitis_at', p_bitis_at));

  return v_id;
end;
$$;

comment on function public.admin_save_duyuru(uuid, text, text, boolean, timestamptz) is
  'Web sitesi duyurusunu oluşturur (p_id null) veya günceller. Yalnızca yönetici.';

revoke execute on function public.admin_save_duyuru(uuid, text, text, boolean, timestamptz) from public, anon;
grant  execute on function public.admin_save_duyuru(uuid, text, text, boolean, timestamptz) to authenticated;
