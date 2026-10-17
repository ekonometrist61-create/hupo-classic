-- =====================================================================
-- ÖĞRETMEN SINIF RAPORU TEST SENARYOLARI
-- Kapsam: 20261041000000_ogretmen_sinif_raporu.sql → public.ogretmen_siniflarim()
--   1-3   yetkisiz roller (oturumsuz, veli, öğrenci) reddedilir
--   4-7   kapsam: öğretmen yalnızca kendi sınıfını, admin hepsini, sınıfsız öğretmen boş liste görür
--   8-12  toplu ilerleme: sayılar, ortalama, 7 gün aktif, tekrar bekleyen, eşik altı gizleme
--   13    çıktıda kişisel veri yok
--   14-16 yetki sözleşmesi: anon çalıştıramaz, authenticated çalıştırır, SECURITY DEFINER + search_path
--
-- Kalıcı kayıt bırakmaz: PGlite geçicidir. Her senaryo kendi hatasını yakalar (FAIL olarak raporlanır).
-- =====================================================================

set client_encoding = 'UTF8';

-- Verilen kullanıcı olarak çağırır (p_uid null ise oturumsuz).
create or replace function pg_temp.rapor_cagir(p_uid uuid) returns jsonb
language plpgsql
as $fn$
begin
  perform set_config(
    'request.jwt.claims',
    case when p_uid is null then '' else json_build_object('sub', p_uid, 'role', 'authenticated')::text end,
    false
  );
  return public.ogretmen_siniflarim();
end
$fn$;

