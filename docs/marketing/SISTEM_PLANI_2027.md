# 2027 Pazarlama Planı için sistem analizi ve geliştirme planı

Tarih: 2026-10-29 · Durum: ÖNERİ (karar bekliyor) · Girdi: "Hupolingo — Stratejik Pazarlama Planı 2027" (PDF, 14 sayfa)
Yöntem notu: Durum tespiti depo taramasıyla (dosya/tablo/sayfa varlığı, `pubspec.yaml`, `PROJE_GUNLUGU.md`, `16_IMPLEMENTATION_BACKLOG.md`) yapıldı. Dosyanın var olması çalıştığını kanıtlamaz; commit'siz çalışma ağacındaki işler ve uzak veritabanı durumu doğrulanmadı. Efor değerleri tahmindir (tek geliştirici + yapay zekâ ajanları, iş günü).

## 1. Planın kendi içindeki, sistem planını etkileyen noktalar
1. **Takvim kritik yolu mağazadır.** Plan 14–20 Aralık'ta iki mağazaya gönderim, 22 Ocak'ta lansman varsayıyor. Bugün: mağaza hesapları ve imzalama anahtarı yok (GÖR-010), `pubspec.yaml`'da uygulama içi satın alma paketi yok (`in_app_purchase`/RevenueCat bulunmadı), Veri Güvenliği formu güncel değil (GÖR-083), ödeme sandbox testi bekliyor (GÖR-016/078/082). Gönderime ~6,5 hafta var.
2. **Satın alma yolu çelişkisi.** Plan "mağaza komisyonu ve KDV öncesi liste fiyatı", "abonelik doğrulama ve iptal akışı" diyor (mağaza içi satın alma). Depoda ise ödeme iyzico (web, tek seferlik; K-0196). Şirketsiz yolda iyzico yok. Hangisinin lansman yolu olduğu belirlenmeden ödeme işi başlamaz.
3. **Modül paketleri için yetki katmanı yok.** Tek `is_premium` bayrağı + günlük soru kotası; `plans` yalnız fiyat/süre/gösterim metni, para birimi yalnız TRY. Plan 6 paket (HupoRead, Soru, Tam, Aile 2, Aile 3 + ücretsiz), modülden Tam'a mahsup ve "yalnız kendi modülünün raporu" istiyor.
4. **Ortaklık (Motor B) planda "küçük ücret; performansa bağlı".** Şirketsiz yolda ortağa ödeme yapılamaz; v1 ödemesiz "Ortak Lite" olmalı (bkz. docs/is-ortagi).
5. **Fiyat:** plan 199/1.599 TL (modül 119/899, Aile 299/399). Bizim hesapla (docs/fiyat) 149/1.199 civarı öneri vardı. Sistem fiyatı kodda sabitlemeyecek; fiyat kararı ayrıdır.
6. **Alan adı:** plan `hupolingo.com.tr` kurumsal e-posta diyor; proje alan adı mimarisi `hupolingo.com` üzerinde.
7. **Kapasite:** 13 haftada aşağıdaki lansman paketinin tamamı tek kişiye sığmıyor (bkz. §4). Kapsam kesilmeli.

