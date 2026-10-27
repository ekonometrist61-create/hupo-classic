# Okuma Dünyası · Yeni kahraman hikâyeleri (brief seti)

Hazırlık: 2026-10-24. Durum: **TASLAK brief**. Yayın yok, veritabanına yazma yok.

Bu klasördeki dört brief, kahraman türlerinde hikâye eksiği olan kahramanlar içindir (uygulama kodu: `mobile-app/lib/models/okuma_kahraman.dart`):

| Dosya | Kahraman (uygulamadaki etiket) | Kod (`izinli_turler`) | Sınıf | Program durumu |
|---|---|---|---|---|
| Bu dosyada: [Hazır Hupo](#hazır-hupo-hazir-sınıf-3) | Hazır Hupo | `hazir` | 3 | TYMM 2026–27 |
| Bu dosyada: [Annem](#annem-anne-sınıf-3) | Annem | `anne` | 3 | TYMM 2026–27 |
| Bu dosyada: [Babam](#babam-baba-sınıf-4) | Babam | `baba` | 4 | **Önceki program**: TYMM kodu yürürlükte sayılmaz |
| Bu dosyada: [Araç](#araç-arac-sınıf-5) | Araç | `arac` | 5 | TYMM 2026–27 |

Ortak kurallar (tüm brief'ler için):

1. **Kazanım kodu:** Kodlar uydurulmaz. Brief'te `curriculum_status` alanı `source_pending` olarak kalır. Kod yalnızca `docs/meb/ortaokul-turkce-tymm-program-metni.txt` içinde görülüp metin okunarak eşlendiğinde yazılır. 4. sınıfta TYMM kodu yazılmaz (2026–27 önceki program).
2. **Kanıt düzeyi:** Yeni hikâyeler `C` ile başlar (resmî eşleşme yok). A yalnızca soru ve dayanak metni birlikte doğrulandığında verilir.
3. **Yayın kapısı:** iki ajan `pass` + insan onayı `approved`. Bu brief'lerden çıkan metinler `draft` olarak girer; `published=false` kalır. Yayın kararı en sonda insan tarafından verilir.
4. **Sözlük:** Her yuva en az 3 aday taşır. Anlamlar TDK'ya göre ve sınıf düzeyinde yazılır; gerçek eş/zıt olmayan "ilişkili" sözcük eş/zıt diye girmez.
5. **Kahraman adı:** Hazır Hupo sabit `Hupo` adıyla gider. Annem, Babam ve Araç için çocuk kendi adını yazar; hikâye `{kahraman}` yer tutucusu ile anlatılır, ad metne sabit yazılmaz. Araç adı için hayvan, araç ve hayali türde din adları yasaktır (K-0024).
6. **Yasak:** gerçek kişi, marka, çizgi film ve oyun karakteri adı; MEB ya da yayınevi sorusunun metni veya yakın parafrazı; çocuğun gerçek kişisel verisi; korkutucu içerik ve tehlikeli sağlık ya da güvenlik tavsiyesi.
7. **Sayfa ve uzunluk (HupoRead pilot ölçütü):** sınıf 3 için ≤ 330, sınıf 4 için ≤ 450, sınıf 5 için ≤ 650 kelime. Bu bir MEB kotası değildir; uzunluk tek başına editoryal onay değildir. 4–6 sayfa; sayfa sonları kaynak metinde `---` ile işaretlenir.
8. **Soru:** sınıf 3 için 2–4, sınıf 4 için 3–5, sınıf 5 için 4–6 soru. Her soru bir `dayanak` cümlesine dayanır; cevap metinde birebir bulunur; çeldiriciler metinle ilgili ve makul; doğru şık en uzun şık olmaz.
9. **Çıktı biçimi:** anotasyon JSON (`icerik/okuma/anotasyon/` kalıbı: `id`, `kisa`, `kaynak`, `slug`, `baslik`, `sinif`, `tur`, `konu`, `kahraman`, `yoldas`, `sorular`, `sozluk`, `spans`) ve kaynak `.md` dosyası (`## HR-XXX · Başlık` başlığıyla).

---

## Ana istem (ChatGPT'ye olduğu gibi verilebilir)

> Sen bir çocuk edebiyatı yazarı ve Türkçe öğretmenisin. Türkiye'deki ilkokul/ortaokul öğrencileri için, sesli okunabilir, sıcak ama sahte olmayan bir hikâye yazacaksın. Kahramanın rolü aşağıda verilen türde; hikâyede kahramanın adı yazılmayacak, yalnızca `{kahraman}` yer tutucusu kullanılacak. Yol arkadaşı gerekiyorsa `{yoldas}` kullanılacak.
>
> Hedef: [SINIF] sınıf · en fazla [KELİME] kelime · [SAYFA] sayfa · sayfalar `---` ile ayrılacak.
> Kahraman türü: [TÜR].
> Merkez fikir: [BRIEF'TEKİ MERKEZ FİKİR].
> Çatışma: kahraman bir hedefe ulaşmak ister; bir engel çıkar; kahraman deneyerek ve birlikte çalışarak engeli aşar; sonuç kahramanın seçimine bağlıdır. Ahlak dersi yazma; değer, sahnenin içinden çıkmalı.
> Sözcük hedefleri (metinde doğal geçsin, bağlamla anlaşılsın): [SÖZCÜKLER]. Deyim: [DEYİM] (sayfada bir kez, cümle içinde).
> Yasaklar: gerçek kişi, marka, çizgi film adı; korku ve şiddet; çocuğun gerçek bilgileri; tek cümlelik ahlak notu dışında vaaz; kahramanın cinsiyetine dayalı klişe.
> Çıktı: önce hikâyenin tamamı (düz metin, sayfa ayrımı `---`), sonra [SORU SAYISI] okuduğunu anlama sorusu; her soru 4 şıklı, tek doğru cevaplı, doğru cevabın dayanak cümlesi metinde birebir geçen bir cümle olacak. Son olarak her sorunun beceri etiketini yaz (`hatirlama`, `cikarim`, `sozcuk_baglami`, `yorumlama`).
> Kendini denetleme: hikâyeyi bitirdikten sonra şunları kontrol et ve sonucu ayrı bir bölümde yaz: kelime sayısı, sayfa sayısı, her sorunun dayanak cümlesi, doğru şıkların uzunluğu, yasak ad/marka olup olmadığı.

---

## Hazır Hupo (`hazir`, sınıf 3)

- **Kahraman:** Hupo, küçük ve neşeli bir kuş; okulun bahçesinde yaşar. Adı sabittir (`Hupo`); çocuk ad yazmaz.
- **Merkez fikir:** Dinlemek bir beceridir. Hupo, bir yankının kaybolan sözcüklerini bulmaya çalışırken önce dikkatle dinlemeyi, sonra sabırla eşleştirmeyi öğrenir.
- **Dünya:** Bahçenin köşesindeki taş kemerde, söylediğin her sözü geri veren bir yankı var. Bir gün yankı kelimeleri karıştırmaya başlar: "masa" "asam" olur, "kitap" "pitak" olur. Hupo'nun görevi, karışan sözcükleri doğru sırayla geri getirmek.
- **Sahne planı (4 sayfa):**
  1. Hupo bahçede yankıyla oynarken garip bir cevap duyar.
  2. Yankı karışık sözler geri verir; Hupo sözleri not eder ve arkadaşı (yol arkadaşı) yardım eder.
  3. Yanlış bir eşleştirme deneyi yapılır; kuş bir süre yanlış sonuca güvenir ve hatasını fark eder.
  4. Dikkatli dinleme ile doğru sözler geri gelir; Hupo'nun not defteri, dinlemenin önemini gösterir.
- **Sözcük hedefleri (2–4):** yankı, dikkat, karıştırmak, eşleştirmek. (Her biri metinde bağlamla açıklanır.)
- **Deyim (0–1):** "kulak kesilmek" (dikkatle dinlemek); yalnızca doğal geçerse.
- **Soru türleri (3 sınıf):** `hatirlama` (Hupo'nun neyi not ettiği), `cikarim` (yanlış eşleştirmenin neden olduğu), `sozcuk_baglami` (bir sözcüğün bağlamdaki anlamı).
- **Değer:** şemadaki D-kodlarından seçilir (insan onayı); önerilen tema: dikkat ve sabır.

## Annem (`anne`, sınıf 3)

- **Kahraman:** Annem bir köprü mühendisi. Çocuk, annesinin adını yazar; kahraman metinde `{kahraman}` ile anlatılır, yaşına ve mesleğine dair ayrıntı verilmez.
- **Merkez fikir:** Bir sorunu tek başına değil, deneyerek ve birlikte çözmek. Annem, kasabanın köprüsündeki çatlağın nedenini bulmak için ölçüm yapar; yanlış tahminini düzeltir.
- **Dünya:** Küçük bir ırmağın üzerindeki taş köprüde bir çatlak belirir. Kasabalılar tedirgin; Annem çatlağı ölçmeye karar verir.
- **Sahne planı (5 sayfa):**
  1. Annem köprünün çatlağını görür ve ilk tahminini söyler: "Su yüzünden olmalı."
  2. Yol arkadaşı ile ölçüm yaparlar; cetvel ve ip kullanılır.
  3. Ölçüm, ilk tahminin yanlış olabileceğini gösterir: çatlak, köprünün eski bir taşından gelmektedir.
  4. Annem tahminini değiştirir ve kasabalılarla birlikte bir kontrol planı yapar.
  5. Köprü onarılır; Annem kendi hatasını kabul eder ve bunun sonuçta güven verdiğini söyler.
- **Sözcük hedefleri (2–4):** ölçüm, çatlak, dayanıklılık, tahmin.
- **Deyim (0–1):** "kafa yormak" (düşünmek); doğal geçerse.
- **Soru türleri (4):** `hatirlama` (ilk tahmin), `cikarim` (ölçümün neyi değiştirdiği), `sozcuk_baglami` (dayanıklılık), `yorumlama` (hatayı kabul etmenin etkisi).
- **Kaçınılacak:** annenin yalnızca bakım veren olarak görülmesi; mesleği ve kararı olan bir karakter olmalı.

## Babam (`baba`, sınıf 4)

- **Kahraman:** Babam bir yerel gazetede fotoğrafçı. Çocuk, babasının adını yazar; `{kahraman}` ile anlatılır.
- **Program durumu:** Sınıf 4, 2026–27'de önceki programdadır. TYMM kodu yazılmaz; `curriculum_status` = `source_pending`.
- **Merkez fikir:** Bir fotoğraf, unutulmuş bir olayın belgesidir; ama fotoğrafın anlatmadığını bulmak için karşılaştırma gerekir.
- **Dünya:** Mahallenin eski bir fotoğrafında, bir meydanın kenarında kimsenin hatırlamadığı bir heykel var. Babam fotoğrafı arşivdeki diğer kareler ile karşılaştırır.
- **Sahne planı (5 sayfa):**
  1. Babam arşivde bulduğu fotoğrafa bakar; bir ayrıntı dikkatini çeker.
  2. Yol arkadaşı, eski gazete sayılarını getirir; tarihleri karşılaştırırlar.
  3. Bir karşılaştırma ilk yorumu çürütür: fotoğraf, sandığımızdan farklı bir yıla aittir.
  4. Yaşlı bir komşu, heykelin neden kaldırıldığını anlatır; Babam bunu kanıtla doğrular.
  5. Babam fotoğrafı mahalleye geri verir; belgenin hikâyesi artık herkesin malıdır.
- **Sözcük hedefleri (2–4):** arşiv, belge, karşılaştırma, kanıt.
- **Deyim (0–1):** "gözden kaçırmak"; doğal geçerse.
- **Soru türleri (4):** `hatirlama` (fotoğrafta dikkat çeken ayrıntı), `cikarim` (tarihin neden önemli olduğu), `sozcuk_baglami` (belge), `yorumlama` (karşılaştırmanın değeri).
- **Kaçınılacak:** babanın yalnızca sorumlu ve sert olarak görülmesi; merak ve sabır da taşıyan bir karakter olmalı.

## Araç (`arac`, sınıf 5)

- **Kahraman:** Bir gece treni, adını çocuk seçer (`Tren`, `Gemi`, `Roket` gibi uygulama önerileri verilebilir; din adı yasaktır). Araç konuşur; `{kahraman}` ile anılır.
- **Program durumu:** TYMM 2026–27 sınıf 5 kapsamında. Kaynak metin `docs/meb/ortaokul-turkce-tymm-program-metni.txt` içinde T.O.5.* kodları görülüyor; hikâye bu kodlarla **eşlenmeden** kod yazılmaz (`source_pending`). Eşleme, metin okunduktan sonra yapılır.
- **Merkez fikir:** Sorumluluk, zamana karşı uyarı: bir yolcu için söz verilen zamanı tutmak; ama yolcu kendi kararını da vermelidir.
- **Dünya:** Dağ hattında son gece seferi. Vagon dolu, kar yağıyor. Yolcuların hepsi aynı adresi arıyor, ama her biri farklı bir nedenle erken inmek istiyor.
- **Sahne planı (6 sayfa):**
  1. Tren, sefer çizelgesini ve yükü anlatır; bir yolcu telaşla bilet arar.
  2. Yolcular, kar nedeniyle hattın değişeceğini öğrenir; tren karar vermek zorundadır.
  3. Bir yolcu, sürenin kısalığını gerekçe gösterip kısa yoldan geçmeyi önerir; tren riskli olduğunu düşünür.
  4. Tren ve yol arkadaşı, haritaya ve sinyal notlarına bakar; güvenli rotayı birlikte hesaplarlar.
  5. Güvenli rota daha uzundur; yolcular geç varır ama kimse zarar görmez.
  6. Tren, kendi kararının sonuçlarını kabul eder ve ertesi sefere hazırlanır.
- **Sözcük hedefleri (2–4):** güzergâh, sefer, öngörü, sorumluluk.
- **Deyim (0–1):** "yolu açmak"; doğal geçerse.
- **Soru türleri (5):** `hatirlama` (güzergâhın değişme nedeni), `cikarim` (riskli yolun neden reddedildiği), `sozcuk_baglami` (öngörü), `yorumlama` (zamanın değeri), `degerlendirme` (tren kararının gerekçesi).
- **Kaçınılacak:** araç markalarının adları ve gerçek yolcu/istasyon adları; uydurulan ama gerçekçi görünen istasyon adları yerine genel isimler.

---

## Yayın kapısı (her brief için)

1. Taslak metin iki denetçiden geçer (olgu ve doğruluk; sınıf uygunluğu ve güvenlik).
2. Sözcük ve sözlük anlamları ayrıca denetlenir.
3. Sorular ve dayanak cümleleri metinle birlikte kontrol edilir (`soru_kontrol.mjs`).
4. İnsan okuması ve onayı yapılmadan `published=false` kalır.
