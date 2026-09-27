-- =====================================================================
-- LİG, İLERLEME VE BİLDİRİM TEST SENARYOLARI
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: test verileri iş bitince geri alınır.
-- Ön koşul: 20260920000700_leagues_progress_notifications.sql uygulanmış olmalı.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.lig_bildirim_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v1 uuid := gen_random_uuid();   -- o1'in velisi
  v2 uuid := gen_random_uuid();   -- yabancı veli
  o1 uuid := gen_random_uuid();   -- ana test çocuğu
  o2 uuid := gen_random_uuid();   -- aynı ligdeki rakip (anonim sıralama)
  o3 uuid := gen_random_uuid();   -- lig yükselmesi
  o4 uuid := gen_random_uuid();   -- düşmeme testi (gümüş lig, XP yok)

  v_json     jsonb;
  v_int      integer;
  v_int2     integer;
  v_text     text;
  v_bool     boolean;
  v_bu_hafta date;
begin
  no := 0;
  v_bu_hafta := public.hafta_baslangic();

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (v1, 'lig.veli1@example.test', '{"role":"veli"}'),
      (v2, 'lig.veli2@example.test', '{"role":"veli"}'),
      (o1, 'lig.cocuk1@example.test', '{"role":"ogrenci","full_name":"Gizli Ad Bir"}'),
      (o2, 'lig.cocuk2@example.test', '{"role":"ogrenci","full_name":"Gizli Ad Iki"}'),
      (o3, 'lig.cocuk3@example.test', '{"role":"ogrenci"}'),
      (o4, 'lig.cocuk4@example.test', '{"role":"ogrenci"}');
    update public.profiles set parent_id = v1 where id = o1;

    -- ---------------------------------------------------------------
    -- Hazırlık (yetkili rolle): XP ver
    -- ---------------------------------------------------------------
    perform public.award_xp_and_streak(o1, 2::smallint, true);   -- +20 XP
    perform public.award_xp_and_streak(o2, 3::smallint, true);   -- +30 XP (o1'den önde)

    -- 1
    no := no + 1;
    senaryo := 'Yeni öğrenci Bronz Ligi''nde başlar';
    select lig into v_text from public.student_stats where student_id = o4;
    gecti := (v_text = 'bronz');
    detay := 'lig=' || coalesce(v_text, 'NULL');
    return next;

    -- 2
    no := no + 1;
    senaryo := 'Kazanılan XP haftalık XP olarak kaydedilir (xp_events)';
    select coalesce(sum(xp), 0) into v_int from public.xp_events where student_id = o1;
    gecti := (v_int = 20);
    detay := 'kayıtlı XP=' || v_int;
    return next;

    -- 3
    no := no + 1;
    senaryo := 'XP verilmeyen (tekrar) doğru cevap xp_events''e satır eklemez';
    select count(*) into v_int from public.xp_events where student_id = o1;
    perform public.award_xp_and_streak(o1, 1::smallint, false);
    select count(*) into v_int2 from public.xp_events where student_id = o1;
    gecti := (v_int2 = v_int);
    detay := format('önce=%s, sonra=%s', v_int, v_int2);
    return next;

    -- 4
    no := no + 1;
    senaryo := 'Seviye atlayınca "Seviye atladın!" bildirimi oluşur';
    for i in 1..5 loop
      perform public.award_xp_and_streak(o3, 3::smallint, true);  -- 5 x 30 = 150 XP → seviye 2
    end loop;
    select count(*) into v_int from public.notifications where alici_id = o3 and tur = 'seviye';
    gecti := (v_int = 1);
    detay := 'seviye bildirimi sayısı=' || v_int;
    return next;

    -- 5
    no := no + 1;
    senaryo := 'Rozet kazanılınca "Yeni rozet" bildirimi oluşur';
    for i in 1..14 loop
      perform public.award_xp_and_streak(o1, 3::smallint, true);  -- toplam >= 400 XP → seviye 5 rozeti
    end loop;
    select count(*) into v_int from public.notifications where alici_id = o1 and tur = 'rozet';
    select mesaj into v_text from public.notifications where alici_id = o1 and tur = 'rozet' limit 1;
    gecti := (v_int >= 1 and v_text like '%rozeti artık senin%');
    detay := format('rozet bildirimi=%s, mesaj=%s', v_int, v_text);
    return next;

    -- 6
    no := no + 1;
    senaryo := 'En uzun seri kaydedilir (en az 1)';
    select en_uzun_seri into v_int from public.student_stats where student_id = o1;
    gecti := (v_int >= 1);
    detay := 'en_uzun_seri=' || v_int;
    return next;

    -- 7: geçen hafta 120 XP (Bronz eşiği 100) → Gümüş'e yüksel
    no := no + 1;
    senaryo := 'Hafta bitince yeterli XP toplayan öğrenci bir üst lige yükselir ve bildirim alır';
    update public.student_stats set lig_hafta = v_bu_hafta - 7 where student_id = o3;
    insert into public.xp_events (student_id, xp, created_at)
      values (o3, 120, now() - interval '7 days');
    perform public.resolve_league_week(o3);
    select lig into v_text from public.student_stats where student_id = o3;
    select count(*) into v_int from public.notifications where alici_id = o3 and tur = 'lig';
    gecti := (v_text = 'gumus' and v_int = 1);
    detay := format('lig=%s, lig bildirimi=%s', v_text, v_int);
    return next;

    -- 8: yeterli XP yok → aynı lig, düşme yok
    no := no + 1;
    senaryo := 'Yetersiz XP ile lig aynı kalır; DÜŞME YOK (gümüşte 0 XP ile bile gümüş kalır)';
    update public.student_stats set lig = 'gumus', lig_hafta = v_bu_hafta - 7 where student_id = o4;
    perform public.resolve_league_week(o4);
    select lig into v_text from public.student_stats where student_id = o4;
    gecti := (v_text = 'gumus');
    detay := 'lig=' || v_text;
    return next;

    -- 9: aynı hafta içinde ikinci çağrı yükseltmeyi tekrarlamaz
    no := no + 1;
    senaryo := 'Lig dönemi aynı haftada tekrar sonuçlandırılmaz (çift yükselme yok)';
    perform public.resolve_league_week(o3);
    perform public.resolve_league_week(o3);
    select lig into v_text from public.student_stats where student_id = o3;
    gecti := (v_text = 'gumus');
    detay := 'lig=' || v_text;
    return next;

    -- ---------------------------------------------------------------
    -- Öğrenci gözüyle (RLS)
    -- ---------------------------------------------------------------
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);

    -- 10
    no := no + 1;
    senaryo := 'Lig durumu: haftalık XP, anonim sıra ve haftanın kalan süresi döner';
    v_json := public.get_league_status(o1);
    gecti := (v_json ->> 'kod') = 'bronz'
             and (v_json ->> 'haftalik_xp')::int >= 400
             and (v_json ->> 'kalan_saniye')::int between 0 and 7 * 86400
             and (v_json ->> 'sonraki_lig') = 'Gümüş Ligi';
    detay := v_json::text;
    return next;

    -- 11
    no := no + 1;
    senaryo := 'Sıralama ANONİMDİR: yanıtta başka çocuğun adı/kimliği yok, yalnızca sayılar';
    v_bool := (v_json ? 'sira') and (v_json ? 'toplam')
              and not (v_json::text ilike '%Gizli Ad%')
              and not (v_json::text ilike '%' || o2::text || '%')
              and not (v_json ? 'full_name') and not (v_json ? 'isim');
    gecti := v_bool;
    detay := format('sira=%s / toplam=%s', v_json ->> 'sira', v_json ->> 'toplam');
    return next;

    -- 12
    no := no + 1;
    senaryo := 'Çocuk başkasının bildirimini göremez';
    select count(*) into v_int from public.notifications where alici_id = o3;
    gecti := (v_int = 0);
    detay := 'görülen yabancı bildirim=' || v_int;
    return next;

    -- 13
    no := no + 1;
    senaryo := 'Çocuk kendine bildirim EKLEYEMEZ';
    begin
      insert into public.notifications (alici_id, tur, baslik, mesaj)
        values (o1, 'bilgi', 'sahte', 'sahte');
      gecti := false; detay := 'ekleme yapılabildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    perform set_config('role', 'authenticated', true);
    return next;

    -- 14
    no := no + 1;
    senaryo := 'Çocuk bildirim içeriğini DEĞİŞTİREMEZ (yalnızca okundu işaretleme fonksiyonuyla)';
    begin
      update public.notifications set baslik = 'değişti' where alici_id = o1;
      gecti := false; detay := 'güncelleme yapılabildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    perform set_config('role', 'authenticated', true);
    return next;

    -- 15
    no := no + 1;
    senaryo := 'Bildirimler okundu işaretlenir (mark_notifications_read)';
    select count(*) into v_int from public.notifications where alici_id = o1 and okundu = false;
    v_int2 := public.mark_notifications_read(null);
    select count(*) into v_int from public.notifications where alici_id = o1 and okundu = false;
    gecti := (v_int2 > 0 and v_int = 0);
    detay := format('işaretlenen=%s, kalan okunmamış=%s', v_int2, v_int);
    return next;

    -- 16
    no := no + 1;
    senaryo := 'Profil özeti: üyelik tarihi ve toplamlar döner';
    v_json := public.get_profile_overview(o1);
    gecti := (v_json ->> 'uye_tarihi') is not null
             and (v_json ->> 'en_uzun_seri')::int >= 1
             and jsonb_typeof(v_json -> 'ders_ilerleme') = 'array';
    detay := left(v_json::text, 160);
    return next;

    -- ---------------------------------------------------------------
    -- Veli gözüyle
    -- ---------------------------------------------------------------
    perform set_config('request.jwt.claim.sub', v1::text, true);

    -- 17
    no := no + 1;
    senaryo := 'Çocuğun velisi lig durumunu ve profil özetini görebilir';
    v_json := public.get_league_status(o1);
    gecti := (v_json ->> 'kod') is not null
             and public.get_profile_overview(o1) is not null;
    detay := 'lig=' || (v_json ->> 'kod');
    return next;

    perform set_config('request.jwt.claim.sub', v2::text, true);

    -- 18
    no := no + 1;
    senaryo := 'Yabancı veli başkasının çocuğunun lig durumunu GÖREMEZ';
    begin
      perform public.get_league_status(o1);
      gecti := false; detay := 'erişim izni verildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    perform set_config('role', 'authenticated', true);
    return next;

    -- 19
    no := no + 1;
    senaryo := 'Yabancı veli başkasının çocuğunun profil özetini GÖREMEZ';
    begin
      perform public.get_profile_overview(o1);
      gecti := false; detay := 'erişim izni verildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
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
  from pg_temp.lig_bildirim_testleri()
 order by no;
