# Olay taksonomisi (Growth CRM ve ölçüm)

Tarih: 2026-10-27 · Kapsam: web (PostHog ve veritabanı), sunucu (`growth_events`), mobil (`kullanim_olaylari`).
Durum etiketleri: **Var** (kodda), **Planlı** (henüz kodda değil), **Bulgu** (sorun, karar gerekiyor).

## 1. Ortak kurallar

1. **Ad biçimi:** `snake_case`, Türkçe, yalnızca ASCII (ı, ş, ğ, ç, ö, ü yok), geçmiş zaman fiil
   (`tiklandi`, `gonderildi`, `baslatildi`, `tamamlandi`). Örnek: `erken_erisim_gonderildi`.
2. **`$` ile başlayan adlar** PostHog'a ayrılmıştır (`$pageview`). Uygulama olayı bu önekle açılmaz.
3. **Yazma yolu:** Sunucu olayları yalnızca `growth_events` tablosuna, `_growth_olay_yaz` ve
   `growth_web_olay_kaydet` üzerinden yazılır. İstemci tabloya doğrudan yazamaz (anon kapalı).
4. **PII kuralı:** Olay özelliklerinde e-posta, ad, telefon, çocuk kimliği veya serbest metin bulunmaz.
   Hane bağı (`household_id`) yalnızca sunucu tarafında kurulur; kişisel veri hane kartında tutulur.
5. **Rıza kuralı:** Web ölçümü (PostHog, anonim ziyaretçi olayları, `kullanim_olaylari`) analitik
   çerezine "Kabul et" denmeden çalışmaz (`consent.ts`, sürüm `ANALYTICS_CONSENT_VERSION`).
   Sunucu hizmet olayları (hesap, ödeme) rıza gerektirmez; pazarlama kanallarına kullanım ayrı
   iletişim izni kapısından geçer (`growth_household_izinleri`, `iletisim_tercihleri`).
6. **Yeni olay** bu dosyaya satır olarak eklenmeden kodlanmaz.

## 2. Web: PostHog olayları (istemci)

Kaynak: `web-panel/src/lib/analytics/events.ts` (`LandingEvent`). Onay: analitik çerez `granted`.
PostHog ayarı: `autocapture: false`, `person_profiles: identified_only`, oturum kaydı kapalı.

| Olay | Tetikleyici | Özellikler | PII | Onay | Durum |
|---|---|---|---|---|---|
| `hero_cta_tiklandi` | CTA tıklaması: `HeroSection.tsx`, `FinalCtaSection.tsx` (`TrackedLink`) | `konum` (yalnız son CTA: `"son"`) | Yok | granted | Var |
| `demo_tamamlandi` | Demo quiz bitişi (`DemoQuiz.tsx`) | `puan`, `toplam` | Yok | granted | Var |
| `veli_kayit_baslatildi` | Veli kayıt bağlantısı: `HeroSection.tsx`, `CharacterUniverseSection.tsx`, `ParentPanelSection.tsx` (`TrackedLink`) | yok | Yok | granted | Var |
| `fiyat_tiklandi` | Fiyat bağlantısı: `PricingSection.tsx` (`TrackedLink`) | yok | Yok | granted | Var |
| `$pageview` | Sayfa açılışı; yalnız `/`, `/demo`, `/gizlilik`, `/kosullar` (`AnalyticsProvider`) | `$current_url` (sorgusuz) | Yok | granted | Var |

## 3. Web veritabanı olayı (anonim ziyaretçi)

Kaynak: `growth-web-izle` Edge Function → `growth_web_olay_kaydet` (`growth_events`, `source='web'`).
Beyaz liste: yalnız bu olay adı kabul edilir. Ek olarak `growth_identity_links` ziyaretçi ile hane arasında bağ kurar.

| Olay | Tetikleyici | Özellikler | PII | Onay | Durum |
|---|---|---|---|---|---|
| `erken_erisim_gonderildi` | Erken erişim formu başarılı gönderimi (`erkenErisimIzleme.ts`) | `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content` | Anonim ziyaretçi kimliği (`vid-…`). Kimlik bağlama sonrası e-posta hane üzerinden bağlanır | granted (bu değişiklikle kapı eklendi) | Var · **Bulgu:** `ErkenErisimSection` hiçbir sayfada içe aktarılmıyor; olay şu an tetiklenmiyor |

## 4. Sunucu olayları (`growth_events`, `source='server'`)

Kaynak: tetikleyiciler `20261027000000_musteri_360_veri_toplama.sql`. Hata tetikleyiciyi bozmaz.

| Olay | Tetikleyici | Özellikler | PII | Onay | Durum |
|---|---|---|---|---|---|
| `hesap_olusturuldu` | Veli profili eklenir (`profiles` insert, `role='veli'`) | yok | Hane kartında ad ve e-posta | hizmet (rıza gerekmez) | Var |
| `ogrenci_baglandi` | Öğrenci profili veliye bağlanır (yeni çocuk kaydı) | `sinif` | Olayda yok; hane içi çocuk kaydında ad var | hizmet | Var |
| `odeme_basarili` | Ödeme `basarili` olur (`payments`) | `tutar_try`, `saglayici` | Yok | hizmet | Var |
| `veli_adayi_kaydi` | Landing formu adayı eklenir (`veli_adaylari` insert) | `kaynak` | Hane kartında e-posta | hizmet | Var |
| `deneme_on_kayit` | Deneme sınavı ön kaydı eklenir | `sinif`, `exam_id` | Hane kartında veli ve çocuk adı | hizmet | Var |
| `ilk_soru_cozuldu` | Öğrencinin ilk soru cevabı (W2) | — | Yok (planlanan) | hizmet | **Planlı (W2)**, repoda yok |
| `abonelik_iptal` | Abonelik iptali (W2) | — | Yok (planlanan) | hizmet | **Planlı (W2)**, repoda yok |

