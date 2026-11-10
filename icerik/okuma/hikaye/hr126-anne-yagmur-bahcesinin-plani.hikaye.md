---
baslik: "Yağmur Bahçesinin Planı"
slug: "hr126-anne-yagmur-bahcesinin-plani"
fis_kodu: "HR-126"
tur: bilim
konu: olcum_plan_kontrol
sinif_alt: 3
sinif_ust: 3
kahraman_turu: anne
deger_anahtarlari: [D16, D20]
yetiskin_uygun: false
tanitim: "Okul bahçesindeki su birikintisi için öğrencilerin yağmur bahçesi planı yapılır. Çevre mühendisi {kahraman} ölçüleri yeniden kontrol eder ve planı buna göre düzenler."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-10-24"
etiketler:
  ana_sinif: 3
  maarif: {ana_deger: D16, yardimci_deger: D20}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: review_needed, ajan_b: review_needed, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: olcum_hr126, tur: lexeme, etiket: "ölçüm", islev: first_hint}
  - {id: egim_hr126, tur: lexeme, etiket: "yamaç", islev: application}
  - {id: model_hr126, tur: lexeme, etiket: "model", islev: application}
  - {id: denetlemek_hr126, tur: lexeme, etiket: "kontrol", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Mühendis, su birikintisinin nedenini önce ne sandı?"
    secenekler:
      - {id: A, metin: "Su borusunun kırıldığını"}
      - {id: B, metin: "Çiçeklerin solduğunu"}
      - {id: C, metin: "Yolun çok geniş olduğunu"}
      - {id: D, metin: "Oluğun bozuk olduğunu"}
    dogru: D
    dayanak: "{kahraman} önce birikintinin yalnızca bozuk bir oluk yüzünden oluştuğunu düşündü."
    aciklama: "İlk tahmin, birikintinin bozuk bir oluktan kaynaklandığıydı."
  - id: s2
    beceri: hatirlama
    dayanak_sayfa: 2
    metin: "Ölçüm sonuçları ve çizim neyi gösterdi?"
    secenekler:
      - {id: A, metin: "Yağmurun o gün hiç yağmadığını"}
      - {id: B, metin: "Bahçenin planlanandan küçük olduğunu"}
      - {id: C, metin: "Suyun taş zeminden aktığını"}
      - {id: D, metin: "Oluğun yerinden kaldırıldığını"}
    dogru: C
    dayanak: "Su, oluğun altından değil, geniş taş zeminin üzerinden akıyordu."
    aciklama: "Ölçüm ve çizim, suyun taş zeminin üzerinden aktığını gösterdi."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 2
    metin: "“Yolun kenarındaki yamaç, bahçeye doğru eğiliyordu” cümlesinde yamaç ne demektir?"
    secenekler:
      - {id: A, metin: "Eğimli, yüksekçe arazi parçası"}
      - {id: B, metin: "Çiçeklerin dikildiği küçük çukur"}
      - {id: C, metin: "Suyun aktığı demir oluk"}
      - {id: D, metin: "Okulun büyük giriş kapısı"}
    dogru: A
    dayanak: "Yolun kenarındaki yamaç, bahçeye doğru eğiliyordu."
    aciklama: "Yamaç, eğimli ve yüksekçe bir arazi parçasıdır."
  - id: s4
    beceri: cikarim
    dayanak_sayfa: 3
    metin: "Suyu toplayan model ilkinden neden farklı çalıştı?"
    secenekler:
      - {id: A, metin: "Çiçeklik yolun hemen yanındaydı"}
      - {id: B, metin: "Çiçeklik biraz daha aşağıdaydı"}
      - {id: C, metin: "Oluk yeniden yapılmıştı"}
      - {id: D, metin: "Yağmur o gün hiç yağmamıştı"}
    dogru: B
    dayanak: "İkinci modelde çiçeklik biraz daha aşağıdaydı ve suyu topladı. Öğrenciler sevinçle el çırptı. {kahraman} ikinci modelin fotoğrafını çekip deftere yapıştırdı."
    aciklama: "Çiçeklik daha aşağıda olduğu için su oraya aktı; ilk modelde çiçeklik yolun hemen yanındaydı ve su yürüyüş alanında kaldı."
---
@omurga
Kasabanın okul bahçesinde yağmurdan sonra büyük su birikintileri oluşuyordu. Teneffüste çocuklar ıslak ayakkabılarla sınıfa dönüyordu. Çevre mühendisi {kahraman}, öğrencilerin çizdiği bir bahçe planını incelemeye geldi. Planın bir köşesinde çocukların boyadığı mavi damlalar ve sarı papatyalar vardı. {kahraman} kâğıdı uzun uzun süzdü. Öğrenciler toprağa küçük bir yağmur bahçesi yapmak istiyordu. Yağmur bahçesi, suyun toplandığı ve toprağa çekildiği, çiçek dikilmiş çukur bir yerdi. Böylece suyun bir bölümü çiçeklerin olduğu yerde toplanacak, yürüyüş yolu daha kuru kalacaktı. {kahraman} önce birikintinin yalnızca bozuk bir oluk yüzünden oluştuğunu düşündü.
---
@omurga
“Su neden hep burada duruyor?” diye sordu okul görevlisi. “Önce ölçelim,” dedi {kahraman}. Görevli ipin bir ucunu kapı direğine bağladı, öbür ucunu {kahraman} tuttu. İple yatay bir çizgi kurdular. İp düz durunca ölçüm yanlış çıkmazdı. Cetvelle yolun kenarındaki yükseklik farkına baktılar. Yolun kenarındaki yamaç, bahçeye doğru eğiliyordu. Bir yaprak koparıp yamacın tepesinden bıraktılar; yaprak yavaşça birikintiye doğru kaydı. Görevli başını eğip suyun akışını izledi. “Demek hep aşağı kayıyor,” dedi.

Ölçüm sonuçlarını deftere yazdılar: yükseklik farkı yaklaşık 20 santimetreydi. Aynı iple planlanan bahçenin sınırını da belirlediler. {kahraman}, yağmur suyunun geldiği yönü bir çizimle gösterdi. Su, oluğun altından değil, geniş taş zeminin üzerinden akıyordu.
---
@omurga
“İlk tahminim doğru çıkmadı,” dedi {kahraman}. Yeni plan için iki küçük model hazırladılar. Öğrenciler kutu kapaklarıyla yamacı, kumla da toprağı yaptı; küçük bir kaptan su döktüler. Her modelin yanına küçük bir bayrak diktiler. İlk modelde çiçeklik yolun hemen yanındaydı; su yine yürüyüş alanında kaldı. “Olmadı!” dedi öğrenciler bir ağızdan. İkinci modelde çiçeklik biraz daha aşağıdaydı ve suyu topladı. Öğrenciler sevinçle el çırptı. {kahraman} ikinci modelin fotoğrafını çekip deftere yapıştırdı.
---
@omurga
Ertesi gün okul yönetimiyle görüştüler. Müdür planı dikkatle inceledi ve başıyla onayladı. Uzmanların kontrol edeceği bir plan hazırladılar; yağmur bahçesinin yolla arasındaki uzaklığı planın üstüne yazdılar. Öğrenciler çiçek seçimiyle ilgilendi, {kahraman} ölçüleri yeniden denetledi. Küçük bir öğrenci cetveli uzattı. “Ben de sayayım,” dedi. {kahraman} gülümsedi ve rakamları onunla birlikte bir kez daha okudu.
---
@omurga
Haftalar sonra tamamlanan yağmur bahçesine ilk yağmur düştü. Su, yürüyüş yoluna yayılmadan çiçeklerin bulunduğu alana yöneldi. Öğrenciler pencerenin önünde sevinçle izlediler. Yamaçtan inen damlalar çiçeklerin arasında kayboldu. {kahraman} defterini açıp ilk çizimi ve yeni planı yan yana koydu.
