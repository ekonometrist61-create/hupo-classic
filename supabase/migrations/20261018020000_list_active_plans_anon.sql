-- =====================================================================
--  Landing fiyat bölümü girişsiz ziyaretçiye de görünsün.
--  list_active_plans yalnızca aktif paketlerin kod, ad, açıklama, fiyat ve süresini
--  döndürür (hassas alan yok). 20260920001100 migration'ı bu fonksiyonu anon'dan
--  geri almıştı; landing ise sunucu tarafında anon rolüyle çağırdığı için 401 alıyordu.
-- =====================================================================

grant execute on function public.list_active_plans() to anon;
