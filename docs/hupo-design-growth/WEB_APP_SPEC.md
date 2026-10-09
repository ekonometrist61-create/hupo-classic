# Hupolingo Flutter Web (app.hupolingo.com) – Masaüstü/Tablet UX Spesifikasyonu
Sürüm: 1.0 / 9 Ekim 2026. Hedef: aynı Flutter kod tabanı (`mobile-app`), telefon deneyimi değişmez.
Kaynak: `root_shell.dart`, `responsive_page.dart`, `quiz_screen.dart`, `home_screen.dart`, `theme/app_theme.dart`. `result_screen`, `learn_screen`, `league_screen` ve `answer_option`/`game_card` bu spesifikasyon için OKUNMADI; uygulayıcı önce bunları açıp tablodaki varsayımları doğrulasın.
Kapsam dışı: reklam, analitik/takip SDK'sı, satın alma/fiyat (satın alma yalnızca veli panelinde), web push (kapalı kabul edilir; doğrula), yeni renk/asset, URL/deep-link yönlendirmesi.

## 1. Kırılımlar
Ölçüt `MediaQuery.sizeOf(context).width`. Yeni yardımcı: `lib/utils/breakpoints.dart` (`isTablet` 600–1023, `isDesktop` ≥1024; sabitler tek yerde).

| Genişlik | Gezinme | İçerik | Not |
|---|---|---|---|
| <600 | Alt `NavigationBar` (mevcut) | Mevcut | Hiçbir şey değişmez. |
| 600–1023 | Alt `NavigationBar` | Ortalı, max 720 | Hero/başlık arka planı tam genişlik kalır, içeriği `ResponsivePage(maxWidth: 720, padding: EdgeInsets.zero)` ile sınırla (iç boşluk mevcut kalsın). |
| ≥1024 | Sol `NavigationRail` | Ortalı, max 1100 | Alt bar kalkar. |

**NavigationRail (≥1024)** – `RootShell` içinde `Row[NavigationRail, VerticalDivider(width:1), Expanded(IndexedStack)]`.
- Sekmeler `_sekmeler` listesinden aynen: Ana Sayfa, Öğren, Arena, Koleksiyon, Profil; aynı ikon/seçili ikon, aynı `shellTabProvider`. Sekme listesi çoğaltılmaz, tek kaynak kalır.
- `labelType: all`, `minWidth: 96`, zemin `AppColors.surface`, gösterge `AppColors.primarySoft`, seçili ikon/etiket `AppColors.primary` (alt çubuktaki stil kuralı: seçili w900, diğeri w700 `muted`, 12 sp).
- Üstte (leading) küçük Hupo (`HupoMood.greeting`, size 48, statik) – altın sarısı başka yerde kullanılmaz.
- `PopScope` mantığı (geri → Ana Sayfa) aynen kalır. Sekme durumu korunur (`IndexedStack`).
- Genişlik küçülünce (pencere yeniden boyutlanınca) alt bara geçilir; seçili sekme ve quiz durumu kaybolmaz.

**Ana Sayfa masaüstü düzeni (≥1024, içerik max 1100):** Hero tam genişlik, altında iki sütun: sol (≈60 %) "Bugünkü hedefin" + "Kaldığın yer"; sağ (≈40 %) "Bugünkü odakların" (ders kartları). Tek sütunlu sıra ve bölüm başlıkları aynı (en fazla 3 odak kuralı). 600–1023: tek sütun, ders kartları 2 sütun grid.

**Sağ özet paneli (isteğe bağlı, P2):** yalnızca ≥1280 ve sekme 0–2'de, genişlik 280. Yeni provider gerekmez: `dailyGoalProvider` (günlük hedef), `statsProvider` (XP, seviye, seri), `myQuestsProvider` (X/Y görev), `dueCountProvider` (tekrar). Yükleme/hata durumunda panel gizlenir (içerik zaten ana ekranda). Panel ana eylem içermez; satırlar ilgili ekrana bağlanır. Veri yoksa `SizedBox.shrink()`.

