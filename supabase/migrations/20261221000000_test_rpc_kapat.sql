-- =====================================================================
--  Test arka kapısını kapat: ogrenci_test_gorselli_sorular
--  Tarih : 2026-11-12
--  Karar : K-0257 / GÖR-114 (ajan kararı; kullanıcı "tüm işleri bitir" dedi)
--  Bulgu : Fonksiyon gövdesinde sabit bir test hesabı e-postası var ve o hesaba yayınlanmamış
--          (onay_durumu = 'beklemede') görselli soruları döndürüyor. Yalnızca Flutter test
--          derlemesinde (--dart-define=GORSELLI_TEST=true) çağrılıyor. Canlıda kapalı olmalı.
--
--  NE YAPIYOR? authenticated'ın EXECUTE yetkisini geri alır. service_role ve sahip erişimi
--  korunur. Gövde değişmez.
--
--  GERİ AÇMA (yalnız görsel soru testi yapılacaksa, işi bitince tekrar kapat):
--    grant execute on function public.ogrenci_test_gorselli_sorular(text) to authenticated;
-- =====================================================================

revoke execute on function public.ogrenci_test_gorselli_sorular(text) from public, anon, authenticated;
