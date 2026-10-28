# Sözcük Çekirdeği — analiz ve Ar-Ge planı (2026-10-25)

Hedef: 1–8. sınıf için MEB'e uygun sözcük envanterini (tür, anlam, örnek cümle, zorluk, puan) veri tabanında tek yerde tutmak; **Kelime Evreni**, **Arena (arkadaşa meydan okuma)** ve **hikâyeler** aynı sözcük kaydından beslensin.

Bu belge plandır; hiçbir veri tabanı değişikliği yapılmadı. Ölçülen değerler 2026-10-25'te uzak DB'ye salt-okunur sorguyla ve yerel dosyalardan alındı.

## 1. Mevcut durum (ölçüldü)

| Konu | Değer | Kaynak |
|---|---|---|
| Kelime Evreni anlam / ilişki / soru (uzakta) | 232 / 118 / 118 | DB sorgusu |
| Onaylı ilişki, **yayındaki soru** | **0 / 0** | DB sorgusu |
| Hikâye sözlüğü girdisi (uzakta) | 997 (kelime ≈801, deyim ≈197), **onaylı: 0** | DB sorgusu |
| Hikâye sayısı | 112 | DB sorgusu |
| Hikâye sözlüğünde benzersiz yazım | 754 (498'i tek hikâyede geçiyor) | `icerik/okuma/sozluk` |
| Kelime Evreni ile hikâye sözlüğü **ortak sözcük** | **15** (218 / 754) | yerel karşılaştırma |
| Hikâye dosyalarında eş / zıt ilişkili girdi | 201 / 138 | `*.iliski.json` |

Sonuç: **Kelime Evreni ve Arena'nın kelime modu bugün oynanamaz** (yayında soru yok; dört göz kuralı tek yöneticiyle yayına izin vermiyor). İki sözcük sistemi birbirinden kopuk.

### Boşluklar

1. **Sözcük türü:** `kelime_anlamlari.sozcuk_turu` yalnız 6 değer (isim, sıfat, fiil, zarf, bağlaç, diğer); zamir, edat, ünlem, sayı yok. Hikâye sözlüğünde (`okuma_sozluk_girdileri`) **hiç yok**.
2. **Örnek cümle:** `sinif-N.json` kayıtlarında var, ama DB'de `kelime_anlamlari`nda sütun yok; veri DB'ye taşınırken kaybolmuş. Hikâye sözlüğünde de yok.
3. **Zorluk:** `kelime_sorulari.zorluk` yalnız sınıftan türetiliyor (`uret-soru-migration.mjs:64`: 1–4→1, 5–6→2, 7–8→3). Sözcüğün gerçek zorluğunu ölçmüyor; aynı sınıftaki tüm sorular aynı XP'yi veriyor.
4. **Puan:** Kelime Evreni XP'si zorluğa bağlı 10/20/30; Arena `doğru×4−yanlış`, XP yok. Sözcük başına puan kavramı yok.
5. **Hikâye bağı:** `okuma_sozluk_girdileri` ile `kelime_anlamlari` arasında bağ yok. Hikâyede görülen sözcük oyuna girmiyor, oyunda öğrenilen sözcük hikâyede işaretlenmiyor.
6. **Kapsam inceliği:** Kelime Evreni ilişkileri sınıf başına 8–20 (1. sınıf 8, 2. sınıf 12). Yalnız eş anlamlı / zıt anlamlı / eş sesli; deyim, atasözü, bağlamda anlam, sözcük türü soruları yok. Yalnız "tanıma" becerisi kayıtlı.
7. **Onay boşluğu:** Sözlük girdisi için onay RPC'si yok (K-0141 açık). 1000+ girdi onay bekleyecek.

## 2. Kurallar ve program tuzakları (skill + CLAUDE.md)

- **Program yılı:** 2026–27'de TYMM 1, 2, 3, 5, 6, 7. **4 ve 8 önceki program**; bu sınıflarda TYMM kodu (`T.O.4.x`, `T.K.8.22.b`) yürürlükte sayılmaz, `source_pending`. **Çelişki:** `kelime_mufredat_kazanimlari` içinde 4 ve 8 için TYMM biçiminde kodlar var (`T.O.4.2.h`, `T.K.8.22.b`). Faz 0'da düzeltilecek.
- **1–3 ve 4. sınıf resmî ilkokul metni depoda yok** (`docs/meb/` yalnız ortaokul 5–8). 1–3 için kazanım kodları kaynakta görülene kadar `source_pending`. README "2026 ilkokul programı" PDF'ine atıf yapıyor ama dosya repoda değil.
- **5–8:** eş/zıt/eş sesli ortak kazanım T.K.x.22.b; kod yalnız resmî metinde görüldüğü için A adayı. A için yine kanıt cümlesi gerekir; "çıkarım var" gibi tür eşleşmesi A değildir.
- **Telif:** MEB sözlüğü yok; anlam tanımları TDK/yayınevi sözlüğünden kopyalanmaz, özgün yazılır (dilbilgisi.net / TDK yalnız doğrulama için bakılır).
- **Yayın kapısı:** iki bağımsız denetçi `pass` + insan onayı → `published`. Varsayılan taslak. Hakem, üretici modelden farklı aileden olur.
- **Soru kuralları** (bağlam kökte, şık dengesi, ipucu cevabı açmaz, tek doğru) sözcük soruları için de geçerli. Hikâyeye gönderme yapan soruda ilgili cümle kökün içinde yazılır.
- **Öğrenci verisi** kişisel tanımlayıcısız; çocuk adı örnek cümlede kullanılmaz. XP/süre ile öğrenme metriği karıştırılmaz.

## 3. Önerilen mimari: tek sözcük çekirdeği + köprüler

Mevcut iki sistem birleştirilmez. Canlı hikâye sözlüğü (`okuma_sozluk_*`, `okuma_sozluk_getir`, mobil bağlantı) bozulmasın diye **köprü** kurulur. Kelime Evreni tabloları çekirdek olarak genişletilir.

```
kelime_anlamlari (genişler)          kelime_iliskileri (var)
  + sozcuk_turu (genişler: zamir, edat, unlem...)
  + tur: kelime | deyim | atasozu
  + ornek_cumle (özgün)
  + sinif_alt / sinif_ust
  + zorluk_hesap (1-3), zorluk_olcum (cevap verisinden)
  + puan (Arena/XP ağırlığı)
  + kaynak_durum, kanit_duzeyi (A/B/C), kazanim_kodu
        |
kelime_hikaye_baglari (yeni)  ──►  okuma_sozluk_girdileri.id (+ hikaye_id, yuva)
kelime_sorulari (genişler): soru_turu (eş, zıt, eş sesli + yeni türler), anlam_id, zorluk, kanit_duzeyi
```

Kararlar:
- `kelime_sorulari.iliski_turu` ve `meydan_okumalar.kelime_iliski_turu` CHECK'leri genişler (yeni soru türleri: `sozcuk_turu`, `baglamda_anlam`, `deyim_anlami`, `atasozu_anlami`). Önce eski CHECK'i okuyup genişleten ek migration; mevcut migration değişmez.
- Hikâye girdisi ↔ çekirdek anlam eşlemesi `(yazım, anlam)` ile yapılır, **otomatik eşleşme kanıt sayılmaz**; belirsiz olan satır insan kuyruğuna gider.
- `questions` tablosu yine kullanılmaz (K2 korunur).

## 4. Zorluk ve puan

**Zorluk (1–3), vekil ölçümle.** Zorluk 3 hedefi için uğraşılmaz (kullanıcı kararı); iki aşama:

1. *Başlangıç (editoryal) zorluk:* sınıf aralığı + soyutluk + çok anlamlılık + ilişki türü (eş sesli > eş anlamlı > zıt anlamlı) + çeldirici yakınlığı. Üretici ajan öneri yazar, denetçi kontrol eder; formül kuralı yazılı ve sabittir.
2. *Ölçülen zorluk:* en az 30 denemeden sonra doğru oranı. Eşik önerisi: ≥%80 kolay, %50–80 orta, <%50 zor. Bu veri ilk kez gerçek öğrenci oynadıktan sonra oluşur; o güne kadar başlangıç zorluğu kullanılır ve "ölçülmedi" diye işaretlenir.

**Puan.**
- Kelime Evreni XP'si **mevcut kural** kalır (10/20/30; yalnız doğru, ipucusuz, tekrar vadesi gelmiş cevap). Sınıf yerine soru zorluğu kullanılır.
- Arena'da öneri: soru zorluğuna göre doğru puanı 3/4/5, yanlış −1 (mevcut `doğru×4−yanlış` korunarak). **Bu Arena kuralını değiştirir; kullanıcı kararı gerekir.** 10 soruluk meydan okumada zorluk dağılımı sabit (ör. 4 kolay / 4 orta / 2 zor) olur ki iki taraf eşit koşulda yarışsın.
- Sözcük puanı XP veya süre ile "öğrenme" ölçüsü sayılmaz; ustalık seviyesi ayrı kalır.

## 5. Hikâye ilişkisi

1. **Okurken:** hikâyedeki işaretli sözcüğe dokunulunca mevcut anlam balonu çekirdekten gelir; "Kelime Evreni'ne kaydet" mevcut `kelime_kaydet` akışına bağlanır.
2. **Hikâye sonrası:** "Bu hikâyenin sözcükleri" mini oyunu; o hikâyeye bağlı onaylı sorulardan 4–6 soru. Bağlam kökte yazılır.
3. **Arena:** isteğe bağlı mod "bu hikâyenin sözcükleri" (iki taraf da aynı hikâyeyi okumuş olmak zorunda değil; sorular bağımsız çözülebilir olmalı).
4. **Yön:** hikâye sözlüğündeki 201 eş + 138 zıt ilişki önerisi, çekirdeğe ilişki **adayı** olarak girer. Kopyalanarak yayınlanmaz.
5. **Kapsam hesabı:** hangi hikâyede hangi sözcük/ilişki var → `kelime_hikaye_baglari` ile yönetim panelinde tek tabloda görünür.

## 6. Üretim hattı (içerik)

1. **Aday havuzu:** hikâye sözlüğü (754), mevcut KE (218), MEB metninde geçen kavramlar (kaynağı olan). Sınıf × tür kapsam tablosu çıkarılır; **önce boş hücreler** (GÖR-070 ile uyumlu: 1–3. sınıf eş/zıt anlam).
2. **Sözcük kartı** (pedagoji paketi alanları): lemma, anlam (özgün), tür, örnek cümle (özgün, çocuk adı yok), ilişkiler, yanlış kavramalar, sınıf aralığı, kazanım/kanıt düzeyi.
3. **Soru üretimi:** blueprint-first (ölçülen kazanım + bilişsel eylem + çeldirici mantığı). 6-gram benzerlik ve kaynak parmak izi. `soru_kontrol.mjs` çalıştırılır.
4. **Kör çözüm:** farklı model ailesi. Yanlış çözülen sorular günlüğe.
5. **Denetim:** Ajan A (olgu, TDK uyumu, tek doğru), Ajan B (sınıf uygunluğu, şık dengesi, ipucu). İkisi `pass` ise insan örneklemi.
6. **Yayın:** insan onayı; `published` tek tek değil, kuru çalıştırmalı toplu (Hikâye Atölyesi kalıbı).

Soru kontrol listesi (sözcük için özellikle): tek doğru (eş anlamlı sorusunda ikinci eş anlamlı çeldirici olmasın), "ilişkili sözcük" eş/zıt sayılmaz, eş sesli ≠ çok anlamlı, sıradan söz öbeği deyim değil, ipucu cevabı açmasın.

## 7. Aşamalar

| Faz | İş | Çıktı / kabul |
|---|---|---|
| **0 Karar** | Aşağıdaki açık kararlar; 4/8 kazanım kodu düzeltmesi; 1–3 ve 4 resmî metin | Karar kaydı `PROJE_GUNLUGU.md`'de |
| **1 Şema** | Çekirdek genişletme + köprü + yeni soru türü CHECK'leri + sözlük girdi onay RPC'si (K-0141). PGlite testleri | Test geçer; `db:preview` → içerik okuma → `db:deploy` |
| **2 Aktarım** | 118 ilişkinin örnek cümlelerini DB'ye taşı; 997 girdiyi çekirdekle eşle (belirsiz olanlar kuyrukta) | Eşleme raporu; kaybolan alan sıfır |
| **3 Pilot** | Tek sınıf aralığı (öneri: 5. sınıf; 5–8 ortak kazanım, TYMM geçerli) tüm tür ve zorluklarla ~150 sözcük, ~220 soru; tam denetim hattı | Pilotta kör çözüm doğruluk oranı, denetim bulgu sayısı, insan örnek sonucu |
| **4 İstemci** | Flutter: zorluk/puan gösterimi, hikâye sonrası mini oyun, Arena dengeli dağılım; panel: kapsam tablosu ve onay | Widget testleri; cihaz kontrolü (yapılmadıysa açıkça yazılır) |
| **5 Ölçek** | Pilot kalıbıyla 1–3, 6–7, sonra 4 ve 8 (`source_pending` etiketiyle) | Sınıf × tür kapsam tablosunda boş hücre kalmaz |
| **6 Kalibrasyon** | Gerçek denemelerden ölçülen zorluk; zorluk sınırlarını gözden geçir | Ölçülen/beklenen sapma raporu |

Hacim hedefi **öneri, onaylı değil**: çekirdek ≈1.200 anlam, ≈1.800 soru (mevcut 232 / 118'den). Pilot sonucu görülmeden büyütülmez.

## 8. Riskler

| Risk | Etki | Önlem |
|---|---|---|
| Dört göz + tek yönetici | Yayın yapılamaz, içerik raflarda kalır | Karar 1 |
| İnsan onay kapasitesi | 1.800 soru + 1.000 sözlük girdisi | Örneklem kuralı, toplu kuru çalıştırma, öncelik sırası |
| Eş anlamlı sorusunda ikinci doğru şık | Hatalı soru | Denetçi kontrol listesi + kör çözüm |
| TDK/yayınevi telifi | Hukuki risk | Özgün tanım, benzerlik kontrolü |
| 4 ve 8. sınıf program belirsizliği | Yanlış kazanım etiketi | `source_pending`, A verilmez |
| Çalışma ağacında başka oturumların değişiklikleri | Çakışma | Yeni migration numarası `ls` ile alınır; yabancı dosyalara dokunulmaz |
| Zorluk formülü uydurma kalır | Yanlış XP/puan | Faz 6 kalibrasyonu; o zamana kadar "ölçülmedi" |

## 8b. Verilen kararlar (2026-10-25, kullanıcı)

1. **Yayın:** Dört göz kuralı kaldırılır. Yeni kural: **2 farklı AI modeli `pass` + insan kontrolü** (sizin onayınız). DB'deki dört göz CHECK'leri ve `kelime_soru_durum_degistir` / `kelime_iliski_onayla` kontrolleri bu kurala göre değişir (Faz 1). Denetçi sonucu kayıt altına yazılır (hangi model, ne zaman, karar).
2. **Arena puanı (benim kararım):** Yalnız **kelime modunda** doğru puanı zorluğa göre **3 / 4 / 5**, yanlış **−1**, toplam en az 0. Gerekçe: iki taraf aynı soruları çözdüğü için adil; zor sözcük daha çok kazandırır; ortalama (4) eski kuralla aynı kalır. Genel soru Arena'sı (`oyun_turu='soru'`) **değişmez**. Dağılım sabit: 4 kolay / 4 orta / 2 zor.
3. **Pilot kapsamı:** MEB'in söz varlığı kazanımı olan **tüm sınıflar (1–8)**, dalga dalga değil tek hat. Sınıf × tür kapsam tablosu boş hücreleri gösterir.
4. **Deyim / atasözü:** eklenir, **seçmeli**. Arena'da meydan okuyan oyun alanını seçer (eş anlamlı, zıt anlamlı, eş sesli, deyim, atasözü, karışık); `create_kelime_challenge(p_iliski_turu)` bunu zaten taşır, CHECK'ler genişler. Kelime Evreni ana ekranında da ayrı kart.
5. **Resmî kaynak:** `docs/mufredat/` (yıllık plan ve `kazanim_etiket_tablosu_2026_2027.csv`). Orada bulunanlar:
   - **3. sınıf (TYMM):** `T.O.2.2` f) zıt anlamlı sözcükleri bulur. Tabloda 3. sınıf için eş anlamlı satırı **görülmedi**; eş anlamlı kodu kaynakta görülene kadar `source_pending`.
   - **4. sınıf (önceki program, 2019 kodları):** `T.4.3.7` zıt, `T.4.3.8` eş, `T.4.3.9` eş sesli, `T.4.3.10` gerçek/mecaz/terim, `T.4.3.11` deyim ve atasözü, `T.4.4.13` eş sesli kullanımı. Bu kodlar kendi programında geçerlidir; **`T.O.4.2.h` gibi TYMM biçimi yürürlükte sayılmaz** (`kelime_mufredat_kazanimlari` içinde düzeltilecek).
   - **5–7 (TYMM):** `T.K/T.O/T.Y.x.22 ve ilgili` kodları; 8. sınıf önceki program, kodu ayrıca bakılır.
   - **1. ve 2. sınıf:** tabloda söz varlığı kazanımı **bulunamadı** (2. sınıf satırları 1. sınıf kodlarıyla karışık görünüyor). Bu sınıflarda içerik üretilir, kazanım `source_pending` kalır; A verilmez. Resmî ilkokul PDF'i ajan çıktısında ayrıca aranacak.

## 9. Açık kararlar (kullanıcı) — 1–5 yanıtlandı, yukarıya bakın

1. **Yayın yetkisi:** tek yöneticiyle yayın için dört göz kuralı gevşetilecek mi (ör. denetçi ajan çifti `pass` + sizin onayınız yeterli)?
2. **Arena puanı:** zorluğa göre 3/4/5 doğru puanı kabul mü, yoksa `doğru×4−yanlış` aynen mi kalsın?
3. **Pilot sınıf:** 5. sınıf mı (TYMM, ortak kazanım), yoksa GÖR-070 önceliğiyle 1–3. sınıf eş/zıt anlam mı? (1–3'te resmî metin olmadığından kazanım `source_pending` kalır.)
4. **Deyim ve atasözü:** Kelime Evreni oyun türü olarak eklensin mi (hikâye sözlüğünde 197 deyim/atasözü var)?
5. **1–3 ve 4. sınıf resmî program PDF'i:** sağlayabilir misiniz? Yoksa bu sınıflar `source_pending` ile gider.
