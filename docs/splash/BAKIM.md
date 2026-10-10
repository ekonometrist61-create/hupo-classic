# HUPO SIGNATURE ENTRANCE — Kanat İmzası

> Uygulama açılış deneyiminin bakım dokümantasyonu.
> Son güncelleme: 10 Ekim 2026

---

## 1. Ne değişti?

Eski açılış, 1500 ms sabit duran statik bir görselden (`hero_splash.webp`) ibaretti.
Yeni açılış, Hupo'yu tanıtan ve ana sayfaya kesintisiz bağlanan dört sahneli bir
marka deneyimidir.

| Katman                       | Eski                       | Yeni                       |
| ---------------------------- | -------------------------- | -------------------------- |
| Android sistem splash zemini | `#25AAF1` (mavi)           | `#147D8A` (marka turkuazı) |
| iOS launch zemin             | `#6C4DF6` (menekşe)        | `#147D8A`                  |
| Android `NormalTheme` zemini | `?android:colorBackground` | `#147D8A` (flaş önleme)    |
| iOS `Main.storyboard` zemini | beyaz                      | `#147D8A` (flaş önleme)    |
| Uygulama içi açılış          | statik görsel + fade       | 4 sahneli animasyon        |

---

## 2. Sahne zaman çizelgesi

Tek bir `AnimationController` (1600 ms) tüm sahneleri yönetir.

| Sahne                    | Aralık       | Ne olur?                                                               | Kod                               |
| ------------------------ | ------------ | ---------------------------------------------------------------------- | --------------------------------- |
| **1 — FIRST SPARK**      | 0–300 ms     | Marka turkuazı zemin yumuşakça belirir; Hupo henüz yok                 | `HupoSignatureEntrance`, `zeminT` |
| **2 — HUPO AWAKENS**     | 300–750 ms   | Hupo alttan yükselir, hafif büyür, "kanat açılışı" supurması           | `_HupoGovdesi`, `uyanmaT`         |
| **3 — WING SIGNATURE**   | 750–1150 ms  | Kanattan altın ışık izi + 3 kıvılcım çizilir                           | `WingSignaturePainter`            |
| **4 — READY TO EXPLORE** | 1150–1600 ms | Hupo nihai konuma yerleşir, "Hupolingo" belirir, sahne içeriğe bırakır | `yerlesmeT`                       |

Sahne sonu: 350 ms fade-out → `widget.child` (giriş ya da ana kabuk) ortaya çıkar.

---

## 3. Dosya haritası

| Dosya                                             | Sorumluluk                                                                                  |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| `lib/services/app_open_service.dart`              | Açılış türü (`AppOpenKind`) ve plan (`AppOpenPlan`) kararı. **Saf, animasyondan bağımsız.** |
| `lib/widgets/splash/hupo_signature_entrance.dart` | 4 sahneli marka sahnesi + karakter gövdesi                                                  |
| `lib/widgets/splash/wing_signature_painter.dart`  | Işık izi ve kıvılcım çizimi (`CustomPainter`)                                               |
| `lib/widgets/splash/home_entrance_stagger.dart`   | Ana sayfa kademeli belirme (Sahne 4 koordinasyonu)                                          |
| `lib/screens/splash_screen.dart`                  | `SplashGate`: plan uygular, yaşam döngüsünü dinler, sahneyi kapatır                         |
| `test/splash_entrance_test.dart`                  | 13 test (karar + sahne + gate)                                                              |

---

## 4. Açılış durumları ve davranışları

`resolveAppOpenKind` + `planAppOpen` ikilisi kararı verir:

| Durum                     | Tam sahne?      | Mikro karşılama? | Süre    |
| ------------------------- | --------------- | ---------------- | ------- |
| FIRST_LAUNCH (bayrak yok) | ✅              | —                | 1600 ms |
| COLD_START (bayrak var)   | ✅              | —                | 1600 ms |
| WARM_START                | —               | ✅               | 600 ms  |
| APP_RESUME                | —               | —                | atlanır |
| DEEP_LINK / AUTH_REDIRECT | —               | —                | atlanır |
| REDUCED_MOTION            | —               | ✅ (statik kare) | 500 ms  |
| ERROR_RECOVERY            | (cold ile aynı) | (cold ile aynı)  | —       |
| LOW_PERFORMANCE           | ✅ (izsiz)      | —                | 1600 ms |

