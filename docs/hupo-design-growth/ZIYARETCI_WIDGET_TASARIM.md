# Ziyaretçi widget'ı (1 soru): tasarım belgesi

Tarih: 2026-10-16
Durum: **Tasarım taslağı.** Kod yazılmadı, veritabanına ve uzak sisteme dokunulmadı. Proje sahibi onayı ve hukuk görüşü bekliyor.
Yüzey: hupolingo.com landing sayfası, yalnız `/`.
Kaynaklar: `ANKET_SISTEMI_MIMARI.md` §1, §5, §12-B; `PROJE_GUNLUGU.md` §24 (satır 963); `ONBOARDING_ANKETI_ON_ARASTIRMA.md` (bu widget'a soru aktarılmaz).

## 0. Özet

- Widget tek soru sorar: **"Hupolingo sizin için en çok neye yardımcı olsun?"** Tek seçim, 6 seçenek.
- Kimlik, e-posta, telefon, çocuk adı, yaş/sınıf, okul ve pazarlama onayı yok. Kayıt yalnız seçenek kodu, gün ve sayfa türüdür; satır değil, günlük toplu sayım olarak tutulur.
- Yer: landing'de `ParentPanelSection` ile `DenemeExamSection` arasında satır içi kart. Popup, overlay ve sabit (fixed) kart yok.
- Frekans: sekme oturumunda en fazla 1 gösterim (sessionStorage bayrağı). ANKET §1'deki 24 saat ve 3/14/90 kuralı ziyaretçide uygulanamaz (çelişki Ç1, §8).
- Hukuk kararı gereken noktalar: bayrak saklama, toplu sayımın çerez metniyle ilişkisi, IP tabanlı hız sınırı (§7).
- Ön koşul: landing'deki `AnketIstemi yuzey="web_sitesi"` (`page.tsx` satır 67) kaldırılmadan widget yayınlanmaz; iki kart üst üste çıkar.

## 1. Amaç ve ana eylem

| Konu | Karar |
|---|---|
| Toplanan tek bilgi | Ziyaretçinin seçtiği ilgi/ihtiyaç kodu (6 seçenekten biri) |
| Neden | Landing'de hangi konuya (demo, SSS, veli paneli) öncelik verileceğini ürün ilgisine göre seçmek |
| Pazarlama izni | **Hayır.** Widget hiçbir iletişim izni istemez, hiçbir iletişim kanalı açmaz |
| Ana eylem | Bir seçenek seçip **Gönder** |
| İkincil eylem | **Şimdi değil** ve **X** (aynı davranış, §4) |
| Başarı tanımı | Yanıt, sunucu 200 döndükten sonra kayda geçmiş sayılır. Tıklama tek başına başarı sayılmaz |
| Karar kuralı | Toplam yanıt 100'ün altındayken yön okunmaz; içerik kararı yalnız bu veriye dayanmaz (öneri, §9-6) |

Durumlar:

| Durum | Ekranda | Kullanıcı eylemi |
|---|---|---|
| Gizli | Kart yok | — |
| Görünür | Soru, 6 seçenek, Gönder pasif | Seçim yapar |
| Seçili | Gönder aktif | Gönder |
| Gönderiliyor | Gönder pasif, "Gönderiliyor..." (`aria-busy`) | Bekler |
| Teşekkür | "Teşekkürler. Yanıtınız Hupolingo'yu geliştirmemize yardımcı olur." (`role="status"`) | Kapat |
| Hata | "Yanıtınız gönderilemedi. Seçiminiz duruyor." | Yeniden dene |
| Kapatıldı | Kart kapanır; bu sekmede bir daha gösterilmez | — |

## 2. Hedef kitle ve bağlam

- **Varsayım (doğrulanmadı):** ziyaretçinin çoğu veli adayı. Dayanak: landing veli odaklı (`WhyParentsSection`, `ParentPanelSection`; `PROJECT_CONTEXT.md` "satış veli alanında"). Gerçek ziyaretçi dağılımı ölçülmedi; PostHog yalnız onayla çalışıyor (`AnalyticsProvider.tsx`).
- **Çocuklar da gelebilir.** Soru çocuğa yönelik değil; metin "siz" hitabıyla yazılır. Çocuk ekranında widget yok.
- **Sayfa:** yalnız `/` (landing). Kapsam dışı: `/demo` (deneme akışı, dikkat dağıtmamalı), `/deneme-sinavi-kayit`, `/gizlilik`, `/kosullar`, `/ticari-ileti-izni`, `/bakim`, `/yonetim-giris`.
- **Fiyat ayrı sayfa değil.** Fiyat bölümü `#pricing` (`PricingSection.tsx`) ve landing'de fiyat yok; planlar "hazırlık aşamasında" (`decisions.md`, 2026-10-06). Widget fiyat sorusu sormaz.
- **Yer:** `ParentPanelSection` (`page.tsx` satır 58) ile `DenemeExamSection` (satır 59) arası. Gerekçe: ziyaretçi ürünü ve veli panelini gördükten sonra soruluyor; kayıt formu `ErkenErisimSection` bu kartın yanında değil.
- **Görünme tetikleyicisi:** bölümün en az %40'ı görünür ve 2 saniye görünür kalır. Sayfa açılışında, zaman sayacıyla veya çıkış niyetiyle gösterim yok.
- **Dil:** TR öncelikli. EN için aynı anahtar yapısı; çeviri onayı ayrı.
- **Cihaz:** mobil öncelikli (320 px), masaüstü 1280 px.

## 3. Soru ve seçenekler

**Soru:** Hupolingo sizin için en çok neye yardımcı olsun?
**Yardımcı metin:** "Bir seçenek işaretleyin." Açıklama alanı yok.

| Kod | Seçenek (TR) |
|---|---|
| `duzenli_calisma` | Düzenli, kısa aralıklarla çalışmaya destek olsun |
| `eksik_konular` | Eksik kaldığı konuları görüp tekrar etmeyi kolaylaştırsın |
| `ortaokula_gecis` | Ortaokula geçiş hazırlığına yardımcı olsun |
| `kendi_basina` | Kendi başına çalışabileceği sade bir alan olsun |
| `eglenceli` | Eğlenceli bir şekilde öğrenmesini desteklesin |
| `emin_degil` | Emin değilim / başka bir şey |

Notlar:
- 5 seçenek + "emin değilim" = 6. Sınır: 4–6 seçenek ve bir "emin değilim" seçeneği.
- "Ortaokula geçiş" seçeneği bilinçli genel tutuldu. 4→5 geçişi ilk odak (`PROJECT_CONTEXT.md`), ama repoda 4. sınıf soru bankası var (`soru-bankasi/sinif-4/`) ve 5. sınıf kapsamı bu belgede doğrulanmadı. Kapsam doğrulanırsa seçenek "4. sınıftan 5. sınıfa geçiş hazırlığı" olarak daraltılabilir (§9-5).
- Sınıf, yaş veya okul sorulmaz: çocuğa ait ve küçük gruplarda tanımlayıcı olabilir. v2 kararı.
- Serbest metin yok. Ad, e-posta, telefon, okul, IP istenmez.
- Yanıt altında tek satır güven notu: "Yanıtınız kimliğinizle eşleşmez; ad, e-posta veya telefon istemiyoruz." Bu cümle yalnız §6 uygulaması gerçekten böyle çalıştığında yayınlanır (kabul kriteri 7).
- Kaçınılacak ifadeler: `decisions.md` satır 28'deki kanıtsız iddialar ("14 Gün İade Garantisi", "Gizli Ücret Yok" vb.) bu widget'a taşınmaz.

**Hupo:** `web-panel/public/hupo/dusunuyor.webp` (mevcut web varlığı), yaklaşık 64 px, `alt=""` (dekoratif; soru zaten anlamı taşır). Kostüm, dini sembol yok. Pozun tasarım sahibi onayı §9-9.

## 4. Davranış

**Görünme:** §2 tetikleyicisi, sekme başına bir kez. Bayrak `yanitlandi` veya `kapatildi` ise hiç gösterilmez.

**Kapatma ("X" ve "Şimdi değil"):**
- İkisi de kartı kapatır, bayrağı `kapatildi` yapar, sunucuya `ziyaretci_widget_kapatildi` olayı yazar (toplu sayım).
- İkisi aynı davranır ve aynı görsel ağırlıktadır. "Şimdi değil" ikincil ama gizlenmez; karanlık desen yok (landing'deki çerez bandında olduğu gibi eşit ağırlık).
- Kart modal değildir; Esc bir şey yapmaz.

**Gönderim:**
- Gönder yalnız seçim sonrası aktif olur; gönderim sırasında pasif (çift tıklama koruması).
- İstek gövdesi yalnız: `widget_kodu` (`ilgi_v1`), `sayfa_turu` (`landing`), `olay` (`secildi`), `secenek_kodu`.
- "Kaydedildi" ifadesi yalnız sunucu 200 döndüğünde gösterilir.
- Hata: hata metni, seçim korunur, "Yeniden dene". Sayfa yenilenirse yanıt kaybolur; bu kabul edilir çünkü yanıt kişisel veri değildir.

**Yanıt sonrası:** "Teşekkürler. Yanıtınız Hupolingo'yu geliştirmemize yardımcı olur." Kişiselleştirme, indirim, deneme veya "size özel içerik" vaadi yok. Kart kendiliğinden kapanmaz; "Kapat" ile kapanır.

**Tekrar gösterim (bayrak tabanlı, kişisel veri yok):**
- Anahtar: `sessionStorage["hupo.ziyaretci.ilgi.v1"]` = `{"d":"gosterildi"|"yanitlandi"|"kapatildi"}`.
- Kimlik, zaman damgası, IP yok. Sekme kapanınca silinir.
- `sessionStorage` okunamazsa veya yazılamazsa (özel mod, engelli depolama) widget gösterilmez. Her okuma/yazma try/catch içinde.

**Ön koşul:** `page.tsx` satır 67'deki `AnketIstemi yuzey="web_sitesi"` kaldırılır (ANKET D2). İki kart aynı anda görünmez.

## 5. Yerleşim

Mobil (320–390 px), akış içinde:

```
+--------------------------------------+
|  [Hupo 64px]                         |
|  KISA BİR SORU                       |  <- küçük etiket
|  Hupolingo sizin için en çok neye    |  <- legend
|  yardımcı olsun?                     |
|  Bir seçenek işaretleyin.            |
|  ( ) Düzenli, kısa çalışma           |  <- her satır >= 44px
|  ( ) Eksik konuları görüp tekrar     |
|  ( ) Ortaokula geçiş hazırlığı       |
|  ( ) Kendi başına sade bir alan      |
|  ( ) Eğlenceli bir şekilde öğrenme   |
|  ( ) Emin değilim / başka           |
|  [          Gönder          ]        |  <- tam genişlik, >= 44px
|  [       Şimdi değil        ] [ X ]  |
+--------------------------------------+
```

Masaüstü (1280 px), `max-w-2xl` kart, ortalı:

```
+----------------------------------------------------------------+
| (Hupo)  KISA BİR SORU                                     [X]  |
|         Hupolingo sizin için en çok neye yardımcı olsun?       |
|  ( ) Düzenli, kısa çalışma      ( ) Eksik konuları tekrar      |
|  ( ) Ortaokula geçiş hazırlığı  ( ) Kendi başına sade alan     |
|  ( ) Eğlenceli bir şekilde öğrenme ( ) Emin değilim / başka    |
|                         [ Şimdi değil ]  [ Gönder ]            |
+----------------------------------------------------------------+
```

Sayfa sırası (landing):

```
Header
DuyuruSeridi            <- akışta, çakışmaz (DuyuruSeridi.tsx, fixed değil)
Hero, TrustBadges, Benefits, Demo, AppScreens, Characters, HowItWorks, WhyParents, ParentPanel
>>> ZİYARETÇİ WİDGET (bu bölüm) <<<
DenemeExam, Pricing, Trust, ErkenErisim, FAQ, FinalCTA, Footer
[sabit alt bant: CookieConsent, yalnız karar yokken]
```

Yerleşim kuralları:
- Kart akışta, `fixed` değil. 16 px yan boşluk; masaüstünde içerik genişliği sınırlı.
- Çerez bandı `fixed bottom-0 z-50`'dir (`CookieConsent.tsx`). Widget yalnız çerez kararı verildikten sonra görünür (öneri, §9-3); iki alt katman üst üste gelmez.
- Dokunma hedefleri en az 44 px (`min-h-11`, landing'deki mevcut desen).
- Odak: `focus-visible:outline-2` ve `brand-500` (landing deseni).
- Koyu tema: `bg-white dark:bg-gray-800`, `text-navy dark:text-gray-100` (FAQ kartıyla aynı desen). Kontrast ölçülmedi.
- Hareket: yalnız opaklık geçişi; `motion-reduce:transition-none`.
- Hidrasyon: kart istemcide, bağlanmadan sonra çizilir. Sunucu HTML'inde zaman veya rastgele içerik yok (geçmiş: `6455fed` "geri sayım hidrasyon hatası").
- Yer ayırma: kart görünmeden önce bölüm sabit bir boşluk alır; kartın belirmesi üstteki içeriği kaydırmaz.

## 6. Veri ve ölçüm

### 6.1 Alanlar

| Alan | Kaydedilir mi | Not |
|---|---|---|
| `widget_kodu` (`ilgi_v1`) | Evet | Soru değişirse kod artar (§9-11) |
| `sayfa_turu` (`landing`) | Evet | Şimdilik tek değer |
| `olay` (`gosterildi`, `secildi`, `kapatildi`, `hata`) | Evet | Sunucuda toplanır |
| `secenek_kodu` | Yalnız `secildi` için | 6 kodluk whitelist |
| `gun` (Europe/Istanbul) | Evet | Saat, dakika, saniye yok |
| IP, user-agent, referrer, cookie/kimlik, locale, sayfa sorgu parametreleri | **Hayır** | |
| Ad, e-posta, telefon, çocuk/okul bilgisi | **Hayır** | |

### 6.2 Depolama modeli (öneri)
- **Satır bazlı yanıt tablosu yok.** Yalnız günlük toplu sayaç: `ziyaretci_widget_sayac(gun, widget_kodu, sayfa_turu, olay, secenek_kodu, adet)`; birincil anahtar bu beş alanın tamamı.
- **Yazma:** tek RPC (`ziyaretci_widget_olay_kaydet`). Parametreler whitelist ile doğrulanır; `security definer`; `anon` yalnız bu fonksiyonu çalıştırabilir; tablo `revoke all` (`AGENTS.md` §1 madde 2: yetki genişletme yok).
- **Okuma:** yalnız `require_admin` ile korunan RPC. n < 5 hücre gösterilmez.
- Anket tablolarına yazılmaz (§8).

### 6.3 Hız sınırı ve kötüye kullanım
- **Seçenek A (öneri, v1):** IP kullanılmaz. Sitewide günlük üst sınır sayaçta uygulanır. Kötüye kullanım riski kabul edilir: sayılar yönlendiricidir, karar aracı değildir.
- **Seçenek B:** mevcut `rate_limit_kontrol` (`supabase/migrations/20261033000000_rate_limit.sql`). Bu tablo ham IP'yi `rate_limit_hits.anahtar` içinde tutar. Widget için yeni IP verisi üretmek hukuk onayı olmadan yapılmamalı (Q3).
- **Turnstile önerilmiyor:** tek dokunuşluk widget için sürtünme getirir. Landing formlarında zaten var.
- Edge Function gerekmez: RPC yeterli; `CAPTCHA_SECRET` bağımlılığı yok.

### 6.4 PostHog
- Widget olayları PostHog'a gönderilmez. Gerekçe: PostHog yalnız onayla çalışır (`AnalyticsProvider.tsx`), tarayıcı kimliği (`distinct_id`) üretir ve yanıtı bu kimliğe bağlar.

### 6.5 Metrikler

| Metrik | Tanım | Not |
|---|---|---|
| Gösterim | `gosterildi` olayı sayısı | Tekil değil; sekme başına |
| Yanıt oranı | `secildi` / `gosterildi` | Yaklaşık; aynı kişi birden çok sekmede sayılabilir |
| Kapatma oranı | `kapatildi` / `gosterildi` | |
| Gönderim hatası | `hata` / (`secildi` + `hata`) | Teknik sağlık ölçüsü |
| Seçenek dağılımı | Seçenek / `secildi` | n < 5 gizli |

Bunlar öğrenme metriği değildir. XP, süre veya görev tamamlama ile karıştırılmaz (`GROWTH_AND_MEASUREMENT.md`). Ürün ilgi sinyali olarak okunur.

Olay adları (sunucu tarafı, toplu): `ziyaretci_widget_gosterildi`, `_secildi`, `_kapatildi`, `_hata`.

## 7. Hukuk ve çerez

### 7.1 Kod ve metin bulguları
- `CookieConsent.tsx`: alt sabit bant; kabul ve reddet eşit ağırlıkta. Karar verilmeden her sayfada görünür.
- `lib/analytics/consent.ts`: karar `localStorage["hupo-analytics-consent"]` içinde. Sürüm `analitik-2026-10-taslak-1`; metin hâlâ "taslak".
- `components/analytics/AnalyticsProvider.tsx`: PostHog yalnız onayla yüklenir; izinli yollar `/`, `/demo`, `/gizlilik`, `/kosullar`.
- `messages/tr.json` `cookie.text` (satır 292): "Ürünü geliştirmek için yalnızca onayınla, herkese açık sayfalarda anonim sayfa görüntüsü ölçümü yaparız."
- `lib/legal/content.ts` (satır 67–72): "Ürünü geliştirmek için analitik ölçüm yalnızca onayınla çalışır." Kapsam: "sayfa görüntüleri ve genel cihaz ve tarayıcı bilgisi".

**Çelişki Ç2:** Widget sayımı "analitik" değildir, ama metnin "ürünü geliştirmek için ölçüm" ifadesine girer. Mevcut metin bu tür ölçümü yalnız onayla anlatıyor. Metin veya akış güncellenmeden widget yayınlanmamalı.

### 7.2 Hukuk onayı gereken sorular
- **Q1.** `sessionStorage` bayrağı için çerez veya yerel depolama bildirimi/onayı gerekir mi? Bayrak kişisel veri değildir ve "zorunlu" da değildir.
- **Q2.** Kimliksiz günlük toplu sayım gizlilik metnine yeni ölçüm olarak eklenip onaysız mı yürütülür, yoksa analitik onayına mı bağlanır? (Onaya bağlarsa yalnız onay verenler görür; örneklem yanlı olur.)
- **Q3.** Hız sınırı için ham IP'nin (`rate_limit_hits`) saklama süresi ve karma (hash) yöntemi. Widget'tan bağımsız mevcut konu.
- **Q4.** Günlük toplu sayım ve n < 5 hücre gizleme, "anonim" ifadesini karşılar mı?
- **Q5.** Widget metin sürümü (`ziyaretci-ilgi-v1`) analitik onay sürümünden (`taslak-1`) ayrı mı tutulmalı?

Bu belge hukuki görüş değildir.

## 8. Anket sistemiyle ilişki

| Seçenek | Değerlendirme | Karar |
|---|---|---|
| A. Mevcut `anketler` + `anket_yanitlari` | `anket_yanitlari.veli_id` her zaman dolu (ANKET §4). Anket veli girişi gerektirir. `web_sitesi` anket yüzeyi kaldırılacak (ANKET §1). Tek aktif anket kuralı (§5) bu widget ile karışır | Reddedildi |
| B. Anketlere yeni yüzey (`ziyaretci`) | Yine `veli_id` ister; yüzey sözlüğü (`SurveySurface`) değişir | Reddedildi |
| C. Ayrı en küçük yapı: tek sayaç tablosu + tek RPC | Kimlik yok, satır yok, anket şemasına dokunmaz, D1–D6 bağımlılığı yok | **Öneri** |
| D. PostHog olayı | Yalnız onay veren alt küme; tarayıcı kimliğine bağlanır | Reddedildi |

**Çelişki Ç1:** ANKET §1'deki "24 saatte en fazla 1 kart" ve "3/14/90 atlama" kuralları ziyaretçide uygulanamaz; ziyaretçinin kimliği ve sunucu oturumu yok. Önerilen: sekme bayrağı + sitewide günlük üst sınır. Kalıcı frekans kuralı giriş yapmış veliler için geçerli kalır. Bu sapma `PROJE_GUNLUGU.md` §24 ile hizalanmalı.

Anket metinleri (`messages/tr.json` `anket.*`, satır 306) kopyalanmaz. Widget kendi anahtarlarını kullanır (`landing.ziyaretciWidget.*`).

## 9. Riskler ve açık kararlar

1. **Bayrak saklama.** Seçenekler: sessionStorage (öneri), localStorage 30 gün (hukuk onayından sonra), hiçbiri (her yüklemede gösterim; kötü deneyim). Karar: sahip + hukuk (Q1).
2. **Toplu sayımın ölçüm statüsü.** Onaysız + gizlilik metni güncellemesi (öneri, hukuk onayıyla) veya analitik onayına bağlama (örneklem yanlı). Karar: hukuk (Q2).
3. **Çerez kararı yokken gizle.** Öneri: evet. İki alt katmanı ve ikili soruyu önler. Bedel: karar vermeyen ziyaretçi widget'ı görmez; yanlılık not edilir.
4. **Sitewide günlük üst sınır.** Değer, trafik tabanı olmadan belirlenemez. Öneri: ilk iki hafta yalnız izleme, sonra sınır.
5. **"Ortaokula geçiş" seçeneğinin kapsamı.** Öneri: genel metin, 5. sınıf kapsamı doğrulanana kadar. Doğrulanırsa "4. sınıftan 5. sınıfa geçiş hazırlığı" metnine dönülür. Doğrulama kaynağı: soru bankası ve içerik sahibi.
6. **Karar eşiği.** Öneri: toplam 100 yanıt olmadan yön okunmaz; n < 5 hücre gizli.
7. **Yer.** Öneri: `ParentPanel`–`DenemeExam` arası. Alternatifler: hero altı (erken, bağlamsız), footer öncesi (düşük görünürlük).
8. **Ön koşul sırası.** Anket `web_sitesi` kaldırma (ANKET D2) widget'tan önce tamamlanmalı. Karar: sahip onayı.
9. **Maskot pozu.** `dusunuyor.webp` kullanımı için tasarım sahibi onayı (landing'de Hupo pozu).
10. **Dil.** Öneri: önce yalnız TR; EN aynı anda yayınlanacaksa çeviri onayı.
11. **Soru değişimi.** Öneri: soru veya seçenek anlamı değişirse `widget_kodu` artar; eski sayılar ayrı kalır (ANKET soru kodu kilidi ilkesi).
12. **Anon anahtar.** `PROJE_GUNLUGU.md` §14.3: `web-panel/.env.local` anon anahtarı canlıda 401 döndürüyor. Bu çözülmeden widget canlıda kanıtlanamaz; sessiz hata yerine §4'teki hata durumu gösterilir.
13. **Değer algısı.** Ziyaretçi "neden cevaplayayım?" diye sorabilir. Tek fayda cümlesi: "Yanıtınız Hupolingo'yu geliştirmemize yardımcı olur." Daha büyük vaat yazılmaz.

## 10. Kabul kriterleri (ürün tarafı, test edilebilir)

1. 320 px genişlikte yatay kaydırma yok; soru ve 6 seçenek tek kolonda; her seçenek en az 44 px yüksekliğinde.
2. 1280 px'te seçenekler iki kolonda; "Şimdi değil" ve "Gönder" aynı yükseklikte.
3. Klavye: sıra seçenekler → Gönder → Şimdi değil → X. Ok tuşlarıyla radyo grubunda gezinme; Enter/Space ile seçim.
4. Ekran okuyucu: soru legend ile, her seçenek ayrı, gönderim sonucu `role="status"` ile okunur.
5. Sunucu yanıtı gelmeden "kaydedildi" görünmez. Hata durumunda seçim korunur.
6. Ağ isteğinin gövdesi yalnız dört alan içerir. Cookie veya localStorage yazılmaz; sessionStorage'da tek anahtar.
7. Kişisel veri alanı yok: ad, e-posta, telefon, okul, yaş/sınıf sorusu yok; form girişi sayısı (`text`, `email`, `tel`) sıfır.
8. Widget olayları PostHog ağ isteklerinde görünmez.
9. Widget yalnız `/` sayfasında çıkar; `/demo` ve diğer sayfalarda hiç çıkmaz.
10. Aynı sekmede yanıt veya kapatmadan sonra sayfa yenilemesinde tekrar görünmez.
11. Çerez kararı yokken kart görünmez; karar verildikten sonra en fazla bir gösterim.
12. Metinlerde sahte kanıt, sayı, yorum, uzman, indirim, deneme veya "size özel" ifadesi yok.
13. Koyu temada normal metin kontrastı en az 4.5:1 (ölçülerek doğrulanır; tahmin yetmez).
14. `prefers-reduced-motion` açıkken geçiş yok; hidrasyon konsol hatası yok; kart belirirken üst içerik kaymaz (görsel kontrol).
15. Yönetim raporunda (yapılırsa) n < 5 hücre gösterilmez.

## 11. Kapsam dışı ve uygulama önkoşulları

- Bu belge uygulama değildir. `PROJE_GUNLUGU.md` §24 satır 963: "Tasarım onayı ve hukuk (çerez/yerel depolama) sonrası uygulama ayrı görev."
- Önkoşullar: Q1–Q5 yanıtı; ANKET D2 (`web_sitesi` anket kaldırma); anon anahtar sorununun canlıda çözülmesi (§9-12).
- Kapsam dışı: admin yönetim ekranı, çoklu soru, sonuç gösterimi (sosyal kanıt riski), A/B testi, sınıf veya yaş sorusu, mobil uygulama widget'ı, EN yayını.

## 11-A. Karar kaydı (proje sahibi, 2026-10-16)

- **Q1 (sekme başına bayrak, yerel depolama):** Çerez onayı GEREKMEZ. Bayrak çerez banner'ındaki pazarlama/analitik kategorilerine bağlanmayacak. Aydınlatma metnine şu cümle eklenir: "Sitedeki bildirim ve ekran gösterimlerini oturum bazlı düzenlemek amacıyla zorunlu teknik yerel depolama araçları kullanılmaktadır." Uygulandı: `web-panel/src/lib/legal/content.ts`, "Çerezler ve ölçüm" bölümü.
- **Q2 (toplu sayım, onaysız):** Eklenebilir, ŞARTLARLA:
  1. Sayım sunucu tarafında anonim toplu sayaçtır. Tarayıcıya tekil tanımlayıcı (çerez, izleyici, kimlik) yazılmaz.
  2. Sayım kullanıcı segmenti veya kişisel veriyle ilişkilendirilmez ("hangi sınıf velisi tıkladı" gibi ölçümler yapılmaz). Bu tür bir ölçüm gerekirse Ölçüm Onayına bağlanır ve ayrı karar olur.
  3. Widget verisi PostHog'a veya başka analitik betiğine gönderilmez.
  4. Sunucu tarafında IP bu sayım için saklanmaz (Q3 kararı).
  Gizlilik metninin "ölçüm yalnızca onayla" cümlesi analitik betiğe aittir; bu sayım o kapsamda değildir. Hukuk onayı bu ayrımın yazılı teyidi için alınır.
- **Q3 (rate_limit_hits ham IP):** Karar: IP düz metin saklanmayacak. Tuzlu, günlük dönen özet (HMAC) ile saklanacak; tuzun değeri ortam değişkeninde durur, kodda ya da belgede yer almaz. Saklama süresi en çok 2 gün kalır (mevcut temizlik kuralı). Uygulama ayrı görev (veritabanı ve Edge Function değişikliği; uzak DB onayı gerekir). Not: barındırma ve Edge Function günlüklerindeki IP ayrı bir konudur; onun ayarı sağlayıcı panelinden yapılır.
- **Ç1 (anket bütçesi yerine sekme başına 1 gösterim):** Onaylandı.
- **Ortaokul geçişi seçeneği:** Hedef kitle 8–14 yaş olarak devam ediyor. "Ortaokula geçiş hazırlığı" seçeneği bu kapsamda kalır. Metin uygulama sırasında gözden geçirilir; 5. sınıf kapsamı doğrulanmadan iddia içeren bir metin yazılmaz.
- **Hupo pozu `dusunuyor.webp`:** Kullanım onaylandı.

## 12. Doğrulama notu

- Okunan kaynaklar: `CLAUDE.md`, `AGENTS.md` (kural 1, 2, 5, 6), `MASTER_BRIEF.md` (ilgili satırlar), `PROJECT_CONTEXT.md`, `ANKET_SISTEMI_MIMARI.md`, `PROJE_GUNLUGU.md` (§14.3, §15, §22–24), `GROWTH_AND_MEASUREMENT.md`, `BRAND_AND_VISUAL_RULES.md`, `decisions.md`, `web-panel/src/app/[locale]/(full-width-pages)/page.tsx`, `web-panel/src/app/[locale]/layout.tsx`, `components/landing/LandingClient.tsx`, `components/landing/sections/DuyuruSeridi.tsx`, `components/analytics/CookieConsent.tsx`, `components/analytics/AnalyticsProvider.tsx`, `lib/analytics/consent.ts`, `lib/legal/content.ts`, `messages/tr.json`, `supabase/functions/_shared/guvenlik.ts`, `supabase/migrations/20261033000000_rate_limit.sql`.
- Çalıştırılan kontrol: yok. Tasarım çalışması; kod ve veritabanı değişmedi. Görsel kontrol, kontrast ölçümü ve cihaz testi yapılmadı.
- `decisions.md` ve `PROJE_GUNLUGU.md` değiştirilmedi (proje sahibi talimatı). Önerilen karar kaydı: "2026-10-16: ziyaretçi widget'ı ayrı, kimliksiz, toplu sayımlı tasarım; anket tabloları kullanılmaz; uygulama hukuk onayına bağlı."
