-- =====================================================================
-- Okuma Dünyası: canlı düzeltme (kullanıcı onayı 2026-10-24).
--   1) Test yayınındaki 12 hikâyenin yayında sürümleri arşive alınır. Bu sürümlerin
--      denetim alanı (ajan_a=pass, ajan_b=pass, insan=approved) 20261069 ile sahte yazılmıştı;
--      gerçekte iki pass ve insan okuması yoktu (K-0122, K-0123).
--   2) Arşive alınan sürümlerin denetim alanı gerçek duruma çekilir (pending).
--   3) Pilot sınıflar [4,5]; genel bayrak (aktif) açık kalır.
-- Kapsam dışı: 20261081 (search_path, GÖR-004) bu dosyada yoktur; ayrı onay bekler.
-- Güvenlik: sayılar beklenenden farklıysa işlem hata verip durur.
-- =====================================================================

do $geri_cek$
declare
  v_ids uuid[];
  v_n   integer;
begin
  -- Yayındaki sürüm denetim kaydı değiştirilemez (_okuma_surum_koru): önce arşive al, sonra denetimi düzelt.
  select array_agg(s.id) into v_ids
    from public.okuma_hikaye_surumleri s
    join public.okuma_hikayeleri h on h.id = s.hikaye_id
   where s.durum = 'yayinda'
     and h.slug in (
       'hr002-renkli-ucurtma', 'hr009-konusan-kalem-kutusu', 'hr014-yagmur-damlasinin-yolculugu',
       'hr015-tohumun-kucuk-sirri', 'hr016-golgeyi-kim-buyuttu', 'hr018-deniz-fenerindeki-sinyal',
       'hr021-kayip-sandigin-sifresi', 'hr022-saat-kulesi-neden-durdu', 'hr025-bremen-yolcularinin-yeni-sarkisi',
       'hr030-ormanin-kaybolan-patikasi', 'hr031-muzede-sessiz-alarm', 'hr032-keloglan-ve-akilli-terazi')
     and s.denetim ->> 'ajan_a' = 'pass'
     and s.denetim ->> 'ajan_b' = 'pass'
     and s.denetim ->> 'insan' = 'approved';
  v_n := coalesce(array_length(v_ids, 1), 0);
  if v_n <> 12 then
    raise exception 'GERI_CEKME_BEKLENMEYEN_SAYI: %', v_n using errcode = '22023';
  end if;

  update public.okuma_hikaye_surumleri
     set durum = 'arsiv', arsiv_at = now()
   where id = any(v_ids);

  update public.okuma_hikaye_surumleri
     set denetim = '{"ajan_a":"pending","ajan_b":"pending","insan":"pending"}'::jsonb
   where id = any(v_ids);

  perform public.log_admin_action('okuma_test_yayini_geri_cekme', jsonb_build_object(
    'not', 'Kullanıcı onayı 2026-10-24: 12 test yayını arşive alındı. Denetim alanları gerçek duruma çekildi (iki pass ve insan onayı yoktu).',
    'hikaye_sayisi', 12));
end
$geri_cek$;

do $pilot$
declare
  v_n integer;
begin
  update public.okuma_ayarlari
     set deger = '[4,5]'::jsonb,
         guncellendi_at = now()
   where anahtar = 'pilot_siniflari';
  get diagnostics v_n = row_count;
  if v_n <> 1 then
    raise exception 'PILOT_AYARI_BULUNAMADI: %', v_n using errcode = '22023';
  end if;

  perform public.log_admin_action('okuma_pilot_siniflari', jsonb_build_object(
    'not', 'Kullanıcı onayı 2026-10-24: pilot sınıflar 4 ve 5. Genel bayrak açık kalır.',
    'pilot_siniflari', '[4,5]'));
end
$pilot$;
