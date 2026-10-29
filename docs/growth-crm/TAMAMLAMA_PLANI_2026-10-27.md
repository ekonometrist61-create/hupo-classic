# CRM, giriş, Müşteri 360, aktivasyon ve analitik: durum analizi ve tamamlama planı (2026-10-27)

Kaynak: dört salt okunur Haiku analizi (giriş, CRM/360, aktivasyon, analitik). İletişim yürütme katmanı (P1–P6) için bkz. `ILETISIM_EKSIKLERI_PLANI_2026-10-27.md`; o paketler yazıldı, commit'siz ve entegre değil.

## Özet bulgular
| Alan | Çalışan | Kritik eksik |
|------|---------|--------------|
| Giriş | rol kontrolü RPC'de, e-posta onayı ve şifre sıfırlama kodlu, rol değiştirilemez | `/veli-paneli` sunucu rol kapısı yok; `next` yok sayılıyor; giriş olay kaydı yok; hesap varlığı sızıyor; ham İngilizce hata; çocuk kodu IP sınırı yok. Captcha (giriş yüzeyleri) ve admin MFA kullanıcı/Dashboard kararı bekliyor |
| Müşteri 360 | hane otomatik besleme, RPC'ler, arama/filtre/sayfa | abonelik tarihleri "-" (camelCase/snake_case), sağlık ve churn skoru yazılmıyor, `activated/engaged/at_risk/winback` atanmıyor, not/görev/destek eklenemiyor, birleştirme, KVKK silme/dışa aktarma yok, lead→hane yok |
| Aktivasyon | kayıt, çocuk bağlama, ödeme olayları | "aktive oldu" tanımı yok; ilk soru/eşleştirme kodu/deneme/iptal olayı yok; abonelik süresi dolunca `paid` kalıyor; hoş geldin, terk, deneme bitiş, pasiflik journey'leri yok; veli "sonraki adım" yok; funnel yok |
| Analitik | KPI, gelir grafiği, growth analitik, çerez kapısı | `kullanim_olaylari_gonder` anon açık; huni ziyaret/deneme/eşleştirme içermiyor; UTM raporu, DAU/WAU, dışa aktarma yok; "aktif 7 gün" XP/streak tabanlı; saklama işi yok; PostHog kararı çelişkili |
| Entegrasyon | P2–P5 ayrı ayrı testli | `growth_iletisim_uygun_mu` ve `sablon.ts` hiçbir yerden çağrılmıyor; journey mesajı tüketen yok; izin kaynağı P2/P4 çelişkili |

## İş paketleri (Haiku 5.5, ayrı dosya kümeleri)
| Paket | Kapsam | Migration |
|-------|--------|-----------|
| W1 | 360 gösterim düzeltmesi (tarihler, boş skor, etiketler) | yok |
| W2 | Aktivasyon + yaşam döngüsü + skor/churn + abonelik sweep | 20261104 |
| W3 | Funnel, UTM atfı, DAU/WAU, aktif_7_gun düzeltmesi + Growth Analitik UI | 20261105 |
| W4 | KVKK silme/anonimleştirme, dışa aktarma, hane birleştirme, lead→hane, 360 aksiyon RPC'leri | 20261106 |
| W5 | 360 aksiyon arayüzü (not, görev, destek, sahip, KVKK, dışa aktar) | yok |
| W6 | Giriş: `next`, tek tip mesaj, hata çevirisi, birim test | yok |
| W7 | Giriş olay kaydı + çocuk kodu global sınırı + admin özeti | 20261107 |
| W8a | `kullanim_olaylari` için IP sınırlı edge fonksiyon + istemciler (web, mobil); anon kapatma ayrı dosya | 20261108 (uygulama: istemciler yayınlandıktan sonra) |
| W8b | Rıza korumalı erken erişim izleme, analitik testleri, saklama işi, olay taksonomisi belgesi | 20261109 |
| W9 | P2–P4 entegrasyonu + journey seed'leri + gönderici tüketici | 20261110 |
| W10 | Veli "sonraki adım" kartı, `/veli-paneli` sunucu rol kapısı, anket yeri | 20261111 |

## Kullanıcı/hukuk kararı bekleyenler (kodlanmaz)
- Giriş/kayıt/sıfırlama/mobil captcha: Turnstile anahtarı ve `CAPTCHA_SECRET`, Supabase captcha ayarı.
- Admin MFA (GÖR-059): Dashboard'da MFA açılması; kilitlenme riski nedeniyle kurtarma planı önce.
- Canlı Auth: site_url, SMTP/Brevo 504, sızdırılmış şifre koruması (GÖR-002/012).
- PostHog kullanılacak mı (PROJE_GUNLUGU 3777 / 4313 çelişkisi), çerez/gizlilik metni `[X AY]`, ekran-süresi cümlesi, mobil ölçüm onayı.
- SMS/WhatsApp (İYS), push pazarlama kapısı, Brevo anahtarı.
- Migrasyonların uzağa uygulanması (preview → içerik okuma → deploy), `kullanim_olaylari_gonder` anon kapatma zamanı.

## Ortak kurallar
Uzak DB'ye uygulanmaz; commit atılmaz; yeni bayraklar KAPALI; PII ve çocuk verisi günlüğe düz yazılmaz; her migration PGlite testiyle (örnek: `supabase/tests/growth_journey`); `PROJE_GUNLUGU.md`'yi yalnız ana oturum günceller.
