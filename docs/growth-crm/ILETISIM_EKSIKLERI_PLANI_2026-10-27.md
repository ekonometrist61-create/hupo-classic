# Bildirim, pazarlama ve iletişim: eksik denetimi ve iş paketleri (2026-10-27)

## Var olanlar (kodlanmış)
- Uygulama içi bildirim kutusu, duyurular, segmentli bildirim, kampanya push dağıtımı (kapı: `pazarlama_push_kapisi`, varsayılan KAPALI), `send-push` (FCM), mobil push katmanı.
- Veli/çocuk hesap bildirimi: `bildirim_gonder` + `eposta_outbox`; `olay_kutusu` + `olay-kutusu-gonder` (Resend, pg_cron 5 dk).
- İletişim izni: 3 kanal, sürümlü metin, iptal fonksiyonu, `/ticari-ileti-izni`.
- Yönetim arayüzleri: kampanyalar, segmentler, journey, mesaj şablonları, AI öneriler, müşteri 360, potansiyel adaylar, satış hattı, destek, growth analitik.

## Tespit edilen eksikler (yürütme katmanı yok)
| # | Eksik | Kanıt |
|---|-------|-------|
| E1 | `eposta-gonder` (Brevo) hiçbir zamanlayıcıyla çağrılmıyor; `eposta_outbox` hiç boşalmıyor. İki ayrı e-posta sağlayıcısı (Brevo / Resend) var | cron yalnız `olay-kutusu-gonder` için |
| E2 | Journey'ler çalışmıyor: `growth_journey_enrollments`'a yazan ve adım ilerleten fonksiyon yok | yalnız şema + liste/kaydet RPC'leri |
| E3 | `growth_message_log` yazıcısı yok; kampanya `sent/opened/clicked` sayaçları hiç artmıyor; `growth_templates` render eden kod yok | tablo yalnız sayılıyor |
| E4 | Sıklık sınırı ve sessiz saat kontrolü yok (e-posta/SMS) | arama sonucu boş |
| E5 | AI öneri üreticisi yok; `growth_ai_recommendations` yalnız okunuyor | yalnız listele/geri bildirim |
| E6 | Yönetimde gönderim günlüğü (mesaj log) ekranı yok | sayfa yok |
| E7 | Growth katmanı için SQL testi yok | `supabase/tests` altında yok |

Kapsam dışı (kullanıcı/hukuk kararı bekliyor, kodlanmaz): SMS/WhatsApp pazarlama gönderimi (İYS, GÖR-018/019), push pazarlama kapısı (GÖR-031), Brevo anahtarı ve gönderici doğrulaması, Firebase anahtarları.

## İş paketleri (her biri ayrı dosya kümesi, Haiku 5.5)
| Paket | Kapsam | Migration |
|-------|--------|-----------|
| P1 | `eposta-gonder` için pg_cron + gizli doğrulama, sağlayıcı seçimi tek `_shared/eposta.ts`, test | 20261098000000 |
| P2 | Journey motoru: kayıt (enroll) ve ilerletme RPC'leri, pg_cron, izin kapısı, PGlite testi | 20261099000000 |
| P3 | Mesaj günlüğü yazıcı RPC, şablon render (`_shared/sablon.ts`), kampanya sayaçları, test | 20261100000000 |
| P4 | Sıklık sınırı + sessiz saat fonksiyonu (`growth_iletisim_uygun_mu`), test | 20261101000000 |
| P5 | AI öneri üreticisi (kural tabanlı, LLM yok), test | 20261102000000 |
| P6 | Yönetim "Gönderim Günlüğü" ekranı (RPC + sayfa + bileşen + çeviri) | 20261103000000 |

Kurallar: migration uzak DB'ye uygulanmaz; commit atılmaz; varsayılan KAPALI bayrak; pazarlama gönderimi izin + sıklık kapısından geçer; çocuk verisi ve PII günlüğe düz yazılmaz.
Entegrasyon (P2 ve P3'ün P4'ü çağırması) ajanlar bittikten sonra ana oturumda yapılır.
