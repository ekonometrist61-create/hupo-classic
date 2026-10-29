# 04 Marka ve Konumlandırma

Durum: Taslak · Tarih: 2026-10-29 · Rol: Marka ve Konumlandırma Stratejisti · Bağımlı: 03, 05, 06, 11, 19

## 1. Kilitli tanımlar (19'a kayıtlı)
- Marka: **Hupolingo**; maskot **Hupo** (altın sarı baykuş, krem yüz, mavi göz, yeşil kanat). Yeni karakter/lig/XP adı üretilmez.
- Hedef: veli (satın alan). Çocuk = kullanıcı; çocuğa ticari baskı yok.
- Konumlandırma: 03 §2. Ana mesaj: *küçük adım, görünür ilerleme, sakin güven.*

## 2. Konumlandırma haritası (2 eksen, Hipotez)
X: Duygusal ton (Sınav baskısı ↔ Sakin rutin). Y: Veli görünürlüğü (Düşük ↔ Yüksek).
- Kunduz/yayınevi akademileri: sınav baskısı, orta-yüksek görünürlük (koç/rapor).
- MEBİ: nötr/resmî, orta-yüksek görünürlük (e-Devlet).
- Oyunlaştırılmış ilkokul uygulamaları (doğrulanamadı): sakin/eğlenceli, düşük görünürlük.
- **Hupolingo hedef boşluk:** sakin rutin + yüksek veli görünürlüğü.

## 3. Mesaj mimarisi
| Katman | Metin (öneri) |
|---|---|
| Ana vaat | Çocuğunuz günde birkaç dakikada soru çözsün; siz neyi tekrar etmesi gerektiğini görün. |
| Kanıt 1 | Kısa görev (en fazla 10 soru varsayılan; 5–20 ayarlanır) |
| Kanıt 2 | Etiketli örnek veli raporu; az veriyle yüzde yok |
| Kanıt 3 | Çocuk alanında reklam yok, konum izni yok; veli onayı |
| Kanıt 4 | Tek seferlik ödeme, otomatik yenileme yok, ödeme öncesi ön bilgilendirme (yayında olunca) |
| Dürüst sınır | Sınav kazanma/puan artışı vaadi vermiyoruz. Pilot sürümdeyiz. |
| CTA (tek) | Örnek soruları dene |

## 4. Sesi ve ton kuralları
Güvenilir, sakin, akıllı, sıcak ama profesyonel; ünlemsiz; klişesiz. Kullanma: "çocuğunuz geride kalmasın", "fark yaratın", "garanti", "1 numara", "yapay zekâ ile özel ders", "bilimsel olarak kanıtlandı", "KVKK uyumlu", "ücretsiz deneme" (akış gerçek olana dek), "otomatik yenilenir". Çocuk metinleri: kısa, cesaretlendirici, bebek dili yok. Veli metinleri: somut fayda → kanıt → tek eylem.

## 5. Tek cümlelik konumlandırma seçenekleri (en çok 3 + öneri)
1. "Günlük soru çalışmasını küçük adımlara bölen, veliye ilerlemeyi gösteren uygulama." **(öneri)**
2. "Proje ortaokulu hazırlığında evde düzenli pratik."  (dar; resmî ortaklık riski)
3. "Çocuk için oyun hissi, veli için net rapor." (kısa, ama "oyun" kelimesi ebeveyni ürkütebilir; sosyal bio için)
Seçim: 1 ana site/mağaza; 3 sosyal bio; 2 yalnızca kampanya teması, okul adı olmadan.

## 6. Kanıt kaydı (görünür canlı iddialar için, `GROWTH_AND_MEASUREMENT.md` biçimi)
| İddia | Kaynak | Durum |
|---|---|---|
| Çocuk uygulamasında reklam varsayılan kapalı | `ads` ayarı + landing güven bölümü | Kanıtlı (kod/manifest taraması); test yok |
| Konum izni istenmez | AndroidManifest/Info.plist taraması | Kanıtlı |
| Cevap anahtarı sunucuda | RPC mimarisi | Kanıtlı (kod); bağımsız test yok |
| Tek seferlik ödeme | `payments-checkout`, K-0196 | Kanıtlı (kod); canlı değil |
| İçerik denetimi iki bağımsız denetçi + insan | Proje kuralı | **Kanıt kaydı gerekli**; yayınlanana dek kullanma |
| "MEB kazanımlarına göre hazırlanmış" | Müfredat etiket çalışması | Kısmen; 4. ve 8. sınıf hariç, kaynak görülünce |
| Kullanıcı sayısı / yorum / uzman | — | **Yok** |

## 7. Görsel tutarlılık
`BRAND_AND_VISUAL_RULES.md`: Teal (ana eylem) + Hupo Gold (maskot/XP) + Navy metin + Cream; Nunito. Sosyal şablon: krem zemin, navy metin, teal CTA şeridi, Hupo pozu köşede; Türkçe metin kodla bindirilir. Veli odaklı reklamda maskot küçük/yan; ödeme çağrılarında maskot yok. Çocuk fotoğrafı yok. AI ile çocuk yüzü yok.

## 8. Marka riskleri
Çocuk içeriği ile veli reklamının karışması; oyunlaştırmanın "oyun uygulaması" algısı; Hupo'nun bebeksi görünümü (9–11 yaş hissi korunur); "pilot" ifadesi güvensizlik mi dürüstlük mü yaratır — A/B değil niteliksel test (5 veli).
