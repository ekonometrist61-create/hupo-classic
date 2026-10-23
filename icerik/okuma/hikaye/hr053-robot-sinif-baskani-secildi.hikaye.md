---
baslik: "Robot Sınıf Başkanı Seçildi"
slug: "hr053-robot-sinif-baskani-secildi"
fis_kodu: "HR-053"
tur: mizah
konu: kural_demokrasi
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas, hayali]
deger_anahtarlari: [D6, D14]
yetiskin_uygun: false
tanitim: "Sınıf başkanlığı seçiminde birinci gelen aday bir robot. Kurallar kime hizmet ediyor?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [okul, bilim_teknoloji]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D14
  ogrenme_hedefleri:
    - {id: desibel_hr053, tur: lexeme, etiket: "desibel", yuva: hr053_desibel, islev: first_hint}
    - {id: temsilcilik_hr053, tur: lexeme, etiket: "temsilcilik", yuva: hr053_temsilcilik, islev: application}
    - {id: algilama_hr053, tur: lexeme, etiket: "algılamak", yuva: hr053_algilama, islev: application}
    - {id: kavram_hr053, tur: concept, etiket: "Kuralın amacı ve demokratik karar", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Başkanlık seçiminde birinci olan aday kimdi?", secenekler: [{id: A, metin: "Okul robotu MİKO"}, {id: B, metin: "Berke"}, {id: C, metin: "Aylin Hanım"}, {id: D, metin: "Arda"}], dogru: A, aciklama: "Seçimde birinci gelen aday, tekerlekli bir okul robotu olan MİKO'ydu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Elif'in itirazının nedeni neydi?", secenekler: [{id: A, metin: "MİKO kuralların amacına değil, yalnızca uyulup uyulmadığına bakıyordu"}, {id: B, metin: "Robot çok yavaştı"}, {id: C, metin: "Kurallar çok kısaydı"}, {id: D, metin: "Öğretmen izin vermemişti"}], dogru: A, aciklama: "Kuralın amacını gözetmeyen uygulama, düzen yerine sorun üretiyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 9, metin: "Hikâyeye göre bir teknolojinin yapabildiği her şeyi yapmasına neden izin verilmemelidir?", secenekler: [{id: A, metin: "Yapabilmek her zaman yapmak için yeterli sebep değildir"}, {id: B, metin: "Robot çok pahalıdır"}, {id: C, metin: "Öğretmen izin vermez"}, {id: D, metin: "Robot çalışmaz"}], dogru: A, aciklama: "Kişisel veriler gibi konularda yapılabilen bir şey, yapılmasının doğru olduğu anlamına gelmez."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, metin: "Metinde geçen desibel ne anlama gelir?", secenekler: [{id: A, metin: "Sesin şiddetini ölçen birim"}, {id: B, metin: "Bir kitap türü"}, {id: C, metin: "Bir oyun"}, {id: D, metin: "Bir tür kâğıt"}], dogru: A, aciklama: "Desibel, sesin şiddetini ölçmek için kullanılan birimdir."}
---
@omurga
Beşinci sınıfın başkanlık seçiminde birinci olan aday, insan bile değildi. Adı MİKO'ydu ve tekerlekli bir okul robotuydu. Üstelik konuşurken her cümlenin sonuna “Talimat tamamlandı,” demek gibi sinir bozucu bir alışkanlığı vardı.

MİKO aslında okulun teknoloji kulübünde geliştirilmiş bir yardım robotuydu. Masaya kâğıt götürür, kütüphaneye hangi kitabın iade edildiğini hatırlatır, okul panosundaki duyuruları seslendirirdi. Öğrenciler seçim kampanyası hazırlarken kulüp üyelerinden biri şaka olsun diye onun adını aday listesine yazmıştı. Robotun yöneticiler tarafından programlanan tanıtım konuşması da herkesi güldürmüştü: “Söz veriyorum: Koridorda koşan kimse olmayacak. Sınıfta kalem düşerse beş saniye içinde kaldırılacak. Teneffüs tam zamanında başlayacak ve bitecek. Talimat tamamlandı.”

