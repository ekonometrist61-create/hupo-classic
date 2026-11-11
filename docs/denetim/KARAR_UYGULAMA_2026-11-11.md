# GÖR-093 karar uygulaması (2026-11-11)

Kaynak: `scratchpad\gor093\karar_sonnet.md` (Sonnet 5.5 kararları), bulgular `docs/denetim/KALITE_ORNEKLEM_2026-11-10.md`. Kayıt: K-0243.

Kural (kararın kendisi): hiçbir kayıt yayına alınmadı, hiçbiri silinmedi, düzeltilen içerik yeniden insan onayı bekliyor.

## 1. Uygulanan

### Sorular (`questions`)
- `94621aad` (İngilizce, 8. sınıf): yayından indirildi (`onaylandi` → `beklemede`). Şık A düzeltildi. **Sonnet'in önerdiği "kendisine" yerine "bana" yazıldı**: "kendisine" arkadaşın kendine yardım ettiği anlamına gelir, yanlıştı. Çözüm adımları buna göre düzeltildi. Denetim alanına `yeniden_denetim_bekliyor` eklendi.
- `26075725` (8. sınıf): `beklemede` kaldı, `kaynak_durumu = source_pending` bayrağı eklendi. Anahtar değiştirilmedi.
- `d8779a77` (4. sınıf): `beklemede` kaldı, `yeniden_yaz_bekliyor` bayrağı eklendi (kazanım dışı sayı).
- `3ec6fd70`, `94ec072e`, `af3ebcd2`, `2d6274b0`, `70a03f85`: **dokunulmadı**. Beşi zaten `reddedildi`. Sonnet D1'de "beklemede" yazmış; bu bir insan reddini geri çevirirdi, yapılmadı.

### Hikâyeler (`okuma_hikaye_surumleri`)
- **D3, `H-dea9f9eb`**: 16. sayfa (yalnız editoryal notlar, "Kavramlar / Dil / Güvenlik") kaldırıldı, `sayfa_sayisi` 15'e indi. Yeni taslak sürüm (`5473cd59`) oluşturuldu, cevaplar yeniden dengelendi (`CBAD`). Eski yayında sürüm arşive alındı.
  - **Sonuç:** Bu hikâye şu an çocuk kataloğunda yok. Yeni sürüm onaylanana kadar kalacak.
- **D5, 61 hepsi-A yayında sürüm + 2 ikinci öncelik (≥%75 A)**: her biri için yeni taslak sürüm oluşturuldu. Toplam 63. Şık metinleri değişmedi; yalnız doğru şık harfi ve şık sırası karıştırıldı (hikâye başına tohumlu). Yayındaki sürümler **değişmedi**. Harf veya sıra referansı içeren soru yok (0 atlandı). Hepsi `insan = pending`, ajan A/B `pending`.
  - Doğrulama: 253 soruda 4 şık, harfler A–D tam, doğru harf geçerli. Hiçbir yeni taslakta hepsi-A yok.
  - Yayında sayısı 100 → 99 (yalnız D3).
- **D6, 4 kopya başlık**: 8 taslak sürüm arşive alındı (`durum = arsiv`). Yayındaki karşılıklar dokunulmadı.

## 2. Uygulanmayan (ve neden)

- **D4, `H-96491ac6` ve `H-9c974d9d`** (sabit adlar Ekin/Aras, Lalin/Narin): dinamik karakter yer tutucusuna çevirme **yapılmadı**. Ad çekimleri (Ekin'in, Ekin'e …) hal ekiyle birlikte değişiyor; otomatik değiştirme yanlış ek üretir. Yayındaki sürümler yerinde kaldı. Yeni taslak için hal ekli düzeltme gerekir; bunu ayrı bir adım olarak yapabilirim.
- **D2 ve D1'in yeniden yazım kısmı** (`70a03f85`, `2d6274b0`, `d8779a77`): yeniden yazım bir insan işi; yalnız bayrak eklendi.
- **D7, politika**: karar kayda geçirildi ama uygulanmadı. (a) `-sız/-siz` türevli zıt çiftler ve (b) yakın anlamlı çiftler kabulü, kapıyı belirleyen kod ve denetçi istemlerinde değişiklik gerektirir; ayrı onay ister. Sonnet'in "yeniden değerlendir" eylemleri de uygulanmadı: yeni denetim kaydı, gerçek bir denetim olmadan yazılmamalı. Etkilenen ilişkiler: `-sız/-siz` zıt çiftler 4 (rapordaki sayı), kapısı açık değil.
- **Sonnet'in belirsizlikleri**: 26075725 kaynağı, 70a03f85 ve 2d6274b0 yeniden yazım biçimi, D6 kopyalarının içerik farkı (arşivlenmeden önce tek insan bakışı önerildi; yapıldı, geri alınabilir).

## 3. Durum sayımı (uygulama sonrası)

- Sorular: yayında (`onaylandi`) sayısı bu iş için bir azaldı (`94621aad`). 5 reddedilmiş soru değişmedi.
- Hikâyeler: yayında 99, taslak 130, arşiv 128 (tüm tablo).

## 4. Geri alma

- Sorular: `94621aad` için `onay_durumu = 'onaylandi'` ve `siklar.A` (eski: "Ona her zaman yardım ettiğini") geri yazılabilir; onay yeniden insan kararıdır.
- Hikâyeler: arşive alınan sürümler `durum = 'taslak'` (ve `arsiv_at = null`) ile geri alınabilir. Yeni taslak sürümler silinebilir ama silme için ayrı onay gerekir.
