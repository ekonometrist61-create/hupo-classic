-- =====================================================================
--  Bildirim kampanyaları ve uygulama içi kutu
--  Tarih : 2026-10-16
--  Ön koşul: 20260920000700 (notifications), 20260920001000 (push),
--            20261003000020 (admin_send_notification / admin_list_notifications),
--            20261026000000, 20261030000000, 20261032000000 (duyurular)
--
--  NE DEĞİŞİYOR?
--    * duyurular      : kategori, hedef_rol, baslangic_at, inbox_yayin, inbox_yayinlandi_at
--    * notifications  : kategori, kaynak_duyuru_id, okundu_at
--    * duyuru_inbox_yayinla()   : yayındaki ve inbox_yayin açık duyuruyu hedef rollerin
--                                 kutusuna TEK SEFER dağıtır. pg_cron her dakika çalıştırır.
--    * get_bildirimler()        : kutu listesi + okunmamış sayısı. Sayı tamdır (istemci
--                                 tarafında kırpılmaz). Arşivlenmiş / süresi dolmuş
--                                 duyurunun kutu kayıtları görünmez.
--    * mark_notifications_read  : okundu_at de yazılır
--    * get_aktif_duyuru         : baslangic_at dikkate alınır (zamanlanmış yayın)
--    * admin_save_duyuru        : 4 yeni parametre; eski 6 parametreli çağrı çalışmaya devam eder
--    * admin_list_duyurular     : yeni alanları döner
--    * admin_list_notifications : kampanya kaynaklı kopyalar listelenmez (kampanya kendi listesinde)
--
--  KURALLAR (çocuk güvenliği ve ticari ileti)
--    * kategori = 'indirim' (pazarlama) uygulama kutusuna GİDEMEZ ve push üretmez.
--      Yalnızca web_sitesi ve veli_paneli banner'ında yayınlanır (DB CHECK ile zorunlu).
--      Kutu/push için yasal onay ve ayrı rıza kanalı gerekir (TASKS.md).
--    * Öğrenci yüzeyleri (mobil, web_app) pazarlama duyurusu alamaz.
--    * Kutu dağıtımı yalnızca yayındaki duyuru içindir: aktif, arşivlenmemiş, süresi dolmamış.
--    * Dağıtım tek seferliktir: inbox_yayinlandi_at + (kaynak, alıcı) benzersizliği.
--    * Kutudaki başlık/metin dağıtım anındaki kopyadır; sonradan düzenlenen duyuru kutuya
--      yansımaz. Arşivleme ise kutudaki kopyayı görünmez yapar.
--    * Push ayrı bir yol değildir: notifications'a eklenen satır mevcut push_outbox hattından
--      geçer (opt-in + veli rızası + sessiz saat, 20260920001000).
-- =====================================================================

set client_encoding = 'UTF8';

-- ---------------------------------------------------------------------
-- 1. duyurular kolonları ve kuralları
-- ---------------------------------------------------------------------
alter table public.duyurular
  add column if not exists kategori            text        not null default 'duyuru',
  add column if not exists hedef_rol           text        not null default 'tumu',
  add column if not exists baslangic_at        timestamptz not null default now(),
  add column if not exists inbox_yayin         boolean     not null default false,
  add column if not exists inbox_yayinlandi_at timestamptz;

alter table public.duyurular drop constraint if exists duyurular_kategori_check;
alter table public.duyurular add constraint duyurular_kategori_check
  check (kategori in ('duyuru', 'indirim', 'sistem', 'akademik'));

alter table public.duyurular drop constraint if exists duyurular_hedef_rol_check;
alter table public.duyurular add constraint duyurular_hedef_rol_check
  check (hedef_rol in ('tumu', 'veli', 'ogrenci', 'ogretmen'));

-- Pazarlama koruması: indirim kutuya gitmez ve öğrenci yüzeylerinde yayınlanmaz.
alter table public.duyurular drop constraint if exists duyurular_indirim_korumasi;
alter table public.duyurular add constraint duyurular_indirim_korumasi check (
  kategori <> 'indirim'
  or (not inbox_yayin and yuzeyler <@ array['web_sitesi', 'veli_paneli']::text[])
);

-- ---------------------------------------------------------------------
-- 2. notifications kolonları
-- ---------------------------------------------------------------------
alter table public.notifications
  add column if not exists kategori         text not null default 'sistem',
  add column if not exists kaynak_duyuru_id uuid references public.duyurular (id) on delete cascade,
  add column if not exists okundu_at        timestamptz;

