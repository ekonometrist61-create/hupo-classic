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
