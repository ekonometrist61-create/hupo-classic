# Hupolingo web sitesi pazarlama stratejisi değerlendirmesi

- **Tarih:** 2026-10-29 · **Hazırlayan:** MAR-OTO-AI (taslak, yayın yok)
- **Yüzey:** public landing (`web-panel/src/app/[locale]/(full-width-pages)/page.tsx`) · **Hedef kitle:** veli (3–7. sınıf çocuğu olan, özellikle 4→5 geçişi) · **Ana eylem:** "Örnek soruları dene" (`/demo`) · **Ana metrik adayı:** `demo_tamamlandi` ve `veli_kayit_baslatildi` (baseline yok)
- **Okunan kaynaklar:** `tr.json` (landing), `HeroSection`, `PricingSection`, `FinalCtaSection`, `Footer`, `page.tsx`, `robots.txt`, `OLAY_TAKSONOMISI.md`, `GIE_ANALIZ_VE_IS_PLANI` §19, §33–35, `decisions.md`, `DENEME_SINIR_KURALI.md`, `ILETISIM_EKSIKLERI_PLANI`.
- **Doğrulama sınırı:** Kod ve metin okundu. Canlı site, tarayıcı görüntüsü, canlı DB'deki plan/fiyat verisi ve Vercel üretim ortamı **görülmedi**.

Güven etiketleri: **Kanıtlı** (repoda görüldü) · **Varsayım** · **Hipotez** (test edilmeli).

## 0. Yayın öncesi zorunlu kontrol listesi (2026-10-29, proje sahibi kararı, K-0199)

Ürün şu an **geliştirme aşamasında**; aşağıdaki üç madde (§1 bulgu 1, 2, 3) bilerek **koda uygulanmadı**. Bunlar ürün satışa çıkmadan hemen önce düzeltilecek. **Kapı kuralı:** bu liste kapanmadan sosyal medyadan veya başka kanaldan siteye trafik yönlendirilmez, mağaza/ödeme yayına alınmaz. Sosyal içerikte şimdiden "indir", "ücretsiz deneme", iade/garanti ve fiyat dili yoktur.

**Gerçek ekran kaydı terimi (bu belgede ve ekteki dosyalarda):** uygulama veya demo ekranının gerçek kullanım sırasında cihazdan kaydedilmiş hâli; çizim, mock-up ya da kurgu ekran değildir. Neden gerekli: sahte veya mock görsel veliye ürünü olduğundan farklı gösterir, güveni zedeler ve mağaza ile Meta politikalarındaki yanıltıcı ürün gösterimi kurallarına takılabilir.

