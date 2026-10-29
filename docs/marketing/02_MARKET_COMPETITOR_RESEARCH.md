# 02 Pazar ve Rakip Araştırması

Durum: Taslak (sınırlı doğrulama) · Tarih: 2026-10-29 · Rol: Ürün ve Rakip Analisti · Bağımlı: 01, 03, 18

**Önemli sınır:** Ahrefs/Similarweb/Supermetrics bağlı değil; App Store sıralaması, reklam harcaması, trafik verisi alınamadı. Yalnızca erişilebilen resmî sayfalar ve arama sonuçları kullanıldı. Her satırda güven düzeyi: **Doğrulandı** (sayfadan okundu) / **Kısmen** / **Tahmin** / **Doğrulanamadı**. Erişim tarihi hepsi 2026-10-29.

## 1. Doğrulanan rakip bulguları

| Rakip | Kaynak (erişim 2026-10-29) | Bulgu | Güven |
|---|---|---|---|
| **MEBİ** (MEB Ortaöğretim Gn. Md.) | https://mebi.eba.gov.tr | Ücretsiz; ortaokul 5–8, lise 9–12, mezun; okul dersleri içeriği şimdilik 5, 6, 9, 10. sınıf; konu anlatım videoları, özetler, çıkmış sorular, denemeler, konu testleri, çalışma planı, hedef, raporlama; yapay zekâ asistanı "KANKA"; veli e-Devlet ile çocuğun ilerlemesini görebiliyor | Doğrulandı |
| **Kunduz** | https://kunduz.com/tr/ | YKS/LGS/okul müfredatı; 4–11. sınıf; 7/24 soru çözümü, bire bir koçluk, canlı grup dersi, deneme kulübü, yapay zekâ asistanı "KAI", veli haftalık raporu; fiyat sayfada yok; başarı oranları şirket anketine dayanıyor | Doğrulandı (fiyat: Doğrulanamadı). App Store kaydında ücretsiz deneme + aylık abonelik ve $5.99–$14.99 aralığı: Kısmen (https://apps.apple.com/app/id1083827128, üçüncü taraf fiyat takip sitesi) |
| **Tonguç Akademi** | tonguc.com alan adı farklı bir kişiye ait çıktı; akakce.com listesi | Ürün ağırlığı basılı yayın (5. sınıf "Zoru Bankası" ~379 TL, "Şampiyon Paketi" ~1.851 TL, tarihsiz fiyat karşılaştırma sitesi); dijital abonelik yapısı doğrulanamadı | Kısmen / fiyat tarihsiz |
| **EBA Akademik Destek** | MEB haberi (meb.gov.tr/eba-kontrol-merkezi...) | 11–12. sınıf odaklı; ortaokul hedef kitlesi değil | Kısmen |
| **Morpa Kampüs, Okulistik** | Akademik makaleler (öğretmen görüşü çalışmaları) | Kullanım ve içerik düzeyinde akademik çalışma var; fiyat, veli paneli, oyunlaştırma doğrulanamadı | Doğrulanamadı |

**Doğrulanamayan, ama değerlendirilmesi gereken adaylar (araştırma boşluğu, tahmin yürütülmedi):** Okulistik, Morpa Kampüs, Vitamin, Eğitim Vadisi, Khan Academy Türkçe, Duolingo (İngilizce/oyunlaştırma referansı), Matific, Pearson/Oxford Türkiye dijital, yayınevi dijital platformları (Tonguç, Nartest, Bilfen, Özdebir...). Bunlar için **ikinci tur araştırma** `16_IMPLEMENTATION_BACKLOG` R-1 olarak kaydedildi: kullanıcı kendi tarayıcısıyla (ya da Similarweb/Ahrefs yetkilendirilince) fiyat, mağaza puanı, yorum temaları ve sosyal hesapları doldurur. Şablon bölüm 6.

