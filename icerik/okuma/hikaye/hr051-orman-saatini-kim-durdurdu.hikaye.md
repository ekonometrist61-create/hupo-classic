---
baslik: "Orman Saatini Kim Durdurdu?"
slug: "hr051-orman-saatini-kim-durdurdu"
fis_kodu: "HR-051"
tur: doga
konu: mevsim_gozlem
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: masalsi
izinli_turler: [ben, arkadas, hayvan, hayali]
deger_anahtarlari: [D6, D9]
yetiskin_uygun: false
tanitim: "Orman saati sonbaharda takıldı ama çiçekler açıyor. Saati kim durdurdu?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [doga, hayvanlar]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D9
  ogrenme_hedefleri:
    - {id: goc_hr051, tur: lexeme, etiket: "göç", yuva: hr051_goc, islev: first_hint}
    - {id: nem_hr051, tur: lexeme, etiket: "nem", yuva: hr051_nem, islev: application}
    - {id: mecaz_hr051, tur: lexeme, etiket: "mecaz", yuva: hr051_mecaz, islev: application}
    - {id: deyim_hr051, tur: idiom, etiket: "Kulaktan kulağa haber yaymak", yuva: hr051_kulaktan_kulaga, islev: application}
    - {id: kavram_hr051, tur: concept, etiket: "Gözlem ile çıkarım ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Bir sabah orman saatinin akrebi nerede takılı kaldı?", secenekler: [{id: A, metin: "Sonbaharda"}, {id: B, metin: "İlkbaharda"}, {id: C, metin: "Yazda"}, {id: D, metin: "Kışta"}], dogru: A, aciklama: "Saatin akrebi sonbaharda takılı kalmıştı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Yuva sayısı neye bağlı olarak değişebilir?", secenekler: [{id: A, metin: "Havaya, besine ve güvenli alana"}, {id: B, metin: "Yalnızca saate"}, {id: C, metin: "Yalnızca sincaplara"}, {id: D, metin: "Kuşların renklerine"}], dogru: A, aciklama: "Mavi'ye göre yuva sayısı yalnızca hava ile değil, besin ve güvenli alanla da ilgiliydi."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 7, metin: "Usta Zaman'ın sözüne göre saat ve orman arasındaki fark nedir?", secenekler: [{id: A, metin: "Saat zamanı sayar, orman canlıların ilişkilerini yaşar"}, {id: B, metin: "Saat ormanı büyütür"}, {id: C, metin: "Orman zamanı sayar"}, {id: D, metin: "İkisi aynıdır"}], dogru: A, aciklama: "Saat zamanı ölçer; ormanda ise canlıların birbirine bağlı ilişkileri sürer."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 7, metin: "Metinde geçen mecaz ne demektir?", secenekler: [{id: A, metin: "Bir şeyi başka bir şeyle anlamlı biçimde ilişkilendiren söz sanatı"}, {id: B, metin: "Bilimsel bir ölçüm"}, {id: C, metin: "Bir ağaç türü"}, {id: D, metin: "Hava durumu"}], dogru: A, aciklama: "Mecaz, bir sözcüğü gerçek anlamından farklı ama ilişkili bir anlamda kullanmaktır."}
deyim_cumleleri:
  hr051_kulaktan_kulaga: "Sincap {yoldas:yalin|bir arkadaş} bunu görür görmez kulaktan kulağa haber yaydı: “Ormanın mevsimleri bozuldu!”"
---
@omurga
Orman okulunun duvarında dört kanatlı, kocaman bir saat asılıydı. Saatin kolları sayıların değil, ilkbahar çiçeklerinin, yaz güneşinin, sonbahar yapraklarının ve kış karının üzerinde dolaşıyordu. Ormandaki hayvanlar bu saati bir takvim gibi kullanmazdı; daha çok büyüklerin anlattığı bir masaldan kalma hatıra olarak severlerdi.

Bir sabah saatin akrebi sonbaharda takılı kaldı. Oysa dere kıyısındaki çiçekler yeni açmıştı.[[deyim:hr051_kulaktan_kulaga]] {isaret:orman}

