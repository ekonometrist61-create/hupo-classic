# Hikâye denetim planı · HR-121 – HR-132 · 2026-11-08

Tarih: 2026-11-08
Kapsam: Ajan A ve Ajan B raporu olmayan 12 hikâye (HR-121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132).
Kaynak: `icerik/okuma/hikaye/hr121-…` – `hr132-….hikaye.md` (12 dosya; her biri kendi içinde ön bilgi, sorular ve metni taşır).

## 1. Kapsam tespiti

- `icerik/okuma/hikaye/` altında 104 hikâye dosyası var.
- `docs/okuma-entegrasyon/denetim/` altında HR-001–HR-114 için Ajan A/B raporları var (2026-10-23 ve 2026-10-24 klasörleri).
- **HR-121–132 için hiçbir Ajan A/B raporu yok.** Bu 12 hikâye 2026-10-25 grup denetimlerinde (`grup-9.md`, `grup-10.md`; tek denetçi, farklı biçim) yalnız gözden geçirildi. Bu ayrı bir denetimdir; A/B yerine geçmez.

## 2. Ayrı not: eski A/B raporları (bu turun kapsamı dışında)

HR-015–HR-114 (92 hikâye) için A/B raporları var ama hikâye dosyalarının değişim tarihi (2026-10-25 / 10-27) raporlardan (2026-10-24) sonra. 10-25 grup denetimlerinde metinlere düzeltme yapıldı. Yani bu 92 hikâyenin A/B raporları eski metne ait. Bunlar "denetlenmemiş" değil ama "güncel metin için denetlenmiş" de değil. Kullanıcı kararı gerekir: tüm 92 hikâyenin yeniden A/B denetimi (yaklaşık 184 rapor) ayrı bir tur olarak planlanabilir. Bu tur bu kararı beklemez; yalnız 12 hikâyeyi kapsar.

## 3. Denetim yöntemi

- **Bağımsızlık:** Ajan A ve Ajan B birbirini, grup raporlarını ve önceki A/B raporlarını okumaz. Her denetçi yalnız kendi hikâye dosyasını okur.
- **Roller:** `DENETIM_TALIMATI.md` (2026-10-23) aynen geçerlidir.
  - Ajan A: olgu ve doğruluk; sözlük anlamları, deyimler, soru cevap anahtarları ve dayanaklar, kurgu tutarlılığı, `kanit_duzeyi` ile iddia uyumu.
  - Ajan B: sınıf uygunluğu, güvenlik ve içerik, vaaz, edebi kalite, soru kalitesi (şık dengesi, cevabın metinden bulunabilirliği), etiket tutarlılığı.
- **Yalnız okuma:** denetçi hikâye, paket, sözlük veya veritabanı dosyası değiştirmez. Yalnız kendi rapor dosyasını yazar.
- **Mekanik taban çizgisi:** `node tools/okuma-hikaye-denetim.mjs --ayrinti` ön kontrol olarak çalıştırıldı. 104 hikâyede sorusuz hikâye yok, karşılıksız ad yok, art arda tekrar yok. Dağılım A=108 / B=108 / C=108 / D=107. Bu sonuçlar A/B yerine geçmez; denetçilere bilgi olarak verilmez (kör kalsınlar).
- **Kanıt kuralı (talimat ile uyumlu):** Ajan A dışında hiçbir denetçi kanıt düzeyi tablosunu değiştirmez. Olgusal iddia doğrulanamıyorsa "doğrulanamadı" yazılır, uydurulmaz.

## 4. Gruplama ve paralellik

| Grup | Hikâyeler | Ajan A raporu | Ajan B raporu |
|---|---|---|---|
| G1 | HR-121, 122, 123, 124 | `HR-121…124-ajan-a` | `HR-121…124-ajan-b` |
| G2 | HR-125, 126, 127, 128 | aynı biçim | aynı biçim |
| G3 | HR-129, 130, 131, 132 | aynı biçim | aynı biçim |

- Her grup için iki denetçi (A ve B) ayrı ajan olarak çalışır: toplam 6 ajan, paralel.
- Her ajan 4 hikâye okur. Bu uzunluk tek oturumda dikkatin kaybolmasını önler (104 hikâye tek seferde değil).

## 5. Rapor biçimi ve yolu

- Yol: `docs/okuma-entegrasyon/denetim/2026-11-08-hr121-132/HR-XXX-ajan-a.md` ve `HR-XXX-ajan-b.md` (her hikâye için iki dosya; toplam 24 rapor).
- Biçim: `DENETIM_TALIMATI.md` içindeki şablon.
- Karar kuralları (talimat):
  - `pass`: kritik ve yüksek bulgu yok; yalnız düşük/orta düzeyde not var.
  - `review_needed`: yüksek ya da birden fazla orta bulgu var, ya da uzman/yazar teyidi gereken iddia var.
  - `fail`: kritik bulgu var (olgusal hata, metinle çelişen cevap anahtarı, çocuğa uygunsuz içerik, güvenlik riski).

## 6. Ölçüt ve sonraki adımlar

- Yayın için iki ajanın `pass` vermesi ve insan onayı (`approved`) gerekir. Bu rapor yalnız ajan kararıdır.
- `review_needed` ya da `fail` çıkan hikâyeler düzeltmeye gider; düzeltme yapılınca yalnız o hikâye yeniden denetlenir.
- Kullanıcı üçüncü göz olarak son okumayı yapar (talimatın 3 göz kararı).
- Yayın kapısı (`published=false`, `editor_approved=false`) hiçbir ajan raporuyla değiştirilmez.

## 7. Çıktılar

- 24 rapor (`HR-121…132`, A ve B).
- `ozet.md` (bu klasörde): hikâye bazında iki ajanın kararı, bulgu sayıları ve açık kararlar.
- `ogrenme-gunlugu.md` girişi (skill'in öğrenme döngüsü).
