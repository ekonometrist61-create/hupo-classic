# HR-017 · Mahallenin En Hızlı Bisikleti · düzeltme önerisi (sürüm 4 adayı)

Tarih: 2026-10-25 · Hazırlayan: asistan (`llm_taslak`) · Onay: insan editör bekleniyor
Durum: **DB'ye hiçbir şey yazılmadı.** Mevcut sürüm 3 (sha `28ff45bb…`) taslak olarak olduğu gibi duruyor. Bu klasördeki `paket-surum4-aday.json` yalnızca aday dosyadır.

## Önceki değerlendirmemin düzeltmesi
Önceki mesajımda HR-017'nin Ajan A'da "kritik bulgu yok" olduğunu yazmıştım. Bu eksik bir bilgiydi:
- 2026-10-24 raporları yalnızca hikâye metnini değerlendirmiş, **soruları değerlendirmemiş** (`denetim-girdi/HR-017.txt` sorularını içeriyor, raporlar bunlara değinmiyor).
- 2026-10-23 Ajan A ve B'nin **kritik** bulgusu (s2 cevap anahtarı metinle çelişiyor) güncel sürümde hâlâ geçerli.
- Bu yüzden 2026-10-24'teki `pass`/`review_needed` sonucu HR-017 için soru kalitesi açısından güvenilir değil.

## Bulgular ve aday değişiklikleri

