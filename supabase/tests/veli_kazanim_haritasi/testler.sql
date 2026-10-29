-- =====================================================================
-- VELİ KAZANIM HARİTASI TEST SENARYOLARI
-- Kapsam: 20261139000000_veli_kazanim_haritasi.sql → public.veli_kazanim_haritasi(p_cocuk_id, p_ders)
--   1     yetkisiz çağıran (oturumsuz, veli olmayan veli, öğrencinin kendisi) 42501 alır
--   2     rıza 'verildi' değilse kazanimlar boş döner
--   3     5 cevap → durum veri_yok
--   4     6 cevap, %50 → gelisiyor
--   5     %83, 2 farklı gün, tekrar_sayisi>=1 doğru → guclu
--   6     %83 ama tekrar yok → pekisiyor
--   7     sinif 4: oran null, durum yine hesaplanır
--   8     ders eşlemesi yok → plan_var=false
--   9-10  yetki sözleşmesi: anon çalıştıramaz, authenticated çalıştırır; SECURITY DEFINER + search_path
--
-- Kalıcı kayıt bırakmaz: PGlite geçicidir. Her senaryo kendi hatasını yakalar (FAIL olarak raporlanır).
-- =====================================================================

set client_encoding = 'UTF8';

-- Verilen kullanıcı olarak haritayı çağırır (p_uid null ise oturumsuz).
create or replace function pg_temp.harita_cagir(p_uid uuid, p_cocuk uuid, p_ders text) returns jsonb
language plpgsql
as $fn$
begin
  perform set_config(
    'request.jwt.claims',
    case when p_uid is null then '' else json_build_object('sub', p_uid, 'role', 'authenticated')::text end,
    false
  );
  return public.veli_kazanim_haritasi(p_cocuk, p_ders);
end
$fn$;

-- Çağrı 42501 ile reddediliyorsa 'reddedildi', hata yoksa 'hata yok', diğerlerinde mesaj döner.
create or replace function pg_temp.reddedildi_mi(p_uid uuid, p_cocuk uuid) returns text
language plpgsql
as $fn$
begin
  perform pg_temp.harita_cagir(p_uid, p_cocuk, 'Matematik');
  return 'hata yok';
exception when sqlstate '42501' then
  return 'reddedildi';
when others then
  return 'beklenmeyen: ' || sqlerrm;
end
$fn$;

-- Öğrencinin cevap olayları: ilk p_adet onaylı soru, ilk p_dogru tanesi doğru; p_gun_geri gün önce.
create or replace function pg_temp.olay_ekle(p_ogrenci uuid, p_sinif int, p_kazanim text,
                                             p_adet int, p_dogru int, p_gun_geri int) returns void
language plpgsql
as $fn$
begin
  insert into public.answer_events (student_id, question_id, dogru_mu, created_at)
  select p_ogrenci, q.id, q.rn <= p_dogru, now() - make_interval(days => p_gun_geri)
    from (select id, row_number() over (order by id) as rn
            from public.questions
           where sinif = p_sinif and kazanim_kodu = p_kazanim and onay_durumu = 'onaylandi') q
   where q.rn <= p_adet;
end
$fn$;

-- Kazanım satırını (kod eşleşen) döndürür.
create or replace function pg_temp.kazanim_satiri(v jsonb, p_kod text) returns jsonb
language plpgsql
as $fn$
declare
  r jsonb;
begin
  select e into r from jsonb_array_elements(v -> 'kazanimlar') e where e ->> 'kod' = p_kod;
  return r;
end
$fn$;

