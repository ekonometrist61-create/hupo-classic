---
baslik: "Dağın Öbür Yanına Ses"
slug: "hr149-baba-dagin-obur-yanina-ses"
fis_kodu: "HR-149"
tur: bilim
konu: radyo_iletisim_iyilestirme
sinif_alt: 6
sinif_ust: 6
kahraman_turu: baba
deger_anahtarlari: [D20, D3]
tanitim: "Dağların arasındaki vadide haberleşme sık sık kesiliyor. {kahraman} ölçümlerle sesin ulaşabileceği güvenli yolu araştırıyor."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 6
  maarif: {ana_deger: D20, yardimci_deger: D3}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr149, tur: lexeme, etiket: "frekans", islev: first_hint}
  - {id: sozcuk2_hr149, tur: lexeme, etiket: "sinyal", islev: application}
  - {id: sozcuk3_hr149, tur: lexeme, etiket: "engel", islev: application}
  - {id: sozcuk4_hr149, tur: lexeme, etiket: "kapsama", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "İletişim sorunları en çok nerede görülüyordu?"
    secenekler:
      - {id: A, metin: "Şehir meydanında"}
      - {id: B, metin: "Vadi yolunun bazı noktalarında"}
      - {id: C, metin: "Köyün içindeki pazarda"}
      - {id: D, metin: "Atölyenin koridorunda"}
    dogru: B
    dayanak: "Dağ köyleri arasındaki yol, bazı noktalarda telefon sinyalinin kesildiği uzun bir vadiden geçiyordu."
    aciklama: "Metindeki \"Dağ köyleri arasındaki yol, bazı noktalarda telefon sinyalinin kesildiği uzun bir vadiden geçiyordu.\" ifadesi doğru seçeneği destekler."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "İlk konum niçin elendi?"
    secenekler:
      - {id: A, metin: "Bakım defteri bulunmadı"}
      - {id: B, metin: "Orada çok insan vardı"}
      - {id: C, metin: "Kaya radyo dalgasını engelliyordu"}
      - {id: D, metin: "Yol haritası kaybolmuştu"}
    dogru: C
    dayanak: "İlk konum uygun görünüyordu fakat arada yüksek bir kaya engel oluşturuyordu."
    aciklama: "Metindeki \"İlk konum uygun görünüyordu fakat arada yüksek bir kaya engel oluşturuyordu.\" ifadesi doğru seçeneği destekler."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: "“Sinyal” sözcüğü burada neyi anlatıyor?"
    secenekler:
      - {id: A, metin: "İletişim taşıyan işareti"}
      - {id: B, metin: "Yol kenarındaki ağacı"}
      - {id: C, metin: "Araçların yakıtını"}
      - {id: D, metin: "Dağdaki rüzgârı"}
    dogru: A
    dayanak: "Ekip, vadinin karşı tarafında aynı anda ölçüm yaparak sinyal gücünü not etti."
    aciklama: "Metindeki \"Ekip, vadinin karşı tarafında aynı anda ölçüm yaparak sinyal gücünü not etti.\" ifadesi doğru seçeneği destekler."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "{kahraman} bakım planını niçin hazırladı?"
    secenekler:
      - {id: A, metin: "Dağların adını değiştirmek için"}
      - {id: B, metin: "Haritayı büyütmek için"}
      - {id: C, metin: "Denemeleri gizlemek için"}
      - {id: D, metin: "Sistemin ileride de çalışmasını sağlamak için"}
    dogru: D
    dayanak: "{kahraman} bakım planını, cihazların kontrol tarihlerini ve olası arıza işaretlerini bir dosyada topladı."
    aciklama: "Metindeki \"{kahraman} bakım planını, cihazların kontrol tarihlerini ve olası arıza işaretlerini bir dosyada topladı.\" ifadesi doğru seçeneği destekler."
---

@omurga

Dağ köyleri arasındaki yol, bazı noktalarda telefon sinyalinin kesildiği uzun bir vadiden geçiyordu. Haberleşme teknikeri olan {kahraman}, bu yol üzerindeki iletişimi iyileştirmek için görevlendirildi. Yol ekipleri, kış aylarında birbirlerine daha kolay ulaşmak istiyordu. {kahraman} haritaya çizilmiş düz bir çizginin, gerçek arazinin bütün ayrıntılarını gösteremeyeceğini biliyordu. Vadiye ilk gidildiğinde ekip, haberleşmenin en çok hangi saatlerde gerekli olduğunu yol görevlilerine sordu. Sabah ve akşam yapılan kontroller farklı olabiliyordu. {kahraman} kullanım ihtiyacını anlamadan yalnızca en güçlü cihazı seçmenin yararlı olmayacağını biliyordu. Planın merkezinde cihaz değil, iletişim kurması gereken insanlar vardı. Önce vadiye gidip farklı yüksekliklerde ölçüm yaptı. Rüzgâr esiyor, tepelerde sis dolaşıyordu. Ölçüm cihazını yağmurdan koruyarak ilerledi. Birkaç noktada ses çok netti, başka noktalarda neredeyse duyulmuyordu. Bu düzensizliği anlamadan yeni cihaz kurulmasını önermedi.

---

@omurga

İkinci gün tepelerin arkasında kalan alanlar incelendi. Radyo dalgalarının yayılışında kullanılan frekans ve arazi yapısı birlikte değerlendiriliyordu. Frekans, bir dalganın belirli sürede ne kadar sık tekrar ettiğini anlatan ölçüydü. {kahraman} teknik ekiple harita üzerinde üç olası yer belirledi. Haritadaki üç nokta arasında yürüyerek ilerlemek kolay değildi. Teknik ekip güzergâhı önceden kontrol etti ve güvenli alanların dışına çıkmadı. {kahraman} en uygun konumu seçerken bakım aracının ulaşabileceği yolu da hesaba kattı. Bir düzenek çalışmaya başladıktan sonra arızalandığında ona ulaşabilmek de gerekiyordu. İlk konum uygun görünüyordu fakat arada yüksek bir kaya engel oluşturuyordu. İkinci konuma ulaşmak zordu; bakım ekibi oraya güvenle gidemeyebilirdi. Üçüncü yer, yol ve tepe arasında dengeli bir noktadaydı. {kahraman} yalnızca en yüksek tepeyi seçmenin her zaman en iyi sonuç vermediğini kaydetti.

---

@omurga

Üçüncü noktaya geçici bir verici yerleştirildi. Ekip, vadinin karşı tarafında aynı anda ölçüm yaparak sinyal gücünü not etti. Sonuçlar umut vericiydi ama belirli bir virajda iletişim hâlâ kesiliyordu. {kahraman} ekip arkadaşlarından biriyle yol kenarındaki güvenli bir noktada durdu. Ölçüm sonuçlarına bakıldığında vadi boyunca kapsama alanının düzensiz olduğu görülüyordu. Kapsama, haberleşmenin kurulabildiği bölgenin genişliğini anlatıyordu. {kahraman} boş kalan küçük alanları harita üzerinde işaretledi. Böylece ekibin yalnızca iyi duyulan bölgelere odaklanması önlenmiş oldu. Eksik kalan kısımlar da planın parçasıydı. Ölçümlerin saati ve hava koşulları karşılaştırıldı. Sorunun, virajı çevreleyen dik kayaların etkisiyle büyüdüğü anlaşıldı. Cihazın gücünü sınırsız artırmak bir çözüm değildi. Bunun yerine daha uygun bir yerleşim ve yönlendirme üzerinde çalışıldı. Denemeler, teknik kurallara uygun şekilde yürütüldü.

---

@omurga

Yeni düzenlemenin ardından test aracı aynı yolu yeniden izledi. Önceden kesilen virajda kısa bir sesli mesaj karşı tarafa ulaştı. {kahraman} sevindi ama tek bir denemeyi yeterli bulmadı. Günün farklı saatlerinde yapılan tekrarlar da başarılı oldu. Eğitime katılan yol görevlileri kısa ve açık mesajlar göndermeyi denedi. Bir mesaj çok uzun olduğunda önemli bilgi arada kaybolabiliyordu. {kahraman} örnek konuşmaları dinleyerek gerekli düzeltmeleri yaptı. Sistem ne kadar güçlü olursa olsun onu kullananların anlaşılır iletişim kurması da önemliydi. Bu nedenle eğitim uygulamalı düzenlendi. Yol bakım görevlileri sistemi kullanmadan önce kısa bir eğitim aldı. Hangi durumda hangi kanaldan iletişim kurulacağı açıkça anlatıldı. {kahraman} bakım planını, cihazların kontrol tarihlerini ve olası arıza işaretlerini bir dosyada topladı. Yardım sağlayan bir düzenin, kurulduktan sonra unutulamayacağını biliyordu.

---

@omurga

Birkaç gün sonra vadide yoğun sis oluştu. Yol ekipleri gerekli bilgileri birbirlerine aktarabildi. Haberleşmenin iyileşmesi, onların çalışmasını daha düzenli hâle getirmişti. {kahraman} son gözlemde vadiyi uzaktan izledi. Sisli günün ardından ekip yeniden bir araya geldi. Alınan mesajın duyulmuş olması sevindiriciydi ama kayıtların kontrolü de tamamlandı. {kahraman} son dosyaya hangi alanların henüz tekrar test edilmesi gerektiğini yazdı. Başarılı bir çalışma, kalan soruları unutturmak yerine görünür hâle getiriyordu. Dağların biçimi değişmemişti; yollar yine kıvrılıyordu. Fakat artık bu kıvrımlar arasındaki sessizlik eskisi kadar güçlü değildi. Köyden gelen bir görevli, “Sesin ulaşması insana güven veriyor,” dedi. {kahraman} elindeki haritaya yalnızca bir işaret ekledi: düzenli bakım. Bir cihazın işe yaraması kadar, gerektiği anda çalışmaya devam etmesi de önemliydi.