alter table public.notifications drop constraint if exists notifications_kategori_check;
alter table public.notifications add constraint notifications_kategori_check
  check (kategori in ('sistem', 'akademik', 'duyuru', 'indirim'));

-- Aynı kampanya aynı kişiye iki kez düşmez (dağıtım yeniden çalışsa bile).
create unique index if not exists notifications_kampanya_tekil
  on public.notifications (kaynak_duyuru_id, alici_id)
  where kaynak_duyuru_id is not null;

-- ---------------------------------------------------------------------
-- 3. Kaynak kampanya hâlâ yayında mı? (kaynak yoksa kayıt her zaman görünür)
-- ---------------------------------------------------------------------
create or replace function public.bildirim_kaynagi_yayinda(p_kaynak_duyuru_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
  select p_kaynak_duyuru_id is null
      or exists (
           select 1
             from public.duyurular d
            where d.id = p_kaynak_duyuru_id
              and d.aktif
              and d.arsivlendi_at is null
              and (d.bitis_at is null or d.bitis_at > now())
         );
$function$;

-- ---------------------------------------------------------------------
-- 4. Kutu dağıtımı (pg_cron her dakika)
--    Yayındaki, inbox_yayin açık ve henüz dağıtılmamış duyuruları hedef rollerin
--    kutusuna yazar. Yönetici rolü kutu almaz. Döner: eklenen kayıt sayısı.
-- ---------------------------------------------------------------------
create or replace function public.duyuru_inbox_yayinla()
returns integer
language plpgsql
security definer
set search_path = ''
as $function$
declare
  d       public.duyurular%rowtype;
  v_adet  integer := 0;
  v_satir integer;
begin
  for d in
    select *
      from public.duyurular
     where inbox_yayin
       and aktif
       and arsivlendi_at is null
       and inbox_yayinlandi_at is null
       and baslangic_at <= now()
       and (bitis_at is null or bitis_at > now())
     order by created_at, id
       for update skip locked
  loop
    insert into public.notifications (alici_id, tur, baslik, mesaj, ikon, kategori, kaynak_duyuru_id)
    select p.id, 'bilgi', d.baslik, d.metin, 'bell', d.kategori, d.id
      from public.profiles p
     where p.role in ('veli', 'ogrenci', 'ogretmen')
       and (d.hedef_rol = 'tumu' or p.role = d.hedef_rol)
    on conflict (kaynak_duyuru_id, alici_id) where kaynak_duyuru_id is not null do nothing;

    get diagnostics v_satir = row_count;
    v_adet := v_adet + v_satir;

    update public.duyurular set inbox_yayinlandi_at = now() where id = d.id;
  end loop;

  return v_adet;
end;
$function$;

comment on function public.duyuru_inbox_yayinla() is
  'Yayındaki ve inbox_yayin açık duyuruları hedef rollerin kutusuna tek seferlik dağıtır. pg_cron çağırır; istemciye kapalıdır.';

-- ---------------------------------------------------------------------
-- 5. Kutu RPC'si: liste + tam okunmamış sayısı (istemci kırpmaz)
-- ---------------------------------------------------------------------
create or replace function public.get_bildirimler(
  p_limit  integer default 20,
  p_offset integer default 0
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_uid       uuid := (select auth.uid());
  v_limit     integer := least(greatest(coalesce(p_limit, 20), 1), 50);
  v_offset    integer := greatest(coalesce(p_offset, 0), 0);
  v_okunmamis integer;
  v_satirlar  jsonb;
begin
  if v_uid is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;

  select count(*)::integer into v_okunmamis
    from public.notifications n
   where n.alici_id = v_uid
     and n.okundu = false
     and public.bildirim_kaynagi_yayinda(n.kaynak_duyuru_id);

  select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc, x.id), '[]'::jsonb) into v_satirlar
    from (
      select n.id, n.tur, n.kategori, n.baslik, n.mesaj, n.ikon,
             n.okundu, n.okundu_at, n.created_at
        from public.notifications n
       where n.alici_id = v_uid
         and public.bildirim_kaynagi_yayinda(n.kaynak_duyuru_id)
       order by n.created_at desc, n.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object(
    'okunmamis_sayi', coalesce(v_okunmamis, 0),
    'satirlar',       v_satirlar
  );
end;
$function$;

comment on function public.get_bildirimler(integer, integer) is
  'Giriş yapmış kullanıcının bildirim kutusu: okunmamış sayısı (tam) ve en yeni satırlar. Arşivlenmiş/süresi dolmuş kampanya kayıtları gizlenir.';

-- ---------------------------------------------------------------------
-- 6. mark_notifications_read: okundu_at de yazılır
-- ---------------------------------------------------------------------
create or replace function public.mark_notifications_read(p_ids uuid[] default null)
returns integer
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_count integer;
begin
  if (select auth.uid()) is null then
    raise exception 'Oturum gerekli' using errcode = '42501';
  end if;

  update public.notifications
     set okundu    = true,
         okundu_at = now()
   where alici_id = (select auth.uid())
     and okundu = false
     and (p_ids is null or id = any (p_ids));
  get diagnostics v_count = row_count;
  return v_count;
end;
$function$;

-- ---------------------------------------------------------------------
-- 7. get_aktif_duyuru: zamanlanmış yayın (baslangic_at) dikkate alınır
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
       and d.baslangic_at <= now()
       and (d.bitis_at is null or d.bitis_at > now())
     order by d.created_at desc, d.id
     limit 1
  );
