# İş Ortağı (Affiliate) Programı — Strateji ve Sistem Planı

Tarih: 2026-10-29 · Durum: ÖNERİ (karar bekliyor) · Hazırlayan: MAR-OTO-AI
Not: Plan fiyatı, KDV, iyzico komisyonu, stopaj oranı ve itiraz süresi doğrulanmadı; tüm sayılar VARSAYIMDIR. `payments-callback` ve `docs/growth-crm/*` tam okunmadı.

## 1. Karar
Evet, ama dar ve ölçümlü: tek seviyeli, performans bazlı, süre sınırlı, bekleme (hold) süreli, manuel ödemeli. Ömür boyu komisyon, otomatik ödeme çekme ve okula para "bağışı" ile BAŞLAMA.
Koşul: ödeme akışı canlı + hukuk onaylı (GÖR-078/082) ve şirket/fatura yolu hazır olmadan program açılmaz. O zamana kadar yalnız D0 (karar, hukuk, sözleşme) ve şema hazırlığı.

## 2. Repodan çıkan gerçekler
1. K-0196: ödeme tek seferlik; abonelik/otomatik yenileme yok → "yinelenen aboneliğin komisyonu" yok; komisyon, aynı velinin her yeni dönem satın alımına bağlanır.
2. Tutar sunucuda `plans.fiyat_kurus`'tan hesaplanır → komisyon da sunucuda, `payments` kaydından.
3. `coupons/campaigns/coupon_redemptions` var (REUSE). Ama migration başlığına göre 6 iç fonksiyon gövdesi canlıdan değil tahminle kurulmuş → ortak işinden önce canlıyla karşılaştır.
4. `growth_households` + `hane_ilk_temas_yaz(p_utm)` ilk-temas hattı var → ortak atfı buna bağlanır (EXTEND).
5. Çocuk yüzeyinde kod/indirim/ortak görünmez (GÖR-081, Apple 3.1.1). Kod yalnız veli web'de.

## 3. Birim ekonomi (varsayım: yıllık plan 1.200 TL brüt, KDV hariç 1.000; davetli indirimi %15 ilk alımda; sağlayıcı %3,5; değişken maliyet 40 TL/dönem)
| | Kötü | Orta | İyi |
|---|---|---|---|
| Komisyon | %30 ömür boyu | %20 ömür boyu | %15 ilk 12 ay |
| İade+chargeback | %8 | %5 | %3 |
| Yeniden alım | %25 | %40 | %55 |
| Net katkı (ortaklı) | ~611 | ~841 | ~1.033 |
| Brüt marj | ~%60 | ~%71 | ~%76 |
| Başabaş artımsallık | ~%50 | ~%36 | ~%29 |
Kodlu alıcıların en az %29–50'si ortak olmasa gelmeyecek kişi olmalı; altında program zarar yazar. Kolları: komisyon süresi sınırlı; indirim+komisyon ilk alımda KDV hariç tahsilatın ~%40'ını aşmasın; komisyon yalnız hold sonrası ve iade edilmemiş ödemeden; yenilemede indirim yok; ilk 3 ay pilot tavanı.

## 4. Hukuk (hepsi danışman onayı gerektirir)
- KVKK: ortak çocuk/veli kimliğini görmez; yalnız toplulaştırılmış sayılar, <5 ise "5'ten az"; aydınlatma metni + VERBİS güncellenir.
- ETK: ortak toplu SMS/e-posta atamaz; davet yalnız ortağın kendi kanalında paylaşım bağlantısıyla.
- Ödeme: gerçek kişiye serbest meslek makbuzu/arızi kazanç (stopaj doğrulanmalı), şirkete fatura. Hupo'nun vergi/şirket statüsü belli olmadan başlanmaz.
- Öğretmen: devlet memuru için 657/28 ve MEB etik riski; okulda/sınıfa doğrudan yönlendirme yok; ilk pilota alınmaz, ayrı görüş.
- Okul: karşılığı olan ödeme "bağış" değildir. Özel okul/dershane = fatura karşılığı hizmet bedeli; kamu okulu = MEB görüşü gelmeden para yok.
- Reklam: ortak ilişkisinin açıklanması zorunlu; kazanç/puan/sınav garantisi yasak.
- Sözleşme, sürümlü kabul kaydı, iade halinde komisyon geri alma maddesi.

## 5. Psikoloji ve pazarlama
- Ortak motivasyonu: fayda, statü (kurucu ortak rozeti), topluluk; gelir ana mesaj değil, "pasif gelir" dili yasak.
- Davetli: tek sayılı indirim, gerçek fiyat ve indirim aynı alanda, "ortak komisyon alır" bilgisi görünür, sahte sayaç/sosyal kanıt yok.
- Segmentler (pilot): eğitim içerik üreticileri, veli topluluğu yöneticileri. Sonra özel öğretmen, dershane/özel okul. Kamu okulu en son.
- UTM: `utm_source=ortak`, `utm_medium=<kanal>`, `utm_campaign=<kod>`, `utm_content=<materyal>`.
- Olaylar: `ortak_kodu_acildi`, `ortak_kodu_uygulandi`, `ortak_kayit_tamamlandi`, `ortak_satin_alma_tamamlandi`, `ortak_komisyon_onaylandi`, `ortak_odeme_yapildi`.