## 2. Quiz ekranı (masaüstü)
**Karar: TEK SÜTUN.** Gerekçe: (a) soru → şık okuma sırası dikey; iki sütun göz sıçraması ve karşılaştırma yükü yaratır, 9–11 yaş için bilişsel yük artar; (b) sorular uzun metin/görsel/formül içerebilir (`SoruMetni`), yan yana yerleşim taşma riski doğurur; (c) mobil ile aynı akış, tek bakım yolu; (d) şık harfleri A–D ile klavye eşlemesi doğrusal. Masaüstünde fark: içerik max 760 ortalı, soru 24 sp, `QuizTopBar` ve sonuç sayfası aynı genişlikte. Quiz `MaterialPageRoute` ile kabuğun üstüne açıldığı için rail görünmez (odak modu) – korunur.
- `ResultSheet` ≥600'de `ConstrainedBox(maxWidth: 760)` + `Align(bottomCenter)`; üst köşeler yuvarlak. Liste alt boşluğu `min(0.45*yükseklik, 360)`.
- Şıklar tek sütun, her biri tam genişlik, yükseklik ≥56, aralık 10 (mevcut).

**Klavye** (`Focus(autofocus: true)` + `onKeyEvent`, yalnızca `KeyDownEvent`; `KeyRepeatEvent` yok sayılır; üstte diyalog açıksa (`ModalRoute.of(context)?.isCurrent != true`) kısayollar çalışmaz):
| Tuş | Durum | Davranış |
|---|---|---|
| 1–4 veya A–D (büyük/küçük) | cevap beklerken, `!locked` | `question.options` sırasındaki n. şıkkı `_submit` eder (dokunmayla aynı yol). Şık sayısı dışındaki tuş yok sayılır. |
| ↑ / ↓ | cevap beklerken | Şıklar arasında odak gezdirir (Tab ile aynı). |
| Enter veya Space | odakta şık varsa | O şıkkı gönderir. |
| Enter | `_result != null` | `_next()` (Devam/Bitir). Sonuç göründükten sonraki ilk 400 ms'de yok sayılır (geri bildirimi okumadan atlamayı önler). |
| Esc | her zaman | Çıkış onayı diyaloğu (bölüm 5). Diyalogda Esc = "Devam et". |
- Süre sayacı: onay diyaloğu açıkken durur (`_ticker` iptal, `_stopwatch.stop()`), "Devam et" ile sürer; "Çık" `Navigator.pop`. `_submitting` sırasında Esc diyalog açar fakat gönderim sürer.
- Çıkış onayı yalnızca `kIsWeb`; `QuizTopBar.onClose` (X) de aynı diyalogu açar. Telefon/native davranışı değişmez.
- Hata: cevap gönderilemezse mevcut snackbar ve süre devamı aynen.

**Şık durumları** (`AnswerOption`, tema renkleri; doğruluk renkle tek başına verilmez, mevcut ikon/etiket kalır):
- idle: surface + `line` kenar; hover: kenar `primaryLight`, zemin `primarySoft`, 120 ms; odak: odak halkası (bölüm 3); pending: mevcut; correct/wrong/dimmed: mevcut. Cevap sonrası ve `locked` iken hover/odak vurgusu yok, imleç `basic`.
- Hover doğru/yanlış sinyali vermez.

**Kısayol ipucu:** soru kartının altında, şıkların üstünde değil; şıklardan sonra tek satır `appText(size: 13, color: AppColors.muted)`; yalnızca `kIsWeb && isDesktop` (veya ilk klavye olayı alındıktan sonra tablette). Dokunmatik cihazda gizli. Metin bölüm 5.

