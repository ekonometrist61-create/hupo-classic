-- =====================================================================
-- GÜVENLİK SERTLEŞTİRME: RPC YETKİLERİ (TASKS.md §11.3)
--
-- 1) evaluate_characters(uuid): yalnızca characters_after_change trigger'ı
--    tarafından çağrılıyor. İstemci (mobil / web) bu fonksiyonu doğrudan
--    çağırmıyor. Authenticated bir kullanıcı başka bir öğrencinin id'siyle
--    çağırabiliyordu (yatay ayrıcalık). Yetki kaldırıldı.
--    Trigger fonksiyonu SECURITY DEFINER olduğu için iç çağrı fonksiyon
--    sahibinin yetkisiyle yapılır; trigger yolu etkilenmez.
-- 2) characters_after_change(): trigger fonksiyonu; istemciden çağrılmaz.
-- Not: admin_* RPC'lerinde anon/PUBLIC EXECUTE yetkisi canlıda zaten yok
-- (20260920000900 içindeki döngü kaldırmıştı; 2026-10-10 canlı proacl ile doğrulandı).
-- Bu nedenle bu dosyada admin RPC'lerine dokunulmuyor.
-- =====================================================================

revoke execute on function public.evaluate_characters(uuid)
  from public, anon, authenticated;

revoke execute on function public.characters_after_change()
  from public, anon, authenticated;
