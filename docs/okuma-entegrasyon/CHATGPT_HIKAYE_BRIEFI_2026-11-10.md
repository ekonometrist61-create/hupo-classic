# ChatGPT'ye verilecek hikâye yazım brief'i (2026-11-10)

> Kullanım: Bu dosyanın "BRIEF" bölümünden sonrasını olduğu gibi ChatGPT'ye yapıştır. Çıktıyı bana getir; ben kontrol edip paketleyip yüklerim (yayın yine insan onayıyla açılır).

## Önce bilmen gerekenler (ChatGPT'ye yapıştırma)

- HR-121…HR-132 arasında anne, baba, araç ve Hazır Hupo için 12 taslak zaten var (başka bir oturum üzerinde çalışıyor). Bu brief onların ÜSTÜNE eklenecek yeni hikâyeleri ister: numaralar **HR-141'den** başlar, çakışma olmaz.
- Bu hikâyeler uygulama içindir. **2026 MEB hikâye yarışmasına gönderilmez** (yarışma AI kullanımını yasaklıyor).
- Kota (26 hikâye). 1. ve 2. sınıf hikâyesi hiç yok; bu brief onları kapsamıyor (ayrı karar).

---

# BRIEF (buradan sonrasını ChatGPT'ye yapıştır)

Sen çocuklar için Türkçe okuma hikâyeleri yazan bir editör-yazarsın. Hupolingo uygulamasının "Senin Hikâyen" bölümü için, belirli kahraman türlerine uygun **yeni ve özgün** hikâyeler yazacaksın. Bu türlerde hikâye azlığı var; çocuk bu türü seçince "hikâyeler hazırlanıyor" ekranı görüyor.

## 1. Neden bu hikâyeler?

Çocuk hikâyesinin kahramanını seçer. Seçtiği türe göre hikâye bulunur. Şu an eksik olanlar:

| Kahraman türü (`kahraman_turu`) | Yazılacak | Sınıf dağılımı |
|---|---|---|
| `anne` | 6 | 3, 5, 6, 6, 7, 7 |
| `baba` | 6 | 3, 5, 6, 6, 7, 7 |
| `arac` | 6 | 3, 3, 6, 6, 7, 7 |
| `hayvan` | 8 | 3, 3, 5, 5, 6, 6, 7, 7 |

Toplam 26 hikâye. Numaralar: `HR-141`, `HR-142`, … sırayla. Slug örneği: `hr141-anne-...`.
(4. ve 8. sınıf bu yıl önceki programdadır; yazma.)

## 2. En önemli kural: kahraman adı yer tutucudur

Hikâyede kahramanın adı **her yerde `{kahraman}`** olarak yazılır. Çocuk kendi adını (ör. "Annem", "Pati", "Mavi Şimşek") yazar ve uygulama yer tutucuya koyar. Bu yüzden:

- Kahramana ad **verme**. "Ayşe", "Mehmet" gibi sabit ad yazma. Yalnızca `{kahraman}` kullan.
- Metin **üçüncü kişi** anlatılır ("{kahraman} kapıyı açtı"). Kahraman için "o" kullan; **cinsiyet belirten sözcük yok** (kız, erkek, kraliçe, kral, bay, hanım…).
- `{kahraman}` **yalnızca yalın hâlde** (özne olarak) geçsin: "{kahraman} kapıyı açtı", "{kahraman} dedi". **Ek almasın**: "{kahraman}'ın", "{kahraman}'a", "{kahraman}'dan" gibi yazma; ek gerektiren cümleyi yeniden kur ("Kapıyı {kahraman} açtı", "Bunu gören {kahraman} güldü"). Mevcut hikâyelerin hiçbirinde ekli kullanım yok; ünlü uyumu bozulmasın diye bu kural zorunlu.
- Kahramanın türü metinle **çelişmesin**:
  - `anne` / `baba`: kahraman **yetişkin**dir ve **iş/uzmanlık rolüyle** bir sorunu çözer (mühendis, doktor, bahçıvan, kütüphaneci, itfaiyeci, saatçi, haritacı…). **Okul, sınıf, ödev, öğretmen, karne yok.** "Annem/babam" diye kendine atıf yok. Çocuk ve aile ilişkisi kurulacaksa "{kahraman}'ın çocuğu" gibi kısa ve doğal geçer; zorunlu değil.
  - `arac`: kahraman bir **araçtır** (tren, gemi, balon, roket, kamyon, otobüs…). Hikâyeyi araç yaşar ve karar verir; insan sürücü kahraman olmaz. Araç düşünebilir ama gerçekçi bir dünyada kalır.
  - `hayvan`: kahraman bir hayvandır (kedi, köpek, tavşan, kuş, kaplumbağa, balık, vb.). Yırtıcılık, şiddet, ölüm yok.
