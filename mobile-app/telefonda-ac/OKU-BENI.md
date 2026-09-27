# Uygulamayı Telefonunuzda Açma (Çok Basit Anlatım)

> Not: "Expo Go" sadece başka türde (React Native) uygulamalarda çalışır. Bizim uygulama Flutter ile yapıldığı için
> Expo Go kullanılamaz. Onun yerine uygulamanın **web sürümünü** telefonunuzun tarayıcısında açıyoruz. Görünüm ve akış aynıdır.

## Ne lazım?
- Uygulamanın bulunduğu bilgisayar **açık** olmalı.
- Telefon ve bilgisayar **aynı Wi-Fi ağında** olmalı.

## 1) Bilgisayarda
1. `mobile-app` klasörünün içindeki **telefonda-ac** klasörünü açın.
2. **telefonda-ac.bat** dosyasına **çift tıklayın**.
3. Siyah bir pencere açılır. Yazılar akar; **ilk seferde 3-6 dakika** sürebilir. Bekleyin, pencereyi kapatmayın.
4. Sonunda şuna benzer bir kutu görürsünüz:

   `http://192.168.1.91:8080`

   (Sizde sayılar farklı olabilir. Ekranda ne yazıyorsa onu kullanın.)
5. Windows "Güvenlik Duvarı" sorarsa **"Özel ağlar" kutusunu işaretleyip "Erişime izin ver"** deyin.

Her seferinde uygulamanın **en son hâli** yeniden hazırlanır; güncel hâli görmek için bat dosyasını tekrar çalıştırmanız yeterli.

## 2) Telefonda
1. Telefonun tarayıcısını açın (Android: Chrome, iPhone: Safari).
2. Üstteki adres çubuğuna, siyah pencerede gördüğünüz adresi aynen yazın. Örnek: `http://192.168.1.91:8080`
   (`www` veya `https` yazmayın; `http://` ile başlasın.)
3. Uygulama açılır. İlk açılış birkaç saniye sürebilir.

## 3) Uygulama gibi tam ekran yapmak (isteğe bağlı)
**Android (Chrome):** sağ üstteki üç nokta (⋮) > **Ana ekrana ekle** (veya "Uygulamayı yükle") > Ekle.

**iPhone (Safari):** alttaki Paylaş simgesi (kare ve yukarı ok) > aşağı kaydırın > **Ana Ekrana Ekle** > Ekle.

Ana ekranda simge oluşur; dokununca adres çubuğu olmadan tam ekran açılır. (Bilgisayar açık ve bat çalışır durumda olmalı.)

## 4) Açılmazsa
1. **Aynı Wi-Fi mi?** Telefonda mobil veriyi kapatın, bilgisayarla aynı Wi-Fi'ye bağlanın. Misafir ağı ("guest") bazen cihazları birbirinden ayırır.
2. **VPN** açıksa (telefonda veya bilgisayarda) kapatın.
3. **Adres doğru mu?** Siyah penceredeki adresi harfi harfine yazdınız mı? Başında `http://` olsun, sonunda `:8080` olsun.
4. **Güvenlik Duvarı (isteğe bağlı çözüm):** Windows bağlantıyı engelliyor olabilir.
   - Başlat'a "Windows Defender Güvenlik Duvarı üzerinden bir uygulamaya izin ver" yazın > **Ayarları değiştir** > listede **Dart** veya **flutter** varsa **Özel** kutusunu işaretleyin.
   - Ya da Başlat'a `cmd` yazın > sağ tık > **Yönetici olarak çalıştır** > şunu yapıştırın:
     `netsh advfirewall firewall add rule name="Telefonda Ac 8080" dir=in action=allow protocol=TCP localport=8080 profile=private`
   - Wi-Fi'niz "Genel" olarak işaretliyse, Ayarlar > Ağ ve İnternet > Wi-Fi > ağınıza tıklayıp **Özel** yapın.
5. Bilgisayarın IP adresi değişmiş olabilir; bat dosyasını kapatıp yeniden çalıştırın ve yeni adresi kullanın.

## 5) Durdurmak
Siyah pencereyi kapatın (veya içinde **Ctrl + C** tuşlarına basın). Bitti.

## Dürüst sınırlar
- Bu, mağazadaki gerçek uygulama değil, **web önizlemesidir**. Görünüm ve akış büyük ölçüde aynıdır.
- Titreşim (haptik), bildirimler ve bazı cihaz özellikleri telefonda gerçek uygulamadan farklı davranabilir veya çalışmayabilir.
- Bilgisayar açık ve bat çalışır olmalı; ev/ofis Wi-Fi'si dışında çalışmaz.
- Yalnızca `http` ile açıldığı için bazı tarayıcı özellikleri (ör. kamera, bildirim izni) kısıtlı olabilir.

## Android APK (gerçek uygulama dosyası)
Şu an **mümkün değil**: bu bilgisayarda Android SDK (Android Studio) kurulu değil. APK üretmek için Android Studio + Android SDK kurulumu gerekir
(sonra `flutter build apk` ile üretilir). iPhone için ise Mac ve Apple Developer hesabı gerekir. İstenirse ayrıca planlanabilir.
