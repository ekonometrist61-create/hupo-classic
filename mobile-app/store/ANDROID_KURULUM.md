# Android'de Gerçek Uygulama Yapma - Sıfırdan Kurulum Rehberi

Bu rehber hiç yazılım bilmeyen biri için yazıldı. Her adımı sırayla yapın. Takıldığınız yerde ekran görüntüsü alıp bize gönderin.

**Toplam süre:** İndirme ve kurulum yaklaşık 1 saat. **Yer:** yaklaşık 10 GB boş disk alanı. **Bilgisayar:** En az 8 GB RAM önerilir (Android Studio hafızayı çok kullanır; kurulum sırasında diğer programları kapatın).

> Not: Bu bilgisayarda şu an Android araçları KURULU DEĞİL (kontrol edildi: Flutter'da Android SDK yolu tanımlı değil, `ANDROID_HOME` yok, `%LOCALAPPDATA%\Android\Sdk` klasörü yok, Java/keytool yok). Bu yüzden henüz APK üretilemedi. Aşağıdaki adımlar bunu çözer.

---

## Adım 1 - Android Studio'yu kurun

1. Tarayıcıda şu adrese gidin: **https://developer.android.com/studio**
2. **"Download Android Studio"** düğmesine tıklayın, şartları kabul edip indirin (yaklaşık 1 GB).
3. İnen `.exe` dosyasına çift tıklayın. **Next - Next** diyerek ilerleyin.
   - "Choose Components" ekranında **Android Studio** ve **Android Virtual Device** kutuları işaretli kalsın.
4. Kurulum bitince **Finish** deyin ve Android Studio'yu açın.
5. Karşılama sihirbazı çıkar: **"Standard"** kurulumu seçin, **Next**. Lisans ekranında her başlığı seçip **Accept** yapın, **Finish** deyin. İndirmeleri bekleyin (10-20 dk).

## Adım 2 - Gerekli parçaları işaretleyin (SDK Manager)

1. Android Studio açıkken **More Actions (Diğer) > SDK Manager** veya **Tools > SDK Manager**'i açın.
2. **SDK Platforms** sekmesi: en üstteki yeni sürüm (ör. "Android 16 / API 36") işaretli olsun.
3. **SDK Tools** sekmesi: şunları **işaretleyin**:
   - **Android SDK Build-Tools**
   - **Android SDK Command-line Tools (latest)** - çok önemli, mutlaka
   - **Android SDK Platform-Tools**
   - (Android Emulator isteğe bağlıdır; gerçek telefon kullanacaksanız gerekmez)
4. **Apply > OK** deyin, indirmeyi bekleyin.
5. Aynı pencerenin en üstündeki **"Android SDK Location"** yolunu not edin. Genelde: `C:\Users\<KULLANICI>\AppData\Local\Android\Sdk`

## Adım 3 - Flutter'a Android'i tanıtın

Windows'ta **Başlat**'a `cmd` yazıp **Komut İstemi**'ni açın. Sırayla yazın (her satırdan sonra Enter):

```
C:\src\flutter\bin\flutter config --android-sdk "C:\Users\<KULLANICI>\AppData\Local\Android\Sdk"
C:\src\flutter\bin\flutter doctor --android-licenses
```

- İkinci komut sürekli soru sorar: her seferinde **y** yazıp Enter'a basın (lisansları kabul ediyorsunuz).
- Sonra kontrol edin: `C:\src\flutter\bin\flutter doctor`. **Android toolchain** satırında yeşil tik görmelisiniz. (Visual Studio, Xcode ile ilgili sarı uyarılar bizi ilgilendirmez.)

## Adım 4 - Telefonunuzu hazırlayın

1. Telefonda **Ayarlar > Telefon hakkında** bölümüne girin. **Yapı numarası**'na (bazı telefonlarda "MIUI sürümü") **7 kez** hızlıca dokunun. "Geliştirici oldunuz" yazar.
2. **Ayarlar > Sistem > Geliştirici seçenekleri**'ni açın (bazı markalarda "Ek ayarlar" içinde). **USB hata ayıklama**'yı (USB debugging) açın.
3. Telefonu USB kablosuyla bilgisayara takın (veri kablosu olmalı; sadece şarj kablosu çalışmaz). Telefonda "Bu bilgisayara izin ver?" çıkarsa **her zaman izin ver** deyin.
4. Komut İstemi'nde `C:\src\flutter\bin\flutter devices` yazın. Listede telefonunuzun adını görmelisiniz.

## Adım 5 - Uygulamayı telefona kurun

Komut İstemi'nde proje klasörüne girin (klasör adında Türkçe karakter var; sorun çıkarsa klasörü `C:\ogrenci-app` gibi düz bir yere kopyalayın):

```
cd "C:\Users\cengi\OneDrive\Desktop\Fırsat Bulucu-Ürün Geliştirme\mobile-app"
C:\src\flutter\bin\flutter run --release
```

İlk seferde 5-15 dakika sürer (Gradle çok şey indirir). Bitince uygulama telefonda açılır ve kurulu kalır. Kabloyu çıkarabilirsiniz.

## Adım 6 - Paylaşılabilir dosyalar üretme

**Arkadaşlara/test edenlere göndermek için APK:**
```
C:\src\flutter\bin\flutter build apk --release
```
Çıktı: `mobile-app\build\app\outputs\flutter-apk\app-release.apk`

**Google Play'e yüklemek için AAB (mağaza bunu ister):**
```
C:\src\flutter\bin\flutter build appbundle --release
```
Çıktı: `mobile-app\build\app\outputs\bundle\release\app-release.aab`

> ÖNEMLİ: Mağazaya yüklemeden ÖNCE `store\anahtar-olustur.bat` dosyasına çift tıklayıp imza anahtarınızı oluşturun (aksi halde derleme "debug" anahtarıyla imzalanır ve Google Play kabul etmez). Anahtarı KAYBETMEYİN, yedekleyin! Ayrıntı: `KIMLIK_VE_HESAPLAR.md`.

## APK'yı arkadaşlara gönderme

1. `app-release.apk` dosyasını WhatsApp / Google Drive / e-posta ile gönderin (WhatsApp bazen .apk'yı engeller; Drive bağlantısı daha kolaydır).
2. Alıcı telefonda dosyayı açınca "Bu kaynaktan yüklemeye izin ver" (bazı telefonlarda "Bilinmeyen kaynaklara izin ver") uyarısı çıkar. **Ayarlar**'a dokunup o uygulama (Drive/Tarayıcı/WhatsApp) için **izin verin**, geri dönüp **Yükle** deyin.
3. Google Play Protect "tanınmayan uygulama" diyebilir: **Yine de yükle**'yi seçin (uygulama henüz mağazada değil, bu normal).
4. Bu yöntem sadece test içindir. Herkese açık dağıtım için Google Play'i kullanın (`MAGAZA_METINLERI.md`, `KONTROL_LISTESI.md`).

## Sık karşılaşılan sorunlar

- **"Unable to locate Android SDK"**: Adım 3'teki `flutter config --android-sdk` yolunu kontrol edin.
- **"cmdline-tools component is missing"**: Adım 2'de Command-line Tools kutusunu işaretleyin.
- **`flutter devices` telefonu görmüyor**: kabloyu/portu değiştirin, telefonda USB modunu "Dosya aktarımı" yapın, USB hata ayıklamayı kapatıp açın.
- **Bilgisayar donuyor**: Android Studio'yu kapatın; komut satırından derlemek ondan daha az bellek kullanır.
- **Push bildirimi**: Bildirim özelliği eklendiğinde Android 13+ telefonlarda uygulama bildirim izni ister (`POST_NOTIFICATIONS` izni ilgili eklenti tarafından otomatik eklenir, elle eklemeyin).
