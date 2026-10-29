# 14 Deney Backlog'u

Durum: Taslak · Tarih: 2026-10-29 · Rol: Veri Analitiği ve Deney Tasarımı · Bağımlı: 06, 13, 15 · Altyapı: A/B motoru (`/yonetim/ab-deneyler`, `ab_*` fonksiyonları, GIE §25–33), `scripts/customer-lab/ab_aday.py`, `scripts/ab-analiz/analiz.py`

## 0. Kurallar
Hiçbir deney çalıştırılmadı; sonuç yok. Tek hipotez, ana + koruma metriği, durdurma/karar kuralı, ara bakış yasağı. Trafik/MDE yetersizse **A/B yürütülmez**, niteliksel test yapılır ve nedensel kanıt diye sunulmaz. Çocuk akışına satış deneyi yok. İlk fiyat/sunum testi GIE §33: yalnızca sunum (fiyat değişmez), 7 günde ücretli ödeme oranı; referans ölçüm 30 gün, tetikleyici mağaza yayını. "Belirsiz" geçerli sonuçtur.

## 1. Örneklem gerçeği (örnek hesap)
İki oranlı test, %80 güç, α=0,05: temel oran p0=%10'dan %13'e (mutlak +3 puan) çıkarmak için kol başına ~1.770 gözlem; p0=%5 → %7 için ~2.200; p0=%2 → %3 için ~3.800 (yaklaşık, normal yaklaşımı; `statistical-power` ile tekrar hesaplanacak, Doğrulanamadı kesin değer). Hupo'da ilk 90 günde ziyaret binlerce değil yüzlerle ölçülür (13) → **web A/B'leri 2027 ortasından önce anlamlı sonuç vermez.** Bu yüzden ilk 6 ay: niteliksel testler ve organik içerik denemeleri (nedensellik iddiasız).

## 2. Sıralı backlog (ICE = etki × güven × kolaylık, 1–5; Hipotez)
| ID | Tür | Hipotez (tek değişken) | Ana metrik | Koruma | Ön koşul | ICE |
|---|---|---|---|---|---|---|
| E1 | Niteliksel (5 veli) | Hero H2 ("günde 10 soruluk alışkanlık"), H1'e göre ilk 5 sn anlaşılırlığı artırır | Görev tamamlama / "ne yapıyor?" doğru cevap | Güven algısı | Görüşme izni | 5×3×5=75 |
| E2 | Niteliksel | "Pilot sürüm" notu güveni artırır mı azaltır mı | Algı sorusu | — | — | 4×3×5=60 |
| E3 | Organik içerik | Kanca biçimi: soru vs gözlem (aynı konu, alternatif günler) | Kaydetme+paylaşım / erişim | Olumsuz yorum | T0 | 3×2×5=30 (nedensel değil) |
| E4 | Organik içerik | Yayın saati (hafta içi 20:00 vs 21:30) | Erişim | — | T0 | 2×2×5=20 |
| E5 | Web A/B (trafik şartı) | İkincil CTA: "Örnek veli raporuna bak" vs "Veli hesabı oluştur" | demo_tamamlandi → veli_kayit_baslatildi | demo geri dönüş | ≥ MDE trafiği; `ab_deney` kaydı | 4×3×4=48 |
| E6 | Web A/B | Demo sonu tek CTA vs iki CTA | veli_kayit_baslatildi | demo geri dönüş | aynı | 4×3×4=48 |
| E7 | Web A/B (GIE §33) | Plan ekranında "deneme vurgusu" (A) / "deneme sonu hatırlatma" (C) | 7 günde ücretli ödeme | İade/şikâyet | Ödeme + self-serve deneme + hukuk; **şu an uygulanamaz** | 5×2×2=20 |
| E8 | E-posta (izinli) | Konu satırı: somut vs merak | Tıklama | Abonelikten çıkış | İzin + gönderim altyapısı | 3×2×3=18 |
| E9 | Kayıt formu | E-posta doğrulama sırası | Hesap tamamlama | Hata oranı | trafik | 4×3×2=24 |
| E10 | Mağaza (ASO) | Mağaza ilk görsel | Mağaza dönüşümü | — | Mağaza yayını | Beklemede |

## 3. Deney şablonu (doldurulacak; `GROWTH_AND_MEASUREMENT.md`)
Hipotez · Segment · Değişen tek unsur · Ana metrik · Koruma metrikleri (öğrenme ve güven) · Baseline · Örneklem+süre (MDE) · Durdurma/karar kuralı · Sonuç ve sınırlılıklar · Kayıt: `ab_deney` + `ab_karar`.
**İlk önerilen tek deney:** E1 (niteliksel hero testi, 5 veli), ardından E5 (trafik yetince). Gerekçe: en düşük maliyet, en yüksek öğrenme, sıfır çocuk etkisi.

## 4. Karar disiplini
Bonferroni (çoklu kol), SRM kontrolü, ara bakış yasağı, guardrail tek kuyruk (analiz.py). Küçük n: "yetersiz". Sonuçlar nedensel dilde değil "bu deneyde şu gözlendi" dilinde raporlanır. Dönüşüm yüzdesi vaadi yok.

## 5. Nedensellik notu (dag-development ruhu)
"Sosyal gönderi kayıt getirdi" iddiası öncesi karıştırıcılar: mevsim (okul açılışı/tatil), pilot daveti, doğrudan paylaşım, hava durumu gibi dış etkiler; yalnız kaydetme/paylaşım gibi platform içi göstergeler karşılaştırılır; DAG çizimi gerçek veri gelince.
