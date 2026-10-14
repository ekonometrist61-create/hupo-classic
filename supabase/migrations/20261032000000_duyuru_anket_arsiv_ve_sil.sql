-- =====================================================================
--  Duyuru ve anket arşivleme; yanıtsız taslak duyuruların silinmesi
--  Tarih : 2026-10-14
--  Ön koşul: 20261026000000 (duyurular), 20261029000000 (anket yüzeyleri),
--            20261030000000 (duyuru yüzeyleri)
--
--  NE DEĞİŞİYOR?
--    * duyurular.yayinlandi_at, duyurular.arsivlendi_at, anketler.arsivlendi_at
--    * admin_list_duyurular(p_arsiv)   : aktif (varsayılan) ya da arşiv listesi; sınır 200
--    * admin_duyuru_arsivle(id, bool)  : arşivle / arşivden çıkar (arşivden çıkan pasif kalır)
--    * admin_duyuru_sil(id)            : YALNIZCA hiç yayınlanmamış duyuru silinir
--    * admin_save_duyuru               : yayinlandi_at işaretler; arşivli duyuru yayına alınamaz
--    * admin_anket_listele(p_arsiv)    : aktif (varsayılan) ya da arşiv listesi
--    * admin_anket_arsivle(id, bool)   : yayında anket arşivlenemez (önce kapatılır)
--
--  KURALLAR
--    * Anket silme YOK. anket_yanitlari anket_id üzerinde ON DELETE CASCADE ile bağlı;
--      bir anketin silinmesi tüm yanıtları götürür. Anketlerde yalnız arşiv vardır.
--    * Duyuru silme yalnızca yayinlandi_at IS NULL kayıtlar için. Geriye dönük:
--      bu migration'dan önceki tüm kayıtlar yayınlanmış sayılır (silinemez, yalnız arşivlenir).
--    * Veli RPC'leri (anket_aktif_listem, anket_yanit_gonder) değişmez: yalnız
--      durum = 'yayinda' anketler gösterilir ve yayında olan anket arşivlenemez.
--    * Duyuru arşivlenince aktif = false olur; get_aktif_duyuru zaten yalnız aktif olanı verir.
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. Kolonlar
-- ---------------------------------------------------------------------
alter table public.duyurular add column if not exists yayinlandi_at timestamptz;
alter table public.duyurular add column if not exists arsivlendi_at timestamptz;
alter table public.anketler  add column if not exists arsivlendi_at timestamptz;

-- Geriye dönük: mevcut duyurular yayınlanmış sayılır (yanlışlıkla silinmesin).
update public.duyurular set yayinlandi_at = created_at where yayinlandi_at is null;

-- ---------------------------------------------------------------------
-- 2. Eski imzalar kalkar (aşırı yükleme belirsizliği olmasın)
-- ---------------------------------------------------------------------
drop function if exists public.admin_list_duyurular();
drop function if exists public.admin_anket_listele();

-- ---------------------------------------------------------------------
-- 3. admin_save_duyuru: yayınlanma zamanı + arşivli duyuru koruması
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
  if v_aktif and p_id is not null and exists (
       select 1 from public.duyurular where id = p_id and arsivlendi_at is not null) then
    raise exception 'Arşivlenmiş duyuru önce arşivden çıkarılmalı.' using errcode = '23514';
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
    insert into public.duyurular (baslik, metin, aktif, bitis_at, yuzeyler, yayinlandi_at)
    values (v_baslik, v_metin, v_aktif, p_bitis_at, coalesce(v_yuzey, array['web_sitesi']::text[]),
            case when v_aktif then now() end)
    returning id into v_id;
  else
    update public.duyurular
       set baslik       = v_baslik,
           metin        = v_metin,
           aktif        = v_aktif,
           bitis_at     = p_bitis_at,
           yuzeyler     = coalesce(v_yuzey, yuzeyler),
           yayinlandi_at = case when v_aktif then coalesce(yayinlandi_at, now()) else yayinlandi_at end,
           updated_at   = now()
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
  'Duyuruyu oluşturur (p_id null) veya günceller; p_yuzeyler NULL ise mevcut yüzeyler korunur. Arşivli duyuru yayına alınamaz. Yalnızca yönetici.';

-- ---------------------------------------------------------------------
-- 4. admin_list_duyurular(p_arsiv)
-- ---------------------------------------------------------------------
create or replace function public.admin_list_duyurular(p_arsiv boolean default false)
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
        select d.id, d.baslik, d.metin, d.aktif, d.bitis_at, d.yuzeyler,
               d.yayinlandi_at, d.arsivlendi_at, d.created_at, d.updated_at
          from public.duyurular d
         where (d.arsivlendi_at is not null) = coalesce(p_arsiv, false)
         order by d.created_at desc, d.id
         limit 200
      ) x
  ), '[]'::jsonb);
end;
$function$;

comment on function public.admin_list_duyurular(boolean) is
  'Yönetici duyuru listesi: p_arsiv=false aktif (arşivlenmemiş), true arşiv. En fazla 200 kayıt. Yalnızca yönetici.';