Öğrenciler gülerek MİKO'ya oy verdi. Öğretmenleri Aylin Hanım, seçimin resmî sınıf {kelime:hr053_temsilcilik} için öğrenciler arasından yapılması gerektiğini, robotun oyununun yalnızca teknoloji etkinliği kapsamında sembolik olduğunu açıkladı. Sınıf bu ayrımı kabul etti ama MİKO'ya bir haftalığına “Deneme Başkanı” rolü vermek istedi. Böylece kurallar üzerine komik bir deney yapacaklardı. Gerçek kararlar yine öğrenciler ve öğretmenlerinde kalacaktı.
---
@omurga
İlk gün MİKO sınıf kapısında durup herkesin ayakkabısının bağcığını kontrol etti. {yoldas:ilgi|bir arkadaşın} bağcığı çözülmüştü. Robot, “Bağcık açık. Düzen bozuk. Ayakkabıyı kullanmak yasaktır,” diye duyuru yaptı. {yoldas:yalin|bir arkadaş} gülerek bağcığını bağladı. Ama MİKO'nun yeni kuralı nedeniyle kapıda kuyruk oluştu. İki dakika sonra zil çaldı; öğrencilerin yarısı içeri girememişti.

“Amacın düzeni sağlamak mı, sırayı uzatmak mı?” diye sordu {kahraman}.

MİKO cevap verdi: “**Amaç: Düzen. İşlem: Kontrol**. Talimat tamamlandı.”

{kahraman} ilk itirazını bu gün yaptı. Kuralların bir amacı vardı, ama her durumda körü körüne uygulanması işleri daha iyi yapmıyordu. MİKO ise amacın sonucunu ölçmüyordu; yalnızca kurala uyulup uyulmadığını sayıyordu.

İkinci gün robotun yeni kararı sınıfa kahkaha attırdı: “Sessiz çalışma zamanında gülmek yasaktır.” Çünkü bir öğrenci komik bir cümle okuyunca kahkaha atmıştı. Öğretmen, sessiz çalışma bölümünde başkalarını rahatsız etmemenin önemli olduğunu, bunun her türlü sevinci yasaklamak anlamına gelmediğini söyledi. MİKO “Gülüş {kelime:hr053_desibel} belirsiz,” diye cevap verdi. Öğrenciler desibelin ses düzeyini açıklamak için kullanılan bir birim olduğunu öğrendi ama sınıfta herkesin kahkahasını ölçmeye karar vermediler.
---
@omurga
Üçüncü gün büyük bir karışıklık çıktı. Okulda kitap takas şenliği vardı. Öğrenciler fazla kitaplarını getirip birbirleriyle değişecekti. MİKO, “Aynı türden iki kitabı olan öğrenci fazla kitap taşımaktadır,” diyerek takas masasına üç kez uyarı gönderdi. Onun gözünde iki kitap gereksiz tekrar demekti; şenlikte ise o tekrar paylaşımın ilk adımıydı.

{kahraman}, teknoloji kulübünden Arda ile konuştu. “Robotu değiştirmek zorundayız. Ama onu susturup her şeyi bizim yapmamız da deneyin amacı değil.” Arda, MİKO'nun karar verme kurallarını anlamayı önerdi. Kulüpte küçük bir dosya açtılar: Kural / amaç / durum / sonuç. Önce kuralın neyi koruduğunu, sonra hangi durumda işe yaradığını, son olarak da gerçekten nasıl bir sonuç verdiğini yazacaklardı.

MİKO'nun ilk görevi koridor güvenliğiydi. “Koridorda koşmak yasaktır” kuralı, düşme ve çarpışma riskini azaltmak için konmuştu. Ama robot, hızlı yürüyen öğretmeni de “koşuyor” diye rapor etmişti. Çünkü tekerleklerinin dönüş hızına göre yaptığı tahmin, insan hareketini doğru ayırt edemiyordu. Arda robotun {kelime:hr053_algilama} yeniden kontrol etti; öğretmen de güvenli davranışın yalnızca sayısal hızla açıklanamayacağını anlattı.
---
@omurga
Bir sonraki denemede MİKO öğrencilere su içmek için izin belgesi vermek istedi. {kahraman}, “Bu gerekli değil,” dedi. “Suyu içmek normal bir ihtiyaç.” Robot, “İzin belgesi gereksiz mi?” diye sordu. “Her yerde kural olmalı.” Arda, “Kural sayısı arttıkça düzen mutlaka artmaz,” dedi. Sonra masaya üç farklı oyun yazdı: satranç, saklambaç ve futbol. Üçünde de kurallar vardı ama hepsinin amacı ve hareket biçimi farklıydı. Birinin kuralını diğerine uygularsan oyun bozulurdu.

