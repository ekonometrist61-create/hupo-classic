# Modül paketleri, maliyet ve başabaş (2026-10-29) — store-only, şirketsiz senaryo

Durum: ÖNERİ. Tüm TL/USD dönüşümleri 1 $ = 45 TL varsayımıyla (kontrol et). Vergi katsayısı doğrulanmadı.

## 0. Modeli değiştiren bulgular
1. **Şirketsiz = yalnız mağaza (IAP).** iyzico web ödemesi, ortak komisyon ödemeleri ve fatura/makbuz için vergi mükellefiyeti gerekir (SMMM kaynağı: önce şahıs/sermaye şirketi). Şirketsiz yolda web checkout ve ortak sistemi (docs/is-ortagi) ertelenir; ortak indirimi için ancak Apple offer code / Google promo code kullanılabilir, atıf elle olur.
2. **Doğrulanan komisyon:** Apple %15 yalnız Small Business Program'a kaydolursa (yıllık yeniden başvuru; yoksa abonelikte ilk yıl %30). Google abonelikte %15. "Bankanın %15 kesmesi" ayrı bir şey: doğrulayamadım; %15 gelir vergisi ilk dilimi veya stopaj karışıyor olabilir. Modelde **temkinli ek %15 vergi tamponu** (τ) iki senaryoda gösterildi. SMMM onayı şart.
3. **USD fiyat:** mağazada Türkiye için fiyat TL'dir; `plans.para_birimi` zaten yalnız 'TRY'. USD'yi iç hedef birimi olarak kullan; TL fiyat noktalarını üç ayda bir kur ve maliyetle yeniden belirle. Apple'ın USD'den otomatik çevirisi Türkiye için ~₺450 (9,99 $) üretir; yerel rakipler ₺149. Türkiye fiyatını elle gir.
4. **Kodda modül yetkisi yok:** tek `is_premium` bayrağı ve günlük soru kotası var; `plans.ozellikler` yalnız gösterim metni. Modül paketleri için yetki katmanı (plan→modül eşlemesi, kontroller) yazılmalı.

## 1. Modül maliyeti
Tahmini trafik (MB/aktif kullanıcı/ay, ölçülmedi): Okuma 12, Soru-Cevap 6, Kelime Evreni 5, Deneme 4, Çarpma 0,5 → toplam ~28 MB. Kota üstü trafik 0,09 $/GB → **modül başına marjinal maliyet ~0,001 $/ay**; tüm paket ~0,003 $/ay. Modüller arası maliyet farkı yok: fark içerik üretimi (sabit, zaman + Gemini) ve destekte. Bu yüzden **fiyat maliyetten değil değerden ve giriş bariyerinden çıkar**; maliyet yalnız taban (mağaza + vergi + sabit giderler) belirler.

## 2. Paketler ve fiyat (TL mağaza fiyatı → USD karşılığı)
| Paket | İçerik | Aylık | Yıllık | USD (yıllık) |
|---|---|---|---|---|
| Tek Modül (Okuma / Kelime / Çarpma) | 1 modül | 69,99 | 449,99 | ~10 |
| Sınav Paketi | Soru-Cevap + Deneme | 129,99 | 899,99 | ~20 |
| Hupo Tam (hedef paket, vurgulu) | 5 modül | 149,99 | 1.199,99 | ~26,7 |
| Aile Tam | 3 çocuğa kadar | — | 1.799,99 | ~40 |
Çapa: iki tek modül (899,99) ≈ Sınav; Tam yalnız 300 TL fazla → Tam doğal yükseltme. Tam yıllık, aylığın 12 katından %33 ucuz. 14 gün deneme tam erişim; sonrası günlük 20 soru ücretsiz katman.
Rakip: Papağanca ₺899/yıl (~20 $), Ev Okulu ₺1.299 (~29 $), Prodigy 59 $, Lingokids 72–90 $.

## 3. Abone başına net (TL fiyat × katsayı; KDV %20, komisyon %15)
Katsayı: τ=%15 ile 0,6021; τ olmadan 0,7083.
| Paket | Net/ay (τ ile) | Net/ay (τ yok) |
|---|---|---|
| Tek modül aylık | 0,94 $ | 1,10 $ |
| Tek modül yıllık | 0,50 $ | 0,59 $ |
| Sınav aylık / yıllık | 1,74 / 1,00 $ | 2,05 / 1,18 $ |
| Tam aylık / yıllık | 2,01 / 1,34 $ | 2,36 / 1,57 $ |
| Aile yıllık | 2,01 $ | 2,36 $ |
Karma varsayımı: %60 Tam yıllık, %15 Tam aylık, %15 Sınav yıllık, %10 Tek modül yıllık → ortalama net 1,31 $ (τ ile) / 1,53 $ (τ yok) abone/ay.

## 4. Sabit gider basamakları (USD/ay)
| Basamak | Kalemler | Toplam |
|---|---|---|
| 0 Yayın | Claude 20, Apple 8,25 (99 $/yıl), alan adı 1, Gemini içerik ~20, beyan/muhasebe ~10 (tahmin); Google Play 25 $ bir kez | ~59 |
| 1 Ticari başlangıç | + Supabase Pro 25 + Vercel Pro 20 | ~104 |
| 2 Büyüme | + Brevo ücretli ~12 + Supabase compute ~30 + kısmi destek ~40 | ~190 |
Tetikleyiciler: Supabase Ücretsiz'in 5 GB trafiği ≈ 170–500 aktif kullanıcı (10–30 MB/kullanıcı), ayrıca 500 MB DB, yedek yok. Vercel Hobby ticari kullanıma kapalı (blog kaynağı). Brevo ücretsiz günde 300 e-posta ≈ ~1.500 kişiye haftalık bülten. Compute ~5–10 bin aktif kullanıcı.

## 5. Başabaş abone sayısı
| Basamak | τ ile | τ yok |
|---|---|---|
| 0 (59 $) | 45 | 39 |
| 1 (104 $) | 80 | 68 |
| 2 (190 $) | 146 | 124 |
%5 dönüşümle 80 ücretli abone ≈ 1.600 aktif kullanıcı. Ücretsiz altyapı sınırı 170–500 kullanıcıda biter (~8–25 abone) → bu aralıkta aylık yaklaşık 25–70 $ cepten açık.
Tam yüklü birim maliyet 500 abonede ≈ 0,21–0,38 $/abone/ay; Tam yıllık net 1,34 $ → ~%75+ brüt marj.

## 6. Şirketleşme eşiği (K3)
Web ödemesi (iyzico ~%4,2) mağazadan (%15) abone başına ~0,2 $/ay daha ucuz (ortalama brüt ~2,17 $/abone/ay). Şirket/muhasebe yükü ~60–110 $/ay varsayımıyla, tüm satış web'e kayarsa ~300–560 abonede başa baş; ama Apple uygulama içinden dış ödeme bağlantısına izin vermez, satışın yalnız bir kısmı web'e kayar → pratikte ~1.000+ abone. Ortak sistemi de bu karara bağlıdır.

## 7. Kararlar
1. Apple Small Business Program kaydı (zorunlu, yayın öncesi).
2. SMMM: mağaza gelirinin vergi yolu, τ gerçek değeri, şahıs şirketi ne zaman.
3. Kodda modül yetkisi katmanı yazılsın mı (paketleme önkoşulu).
4. İlk sürüm paketleri: yalnız Tam + Sınav + Tek modül mü, Aile sonra mı.
5. Vercel Hobby ticari sınırı: Pro'ya ne zaman geçilecek.
