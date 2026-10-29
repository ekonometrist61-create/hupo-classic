# Veli ödeme/paket ekranı: A ve C metin ve tasarım taslağı

- **Tarih:** 2026-10-28
- **Durum:** TASLAK. Yayınlanmadı. Kod, veritabanı, ayar ve fiyat değiştirilmedi. Son onay: proje sahibi.
- **Dayanak:** I4 karar kaydı (`docs/growth-crm/GIE_ANALIZ_VE_IS_PLANI_2026-10-28.md` §33). İlk test sunum testidir, fiyat değişmez. Birincil hipotez: 7 gün içinde ücretli ödeme oranı.
- **Okunan kaynaklar:** `web-panel/src/components/veli-paneli/PlanKarti.tsx`, `MembershipView.tsx`; `supabase/migrations/20261018010000_deneme_suresi.sql`, `20261025000200_plan_deneme_gun.sql`, `20260920001100_payments_iyzico.sql` (`payment_create_pending`), `20261038000000_pazarlama_push_kapisi_ve_olcum.sql`; `docs/growth-crm/specs/AB_MOTORU_SPEC.md`; `docs/hupo-design-growth/decisions.md`, `BRAND_AND_VISUAL_RULES.md`.

---

## 0. Yayını durduran üç bulgu

Bu üç madde çözülmeden A ve C metinleri yayınlanamaz. Aşağıdaki metinler bu yüzden **koşullu** işaretlidir.

1. **Ücretsiz deneme veliye kendiliğinden açılmıyor.** Deneme kaydını yalnız yönetici açar (`admin_deneme_baslat`). Ödeme akışında (`payment_create_pending`) deneme mantığı yok; veli "Satın al" dediğinde ödeme hemen `beklemede` olarak yazılır. Bugünkü kodla "14 gün ücretsiz dene" cümlesi doğru olmaz. Deneme elle açıldığı için (proje hafızasında 20–30 kişi notu var) A da C de için örneklem yetersiz kalır.
2. **Kontrol ekranındaki deneme satırı kaynaksız olabilir.** `PlanKarti`, her plan için `plans.deneme_gun` değerini "N gün ücretsiz deneme" diye gösterir. Bu alan yalnız görüntülenir; ödeme akışı uygulamaz. Canlı değer 0'dan büyükse kontrol kolu bugün de yanıltıcıdır. Bu oturumda veritabanına erişim yoktu; kontrol yapılmadı.
3. **Deneme bitince ne olacağı tanımlı değil.** Yenileme koşulu veride yok (`decisions.md`, 2026-10-16: gösterim "bilinmiyor"). Ücret alınıp alınmayacağı ve erişimin nasıl biteceği hukuk ve ürün kararıdır.

Ek: iyzico sandbox üzerinden uçtan uca ödeme hiç test edilmedi (`decisions.md`, 2026-10-09).

---

## 1. Kapsam ve sabit kurallar

- **Yüzey:** veli web paneli, üyelik ve paket ekranı (`MembershipView` → `PlanKarti`). Çocuk uygulaması ve çocuk kota diyaloğu test dışıdır; metinleri değişmez.
- **Kontrol kolu:** bugünkü `PlanKarti` aynen kalır.
- **Fiyat ve paket:** iki kolda da aynıdır. Fiyat `plans` tablosundan gelir; metne rakam yazılmaz (`{fiyat}` değişkeni). Aynı veliye iki farklı fiyat gösterilmez.
- **Atama:** veli (hane) düzeyinde, bir kez. Çocuk hesabı ayrı kol almaz. Çocuk yüzeyinde satın alma metni yoktur.
- **Dil:** veliye "siz" hitabı. "Deneme" tek başına kullanılmaz; "ücretsiz deneme" yazılır, çünkü veli panelinde "Deneme sınavları" ayrı bir özelliktir.
- **Değişkenler** (hepsi sunucudan gelir; metinde sabit sayı yoktur):
  - `{gun}`: `app_settings.deneme.gun` (varsayılan 14)
  - `{gunluk_soru}`: `app_settings.deneme.gunluk_soru` (varsayılan 20)
  - `{bitis_tarih}`, `{kalan_gun}`: `my_deneme_durumu()`
  - `{bugun_plus_gun}`: sunucuda hesaplanır, Europe/Istanbul
  - `{fiyat}`, `{plan_ad}`: `list_active_plans()`
  - `{veli_ad}`, `{veli_panel_url}`, `{tercih_url}`: e-posta şablonu

