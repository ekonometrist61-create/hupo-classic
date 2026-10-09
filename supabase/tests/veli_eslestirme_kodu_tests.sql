-- =====================================================================
-- VELİ ↔ ÇOCUK EŞLEŞTİRME KODU TEST SENARYOLARI
-- Kapsam: 20261016000000_veli_eslestirme_kodu.sql
--   * create_parent_link_code(): yalnızca veli, tek aktif kod
--   * redeem_parent_link_code(kod): yalnızca bağsız öğrenci, tek kullanım,
--     süre sınırı, hız sınırı
--   * profiles_guard_immutable(): istemci parent_id'yi hâlâ doğrudan değiştiremez
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: tüm test verisi iş bitince geri alınır.
-- Ön koşul: tüm migration'lar uygulanmış olmalı (supabase db reset).
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.veli_eslestirme_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v1      uuid := gen_random_uuid();   -- veli 1
  v2      uuid := gen_random_uuid();   -- veli 2
  o1      uuid := gen_random_uuid();   -- öğrenci 1
  o2      uuid := gen_random_uuid();   -- öğrenci 2
  o3      uuid := gen_random_uuid();   -- öğrenci 3 (hız sınırı)
  v_j     jsonb;
  v_kod   text;
  v_kod2  text;
  v_uuid  uuid;
  v_int   integer;
  k       integer;
