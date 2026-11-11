# Kalite örneklemi: AI denetim kararları (GÖR-093)

Tarih: 2026-11-10 · Kayıt: PROJE_GUNLUGU.md K-0242 · Karar: kullanıcı (insan örneklemi, REHBER §15 ile birlikte)

Yazılan kitle: proje ekibi ve insan inceleyici. Bu belge denetim kararlarının doğruluğunu ölçer; yayın ve düzeltme kararı vermez.

## 1. Yöntem

- **Kapsam (uzak DB, salt okunur):** `questions.denetim` içinde `ajan_c` bulunan 151 soru; `okuma_hikaye_surumleri.denetim` içinde `ajan_c` bulunan 145 hikâye sürümü; onaysız 118 kelime ilişkisi.
- **Örneklem (tohumlu, rastgele):** soru 32 (6 hedef: `fail` ve kör çözüm uyuşmazlığı; 16 `pass`; 10 `review_needed`), hikâye 10 (2 `fail`, 4 `pass`, 4 `review_needed`), kelime ilişkisi 18 (12 kapısı açık, 6 kapısı kapalı).
- **Kör değerlendirme:** Önce yalnızca içerik okundu (cevap anahtarı, denetim alanları ve kayıt notları gizli), sonra kayıtla karşılaştırıldı.
- **Yapısal tarama (tüm kayıtlar):** sözlük ve yuva bütünlüğü, cevap anahtarı dağılımı, başlık çakışması, yayın durumu ile denetim kararının çaprazı.
- **Sınır:** Değerlendiren bir Claude modeli, insan değil. Örneklem küçük; oranlar kaba tahmindir (rastgele kısımda n=26). İnsan örneklemi (REHBER §15) ayrıca gerekir.

## 2. Sorular (32 örneklem)

### 2.1 Yayındaki (onaylı) sorularda hata

