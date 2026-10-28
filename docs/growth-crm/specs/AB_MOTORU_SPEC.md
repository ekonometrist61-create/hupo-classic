# Gerçek A/B motoru spesifikasyonu (H-GIE Faz 6)

Durum: **taslak spec, kod yok.** Tarih: 2026-10-28. Kapsam: gerçek kullanıcıda deney yürütme. Sentetik Customer-Lab sonucu bu motorun girdisi değildir; yalnızca aday üretir (`scripts/customer-lab/ab_aday.py`).

## 1. Amaç
Customer-Lab'ın ürettiği hipotezleri (fiyat, onboarding, mesaj) gerçek kullanıcıda, önceden kayıtlı kurallarla test etmek ve sonucu karara bağlamak.

## 2. Kapsam dışı
- Sentetik veriyi gerçek sonuç olarak kaydetmek.
- Çocuk verisine dayalı hedefleme veya çocuğa kişisel fiyat gösterme (proje kuralı).
- Testin sonucuna bakıp durdurmak (optional stopping) ve sonucu seçerek raporlamak.
- Ödeme akışında kullanıcıya farklı fiyat göstermek, ön onay olmadan (fiyat değişikliği insan onaylı).

## 3. Deney tanımı (zorunlu alanlar, deney başlamadan kayıtlı)
| Alan | Açıklama |
|---|---|
| hipotez | Tek cümle; yön ve beklenen etki |
| birincil metrik | Tek metrik (örn. 7 gün içinde tamamlanan ödeme oranı) |
| guardrail | En az iki metrik; kötüleşirse deney durdurulur (örn. iade, şikâyet) |
| referans oranı | Kontrol kolunun geçmiş oranı |
| minimum ilgi farkı | Yani tespit edilecek en küçük fark |
| alfa, güç | Varsayılan 0.05 (çok karşılaştırmada Bonferroni), 0.80 |
| kol başına örneklem | `ornek_boyutu` ile hesaplanır; deney süresi buna göre planlanır |
| başlangıç ve bitiş tarihi | Önceden sabit; ara bakış yok |
| sorumlu kişi | İsimle; onay kaydı |

## 4. Atama
- Rastgele atama, kullanıcı kimliğinin tuzlu özetine göre (deterministik ama tahmin edilemez). Kolların boyutları ön kayıtlıdır.
- Atama kararı bir kez verilir; kullanıcı kol değiştirmez.
- Çocuk hesapları: atama veliye bağlı yapılır; çocuğa kişisel fiyat gösterilmez.
- Atamanın dengesi (SRM kontrolü): beklenen oranla gerçek oran arasında anlamlı fark varsa deney geçersiz sayılır.

## 5. Analiz
- Birincil metrik için iki oranlı z-testi veya uygun eşdeğeri; güven aralığı raporlanır.
- Çoklu karşılaştırmada alfa, kol ve metrik sayısına göre düzeltilir (Bonferroni, ön kayıtlı).
- Guardrail kötüleşmesi, birincil metrik iyi görünse bile kararı durdurur.
- Alt grup analizi yalnız ön kayıtlıysa yapılır; eşik altı gruplar (n<10 hane) raporlanmaz.

## 6. Kararlar ve kapılar
| Kapı | Koşul |
|---|---|
| Başlatma | Kayıt tamam, guardrail tanımlı, onay var |
| Ara kontrol | Yalnız izleme (SRM, guardrail, teknik hata); etkiye göre karar yok |
| Sonuç | Bitiş tarihinde, ön kayıtlı analizle |
| Uygulama | Kazanan kol ancak insan onayıyla ürüne alınır |

## 7. Veri ve gizlilik
- Atama ve sonuç kayıtları hane düzeyinde değil, toplulaştırılmış analizde kullanılır.
- Deney kayıtları analitik izin (`iletisim_tercihleri` / analitik çerez) olan kullanıcılarla sınırlıdır; izinsiz kullanıcı deneye alınmaz.
- Analiz çıktısında kişi bilgisi, öğrenci kimliği ve doğruluk düzeyi yoktur (H-GIE Faz 3 kuralları).

## 8. Aşamalar
| Aşama | İçerik | Kapı |
|---|---|---|
| A0 | Bu spec, deney kayıt şeması | Onay |
| A1 | Deney tanımı ve atama (tablolar, RLS, testler) | Deploy onayı |
| A2 | Toplulaştırılmış analiz ve SRM kontrolü | Test: sahte veriyle yanlış pozitif oranı beklenen düzeyde |
| A3 | Ekran ve karar kaydı | Gözden geçirme |

## 9. Kabul ölçütleri
- Sahte (sıfır etkili) veriyle yapılan simülasyonda yanlış pozitif oranı alfa'ya yakın kalır (test).
- Ara bakış ile sonuç değişikliği ön kayıtlı kuralda engellenir (test).
- SRM tespit edildiğinde deney sonucu raporlanmaz (test).
- Kayıtsız (ön kaydı olmayan) deney başlatılamaz (test).