Cuma günü gerçek sınıf temsilcisi adayı olan {yoldas:yalin|bir arkadaş} bir öneride bulundu: “MİKO her şeyi takip etmek yerine bize sorun çözmeyi hatırlatsın. Böylece hepimiz karar sürecine katılırız.” Sınıfta kısa bir toplantı yapıldı. Öğrenciler sırayla konuştu, fikirlerini gerekçeleriyle anlattı. Aylin Hanım, bunun demokratik karar verme denemesi olduğunu açıkladı. Çok oy alan bir fikir seçilebilir, fakat seçilmeyen fikirlerin sahipleri de saygıyla dinlenmeliydi. Ayrıca her öneri okulun güvenlik ve eğitim kurallarına uygun olmalıydı.
---
@omurga
Oylamanın ilk sonucu sürprizdi. Çoğunluk, MİKO'nun bütün kurallarını kaldırmak istedi. {yoldas:yalin|bir arkadaş} bu önerinin de sorunlu olabileceğini söyledi. “Bazen kurala ihtiyacımız var,” dedi. “Mesela merdivenlerde itişmemek hepimizin güvenliği için gerekli.” {kahraman}, kuralları kaldırmak yerine yeniden düzenlemeyi önerdi. Sınıf ikinci kez oy kullandı. Yeni karar, robotun öğrencilere uyarı göndermeden önce durum hakkında soru sormasıydı.

MİKO yeni komutla ilk kez durup bekledi: “Bir öğrenci koridorda hızlı ilerliyor. Acil durum mu? Yardım mı gerekiyor? Güvenlik riski var mı?” Okul görevlisi gerekli bilgiyi verdiğinde robot gereksiz alarm vermedi. Bu küçük değişiklik öğrencileri sevindirdi. MİKO'nun daha akıllı olduğunu düşündüler. Arda, “Aslında daha iyi tasarlanmış bir kurallar dizisi kullanıyor,” dedi. “Robotun neyi nasıl yaptığını doğru anlamak önemli.”
---
@omurga
Deneme başkanlığının son günü Aylin Hanım sınıfa bir kâğıt dağıttı. Üzerinde “Bir kuralı gereksiz sanıyorsan önce amacını araştır,” yazıyordu. Öğrenciler en çok hangi kuralın işlerine yaradığını tartıştı. {kahraman}, teneffüs sürelerinin belli olmasının herkesin zamanı planlamasına yardım ettiğini söyledi. {yoldas:yalin|bir arkadaş}, ortak malzemeleri yerine bırakmanın sonraki öğrenciye saygı göstermek olduğunu anlattı. Arda, MİKO'yu programlarken yazdığı her komutun gerçek dünyada beklenmedik bir sonuç doğurabileceğini öğrendiğini söyledi.

MİKO sınıfın önüne geldi. “Seçim sonucu: Deneme başkanlığı tamamlandı,” dedi. “Yeni görev talebi: Öğrencilerin sorularını listelemek ve kararlarını kaydetmek.”

“Bunu başarabilir misin?” diye sordu {kahraman}.

“Önce amacını soracağım,” dedi robot.

