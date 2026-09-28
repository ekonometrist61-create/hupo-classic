-- =====================================================================
--  KURTARMA: public.questions tablosundaki eksik kolonlar
--  Proje : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih : 2026-09-27
--
--  KAYNAK (katalog çıktısı, TAHMİN YOK):
--    kurtarilan/cikti-bagimlilik.csv:142-158 → canlı questions kolonları
--      16. inceleme_gerekli | boolean  | null=NO | default=false
--      17. sinif            | smallint | null=NO
--    (Diski sıfırdan kuran şemada bu iki kolon yoktu; sıra numaraları
--     canlıdaki ordinal_position değerleridir.)
--
--  NEDEN GEREKLİ:
--    * inceleme_gerekli → 20260927000030'daki _refresh_question_flag() bu
--      kolonu YAZAR, report_question() onu çağırır. Kolon yokken çağrı
--      "column does not exist" hatası verir; "soru bildirme" çalışmaz.
--    * sinif → 20260927000030'daki admin_set_daily_challenge()
--      ("seçilen 5 soru aynı sınıfa ait olmalı") kuralını q.sinif üzerinden
--      uygular. 20260927000030:276-294 bu kolonu okur; kolon yokken
--      "günün sorusunu elle seç" yolu çalışmaz. Ayrıca yönetici soru
--      listesi (20260927000100) ve admin_get_question() q.sinif döndürür.
--
--  ⚠️ BİLİNÇLİ SAPMA — sinif yerelde NULLABLE:
--    Canlıda sinif NOT NULL'tur. Ancak diskte KURTARILMAMIŞ eski soru ekleme
--    yolu (20260920000900'daki admin_upsert_question) sinif değeri
--    GÖNDERMEZ; NOT NULL olsaydı o yol "null value in column sinif" ile
--    kırılırdı. Canlıdaki admin_upsert_question() ise iki eksik nesneye
--    bağlı olduğu için şu an kurtarılamaz:
--      * public.question_revisions (tablo; canlı gövdesi dökümde YOK)
--      * public._soru_anlik()      (yardımcı fonksiyon; dökümde YOK)
--    Sıra:
--      1) 20260927000100 → canlı admin_import_questions() kurtarılır, yeni
--         sorular sinif değeriyle eklenir ✓
--      2) question_revisions + _soru_anlik canlıdan alınır
--      3) o zaman burada:
--           alter table public.questions alter column sinif set not null;
--    Doğrulama sorgusu:
--      select column_name, data_type, is_nullable, column_default
--        from information_schema.columns
--       where table_schema = 'public' and table_name = 'questions'
--       order by ordinal_position;
-- =====================================================================

alter table public.questions
  add column if not exists inceleme_gerekli boolean not null default false;

alter table public.questions
  add column if not exists sinif smallint;

comment on column public.questions.inceleme_gerekli is
  'Aynı soru yeterli sayıda farklı kişi tarafından bildirildiğinde true olur (bkz. public._refresh_question_flag).';
comment on column public.questions.sinif is
  'Sorunun hedef sınıfı (1-12). Canlıda NOT NULL; yerelde geçici olarak NULLABLE (bkz. dosya başındaki not).';