end;
$function$;

-- ---------------------------------------------------------------------
-- 8. admin_save_duyuru: yeni alanlar (eski 6 parametreli çağrı çalışır)
--    Güncellemede NULL gelen alan mevcut değerini korur.
-- ---------------------------------------------------------------------
drop function if exists public.admin_save_duyuru(uuid, text, text, boolean, timestamptz, text[]);

create or replace function public.admin_save_duyuru(
  p_id           uuid,
  p_baslik       text,
  p_metin        text,
  p_aktif        boolean,
  p_bitis_at     timestamptz default null,
  p_yuzeyler     text[]      default null,
  p_kategori     text        default null,
  p_hedef_rol    text        default null,
  p_baslangic_at timestamptz default null,
  p_inbox_yayin  boolean     default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_baslik     text := trim(coalesce(p_baslik, ''));
  v_metin      text := trim(coalesce(p_metin, ''));
  v_aktif      boolean := coalesce(p_aktif, false);
  v_mevcut     public.duyurular%rowtype;
  v_yuzey_yeni text[];
  v_yuzey      text[];
  v_kategori   text;
  v_hedef      text;
  v_inbox      boolean;
  v_baslangic  timestamptz;
  v_id         uuid;
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

  if p_id is not null then
    select * into v_mevcut from public.duyurular where id = p_id for update;
    if not found then
      raise exception 'Duyuru bulunamadı' using errcode = 'P0002';
    end if;
    if v_aktif and v_mevcut.arsivlendi_at is not null then
      raise exception 'Arşivlenmiş duyuru önce arşivden çıkarılmalı.' using errcode = '23514';
    end if;
  end if;

  if p_yuzeyler is not null then
    select coalesce(array_agg(distinct y order by y), '{}'::text[]) into v_yuzey_yeni
      from unnest(p_yuzeyler) as y;
    if cardinality(v_yuzey_yeni) = 0
       or not (v_yuzey_yeni <@ array['mobil', 'web_app', 'web_sitesi', 'veli_paneli']::text[]) then
      raise exception 'En az bir geçerli yayın yüzeyi seçilmeli.' using errcode = '22023';
    end if;
  end if;

  v_yuzey := coalesce(
    v_yuzey_yeni,
    case when p_id is null then array['web_sitesi']::text[] else v_mevcut.yuzeyler end
  );
  v_kategori := coalesce(p_kategori, case when p_id is null then 'duyuru' else v_mevcut.kategori end);
  v_hedef := coalesce(p_hedef_rol, case when p_id is null then 'tumu' else v_mevcut.hedef_rol end);
  v_inbox := coalesce(p_inbox_yayin, case when p_id is null then false else v_mevcut.inbox_yayin end);
  v_baslangic := coalesce(p_baslangic_at, case when p_id is null then now() else v_mevcut.baslangic_at end);

  if v_kategori not in ('duyuru', 'indirim', 'sistem', 'akademik') then
    raise exception 'Geçersiz duyuru kategorisi' using errcode = '22023';
  end if;
  if v_hedef not in ('tumu', 'veli', 'ogrenci', 'ogretmen') then
    raise exception 'Geçersiz hedef rol' using errcode = '22023';
  end if;
  if v_kategori = 'indirim' and v_inbox then
    raise exception 'İndirim duyurusu uygulama kutusuna gönderilemez; yalnızca web sitesi veya veli paneli banner''ı olarak yayınlanabilir.'
      using errcode = '23514';
  end if;
  if v_kategori = 'indirim' and not (v_yuzey <@ array['web_sitesi', 'veli_paneli']::text[]) then
    raise exception 'İndirim duyurusu yalnızca web sitesi ve veli panelinde yayınlanabilir.'
      using errcode = '23514';
  end if;

  if p_id is null then
    insert into public.duyurular (baslik, metin, aktif, bitis_at, yuzeyler, yayinlandi_at,
                                  kategori, hedef_rol, baslangic_at, inbox_yayin)
    values (v_baslik, v_metin, v_aktif, p_bitis_at, v_yuzey,
            case when v_aktif then now() end,
            v_kategori, v_hedef, v_baslangic, v_inbox)
    returning id into v_id;
  else
    update public.duyurular
       set baslik        = v_baslik,
           metin         = v_metin,
           aktif         = v_aktif,
           bitis_at      = p_bitis_at,
           yuzeyler      = v_yuzey,
           yayinlandi_at = case when v_aktif then coalesce(yayinlandi_at, now()) else yayinlandi_at end,
           kategori      = v_kategori,
           hedef_rol     = v_hedef,
           baslangic_at  = v_baslangic,
           inbox_yayin   = v_inbox,
           updated_at    = now()
     where id = p_id
    returning id into v_id;
  end if;

  perform public.log_admin_action('duyuru_kaydedildi', jsonb_build_object(
    'id', v_id, 'aktif', v_aktif, 'bitis_at', p_bitis_at, 'yuzeyler', v_yuzey,
    'kategori', v_kategori, 'hedef_rol', v_hedef, 'inbox_yayin', v_inbox));

  return v_id;
end;
$function$;

comment on function public.admin_save_duyuru(uuid, text, text, boolean, timestamptz, text[], text, text, timestamptz, boolean) is
  'Duyuruyu oluşturur (p_id null) veya günceller. NULL alanlar güncellemede korunur. İndirim kutuya gitmez ve öğrenci yüzeyinde yayınlanmaz. Yalnızca yönetici.';

-- ---------------------------------------------------------------------
-- 9. admin_list_duyurular: yeni alanlar
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
               d.yayinlandi_at, d.arsivlendi_at, d.created_at, d.updated_at,
               d.kategori, d.hedef_rol, d.baslangic_at, d.inbox_yayin, d.inbox_yayinlandi_at
          from public.duyurular d
         where (d.arsivlendi_at is not null) = coalesce(p_arsiv, false)
         order by d.created_at desc, d.id
         limit 200
      ) x
  ), '[]'::jsonb);
