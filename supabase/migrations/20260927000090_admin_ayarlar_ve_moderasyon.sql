-- =====================================================================
--  KURTARMA: yönetici ayarları ve soru moderasyonu RPC'leri
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  KAYNAK (canlı gövdeler, BİREBİR kopya):
--    kurtarilan/cikti-kalan.csv → kurtarilan/parcalar/
--      admin_set_setting.sql · admin_get_settings.sql · admin_list_reports.sql
--      admin_set_report_status.sql · admin_get_question.sql · admin_find_duplicates.sql
--    Her parça dosyanın sonundaki "-- secdef: true | path: {search_path=\"\"} |
--    anon: false | auth: true | servis: true" satırı yetki kanıtıdır.
--
--  ⚠️ admin_set_setting: diskte ESKİ (20260920001100) sürümü vardı; bu dosya
--     onun yerine CANLI sürümü koyar. Eski sürüm yalnızca 'premium_gating'
--     anahtarını kabul ediyordu; canlı sürüm 5 anahtarı yönetir:
--       premium_gating · bakim_modu · min_surum · desteklenen_siniflar · reklamlar
--     'desteklenen_siniflar' anahtarını 20260927000030'daki
--     _desteklenen_siniflar() okur → eski sürümle hangi sınıfların desteklendiği
--     yönetici tarafından hiç ayarlanamıyordu.
--
--  BAĞIMLILIKLAR (diskte VAR ✓):
--    public.app_settings          → 20260920001100
--    public.question_reports      → 20260927000030 (durum, neden, admin_notu, cozen_id)
--    public._refresh_question_flag(uuid) → 20260927000030
--    public.require_admin(), public.is_admin(), public.log_admin_action(text,jsonb)
--    public.tr_normalize(text), public.user_answers
--    public.questions.inceleme_gerekli ve .sinif → 20260927000040
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. admin_set_setting — 5 anahtarlı CANLI sürüm (eski sürümün yerine)
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

  else
    raise exception 'Bilinmeyen ayar anahtarı' using errcode = '22023';
  end if;

  insert into public.app_settings (key, value) values (p_key, v_yeni)
  on conflict (key) do update set value = excluded.value, updated_at = now();

  perform public.log_admin_action('ayar_degisti', jsonb_build_object('key', p_key, 'value', v_yeni));
end;
$function$;

comment on function public.admin_set_setting(text, jsonb) is
  'Yönetici ayarı yazar: premium_gating, bakim_modu, min_surum, desteklenen_siniflar, reklamlar.';

revoke execute on function public.admin_set_setting(text, jsonb) from public, anon;
grant  execute on function public.admin_set_setting(text, jsonb) to authenticated;

-- ---------------------------------------------------------------------
-- 2. admin_get_settings — yönetici ayar ekranı için toplu okuma
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
                                  'reklamlar')), '{}'::jsonb);
end;
$function$;

comment on function public.admin_get_settings() is
  'Yönetici ayar ekranı için 5 ayar anahtarını tek nesnede döndürür.';

revoke execute on function public.admin_get_settings() from public, anon;
grant  execute on function public.admin_get_settings() to authenticated;

-- ---------------------------------------------------------------------
-- 3. admin_list_reports — soru bildirimleri listesi
-- ---------------------------------------------------------------------
create or replace function public.admin_list_reports(
  p_durum text default null,
  p_neden text default null,
  p_limit integer default 25,
  p_offset integer default 0,
  p_sirala text default 'yeni'
)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
declare
  v_limit  integer := least(greatest(coalesce(p_limit, 25), 1), 100);
  v_offset integer := greatest(coalesce(p_offset, 0), 0);
  v_toplam integer;
  v_satir  jsonb;