---

## 2. Varyant A: deneme vurgusu

### 2.1 Ekran metinleri

| Öğe | Metin | Kaynak ve koşul |
|---|---|---|
| Başlık (ana) | Çocuğunuz için {gun} gün ücretsiz deneyin | Deneme KARAR-1 ile açıldığında |
| Alt metin | Önce deneyin, sonra devam edip etmemeye karar verin. Fiyatlar aşağıda açıkça yazılı. | Sabit |
| Deneme bitişi (deneme aktif) | Deneme bitiş tarihi: {bitis_tarih} (kalan {kalan_gun} gün) | `my_deneme_durumu`. Veri yoksa satır gösterilmez. |
| Deneme bitişi (deneme yok) | Denemeyi bugün başlatırsanız bitiş tarihi: {bugun_plus_gun} | Başlatıldıktan sonra gerçek tarih gösterilir |
| Kota satırı | Deneme süresince çocuğunuz günde en fazla {gunluk_soru} soru çözebilir. | Sayı onaylanmadıysa gösterilmez (Açık soru 5) |
| Koşul satırı (CTA'nın hemen üstü) | KARAR-3 seçeneklerinden biri (aşağıya bakın) | Zorunlu |
| Ana CTA | Ücretsiz denemeyi başlat | Yalnız kartsız deneme gerçekten çalışıyorsa. Aksi halde CTA "Planı seç" olarak kalır ve bu bir A varyantı sayılmaz. |
| İkincil | Planları karşılaştır | Plan kartlarına kaydırır |

**Koşul satırı (KARAR-3 bekliyor; ikisi de hukuk ve ürün onayı olmadan yayınlanmaz):**
- Seçenek a: "Deneme bitince sizden otomatik ücret alınmaz; devam etmek isterseniz planı kendiniz seçersiniz."
- Seçenek b: "Deneme bitince {bitis_tarih} itibarıyla ücretsiz plana geçilir; planı seçerseniz ödeme ekranında tutarı onaylarsınız."

Seçenek a, ödemenin yalnızca veli butona bastığında başladığı koda (`payments-checkout`) uygun görünüyor. Yine de yenileme davranışı veride tanımlı değildir.

**Durum metinleri (A ekranı):**
- Yükleniyor: mevcut `loading` metni.
- Deneme bilgisi alınamadı: "Deneme bilgisi şu an alınamadı. Planlar aşağıda; fiyatlar değişmez." Planlar alınabiliyorsa gösterilir.
- Ödeme başlatılamadı: mevcut `checkoutError` metni.

### 2.2 Alternatif başlıklar

- **A-alt-1:** Önce {gun} gün deneyin, sonra karar verin. Öneri: koşul sorusunu erken yanıtlar, karar baskısı kurmaz.
- **A-alt-2:** Düzenli pratiği {gun} gün ücretsiz deneyin. "Düzenli pratik" bir çalışma biçimidir, sonuç vaadi değildir.

Ana başlık için A-alt-1 önerilir. Aynı testte iki başlık birden kullanılmaz; başlık değişirse ayrı bir kol olur.

### 2.3 Yerleşim notu (A; 360 ve 390 px öncelikli)

1. Üstte başlık ve alt metin. `PlanKarti` başlık stili korunur.
2. Hemen altında deneme bandı: ikon ve metin, tek kutu. Bitiş tarihi ve kota bu bantta bulunur. Renk tek başına bilgi taşımaz.
3. Plan kartları aynı sırada. Her kartta fiyat, süre, deneme satırı ve yenileme satırı bulunur. Deneme satırı yalnız gerçek bir deneme tanımlıysa gösterilir; aksi halde KARAR-2 sonucuna göre gizlenir.
4. Koşul satırı CTA'nın hemen üstünde. En az 14 px, gri-500 üzeri.
5. CTA tam genişlikte (mobil), en az 44 px yükseklikte (`min-h-11`), mevcut `brand-500` rengiyle. Devre dışı ve `aria-busy` durumları korunur.
6. `paymentNote` ve `cancelNote` aynen kalır.
- Hupo maskotu yoktur. Veli ödeme ekranı bilgi ekranıdır; maskot burada yalnız dekor olur.
- Yeni renk eklenmez. Beyaz metin ile `brand-500` arasındaki kontrast bu taslakta ölçülmedi; uygulamadan önce ölçülmelidir.

---

## 3. Varyant C: deneme sonu hatırlatması

### 3.1 Uygulama içi (veli paneli, üyelik sayfasının üstü)

Üç satırlık, kapatılabilir banner:
1. Ücretsiz denemeniz {bitis_tarih} tarihinde bitiyor.
2. Devam etmek isterseniz planlar ve fiyatlar aşağıda.
3. Bitiş tarihinden önce istediğiniz zaman plan seçebilirsiniz.

Düğmeler: **Planları gör** (birincil; plan kartlarına gider) ve **Daha sonra** (banner'ı gizler).

### 3.2 E-posta (yalnızca 3.5'teki ön koşul sağlanırsa)

- **Konu:** Ücretsiz denemeniz {bitis_tarih} tarihinde bitiyor
- **Gövde (3 satır):**
  1. Merhaba {veli_ad}, ücretsiz denemeniz {bitis_tarih} tarihinde bitiyor.
  2. Devam etmek isterseniz planları ve fiyatları veli panelinizde görebilirsiniz: {veli_panel_url}
  3. Bitiş tarihinden önce istediğiniz zaman plan seçebilirsiniz.
- **Alt bilgi:** Bu e-postaları almak istemiyorsanız {tercih_url} adresinden tercihlerinizi değiştirebilirsiniz. [Şirket bilgisi: hukuk bekliyor]

### 3.3 Gönderim koşulları

| Konu | Öneri | Gerekçe ve kaynak |
|---|---|---|
| Tetik | Bitişe 3 gün kala, her deneme kaydı için bir kez | T-1 son gün baskısı yaratır. T-7 unutulur. T-3 karar için yeterli süre bırakır. |
| Uygulama içi görünürlük | Yalnızca veli paneli açıldığında. Bitişe 3 gün kala başlar. "Daha sonra" ile gizlenir. En fazla 2 gösterim. | Push kullanılmaz; pazarlama push kapısı varsayılan kapalıdır (`pazarlama_push_kapisi`). |
| E-posta saati | Hafta içi, 10:00–18:00 İstanbul, tek gönderim | Hafta sonu gönderilmez |
| Sessiz saat | 20:00–08:00 Europe/Istanbul | Push altyapısındaki mevcut varsayılanla aynı; e-posta için de uygulanır |
| Kapsam | Yalnız veli hesabı; aktif deneme; ücretli plan yok; C kolu | Çocuk hesabı ve çocuk uygulaması hariç |
| Ön koşul (e-posta) | Hukuk, e-postanın hizmet bildirimi mi ticari ileti mi olduğunu belirler. Ticari ise yalnız pazarlama izni olan veliye gider. | K-0011 ve GÖR-019 (İYS) bekliyor |
| Kontrol kolu | Hatırlatma almaz; A metinlerini görmez | Atama hane bazlı, bir kez |
| Kayıt | Her gösterim ve gönderim `growth_mesaj_gunlugu` içine yazılır | Mevcut tablo; yeni alan gerekmez |

Kullanılmayan kanallar: SMS ve WhatsApp (GÖR-018/019), pazarlama push. Çocuk uygulamasında hatırlatma yoktur.

### 3.4 Kapatma ve iptal cümleleri

- Uygulama içi kapatma: "Daha sonra" düğmesi. Bu hatırlatmayı gizler; plan seçimini etkilemez.
- E-posta: alt bilgi cümlesi (3.2). Tercih sayfasında bu hatırlatma için bir kutu yoksa cümle yazılmaz; önce kutu eklenir.
- Ücretli plan iptali: **bu taslakta yazılmaz.** İptal kanalı doğrulanmadı; `iletisim@hupolingo.com` yalnız yer tutucudur (`decisions.md`, 2026-10-16). Kanal ve akış netleşince yazılır.

---

## 4. Yasak kontrolü ve gerekçe

| ID | Metin (kısa) | Sonuç | Gerekçe |
|---|---|---|---|
| A-1 | Çocuğunuz için {gun} gün ücretsiz deneyin | Koşullu | Süre admin ayarıdır; garanti veya sonuç vaadi yok. Kartsız deneme çalışmıyorsa yayınlanmaz (KARAR-1). |
| A-2 | Önce deneyin... Fiyatlar aşağıda açıkça yazılı. | Geçti | Kanıt iddiası yok; fiyat rakamı değişmez. |
| A-3 | Ücretsiz denemeyi başlat | Koşullu | Kart gerekiyorsa CTA değişir ve kart ile ücret koşulu CTA'nın yanında açık yazılır. |
| A-4 | Bitiş tarihi ve kalan gün | Geçti | Gerçek veri; veri yoksa satır gösterilmez. Sahte geri sayım yok. |
| A-5 | Kota: {gunluk_soru} soru | Koşullu | Değer admin ayarı; yayın değeri onaylı değil (Açık soru 5). |
| A-6 | Koşul satırı | Koşullu | Eksik ya da yanlış yazılırsa gizli ücret algısı oluşur. Seçenek a veya b onaylanmadan yayınlanmaz. |
| A-alt-1 | Önce {gun} gün deneyin, sonra karar verin | Geçti | Baskı dili yok. |
| A-alt-2 | Düzenli pratiği {gun} gün ücretsiz deneyin | Geçti | "Düzenli" bir çalışma biçimi; sonuç veya puan vaadi değil. |
| Kaldırıldı | "14 Gün İade Garantisi", "%100 Güvenli Ödeme", "Gizli Ücret Yok" | A ve C'de yok | Landing'de kanıtsız iddialar (`decisions.md`, 2026-10-09, AÇIK RİSK). İade süreci doğrulanmadan A ve C'ye alınmaz. |
| C-1 | Ücretsiz denemeniz {tarih} tarihinde bitiyor. | Geçti | Gerçek tarih. "Son fırsat" ve "bugün bitiyor" yok. |
| C-2 | Devam etmek isterseniz planlar ve fiyatlar aşağıda. | Geçti | Bilgi veriyor, zorlamıyor. |
| C-3 | Bitiş tarihinden önce istediğiniz zaman plan seçebilirsiniz. | Geçti | Ödeme ekranı bitiş tarihine kadar açık kalmalı; kodda öyledir. |
| C-4 | E-posta konusu | Geçti | Tarih gerçek; aciliyet dili yok. |
| C-5 | E-posta gövdesi | Koşullu | Gönderim sınıfı hukuk kararına bağlı (3.3). |
| C-6 | Alt bilgi ve kapatma | Koşullu | Tercih kutusu yoksa cümle yazılmaz. |
| C-7 | Planları gör / Daha sonra | Geçti | Suçluluk ve baskı dili yok. |
| Tümü | Çocuk verisi | Geçti | Metinlerde ilerleme, soru sayısı, konu veya davranış yok. Veliye çocuğun performansını gösteren bir hatırlatma bu testte yasaktır. |
| Tümü | Sahte yorum, sayı, uzman, sertifika | Geçti | Yok. |
| Tümü | Puan veya sınav garantisi | Geçti | Yok. |
| Tümü | Farklı fiyat | Geçti | Tek fiyat; fiyat değişmez. |

---

## 5. Ölçüm taslağı (ön kayıt için)

- **Birincil metrik:** maruziyetten sonra 7 gün içinde başarılı ödeme yapan veli / maruziyet alan veli. Maruziyet `ab_maruziyet_kaydet` ile (kullanıcı başına bir kez) kaydedilir. Dönüşüm `ab_donusum_kaydet` ile kaydedilir; metrik adı deney tanımında önceden kayıtlı olmalıdır.
- **Maruziyet tanımı:** A için ödeme ve paket ekranının plan listesiyle render edilmesi. C için banner'ın gösterilmesi; e-posta açılması değil (Açık soru 12).
- **Ödeme durumu:** "başarılı" durum değeri `payments` tablosunda doğrulanacak.
- **Koruma metrikleri (en az iki):**
  1. Ödeme başlatma hatası veya iptal edilen ödeme oranı (`payments.durum`).
  2. C için banner kapatma oranı. Ücret veya iptal ile ilgili destek talebi ayrı etiketlenmiyorsa ölçülemez; bu açıkça yazılır.
- **Örneklem ve süre:** referans ölçümü (30 gün) başlamadı. Örneklem ve minimum ilgi farkı bu ölçüm olmadan hesaplanmaz. Bu taslakta sayı uydurulmadı.
- **Kurallar:** ara bakış yok; SRM kontrolü yapılır; koruma metriği kötüleşirse deney durdurulur. Sonuç, son maruziyetten 7 gün sonra okunur. Yetersiz örnekte sonuç gösterilmez (`admin_ab_sayilar`, n < 30).
- **Kol sayısı:** iki kol (kontrol, A) için tek karşılaştırma. Üç kol (kontrol, A, C) için Bonferroni düzeltmesi gerekir (Açık soru 7).

---

## 6. Açık sorular

**K** yayını bloklar. **Ö** önemlidir, ama taslak yazılabilir.

1. **K. Gerçek ücretsiz deneme yolu.** Kartsız ve self-serve bir deneme akışı yoksa A ve C yayınlanmaz. Önerim: bu akış tasarlanana kadar kontrol kolu değişmeden kalır. Kart isteyen bir deneme bu testte önerilmez; kart ve ücret koşulları hukuk onayı gerektirir. Sahip: ürün ve kullanıcı.
2. **K. `plans.deneme_gun` canlı değeri.** Salt okunur kontrol: `select kod, deneme_gun from plans where aktif`. Değer 0'dan büyükse kontrol kolundaki deneme satırı düzeltilmelidir; bu, test kararından bağımsız bir ürün düzeltmesidir. Sahip: kullanıcı (veri erişimi).
3. **K. Deneme sonu davranışı.** Ücret alınır mı, yenileme var mı, erişim nasıl biter? KARAR-3 seçeneklerinden hangisi geçerli, ya da başka bir model mi? Sahip: ürün ve hukuk.
4. **Ö. Deneme kapsamı.** Deneme süresince veli paneli, deneme sınavları ve plan özellikleri açık mı? Alt metinler buna bağlıdır. Bugünkü landing, "Veli paneli" özelliğini premium listesinde gösteriyor; deneme için açık bir kayıt yok.
5. **Ö. Süre ve kota.** 14 gün ve günlük kota (varsayılan 20) 2026-10-18 kararlarında kayıtlıdır. Ancak veli ekranında gösterilecek sayının onayı ayrıca alınmalıdır. Onay gelmeden A-5 yayınlanmaz.
6. **Ö. Kart isteniyor mu?** Önerim: hayır. Bu testte kartsız deneme yoksa A ve C ertelenir.
7. **Ö. Test yapısı.** I4 kararı "A veya C" diyor. Önerim: ilk test kontrol ve A (iki kol). C'nin hedef kitlesi aktif denemedeki velilerdir; bugün bu kitle elle açıldığı için küçüktür. C ikinci dalgaya alınmalıdır. Üç kol gerekiyorsa örneklem ve Bonferroni yeniden hesaplanır.
8. **Ö. Referans ölçümü.** I4 "mağaza yayını ve ilk indirmelerden sonra" diyor, ama bu test veli web paneli üzerinde. Web için referans hangi tarihte ve hangi trafikle alınacak? Sahip: proje sahibi.
9. **K. Hukuk: e-posta sınıfı ve metinler.** Deneme bitiş bildirimi hizmet bildirimi mi, ticari ileti mi (K-0011, GÖR-019)? Hukuk metni gerekiyor: alt bilgi ve tercih metni, deneme ve yenileme koşulları, iade veya garanti iddiasının kaldırılması ya da doğrulanması, şirket bilgisi. Onaysız yayın yapılmaz.
10. **Ö. İptal kanalı.** Destek kanalı ve iptal akışı doğrulanana kadar iptal cümlesi yazılmaz.
11. **Ö. Terminoloji.** "Deneme" hem deneme sınavı hem ücretsiz deneme anlamına geliyor. Onay istenir: veli arayüzünde "ücretsiz deneme" kullanılsın, deneme sınavları ayrı adıyla kalsın.
12. **Ö. C maruziyeti.** Banner gösterimi mi, e-posta gönderimi mi? Önerim: banner gösterimi.
13. **Ö. Hupo görseli.** Ödeme ekranında maskot olmaması önerilir. Onay istenir.

---

## 7. Yayın kapısı (sırayla)

1. Açık sorular 1, 2, 3 ve 9 yanıtlanır.
2. Seçilen deneme yolu sandbox'ta uçtan uca test edilir: kayıt, deneme, ödeme, dönüş. Bugüne kadar yapılmadı.
3. Referans ölçümü tamamlanır; birincil ve koruma metrikleri ön kayıtla deney tanımına girer.
4. Metinler i18n'e alınır (tr ve en). Uzun metin ve 360 px taşma testi yapılır; kontrast ölçülür.
5. Hukuk onayı ve proje sahibinin son onayı alınır.

---

## 8. Doğrulama ve sınırlar

- **Yapıldı:** yukarıdaki kaynakların okunması; migration ve kod karşılaştırması. Kod, veritabanı, ayar ve fiyat değiştirilmedi.
- **Yapılmadı:** canlı veritabanı sorgusu (`plans`, `app_settings`) için erişim yoktu; tarayıcı kontrolü yapılmadı; ödeme sandbox testi yapılmadı; metinlerin i18n, taşma ve kontrast testi yapılmadı.
- **Çelişki:** `decisions.md` 2026-10-06 "ücretli plan hazırlık aşamasında" diyor; 2026-10-09 kaydı paket kartının ve ödeme akışının kurulduğunu yazıyor. Canlıda hangisinin geçerli olduğu Açık soru 2 ile birlikte doğrulanmalı.

## 9. Kullanıcı kararları (2026-10-28, son)
1. **Deneme akışı:** Önce kartsız, kendi başına açılan deneme akışı ürün olarak kurulur (ayrı iş ve hukuk onayı). A ve C ondan sonra.
2. **Deneme sonu:** Otomatik ücret yok. Erişim bitince premium özellikler kapanır, ücretsiz günlük kota kalır, veli ödeme ekranına yönlendirilir. Otomatik yenileme ilk dönemde yok (veli bilinçli satın alır). Hukuk onayı şart.
3. **14 gün ve günlük kota:** Veli ekranında gösterilir; rakamlar plan kaydından gelir (metne sabit yazılmaz). Önce plan kaydı doldurulmalı (`deneme_gun` şu an boş).
4. **Test yapısı:** İlk test kontrol ve A (iki kol). C ikinci dalga. İki kolda Bonferroni gerekmez.
5. **Referans ölçümü:** Web için ayrı tetikleyici: kartsız deneme sandbox'ta uçtan uca test edilip canlıya alındıktan ve veli panelinde gerçek ödeme ekranı trafiği oluştuktan sonra 30 gün. Mağaza yayınını beklemez.
6. **Terminoloji ve maskot:** Veli arayüzünde "ücretsiz deneme"; "deneme" tek başına geçmez; deneme sınavları kendi adıyla kalır. Ödeme ekranında maskot yok. Landing iddiaları ("14 Gün İade Garantisi", "%100 Güvenli Ödeme", "Gizli Ücret Yok") doğrudur ve kullanılabilir; ajanın bu iddiaları dışlama önerisi geçersiz.