create or replace function pg_temp.veli_kazanim_haritasi_testleri()
returns table (no int, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v_veli     uuid := gen_random_uuid();   -- veli: 5 çocuğu var
  v_yabanci  uuid := gen_random_uuid();   -- veli: çocuğu yok
  c_az       uuid := gen_random_uuid();   -- sinif 5, verildi, 5 cevap
  c_orta     uuid := gen_random_uuid();   -- sinif 5, verildi, 6 cevap, 3 doğru
  c_guclu    uuid := gen_random_uuid();   -- sinif 5, verildi, 6 cevap 5 doğru, 2 gün, tekrar doğru
  c_pekis    uuid := gen_random_uuid();   -- aynı, tekrar yok
  c_dort     uuid := gen_random_uuid();   -- sinif 4, verildi, guclu koşulları
  c_riza_yok uuid := gen_random_uuid();   -- rıza kaydı yok
  c_geri     uuid := gen_random_uuid();   -- rıza geri çekildi
  v      jsonb;
  v2     jsonb;
  r      jsonb;
  v_bir  text;
  v_iki  text;
  v_uc   text;
begin
  no := 0;

  -- Kurulum: veli, çocuklar, sorular, kazanım özeti, rıza, cevaplar
  insert into public.profiles (id, role, parent_id, sinif, full_name) values
    (v_veli,    'veli',    null, null, 'Veli Test'),
    (v_yabanci, 'veli',    null, null, 'Başka Veli'),
    (c_az,      'ogrenci', v_veli, 5, 'Çocuk Az'),
    (c_orta,    'ogrenci', v_veli, 5, 'Çocuk Orta'),
    (c_guclu,   'ogrenci', v_veli, 5, 'Çocuk Güçlü'),
    (c_pekis,   'ogrenci', v_veli, 5, 'Çocuk Pekişen'),
    (c_dort,    'ogrenci', v_veli, 4, 'Çocuk Dört'),
    (c_riza_yok,'ogrenci', v_veli, 5, 'Çocuk Rızasız'),
    (c_geri,    'ogrenci', v_veli, 5, 'Çocuk Geri');

  insert into public.questions (ders, sinif, konu, kazanim_kodu, kazanim_metni, onay_durumu)
  select 'Matematik', 5, 'Doğal sayılar', 'M.5.1.1', 'Doğal sayılarla işlemler', 'onaylandi'
    from generate_series(1, 10);
  insert into public.questions (ders, sinif, konu, kazanim_kodu, kazanim_metni, onay_durumu)
  select 'Matematik', 4, 'Doğal sayılar', 'M.4.1.1', 'Doğal sayılarla işlemler', 'onaylandi'
    from generate_series(1, 10);

  insert into public.mufredat_ders_eslesme (soru_ders, mufredat_ders) values ('Matematik', 'Matematik');

  insert into public.mufredat_kazanim_ozet (ders, sinif, kazanim_kodu, ilk_hafta, son_hafta, kazanim_metni, unite_tema, konu) values
    ('Matematik', 5, 'M.5.1.1', 1, 1, 'Doğal sayılarla işlemler', 'Doğal Sayılar', 'Toplama'),
    ('Matematik', 5, 'M.5.1.2', 3, 3, 'Kesirler',                  'Kesirler',      'Kesir'),
    ('Matematik', 4, 'M.4.1.1', 1, 1, 'Doğal sayılarla işlemler', 'Doğal Sayılar', 'Toplama');

  insert into public.test_riza (cocuk_id, durum) values
    (c_az, 'verildi'), (c_orta, 'verildi'), (c_guclu, 'verildi'),
    (c_pekis, 'verildi'), (c_dort, 'verildi'), (c_geri, 'geri_cekildi');
  -- c_riza_yok: rıza kaydı yok → 'yok'

  -- c_az: 5 cevap, 3 doğru
  perform pg_temp.olay_ekle(c_az, 5, 'M.5.1.1', 5, 3, 0);
  -- c_orta: 6 cevap, 3 doğru (%50)
  perform pg_temp.olay_ekle(c_orta, 5, 'M.5.1.1', 6, 3, 0);
  -- c_guclu: 3 doğru (bugün) + 2 doğru/1 yanlış (dün) = 5/6 (%83), 2 farklı gün
  perform pg_temp.olay_ekle(c_guclu, 5, 'M.5.1.1', 3, 3, 0);
  perform pg_temp.olay_ekle(c_guclu, 5, 'M.5.1.1', 3, 2, 1);
  insert into public.user_answers (student_id, question_id, dogru_mu, deneme_sayisi, dogru_sayisi, tekrar_sayisi)
  select c_guclu, q.id, true, 1, 1, 1
    from (select id from public.questions where sinif = 5 and kazanim_kodu = 'M.5.1.1' order by id limit 1) q;
  -- c_pekis: aynı cevap dağılımı, tekrar yok
  perform pg_temp.olay_ekle(c_pekis, 5, 'M.5.1.1', 3, 3, 0);
  perform pg_temp.olay_ekle(c_pekis, 5, 'M.5.1.1', 3, 2, 1);
  insert into public.user_answers (student_id, question_id, dogru_mu, deneme_sayisi, dogru_sayisi, tekrar_sayisi)
  select c_pekis, q.id, true, 1, 1, 0
    from (select id from public.questions where sinif = 5 and kazanim_kodu = 'M.5.1.1' order by id limit 1) q;
  -- c_dort: sinif 4, aynı dağılım + tekrar
  perform pg_temp.olay_ekle(c_dort, 4, 'M.4.1.1', 3, 3, 0);
  perform pg_temp.olay_ekle(c_dort, 4, 'M.4.1.1', 3, 2, 1);
  insert into public.user_answers (student_id, question_id, dogru_mu, deneme_sayisi, dogru_sayisi, tekrar_sayisi)
  select c_dort, q.id, true, 1, 1, 1
    from (select id from public.questions where sinif = 4 and kazanim_kodu = 'M.4.1.1' order by id limit 1) q;
  -- c_riza_yok ve c_geri: tam doğru cevaplar var ama rıza kapısı kapalı
  perform pg_temp.olay_ekle(c_riza_yok, 5, 'M.5.1.1', 6, 6, 0);
  perform pg_temp.olay_ekle(c_geri, 5, 'M.5.1.1', 6, 6, 0);

  -- 1. Yetkisiz çağıranlar 42501 alır
  no := no + 1;
  senaryo := 'Veli olmayan çağıran 42501 alır (oturumsuz, başka veli, öğrencinin kendisi)';
  gecti := false; detay := null;
  begin
    v_bir := pg_temp.reddedildi_mi(null, c_az);
    v_iki := pg_temp.reddedildi_mi(v_yabanci, c_az);
    v_uc  := pg_temp.reddedildi_mi(c_az, c_az);
    gecti := v_bir = 'reddedildi' and v_iki = 'reddedildi' and v_uc = 'reddedildi';
    detay := format('oturumsuz=%s; yabanci=%s; ogrenci=%s', v_bir, v_iki, v_uc);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 2. Rıza verilmemişse (yok / geri_cekildi) kazanimlar boş döner
  no := no + 1;
  senaryo := 'Rıza verildi değilse kazanimlar boş döner (yok ve geri_cekildi)';
  gecti := false; detay := null;
  begin
    v  := pg_temp.harita_cagir(v_veli, c_riza_yok, 'Matematik');
    v2 := pg_temp.harita_cagir(v_veli, c_geri, 'Matematik');
    gecti := v ->> 'riza' = 'yok' and v -> 'kazanimlar' = '[]'::jsonb
             and v2 ->> 'riza' = 'geri_cekildi' and v2 -> 'kazanimlar' = '[]'::jsonb;
    detay := format('yok: riza=%s kaz=%s; geri: riza=%s kaz=%s',
                    v ->> 'riza', jsonb_array_length(v -> 'kazanimlar'),
                    v2 ->> 'riza', jsonb_array_length(v2 -> 'kazanimlar'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 3. 5 cevap → veri_yok (oran null)
  no := no + 1;
  senaryo := '5 cevap → durum veri_yok, oran null';
  gecti := false; detay := null;
  begin
    v := pg_temp.harita_cagir(v_veli, c_az, 'Matematik');
    r := pg_temp.kazanim_satiri(v, 'M.5.1.1');
    gecti := (r ->> 'cevap')::int = 5 and r ->> 'durum' = 'veri_yok' and r -> 'oran' = 'null'::jsonb;
    detay := format('cevap=%s durum=%s oran=%s', r ->> 'cevap', r ->> 'durum', r -> 'oran');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 4. 6 cevap, %50 → gelisiyor
  no := no + 1;
  senaryo := '6 cevap, %50 doğru → durum gelisiyor (oran 50)';
  gecti := false; detay := null;
  begin
    v := pg_temp.harita_cagir(v_veli, c_orta, 'Matematik');
    r := pg_temp.kazanim_satiri(v, 'M.5.1.1');
    gecti := (r ->> 'cevap')::int = 6 and r ->> 'durum' = 'gelisiyor' and (r ->> 'oran')::int = 50;
    detay := format('cevap=%s durum=%s oran=%s', r ->> 'cevap', r ->> 'durum', r ->> 'oran');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 5. %83, 2 farklı gün, tekrar doğru → guclu
  no := no + 1;
  senaryo := '%83, 2 farklı gün, tekrar_sayisi>=1 doğru → durum guclu';
  gecti := false; detay := null;
  begin
    v := pg_temp.harita_cagir(v_veli, c_guclu, 'Matematik');
    r := pg_temp.kazanim_satiri(v, 'M.5.1.1');
    gecti := r ->> 'durum' = 'guclu' and (r ->> 'oran')::int = 83
             and (r ->> 'farkli_gun')::int = 2 and (r ->> 'kalici_dogru')::int = 1;
    detay := format('durum=%s oran=%s gun=%s kalici=%s', r ->> 'durum', r ->> 'oran', r ->> 'farkli_gun', r ->> 'kalici_dogru');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 6. %83 ama tekrar yok → pekisiyor
  no := no + 1;
  senaryo := '%83 ama tekrar yok (kalici 0) → durum pekisiyor';
  gecti := false; detay := null;
  begin
    v := pg_temp.harita_cagir(v_veli, c_pekis, 'Matematik');
    r := pg_temp.kazanim_satiri(v, 'M.5.1.1');
    gecti := r ->> 'durum' = 'pekisiyor' and (r ->> 'oran')::int = 83
             and (r ->> 'farkli_gun')::int = 2 and (r ->> 'kalici_dogru')::int = 0;
    detay := format('durum=%s oran=%s gun=%s kalici=%s', r ->> 'durum', r ->> 'oran', r ->> 'farkli_gun', r ->> 'kalici_dogru');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 7. Sinif 4: oran null, durum yine hesaplanır (guclu)
  no := no + 1;
  senaryo := 'Sinif 4: oran null, durum yine hesaplanır (guclu)';
  gecti := false; detay := null;
  begin
    v := pg_temp.harita_cagir(v_veli, c_dort, 'Matematik');
    r := pg_temp.kazanim_satiri(v, 'M.4.1.1');
    gecti := (v ->> 'sinif')::int = 4 and r -> 'oran' = 'null'::jsonb
             and r ->> 'durum' = 'guclu' and (r ->> 'cevap')::int = 6;
    detay := format('sinif=%s oran=%s durum=%s cevap=%s', v ->> 'sinif', r -> 'oran', r ->> 'durum', r ->> 'cevap');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 8. Ders eşlemesi yok → plan_var=false, kazanimlar boş
  no := no + 1;
  senaryo := 'Ders eşlemesi yoksa plan_var=false ve kazanimlar boş';
  gecti := false; detay := null;
  begin
    v := pg_temp.harita_cagir(v_veli, c_az, 'Müzik');
    gecti := v ->> 'plan_var' = 'false' and v -> 'kazanimlar' = '[]'::jsonb;
    detay := format('plan_var=%s kazanimlar=%s', v ->> 'plan_var', jsonb_array_length(v -> 'kazanimlar'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 9. anon çalıştıramaz
  no := no + 1;
  senaryo := 'anon rolü veli_kazanim_haritasi() çalıştıramaz (EXECUTE yok)';
  gecti := false; detay := null;
  begin
    gecti := not has_function_privilege('anon', 'public.veli_kazanim_haritasi(uuid,text)', 'EXECUTE');
    detay := format('anon=%s', has_function_privilege('anon', 'public.veli_kazanim_haritasi(uuid,text)', 'EXECUTE'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 10. authenticated çalıştırabilir; SECURITY DEFINER ve search_path boş
  no := no + 1;
  senaryo := 'authenticated çalıştırabilir; SECURITY DEFINER ve search_path ("") sabit';
  gecti := false; detay := null;
  begin
    select has_function_privilege('authenticated', 'public.veli_kazanim_haritasi(uuid,text)', 'EXECUTE')
           and p.prosecdef and array_to_string(p.proconfig, ',') like '%search_path=""%'
      into gecti
      from pg_proc p
     where p.oid = 'public.veli_kazanim_haritasi(uuid,text)'::regprocedure;
    detay := format('gecti=%s', gecti);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- Temizlik: oturum değişkenini sıfırla
  perform set_config('request.jwt.claims', '', false);
end
$fn$;
