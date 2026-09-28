-- =====================================================================
--  Yardımcı fonksiyonların yetkileri (yetki sıkılaştırma)
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  NEDEN?
--    PostgreSQL, yeni fonksiyonlarda EXECUTE yetkisini varsayılan olarak
--    PUBLIC'e verir. Bu yüzden şu üç yardımcı, diskteki migration'larda
--    revoke edilmediği için anon ve authenticated rollerine AÇIK kaldı:
--
--      public.set_updated_at()     → updated_at trigger'ı
--      public.tr_normalize(text)   → Türkçe arama normalizasyonu
--      public.hafta_baslangic()    → liglerin hafta başlangıcı
--
--    tools/kurtarma-sql-denetim.ps1 bu üçünü "revoke yok" diye bildirdi.
--    (Aynı denetim, diğer tüm fonksiyonlarda revoke/grant satırlarını buldu.)
--
--  RİSK DEĞERLENDİRMESİ (revoke'un bir şeyi bozmadığının kanıtı):
--    * set_updated_at() RETURNS trigger: doğrudan çağrılamaz
--      ("trigger functions can only be called as triggers"). Trigger'lar
--      EXECUTE yetkisi aramadan çalıştığı için revoke güvenlidir.
--    * tr_normalize() ve hafta_baslangic() yalnızca başka SQL fonksiyonlarının
--      İÇİNDEN çağrılır; o fonksiyonlar SECURITY DEFINER olduğu için
--      çalışma anında yetki kontrolü sahibe (postgres) göre yapılır.
--      Doğrulama: mobile-app/lib ve web-panel/src içinde bu adlara yapılan
--      istemci çağrısı YOK (yalnızca rpc() çağrıları tarandı →
--      tools/istemci-rpc-denetimi.ps1: 0 eksik).
--    * authenticated'e EXECUTE veriliyor: testler 'set role authenticated'
--      ile bu fonksiyonları çağırabiliyor (ör. league_notifications_tests.sql
--      hafta_baslangic() kullanır), davranış değişmesin.
--
--  Kural (AGENTS.md §4): yeni fonksiyon → revoke + grant satırı zorunlu.
-- =====================================================================

set client_encoding = 'UTF8';

-- updated_at trigger'ı: yalnızca trigger olarak çalışır, doğrudan çağrı imkânsız
revoke execute on function public.set_updated_at() from public, anon, authenticated;

-- Türkçe normalizasyon: yalnızca SECURITY DEFINER fonksiyonlar kullanır
revoke execute on function public.tr_normalize(text) from public, anon;
grant  execute on function public.tr_normalize(text) to authenticated;

-- Hafta başlangıcı: yalnızca lig RPC'leri ve testler kullanır
revoke execute on function public.hafta_baslangic() from public, anon;
grant  execute on function public.hafta_baslangic() to authenticated;
