-- TASLAK, UYGULANMADI (2026-10-29). Kullanıcı onayı olmadan supabase/migrations'a taşınmaz.
-- Amaç: görselli sorular için questions tablosuna görsel alanları eklemek.
-- Yetki modeli: 20260920000300_hide_correct_answer.sql ile aynı. Tablo düzeyinde select yok;
-- sütun listesiyle okuma var. gorsel_spec (cevap ipucu taşır) öğrenciye HİÇ açılmaz.

alter table public.questions
  add column if not exists gorsel_svg       text,
  add column if not exists gorsel_alt_metin text,
  add column if not exists gorsel_tip       text,
  add column if not exists gorsel_spec      jsonb;

-- SVG boyut sınırı (lint 30 KB ile aynı); boş olabilir.
alter table public.questions drop constraint if exists questions_gorsel_svg_boyut;
alter table public.questions add constraint questions_gorsel_svg_boyut
  check (gorsel_svg is null or octet_length(gorsel_svg) <= 30000);

-- Alt metin zorunluluğu: görsel varsa alt metin de olmalı (erişilebilirlik).
alter table public.questions drop constraint if exists questions_gorsel_alt_metin_zorunlu;
alter table public.questions add constraint questions_gorsel_alt_metin_zorunlu
  check (gorsel_svg is null or (gorsel_alt_metin is not null and length(trim(gorsel_alt_metin)) > 0));

-- İstemci yetkisi: yalnız görsel (svg, alt metin, tip). gorsel_spec YOK.
grant select (gorsel_svg, gorsel_alt_metin, gorsel_tip) on public.questions to authenticated;

-- Not: gorsel_spec yalnız admin RPC ve service_role ile okunur (SECURITY DEFINER).
-- Yazma: admin_import_questions_v2 bu alanları henüz bilmiyor. Görselli paket için
-- ayrı bir RPC (v3) gerekir; o taslak bu dosyada değil, migrasyon onayından sonra yazılır.