## 2. Asıl bulgu: ücretsiz devlet platformu çıtayı belirliyor
MEBİ ücretsiz, veli erişimli, yapay zekâ asistanlı. Dolayısıyla Hupolingo:
- **İçerik hacmi, video, deneme sayısı üzerinden yarışmamalı** (kısa vadede kaybeder, kanıt: MEBİ ücretsiz + MEB içerik hakkı).
- "Yapay zekâ" kelimesiyle konumlanmamalı (MEBİ KANKA, Kunduz KAI var; Hupo'nun çocuk yüzeyinde LLM'i yok).
- MEBİ ile **rakip değil tamamlayıcı** tonu mümkün: "Okul ve MEBİ içeriğinin yanında, 10 dakikalık günlük pratik ve veliye okunur özet". MEB ile iş birliği iddiası **yok**; yalnızca nötr karşılaştırma. (Güven: Hipotez.)

Beklenen müşteri sorusu: "MEBİ ücretsizse neden Hupolingo?" → 12 aylık plana SSS maddesi, 06/11'de yazılı cevap: *kısa günlük rutin, çocuk motivasyonu, veliye tek ekranda konu özeti, tek seferlik şeffaf ödeme*; MEBİ'yi kötülemeden. Not: MEBİ okul dersleri 5–6. sınıf için yüklü; Hupo'nun 3–4 ve 7. sınıf kapsamı bu açıdan fark olabilir (kapsam doğrulaması gerekir: MEBİ sayfası yalnızca "şimdilik 5,6,9,10" diyor).

## 3. Kategori haritası (Hipotez)
| Kategori | Örnek | Hupo'nun konumu |
|---|---|---|
| Devlet ücretsiz platform | MEBİ, EBA | Fiyat çıtası = 0; yarışılmaz, tamamlanır |
| Sınav/koçluk odaklı özel platform | Kunduz, yayınevi akademileri | Sınav kaygısı ve garanti diline yaslanır; Hupo bu dili kullanmaz |
| Basılı soru bankası + dijital ek | Tonguç, Nartest vb. | Fiyat çıpası: set başına yüzlerce TL (tarihsiz) |
| Oyunlaştırılmış ilkokul uygulamaları | Morpa, Okulistik, Matific (doğrulanamadı) | Doğrudan benzer; ayrışma: veli raporu + kısa rutin + güven |
| Dil öğrenme oyunlaştırması | Duolingo | Alışkanlık mekaniği referansı, çocuk için "seri korkusu" kullanılmaz |

## 4. SWOT (kanıt etiketli)
| | |
|---|---|
| **Güçlü** | Dürüst veli odaklı mesaj ve etiketli örnek rapor (Kanıtlı); çocuk yüzeyi reklamsız/konumsuz (Kanıtlı); tek seferlik ödeme (Kanıtlı, yayınsız); kazanım etiket altyapısı (Kanıtlı); ölçüm ve A/B altyapısı hazır (Kanıtlı) |
| **Zayıf** | Mağazada yok; fiyat ve ödeme yayında değil; sıfır sosyal kanıt; soru hacmi/kalite kanıtı doğrulanamadı; kitle çok geniş (3–7 sınıf); self-serve deneme yok; tek kişilik üretim kapasitesi (Varsayım); arama indeksinde yok (robots) |
| **Fırsat** | Ücretsiz platformların "veliye okunur günlük rutin" boşluğu (Hipotez); 4→5 geçişi ve proje okulu hazırlığı niş (Hipotez); ara tatil/yarıyıl dönemlerinde evde pratik talebi (Hipotez); SEO'da veli soruları (Hipotez) |
| **Tehdit** | MEBİ gibi ücretsiz kamu platformu; yayınevlerinin dijital geçişi; Meta/TikTok çocuk reklam politikaları; KVKK ve ticari ileti hukuku; hukuk metinleri onaylanmamış; "sınav garantisi" diliyle rekabet eden oyuncular |

