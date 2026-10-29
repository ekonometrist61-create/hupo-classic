-- =====================================================================
-- VELI DESTEK ISARETLERI TEST SENARYOLARI
-- Kapsam: 20261140000000_veli_destek_isaretleri.sql
--   public.veli_destek_isaret_degistir(p_cocuk_id, p_oneri_kod, p_yapildi)
--   public.veli_destek_isaretleri_listele(p_cocuk_id)
--   1   yetkisiz (oturumsuz, baska velinin) cagri 42501
--   2   riza yok / geri_cekildi -> 42501
--   3   gecersiz kod -> 22023
--   4   isaretle -> listede gorunur
--   5   ayni kod iki kez -> tek satir
--   6   p_yapildi=false siler (ve olmayani silmek hata vermez)
--   7   baska velinin isareti gorunmez
--   8   son_4_hafta sayimi (distinct hafta, >= hafta_basi - 21)
--   9   anon / authenticated EXECUTE yetkileri
--   10  tabloya dogrudan erisim yok (RLS acik, anon/authenticated yetkisiz)
--   11  hafta basi: Europe/Istanbul saat dilimi ve Pazartesi
--
-- Kalici kayit birakmaz: PGlite gecicidir. Her senaryo kendi hatasini yakalar (FAIL olarak raporlanir).
-- =====================================================================

set client_encoding = 'UTF8';

