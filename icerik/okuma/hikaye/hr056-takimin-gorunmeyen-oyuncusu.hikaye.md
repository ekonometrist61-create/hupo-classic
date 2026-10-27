---
baslik: "Takımın Görünmeyen Oyuncusu"
slug: "hr056-takimin-gorunmeyen-oyuncusu"
fis_kodu: "HR-056"
tur: arkadaslik
konu: takim_kapsayicilik
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D4, D20]
yetiskin_uygun: false
tanitim: "Takımın listesinde adı yok. Robotik yarışı, sessiz bir çocuğun fikirleriyle nasıl değişti?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [dostluk, dayanisma]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D4
    yardimci_deger: D20
  ogrenme_hedefleri:
    - {id: parkur_hr056, tur: lexeme, etiket: "parkur", yuva: hr056_parkur, islev: first_hint}
    - {id: sensor_hr056, tur: lexeme, etiket: "sensör", yuva: hr056_sensor, islev: application}
    - {id: viraj_hr056, tur: lexeme, etiket: "viraj", yuva: hr056_viraj, islev: application}
    - {id: deyim_hr056, tur: idiom, etiket: "İçi burkulmak", yuva: hr056_ici_burkulmak, islev: application}
    - {id: kavram_hr056, tur: concept, etiket: "Katkıyı görmek ve kapsayıcılık", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Takımda Deniz'e hangi görev verildi?", secenekler: [{id: A, metin: "Yedek olmak"}, {id: B, metin: "Kodlama"}, {id: C, metin: "Sunum"}, {id: D, metin: "Zaman tutmak"}], dogru: A, aciklama: "Deniz'e ilk başta yedek olması söylendi."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Deniz'in çizimi takıma neyi gösterdi?", secenekler: [{id: A, metin: "Sensörün kırık olduğunu ve yeni parça alınması gerektiğini"}, {id: B, metin: "Yarışın erken bittiğini ve takımın ödül alamayacağını"}, {id: C, metin: "Hız değişiminin yerinin sorun olabileceğini"}, {id: D, metin: "Okulun turnuva alanının küçüldüğünü ve masaların kaldırıldığını"}], dogru: C, aciklama: "Deniz, sorunun sensörden önce hız değişiminde olabileceğini düşündü."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 11, metin: "Takım neden başarısız denemelerini sakladı?", secenekler: [{id: A, metin: "Hatalardan öğrenip sonraki yarışa hazırlanmak için"}, {id: B, metin: "Takım arkadaşlarının onları görmesini istemediği ve utandığı için"}, {id: C, metin: "Bu denemeleri yarış sonrasında tamamen unutmak istediği için"}, {id: D, metin: "Öğretmenleri bu denemeleri ayrıca değerlendirmeyi istediği için"}], dogru: A, aciklama: "Başarısız denemeler, gelişmenin yollarını göstermek için saklandı."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 1, metin: "Metinde geçen sensör ne işe yarar?", secenekler: [{id: A, metin: "Oyunda sıra belirlemek için kullanılan küçük bir kart"}, {id: B, metin: "Ortamdaki bir değişikliği algılayıp ölçen cihaz"}, {id: C, metin: "Robotun hızlı dönüş yaptığı yere verilen ad"}, {id: D, metin: "Parkur çizmek için kullanılan kalın bir kâğıt türü"}], dogru: B, aciklama: "Sensör, hız, sıcaklık, mesafe gibi değişkenleri algılar."}
deyim_cumleleri:
  hr056_ici_burkulmak: "Deniz kızmadı ama içi burkuldu."
---
@omurga
Turnuva listesinde herkesin adı vardı; yalnız Deniz'in adı hiçbir görevde görünmüyordu. Beşinci sınıfın robotik {kelime:hr056_parkur} yarışına hazırlanmasına iki hafta kalmıştı. Deniz yeni öğrenci olduğu için kimse onun neleri iyi yapabildiğini bilmiyordu. Sınıfta çok konuşmuyor, teneffüste çoğunlukla çizim defterine bakıyordu. Kimi arkadaşları onun yarışmayı sevmediğini sanmıştı. Oysa Deniz, parkurdaki dönüşleri ve süreleri aklında canlandırmayı çok seviyordu.

