# 01 Ürün Denetimi ve Rekabet Avantajı Matrisi

Durum: Taslak (kod/belge okuma ile doğrulandı; canlı UX ve canlı DB okunmadı) · Tarih: 2026-10-29 · Rol: Ürün ve Rakip Analisti · Bağımlı: 02, 03, 04, 06, 19

Doğrulama sınırı: Repo belgeleri (`PROJE_GUNLUGU.md` pano, `DENEME_SINIR_KURALI.md`, `GIE_ANALIZ...`, `decisions.md`, `STRATEJI_DEGERLENDIRME.md`), `web-panel/src/messages/tr.json` (landing), `web-panel/src/app` rota listesi, `mobile-app/lib/screens` listesi, `docs/mufredat/README.md` okundu. Canlı site, canlı Supabase içerik sayıları, mağaza durumu **görülmedi** (playwright MCP bağlanmadı: "canlı UX denetimi çalışmadı").

## 1. Ürün özeti (Kanıtlı)
- Marka Hupolingo, maskot Hupo. Çocuk için kısa soru çalışması (günlük hedef 5–20, varsayılan 10), açıklama, ertesi gün tekrar listesi, XP, 40 karakter / 8 sınıf, Ay Ligi; veli için ders/konu bazlı özet ve tekrar önerisi, onaylı veri görünürlüğü.
- İlk odak: Ankara proje ortaokulu hazırlığı, 4→5 geçişi; kapsam 3–7. sınıf (landing). MEB 2026–27: TYMM 1,2,3,5,6,7; 4 ve 8 önceki program (kazanım kodu yürürlükte sayılmaz).
- Hosting Vercel; veritabanı Supabase; mobil Flutter (1.4.0+6); web Next.js (panel 0.4.0); ödeme iyzico 3D Secure, **tek seferlik satış, otomatik yenileme yok** (K-0196, `payments-checkout`).

## 2. Ürün envanteri (durum etiketli)

Etiketler: Canlı · Geliştirilmiş-yayınsız · Kısmen · Prototip · Planlı · Doğrulanamadı.

| # | Özellik | Durum | Kanıt | Pazarlamada kullanım |
|---|---|---|---|---|
| 1 | Landing + `/demo` (5 örnek soru, kayıtsız) | Canlı (Vercel production; robots `Disallow: /` olduğu için arama dışı) | `decisions.md` 2026-10-06/29, `DENEME_SINIR_KURALI` §8 | Ana CTA |
| 2 | Mobil uygulama (Flutter): ana ekran, quiz, tekrar, koleksiyon, lig, günlük görev, arena | Geliştirilmiş-yayınsız (mağaza yüklemesi yapılmadı, `key.properties` yok) | `DENEME_SINIR_KURALI` §8; GÖR-081 | "Yakında"; indir CTA yok |
| 3 | Öğrenci web uygulaması (app.hupolingo.com) | Kısmen/Doğrulanamadı (plan + `/ogrenci*` rotaları var; alan adı canlılığı doğrulanmadı) | `project_ogrenci_web_app` hafıza notu, `WEB_APP_SPEC.md` | Doğrulanana dek anılmaz |
| 4 | Veli paneli (ders, tekrar, başarılar, hedefler, çocuklarım, aktivite, üyelik) | Canlı (web) | rota listesi | Etiketli örnek rapor ile |
| 5 | Veli raporu: ders bazlı, az veriyle yüzde göstermeme (en az 6 soru) | Canlı | tr.json `report.insufficient` | Güçlü kanıt |
| 6 | Ücretli plan / ödeme (iyzico) | Geliştirilmiş-yayınsız: uçtan uca sandbox testi yok; migration 20261124 (ön bilgilendirme) uzağa uygulanmadı; hukuk onayı bekliyor (GÖR-078/082) | `decisions.md` 2026-10-09; PROJE_GUNLUGU GÖR-078/082 | Fiyat/ödeme CTA yok |
| 7 | 14 gün kartsız deneme + günlük 20 soru sınırı | Kısmen: DB + veli kartı deploy; **self-serve değil** (yalnız `admin_deneme_baslat`) | `DENEME_SINIR_KURALI`, GIE §34 | "Ücretsiz deneme" yasak |
| 8 | Premium gating (20 soru/gün) | Kısmen: uzakta uygulandı; hukuk onayı açık | `DENEME_SINIR_KURALI` §8 | Plan kapsamı admin kaydından |
| 9 | Kelime Evreni (eş anlamlı/zıt/eş sesli) | Kısmen: 48 soru "yayında" ama test ortamı, dil uzmanı incelemesi yok | hafıza notu `project_kelime_evreni` (koddan tam doğrulanmadı) | Anılmaz; "yakında" bile dikkatli |
| 10 | Okuma Dünyası / HupoRead ("Senin Hikâyen") | Prototip/pilot: 12 test hikâyesi arşivde, pilot sınıf [4,5], sayfalar `noindex` | `decisions.md` 2026-10-23, K-0124 | Anılmaz; pilot sonrası |
| 11 | Görselli soru motoru (SVG) | Prototip: hiçbir soru onaylı değil | `project_gorselli_devir` | Anılmaz |
| 12 | Deneme sınavı (ön kayıt, puanlama %0–100) | Kısmen: 5–8 için; 1–4 kapalı | `DENEME_SINIR_KURALI` §2 | Ön kayıt sayfası var; tarih/sınav yoksa vaat yok |
| 13 | Karakter koleksiyonu 40, ligler, rozetler | Geliştirilmiş (mobil); landing'de gösteriliyor | tr.json `characters` | Kullanılabilir (öğrenme sonrası motivasyon çerçevesinde) |
| 14 | Growth CRM, outbox, journey şeması | Kısmen: journey yürütme motoru yok, e-posta cron yok (E1–E7) | `ILETISIM_EKSIKLERI_PLANI` | Otomasyon bu yapıya EXTEND |
| 15 | A/B motoru + olay kaydı + karar kaydı | Kısmen (uzakta, web entegrasyonu I4 bloklu) | GIE §25–33 | Deney altyapısı var, trafik yok |
| 16 | Customer-Lab (sentetik persona), ML eşik | Kısmen/sentetik | GIE §21–24 | Sonuçlar kanıt sayılmaz |
| 17 | HupoMentor | Planlı (spec; hukuk onayı olmadan kodlanmaz) | GIE §19 | Anılmaz |
| 18 | Kişiselleştirilmiş öğretici hikâye | Prototip (Okuma ile aynı hat) | #10 | Anılmaz |
| 19 | Yapay zekâ özellikleri (öğrenci tarafı) | Doğrulanamadı: çocuk-yüzeyinde LLM sohbeti yok (MVP kuralı: sınırsız chat önerilmez). Soru üretimi AI+iki denetçi; üründe AI etiketi gösterilmez (kullanıcı kararı) | `project_soru_uretim` | "Yapay zekâ ile kişiselleştirme" iddiası **yazılmaz** |
| 20 | Soru bankası hacmi (yayında onaylı) | Doğrulanamadı (canlı DB okunmadı; 3 veli, 4 profil seviyesinde test) | — | Soru sayısı iddiası yok |

