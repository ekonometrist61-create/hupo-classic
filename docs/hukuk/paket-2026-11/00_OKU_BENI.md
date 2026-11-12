> **Durum:** TASLAK · 2026-11-12 · Hukuki görüş değildir. Yayından önce KVKK ve tüketici hukuku bilen bir avukat onaylamalıdır. Köşeli parantezli `[ALAN]`lar doldurulmadan yayına alınmaz.

# Hupolingo hukuk paketi (2026-11): yol haritası

Bu klasör, Hupolingo'nun web sitesi, veli paneli, mobil ve web uygulaması için gereken bütün hukuki metinleri tek yerde toplar. Mevcut metinler (`web-panel/src/lib/legal/content.ts`, `/ticari-ileti-izni`, `mobile-app/lib/content/privacy_notice.dart`) bu paketle değiştirilecek.

## 1. Belgeler

| # | Belge | Kime | Nerede gösterilir | Onay biçimi |
|---|---|---|---|---|
| 01 | [Üyelik ve Kullanım Sözleşmesi](01_KULLANIM_SOZLESMESI.md) | Veli, öğrenci | `/kosullar`, kayıt ekranı | "Okudum, kabul ediyorum" kutusu (zorunlu) |
| 02 | [KVKK Aydınlatma Metni](02_KVKK_AYDINLATMA_METNI.md) | Veli, ziyaretçi, aday | `/gizlilik`, her formun altı | **Onay alınmaz**, yalnız bağlantı ("Aydınlatma metnini okuyun") |
| 03 | [Çocuk ve Veli Metinleri](03_COCUK_VE_VELI_METINLERI.md) | Öğrenci (sade dil), veli | Uygulama ilk açılış, veli eşleştirme | Çocuk: okundu kaydı · Veli: veli onayı kutusu |
| 04 | [Açık Rıza ve İzin Metinleri](04_ACIK_RIZA_VE_IZIN_METINLERI.md) | Veli, aday | Kayıt, form, tercih merkezi | Her izin ayrı kutu, işaretsiz, isteğe bağlı |
| 05 | [Çerez Politikası](05_CEREZ_POLITIKASI.md) | Ziyaretçi | `/cerez-politikasi`, çerez bandı | Banda göre kategori bazlı |
| 06 | [Ön Bilgilendirme ve Mesafeli Satış](06_ON_BILGILENDIRME_MESAFELI_SATIS.md) | Satın alan veli | Ödeme öncesi | İki kutu (zorunlu) |
| 07 | [İletişim Politikası (iç kural)](07_ILETISIM_POLITIKASI_IC_KURAL.md) | Ekip, CRM, ajanlar | Repo içi | — |
| 08 | [Veri İşleyen Sözleşmesi ve aktarım listesi](08_VERI_ISLEYEN_SOZLESMESI.md) | Tedarikçi, ajans, serbest çalışan | İmzalı sözleşme | Islak/e-imza |
| 09 | [Veri Sahibi Başvuru Formu](09_BASVURU_FORMU.md) | Herkes | `/kvkk-basvuru` | — |
| 10 | [Saklama ve İmha Politikası](10_SAKLAMA_IMHA_POLITIKASI.md) | İç + talep edene | Repo içi, istek üzerine | — |
| 11 | [Künye (6563 m.3)](11_KUNYE.md) | Herkes | Footer `/kunye` | — |

## 2. "Eli geniş" olmanın yasal yolu: ana fikir

İstenen şey, kullanıcıyı korkutmadan ve ona zarar vermeden pazarlama, e-posta, SMS, bildirim ve veri işleme alanında en geniş hareket serbestisini sağlamak. Türk hukukunda bunun yolu "her şeye tek imza almak" değildir. Kişisel Verileri Koruma Kurulu bunu açıkça geçersiz sayıyor ve ceza kesiyor. Doğru yol üç katmandır:

