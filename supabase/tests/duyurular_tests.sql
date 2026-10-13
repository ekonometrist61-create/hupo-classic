-- =====================================================================
-- WEB SİTESİ DUYURU TEST SENARYOLARI
-- Kapsam: 20261026000000_site_duyurulari.sql
--   * get_aktif_duyuru  — anon okuyabilir; aktif + süresi dolmamış + en yeni olan
--   * admin_save_duyuru — yalnızca admin; doğrulama; oluştur/düzenle
--   * admin_list_duyurular — yalnızca admin
--   * duyurular tablosu — anon/authenticated doğrudan okuyamaz
--
-- Nasıl çalıştırılır: Önce stubs + require_admin + migration, sonra bu dosya
-- (kelime_evreni/pglite-kos.mjs ile benzer şekilde PGlite üzerinde).
-- Kalıcı kayıt bırakmaz: tüm test verisi sonunda geri alınır.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.duyuru_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm uuid := gen_random_uuid();   -- admin
  o1  uuid := gen_random_uuid();   -- admin olmayan veli
  d1  uuid;
  d2  uuid;
  d3  uuid;
  d4  uuid;
  v_json jsonb;
  v_arr  jsonb;
  v_text text;
  v_sayi integer;
begin
  no := 0;

  insert into auth.users (id, email, raw_user_meta_data) values
    (adm, 'duyuru.adm@example.test', '{"full_name":"Admin"}'),
    (o1,  'duyuru.o1@example.test',  '{"full_name":"Veli"}');
  insert into public.profiles (id, role, full_name) values
    (adm, 'admin', 'Admin'),
    (o1,  'veli',  'Veli');

  -- 1. Admin aktif bir duyuru oluşturur; anon okuyabilir
  no := no + 1;
  senaryo := 'Admin aktif duyuru oluşturur ve anon get_aktif_duyuru ile okur';
  perform set_config('request.jwt.claims', json_build_object('sub', adm)::text, true);
  perform set_config('role', 'authenticated', true);
  d1 := public.admin_save_duyuru(null, 'Deneme sınavı', 'Kayıtlar açıldı', true, now() + interval '7 days');
  perform set_config('role', 'none', true);
  perform set_config('role', 'anon', true);
  v_json := public.get_aktif_duyuru();
  perform set_config('role', 'none', true);
  gecti := v_json ->> 'baslik' = 'Deneme sınavı' and (v_json ->> 'id')::uuid = d1;
  detay := coalesce(v_json::text, 'null');
  return next;

  -- 2. Admin olmayan kullanıcı duyuru kaydedemez
  no := no + 1;
  senaryo := 'Admin olmayan kullanıcı admin_save_duyuru çağıramaz (42501)';
  perform set_config('request.jwt.claims', json_build_object('sub', o1)::text, true);
  perform set_config('role', 'authenticated', true);
  v_text := 'kabul';
  begin
    perform public.admin_save_duyuru(null, 'Sahte', 'Sahte', true, null);
  exception when sqlstate '42501' then v_text := '42501';
  end;
  perform set_config('role', 'none', true);
  gecti := v_text = '42501';
  detay := v_text;
  return next;

  -- 3. anon tabloyu doğrudan okuyamaz
  no := no + 1;
  senaryo := 'anon duyurular tablosunu doğrudan okuyamaz (42501)';
  perform set_config('role', 'anon', true);
  v_text := 'kabul';
  begin
    perform 1 from public.duyurular;
  exception when sqlstate '42501' then v_text := '42501';
  end;
  perform set_config('role', 'none', true);
  gecti := v_text = '42501';
  detay := v_text;
  return next;

  -- 4. anon admin_save_duyuru'yu çalıştıramaz (yetki yok)
  no := no + 1;
  senaryo := 'anon için admin_save_duyuru ve admin_list_duyurular execute yetkisi yok';
  gecti := not has_function_privilege('anon', 'public.admin_save_duyuru(uuid,text,text,boolean,timestamptz)', 'execute')
           and not has_function_privilege('anon', 'public.admin_list_duyurular()', 'execute')
           and has_function_privilege('anon', 'public.get_aktif_duyuru()', 'execute');
  detay := 'save/list anon yetkisiz, get_aktif_duyuru anon açık';
  return next;

  -- 5. Geçmiş bitiş tarihli AKTİF duyuru reddedilir
  no := no + 1;
  senaryo := 'Aktif duyurunun bitiş tarihi geçmişte olamaz (22023)';
  perform set_config('request.jwt.claims', json_build_object('sub', adm)::text, true);
  perform set_config('role', 'authenticated', true);
  v_text := 'kabul';
  begin
    perform public.admin_save_duyuru(null, 'Geçmiş', 'Geçmiş tarihli', true, now() - interval '1 day');
  exception when sqlstate '22023' then v_text := '22023';
  end;
  perform set_config('role', 'none', true);
  gecti := v_text = '22023';
  detay := v_text;
  return next;

  -- 6. Boş başlık ve 500 karakteri aşan metin reddedilir
  no := no + 1;
  senaryo := 'Boş başlık ve 500 karakteri aşan metin reddedilir (22023)';
  perform set_config('role', 'authenticated', true);
  v_sayi := 0;
  begin
    perform public.admin_save_duyuru(null, '   ', 'Metin', false, null);
  exception when sqlstate '22023' then v_sayi := v_sayi + 1;
  end;
  begin
    perform public.admin_save_duyuru(null, 'Başlık', repeat('a', 501), false, null);
  exception when sqlstate '22023' then v_sayi := v_sayi + 1;
  end;
  perform set_config('role', 'none', true);
  gecti := v_sayi = 2;
  detay := 'reddedilen: ' || v_sayi;
  return next;

  -- 7. Süresi dolmuş aktif duyuru ve pasif duyuru public okumada görünmez.
  --    created_at elle verilir: aynı transaction içinde now() sabit olduğundan
  --    "en yeni" sıralaması bu şekilde ayırt edilir.
  no := no + 1;
  senaryo := 'Süresi dolmuş ve pasif duyuru get_aktif_duyuru sonucuna girmez';
  insert into public.duyurular (baslik, metin, aktif, bitis_at, created_at)
  values ('Süresi dolmuş', 'Eski', true, now() - interval '1 day', now() + interval '1 minute')
  returning id into d2;
  insert into public.duyurular (baslik, metin, aktif, bitis_at, created_at)
  values ('Pasif', 'Taslak', false, null, now() + interval '2 minutes')
  returning id into d3;
  perform set_config('role', 'anon', true);
  v_json := public.get_aktif_duyuru();
  perform set_config('role', 'none', true);
  gecti := (v_json ->> 'id')::uuid = d1;
  detay := coalesce(v_json ->> 'baslik', 'null');
  return next;

  -- 8. En yeni aktif ve süresi dolmamış duyuru öncelik alır
  no := no + 1;
  senaryo := 'Birden çok aktif duyuruda en yeni olan döner';
  insert into public.duyurular (baslik, metin, aktif, bitis_at, created_at)
  values ('Yeni duyuru', 'En yeni', true, null, now() + interval '3 minutes')
  returning id into d4;
  perform set_config('role', 'anon', true);
  v_json := public.get_aktif_duyuru();
  perform set_config('role', 'none', true);
  gecti := (v_json ->> 'id')::uuid = d4;
  detay := coalesce(v_json ->> 'baslik', 'null');
  return next;

  -- 9. Düzenleme: metin güncellenir, yeni duyuru pasife alınınca eski aktif duyuru öne çıkar
  no := no + 1;
  senaryo := 'Admin duyuruyu düzenler ve pasife alır; önceki aktif duyuru geri döner';
  perform set_config('request.jwt.claims', json_build_object('sub', adm)::text, true);
  perform set_config('role', 'authenticated', true);
  perform public.admin_save_duyuru(d1, 'Deneme sınavı', 'Metin güncellendi', true, now() + interval '7 days');
  perform public.admin_save_duyuru(d4, 'Yeni duyuru', 'En yeni', false, null);
  perform set_config('role', 'none', true);
  perform set_config('role', 'anon', true);
  v_json := public.get_aktif_duyuru();
  perform set_config('role', 'none', true);
  gecti := (v_json ->> 'metin') = 'Metin güncellendi' and (v_json ->> 'id')::uuid = d1;
  detay := coalesce(v_json::text, 'null');
  return next;

  -- 10. Var olmayan id ile düzenleme reddedilir (P0002)
  no := no + 1;
  senaryo := 'Var olmayan duyuru düzenlenemez (P0002)';
  perform set_config('role', 'authenticated', true);
  v_text := 'kabul';
  begin
    perform public.admin_save_duyuru(gen_random_uuid(), 'Yok', 'Yok', false, null);
  exception when sqlstate 'P0002' then v_text := 'P0002';
  end;
  perform set_config('role', 'none', true);
  gecti := v_text = 'P0002';
  detay := v_text;
  return next;

  -- 11. admin_list_duyurular: admin listeler, admin olmayan reddedilir
  no := no + 1;
  senaryo := 'admin_list_duyurular admin için liste döner, admin olmayan için 42501';
  perform set_config('role', 'authenticated', true);
  v_arr := public.admin_list_duyurular();
  perform set_config('role', 'none', true);
  perform set_config('request.jwt.claims', json_build_object('sub', o1)::text, true);
  perform set_config('role', 'authenticated', true);
  v_text := 'kabul';
  begin
    perform public.admin_list_duyurular();
  exception when sqlstate '42501' then v_text := '42501';
  end;
  perform set_config('role', 'none', true);
  gecti := jsonb_typeof(v_arr) = 'array' and jsonb_array_length(v_arr) = 4 and v_text = '42501';
  detay := 'satır=' || coalesce(jsonb_array_length(v_arr), -1) || ', admin-olmayan=' || v_text;
  return next;

  -- 12. Yönetim işlemleri denetim kaydına düşer
  no := no + 1;
  senaryo := 'Duyuru kaydı admin_audit_log içine yazılır';
  select count(*) into v_sayi from public.admin_audit_log where islem = 'duyuru_kaydedildi';
  gecti := v_sayi >= 3;
  detay := 'kayit=' || v_sayi;
  return next;

  -- 13. Hiç aktif duyuru yoksa null döner
  no := no + 1;
  senaryo := 'Aktif duyuru yokken get_aktif_duyuru null döner';
  update public.duyurular set aktif = false;
  perform set_config('role', 'anon', true);
  v_json := public.get_aktif_duyuru();
  perform set_config('role', 'none', true);
  gecti := v_json is null;
  detay := coalesce(v_json::text, 'null');
  return next;

  perform set_config('request.jwt.claims', '', true);
end;
$fn$;

begin;  -- tüm test verisi sonunda geri alınır
select * from pg_temp.duyuru_testleri();
rollback;
