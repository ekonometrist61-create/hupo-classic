-- =====================================================================
-- DENEME VELİ RIZA KAPISI TEST SENARYOLARI
-- Kapsam: 20261150000000_veli_deneme_riza_kapisi.sql (AGENTS.md §5.3)
--   get_child_exam_history ve get_upcoming_mock_exams_for_child:
--   veli çağrısında _veli_riza_durumu <> 'verildi' ise boş liste '[]'.
--   Bağsız (veli olmayan) ya da oturumsuz çağrı 42501 alır.
--
-- Sonuç: pg_temp.deneme_riza_kapisi_testleri() -> (no, senaryo, gecti, detay).
-- Kalıcı kayıt bırakmaz: PGlite geçicidir.
-- =====================================================================

-- Verilen kullanıcı olarak oturum açar (p_uid null ise oturumsuz).
create or replace function pg_temp.riza_giris(p_uid uuid) returns void
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

-- Geçmiş deneme sonuçları (veli görünümü).
create or replace function pg_temp.riza_gecmis(p_uid uuid, p_cocuk uuid) returns jsonb
language plpgsql
as $fn$
begin
  perform pg_temp.riza_giris(p_uid);
  return public.get_child_exam_history(p_cocuk);
end
$fn$;

-- Yaklaşan denemeler (veli görünümü).
create or replace function pg_temp.riza_yaklasan(p_uid uuid, p_cocuk uuid) returns jsonb
language plpgsql
as $fn$
begin
  perform pg_temp.riza_giris(p_uid);
  return public.get_upcoming_mock_exams_for_child(p_cocuk);
end
$fn$;

-- Çağrı 42501 ile reddediliyorsa '42501', hata yoksa 'hata yok', diğerlerinde mesaj.
create or replace function pg_temp.riza_hata_kodu(p_fn text, p_uid uuid, p_cocuk uuid) returns text
language plpgsql
as $fn$
begin
  perform pg_temp.riza_giris(p_uid);
  if p_fn = 'gecmis' then
    perform public.get_child_exam_history(p_cocuk);
  else
    perform public.get_upcoming_mock_exams_for_child(p_cocuk);
  end if;
  return 'hata yok';
exception
  when sqlstate '42501' then
    return '42501';
  when others then
    return 'beklenmeyen: ' || sqlstate || ' ' || sqlerrm;
end
$fn$;

