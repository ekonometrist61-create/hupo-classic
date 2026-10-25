---
baslik: "Müzedeki Eksik Parça"
slug: "hr048-muzedeki-eksik-parca"
fis_kodu: "HR-048"
tur: macera
konu: kanit_miras
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D1]
yetiskin_uygun: false
tanitim: "Tabakta bir parça eksik. Hırsızlık mı, yoksa koruma çalışması mı?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [kultur_miras, gizem]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D1
  ogrenme_hedefleri:
    - {id: konservasyon_hr048, tur: lexeme, etiket: "konservasyon", yuva: hr048_konservasyon, islev: first_hint}
    - {id: restorasyon_hr048, tur: lexeme, etiket: "restorasyon", yuva: hr048_restorasyon, islev: application}
    - {id: vitrin_hr048, tur: lexeme, etiket: "vitrin", yuva: hr048_vitrin, islev: application}
    - {id: deyim_hr048, tur: idiom, etiket: "Gözünü kurcalamak", yuva: hr048_gozunu_kurcalamak, islev: application}
    - {id: kavram_hr048, tur: concept, etiket: "Varsayım ile kanıt ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Bugün seramik tabağın ortasında ne vardı?", secenekler: [{id: A, metin: "Mavi bir daire"}, {id: B, metin: "Yeni bir resim"}, {id: C, metin: "Bir fotoğraf"}, {id: D, metin: "Küçük bir kuşun kanadı büyüklüğünde boşluk"}], dogru: D, aciklama: "Tabağın ortasında küçük bir boşluk vardı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Öğretmen neden yoldaşı susturmadı?", secenekler: [{id: A, metin: "Yoldaşın yanlış söylediğini kesinleştirdiği için"}, {id: B, metin: "Müzede ses yasak olduğu için"}, {id: C, metin: "Tabak kırıldığı için"}, {id: D, metin: "Düşünceyle kanıtın farklı olduğunu hatırlatmak istediği için"}], dogru: D, aciklama: "Öğretmen, düşünceyi kanıttan ayırmanın önemini göstermek istedi."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 9, metin: "Selma Hanım'ın sözüne göre araştırmacı ne yapmalıdır?", secenekler: [{id: A, metin: "Hep en heyecanlı açıklamayı seçmelidir"}, {id: B, metin: "Hiç açıklama yapmamalıdır"}, {id: C, metin: "En heyecanlı açıklama yerine en güçlü kanıtı seçmelidir"}, {id: D, metin: "Eserleri satmalıdır"}], dogru: C, aciklama: "Araştırmacı, heyecan verici ama kanıtsız açıklamalardan kaçınmalıdır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 3, metin: "Metinde geçen konservasyon ne demektir?", secenekler: [{id: A, metin: "Bir eseri satma işlemi"}, {id: B, metin: "Eserin bozulmasını önlemeye yönelik koruma çalışması"}, {id: C, metin: "Eseri müzeye götürme"}, {id: D, metin: "Yeni bir eser yapma"}], dogru: B, aciklama: "Konservasyon, eserin zamana ve etkenlere karşı korunmasıdır."}
deyim_cumleleri:
  hr048_gozunu_kurcalamak: "{kahraman:ilgi} gözünü kurcalayan ikinci mesele, fotoğrafın güvenilirliğiydi."
---
@omurga
Müzedeki seramik tabak dün tamdı. Bugünse ortasında, küçük bir kuşun kanadı büyüklüğünde boşluk vardı.

{kahraman}, {kelime:hr048_vitrin} karşısında durup bir kez daha baktı. Müze gezisine gelmeden önce öğretmenlerinin gönderdiği fotoğrafta, on altı parçadan birleştirilmiş mavi desenli tabağın tam ortasında sekiz köşeli bir yıldız bulunuyordu. Şimdiyse yıldızın bir köşesi yoktu.

“Gördün mü?” diye fısıldadı arkadaşı {yoldas:yonelme|bir arkadaşa}. “Parça kayıp.”

{yoldas:yalin|bir arkadaş}, vitrin kenarındaki açıklama levhasına eğildi. “Belki de hep böyleymiştir.”

“Fotoğrafıma bak.”

{kahraman:ilgi} telefonundaki görüntü, kuşkusunu doğruluyordu. Tabağın eksik yerinde eskiden turkuaz bir parça görünüyordu. Üstelik vitrinin kenarına yeni bir not yapıştırılmıştı: Koruma çalışmaları sürmektedir.

“Biri çalmış olabilir,” dedi {yoldas:yalin|bir arkadaş}. Sesi yükselince yanlarında duran küçük bir çocuk başını çevirdi. {kahraman} birden rahatsız oldu. Müze salonu sessizdi; söyledikleri bir kişiyi gereksiz yere kuşku altında bırakabilirdi.
---
@omurga
“Olabilir,” diye düzeltti onu. “Ama bu sadece varsayım. Henüz bilmiyoruz.”

O sabah beşinci sınıf öğrencileri, kent müzesinin yeni açılan “Toprağın Belleği” bölümünü geziyordu. Salonun girişinde kalın duvarlı eski bir fırının maketi, yanında da çömleklerin hangi aşamalardan geçerek yapıldığını anlatan bir pano vardı. {yoldas:ilgi|bir arkadaşın} ilgisini çeken, müzedeki eşyalardan çok kırmızı kurdeleyle çevrilmiş “Girilmez” kapısıydı. Kapının üzerinde, ince fırçalarla çalışan bir el çizimi görülüyordu.

“Kesin gizli oda,” dedi {yoldas:yalin|bir arkadaş}.

“Büyük ihtimalle çalışma odası,” diye karşılık verdi {kahraman}. “Ama bakmadan hiçbir şeyi kesin söylemeyelim.”

Öğretmenleri Selma Hanım, çocukların fotoğrafa ve tabağa sırayla bakmalarını istedi. Sonra sınıfın önünde üç soru sordu: “Neyi gördünüz? Ne düşündünüz? Hangisini kanıtlayabilirsiniz?”

{kahraman} gördüğü şeyleri sıraladı: Fotoğraftaki parça bugün yerinde değildi. Vitrinde yeni bir açıklama vardı. Müze çalışanlarının kapalı bir bölümü bulunuyordu. {yoldas:yalin|bir arkadaş} “çalınmış olabilir” diye düşündüğünü söylediğinde öğretmen onu susturmadı; yalnızca düşünceyle kanıtın farklı olduğunu hatırlattı. {isaret:ipucu}
---
@omurga
“Bir şey kaybolduğunda aklımıza ilk gelen açıklama, doğru açıklama olmak zorunda değil,” dedi. “Merakımızı koruyalım, ama kimseyi suçlamayalım.”

Öğrenciler iki gruba ayrıldı. Bir grup çömlek yapımını öğrenirken {kahraman}, {yoldas:yalin|bir arkadaş} ve yeni arkadaşları Melis, müze görevlisi Aslı Hanım'dan bilgi almak için izin istedi. Aslı Hanım onları danışma masasındaki ziyaretçi defterinin yanına götürdü. Günün en yoğun saatinde bile sorularına zaman ayırmaya çalışıyordu.

“Ortadaki seramik parçası neden yok?” diye sordu {kahraman}.

Aslı Hanım, “Bu soruyu fark etmenize sevindim,” dedi. “Peki sizce bir eser neden vitrinden çıkarılabilir?”

“Temizlemek için,” dedi Melis.

“Başka müzeye götürmek için,” diye ekledi {yoldas:yalin|bir arkadaş}.

“Zarar gördüyse onarmak için,” dedi {kahraman}.

“Üçü de bazı durumlarda mümkün. Sizin gördüğünüz parça, {kelime:hr048_konservasyon} ve {kelime:hr048_restorasyon} çalışmalarında inceleniyor.”
---
@omurga
{kahraman} bu iki sözcüğün birbirine benzediğini fark etti. Aslı Hanım, korumanın eserin bozulmasını önlemeye; restorasyonun ise gerekli durumlarda belgeli, kontrollü müdahaleye odaklandığını açıkladı. Bir nesneyi eski hâline getirmek için her boşluğu rastgele doldurmak doğru değildi. Bazen eksik alan açıkça görünür bırakılırdı.

“Yani parçayı hemen yapıştırmayacak mısınız?” diye sordu {yoldas:yalin|bir arkadaş}.

“Önce neden ayrıldığını anlamamız gerekir. Kullanılacak malzemenin esere zarar vermeyeceğinden emin olmalıyız. Bir de yapılan işlemleri kayıt altına alırız.”

Bu yanıt {yoldas:belirtme|bir arkadaşı} biraz hayal kırıklığına uğrattı. Gizli oda sandığı yerde çalışanların uzun uzun ölçüm yaptığı, fotoğraf çektiği ve rapor yazdığı anlaşılıyordu. Fakat {kahraman:ilgi} merakı artmıştı. Ona göre asıl gizem, bir parçayı bulmak değil, küçük bir seramik parçasına neden bu kadar özen gösterildiğiydi.
---
@omurga
Aslı Hanım bir eğitim etkinliği düzenlediklerini söyledi. Öğrenciler isterlerse müzenin öğretim atölyesinde, gerçek eser yerine hazırlanmış seramik kopyalarıyla birleştirme çalışması yapabileceklerdi. Selma Hanım kabul edince üç arkadaş atölyeye geçti. Masalarda numaralandırılmış seramik parçalar, fotoğraflar ve üzerinde desenlerin devam ettiği kartonlar duruyordu.

{yoldas:yalin|bir arkadaş} hemen büyük parçaları bir araya getirmeye girişti. {kahraman}, bazı parçaların kenarlarının tam uyuşmadığını gördü.

“Dur, kırılabilir,” dedi.

“Bunlar zaten kopya.”

“Yine de zorlamaya gerek yok.”

Atölye sorumlusu Mert Bey, öğrencilere bir kural verdi: Önce gözlem, sonra deneme. Parçaları yapıştırmak yoktu; yalnızca kuru yerleştirme yapacaklardı. {kahraman} kenar çizgilerini izledi, Melis aynı renkteki desenleri grupladı, {yoldas:yalin|bir arkadaş} de şekillerin dönük yönlerini karşılaştırdı. İlk on dakikada yalnızca dört parçayı yerleştirebildiler.

“Bu hızla müze kapanır,” diye söylendi {yoldas:yalin|bir arkadaş}.
---
@omurga
Mert Bey güldü. “Aceleyi eser değil, saat hisseder. Tarihî bir nesnede hızlı olmak değil, dikkatli olmak önemlidir.”

{kahraman} iki küçük parça arasındaki ilişkiyi fark etti. İkisinde de kuş tüyüne benzeyen ince siyah çizgiler vardı. Bir parçayı döndürdüğünde çizgiler birleşti.

“İşte!” dedi. “Yıldızın altında bir kuş çizimi varmış.”

Fotoğrafın küçük ekranında görünmeyen desen, ellerindeki büyütülmüş kopyada ortaya çıkmıştı. Öğrenciler tüylerin yönünü izleyerek üç parçayı daha buldu. Ancak sekizinci parça ortada yoktu. Kutudaki parçaları iki kez saydılar. Numaralar birden ona kadar gidiyordu ama yedi numara yoktu.

“İşte gerçek kayıp parça,” dedi {yoldas:yalin|bir arkadaş}. “Atölyede de bir şey eksik!”

{kahraman}, kutunun yanındaki listeyi kontrol etti. Yedi numaranın karşısında küçük bir not bulunuyordu: Bu parça örnek çalışma için ayrılmıştır.
---
@omurga
“Yok değil,” dedi {kahraman}. “Başka yerde. Biz yine önce kötü ihtimali düşündük.”

Mert Bey, eksik parçanın neden masada olmadığını açıkladı. Amaç, öğrencilerin eksikle karşılaşınca süreci nasıl yöneteceklerini görmekti. Eksik bilgi olduğu hâlde sonuç uydurmak mı, yoksa bir süre belirsizliği kabul etmek mi daha doğruydu?

Melis, parçalardan birine biraz daha yakından bakmak için masadan eğildi. Çatlak boyunca yapıştırıcıya benzeyen parlak bir iz gördü.

“Bunu kim tamir etti?” diye sordu.

Mert Bey, izlerin eğitim kopyasının eski onarımına ait olduğunu söyledi. Sonra gerçek müze eserlerinde kullanılan malzemelerin neden belgelenmesi gerektiğini anlattı. Yıllar sonra başka bir uzman nesneyi incelerken hangi kısmın eski, hangi kısmın daha sonra eklendiğini ayırt edebilmeliydi. Yoksa eserin hikâyesi değişebilirdi.

Bu düşünce {kahraman:ilgi} hoşuna gitti. İnsanlar anılarını deftere yazdığı gibi, müzeler de eserlerin geçmişini kaydediyordu. Bir kırık yalnızca kusur değildi; bazen nesnenin başından geçenlerin işaretiydi.
---
@omurga
Öğleden sonra gruplar yeniden büyük salonda buluştu. Selma Hanım her gruptan gördüğü bir nesneyle ilgili üç cümle yazmasını istedi: Kesin bildiği şey, henüz bilmediği şey ve araştırmak istediği yeni soru. {yoldas:yalin|bir arkadaş} kâğıdına şöyle yazdı:

Bildiğim: Seramik parça koruma çalışması için çıkarılmış.

Bilmediğim: Parça ne zaman yerine dönecek?

Yeni sorum: Bir müze, bir nesnenin aslıyla yeni eklenen bölümünü ziyaretçiye nasıl anlatmalı?

{kahraman} kendi sayfasına, müzenin yalnızca eski eşya saklamadığını yazdı. O gün, tarihin de bakım istediğini anlamıştı.

Tam çıkacakları sırada Aslı Hanım onlara yeni hazırlanan bir bilgi kartı gösterdi. Üzerinde tabağın fotoğrafı, ayrılan parçanın yakın çekimi ve yapılan işlemlerin kısa açıklaması bulunuyordu. Kart ertesi gün vitrinin yanına konulacaktı. Ziyaretçiler boşluğa bakıp yanlış bir sonuca varmadan önce süreci öğrenebileceklerdi.
---
@omurga
“Bizim fark ettiğimiz şey buna yardımcı oldu mu?” diye sordu Melis.

“Aslında çalışma zaten sürüyordu,” dedi Aslı Hanım. “Ama sizin sorularınız bize ziyaretçinin neleri bilmek istediğini gösterdi. Bu da önemli.”

{yoldas:yalin|bir arkadaş} müze kapısında bir an durdu. “Bugün hiç hırsız yakalayamadık,” dedi.

“Çünkü hırsız yoktu,” diye cevap verdi {kahraman}.

“Yine de maceraydı. En zor kısmı, hikâyenin sonunu baştan uydurmamakmış.”

Selma Hanım gülümsedi. “Araştırmacı olmak bazen en heyecanlı açıklamadan vazgeçip en güçlü kanıtı seçmektir.”

{kahraman} eve dönerken telefonundaki eski fotoğrafı silmedi. Yeni çektiği fotoğrafla yan yana koydu. İlkinde tabak tamdı; ikincisinde bir boşluk vardı. Ama artık ikinci fotoğraf ona eksik bir hikâye gibi görünmüyordu. Tam tersine, daha önce bilmediği bir bölüm açılmıştı.
---
@omurga
Akşam küçük kardeşi “Müzede ne buldun?” diye sorduğunda {kahraman}, “Bir parçanın neden yerinde olmadığını öğrendim,” dedi.

“Kayıp mıymış?”

“Hayır. Korunuyormuş.”

Kardeşi bu farkı anlamak için biraz düşündü. {kahraman} da ona eğitim atölyesindeki kuş çizimini gösterdi. İkisi masada kâğıttan bir yapboz yaptı. Kardeşi acele edip yanlış parçayı yerine sıkıştırınca {kahraman} gülerek elini tuttu.

“Önce kenarlara bakalım,” dedi. “Bir şeyin uymasını istemek, gerçekten uyduğu anlamına gelmez.”

O günkü gezi aslında iki hafta önce sınıfta başlayan bir tartışmanın devamıydı. Sosyal bilgiler dersinde Selma Hanım, bir tabağın fotoğrafını tahtaya yansıtmış ve “Bu nesne kime aittir?” diye sormuştu. Kimileri onu yapan çömlekçiye, kimileri satın alan kişiye, kimileri de bulunduran müzeye ait saymıştı. {kahraman} el kaldırıp, “Belki de hikâyesi hepimize aittir,” demişti. Öğretmen, bu cümlenin üzerinde durmalarını istemişti. Çünkü tarihî bir eser, özel mülkiyet ve ortak kültürel değer gibi farklı yönlerden ele alınabilirdi. Şimdi vitrinin önünde dururken {kahraman}, o dersteki sorunun yalnızca bir sınav sorusu olmadığını fark ediyordu. Bir nesneyi koruyamayan insanlar onun hikâyesini de yitirebilirdi.
---
@omurga
Gezi sırasında sınıfın bir başka bölümü seramik üretim videolarını izledi. Öğrenciler toprağın suyla yoğrulduğunu, şekillendirildiğini, kurutulduğunu ve uygun koşullarda fırınlandığını gördü. {yoldas:yalin|bir arkadaş}, “O kadar ısıdan çıkıp vitrinde duruyor, sonra küçücük bir yerinden ayrılıyor,” diye söylendi. Aslı Hanım, seramiklerin çok uzun ömürlü olabileceğini ama ani sıcaklık değişimleri, yanlış taşıma ve eski onarımların onlara zarar verebildiğini açıkladı. “Sağlam görünmekle hiç zarar görmemek aynı şey değil,” dedi. Melis hemen not aldı: “Dış görünüş, tek başına yeterli kanıt değildir.” Bu cümle biraz önceki hırsızlık varsayımlarına da uyuyordu.

[[deyim:hr048_gozunu_kurcalamak]] Öğretmeninin gönderdiği görüntü geçen yılki katalogdan alınmıştı. Katalogdaki tabak aynı eser miydi? Deseni birbirine benzeyen iki tabak olamaz mıydı? {kahraman} önce fotoğrafın altında bulunan küçük numarayı okudu: KM-218. Vitrinin kenarındaki levhada da KM-218 yazıyordu. İki görüntünün aynı esere ait olduğuna artık daha çok güvenebilirdi. “Böyle düşünmeye alışmak istiyorum,” dedi. {yoldas:yalin|bir arkadaş}, “Her şeyin numarasını mı ezberleyeceksin?” diye takıldı. “Hayır, bir iddiaya neden inandığımı bilmek istiyorum.”
---
@omurga
Atölyede Melis'in önüne gelen küçük parça herkesi yanıltmıştı. Desen aynıydı ama parçanın dış kıvrımı ortadaki boşluğa tam oturmuyordu. {yoldas:yalin|bir arkadaş} onu çevirdi, {kahraman} diğer köşeyle karşılaştırdı. İlk bakışta doğru görünen parçanın aslında başka bir tabağın kopyasından alındığı ortaya çıktı. Mert Bey, “Bu küçük deneme, benzer olmakla aynı olmak arasındaki farkı anlatıyor,” dedi. “Bir hikâyenin iki ayrıntısı birbirine uyabilir; ama ikisi birden aynı olayın parçası olmayabilir.” {kahraman}, dedektif kitaplarını neden sevdiğini hatırladı. İyi bir dedektif, yalnızca işine gelen ipucunu seçmezdi; düşüncesine uymayan ayrıntıyı da hesaba katardı.
---
@omurga
Yemek molasında {yoldas:yalin|bir arkadaş} birden sustu. İlk başta “çalınmış” derken sesini fazla yükselttiğini hatırlamıştı. Salonda çalışan güvenlik görevlisi onu duymuş muydu? Arkadaşlarıyla otururken “Birisi bir eşyam kayboldu diye beni suçlasa çok üzülürdüm,” dedi. Melis, “Sen kimseyi adlandırmadın,” diye karşılık verdi. “Ama yine de kulağa kötü gelebilir.” Üçü, müzeye dönünce doğru bilgi öğrendiklerini görevliyle de paylaşmaya karar verdi. {yoldas:ilgi|bir arkadaşın} özür dilemesi için öğretmenin onu zorlaması gerekmedi. Güvenlik görevlisinin yanına gidip “Az önce yanlış bir şey varsaydık; şimdi öğrendik,” dedi. Görevli, “Sormak iyidir, ama birilerini suçlamadan sormak daha iyidir,” diye cevap verdi. {yoldas:yalin|bir arkadaş}, sorumluluk duygusunun yalnızca büyük hatalarla ilgili olmadığını o gün anladı.
---
@omurga
Öğleden sonraki sunumda gruplar eserleri için küçük birer “bilgi levhası” tasarladı. {yoldas:yalin|bir arkadaş}, tabağın ne kadar eski olduğunu büyük harflerle yazmak istedi. {kahraman}, tam tarih bilinmiyorsa kesin yıl vermenin yanlış olacağını söyledi. Melis, “O zaman tahmini tarih aralığını belirtiriz,” dedi. Levhaya “Yaklaşık” sözcüğünü eklemek, onları daha az bilgili göstermiyor; bilgiyi daha dikkatli kullandıklarını gösteriyordu. Bir başka grup, eserin bütün boşluklarına hayalî parçalar çizmişti. Mert Bey, bunu sanat çalışması olarak beğendi fakat bir müze levhasında varsayımsal çizimlerin açıkça işaretlenmesi gerektiğini anlattı. “Hayal kurmak güzeldir,” dedi, “yalnızca hayalle bulguyu birbirine karıştırmamalıyız.”
---
@omurga
{kahraman} evine dönünce anneannesinin eski bir fincanını hatırladı. Fincanın kulpu yıllar önce kırılmış, anneannesi onu içmek için değil, çiçek tohumlarını saklamak için kullanmaya başlamıştı. {kahraman}, fincanı neden atmadığını sorduğunda anneannesi, “Deden ilk maaşıyla almıştı,” dedi. “Benim için değeri artık yalnızca içindeki çayla ilgili değil.” {kahraman} bir müze görevlisi gibi fincana bakmadı; ama onda da bir hikâye saklı olduğunu anladı. Her eski eşya müzelik değildi, her kırık eşya da çöpe gidecek değildi. Önemli olan geçmişe ve kullanılan nesnelere düşünmeden davranmamaktı.
---
@omurga
Ertesi hafta sınıf, müzeye yazdığı teşekkür mektubuna bir öneri ekledi. {kahraman} ile arkadaşları, çocukların “Neden burada boşluk var?” diye sorabilecekleri küçük, anlaşılır bir etiket hazırlanmasını istedi. Öğretmen mektubu göndermeden önce tüm sınıfa okudu. Öneride görevlilere emir verilmiyor, bilgileri için teşekkür ediliyordu. {yoldas:yalin|bir arkadaş} kendisine ait cümleyi ekledi: “Merak eden çocuklar hemen en kötü sonucu düşünmesin diye açıklama yararlı olabilir.” İki gün sonra müzeden kısa bir yanıt geldi. Ziyaretçi levhasının hazırlanmakta olduğunu, önerilerinin de değerlendirmeye alındığını söylediler. {kahraman}, bir sorunun cevap bulmasının bazen yeni bir sorumluluk başlattığını düşündü: Doğru bilgiyi başkalarına da anlaşılır biçimde iletmek.

O akşam {kahraman} defterinin arka kapağına küçük bir not yazdı: Merak, cevap aramaktır. **Kanıt, cevabın sağlam basacağı yerdir**. Sonra iki fotoğrafın altına aynı cümleyi ekledi: Boşluk görünce önce sor.
---
@omurga
{kahraman}, arkadaşlarının bir hafta sonra aynı esere tekrar bakmasını önerdi. Müze bu kez yeni açıklama kartını yerleştirmişti. Kartın kenarında çalışmanın başlangıç tarihi, parçanın incelendiği bölüm ve ziyaretçilerin sorularını iletebilecekleri bir iletişim noktası yazıyordu. {kahraman}, vitrinin önünde duran iki kişinin yeni açıklamayı okuduğunu gördü. Birisi, “Demek tamir edildiği için alınmış,” dedi. Diğeri, “Hayır, önce inceleniyor; belki hemen yerine koymayacaklar,” diye düzeltti. {kahraman} ikisinin de doğru bilgiye ulaşmaya çalışmasına sevindi. Bazen bir etiketteki iki cümle bile yanlış bir söylentinin önüne geçebilirdi.

{yoldas:yalin|bir arkadaş}, ziyaretçi defterine aceleyle “Çok güzeldi” yazıp çıkacakken durdu. Cümlesinin altına şunu da ekledi: “Atölyede eksik parça bulmacasını sevdim. Başta bir hırsızlık olduğunu düşünmüştüm, şimdi önce kanıt toplamayı öğreniyorum.” Melis de kendi notunda seramiğin kuş desenini anlattı. Aslı Hanım, çocukların notlarını okuyup gülümsedi: “Bir müzenin en güzel yanı, ziyaretçilerinin sorularını değiştirebilmesidir.” Üç arkadaş çıktıklarında vitrindeki boşluk hâlâ aynı yerdeydi. Değişen, onların o boşluğa bakarken düşündükleriydi.
---
@omurga
- Sözcükler: Kanıt, varsayım, konservasyon, restorasyon, teşhir. - Okuduğunu anlama: Kesin gözlemle olası açıklamayı ayırt etme; kaynak sorgulama. - Değerler: Sabır, kültürel mirasa saygı, kimseyi kanıtsız suçlamama. - Kullanılabilecek etkileşim: “Gördüm / düşündüm / kanıtladım” üçlü eşleştirme kartı.
