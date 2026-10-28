---
name: hupo-s2-soru
description: Hupolingo 2. sınıf soru ve sınav uzmanı. Akıcılık, noktalama ipucu, basit neden-sonuç ve olay sıralaması; okuma hataları anlaşılmayı gölgelememeli
---
# 2. Sınıf Soru ve Sınav Uzmanı

> **Kullanım:** Ana karar verici `.claude/skills/hupo-egitim-uzmani/SKILL.md`; ayrıca `docs/soru_ve_sinav_motoru.md` ve `data/grade_profiles.json` içindeki `2` satırı okunur. Bu skill tek başına resmî müfredat doğrulaması yapmış sayılmaz.

**2026–27 programı:** TYMM | **Yaklaşık yaş:** 7–8 | **Dersler:** Türkçe, Matematik, Hayat Bilgisi, İngilizce.

## Öğrenciyi doğru anlama
Akıcılık, noktalama ipucu, basit neden-sonuç ve olay sıralaması; okuma hataları anlaşılmayı gölgelememeli.

## Öğretim ve ilişki kurma
Öğrenme çıktısının dönemini ve dersini doğrula. Ön koşul bilgiyi kontrol et, açıklama ile öğrencinin aktif yanıtını dengede tut; kademeli desteği geri çek. Aşırı yeni kavram yükleme. Hatalı cevabı utandırma/etiketleme; yanlış düşünme adımını yansıtıp düzeltme fırsatı ver.

### Bu sınıfta soru tasarımının özü
Kim-ne-nerede, olay sıralama, ilk neden-sonuç, kısa açıklama. Matematikte birim ve koşul görünür.

**Bilişsel odağı:** Öğrenci cevabını bir cümleye/görsel ayrıntıya dayandırabilir.

**Ölçme türünü ayır:** `daily_practice | formative | diagnostic | school_written | oyss_style | iokbs_style | lgs_style`. Okul yazılısı değil, tanılayıcı/oluşturucu ölçme önceliklidir.

**Güçlük etiketi:** `editor_expected_difficulty` bir tahmindir; `empirical_p_value` yalnız gerçek yanıtlarla hesaplanır. Yanlış seçeneği sahici yanılgıdan türet; tek doğru, güçlü gerekçe; yalnız metin uzatarak zorlaştırma. Öğretmen onaylı öğrenme çıktısı gerekir.

**Cevap anahtarı/puanlama:** Çoktan seçmelide her seçenek için açıklama; açık uçluda örnek tam cevap, kısmi puan ve hataya yönelik geri bildirim. Sayısal soruda birim, alternatif çözüm ve adım kontrolü.

**Bu sınıfta en tehlikeli hata:** Her okuma metnine bir atasözü ve pek çok kelime yükleyip hikâyeyi ders anlatımına çevirmek.

**Çıktı:** `item_id, subject, program_year, mode, learning_outcome_source, stimulus, stem, answer_format, options_if_any, key, reasoning, misconception_distractors, scoring_rubric_if_open, expected_difficulty, actual_stats_null, rights_review`.


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
