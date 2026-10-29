# 06 Web CRO ve SEO Denetimi

Durum: Taslak (kaynak kod/metin denetimi; **canlı UX denetimi çalışmadı**, tarayıcı MCP bağlanmadı) · Tarih: 2026-10-29 · Rol: CRO ve Büyüme + SEO/ASO Uzmanı · Bağımlı: 01, 03, 04, 11/landing_pages, 14

Bu belge mevcut `docs/hupo-design-growth/sosyal-medya/STRATEJI_DEGERLENDIRME.md` bulgularını (P0–P2, Y1–Y5 yayın öncesi liste) **tekrar etmez, devralır**. Orada 12 bulgu var; burada yalnız ek bulgular, alternatif konumlandırma ve içerik üretimi yer alır. Kod değiştirilmedi.

## 1. Özet puan kartı (kod/metin okuma; ölçüm yok)
| Alan | Değerlendirme | Kanıt |
|---|---|---|
| İlk 5 sn netliği | İyi: başlık+alt başlık veli odaklı, tek CTA | tr.json hero |
| Güven | Güçlü içerik, zayıf kanıt (görsel kanıt/gerçek ekran?) | trust bölümü |
| Fiyat sayfası | Zayıf: plan yok, "hazırlık aşamasında"; pricing bölümünde kanıtsız rozetler (Y2) | tr.json pricing |
| Mobil/hız | LCP ve Lighthouse ölçüldü (K-0200) ama sonuç bu oturumda okunmadı; mobil gerçek cihaz yok | decisions.md 2026-10-29 |
| SEO | Sıfır: robots Disallow, sitemap/OG/JSON-LD yok (Y3) | STRATEJI §0 |
| Erişilebilirlik | Yazı boyutu kontrolü, skip link, reduced-motion var | tr.json, decisions |

## 2. Ek bulgular (STRATEJI'den farklı)
| # | Bulgu | Öneri | Etiket |
|---|---|---|---|
| E1 | **Rakip/karşılaştırma yok:** "MEBİ ücretsizse?" itirazına cevap yok. | SSS'ye nötr madde (11/landing_pages) | Hipotez |
| E2 | **Landing'de ücretsiz/premium/aile kapsam listesi (tr.json `pricing.*`)** kodda bileşende kullanılsa da onaylı plan kaydı değil ("Aile 6 üye", "öncelikli destek", "özel aile etkinlikleri"). Kanıt yok. | Plan kaydı gelmeden bu metin yayında olmasın (Y2'ye ekle) | Kanıtlı |
| E3 | `characters.cta` "Koleksiyona Başla", `characters.desc` "Her doğru cevap seni..." çocuğa hitap ediyor; sayfanın alıcısı veli. Çocuk dili ile veli satışı karışıyor. | Karakter bölümünü veli faydasına bağla ("çocuğun motivasyonu") | Hipotez |
| E4 | Landing'de gerçek ürün ekranı ("uygulama ön izlemesi, tasarım") var; "Uygulama içinden" bölümü tasarım ön izlemesi diyor. Gerçek ekran kaydı yok. | Gerçek ekran kaydı ile değiştir; "tasarım ön izlemesi" ifadesi güveni düşürür | Hipotez |
| E5 | Hero rozeti "3–7. Sınıf" ↔ 4→5 odak; veli "çocuğum mu?" sorusuna net değil | 3 hero adayı (aşağı) | Hipotez |
| E6 | Veli kaydı sonrası ilk değer anı (çocuk eşleştirme kodu) landing'de anlatılmıyor | "Nasıl çalışır" 3. adımı ekran görüntülü; kod eşleştirmesini 1 cümleyle | Hipotez |
| E7 | `footer.tagline` "Öğren. Güçlen. Zirveye çık." çocuk/motivasyon sloganı; veli kategorisiyle uyumsuz, "zirve" başarı vaadi çağrıştırır | Veli sloganı: "Küçük adımlar, görünür ilerleme." | Hipotez |
| E8 | Ticari ileti izni: landing'de e-posta toplama yok (tek CTA). Hazır olmayan ziyaretçi kayboluyor. STRATEJI bulgu 5. | "Veli rehberi" e-posta serisi için ayrı sayfa, izin kutusu, hukuk onayı sonrası | Hipotez |

## 3. Alternatif ana sayfa konumlandırmaları (test için; uygulamaz, yazılı)
| ID | Başlık | Alt başlık | Farkındalık / itiraz |
|---|---|---|---|
| H1 (mevcut) | Soru çözme alışkanlığını küçük görevlerle destekleyin | Çocuğunuz Hupo ile kısa soru çalışmaları yapsın; siz ilerlediği ve tekrar etmesi gereken konuları görün. | Çözüm farkında; itiraz: "işe yarar mı" |
| H2 | Ders çalışmayı günde 10 soruluk bir alışkanlığa çevirin | Çocuğunuz kısa görevlerle çalışır; siz hangi konuyu tekrar etmesi gerektiğini tek ekranda görürsünüz. | Problem farkında ("alışkanlık") |
| H3 | Akşam ders kavgası yerine, 10 soruluk bir rutin | Hupo ile çocuğunuz kendi hızında ilerler; siz sakin bir özetle neyi tekrar edeceğini görürsünüz. | Duygusal (rahatlama), korkusuz |
Öneri: H1'i temel kol bırak, H2'yi ilk niteliksel testte (5 veli) karşılaştır. Trafik yetersiz → A/B yürütme (14).

