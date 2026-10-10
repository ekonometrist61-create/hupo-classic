-- =====================================================================
-- KELİME EVRENİ TEST SENARYOLARI
--
-- Ön koşul: 20261022000000_kelime_evreni.sql uygulanmış olmalı.
-- Çalıştırma: Supabase SQL Editor'e yapıştırıp Run. Her senaryo için "gecti" sütununa bakın.
-- Kalıcı veri bırakmaz: test verisi transaction içinde kurulur ve sonunda geri alınır.
-- Yerel doğrulama: supabase/tests/kelime_evreni/ (PGlite harness, Docker gerekmez).
--
-- Not: Doğrudan tablo okumaları (durum kontrolü) süper kullanıcı rolünde yapılır
-- (pg_temp.kelime_sorgu_text). Yetki kontrolünün kendisi RPC ve tablo-reddi senaryolarında test edilir.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.kelime_giris(p_uid uuid)
returns void language plpgsql as $fn$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_uid, 'role', 'authenticated')::text, false);
  perform set_config('role', 'authenticated', false);
end $fn$;

create or replace function pg_temp.kelime_giris_anon()
returns void language plpgsql as $fn$
begin
  perform set_config('request.jwt.claims', '', false);
  perform set_config('role', 'anon', false);
end $fn$;

create or replace function pg_temp.kelime_cikis()
returns void language plpgsql as $fn$
begin
  perform set_config('role', 'none', false);
  perform set_config('request.jwt.claims', '', false);
end $fn$;

-- Verilen SQL hata verirse ve mesajı beklenen kodu içeriyorsa true
create or replace function pg_temp.kelime_hata_bekle(p_sql text, p_kod text)
returns boolean language plpgsql as $fn$
begin
  execute p_sql;
  return false;
exception when others then
  return sqlerrm like '%' || p_kod || '%';
end $fn$;

-- Durum kontrolü için tek değerli okuma: süper kullanıcı olarak, geçici olarak rol değiştirir
create or replace function pg_temp.kelime_sorgu_text(p_sql text)
returns text language plpgsql as $fn$
declare
  v_rol   text := current_setting('role', true);
  v_sonuc text;
begin
  perform set_config('role', 'none', false);
  execute p_sql into v_sonuc;
  perform set_config('role', coalesce(v_rol, 'none'), false);
  return v_sonuc;
end $fn$;

create or replace function pg_temp.kelime_evreni_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm1  uuid := '00000000-0000-4000-8000-00000000a001';
  adm2  uuid := '00000000-0000-4000-8000-00000000a002';
  ogr5  uuid := '00000000-0000-4000-8000-00000000b005';  -- 5. sınıf öğrenci, vel1'in çocuğu
  ogr6  uuid := '00000000-0000-4000-8000-00000000b006';  -- 6. sınıf öğrenci
  ogr0  uuid := '00000000-0000-4000-8000-00000000b000';  -- sınıfı olmayan öğrenci
  vel1  uuid := '00000000-0000-4000-8000-00000000c001';
  vel2  uuid := '00000000-0000-4000-8000-00000000c002';

  s_mutlu   uuid := '00000000-0000-4000-8000-00000000d001';
  s_sevinc  uuid := '00000000-0000-4000-8000-00000000d002';
  s_uzgun   uuid := '00000000-0000-4000-8000-00000000d003';
  s_hizli   uuid := '00000000-0000-4000-8000-00000000d004';
  s_yuz_ins uuid := '00000000-0000-4000-8000-00000000d005';
  s_yuz_say uuid := '00000000-0000-4000-8000-00000000d006';

  r_zit  uuid := '00000000-0000-4000-8000-00000000e002';  -- ONAYSIZ zıt ilişki

  q1 uuid := '00000000-0000-4000-8000-00000000f001';  -- mutlu / es, 5. sınıf, yayında
  q2 uuid := '00000000-0000-4000-8000-00000000f002';  -- mutlu / zıt, 5. sınıf, TASLAK
  q3 uuid := '00000000-0000-4000-8000-00000000f003';  -- hızlı / es, 6. sınıf, yayında
  q4 uuid := '00000000-0000-4000-8000-00000000f004';  -- yüz(insan) / eş sesli, 5. sınıf, yayında
  q5 uuid := '00000000-0000-4000-8000-00000000f005';  -- mutlu / es, 5. sınıf, yayında (2. soru)
  q6 uuid := '00000000-0000-4000-8000-00000000f006';  -- hızlı / es, 5. sınıf, zorluk 3, yayında

  v_json   jsonb;
  v_json2  jsonb;
  v_sayi   integer;
  v_bool   boolean;
  v_id     uuid;
  v_sicak  uuid;
  v_soguk  uuid;
  v_xp_cagri_once integer;
  v_m1     jsonb;
  v_m2     jsonb;
  v_cevap  jsonb;
  v_cevap2 jsonb;
  v_sor1   text;
  v_sor2   text;
  v_sor3   text;
  v_d1     text;
  v_d2     text;
  v_d3     text;
  v_arena_xp_once integer;
  v_text  text;
