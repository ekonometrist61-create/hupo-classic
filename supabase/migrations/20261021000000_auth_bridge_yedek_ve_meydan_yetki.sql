-- =====================================================================
-- TEMİZLİK (TASKS.md §11.7, kullanıcı onayı 2026-10-10)
--
-- 1) Auth bridge kaldırılıyor: exchange_auth_bridge_token / issue_auth_bridge_token
--    ve auth_bridge_tokens tablosu. Repoda ve bilinen uygulamalarda kullanılmıyordu;
--    anonim çağrıyla oturum bilgisi döndürebildiği için risk taşıyordu.
--    (Önceki migration 20261019000400 yalnızca yetkileri kapatmıştı.)
-- 2) questions_sinifsiz_yedek (yedek tablo) kaldırılıyor. Her soru sınıflı olmalı.
-- 3) _uret_meydan_kod() iç yardımcısından anon ve authenticated EXECUTE yetkisi
--    kaldırılıyor. Yalnızca create_challenge (SECURITY DEFINER) tarafından kullanılır.
--
-- Not: Bu migration 20261020* serisinden SONRA gelir (uzak geçmiş sırası için).
-- =====================================================================

drop function if exists public.exchange_auth_bridge_token(text);
drop function if exists public.issue_auth_bridge_token(text, text);
drop table if exists public.auth_bridge_tokens;

drop table if exists public.questions_sinifsiz_yedek;

revoke execute on function public._uret_meydan_kod() from public, anon, authenticated;