## 5. Mobil: `kullanim_olaylari` (ekran süresi)

Kaynak: `mobile-app/lib/services/kullanim_suresi.dart` → `kullanim_olaylari_gonder` RPC'si.
Sunucu: `20261066000000_kullanim_suresi.sql`. Olay adı yoktur; kayıt ekran süresidir.

| Kayıt | Tetikleyici | Alanlar | PII | Onay | Durum |
|---|---|---|---|---|---|
| Ekran süresi (`yuzey` `mobil` veya `flutter_web`) | Ekrandan çıkış veya arka plana geçiş | `ekran` (yol, kimlik benzeri parçalar `:id`), `sure_sn`, `baslangic`, `oturum_anahtari` (rastgele), `rol` | Yok | **Bulgu:** istemcide rıza kapısı yok; mobil ölçüm onayı kararı bekliyor | Var (kapı açık) |
| Ekran süresi (`yuzey` `site`, `yonetim`, `veli`, `ogretmen`) | Web `KullanimSuresi.tsx` | aynı | Yok | granted | Var |

**Bulgu:** `kullanim_suresi.dart` içinde rıza veya onay kontrolü yok. Çocuk uygulaması için varsayılan
"takip kapalı" kuralı (AGENTS.md §5.6) ile çelişiyor olabilir. Karar: mobil ölçüm onayı (hukuk).

## 6. Mobil funnel adımları (eksik, planlı)

Mobil istemcide bu adımların olay gönderimi yok. Adlar taslaktır; W3 funnel kararında kesinleşir.

| Taslak olay | Anlamı | Durum |
|---|---|---|
| `mobil_kayit_tamamlandi` | Mobilde hesap oluşturma tamamlandı | Planlı (W3) |
| `mobil_cocuk_baglandi` | Çocuk profili oluşturuldu veya bağlandı | Planlı (W3) |
| `mobil_eslestirme_kodu_girildi` | Veli eşleştirme kodu girildi | Planlı (W3) |
| `mobil_deneme_baslatildi` | Deneme süresi başladı | Planlı (W3) |
| `mobil_odeme_sayfasi_acildi` | Ödeme ekranı açıldı | Planlı (W3) |

Sunucu tarafı karşılıkları (`ogrenci_baglandi`, `odeme_basarili`) zaten Var; mobil olayları
yalnızca istemci tarafındaki boşluğu kapatır.

## 7. Açık noktalar

- **Saklama çelişkisi:** `kullanim_olaylari` için `20261066` 300 gün uygular (03:15 zamanlı). Yeni
  `growth_saklama_temizle()` 400 gün uygular, ama eski iş önce çalıştığı için etkisizdir. Hukuk süreyi
  seçmeli. Bkz. `20261109000000_growth_saklama.sql`.
- **Mobil rıza:** Bölüm 5'teki bulgu.
- **Eski ziyaretçi kayıtları:** Rıza kapısı eklenmeden önce yazılmış `hupo_vid` ve `hupo_utm`
  (localStorage) kayıtları temizlenmiyor.
- **`ErkenErisimSection` kullanılmıyor:** Erken erişim olayı ve UTM ilk temas kaydı şu an hiçbir
  sayfada çalışmaz. Sayfa bağlanınca bu belge güncellenir.
- **Saklama kuralları** hukuk onayı bekliyor; süreler `20261109` dosya başında sabittir.

## 8. Tanımlar (Faz 0, 2026-10-28)

Bu tanımlar koddan çıkarıldı. Metrikler bu tanımlara göre hesaplanır; başka bir yerde farklı tanım kullanılırsa bu bölüm esas alınır.

| Terim | Tanım | Kaynak |
|---|---|---|
| **Aktive hane** | Hanenin çocuğu ilk soru cevabını verdiyse. Bir kez yazılır; sonraki cevaplar değiştirmez. Alan: `growth_households.activated_at`. | `20261104` §3 (user_answers AFTER INSERT) |
| **Aktif gün (hane)** | Hanenin çocuğunun cevap verdiği takvim günü. Tek satır: (hane, gün). Yalnız hane ve gün saklanır; cevap içeriği yok. | `growth_hane_aktif_gunleri` (`20261104`) |
| **Aktif kullanıcı (DAU / WAU / MAU)** | Pencere içinde en az bir cevap kaydı olan öğrenci (`answer_events.student_id`). DAU: bugün (İstanbul saati). WAU: son 7 gün. MAU: son 30 gün. | `admin_growth_aktiflik` (`20261105`) |
| **Düzenli aile** | Son 14 günde en az 3 aktif gün (hane). | `20261104` §3 (engaged kuralı) |
| **Kullanım dışı (at_risk)** | Aktive veya düzenli hanede son aktif günden 14 gün geçmişse. | `20261104` §3 |

**Notlar**
- Pazarlama "aktif" ile öğrenme metriği ayrıdır. Aktif kullanıcı bir cevap verme sayısıdır; XP, seri (streak) veya süre bu tanıma girmez.
- Eski `aktif_7_gun` görünümü (XP/streak tabanlı) bu tanımla değiştirilmiş olmalı. Değiştirildiği bu belgede **doğrulanmadı**; W3 kapsamında kod ve sorgu kontrolü yapılacak.
- Harcama (`growth_harcama`) bir olay değildir; bu tabloya yazılmaz. CAC yalnız harcama girilmiş dönemde hesaplanır.
