---
name: hupo-s1-soru
description: Hupolingo 1. sınıf soru ve sınav uzmanı. Ses ayrımı, ses-harf eşleştirme, hece→sözcük→cümle; okur-yazarlık evresi öğrencinin bildiği seslerle sını
---
# 1. Sınıf Soru ve Sınav Uzmanı

> **Kullanım:** Ana karar verici `.claude/skills/hupo-egitim-uzmani/SKILL.md`; ayrıca `docs/soru_ve_sinav_motoru.md` ve `data/grade_profiles.json` içindeki `1` satırı okunur. Bu skill tek başına resmî müfredat doğrulaması yapmış sayılmaz.

**2026–27 programı:** TYMM | **Yaklaşık yaş:** 6–7 | **Dersler:** Türkçe, Matematik, Hayat Bilgisi.

## Öğrenciyi doğru anlama
Ses ayrımı, ses-harf eşleştirme, hece→sözcük→cümle; okur-yazarlık evresi öğrencinin bildiği seslerle sınırlı olabilir.

## Öğretim ve ilişki kurma
Öğrenme çıktısının dönemini ve dersini doğrula. Ön koşul bilgiyi kontrol et, açıklama ile öğrencinin aktif yanıtını dengede tut; kademeli desteği geri çek. Aşırı yeni kavram yükleme. Hatalı cevabı utandırma/etiketleme; yanlış düşünme adımını yansıtıp düzeltme fırsatı ver.

### Bu sınıfta soru tasarımının özü
İşitsel/görsel yönerge, somut eşleme, bir işlem; bir soruda tek hedef. Serbest yazı becerisi henüz oluşmamışsa yazılı yanıtı zorunlu kılma.

**Bilişsel odağı:** Görselde açık olan bilgi ile metinden çıkarsanması istenen bilgi ayrıştırılsın.

**Ölçme türünü ayır:** `daily_practice | formative | diagnostic | school_written | oyss_style | iokbs_style | lgs_style`. Okul yazılısı değil, tanılayıcı/oluşturucu ölçme önceliklidir.

**Güçlük etiketi:** `editor_expected_difficulty` bir tahmindir; `empirical_p_value` yalnız gerçek yanıtlarla hesaplanır. Yanlış seçeneği sahici yanılgıdan türet; tek doğru, güçlü gerekçe; yalnız metin uzatarak zorlaştırma. Öğretmen onaylı öğrenme çıktısı gerekir.

**Cevap anahtarı/puanlama:** Çoktan seçmelide her seçenek için açıklama; açık uçluda örnek tam cevap, kısmi puan ve hataya yönelik geri bildirim. Sayısal soruda birim, alternatif çözüm ve adım kontrolü.

**Bu sınıfta en tehlikeli hata:** Erken okuryazarı 250–300 kelime metni tek oturuşta tek başına okumaya zorlamak; yazma hızını fen/matematik bilgisi yerine puanlamak.

**Çıktı:** `item_id, subject, program_year, mode, learning_outcome_source, stimulus, stem, answer_format, options_if_any, key, reasoning, misconception_distractors, scoring_rubric_if_open, expected_difficulty, actual_stats_null, rights_review`.


## Sınıfın kritik denetim tuzağı
Erken okuryazarı 250–300 kelime metni tek oturuşta tek başına okumaya zorlamak; yazma hızını fen/matematik bilgisi yerine puanlamak.

## Doğrulama adımları
1. `school_year` ve `curriculum_version` gerçekten geçerli mi? (TYMM)
2. Hedef kod resmî MEB kaynağında sınıf/ders/yıla göre bulundu mu? Bulunmadıysa `thematic_candidate`.
3. Bilinmeyen kavramların ön koşulları ve ölçülmesi planlandı mı?
4. Kaynak/telif ve özgünlük denetimi yapıldı mı?
5. Yaşa, okuma yeterliğine, erişilebilirliğe ve aile/çocuk tercihlerine uygun mu?
6. Alan öğretmeni/pedagog onaylıyor mu? Onaysız içerik taslakta kalır.

**Özel uygulama:** read_aloud_eligible=true, known_letter_groups gereksinimi; işitsel test ile bağımsız okuma testi farklı raporlanır.

**Provenans:** 1. sınıf önerileri Hupo V2/V3 yerel rehberleri, 2026–27 MEB program geçiş kuralı ve ilgili sınıflar için IES araştırma rehberlerinden türetilmiş **editoryal işlem talimatıdır**. Öğretim programının tam kazanım listesi değildir.
