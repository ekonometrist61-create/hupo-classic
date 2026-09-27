# store/ - Mağazaya Çıkış Paketi

| Dosya | Ne işe yarar |
|---|---|
| `ANDROID_KURULUM.md` | Android Studio kurulumu, telefona kurma, APK/AAB üretme (sıfırdan) |
| `KIMLIK_VE_HESAPLAR.md` | Uygulama kimliği, hesaplar ve ücretler, imza anahtarı |
| `anahtar-olustur.bat` | İmza anahtarını (keystore) adım adım oluşturur |
| `MAGAZA_METINLERI.md` | Google Play başlık/açıklama, kategori, içerik derecelendirme |
| `VERI_GUVENLIGI_VE_GIZLILIK.md` | Data Safety yanıtları, gizlilik politikası URL şartı |
| `IOS_YAYIN.md` | App Store yol haritası (Mac/CI, Kids kuralları) |
| `KONTROL_LISTESI.md` | Yayın kontrol listesi ve ekran görüntüsü planı |
| `icon-kaynak/` | İkon kaynak PNG'leri ve üreten betik (`uret.js`, sharp gerekir) |

İkonlar `assets/hupo/ayakta.png` görselinden, uygulama moru `#6C4DF6` (`AppColors.primary`) zemin üzerine üretilir. İkonu değiştirmek için `uret.js`'i çalıştırın: `node store/icon-kaynak/uret.js` (Android `res/mipmap-*` ve iOS `AppIcon.appiconset` dosyalarını da yeniler).