## 4. Üç landing page konsepti (tam metin 11/landing_pages.md)
1. **L-A "Veli Rutini"** (ana site, sosyal kampanyalar): sorunu kabul → 10 soruluk rutin → demo → örnek rapor → güven.
2. **L-B "Geçiş Hazırlığı" (4→5)**: takvimli hazırlık; sınav/okul adı yok; "Proje ortaokulu hazırlığı" yalnız bir tema, resmî ortaklık yok. Yayın kapısı: sınav formatı/tarih doğrulaması.
3. **L-C "Güvenle Başla"** (P3 şüpheci veli): yalnız uygulanmış güven maddeleri, veri yönetimi, hesapsız demo.

## 5. Premium/üyelik sayfası önerisi
Fiyat kaydı yok → "iskelet" (11/landing_pages.md): plan karşılaştırması (admin kaydından), toplam tutar+dönem aynı alanda, "Tek seferlik ödeme. Otomatik yenileme yok.", ön bilgilendirme bağlantısı, SSS (iade/cayma: hukuk onaylı metin gelince), maskot yok (ödeme ekranı kuralı). Kaldırılacak: "En Çok Tercih Edilen" rozeti (sosyal kanıt iddiası, veri yok), "%40 tasarruf", "İstediğin Zaman İptal".

## 6. Kayıt dönüşümü A/B testleri (hepsi ön koşullu)
Trafik yok: **yürütme yok**. Sıralama (ICE):
| # | Hipotez (tek değişken) | Ana metrik | Koruma | ICE |
|---|---|---|---|---|
| T1 | İkincil CTA "Örnek veli raporuna bak" vs "Veli hesabı oluştur" (STRATEJİ §5) | demo_tamamlandi → veli_kayit_baslatildi | demo tamamlama | 4×3×4=48 |
| T2 | Hero H1 vs H2 | hero_cta_tiklandi | sayfadan çıkış | 3×2×5=30 |
| T3 | Demo sonu CTA: "Veli hesabı oluştur" tek eylem vs iki eylem | veli_kayit_baslatildi | demo geri dönüş | 4×3×4=48 |
| T4 | Gerçek ekran kaydı hero'da vs statik telefon | hero_cta_tiklandi | LCP | 3×3×3=27 |
| T5 | Kayıt formu alan sayısı/e-posta doğrulama sırası | hesap oluşturma | hata oranı | 4×3×2=24 |
Çocuk akışında satış deneyi yok. Örneklem: `scripts/customer-lab/ab_aday.py` / `statistical-power` ile; baseline yoksa 30 gün ölçüm.

## 7. Teknik SEO yol haritası (Y3 sonrası, lansman kapısı)
robots (ortam bazlı) · sitemap · canonical · hreflang yok (tek dil) · OG 1200×630 · `Organization`, `FAQPage`, `Article` JSON-LD · iç bağlantı: rehber ↔ demo · `noindex` kalacaklar: `/demo` sonuçları, `okuma-demo`, panel yolları, soru/çocuk içeriği · Core Web Vitals izleme (Search Console) · Yapay zekâ görünürlüğü: net, alıntılanabilir SSS blokları ve kısa tanım cümleleri (llms.txt gibi deneysel standartlar zorunlu değil). Soru içeriği veya çocuk verisi public index'e **taşınmaz**.

## 8. İlk 20 SEO içerik önerisi (arama niyeti: veli, bilgi/işlem; anahtar kelime hacmi **Doğrulanamadı**, Ahrefs yok)
Küme 1 Rutin: (1) 4. sınıf çocuk evde nasıl düzenli çalışır, (2) günde kaç soru yeterli, (3) çocuk ders çalışmak istemiyor ne yapılır, (4) ekran süresi ve eğitim uygulaması dengesi, (5) kısa çalışma mı uzun çalışma mı.
Küme 2 Geçiş: (6) 4. sınıftan 5. sınıfa geçişte velinin yapabilecekleri, (7) ortaokula hazırlık kontrol listesi, (8) 5. sınıf ilk dönem çalışma planı örneği, (9) yaz tatilinde tekrar nasıl yapılır, (10) ara tatilde 20 dakikalık çalışma.
Küme 3 Veri/rapor: (11) yanlış cevaplar nasıl okunur, (12) tekrar listesi neden önemli, (13) doğru oranı neden tek başına yanıltıcıdır, (14) çocuğun gelişimini nasıl takip ederim.
Küme 4 Güven/ürün: (15) çocuk için eğitim uygulaması seçerken 10 soru, (16) reklamsız eğitim uygulaması neye bakılır, (17) çocuk verisi ve veli onayı nasıl çalışır, (18) tek seferlik ödeme ile abonelik farkı, (19) MEBİ ve özel uygulamalar birlikte nasıl kullanılır, (20) ortak yazılı sınavı öncesi 7 günlük tekrar planı (5–8 için, takvim kaynağı: MEB).
Brief ve 3 tam yazı: `11_SAMPLE_CONTENT/blog_content.md`.

## 9. ASO notu
Uygulama mağazada yok → ASO denetimi yapılamaz. Hazırlık: `mobile-app/store/MAGAZA_METINLERI.md` + 11/advertising altında mağaza metni taslağı **yok** (önceki mağaza metni var; yalnız kural: fiyat/garanti/1 numara yok). Anahtar kelime araştırması yayın öncesi `aso` skill'iyle ve mağaza arama önerileriyle yapılır (Doğrulanamadı).
