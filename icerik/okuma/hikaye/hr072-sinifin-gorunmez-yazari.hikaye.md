---
baslik: "Sınıfın Görünmez Yazarı"
slug: "hr072-sinifin-gorunmez-yazari"
fis_kodu: "HR-072"
tur: gizem
konu: iyilik_mahremiyet_iletisim
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D15]
yetiskin_uygun: false
tanitim: "Panoya imzasız bir not asıldı. Kimin yazdığını bulmak mı önemli, yoksa iyiliğin kendisi mi?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [dayanisma, kesif]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D15
  ogrenme_hedefleri:
    - {id: imzasiz_hr072, tur: lexeme, etiket: "imzasız", yuva: hr072_imzasiz, islev: first_hint}
    - {id: soylenti_hr072, tur: lexeme, etiket: "söylenti", yuva: hr072_soylenti, islev: application}
    - {id: gonulluluk_hr072, tur: lexeme, etiket: "gönüllülük", yuva: hr072_gonulluluk, islev: application}
    - {id: deyim_hr072, tur: idiom, etiket: "Sözünü kesmek", yuva: hr072_soz_kesmek, islev: application}
    - {id: kavram_hr072, tur: concept, etiket: "Mahremiyet ve iyilik ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "İlk notun altında ne yoktu?", secenekler: [{id: A, metin: "İmza"}, {id: B, metin: "Tarih"}, {id: C, metin: "Resim"}, {id: D, metin: "Kenar çizgisi"}], dogru: A, aciklama: "Notun altında imza yoktu; yalnızca köşede mavi bir yıldız vardı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 7, metin: "Kutunun kuralı neden önemliydi?", secenekler: [{id: A, metin: "Kimse isim yazmaya zorlanmıyordu; katılım isteğe bağlıydı"}, {id: B, metin: "Herkes isim yazmak zorundaydı"}, {id: C, metin: "Kutu yalnızca öğretmen içindi"}, {id: D, metin: "Notlar ödül için yazılıyordu"}], dogru: A, aciklama: "Kutuya not bırakmak isteğe bağlıydı ve kimse adını yazmaya zorlanmıyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 9, metin: "Nazan Hanım'a göre bir iyiliğin değeri neye bağlıdır?", secenekler: [{id: A, metin: "Panoya asılmasına bağlı değildir"}, {id: B, metin: "Ancak not yazılırsa değerlidir"}, {id: C, metin: "Yalnız öğretmenin gördüğü iyiliklerde vardır"}, {id: D, metin: "Notların sayısına bağlıdır"}], dogru: A, aciklama: "İyilik, panoda görünmese de değerini korur."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 11, metin: "Metinde geçen söylenti ne anlama gelir?", secenekler: [{id: A, metin: "Doğrulanmamış, dolaşan haber ya da iddia"}, {id: B, metin: "Bir tür kitap"}, {id: C, metin: "Bir çeşit bayrak"}, {id: D, metin: "Bir oyun kuralı"}], dogru: A, aciklama: "Söylenti, kanıtı olmadan kulaktan kulağa yayılan bilgidir."}
deyim_cumleleri:
  hr072_soz_kesmek: "Bir öğrenci bir dakikalık küçük bir anı anlatacak, diğeri sözünü kesmeden dinleyecekti."
---
@omurga
Altıncı sınıf panosunda ilk not pazartesi sabahı ortaya çıktı. Beyaz bir kâğıda küçük, düzgün harflerle şöyle yazılmıştı: Dün teneffüste düşen kitaplarını kimse görmeden topladığını gördüm. Yaptığın iyilik gözden kaçmadı. {isaret:kalp}

Sınıf başkanı {kahraman} notu görünce durdu. Altında imza yoktu. Kimin için yazıldığı da belirtilmemişti. Yalnızca sağ alt köşede minik bir mavi yıldız çizilmişti. Arkadaşı {yoldas:yalin|bir arkadaş}, "Kesin biri şaka yapıyor," dedi. {kahraman}, "Şaka olsa neden teşekkür etsin?" diye sordu. İkisi de cevap bulamadı.

Teneffüste haber bütün sınıfa yayıldı. Bazıları notun kendisi için yazıldığını düşündü, bazıları kimin bıraktığını merak etti. Sınıfın en sessiz öğrencilerinden Zeynep panoya uzun uzun baktı ama hiç konuşmadı. {kahraman} onun yüzündeki küçük gülümsemeyi gördü; bu gülümsemenin ne anlama geldiğini anlayamadı.
---
@omurga
İlk nottan önce sınıfta pek çok küçük kırgınlık birikmişti. Grup çalışması sırasında bazı öğrenciler söz kesiyor, teneffüste oyun kuranlar hep aynı arkadaşlarını çağırıyordu. {kahraman} bunları görüyordu ama nasıl değiştireceğini bilmiyordu. Bir gün Zeynep defterini yere düşürdüğünde birkaç kâğıt savruldu. {kahraman} yardım etmek için eğildiğinde Zeynep "Ben toplarım," dedi. Sesindeki telaş, çevresindeki herkesin bakmasından rahatsız olduğunu gösteriyordu. {kahraman} kâğıtları izinsiz okumadan toparladı. Sonra hiçbir şey olmamış gibi konuşmayı sürdürdü. O an mahremiyete saygının bazen çok küçük davranışlarda saklı olduğunu fark etti.

Mavi yıldızlı ilk notu okuduğunda da benzer bir duygu yaşadı. Yazı, birinin iyi davranışını görmüş ama onun adını herkesin önünde söylememişti. {kahraman} bunu önce anlaşılmaz buldu. İyilik yapan birinin tanınması hoş olabilirdi. Fakat her öğrenci öne çıkmak istemeyebilirdi. Bazıları güzel bir davranışının büyük bir gösteriye dönüşmesinden rahatsız olabilirdi. Nazan Hanım, "Övgü de kişiye göre farklı hissedilebilir," dedi. "Bu yüzden **güzel niyet kadar karşımızdakini anlamak önemlidir**." {kahraman} o günden sonra arkadaşlarına teşekkür ederken onların nasıl hissettiğine daha çok dikkat etmeye başladı.
---
@omurga
Ertesi hafta ikinci not geldi: Bir arkadaşın konuşurken onu bölmeyip dinledin. Bazen dinlemek en güzel yardımdır. Bu kez köşede yine mavi yıldız vardı. {yoldas:yalin|bir arkadaş}, "Bence yazarı bulmalıyız," dedi. {kahraman} önce bu fikre katıldı. Bir gizem vardı ve onu çözmek eğlenceli olabilirdi. Ama sınıf rehber öğretmeni Nazan Hanım'a danıştıklarında farklı bir soru duydu.

"Yazarı bulursanız ne kazanacaksınız?" diye sordu öğretmen. {yoldas:yalin|bir arkadaş}, "Gizemi çözmüş olacağız," dedi. Nazan Hanım, "Peki kişi adını vermek istemiyorsa onun kararına saygı gösterecek misiniz?" diye devam etti. Sınıf sessizleşti. {kahraman} ilk kez notların bir oyun değil, birinin kişisel tercihi de olabileceğini düşündü.

Üçüncü not daha da ilginçti: Yalnız kalan bir arkadaşını oyuna çağırdın. Belki gününün en iyi anı buydu. Panonun önünde toplanan öğrenciler birbirlerine bakıyordu. Kim kiminle oynamıştı? {yoldas:yalin|bir arkadaş} hemen tahminler üretmeye başladı. {kahraman} bu kez onu durdurdu. "Kim olduğunu bulmak zorunda değiliz," dedi. "Notun anlattığı şeyi konuşabiliriz."
---
@omurga
Sınıf kendi arasında küçük bir karar aldı: Notlar kimseyi utandırmıyorsa ve saygılıysa panoda kalacaktı. Fakat {kelime:hr072_imzasiz} yazarı bulmak için çantalara bakılmayacak, kimsenin el yazısı karşılaştırılmayacak, fotoğraf ya da mesajlar izinsiz incelenmeyecekti. Nazan Hanım bu kararı destekledi. "Merak güzel," dedi. "Ama her merak, başka birinin özel alanına girme hakkı vermez."

{kahraman} notları okudukça sınıftaki davranışlara daha çok dikkat etmeye başladı. Önceden teneffüste kimin kiminle oyun oynadığını fark etmezdi. Şimdi yalnız oturanları, yardım edenleri, bir sözle arkadaşını sevindirenleri görüyordu. Bir sabah yere düşen boya kalemlerini birlikte toplayan iki öğrenciyi izledi. "Bunu panoya yazabiliriz," diye düşündü. Sonra durdu. "Ama onlar ister mi?" diye sordu kendi kendine.
---
@omurga
{yoldas:ilgi|bir arkadaşın} aklına notun yazarı hakkında çeşitli tahminler geliyordu. Bir gün panonun yakınındaki boya kalemlerinde mavi bir kalem gördü. "İşte kanıt!" diye fısıldadı. {kahraman}, "Sınıftaki herkes aynı kalemi kullanabilir," dedi. {yoldas:yalin|bir arkadaş} ikinci ipucunu gösterdi: Notlar hep sabah geliyordu. "O zaman erkenden gelen biri," dedi. {kahraman} yeniden karşı çıktı: "Belki bir önceki gün bırakılıyordur." İki arkadaş küçük bir tartışmaya girdi. Sonunda Nazan Hanım, "Bir davranışı anlamak için insanı gizlice takip etmek gerekir mi?" diye sordu. {yoldas:yalin|bir arkadaş} hayır demek zorunda kaldı. Merakı güçlüydü ama yöntemi doğru değildi.

Bir gün teneffüste {yoldas:yalin|bir arkadaş}, arkadaşlarından biriyle şakalaşırken "Kim yazdıysa yakalayacağım," dedi. Yakınlarındaki Zeynep birden sessizleşti. {kahraman} bunu gördü ama nedenini anlamaya çalışmadı. Daha sonra {yoldas:yonelme|bir arkadaşa}, "Yakalayacağım kelimesi sanki yanlış bir şey yapılmış gibi duruyor," dedi. {yoldas:yalin|bir arkadaş} duraksadı. "Öyle demek istemedim," diye karşılık verdi. "Sadece merak ediyorum." {kahraman}, "O zaman merak ettiğini söyle ama kimseyi rahatsız edecek bir oyun kurma," dedi. {yoldas:yalin|bir arkadaş} bu uyarıya kızmadı. Kendisinin de bir sır paylaşmak istemediği zamanlar olduğunu hatırladı.
---
@omurga
İkinci not sınıfta farklı bir tartışma başlattı. "Dinlemek neden iyilik sayılsın?" diye sordu bir öğrenci. "Hiçbir şey yapmıyorsun ki." Zeynep elini kaldırdı. "Bazen biri konuşurken sözünü kesmemek, onu gerçekten duyduğunu gösterir," dedi. Nazan Hanım herkese ikişerli konuşma etkinliği yaptırdı.[[deyim:hr072_soz_kesmek]] Sonra anlatan kişi, dinlenmenin nasıl hissettirdiğini söyleyecekti. {yoldas:yalin|bir arkadaş} etkinliğin sonunda, "Ben dinlerken aslında çok şey yapıyormuşum," dedi. {kahraman} güldü. "Evet, en azından arkadaşının sözünü bitirmesine izin veriyorsun."

Sınıfta uzun süredir çekingen duran Meryem, üçüncü notun asıldığı gün {kahraman:ilgi} yanına geldi. "Bence bazı güzel davranışların fark edilmesi iyi," dedi. "Ama bazen isim yazılınca herkes o kişiye bakıyor." {kahraman} onun ne demek istediğini anladı. Meryem, kendisiyle ilgili bir not yazılmasını istemediğini açıkça söyledi. {kahraman} bu tercihe saygı göstereceklerine söz verdi. Etkinlik kuralları hazırlanırken "Kişi istemiyorsa adını paylaşma" maddesi eklendi. Nazan Hanım bu cümlenin yalnız panoya değil, sınıfın günlük ilişkilerine de uyduğunu belirtti.
---
@omurga
Bu düşünce onu farklı bir fikre götürdü. Sınıf panosunun yanına boş bir kutu koydular. Üzerine İyilik Fikri Kutusu yazdılar. İsteyen öğrenciler, bir arkadaşını incitmeden ve özel bilgi paylaşmadan sınıfta gördükleri güzel davranışlar hakkında kısa not bırakabilecekti. Hiç kimse isim yazmaya zorlanmayacaktı. İlk gün kutuya yalnız iki kâğıt geldi. Sonraki hafta sayı arttı.

İyilik Fikri Kutusu'nun hazırlanması sandıkları kadar kolay olmadı. {yoldas:yalin|bir arkadaş} büyük, parlak bir kutu istiyordu. {kahraman} küçük, sade bir kutunun yeterli olacağını düşünüyordu. Zeynep ise kutunun herkesin erişebileceği bir yerde durmasını önerdi. Sonunda eski bir karton kutuyu birlikte kapladılar. Üzerine mavi yıldızlar çizdiler ama ilk notun yazarına ait olduğunu iddia etmediler. Bu yıldız artık tek bir kişiyi temsil etmiyordu; sınıfın birlikte seçtiği bir simgeydi. {kahraman}, kartonu düzeltirken bir şeyin anlamının insanlar onu nasıl kullandıkça değişebildiğini fark etti.
---
@omurga
Kutunun yanında küçük bir yönerge vardı. "İstersen yaz; yazmak istemiyorsan da sorun değil." Bu cümleyi Zeynep önermişti. {yoldas:yalin|bir arkadaş} başta anlamamıştı. "Herkes yazarsa daha çok notumuz olur," diyordu. Nazan Hanım, {kelime:hr072_gonulluluk} bir etkinliği gerçekten iyi kıldığını anlattı. İyilik için bile olsa zorunlu katılım, bazı çocukların kendilerini baskı altında hissetmesine neden olabilirdi. {kahraman}, kutunun kalabalık görünmesindense herkesin rahat hissetmesini daha önemli buldu.

{yoldas:yalin|bir arkadaş} başta bu fikri sıkıcı buldu. "Artık herkes not yazabilir," dedi. "Görünmez yazarın sırrı kalmadı." {kahraman} gülümsedi. "Belki de mesele sır değildi," dedi. "Belki iyi şeyleri daha çok görmekti." {yoldas:yalin|bir arkadaş} cevap vermedi ama kutuya ilk notunu o yazdı: Bugün biri sıraya girmeyi bekleyen arkadaşına yer verdi. Bunu fark ettim.
---
@omurga
İlk hafta gelen notlardan biri yalnızca şunu söylüyordu: Bugün biri beni güldürdü. {kahraman}, kimin güldürdüğünü ve neden güldüğünü merak etti. Ama notun yazarının ayrıntı vermemeyi seçtiğini düşündü. Diğer notta ise Bahçedeki küçük kâğıdı çöp kutusuna atan arkadaşımı gördüm yazıyordu. Sınıf bu iki davranışı konuştu. Biri başkasının duygusunu değiştirmiş, diğeri ortak alanı temiz tutmaya yardım etmişti. İkisi de gösterişsizdi. {yoldas:yalin|bir arkadaş}, "Görünmez yazarın notları gibi," dedi.

Bir cuma günü panoda hiç yeni not yoktu. {kahraman} hayal kırıklığına uğradı. "Belki kimse artık ilgilenmiyor," diye düşündü. Nazan Hanım bunun üzerine çocuklardan gün içinde fark ettikleri küçük iyilikleri akıllarından geçirmelerini istedi. Pek çok öğrenci örnek buldu ama hiçbiri yazmamıştı. Öğretmen, "Bir davranışın değerli olması için panoya asılması gerekmez," dedi. {kahraman} rahatladı. Kutunun amacı not sayısı toplamak değildi. İnsanların çevrelerine farklı gözle bakmasına yardımcı olabilirdi; görünmeyen iyilikler de varlığını sürdürebilirdi.
---
@omurga
Zeynep aynı hafta okul kütüphanesinde daha küçük sınıftan bir öğrenciyle karşılaştı. Çocuk aradığı kitabı bulamıyordu. Zeynep, kütüphane görevlisinden yardım istemesini önerdi; sonra görevliyle birlikte doğru rafı bulmalarına yardımcı oldu. Öğrenci teşekkür etti. Zeynep bu olayı panoya yazmayı düşünmedi. Çünkü kendisi için yeterince güzel bir andı. Eve giderken, insanın bir davranışını başkalarının görmesinin bazen hoş, bazen de gereksiz olabileceğini düşündü. İyilik tek bir biçimde yapılmıyordu.

{yoldas:ilgi|bir arkadaşın} aklına yeni bir fikir geldi: Kutudaki notları haftanın sonunda sayacak, en çok not yazan kişiye ödül vereceklerdi. {kahraman} hemen itiraz etti. "İsimsiz notlara nasıl puan vereceğiz?" {yoldas:yalin|bir arkadaş}, "İmza atarlar," dedi. Nazan Hanım soruyu değiştirdi: "Bu ödül insanların davranışını nasıl etkiler?" Zeynep, bazı öğrencilerin yalnız ödül almak için not yazabileceğini söyledi. Başka bir öğrenci, "İyi davranışlar yarış olursa biri daha az yazdı diye kendini kötü hissedebilir," dedi. {yoldas:yalin|bir arkadaş} bir süre düşündü. Sonunda puan tablosu yapmaktan vazgeçti. Bunun yerine herkesin katılabileceği bir teşekkür günü önerdi.
---
@omurga
Teşekkür günü için sınıf renkli kartlar hazırladı. Kartların üzerinde kişi adları yazmak zorunlu değildi. Bir kartta "Birlikte çalışmak güzeldi", diğerinde "Dinlediğin için teşekkürler" yazıyordu. Bazı öğrenciler kartları kendilerine vermek istemedi; bazıları arkadaşlarına özel olarak iletti. Nazan Hanım, herkesin tercihine saygı gösterdi. {kahraman} ilk kez bir etkinliğin iyi geçmesi için herkesin aynı şeyi yapmasının gerekmediğini gördü. Ortak amaç, farklı yollarla da gerçekleştirilebilirdi.

O sırada okulda küçük bir {kelime:hr072_soylenti} yayıldı: Mavi yıldızlı notların yazarı belirli bir öğrenciydi. Bazıları bunu kesinmiş gibi anlatmaya başladı. {kahraman} söylentiyi duyunca rahatsız oldu. {yoldas:yalin|bir arkadaş} bile bir an "Acaba doğru mu?" diye sordu. Nazan Hanım sınıfla konuşarak birinin kimliği hakkında doğrulanmamış iddialar yaymanın arkadaşlık ilişkilerine zarar verebileceğini anlattı. Eğer bir öğrenci anonim kalmayı seçmişse bunu bozmak için başkalarını sıkıştırmak doğru değildi. Sınıf, notun yazarı hakkında tahmin yürütmeyi bırakma kararını yeniden onayladı.
---
@omurga
Bir süre sonra kötü bir şey oldu. Kutudan çıkan bir kâğıtta bir öğrencinin adı yazılmış, ardından onu utandırabilecek bir ifade eklenmişti. {kahraman} kâğıdı panoya asmadan Nazan Hanım'a gösterdi. Öğretmen, iyi niyetli bir etkinliğin başkalarını incitmek için kullanılmasına izin vermeyeceklerini anlattı. Sınıf kurallarını yeniden gözden geçirdi. Notların olumlu, saygılı ve kişisel sınırları koruyan içerikler taşıması gerekiyordu.

Zeynep bu konuşma sırasında elini kaldırdı. "Birinden söz etmek istemiyorsak kendi duygumuzu yazsak olur mu?" diye sordu. Nazan Hanım, "Elbette," dedi. "Birinin adını vermeden teşekkür duygusunu anlatabilirsiniz." Ertesi gün panoda yeni bir not vardı: Bugün kendimi yalnız hissettiğimde biri yanıma oturdu. Teşekkür ederim. Bu notun köşesinde yıldız yoktu. {kahraman} bunun kimin yazdığını merak etmedi; önemli olan duygunun sınıfa ulaşmasıydı.
---
@omurga
Ay sonuna doğru panonun renkleri değişti. Başlangıçta yalnız mavi yıldızlı beyaz kâğıtlar varken şimdi farklı renklerde küçük kartlar vardı. Birinde sabır, diğerinde saygı, bir başkasında cesaret yazıyordu. {yoldas:yalin|bir arkadaş} her teneffüste panonun önünde durup yeni notları okuyordu. Bir gün {kahraman:yonelme}, "Bence insan başkasını mutlu etmeye başlayınca kendi de mutlu oluyor," dedi. {kahraman} onun gülümseyişine bakıp başını salladı.

Okulun başka sınıfları da bu panoyu merak etti. Bazı öğretmenler benzer bir etkinlik düzenlemeyi düşündü. Nazan Hanım önce çocukların izinlerini ve mahremiyet kurallarını konuştu. "Bir iyi davranışı kutlamak için kimin yaptığına dair her ayrıntıyı paylaşmak gerekmez," dedi. Sınıf hazırladığı küçük rehberde bu cümleyi özellikle vurguladı.
---
@omurga
Söylentinin yayıldığı gün Zeynep teneffüste kütüphaneye gitti. {kahraman} onu rafların arasında yalnız buldu. "İyi misin?" diye sordu. Zeynep omuz silkti. "İnsanların başkaları hakkında konuşması bazen yorucu," dedi. {kahraman} kimin ne yazdığını sormadı. Bunun yerine, "İstersen burada biraz oturabiliriz," diye karşılık verdi. İkisi bir süre sessizce kitaplara baktı. Zeynep sonunda "Bazen biri beni fark etsin istiyorum, bazen de kimse bakmasın," dedi. {kahraman} başını salladı. Bu duygunun tanıdık olduğunu fark etmişti. Bir arkadaşın aynı anda hem görülmek hem de rahat bırakılmak isteyebileceğini yeni öğreniyordu.

Ertesi gün {kahraman}, panoda kullanılan kelimelerle ilgili bir öneri getirdi. "İyilik" sözcüğünü herkes aynı şekilde anlamıyordu. Bazıları büyük yardımları, bazıları küçük davranışları düşünüyordu. Sınıf, örnekleri birlikte konuştu: yere düşen kâğıdı toplamak, birini dinlemek, grup çalışmasında söz hakkı vermek, ortak eşyayı korumak. Nazan Hanım, yardım teklif ederken karşı tarafın gerçekten yardım isteyip istemediğini sormanın önemli olduğunu da ekledi. İyi niyet her zaman doğru yöntemi kendiliğinden getirmeyebilirdi. {kahraman} bunu Zeynep'in yere düşen defterini topladığı günü hatırlayarak anladı.
---
@omurga
Sınıfta fark edilen bir başka durum da sessiz öğrencilerin yorumlarının az duyulmasıydı. {yoldas:yalin|bir arkadaş}, konuşmayı çok sevdiği için bazen arkadaşlarını istemeden bastırıyordu. Nazan Hanım küçük bir konuşma çemberi kurdu. İsteyen sırayla fikrini söyledi; konuşmak istemeyen pas geçebildi. {yoldas:yalin|bir arkadaş} kendi sırası gelmediğinde dinlemeye çalıştı. İlk başta beklemek zor geldi. Sonra uzun süredir az konuşan bir arkadaşının sınıftaki paylaşımlarla ilgili ilginç bir öneri getirdiğini duydu. "Herkesin fikrini duymayınca bazı iyi fikirleri kaçırıyormuşum," dedi. {kahraman} ona gülümsedi.

Mavi yıldızlı notların gelmediği günlerden birinde sınıf beklenmedik bir teşekkür aldı. Okulun temizlik görevlisi, bazı öğrencilerin koridoru düzenli bıraktıklarını ve kullandıkları eşyaları yerlerine koyduklarını fark etmişti. Nazan Hanım bu teşekkürün öğrencilere iletilmesi için izin aldı. {kahraman}, "Bu davranışları kim yaptı?" diye sormadı. "Demek hepimiz kullandığımız alanlara daha dikkat etmeye başlamışız," dedi. {yoldas:yalin|bir arkadaş}, teşekkürün bir kişiye ödül vermekten farklı olmasını sevdi. Ortak alanı korumak bir yarış değil, birlikte yaşamanın parçasıydı.
---
@omurga
Bir pazartesi panoya büyük bir kâğıt asıldı. Üzerinde bir çizelge vardı: solda görmek, ortada sormak, sağda saygı göstermek. {kahraman} bu üç sözcüğü sınıfa açıkladı. Önce arkadaşının durumunu fark etmek, sonra ona neye ihtiyacı olduğunu sormak, ardından verdiği cevaba saygı göstermek. {yoldas:yalin|bir arkadaş} bir örnek verdi: "Biri yalnız oturuyorsa hemen onu zorla oyuna çekmek yerine oynamak isteyip istemediğini sorabilirim." Zeynep bu örneği duyunca başını kaldırdı. "Bence güzel," dedi. Çünkü birinin yanında bulunmak ile onu zorlamak arasında önemli bir fark vardı.

Nazan Hanım yeni kartlarla küçük bir canlandırma etkinliği yaptı. Bir kartta, "Arkadaşın çalışma sırasında sessiz kalıyor" yazıyordu. Öğrenciler farklı yorumlar söyledi: sıkılmış olabilir, yorulmuş olabilir, düşünüyordur. Öğretmen, birinin davranışına bakarak duygusunu kesin bilemeyeceklerini anlattı. {kahraman} bunu ilk gün Zeynep'in gülümsemesini yorumlamaya çalıştığında da yaşamıştı. Bir gülümseme, bir sırrın kanıtı değildi. {yoldas:yalin|bir arkadaş} bile bunu anladı. "Demek yazarı bulmak için yüzlere bakmak da işe yaramaz," diye şakalaştı; sonra "Zaten aramıyoruz," diye ekledi.
---
@omurga
Dönem ortasında okulda bir dayanışma kampanyası düzenlendi. Öğrenciler kullanılabilir durumdaki kitapları gönüllü olarak paylaşacaktı. {kahraman}, iyilik panosunda kampanyayı tanıtmak istedi ama Nazan Hanım kimsenin bağış yapmaya zorlanmaması gerektiğini hatırlattı. Katılabilecekleri farklı yollar düşünülmeliydi: kitapların düzenlenmesine yardım etmek, afiş hazırlamak, okuma saatine katılmak. {yoldas:yalin|bir arkadaş} ilk anda yalnız bağış sayısına bakacaktı. Sonra yardımlaşmanın farklı biçimleri olduğunu fark etti. Sınıf her katkıyı kişilerin isteğine göre görünür kıldı ya da gizli tuttu.

Kampanya sonrasında panoda bir not belirdi: Biri bana ihtiyacım olmadığında bile yardım etmek isteyip istemediğimi sordu. Hayır dediğimde de gülümsedi. Teşekkür ederim. {kahraman} bu cümleyi üç kez okudu. Birine saygı göstermek bazen onun "hayır" cevabını kabul etmekti. {yoldas:yalin|bir arkadaş} de notu sevdi. Daha önce herkesin yardım teklifini mutlaka kabul etmesi gerektiğini düşünüyordu. Şimdi bir arkadaşın kendi kararına yer açmanın da iyilik olabileceğini anladı.
---
@omurga
Sene sonu yaklaştığında çocuklar notları defter hâline getirmeyi düşündü. Fakat bazı notlarda özel duygular vardı. Zeynep, "Hepsini kalıcı bir kitapta toplamak doğru mu?" diye sordu. Nazan Hanım, sınıfça yazılmış genel ve izin verilmiş ifadelerin seçilebileceğini, kişileri tanımlayabilecek özel ayrıntıların çıkarılması veya hiç kullanılmaması gerektiğini anlattı. {kahraman}, yalnızca anonim genel iyilik fikirlerini içeren küçük bir broşür hazırlamayı önerdi. Böylece kimsenin istemediği bir hatıra başkalarına dağıtılmamış oldu.

Broşürün ilk sayfasına başlık bulmak zorlaştı. {yoldas:yalin|bir arkadaş} "Gizli Kahramanların Sınıfı" istiyordu. {kahraman} bu ismin yeniden gizli kişiyi bulmaya yöneltebileceğini düşündü. Zeynep, "Bir İyilik Fark Ettim" başlığını önerdi. Herkes bunu sevdi. Çünkü başlık bir kişiye değil, birlikte gelişen bir alışkanlığa işaret ediyordu. Broşürde kısa örnekler vardı: söz kesmeden dinlemek, uygun zamanda yardım teklif etmek, başkasının mahremiyetini korumak, ortak alanı temiz bırakmak. Her örneğin yanında tek cümlelik bir düşünme sorusu yer alıyordu.
---
@omurga
Dönemin son haftasında mavi yıldızlı yeni bir not gelmedi. {yoldas:yalin|bir arkadaş} biraz üzüldü. "Görünmez yazar artık yazmıyor," dedi. {kahraman}, "Belki başka biçimde iyilik yapıyordur," diye cevap verdi. Zeynep panonun önünden geçerken durdu. "Yazarın kim olduğunu hâlâ merak ediyor musunuz?" diye sordu. {yoldas:yalin|bir arkadaş} bir süre düşündü. "Eskisi kadar değil," dedi. "Artık hepimiz bir şey yazıyoruz."

{kahraman}, mavi yıldızlı ilk notun kopyasını defterine yapıştırdı. Altına şu cümleyi yazdı: Bir kişinin adını bilmiyorum ama başlattığı iyiliğin nasıl büyüdüğünü gördüm. Sonra defteri kapattı. Gizem çözülmemişti; fakat sınıftaki pek çok şey değişmişti. Daha çok öğrenci birbirine teşekkür ediyor, kimse fark etmese de yardım edenler artıyordu.

Dönem sonunda {kahraman} panonun eski fotoğraflarına baktı. İlk fotoğrafta yalnız mavi yıldızlı tek bir kâğıt vardı. Sonrakilerde kutu, renkli kartlar ve öğrencilerin çizdiği küçük resimler görünüyordu. {kahraman}, sayıların artmasına sevinse de bunu bir puan yarışına çevirmemeleri gerektiğini hatırladı. Bazı günler az not vardı ama sınıfta güzel davranışlar yine görülüyordu. Kimin daha fazla iyilik yaptığı sayılamazdı; çünkü bazı yardımlar hiç kimsenin görmediği anlarda gerçekleşiyordu.
---
@omurga
{yoldas:yalin|bir arkadaş} bir gün {kahraman:yonelme} sessizce bir şey söyledi: "Başta yazarı bulursam herkes bana 'Harika dedektif' diyecek sanıyordum." {kahraman} şaşırdı. "Şimdi?" diye sordu. {yoldas:yalin|bir arkadaş} biraz düşündü. "Şimdi kim olduğunu bulmamamın daha doğru olduğunu biliyorum. Çünkü sınıfımızdaki güzel şeyleri onun adı olmadan da fark edebildik." {kahraman} bunu duyunca sevindi. {yoldas:ilgi|bir arkadaşın} merakı kaybolmamıştı; yalnız yön değiştirmişti. Artık bir insanın sırrını çözmeye değil, nasıl daha iyi bir arkadaş olabileceğini öğrenmeye merak duyuyordu.

Zeynep o gün sınıftan son çıkanlardan biriydi. Panoya baktı, ardından çantasından küçük bir kâğıt çıkardı. Kâğıdın üzerinde bir cümle yazıyordu, fakat kimseye göstermedi. Bir süre düşünerek kâğıdı yeniden çantasına koydu. {kahraman} onu kapıda bekliyordu. "Geliyor musun?" diye sordu. Zeynep başını salladı. Birlikte koridora çıktılar. {kahraman} kâğıdı merak etmişti ama sormadı. Her düşüncenin herkesle paylaşılması gerekmediğini artık biliyordu. Arkadaşının yanında sessizce yürümek de bazen iyi bir davranıştı.
---
@omurga
Sınıfın hazırladığı küçük broşür başka bir okuldan da ilgi gördü. Öğretmenler örnekleri çocukların yaşına göre nasıl uyarlayabileceklerini konuştu. {kahraman}, uygulamanın aynı şekilde kopyalanması gerekmediğini söyledi. "Bizim kutumuz işe yaradı çünkü kurallarını birlikte belirledik," dedi. "Başka sınıflar da kendi ihtiyaçlarını konuşmalı." Nazan Hanım bu sözü takdir etti. Çünkü iyi bir fikir, uygulandığı yerdeki insanların duygularını ve haklarını dikkate aldığında değer kazanıyordu.

{yoldas:yalin|bir arkadaş} okuldan çıkarken panoda küçük bir boşluk gördü. Elini cebine atıp not kâğıdı aradı, sonra vazgeçti. Bugün bir şey yazmak istemiyordu. Bunun yerine koridorda elindeki kitapları taşımakta zorlanan arkadaşına yardım isteyip istemediğini sordu. Arkadaşı kabul edince birlikte yürüdüler. Kimse onları görmemiş olabilir, kimse panoya not yazmayabilirdi. {yoldas:yalin|bir arkadaş} bunun önemsiz olduğunu düşünmüyordu. Çünkü o an yardım etmiş olmak, başkalarının bunu öğrenmesinden daha değerliydi.
---
@omurga
Sene sonunda Nazan Hanım, öğrencilere tek bir soru sordu: "Bu etkinlik size ne öğretti?" {yoldas:yalin|bir arkadaş} elini kaldırdı. "Bazen bir sırrı çözmekten daha iyi şeyler var," dedi. {kahraman} gülerek, "Mesela o sırrın doğurduğu iyiliği çoğaltmak," diye tamamladı. Zeynep de sessizce başını salladı. Sınıf, görünmez yazarın kim olduğunu öğrenmedi. Ama belki de en güzel son buydu: Çünkü artık panoda yalnız bir kişinin değil, herkesin iyiliğinin izleri vardı.
---
@omurga
Yaz tatilinde {kahraman}, ilk notun fotoğrafını defterinin arasında buldu. Üzerindeki mavi yıldız artık ona bir dedektif işareti gibi görünmüyordu. Daha çok küçük bir kapıyı hatırlatıyordu: Birinin yaptığı iyi davranışı fark edip ona saygıyla yaklaşmanın kapısını. Defterini kapattı, ertesi yıl için bir hedef yazdı: "Yalnızca iyilik yapanı görmek değil, yardıma ihtiyaç duyanı da anlamak." Sonra hedefinin yanına bir soru ekledi: "Bu kişiye neyin iyi geleceğini gerçekten biliyor muyum, yoksa önce sormalı mıyım?" {kahraman} ikinci seçeneğin daha güvenilir olduğunu öğrendiği için kendine gülümsedi. İyi bir arkadaşlık, bazen en güzel soruyla başlıyordu. Ve bir sınıfı değiştirmek için herkesin kim olduğunu bilmek gerekmiyordu. İyiliğin başlattığı küçük hareket, adı açıklanmadan da yeni ve güçlü arkadaşlıkların içinde sessizce ve güvenle yaşamaya devam edebilirdi.