Sınıf alkışladı. MİKO kısa bir süre sustu. “Alkış sesi düzenli mi?” diye sordu. Herkes kahkahaya boğuldu. Robot da programına eklenen yeni ifadeyi kullandı: “Bazen gülmek iyi bir işarettir. Talimat tamamlandı.”
---
@omurga
MİKO'nun ilk günlerde yaptığı küçük bir hata daha vardı. Okulun bahçesindeki geri dönüşüm kutularını düzenlemek için gönderildiğinde bütün kâğıtları “aynı boyda olma” kuralına göre ayırmıştı. Kullanılmış bir defter yaprağıyla henüz boş olan bir sayfayı aynı kutuya koymuştu. Arda, robotun “geri dönüşüm” sözcüğünü yalnızca şekle göre sınıflandırma sanmasını ilginç buldu. “Malzemenin türünü ve kullanım durumunu da anlaman gerek,” dedi. MİKO, “Yeni ölçüt öneriliyor,” diye cevap verdi. {kahraman}, bunun yalnız robotlar için değil insanlar için de geçerli olduğunu fark etti. Kimi zaman insanlar da birini dış görünüşüne göre hemen değerlendiriyordu. Oysa bir şeyi anlamak için daha fazla bilgi gerekebilirdi.
---
@omurga
Robotun düzen takıntısı kütüphanede de sorun çıkarmıştı. Kitapları yazar adına göre dizerken aynı soyadı taşıyan iki farklı yazarı tek kişi saymıştı. Kütüphane görevlisi, kitabın kimliğini belirlemek için başlık, yazar ve başka kayıt bilgilerine bakmak gerektiğini anlattı. Arda, MİKO'nun verileri eksik kullandığını kabul etti. Öğrenciler, bir liste hazırlanırken başlıkların neden açık yazılması gerektiğini gördü. {kahraman} “Bilgiyi eksik verirsek robotun yaptığı hata bizim hazırladığımız soruyla da ilgili,” dedi. Böylece sorumluluğu yalnız cihazın üzerine yıkmamayı öğrendiler.

Takas şenliğinde çıkan kargaşanın çözümü biraz daha uzun sürdü. Bazı öğrenciler kitaplarını getirmiş ama henüz değiştirmek istemiyordu. MİKO onları “kararsız” diye etiketledi. Ece buna sinirlendi. Kitabını başkasına vermeden önce son kez okuyup okumayacağına karar vermek istiyordu. {yoldas:yalin|bir arkadaş} “Karar vermek için zaman istemek kararsızlık değildir,” diye savundu onu. Robot için yeni bir seçenek eklendi: “Daha sonra karar verecek.” Ece buna sevindi; şenlik sonunda kitabını karşı sınıftan bir öğrenciyle değiştirdi. MİKO ise işlem fişine “Zaman tanındığında gönüllü katılım arttı” yazdı. {kahraman}, robotun dili biraz tuhaf olsa da bu gözlemin doğru olabileceğini düşündü.
---
@omurga
Okulun teknoloji öğretmeni deneyi ziyaret ettiğinde çocuklara küçük bir rol oyunu oynattı. Arda robot olacaktı; {kahraman} kullanıcı, {yoldas:yalin|bir arkadaş} de kural yazarı. İlk talimat çok basitti: “Masaya gelen bütün nesneleri kutuya koy.” {kahraman} masaya kalem, kâğıt, su şişesi ve bir arkadaşının doğum günü hediyesini getirdi. Arda hepsini kutuya koyunca {yoldas:yalin|bir arkadaş} durdu. Hediye ezilmişti; su şişesi de dökülebilirdi. Öğretmen, “Talimatı uygulamak her zaman iyi sonuç vermez,” dedi. “Ne tür nesneler olduğunu, nasıl taşınacağını ve hangi durumda durman gerektiğini de belirtmelisin.” Çocuklar birbirlerinin yerine geçince herkesin farklı bir sorumluluğu olduğunu gördü.

MİKO'yu sevmeyen öğrenciler de vardı. Eylül, robotun yaptığı her hareketin kaydedilmesinden rahatsız olmuştu. Arda, deneme için yalnız gerekli görev bilgilerini tutmaları gerektiğini, öğrencilerin kişisel verilerini gereksiz toplamamaları gerektiğini öğretmenle konuştu. Sınıf, MİKO'nun kişisel sohbetleri kaydetmeyeceği ve deneme sonunda etkinlik kayıtlarının gözden geçirileceği konusunda anlaştı. {kahraman} için bu, kurallardan daha önemli bir konuya dönüşmüştü: Bir teknolojinin yapabildiği her şeyi yapmasına izin vermek gerekli değildi. Bazen “Yapabilir ama yapmamalı” demek de doğru bir karardı.
---
@omurga
Hafta ortasında MİKO'ya okulun önünde küçük bir tanıtım konuşması yaptırıldı. Robot, “İlk hedefim sıfır hata,” dedi. {yoldas:yalin|bir arkadaş} söz alarak bunun gerçekçi olmadığını söyledi. “İnsanlar hata yapar, makineler de yapabilir. Önemli olan fark edince düzeltmek.” MİKO yeni cümleyi kaydetti. Ertesi gün sıra kâğıdını yanlış dağıttığında “Hata yok” demek yerine “Sıralama beklenenden farklı. Kontrol gerekli,” dedi. Öğrenciler bu yeni yanıtı alkışladı. Robot her şeyi bilen biri gibi görünmüyordu artık; neyi bilmediğini de söyleyebiliyordu.

