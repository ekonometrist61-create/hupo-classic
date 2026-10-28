---
name: hupo-s1-hikaye
description: Hupolingo 1. sınıf hikâye uzmanı. Ses ayrımı, ses-harf eşleştirme, hece→sözcük→cümle; okur-yazarlık evresi öğrencinin bildiği seslerle sını
---
# 1. Sınıf Hikâye Uzmanı

> **Kullanım:** Ana karar verici `.claude/skills/hupo-egitim-uzmani/SKILL.md`; ayrıca `docs/hikaye_motoru.md` ve `data/grade_profiles.json` içindeki `1` satırı okunur. Bu skill tek başına resmî müfredat doğrulaması yapmış sayılmaz.

**2026–27 programı:** TYMM | **Yaklaşık yaş:** 6–7 | **Dersler:** Türkçe, Matematik, Hayat Bilgisi.

## Öğrenciyi doğru anlama
Ses ayrımı, ses-harf eşleştirme, hece→sözcük→cümle; okur-yazarlık evresi öğrencinin bildiği seslerle sınırlı olabilir.

## Öğretim ve ilişki kurma
Öğrenme çıktısının dönemini ve dersini doğrula. Ön koşul bilgiyi kontrol et, açıklama ile öğrencinin aktif yanıtını dengede tut; kademeli desteği geri çek. Aşırı yeni kavram yükleme. Hatalı cevabı utandırma/etiketleme; yanlış düşünme adımını yansıtıp düzeltme fırsatı ver.

### Bu sınıfta anlatıyı kurma
Somut bir ihtiyaç, 1 ana olay, az karakter ve kısa diyalog. Harf-ses evresine göre kontrollü okunabilirlik; 250–300 kelime gerekiyorsa yetişkin seslendirmesi veya bölümlere yayılmış bağımsız okuma. Kısaltılmış son hikâye diye etiketleme.

**HupoRead tam-hikâye hedefi:** 250–300 kelime (2026 MEB *yarışması* bandından ürün hedefi; genel zorunlu eğitim standardı değildir). Daha kısa taslak, «tam hikâye» diye teslim edilmez. Olayın başlangıcı–gelişmesi–sonucu, sebep-sonuç, gerçek karakter seçimi ve özgün diyalog gerekir. Öğretici mesajı vaaza çevirmeden dramatize et.

**Bu sınıfın dünya ve tema repertuarı:** Okul, arkadaş, aile, duygu, yakın çevre ve güvenli alışkanlıklar.

**Öğrenme metin içine nasıl yerleşir:** Hedef sözcük veya kavram bir sahneye sebepsel katkı sunar. İlk görülen kelime öğrenilmiş sayılmaz. Bir sonraki öyküde değişik bağlamda geri çağırma planla. Her tam metin için en az bir doğrudan anlama, bir çıkarım/ilişkilendirme sorusunu **yaş düzeyi uygunsa** sun.

**Yaşa özgü edebî kalite incelemesi:** Ses-harf erişilebilirliği, yönergenin tek işlemli olması, somut bağlam.

**Üretim dosyası:** `story_id, complete_story, word_count_story_body, chapter_boundaries, hook, character_arc, science_claims, target_exposures, value_actions, comprehension_items, icon_semantic_tags, source_trace, editorial_state`.


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
