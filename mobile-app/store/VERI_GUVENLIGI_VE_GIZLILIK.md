# Veri Güvenliği (Data Safety / App Privacy) Formu ve Gizlilik Politikası

Sürüm: 2026-10-29 (yeniden yazıldı; önceki sürüm Sentry, Cloudflare Turnstile, satın alma ve meydan okuma özelliklerini içermiyordu — GÖR-083)
DURUM: Teknik hazırlıktır, HUKUKİ TAVSİYE DEĞİLDİR. Formdaki her yanıt sizin hukuki beyanınızdır; yayından önce KVKK uzmanı bir avukata gösterin.

## 0) Bu belgenin kapsamı ve sınırları
- Kaynak: `mobile-app/pubspec.yaml`, `lib/auth/signup.dart`, `lib/auth/turnstile.dart`, `lib/services/error_reporting.dart`, `lib/services/push/*`, `lib/services/quiz_repository.dart` (RPC listesi), `supabase/migrations/20261107000000_giris_olaylari.sql`, `web-panel/src/lib/legal/content.ts`.
- Bu belge **mobil uygulamayı** kapsar. Web paneli (veli paneli, landing) ayrı bir gizlilik beyanıdır ve `content.ts` içinde tutulur.
- İki sürüm vardır: **A) Şu anki kod** ve **B) Satın alma sürümü** (Qonversion eklenince geçerli). Mağazaya hangi sürüm gidiyorsa o sütunun yanıtları girilir. Yanlış sürümün yanıtı mağazadan kaldırılma sebebidir.
- Doğrulanamayanlar §8'de listelenir. Orada "doğrulanmalı" yazan hiçbir satır kesin beyan olarak girilmemeli.

## 1) Gizlilik politikası URL'si (ZORUNLU)
Hem Google Play hem App Store herkese açık bir web adresinde yayınlanmış gizlilik politikası ister (giriş gerektirmeyen sayfa). Mobilde çocuğa gösterilen sade metin `lib/content/privacy_notice.dart` içindedir ve TASLAKTIR (`kPrivacyNoticeVersion` ile sürümlenir). Yapılacaklar:
1. KVKK avukatı taslağı inceler (veri sorumlusu kimliği, işleme amaçları, saklama süresi, yurt dışına aktarım dayanağı, çocuk verisi için veli rızası, başvuru yolları).
2. Onaylanan tam metin `hupolingo.com` altında herkese açık yayınlanır (`/gizlilik`). Aynı adres Play Console ve App Store Connect'e girilir.
3. Metin değişirse `kPrivacyNoticeVersion` artırılır ve web sayfası güncellenir.
4. Sayfada iletişim e-postası (`@hupolingo.com` alan adlı) ve **web üzerinden hesap silme talebi** yolu bulunur (Google bunu ister; uygulama içi "Hesabımı sil" `delete_my_account` ile ayrıca vardır).

## 2) Veri envanteri (kodla kanıtlı)
| Veri | Nerede toplanıyor | Kanıt | Saklandığı yer |
|---|---|---|---|
| Ad (`full_name`), e-posta, parola (hash) | Kayıt | `lib/auth/signup.dart` (`signUp(... data: full_name, role)`) | Supabase Auth |
| Rol (öğrenci), sınıf (`set_my_grade`), veli eşleştirme kodu | Kayıt ve profil | `quiz_repository.dart` (`redeem_parent_link_code`, `set_my_grade`) | Supabase |
| Uygulama içi etkileşim: cevaplar, XP, seviye, seri, rozet, günlük hedef, görev, deneme sonucu, yer imi, soru bildirimi | Kullanım | `quiz_repository.dart` RPC'leri (`submit_answer`, `start_mock_exam`, `toggle_bookmark`, `report_question`...) | Supabase |
| Meydan okuma (arkadaşla yarışma): katılım ve sonuç | Kullanım | `create_challenge`, `join_challenge`, `submit_challenge` | Supabase |
| Anket yanıtı | Kullanım | `anket_yanit_gonder` | Supabase |
| Başarılı giriş olayı (kullanıcı kimliği, rol, kanal, zaman; IP ve e-posta tutulmaz; 180 gün) | Giriş | `20261107000000_giris_olaylari.sql` | Supabase |
| Bildirim belirteci (FCM) ve bildirim tercihi | Bildirim izni verilirse | `lib/services/push/*` (`register_device_token`) | Supabase + Google (FCM) |
| Hata raporu: hata türü, cihaz/işletim sistemi bilgisi; kişisel veri, mesaj metni ve breadcrumb temizlenir | Çökme | `lib/services/error_reporting.dart` (`sendDefaultPii=false`, `beforeSend` temizliği) | Sentry |
| Bot kontrolü: tarayıcı/cihaz sinyalleri ve IP, kayıt sırasında | Kayıt (WebView) | `lib/auth/turnstile.dart` (`challenges.cloudflare.com`) | Cloudflare |
| Okuma Dünyası kişiselleştirme (çocuğun yazdığı ad, kahraman seçimi), PDF çıktı | Yalnız cihazda | `okuma_cihaz_deposu.dart` ("Yalnız bu cihazda tutulur; sunucuya gönderilmez") | Cihaz |
Toplanmayanlar: konum, kişiler, mikrofon/kamera, fotoğraf, finansal bilgi (A sürümünde), sağlık, mesajlaşma, tarama geçmişi, reklam kimliği.

