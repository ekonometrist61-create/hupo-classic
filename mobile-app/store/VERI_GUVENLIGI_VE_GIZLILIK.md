# Veri Güvenliği (Data Safety) Formu ve Gizlilik Politikası

DURUM: Bu belge teknik bir hazırlıktır, HUKUKİ TAVSİYE DEĞİLDİR. Formdaki her yanıt sizin hukuki beyanınızdır; yayından önce KVKK uzmanı bir avukata gösterin.

## 1) Gizlilik politikası URL'si (ZORUNLU)

Hem Google Play hem App Store, **herkese açık bir web adresinde** yayınlanmış bir gizlilik politikası ister (giriş gerektirmeyen, PDF değil sayfa olması tercih edilir). Uygulama içindeki metin (`lib/content/privacy_notice.dart`) çocuklar için sade dille yazılmış bir **TASLAKTIR** ve kod içinde de öyle işaretlidir (sürüm: `2026-09-taslak-1`). Yapılacaklar:

1. Bir KVKK avukatına taslağı inceletin (veri sorumlusu kimliği, işleme amaçları, saklama süresi, yurt dışına aktarım - Supabase sunucu bölgesi, çocuk verisi için veli rızası, başvuru yolları, iletişim bilgisi).
2. Onaylanan tam metni herkese açık bir adreste yayınlayın (ör. kurum web siteniz, GitHub Pages, Google Sites - ücretsiz).
3. Aynı adresi hem Play Console'a hem App Store Connect'e girin.
4. Metin değişirse uygulamadaki `kPrivacyNoticeVersion` da artırılmalı (öğrencilere yeniden gösterilir) ve web sayfası güncellenmelidir.
5. Ayrıca web sayfasında bir **iletişim e-postası** ve hesap silme talebi yolu belirtin. Google, hesap oluşturulan uygulamalarda **web üzerinden hesap silme talebi bağlantısı** da isteyebilir (Play Console > Veri güvenliği > "Hesap silme"); bu için basit bir sayfa (talep e-postası açıklaması) yeterli olabilir.

## 2) Google Play - Veri Güvenliği formu için yanıt taslağı

Kaynaklar: Supabase şeması (`supabase/migrations`), uygulama gizlilik metni, ayarlar ekranı. Bildirim (push) özelliği eklendiği için cihaz belirteci (device token) de dahil edilmiştir.

**Genel sorular**
- Uygulama kullanıcı verisi topluyor mu / paylaşıyor mu? **Evet, topluyor.**
- Tüm veriler aktarımda şifreleniyor mu? **Evet** (Supabase HTTPS/TLS).
- Kullanıcılar veri silme talebinde bulunabilir mi? **Evet** - uygulama içinde Ayarlar > "Hesabımı sil" (sunucudaki `delete_my_account`) ve "Bilgilerimi kopyala" (`export_my_data`) vardır. Web tabanlı silme bağlantısı da gerekebilir (yukarıda).
- Üçüncü taraflarla paylaşım: **Hayır** (reklam, analiz, pazarlama için paylaşım yok). Not: Supabase, verileri kendi adımıza işleyen bir **hizmet sağlayıcıdır (işleyen)**; Google bunu "paylaşım" saymaz. Bildirim için Firebase (FCM) eklenirse bu da işleyen olarak beyan edilir.

**Toplanan veri türleri**

| Kategori / Tür | Toplanıyor | Amaç | İsteğe bağlı mı | Paylaşılıyor mu |
|---|---|---|---|---|
| Kişisel bilgi > Ad | Evet | Uygulama işlevi, hesap yönetimi | Zorunlu | Hayır |
| Kişisel bilgi > E-posta adresi | Evet | Hesap yönetimi (giriş), uygulama işlevi | Zorunlu | Hayır |
| Uygulama etkinliği > Uygulama içi etkileşimler (çözülen sorular, cevaplar, XP, seviye, seri, rozet, günlük hedef) | Evet | Uygulama işlevi, kişiselleştirme | Zorunlu | Hayır |
| Cihaz veya diğer kimlikler (bildirim belirteci) | Evet (bildirim özelliği ile) | Uygulama işlevi (bildirim) | İsteğe bağlı (bildirim izni verilirse) | Hayır |

Toplanmayanlar: konum, kişiler, mikrofon/kamera, fotoğraf, finansal bilgi, sağlık, mesajlar, tarama geçmişi, reklam kimliği. (Sınıf bilgisi "kişisel bilgi" altında ek bir alan sayılabilir; formda uygun kategoriye ekleyin.)

**Güvenlik uygulamaları:** Aktarımda şifreleme = Evet. Veri silme talebi yolu = Evet. Veriler sunucuda satır düzeyi güvenlik (RLS) ile korunur.

**Kritik doğruluk notu:** Formu, uygulamaya sonradan eklenen her özellikle (yeni SDK, analitik, ödeme) yeniden gözden geçirin. Yanlış beyan mağazadan kaldırılma sebebidir.

## 3) Veli onayı

- Uygulama ilk açılışta öğrenciye aydınlatma metnini gösterir (`record_notice_read`), veli onayı velinin panelinden verilir/geri çekilir (`set_parental_consent`, tablo `consents`).
- Hukuki taraf: hangi yaşta hangi rızanın (KVKK, 18 yaş altı) gerektiği avukat tarafından teyit edilmelidir.

## 4) Apple gizlilik ("App Privacy") notları

App Store Connect'te aynı verileri "Veri Toplama" bölümünde beyan edin: İletişim bilgisi (ad, e-posta), Kullanıcı içeriği/kullanım verisi (ürün etkileşimi), Tanımlayıcılar (cihaz kimliği - bildirim belirteci). Hiçbiri "izleme (tracking)" için kullanılmıyor: "Verileri takip için kullanıyor musunuz? **Hayır**". Ayrıntı: `IOS_YAYIN.md`.
