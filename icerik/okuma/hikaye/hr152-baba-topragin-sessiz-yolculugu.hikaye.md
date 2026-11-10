---
baslik: "Yağmurla Yola Çıkan Toprak"
slug: "hr152-baba-topragin-sessiz-yolculugu"
fis_kodu: "HR-152"
tur: bilim
konu: toprak_erozyon_modeli
sinif_alt: 7
sinif_ust: 7
kahraman_turu: baba
deger_anahtarlari: [D5, D19]
tanitim: "Yağmur verimli toprağı tarlalardan uzaklaştırıyor. {kahraman} suyun ve toprağın hareketini inceleyerek kalıcı önlemler tasarlıyor."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 7
  maarif: {ana_deger: D5, yardimci_deger: D19}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr152, tur: lexeme, etiket: "erozyon", islev: first_hint}
  - {id: sozcuk2_hr152, tur: lexeme, etiket: "örneklem", islev: application}
  - {id: sozcuk3_hr152, tur: lexeme, etiket: "eğim", islev: application}
  - {id: sozcuk4_hr152, tur: lexeme, etiket: "çökeltme", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Araştırmayı başlatan temel sorun neydi?"
    secenekler:
      - {id: A, metin: "Tepenin bütünüyle kuruyup çatlaması"}
      - {id: B, metin: "Tarlaların başka yere kayması"}
      - {id: C, metin: "Yağmur suyunun toprağı taşıması"}
      - {id: D, metin: "Bütün yolların birden kapanması"}
    dogru: C
    dayanak: "Kırsaldaki bir tepenin eteklerinde yağmurdan sonra bulanık su birikiyordu."
    aciklama: "Yağmurdan sonra biriken bulanık su, toprağın taşındığını gösteriyordu; araştırma bunun için başladı. Tepenin kuruması, tarlaların kayması ve yolların kapanması metinde geçmez."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Aynı büyüklükteki kaplarda köklü toprakta su daha yavaş akıyor. Bu neyi düşündürür?"
    secenekler:
      - {id: A, metin: "Bitki kökleri toprağı tutabilir"}
      - {id: B, metin: "Bütün bitkiler aynı türdendir"}
      - {id: C, metin: "Kapların büyüklüğü hiç önemli değildir"}
      - {id: D, metin: "Yağmur yalnızca yazın yağmaktadır"}
    dogru: A
    dayanak: "Bitki köklerinin bulunduğu örnekte suyun daha yavaş aktığı görüldü."
    aciklama: "Kökler suyu yavaşlatıyor, bu da bitki örtüsünün toprağı tutmaya yardım edebileceğini düşündürür. Bitki türü, kap büyüklüğü ve yağış mevsimi bu deneyden çıkarılamaz."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: "“Biri çok dik, diğeri daha yumuşak bir eğim taşıyordu.” cümlesindeki “eğim” hangi özelliği anlatır?"
    secenekler:
      - {id: A, metin: "Toprağın rengini"}
      - {id: B, metin: "Yüzeyin diklik derecesini"}
      - {id: C, metin: "Yağmurun sıcaklığını"}
      - {id: D, metin: "Bitkilerin yaprak sayısını"}
    dogru: B
    dayanak: "Biri çok dik, diğeri daha yumuşak bir eğim taşıyordu."
    aciklama: "Dik ve yumuşak sözcükleri yüzeyin ne kadar yatık olduğunu anlatır; eğim diklik derecesidir. Renk, sıcaklık ve yaprak sayısı eğimle ilgili değildir."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 5
    metin: "Yağmurdan sonra toprak kaybı azalınca {kahraman} bunu neden kesin başarı saymadı?"
    secenekler:
      - {id: A, metin: "Çalışmayı kimseye göstermemek için"}
      - {id: B, metin: "Yeni örnek almak istemediği için"}
      - {id: C, metin: "Tarlaları bir an önce satmak için"}
      - {id: D, metin: "Ölçümlerin sürmesi gerektiği için"}
    dogru: D
    dayanak: "Mevsim boyunca tekrarlanacak ölçümlerin daha güvenilir bilgi sağlayacağını söyledi."
    aciklama: "Tek yağmurun sonucu erken bir bulguydu; güvenilir bilgi için ölçümlerin mevsim boyunca sürmesi gerekiyordu. Gizleme, örnek almama ya da tarla satma gerekçe değildir."
---

@omurga

Kırsaldaki bir tepenin eteklerinde yağmurdan sonra bulanık su birikiyordu. Aşağıdaki küçük tarla bundan zarar görmüştü. Toprak bilimi uzmanı {kahraman}, suyun neden bu kadar çok toprak taşıdığını anlamak için çağrıldı. Tepeyi dolaşırken bir yerde ince, başka bir yerde kalın toprak tabakası gördü. Herkes toprağın bir yerden başka yere gittiğini anlatıyordu ama hangi yağmurdan sonra ne kadar değiştiğine dair ortak bir kayıt yoktu. {kahraman} belirli gözlem noktaları seçti ve bunları köy odasının duvarındaki eski haritaya işaretledi; herkes aynı yerlere bakarsa gözlemler karşılaştırılabilirdi. Tarla sahipleri, işaretlerin günlük işlerine engel olmayacağı konusunda bilgilendirildi. Bazı yamaçlarda bitki örtüsü zayıflamıştı ama {kahraman} her yere aynı tohumu ekmeyi önermedi. Önce toprağın yapısını, suyun izlediği yolu ve yüzeyin eğimini ayrı ayrı incelemek gerekiyordu. Çalışmayı köydeki arazi sahipleriyle birlikte planladı.

---

@omurga

Ekip tepenin farklı yerlerinden küçük bir örneklem topladı. Örneklem, bütün alanı daha iyi anlamak için seçilen sınırlı sayıda parçadır. Toprak örnekleri aynı büyüklükte kaplara kondu ve karışmasınlar diye numaralandırıldı. Kapların altına akan suyu toplayan küçük tepsiler yerleştirildi. Sonra kontrollü biçimde, her kaba aynı miktarda su verildi. Bitki köklerinin bulunduğu örnekte suyun daha yavaş aktığı görüldü. Toprakların renkleri farklıydı; bazıları kolayca dağılıyor, bazıları daha toplu duruyordu. {kahraman} yalnızca renge bakarak karar vermedi. Topraktaki organik parçaların, bitki köklerinin ve farklı büyüklükteki tanelerin suyun davranışını etkileyebileceğini anlattı. Açıktaki toprak daha kolay taşınıyordu. Verimli üst toprağın yerinden kopup başka yere taşınmasına erozyon denir. {kahraman} sonuçları herkesin anlayacağı bir çizimle gösterdi ama kapta görülen sonucun doğrudan bütün tepeye uygulanamayacağını da ekledi; gerçek arazide rüzgâr, yağış ve zemin birlikte etkiliydi.

---

@omurga

İkinci aşamada tepeden inen küçük akış yolları işaretlendi. Biri çok dik, diğeri daha yumuşak bir eğim taşıyordu. Yağmur sırasında suyun nerede hızlandığı güvenli bir noktadan gözlendi. Yağmur dindikten sonra akış yollarının kenarında küçük çukurlar ve sürüklenmiş çakıllar görüldü. {kahraman}, toprağın az sürüklendiği yerlerde bitki örtüsünün daha sık olduğunu not etti. Komşu arazilerde aynı yağmurun farklı izler bırakması dikkat çekiciydi; yamaçlar yalnızca diklik bakımından değil, bitki örtüsü ve yüzey yapısı bakımından da birbirinden ayrılıyordu. Bir arazi sahibi, kendi tarlasına yapılacak düzenlemenin aşağıdaki tarlayı etkileyebileceğini ilk kez bu kadar açık gördü. Komşu arazilerin sahipleri de görüşmeye çağrıldı ve herkes kendi sınırına değil, suyun bütün yolunu gösteren haritaya baktı. Bazı noktalarda geçici su yönlendirme düzenekleri işe yarayabilirdi ama yanlış yapılırlarsa sorunu başka tarlaya taşıyabilirdi. Bu yüzden çözüm tek bir parsele göre tasarlanmadı.

---

@omurga

Plan, toprağı koruyacak bitkilendirme alanlarını ve uzmanların belirlediği küçük su yavaşlatma noktalarını içeriyordu. Bir köşede çökeltme için güvenli bir alan ayrıldı; suyla gelen ince parçaların nasıl biriktiği burada gözlenecekti. {kahraman} her yere aynı yöntemi uygulamak yerine koşullara göre farklı çözümler seçti. Yavaşlatma noktaları yapılırken küçük canlıların geçiş yolları korundu, eski yürüyüş patikası açık tutuldu. Toprağı gereksiz kazmak, korunmak istenen yüzeyi daha da bozabilirdi. Ekip düzeneklerin yağmurlu havada nasıl davranacağını önceden tartıştı. {kahraman}, bakım ve kontrol tarihlerinin de yazılmasını istedi; kontrol edilmeyen bir düzenek zamanla yeni bir soruna dönüşebilirdi. Bu yüzden planın yanına bir izleme çizelgesi eklendi. İşaretlerin yanına bir yağmur ölçer de kondu; böylece her ölçüm aynı gün düşen yağmurla birlikte yazılacaktı. İlk yağmur beklenirken ekip ölçüm işaretlerini yerleştirdi ve not defterlerini hazırladı.

---

@omurga

Yağmurdan sonraki ölçümde su tam berrak değildi; zaten bunu hemen beklemek doğru olmazdı. Fakat bazı noktalarda taşınan toprak miktarı azalmıştı. {kahraman} bu erken bulguyu kesin başarı diye duyurmadı. Mevsim boyunca tekrarlanacak ölçümlerin daha güvenilir bilgi sağlayacağını söyledi. Defterlerin ilk sayfasına tarih, yağış ve gözlem yeri başlıkları açıldı. Bir tarla sahibi aşağıdaki komşusunu da ölçüme çağırdı. Tarla sahipleri bakım görevlerini mevsimlere göre paylaştı: Biri bitki örtüsünü, öbürü su akış işaretlerini kontrol edecekti. Tepeye bakan biri yapılan işleri yalnızca küçük çizgiler ve yeşil yamalar olarak görüyordu. Oysa bu çizgiler toprağın yerinde kalmasına yardım eden dikkatli bir planın parçalarıydı. {kahraman} giderken örnek kaplarını topladı; toprağı korumak, onu önce anlamakla başlamıştı.