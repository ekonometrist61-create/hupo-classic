-- =====================================================================
-- VELİ ADAYLARI (CRM) + OLAY KUTUSU (OUTBOX) TEST SENARYOLARI
--
-- Nasıl çalıştırılır: Supabase SQL Editor'e tamamını yapıştırıp Run'a basın.
-- Her senaryo için "gecti" sütununda true/false görürsünüz.
-- Kalıcı kayıt bırakmaz: test verileri iş bitince geri alınır.
-- Ön koşul: 20261006010000_veli_adaylari_crm_ve_olay_kutusu.sql uygulanmış olmalı.
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.veli_adaylari_testleri()
returns table (no integer, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm uuid := gen_random_uuid();   -- admin
  v1  uuid := gen_random_uuid();   -- veli (admin değil)

  v_json  jsonb;
  v_json2 jsonb;
  v_pay   jsonb;
  v_int   integer;
  v_id    uuid;
  v_text  text;
  v_bool  boolean;
begin
  no := 0;

  begin  -- tüm test verisi sonunda geri alınır
    insert into auth.users (id, email, raw_user_meta_data) values
      (adm, 'crm.adm@example.test',  '{"role":"veli","full_name":"Test Admin"}'),
      (v1,  'crm.veli@example.test', '{"role":"veli","full_name":"Test Veli"}');
    update public.profiles set role = 'admin' where id = adm;

    -- ---------------------------------------------------------------
    -- A) Public lead yakalama (anon)
    -- ---------------------------------------------------------------

    -- 1
    no := no + 1;
    senaryo := 'Anon ziyaretçi lead oluşturur: yeni=true, kayıt yazılır';
    perform set_config('role', 'anon', true);
    v_json := public.veli_adayi_olustur('Ayse@Example.test', '  Ayşe Veli  ', '0555 111 22 33', 'landing', true);
    perform set_config('role', 'none', true);
    select email || '/' || ad || '/' || kaynak || '/' || pazarlama_izni::text || '/' || (izin_at is not null)::text
      into v_text from public.veli_adaylari where email = 'ayse@example.test';
    gecti := (v_json ->> 'yeni')::boolean = true
             and v_text = 'ayse@example.test/Ayşe Veli/landing/true/true';
    detay := v_text;
    return next;

    -- 2
    no := no + 1;
    senaryo := 'Outbox olayı AYNI işlemde yazıldı ve PII (email/ad) İÇERMİYOR';
    select payload into v_pay from public.olay_kutusu
      where tur = 'veli_adayi_olusturuldu'
      order by created_at desc limit 1;
    gecti := v_pay is not null
             and (v_pay ? 'veli_adayi_id')
             and not (v_pay ? 'email') and not (v_pay ? 'ad')
             and (v_pay ->> 'kaynak') = 'landing';
    detay := v_pay::text;
    return next;

    -- 3
    no := no + 1;
    senaryo := 'Aynı e-posta tekrar gelince tekilleşir (upsert): yeni=false, guncellendi olayı';
    perform set_config('role', 'anon', true);
    v_json := public.veli_adayi_olustur('ayse@example.test', 'Ayşe Yeni Ad', null, 'web_form', false);
    perform set_config('role', 'none', true);
    select count(*) into v_int from public.veli_adaylari where email = 'ayse@example.test';
    select ad || '/' || pazarlama_izni::text into v_text from public.veli_adaylari where email = 'ayse@example.test';
    gecti := (v_json ->> 'yeni')::boolean = false
             and v_int = 1                          -- tek kayıt
             and v_text = 'Ayşe Yeni Ad/true'       -- ad tazelendi, onay geri ALINMADI
             and exists (select 1 from public.olay_kutusu where tur = 'veli_adayi_guncellendi');
    detay := format('adet=%s, %s', v_int, v_text);
    return next;

    -- 4
    no := no + 1;
    senaryo := 'Geçersiz e-posta ve kısa ad reddedilir (22023)';
    perform set_config('role', 'anon', true);
    v_int := 0;
    begin perform public.veli_adayi_olustur('bozuk-eposta', 'Ali'); exception when invalid_parameter_value then v_int := v_int + 1; end;
    begin perform public.veli_adayi_olustur('ok@example.test', 'A'); exception when invalid_parameter_value then v_int := v_int + 1; end;
    perform set_config('role', 'none', true);
    gecti := (v_int = 2);
    detay := format('reddedilen=%s/2', v_int);
    return next;

    -- ---------------------------------------------------------------
    -- B) Fail-closed: doğrudan tablo erişimi yok
    -- ---------------------------------------------------------------

    -- 5
    no := no + 1;
    senaryo := 'authenticated kullanıcı veli_adaylari / olay_kutusu tablosunu DOĞRUDAN okuyamaz';
    v_int := 0;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform 1 from public.veli_adaylari; exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform 1 from public.olay_kutusu;   exception when insufficient_privilege then v_int := v_int + 1; end;
    perform set_config('role', 'none', true);
    gecti := (v_int = 2);
    detay := format('reddedilen=%s/2', v_int);
    return next;

    -- 6
    no := no + 1;
    senaryo := 'Admin olmayan veli hiçbir admin CRM fonksiyonunu çağıramaz';
    v_int := 0;
    perform set_config('request.jwt.claim.sub', v1::text, true);
    perform set_config('role', 'authenticated', true);
    begin perform public.admin_list_veli_adaylari();           exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform public.admin_veli_adayi_asama(gen_random_uuid(), 'deneme'); exception when insufficient_privilege then v_int := v_int + 1; end;
    begin perform public.admin_veli_adayi_detay(gen_random_uuid());           exception when insufficient_privilege then v_int := v_int + 1; end;
    perform set_config('role', 'none', true);
    gecti := (v_int = 3);
    detay := format('reddedilen=%s/3', v_int);
    return next;

    -- ---------------------------------------------------------------
    -- C) Admin yönetimi
    -- ---------------------------------------------------------------
    perform set_config('request.jwt.claim.sub', adm::text, true);
    perform set_config('role', 'authenticated', true);

    -- 7
    no := no + 1;
    senaryo := 'admin_list_veli_adaylari: {toplam, satirlar} döner, ada göre arar';
    v_json := public.admin_list_veli_adaylari(p_arama => 'ayşe');
    gecti := (v_json ->> 'toplam')::int = 1
             and (v_json -> 'satirlar' -> 0 ->> 'email') = 'ayse@example.test';
    detay := 'toplam=' || (v_json ->> 'toplam');
    return next;

    -- 8
    no := no + 1;
    senaryo := 'Aşama filtresi çalışır: yeni aday "yeni" filtresinde görünür, "musteri"de görünmez';
    v_json  := public.admin_list_veli_adaylari(p_asama => 'yeni');
    v_json2 := public.admin_list_veli_adaylari(p_asama => 'musteri');
    gecti := (v_json ->> 'toplam')::int = 1 and (v_json2 ->> 'toplam')::int = 0;
    detay := format('yeni=%s, musteri=%s', v_json ->> 'toplam', v_json2 ->> 'toplam');
    return next;

    -- 9
    no := no + 1;
    senaryo := 'admin_veli_adayi_asama: aşamayı değiştirir, not yazar, outbox + audit kaydı oluşur';
    select id into v_id from public.veli_adaylari where email = 'ayse@example.test';
    perform public.admin_veli_adayi_asama(v_id, 'deneme', 'Telefonda ilgilendi');
    perform set_config('role', 'none', true);
    select asama || '/' || notlar into v_text from public.veli_adaylari where id = v_id;
    select count(*) into v_int from public.olay_kutusu
      where tur = 'veli_adayi_asama_degisti' and payload ->> 'veli_adayi_id' = v_id::text;
    select exists (select 1 from public.admin_audit_log
      where admin_id = adm and islem = 'veli_adayi_asama_degisti') into v_bool;
    perform set_config('role', 'authenticated', true);
    gecti := (v_text = 'deneme/Telefonda ilgilendi' and v_int = 1 and v_bool);
    detay := format('%s, outbox=%s, audit=%s', v_text, v_int, v_bool);
    return next;

    -- 10
    no := no + 1;
    senaryo := 'Aynı aşama tekrar yazılırsa yeni outbox olayı ÜRETİLMEZ';
    perform public.admin_veli_adayi_asama(v_id, 'deneme');
    perform set_config('role', 'none', true);
    select count(*) into v_int from public.olay_kutusu
      where tur = 'veli_adayi_asama_degisti' and payload ->> 'veli_adayi_id' = v_id::text;
    perform set_config('role', 'authenticated', true);
    gecti := (v_int = 1);
    detay := 'asama_degisti olayı=' || v_int;
    return next;

    -- 11
    no := no + 1;
    senaryo := 'Geçersiz aşama (22023) ve olmayan aday (P0002) reddedilir';
    v_int := 0;
    begin perform public.admin_veli_adayi_asama(v_id, 'uydurma'); exception when invalid_parameter_value then v_int := v_int + 1; end;
    begin perform public.admin_veli_adayi_asama(gen_random_uuid(), 'deneme'); exception when no_data_found then v_int := v_int + 1; end;
    gecti := (v_int = 2);
    detay := format('reddedilen=%s/2', v_int);
    return next;

    -- 12
    no := no + 1;
    senaryo := 'admin_veli_adayi_detay: aday + olay zaman çizelgesini (outbox) döner';
    v_json := public.admin_veli_adayi_detay(v_id);
    gecti := (v_json -> 'aday' ->> 'email') = 'ayse@example.test'
             and jsonb_typeof(v_json -> 'olaylar') = 'array'
             and jsonb_array_length(v_json -> 'olaylar') >= 2;   -- olusturuldu/guncellendi + asama_degisti
    detay := 'olay sayısı=' || jsonb_array_length(v_json -> 'olaylar');
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
  from pg_temp.veli_adaylari_testleri()
 order by no;
