# Sürümleme kuralı (app ve panel)

Bu kural mobil uygulama (`mobile-app`) ve web paneli + site (`web-panel`) için geçerlidir. Veritabanı migration'ları iki tarafın ortak sözleşmesidir; bu yüzden her sürüm notu migration numaralarını da listeler.

## Sürüm numarası: MAJOR.MINOR.PATCH

- **MAJOR (X.0.0):** Geriye uyumsuz değişiklik. Eski app ya da eski panel yeni veriyle çalışmaz; eski sürümlerin desteği biter.
- **MINOR (x.Y.0):** Büyük değişiklik. Aşağıdakilerden biri varsa MINOR artar:
  - Yeni bir modül ya da kullanıcı yüzeyi (ör. Okuma Dünyası).
  - Veri sözleşmesine (RPC, paket biçimi, migration) geriye uyumlu eklenti.
  - Tek bir değişikliğin 5'ten fazla alanı ya da 2 yüzeyi etkilemesi.
- **PATCH (x.y.Z):** Hata düzeltmesi, metin, küçük görünüm düzeltmesi. Veri değişmez ya da yalnız düzeltme migration'ı içerir.

Panel 0.x iken: büyük değişiklik 0.Y.0, düzeltme 0.y.Z. Panel 1.0.0'a ancak tüm yüzeyler kararlı olduğunda çıkılır.

## Nerede tutulur

- **App:** `mobile-app/pubspec.yaml` içinde `version: X.Y.Z+B`. `+B` (build numarası) her APK derlemesinde bir artar (Android `versionCode`).
- **Panel:** `web-panel/package.json` içinde `"version": "X.Y.Z"`.
- **Git etiketi:** Her sürümde `app-vX.Y.Z` ve/veya `panel-vX.Y.Z` etiketi, sürümün birleştirme (merge) commit'ine konur.
- **Sürüm notu:** Bu dosyanın altında, en yeni en üstte.

## Yayın akışı

1. Değişiklik bir feature branch'inde geliştirilir; her mantıklı adım ayrı commit'tir.
2. Sürüm numarası, büyük değişiklik tanımına göre belirlenir ve ilgili `pubspec.yaml` / `package.json` güncellenir.
3. Sürüm notu eklenir: tarih, app ve panel sürümleri, değişiklikler, eklenen migration numaraları, uyumluluk notu.
4. Test kapıları: app için `flutter test`; panel için `tsc --noEmit`, `eslint`, `npm run build`; veritabanı için PGlite testleri.
5. Migration'lar önce `db:preview`, sonra onayla `db:deploy` ile uygulanır.
6. Branch master'a birleştirilir; etiketler eklenir ve master push edilir. Panel Vercel'de otomatik yayınlanır.
7. App APK'sı derlenir ve kurulur (ya da mağazaya gönderilir).

## Uyumluluk

- Panel değişikliği veri sözleşmesi değiştiriyorsa, sürüm notunda hangi app sürümünden itibaren çalıştığı yazılır.
- Migration'lar geri alınamaz varsayılır; geri dönüş gerekirse yeni bir ileri migration yazılır.

---

## Sürüm notları
### panel 0.11.3 · 2026-11-14

Düzeltme (PATCH). Hakkımızda sayfası yeni metinle güncellendi; Hakkında menüsü eklendi; örnek hikâye denemesi uygulamadaki akışa göre yeniden kuruldu.
- /hakkimizda: kurucu hikâyesi metni; iletişim bölümü korundu. Landing header ve mobil menüde "Hakkında" bağlantısı.
- /okuma-demo: kahraman seçimi (ad, yol arkadaşı, uygulamadaki ad kuralları), hikâye metninde ad belirteçleri, soru ekranı (şık, Cevapla, geri bildirim, ipucu), sonuç. Kayıtsız; cevaplar sunucuya gitmez.
- sinif-okuma-anlama: "Örnek hikâyeyi deneyin" adımları yeni akışa göre.

**Migration:** yok.

**Uyumluluk:** Yalnız panel; app ve veri sözleşmesi değişmedi.
### panel 0.11.2 · 2026-11-14