| # | Madde | Yapılacak (ne zaman) | Sahibi | Doğrulama yolu | Durum |
|---|---|---|---|---|---|
| Y1 | **Mağaza rozetleri** (bulgu 1) | `web-panel/src/components/landing/Footer.tsx` satır ~47–56 ve `messages/tr.json`/`en.json` `footer.appStore`, `footer.googlePlay`: uygulama **mağazada yayınlanana kadar** rozetleri kaldır veya "Yakında" yap; mağazada yayın olunca gerçek mağaza bağlantısıyla değiştir. Mağaza yayın kararı ve tarihi proje sahibinde; kapı: rozet yalnızca gerçek mağaza URL'si 200 dönüyorsa görünür | Ana oturum (kod); proje sahibi (mağaza yayın bilgisi) | Üretim sayfasını aç (`/`), footer'da "indir" rozeti yok veya gerçek bağlantı; tıkla, mağaza sayfası açılıyor. `rg "appStore\|googlePlay" web-panel/src` ile bayat kullanım kalmadığını kontrol et | AÇIK (satıştan hemen önce) |
| Y2 | **Fiyat güven rozetleri** (bulgu 2) | `web-panel/src/components/landing/sections/PricingSection.tsx` (`trustBadges`, satır ~64 ve ~150) ve `messages/tr.json`/`en.json` `landing.pricing.trustBadges`, `yearlyNote`: "14 Gün İade Garantisi", "%100 Güvenli Ödeme", "Gizli Ücret Yok", "İstediğin Zaman İptal" ve "%40 tasarruf" kaldırılır; yerine `decisions.md` 2026-10-29 "Güven rozetleri çelişkisi" kararındaki üç doğrulanabilir ifade konur (tek seferlik/yenilemesiz, toplam tutar ödeme öncesi görünür + 3D Secure, ön bilgilendirme onayı). İade/cayma ifadesi yalnız hukuk metni onaylanınca ve metin aynı koşulu yazıyorsa | Ana oturum (kod); Hukuk (iade/cayma/ön bilgilendirme onayı); proje sahibi | `rg "İade Garantisi\|%100\|Gizli Ücret\|İstediğin Zaman İptal\|tasarruf" web-panel/src/messages` boş döner; fiyat bölümü ekran görüntüsü alınır; ödeme sayfasındaki `/on-bilgilendirme` onayı ile rozet metni çelişmez; `payments-checkout` tek seferlik satış davranışı değişmediği doğrulanır | AÇIK (satıştan hemen önce); hukuk onayı BEKLİYOR |
| Y3 | **robots.txt ve indeks paketi** (bulgu 3) | `web-panel/public/robots.txt` şu an `Disallow: /` (staging notu). Lansman gününde: robots'u üretim için izin verecek şekilde değiştir (özel yollar `Disallow`: `/yonetim`, `/veli-paneli`, `/api` gibi; soru/çocuk içeriği indekslenmez), `sitemap.xml`, 1200×630 OG görseli, canonical, `Organization` ve `FAQPage` JSON-LD ekle. Önce staging'in üretim alan adıyla karışmadığını doğrula (Vercel ortam bazlı robots gerekebilir) | Ana oturum (kod); proje sahibi (lansman günü) | Üretimde `https://hupolingo.com/robots.txt` içeriğini aç: `Disallow: /` yok, sitemap satırı var; `/sitemap.xml` 200; sayfa kaynağında `og:image` ve canonical; Search Console URL denetimi ve Facebook/LinkedIn paylaşım hata ayıklayıcı önizlemesi | AÇIK (lansman günü) |
| Y4 | **Footer sosyal bağlantıları** (bulgu 11; hesaplar açılana kadar çalışmıyor sayılır) | `Footer.tsx` satır ~25, ~32, ~39: `instagram.com/hupolingo`, `youtube.com/@hupolingo`, `linkedin.com/company/hupolingo`. Hesaplar açılıp kullanıcı adları doğrulanınca bağlantılar güncellenir; açılmadan trafik yönlendirilmez | Proje sahibi (hesaplar); ana oturum (kod) | Üç bağlantıya tıkla, gerçek hesap açılıyor; `KANAL_OTOMASYON_PLANI.md` §10 adım 9 | AÇIK |
| Y5 | **Kullanılmayan "Ücretsiz hesap oluştur…" metni** (bulgu 7) | `cta.subtitle` kaldırılır veya yeniden yazılır; "ücretsiz deneme" akış gerçekten kartsız çalışana kadar hiçbir yüzeyde kullanılmaz | Ana oturum | `rg "ücretsiz\|Ücretsiz" web-panel/src/messages/tr.json` ve sosyal içerik linter'ı | AÇIK |

**Sosyal içerik tarafı (şimdiden geçerli):** "indir", "ücretsiz deneme", "otomatik yenilenir", iade/garanti/"%100", fiyat rakamı ve "KVKK uyumlu" ifadeleri içerik paketinde yok; `sosyal_lint` bunları reddedecek şekilde tanımlıdır (`KANAL_OTOMASYON_PLANI.md` §5.2).

## 1. Öncelikli bulgular (P0 → P2)

### P0 — Yayını ve güveni doğrudan etkiler