create or replace function pg_temp.ogretmen_sinif_raporu_testleri()
returns table (no int, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v_adm  uuid := gen_random_uuid();
  v_oa   uuid := gen_random_uuid();   -- öğretmen A: iki sınıfı var
  v_ob   uuid := gen_random_uuid();   -- öğretmen B: bir sınıfı var
  v_oc   uuid := gen_random_uuid();   -- öğretmen C: sınıfı yok
  v_vel  uuid := gen_random_uuid();
  s1     uuid := gen_random_uuid();
  s2     uuid := gen_random_uuid();
  s3     uuid := gen_random_uuid();
  s4     uuid := gen_random_uuid();   -- sınıfta, hiç cevap vermedi
  s5     uuid := gen_random_uuid();   -- tek öğrencili sınıf
  k_a1   uuid := gen_random_uuid();   -- A: 4 üye, 3 cevaplayan
  k_a2   uuid := gen_random_uuid();   -- A: 1 üye, 1 cevaplayan (eşik altı)
  k_b1   uuid := gen_random_uuid();   -- B: 3 üye, 3 cevaplayan
  k_c    uuid := gen_random_uuid();   -- sahipsiz sınıf (ogretmen_id null)
  v      jsonb;
  v_satir jsonb;
  v_say  int;
  v_dgr  int;
begin
  no := 0;

  -- Kurulum: profiller, sınıflar, üyelikler, cevaplar
  insert into public.profiles (id, role, full_name) values
    (v_adm, 'admin', 'Yönetici Test'),
    (v_oa,  'ogretmen', 'Öğretmen Alfa'),
    (v_ob,  'ogretmen', 'Öğretmen Beta'),
    (v_oc,  'ogretmen', 'Öğretmen Gama'),
    (v_vel, 'veli', 'Veli Test'),
    (s1, 'ogrenci', 'Ali Test Öğrenci'),
    (s2, 'ogrenci', 'Ayşe Test Öğrenci'),
    (s3, 'ogrenci', 'Mehmet Test Öğrenci'),
    (s4, 'ogrenci', 'Elif Test Öğrenci'),
    (s5, 'ogrenci', 'Can Test Öğrenci');

  insert into public.siniflar (id, ad, sinif_seviyesi, ogretmen_id, okul_adi, yil) values
    (k_a1, 'A-5 Sınıfı', 5, v_oa, 'Test Okulu', 2026),
    (k_a2, 'A-6 Sınıfı', 6, v_oa, 'Test Okulu', 2026),
    (k_b1, 'B-7 Sınıfı', 7, v_ob, 'Test Okulu', 2026),
    (k_c,  'Sahipsiz',   4, null, null, 2026);

  insert into public.sinif_uyelikleri (sinif_id, ogrenci_id) values
    (k_a1, s1), (k_a1, s2), (k_a1, s3), (k_a1, s4),
    (k_a2, s5),
    (k_b1, s1), (k_b1, s2), (k_b1, s3);

  -- s1: 6/10 doğru (%50), biri tekrar zamanı geçmiş, biri gelecekte; son cevap şimdi
  insert into public.user_answers (student_id, question_id, dogru_mu, deneme_sayisi, dogru_sayisi, son_cevap_tarihi, sonraki_tekrar_tarihi) values
    (s1, gen_random_uuid(), true,  6, 3, now(), now() - interval '1 day'),
    (s1, gen_random_uuid(), true,  4, 2, now(), now() + interval '1 day');
  -- s2: 10/10 (%100), 10 gün önce; tekrar gelecekte
  insert into public.user_answers (student_id, question_id, dogru_mu, deneme_sayisi, dogru_sayisi, son_cevap_tarihi, sonraki_tekrar_tarihi) values
    (s2, gen_random_uuid(), true, 10, 10, now() - interval '10 days', now() + interval '2 days');
  -- s3: 3/4 (%75), 1 saat önce; tekrar zamanı geçmiş
  insert into public.user_answers (student_id, question_id, dogru_mu, deneme_sayisi, dogru_sayisi, son_cevap_tarihi, sonraki_tekrar_tarihi) values
    (s3, gen_random_uuid(), true,  4, 3, now() - interval '1 hour', now() - interval '2 hours');
  -- s5: tek öğrenci, A-6 sınıfında
  insert into public.user_answers (student_id, question_id, dogru_mu, deneme_sayisi, dogru_sayisi, son_cevap_tarihi, sonraki_tekrar_tarihi) values
    (s5, gen_random_uuid(), false, 5, 2, now(), now() - interval '1 day');

  -- 1. Oturumsuz çağrı reddedilir
  no := no + 1;
  senaryo := 'Oturumsuz çağrı reddedilir (42501)';
  gecti := false; detay := 'çağrı hata vermedi';
  begin
    perform pg_temp.rapor_cagir(null);
  exception when sqlstate '42501' then
    gecti := true; detay := 'reddedildi';
  when others then
    detay := 'beklenmeyen hata: ' || sqlerrm;
  end;
  return next;

  -- 2. Veli rolü reddedilir
  no := no + 1;
  senaryo := 'Veli rolü reddedilir (42501)';
  gecti := false; detay := 'çağrı hata vermedi';
  begin
    perform pg_temp.rapor_cagir(v_vel);
  exception when sqlstate '42501' then
    gecti := true; detay := 'reddedildi';
  when others then
    detay := 'beklenmeyen hata: ' || sqlerrm;
  end;
  return next;

  -- 3. Öğrenci rolü reddedilir
  no := no + 1;
  senaryo := 'Öğrenci rolü reddedilir (42501)';
  gecti := false; detay := 'çağrı hata vermedi';
  begin
    perform pg_temp.rapor_cagir(s1);
  exception when sqlstate '42501' then
    gecti := true; detay := 'reddedildi';
  when others then
    detay := 'beklenmeyen hata: ' || sqlerrm;
  end;
  return next;

  -- 4. Öğretmen A yalnızca kendi iki sınıfını görür (B'nin ve sahipsiz sınıf yok)
  no := no + 1;
  senaryo := 'Öğretmen A yalnızca kendi 2 sınıfını görür (B ve sahipsiz sınıf görünmez)';
  gecti := false; detay := null;
  begin
    v := pg_temp.rapor_cagir(v_oa);
    v_say := jsonb_array_length(v -> 'siniflar');
    gecti := v_say = 2
             and not exists (select 1 from jsonb_array_elements(v -> 'siniflar') e where e ->> 'id' in (k_b1::text, k_c::text));
    detay := format('sayı=%s', v_say);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 5. Öğretmen B yalnızca kendi sınıfını görür
  no := no + 1;
  senaryo := 'Öğretmen B yalnızca kendi sınıfını görür (k_b1)';
  gecti := false; detay := null;
  begin
    v := pg_temp.rapor_cagir(v_ob);
    v_say := jsonb_array_length(v -> 'siniflar');
    gecti := v_say = 1 and (v -> 'siniflar' -> 0 ->> 'id') = k_b1::text;
    detay := format('sayı=%s', v_say);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 6. Admin tüm sınıfları görür (sahipsiz dahil)
  no := no + 1;
  senaryo := 'Admin tüm sınıfları görür (4 sınıf, sahipsiz dahil)';
  gecti := false; detay := null;
  begin
    v := pg_temp.rapor_cagir(v_adm);
    v_say := jsonb_array_length(v -> 'siniflar');
    gecti := v_say = 4;
    detay := format('sayı=%s', v_say);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 7. Sınıfı olmayan öğretmen boş dizi alır (hata değil)
  no := no + 1;
  senaryo := 'Sınıfı olmayan öğretmen boş dizi alır';
  gecti := false; detay := null;
  begin
    v := pg_temp.rapor_cagir(v_oc);
    gecti := jsonb_typeof(v -> 'siniflar') = 'array' and jsonb_array_length(v -> 'siniflar') = 0;
    detay := format('tür=%s', jsonb_typeof(v -> 'siniflar'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- Öğretmen A'nın sınıf satırları (sonraki senaryolar için)
  v := pg_temp.rapor_cagir(v_oa);
  select e into v_satir from jsonb_array_elements(v -> 'siniflar') e where e ->> 'id' = k_a1::text;

  -- 8. Öğrenci sayısı üyelerle eşleşir
  no := no + 1;
  senaryo := 'Öğrenci sayısı üyelik sayısıyla eşleşir (A-5: 4, A-6: 1)';
  gecti := false; detay := null;
  begin
    gecti := (v_satir ->> 'ogrenci_sayisi')::int = 4
             and (select e ->> 'ogrenci_sayisi' from jsonb_array_elements(v -> 'siniflar') e where e ->> 'id' = k_a2::text)::int = 1;
    detay := format('a1=%s', v_satir ->> 'ogrenci_sayisi');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 9. Ortalama doğru oranı: üç cevaplayan öğrencinin bireysel oranlarının ortalaması (50+100+75)/3
  no := no + 1;
  senaryo := 'Ortalama doğru oranı öğrenci bazlı ortalama (A-5: 75)';
  gecti := false; detay := null;
  begin
    gecti := (v_satir ->> 'ortalama_dogru_orani')::int = 75
             and (v_satir ->> 'ilerleme_gosterilir')::boolean = true;
    detay := format('oran=%s gosterilir=%s', v_satir ->> 'ortalama_dogru_orani', v_satir ->> 'ilerleme_gosterilir');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 10. Son 7 gün aktif (s1, s3) ve tekrar bekleyen (s1: 1, s3: 1) sayıları
  no := no + 1;
  senaryo := 'Son 7 gün aktif = 2 (s2 10 gün önce) ve tekrar bekleyen toplamı = 2';
  gecti := false; detay := null;
  begin
    gecti := (v_satir ->> 'aktif_ogrenci_7g')::int = 2
             and (v_satir ->> 'bekleyen_tekrar')::int = 2;
    detay := format('aktif7g=%s bekleyen=%s', v_satir ->> 'aktif_ogrenci_7g', v_satir ->> 'bekleyen_tekrar');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 11. Son etkinlik dolu (en yeni cevap şimdi)
  no := no + 1;
  senaryo := 'Son etkinlik tarihi dolu (en az bir cevap var)';
  gecti := false; detay := null;
  begin
    gecti := (v_satir ->> 'son_aktivite') is not null;
    detay := format('son=%s', v_satir ->> 'son_aktivite');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 12. Eşik altı sınıf (A-6: tek cevaplayan öğrenci) ilerleme değerlerini göstermez
  no := no + 1;
  senaryo := 'Eşik altı sınıf (3 cevaplayan öğrenci yok) ilerleme değerleri null döner';
  gecti := false; detay := null;
  begin
    select e into v_satir from jsonb_array_elements(v -> 'siniflar') e where e ->> 'id' = k_a2::text;
    gecti := (v_satir ->> 'ilerleme_gosterilir')::boolean = false
             and v_satir -> 'ortalama_dogru_orani' = 'null'::jsonb
             and v_satir -> 'aktif_ogrenci_7g' = 'null'::jsonb
             and v_satir -> 'bekleyen_tekrar' = 'null'::jsonb
             and v_satir -> 'son_aktivite' = 'null'::jsonb;
    detay := format('gosterilir=%s oran=%s', v_satir ->> 'ilerleme_gosterilir', v_satir ->> 'ortalama_dogru_orani');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 13. Çıktıda kişisel veri yok: ad, e-posta, öğrenci kimliği, öğrenci UUID'si
  no := no + 1;
  senaryo := 'Çıktıda kişisel veri yok (ad, e-posta, ogrenci_id, öğrenci UUID)';
  gecti := false; detay := null;
  begin
    v := pg_temp.rapor_cagir(v_oa);
    gecti := position('Test Öğrenci' in v::text) = 0
             and position('@' in v::text) = 0
             and position('full_name' in v::text) = 0
             and position('ogrenci_id' in v::text) = 0
             and position(s1::text in v::text) = 0
             and position(s2::text in v::text) = 0;
    detay := 'kontrol tamam';
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 14. anon çalıştıramaz
  no := no + 1;
  senaryo := 'anon rolü ogretmen_siniflarim() çalıştıramaz (EXECUTE yok)';
  gecti := false; detay := null;
  begin
    gecti := not has_function_privilege('anon', 'public.ogretmen_siniflarim()', 'EXECUTE');
    detay := format('anon=%s', has_function_privilege('anon', 'public.ogretmen_siniflarim()', 'EXECUTE'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 15. authenticated çalıştırabilir
  no := no + 1;
  senaryo := 'authenticated rolü ogretmen_siniflarim() çalıştırabilir';
  gecti := false; detay := null;
  begin
    gecti := has_function_privilege('authenticated', 'public.ogretmen_siniflarim()', 'EXECUTE');
    detay := format('authenticated=%s', has_function_privilege('authenticated', 'public.ogretmen_siniflarim()', 'EXECUTE'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 16. SECURITY DEFINER ve sabit search_path (AGENTS.md: zorunlu)
  no := no + 1;
  senaryo := 'SECURITY DEFINER ve search_path = public, pg_temp sabit';
  gecti := false; detay := null;
  begin
    select p.prosecdef and array_to_string(p.proconfig, ',') like '%search_path=public%pg_temp%'
      into gecti
      from pg_proc p
     where p.oid = 'public.ogretmen_siniflarim()'::regprocedure;
    detay := format('gecti=%s', gecti);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- Temizlik: oturum değişkenini sıfırla
  perform set_config('request.jwt.claims', '', false);
end
$fn$;
