-- =====================================================================
-- PUSH BİLDİRİMİ TEST SENARYOLARI
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: test verileri iş bitince geri alınır.
-- Ön koşul: 20260920001000_push_notifications.sql uygulanmış olmalı.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.push_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v1 uuid := gen_random_uuid();   -- o1'in velisi
  v2 uuid := gen_random_uuid();   -- yabancı veli
  o1 uuid := gen_random_uuid();   -- velisi olan çocuk
  o2 uuid := gen_random_uuid();   -- yabancı çocuk
  o3 uuid := gen_random_uuid();   -- velisiz çocuk

  tok1 text := repeat('a', 40);
  tok2 text := repeat('b', 40);
  tok3 text := repeat('c', 40);

  v_json   jsonb;
  v_int    integer;
  v_int2   integer;
  v_bool   boolean;
  v_text   text;
  v_now_t  time;
  n1       uuid;
  n2       uuid;
begin
  no := 0;

  begin
    insert into auth.users (id, email, raw_user_meta_data) values
      (v1, 'push.veli1@example.test', '{"role":"veli"}'),
      (v2, 'push.veli2@example.test', '{"role":"veli"}'),
      (o1, 'push.cocuk1@example.test', '{"role":"ogrenci"}'),
      (o2, 'push.cocuk2@example.test', '{"role":"ogrenci"}'),
      (o3, 'push.cocuk3@example.test', '{"role":"ogrenci"}');
    update public.profiles set parent_id = v1 where id = o1;

    -- 1: anon her şeyden yasaklı
    no := no + 1;
    senaryo := 'Anonim kullanıcı jeton kaydedemez ve tabloları okuyamaz';
    perform set_config('role', 'anon', true);
    begin
      perform public.register_device_token(tok1, 'android');
      gecti := false; detay := 'RPC çalıştı';
    exception when insufficient_privilege then
      begin
        perform 1 from public.device_tokens;
        gecti := false; detay := 'tablo okundu';
      exception when insufficient_privilege then
        gecti := true; detay := 'reddedildi';
      end;
    end;
    perform set_config('role', 'none', true);
    return next;

    -- 2: varsayılan kapalı + veli onayı gerekli
    no := no + 1;
    senaryo := 'Varsayılan: push KAPALI, çocuk için "veli onayı gerekli", sessiz saat 20:00-08:00';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.get_push_preference();
    perform set_config('role', 'none', true);
    gecti := (v_json->>'push_enabled')::boolean = false
         and (v_json->>'veli_onayi_gerekli')::boolean = true
         and v_json->>'quiet_start' = '20:00' and v_json->>'quiet_end' = '08:00';
    detay := v_json::text;
    return next;

    -- 3: onay yokken çocuk açamaz
    no := no + 1;
    senaryo := 'Veli onayı yokken çocuk push''u AÇAMAZ';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    begin
      perform public.set_push_preference(true);
      gecti := false; detay := 'açıldı';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    perform set_config('role', 'none', true);
    return next;

    -- 4: velisiz çocuk açamaz
    no := no + 1;
    senaryo := 'Velisi olmayan çocuk push''u açamaz';
    perform set_config('request.jwt.claim.sub', o3::text, true);
    perform set_config('role', 'authenticated', true);
    begin
      perform public.set_push_preference(true);
      gecti := false; detay := 'açıldı';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    perform set_config('role', 'none', true);
    return next;

    -- 5: kapatmak serbest (satır yoksa bile)
    no := no + 1;
    senaryo := 'Kapatmak her zaman serbesttir';
    perform set_config('request.jwt.claim.sub', o3::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.set_push_preference(false);
    perform set_config('role', 'none', true);
    gecti := (v_json->>'push_enabled')::boolean = false;
    detay := v_json::text;
    return next;

    -- 6: rıza verildi -> çocuk açabilir
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.set_parental_consent(o1, 'v1', true);
    perform set_config('role', 'none', true);

    no := no + 1;
    senaryo := 'Veli onayı verilince çocuk push''u açabilir';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    -- sessiz saat yokmuş gibi (başlangıç = bitiş) test için tüm gün açık
    v_json := public.set_push_preference(true, '00:00', '00:00');
    perform set_config('role', 'none', true);
    gecti := (v_json->>'push_enabled')::boolean and not (v_json->>'veli_onayi_gerekli')::boolean;
    detay := v_json::text;
    return next;

    -- 7: jeton upsert
    no := no + 1;
    senaryo := 'Aynı jeton iki kez kaydedilince tek satır kalır (upsert)';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.register_device_token(tok1, 'android');
    perform public.register_device_token(tok1, 'android');
    select count(*)::int into v_int from public.device_tokens where token = tok1;
    perform set_config('role', 'none', true);
    gecti := v_int = 1;
    detay := 'satır=' || v_int;
    return next;

    -- 8: geçersiz platform / kısa jeton
    no := no + 1;
    senaryo := 'Geçersiz platform ve çok kısa jeton reddedilir';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_bool := true;
    begin
      perform public.register_device_token(tok2, 'windows');
      v_bool := false;
    exception when others then null;
    end;
    begin
      perform public.register_device_token('kisa', 'android');
      v_bool := false;
    exception when others then null;
    end;
    perform set_config('role', 'none', true);
    gecti := v_bool;
    detay := '';
    return next;

    -- 9: RLS izolasyonu
    no := no + 1;
    senaryo := 'Başka kullanıcı jetonu göremez ve silemez (RLS)';
    perform set_config('request.jwt.claim.sub', o2::text, true);
    perform set_config('role', 'authenticated', true);
    select count(*)::int into v_int from public.device_tokens;
    delete from public.device_tokens where token = tok1;
    perform public.unregister_device_token(tok1);   -- yabancı jeton: etkisiz
    perform set_config('role', 'none', true);
    select count(*)::int into v_int2 from public.device_tokens where token = tok1;
    gecti := v_int = 0 and v_int2 = 1;
    detay := 'gorulen=' || v_int;
    return next;

    -- 10: istemci doğrudan yazamaz
    no := no + 1;
    senaryo := 'İstemci device_tokens / push_preferences / push_outbox tablolarına doğrudan yazamaz';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_bool := true;
    begin
      insert into public.device_tokens (user_id, token, platform) values (o1, tok3, 'ios');
      v_bool := false;
    exception when insufficient_privilege then null;
    end;
    begin
      update public.push_preferences set push_enabled = true where user_id = o1;
      -- güncelleme yetkisi yok: hata beklenir
      v_bool := false;
    exception when insufficient_privilege then null;
    end;
    begin
      perform 1 from public.push_outbox;
      v_bool := false;
    exception when insufficient_privilege then null;
    end;
    perform set_config('role', 'none', true);
    gecti := v_bool;
    detay := '';
    return next;

    -- 11: jeton hesap değiştirir
    no := no + 1;
    senaryo := 'Paylaşılan cihazda aynı jeton yeni hesaba geçer (eski hesapta kalmaz)';
    perform set_config('request.jwt.claim.sub', o2::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.register_device_token(tok1, 'android');
    perform set_config('role', 'none', true);
    select user_id into v_text from public.device_tokens where token = tok1;
    gecti := v_text = o2::text;
    detay := 'sahip=' || coalesce(v_text, 'yok');
    -- jetonu yeniden o1'e ver
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.register_device_token(tok1, 'android');
    perform set_config('role', 'none', true);
    return next;

    -- 12: kendi jetonunu siler
    no := no + 1;
    senaryo := 'Kullanıcı kendi jetonunu kaldırabilir (unregister)';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.register_device_token(tok2, 'ios');
    perform public.unregister_device_token(tok2);
    select count(*)::int into v_int from public.device_tokens where token = tok2;
    perform set_config('role', 'none', true);
    gecti := v_int = 0;
    detay := 'kalan=' || v_int;
    return next;

    -- 13: sessiz saat fonksiyonu
    no := no + 1;
    senaryo := 'Sessiz saat: 20:00-08:00 aralığı gece yarısını aşar (21:00, 03:00 sessiz; 12:00 değil)';
    gecti := public.push_in_quiet_hours('20:00', '08:00', timestamptz '2026-09-21 21:00+03')
         and public.push_in_quiet_hours('20:00', '08:00', timestamptz '2026-09-21 03:00+03')
         and public.push_in_quiet_hours('20:00', '08:00', timestamptz '2026-09-21 07:59+03')
         and not public.push_in_quiet_hours('20:00', '08:00', timestamptz '2026-09-21 08:00+03')
         and not public.push_in_quiet_hours('20:00', '08:00', timestamptz '2026-09-21 12:00+03')
         and not public.push_in_quiet_hours('20:00', '08:00', timestamptz '2026-09-21 19:59+03');
    detay := '';
    return next;

    no := no + 1;
    senaryo := 'Sessiz saat: gün içi aralık ve başlangıç=bitiş (sessiz saat yok)';
    gecti := public.push_in_quiet_hours('13:00', '15:00', timestamptz '2026-09-21 14:00+03')
         and not public.push_in_quiet_hours('13:00', '15:00', timestamptz '2026-09-21 16:00+03')
         and not public.push_in_quiet_hours('00:00', '00:00', timestamptz '2026-09-21 03:00+03');
    detay := '';
    return next;

    -- 14: izinliyken outbox oluşur
    no := no + 1;
    senaryo := 'Bildirim eklenince (opt-in + rıza + sessiz saat dışı) push_outbox satırı oluşur';
    insert into public.notifications (alici_id, tur, baslik, mesaj)
      values (o1, 'bilgi', 'Merhaba', 'Test mesajı') returning id into n1;
    select count(*)::int into v_int from public.push_outbox where notification_id = n1;
    gecti := v_int = 1;
    detay := 'outbox=' || v_int;
    return next;

    -- 15: push_targets
    no := no + 1;
    senaryo := 'push_targets yalnızca service_role için jeton döner';
    perform set_config('role', 'service_role', true);
    select count(*)::int into v_int from public.push_targets(n1);
    select token into v_text from public.push_targets(n1) limit 1;
    perform set_config('role', 'none', true);
    gecti := v_int = 1 and v_text = tok1;
    detay := 'hedef=' || v_int;
    return next;

    no := no + 1;
    senaryo := 'push_targets istemci (authenticated) ve anon için YASAK';
    v_bool := true;
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    begin
      perform * from public.push_targets(n1);
      v_bool := false;
    exception when insufficient_privilege then null;
    end;
    perform set_config('role', 'anon', true);
    begin
      perform * from public.push_targets(n1);
      v_bool := false;
    exception when insufficient_privilege then null;
    end;
    perform set_config('role', 'none', true);
    gecti := v_bool;
    detay := '';
    return next;

    -- 16: sessiz saatte outbox yok, targets boş
    no := no + 1;
    senaryo := 'Sessiz saat içindeyken outbox oluşmaz ve push_targets boş döner';
    v_now_t := (now() at time zone 'Europe/Istanbul')::time;
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.set_push_preference(true, (v_now_t - interval '1 hour')::time, (v_now_t + interval '1 hour')::time);
    perform set_config('role', 'none', true);
    insert into public.notifications (alici_id, tur, baslik, mesaj)
      values (o1, 'bilgi', 'Sessiz', 'Sessiz saatte') returning id into n2;
    select count(*)::int into v_int from public.push_outbox where notification_id = n2;
    perform set_config('role', 'service_role', true);
    select count(*)::int into v_int2 from public.push_targets(n2);
    perform set_config('role', 'none', true);
    gecti := v_int = 0 and v_int2 = 0;
    detay := 'outbox=' || v_int || ' hedef=' || v_int2;
    return next;

    -- 17: gönderim anında sessiz saat tekrar kontrol (önceden kuyruğa girmiş n1 şimdi engellenir)
    no := no + 1;
    senaryo := 'Kuyruğa girmiş bildirim, gönderim anında sessiz saate düşerse gönderilmez';
    perform set_config('role', 'service_role', true);
    select count(*)::int into v_int from public.push_targets(n1);
    perform set_config('role', 'none', true);
    gecti := v_int = 0;
    detay := 'hedef=' || v_int;
    return next;

    -- 18: opt-in kapalı çocuk (o2 velisiz, tercih yok) için outbox yok
    no := no + 1;
    senaryo := 'Tercihi/rızası olmayan kullanıcı için outbox oluşmaz';
    insert into public.notifications (alici_id, tur, baslik, mesaj)
      values (o2, 'bilgi', 'x', 'y') returning id into n2;
    select count(*)::int into v_int from public.push_outbox where notification_id = n2;
    gecti := v_int = 0;
    detay := 'outbox=' || v_int;
    return next;

    -- 19: rıza geri çekilince push durur
    no := no + 1;
    senaryo := 'Veli rızayı geri çekince push kapanır, outbox oluşmaz, hedef kalmaz';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.set_push_preference(true, '00:00', '00:00');
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform public.set_parental_consent(o1, 'v1', false);
    perform set_config('role', 'none', true);
    select push_enabled into v_bool from public.push_preferences where user_id = o1;
    insert into public.notifications (alici_id, tur, baslik, mesaj)
      values (o1, 'bilgi', 'Rıza sonrası', 'z') returning id into n2;
    select count(*)::int into v_int from public.push_outbox where notification_id = n2;
    perform set_config('role', 'service_role', true);
    select count(*)::int into v_int2 from public.push_targets(n2);
    perform set_config('role', 'none', true);
    gecti := v_bool = false and v_int = 0 and v_int2 = 0;
    detay := 'enabled=' || v_bool || ' outbox=' || v_int;
    return next;

    -- 20: veli kendi hesabı için rıza gerektirmeden açabilir
    no := no + 1;
    senaryo := 'Veli (yetişkin) kendi hesabında push''u açabilir';
    perform set_config('request.jwt.claim.sub', v2::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.set_push_preference(true);
    perform set_config('role', 'none', true);
    gecti := (v_json->>'push_enabled')::boolean;
    detay := v_json::text;
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
  from pg_temp.push_testleri()
 order by no;
