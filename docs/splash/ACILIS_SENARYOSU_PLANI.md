# Hupolingo mobil açılış: teşhis, senaryo ve üretim planı

> Tarih: 28 Ekim 2026 · Konu: MOB/TSR · Durum: **PLAN — Faz 1 onayı bekliyor** (hiçbir kod değişmedi)
> Mevcut sistemin bakım belgesi: [BAKIM.md](BAKIM.md) (Kanat İmzası, 10 Ekim 2026)
> **Doğrulama durumu:** Baseline **gerçek cihazda alındı** (Samsung SM-S711B, Android 16, profile derleme,
> ekran kaydı + kare kare inceleme; §1.1). Kanıt: [baseline-2026-10-28/](baseline-2026-10-28/).
> Ölçülmeyenler: kare süresi/jank (DevTools yok), düşük uç cihaz, iOS.

---

## 1. Teşhis: açılış neden "profesyonel" görünmüyor?

Sebepler önem sırasıyla. Her madde koddan veya asset'in kendisinden doğrulandı.

| # | Bulgu | Kanıt |
|---|-------|-------|
| 1 | **İlk iki saniyede üç farklı Hupo görünüyor.** Android 12+ sistem splash'i yuvarlak, mavi zeminli bir Hupo *kafası* gösterir; iOS eski çizimli, ayakta duran bir Hupo; Flutter sahnesi ise kanat kaldıran üçüncü bir poz. Sistemden uygulamaya geçişte karakter değişiyor, boyutu ve yeri sıçrıyor. | `android/.../mipmap-xxxhdpi/ic_launcher_foreground.png`, `ios/.../LaunchImage@3x.png`, `assets/hupo/uygulama/hero_splash.webp` |
| 2 | **Hareket "kaydırılan çıkartma" gibi.** Karakter tek katmanlı bir görsel; yalnızca yukarı kayıyor, büyüyor, belirginleşiyor. Göz kırpma, kanat, baş hareketi yok. Bunu BAKIM.md §5 de kabul ediyor. | `hupo_signature_entrance.dart` `_HupoGovdesi` |
| 3 | **Marka imzası yok.** "Hupolingo" yalnızca Nunito 900 düz metin. Logo kilidi (karakter + kelime işareti) yok; repoda resmî logo dosyası da yok (PROJE_GUNLUGU.md, "TailAdmin logosu → onaylı Hupo maskotu" notu, satır ~3651). | `hupo_signature_entrance.dart:176` |
| 4 | **Dekor karaktere bağlı değil.** Sağ üst köşede bokeh, altın halka ve hilal ışık yayı genel "efekt" hissi veriyor. Hero görselin içinde zaten sarı vurgu çizgileri var; üstüne bir de çizilen efektler çakışıyor. | `_BokehPainter`, `_GoldenRingPainter`, `WingSignaturePainter` |
| 5 | **Tam sahne her soğuk açılışta oynuyor (1,6 s + 0,35 s solma).** Açılış türü kararı yalnızca `false/false` ile çağrılıyor; `warmStart`, `resume`, `directRedirect` kolları hiç çalışmıyor. "İlk açılış" ile "sonraki açılış" aynı sahneyi oynuyor. Marka sesi de her seferinde çalıyor. | `splash_screen.dart:60-70`, tek çağrı yeri |
| 6 | **Sahne süreci geciktiriyor.** `runApp`, `Supabase.initialize` ve `SharedPreferences` beklendikten sonra çağrılıyor; Flutter sahnesi bu bitmeden başlayamıyor. Süre ölçülmedi, etkisi bilinmiyor. | `main.dart:26-44` |
| 7 | **Sahneden sonra karşılama yok.** İlk kez giren çocuk sahneden doğrudan Giriş formuna düşüyor. Sınıf seçimi yalnızca Profil ve Kelime oyunundan açılıyor; ilk girişte yönlendirme bulunamadı (başka yerde olabilir, doğrulanmadı). | `login.dart`, `GradePickerScreen` çağrı yerleri |
| 8 | **Sahne → Giriş geçişinde yine Hupo değişiyor.** Büyük `hero_splash` solup yerine küçük `welcome` pozu geliyor; ortak eleman (Hero) geçişi yok. | `splash_screen.dart`, `auth_widgets.dart:32` |

