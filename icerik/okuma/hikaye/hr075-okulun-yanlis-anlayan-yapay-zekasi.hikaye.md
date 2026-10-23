---
baslik: "Okulun Yanlış Anlayan Yapay Zekâsı"
slug: "hr075-okulun-yanlis-anlayan-yapay-zekasi"
fis_kodu: "HR-075"
tur: mizah
konu: deyim_gercek_anlam
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Okulun yeni asistanı her deyimi gerçek anlamıyla yorumluyor. Çocuklar ona nasıl öğretecek?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, dayanisma]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: sestes_hr075, tur: lexeme, etiket: "sesteş", yuva: hr075_sestes, islev: first_hint}
    - {id: baglam_hr075, tur: lexeme, etiket: "bağlam", yuva: hr075_baglam, islev: application}
    - {id: deyim_hr075, tur: idiom, etiket: "Etekleri zil çalmak", yuva: hr075_etekleri, islev: application}
    - {id: kavram_hr075, tur: concept, etiket: "Mecaz ve gerçek anlam ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Asistanın adı neydi?", secenekler: [{id: A, metin: "Çınar"}, {id: B, metin: "Batu"}, {id: C, metin: "Nehir"}, {id: D, metin: "Selin"}], dogru: A, aciklama: "Okulun asistanının adı Çınar'dı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 6, metin: "Selin Hanım'a göre bir sözcüğün anlamı nasıl bulunur?", secenekler: [{id: A, metin: "Önceki ve sonraki sözlere, konuşmanın durumuna bakılarak"}, {id: B, metin: "Yalnız sözlükteki ilk anlama bakılarak"}, {id: C, metin: "Sözcüğün harf sayısına bakılarak"}, {id: D, metin: "Hiç kimse anlamını bilemez"}], dogru: A, aciklama: "Bağlam, sözcüğün anlamını belirleyen çevredir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 8, metin: "İdil'in sesteş sözcükler hakkında vardığı sonuç nedir?", secenekler: [{id: A, metin: "Sözcüğü tek başına ezberlemek yetmez; cümlenin bağlamı gerekir"}, {id: B, metin: "Sesteş sözcükler hiç kullanılmaz"}, {id: C, metin: "Yalnız çiçek adları sesteştir"}, {id: D, metin: "Her sözcük yalnız bir anlam taşır"}], dogru: A, aciklama: "Aynı ses farklı anlamları taşıyabilir; doğru anlam için cümlenin çevresine bakılır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 4, metin: "Metinde geçen deyim ne demektir?", secenekler: [{id: A, metin: "Anlamı, kelimelerin tek tek anlamından farklı olan kalıplaşmış söz"}, {id: B, metin: "Bir tür oyun"}, {id: C, metin: "Ekranda çıkan bir resim"}, {id: D, metin: "Bir zil sesi"}], dogru: A, aciklama: "Deyim, kalıplaşmış ve mecaz anlamı olan bir sözdür."}
deyim_cumleleri:
  hr075_etekleri: "Üçüncü grup deyimleri ele aldı ve “Etekleri zil çalmak” sözü için gerçek bir zilin gerekli olmadığını anlattı."
---
@omurga
Okulun yeni sesli asistanı ilk gününde müdür yardımcısının söylediği “Gözünüzü dört açın,” sözünü duyunca bütün ekranlara dört gözlü bir yüz resmi gönderdi. Biri teneffüs saatine bakarken, biri kütüphanedeki kitabını ararken, hatta öğretmen yoklama listesini açarken bile aynı resim karşısına çıkıyordu. Ekranın altında nazik bir mesaj vardı: Güvenliğiniz için önerilen göz sayısı: dört. {isaret:ipucu}

Altıncı sınıf öğrencisi {kahraman} önce güldü, sonra yüzünü buruşturdu. “Bu robot deyimleri hiç anlamıyor,” dedi. Arkadaşı Batu, “Daha kötüsü, anlamadığını söylemiyor,” diye karşılık verdi. İkisinin yanında duran {yoldas:yalin|bir arkadaş} ise ekranın görüntüsünü defterine çizdi. {yoldas:yalin|bir arkadaş}, okulun teknoloji kulübünde her şeyin nasıl çalıştığını merak eden bir öğrenciydi. Bir açıklama bulmadan “Robot aptal,” demeyi doğru bulmuyordu.

