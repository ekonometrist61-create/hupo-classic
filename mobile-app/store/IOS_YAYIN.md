# iOS (App Store) - Dürüst Durum ve Yol Haritası

## Bilmeniz gerekenler

- iOS uygulaması **yalnızca Apple'ın araçlarıyla** derlenir. Windows bilgisayarda iOS derlemesi YAPILAMAZ. Seçenekler:
  1. **Mac + Xcode** (Mac App Store'dan ücretsiz Xcode). Gerçek bir Mac gerekir.
  2. **Bulut derleme (CI)**: ör. Codemagic, GitHub Actions macOS makineleri. Mac satın almadan derleme ve TestFlight'a yükleme yapılabilir; ücretsiz kotalar sınırlıdır, ücretli planlar olabilir (güncel fiyatlara bakın). Kurulumu bir geliştirici yapmalıdır.
- **Apple Developer Program** üyeliği gerekir: yıllık yaklaşık 99 USD (fiyat değişebilir). Test için TestFlight de bu üyelikle gelir. Kendi iPhone'unuza sadece kişisel deneme yüklemek ücretsiz Apple ID ile mümkündür ama 7 günde süresi dolar ve Mac ister.
- Bu depoda `ios/` projesi hazırdır: görünen ad "Öğrenci Hazırlık", bundle id `com.ogrencihazirlik.ogrenciHazirlik` (yayından önce karar verin: `KIMLIK_VE_HESAPLAR.md`), 1024 piksel simge (alfa kanalsız) ve mor açılış ekranı eklenmiştir. **Bu ayarlar Windows'ta derlenip denenemedi**; ilk Mac/CI derlemesinde Xcode'da "Signing & Capabilities" (Team seçimi) gerekir.

## Kids Category (Çocuklar kategorisi) kuralları - özet

Uygulamayı "Kids" olarak işaretlerseniz (yaş bandı 5 ve altı / 6-8 / 9-11 seçilir):
- Üçüncü taraf **reklam ve analiz SDK'sı YASAK** (bizde yok, ekleyecekseniz bu kategoriden çıkmak gerekir).
- Uygulamadan dışarı çıkan bağlantılar, satın alma ve ayarlar bölümü bir **ebeveyn kapısı (parental gate)** arkasında olmalıdır (ör. "bu sayıları topla" sorusu). Uygulamada dış bağlantı/satın alma eklenirse gerekli olur.
- Gizlilik politikası şart; çocuk verisi toplama beyanı net olmalıdır.
- Push bildirimi için üçüncü taraf (Firebase) kullanılıyorsa, Apple bu kategoride üçüncü taraf hizmetlerin çocukların kişisel verisini almasına sıkı bakar. Bu yüzden Kids kategorisine girmeden önce bildirim mimarisini ve gizlilik metnini birlikte kontrol edin. Kids kategorisi zorunlu DEĞİLDİR; "Eğitim" kategorisinde 4+ / 9+ yaş derecelendirmesiyle de yayınlanabilir (kuralları daha gevşektir, ama çocuk verisi yükümlülükleri yine geçerlidir).

## Adımlar (sırayla)

1. Apple Developer Program'a kaydolun (Apple ID + kimlik doğrulama; kurum için D-U-N-S).
2. App Store Connect'te yeni uygulama oluşturun (ad "Öğrenci Hazırlık", bundle id, dil Türkçe).
3. Mac veya bulut CI ile `flutter build ipa` alıp TestFlight'a yükleyin; birkaç iPhone'da test edin.
4. Bildirim kullanılacaksa: Xcode'da **Push Notifications** yeteneği ve APNs anahtarı (.p8) Firebase'e yüklenir (bildirim mühendisinin belgesine bakın).
5. Listeleme metinleri: `MAGAZA_METINLERI.md`'yi uyarlayın (App Store başlığı 30 karakter, alt başlık 30, tanıtım metni 170, açıklama 4000).
6. Gizlilik politikası URL'si + "App Privacy" formu (`VERI_GUVENLIGI_VE_GIZLILIK.md`).
7. Ekran görüntüleri: en az 6,7 inç (iPhone büyük) boyutu; gerçek cihaz veya simülatörden alınır.
8. **Hesap silme:** Apple, hesap oluşturulan uygulamalarda uygulama içinde hesap silmeyi şart koşar - bizde var (Ayarlar > Hesabımı sil).
9. İnceleme için test hesabı bilgilerini "App Review Information" alanına yazın.
10. İncelemeye gönderin (genelde 1-3 gün; reddedilirse gerekçesine göre düzeltilir).
