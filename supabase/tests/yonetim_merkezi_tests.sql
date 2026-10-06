-- =====================================================================
-- YÖNETİM MERKEZİ (CRM tercihleri, segment, kampanya, anket, otomasyon,
-- analitik, mutabakat) TEST SENARYOLARI
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: test verileri iş bitince geri alınır.
-- Ön koşul: 20261007000010, 20261007000020, 20261007000030 migration'ları uygulanmış olmalı.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.yonetim_merkezi_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm uuid := gen_random_uuid();   -- admin
  v1  uuid := gen_random_uuid();   -- veli, 2 çocuklu, e-posta izinli
  v2  uuid := gen_random_uuid();   -- veli, 1 çocuklu, izin yok
  c1  uuid := gen_random_uuid();   -- v1'in çocuğu (4. sınıf)
  c2  uuid := gen_random_uuid();   -- v1'in çocuğu (4. sınıf)
  c3  uuid := gen_random_uuid();   -- v2'nin çocuğu (5. sınıf)

  v_json  jsonb;
  v_json2 jsonb;
  v_int   integer;
  v_int2  integer;
  v_id    uuid;
  v_seg   uuid;
  v_kam   uuid;
  v_anket uuid;
  v_text  text;
  v_bool  boolean;
  v_gun   timestamptz;
  v_gece  timestamptz;
