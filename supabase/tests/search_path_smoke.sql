-- =====================================================================
-- GÖR-004 DUMAN TESTİ (canlı veya yerel Postgres; yazmaz)
--
-- 17 fonksiyonu gerçek şemada çağırır. Tüm çağrılar tek bir DO bloğunda çalışır ve sonunda
-- bilerek hata fırlatılır: böylece her yazma geri alınır, hiçbir veri kalıcı olmaz.
-- Sonuç, fırlatılan hata mesajında döner ("SONUC: ...").
--
-- Kriter: search_path kaynaklı hatalar FAIL sayılır (42P01 tablo yok, 42883 fonksiyon yok,
-- 42704 tip yok). İş kuralı hataları (yetkisiz, bulunamadı, geçersiz girdi) beklenen davranıştır.
--
-- Çalıştırma: supabase db query --linked -f supabase/tests/search_path_smoke.sql
-- =====================================================================

do $$
declare
  v_veli  uuid := (select id from public.profiles where role = 'veli' limit 1);
  v_ogr   uuid := (select id from public.profiles where role = 'ogrenci' limit 1);
  v_sonuc text := '';
begin
  perform set_config('request.jwt.claims', json_build_object('sub', coalesce(v_veli, v_ogr))::text, true);

  -- Her çağrı ayrı blokta: biri hata verirse sonraki denenir.
  begin perform public.telefon_normalize('0555 111 22 33'); v_sonuc := v_sonuc || 'telefon_normalize:OK ';
  exception when others then v_sonuc := v_sonuc || 'telefon_normalize:' || sqlstate || ' '; end;

  begin perform public.get_my_characters(); v_sonuc := v_sonuc || 'get_my_characters:OK ';
  exception when others then v_sonuc := v_sonuc || 'get_my_characters:' || sqlstate || ' '; end;

  begin perform public.ogretmen_siniflarim(); v_sonuc := v_sonuc || 'ogretmen_siniflarim:OK ';
  exception when others then v_sonuc := v_sonuc || 'ogretmen_siniflarim:' || sqlstate || ' '; end;

  begin perform public.join_challenge('ZZZZZZ'); v_sonuc := v_sonuc || 'join_challenge:OK ';
  exception when others then v_sonuc := v_sonuc || 'join_challenge:' || sqlstate || ' '; end;

  begin perform public.create_challenge(); v_sonuc := v_sonuc || 'create_challenge:OK ';
  exception when others then v_sonuc := v_sonuc || 'create_challenge:' || sqlstate || ' '; end;

  begin perform public.set_active_character('yok_kod'); v_sonuc := v_sonuc || 'set_active_character:OK ';
  exception when others then v_sonuc := v_sonuc || 'set_active_character:' || sqlstate || ' '; end;

  begin perform public.create_parent_link_code(); v_sonuc := v_sonuc || 'create_parent_link_code:OK ';
  exception when others then v_sonuc := v_sonuc || 'create_parent_link_code:' || sqlstate || ' '; end;

  begin perform public.redeem_parent_link_code('000000'); v_sonuc := v_sonuc || 'redeem_parent_link_code:OK ';
  exception when others then v_sonuc := v_sonuc || 'redeem_parent_link_code:' || sqlstate || ' '; end;

  begin perform public.telefon_kod_uret(v_veli, '05551112233'); v_sonuc := v_sonuc || 'telefon_kod_uret:OK ';
  exception when others then v_sonuc := v_sonuc || 'telefon_kod_uret:' || sqlstate || ' '; end;

  begin perform public.telefon_kod_dogrula('123456'); v_sonuc := v_sonuc || 'telefon_kod_dogrula:OK ';
  exception when others then v_sonuc := v_sonuc || 'telefon_kod_dogrula:' || sqlstate || ' '; end;

  -- Admin fonksiyonları gövdeye ancak admin oturumuyla girer; rol kontrolünü geçmek için.
  perform set_config('request.jwt.claims', json_build_object('sub', (select id from public.profiles where role = 'admin' limit 1))::text, true);

  begin perform public.admin_list_siniflar(null, null, null, 10, 0); v_sonuc := v_sonuc || 'admin_list_siniflar:OK ';
  exception when others then v_sonuc := v_sonuc || 'admin_list_siniflar:' || sqlstate || ' '; end;

  begin perform public.admin_upsert_sinif(null, 'Test', 5, null, null, 2026, true); v_sonuc := v_sonuc || 'admin_upsert_sinif:OK ';
  exception when others then v_sonuc := v_sonuc || 'admin_upsert_sinif:' || sqlstate || ' '; end;

  begin perform public.admin_sinif_ogrenci_ekle(gen_random_uuid(), gen_random_uuid()); v_sonuc := v_sonuc || 'admin_sinif_ogrenci_ekle:OK ';
  exception when others then v_sonuc := v_sonuc || 'admin_sinif_ogrenci_ekle:' || sqlstate || ' '; end;

  begin perform public.admin_sinif_ogrenci_cikar(gen_random_uuid(), gen_random_uuid()); v_sonuc := v_sonuc || 'admin_sinif_ogrenci_cikar:OK ';
  exception when others then v_sonuc := v_sonuc || 'admin_sinif_ogrenci_cikar:' || sqlstate || ' '; end;

  begin perform public.admin_send_notification('test', 'test', 'bell', null, 'ogrenci'); v_sonuc := v_sonuc || 'admin_send_notification:OK ';
  exception when others then v_sonuc := v_sonuc || 'admin_send_notification:' || sqlstate || ' '; end;

  begin perform public.admin_list_notifications(10, 0); v_sonuc := v_sonuc || 'admin_list_notifications:OK ';
  exception when others then v_sonuc := v_sonuc || 'admin_list_notifications:' || sqlstate || ' '; end;

  begin perform public.characters_after_change(); v_sonuc := v_sonuc || 'characters_after_change:OK ';
  exception when others then v_sonuc := v_sonuc || 'characters_after_change:' || sqlstate || ' '; end;

  -- Tüm sonucu bilerek fırlat: her şey geri alınır.
  raise exception 'SONUC: %', v_sonuc;
end
$$;