-- Test verisi (superuser olarak; RLS'i asmak icin tablo sahibi olarak eklenir)
insert into public.profiles (id, role, parent_id) values
  ('00000000-0000-0000-0000-000000000001', 'parent', null),                                  -- veli
  ('00000000-0000-0000-0000-000000000002', 'student', '00000000-0000-0000-0000-000000000001'), -- cocuk (rıza verildi)
  ('00000000-0000-0000-0000-000000000003', 'student', '00000000-0000-0000-0000-000000000001'), -- cocuk (rıza yok)
  ('00000000-0000-0000-0000-000000000004', 'student', '00000000-0000-0000-0000-000000000001'), -- cocuk (rıza geri çekildi)
  ('00000000-0000-0000-0000-000000000005', 'parent', null),                                  -- baska veli
  ('00000000-0000-0000-0000-000000000006', 'student', '00000000-0000-0000-0000-000000000005'), -- baska velinin cocugu
  ('00000000-0000-0000-0000-000000000007', 'student', '00000000-0000-0000-0000-000000000001'); -- cocuk (son 4 hafta)

insert into public.test_riza (cocuk_id, durum, created_at) values
  ('00000000-0000-0000-0000-000000000002', 'verildi', now() - interval '2 days'),
  ('00000000-0000-0000-0000-000000000004', 'verildi', now() - interval '3 days'),
  ('00000000-0000-0000-0000-000000000004', 'geri_cekildi', now() - interval '1 day'),
  ('00000000-0000-0000-0000-000000000006', 'verildi', now() - interval '2 days'),
  ('00000000-0000-0000-0000-000000000007', 'verildi', now() - interval '2 days');

-- Verilen kullanici olarak ayarlar (p_uid null ise oturumsuz).
create or replace function pg_temp.bagla(p_uid uuid) returns void
language plpgsql
as $fn$
begin
  perform set_config(
    'request.jwt.claims',
    case when p_uid is null then '' else json_build_object('sub', p_uid, 'role', 'authenticated')::text end,
    false
  );
end
$fn$;

-- Verilen SQL'i p_uid olarak calistirir; hata yoksa 'ok', varsa SQLSTATE dondurur.
create or replace function pg_temp.sqlstate_of(p_uid uuid, p_sql text) returns text
language plpgsql
as $fn$
begin
  perform pg_temp.bagla(p_uid);
  execute p_sql;
  return 'ok';
exception when others then
  return sqlstate;
end
$fn$;

create or replace function pg_temp.isaretle(p_uid uuid, p_cocuk uuid, p_kod text, p_yapildi boolean) returns jsonb
language plpgsql
as $fn$
begin
  perform pg_temp.bagla(p_uid);
  return public.veli_destek_isaret_degistir(p_cocuk, p_kod, p_yapildi);
end
$fn$;

create or replace function pg_temp.listele(p_uid uuid, p_cocuk uuid) returns jsonb
language plpgsql
as $fn$
begin
  perform pg_temp.bagla(p_uid);
  return public.veli_destek_isaretleri_listele(p_cocuk);
end
$fn$;

create or replace function pg_temp.veli_destek_testleri()
returns table (no int, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v_veli   uuid := '00000000-0000-0000-0000-000000000001';
  -- (no, senaryo, gecti, detay: OUT parametreleri)
  v_baska  uuid := '00000000-0000-0000-0000-000000000005';
  c_cocuk  uuid := '00000000-0000-0000-0000-000000000002';
  c_riza_yok uuid := '00000000-0000-0000-0000-000000000003';
  c_geri   uuid := '00000000-0000-0000-0000-000000000004';
  c_baska  uuid := '00000000-0000-0000-0000-000000000006';
  c_son4   uuid := '00000000-0000-0000-0000-000000000007';
  v_hafta  date := public._istanbul_hafta_basi();
  v_kod    text;
  v_sayi   int;
  v_j      jsonb;
  v_kodlar text[] := array['ab', 'A', 'Abc', 'a b', 'kod/abc', 'a', '', repeat('a', 81)];
begin
  no := 0;
  -- 1. Yetkisiz cagrilar
  no := no + 1;
  senaryo := 'Yetkisiz: oturumsuz ve baska velinin yazma/listeleme cagrilari 42501 alir';
  gecti := false; detay := null;
  begin
    gecti := pg_temp.sqlstate_of(null, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, true)', c_cocuk, 'kod.abc')) = '42501'
         and pg_temp.sqlstate_of(null, format('select public.veli_destek_isaretleri_listele(%L::uuid)', c_cocuk)) = '42501'
         and pg_temp.sqlstate_of(v_baska, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, true)', c_cocuk, 'kod.abc')) = '42501'
         and pg_temp.sqlstate_of(v_baska, format('select public.veli_destek_isaretleri_listele(%L::uuid)', c_cocuk)) = '42501';
    detay := format('oturumsuz_yaz=%s oturumsuz_liste=%s baska_yaz=%s baska_liste=%s',
      pg_temp.sqlstate_of(null, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, true)', c_cocuk, 'kod.abc')),
      pg_temp.sqlstate_of(null, format('select public.veli_destek_isaretleri_listele(%L::uuid)', c_cocuk)),
      pg_temp.sqlstate_of(v_baska, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, true)', c_cocuk, 'kod.abc')),
      pg_temp.sqlstate_of(v_baska, format('select public.veli_destek_isaretleri_listele(%L::uuid)', c_cocuk)));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 2. Riza yok / geri cekildi -> 42501 (yazma)
  no := no + 1;
  senaryo := 'Riza yok veya geri_cekildi ise yazma 42501 ile reddedilir';
  gecti := false; detay := null;
  begin
    gecti := pg_temp.sqlstate_of(v_veli, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, true)', c_riza_yok, 'kod.abc')) = '42501'
         and pg_temp.sqlstate_of(v_veli, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, true)', c_geri, 'kod.abc')) = '42501';
    detay := format('riza_yok=%s geri_cekildi=%s',
      pg_temp.sqlstate_of(v_veli, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, true)', c_riza_yok, 'kod.abc')),
      pg_temp.sqlstate_of(v_veli, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, true)', c_geri, 'kod.abc')));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 3. Gecersiz kod -> 22023 (riza verili cocukta)
  no := no + 1;
  senaryo := 'Gecersiz oneri kodu (kisa, buyuk harf, bosluk, /, bos, 81 karakter, null) 22023 alir';
  gecti := true; detay := null;
  begin
    foreach v_kod in array v_kodlar loop
      if pg_temp.sqlstate_of(v_veli, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, true)', c_cocuk, v_kod)) <> '22023' then
        gecti := false;
        detay := 'kabul edildi: "' || v_kod || '"';
        exit;
      end if;
    end loop;
    if gecti and pg_temp.sqlstate_of(v_veli, format('select public.veli_destek_isaret_degistir(%L::uuid, null, true)', c_cocuk)) <> '22023' then
      gecti := false;
      detay := 'null kod kabul edildi';
    end if;
    if gecti then detay := format('%s kod da 22023 dondu', array_length(v_kodlar, 1)); end if;
  exception when others then
    gecti := false;
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 4. Isaretle -> listede gorunur
  no := no + 1;
  senaryo := 'Isaretlenen oneri, listelemede yapilanlar icinde gorunur';
  gecti := false; detay := null;
  begin
    v_j := pg_temp.isaretle(v_veli, c_cocuk, 'okuma.kelime.1', true);
    gecti := (v_j ->> 'yapildi')::boolean
         and (v_j ->> 'hafta')::date = v_hafta
         and pg_temp.listele(v_veli, c_cocuk) -> 'yapilanlar' @> '["okuma.kelime.1"]'::jsonb;
    detay := format('yanit=%s liste=%s', v_j, pg_temp.listele(v_veli, c_cocuk) -> 'yapilanlar');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 5. Ayni kod iki kez -> tek satir
  no := no + 1;
  senaryo := 'Ayni kod iki kez isaretlenince tek satir olusur (idempotent)';
  gecti := false; detay := null;
  begin
    perform pg_temp.isaretle(v_veli, c_cocuk, 'okuma.kelime.1', true);
    select count(*) into v_sayi from public.veli_destek_isaretleri
     where veli_id = v_veli and cocuk_id = c_cocuk and hafta = v_hafta and oneri_kod = 'okuma.kelime.1';
    gecti := v_sayi = 1
         and jsonb_array_length(pg_temp.listele(v_veli, c_cocuk) -> 'yapilanlar') = 1;
    detay := format('satir=%s', v_sayi);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 6. p_yapildi=false siler; olmayani silmek hata vermez
  no := no + 1;
  senaryo := 'p_yapildi=false isareti siler; olmayan kayit icin de hata vermez';
  gecti := false; detay := null;
  begin
    v_j := pg_temp.isaretle(v_veli, c_cocuk, 'okuma.kelime.1', false);
    select count(*) into v_sayi from public.veli_destek_isaretleri
     where veli_id = v_veli and cocuk_id = c_cocuk and hafta = v_hafta and oneri_kod = 'okuma.kelime.1';
    gecti := (v_j ->> 'yapildi')::boolean = false
         and v_sayi = 0
         and pg_temp.listele(v_veli, c_cocuk) -> 'yapilanlar' = '[]'::jsonb
         and pg_temp.sqlstate_of(v_veli, format('select public.veli_destek_isaret_degistir(%L::uuid, %L, false)', c_cocuk, 'yok.kod')) = 'ok';
    detay := format('satir=%s liste=%s', v_sayi, pg_temp.listele(v_veli, c_cocuk) -> 'yapilanlar');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 7. Baska velinin isareti gorunmez
  no := no + 1;
  senaryo := 'Baska velinin isareti, bu velinin listesinde ve sayiminda gorunmez';
  gecti := false; detay := null;
  begin
    insert into public.veli_destek_isaretleri (veli_id, cocuk_id, hafta, oneri_kod)
    values (v_baska, c_cocuk, v_hafta, 'baska.kod');
    gecti := pg_temp.listele(v_veli, c_cocuk) -> 'yapilanlar' @> '["baska.kod"]'::jsonb = false
         and (pg_temp.listele(v_veli, c_cocuk) ->> 'son_4_hafta')::int = 0;
    detay := format('liste=%s son_4=%s', pg_temp.listele(v_veli, c_cocuk) -> 'yapilanlar', pg_temp.listele(v_veli, c_cocuk) ->> 'son_4_hafta');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 8. son_4_hafta: distinct hafta, >= hafta_basi - 21 (4 hafta: bu, -7, -14, -21)
  no := no + 1;
  senaryo := 'son_4_hafta: ayni haftadaki birden fazla kod tek hafta sayilir; -28 haftasi sayilmaz';
  gecti := false; detay := null;
  begin
    insert into public.veli_destek_isaretleri (veli_id, cocuk_id, hafta, oneri_kod) values
      (v_veli, c_son4, v_hafta,      'a.bir'),
      (v_veli, c_son4, v_hafta,      'a.iki'),
      (v_veli, c_son4, v_hafta - 7,  'a.bir'),
      (v_veli, c_son4, v_hafta - 14, 'a.bir'),
      (v_veli, c_son4, v_hafta - 21, 'a.bir'),
      (v_veli, c_son4, v_hafta - 28, 'a.bir');
    v_j := pg_temp.listele(v_veli, c_son4);
    gecti := (v_j ->> 'son_4_hafta')::int = 4
         and jsonb_array_length(v_j -> 'yapilanlar') = 2;
    detay := format('son_4=%s bu_hafta_kayit=%s', v_j ->> 'son_4_hafta', jsonb_array_length(v_j -> 'yapilanlar'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 9. EXECUTE yetkileri: anon yok, authenticated var
  no := no + 1;
  senaryo := 'anon iki RPC icin EXECUTE yok; authenticated EXECUTE var';
  gecti := false; detay := null;
  begin
    gecti := not has_function_privilege('anon', 'public.veli_destek_isaret_degistir(uuid,text,boolean)', 'EXECUTE')
         and not has_function_privilege('anon', 'public.veli_destek_isaretleri_listele(uuid)', 'EXECUTE')
         and has_function_privilege('authenticated', 'public.veli_destek_isaret_degistir(uuid,text,boolean)', 'EXECUTE')
         and has_function_privilege('authenticated', 'public.veli_destek_isaretleri_listele(uuid)', 'EXECUTE');
    detay := format('anon_yaz=%s anon_liste=%s auth_yaz=%s auth_liste=%s',
      has_function_privilege('anon', 'public.veli_destek_isaret_degistir(uuid,text,boolean)', 'EXECUTE'),
      has_function_privilege('anon', 'public.veli_destek_isaretleri_listele(uuid)', 'EXECUTE'),
      has_function_privilege('authenticated', 'public.veli_destek_isaret_degistir(uuid,text,boolean)', 'EXECUTE'),
      has_function_privilege('authenticated', 'public.veli_destek_isaretleri_listele(uuid)', 'EXECUTE'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 10. Tabloya dogrudan erisim yok
  no := no + 1;
  senaryo := 'veli_destek_isaretleri: RLS acik; anon ve authenticated tabloya dogrudan erisemez';
  gecti := false; detay := null;
  begin
    gecti := (select relrowsecurity from pg_class where oid = 'public.veli_destek_isaretleri'::regclass)
         and not has_table_privilege('anon', 'public.veli_destek_isaretleri', 'SELECT')
         and not has_table_privilege('anon', 'public.veli_destek_isaretleri', 'INSERT')
         and not has_table_privilege('authenticated', 'public.veli_destek_isaretleri', 'SELECT')
         and not has_table_privilege('authenticated', 'public.veli_destek_isaretleri', 'INSERT')
         and not has_table_privilege('authenticated', 'public.veli_destek_isaretleri', 'DELETE');
    detay := format('rls=%s anon_select=%s auth_select=%s auth_insert=%s',
      (select relrowsecurity from pg_class where oid = 'public.veli_destek_isaretleri'::regclass),
      has_table_privilege('anon', 'public.veli_destek_isaretleri', 'SELECT'),
      has_table_privilege('authenticated', 'public.veli_destek_isaretleri', 'SELECT'),
      has_table_privilege('authenticated', 'public.veli_destek_isaretleri', 'INSERT'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 11. Hafta basi: Europe/Istanbul saat dilimi ve Pazartesi
  no := no + 1;
  senaryo := 'Hafta basi Europe/Istanbul''a gore Pazartesi: Pazar 23:30 -> onceki Pazartesi; Pazartesi 01:30 -> o gun';
  gecti := false; detay := null;
  begin
    gecti := public._istanbul_hafta_basi(timestamptz '2026-10-25 20:30:00+00') = date '2026-10-19'
         and public._istanbul_hafta_basi(timestamptz '2026-10-25 22:30:00+00') = date '2026-10-26';
    detay := format('pazar_2330=%s pazartesi_0130=%s',
      public._istanbul_hafta_basi(timestamptz '2026-10-25 20:30:00+00'),
      public._istanbul_hafta_basi(timestamptz '2026-10-25 22:30:00+00'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- Temizlik: oturum degiskenini sifirla
  perform set_config('request.jwt.claims', '', false);
end
$fn$;
