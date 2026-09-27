-- =====================================================================
-- Doğru şıkkı istemciden gizle
-- Öğrenci uygulaması soruları doğrudan okur; dogru_sik sütununu okuyamamalı.
-- Cevap kontrolü yalnızca public.submit_answer() (SECURITY DEFINER) ile yapılır.
-- =====================================================================

set client_encoding = 'UTF8';

-- Tablo düzeyindeki SELECT yetkisini kaldır, dogru_sik dışındaki sütunlara ver
revoke select on public.questions from authenticated;

grant select (
  id, okul, ders, konu, alt_konu, zorluk, soru_metni, siklar,
  onay_durumu, created_at, updated_at
) on public.questions to authenticated;

-- Not: artık istemcide "select *" yerine sütun listesi kullanılmalı.
-- service_role ve SECURITY DEFINER fonksiyonlar bu kısıttan etkilenmez.
