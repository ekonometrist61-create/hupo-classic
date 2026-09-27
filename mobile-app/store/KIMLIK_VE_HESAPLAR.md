# Uygulama Kimliği, Hesaplar ve İmza

## 1) Uygulama kimliği (paket adı) - SİZİN KARARINIZ

| Platform | Şu anki değer |
|---|---|
| Android `applicationId` | `com.ogrencihazirlik.ogrenci_hazirlik` |
| iOS bundle id | `com.ogrencihazirlik.ogrenciHazirlik` |
| Telefonda görünen ad | **Öğrenci Hazırlık** (Android ve iOS) |
| Sürüm | `pubspec.yaml` içindeki `version: 1.0.0+1` (1.0.0 = sürüm adı, +1 = sürüm kodu) |
| minSdk / targetSdk | Flutter varsayılanı: 24 (Android 7.0) / 36 |

Bunlar geçici (placeholder) değerlerdir. Şablon uygulamadan kalan bir isim değildir, ama kurumunuza ait bir alan adına da bağlı değildir.

**KRİTİK UYARI:** Kimlik, mağazaya İLK yükleme yapıldıktan sonra ASLA değiştirilemez (değişirse "yeni uygulama" olur; kullanıcılar, yorumlar, indirme sayısı kaybolur). Bu yüzden ilk yüklemeden ÖNCE karar verin. Alışılmış yöntem, sahip olduğunuz alan adının tersini kullanmaktır (ör. `com.sirketiniz.ogrencihazirlik`). Alan adınız yoksa bugünkü değerlerle devam edebilirsiniz. Android'de alt çizgi geçerlidir ama pek şık durmaz; değiştirecekseniz `com.ogrencihazirlik.ogrenci` gibi sade bir ad önerilir.

Değiştirmek isterseniz geliştiriciye söyleyin; şu yerler birlikte güncellenmelidir: `android/app/build.gradle.kts` (namespace + applicationId), `MainActivity.kt` paket klasörü/satırı, `ios/Runner.xcodeproj/project.pbxproj` (PRODUCT_BUNDLE_IDENTIFIER) ve bildirim (Firebase) ayarlarındaki kayıtlı uygulama kimliği.

**Sürüm numarası:** Mağazaya her yeni yüklemede `pubspec.yaml`'daki `+1` kısmı artırılmalıdır (`1.0.0+2`, `1.0.1+3` ...). Aynı sürüm kodu ikinci kez kabul edilmez.

## 2) İzinler

Uygulama yalnızca **INTERNET** iznini kullanır (giriş ve soru/ilerleme verisi için). Konum, rehber, mikrofon, kamera izni YOKTUR ve eklenmemelidir (çocuk uygulamasında mağaza incelemesini zorlaştırır). Bildirim özelliği geldiğinde `POST_NOTIFICATIONS` (Android 13+) ilgili eklenti tarafından otomatik eklenir.

## 3) Hesaplar ve ücretler (yaklaşık; fiyatlar ve kurallar değişebilir, mağaza sitesinden doğrulayın)

| Hesap | Ücret | Not |
|---|---|---|
| Google Play Console | Tek seferlik yaklaşık 25 USD | Kimlik doğrulama ister. Yeni kişisel hesaplarda yayına çıkmadan önce kapalı test şartı (ör. belirli sayıda test kullanıcısı, belirli gün) olabilir; güncel kuralı Play Console'da kontrol edin. Kurum hesabı için D-U-N-S numarası istenebilir. |
| Apple Developer Program | Yıllık yaklaşık 99 USD | Yenilenmezse uygulama mağazadan kalkar. |
| Gizlilik politikası web sayfası | Ücretsiz barındırılabilir | İki mağaza da herkese açık bir URL ister. Bkz. `VERI_GUVENLIGI_VE_GIZLILIK.md`. |

## 4) Yayın imza anahtarı (Android)

1. `store\anahtar-olustur.bat` dosyasına çift tıklayın, sorulara yanıt verin (önce Android Studio kurulu olmalı; Java oradan gelir).
2. Dosya `C:\Users\<siz>\ogrenci-hazirlik-anahtar\upload-keystore.jks` olarak oluşur, `android\key.properties` otomatik yazılır (Git'e girmez).
3. **Klasörü USB belleğe ve ikinci bir güvenli yere kopyalayın; şifreyi kağıda yazın.** Kaybederseniz uygulamayı güncelleyemezsiniz.
4. Google Play'de "Play App Signing" (varsayılan) açılır; bu anahtar "upload key" olur. Kaybolursa Google desteğiyle sıfırlanabilir ama yine de yedekleyin.
5. Anahtar yokken derleme "debug" anahtarıyla imzalanır: yalnızca kendi telefonunuzda denemek içindir, Play Store kabul etmez.