| # | Bulgu | Kanıt | Öneri | Etiket |
|---|---|---|---|---|
| 1 | **Footer'da "App Store'dan İndir" / "Google Play'den İndir" rozetleri var, uygulama mağazada yok.** Rozetler bağlantısız `<span>`; K-0193'e göre referans ölçümü "mağaza yayını + ilk indirmeler"den sonra başlıyor, yani yayın henüz yok. Yanlış vaat ve mağaza politikası riski. | `Footer.tsx` satır 47–56; `tr.json` `footer.appStore/googlePlay`; `GIE` §33 | Rozetleri mağaza yayınlanana kadar kaldır veya "Yakında" yap. Sosyal medyada "indir" CTA'sı kullanma; CTA web `/demo`. | Kanıtlı (kod); mağaza durumu Varsayım |
| 2 | **Fiyat bölümündeki güven rozetleri koşulsuz gösteriliyor:** "14 Gün İade Garantisi", "%100 Güvenli Ödeme", "Gizli Ücret Yok", "İstediğin Zaman İptal". 2026-10-09'dan beri "AÇIK RİSK". Ayrıca ödeme K-0196'ya göre **tek seferlik satış**; "istediğin zaman iptal" abonelik dili, çelişir. İade ve ön bilgilendirme (`/on-bilgilendirme`) hukuk onayı bekliyor. | `PricingSection.tsx` satır 149–156; `tr.json` `landing.pricing.trustBadges`; `decisions.md` 2026-10-09, 2026-10-28 | Hukuk/proje sahibi kanıtlayana kadar dört rozeti de gizle. Kontrol kolunda bile A/C varyantları bunları kullanmıyor (karar 2026-10-28). | Kanıtlı |
| 3 | **`robots.txt` tüm siteyi engelliyor** (`Disallow: /`, "Staging ortamı" notu). Landing'de sitemap, canonical, Open Graph, JSON-LD de yok (yalnız okuma sayfalarında OG/canonical var). Organik arama ve sosyal paylaşım önizlemesi sıfır. | `web-panel/public/robots.txt`; `src/app` altında `sitemap/robots/opengraph-image` yok; `generateMetadata` yalnız title+description | Üretimde robots'un gerçekte ne döndüğünü kontrol et. Lansman kararından sonra: robots, sitemap, OG görseli (1200×630), canonical, `Organization` + `FAQPage` JSON-LD. Soru/çocuk içeriğini indekse taşıma. | Kanıtlı (dosya); üretimde aynı olup olmadığı Varsayım |

### P1 — Dönüşümü ve ölçümü sınırlar

