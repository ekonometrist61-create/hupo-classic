---
baslik: "Yıldız Terzisinin Haritası"
slug: "hr050-yildiz-terzisinin-haritasi"
fis_kodu: "HR-050"
tur: bilim
konu: gokyuzu_gozlem
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: masalsi
izinli_turler: [ben, arkadas, hayali]
deger_anahtarlari: [D6, D3]
yetiskin_uygun: false
tanitim: "Gökyüzünden bir düğme düşer. Yıldız Terzisi haritasını yeniden çizebilecek mi?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, kesif]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D3
  ogrenme_hedefleri:
    - {id: teleskop_hr050, tur: lexeme, etiket: "teleskop", yuva: hr050_teleskop, islev: first_hint}
    - {id: pusula_hr050, tur: lexeme, etiket: "pusula", yuva: hr050_pusula, islev: application}
    - {id: takimyildizi_hr050, tur: lexeme, etiket: "takımyıldızı", yuva: hr050_takimyildizi, islev: application}
    - {id: deyim_hr050, tur: idiom, etiket: "Kafası karışmak", yuva: hr050_kafasi_karismak, islev: application}
    - {id: kavram_hr050, tur: concept, etiket: "Gözlem ile yorum ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Düğme ne zaman düştü?", secenekler: [{id: A, metin: "Gece on ikide"}, {id: B, metin: "Sabah altıda"}, {id: C, metin: "Öğlen"}, {id: D, metin: "Akşam beşte"}], dogru: A, aciklama: "Saat kulesindeki akrep gece on ikiyi gösterirken düğme düştü."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Defne neden rahatladı?", secenekler: [{id: A, metin: "Yıldızların uzak cisimler, hayalî çizgilerin ise desen olduğunu bildiği için"}, {id: B, metin: "Terzinin çok yaşlı olduğu için"}, {id: C, metin: "Kardeşinin uyuduğu için"}, {id: D, metin: "Düğmenin altın olduğu için"}], dogru: A, aciklama: "Defne, astronomi bilgisiyle gökyüzündeki hayalî çizgileri gerçek yıldız bağlantılarından ayırabiliyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 5, metin: "Defne'ye göre takımyıldızı çizgileri nasıl görülmeli?", secenekler: [{id: A, metin: "Tek doğru değil, farklı hikâyelerle birleşebilen desenler olarak"}, {id: B, metin: "Gerçek yıldız bağları olarak"}, {id: C, metin: "Hiç görülmemesi gereken çizgiler olarak"}, {id: D, metin: "Yalnız gündüz görülen çizgiler olarak"}], dogru: A, aciklama: "Takımyıldızları kültürlere göre farklı hikâyelerle anlatılabilir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, metin: "Metinde geçen pusula ne işe yarar?", secenekler: [{id: A, metin: "Yönleri göstermeye yarar"}, {id: B, metin: "Yıldız çizer"}, {id: C, metin: "Düğme diker"}, {id: D, metin: "Ay'ı büyütür"}], dogru: A, aciklama: "Pusula, yönleri bulmada kullanılan bir araçtır."}
deyim_cumleleri:
  hr050_kafasi_karismak: "Bazen iyi niyetle verilen çok fazla öneri de insanın kafasını karıştırabilirdi."
---
@omurga
Kasabanın saat kulesindeki akrep, gece on ikiyi gösterirken gökyüzünden bir düğme düştü. Evet, gerçekten bir düğme: mercimek büyüklüğünde, ışıl ışıl, arkasında dört delik bulunan gümüş renkli bir düğme. {isaret:yildiz}

Düğmeyi bulan {kahraman}, onu bahçelerindeki masanın üzerine koydu. Bir taş kadar soğuktu ama parmaklarını çektiğinde masanın üzerinde ince bir ışık izi bırakıyordu. {kahraman} beşinci sınıfa gidiyordu; yıldızlarla ilgilenmeyi sever, bazen {kelime:hr050_teleskop} olan komşuları Gülseren Hanım'ın gözlemlerine katılırdı. Yine de gökyüzünden düğme düştüğünü hiçbir kitapta okumamıştı.

“Birileri göğe gömlek mi dikiyor?” diye güldü kardeşi {yoldas:yalin|bir arkadaş}.

Şaka gibi görünen söz, ertesi gece tuhaf biçimde gerçek oldu. {kahraman} pencereden baktığında karşı apartmanın çatısında uzun şapkalı birinin gümüş ipliklerle uğraştığını gördü. Yabancı kişi yukarı doğru ince bir iğne uzatıyor, yıldızların arasına ışıklı çizgiler örüyordu. Bir an sonra bir yıldız kümesindeki üç nokta yer değiştirdi. {kahraman} gözlerini ovuşturdu. Çizgiler yeniden göründüğünde gökyüzündeki şekil artık bildiği gibi değildi.
---
@omurga
Kardeşini uyandırmak için döndüğünde çatıdan bir ses yükseldi: “Dur! {kelime:hr050_pusula} kaybettim.”

{kahraman} koşarak balkona çıktı. Şapkalı adam kendini “Yıldız Terzisi” diye tanıttı. “İnsanların gece vakti bulduğu desenleri tamir ederim,” dedi. “Ama bu kez yıldızları işaretlediğim harita birbirine karıştı. Kaybolmadılar; benim çizgilerim yanlış yerlere gitti.”

{kahraman} önce onun gerçekten yıldızları yerinden oynattığını sandı. Terzi hemen açıkladı: “Ben yıldızların kendisini taşımam. Yeryüzünden bakanların hayalinde onları birleştiren çizgilere yama yaparım. Bu gece rüzgâr yüzünden haritam yanlışlıkla kuzey yerine doğuya döndü.”

Bu açıklama {kahraman:belirtme} rahatlattı. Çünkü astronomi kitaplarından yıldızların gökteki uzak cisimler olduğunu, insanların onlara çizdiği hayalî çizgilerin ise {kelime:hr050_takimyildizi} desenlerini oluşturduğunu biliyordu. Yıldız Terzisi masal dünyasından geliyor olabilirdi ama yıldızların gerçekten bir kumaşa dikili olmadığını o da biliyordu.
---
@omurga
Terzi, kendi haritasını düzeltene kadar kasabanın meydanında yapılacak “Yıldız Gecesi” etkinliğinde rehberlik edemeyeceğini söyledi. {kahraman} yardım etmeyi kabul etti. Ancak önce ailesine haber verdi. Annesi hayalî görünümlü terziyi pencereden gördüğünde epey şaşırdı. Gülseren Hanım'ı da çağırdılar; birlikte gözlemevindeki açık hava etkinliğine gideceklerdi.

Terzi, kasabanın dışındaki küçük tepeye varınca cebinden yedi ayrı ip makarası çıkardı. Kırmızı ip batıyı, yeşil ip doğuyu, mavi ip kuzeyi, sarı ip güneyi gösteriyordu. Geri kalan renklerin ne anlama geldiğini hatırlamıyordu. “Renkleri yeniden eşleyebiliriz,” dedi {kahraman}. “Ama gökyüzünün yönünü gerçekten nasıl belirleyeceğiz?”

Gülseren Hanım önce pusulayı gösterdi. “Gözlem yaparken bir araca güvenmek iyidir, fakat çevremizdeki işaretleri de anlamak gerekir.” Sonra gökyüzündeki yıldız desenlerinin yıl içinde ve gecenin saatine göre görünüşlerinin değiştiğini anlattı. Kutup Yıldızı'nın kuzey yönünü bulmada kullanılabildiğini, fakat onu bulurken doğru yıldız desenlerinden yararlanmak gerektiğini söyledi.
---
@omurga
{yoldas:yalin|bir arkadaş} hemen bir yıldızı gösterdi. “En parlak olan kuzey yıldızı değil mi?”

“Her zaman değil,” dedi Gülseren Hanım. “Parlaklıkla yönü karıştırmamalıyız.”

Yıldız Terzisi utandı. “Ben de haritamı tam öyle karıştırdım. En ışıklı deseni kuzey sandım.”

{kahraman}, gökyüzündeki Büyükayı desenini aramaya çalıştı. İlk bakışta bulamadı. Şehrin ışıkları yıldızları görmesini zorlaştırıyordu. Gülseren Hanım, gözlerinin karanlığa alışması için biraz beklemelerini istedi. Telefona bakarak geçen her dakikanın gözlerini yeniden parlak ışığa alıştırdığını fark edince {kahraman} ekranı kapattı. Bir süre sonra daha fazla yıldız seçebildi.

“Demek ki bazen görmek için acele etmemek gerekiyor,” dedi.

{yoldas:yalin|bir arkadaş}, sanki göğün içinden bir kapı açılmış gibi şaşırmıştı. İğnenin ince ışığı yıldızlara dokundukça gökyüzünde kuş, balık ve yolcu biçimleri görünüyordu. Ama bu hayalî çizimler gerçekte yıldızların birbiriyle komşu olduğu anlamına gelmiyordu. {kahraman} iki yıldızın gökyüzünde birbirine yakın görünse bile uzayda çok farklı uzaklıklarda olabileceğini hatırladı.
---
@omurga
Terzi, “Haritamı eski hâline çevirirsek herkes aynı şekli görecek,” dedi.

“Belki de farklı yerlerde farklı desenler görürler,” diye karşılık verdi {kahraman}. “İnsanlar gökyüzündeki yıldızları geçmişte başka başka hikâyelerle birleştirmiş. Senin çizgilerin tek doğru hikâye değil.”

Terzi bunu hiç düşünmemişti. Onun işinin her yıldızı tek bir örüntüye zorlamak değil, insanların göğe bakarken kurduğu hayallere alan açmak olabileceğini anladı. İğnesini indirdi ve şapkasından küçük bir defter çıkardı.

İlk sayfada eski bir harita vardı. Yanlış dönen kâğıtta, kuzey işareti sağ kenara gelmişti. {kahraman} sayfayı yere koyup pusula yönüne göre çevirdi. Terzi, çizgileri büyük bir ciddiyetle yeniden çizdi. Ancak bir çizgi hep yanlış yıldızın yanına gidiyordu. {yoldas:yalin|bir arkadaş} bunu fark etti: “Sen ipliği yıldızın üstüne değil, haritadaki işarete bağlıyorsun. Harita dönünce iğnen de yanlış dönüyor.”
---
@omurga
“Harita ile gökyüzünü ayrı ayrı doğrulayalım,” önerisinde bulundu Gülseren Hanım.

Bir süre hep birlikte çalıştılar. {kahraman} gözlem yaptığı yıldızları not etti, {yoldas:yalin|bir arkadaş} hayalî çizgileri kâğıda aktardı, terzi ise iplikleri onlara göre düzeltti. Herkesin görevi ayrıydı ama tek bir kişinin hatası diğerlerine anlatılmadan düzeltilemezdi. Terzi kendi karışıklığını kabul ettiğinde iş ilerledi.

Tepeye uzaktan okulun servis aracı geldi. Öğretmenler ve veliler Yıldız Gecesi için teleskopları getiriyordu. {kahraman}, kimsenin gökyüzündeki garip ipliklere çarpıp şaşırmaması için terziden onları toplamasını istedi. Terzi biraz alındı. “Bütün gece diktiğim işleri mi sökeyim?”

“Gerçek yıldızların arasına değil, insanların hayal ettiği çizgilere dokundun,” dedi {kahraman}. “Onların kendi hikâyelerini görebilmeleri için biraz boşluk bırakmak daha güzel olmaz mı?”

Terzi sessizleşti. İğnesini uzatıp fazla ipleri topladı. Gökte geriye yalnız yıldızların ışıkları kaldı. {kahraman}, çıplak göğe bakınca kâğıttaki desenden daha etkileyici olduğunu düşündü. Terzi ise ilk defa bütün yama işlerinin görünür olmak zorunda olmadığını kabul ediyordu.
---
@omurga
Etkinliğin başında Gülseren Hanım katılımcılara küçük bir oyun önerdi. Her öğrenci gökyüzünde seçtiği üç yıldızla hayalî bir şekil çizecekti. {kahraman} bir kuş kanadı, {yoldas:yalin|bir arkadaş} minik bir kayık çizdi. Bir arkadaşları bunları bambaşka bir biçimde gördü; yıldızların arasına bir anahtar şekli yerleştirdi. Kimse ötekinin çizimini yanlış saymadı. Yalnız yıldızların gerçek konumlarını kaydederken doğru gözlem yapmak gerektiğini konuştular.

{kahraman} teleskoptan Ay'a baktığında yüzeyindeki gölgelerin ne kadar belirgin olduğunu gördü. Terzi, “Oraya da düğme diksem?” diye sordu. {kahraman} güldü: “Ay'ın yüzeyinde bunlara ihtiyaç yok. Ama belki Ay'a bakarak bir hikâye yazabiliriz.”

Gecenin sonunda terzi {kahraman:yonelme} ilk düşen düğmenin eşini verdi. İki düğmeyi bir araya getirince üzerlerinde aynı dört delik olduğu görüldü. {kahraman} düğmelerin deliklerinden geçen çizgileri saydı. “Bunlarla bir takımyıldızı deseni kurabilir miyiz?” diye sordu.
---
@omurga
“Kurabilirsin,” dedi terzi. “Ama çizdiğin desenin hayal gücünün ürünü olduğunu da söyle.”

Bir sonraki hafta sınıfta öğretmenleri, {kahraman:ilgi} gözlem gecesini anlatmasını istedi. {kahraman} sunumuna “**Gökyüzünü okumak iki ayrı iştir**,” diye başladı. “Biri bilimsel gözlem; diğeri hayal kurmak. İkisi de güzeldir ama birbirinin yerine geçmez.” Sınıf, bu ayrımı anlamak için aynı yıldız fotoğrafının üzerine hem gök koordinatlarını hem de yaratıcı desenleri çizdi.

{yoldas:yalin|bir arkadaş} ise eve döndüklerinde kâğıttan bir “yıldız terzisi takımı” yaptı. İçine ip, karton ve küçük pusula koydu. Düğmelerin birini cebinde saklıyor, ötekini {kahraman:yonelme} emanet ediyordu. Her yeni ayda gökyüzünü gözlemek için birlikte bir tarih belirlediler. Bulutlu gecelerde yıldız göremeyince de eski gözlem notlarına dönüp karşılaştırma yapıyorlardı. Hava açık olduğunda aynı yıldızların farklı saatte nasıl yer değiştirmiş gibi göründüğünü fark ettiler.
---
@omurga
Bir akşam kasabanın saat kulesinden rüzgârla küçük bir ses geldi. {kahraman} başını kaldırdı. Çatıda hiç kimse yoktu, ama uzaktan birinin iğnesini çantasına yerleştirirken çıkardığına benzeyen bir tıkırtı duyuluyordu. {kahraman} gülümsedi. Gökyüzüne bakmak için artık terzinin dönmesini beklemesi gerekmiyordu. Yıldızlar oradaydı. Kendisi bakmayı öğrenmişti.

Gözleme hazırlık bir önceki haftadan başlamıştı. {kahraman} kütüphaneden gökyüzü atlası almış, haritadaki yıldızlarla telefondaki uygulamanın çizgilerini karşılaştırmıştı. İlk denemesinde doğu ile batıyı ters işaretlediği için gördüğü şekillerin hiçbiri kitaptakilere benzememişti. Üstelik telefonda seçtiği şehir yanlış olduğundan yıldızların konumları tutmuyordu. Bu küçük hata, Yıldız Terzisi'nin yaşadıklarını anlamasını kolaylaştırdı. Bir araç doğru da olsa ona yanlış bilgi verirsen çıkan sonuç da yanlış olabilirdi. {kahraman} not defterine “Araçları kullanmadan önce ayarlarını kontrol et,” diye yazdı. {yoldas:yalin|bir arkadaş} bunu görünce “Sen yıldızlara bile ödev veriyorsun,” diye takıldı. {kahraman} cevap vermedi, yalnız kalemini ona uzatıp bir yön oku çizmesini istedi.
---
@omurga
Gülseren Hanım'ın tepesine çıktıklarında havanın serinliğini tahmin etmemişlerdi. {kahraman} ince hırkasıyla titredi, annesi çantasından getirdiği atkıyı verdi. Terzi, yıldız iplerini düzeltme telaşı içinde yerdeki çiğ tanelerine basıyordu. Çimenler kayganlaşmıştı. {kahraman} ona “Biraz yavaşla,” dedi. Terzi ilk kez bir çocuktan uyarı duymaya alışık değildi. “Ben yüzlerce yıldır göğün eteklerini dikerim,” diye söylenince {yoldas:yalin|bir arkadaş}, “O zaman çimende nasıl yürüyeceğini de biliyor olman lazım,” dedi. Terzi kaymamak için durup bastığı yeri inceledi. {kahraman}, bilginin yaşla birlikte artabileceğini ama yeni bir koşulla karşılaşınca herkesin dikkat göstermesi gerektiğini düşündü.
---
@omurga
Terzi'nin haritasında en tuhaf şey çizgiler değildi. Bir köşede silinmiş bir isim vardı: “Yolcuların Dostu”. {kahraman} bunun bir takımyıldızı mı, yoksa terzinin kendi koyduğu bir ad mı olduğunu sordu. Terzi uzun süre cevap vermedi. Sonunda küçükken yolunu kaybeden bir yolcuya gökyüzünde bir işaret gösterdiğini, yolcunun da ona bu adı taktığını anlattı. O günden sonra, herkes kendisini gerekli görsün diye göğe daha çok işaret koymaya başlamıştı. Fakat işaretler çoğaldıkça insanların hangisini izleyeceğini bilemediğini fark etmişti. {kahraman} bunun neden üzücü olduğunu anlayabiliyordu.[[deyim:hr050_kafasi_karismak]]
---
@omurga
{yoldas:yalin|bir arkadaş}, “Öyleyse haritada en gerekli işaretler kalsın,” dedi. “Herkes bütün çizgileri bilmek zorunda değil.” Terzi buna karşı çıktı: “Birini silersem verdiğim emek boşa gider.” Gülseren Hanım, “Emek değerli,” dedi, “ama yaptığımız bir şeyin yararlı olmadığını öğrenirsek onu düzeltmek de emeğe saygıdır.” Terzi düşünmek için şapkasını çıkardı. Şapkasının içinden yedi renk iplik yerine küçücük yıldız haritaları döküldü. Bazıları aynı yıldızları değişik biçimlerde birleştiriyordu. {kahraman} onları bir araya getirince farklı kültürlerin gökyüzündeki desenlere neden değişik adlar verdiğini konuşmaya başladılar.

Yıldız Gecesi'nin başlamasına yarım saat kala beklenmedik bir olay çıktı. Okuldan gelen öğrenci gruplarından biri karanlıkta yan tepeye yürümek istedi. Görevliler, alanda önceden belirlenmiş güvenli yürüyüş yolunun dışına çıkmamalarını söyledi. Bir çocuk, “Kuzey tarafta daha güzel yıldız görünüyormuş,” diye itiraz etti. {kahraman} ona ışık kirliliğinin etkisini anlattı ama uzaklaşmanın güvenlik riskini değiştirmeyeceğini ekledi. Birlikte tepenin aydınlatması kontrollü bölümünde kaldılar. Yıldızları biraz daha az görseler de grup hâlinde güvenli bir gözlem yapabildiler. {kahraman}, bilimsel merakın bazen sınır tanımamayı değil, sınırları anlayarak araştırmayı gerektirdiğini düşündü.
---
@omurga
Gözlem başlamadan önce bulutlar geldi. İncecik sis çizgileri önce doğu ufkunu, sonra yıldızların bir kısmını kapattı. Terzi “Bütün hazırlık boşa gitti!” diye yakındı. Gülseren Hanım, hava olaylarının da gözlem planının bir parçası olduğunu söyledi. {kahraman}, grup için hazırlanan yedek çalışmayı hatırladı: Teleskop kullanılamazsa daha önce çekilmiş gökyüzü görüntüleri üzerinde araştırma yapılacaktı. Öğrenciler sınıfta yaptıkları haritalarla görüntülerdeki yıldızları eşleştirecek, sorularını bir sonraki gözlem tarihine saklayacaktı. {yoldas:yalin|bir arkadaş} bu düşünceyi beğendi. “Bulutların bile bir görevi var; bize B planını hatırlatıyorlar,” dedi.

Bulutlar biraz açıldığında sıra {kahraman:yonelme} geldi. Teleskobun ayarı yetişkin görevli tarafından yapılmıştı. {kahraman} önce baktığı gök cisminin ne olduğunu öğrenmek istedi. Yanında duran öğrenci, “Görüntüyü hemen çekelim,” diyordu. {kahraman} ise fotoğraftan önce çıplak gözle gördüğünü tarif etmeye çalıştı. Küçük parlak bir nokta, etrafında sanki daha zayıf ışıklar… Görevli, parlaklık ve şekil konusunda yanılabileceğini, bir teleskop görüntüsünde gözlem koşullarının önemli olduğunu açıkladı. {kahraman} gördüğünü olduğu gibi yazdı, sonra cihazın gösterdiği cismi öğrendi. Tahmininin tamamı doğru çıkmadı. Ama yanlışın nedenini öğrenmesi, doğru tahmin yapmaktan daha çok aklında kaldı.
---
@omurga
Terzi, gösteri bitince kendisine yardım eden üç kişiye birer hayalî sertifika dikti. {kahraman:ilgi} sertifikasında “Sabırlı Gözlemci”, {yoldas:ilgi|bir arkadaşın} sertifikasında “Dikkatli Soru Soran”, Gülseren Hanım'ınkinde “Yol Gösteren” yazıyordu. {kahraman} bu unvanlara güldü. Terzi kendi sertifikasını da hazırladı: “Hatalarını Düzeltmeyi Öğrenen”. Önce yazıyı küçük tuttu, sonra daha görünür bir yere işledi. Yanlış yapmış olmak onu küçültmüyordu. Hatasını saklamak için kurduğu yeni çizgiler ise gerçekten gökyüzünü karıştırmıştı. Onları kaldırdıktan sonra kendisini hafiflemiş hissetti.

Ertesi gün okulda {kahraman:ilgi} anlattıklarına herkes inanmadı. Bazıları yıldız terzisinin bir rüya olduğunu söyledi. {kahraman}, “Terziyi görmediyseniz onu gerçek kabul etmek zorunda değilsiniz,” diye cevap verdi. “Ama beraber gözlediğimiz gökyüzü hakkında soruları araştırabiliriz.” Sonra sınıfın iki sütun hazırlamasını önerdi: “Öyküdeki fantastik olaylar” ve “Gerçek dünyada doğrulayabileceğimiz bilgiler”. Birinci sütuna ışıklı ipliklerle desen çizmek, ikinci sütuna gökyüzünde yön bulma ve ışık kirliliği yazıldı. Öğretmen, hayal gücüyle bilimi birbirine düşman gibi görmemelerine sevindi. Biri soru sorulacak yeni dünyalar açıyor, öteki soruların hangisine nasıl yanıt bulunabileceğini gösteriyordu.
---
@omurga
{kahraman:ilgi} defterindeki en son sayfada ise ne harita ne de çizim vardı. Yalnızca küçük bir cümle: “Göğün dikişleri yıldızların arasında değil, onlara baktığımız hikâyelerde.” Kardeşi cümleyi okuyunca biraz kaşlarını çattı. “Yani terzinin gerçek iğnesi yok mu?” {kahraman}, “Masalda var,” dedi. “Gerçekteyse bizim kalemlerimiz ve sorularımız var.” {yoldas:yalin|bir arkadaş} ertesi gece kendi yıldız haritasını çizerken yıldızları yerlerinden oynatmaya kalkmadı. Yalnız kâğıdı çevirdi, yönünü düzeltti ve gökyüzünü yeniden gözledi.

Bahar geldiğinde yıldız gecesini tekrarladılar. Bu kez {kahraman} yeni gelen öğrencilere kendi öğrendiklerini anlattı, ama önce onlara gökyüzünde ne gördüklerini sordu. Bir çocuk üç yıldızı bir çiçek, bir başkası bir taç gibi çizdi. {kahraman} ikisinin resmini de panoya astı. Panonun altına bilimsel bilgilerle hayalî çizimlerin farklı renklerle yazıldığı küçük bir anahtar ekledi. Böylece kimse hangi bilginin gözlem, hangisinin yaratıcı yorum olduğunu karıştırmadı. Gülseren Hanım, “En iyi haritalar bazen nereye baktığını değil, nasıl baktığını da öğretir,” dedi. {kahraman} kuzeyi işaretleyen oku yeniden kontrol etti, sonra başını kaldırdı. Yıldızlar yerindeydi; değişen, onları okuyan gözlerdi.
---
@omurga
{yoldas:yalin|bir arkadaş}, defterin sonuna küçük bir yıldız çizip altına şunu yazdı: “Bir sorunun cevabını bulamadığımda onu silmeyeceğim. Daha iyi bir gözlem için saklayacağım.” {kahraman} kardeşinin cümlesini görünce gülümsedi.
---
@omurga
- Kavramlar: Yön, gökyüzü gözlemi, takımyıldızı, ışık kirliliği. - Dil: “Gökyüzüne yama yapmak” mecazı; gözlem ile yorum ayrımı. - Bilimsel not: Takımyıldızı çizgileri hayalîdir; yıldızların fiziksel olarak birbirine bağlandığı iddia edilmez.
