-- =====================================================================
--  Türkiye Geneli Deneme Sınavı tarihi: yönetici ayarı + herkese açık okuma
--  Tarih : 2026-10-17
--
--  SORUN:
--    1. Yönetim panelinde (/yonetim/ayarlar) bu tarih için alan yoktu.
--    2. admin_set_setting yalnızca 5 anahtarı kabul ediyordu; 'deneme_sinavi_tarihi'
--       "Bilinmeyen ayar anahtarı" hatasıyla reddedilirdi.
--    3. Landing sayfası app_settings tablosunu anon/istemci rolüyle okuyordu;
--       app_settings için anon yetkisi kaldırılmış ve select politikası yalnızca
--       'premium_gating' anahtarına izin veriyor. Sorgu sessizce düşüp sabit
--       yedek tarihe (2026-11-15) dönüyordu — yönetici değiştirse bile site değişmezdi.
--
--  ÇÖZÜM:
--    * admin_set_setting   → 'deneme_sinavi_tarihi' anahtarını kabul eder (ISO 8601 metin, UTC'ye çevrilir)
--    * admin_get_settings  → anahtarı da döndürür
--    * get_deneme_sinavi_tarihi() → girişsiz (anon) okunabilen tek değerli RPC; landing bunu çağırır
--
--  Önceki sürümler: 20260927000090 (admin_set_setting / admin_get_settings),
--                   20261009020000 (deneme_sinavi_tarihi satırı)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. admin_set_setting — 6 anahtarlı sürüm (deneme_sinavi_tarihi eklendi)
-- ---------------------------------------------------------------------
create or replace function public.admin_set_setting(p_key text, p_value jsonb)
returns void
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_yeni  jsonb;
  v_p     text;
  v_mesaj text;
  v_liste integer[];
  v_tarih timestamptz;
begin
  perform public.require_admin();

  if p_key = 'premium_gating' then
    if jsonb_typeof(p_value) is distinct from 'object'
       or jsonb_typeof(p_value -> 'aktif') is distinct from 'boolean'
       or jsonb_typeof(p_value -> 'ucretsiz_gunluk_soru') is distinct from 'number'
       or (p_value ->> 'ucretsiz_gunluk_soru') !~ '^[0-9]{1,4}$' then
      raise exception 'premium_gating: {"aktif": true|false, "ucretsiz_gunluk_soru": 0-9999} olmalı'
        using errcode = '22023';
    end if;
    v_yeni := jsonb_build_object('aktif', p_value -> 'aktif',
                                 'ucretsiz_gunluk_soru', p_value -> 'ucretsiz_gunluk_soru');

  elsif p_key = 'bakim_modu' then
    if jsonb_typeof(p_value) is distinct from 'object'
       or jsonb_typeof(p_value -> 'aktif') is distinct from 'boolean'
       or jsonb_typeof(coalesce(p_value -> 'mesaj', '""'::jsonb)) is distinct from 'string' then
      raise exception 'bakim_modu: {"aktif": true|false, "mesaj": "metin"} olmalı' using errcode = '22023';
    end if;
    v_mesaj := trim(coalesce(p_value ->> 'mesaj', ''));
    if length(v_mesaj) > 300 then
      raise exception 'Mesaj en fazla 300 karakter olabilir' using errcode = '22023';
    end if;
    v_yeni := jsonb_build_object('aktif', p_value -> 'aktif', 'mesaj', v_mesaj);

  elsif p_key = 'min_surum' then
    if jsonb_typeof(p_value) is distinct from 'object' then
      raise exception 'min_surum bir nesne olmalı' using errcode = '22023';
    end if;
    foreach v_p in array array['android', 'ios', 'web'] loop
      if jsonb_typeof(p_value -> v_p) is distinct from 'string'
         or (p_value ->> v_p) !~ '^[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}$' then
        raise exception 'min_surum: % için sürüm 1.2.3 biçiminde olmalı', v_p using errcode = '22023';
      end if;
    end loop;
    if jsonb_typeof(coalesce(p_value -> 'mesaj', '""'::jsonb)) is distinct from 'string' then
      raise exception 'min_surum.mesaj metin olmalı' using errcode = '22023';
    end if;
    v_mesaj := trim(coalesce(p_value ->> 'mesaj', ''));
    if length(v_mesaj) > 300 then
      raise exception 'Mesaj en fazla 300 karakter olabilir' using errcode = '22023';
    end if;
    v_yeni := jsonb_build_object('android', p_value ->> 'android', 'ios', p_value ->> 'ios',
                                 'web', p_value ->> 'web', 'mesaj', v_mesaj);

  elsif p_key = 'desteklenen_siniflar' then
    if jsonb_typeof(p_value) is distinct from 'object'
       or jsonb_typeof(p_value -> 'siniflar') is distinct from 'array'
       or jsonb_array_length(p_value -> 'siniflar') not between 1 and 12
       or exists (select 1 from jsonb_array_elements(p_value -> 'siniflar') e
                   where jsonb_typeof(e) is distinct from 'number'
                      or (e #>> '{}') !~ '^([1-9]|1[0-2])$') then
      raise exception 'desteklenen_siniflar: {"siniflar": [3, 4]} (1-12 arası tam sayılar) olmalı'
        using errcode = '22023';
    end if;
    select array_agg(distinct (e #>> '{}')::integer order by (e #>> '{}')::integer)
      into v_liste from jsonb_array_elements(p_value -> 'siniflar') e;
    v_yeni := jsonb_build_object('siniflar', to_jsonb(v_liste));

  elsif p_key = 'reklamlar' then
    if jsonb_typeof(p_value) is distinct from 'object' then
      raise exception 'reklamlar bir nesne olmalı' using errcode = '22023';
    end if;
    -- Bilinmeyen fazladan anahtar kabul edilmez
    for v_p in select jsonb_object_keys(p_value) loop
      if v_p not in ('veli_paneli_acik', 'ogrenci_acik', 'admob_app_id_android', 'admob_app_id_ios',
                     'admob_banner_id_android', 'admob_banner_id_ios', 'adsense_publisher_id',
                     'adsense_slot_id') then
        raise exception 'reklamlar: bilinmeyen alan %', v_p using errcode = '22023';
      end if;
    end loop;
    foreach v_p in array array['veli_paneli_acik', 'ogrenci_acik'] loop
      if jsonb_typeof(p_value -> v_p) is distinct from 'boolean' then
        raise exception 'reklamlar: % boolean olmalı', v_p using errcode = '22023';
      end if;
    end loop;
    foreach v_p in array array['admob_app_id_android', 'admob_app_id_ios', 'admob_banner_id_android',
                                'admob_banner_id_ios', 'adsense_publisher_id', 'adsense_slot_id'] loop
      if not (p_value -> v_p is null or jsonb_typeof(p_value -> v_p) = 'null'
              or jsonb_typeof(p_value -> v_p) = 'string') then
        raise exception 'reklamlar: % metin veya null olmalı', v_p using errcode = '22023';
      end if;
      if jsonb_typeof(p_value -> v_p) = 'string' and trim(p_value ->> v_p) = '' then
        raise exception 'reklamlar: % boş olamaz (boş bırakmak için null kullanın)', v_p
          using errcode = '22023';
      end if;
    end loop;
    v_yeni := jsonb_build_object(
      'veli_paneli_acik', p_value -> 'veli_paneli_acik',
      'ogrenci_acik', p_value -> 'ogrenci_acik',
      'admob_app_id_android', case when p_value -> 'admob_app_id_android' is null
        or jsonb_typeof(p_value -> 'admob_app_id_android') = 'null' then null
        else trim(p_value ->> 'admob_app_id_android') end,
      'admob_app_id_ios', case when p_value -> 'admob_app_id_ios' is null
        or jsonb_typeof(p_value -> 'admob_app_id_ios') = 'null' then null
        else trim(p_value ->> 'admob_app_id_ios') end,
      'admob_banner_id_android', case when p_value -> 'admob_banner_id_android' is null
        or jsonb_typeof(p_value -> 'admob_banner_id_android') = 'null' then null
        else trim(p_value ->> 'admob_banner_id_android') end,
      'admob_banner_id_ios', case when p_value -> 'admob_banner_id_ios' is null
        or jsonb_typeof(p_value -> 'admob_banner_id_ios') = 'null' then null
        else trim(p_value ->> 'admob_banner_id_ios') end,
      'adsense_publisher_id', case when p_value -> 'adsense_publisher_id' is null
        or jsonb_typeof(p_value -> 'adsense_publisher_id') = 'null' then null
        else trim(p_value ->> 'adsense_publisher_id') end,
      'adsense_slot_id', case when p_value -> 'adsense_slot_id' is null
        or jsonb_typeof(p_value -> 'adsense_slot_id') = 'null' then null
        else trim(p_value ->> 'adsense_slot_id') end);

  elsif p_key = 'deneme_sinavi_tarihi' then
    -- ISO 8601 metin bekler (ör. "2026-11-15T06:00:00Z"); saklanırken UTC'ye çevrilir
    if jsonb_typeof(p_value) is distinct from 'string' then
      raise exception 'deneme_sinavi_tarihi: ISO 8601 tarih metni olmalı' using errcode = '22023';
    end if;
    begin
      v_tarih := (p_value #>> '{}')::timestamptz;
    exception when others then
      raise exception 'deneme_sinavi_tarihi: geçerli bir tarih değil' using errcode = '22023';
    end;
    v_yeni := to_jsonb(to_char(v_tarih at time zone 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'));

  else
    raise exception 'Bilinmeyen ayar anahtarı' using errcode = '22023';
  end if;

  insert into public.app_settings (key, value) values (p_key, v_yeni)
  on conflict (key) do update set value = excluded.value, updated_at = now();

  perform public.log_admin_action('ayar_degisti', jsonb_build_object('key', p_key, 'value', v_yeni));
end;
$function$;

comment on function public.admin_set_setting(text, jsonb) is
  'Yönetici ayarı yazar: premium_gating, bakim_modu, min_surum, desteklenen_siniflar, reklamlar, deneme_sinavi_tarihi.';

revoke execute on function public.admin_set_setting(text, jsonb) from public, anon;
grant  execute on function public.admin_set_setting(text, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 2. admin_get_settings — 6 anahtar (deneme_sinavi_tarihi eklendi)
-- ---------------------------------------------------------------------
create or replace function public.admin_get_settings()
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
begin
  perform public.require_admin();
  return coalesce((select jsonb_object_agg(key, value) from public.app_settings
                    where key in ('premium_gating', 'bakim_modu', 'min_surum', 'desteklenen_siniflar',
                                  'reklamlar', 'deneme_sinavi_tarihi')), '{}'::jsonb);
end;
$function$;

comment on function public.admin_get_settings() is
  'Yönetici ayar ekranı için 6 ayar anahtarını tek nesnede döndürür.';

revoke execute on function public.admin_get_settings() from public, anon;
grant  execute on function public.admin_get_settings() to authenticated;

-- ---------------------------------------------------------------------
-- 3. get_deneme_sinavi_tarihi — landing sayfası için herkese açık okuma
--    Girişsiz ziyaretçi app_settings tablosunu doğrudan okuyamaz; yalnızca bu
--    tek değeri döndüren RPC'yi çağırır. Ayar yoksa null döner.
-- ---------------------------------------------------------------------
create or replace function public.get_deneme_sinavi_tarihi()
returns timestamptz
language sql
stable security definer
set search_path = ''
as $function$
  select (s.value #>> '{}')::timestamptz
    from public.app_settings s
   where s.key = 'deneme_sinavi_tarihi';
$function$;

comment on function public.get_deneme_sinavi_tarihi() is
  'Türkiye Geneli Deneme Sınavı tarihini döndürür (landing geri sayımı). Girişsiz (anon) çağrılabilir.';

revoke execute on function public.get_deneme_sinavi_tarihi() from public;
grant  execute on function public.get_deneme_sinavi_tarihi() to anon, authenticated;
