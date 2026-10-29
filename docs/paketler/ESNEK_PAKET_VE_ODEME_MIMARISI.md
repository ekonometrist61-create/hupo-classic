# Esnek paket sistemi ve ödeme mimarisi (Qonversion + Supabase + PayTR/Param)

Tarih: 2026-10-29 · Durum: TASARIM (kod/migration yok; onay sonrası dilimlenir)
Kararlar (kullanıcı, 2026-10-29): mağaza hesapları en son açılır; satın alma yolu esnek, iyzico zorunlu değil; mobil Qonversion, web PayTR/Param, erişim kararı Supabase; paketler admin panelinden düzenlenir; her yeni modülde "hangi pakete nasıl yansır" kural olarak sorulur; lansman tüm paketlerle; fiyatlar pazarlama planındaki gibi; kurumsal e-posta `.com`.

## 1. İlke
1. **Erişimin tek kaynağı Supabase.** Mobil ve web yalnız `has_access(modul)` çağırır. Qonversion, PayTR, Param, iyzico, deneme, beta, kurum: hepsi "abonelik kaynağı"dır; yetkiyi Supabase'e yazar.
2. **Paket = veri.** Paket, modül matrisi, kota, çocuk sınırı, rapor kapsamı ve fiyat panelden değişir; kod değişmez.
3. **Fail-closed.** Karar verilmemiş modül/paket kombinasyonu erişim vermez.
4. **Kazanılmış hak.** Satın alma anındaki paket sürümü, kullanıcıda geçerli kalır; değişikliğin mevcut abonelere uygulanması her değişiklikte açık seçimdir.

## 2. Veri modeli (öneri)
| Tablo | Amaç | Ana alanlar |
|---|---|---|
| `moduller` | Modül kataloğu | `kod`, `ad`, `durum` (`taslak`/`yayinda`/`arsiv`), `sira` |
| `paketler` | Paket tanımı | `kod`, `ad`, `tur` (`ucretsiz`/`modul`/`tam`/`aile`/`kurum`/`deneme`/`beta`), `cocuk_siniri`, `rapor_kapsami` (`modul`/`birlesik`), `yenileme_modu` (`manuel`/`otomatik`), `gorunur`, `vurgulu`, `sira`, `durum`, `surum` |
| `paket_modul` | Matris (panelde düzenlenen) | `paket_kod`, `modul_kod`, `erisim` (`tam`/`sinirli`/`onizleme`/`yok`), `gunluk_kota`, `kisit jsonb` |
| `paket_fiyat` | Kanal bazlı fiyat/ürün | `paket_kod`, `kanal` (`apple`/`google`/`web`), `periyot`, `fiyat_kurus`, `magaza_urun_kodu`, `qonversion_urun`, `aktif` |
| `paket_gecis` | Yükseltme/düşürme | `kaynak_paket`, `hedef_paket`, `mahsup` (`orantili`/`yok`) |
| `paket_surum` | Her yayında anlık görüntü | `paket_kod`, `surum`, `matris jsonb`, `yayin_tarihi` |
| `modul_paket_karar` | Yeni modül kuralı | `modul_kod`, `paket_kod`, `karar` (`dahil`/`sinirli`/`haric`/`yeni_paket`), `mevcut_aboneleri_kapsar`, `gerekce`, `karar_veren`, `tarih` |
| `subscriptions` (mevcut, genişler) | Abonelik | + `kaynak` (`apple`/`google`/`paytr`/`param`/`iyzico`/`deneme`/`beta`/`kurum`/`manuel`), `paket_kod`, `paket_surum`, `saglayici_ref` |
`payments.saglayici` alanı zaten var; sağlayıcı adaptörleriyle genelleşir. `plans` tablosu geçişte `paketler` + `paket_fiyat`'a eşlenir (eski satırlar korunur; TRY kısıtı kanal fiyatında kalır).

`has_access(uid, modul)`: kullanıcının aktif aboneliklerinin (paket sürümüne göre) matrisinden en yüksek erişim + kota; aktif abonelik yoksa `ucretsiz` paketi; deneme aktifse deneme paketi. Çocuk sayısı sınırı `veli_cocuk_bagla`'da denetlenir.