Beşinci sınıftan {kahraman}, babasıyla birlikte yürüyüş yapmak için ormana geldiğinde herkesin saat hakkında konuştuğunu duydu. Orman girişindeki rehber panosunda gerçekten de eski bir saat resmi vardı; bu, yıllar önce bir sanatçının yaptığı ahşap bir düzeneğin simgesiydi. {kahraman}, sincapların konuştuğunu duymadığı hâlde hayalinde onların bir araya gelip tartıştığını düşündü. Babası, “Bir doğa hikâyesi yazmak ister misin?” diye sordu. {kahraman} defterine şu başlığı attı: Orman Saatini Kim Durdurdu?
---
@omurga
Hikâyede {yoldas:yalin|bir arkadaş} ilk olarak kirpi Pati'ye koştu. Pati toprağın {kelime:hr051_nem} kontrol ediyordu. “Kış yeniden gelecekmiş,” dedi {yoldas:yalin|bir arkadaş}. “Saat durmuş.”

Pati başını kaldırdı. “Saat bir işarettir, mevsimin kendisi değil. Toprak hâlâ ılık, çiçekler açıyor. Acele karar verme.”

{yoldas:yalin|bir arkadaş} ikna olmadı. Saatin altındaki yaprak motifinin üzerine yağmur damlaları birikmişti. “Baksana, yapraklar da dökülüyor,” dedi. Pati ona rüzgârın kuru yaprakları bütün yıl yere indirebileceğini anlattı. Bir işaretin tek başına mevsimi belirlemeyeceğini vurguladı. {yoldas:yalin|bir arkadaş} ise dört kanatlı saatin yıllardır yanlış göstermediğine inanıyordu.

İkili ormandaki kuşlara sordu. Serçe Mavi, aynı dalda geçen yıldan daha az yuva gördüğünü söyledi. “Demek kuşlar kışı bekliyor,” dedi {yoldas:yalin|bir arkadaş}. Mavi başını iki yana salladı. “Bazı arkadaşlarımız başka yerlere {kelime:hr051_goc} ediyor, bazıları burada kalıyor. Her kuşun davranışı aynı değil. Üstelik yuva sayısı hava kadar besin ve güvenli alanla da ilgili.”
---
@omurga
Yol kenarındaki çiçekler bazen erken açmış, bazen geç kalmıştı. Arılar hava soğukken daha az dışarı çıkıyor, güneşli saatlerde çiçeklerin çevresinde daha çok görünüyordu. Orman saati ise bütün bu değişiklikleri tek bir hareketle anlatmaya çalışıyordu. {kahraman}, hikâyesinde saatin neden durduğunu öğrenmek için hayvanları bir araştırma ekibine dönüştürdü.

İlk görevleri çevreyi gözlemlemekti. Pati toprağın nemini, Mavi kuşların davranışlarını, {yoldas:yalin|bir arkadaş} da ağaçların yapraklarını izleyecekti. Tilki Doruk kayıt tutacaktı. Çünkü Doruk, kim neyi ne zaman gördüyse yazmanın kulaktan dolma sözlerden daha güvenilir olduğunu söylüyordu.

Bir hafta sonra notlar birikti. {yoldas:yalin|bir arkadaş} her gün aynı ağaca baktı; yeni yapraklar küçücük başlayıp büyüyordu. Mavi, bazı göçmen kuşların geri döndüğünü gördü. Pati, sabah ile öğle arasında toprağın yüzey sıcaklığının değiştiğini yazdı. Doruk hepsini büyük bir kâğıda geçirdi.
---
@omurga
“İşte, ilkbahardayız,” dedi Pati.

“Peki saat neden sonbaharda kaldı?” diye sordu {yoldas:yalin|bir arkadaş}. “Bütün bunlar birbirine uymuyor.”

Doruk, “Saat bozuk olabilir,” dedi. “Bunu anlamak için saate bakmamız gerek.”

Saat, bir gövdeye sabitlenmişti. Kimse hayvanları ağaca tırmanmaya zorlamadı; hikâyede bile güvenli davranmayı tercih ediyorlardı. Orman görevlisi Ekin Hanım'dan yardım istediler. Gerçek ormanda böyle bir saati bakım ekibinin incelemesi gerekirdi. {kahraman} bu ayrıntıyı defterine özellikle ekledi.

Ekin Hanım saatin yakınındaki toprağı inceledi. Sert esen fırtınada kopan ince bir dal, ahşap çarkların arasına sıkışmıştı. Dal, saatin mevsim kanadını engelliyordu. {yoldas:yalin|bir arkadaş} şaşkınlıkla baktı. “Demek bütün orman bozulmadı, yalnızca saat sıkıştı.”