Asistanın adı Çınar'dı. Koridorlara yerleştirilen hoparlörlerden cevap verebiliyor, kütüphane kataloğunda arama yapabiliyor, okul etkinlikleri hakkında bilgi sunabiliyordu. Ancak henüz deneme aşamasındaydı; önemli duyurular mutlaka öğretmenler tarafından kontrol ediliyordu. Bunu söyleyen bilişim öğretmeni Selin Hanım, o sabah sınıfın kapısına “Deneysel sistem, önerileri doğrulayın” yazılı bir uyarı asmıştı.
---
@omurga
Teneffüs zili çalınca Batu, “Çınar, biraz kafamı dağıt,” dedi. Koridordaki ekran anında renkli, dönen baş resimleriyle doldu. Çınar'ın sesi duyuldu: “Kafaları dağıtmak yaralanmalara yol açabilir. Lütfen güvenli bir mesafede durun.” Bir öğrenci elindeki suyunu gülmekten dökecek gibi oldu. Çınar buna da cevap verdi: “Kaygan zemin riski algılandı.”

“Bence yanlış anlamak başka, yanlış anladığını fark etmemek başka,” dedi {yoldas:yalin|bir arkadaş}. Üç arkadaş buna çözüm bulmaya karar verdi. Başlangıçta niyetleri yalnızca daha fazla komik cevap almak değildi. Eğer asistan bir gün bir velinin sorusunu da yanlış anlayacaksa, hatalar henüz kimseyi etkilemeden görülmeliydi.
---
@omurga
İlk hatadan sonra müdür yardımcısı çocuklara asistanın kapatılması gerekip gerekmediğini sordu. Batu, “Yarın okulun kapısını bile yanlış açar,” diye şaka yaptı. Selin Hanım, “Okul kapılarını zaten bu sistem açmıyor,” dedi. “Bir aracın ne yapabildiğini bilmeden ona güç yüklemek de yanlış anlamanın başka bir çeşidi.” Böylece ilk kontrollerini yaptılar. Çınar'ın hangi bilgilere eriştiği, neyi yalnızca gösterdiği ve hangi kararlara hiç karışmadığı yazılı bir listede bulunuyordu. Sınıfın kişisel notlarıyla sağlık bilgilerini okumaması özellikle belirtilmişti. {yoldas:yalin|bir arkadaş}, erişim sınırlarının gerçek bir güvenlik önlemi olduğunu fark etti; komik hatalar üzerine gülmek kolaydı, gizli bilgilerin yanlış yerde görünmesi ise aynı derecede eğlenceli olmazdı.
---
@omurga
Batu daha fazla şaka bulmak için okulun ilan panosunu dolaştı. “Kulübümüz yeni döneme hızlı bir giriş yapıyor,” başlığını okuyunca Çınar'a “Hızlı giriş”in ne anlama geldiğini sordu. Asistan, “Kapıdan hızlı koşmak düşmeye neden olabilir,” diye cevap verdi. Bu kez üçü de güldü ama koridorda koşmadılar. {yoldas:yalin|bir arkadaş}, kapı resmi değil, dönem başlangıcını anlatan bir takvim simgesi eklemeyi önerdi. {kahraman} ise aynı ifadenin başka bir bağlamda gerçekten hızlıca bir yere girmek anlamına gelebileceğini hatırlattı. Tek bir doğru anlamın her cümleye uymayacağı, hazırlayacakları sistemin temel ilkesi olacaktı.

Öğle yemeğinde konuyu arkadaşlarıyla konuşunca herkes başka bir örnek getirdi. Birisi “Ağzı kulaklarına varmak” deyiminin mutluluğu anlattığını, bir diğeri “İçi içine sığmamak” sözünün heyecanı gösterdiğini söyledi. Küçük bir öğrenci “Pabucu dama atılmak” deyimini anlattığında Batu bunun nereden çıktığını merak etti. Selin Hanım, deyimlerin geçmişi konusunda doğrulanmamış hikâyeler uydurmanın kolay olduğunu söyledi. Çocuklar anlamlarını güvenilir bir sözlükten kontrol edebiliyorlardı; kökenini bilmedikleri sözler içinse “araştırılacak” notu bırakacaklardı. Böylece mizah kulübü gibi başlayan iş, dikkatli kaynak okuma alışkanlığına dönüştü.
---
@omurga
Öğle arasında boş bir sınıfa geçtiler. Selin Hanım'ın izniyle Çınar'ın deneme sürümünü açtılar; okulun gerçek duyuru sistemine dokunmaları yasaktı. {kahraman} ilk cümleyi yazdı: Öğretmen, çocuklara göz kulak olmasını istedi. Çınar bu defa “Göz ve kulak organlarının karşılaştırmasını ister misiniz?” diye cevap verdi.

