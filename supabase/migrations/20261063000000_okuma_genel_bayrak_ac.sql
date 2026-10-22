-- =====================================================================
-- Okuma Dünyası — genel özellik bayrağını aç (kullanıcı onayıyla, 2026-10-22).
--   * Şu an canlıda yalnızca sahibinin uygulaması var; genel açılış bu nedenle güvenli.
--   * Hikâye kataloğu yalnız "yayinda" sürümleri gösterir; bayrak açılınca modül görünür,
--     ama yayınlanmış hikâye yoksa boş kalır. Yayın ayrı bir karardır.
-- =====================================================================

update public.okuma_ayarlari
   set deger = 'true'::jsonb,
       guncellendi_at = now()
 where anahtar = 'aktif';

do $bayrak$
begin
  if not exists (select 1 from public.okuma_ayarlari where anahtar = 'aktif' and deger = 'true'::jsonb) then
    raise exception 'genel bayrak açılamadı';
  end if;
end
$bayrak$;