Ekin Hanım bakım ekibiyle dalı güvenli şekilde çıkardı. Çarkları temizlediler; saate aşırı baskı yapan paslı bölümleri kontrol ettiler. Ahşap kanat yeniden döndüğünde {yoldas:yalin|bir arkadaş} sevinçle bağırdı. Ama Doruk'un aklında hâlâ bir soru vardı: “Saat düzelmiş olabilir, fakat çevredeki değişiklikleri nasıl anlatacağız?”
---
@omurga
Bu soru hayvanları susturdu. Çünkü dere kıyısında bu yıl gerçekten daha az su akıyordu. Ormanın bazı yerlerinde çocukların bıraktığı çöpler birikmişti. {kahraman}, olayın yalnızca kırılan bir saatten ibaret olmasını istemedi. Bir göstergenin düzelmesi, çevredeki bütün sorunların da çözülmesi anlamına gelmiyordu.

Hikâyedeki hayvanlar dereye yürüdü. Pati, kıyıda plastik ambalajlar gördü. Mavi yuva yaparken takıldığı bir ipi gösterdi. Doruk, “Bunlar mevsimin değişmesi değil, insanların bıraktığı izler,” dedi. {yoldas:yalin|bir arkadaş}, saat bozuk sanıp ormanın gerçek işaretlerine bakmadığı için utandı.

{kahraman} defterini kapatıp babasına okudu. Babası, “Saatin bozulduğu kısmı çok sevdim,” dedi. “Ama hayvanlar neden yalnızca bir haftalık gözlemle bütün mevsimleri açıklıyor?”

{kahraman} düşündü. Bir haftalık veri bazen günlük değişimleri gösterebilirdi; uzun süreli iklim örüntülerini ise tek başına açıklayamazdı. Babasının sorusu hikâyeyi geliştirdi. Hayvanların yalnız bir hafta değil, yıl boyunca farklı aralıklarla gözlem yapmaya karar verdiği bir bölüm ekledi. Doruk, kayıtların yıllar içinde karşılaştırılmasını önerdi. Hava durumunun o günkü koşulları, ikliminse uzun süreli örüntüleri anlattığını öğrendiler.
---
@omurga
Ertesi pazar {kahraman} yeniden ormana geldi. Yanında küçük bir defter vardı. Bu kez gerçek gözlemlerini yazmaya başladı: “Saat 10.20, hava parçalı bulutlu. Dere akıyor. Üç serçe gördüm. Bir çiçeğin üstünde arı vardı.” Babası bunu görünce, “Yazar da araştırmacı da dikkatli bakmayı sever,” dedi.

{kahraman}, kurduğu öykünün bazı kısımlarını düzeltti. Örneğin hayvanların insanlar gibi konuşmasını masal özelliği olarak bıraktı. Ancak kuşların göç etmesinin tek bir nedene bağlı olmadığını, mevsimlerin yalnızca bir saate bakılarak belirlenemeyeceğini açıkça gösterdi. Arkadaşlarıyla okulda okuduklarında kimse hikâyenin ders gibi olduğunu söylemedi. Çünkü saatin kim tarafından durdurulduğunu bulmak hâlâ merak uyandırıyordu.

Hikâyenin sonunda {yoldas:yalin|bir arkadaş}, saatin altına yeni bir pano asmayı önerdi. Panoda dört mevsim vardı ama her birinin yanında hayvanların gözlem defterleri için ayrı kutular bulunuyordu. Baharda çiçeklenen bitkiler, yazın gölgede dinlenen hayvanlar, sonbaharda değişen yapraklar, kışın görülen izler kaydedilecekti. Her yeni yıl, eski notlarla karşılaştırılacaktı.
---
@omurga
Saat bundan sonra da bazen durabilirdi. Rüzgâr yine dal kırabilir, yağmur yağabilir, tahtalar eskirdi. {yoldas:yalin|bir arkadaş} artık her değişikliği felaket olarak görmeyecekti. Çünkü bir işareti anlamanın yolu, yalnızca ona bakmak değildi. Çevreyi birlikte gözlemlemek, kuşkuyu soru hâline getirmek ve uzun süreli kayıt tutmak gerekiyordu.

