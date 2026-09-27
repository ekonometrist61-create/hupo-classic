-- =====================================================================
-- ÖDEME (iyzico) SUNUCU TARAFI TEST SENARYOLARI
-- Nasıl çalıştırılır: Supabase SQL Editor'e yapıştırıp Run. Kalıcı kayıt bırakmaz.
-- Ön koşul: 20260920001100_payments_iyzico.sql uygulanmış olmalı.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.odeme_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm uuid := gen_random_uuid();
  v1  uuid := gen_random_uuid();
  v2  uuid := gen_random_uuid();
  o1  uuid := gen_random_uuid();   -- v1'in çocuğu
  o2  uuid := gen_random_uuid();   -- bağsız çocuk
  v_json  jsonb;
  v_json2 jsonb;
  v_pid   uuid;
  v_pid2  uuid;
  v_int   integer;
  v_int2  integer;
  v_text  text;
  v_bool  boolean;
  v_ts    timestamptz;
  v_ts2   timestamptz;
  v_q     uuid[] := array[gen_random_uuid(), gen_random_uuid(), gen_random_uuid()];
  i       integer;
begin
  no := 0;
  begin
    insert into auth.users (id, email, raw_user_meta_data) values
      (adm, 'pay.adm@example.test', '{"role":"veli","full_name":"Pay Admin"}'),
      (v1,  'pay.v1@example.test',  '{"role":"veli","full_name":"Veli Bir"}'),
      (v2,  'pay.v2@example.test',  '{"role":"veli","full_name":"Veli Iki"}'),
      (o1,  'pay.o1@example.test',  '{"role":"ogrenci","full_name":"Cocuk Bir"}'),
      (o2,  'pay.o2@example.test',  '{"role":"ogrenci","full_name":"Cocuk Iki"}');
    update public.profiles set role = 'admin' where id = adm;
    update public.profiles set parent_id = v1 where id = o1;

    insert into public.plans (kod, ad, aciklama, fiyat_kurus, sure_gun, aktif, sira) values
      ('t_aylik', 'Test Aylık', 'x', 14990, 30, true, 1),
      ('t_yillik', 'Test Yıllık', 'y', 100, 365, true, 2),
      ('t_kapali', 'Test Kapalı', 'z', 5000, 30, false, 3);
    update public.plans set aktif = false where kod in ('aylik', 'yillik');

    for i in 1..3 loop
      insert into public.questions (id, okul, ders, konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu)
      values (v_q[i], 'ortaokul', 'TestDers', 'Konu', 1, 'Soru ' || i,
              '{"A":"1","B":"2"}'::jsonb, 'A', 'onaylandi');
    end loop;

    -- 1
    no := no + 1;
    senaryo := 'payment_create_pending: tutar plans tablosundan (14990), durum beklemede, saglayici iyzico';
    perform set_config('role', 'service_role', true);
    v_json := public.payment_create_pending(v1, 't_aylik');
    perform set_config('role', 'none', true);
    v_pid := (v_json ->> 'payment_id')::uuid;
    select tutar_kurus, durum into v_int, v_text from public.payments where id = v_pid;
    gecti := v_int = 14990 and v_text = 'beklemede' and (v_json ->> 'tutar_kurus')::int = 14990
             and (select saglayici from public.payments where id = v_pid) = 'iyzico';
    detay := v_json::text;
    return next;

    -- 2
    no := no + 1;
    senaryo := 'Plan fiyatı DB''den okunur: fiyat değişince yeni bekleyen ödeme yeni fiyatı alır';
    update public.plans set fiyat_kurus = 15990 where kod = 't_aylik';
    perform set_config('role', 'service_role', true);
    v_json2 := public.payment_create_pending(v1, 't_aylik');
    perform set_config('role', 'none', true);
    gecti := (v_json2 ->> 'tutar_kurus')::int = 15990
             and (select tutar_kurus from public.payments where id = v_pid) = 14990;
    update public.plans set fiyat_kurus = 14990 where kod = 't_aylik';
    delete from public.payments where id = (v_json2 ->> 'payment_id')::uuid;
    detay := v_json2::text;
    return next;

    -- 3
    no := no + 1;
    senaryo := 'Pasif plan ve çocuk hesabı için bekleyen ödeme oluşturulamaz';
    v_bool := false; v_text := '';
    perform set_config('role', 'service_role', true);
    begin perform public.payment_create_pending(v1, 't_kapali'); v_bool := true;
    exception when others then v_text := sqlstate; end;
    begin perform public.payment_create_pending(o1, 't_aylik'); v_bool := true;
    exception when others then v_text := v_text || ',' || sqlstate; end;
    perform set_config('role', 'none', true);
    gecti := not v_bool and v_text = 'P0002,42501';
    detay := v_text;
    return next;

    -- 4
    no := no + 1;
    senaryo := 'payment_set_token kaydeder; payment_get token ve tutarı döner';
    perform set_config('role', 'service_role', true);
    perform public.payment_set_token(v_pid, 'tok_test_123456789');
    v_json := public.payment_get(v_pid);
    perform set_config('role', 'none', true);
    gecti := v_json ->> 'iyzico_token' = 'tok_test_123456789' and (v_json ->> 'tutar_kurus')::int = 14990;
    detay := v_json::text;
    return next;

    -- 5
    no := no + 1;
    senaryo := 'Yanlış tutar: ödeme basarisiz, abonelik OLUŞMAZ, not düşülür';
    perform set_config('role', 'service_role', true);
    v_json2 := public.payment_create_pending(v2, 't_aylik');
    v_pid2 := (v_json2 ->> 'payment_id')::uuid;
    v_json := public.payment_complete(v_pid2, 'iyz-pay-MISMATCH', 100, '{"paymentStatus":"SUCCESS"}');
    perform set_config('role', 'none', true);
    select durum, hata_nedeni into v_text, detay from public.payments where id = v_pid2;
    gecti := v_json ->> 'sonuc' = 'tutar_uyusmazligi' and v_text = 'basarisiz'
             and detay like 'TUTAR_UYUSMAZLIGI%'
             and not exists (select 1 from public.subscriptions where veli_id = v2);
    detay := v_json::text || ' | ' || coalesce(detay, '');
    return next;

    -- 6
    no := no + 1;
    senaryo := 'payment_complete: doğru tutar -> basarili + 30 günlük abonelik';
    perform set_config('role', 'service_role', true);
    v_json := public.payment_complete(v_pid, 'iyz-pay-1', 14990,
      '{"paymentStatus":"SUCCESS","paymentId":"iyz-pay-1","paidPrice":149.9,"cardNumber":"5528790000000008","binNumber":"552879","buyer":{"x":1}}');
    perform set_config('role', 'none', true);
    select p.durum, s.bitis, s.baslangic into v_text, v_ts, v_ts2
      from public.payments p join public.subscriptions s on s.id = p.subscription_id where p.id = v_pid;
    gecti := v_json ->> 'sonuc' = 'tamamlandi' and v_text = 'basarili'
             and v_ts - v_ts2 = interval '30 days';
    detay := v_json::text;
    return next;

    -- 7
    no := no + 1;
    senaryo := 'payment_complete idempotent: ikinci çağrı yeni abonelik açmaz';
    perform set_config('role', 'service_role', true);
    v_json := public.payment_complete(v_pid, 'iyz-pay-1', 14990, null);
    perform set_config('role', 'none', true);
    select count(*)::int into v_int from public.subscriptions where veli_id = v1;
    gecti := v_json ->> 'sonuc' = 'zaten_islendi' and v_int = 1;
    detay := v_json::text || ' abonelik=' || v_int;
    return next;

    -- 8
    no := no + 1;
    senaryo := 'Ham veri beyaz listeden geçer: kart numarası/bin/buyer saklanmaz';
    select ham into v_json from public.payments where id = v_pid;
    gecti := v_json ? 'paymentStatus' and not (v_json ? 'cardNumber') and not (v_json ? 'binNumber')
             and not (v_json ? 'buyer') and v_json::text not like '%5528790000000008%';
    detay := v_json::text;
    return next;

    -- 9
    no := no + 1;
    senaryo := 'Aynı plan tekrar alınınca süre mevcut bitişten uzar (60 gün)';
    perform set_config('role', 'service_role', true);
    v_json2 := public.payment_create_pending(v1, 't_aylik');
    v_pid2 := (v_json2 ->> 'payment_id')::uuid;
    perform public.payment_complete(v_pid2, 'iyz-pay-2', 14990, null);
    perform set_config('role', 'none', true);
    select s.baslangic, s.bitis into v_ts, v_ts2
      from public.payments p join public.subscriptions s on s.id = p.subscription_id where p.id = v_pid2;
    gecti := v_ts = (select s.bitis from public.subscriptions s join public.payments p on p.subscription_id = s.id where p.id = v_pid)
             and v_ts2 - now() between interval '59 days 23 hours' and interval '60 days';
    detay := 'baslangic=' || v_ts || ' bitis=' || v_ts2;
    return next;

    -- 10
    no := no + 1;
    senaryo := 'Farklı plan satın alma şimdi başlar (uzatma yalnızca aynı planda)';
    perform set_config('role', 'service_role', true);
    v_json2 := public.payment_create_pending(v1, 't_yillik');
    v_pid2 := (v_json2 ->> 'payment_id')::uuid;
    perform public.payment_complete(v_pid2, 'iyz-pay-3', 100, null);
    perform set_config('role', 'none', true);
    select s.baslangic into v_ts from public.payments p join public.subscriptions s on s.id = p.subscription_id where p.id = v_pid2;
    gecti := v_ts = now();
    detay := v_ts::text;
    return next;

    -- 11
    no := no + 1;
    senaryo := 'payment_fail: bekleyen -> basarisiz; başarılı ödeme asla düşürülmez';
    perform set_config('role', 'service_role', true);
    v_json2 := public.payment_create_pending(v2, 't_aylik');
    v_pid2 := (v_json2 ->> 'payment_id')::uuid;
    v_json := public.payment_fail(v_pid2, 'FAILURE');
    v_json2 := public.payment_fail(v_pid, 'FAILURE');
    perform set_config('role', 'none', true);
    gecti := (select durum from public.payments where id = v_pid2) = 'basarisiz'
             and (select durum from public.payments where id = v_pid) = 'basarili'
             and v_json2 ->> 'sonuc' = 'islenmis_degistirilmedi';
    detay := v_json::text || v_json2::text;
    return next;

    -- 12
    no := no + 1;
    senaryo := 'Başarısız ödeme sonradan payment_complete ile canlandırılamaz';
    perform set_config('role', 'service_role', true);
    v_json := public.payment_complete(v_pid2, 'iyz-late', 14990, null);
    perform set_config('role', 'none', true);
    gecti := v_json ->> 'sonuc' = 'islenmis_degistirilmedi'
             and not exists (select 1 from public.subscriptions where veli_id = v2);
    detay := v_json::text;
    return next;

    -- 13
    no := no + 1;
    senaryo := 'Aynı iyzico paymentId ikinci bir ödemeye bağlanamaz (unique)';
    v_bool := false;
    perform set_config('role', 'service_role', true);
    v_json2 := public.payment_create_pending(v2, 't_aylik');
    begin
      perform public.payment_complete((v_json2 ->> 'payment_id')::uuid, 'iyz-pay-1', 14990, null);
    exception when unique_violation then v_bool := true; end;
    perform set_config('role', 'none', true);
    gecti := v_bool;
    detay := '';
    return next;

    -- 14
    no := no + 1;
    senaryo := 'RLS: veli yalnızca kendi ödemelerini görür';
    perform set_config('request.jwt.claim.sub', v2::text, true);
    perform set_config('role', 'authenticated', true);
    select count(*)::int into v_int from public.payments where veli_id = v1;
    select count(*)::int into v_int2 from public.payments where veli_id = v2;
    perform set_config('role', 'none', true);
    gecti := v_int = 0 and v_int2 > 0;
    detay := 'v1 satırı=' || v_int || ' v2 satırı=' || v_int2;
    return next;

    -- 15
    no := no + 1;
    senaryo := 'Çocuk hesabı (velisinin bile) ödemelerini listeleyemez; my_payments boş';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    select count(*)::int into v_int from public.payments;
    v_json := public.my_payments();
    perform set_config('role', 'none', true);
    gecti := v_int = 0 and jsonb_array_length(v_json) = 0;
    detay := 'satir=' || v_int;
    return next;

    -- 16
    no := no + 1;
    senaryo := 'anon: payments, app_settings ve RPC''ler reddedilir';
    v_text := '';
    perform set_config('request.jwt.claim.sub', '', true);
    perform set_config('role', 'anon', true);
    begin perform count(*) from public.payments; v_text := v_text || 'A'; exception when others then null; end;
    begin perform count(*) from public.app_settings; v_text := v_text || 'B'; exception when others then null; end;
    begin perform public.my_subscription_status(); v_text := v_text || 'C'; exception when others then null; end;
    begin perform public.list_active_plans(); v_text := v_text || 'D'; exception when others then null; end;
    perform set_config('role', 'none', true);
    gecti := v_text = '';
    detay := 'geçenler=' || v_text;
    return next;

    -- 17
    no := no + 1;
    senaryo := 'my_payments: velinin listesi (yalnızca kendi, hassas alan yok)';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.my_payments();
    perform set_config('role', 'none', true);
    gecti := jsonb_array_length(v_json) = (select count(*) from public.payments where veli_id = v1)
             and not (v_json -> 0 ? 'iyzico_token') and not (v_json -> 0 ? 'ham');
    detay := v_json ->> 0;
    return next;

    -- 18
    no := no + 1;
    senaryo := 'list_active_plans: yalnızca aktif planlar, sira sırasıyla';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    select string_agg(kod, ',' order by ord) into v_text
      from (select kod, row_number() over () ord from public.list_active_plans()) x;
    perform set_config('role', 'none', true);
    gecti := v_text = 't_aylik,t_yillik';
    detay := v_text;
    return next;

    -- 19
    no := no + 1;
    senaryo := 'Servis fonksiyonları authenticated ve anon tarafından çağrılamaz';
    v_text := '';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform public.payment_create_pending(v1, 't_aylik'); v_text := v_text || 'a'; exception when others then null; end;
    begin perform public.payment_complete(v_pid, 'x', 1, null); v_text := v_text || 'b'; exception when others then null; end;
    begin perform public.payment_fail(v_pid, 'x'); v_text := v_text || 'c'; exception when others then null; end;
    begin perform public.payment_get(v_pid); v_text := v_text || 'd'; exception when others then null; end;
    begin perform public.is_premium(v1); v_text := v_text || 'e'; exception when others then null; end;
    begin perform public.can_start_quiz(v1); v_text := v_text || 'f'; exception when others then null; end;
    perform set_config('role', 'anon', true);
    begin perform public.payment_complete(v_pid, 'x', 1, null); v_text := v_text || 'g'; exception when others then null; end;
    perform set_config('role', 'none', true);
    gecti := v_text = '';
    detay := 'geçenler=' || v_text;
    return next;

    -- 20
    no := no + 1;
    senaryo := 'Veli payments/subscriptions tablosuna doğrudan yazamaz (sahte abonelik yok)';
    v_text := '';
    perform set_config('request.jwt.claim.sub', v2::text, true);
    perform set_config('role', 'authenticated', true);
    begin insert into public.subscriptions (veli_id, plan_kod, durum, bitis) values (v2, 't_aylik', 'aktif', now() + interval '1 year'); v_text := v_text || 's'; exception when others then null; end;
    begin update public.payments set durum = 'basarili' where veli_id = v2; get diagnostics v_int = row_count; if v_int > 0 then v_text := v_text || 'u'; end if; exception when others then null; end;
    perform set_config('role', 'none', true);
    gecti := v_text = '';
    detay := v_text;
    return next;

    -- 21
    no := no + 1;
    senaryo := 'my_subscription_status: veli kendi aktif aboneliğini görür (kaynak kendi)';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.my_subscription_status();
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'aktif')::boolean and v_json ->> 'kaynak' = 'kendi'
             and v_json ->> 'plan_kod' is not null and (v_json ->> 'kalan_gun')::int > 0;
    detay := v_json::text;
    return next;

    -- 22
    no := no + 1;
    senaryo := 'Çocuk, velisinin premium''unu devralır (kaynak veli); bağsız çocuk devralmaz';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.my_subscription_status();
    perform set_config('request.jwt.claim.sub', o2::text, true);
    v_json2 := public.my_subscription_status();
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'aktif')::boolean and v_json ->> 'kaynak' = 'veli'
             and not (v_json2 ->> 'aktif')::boolean and (v_json ->> 'gating_aktif')::boolean = false;
    detay := v_json::text || ' / ' || v_json2::text;
    return next;

    -- 23
    no := no + 1;
    senaryo := 'Admin: aktif = true; aboneliği olmayan veli: aktif = false';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.my_subscription_status();
    perform set_config('request.jwt.claim.sub', v2::text, true);
    v_json2 := public.my_subscription_status();
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'aktif')::boolean and not (v_json2 ->> 'aktif')::boolean;
    detay := v_json2::text;
    return next;

    -- 24
    no := no + 1;
    senaryo := 'Gating KAPALI (varsayılan): kota yok, sınırsız cevap; kalan = null';
    perform set_config('request.jwt.claim.sub', o2::text, true);
    perform set_config('role', 'authenticated', true);
    for i in 1..3 loop perform public.submit_answer(v_q[i], 'A', 1000); end loop;
    v_json := public.my_quiz_quota();
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'izinli')::boolean and v_json -> 'kalan' = 'null'::jsonb
             and (select count(*) from public.answer_events where student_id = o2) = 3;
    detay := v_json::text;
    return next;

    -- 25
    no := no + 1;
    senaryo := 'admin_set_setting: veli reddedilir, admin başarılı ve audit log yazılır';
    v_bool := false; v_text := '';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform public.admin_set_setting('premium_gating', '{"aktif":true,"ucretsiz_gunluk_soru":2}'); v_bool := true;
    exception when others then v_text := sqlstate; end;
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform public.admin_set_setting('premium_gating', '{"aktif":true,"ucretsiz_gunluk_soru":2}');
    perform set_config('role', 'none', true);
    gecti := not v_bool and v_text = '42501'
             and (select (value ->> 'aktif')::boolean from public.app_settings where key = 'premium_gating')
             and exists (select 1 from public.admin_audit_log where islem = 'ayar_degisti' and admin_id = adm);
    detay := v_text;
    return next;

    -- 26
    no := no + 1;
    senaryo := 'Ayar doğrulaması: bilinmeyen anahtar/hatalı değer reddedilir; istemci app_settings''e yazamaz';
    v_text := '';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform public.admin_set_setting('baska', '{}'); v_text := v_text || 'a'; exception when others then null; end;
    begin perform public.admin_set_setting('premium_gating', '{"aktif":"evet","ucretsiz_gunluk_soru":5}'); v_text := v_text || 'b'; exception when others then null; end;
    begin perform public.admin_set_setting('premium_gating', '{"aktif":true,"ucretsiz_gunluk_soru":-5}'); v_text := v_text || 'c'; exception when others then null; end;
    begin update public.app_settings set value = '{"aktif":false,"ucretsiz_gunluk_soru":9999}'; get diagnostics v_int = row_count; if v_int > 0 then v_text := v_text || 'd'; end if; exception when others then null; end;
    perform set_config('role', 'none', true);
    gecti := v_text = '';
    detay := v_text;
    return next;

    -- 27 (o2: bugün zaten 3 cevabı var, kota 2)
    no := no + 1;
    senaryo := 'Gating AÇIK: ücretsiz kota dolunca yeni cevap reddedilir (P0402), kalan = 0';
    v_text := '';
    perform set_config('request.jwt.claim.sub', o2::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform public.submit_answer(v_q[1], 'A', 1000); exception when others then v_text := sqlstate; end;
    v_json := public.my_quiz_quota();
    perform set_config('role', 'none', true);
    gecti := v_text = 'P0402' and (v_json ->> 'kalan')::int = 0 and not (v_json ->> 'izinli')::boolean;
    detay := v_text || ' ' || v_json::text;
    return next;

    -- 28
    no := no + 1;
    senaryo := 'Gating AÇIK: premium velinin çocuğu kotadan muaf, sınırsız cevaplar';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    for i in 1..3 loop perform public.submit_answer(v_q[i], 'A', 1000); end loop;
    v_json := public.my_quiz_quota();
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'izinli')::boolean and (v_json ->> 'premium')::boolean
             and (select count(*) from public.answer_events where student_id = o1) = 3;
    detay := v_json::text;
    return next;

    -- 29
    no := no + 1;
    senaryo := 'Gating AÇIK: kota dolmadıkça (2 hak) cevap serbest, kalan doğru azalır';
    delete from public.answer_events where student_id = o2;
    delete from public.user_answers where student_id = o2;
    perform set_config('request.jwt.claim.sub', o2::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.submit_answer(v_q[1], 'A', 1000);
    v_json := public.my_quiz_quota();
    perform public.submit_answer(v_q[2], 'A', 1000);
    v_json2 := public.my_quiz_quota();
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'kalan')::int = 1 and (v_json2 ->> 'kalan')::int = 0;
    detay := v_json::text || v_json2::text;
    return next;

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
  from pg_temp.odeme_testleri()
 order by no;
