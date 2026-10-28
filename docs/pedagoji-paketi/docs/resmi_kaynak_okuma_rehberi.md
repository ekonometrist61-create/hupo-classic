# MEB kaynak tarama protokolü — sınıf × ders × mod

**Her içerik üretimi öncesi:** `data/source_registry.json` içindeki MEB portal ve program yılını karşılaştır. TYMM sekmesinde sınıf görünmesini uygulamaya delil sayma. Ders kitaplarında 1–8 sınıfın yalnız güncel programla eşleşen kitaplarını seç; 4/8 önceki program üzerinden çalış.

**Soru analizinde en az şu sütunlar:** `source, year, school_year, grade, subject, page, outcome, item_format, stimulus_format, text_length, inferential_steps, reasoner_action, misconception, options_anatomy, estimated_difficulty, validity_notes, excluded_reason`. 1–4 için yazılılardan çok ders içi biçimlendirici ölçme örnekleri; 5–8 için ilgili yıl ortak yazılı/İOKBS/LGS ayrımı.

**Kopyasız ilk okuma:** önce soru kitapçığında temsil, yönerge, akıl yürütme, çeldirici *özelliklerini* kaydet; metin ve seçenekleri saklama. Grafik/fotoğrafa telif ve kaynak etiketi ekle; benzersiz yeni veri/şekil üret.

**Saha referansı örnekleri:** 2026 İOKBS 8. sınıf Türkçe soruları; çok anlamlı sözcük, metindeki söz öbeği, neden-sonuç, söz sanatı, çıkarım, olumsuz köklü metin soruları gibi çeşitli madde biçimleri barındırır. Tek sayfa örnekle gerçek frekans dağılımı hesaplama. 2026 OYSS öncesi açık uçlu soru-rubrik tasarımı için 20.10.2026 MEB duyurusu kullan.

**Yayılma kapsamı:** Bütün MEB kitaplarını otomatik 'okundu' sayma. Gerekli ders/sınıf öğrenme çıktıları ve resmî soru sayfaları için kaynak-id/page içeren ayrı çalışma dökümü tut. Resmî öğrenme çıktısı işaretleri yalnız doğrulanmış kayıtlarla eklenir.