Hikâyeyi tamamlamadan önce {kahraman}, aynı sınıftan Eren'le tartıştı. Eren, “Bir saatin durması için daha gizemli sebep gerekirdi,” diyordu. “Belki ormanın kalbi yorulmuştur.” {kahraman} bu fikri güzel bir {kelime:hr051_mecaz} olarak buldu ama ormanın gerçek anlamda bir kalbi olmadığını söyledi. İkisi kısa süreliğine anlaşamadı. Sonra öğretmenleri mecazla bilimsel bilgiyi nasıl yan yana kullanabileceklerini sordu. {kahraman}, “Orman tek bir canlının kalbi gibi işlemez, ama canlıların ilişkileri birbirini etkiler,” dedi. Eren, bu cümleden hareketle yeni bir karakter yazmalarını önerdi: Dere kıyısında yaşayan, bütün hayvanların haberlerini toplayan yaşlı kaplumbağa. Kaplumbağanın adı Usta Zaman olacaktı. Masalsı bilgeliğiyle şunu söyleyecekti: “Saatler dakikayı sayar, orman ilişkileri yaşar.”
---
@omurga
Usta Zaman ilk bölümde {yoldas:yonelme|bir arkadaşa} üç ayrı kutu gösterdi. Birinde yağmurdan sonra toplanmış su, birinde kuru yapraklar, diğerinde de küçük tohumlar vardı. “Bunlar aynı mevsime ait olabilir mi?” diye sordu. {yoldas:yalin|bir arkadaş} hemen “Hayır,” dedi. Sonra bahar yağmurunu, kıştan kalan yaprakları ve toprağa düşen tohumları düşündü. Birbirinden farklı işaretler aynı gün görülebilirdi. Usta Zaman, “Doğadaki her değişim aynı hızda gerçekleşmez,” dedi. “Bir ağaç başka bir ağaçtan önce yapraklanabilir. Bir kuşun göç zamanı, bir böceğin ortaya çıkış zamanı farklı olabilir.” {yoldas:yalin|bir arkadaş} bu sözleri dinledikten sonra saatin tek kanadına bakıp bütün orman adına konuşmamaya karar verdi.
---
@omurga
{kahraman}, hikâyenin araştırma bölümüne küçük bir yanlış alarm ekledi. Doruk bir sabah dere kenarında beyaz köpükler gördü ve suyun kirlenmiş olabileceğini düşündü. {yoldas:yalin|bir arkadaş} hemen panikledi. Pati ise köpüğün nedenini belirlemeden “zehirli” demelerinin doğru olmadığını söyledi. Ekin Hanım'a haber verdiler; görevli suyun görünüşünden kesin sonuç çıkarılamayacağını, şüpheli bir durumda yetkili birimlerce inceleme yapılması gerektiğini anlattı. Çocuklar da gerçek hayatta böyle bir durum görürlerse suya dokunmadan yetişkinlere bildirmeleri gerektiğini öğrendi. Böylece hikâyedeki merak, tehlikeli denemelere dönüşmedi.

