-- =====================================================================
-- ADMIN KARAKTER KATALOĞU TEST SENARYOLARI
-- Kapsam: 20261008010000_admin_karakter_katalogu.sql
--   * admin_list_characters(): yalnızca admin çağırabilir, 40 kayıt döner,
--     kazanan_sayisi gerçek user_characters sayımını yansıtır.
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Kalıcı kayıt bırakmaz: tüm test verisi iş bitince geri alınır.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.admin_karakter_katalogu_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm uuid := gen_random_uuid();   -- admin
  o1  uuid := gen_random_uuid();   -- öğrenci 1
  o2  uuid := gen_random_uuid();   -- öğrenci 2
  v_json  jsonb;
  v_once  jsonb;
begin
  no := 0;

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (adm, 'akk.admin@example.test', '{"role":"veli","full_name":"Test Admin"}'),
      (o1,  'akk.cocuk1@example.test', '{"role":"ogrenci","full_name":"Çocuk Bir"}'),
      (o2,  'akk.cocuk2@example.test', '{"role":"ogrenci","full_name":"Çocuk İki"}');
    update public.profiles set role = 'admin' where id = adm;

    -- ozgur_ruh: iki öğrenci kazanmış olsun (seed'de zaten tanımlı karakter).
    insert into public.user_characters (student_id, karakter_kod) values
      (o1, 'ozgur_ruh'),
      (o2, 'ozgur_ruh');

    -- 1) Öğrenci çağıramaz (yetkisiz)
    no := no + 1;
    senaryo := 'Öğrenci admin_list_characters çağıramaz (hata beklenir)';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    begin
      perform public.admin_list_characters();
      gecti := false;
      detay := 'Hata fırlatılmadı';
    exception when others then
      gecti := (sqlerrm like '%admin yetkisi%');
      detay := 'hata=' || sqlerrm;
    end;
    return next;

    -- 2) Admin çağırabilir, 40 kayıt döner
    no := no + 1;
    senaryo := 'Admin çağırınca 40 karakter döner';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_list_characters();
    gecti := (jsonb_array_length(v_json) = 40);
    detay := 'adet=' || jsonb_array_length(v_json);
    return next;

    -- 3) ozgur_ruh için kazanan_sayisi gerçek sayımla eşleşir (en az 2)
    no := no + 1;
    senaryo := 'ozgur_ruh kazanan_sayisi doğru sayılır';
    select t into v_once
      from jsonb_array_elements(v_json) t
     where t ->> 'kod' = 'ozgur_ruh';
    gecti := (v_once is not null and (v_once ->> 'kazanan_sayisi')::int >= 2);
    detay := coalesce(v_once::text, 'bulunamadı');
    return next;

    -- 4) Hiç kazanılmamış bir karakterde kazanan_sayisi = 0 (null değil)
    no := no + 1;
    senaryo := 'Kazanılmamış karakterde kazanan_sayisi 0 döner';
    select t into v_once
      from jsonb_array_elements(v_json) t
     where t ->> 'kod' <> 'ozgur_ruh'
     limit 1;
    gecti := (v_once is not null and (v_once ->> 'kazanan_sayisi')::int = 0);
    detay := coalesce(v_once::text, 'bulunamadı');
    return next;

    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);

    raise exception 'ROLLBACK_TEST';
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

select * from pg_temp.admin_karakter_katalogu_testleri() order by no;
