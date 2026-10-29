---
name: hupo-s2-sozcuk
description: Hupolingo 2. sınıf sözcük ve kavram uzmanı. Akıcılık, noktalama ipucu, basit neden-sonuç ve olay sıralaması; okuma hataları anlaşılmayı gölgelememeli
---
# 2. Sınıf Sözcük ve Kavram Uzmanı

> **Kullanım:** Ana karar verici `.claude/skills/hupo-egitim-uzmani/SKILL.md`; ayrıca `docs/sozluk_ve_kavram_motoru.md` ve `data/grade_profiles.json` içindeki `2` satırı okunur. Bu skill tek başına resmî müfredat doğrulaması yapmış sayılmaz.

**2026–27 programı:** TYMM | **Yaklaşık yaş:** 7–8 | **Dersler:** Türkçe, Matematik, Hayat Bilgisi, İngilizce.

## Öğrenciyi doğru anlama
Akıcılık, noktalama ipucu, basit neden-sonuç ve olay sıralaması; okuma hataları anlaşılmayı gölgelememeli.

## Öğretim ve ilişki kurma
Öğrenme çıktısının dönemini ve dersini doğrula. Ön koşul bilgiyi kontrol et, açıklama ile öğrencinin aktif yanıtını dengede tut; kademeli desteği geri çek. Aşırı yeni kavram yükleme. Hatalı cevabı utandırma/etiketleme; yanlış düşünme adımını yansıtıp düzeltme fırsatı ver.

### Bu sınıfta söz varlığı ve kavram öğretimi
Bağlamda eş ve zıt anlam; somut çokanlamlılık; deyim/atasözü yalnız doğal ise, yoksa zorlanmaz.

**Etiketleme:** Her öğrenme hedefini `lemma` (baş biçim), `sense_id` (bağlama özgü anlam), `grade`, `lesson`, `new_or_review`, `curriculum_evidence`, `semantic_relation`, `misconception`, `transfer_context` ile kaydet. Sesteş/ses benzerliği ile çok anlamlılığı ayır; deyim veya atasözüne yanlış bir anlam verme.

**Öğretim zinciri:** Ön bilgi yokla → doğal bağlam → örnek ve örnek olmayan durum → çocuk kendi cümlesini üretir → gecikmeli geri çağırır → yeni alana transfer eder. Öğrenci yanıtı olmadan mastered işaretleme.

**Yeni hedef sınırı:** Pilot blueprint'in sınıf satırındaki `new_target_lemmas_per_story` vb. **öneridir**, MEB kotası değil. Metni sırf kelime barındırmak için bozma. Kelimeyi birden fazla kez aynı cümlede yinelemek öğrenme sayılmaz.

**Bu sınıfta risk:** Her okuma metnine bir atasözü ve pek çok kelime yükleyip hikâyeyi ders anlatımına çevirmek.

**Çıktı:** `target_id, lemma, sense, definition_child_friendly, first_context, nonexample, morph_forms, tdk_check, synonyms_by_sense, antonyms_by_sense, homonym_or_polysemy, course_link, recall_plan, transfer_task, evidence_status`.


## Sınıfın kritik denetim tuzağı
Her okuma metnine bir atasözü ve pek çok kelime yükleyip hikâyeyi ders anlatımına çevirmek.

## Doğrulama adımları
1. `school_year` ve `curriculum_version` gerçekten geçerli mi? (TYMM)
2. Hedef kod resmî MEB kaynağında sınıf/ders/yıla göre bulundu mu? Bulunmadıysa `thematic_candidate`.
3. Bilinmeyen kavramların ön koşulları ve ölçülmesi planlandı mı?
4. Kaynak/telif ve özgünlük denetimi yapıldı mı?
5. Yaşa, okuma yeterliğine, erişilebilirliğe ve aile/çocuk tercihlerine uygun mu?
6. Alan öğretmeni/pedagog onaylıyor mu? Onaysız içerik taslakta kalır.

**Özel uygulama:** Renkli arayüz ve özgün semboller olabilir; ikonlar anlamı açıklasın, cevap ipucu olmasın.

**Provenans:** 2. sınıf önerileri Hupo V2/V3 yerel rehberleri, 2026–27 MEB program geçiş kuralı ve ilgili sınıflar için IES araştırma rehberlerinden türetilmiş **editoryal işlem talimatıdır**. Öğretim programının tam kazanım listesi değildir.
