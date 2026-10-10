-- =====================================================================
-- AUTH BRIDGE: ANONİM / OTURUMLU ERİŞİM KAPATILIYOR (TASKS.md §11.7)
--
-- exchange_auth_bridge_token(text) anonim olarak çağrılabiliyordu; 90 saniye geçerli,
-- tek kullanımlık bir token karşılığında access_token ve refresh_token döndürüyor.
-- Repoda hiçbir istemci bu akışı kullanmıyor (kullanıcı onayı: kullanılmıyor).
--
-- Bu migration yalnızca EXECUTE yetkisini service_role dışına kapatır.
-- Fonksiyonlar ve auth_bridge_tokens tablosu KALIR (geri alınabilir). Kaldırma,
-- ayrı bir migration ve ayrı onay ile yapılacak.
-- =====================================================================

revoke execute on function public.exchange_auth_bridge_token(p_token text)
  from public, anon, authenticated;

revoke execute on function public.issue_auth_bridge_token(p_access_token text, p_refresh_token text)
  from public, anon, authenticated;
