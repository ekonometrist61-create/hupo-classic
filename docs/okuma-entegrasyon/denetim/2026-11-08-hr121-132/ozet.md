# Hikâye denetim özeti · HR-121 – HR-132 · 2026-11-08

Plan: `PLAN.md` (bu klasör). Raporlar: `HR-XXX-ajan-a.md` ve `HR-XXX-ajan-b.md` (24 dosya). Denetçiler bağımsızdı; her biri yalnız kendi hikâyesini ve kendi rolünü okudu.

## Karar tablosu

| Hikâye | Ajan A (olgu) | Ajan B (kalite) | Yüksek bulgu (B/A) | Yayın durumu |
|---|---|---|---|---|
| HR-121 | pass | review_needed | 0 | Yayınlanamaz (B) |
| HR-122 | pass | review_needed | 0 | Yayınlanamaz (B) |
| HR-123 | review_needed | review_needed | 0 | Yayınlanamaz (A, B) |
| HR-124 | pass | review_needed | 0 | Yayınlanamaz (B) |
| HR-125 | review_needed | review_needed | 1 / 1 | Yayınlanamaz (A, B) |
| HR-126 | pass | review_needed | 0 | Yayınlanamaz (B) |
| HR-127 | review_needed | review_needed | 0 | Yayınlanamaz (A, B) |
| HR-128 | pass | review_needed | 1 (B) | Yayınlanamaz (B) |
| HR-129 | pass | review_needed | 0 | Yayınlanamaz (B) |
| HR-130 | pass | review_needed | 0 | Yayınlanamaz (B) |
| HR-131 | pass | review_needed | 1 (B) | Yayınlanamaz (B) |
| HR-132 | pass | review_needed | 0 | Yayınlanamaz (B) |

Sayılar: `fail` yok (kritik bulgu yok). Ajan A: 9 pass, 3 review_needed (HR-123, 125, 127). Ajan B: 12 review_needed, pass yok.

Yayın kuralı: iki ajan `pass` + insan onayı gerekir. Hiçbir hikâye iki ajandan `pass` almadı; bu nedenle hiçbiri yayın adayı değil.

## Yüksek bulgular (düzeltme öncelikli)

- **HR-125 (A ve B):** Ritim çizelgesi tutarsız. Kuralda yavaş damla uzun çizgi, ama sayfa 2–3'te yavaş ses dört nokta / üç nokta + kare olarak çizilmiş. Okur hangi kodun hangi sesi taşıdığını takip edemiyor. Bu, olgusal bir tutarsızlık ve sorular bu çizelgeye bağlıysa cevap anahtarını da etkileyebilir.
- **HR-128 (B):** Kahramanın iç sesi doruk noktasında ahlak dersini doğrudan veriyor (sayfa 5). Cümle çıkarılmalı.
- **HR-131 (B):** Sayfa 5'te ders diyalogda ve sonda (replik ve son paragraflar). Replik kaldırılıp sahne eylemle bitirilmeli.

## Ortak bulgular (Ajan B)

- Vaaz tonu ve sonda "öğrendi/fark etti" kalıbı birçok hikâyede (121, 122, 124, 126, 129, 130, 132).
- Soru kalitesi: şık uzunluğu dengesi (doğru şık en uzun), bazı kökte olmayan bilgiye gönderme ve sahne ile çelişen cevaplar.
- Yazım ve noktalama düzeltmeleri (de/da, ki, virgül) düşük–orta düzeyde.

## Ajan A'nın review_needed kararları

- **HR-123:** İki orta bulgu, olgusal ya da cevap anahtarı teyidi gerekiyor (ayrıntı raporda).
- **HR-125:** Yüksek ritim tutarsızlığı (yukarıda).
- **HR-127:** İki orta bulgu, soru dayanağı ya da olgusal ayrıntı (ayrıntı raporda).

## Sonraki adımlar (öneri)

1. Her hikâye için raporlardaki yüksek ve orta bulgular düzeltilir; düzeltme metni değiştirir, bu yüzden yalnız ilgili hikâye yeniden denetlenir.
2. Yeniden denetim sonrası iki ajanın `pass` vermesi aranır; ardından insan okuması (üçüncü göz) ve `approved` kararı.
3. Ayrı tur (karar bekliyor): HR-015–114 için 92 hikâyenin A/B raporları 10-24 tarihli, metinler 10-25/10-27'de değişti. Bunların yeniden A/B denetimi kullanıcı kararı.

## Sınırlar

- Denetim yalnız ajan kararıdır; yayın onayı değildir. `published`, `editor_approved` ve `curriculum_verified` alanları değiştirilmedi.
- Hikâye, paket ve sözlük dosyaları değiştirilmedi.
- Tek Ajan A raporunda web araması kullanılıp kullanılmadığı ayrıca doğrulanmadı; raporların "Doğrulanamayan iddialar" bölümlerine bakılmalı.
