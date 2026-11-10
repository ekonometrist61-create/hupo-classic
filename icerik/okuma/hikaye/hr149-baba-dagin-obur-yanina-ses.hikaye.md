---
baslik: Dağın Öbür Yanına Ses
slug: hr149-baba-dagin-obur-yanina-ses
fis_kodu: HR-149
tur: bilim
konu: radyo_iletisim_iyilestirme
sinif_alt: 6
sinif_ust: 6
kahraman_turu: baba
deger_anahtarlari:
  - D20
  - D3
tanitim: Dağların arasındaki vadide haberleşme sık sık kesiliyor. {kahraman} ölçümlerle sesin ulaşabileceği güvenli yolu araştırıyor.
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: 2026-11-10
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 3
  kavram_zorlugu: 3
  ilgi_egilimi: ortak
  temalar:
    - bilim_teknoloji
  ders_baglantisi:
    - turkce
  maarif:
    ana_deger: D20
    yardimci_deger: D3
  ogrenme_hedefleri:
    - id: sozcuk1_hr149
      tur: lexeme
      etiket: verici
      yuva: hr149_verici
      islev: first_hint
    - id: sozcuk2_hr149
      tur: lexeme
      etiket: sinyal
      yuva: hr149_sinyal
      islev: application
    - id: sozcuk3_hr149
      tur: lexeme
      etiket: engel
      yuva: hr149_engel
      islev: application
    - id: sozcuk4_hr149
      tur: lexeme
      etiket: kapsama
      yuva: hr149_kapsama
      islev: transfer
  kanit_duzeyi: C
  program_surumu: TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)
  denetim:
    ajan_a: pending
    ajan_b: pending
    insan: pending
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: İletişim sorunları en çok nerede görülüyordu?
    secenekler:
      - id: A
        metin: Şehir merkezindeki büyük meydanda
      - id: B
        metin: Vadi yolunun bazı noktalarında
      - id: C
        metin: Köyün içindeki küçük pazar yerinde
      - id: D
        metin: Merkezdeki atölyenin uzun koridorunda
    dogru: B
    aciklama: Sinyal, köyleri birbirine bağlayan vadi yolunun bazı noktalarında kesiliyordu. Meydan, pazar ve atölye koridoru metinde geçmez.
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: Ekip üç olası konumdan ilkini niçin eledi?
    secenekler:
      - id: A
        metin: Konumun bakım kaydı bulunamamıştı
      - id: B
        metin: Orada çok sayıda insan toplanmıştı
      - id: C
        metin: Kaya dalgaların yolunu kesiyordu
      - id: D
        metin: Konumun yol haritası kaybolmuştu
    dogru: C
    aciklama: İlk konumda yüksek bir kaya engel oluşturuyordu; radyo dalgalarının geçişini keser. Bakım kaydı, kalabalık ve yol haritası eleme nedeni olarak yazılmamıştır.
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: “Ekip, vadinin karşı tarafında aynı anda ölçüm yaparak sinyal gücünü not etti.” cümlesindeki “sinyal” neyi anlatıyor?
    secenekler:
      - id: A
        metin: Haberleşmeyi taşıyan işareti
      - id: B
        metin: Yol kenarında duran büyük ağacı
      - id: C
        metin: Araçların depodaki yakıtını
      - id: D
        metin: Vadide esen soğuk rüzgârı
    dogru: A
    aciklama: Ölçülen şey haberleşmeyi taşıyan işaretin gücüdür. Ağaç, yakıt ve rüzgâr bu ölçümle ilgili değildir.
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "{kahraman} bakım planını niçin hazırladı?"
    secenekler:
      - id: A
        metin: Dağların adını değiştirmek için
      - id: B
        metin: Haritayı daha da büyütmek için
      - id: C
        metin: Denemeleri herkesten gizlemek için
      - id: D
        metin: Sistemin sonra da çalışması için
    dogru: D
    aciklama: Kontrol tarihleri ve arıza işaretleri düzenin kurulduktan sonra da çalışmasını sağlar. Dağ adı, harita boyutu ya da gizleme planın konusu değildir.
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler:
  - baba
yetiskin_uygun: true
---
@omurga

Dağ köyleri arasındaki yol, bazı noktalarda telefon sinyalinin kesildiği uzun bir vadiden geçiyordu. Haberleşme teknikeri {kahraman}, buradaki iletişimi iyileştirmek için görevlendirildi. Yol ekipleri özellikle kış aylarında birbirine daha kolay ulaşmak istiyordu. Sis çöktüğünde araçlar vadiden tek tek geçiyor, birbirinden haber almak zorlaşıyordu. {kahraman} ilk gün yol görevlilerine haberleşmenin en çok hangi saatlerde gerektiğini sordu; sabah ve akşam ihtiyaçları farklıydı. En güçlü cihazı seçmeden önce kullanıcıların ne istediğini öğrenmek gerekiyordu. Sonra vadiye çıkıp farklı yüksekliklerde ölçüm yaptı. Rüzgâr esiyor, tepelerde sis dolaşıyordu; ölçüm cihazını yağmurdan korudu. Bazı noktalarda ses çok netti, bazı noktalarda neredeyse hiç duyulmuyordu. Haritadaki düz bir çizgi arazinin bütün ayrıntılarını göstermiyordu. Bu düzensizliğin nedenini anlamadan yeni bir cihaz kurulmasını önermedi.