**Katman 1 — Rıza gerektirmeyen geniş alan (en büyük alan).** İşlemlerin çoğunu açık rızaya değil, sözleşme (KVKK m.5/2-c), hukuki yükümlülük (m.5/2-ç) ve meşru menfaat (m.5/2-f) dayanağına oturttuk. Bu dayanaklar geri alınamaz; kullanıcı "rızamı geri alıyorum" dese de hizmet için gereken işlem sürer. Bu katmana girenler:
- hesap, giriş, güvenlik, ödeme, fatura e-postası/SMS'i ve bildirimi;
- çocuğun haftalık gelişim raporunun veliye gönderilmesi (ürünün kendisi);
- kota doldu, deneme bitiyor, abonelik bitiyor gibi **hesap durumu bildirimleri** (tanıtım dili olmadan);
- satın alınan pakete gelen yeni özellik, değişiklik ve kullanım ipucu iletileri (6563 m.6/1 istisnası, ayrı onay gerekmez);
- uygulama içi ürün analitiği, A/B testi, hata izleme, dolandırıcılık önleme (meşru menfaat; çocuk ekranlarında reklam/çapraz site takibi yok);
- **anonim** istatistiklerin her amaçla (basın, rapor, pazarlama içeriği, ürün geliştirme) kullanılması. Gerçekten anonim veri KVKK kapsamı dışındadır.

**Katman 2 — Tek, cazip ve dürüst izin kutusu.** Kampanya iletileri için tek ana kutu: "Kampanya, indirim ve yeniliklerden e-posta, SMS ve uygulama bildirimiyle haberdar olmak istiyorum." (Telefon araması şimdilik yapılmayacağı için kapsam dışı; karar 2026-11-12.) Bu kutu hem 6563 ticari ileti onayını hem KVKK açık rızasını birlikte alır (Kurul ikisini aynı faaliyet sayıyor) ve **kişiselleştirmeyi kapsar** (velinin paketi, kullanım sıklığı, çocuğun sınıf düzeyi). Kanal kanal ayrım tercih merkezinde yapılır. Tek kutu, üç ayrı kutuya göre çok daha yüksek onay oranı getirir ve hukuken geçerlidir; şartı, isteğe bağlı olması ve işaretsiz başlamasıdır.

**Katman 3 — Ayrı ve dar izinler.** Reklam platformlarıyla eşleştirme (Meta/Google/TikTok özel kitle, dönüşüm API), pazarlama çerezleri ve gerçek kullanıcı yorumunun/başarı hikâyesinin yayınlanması ayrı kutudur. Bunlar ayrı olmazsa Kurul kararlarına göre bütün izin paketi sakatlanır. **Lansmanda reklam eşleştirmesi ve pazarlama çerezleri kapalıdır** (karar 2026-11-12); metinleri hazır tutulur, KVKK standart sözleşmesi sağlanınca açılır.

**Kullanıcıyı korkutmayan yanı:** Her metnin başında 5 satırlık "kısaca" özeti var; satmama, çocuğa reklam yapmama, tek tıkla iptal, gönül rahatlığı iadesi gibi güvence cümleleri öne çıkarıldı. Bunlar hem dönüşümü artırır hem ihlal riskini düşürür.

> **Yapay zekâ ifadesi (2026-11-12):** Sözleşme Madde 3.3–3.5 ve 13.2, aydınlatma §8 ve "Kısaca" özeti içeriklerin yapay zekâ desteğiyle hazırlandığını ve hata olabileceğini açıkça söyler. Bu ifade hatalara karşı koruma sağlar ama **ağır ihmal, ayıplı hizmet ve tüketici haklarını ortadan kaldıramaz**; bu yüzden gerçek koruma, yayın öncesi kontrol kapılarının (soru: iki ajan + insan, hikâye: insan onayı) çalışmaya devam etmesidir. İfade, "yapay zekâ kullanılmaz" iddiası gerektiren ortamlarda (ör. MEB hikâye yarışması, mağaza beyanları) kullanılmamalı; oralarda gerçek durum beyan edilmelidir. Avukat teyidi bekliyor.