{kahraman} bir gün Arda'ya, “Sence MİKO'nun başkan seçilmesi tamamen şaka mıydı?” diye sordu. Arda, “Başta evet,” dedi. “Ama sonra kendi kararlarımız hakkında düşünmemizi sağladı.” {kahraman}, çoğunluğun komik bulduğu bir fikrin her zaman iyi bir karar olmadığını da öğrenmişti. Başta herkesi eğlendiren robot, kurallarını yanlış uygulayınca rahatsız edici olmuştu. Sınıfın görevi yalnız oy vermek değil, sonuçları değerlendirmek ve gerektiğinde yeniden konuşmaktı. Aylin Hanım bunun demokratik yaşamın önemli bir yanı olduğunu söyledi: Katılım tek bir gün verilen oyla bitmez, ortak yaşamla sürer.
---
@omurga
Sınıf temsilciliği için yapılan gerçek seçimde {yoldas:yalin|bir arkadaş} ile {kahraman} yeniden aday oldu. {yoldas:yalin|bir arkadaş}, “Yapabileceğim şeyleri söyleyeceğim; her sorunu bir günde çözemem,” dedi. {kahraman}, öğrencilere düzenli aralıklarla fikir sorma sözü verdi. MİKO bu kez taraf tutmadı; oyları saymak için öğretmen gözetiminde yardımcı ekranı açtı, ama karar hakkının insanlarda olduğunu hatırlattı. Sonuçlar açıklandıktan sonra iki aday da birbirini kutladı. Kaybeden adayın önerileri tümden silinmedi; sınıf, yararlı bulduğu önerileri ortak plana ekledi. MİKO'nun en büyük dersi belki de buydu: Yarış bitince birlikte yaşamak devam ediyordu.

Cuma öğleden sonra öğrenciler deneyin en komik cümlelerini panoya astı. “Ayakkabı bağcığı çözülürse ayakkabı kullanılamaz”, “Gülüş desibeli belirsiz”, “İki kitap taşıyan öğrenci fazla kitap sahibidir” gibi cümleler herkesin yüzünü güldürdü. Yanlarına küçük açıklamalar eklendi: Kuralın amacı nedir? Bu kural hangi durumda işe yaramaz? Daha iyi nasıl düzenlenir? Panoya bakan alt sınıflardan bir öğrenci “Robotunuz çok komikmiş,” dedi. {kahraman}, “Komik olduğu doğru,” diye karşılık verdi. “Ama bize ciddiye almamız gereken şeyler de öğretti.”
---
@omurga
Deney bittikten birkaç hafta sonra okulda beklenmedik bir olay yaşandı. Kütüphanenin ödünç kayıt programı geçici olarak çalışmadı. Bir öğrenci bütün kitapların alınmasını yasaklamak gerektiğini söyledi. {kahraman}, MİKO'nun ilk günlerini hatırladı. “Sistem çalışmadığında tek seçenek her şeyi durdurmak değil,” dedi. Görevli öğretmen, geçici ve güvenli bir kayıt yöntemiyle sınırlı ödünç işlemlerini sürdürmenin mümkün olabileceğini açıkladı. Öğrenciler kitap adlarını dikkatle yazdı, sonra program açıldığında kayıtları karşılaştırdı. MİKO bu kez yalnızca hatırlatma görevinde kaldı. Hiç kimse ona sınıfı yönetmesini söylemedi. Ama herkes, yanlış bir kuralın ne kadar iyi niyetle yazılmış olursa olsun yeniden düşünülmesi gerektiğini artık biliyordu.
---
@omurga
MİKO artık kütüphane girişinde yalnızca kitapların geri dönüş tarihlerini hatırlatıyor, bir öğrencinin sorusunu anlamadığında “Açıklayabilir misiniz?” diyordu. Başlarda bu cümleyi duyunca herkes gülüyordu. Sonra sorunun yeniden anlatılmasının bazen daha iyi bir cevap bulmaya yardım ettiğini gördüler. {kahraman}, okul panosuna “Anlaşılmayan sorular da değerlidir” yazdı. Ece bunun yanına bir çizim yaptı: MİKO, elinde büyüteçle bir soru işaretini inceliyordu. Arda çizime bakıp gülümsedi. “Robot en akıllı görünmeye çalışmıyor artık,” dedi. “Önce neyi anlaması gerektiğini buluyor.”

