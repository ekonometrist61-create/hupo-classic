# 18 Kaynaklar ve Kanıt

Durum: Taslak · Tarih: 2026-10-29 · Rol: Tümü · Bağımlı: tümü

## 1. Web kaynakları (erişim 2026-10-29)
| URL | İçerik | Güven | Kullanıldığı yer |
|---|---|---|---|
| https://mebi.eba.gov.tr | MEBİ: ücretsiz, 5–8 ve 9–12, okul dersleri şimdilik 5,6,9,10; KANKA asistan; veli e-Devlet ile ilerleme | Doğrulandı | 02, 03, 06 |
| https://kunduz.com/tr/ | Kunduz özellikleri (KAI, koçluk, veli raporu); fiyat yok | Doğrulandı (fiyat yok) | 02 |
| https://apps.apple.com/app/id1083827128 | Kunduz App Store kaydı (arama sonucu özeti; ücretsiz deneme + abonelik) | Kısmen | 02, 15 |
| akakce.com Tonguç listesi (arama sonucu) | Basılı set fiyatları, tarihsiz | Kısmen | 02, 15 |
| MEB haberi (meb.gov.tr/eba-kontrol-merkezi...) | EBA Akademik Destek 11–12. sınıf | Kısmen | 02 |
| https://omersaidakcin.com/ilk-1000-kullanici | 20 taktik makalesi (yazar tarihi 2026-09-29) | Görüş yazısı | 20, 02, 08, 10, 15 |
| https://developer.apple.com/app-store/in-app-events/ | Etkinlik: ≤31 gün, 14 gün önce tanıtım, 10 eşzamanlı, 15 onaylı | **Doğrulandı** | 20 |
| https://developer.apple.com/app-store/getting-featured/ | Öne çıkarma: ≥2 hafta, geniş değerlendirme için 3 aya kadar | **Doğrulandı** | 20 |
| https://developer.android.com/guide/playcore/in-app-review | Puan istemi: ön "sevdin mi?" sorusu yok, buton tetikleme yok, kota değişebilir | **Doğrulandı** | 20, 16 |
| https://developer.apple.com/documentation/storekit/requesting-app-store-reviews | iOS 3/365 | **Doğrulanmadı** (sayfa gövdesi okunamadı) | 20 |
| support.google.com Play ön kayıt (iki sayfa denendi) | Alakasız içerik | **Doğrulanmadı** (90 gün, 2 uygulama) | 20 |
| tonguc.com | Alakasız (illüstratör sitesi) | Kullanılmadı | 02 |

**Erişilemeyen/yapılmayan:** Ahrefs, Similarweb, Supermetrics (yetkisiz); Meta Reklam Kitaplığı; App Store/Play sıralaması ve yorum temaları; rakip sosyal hesapları; Meta/Google/YouTube/LinkedIn API belgeleri; MEB resmî 2026–27 takvim sayfası; Webrazzi/ShiftDelete/Technopat kuralları. playwright ve nano-banana-2 MCP bağlanmadı (canlı site UX denetimi ve görsel üretim yapılamadı).

## 2. Repo kaynakları (okunan)
`docs/hupo-design-growth/{PROJECT_CONTEXT, BRAND_AND_VISUAL_RULES, GROWTH_AND_MEASUREMENT, decisions}.md`, `sosyal-medya/{STRATEJI_DEGERLENDIRME, KANAL_OTOMASYON_PLANI, ICERIK_PAKETI_2_HAFTA (başlıklar)}.md`; `docs/growth-crm/{GIE_ANALIZ... §19–35, DENEME_SINIR_KURALI, ILETISIM_EKSIKLERI_PLANI}.md`; `docs/mufredat/{README, takvim_notlari_2026_2027.csv}`; `web-panel/src/messages/tr.json` (landing); `web-panel/src/app` rota listesi; `mobile-app/lib/screens` listesi; `scripts/growth-ajan/ajan.py` (ilk 70 satır); `PROJE_GUNLUGU.md` (GÖR-078…084 satırları); hafıza notları (ipucu, koddan tam doğrulanmadı: Kelime Evreni, Okuma, Görselli soru, Soru üretimi). Okunmayan: `OLAY_TAKSONOMISI.md` (K-0199 kaydı üzerinden), `AGENTS.md` ayrıntı, kod dosyalarının çoğu, canlı DB.

