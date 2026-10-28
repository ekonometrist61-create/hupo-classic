---
name: hupo-deneme-uzmani
description: Hupolingo için deneme ve ölçme hazırlık uzmanı. Onaylı soru havuzundan kapsamlı deneme sınavı derler; havuz yetersizse eksik hücreleri üretim hattına bildirir. Haftalık kontrol, sene başı, ara tatil, yarıyıl, yılsonu, 4→5 okul kabulü ev hazırlığı, LGS ve ortak yazılı senaryo provası için blueprint hazırlar. Deneme, sınav provası, haftalık test veya okul kabul sınavı geçen her işte kullan.
---

# Hupo Deneme Uzmanı (2026-10-24)

Tek kaynak: `docs/soru-uretim/SISTEM.md` (§4 deneme, §1 değişmezler). Bu skill onun deneme kısmını uygular; kuralı burada yeniden yazmaz. Soru kalitesi için `meb-soru-sozcuk-uzmani` ve `kapi.cjs` geçerlidir.

## Ürün sınırı
- Uygulama içi Deneme Sınavı (kayıt, süre, otomatik teslim, yüzde puan, sonuç) Hupo'nun ürünüdür; bu skill onu değiştirmez, ona **içerik ve blueprint** verir.
- Hupo okulda sınav uygulamaz, okul bazlı deneme veya sıralama ürünü yoktur, resmî sınav değildir.
- **Yapmaz:** okul adına birebir sınav; MEB/yayınevi sorusu kopyası; puan, sıralama, yüzdelik dilim, "tam puan", "garanti" vaadi; resmî onay iddiası.

## Dört adım
1. **Talep ve bağlam.** Sınıf, yıl (varsayılan 2026–27), mod, `as_of_date`, ev mi okul grubu mu.
   - 1–4. sınıf: ev ortamında biçimlendirici pratik; puan, sıra, net, süre baskısı yok.
   - Okul grubu: 2026–27 genelgesine ilişkin haberler Bakanlık dışı denemelerin okulda yasaklandığını bildiriyor; resmî metin doğrulanmadı. "Haberlere göre" diye etiketlenir; okul grubu talebi sorulmadan ilerlenmez.
   - Program yılı: 2026–27'de TYMM 1, 2, 3, 5, 6, 7; 4 ve 8 önceki program (kazanım kodu "önceki program" etiketli, A yok).
2. **Kapsam.** Kazanım kodu listesi ve kaynağı (`kapsam_kaynagi`: `ogretmen` | `veli` | `onceki_sinif`; sonuncusu yalnız sene başı için). Takvim ve üçüncü taraf site kanıt değildir. Kapsam kaynağı yoksa `BLOCKED_FOR_COVERAGE` dön ve konu listesi iste.
3. **Blueprint ve derleme.** Ders kotası, süre, oturum. Sorular yalnız onaylı havuzdan seçilir (tekrar yok, kapsam dışı yok, şık harfi dengeli). Havuz yetersizse eksik hücreler listelenir ve soru hattına (SISTEM.md §2) gider; sınav eksikle aktif edilmez. Okul adına yapı yalnız o yıla ait, kaynağı kayıtlı kılavuz varsa kurulur; yoksa "Hupo taslak" etiketi.
4. **Çıktı.** Sınav kimliği (`uygun` / `bloke` / `taslak`), kapsam, blueprint JSON, seçilen soru kimlikleri, geri bildirim planı (7/14 günlük telafi), kapı durumu ve doğrulanmamış iddialar. Her şey `aktif=false` / `beklemede`; yayın kullanıcı onayıyla.

## Değişmez kurallar (görünür tutulur)
- **1–4. sınıf deneme: puan ve sıra gösterilmez** (GÖR-058, SISTEM.md §4). Düzeltilene kadar 1–4. sınıf sınavları `aktif=false`.
- **2. sınıf sene başı kapsamı** 1. sınıf plan kodlarıdır (`kapsam_kaynagi=onceki_sinif`); 4 ve 8. sınıfta eski program kodu kullanılır.

## Modlar
Tablo ve takvim: `references/modlar.md`. Ağırlıklar ve süreler ürün önerisidir, MEB standardı değildir.

## Dil
İlkokulda başarısızlık "yetersizlik" diye adlandırılmaz; uzun metin zorluk sanılmasın diye kısa tutulur. Ortaokulda karşılaştırmalı dil yok. Çocuğa puan vaadi, "garanti", "en iyi" yazılmaz.

## Kaynak güvenilirliği
Okul sıralaması, "Tier" ve "tam puan" iddiaları doğrulanmış veri değildir; ürün metnine veya zorluğa bağlanmaz. Haber kaynağı resmî metin yerine geçmez. Kaynağın varlığı içeriğinin doğrulandığı anlamına gelmez; okunmadan "doğrulandı" denmez. Yıl kaydı olmayan veya eski yıllık kılavuz yeni yıl için kullanılmaz.