Yarışın konusu basitti: Bir robot, yere çizilmiş yolu izleyerek engellere çarpmadan hedefe varacaktı. Görevi bir kişi sürmeyecek, takım olarak planlayacaklardı. Sınıfın hızlı karar veren öğrencisi {yoldas:yalin|bir arkadaş}, kodlamayı üstlendi. Toprak parçaları birleştirecek, Ece zaman tutacak, Barış sunumu yapacaktı. Deniz'e ise “Yedek olursun,” dediler.

[[deyim:hr056_ici_burkulmak]] Öğretmenleri Cenk Bey, takımlara ilk deneme için on dakika verdiğinde Deniz sessizce kenara oturdu. Robot ilk {kelime:hr056_viraj}a hızlı girdi, çizgiyi kaçırıp karton duvara çarptı. Toprak {kelime:hr056_sensor}ün bozuk olduğunu düşündü. {yoldas:yalin|bir arkadaş} kodun hız ayarını değiştirdi. İkinci denemede robot duvara çarpmadı ama virajı çok geniş aldı. Ece, “Süremiz kötü,” dedi.
---
@omurga
Deniz defterine küçük bir çizim yaptı. Robotun giriş açısını, virajın uzunluğunu ve hızın nerede azalıp artması gerektiğini işaretledi. {yoldas:yalin|bir arkadaş} onu görünce “Bu ne?” diye sordu. “Parkurun ölçüsü,” dedi Deniz. “Bence sorun sensörden önce hız değişiminin yerinde.”

Toprak çizime baktı. “Ama sen robotu kullanmadın ki.”

“Çünkü bana görev verilmedi,” diye cevap verdi Deniz. Sonra durup daha sakin konuştu: “İsterseniz birlikte deneyebiliriz.”

Cenk Bey, her öğrencinin bir öneriyi denemeye değer gördüğünde gerekçesini açıklamasını istedi. Deniz robota dokunmadan da planlama yapabileceğini söyledi. Takım birkaç deneme yaptı. Robot yavaşladığı noktayı değiştirince virajı daha düzgün aldı. {yoldas:yalin|bir arkadaş}, “İşe yaradı!” diye bağırdı. Deniz yalnızca gülümsedi.

Başarı, takımın bütün sorunlarını çözmedi. Ertesi gün başka bir parkur eklendi. Bu kez çizginin üzerinde küçük boşluklar vardı. Robot, çizgiyi kaybedince duruyordu. Barış, “Deniz yine bir şey çizer,” dedi. Deniz bundan hoşlanmadı. Bir problemi tek başına çözmesi bekleniyordu ama karar verme sürecine yine tam katılmıyordu. “Birlikte bakalım,” dedi. “Benim çizimim tek çözüm olmayabilir.”
---
@omurga
{yoldas:yalin|bir arkadaş} bunun üzerine görev listesini değiştirdi. Herkes yalnız yaptığı işi değil, karar sürecine katkısını da yazacaktı. Deniz parkur planını paylaşacak, {yoldas:yalin|bir arkadaş} kodu düzenleyecek, Toprak sensörleri test edecek, Ece ölçümleri karşılaştıracak, Barış ekibin sonuçlarını anlatacaktı. Ayrıca işler değiştiğinde herkes farklı görevleri deneyebilecekti. Böylece Deniz yalnız zor anlarda çağrılan bir kişi olmayacaktı.

Turnuvadan üç gün önce takım beklenmedik bir sıkıntıyla karşılaştı. Kullanacakları masalardan biri başka sınıfa ayrılmıştı. Çalışma alanları küçüldü; parkurun tamamını kuramıyorlardı. Toprak sinirlendi. “Bu kadar hazırlık boşa gitti,” dedi. Deniz bir kâğıt açıp parkuru iki bölüme ayırmayı önerdi. Her bölüm ayrı ayrı denenebilir, sonra bütün yol birleştirilebilirdi. Cenk Bey fikri onayladı ama tam parkuru yarış öncesinde güvenli bir alanda mutlaka denemeleri gerektiğini hatırlattı.
---
@omurga
İlk bölümü çalıştırdıklarında robot düzgün ilerledi. İkinci bölümdeyse küçük bir dönüş yine sorun çıkardı. Ece iki denemenin sürelerini karşılaştırdı. Robotun hızlı olması gereken yerde yavaş kaldığını gösterdi. Deniz planındaki işareti değiştirdi, {yoldas:yalin|bir arkadaş} kodu kontrol etti. Bu sefer robot yolun sonuna ulaştı. Beş arkadaş birbirine baktı. Artık kimin neyi yaptığı belli, herkesin emeği görünür olmuştu.

