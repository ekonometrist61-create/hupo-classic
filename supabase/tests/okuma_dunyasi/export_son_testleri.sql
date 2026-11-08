-- GÖR-048: export_my_data SON tanımı (20261106) gerçek okuma + kelime zinciri üstünde.
-- Okuma/kelime bölümleri testler.sql'deki senaryolarla (son tanım yüklüyken) sınanır; burada growth bölümü,
-- anahtar bütünlüğü ve yetki kapısı sınanır. Sonuç: pg_temp.export_son_testleri().
create or replace function pg_temp.exs_giris(p_uid uuid) returns void language plpgsql as $f$
begin
  perform set_config('request.jwt.claims', json_build_object('sub', p_uid, 'role', 'authenticated')::text, false);
  perform set_config('role', 'authenticated', false);
end $f$;
create or replace function pg_temp.exs_cikis() returns void language plpgsql as $f$
begin perform set_config('role', 'none', false); perform set_config('request.jwt.claims', '', false); end $f$;

create or replace function pg_temp.export_son_testleri()
returns table (no int, senaryo text, gecti boolean, detay text)
language plpgsql as $f$
declare
  ua uuid := gen_random_uuid(); ub uuid := gen_random_uuid(); uc uuid := gen_random_uuid();
  ha uuid; hb uuid; hm uuid;
  ex jsonb; n int := 0; hata text;
begin
  insert into auth.users (id, email) values (ua, 'son-a@t.local'), (ub, 'son-b@t.local'), (uc, 'son-c@t.local');
  insert into public.profiles (id, role, full_name) values (ua, 'veli', 'Veli A'), (ub, 'veli', 'Veli B'), (uc, 'veli', 'Veli C');
  insert into public.growth_households (core_parent_user_id, customer_no, lifecycle, plan, subscription_status)
    values (ua, 'MUSTERI-A-001', 'active', 'free', 'none') returning id into ha;
  insert into public.growth_households (core_parent_user_id, customer_no, lifecycle, plan, subscription_status)
    values (ub, 'MUSTERI-B-002', 'active', 'free', 'none') returning id into hb;
  insert into public.growth_households (core_parent_user_id, customer_no, merged_into) values (uc, 'MUSTERI-M-003', ha) returning id into hm;
  insert into public.growth_events (household_id, event_name, source) values (ha, 'olay_a', 'web'), (hb, 'olay_b_gizli', 'web');
  insert into public.growth_consent_bridge (household_id, channel, granted, source) values (ha, 'email', true, 'form'), (hb, 'sms', true, 'form');
  insert into public.growth_message_log (household_id, channel, status) values (ha, 'email', 'sent'), (ha, 'email', 'sent'), (ha, 'email', 'failed'), (hb, 'sms', 'sent');

  perform pg_temp.exs_giris(ua); ex := public.export_my_data(); perform pg_temp.exs_cikis();

  n := n + 1; no := n; senaryo := 'son tanım: önceki tüm üst düzey anahtarlar korunur, growth eklenir';
  gecti := ex ?& array['olusturulma_tarihi','profil','istatistikler','cevaplar','rozetler','bildirimler','xp_gecmisi','onaylar','kelime','okuma','growth'];
  detay := (select string_agg(k, ',') from jsonb_object_keys(ex) k); return next;

  n := n + 1; no := n; senaryo := 'son tanım: kelime ve okuma bölümleri alt anahtarlarıyla sağlam';
  gecti := (ex -> 'kelime') ?& array['denemeler','ustaliklar','kaydedilenler']
       and (ex -> 'okuma') ?& array['oturumlari','cevaplari','geri_bildirimleri','ogrenci_hedef_durumu','pdf_kullanimlari','cocuk_tercihleri'];
  detay := (select string_agg(k, ',') from jsonb_object_keys(ex -> 'okuma') k); return next;

  n := n + 1; no := n; senaryo := 'growth: yalnız çağıranın hanesi (müşteri no, olay, izin); başka hane sızmaz';
  gecti := ex #>> '{growth,hane,musteri_no}' = 'MUSTERI-A-001'
       and jsonb_array_length(ex #> '{growth,olaylar}') = 1
       and jsonb_array_length(ex #> '{growth,izinler}') = 1
       and position('MUSTERI-B-002' in ex::text) = 0 and position('olay_b_gizli' in ex::text) = 0 and position('MUSTERI-M-003' in ex::text) = 0;
  detay := (ex -> 'growth')::text; return next;

  n := n + 1; no := n; senaryo := 'growth: mesaj günlüğü yalnız kanal/durum/adet özetidir (3 satırdan 2 grup, toplam 3)';
  gecti := jsonb_array_length(ex #> '{growth,mesaj_gunlugu_ozeti}') = 2
       and (ex #> '{growth,mesaj_gunlugu_ozeti}') @> '[{"kanal":"email","durum":"sent","adet":2}]'::jsonb
       and (ex #> '{growth,mesaj_gunlugu_ozeti}') @> '[{"kanal":"email","durum":"failed","adet":1}]'::jsonb;
  detay := (ex #> '{growth,mesaj_gunlugu_ozeti}')::text; return next;

  -- Haneye birleştirilmiş (merged_into dolu) kullanıcının kendi hanesi yok sayılır
  perform pg_temp.exs_giris(uc); ex := public.export_my_data(); perform pg_temp.exs_cikis();
  n := n + 1; no := n; senaryo := 'growth: birleştirilmiş hane çıktıya girmez; hane null, listeler boş';
  gecti := ex #> '{growth,hane}' = 'null'::jsonb and ex #> '{growth,olaylar}' = '[]'::jsonb
       and ex #> '{growth,izinler}' = '[]'::jsonb and ex #> '{growth,mesaj_gunlugu_ozeti}' = '[]'::jsonb
       and position('MUSTERI-A-001' in ex::text) = 0;
  detay := (ex -> 'growth')::text; return next;

  -- Oturumsuz çağrı
  begin
    perform pg_temp.exs_cikis(); perform public.export_my_data(); hata := 'hata yok';
  exception when others then hata := sqlstate || ':' || sqlerrm; end;
  n := n + 1; no := n; senaryo := 'son tanım: oturumsuz çağrı 42501 ile reddedilir';
  gecti := hata like '42501:%'; detay := hata; return next;

  n := n + 1; no := n; senaryo := 'son tanım: güvenlik definer, sabit search_path, anon kapalı / authenticated açık';
  gecti := (select p.prosecdef and exists (select 1 from unnest(p.proconfig) c where c like 'search_path=%') from pg_proc p where p.proname = 'export_my_data' and p.pronamespace = 'public'::regnamespace)
       and not has_function_privilege('anon', 'public.export_my_data()', 'execute')
       and has_function_privilege('authenticated', 'public.export_my_data()', 'execute');
  detay := (select array_to_string(p.proconfig, ';') from pg_proc p where p.proname = 'export_my_data' and p.pronamespace = 'public'::regnamespace);
  return next;
end $f$;