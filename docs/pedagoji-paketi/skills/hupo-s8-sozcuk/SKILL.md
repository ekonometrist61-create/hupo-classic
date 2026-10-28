---
name: hupo-s8-sozcuk
description: Hupolingo 8. sınıf sözcük ve kavram uzmanı. LGS/okul sınavı ayrımı; eleştirel okuma, kanıt sentezi, ima, perspektif, problem çözme ve transfer.
---
# 8. Sınıf Sözcük ve Kavram Uzmanı

> **Kullanım:** Ana karar verici `.claude/skills/hupo-egitim-uzmani/SKILL.md`; ayrıca `docs/sozluk_ve_kavram_motoru.md` ve `data/grade_profiles.json` içindeki `8` satırı okunur. Bu skill tek başına resmî müfredat doğrulaması yapmış sayılmaz.

**2026–27 programı:** GECIS_ONCEKI_PROGRAM | **Yaklaşık yaş:** 13–14 | **Dersler:** Türkçe, Matematik, Fen Bilimleri, T.C. İnkılap Tarihi ve Atatürkçülük, Din Kültürü ve Ahlak Bilgisi, İngilizce.

## Öğrenciyi doğru anlama
LGS/okul sınavı ayrımı; eleştirel okuma, kanıt sentezi, ima, perspektif, problem çözme ve transfer.

## Öğretim ve ilişki kurma
Öğrenme çıktısının dönemini ve dersini doğrula. Ön koşul bilgiyi kontrol et, açıklama ile öğrencinin aktif yanıtını dengede tut; kademeli desteği geri çek. Aşırı yeni kavram yükleme. Hatalı cevabı utandırma/etiketleme; yanlış düşünme adımını yansıtıp düzeltme fırsatı ver.

### Bu sınıfta söz varlığı ve kavram öğretimi
Akademik/soyut kavram, bağlam içinde ince anlam farkları, söz sanatı, metinler arası kavram transferi.

**Etiketleme:** Her öğrenme hedefini `lemma` (baş biçim), `sense_id` (bağlama özgü anlam), `grade`, `lesson`, `new_or_review`, `curriculum_evidence`, `semantic_relation`, `misconception`, `transfer_context` ile kaydet. Sesteş/ses benzerliği ile çok anlamlılığı ayır; deyim veya atasözüne yanlış bir anlam verme.

**Öğretim zinciri:** Ön bilgi yokla → doğal bağlam → örnek ve örnek olmayan durum → çocuk kendi cümlesini üretir → gecikmeli geri çağırır → yeni alana transfer eder. Öğrenci yanıtı olmadan mastered işaretleme.

**Yeni hedef sınırı:** Pilot blueprint'in sınıf satırındaki `new_target_lemmas_per_story` vb. **öneridir**, MEB kotası değil. Metni sırf kelime barındırmak için bozma. Kelimeyi birden fazla kez aynı cümlede yinelemek öğrenme sayılmaz.

**Bu sınıfta risk:** 2026–27 TYMM 8. sınıf çıktılarını yürürlükte saymak; LGS soru tasarımını aşırı uzun metin üretmeye indirgemek.

**Çıktı:** `target_id, lemma, sense, definition_child_friendly, first_context, nonexample, morph_forms, tdk_check, synonyms_by_sense, antonyms_by_sense, homonym_or_polysemy, course_link, recall_plan, transfer_task, evidence_status`.


## Sınıfın kritik denetim tuzağı
2026–27 TYMM 8. sınıf çıktılarını yürürlükte saymak; LGS soru tasarımını aşırı uzun metin üretmeye indirgemek.

## Doğrulama adımları
1. `school_year` ve `curriculum_version` gerçekten geçerli mi? (GECIS_ONCEKI_PROGRAM)
2. Hedef kod resmî MEB kaynağında sınıf/ders/yıla göre bulundu mu? Bulunmadıysa `thematic_candidate`.
3. Bilinmeyen kavramların ön koşulları ve ölçülmesi planlandı mı?
4. Kaynak/telif ve özgünlük denetimi yapıldı mı?
5. Yaşa, okuma yeterliğine, erişilebilirliğe ve aile/çocuk tercihlerine uygun mu?
6. Alan öğretmeni/pedagog onaylıyor mu? Onaysız içerik taslakta kalır.

**Özel uygulama:** LGS yayın yılını ve o yılın 8. sınıf programını kullan; okul yazılısı ayrı mod.

**Provenans:** 8. sınıf önerileri Hupo V2/V3 yerel rehberleri, 2026–27 MEB program geçiş kuralı ve ilgili sınıflar için IES araştırma rehberlerinden türetilmiş **editoryal işlem talimatıdır**. Öğretim programının tam kazanım listesi değildir.
