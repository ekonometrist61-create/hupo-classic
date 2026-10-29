# Rakip fiyatları ve Hupo fiyat önerisi (2026-10-29)

Kaynak notu: fiyatlar çoğunlukla üçüncü taraf sitelerden; resmi sayfalar doğrulanmadı. USD→TL 45 varsayımı. Hupo'nun gerçek plan fiyatı admin `plans` tablosunda; burada yok.

## Rakip tablosu (TL, KDV dahil varsayım)
| Ürün | Segment | Aylık | Yıllık | Not |
|---|---|---|---|---|
| Papağanca (4–11 İngilizce) | Çocuk dil | 149 | 899 | Kalıcı sürüm 1.499; canlı ders ayrı |
| Ev Okulu App | Okul öncesi/ilkokul | 149 | 1.299 (6 ay 749) | Deneme yok |
| Oynayoynaya | Okul öncesi | — | 4.750 / eğitim yılı | |
| Babil Kids | Canlı İngilizce | 399–799 | — | Canlı eğitmen, kıyas zor |
| Duolingo Super | Dil (yetişkin ağırlıklı) | 122–169 (kullanıcı bildirimi) | 969–1.199 (bildirim) | Resmi TL fiyat yok |
| Lingokids Plus | Çocuk dil | ~$15 | ~$72–90 (≈3.200–4.050) | Türkiye App Store fiyatı düşük olabilir |
| Prodigy Core / Ultra | Çocuk matematik | ~$10 / ~$20 | $59 / $119 (≈2.650 / 5.350) | Mart 2026 üçüncü taraf |
| Matific | Çocuk matematik | ~$10 | ~$80 (≈3.600) | Tahmini |
| Mathletics | Çocuk matematik | — | ~$99 (eski) | Doğrulanamadı |
| Socrates Dergi uygulaması | Türkçe/İngilizce okuma | — | 199,99 (2023) | Eski veri |
| Sınav deneme paketleri (LGS/TYT) | Sınav | — | 12.500 / 25 deneme (≈500/deneme); 5.500–7.400 abonelik | Paket satışı, uygulama üyeliği değil |

Türkçe çocuk/eğitim uygulaması için çapa: aylık 149 TL, yıllık 900–1.300 TL. Sınav hazırlığı için çapa çok daha yüksek.

## Hupo maliyet–başabaş (ortaksız taban, MALIYET_TABAN.md)
Net katkı ≈ 0,76 × P − 10 (P: yıllık KDV dahil fiyat; iade %5, sağlayıcı %4,2, KDV %20, değişken ~10 TL).

| Yıllık fiyat P | Net/hane | Başabaş ücretli oran, 2.000 öğrenci (sabit 216k) | Başabaş, 10.000 öğrenci (sabit 456k) |
|---|---|---|---|
| 899 | ~673 | %21 | %8,8 |
| 1.199 | ~901 | %16 | %6,6 |
| 1.499 | ~1.129 | %12 | %5,3 |

## Öneri
- **Aylık: 149 TL.** Papağanca ve Ev Okulu ile aynı; yıllık planı cazip kılar.
- **Yıllık: 1.199 TL.** Aylıktan %33 indirim; Ev Okulu 1.299 ve Duolingo Super aralığının alt ucunda, marka yanlısı anlatım gerekir. Başabaşı en düşük tutan dengeli nokta.
- **Aile (2 çocuk): 1.799 TL/yıl.** Tek çocuk fiyatının 1,5 katı; ikinci çocukta marjinal katkı yüksek.
- **Deneme: 14 gün** (kararlarla uyumlu), yenilemede otomatik çekim yok (kart ve hukuk onayı şart).
- **Kalıcı/ömür boyu sürüm önermiyorum.** Papağanca 1.499 sunuyor ama nakit akışını bozar ve yenileme gelirini yok eder.
- **Sınav paketi (ayrı ürün, 7–8. sınıf):** deneme başına ~500 TL çapası var; LGS öncesi dönemde 1.500–2.500 TL'lik dönemsel paket daha uygun olabilir. Bu, sınav ürünü tasarlanınca ayrıca değerlendirilmeli.

## Riskler
- Fiyat hassasiyeti veriye değil varsayıma dayanıyor; ilk 2–3 ay kademeli deneme (1.199 vs 1.499 A/B, B-18 kapısıyla) önerilir.
- Ortak indirimi (%15) fiyatla birlikte çalışır: 1.199 TL'de ilk alım ~1.019 TL'ye düşer, bu da ortak için komisyon tabanını etkiler.
- Lingokids ve Duolingo'nun Türkiye fiyatları düşük olabilir; kıyas aynı segmentten yapılmalı.
