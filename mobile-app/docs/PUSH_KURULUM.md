# Push Bildirimi Kurulumu (Sıfırdan, Adım Adım)

Bu rehber hiç bilmeyen biri için yazıldı. Sırayla git, atlama. Her adımın sonunda
"Oldu mu?" diye kontrol edebileceğin bir şey var.

> **Önce kısa özet.** Uygulama zaten push'a hazır. Eksik olan tek şey senin
> Firebase hesabın ve birkaç gizli anahtar. Bunlar olmadan uygulama normal çalışır;
> sadece Ayarlar'daki "Bildirimler" anahtarı "henüz kullanılamıyor" der.

## Nasıl çalışıyor? (30 saniyede)

1. Çocuk Ayarlar'dan **Bildirimler**'i açar (velisi daha önce onay vermişse).
2. Telefon, Firebase'den bir "adres" (jeton) alır; uygulama bunu Supabase'e kaydeder.
3. Uygulamada yeni bir bildirim oluşunca (rozet, seviye, günlük hedef...) Supabase
   `push_outbox` tablosuna bir satır yazar.
4. Bir **Database Webhook** bu satırı görür ve `send-push` fonksiyonunu çağırır.
5. Fonksiyon, Firebase üzerinden telefona bildirimi yollar.

Güvenlik kuralları (kodda zaten var, senin yapman gereken bir şey yok):

* Bildirimler **varsayılan olarak kapalı**dır.
* Çocuk hesabı için **velinin onayı** olmadan açılamaz. Veli onayı geri çekerse durur.
* **20:00 - 08:00 arası** (İstanbul saati) bildirim gönderilmez.
* Bildirimde ad, soyad gibi kişisel bilgi yoktur; sadece "Yeni rozet kazandın!" gibi metinler.
* Gizli anahtarlar koda yazılmaz, Supabase'in gizli alanında saklanır.

---

## ADIM 1. Veritabanı güncellemesini çalıştır

1. https://supabase.com adresinden projene gir.
2. Sol menüden **SQL Editor**'ü aç. **New query**'ye tıkla.
3. Bilgisayarında şu dosyayı aç, içindekilerin **tamamını** kopyala:
   `supabase/migrations/20260920001000_push_notifications.sql`
4. SQL Editor'e yapıştır ve **Run**'a bas.
5. **Oldu mu?** "Success" yazmalı. Sol menüden **Table Editor**'e gir; listede
   `device_tokens`, `push_preferences` ve `push_outbox` tablolarını görmelisin.

(İstersen kontrol için `supabase/tests/push_tests.sql` dosyasını aynı şekilde yapıştırıp
çalıştır; tüm satırlarda `gecti` sütunu `true` olmalı. Test hiçbir kayıt bırakmaz.)

## ADIM 2. Firebase projesi oluştur

1. https://console.firebase.google.com adresine git, Google hesabınla giriş yap.
2. **Proje oluştur** (Create a project) tıkla. Bir ad yaz (örn. `hupo-app`). Devam et.
3. "Google Analytics" sorusunda **kapatabilirsin** (gerekmez). **Proje oluştur**'a bas.
4. **Oldu mu?** Projenin ana sayfası açılmalı.

## ADIM 3. Android uygulamasını Firebase'e ekle

1. Firebase ana sayfasında, ortadaki **Android simgesine** (küçük yeşil robot) tıkla.
2. **Android paket adı** kutusuna uygulamanın paket adını yazacaksın. Bunu şuradan oku:
   `mobile-app/android/app/build.gradle.kts` dosyasını aç, `applicationId = "..."`
   satırındaki tırnak içindeki metni aynen kopyala.
   **Önemli:** Bu ad mağaza hazırlığı sırasında değişmiş olabilir. Her zaman dosyada
   **o an** ne yazıyorsa onu kullan. (Şu an: `com.ogrencihazirlik.ogrenci_hazirlik`.)
   Sonradan değişirse Firebase'e yeni bir Android uygulaması eklemen gerekir.