## 3. Fare ve klavye genel kuralları
- **İmleç:** tıklanabilir her `GameCard`/`ChunkyButton`/şık/rail öğesi `SystemMouseCursors.click`; devre dışı `basic`. Metin seçimi gereken yerde (soru metni) `SelectionArea` kullanma; kopyalama önerilmez (sorular çalınmasın diye değil, oyun akışı için – karar: seçilemez bırak).
- **Hover** (yalnız fare/pointer): kartlar 120 ms (`motionMs` ile; reduced motion'da anında) – kenar `lineDark` → `primaryLight`, gölge/kabartma 2 px yukarı. Altın sarısı hover rengi olarak kullanılmaz. Hover tek başına bilgi taşımaz.
- **Odak halkası:** tek paylaşılan sarmalayıcı `HupoFocus` (yeni, `widgets/ui/`), `FocusableActionDetector` ile; yalnızca klavye odağında (`FocusHighlightMode.traditional`) 3 px `AppColors.primary` halka + 2 px `surface` iç boşluk, köşe yarıçapı çocuk bileşenle aynı. Koyu (navy/hero) zeminde halka `Colors.white`. `primary` (#147D8A) krem/beyaz üzerinde ≥3:1 hedeflenir; ölçüm bu belgede YAPILMADI – uygulayıcı doğrulasın. Halka kırpılmamalı (ListView clip padding).
- **Tab sırası:** görsel sıra (soldan sağa, yukarıdan aşağıya); rail → içerik. Rail'de ↑/↓ ile gezinme (Flutter varsayılanı). Diyalog açılınca odak diyaloğa gider, kapanınca tetikleyiciye döner.
- **Hedef boyutlar:** tüm dokunma/tıklama hedefleri ≥48×48 (çocuk yüzeyi: şık ≥56, ana buton ≥52). Fare cihazda küçültme yok.
- **Metin/ölçek:** tarayıcı yakınlaştırma %200'e kadar bozulmaz; `maxWidth` kuralları korunur. Tekerlek/trackpad ile kaydırma çalışır; `RefreshIndicator` fare ile çalışmaz → Ana Sayfa'da ≥600'de başlık yanına "Yenile" `IconButton` (tooltip: "Yenile") ekle.
- **Tooltip:** yalnız ikon butonlarda (mevcut `tooltip` alanları kalsın; rail öğeleri etiketli).
- **Sağ tık/çift tık/sürükle:** özel davranış yok.

## 4. Ekran tablosu
| Ekran | Hedef | Ana eylem | Durumlar | Kabul kriteri |
|---|---|---|---|---|
| **home** | Öğrenci bugün ne yapacağını 5 sn içinde görür | Bir ders kartı → quiz başlat (ya da Günün Tekrarı) | Yükleniyor: `HupoLoading`. Boş: ders yok → "Sorular yolda!" (mevcut). Hata: "Profilin yüklenemedi…" + Tekrar dene; dersler için `InlineRetry`. Kota dolu: quiz'e girişte P0402 → quiz tarafında diyalog (home'da kota göstergesi yok; yeni uydurma yok). Gizlilik bildirimi ilk girişte tam ekran (mevcut). | 1280 px'te rail + iki sütun, yatay kaydırma yok; 700 px'te tek sütun/720; 390 px'te bugünkü düzen birebir; Tab ile tüm kartlara ulaşılır, odak görünür; hover imleç el. |
| **quiz** | Soruyu rahat okuyup cevaplamak, kesintisiz akış | Şık seç → Devam | Yükleniyor: `QuizLoadingCard`. Boş: `emptyMessage` snackbar (mevcut). Hata: yükleme "Sorular yüklenemedi…" snackbar; gönderim "Cevabın gönderilemedi…". Kota dolu P0402: mevcut diyalog (barrierDismissible false), Enter/Esc ve butonla kapanır, sonra quiz kapanır; ödeme/fiyat metni yok. | Klavyeyle (1–4/A–D, Enter, Esc) tüm quiz fareye dokunmadan bitirilebilir; çift gönderim olmaz (tuş yinelemesi, hızlı Enter); Esc diyaloğunda süre durur; ipucu satırı dokunmatikte yok; 1280 px'te soru ve şıklar ≤760 px kolonda. |
| **result** | Sonucu anlamak, devam etmek | "Devam" (sonraki görev / Ana Sayfa) | Boş: sonuç listesi boşsa Ana Sayfa'ya dön butonu (varsayım, doğrula). Hata: yok (yerel sonuç). Kota dolu: n/a. Kutlama azaltılmış harekette statik. | İçerik max 760 ortalı; Enter birincil eyleme gider; XP/doğru-yanlış özeti ilk bakışta; konfeti `reducedMotion` ile kapalı; kutlamayı atlama yolu var. |
| **learn** | Konu seçip öğrenmeye geçmek | Konu/ders seç → çalış | Yükleniyor/boş/hata: ekranın mevcut durumları korunur (doğrula, eksikse home'daki `HupoLoading`/`InlineRetry` desenini kullan). Kota dolu: konu açılışında P0402 gelirse quiz diyaloğu. | ≥1024'te liste 2 sütun grid, max 1100; ≥600 <1024 max 720; kartlar klavye ile odaklanır ve Enter ile açılır. |
| **league** | Haftalık konumunu ve sağlıklı rekabeti görmek | Sıralamayı incele → "Çalışmaya devam" | Yükleniyor: `HupoLoading`. Boş: lig yok / takım dolmamış → ilk yararlı eylem (soru çöz). Hata: `InlineRetry`. Kota dolu: n/a. Başka çocuğun tam adı gösterilmez (mevcut kural neyse korunur; doğrula). | Tablo/satır max 720 ortalı, kendi satırın vurgulu; ad kısaltmaları taşmaz; yeşil/amber yalnız ikon+metinle birlikte; klavye ile kaydırılabilir. |

Not: `leagueProvider` ana sayfada `valueOrNull` ile çalışıyor; hata durumunda kart gizlenir (mevcut).

## 5. Web'e özel metinler (const Türkçe, "sen" dili)
| Yer | Metin |
|---|---|
| Web açılış/yükleme (ilk karşılama, `HupoLoading.message`) | `'Hupo geliyor, bir saniye…'` |
| Profil sekmesi alt satırı, yalnız `!kIsWeb` (native app'te bilgi; `app.hupolingo.com` bağlantısı/kopyala `IconButton`, tooltip `'Bağlantıyı kopyala'`) | `'Bilgisayardan da girebilirsin: app.hupolingo.com'` |
| Kopyalandı snackbar | `'Bağlantı kopyalandı.'` |
| Quiz çıkış onayı – başlık | `'Çıkmak istiyor musun?'` |
| Quiz çıkış onayı – gövde | `'Çözdüğün sorular kayıtlı kalır. Kalan sorular için sonra yeni bir tur başlatabilirsin. Sen karar verirken süre durur.'` |
| Çıkış onayı – butonlar | Birincil: `'Devam et'` (varsayılan odak), ikincil: `'Çık'` |
| Quiz kısayol ipucu | `'Klavye: 1–4 veya A–D ile seç · Enter ile devam et · Esc ile çık'` |
| Yenile ikon tooltip | `'Yenile'` |
Doğrulanması gerekenler: "Çözdüğün sorular kayıtlı kalır" – `submitAnswer` her soruda sunucuya gittiği için doğru görünüyor, ama tur özeti/XP'nin yarım turda nasıl işlendiği test edilmeli; yanlışsa gövdeyi kısalt. "Bilgisayardan da girebilirsin" satırını web build'de gösterme.

## 6. Uygulama sırası ve doğrulama
1. `breakpoints.dart` + rail (`RootShell`) + içerik genişlik sınırı (P0).
2. `HupoFocus` + hover/imleç (`GameCard`, `ChunkyButton`, `AnswerOption`) (P0).
3. Quiz klavye, çıkış onayı, ipucu, `ResultSheet` genişlik (P0).
4. Home iki sütun, learn/league grid, Yenile butonu (P1). Sağ panel (P2).
5. Kontrol: `flutter analyze`; `flutter build web`; tarayıcıda 390, 768, 1280 genişliklerinde ekran görüntüsü; yalnız klavye ile tam quiz; pencere yeniden boyutlandırma sırasında quiz durumu korunur; çocuk profili ile P0402 yolu. Kontrast ölçümü ve gerçek görüntü incelemesi çalıştırılmadan "tamamlandı" denmez.