begin
  no := 0;

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (adm, 'ym.adm@example.test', '{"role":"veli","full_name":"Test Admin"}'),
      (v1,  'ym.v1@example.test',  '{"role":"veli","full_name":"Test Veli Bir"}'),
      (v2,  'ym.v2@example.test',  '{"role":"veli","full_name":"Test Veli Iki"}'),
      (c1,  'ym.c1@example.test',  '{"role":"ogrenci","full_name":"Cocuk Bir"}'),
      (c2,  'ym.c2@example.test',  '{"role":"ogrenci","full_name":"Cocuk Iki"}'),
      (c3,  'ym.c3@example.test',  '{"role":"ogrenci","full_name":"Cocuk Uc"}');
    update public.profiles set role = 'admin' where id = adm;
    update public.profiles set parent_id = v1, sinif = 4 where id in (c1, c2);
    update public.profiles set parent_id = v2, sinif = 5 where id = c3;

    -- Bir ödeme + abonelik verisi (mutabakat/plan kriteri için)
    insert into public.plans (kod, ad, fiyat_kurus, sure_gun)
      values ('ym_test_plan', 'YM Test Plan', 1000, 30) on conflict (kod) do nothing;

    v_gun   := ((date_trunc('day', now() at time zone 'Europe/Istanbul') + interval '2 days 12 hours')
                at time zone 'Europe/Istanbul');
    v_gece  := ((date_trunc('day', now() at time zone 'Europe/Istanbul') + interval '2 days 23 hours')
                at time zone 'Europe/Istanbul');

    -- ---------------------------------------------------------------
    -- A) Fail-closed + yetki
    -- ---------------------------------------------------------------
    no := no + 1;
    senaryo := 'authenticated kullanıcı yeni tabloları DOĞRUDAN okuyamaz (fail-closed)';
    v_int := 0;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform 1 from public.iletisim_tercihleri;     exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform 1 from public.segmentler;              exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform 1 from public.iletisim_kampanyalari;   exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform 1 from public.anketler;                exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform 1 from public.anket_yanitlari;         exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform 1 from public.otomasyonlar;            exception when insufficient_privilege then v_int := v_int + 1; end;
    perform set_config('role', 'none', true);
    gecti := (v_int = 6);
    detay := format('reddedilen=%s/6', v_int);
    return next;

    no := no + 1;
    senaryo := 'Admin olmayan veli admin fonksiyonlarını çağıramaz';
    v_int := 0;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform public.admin_veli_profil(v1);                       exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform public.admin_segment_listele();                     exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform public.admin_kampanya_listele();                    exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform public.admin_anket_listele();                       exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform public.admin_analitik_ozet(30);                     exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform public.admin_export_aileler(null, 'yetkisiz deneme kaydi'); exception when insufficient_privilege then v_int := v_int + 1; end;
    perform set_config('role', 'none', true);
    gecti := (v_int = 6);
    detay := format('reddedilen=%s/6', v_int);
    return next;

    -- ---------------------------------------------------------------
    -- B) İletişim tercihleri (KVKK)
    -- ---------------------------------------------------------------
    no := no + 1;
    senaryo := 'Varsayılan: hiçbir kanalda izin YOK; veli kendi tercihlerini 4 kanal olarak görür';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    v_json := public.veli_tercihlerim();
    perform set_config('role', 'none', true);
    gecti := jsonb_array_length(v_json) = 4
             and not exists (select 1 from jsonb_array_elements(v_json) e where (e ->> 'izin')::boolean);
    detay := v_json::text;
    return next;

    no := no + 1;
    senaryo := 'Veli e-posta izni verir, sonra GERİ ÇEKER; geçmişe iki kayıt yazılır';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.veli_tercih_ayarla('eposta', true);
    perform public.veli_tercih_ayarla('eposta', false);
    perform public.veli_tercih_ayarla('eposta', true);   -- segment testleri için tekrar izinli
    perform set_config('role', 'none', true);
    select count(*) into v_int from public.iletisim_tercih_gecmisi where veli_id = v1 and kanal = 'eposta';
    select izin into v_bool from public.iletisim_tercihleri where veli_id = v1 and kanal = 'eposta';
    gecti := (v_int = 3 and v_bool);
    detay := format('gecmis=%s son_izin=%s', v_int, v_bool);
    return next;

    no := no + 1;
    senaryo := 'Çocuk hesabı tercih ayarlayamaz; geçersiz kanal reddedilir';
    v_int := 0;
    perform set_config('request.jwt.claim.sub', c1::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform public.veli_tercih_ayarla('eposta', true); exception when insufficient_privilege then v_int := v_int + 1; end;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    begin perform public.veli_tercih_ayarla('faks', true);   exception when invalid_parameter_value then v_int := v_int + 1; end;
    perform set_config('role', 'none', true);
    gecti := (v_int = 2);
    detay := format('reddedilen=%s/2', v_int);
    return next;

    -- Bundan sonrası admin
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);

    no := no + 1;
    senaryo := 'Admin izin değiştirirken gerekçe ZORUNLU (kısa gerekçe 22023); gerekçeyle başarılı';
    v_int := 0;
    begin perform public.admin_veli_tercih_ayarla(v2, 'push', true, 'kısa'); exception when invalid_parameter_value then v_int := v_int + 1; end;
    perform public.admin_veli_tercih_ayarla(v2, 'push', true, 'Veli telefonda yazılı onay verdi');
    select count(*) into v_int2 from public.iletisim_tercih_gecmisi where veli_id = v2 and gerekce is not null;
    gecti := (v_int = 1 and v_int2 = 1);
    detay := format('reddedilen=%s gerekceli_kayit=%s', v_int, v_int2);
    return next;

    no := no + 1;
    senaryo := 'Veli notu eklenir; denetim izine not METNİ yazılmaz';
    perform public.admin_veli_not_ekle(v1, 'Gizli not metni 12345');
    select exists (select 1 from public.admin_audit_log
                    where admin_id = adm and islem = 'veli_notu_eklendi'
                      and detay::text not like '%12345%') into v_bool;
    v_json := public.admin_veli_profil(v1);
    gecti := v_bool and jsonb_array_length(v_json -> 'notlar') = 1;
    detay := 'notlar=' || jsonb_array_length(v_json -> 'notlar');
    return next;

    no := no + 1;
    senaryo := 'admin_veli_profil: 2 çocuk, 4 kanal tercihi ve zaman çizelgesi (kayıt + tercih) döner';
    gecti := jsonb_array_length(v_json -> 'cocuklar') = 2
             and jsonb_array_length(v_json -> 'tercihler') = 4
             and exists (select 1 from jsonb_array_elements(v_json -> 'zaman_cizelgesi') z where z ->> 'tur' = 'kayit')
             and exists (select 1 from jsonb_array_elements(v_json -> 'zaman_cizelgesi') z where z ->> 'tur' = 'tercih');
    detay := 'zaman=' || jsonb_array_length(v_json -> 'zaman_cizelgesi');
    return next;

    no := no + 1;
    senaryo := 'Dışa aktarma: gerekçesiz reddedilir; gerekçeyle satır döner ve denetim izine adet+gerekçe yazılır';
    v_int := 0;
    begin perform public.admin_export_aileler(null, 'kisa'); exception when invalid_parameter_value then v_int := v_int + 1; end;
    v_json := public.admin_export_aileler('Test Veli', 'Muhasebe mutabakatı için aylık liste');
    select exists (select 1 from public.admin_audit_log
                    where admin_id = adm and islem = 'aileler_disa_aktarildi'
                      and (detay ->> 'adet')::int = 2) into v_bool;
    gecti := (v_int = 1 and jsonb_array_length(v_json) = 2 and v_bool);
    detay := format('reddedilen=%s satir=%s audit=%s', v_int, jsonb_array_length(v_json), v_bool);
    return next;

    -- ---------------------------------------------------------------
    -- C) Segment: veli bazlı tekilleştirme + izin dışlama
    -- ---------------------------------------------------------------
    no := no + 1;
    senaryo := '4. sınıf segmenti: 2 çocuklu aile TEK alıcıdır (tekilleştirme)';
    -- Canlı veride başka 4. sınıf velileri olabilir: yalnızca test velisinin satırı sayılır.
    perform set_config('role', 'none', true);   -- iç fonksiyon istemciye kapalı
    select count(*) into v_int from public._segment_veliler('{"sinif":[4]}'::jsonb, 'eposta') where r_veli_id = v1;
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_segment_onizle('{"sinif":[4]}'::jsonb, 'eposta');
    gecti := v_int = 1 and (v_json ->> 'toplam')::int >= 1 and (v_json ->> 'izinli')::int >= 1;
    detay := format('v1_satir=%s %s', v_int, v_json);
    return next;

    no := no + 1;
    senaryo := 'Tüm veliler: izinsiz veli (v2 e-posta) "hariç" sayılır';
    v_json := public.admin_segment_onizle('{}'::jsonb, 'eposta');
    gecti := (v_json ->> 'toplam')::int >= 2
             and (v_json ->> 'haric')::int >= 1
             and (v_json ->> 'izinli')::int >= 1;
    detay := v_json::text;
    return next;

    no := no + 1;
    senaryo := 'Geçersiz segment kriteri (aktiflik) reddedilir; segment kaydedilir ve listelenir';
    v_int := 0;
    begin perform public.admin_segment_kaydet(null, 'Kötü', null, '{"aktiflik":"uydurma"}'::jsonb); exception when invalid_parameter_value then v_int := v_int + 1; end;
    v_seg := public.admin_segment_kaydet(null, 'YM 4. sınıf velileri', 'test', '{"sinif":[4]}'::jsonb);
    v_json := public.admin_segment_listele();
    gecti := (v_int = 1)
             and exists (select 1 from jsonb_array_elements(v_json) s where (s ->> 'id')::uuid = v_seg and (s ->> 'veli_sayisi')::int >= 1);
    detay := format('reddedilen=%s', v_int);
    return next;

    -- ---------------------------------------------------------------
    -- D) Kampanya: ön kontrol → planlama kapıları
    -- ---------------------------------------------------------------
    no := no + 1;
    senaryo := 'Kampanya taslağı kaydedilir; ön kontrol olmadan PLANLANAMAZ (23514)';
    v_kam := public.admin_kampanya_kaydet(null, 'YM kampanya', 'eposta', v_seg, 'Merhaba', 'Haftalık özet hazır');
    v_int := 0;
    begin perform public.admin_kampanya_planla(v_kam); exception when check_violation then v_int := v_int + 1; end;
    gecti := (v_int = 1);
    detay := format('reddedilen=%s', v_int);
    return next;

    no := no + 1;
    senaryo := 'Sessiz saatte (23:00 yerel) ön kontrol sessiz_saat=true; planlama reddedilir';
    v_json := public.admin_kampanya_on_kontrol(v_kam, v_gece);
    v_int := 0;
    begin perform public.admin_kampanya_planla(v_kam); exception when check_violation then v_int := v_int + 1; end;
    gecti := (v_json ->> 'sessiz_saat')::boolean and v_int = 1;
    detay := v_json::text;
    return next;

    no := no + 1;
    senaryo := 'Gün içi (12:00 yerel) ön kontrol temiz: gönderilecek>=1; planlama başarılı, outbox olayı PII içermez';
    v_json := public.admin_kampanya_on_kontrol(v_kam, v_gun);
    perform public.admin_kampanya_planla(v_kam);
    select count(*) into v_int from public.olay_kutusu
      where tur = 'iletisim_kampanyasi_planlandi' and payload ->> 'kampanya_id' = v_kam::text
        and not (payload ? 'email') and not (payload ? 'ad');
    select durum into v_text from public.iletisim_kampanyalari where id = v_kam;
    gecti := not (v_json ->> 'sessiz_saat')::boolean
             and (v_json ->> 'gonderilecek')::int >= 1
             and v_text = 'planlandi' and v_int = 1;
    detay := format('durum=%s outbox=%s onkontrol=%s', v_text, v_int, v_json);
    return next;

    no := no + 1;
    senaryo := 'Planlanmış kampanya düzenlenemez (23514); iptal edilince iptal olayı yazılır';
    v_int := 0;
    begin perform public.admin_kampanya_kaydet(v_kam, 'Yeni ad', 'eposta', v_seg, 'B', 'M'); exception when check_violation then v_int := v_int + 1; end;
    perform public.admin_kampanya_iptal(v_kam);
    select durum into v_text from public.iletisim_kampanyalari where id = v_kam;
    gecti := (v_int = 1 and v_text = 'iptal');
    detay := format('reddedilen=%s durum=%s', v_int, v_text);
    return next;

    no := no + 1;
    senaryo := 'Açık kampanyada kullanılan segment arşivlenemez; iptal sonrası arşivlenir';
    v_kam := public.admin_kampanya_kaydet(null, 'YM ikinci', 'eposta', v_seg, 'Selam', 'Mesaj');
    v_int := 0;
    begin perform public.admin_segment_arsivle(v_seg); exception when foreign_key_violation then v_int := v_int + 1; end;
    perform public.admin_kampanya_iptal(v_kam);
    perform public.admin_segment_arsivle(v_seg);
    gecti := (v_int = 1);
    detay := format('reddedilen=%s', v_int);
    return next;

    -- ---------------------------------------------------------------
    -- E) Anket: anonimlik, NPS, düşük skor görevi
    -- ---------------------------------------------------------------
    no := no + 1;
    senaryo := 'Geçersiz anket soruları (koşul ileri soruya bağlı) reddedilir';
    v_int := 0;
    begin
      perform public.admin_anket_kaydet(null, 'Kötü anket', false,
        '[{"id":"a","tur":"nps","baslik":"A","kosul":{"soru_id":"b","op":"lte","deger":6}},{"id":"b","tur":"uzun_metin","baslik":"B"}]'::jsonb);
    exception when invalid_parameter_value then v_int := v_int + 1; end;
    gecti := (v_int = 1);
    detay := format('reddedilen=%s', v_int);
    return next;

    v_anket := public.admin_anket_kaydet(null, 'YM kimlikli NPS', false,
      '[{"id":"nps1","tur":"nps","baslik":"Önerir misiniz?"},{"id":"neden","tur":"uzun_metin","baslik":"Neden?","kosul":{"soru_id":"nps1","op":"lte","deger":6}}]'::jsonb);
    perform public.admin_anket_durum(v_anket, 'yayinda');

    no := no + 1;
    senaryo := 'Veli aktif anketi görür, NPS=3 ile yanıtlar → DESTEK GÖREVİ oluşur (indirim/teklif yok)';
    perform set_config('request.jwt.claim.sub', v1::text, true);
    v_json := null;
    perform set_config('role', 'authenticated', true);
    v_json := public.anket_aktif_listem();
    perform public.anket_yanit_gonder(v_anket, '{"nps1":3,"neden":"Yavaş"}'::jsonb);
    v_json2 := public.anket_aktif_listem();   -- tekrar gösterim aralığında gizlenmeli
    perform set_config('role', 'none', true);
    select count(*) into v_int from public.destek_gorevleri where veli_id = v1 and durum = 'acik';
    gecti := exists (select 1 from jsonb_array_elements(v_json) a where (a ->> 'id')::uuid = v_anket)
             and not exists (select 1 from jsonb_array_elements(v_json2) a where (a ->> 'id')::uuid = v_anket)
             and v_int = 1;
    detay := format('acik_gorev=%s', v_int);
    return next;

    no := no + 1;
    senaryo := 'Aynı veli tekrar yanıtlayamaz (23505); aralık dışı değer ve tanımsız soru reddedilir';
    v_int := 0;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform public.anket_yanit_gonder(v_anket, '{"nps1":9}'::jsonb); exception when unique_violation then v_int := v_int + 1; end;
    perform set_config('request.jwt.claim.sub', v2::text, true);
    begin perform public.anket_yanit_gonder(v_anket, '{"nps1":11}'::jsonb); exception when invalid_parameter_value then v_int := v_int + 1; end;
    begin perform public.anket_yanit_gonder(v_anket, '{"uydurma":1}'::jsonb); exception when invalid_parameter_value then v_int := v_int + 1; end;
    perform set_config('role', 'none', true);
    gecti := (v_int = 3);
    detay := format('reddedilen=%s/3', v_int);
    return next;

    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);
    v_id := public.admin_anket_kaydet(null, 'YM anonim', true,
      '[{"id":"n","tur":"nps","baslik":"Önerir misiniz?"}]'::jsonb);
    perform public.admin_anket_durum(v_id, 'yayinda');
    perform set_config('role', 'none', true);

    no := no + 1;
    senaryo := 'ANONİM anket: yanıtta veli_id NULL, zaman günü yuvarlanır, DESTEK GÖREVİ üretilmez';
    perform set_config('request.jwt.claim.sub', v2::text, true);
    perform set_config('role', 'authenticated', true);
    perform public.anket_yanit_gonder(v_id, '{"n":2}'::jsonb);
    perform set_config('role', 'none', true);
    select count(*) into v_int from public.anket_yanitlari
      where anket_id = v_id and veli_id is null and created_at = date_trunc('day', created_at);
    select count(*) into v_int2 from public.destek_gorevleri where veli_id = v2;
    gecti := (v_int = 1 and v_int2 = 0);
    detay := format('anonim_yanit=%s destek=%s', v_int, v_int2);
    return next;

    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);

    no := no + 1;
    senaryo := 'Yanıt alınmış ankette anonimlik DEĞİŞTİRİLEMEZ (23514)';
    v_int := 0;
    begin perform public.admin_anket_kaydet(v_id, 'YM anonim', false, '[{"id":"n","tur":"nps","baslik":"Önerir misiniz?"}]'::jsonb);
    exception when check_violation then v_int := v_int + 1; end;
    gecti := (v_int = 1);
    detay := format('reddedilen=%s', v_int);
    return next;

    no := no + 1;
    senaryo := 'Sonuç: NPS hesabı (1 eleştiren) ve sonuçta kimlik alanı YOK; yayındaki soru değişince sürüm artar';
    v_json := public.admin_anket_sonuc(v_anket);
    perform public.admin_anket_kaydet(v_anket, 'YM kimlikli NPS', false,
      '[{"id":"nps1","tur":"nps","baslik":"Tavsiye eder misiniz?"}]'::jsonb);
    select surum into v_int from public.anketler where id = v_anket;
    gecti := (v_json -> 'nps' ->> 'elestiren')::int = 1
             and (v_json -> 'nps' ->> 'skor')::int = -100
             and position('veli_id' in v_json::text) = 0
             and v_int = 2;
    detay := format('skor=%s surum=%s', v_json -> 'nps' ->> 'skor', v_int);
    return next;

    -- ---------------------------------------------------------------
    -- F) Otomasyon + analitik + mutabakat
    -- ---------------------------------------------------------------
    no := no + 1;
    senaryo := 'Otomasyon: geçersiz adım reddedilir; geçerli akış kaydedilir; mesajsız akış "hazır" olamaz';
    v_int := 0;
    begin perform public.admin_otomasyon_kaydet(null, 'Kötü', 'veli_kayit', '[{"tur":"bekle","saat":0}]'::jsonb);
    exception when invalid_parameter_value then v_int := v_int + 1; end;
    v_id := public.admin_otomasyon_kaydet(null, 'YM akış', 'veli_kayit',
      '[{"tur":"bekle","saat":24},{"tur":"kosul","olcut":"ilk_gorev_tamamlandi"}]'::jsonb);
    begin perform public.admin_otomasyon_durum(v_id, 'hazir'); exception when check_violation then v_int := v_int + 1; end;
    v_id := public.admin_otomasyon_kaydet(v_id, 'YM akış', 'veli_kayit',
      '[{"tur":"bekle","saat":24},{"tur":"mesaj","kanal":"eposta","baslik":"Başlayalım"}]'::jsonb);
    perform public.admin_otomasyon_durum(v_id, 'hazir');
    select durum into v_text from public.otomasyonlar where id = v_id;
    gecti := (v_int = 2 and v_text = 'hazir');
    detay := format('reddedilen=%s durum=%s', v_int, v_text);
    return next;

    no := no + 1;
    senaryo := 'Analitik özeti: huni değerleri sıralı (kayıt >= çocuk >= ilk öğrenme) ve 5 haftalık kohort döner';
    v_json := public.admin_analitik_ozet(30);
    gecti := (v_json -> 'huni' ->> 'kayit')::int >= (v_json -> 'huni' ->> 'cocuk_bagladi')::int
             and (v_json -> 'huni' ->> 'cocuk_bagladi')::int >= (v_json -> 'huni' ->> 'ilk_ogrenme')::int
             and jsonb_array_length(v_json -> 'kohort') = 5;
    detay := (v_json -> 'huni')::text;
    return next;

    no := no + 1;
    senaryo := 'Mutabakat: aboneliği olmayan başarılı ödeme ve süresi geçmiş aktif abonelik yakalanır';
    perform set_config('role', 'none', true);
    insert into public.payments (veli_id, tutar_kurus, durum, saglayici)
      values (v1, 1000, 'basarili', 'manuel');
    insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis)
      values (v2, 'ym_test_plan', 'aktif', now() - interval '40 days', now() - interval '10 days');
    perform set_config('role', 'authenticated', true);
    v_json := public.admin_odeme_mutabakat();
    gecti := exists (select 1 from jsonb_array_elements(v_json) m where m ->> 'tur' = 'abonelik_yok')
             and exists (select 1 from jsonb_array_elements(v_json) m where m ->> 'tur' = 'suresi_gecmis_aktif');
    detay := 'kayit=' || jsonb_array_length(v_json);
    return next;

    no := no + 1;
    senaryo := 'İletişim ayarları: geçersiz sınır/aralık reddedilir; geçerli kaydedilir';
    v_int := 0;
    begin perform public.admin_iletisim_ayarlari_kaydet(99, '20:00', '09:00'); exception when invalid_parameter_value then v_int := v_int + 1; end;
    begin perform public.admin_iletisim_ayarlari_kaydet(3, '09:00', '09:00');  exception when invalid_parameter_value then v_int := v_int + 1; end;
    perform public.admin_iletisim_ayarlari_kaydet(3, '20:00', '09:00');
    v_json := public.admin_iletisim_ayarlari_getir();
    gecti := (v_int = 2 and (v_json ->> 'haftalik_limit')::int = 3);
    detay := v_json::text;
    return next;

    perform set_config('role', 'none', true);
    perform set_config('request.jwt.claim.sub', '', true);

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
  from pg_temp.yonetim_merkezi_testleri()
 order by no;