3. Takma ad boş kalabilir. **Uygulamayı kaydet**'e bas.
4. **`google-services.json` dosyasını indir** düğmesine bas. Dosyayı şuraya koy:
   `mobile-app/android/app/google-services.json`
   (Bu dosyayı Git'e/başkalarına gönderme; sadece senin bilgisayarında dursun.)
5. Sonraki ekranlarda (Firebase SDK ekleme) **hiçbir şey yapma**, "İleri" ve
   "Konsola devam et" de. Uygulama kodu Firebase'i zaten kendisi başlatıyor.

### 3b. Uygulamaya dört değeri ver

Az önce indirdiğin `google-services.json` dosyasını Not Defteri ile aç. İçinde şu
dört bilgi var; hepsini bir kenara yaz:

| Bizim ad | JSON içinde nerede |
|---|---|
| `FIREBASE_API_KEY` | `client` > `api_key` > `current_key` |
| `FIREBASE_APP_ID` | `client` > `client_info` > `mobilesdk_app_id` |
| `FIREBASE_PROJECT_ID` | `project_info` > `project_id` |
| `FIREBASE_MESSAGING_SENDER_ID` | `project_info` > `project_number` |

Uygulamayı çalıştırırken bu dört değeri şöyle verirsin (tek satır, kendi değerlerinle):

```
flutter run --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... --dart-define=FIREBASE_PROJECT_ID=... --dart-define=FIREBASE_MESSAGING_SENDER_ID=...
```

Mağaza sürümü (`flutter build appbundle`) alırken de aynı dört `--dart-define` eklenir.
Dört değerden biri eksikse push otomatik kapalı kalır, uygulama çökmez.

## ADIM 4. Firebase servis hesabı anahtarını al (gizli!)

Bu dosya, sunucunun senin adına bildirim göndermesini sağlar. **Şifre gibidir.**
Kimseyle paylaşma, sohbete yapıştırma, Git'e koyma.

1. Firebase'de sol üstte dişli simgesi > **Proje ayarları**.
2. **Hizmet hesapları** (Service accounts) sekmesi.
3. **Yeni özel anahtar oluştur** (Generate new private key) > **Anahtar oluştur**.
4. Bir `.json` dosyası iner. Güvenli bir yerde sakla (masaüstüne bırakma).
5. Aynı ekranda `Cloud Messaging API (V1)` etkin olmalı. Değilse Firebase
   **Proje ayarları > Cloud Messaging** sekmesinden etkinleştir.

## ADIM 5. Gizli anahtarları Supabase'e kaydet

İki gizli değer saklayacağız:

* `FIREBASE_SERVICE_ACCOUNT` = Adım 4'te inen JSON dosyasının **tüm içeriği**
* `PUSH_WEBHOOK_SECRET` = Senin uydurduğun uzun rastgele bir metin (en az 32 karakter).
  Bunu sadece webhook ile fonksiyon bilecek. Örnek üretmek için tarayıcıda
  bir "parola oluşturucu" kullanabilirsin.

**Yol A: Panelden (en kolayı)**

1. Supabase'de **Edge Functions** > **Secrets** (veya Project Settings > Edge Functions).
2. **Add new secret** ile önce `PUSH_WEBHOOK_SECRET`, sonra `FIREBASE_SERVICE_ACCOUNT`
   ekle. İkincisinin değerine JSON dosyasını Not Defteri'nde açıp tüm metni yapıştır.

**Yol B: Komut satırından (Supabase CLI kuruluysa)**

```
supabase secrets set PUSH_WEBHOOK_SECRET=buraya-uzun-rastgele-metin
supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat indirdigin-dosya.json)"
```

**Oldu mu?** Secrets listesinde iki ismi görürsün (değerler gizli görünür).

## ADIM 6. `send-push` fonksiyonunu yayınla

**Yol A: Supabase CLI ile**

1. CLI'yi kur: https://supabase.com/docs/guides/cli
2. Terminalde projenin `supabase` klasörünün bir üstüne gel ve giriş yap:
   ```
   supabase login
   supabase link --project-ref PROJE_REF_KODUN
   ```
3. Yayınla. Bu fonksiyonu **Supabase JWT'siz** çağıracağız (webhook kendi gizli
   başlığıyla doğrulanır), bu yüzden `--no-verify-jwt` gerekir:
   ```
   supabase functions deploy send-push --no-verify-jwt
   ```

**Yol B: Panelden**

1. **Edge Functions** > **Deploy a new function** > **Via Editor**. Ad: `send-push`.
2. `supabase/functions/send-push/index.ts` içeriğini editöre yapıştır. Aynı işlevde
   `logic.ts` dosyasını da ekle (aynı adla, aynı içerikle).
3. Fonksiyon ayarlarında **"Verify JWT"** seçeneğini **kapat**. Deploy et.

**Oldu mu?** Edge Functions listesinde `send-push` görünür. Adresi şuna benzer:
`https://PROJE_REF.supabase.co/functions/v1/send-push`

