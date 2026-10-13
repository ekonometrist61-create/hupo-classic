-- =====================================================================
--  Duyuru yayın yüzeyleri: duyuru hangi mecralarda gösterilecek?
--  Tarih : 2026-10-13
--  Ön koşul: 20261026000000 (duyurular, get_aktif_duyuru, admin_*_duyuru),
--            20261029000000 (anket yüzeyleri — aynı yüzey sözlüğü)
--
--  NE DEĞİŞİYOR?
--    * duyurular.yuzeyler text[]        : 'mobil' | 'web_app' | 'web_sitesi' | 'veli_paneli'
--                                         (varsayılan yalnız 'web_sitesi' = bugünkü davranış)
--    * get_aktif_duyuru(p_yuzey)        : o yüzey için en yeni aktif, süresi dolmamış duyuru.
--                                         p_yuzey varsayılanı 'web_sitesi' → yayın sırasında
--                                         parametresiz çağıran eski web sürümü bozulmaz.
--    * admin_list_duyurular             : yuzeyler döner
--    * admin_save_duyuru                : p_yuzeyler eklendi (NULL → mevcut değer korunur)
--
--  KURALLAR
--    * Duyuru herkese açık bilgidir: get_aktif_duyuru anon + authenticated çağırabilir.
--    * Her yüzey kendi duyurusunu alır; yüzeyler arası "tek duyuru" kısıtı yoktur.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.duyurular
  add column if not exists yuzeyler text[] not null default array['web_sitesi']::text[];

alter table public.duyurular drop constraint if exists duyurular_yuzeyler;
alter table public.duyurular add constraint duyurular_yuzeyler check (
  cardinality(yuzeyler) between 1 and 4
  and yuzeyler <@ array['mobil', 'web_app', 'web_sitesi', 'veli_paneli']::text[]
);

drop function if exists public.get_aktif_duyuru();
drop function if exists public.admin_save_duyuru(uuid, text, text, boolean, timestamptz);

-- ---------------------------------------------------------------------
-- get_aktif_duyuru
-- ---------------------------------------------------------------------
create or replace function public.get_aktif_duyuru(p_yuzey text default 'web_sitesi')
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  if p_yuzey is null or p_yuzey not in ('mobil', 'web_app', 'web_sitesi', 'veli_paneli') then
    raise exception 'Geçersiz yayın yüzeyi.' using errcode = '22023';
  end if;

  return (
    select jsonb_build_object(
             'id', d.id,
             'baslik', d.baslik,
             'metin', d.metin,
             'bitis_at', d.bitis_at)
      from public.duyurular d
     where d.aktif
       and p_yuzey = any (d.yuzeyler)
       and (d.bitis_at is null or d.bitis_at > now())
     order by d.created_at desc, d.id
     limit 1
  );
end;
$function$;

comment on function public.get_aktif_duyuru(text) is
  'Verilen yüzeyde gösterilecek en yeni aktif ve süresi dolmamış duyuruyu döndürür (yoksa null). Girişsiz çağrılabilir.';

revoke execute on function public.get_aktif_duyuru(text) from public;
grant  execute on function public.get_aktif_duyuru(text) to anon, authenticated;

-- ---------------------------------------------------------------------
-- admin_list_duyurular
-- ---------------------------------------------------------------------
create or replace function public.admin_list_duyurular()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
begin
  perform public.require_admin();

  return coalesce((
    select jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id)
      from (
        select d.id, d.baslik, d.metin, d.aktif, d.bitis_at, d.yuzeyler, d.created_at, d.updated_at
          from public.duyurular d
         order by d.created_at desc, d.id
         limit 100
      ) x
  ), '[]'::jsonb);
end;
$function$;

-- ---------------------------------------------------------------------
-- admin_save_duyuru
-- ---------------------------------------------------------------------
create or replace function public.admin_save_duyuru(
  p_id        uuid,
  p_baslik    text,
  p_metin     text,
  p_aktif     boolean,
  p_bitis_at  timestamptz default null,
  p_yuzeyler  text[] default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_baslik text := trim(coalesce(p_baslik, ''));
  v_metin  text := trim(coalesce(p_metin, ''));
  v_aktif  boolean := coalesce(p_aktif, false);
  v_yuzey  text[];
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

  if p_yuzeyler is not null then
    select coalesce(array_agg(distinct y order by y), '{}'::text[]) into v_yuzey
      from unnest(p_yuzeyler) as y;
    if cardinality(v_yuzey) = 0
       or not (v_yuzey <@ array['mobil', 'web_app', 'web_sitesi', 'veli_paneli']::text[]) then
      raise exception 'En az bir geçerli yayın yüzeyi seçilmeli.' using errcode = '22023';
    end if;
  end if;

  if p_id is null then
    insert into public.duyurular (baslik, metin, aktif, bitis_at, yuzeyler)
    values (v_baslik, v_metin, v_aktif, p_bitis_at, coalesce(v_yuzey, array['web_sitesi']::text[]))
    returning id into v_id;
  else
    update public.duyurular
       set baslik     = v_baslik,
           metin      = v_metin,
           aktif      = v_aktif,
           bitis_at   = p_bitis_at,
           yuzeyler   = coalesce(v_yuzey, yuzeyler),
           updated_at = now()
     where id = p_id
    returning id into v_id;

    if v_id is null then
      raise exception 'Duyuru bulunamadı' using errcode = 'P0002';
    end if;
  end if;

  perform public.log_admin_action('duyuru_kaydedildi', jsonb_build_object(
    'id', v_id, 'aktif', v_aktif, 'bitis_at', p_bitis_at, 'yuzeyler', v_yuzey));

  return v_id;
end;
$function$;

comment on function public.admin_save_duyuru(uuid, text, text, boolean, timestamptz, text[]) is
  'Duyuruyu oluşturur (p_id null) veya günceller; p_yuzeyler NULL ise mevcut yüzeyler korunur. Yalnızca yönetici.';

revoke execute on function public.admin_save_duyuru(uuid, text, text, boolean, timestamptz, text[]) from public, anon;
grant  execute on function public.admin_save_duyuru(uuid, text, text, boolean, timestamptz, text[]) to authenticated;