### 1.1 Cihaz baseline (28 Ekim 2026, Galaxy S23 FE, profile)

Kayıt: ilk açılış (veri sıfırlı) ve sonraki soğuk açılış. Kare görselleri `baseline-2026-10-28/`. İki açılış **aynı sahneyi** oynuyor.

| Ölçü | Değer |
|------|-------|
| `am start -W` TotalTime (ilk kare) | 1256 ms (ilk), 842 ms (sonraki) |
| Simgeye dokunuştan Giriş ekranına | ≈ 2,9 – 3,0 s (≈ 1,1 s sistem splash + ≈ 1,9 s Flutter sahnesi) |
| Her soğuk açılışta tam sahne | Evet (ikinci kayıtta da) |

Kayıttan çıkan **yeni** bulgular (kod okumasında görünmemişti):

| # | Bulgu | Kanıt |
|---|-------|-------|
| 9 | **"Hupolingo" yazısı yanlış çiziliyor:** Nunito 900 yerine geri dönüş (tek aralıklı) fontla, **çift sarı-yeşil alt çizgiyle**. Sahne `Material`/`DefaultTextStyle` altında olmadığı için Flutter'ın "eksik Material" varsayılanı devreye giriyor. Sahnenin en görünür kusuru ve tek satırlık düzeltme. | `kelime-isareti-yakin-plan.png` |
| 10 | **Hupo bir an kayboluyor:** sistem splash'indeki kafa ikonu söndükten (≈ 2,0 s) sonra Hupo'nun görünmediği yaklaşık 0,3 s'lik boş turkuaz kare var; tam boy Hupo ≈ 2,3 s'de beliriyor. Bu, plandaki "birebir ilk kare" ihtiyacının somut hâli. | `ilk-acilis-kareler.png` (2014 → 2300 ms) |
| 11 | **Gezinme çubuğu rengi sıçrıyor:** sistem splash'inde turkuaz, Flutter sahnesinde açık gri bant. | aynı kareler, alt kenar |
| 12 | **Solma sırasında çift pozlama:** 3,4 s'de büyük Hupo + halka, Giriş formunun üstünde yarı saydam görünüyor (≈ 0,35 s). | `ilk-acilis-kareler.png` (3411 ms) |
| 13 | **Altın "hilal yay" ince, kopuk bir çizgi gibi okunuyor**, parıltı değil; sahne ortasında hata gibi duruyor. | 2574 – 2901 ms |

### 1.2 Faz 1 sonucu (28 Ekim 2026, aynı cihaz, profile)

Kanıt: `baseline-2026-10-28/faz1-sonrasi-*.png`. Yapılan: bulgu 1, 5, 9–12 kapatıldı.

| Bulgu | Sonuç (cihaz kaydı) |
|-------|---------------------|
| 1 Üç farklı Hupo | Android 12+ sistem splash'i artık sahneyle aynı tam boy Hupo; kayıtta sistemden Flutter'a boyut sıçraması yok. **iOS: varlıklar üretildi, cihazda/simülatörde doğrulanmadı.** |
| 5 Her açılışta tam sahne, her seferinde ses | İlk açılış 2,0 s + ses; sonraki açılış 0,9 s, sessiz. Ses yalnız ilk açılışta **(kodla ve testle doğrulandı; kulakla dinlenmedi)**. |
| 9 Yazı | "Hupolingo" Nunito, beyaz, alt çizgisiz; halka tam görünüyor. Regresyon testi var (düzeltme kaldırılınca kırıldığı doğrulandı). |
| 10 Boş kare | Yok; Hupo ilk Flutter karesinde de görünür. |
| 11 Gezinme çubuğu | Sahne boyunca turkuaz (kayıtta açık gri bant yok). |
| 12 Çift pozlama | Yok; ön plan önce solar, düz zemin perde gibi açılır. |

Süre (simge → Giriş, tek ölçüm, startup değişkenliği ±0,5 s): sonraki açılış ≈ 2,0–2,2 s (önceden ≈ 2,9 s). `am start -W` TotalTime 973–1974 ms (sistem başlatma gürültüsü; karşılaştırma için tek başına güvenilmez).

