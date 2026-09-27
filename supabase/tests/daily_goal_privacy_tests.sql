-- =====================================================================
-- GÜNLÜK HEDEF, SERİ KALKANI VE GİZLİLİK (KVKK) TEST SENARYOLARI
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: test verileri iş bitince geri alınır.
-- Ön koşul: 20260920000800_daily_goal_shield_privacy.sql uygulanmış olmalı.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.hedef_gizlilik_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v1 uuid := gen_random_uuid();   -- o1'in velisi
  v2 uuid := gen_random_uuid();   -- yabancı veli
  o1 uuid := gen_random_uuid();   -- hedef ve gizlilik testleri
  o2 uuid := gen_random_uuid();   -- yetki testleri, hesap silme
  o3 uuid := gen_random_uuid();   -- kalkan kazanma
  o4 uuid := gen_random_uuid();   -- kalkan kullanma
  o5 uuid := gen_random_uuid();   -- kalkansız ara

  q_id     uuid := gen_random_uuid();
  v_json   jsonb;
  v_int    integer;
  v_int2   integer;
  v_text   text;
  v_bool   boolean;
  v_today  date := (now() at time zone 'Europe/Istanbul')::date;
begin
  no := 0;

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (v1, 'hg.veli1@example.test', '{"role":"veli"}'),
      (v2, 'hg.veli2@example.test', '{"role":"veli"}'),
      (o1, 'hg.cocuk1@example.test', '{"role":"ogrenci","full_name":"Test Bir"}'),
      (o2, 'hg.cocuk2@example.test', '{"role":"ogrenci"}'),
      (o3, 'hg.cocuk3@example.test', '{"role":"ogrenci"}'),
      (o4, 'hg.cocuk4@example.test', '{"role":"ogrenci"}'),
      (o5, 'hg.cocuk5@example.test', '{"role":"ogrenci"}');
    update public.profiles set parent_id = v1 where id in (o1);

    insert into public.questions (id, okul, ders, konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu)
      values (q_id, 'ortaokul', 'TestDers', 'TestKonu', 1, 'Test sorusu?', '{"A":"1","B":"2"}', 'A', 'onaylandi');

    -- ---------------------------------------------------------------
    -- A) Günlük hedef
    -- ---------------------------------------------------------------

    -- 1
    no := no + 1;
    senaryo := 'Yeni öğrencinin günlük hedefi varsayılan 10 sorudur';
    select gunluk_hedef into v_int from public.student_stats where student_id = o1;
    gecti := (v_int = 10);
    detay := 'hedef=' || v_int;
    return next;

    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);

    -- 2
    no := no + 1;
    senaryo := 'Öğrenci kendi günlük hedefini değiştirebilir (15)';
    perform public.set_daily_goal(15);
    v_json := public.get_daily_goal(o1);
    gecti := (v_json ->> 'hedef')::int = 15 and (v_json ->> 'bugun')::int = 0
             and (v_json ->> 'tamamlandi')::boolean = false;
    detay := v_json::text;
    return next;

    -- 3
    no := no + 1;
    senaryo := 'Geçersiz hedef (7) reddedilir';
    begin
      perform public.set_daily_goal(7);
      gecti := false; detay := 'kabul edildi';
    exception when invalid_parameter_value then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 4
    no := no + 1;
    senaryo := 'Öğrenci başka bir öğrencinin hedefini değiştiremez';
    begin
      perform public.set_daily_goal(5, o2);
      gecti := false; detay := 'değiştirilebildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    perform set_config('request.jwt.claim.sub', v1::text, true);

    -- 5
    no := no + 1;
    senaryo := 'Veli, kendi çocuğunun günlük hedefini değiştirebilir';
    perform public.set_daily_goal(5, o1);
    v_int := (public.get_daily_goal(o1) ->> 'hedef')::int;
    gecti := (v_int = 5);
    detay := 'hedef=' || v_int;
    return next;

    perform set_config('request.jwt.claim.sub', v2::text, true);

    -- 6
    no := no + 1;
    senaryo := 'Yabancı veli başkasının çocuğunun hedefini değiştiremez';
    begin
      perform public.set_daily_goal(20, o1);
      gecti := false; detay := 'değiştirilebildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);

    -- 7: hedef 5; 5 cevap → bildirim (bir kez)
    no := no + 1;
    senaryo := 'Günlük hedefe ulaşılınca bildirim gelir ve yalnızca bir kez gelir';
    for i in 1..5 loop
      insert into public.answer_events (student_id, question_id, dogru_mu, sure_ms)
        values (o1, q_id, true, 1000);
    end loop;
    select count(*) into v_int from public.notifications
     where alici_id = o1 and baslik = 'Günlük hedefini tamamladın!';
    insert into public.answer_events (student_id, question_id, dogru_mu, sure_ms)
      values (o1, q_id, true, 1000);
    select count(*) into v_int2 from public.notifications
     where alici_id = o1 and baslik = 'Günlük hedefini tamamladın!';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.get_daily_goal(o1);
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
    gecti := (v_int = 1 and v_int2 = 1 and (v_json ->> 'tamamlandi')::boolean
              and (v_json ->> 'bugun')::int = 6);
    detay := format('5. cevapta bildirim=%s, 6. cevaptan sonra=%s, bugün=%s',
                    v_int, v_int2, v_json ->> 'bugun');
    return next;

    -- ---------------------------------------------------------------
    -- B) Seri kalkanı
    -- ---------------------------------------------------------------

    -- 8
    no := no + 1;
    senaryo := '7. seri gününde çalışarak seri kalkanı kazanılır (+1) ve bildirim gelir';
    update public.student_stats
       set streak_count = 6, last_active_date = v_today - 1 where student_id = o3;
    perform public.award_xp_and_streak(o3, 1::smallint, true);
    select count(*) into v_int2 from public.notifications where alici_id = o3 and baslik = 'Seri kalkanı kazandın!';
    select seri_kalkani into v_int from public.student_stats where student_id = o3;
    gecti := (v_int = 1 and v_int2 = 1);
    detay := format('kalkan=%s, bildirim=%s', v_int, v_int2);
    return next;

    -- 9
    no := no + 1;
    senaryo := 'Aynı gün ikinci cevap seriyi ve kalkanı artırmaz';
    perform public.award_xp_and_streak(o3, 1::smallint, true);
    select streak_count, seri_kalkani into v_int, v_int2 from public.student_stats where student_id = o3;
    gecti := (v_int = 7 and v_int2 = 1);
    detay := format('seri=%s, kalkan=%s', v_int, v_int2);
    return next;

    -- 10
    no := no + 1;
    senaryo := 'Kalkan en fazla 2 olur (üst sınır)';
    update public.student_stats
       set streak_count = 13, seri_kalkani = 2, last_active_date = v_today - 1 where student_id = o3;
    perform public.award_xp_and_streak(o3, 1::smallint, true);
    select streak_count, seri_kalkani into v_int, v_int2 from public.student_stats where student_id = o3;
    gecti := (v_int = 14 and v_int2 = 2);
    detay := format('seri=%s, kalkan=%s', v_int, v_int2);
    return next;

    -- 11
    no := no + 1;
    senaryo := 'Bir gün ara verilirse kalkan otomatik kullanılır, seri korunur, bildirim gelir';
    update public.student_stats
       set streak_count = 5, seri_kalkani = 1, last_active_date = v_today - 2 where student_id = o4;
    perform public.award_xp_and_streak(o4, 1::smallint, true);
    select count(*) into v_int2 from public.notifications where alici_id = o4 and baslik = 'Seri kalkanın devreye girdi!';
    select seri_kalkani, streak_count::text into v_int, v_text from public.student_stats where student_id = o4;
    gecti := (v_text::int = 6 and v_int = 0 and v_int2 = 1);
    detay := format('seri=%s, kalan kalkan=%s, bildirim=%s', v_text, v_int, v_int2);
    return next;

    -- 12
    no := no + 1;
    senaryo := 'Kalkan yokken bir gün ara verilirse seri 1''den başlar';
    update public.student_stats
       set streak_count = 5, seri_kalkani = 0, last_active_date = v_today - 2 where student_id = o5;
    perform public.award_xp_and_streak(o5, 1::smallint, true);
    select streak_count into v_int from public.student_stats where student_id = o5;
    gecti := (v_int = 1);
    detay := 'seri=' || v_int;
    return next;

    -- 13
    no := no + 1;
    senaryo := 'İki günden uzun ara: kalkan olsa bile seri sıfırlanır, kalkan harcanmaz';
    update public.student_stats
       set streak_count = 9, seri_kalkani = 2, last_active_date = v_today - 3 where student_id = o2;
    perform public.award_xp_and_streak(o2, 1::smallint, true);
    select streak_count, seri_kalkani into v_int, v_int2 from public.student_stats where student_id = o2;
    gecti := (v_int = 1 and v_int2 = 2);
    detay := format('seri=%s, kalkan=%s', v_int, v_int2);
    return next;

    -- ---------------------------------------------------------------
    -- C) Gizlilik (KVKK altyapısı)
    -- ---------------------------------------------------------------
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);

    -- 14
    no := no + 1;
    senaryo := 'Aydınlatma metninin okunduğu kaydedilir; aynı sürüm için tekrar kayıt oluşmaz';
    perform public.record_notice_read('test-v1');
    perform public.record_notice_read('test-v1');
    v_json := public.get_consent_status(o1, 'test-v1');
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
    select count(*) into v_int from public.consents where cocuk_id = o1 and tur = 'aydinlatma_okundu';
    gecti := ((v_json ->> 'aydinlatma_okundu')::boolean and v_int = 1);
    detay := format('okundu=%s, kayıt sayısı=%s', v_json ->> 'aydinlatma_okundu', v_int);
    return next;

    -- 15
    no := no + 1;
    senaryo := 'Başka bir sürüm için aydınlatma "okunmadı" görünür (metin değişince yeniden gösterilir)';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.get_consent_status(o1, 'test-v2');
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
    gecti := not (v_json ->> 'aydinlatma_okundu')::boolean;
    detay := v_json::text;
    return next;

    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);

    -- 16
    no := no + 1;
    senaryo := 'Başlangıçta veli rızası "yok"; veli verince "verildi", geri çekince "geri_cekildi", tekrar verince "verildi"';
    v_text := public.get_consent_status(o1, 'test-v1') ->> 'veli_riza';
    perform public.set_parental_consent(o1, 'test-v1', true);
    v_bool := (public.get_consent_status(o1, 'test-v1') ->> 'veli_riza') = 'verildi';
    perform public.set_parental_consent(o1, 'test-v1', false);
    v_int := case (public.get_consent_status(o1, 'test-v1') ->> 'veli_riza') when 'geri_cekildi' then 1 else 0 end;
    perform public.set_parental_consent(o1, 'test-v1', true);
    v_int2 := case (public.get_consent_status(o1, 'test-v1') ->> 'veli_riza') when 'verildi' then 1 else 0 end;
    gecti := (v_text = 'yok' and v_bool and v_int = 1 and v_int2 = 1);
    detay := format('başlangıç=%s', v_text);
    return next;

    perform set_config('request.jwt.claim.sub', v2::text, true);

    -- 17
    no := no + 1;
    senaryo := 'Yabancı veli başkasının çocuğu için rıza kaydı oluşturamaz';
    begin
      perform public.set_parental_consent(o1, 'test-v1', true);
      gecti := false; detay := 'kayıt oluşturuldu';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 18
    no := no + 1;
    senaryo := 'Yabancı veli başkasının çocuğunun onay durumunu göremez';
    begin
      perform public.get_consent_status(o1, 'test-v1');
      gecti := false; detay := 'erişim verildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    perform set_config('request.jwt.claim.sub', o1::text, true);

    -- 19
    no := no + 1;
    senaryo := 'Çocuk kendi adına "veli rızası" kaydı OLUŞTURAMAZ';
    begin
      perform public.set_parental_consent(o1, 'test-v1', true);
      gecti := false; detay := 'kayıt oluşturuldu';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 20
    no := no + 1;
    senaryo := 'Verileri dışa aktarma: yalnızca kendi verisi (profil, istatistik, cevaplar, bildirimler, onaylar)';
    v_json := public.export_my_data();
    gecti := (v_json -> 'profil' ->> 'id') = o1::text
             and v_json ? 'istatistikler' and v_json ? 'cevaplar'
             and v_json ? 'rozetler' and v_json ? 'bildirimler' and v_json ? 'onaylar'
             and not (v_json::text ilike '%' || o2::text || '%')
             and not (v_json::text ilike '%' || v2::text || '%');
    detay := 'anahtarlar=' || (select string_agg(k, ',') from jsonb_object_keys(v_json) k);
    return next;

    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);

    -- 21: hesap silme (öğrenci)
    no := no + 1;
    senaryo := 'Hesabı sil: kullanıcı ve bağlı tüm verileri silinir, diğer kullanıcılar etkilenmez';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.delete_my_account();
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
    select (select count(*) from auth.users where id = o1)
         + (select count(*) from public.profiles where id = o1)
         + (select count(*) from public.student_stats where student_id = o1)
         + (select count(*) from public.answer_events where student_id = o1)
         + (select count(*) from public.notifications where alici_id = o1)
         + (select count(*) from public.consents where cocuk_id = o1)
      into v_int;
    select count(*) into v_int2 from public.profiles where id in (o2, o3, v1, v2);
    gecti := (v_int = 0 and v_int2 = 4);
    detay := format('kalan kayıt=%s, diğer profiller=%s/4', v_int, v_int2);
    return next;

    -- 22: veli silinince çocuk hesabı kalır, parent_id boşalır
    no := no + 1;
    senaryo := 'Veli hesabı silinirse çocuk hesabı KALIR, yalnızca parent_id boşalır';
    update public.profiles set parent_id = v1 where id = o3;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.delete_my_account();
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
    select parent_id into v_text from public.profiles where id = o3;
    select count(*) into v_int from public.profiles where id = o3;
    gecti := (v_int = 1 and v_text is null);
    detay := format('çocuk profili=%s, parent_id=%s', v_int, coalesce(v_text, 'NULL'));
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
  from pg_temp.hedef_gizlilik_testleri()
 order by no;
