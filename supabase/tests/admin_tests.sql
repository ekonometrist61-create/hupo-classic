-- =====================================================================
-- ADMİN ROLÜ, TOPLU SORU YÖNETİMİ VE ÖDEME YÖNETİMİ TEST SENARYOLARI
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: test verileri iş bitince geri alınır.
-- Ön koşul: 20260920000900_admin_role_and_payments.sql uygulanmış olmalı.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.admin_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm uuid := gen_random_uuid();   -- admin
  v1  uuid := gen_random_uuid();   -- veli 1
  v2  uuid := gen_random_uuid();   -- veli 2
  o1  uuid := gen_random_uuid();   -- çocuk (v1'e bağlanacak)

  v_q       jsonb;
  v_json    jsonb;
  v_json2   jsonb;
  v_int     integer;
  v_int2    integer;
  v_text    text;
  v_id      uuid;
  v_id2     uuid;
  v_ids     uuid[];
  v_fail    integer;
  v_rows    integer;
begin
  no := 0;

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (adm, 'adm.test@example.test', '{"role":"veli","full_name":"Test Admin"}'),
      (v1,  'adm.veli1@example.test', '{"role":"veli","full_name":"Ayşe Veli"}'),
      (v2,  'adm.veli2@example.test', '{"role":"veli","full_name":"Mehmet Veli"}'),
      (o1,  'adm.cocuk1@example.test', '{"role":"ogrenci","full_name":"Çocuk Bir"}');
    -- Yükseltme yetkili taraf (SQL Editor / service_role) tarafından yapılır
    update public.profiles set role = 'admin' where id = adm;

    v_q := jsonb_build_object(
      'okul', 'ortaokul', 'ders', 'TestDers', 'konu', 'Yüzdeler', 'zorluk', 2,
      'soru_metni', 'Yüzde sorusu 1?',
      'siklar', jsonb_build_object('A', '10', 'B', '20', 'C', '30'),
      'dogru_sik', 'b', 'cozum_adimlari', jsonb_build_array('Adım 1', 'Adım 2'));

    -- ---------------------------------------------------------------
    -- A) Rol güvenliği
    -- ---------------------------------------------------------------

    -- 1
    no := no + 1;
    senaryo := 'Kayıtta metadata ile "admin" rolü istenirse hesap öğrenci olur (kendiliğinden admin olunamaz)';
    insert into auth.users (id, email, raw_user_meta_data)
      values (gen_random_uuid(), 'adm.kotu@example.test', '{"role":"admin"}');
    select role into v_text from public.profiles where id = (select id from auth.users where email = 'adm.kotu@example.test');
    gecti := (v_text = 'ogrenci');
    detay := 'rol=' || v_text;
    return next;

    -- 2
    no := no + 1;
    senaryo := 'Veli kendini admin yapamaz (rol değişikliği istemciye kapalı)';
    begin
      perform set_config('request.jwt.claim.sub', v1::text, true);
      perform set_config('role', 'authenticated', true);
      update public.profiles set role = 'admin' where id = v1;
      perform set_config('role', 'none', true);
      perform set_config('request.jwt.claim.sub', '', true);
      gecti := false; detay := 'yükseltme başarılı oldu';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 3
    no := no + 1;
    senaryo := 'Admin olmayan biri hiçbir admin fonksiyonunu çağıramaz (8 fonksiyon denendi)';
    v_fail := 0;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform public.admin_list_questions(); exception when insufficient_privilege then v_fail := v_fail + 1; end;
    begin perform public.admin_dashboard_summary(); exception when insufficient_privilege then v_fail := v_fail + 1; end;
    begin perform public.admin_list_users(); exception when insufficient_privilege then v_fail := v_fail + 1; end;
    begin perform public.admin_list_payments(); exception when insufficient_privilege then v_fail := v_fail + 1; end;
    begin perform public.admin_import_questions('[]'::jsonb); exception when insufficient_privilege then v_fail := v_fail + 1; end;
    begin perform public.admin_set_question_status(array[]::uuid[], 'onaylandi'); exception when insufficient_privilege then v_fail := v_fail + 1; end;
    begin perform public.admin_upsert_plan('hack', 'x', null, 1, 1); exception when insufficient_privilege then v_fail := v_fail + 1; end;
    begin perform public.admin_link_child(o1, v2); exception when insufficient_privilege then v_fail := v_fail + 1; end;
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
    gecti := (v_fail = 8);
    detay := format('reddedilen=%s/8', v_fail);
    return next;

    -- 4
    no := no + 1;
    senaryo := 'Giriş yapmamış (anon) kullanıcı admin fonksiyonlarına erişemez';
    begin
      perform set_config('role', 'anon', true);
      perform public.admin_dashboard_summary();
      perform set_config('role', 'none', true);
      gecti := false; detay := 'erişim verildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 5
    no := no + 1;
    senaryo := 'is_admin(): admin için true, veli için false';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_int := case when public.is_admin() then 1 else 0 end;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    v_int2 := case when public.is_admin() then 1 else 0 end;
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
    gecti := (v_int = 1 and v_int2 = 0);
    detay := format('admin=%s, veli=%s', v_int, v_int2);
    return next;

    -- ---------------------------------------------------------------
    -- B) Soru yönetimi (admin)
    -- ---------------------------------------------------------------
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);

    -- 6
    no := no + 1;
    senaryo := 'Tekil soru eklenir: beklemede, doğru şık büyük harfe çevrilir, ekleyen kaydedilir';
    v_id := public.admin_upsert_question(null, v_q);
    perform set_config('role', 'none', true);
    select onay_durumu || '/' || dogru_sik || '/' || (created_by = adm)::text into v_text
      from public.questions where id = v_id;
    perform set_config('role', 'authenticated', true);
    gecti := (v_text = 'beklemede/B/true');
    detay := v_text;
    return next;

    -- 7
    no := no + 1;
    senaryo := 'Geçersiz soru (zorluk 5) anlaşılır bir hata ile reddedilir';
    begin
      perform public.admin_upsert_question(null, v_q || '{"zorluk": 5}'::jsonb);
      gecti := false; detay := 'kabul edildi';
    exception when invalid_parameter_value then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 8
    no := no + 1;
    senaryo := 'Soru güncellenir; olmayan soru için "bulunamadı" hatası verilir';
    perform public.admin_upsert_question(v_id, v_q || '{"soru_metni": "Güncel soru?", "onay_durumu": "onaylandi"}'::jsonb);
    perform set_config('role', 'none', true);
    select soru_metni || '/' || onay_durumu into v_text from public.questions where id = v_id;
    perform set_config('role', 'authenticated', true);
    begin
      perform public.admin_upsert_question(gen_random_uuid(), v_q);
      gecti := false; detay := 'olmayan soru güncellendi';
    exception when no_data_found then
      gecti := (v_text = 'Güncel soru?/onaylandi'); detay := v_text;
    end;
    return next;

    -- 9
    no := no + 1;
    senaryo := 'Listeleme: doğru şık ve çözüm adımları döner; Türkçe karaktersiz arama ("yuzde") çalışır';
    v_json := public.admin_list_questions(p_arama => 'yuzde');
    gecti := (v_json ->> 'toplam')::int >= 1
             and (v_json -> 'satirlar' -> 0 ->> 'dogru_sik') is not null
             and jsonb_typeof(v_json -> 'satirlar' -> 0 -> 'cozum_adimlari') = 'array'
             and (v_json -> 'satirlar' -> 0 ->> 'ders') = 'TestDers';
    detay := 'toplam=' || (v_json ->> 'toplam');
    return next;

    -- 10
    no := no + 1;
    senaryo := 'Toplu ekleme: geçerli satırlar eklenir, hatalı satır NUMARASIYLA bildirilir, tekrar atlanır';
    v_json := public.admin_import_questions(jsonb_build_array(
      v_q || '{"soru_metni": "Toplu 1?", "konu": "TopluKonu"}'::jsonb,
      v_q || '{"soru_metni": "Toplu 2?", "konu": "TopluKonu"}'::jsonb,
      v_q || '{"soru_metni": "Toplu 3?", "konu": "TopluKonu", "siklar": {"A": "1", "B": ""}}'::jsonb,
      v_q || '{"soru_metni": "TOPLU 1?", "konu": "TopluKonu"}'::jsonb));
    gecti := (v_json ->> 'eklenen')::int = 2
             and (v_json ->> 'tekrar')::int = 1
             and (v_json ->> 'hatali')::int = 1
             and (v_json -> 'hatalar' -> 0 ->> 'satir')::int = 3;
    detay := v_json::text;
    return next;

    -- 11
    no := no + 1;
    senaryo := 'Toplu ekleme varsayılan olarak "beklemede", p_onayla=true ile "onaylandi" ekler';
    v_json := public.admin_import_questions(jsonb_build_array(v_q || '{"soru_metni": "Onaysız?", "konu": "OnayKonu"}'::jsonb));
    v_json2 := public.admin_import_questions(
      jsonb_build_array(v_q || '{"soru_metni": "Onaylı?", "konu": "OnayKonu"}'::jsonb), true);
    perform set_config('role', 'none', true);
    select count(*) filter (where onay_durumu = 'beklemede'), count(*) filter (where onay_durumu = 'onaylandi')
      into v_int, v_int2
      from public.questions where konu = 'OnayKonu';
    perform set_config('role', 'authenticated', true);
    gecti := (v_int = 1 and v_int2 = 1);
    detay := format('beklemede=%s, onaylandi=%s', v_int, v_int2);
    return next;

    -- 12
    no := no + 1;
    senaryo := '"Hepsi ya da hiçbiri" seçilirse tek hata bile varsa HİÇBİR satır eklenmez';
    perform set_config('role', 'none', true);
    select count(*) into v_int from public.questions;
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_import_questions(jsonb_build_array(
      v_q || '{"soru_metni": "Hepsi 1?", "konu": "HHKonu"}'::jsonb,
      v_q || '{"soru_metni": "Hepsi 2?", "konu": "HHKonu", "zorluk": 9}'::jsonb), false, true);
    perform set_config('role', 'none', true);
    select count(*) into v_int2 from public.questions;
    perform set_config('role', 'authenticated', true);
    gecti := (v_json ->> 'eklenen')::int = 0 and v_int = v_int2 and (v_json ->> 'hatali')::int = 1;
    detay := format('önce=%s, sonra=%s', v_int, v_int2);
    return next;

    -- 13
    no := no + 1;
    senaryo := 'Tek seferde 1000''den fazla satır reddedilir';
    begin
      perform public.admin_import_questions(
        (select jsonb_agg(v_q) from generate_series(1, 1001)));
      gecti := false; detay := 'kabul edildi';
    exception when invalid_parameter_value then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 14
    no := no + 1;
    senaryo := 'Toplu durum değişikliği: seçilen sorular onaylanır';
    perform set_config('role', 'none', true);
    select array_agg(id) into v_ids from public.questions where konu = 'TopluKonu';
    perform set_config('role', 'authenticated', true);
    v_int := public.admin_set_question_status(v_ids, 'onaylandi');
    perform set_config('role', 'none', true);
    select count(*) into v_int2 from public.questions where konu = 'TopluKonu' and onay_durumu = 'onaylandi';
    perform set_config('role', 'authenticated', true);
    gecti := (v_int = 2 and v_int2 = 2);
    detay := format('güncellenen=%s', v_int);
    return next;

    -- 15
    no := no + 1;
    senaryo := 'Soru silinir; geçersiz durum değeri reddedilir';
    v_int := public.admin_delete_questions(array[v_id]);
    begin
      perform public.admin_set_question_status(v_ids, 'gizli');
      gecti := false; detay := 'geçersiz durum kabul edildi';
    exception when invalid_parameter_value then
      gecti := (v_int = 1); detay := 'silinen=' || v_int;
    end;
    return next;

    -- ---------------------------------------------------------------
    -- C) Kullanıcı yönetimi
    -- ---------------------------------------------------------------

    -- 16
    no := no + 1;
    senaryo := 'Kullanıcı listesi: e-posta ve rol döner; role ve aramaya göre süzülür';
    v_json := public.admin_list_users('veli', 'ayse');
    gecti := (v_json ->> 'toplam')::int = 1
             and (v_json -> 'satirlar' -> 0 ->> 'email') = 'adm.veli1@example.test'
             and (v_json -> 'satirlar' -> 0 ->> 'rol') = 'veli';
    detay := v_json::text;
    return next;

    -- 17
    no := no + 1;
    senaryo := 'Veli–çocuk bağı admin panelinden kurulur ve kaldırılır';
    perform public.admin_link_child(o1, v1);
    perform set_config('role', 'none', true);
    select parent_id into v_id2 from public.profiles where id = o1;
    perform set_config('role', 'authenticated', true);
    v_int := case when v_id2 = v1 then 1 else 0 end;
    perform public.admin_link_child(o1, null);
    perform set_config('role', 'none', true);
    select parent_id into v_id2 from public.profiles where id = o1;
    perform set_config('role', 'authenticated', true);
    gecti := (v_int = 1 and v_id2 is null);
    detay := 'bağ kuruldu=' || v_int;
    return next;

    -- 18
    no := no + 1;
    senaryo := 'Bağ kurarken rol kontrolü: çocuk veliye değil çocuğa bağlanamaz';
    begin
      perform public.admin_link_child(o1, o1);
      gecti := false; detay := 'çocuk çocuğa bağlandı';
    exception when no_data_found then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 19
    no := no + 1;
    senaryo := 'Admin başkasının rolünü doğrudan güncelleyemez (satır düzeyi güvenlik)';
    update public.profiles set role = 'admin' where id = v2;
    get diagnostics v_rows = row_count;
    perform set_config('role', 'none', true);
    select role into v_text from public.profiles where id = v2;
    perform set_config('role', 'authenticated', true);
    gecti := (v_rows = 0 and v_text = 'veli');
    detay := format('etkilenen=%s, rol=%s', v_rows, v_text);
    return next;

    -- ---------------------------------------------------------------
    -- D) Ödeme yönetimi
    -- ---------------------------------------------------------------

    -- 20
    no := no + 1;
    senaryo := 'Plan eklenir/güncellenir (tutar kuruş, para birimi TRY); geçersiz plan kodu reddedilir';
    perform public.admin_upsert_plan('aylik', 'Aylık', 'Test', 14990, 30);
    perform public.admin_upsert_plan('aylik', 'Aylık Premium', 'Test', 12990, 30);
    select fiyat_kurus::text || '/' || ad || '/' || para_birimi into v_text from public.plans where kod = 'aylik';
    begin
      perform public.admin_upsert_plan('Kötü Kod!', 'x', null, 1, 1);
      gecti := false; detay := 'geçersiz kod kabul edildi';
    exception when invalid_parameter_value then
      gecti := (v_text = '12990/Aylık Premium/TRY'); detay := v_text;
    end;
    return next;

    -- 21
    no := no + 1;
    senaryo := 'Başarılı elle ödeme kaydı aktif abonelik oluşturur (bitiş = plan süresi kadar sonra)';
    v_id := public.admin_record_payment(v1, 'aylik', 12990, 'basarili', 'EFT');
    select s.durum || '/' || round(extract(epoch from (s.bitis - now())) / 86400)::int::text into v_text
      from public.payments p join public.subscriptions s on s.id = p.subscription_id where p.id = v_id;
    gecti := (v_text = 'aktif/30');
    detay := v_text;
    return next;

    -- 22
    no := no + 1;
    senaryo := 'Bekleyen ödeme abonelik oluşturmaz; olmayan veli/plan reddedilir';
    v_id2 := public.admin_record_payment(v1, 'aylik', 5000, 'beklemede', null);
    select subscription_id::text into v_text from public.payments where id = v_id2;
    v_fail := 0;
    begin perform public.admin_record_payment(gen_random_uuid(), 'aylik', 1, 'basarili', null);
      exception when no_data_found then v_fail := v_fail + 1; end;
    begin perform public.admin_record_payment(v1, 'yok_plan', 1, 'basarili', null);
      exception when no_data_found then v_fail := v_fail + 1; end;
    gecti := (v_text is null and v_fail = 2);
    detay := format('abonelik=%s, reddedilen=%s/2', coalesce(v_text, 'yok'), v_fail);
    return next;

    -- 23
    no := no + 1;
    senaryo := 'Ödeme listesi: toplam tutara yalnızca BAŞARILI ödemeler girer; durum ve tarih süzgeci çalışır';
    v_json := public.admin_list_payments();
    v_json2 := public.admin_list_payments('beklemede');
    gecti := (v_json ->> 'basarili_tutar_kurus')::bigint = 12990
             and (v_json ->> 'toplam')::int = 2
             and (v_json2 ->> 'toplam')::int = 1
             and (v_json -> 'satirlar' -> 0 ->> 'veli_email') = 'adm.veli1@example.test'
             and public.admin_list_payments(null, current_date + 1, null) ->> 'toplam' = '0';
    detay := format('başarılı tutar=%s kuruş', v_json ->> 'basarili_tutar_kurus');
    return next;

    -- 24
    no := no + 1;
    senaryo := 'Panel özeti: kullanıcı/soru/ödeme sayıları ve son 6 ay gelir serisi (₺ kuruş cinsinden)';
    v_json := public.admin_dashboard_summary();
    gecti := (v_json -> 'kullanicilar' ->> 'veli')::int >= 2
             and (v_json -> 'sorular' ->> 'toplam')::int >= 1
             and (v_json -> 'odemeler' ->> 'bu_ay_kurus')::bigint = 12990
             and (v_json -> 'odemeler' ->> 'bekleyen_adet')::int = 1
             and jsonb_array_length(v_json -> 'odemeler' -> 'aylik') = 6
             and (v_json -> 'odemeler' -> 'aylik' -> 5 ->> 'tutar_kurus')::bigint = 12990
             and (v_json -> 'abonelikler' ->> 'aktif')::int = 1
             and jsonb_array_length(v_json -> 'son_islemler') > 0;
    detay := 'bu ay=' || (v_json -> 'odemeler' ->> 'bu_ay_kurus');
    return next;

    -- 25
    no := no + 1;
    senaryo := 'İade işaretlenince bağlı abonelik iptal edilir';
    perform public.admin_set_payment_status(v_id, 'iade');
    select durum into v_text from public.subscriptions where veli_id = v1 and plan_kod = 'aylik';
    gecti := (v_text = 'iptal');
    detay := 'abonelik=' || v_text;
    return next;

    -- 26
    no := no + 1;
    senaryo := 'İşlem geçmişi: yapılan admin işlemleri kaydedilir';
    select count(*) into v_int from public.admin_audit_log where admin_id = adm;
    select count(*) into v_int2 from public.admin_audit_log
     where admin_id = adm and islem in ('soru_eklendi', 'toplu_soru_eklendi', 'odeme_kaydedildi', 'plan_kaydedildi');
    gecti := (v_int >= 10 and v_int2 >= 4);
    detay := format('toplam kayıt=%s', v_int);
    return next;

    -- ---------------------------------------------------------------
    -- E) Diğer kullanıcıların gözünden (RLS)
    -- ---------------------------------------------------------------

    -- 27
    no := no + 1;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    senaryo := 'Veli yalnızca KENDİ ödemelerini ve aboneliğini görür; başkasınınkini göremez';
    select count(*) into v_int from public.payments;
    select count(*) into v_int2 from public.payments where veli_id = v1;
    perform set_config('request.jwt.claim.sub', v2::text, true);
    select count(*) into v_rows from public.payments;
    gecti := (v_int = 2 and v_int2 = 2 and v_rows = 0);
    detay := format('v1 görür=%s, v2 görür=%s', v_int, v_rows);
    return next;

    -- 28
    no := no + 1;
    senaryo := 'Veli ödeme kaydı EKLEYEMEZ (yalnızca sağlayıcı webhook''u / admin)';
    begin
      perform set_config('request.jwt.claim.sub', v1::text, true);
      insert into public.payments (veli_id, tutar_kurus, durum) values (v1, 1, 'basarili');
      gecti := false; detay := 'ekleme yapılabildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    perform set_config('role', 'authenticated', true);
    return next;

    -- 29
    no := no + 1;
    senaryo := 'Çocuk ödemeleri ve işlem geçmişini göremez';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    select count(*) into v_int from public.payments;
    select count(*) into v_int2 from public.admin_audit_log;
    gecti := (v_int = 0 and v_int2 = 0);
    detay := format('ödeme=%s, geçmiş=%s', v_int, v_int2);
    return next;

    -- 30
    no := no + 1;
    senaryo := 'Öğrenci BEKLEYEN soruyu göremez (yalnızca onaylılar); admin hepsini görür';
    select count(*) into v_int from public.questions where onay_durumu = 'beklemede';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    v_json := public.admin_list_questions(p_durum => 'beklemede');
    gecti := (v_int = 0 and (v_json ->> 'toplam')::int >= 1);
    detay := format('öğrenci görür=%s, admin görür=%s', v_int, v_json ->> 'toplam');
    return next;

    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);

    raise exception 'TEST_GERI_AL' using errcode = 'P0001';
  exception when others then
    if sqlerrm <> 'TEST_GERI_AL' then
      no := no + 1;
      senaryo := 'BEKLENMEYEN HATA (testler yarıda kesildi)';
      gecti := false;
      detay := sqlstate || ': ' || sqlerrm;
      return next;
    end if;
  end;

  return;
end;
$fn$;

select no, senaryo, gecti, detay
  from pg_temp.admin_testleri()
 order by no;