Ormanın eski fotoğraflarına bakmak, Doruk'un aklına gelmişti. Park girişindeki ziyaretçi merkezinde on yıl önce çekilmiş görüntüler vardı. Bazı ağaçlar büyümüş, yürüyüş yolları değiştirilmiş, bir açıklığa yeni fidanlar dikilmişti. {yoldas:yalin|bir arkadaş} görüntüleri yan yana koyunca aynı alandaki değişimleri daha rahat gördü. Fakat fotoğrafların farklı mevsimlerde çekilmiş olabileceği uyarısını da not etti. Kışın çıplak görünen bir ağaç, yazın yapraksız kalmış bir ağaçla aynı anlama gelmiyordu. Ekin Hanım tarihlere bakmalarını istedi. Bu küçük ayrıntı olmadan karşılaştırmaları yanıltıcı olabilirdi.
---
@omurga
Bir gün Mavi, kuşların neden bazen sessizleştiğini sordu. {kahraman} bu bölüm için kuşların seslerini araştırdı. Kuşlar farklı amaçlarla ötebilir, çevredeki gürültü de seslerini duymamızı zorlaştırabilirdi. Mavi, orman kenarındaki yolun kalabalık saatlerinde kendi sesinin zor duyulduğunu anlattı. Bu yüzden sessizliği yalnızca “kuşlar yok oldu” diye yorumlamayacaklardı. Gözlemleri tekrar edecek, farklı saatlerde dinleyeceklerdi. {kahraman} hikâyeye küçük bir oyun koydu: Okur, ormanın üç farklı anında neyin değiştiğini düşünerek kendi gözlem listesi oluşturabilecekti. Ancak hikâyenin devamı bu oyunu tamamlamasına bağlı olmayacaktı; okumak her zaman özgür kalacaktı.
---
@omurga
Eren son taslakta, saati gerçekten kimin durdurduğunu öğrenmeden önce {yoldas:ilgi|bir arkadaşın} ağaca tırmanmasını istemişti. {kahraman} bu sahneyi değiştirdi. “Hayvanların istediği yere tırmanması başka; çocukların bozuk bir mekanizmayı kendilerinin tamir etmeye çalışması başka,” dedi. “Biz okuyucularımıza riskli bir şeyi örnek göstermeyelim.” Onun yerine Ekin Hanım'ın bakım ekibine haber verdiği, hayvanların da güvenli uzaklıkta beklediği sahne yazıldı. Eren bu çözümü sıkıcı buldu; fakat bakım ekibinin içinden çıkan paslı çarkı görünce ilgisi yeniden arttı. Çarkın üzerinde yıllar önce saati yapan ustanın küçük işareti vardı. Usta, saat durduğunda doğayı suçlamak yerine önce saatin bakımını kontrol etmelerini öğütleyen bir not bırakmıştı.
---
@omurga
{kahraman:ilgi} babası, yazdığı masalı akşam evde sesli okumasını istedi. Küçük kardeşi özellikle {yoldas:belirtme|bir arkadaşı} sevmişti. “Niye bu kadar acele ediyor?” diye sordu. {kahraman}, sincapların gerçekten telaşlı olduğu iddiasını değil, kendi karakterinin huyunu anlattı: {yoldas:yalin|bir arkadaş} başkalarına haber vermeyi sevdiği için doğrulamadan konuşuyordu. “Peki sonra ne öğreniyor?” sorusuna {kahraman} şu cevabı verdi: “Hızlı haber vermek bazen iyidir ama **yanlış haberi hızla yaymak zarar verebilir**.” Kardeşi ertesi gün sınıf grubunda duyduğu bir söylentiyi hemen paylaşmak istemediğini söyledi. {kahraman}, hikâyenin yalnız mevsimler hakkında olmadığını o anda anladı.
---
@omurga
Hikâyenin bitiminden sonra orman okulunda “Dört Mevsim Şenliği” düzenlendi. Hayvanlar her masada bir farklı gözlem türü sundu. Pati toprak ve nem ilişkisini, Mavi göç yolculuklarının zorluklarını, Doruk uzun süreli kayıtları anlattı. {yoldas:yalin|bir arkadaş} ise bir panoda “Önce bak, sonra sor, en son paylaş” yazdı. Başlarda kendisini her haberin ilk sahibi olarak görmek isterdi. Şimdi en iyi habercinin en hızlı bağıran değil, dikkatle dinleyen olduğunu düşünüyordu. Şenlik boyunca bir çocuk panodaki saatin resmini gösterip “Bunu kim düzeltti?” diye sorunca {yoldas:yalin|bir arkadaş} kahkaha attı: “Bakım ekibi! Biz yalnız soruyu doğru sormayı öğrendik.”
---
@omurga
{kahraman} son sayfaya, gerçek orman gezisinde gördüğü üç şeyi ekledi. Kırık dalın altındaki mantarlar, dere kıyısındaki taze ayak izleri ve rüzgârın çevirdiği kuru yaprak… Bunlardan hiçbiri tek başına koca ormanın sağlığı hakkında kesin karar verdirmiyordu. Ama her biri iyi bir başlangıç sorusu olabilirdi. {kahraman} defterini kapatırken masalındaki saati bir kez daha çizdi. Bu kez saatin yanında bir büyüteç, bir not defteri ve küçük bir soru işareti vardı. Mevsimleri yöneten sihirli bir düğme değil, doğayı anlamaya çalışan bir çocuğun araçları bunlardı.

