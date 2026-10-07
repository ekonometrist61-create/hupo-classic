-- =====================================================================
-- KURTARMA XP + KONU İLERLEMESİ TEST SENARYOLARI
-- Kapsam: 20261008000000_recovery_xp_ve_konu_ilerleme.sql
--   * submit_answer(): yanlış sorunun ardından aynı konudan farklı bir soru
--     doğru çözülünce bir kez kurtarma XP verir
--   * get_topic_progress(): 6 bağımsız soru eşiği altında oran null döner
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: tüm test verisi iş bitince geri alınır.
-- Ön koşul: tüm migration'lar uygulanmış olmalı (supabase db reset).
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.kurtarma_xp_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  o1   uuid := gen_random_uuid();   -- öğrenci
  qA   uuid := gen_random_uuid();   -- Konu1, yanlış cevaplanacak
  qB   uuid := gen_random_uuid();   -- Konu1, kurtarma sorusu (doğru)
  qC   uuid := gen_random_uuid();   -- Konu1, ikinci kurtarma denemesi (tek seferlik kontrol)
  qD   uuid := gen_random_uuid();   -- Farklı konu
  v_xp_before integer;
  v_xp_after  integer;
  v_res       jsonb;
  v_progress  jsonb;
begin
  no := 0;

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (o1, 'kurtarma.xp.ogrenci@example.test', '{"role":"ogrenci","full_name":"Kurtarma Test"}');

    insert into public.questions (id, okul, sinif, ders, konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu)
    values
      (qA, 'ortaokul', 5, 'KurtarmaXPDers', 'Konu1', 1, 'Soru A?', '{"A":"1","B":"2"}'::jsonb, 'A', 'onaylandi'),
      (qB, 'ortaokul', 5, 'KurtarmaXPDers', 'Konu1', 1, 'Soru B?', '{"A":"1","B":"2"}'::jsonb, 'A', 'onaylandi'),
      (qC, 'ortaokul', 5, 'KurtarmaXPDers', 'Konu1', 1, 'Soru C?', '{"A":"1","B":"2"}'::jsonb, 'A', 'onaylandi'),
      (qD, 'ortaokul', 5, 'KurtarmaXPDers', 'Konu2', 1, 'Soru D?', '{"A":"1","B":"2"}'::jsonb, 'A', 'onaylandi');

    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);

    select xp into v_xp_before from public.student_stats where student_id = o1;
    v_xp_before := coalesce(v_xp_before, 0);

    -- 1) Soru A yanlış cevaplanır (kurtarma öncesi durum)
    no := no + 1;
    senaryo := 'Yanlış cevap kurtarma XP vermez';
    v_res := public.submit_answer(qA, 'B');
    gecti := ((v_res->>'kazanilan_xp')::int = 0 and (v_res->>'kurtarma_mi')::boolean = false);
    detay := v_res::text;
    return next;

    -- 2) Aynı konudan B sorusu doğru + kurtarma_of=A → kurtarma XP verilir
    no := no + 1;
    senaryo := 'Aynı konudan doğru + kurtarma_of ile kurtarma XP verilir';
    v_res := public.submit_answer(qB, 'A', null, null, qA);
    gecti := ((v_res->>'kurtarma_mi')::boolean = true and (v_res->>'kazanilan_xp')::int >= 5);
    detay := v_res::text;
    return next;

    select xp into v_xp_after from public.student_stats where student_id = o1;
    no := no + 1;
    senaryo := 'Kurtarma XP gerçekten öğrencinin bakiyesine eklendi';
    gecti := (v_xp_after > v_xp_before);
    detay := format('önce=%s sonra=%s', v_xp_before, v_xp_after);
    return next;

    -- 3) Aynı A sorusu için tekrar kurtarma denenirse (C doğru, kurtarma_of=A) ikinci kez verilmez.
    -- C hiç cevaplanmamış yeni bir soru olduğu için kendi normal XP'sini (10) alır;
    -- önemli olan kurtarma_mi=false ve kazanilan_xp'nin +5 bonus İÇERMEMESİ (yani 10, 15 değil).
    no := no + 1;
    senaryo := 'Kurtarma XP aynı soru için iki kez verilmez (tek sefer)';
    v_res := public.submit_answer(qC, 'A', null, null, qA);
    gecti := ((v_res->>'kurtarma_mi')::boolean = false and (v_res->>'kazanilan_xp')::int = 10);
    detay := v_res::text;
    return next;

    -- 4) Farklı konudan (D) doğru cevap + kurtarma_of=A → konu eşleşmediği için kurtarma verilmez
    no := no + 1;
    senaryo := 'Farklı konudan doğru cevap kurtarma saymaz';
    v_res := public.submit_answer(qD, 'A', null, null, qA);
    gecti := ((v_res->>'kurtarma_mi')::boolean = false);
    detay := v_res::text;
    return next;

    -- 5) get_topic_progress: 6'dan az bağımsız soru olduğu için oran null
    no := no + 1;
    senaryo := 'get_topic_progress: 6 sorudan az olunca oran null (yetersiz veri)';
    v_progress := public.get_topic_progress('KurtarmaXPDers');
    gecti := (
      (select bool_and((t->>'oran') is null)
         from jsonb_array_elements(v_progress) t
        where t->>'konu' = 'Konu1')
    );
    detay := v_progress::text;
    return next;

    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);

    raise exception 'ROLLBACK_TEST';   -- tüm test verisini geri al
  exception
    when others then
      if sqlerrm <> 'ROLLBACK_TEST' then
        no := no + 1;
        senaryo := 'Beklenmeyen hata';
        gecti := false;
        detay := sqlerrm;
        return next;
      end if;
  end;
end;
$fn$;

select * from pg_temp.kurtarma_xp_testleri() order by no;
