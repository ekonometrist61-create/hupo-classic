-- =====================================================================
-- AKTİF KARAKTER TEST SENARYOLARI
-- Kapsam: 20261006000000_aktif_karakter.sql
--   * student_stats.aktif_karakter kolonu
--   * set_active_character(p_kod): yalnızca kazanılmış karakter aktif yapılabilir
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: tüm test verisi iş bitince geri alınır.
-- Ön koşul: tüm migration'lar uygulanmış olmalı (supabase db reset).
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.aktif_karakter_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  o1      uuid := gen_random_uuid();   -- öğrenci
  v_text  text;
begin
  no := 0;

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (o1, 'ak.cocuk1@example.test', '{"role":"ogrenci","full_name":"Aktif Test"}');

    -- Öğrenci yalnızca başlangıç karakterini kazanmış olsun.
    insert into public.user_characters (student_id, karakter_kod)
      values (o1, 'ozgur_ruh');

    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);

    -- 1) Kazanılmış karakter aktif yapılabilir
    no := no + 1;
    senaryo := 'Kazanılmış karakter aktif yapılabilir';
    perform public.set_active_character('ozgur_ruh');
    select aktif_karakter into v_text from public.student_stats where student_id = o1;
    gecti := (v_text = 'ozgur_ruh');
    detay := 'aktif=' || coalesce(v_text, 'null');
    return next;

    -- 2) Kilitli (kazanılmamış) karakter aktif yapılamaz
    no := no + 1;
    senaryo := 'Kilitli karakter aktif yapılamaz (hata beklenir)';
    begin
      perform public.set_active_character('kivilcim');
      gecti := false;
      detay := 'Hata fırlatılmadı — kilitli karakter aktif oldu';
    exception when others then
      gecti := (sqlerrm like '%kilitli%');
      detay := 'hata=' || sqlerrm;
    end;
    return next;

    -- 3) Olmayan karakter reddedilir
    no := no + 1;
    senaryo := 'Tanımsız karakter kodu reddedilir (hata beklenir)';
    begin
      perform public.set_active_character('boyle_bir_kod_yok');
      gecti := false;
      detay := 'Hata fırlatılmadı';
    exception when others then
      gecti := (sqlerrm like '%karakter yok%');
      detay := 'hata=' || sqlerrm;
    end;
    return next;

    -- 4) Kilitli karakter denemesi aktif karakteri bozmaz
    no := no + 1;
    senaryo := 'Başarısız denemeden sonra aktif karakter hâlâ ozgur_ruh';
    select aktif_karakter into v_text from public.student_stats where student_id = o1;
    gecti := (v_text = 'ozgur_ruh');
    detay := 'aktif=' || coalesce(v_text, 'null');
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

select * from pg_temp.aktif_karakter_testleri() order by no;
