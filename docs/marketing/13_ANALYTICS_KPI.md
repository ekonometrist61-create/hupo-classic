# 13 Analitik ve KPI Çerçevesi

Durum: Taslak · Tarih: 2026-10-29 · Rol: Veri Analitiği ve Deney Tasarımı · Bağımlı: 08, 12, 14, 15 · Kaynak: `GROWTH_AND_MEASUREMENT.md`, `OLAY_TAKSONOMISI.md`, `GIE` §19–35

**Hiç hedef rakam konmadı** (baseline yok). Her KPI: tanım (pay/payda, pencere), kaynak, kalite sınırı. Olay adları taksonomi biçiminde (`snake_case`, ASCII, Türkçe, geçmiş zaman); yeni olay önerileri `16`'da. Çocuk, mobil, serbest metin, ad/e-posta analytics'e girmez. PostHog yalnız web, çerez onaylı → **onay vermeyen ziyaretçi görünmez (yanlı örneklem)**.

## 1. Kuzey yıldızı
**Haftalık anlamlı öğrenme ilerlemesi gösteren aktif öğrenci**; ölçüm geçerli değilse geçici proxy: *haftada ≥1 tamamlanmış öğrenme/tekrar oturumu yapan öğrenci* (açıkça "proxy" etiketli). XP/süre ile karıştırılmaz.

## 2. KPI tablosu
| Seviye | KPI | Tanım | Kaynak | Kalite sınırı |
|---|---|---|---|---|
| Edinim | Ziyaretçi (kanal) | UTM'li onaylı oturum sayısı | PostHog `$pageview` + `utm_*` | Onay vermeyen eksik; sekme kapanınca ilk temas kaybolur |
| Edinim | Demo tamamlama | `demo_tamamlandi` / `$pageview` (landing, onaylı) | PostHog | Yalnız onaylı alt küme |
| Edinim | Kayıt başlatma | `veli_kayit_baslatildi` / demo_tamamlandi | PostHog | — |
| Edinim | Veli hesabı | Sunucu hesap oluşturma sayısı (kaynak alanı ≥%80 doluysa kanala bölünür) | Supabase | Hane kaynak alanı henüz yok (migration kararı) |
| Edinim | İndirme | Mağaza yayını sonrası | Mağaza konsolları (manuel) | Şu an yok |
| Edinim | CAC | `growth_harcama` / yeni hane (toplam; kanal bazlı ≥%80 kaynak sonrası) | admin RPC | Karar 2026-10-28: kanal CAC yok |
| Aktivasyon | İlk başarılı oturum oranı | Eşleşmiş hane içinde ilk tamamlanmış oturum / kayıt (7 gün penceresi, cohort) | Supabase | Tanım ve pencere deneyden önce kilitlenir |
| Elde tutma | D1/D7/D30 | Cohort'ta o gün **tamamlanmış oturum** yapan / cohort; yalnızca uygulama açmak sayılmaz | kohort RPC (GIE §13) | n<5 gizli |
| Elde tutma | Haftalık aktif öğrenci | Haftada ≥1 tamamlanmış oturum | Supabase | — |
| Öğrenme | Görev tamamlama | Başlatılan/tamamlanan günlük görev | Supabase | — |
| Öğrenme | Öğrenme kazanımı | Geçerli başlangıç/sonuç ölçümü yoksa **hesaplanmaz** | — | "veri yetersiz" |
| Ticari | Ücretli dönüşüm | Aynı cohort ve pencerede doğrulanmış ilk ödeme / uygun veli | sunucu ödeme olayı | Client tıklaması değil |
| Ticari | Gelir | Brüt/net, iade, para birimi, dönem ayrı | Ödeme tablosu | MRR tanımı yok (tek seferlik) |
| Ticari | ARPU / LTV | Gelir / ücretli hane; LTV = ilk satış + yeniden alım | Hesap | Aralık ver, tek sayı yok |
| Ticari | Yeniden satın alma | Dönem sonu yeni erişim alan / dönemi biten | Ödeme | Tek seferlik modelde "churn" yerine |
| İçerik | Erişim, kaydetme, paylaşım | Platform istatistiği (manuel CSV) | Meta/YouTube | Hesap bağlama yok |
| İçerik | Nitelikli etkileşim | (kaydetme + paylaşım) / erişim | Hesap | Kıyaslama için baseline ilk 4 hf |
| İçerik | İçerik kaynaklı kayıt | UTM `utm_content` bazında `veli_kayit_baslatildi` | PostHog | Instagram'da bio linki tek (sınırlı atıf) |
| İçerik | Organik arama görünürlüğü | Search Console gösterim/tıklama | GSC | Lansman sonrası |
| İçerik | Tavsiye | "Nereden duydunuz?" (kayıt formunda isteğe bağlı sorusu önerisi, `16`) | Kayıt formu | Öz-bildirim |
| Koruma | Şikâyet / olumsuz yorum / takipten çıkma / gizlilik sorusu | Manuel sayım | Platform | Artarsa duraklat |

## 3. Olay planı (mevcut + öneri)
Mevcut (taksonomi): `hero_cta_tiklandi`, `demo_tamamlandi`, `veli_kayit_baslatildi`, `fiyat_tiklandi`, `$pageview`. UTM: `utm_source|medium|campaign|content` (K-0199, uygulandı).
Önerilen (kod değişikliği ana oturum): `veli_kaynak_bildirdi` (kayıtta isteğe bağlı kategorik "nereden duydunuz"; serbest metin yok), `ornek_rapor_goruntulendi`, `sss_madde_acildi`, `plan_karsilastirma_goruntulendi`, `on_bilgilendirme_onaylandi` (sunucu), `odeme_dogrulandi` (sunucu, idempotent). Çocuk yüzeyi olayları PostHog'a gitmez.

## 4. Veri kalitesi görevleri (`16`)
Hane kaynak alanı; UTM canlı doğrulama; demo ölçümünün yanlılığı notu; yinelenen olay denetimi (çift sayım); `growth_harcama` düzenli girişi; mağaza yayını sonrası referans 30 gün.

## 5. Raporlama ritmi
Haftalık (Pazartesi, tek sayfa): sosyal metrik özeti (n<5 "yetersiz"), site funnel, uyarılar. Aylık: kanal kararı, deney durumu, CAC (toplam), karar kaydı. Üç aylık: öğrenme raporu ve plan revizyonu. Yıllık: baseline seti ve 2028 hedefleri. Rapor taslağı `rapor_taslaklari` yoluyla (admin onayı); LLM sayı üretmez.

## 6. Atıf notu
Atıf yaklaşıktır: ilk temas UTM, oturum kapsamlı; "dark social" (WhatsApp/DM) görünmez; Instagram link sınırı; öz-bildirim kaynağı tamamlayıcı. Reklam hesabı/piksel bağlanmaz; ücretli kanal yalnız UTM ve manuel harcama ile. Tam çok-dokunuşlu atıf veya MMM bu ölçekte anlamsız (n çok küçük).