begin
  perform public.require_admin();
  if coalesce(p_sirala, 'yeni') not in ('yeni', 'cok') then
    raise exception 'Geçersiz sıralama' using errcode = '22023';
  end if;

  select count(*)::integer into v_toplam
    from public.question_reports r
   where (p_durum is null or r.durum = p_durum)
     and (p_neden is null or r.neden = p_neden);

  select coalesce(jsonb_agg(to_jsonb(x) order by
           case when coalesce(p_sirala, 'yeni') = 'cok' then x.bildiren_sayisi end desc nulls last,
           x.created_at desc, x.id), '[]'::jsonb)
    into v_satir
    from (
      select r.id, r.question_id as soru_id, q.soru_metni, q.ders, q.konu, q.siklar, q.dogru_sik,
             q.onay_durumu, q.inceleme_gerekli,
             r.neden, r.not_metni as "not", r.durum, r.admin_notu, r.created_at,
             (select count(distinct r2.reporter_id)::integer from public.question_reports r2
               where r2.question_id = r.question_id and r2.durum in ('acik', 'inceleniyor')) as bildiren_sayisi
        from public.question_reports r
        join public.questions q on q.id = r.question_id
       where (p_durum is null or r.durum = p_durum)
         and (p_neden is null or r.neden = p_neden)
       order by case when coalesce(p_sirala, 'yeni') = 'cok' then
                  (select count(distinct r3.reporter_id) from public.question_reports r3
                    where r3.question_id = r.question_id and r3.durum in ('acik', 'inceleniyor')) end desc nulls last,
                r.created_at desc, r.id
       limit v_limit offset v_offset
    ) x;

  return jsonb_build_object('toplam', v_toplam, 'satirlar', v_satir);
end;
$function$;

comment on function public.admin_list_reports(text, text, integer, integer, text) is
  'Soru bildirimlerini durum/neden filtresiyle listeler (yeni veya en çok bildirilen önce).';

revoke execute on function public.admin_list_reports(text, text, integer, integer, text) from public, anon;
grant  execute on function public.admin_list_reports(text, text, integer, integer, text) to authenticated;

-- ---------------------------------------------------------------------
-- 4. admin_set_report_status — bildirim durumunu toplu güncelle
-- ---------------------------------------------------------------------
create or replace function public.admin_set_report_status(
  p_ids uuid[],
  p_durum text,
  p_not text default null
)
returns integer
language plpgsql
security definer
set search_path to ''
as $function$
declare
  v_adet integer;
  v_q    uuid;
  v_not  text := nullif(left(trim(coalesce(p_not, '')), 500), '');
begin
  perform public.require_admin();
  if p_durum is null or p_durum not in ('acik', 'inceleniyor', 'cozuldu', 'gecersiz') then
    raise exception 'Geçersiz durum' using errcode = '22023';
  end if;
  if coalesce(array_length(p_ids, 1), 0) > 200 then
    raise exception 'Tek seferde en fazla 200 bildirim güncellenebilir' using errcode = '22023';
  end if;

  begin
    update public.question_reports
       set durum = p_durum,
           admin_notu = coalesce(v_not, admin_notu),
           cozen_id = case when p_durum in ('cozuldu', 'gecersiz') then (select auth.uid()) else null end
     where id = any (coalesce(p_ids, '{}'));
    get diagnostics v_adet = row_count;
  exception when unique_violation then
    raise exception 'Aynı kullanıcının bu soru için zaten açık bir bildirimi var' using errcode = '23505';
  end;

  for v_q in select distinct question_id from public.question_reports where id = any (coalesce(p_ids, '{}')) loop
    perform public._refresh_question_flag(v_q);
  end loop;

  perform public.log_admin_action('rapor_durumu_degisti',
    jsonb_build_object('durum', p_durum, 'adet', v_adet));
  return v_adet;
end;
$function$;

comment on function public.admin_set_report_status(uuid[], text, text) is
  'Bildirim durumlarını toplu günceller ve etkilenen soruların inceleme bayrağını tazeler.';

revoke execute on function public.admin_set_report_status(uuid[], text, text) from public, anon;
grant  execute on function public.admin_set_report_status(uuid[], text, text) to authenticated;

-- ---------------------------------------------------------------------
-- 5. admin_get_question — tek soru detayı (açık bildirim sayısıyla)
-- ---------------------------------------------------------------------
create or replace function public.admin_get_question(p_id uuid)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
declare
  v_row jsonb;
