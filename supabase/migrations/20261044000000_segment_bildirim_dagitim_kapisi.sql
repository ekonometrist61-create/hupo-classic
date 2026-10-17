-- =====================================================================
-- Segmentli bildirim: kanal ve hukuk kapısı kontrolü (K-0018, ONAYLI 2026-10-17)
--
-- 1. admin_kampanya_kaydet: yalnızca 'push' kanalı kaydedilir. E-posta, SMS ve
--    uygulama içi kanallarının dağıtıcısı yok; planlanıp sessizce kalmaları engellenir.
-- 2. admin_kampanya_on_kontrol: sonuca kapi_acik ve kanal_dagitilir alanları eklenir
--    (geriye uyumlu; mevcut alanlar aynen kalır).
-- 3. admin_kampanya_planla: kanal push değilse veya pazarlama push kapısı kapalıysa
--    reddeder. Kampanya taslak/ön kontrol aşamasında kalır.
--
-- Bu dosya hukuk kapısını AÇMAZ ve açan bir yol eklemez. Kapı yalnızca 20261038'deki
-- admin_pazarlama_push_kapisi_guncelle ile yönetici kararından açılır (GÖR-031).
-- Gövdeler 20261007000020 ile aynıdır; yalnızca yukarıdaki kontroller ve alanlar eklenir.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Kampanya kaydı: yalnızca push
-- ---------------------------------------------------------------------
create or replace function public.admin_kampanya_kaydet(
  p_id          uuid,
  p_ad          text,
  p_kanal       text,
  p_segment_id  uuid,
  p_baslik      text,
  p_mesaj       text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_id    uuid := p_id;
  v_durum text;
begin
  perform public.require_admin();
  if p_kanal is distinct from 'push' then
    raise exception 'Yalnızca push kanalı dağıtılıyor; diğer kanallar henüz kullanılamaz.' using errcode = '22023';
  end if;
  if not exists (select 1 from public.segmentler where id = p_segment_id and not arsiv) then
    raise exception 'Segment bulunamadı.' using errcode = 'P0002';
  end if;

  if v_id is null then
    insert into public.iletisim_kampanyalari (ad, kanal, segment_id, baslik, mesaj, created_by)
    values (btrim(coalesce(p_ad, '')), p_kanal, p_segment_id,
            btrim(coalesce(p_baslik, '')), btrim(coalesce(p_mesaj, '')), (select auth.uid()))
    returning id into v_id;
  else
    select durum into v_durum from public.iletisim_kampanyalari where id = v_id;
    if not found then
      raise exception 'Kampanya bulunamadı' using errcode = 'P0002';
    end if;
    if v_durum not in ('taslak', 'kontrol_edildi') then
      raise exception 'Planlanmış veya iptal edilmiş kampanya düzenlenemez.' using errcode = '23514';
    end if;
    -- İçerik/kitle değişince önceki ön kontrol geçersizdir.
    update public.iletisim_kampanyalari
       set ad = btrim(coalesce(p_ad, '')), kanal = p_kanal, segment_id = p_segment_id,
           baslik = btrim(coalesce(p_baslik, '')), mesaj = btrim(coalesce(p_mesaj, '')),
           durum = 'taslak', onkontrol = null, planlanan_at = null, updated_at = now()
     where id = v_id;
  end if;

  perform public.log_admin_action('iletisim_kampanyasi_kaydedildi', jsonb_build_object('kampanya_id', v_id));
  return v_id;
end;
$function$;

-- ---------------------------------------------------------------------
-- 2. Ön kontrol: kapı ve kanal durumunu da döner. Gönderim YAPMAZ.
-- ---------------------------------------------------------------------
create or replace function public.admin_kampanya_on_kontrol(p_id uuid, p_planlanan_at timestamptz)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $function$
declare
  c          public.iletisim_kampanyalari%rowtype;
  s          public.segmentler%rowtype;
  a          public.iletisim_ayarlari%rowtype;
  v_toplam   integer;
  v_izinli   integer;
  v_diger    uuid[] := '{}';
  v_sinir    integer;
  v_sessiz   boolean;
  v_sonuc    jsonb;
  r          record;
begin
  perform public.require_admin();

  select * into c from public.iletisim_kampanyalari where id = p_id;
  if not found then
    raise exception 'Kampanya bulunamadı' using errcode = 'P0002';
  end if;
  if c.durum not in ('taslak', 'kontrol_edildi') then
    raise exception 'Bu kampanya için ön kontrol yapılamaz.' using errcode = '23514';
  end if;
  if p_planlanan_at is null or p_planlanan_at <= now() then
    raise exception 'Planlanan zaman gelecekte olmalı.' using errcode = '22023';
  end if;

  select * into s from public.segmentler where id = c.segment_id and not arsiv;
  if not found then
    raise exception 'Segment bulunamadı veya arşivlenmiş.' using errcode = 'P0002';
  end if;
  select * into a from public.iletisim_ayarlari where id;

  select count(*)::integer, (count(*) filter (where r_izinli))::integer
    into v_toplam, v_izinli
    from public._segment_veliler(s.kriterler, c.kanal);

  -- Planlanan zamanın ±6 günündeki (7 günlük pencereye sığan) planlı diğer kampanyaların
  -- GERÇEK alıcıları (yalnızca o kanalda izinliler), kanallar birlikte sayılır.
  -- Not: bu, "her olası 7 günlük pencere" için tam hesap değil, muhafazakâr bir yaklaşımdır.
  for r in
    select c2.kanal as kanal2, s2.kriterler as kriter2
      from public.iletisim_kampanyalari c2
      join public.segmentler s2 on s2.id = c2.segment_id
     where c2.durum = 'planlandi' and c2.id <> p_id
       and c2.planlanan_at between p_planlanan_at - interval '6 days' and p_planlanan_at + interval '6 days'
  loop
    v_diger := v_diger || array(select r_veli_id from public._segment_veliler(r.kriter2, r.kanal2) where r_izinli);
  end loop;

  with sayac as (
    select x as veli, count(*) as n from unnest(v_diger) x group by x
  )
  select count(*)::integer into v_sinir
    from public._segment_veliler(s.kriterler, c.kanal) h
    join sayac y on y.veli = h.r_veli_id
   where h.r_izinli and y.n >= a.haftalik_limit;

  v_sessiz := public._sessiz_saat_mi(p_planlanan_at);

  v_sonuc := jsonb_build_object(
    'hedef', v_toplam,
    'izinli', v_izinli,
    'izin_haric', v_toplam - v_izinli,
    'sinir_haric', v_sinir,
    'gonderilecek', greatest(v_izinli - v_sinir, 0),
    'sessiz_saat', v_sessiz,
    'haftalik_limit', a.haftalik_limit,
    'planlanan_at', p_planlanan_at,
    'kontrol_zamani', now(),
    'kapi_acik', public._pazarlama_push_acik(),
    'kanal_dagitilir', c.kanal = 'push'
  );

  update public.iletisim_kampanyalari
     set durum = 'kontrol_edildi', planlanan_at = p_planlanan_at, onkontrol = v_sonuc, updated_at = now()
   where id = p_id;

  perform public.log_admin_action('iletisim_kampanyasi_on_kontrol', jsonb_build_object('kampanya_id', p_id));
  return v_sonuc;
end;
$function$;

-- ---------------------------------------------------------------------
-- 3. Planlama: push kanalı ve hukuk kapısı şartı eklendi. Mesaj GÖNDERİLMEZ;
--    dağıtım kampanya_push_gonder (dakikalık cron) ile yapılır.
-- ---------------------------------------------------------------------
create or replace function public.admin_kampanya_planla(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $function$
declare
  c public.iletisim_kampanyalari%rowtype;
begin
  perform public.require_admin();

  select * into c from public.iletisim_kampanyalari where id = p_id for update;
  if not found then
    raise exception 'Kampanya bulunamadı' using errcode = 'P0002';
  end if;
  if c.durum <> 'kontrol_edildi' or c.onkontrol is null then
    raise exception 'Önce ön kontrol yapılmalı.' using errcode = '23514';
  end if;
  if c.kanal <> 'push' then
    raise exception 'Yalnızca push kanalı dağıtılıyor; bu kampanya planlanamaz.' using errcode = '23514';
  end if;
  if not public._pazarlama_push_acik() then
    raise exception 'Pazarlama push kapısı kapalı (hukuk onayı bekleniyor); kampanya planlanamaz.' using errcode = '23514';
  end if;
  if c.planlanan_at is null or c.planlanan_at <= now() + interval '5 minutes' then
    raise exception 'Planlanan zaman en az 5 dakika sonrası olmalı; ön kontrolü yenileyin.' using errcode = '23514';
  end if;
  if (c.onkontrol ->> 'kontrol_zamani')::timestamptz < now() - interval '1 hour' then
    raise exception 'Ön kontrol 1 saatten eski; yenileyin.' using errcode = '23514';
  end if;
  if coalesce((c.onkontrol ->> 'sessiz_saat')::boolean, true) then
    raise exception 'Planlanan zaman sessiz saat aralığında.' using errcode = '23514';
  end if;
  if coalesce((c.onkontrol ->> 'gonderilecek')::integer, 0) < 1 then
    raise exception 'Gönderilecek izinli alıcı yok.' using errcode = '23514';
  end if;

  update public.iletisim_kampanyalari set durum = 'planlandi', updated_at = now() where id = p_id;

  insert into public.olay_kutusu (tur, payload)
  values ('iletisim_kampanyasi_planlandi',
          jsonb_build_object('kampanya_id', p_id, 'kanal', c.kanal, 'planlanan_at', c.planlanan_at));

  perform public.log_admin_action('iletisim_kampanyasi_planlandi', jsonb_build_object('kampanya_id', p_id));
end;
$function$;

-- ---------------------------------------------------------------------
-- Yetkiler: yeniden tanımlanan her RPC için açık revoke/grant
-- ---------------------------------------------------------------------
revoke execute on function public.admin_kampanya_kaydet(uuid, text, text, uuid, text, text) from public, anon;
grant  execute on function public.admin_kampanya_kaydet(uuid, text, text, uuid, text, text) to authenticated;

revoke execute on function public.admin_kampanya_on_kontrol(uuid, timestamptz) from public, anon;
grant  execute on function public.admin_kampanya_on_kontrol(uuid, timestamptz) to authenticated;

revoke execute on function public.admin_kampanya_planla(uuid) from public, anon;
grant  execute on function public.admin_kampanya_planla(uuid) to authenticated;
