# 15 Bütçe ve Tahmin (SENARYO modeli)

Durum: Taslak · Tarih: 2026-10-29 · Rol: CMO / Veri Analitiği · Bağımlı: 03, 08, 13, 19 · Model: `automation/scripts/butce_modeli.py` · Çıktı: `automation/examples/butce_senaryolari.csv`

**Hiçbir sayı Hupo verisi değildir.** Fiyat, huni oranları, TBM, büyüme **varsayımdır**. Model, girdileri değiştirince tekrar çalıştırılacak şekilde yazıldı (`python butce_modeli.py cikti.csv`, çalıştırıldı, 27 satır üretti). Bu belge kararı değil, duyarlılığı gösterir.

## 1. Varsayımlar (model girdileri)
| Girdi | Değer | Etiket / değiştirilecek kaynak |
|---|---|---|
| Fiyat (tek seferlik dönem erişimi, TL, KDV dahil) | düşük 400 / orta 700 / yüksek 1.000 | **Varsayım**; `plans` kaydı (admin) gelince değişir. Çıpa: basılı set 375–1.850 TL (tarihsiz, Kısmen) |
| Net gelir oranı (KDV + ödeme komisyonu sonrası) | 0,75 | Varsayım; muhasebe/iyzico sözleşmesi |
| Dönem sonu yeniden satın alma | %10 / %25 / %40 | Varsayım (K3); ilk kohort verisiyle |
| Ziyaretçi→demo tamamlama | %8 / 15 / 25 | Varsayım; PostHog (yalnız çerez onaylı alt küme) |
| Demo→veli kaydı | %5 / 12 / 20 | Varsayım |
| Kayıt→çocuk ilk oturum | %25 / 40 / 55 | Varsayım; aktivasyon tanımı 13 |
| Aktif→ücretli | %2 / 6 / 12 | Varsayım; K-0193 referans ölçümü |
| TBM (ücretli tık) | 6 TL | Varsayım; Meta/Google tahminleri doğrulanamadı |
| Başlangıç organik ziyaret | 300/ay, aylık büyüme %12 / 15 / 18 | Varsayım |
| Mevsim çarpanı | Oca 1,2; Haz 0,8; Eyl 1,4; Eki 1,3 | Hipotez |
| Ücretli reklam başlangıcı | 7. ay (Mayıs 2027) | Kapı kuralı |