begin
  perform public.require_admin();
  select to_jsonb(x) into v_row from (
    select q.id, q.okul, q.sinif, q.ders, q.konu, q.alt_konu, q.zorluk, q.soru_metni, q.siklar,
           q.dogru_sik, q.cozum_adimlari, q.onay_durumu, q.created_at, q.inceleme_gerekli,
           (select count(*)::integer from public.question_reports r
             where r.question_id = q.id and r.durum in ('acik', 'inceleniyor')) as acik_rapor
      from public.questions q where q.id = p_id) x;
  return v_row;
end;
$function$;

comment on function public.admin_get_question(uuid) is
  'Tek sorunun tüm alanlarını ve açık bildirim sayısını döndürür.';

revoke execute on function public.admin_get_question(uuid) from public, anon;
grant  execute on function public.admin_get_question(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- 6. admin_find_duplicates — aynı metinli soruları gruplar
-- ---------------------------------------------------------------------
create or replace function public.admin_find_duplicates(p_limit integer default 50)
returns jsonb
language plpgsql
stable security definer
set search_path to ''
as $function$
declare
  v_limit integer := least(greatest(coalesce(p_limit, 50), 1), 200);
  v_toplam integer;
  v_gruplar jsonb;
begin
  perform public.require_admin();

  with n as (
    select q.id, q.ders, q.konu,
           trim(regexp_replace(public.tr_normalize(q.soru_metni), '[^a-z0-9]+', ' ', 'g')) as norm
      from public.questions q
     where q.onay_durumu <> 'arsiv'
  ),
  g as (
    select ders, konu, norm, count(*) as adet
      from n group by ders, konu, norm having count(*) > 1
  )
  select count(*)::integer into v_toplam from g;

  with n as (
    select q.id, q.ders, q.konu,
           trim(regexp_replace(public.tr_normalize(q.soru_metni), '[^a-z0-9]+', ' ', 'g')) as norm
      from public.questions q
     where q.onay_durumu <> 'arsiv'
  ),
  g as (
    select ders, konu, norm, count(*)::integer as adet
      from n group by ders, konu, norm having count(*) > 1
     order by count(*) desc, ders, konu, norm
     limit v_limit
  )
  select coalesce(jsonb_agg(jsonb_build_object(
           'ders', g.ders, 'konu', g.konu, 'adet', g.adet,
           'sorular', (
             select jsonb_agg(jsonb_build_object(
                      'id', q.id, 'soru_metni', q.soru_metni, 'siklar', q.siklar,
                      'dogru_sik', q.dogru_sik, 'onay_durumu', q.onay_durumu,
                      'created_at', q.created_at,
                      'cevap_sayisi', (select count(*) from public.user_answers ua where ua.question_id = q.id)
                    ) order by q.created_at, q.id)
               from n
               join public.questions q on q.id = n.id
              where n.ders = g.ders and n.konu = g.konu and n.norm = g.norm)
         ) order by g.adet desc, g.ders, g.konu), '[]'::jsonb)
    into v_gruplar
    from g;

  return jsonb_build_object('toplam_grup', v_toplam, 'gruplar', v_gruplar);
end;
$function$;

comment on function public.admin_find_duplicates(integer) is
  'Aynı ders+konu içinde benzer metinli soruları gruplar (mükerrer temizliği için).';

revoke execute on function public.admin_find_duplicates(integer) from public, anon;
grant  execute on function public.admin_find_duplicates(integer) to authenticated;

-- ---------------------------------------------------------------------
-- NOT (kurtarma): bu dosyaya ALINMAYAN canlı fonksiyonlar ve gerekçesi
--   * admin_question_history(uuid, integer)  → public.question_revisions
--     tablosunu okur; tablonun canlı tanımı dökümde YOK.
--   * admin_question_analytics(integer)      → public._question_analytics_base
--     (integer) fonksiyonuna bağlı; bu yardımcı fonksiyonun gövdesi dökümde YOK.
--   İkisi de panelden/uygulamadan ÇAĞRILMIYOR (bkz. KURTARMA_DURUMU.md §6).
--   Nesneler canlıdan (supabase db pull) alınınca ayrı bir migration'la eklenir.
-- ---------------------------------------------------------------------