## 5. PESTEL (Tahmin/Kısmen, kaynak: repo müfredat belgeleri ve genel bilgi)
- **Politik:** TYMM geçişi (2026–27'de 1,2,3,5,6,7); 4 ve 8 önceki program; ortaokul yapay zekâ uygulamaları dersi programı yayımlanmış (mufredat.meb.gov.tr, Kısmen). Etki: müfredat belirsizliği, kazanım kodu disiplini.
- **Ekonomik:** Veli bütçesi baskısı; özel ders/kurs maliyeti yüksek (Tahmin); basılı set fiyatları yüzlerce TL (Kısmen).
- **Sosyal:** Ekran süresi kaygısı, motivasyon, proje okulu rekabeti (Hipotez).
- **Teknolojik:** Mobil ağırlık, mağaza politikaları (Apple 3.1.1 vb.), AI asistanların normalleşmesi.
- **Yasal:** KVKK, çocuk verisi, ticari ileti (İYS), mesafeli satış ön bilgilendirme (taslak), reklam politikaları. `17_RISK_COMPLIANCE`.
- **Çevresel:** Anlamlı etki yok.

## 6. Porter'ın Beş Gücü (Hipotez)
Yeni giren tehdidi yüksek (düşük bariyer); alıcı pazarlık gücü yüksek (çok ücretsiz alternatif); tedarikçi gücü düşük/orta (AI/altyapı sağlayıcıları, içerik üretimi kendi hattı); ikame tehdidi çok yüksek (MEBİ, özel ders, kitap); rekabet yoğunluğu yüksek. Sonuç: fiyatla değil güven, rutin ve veli görünürlüğü ile tutunmak; maliyet yapısını düşük tutmak (organik, otomasyon).

## 7. Jobs-to-be-Done (Hipotez; mom-test/JTBD görüşmesiyle doğrulanmalı, `05`)
- "Çocuğum ders dışında ekranda boş zaman yerine bir şey çalışsın, ama kavga etmeden." (işlevsel + duygusal)
- "Okulun neresinde eksik olduğunu öğreneyim, panik olmadan." 
- "Proje okulu/geçiş sürecinde geride kalmadığımızı hissedeyim." (duygusal; **korku çerçevesi kullanılmaz**)
- Rakip "işe alma" nedenleri: MEBİ = ücretsiz ve resmî; Kunduz = soru çözdürme/koç; yayınevi seti = tanıdık güven.

## 8. Fiyat/değer algısı
Hupo fiyatı **belirlenmedi** (plan admin'de; landing "hazırlık aşamasında"). Çıpa verileri: MEBİ 0 TL (Doğrulandı); Kunduz mağaza kaydı $5.99–$14.99 aralığı (Kısmen, TL karşılığı doğrulanamadı); basılı set 375–1.850 TL (Kısmen, tarihsiz). `15_BUDGET_FORECAST` fiyatları **senaryo girdisi** olarak etiketler.

## 9. Rakip araştırma şablonu (R-1 için doldurulacak)
Rakip · hedef · değer önerisi · özellikler · fiyat (TL, tarih, URL) · web mesajı · App Store/Play puanı ve yorum sayısı · yorum temaları · sosyal hesaplar ve sıklık · reklam örnekleri (Meta Reklam Kitaplığı: kullanıcı kendi tarayıcısında) · güçlü/zayıf · Hupo fırsatı. Meta Ad Library ve mağaza sayfaları bu oturumda **erişilemedi/denenmedi**.

## 9b. Ek kaynak (kullanıcı): ilk 1000 kullanıcı taktikleri
Ömer Said Akçin, "Uygulaman yayında ama kimse indirmiyor: 20 bedava yol", https://omersaidakcin.com/ilk-1000-kullanici, erişim 2026-10-29. Rakip verisi değil, büyüme taktik havuzudur; Hupo uyarlaması ve platform iddialarının resmî doğrulaması: `20_TAKTIK_HAVUZU_ILK_1000.md`. Güven: kaynak görüş yazısı, resmî belge değil.

## 10. Asıl soru: "Neden Hupolingo?"
Çocuğun 10 dakikalık günlük rutini + veliye tek bakışta dürüst konu özeti + abonelik tuzağı olmayan tek seferlik ödeme + çocuğa baskı yapmayan tasarım. İçerik hacmi veya "AI" değil. Detay: 03, 04.