## 3. Kırmızı çizgiler (bunları yapmak eli genişletmez, ceza getirir)

1. **İzni hizmete şart koşmak.** Kurul 2025/1072 sayılı kararıyla ticari ileti onayının ürün/hizmet için zorunlu gösterilmesini ve "bilgi güncelleme" gibi başka bir amaçla alınmasını hukuka aykırı saydı. Kutular isteğe bağlıdır, işaretsiz başlar, onaysız da üye olunur.
2. **Aydınlatma ile rızayı birleştirmek.** "Aydınlatma metnini okudum ve onaylıyorum" kutusu kullanılmaz. Aydınlatma yalnız bağlantıdır; rıza ayrı kutudur.
3. **Çocuğa ticari ileti ve satın alma teşviki.** Ticari Reklam ve Haksız Ticari Uygulamalar Yönetmeliği, çocuğu doğrudan satın almaya veya anne-babasını ikna etmeye teşvik eden reklamı yasaklar. Bu yüzden:
   - öğrenci hesabına/cihazına kampanya e-postası, SMS'i, push'u gitmez;
   - çocuk ekranındaki kilitli içerik mesajı nötr olur: ✅ "Bu bölüm veli planıyla açılır. Velin, veli panelinden bakabilir." ❌ "Velinden iste, hemen aç!", ❌ geri sayım, ❌ "arkadaşların açtı";
   - çocuk uygulamasında reklam pikseli, reklam SDK'sı, çapraz uygulama takibi yok (Apple Kids / Google Families kuralları da bunu ister).
   - Not: Monetizasyon kararında "satın alma çocuk ekranında da olabilir" yazıyor (2026-10-18). Ödeme veli kartıyla ve 3DS ile olsa da, çocuk ekranındaki **teşvik dili** bu yönetmeliğe takılır. Ödeme adımı veli doğrulamasının (veli PIN'i/veli girişi) arkasına alınmalı. **Karar gerekiyor.**
4. **İYS'siz SMS/e-posta/arama.** Onay alındıktan sonra 3 iş günü içinde İYS'ye yüklenir; İYS'de onayı görünmeyen kişiye ticari SMS, e-posta veya arama yapılmaz. Ret bildirimi gelince en geç 3 iş günü içinde gönderim durur.
5. **Yurt dışı aktarımda açık rızaya güvenmek.** 7499 sayılı değişiklikten sonra (1 Eylül 2024 itibarıyla) düzenli aktarımlar açık rızayla yapılamaz. Yurt dışındaki her hizmet sağlayıcısıyla Kurul'un **standart sözleşmesi** imzalanır ve imzadan sonra **5 iş günü içinde** Kurum'a bildirilir. Bkz. belge 08.
6. **Sahte sosyal kanıt.** Uydurma yorum, sayı, "son 3 yer" gibi sahte kıtlık yasaktır (proje kuralı ve haksız ticari uygulama).
7. **Puan/sınav garantisi.** Sözleşme ve pazarlamada başarı garantisi verilmez.

## 4. Mevcut metinlere göre neler değişti

| Konu | Eski metin | Yeni paket | Neden |
|---|---|---|---|
| Ticari ileti kutusu | 3 ayrı kutu (e-posta/SMS/telefon) | 1 ana kutu (e-posta, SMS, push) + tercih merkezinde kanal ayrımı; telefon araması yok | Onay oranı; hukuken geçerli; kullanılmayan kanala izin toplanmaz |
| Kişiselleştirme | Belirtilmemiş, "segment yalnız izinliler" | Ana kutunun içinde açıkça yazılı | Hedefli kampanya yapabilmek |
| Reklam platformları | "Hiç paylaşmayız" (kesin söz) | Lansmanda kapalı; ileride ayrı izinle ve standart sözleşme şartıyla açılabilir | Kesin söz ileride elinizi bağlardı |
| Hizmet iletileri | Yalnız "giriş, parola" | Hesap durumu, rapor, kota, paket değişikliği dahil geniş liste | Rızasız iletişim alanı |
| Anonim veri | Değinilmemiş | Açıkça serbest | Rapor/PR içeriği |
| Yurt dışı aktarım | Dayanak boş | Standart sözleşme + 5 iş günü bildirimi | 7499 sonrası tek güvenli yol |
| Cayma | Belirsiz | Yasal istisna + gönüllü 14 günlük gönül rahatlığı iadesi | Güven; düşük maliyet |
| Otomatik yenileme | "Yoktur" (kesin) | Web tek seferlik (30/7/1 gün kala hatırlatma); mağaza abonelikleri yenilenir | Mağaza abonelikleri yenilenir (Qonversion); web yenilemesi 3–6 ay sonra yeniden değerlendirilir |
| Çocuk ekranında satın alma dili | Kural yok | Nötr dil zorunlu | Reklam yönetmeliği |
| Hitap | "sen" | Veli belgelerinde "siz", çocuk metninde "sen" | Hukuki metinde güven |

## 5. Kodda yapılacaklar (bu paket kod değiştirmedi)

1. `content.ts`, `/ticari-ileti-izni`, `privacy_notice.dart` metinleri bu paketle değiştirilecek; sürümler artırılacak (`hupolingo-ticari-ileti-2026-11-v2`, `kPrivacyNoticeVersion` yükseltilir).
2. `SignUpForm.tsx` ve `DenemeKayitForm.tsx`: 3 kutu → 1 ana kutu ("Reklam ortakları" kutusu lansmanda gösterilmez). Veritabanı yapısı (`iletisim_tercihleri`, kanal başına satır) aynı kalır; ana kutu işaretlenince her kanal için ayrı satır yazılır (eposta, sms, push). `telefon` kanalına yeni onay yazılmaz; eski telefon onayları korunur ama kullanılmaz. Kanal kısıtı `push` değerini de içermeli (migration gerekir).
3. Tercih merkezi (veli paneli "İletişim izinlerim"): kanal kanal aç/kapa (e-posta, SMS, push) + "Başarı hikâyesi" ("Reklam ortakları" açıldığında eklenir). `iletisim_izni_iptal_et` şu an yalnız e-posta kanalını destekliyor; tüm kanallara genişletilmeli.
4. İYS entegrasyonu: onay/ret İYS'ye 3 iş günü içinde (cron veya webhook). Kampanya gönderiminden önce İYS sorgusu/bastırma listesi.
5. Push bildirimi kategorileri: "Çalışma hatırlatmaları" (hizmet) ve "Kampanyalar" (onaylı, yalnız veli cihazı). Öğrenci rolünde kampanya kategorisi hiç yok.
6. Çerez bandı: "Reddet" ile "Kabul et" eşit görünürlükte; lansmanda yalnız zorunlu + analitik kategorisi.
7. **(Avukatı beklemez)** Çocuk ekranındaki kilitli içerik ve satın alma metinleri nötr dile çevrilir; ödeme veli kapısının arkasına alınır.
8. **(Avukatı beklemez)** Web planı bitiş hatırlatmaları: 30/7/1 gün kala veliye e-posta (+ veli cihazına push), indirim içermez.
9. Yeni sayfalar: `/cerez-politikasi`, `/kvkk-basvuru`, `/kunye`, `/acik-riza` (izin metinlerinin tam hâli).

## 6. Doldurulacak bilgiler ve kararlar

**Şirket bilgisi (hepsi bloke edici):** ticaret unvanı, MERSİS, vergi dairesi/no, adres, KEP, telefon, e-posta (`kvkk@hupolingo.com`, `destek@hupolingo.com` önerilir), ticaret sicil müdürlüğü, meslek odası.

**Teknik bilgi:** Supabase sunucu bölgesi; hesap silme sonrası silme süresi (öneri 30 gün); hata kayıtları (öneri 90 gün); analitik (öneri 24 ay); giriş kayıtları (migration'a göre 180 gün, teyit).

**Kullanıcı kararları (2026-11-12, ONAYLI — K-0256):**
1. **Gönül rahatlığı iadesi: AÇIK.** İlk ücretli satın almada 14 gün, koşulsuz, hesap başına bir kez. Web ve Google Play iadesini Hupolingo yapar; Apple iadesi Apple'ın kararına bağlıdır, Apple reddederse veliye ücretsiz ek süre verilir. (Belge 06 §7.)
2. **Web otomatik yenileme: KAPALI (lansman).** Web planları tek seferlik; bitişten 30, 7 ve 1 gün önce indirim içermeyen hatırlatma (K sınıfı ileti). Mağaza abonelikleri yenilenir. 3–6 ay sonra yenileme verisine bakılıp yeniden değerlendirilir.
3. **Reklam platformu eşleştirmesi ve pazarlama çerezleri: KAPALI (lansman).** Ölçüm UTM + PostHog (AB) ile, kişisel veri göndermeden. Meta ve Google'dan KVKK standart sözleşmesi istenecek; imzalanırsa İzin 2 ve pazarlama çerezleri açılır.
4. **Çocuk ekranında satın alma: veli kapısının arkasında.** Çocuk ekranında yalnızca "Veline bilgi gönder"; veliye hizmet bildirimi gider, satın alma veli panelinden. Çocuk cihazında ödeme ekranı veli doğrulamasıyla açılır (Apple Kids kuralı da gerektirir).
5. **VERBİS: büyük olasılıkla muaf;** şirket kuruluşunda SMMM'ye "bilanço esasına göre mi defter tutulacak?" sorusuyla teyit ettirilecek. Saklama ve imha politikası yine de tutulur.
6. **Telefon araması: yok.** Pazarlama kutusundan çıkarıldı; telefon numarası yalnız SMS ve hesap doğrulaması için.

## 7. Yayın kontrol listesi

- [ ] Avukat onayı (özellikle: sorumluluk sınırı, gönül rahatlığı iadesi, çocuk hesabı)
- [ ] Tüm `[ALAN]`lar dolu
- [ ] İYS'ye hizmet sağlayıcı (marka) kaydı yapıldı
- [ ] Yurt dışı tedarikçilerle standart sözleşmeler imzalandı, 5 iş günü içinde bildirildi
- [ ] Metin sürümleri kod ve veritabanında artırıldı
- [ ] Kayıt ekranı gerçek tarayıcıda denendi: kutular işaretsiz, onaysız kayıt mümkün
- [ ] Tercih merkezinden kanal kapatma uçtan uca denendi (İYS'ye ret gidiyor)

## 8. Kaynaklar (2026-11-12'de kontrol edildi)

- 6698 sayılı KVKK (7499 sayılı Kanunla değişik m.6, m.9), Aydınlatma Yükümlülüğü Tebliği, Başvuru Usul ve Esasları Tebliği, Kurul Açık Rıza ve Çerez Rehberleri
- 6563 sayılı Elektronik Ticaretin Düzenlenmesi Hakkında Kanun m.3, m.6; Ticari İletişim ve Ticari Elektronik İletiler Hakkında Yönetmelik (İYS)
- 6502 sayılı TKHK, Mesafeli Sözleşmeler Yönetmeliği (m.15 cayma istisnaları), Ticari Reklam ve Haksız Ticari Uygulamalar Yönetmeliği (çocuklar)
- Kurul 2025/1072 (ticari ileti onayı hizmet şartı olamaz), 2025/1572 ve 2025/2393 (VERBİS istisnaları)
- Kurum standart sözleşme bildirim duyurusu (5 iş günü, KEP veya bildirim modülü)
- Piyasa uygulaması: Türk eğitim teknolojisi firmaları aydınlatma metnini formun altında bağlantı olarak verir, ticari ileti onayını ayrı kutuda alır ve İYS üzerinden yönetim sunar (ör. Doping Hafıza işlem rehberi). Duolingo, Khan Academy Kids gibi çocuk odaklı ürünler çocuk hesabında reklam ve pazarlama iletisi göndermez; pazarlamayı yetişkin hesabına yapar.