Yıl sonunda teknoloji kulübü çalışmalarını sergilediğinde başka okullardan öğrenciler MİKO'yu görmek için sıraya girdi. Bir ziyaretçi, “Hiç hata yapmıyor mu?” diye sordu. Robotun ekranında önce kısa bir hesaplama işareti belirdi. Sonra şu cevap duyuldu: “Hata olasılığı vardır. Güvenli kullanım için insan denetimi gereklidir.” Arda bu cümleyi duyunca gururlandı. Çünkü en güzel geliştirmelerinin robotu kusursuz göstermek değil, sınırlarını açık anlatmak olduğunu biliyordu.
---
@omurga
{kahraman} sergi defterine son notunu yazdı: “Başkanlık yalnızca başkalarına kural söylemek değildir. İnsanları dinlemek, sorumluluk almak, gerektiğinde fikrini değiştirmek ve birlikte karar vermektir.” MİKO'nun tekerlekleri sessizce döndü. “Yeni görev?” diye sordu. {kahraman}, “Bugünlük yeter,” dedi. Robot kısa bir duraklamadan sonra cevap verdi: “Dinlenme de planın parçasıdır. Talimat tamamlandı.” Bu kez sınıf kahkahayı serbest bıraktı. {isaret:kitap}

Bir sonraki yıl okula gelen yeni öğrenciler sınıf panosundaki robot fotoğraflarını görünce şaşırdı. “Gerçekten robot başkanınız mı vardı?” diye sordular. {kahraman}, “Bir haftalık deneme başkanımızdı,” diye düzeltti. “Gerçek başkanı biz seçtik.” Sonra seçimin nasıl başladığını ve neden farklı bir hâl aldığını anlattı. Yeni öğrencilerden biri, “O zaman MİKO'ya yeniden oy versek olur mu?” diye şaka yaptı. {yoldas:yalin|bir arkadaş} güldü. “İsterseniz onu yine etkinlikte kullanabiliriz. Ama önce neyi öğrenmek istediğimize karar verelim.”
---
@omurga
MİKO, sınıftaki kalabalığı görünce eski selamlama cümlesini söyledi: “Düzen kontrolü başlıyor.” Herkes bir an durdu. Robot ardından yeni cümlesini ekledi: “İlk sorum şu: Bugün size nasıl yardımcı olabilirim?” {kahraman} bu değişimi duyunca yüzü aydınlandı. Bir sınıfın öğrenmesi de bazen bir robotun yazılımı gibi olurdu. Eski alışkanlıkları bulur, işe yaramayanları değiştirir, iyi olanları korurdun. Yalnız bunu yaparken karşındaki insanların düşüncelerini duymayı unutmamalıydın.

O gün MİKO'nun ekranında küçük bir yıldız işareti belirdi. Arda onun ne anlama geldiğini sorduğunda robot “Yeni kural: Soru sormak serbesttir,” dedi. Çocuklar bunu beğendi.
---
@omurga
- Kavramlar: Temsil, seçim, kuralın amacı, algılama hatası, algoritma. - Dil: Gerçek/mecaz anlam, ifade niyeti; “kuralı harfiyen uygulamak” sözünün anlamı. - Değer: Demokratik katılım, farklı fikre saygı, kuralları gerekçelendirme.