| # | Bulgu | Kanıt | Öneri | Etiket |
|---|---|---|---|---|
| 4 | **Kanal/UTM atfı yok.** Landing olayları (`hero_cta_tiklandi`, `demo_tamamlandi`, `veli_kayit_baslatildi`, `fiyat_tiklandi`) UTM taşımıyor. UTM yalnız `erkenErisimIzleme.ts`'de var ve `ErkenErisimSection` sayfaya bağlı değil (olay tetiklenmiyor). Sosyal medya trafiği hangi gönderiden geldiği ölçülemez; kanal CAC'si zaten §19 kararıyla "yok" (hane kaynak alanı ≥%80 dolu olmalı). | `OLAY_TAKSONOMISI` §2–3; `page.tsx` yorumu; `GIE` §19 | Rıza sonrası ilk-temas UTM'ini (`utm_*` beş alan, PII yok) olay özelliklerine ve hane kaynağına yaz. Bu bir kod/ölçüm işi; ana oturumda karar (bkz. KANAL_OTOMASYON_PLANI §6). | Kanıtlı |
| 5 | **Landing'de e-posta/izin yakalama yok.** Erken erişim ve deneme sınavı bölümleri tek-CTA kuralı için çıkarıldı. Hazır olmayan ziyaretçi (sosyal medyadan gelen çoğu veli) geri dönüş yolu bırakmadan ayrılır; yeniden hedefleme/ısıtma için ne e-posta ne izinli kitle var. | `page.tsx` yorumu | Tek CTA'yı bozmadan, SSS altında düşük baskılı "veli notu" kaydı (ayrı izin kutusu, `/ticari-ileti-izni`) değerlendir. Hukuk onayı olmadan açılmaz. | Hipotez |
| 6 | **Ana CTA (demo) ile ikinci CTA (veli hesabı) arasında kopuş:** demo sonunda ne olduğu (veli kaydına geçiş, sonuç ekranı CTA'sı) bu incelemede doğrulanmadı. Demo hiçbir şey kaydetmediği için `demo_tamamlandi` yalnız çerez onaylı ziyaretçide sayılır; ölçüm yanlı (onay veren alt küme). | `OLAY_TAKSONOMISI` §2; `decisions.md` 2026-10-06 | Demo sonuç ekranını gerçek görüntüyle incele; "veli hesabı oluştur" CTA'sını sonuçta tek eylem yap. Ölçüm raporlarında "yalnız onaylı ziyaretçi" notu. | Varsayım |
| 7 | **Ücretsiz/deneme dili tutarsız.** `cta.subtitle` "Ücretsiz hesap oluştur…" (şu an sayfada kullanılmıyor), `nav.freeTrial` etiketi "Örnek soruları dene". Kartsız deneme DB'de var (`20261125`), ama arayüz/ödeme akışında yok; hukuk metni onaysız. | `DENEME_SINIR_KURALI` §3; `tr.json` | "Ücretsiz deneme" ifadesini hiçbir yüzeyde kullanma (sosyal medya dahil) tamamen akış çalışana kadar. Kullanılmayan `cta.subtitle` metnini sil veya yeniden yaz. | Kanıtlı |

### P2 — İyileştirme

| # | Bulgu | Öneri | Etiket |
|---|---|---|---|
| 8 | Hero rozeti "3–7. Sınıf · Proje Ortaokulu Hazırlığı", FAQ ise "Proje Ortaokullarına hazırlık öncelikli odağımız" der. İlk odak 4→5 geçişi (PROJECT_CONTEXT). Kitle netliği: veli "benim çocuğum mu?" sorusunu ilk ekranda cevaplamalı. | Rozeti "4→5 geçişi dahil 3–7. sınıf" gibi netleştirmeyi test et. Okul adı/resmî ortaklık izlenimi yaratma. | Hipotez |
| 9 | `WhyParentsSection` ("Neden çocuklar ve veliler Hupolingo'yu **seviyor**?") ve `TrustBadgesBar` ("%100 Türkçe içerik", "Kazanımları takip eder") sayfada **bağlı değil**; bu iyi. Yeniden bağlanırsa "seviyor" ima edilen kullanıcı kanıtı üretir. | Yeniden bağlamadan önce başlık ve iddiaları değiştir. | Kanıtlı |
| 10 | Hikâyeler bölümü "yayından önce üç aşamada incelenir" diyor. İçerik kapısı (iki bağımsız denetçi + insan onayı) proje kurallarında var; hikâye için süreç gerçekte uygulanıyor mu doğrulanmalı. | Sosyal medyada bu cümleyi kullanmadan önce kayıt/kanıt iste. | Varsayım |
| 11 | Footer sosyal bağlantıları (`instagram.com/hupolingo`, `youtube.com/@hupolingo`, `linkedin.com/company/hupolingo`) var; bu hesapların var olduğu, sahipliği ve kullanıcı adının doğru olduğu doğrulanmadı. | Kullanıcı hesapları teyit etsin. Yoksa footer'dan kaldır. | Varsayım |
| 12 | `framer-motion` kullanılmıyor (karar 2026-10-29 öneri). LCP ölçülmedi. Sosyal trafik mobil ağırlıklı olacağı için mobil LCP ve 4G ölçümü yapılmalı. | Lighthouse/PageSpeed (mobil) ölçümü; sonuç yazılmadan performans iddiası yok. | Kanıtlı (not), ölçüm yok |

## 2. Güçlü yönler (korunacaklar)

1. **Dürüst, veli odaklı hero:** "Soru çözme alışkanlığını küçük görevlerle destekleyin"; garanti yok; "pilot sürüm" notu. Kırmızı çizgilere uygun. *Kanıtlı.*
2. **Önce deneyim:** hesap gerektirmeyen, kayıt tutmayan 5 soruluk demo; "Örnek" ve "resmî sınav sorusu değildir" etiketi. *Kanıtlı.*
3. **Örnek rapor açıkça "ÖRNEK RAPOR"** ve "az veriyle yüzde göstermeyiz" ilkesi; XP/süre ile öğrenme ayrı tutulmuş. *Kanıtlı.*
4. **Güven bölümü yalnız uygulanmış şeyleri söylüyor** (reklam varsayılan kapalı, konum izni yok — `AndroidManifest.xml`/`Info.plist`'te konum izni bulunmadı, veli onayı, cevap anahtarı sunucuda). *Kanıtlı (landing metni + manifest taraması); sunucu tarafı iddiayı test etmedim.*
5. **Fiyat DB'den okunur**, ₺ hardcode yok, veri yoksa satır gizlenir; deneme günü yalnız `get_deneme_ayari` gelirse görünür. Tek CTA yapısı. *Kanıtlı.*
6. **Ölçüm disiplini:** PostHog yalnız çerez onayıyla, autocapture kapalı, PII yok, olay adları taksonomiyle uyumlu. *Kanıtlı.*

## 3. Değer önerisi — fayda / kanıt / eylem matrisi

| Veli itirazı | Cevap (yayınlanabilir) | Kanıt kaynağı | Eylem |
|---|---|---|---|
| "Çocuk çalışmıyor/kaçıyor" | Kısa (en fazla 10 soru) çalışmalar; ertesi gün kaldığı yerden | Landing `benefits` (ürün doğrulaması gerekir) | Örnek soruları dene |
| "Hangi konuda eksik?" | Ders/konu bazında özet, tekrar önerisi | Örnek rapor (etiketli) | Veli raporuna bak (demo/örnek) |
| "Ekran süresi/güven" | Reklam varsayılan kapalı, konum izni yok, veli onayı | Güven bölümü, manifest | Güven bölümünü oku |
| "Ücret değer mi?" | Fiyat/kapsam netleşince gösterilir; gizli ücret iddiası **kanıtlanana kadar yok** | Plan kaydı | Planlar |
| "Sınav garantisi?" | Yok; düzenli pratik ve görünür ilerleme | FAQ | — |

Kanıt boşluğu: gerçek kullanıcı yorumu, kullanıcı sayısı, uzman/pedagog görüşü, okul ortaklığı **yok** ve yazılmaz.

## 4. Öncelikli aksiyon listesi

1. (P0) Footer mağaza rozetlerini ve fiyat güven rozetlerini yayından çıkar/koşula bağla. *Kolaylık: yüksek, etki: yüksek (ICE).*
2. (P0) robots/sitemap/OG kararı: lansman tarihi belli olunca tek paket.
3. (P1) Rıza sonrası UTM ilk-temas kaydı → sosyal medya ölçümünün ön koşulu.
4. (P1) Demo sonucu → veli kaydı geçişini ekran görüntüsüyle incele.
5. (P2) Kitle rozetini ve sosyal hesap bağlantılarını netleştir.

## 5. Tek deney önerisi

**Hipotez (Hipotez):** Sosyal medyadan gelen velilerde hero ikincil CTA'sını "Veli hesabı oluştur" yerine "Örnek veli raporuna bak" (örnek rapor bölümüne çapa) yapmak, `veli_kayit_baslatildi` oranını artırır.
- **Segment:** UTM'li organik sosyal trafik · **Tek değişken:** ikincil CTA metni/hedefi · **Ana metrik:** `demo_tamamlandi` → `veli_kayit_baslatildi` oranı (çerez onaylı oturumlar) · **Koruma metriği:** demo tamamlama oranı ve geri dönüş (sayfadan çıkış) · **Baseline:** yok; önce 30 gün referans ölçümü (K-0193 tetikleyicisi). **Yeterli trafik yoksa A/B yürütülmez**; önce görev bazlı 5 veli ile kullanılabilirlik gözlemi. Karar kuralı yalnız GIE A/B motoru ve ön kayıtlı deney tanımıyla.
- Not: Çocuk akışına deney konmaz; fiyat/yıllık paket bu deneyde değişmez (K-0193).

## 6. Çelişkiler / raporlanan farklar

- `decisions.md` 2026-10-09: "iddialar kalsın" koordinatör kararı ↔ 2026-10-28: A/C varyantlarında bu iddialar kullanılmaz ↔ K-0196 tek seferlik ödeme. **ÇÖZÜLDÜ (2026-10-29, proje sahibi devri):** dört rozet ve "%40 tasarruf" hiçbir kolda kullanılmaz; yerine doğrulanabilir ödeme şeffaflığı ifadeleri (`decisions.md` "Güven rozetleri çelişkisi"). Uygulama yayın öncesi listede (§0, Y2).
- Bulgu 4 (kanal/UTM atfı) **kapandı (kod)**: 2026-10-29 K-0199, `web-panel/src/lib/analytics/utm.ts`. Kalan: hane/kaynak kaydı (migration, ana oturum).
- `PricingSection` kodunda `yearlyNote` ("%40 tasarruf") görünmüyor (i18n'de var, bileşende kullanılmıyor); güvenli, ama silinmeli.
- Kartsız deneme "karar" olarak var (K-0193/0194, `DENEME_SINIR_KURALI`), arayüzde ve ödeme akışında yok; sosyal medya bunu vaat edemez.
