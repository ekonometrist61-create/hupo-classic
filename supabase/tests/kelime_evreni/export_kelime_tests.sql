-- GÖR-048: export_my_data 'kelime' bölümünün GERÇEK kelime migrasyonlarıyla sınanması.
-- Yükleme sırası (pglite-kos benzeri, export_kelime_kos.mjs): export_taban_stubs.sql →
-- 20261022000000_kelime_evreni.sql → 20261045000000_kelime_veli_ozeti_riza_kapisi.sql →
-- 20261046000000_export_my_data_kelime.sql → bu dosya.
-- Sonuç: pg_temp.export_kelime_testleri() → (no, senaryo, gecti, detay).

create or replace function pg_temp.exp_giris(p_uid uuid)
returns void language plpgsql as $fn$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_uid, 'role', 'authenticated')::text, false);
  perform set_config('role', 'authenticated', false);
end $fn$;

create or replace function pg_temp.exp_cikis()
returns void language plpgsql as $fn$
begin
  perform set_config('role', 'none', false);
  perform set_config('request.jwt.claims', '', false);
end $fn$;

create or replace function pg_temp.export_kelime_testleri()
returns table (no int, senaryo text, gecti boolean, detay text)
language plpgsql as $fn$
declare
  ob uuid := gen_random_uuid();   -- test edilen öğrenci
  oa uuid := gen_random_uuid();   -- başka öğrenci (sızıntı kontrolü)
  an1 uuid; an2 uuid; so1 uuid; so2 uuid;
  ex jsonb; kel jsonb;
  sonuc text[] := '{}';
  sayac int := 0;
  ok boolean;
  n_den int; n_ust int; n_kay int;