-- ---------------------------------------------------------------------
-- 5. admin_duyuru_arsivle
-- ---------------------------------------------------------------------
create or replace function public.admin_duyuru_arsivle(p_id uuid, p_arsivle boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id uuid;
begin
  perform public.require_admin();
  if p_arsivle is null then
    raise exception 'Arşiv durumu belirtilmeli.' using errcode = '22023';
  end if;

  update public.duyurular
     set arsivlendi_at = case when p_arsivle then coalesce(arsivlendi_at, now()) else null end,
         aktif         = case when p_arsivle then false else aktif end,
         updated_at    = now()
   where id = p_id
  returning id into v_id;

  if v_id is null then
    raise exception 'Duyuru bulunamadı' using errcode = 'P0002';
  end if;

  perform public.log_admin_action(
    case when p_arsivle then 'duyuru_arsivlendi' else 'duyuru_arsivden_cikarildi' end,
    jsonb_build_object('id', p_id));
end;
$function$;

comment on function public.admin_duyuru_arsivle(uuid, boolean) is
  'Duyuruyu arşivler (aktif=false) veya arşivden çıkarır (pasif kalır). Yalnızca yönetici.';

-- ---------------------------------------------------------------------
-- 6. admin_duyuru_sil — yalnızca hiç yayınlanmamış duyuru
-- ---------------------------------------------------------------------
create or replace function public.admin_duyuru_sil(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  d public.duyurular%rowtype;
begin
  perform public.require_admin();

  select * into d from public.duyurular where id = p_id for update;
  if not found then
    raise exception 'Duyuru bulunamadı' using errcode = 'P0002';
  end if;
  if d.yayinlandi_at is not null then
    raise exception 'Yayınlanmış duyuru silinemez; arşivleyin.' using errcode = '23514';
  end if;

  delete from public.duyurular where id = p_id;

  perform public.log_admin_action('duyuru_silindi', jsonb_build_object('id', p_id, 'baslik', d.baslik));
end;
$function$;

comment on function public.admin_duyuru_sil(uuid) is
  'Yalnızca hiç yayınlanmamış (yayinlandi_at null) duyuruyu siler. Yayınlanmış kayıt için arşivleme kullanılır. Yalnızca yönetici.';

-- ---------------------------------------------------------------------
-- 7. admin_anket_listele(p_arsiv)
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_listele(p_arsiv boolean default false)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_res jsonb;
begin
  perform public.require_admin();
  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc), '[]'::jsonb) into v_res
    from (
      select a.id, a.ad, a.anonim, a.durum, a.sorular, a.surum, a.tekrar_gosterim_gun, a.yuzeyler,
             a.arsivlendi_at, a.created_at,
             (select count(*)::integer from public.anket_yanitlari y where y.anket_id = a.id) as yanit_sayisi
        from public.anketler a
       where (a.arsivlendi_at is not null) = coalesce(p_arsiv, false)
    ) x;
  return v_res;
end;
$function$;

comment on function public.admin_anket_listele(boolean) is
  'Yönetici anket listesi: p_arsiv=false aktif, true arşiv. Yalnızca yönetici.';

-- ---------------------------------------------------------------------
-- 8. admin_anket_arsivle — yayında anket arşivlenemez; silme yok
-- ---------------------------------------------------------------------
create or replace function public.admin_anket_arsivle(p_id uuid, p_arsivle boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  a public.anketler%rowtype;
begin
  perform public.require_admin();
  if p_arsivle is null then
    raise exception 'Arşiv durumu belirtilmeli.' using errcode = '22023';
  end if;

  select * into a from public.anketler where id = p_id for update;
  if not found then
    raise exception 'Anket bulunamadı' using errcode = 'P0002';
  end if;
  if p_arsivle and a.durum = 'yayinda' then
    raise exception 'Yayındaki anket arşivlenemez; önce kapatın.' using errcode = '23514';
  end if;

  update public.anketler
     set arsivlendi_at = case when p_arsivle then coalesce(a.arsivlendi_at, now()) else null end,
         updated_at    = now()
   where id = p_id;

  perform public.log_admin_action(
    case when p_arsivle then 'anket_arsivlendi' else 'anket_arsivden_cikarildi' end,
    jsonb_build_object('anket_id', p_id));
end;
$function$;

comment on function public.admin_anket_arsivle(uuid, boolean) is
  'Kapalı veya taslak anketi arşivler / arşivden çıkarır. Yayındaki anket arşivlenemez. Silme yoktur. Yalnızca yönetici.';

-- ---------------------------------------------------------------------
-- 9. Yetkiler
-- ---------------------------------------------------------------------
revoke execute on function public.admin_list_duyurular(boolean)       from public, anon;
revoke execute on function public.admin_duyuru_arsivle(uuid, boolean) from public, anon;
revoke execute on function public.admin_duyuru_sil(uuid)              from public, anon;
revoke execute on function public.admin_anket_listele(boolean)        from public, anon;
revoke execute on function public.admin_anket_arsivle(uuid, boolean)  from public, anon;

grant execute on function public.admin_list_duyurular(boolean)       to authenticated;
grant execute on function public.admin_duyuru_arsivle(uuid, boolean) to authenticated;
grant execute on function public.admin_duyuru_sil(uuid)              to authenticated;
grant execute on function public.admin_anket_listele(boolean)        to authenticated;
grant execute on function public.admin_anket_arsivle(uuid, boolean)  to authenticated;