Batu, “Ne yapsak olmuyor,” dedi. {yoldas:yalin|bir arkadaş} acele etmedi. Aynı sözü iki ayrı cümlede denemelerini önerdi: Bahçede küçük kardeşime göz kulak oldum. ve Biyoloji kitabında göz ve kulak resimleri var. Çınar ikisini de organlarla ilişkilendirdi. Oysa ilk cümlede birini kollamak anlamı vardı. {kahraman}, deyimin mecaz anlamını defterine yazdı. Sonra yanına gerçek anlamdaki sözcükleri çizdi. İki kullanım arasındaki farkı görsel olarak göstermek kolaydı; makineye {kelime:hr075_baglam} açıklamak ise daha zordu.
---
@omurga
Selin Hanım onları dinledikten sonra tahtaya büyük harflerle BAĞLAM yazdı. “Bir kelimenin ne anlama geldiğini yalnız kendisine bakarak anlayamayız,” dedi. “Önündeki ve arkasındaki sözler, konuşan kişinin amacı ve içinde bulunduğumuz durum önemlidir.” Batu el kaldırdı. “O zaman Çınar bizimle oyun mu oynuyor?” Öğretmen güldü. “Çınar bir insan gibi düşünmüyor. Kullandığı örüntülerden yanıt üretmeye çalışıyor. Bazen doğru, bazen çok yanlış olabilir. Bu nedenle özellikle sonuç doğuran bilgileri kontrol etmemiz gerekir.”

Çocuklar ikinci denemeye geçti. Bu kez {kahraman}, “Şu iki sözcüğü bir düşün: yüz ve yüz,” dedi. Çınar ikisini de sayı olarak yorumladı. Batu cümleleri uzattı: Yüz metre koştuk, Denizde yüzmek güzel, Yüzündeki gülümseme kayboldu. Üç kullanım için ayrı açıklama istediler. Çınar bazılarını doğru ayırdı, bazılarında karıştı. {yoldas:yalin|bir arkadaş} buna sevindi. “Demek tamamen başarısız değil,” dedi. “Ama bir yanıt doğru diye ötekilerin de doğru olacağını sanmamalıyız.”
---
@omurga
Bir gün Çınar'a sesli komut veren öğrencilerden Asya, salonun çok gürültülü olduğunu söyledi. Asya işitme cihazı kullanıyordu ve hoparlörden peş peşe gelen sesler onun için yorucu olabiliyordu. “Komik olması güzel ama bazen yazıyı okumak istiyorum,” dedi. Batu ilk kez kendi eğlendiği bir özelliğin başka birini rahatsız edebileceğini fark etti. Çınar'ın sesli cevaplarının yanında ekranda aynı metnin görünmesini, sesin kolayca kapatılmasını önerdiler. Selin Hanım da herkes için erişilebilir seçenekler bulunmasının önemini anlattı. Asya, önerinin yalnız kendisi için değil, gürültülü ortamda bulunan tüm öğrenciler için faydalı olacağını söyledi.

Öğrenciler ikinci bir özellik düşündü: Çınar emin olmadığı durumda “Bundan emin değilim, doğrulamak ister misiniz?” diye sorabilmeliydi. İlk bakışta bu cümle heyecan verici görünmüyordu. Ama {kahraman} örnek gösterdi: “Ya bir çocuk ‘Yarın sınav iptal mi?’ derse ve Çınar uydurma bir cevap verirse?” Bu soruyla beraber herkesin gülüşü durdu. Böyle bilgiler öğretmenin resmî duyurusundan kontrol edilmeliydi. {yoldas:yalin|bir arkadaş} rapora, eğlenceli konuşma ile sonuç doğuran bilgi ayrı ele alınmalı notunu ekledi.
---
@omurga
Sonra görevleri paylaştılar. Batu deyimleri toplayacak, {kahraman} örnek cümleleri yazacak, {yoldas:yalin|bir arkadaş} kaynakları doğrulayacaktı. Asya ise ekrandaki metinlerin okunabilirliğini denetlemeyi önerdi. Bir resmin komik olması, metnin küçük ya da soluk yazılmasını haklı çıkarmazdı. Çınar'ın bir sonraki güncellemesi henüz onların elinde değildi; yine de geliştiriciye hangi soruları soracaklarını artık biliyorlardı. Bu düşünce Batu'yu şaşırttı. Önceki hafta teknolojiyi yalnızca kullanmak istiyordu. Şimdi kullandığı şeyin nasıl geliştirilmesi gerektiği üzerine konuşabiliyordu.