begin
  -- Hesaplar (yalın kurulum; tümü transaction içinde, sonunda geri alınabilir)
  insert into auth.users (id, email) values (ob, 'kelime-b@test.local'), (oa, 'kelime-a@test.local');
  insert into public.profiles (id, role, full_name) values (ob, 'ogrenci', 'Test B'), (oa, 'ogrenci', 'Test A');

  -- Kelime sözlüğü ve sorular (gerçek tablolar, gerçek kısıtlar)
  insert into public.kelime_anlamlari (kelime, anlam) values
    ('bulut', 'gökyüzünde yüzen su buharı kümesi'), ('sis', 'havada asılı kalan ince su tanecikleri');
  select id into an1 from public.kelime_anlamlari where kelime = 'bulut';
  select id into an2 from public.kelime_anlamlari where kelime = 'sis';
  insert into public.kelime_sorulari (anlam_id, iliski_turu, sinif, soru_metni, secenekler, dogru_indeks, aciklama)
    values (an1, 'es_anlamli', 3, 'Bulut sözcüğünün eş anlamlısı hangisidir?', '["sis","bulut"]', 1, 'Test sorusu, açıklama metni yeterli uzunlukta.')
    returning id into so1;
  insert into public.kelime_sorulari (anlam_id, iliski_turu, sinif, soru_metni, secenekler, dogru_indeks, aciklama)
    values (an2, 'es_anlamli', 3, 'Sis sözcüğünün eş anlamlısı hangisidir?', '["bulut","es"]', 0, 'Test sorusu, açıklama metni yeterli uzunlukta.')
    returning id into so2;

  -- Öğrenci B'nin kelime verisi (2 deneme, 1 ustalık, 1 kayıt)
  insert into public.kelime_denemeleri (ogrenci_id, soru_id, anlam_id, deneme_anahtari, secilen_indeks, dogru_mu, ipucu_kullanildi, kazanilan_xp)
    values (ob, so1, an1, 'deneme-b-0001-aaaa', 1, true, false, 20),
           (ob, so2, an2, 'deneme-b-0002-bbbb', 1, false, true, 0);
  insert into public.kelime_ustaliklari (ogrenci_id, anlam_id, beceri, basari_seviyesi, sonraki_tekrar_tarihi, son_cevap_tarihi)
    values (ob, an1, 'taninma', 2, now() + interval '1 day', now());
  insert into public.kelime_kaydedilenler (ogrenci_id, anlam_id) values (ob, an2);

  -- Öğrenci A'nın kelime verisi (sızıntı kontrolü için farklı kimlikler)
  insert into public.kelime_denemeleri (ogrenci_id, soru_id, anlam_id, deneme_anahtari, secilen_indeks, dogru_mu, ipucu_kullanildi, kazanilan_xp)
    values (oa, so2, an2, 'deneme-a-0001-cccc', 0, true, false, 10);
  insert into public.kelime_kaydedilenler (ogrenci_id, anlam_id) values (oa, an1);

  -- 1) Kendi verisi tam ve doğru değerlerle çıkıyor
  perform pg_temp.exp_giris(ob);
  ex := public.export_my_data();
  perform pg_temp.exp_cikis();
  kel := ex -> 'kelime';
  ok := (kel #> '{denemeler}') @> '[{"secilen_indeks":1,"dogru_mu":true,"kazanilan_xp":20}]'::jsonb
        and (kel #> '{denemeler}') @> '[{"secilen_indeks":1,"dogru_mu":false,"ipucu_kullanildi":true}]'::jsonb;
  sayac := sayac + 1; no := sayac; senaryo := 'kelime denemeleri kendi değerleriyle çıkar';
  gecti := ok; detay := coalesce((kel #> '{denemeler}')::text, 'null');
  return next;

  -- 2) Sayılar tablolarla eşit (yalnız öğrenci B)
  select count(*) into n_den from public.kelime_denemeleri where ogrenci_id = ob;
  select count(*) into n_ust from public.kelime_ustaliklari where ogrenci_id = ob;
  select count(*) into n_kay from public.kelime_kaydedilenler where ogrenci_id = ob;
  ok := jsonb_array_length(kel #> '{denemeler}') = n_den
        and jsonb_array_length(kel #> '{ustaliklar}') = n_ust
        and jsonb_array_length(kel #> '{kaydedilenler}') = n_kay;
  sayac := sayac + 1; no := sayac; senaryo := 'kelime bölümü satır sayıları tablolarla eşit';
  gecti := ok; detay := format('den %s/%s ust %s/%s kay %s/%s', jsonb_array_length(kel #> '{denemeler}'), n_den,
                              jsonb_array_length(kel #> '{ustaliklar}'), n_ust, jsonb_array_length(kel #> '{kaydedilenler}'), n_kay);
  return next;

  -- 3) Başka öğrencinin kimliği ve verisi çıktıda yok
  ok := position(oa::text in ex::text) = 0
        and position('deneme-a-0001-cccc' in ex::text) = 0
        and position(so2::text in (kel #> '{denemeler}')::text) > 0;
  sayac := sayac + 1; no := sayac; senaryo := 'başka öğrencinin kelime verisi ve kimliği sızmaz';
  gecti := ok; detay := 'kendi soru kimliği (so2) yalnız kendi denemesinde; A verisi yok';
  return next;

  -- 4) Kelime anlam metni dışa aktarılmaz (kelime/anlam metni yalnız id ile dönülür)
  ok := position('gökyüzünde yüzen' in ex::text) = 0 and position('Bulut sözcüğünün' in ex::text) = 0;
  sayac := sayac + 1; no := sayac; senaryo := 'kelime ve anlam metni dışa aktarımda yok (yalnız id)';
  gecti := ok; detay := 'metin alanları sızmadı';
  return next;

  -- 5) Başka kullanıcı oturumunda B'nin kelime verisi görünmez (oturum değişimi)
  perform pg_temp.exp_giris(oa);
  kel := public.export_my_data() -> 'kelime';
  perform pg_temp.exp_cikis();
  ok := jsonb_array_length(kel #> '{denemeler}') = (select count(*) from public.kelime_denemeleri where ogrenci_id = oa)
        and position(so1::text in (kel #> '{denemeler}')::text) = 0;
  sayac := sayac + 1; no := sayac; senaryo := 'A oturumunda yalnız A''nın kelime verisi döner';
  gecti := ok; detay := format('A denemeleri: %s', jsonb_array_length(kel #> '{denemeler}'));
  return next;

  -- 6) anon çağıramaz (yetki kapısı)
  ok := not has_function_privilege('anon', 'public.export_my_data()', 'execute')
        and has_function_privilege('authenticated', 'public.export_my_data()', 'execute');
  sayac := sayac + 1; no := sayac; senaryo := 'export_my_data: anon kapalı, authenticated açık';
  gecti := ok; detay := 'yetki kontrolü';
  return next;
end $fn$;
