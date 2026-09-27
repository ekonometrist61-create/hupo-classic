-- =====================================================================
-- ÇOCUK GÜVENLİĞİ TEST SENARYOLARI
--
-- Kontrol edilenler:
--   A) Çocuk hesabı doğrudan veli hesabına bağlıdır (parent_id) ve bu bağ bozulamaz.
--   B) Sosyal özellikler ve arkadaş ekleme varsayılan olarak KAPALI gelir;
--      çocuk kendisi açamaz, yalnızca kendi velisi açabilir.
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Sonuçta her senaryo için "gecti" sütununda true/false görürsünüz.
-- Hiçbir kalıcı kayıt bırakmaz: test kullanıcıları ve veriler iş bitince geri alınır.
-- Ön koşul: 20260920000600_child_safety_defaults.sql uygulanmış olmalı.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.cocuk_guvenligi_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v1 uuid := gen_random_uuid();   -- veli 1 (o1'in velisi)
  v2 uuid := gen_random_uuid();   -- veli 2 (yabancı veli)
  o1 uuid := gen_random_uuid();   -- v1'e bağlı çocuk
  o2 uuid := gen_random_uuid();   -- bağsız çocuk
  o3 uuid := gen_random_uuid();   -- kötü niyetli metadata ile kayıt olan çocuk

  v_ok       boolean;
  v_detail   text;
  v_rows     integer;
  v_parent   uuid;
  v_role     text;
  v_sosyal   boolean;
  v_arkadas  boolean;
  v_count    integer;
  v_default  text;
  v_nullable text;
begin
  no := 0;

  begin  -- tüm test verisi bu blok sonunda geri alınır
    -- ---------------------------------------------------------------
    -- Hazırlık: kullanıcılar (kayıt tetikleyicisi profilleri oluşturur)
    -- ---------------------------------------------------------------
    insert into auth.users (id, email, raw_user_meta_data) values
      (v1, 'test.veli1@example.test', '{"role":"veli","full_name":"Test Veli 1"}'),
      (v2, 'test.veli2@example.test', '{"role":"veli","full_name":"Test Veli 2"}'),
      (o1, 'test.cocuk1@example.test', '{"role":"ogrenci","full_name":"Test Çocuk 1"}'),
      (o2, 'test.cocuk2@example.test', '{"role":"ogrenci","full_name":"Test Çocuk 2"}');

    -- Kötü niyetli kayıt: metadata ile veli bağlamaya ve sosyal ayarı açmaya çalışıyor
    insert into auth.users (id, email, raw_user_meta_data) values
      (o3, 'test.cocuk3@example.test',
       jsonb_build_object('role', 'admin', 'full_name', 'Kötü Niyetli',
                          'parent_id', v1::text,
                          'sosyal_ozellikler_acik', true,
                          'arkadas_ekleme_acik', true));

    -- Veli bağlama yetkili taraf (service_role / SQL editörü) tarafından yapılır
    update public.profiles set parent_id = v1 where id = o1;

    -- ---------------------------------------------------------------
    -- A) parent_id bağı
    -- ---------------------------------------------------------------

    -- 1
    no := no + 1;
    senaryo := 'Çocuk hesabı doğrudan veli hesabına bağlı (parent_id = veli, rolü "veli")';
    select p.parent_id, par.role into v_parent, v_role
      from public.profiles p
      left join public.profiles par on par.id = p.parent_id
     where p.id = o1;
    gecti := (v_parent = v1 and v_role = 'veli');
    detay := format('parent_id=%s, veli rolü=%s', v_parent, v_role);
    return next;

    -- 2
    no := no + 1;
    senaryo := 'Veli hesabının kendisinin parent_id değeri olamaz';
    begin
      update public.profiles set parent_id = v2 where id = v1;
      gecti := false; detay := 'Güncelleme reddedilmedi';
    exception when check_violation then
      gecti := true; detay := 'check kısıtı reddetti';
    end;
    return next;

    -- 3
    no := no + 1;
    senaryo := 'parent_id bir çocuk hesabını gösteremez (yalnızca veli olabilir)';
    begin
      update public.profiles set parent_id = o1 where id = o2;
      gecti := false; detay := 'Çocuk başka bir çocuğa bağlanabildi';
    exception when raise_exception then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 4
    no := no + 1;
    senaryo := 'Çocuk kendi parent_id değerini değiştiremez';
    begin
      perform set_config('request.jwt.claim.sub', o1::text, true);
      perform set_config('role', 'authenticated', true);
      update public.profiles set parent_id = v2 where id = o1;
      perform set_config('role', 'none', true);
      perform set_config('request.jwt.claim.sub', '', true);
      gecti := false; detay := 'Çocuk kendini başka veliye bağlayabildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 5
    no := no + 1;
    senaryo := 'Çocuk rolünü "veli" yapıp kendini yetkilendiremez';
    begin
      perform set_config('request.jwt.claim.sub', o1::text, true);
      perform set_config('role', 'authenticated', true);
      update public.profiles set role = 'veli' where id = o1;
      perform set_config('role', 'none', true);
      perform set_config('request.jwt.claim.sub', '', true);
      gecti := false; detay := 'Rol değiştirilebildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 6
    no := no + 1;
    senaryo := 'Kayıt sırasında metadata ile parent_id, rol ve sosyal ayarlar zorlanamaz';
    select parent_id, role, sosyal_ozellikler_acik, arkadas_ekleme_acik
      into v_parent, v_role, v_sosyal, v_arkadas
      from public.profiles where id = o3;
    gecti := (v_parent is null and v_role = 'ogrenci'
              and v_sosyal = false and v_arkadas = false);
    detay := format('parent_id=%s, rol=%s, sosyal=%s, arkadas=%s',
                    v_parent, v_role, v_sosyal, v_arkadas);
    return next;

    -- 7
    no := no + 1;
    senaryo := 'Bir veli yalnızca kendi çocuğunu görür (yabancı veli göremez)';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    select count(*) into v_count from public.profiles where id = o1;
    v_ok := (v_count = 1);
    perform set_config('request.jwt.claim.sub', v2::text, true);
    select count(*) into v_count from public.profiles where id = o1;
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
    gecti := (v_ok and v_count = 0);
    detay := format('kendi velisi görüyor=%s, yabancı veli gördüğü satır=%s', v_ok, v_count);
    return next;

    -- ---------------------------------------------------------------
    -- B) Sosyal özellikler / arkadaş ekleme varsayılanları
    -- ---------------------------------------------------------------

    -- 8
    no := no + 1;
    senaryo := 'Sütun varsayılanları: NOT NULL ve DEFAULT false (sosyal + arkadaş ekleme)';
    gecti := true; detay := '';
    for v_default, v_nullable in
      select column_default, is_nullable
        from information_schema.columns
       where table_schema = 'public' and table_name = 'profiles'
         and column_name in ('sosyal_ozellikler_acik', 'arkadas_ekleme_acik')
    loop
      if v_default is distinct from 'false' or v_nullable <> 'NO' then
        gecti := false;
      end if;
      detay := detay || format('[default=%s, nullable=%s] ', v_default, v_nullable);
    end loop;
    select count(*) into v_count
      from information_schema.columns
     where table_schema = 'public' and table_name = 'profiles'
       and column_name in ('sosyal_ozellikler_acik', 'arkadas_ekleme_acik');
    gecti := gecti and v_count = 2;
    return next;

    -- 9
    no := no + 1;
    senaryo := 'Yeni çocuk hesaplarında sosyal özellikler ve arkadaş ekleme KAPALI gelir';
    select count(*) filter (where sosyal_ozellikler_acik or arkadas_ekleme_acik)
      into v_count
      from public.profiles where id in (o1, o2, o3);
    gecti := (v_count = 0);
    detay := format('açık gelen hesap sayısı=%s (3 çocuk kontrol edildi)', v_count);
    return next;

    -- 10
    no := no + 1;
    senaryo := 'Arkadaş ekleme, sosyal özellikler kapalıyken açılamaz';
    begin
      update public.profiles set arkadas_ekleme_acik = true where id = o2;
      gecti := false; detay := 'Tek başına açılabildi';
    exception when check_violation then
      gecti := true; detay := 'check kısıtı reddetti';
    end;
    return next;

    -- 11
    no := no + 1;
    senaryo := 'Çocuk sosyal özellikleri kendisi AÇAMAZ';
    begin
      perform set_config('request.jwt.claim.sub', o1::text, true);
      perform set_config('role', 'authenticated', true);
      update public.profiles set sosyal_ozellikler_acik = true where id = o1;
      perform set_config('role', 'none', true);
      perform set_config('request.jwt.claim.sub', '', true);
      gecti := false; detay := 'Çocuk kendi hesabında açabildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 12
    no := no + 1;
    senaryo := 'Çocuk arkadaş eklemeyi kendisi AÇAMAZ';
    begin
      perform set_config('request.jwt.claim.sub', o1::text, true);
      perform set_config('role', 'authenticated', true);
      update public.profiles
         set sosyal_ozellikler_acik = true, arkadas_ekleme_acik = true
       where id = o1;
      perform set_config('role', 'none', true);
      perform set_config('request.jwt.claim.sub', '', true);
      gecti := false; detay := 'Çocuk kendi hesabında açabildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- 13
    no := no + 1;
    senaryo := 'Yabancı veli başkasının çocuğunun sosyal ayarını değiştiremez';
    perform set_config('request.jwt.claim.sub', v2::text, true);
    perform set_config('role', 'authenticated', true);
    update public.profiles set sosyal_ozellikler_acik = true where id = o1;
    get diagnostics v_rows = row_count;
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);
    select sosyal_ozellikler_acik into v_sosyal from public.profiles where id = o1;
    gecti := (v_rows = 0 and v_sosyal = false);
    detay := format('etkilenen satır=%s, ayar hâlâ kapalı=%s', v_rows, not v_sosyal);
    return next;

    -- 14 (yazma yapan son senaryo; sonrası varsayılanlara dönmez, test sonunda geri alınır)
    no := no + 1;
    senaryo := 'Çocuğun kendi velisi sosyal özellikleri ve arkadaş eklemeyi açıp kapatabilir';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);

    update public.profiles set sosyal_ozellikler_acik = true where id = o1;
    get diagnostics v_rows = row_count;
    v_ok := (v_rows = 1);

    update public.profiles set arkadas_ekleme_acik = true where id = o1;
    select sosyal_ozellikler_acik, arkadas_ekleme_acik into v_sosyal, v_arkadas
      from public.profiles where id = o1;
    v_ok := v_ok and v_sosyal and v_arkadas;

    update public.profiles
       set sosyal_ozellikler_acik = false, arkadas_ekleme_acik = false
     where id = o1;
    select sosyal_ozellikler_acik, arkadas_ekleme_acik into v_sosyal, v_arkadas
      from public.profiles where id = o1;
    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);

    gecti := v_ok and not v_sosyal and not v_arkadas;
    detay := 'açma, arkadaş ekleme ve tekrar kapatma sırayla denendi';
    return next;

    -- 15
    no := no + 1;
    senaryo := 'Veli, çocuğunu başka bir veliye BAĞLAYAMAZ';
    begin
      perform set_config('request.jwt.claim.sub', v1::text, true);
      perform set_config('role', 'authenticated', true);
      update public.profiles set parent_id = v2 where id = o1;
      perform set_config('role', 'none', true);
      perform set_config('request.jwt.claim.sub', '', true);
      gecti := false; detay := 'çocuk başka veliye bağlanabildi';
    exception when insufficient_privilege then
      gecti := true; detay := sqlerrm;
    end;
    return next;

    -- Tüm test verisini geri al
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
  from pg_temp.cocuk_guvenligi_testleri()
 order by no;