## 3. Yüzeyler ve kullanıcı yolculuğu (kod rotalarından)
Landing (`/`) → `/demo` → `/signup` veya `/veli-paneli/kayit` → veli hesabı → çocuk eşleştirme (6 haneli kod) → çocuk uygulamada kısa görev → veli paneli (özet, tekrar) → üyelik (plan, ön bilgilendirme, ödeme). Çocuk kendi hesabını açabilir; veli yalnızca ücretli plan alırken devreye girer (GÖR-079, ONAYLI karar; hukuk metni uyumsuzluğu açık).

## 4. Rekabet avantajı matrisi (taklit edilebilirlik)

| Avantaj | Taklit zorluğu | Durum | Sınıf |
|---|---|---|---|
| Veli için okunabilir, "az veriyle yüzde göstermeyen" rapor ve tekrar önerisi | Orta (tasarım kopyalanır, dürüst eşik disiplini ve kazanım etiketi veri ister) | Mevcut | Savunulabilir, **kanıtlanması gereken** (gerçek veli kullanımı yok) |
| Tek seferlik ödeme, otomatik yenileme yok (kod ile doğrulanmış) | Düşük (rakip değiştirebilir) | Mevcut ama yayınsız | Kısa vadeli fark |
| Çocuk yüzeyinde reklam/konum/takip yok; veli onaylı veri | Orta | Mevcut | Güven farkı; kanıtı denetlenebilir olmalı |
| MEB 2026–27 yıllık plan + kazanım etiketleme altyapısı (3.805 etiket, hafta bazlı) | Yüksek emek | Geliştirilmiş (etiketleme kapsamı eksik) | **Geliştirilebilir** moat |
| Özgün blueprint-first soru üretimi + iki bağımsız denetçi + insan onayı kapısı | Yüksek (süreç ve kalite verisi) | Süreç var, hacim/kalite kanıtı doğrulanamadı | **Kanıtlanması gereken** |
| Karakter/lig/oyunlaştırma | Düşük | Mevcut | Farklılaşma **yetmez** (rakipler kopyalar; çocuk motivasyonu için gerekli, veli için satış nedeni değil) |
| Birinci taraf öğrenme verisi | Zamanla yüksek | Henüz yok (pilot) | Geliştirilebilir |
| Ürünler arası bütünleşme (soru + kelime + okuma + deneme) | Orta | Dağınık, çoğu pilot | Geliştirilebilir |

Sonuç: Tek başına oyunlaştırma yeterli farklılaşma **değildir**. Savunulabilir eksen: *veliye dürüst ve görünür öğrenme ilerlemesi + kısa günlük rutin + güven*. Detay 03/04.

## 5. Çelişkiler ve açık noktalar (19'a taşındı)
1. `decisions.md` 2026-10-09 "iddialar kalsın" ↔ 2026-10-29 çözüm: güven rozetleri **yok**; kod değişikliği yayın öncesi listede (Y2).
2. Landing `pricing` bölümünde Ücretsiz/Premium/Aile kapsam listesi (tr.json) onaylı plan kaydı değil; `family` "6 aile üyesine kadar" gibi iddialar plans tablosuyla doğrulanmadı.
3. `hero.badge` "3–7. Sınıf · Proje Ortaokulu Hazırlığı" ↔ ilk odak 4→5; FAQ "öncelikli odağımız".
4. `hikayeler.not`: "iki bağımsız yapay zekâ denetimi" cümlesi hem üründe AI etiketi gösterilmeme kararıyla hem şeffaflık ilkesiyle gerilim taşır; kullanım öncesi karar gerekir.
5. Çocuk ekranındaki "Velime mesaj hazırla" akışı mağaza politikası (Apple 3.1.1 / Google) açısından kontrol edilmedi (GÖR-081).
6. App/panel dokümanlarında "AI destekli adaptif öğrenme" ifadesi geçer; kodda çocuk yüzeyinde adaptif model doğrulanamadı.
