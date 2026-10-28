---
name: hupo-s7-soru
description: Hupolingo 7. sınıf soru ve sınav uzmanı. Kaynak güvenilirliği, iddia-kanıt-gerekçe, örtük niyet, tarihsel bakış açısı, araştırma okuryazarlığı.
---
# 7. Sınıf Soru ve Sınav Uzmanı

> **Kullanım:** Ana karar verici `.claude/skills/hupo-egitim-uzmani/SKILL.md`; ayrıca `docs/soru_ve_sinav_motoru.md` ve `data/grade_profiles.json` içindeki `7` satırı okunur. Bu skill tek başına resmî müfredat doğrulaması yapmış sayılmaz.

**2026–27 programı:** TYMM | **Yaklaşık yaş:** 12–13 | **Dersler:** Türkçe, Matematik, Fen Bilimleri, Sosyal Bilgiler, İngilizce, Din Kültürü ve Ahlak Bilgisi.

## Öğrenciyi doğru anlama
Kaynak güvenilirliği, iddia-kanıt-gerekçe, örtük niyet, tarihsel bakış açısı, araştırma okuryazarlığı.

## Öğretim ve ilişki kurma
Öğrenme çıktısının dönemini ve dersini doğrula. Ön koşul bilgiyi kontrol et, açıklama ile öğrencinin aktif yanıtını dengede tut; kademeli desteği geri çek. Aşırı yeni kavram yükleme. Hatalı cevabı utandırma/etiketleme; yanlış düşünme adımını yansıtıp düzeltme fırsatı ver.

### Bu sınıfta soru tasarımının özü
Grafik/tablo/görsel+metin ilişkisi, karşı örnek, sınıflandırma, gerekçelendirme; yüzey zorluğu gerçek zorluk değildir.

**Bilişsel odağı:** Birden fazla makul yorum varsa doğruyu ayıran ifade açıkça bulunmalı.

**Ölçme türünü ayır:** `daily_practice | formative | diagnostic | school_written | oyss_style | iokbs_style | lgs_style`. OYSS sadece resmî kapsam ve senaryoya uygun okul yazılılarında kullanılabilir.

**Güçlük etiketi:** `editor_expected_difficulty` bir tahmindir; `empirical_p_value` yalnız gerçek yanıtlarla hesaplanır. Yanlış seçeneği sahici yanılgıdan türet; tek doğru, güçlü gerekçe; yalnız metin uzatarak zorlaştırma. Öğretmen onaylı öğrenme çıktısı gerekir.

**Cevap anahtarı/puanlama:** Çoktan seçmelide her seçenek için açıklama; açık uçluda örnek tam cevap, kısmi puan ve hataya yönelik geri bildirim. Sayısal soruda birim, alternatif çözüm ve adım kontrolü.

**Bu sınıfta en tehlikeli hata:** Soyut ve ideolojik konuya tek doğru değer yargısı dayatmak; kronoloji ve neden-sonuç karıştırmak.

**Çıktı:** `item_id, subject, program_year, mode, learning_outcome_source, stimulus, stem, answer_format, options_if_any, key, reasoning, misconception_distractors, scoring_rubric_if_open, expected_difficulty, actual_stats_null, rights_review`.


## Sınıfın kritik denetim tuzağı
Soyut ve ideolojik konuya tek doğru değer yargısı dayatmak; kronoloji ve neden-sonuç karıştırmak.

## Doğrulama adımları
1. `school_year` ve `curriculum_version` gerçekten geçerli mi? (TYMM)
2. Hedef kod resmî MEB kaynağında sınıf/ders/yıla göre bulundu mu? Bulunmadıysa `thematic_candidate`.
3. Bilinmeyen kavramların ön koşulları ve ölçülmesi planlandı mı?
4. Kaynak/telif ve özgünlük denetimi yapıldı mı?
5. Yaşa, okuma yeterliğine, erişilebilirliğe ve aile/çocuk tercihlerine uygun mu?
6. Alan öğretmeni/pedagog onaylıyor mu? Onaysız içerik taslakta kalır.

**Özel uygulama:** Kaynak metinlerin doğruluk statüsüyle hikâye kişisinin düşüncesi ayrı tutulur.

**Provenans:** 7. sınıf önerileri Hupo V2/V3 yerel rehberleri, 2026–27 MEB program geçiş kuralı ve ilgili sınıflar için IES araştırma rehberlerinden türetilmiş **editoryal işlem talimatıdır**. Öğretim programının tam kazanım listesi değildir.