---

@omurga

İkinci gün tepelerin arkasında kalan alanlar incelendi. Radyo dalgalarının nasıl yayıldığı, hem kullanılan frekansa hem de arazinin biçimine bağlıydı. Frekans, bir dalganın belirli sürede kaç kez tekrarlandığını anlatan ölçüdür. {kahraman} teknik ekiple harita üzerinde üç olası yer belirledi. Ekip yürüyüş güzergâhını önceden kontrol etti ve güvenli alanın dışına çıkmadı. {kahraman} konum seçerken bakım aracının ulaşabileceği yolu da hesaba kattı; cihaz arızalanırsa ona ulaşılabilmeliydi. İlk konum uygun görünüyordu fakat arada yüksek bir kaya {kelime:hr149_engel} oluşturuyordu. İkinci konuma ulaşmak zordu, bakım ekibi oraya güvenle gidemeyebilirdi. Üçüncü yer yol ile tepe arasında dengeli bir noktadaydı; bakım aracı oraya rahatça çıkabilirdi. En yüksek tepe her zaman en iyi konum değildi.

---

@omurga

Üçüncü noktaya geçici bir {kelime:hr149_verici} yerleştirildi. Ekip, vadinin karşı tarafında aynı anda ölçüm yaparak {kelime:hr149_sinyal} gücünü not etti. Sonuçlar umut vericiydi ama belirli bir virajda iletişim hâlâ kesiliyordu. {kahraman}, yol kenarındaki güvenli bir noktada {yoldas:yalin|Ege} ile birlikte ölçümlere baktı: Vadi boyunca {kelime:hr149_kapsama} düzensizdi. Kapsama, haberleşmenin kurulabildiği bölgenin genişliğidir. {kahraman} boş kalan küçük alanları haritada işaretledi; ekip yalnızca iyi çeken yerlere bakıp eksikleri unutmamalıydı. Ölçüm sırasında {yoldas:yalin|Ege} vadinin karşı yamacında, öteki virajda duruyor, sonuçları ayrı ayrı yazıyordu. Ölçümlerin saati ve hava koşulları karşılaştırıldı. Sorunun, virajı çevreleyen dik kayalar yüzünden büyüdüğü anlaşıldı. Cihazın gücünü sınırsız artırmak çözüm değildi. Bunun yerine vericinin yerleşimi ve yönü değiştirildi.

---

@omurga

Yeni düzenlemeden sonra test aracı aynı yolu yeniden izledi. Önceden kesilen virajda kısa bir sesli mesaj karşıya ulaştı. {kahraman} sevindi ama tek bir denemeyi yeterli bulmadı. Günün farklı saatlerinde yapılan tekrarlar da başarılı oldu. Yol görevlileri kısa bir eğitim aldı: Hangi durumda hangi kanaldan haberleşileceği anlatıldı, örnek mesajlar denendi. Kimi görevliler mesajları gereğinden uzun kuruyordu. Çok uzun bir mesajda önemli bilgi arada kaybolabiliyordu; {kahraman} örnek konuşmaları dinleyip düzeltmeler önerdi. {kahraman} bakım planını, cihazların kontrol tarihlerini ve olası arıza işaretlerini bir dosyada topladı. Kurulduktan sonra unutulan bir düzen, kısa sürede işe yaramaz hâle gelebilirdi.

---

@omurga

Birkaç gün sonra vadide yoğun sis oluştu. Yol ekipleri gerekli bilgileri birbirine aktarabildi. Sisli günün ardından ekip yeniden bir araya geldi ve kayıtları kontrol etti. {kahraman}, son dosyaya hangi alanların henüz tekrar test edilmesi gerektiğini de yazdı; kalan sorular unutulmamalı, görünür kalmalıydı. Ekip, sinyali hâlâ zayıf kalan kısa bir bölümü de bir sonraki ölçüm listesine aldı. Dağların biçimi değişmemişti, yollar yine kıvrılıyordu. Fakat bu kıvrımların arasındaki sessizlik eskisi kadar uzun sürmüyordu. Köyden gelen bir görevli, “Sesin ulaşması insana güven veriyor,” dedi. {kahraman} elindeki haritaya yalnızca bir not ekledi: düzenli bakım.