---
baslik: "Sessiz Köprünün Nabzı"
slug: "hr143-anne-sessiz-koprunun-nabzi"
fis_kodu: "HR-143"
tur: bilim
konu: kopru_titresim_olcumu
sinif_alt: 6
sinif_ust: 6
kahraman_turu: anne
deger_anahtarlari: [D6, D3]
tanitim: "Bir yaya köprüsündeki küçük sesin büyük bir araştırmaya dönüşmesini izle. {kahraman} ölçümleri ve güvenliği adım adım değerlendiriyor."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 6
  maarif: {ana_deger: D6, yardimci_deger: D3}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr143, tur: lexeme, etiket: "titreşim", islev: first_hint}
  - {id: sozcuk2_hr143, tur: lexeme, etiket: "sensör", islev: application}
  - {id: sozcuk3_hr143, tur: lexeme, etiket: "veri", islev: application}
  - {id: sozcuk4_hr143, tur: lexeme, etiket: "karşılaştırma", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Kontrol başlamadan önce yayalar nereye yönlendirildi?"
    secenekler:
      - {id: A, metin: "Köprünün ortasına"}
      - {id: B, metin: "Yakın dükkânlara"}
      - {id: C, metin: "Diğer güvenli geçişe"}
      - {id: D, metin: "Köprü altındaki yola"}
    dogru: C
    dayanak: "Köprüden geçenleri önce diğer güvenli geçişe yönlendirdi."
    aciklama: "Metindeki \"Köprüden geçenleri önce diğer güvenli geçişe yönlendirdi.\" ifadesi doğru seçeneği destekler."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Bakım aracı durdurulduktan sonra yeniden ölçüm yapılması neden önemlidir?"
    secenekler:
      - {id: A, metin: "Cihazların rengini anlamak için"}
      - {id: B, metin: "Ölçümü etkileyen koşulu ayırmak için"}
      - {id: C, metin: "Köprünün boyunu kısaltmak için"}
      - {id: D, metin: "Yürüyenleri saymak için"}
    dogru: B
    dayanak: "Araç durduktan sonra yeni bir ölçüm yapılmasını istedi."
    aciklama: "Metindeki \"Araç durduktan sonra yeni bir ölçüm yapılmasını istedi.\" ifadesi doğru seçeneği destekler."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: "“Karşılaştırma” ile anlatılmak istenen nedir?"
    secenekler:
      - {id: A, metin: "İki kayıt arasındaki benzerlik ve farkları incelemek"}
      - {id: B, metin: "Köprünün kenarını yeniden boyamak"}
      - {id: C, metin: "Cihazları tek bir kutuda toplamak"}
      - {id: D, metin: "Dükkânların iş saatlerini belirlemek"}
    dogru: A
    dayanak: "Ekip önceki günün kayıtlarıyla bugünküler arasında bir karşılaştırma yaptı."
    aciklama: "Metindeki \"Ekip önceki günün kayıtlarıyla bugünküler arasında bir karşılaştırma yaptı.\" ifadesi doğru seçeneği destekler."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "{kahraman} ses azaldığı hâlde neden testleri sürdürdü?"
    secenekler:
      - {id: A, metin: "Daha çok cihaz satın almak için"}
      - {id: B, metin: "Köprüyü hiç açmamak için"}
      - {id: C, metin: "Ekip üyelerini değiştirmek için"}
      - {id: D, metin: "Sonucun farklı koşullarda doğrulanması için"}
    dogru: D
    dayanak: "Değişik saatlerde, farklı yürüme ritimlerinde ve farklı hava koşullarında deneme yapılmasını istedi."
    aciklama: "Metindeki \"Değişik saatlerde, farklı yürüme ritimlerinde ve farklı hava koşullarında deneme yapılmasını istedi.\" ifadesi doğru seçeneği destekler."
---

@omurga

Kentin iki yakasını birleştiren yaya köprüsünde tuhaf bir ses duyuluyordu. Ses, özellikle öğleden sonra kalabalık arttığında ortaya çıkıyor, sonra kendiliğinden kayboluyordu. İnşaat mühendisi olan {kahraman}, köprünün güvenliğini kontrol etmek için çağrıldı. Köprüden geçenleri önce diğer güvenli geçişe yönlendirdi. Köprüye sabah yürüyüşü için gelenler kapalı geçişi görünce nedenini merak etti. {kahraman} geçici levhada kullanılan dili inceledi. Teknik terimlerle dolu bir duyuru yerine kısa ve anlaşılır bir açıklama yazıldı. Böylece bakımın ne zaman biteceği bilinmese de önlemin amacı anlaşılır hâle geldi. Ardından kesin bir açıklama yapmak yerine bilinenlerle bilinmeyenleri ayırdı. Köprünün yüzeyinde belirgin bir hasar görülmüyordu. Yine de yalnızca gözle bakmak yeterli değildi. {kahraman} geçici ölçüm cihazlarıyla köprünün farklı noktalarını inceleyecekti. Sorunun kaynağı bulunmadan köprüyü yeniden açmayı doğru bulmuyordu.

---

@omurga

Teknik ekip üç noktaya küçük bir sensör yerleştirdi. Sensör, hareket sırasında oluşan titreşim miktarını kaydedebilen bir cihazdı. {kahraman} her ölçümden önce cihazların doğru çalışıp çalışmadığını sınadı. İlk veri dizisi sabah saatlerine aitti. İkinci ölçümde köprünün bir kenarı ötekinden daha fazla sallanıyor görünüyordu. Ölçüm cihazlarından birinin kaydı diğerlerinden az farklıydı. {kahraman} bunun köprünün davranışından mı yoksa cihazın yerleşiminden mi kaynaklandığını ayırmaya çalıştı. Sensörün bağlantısı yeniden kontrol edildi. Tek bir sayının bütün raporu yönlendirmemesi için aynı noktada ikinci ölçüm alındı. Her sonuç yanına açıklamasıyla yazıldı. Fakat o sırada yakındaki bakım aracının çalıştığı fark edildi. {kahraman} yanlış bir sonuca varmak istemedi. Araç durduktan sonra yeni bir ölçüm yapılmasını istedi. Ekip, ölçüm koşullarının da sonuç kadar önemli olduğunu böylece gördü. Her değişikliği saat ve hava durumuyla birlikte kaydettiler.

---

@omurga

Öğleden sonraki kayıtlarda sesin yalnızca belirli adım ritimlerinde arttığı görüldü. {kahraman} sayıların tek başına bir şey söylemediğini, onları doğru soruyla yorumlamak gerektiğini anlattı. Ekip önceki günün kayıtlarıyla bugünküler arasında bir karşılaştırma yaptı. Verileri karşılaştırırken köprü üstündeki insan sayısı da kaydedilmişti. Kalabalıkla ses arasında ilişki var gibi görünüyordu fakat bu tek başına neden-sonuç kanıtı değildi. {kahraman} ekibe bir tablo gösterdi; koşullar aynı olmadığında iki sayının doğrudan eşitlenemeyeceğini anlattı. Birlikte daha dikkatli yorum yapmaya başladılar. Köprünün kenarındaki gevşek bağlantı parçasının aynı ritimde hafifçe vurduğu anlaşıldı. Bu durum hemen büyük bir tehlike anlamına gelmiyordu; ancak onarılmadan bırakılması da doğru değildi. {kahraman} bulguyu gizlemek yerine belediye teknik birimine ayrıntılı olarak iletti. Hangi sonucun ölçüldüğü, hangisinin henüz tahmin olduğu belgede ayrı yazılıydı.

---

@omurga

Onarım ekibi bağlantıyı söküp incelemek için koruyucu bir düzenek kurdu. Parçada yüzey aşınması vardı. Değiştirilen küçük parçanın ardından aynı koşullarda yeni ölçümler yapıldı. Ses azalmıştı; buna rağmen {kahraman} hemen kesin hüküm vermedi. Bağlantı parçası çıkarıldığında eski ve yeni parçanın ölçüleri yan yana kondu. Görünüşleri birbirine yakındı ama küçük bir aşınma farkı vardı. {kahraman} bu farkın nerede oluştuğunu fotoğrafla belgeledi. Parça değiştirmekten daha fazlası, benzer bir sorun olduğunda nereye bakılacağını öğrenmekti. Bakım defterine bu bilgi eklendi. Değişik saatlerde, farklı yürüme ritimlerinde ve farklı hava koşullarında deneme yapılmasını istedi. Çalışma birkaç gün sürdü. Köprü hâlâ kapalıyken karşıya geçmek isteyenlere diğer yolun neden kullanıldığı açıkça anlatıldı. Teknik ekibin işini hızlı göstermek yerine doğru yapmak istemesi, başlangıçta sabırsızlananların da güvenini kazandı.

---

@omurga

Son testlerde titreşim düzeyi teknik değerlendirmeye uygun bulundu. {kahraman} köprünün yeniden açılmasına ilişkin rapora yalnızca bu ölçümlerin sınırları içindeki sonuçları yazdı. Köprü açıldığında insanlar artık eski sesi duymuyordu. Köprü açıldıktan sonra ilk geçenler yavaş adımlarla ilerledi. Bazıları yeni yapılan kontrollerin ne anlama geldiğini sordu. {kahraman} rapordaki teknik ayrıntıları gizlemeden, günlük dille özetledi. Güven duygusu yalnızca sessiz bir köprüyle değil, açık bir açıklamayla da güçleniyordu. Ekip sonraki kontrol tarihini belirledi. Yakındaki dükkân sahibi, “Demek ki sorun tek bir vidada saklıymış,” dedi. {kahraman} gülümsedi: “O parçayı bulmamızı sağlayan şey dikkatli kayıt ve tekrar deneydi.” Günün sonunda sensörler toplandı, ölçüm tablosu arşive kaldırıldı. Sessiz köprü yeniden insanların adımlarını taşırken küçük bir sesin nasıl önemli bir araştırmaya dönüştüğü unutulmadı.
