-- =====================================================================
-- GROWTH KVKK VE HANE BİRLEŞTİRME TEST SENARYOLARI
-- Kapsam: 20261106000000_growth_kvkk_birlestirme.sql
--   1-3   anonimleştirme: kişisel alan kalmaz, liste/detayda görünmez, denetim PII'siz
--   4     ücretli aktif abonelik reddedilir
--   5     admin olmayan: beş RPC de reddedilir; anon yetkisi kapalı
--   6-8   birleştirme: sayılar, izin AND kuralı, kaynak gizlenir ve PII taşımaz
--   9     farklı core hesaplı haneler ve kendi kendine birleştirme reddedilir
--   10-11 lead won kancası ve prospect üzerinden elle lead→hane bağlama
--   12    hane sahibi: yalnız admin kullanıcı
--   13    KVKK dışa aktarma: bölümler ve denetim
--   14-15 export_my_data 'growth' bölümü: yalnız kendi hanesi, anahtarlar korunur
--   16    birleştirilmiş kayıt doğrudan silinemez; kısa neden reddedilir
--   17    yeni işlemlerin denetim satırlarında PII yok
--
-- Kalıcı kayıt bırakmaz: PGlite geçicidir. Her senaryo kendi hatasını yakalar (FAIL olarak raporlanır).
-- =====================================================================

set client_encoding = 'UTF8';

-- JWT taklidi: auth.uid() bu değeri okur (stubs: musteri_360/stubs.sql).
create or replace function pg_temp.giris(p_uid uuid)
returns void
language plpgsql
as $fn$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_uid, 'role', 'authenticated')::text, false);
end $fn$;

-- SQL'i çalıştırır; hata olursa "SQLSTATE: mesaj" döner, yoksa null.
create or replace function pg_temp.hata(p_sql text)
returns text
language plpgsql
as $fn$
begin
  execute p_sql;
  return null;
exception when others then
  return sqlstate || ': ' || sqlerrm;
end $fn$;

create or replace function pg_temp.veli_olustur(p_email text, p_ad text)
returns uuid
language plpgsql
as $fn$
declare
  v uuid := gen_random_uuid();
begin
  insert into auth.users (id, email) values (v, p_email);
  insert into public.profiles (id, role, full_name) values (v, 'veli', p_ad);
  return v;
end $fn$;

create or replace function pg_temp.ogrenci_olustur(p_veli uuid, p_ad text, p_sinif smallint)
returns uuid
language plpgsql
as $fn$
declare
  o uuid := gen_random_uuid();
begin
  insert into auth.users (id, email) values (o, o::text || '@ogrenci.test');
  insert into public.profiles (id, role, parent_id, full_name, sinif) values (o, 'ogrenci', p_veli, p_ad, p_sinif);
  return o;
end $fn$;

create or replace function pg_temp.hane_of(p_veli uuid)
returns uuid
language sql
as $fn$
  select h.id from public.growth_households h where h.core_parent_user_id = p_veli
$fn$;

-- Verilen desenlerden biri, CRM tablolarının hiçbir satırında geçiyor mu? (toplam eşleşme sayısı)
create or replace function pg_temp.pii_sayisi(p_desen text[])
returns int
language plpgsql
as $fn$
declare
  t  text;
  n  int;
  toplam int := 0;
begin
  foreach t in array array[
    'growth_households','growth_customer_people','growth_events','growth_message_log','growth_tasks',
    'growth_team_feed','growth_leads','growth_prospects','growth_prospect_events','growth_prospect_provenance',
    'growth_financial_transactions','growth_customer_addresses','growth_household_izinleri',
    'growth_identity_links','growth_students','growth_support_tickets','growth_opportunities',
    'growth_journey_enrollments','growth_subscription_projection','growth_ai_recommendations',
    'growth_entity_custom_values'
  ] loop
    execute format('select count(*) from public.%I x where to_jsonb(x)::text ilike any ($1)', t)
      into n using p_desen;
    toplam := toplam + n;
  end loop;
  return toplam;
end $fn$;

