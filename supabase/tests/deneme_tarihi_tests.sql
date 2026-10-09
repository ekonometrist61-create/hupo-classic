-- =====================================================================
-- DENEME SINAVI TARİHİ AYARI TEST SENARYOLARI
-- Kapsam: 20261017000000_deneme_sinavi_tarihi_ayari.sql
--   * admin_set_setting('deneme_sinavi_tarihi') — UTC'ye çevirir, geçersizi reddeder
--   * admin_get_settings — anahtarı döndürür
--   * get_deneme_sinavi_tarihi() — anon çağırabilir, ayar yoksa null
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Kalıcı kayıt bırakmaz: tüm test verisi iş bitince geri alınır.
-- Ön koşul: tüm migration'lar uygulanmış olmalı (supabase db reset).
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.deneme_tarihi_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm uuid := gen_random_uuid();   -- admin
  o1  uuid := gen_random_uuid();   -- admin olmayan giriş
  v_text  text;
  v_text2 text;
  v_json  jsonb;
  v_tarih timestamptz;
begin
  no := 0;

  insert into auth.users (id, email, raw_user_meta_data) values
    (adm, 'dt.adm@example.test', '{"role":"veli","full_name":"Deneme Admin"}'),
    (o1,  'dt.o1@example.test',  '{"role":"ogrenci","full_name":"Cocuk Bir"}');
  update public.profiles set role = 'admin' where id = adm;

  -- 1
  no := no + 1;
  senaryo := 'Yerel saatle (UTC+3) gönderilen tarih UTC olarak saklanır';
  perform set_config('request.jwt.claim.sub', adm::text, true);
  perform set_config('role', 'authenticated', true);
  perform public.admin_set_setting('deneme_sinavi_tarihi', '"2026-11-15T09:00:00+03:00"'::jsonb);
  perform set_config('role', 'none', true);
  select (value #>> '{}') into v_text from public.app_settings where key = 'deneme_sinavi_tarihi';
  gecti := v_text = '2026-11-15T06:00:00Z';
  detay := v_text;
  return next;

  -- 2
  no := no + 1;
  senaryo := 'Geçersiz tarih metni ve sayı değeri reddedilir';
  v_text := '';
  perform set_config('request.jwt.claim.sub', adm::text, true);
  perform set_config('role', 'authenticated', true);
  begin
    perform public.admin_set_setting('deneme_sinavi_tarihi', '"bu bir tarih degil"'::jsonb);
    v_text := v_text || 'a';
  exception when sqlstate '22023' then null; end;
  begin
    perform public.admin_set_setting('deneme_sinavi_tarihi', '12345'::jsonb);
    v_text := v_text || 'b';
  exception when sqlstate '22023' then null; end;
  perform set_config('role', 'none', true);
  gecti := v_text = '';
  detay := 'reddedilmeyen: ' || v_text;
  return next;

  -- 3
  no := no + 1;
  senaryo := 'admin_get_settings deneme_sinavi_tarihi anahtarını döndürür';
  perform set_config('request.jwt.claim.sub', adm::text, true);
  perform set_config('role', 'authenticated', true);
  v_json := public.admin_get_settings();
  perform set_config('role', 'none', true);
  gecti := v_json ? 'deneme_sinavi_tarihi'
           and (v_json ->> 'deneme_sinavi_tarihi') = '"2026-11-15T06:00:00Z"';
  detay := coalesce(v_json ->> 'deneme_sinavi_tarihi', 'yok');
  return next;

  -- 4
  no := no + 1;
  senaryo := 'get_deneme_sinavi_tarihi anon tarafından çağrılabilir ve ayarlanan tarihi döndürür';
  perform set_config('role', 'anon', true);
  v_tarih := public.get_deneme_sinavi_tarihi();
  perform set_config('role', 'none', true);
  gecti := v_tarih = '2026-11-15T06:00:00Z'::timestamptz
           and has_function_privilege('anon', 'public.get_deneme_sinavi_tarihi()', 'execute');
  detay := coalesce(v_tarih::text, 'null');
  return next;

  -- 5
  no := no + 1;
  senaryo := 'Admin olmayan kullanıcı deneme_sinavi_tarihi ayarlayamaz';
  perform set_config('request.jwt.claim.sub', o1::text, true);
  perform set_config('role', 'authenticated', true);
  v_text := '';
  begin
    perform public.admin_set_setting('deneme_sinavi_tarihi', '"2026-12-01T06:00:00Z"'::jsonb);
    v_text := 'kabul';
  exception when sqlstate '42501' then v_text := sqlstate; end;
  perform set_config('role', 'none', true);
  gecti := v_text = '42501';
  detay := v_text;
  return next;

  perform set_config('request.jwt.claim.sub', '', true);
end;
$fn$;

begin;  -- tüm test verisi ve ayar değişikliği sonunda geri alınır
select * from pg_temp.deneme_tarihi_testleri();
rollback;
