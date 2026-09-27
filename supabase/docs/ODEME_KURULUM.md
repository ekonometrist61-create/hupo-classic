# Kartlı Ödeme Kurulumu (iyzico) - Yeni Başlayanlar İçin

Bu belge, veli web panelinden kartla abonelik satın almayı çalıştırmak için gereken her şeyi
sırayla anlatır. Hiçbir şey bilmiyorsanız bile adım adım gidebilirsiniz.

> **Önemli:** Bu belge hukuki veya mali tavsiye DEĞİLDİR. "Hukuki notlar" bölümündeki maddeler
> bir hatırlatma listesidir; hiçbirinin "yeterli" olduğu iddia edilmez. Mutlaka bir avukat ve
> mali müşavirle doğrulayın.

## 1. iyzico nedir, nasıl çalışır?

iyzico, Türkiye'de internetten kartla ödeme almanızı sağlayan lisanslı bir ödeme kuruluşudur.
Biz "Checkout Form" yöntemini kullanıyoruz:

1. Veli panelde "Satın al"a basar.
2. Sunucumuz (Edge Function `payments-checkout`) iyzico'ya "şu tutarda ödeme başlat" der.
3. Veli iyzico'nun kendi sayfasına gider ve kartını **orada** girer. Kart bilgisi bizim
   sunucumuza, veritabanımıza veya kayıtlarımıza HİÇ uğramaz (PCI yükümlülüğümüz asgaridir).
4. Ödeme bitince iyzico veliyi `payments-callback` adresine geri gönderir. Bu fonksiyon,
   tarayıcıdan gelene GÜVENMEZ; sonucu iyzico'ya kendisi sorar, tutarı kontrol eder, sonra
   aboneliği açar ve veliyi panele geri yönlendirir.

Abonelik tek seferliktir (ör. 30 gün). Otomatik yenileme yoktur; süre bitince veli yeniden satın alır.
Satın alma yalnızca veli panelinde yapılır; çocuk uygulamasında satın alma yoktur.

## 2. Müşterinin (işletme sahibinin) hazırlaması gerekenler

Canlı (gerçek para) hesap için iyzico bir **işletme** ister. Ayrıntılı ve güncel liste iyzico'nun
başvuru sayfasındadır; genel olarak şunlar gerekir:

- Kayıtlı bir işletme: **şahıs işletmesi** veya **limited/anonim şirket**
- Vergi numarası ve vergi levhası
- İşletme adına açılmış banka hesabı (IBAN) - iyzico paranızı buraya aktarır
- Yetkilinin kimlik belgesi, imza sirküleri/yetki belgesi (şirketse), gerekiyorsa faaliyet belgesi
- Çalışan bir internet sitesi (alan adı) üzerinde: iletişim bilgileri, gizlilik/KVKK metni,
  mesafeli satış sözleşmesi, iade/cayma bilgileri

Başvurunun onaylanması günler sürebilir. **Beklemeden** test için ücretsiz "sandbox" hesabı açılır
(sonraki bölüm); tüm geliştirme ve deneme onunla yapılır. Gerçek para yalnızca canlı hesapta akar.

## 3. Sandbox (deneme) anahtarlarını alma

1. https://sandbox-merchant.iyzipay.com adresine gidin, "Kayıt ol" ile ücretsiz hesap açın.
2. Giriş yapın; **Ayarlar > Firma Ayarları** (menü adı zamanla değişebilir) bölümünde
   **API Anahtarı** ve **Gizli Anahtar** görünür.
3. İkisini bir yere **güvenli** not alın. Gizli anahtarı kimseye göndermeyin, koda veya
   GitHub'a yazmayın, sohbetlere yapıştırmayın.

## 4. Anahtarları Supabase'e tanıtma

Terminalde (Supabase CLI kurulu ve `supabase login` yapılmış olmalı; proje klasöründesiniz):

```
supabase secrets set IYZICO_API_KEY=buraya_api_anahtari
supabase secrets set IYZICO_SECRET_KEY=buraya_gizli_anahtar
supabase secrets set IYZICO_BASE_URL=https://sandbox-api.iyzipay.com
supabase secrets set WEB_PANEL_URL=https://veli-paneliniz.ornek.com
```

- `WEB_PANEL_URL`: veli panelinin adresi (sonunda `/` olmasın). Ödeme sonrası veli buraya döner
  ve tarayıcı erişim izni (CORS) yalnızca bu adrese verilir.
- `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` Supabase tarafından kendiliğinden eklenir.
- `IYZICO_BASE_URL` verilmezse zaten sandbox kullanılır.

## 5. Veritabanı göçünü uygulama

