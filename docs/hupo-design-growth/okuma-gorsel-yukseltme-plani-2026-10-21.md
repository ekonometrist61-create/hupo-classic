# HupoRead (Okuma Dünyası) görsel ve içerik sunumu yükseltme planı

- Tarih: 2026-10-21
- Durum: **PLAN.** Kod ve içerik değiştirilmedi; yalnızca okundu ve planlandı.
- Girdiler: `HupoRead_PDF_ve_89_Ikon_Tam_Paket.zip`, `HupoRead_ Renkli Okuma Macerası.png`, mevcut okuma kodu, `okuma-platform-denetimi-2026-10-21.md`, `okuma-gorsel-kutuphane-2026-10-21.md`.

## 0. Kalite çıtası

Kullanıcının verdiği iki referans (PNG "Renkli Okuma Macerası" ve PDF "Feneri Kim Yakıyor?" tasarım örneği) bu planın kabul çıtasıdır. Hiçbir ekran veya PDF bu referansların altında kalmamalıdır. Kabul, referansla yan yana karşılaştırmayla yapılır.

Görsel üretim bugün blokeli (K-0074). Bu yüzden ilk fazlarda sahne illüstrasyonları eksik kalacak. Bu fark raporlanacak. Boşluk, ikon, tipografi ve yerleşim tarafında kapatılacak; illüstrasyonsuz bir sürüm referansın kalitesine ulaşmış sayılmayacak.

## 1. Doğrulanan gerçekler

| Kaynak | Bulgu | Kanıt |
|---|---|---|
| ZIP ikon seti | 178 SVG + `manifest.json` repodaki `assets/okuma/hikaye_ikonlari/` ile birebir aynı. | SHA-256 karşılaştırması: 179/179 eşleşti, fark 0. Yeni import gerekmiyor. |
| ZIP ikon lisansı | Repoda ikon için kaynak/lisans belgesi yok. Fontlarda `KAYNAK` ve OFL dosyası var. | Dosya listesi. |
| ZIP token dosyası | Palet uygulamanın `AppColors` paletiyle uyuşmuyor: sarı `F5B73D` ↔ `sun F5C842`, lacivert `17344D` ↔ `ink 17324D`, turkuaz `48AFCC` ↔ `primary 147D8A`. | `design_tokens.json`; `app_theme.dart` (AppColors). |
| PDF paleti | PDF kodu zip değerlerini kullanıyor (lacivert, sarı, turkuaz, soluk). | `okuma_pdf_hikaye.dart:35-41`. |
| PDF yazı tipi | Gövde Literata, başlık Nunito, gömülü. Brief ile uyumlu. | `okuma_pdf_hikaye.dart:27-30`. |
| PDF maskot | `_maskotPng()` iki yerde çağrılıyor. Filigran/opaklık kullanımı aramada bulunmadı, ama yerleşim görsel olarak doğrulanmadı. | `okuma_pdf_hikaye.dart:121, 375`. |
| PNG ritmi | Üç adım: **Oku → Keşfet → Düşün**. | PNG. |
| Mevcut okuyucu | Sayfa ilerleme var. Kelime, deyim ve atasözüne dokununca alt sayfa açılıyor; bu, PNG'deki "Keşfet" adımının büyük kısmı. "Düşün" adımı yok. | `okuyucu_ekrani.dart:172-231`. |
| Emoji kuralı | PNG'de satır içi emoji var (🚲 🏁 ❤️). Brief kuralı `emojiAsStoredStoryContent: false`. Mevcut okuyucuda "çıkartma (emoji, en çok 3)" stili tanımlı. | PNG; brief; `okuyucu_ekrani.dart:16`. |
| Veri sözleşmesi | Paket alanları: `sorular` (`dayanak_sayfa`), `sozluk` (isteğe bağlı), `ogrenme_hedefleri`. Sahne görseli, düşünme sorusu, ikon anotasyonu alanı yok. | `okuma_models.dart`; "gorsel/sahne/kapak" aramasında eşleşme yok. |
| İkon kapsamı | 89 kavramda bisiklet, bayrak, kalp, güneş, yıldız, fener, tekne, el var. Balon ve alkış eli yok. | Dosya listesi. |
| Maskot | `karakter_hayvan_hupo_kus.webp` dosyası görüntülendi: turuncu saçlı bir çocuk çiziyor, kuş değil. PNG'deki yeşil-sarı kuşla eşleşmiyor. Onaylı master hangi dosya belli değil. | Görüntüleme. → K5. |
| Görsel üretim | Nano-banana anahtarı bayat (`API_KEY_INVALID`, K-0074). Bu oturumda MCP bağlantısı da zaman aşımına uğradı (`CONNECT_TIMEOUT`). | K-0074; oturum durumu. |