- **Yardımcı karakterler** ("yoldaş") adlı olabilir ama ad sabit olsun ve gerçek/ünlü bir ad olmasın. Kahramanla arasında karışıklık çıkarmasın.

## 3. Dosya biçimi (aynen uy)

Her hikâye ayrı bir kod bloğunda, **tam `.hikaye.md` dosyası** olarak verilir: önce `---` ile açılan ve `---` ile kapanan üst bilgi (YAML), sonra hikâye gövdesi. Örnek iskelet (HR-122'den alındı, kendi içeriğinle doldur):

```
---
baslik: "Hikâye Başlığı"
slug: "hr141-anne-kisa-slug"
fis_kodu: "HR-141"
tur: bilim
konu: konu_kisa_snake_case
sinif_alt: 5
sinif_ust: 5
kahraman_turu: anne
deger_anahtarlari: [D6, D16]
tanitim: "Bir iki cümlelik tanıtım. Kahramanın adı yer tutucu: {kahraman}."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 5
  maarif: {ana_deger: D6, yardimci_deger: D16}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr141, tur: lexeme, etiket: "ölçüm", islev: first_hint}
  - {id: sozcuk2_hr141, tur: lexeme, etiket: "çatlak", islev: application}
  - {id: sozcuk3_hr141, tur: lexeme, etiket: "dayanıklılık", islev: application}
  - {id: sozcuk4_hr141, tur: lexeme, etiket: "tahmin", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Soru metni?"
    secenekler:
      - {id: A, metin: "Seçenek"}
      - {id: B, metin: "Seçenek"}
      - {id: C, metin: "Seçenek"}
      - {id: D, metin: "Seçenek"}
    dogru: C
    dayanak: "Metinden BİREBİR alınmış cümle ya da cümle parçası"
    aciklama: "Doğru cevabın neden doğru olduğu, tek cümle."
  # s2, s3, s4 aynı biçimde
---
@omurga
1. sayfanın metni.
---
@omurga
2. sayfanın metni.
---
@omurga
3. sayfanın metni.
```

Biçim kuralları:
- Gövde `@omurga` ile başlayan **bölümlerden** oluşur; bölümler `---` ile ayrılır. Her bölüm uygulamada bir sayfadır. **5–6 bölüm** yaz.
- Başka etiket (`@...`), başlık (`#`), kalın (`**`), tablo, liste ya da editör notu **koyma**. Düz metin.
- `tur` şunlardan biri: `arkadaslik, bilim, bilim_kurgu, doga, fantastik, gezi_kultur, gizem, hayvanlar, macera, mizah, spor, tarih_kultur`. Mevcut hikâyelerde yoğun olan macera/gizem/bilim_kurgu dışında da türler seç (hayvanlar, doga, mizah, gezi_kultur, spor, arkadaslik).
- `deger_anahtarlari` ve `maarif`: aşağıdaki D-kodlarından **ikişer** tane; ana ve yardımcı farklı olsun, metinde gerçekten işlensin (konuyu ahlak dersine çevirme, değeri olay içinden göster):
  D1 Adalet · D2 Aile Bütünlüğü · D3 Çalışkanlık · D4 Dostluk · D5 Duyarlılık · D6 Dürüstlük · D7 Estetik · D8 Mahremiyet · D9 Merhamet · D10 Mütevazılık · D11 Özgürlük · D12 Sabır · D13 Sağlıklı Yaşam · D14 Saygı · D15 Sevgi · D16 Sorumluluk · D17 Tasarruf · D18 Temizlik · D19 Vatanseverlik · D20 Yardımseverlik
- Her 26 hikâyede aynı iki değeri tekrarlama; dağıt.
- `durum: taslak`, `uretim_kaynak: llm_taslak`, `denetim` alanları `pending`, `curriculum_status: source_pending`, `kanit_duzeyi: C` olarak **kalır**. **Kazanım kodu (ör. T.3.1.1) yazma**; kaynağı görmediğin kodu uydurma.
- `ogrenme_hedefleri`: **3–4 sözcük** (`tur: lexeme`) ve varsa **1 deyim/atasözü** (`tur: idiom`) ya da kavram (`tur: concept`). Her hedef **metinde geçmeli**. `islev`: `first_hint` (ilk geçtiği yerde bağlamdan anlaşılır ipucu), `application` (sonra kullanılır), `transfer` (farklı bağlamda). Deyim ve atasözlerini **yalnızca gerçek ve doğru olanlardan** seç; anlamını bilmediğin ya da uydurduğun kullanımı koyma.
- Hedef sözcükler sınıfa uygun olsun (3. sınıfa "dayanıklılık" gibi tek zor sözcük yeter; her cümleye zor sözcük koyma).

## 4. Uzunluk (sınıfa göre)

Gövde kelime sayısı üst sınırı (pilot hedefi): 3. sınıf ≤ 330 · 5. sınıf ≤ 650 · 6. sınıf ≤ 800 · 7. sınıf ≤ 950. Üst sınırın %70–100'ünde yaz; sayfa başına yaklaşık eşit uzunlukta.

## 5. Sorular (4 soru, çoktan seçmeli)

- Her hikâyede **4 soru**: biri `hatirlama`, biri `cikarim`, biri `sozcuk_baglami`, biri `yorumlama` (üst sınıflarda biri `degerlendirme` olabilir). `beceri` yalnızca şunlardan: `hatirlama, cikarim, sozcuk_baglami, yorumlama, degerlendirme`.
- `dayanak_sayfa`: cevabın bulunduğu sayfa (bölüm) numarası, 1'den başlar. Sorular sayfa sırasını izlesin.
- **`dayanak` metinde birebir geçmelidir.** Noktalama dahil kopyala; özetleme.
- 4 şık (A–D), uzunlukları birbirine yakın; **doğru şık hep en uzun olmasın**. Çeldiriciler makul ama metne göre kesin yanlış olsun; iki doğru cevap çıkmasın. `dogru` harfi 4 soruda değişsin (hepsi C olmasın).
- "Hepsi", "hiçbiri", "yukarıdakilerin hepsi" şıkkı yok. Soru metni cevabı ele vermesin.
- Her cevap yalnızca bu metinden bulunabilsin; dışarıdan bilgi gerektirmesin.
- **Sınav kitabı ya da MEB sorusu metnini çoğaltma**; soruları bu hikâyeye özgü yaz.

## 6. İçerik kırmızı çizgileri

- Tamamen **özgün** yaz. Var olan masal, çizgi film, film, oyun, marka ya da kitap karakterlerini ve olay örgülerini kullanma. Pikachu, Mario, Batman gibi bilinen karakter adları yok.
- Gerçek kişi adı (ünlü, siyasetçi, sporcu, tarihî kişi dahil) yok. Gerçek kurum/marka adı yok.
- Allah, peygamber ve din büyükleri adları yok (hayvan, araç, hayalî kahramanlarda kesin yasak; yardımcı karakterlerde de kullanma).
- Çocuğun gerçek adı, yaşı, adresi, okulu, şehri ya da fotoğrafı gibi kişisel bilgi **yok**; "çocuğun adı şudur" tarzı varsayım yok.
- Siyaset, parti, nefret, cinsellik, şiddet, ölüm, korku, bağımlılık, silah yok. Gerilim hafif kalır (merak, bulmaca, küçük sorun).
- Ders verme, nasihat paragrafı yok. Sonuç olaydan çıksın.
- "Yapay zekâ" kelimesi geçen hikâyelerde (robot vb.) tek bir hikâyeden fazla olmasın; çeşitlilik koru.
- Aynı kalıp açılış ("Bir sabah…") 26 hikâyede en fazla 3 kez. Konuları, mekânları, mesleklerin ve araçların tekrarını azalt.
- Her hikâye **tek başına anlaşılır**; önceki hikâyeye gönderme yok.

## 7. Teslim biçimi

1. Önce **26 hikâyenin tek satırlık listesi**: numara, kahraman türü, sınıf, başlık, tür, iki değer (tablo).
2. Sonra her hikâye için **tek bir kod bloğu**: yukarıdaki tam dosya biçimi. Kod bloğunun dışına açıklama yazma.
3. En sonda kendi kontrolün: her hikâye için `{kahraman}` dışında sabit kahraman adı var mı, `dayanak` birebir mi, kelime sayısı sınır içinde mi, hedef sözcükler metinde geçiyor mu. Geçmeyen ya da emin olmadığın bir şey varsa **açıkça yaz**; "hepsi doğru" deme.
- Tek mesaja sığmazsa 6–7'şerli parçalara böl, numarayı ve kuralları koru.

---

## Bu brief'in sınırları (sana, ChatGPT'ye değil)

- Kota ve sınıf dağılımı benim önerim; sayıyı değiştirmek serbest.
- Pakete çevirme, `izinli_turler` yazımı, sözlük (TDK) ve Ajan A/B denetimi, doğrulayıcı testi bende. ChatGPT çıktısı "taslak"tır; yayın yalnız insan onayıyla açılır.
- Kazanım eşlemesi yapılmadı (`source_pending`).