## 3. Yeni modül kuralı ("sor, sonra ilerle")
1. Admin "Yeni modül" ekler → `durum=taslak`. Taslak modül hiçbir pakete erişim vermez.
2. Panel, **her aktif paket için** zorunlu soru gösterir: *Bu modül [paket] içinde: dahil / sınırlı / hariç? Mevcut aboneler de kapsansın mı? Ayrı yeni paket mi olsun?*
3. Etki önizlemesi: kaç aktif abone etkilenir, hangi paketin modül sayısı/fiyat mantığı değişir, "Tam paket modül toplamından ucuz olmalı" kuralı ihlal ediliyor mu (paketleme kuralı: iki tek modül < Tam).
4. `modul_yayinla(modul)` RPC'si, tüm aktif paketlerde karar yoksa **hata verir**; yetki kontrolü + `log_admin_action`.
5. Yayınlanınca `paket_surum` anlık görüntüsü yazılır. `mevcut_aboneleri_kapsar=evet` ise ilgili abonelerin paket sürümü yükseltilir, hayırsa yeni satın almalar yeni sürümü alır.
6. "Yeni paket" seçilirse paket sihirbazı açılır (modüller, kota, fiyat, mağaza ürünü eşlemesi) ve paket `taslak` kalır.
Aynı kural modül arşivleme ve paket silme için de çalışır (aktif abonesi olan paket silinemez, yalnız arşivlenir).

## 4. Admin paneli ekranları (`/yonetim/paketler`, mevcut `planlar` ekranı yerine)
1. **Paket listesi + matris:** satır = modül, sütun = paket; hücre = erişim/kota; taslak/yayında rozetleri; "yayınla" onayı etki önizlemesiyle.
2. **Paket detayı:** çocuk sınırı, rapor kapsamı, yenileme modu, görünürlük, vurgu, sıralama; kanal fiyatları tablosu.
3. **Mağaza eşleşme durumu:** her `paket_fiyat` satırı için Apple/Google ürün kodu ve Qonversion ürünü var mı/eşleşiyor mu; eşleşmeyen kanal "satışa kapalı" görünür (sapma uyarısı).
4. **Modül sihirbazı** (§3) ve **geçiş kuralları** (mahsup).
5. **Denetim günlüğü:** kim, ne zaman, hangi değişikliği yayınladı; geri alma = önceki sürümü yeniden yayınla.
**Sınır (dürüst not):** Panel bileşimi (modül, kota, çocuk sınırı, rapor) ve web fiyatını anında değiştirir. Apple/Google fiyatı ve ürün tanımı mağaza konsollarında değişir; panel bunları yalnız eşler ve sapmayı gösterir. Mağaza fiyat noktaları sabit kademelerdir; 199/1.599 gibi tutarların ₺199,99 vb. olabileceği konsol açılınca doğrulanır.

