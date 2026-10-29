-- =====================================================================
--  ÜCRETSİZ DENEME FIRSATI (her ürün, Kelime Evreni dahil)
--  Tarih : 2026-10-29
--  Karar (proje sahibi, 2026-10-29): her ürün kısıtlı ücretsiz denemeyle tanınır, denenir.
--
--  NE DEĞİŞİYOR?
--    1) Ücretsiz taban paketi: beş modülün tamamı 'sinirli' (günlük kota). Önceden
--       Kelime Evreni / Deneme 'onizleme' idi (kapalı).
--         okuma 2 · carpma 40 · soru_cevap 20 · kelime_evreni 30 · deneme 1
--       Değerler mevcut app_settings 'deneme_sinirlari' varsayılanlarıyla aynıdır
--       (okuma_hikayesi 2, carpim_sifresi 40, soru 20, kelime_evreni 30, deneme_sinavi 2 → 1).
--    2) deneme_sinir_tetik: deneme penceresi DIŞINDA ürün kotası artık paket matrisinden
--       (has_access) okunur. Deneme penceresi İÇİNDEKİ davranış aynıdır (legacy sınırlar).
--         - erişim 'tam'     → sınırsız
--         - erişim 'sinirli' → günlük kota (matris)
--         - diğer            → P0403 "bu bölüm planında yok"
--    3) deneme_sinav_kapisi: deneme sınavı, deneme penceresi / tam / sinirli erişimde açılır.
--       Sayım tetikleyicide (2) yapılır: tek yer.
--
--  Güvenlik: iki fonksiyon da security definer + search_path=''. Yalnız oturumlu (istemci)
--  yazımlarını sınırlar; servis yazımları etkilenmez (mevcut kalıp).
--  Uygulama sıralaması: 20261125 tetikleyicileri zaten var; yalnız fonksiyon gövdeleri değişir.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Ücretsiz taban matrisi
-- ---------------------------------------------------------------------
insert into public.paket_modul (paket_kod, modul_kod, erisim, gunluk_kota) values
  ('ucretsiz', 'okuma',         'sinirli', 2),
  ('ucretsiz', 'carpma',        'sinirli', 40),
  ('ucretsiz', 'soru_cevap',    'sinirli', 20),
  ('ucretsiz', 'kelime_evreni', 'sinirli', 30),
  ('ucretsiz', 'deneme',        'sinirli', 1)
on conflict (paket_kod, modul_kod) do update set
  erisim = excluded.erisim,
  gunluk_kota = excluded.gunluk_kota;

-- Ücretsiz paketi yeni sürümle yeniden yayınla (has_access en güncel sürümü okur)
select public._paket_yayinla_ic('ucretsiz');

-- ---------------------------------------------------------------------
-- 2. Sınır tetikleyicisi: deneme penceresi legacy, değilse paket kotası
--    TG_ARGV[0] öğrenci kolonu, [1] zaman kolonu, [2] özellik anahtarı, [3] Türkçe etiket
-- ---------------------------------------------------------------------
create or replace function public.deneme_sinir_tetik()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_ogrenci uuid := (to_jsonb(new) ->> TG_ARGV[0])::uuid;
  v_zaman   text := TG_ARGV[1];
  v_ozellik text := TG_ARGV[2];
  v_etiket  text := TG_ARGV[3];
  v_modul   text;
  v_erisim  jsonb;
  v_sinir   jsonb;
  v_pencere text;
  v_limit   integer;
  v_bas     timestamptz;
  v_bit     timestamptz := 'infinity'::timestamptz;
  v_sayi    bigint;