## 3) Üçüncü taraflar (işleyen / SDK)
| Taraf | Rol | Sürüm | Not |
|---|---|---|---|
| Supabase | Veritabanı, kimlik doğrulama | A, B | Veri işleyen; sunucu bölgesi aktarım dayanağı için yazılı teyit |
| Firebase Cloud Messaging (Google) | Bildirim | A, B | Yalnız `firebase_core` + `firebase_messaging`; analitik paketi yok. SDK'nın kurulum kimliği (Installations) topladığı doğrulanmalı |
| Sentry | Hata izleme | A, B | Kişisel veri temizlenir; yine de cihaz/OS bilgisi gider |
| Cloudflare Turnstile | Bot koruması | A, B | IP ve tarayıcı sinyalleri Cloudflare'a gider |
| Qonversion | Satın alma, abonelik doğrulama | **B** | Kullanıcı kimliği ve cihaz kimliği toplar (kaynak: Qonversion Google Play Data Safety rehberi); ücretsiz kota ve çocuk kategorisi uyumu doğrulanmalı |
| Apple App Store / Google Play Faturalandırma | Ödeme | **B** | Kart bilgisi Hupolingo'ya ulaşmaz |
| PayTR / Param (web) | Web ödemesi | Web (mobil kapsam dışı) | Mobil uygulama bu sağlayıcıları çağırmaz; çocuk ekranında ödeme yok |
Sunucu tarafı e-posta (Brevo, Resend) ve analitik (PostHog, yalnız web ve onayla) mobil SDK değildir; gizlilik politikasında işleyen olarak yazılır (`web-panel/src/lib/legal/content.ts`).