## 2. Gereksinim → mevcut durum → boşluk
Durum: ✅ var · 🟡 kısmen · ❌ yok.
| # | Planın istediği | Depoda görülen | Durum | Boşluk | Efor |
|---|---|---|---|---|---|
| 1 | Mağaza içi satın alma, abonelik doğrulama, iptal, geri yükleme | Yok (paket, hesap, anahtar yok) | ❌ | IAP entegrasyonu + sunucu tarafı bildirim (Apple/Google) + yetki eşitleme | 10–15 |
| 2 | Paket/yetki sistemi (modül, Tam, Aile 2/3, mahsup) | `is_premium` + `plans` (TRY, sure_gun) | ❌ | plan→modül eşlemesi, çocuk sayısı sınırı, istemci kapıları (mobil+web), mahsup | 8–10 |
| 3 | Kartsız 14 gün deneme, self-serve | `20261125000000_kartsiz_deneme_kayitta.sql` + test var; B-18 hukuk bekliyor | 🟡 | uzak DB durumu, UI, deneme sonu davranışı, 7 vs 14 gün testi | 3–5 |
| 4 | Haftalık veli raporu (kahraman özellik), rapor açma olayı, birleşik rapor | Veli paneli sayfaları (aktivite, hedefler, okuma dünyası, dersler, tekrar, başarılar); admin growth rapor taslak/zamanlı | 🟡 | veliye otomatik haftalık özet (e-posta/push), "neyi öğrendi / neye tekrar", `rapor_acildi` olayı, modül bazlı kapsam | 6–8 |
| 5 | Kuzey yıldızı HMA, KPI panosu, K1–K4 kapıları | `growth_kohort_cac`, `growth_analitik`, `buyume_ozeti`, A/B motoru (`ab_deney/karar/olay`) | 🟡 | HMA tanımı + olay doğrulama (B-15), ARR/CAC/D7/deneme→ücretli kartları, kapı göstergeleri | 3–4 |
| 6 | UTM ilk temas, kanal atfı | `20261127000000_hane_ilk_temas_utm.sql` + `utm.ts`, `kaynak.ts` (commit'siz) | 🟡 | commit/uygulama, B-6/B-7 | 2–3 |
| 7 | Bekleme listesi (≥1.000 izinli), KVKK/İYS | İletişim izni ve ticari ileti izni sayfaları, tablo/sayfa **bekleme listesi yok** | 🟡 | bekleme listesi sayfası+tablosu, izin kaydı, davet sırası, erken erişim | 2–3 |
| 8 | Ücretsiz web araçları: Sınıfına Göre Öğrenme Kontrolü, açık hikâye+3 etkinlik, 7 günlük çarpma, 4→5 mini deneme, kelime oyunu | `okuma/sinif-okuma-anlama`, `okuma-demo`, `demo`, `deneme-sinavi-kayit` | 🟡 | çok modüllü Öğrenme Kontrolü, sonuç ekranı ("güçlü/tekrar"), "e-postayla kaydet", çarpma ve 4→5 araçları, kayıtsız başla→hesaba bağla | 15–20 |
| 9 | Kapalı beta 30–50 aile | `admin_deneme_baslat`, anketler, kullanıcı yönetimi | 🟡 | beta kohort etiketi, D7/rapor açma ölçümü, geri bildirim formu | 2–3 |
| 10 | Segmente göre paywall, "Kaç çocuğunuz var?" seçici, fiyat sayfası | `PlanKarti`, `MembershipView`, A/B motoru | 🟡 | paket kartları, segment girişi, aile seçici, kampanya fiyatı (mağazada tanıtım teklifi/promo kodu) | 5–7 |
| 11 | Lansman kampanyası (ilk yıl indirimi, "Karne Hediyesi") | `kuponlar`, `kampanyalar` sayfaları | 🟡 | mağaza fiyatlarında kupon çalışmaz; Apple tanıtım teklifi/Google promo kodu ile eşleme | 2–3 |
| 12 | E-posta yolculuğu (Gün 3/7/12/14/30), izinli liste | `eposta-gonder`, `journey-otomasyonlari`, `mesaj-sablonlari` | 🟡 | B-19 yürütme katmanı (cron, sıklık, sessiz saat, günlük) | 6–8 |
| 13 | SEO: robots/sitemap/OG/JSON-LD, 48 sayfa, 4 küme | `site-icerik` admin; B-3 açık, GÖR-038 footer | 🟡 | teknik SEO (B-3), içerik şablonu/CMS yolu, bağlantılar | 4–6 |
| 14 | Mağaza hazırlığı (Kids/Families, ASO, ekranlar, puan isteği, smart banner) | `mobile-app/store/` kontrol listesi, GÖR-010/083 | ❌ | hesaplar, imza, veri güvenliği formu, çocuk kategorisi kuralları (R-2), B-10/B-11 | 5–7 (+ kullanıcı) |
| 15 | Ortaklık (20 ortak, UTM bağlantı, işbirliği ibaresi) | kupon, UTM, hane kaynak | ❌ | **Ortak Lite**: bağlantı üretici, ortak başı kayıt/atıf sayısı, işbirliği ibaresi şablonu; ödemesiz | 4–6 |
| 16 | Veli referansı (doğrulanmış davet → 2 aileye 7 gün) | Yok | ❌ | davet kodu/bağlantı, doğrulama, kötüye kullanım kontrolü | 5–7 |
| 17 | Kurum lisansı (5 pilot) | Yok (sınıf/kurum kavramı lisans için yok) | ❌ | kurum hesabı, toplu davet, lisans süresi, veli raporu paylaşımı | 10–12 |
| 18 | Paylaşılabilir karne / Yılın Özeti / Yaz Okuma Kulübü | `gorevler`, `rozetler`, `ligler` | 🟡 | paylaşılabilir özet kartı, kulüp görevi/rozeti | 6–8 |
| 19 | İptal nedeni, yenileme ekranı, churn analizi | `elde-tutma`, `anketler` | 🟡 | IAP iptal olayı/anketi, "bu ay neler öğrendi" | 4–5 |
| 20 | Çocuk güvenliği (üçüncü taraf reklam SDK yok, hukuk teyidi) | Sentry, FCM kullanılıyor | 🟡 | mobilde üçüncü taraf SDK envanteri, çocuk kategorisi uyumu | 2–3 |

## 3. Mimari kararlar (önerilen)
1. **Satın alma:** Mağaza içi satın almayı hazır abonelik hizmetiyle (ör. RevenueCat) yapmak, kendi Apple/Google doğrulamasını yazmaktan çok daha kısa sürer; ücretsiz kota ve %1 eşiği kaynakta doğrulandı (aylık gelir 2.500 $ üstü). Çocuk kategorisinde üçüncü taraf SDK kısıtı doğrulanmalı (R-2). Karar: **kullanıcı**.
2. **Yetki modeli:** `plans` yanında `plan_modulleri(plan_kod, modul)` ve `subscriptions`'a kaynak (`magaza|web|deneme|kurum|beta`) + çocuk sayısı sınırı. Tek sunucu fonksiyonu `has_access(uid, modul)`; mobil ve web yalnız onu çağırır. Veri modeli modül-hazır, vitrin başta yalnız Tam + Aile.
3. **Fiyat tek kaynak:** TL fiyat mağaza fiyat noktaları olarak ayrıca tutulur; `plans.fiyat_kurus` yalnız gösterim/web. Çifte kaynak riskine karşı paket kodu ortak anahtar.
4. **Rapor üretimi:** mevcut ilerleme olaylarından haftalık toplulaştırma (SQL) → şablon → izinli e-posta/push; "açıldı" olayı HMA'yı besler. Çocuk adı gerekmeden.
5. **Ortak Lite:** UTM + hane kaynak üzerine, ödemesiz; tam ortak paneli ve komisyon şirket kararına kadar ertelenir.

## 4. Sıralama ve kapasite
Toplam eforu tablodaki alt sınırlarla toplarsak lansman öncesi (satır 1–14, 20) ~65–90 iş günü; takvimde 2 Kasım–31 Ocak = ~55 iş günü ve pazarlama ritmi de kurucuda. Kapsam kesintisi şart.

**Lansman (22 Ocak) için asgari kapı:** (A) satın alma + yetki: Tam (aylık/yıllık) + Aile; (B) 14 gün deneme; (C) bekleme listesi; (D) 2 ücretsiz araç: Öğrenme Kontrolü + açık hikâye; (E) veli raporu v1; (F) ölçüm + HMA; (G) mağaza hazırlığı; (H) teknik SEO.
**Lansman sonrasına:** modül paketleri (K2'ye kadar), çarpma/4→5 araçları, Ortak Lite (Mart), referans (Temmuz), kurum (Ağustos), paylaşılabilir karne (Haziran), yılın özeti (Aralık).

| Plan haftası | Sistem işi | Sahip |
|---|---|---|
| 1 (2–8 Kas) | Kararlar (§5), ölçüm sözlüğü + UTM commit, bekleme listesi + izin, mağaza hesapları ve imza anahtarı başlat | Kullanıcı + ana oturum |
| 2–3 | Yetki modeli + paket şeması; IAP entegrasyonunun başlaması; veli raporu v0; beta kohort etiketi | Ana oturum |
| 4–6 | IAP uçtan uca (sandbox), paywall + Aile seçici; Öğrenme Kontrolü; haftalık rapor; kartsız deneme tamamla | Ana oturum + MAR-OTO-AI |
| 6–7 (7–20 Ara) | Mağaza gönderimi (Kids/Families, veri güvenliği formu); teknik SEO | Kullanıcı + ana oturum |
| 8–9 | Lansman e-posta serisi (izinli), kampanya eşlemesi (mağaza tanıtım teklifi), yumuşak açılış | MAR-OTO-AI |
| 10–13 | Hata düzeltme, KPI panosu, 90 gün değerlendirmesi | Ana oturum |
Bağımlılık: 7. hafta gönderimi için IAP ve yetki 6. haftada sandbox'ta geçmiş olmalı; mağaza onayı gecikirse web sürümü yedek kanal (plan riski), bu da ödeme yolu kararına bağlı.

## 5. Kararlar (en çok bu hafta)
1. Lansman satın alma yolu: yalnız mağaza (şirketsiz) mı, web ödemesi de mi (şirket)?
2. IAP: hazır abonelik hizmeti mi, kendi doğrulama mı?
3. Lansman paket kapsamı: yalnız Tam + Aile mi, modül paketleri baştan mı?
4. Fiyat: plan (199/1.599) mi, bizim hesap (149/1.199 civarı) mı; mağaza fiyat noktaları doğrulansın.
5. Kids/Families kategorisi mi, genel kategori mi (SDK ve analitik kısıtlarını belirler).
6. Mağaza hesapları + imza anahtarı: ne zaman (bu hafta başlamazsa 14 Aralık kayar).
7. Kurumsal e-posta alan adı: `.com.tr` mi `.com` mu.

## 6. Yapılmayacak / sonraya
Tam ortak paneli ve komisyon ödemeleri, okul programı, çok dilli genişleme, LGS içerikleri (plan: 2028).