begin
  no := 0;

  -- ---------------------------------------------------------------
  -- Test verisi (superuser olarak; RLS ve RPC kurallarını atlar)
  -- ---------------------------------------------------------------
  insert into auth.users (id, email) values
    (adm1, 'kelime.adm1@example.test'), (adm2, 'kelime.adm2@example.test'),
    (ogr5, 'kelime.ogr5@example.test'), (ogr6, 'kelime.ogr6@example.test'),
    (ogr0, 'kelime.ogr0@example.test'), (vel1, 'kelime.vel1@example.test'),
    (vel2, 'kelime.vel2@example.test');

  insert into public.profiles (id, role, full_name, sinif) values
    (adm1, 'admin', 'Yönetici Bir', null),
    (adm2, 'admin', 'Yönetici İki', null),
    (vel1, 'veli', 'Veli Bir', null),
    (vel2, 'veli', 'Veli İki', null),
    (ogr5, 'ogrenci', 'Öğrenci Beş', 5),
    (ogr6, 'ogrenci', 'Öğrenci Altı', 6),
    (ogr0, 'ogrenci', 'Öğrenci Sınıfsız', null);
  update public.profiles set parent_id = vel1 where id = ogr5;

  insert into public.kelime_anlamlari (id, kelime, anlam, sozcuk_turu, olusturan_id) values
    (s_mutlu,   'mutlu',    'sevinç duyan',              'sifat', adm1),
    (s_sevinc,  'sevinçli', 'sevinç dolu, neşeli',       'sifat', adm1),
    (s_uzgun,   'üzgün',    'keder duyan',               'sifat', adm1),
    (s_hizli,   'hızlı',    'çabuk, süratli',            'sifat', adm1),
    (s_yuz_ins, 'yüz',      'insan başının ön kısmı',    'isim',  adm1),
    (s_yuz_say, 'yüz',      'on ondalık sayı (100)',     'isim',  adm1);

  -- Onaylı: es anlamlı (mutlu-sevinçli), eş sesli (yüz-yüz). ONAYSIZ: zıt (mutlu-üzgün)
  insert into public.kelime_iliskileri (kaynak_anlam_id, hedef_anlam_id, iliski_turu, olusturan_id, onaylayan_id, onay_tarihi) values
    (s_mutlu,   s_sevinc,  'es_anlamli',  adm1, adm2, now()),
    (s_yuz_ins, s_yuz_say, 'es_sesli',    adm1, adm2, now());
  insert into public.kelime_iliskileri (id, kaynak_anlam_id, hedef_anlam_id, iliski_turu, olusturan_id) values
    (r_zit, s_mutlu, s_uzgun, 'zit_anlamli', adm1);

  insert into public.kelime_sorulari (id, anlam_id, iliski_turu, sinif, soru_metni, secenekler, dogru_indeks, dogru_anlam_id, ipucu, aciklama, durum, olusturan_id, inceleyen_id, yayin_tarihi) values
    (q1, s_mutlu, 'es_anlamli', 5, 'Mutlu kelimesinin eş anlamlısı hangisidir?',
       '["Üzgün","Sevinçli","Sessiz"]', 1, s_sevinc, 'Sevinç duygusuna bak.',
       'Mutlu ve sevinçli, sevinç duygusunu anlatan eş anlamlı kelimelerdir.', 'yayinda', adm1, adm2, now()),
    (q2, s_mutlu, 'zit_anlamli', 5, 'Mutlu kelimesinin zıt anlamlısı hangisidir?',
       '["Neşeli","Üzgün","Hızlı"]', 1, s_uzgun, null,
       'Mutlu ile üzgün birbirinin karşıtıdır.', 'taslak', adm1, null, null),
    (q3, s_hizli, 'es_anlamli', 6, 'Hızlı kelimesinin eş anlamlısı hangisidir?',
       '["Çabuk","Yavaş"]', 0, null, null,
       'Hızlı ve çabuk aynı anlamdadır.', 'yayinda', adm1, adm2, now()),
    (q4, s_yuz_ins, 'es_sesli', 5, 'Yüz kelimesinin "insan başı" anlamını seç.',
       '["Sayı","Yüz kısmı","Renk"]', 1, null, 'Bir insanın yüzüne bak.',
       'Yüz kelimesi hem insan yüzü hem de sayı anlamında kullanılır.', 'yayinda', adm1, adm2, now()),
    (q5, s_mutlu, 'es_anlamli', 5, 'Hangisi "mutlu" kelimesine anlamca yakındır?',
       '["Sessiz","Sevinçli"]', 1, s_sevinc, null,
       'Sevinçli, mutlu ile aynı duyguyu anlatır.', 'yayinda', adm1, adm2, now());

  -- Zorluk 3 soru (hızlı, 5. sınıf): zorluğa göre XP ve tekrar zamanı testleri için
  insert into public.kelime_sorulari (id, anlam_id, iliski_turu, sinif, zorluk, soru_metni, secenekler, dogru_indeks, aciklama, durum, olusturan_id, inceleyen_id, yayin_tarihi) values
    (q6, s_hizli, 'es_anlamli', 5, 3, 'Hızlı kelimesinin eş anlamlısı hangisidir?',
       '["Yavaş","Çabuk","Ağır"]', 1, 'Hızlı ve çabuk aynı anlamdadır.', 'yayinda', adm1, adm2, now());

  -- Arena (meydan okuma) için öğrenci istatistik kayıtları (davet_eden / davet_edilen FK)
  insert into public.student_stats (student_id) values (ogr5), (ogr6), (ogr0);

  -- ---------------------------------------------------------------
  -- A) Okuma yetkileri ve RLS
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Anon, kelime_sorulari tablosunu doğrudan okuyamaz (permission denied)';
  perform pg_temp.kelime_giris_anon();
  gecti := pg_temp.kelime_hata_bekle('select count(*) from public.kelime_sorulari', 'permission denied');
  detay := 'anon tablo select';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Öğrenci, kelime_sorulari tablosunu doğrudan okuyamaz (doğru şık sızmaz)';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle('select dogru_indeks from public.kelime_sorulari', 'permission denied');
  detay := 'authenticated tablo select';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Öğrenci, kelime_ustaliklari ve kelime_denemeleri tablolarını doğrudan okuyamaz';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle('select count(*) from public.kelime_ustaliklari', 'permission denied')
       and pg_temp.kelime_hata_bekle('select count(*) from public.kelime_denemeleri', 'permission denied');
  detay := 'tablo select reddi';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Öğrenci, deneme tablosuna doğrudan yazamaz (cevap yalnızca RPC ile kaydedilir)';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle(
    'insert into public.kelime_denemeleri (ogrenci_id, soru_id, anlam_id, deneme_anahtari, secilen_indeks, dogru_mu)
     values (''' || ogr5 || ''', ''' || q1 || ''', ''' || s_mutlu || ''', ''elle-yazma-anahtari'', 1, true)',
    'permission denied');
  detay := 'insert reddi';
  perform pg_temp.kelime_cikis();
  return next;

  -- ---------------------------------------------------------------
  -- B) Öğrenci oyun akışı
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Öğrenci oyun listesi: yalnızca yayında + kendi sınıfı; doğru şık ve açıklama YOK';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_oyun_getir('es_anlamli', 20);
  gecti := jsonb_array_length(v_json -> 'sorular') = 3   -- q1, q5, q6 (q2 taslak, q3 6. sınıf)
       and position('dogru_indeks' in v_json::text) = 0
       and position('aciklama' in v_json::text) = 0
       and position('dogru_anlam' in v_json::text) = 0;
  detay := v_json::text;
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Eş sesli oyun listesi: yalnızca q4 döner';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_oyun_getir('es_sesli', 8);
  gecti := jsonb_array_length(v_json -> 'sorular') = 1
       and (v_json -> 'sorular' -> 0 ->> 'id') = q4::text;
  detay := 'sorular: ' || jsonb_array_length(v_json -> 'sorular');
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Geçersiz ilişki türü reddedilir (BAD_RELATION)';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle($q$select public.kelime_oyun_getir('bilinmeyen', 8)$q$, 'BAD_RELATION');
  detay := 'bilinmeyen tür';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Sınıfı olmayan öğrenci oyuna alınmaz (SINIF_GEREKLI)';
  perform pg_temp.kelime_giris(ogr0);
  gecti := pg_temp.kelime_hata_bekle($q$select public.kelime_oyun_getir('es_anlamli', 8)$q$, 'SINIF_GEREKLI');
  detay := 'sinifsiz öğrenci';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Veli ve yönetici oyun RPC''sini çağıramaz (STUDENT_ONLY)';
  perform pg_temp.kelime_giris(vel1);
  v_bool := pg_temp.kelime_hata_bekle($q$select public.kelime_oyun_getir('es_anlamli', 8)$q$, 'STUDENT_ONLY');
  perform pg_temp.kelime_giris(adm1);
  v_bool := v_bool and pg_temp.kelime_hata_bekle($q$select public.kelime_oyun_getir('es_anlamli', 8)$q$, 'STUDENT_ONLY');
  gecti := v_bool;
  detay := 'veli ve admin';
  perform pg_temp.kelime_cikis();
  return next;

  -- ---------------------------------------------------------------
  -- C) Cevap, XP ve ustalık
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'İlk doğru ve ipucusuz cevap: 10 XP, XP çağrısı xp_ver=true, ustalık seviye 1';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_cevap_gonder(q1, 1, false, 'anahtar-q1-ilk-0001');
  perform pg_temp.kelime_cikis();
  v_xp_cagri_once := pg_temp.kelime_sorgu_text(
    'select count(*) from public.stub_xp_cagrilari where student_id = ''' || ogr5 || ''' and xp_ver = true')::integer;
  gecti := (v_json ->> 'dogru')::boolean
       and (v_json ->> 'kazanilan_xp')::integer = 10
       and (v_json ->> 'dogru_indeks')::integer = 1
       and (v_json ->> 'aciklama') is not null
       and ((v_json -> 'ustalik') ->> 'seviye')::integer = 1
       and v_xp_cagri_once = 1;
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'Aynı yanıt aynı anahtarla tekrar gelirse yeniden puanlanmaz (tekrar=true, XP çağrısı yok)';
  v_sayi := pg_temp.kelime_sorgu_text('select count(*) from public.stub_xp_cagrilari')::integer;
  perform pg_temp.kelime_giris(ogr5);
  v_json2 := public.kelime_cevap_gonder(q1, 1, false, 'anahtar-q1-ilk-0001');
  perform pg_temp.kelime_cikis();
  gecti := (v_json2 ->> 'tekrar')::boolean
       and (v_json2 ->> 'kazanilan_xp')::integer = 10
       and pg_temp.kelime_sorgu_text('select count(*) from public.stub_xp_cagrilari')::integer = v_sayi
       and pg_temp.kelime_sorgu_text('select count(*) from public.kelime_denemeleri where deneme_anahtari = ''anahtar-q1-ilk-0001''')::integer = 1;
  detay := v_json2::text;
  return next;

  no := no + 1;
  senaryo := 'Aynı anahtar farklı şık ile gelirse IDEMPOTENCY_CONFLICT';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle(
    $q$select public.kelime_cevap_gonder('00000000-0000-4000-8000-00000000f001', 0, false, 'anahtar-q1-ilk-0001')$q$,
    'IDEMPOTENCY_CONFLICT');
  detay := 'çakışan yeniden deneme';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Aynı soruya ikinci doğru cevap (ipucusuz) XP vermez; xp_ver=false ile seri sayılır';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_cevap_gonder(q1, 1, false, 'anahtar-q1-ikinci-02');
  perform pg_temp.kelime_cikis();
  gecti := (v_json ->> 'kazanilan_xp')::integer = 0
       and (v_json ->> 'tekrar')::boolean = false
       and ((v_json -> 'ustalik') ->> 'seviye')::integer = 2
       and pg_temp.kelime_sorgu_text('select count(*) from public.stub_xp_cagrilari where student_id = ''' || ogr5 || ''' and xp_ver = false')::integer >= 1;
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'İpucuyla doğru cevap: XP yok, ustalık seviyesi değişmez (bu anlam için 0), sonraki tekrar 1 gün';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_cevap_gonder(q4, 1, true, 'anahtar-q4-ipucu-0001');
  perform pg_temp.kelime_cikis();
  v_sayi := pg_temp.kelime_sorgu_text(
    'select basari_seviyesi from public.kelime_ustaliklari where ogrenci_id = ''' || ogr5 || ''' and anlam_id = ''' || s_yuz_ins || ''' and beceri = ''taninma''')::integer;
  gecti := (v_json ->> 'dogru')::boolean
       and (v_json ->> 'kazanilan_xp')::integer = 0
       and v_sayi = 0
       and pg_temp.kelime_sorgu_text('select count(*) from public.kelime_denemeleri where deneme_anahtari = ''anahtar-q4-ipucu-0001'' and ipucu_kullanildi')::integer = 1;
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'Yanlış cevap: XP yok, ustalık seviye 0, açıklama döner';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_cevap_gonder(q4, 0, false, 'anahtar-q4-yanlis-01');
  perform pg_temp.kelime_cikis();
  gecti := (v_json ->> 'dogru')::boolean = false
       and (v_json ->> 'kazanilan_xp')::integer = 0
       and ((v_json -> 'ustalik') ->> 'seviye')::integer = 0
       and (v_json ->> 'aciklama') is not null;
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'Tanıma ustalığı en fazla 3 olur (seçenekle tanıma tam ustalık değildir)';
  perform pg_temp.kelime_giris(ogr5);
  -- "mutlu" anlamında doğru cevaplar: q1 (1.), q1 (2.), q5 (3.), q1 (4.). Tavan 3.
  v_json := public.kelime_cevap_gonder(q5, 1, false, 'anahtar-q5-ilk-0001');
  v_json2 := public.kelime_cevap_gonder(q1, 1, false, 'anahtar-q1-ucuncu-3');
  perform pg_temp.kelime_cikis();
  gecti := ((v_json2 -> 'ustalik') ->> 'seviye')::integer = 3
       and pg_temp.kelime_sorgu_text('select max(basari_seviyesi) from public.kelime_ustaliklari where ogrenci_id = ''' || ogr5 || ''' and anlam_id = ''' || s_mutlu || '''')::integer = 3;
  detay := (v_json2 -> 'ustalik')::text;
  return next;

  no := no + 1;
  senaryo := 'XP zorluğa göre: zorluk 3 sorunun ilk doğru (ipucusuz) cevabı 30 XP verir';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_cevap_gonder(q6, 1, false, 'anahtar-q6-zor-0001');
  perform pg_temp.kelime_cikis();
  gecti := (v_json ->> 'dogru')::boolean and (v_json ->> 'kazanilan_xp')::integer = 30;
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'XP tekrar zamanı kuralı: tekrar zamanı gelen anlamda doğru cevap yeniden XP verir';
  update public.kelime_ustaliklari set sonraki_tekrar_tarihi = now() - interval '1 day'
   where ogrenci_id = ogr5 and anlam_id = s_hizli and beceri = 'taninma';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_cevap_gonder(q6, 1, false, 'anahtar-q6-tekrar-01');
  perform pg_temp.kelime_cikis();
  gecti := (v_json ->> 'kazanilan_xp')::integer = 30;
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'Geçersiz şık indeksi reddedilir (BAD_OPTION)';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle(
    $q$select public.kelime_cevap_gonder('00000000-0000-4000-8000-00000000f001', 9, false, 'anahtar-bad-opt-01')$q$,
    'BAD_OPTION');
  detay := 'indeks 9';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Kısa anahtar reddedilir (INVALID_ATTEMPT_KEY)';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle(
    $q$select public.kelime_cevap_gonder('00000000-0000-4000-8000-00000000f001', 0, false, 'kisa')$q$,
    'INVALID_ATTEMPT_KEY');
  detay := 'kısa anahtar';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Taslak soru cevaplanamaz (SORU_BULUNAMADI); başka sınıfın sorusu da cevaplanamaz';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle(
           $q$select public.kelime_cevap_gonder('00000000-0000-4000-8000-00000000f002', 0, false, 'anahtar-taslak-001')$q$,
           'SORU_BULUNAMADI')
       and pg_temp.kelime_hata_bekle(
           $q$select public.kelime_cevap_gonder('00000000-0000-4000-8000-00000000f003', 0, false, 'anahtar-6sinif-001')$q$,
           'SORU_BULUNAMADI');
  detay := 'taslak ve 6. sınıf';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Hız sınırı: dakikada 30 denemeden sonra RATE_LIMIT';
  -- ogr6 (6. sınıf) için 30 yakın tarihli deneme; q3 onun sınıfında yayında
  insert into public.kelime_denemeleri (ogrenci_id, soru_id, anlam_id, deneme_anahtari, secilen_indeks, dogru_mu, kazanilan_xp)
  select ogr6, q3, s_hizli, 'hiz-siniri-' || lpad(g::text, 4, '0'), 1, false, 0
    from generate_series(1, 30) g;
  perform pg_temp.kelime_giris(ogr6);
  gecti := pg_temp.kelime_hata_bekle(
    $q$select public.kelime_cevap_gonder('00000000-0000-4000-8000-00000000f003', 0, false, 'anahtar-hiz-sinir-1')$q$,
    'RATE_LIMIT');
  detay := 'son dakika 30 deneme';
  perform pg_temp.kelime_cikis();
  return next;

  -- ---------------------------------------------------------------
  -- D) Öğrenci özeti, kaydet ve RLS (yetki açıkken)
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Kelime kaydet / listele / kaldır çalışır; bilinmeyen anlam reddedilir';
  perform pg_temp.kelime_giris(ogr5);
  perform public.kelime_kaydet(s_uzgun, true);
  v_sayi := jsonb_array_length(public.kelime_kaydedilenler_listele());
  perform public.kelime_kaydet(s_uzgun, false);
  gecti := v_sayi = 1
       and jsonb_array_length(public.kelime_kaydedilenler_listele()) = 0
       and pg_temp.kelime_hata_bekle(
             $q$select public.kelime_kaydet('00000000-0000-4000-8000-0000000099ff', true)$q$, 'ANLAM_BULUNAMADI');
  detay := 'kayıtlı sayısı: ' || v_sayi;
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Öğrenci özeti alanları döner (tekrar bekleyen, tanıma tamam, çalışılan, kaydedilen, bugün)';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_ogrenci_ozeti();
  perform pg_temp.kelime_cikis();
  gecti := v_json ? 'tekrar_bekleyen' and v_json ? 'tanima_tamam'
       and v_json ? 'calisilan_kelime' and v_json ? 'kaydedilen' and v_json ? 'bugun_cozulen'
       and (v_json ->> 'calisilan_kelime')::integer >= 2;
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'RLS politikası (tablo yetkisi geçici açıkken): bağlı veli görür, yabancı veli görmez';
  -- Savunma derinliği: yetki bugün kapalı; politika yetki ileride açılırsa da veriyi korumalı
  insert into public.kelime_denemeleri (ogrenci_id, soru_id, anlam_id, deneme_anahtari, secilen_indeks, dogru_mu, kazanilan_xp)
    values (ogr5, q1, s_mutlu, 'rls-kontrol-0001', 0, false, 0);
  grant select on public.kelime_denemeleri to authenticated;
  perform pg_temp.kelime_giris(vel2);  -- vel2, ogr5'in velisi değil
  v_sayi := (select count(*) from public.kelime_denemeleri where ogrenci_id = ogr5);
  perform pg_temp.kelime_giris(vel1);  -- vel1, ogr5'in velisi
  v_bool := (select count(*) from public.kelime_denemeleri where ogrenci_id = ogr5) >= 1;
  perform pg_temp.kelime_cikis();
  revoke all on public.kelime_denemeleri from authenticated;
  gecti := v_sayi = 0 and v_bool;
  detay := 'yabancı veli: ' || v_sayi || ' satır';
  return next;

  -- ---------------------------------------------------------------
  -- E) Veli özeti (yetki + veri minimizasyonu)
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Bağlı veli çocuğunun toplu özetini görür; kişisel cevap listesi içermez';
  perform pg_temp.kelime_giris(vel1);
  v_json := public.kelime_veli_ozeti(ogr5);
  perform pg_temp.kelime_cikis();
  gecti := (v_json ->> 'deneme_sayisi')::integer > 0
       and jsonb_array_length(v_json -> 'zorlanilan') > 0
       and position('secilen' in v_json::text) = 0
       and position('soru_id' in v_json::text) = 0
       and position('secenek' in v_json::text) = 0
       and v_json ? 'oneriler';
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'Bağlı olmayan veli çocuk özetini göremez (FORBIDDEN)';
  perform pg_temp.kelime_giris(vel2);
  gecti := pg_temp.kelime_hata_bekle($q$select public.kelime_veli_ozeti('00000000-0000-4000-8000-00000000b005')$q$, 'FORBIDDEN');
  detay := 'yabancı veli';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Öğrenci kendi özetini veli fonksiyonu ile alamaz (FORBIDDEN)';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle($q$select public.kelime_veli_ozeti('00000000-0000-4000-8000-00000000b005')$q$, 'FORBIDDEN');
  detay := 'öğrenci kendi çocuk özetini';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Velinin çocuğu olmayan öğrencinin özetine erişim yok (ogr6)';
  perform pg_temp.kelime_giris(vel1);
  gecti := pg_temp.kelime_hata_bekle($q$select public.kelime_veli_ozeti('00000000-0000-4000-8000-00000000b006')$q$, 'FORBIDDEN');
  detay := 'velinin çocuğu olmayan öğrenci';
  perform pg_temp.kelime_cikis();
  return next;

  -- ---------------------------------------------------------------
  -- F) Yönetim: yetki, dört göz, onay akışı
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Öğrenci ve veli yönetim RPC''lerini çağıramaz (ADMIN_ONLY)';
  perform pg_temp.kelime_giris(ogr5);
  v_bool := pg_temp.kelime_hata_bekle($q$select public.kelime_metrikleri()$q$, 'ADMIN_ONLY');
  perform pg_temp.kelime_giris(vel1);
  v_bool := v_bool and pg_temp.kelime_hata_bekle($q$select public.kelime_yonetim_liste()$q$, 'ADMIN_ONLY');
  gecti := v_bool;
  detay := 'öğrenci ve veli';
  perform pg_temp.kelime_cikis();
  return next;

  no := no + 1;
  senaryo := 'Yönetici metrikleri alır: durum dağılımı ve 7 günlük toplu oranlar (öğrenci kırılımı yok)';
  perform pg_temp.kelime_giris(adm1);
  v_json := public.kelime_metrikleri();
  perform pg_temp.kelime_cikis();
  gecti := v_json ? 'durumlar' and v_json ? 'yayinda_dagilim' and v_json ? 'son_7_gun'
       and position('ogrenci_id' in v_json::text) = 0;
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'İlişki: kaydeden yönetici kendi ilişkisini onaylayamaz (DORT_GOZ); farklı yönetici onaylar; tekrar onay idempotent';
  perform pg_temp.kelime_giris(adm1);
  v_sicak := public.kelime_anlam_kaydet('sıcak', 'ısısı yüksek', 'sifat', null);
  v_soguk := public.kelime_anlam_kaydet('soğuk', 'ısısı düşük', 'sifat', null);
  v_id := public.kelime_iliski_kaydet(v_sicak, v_soguk, 'zit_anlamli');
  gecti := pg_temp.kelime_hata_bekle(format($q$select public.kelime_iliski_onayla(%L)$q$, v_id), 'DORT_GOZ');
  perform pg_temp.kelime_cikis();
  perform pg_temp.kelime_giris(adm2);
  perform public.kelime_iliski_onayla(v_id);
  perform public.kelime_iliski_onayla(v_id);  -- ikinci çağrı hata vermez
  perform pg_temp.kelime_cikis();
  gecti := gecti and pg_temp.kelime_sorgu_text(format('select onay_tarihi is not null from public.kelime_iliskileri where id = %L', v_id))::boolean;
  detay := 'iliski ' || v_id::text;
  return next;

  no := no + 1;
  senaryo := 'Aynı çift için ters yönde kayıt yeni satır açmaz (mevcut ilişki kimliği döner)';
  perform pg_temp.kelime_giris(adm2);
  gecti := public.kelime_iliski_kaydet(v_soguk, v_sicak, 'zit_anlamli') = v_id;
  perform pg_temp.kelime_cikis();
  detay := 'ters yön';
  return next;

  no := no + 1;
  senaryo := 'Soru taslağı: geçersiz şık kümeleri reddedilir (tek şık, tekrar eden şık, indeks aralık dışı)';
  perform pg_temp.kelime_giris(adm1);
  v_bool := pg_temp.kelime_hata_bekle(
      format($q$select public.kelime_soru_kaydet(null, %L, 'zit_anlamli', 5, null, 'Sıcak kelimesinin zıt anlamı?', '["Soğuk"]'::jsonb, 0, null, null, 'Isı konusuna bak.')$q$, v_sicak),
      'BAD_SECENEK_SAYISI');
  v_bool := v_bool and pg_temp.kelime_hata_bekle(
      format($q$select public.kelime_soru_kaydet(null, %L, 'zit_anlamli', 5, null, 'Sıcak kelimesinin zıt anlamı?', '["Soğuk","soğuk"]'::jsonb, 0, null, null, 'Isı konusuna bak.')$q$, v_sicak),
      'SECENEK_TEKRARI');
  v_bool := v_bool and pg_temp.kelime_hata_bekle(
      format($q$select public.kelime_soru_kaydet(null, %L, 'zit_anlamli', 5, null, 'Sıcak kelimesinin zıt anlamı?', '["Soğuk","Ilık"]'::jsonb, 5, null, null, 'Isı konusuna bak.')$q$, v_sicak),
      'BAD_DOGRU_INDEKS');
  perform pg_temp.kelime_cikis();
  gecti := v_bool;
  detay := 'şık doğrulamaları';
  return next;

  no := no + 1;
  senaryo := 'Onaylı olmayan ilişkiye bağlı doğru şık kaydedilemez (ILISKI_ONAYSIZ)';
  perform pg_temp.kelime_giris(adm1);
  gecti := pg_temp.kelime_hata_bekle(
      format($q$select public.kelime_soru_kaydet(null, %L, 'zit_anlamli', 5, null, 'Mutlu kelimesinin zıt anlamı?', '["Üzgün","Hızlı"]'::jsonb, 0, %L, null, 'Duygu zıtlığına bak.')$q$,
             s_mutlu, s_uzgun), 'ILISKI_ONAYSIZ');
  perform pg_temp.kelime_cikis();
  detay := 'r_zit onaysız (' || r_zit::text || ')';
  return next;

  no := no + 1;
  senaryo := 'Taslak → incelemede → yayında: yazan yönetici yayınlayamaz (DORT_GOZ), farklı yönetici yayınlar';
  perform pg_temp.kelime_giris(adm1);
  v_id := public.kelime_soru_kaydet(null, v_sicak, 'zit_anlamli', 5, 'T.5.2.1',
      'Sıcak kelimesinin zıt anlamlısı hangisidir?', '["Soğuk","Ilık"]'::jsonb, 0, null,
      'Isı konusuna bak.', 'Sıcak ile soğuk birbirinin karşıtıdır.');
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  v_bool := pg_temp.kelime_hata_bekle(format($q$select public.kelime_soru_durum_degistir(%L, 'yayinda')$q$, v_id), 'DORT_GOZ');
  perform pg_temp.kelime_cikis();
  perform pg_temp.kelime_giris(adm2);
  v_json := public.kelime_soru_durum_degistir(v_id, 'yayinda');
  perform pg_temp.kelime_cikis();
  gecti := v_bool and (v_json ->> 'durum') = 'yayinda'
       and pg_temp.kelime_sorgu_text(format('select inceleyen_id::text from public.kelime_sorulari where id = %L', v_id)) = adm2::text;
  detay := v_json::text;
  return next;

  no := no + 1;
  senaryo := 'Yayına alınan soru 5. sınıfa görünür; yayında soru düzenlenemez (DUZENLENEMEZ)';
  perform pg_temp.kelime_giris(ogr5);
  v_json := public.kelime_oyun_getir('zit_anlamli', 20);
  perform pg_temp.kelime_cikis();
  v_bool := exists (select 1 from jsonb_array_elements(v_json -> 'sorular') e where (e ->> 'id') = v_id::text);
  perform pg_temp.kelime_giris(adm1);
  gecti := v_bool and pg_temp.kelime_hata_bekle(
      format($q$select public.kelime_soru_kaydet(%L, %L, 'zit_anlamli', 5, null, 'Sıcak kelimesinin zıt anlamı nedir?', '["Soğuk","Ilık"]'::jsonb, 0, null, null, 'Isı konusuna bak.')$q$, v_id, v_sicak),
      'DUZENLENEMEZ');
  perform pg_temp.kelime_cikis();
  detay := 'öğrenci görünürlüğü: ' || v_bool;
  return next;

  no := no + 1;
  senaryo := 'Geçersiz durum geçişi reddedilir (taslak → yayında doğrudan)';
  perform pg_temp.kelime_giris(adm2);
  v_id := public.kelime_soru_kaydet(null, v_sicak, 'zit_anlamli', 6, null, 'Sıcak kelimesinin karşıtı nedir?',
      '["Soğuk","Ilık"]'::jsonb, 0, null, null, 'Isı konusuna bak.');
  gecti := pg_temp.kelime_hata_bekle(format($q$select public.kelime_soru_durum_degistir(%L, 'yayinda')$q$, v_id), 'GECERSIZ_GECIS');
  perform pg_temp.kelime_cikis();
  detay := 'taslak → yayında';
  return next;

  no := no + 1;
  senaryo := 'Yayındaki soru 6. sınıfa görünür; arşive alınınca görünmez ve cevaplanamaz';
  perform pg_temp.kelime_giris(adm2);
  perform public.kelime_soru_durum_degistir(v_id, 'incelemede');
  perform pg_temp.kelime_cikis();
  perform pg_temp.kelime_giris(adm1);
  perform public.kelime_soru_durum_degistir(v_id, 'yayinda');
  perform pg_temp.kelime_cikis();
  perform pg_temp.kelime_giris(ogr6);
  v_bool := exists (select 1 from jsonb_array_elements(public.kelime_oyun_getir('zit_anlamli', 20) -> 'sorular') e
                    where (e ->> 'id') = v_id::text);
  perform pg_temp.kelime_cikis();
  perform pg_temp.kelime_giris(adm2);
  perform public.kelime_soru_durum_degistir(v_id, 'arsiv');
  perform pg_temp.kelime_cikis();
  perform pg_temp.kelime_giris(ogr6);
  gecti := v_bool
       and not exists (select 1 from jsonb_array_elements(public.kelime_oyun_getir('zit_anlamli', 20) -> 'sorular') e
                       where (e ->> 'id') = v_id::text)
       and pg_temp.kelime_hata_bekle(format($q$select public.kelime_cevap_gonder(%L, 0, false, 'anahtar-arsiv-0001')$q$, v_id), 'SORU_BULUNAMADI');
  perform pg_temp.kelime_cikis();
  detay := 'yayında görünür: ' || v_bool;
  return next;

  no := no + 1;
  senaryo := 'Yönetim listesi toplam ve satır döner (yetkili yönetici)';
  perform pg_temp.kelime_giris(adm1);
  v_json := public.kelime_yonetim_liste(null, null, null, 200);
  perform pg_temp.kelime_cikis();
  gecti := (v_json ->> 'toplam')::integer >= 5 and jsonb_array_length(v_json -> 'satirlar') >= 5;
  detay := 'toplam ' || (v_json ->> 'toplam');
  return next;

  -- ---------------------------------------------------------------
  -- G) Savunma: yönetici bile tabloya doğrudan yazamaz; anon RPC yok
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Yönetici bile tabloya doğrudan yazamaz (yazma yalnızca RPC ile)';
  perform pg_temp.kelime_giris(adm1);
  gecti := pg_temp.kelime_hata_bekle(
    $q$insert into public.kelime_sorulari (anlam_id, iliski_turu, sinif, soru_metni, secenekler, dogru_indeks, aciklama, olusturan_id)
       values ('00000000-0000-4000-8000-00000000d001', 'es_anlamli', 5, 'Doğrudan yazma denemesi', '["a","b"]', 0, 'Doğrudan yazma', null)$q$,
    'permission denied');
  perform pg_temp.kelime_cikis();
  detay := 'doğrudan insert';
  return next;

  no := no + 1;
  senaryo := 'Anonim çağrıda kelime_metrikleri reddedilir (permission denied)';
  perform pg_temp.kelime_giris_anon();
  gecti := pg_temp.kelime_hata_bekle($q$select public.kelime_metrikleri()$q$, 'permission denied');
  perform pg_temp.kelime_cikis();
  detay := 'anon rpc';
  return next;

  no := no + 1;
  senaryo := 'Yönetici soru zorluğunu 1-3 dışında kaydedemez (BAD_ZORLUK)';
  perform pg_temp.kelime_giris(adm1);
  gecti := pg_temp.kelime_hata_bekle(
    format($q$select public.kelime_soru_kaydet(null, %L, 'zit_anlamli', 5, null, 'Sıcak kelimesinin zıt anlamı?', '["Soğuk","Ilık"]'::jsonb, 0, null, null, 'Isı konusuna bak.', 4)$q$, s_mutlu),
    'BAD_ZORLUK');
  perform pg_temp.kelime_cikis();
  detay := 'zorluk 4';
  return next;

  -- ---------------------------------------------------------------
  -- H) Arena: kelime meydan okuma (create_kelime_challenge / join / submit)
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Sınıfsız öğrenci kelime meydanı açamaz (SINIF_GEREKLI); veli açamaz (STUDENT_ONLY)';
  perform pg_temp.kelime_giris(ogr0);
  gecti := pg_temp.kelime_hata_bekle($q$select public.create_kelime_challenge(null)$q$, 'SINIF_GEREKLI');
  perform pg_temp.kelime_giris(vel1);
  gecti := gecti and pg_temp.kelime_hata_bekle($q$select public.create_kelime_challenge(null)$q$, 'STUDENT_ONLY');
  perform pg_temp.kelime_cikis();
  detay := 'sınıfsız öğrenci ve veli';
  return next;

  no := no + 1;
  senaryo := 'Geçersiz ilişki türü kelime meydanını reddeder (BAD_RELATION)';
  perform pg_temp.kelime_giris(ogr5);
  gecti := pg_temp.kelime_hata_bekle($q$select public.create_kelime_challenge('bilinmeyen')$q$, 'BAD_RELATION');
  perform pg_temp.kelime_cikis();
  detay := 'bilinmeyen tür';
  return next;

  no := no + 1;
  senaryo := 'Karışık kelime meydanı: 3-10 soru, şıklar A/B/C; doğru şık, açıklama ve ipucu anlık görüntüde YOK';
  perform pg_temp.kelime_giris(ogr5);
  v_m1 := public.create_kelime_challenge(null);
  perform pg_temp.kelime_cikis();
  gecti := (v_m1 ->> 'oyun_turu') = 'kelime'
       and jsonb_array_length(v_m1 -> 'sorular') between 3 and 10
       and (v_m1 -> 'sorular' -> 0 -> 'siklar') ? 'A'
       and position('dogru_indeks' in v_m1::text) = 0
       and position('aciklama' in v_m1::text) = 0
       and position('ipucu' in v_m1::text) = 0;
  detay := 'kod ' || (v_m1 ->> 'kod') || ', soru ' || jsonb_array_length(v_m1 -> 'sorular');
  return next;

  no := no + 1;
  senaryo := 'Eş anlamlı kelime meydanı yalnızca eş anlamlı sorulardan kurulur (konu = Anlam Köprüleri)';
  perform pg_temp.kelime_giris(ogr5);
  v_m2 := public.create_kelime_challenge('es_anlamli');
  perform pg_temp.kelime_cikis();
  gecti := (select bool_and(s ->> 'konu' = 'Anlam Köprüleri') from jsonb_array_elements(v_m2 -> 'sorular') s);
  detay := 'soru ' || jsonb_array_length(v_m2 -> 'sorular');
  return next;

  no := no + 1;
  senaryo := 'Meydan sahibi kendi meydanına katılamaz; katılmadan cevap gönderilemez';
  perform pg_temp.kelime_giris(ogr5);
  v_bool := pg_temp.kelime_hata_bekle(format($q$select public.join_challenge(%L)$q$, v_m1 ->> 'kod'), 'Kendi meydan okumanına');
  perform pg_temp.kelime_cikis();
  perform pg_temp.kelime_giris(ogr0);
  v_sayi := case when v_bool then 1 else 0 end;
  v_bool := pg_temp.kelime_hata_bekle(format($q$select public.submit_challenge(%L, '[]'::jsonb)$q$, v_m1 ->> 'id'), 'erişim yok');
  perform pg_temp.kelime_cikis();
  gecti := v_bool;
  detay := 'join=' || v_sayi::text || ' submit=' || v_bool::text;
  return next;

  no := no + 1;
  senaryo := 'Rakip katılınca meydan aktif olur; Arena XP üretmez (sayaç değişmez)';
  v_arena_xp_once := pg_temp.kelime_sorgu_text(format(
    'select count(*) from public.stub_xp_cagrilari where student_id in (%L, %L)', ogr5, ogr6))::integer;
  perform pg_temp.kelime_giris(ogr6);
  v_json := public.join_challenge(v_m1 ->> 'kod');
  perform pg_temp.kelime_cikis();
  gecti := (v_json ->> 'durum') = 'aktif'
       and pg_temp.kelime_sorgu_text(format(
             'select count(*) from public.stub_xp_cagrilari where student_id in (%L, %L)', ogr5, ogr6))::integer = v_arena_xp_once;
  detay := v_json ->> 'durum';
  return next;

  no := no + 1;
  senaryo := 'Puanlama: doğru x 4 - yanlış (en az 0); doğru şık sunucudan okunur; iki oyuncu bitirince meydan "bitti"';
  v_sor1 := v_m1 -> 'sorular' -> 0 ->> 'id';
  v_sor2 := v_m1 -> 'sorular' -> 1 ->> 'id';
  v_sor3 := v_m1 -> 'sorular' -> 2 ->> 'id';
  v_d1 := pg_temp.kelime_sorgu_text(format('select chr(65 + dogru_indeks) from public.kelime_sorulari where id = %L', v_sor1));
  v_d2 := pg_temp.kelime_sorgu_text(format('select chr(65 + dogru_indeks) from public.kelime_sorulari where id = %L', v_sor2));
  v_d3 := pg_temp.kelime_sorgu_text(format('select chr(65 + dogru_indeks) from public.kelime_sorulari where id = %L', v_sor3));
  perform pg_temp.kelime_giris(ogr5);
  v_cevap := public.submit_challenge((v_m1 ->> 'id')::uuid, jsonb_build_array(
    jsonb_build_object('question_id', v_sor1, 'secilen_sik', v_d1),
    jsonb_build_object('question_id', v_sor2, 'secilen_sik', case when v_d2 = 'A' then 'B' else 'A' end),
    jsonb_build_object('question_id', v_sor3, 'secilen_sik', v_d3)));
  perform pg_temp.kelime_cikis();
  perform pg_temp.kelime_giris(ogr6);
  v_cevap2 := public.submit_challenge((v_m1 ->> 'id')::uuid, jsonb_build_array(
    jsonb_build_object('question_id', v_sor1, 'secilen_sik', case when v_d1 = 'A' then 'B' else 'A' end),
    jsonb_build_object('question_id', v_sor2, 'secilen_sik', case when v_d2 = 'A' then 'B' else 'A' end)));
  perform pg_temp.kelime_cikis();
  gecti := (v_cevap ->> 'dogru_sayisi')::integer = 2
       and (v_cevap ->> 'yanlis_sayisi')::integer = 1
       and (v_cevap ->> 'puan')::numeric = 7
       and (v_cevap2 ->> 'puan')::numeric = 0
       and (v_cevap2 ->> 'yanlis_sayisi')::integer = 2
       and pg_temp.kelime_sorgu_text(format('select durum from public.meydan_okumalar where id = %L', v_m1 ->> 'id')) = 'bitti'
       and pg_temp.kelime_sorgu_text(format(
             'select count(*) from public.stub_xp_cagrilari where student_id in (%L, %L)', ogr5, ogr6))::integer = v_arena_xp_once;
  detay := v_cevap::text || ' | ' || v_cevap2::text;
  return next;

  no := no + 1;
  senaryo := 'Listede olmayan soru kimliği puan vermez (doğru şık sızdırılamaz)';
  perform pg_temp.kelime_giris(ogr6);
  perform public.join_challenge(v_m2 ->> 'kod');
  v_cevap := public.submit_challenge((v_m2 ->> 'id')::uuid, jsonb_build_array(
    jsonb_build_object('question_id', q3, 'secilen_sik', 'A')));
  perform pg_temp.kelime_cikis();
  gecti := (v_cevap ->> 'dogru_sayisi')::integer = 0 and (v_cevap ->> 'yanlis_sayisi')::integer = 0;
  detay := v_cevap::text;
  return next;
end;
$fn$;

-- Testi çalıştır. Sonuç tablosu:
-- select * from pg_temp.kelime_evreni_testleri();