| Soru | Sınıf | Sorun | Kayıt |
|---|---|---|---|
| `3ec6fd70` | 4 | Anahtar A (35 207). Doğru: C (35 027), 3×10000+5×1000+2×10+7. | 3 denetçi `review_needed`, onaylı |
| `94ec072e` | 5 | Anahtar B (6000). Doğru: C (6100), 3984≈4000, 2117≈2100. | 3 denetçi `review_needed`, onaylı |
| `af3ebcd2` | 8 | Anahtar A (kuvvetten kazanç artar). Doğru: B, kuvvet kolu kısalır, kazanç azalır. | Ajan A ve B `pass` (notları "çözüm B, anahtar A" diyor), onaylı |
| `2d6274b0` | 2 | A ve D de bağlaç "ki" olarak doğru yazılmış; birden fazla doğru şık. | Ajan C `fail`, onaylı |
| `70a03f85` | 6 | A (3'üncü) ve B (üçüncü) ikisi de doğru. | Ajan C `fail`, onaylı |
| `94621aad` | 8 (İng.) | A şıkkı "Ona her zaman yardım ettiğini"; kaynak "helps me" = "bana". Çeviri hatası. | Ajan A ve C `pass`, onaylı |
| `26075725` | 8 | Anahtar C (Sakarya). Kaynak cümlesi "makûs talih" hangi savaşa ait, metinle doğrulanamadı. | 3 denetçi `review_needed`, onaylı |

Bu yedi sorunun her birinde en az bir denetçi `review_needed` ya da `fail` demişti. Onaylar denetim sonucunu geçersiz kılmış; bu bir insan kararıdır, ama kaydın bilinmesi gerekir.

### 2.2 Onaysız (beklemede) soru

| Soru | Sınıf | Sorun | Kayıt |
|---|---|---|---|
| `d8779a77` | 4 | 302 400 sayısı M.4.1.1.2 ("10 000'e kadar") kazanımının dışında. Ajan B notunda "kazanım uyumsuz" yazıyor ama `pass` veriyor. | Ajan A ve B `pass`, Ajan C `review_needed` |

### 2.3 Kalite sorunları (yanlış değil, düzeltilmeli)

- Kök ya da doğru şık ipucu veriyor: `05e2838a` ("Günde" tekrarı), `458dcfe7` ("emanet" tekrarı), `4a444c4d` ("tarihî" tekrarı). Denetçi C doğru yakalamış.
- Çeldiriciler zorluk düzeyine göre zayıf: `0a08661e` (8. sınıf, zorluk 3), `44853558`, `498dd494` (7. sınıf).
- Denetçi C'nin `review_needed` gerekçesi zayıf, soru doğru: `de630f60` (kök üslubu), `e1926325` ve `e8e8968c` (çok kolay). Bunlar zorluk etiketiyle çözülür.

### 2.4 Sayılar

- Örneklemde yanlış `pass` (denetçi hatası): 3 (`af3ebcd2`, `94621aad`, `d8779a77`).
- Örneklemde fazla temkinli `review_needed`: 3 (`de630f60`, `e1926325`, `e8e8968c`).
- Rastgele 26 soruda sorunlu içerik: 2 (`94621aad`, `d8779a77`), yaklaşık %8. Güven aralığı geniş; kesin oran değildir.
- Tüm 151 soruda cevap anahtarı dağılımı: A 65 (%43), B 58, C 19, D 9. C ve D düşük; dağılım tahmin edilebilir.
- 151 soruda kör çözüm anahtarla uyuşmayan 4 soru var. Dördü de onaylı; üçünde ajanlar `review_needed` vermişti, `af3ebcd2`'de A ve B `pass` vermişti.

## 3. Hikâyeler (10 örneklem)

| Hikâye | Durum | Denetim | Benim görüşüm |
|---|---|---|---|
| `H-56989361`, `H-f7630c4a` (2. sınıf, bisiklet) | taslak | 3 × `fail` | Doğru karar. Sözlük boş, yuva eksik (`s2_eski`, `s2_yeni`, `ata_elin_nesi`). Aynı metin iki tür altında (macera, spor). |
| `H-7c022e5c` (2. sınıf, tavşan) | taslak | A, B `review`; C `pass` | C yanlış `pass`. Sözlük boş, yuva eksik. |
| `H-b125e713` (2. sınıf, robot) | taslak | 3 × `review` | Doğru karar. Sözlük null, 4 sorunun 4'ü de A. |
| `H-400f0ed0` (4. sınıf) | taslak | A, C `pass`; B `review` | Pass. Metin ve dört yapısal bağ tutarlı. |
| `H-59ec1055` (5. sınıf) | taslak | A, C `pass`; B `review` | Pass. |
| `H-c89dff19` (5. sınıf) | taslak | A, C `pass`; B `review` | Pass. |
| `H-96491ac6` (8. sınıf) | yayında, insan onaylı | 3 × `review` | Cevaplar doğru. Sabit ad (Ekin, Aras) dinamik karakter kuralını bozuyor. |
| `H-9c974d9d` (8. sınıf) | yayında, insan onaylı | 3 × `review` | Cevaplar doğru. Sabit ad (Lalin, Narin) aynı sorun. |
| `H-dea9f9eb` (5. sınıf) | yayında, insan onaylı | A `pass`; B, C `review` | 4 sorunun cevabı A. 16. sayfada "Kavramlar / Dil / Güvenlik" editoryal notları hikâye metninin içinde, öğrenci görüyor. Denetçi C doğru yakaladı. |

### 3.1 Tüm hikâye kayıtları (yapısal tarama, 145 sürüm)

- **Sözlük boş ve yuva eksik: 52** (hepsi taslak, insan `pending`). Bunların **24'ü** denetçi C'de `pass` almış. Yapısal kontrol denetimde yok.
- **Yayındaki 70 hikâyede** yapısal eksik yok.
- **Cevap anahtarı A yanlılığı:** yayındaki hikâyelerin 49'unda (sorusu olan 70'in 49'u) tüm cevaplar A. Yayındaki 306 cevabın 241'i A (%79). Bu, sistemik bir sorun: öğrenci tahminle doğru cevabı bulabilir.
- **Başlık çakışması:** 4 başlıkta yayındaki kayıtla aynı başlıkta ayrı taslak hikâye kaydı var: "Kapadokya'nın Gizli Geçidi", "Anka'nın Kaybolan Tüyü", "Yedi Renkli Köprünün Koruyucusu", "2040'ın Konuşan Okul Çantası". Kopya mı yeni sürüm mü, insan kontrol etmeli.

## 4. Kelime ilişkileri (18 örneklem)

- **Kapısı açık (12):** 12'si de Claude ve Gemini `pass` veriyor; benim görüşüm de `pass`. Uyum 12/12.
- **Kapısı kapalı (6):**
  - `anlatmak–açıklamak`: `review_needed`. Benim görüşüm de aynı; anlam farkı var.
  - `başarı–başarısızlık`, `tutarlı–tutarsız`, `bilinçli–bilinçsiz`: Gemini-C `fail`, gerekçe "-sız/-siz türevi zıt anlamlı değildir". Benim görüşüm `pass`: bu çiftler pedagojik olarak zıt anlamlı kabul ediliyor. Politika kararı gerekiyor.
  - `tehlike–risk`, `mutlu–sevinçli`: Gemini `review_needed`, gerekçe "tam eş anlamlı değil". Benim görüşüm `pass`: yakın anlamlı çiftler eş anlamlı kabul ediliyor. Politika kararı gerekiyor.
- **Uyum:** 13/18. Beşi politika farkından, Claude denetimi kendi görüşümle uyumlu.
- **Etki:** 118 onaysız ilişkide `-sız/-siz` türevli zıt çift 4 tane; bunlardan hiçbiri kapısı açık değil. Politika kararı az sayıda ilişkiyi etkiliyor ama kapı kuralını da belirliyor.

Ayrıca: `bilinçli` anlamı "kasıtlı" olarak verilmiş. TDK tanımıyla birebir örtüşmüyor, gözden geçirilmeli.

## 5. Kararlar (kullanıcıda)

1. **Yayındaki 7 hatalı ya da belirsiz soru:** yayından indirilsin mi (`onay_durumu` → `beklemede`)? Anahtarlar düzeltilip yeniden denetlensin mi? Ajan indirmeyi yapmaz; onay ister.
2. **Yayındaki hikâyeler:** `H-dea9f9eb` editoryal metni çıkarılsın mı? `H-96491ac6` ve `H-9c974d9d` sabit adları dinamik karaktere çevrilsin mi?
3. **Cevap anahtarı A yanlılığı (49 hikâye, 241/306):** yayındaki hikâyelerin cevap dağılımı dengelensin mi? Bu içerik değişikliği, yeniden insan onayı ister.
4. **Kopya başlıklar (4):** taslak kayıtlar silinsin mi, yeni sürüm mü olsun?
5. **Yapısal kapı:** denetim kuralına "sözlük ve yuva bütünlüğü" kontrolü eklensin mi? Bu kod değişikliği, ayrı onay ister.
6. **Politika:** (a) `-sız/-siz` türevli zıt anlamlı çiftler kabul edilsin mi? (b) "yakın anlamlı" çiftler eş anlamlı sayılsın mı? Kelime kapısı bu kararı bekliyor.
7. **İnsan örneklemi (REHBER §15):** bu belgedeki örneklem listesi insan inceleyicisine verilebilir.

## 6. Ara dosyalar

Repo dışında: `scratchpad\gor093\` (örneklem listeleri, kör paketler, anahtar dosyaları). Yeniden üretim için tohum 20261110 (soru, hikâye) ve 20261111 (kelime).