## 2. Senaryolar (12 ay, orta fiyat varsayımı)
| Senaryo | Aylık bütçe | Toplam harcama | Kötü huni | Baz huni | İyi huni |
|---|---|---|---|---|---|
| **A Minimum** (kurucu + otomasyon, ücretsiz araçlar; 500 TL/ay araç) | 500 | 6.000 TL | 0,2 satış, CAC ~37.900 | **3,4 satış, CAC ~1.750**, LTV/CAC 0,37 | 26 satış, CAC ~230, LTV/CAC 2,9 |
| **B Dengeli** (2.500 TL/ay sabit + 7.500 TL/ay reklam Mayıs'tan) | 2.500–10.000 | 75.000 TL | 0,4 satış | **7,7 satış, CAC ~9.800**, LTV/CAC 0,07 | 58 satış, CAC ~1.300, LTV/CAC 0,51 |
| **C Agresif** (8.000 sabit + 30.000 reklam Mayıs'tan) | 8.000–38.000 | 276.000 TL | 0,9 satış | **19 satış, CAC ~14.500**, LTV/CAC 0,05 | 146 satış, CAC ~1.900, LTV/CAC 0,35 |
(LTV orta fiyat: net birim 525 TL, LTV ~656 TL; sabit giderler CAC'ye dahil edildi, "karma CAC".)

## 3. Okunması gereken sonuçlar
1. **Ücretli reklam, bu varsayımlarla ekonomik değil.** Başa baş: ücretli tık maliyeti / net birim gelir = 6 / 525 ≈ **%1,1 ziyaretçi→ücretli dönüşümü** gerekir (düşük fiyat %2,0; yüksek fiyat %0,8). Modeldeki iyi huni ziyaretçi→ücretli ≈ %0,33; baz ≈ %0,04. (Hesap: 0,25·0,20·0,55·0,12.) Sonuç: ücretli edinim ancak huni çok yüksek (ör. aktif→ücretli çok yüksek ya da fiyat yüksek) veya TBM çok düşük ise anlamlı. **Hipotez; gerçek ölçümle sınanır.**
2. **Tek seferlik fiyat modeli LTV'yi sınırlar:** aboneliğin tekrar eden geliri yok; LTV = dönem satışı × (1 + yeniden alım). Dolayısıyla CAC tavanı ≈ net birim gelir (orta fiyat ≈ 525 TL) olmalı; aksi halde "büyütmek" zarar eder.
3. **Geri ödeme süresi:** tek satışta "ilk satış CAC'yi karşılıyor mu" ölçüsü kullanıldı (`ilk_satis_CAC_karsiliyor`); abonelik aylık geri ödeme dili uygulanamaz.
4. **Strateji sonucu:** İlk 12 ayda ağırlık organik + referans kanıtı + dönüşüm iyileştirme; ücretli reklam yalnız (a) ödeme canlı, (b) aktif→ücretli oranı ölçüldü, (c) CAC tavanı hesaplandı, (d) ayrı onay verildiğinde, küçük (≤7.500 TL/ay) ve 4 haftalık durdurma kuralıyla. Senaryo C'yi bu veriyle önermiyoruz.
5. Model duyarlılık analizidir: fiyat ve aktif→ücretli en güçlü kaldıraç. Veri geldikçe `GIRDILER` güncellenir.

## 4. Kalem bazlı bütçe önerisi (Senaryo A taban, B isteğe bağlı)
| Kalem | A (TL/ay) | B (TL/ay) | Not |
|---|---|---|---|
| Araçlar (domain zaten var; ek: zamanlayıcı yok, Canva yok) | 0–500 | 500–1.000 | Remotion/HTML ücretsiz |
| Stok müzik/font | 0 | 0–500 | Yalnız telifsiz; Nunito/Inter OFL |
| Freelance video/montaj | 0 | 1.000–2.000 | Onaylı |
| Mikro etkileşim/anket ödülü | 0 | 0 | Çocuk/ödül yok |
| Ücretli reklam | 0 | 7.500 (Mayıs+) | Ayrı onay, `growth_harcama` manuel |
| Hukuk danışmanlığı (metin onayı) | (ayrı bütçe) | (ayrı) | Zorunlu önkoşul; tutar Doğrulanamadı |
Rakamlar tahmindir; Meta/Google gerçek tahmini yok (doğrulanamadı).

## 4b. Senaryo A taktik havuzu
Senaryo A'nın "organik büyüme" varsayımı (başlangıç 300/ay, aylık +%12) `20_TAKTIK_HAVUZU_ILK_1000.md` içindeki ICE ≥36 taktiklere (indeks paketi, pilot görüşmeleri, Shorts, şeffaflık günlüğü, onaylı veli toplulukları, mini araç) dayanır; taktiklerin trafik etkisi **ölçülmemiştir**, %12 büyüme bu yüzden bir **Varsayım**dır ve ilk 4 hafta verisiyle değiştirilecektir. Taktik maliyeti ≈ 0 TL (zaman); mağaza yayını ve Apple/Google kuralları 20 §1'de.

## 5. Nasıl güncellenir
1. `plans` fiyatını `FIYAT` içine yaz. 2. Referans ölçüm (GIE §33) sonrası `HUNI` baz değerlerini gerçekle değiştir. 3. `growth_harcama` toplamını `SENARYO.sabit/reklam` ile eşle. 4. Betiği çalıştır, CSV'yi karar toplantısına getir. 5. Kapı: karma CAC > net birim gelir ise ücretli büyütme yok.