create or replace function pg_temp.deneme_riza_kapisi_testleri()
returns table (no int, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v_veli     uuid := '11111111-1111-4111-8111-111111111111';
  v_yabanci  uuid := '22222222-2222-4222-8222-222222222222';
  v_cocuk    uuid := '33333333-3333-4333-8333-333333333333';
  v_gecmis   uuid := '55555555-5555-4555-8555-555555555551';
  v_yakin    uuid := '55555555-5555-4555-8555-555555555552';
  j          jsonb;
  n1         int;
  n2         int;
  durum      text;
  ok         boolean;
  ayrinti    text;
begin
  no := 0;

  -- ---- Kurulum: çocuğun tamamlanmış geçmiş denemesi ve yaklaşan bir sınavı ----
  insert into public.profiles (id, role, full_name) values
    (v_veli, 'veli', 'Test Veli'),
    (v_yabanci, 'veli', 'Yabancı Veli');
  insert into public.profiles (id, role, full_name, parent_id, sinif) values
    (v_cocuk, 'ogrenci', 'Test Çocuk', v_veli, 6);
  insert into public.deneme_sinavlari (id, ad, baslangic_zamani, sure_dakika, siniflar, aktif) values
    (v_gecmis, 'Geçmiş deneme', now() - interval '7 days', 40, '{5,6}', true),
    (v_yakin,  'Yaklaşan deneme', now() + interval '7 days', 40, '{5,6}', true);
  insert into public.deneme_sinavi_denemeleri
    (exam_id, student_id, sinif, puan, dogru_sayisi, yanlis_sayisi, bos_sayisi, bitis_zamani, teslim_turu)
  values
    (v_gecmis, v_cocuk, 6, 70, 14, 4, 2, now() - interval '7 days', 'elle');

  -- 1. Fikstür: gate'siz sayımda veri VAR (aşağıdaki boş dönüşler kapıdan gelmeli)
  select count(*) into n1 from public.deneme_sinavi_denemeleri
   where student_id = v_cocuk and bitis_zamani is not null;
  select count(*) into n2 from public.deneme_sinavlari
   where aktif and baslangic_zamani > now() and 6::smallint = any (siniflar);
  ok := n1 = 1 and n2 = 1;
  no := no + 1; senaryo := 'fikstür: geçmiş deneme ve yaklaşan sınav veritabanında mevcut';
  gecti := ok; detay := format('geçmiş=%s yaklaşan=%s', n1, n2); return next;

  -- 2. Veli, rıza yok -> geçmiş '[]'
  j := pg_temp.riza_gecmis(v_veli, v_cocuk);
  ok := j = '[]'::jsonb;
  no := no + 1; senaryo := 'veli + rıza yok: get_child_exam_history = []';
  gecti := ok; detay := 'sonuç=' || j::text; return next;

  -- 3. Veli, rıza yok -> yaklaşan '[]'
  j := pg_temp.riza_yaklasan(v_veli, v_cocuk);
  ok := j = '[]'::jsonb;
  no := no + 1; senaryo := 'veli + rıza yok: get_upcoming_mock_exams_for_child = []';
  gecti := ok; detay := 'sonuç=' || j::text; return next;

  -- Rıza verilir (veli_acik_riza)
  insert into public.consents (cocuk_id, veli_id, tur, surum)
  values (v_cocuk, v_veli, 'veli_acik_riza', 'deneme-riza-test-v1');

  -- 4. Rıza verildi -> geçmiş veri döner
  j := pg_temp.riza_gecmis(v_veli, v_cocuk);
  ok := jsonb_array_length(j) = 1 and j -> 0 ->> 'sinav_ad' = 'Geçmiş deneme';
  no := no + 1; senaryo := 'rıza verildi: get_child_exam_history veri döndürür';
  gecti := ok; detay := 'sonuç=' || j::text; return next;

  -- 5. Rıza verildi -> yaklaşan veri döner
  j := pg_temp.riza_yaklasan(v_veli, v_cocuk);
  ok := jsonb_array_length(j) = 1 and j -> 0 ->> 'ad' = 'Yaklaşan deneme';
  no := no + 1; senaryo := 'rıza verildi: get_upcoming_mock_exams_for_child veri döndürür';
  gecti := ok; detay := 'sonuç=' || j::text; return next;

  -- 6. Bağsız veli (rıza verili çocuk için bile) -> 42501 (geçmiş)
  ayrinti := pg_temp.riza_hata_kodu('gecmis', v_yabanci, v_cocuk);
  ok := ayrinti = '42501';
  no := no + 1; senaryo := 'bağsız veli: get_child_exam_history 42501 alır';
  gecti := ok; detay := 'sonuç=' || ayrinti; return next;

  -- 7. Bağsız veli -> 42501 (yaklaşan)
  ayrinti := pg_temp.riza_hata_kodu('yaklasan', v_yabanci, v_cocuk);
  ok := ayrinti = '42501';
  no := no + 1; senaryo := 'bağsız veli: get_upcoming_mock_exams_for_child 42501 alır';
  gecti := ok; detay := 'sonuç=' || ayrinti; return next;

  -- Rıza sonradan geri çekilir (daha yeni kayıt, clock_timestamp ile sıralanır)
  insert into public.consents (cocuk_id, veli_id, tur, surum)
  values (v_cocuk, v_veli, 'veli_riza_geri_cekildi', 'deneme-riza-test-v1');

  -- 8. Rıza geri çekildi -> geçmiş '[]' (durum geri_cekildi)
  durum := public._veli_riza_durumu(v_cocuk);
  j := pg_temp.riza_gecmis(v_veli, v_cocuk);
  ok := durum = 'geri_cekildi' and j = '[]'::jsonb;
  no := no + 1; senaryo := 'rıza geri çekildi: get_child_exam_history = []';
  gecti := ok; detay := 'durum=' || durum || ' sonuç=' || j::text; return next;

  -- 9. Rıza geri çekildi -> yaklaşan '[]'
  j := pg_temp.riza_yaklasan(v_veli, v_cocuk);
  ok := j = '[]'::jsonb;
  no := no + 1; senaryo := 'rıza geri çekildi: get_upcoming_mock_exams_for_child = []';
  gecti := ok; detay := 'sonuç=' || j::text; return next;

  -- 10. Oturumsuz çağrı -> 42501 (geçmiş)
  ayrinti := pg_temp.riza_hata_kodu('gecmis', null, v_cocuk);
  ok := ayrinti = '42501';
  no := no + 1; senaryo := 'oturumsuz çağrı: get_child_exam_history 42501 alır';
  gecti := ok; detay := 'sonuç=' || ayrinti; return next;
end
$fn$;