## 5. Ödeme mimarisi
```
Mobil (Qonversion SDK, veli kapısı)      Web (veli paneli)
        │ mağaza satın alma                   │ PayTR / Param ödeme sayfası
        ▼                                     ▼
 Qonversion ──webhook──► Edge fn            Sağlayıcı callback ──► Edge fn
                    qonversion-webhook          odeme-callback (adaptör)
                          └────────────┬────────────┘
                                       ▼
                     Supabase: payments + subscriptions (+paket_surum)
                                       ▼
                         has_access(modul)  ← mobil + web okur
```
- **Sağlayıcı adaptörü:** tek arayüz (`olustur`, `dogrula`, `iade`); iyzico mevcut, PayTR ve Param eklenir; hangi web sağlayıcısının aktif olduğu `app_settings` ile seçilir. Tutar sunucuda `paket_fiyat`'tan hesaplanır, istemciden alınmaz (mevcut ilke).
- **Webhook güvenliği:** imza doğrulama, idempotency (sağlayıcı olay kimliği benzersiz), yeniden oynatma koruması, tüm olaylar `odeme_olaylari` tablosuna ham kayıt (PII'siz).
- **Qonversion'ın rolü:** mağaza faturalama ve abonelik olayı; **yetki kararı vermez**. Uygulama yetkiyi Supabase'den okur, böylece web ve mağaza satın almaları aynı yerde birleşir.
- **Çocuk yüzeyi:** fiyat, ödeme ve dış bağlantı yok (K-0196, GÖR-081); SDK yalnız veli kapısından sonra, anonim kimlikle başlatılır.
- **Yenileme:** `yenileme_modu` paketten gelir; otomatik yenileme hukuk onayı olmadan açılmaz (karar K-0196 tek seferlik; mağaza ürünleri yenilenen/yenilenmeyen abonelik olarak ayrı seçilir).

## 6. Lansman kataloğu (pazarlama planı, KDV ve komisyon öncesi liste fiyatı)
| Paket | Aylık | Yıllık | Modüller | Rapor |
|---|---|---|---|---|
| Ücretsiz | 0 | 0 | araçlar, günde 1 mini görev, son oturum kısa veli özeti | özet |
| HupoRead | 119 | 899 | Okuma | yalnız okuma |
| Soru | 119 | 899 | Soru-Cevap + Deneme | yalnız soru/deneme |
| Tam (1 çocuk) | 199 | 1.599 | tüm modüller + Çarpma + Kelime Evreni | birleşik |
| Aile (2 çocuk) | 299 | 2.399 | Tam, 2 çocuk | birleşik |
| Aile (3 çocuk) | 399 | 2.999 | Tam, 3 çocuk | birleşik |
Lansman teklifi (22 Ocak–8 Şubat): Tam yıllık ilk yıl 1.199; mağazada tanıtım teklifi, webde kupon (`coupons`) ile; bitiş tarihi sabit, sahte geri sayım yok. 14 gün deneme: `deneme` paketi (kartsız, sunucu tarafı). Modülden Tam'a geçişte kalan süre `paket_gecis.mahsup=orantili`.
Birim ekonomi notu: bu fiyatlarla (aynı varsayımlarla) ortalama net abone geliri önceki 1.199'luk yapıya göre ~%30 yüksek; başabaş abone sayısı yaklaşık %24 düşer (59 $ basamağında ~45 → ~34), ancak yüksek fiyat dönüşümü düşürebilir; K2 kapısında gerçek veriyle test (planın 1.599/1.399 A/B'si).

