---
baslik: "Müzede Sessiz Alarm"
slug: "hr031-muzede-sessiz-alarm"
fis_kodu: "HR-031"
tur: gizem
konu: kanit_varsayim
sinif_alt: 4
sinif_ust: 4
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Müzede alarm çalıyor. Pusulayı mı çalmaya çalışıyorlar, yoksa başka bir neden mi var?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 4
  okuma_zorlugu: 3
  kavram_zorlugu: 3
  ilgi_egilimi: ortak
  temalar: [gizem, kesif]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: sensor_hr031, tur: lexeme, etiket: "sensör", yuva: hr031_sensor, islev: first_hint}
    - {id: algilamak_hr031, tur: lexeme, etiket: "algılamak", yuva: hr031_algilamak, islev: application}
    - {id: vitrin_hr031, tur: lexeme, etiket: "vitrin", yuva: hr031_vitrin, islev: application}
    - {id: kavram_hr031, tur: concept, etiket: "Kanıt ile varsayım", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (4. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 2, metin: "İki alarm hangi ortak durumda duyulmuştu?", secenekler: [{id: A, metin: "Havalandırma çalışmaya başladığında"}, {id: B, metin: "Müze kapandığında"}, {id: C, metin: "Rehber konuştuğunda"}, {id: D, metin: "Pusula düştüğünde"}], dogru: A, aciklama: "İki alarm da havalandırma açıldığında duyulmuştu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 3, metin: "Alarmların nedeni neydi?", secenekler: [{id: A, metin: "Bir algılayıcı havalandırma değişikliğine gereğinden fazla duyarlıydı"}, {id: B, metin: "Hırsızlar gelmişti"}, {id: C, metin: "Pusula bozulmuştu"}, {id: D, metin: "Telefon çalmıştı"}], dogru: A, aciklama: "Teknik görevli, algılayıcının ayarının fazla hassas olduğunu buldu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 5, metin: "İpek'in “acele hüküm vermemek” sözü neyi anlatır?", secenekler: [{id: A, metin: "Kanıt olmadan karar vermemeyi"}, {id: B, metin: "Müzeyi hemen kapatmayı"}, {id: C, metin: "Tahmin etmeyi yasaklamayı"}, {id: D, metin: "Pusulayı çalmayı"}], dogru: A, aciklama: "İpek, kanıt toplamadan karar vermenin yanlış olabileceğini söyledi."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, metin: "Metinde geçen sensör ne işe yarar?", secenekler: [{id: A, metin: "Hareket, sıcaklık gibi değişimleri algılar"}, {id: B, metin: "Bir tür vitrin"}, {id: C, metin: "Ses çıkarır ama bir şey algılamaz"}, {id: D, metin: "Pusulanın parçası"}], dogru: A, aciklama: "Sensör, ortamdaki değişimi algılayan cihazdır."}
---
@omurga
Kent müzesinin en sessiz salonundan aniden ince bir ses yükseldi: bip, bip, bip! Ziyaretçiler durdu. Cam {kelime:hr031_vitrin} tarihî pusula yerli yerindeydi; kimse ona yaklaşmıyordu. Rehber, çocukları güvenli bekleme alanına götürdü. Görevli alarmı kontrol etmeye geldiğinde ses kesildi.

“Pusulayı biri mi çalmaya çalıştı?” diye sordu {yoldas:yalin|bir arkadaş}.

“Bilmiyoruz,” dedi arkadaşları {kahraman}. “Önce ne olduğunu anlamalıyız.”

Bir süre sonra ses yeniden duyuldu. {kahraman}, not defterine saati yazdı. {yoldas:yalin|bir arkadaş} salondaki kalabalığı gözledi. İlk alarm sırasında bir grup kapının yanında bekliyordu; ikinci alarmda ise salon neredeyse boştu. Bu bilgi, kalabalığın tek başına neden olamayacağını düşündürdü. {isaret:kitap}
---
@omurga
Rehber, müzede eşyaların korunması için {kelime:hr031_sensor} kullanıldığını anlattı. “Sensörler hareket, sıcaklık ya da başka değişimleri {kelime:hr031_algilamak}. Bazen de ayarlarının kontrol edilmesi gerekir,” dedi. Çocuklardan cihazlara ve vitrinlere dokunmamalarını özellikle istedi.

{kahraman}, alarmlar arasında ortak bir ayrıntı fark etti. Her ikisi de havalandırma sisteminin çalışmaya başladığı sırada duyulmuştu. Bunun arızanın nedeni olduğunu kesin söyleyemezdi. “Bu yalnızca bir tahmin,” diyerek defterine soru işareti koydu. Rehbere gözlemini aktardı.

Rehber, alarmın duyulduğu iki saati kontrol odasındaki kayıtlara aktardı. {yoldas:yalin|bir arkadaş} önce kendi defterindeki saatlerden birini yanlış yazmış olabileceğini düşündü. {kahraman}, “Zamanları yeniden kontrol edelim,” dedi. Kayıtlar onun notuyla uyuşuyordu. İki farklı kaynağın aynı bilgiyi göstermesi gözlemlerini güçlendirdi ama nedenin ne olduğunu henüz kanıtlamıyordu.
---
@omurga
{yoldas:yalin|bir arkadaş} başka bir olasılık sundu: “Belki alarmı bir telefon sesi tetiklemiştir.” Rehber böyle bir tahmini de not etti; hemen doğru ya da yanlış diye işaretlemedi. {kahraman}, hangi düşüncenin kanıtlandığını anlamanın tahmin sayısını çoğaltmaktan daha önemli olduğunu söyledi. O sırada salonda kimseye suçlayıcı gözle bakmamaya özen gösterdiler.

Teknik görevli salonun boşaltıldığı güvenli bir anda sistemi denetledi.

Teknik görevli salonun boşaltıldığı güvenli bir anda sistemi denetledi. Vitrinin yakınındaki bir algılayıcının, havalandırmanın oluşturduğu değişime gereğinden fazla duyarlı ayarlandığını belirledi. Yetkili ekip ayarı düzenledi ve alarmı birkaç kez denedi. Artık gereksiz ses duyulmuyordu.
---
@omurga
{yoldas:yalin|bir arkadaş} rahatladı. “Demek kimse pusulayı çalmaya çalışmamış.”

{kahraman} dikkatle konuştu: “En azından bu iki alarmın nedeni hırsızlık değilmiş. Başta bunu bilmiyorduk.”

Salon yeniden açılmadan önce rehber, ziyaretçilerin neler olduğunu merak ettiğini gördü. Kısa ve sakin bir açıklama yaptı: “Bir koruma sisteminin gereğinden duyarlı ayarı düzeltildi; eserlerimiz güvende.” {kahraman} bu açıklamayı beğendi. Hem doğru bilgi veriyor hem de kesinleşmemiş bir suçlama içermiyordu. {yoldas:yalin|bir arkadaş}, bir sorunun çözülmesinin yalnız aleti onarmak değil, insanlara doğru bilgiyi aktarmak olduğunu düşündü.

Gezi devam ettiğinde rehber çocuklara tarihî pusulanın eski yolculuklarda yön bulmaya yardım ettiğini anlattı. {yoldas:yalin|bir arkadaş} pusulayı izlerken küçük bir çelişki fark etti: “Eskiden insanlar yolda kaybolmamak için pusula kullanıyordu; şimdi de eserleri kaybetmemek için sensör kullanıyoruz.”
---
@omurga
Sınıfın dönüş otobüsünde herkes en sevdiği eseri söyledi. {kahraman} ise defterindeki üç sözcüğü gösterdi: **gözlem, varsayım, kanıt**. “Bir ses bizi korkutmuştu,” dedi, “ama ne olduğunu anlamak için acele hüküm vermemek gerekiyormuş.”

Bir sonraki hafta müzeden sınıfa teşekkür mesajı geldi. Görevliler, çocukların dikkatli gözlem paylaşımının incelemeyi kolaylaştırdığını yazmıştı. {kahraman} mesajı okurken gülümsedi; müzedeki en ilginç şeyin yalnız geçmişe ait eşyalar değil, bugün kullanılan bilimsel düşünme biçimi olduğunu fark etti.

Dil hedefi: kanıt–varsayım, neden–sonuç; Kavram/değer: sensörler, müze kültürü, acele hüküm vermeme. İkon önerileri: müze, alarm, mercek. Okuma sonrası: {kahraman} hangi ortak ayrıntıyı gözlemledi? Neden bunu önce yalnız tahmin saydı?
