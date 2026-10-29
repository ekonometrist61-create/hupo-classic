-- =====================================================================
-- kullanim_olaylari_gonder: ANON / AUTHENTICATED YETKİSİ KALDIRILIR (W8a)
--
-- 20261066000000 bu RPC'yi anon ve authenticated'a açmıştı. IP hız sınırı yoktu; sınır yalnızca
-- istemci üretimli oturum anahtarına bağlıydı. Sahte veri göndermek admin kullanım raporunu zehirleyebiliyordu.
-- Artık tek giriş noktası Edge Function'dır (IP hız sınırı → service_role):
--   kullanim-izle → kullanim_olaylari_gonder
--
-- UYGULAMA SIRASI: önce edge function deploy + web/mobil istemci yayını; yoksa eski istemciler veri kaybeder.
--   1. Edge Function deploy edilir (JWT doğrulaması kapalı):
--        supabase functions deploy kullanim-izle --no-verify-jwt
--   2. Web sitesi/panel ve mobil uygulama yeni sürümle yayınlanır (KullanimSuresi.tsx ve kullanim_suresi.dart
--      artık kullanim-izle'i çağırır).
--   3. Bu migration uygulanır. Önce uygulanırsa eski istemcilerin gönderdiği olaylar sessizce düşer.
--
-- Kullanıcı onayı olmadan uygulanmaz. Uzak veritabanına uygulama, migration sahipliği kuralına tabidir.
-- Tekrar çalıştırılması güvenlidir (revoke/grant idempotent).
-- =====================================================================

revoke all on function public.kullanim_olaylari_gonder(jsonb) from public, anon, authenticated;
grant execute on function public.kullanim_olaylari_gonder(jsonb) to service_role;
