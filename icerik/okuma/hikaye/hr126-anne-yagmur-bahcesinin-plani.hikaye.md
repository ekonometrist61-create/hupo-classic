---
baslik: "Annem ve Yağmur Bahçesinin Planı"
slug: "hr126-anne-yagmur-bahcesinin-plani"
fis_kodu: "HR-126"
tur: bilim
konu: olcum_plan_kontrol
sinif_alt: 3
sinif_ust: 3
kahraman_turu: anne
deger_anahtarlari: [D16, D20]
tanitim: "Okul bahçesindeki su birikintisi için öğrencilerin yağmur bahçesi planı yapılır. Köprü mühendisi {kahraman} ölçüleri yeniden alıp planı düzeltir."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-10-24"
etiketler:
  ana_sinif: 3
  maarif: {ana_deger: D16, yardimci_deger: D20}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: olcum_hr126, tur: lexeme, etiket: "ölçüm", islev: first_hint}
  - {id: egim_hr126, tur: lexeme, etiket: "eğim", islev: application}
  - {id: model_hr126, tur: lexeme, etiket: "model", islev: application}
  - {id: denetlemek_hr126, tur: lexeme, etiket: "denetlemek", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "İlk tahmin neydi?"
    secenekler:
      - {id: A, metin: "Su borusu tamamen kırılmıştı"}
      - {id: B, metin: "Çiçekler solmuştu"}
      - {id: C, metin: "Yol çok genişti"}
      - {id: D, metin: "Sorun bozuk oluktandı"}
    dogru: D
    dayanak: "{kahraman} önce birikintinin yalnızca bozuk bir oluk yüzünden oluştuğunu düşündü."
    aciklama: "İlk tahmin, birikintinin bozuk bir olukta olduğuydu."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Ölçümlerden sonra hangi bilgi ortaya çıktı?"
    secenekler:
      - {id: A, metin: "Yağmur o gün hiç yağmamıştı"}
      - {id: B, metin: "Bahçe planlanandan küçüktü"}
      - {id: C, metin: "Su taş zeminden akıyordu"}
      - {id: D, metin: "Oluk kaldırılmıştı"}
    dogru: C
    dayanak: "Su, oluğun altından değil, geniş taş zeminin üzerinden akıyordu."
    aciklama: "Ölçüm ve çizim, suyun taş zeminden aktığını gösterdi."
  - id: s3
    beceri: hatirlama
    dayanak_sayfa: 3
    metin: "Hangi model suyu topladı?"
    secenekler:
      - {id: A, metin: "Birinci model"}
      - {id: B, metin: "İkinci model"}
      - {id: C, metin: "Hiçbir modelde çiçeklik yoktu"}
      - {id: D, metin: "Eğimi olmayan düz bir çizim"}
    dogru: B
    dayanak: "İkinci modelde çiçeklik biraz daha aşağıdaydı ve suyu topladı."
    aciklama: "Çiçeklik daha aşağıda olan ikinci model suyu topladı."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "Planın uzmanlarca kontrol edilmesi neden önemliydi?"
    secenekler:
      - {id: A, metin: "Bahçeyi biraz daha süslemek için"}
      - {id: B, metin: "Planı daha pahalı yapmak için"}
      - {id: C, metin: "Çiçekleri değiştirmek için"}
      - {id: D, metin: "Çalışmayı güvenle yapmak için"}
    dogru: D
    dayanak: "Çalışmanın güvenli ve uygun biçimde yapılması için uzmanların kontrol edeceği bir plan oluşturdular."
    aciklama: "Uzman kontrolü, çalışmanın güvenli ve uygun yapılmasını sağlar."
---
@omurga
Kasabanın okul bahçesinde yağmurdan sonra büyük su birikintileri oluşuyordu. Köprü mühendisi {kahraman}, öğrencilerin çizdiği bir bahçe planını incelemeye geldi. Öğrenciler, toprağa küçük bir yağmur bahçesi yapmak istiyordu. Böylece suyun bir bölümü çiçeklerin olduğu yerde toplanacak, yürüyüş yolu daha kuru kalacaktı. {kahraman} önce birikintinin yalnızca bozuk bir oluk yüzünden oluştuğunu düşündü.
---
@omurga
{kahraman}, okul görevlisiyle birlikte bahçeyi ölçtü. Bir cetvelle yolun kenarındaki küçük eğimi, bir iple de planlanan bahçenin sınırını belirlediler. Ölçüm sonuçlarını deftere yazdılar. Öğrencilerden biri, “Birikinti hep aynı yerde oluyor,” dedi. {kahraman}, yağmur suyunun geldiği yönü bir çizimle gösterdi. Su, oluğun altından değil, geniş taş zeminin üzerinden akıyordu.
---
@omurga
“İlk tahminim doğru çıkmadı,” dedi {kahraman}. Yeni plan için iki küçük model hazırladılar. İlk modelde çiçeklik yolun hemen yanındaydı; su yine yürüyüş alanında kaldı. İkinci modelde çiçeklik biraz daha aşağıdaydı ve suyu topladı. Herkes ikinci modelin neden işe yaradığını konuştu. {kahraman}, “Ölçmeden karar verirsek önemli ayrıntıları gözden kaçırabiliriz,” diye açıkladı.
---
@omurga
Ertesi gün okul yönetimiyle görüştüler. Çalışmanın güvenli ve uygun biçimde yapılması için uzmanların kontrol edeceği bir plan oluşturdular. Öğrenciler çiçek seçimiyle ilgilendi, {kahraman} ölçüleri yeniden denetledi. Böylece herkes yapabileceği işi üstlendi.
---
@omurga
Haftalar sonra tamamlanan yağmur bahçesine ilk yağmur düştü. Su, yürüyüş yoluna yayılmadan çiçeklerin bulunduğu alana yöneldi. Öğrenciler pencerenin önünde sevinçle izledi. {kahraman} defterini açıp ilk çizimi ve yeni planı yan yana koydu. İki çizim arasındaki fark, bahçenin neden işe yaradığını açıkça gösteriyordu.