Yarış günü salonda birçok takım vardı. Bazıları gösterişli renkli robotlar getirmiş, bazıları kartondan basit engeller kullanmıştı. Barış sunum sırası geldiğinde Deniz'in adını listeye ekledi: “Parkur planlamasını ve veri yorumlamasını Deniz'le birlikte yaptık.” Deniz şaşırdı. Toprak omzuna dokundu. “Görünmez oyuncu diye bir şey yokmuş,” dedi. “Biz seni yeterince görmemişiz.”

Deniz konuşmasını kısa tuttu. “Robotumuz her denemede bir hata yaptı,” dedi. “Biz hatayı kimin yaptığına değil, hangi koşulda ortaya çıktığına bakınca daha iyi öğrendik.” Jüri üyelerinden biri, farklı hız ayarları için tuttukları tabloyu istedi. Ece tabloyu gösterdi, Deniz seçtikleri yöntemi açıkladı. Takım sunumdan sonra rahatlamıştı.
---
@omurga
Final parkurunda robot son dönüşü başarıyla geçti ama hedefin birkaç santimetre önünde durdu. {yoldas:yalin|bir arkadaş} “Bitti,” diye düşündü. Toprak “Keşke daha fazla deneseydik,” dedi. Deniz ise süre tablosuna baktı. Görev boyunca iyi iş çıkarmışlardı; sonuç birincilik olmayabilirdi. Ece, “Önemli olan öğrendiklerimizi anlatabildik,” dedi. Barış da “Bir dahaki sefer son düzlüğü daha iyi çalışırız,” diye ekledi.

Ödüller açıklanınca takım birincilik kazanmadı. Ama jüri, süreçlerini açık anlattıkları ve görev paylaşımını geliştirdikleri için onlara özel bir takdir belgesi verdi. Deniz belgeye bakarken başka bir şey düşünüyordu. Daha önce sesini çıkarmadığı için kimsenin onu fark etmesini beklemişti. Şimdiyse gerektiğinde kendi fikrini anlatmanın, karşısındakine de dinleme fırsatı vermenin ne kadar önemli olduğunu biliyordu.

Okula döndüklerinde görev listesini yeniden hazırladılar. Bu kez herkesin adının yanında iki satır vardı: “Bildiklerim” ve “Öğrenmek istediklerim”. Deniz, kodlama öğrenmek istediğini yazdı. {yoldas:yalin|bir arkadaş} ise planlama çizimlerinde daha iyi olmayı seçti. Takım artık yalnız yarışmak için değil, birbirinden öğrenmek için de bir araya geliyordu.
---
@omurga
Deniz'in okula başladığı ilk gün aslında oldukça zor geçmişti. Geçen yıl yaşadığı şehirden taşınmış, eski arkadaşlarını geride bırakmıştı. İlk teneffüste sınıf kalabalık bir oyun oynarken kime yaklaşacağını bilememişti. Öğretmeni onu birkaç kişiyle tanıştırmıştı ama herkesin konuşacak çok şeyi vardı. Deniz yeni bir grubun içine hemen giremiyordu. Çizim defteri, kendini rahat hissettiği bir yerdi. Parkurları, haritaları ve çeşitli makineleri çiziyordu. Arkadaşlarının bunu yalnızca resim merakı sandığını fark etmemişti. Gerçekte çizimler, onun düşünme biçiminin bir parçasıydı; bir problemi kâğıt üzerinde görürse daha rahat çözebiliyordu.