Düzeltme (PATCH). Landing metin sadeleştirmesi ve tip düzeltmesi.
- Landing: "Söz verdiklerimiz" bölümü kaldırıldı; örnek ekran, erken erişim ve pilot notları kaldırıldı; 8 Dünya bölümündeki "Veli hesabı oluştur" butonu kaldırıldı; öğrenme ilkeleri kartlarındaki araştırma/tasarım alt blokları kaldırıldı; ana sayfa Hakkımızda bölümünden pilot notu kaldırıldı.
- Landing: "ÖĞRETME TARZI / Hupo nasıl çalışıyor?" başlığı; hikâye adımı metinleri güncellendi.
- Tip düzeltmesi: auth formlarında `kaynak` (UTM) çözümleme, dil seçici (İngilizce geçici kapalı), `temel-mesajlar`; `tsc --noEmit` temiz.

**Migration:** yok.

**Uyumluluk:** Yalnız panel; app ve veri sözleşmesi değişmedi.

### panel 0.9.0 · 2026-11-12

Yeni kullanıcı yüzeyi (MINOR: yeni sayfa ve iki yeni landing bölümü).
- Landing: "Onlarca Hikâye" (yayındaki hikâyelerin özeti, tür çipleri) ve "Senin Hikâyen" (kahramanı çocuğun seçtiği deneyim, üç adım, gerçek uygulama ekranı) ayrı bölümler oldu. Hupo kuşu bu iki bölümden kaldırıldı.
- Yeni sayfa `/hikaye-demo?sinif=3…7`: her sınıf için yayında ve insan onaylı bir hikâye parçası, deyim kartı, bir anlama sorusu ve cevaba geri bildirim. Yazılan kahraman ve yol arkadaşı adları yalnız sayfa belleğinde kalır; kaydedilmez.
- Sınıf 7 demosunda yol arkadaşı adı sabittir (soru metni "Nehir" adına bağlı).
- Landing okuma özeti çağrısı ortak yardımcıya taşındı (`lib/okuma/site-ozeti.ts`).

**Migration:** yok.

**Uyumluluk:** Veri sözleşmesi değişmedi. Yeni sayfa yalnız `okuma_site_ozeti` RPC'sini kullanır; demo parçaları statik içeriktir ve yayın sürümü değişince güncellenmelidir.

**Bilinen sınır:** 72 yayın hikâyesinin 13'ünde kahraman adı yoktur; landing "çoğu hikâyede" der. Bu hikâyelerin düzenlenmesi editör onayına bağlı ve bu sürümde yoktur.

### panel 0.8.1 · 2026-11-12

Düzeltme (PATCH: metin ve görünüm; veri ve migration değişmedi). Satış temas noktaları (FK-006, K-0258, yalnız web kısmı).
- Landing hero: rozet "3–7. Sınıf · Proje Ortaokulu Hazırlığı"; pilot kutusu kaldırıldı; düşük oranlı derste kırmızı damga yerine nötr "Tekrar önerilir" notu.
- Fiyat bölümü: rozet "Önerilen"; deneme notu; planlar arası kapsam ve pilot notları fiyat bölümüne taşındı.
- Footer: tıklanamayan mağaza rozetleri ve yer tutucu bağlantılar kaldırıldı; "Mobil uygulama yakında." notu.
- Öğrenme Bilimi: kısa blok (kanıt kartları kaldırıldı; kaynaklar /yontem sayfasında). Ana sayfa sırası: veli raporu → okuma dünyası → karakterler. Keşfet bölümü yerinde kaldı.
- Veli giriş, kayıt ve parola ekranları: "siz" hitabı, "Hupolingo" yazımı, Nunito yazı tipi; kayıt sonrası "sonraki adım" metni. Veli paneli abonelik kartı ham hata yerine kullanıcı dostu metin gösterir.
- Kapsam dışı: mobil uygulama kısmı (ayrı app sürümü), premium özellik migration'ı (20261218), kayıt formundaki UTM takibi (master'da bilerek kapalı).

**Migration:** yok.

**Uyumluluk:** Veri sözleşmesi değişmedi; mevcut app sürümleriyle uyumlu.

### panel 0.8.0 · 2026-11-12

Yeni kullanıcı yüzeyi (MINOR: demo yeniden kuruldu, tanıtım bölümleri, RPC sınıf bandı).
- Örnek soru demosu: önce sınıf seçimi (3–7), her sınıf için 5 özgün soru (10 şekilli), altı çizili anahtar, yanlış cevapta öğretici ve cesaretlendirici açıklama, sonunda veliye beceri bazlı özet. demo_tamamlandi olayına sinif özelliği eklendi.
- Landing: "Senin Hikâyen" tanıtımı genişletildi (sınıf aralığı sabit 3–7); yeni "Keşfet" bölümü (Çarpım Şifreleri, Kelime Evreni, Arena; dürüst durum rozetleri).
- Sorular ayrı ajanla kör çözüldü (25/25 anahtarla uyumlu, 3 düzeltme). Kazanım kodu yazılmadı.
- Commit: 8738022'den cherry-pick (feature dalının tamamı alınmadı).