## 3. Bilimsel kanıt düzeyleri
K1 kendi verimiz (yok) · K2 replike ilke · K3 bağlama duyarlı hipotez · K4 çürütülmüş/popüler. Bu çalışmada kullanılan ikna ilkeleri: bilişsel akıcılık (K2), somutluk (K2–K3), çerçeveleme (K3), hikâye (K3), sosyal kanıt (K3, şu an uygulanmıyor). Kullanılmayan: kıtlık, kayıptan kaçınma, ankraj-çıpa (yalnız doğrulanmış fiyatla ve tarihle), "alt bilinç/sürüngen beyin" (K4). Nudge etkisi yayın yanlılığı düzeltmesiyle zayıf olabilir; hiçbir teknik "işe yarar" diye sunulmadı.

## 4. Hangi uzmanlık hangi skill'le, hangisi kendi yöntemle
| Uzmanlık | Yol |
|---|---|
| Hupo kuralları, UX yazarlığı, strateji, tasarım | `hupo-growth-marketing`, `hupo-ux-writing`, `hupo-ux-strategy`, `hupo-design-system`, `hupo-platform-review` (yüklendi) |
| Pazarlama psikolojisi, ikna | Kendi yöntem + skill çerçeveleri (marketing-psychology/influence-psychology ilkeleri **uygulandı**, skill çağrısı yapılmadı) |
| Müşteri araştırması, JTBD, mom-test, interview-analyst/abductive | Plan yazıldı (05 §5); skill çağrısı yok, çünkü veri yok |
| Rakip analizi / positioning / revops / social-media / behavioral-economics / literature-review | **Kurulu değil**; `product-marketing` ve `marketing:competitive-brief` yöntemi + kendi analiz; WebFetch/WebSearch ile sınırlı |
| CRO, copywriting, storybrand, made-to-stick | Kendi yöntemle uygulandı (06, 11) |
| SEO / ASO | 06 (kendi yöntem); `aso` yalnız hazırlık, mağaza yok |
| Pricing, paywalls, churn | `pricing/paywalls/churn-prevention` ilkeleri Hupo'ya uyarlandı (tek seferlik); skill çağrısı yapılmadı |
| A/B, istatistik | `ab-testing/statistical-power` mantığı; hesap kabaca elle (14), Python istatistik paketi çalıştırılmadı |
| Analitik, atıf | `analytics/attribution` ilkeleri + mevcut taksonomi (13) |
| Otomasyon | Kendi MVP + `growth-ajan` yöntemi; test edildi |
| dataviz | Kullanılmadı (grafik üretilmedi) |
| Dış skill paketi kurulumu | Yapılmadı |
Bu oturumda `Skill` aracıyla yalnız `hupo-*` beş skill yüklendi (talimatla önceden); diğer uzman skill'ler çağrılmadı.

## 5. Doğrulama kayıtları (gerçekten yapılanlar)
| Kontrol | Sonuç |
|---|---|
| `python -I automation/tests/test_akis.py` | 14/14 geçti |
| `butce_modeli.py` çalıştırıldı | 27 satırlık CSV üretildi (`examples/butce_senaryolari.csv`) |
| `pazarlama_akis.py lint/gec/utm` DRY_RUN | Çalıştı; atlama reddedildi; dosya yazılmadı |
| Reklam metni harf sınırı (≤30 / ≤90) | Betikle kontrol edildi, ihlal yok |
| n8n JSON'ları ve şemalar | JSON ayrıştırma geçti; n8n'de import/çalıştırma **denenmedi** |
| Canlı site/mobil ekran incelemesi | **Yapılmadı** |
| Görsel/video üretimi | **Yapılmadı** (görsel kontrol yapılmadı) |