begin
  -- Yalnız oturumlu (istemci) yazımları; servis ve sunucu yazımları etkilenmez.
  if (select auth.uid()) is null or v_ogrenci is null then
    return new;
  end if;

  -- 1) Deneme penceresi (premium değil): mevcut deneme sınırları (değişmedi)
  if not public.is_premium(v_ogrenci) and public._deneme_aktif(v_ogrenci) then
    v_sinir := public._deneme_sinir(v_ogrenci, v_ozellik);
    if v_sinir is null then
      return new;
    end if;
    v_limit   := (v_sinir ->> 'sinir')::integer;
    v_pencere := coalesce(v_sinir ->> 'pencere', 'gunluk');

    if v_pencere = 'deneme' then
      select max(d.baslangic) into v_bas
        from public.deneme_donemleri d
       where d.veli_id = public._deneme_sahibi(v_ogrenci) and d.bitis > now();
    else
      v_bas := ((now() at time zone 'Europe/Istanbul')::date)::timestamp at time zone 'Europe/Istanbul';
      v_bit := v_bas + interval '1 day';
    end if;

    execute format(
      'select count(*) from public.%I where %I = $1 and %I >= $2 and %I < $3',
      TG_TABLE_NAME, TG_ARGV[0], v_zaman, v_zaman)
      into v_sayi using v_ogrenci, v_bas, v_bit;

    if v_sayi > v_limit then
      raise exception '%', format('%s için %s ücretsiz hakkın doldu.', v_etiket,
        case when v_pencere = 'deneme' then 'deneme süresindeki' else 'bugünkü' end)
        using errcode = 'P0402';
    end if;
    return new;
  end if;

  -- 2) Ürün kotası: paket matrisi (ücretsiz taban veya abonelik)
  v_modul := case v_ozellik
    when 'kelime_evreni'  then 'kelime_evreni'
    when 'carpim_sifresi' then 'carpma'
    when 'okuma_hikayesi' then 'okuma'
    when 'deneme_sinavi'  then 'deneme'
    else null end;
  if v_modul is null then
    return new;
  end if;

  v_erisim := public.has_access(v_ogrenci, v_modul);
  if v_erisim ->> 'erisim' = 'tam' then
    return new;
  end if;
  if v_erisim ->> 'erisim' <> 'sinirli' or v_erisim ->> 'gunluk_kota' is null then
    raise exception '%', format('%s bu planda yok.', v_etiket) using errcode = 'P0403';
  end if;

  v_limit := (v_erisim ->> 'gunluk_kota')::integer;
  v_bas := ((now() at time zone 'Europe/Istanbul')::date)::timestamp at time zone 'Europe/Istanbul';
  v_bit := v_bas + interval '1 day';

  execute format(
    'select count(*) from public.%I where %I = $1 and %I >= $2 and %I < $3',
    TG_TABLE_NAME, TG_ARGV[0], v_zaman, v_zaman)
    into v_sayi using v_ogrenci, v_bas, v_bit;

  if v_sayi > v_limit then
    raise exception '%', format('%s için bugünkü ücretsiz hakkın doldu.', v_etiket)
      using errcode = 'P0402';
  end if;
  return new;
end;
$$;

revoke execute on function public.deneme_sinir_tetik() from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- 3. Deneme sınavı kapısı: deneme penceresi veya paket erişimi (tam/sinirli) varsa açık.
--    Sayım deneme_sinir_tetik'te (deneme_sinavi özelliği, günlük/ pencere kotası).
-- ---------------------------------------------------------------------
create or replace function public.deneme_sinav_kapisi()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is null then
    return new;
  end if;
  if public._deneme_aktif(new.student_id) then
    return new;
  end if;
  if (public.has_access(new.student_id, 'deneme') ->> 'erisim') in ('tam', 'sinirli') then
    return new;
  end if;
  raise exception 'Deneme sınavları bu planda yer almıyor. Planını veli panelinden seçebilirsin.'
    using errcode = 'P0403';
end;
$$;

comment on function public.deneme_sinav_kapisi() is
  'Deneme sınavı kaydını deneme penceresi veya paket erişimi (tam/sinirli) varsa açar (P0403).';

revoke execute on function public.deneme_sinav_kapisi() from public, anon, authenticated;
