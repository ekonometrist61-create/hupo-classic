# Customer-Lab spesifikasyonu (H-GIE Faz 6)

Durum: **taslak spec, kod yok.** Karar veren: proje sahibi (onay bekliyor). Tarih: 2026-10-28.

## 1. Amaç
Veli davranışı hakkında **hipotez** üretmek ve bunları gerçek A/B testlerine aday olarak listelemek. Customer-Lab bir kanıt kaynağı değildir. Çıktıları pazarlamada, fiyatlamada veya ürün kararında tek başına kullanılamaz.

Kapsam: persona hipotezleri, fiyat duyarlılığı senaryoları, onboarding alternatifleri, mağaza sayfası mesajları, kampanya mesajları, paket konumlandırma.

## 2. Kapsam dışı (kesin)
- Gerçek kullanıcı ölçümü üretmek veya gerçek tablolara yazmak.
- Sentetik sonucu "sosyal kanıt" olarak göstermek (proje kuralı: sahte sosyal kanıt yok).
- Çocuk verisiyle modelleme. Simülasyon girdisi çocuk düzeyinde değil, yalnız toplulaştırılmış dağılımlardır.
- Makine öğrenmesi modeli eğitmek (ML Faz 4 eşiğine tabidir).

## 3. Veri sınırı
- Girdi: yalnız toplulaştırılmış dağılımlar (örn. "tutulan oranı", "kanal payı"), en az 10 hane eşiğiyle. Ham satır yok.
- Sentetik kayıtlar yalnız `sentetik_` şemasında tutulur (`sentetik_kosu`, `sentetik_sonuc`). Bu şemaya gerçek veri tablolarından yazan hiçbir yol olmaz.
- Her koşu: tohum (seed), parametreler, sürüm ve tarih kaydedilir; aynı girdi aynı çıktıyı verir.

## 4. Model (ilk sürüm)
- Kural tabanlı, olasılıksal olmayan basit senaryo motoru: persona parametreleri × senaryo → beklenen aralık.
- Çıktı her zaman **aralık + belirsizlik** olur; tek sayı gösterilmez.
- ML yok. Eşik ve gerekçe Faz 4'te yeniden değerlendirilir.

## 5. Aşamalar
| Aşama | İçerik | Kabul |
|---|---|---|
| L0 | Bu spec ve veri sözleşmesi | Onay |
| L1 | Persona parametre kataloğu (gerçek dağılımlardan, eşik üstü) | Test: eşik altı hücre üretilmez |
| L2 | Fiyat duyarlılığı senaryo koşucusu | Test: aynı tohum aynı sonuç; çıktı aralık |
| L3 | Onboarding ve mesaj varyantları, A/B aday listesi | Test: sentetik ve gerçek şemalar ayrı |

## 6. Kabul ölçütleri
- Sentetik tablolardan gerçek tablolara hiçbir satır yazılmaz (test).
- Her çıktıda "hipotez" etiketi ve belirsizlik aralığı bulunur (test).
- Ekranda ve raporda Customer-Lab sonucu, gerçek A/B sonucu gibi sunulmaz (gözden geçirme).

## 7. Açık işler (bu spec'in dışında)
- Gerçek A/B motoru (randomizasyon, guardrail, çoklu karşılaştırma düzeltmesi) ayrı spec ile yazılır.
- Sentetik şema migration'ı L1'de, ayrı onayla deploy edilir.
