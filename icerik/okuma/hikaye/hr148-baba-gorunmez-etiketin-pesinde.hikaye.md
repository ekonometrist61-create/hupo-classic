---
baslik: "Görünmez Etiketin Peşinde"
slug: "hr148-baba-gorunmez-etiketin-pesinde"
fis_kodu: "HR-148"
tur: mizah
konu: gida_etiketi_dogrulama
sinif_alt: 5
sinif_ust: 5
kahraman_turu: baba
deger_anahtarlari: [D6, D13]
tanitim: "Gizemli bir reçelin içindekileri kimse tam bilmiyor. {kahraman} eğlenceli bir etiketin aynı zamanda güvenilir olmasını sağlıyor."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 5
  maarif: {ana_deger: D6, yardimci_deger: D13}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr148, tur: lexeme, etiket: "içerik", islev: first_hint}
  - {id: sozcuk2_hr148, tur: lexeme, etiket: "etiket", islev: application}
  - {id: sozcuk3_hr148, tur: lexeme, etiket: "numune", islev: application}
  - {id: sozcuk4_hr148, tur: lexeme, etiket: "karışım", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Kavanozların ilk etiketindeki sorun neydi?"
    secenekler:
      - {id: A, metin: "Adının çok kısa olması"}
      - {id: B, metin: "Kavanozların küçük olması"}
      - {id: C, metin: "İçeriğin açık yazılmaması"}
      - {id: D, metin: "Raflara yerleştirilmemesi"}
    dogru: C
    dayanak: "Kasabanın küçük meyve atölyesinde kavanozlara komik bir etiket yapıştırılmıştı: “Gizemli Güneş Reçeli.” Atölyenin gıda uzmanı olan {kahraman}, ismin ilgi çekici olduğunu düşündü ama kavanozun içindekilerin açıkça belirtilmediğini fark etti."
    aciklama: "Metindeki \"Kasabanın küçük meyve atölyesinde kavanozlara komik bir etiket yapıştırılmıştı: “Gizemli Güneş Reçeli.” Atölyenin gıda uzmanı olan {kahraman}, ismin ilgi çekici olduğunu düşündü ama kavanozun içindekilerin açıkça belirtilmediğini fark etti.\" ifadesi doğru seçeneği destekler."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Her partiden numune alınması neden daha güvenilir?"
    secenekler:
      - {id: A, metin: "Farklı üretimlerin ayrı ayrı incelenmesini sağlar"}
      - {id: B, metin: "Etiket yazısını otomatik büyütür"}
      - {id: C, metin: "Kavanozların hepsini aynı yapar"}
      - {id: D, metin: "Meyvenin rengini değiştirir"}
    dogru: A
    dayanak: "{kahraman} rastgele bir kavanozu açıp tadına bakmak yerine her partiden uygun bir numune ayırdı."
    aciklama: "Metindeki \"{kahraman} rastgele bir kavanozu açıp tadına bakmak yerine her partiden uygun bir numune ayırdı.\" ifadesi doğru seçeneği destekler."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: "“Okunaklı” etiket nasıl bir etikettir?"
    secenekler:
      - {id: A, metin: "Çok ağır"}
      - {id: B, metin: "Kolay okunabilen"}
      - {id: C, metin: "Birden çok kapaklı"}
      - {id: D, metin: "Yalnız resimli"}
    dogru: B
    dayanak: "{kahraman} okunaklı ve sade bir yerleşim hazırladı."
    aciklama: "Metindeki \"{kahraman} okunaklı ve sade bir yerleşim hazırladı.\" ifadesi doğru seçeneği destekler."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "{kahraman} çizimin bilgiyi örtmemesini neden istedi?"
    secenekler:
      - {id: A, metin: "Resim çizmek zor olduğu için"}
      - {id: B, metin: "Sadece atölyeyi süslemek için"}
      - {id: C, metin: "Pazarın kapanmaması için"}
      - {id: D, metin: "Müşterinin doğru seçim yapabilmesi için"}
    dogru: D
    dayanak: "Fakat {kahraman} çizimin doğru bilgiyi örtmesine izin vermedi."
    aciklama: "Metindeki \"Fakat {kahraman} çizimin doğru bilgiyi örtmesine izin vermedi.\" ifadesi doğru seçeneği destekler."
---

@omurga

Kasabanın küçük meyve atölyesinde kavanozlara komik bir etiket yapıştırılmıştı: “Gizemli Güneş Reçeli.” Atölyenin gıda uzmanı olan {kahraman}, ismin ilgi çekici olduğunu düşündü ama kavanozun içindekilerin açıkça belirtilmediğini fark etti. Bir müşteri, “Bunun içinde ne var?” diye sorunca herkes aynı anda konuşmaya başladı. Biri kayısı dedi, biri şeftali, biri de portakal. {kahraman} tahmin yarışına katılmadı. Atölyedeki ilk toplantıda herkes kendi tahminini kâğıda yazdı. Aynı kavanoz için üç farklı cevap çıkması, sorunun müşteride olmadığını açıkça gösterdi. {kahraman} bu kâğıtları çöpe atmadı; yeni etiket tamamlanınca eski ve yeni bilgi arasındaki farkı göstermek için sakladı. Önce ürünün üretim kaydını istedi. Çünkü bir etiket yalnızca güzel görünmek için değil, doğru bilgi vermek için de vardı. Atölye sahibi, “İsmin gizemli olması daha eğlenceli değil mi?” diye sordu. {kahraman} gizemli bir adla belirsiz içeriğin aynı şey olmadığını açıkladı.

---

@omurga

Kayıt defterinde üç ayrı meyvenin karışım hâlinde kullanıldığı yazılıydı. Ancak kavanozların bir kısmında miktarlar da yanlış basılmıştı. {kahraman} rastgele bir kavanozu açıp tadına bakmak yerine her partiden uygun bir numune ayırdı. Numune, incelenmek için seçilmiş küçük bir örnekti. Üretim kayıtlarının tutulduğu klasör daha önce rafın arkasındaydı. {kahraman} kayıtların kolay bulunabileceği bir yer önerdi. Böylece bir soru geldiğinde herkes hafızasına dayanmak yerine aynı bilgiye ulaşacaktı. Bu küçük düzenleme, etiket düzeltmek kadar yararlı oldu. Üretim tarihini ve parti bilgisini karşılaştırdı. Bir görevli, baştan hazırlanan etiketlerin çöpe gitmesine üzüldü. {kahraman} kullanılabilir kâğıtların arka yüzünden deneme baskısı yapılabileceğini söyledi. Böylece hem doğru bilgi hazırlanacak hem de gereksiz malzeme tüketilmeyecekti. Çalışma masasındaki renkli çıkartmalar artık daha düzenli görünüyordu.

---

@omurga

Yeni etiket tasarımında komik isim kaldı. Altına meyvelerin isimleri ve içerik bilgileri açıkça yazıldı. {kahraman} özellikle küçük yazıların kolay okunmasını istedi. Çalışanlardan biri, çok uzun yazıları kavanozun altına koymayı önerdi. Yazı büyüklüğü denenirken biri parlak renklerin her sorunu çözeceğini düşündü. {kahraman} açık arka plan üzerinde koyu yazının nasıl göründüğünü gösterdi. Renklerin güzel olması yeterli değildi; göz yormayan ve okunabilen bir tasarım da gerekiyordu. Denemeyi farklı uzaklıklardan yaptılar. Bu kez müşteri kavanozu ters çevirmeden bilgiye ulaşamayacaktı. {kahraman} okunaklı ve sade bir yerleşim hazırladı. Ayrıca alerji ya da özel beslenme ihtiyacı olan insanların ürünleri daha dikkatli seçebileceğini hatırlattı. Atölye, uzman incelemesinden geçen bilgileri kullanmaya karar verdi. İlk baskı yapıldığında herkes kavanozu elden ele dolaştırıp yazıları okumayı denedi.

---

@omurga

Öğleden sonra bir ziyaretçi atölyeye geldi. Eski tasarımı görünce güldü; yeni tasarıma bakınca içeriği hemen anladı. “Demek gizemli olan sadece adıymış,” dedi. {kahraman} etiketin arkasındaki küçük çizimi gösterdi. Çizimde üç meyve el ele tutuşmuş gibi duruyordu. Etiketin kontrol edildiğini belirten işaret tasarımın en küçük bölümündeydi. {kahraman} müşterinin asıl görmek istediği içeriğin ön planda kalmasını sağladı. Çizimlerin yeri bir kez daha değiştirildi; böylece bilgi kaybolmadan eğlenceli görünüm korunmuş oldu. Atölyedeki çalışanlar bu fikri çok sevdi. Fakat {kahraman} çizimin doğru bilgiyi örtmesine izin vermedi. Daha sonra kavanozların üzerine birer kontrol işareti kondu. İşaret, içeriğin kontrol edildiğini gösteriyor ama ürünü olduğundan farklı tanıtmıyordu. Gülümseten bir tasarımla güvenilir bilgi aynı kavanozda buluşmuştu.

---

@omurga

Akşam pazarına gönderilen kavanozlar raflara dizildi. Bir müşteri iki farklı reçeli karşılaştırıp kendisine uygun olanı seçti. Atölye sahibi, önceki etiketin ne kadar çok soru doğurduğunu hatırladı. Pazar kapanırken atölye çalışanları yeni ürün için kısa bir kontrol listesi oluşturdu. Adı, içeriği, kayıt bilgisi ve okunabilirliği ayrı ayrı gözden geçirilecekti. {kahraman} yalnızca bugünkü hatayı düzeltmek yerine benzer karışıklıkların yeniden yaşanmamasına yardım etmişti. “Bazen daha kısa bir cevap için daha doğru bir açıklama gerekiyormuş,” dedi. {kahraman} yeni parti kayıtlarının da düzenli tutulmasını istedi. Bir sonraki ürün farklı bir meyveden yapılacaktı; onun etiketi de kendi içeriğini anlatmalıydı. Gizemli Güneş Reçeli raflarda kaldı ama artık kavanozu eline alan kimse, içindekileri tahmin etmek zorunda değildi.
