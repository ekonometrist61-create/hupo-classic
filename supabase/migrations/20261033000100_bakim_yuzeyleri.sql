-- =====================================================================
-- BAKIM KONTROLÜ: YÜZEY BAZLI BAKIM (TASKS.md §16.3)
--
-- app_settings.bakim_modu değerine isteğe bağlı "yuzeyler" alanı eklenir:
--   { "aktif": bool,            -- MOBİL (Flutter web dahil) bakım kapısı
--     "mesaj": "metin",
--     "yuzeyler": { "site": bool, "veli": bool, "yonetim": bool } }
--
--   aktif     → mobil uygulama ve öğrenci web uygulaması (Flutter, aynı kod)
--   site      → hupolingo.com genel sayfaları (landing, /demo, vb.)
--   veli      → /veli-paneli/*
--   yonetim   → /yonetim/* (yöneticiler bakım sırasında da girebilir)
--
-- Geriye dönük uyum: "yuzeyler" yoksa tüm web yüzeyleri kapalı kabul edilir.
-- Mobil istemci yalnızca "aktif" ve "mesaj" alanlarını okur; fazla alan zararsız.
--
-- Bu dosya admin_set_setting'i CANLI sürümün (20260927000090) tam kopyası
-- olarak yeniden tanımlar; tek fark bakim_modu dalındaki yuzeyler işlemesidir.
-- =====================================================================

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
    if p_value ? 'yuzeyler' then
      if jsonb_typeof(p_value -> 'yuzeyler') is distinct from 'object'
         or exists (select 1 from jsonb_each(p_value -> 'yuzeyler') e
                     where e.key not in ('site', 'veli', 'yonetim')
                        or jsonb_typeof(e.value) is distinct from 'boolean') then
        raise exception 'bakim_modu.yuzeyler: yalnızca site, veli, yonetim (boolean) olabilir'
          using errcode = '22023';
      end if;
    end if;
    v_mesaj := trim(coalesce(p_value ->> 'mesaj', ''));
    if length(v_mesaj) > 300 then
      raise exception 'Mesaj en fazla 300 karakter olabilir' using errcode = '22023';
    end if;
    v_yeni := jsonb_build_object(
      'aktif', p_value -> 'aktif',
      'mesaj', v_mesaj,
      'yuzeyler', jsonb_build_object(
        'site',    coalesce((p_value #> '{yuzeyler,site}')::boolean, false),
        'veli',    coalesce((p_value #> '{yuzeyler,veli}')::boolean, false),
        'yonetim', coalesce((p_value #> '{yuzeyler,yonetim}')::boolean, false)));

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

  else
    raise exception 'Bilinmeyen ayar anahtarı' using errcode = '22023';
  end if;

  insert into public.app_settings (key, value) values (p_key, v_yeni)
  on conflict (key) do update set value = excluded.value, updated_at = now();

  perform public.log_admin_action('ayar_degisti', jsonb_build_object('key', p_key, 'value', v_yeni));
end;
$function$;

comment on function public.admin_set_setting(text, jsonb) is
  'Yönetici ayarı yazar: premium_gating, bakim_modu (yuzeyler dahil), min_surum, desteklenen_siniflar, reklamlar.';

revoke execute on function public.admin_set_setting(text, jsonb) from public, anon;
grant  execute on function public.admin_set_setting(text, jsonb) to authenticated;