**Kalıcılık:** `hupo_first_greeting_done` bayrağı (`SharedPreferences`).
Bu bir **kullanıcı tercihi değil**, cihaz/oturum yaşam döngüsü durumudur;
oturum kapatılıp açılsa da tam sahne tekrar oynamaz.

**Arka plandan dönüş:** `didChangeAppLifecycleState` yakalar; sahne oynarken
dönülürse hemen bitirilir, sahne bittikten sonra dönülürse hiç oynamaz.

---

## 5. Karakter katman gereksinimi — DÜRÜST DURUM

**Mevcut karakter asseti TEK KATMANLIDIR** (`hero_splash.webp`): gövde, göz,
kanat ayrı dosyalar değildir. Bu nedenle:

- ✅ **Yapılabilen:** Gövde yükselmesi, hafif büyüme, supurma (kanat açılışı
  _taklidi_), ışık izi (kanattan çıkıyormuş gibi), kıvılcımlar.
- ❌ **YAPILAMAYAN:** Gerçek göz kırpma, gerçek bağımsız kanat hareketi, gerçek
  baş hareketi.

Katmanlar **varmış gibi gösterilmedi**; bu bir bilinçli geçici çözümdür.

### Katmanlı asset geldiğinde ne yapılır?

`hero_splash.webp` yerine şu dosyalar üretilirse sahne gerçek katmanlı animasyona
yükseltilebilir:

```
assets/hupo/splash/hupo_govde.webp       (gövde, şeffaf)
assets/hupo/splash/hupo_goz_acik.webp    (göz açık katmanı)
assets/hupo/splash/hupo_goz_kapali.webp  (göz kırpma katmanı)
assets/hupo/splash/hupo_kanat.webp       (kanat, ayrı katman)
```

Ardından `_HupoGovdesi` içine, `uyanmaT` ilerlemesine bağlı göz-kırpma kare
geçişi ve kanat `Transform.rotate` eklenir. `HupoSignatureEntrance.assetPath`
parametresi tek katman için hazırdır; çok katman için yeni bir `_HupoKatmanlari`
widget'ı yazılmalıdır.

---

## 6. Ayarlar ve test kancaları

`HupoSignatureEntrance` şu parametreleri alır:

- `onFinished`: sahne bitince çağrılır (bir kez).
- `assetPath`: karakter görseli (testte değiştirilebilir).
- `reducedMotion`: `true` ise statik marka karesi.
- `lowPerformance`: `true` ise ışık izi/kıvılcım çizilmez.

Bunlar gelecekte cihaz sınıfına göre (`MediaQuery` + `platformDispatcher`)
otomatik beslenebilir.

---

## 7. Performans notları

- **Tek controller:** Tüm sahneler tek `AnimationController`; fazladan
  `Ticker` yok.
- **Repaint sınırı:** `AnimatedBuilder` yalnızca sahne ağacını yeniden kurar;
  `CustomPaint` ışık izi sahnesi dışında `shouldRepaint` false döner.
- **Asset ön yükleme:** `hero_splash.webp` `precacheImage` edilmelidir (henüz
  eklenmedi; bkz. §8 Açık işler).
- **Ses:** Marka sesi YALNIZCA tam sahnede çalınır; mikro/atlanan açılışlarda
  uygulama açılışında ses yoktur.
- **Işık izi:** En fazla 3 kıvılcım, iç içe 2 daire; opaklık 0.8'i geçmez, tam
  ekran beyaz parlama yoktur.

---

## 8. Açık işler / iyileştirme noktaları

1. **Katmanlı karakter asseti yok** (§5). En büyük görsel kalite sınırı budur.
2. **Deep link entegrasyonu:** `resolveAppOpenKind`'ın `isDeepLink` parametresi
   altyapı olarak hazır ama `main.dart`'ta henüz beslenmiyor (derin bağlantı
   yönlendirmesi bu depoda kurulu değil).
3. **LOW_PERFORMANCE tespiti:** `lowPerformance` parametresi hazır ama cihaz
   sınıfına göre otomatik beslenmiyor.
4. **Asset ön yükleme:** Splash asseti için `precacheImage` eklenebilir; şu an
   ilk kare bir tık geç gelebilir (tipik olarak fark edilmez).
5. **Cihaz testi yapılmadı:** Yalnızca widget testleri çalıştırıldı (13/13).
   Fiziksel cihaz/emülatör ölçümü (gerçek FPS, jank) yapılmadı.

---

## 9. Doğrulama komutları

```bash
cd mobile-app
flutter analyze                 # 0 hata olmalı
flutter test test/splash_entrance_test.dart
flutter test                    # tüm testler
```