## 4) Google Play — Veri Güvenliği formu
**Genel:** Veri topluyor: Evet. Aktarımda şifreleme: Evet (TLS). Silme talebi: Evet (uygulama içi "Hesabımı sil" + web talep sayfası). Üçüncü tarafla paylaşım: Hayır, **şu varsayımla**: Supabase, FCM, Sentry, Cloudflare ve (B'de) Qonversion Google'ın "hizmet sağlayıcı" tanımına girer ve verileri kendi amaçları için kullanmaz. Bu sınıflandırma avukat ve her sağlayıcının sözleşmesiyle teyit edilmeli (§8).

| Kategori / Tür | A | B | Amaç | Zorunlu mu | Paylaşım |
|---|---|---|---|---|---|
| Kişisel bilgi > Ad | Evet | Evet | Hesap yönetimi, uygulama işlevi | Zorunlu | Hayır |
| Kişisel bilgi > E-posta | Evet | Evet | Hesap yönetimi, uygulama işlevi | Zorunlu | Hayır |
| Kişisel bilgi > Kullanıcı kimlikleri (hesap kimliği) | Evet | Evet | Uygulama işlevi | Zorunlu | Hayır |
| Uygulama etkinliği > Uygulama içi etkileşimler | Evet | Evet | Uygulama işlevi, kişiselleştirme | Zorunlu | Hayır |
| Uygulama bilgisi ve performansı > Çökme günlükleri | Evet | Evet | Uygulama işlevi, analiz | Zorunlu | Hayır |
| Uygulama bilgisi ve performansı > Tanılama | Evet | Evet | Analiz | Zorunlu | Hayır |
| Cihaz veya diğer kimlikler (bildirim belirteci; B'de satın alma cihaz kimliği) | Evet | Evet | Uygulama işlevi (bildirim; satın alma doğrulama) | Bildirim isteğe bağlı | Hayır |
| Finansal bilgi > Satın alma geçmişi | Hayır | Evet | Uygulama işlevi (abonelik doğrulama) | Zorunlu (satın alan için) | Hayır |
Güvenlik uygulamaları: aktarımda şifreleme, silme yolu, satır düzeyi güvenlik (RLS).
Hedef kitle ve içerik: çocuklara yönelik uygulama ise Aileler Politikası geçerlidir (§6).

## 5) Apple — App Privacy ("Veri Toplama")
- İletişim bilgisi: ad, e-posta — Uygulama işlevi, hesaba bağlı.
- Tanımlayıcılar: kullanıcı kimliği; cihaz kimliği (bildirim belirteci; B'de satın alma) — Uygulama işlevi.
- Kullanım verisi: ürün etkileşimi — Uygulama işlevi, hesaba bağlı.
- Tanılama: çökme verisi, performans verisi — Analiz, hesaba bağlı değil (kişisel veri temizlenir).
- Satın alımlar: satın alma geçmişi — yalnız B sürümünde.
- Takip (Tracking): **Hayır** — bu yanıt Qonversion'ın atıf entegrasyonları (reklam ağı, Apple Search Ads vb.) **kapalı** kalırsa ve ATT istemi kullanılmazsa geçerlidir. Bu ayarlar kodda ve Qonversion panelinde kapalı tutulacak; sürüm kontrolünde doğrulanacak.
- Apple, SDK'lar için "Privacy Manifest" ister; Qonversion, Firebase ve Sentry manifestleri build raporundan (Xcode "Privacy Report") doğrulanır.

## 6) Çocuklara özel kararlar (yayın öncesi verilmeli)
1. **Hedef kitle:** Play Console "Hedef kitle ve içerik" (13 yaş altı seçilirse Aileler Politikası) ve App Store "Kids" kategorisi kararı. Bu karar hangi SDK'ların kullanılabileceğini belirler (backlog R-2). Karar verilmeden form kesinleşmez.
2. **Satın alma yolu:** çocuk ekranında fiyat, ödeme veya dış bağlantı yok (K-0196, GÖR-081). Satın alma veli kapısının arkasında. B sürümünde Qonversion SDK'sı yalnız veli kapısı geçildikten sonra başlatılmalı ve anonim kimlikle çalışmalı (çocuk adı/e-postası SDK'ya verilmez).
3. **Reklam ve takip:** üçüncü taraf reklam SDK'sı yok; reklam kimliği kullanılmıyor.
4. **Sosyal özellikler:** meydan okuma yalnız sonuç/katılım; serbest metin ve sohbet yok (kodla doğrulandı: `create_challenge`, `join_challenge`, `submit_challenge` yalnız kimlik/sonuç taşır — migration içeriği tam okunmadı, §8).
5. **Veli onayı:** `record_notice_read`, `set_parental_consent`; hangi yaşta hangi rızanın gerektiği avukat tarafından teyit edilir.

## 7) Satın alma sürümü (B) için yapılacaklar
- [ ] Qonversion hesabı ve SDK; atıf/reklam entegrasyonları kapalı; kimlik anonim.
- [ ] Qonversion gizlilik manifesti ve veri işleme sözleşmesi (DPA) incelenir; çocuk kategorisi uyumu yazılı teyit.
- [ ] Qonversion'dan gelen abonelik olayları Supabase'e yazılır; **erişim kararı Supabase'dedir**, uygulama yetkiyi yalnız Supabase'den okur.
- [ ] Bu belgenin B sütunu mağaza formlarına girilir; A sütunu girilmez.
- [ ] `web-panel/src/lib/legal/content.ts` ödeme bölümleri sağlayıcı değişikliğine (iyzico → PayTR/Param) göre güncellenir (şimdi iyzico yazıyor, satır 60, 105, 243, 358, 381).

## 8) Doğrulanamayanlar ve avukata/sağlayıcıya sorular
1. Qonversion çocuk odaklı uygulamalarda (Kids / Aileler) kullanılabilir mi, COPPA/KVKK konumu nedir? (Kaynaklarda bulunamadı.)
2. Qonversion ücretsiz kota eşiği: kaynaklar $10K ve $7K veriyor; `qonversion.io/pricing` kontrol edilmeli.
3. FCM SDK'sı Firebase kurulum kimliği topluyor mu ve formda ayrı satır gerekir mi?
4. Sentry olayına cihaz/OS bilgisinden başka bir şey gidiyor mu (sürümde ağ trafiği izlenerek doğrulanır)?
5. Turnstile'ın topladığı sinyaller "Cihaz kimliği" olarak beyan gerektirir mi?
6. Supabase sunucu bölgesi ve yurt dışına aktarım dayanağı (KVKK m.9).
7. Meydan okuma migration'ları (`20261010000000_meydan_okuma.sql` vb.) serbest metin alanı içermiyor mu? (Tam okunmadı.)
8. Hedef kitle kararına göre Aileler Politikası kapsamında SDK listesinin Google'a bildirilmesi gerekir mi?

## 9) Güncelleme kuralı
Her yeni SDK, analitik, ödeme veya veri alanında bu belge ve mağaza formları birlikte güncellenir. Yeni migration ile kullanıcı verisi alanı eklendiyse §2 tablosuna satır eklenir.