{yoldas:ilgi|bir arkadaşın} da güçlü bir alışkanlığı vardı: Sorunları hızlıca çözmek isterdi. Geçen yıl kodlama yarışmasında zamanını yanlış planlamış, bu yüzden takımın son denemeye yetişemediğini düşünüyordu. Bu defa her dakikayı değerlendirmeye kararlıydı. Deniz'in yavaş yavaş çizim yapmasını bazen zaman kaybı sanmasının nedeni buydu. İlk tartışmalarında Deniz “Bir dakika düşünelim,” dediğinde {yoldas:yalin|bir arkadaş} “Zamanımız yok,” diye karşılık vermişti. Sonra robot aynı virajda üç kez hata yapınca, birkaç dakikalık planın daha fazla zaman kazandırabileceğini gördü. Öğrenmek yalnız yeni bir beceri kazanmak değil, eski alışkanlığı gerektiğinde yeniden değerlendirmekti.
---
@omurga
Toprak, sensörün bozuk olduğundan çok emindi ve bunu kendi kendine denemek istiyordu. Öğretmeninden izin alarak okulun kulüp saatinde aynı sensörü farklı hızlarda test etti. Sonuçları görünce sensörün çoğu koşulda doğru çalıştığı ortaya çıktı. Toprak biraz utandı; çünkü ilk anda sorun olduğunu düşündüğü parçayı suçlamıştı. Deniz ona “Ben de bazen harita çizince her şeyin çözüleceğini sanıyorum,” dedi. “Ama plan işe yarıyor mu diye denememiz gerekiyor.” Toprak, bu sözden sonra Deniz'i daha dikkatle dinlemeye başladı. İkisinin de elindeki bilgi tek başına yeterli değildi.

Ece, süreleri kaydederken küçük bir yöntem geliştirdi. Tek bir denemeye bakmak yerine üç denemenin sonuçlarını yan yana yazıyordu. Bir denemede robot çok hızlı gitmiş ama çizgiyi kaçırmıştı. Başka birinde yavaş ilerlemiş ama hedefe ulaşmıştı. Ece, yarışta yalnız hızın değil, parkuru tamamlamanın da puan getirdiğini hatırlattı. “En hızlı denememiz her zaman en iyi denememiz değil,” dedi. {yoldas:yalin|bir arkadaş} bu cümleyi kendi hayatıyla ilişkilendirdi. Geçen yıldan beri hızla gurur duyuyordu. Şimdi doğru kararı verebilmek için bazen yavaşlaması gerektiğini anlıyordu.
---
@omurga
Barış ise herkesin düşündüğünden farklı bir sorunla uğraşıyordu. Sunum yapmayı sevdiği için kolay bir göreve sahip olduğu sanılıyordu. Oysa takımın ne yaptığını gerçekten anlamazsa sunum sırasında sorulan sorulara cevap veremeyeceğini biliyordu. Bu yüzden her çalışmanın sonunda arkadaşlarına kısa sorular soruyordu: “Neden bu hızı seçtik? Alternatifimiz neydi? Hangi deneme başarısız oldu?” Başta {yoldas:yalin|bir arkadaş} “Bunları zaten biliyorsun,” diye karşılık verdi. Barış, “Bilmekle anlatmak aynı şey değil,” dedi. Sonunda tüm takım kendi yöntemlerini başkasına anlatabilecek kadar anlamaya çalışmaya başladı.

Bir gün karşı sınıftan gelen takım, robotlarını incelemek istedi. Toprak önce çekindi; rakiplerinin kendi yöntemlerini öğrenmesini istemiyordu. Öğretmen, yarışın kurallarında nelerin açıkça paylaşılabileceğini anlattı. Öğrenciler kendi tasarımlarını tanıtabilir, genel çalışma ilkelerini konuşabilirdi; fakat başkasının dosyasını izinsiz almak veya yarış esnasında haksız avantaj sağlamak doğru değildi. Deniz, karşı takımın da benzer bir viraj problemi yaşadığını öğrenince bu konuda genel bir fikir paylaşmanın sakıncalı olmadığını düşündü. Rekabetin saygıyla yürüyebileceğini, herkesin öğrenmesini engellemek zorunda olmadığını fark ettiler.
---
@omurga
Takımın en büyük anlaşmazlığı ikinci haftanın sonunda çıktı. {yoldas:yalin|bir arkadaş}, kodda büyük bir değişiklik yapmak istedi. Deniz buna karşı çıktı çünkü son üç denemede çözümün kararlı hâle geldiğini düşünüyordu. İkisi seslerini yükseltti. Barış araya girdi: “İki öneriyi de küçük bir denemeyle karşılaştıralım.” Ece zamanı ölçtü. {yoldas:ilgi|bir arkadaşın} yöntemi düz çizgide daha hızlıydı ama son dönüşte daha fazla sapma gösterdi. Deniz'in önerisi biraz yavaştı ama daha tutarlıydı. Bu kez karar birinin sesini yükseltmesine göre verilmedi. Verilerin ne söylediğine bakıldı. {yoldas:yalin|bir arkadaş}, fikrinin kabul edilmemesine üzüldü ama nedenini anlayabildiği için daha kolay sakinleşti.