{kahraman} o gün eve yürürken {kelime:hr075_sestes} sözcükleri düşündü. Türkçe dersinde aynı sesle söylenebilen sözcüklerin farklı anlamları olabileceğini öğrenmişti. Gül hem çiçekti hem de gülmek fiilinin emir biçimiydi. Yaz hem mevsimdi hem de bir şeyi kalemle yazma emri olabilirdi. Bunların hiçbirinde sözcüğü tek başına ezberlemek yetmiyordu. Anlamı belirlemek için konuşmanın öncesine ve sonrasına bakmak gerekiyordu. Akşam kardeşine “Yaz geliyor,” dediğinde kardeşi defterini açmış, “Neyi yazayım?” diye sormuştu. İkisi bir süre güldü. {kahraman} gülmeyi bıraktığında, kardeşinin verdiği yanlış cevabın bile bir mantığı olduğunu fark etti. Çınar'ı da yalnızca alay konusu olarak görmemeye başladı; yanlış anlamanın nasıl oluştuğunu merak ediyordu.
---
@omurga
Ertesi gün {yoldas:yalin|bir arkadaş} bir sınıf etkinliği önerdi. Üç gruba ayrı cümleler verdiler. Her grup, bir ifadenin anlamını belirlemek için cümleden hangi sözcükleri kullandığını açıklayacaktı. İlk grup “Yaz boyunca her gün yazı yazdım,” cümlesinde aynı sesle başlayan iki ayrı kullanımı buldu. İkinci grup “Gül, vazodaki gülü gösterdi,” örneğinde özel adla çiçek adını ayırdı.[[deyim:hr075_etekleri]] Bazı öğrenciler yanlış yaptı ama arkadaşları onları küçümsemedi. Böylece Çınar'ın yanlış anlamalarını düzeltmek için başladıkları çalışma, birbirlerinden öğrenebildikleri küçük bir oyun hâline geldi.
---
@omurga
Sistemin geliştiricileri hafta sonunda okula gelecek, öğrencilere küçük bir gösteri yapacaktı. Selin Hanım, “İsterseniz gözlemlerinizi bir rapora dönüştürün,” dedi. “Geliştiricilere yalnız hataları değil, hangi şartlarda ortaya çıktıklarını da anlatın.” Çocuklar dört sütunlu bir çizelge hazırladı: söylenen cümle, beklenen anlam, Çınar'ın cevabı ve daha açık ifade.

İlk satıra Etekleri zil çalmak yazdılar. Batu, Çınar'ın cevabını merak edip sistemi çalıştırdı. Hoparlörden tiz bir zil sesi duyuldu. {yoldas:yalin|bir arkadaş} hızla sesi kıstı. “Bu deyim bir insanın çok sevinmesi demek,” dedi. {kahraman} de neşeli bir öğrenci çizdi. Başka bir satıra Burnundan solumak yazdılar. Çınar nefes alma organları hakkında bilgi verdi. Oysa deyim çok öfkeli olmak anlamına geliyordu.

Çocuklar deyimlerin başına gülünç birer resim koymanın her zaman işe yaramayacağını fark etti. İğneyle kuyu kazmak ifadesine bir iğneyle derin kuyunun çizildiği resim yapmışlardı. Resim komikti; fakat deyimin büyük emek isteyen işi sabırla yürütmek anlamına geldiğini tek başına anlatmıyordu. {kahraman} yeni bir resim tasarladı: Uzun bir proje üzerinde her gün küçük adımlar atan çocuk. Altına da “zor işi azimle sürdürmek” yazdı.
---
@omurga
Bir sonraki hata onları gerçekten düşündürdü. Batu, “Bugün ödevden başımı kaldıramadım,” deyince Çınar boyun egzersizi önerdi. Öneri tehlikeli değildi, ama yine de öğrencinin ne anlattığını anlamıyordu. {yoldas:yalin|bir arkadaş}, “Bunu gören küçük bir çocuk, deyimin gerçek anlamını sanabilir,” dedi. Selin Hanım, çözümün yalnızca sisteme daha çok örnek eklemek olmadığını hatırlattı. İnsanların da deyimleri bazen yanlış anladığını, kitap okumanın ve sözlük kullanmanın önemli olduğunu söyledi.

