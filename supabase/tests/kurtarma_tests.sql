-- =====================================================================
-- KURTARMA (27.09.2026) TEST SENARYOLARI
-- Kapsam: 20260927000040 … 20260927000100 arasındaki kurtarma migration'ları
--   * 20260927000040  questions.inceleme_gerekli + questions.sinif kolonları
--   * 20260927000050  question_quality_config (tek satırlık eşik tablosu)
--   * 20260927000060  profiles sınıf koruması (app.grade_rpc bayrağı)
--   * 20260927000070  get_app_config()
--   * 20260927000080  my_sinif(), set_child_grade()
--   * 20260927000090  admin_set_setting / admin_get_settings / admin_list_reports
--                     admin_set_report_status / admin_get_question / admin_find_duplicates
--   * 20260927000100  admin_list_questions (8 parametre) / admin_import_questions
--   * 20260927000110  soru revizyon geçmişi (question_revisions, admin_question_history)
--   * 20260927000120  yardımcı fonksiyon yetkileri (set_updated_at, tr_normalize, hafta_baslangic)
--   * 20260927000130  kupon + kampanya (campaigns, coupons, coupon_redemptions, coupon_attempts, _kupon_*)
--   * 20260927000140  deneme sınavı (deneme_sinavlari / deneme_sinavi_sorulari / deneme_sinavi_denemeleri)
--   * 20260927000150  soru analitiği (_question_analytics_base, admin_question_analytics)
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: tüm test verisi iş bitince geri alınır.
-- Ön koşul: tüm migration'lar uygulanmış olmalı (supabase db reset).
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.kurtarma_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm uuid := gen_random_uuid();   -- admin
  v1  uuid := gen_random_uuid();   -- veli (o1 ve o2'nin velisi)
  v2  uuid := gen_random_uuid();   -- başka bir veli (yetkisiz deneme için)
  o1  uuid := gen_random_uuid();   -- öğrenci (v1'in çocuğu)
  o2  uuid := gen_random_uuid();   -- öğrenci (v1'in ikinci çocuğu)
  q   uuid[] := array[gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), gen_random_uuid()];
  d1  uuid := gen_random_uuid();   -- mükerrer soru 1
  d2  uuid := gen_random_uuid();   -- mükerrer soru 2
  v_r1 uuid;                       -- bildirim 1 (o1)
  v_r2 uuid;                       -- bildirim 2 (o2)
  v_r3 uuid;                       -- bildirim 3 (v1)
  v_json  jsonb;
  v_json2 jsonb;
  v_id2   uuid;                    -- revizyon testi: ikinci soru kimliği
  v_int   integer;
  v_int2  integer;
  v_int3  integer;
  v_ku    uuid;                    -- kupon (yüzde 25)
  v_ku2   uuid;                    -- kupon (süresi geçmiş)
  v_kamp  uuid;                    -- kampanya
  v_sinav uuid;                    -- deneme sınavı
  v_x1    uuid;                    -- geçmiş tarihli deneme sınavı
  v_text  text;
  v_text2 text;
  v_bool  boolean;
  v_liste integer[];
  i integer;
begin
  no := 0;

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (adm, 'kur.adm@example.test', '{"role":"veli","full_name":"Kurtarma Admin"}'),
      (v1,  'kur.v1@example.test',  '{"role":"veli","full_name":"Veli Bir"}'),
      (v2,  'kur.v2@example.test',  '{"role":"veli","full_name":"Veli Iki"}'),
      (o1,  'kur.o1@example.test',  '{"role":"ogrenci","full_name":"Cocuk Bir"}'),
      (o2,  'kur.o2@example.test',  '{"role":"ogrenci","full_name":"Cocuk Iki"}');

    -- Yükseltmeler ve bağ kurma doğrudan (SQL Editor / service_role) yapılır
    update public.profiles set role = 'admin' where id = adm;
    update public.profiles set parent_id = v1 where id in (o1, o2);
    update public.profiles set sinif = 4 where id = o1;

    -- 4 onaylı soru (sinif 5)
    for i in 1..4 loop
      insert into public.questions (id, okul, sinif, ders, konu, zorluk, soru_metni, siklar, dogru_sik,
                                    onay_durumu)
      values (q[i], 'ortaokul', 5, 'KurtarmaDers', 'Konu', 1, 'Kurtarma sorusu ' || i || '?',
              '{"A": "1", "B": "2"}'::jsonb, 'A', 'onaylandi');
    end loop;

    -- Aynı metnin (yalnızca fazladan boşluk farkıyla) iki kopyası → mükerrer testi
    insert into public.questions (id, okul, sinif, ders, konu, zorluk, soru_metni, siklar, dogru_sik,
                                  onay_durumu) values
      (d1, 'ortaokul', 6, 'KurtarmaDers', 'Mukerrer', 2, 'Aynı metin?',
       '{"A": "1", "B": "2"}'::jsonb, 'A', 'onaylandi'),
      (d2, 'ortaokul', 6, 'KurtarmaDers', 'Mukerrer', 2, 'Aynı  metin? ',
       '{"A": "1", "B": "2"}'::jsonb, 'A', 'onaylandi');

    -- ---------------------------------------------------------------
    -- A) Şema: eksik kolonlar ve eşik tablosu (000040 / 000050)
    -- ---------------------------------------------------------------

    -- 1
    no := no + 1;
    senaryo := 'questions.inceleme_gerekli: boolean, NOT NULL ve varsayılanı false';
    select data_type || '|' || is_nullable || '|' || coalesce(column_default, '-')
      into v_text
      from information_schema.columns
     where table_schema = 'public' and table_name = 'questions'
       and column_name = 'inceleme_gerekli';
    gecti := v_text = 'boolean|NO|false';
    detay := coalesce(v_text, 'kolon YOK');
    return next;

    -- 2
    no := no + 1;
    senaryo := 'questions.sinif: smallint (yerelde bilinçli NULLABLE — bkz. KURTARMA_DURUMU.md §3)';
    select data_type || '|' || is_nullable into v_text
      from information_schema.columns
     where table_schema = 'public' and table_name = 'questions' and column_name = 'sinif';
    gecti := v_text = 'smallint|YES';
    detay := coalesce(v_text, 'kolon YOK');
    return next;

    -- 3
    no := no + 1;
    senaryo := 'question_quality_config: tek satır, rapor_esigi=3, otomatik_gizle kapalı, RLS açık';
    select count(*)::integer into v_int from public.question_quality_config;
    select rapor_esigi, otomatik_gizle into v_int2, v_bool
      from public.question_quality_config limit 1;
    v_text2 := v_bool::text;
    select c.relrowsecurity into v_bool from pg_class c
     where c.oid = 'public.question_quality_config'::regclass;
    gecti := v_int = 1 and v_int2 = 3 and v_text2 = 'false' and v_bool;
    detay := 'satir=' || v_int || ' esik=' || v_int2 || ' otomatik=' || v_text2 || ' rls=' || v_bool;
    return next;

    -- 4
    no := no + 1;
    senaryo := 'question_quality_config: anon/authenticated tabloya erişemez (yalnızca SECURITY DEFINER okur)';
    gecti := has_table_privilege('anon', 'public.question_quality_config', 'select') = false
             and has_table_privilege('authenticated', 'public.question_quality_config', 'select') = false;
    detay := 'anon=' || has_table_privilege('anon', 'public.question_quality_config', 'select')::text
             || ' auth=' || has_table_privilege('authenticated', 'public.question_quality_config', 'select')::text;
    return next;

    -- 5
    no := no + 1;
    senaryo := 'question_quality_config: tek satır kuralı ihlal edilemez (id yalnızca true)';
    v_text := '';
    begin
      insert into public.question_quality_config (id, rapor_esigi) values (false, 9);
      v_text := 'eklendi';
    exception when others then v_text := sqlstate;
    end;
    gecti := v_text = '23514';
    detay := v_text;
    return next;

    -- ---------------------------------------------------------------
    -- B) get_app_config() (000070): bakım modu / min sürüm / reklamlar
    -- ---------------------------------------------------------------

    -- 6
    no := no + 1;
    senaryo := 'get_app_config(): anon çağırabilir, ayar satırı yokken güvenli varsayılanları döner';
    perform set_config('role', 'anon', true);
    v_json := public.get_app_config();
    perform set_config('role', 'none', true);
    gecti := has_function_privilege('anon', 'public.get_app_config()', 'execute')
             and v_json ? 'bakim_modu' and v_json ? 'min_surum' and v_json ? 'reklamlar'
             and (v_json -> 'bakim_modu' ->> 'aktif')::boolean = false
             and (v_json -> 'reklamlar' ->> 'veli_paneli_acik')::boolean = false
             and (v_json -> 'reklamlar' ->> 'ogrenci_acik')::boolean = false
             and (v_json -> 'min_surum' ->> 'android') = '1.0.0';
    detay := v_json::text;
    return next;

    -- 7
    no := no + 1;
    senaryo := 'Bakım modu zinciri: admin_set_setting → get_app_config aynı değeri döner (anon görür)';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.admin_set_setting('bakim_modu', '{"aktif": true, "mesaj": "Planlı bakım var"}');
    perform set_config('role', 'anon', true);
    v_json := public.get_app_config();
    perform set_config('role', 'none', true);
    gecti := (v_json -> 'bakim_modu' ->> 'aktif')::boolean
             and (v_json -> 'bakim_modu' ->> 'mesaj') = 'Planlı bakım var';
    detay := v_json -> 'bakim_modu';
    return next;

    -- ---------------------------------------------------------------
    -- C) admin_set_setting / admin_get_settings (000090)
    -- ---------------------------------------------------------------

    -- 8
    no := no + 1;
    senaryo := 'Ayar doğrulaması: uzun mesaj, bilinmeyen reklam alanı, geçersiz sınıf listesi ve hatalı sürüm reddedilir';
    v_text := '';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    begin
      perform public.admin_set_setting('bakim_modu', jsonb_build_object('aktif', true, 'mesaj', repeat('a', 301)));
      v_text := v_text || 'a';
    exception when others then null; end;
    begin
      perform public.admin_set_setting('reklamlar',
        '{"veli_paneli_acik": false, "ogrenci_acik": false, "bilinmeyen_alan": 1}');
      v_text := v_text || 'b';
    exception when others then null; end;
    begin
      perform public.admin_set_setting('desteklenen_siniflar', '{"siniflar": [0, 13]}');
      v_text := v_text || 'c';
    exception when others then null; end;
    begin
      perform public.admin_set_setting('min_surum', '{"android": "1.2", "ios": "1.0.0", "web": "1.0.0"}');
      v_text := v_text || 'd';
    exception when others then null; end;
    begin
      perform public.admin_set_setting('baska_bir_anahtar', '{}');
      v_text := v_text || 'e';
    exception when others then null; end;
    perform set_config('role', 'none', true);
    gecti := v_text = '';
    detay := 'reddedilmeyen: ' || v_text;
    return next;

    -- 9
    no := no + 1;
    senaryo := 'desteklenen_siniflar: yazılan liste _desteklenen_siniflar() tarafından okunur (tekilleştirilip sıralanır)';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.admin_set_setting('desteklenen_siniflar', '{"siniflar": [11, 3, 5, 4, 5]}');
    v_json := public.admin_get_settings();
    begin
      perform public.admin_set_setting('premium_gating', jsonb_build_object('aktif', 'evet'));
      v_text := 'kabul_edildi';
    exception when others then v_text := sqlstate; end;
    perform set_config('role', 'none', true);
    v_liste := public._desteklenen_siniflar();
    gecti := v_liste = array[3, 4, 5, 11] and v_text = '22023'
             and (v_json -> 'desteklenen_siniflar' -> 'siniflar') = '[3, 4, 5, 11]'::jsonb
             and v_json ? 'premium_gating' and v_json ? 'bakim_modu' and v_json ? 'min_surum'
             and v_json ? 'reklamlar';
    detay := v_liste::text || ' ' || (v_json -> 'desteklenen_siniflar')::text;
    return next;

    -- 10
    no := no + 1;
    senaryo := 'admin_get_settings: anon çağıramaz, admin olmayan girişli kullanıcı 42501 alır';
    perform set_config('request.jwt.claim.sub', '', true);
    perform set_config('role', 'anon', true);
    v_text := '';
    begin perform public.admin_get_settings(); v_text := 'anon'; exception when others then v_text := sqlstate; end;
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_text2 := '';
    begin perform public.admin_get_settings(); v_text2 := 'kabul'; exception when others then v_text2 := sqlstate; end;
    perform set_config('role', 'none', true);
    gecti := v_text <> 'anon' and v_text2 = '42501'
             and has_function_privilege('anon', 'public.admin_get_settings()', 'execute') = false;
    detay := v_text || ' / ' || v_text2;
    return next;

    -- ---------------------------------------------------------------
    -- D) Sınıf RPC'leri (000080)
    -- ---------------------------------------------------------------

    -- 11
    no := no + 1;
    senaryo := 'my_sinif(): oturumdaki kullanıcının sınıfını döner, oturum yoksa NULL';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_int := public.my_sinif();
    perform set_config('request.jwt.claim.sub', '', true);
    v_int2 := public.my_sinif();
    perform set_config('role', 'none', true);
    gecti := v_int = 4 and v_int2 is null
             and has_function_privilege('anon', 'public.my_sinif()', 'execute') = false;
    detay := coalesce(v_int::text, 'NULL') || ' / ' || coalesce(v_int2::text, 'NULL');
    return next;

    -- 12
    no := no + 1;
    senaryo := 'set_child_grade(): veli olmayan kullanıcı 42501 alır (anon erişimi de kapalı)';
    perform set_config('request.jwt.claim.sub', v2::text, true);
    perform set_config('role', 'authenticated', true);
    v_text := '';
    begin perform public.set_child_grade(o1, 5); v_text := 'kabul'; exception when others then v_text := sqlstate; end;
    perform set_config('role', 'none', true);
    gecti := v_text = '42501'
             and has_function_privilege('anon', 'public.set_child_grade(uuid, integer)', 'execute') = false;
    detay := v_text;
    return next;

    -- 13
    no := no + 1;
    senaryo := 'set_child_grade(): veli sınıfı değiştirir (geçmiş yazılır), 24 saat içinde ikinci deneme reddedilir';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    v_int := public.set_child_grade(o1, 5);
    v_text := '';
    begin perform public.set_child_grade(o1, 6); v_text := 'kabul'; exception when others then v_text := sqlstate; end;
    perform set_config('role', 'none', true);
    gecti := v_int = 5 and v_text = '22023'
             and (select p.sinif from public.profiles p where p.id = o1) = 5
             and (select count(*) from public.grade_changes g
                   where g.user_id = o1 and g.kaynak = 'veli' and g.yeni_sinif = 5) = 1;
    detay := 'yeni=' || coalesce(v_int::text, 'NULL') || ' ikinci=' || v_text;
    return next;

    -- ---------------------------------------------------------------
    -- E) profiles sınıf koruması (000060)
    -- ---------------------------------------------------------------

    -- 14
    no := no + 1;
    senaryo := 'profiles koruması: sınıf doğrudan UPDATE ile değiştirilemez, app.grade_rpc bayrağıyla değişir';
    v_text := '';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    begin
      update public.profiles set sinif = 8 where id = o1;
      v_text := v_text || 'ogrenci';
    exception when others then null; end;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    begin
      update public.profiles set sinif = 8 where id = o1;
      v_text := v_text || 'veli';
    exception when others then null; end;
    perform set_config('app.grade_rpc', 'on', true);
    update public.profiles set sinif = 8 where id = o1;
    perform set_config('app.grade_rpc', 'off', true);
    perform set_config('role', 'none', true);
    select p.sinif into v_int from public.profiles p where p.id = o1;
    gecti := v_text = '' and v_int = 8;
    detay := 'engellenmeyen: ' || coalesce(nullif(v_text, ''), '-') || ' sinif=' || coalesce(v_int::text, 'NULL');
    return next;

    -- ---------------------------------------------------------------
    -- F) Bildirim eşiği: report_question + question_quality_config (000030 + 000050)
    -- ---------------------------------------------------------------

    -- 15
    no := no + 1;
    senaryo := 'Bildirim eşiği (3): iki farklı kişi bildirince soru incelemeye düşmez';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_r1 := (public.report_question(q[1], 'yanlis_cevap', 'test 1') ->> 'id')::uuid;
    perform set_config('request.jwt.claim.sub', o2::text, true);
    v_r2 := (public.report_question(q[1], 'anlasilmiyor', 'test 2') ->> 'id')::uuid;
    perform set_config('role', 'none', true);
    select qq.inceleme_gerekli into v_bool from public.questions qq where qq.id = q[1];
    gecti := v_r1 is not null and v_r2 is not null and v_bool = false;
    detay := 'inceleme_gerekli=' || v_bool::text;
    return next;

    -- 16
    no := no + 1;
    senaryo := 'Bildirim eşiği (3): üçüncü farklı kişi bildirince inceleme_gerekli=true olur';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    v_r3 := (public.report_question(q[1], 'yazim', 'test 3') ->> 'id')::uuid;
    v_text := '';
    begin
      perform public.report_question(q[1], 'diger', 'aynı kişi ikinci kez');
      v_text := 'kabul';
    exception when others then v_text := sqlstate; end;
    perform set_config('role', 'none', true);
    select qq.inceleme_gerekli into v_bool from public.questions qq where qq.id = q[1];
    gecti := v_bool and v_r3 is not null and v_text = '23505';
    detay := 'inceleme_gerekli=' || v_bool::text || ' ikinci_bildirim=' || v_text;
    return next;

    -- ---------------------------------------------------------------
    -- G) Yönetici moderasyonu (000090)
    -- ---------------------------------------------------------------

    -- 17
    no := no + 1;
    senaryo := 'admin_list_reports(): açık bildirimler listelenir, en çok bildirilen soru önce gelir';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_list_reports('acik', null, 25, 0, 'cok');
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'toplam')::int = 3
             and (v_json -> 'satirlar' -> 0 ->> 'bildiren_sayisi')::int = 3
             and (v_json -> 'satirlar' -> 0 ->> 'soru_id')::uuid = q[1];
    detay := 'toplam=' || coalesce(v_json ->> 'toplam', 'NULL');
    return next;

    -- 18
    no := no + 1;
    senaryo := 'admin_get_question(): açık bildirim sayısı, sınıf ve inceleme bayrağı döner';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_get_question(q[1]);
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'acik_rapor')::int = 3 and (v_json ->> 'sinif')::int = 5
             and (v_json ->> 'inceleme_gerekli')::boolean;
    detay := v_json::text;
    return next;

    -- 19
    no := no + 1;
    senaryo := 'admin_set_report_status(): 3 bildirim "cozuldu" olur, bayrak temizlenir, geçersiz durum reddedilir';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_int := public.admin_set_report_status(array[v_r1, v_r2, v_r3], 'cozuldu', 'Kontrol edildi');
    v_text := '';
    begin
      perform public.admin_set_report_status(array[v_r1], 'kapandi');
      v_text := 'kabul';
    exception when others then v_text := sqlstate; end;
    perform set_config('role', 'none', true);
    select qq.inceleme_gerekli into v_bool from public.questions qq where qq.id = q[1];
    gecti := v_int = 3 and v_text = '22023' and v_bool = false
             and (select count(*) from public.question_reports r
                   where r.id = any (array[v_r1, v_r2, v_r3])
                     and r.durum = 'cozuldu' and r.cozen_id = adm
                     and r.admin_notu = 'Kontrol edildi') = 3;
    detay := 'guncellenen=' || coalesce(v_int::text, 'NULL') || ' gecersiz=' || v_text
             || ' inceleme=' || v_bool::text;
    return next;

    -- ---------------------------------------------------------------
    -- H) Yönetici soru listesi + mükerrer + içe aktarma (000100)
    -- ---------------------------------------------------------------

    -- 20
    no := no + 1;
    senaryo := 'admin_list_questions(): 8 parametreli canlı imza; sınıf ve inceleme süzgeçleri çalışır';
    select pronargs::text into v_text from pg_proc
     where oid = 'public.admin_list_questions(text,text,integer,text,integer,integer,boolean,integer)'::regprocedure;
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_json  := public.admin_list_questions(null, null, null, null, 25, 0, true, null);
    v_json2 := public.admin_list_questions(null, null, null, null, 25, 0, null, 5);
    v_text2 := '';
    begin
      perform public.admin_list_questions(null, null, null, null, 25, 0, null, 99);
      v_text2 := 'kabul';
    exception when others then v_text2 := sqlstate; end;
    perform set_config('request.jwt.claim.sub', o1::text, true);
    begin
      perform public.admin_list_questions(null, null, null, null, 25, 0, null, null);
      v_text2 := v_text2 || 'ogrenci';
    exception when others then v_text2 := v_text2 || sqlstate; end;
    perform set_config('role', 'none', true);
    gecti := v_text = '8' and v_text2 = ('22023' || '42501')
             and (v_json ->> 'toplam')::int = 0   -- bildirimler kapandığı için inceleme listesi boş
             and (v_json2 ->> 'toplam')::int >= 4
             and not exists (select 1 from jsonb_array_elements(v_json2 -> 'satirlar') s
                              where (s ->> 'sinif') <> '5')
             and has_function_privilege('anon',
                   'public.admin_list_questions(text,text,integer,text,integer,integer,boolean,integer)',
                   'execute') = false;
    detay := 'parametre=' || v_text || ' inceleme=' || coalesce(v_json ->> 'toplam', 'NULL')
             || ' sinif5=' || coalesce(v_json2 ->> 'toplam', 'NULL') || ' ' || v_text2;
    return next;

    -- 21
    no := no + 1;
    senaryo := 'admin_find_duplicates(): boşluk farkı olan aynı metinleri tek grupta bulur';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_find_duplicates(50);
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'toplam_grup')::int >= 1
             and exists (select 1 from jsonb_array_elements(v_json -> 'gruplar') g
                          where (select count(*) from jsonb_array_elements(g -> 'sorular') s
                                  where (s ->> 'id')::uuid in (d1, d2)) = 2);
    detay := 'toplam_grup=' || coalesce(v_json ->> 'toplam_grup', 'NULL');
    return next;

    -- 22
    no := no + 1;
    senaryo := 'admin_import_questions(): satırdaki sinif yazılır, aynı soru ikinci kez eklenmez';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_import_questions(jsonb_build_array(jsonb_build_object(
      'okul', 'ortaokul', 'sinif', 7, 'ders', 'KurtarmaDers', 'konu', 'İçe aktarma', 'zorluk', 2,
      'soru_metni', 'İçe aktarma sorusu 1?',
      'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'a')), true, false);
    v_json2 := public.admin_import_questions(jsonb_build_array(jsonb_build_object(
      'okul', 'ortaokul', 'sinif', 7, 'ders', 'KurtarmaDers', 'konu', 'İçe aktarma', 'zorluk', 2,
      'soru_metni', 'İçe aktarma sorusu 1?',
      'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'a')), true, false);
    perform set_config('role', 'none', true);
    select qq.sinif, qq.onay_durumu into v_int, v_text
      from public.questions qq where qq.soru_metni = 'İçe aktarma sorusu 1?';
    gecti := (v_json ->> 'eklenen')::int = 1 and (v_json2 ->> 'eklenen')::int = 0
             and (v_json2 ->> 'tekrar')::int = 1
             and (v_json ->> 'hatali')::int = 0 and v_int = 7 and v_text = 'onaylandi';
    detay := 'eklenen=' || coalesce(v_json ->> 'eklenen', 'NULL')
             || ' tekrar=' || coalesce(v_json2 ->> 'tekrar', 'NULL')
             || ' sinif=' || coalesce(v_int::text, 'NULL');
    return next;

    -- ---------------------------------------------------------------
    -- E) Soru revizyon geçmişi (20260927000110)
    -- ---------------------------------------------------------------

    -- 23
    no := no + 1;
    senaryo := 'admin_upsert_question(): yeni soru sinif alanıyla birlikte eklenir';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_id2 := public.admin_upsert_question(null, jsonb_build_object(
      'okul', 'ortaokul', 'sinif', 7, 'ders', 'KurtarmaDers', 'konu', 'Revizyon', 'zorluk', 1,
      'soru_metni', 'Revizyon sorusu?',
      'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'a'));
    perform set_config('role', 'none', true);
    select qq.sinif into v_int from public.questions qq where qq.id = v_id2;
    gecti := v_int = 7;
    detay := 'yeni_sinif=' || coalesce(v_int::text, 'NULL');
    return next;

    -- 24
    no := no + 1;
    senaryo := 'Soru güncellenince eski hâl question_revisions''a yazılır; admin_question_history() döner';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.admin_upsert_question(v_id2, jsonb_build_object(
      'okul', 'ortaokul', 'sinif', 7, 'ders', 'KurtarmaDers', 'konu', 'Revizyon', 'zorluk', 1,
      'soru_metni', 'Revizyon sorusu (güncel)?',
      'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'a'));
    v_json := public.admin_question_history(v_id2);
    perform set_config('role', 'none', true);
    select count(*)::integer into v_int2
      from public.question_revisions where question_id = v_id2;
    gecti := v_int2 = 1
             and jsonb_array_length(v_json) = 1
             and (v_json -> 0 -> 'degisen_alanlar') ? 'soru_metni'
             and (v_json -> 0 -> 'old_data' ->> 'soru_metni') = 'Revizyon sorusu?';
    detay := 'kayit=' || coalesce(v_int2::text, 'NULL')
             || ' gecmis=' || coalesce(jsonb_array_length(v_json)::text, 'NULL')
             || ' alanlar=' || coalesce(v_json -> 0 ->> 'degisen_alanlar', 'NULL');
    return next;

    -- 25
    no := no + 1;
    senaryo := 'Revizyon geçmişi ve tekil soru kaydı yalnızca adminin (veli 42501 alır)';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    v_text := '';
    begin
      perform public.admin_question_history(v_id2);
      v_text := 'erişim verildi';
    exception when insufficient_privilege then v_text := sqlstate;
    end;
    v_bool := (v_text = '42501');
    v_text2 := '';
    begin
      perform public.admin_upsert_question(null, jsonb_build_object(
        'okul', 'ortaokul', 'sinif', 7, 'ders', 'KurtarmaDers', 'konu', 'Revizyon', 'zorluk', 1,
        'soru_metni', 'Veli denemesi?',
        'siklar', jsonb_build_object('A', '1', 'B', '2'), 'dogru_sik', 'a'));
      v_text2 := 'erişim verildi';
    exception when insufficient_privilege then v_text2 := sqlstate;
    end;
    perform set_config('role', 'none', true);
    gecti := v_bool and (v_text2 = '42501');
    detay := 'gecmis=' || v_bool::text || ' kayit=' || v_text2;
    return next;

    -- 26
    no := no + 1;
    senaryo := 'question_revisions: RLS açık, istemci yazamaz, anon okuyamaz';
    gecti := has_table_privilege('anon', 'public.question_revisions', 'select') = false
             and has_table_privilege('authenticated', 'public.question_revisions', 'insert') = false
             and (select c.relrowsecurity from pg_class c
                   where c.oid = 'public.question_revisions'::regclass);
    detay := 'anon_select=' || has_table_privilege('anon', 'public.question_revisions', 'select')::text
             || ' auth_insert=' || has_table_privilege('authenticated', 'public.question_revisions', 'insert')::text;
    return next;

    -- ---------------------------------------------------------------
    -- F) Kupon + kampanya (20260927000130)
    -- ---------------------------------------------------------------

    -- 27
    no := no + 1;
    senaryo := '_kupon_kod_temizle(): boşluk atılır, Türkçe harf ASCII''ye iner, kod büyük harfe çevrilir';
    v_text := public._kupon_kod_temizle('  indirim-ğ  ');
    v_text2 := public._kupon_kod_temizle(null);
    gecti := v_text = 'INDIRIM-G' and v_text2 is null;
    detay := 'temiz=' || coalesce(v_text, 'NULL') || ' bos=' || coalesce(v_text2, 'null');
    return next;

    -- 28
    no := no + 1;
    senaryo := 'admin_upsert_coupon(): kupon açılır, kodu normalize edilir ve listede görünür';
    insert into public.plans (kod, ad, fiyat_kurus, sure_gun)
    values ('kur_plan', 'Kurtarma Planı', 10000, 30)
    on conflict (kod) do nothing;

    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_ku := public.admin_upsert_coupon(null, 'kur-test', 'yuzde', 25, null, 0, 10, 1, null, null,
                                       true, false, false, null);
    v_json := public.admin_list_coupons(null, 'KUR-TEST', 25, 0, null);
    perform set_config('role', 'none', true);
    gecti := v_ku is not null and (v_json ->> 'toplam')::int = 1
             and (v_json -> 'satirlar' -> 0 ->> 'kod') = 'KUR-TEST'
             and (v_json -> 'satirlar' -> 0 ->> 'tur') = 'yuzde';
    detay := 'toplam=' || coalesce(v_json ->> 'toplam', 'NULL')
             || ' kod=' || coalesce(v_json -> 'satirlar' -> 0 ->> 'kod', 'NULL');
    return next;

    -- 29
    no := no + 1;
    senaryo := 'coupon_preview(): %25 indirim plan fiyatından hesaplanır (10.000 → 2.500 indirim / 7.500 ödeme)';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.coupon_preview('kur_plan', 'kur-test');
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'gecerli')::boolean
             and (v_json ->> 'plan_fiyat_kurus')::int = 10000
             and (v_json ->> 'indirim_kurus')::int = 2500
             and (v_json ->> 'odenecek_kurus')::int = 7500
             and (v_json ->> 'ucretsiz')::boolean = false;
    detay := 'gecerli=' || coalesce(v_json ->> 'gecerli', 'NULL')
             || ' indirim=' || coalesce(v_json ->> 'indirim_kurus', 'NULL')
             || ' odenecek=' || coalesce(v_json ->> 'odenecek_kurus', 'NULL');
    return next;

    -- 30
    no := no + 1;
    senaryo := 'coupon_preview(): yalnızca veli (öğrenci 42501) ve bilinmeyen plan deneme sayacını artırmaz';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    v_text := '';
    begin
      perform public.coupon_preview('kur_plan', 'kur-test');
      v_text := 'erişim verildi';
    exception when insufficient_privilege then v_text := sqlstate;
    end;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform public.coupon_preview('olmayan_plan', 'kur-test');
    perform set_config('role', 'none', true);
    v_int := public._kupon_deneme_sayisi(v1);
    gecti := (v_text = '42501') and v_int = 0;
    detay := 'ogrenci=' || v_text || ' deneme_sayaci=' || v_int;
    return next;

    -- 31
    no := no + 1;
    senaryo := 'coupon_preview(): süresi geçmiş kupon reddedilir (neden=suresi_gecti)';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_ku2 := public.admin_upsert_coupon(null, 'KUR-ESKI', 'tutar', 500, null, 0, null, 1,
                                        now() - interval '10 days', now() - interval '1 day',
                                        true, false, false, null);
    perform set_config('request.jwt.claim.sub', v1::text, true);
    v_json := public.coupon_preview('kur_plan', 'kur-eski');
    perform set_config('role', 'none', true);
    gecti := (v_json ->> 'gecerli')::boolean = false and (v_json ->> 'neden') = 'suresi_gecti'
             and (v_json ->> 'mesaj') is not null;
    detay := 'neden=' || coalesce(v_json ->> 'neden', 'NULL');
    return next;

    -- 32
    no := no + 1;
    senaryo := 'Kupon deneme freni: 10 başarısız denemeden sonra neden=cok_deneme';
    insert into public.coupon_attempts (veli_id) select v1 from generate_series(1, 10);
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.coupon_preview('kur_plan', 'YOKKOD');
    perform set_config('role', 'none', true);
    delete from public.coupon_attempts where veli_id = v1;
    gecti := (v_json ->> 'neden') = 'cok_deneme' and (v_json ->> 'mesaj') is not null;
    detay := 'neden=' || coalesce(v_json ->> 'neden', 'NULL')
             || ' mesaj=' || coalesce(v_json ->> 'mesaj', 'NULL');
    return next;

    -- 33
    no := no + 1;
    senaryo := 'Kupon/kampanya tabloları: RLS açık, istemciye hiç yetki yok (fail-closed)';
    gecti := has_table_privilege('authenticated', 'public.coupons', 'select') = false
             and has_table_privilege('authenticated', 'public.coupon_redemptions', 'insert') = false
             and has_table_privilege('anon', 'public.campaigns', 'select') = false
             and has_table_privilege('authenticated', 'public.coupon_attempts', 'select') = false
             and (select bool_and(c.relrowsecurity) from pg_class c
                   where c.oid in ('public.coupons'::regclass, 'public.campaigns'::regclass,
                                   'public.coupon_redemptions'::regclass, 'public.coupon_attempts'::regclass));
    detay := 'iç kullanım tabloları; istemci yetkisi yok';
    return next;

    -- 34
    no := no + 1;
    senaryo := 'admin_upsert_campaign()/admin_list_campaigns(): kampanya açılır, kupon sayısı görünür';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_kamp := public.admin_upsert_campaign(null, 'Kurtarma Kampanyası', 'Test', null, null, true);
    perform set_config('role', 'none', true);
    update public.coupons set campaign_id = v_kamp where id = v_ku;
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_list_campaigns();
    perform set_config('role', 'none', true);
    select count(*)::integer into v_int
      from jsonb_array_elements(v_json) e
     where e ->> 'ad' = 'Kurtarma Kampanyası' and (e ->> 'kupon_sayisi')::int = 1;
    gecti := v_kamp is not null and v_int = 1;
    detay := 'kampanya=' || coalesce(v_kamp::text, 'NULL') || ' eslesme=' || v_int;
    return next;

    -- 35
    no := no + 1;
    senaryo := 'admin_upsert_coupon(): geçersiz kupon (yüzde 150 / 2 harflik kod) 22023 ile reddedilir';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_text := '';
    begin
      perform public.admin_upsert_coupon(null, 'KUR-BOZUK', 'yuzde', 150, null, 0, null, 1,
                                         null, null, true, false, false, null);
      v_text := 'kabul edildi';
    exception when invalid_parameter_value then v_text := sqlstate;
    end;
    v_text2 := '';
    begin
      perform public.admin_upsert_coupon(null, 'ab', 'tutar', 500, null, 0, null, 1,
                                         null, null, true, false, false, null);
      v_text2 := 'kabul edildi';
    exception when invalid_parameter_value then v_text2 := sqlstate;
    end;
    perform set_config('role', 'none', true);
    gecti := v_text = '22023' and v_text2 = '22023';
    detay := 'yuzde150=' || v_text || ' kisa_kod=' || v_text2;
    return next;

    -- ---------------------------------------------------------------
    -- G) Deneme sınavı (20260927000140)
    -- ---------------------------------------------------------------

    -- 36
    no := no + 1;
    senaryo := 'admin_upsert_mock_exam(): sınav açılır (sınıf 5+6, 40 dk) ve listede görünür';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_sinav := public.admin_upsert_mock_exam(null, 'Kurtarma Denemesi', now() + interval '1 day', 40,
                                             array[5, 6]::smallint[], true);
    v_json := public.admin_list_mock_exams();
    perform set_config('role', 'none', true);
    select count(*)::integer into v_int
      from jsonb_array_elements(v_json) e
     where e ->> 'ad' = 'Kurtarma Denemesi' and (e ->> 'sure_dakika')::int = 40;
    gecti := v_sinav is not null and v_int = 1;
    detay := 'sinav=' || coalesce(v_sinav::text, 'NULL') || ' listede=' || v_int;
    return next;

    -- 37
    no := no + 1;
    senaryo := 'admin_upsert_mock_exam(): 3 dakika süre ve desteklenmeyen sınıf (9) 22023 ile reddedilir';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_text := '';
    begin
      perform public.admin_upsert_mock_exam(null, 'Kurtarma Kısa', now() + interval '1 day', 3,
                                            array[5]::smallint[], true);
      v_text := 'kabul edildi';
    exception when invalid_parameter_value then v_text := sqlstate;
    end;
    v_text2 := '';
    begin
      perform public.admin_upsert_mock_exam(null, 'Kurtarma Sınıf9', now() + interval '1 day', 40,
                                            array[9]::smallint[], true);
      v_text2 := 'kabul edildi';
    exception when invalid_parameter_value then v_text2 := sqlstate;
    end;
    perform set_config('role', 'none', true);
    gecti := v_text = '22023' and v_text2 = '22023';
    detay := 'sure3=' || v_text || ' sinif9=' || v_text2;
    return next;

    -- 38
    no := no + 1;
    senaryo := 'admin_set_mock_exam_questions(): sorular sıra numarasıyla atanır, atanmamış sınıf 22023 alır';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.admin_set_mock_exam_questions(v_sinav, 5, array[q[1], q[2]]);
    v_json := public.admin_get_mock_exam_questions(v_sinav, 5);
    v_text := '';
    begin
      perform public.admin_set_mock_exam_questions(v_sinav, 7, array[q[3]]);
      v_text := 'kabul edildi';
    exception when invalid_parameter_value then v_text := sqlstate;
    end;
    perform set_config('role', 'none', true);
    gecti := jsonb_array_length(v_json) = 2
             and (v_json -> 0 ->> 'sira')::int = 1
             and (v_json -> 1 ->> 'sira')::int = 2
             and (v_json -> 0 ->> 'soru_metni') = 'Kurtarma sorusu 1?'
             and v_text = '22023';
    detay := 'soru=' || coalesce(jsonb_array_length(v_json)::text, 'NULL')
             || ' atanmamis_sinif=' || v_text;
    return next;

    -- 39
    no := no + 1;
    senaryo := 'Başlamış sınavın soruları değiştirilemez; kilitli sınav da 42501 verir';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_x1 := public.admin_upsert_mock_exam(null, 'Kurtarma Geçmiş', now() - interval '2 days', 40,
                                          array[5]::smallint[], true);
    v_text := '';
    begin
      perform public.admin_set_mock_exam_questions(v_x1, 5, array[q[3]]);
      v_text := 'kabul edildi';
    exception when insufficient_privilege then v_text := sqlstate;
    end;
    perform set_config('role', 'none', true);
    update public.deneme_sinavlari set sorular_kilitli = true where id = v_sinav;
    perform set_config('role', 'authenticated', true);
    v_text2 := '';
    begin
      perform public.admin_set_mock_exam_questions(v_sinav, 5, array[q[3]]);
      v_text2 := 'kabul edildi';
    exception when insufficient_privilege then v_text2 := sqlstate;
    end;
    perform set_config('role', 'none', true);
    update public.deneme_sinavlari set sorular_kilitli = false where id = v_sinav;
    gecti := v_text = '42501' and v_text2 = '42501';
    detay := 'gecmis=' || v_text || ' kilitli=' || v_text2;
    return next;

    -- 40
    no := no + 1;
    senaryo := 'admin_get_mock_exam_results(): bitmiş denemeler sınıf içi sıralanır, bitmemiş hariç tutulur';
    insert into public.deneme_sinavi_denemeleri
      (exam_id, student_id, sinif, puan, dogru_sayisi, yanlis_sayisi, bos_sayisi, bitis_zamani)
    values (v_sinav, o1, 5, 80, 4, 1, 0, now() - interval '2 hours'),
           (v_sinav, o2, 5, 90, 5, 0, 0, now() - interval '1 hour'),
           (v_sinav, v1, 5, 10, 1, 0, 0, null);
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    select count(*)::integer,
           (array_agg(sira order by sira))[1]::integer,
           (array_agg(puan order by sira))[1]::integer,
           (array_agg(ad_soyad order by sira))[1]
      into v_int, v_int2, v_int3, v_text
      from public.admin_get_mock_exam_results(v_sinav);
    perform set_config('role', 'none', true);
    gecti := v_int = 2 and v_int2 = 1 and v_int3 = 90 and v_text = 'Cocuk Iki';
    detay := 'satir=' || v_int || ' ilk_sira=' || v_int2 || ' ilk_puan=' || v_int3
             || ' ad=' || coalesce(v_text, 'NULL');
    return next;

    -- 41
    no := no + 1;
    senaryo := 'Deneme sınavı: RLS açık, istemciye tablo yetkisi yok, yardımcı fonksiyon authenticated''a kapalı';
    gecti := has_table_privilege('authenticated', 'public.deneme_sinavlari', 'select') = false
             and has_table_privilege('anon', 'public.deneme_sinavi_sorulari', 'select') = false
             and has_table_privilege('authenticated', 'public.deneme_sinavi_denemeleri', 'select') = false
             and has_function_privilege('authenticated',
                   'public._deneme_sinavi_siniflar_gecerli(smallint[])', 'execute') = false
             and (select bool_and(c.relrowsecurity) from pg_class c
                   where c.oid in ('public.deneme_sinavlari'::regclass,
                                   'public.deneme_sinavi_sorulari'::regclass,
                                   'public.deneme_sinavi_denemeleri'::regclass));
    detay := 'üç tablo RLS + yetki kapalı (fail-closed)';
    return next;

    -- ---------------------------------------------------------------
    -- H) Soru analitiği (20260927000150)
    -- ---------------------------------------------------------------

    -- 42
    no := no + 1;
    senaryo := '_question_analytics_base(): limit_ms istemciyle aynı, istatistik ve dağılım tutuyor';
    insert into public.user_answers (student_id, question_id, secilen_sik, dogru_mu, son_sure_ms,
                                     deneme_sayisi, dogru_sayisi)
    values (o1, q[1], 'A', true, 40000, 10, 9),
           (o2, q[1], 'B', false, 50000, 10, 1);
    select count(*)::integer into v_int
      from public._question_analytics_base(1) b
     where b.id = q[1]
       and b.ogrenci = 2 and b.deneme = 20 and b.dogru = 10
       and b.dogru_oran = 0.5000 and b.limit_ms = 45000
       and cardinality(b.bayraklar) = 0
       and (b.dagilim ->> 'A')::int = 1 and (b.dagilim ->> 'B')::int = 1;
    gecti := v_int = 1;
    detay := 'kolay soru: 2 öğrenci / 20 deneme / 0,50 oran / limit 45000 / bayrak yok';
    return next;

    -- 43
    no := no + 1;
    senaryo := '_question_analytics_base(): düşük doğru oranı + süre aşımı bayraklanır (zor/yavas)';
    insert into public.user_answers (student_id, question_id, secilen_sik, dogru_mu, son_sure_ms,
                                     deneme_sayisi, dogru_sayisi)
    values (o1, q[2], 'B', false, 90000, 10, 0);
    select count(*)::integer into v_int
      from public._question_analytics_base(1) b
     where b.id = q[2] and b.bayraklar @> array['zor', 'yavas']::text[];
    gecti := v_int = 1;
    detay := 'kolay soru (limit 45 sn) 90 sn ortalama + %0 doğru → zor+yavas';
    return next;

    -- 44
    no := no + 1;
    senaryo := 'admin_question_analytics(): şüpheli süzgeci çalışır, geçersiz sıralama 22023 alır';
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_question_analytics(null, 1, 25, 0, 'supheli', true);
    v_int2 := jsonb_array_length(v_json -> 'satirlar');
    v_text := '';
    begin
      perform public.admin_question_analytics(null, 1, 25, 0, 'yanlis_siralama', false);
      v_text := 'kabul edildi';
    exception when invalid_parameter_value then v_text := sqlstate;
    end;
    v_json2 := public.admin_question_analytics(null, 1, 25, 0, 'deneme_azalan', false);
    perform set_config('role', 'none', true);
    gecti := v_int2 >= 1
             and (v_json -> 'ozet' ->> 'supheli_soru')::int >= 1
             and (v_json -> 'ozet' ->> 'min_cevap')::int = 1
             and (v_json2 ->> 'toplam')::int >= 2
             and v_text = '22023';
    detay := 'supheli_satir=' || v_int2 || ' toplam=' || coalesce(v_json2 ->> 'toplam', 'NULL')
             || ' siralama=' || v_text;
    return next;

    -- 45
    no := no + 1;
    senaryo := 'Analitik: taban fonksiyonu istemciye kapalı, RPC anon''a kapalı ve authenticated''a açık';
    gecti := has_function_privilege('authenticated', 'public._question_analytics_base(integer)', 'execute') = false
             and has_function_privilege('anon',
                   'public.admin_question_analytics(text, integer, integer, integer, text, boolean)',
                   'execute') = false
             and has_function_privilege('authenticated',
                   'public.admin_question_analytics(text, integer, integer, integer, text, boolean)',
                   'execute');
    detay := 'base=kapalı anon=kapalı auth=açık';
    return next;

    -- ---------------------------------------------------------------
    -- I) Çarpım Şifreleri Seed ve Detay Doğrulaması (20260927000015)
    -- ---------------------------------------------------------------

    -- 46
    no := no + 1;
    senaryo := 'carpim_sifreleri seed: en az 10 şifre tanımlı, sıra ve anahtar benzersiz';
    select count(*)::integer into v_int from public.carpim_sifreleri;
    gecti := v_int >= 10
             and (select count(distinct sira) from public.carpim_sifreleri) = v_int
             and (select count(distinct anahtar) from public.carpim_sifreleri) = v_int;
    detay := 'toplam_sifre=' || coalesce(v_int::text, 'NULL');
    return next;

    -- 47
    no := no + 1;
    senaryo := 'get_carpim_sifre_detay(): kapali test sorularının cevap alanı istemciye gitmez';
    perform set_config('request.jwt.claim.sub', o1::text, true);
    perform set_config('role', 'authenticated', true);
    select id into v_x1 from public.carpim_sifreleri where anahtar = '2ler';
    v_json := public.get_carpim_sifre_detay(v_x1);
    perform set_config('role', 'none', true);
    gecti := v_json is not null
             and jsonb_array_length(v_json -> 'test') >= 2
             and (v_json -> 'test' -> 0 ? 'soru')
             and not (v_json -> 'test' -> 0 ? 'cevap')
             and not (v_json -> 'test' -> 0 ? 'cozum');
    detay := 'test_soru_sayisi=' || coalesce(jsonb_array_length(v_json -> 'test')::text, '0')
             || ' cevap_gizli=' || (not (v_json -> 'test' -> 0 ? 'cevap'))::text;
    return next;

    -- Tüm test verisi geri alınır (kayıt bırakılmaz)
    raise exception 'TEST_GERI_AL' using errcode = 'P0001';
  exception when others then
    if sqlerrm <> 'TEST_GERI_AL' then
      -- Beklenmeyen hata: senaryo numarası ve mesajı ile birlikte raporlanır
      no := no + 1;
      senaryo := 'BEKLENMEYEN HATA (test verisi geri alındı)';
      gecti := false;
      detay := sqlstate || ': ' || sqlerrm;
      return next;
    end if;
  end;

  return;
end;
$fn$;

select * from pg_temp.kurtarma_testleri();
