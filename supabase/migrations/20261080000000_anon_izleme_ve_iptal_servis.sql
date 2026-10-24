-- =====================================================================
-- ANONİM RPC'LER: YALNIZCA SERVİS ROLÜ (GÖR-003)
--
-- growth_web_olay_kaydet, growth_web_kimlik_bagla ve iletisim_izni_iptal_et
-- anon ve authenticated tarafından doğrudan çağrılabiliyordu; IP hız sınırı yoktu.
-- Artık tek giriş noktası Edge Function'lar (IP hız sınırı → service_role):
--   growth-web-izle      → growth_web_olay_kaydet / growth_web_kimlik_bagla
--   iletisim-izni-iptal  → iletisim_izni_iptal_et
--
-- DEPLOY SIRASI (kırılmayı önlemek için; veli_adayi_olustur ile aynı desen):
--   1. Edge Function'lar deploy edilir (--no-verify-jwt):
--        supabase functions deploy growth-web-izle --no-verify-jwt
--        supabase functions deploy iletisim-izni-iptal --no-verify-jwt
--   2. Web sitesi yeni sürümle yayınlanır (erkenErisimIzleme.ts ve UnsubscribeForm.tsx
--      artık Edge Function'ları çağırır).
--   3. Bu migration uygulanır. Önce uygulanırsa erken erişim izleme sessizce düşer
--      ve e-posta iptal sayfası hata verir.
--
-- İptal bağlantısı imzasız kalır (bkz. iletisim-izni-iptal/index.ts); imzalı bağlantı ayrı karar.
-- =====================================================================

revoke execute on function public.growth_web_olay_kaydet(text, text, jsonb) from public, anon, authenticated;
grant  execute on function public.growth_web_olay_kaydet(text, text, jsonb) to service_role;

revoke execute on function public.growth_web_kimlik_bagla(text, text) from public, anon, authenticated;
grant  execute on function public.growth_web_kimlik_bagla(text, text) to service_role;

revoke execute on function public.iletisim_izni_iptal_et(text, text) from public, anon, authenticated;
grant  execute on function public.iletisim_izni_iptal_et(text, text) to service_role;