Öğretmenleri sınıfta farklı masalları okuduktan sonra herkes kendi metnindeki bir varsayımı işaretledi. {kahraman}, ormanda görülen az sayıdaki kuşun bütün türlerin azaldığı anlamına gelmediği cümlesini seçti. Eren ise “Ormanın kalbi yoruldu” benzetmesinin bilimsel bir açıklama olmadığını yazdı. İkisi artık aynı metinde hem şiirsel dili hem de güvenilir bilgiyi kullanabileceklerini biliyordu. Bu da arkadaşlıklarına iyi gelmişti. Çünkü tartışmaları artık kimin haklı olduğunu göstermeye değil, birlikte daha iyi bir hikâye yazmaya yönelmişti.
---
@omurga
Bir ay sonra öğretmen, öğrencilerden hikâyelerindeki kahramanların değişimini tek cümleyle anlatmalarını istedi. {kahraman}, {yoldas:ilgi|bir arkadaşın} saat bozukken ormanı suçladığını, sonunda ise kendi düşünme biçimini sorguladığını söyledi. Eren ona katıldı: “Bence saatin onarılması asıl bitiş değil. {yoldas:ilgi|bir arkadaşın} hemen hüküm vermemeyi öğrenmesi asıl son.” Sınıfta kısa bir sessizlik oldu. {kahraman} başlangıçta yalnızca durdurulmuş bir saat hakkında eğlenceli bir bilmece yazdığını sanmıştı. Şimdi bulmacanın kahramanın davranışlarına da dokunduğunu görüyordu.

Yaz gelince {kahraman} ile babası aynı yürüyüş yoluna tekrar gitti. Dere biraz çekilmişti. {kahraman} bunun nedenini tek bir gözlemle açıklamaya kalkmadı. Yağış miktarı, sıcaklık, su kullanımı ve başka etkenleri araştırmaları gerektiğini biliyordu. Yanlarına aldıkları küçük bir torbaya yol kenarında buldukları çöp parçalarını, güvenli biçimde ve yetişkin gözetiminde topladılar; keskin veya tanımadıkları atıklara dokunmadılar. {kahraman}, bir hikâye yazmanın doğayla ilişkisini değiştirdiğini fark etti. Artık patikaya yalnız güzel bir manzara olarak bakmıyordu; orada yaşayan canlıların ihtiyaçlarını da düşünüyordu.
---
@omurga
O gece masalın sonuna yeni bir cümle ekledi: “{yoldas:yalin|bir arkadaş} her bahar saatin önünden geçiyor, onu kısa süreliğine kontrol ediyordu; ama asıl takvimi, birbirine bağlı canlıların yaşadığı ormanda okuyordu.” Böyle yazınca saatin simgesi de değişti. Başta korku yaratan saat, sonunda öğrenmeye açılan bir hatırlatıcıya dönüştü. {kahraman} bu sonu beğendi. Çocukların hiçbir değişikliği görmezden gelmemesini, ama tek bir işarete bakıp bütün dünyayı açıklamaya çalışmamasını istiyordu.

Sonraki eğitim yılında okul, doğa gözlem defterlerini küçük bir sergide topladı. Bir öğrencinin çiziminde yağmurlu bir bahar günü, diğerinde sıcak bir sonbahar öğlesi vardı. {kahraman}, farklı gözlemlerin aynı dünyaya ait olabildiğini anlattı. Ziyaretçilerden biri “Peki saatin doğru gösterdiğini nereden biliyorsunuz?” diye sordu. {kahraman} gülümsedi. Masalını okuyup bitiren herkesin bu soruyu sorabilmesini umuyordu. “Saate bakarız,” dedi, “ama sonra çevremizdeki kanıtları da inceleriz. İki bilgi uyuşmuyorsa hemen korkmayız, nedenini araştırırız.” Sergiden çıkarken {yoldas:ilgi|bir arkadaşın} küçük resmine baktı. Sincap artık kuyruğunu telaşla sallamıyordu. Bir yaprağın üzerine oturmuş, defterini açmıştı.
---
@omurga
{kahraman} sayfanın köşesine son bir çizgi ekledi: Saati onaran elin yanında küçük bir soru işareti vardı. Sorular bitmemişti; artık onlardan korkmuyordu. Çünkü merak, öğrenmenin en güzel başlangıcıydı.
---
@omurga
- Kavramlar: Mevsim, göç, ekosistem, hava durumu–iklim ayrımı, veri kaydı. - Dil: Benzetme, değişim ve döngü; gözlem ile çıkarım. - Editoryal: Hayvanların konuşması masal tekniğidir; ekolojik olgular gerçekçi açıklanmalıdır.