begin
  no := 0;

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (v1, 've.veli1@example.test',  '{"role":"veli","full_name":"Veli Bir"}'),
      (v2, 've.veli2@example.test',  '{"role":"veli","full_name":"Veli Iki"}'),
      (o1, 've.cocuk1@example.test', '{"role":"ogrenci","full_name":"Cocuk Bir"}'),
      (o2, 've.cocuk2@example.test', '{"role":"ogrenci","full_name":"Cocuk Iki"}'),
      (o3, 've.cocuk3@example.test', '{"role":"ogrenci","full_name":"Cocuk Uc"}');

    perform set_config('role', 'authenticated', true);

    -- 1) Öğrenci kod üretemez
    no := no + 1;
    senaryo := 'Öğrenci eşleştirme kodu üretemez (hata beklenir)';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    begin
      perform public.create_parent_link_code();
      gecti := false;
      detay := 'Hata fırlatılmadı';
    exception when others then
      gecti := (sqlerrm like '%yalnızca veli%');
      detay := 'hata=' || sqlerrm;
    end;
    return next;

    -- 2) Veli kod üretir, biçim doğru
    no := no + 1;
    senaryo := 'Veli 6 karakterli kod üretir';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    v_j := public.create_parent_link_code();
    v_kod := v_j ->> 'kod';
    gecti := (v_kod ~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{6}$');
    detay := 'kod=' || coalesce(v_kod, 'null');
    return next;

    -- 3) Yeni kod eskisini geçersiz kılar (veli başına tek aktif kod)
    no := no + 1;
    senaryo := 'İkinci kod üretilince ilk kod silinir';
    v_kod2 := public.create_parent_link_code() ->> 'kod';
    select count(*) into v_int from public.parent_link_codes where veli_id = v1;
    gecti := (v_int = 1 and v_kod2 <> v_kod);
    detay := 'aktif_kod_sayisi=' || v_int;
    v_kod := v_kod2;
    return next;

    -- 4) Veli 2, Veli 1'in kodunu göremez (RLS)
    no := no + 1;
    senaryo := 'Başka velinin kodu RLS ile görünmez';
    perform set_config('request.jwt.claim.sub', v2::text, true);
    select count(*) into v_int from public.parent_link_codes where kod = v_kod;
    gecti := (v_int = 0);
    detay := 'gorunen=' || v_int;
    return next;

    -- 5) Öğrenci parent_id'yi doğrudan değiştiremez
    no := no + 1;
    senaryo := 'Öğrenci parent_id''yi doğrudan yazamaz (hata beklenir)';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    begin
      update public.profiles set parent_id = v1 where id = o1;
      gecti := false;
      detay := 'Hata fırlatılmadı';
    exception when others then
      gecti := (sqlerrm like '%parent_id%');
      detay := 'hata=' || sqlerrm;
    end;
    return next;

    -- 6) Yanlış kod 'gecersiz' döner
    no := no + 1;
    senaryo := 'Yanlış kod gecersiz döner';
    v_j := public.redeem_parent_link_code('ZZZZZZ');
    gecti := (v_j ->> 'durum' = 'gecersiz');
    detay := v_j::text;
    return next;

    -- 7) Doğru kod (küçük harf + boşlukla) bağlar
    no := no + 1;
    senaryo := 'Doğru kod öğrenciyi veliye bağlar (küçük harf/boşluk toleransı)';
    v_j := public.redeem_parent_link_code(lower(substr(v_kod, 1, 3)) || ' ' || substr(v_kod, 4));
    select parent_id into v_uuid from public.profiles where id = o1;
    gecti := (v_j ->> 'durum' = 'baglandi' and v_uuid = v1 and v_j ->> 'veli_ad' = 'Veli Bir');
    detay := v_j::text;
    return next;

    -- 8) Kullanılmış kod ikinci öğrencide çalışmaz
    no := no + 1;
    senaryo := 'Kod tek kullanımlık';
    perform set_config('request.jwt.claim.sub', o2::text, true);
    v_j := public.redeem_parent_link_code(v_kod);
    select parent_id into v_uuid from public.profiles where id = o2;
    gecti := (v_j ->> 'durum' = 'gecersiz' and v_uuid is null);
    detay := v_j::text;
    return next;

    -- 9) Zaten bağlı öğrenci başka koda geçemez
    no := no + 1;
    senaryo := 'Bağlı öğrenci yeni kod kullanamaz (hata beklenir)';
    perform set_config('request.jwt.claim.sub', v2::text, true);
    v_kod2 := public.create_parent_link_code() ->> 'kod';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    begin
      perform public.redeem_parent_link_code(v_kod2);
      gecti := false;
      detay := 'Hata fırlatılmadı';
    exception when others then
      gecti := (sqlerrm like '%zaten%');
      detay := 'hata=' || sqlerrm;
    end;
    return next;

    -- 10) Süresi geçmiş kod çalışmaz
    no := no + 1;
    senaryo := 'Süresi geçmiş kod gecersiz döner';
    perform set_config('role', 'postgres', true);
    update public.parent_link_codes set son_kullanma = now() - interval '1 minute'
     where kod = v_kod2;
    perform set_config('role', 'authenticated', true);
    perform set_config('request.jwt.claim.sub', o2::text, true);
    v_j := public.redeem_parent_link_code(v_kod2);
    gecti := (v_j ->> 'durum' = 'gecersiz');
    detay := v_j::text;
    return next;

    -- 11) Veli kod kullanamaz
    no := no + 1;
    senaryo := 'Veli hesabı kod kullanamaz (hata beklenir)';
    perform set_config('request.jwt.claim.sub', v2::text, true);
    begin
      perform public.redeem_parent_link_code('ABCDEF');
      gecti := false;
      detay := 'Hata fırlatılmadı';
    exception when others then
      gecti := (sqlerrm like '%öğrenci hesabıyla%');
      detay := 'hata=' || sqlerrm;
    end;
    return next;

    -- 12) 5 hatalı denemeden sonra doğru kod bile 'cok_deneme' döner
    no := no + 1;
    senaryo := 'Hız sınırı: 5 hatalı denemeden sonra cok_deneme';
    v_kod2 := public.create_parent_link_code() ->> 'kod';
    perform set_config('request.jwt.claim.sub', o3::text, true);
    for k in 1..5 loop
      perform public.redeem_parent_link_code('ZZZZZZ');
    end loop;
    v_j := public.redeem_parent_link_code(v_kod2);
    select parent_id into v_uuid from public.profiles where id = o3;
    gecti := (v_j ->> 'durum' = 'cok_deneme' and v_uuid is null);
    detay := v_j::text;
    return next;

    -- 13) Öğrenci deneme tablosunu okuyamaz
    no := no + 1;
    senaryo := 'parent_link_attempts istemciye kapalı (hata beklenir)';
    begin
      select count(*) into v_int from public.parent_link_attempts;
      gecti := false;
      detay := 'Okunabildi: ' || v_int;
    exception when others then
      gecti := (sqlstate = '42501');
      detay := 'hata=' || sqlerrm;
    end;
    return next;

    -- 14) Anonim kullanıcı RPC çağıramaz
    no := no + 1;
    senaryo := 'anon rolü create_parent_link_code çağıramaz';
    perform set_config('role', 'anon', true);
    begin
      perform public.create_parent_link_code();
      gecti := false;
      detay := 'Hata fırlatılmadı';
    exception when others then
      gecti := (sqlstate = '42501');
      detay := 'hata=' || sqlerrm;
    end;
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

select * from pg_temp.veli_eslestirme_testleri() order by no;