Denetimle çakışan tasarım maddeleri:
- OK-07: 2.0 yazı ölçeğinde başlık kelime ortasından kırılıyor.
- OK-12: Sade mod vurgu bütçesi metinle tutarsız.
- OK-13: Kelime dokunma hedefi küçük.
- OK-06: Sonuç ekranındaki `': . .'` erişilebilirlik etiketi.

## 2. Referans ile bugün arasındaki boşluk

| Alan | Referans | Bugün | Boşluk |
|---|---|---|---|
| Palet | Tek sistem (PNG ve PDF aynı renkler) | AppColors + PDF'de zip hex'leri | İki palet |
| Okuma ritmi | Oku / Keşfet / Düşün | Sayfa + sözlük alt sayfası | "Düşün" yok |
| Emoji | İkon hissi, satır içi | Emoji stili (en çok 3) | Kural çelişkisi |
| Sahne görseli | Her sayfada illüstrasyon | Yok (üretim blokeli) | Büyük boşluk |
| Kelime keşfi (eski/yeni) | Görsel çift | Yok | İçerik + görsel |
| Atasözü | Krem blok + "Anlamı" | Blok var, anlam alt sayfada | Küçük |
| Ödül | "Yeni şey öğrendin" yıldızı | Yok | Sözlüğe ekleme eylemine bağlanmalı |
| Üst çubuk | Geri, logo, Aa, kalp | Yazı boyutu ve favori ikonları var | Birebir doğrulanmadı |

## 3. Kararlar

Kararların hepsi kullanıcı onayı bekliyor. Öneriler işaretli.

- **K1 Palet.** AppColors tek kaynak olur. PDF tokenları AppColors'tan türetilir; zip hex'leri referans olarak kalır. **Öneri: evet.** Brief de "ikinci bir marka kimliği üretme" diyor.
- **K2 Düşün adımı.** Paket sözleşmesine editör onaylı bir `dusun` alanı eklenir (hikâye veya sayfa bazında 1–2 soru). Veri yoksa adım gizlenir; uygulama soru uydurmaz. **Öneri: evet.**
- **K3 Emoji.** Satır içi emoji kaldırılır, yerine manifest ikonları (SVG) gelir. "Çıkartma" stili ikon anotasyonuna dönüşür. Yoğunluk brief'in yaş tablosuna göre: 2–4. sınıf sayfa başına en fazla 5, 5–6. sınıf 3, 7–8. sınıf 2. **Öneri: evet.**
- **K4 Sahne görselleri.** F1–F3 görselsiz yapılır (ikon, vektör, tipografi). Sahne üretimi nano-banana düzelince başlar. **Öneri: evet.** Kalite farkı belgelenir.
- **K5 Maskot.** Onaylı Hupo master dosyası ve hangi karakterin maskot olduğu proje sahibi tarafından teyit edilir. PNG'deki kuş referans olarak değil, master ile karşılaştırılır. **Engel:** Maskotlu kapak ve sonuç ekranı F1'de bekler.
- **K6 İçerik sözleşmesi.** `dusun`, ikon anotasyonu ve `atasoz` anlamı alanları canlı Supabase paketini değiştirir. Migration ve sürüm artışı gerekir. Kullanıcı onayı olmadan uygulanmaz.

## 4. Faz planı

### F0 — Karar ve doğrulama (kod yok)
1. K1–K6 yanıtı; maskot master teyidi.
2. Kabul şablonu: her önemli ekran için hedef, ana eylem, durumlar, kabul kriteri (CLAUDE.md zorunluluğu) ve referansla yan yana karşılaştırma.
3. Doğrulama: karar fazı, kod testi yok.

