-- =====================================================================
-- VELİ ADAYI RPC'Sİ: YALNIZCA SERVİS ROLÜ (TASKS.md §16.2)
--
-- Önceden anon ve authenticated doğrudan çağırabiliyordu; captcha ve IP
-- sınırı bu yolu atlatabiliyordu. Artık tek giriş noktası Edge Function
-- veli-adayi-kayit'tir (captcha + hız sınırı → service_role ile bu RPC).
--
-- DEPLOY SIRASI (kırılmayı önlemek için):
--   1. Edge Function veli-adayi-kayit deploy edilir (CAPTCHA_SECRET ayarlı).
--   2. Web sitesi yeni sürümle yayınlanır (ErkenErisimSection Edge'i çağırır).
--   3. Bu migration uygulanır. Bunu önce yaparsanız erken erişim formu çalışmaz.
-- =====================================================================

revoke execute on function public.veli_adayi_olustur(text, text, text, text, boolean) from anon, authenticated;
grant  execute on function public.veli_adayi_olustur(text, text, text, text, boolean) to service_role;