**Migration:** 20261219000000 (okuma_site_ozeti yalnız 3–7. sınıf hikâyelerini sayar; uzak veritabanında 2026-11-12'de uygulandı, db query --linked ile; geçmiş migration repair ile işlendi).

**Uyumluluk:** Panel 0.8.0 migration olmadan da çalışır; yalnız hikâye sayısı 2. ve 8. sınıf hikâyelerini de içerir.
### panel 0.7.2 · 2026-11-10

Düzeltme (PATCH: yayın kapısı arayüzü; veri sözleşmesi değişmez, migration bu sürümde yok).
- Hikâye yayın adımı artık yalnız insan onayına bakar ("İnsan onayladı" + "Yayınla"). Önceden panel Ajan A ve Ajan B pass olmadan yayın düğmesini kapatıyordu; sunucu kuralıyla (20261201, kullanıcı kararı 2026-11-10) uyumsuzdu. Ajan sonuçları kaydedilir ve görünür, yayını engellemez.
- Yayın süzgeci ve toplu onay yalnız insan kararına bakar. TR/EN metinler güncellendi.
- Commit: a3eff78 (2055be8'den cherry-pick; feature dalının tamamı alınmadı).

**Migration:** 20261201000000 (dosya bu sürümde; uzak veritabanında zaten uygulanmış, `db:status` ile doğrulandı).

**Uyumluluk:** Panel 0.7.2 yalnız 20261201 uzak veritabanında uygulanmışken doğru çalışır. Migration yoksa sunucu eski kuralı (ajan A ve B pass) uygular ve yeni panelde ajan geçmeyen sürüm yayınlanamaz.

### panel 0.7.1 · 2026-11-10

Düzeltme (PATCH: metin ve görünüm; veri değişmez, migration yok).
- Landing fiyat bölümündeki "14 Gün İade Garantisi" ve "%100 Güvenli Ödeme" rozetleri kaldırıldı (kanıt yoktu). "İstediğin Zaman İptal" ve "Gizli Ücret Yok" kullanıcı kararıyla korundu.
- Commit: 8a14222 (master'a 9999305 olarak alındı). Canlı HTML kontrolü: iki iddia yok.

**Migration:** yok.

**Uyumluluk:** Eski panel ve app ile aynen çalışır; veri sözleşmesi değişmez.

### panel 0.7.0 · 2026-11-08

Büyük değişiklik (MINOR: yeni kullanıcı yüzeyleri ve veri sözleşmesine geriye uyumlu eklenti).
- Veli rehberi altyapısı: /rehber/carpim-tablosu-pif-noktalari sayfası, e-posta + sınıf (3–7) formu ve lead-magnet-kayit uç noktası. **Bayrak kapalı** (NEXT_PUBLIC_LEAD_MAGNET_ACIK): sayfa 404, landing bandı ve footer bağlantısı yok. Açılış için hukuk onayı (GÖR-078), şirket bilgileri ve ticari ileti metnindeki yer tutucuların kapanması gerekir.
- Landing: "Öğrenme Bilimi" bölümü (3 araştırma kartı, DOI bağlantılı, "Hupolingo'nun sonucu değildir" dipnotu) ve footer'da "Yöntem ve kaynaklar" bağlantısı.
- Yeni sayfa /yontem: bilmediklerimiz, yöntem ve denetim süreci, 12 kaynaklı araştırma kütüphanesi.
- Migration: \20261030000100_lead_magnet_kayit\ (lead_magnet_kayitlari, append-only lead_magnet_izin_logu, lead_magnet_kayit_ekle). Üretimde uygulandı.
- Edge function: \lead-magnet-kayit\ (--no-verify-jwt). Üretimde deploy edildi. Operasyon notu: \CAPTCHA_SECRET\ 2026-11-08 güncellendi; bu, canlı deneme ön kayıt ve veli adayı formlarını da etkiler.
- Analitik: bu yayında UTM okuması lead magnet formunda yok (\58dfc57\ henüz master'da değil). Lead magnet olayları (\lead_magnet_*\) taksonomide tanımlı, bayrak kapalı.
- Uyumluluk: App etkilenmez (yeni RPC yok, mevcut sözleşme değişmedi).
### panel 0.6.3 · 2026-10-30

Küçük görünüm ve kod kalitesi düzeltmesi (PATCH).
- Çerez bandı 320 px'te metni kesmiyor; metin gerekirse iki satıra iniyor. Sayfa sonundaki boşluk bandın ölçülen yüksekliğini izliyor.
- Çerez bandının görünürlüğü `useSyncExternalStore` ile okunuyor; eslint `set-state-in-effect` uyarısı kalktı. Onay ve ret davranışı aynı.

Migration yok. Uyumluluk: App değişmedi.

### panel 0.6.2 · 2026-10-30

Küçük görünüm düzeltmesi (PATCH). Landing ekran matrisi bulguları 4–5.
- Çerez şeridi telefonda kompaktlaştırıldı (69 px → 57 px, düğmeler 44 px). Bant açıkken sayfanın sonuna aynı yükseklikte boşluk eklenir; son içerik bantın altında kalmaz. Onay ve ret mantığı değişmedi.
- 1024 px ve üstünde masaüstü menü görünür (eşik xl → lg); mobil menü 1024 px'ten itibaren gizlenir.

Migration yok. Uyumluluk: App değişmedi, metin ve veri değişmedi.

### panel 0.6.1 · 2026-10-29

Küçük görünüm düzeltmesi (PATCH). Landing ekran matrisi (320–1920 px) bulguları 1–3.
- Hero: telefon genişliğinde "ÖRNEK RAPOR" kartı telefon maketinin altına alındı, Hupo karakteri soru metnini örtmüyor; 1024 px'te kart sağ kenardan boşluklu.
- Okunurluk: 11 px yazılar 12 px (etiket, yüzde rozetleri), "Örnek veri" uyarısı 13 px.
- Dokunma hedefleri: üst menü bağlantıları ve logo, alt bilgide SSS/Blog en az 44 px.

Migration yok. Uyumluluk: App değişmedi, metin ve akış değişmedi.

### panel 0.5.0 · 2026-10-25

Büyük değişiklik (MINOR: yeni RPC, migration, yönetici yüzeyi). Hikâye Atölyesi toplu yayın.
- Liste: "Seçilenleri yayına al" ve "Seçilenleri yayından çek" düğmeleri. Önce kuru çalıştırma: her hikâye için "yapılacak" ya da "atlandı + neden" gösterilir; onaylanınca gerçek işlem yapılır.
- Yayına al: her hikâyenin en yeni taslak veya incelemedeki sürümü; Ajan A ve Ajan B "geçti", insan kararı "onaylandı", inceleyen kayıtlı olmalı. Taslak önce incelemeye geçer; önceki yayındaki sürüm arşive gider. Yayın kapısı sunucuda değişmedi.
- Yayından çek: yayındaki sürüm arşive alınır; okuma oturumları ve karneler korunur.
- Yeni hata kodları: ZATEN_YAYINDA, YAYINDA_DEGIL.

**Migration'lar (uzak veritabanında uygulandı):** 20261094000000.

**Uyumluluk:** App değişmedi. Migration uygulanmadan toplu yayın düğmeleri "kurulu değil" uyarısı verir; mevcut tek tek yayın ve toplu arşiv/silme etkilenmez.

### panel 0.4.0 · 2026-10-25

Büyük değişiklik (MINOR: yeni yönetici yüzeyi). Hikâye Atölyesi liste ekranı: denetim rozetleri, denetim süzgeci, toplu insan onayı.
- Liste: her sürüm için Ajan A, Ajan B ve İnsan rozetleri; "Denetim" süzgeci (ajanlar geçti, ajan bekliyor, insan onaylı, insan bekliyor, yayına hazır).
- Toplu onay: işaretli hikâyelerin taslak ya da incelemedeki sürümlerinde yalnız insan kararı değişir; ajan sonuçları olduğu gibi kalır. Onay için Ajan A ve Ajan B "geçti" olmalıdır. Kuralları sunucu (`okuma_surum_durum_degistir`) zorlar; hatalar sürüm başına gösterilir.
- Toplu onay yayındaki sürüme dokunmaz; yalnız taslak ve incelemedeki sürümler etkilenir.

**Migration:** yok (mevcut RPC kullanılır).

**Uyumluluk:** Sunucu sözleşmesi değişmedi; panel 0.3.0 ile aynı RPC'ler.
### app 1.3.1+5 · 2026-11-09

Küçük değişiklik (PATCH: mevcut ekranın eksik kalan parçası; veri sözleşmesi değişmedi).
- Çocuk hikâye seçiminde "Veli tercihleri" çipi ve kartlarda "Veli tercihi" rozeti: veli panelinde seçilen değerle eşleşen hikâyeler filtrelenir ve rozetlenir. Liste sıralaması bu değerle eşleşen hikâyeleri öne alır (sunucu tarafı, mevcut RPC).
- Test: okuma değer filtresi ve tüm mobil paket (`flutter test`) geçti. Cihazda görsel kontrol bu sürümde ayrıca yapılmalı.

Migration yok. Uyumluluk: Sunucu sözleşmesi değişmedi (`okuma_katalog_filtre`, `okuma_veli_degerleri_getir/ayarla`, migration 20261050000200/300 zaten uygulanmış; canlıda 2026-11-09 testinde doğrulandı).

### app 1.4.0+6 · panel 0.4.0 · 2026-10-29

Büyük değişiklik (MINOR: kartsız ücretsiz deneme ve özellik sınırları; veri sözleşmesine geriye uyumlu eklenti).
- Kayıtta 14 gün ücretsiz deneme (veli hesabı açılınca). Deneme sırasında soru, Kelime Evreni, çarpım, okuma, meydan okuma ve deneme sınavı sınırları (günlük ya da deneme süresi boyunca).
- Deneme bitince deneme sınavları ücretsiz planda kapanır; ilerleme ve tekrar listesi açık kalır.
- Çocuk profilinde "Ücretsiz deneme" kartı (kalan gün, sınırda olan özellikler); meydan okuma ve kelime hatalarında sınır metni.
- Panel: Ayarlar'da "Deneme sınırları" (yönetici); üyelikte çocuk başına deneme kartı.
- Premium gating açık: ücretsiz hesap günlük 20 soru ile sınırlanır (mar-oto-ai kararı).

**Migration:** 20261125000000 (uygulandı), 20261126000000 (uygulandı), 20261127000000 (uygulandı).

**Uyumluluk:** Eski app (1.3.x) yeni deneme alanlarını yok sayar; sınır hataları eski sürümde genel hata metni olarak görünür. Panel 0.4.0 yeni RPC'leri kullanır; migration'lar uygulanmadan panel deneme kartını "bilgi yok" olarak gösterir.

### app 1.3.0+4 · 2026-10-25

Büyük değişiklik (MINOR: yeni seçim yüzeyi). Kahraman seçimi ve vitrin görselleri yenilendi.
- Kahraman seçimi ("Senin Hikâyen"): renkli başlık kartı; Ben ve Hupo büyük kart; Ailem, Arkadaşım, Hayvan Dostlarımız, Araçlar kompakt kart; "Diğer kahraman seçenekleri" altında Hayalî karakter ve Başka biri. Karakter görselleri açıkça seçilir ("Başka biri" için büyükanne görseli çıkmaz).
- Hayvan Dostlarımız (at, aslan, fil, kartal, kedi, köpek, kurt, tilki, panda, kaplumbağa) ve Araçlar (otomobil, tren, uçak, vapur, balon, uzay gemisi, denizaltı, arazi aracı, bisiklet, robot araç) alt seçenekleri. Seçilen ad kutuya öneri olarak yazılır; sunucuya yalnız tür kodu gider.
- Öğren vitrini: kapak görselleri Türkiye'ye uygun yeniden üretildi (Galata, Safranbolu, Kapadokya, Efes, Ay'da astronot); "Tüm hikâyeler" bağlantısı kapak şeridi başlığına, seri rozeti başlığın sağına alındı; Tüm hikâyeler ekranındaki yinelenen "Hikâyemi oluştur" kaldırıldı.
- Web: `app.hupolingo.com` yeni derlemeyle güncellenir (Vercel `hupo-app-web-yeni` projesi elle yüklenir; git push'u tetiklemez).

**Migration:** yok.

**Uyumluluk:** Sunucu sözleşmesi değişmedi; tür kodları aynı.
### app 1.2.0+3 · 2026-10-24

Büyük değişiklik (MINOR: yeni kullanıcı yüzeyi). Öğren sekmesinde HupoRead vitrini.
- Öğren: "HupoRead" başlığı, seri rozeti, duruma göre ana hikâye kartı (yeni kullanıcı, öneri, yarım kalan hikâye, kota dolu), kategori kapak şeridi (katalogdan; hikâyesi olmayan kategori gizlenir).
- "Tüm hikâyeler" keşif ekranı: yarım kalan hikâye, "Hikâyemi oluştur", tür kategorileri. Kategori kapağı ilgili türün listesini filtreli açar.
- Yarım kalan hikâye yalnız bu cihazda tutulur (sunucuya gönderilmez); aynı hikâyeye dönünce kaldığı sayfadan açılır; hikâye bitince silinir.
- Düzeltme: PDF kapağında hikâye sahne görseli artık doğru dosyadan okunur (önceden yol eksikti, kapak boş kalıyordu).

**Migration:** yok. Mevcut RPC'ler kullanılır (okuma_seri_ve_oneri, okuma_katalog_filtre).

**Uyumluluk:** Panel 0.3.0 ile çalışır. Kota kuralı değişmedi: yeni hikâye günde bir kez; kota dolu iken yarım hikâye öne çıkmaz.

**Bilinen açıklar:** Yarım kalan hikâye yalnız bu cihazda tutulduğu için cihaz değişince kaybolur. Derleme bu turda yalnız debug APK olarak yapıldı; yayın imzası için `android/key.properties` yok.

### panel 0.3.0 · 2026-10-24

Büyük değişiklik (MINOR: RPC, migration, paket biçimi). Soru Atölyesi JSON paket içe aktarma.
- `admin_import_questions_v2` RPC'si: Soru Atölyesi paketini (sürüm 1, parti kimliği, sınıf 1–8) tek işlemde içe aktarır; tekrarları ve hatalı satırları ayırır, "hepsi ya da hiçbiri" seçeneği vardır.
- Parti geri alma: parti kimliğiyle sorular silinmeden "reddedildi" yapılır; öğrenci cevap geçmişi korunur.
- Panel: Toplu Soru Ekleme sayfasına `PaketImport` ekranı (dosya seçme, önizleme, sonuç özeti, reddedilen satırlar, geri alma); TR/EN metinler.

**Migration'lar (uzak veritabanında uygulandı):** 20261047000000, 20261073000000.

**Uyumluluk:** İçe aktarılan sorular varsayılan olarak `beklemede` girer; yalnızca yönetici "insan onayı taşıyanlar onaylı girsin" kutusunu işaretlerse ve satırda insan onayı (onay/duzeltildi) varsa `onaylandi` olur. App tarafında değişiklik yoktur; öğrenciye dönük bir değişiklik yoktur (beklemedeki sorular öğrenciye gitmez).

### panel 0.2.1 · 2026-10-23

Düzeltme (PATCH). Hikâye Atölyesi: "İncele ve yönet" detayı listenin altında açılıp oraya kaydırılıyor; ağır içerik yalnız düzenleme ve önizleme istenince yükleniyor; yayın adımları detayda gösteriliyor.

### app 1.1.0+2 · panel 0.2.0 · 2026-10-23

Büyük değişiklik (MINOR).

**Okuma Dünyası (yeni modül)**
- Mobil: okuma akışı, kelime ve atasözü anlamları (hikâye paketi içinde), kavram ikonları, otomatik kaydırma, soru geri bildirimi, anket (isteğe bağlı puan), sonuç ekranı, PDF indirme (kapakta sahne görseli).
- Panel: Hikâye Atölyesi (içe aktarma, düzenleme, sürüm yönetimi, toplu arşiv/silme, karne uyarıları, sözlük yükleme), veli ve öğretmen dashboard metrikleri, kullanım süresi raporu.
- Site: `/okuma-demo` ve `/okuma/sinif-okuma-anlama` (bağlantısız, noindex); ana sayfada gerçek sayılarla "Hikâyeler" bölümü.

**Migration'lar (uzak veritabanında uygulandı):** 20261057, 20261058, 20261059, 20261060, 20261061, 20261062, 20261063, 20261064, 20261065, 20261066, 20261067, 20261068, 20261069, 20261070, 20261071, 20261072, 20261074, 20261075, 20261076, 20261077, 20261078, 20261079.

**Uyumluluk:** Okuma modülü app 1.1.0+2 ile birlikte çalışır. Önceki app sürümlerinde okuma modülü yoktur, etkilenmez. Panel 0.2.0 yeni RPC'leri kullanır; 20261078 ve 20261079 uygulanmadan yeni alanlar ve toplu işlem gelmez.

**Bilinen açıklar:** Yayına alınmamış yeni hikâye sürümleri; insan okuması bekliyor. Gerçek cihazda PDF indirme ve otomatik kaydırma henüz doğrulanmadı.