## ADIM 7. Database Webhook'u oluştur

Bu, "tabloya yeni satır düşünce fonksiyonu çağır" bağlantısıdır.

1. Supabase'de **Database** > **Webhooks** > **Create a new hook**.
2. Ad: `push_outbox_send`
3. **Table**: `push_outbox`
4. **Events**: sadece **Insert** işaretli olsun.
5. **Type of hook**: HTTP Request. **Method**: POST.
6. **URL**: Adım 6'daki adres (`https://PROJE_REF.supabase.co/functions/v1/send-push`).
7. **HTTP Headers**: `Content-Type: application/json` kalsın; **yeni başlık ekle**:
   * Ad: `x-webhook-secret`
   * Değer: Adım 5'te yazdığın `PUSH_WEBHOOK_SECRET` ile **aynı** metin.
8. **Create webhook**.

## ADIM 8. Telefonda dene

1. Telefonu USB ile bağla ve Adım 3b'deki `--dart-define` değerleriyle uygulamayı çalıştır.
2. Bir **veli** hesabıyla ve bir **çocuk** hesabıyla giriş yapabilecek şekilde hazırlan.
   Çocuk hesabı, velisine bağlı olmalı ve veli, uygulamadaki gizlilik ekranından
   çocuğu için **açık rıza** vermiş olmalı.
3. Çocuk hesabında **Ayarlar > Bildirimler** anahtarını aç. Açıklama penceresinde
   "Evet, aç"a bas, telefon izin sorarsa **İzin ver**.
4. Supabase **SQL Editor**'de kendine bir deneme bildirimi ekle. `ÇOCUĞUN_ID` yerine
   çocuğun kullanıcı kimliğini (Authentication > Users listesindeki `UID`) yaz:

   ```sql
   insert into public.notifications (alici_id, tur, baslik, mesaj)
   values ('ÇOCUĞUN_ID', 'bilgi', 'Merhaba!', 'Deneme bildirimi: harika gidiyorsun.');
   ```

5. Telefon kilitliyken birkaç saniye içinde bildirim gelmeli.
   **Not:** Saat 20:00 - 08:00 arasındaysa bildirim bilerek gönderilmez. Denemeyi gündüz yap.
6. Nasıl gitti bakmak için:
   ```sql
   select status, last_error, created_at from public.push_outbox order by created_at desc limit 5;
   ```
   * `sent`: gönderildi.
   * `skipped`: gönderilecek uygun cihaz/izin yoktu (rıza yok, tercih kapalı, sessiz saat...).
   * `failed`: hata; `last_error` sütununa bak. Edge Functions > send-push > **Logs** da yardımcı olur.

### Bildirim gelmezse kontrol listesi

* `push_outbox` tablosunda satır oluştu mu? Oluşmadıysa: tercih kapalı, veli rızası yok
  veya saat sessiz saat aralığında demektir.
* Satır var ama `pending`'te kaldıysa: Webhook (Adım 7) ya da adres/başlık yanlış.
* `failed` + `OAuth`: `FIREBASE_SERVICE_ACCOUNT` yanlış yapıştırılmış olabilir.
* Android 13 ve üstü: uygulamanın bildirim izni verilmiş olmalı (Ayarlar'da açarken sorulur).

## iOS (iPhone) için: sonraki adım

iPhone'larda push için **ücretli Apple Developer hesabı** ve bir **APNs anahtarı** gerekir
(Firebase > Proje ayarları > Cloud Messaging > Apple uygulama yapılandırması bölümüne
yüklenir), ayrıca Xcode'da "Push Notifications" yeteneği eklenir. Bu adımlar henüz
yapılmadı ve bu rehberin kapsamı dışında. Uygulama kodu iOS için de hazır; ama gerçek
iPhone'da denenmedi. Android çalıştıktan sonra ayrı bir iş olarak ele alınmalı.

## Güvenlik hatırlatmaları

* `FIREBASE_SERVICE_ACCOUNT` JSON'unu ve `PUSH_WEBHOOK_SECRET`'i asla koda, Git'e,
  sohbete veya ekran görüntüsüne koyma. Sızdıysa Firebase'de anahtarı sil, yenisini üret.
* `google-services.json` gizli değildir ama projeye özeldir; Git'e koymamayı tercih et.
* Bildirim metinleri cesaretlendirici olmalı; suçluluk hissettiren ifadeler
  (örn. "Hupo üzülüyor") kullanılmaz. Bildirim metinleri veritabanındaki
  `notifications` kayıtlarından gelir.
