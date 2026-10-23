---
baslik: "Kayıp Arşivin Yedi Tanığı"
slug: "hr101-kayip-arsivin-yedi-tanigi"
fis_kodu: "HR-101"
tur: gizem
konu: kanit_tanik_belirsizlik
sinif_alt: 8
sinif_ust: 8
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Bir fotoğrafın arkasındaki tarih doğru mu? Yedi tanık yedi ayrı şey anlatınca Elif ve Bora kesin cevabı değil, kanıtın sınırını öğrenir."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 8
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [kesif]
  ders_baglantisi: [turkce, sosyal]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: celiski_hr101, tur: lexeme, etiket: "çelişki", yuva: hr101_celiski, islev: first_hint}
    - {id: tanik_hr101, tur: lexeme, etiket: "tanık", yuva: hr101_tanik, islev: application}
    - {id: deyim_hr101, tur: idiom, etiket: "Başını tutmak", yuva: hr101_basini, islev: application}
    - {id: kanit_hr101, tur: lexeme, etiket: "kanıt", yuva: hr101_kanit, islev: application}
    - {id: belirsiz_hr101, tur: lexeme, etiket: "belirsiz", yuva: hr101_belirsiz, islev: transfer}
    - {id: kavram_hr101, tur: concept, etiket: "Gözlem, duyum ve çıkarım ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (8. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Sergideki ilk fotoğrafın etiketinde hangi tarih yazıyordu?", secenekler: [{id: A, metin: "12 Mayıs 1984"}, {id: B, metin: "12 Mayıs 1974"}, {id: C, metin: "21 Mayıs 1984"}, {id: D, metin: "Tarih yazmıyordu"}], dogru: A, aciklama: "Fotoğraflardan biri 12 Mayıs 1984 tarihiyle etiketlenmişti."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 5, metin: "Orhan Bey'in uyarısına göre fotoğrafın arkasındaki tarih neyi gösterebilir?", secenekler: [{id: A, metin: "Kesin olarak çekim tarihini"}, {id: B, metin: "Kopyalama ya da basım tarihini"}, {id: C, metin: "Fotoğrafçının doğum tarihini"}, {id: D, metin: "Köprünün yapım tarihini"}], dogru: B, aciklama: "Arka yazı, daha sonra basılan kopyanın üzerinde olabilir; bu yüzden çekim tarihini kesin olarak göstermeyebilir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 12, metin: "Tanıkların anlatıları farklı çıkınca Bora ne önerdi?", secenekler: [{id: A, metin: "Tanıkların hepsini sergiden çıkarmayı"}, {id: B, metin: "Her anlatıyı, hangi bilgiye dayandığını gösteren etiketlerle sunmayı"}, {id: C, metin: "Yalnızca ilk tanığı dinlemeyi"}, {id: D, metin: "Fotoğrafın arkasını tamamen silmeyi"}], dogru: B, aciklama: "Bora, gözlem, duyum, çıkarım ve tarih belirsiz etiketleriyle her anlatının hangi bilgiye dayandığını göstermeyi önerdi."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 9, metin: "Metinde “çelişki” sözcüğü neyi anlatır?", secenekler: [{id: A, metin: "Birbirini tutmayan iki bilgi ya da anlatı"}, {id: B, metin: "Bir fotoğrafın kopyası"}, {id: C, metin: "Sergi için yapılan bir afiş"}, {id: D, metin: "Bir köprünün adı"}], dogru: A, aciklama: "Çelişki, birbirini tutmayan iki anlatının ya da bilginin varlığını ifade eder."}
  - {id: s5, beceri: degerlendirme, dayanak_sayfa: 16, metin: "“Bir kanıt bazen tam tarihi vermez” sözü neyi anlatır?", secenekler: [{id: A, metin: "Bir kanıt tam cevabı vermese de bazı ihtimalleri eleyebilir"}, {id: B, metin: "Her kanıt kesin tarihi gösterir"}, {id: C, metin: "Kanıt yalnızca yazılı belgelerden oluşur"}, {id: D, metin: "Kanıtlar araştırmada önemsizdir"}], dogru: A, aciklama: "Kanıt tek başına her soruyu yanıtlamaz, ama bazı olası açıklamaları eleyerek araştırmayı ilerletir."}
deyim_cumleleri:
  hr101_basini: "{yoldas:yalin|bir arkadaş} bu cevapları okuyunca başını tuttu."
---
@omurga
Şehir Belleği Sergisi'ne üç gün kalmıştı. Belediye kütüphanesinin üst katındaki küçük salonda otuz iki fotoğraf asılıydı. Fotoğraflardan biri, 12 Mayıs 1984 tarihiyle etiketlenmişti. Eski bir taş köprünün üzerinde bayraklar taşıyan insanlar görünüyordu; köprünün girişinde geçici bir sahne kurulmuş, sahnenin önünde kalabalık birikmişti. Alt yazı, “Köprünün açılış töreni” diyordu.

Sekizinci sınıf öğrencisi {kahraman}, fotoğrafın sağ köşesindeki dükkâna dikkat etti. Dükkânın tabelasında “Özlem Kasetçilik” yazıyordu. {kahraman:ilgi} dedesi kasetçilik dükkânının daha sonra açıldığını anlatırdı. Fakat eski hikâyelere güvenip sergiyi değiştirmek istemiyordu. Depodaki dosyaları karıştırdı ve başka bir fotoğraf buldu. Aynı köprü, aynı dükkân, ama farklı bir tören. O fotoğrafın arkasında da 1984 yazıyordu.

İki fotoğraf birbirini doğrular gibi görünüyordu. Yine de ayrıntılar uyuşmuyordu. İlk fotoğrafta dükkânın önünde duran çınar ağacının dalları çok daha genişti. İkinci fotoğrafta köprü korkuluğunda yeni bir onarım çizgisi vardı. {kahraman}, fotoğraflardan hangisinin önce çekildiğini düşünürken sınıf arkadaşı {yoldas:yalin|bir arkadaş} içeri girdi. “Hâlâ şunu mu inceliyorsun?” diye sordu. “Sergi yarın kurulacak. Tarihi fotoğrafın üstünde yazıyor işte.”
---
@omurga
{kahraman} kâğıdın arka yüzünü çevirdi. Mavi mürekkep hafifçe dağılmıştı. Son iki rakamın çevresinde soluk bir silinti izi vardı. “**Bir fotoğrafın arkasına tarih yazılması, o tarihin doğru olduğu anlamına gelmez**,” dedi. “Belki de sonradan biri yanlış yazdı.”

Kütüphane görevlisi Suna Hanım, çocukların tartışmasını duydu. “Bu fotoğrafları bize şehir arşivinden değil, farklı ailelerden gelen kutulardan derledik,” dedi. “Bazılarının tarihi kesin, bazılarınınki anlatılan hatıralara dayanıyor.” {kahraman} etiketin yanına küçük bir soru işareti koydu. “O zaman açılış günü olduğunu söyleyemeyiz,” dedi. “Önce kaynağı anlamamız gerek.”

Suna Hanım onları uyardı: “Eski fotoğrafları kimseye göstermeden kopyalamayın. Ailelerden alınan izinler sergide kullanılmaları için. Dijital paylaşım ayrı bir konu.” Çocuklar notları yalnızca izin verilen arşiv kayıtları üzerinden tutmayı kabul etti. Gizem sadece yanlış tarihi bulmak değildi; başkasının geçmişini güvenle koruyarak araştırmak da gerekiyordu.
---
@omurga
{kahraman:ilgi} araştırması bir öğretmen görevine dönüştü. Sosyal bilgiler öğretmeni, köprü hakkında bilgi sahibi olabilecek yedi kişiyle görüşme yapılabileceğini söyledi. Ancak tanıkların her birinin hatırladıkları, deneyimleri ve gördükleri aynı olmayacaktı. Önce onlardan izin alacak, görüşmelerin amacını anlatacak, istemeyenlerin sesini kaydetmeyeceklerdi. Hiç kimse sırf hatırlayamadığı için yanlış söylemiş sayılmayacaktı.

Birinci tanık eski belediye çalışanı Cemal Bey'di. Köprüde 1984'te bir açılış töreni yapıldığını hatırlıyordu. İkinci tanık, köprünün yakınında büyümüş Emine Hanım, aynı yıl yalnızca onarım yapıldığını söyledi. Üçüncü tanık eski fotoğrafçı Orhan Bey fotoğrafın hangi makineyle çekildiğini tahmin edebiliyordu ama yılından emin değildi. Dördüncü tanık bir müzik topluluğunda çalmış Aysun Hanım, törende duyduğu şarkıyı hatırlıyordu. Beşinci tanık dükkân sahibi Murat Bey, kasetçiliğin tabelasının babasının döneminde yenilendiğini anlattı. Altıncı tanık köprüden her gün geçen Şermin Hanım, tören gününde yağmur yağdığını söyledi. Yedinci tanık ise {kahraman:ilgi} dedesi Ziya Bey'di; kalabalığı hatırlıyor, ama köprüden başka bir nedenle de geçtiğini söylüyordu.
---
@omurga
[[deyim:hr101_basini]] “Yedi {kelime:hr101_tanik} var, yedi ayrı olay anlatıyorlar.” {kahraman} tabloya baktı. “Belki de yedi kişi yedi farklı yerden aynı olaya bakıyor.”

Bir harita çizdiler. Cemal Bey köprünün şehir merkezine bakan ucundaydı. Emine Hanım karşı sokaktaki balkonundan izliyordu. Orhan Bey sahnenin önünde, Aysun Hanım sahnenin arkasındaydı. Murat Bey dükkânda çalışırken sesleri duyuyordu. Şermin Hanım köprüyü geçiyordu. Ziya Bey de fotoğrafın çekildiği sırada kalabalığın gerisinde yürüyordu. Kimin hangi şeyi görebileceğini işaretleyince bazı çelişkiler hafifledi.

“Yine de yıl aynı olmayabilir,” dedi {kahraman}. “Bir kişi bir töreni, başka biri başka töreni hatırlıyor olabilir. İnsanlar benzer olayları zamanla birbirine karıştırabilir.”

{yoldas:yalin|bir arkadaş} ilk defa sabırsızlığını bir kenara bıraktı. “O zaman bütün hatıraları tarih çizelgesine yazalım,” dedi. “Kimseyi yalancı çıkarmadan.”
---
@omurga
Eski fotoğrafçı Orhan Bey, onları dükkânının arka odasında karşıladı. Raflarda tozlanmış makineler, objektifler ve kutular vardı. Çocuklar eski makinelerden birini görünce şaşırdı. Orhan Bey, “Makinenin modeli fotoğrafın çekildiği tarihi her zaman göstermez,” dedi. “Aynı makineyle yıllarca çekim yapılabilir.”

{kahraman}, arşivdeki kâğıdın kenarındaki kesme izlerini anlattı. Orhan Bey fotoğrafı eline almadı; kendisine gösterilen korumalı kopyaya baktı. “Bu fotoğraf bir defa çoğaltılmış olabilir,” dedi. “Arka yazısı da orijinalin değil, daha sonra basılan kopyanın üzerindedir.”

“Yani arka yüzdeki 1984 tarihi, çekim tarihini değil kopyalama tarihini mi gösterir?” diye sordu {yoldas:yalin|bir arkadaş}.

“Olabilir,” dedi Orhan Bey. “Ama bunu tahmin olarak yazın. Kesin bilgi değil.”

Orhan Bey, aynı günün diğer kareleri bulunursa fotoğrafın sırasından, ışığından ve törenin ilerleyişinden ipuçları çıkabileceğini anlattı. {kahraman} dosyada üç benzer fotoğraf daha olduğunu hatırladı. Bunların birinde sahne boştu, diğerinde insanlar kürsünün etrafında toplanmıştı, üçüncüsünde herkes dağılmaya başlamıştı. Fotoğrafların çekim sırası yaklaşık belirlenebiliyordu ama hiçbirinin tarihi güvenilir biçimde yazılmamıştı.
---
@omurga
{kahraman}, “Bazen görüntü çok şey anlatıyor, ama tarihini söylemiyor,” dedi. Orhan Bey gülümsedi. “Fotoğraf bir pencere gibidir,” dedi. “Pencerenin içinden gördüğün manzarayı anlatabilir; fakat pencerenin dışında kalanları unutursan yanlış hikâye kurarsın.”

Dönüş yolunda {yoldas:yalin|bir arkadaş} bu sözü defterine yazdı. Orhan Bey konuşurken penceredeki ışık bile değişmişti. Sabah fotoğrafı ile öğleden sonra fotoğrafının gölgeleri farklı olabilirdi. {kahraman}, bir an önce kesin sonuç çıkarmak istediğini fark etti; fakat artık tahminleri kanıtlardan ayırma konusunda daha dikkatliydi.
---
@omurga
Murat Bey'le görüşmek için eski dükkânın bulunduğu sokağa gittiler. Kasetçiliğin yerinde şimdi küçük bir kitapçı vardı. Murat Bey emekli olmuştu ama kitapçının üst katında arada sırada eski plakları onarıyordu. Çocukları görünce kahvesini bir kenara bıraktı.

{kahraman} fotoğraftaki tabelayı gösterdi. “Bu yazı 1984 yılında burada olabilir miydi?” diye sordu. Murat Bey yüzünü buruşturdu. “İsim aynıydı ama tabelamız değişti,” dedi. “Babam ilk tabelayı elle boyamıştı. Fotoğraftaki büyük harfli levhayı sonradan yaptırdık.”

“Ne zaman?”

Murat Bey bir süre düşündü. “Kesin hatırlamıyorum. Kardeşim üniversiteyi kazandığı yıl olabilir.” Sonra durdu. “Ama o yılın hangisi olduğunu hemen söyleyemem. Eski vergi belgeleri ya da dükkân fotoğrafları daha iyi kaynak olur.”

{yoldas:yalin|bir arkadaş} bu kadar dikkatli cevaba şaşırmıştı. Büyükler genelde bir tarih sorulduğunda hemen cevap vermeye çalışıyordu. Murat Bey ise bilmediğini söylemekten rahatsız görünmüyordu. Dükkânın eski albümünden iki fotoğraf getirdi. İlkinde tabelanın yalnızca küçük harflerle yazıldığı görülüyordu. İkincisinde köprüdeki fotoğraftaki büyük tabelanın aynısı vardı. Albümün kenarında bir düğün davetiyesi duruyordu; üzerinde yıl yazılıydı. Çocuklar tarihten bir sınır çıkarabildi ama köprü fotoğrafının tam yılını belirleyemedi.
---
@omurga
“Yani büyük tabela en erken bu tarihten sonra asılmış olabilir,” dedi {kahraman}. “Ama ne kadar sonra olduğunu bilmiyoruz.”

Murat Bey başını salladı. “Tam da öyle.”

Eve dönerken {kahraman}, kalabalığın üzerindeki bayrakları düşündü. Belki köprü açılışı değil, başka bir kutlamaydı. Fotoğrafta görülen insanlar geçmişin içine sıkışmış gibiydi; oysa her biri o gün farklı bir nedenle orada bulunmuş olabilirdi.
---
@omurga
Şermin Hanım'ın anlatısı araştırmayı farklı bir yöne çevirdi. Kendisi o gün pazar çantasıyla köprüden geçtiğini, ayakkabılarının ıslandığını ve şemsiyesini açtığını hatırlıyordu. {kahraman} bunu fotoğrafa bakarak kontrol etti. Görüntüde kimsenin elinde şemsiye yoktu, yerler de kuru görünüyordu.

{yoldas:yalin|bir arkadaş} heyecanlandı. “Demek ki Şermin Hanım yanlış hatırlıyor!” dedi.

{kahraman} hemen karşı çıkmadı, ama deftere “{kelime:hr101_celiski}” yazdı. Şermin Hanım'a tekrar gidince anlatısını dikkatle dinledi. Kadın, “Yağmuru çok iyi hatırlıyorum,” dedi. “Çünkü yeni aldığım ayakkabılar zarar görmüştü. Ama kalabalığın olduğu güne mi, ertesi haftaya mı rastladı, emin değilim.”

Bu düzeltme {kahraman:ilgi} hoşuna gitti. Bir insanın anısı, ayrıntı bakımından canlı olsa bile tarihle yanlış eşleşebilirdi. {yoldas:yalin|bir arkadaş} da bunu kabul etti. “Belki yağmur doğru, gün yanlış,” dedi.

Hava durumu kayıtlarına bakma fikri akıllarına geldi; fakat eski yılların günlük kayıtlarına kolay ulaşamıyorlardı. Öğretmenleriyle konuşup kamuya açık güvenilir arşiv kaynaklarını araştırdılar. Bulabildikleri kayıtlar, o dönemde birkaç yağışlı gün olduğunu gösteriyordu ama hangi törenin hangi güne denk geldiğini ispatlamıyordu. Sonucu zorlamadılar.
---
@omurga
{kahraman} bir zamanlar tarih yazmayı olayları sıralamak sanırdı. Şimdi tarih yazmanın, neyin bilindiği kadar neyin bilinmediğini de dürüstçe belirtmek olduğunu öğreniyordu. Şermin Hanım'a teşekkür edip notun yanına “Hangi güne ait olduğu belirsiz anı” yazdılar. Yargı vermemek, araştırmayı bitirmek anlamına gelmiyordu; daha iyi bir soruyla devam etmekti.
---
@omurga
Yedinci tanık Ziya Bey, {kahraman:ilgi} en çok soru sormakta zorlandığı kişiydi. Dedesinin anlattığı hikâyeleri küçük yaştan beri dinlerdi. Köprünün açılışında tanınmış bir müzisyenin sahneye çıktığını, herkesin şarkılar söylediğini, sonra kalabalığın komşu mahalleye doğru yürüdüğünü hatırlardı. {kahraman} onun bu anılarıyla büyümüştü. Şimdi bu hikâyenin bir bölümünün başka bir güne ait olabileceğini düşünmek bile tuhaf geliyordu.

Ziya Bey görüşme isteğini duyunca eski defterini çıkardı. “Ben de yanılıyor olabilirim,” dedi. “İnsan yıllar önce gördüğü sahneleri bazen bir film gibi birleştiriyor.” {kahraman}, “Bize kesin tarih söylemek zorunda değilsin dede,” diye cevap verdi. “Yalnızca gördüğün şeyi ve neye dayanarak hatırladığını anlatmanı istiyorum.”

Ziya Bey köprüye ilk kez küçük kardeşiyle yürüdüğü günü anlattı. Karşıdan gelen insanlar bir kutlama için hazırlanıyordu. Ancak yıllar sonra anlatılarında kardeşinin üniversiteye gittiği yılı da aynı güne yerleştirdiğini fark etti. {kahraman} defterdeki isimleri karşılaştırınca bu iki olay arasında birkaç yıl bulunduğunu gördü. “Belki iki ayrı kutlamayı birleştirmişim,” dedi Ziya Bey. “Ama o köprünün üstünde birlikte yürüdüğümüzü hatırlıyorum.”
---
@omurga
{kahraman}, “Bu anının değeri değişmiyor,” dedi. “Sadece tarihi konusunda daha dikkatli olacağız.” Dede torununun yüzüne baktı. Eskiden anlattığı her şeyin büyülenerek dinlendiğini bilirdi; şimdi ona soru soran, kanıt arayan bir genç vardı karşısında. Bu durumdan rahatsız olmadı. “Senin işin daha zor,” dedi. “Biz hatırlıyoruz, siz bunları başkalarının da öğrenebileceği bir biçime getirmeye çalışıyorsunuz.”

{kahraman}, dede ile yaptığı görüşmede uzun bir sessizlik de kaydetti. Ziya Bey bir noktada konuşmayı bırakmış, pencereden eski köprüye bakmıştı. {kahraman} hemen yeni bir soru sormadı. Çünkü bazen bir hatıranın söylenmemiş kısmına yer açmak gerekiyordu. Görüşmenin sonunda dedesi, “Yazdıklarında benim adım geçmesin,” dedi. “Sözümden izin verdiğim kadarını kullan.” {kahraman} bunu kabul etti. Tanık olmanın, insanın bütün hayatını herkese açmak anlamına gelmediğini yeniden gördü.

Ertesi sabah {yoldas:yonelme|bir arkadaşa} defterini gösterdi. “Dedemin anlattığı her şey ya doğru ya yanlış diye ikiye ayrılamıyor,” dedi. “Bazı parçaları doğrulayabiliyoruz; bazıları özel anı, bazıları {kelime:hr101_belirsiz}.” {yoldas:yalin|bir arkadaş} “O zaman her tanığın anlatısını küçük etiketlerle gösterelim,” diye önerdi: gözlem, duyum, çıkarım, tarih belirsiz. Böylece bir kişinin tüm sözünü reddetmeden, hangi cümlenin neye dayandığını gösterebileceklerdi.
---
@omurga
Aysun Hanım, fotoğraftaki toplanmayı bir konser olarak hatırlıyordu. Yıllar önce yerel müzik topluluğunda çalışmış, köprü üzerinde kurulan küçük sahnelerden birinde şarkı söylemişti. {kahraman} ve {yoldas:yalin|bir arkadaş} onu kültür merkezinde buldu. Kadın bir etkinlik afişi saklamıştı ama afiş nemden zarar görmüş, tarih kısmı okunmaz hâle gelmişti. Yine de üstünde “Köprü Şenliği” yazıyordu.

“İşte!” dedi {yoldas:yalin|bir arkadaş}. “Demek açılış değil şenlikmiş.”

Aysun Hanım başını iki yana salladı. “Bir şenlik düzenlenmiş olması, fotoğraftaki günün o gün olduğunu ispatlamaz,” dedi. “Yılda birkaç etkinlik yapılıyordu.”

{kahraman} afişteki küçük logoya baktı. Bugün kullanılmayan bir dernek adı yazıyordu. Bu derneğin kurulduğu yıl biliniyorsa, afişin daha önce hazırlanmış olamayacağını düşündü. Ancak yine aynı sorun vardı: Afişin fotoğrafla bağlantısı kanıtlanmamıştı.

Aysun Hanım sahne yerini tarif etti. “Biz köprünün hemen çıkışında, bahçeye yakın taraftaydık. Fotoğraftaki sahne girişte duruyor.” {yoldas:yalin|bir arkadaş} bu ayrımı krokiye işaretledi. İki sahne arasındaki fark yeni bir ihtimal doğurdu: Fotoğraflar birbirine benzeyen iki farklı etkinlikten olabilirdi. Suna Hanım'a döndüklerinde ekip artık “Tek bir günün bütün kareleri” varsayımını yeniden sorguluyordu.
---
@omurga
Öğretmenleri bu yaklaşımı destekledi. “Bir araştırmada yeni bir {kelime:hr101_kanit} eski varsayımı zayıflatabilir,” dedi. “Bundan korkmayın.” {kahraman} kendisini kaybolmuş gibi hissetti. İki gün önce yalnızca yanlış bir tarihi düzeltecekti; şimdi sergi panosundaki başlığın kendisi sorgulanıyordu. Fakat gerçeğin kolay olması gerekmiyordu.

Arşiv bilgisayarında fotoğrafları yan yana dizdiler. Birinde köprü üzerindeki sahne kuzey tarafta, diğerinde güney taraftaydı. Aynı ağacın farklı yıllardaki büyüklüğü de dikkat çekiyordu. İki kareyi aynı güne ait kabul etmek için yeterli kanıt yoktu. {kahraman} not defterine kalın bir çizgi çekti. Üstüne “İki olası etkinlik” yazdı. Araştırmanın en önemli ilerlemesi belki de kesin tarih bulmak değil, yanlış bir birleştirmeyi ayırmaktı.
---
@omurga
Suna Hanım ertesi gün şehrin eski gazetelerinin dijitalleştirilmiş nüshalarına erişebilecekleri bir bağlantı buldu. {kahraman} arama kutusuna köprünün adını yazdı; onlarca haber çıktı. Gazetelerin bir kısmı eski yazı karakterleriyle taranmıştı ve arama sonuçları hatalıydı. {yoldas:yalin|bir arkadaş}, “Program bu kelimeyi okuyamıyor,” dedi. Sayfaları tek tek açmaya başladılar. Başlıkların büyüklüğüne, tarih satırlarına ve aynı sayfada yer alan ilanlara baktılar.

Bir gazetenin yerel haberler bölümünde “Köprü onarımı tamamlandı” cümlesi vardı. Haber, açılıştan değil, yıllar sonra yapılan güvenlik çalışmalarından söz ediyordu. Fotoğraflardan birindeki yeni korkuluk izi bu haberle uyumlu görünüyordu. Ancak gazete sayfasındaki küçük fotoğrafın köprüdeki kalabalıkla ilgili olmadığı anlaşıldı. Yine de önemli bir zaman sınırı yakalamışlardı: Onarım sonrası görülen korkuluk, onarımdan önce çekilmiş bir karede bulunamazdı.

{yoldas:yalin|bir arkadaş} “Demek şu fotoğraf kesin daha yeni,” dedi. {kahraman} duraksadı. “Eğer gördüğümüz çizgi gerçekten o onarımla yapıldıysa.” Suna Hanım onları, varsayımı doğrulayacak teknik kayda yönlendirdi. Belediye arşivindeki onarım planını incelemek için izin istediler. Kayıtta korkuluğun ilgili bölümüne hangi yıl müdahale edildiği yazılıydı. Böylece fotoğrafın en erken çekilebileceği döneme ilişkin daha güvenilir bir sınır elde ettiler.
---
@omurga
Öğretmenleri, “Bir kanıt bazen tam tarihi vermez,” dedi. “Ama bazı ihtimalleri eler.” Çocuklar bunu uzun süre düşündü. Eskiden buldukları her belgenin soruya bir cümleyle cevap vermesini beklerlerdi. Şimdi bir belgenin ancak başka belgelerle birlikte anlam kazandığını görüyorlardı. {isaret:anahtar}

{yoldas:yalin|bir arkadaş} gazetelerde bir başka etkinlik buldu. Köprü onarımından sonraki yıllarda, kentin kuruluş yıl dönümüne ilişkin yürüyüşler yapılmıştı. Fotoğraftaki bayraklar böyle bir töreni çağrıştırıyordu. Fakat bu kez de “çağrıştırıyor” sözcüğünü özellikle kullandılar. Gazete haberi kesin bağlantı kurmadan yalnızca olası bir açıklama sağlıyordu.

{kahraman} buldukları kayıtları bir dosyada topladı. Her sayfanın üstüne kaynağı, hangi tarihte erişildiğini ve hangi iddiayı desteklediğini yazdı. İnternetten alınmış görüntüleri izinsiz yayımlamadı; arşivde gösterilebilecek malzemeler için gerekli izinleri kontrol etti. Kayıt düzeni, gizemin çözümünden daha sıkıcı görünebilirdi ama bir sonraki araştırmacının aynı yolu yeniden izlemesini sağlayacaktı.
---
@omurga
Suna Hanım sergi için son kontrole başladığında {kahraman} ve {yoldas:yalin|bir arkadaş} henüz kesin tarihi bulamamıştı. Panodaki etiket güncellenmezse yanlış bilgi yayımlanacaktı. Suna Hanım, “Bazen eksik bilgiyle karar vermemiz gerekir,” dedi. “Ama eksikliği saklamayız.”

{kahraman} yeni etiket için iki öneri yazdı. Birincisi “1984 köprü açılışı” ifadesinin yanına soru işareti koymaktı. İkincisi, “Köprüdeki tören; kesin tarih araştırılıyor” demekti. {yoldas:yalin|bir arkadaş} ikinci seçeneği daha dürüst buldu. Ancak törenin kendisinin de ne olduğundan emin değillerdi. Bu kez daha dikkatli bir başlık buldular: Köprü Üzerinde Bir Toplanma — Tarihi ve Nedeni Araştırılıyor.

Öğretmenleri, tanıkların anlatılarını yan yana koyan bir bilgi kartı hazırlamalarını önerdi. Bir kartta fotoğrafın hangi kısmından ne gördükleri, diğerinde görüşülen kişilerin hangi noktada durduğu gösterilecekti. Şahısların özel bilgileri yayımlanmayacak, izin verilen alıntılar kullanılacaktı. Tanık anlatıları birincil deneyim olarak değer taşıyacaktı ama tek başına kesin tarih kanıtı sayılmayacaktı.
---
@omurga
{yoldas:yalin|bir arkadaş} kartları yerleştirirken bir ayrıntı fark etti. Köprünün üstündeki büyük pankartta yazı vardı; ama görüntünün düşük çözünürlüğü nedeniyle okunmuyordu. Dijital büyütme denemesinde harflerin kenarları bozulmuştu. Bir arkadaşları yapay zekâ ile yazıyı “tamamlamayı” teklif etti. {kahraman} bu öneriyi reddetti. “Program tahmin ettiği harfleri gerçekmiş gibi gösterebilir,” dedi. “O zaman kanıt üretmiş olmayız.”

Suna Hanım, daha yüksek çözünürlüklü orijinal kopyayı bulmayı deneyeceğini söyledi. {kahraman} araştırma defterinin son sayfasına şunu yazdı: Görüntüyü iyileştirmek, görüntüde bulunmayan bilgiyi icat etmek değildir.
---
@omurga
Sergi afişleri basılmadan bir gün önce belediyenin tanıtım biriminden bir görevli geldi. Görevli, ziyaretçilerin kesin tarihler ve güçlü başlıklar görmek istediğini söyledi. “Köprü Açılışı, 1984” ifadesinin daha dikkat çekici olduğunu savundu. {kahraman}, fotoğraftaki ayrıntıları tek tek anlattı. Görevli önce sabırsızlandı. “Çocukların araştırmasını çok önemsiyoruz, ama afişte bu kadar soru işareti hoş durmaz,” dedi.

{yoldas:yalin|bir arkadaş} bir an kararsız kaldı. Bütün emekleri sergide görünmez olursa üzülecekti. O akşam yaptığı konuşmada {kahraman:yonelme} “Belki başlığa eski tarihi yazıp içeride açıklama yapabiliriz,” dedi. {kahraman}, “Ama dışarıda yazdığımız sözü içeride düzeltmek yeterli mi?” diye sordu. “Birçok ziyaretçi panoya kadar gelmeyebilir.”

Suna Hanım iki öğrenciyi de dinledi. “Afiş insanların dikkatini çekmek için var,” dedi. “Ama araştırmada ulaşmadığınız bir sonucu kesinmiş gibi söyleyemezsiniz.” Onlara kısa ama dürüst başlıklar denemelerini önerdi. “Köprünün İki Hatırası” ve “Yedi Tanık, İki Fotoğraf” seçenekleri çıktı. En sonunda ikinciyi seçtiler. Hem merak uyandırıyor hem de tarih konusunda uydurma bir kesinlik taşımıyordu.
---
@omurga
Görevli öneriyi görünce bir süre düşündü. “Bu daha ilginçmiş,” dedi. “Peki neden iki fotoğraf var?” {yoldas:yalin|bir arkadaş} kendisini anlatırken buldu. Araştırmanın en güçlü tarafının kesin cevap vermemek değil, doğru soruyu açık biçimde göstermek olduğunu fark etti. Bazen dürüst başlık daha çok merak uyandırabiliyordu.
---
@omurga
Hazırlık sırasında yüksek çözünürlüklü bir tarama bulundu. Fotoğrafın sağ kenarında, önceki kopyada görünmeyen dar bir bölüm vardı. Bu bölümde sahnenin yanında asılı küçük bir bez parçası görülüyordu. {kahraman} bezin üzerindeki şekilleri büyütüp incelemek istedi. Ancak pikseller belirginleşiyor, yazı hâlâ okunamıyordu. {yoldas:yalin|bir arkadaş} otomatik keskinleştirme aracıyla görüntüyü işlemeyi önerdi.

Orhan Bey'e danıştılar. Fotoğrafçı, görüntü iyileştirmenin farklı yöntemleri bulunduğunu, bazılarının var olan çizgileri belirginleştirdiğini, bazılarının ise tahmine dayalı yeni ayrıntılar üretebildiğini anlattı. “İyileştirilmiş görüntüyü gösterirseniz nasıl işlendiğini belirtin,” dedi. “Ayrıca orijinal taramayı koruyun.”

{kahraman} iki sürümü yan yana koydu. İşlenmiş görüntüde bir harf “K” gibi görünüyordu. Orijinalde ise o şeklin harf olduğundan emin olmak mümkün değildi. {yoldas:yalin|bir arkadaş}, “Belki kentin adı,” dedi. {kahraman}, “Olabilir, ama başka bir işaret de olabilir,” diye yanıtladı. İpuçlarını istediği sonuca doğru çekmemeyi öğreniyordu.

Arşiv sorumlusu Suna Hanım, çocuklara fotoğrafın kenarlarının neden kesilebildiğini de gösterdi. Bazı aileler fotoğrafı albüme sığdırmak için kenarlarını kırpmış, bazı baskılarda ise görünüşü düzeltmek için kopya yeniden düzenlenmişti. Bu yüzden tek bir kopyanın çerçevesi, çekildiği anın tamamını göstermeyebilirdi. {kahraman} ilk gün göremediği bir çizgi yüzünden yanlış tarih yazılacağını düşününce ürperdi. Sonra aynı hatayı önlemek için kaynakları karşılaştırmanın önemini hatırladı.
---
@omurga
Panoya yedi tanığın kartı asıldığında {yoldas:yalin|bir arkadaş} bir eksiklik gördü. Kartlar kişilerin sözlerini anlatıyordu, ama birbirleriyle ilişkilerini göstermiyordu. Büyük bir zaman çizgisi çizdi; belediyenin onarım kayıtlarını ve gazetelerde buldukları etkinlikleri bu çizgiye yerleştirdi. Tanık anlatılarını kesin tarih veriyormuş gibi değil, olası dönemleri işaretleyen renkli şeritlerle gösterdi. Böylece sözlü tarihin gücü ve sınırı daha anlaşılır hâle geldi.

{kahraman} bir kartın yanında uzun süre durdu. Emine Hanım'ın “Açılış değil onarımdı” sözünü başlangıçta kesin karşı görüş sanmışlardı. Oysa Emine Hanım başka tarafta bulunan iskelenin söküldüğünü anlatıyordu; fotoğrafın tamamındaki kalabalığın ne için toplandığını görmemişti. Sözü yanlış değildi, ama kapsamı sınırlıydı. {kahraman} kartın üstüne küçük bir not ekledi: “Tanığın doğrudan gördüğü bölüm: köprü onarımı.”

{yoldas:yalin|bir arkadaş} eski belediye çalışanı Cemal Bey'i yeniden aradı. Onun “Açılışı hatırlıyorum” sözünü sorarken hangi açılıştan bahsettiğini netleştirmek istedi. Cemal Bey uzun süre düşündü, ardından fotoğrafta görülen sahneyi değil, köprünün tekrar kullanıma açıldığı töreni hatırladığını söyledi. İlk görüşmedeki kelime farklı anlam taşımıştı. “Açılış” hem yeni köprünün ilk kullanıma girmesi hem de onarım sonrası trafiğe açılması için kullanılabiliyordu. Bir sözcüğün çok anlamlılığı tarihleme hatasına dönüşebilirdi.
---
@omurga
{kahraman} bu bulguyu not defterine ekledi. Dil dersinde öğrendikleri, arşiv araştırmasına beklemediği kadar yardım etmişti. Tek bir sözcüğün anlamını bağlamdan ayırarak okumak, bazen bütün bir olayı yanlış yere yerleştiriyordu. Bundan sonra tanıklara aynı soruyu tekrar etmek yerine neyi kastettiklerini açık biçimde soruyorlardı.
---
@omurga
Serginin açılışından önce öğretmenleri sınıfa geldi. “Bütün tanıklarınızı dinlemişsiniz,” dedi. “Peki siz bu süreçte kendi varsayımlarınızı nasıl değiştirdiniz?” {kahraman}, dedesinin anlattıklarını ilk başta sorgulamak istemediğini itiraf etti. {yoldas:yalin|bir arkadaş} ise sergiyi yetiştirmek için tarihi hemen kesinleştirmeye çalıştığını söyledi. İkisi de araştırmacının yalnızca başkalarının sözlerini değil, kendi beklentilerini de denetlemesi gerektiğini anlamıştı.

Birlikte küçük bir kutu hazırladılar: “Sen olsan başka hangi kaynağa bakardın?” Kutunun yanında boş kartlar duruyordu. Ziyaretçiler arşiv dosyası, eski gazete, fotoğrafın orijinali, farklı tanıklar gibi fikirler yazabilecekti. Bir öğrenci “Köprünün üstündeki taşların tarihi” önerisini yazdı. {kahraman} buna gülümsedi; malzemenin yaşı ile fotoğrafın tarihi aynı şey olmasa da yeni bir kanıt türünü düşündürüyor olabilirdi.

Açılış günü görevli tanıtım afişindeki başlığı bir kez daha okudu. “Yedi Tanık, İki Fotoğraf,” dedi. “Aslında serginin içinde sekizinci bir tanık daha var.” {yoldas:yalin|bir arkadaş} şaşırdı. “Kim?” Görevli fotoğrafları gösterdi. “Kendileri.” {kahraman} gülümsedi, sonra ekledi: “Ama onların söylediklerini de dikkatle okumamız gerekiyor.”
---
@omurga
Son sergi toplantısında {kahraman}, yedi tanığın ifadelerini tek bir çizelgeye yerleştirdi. İlk sütunda kimin neyi gördüğü, ikinci sütunda hangi kaynağın bu anlatıyı desteklediği, üçüncü sütunda ise belirsizlikler vardı. Suna Hanım tek tek inceledi. “Fotoğrafın tek bir doğru hikâyesi varmış gibi sunamayız,” dedi. “Ama yaptığınız araştırmanın kendisi serginin en güçlü bölümü olabilir.”

{yoldas:yalin|bir arkadaş} yeni bir pano çizdi. Ortada iki fotoğraf bulunacak, çevresinde yedi küçük tanık kartı yer alacaktı. Kartlarda kişilerin izniyle seçilmiş kısa sözler vardı. Bazılarında fotoğraftaki kalabalık, bazılarında müzik, bazılarında dükkân tabelası anlatılıyordu. En altta ise “Kesinleşenler”, “Muhtemel yorumlar” ve “Henüz bilmiyoruz” başlıklı üç bölüm bulunacaktı.

{kahraman} panonun önünde durunca araştırmanın nasıl değiştiğini hatırladı. Başta dedesini doğrulamak istemişti. Sonra yanlış bir tarihi düzeltmeye odaklanmıştı. Şimdi farklı bakış açılarını birlikte değerlendirmek istiyordu. {yoldas:yalin|bir arkadaş}, “Fotoğrafın kesin tarihini yazamayınca sergi eksik gibi görünmez mi?” diye sordu. {kahraman} başını iki yana salladı. “Bilmediğimizi söylemek, yanlış bir şeyi biliyormuş gibi göstermekten daha iyi.”
---
@omurga
Sergi açıldığında ziyaretçiler önce iki büyük fotoğrafı gördü. Sonra çevresindeki küçük kartlara yaklaştı. Yaşlı bir adam, “Ben bu şenliklerden birine katılmıştım,” dedi. Yanındaki çocuk, “Hangisine?” diye sorunca adam uzun süre düşündü. “Sanırım şu ikinci olana,” dedi, “ama emin değilim.” {kahraman} gülümsedi. Soru sormak, hatırayı değersizleştirmiyordu. Onu daha dikkatli dinlemeyi sağlıyordu.

Ziya Bey torununun hazırladığı panoya uzun uzun baktı. Kendi sözünden izin verdiği alıntıyı görünce gözleri doldu. “Bunu böyle anlatmanız hoşuma gitti,” dedi. “Benim anım benim için gerçek; ama hangi yıl olduğunu araştırmanız da doğru.” {kahraman} dedesine sarıldı. Bazen aynı olayla ilgili farklı türden doğrular bulunabilirdi: yaşanmış duygu, görülen görüntü, tarihsel kayıt. Bunları birbirine karıştırmadan yan yana koyabilmek büyük emek gerektiriyordu.

Sergi kapanışında öğretmenleri öğrencilere hangi ipucunun en önemli olduğunu sordu. {yoldas:yalin|bir arkadaş} dükkân tabelasını söyledi. {kahraman}, “Bence 'emin değilim' diyen bütün tanıklar,” dedi. “Çünkü onların tereddüdü bizi yeni kanıt aramaya götürdü.”
---
@omurga
Sergi açıldıktan sonra {kahraman:ilgi} en çok şaşırdığı şey, ziyaretçilerin fotoğraflardan çok araştırma defterini merak etmesiydi. Defterde silinen tarihler, üzeri çizilmiş tahminler ve sonradan eklenen notlar vardı. Bir kadın “Neden bu kadar çok düzeltme yaptınız?” diye sordu. {yoldas:yalin|bir arkadaş}, “Çünkü ilk düşündüğümüz şeyleri kanıtlarla karşılaştırdık,” dedi. {kahraman} de “Yanılabileceğimizi kabul edince daha iyi sorular sorduk,” diye ekledi.

Kadın kendi aile albümünde de tarihi karışmış fotoğraflar bulunduğunu anlattı. “Bazen annem bir yıl söyler, dayım başka bir yıl,” dedi. “Ben de kimin doğru söylediğini tartışırdım.” {kahraman} ona, aynı fotoğrafın farklı insanlarda farklı hatıraları canlandırabileceğini, anlaşmazlığı hemen yalancılığa bağlamadan belge aramanın daha yararlı olacağını söyledi.

Öğleden sonra sergiye gelen bir çocuk, “İki fotoğrafı birleştirip tek güzel kare yapamaz mısınız?” diye sordu. {yoldas:yalin|bir arkadaş} bunun sanat için yapılabilecek bir kolaj olabileceğini, fakat tarihî belge diye sunulmaması gerektiğini anlattı. Çocuk başını salladı. “Yani yapılabilir ama gerçek fotoğraf olduğu söylenmemeli.” {kahraman} bunu duyunca gülümsedi. Araştırmalarının yalnızca bir tarihi düzeltmekten fazlasına dokunduğunu fark etti.
---
@omurga
Akşam sergi kapatılırken Suna Hanım kutuları tek tek saydı. {kahraman}, fotoğrafı koyduğu dosyanın kapağına yeni bir etiket yapıştırdı: Kesin tarih bilinmiyor; kaynak araştırması sürüyor. Bu ifadeyi yazmak başlangıçta ona başarısızlık gibi gelmişti. Şimdi tersine, gelecekteki araştırmacılara bırakılmış dürüst bir davet gibiydi. Kaydın geçmişini ve yapılan araştırma adımlarını ekledi; böylece başkaları yeniden aynı soruları sormak zorunda kalmadan kaldıkları yerden ilerleyebilecekti.

{yoldas:yalin|bir arkadaş} koridorda asılı kalan afişe baktı. “Yedi tanık, iki fotoğraf,” diye okudu. “Ama sayılar değişebilir. Başka bir tanık bulunabilir, başka bir fotoğraf çıkabilir.” {kahraman} başını salladı. “O zaman hikâyemiz de değişir. Yeter ki neden değiştiğini açıklayabilelim.”

Köprünün üzerinde gün batarken {kahraman} ve {yoldas:yalin|bir arkadaş} son kez dışarı çıktılar. Korkuluk boyunca yürürken farklı yıllarda oradan geçen insanları düşündüler. Biri yağmuru hatırlamış, biri şarkıyı, biri yeni açılan dükkânı. Hiçbirinin anlattığı geçmiş tek başına şehri doldurmuyordu. Ama hepsi birlikte, dikkatle dinlenirse daha geniş bir manzara açıyordu.
---
@omurga
{kahraman} defterinin arkasına son cümleyi yazdı: “Bir tarihin arkasında bazen tek bir tanık değil, birbirine sorular soran birçok ses vardır.”
---
@omurga
Sergi kapandıktan birkaç gün sonra kütüphaneye bir mektup geldi. Mektubu yazan yaşlı bir ziyaretçi, köprüdeki etkinliklerden birine çocukken katıldığını söylüyordu. {kahraman} bunu görünce heyecanlandı; belki de bekledikleri kesin tarih bulunacaktı. Ancak ziyaretçi olayın yılını hatırlamıyor, yalnızca yanında bulunan akrabasının ismini veriyordu. {yoldas:yalin|bir arkadaş}, “Sekizinci tanık!” diye seslendi.

Suna Hanım, görüşme için önce izin alınması gerektiğini hatırlattı. {kahraman} mektuba nazikçe cevap yazdı. Ziyaretçinin adının açık yayımlanıp yayımlanamayacağını, hangi bilgilerini paylaşmak istediğini ve anlatısını görüşme notu olarak kullanmalarına izin verip vermediğini sordu. Bir süre sonra gelen cevapta kişi adını gizli tutmak istediğini belirtti. Bu tercih kabul edildi.

Yeni tanık, fotoğraftaki pankartın kırmızı kenarlı olduğunu hatırlıyordu. Fotoğrafta pankartın rengi siyah-beyaz baskı yüzünden anlaşılamıyordu. {kahraman} bu ayrıntıyı kesin doğrulanmış bilgi olarak kullanmadı. “Renk bir ipucu olabilir,” dedi, “ama elimizde bunu doğrulayacak görüntü yok.”

{yoldas:yalin|bir arkadaş}, araştırmanın hiç bitmeyeceğinden korktu. {kahraman} ise artık başka türlü bakıyordu. Bütün soruların cevaplanması, yapılan işin değerli olması için şart değildi. Yeter ki araştırılan konu, kullanılan kanıtlar ve belirsizlikler açıkça gösterilsin. Son kayıt dosyasına yeni tanığın ifadesi ayrı bir not olarak eklendi, fakat sergi etiketi değiştirilmedi.
---
@omurga
{kahraman} eve giderken köprünün üzerinden geçti. Bir zamanlar bu fotoğrafı doğru yıla yerleştirdiğinde gizemin tamamen biteceğini düşünmüştü. Şimdi şehrin geçmişinin tek bir fotoğraf çerçevesine sığmayacağını biliyordu. Her yeni tanık bir şey ekleyebilir, bazı soruları da çoğaltabilirdi. Köprünün altından geçen su gibi hikâyeler de akıp gidiyordu; önemli olan onları aceleyle tek bir kalıba hapsetmemekti.

Suna Hanım sergi arşivinin son hâlini kontrol ederken çocuklara teşekkür etti. “Siz yalnızca bir fotoğrafı yeniden adlandırmadınız,” dedi. “Kaynakların nasıl karşılaştırılabileceğini de gösterdiniz.” {yoldas:yalin|bir arkadaş} ilk günlerde bu kadar uğraşmanın gereksiz olduğunu düşündüğünü itiraf etti. Şimdi elindeki dosyayı gelecekte aynı fotoğrafı araştıracak kişilere aktarabilmekten memnundu. {kahraman} ise köprüden her geçtiğinde başka bir tanığın neler görebileceğini hayal ediyordu. Farklı pencerelerden bakılan aynı meydan, herkese aynı ayrıntıyı göstermiyordu. Bu yüzden insanları aceleyle karşı karşıya getirmek yerine anlatılarının sınırını anlamak gerekiyordu.
---
@omurga
Açılış günü yaşlı bir ziyaretçi panonun önünde uzun süre durdu. Fotoğrafta görünmüyordu; köprünün o günkü kalabalığını da hatırlamıyordu. Fakat alt yazıya eklenen “tarih kesinleşmedi” ifadesinin yanına konmuş kaynak notlarını tek tek okudu. “Demek eskiden fotoğrafları yalnızca albüme koymuyorlarmış,” dedi. {kahraman} gülümsedi: “Hayır, bazen de onlar hakkında yanlış başlık yazmışlar. Biz bunu düzeltmeye çalışıyoruz.”

Ziyaretçi bir ayrıntı sordu: “Bu iki fotoğrafın aynı makineden çıktığı belli mi?” {kahraman} bunun araştırılmadığını söyledi. {yoldas:yalin|bir arkadaş} hemen cevap vermek istiyordu ama {kahraman} başını hafifçe salladı. Sorular bitmediği için serginin eksik sayılmayacağını anlamışlardı. Bir kağıt bırakıp ziyaretçilerin bildikleri bir belge, tarih veya tanıklık varsa kaynağıyla birlikte paylaşmalarını istediler. Bu, rastgele yorum toplamak değildi; yeni bir araştırma kapısı açmaktı.

Akşam kapanışta {kahraman}, panonun kenarına iliştirilen iki notu okudu. Biri bir arşiv numarasını öneriyordu, diğeri yalnızca “Ben öyle hatırlıyorum” diyordu. İki cümlenin değeri aynı değildi ama ikisini de küçümsemedi. Birini izlenebilir bir ipucuna, diğerini incelenmesi gereken bir tanıklığa dönüştürmenin yolunu düşünmeye başladı.