### F1 — Görsel sistem tutarlılığı (yalnızca mevcut veri)
1. PDF paletini AppColors'a eşle (`okuma_pdf_hikaye.dart:35-41`).
2. PDF'de maskot filigranı ve opaklık olmadığını doğrula; `_maskotPng()` kullanım yerlerini gözden geçir.
3. Okuyucudaki emoji "çıkartma" stilini SVG ikona çevir (K3).
4. Denetim maddeleri: OK-07, OK-12 (mevcut karar #5), OK-13, OK-06.
- **Kabul:** 390 px ve 360x640 ekran görüntüsü, önce/sonra. 2.0 yazı ölçeğinde kırılma yok. PDF örnekleri 2., 5. ve 8. sınıf için Türkçe karakter ve metin sadakati kontrolünden geçer.
- **Doğrulama:** `flutter analyze`, ilgili testler, cihaz veya emülatör görüntüsü. Görsel kontrol yapılmazsa raporda "DOĞRULANMADI" yazılır.

### F2 — Okuyucu ritmi: Oku / Keşfet / Düşün
1. Adım göstergesi: 1 Oku · 2 Keşfet · 3 Düşün. Verisi olmayan adım gizlenir.
2. Keşfet: mevcut sözlük alt sayfası. Sesli dinleme (PNG'deki "dinle") ayrı bir TTS kararıdır; bu planda ertelendi.
3. Düşün: atasözü bloğu, anlamı, düşündürücü soru ve "Sözlüğe ekle". "Yeni şey öğrendin" yalnızca sözlüğe ekleme gerçekleşince gösterilir. XP veya süre ile karıştırılmaz.
- **Kabul:** Üç adım klavye ve ekran okuyucuyla sırayla gezilir. Düşün verisi olmayan hikâyede görünmez. Hareket azaltma ve 2.0 ölçek çalışır.

### F3 — İçerik sözleşmesi (K2 ve K6 onayından sonra)
1. `dusun`, `atasoz` anlamı ve ikon anotasyonu alanları eklenir; manifest şema sürümü artırılır; sha256 yeniden hesaplanır.
2. Migration, K-0069'daki canlı migration akışıyla yapılır.
3. Editör onayı: üretilen düşünme soruları `onayli=false` ile taslak kalır; yayınlanmaz.
- **Onay:** Uzak veritabanı değişikliği kullanıcı onayı gerektirir.

### F4 — Görsel varlık hattı (engelli)
1. K-0074 anahtarı yenilenince sahne, kapak ve eski/yeni kart görselleri üretilir. Referans PNG'nin stiline göre stil kilidi yapılır (deneme partisi).
2. Telif: PNG ve ZIP görselleri ürün varlığı olarak kullanılmaz; kaynağı ve lisansı belirsiz. Özgün üretim promptları (`okuma-varlik-promptlari.json`) esas alınır.
3. Anahtar düzelmezse kapak ve sahneler için vektör (SVG) alternatifi değerlendirilir; maliyeti ayrıca çıkarılır.

### F5 — QA ve yayın kapısı
1. Otomatik: `flutter test` (okuma testleri), PDF metin sadakati testi (PDF paragrafları = paket metni), ikon ID'lerinin manifestte bulunması.
2. Görsel: referansla yan yana karşılaştırma, üç yaş grubu, ink-saver baskı.
3. Yayın kapısı: denetimdeki Kritik OK-01 (yasak ad listesi) kapanmadan canlıya alınmaz. Mevcut kural.

## 5. Riskler
- Sahne illüstrasyonlarındaki kalite farkı F4'e bağlı; kullanıcı beklentisiyle çakışabilir.
- Maskot kimliği belirsiz (K5).
- İkon kaynağı ve lisansı belgesiz.
- Emoji kaldırılması, çıkartma kullanan mevcut hikâyelerle çelişebilir. Kullanım taranmalı.
- Sözleşme değişikliği canlı içeriği kırabilir; sürüm uyumluluğu şart.

## 6. Doğrulama durumu
- Bu oturumda kod değişmedi; yalnızca okuma yapıldı.
- **Doğrulandı:** ZIP ve repo SHA-256 eşleşmesi; palet farkı (kod); Keşfet alt sayfası ve çıkartma stili (kod); veri alanları (kod); `hupo_kus` görüntüsü.
- **Doğrulanmadı:** Cihazda görünüm; PDF'nin görsel çıktısı; PNG'deki maskotun master ile eşleşmesi; nano-banana bağlantısı (bu oturumda zaman aşımı).