| # | Kaynak | Bulgu | Aday |
|---|---|---|---|
| 1 | 10-23 A+B, kritik | s2 doğru şığı ("geç başlamak") metinle çelişiyor: iki çocuk "yan yana başladı", neden de verilmemiş | s2 yeniden kuruldu: "Kahraman neden görevliye seslendi?" Doğru: arkadaşına yardım etmek. Kök olayı kendi içinde verir. |
| 2 | 10-24 B orta; 10-23 B orta | Sayfa 6 vaaz cümlesi: "O yıldız ona hızdan çok arkadaşlığı hatırlatıyordu." | Çıkarıldı. s3 bu cümleye dayanıyordu; s3 yeniden kuruldu (kök olayı verir, okurdan yorum ister). |
| 3 | 10-24 B orta | Sayfa 7 son cümlesi dersi tekrarlıyor | Son sayfa tek görüntüyle bitiyor: "Gidondaki yıldız, pencereden giren ışıkta parlıyordu." |
| 4 | 10-24 B düşük | Babanın "nasıl göründüğüne değil…" cümlesi ders gibi | Sadeleştirildi; "nasıl" ikonu kaldırıldı. |
| 5 | 10-24 A düşük | Zincir düzeldikten sonra güvenlik kontrolü yok | Görevli bisikleti kısaca kontrol ediyor. |
| 6 | 10-23 A+B | Kask ve fren kontrolü sayfa 1 ve 2'de tekrarlanıyor | Kontrol yalnız sayfa 2'de. Sayfa 1 afişle bitiyor. |
| 7 | 10-23 B | Mert tanıtılmadan giriyor | "Komşumuz Mert'in bisikleti…" |
| 8 | 10-23 B | "start", "finiş" yabancı sözcük (2. sınıf için) | "başlangıç çizgisi", "bitiş çizgisi" |
| 9 | 10-23 B orta | Atasözü mekanik ekleniyor ("…derlerdi.") | Mert'in sözü olarak, iki çocuğun bisikleti birlikte tuttuğu sahnenin hemen ardından. |
| 10 | 10-23 B orta | Dört sorunun cevabı A; s2 ve s4'te doğru şık en uzun | Cevaplar sırayla A, C, B, A, C. Hiçbir doğru şık en uzun değil. |
| 11 | 10-23 B | s3 "yorumlama" etiketli ama cevap sayfadaki cümlenin aynısı (hatırlama) | s3 gerçek bir yorum sorusu oldu (#2). |
| 12 | 10-23 B | s4 kökü bozuk ("eski sözcüğü" tırnaksız); bağlam kökte yok | Kök bağlam cümlesini içeriyor, tırnaklar düzeldi. |
| 13 | 10-23 A düşük | Sözlük "eski" tanımı ile s4 şıkkı farklı tanım veriyor | Sözlük ve s4 aynı tanıma getirildi: "Uzun süre kullanılmış…" |
| 14 | 10-23 A orta | "Denge" kavramı metinde işlenmiyor, sözlükte yok, hiçbir soru ölçmüyor | Hedef listesinden çıkarıldı. **Karar gerekli (1).** |
| 15 | 10-23 B | Atasözü hedefi (application) hiçbir soruda ölçülmüyor | Hedef `background` olarak düşürüldü. **Karar gerekli (2).** |
| 16 | 10-23 B | "yeni" hedefi ölçülmüyordu | s5 eklendi. |
| 17 | 10-23 B | Mert'in "Hızlı olmak zorunda değilsin…" cümlesi öğüt gibi | "Acele etme, yavaş sür!" |
| 18 | 10-23 B | "bir çizginin üzerinden dikkatle geçebiliyordu" belirsiz | "yere çizilen düz bir çizgi boyunca sapmadan gidebiliyordu" |

## Aday soru seti

| Soru | Beceri | Sayfa | Doğru | Not |
|---|---|---|---|---|
| s1 | hatırlama | 1 | A | Boya soruşu; şıklar değişti, A artık en uzun değil |
| s2 | çıkarım | 4 | C | Yeni kurgu (#1) |
| s3 | yorumlama | 6 | B | Yeni kurgu (#2); kök olayı içerir |
| s4 | sözcük bağlamı | 1 | A | Hedef: eski |
| s5 | sözcük bağlamı | 2 | C | Yeni; hedef: yeni |

Kök kuralı: her soru, öğrencinin çözmek için gereken olayı kökte verir (skill kuralı 14). Dayanak cümleleri metinde birebir geçer.

## Editörün kararı gereken noktalar

1. **"Denge" hedefi.** Önerim: çıkarılması. **ONAYLI (2026-10-25).** Aday pakette yok.
2. **Atasözü hedefi.** Önerim: `background` olarak kalması (sahnede doğal kullanılıyor). **ONAYLI (2026-10-25).** Aday pakette `background`.
3. **s2 kurgusu.** Metne "neden" eklemek de mümkündü, ama bu hem sahneyi hem öğretiyi değiştirir: "yardım edersen yarışı kaybedersin" gibi bir ders çıkar (10-23 B bunu öngörmüştü). Bu yüzden önerilmedi.
4. **Son okuma.** Skill'e göre üçüncü göz insan okumasıdır. Yayın kararı bu öneriden ayrıdır.

## Yapılan kontroller

- Dayanak birebir: 5/5 (geçici kontrol betiği `hr017_kontrol.mjs`, yalnız bu oturumda; depoya eklenmedi).
- Doğru şık en uzun değil: 5/5. Şık sayısı 3, doğru cevap dağılımı A2, B1, C2.
- `olculen` tutarlı: sayfa 7, soru 5, beceri dağılımı, hedef türleri, yoldaş 2, simge 4. Kelime sayısı 199 (aynı yöntemle mevcut sürüm 215 çıkıyor; yazılı değer 214).
- Hedef kapsamı: eski → s4, yeni → s5, atasözü → `background` (ölçülmesi gerekmez).
- Doğrulayıcı kuralları (sayfa, soru, şık, enum, yuva, ikon sınırları) elle karşılaştırıldı; uyumlu.

## Yapılmayanlar (dürüst liste)

- **`soru_kontrol.mjs` çalıştırılamadı.** Araç her soruda dört şık bekliyor; bu sorularda üç şık var. Kazanım kodu da yok: 2. sınıf resmî metni bu depoda yok (skill: `source_pending`). Bu nedenle kanıt düzeyi A verilmedi, `C` kaldı.
- **Sunucu doğrulayıcısı çalıştırılmadı.** `okuma_paket_ice_aktar` admin oturumu ister; ben bir admin oturumuyla çağıramıyorum. Kuru çalıştırma (`p_kuru=true`) hata varsa hiçbir şey yazmaz.
- **Kör çözüm yapılmadı** (skill, farklı bir model ailesi ister).
- **Yeni denetim yapılmadı.** Yeni sürüm `pending` olarak girer; 2026-10-23/24 sonuçları ona geçmez.

## Sonraki adımlar

1. Yukarıdaki iki kararı ver (Denge, atasözü) ve s2 kurgusunu onayla.
2. Hikâye Atölyesi'nin içe aktarma sekmesinde `paket-surum4-aday.json` dosyasını önce **kuru çalıştır**. Hata yoksa yaz. Sonuç: yeni taslak sürüm 4; sürüm 3 aynen kalır.
3. Yeni sürümü bağımsız olarak denetle (Ajan A ve B, kör), sonra insan okuması.
4. Yayın kararı ayrı bir adımdır; bu belge yayın onayı değildir.
