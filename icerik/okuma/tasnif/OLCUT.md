# HupoRead hikâye tasnif ölçütleri (taslak, 2026-10-22)

Bu dosya `hikaye-tasnif.csv` içindeki kademe ve bölüm önerilerinin nasıl hesaplandığını açıklar.

## 1. Uzunluk ölçütü

- Üst sınır kaynağı: proje içi `sema/etiket-sozlugu.v1.json` → `sinif_olcutleri.kelime` (üst değer).
  - 3. sınıf 330 · 4. sınıf 450 · 5. sınıf 650 · 6. sınıf 800 · 7. sınıf 950 · 8. sınıf 1100
- Bu değerler dosyada "PILOT_HEDEF, MEB kotası değildir" diye işaretli.
- Web araması (2026-10-22): sınıf düzeyine göre sesli okuma hızı için resmî bir MEB tablosu bulunamadı. Bulunan çalışmalar farklı birim ve örneklem kullandığı için bu tabloya doğrudan bağlanmadı.

## 2. Kademe

| Kademe | Kural (kelime / üst sınır) | Bölüm önerisi |
|---|---|---|
| T1 uyumlu | ≤ 1,0 | 1 |
| T2 hafif uzun | 1,0–1,5 | 2 |
| T3 uzun | 1,5–3,0 | ⌈oran⌉ |
| T4 çok uzun | > 3,0 | ⌈oran⌉ |

Bölüm önerisi, her bölümün sınıfın üst sınırının altında kalacağı en küçük sayıdır.

## 3. Ölçütün sınırları

- **Çelişki:** Son parti dosyasındaki HR-111/112 "Hedef kelime aralığı: 4.000–5.000" diyor. 120'lik üretim ve ara durum dosyaları da benzer geniş aralıklar kullanıyor. Bu, proje içindeki pilot aralıkla (8. sınıf: 1100) açıkça çelişiyor. Karar kullanıcıda.
- Bu tasnif yalnızca uzunluğu ölçer. Deyim/atasözü içeriği ve sözlük yükü hikâye bazında ayrıca okunmalı (henüz yapılmadı).
- Sınıf bilgisi kaynak dosyadaki `**Sınıf:**` satırından alındı. Satırı olmayan hikâye yok.
- Kelime sayımı yaklaşıktır: başlıklar, tablo, liste ve `**` ile başlayan satırlar sayılmaz.

## 3a. Uzunluk kararı (2026-10-22, proje sahibi yetkisiyle)

- Hikâyeler **bölünmez, metne dokunulmaz**. Her hikâye tek `.hikaye.md`; uygulama sayfalara böler (üst sınır 40 sayfa).
- Gerekçe: bölme anlatı yapısına müdahaledir ve editör onayı gerektirir. Uzun hikâyeler kademeyle işaretli kalır; bölme kararı editöryel adıma bırakılır.
- T4 hikâyeler yayın öncesi "uzun hikâye" uyarısı taşır.

## 4. Sürüm notu

- HR-111 ve HR-112 iki sürümde var: `v1` (kaynak/HR-111.md, HR-112.md) ve `v2` (kaynak/p16-son-parti-HR111-112.md). Hangisinin esas alınacağı kullanıcı kararıdır.