Çizelgeye örnek eklemek düşündüklerinden zahmetli çıktı. Aynı deyimi farklı kişiler farklı durumlarda kullanıyordu. “Ayağına taş değmesin,” sözünü anneannesinden duyan bir çocuk bunun iyi dilek olduğunu söyledi. Çınar ise yürüyüş yollarındaki taşlara karşı uyarı verdi. {kahraman} önce doğrudan “iyi dilek” etiketini eklemek istedi. {yoldas:yalin|bir arkadaş}, önce tüm cümleyi yazmaları gerektiğini savundu: Yolun açık olsun, ayağına taş değmesin. Böyle yazınca sözün gerçek bir taş tehlikesinden daha geniş bir anlam taşıdığı belli oluyordu.
---
@omurga
Bir başka öğrenci, “Sözünü kesmek” ifadesini kullanınca asistan bir makas resmi gösterdi. Çınar'a “İki arkadaş konuşurken üçüncüsü araya girdi,” cümlesini verdiklerinde ise daha doğru açıklamaya yaklaştı. Batu bunu kara tahtada canlandırdı. {kahraman} bir şey anlatırken onun sözünü kesti, sonra izin isteyerek konuştu. Sınıftaki çocuklar iki davranış arasındaki farkı hemen gördü. Anlatım yalnız sözlük tanımından ibaret olmayınca kavram daha iyi yerleşmişti. {kahraman}, “Kelimelerin anlamını öğretirken davranışları da gösterebiliriz,” dedi.

Denemelerde kimi öğrenciler yalnız gülmek için en tuhaf cümleleri seçiyordu. {yoldas:yalin|bir arkadaş} buna karşı bir sınır önerdi: Öğrencilerin adları, kişisel sorunları veya utandırıcı olayları test cümlelerinde kullanılmayacaktı. Birinin konuşmasını taklit ederek arkadaşları güldürmeye çalışmak da yasaktı. Batu önce “Bu kadar kural komediyi bitirir,” dedi. Fakat Mert'in afiş telaşında neden utanmış göründüğünü hatırlayınca fikrini değiştirdi. Bir şaka bir kişiyi yalnız bırakıyorsa, herkesin eğlendiği söylenemezdi.
---
@omurga
Deyim kartlarının arkasına soru eklemeye karar verdiler. Örneğin “Elini taşın altına koymak” kartının önünde ağır bir taş resmi vardı. Arkasına ise “Bir işin sorumluluğunu üstlenmek” açıklaması ve iki kısa olay yazıldı. Birinci olayda bir öğrenci bahçedeki taşı itmeye çalışıyordu. İkinci olayda sınıf projesinin zor bölümüne gönüllü oluyordu. Ziyaretçinin hangisinin deyimi anlattığını seçmesi gerekiyordu. İlk kartı deneyen öğrencilerin çoğu ikinci olayı buldu, ama bazıları birinciyi seçti. {yoldas:yalin|bir arkadaş} onlara nedenini sordu. Çocuklar “Taş sözcüğü var,” deyince yeni bir soru ortaya çıktı: Sözcükleri tek tek görmekle cümlenin anlamını görmek arasındaki fark neydi?

Batu bunun üzerine kartlara küçük konuşma balonları ekledi. “Bu işte elimi taşın altına koyacağım,” diyen bir karakterin karşısına, “Teşekkür ederim, o zaman planı birlikte tamamlayabiliriz,” diyen başka birini çizdi. İnsanların cevabı, ifadenin mecaz anlamını görünür kılıyordu. Selin Hanım çizimleri beğendi ama uyardı: “**Her deyimi resimle açıklamak zorunda değilsiniz**. Bazılarında iyi bir örnek cümle daha etkili olabilir.” {kahraman} bu uyarıyı not etti. Görsel destek bir araçtı; okumayı ve anlamayı ortadan kaldırmamalıydı.
---
@omurga
Gösteriden bir gün önce sınıf temsilcisi Mert, okul kulübünün afişine yardım istemek için geldi. “Elimizi çabuk tutmalıyız, yoksa iş başımıza kalacak,” dedi. Çınar bu konuşmayı duyunca büyük ekranda dört elin koştuğu bir animasyon açtı. Ardından uyarı verdi: “Başınıza düşebilecek nesneleri kaldırın.” Batu kahkahadan sıraya kapandı. {kahraman} de gülüyordu ama Mert'in yüzündeki sıkıntıyı fark etti. Çocuk, afişin yetişmeyeceğinden gerçekten kaygılıydı.

“Çınar'ın cevabı komik,” dedi {kahraman}, “ama Mert'in ihtiyacı afişin hazırlanması.” Afiş için görevleri paylaştılar. {yoldas:yalin|bir arkadaş} yazım hatalarını kontrol etti, {kahraman} çizimleri tamamladı, Batu renkleri seçti. Mert ilk kez rahatça gülümsedi. Böylece şakanın içindeki gerçek sorunu görmeyi de öğrendiler.

