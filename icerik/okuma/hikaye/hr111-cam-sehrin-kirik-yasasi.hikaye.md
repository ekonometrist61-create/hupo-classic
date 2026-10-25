---
baslik: "Cam Şehrin Kırık Yasası"
slug: "hr111-cam-sehrin-kirik-yasasi"
fis_kodu: "HR-111"
tur: fantastik
konu: gizlilik_riza_guvenlik
sinif_alt: 8
sinif_ust: 8
okuma_bandi: 3
dunya_tipi: masalsi
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Düşüncelerin duvarda göründüğü bir şehirde {kahraman}, gizliliği ve güvenliği birlikte düşünmeyi öğrenir. Rıza ve sorumluluk üzerine bir yasa tartışması."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 8
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [guvenlik, dayanisma]
  ders_baglantisi: [turkce, sosyal]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: denetim_hr111, tur: lexeme, etiket: "denetim", yuva: hr111_denetim, islev: first_hint}
    - {id: kalkan_hr111, tur: lexeme, etiket: "kalkan", yuva: hr111_kalkan, islev: application}
    - {id: sorusturma_hr111, tur: lexeme, etiket: "soruşturma", yuva: hr111_sorusturma, islev: application}
    - {id: varsayilan_hr111, tur: lexeme, etiket: "varsayılan", yuva: hr111_varsayilan, islev: transfer}
    - {id: deyim_hr111, tur: idiom, etiket: "Söz istemek", yuva: hr111_soz, islev: application}
    - {id: kavram_hr111, tur: concept, etiket: "Gizlilik ile güvenliği dengelemek", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (8. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Kahramanın pazardan aldığı müzik kutusunun hangi kısmı çatlamıştı?", secenekler: [{id: A, metin: "Anahtarı"}, {id: B, metin: "Kemeri"}, {id: C, metin: "Mekanizması"}, {id: D, metin: "Kapağı"}], dogru: D, aciklama: "Kutunun kapağı çatlamıştı; içindeki mekanizma ise sıkışmıştı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 8, metin: "Kahramana göre bir kişinin yalnızca korkmuş olması ne anlama gelir?", secenekler: [{id: A, metin: "Kötülük yaptığının kanıtı değildir"}, {id: B, metin: "Kötülük yaptığının kanıtıdır"}, {id: C, metin: "Her zaman yalan söylediğini gösterir"}, {id: D, metin: "Okuldan ayrılması gerektiğini gösterir"}], dogru: A, aciklama: "Korkmuş olmak tek başına kötülük yapıldığının kanıtı değildir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 21, metin: "Kahramana göre düşüncelerin herkese görünmesi neyin yerini tutamaz?", secenekler: [{id: A, metin: "Gönüllü yardım kanallarının"}, {id: B, metin: "Güvenli bir soruşturmanın"}, {id: C, metin: "Okul kütüphanesinin"}, {id: D, metin: "Babanın sözünün"}], dogru: B, aciklama: "Kahraman, düşüncelerin görünür olmasının güvenli bir soruşturmanın yerini tutamayacağını söyler."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 12, metin: "Bu cümlede “hesaba katmak” ne anlama gelir?", secenekler: [{id: A, metin: "Parayı saymak"}, {id: B, metin: "Bir sayıyı hesaplamak"}, {id: C, metin: "Farklı ihtiyaçları göz önünde bulundurmak"}, {id: D, metin: "Birini suçlamak"}], dogru: C, aciklama: "Hesaba katmak, farklı ihtiyaçları karar verirken dikkate almak demektir."}
  - {id: s5, beceri: degerlendirme, dayanak_sayfa: 20, metin: "Metne göre rıza nasıl olmalıdır?", secenekler: [{id: A, metin: "Bir kez verilip ömür boyu geçerli olmalı"}, {id: B, metin: "Yetişkinlerin kararıyla verilmeli"}, {id: C, metin: "Hiç yazılı olmamalı"}, {id: D, metin: "Anlaşılır, geri alınabilir ve baskı olmadan verilmiş olmalı"}], dogru: D, aciklama: "Rıza, anlaşılır, geri alınabilir ve baskısız verilmiş olmalıdır."}
deyim_cumleleri:
  hr111_soz: "İpek söz istedi."
---
@omurga
Cam Şehir'de kimse başkasının aklından ne geçtiğini sormazdı. Buna gerek yoktu. Bir insan bir şeyi yeterince güçlü düşündüğünde düşüncesi yakınındaki duvara renkli yazılar halinde düşerdi. Sevince sarı, korkunca lacivert, kuşkulanınca soluk yeşil görünürdü. Şehrin girişindeki büyük kemerde bu düzenin adı yazılıydı: Açıklık, güvenin başlangıcıdır.

On dört yaşındaki {kahraman} bu cümleyi, aynı kemerin altından her geçişinde okurdu. Çocukken ona hoş gelmişti. Kardeşiyle oyun oynarken ikisinin de aynı yere saklanmayı düşündüğünü duvardan görüp gülerlerdi. Şimdi ise her sözcüğün, söylendiği yerde başka bir anlamı olabileceğini fark ediyordu. Geçen hafta arkadaşı {yoldas:ilgi|bir arkadaşın} matematik sınavından korktuğu, koridorun camına kocaman harflerle yazılmıştı. Sınıfın yarısı onu teselli etmeye çalışmış, öteki yarısı alay etmişti. {yoldas:yalin|bir arkadaş} ertesi gün okula gelmemişti.

{kahraman:ilgi} asıl sorunu bundan daha küçüktü ve belki bu yüzden daha ağır geliyordu: Babasına doğum günü için bir sürpriz hazırlamak istiyordu. İkinci el eşya pazarından onun çocukluğunda dinlediği eski bir müzik kutusu bulmuştu. Kutunun kapağı çatlamış, içindeki küçük mekanizma sıkışmıştı. {kahraman} onarmak için atölyeye götürmek istediğinde pazarın cam tavanında bir yazı belirmişti: Babam görmesin.
---
@omurga
Satıcı göz kırpmıştı. “Sürprizler bu şehirde pek uzun yaşamaz.”

Dün gece babası sofrada, “Bana ne saklıyorsun?” diye sorunca {kahraman} yalan söylememiş, fakat doğruyu da anlatamamıştı. “Şimdilik anlatmak istemiyorum,” demişti. Duvar hemen koyulaşmış, Kızım bana güvenmiyor diye babasının düşüncesini göstermişti. Oysa {kahraman:ilgi} sakladığı şey güvensizlik değil, sevgiyle hazırlanmış bir hediyeydi.

Sabah evden çıkarken müzik kutusunu çantasına koydu. Kapağın altında küçük pirinç bir anahtar vardı. Üzerinde bir sözcük kazılıydı: Seçmek. {kahraman} bu sözcüğün neden orada olduğunu bilmiyordu. Fakat okulun yolunda ilk kez düşüncelerini değil, düşüncelerini kimin görebileceğini seçmek istedi.
---
@omurga
Cam Şehir Ortaokulu, üst üste konmuş saydam küplerden oluşuyordu. Merdivenlerde kimin sınava hazırlandığı, kimin arkadaşıyla küstüğü, kimin eve özlem duyduğu yazardı. Öğretmenler, “Böylece birbirimizi daha kolay anlıyoruz,” derdi. Bazen haklıydılar. Geçen kış merdivende fenalaşan bir öğrencinin korkusu duvara yansımış, nöbetçi öğretmen yardım edebilmişti. Ancak koridordaki her yazı yardım çağrısı değildi.

{kahraman}, sınıfa girerken {yoldas:ilgi|bir arkadaşın} sırasının hâlâ boş olduğunu gördü. Matematik öğretmeni Arda Bey yoklama aldıktan sonra bir duyuru yaptı: Şehir Meclisi, düşünce duvarlarının kullanımına ilişkin eski yasayı değerlendirmek için gençlerin görüşlerini toplayacaktı. Her okul bir temsilci gönderecekti. Öğrenciler önce heyecanlandı, sonra tedirgin oldu. Meclis salonunun duvarları da düşünceleri gösteriyordu; konuşmadan önce ne hissettikleri herkesçe görülecekti.

“Aday olmak isteyen?” diye sordu Arda Bey.

Sınıfın arkasında bir el kalktı. İpek, şehirdeki saydamlık düzenini savunan en çalışkan öğrencilerden biriydi. “Gizlenecek şeyi olmayan neden korksun?” dedi. Bu söz duvarda parlak sarı harflerle görünürken {kahraman}, kimsenin gizlemek istemediği ama paylaşmak da istemediği şeyler bulunduğunu düşündü: Birine duyulan hayranlık, henüz söylenmemiş bir özür, unutulması istenen bir korku.
---
@omurga
{kahraman} da elini kaldırdı. “Ben de aday olmak istiyorum.”

İpek şaşırdı. “Ama sen bir konuşmanın ortasında bile fikrini değiştirebilirsin.”

“Evet,” dedi {kahraman}. “Belki de bunun kötü bir yanı yoktur.”

Seçim için arkadaşlarından destek istemek yerine bir soru yazdı: Başkalarının öğrenmesine izin vermediğiniz bir düşünceniz oldu mu? Okulun girişinde sergilenen sorunun altına, yüzlerce öğrenci cevap verdi. Kimi “Bir kez,” kimi “Her gün,” kimi de “Soruyu bile cevaplamak istemiyorum,” yazmıştı.

Son cümlenin yanına {kahraman} küçük bir yıldız çizdi. Kimseye cevap vermemeyi seçmek de bir cevaptı; ama bunu açıklamak zorunda değildi. Seçimde {kahraman} bir oy farkla kazandı. Duvarda İpek'in kırgınlığı, {kahraman:ilgi} korkusu aynı anda belirdi. İki kız birbirine bakınca hiçbirinin o an gösterilen duyguya indirgenemeyeceğini anladı.
---
@omurga
{kahraman}, konuşmasını hazırlamak için şehrin en eski bölgesindeki Kırık Cam Atölyesi'ne gitti. Burada aynalar, renkli pencereler ve artık üretilmeyen opak şişeler onarılırdı. Atölyenin sahibi Lale Usta, düşünce yansıtma sistemi kurulmadan önce doğmuş az sayıdaki kişidendi. Elleri kesik izleriyle doluydu; masasında farklı çağlardan kalma cam örnekleri bulunurdu.

“Duvarların eskiden düşünceleri göstermediği doğru mu?” diye sordu {kahraman}.

“Doğru. Eskiden de insanlar birbirinin ne düşündüğünü anlamaya çalışırdı. Yüzlere bakar, sorular sorar, bazen yanılırdı.”

“Şimdi yanılmıyoruz sanıyoruz.”

Lale Usta {kahraman:ilgi} getirdiği müzik kutusuna baktı. “Babanın kutusu bu mu? Çok eski bir yay mekanizması var. Onarabiliriz.” Sonra {kahraman:belirtme} arka odaya çağırdı. Odanın pencereleri buzlu camdandı. Duvarlarda hiçbir düşünce görünmüyordu.

{kahraman} neredeyse irkildi. Kendi sesini duydu; başka kimsenin aklından geçen şeyi okuyamadığı bir sessizlikti bu. “Burası nasıl çalışıyor?” diye fısıldadı.

“Düşünceleri saklayan bir büyü değil. Bu cam, renkleri dışarıdaki yansıtma damarlarına iletmiyor. Vaktiyle sıradan bir yapı malzemesiydi.”
---
@omurga
{kahraman} buradaki ilk düşüncesinin Ya yanlış bir şey söylersem? olduğunu fark etti. Hiçbir yere yazılmadı. İkincisi Burada daha rahat nefes alıyorum oldu. Bunun da görünmemesi onu özgürleştirdi. Fakat Lale Usta'nın ne düşündüğünü görememek başka bir soruyu aklına getirdi: Ya biri burada kötülük planlıyorsa?

“Öyleyse her düşünceyi göstermek güvenlik için gerekli olabilir,” dedi.

Lale Usta bir kavanozu çevirdi. “Düşünceyle eylemi aynı şey sayarsan, korkmuş birini suçlu; kızgın birini tehlikeli; bir hata yapmayı düşüneni hata yapmış sayarsın. Yine de gerçek tehditler konusunda önlem gerekir. Mesele sınırı doğru çizmek.”

{kahraman} bu yanıtı defterine yazdı. Çünkü tartışmayı kazanmak için değil, gerçekten anlamak için gelmişti. Atölyeden çıkmadan önce buzlu camdan küçük bir parça istedi. Lale Usta ona düz, kenarları güvenli biçimde yontulmuş bir örnek verdi. “Meclise götür,” dedi, “ama bir çözümü gösterirken yeni bir sorun yaratmadığından emin ol.”
---
@omurga
Gençler toplantısı, şehrin merkezindeki Yansımalar Sarayı'nda yapıldı. Sarayın içi öyle saydamdı ki yüksek tavanlardan karşı meydanın kuşları görülebiliyordu. Duvarlardaki düşünce yazıları da aynı ölçüde açıktı. {kahraman} içeri girdiğinde diğer okulların temsilcilerinin heyecanı üst üste bindi; yüzlerce kısa cümle havada geziniyor gibiydi.

Oturumu yöneten Meclis Başkanı Suzan Hanım gençlere tek tek söz verdi. İpek de okul gözlemcisi olarak gelmişti. Önce başka bir temsilci, şehirde yansımalar sayesinde kaybolan çocukların daha çabuk bulunduğunu anlattı. Bir diğeri, düşünce yazılarının kişiler tarafından yanlış anlaşılabileceğini söyledi. Her konuşmanın ardından duvarlar yalnızca konuşanın değil, dinleyicilerin de tepkilerini sergiliyordu.

{kahraman} kürsüye çıktığında aklından tek bir sözcük geçti: Kaç. Sözcük arkasındaki camda kırmızı harflerle belirdi. Salonda kısık gülüşmeler duyuldu. {kahraman} kürsünün iki kenarını tuttu. Ardından bilinçli olarak nefes aldı ve bekledi. Herkes onun korktuğunu biliyordu. Buna rağmen oradaydı.

“Az önce kaçmayı düşündüm,” dedi. “Ama kaçmadım. Demek ki aklımdan geçen şey yaptığım şeyi tek başına açıklamıyor.” Salondaki gülüşme durdu.
---
@omurga
Buzlu camı çıkardı. “Bu parçanın arkasında düşündüklerimi göremezsiniz. Belki size yalan söylerim, belki bir hediye saklarım, belki üzüldüğümü kimseye anlatmam. Bunların hepsi aynı davranış değildir.”

Başkanın arkasında şu sözcükler belirdi: Böyle bir duvar yasaları değiştirebilir. {kahraman} bunu okuyunca konuşmasının diğer yarısının da olduğunu hatırladı. “Fakat duvarlar her zaman zararlı değil. Acil yardım isteyen birini fark etmeyi kolaylaştırabilirler. Sorun, herkesin her an bütün düşüncelerini herkese göstermek zorunda olması.”

[[deyim:hr111_soz]] “Gizlilik olursa kötülük yapmak isteyenler de saklanır. O zaman ne yapacağız?”

{kahraman} hazır bir sloganla cevap vermedi. “Eylemlere, kanıtlara, yardım isteklerine ve açık kurallara bakacağız. Birinin yalnızca korkmuş olması, kötülük yaptığına kanıt değildir. Güvenliği bütün duvarları açık tutarak değil, gerektiği kadar bilgi kullanarak da sağlamayı denemeliyiz.”

Suzan Hanım bir not aldı. Meclis salondan görüş toplamaya karar verdi. İlk bakışta {kahraman} kazanmış gibi görünüyordu. Ancak ertesi sabah bir olay, konuşmasının ne kadar eksik olduğunu ona gösterecekti.
---
@omurga
Ertesi sabah bütün şehir aynı sözcükle uyandı: Tehlike. Merkez Meydanı'ndaki cam kubbe bir öğrencinin düşüncesini büyütmüş, sokaklardaki küçük paneller de onu tekrar etmişti. Kalabalık, meydanın güney merdivenine doğru koşmuştu. {kahraman} okula giderken köprü başındaki telaşı gördü. İnsanlar birini arıyor, bazıları da kapalı dükkânların kepenklerine vuruyordu.

Sözün sahibi Eren adında on üç yaşında bir çocuktu. Önceki gün mecliste konuşan bir temsilcinin küçük kardeşiydi. Meydanın altında çalışan ısı borularından birinin metal kapağı alışılmadık bir ses çıkarmıştı. Eren oradan geçerken gürültüyü duymuş, yıllar önce yaşadığı bir kazayı hatırlamış ve çok korkmuştu. Duvarda Tehlike yazısı belirince nöbetçi bunu acil sinyal sanmış, sistem düşünceyi meydanın tamamına aktarmıştı.

Mühendisler boruyu kontrol ettiğinde onarılması gereken küçük bir parça buldu; fakat o an için insanları tehdit eden bir arıza yoktu. Buna rağmen meydandaki izdihamda bir satıcının tezgâhı devrilmiş, iki kişi hafif yaralanmıştı. Eren'i tanıyanlar onun adıyla konuşmaya başlamıştı. Bazıları çocuğu dikkatli olmakla övüyor, bazıları herkesi gereksiz yere korkuttuğunu söylüyordu. Eren ise belediye odasında sessizce bekliyordu.
---
@omurga
{kahraman} olayın nasıl aktarıldığını öğrenmek için halk bilgi masasına gitti. Görevli ona güvenlik kayıtlarının herkesin incelemesine açık olduğunu söyledi. Görüntülerin birinde Eren yalnızca korktuğu için bir an durmuştu. Ekranın altında ise “Kaygı kaynaklı genel tehdit” yazıyordu. {kahraman} bu etiketin hem yargılayıcı hem de yanlış olduğunu düşündü. Çünkü küçük bir bakım ihtiyacı gerçekten vardı; sadece acil tahliye gerektirecek ölçüde değildi.

Arda Bey, “Korkuyu ciddiye almak doğrudur,” dedi, “ama korkuyla kesin tehlikeyi ayırmak da gerekir.” Bunun üzerine {kahraman} not defterine yeni bir soru yazdı: Yardıma ihtiyaç duyulan anı, kişiyi damgalamadan nasıl anlayabiliriz?

İpek'le o öğleden sonra meydanda karşılaştılar. İpek, “Bak, sistem olmasa kapağı kimse kontrol etmeyecekti,” dedi. {kahraman} başını salladı. “Doğru. Fakat Eren'in korkusu herkesin önünde ona karşı bir suçlama gibi kullanıldı. Biz bir yararı korurken bir zararı azaltabilir miyiz?” İpek ilk kez cevap vermeden önce düşündü.
---
@omurga
Arda Bey, iki kızın önerisiyle okulda gönüllü bir gözlem çalışması yapılmasını kabul etti. Ama bunun sınıf arkadaşlarının zihnini izleyen gizli bir deney olmayacağını özellikle söyledi. Çalışmaya katılacak öğrenciler bilgilendirilecek, istemeyenler dışarıda kalabilecek ve hiçbir özel düşünce kaydedilmeyecekti. Araştırmanın amacı, farklı uyarı sistemlerinin çocuklar üzerindeki etkisini anlamaktı.

{kahraman} ile İpek üç pano hazırladı. Birincisi eskisi gibi tüm duyguları gösteriyordu. İkincisi yalnızca kişinin kendi isteğiyle verdiği yardım çağrısını, üçüncüsü ise ortak alandaki doğrulanmış tehlike bildirimlerini gösteriyordu. Panolar gerçek düşünce akışına bağlanmamıştı; öğrenciler hazırlanan hayali senaryoları kullanıyordu. Böylece kimsenin mahremiyetine dokunmadan tasarımın mantığını sınayabildiler.

İlk senaryoda bir öğrenci sınavdan önce “Yapamayacağım” diyordu. Eski düzende bu cümle herkesin önüne düşüyordu. Gönüllü yardım panosunda ise öğrenci isterse rehberlik servisine mesaj gönderebiliyordu. İkinci senaryoda koridorda duman görülüyordu. Bu durumda kişisel düşünceye ihtiyaç duymadan, duman sensöründen gelen doğrulanmış uyarı panoya aktarılıyordu. Üçüncü senaryo en zorlusuydu: Bir çocuk kendini tehdit altında hissediyor ama korkusunu açıklamak istemiyordu.
---
@omurga
“Onu görmezden mi geleceğiz?” dedi İpek.

“Hayır,” dedi {kahraman}. “Yardım istemeyi kolaylaştıracağız. Ama ondan herkesin önünde açıklama yapmasını beklemeyeceğiz.”

Eren deneye katılmayı kabul etti. Kendisini herkesin tartıştığı olaydan söz ederken sesi titredi. Bir gün boyunca koridorlardaki yazılardan kaçtığını anlattı. “Beni iyi niyetle koruduklarını söyleyenler bile korkumu tekrar tekrar gösterdi,” dedi. “Bir kez korktuğum için her gün korkak ilan edilmiş gibi oldum.” Arkadaşları ona sorular sormak istedi. {kahraman}, Eren'in yalnızca istediği sorulara yanıt vereceğini önceden kararlaştırdıklarını hatırlattı.

Sonuçlar umdukları kadar basit değildi. Bazı öğrenciler eski sistemde daha güvende hissettiklerini söyledi; özellikle birinin yardım aradığını fark etmek istiyorlardı. Bazıları ise düşüncelerinin görülmesinden korktuğu için ortak alanlardan uzak durduklarını belirtti. {kahraman} bu iki grubu karşı karşıya getirmemeye çalıştı. “Herkesin aynı hissetmesi gerekmiyor,” diye yazdı sonuç bölümüne. “Önemli olan çözümün farklı ihtiyaçları hesaba katması.”
---
@omurga
Belediyeden deneyle ilgili haber gelince, yeni bir sorun çıktı. Bir cam üreticisi bütün şehre opak duvar kaplaması satmayı öneriyordu. Ürünün adı Mutlak Kalkan idi. Reklamlarında “Hiçbir düşünceniz görülmeyecek, kimse sizin hakkınızda hiçbir şey bilemeyecek” deniyordu. Slogan, {kahraman:ilgi} konuşmasından bir cümleyi bağlamından koparıp kullanıyordu.

{kahraman} öfkelendi. Özel yaşamı savunmuştu ama kimsenin yardım çağıramadığı bir şehir istememişti. İpek reklamı görünce ona mesaj gönderdi: “Sözlerin de duvarlardaki düşünceler gibi yanlış okunabiliyormuş.” {kahraman} önce bu cümleyi alay sanıp kızdı. Sonra İpek'in bir tehlikeyi haber vermeye çalıştığını fark etti.

İkisi Lale Usta'nın atölyesinde buluştu. Usta, ürünün örnek kaplamasını incelemişti. “Camı karartıyor, evet. Ama ısı uyarılarını da örtüyor,” dedi. “Bütün camların aynı işi yapması gerektiğini varsaymışlar. Oysa sınıf penceresiyle yangın çıkışının güvenlik işareti aynı şey değil.”

{kahraman} meclise yeni bir açıklama göndermek istedi. Bu kez ifadelerini daha dikkatli seçti: Kimsenin düşüncelerinin sürekli sergilenmemesi, acil durum iletişiminin kapanması demek değildir. Bize kişisel alan, doğrulanmış güvenlik uyarıları ve gönüllü yardım seçenekleri birlikte gereklidir.
---
@omurga
Günün sonunda reklam şirketi bir toplantı talep etti. {kahraman} tek başına gitmeyi düşündü fakat Arda Bey onlara reşit olmadıklarını ve böyle bir görüşmenin okulun rehberliğinde yürütülmesi gerektiğini söyledi. İki öğrenci kabul etti. Toplantıda şirket yöneticisi ürünlerinin her soruna çözüm olacağını söylediğinde {kahraman}, panoların çalışmasından örnek verdi. “Tek tasarımla bütün ihtiyaçları karşılayamayız,” dedi. “İnsanların güvenliği de özel alanı da gerçektir.”

Şirket yöneticisi ürünü değiştirmeyi değerlendireceğini söyledi. {kahraman} bunun yeterli bir söz olmadığını düşündü; yazılı güvenlik denetimi istediler. Şimdiye kadar birçok sorunu birinin iyi niyetine güvenerek çözmeye alışmıştı. Oysa kalıcı bir kural, yalnızca iyi insanların var olduğu günler için yapılmazdı.
---
@omurga
Meclis için hazırlanan deneyin sonuçları açıklanınca şehir gazeteleri aynı olayı birbirinden farklı manşetlerle verdi. Biri, “Çocuklar cam duvarları kaldırmak istiyor” dedi; öteki, “Yeni sistem tehlikeleri gizleyecek mi?” diye sordu. Oysa raporda böyle bir karar yoktu. {kahraman} gazete bayisinde iki başlığı yan yana görünce yüzü kızardı. Sanki söylediklerini geri alması bekleniyordu.

Arda Bey onu okul kütüphanesine çağırdı. Masaya gazeteleri, deneyin tamamını ve meclisin tutanağını koydu. “Bunları tek tek okumadan hangisinin doğru olduğunu söyleyebilir misin?” diye sordu.

“İkisi de eksik,” dedi {kahraman}. “Bir soruyu tek cevap gibi yazmışlar.”

“Öyleyse bizim de kendimizi kontrol etmemiz gerekir. Kendi raporumuzun tamamında neyi söylemediğimize bakalım.”

{kahraman} ve İpek raporu yeniden incelediler. Panoları sınayanların hepsi kendi okullarından gönüllü öğrencilerdi. Küçük çocukların, yaşlıların ve düşünce yazılarını okumakta zorlanan insanların görüşleri henüz alınmamıştı. Deneyden çıkan sonuçları bütün Cam Şehir'e uygulamak doğru olmazdı. {kahraman} bu eksikliği görmekten utandı. İpek ise gülümsedi. “Yanılma payımız olduğunu söylememiz, hiç çalışmadığımız anlamına gelmez. Tam tersine, buradan yeni sorular çıkar.”
---
@omurga
Birlikte şehrin engelli danışma kuruluna ve mahalle toplantılarına açık davet gönderdiler. Ama davet metninde katılmayanların isteksiz, korkak ya da bilgisiz sayılmayacağını da belirttiler. {kahraman} ilk kez insanların kendi hayatlarını ilgilendiren bir tasarımı değerlendirmeye davet edilmesinin, onlar adına düşünmekten ne kadar farklı olduğunu hissediyordu.

İlk toplantıya çok az kişi geldi. Bir kadın, “Evime gelen sağlık görevlisine düşüncemi göstermek isteyebilirim,” dedi. Yanında oturan yaşlı adam, “Ben her duvara yazılan cümleyi göremiyorum; yüksek sesli alternatif gerek,” diye ekledi. Başka biri geçmişte düşüncesi duvarda belirdiği için iş arkadaşları tarafından küçük düşürüldüğünü anlattı. {kahraman} bunları duydukça tek bir “mahremiyet” sözcüğünün herkes için aynı ihtiyaçları ifade etmediğini anladı.

Toplantı sonrasında görüşleri ad ve özel hikâyelerle değil, ihtiyaç kategorileriyle kaydettiler. İpek neden isim yazmadıklarını sorduğunda {kahraman}, “Bir sorun çözülsün diye konuşan insanların başka bir listede teşhir edilmesi gerekmez,” dedi. İpek dosyadaki ilk sayfaya büyük harflerle GEREĞİ KADAR BİLGİ yazdı. Bu, sonraki haftalarda tasarımlarının en önemli ölçütü olacaktı.
---
@omurga
Meclisin kararını bekledikleri günlerde {kahraman}, {yoldas:ilgi|bir arkadaşın} sırasının boşluğuna bakmaktan vazgeçemedi. Arkadaşının istemediği bir hikâyeyi onun adına anlattığını düşündüğünde rahatsız oluyordu. {yoldas:yalin|bir arkadaş} bir öğle arası okula kısa süreliğine geldiğinde onunla bahçedeki söğüt ağacının altında karşılaştı. Yanlarında kimse yoktu. Duvar panosu da o bölgede bakım nedeniyle kapalıydı.

“Senin yaşadığını kürsüde örnek verdim,” dedi {kahraman}. “Adını söylemedim ama yine de senden izin almalıydım.”

{yoldas:yalin|bir arkadaş} yerden küçük bir taş aldı, iki eli arasında çevirdi. “Biri benim adıma konuşunca hemen teşekkür etmek zorunda hissediyorum,” dedi. “Çünkü yardım etmek istiyor. Ama çoğu zaman nasıl hissettiğimi sormuyor.”

{kahraman} savunmaya geçmedi. “Özür dilerim.”

“Özrünü kabul ediyorum. Bir de şunu bilmeni istiyorum: Sınavdan korktuğum için okula gelmedim sanılıyor. Oysa insanların her gün korkumu görmesinden sıkıldım. Sınavı zaten bir gün sonra tekrar çözebilirdim.”

Bu fark {kahraman:belirtme} şaşırttı. Kendi anlattığı öyküde {yoldas:ilgi|bir arkadaşın} asıl sorunu korkuydu; onun anlattığında ise o korkunun herkes tarafından sahiplenilmesiydi. {kahraman} bir not çıkarmak üzere çantasına uzandı, sonra vazgeçti. “Bunu rapora yazmamı ister misin?” diye sordu.
---
@omurga
“Benim adımla değil. Ama insanların bazen yardım istemek için konuşacak zamanı kendilerinin seçmek istediğini söyleyebilirsin.”

{kahraman} söz verdi. Arkadaşlıklarının geri dönmesi için yasa çıkmasını beklemeleri gerekmediğini o gün anladı. Bazen atılan ilk adım bir savunma yapmak değil, karşı tarafı bitirmeden dinlemekti. {yoldas:yalin|bir arkadaş} söğüdün bir dalını hafifçe salladı; dalların arasından ışık süzüldü. İkisi sınavdan, şehirden ve camlardan başka şeylerden konuşmaya başladı: bir kitabın son sayfasından, tatilde gidilecek yayladan, rüzgârın sonbaharda niçin başka koktuğundan.
---
@omurga
Mecliste ikinci oturumdan önce genç temsilciler kendi aralarında bir toplantı yaptılar. Kimileri camları tamamen kapatma önerisinden yanaydı, kimileri yaşlı komşularının güvenlik kaygısını dile getiriyordu. Herkesin düşünceleri masanın etrafındaki duvarlara yansıdığı için tartışma hızla kişisel bir kavgaya dönüştü. Bir temsilci, başkasının aklından geçen Bunu anlamıyor sözünü görünce sandalyesini iterek kalktı.

{kahraman} da konuşmanın bir anında Keşke hepsi beni dinlese diye düşündü. Cümle büyük harflerle belirdi. Çevresindekiler susunca {kahraman} utandı. “Evet, bunu düşündüm,” dedi. “Ama böyle davranmak istemiyorum. Önce siz anlatın.”

Toplantının kalanında herkesin konuşması için sınırlı süre tanıdılar. Yanıt verecek kişi, önce karşı tarafın önerisini doğru anladığını kendi sözcükleriyle açıklayacaktı. Bu yöntem kavgayı hemen bitirmedi. Fakat “Benim söylediğim o değildi” diye başlayan düzeltmeler, geçmişteki gibi bir saldırıya dönüşmedi.

Akşam olunca önerilerini dört başlıkta değerlendirdiler: kimin hangi bilgiye erişeceği, bilginin ne kadar süre saklanacağı, yanlış kullanımın nasıl denetleneceği ve mağdur olduğunu düşünen insanların nereye başvuracağı. Başka bir öğrenci, “Bu sorular yasayı yavaşlatacak,” dedi. {kahraman}, “Belki yavaşlatacak,” diye kabul etti. “Ama sonradan başımıza gelecek haksızlıkları azaltabilir.”
---
@omurga
Masadaki en genç temsilci, on iki yaşındaki Nehir, konuşmalar bitmek üzereyken el kaldırdı. “Ben iki yıl önce düşüncelerimin görülmesini istiyordum,” dedi. “Çünkü yeni okulda kimseyle konuşamıyordum. Duvarımda Biri benimle oyun oynasın yazısını görünce biri yanıma geldi. Bugün ise sınavdan önce korktuğumu herkesin bilmesini istemiyorum. İnsanların isteği zamanla değişebilir mi?”

İpek hemen not aldı. “Öyleyse seçimin bir kez yapılıp ömür boyu sürmesi doğru olmayabilir. İnsanlar izinlerini değiştirebilmeli.”

{kahraman} bu cümleyi duyunca yasa taslağının en önemli eksik parçasını bulduklarını düşündü: Rıza, birinin yıllar önce imzaladığı ve artık hatırlamadığı bir kâğıt olamazdı. Anlaşılır, geri alınabilir ve baskı olmadan verilmiş olmalıydı. Çocuk meclisi o gece dağılırken herkesin üzerinde uzlaştığı tek şey, daha çok soru sormak gerektiğiydi.
---
@omurga
Meclisin ikinci toplantısında salonun duvarları eski düzende çalışıyordu. Başkan Suzan Hanım oturumu açarken kendi düşüncesi camda göründü: Çocuklar bizi yetişkinlerden daha dikkatli olmaya zorluyor. Bu kez salonda kimse gülmedi. Gençlerin hazırladığı dosya masalara dağıtıldı. Dosyanın ilk sayfasında üç kapı çizilmişti.

Birinci kapı özel alan adını taşıyordu. İnsanların evlerinde, kişisel görüşmelerinde ve okulun belirlenmiş alanlarında düşünce gösterimi {kelime:hr111_varsayilan} olarak kapalı olacaktı. Bir kişi kendi düşüncesini paylaşmak isterse bunu seçebilirdi. İkinci kapı gönüllü yardım idi. İhtiyaç duyan herkes, kime ve ne kadar bilgi vereceğini seçebileceği bir kanaldan yardım isteyebilecekti. Üçüncü kapı kamusal güvenlik idi. Ortak tehlikeler, mümkün olduğunca doğrulanabilir işaretlerle bildirilecek; acil müdahale için gerekli bilgiler, amacı ve süresi belli kurallarla ele alınacaktı.

“Ya biri sistemden yararlanıp zarar vermeye kalkarsa?” diye sordu meclis üyesi Kerem Bey.

{kahraman} sesini sakin tutmaya çalıştı. “Buna karşı kanıta dayalı {kelime:hr111_sorusturma} ve güvenlik süreçleri gerekir. **Bir düşüncenin herkese görünmesi güvenli bir soruşturmanın yerini tutamaz**. Üstelik insanlar öfkeli, korkulu veya kararsız olabilir; bunlar tek başına bir suç değildir.” {isaret:anahtar}
---
@omurga
İpek karşı görüşü de sundu. Birçok insanın saydam duvarlara alıştığını, sistemin bir gecede kaldırılmasının güvensizlik yaratabileceğini anlattı. {kahraman} onun sözünü kesmedi. Geçiş planına, kullanıcıların bilgi alacağı açık toplantıların ve bağımsız denetimin eklenmesini önerdi. Böylece değişiklikten korkanları cahil ya da kötü niyetli saymamış olacaklardı.

Oylama saatler sürdü. Bazı üyeler şehir geleneğini savundu. Bazıları, camların yıllardır çocukları utandırdığını ilk kez duymuş gibi şaşırdı. Bir üye yalnızca üç kapıyı değil, düşünce kayıtlarının saklanma süresini de sordu. {kahraman} ve İpek cevap veremedi. Bunun üzerine kuralın ayrı bir uzman grubu tarafından incelenmesi gerektiğini kabul ettiler. “Bilmiyoruz” demek, önerilerinin değerini azaltmadı; hangi konuda çalışılması gerektiğini belirledi.

Sonunda ilk değişiklikler oy çokluğuyla kabul edildi. Cam Şehir bir gecede opaklaşmadı. Okul koridorlarındaki panolar gönüllü yardım düzenine geçti, belediye ortak tehlike uyarılarını yeniden tasarlamaya başladı, özel evlerdeki yansımaları kapatma hakkı tanındı. Yasanın adı Üç Kapılı Cam Yasası oldu. {kahraman:ilgi} elindeki küçük anahtar sembolü, tartışmalar sırasında defalarca defterin kenarına çizilmişti.
---
@omurga
Yeni düzenden sonraki ilk pazartesi {yoldas:yalin|bir arkadaş} okula geldi. {kahraman} onu kantinin yanında gördüğünde hemen bütün olanları anlatmak istedi. {yoldas:yalin|bir arkadaş} ise önce çantasını yerine koydu, sonra “Bana normal bir gün ver,” dedi. {kahraman} sustu. Arkadaşının hayatı, onun konuşmasının zaferine dönüşmek zorunda değildi. Birlikte bahçede yürüdüler. {yoldas:yalin|bir arkadaş} sınavdan söz etmedi; {kahraman} da sormadı.

İpek'le aralarındaki yarış ise sessizce değişmişti. Sınıf temsilciliği konusunda zaman zaman tartışıyorlardı. Fakat birbirlerinin itirazını önceden dinlemeyi öğrenmişlerdi. İpek bir gün {kahraman:yonelme}, “Ben bütün düşünceler görünürse insanlar daha dürüst olur sanıyordum,” dedi. “Şimdi dürüstlüğün bazen insanın söylemeye hazır olmadığı şeyleri söylememesini de içerdiğini düşünüyorum.”

“Ben de bütün duvarlar kapanırsa rahatlarız sanmıştım,” dedi {kahraman}. “Eren'in olayında yardım uyarısının niçin önemli olduğunu gördüm.”

Lale Usta müzik kutusunu nihayet onarmıştı. {kahraman} kapağı açtı; içindeki küçük silindir dönüyor, yıllardır unutulmuş bir melodi birkaç kırık notadan sonra tamamlanıyordu. Babasının doğum günü akşamı, odalarının düşünce yansıtıcısını kapattı. Babası neden kapattığını sormadı. {kahraman} kutuyu masaya koydu. Babasının önce şaşkınlığı, sonra sevinci yüzünde belirdi; hiçbir yazı bu iki duyguyu onun yerini alarak anlatmıyordu.
---
@omurga
“Bunu nereden buldun?” dedi babası.

“Uzun bir hikâye,” diye cevap verdi {kahraman}. Sonra atölyeyi, meclisi ve tartışmaları anlattı. Babası bir süre dinledi. “O gün bana bir şey sakladığında gücenmiştim,” dedi. “Bana güvenmediğini düşündüm.”

“Sana güveniyordum. Sadece hediyeyi kendi zamanında vermek istedim.”

Babası başını eğdi. “Bir düşünceyi gördüğüm için nedenini bildiğimi sanmışım. Bunun için üzgünüm.”

{kahraman} o anda babasının yüzünde beliren ifadeyi camda görmek istemedi. Gerçek bir özrün, duvara yazılınca güçlenmediğini; bazen yalnızca duyulduğu yerde yeterli olduğunu anladı.
---
@omurga
Değişiklikler kabul edildikten sonra meclise bağımsız denetçi olarak görevlendirilen Selim Bey okulu ziyaret etti. Yeni sistemin tanıtımı için hazırlanan afişte büyük bir {kelime:hr111_kalkan} çizimi vardı. Altında Artık güvendesiniz yazıyordu. Selim Bey afişi okuyup {kahraman:yonelme} döndü. “Bunu nasıl biliyorsunuz?” diye sordu.

{kahraman} şaşırdı. “Yasa değişti. Özel alanlar açıldı.”

“Bu iyi bir başlangıç,” dedi Selim Bey. “Ama güvenli bir sistem olduğunu söylemek için onu sınamanız gerekir. Bir öğrenci yanlışlıkla eski ayarı açarsa? Bir görevli izin verilmeyen kayıtlara bakarsa? Bir çocuk yardım istemek ister de panoyu kullanamazsa?”

İpek kendini savunur gibi oldu. “Biz her ihtimali düşünemeyiz.”

“Zaten tek başınıza düşünmeniz beklenmiyor. Bunun için düzenli {kelime:hr111_denetim}, açık başvuru yolları ve farklı kullanıcıların katılımı gerekiyor.”

{kahraman} afişteki kesin cümlenin üzerini kalemle çizdi. Yerine Yeni düzenin güvenliğini birlikte izleyeceğiz yazdı. Selim Bey onayladı. “Bir kurumun yaptığı değişikliğin sonuçlarını da takip etmesi, sözünü ciddiye aldığını gösterir.”
---
@omurga
O hafta deneme panolarını kullanan öğrencilerden bildirim topladılar. Bazıları kişisel alanda rahat çalıştığını söyledi. Bir öğrenci, yardım düğmesine ulaşmak için çok yüksek bir ekrana uzanmak zorunda kaldığını bildirdi. Bir başkası sesli uyarıların işitme güçlüğü olan arkadaşına ulaşmadığını hatırlattı. Sorunların hiçbiri büyük bir skandala dönüşmemişti; tam da bu nedenle bunları erkenden düzeltmek mümkündü.

{kahraman}, çözüm getirdiği için kendisini kahraman sanmış olmaktan utandı. Gerçekte değişimi sağlayan çok sayıda insan vardı: korkusunu paylaşan Eren, eleştiri yapan İpek, konuşmaya hazır olmayan {yoldas:yalin|bir arkadaş}, kapalı camı gösteren Lale Usta, itiraz eden meclis üyeleri ve ihtiyaçlarını bildiren şehir sakinleri. Her biri yasada bir iz bırakmıştı.

Okul çıkışında ilk afişi söküp yenisini astılar. {kahraman} küçük bir kalkan sembolünün yanına açık bir kapı çizdi. “Sence bu iki işaret birbirine ters mi?” diye sordu İpek.

“Hayır,” dedi {kahraman}. “Kapıyı ne zaman açacağımızı seçebilmek için kalkanımız olmalı. Birini korumak, onu dünyadan ayırmak değildir.”
---
@omurga
Aylar sonra şehrin girişindeki kemer yenilendi. Kimse camı sökmedi. İnsanlar hâlâ birbirlerinin yüzüne, hareketine, sesine bakıyor; istediklerinde duvarlar üzerinden mesaj gönderiyordu. Ama kemerin üzerindeki eski sözün yanına ikinci bir satır yazıldı: Güven, bazen sormayı; bazen de cevabı beklemeyi bilmektir.

{kahraman} okul çıkışında yeni yazıyı okurken düşünce panosunu kontrol etti. Kimse onun aklından geçenleri görmüyordu. Yalnızca gönüllü bir mesaj kutusu vardı; birisi yardıma ihtiyacı olursa açabilecekti. O gün {yoldas:yalin|bir arkadaş} kutuyu kullanarak öğretmeninden ek çalışma saati istemişti. Kimseden korktuğunu saklaması gerekmemiş, ama bütün okula açıklamak zorunda da kalmamıştı.

Şehrin merkezinden geçen dar yolda bir kız çocuğu, yere düşen defterini topluyordu. {kahraman} yardım etmek için yaklaştı. “İstersen tutayım,” dedi. Çocuk başını sallayıp defterleri uzattı. {kahraman} onun ne düşündüğünü bilmiyordu. Yardım etmek için bilmesi de gerekmiyordu.

Gece evde müzik kutusunun anahtarını çevirdi. Metal kapağın kenarında, eskiden fark etmediği ince bir çatlak vardı. Lale Usta onarırken çatlağı saklamamış, küçük bir pirinç çizgiyle güçlendirmişti. {kahraman} annesine neden böyle bıraktıklarını sordu.
---
@omurga
“Çünkü bir şeyin onarılmış olması, hiç kırılmadığı anlamına gelmez,” dedi annesi.

{kahraman} şehrin yasasını düşündü. Eski düzenin verdiği yarar da zarar da hatırlanmalıydı. Yeni yasa kusursuz olmayacaktı; ileride başka sorunlar çıkacak, başka çocuklar yeni sorular soracaktı. Belki bazı kapılar yanlış zamanda kapanacak, bazıları gereğinden fazla açık kalacaktı. Önemli olan, kuralları yalnızca güçlü insanların değil, onlardan etkilenen herkesin tartışabilmesiydi.

Birkaç gün sonra okul duvarının eski kayıt bölümüne küçük bir sergi açıldı. Sergide yalnızca yeni yasanın güzel sonuçları değil, onunla ilgili itirazlar da yer aldı. {kahraman}, “Başarılarımızı gösterelim” diyen arkadaşına bunun neden önemli olduğunu anlattı: “Bir kuralın savunucuları eleştirileri saklarsa, yarın aynı eleştirilerin doğru çıktığını da fark edemezler.” Sergide Eren'in adı yoktu; örnek olaylar kişisel bilgi içermeyecek biçimde düzenlenmişti. İpek ise serginin yanına boş bir pano bıraktı. Pano üzerinde “Bu kuralda neyi geliştirmeliyiz?” yazıyordu. İlk not, yüksek bir ekrana uzanamayan küçük bir öğrenciden geldi. İkincisi, yaşlı komşusunun yardım sistemini kullanmayı öğrenmekte zorlandığını söyleyen birinden. {kahraman} her notu dikkatle okudu. Cam Şehir'in yeni yasası bir final değil, halkın birlikte sürdürdüğü bir çalışmanın başlangıcıydı.
---
@omurga
Müzik kutusu son notasını çaldı. {kahraman} kapağı yavaşça kapattı. İlk kez Cam Şehir'in güzelliğinin herkesin içini göstermesinde değil, insanların birbirini görmeye çalışırken birbirine alan bırakabilmesinde olduğunu düşündü. Bu düşünce duvara yazılmadı. {kahraman} yine de onun gerçek olduğunu biliyordu. Çünkü bir düşünceyi paylaşma hakkı kadar, onu kendine saklama hakkı da vardı. Şimdi ikisinin de değerini, üstelik başkalarının aynı hakkını gözeterek öğrenmişti.
