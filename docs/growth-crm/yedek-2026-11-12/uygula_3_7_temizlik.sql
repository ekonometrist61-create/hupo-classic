-- 3–7 içerik temizliği (K-0260). ÇALIŞTIRMADAN ÖNCE kullanıcı onayı gerekir.
-- Geri alma: yedek JSON dosyalarındaki id ve önceki durum ile:
--   update public.okuma_hikaye_surumleri set durum = 'yayinda' where id in (...);
--   update public.kelime_sorulari set durum = 'yayinda' where id in (...);
-- Silme yok; yalnız durum değişir.

begin;
update public.okuma_hikaye_surumleri set durum = 'arsiv' where durum = 'yayinda' and (sinif_alt < 3 or sinif_ust > 7);
update public.kelime_sorulari set durum = 'incelemede' where durum = 'yayinda' and (sinif < 3 or sinif > 7);
commit;

select 'okuma_yayinda_kalan_disi' as k, count(*) from public.okuma_hikaye_surumleri where durum = 'yayinda' and (sinif_alt < 3 or sinif_ust > 7)
union all
select 'kelime_yayinda_kalan_disi', count(*) from public.kelime_sorulari where durum = 'yayinda' and (sinif < 3 or sinif > 7)
union all
select 'okuma_site_ozeti_hikaye', (public.okuma_site_ozeti() ->> 'hikaye_sayisi')::int;
