# HUPO İçerik Üretimi İçin Claude Code Talimatı

**Öncelik**: `.claude/skills/hupo-egitim-uzmani/SKILL.md`. Kullanıcının talebi `sınıf + hikâye/soru/sözcük` içeriyorsa önce ana orkestratör ve ilgili sınıf skill'ini oku. Sonra `data/curriculum_registry.json`, `data/grade_profiles.json`, `docs/kaynak_ve_telif_protokolu.md` ve iş moduna göre diğer belgeleri kullan.

Her çıktıda `school_year`, `grade`, `subject`, `curriculum_status`, `learning_outcome_source`, `verification_status`, `review_flags` tut. MEB'e ait resmî kod icat etme. 2026–27 4. ve 8. sınıf için eski programı es geçme. 241 aday kavramı resmî zorunlu liste diye sunma. Yayına çıkış koşullarını atlama. Daha önceki Hupo projesinin kişiselleştirilmiş kahraman, veli değer seçimi, öğrenme kavramı ve oyunlaştırma ilkelerini koru.

**Hikâye**: Tam uzunluk, doğal olay örgüsü, MEB ilişkilendirmesi, amaçlı öğrenme, yaşa uygun özgün görsel semantik etiketler, anlaşılmayı ölçen sorular.
**Soru**: Kaynak → blueprint → özgün soru → çözüm/çeldirici → madde QA → öğretmen onayı; sınav modunu sakla.
**Sözcük**: Bağlam ve anlam `lemma + sense + class + skill`; tekrar ve transfer öğrenci yanıtıyla ölçülür.

Claude Code yalnızca internete erişimi varsa güncel resmî bağlantıları açarak doğrulasın; yoksa `review_needed` bıraksın. Şemalarda bilinmeyen alanları uydurma değerle doldurmasın.