## 7. Engeller ve açık noktalar
1. **PayTR/Param için vergi mükellefi gerekir** (şahıs işletmesi/şirket; kaynaklarda bireysel vergi kaydı olmayan başvuru görünmüyor; abonelik/yinelenen ödeme izni sağlayıcıya yazılı sorulmalı). Web ödemesi gerçek tahsilata ancak işletme açılınca geçer; mimari bunu beklemeden sağlayıcı-bağımsız kurulur. Mağaza yolu işletmesiz çalışabilir (vergi tarafı SMMM'ye).
2. **Qonversion:** çocuk kategorisi uyumu ve ücretsiz kota eşiği ($10K/$7K) doğrulanmadı; alternatif RevenueCat. Karar: Qonversion kalır, Veri Güvenliği §8 maddeleri teyit edilir.
3. **Mağaza hesapları en son** olduğundan mobil satın alma gerçek cihazda ancak sonra sınanır; o zamana kadar sandbox yok. Mobil tarafta Qonversion entegrasyonu hesaplar açılmadan "kapalı" bayrakla geliştirilir; lansman takvimi (mağaza gönderimi 14–20 Aralık) hesap açma süresine bağlıdır (Apple geliştirici onayı ve Google kimlik doğrulaması günler sürebilir).
4. Çifte kaynak: web fiyatı `paket_fiyat`, mağaza fiyatı konsol; sapma uyarısı ve aylık mutabakat.
5. Hukuk: ön bilgilendirme ve cayma metni (GÖR-078), otomatik yenileme dili, ödeme sağlayıcısı değişince `content.ts` güncellemesi.

## 8. Dilimler (tahmini iş günü; migration onayı her dilimde ana oturumda)
| Dilim | İçerik | Kabul kriteri | Efor |
|---|---|---|---|
| P1 | `moduller`, `paketler`, `paket_modul`, `paket_surum`, `has_access`, `plans` göçü, mevcut `is_premium` yerine köprü | Mevcut kullanıcılar aynı erişimi korur; RLS/negatif testler; fail-closed | 5–6 |
| | **DURUM (2026-10-29): UZAK DB'YE UYGULANDI (test ortamı; `db push --include-all`, 9 migration: 20261108 → 20261130). `20261127` çakışması için `deneme_sinav_kapisi` → `20261127000001` olarak yeniden adlandırıldı. Dry-run "up to date".** Önceki not: yazıldı, uygulanmadı. `supabase/migrations/20261130000000_paket_modul_erisim.sql` + `supabase/tests/paket_erisim/test.mjs` (PGlite 28/28). `has_access(uid, modul)` iç fonksiyondur (istemciye kapalı); istemci `my_access()` çağırır. `is_premium`/`my_subscription_status` değişmedi; `plans.paket_kod` boş olan eski satış kalemleri bugünkü premium gibi davranır. Fiyat eklenmedi; `plans.paket_kod` eşlemesi P3 panelinden yapılır. Açık: Deneme paketi tohumu "tam erişim" (plan) iken bugünkü kod günlük 20 soru veriyor; istemci kapıları (P4) gelmeden etkisiz. | | |
| | **MOBİL KOTA GÖSTERİMİ (2026-10-29): `20261135000000_kota_durumu.sql` UYGULANDI (test ortamı); `my_kota_durumu()` → modül başına {gunluk_kota, kullanilan, kalan}; PGlite 8/8. Mobil: `ModulKota`, `kotaDurumuProvider`, `KotaRozeti` (Kelime Evreni ve Deneme kartlarının altında). Kota 0 ya da tam erişimde rozet gizli. `flutter analyze` (9 dosya) temiz.** Soru ekranı mevcut quota göstergesini kullanıyor (kapsam dışı bırakıldı); Okuma ve Çarpma için giriş noktası kartı yok, rozet de yok. |
| | **TOHUM KARAR KAYITLARI (2026-10-29): `20261136000000_tohum_karar_kayitlari.sql` UYGULANDI (test ortamı).** Mevcut matristen 35 karar (5 modül × 7 paket) türetildi, idempotent, yönetici kararlarını ezmez. Canlı yönetici RPC'sinde doğrulandı: 35 karar, 5 modülün hepsi `yayinlanabilir=true`. PGlite 20/20 (`supabase/tests/tohum_karar`). **Yönetim formu:** karar verilmemişse boş seçim ("Seçin"), karar seçilmeden kaydet pasif. **Mobil rozet:** Okuma (`okuma_vitrin.dart`) ve Çarpma (`learn_screen.dart`, `home_screen.dart`) girişlerine `KotaRozeti` eklendi; `flutter analyze` hatasız (5 eski bilgi uyarısı `okuma_vitrin.dart`'ta). Tarayıcı/cihaz kontrolü yapılmadı. |
| | **UÇTAN UCA TARAYICI DENEMESİ (2026-10-29):** yönetici girişi + `/yonetim/paketler` + karar kaydetme gerçek tarayıcıda (Playwright) denendi. Deney: Aile (3 çocuk) × Kelime Evreni → "Sınırlı 15" kaydedildi, sayfa yeniden yüklenince matriste "Günlük 15" göründü; sonra "Dahil (tam)"e geri alındı ve API ile doğrulandı (matris `tam`, karar `dahil`, aile3 sürüm 1, 35 karar/28 hücre aynı; yalnız gerekçe notu "e2e deneme geri alındı" ve karar sahibi farklı). Bulunan ve düzeltilen iki hata: (1) modül değişince eski modülün formu birkaç saniye görünüyordu (yanlış kayıt riski): artık seçimde form temizleniyor ve eski isteğin yanıtı yok sayılıyor; (2) kayıttan sonra matris yenilenmiyordu: artık önizleme ve matris birlikte yenileniyor. Bu iki düzeltme tarayıcıda yeniden denenmedi (ESLint 0 hata, `tsc` temiz). Kaydet düğmesi çerez bandının altında kalıyordu (bantta "Reddet" ile kapatıldı); gerçek kullanıcı için ayrı bir UX notu. **Modül yayınlama denenmedi** (tüm modüller zaten yayında). Mobil: Çarpma rozeti yalnız Öğren sekmesinde kaldı (ana ekrandaki kaldırıldı). |
| | **YAYIN DENEMESİ VE DÜZELTMELER (2026-10-29): `20261137000000_modul_olustur_arsivle.sql` UYGULANDI (test ortamı).** `admin_modul_olustur` (taslak modül) ve `admin_modul_arsivle`; PGlite 16/16. Yönetim ekranına "Yeni modül" formu ve "Modülü arşivle" düğmesi eklendi. **Tarayıcıda uçtan uca doğrulandı:** (1) çerez bandı açıkken en alttaki "Kararı kaydet" tıklanabiliyor (bant görünürken sayfanın altına bant yüksekliği kadar boşluk bırakılıyor, `CookieConsent.tsx`); (2) modül değişince form hemen temizleniyor; (3) kayıttan sonra matris sayfa yenilenmeden güncelleniyor (Test Yayın × Tam: "Tam" → "—"); (4) bir paket kaydedilince diğer paketlerdeki kaydedilmemiş seçimler korunuyor; (5) taslak modül oluşturuldu, 7 pakette karar verildi, **yayınlandı** ("Etkilenen paket sayısı: 0") ve arşivlendi. Test sonrası: paket sürümleri değişmedi, 28 hücre aynı, `my_access`'te test modülü yok. Test izi: `test_yayin` modülü 'arsiv' durumunda ve 7 karar satırı kayıtlı (yönetim RPC'siyle silinemez, zararsız). Yayın düğmesi artık yalnız taslak modülde etkin. |
| | **P3 YÖNETİM SAYFASI (2026-10-29): yapıldı.** `/yonetim/paketler`: matris tablosu (`admin_paket_matris`), modül seçimi, etki önizlemesi (`admin_modul_etki_onizleme`), paket başına karar formu (`admin_modul_karar_kaydet`), modül yayını (`admin_modul_yayinla`). Menü: `adminNav` "Paketler". Metinler `yonetim-paketler.{tr,en}.json`. ESLint 0 hata (2 uyarı, mevcut `PlanlerSayfa` ile aynı deseni kullanıyor); `tsc --noEmit` temiz. Tarayıcıda yönetici girişi ile kontrol yapılmadı. |
| P3 | (veri katmanı) | **DURUM (2026-10-29): `20261132` test ortamına uygulandı; PGlite 14/14.** `admin_paket_matris`, `admin_modul_etki_onizleme`. Yönetim UI'si henüz yok. | | |
| P2 | Modül kuralı: `modul_paket_karar`, `modul_yayinla`, etki önizleme RPC'si | Kararsız modül yayınlanamaz; testle kanıtlı | 3–4 |
| | **DURUM (2026-10-29): yazıldı + PGlite 19/19; UZAK DB'YE UYGULANMADI** (`db push` izni reddedildi, dry-run: `20261131000000_modul_yayin_kurali.sql` bekliyor). Kurallar: `admin_modul_karar_kaydet`, `admin_modul_yayinla` (P0422 eksik karar). Etki önizleme RPC'si henüz yok (P3 paneline ait). |
| P3 | Admin paneli paketler ekranı + sihirbaz + denetim günlüğü | Ekran sözleşmesi, gerçek ekran kontrolü | 6–8 |
| | **P4 WEB (2026-10-29): yapıldı.** `web-panel/src/lib/paket/erisim.ts` (`modulErisimiGetir` → `my_access()`, fail-closed), `components/paket/ModulKapisi.tsx` (sunucu kapısı). Uygulandı: `ogrenci/deneme/[examId]` (gereken `tam`), `ogrenci/soru` (gereken `sinirli`). Metinler `paket-kapisi.{tr,en}.json`. ESLint ve `tsc --noEmit` temiz. Tarayıcı/e2e kontrolü yapılmadı. MOBİL YAPILMADI (ayrı tur). |
| P4 | Mobil/web istemci kapıları (`has_access`), paywall'da paket kartları, Aile seçici | Modül kilidi çalışır; çocuk ekranında fiyat yok | 5–7 |
| P5 | Ödeme adaptörü + PayTR/Param (sandbox) + callback genelleme | İdempotent, imzalı, tutar sunucuda | 5–7 |
| P6 | Qonversion webhook + abonelik eşleme + restore + iptal | Mağaza olayı yetkiyi günceller (hesap açılınca gerçek test) | 5–7 |
| P7 | Kartsız deneme paketi, kampanya/kupon eşleme, geçiş/mahsup | Plan KPI'larıyla uyumlu | 3–5 |
| | **ÜCRETSİZ DENEME FIRSATI (karar: proje sahibi, 2026-10-29): `20261134000000_ucretsiz_deneme_fircasi.sql` UYGULANDI (test ortamı).** Ücretsiz taban her ürün için 'sinirli': okuma 2, çarpma 40, soru 20, kelime evreni 30, deneme sınavı 1 (günlük). `deneme_sinir_tetik`: deneme penceresi legacy sınırları aynen; pencere dışında paket kotası; 'tam' sınırsız; diğer P0403. `deneme_sinav_kapisi`: deneme penceresi veya tam/sinirli erişim. PGlite 13/13 (`supabase/tests/ucretsiz_deneme`). İstemci kapıları Kelime Evreni ve Deneme için 'sinirli'e çekildi (mobil + web). Not: modül kotası yalnız deneme tetikleyicilerinde sunucuda; mobil/web kapıları seviyeye bakar, kotayı sunucu uygular. P1 testleri kendi zincirinde (20261134 yok) hâlâ geçerli; matris davranışı yukarıdaki kararla değişti. |
| | **DURUM (2026-10-29):** (a) Deneme paketi: `has_access` zaten `_deneme_aktif` okuyor (P1 testi). (b) Mahsup: `20261133000000_paket_gecis_mahsup.sql` → `my_gecis_mahsubu(hedef)` (salt okuma, orantılı, mevcut plan süresine göre); PGlite 11/11; **UZAK DB'YE UYGULANMADI** (onay bekliyor). (c) Kupon/mağaza promosyonu: P5 (checkout) ve P6 (Qonversion) bağımlı; yapılmadı. |
| | **P4 MOBİL (2026-10-29): yapıldı.** `models/paket_erisim_models.dart`, `QuizRepository.fetchMyAccess` (`my_access`, hata → kapalı), `modulErisimProvider`, `widgets/paket/modul_kapisi.dart` (satın alma/fiyat yok). Kapı: Kelime Evreni (`tam`), Deneme sınavları (`tam`), Soru (`sinirli`). `flutter analyze` (7 dosya) temiz; cihazda görsel kontrol yapılmadı. |
Toplam ~32–44 iş günü; lansman asgari yolu P1→P4→P6 (web ödemesi işletme açılana kadar P5 sandbox'ta kalır).

## 9. Bu mimariyle ilgili kararlar (KESİNLEŞTİ, 2026-10-29)
1. Paket değişikliğinin varsayılanı: yeni sürüm yalnız yeni satın almalara uygulanır; mevcut abonelere uygulamak her değişiklikte açık seçimdir (`mevcut_aboneleri_kapsar`).
2. Mağaza yolu işletmesiz başlar; web ödemesi (PayTR/Param) işletme açılınca devreye girer. Mimari sağlayıcı-bağımsız kurulur, web kanalı o zamana kadar `app_settings` ile kapalı kalır.
3. Kurumsal e-posta `.com`: `@hupolingo.com` (gizlilik, destek, mağaza iletişimi).
