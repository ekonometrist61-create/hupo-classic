-- =====================================================================
--  Premium paket özellik listesi: kanıtsız iki madde çıkarılıyor
--  Tarih : 2026-11-12
--  Karar : K-0258 (FK-006 satış temas noktaları)
--  Neden : "Veli paneli" — panel erişimi plana bağlı değil (loadVeliAccess yalnız
--          rol/oturum kontrol eder; ücretsiz veli de kullanır). "Reklamsız, güvenli
--          ortam" — reklam kapatma yapılandırması plana bağlı değil (ad_config sunucu
--          bayrağına bakar). Plana bağlı olmayan şeyi Premium avantajı diye satmak
--          yanıltıcı olur.
--  Etki  : yalnız plan_tipleri.premium satırının ozellikler / ozellikler_en dizileri.
--          Yönetici panelinden değiştirilmiş listelerde madde yoksa değişiklik olmaz.
--          Fiyat, paket ve kota verisine dokunulmaz. Tekrar çalıştırmak zararsızdır.
-- =====================================================================

update public.plan_tipleri
   set ozellikler    = array_remove(array_remove(ozellikler, 'Veli paneli'), 'Reklamsız, güvenli ortam'),
       ozellikler_en = array_remove(array_remove(ozellikler_en, 'Parent dashboard'), 'Ad-free, secure environment')
 where kod = 'premium';