Cenk Bey bir toplantıda “Sizce takımın kaptanı kim?” diye sordu. Herkes {yoldas:yonelme|bir arkadaşa} baktı. {yoldas:yalin|bir arkadaş} da biraz gururlandı. Öğretmen, “Kaptanlık yalnız kararları tek başına vermek değildir,” dedi. “İyi bir lider arkadaşlarının hangi katkıları yapabileceğini fark eder ve onları dinler.” {yoldas:yalin|bir arkadaş} daha önce görev dağıtırken bunu düşünmemişti. Şimdi bir sonraki yarışta görevleri kendisi yazmak yerine önce herkesin ilgi alanını sormaya karar verdi. Deniz'e “Bu sefer sen baştan ne yapmak istediğini söyle,” dedi. Deniz de sessiz kalıp anlaşılmayı beklememeyi öğrendi.
---
@omurga
Turnuvadan önce okulun spor salonu hazırlanırken robotlarını taşıyan kutunun kapağı açıldı. Parçalardan biri yere düştü. Çocuklar panikledi. Cenk Bey müdahale etti, küçük parçanın güvenli biçimde kontrol edilmesini sağladı. Toprak bağlantıyı inceleyip yeniden yerine taktı, sonra tüm robotu test etti. Bu olay, iyi bir planın yalnız parkurda değil malzemeleri taşıma ve saklama sırasında da gerekli olduğunu gösterdi. Barış kontrol listesine yeni bir satır ekledi: “Taşıma kutusunu kilitle, bağlantıları kontrol et, son denemeyi güvenli alanda yap.” Başarılı yarış için küçük ayrıntılar da önemliydi.

Jüri önünde sunum sırası geldiğinde Barış bir an heyecanlandı ve sözcükleri karıştırdı. {yoldas:yalin|bir arkadaş} ona başıyla işaret verdi. Deniz, çizim defterinden iki sayfa açıp sıradaki görseli gösterdi. Barış nefesini düzenleyip konuşmasına devam etti. Sonradan “Ben tek başıma anlatıyorum sanıyordum, aslında hepiniz yanımdaydınız,” dedi. Ece de aynı şeyi düşündüğünü söyledi. Birisi konuşurken diğerleri sessiz duruyor olsa bile başarıda onların emeği vardı.
---
@omurga
Yarışın sonunda hedefe birkaç santimetre kala duran robot, takım için beklenmedik bir üzüntüye yol açmıştı. Toprak “Bütün emek boşa gitti,” dediğinde Deniz ona çizim defterini gösterdi. İlk sayfada robot ilk virajı bile dönemiyordu. Son sayfada neredeyse tüm parkuru tamamlamıştı. “Bunlar boşa giden şeyler değil,” dedi. “Bu hafta bir sürü yeni yöntem öğrendik.” {yoldas:yalin|bir arkadaş}, başarısız denemeleri de sakladıkları için hangi noktada gelişmeleri gerektiğini görebileceklerini fark etti. Hatalarını gizlemek yerine onlardan öğrenmek, sonraki yarışa hazırlık olabilirdi.

