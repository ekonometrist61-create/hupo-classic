-- =====================================================================
-- MÜŞTERİ 360 VERİ TOPLAMA TEST SENARYOLARI
-- Kapsam: 20261027000000_musteri_360_veri_toplama.sql
--   1-2  profil → hane + çocuk kişisi
--   3-5  veli_adaylari / deneme ön kaydı → kart, izin köprüsü, tekilleştirme
--   6    admin'in elle yazdığı alan senkronla ezilmez
--   7-8  abonelik → plan/durum/yaşam döngüsü; ödeme → işlem satırı ve ciro
--   9    geçersiz e-posta tetikleyiciyi patlatmaz
--   10   geri doldurma idempotent
--
-- Kalıcı kayıt bırakmaz: PGlite geçicidir. Her senaryo kendi hatasını yakalar (FAIL olarak raporlanır).
-- =====================================================================

set client_encoding = 'UTF8';

create or replace function pg_temp.musteri360_testleri()
returns table (no int, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  v_veli  uuid;
  v_ogr   uuid;
  v7      uuid;
  sid7    uuid;
  pid     uuid;
  on_id   uuid;
  hrow    public.growth_households%rowtype;
  kisi    public.growth_customer_people%rowtype;
  cnt     int;
  cnt2    int;
  h0      int;
  h1      int;
  h2      int;
  p0      int;
  p1      int;
  p2      int;
  i0      int;
  i1      int;
  i2      int;
  v_text  text;
  v_num   numeric;
begin
  no := 0;

  -- 1. Veli profili → e-posta ile hane kartı
  no := no + 1;
  senaryo := 'Veli profili eklenince e-postayla kart oluşur (registered, HUP-, core_parent dolu)';
  gecti := false; detay := null;
  begin
    v_veli := gen_random_uuid();
    insert into auth.users (id, email) values (v_veli, 's1.veli@example.test');
    insert into public.profiles (id, role, full_name) values (v_veli, 'veli', 'Ayşe Yılmaz');
    select * into hrow from public.growth_households where lower(email) = 's1.veli@example.test';
    gecti := found and hrow.lifecycle = 'registered' and hrow.customer_no like 'HUP-%'
             and hrow.core_parent_user_id = v_veli;
    detay := format('bulundu=%s lifecycle=%s customer_no=%s core=%s',
                    found, hrow.lifecycle, hrow.customer_no, hrow.core_parent_user_id);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 2. Öğrenci profili → growth_customer_people (student, grade 5)
  no := no + 1;
  senaryo := 'Öğrenci profili (parent_id=veli, sinif=5) growth_customer_people içinde student, grade 5';
  gecti := false; detay := null;
  begin
    v_ogr := gen_random_uuid();
    insert into auth.users (id, email) values (v_ogr, 's2.ogrenci@example.test');
    insert into public.profiles (id, role, parent_id, full_name, sinif)
      values (v_ogr, 'ogrenci', v_veli, 'Ali', 5);
    select * into hrow from public.growth_households where core_parent_user_id = v_veli;
    select * into kisi from public.growth_customer_people
     where household_id = hrow.id and core_student_id = v_ogr;
    gecti := found and kisi.person_role = 'student' and kisi.grade = 5;
    detay := format('bulundu=%s role=%s grade=%s', found, kisi.person_role, kisi.grade);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 3. Landing formu adayı (pazarlama_izni=true) → lead kartı, source=kaynak, e-posta izni granted
  no := no + 1;
  senaryo := 'veli_adaylari (izin=true) kart oluşturur (lead, source=kaynak) ve bridge email granted';
  gecti := false; detay := null;
  begin
    insert into public.veli_adaylari (email, ad, kaynak, pazarlama_izni)
      values ('s3.aday@example.test', 'Zeynep Kaya', 'landing_form', true);
    select * into hrow from public.growth_households where lower(email) = 's3.aday@example.test';
    gecti := found and hrow.lifecycle = 'lead' and hrow.source = 'landing_form'
             and exists (select 1 from public.growth_consent_bridge b
                          where b.household_id = hrow.id and b.channel = 'email' and b.granted);
    detay := format('bulundu=%s lifecycle=%s source=%s', found, hrow.lifecycle, hrow.source);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 4. Deneme sınavı ön kaydı: e-posta izni granted, sms/telefon denied, çocuk, olay
  no := no + 1;
  senaryo := 'deneme ön kaydı: kart(source deneme_on_kayit), email granted, sms+phone denied, çocuk sinif 6, olay';
  gecti := false; detay := null;
  begin
    insert into public.deneme_sinavi_on_kayitlari
      (exam_id, veli_ad, cocuk_ad, sinif, eposta, telefon, izin_eposta, izin_sms, izin_telefon, izin_surum)
      values (gen_random_uuid(), 'Mehmet Demir', 'Elif', 6, 'S4.Veli@Example.test ', '5550001122',
              true, false, false, 'v1')
      returning id into on_id;
    select * into hrow from public.growth_households where lower(email) = 's4.veli@example.test';
    select * into kisi from public.growth_customer_people
     where household_id = hrow.id and first_name = 'Elif' and person_role = 'student';
    gecti := found
             and hrow.source = 'deneme_on_kayit'
             and exists (select 1 from public.growth_consent_bridge b where b.household_id = hrow.id and b.channel = 'email' and b.granted)
             and exists (select 1 from public.growth_consent_bridge b where b.household_id = hrow.id and b.channel = 'sms' and not b.granted)
             and exists (select 1 from public.growth_consent_bridge b where b.household_id = hrow.id and b.channel = 'phone' and not b.granted)
             and kisi.grade = 6
             and exists (select 1 from public.growth_events e where e.household_id = hrow.id and e.event_name = 'deneme_on_kayit');
    detay := format('hane=%s source=%s cocuk_grade=%s',
                    found, hrow.source, kisi.grade);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 5. Aynı e-posta ile ikinci form kart çoğaltmaz; source ilk değerde kalır
  no := no + 1;
  senaryo := 'Aynı e-posta ile ikinci form (veli_adaylari) kart çoğaltmaz (count=1) ve source ilk değerde kalır';
  gecti := false; detay := null;
  begin
    insert into public.veli_adaylari (email, ad, kaynak, pazarlama_izni)
      values ('s3.aday@example.test', 'Zeynep Kaya', 'meta_reklam', true);
    select count(*) into cnt from public.growth_households where lower(email) = 's3.aday@example.test';
    select source into v_text from public.growth_households where lower(email) = 's3.aday@example.test';
    gecti := cnt = 1 and v_text = 'landing_form';
    detay := format('kart_sayisi=%s source=%s', cnt, v_text);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 6. Admin'in elle yazdığı telefon senkronla ezilmez
  no := no + 1;
  senaryo := 'Admin elle yazdığı phone (555) yeni deneme kaydıyla ezilmez';
  gecti := false; detay := null;
  begin
    update public.growth_households set phone = '555' where lower(email) = 's4.veli@example.test';
    insert into public.deneme_sinavi_on_kayitlari
      (exam_id, veli_ad, cocuk_ad, sinif, eposta, telefon, izin_eposta, izin_surum)
      values (gen_random_uuid(), 'Mehmet Demir', 'Elif', 6, 's4.veli@example.test', '5559998877', true, 'v1');
    select phone into v_text from public.growth_households where lower(email) = 's4.veli@example.test';
    gecti := v_text = '555';
    detay := format('phone=%s', v_text);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 7. Abonelik: aktif ücretli → premium/active/paid/mrr>0; süresi dolunca expired/churned
  no := no + 1;
  senaryo := 'Aktif ücretli abonelik → premium/active/paid/mrr>0; suresi_doldu → expired/churned';
  gecti := false; detay := null;
  begin
    v7 := gen_random_uuid();
    insert into auth.users (id, email) values (v7, 's7.veli@example.test');
    insert into public.profiles (id, role, full_name) values (v7, 'veli', 'Can Öz');
    insert into public.plans (kod, ad, fiyat_kurus, sure_gun, tip_kod)
      values ('premium_aylik', 'Premium Aylık', 9900, 30, 'premium');
    insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis, saglayici)
      values (v7, 'premium_aylik', 'aktif', now(), now() + interval '30 days', 'iyzico')
      returning id into sid7;
    select * into hrow from public.growth_households where core_parent_user_id = v7;
    v_text := format('aktif: plan=%s durum=%s lifecycle=%s mrr=%s', hrow.plan, hrow.subscription_status, hrow.lifecycle, hrow.mrr);
    gecti := hrow.plan = 'premium' and hrow.subscription_status = 'active'
             and hrow.lifecycle = 'paid' and hrow.mrr > 0;

    update public.subscriptions set durum = 'suresi_doldu' where id = sid7;
    select * into hrow from public.growth_households where core_parent_user_id = v7;
    detay := v_text || format(' | sonra: durum=%s lifecycle=%s', hrow.subscription_status, hrow.lifecycle);
    gecti := gecti and hrow.subscription_status = 'expired' and hrow.lifecycle = 'churned';
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 8. Ödeme: basarili → paid işlem satırı, ciro/adet; güncelleme satır çoğaltmaz
  no := no + 1;
  senaryo := 'Ödeme basarili → işlem paid, ciro ve adet güncellenir; ödeme update satır çoğaltmaz';
  gecti := false; detay := null;
  begin
    insert into public.payments (veli_id, subscription_id, tutar_kurus, durum, saglayici, saglayici_ref, aciklama)
      values (v7, sid7, 9900, 'basarili', 'iyzico', 'REF-1', 'Aylık abonelik')
      returning id into pid;
    select * into hrow from public.growth_households where core_parent_user_id = v7;
    select count(*) into cnt from public.growth_financial_transactions where household_id = hrow.id;
    v_num := hrow.total_revenue_try;
    gecti := cnt = 1 and v_num = 99.00 and hrow.total_paid_transactions = 1
             and exists (select 1 from public.growth_financial_transactions t
                          where t.household_id = hrow.id and t.status = 'paid');
    v_text := format('islem=%s ciro=%s adet=%s', cnt, v_num, hrow.total_paid_transactions);

    update public.payments set aciklama = 'guncellendi' where id = pid;
    select count(*) into cnt2 from public.growth_financial_transactions where household_id = hrow.id;
    select * into hrow from public.growth_households where core_parent_user_id = v7;
    gecti := gecti and cnt2 = 1 and hrow.total_revenue_try = 99.00 and hrow.total_paid_transactions = 1;
    detay := v_text || format(' | update sonrası islem=%s ciro=%s', cnt2, hrow.total_revenue_try);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 9. Geçersiz e-posta: tetikleyici patlamaz, kart oluşmaz
  no := no + 1;
  senaryo := 'Geçersiz e-posta (abc) veli_adaylari kaydı tetikleyiciyi patlatmaz, kart oluşmaz';
  gecti := false; detay := null;
  begin
    insert into public.veli_adaylari (email, ad, kaynak, pazarlama_izni)
      values ('abc', 'Geçersiz Aday', 'web_form', true);
    select count(*) into cnt from public.veli_adaylari where email = 'abc';
    select count(*) into cnt2 from public.growth_households where lower(email) = 'abc';
    gecti := cnt = 1 and cnt2 = 0;
    detay := format('aday_satiri=%s kart=%s', cnt, cnt2);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 10. Geri doldurma idempotent: tekrar çalışınca sayılar değişmez
  no := no + 1;
  senaryo := 'Geri doldurma (_growth_on_kayit_esle) tekrar çalışınca kart/kişi/izin sayısı değişmez';
  gecti := false; detay := null;
  begin
    select count(*) into h0 from public.growth_households;
    select count(*) into i0 from public.growth_household_izinleri;
    select count(*) into p0 from public.growth_customer_people;
    perform public._growth_on_kayit_esle(d.id) from public.deneme_sinavi_on_kayitlari d;
    select count(*) into h1 from public.growth_households;
    select count(*) into i1 from public.growth_household_izinleri;
    select count(*) into p1 from public.growth_customer_people;
    perform public._growth_on_kayit_esle(d.id) from public.deneme_sinavi_on_kayitlari d;
    select count(*) into h2 from public.growth_households;
    select count(*) into i2 from public.growth_household_izinleri;
    select count(*) into p2 from public.growth_customer_people;
    gecti := h1 = h2 and i1 = i2 and p1 = p2 and h1 = h0 and i1 = i0 and p1 = p0;
    detay := format('kart %s->%s->%s, izin %s->%s->%s, kisi %s->%s->%s',
                    h0, h1, h2, i0, i1, i2, p0, p1, p2);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 11. İşaretsiz kutu verilmiş izni geri çekmiş sayılmaz; yeni kanalda "verilmedi" yazılır
  no := no + 1;
  senaryo := 'Önce izin veren kişi izinsiz formla tekrar gelince e-posta izni korunur, sms ilk kez denied';
  gecti := false; detay := null;
  begin
    insert into public.deneme_sinavi_on_kayitlari
      (exam_id, veli_ad, cocuk_ad, sinif, eposta, telefon, izin_eposta, izin_sms, izin_telefon, kvkk_surum, izin_surum)
    values (gen_random_uuid(), 'Izin Test', 'Cocuk A', 5, 'izin.korun@example.test', '+905550000011', true, false, false, 'k1', 'i1');
    insert into public.deneme_sinavi_on_kayitlari
      (exam_id, veli_ad, cocuk_ad, sinif, eposta, telefon, izin_eposta, izin_sms, izin_telefon, kvkk_surum, izin_surum)
    values (gen_random_uuid(), 'Izin Test', 'Cocuk A', 5, 'izin.korun@example.test', '+905550000011', false, false, false, 'k1', 'i2');
    select count(*) filter (where b.channel = 'email' and b.granted),
           count(*) filter (where b.channel = 'sms' and not b.granted)
      into cnt, cnt2
      from public.growth_consent_bridge b
      join public.growth_households h on h.id = b.household_id
     where lower(h.email) = 'izin.korun@example.test';
    gecti := cnt = 1 and cnt2 = 1;
    detay := format('email_granted=%s sms_denied=%s', cnt, cnt2);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;
end;
$fn$;