Gösteri gününde okul salonu doluydu. Geliştirici ekipten gelen Yasemin Hanım, Çınar'ın nasıl cevap ürettiğini örneklerle anlattı. Öğrencilerin hazırladığı çizelgeyi görünce şaşırdı. “Sadece yanlış yanıtları değil, neden yanlış olduklarını da yazmışsınız,” dedi. “Bu bize sistemin hangi durumlarda zorlandığını gösterir.”
---
@omurga
Batu mikrofonu aldı. “Çınar, ‘Gözüme girdi’ deyince ne düşünüyorsun?” diye sordu. Çınar cevap verdi: “Gözünüze yabancı madde kaçtıysa yetkili bir yetişkinden yardım isteyin.” Salonda gülüşmeler yükseldi. Batu bu kez aynı deyimi tam cümlede kullandı: Dün sınıf panosunu yetiştirdim, öğretmenimin gözüne girdim. Çınar kısa bir duraklamadan sonra şöyle dedi: “Bu cümlede ‘göze girmek’, beğeni kazanmak anlamında kullanılıyor olabilir.” Alkış koptu.

“Gördünüz mü, artık biliyor!” diye bağırdı Mert. Yasemin Hanım elini kaldırdı. “Bir örnekte doğru cevap verdi; bütün durumları anladığı sonucunu çıkarmayalım. Hâlâ test etmeliyiz.” {yoldas:yalin|bir arkadaş} bu cümleyi defterinin kenarına yazdı. Başarı sevindiriciydi, ancak denetimi bırakmanın nedeni değildi.
---
@omurga
Gösteri başlamadan önce Yasemin Hanım, çocuklara küçük bir kart dağıttı. Kartta üç soru vardı: Sistem hangi görevi yapıyor? Yanıtını nasıl kontrol ederiz? Hata yaparsa kime bildiririz? {kahraman}, bu soruları başlangıçta sıkıcı bulabilirdi. Oysa şimdi sınıfta yaşananları düşününce her birinin somut bir karşılığı olduğunu gördü. Çınar, bir duyuruyu göstermek üzere tasarlanmışsa gizli öğrenci bilgilerini bilmemeliydi. Bir deyimin anlamı sorulmuşsa, bağlamı dikkate almadan kesin yargı vermemeliydi. Bir hata fark edildiğinde de öğrenciye kızmadan düzeltme yapılabilmeliydi.

Batu bir deneme daha yapmak istedi. “Çınar, aklım bir karış havada,” dedi. Ekranda önce rengârenk bulutlar belirdi. Salondan gülüşmeler yükseldi. Çınar ardından, “Düşüncelerinizi toplamakta zorlandığınızı söylemek istiyor olabilirsiniz,” diye devam etti. Batu şaşkınlıkla gözlerini açtı. “Bu iki farklı cevap gibi!” Yasemin Hanım, asistanın eğlenceli görseller üretmek üzere de ayarlandığını, ancak bunun anlamın doğru olup olmadığını garanti etmediğini anlattı. Selin Hanım, görsellerin metni destekleyebileceğini fakat bazen dikkat de dağıtabileceğini ekledi. {kahraman} çizimlerin, doğru anlamı göstermek için kullanılmasını önerdi.
---
@omurga
Gösterinin arka sırasında oturan üçüncü sınıf öğrencisi, “Peki her yanlışını biz mi düzelteceğiz?” diye sordu. Bu soruyu kimse beklemiyordu. Yasemin Hanım, “Hayır,” dedi. “Asıl sorumluluk sistemi tasarlayan, denetleyen yetişkinlerde. Sizin gözlemleriniz çok değerli ama güvenliği tek başınıza sağlamak sizin göreviniz değil.” {yoldas:yalin|bir arkadaş} bu cevabı beğendi. Teknoloji kulübüne katılan çocukların katkısı önemliydi; yine de güvenilir bir sistemin yetişkinler tarafından sınanması, güncellenmesi ve sorumluluk alınması gerekiyordu.