**Faz 1'de bilerek yapılmayanlar:** `runApp`'in init'ten önce çağrılması (ölçüm yok; kazanç kanıtlanmadan değişmedi; yalnız Hupo görseli ilk kareden önce çözülüyor); Giriş/Ana sayfaya ortak eleman (Hero) geçişi (Faz 4'te yeni Hupo rig'iyle). Bulgu 2, 3, 4, 7, 13 sonraki fazlarda.
**Doğrulanmayanlar:** kare süresi/jank, düşük uç cihaz, iOS, TalkBack, reduced-motion cihazda. Telefona kurulan APK, dokunarak atlama zamanlayıcısını `Stopwatch` ile içeren sürümdür; commit'teki `Timer` sürümü yalnız birim testle doğrulandı.

Güçlü olan: marka turkuazı sistemden Flutter'a tutarlı (#147D8A), reduced-motion desteği, tek `AnimationController`,
sahne içeriği bloke etmiyor, testler var. Bunlar korunur.

---

## 2. Tasarım ilkeleri

1. **Sistem açılışı ile Flutter'ın ilk karesi aynı kare olmalı.** Android belgesi splash'in ilk Flutter karesiyle
   kapanmasını, Flutter belgesi ilk karenin native splash'i aynı konumda yeniden kurmasını ve Android 12+'ta sistem solmasının
   kapatılmasını öneriyor ([Android](https://developer.android.com/about/versions/12/features/splash-screen),
   [Flutter](https://docs.flutter.dev/platform-integration/android/splash-screen)).
2. **Marka anı kısa, tekrar eden açılış daha da kısa.** İlk açılış ≈ 2 s, sonraki açılışlar ≤ 900 ms. Kullanıcı
   dokununca atlar. Sahne içeriği asla geciktirmez.
3. **Hupo bir *dekor* değil, *oyuncu*.** Hareketin hikâyesi var: uyur → uyanır → selam verir → imza çizer. Hareket
   geri bildirimdir (Hupo'nun "var olduğunu" gösterir), gösteriş değil.
4. **Tek karakter, tek poz ailesi.** Native ve Flutter'da aynı master Hupo. Onaylı master yeniden yorumlanmaz
   (BRAND_AND_VISUAL_RULES: kaş/gaga/ayak dahil).
5. **Çocuk ve veli dostu.** İlk açılışta ödeme, koleksiyon, uzun form yok. Sesli açılış ilk seferle sınırlı (sınıfta,
   yatakta, toplantıda açan çocuklar). Reduced-motion'da hareket yok.
6. **Altın sarı değerli kalır.** Altın yay yalnız Hupo imzasında (kimlik rengi); butonlar sarıya boyanmaz.

---

## 3. Senaryo: "Hupo Uyanır"

Mevcut "Kanat İmzası" fikri korunur ve oyunculaştırılır: altın kanat izi artık dekor değil, kelime işaretinin
altını çizen **imza** olur.

### 3.1 İlk açılış (≈ 2,2 s, atlanabilir)

| Zaman | Ne görünür | Teknik | Ses / dokunuş |
|-------|-----------|--------|---------------|
| 0 – native | Turkuaz zeminde **gözleri kapalı, uyuyan Hupo** (sistem splash'i). | Android 12+ `windowSplashScreenAnimatedIcon`, iOS `LaunchScreen`; aynı varlık | — |
| 0,00 | Flutter ilk karesi native ile **birebir aynı** (konum, boyut, zemin). Geçişte kesilme yok. | `SplashFrame0` + sistem solmasını kapatma | — |
| 0,00 – 0,35 | Hupo'nun arkasında şafak gibi açılan yumuşak ışık; toz parçacıkları yukarı süzülür. | radyal gradyan + hafif parçacık | — |
| 0,35 – 0,80 | **Uyanış:** iki hızlı göz kırpma, baş hafif yana eğilir, püskül yaylanır, küçük bir sıçrama (hazırlık → hareket → oturma). | katmanlı Hupo (göz, baş, püskül) | sıçrama inişinde hafif dokunuş; marka sesi başlar |
| 0,80 – 1,30 | **Selam:** kanat kalkar, ucundan altın yay çıkıp ekranı sarar ve kelime işaretinin altına oturur. | kanat katmanı + mevcut `WingSignaturePainter` mantığı | — |
| 1,30 – 1,80 | **Kelime işareti** harf harf yükselir; üstünden tek bir ışık süpürmesi geçer. | `ShaderMask` gradyanı (özel shader gerekmez) | — |
| 1,80 – 2,20 | Hupo nefes alır; küçük bir konuşma balonu: **"Merhaba, ben Hupo!"** | idle döngü | — |
| 2,20 → | Balon, ilk karşılama kartına (§3.3) dönüşür. Hupo yerinde kalır, zemin sürer: **sahne değişmez, içerik gelir.** | `Hero` / ortak eleman | — |

### 3.2 Sonraki açılışlar (dönen kullanıcı, ≈ 0,8 – 0,9 s)

Native'de uyuyan Hupo → Flutter ilk karesi aynı → göz açılır, kısa kanat selamı (0,3 s) → Hupo, Giriş başlığındaki veya
Ana sayfadaki yerine **uçarak yerleşir** (0,25 s) ve içerik kademeli belirir (`HomeEntranceStagger` mevcut).
Kelime işareti ve ses yok. İçerik hazırsa sahne beklemez; hazır değilse Hupo nefes alarak bekler (en fazla 3 s, sonra iskelet).

### 3.3 İlk karşılama ("Hupo ile Tanış"): hesap açılmadan önce 1, sonra en fazla 1 adım

| Adım | Ne zaman | İçerik | Ana eylem |
|------|----------|--------|-----------|
| A. Merhaba | Cihazda ilk açılış, giriş yokken | "Merhaba, ben Hupo! Kısa görevlerle, adım adım birlikte öğreneceğiz." | **Başlayalım** → Giriş/Kayıt |
| B. Sınıfını seç | Giriş sonrası, profilde sınıf yoksa | Mevcut `GradePickerScreen` içeriği, Hupo yanında; sınıf değiştirme kuralı (30 gün) metne eklenir | **Devam** → Ana sayfa |

Ana sayfa ilk oturumunda yeni ekran yok: Hupo (karşılama pozu) + günlük görev + **Başla** öne çıkar (tasarım sistemi kuralı).
Atlama her adımda görünür. Metinler öneridir; `hupo-ux-writing` ile son hâli verilir.

### 3.4 Durum tablosu

| Durum | Davranış |
|-------|----------|
| İlk açılış | §3.1 + §3.3-A |
| Sonraki soğuk açılış | §3.2 |
| Arka plandan dönüş | Sahne yok (Flutter ağacı zaten yaşıyor; bugün de böyle) |
| Reduced-motion | Statik kare 300 ms, ardından çapraz geçiş; hareket yok, ses yok |
| Düşük başarım | Parçacık ve altın yay çizilmez; Hupo sıçraması ve göz kırpma kalır |
| Dokunma | 600 ms sonra herhangi bir yere dokunmak sahneyi atlar |
| Bağlantı yok | Sahne aynı; içerik katmanı kendi hata durumunu gösterir (mevcut) |
| Erişilebilirlik | "Hupolingo açılıyor" okunur; sahne dokunma ve odağı tutmaz |

---

## 4. Teknoloji seçimi

| Seçenek | Güçlü | Zayıf | Karar |
|---------|-------|-------|-------|
| **A. Rive** (`rive` 0.14.x, Rive Native çalışma zamanı) | Kemik/ağ + durum makinesi; aynı Hupo rig'i ana sayfa selamı, soru tepkileri, sonuç kutlamasında yeniden kullanılır. Küçük `.riv` dosyası. | Rive Editor'de animatör gerekir; **web'de WASM çalışma zamanı eklenir (boyut ölçülmedi)**; Rive Editor plan koşulları doğrulanmalı. | **Öneri, kapıyla (Faz 3)** |
| B. dotLottie (durum makineli) | After Effects hattı; mevcut `lottie` bağımlılığına yakın. | Durum makinesi desteği yeni (Aralık 2025) ve belgesinde "geliştirilmekte, API değişebilir" deniyor; karakter rig'i için zayıf. | Elendi |
| C. Saf Flutter katmanlı sprite | Sıfır yeni bağımlılık; web uyumlu; mevcut `AnimationController` mimarisi. | Kemik/ağ deformasyonu yok; her poz için ayrı katman. | **Yedek** (aynı katmanlı asset kullanılır, yatırım boşa gitmez) |

Gerekçe: açılış tek başına Rive gerektirmez, **Hupo'nun canlı bir karakter olması** gerekir. Rive'ın asıl getirisi açılışın
ötesinde. Bu yüzden Faz 3'te iki günlük bir karşılaştırma yapılır; Rive yalnızca şu üç koşul sağlanırsa seçilir:
(a) web paketi artışı kabul edilebilir ya da web'de yedek sprite kullanılır, (b) düşük uç Android'de akıcı,
(c) animatör mevcut. Aksi hâlde C ile ilerlenir.

Notlar:
- **Impeller** iOS'ta tek motor, Android'de (API 29+) varsayılan; kaynaklar Android'de Skia'nın tamamen kalktığı sürüm konusunda
  çelişiyor, bu yüzden çizim maliyeti cihazda profile modda ölçülür, varsayılmaz. Güncel Flutter: 3.47.5.
- **Özel fragment shader** gerekmez. Işık süpürmesi `ShaderMask` ile yapılır. Shader yalnız Faz 4 sonunda, ölçüm iyi çıkarsa isteğe bağlı.
- Mevcut `MaskFilter.blur` katmanları (3 yerde) düşük uçta ölçülmeden korunmaz.

---

## 5. Üretim planı

Boyut yaklaşımı: **K** küçük (yarım–1 gün), **O** orta (2–4 gün), **B** büyük (1 hafta+). Takvim sözü verilmez.

### Faz 0: Karar ve hazırlık (Kullanıcı) · K
Aşağıdaki §7 kararlar. Çalışma dalı: `master`'dan `feature/acilis-senaryosu`. Çalışma ağacında başka oturumların
değişiklikleri var (`mobile-app/` altında da birden çok dosya, 28 Ekim başı git durumu); commit'ler yalnızca kendi dosyalarına pathspec ile yapılır.

### Faz 1: Yeni asset gerektirmeyen düzeltmeler (Ajan) · O
0. **Acil hata düzeltmeleri (bulgu 9–12, yeni asset gerektirmez):** sahneyi `Material(type: transparency)` ile sarıp yazının geri dönüş stilini gider; gezinme çubuğu/durum çubuğu rengini sahneyle eşitle; solma sırasında altta kalan içeriği gizle (çift pozlama).
1. **Baseline: ALINDI** (§1.1). Faz 1 sonunda aynı yöntemle (`adb shell screenrecord` + kare kare) yeniden ölçülür; karşılaştırma bu belgeye eklenir. `flutter run --profile --trace-startup` ile ilk kare süresi hâlâ ölçülmedi.
2. **Tek Hupo:** `hero_splash`'tan Android 12+ splash ikonu (güvenli alan: arka plansız ikon için 288 dp tuvalde 192 dp daire — Android belgesine göre, uygularken doğrula) ve iOS `LaunchImage` üretilir. Üçü aynı poz.
3. **Birebir ilk kare:** `SplashFrame0` (aynı konum/boyut); Android 12+ sistem çıkış animasyonu kapatılır.
4. **Önyükleme:** `runApp` init'ten önce; `Supabase.initialize` ve `SharedPreferences` arka planda. Kazanç ölçülür; anlamlı değilse geri alınır.
5. **Açılış türü sadeleştirme:** ölü kollar (`warmStart`, `resume`, `directRedirect`) kaldırılır; gerçek durumlar: ilk açılış / sonraki açılış / reduced-motion. Deep link eklenince yeniden bağlanır.
6. **Süre kademesi:** sonraki açılışlar ≤ 900 ms; ses yalnız ilk açılışta; dokununca atla; `precacheImage`.
7. **Ortak eleman geçişi:** Hupo, Giriş başlığına/Ana sayfaya `Hero` ile yerleşir.
Çıktı: `main.dart`, `splash_screen.dart`, `app_open_service.dart`, `hupo_signature_entrance.dart`, `android/.../res/values-v31`, `ios/Runner/...`, güncel testler.
**Bu faz tek başına, yeni üretim beklemeden en büyük "profesyonellik" sıçramasını verir** (bulgu 1, 5, 6, 8).

### Faz 2: Marka ve varlık üretimi (Kullanıcı + illüstratör) · B
1. **Logo kilidi:** Hupo + "Hupolingo" kelime işareti (şimdilik düz metin).
2. **Katmanlı Hupo:** master'dan **kesilerek/vektörleştirilerek** (yeniden çizilmeden): gövde, baş, göz açık/kapalı, sol–sağ kanat, püskül, kuyruk, ayaklar; şeffaf. Ek poz: uyuyan Hupo (gözler kapalı).
3. **Ses:** mevcut `hupo_marka_sesi.mp3` (25 KB) dinlenir; gerekirse ≤ 1,2 s'ye kısaltılır.
4. **Android 12+ ikon:** vektör/PNG, güvenli alana uygun.
Kabul: onaylı master ile görsel fark yok (Kullanıcı onayı); dosya yolları `assets/hupo/splash/` (BAKIM.md §5'te zaten öngörülmüş).

### Faz 3: Animasyon prototipi ve teknoloji kapısı (Ajan + animatör) · O
Aynı katmanlarla iki prototip: C (sprite) ve A (Rive). Ölçüm: web paketi farkı (`flutter build web` öncesi/sonrası), Galaxy S23 FE **ve** bir düşük uç Android'de profile mod kare süresi, `.riv` boyutu. Çıktı: seçim kaydı (Karar).

### Faz 4: "Hupo Uyanır" uygulaması (Ajan) · B
§3.1 ve §3.2 zaman çizelgesi; reduced-motion ve düşük başarım kolları; ses ve dokunuş; Android 12+ AVD (≤ 1 s; Android 13+ süreyi AVD'den alır) ve iOS launch storyboard; `HupoSignatureEntrance` testleri güncellenir. `BAKIM.md` yenilenir.

### Faz 5: İlk karşılama (Ajan) · O
§3.3-A kartı (cihaz bayrağı) ve §3.3-B sınıf adımı (profilde sınıf yoksa; sunucu durumu esas, yeni bayrak yok). Ekran sözleşmeleri §6.

### Faz 6: Cihaz QA ve kayıt (Ajan + Kullanıcı) · K
Matris: Android 16 (Galaxy S23 FE, mevcut), düşük uç Android (**temin edilmeli**), iOS (**bu Windows makinesinde derlenemez; Mac/CI gerekir**), Android 12 ve 13 (ikon davranışı farklı), koyu mod, %130 yazı boyutu, reduced-motion. Her satır için kayıt; kayıtsız satır `DOĞRULANDI` olmaz (AGENTS §9.5-3).

---

## 6. Ekran sözleşmeleri (özet)

**Açılış sahnesi** · Yüzey: öğrenci · Görev: uygulamanın açıldığını ve Hupo'nun hazır olduğunu hissetmek · Ana eylem: yok (dokununca atla) ·
Hupo: tam boy, merkez, uyuyan → uyanık · Tokenlar: `AppColors.primary/primaryDark/primaryLight`, `AppColors.sun` (yalnız imza) ·
Loading: Hupo nefesi, en fazla 3 s sonra iskelet · Hata/bağlantı yok: sahne aynı, hata içerik katmanında ·
Beyaz yazı / #147D8A kontrastı elle hesaplandı ≈ 4,85:1 (ekranda ölçülmedi).

**İlk karşılama kartı** · Yüzey: öğrenci (8–14) · Görev: Hupo'yu tanımak ve girişe geçmek · Ana eylem: **Başlayalım** ·
İkincil: Atla · Hupo: orta boy, sahnedeki yerinde · Metin 2. tekil, vaat/garanti yok · Uzun metin ve büyük yazıda kaydırılabilir ·
Çift dokunma: tek geçiş.

---

## 7. Karar gereken noktalar

| # | Karar | Öneri |
|---|-------|-------|
| D1 | Teknoloji: Rive mi, katmanlı sprite mı? | Faz 3 kapısıyla; Rive önerilir |
| D2 | Katmanlı Hupo kim üretir? | Master'dan illüstratör kesimi; yapay zekâ ile yeniden çizim **yok** (marka kuralı) |
| D3 | Logo kilidi: şimdi mi, sonra mı? | **Faz 2'de, Faz 4'ten önce** (kullanıcı kararı ajana bıraktı; `ONAY BEKLİYOR`). Faz 1'de düz metin. Yapay zekâ yalnız fikir taslağı; nihai logoyu tasarımcı vektörel çizer. |
| D4 | Marka sesi | **KARAR (kullanıcı, 28 Ekim): yalnız ilk açılışta** |
| D5 | Dönen kullanıcı açılış süresi | ≤ 900 ms (şu an ≈ 3 s) |
| D6 | İlk karşılama kapsamı | A + B yeterli |
| D7 | iOS doğrulaması | Kullanıcının Mac'i yok. Öneri: GitHub Actions macOS çalıştırıcısı (iOS simülatöründe derle + ekran görüntüsü). Depo GitHub'da (`hupo-classic`). Kurulum için onay ve plan/ücret kontrolü gerekir; yoksa iOS maddeleri `DOĞRULANMADI` kalır. |

Mevcut araçlar: Remotion çalışma alanı `C:\Dev\video-studio` (başka bir ajan kuruyor; Faz 3'te hareket önizleme videosu için), Fal.ai ve Gemini anahtarları ortamda var (logo/katman *taslakları*; onaylı master'a sadakat şartıyla), `stitch` MCP yapılandırılmış, `nano-banana-2` bu oturumda bağlanamadı.

## 8. Kabul kriterleri (hedef; ölçülene kadar hipotez)

1. Native → Flutter geçişinde Hupo'nun konum/boyut sıçraması gözle görünmez; kayıt kare kare incelenir.
2. Sonraki soğuk açılışta sahne ≤ 900 ms; ilk açılışta ≤ 2,2 s; dokununca atlanır. (Baseline: simge → Giriş ≈ 2,9–3,0 s, her açılışta.) "Hupolingo" yazısı Nunito ile, alt çizgisiz çizilir.
3. Profile modda sahne boyunca bütçe aşan kare yok: S23 FE'de 0, düşük uçta ölçülür ve eşik kayda yazılır.
4. Reduced-motion açıkken hareket ve ses yok; TalkBack "Hupolingo açılıyor" okur.
5. Mobil paket artışı ≤ 400 KB; web paketi artışı ölçülmüş ve onaylı.

**Ölçüm olayı önerisi (BYM, kişisel veri yok):** `acilis_tamamlandi {tur: ilk|sonraki, sure_ms, atlandi}`.

## 9. Kapsam dışı

- "Önce dene" / misafir modu (anonim giriş): çocuk verisi, KVKK ve arka uç kararı gerekir; HUK onayı olmadan yok.
- Açılışta bildirim izni, ödeme, sosyal kanıt, puan/sınav vaadi.
- Ana sayfa, soru ve sonuç ekranlarının Rive ile yenilenmesi (rig hazır olunca ayrı plan).
- Web uygulamasının (app.hupolingo.com) açılışı: yedek (statik Hupo) kalır.

## 10. Kaynaklar

- [Android: Splash screens](https://developer.android.com/about/versions/12/features/splash-screen) (animasyonlu ikon API 31+, öneri ≤ 1 s)
- [Flutter: Android splash](https://docs.flutter.dev/platform-integration/android/splash-screen) (ilk kare eşleşmesi, solmayı kapatma)
- [Rive Flutter (Context7 belgeleri)](https://github.com/rive-app/rive-flutter) ve [rive_native](https://pub.dev/documentation/rive_native/latest/) (web: WASM)
- [dotLottie durum makineleri](https://docs.lottiefiles.com/en/format/dotlottie/interactivity/state-machines) (geliştirilmekte)
- [Flutter fragment shader](https://docs.flutter.dev/development/ui/advanced/shaders)
- Yerel: `docs/hupo-design-growth/BRAND_AND_VISUAL_RULES.md`, `SCREEN_CONTRACT.md`, `docs/splash/BAKIM.md`