end;
$function$;

-- ---------------------------------------------------------------------
-- 10. admin_list_notifications: kampanya kopyaları listelenmez
--     (aynı imza; 20261003000020 gövdesine tek koşul eklendi)
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
as $function$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();

  select count(*)::integer into v_toplam
    from public.notifications
   where tur = 'bilgi'
     and kaynak_duyuru_id is null;

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
        and n.kaynak_duyuru_id is null
      order by n.created_at desc, n.id
      limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$function$;

-- ---------------------------------------------------------------------
-- 11. Yetkiler (her RPC açıkça; istemciye yalnız gereken)
-- ---------------------------------------------------------------------
revoke execute on function public.bildirim_kaynagi_yayinda(uuid)              from public, anon, authenticated;
revoke execute on function public.duyuru_inbox_yayinla()                      from public, anon, authenticated;
revoke execute on function public.get_bildirimler(integer, integer)           from public, anon;
grant  execute on function public.get_bildirimler(integer, integer)           to authenticated;

revoke execute on function public.mark_notifications_read(uuid[])             from public, anon;
grant  execute on function public.mark_notifications_read(uuid[])             to authenticated;

revoke execute on function public.get_aktif_duyuru(text)                      from public;
grant  execute on function public.get_aktif_duyuru(text)                      to anon, authenticated;

revoke execute on function public.admin_save_duyuru(uuid, text, text, boolean, timestamptz, text[], text, text, timestamptz, boolean) from public, anon;
grant  execute on function public.admin_save_duyuru(uuid, text, text, boolean, timestamptz, text[], text, text, timestamptz, boolean) to authenticated;

revoke execute on function public.admin_list_duyurular(boolean)              from public, anon;
grant  execute on function public.admin_list_duyurular(boolean)              to authenticated;

revoke execute on function public.admin_list_notifications(integer, integer)  from public, anon;
grant  execute on function public.admin_list_notifications(integer, integer)  to authenticated;

-- ---------------------------------------------------------------------
-- 12. Zamanlayıcı: dakikada bir kutu dağıtımı (pg_cron; deneme sweep ile aynı kalıp)
-- ---------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from cron.job where jobname = 'duyuru-inbox-yayinla') then
    perform cron.schedule(
      'duyuru-inbox-yayinla',
      '* * * * *',
      'select public.duyuru_inbox_yayinla()'
    );
  end if;
end
$$;