Okul töreninde verilen takdir belgesini sınıf panosuna astılar. Deniz belgenin altına kendi adını tek başına yazmak istemedi. “Beşimizin ortak çalışması,” dedi. {yoldas:yalin|bir arkadaş} da ona hak verdi. Bütün ekip, görev listesi değişmeden önce Deniz'in görünmediğini hatırladı. Bu nedenle yeni gelen öğrencilere ilk hafta yalnız “Hangi takımdasın?” değil, “Neler yapmayı seversin?” diye sormayı kararlaştırdılar. Bazı çocukların katkısı hemen fark edilmeyebilirdi; iyi bir takım bu katkıları bulmak için zaman ayırırdı. {isaret:yildiz}
---
@omurga
Deniz ertesi dönem kodlama kulübüne ilk kez kendisi kayıt yaptırdı. Başta programlama dilini anlamakta zorlandı. {yoldas:yalin|bir arkadaş} ona birkaç temel komutu gösterdi; Deniz de {yoldas:yonelme|bir arkadaşa} çizimlerle plan yapmanın yollarını anlattı. İkisi küçük bir robot kolu tasarlamak için birlikte çalıştı. Bir gün kod doğru görünmesine rağmen robot kolu beklenmeyen yöne döndü. Deniz hemen sorunu çözmüş gibi davranmadı. “Önce ne yaptığını gözleyelim,” dedi. {yoldas:yalin|bir arkadaş} da “Bir deneme daha yapalım ama sonucunu kaydedelim,” diye karşılık verdi. İkisi birbirine gülümseyip defteri açtı. Artık acele etmekle beklemek arasında kavga etmiyorlardı; ne zaman hangi yöntemin gerekli olduğunu konuşuyorlardı.

Toprak, okul kütüphanesinde küçük bir “Yarış Günlüğü” rafı oluşturdu. Sınıflar katıldıkları yarışlarda hangi denemeleri yaptıklarını, hangi hatalardan ders çıkardıklarını bu rafta paylaşacaktı. Ece ilk deftere zaman tablolarını ekledi. Barış sunumda yaşadığı heyecanı ve arkadaşlarının kendisine nasıl yardımcı olduğunu yazdı. Deniz kendi çizimlerini koydu ama ilk sayfasına başka bir not düştü: “Yeni gelen birinin sessiz olması, fikri olmadığı anlamına gelmez.” Öğretmenleri notu okuyunca okulun yeni öğrenci karşılama etkinliğinde de kullanmayı önerdi.
---
@omurga
O yıl okulda farklı yeteneklerin tanıtıldığı bir gün düzenlendi. Kimi öğrenci müzik yaptı, kimi resim çizdi, kimi matematik bilmecesi çözdü. Deniz, parkur planlama masasının başında diğer çocuklara geometrik şekillerin robot hareketine nasıl yardımcı olduğunu anlattı. Bir öğrenci “Ben de çok iyi çizebilirim ama kodlama bilmiyorum,” dedi. Deniz ona “Ben de başta bilmiyordum,” diye cevap verdi. “İstersen birlikte öğreniriz.” O an yüzünde belirgin bir sevinç vardı. Önceleri yalnız yedek oyuncu olarak görülen çocuk, şimdi bir başkasının başlamasına yardım ediyordu.

Cenk Bey günün sonunda sınıfa “Yarışı kim kazandı?” diye şaka yaptı. Çocuklar birbirlerine baktı. {yoldas:yalin|bir arkadaş} gülerek “**Bu kez hepimiz**,” dedi. Öğretmen, bunun güzel bir cevap olduğunu ama bütün yarışların kazanılmadığını da hatırlattı. “Önemli olan yalnız sonucu değil, süreç boyunca birbirimize nasıl davrandığımızı da görmek,” dedi. Deniz, takdir belgesinden çok bu sözü saklamak istedi. Çünkü görünür olmanın en güzel yanı, başkasının da görünmesine yardım edebilmekti.
---
@omurga
Takım yeniden toplandığında herkes bir önceki denemesinde öğrendiği en değerli şeyi söyledi. Toprak “Yanıldığımda ölçmeye devam etmek,” Ece “Veriyi dikkatle karşılaştırmak,” Barış “Başkalarının emeğini doğru anlatmak,” {yoldas:yalin|bir arkadaş} “Dinlemek,” dedi. Sıra Deniz'e geldiğinde biraz düşündü. “Kendimi anlatmaktan çekinmemek,” dedi. Ardından ekledi: “Ve bir arkadaşım sessizse ona da söz hakkı vermek.” Beş arkadaş birbirine gülümsedi. Yeni yarışın parkuru henüz açıklanmamıştı, ama takımın en önemli ortak kuralı belliydi.
---
@omurga
- Dil: Ön yargı, beceri, katkı; ana fikir ve neden-sonuç ilişkileri. - Kavram: Ölçüm, plan, takım rolleri, hata analizi. - Değer: Kapsayıcılık, herkese söz hakkı, katkının fark edilmesi.