Hazırlıkların son gününde kulüp üyeleri kısa bir prova yaptı. Batu sahneye çıkıp asistanın en komik yanıtını anlattı. Ardından çocuklara “Sizce bu yanıt neden yanlış?” diye sordu. Beklediğinden farklı cevaplar geldi. Kimisi deyimin mecaz olduğunu söyledi, kimisi asistanın sorunun tamamını dinlemediğini düşündü. {yoldas:yalin|bir arkadaş} de küçük bir ayrıntıyı hatırlattı: Bazen insanlar bir deyimi gerçekten şaka yapmak için gerçek anlamda kullanabilirdi. Örneğin “Etekleri zil çalmak” sözü, tiyatro oyununda eteğine zil takılmış bir karakteri de anlatabilirdi. Dolayısıyla yalnızca “Bu sözcükler hep mecazdır,” diye bir kural koymak da hatalıydı. Önemli olan, cümlenin gerçek hayatta nasıl kullanıldığına bakmaktı.
---
@omurga
{kahraman} bu düşünceden yeni bir oyun çıkardı. Sınıf arkadaşları iki cümle yazacak, diğerleri hangisinin mecaz hangisinin gerçek kullanım olduğunu tartışacaktı. İlk örneği kendisi verdi: “Yeni oyuncu sahneye çıkar çıkmaz etekleri zil çaldı; kostümüne küçük çanlar dikilmişti.” İkinci örnekte ise “Takıma seçildiğini duyunca etekleri zil çaldı,” diyordu. Aynı ifade iki ayrı durumda iki farklı anlama gelebiliyordu. Bu oyun hazırlıkları biraz uzattı ama gösteriye katılanların yalnızca gülmekle kalmayacağı da belli oldu.

Gösteriden bir gün önce küçük bir prova yaptılar. Selim “dili tutulmak” sözünü duyunca önce hastalık sandı; sonra birinin heyecandan konuşamadığını anlatabileceğini öğrendi. Asya, sözcüklerin anlamının yalnız sözlükten değil, cümlenin çevresinden de çıktığını hatırlattı. Çınar iki örnek arasında karar vermek yerine “Hangi durumdan söz ediyoruz?” diye sordu. {kahraman} bu soruyu çok sevdi. Çünkü çocuklar artık makineyi sınamak için zor cümleler aramıyor, kendi düşüncelerini daha açık anlatmanın yollarını deniyordu. Provada yapılan küçük bir hata bile yeni bir soruya dönüşüyordu.
---
@omurga
Gösterinin sonunda Çınar'a serbest soru sorma hakkı verildi. Sınıfın en sessiz öğrencilerinden Selim ayağa kalktı. “Çınar, bazen arkadaşlarımla konuşurken ne demek istediğimi anlatamıyorum. Ne yapmalıyım?” diye sordu. Salon bir anda sessizleşti. Herkes asistanın yine tuhaf bir resim göstereceğini bekliyordu.

Çınar bu kez acele etmedi. “Sizi yanlış anlamış olabilirim,” dedi. “İsterseniz cümlenizi başka şekilde söyleyebilirsiniz. Bir öğretmenden veya güvendiğiniz bir arkadaşınızdan yardım istemek de mümkündür.”

Selim gülümsedi. “Bu iyi bir cevap,” dedi. {kahraman} de aynı fikirdeydi. Belki en akıllı yanıt, her şeyi biliyormuş gibi yapmak değil, bilmediğini kabul etmekti. Bunun bir makineden gelmesi daha da dikkat çekiciydi.

Gösterinin ardından okul yönetimi, Çınar'ın deneme sürümünü iki hafta daha yalnız belirli alanlarda kullanmaya karar verdi. Öğrencilerden gelen hata bildirimleri küçük bir kutuda toplanacaktı. Asya, kutunun yanında yazılı açıklama biçimini de değerlendirdi. Selim, anlamını bilmediği bir deyim için kimseye gülünmemesi gerektiğini söyledi. Bu sayede sınıfın amacı değişti: Yalnızca Çınar'ın bilmediklerini saymak değil, insanların da birbirini daha iyi anlamasını sağlayan bir ortam kurmak.
---
@omurga
{kahraman} gösteride asistanın verdiği iyi cevabı eve gidince ailesine anlattı. Babası, “Demek teknoloji bir günde her şeyi öğrendi,” diye takıldı. {kahraman} bu kez hemen karşı çıktı: “Hayır, yalnızca bazı cümleleri daha iyi açıklıyor. Yarın başka bir cümlede yine hata yapabilir.” Babası gülümseyerek, “Bu ayrımı bilmen çok iyi,” dedi. Annesi ise {kahraman:ayrilma} sözlükten bakıp öğrenebilecekleri yeni bir deyim seçmesini istedi. {kahraman}, ince eleyip sık dokumak deyimini buldu. Anlamını öğrendikten sonra Çınar'ın hazırlanan rapora neden iyi uyduğunu düşündü. Arkadaşlarıyla gerçekten de her örneği ince ince değerlendiriyorlardı.

