-- =====================================================================
-- Admin bildirim yönetimi
--   admin_send_notification  : belirli bir kullanıcıya veya rol grubuna bildirim gönder
--   admin_list_notifications : admin'in son 200 gönderimini listele
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. admin_send_notification — tek kullanıcıya veya rol grubuna gönderim
--   p_alici_id   : belirli kullanıcı UUID; null ise p_hedef_rol kullanılır
--   p_hedef_rol  : 'veli' | 'ogrenci' | 'tumu' — p_alici_id null ise zorunlu
-- ---------------------------------------------------------------------
create or replace function public.admin_send_notification(
  p_baslik    text,
  p_mesaj     text,
  p_ikon      text     default 'bell',
  p_alici_id  uuid     default null,
  p_hedef_rol text     default null
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_admin uuid := auth.uid();
  v_count integer := 0;
begin
  perform public.require_admin();

  if p_baslik is null or length(trim(p_baslik)) = 0 then
    raise exception 'Başlık boş olamaz' using errcode = '22023';
  end if;
  if p_mesaj is null or length(trim(p_mesaj)) = 0 then
    raise exception 'Mesaj boş olamaz' using errcode = '22023';
  end if;

  if p_alici_id is not null then
    -- Tek kullanıcıya
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
    values (p_alici_id, 'bilgi', trim(p_baslik), trim(p_mesaj), coalesce(nullif(trim(p_ikon), ''), 'bell'));
    v_count := 1;
  elsif p_hedef_rol in ('veli', 'ogrenci') then
    -- Belirli rol grubuna
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
    select id, 'bilgi', trim(p_baslik), trim(p_mesaj), coalesce(nullif(trim(p_ikon), ''), 'bell')
      from public.profiles
     where role = p_hedef_rol;
    get diagnostics v_count = row_count;
  elsif p_hedef_rol = 'tumu' then
    -- Tüm kullanıcılara
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon)
    select id, 'bilgi', trim(p_baslik), trim(p_mesaj), coalesce(nullif(trim(p_ikon), ''), 'bell')
      from public.profiles
     where role in ('veli', 'ogrenci');
    get diagnostics v_count = row_count;
  else
    raise exception 'Hedef: p_alici_id veya p_hedef_rol (veli|ogrenci|tumu) gerekli' using errcode = '22023';
  end if;

  perform public.log_admin_action('bildirim_gonderildi', jsonb_build_object(
    'baslik', p_baslik, 'hedef_rol', p_hedef_rol, 'alici_id', p_alici_id, 'adet', v_count
  ));
  return v_count;
end;
$$;

revoke execute on function public.admin_send_notification(text, text, text, uuid, text) from public, anon;
grant  execute on function public.admin_send_notification(text, text, text, uuid, text) to authenticated;

-- ---------------------------------------------------------------------
-- 2. admin_list_notifications — admin'in gönderdiği bildirimleri listele
--   Son 200 'bilgi' tipindeki bildirimi, başlık/mesaj/alıcı bilgisiyle döner.
-- ---------------------------------------------------------------------
create or replace function public.admin_list_notifications(
  p_limit  integer default 50,
  p_offset integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_toplam
    from public.notifications
   where tur = 'bilgi';

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb) into v_satir
    from (
      select
        n.id,
        n.baslik,
        n.mesaj,
        n.ikon,
        n.okundu,
        n.created_at,
        p.full_name as alici_ad,
        p.role      as alici_rol
      from public.notifications n
      join public.profiles p on p.id = n.alici_id
      where n.tur = 'bilgi'
      order by n.created_at desc, n.id
      limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$$;

revoke execute on function public.admin_list_notifications(integer, integer) from public, anon;
grant  execute on function public.admin_list_notifications(integer, integer) to authenticated;
