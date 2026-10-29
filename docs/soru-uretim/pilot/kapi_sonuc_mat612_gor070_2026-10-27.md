# Kapı sonucu: MAT.6.1.2 (6. sınıf Matematik) · GÖR-070 · 2026-10-27 (güncel)

Kimlik: school_year 2026-2027 · grade 6 · subject Matematik · curriculum_status TYMM · kazanim_kodu MAT.6.1.2
Durum: **otomatik kapılar ve kör çözüm geçti; ikinci denetim pass; insan denetimi bekliyor.** `published=false`. DB'ye yazılmadı.
Soru dosyası: `docs/soru-uretim/pilot/uretim_mat612_gor070_2026-10-27.json` (6 soru)
Blueprint: `docs/soru-uretim/BLUEPRINT_GOR070_MAT612_2026-10-27.md`
Yedek taslak (K-0153, değiştirilmedi): `docs/soru-uretim/pilot/uretim_matematik_6_mat612_taslak.json`

## 1. Kazanım kaynağı
- Resmî kaynak: 2026 Maarif DÖP, Matematik (5-8), PDF 67. ve 69. sayfalar (metin katmanı). Çıkarılan metin: `meb_mat6_dob_mat612_2026-10-27.txt`.
- Ana cümle ve a, b, c, ç, d alt maddeleri resmî metinle eşitlendi (`kazanim_6_matematik.json`).
- `program_surumu` etiketi "2026 Maarif Modeli Matematik (5-8) DÖP, 6. sınıf bölümü" olarak düzeltildi.
- Aynı "5. sınıf DÖP" etiketi `kazanim_6_fen.json` ve `kazanim_6_sosyal.json` dosyalarında da var; kaynak PDF'leri doğrulanmadan dokunulmadı (ayrı iş).

## 2. Otomatik kapı (`soru_kontrol.mjs`, güncel betik)
| Kontrol | Sonuç |
|---|---|
| Kapsam (kod) | 1 kod, kapsam dışı 0 |
| Kazanım metni kaynakla | 6/6 uyumlu |
| Dayanak pasajda birebir | 6/6 |
| Kanıt düzeyi A (kural) | 0/6 — matematik kazanımları A-adayı değil (betik güncellendi: yalnız T.O.* A'ya çıkabilir) |
| Doğru şık en uzun | 0/6 |
| Hepsi/Hiçbiri, olumsuz kök, metne referans | 0 |
| Cevap dağılımı | A0 B2 C3 D1 |
| Benzerlik (6-gram, mevcut MAT.6 kayıtları) | 0 |
| Sorunlar | yok |

Betik değişikliği: `kuralSeviye` içinde kazanım kodu `T.O.` ile başlamıyorsa kanıt B. Bu, SKILL.md kanıt tablosunun ("A adayı: kazanım okuma çözümlemesi ise") betik karşılığıdır; tablo değişmedi.

## 3. Şema ve sayısal doğruluk
- Her soru 4 şık, tek doğru cevap; `dogru_sik` şıklarda var.
- Sayısal iddialar bağımsız hesapla doğrulandı (115÷5; 1215 ve 417 ÷3; 3148 ÷4; 6 = 2·3; 18÷4 = 4,5; 24, 40, 100 ÷4 tam).

## 4. Kör çözüm (Gemini `gemini-3.8-flash`, yalnız kök ve şıklar)
- 6/6 anahtarla uyuştu (son set).

## 5. İkinci denetim (Gemini, doğru şıklar ve çeldirici gerekçeleriyle)
- 6/6 pass (son set, 103 ve 105 dâhil).
- Ek geçiş (taze Claude Sonnet, yalnız soru, şıklar ve çeldirici gerekçeleri): 102–106 pass; 101 review_needed (zayıf çeldiriciler). 101'in şıkları yeniden yazıldı (2503, 362, 115, 247); kapı 6/6 uyumlu; kör çözüm (Gemini) 101 için C, anahtarla uyumlu. Yeni 101 için ikinci Sonnet geçişi yapılmadı.
- Not: Denetçi ve kör çözücü aynı model ailesi (Gemini). "Farklı model ailesi" koşulu tam karşılanmıyor.

## 6. Hücre kapsamı ve sınırlar
- Her hücrede bir soru: C1 (5), C2 (10), C3 (3), C4 (4), C5 (6), C6 (genelleme sınaması).
- Pilot ölçüt 5–8; 6 yeterli. C5 ve C6 için ek soru insan denetimi sonrasına bırakıldı (yeni sorular tüm kapılardan yeniden geçer).

## 7. Açık noktalar
1. **İnsan denetimi** (yayın öncesi zorunlu). Yayın, onay kaydı ve `published=true` kararı kullanıcıya aittir.
2. **Zorluk etiketi** tahmini; kesinleştirme öğretmen denetimi ve pilot öğrenci verisiyle yapılır. Zorluk vekili ölçülmedi.
3. **Bağımsızlık:** Kör çözüm ve ikinci denetim aynı model ailesinden. Farklı aileden (ör. taze bir Claude oturumu) çeldirici denetimi, insan denetiminin yerini tutmaz ama değerli bir ek kontrol.
4. **Kazanım kaynağı:** `kazanim_6_matematik.json` 24 kazanımın yalnız MAT.6.1.2'sinin alt maddeleri resmî metinle eşitlendi; diğer kodlar kırpık kalmaya devam ediyor.
5. **Hedef dağılımı:** 4. sınıf yuvarlama/bölünebilme ve 8. sınıf üslü sayı hedefleri kaynakta 2026-27 TYMM dışında (önceki program); GÖR-055 kararına bağlı. 2–3. sınıf Türkçe eş/zıt hedefi K-0151 gereği bekletildi.

## 8. Sonraki düzeltmeler (2026-10-27, taze Claude denetimi sonrası)
Taze Claude oturumu (Sonnet, önceki kayıtları okumadan) çeldirici denetimi yaptı: 101, 104, 106 PASS; 102, 103, 105 REVIEW. Cevap anahtarı hatası yok.
- 102 A/B/D ve 103 C/D gerekçeleri yeniden yazıldı.
- 105 kök cümlesi sadeleştirildi ("Bir bahçedeki ağaç sayısı hem 2 ile hem de 3 ile tam bölünüyor…"); 105 A gerekçesi düzeltildi.
- 105 kökü değiştiği için yalnız bu soru Gemini kör çözümünden yeniden geçti: D = D.
- Şıklar, doğru şıklar ve pasaj metinleri değişmedi. Bu bölümden önceki kapı sonuçları (2–5) bu düzeltmelerden önceki metin için geçerlidir; 105 için kör çözüm bölüm 8'de yenilenmiştir.
- Bağımsızlık: çeldirici denetçisi Claude, kör çözücü Gemini (iki farklı aile). İnsan denetimi (kapı 7) hâlâ açık.