Ertesi hafta çocuklar teknoloji kulübündeErtesi hafta çocuklar teknoloji kulübünde küçük bir çalışma başlattı: Deyimlerin Gerçekten Gerçek Olmadığı Müze. Bir köşede Çınar'ın eğlenceli yanlış anlamaları, karşılarında ise deyimlerin doğru anlamları bulunuyordu. Ziyaretçiler resimlere gülüyor, sonra hangi cümlenin hangi bağlamda kullanıldığını tartışıyordu. Okulun sözlük rafı, uzun zamandır olmadığı kadar kalabalıktı.
---
@omurga
Serginin açıldığı gün küçük bir öğrenci {kahraman:ilgi} yanına geldi. “Ben konuşurken bazen kelime bulamıyorum,” dedi. “Çınar yanlış anlarsa herkes bana güler mi?” {kahraman} çocuğun sorusunu hemen cevaplamak istemedi. Batu'yla göz göze geldi. Daha önce kahkahalarla anlattıkları hataların birini üzebileceğini o anda iyice anladılar. “Burada insanlara gülmüyoruz,” dedi {kahraman}. “Sözcüklerin bizi nasıl şaşırttığına gülüyoruz. Anlamadığımızda yeniden soruyoruz.” Çocuk, kartlardan birini seçti. “İçi içine sığmamak,” diye okudu. {kahraman} onun neden seçtiğini sorunca, ilk kez sahneye çıkacağı için çok heyecanlandığını öğrendi.

Üç arkadaş kısa bir oyun hazırladı. Çocuk sahneye çıktığında kendisiyle ilgili hiçbir bilgi paylaşılmadı; yalnızca karttaki deyim anlatıldı. Oyunun sonunda izleyiciler “heyecanlı olmak” cevabını buldu. {kahraman}, bir sözün anlamını öğrenirken konuşan kişinin duygusunu da dinlemek gerektiğini düşündü. Teknoloji ne kadar gelişirse gelişsin, insanın kendisini güvende hissetme ihtiyacı değişmiyordu. Selin Hanım serginin kapanışında bunu özellikle vurguladı: “İyi iletişim yalnızca doğru kelimeyi bulmak değildir; karşıdakini dinlemek ve gerektiğinde yeniden açıklayabilmektir.”
---
@omurga
{kahraman} akşam defterinin kapağına büyük bir soru yazdı: Bir şeyin komik olması için birinin üzülmesi gerekir mi? Altına üç arkadaşının verdiği cevapları not etti. Batu hayır diyordu; {yoldas:yalin|bir arkadaş} yanlış anlamaların bile insanı düşündürebileceğini söylüyordu. {kahraman} ise bu sorunun yanıtını tek cümlede bitirmek istemiyordu. Ertesi gün yeni bir deyim öğrendiklerinde aynı sayfaya dönecek, hem sözcüklerin hem de şakalarının nasıl değiştiğine bakacaklardı. Böylece yaptıkları çalışma bir günlük gösteriden daha uzun ömürlü olmuştu.

Sonunda {yoldas:yalin|bir arkadaş}, raporun en üstüne küçük bir hatırlatma ekledi: Önce anlamaya çalış. Her yeni yanıtı da dikkatle kontrol et. Şüphe duyduğunda sor. Çınar'ın hata yapması artık onları kızdırmıyordu; çünkü hangi durumda makineye, hangi durumda sözlüğe, hangi durumda da birbirlerine başvuracaklarını daha iyi biliyorlardı.
---
@omurga
Çınar'ın ekranında son bir mesaj belirdi: “Bugün yeni bir deyim öğrendim: Kulağına küpe olsun.” Batu telaşla, “Aman sakın kulağına metal halka takmaya kalkma,” dedi. Çınar birkaç saniye sustu. Ardından cevap verdi: “Bu ifadenin bir deneyimden ders çıkarmak anlamına gelebileceğini anlıyorum. Yine de kullanıldığı cümle önemlidir.”

{yoldas:yalin|bir arkadaş} kahkahayla güldü. “İşte şimdi oldu!”

{kahraman} hemen düzeltti: “Belki. Önce bir örnek daha deneyelim.”

Bu kez herkes güldü. Çınar da neşeli bir sesle, “Yanıtınız için teşekkür ederim,” dedi. Çocuklar ilk kez onun cümlesini doğru anlamış olabileceğinden emindi: Gerçekten teşekkür ediyordu, başlarına yeni bir ekran resmi göndermiyordu.
