-- Soru Atölyesi paket içe aktarma testleri (PGlite). Her iddia başarısızsa exception atar.
do $t$
declare
  r        jsonb;
  n        integer;
  durum    text;
  hata_ok  boolean;
begin
  -- Yardımcı: geçerli 4 şıklı soru
  -- (her çağrıda ayrı bir paket/parti kullanılır)

  -- A) Geçerli paket: beklemede girer, dış kimlik, ipucu ve kaynak bilgisi yazılır
  r := public.admin_import_questions_v2(jsonb_build_object(
    'surum', '1',
    'parti', jsonb_build_object('parti_id', 'test-parti-001', 'aciklama', 'test'),
    'kaynaklar', jsonb_build_array(jsonb_build_object(
      'kaynak_id', 'meb-test-kaynak', 'baslik', 'Test kaynağı', 'lisans_durumu', 'belirsiz',
      'sinif', 4, 'ders', 'Matematik', 'lisans_dayanagi', 'test dayanağı')),
    'sorular', jsonb_build_array(jsonb_build_object(
      'soru_id', 'meb-test-kaynak-s0001', 'okul', 'ilkokul', 'sinif', 4, 'ders', 'Matematik',
      'konu', 'Toplama', 'zorluk', 1, 'soru_metni', 'Ayşe 12 çilek, Ömer 15 çilek aldı. Toplam kaç çilek?',
      'siklar', jsonb_build_object('A', '25', 'B', '27', 'C', '29', 'D', '31'), 'dogru_sik', 'B',
      'cozum_adimlari', jsonb_build_array('12 + 15 = 27', 'Doğru cevap B seçeneğidir.'),
      'ipuclari', jsonb_build_array('İki sayıyı birleştir.'),
      'yanlis_sik_geri_bildirimi', jsonb_build_object('A', jsonb_build_object('neden_yanlis', '2 eksik')),
      'kaynak_id', 'meb-test-kaynak', 'kaynak_sayfa', 3, 'kaynak_turu', 'birebir',
      'uretim_yontemi', 'pdf', 'kalite_durumu', 'yesil'))));
  if r->>'eklenen' <> '1' then raise exception 'A: eklenen 1 olmalı, gelen %', r; end if;

  select onay_durumu into durum from public.questions where dis_soru_id = 'meb-test-kaynak-s0001';
  if durum <> 'beklemede' then raise exception 'A: onay_durumu beklemede olmalı, gelen %', durum; end if;

  if (select uretim_partisi from public.questions where dis_soru_id = 'meb-test-kaynak-s0001') <> 'test-parti-001' then
    raise exception 'A: uretim_partisi yazılmalı';
  end if;
  if (select jsonb_array_length(ipuclari) from public.questions where dis_soru_id = 'meb-test-kaynak-s0001') <> 1 then
    raise exception 'A: ipuclari yazılmalı';
  end if;
  if (select count(*) from public.soru_kaynaklari where kaynak_id = 'meb-test-kaynak') <> 1 then
    raise exception 'A: kaynak kaydı yazılmalı';
  end if;

  -- B) Aynı parti tekrar: reddedilmeli
  hata_ok := false;
  begin
    perform public.admin_import_questions_v2(jsonb_build_object('surum', '1', 'parti', jsonb_build_object('parti_id', 'test-parti-001'), 'sorular', '[]'::jsonb));
  exception when unique_violation then hata_ok := true;
  end;
  if not hata_ok then raise exception 'B: aynı parti ikinci kez içe aktarılmamalı'; end if;

  -- C) Sınıf eksik: hatalı, yazılmaz
  r := public.admin_import_questions_v2(jsonb_build_object(
    'surum', '1', 'parti', jsonb_build_object('parti_id', 'test-parti-002'),
    'sorular', jsonb_build_array(jsonb_build_object(
      'soru_id', 'sinifsiz-soru-0001', 'okul', 'ilkokul', 'ders', 'Matematik', 'konu', 'X', 'zorluk', 1,
      'soru_metni', 'Sınıfsız soru metni', 'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'A',
      'cozum_adimlari', jsonb_build_array('Doğru cevap A seçeneğidir.')))));
  if r->>'hatali' <> '1' or r->>'eklenen' <> '0' then raise exception 'C: sınıfsız soru reddedilmeli, gelen %', r; end if;

  -- D) Sınıf 9: hatalı
  r := public.admin_import_questions_v2(jsonb_build_object(
    'surum', '1', 'parti', jsonb_build_object('parti_id', 'test-parti-003'),
    'sorular', jsonb_build_array(jsonb_build_object(
      'soru_id', 'sinif-dokuz-0001', 'okul', 'ortaokul', 'sinif', 9, 'ders', 'Matematik', 'konu', 'X', 'zorluk', 1,
      'soru_metni', 'Dokuzuncu sınıf soru', 'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'A',
      'cozum_adimlari', jsonb_build_array('Doğru cevap A seçeneğidir.')))));
  if r->>'hatali' <> '1' then raise exception 'D: sınıf 9 reddedilmeli, gelen %', r; end if;

  -- E) Kırmızı kalite: içe aktarılamaz
  r := public.admin_import_questions_v2(jsonb_build_object(
    'surum', '1', 'parti', jsonb_build_object('parti_id', 'test-parti-004'),
    'sorular', jsonb_build_array(jsonb_build_object(
      'soru_id', 'kirmizi-soru-0001', 'okul', 'ilkokul', 'sinif', 4, 'ders', 'Matematik', 'konu', 'X', 'zorluk', 1,
      'soru_metni', 'Kırmızı kalite sorusu metni', 'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'A',
      'cozum_adimlari', jsonb_build_array('Doğru cevap A seçeneğidir.'), 'kalite_durumu', 'kirmizi'))));
  if r->>'hatali' <> '1' then raise exception 'E: kırmızı soru reddedilmeli, gelen %', r; end if;

  -- F) Birebir ama kaynağın lisans dayanağı boş: reddedilmeli
  r := public.admin_import_questions_v2(jsonb_build_object(
    'surum', '1', 'parti', jsonb_build_object('parti_id', 'test-parti-005'),
    'kaynaklar', jsonb_build_array(jsonb_build_object('kaynak_id', 'meb-dayanaksiz', 'baslik', 'X', 'lisans_durumu', 'belirsiz', 'lisans_dayanagi', '')),
    'sorular', jsonb_build_array(jsonb_build_object(
      'soru_id', 'birebir-soru-0001', 'okul', 'ilkokul', 'sinif', 4, 'ders', 'Matematik', 'konu', 'X', 'zorluk', 1,
      'soru_metni', 'Birebir ama dayanaksız soru metni', 'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'A',
      'cozum_adimlari', jsonb_build_array('Doğru cevap A seçeneğidir.'), 'kaynak_id', 'meb-dayanaksiz', 'kaynak_turu', 'birebir'))));
  if r->>'hatali' <> '1' then raise exception 'F: dayanaksız birebir reddedilmeli, gelen %', r; end if;

  -- G) Onaylı içe aktarma: yalnızca insan onayı olan 'onaylandi' olur
  r := public.admin_import_questions_v2(jsonb_build_object(
    'surum', '1', 'parti', jsonb_build_object('parti_id', 'test-parti-006'),
    'sorular', jsonb_build_array(
      jsonb_build_object(
        'soru_id', 'onayli-soru-0001', 'okul', 'ilkokul', 'sinif', 4, 'ders', 'Matematik', 'konu', 'X', 'zorluk', 1,
        'soru_metni', 'İnsan onaylı birinci soru metni', 'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'A',
        'cozum_adimlari', jsonb_build_array('Doğru cevap A seçeneğidir.'),
        'insan_onayi', jsonb_build_object('kim', 'Test', 'ne_zaman', '2026-10-17T10:00:00+03:00', 'karar', 'onay')),
      jsonb_build_object(
        'soru_id', 'onaysiz-soru-0002', 'okul', 'ilkokul', 'sinif', 4, 'ders', 'Matematik', 'konu', 'X', 'zorluk', 1,
        'soru_metni', 'İnsan onayı olmayan ikinci soru metni', 'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'A',
        'cozum_adimlari', jsonb_build_array('Doğru cevap A seçeneğidir.')))), true);
  if r->>'eklenen' <> '2' then raise exception 'G: iki soru eklenmeli, gelen %', r; end if;
  if (select onay_durumu from public.questions where dis_soru_id = 'onayli-soru-0001') <> 'onaylandi' then
    raise exception 'G: insan onaylı soru onaylandi olmalı';
  end if;
  if (select onay_durumu from public.questions where dis_soru_id = 'onaysiz-soru-0002') <> 'beklemede' then
    raise exception 'G: onaysız soru beklemede kalmalı';
  end if;

  -- H) Aynı metin, aynı sınıf/ders/konu başka partide: tekrar sayılır
  r := public.admin_import_questions_v2(jsonb_build_object(
    'surum', '1', 'parti', jsonb_build_object('parti_id', 'test-parti-007'),
    'sorular', jsonb_build_array(jsonb_build_object(
      'soru_id', 'tekrar-soru-0001', 'okul', 'ilkokul', 'sinif', 4, 'ders', 'Matematik', 'konu', 'Toplama', 'zorluk', 1,
      'soru_metni', 'Ayşe 12 çilek, Ömer 15 çilek aldı. Toplam kaç çilek?',
      'siklar', jsonb_build_object('A', '25', 'B', '27'), 'dogru_sik', 'B',
      'cozum_adimlari', jsonb_build_array('Doğru cevap B seçeneğidir.')))));
  if r->>'tekrar' <> '1' or r->>'eklenen' <> '0' then raise exception 'H: mükerrer soru atlanmalı, gelen %', r; end if;

  -- I) Geri alma: sorular silinmez, reddedildi olur; parti durumu güncellenir
  r := public.admin_geri_al_parti('test-parti-006');
  if r->>'geri_alinan' <> '2' then raise exception 'I: iki soru geri alınmalı, gelen %', r; end if;
  if (select count(*) from public.questions where uretim_partisi = 'test-parti-006') <> 2 then
    raise exception 'I: geri alma silme yapmamalı';
  end if;
  if (select si.durum from public.soru_importlari si where si.parti_id = 'test-parti-006') <> 'geri_alindi' then
    raise exception 'I: parti durumu geri_alindi olmalı';
  end if;

  -- J) Yeni alanlar istemciye açık değil (öğrenci cevaptan önce ipucu/yanlış şık göremez)
  if has_column_privilege('authenticated', 'public.questions', 'ipuclari', 'SELECT') then
    raise exception 'J: ipuclari authenticated tarafından okunmamalı';
  end if;
  if has_column_privilege('authenticated', 'public.questions', 'yanlis_sik_geri_bildirimi', 'SELECT') then
    raise exception 'J: yanlis_sik_geri_bildirimi authenticated tarafından okunmamalı';
  end if;
  if has_table_privilege('anon', 'public.soru_importlari', 'SELECT') then
    raise exception 'J: soru_importlari anon tarafından okunmamalı';
  end if;

  raise notice 'TUM TESTLER GECTI';
end;
$t$;