## 6. Sistem
Tablolar: `partners`, `partner_odeme_bilgisi` (şifreli, yalnız admin), `partner_codes` (kupona bağlı), `partner_attributions` (hane başına tek, kilitli), `commission_ledger` (append-only, UNIQUE(payment_id, tür)), `partner_payouts`, `partner_events_agg`, `partner_fraud_flags`, `school_programs` (Faz 3).
Atıf: girilen kod kazanır, bağlantı kodu 30 gün; ilk satın almada kilitlenir; komisyon süresi 12 ay veya ilk iki ödeme. Self-referral: aynı hane/e-posta kalıbı/cihaz özeti/kart → "incelemede".
Defter: başarılı ödemede RPC → `kazanc` (KDV hariç net × oran, oran parametre tablosundan), hold 30 gün; iade/chargeback → negatif `geri_alma`; eşik 500 TL; ödeme: makbuz/fatura → admin onayı → manuel EFT → dekont no.
Güvenlik: fail-closed RLS, SECURITY DEFINER + `search_path=''`, revoke/grant, ortak çocuk tablolarına erişemez (negatif test), şüpheli komisyon otomatik ödenmez.
Ekranlar: `/is-ortagi` gösterge, kodlarım, kazanç, ödeme, materyal, şartlar. Mobil app'te yok.

| Dilim | Kabul kriteri |
|---|---|
| D0 karar/hukuk/sözleşme | 8 karar yazılı, hukuk-muhasebe onayı belgede |
| D1 ortak+kod+atıf | indirim görünür, atıf tek ve kilitli, self-referral reddi |
| D2 defter+callback | tek `kazanc`, idempotent, iade→`geri_alma`, hold sonrası kullanılabilir |
| D3 ortak paneli | yalnız kendi toplulaştırılmış verisi, <5 maske |
| D4 admin onay/ödeme | başvuru, talep→onay→dekont, audit |
| D5 fraud+olaylar | şüpheli satır incelemede, PII analytics'te yok |
| D6 pilot | 10–20 ortak, kod tavanı, 90 gün, artımsallık + iade raporu |

## 7. Maliyet (tahmin)
Geliştirme MVP ~25–32 iş günü (okul programı +8–10). Hukuk teklif alınmalı (varsayım 30–80 bin TL, doğrulanmamış). Muhasebe aylık ek iş. İşletme maliyeti ihmal edilebilir; komisyon yalnız satış olunca doğar.

## 8. Kırmızı çizgiler
Tek seviye (MLM yok), kazanç vaadi yok, sahte sosyal kanıt yok, puan/sınav garantisi yok, çocuk yüzeyinde ortak/kod yok, öğrenci verisi ortağa gitmez, "otomatik yenileme komisyonu" dili yok.

## 9. Kullanıcı kararları (öneri)
1. Vergi/şirket yapısı ve ortak ödeme yolu → önce muhasebeci.
2. Komisyon: %15–20, ilk 12 ay veya ilk iki ödeme.
3. Davetli indirimi: %10–15 yalnız ilk alım.
4. 30 gün hold, 500 TL eşik, aylık manuel EFT.
5. Öğretmen ortaklığı → hukuk görüşünden sonra; pilotta içerik üretici + veli topluluğu.
6. Okul yolu → Faz 3; bağış değil hizmet bedeli; kamu okulu görüşsüz açılmaz.
7. Pilot: 10–20 ortak, 90 gün, tavanlı.
8. Ödeme canlı olana kadar yalnız D0 + şema hazırlığı.

## 10. Maliyet senaryoları (2026-10-29, tüm TL değerleri VARSAYIM)
Alıcı başına 2 dönem, KDV hariç: ortaksız katkı 1.218 TL; kodlu alıcı katkısı 844 TL (indirim %15, komisyon %20 = 237 TL, iade %5, yeniden alım %40, sağlayıcı %4,2, değişken 56 TL). Kodlu alıcı başına kâr = 1.218·s − 374 (s = ortak olmasa gelmeyecek pay). Başabaş s ≈ %31.
| Senaryo | Ortak / kodlu alıcı (yıl) | Komisyon nakit çıkışı | Sabit yıllık maliyet (geliştirme hariç) | Net s=%20 / %40 / %60 |
|---|---|---|---|---|
| A Pilot | 15 / 150 | ~36 bin | ~91 bin | −110 / −74 / −38 bin |
| B Orta | 100 / 1.500 | ~356 bin | ~197 bin | −393 / −27 / +338 bin |
| C Büyük | 500 / 10.000 | ~2,38 milyon | ~610 bin | −1,91 mn / +522 bin / +2,96 mn |
Sabit kalemler: hukuk 55–80 bin (tek sefer), muhasebe 3–10 bin TL/ay, ödeme/destek operasyonu (500 TL/saat fırsat maliyeti), altyapı ek maliyeti ~0–60 bin. Geliştirme: 25–32 iş günü; dışarıdan alınırsa günlük 8–15 bin TL varsayımıyla 200–480 bin TL.
Altyapı (doğrulanan): Supabase Pro 25 $/ay (8 GB DB, 250 GB egress, 100 bin MAU dahil); Vercel Pro 20 $/kişi; Resend Pro 20 $/ay (günde 100 e-posta üstü); Sentry Team 26 $/ay. iyzico oranı sözleşmeye göre (kaynaklar %2,49–2,79 + 0,25 TL) — plan %4,2 (KDV dahil, taksit payıyla) ile muhafazakâr.
Sonuç: pilot kendini finanse etmez, deney bütçesidir; asıl belirleyici s ve operasyon yüküdür. Ölçek büyüyünce ödeme operasyonu (ortak başına ~5 dk/ay) darboğaz olur → üç aylık ödeme veya eşik artışı.
