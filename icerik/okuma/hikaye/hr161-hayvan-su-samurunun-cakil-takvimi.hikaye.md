---
baslik: "Su Samurunun Çakıl Takvimi"
slug: "hr161-hayvan-su-samurunun-cakil-takvimi"
fis_kodu: "HR-161"
tur: doga
konu: nehir_su_seviyesi
sinif_alt: 5
sinif_ust: 5
kahraman_turu: hayvan
deger_anahtarlari: [D5, D12]
tanitim: "Nehir kenarındaki taşlar gün gün suyun altında kalıyor. {kahraman} küçük çakıllarla su seviyesinin değişimini izliyor."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 5
  maarif: {ana_deger: D5, yardimci_deger: D12}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr161, tur: lexeme, etiket: "seviye", islev: first_hint}
  - {id: sozcuk2_hr161, tur: lexeme, etiket: "gözlem", islev: application}
  - {id: sozcuk3_hr161, tur: lexeme, etiket: "kıyı", islev: application}
  - {id: sozcuk4_hr161, tur: lexeme, etiket: "düzenli", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Nehirde hangi değişim fark edildi?"
    secenekler:
      - {id: A, metin: "Suyun hiç değişmeden hep aynı kaldığı"}
      - {id: B, metin: "Suyun bazı günler yükselip alçaldığı"}
      - {id: C, metin: "Taşların renksizleştiği"}
      - {id: D, metin: "Kuşların hiç uçmadığı"}
    dogru: B
    dayanak: "Sonbaharda nehrin bazı günler yükseldiğini, bazı günler ise alçaldığını fark etti."
    aciklama: "Metindeki \"Sonbaharda nehrin bazı günler yükseldiğini, bazı günler ise alçaldığını fark etti.\" cümlesi B seçeneğini doğrular. Su sürekli aynı kalmamış, taşların rengi kaybolmamış, kuşlar da uçmaya devam etmişti."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Neden her gün aynı saatte gözlem yapıldı?"
    secenekler:
      - {id: A, metin: "Günleri kıyaslayabilmek için"}
      - {id: B, metin: "Taşları daha hızlı taşımak için"}
      - {id: C, metin: "Suyu durdurmak için"}
      - {id: D, metin: "Yağmuru önlemek için"}
    dogru: A
    dayanak: "{kahraman} suyun seviyesini her gün aynı saatlerde gözledi."
    aciklama: "Metindeki \"{kahraman} suyun seviyesini her gün aynı saatlerde gözledi.\" cümlesi, ölçümlerin aynı koşullarda yapıldığını gösterir; böylece günler birbiriyle kıyaslanabilir. Taşları taşımak, suyu durdurmak ve yağmuru önlemek metinde gözlemin amacı değildir."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 2
    metin: "“Seviye” sözcüğü bu hikâyede neyi gösterir?"
    secenekler:
      - {id: A, metin: "Kuşların uçuş hızını"}
      - {id: B, metin: "Çakıl taşlarının renk tonunu"}
      - {id: C, metin: "Su yüzeyinin yüksekliğini"}
      - {id: D, metin: "Ağacın yaşını"}
    dogru: C
    dayanak: "Seviye, su yüzeyinin yüksekliğini anlatıyordu."
    aciklama: "Metindeki \"Seviye, su yüzeyinin yüksekliğini anlatıyordu.\" cümlesi sözcüğün anlamını doğrudan verir. Kuşların hızı, taşların rengi ve ağacın yaşı seviye ile ilgili değildir."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 3
    metin: "{kahraman} neden bir günlük değişimle kesin hüküm vermedi?"
    secenekler:
      - {id: A, metin: "Taşları kimse görmesin diye gizlemek için"}
      - {id: B, metin: "Nehirden bir an önce uzaklaşmak için"}
      - {id: C, metin: "Kaplumbağa ve kuşları sürekli bekletmek için"}
      - {id: D, metin: "Düzeni uzun süre izlemek gerektiği için"}
    dogru: D
    dayanak: "{kahraman} bir günlük değişimle uzun süreli düzeni karıştırmamaya çalıştı."
    aciklama: "Metindeki \"{kahraman} bir günlük değişimle uzun süreli düzeni karıştırmamaya çalıştı.\" cümlesi, tek bir günün sonucunu kalıcı düzen sanmak istemediğini gösterir; bu yüzden gözlemi önceki günlerle birlikte değerlendirdi. Taşları gizlemek, nehirden kaçmak ve arkadaşlarını bekletmek metinde yoktur."
---

@omurga

{kahraman} nehir kenarında yaşayan bir su samuruydu. Günlerinin çoğunu suyun sesini dinleyerek geçirirdi. Sonbaharda nehrin bazı günler yükseldiğini, bazı günler ise alçaldığını fark etti. Kıyıdaki küçük taşlar bir gün su altında kalıyor, ertesi gün yeniden görünüyordu. Sabah ışığı suyun üstüne vurduğunda taşların görünüşü değişiyordu. {kahraman} yalnızca renge bakıp karar vermedi; taşın gerçekten suyun altında kalıp kalmadığına dikkat etti. {kahraman} bu değişimi anlamak için taşların yanına dikkatlice bakmaya başladı. Nehirdeki canlıları rahatsız etmeden aynı noktadan gözlem yapacaktı. Yaşlı bir kaplumbağa da her gün o bölgede dinlenirdi. Kaplumbağa, “Bu taş geçen hafta görünmüyordu,” dedi. {kahraman} yalnızca hatırlamaya güvenmek yerine düzenli bir işaret sistemi düşünmeye başladı.

---

@omurga

Nehir kıyısında üç yuvarlak çakıl buldu. Taşları suya atmadı; mevcut yerlerini işaret olarak kullanmayı seçti. İlk taş suyun hemen kenarındaydı. İkincisi biraz yukarıda, üçüncüsü ise küçük bir ağaç kökünün yanındaydı. {kahraman} suyun seviyesini her gün aynı saatlerde gözledi. İşaretlerin çevresindeki otlar uzamaya başladığında bazı çakıllar zor görünüyordu. {kahraman} otları koparmak yerine bakış noktasını değiştirdi. Böylece doğal çevre bozulmadan gözlem sürdü. Taşlar olduğu yerde kaldı. Seviye, su yüzeyinin yüksekliğini anlatıyordu. Bir gün ilk iki taş görünmez oldu. Ertesi gün yalnızca ilk taş suyun altında kaldı. {kahraman} taşlara bakarak büyük bir değişimin tek gecede değil, gün gün izlenebildiğini fark etti. Kaplumbağa da gözlemlerini paylaşmaya başladı.

---

@omurga

Yağmurlu bir akşamdan sonra nehir hızlandı. {kahraman} suya yaklaşmadı, yüksek bir kıyı noktasından izledi. Ertesi gün üç taşın hiçbiri görünmüyordu. Kıyıdaki kuşlar, yuvalarına giden dar geçidin suyla kaplandığını fark etmişti. {kahraman} onları yüksek patikaya yönlendirdi. Kimse acele etmedi; geride kalan olup olmadığını kontrol ederek yolun kuru olduğu bölümden ilerlediler. Bu sırada kaplumbağa, yağmurdan sonra suyun birden yükseldiğini hatırlattı. {kahraman} bir günlük değişimle uzun süreli düzeni karıştırmamaya çalıştı. Her yeni gözlemi önceki günlerle birlikte düşündü.

---

@omurga

Bir süre sonra yağışlar azaldı. Çakıllar yeniden görünmeye başladı. {kahraman} kaplumbağayla birlikte kıyı boyunca yürüdü. Yüksek suda kullanılabilecek güvenli dinlenme noktalarını belirlediler. Kaplumbağa güvenli dinlenme noktalarının yerini hatırlamak için çevredeki büyük taşları saydı. {kahraman} ise kıyının biçimini gözledi. İki farklı yöntem aynı yere ulaşmayı kolaylaştırdı. Küçük gözlemler paylaşılınca çevreyi tanımak kolaylaşıyordu. Bu noktalar, nehrin taşkın dönemlerinde canlıların sakin biçimde uzaklaşabileceği yerlerdi. {kahraman} yalnızca su seviyesinin değişimini izlemiyordu; bu değişimin çevrede yaşayanları nasıl etkilediğini de öğreniyordu. Nehir bazen dingin, bazen hızlı akıyordu. Çakıllar ise aynı yerde durarak gözlem yapmayı kolaylaştırıyordu. Küçük taşlar kocaman bir takvime dönüşmüştü.

---

@omurga

Kış yaklaşırken {kahraman} üçüncü çakılın yanına oturdu. Güneş soluk bir ışık veriyor, su kıyıda hafifçe dalgalanıyordu. Kaplumbağa, “Peki artık nehrin ne yapacağını biliyor muyuz?” diye sordu. {kahraman} başını hafifçe eğdi. Kış öncesi son gözlemde çakılların yalnızca araç olduğunu düşündü. Taşlar değişimi kendiliğinden açıklamıyordu; anlamı kuran dikkatli bakıştı. Kaplumbağa ile birlikte geçen günleri hatırlayınca acele etmeden öğrenmenin sevincini duydu. Nehirse akmaya devam ediyordu. Birkaç günün gözlemi bütün mevsimleri açıklayamazdı. Ama önceye göre daha dikkatliydiler. Yağmurdan sonra hangi yola bakmaları gerektiğini biliyorlardı. Çakıl taşları orada kalacaktı. {kahraman} nehrin sesini dinlerken yarın hangi taşın görüneceğini merak etti.