create or replace function pg_temp.growth_kvkk_testleri()
returns table (no int, senaryo text, gecti boolean, detay text)
language plpgsql
as $fn$
declare
  adm    uuid;
  v1 uuid; v2 uuid; v3 uuid; v4 uuid; v5 uuid; v6 uuid; v7 uuid;
  h1 uuid; h2 uuid; hs uuid; ht uuid; h5 uuid; h6 uuid; h7 uuid;
  jid uuid; j2 uuid; lid1 uuid; pid1 uuid; ogr uuid;
  l1 uuid; l2 uuid; l3 uuid; l4 uuid; p3 uuid; p4 uuid; p5 uuid;
  r jsonb; r2 jsonb; r3 jsonb;
  cnt int; cnt2 int; n_once int; n_sonra int;
  msg text; s text; calls text[];
  ok boolean; ok2 boolean;
  desen text[] := array['%Zeynep%', '%kvkk1.veli%', '%Deniz%'];
  desen_s text[] := array['%Kaynak Ali%', '%kvkk4.kaynak%'];
begin
  no := 0;
  adm := gen_random_uuid();
  insert into auth.users (id, email) values (adm, 'kvkk.admin@example.test');
  insert into public.profiles (id, role, full_name) values (adm, 'admin', 'Yönetici Test');

  -- ---------------------------------------------------------------
  -- 1. Anonimleştirme: tüm CRM kayıtları silinir, kişisel alan kalmaz
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Anonimleştirme: hane ve bağlı CRM kayıtları silinir, hiçbir tabloda kişisel alan kalmaz';
  gecti := false; detay := null;
  begin
    v1 := pg_temp.veli_olustur('kvkk1.veli@example.test', 'Zeynep Kaya');
    h1 := pg_temp.hane_of(v1);
    ogr := pg_temp.ogrenci_olustur(v1, 'Deniz', 5::smallint);
    insert into public.growth_events (household_id, event_name, source, properties)
      values (h1, 'test_olay', 'web', '{"not":"Zeynep test"}');
    insert into public.growth_message_log (household_id, channel, status, consent_snapshot)
      values (h1, 'email', 'sent', '{}');
    insert into public.growth_journeys (name) values ('KVKK test yolculuğu') returning id into jid;
    insert into public.growth_journey_enrollments (journey_id, household_id) values (jid, h1);
    insert into public.growth_tasks (household_id, title, task_type, due_at)
      values (h1, 'Zeynep ara', 'call', now());
    insert into public.growth_team_feed (household_id, feed_type, body) values (h1, 'note', 'Zeynep ile görüştük');
    insert into public.growth_support_tickets (id, household_id, subject, category)
      values ('DST-KVKK-1', h1, 'Zeynep sorunu', 'account');
    insert into public.growth_leads (parent_name, email, stage, household_id)
      values ('Zeynep Kaya', 'kvkk1.veli@example.test', 'qualified', h1) returning id into lid1;
    insert into public.growth_prospects (prospect_no, display_name, first_name, email, source_type, origin, source_name, converted_lead_id)
      values ('PRS-KVKK-1', 'Zeynep Kaya', 'Zeynep', 'kvkk1.veli@example.test', 'website_form', 'first_party', 'test', lid1)
      returning id into pid1;
    insert into public.growth_prospect_events (prospect_id, event_type, source, title, properties)
      values (pid1, 'form', 'web', 'Zeynep formu', '{"email":"kvkk1.veli@example.test"}');

    perform pg_temp.giris(adm);
    r := public.admin_growth_hane_anonimlestir(h1, 'KVKK silme talebi (test)');

    select count(*) into cnt from public.growth_households where id = h1;
    n_once := pg_temp.pii_sayisi(desen);
    select count(*) into cnt2 from public.growth_prospects
     where prospect_no = 'PRS-KVKK-1' and status = 'suppressed' and display_name = 'Silinmiş kayıt';

    gecti := cnt = 0 and n_once = 0 and cnt2 = 1
             and (r ->> 'household_id')::uuid = h1
             and (r -> 'silinen' ->> 'kisi')::int >= 1
             and (r -> 'silinen' ->> 'olay')::int >= 1
             and (r -> 'silinen' ->> 'mesaj')::int = 1
             and (r -> 'silinen' ->> 'gorev')::int = 1
             and (r -> 'silinen' ->> 'lead')::int = 1;
    detay := format('hane_kaldi=%s pii=%s prospect_suppressed=%s silinen=%s', cnt, n_once, cnt2, r -> 'silinen');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 2. Anonimleştirme sonrası liste ve detayda görünmez
  no := no + 1;
  senaryo := 'Anonimleştirilen hane 360 listesinde ve detayında görünmez';
  gecti := false; detay := null;
  begin
    perform pg_temp.giris(adm);
    r2 := public.admin_musteri_360_listele('Zeynep', null, null, 25, 0, null, null);
    msg := pg_temp.hata(format('select public.admin_musteri_360_detay(%L)', h1));
    gecti := (r2 ->> 'total')::int = 0 and msg like 'P0002%' and msg like '%bulunamadı%';
    detay := format('liste_toplam=%s detay=%s', r2 ->> 'total', msg);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- 3. Denetim satırı PII içermez (silme kaydı)
  no := no + 1;
  senaryo := 'Anonimleştirme denetim satırı: işlem kaydı var, PII (ad, e-posta, neden metni) yok';
  gecti := false; detay := null;
  begin
    select count(*) into cnt from public.admin_audit_log a
     where a.islem = 'musteri_hanesi_anonimlestirildi' and a.detay ->> 'household_id' = h1::text
       and a.detay::text not ilike any (array['%Zeynep%', '%kvkk1%', '%Deniz%', '%@%', '%KVKK silme%']);
    gecti := cnt = 1;
    detay := format('temiz_denetim_satiri=%s', cnt);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 4. Aktif ücretli abonelik varken reddedilir
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Aktif ücretli abonelik varken anonimleştirme reddedilir (anlamlı hata, hane kalır)';
  gecti := false; detay := null;
  begin
    v2 := pg_temp.veli_olustur('kvkk2.veli@example.test', 'Ahmet Demir');
    h2 := pg_temp.hane_of(v2);
    insert into public.plans (kod, ad, fiyat_kurus, sure_gun, aktif, tip_kod)
      values ('kvkk-aylik', 'Aylık test', 9900, 30, true, 'premium');
    insert into public.subscriptions (veli_id, plan_kod, durum, baslangic, bitis)
      values (v2, 'kvkk-aylik', 'aktif', now(), now() + interval '30 days');

    perform pg_temp.giris(adm);
    msg := pg_temp.hata(format('select public.admin_growth_hane_anonimlestir(%L, %L)', h2, 'test silme'));
    select count(*) into cnt from public.growth_households where id = h2;
    gecti := msg like '23514%' and msg like '%Aktif ücretli abonelik%' and cnt = 1;
    detay := format('hata=%s hane_kaldi=%s', msg, cnt);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 5. Admin olmayan: beş RPC reddedilir; anon yetkisi kapalı
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Admin olmayan kullanıcı beş RPC''de de reddedilir (42501) ve anon execute yetkisi yok';
  gecti := false; detay := null;
  begin
    v3 := pg_temp.veli_olustur('kvkk3.veli@example.test', 'Admin Olmayan');
    perform pg_temp.giris(v3);
    calls := array[
      format('select public.admin_growth_hane_anonimlestir(%L, %L)', h2, 'test silme'),
      format('select public.admin_growth_hane_disa_aktar(%L)', h2),
      format('select public.admin_growth_hane_birlestir(%L, %L)', h2, gen_random_uuid()),
      format('select public.admin_growth_lead_haneye_bagla(%L, null)', gen_random_uuid()),
      format('select public.admin_growth_hane_sahip_ata(%L, null)', h2)
    ];
    cnt := 0;
    foreach s in array calls loop
      msg := pg_temp.hata(s);
      if msg like '42501%' then cnt := cnt + 1; end if;
    end loop;
    ok2 := not has_function_privilege('anon', 'public.admin_growth_hane_anonimlestir(uuid,text)', 'execute')
       and not has_function_privilege('anon', 'public.admin_growth_hane_disa_aktar(uuid)', 'execute')
       and not has_function_privilege('anon', 'public.admin_growth_hane_birlestir(uuid,uuid)', 'execute')
       and not has_function_privilege('anon', 'public.admin_growth_lead_haneye_bagla(uuid,uuid)', 'execute')
       and not has_function_privilege('anon', 'public.admin_growth_hane_sahip_ata(uuid,uuid)', 'execute')
       and not has_function_privilege('anon', 'public.export_my_data()', 'execute');
    gecti := cnt = 5 and ok2;
    detay := format('reddedilen=%s anon_kapali=%s', cnt, ok2);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 6. Birleştirme: sayılar, izin AND kuralı, e-posta tekilliği, kaynak gizlenir
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Birleştirme: taşınan sayılar doğru, izin kısıtlayıcı olanla kalır, kaynak soft-delete ve gizli';
  gecti := false; detay := null;
  begin
    v4 := pg_temp.veli_olustur('kvkk4.hedef@example.test', 'Hedef Veli');
    ht := pg_temp.hane_of(v4);
    insert into public.growth_households (parent_name, email, lifecycle, customer_no, notes, tags, source)
      values ('Kaynak Ali', 'kvkk4.kaynak@example.test', 'lead', 'HUP-KVKK-S', '{"kaynak-not"}', '{"kaynak-etiket"}', 'web_form')
      returning id into hs;
    insert into public.growth_customer_people (household_id, person_role, first_name)
      values (hs, 'student', 'Kaynak Cocuk1'), (hs, 'parent', 'Kaynak Ali');
    insert into public.growth_events (household_id, event_name, source)
      values (hs, 'k1', 'web'), (hs, 'k2', 'web'), (hs, 'k3', 'web');
    insert into public.growth_message_log (household_id, channel, status, consent_snapshot)
      values (hs, 'email', 'sent', '{}');
    insert into public.growth_tasks (household_id, title, task_type, due_at)
      values (hs, 'g1', 'call', now()), (hs, 'g2', 'call', now());
    insert into public.growth_team_feed (household_id, feed_type, body) values (hs, 'note', 'kaynak notu');
    insert into public.growth_leads (household_id, parent_name, email, stage)
      values (hs, 'Kaynak Ali', 'kvkk4.kaynak@example.test', 'new');
    insert into public.growth_journeys (name) values ('Birleştirme yolculuğu 1') returning id into jid;
    insert into public.growth_journeys (name) values ('Birleştirme yolculuğu 2') returning id into j2;
    insert into public.growth_journey_enrollments (journey_id, household_id, entered_at)
      values (jid, hs, '2026-10-01 10:00+03'), (j2, hs, '2026-10-02 10:00+03'), (jid, ht, '2026-10-01 10:00+03');
    insert into public.growth_household_izinleri (household_id, channel, granted, source)
      values (hs, 'email', true, 'web_form'), (hs, 'sms', true, 'web_form'), (ht, 'email', false, 'admin');

    select count(*) into n_once from public.growth_events where household_id = ht;

    perform pg_temp.giris(adm);
    r := public.admin_growth_hane_birlestir(hs, ht);

    select count(*) into n_sonra from public.growth_events where household_id = ht;

    gecti :=
         (r -> 'tasinan' ->> 'kisi')::int = 2
     and (r -> 'tasinan' ->> 'olay')::int = 3
     and (r -> 'tasinan' ->> 'mesaj')::int = 1
     and (r -> 'tasinan' ->> 'gorev')::int = 2
     and (r -> 'tasinan' ->> 'ekip_notu')::int = 1
     and (r -> 'tasinan' ->> 'lead')::int = 1
     and (r -> 'tasinan' ->> 'not_dizisi')::int = 1
     and (r ->> 'journey_tekrar_silinen')::int = 1
     and n_sonra - n_once = 3
     and (select count(*) from public.growth_customer_people where household_id = ht) = 2
     and (select count(*) from public.growth_journey_enrollments where household_id = ht) = 2
     -- izin: email AND (true ∧ false = false); sms yalnız kaynakta vardı, kopyalanır
     and (select granted from public.growth_household_izinleri where household_id = ht and channel = 'email') = false
     and (select granted from public.growth_household_izinleri where household_id = ht and channel = 'sms') = true
     and (select count(*) from public.growth_household_izinleri where household_id = hs) = 0
     and (select merged_into from public.growth_households where id = hs) = ht
     and (select email from public.growth_households where id = hs) like 'birlesti-%@anonim.invalid'
     and (select count(*) from public.growth_households where lower(email) = 'kvkk4.hedef@example.test') = 1
     and (select notes from public.growth_households where id = ht) @> array['kaynak-not']::text[];
    detay := format('tasinan=%s dup=%s uyarilar=%s', r -> 'tasinan', r ->> 'journey_tekrar_silinen', r -> 'uyarilar');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  no := no + 1;
  senaryo := 'Birleştirilen kaynak 360 listesinde ve detayında görünmez; liste toplamı aktif hane sayısıdır';
  gecti := false; detay := null;
  begin
    perform pg_temp.giris(adm);
    r2 := public.admin_musteri_360_listele('', null, null, 100, 0, null, null);
    select count(*) into cnt from public.growth_households where merged_into is null;
    msg := pg_temp.hata(format('select public.admin_musteri_360_detay(%L)', hs));
    gecti := (r2 ->> 'total')::int = cnt and msg like '%bulunamadı%'
             and not (r2 -> 'rows')::text like '%birlesti-%';
    detay := format('liste_toplam=%s aktif=%s detay=%s', r2 ->> 'total', cnt, msg);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  no := no + 1;
  senaryo := 'Birleştirilen kaynak kişisel alan taşımaz (ad, e-posta, telefon temizlenir)';
  gecti := false; detay := null;
  begin
    select count(*) into cnt from public.growth_households x
     where x.id = hs and to_jsonb(x)::text ilike any (desen_s);
    select count(*) into cnt2 from public.growth_customer_people where first_name ilike 'Kaynak%';
    gecti := cnt = 0 and cnt2 = 2
             and (select parent_name from public.growth_households where id = hs) = 'Birleştirilmiş kayıt'
             and (select phone from public.growth_households where id = hs) is null;
    detay := format('kaynak_pii_satir=%s kisi_hedefte=%s', cnt, cnt2);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 8. Farklı core hesaplı haneler birleşmez; kendi kendine birleşme reddedilir
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'İki farklı core hesaplı hane birleşmez; aynı hane ile birleşme reddedilir';
  gecti := false; detay := null;
  begin
    v5 := pg_temp.veli_olustur('kvkk5.veli@example.test', 'Veli Beş');
    h5 := pg_temp.hane_of(v5);
    v6 := pg_temp.veli_olustur('kvkk6.veli@example.test', 'Veli Altı');
    h6 := pg_temp.hane_of(v6);
    perform pg_temp.giris(adm);
    msg := pg_temp.hata(format('select public.admin_growth_hane_birlestir(%L, %L)', h5, h6));
    msg := coalesce(msg, '') || ' | ' || coalesce(pg_temp.hata(format('select public.admin_growth_hane_birlestir(%L, %L)', h5, h5)), '');
    gecti := msg ilike '%farklı hesaba%' and msg ilike '%farklı hane%';
    detay := msg;
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 9. Lead won kancası ve elle lead→hane bağlama
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Lead won olunca e-posta eşleşmezse yeni hane üretilir; eşleşirse mevcut hane kullanılır';
  gecti := false; detay := null;
  begin
    v7 := pg_temp.veli_olustur('kvkk7.mevcut@example.test', 'Mevcut Veli');
    h7 := pg_temp.hane_of(v7);
    perform pg_temp.giris(adm);
    insert into public.growth_leads (parent_name, email, stage)
      values ('Aday Ayşe', 'kvkk7.aday@example.test', 'qualified') returning id into l1;
    insert into public.growth_leads (parent_name, email, stage)
      values ('Mevcut Veli', 'kvkk7.mevcut@example.test', 'contacted') returning id into l2;
    perform public.admin_lead_asama(l1, 'won');
    perform public.admin_lead_asama(l2, 'won');

    gecti :=
         (select household_id from public.growth_leads where id = l1) is not null
     and (select lifecycle from public.growth_households
           where id = (select household_id from public.growth_leads where id = l1)) = 'lead'
     and (select count(*) from public.growth_households where lower(email) = 'kvkk7.aday@example.test') = 1
     and (select household_id from public.growth_leads where id = l2) = h7
     and (select count(*) from public.growth_households where lower(email) = 'kvkk7.mevcut@example.test') = 1;
    detay := format('l1_hane=%s l2_hane=%s beklenen_h7=%s',
                    (select household_id from public.growth_leads where id = l1),
                    (select household_id from public.growth_leads where id = l2), h7);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  no := no + 1;
  senaryo := 'Prospect üzerinden elle bağlama: lead''e hane üretir veya verilen haneye bağlar; lead''siz prospect reddedilir';
  gecti := false; detay := null;
  begin
    perform pg_temp.giris(adm);
    insert into public.growth_leads (parent_name, email, stage)
      values ('Prospect Adayı', 'kvkk7.prospect@example.test', 'new') returning id into l3;
    insert into public.growth_prospects (prospect_no, display_name, email, source_type, origin, source_name, converted_lead_id)
      values ('PRS-KVKK-3', 'Prospect Adayı', 'kvkk7.prospect@example.test', 'website_form', 'first_party', 'test', l3)
      returning id into p3;
    r := public.admin_growth_lead_haneye_bagla(p3, null);

    insert into public.growth_leads (parent_name, email, stage)
      values ('Elle Bağlanan', 'kvkk7.elle@example.test', 'new') returning id into l4;
    insert into public.growth_prospects (prospect_no, display_name, email, source_type, origin, source_name, converted_lead_id)
      values ('PRS-KVKK-5', 'Elle Bağlanan', 'kvkk7.elle@example.test', 'website_form', 'first_party', 'test', l4)
      returning id into p5;
    r2 := public.admin_growth_lead_haneye_bagla(p5, h7);

    insert into public.growth_prospects (prospect_no, display_name, email, source_type, origin, source_name)
      values ('PRS-KVKK-4', 'Lead Yok', 'kvkk7.yok@example.test', 'website_form', 'first_party', 'test')
      returning id into p4;
    msg := pg_temp.hata(format('select public.admin_growth_lead_haneye_bagla(%L, null)', p4));

    gecti := (r ->> 'household_id') is not null and (r ->> 'olusturuldu') = 'true'
             and (select household_id from public.growth_leads where id = l3) = (r ->> 'household_id')::uuid
             and (r2 ->> 'household_id')::uuid = h7 and (r2 ->> 'olusturuldu') = 'false'
             and (select household_id from public.growth_leads where id = l4) = h7
             and msg like '23514%' and msg like '%henüz lead%';
    detay := format('r=%s r2=%s msg=%s', r, r2, msg);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 11. Hane sahibi: yalnız admin kullanıcı
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Hane sahibi admin kullanıcı kimliğiyle atanır (owner_name otomatik), veli atanamaz, boşaltılabilir';
  gecti := false; detay := null;
  begin
    perform pg_temp.giris(adm);
    r := public.admin_growth_hane_sahip_ata(h7, adm);
    cnt := (select count(*) from public.growth_households
             where id = h7 and owner_user_id = adm and owner_name = 'Yönetici Test');
    msg := pg_temp.hata(format('select public.admin_growth_hane_sahip_ata(%L, %L)', h7, v7));
    r2 := public.admin_growth_hane_sahip_ata(h7, null);
    gecti := cnt = 1 and (r ->> 'owner_name') = 'Yönetici Test'
             and msg like '22023%' and msg like '%yalnızca admin%'
             and (select owner_user_id from public.growth_households where id = h7) is null
             and (select owner_name from public.growth_households where id = h7) is null;
    detay := format('atama=%s veli_red=%s', r, msg);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 12. KVKK dışa aktarma: bölümler ve denetim
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Dışa aktarma: hane, kişiler, olaylar, izinler, mesajlar, ödemeler bölümleri var; denetim satırı yazılır';
  gecti := false; detay := null;
  begin
    perform pg_temp.giris(adm);
    r := public.admin_growth_hane_disa_aktar(ht);
    select count(*) into cnt from public.admin_audit_log a
     where a.islem = 'musteri_veri_disa_aktarildi' and a.detay ->> 'household_id' = ht::text;
    gecti := r ? 'hane' and r ? 'kisiler' and r ? 'olaylar' and r ? 'izinler'
             and r ? 'mesajlar' and r ? 'odemeler' and r ? 'abonelik'
             and jsonb_array_length(r -> 'kisiler') = 2
             and cnt = 1;
    detay := format('anahtarlar_tamam=%s denetim=%s kisi=%s',
                    (r ? 'hane' and r ? 'odemeler'), cnt, jsonb_array_length(r -> 'kisiler'));
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 13-14. export_my_data 'growth' bölümü
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'export_my_data: growth bölümü yalnız çağıranın hanesini taşır; kelime/okuma/profil anahtarları korunur';
  gecti := false; detay := null;
  begin
    perform pg_temp.giris(v4);
    r := public.export_my_data();
    select count(*) into cnt from public.growth_events where household_id = ht;
    gecti := r ? 'growth' and r ? 'kelime' and r ? 'okuma' and r ? 'profil'
             and jsonb_array_length(r -> 'growth' -> 'olaylar') = cnt
             and (r -> 'growth' -> 'hane' ->> 'musteri_no') is not null
             and (r -> 'growth') ->> 'izinler' is not null
             and position('@' in (r -> 'growth')::text) = 0;
    detay := format('growth_olay=%s beklenen=%s', jsonb_array_length(r -> 'growth' -> 'olaylar'), cnt);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  no := no + 1;
  senaryo := 'export_my_data: başka kullanıcının hanesi sızmaz; hanesi olmayan kullanıcıda growth boş';
  gecti := false; detay := null;
  begin
    perform pg_temp.giris(v3);
    r3 := public.export_my_data();
    select count(*) into cnt from public.growth_events
     where household_id = pg_temp.hane_of(v3);
    perform pg_temp.giris(adm);
    r2 := public.export_my_data();
    gecti := jsonb_array_length(r3 -> 'growth' -> 'olaylar') = cnt
             and (r3 -> 'growth' -> 'olaylar')::text not like '%test_olay%'
             and (r2 -> 'growth' -> 'hane') = 'null'::jsonb
             and jsonb_array_length(r2 -> 'growth' -> 'olaylar') = 0;
    detay := format('v3_olay=%s admin_hane=%s', jsonb_array_length(r3 -> 'growth' -> 'olaylar'), r2 -> 'growth' -> 'hane');
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 15. Birleştirilmiş kayıt doğrudan silinemez; kısa neden reddedilir
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Birleştirilmiş kayıt anonimleştirilemez; 3 karakterden kısa neden reddedilir';
  gecti := false; detay := null;
  begin
    perform pg_temp.giris(adm);
    msg := pg_temp.hata(format('select public.admin_growth_hane_anonimlestir(%L, %L)', hs, 'test silme'));
    msg := coalesce(msg, '') || ' | ' || coalesce(pg_temp.hata(format('select public.admin_growth_hane_anonimlestir(%L, %L)', h5, 'x')), '');
    gecti := msg like '%Birleştirilmiş kayıt%' and msg like '%Silme nedeni 3-500%';
    detay := msg;
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;

  -- ---------------------------------------------------------------
  -- 16. Denetim satırları (yeni işlemler) PII içermez
  -- ---------------------------------------------------------------
  no := no + 1;
  senaryo := 'Yeni işlem denetim satırlarında ad, e-posta veya neden metni yok';
  gecti := false; detay := null;
  begin
    -- Desen anahtar adlarına değil kişisel DEĞERLERE bakar (ör. "kaynak_id", "anonimlestirilen_prospect" eşleşmez).
    select count(*) into cnt from public.admin_audit_log a
     where a.islem in ('musteri_hanesi_anonimlestirildi', 'musteri_haneleri_birlestirildi',
                       'musteri_veri_disa_aktarildi', 'lead_haneye_baglandi', 'musteri_sahibi_atandi')
       and (a.detay::text like '%@%' or a.detay::text ilike any (array['%Zeynep%', '%Kaynak Ali%', '%Aday Ayşe%',
                                                                      '%Mevcut Veli%', '%Ahmet%', '%Elle Bağlanan%',
                                                                      '%Prospect Adayı%', '%Birleştirilmiş kayıt%']));
    gecti := cnt = 0;
    detay := format('pii_iceren_satir=%s', cnt);
  exception when others then
    detay := 'HATA: ' || sqlerrm;
  end;
  return next;
end
$fn$;
