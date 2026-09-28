-- =====================================================================
--  KURTARMA: public.get_app_config() — bakım modu / min sürüm / reklamlar
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  KAYNAK (canlı gövdeler, BİREBİR):
--    kurtarilan/cikti-kalan.csv  →  kurtarilan/parcalar/get_app_config.sql
--    (üretim aracı: tools/kurtarilan-govdeleri-cikar.ps1)
--  Yetkiler (aynı dökümün "-- secdef" satırı):
--    secdef: true | search_path="" | anon: true | auth: true | servis: true
--
--  NEDEN GEREKLİ:
--    Mobil uygulama açılışta bakım modunu, asgari sürümü ve reklam anahtarlarını
--    bu RPC'den okur. Kanıt: kurtarilan/KURTARMA_RAPORU.md:223
--    ("Provider: appConfigProvider, appConfigFetcherProvider. Alanlar:
--      bakim_modu, min_surum") ve mobile-app/lib/.../app_config.dart:3
--    ("Kaynak: public.get_app_config() RPC'si").
--    Fonksiyon diskte yoksa kayıp "bakım modu" ve "reklam" ekranları
--    çalışma zamanında 404 (function not found) alır.
--
--  BAĞIMLILIK: public.app_settings (20260920001100) — diskte VAR ✓
--    Anahtarlar: bakim_modu, min_surum, reklamlar. Satır yoksa fonksiyon
--    kendi güvenli varsayılanlarını döndürür (aşağıdaki coalesce'ler).
--    İstemci app_settings tablosunu doğrudan okumaz; bu yüzden
--    app_settings_select politikası (yalnızca premium_gating) DEĞİŞTİRİLMEDİ.
-- =====================================================================

create or replace function public.get_app_config()
returns jsonb
language sql
stable security definer
set search_path = ''
as $function$
  select jsonb_build_object(
    'bakim_modu', coalesce((select value from public.app_settings where key = 'bakim_modu'),
                           '{"aktif": false, "mesaj": ""}'::jsonb),
    'min_surum',  coalesce((select value from public.app_settings where key = 'min_surum'),
                           '{"android": "1.0.0", "ios": "1.0.0", "web": "1.0.0", "mesaj": ""}'::jsonb),
    'reklamlar',  coalesce((select value from public.app_settings where key = 'reklamlar'),
                           jsonb_build_object(
                             'veli_paneli_acik', false, 'ogrenci_acik', false,
                             'admob_app_id_android', null, 'admob_app_id_ios', null,
                             'admob_banner_id_android', null, 'admob_banner_id_ios', null,
                             'adsense_publisher_id', null, 'adsense_slot_id', null)));
$function$;

comment on function public.get_app_config() is
  'Uygulama yapılandırması: bakım modu, asgari sürüm ve reklam anahtarları. Girişsiz (anon) çağrılabilir.';

-- Yetkiler: canlı dökümde anon açık (uygulama girişten önce okur).
revoke execute on function public.get_app_config() from public;
grant  execute on function public.get_app_config() to anon, authenticated;