`supabase/migrations/20260920001100_payments_iyzico.sql` dosyasını, diğer göçlerle aynı şekilde
uygulayın (`supabase db push` veya SQL Editor'e yapıştırıp Run). Bu göç ödeme tablolarına
alan ekler, `app_settings` tablosunu ve satın alma fonksiyonlarını oluşturur.
İki örnek plan (`aylik`, `yillik`) **satışa kapalı** olarak eklenir: admin panelinden
fiyatı girip "aktif" yapana kadar kimse satın alamaz.

## 6. İki fonksiyonu yayınlama

```
supabase functions deploy payments-checkout
supabase functions deploy payments-callback --no-verify-jwt
```

- `payments-checkout` **JWT doğrulaması AÇIK** kalır (bayrak eklemeyin): yalnızca giriş yapmış
  kullanıcı çağırabilir, ayrıca fonksiyon içinde "bu kişi veli mi?" diye ayrıca kontrol edilir.
- `payments-callback` **`--no-verify-jwt`** ile yayınlanır, çünkü iyzico'dan dönen tarayıcı
  yönlendirmesinde giriş belgesi (JWT) YOKTUR. Bu güvenlidir: fonksiyon tarayıcıdan gelen hiçbir
  bilgiye güvenmez; token'ı ödeme kaydında sakladığımız token ile eşleştirir ve sonucu iyzico'ya
  sunucudan sorar.

## 7. Uçtan uca deneme (sandbox)

1. Admin panelinde bir planı (ör. `aylik`) fiyatla ve **aktif** yapın (ör. 149,90 TL = 14990 kuruş).
2. Bir veli hesabıyla veli paneline girip planı seçin, "Satın al"a basın.
3. iyzico'nun sandbox ödeme sayfası açılır. Test kartı girin (aşağıda).
4. Ödeme sonrası `.../veli-paneli/abonelik?odeme=basarili&id=...` adresine dönmelisiniz.
5. Kontrol: Admin panelinde Ödemeler'de kayıt "basarili"; veli panelinde abonelik ve bitiş
   tarihi görünür; çocuğun hesabında da premium görünür (kaynak: veli).
6. Aynı adresi yenileyin: hiçbir şey ikinci kez işlenmemeli (abonelik tek kalır).
7. Başarısız kart ile deneyip `odeme=basarisiz` döndüğünü doğrulayın.

**Test kartları:** iyzico'nun güncel "test kartları" listesi kendi dokümanındadır
(docs.iyzico.com, "Test Cards" araması). Yaygın bilinenler (hafızadan, **sizin doğrulamanız gerekir**):
başarılı kart `5528 7900 0000 0008`, son kullanma tarihi gelecekte herhangi bir ay/yıl (ör. 12/2030),
CVC `123`; 3D Secure şifresi sandbox'ta `283126` sorulursa onu deneyin. Hatalı kart örnekleri
iyzico listesinde hata nedenine göre ayrıdır. Bu sayfalar taşınmış olabilir; bulamazsanız sandbox
panelindeki yardım bölümüne bakın.

## 8. "Yer tutucu alanlar" ve kimlik numarası (dürüst not)

iyzico'nun başlatma isteği alıcı için `identityNumber` (T.C. kimlik no), telefon ve adres alanlarını
**zorunlu** sayar. Biz bu bilgileri veliden **toplamıyoruz** (gereksiz kişisel veri = KVKK yükü).
Bu yüzden istekte sabit yer tutucular gönderiyoruz: kimlik `11111111111`, telefon `+905350000000`,
adres "Türkiye (dijital ürün, teslimat yok)". Ad, soyad ve e-posta gerçek profilden alınır.

- iyzico'nun dokümanı yer tutucu için özel bir kural yazmıyor. **Sandbox'ta** böyle değerler
  genellikle kabul edilir, ancak bunu kendi sandbox denemenizle doğrulayın.
- **Canlıda** iyzico/bankaların sahtekarlık kontrolü yer tutucu kimlikleri reddedebilir veya
  ek doğrulama isteyebilir. Canlıya geçmeden iyzico destek/satış temsilcinize "dijital abonelikte
  gerçek TCKN toplamadan yer tutucu kullanabilir miyiz?" diye **yazılı** sorun. Cevap "hayır" ise
  veliden kimlik numarası (ve açık rıza/aydınlatma) toplayan bir alan eklemek gerekir; bu, KVKK
  metinlerini de değiştirir.
- IP adresi isteğin `x-forwarded-for` başlığından alınır; alınamazsa iyzico'nun örneğindeki
  sabit bir IP kullanılır.
- Taksit kapalıdır (tek çekim): taksit faizi ödenen tutarı değiştirip doğrulamayı bozacağı için.

## 9. Canlıya geçiş listesi

1. iyzico canlı hesabınız onaylandı ve canlı API/Gizli anahtarlarını aldınız.
2. `supabase secrets set IYZICO_API_KEY=...` ve `IYZICO_SECRET_KEY=...` ile **canlı** anahtarları yazın.
3. `supabase secrets set IYZICO_BASE_URL=https://api.iyzipay.com`
4. `WEB_PANEL_URL` canlı panel adresi olmalı (https).
5. İki fonksiyonu yeniden yayınlayın (bölüm 6) - secret değişince de yeniden yayın önerilir.
6. Küçük tutarlı gerçek bir ödeme yapıp iyzico panelinde görün, sonra iade edin ve admin ekranında
   durumu "iade" yapın (bölüm 10).
7. Hukuki metinler yayında ve ödeme öncesi onaylatılıyor (bölüm 11).
8. Plan fiyatlarını admin panelinden girip planları aktif edin. Ücretli özellik kısıtı
   (`premium_gating`) varsayılan **kapalıdır**; sınırsız/ücretsiz kota ayarını yalnızca hazır
   olunca açın (admin, `admin_set_setting('premium_gating', '{"aktif": true, "ucretsiz_gunluk_soru": 20}')`).
9. Yedek/uyarı: Supabase Edge Function günlüklerini (Logs) ilk günlerde izleyin.

## 10. İadeler

Para iadesini **iyzico yönetim panelinden** yaparsınız (sistemimiz iyzico'ya iade komutu göndermez).
Ardından admin ekranında ilgili ödemenin durumunu **"iade"** yapın; bağlı abonelik otomatik iptal edilir.
Ödeme "TUTAR_UYUSMAZLIGI" notuyla başarısız görünüyorsa: iyzico'da para çekilmiş olabilir;
iyzico panelinde kontrol edip gerekirse iade edin.

## 11. Hukuki / vergi hatırlatmaları (tavsiye değildir)

Şunları bir avukat ve mali müşavirle mutlaka netleştirin; burada hiçbirinin yeterli olduğu iddia edilmez:

- **Mesafeli Satış Sözleşmesi ve Ön Bilgilendirme Formu:** Tüketiciye internetten satışta
  ödemeden önce sunulmalı ve onayı kayıt altına alınmalıdır. Bu kodda onay ekranı/kaydı henüz yoktur;
  veli panelinde satın almadan önce gösterilmelidir.
- **Cayma hakkı:** Tüketicinin genelde 14 gün cayma hakkı vardır. Dijital içerikte, tüketicinin
  **açık onayıyla** ifa başlamışsa cayma hakkının kalkabildiği istisna vardır; bu onay ayrıca ve
  açıkça alınmalıdır. Uygulamanın nasıl bir hizmet sayıldığı hukuki değerlendirme ister.
- **e-Arşiv / e-Fatura:** Satış için fatura düzenleme yükümlülüğünüz olabilir (işletme türüne ve
  cirosuna göre e-fatura/e-arşiv mükellefiyeti). Ödeme kaydı tutulur ama fatura kesmez.
- **KVKK:** Ödeme verisi işleme (velinin adı, e-postası, işlem kayıtları) aydınlatma metninde ve
  veri envanterinde yer almalıdır. iyzico ayrıca kendi başına veri sorumlusu/işleyicisidir.
  Biz kart numarası, CVC veya son kullanma tarihi almaz ve saklamayız; ödeme kaydına yalnızca
  beyaz listeli alanlar (durum, ödeme no, tutar) yazılır.
- **Mağaza kuralları:** Apple ve Google, mobil uygulamanın **içinde** satılan dijital içerik için
  genellikle kendi uygulama içi satın alma sistemlerini zorunlu tutar. Bu yüzden satın alma yalnızca
  veli web panelinde yapılır ve çocuk uygulaması satın alma sayfasına **yönlendirmez/link vermez**.
  Bu, güncel mağaza politikalarıyla **sizin doğrulamanız gereken** bir rehberdir; kurallar ve
  istisnalar (ör. "reader" uygulamaları, bölgesel düzenlemeler) değişebilir.
- Çocuk verisi ve ödeme: satın alan her zaman velidir; çocuk hesapları ödeme kaydını göremez.

## 12. Sorun giderme

| Belirti | Olası neden |
|---|---|
| "Ödeme yapılandırılmamış" | `IYZICO_API_KEY`/`IYZICO_SECRET_KEY` secret'ları yok |
| "Ödeme sayfası açılamadı" (502) | Yanlış anahtar/adres; Supabase Logs'ta `iyzico init başarısız` + hata kodu |
| Ödeme sonrası `odeme=basarisiz` ama para çekilmiş | iyzico panelinde ödemeyi bulun; Logs'ta `callback işlenmedi` |
| Tarayıcıda CORS hatası | `WEB_PANEL_URL` panelin adresiyle bire bir aynı değil |
| Callback 401 | `payments-callback` `--no-verify-jwt` olmadan yayınlanmış |

## 13. Teknik özet (geliştiriciler için)

- `payment_create_pending / payment_set_token / payment_get / payment_complete / payment_fail`
  yalnızca `service_role` içindir (istemci çağıramaz).
- `payment_complete` idempotenttir: ödenen tutar = plan fiyatı değilse ödeme başarısız işaretlenir
  ve abonelik açılmaz; aynı plan tekrar alınırsa süre mevcut bitişten uzar.
- Öğrenci kotası: `premium_gating.aktif=true` iken günlük ücretsiz soru dolunca `submit_answer`
  yeni cevap kaydı `P0402` ("Günlük ücretsiz soru hakkın doldu") hatasıyla reddedilir
  (tetikleyici `user_answers_enforce_quota`). Flutter tarafı `my_quiz_quota()` ve
  `my_subscription_status()` RPC'lerini gösterim için kullanır. Varsayılan KAPALI.
- Doğrulanmamış nokta: iyzico'ya gerçek çağrı bu ortamda anahtar olmadığı için denenmemiştir;
  ilk sandbox denemeniz bu doğrulamadır.
