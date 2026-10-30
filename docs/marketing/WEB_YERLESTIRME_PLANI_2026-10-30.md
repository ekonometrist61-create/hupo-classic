# Web yerleştirme planı: lead magnet ve ikna içerikleri (2026-10-30)

Durum: PLAN. Yalnız Pilot 1 kodlandı (bayrak KAPALI). Diğerleri kodlanmadı. Güven: **K** kanıtlı, **V** varsayım, **H** hipotez.
Kaynaklar: `LEAD_MAGNET_VE_KANIT_ICERIK_FIKIRLERI_2026-10-30.md`, kanıt paketi §7 (yasaklı iddialar bağlayıcı), landing `page.tsx` (tek CTA kuralı).

## 1. Yerleştirme tablosu

| İçerik | Rota | Landing'de | Header / Footer | Kapı | Durum |
|---|---|---|---|---|---|
| #1 Çarpım pif noktaları (Pilot 1) | `/rehber/carpim-tablosu-pif-noktalari` | İkincil bant (§2) | Header yok; Footer "Veliler" sütunu (yalnız bayrak açıkken) | Form (e-posta+sınıf) | **Kodlandı, bayrak kapalı** |
| Sonraki rehberler (#4, #5, #10, #11) | `/rehber/<slug>` aynı şablon | Bant tek kalır; ileride `/rehber` dizin sayfası | Footer'da tek "Veli rehberleri" bağlantısı (dizin gelince) | Aynı form | Plan |
| Örnek veli raporu (#15) | `/ornek-rapor` (hesapsız, "örnek veri" etiketli) | Mevcut ParentPanelSection içinde bağlantı (yeni bölüm yok) | Footer "Veli raporu" zaten var | **Kapısız** | Plan |
| Öğrenme Bilimi bölümü (B#2, #3, #11) | Landing: TrustSection ile PricingSection arasında kısa bölüm (3 kart, tek paragraf, "Araştırma kütüphanesi" bağlantısı) | Evet, **kodlanmaz bu turda** | Footer "Yöntem" | Kapısız | Plan |
| Şeffaflık: "Bilmediklerimiz" (B#6), yöntem/denetim (B#8), araştırma kütüphanesi (B#12) | `/yontem` (tek sayfa, 3 bölüm) | Yok (TrustSection'dan bağlantı) | Footer "Şirket" sütunu | Kapısız (güven içeriği kapının arkasına konmaz) | Plan |
| Ayın Denemesi (#3) | Mevcut `/deneme-sinavi-kayit` altyapısı | Yok (tek CTA için çıkarılmıştı) | Footer "Deneme Sınavı" var | Ön kayıt | Pilot 2 |
| Haftalık görev kartı (#7) | Rehber teslim sayfası + e-posta | Yok | Yok | İzinli e-posta | Pilot 3, gönderim motoru önkoşul |

## 2. Landing "tek CTA" kuralıyla uyum

- **Karar:** `PricingSection` ile `FaqSection` arasında, tek satırlık, düşük vurgulu bant: "Veliler için ücretsiz rehber: Çarpım tablosu için pif noktaları  Rehbere bak →". Düğme değil metin bağlantısı, renkli dolgu yok. Ana CTA `/demo` (hero, demo, son CTA) değişmedi. Bayrak kapalıyken hiç render edilmez.
- **Gerekçe (H):** Fiyat bölümünde kararsız kalan veliye düşük taahhütlü ikinci yol sunar. DemoSection'dan sonra olsaydı demo CTA'sıyla yarışırdı; FinalCta'dan hemen önce olsaydı son CTA'yı sulandırırdı.
- **Koruma:** Bandın tıklanma oranı ile `demo_tamamlandi` / `veli_kayit_baslatildi` oranı izlenir; demo oranı belirgin düşerse bant kaldırılır (karar kuralı: ilk 4 hafta yalnız taban ölçümü, A/B yok, yeterli trafik yok).
- Header menüsüne rehber eklenmez (menü zaten kısa tutuldu).

## 3. Sayfa şablonu (rehber sayfaları)

Hero (etiket + tek H1 + 2 cümle) → Ne alırsın (liste) → 2 ipucu önizlemesi (sunucuda render, **indekslenebilir**) → Form → Teslim (aynı sayfada açılan içerik) → Sıradaki adım (ana CTA `/demo`, ikincil `/veli-paneli/kayit`; fiyat/deneme/iade vaadi yok).
Tam içerik istemci tarafında formdan sonra render edilir (yumuşak kapı; HTML'de yok, ama JS paketinde var; gizlilik gerektiren içerik için uygun değildir).

## 4. SEO

| Konu | Karar |
|---|---|
| Metadata | `title` ve `description` landing.rehber namespace'inde; bayrak açıkken `index,follow`, kapalıyken 404 |
| Başlık | Tek H1, bölümler H2, ipucu kartları H3 |
| Schema | Yalnız `Article` (kodlandı). FAQPage yalnız sayfada gerçek SSS bölümü olursa. **Akademik bulgular Product/Review/AggregateRating şemasına konmaz** (kanıt paketi brief madde 10 uygulanmaz) |
| Kapsam | Soru içeriği veya çocuk verisi public index'e girmez; sayfada örnek çarpımlar özgündür |
| Önkoşul (V, doğrulanmadı) | `robots.txt`, sitemap, canonical/OG durumu kontrol edilecek; canonical ve `og:*` bu turda eklenmedi |
| Dil | tr asıl; en kısa karşılık. `hreflang` ayrı iş |

## 5. Olay planı

`trackLandingEvent` kalıbı: yalnız çerez onayı varsa gönderilir; ad/e-posta analytics'e gitmez. `OLAY_TAKSONOMISI.md` eklemesi ana oturumda.

| Olay | Ne zaman | Özellikler | Not |
|---|---|---|---|
| `lead_magnet_goruntulendi` | Sayfa istemcide yüklendi | `icerik` (slug), utm_* (otomatik) | Sunucu sayacı ayrı |
| `lead_magnet_istendi` | Backend 200 döndü | `icerik`, `sinif` (sayı), utm_* | E-posta/lead_id gönderilmez |
| `lead_magnet_icerik_acildi` | İçerik ilk kez açıldı | `icerik` | Yenilemede yeniden gönderilmez |

Ana metrik: `lead_magnet_istendi` / benzersiz ziyaret (BOŞ, baseline yok). Koruma: e-posta çıkış ve şikâyet oranı (gönderim başlayınca). Taban 4 hafta ölçülür; yüzde artış vaadi yok.

## 6. Erişim ve mobil kabul kriterleri

- 390 px'te yatay kaydırma yok; hedef dokunma alanları ≥44 px (form alanları 48 px).
- Form: görünür etiket, zorunlu alan `*` + ekran okuyucu metni, hata `role="alert"`, odak halkası görünür.
- Açılışta odak içerik başlığına gider; durum notu `role="status"`.
- Cevaplar `<details>` ile klavyeyle açılır. Tablo `th scope` ve `aria-label` taşır. `prefers-reduced-motion` ile uyumlu (animasyon yok).
- Yazdırma: yalnız çarpım tablosu basılır (print CSS), PDF üretilmez.
- Kontrast: mevcut tasarım tokenları kullanıldı; ayrı kontrast ölçümü yapılmadı.

## 7. Ekran sözleşmeleri

| Ekran | Hedef | Ana eylem | Durumlar | Kabul kriteri |
|---|---|---|---|---|
| Rehber sayfası (form durumu) | Veli faydayı görür, rehberi ister | "Rehberi aç" | boş, doğrulama hatası (zorunlu/e-posta/KVKK/captcha), gönderiliyor, sunucu hatası, başarı | E-posta+sınıf (3–7)+KVKK olmadan gönderilmez; izin kutusu işaretsiz başlar ve işaretlenmeden de içerik açılır; çocuk adı/telefon yok |
| Rehber (içerik durumu) | Veli çocukla 3 dk çalışır | "Tabloyu yazdır" / ana CTA "5 soruluk örneği dene" | yeni açıldı, yenileme sonrası açık (sessionStorage kapalıysa form) | Tüm çarpımlar doğru; "gün/garanti/bilimsel olarak kanıtlandı/fiyat/deneme/iade" ifadesi yok; durum notu e-posta gönderildiğini söylemez |
| Landing bandı | Rehbere ikincil yol | "Rehbere bak" | bayrak kapalı: yok | Düğme değil bağlantı; ana CTA'lar değişmedi; mobilde tek satıra sığmasa sarar |
| Öğrenme Bilimi bölümü (plan) | Güveni kanıtla destekler | "Araştırma kütüphanesi" | statik | Yalnız kanıt paketindeki güvenli ifade + DOI + "Hupolingo'nun sonucu değildir" dipnotu |
| Örnek veli raporu (plan) | "Ne göreceğim" itirazı | "Veli hesabı oluştur" | statik | "Örnek veri" etiketi; gerçek çocuk/yorum yok |

## 8. Çelişkiler ve taşınmayanlar

| Konu | Karar |
|---|---|
| Kanıt dosyasındaki 399 TL / 90 gün, 14 gün ücretsiz deneme, 14 gün iade, "Hupo'yu ücretsiz deneyin" | **Taşınmadı**: K-5 (deneme dili kilitli), K-6 (iade rozeti yok), K-0196 (tek seferlik ödeme). Onaylı plan kaydı gelene dek hiçbir rehber CTA'sında fiyat/deneme/iade yok |
| "Veliler için ücretsiz rehber" etiketi | Rehberin kendisi gerçekten ücretsizdir (V: ödeme alınmaz). Deneme/ürün için "ücretsiz" denmez |
| `/demo` soruları "4. sınıf" etiketli (önceki program) | Rehber 3. sınıfa yazıldı; CTA hedefi demo kalıyor, etiket uyumu ayrıca doğrulanmalı |
| E-posta teslimi | Gönderim motoru yok (E1–E4); sayfa "e-posta gönderdik" demez, durum notunda dürüst açıklar. Ana oturum çift doğrulama + gönderimi kurana dek değişmez |
| Rehber sayfasında LandingHeader/Footer yok | Onlar ana sayfa çapaları (`#pricing`...) kullanır; rehber sayfasında kırık olurdu. Sade üst çubuk + gizlilik/ticari ileti bağlantıları kullanıldı. Karar sende |
| Yayın kapısı | `NEXT_PUBLIC_LEAD_MAGNET_ACIK=true` yalnız hukuk onayı (GÖR-078), şirket bilgileri, `ticari-ileti-izni` yer tutucularının kapanması ve backend dağıtımı sonrası |
