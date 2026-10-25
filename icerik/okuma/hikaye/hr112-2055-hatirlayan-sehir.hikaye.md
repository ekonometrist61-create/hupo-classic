---
baslik: "2055: Hatırlayan Şehir"
slug: "hr112-2055-hatirlayan-sehir"
fis_kodu: "HR-112"
tur: bilim_kurgu
konu: veri_tahmin_mahremiyet
sinif_alt: 8
sinif_ust: 8
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Güneşkent'te bir durak, yolcuya ne zaman neyi önereceğini bilen bir sistem. Elif ve arkadaşları, bir sistemin ne kadar hatırlaması gerektiğini sorar."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 8
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, guvenlik]
  ders_baglantisi: [fen, sosyal]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: tahmin_hr112, tur: lexeme, etiket: "tahmin", yuva: hr112_tahmin, islev: first_hint}
    - {id: minimizasyon_hr112, tur: lexeme, etiket: "veri minimizasyonu", yuva: hr112_minimizasyon, islev: application}
    - {id: itiraz_hr112, tur: lexeme, etiket: "itiraz", yuva: hr112_itiraz, islev: application}
    - {id: kayit_hr112, tur: lexeme, etiket: "kayıt", yuva: hr112_kayit, islev: transfer}
    - {id: deyim_hr112, tur: idiom, etiket: "İçine ağırlık oturmak", yuva: hr112_agirlik, islev: application}
    - {id: kavram_hr112, tur: concept, etiket: "Tahmin ile kaydı ayırmak", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (8. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Belediye sisteme hangi adı vermişti?", secenekler: [{id: A, metin: "GÜNEŞ"}, {id: B, metin: "ŞEHİR"}, {id: C, metin: "HAFIZA"}, {id: D, metin: "KONSEY"}], dogru: C, aciklama: "Belediye sisteme HAFIZA adını vermişti."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 12, metin: "Elif'e göre bir veriyi yalnızca toplayabiliyor olmak ne anlama gelir?", secenekler: [{id: A, metin: "Toplamak için yeterli bir gerekçe olur"}, {id: B, metin: "Toplamak için tek başına yeterli bir gerekçe olmaz"}, {id: C, metin: "Verinin daha güvenli olduğunu gösterir"}, {id: D, metin: "Sistemin daha yavaş çalışacağını gösterir"}], dogru: B, aciklama: "Bir verinin toplanabilir olması, toplanması için tek başına yeterli gerekçe değildir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 22, metin: "Elif'in afişteki sözü değiştirmesinin nedeni nedir?", secenekler: [{id: A, metin: "Bilmek ile tahmin etmek arasındaki farkı fark etmesi"}, {id: B, metin: "Afişin çok renkli olması"}, {id: C, metin: "Jürinin bunu istemesi"}, {id: D, metin: "Sistemin tüm yanıtları bilmesi"}], dogru: A, aciklama: "Elif, bilmek ile tahmin etmek arasındaki farkı öğrenince ilk sözün kibirli olduğunu fark eder."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 18, metin: "Metinde “kimliksiz” sözcüğü ne anlatır?", secenekler: [{id: A, metin: "Hiç kullanılmayan"}, {id: B, metin: "Sahibi olmayan bir cihaz"}, {id: C, metin: "Yanlış bir yazıyla yazılmış"}, {id: D, metin: "Adı ya da kimliği açıkça belirtilmeyen"}], dogru: D, aciklama: "Kimliksiz, verinin üzerinde kişinin adı ya da kimliği açıkça yer almayan durumu anlatır."}
  - {id: s5, beceri: degerlendirme, dayanak_sayfa: 20, metin: "Öğrencilerin yasal ve teknik ayrıntılar konusundaki tutumu nasıldır?", secenekler: [{id: A, metin: "Kendi kararlarıyla hemen belirlemek"}, {id: B, metin: "Bu ayrıntıları tamamen görmezden gelmek"}, {id: C, metin: "Uzmanların değerlendirmesine güvenmek ve dikkatli davranmak"}, {id: D, metin: "Sadece jürinin görüşüne uymak"}], dogru: C, aciklama: "Öğrenciler yasal ve teknik ayrıntıların uzmanlarca belirlenmesi gerektiğini kabul eder."}
deyim_cumleleri:
  hr112_agirlik: "{kahraman} bunu duyunca içine bir ağırlık oturdu."
---
@omurga
2055 yılında Güneşkent'in otobüs durakları yalnızca otobüslerin ne zaman geleceğini değil, yolcuların nereye gitmek isteyeceğini de tahmin ederdi. Durakların çatısındaki ince ekranlar, insanlar yaklaşırken kişisel rotalar önerirdi. Yağmurlu günlerde yürümek istemeyenleri otobüse, acelesi olanları metroya yönlendirirdi. Belediye bu sisteme HAFIZA adını vermişti: Hareket Analizi ve Fırsatları İzleme Akıllısı.

On dört yaşındaki {kahraman}, HAFIZA'yı önce sevmişti. Sabah aceleyle evden çıktığında trafik sıkışıklığını haber veriyor, bilim kulübü toplantısından döndüğünde evine en kısa yolu buluyordu. Kardeşi Ömer'in unutkanlığı yüzünden otobüste bıraktığı şemsiyeyi bile hangi saatte hangi hatta taşıdığını gösteren {kelime:hr112_kayit} bulmuşlardı. {kahraman:ilgi} babası, “Şehir nihayet bizi dinliyor,” derdi.

Fakat bir perşembe sabahı durak ekranı {kahraman:yonelme} şu öneriyi sundu: Müzik kursu yerine doğrudan eve gitmek ister misin? Son üç haftadır kursta mutlu görünmüyorsun.

{kahraman} durdu. Kursa neden gitmediğini kimse bilmiyordu; üç haftadır okul çıkışında ablasıyla kütüphanede buluşuyor, gizlice hazırladıkları küçük bir müzik kayıt projesini geliştiriyorlardı. Üstelik sistemin “mutlu görünmüyorsun” demesi daha da tuhaftı. Durak yüzünden bir şey okumuş olmalıydı. Ekranın altında kaynağa ilişkin hiçbir açıklama bulunmuyordu.
---
@omurga
O gün okulda arkadaşı {yoldas:yalin|bir arkadaş} ona yeni bir afiş gösterdi. Kent Konseyi gençlerden şehir teknolojilerini değerlendirecek projeler istiyordu. {kahraman} hemen durak ekranındaki cümleyi anlattı. {yoldas:yalin|bir arkadaş} güldü: “Demek otobüs durağı senden daha iyi ne istediğini biliyor.”

“Benim yerime karar verirse iyi bilebilir mi?” dedi {kahraman}. Sesindeki sertliğe kendisi de şaşırdı. Bilim kulübüne yazmayı düşündükleri proje başlığını değiştirdiler: Bir Şehir Ne Kadar Hatırlamalı?
---
@omurga
İlk araştırmayı küçük bir not defteriyle yaptılar. Bir hafta boyunca kendilerine önerilen rotaları, önerilerin gerekçelerini ve gerçekten işe yarayıp yaramadıklarını kaydettiler. {yoldas:ilgi|bir arkadaşın} ekranı her salı ona basketbol salonuna yöneliyordu, çünkü geçen yıl o salonda antrenman yapmıştı. Oysa dizindeki incinme geçtikten sonra başka bir sporla ilgilenmeye başlamıştı. Sistem bunu bilmiyor, eski alışkanlığı güncel tercih sanıyordu.

Sınıf arkadaşları Mina'nın durumu daha farklıydı. Mina görme güçlüğü yaşayan bir öğrenciydi ve sesli yönlendirmeleri kullanıyordu. HAFIZA onun için bazı yollardaki çalışmaları haber vererek yararlı oluyordu. Ancak geçen ay geçici olarak kullandığı bir güzergâhı “daima tercih edilen rota” olarak kaydetmişti. Şimdi daha kısa ve güvenli seçenekler varken onu uzun bir yola yönlendiriyordu.

“Bu sistemi tamamen kapatalım desem,” dedi {kahraman}, “sana zarar vermiş olur muyum?”

“Ben de tamamen kapatalım demiyorum,” dedi Mina. “Ama neden böyle karar verdiğini görmek, yanlışsa düzeltebilmek istiyorum.”
---
@omurga
Üç öğrenci öğretmenleri Deniz Hanım'a danıştı. Öğretmen, veriyle {kelime:hr112_tahmin} birbirinden ayırmalarını istedi. “Durak gerçekten neyi biliyor? Neyi tahmin ediyor? Hangisini açıkça söylüyor?” diye sordu. {kahraman} defterine iki sütun çizdi. Birine kayıt, ötekine çıkarım yazdı. {yoldas:ilgi|bir arkadaşın} geçen yıl basketbol salonuna gittiği bir kayıttı. Bugün de oraya gitmek istediği ise çıkarımdı.

Okul çıkışında HAFIZA'nın bilgi merkezini ziyaret ettiler. Görevli, hareket örüntülerini kullandığını anlattı. “Veriler birleşince şehir hizmetlerini iyileştiriyoruz. İnsanlar beklemiyor, araçlar boş dolaşmıyor,” dedi. {kahraman} bir örnek gösterdi: {yoldas:yonelme|bir arkadaşa} yapılan eski basketbol önerisi. Görevli bunun bir tahmin hatası olabileceğini kabul etti ama tek bir yanlışın bütün sistemi değersizleştirmeyeceğini söyledi.

{kahraman} de öyle düşünüyordu. Fakat hatanın nasıl düzeltileceği sorulduğunda görevli uzun bir kılavuza yönlendirdi. Kılavuzda hangi kaydın ne kadar saklandığına ilişkin açık bir cümle bulamadılar.
---
@omurga
Araştırmanın üçüncü günü okul gezisinde küçük bir olay yaşandı. Sekizinci sınıflar tarihi bilim merkezine gidecekti. HAFIZA, kalabalığı azaltmak için öğrencileri farklı duraklara yönlendirdi. Sistem yalnızca önceki yolculuk kayıtlarını dikkate almış, öğretmenlerin yeni buluşma planını tam olarak işlememişti. Bazı öğrenciler doğru noktaya ulaşırken bir grup, kapalı bir servis girişine yöneldi.

Kimse kaybolmadı; öğretmenleri öğrencileri sayıp kapalı girişin yanındaki bekleme alanında topladı. Ancak buluşma gecikince ziyaretin bir bölümü iptal edildi. Deniz Hanım, “Teknolojik öneri yararlı olabilir,” dedi, “ama okul gezisinin güvenliğini ona bırakamayız.” Öğrencilerin konumları okulun doğrulanmış gezi planına göre yeniden kontrol edildi. {kahraman} bir önerinin resmî bilgi gibi sunulmasının tehlikesini ilk kez bu kadar açık gördü.

Sonraki gün yerel bir haber sitesi “HAFIZA okul gezisini felakete sürükledi” başlığı attı. {yoldas:yalin|bir arkadaş} habere kızdı. “Ortada felaket yoktu. Sadece yanlış yönlendirme vardı,” dedi. {kahraman}, aynı hatanın iki uçta nasıl çarpıtıldığını düşündü: Belediyenin tanıtımında kusursuz görünen sistem, haberde tam bir tehdit gibi anlatılmıştı. Oysa araştırmanın değeri, olup biteni olduğu gibi yazmaktaydı.
---
@omurga
Bilim kulübünün toplantısında olayın zaman çizelgesini hazırladılar. Öğretmenler hangi saatte hangi durakta öğrenci saymıştı? Uyarı ne zaman gönderilmişti? Kapalı girişe yönlendirmeyi kim fark etmişti? {kahraman}, doğrulanmamış bir sosyal medya paylaşımını çizelgeden çıkardı. “Bu kişi orada değilmiş,” dedi. “Ona dayanamayız.”

Mina, “Sistemin hepsini bilmesi daha iyi yönlendirme yapmasını sağlamamış,” diye ekledi. “Belki doğru şeyi, doğru zamanda bilmesi yeterliydi.”

{kahraman} bu cümleyi raporun kapağına yazdı. O ana kadar yalnızca özel hayatı korumakla ilgilendiklerini sanmıştı. Oysa gereksiz veri toplanması, daha doğru karar verileceği anlamına da gelmiyordu.
---
@omurga
Araştırmayı ilerletmek için HAFIZA'nın halka açık test merkezine başvurdular. Merkezdeki görevli Murat Bey, çeşitli şehir hizmetlerinin küçük modellerini gösterdi. Enerji tüketimini hesaplayan, otobüs doluluğunu tahmin eden ve belediye bisikletlerini dağıtan programlar yan yana çalışıyordu. Her programın kullandığı bilgi farklıydı. Bisikletlerin bir bölgede azalıp azalmadığını anlamak için tek tek insanların isimlerine ihtiyaç yoktu. Yalnızca hangi istasyonda kaç bisiklet kaldığını bilmek çoğu zaman yeterliydi.

Fakat HAFIZA'nın kişiselleştirme bölümü geçmiş yolculuklarla okul saatlerini birleştiriyordu. Murat Bey, “Böylece alışkanlıkları anlayabiliyoruz,” dedi. {yoldas:yalin|bir arkadaş}, “Peki alışkanlığımız değişince?” diye sordu. Görevli cevap vermeden önce ekrana baktı. “Sistem zamanla öğreniyor.”

{kahraman}, eski bir kaydın kişiyi yıllarca izleyip izleyemeyeceğini sordu. Murat Bey kayıt saklama yöntemlerinin farklı olduğunu söyledi ama kesin süreleri uzman ekibin değerlendirmesi gerektiğini belirtti. Bu kez {kahraman}, teknik belirsizliği dürüstçe kabul ettiği için ona teşekkür etti. Bilimsel bir cevap, her soruya hemen yanıt vermek zorunda değildi.
---
@omurga
Test merkezinden çıkarken Mina'nın ekranında tuhaf bir mesaj belirdi: Şehir içi hareket puanınız düştü. Önerileriniz sınırlandırıldı. Mina bir an olduğu yerde kaldı. “Ben ne yaptım?” dedi.

Daha sonra anlaşıldı ki program, uzun süre kullanılmayan güzergâhlara düşük güven puanı veriyordu. Mina'nın tercihleri yanlış kaydedildiği için sistem onun gerçekten kullandığı yolları yeterince tanımıyordu. Mesajın ne anlama geldiği açık anlatılmadığından, Mina bunu bir cezalandırma gibi hissetmişti. {kahraman} bu olayı kişisel kırgınlık başlığına değil, tasarım hatası başlığına ekledi. Bir kullanıcının sistemin ne yaptığını anlayamaması, yalnızca onun bilgisizliği sayılmamalıydı.
---
@omurga
{kahraman} akşam büyükbabasıyla yürüyüşe çıktı. Büyükbabası her gün aynı parkta yavaş adımlarla dolaşır, kestirme yolları sevmezdi. HAFIZA ona sürekli daha kısa rotalar öneriyordu. Bir gün, “Kısa yolum hazır,” yazan ekranı eliyle kapatmıştı.

“Niçin yeni rotayı denemiyorsun?” diye sordu {kahraman}.

“Çünkü benim yürüyüşüm bir yere en hızlı ulaşmak için değil,” dedi büyükbabası. “Eski çınarın önünde biraz durmayı seviyorum. Orada gençliğimde oturduğum bankın yerini hatırlıyorum. Makine bana daha kısa yol önerince yanlış bir şey yapmıyorum ki.”

{kahraman} güldü. “HAFIZA galiba insanların hep aynı amaçla yürüdüğünü sanıyor.”

Büyükbabası ciddi bir ifadeyle ona baktı. “Daha önemlisi, bütün amaçlarımı bilmek zorunda değil.” Sonra eski bir hikâye anlattı. {kahraman:ilgi} büyükannesiyle tanıştığı gün de o parkta yürümüştü. O anıyı anlatmak istemediği günler oluyordu. Parka yürümeye devam etmesi, hikâyeyi her seferinde paylaşmayı kabul ettiği anlamına gelmiyordu.

Ertesi sabah {kahraman} deney raporuna yeni bir başlık açtı: İnsanın söylediğiyle sistemin tahmin ettiğini ayırmak. Büyükbabasının parkta durduğu yeri kaydetmedi. Bu bilgi, tasarımın sorununu anlatmak için gerekli değildi. Yalnızca insanların her zaman verimliliği en yüksek yolu istemeyebileceğini belirtti.
---
@omurga
Kulüpte {yoldas:yalin|bir arkadaş} buna itiraz etti: “Ama kişisel önerileri azaltırsak otobüsler boş dolaşabilir.”

{kahraman} itirazı bekliyordu. “Her şeyi azaltmak değil, hizmet için gerekli olanı seçmek istiyoruz. Araçların hangi saatlerde dolu olduğunu bilmek için bütün yolcuların nerede durup ne düşündüğünü öğrenmek şart değil.”

Mina karşılarına üç örnek yazdı: anlık doluluk sayısı, konumdan bağımsız rota tercihi, kişinin aylar önceki özel ziyareti. “Bunların hepsi aynı veri değil,” dedi. “Hangisi hangi karara gerçekten yardım ediyor, bunu soralım.”
---
@omurga
Öğrenciler şehir tasarım yarışmasına sıradan bir sunum hazırlamak istemedi. Bunun yerine küçük bir HAFIZA modeli kurdular. {yoldas:yalin|bir arkadaş} ekranların ve sensörlerin tasarımını yaptı, Mina sesli ve dokunarak kullanılabilir seçenekleri denetledi, {kahraman} ise sistemin hangi veriye neden ihtiyaç duyduğunu gösteren kılavuzu yazdı.

Birinci kutu anlık ihtiyaç adını taşıyordu. Örneğin durakta o anda bekleyen yolcu sayısı, otobüsün doluluğunu hesaplamak için kullanılıyordu. Yolcuların isimleri tutulmuyordu. İkinci kutu gönüllü tercih idi. Bir kişi isterse az merdivenli ya da sesli yönlendirmeli bir rota seçebiliyor, tercihlerini sonradan silebiliyordu. Üçüncü kutu ise gerekçeli istisna başlığını taşıyordu; burada veri kullanılacaksa bunun amacı ve sınırı açıkça belirtiliyor, ilgili yetkili onayı ve denetim kaydı gerekiyordu.

{kahraman} modelleri tanıtırken tek bir iddiada bulunmamaya dikkat etti. “Bu düzen bütün sorunları yok etmeyecek,” dedi. “Amacımız bir hizmeti yürütmek için en az neye ihtiyaç duyulduğunu sormak.” Yarışmanın ön jürisi ona şu soruyu yöneltti: “Bir veri daha toplarsanız hizmet biraz daha iyileşebilir. Neden toplamayacaksınız?”
---
@omurga
{kahraman} birkaç saniye düşündü. “Önce iyileşmenin ne olduğunu ölçmeliyiz. Sonra bunun kişiye getirdiği riski, başka yöntemle aynı faydanın sağlanıp sağlanamayacağını değerlendirmeliyiz. Yalnızca toplayabiliyoruz diye toplamak iyi bir gerekçe değil.”

Jüri üyesi itirazını sürdürdü. “İnsanlar bazen ne istediklerini bilmiyor.”

Mina söze girdi: “O zaman sistemi daha anlaşılır yapmalı, kullanıcılara seçim yapabilecekleri bilgi vermeliyiz. Onlar yerine her şeyi seçmek çözüm değil.”

{yoldas:yalin|bir arkadaş} modelin son ekranını açtı. Burada örnek bir otobüs durağı vardı. Ekranın üstünde tek bir soru görünüyordu: Daha kolay ulaşım için hangi desteği istersin? Altında seçenekler ve “Şimdi değil” tuşu bulunuyordu. Böylece bir yolcu, sistemin kendi geçmişini ezbere bilmesine gerek olmadan yardım alabiliyordu.
---
@omurga
Yarışma için hazırladıkları model, Güneşkent'in bir mahallesinde üç günlük gönüllü denemeye seçildi. Belediye bunun büyük bir uygulama olmadığını, yalnızca tasarımın kullanılabilirliğini inceleyeceklerini açıkladı. {kahraman}, “Mahalledeki herkes bilgilendirilmeli,” diye önerdi. Murat Bey buna katıldı; test duraklarına neyin denenmekte olduğunu anlatan açık levhalar kondu. İsteyen eski yönlendirme sistemini kullanmaya devam edebiliyordu.

İlk sabah işler fena gitmedi. İnsanlar anlık doluluk ekranını kolayca anladı. İki öğrenci, aileleriyle birlikte sesli yönlendirmeyi denedi. Ancak öğle saatlerinde yağmur başlayınca öneri sayısı arttı. Otobüslerden biri planlanandan erken dolmuş, yeni sistem bu değişikliği birkaç dakika gecikmeyle göstermişti. Yaşlı bir yolcu, boş sandığı otobüse bindiğinde ayakta kalmak zorunda kaldı.[[deyim:hr112_agirlik]] Dünyanın en iyi fikrini kurduklarını sanmıştı; oysa tek bir gecikme bile gerçek bir insanın gününü zorlaştırmıştı.

{yoldas:yalin|bir arkadaş} hatayı buldu: Otobüs doluluk sayısını gönderen küçük sensör bir süre bağlantı kaybetmişti. Eski tasarımda veri gelmezse son sayı ekranda kalıyordu. Yeni düzende bunun yerine “Doluluk bilgisi güncel değil” uyarısı gösterilmesi gerekiyordu. Fakat test uygulamasındaki bu özellik, yanlışlıkla kapatılmıştı.
---
@omurga
“Böyle bir hata yüzünden bütün denemeyi iptal ederler mi?” diye sordu {yoldas:yalin|bir arkadaş}.

“Bilmiyorum,” dedi {kahraman}. “Ama saklayamayız.”

Mina, yaşlı yolcuyla konuşmak için belediye görevlisinden yardım aldı. Adam kısa bir özürden fazlasını istedi. “Bana neyin yanlış gittiğini söyleyin,” dedi. “Yarın aynı otobüse bineceğim. Ekrana güvenebilir miyim?”

Çocuklar hata kaydını gösterdi, düzeltilen özelliği anlattı ve deneme bitene kadar güncel olmayan bilgilerin açıkça belirtileceğine söz verdi. Adam bunun makul olduğunu söyledi. “Ben sizden kusursuz olmanızı istemiyorum,” diye ekledi. “Yanlış yapınca gerçeği söylemenizi istiyorum.” {kahraman} o cümleyi hiçbir jüri ödülünden daha önemli buldu.
---
@omurga
Üç günlük denemeden sonra katılanlara tercihlerini silmek isteyip istemedikleri soruldu. İnsanların çoğu yalnızca anlık durak sayımı kullanmıştı; bu nedenle adlarıyla ilişkilendirilmiş bir kayıt zaten yoktu. Bazıları sesli yönlendirme tercihini saklamak istedi. İki kişi ise geçmiş seçimlerinin sistemden kaldırılmasını talep etti. {kahraman}, {kelime:hr112_minimizasyon} sadece başlangıçta az bilgi toplamak olmadığını anladı. Verinin artık gerekli olmadığı zamanı belirlemek de aynı derecede önemliydi.

Sistemin eski sürümünü kullanan bir kişi, “Ben bütün geçmiş yolculuklarımı sildirmek istiyorum,” dediğinde belediye kayıt masasındaki görevli bir form uzattı. Formun başında uzun teknik kelimeler vardı. Mina yüksek sesle okuduğu metnin ne demek istediğini anlayamadı. “Bir hakkı kullanabilmek için önce bu kadar zor bir dili öğrenmemiz mi gerekiyor?” dedi.

Bunun üzerine kulüp iki sayfalık açıklamanın tek sayfalık, anlaşılır bir sürümünü hazırladı. Ancak Deniz Hanım, hukuki metni kendi başlarına değiştiremeyeceklerini hatırlattı. Resmî açıklama birimiyle çalışarak sade bir bilgilendirme katmanı eklediler. Böylece doğruluk korunurken anlaşılabilirlik arttı. “**Kolay anlatmak, eksiltmek değildir**,” dedi öğretmenleri. “Bazen anlatanın konuyu daha iyi anlamasını gerektirir.”
---
@omurga
{kahraman} ertesi gün büyükbabasıyla durakta karşılaştı. Eski sistemden gelen bir öneri hâlâ ekranda görünüyor, adamı parkın kısa yoluna çağırıyordu. {kahraman} ona ayarları değiştirmeyi teklif etti. Büyükbabası durup düşündü. “Önce seçeneklerimi bana anlat,” dedi. {kahraman} tek tek açıkladı: geçmiş alışkanlıkların kullanılmasını durdurmak, kişisel öneri geçmişini temizlemek, yalnızca anlık ulaşım bilgisi almak. Büyükbabası sonuncusunu seçti.

“Bunu senin yerine ben seçseydim daha çabuk biterdi,” dedi {kahraman}.

“Doğru,” dedi büyükbabası. “Ama benim kararım olmazdı.”

Bu kısa konuşma {kahraman:ilgi} zihninde kaldı. Yardım etmek ile kişinin iradesini elinden almak arasındaki çizgi, bazen yalnızca bir soruyu ne zaman ve nasıl sorduğunda saklıydı.
---
@omurga
Güneşkent gazetesi çocukların projesine yer verdiğinde ilgi büyüdü. Bir grup şehir sakini yeni tasarımı hemen bütün duraklarda görmek istedi. Başka bir grup ise kişisel kayıtların azaltılmasının belediyenin trafik araştırmalarını zayıflatacağından korkuyordu. Kent Konseyi iki tarafı dinlemek için toplantı düzenledi. {kahraman} konuşmadan önce iki görüşün de güçlü yanlarını not etti; tartışmayı bir yarışma gibi yönetmek istemiyordu.

Toplantıda ulaşım planlamacısı Derya Hanım, geçmiş seyahat verilerinin yoğunluğu anlamakta kullanıldığını anlattı. “Sadece anlık sayılara bakarsak bayram öncesi hangi hatların kalabalıklaşacağını öngörmek zorlaşabilir,” dedi. Bu, {kahraman:ilgi} şimdiye kadar yeterince düşünmediği bir itirazdı. Projelerinin bütün geçmiş verileri gereksiz saydığını sananlar olabilirdi.

{yoldas:yalin|bir arkadaş} bu kez el kaldırdı. “Biz geçmiş verilerin hiç kullanılmamasını önermedik,” dedi. “Kişiye bağlanması gerekmeyen toplam istatistiklerin kullanılmasını, amaçların açıkça söylenmesini ve geçmiş kayıtların süresiz tutulmamasını önerdik.” Derya Hanım başını salladı. “Bu tartışılabilir bir yaklaşım. Fakat istatistiklerin de küçük gruplarda kişileri dolaylı olarak tanıtmaması gerekir. Bazı mahallelerde bir durakta çok az kişi bulunuyor.”
---
@omurga
{kahraman} bir not daha ekledi: Kimliksiz görünen veriler de bazen kişi hakkında ipucu verebilir. Daha önce yalnızca isimleri silmenin yeterli olacağını düşünmüştü. Veri korumak düşündüğünden daha kapsamlı bir çalışmaydı. Konseyden tüm sistemi değiştirmelerini istemek yerine, pilot uygulamayı bağımsız uzmanların ve mahalle temsilcilerinin izlemesini teklif etti.

Toplantının ardından bir gazeteci {kahraman:yonelme}, “HAFIZA'yı yenebildin mi?” diye sordu. {kahraman} soruyu düzeltti. “Bu bir insanla makine arasındaki maç değil. Bir şehrin teknolojiyle nasıl yaşayacağını birlikte tartışıyoruz.” Gazeteci gülümsedi ama {kahraman:ilgi} cümlesini olduğu gibi yazacağına söz vermedi. {kahraman} ertesi gün haber çıkınca başlığı ayrıca kontrol etmeye karar verdi.
---
@omurga
Araştırmanın son haftasında belediyenin veri merkezi için düzenlenen eğitim gezisine katıldılar. Geniş salonda soğutma sistemleri sessizce çalışıyor, ışıklı göstergeler duvarlara ince çizgiler düşürüyordu. {kahraman} makinelerin arasından geçerken HAFIZA'nın şehirdeki her insanı tek bir dev kutuda tutan bir varlık olmadığını öğrendi. Farklı hizmetlerin ayrı sistemleri vardı; bazıları birbiriyle konuşuyor, bazıları yalnızca belirli sonuçları paylaşıyordu.

Rehberleri bir tahtaya üç sözcük yazdı: Toplama, kullanma, saklama. Ardından dördüncüsünü ekledi: Silme. Mina neden silmenin ayrıca yazıldığını sordu. “Çünkü bir bilginin sonsuza kadar durması doğal bir zorunluluk değildir,” dedi rehber. “Ama onu güvenle kaldırmak da tasarım ister.”

Öğrenciler küçük bir simülasyonda veri sızıntısı yaşandığında ne olacağını gördüler. Gerçek kişilere ait kayıtlar kullanılmıyordu. Deney, bir uygulamanın ihtiyaç duymadığı hâlde tuttuğu yüzlerce alanın denetlenmesini zorlaştırdığını gösteriyordu. {yoldas:yalin|bir arkadaş} hangi alanların gerekli olduğunu işaretledi; {kahraman} her alanın karşısına kullanım gerekçesini yazdı. Boş kalan gerekçeler, toplanmaması gereken veri adaylarıydı.
---
@omurga
Ancak rehber yeni bir soru sordu: “Yanlış bir kararı düzeltmek için geçmiş kayıtları incelemeniz gerekirse?” {kahraman} hemen “Hiç kayıt tutmayalım” diyemedi. Bunun yerine kayıtların amacına uygun sınırlarla, gerekli süre kadar, yetkili erişimi ve denetimiyle ele alınabileceğini tartıştılar. Yasal ve teknik ayrıntıları uzmanların belirlemesi gerektiğini kabul ettiler.

Gezinin sonunda veri merkezinin boş eğitim odasına girdiler. Odada hiç ekran yoktu; yalnızca üç sandalye ve pencere vardı. {yoldas:yalin|bir arkadaş} şaşırdı. “Burası ne için?” Rehber cevap verdi: “Teknoloji kararlarını tartışırken bazen bütün göstergeleri kapatıp birbirimizi dinlemek için.” {kahraman} bunu duyunca gülümsedi. Bir şehir ne kadar akıllı olursa olsun, vatandaşlarının birbirine soru sormayı unutmaması gerektiğini düşünüyordu.
---
@omurga
Final sunumu öncesinde {kahraman} herkesten projelerine yöneltilebilecek en güçlü {kelime:hr112_itiraz} yazmasını istedi. {yoldas:yalin|bir arkadaş}, “Öngörü gücümüz azalabilir,” dedi. Mina, “Kullanıcılar seçeneklerin ne anlama geldiğini bilmeyebilir,” diye ekledi. {kahraman} kendi kâğıdına, Belediye yeterli kaynak ayıramayabilir yazdı. Başta bu itirazları jüri önünde saklamayı düşünmüştü; şimdi ise sunumun merkezine koymak istiyordu.

Deniz Hanım önerilerini okuyunca memnun oldu. “İyi bir savunma, yalnızca kendi haklılığını övmek değildir,” dedi. “Karşı görüşün neden makul görünebileceğini anlamak ve buna gerekçeli cevap vermektir.” {kahraman} sunumun başına küçük bir not koydu: Bu bir başlangıç tasarımıdır; gerçek dünya denetimi gerektirir.

O gün sınıfın bir köşesinde deneme yaptılar. {yoldas:yalin|bir arkadaş} sistemin enerji kullanımını anlattı. Mina, sesli yönlendirme tercihinin nasıl değiştirildiğini gösterdi. {kahraman} veri alanlarını açıklarken bir arkadaşları, “İnsanlar bu kadar ayara zaman ayırmak istemezse?” diye sordu. {kahraman} cevap verirken hiç kişiselleştirme yapmayan basit sürümün varsayılan seçenek olmasının önemini anlattı. Karmaşık tercihler isteyenler ek seçenekleri açabilecekti.
---
@omurga
Bir başka öğrenci, “Bu kadar temkinli olursanız şehir yavaşlar,” dedi. {kahraman}, “Belki bazı kararlar için biraz daha açıklama gerekir,” diye karşılık verdi. “Ama yanlış kararların düzeltilmesi de zaman ve kaynak tüketir. Hızlı olmayı tek başarı ölçüsü yapamayız.”

Prova bittikten sonra üçlü sessizce oturdu. Birbirlerine katılmadıkları konular hâlâ vardı. {yoldas:yalin|bir arkadaş}, sistemin daha çok veriyle daha isabetli tahminler yapabileceği bazı durumlar olduğunu savunuyordu. Mina ise kullanıcının anlayamadığı bir önerinin isabetli olsa bile sorun çıkarabileceğini düşünüyordu. {kahraman} bu anlaşmazlığın projelerini zayıflatmadığını fark etti. Onları daha iyi sorular sormaya zorlamıştı.

{kahraman} ertesi gün afişi hazırlarken bir kavramı özellikle değiştirdi. Önce “akıllı şehir her şeyi bilir” yazmayı düşünmüştü. Bunun yerine “akıllı şehir doğru soruları sorar” cümlesini seçti. Bilmekle tahmin etmek arasındaki farkı öğrendikçe ilk sözün kibirli olduğunu fark etmişti. Deniz Hanım afişe bakıp bunun da tartışmaya açık bir önerme olduğunu söyledi. {kahraman} rahatsız olmadı; bir fikir değerliyse iyi bir sorudan kaçmamalıydı.
---
@omurga
Küçük kardeşi Ömer gösteri için hazırladıkları kartlara bakıp “Bir durak bana nereye gideceğimi sorsa, ben de ona soru sorabilir miyim?” dedi. {kahraman} gülümsedi. “Elbette. Neden bu yolu öneriyorsun, hangi bilgiye dayanıyorsun, fikrimi nasıl değiştiririm diye sorabilirsin.” Ömer bir kartın arkasına iri harflerle “NEDEN?” yazdı. Kart çocukça görünüyordu ama araştırmanın en büyük sorusunu taşıyordu. {kahraman} onu çöpe atmadı; proje dosyasının içine, bütün tabloların ve grafiklerin önüne yerleştirdi. Bir gün sistem başka bir öğrenciye anlaşılmaz bir öneri sunduğunda, bu basit sorunun hâlâ işe yarayacağını umuyordu.
---
@omurga
Final günü salonda parlak afişler ve öğrencilerin kendi kurduğu modeller vardı. Kimileri hava kirliliğini azaltan ölçüm cihazları tasarlamış, kimileri su kullanımını daha anlaşılır gösteren ekranlar hazırlamıştı. {kahraman}, ilk kez yalnızca kendi fikirlerinin değil, başkalarının emeğinin de büyüklüğünü gördü. Yarışmada ödül almak güzel olacaktı ama asıl beklentisi kent yönetiminin sorularını ciddiye almasıydı.

Sunum sırası geldiğinde {yoldas:yalin|bir arkadaş} model durağın ışıklarını yaktı. Ekran otobüsün doluluğunu, beklenen geliş süresini ve bilginin güncellenme zamanını gösterdi. Mina sesli yönlendirme seçeneğini çalıştırdı. {kahraman} de üç veri kutusunu tanıttı. Ardından sahnede beklenmedik bir soru geldi. Kent Konseyi'nin genç üyelerinden biri, “Yeni sistemde benim tercihimi kim görebilir?” diye sordu.

{kahraman} görevli erişimlerini ve denetim kaydını anlattı. Genç üye devam etti: “Peki yanlış bilgi yüzünden zarar görürsem ne olacak?”

“Şikâyet etmek, düzeltme istemek ve gerektiğinde bağımsız bir incelemeye başvurmak için açık bir yol bulunmalı,” dedi {kahraman}. “İnsanların yalnızca bir ekranın doğru çalışmasını beklemesi yeterli değil.”
---
@omurga
Jüri üyelerinden biri yanındaki dosyayı kapattı. “Sizce mevcut HAFIZA'yı tamamen değiştirmeli miyiz?”

Bu soru için hazırlanmış tek cümlelik bir yanıtları yoktu. {kahraman} önce {yoldas:yonelme|bir arkadaşa}, sonra Mina'ya baktı. Üçü aylardır çalışırken bazı yönlerde farklı düşünmüştü. Sonunda {kahraman}, “Biz aşamalı bir değişim öneriyoruz,” dedi. “Önce gereksiz verileri belirlemek, kullanıcıların seçeneklerini anlaşılır kılmak, sonra bağımsız ölçümle nelerin iyileştiğini görmek istiyoruz. Mevcut sistemin yararlı kısımlarını yok saymıyoruz.”

Salonda birkaç kişi alkışladı. {kahraman} en çok, başta yalnızca teknolojiyi savunan {yoldas:ilgi|bir arkadaşın} gülümsemesine sevindi. O gülümseme karşılıklı dinlemenin küçük bir sonucuydu. Jüri son sorusunu yönelttiğinde Mina söze girdi: “Bir şehirde yaşamaya değer olan şey yalnızca hızlı hareket etmek değildir. Kimsenin geride kalmamasıdır.”
---
@omurga
Ödül töreninden iki saat önce yerel ağda sahte bir görsel dolaşıma girdi. Görselde {kahraman:ilgi} sunumundan alınmış bir fotoğrafın altına “Çocuklar Güneşkent'in bütün kayıtlarını sildirecek” yazılmıştı. Birkaç dakika içinde yüzlerce kişi bu iddiayı paylaşmıştı. {yoldas:yalin|bir arkadaş} telefonunu gösterirken sinirden gülüyordu. “Bütün sunumu dinleyip bunu mu çıkarmışlar?”

{kahraman} hemen karşılık vermek istedi. “Bizi yanlış anlayanların hepsi gerçeği bilsin!” diye bağırdı. Mina onu durdurdu. “Önce bu paylaşımın nereden geldiğini ve ne söylendiğini doğrulayalım.”

Üç arkadaş resmin ilk paylaşıldığı sayfayı bulmaya çalıştı. Görselin üzerine eklenmiş yazı, aslında bir tartışma hesabından yayılmıştı. Fotoğraf gerçekti ama altyazısı sunumdaki önerileri yanlış yansıtıyordu. Kaydı izlediklerinde {kahraman:ilgi} “verileri gerektiği kadar kullanmak” dediği bölüm açıkça duyuluyordu. Deniz Hanım'ın önerisiyle kısa, sakin bir düzeltme hazırladılar. Düzeltmede asıl sunumdan doğrulanabilir bir bölüm ve raporun halka açık özeti vardı.

“Elimizdeki yanlış haberi tekrar tekrar göstermeyelim mi?” diye sordu {yoldas:yalin|bir arkadaş}.
---
@omurga
“İnsanlara neyin doğru olduğunu anlatmak daha yararlı olabilir,” dedi Mina. “Yanlış iddiayı büyütmeye gerek yok.”

Bütün paylaşımlar silinmedi. Bazıları düzeltmeyi gördüğü hâlde önceki fikrini sürdürdü. {kahraman} bu duruma üzülse de internetin bir düğmeyle gerçeği kabul eden bir yer olmadığını anladı. Kanıt sunabilir, yanlış bilgiyi düzeltebilir, ama herkesin ne düşüneceğini kontrol edemezdi.

Ödül törenine döndüklerinde tören başlamıştı. {kahraman:ilgi} eli titriyordu. Deniz Hanım, “Sonuca değil, nasıl çalıştığınıza bak,” dedi. O an {kahraman} için en önemli başarı, eleştiriye kızdığı hâlde onu dinlemeyi; yanlış haberle karşılaşınca doğrulanabilir bilgiye dönmeyi öğrenmiş olmasıydı.
---
@omurga
Jüri raporları hazırlanırken öğretmenleri, çocukların son kez pilot mahalleden gelen görüşleri okumalarını istedi. Raporda tam yüz otuz iki yorum vardı. Bazıları bir cümlelik teşekkür, bazıları ayrıntılı eleştiriydi. Bir kişi ekran yazılarının güneş altında zor seçildiğini, diğeri bazı durakların çok kalabalık olduğu saatlerde sesli anlatımın duyulmadığını yazmıştı. {kahraman} önce bunları küçük tasarım hataları sandı. Mina, “Kullanamayan biri için küçük hata değildir,” dedi.

{yoldas:yalin|bir arkadaş} yorumları üçe ayırdı: doğrulanmış teknik sorunlar, kullanıcıların tercihleri ve yeni araştırma gerektiren iddialar. Böylece beğenilen bir özelliğin herkes için işe yaradığı varsayımını sorguladılar. Özellikle küçük çocuklar ile yaşlı yolcuların aynı düğmeleri aynı kolaylıkta bulmadığı görülüyordu. Mina, deneme sırasında sadece kendi deneyimlerinin yetmeyeceğini, daha çeşitli kullanıcılarla sınama yapmak gerektiğini hatırlattı.

Bir yorumda “Sistem neden seçimimi sormadan bildiğini düşünüyor?” yazıyordu. {kahraman} bu cümleyi okuyunca aylar önceki ilk durak mesajını hatırladı. O kişinin de kendi özel hikâyesi olabilirdi. Raporun içinde yalnızca gerekli olanı aktardılar; yorum sahibinin kim olduğunu araştırmadılar. {yoldas:yalin|bir arkadaş} bunu yadırgamadı. Artık bir insanı anlamakla onun bütün bilgilerine sahip olmak arasındaki farkı daha iyi biliyordu.
---
@omurga
Öğretmenlerinin önerisiyle rapora “Çözülemedi” başlıklı bir sayfa eklediler. Bu sayfada, hangi soruların henüz cevaplanmadığı ve sonraki testte nasıl araştırılacağı açıklanıyordu. {kahraman} bu sayfayı gizlemek istemedi. Tam tersine, onu sunumun sonuna koydu. Çünkü doğru bir araştırmanın yalnızca ulaşılan sonuçlarla değil, hangi sorulara henüz yanıt veremediğini dürüstçe belirtmesiyle de değer kazandığını anlamıştı.
---
@omurga
Jüri birincilik ödülünü başka bir gruba verdi: Kentin boşalan yağmur suyu depolarını izlemek için düşük maliyetli bir ölçüm ağı tasarlamışlardı. {kahraman} içinden kısa bir hayal kırıklığı geçirdi, sonra arkadaşlarını alkışladı. Kendi projeleri ise toplumsal etki ve kullanıcı katılımı alanında özel bir değerlendirme aldı. Bununla birlikte Kent Konseyi, pilot uygulamanın sonuçlarını inceleyecek bir çalışma grubuna öğrencileri davet etti.

Bu davet, kupadan daha zor bir sorumluluktu. Çünkü artık anlatılacak güzel fikirler kadar izlenecek sorunlar da vardı. {kahraman}, toplantılara tek başına katılmayacaklarını söyledi. Mina'nın erişilebilirlik gözlemleri, {yoldas:ilgi|bir arkadaşın} teknik itirazları ve farklı mahallelerin görüşleri birlikte dikkate alınmalıydı. Konsey başkanı bunu kabul etti. Çalışma grubunun ilk toplantısı halka açık yapılacak, çocuklar aileleri ve öğretmenlerinin desteğiyle katılabilecekti.

Evde babası kutlama pastası hazırlamıştı. Ömer masaya oturunca “Artık otobüs durağı bana ödevimi de hatırlatır mı?” diye sordu. {kahraman} güldü. “İstersen bir hatırlatıcı kullanırsın. Ama onun bütün hayatını bilmesi gerekmiyor.”
---
@omurga
Büyükbabası çatalını bıraktı. “Peki parkın uzun yolunu seçtiğimde artık bana yanlış yoldasın demeyecek mi?”

“En azından bunun bir tercih olabileceğini anlaması için çalışıyoruz.”

Büyükbabası başını salladı. “Şehir bizi hatırlayabilir. Ama bize kim olduğumuzu emretmesin.”

Bu söz {kahraman:yonelme} çok tanıdık geldi. Araştırmanın ilk gününde durak ekranda onun mutsuz olduğunu iddia etmişti. Şimdi {kahraman}, tahminlerin bir öneri olarak kalabileceğini, insanın hayatının yerine geçmemesi gerektiğini daha iyi biliyordu. {isaret:anahtar}
---
@omurga
Birkaç ay sonra pilot uygulamanın yeni sürümü mahalle duraklarına kuruldu. Duraklar hâlâ otobüslerin doluluğunu gösteriyor, isteyenlere sesli yönlendirme yapıyordu. Fakat kimse nedenini anlamadığı kişisel puanlar görmüyordu. Öneri yapan sistem, bunun bir tahmin olduğunu açıkça belirtiyor; kişi isterse tercihini değiştirebiliyordu. Belediye uzmanları, gereksiz kayıtların azaltılması ve silme süreçleri üzerinde çalışmaya devam ediyordu.

{kahraman} bir sabah aynı durağa geldi. Ekran bu kez yalnızca şunu yazdı: Bir sonraki araç dört dakika sonra gelecek. İstersen alternatif rotalara bakabilirsin. Müzik kursunu, kütüphaneyi, ablasıyla hazırladığı sürpriz projeyi anmadı. {kahraman} önce buna sevindi, sonra ekranın sessizliğinin tek başına başarı olmadığını hatırladı. Arkasında çok sayıda insanın düşüncesi, itirazı ve denetimi vardı.

Ablasıyla yaptıkları müzik kaydını okul gösterisinde ilk kez çaldılar. Parçanın adını Unutulacak Kadar Özel koymuşlardı. Dinleyenlerden bazıları bunun ne anlama geldiğini sordu. {kahraman} şöyle anlattı: “İnsan her şeyi bütün dünyaya anlatmak zorunda değil. Ama paylaşmak istediğinde sesinin duyulmasını da ister.”
---
@omurga
Gösteriden sonra {yoldas:yalin|bir arkadaş}, “Gelecek yıl enerji verimliliği projesi yapalım mı?” dedi. Mina, “Önce onu kimin kullanacağını düşünelim,” diye cevap verdi. {kahraman} ikisine baktı. Bir zamanlar sıradan bir durak mesajıyla başlayan huzursuzluk, arkadaşlarının dünyaya başka sorularla bakmasını sağlamıştı.

Otobüs geldi. {kahraman} bindiğinde ekran ona bir koltuk seçmedi, nereye gideceğini sormadan bildiğini iddia etmedi. Yalnızca yolculuğuna ilişkin gerekli bilgiyi sundu. {kahraman} camdan dışarı baktı. 2055'in şehri hâlâ ışıklı, hızlı ve karmaşıktı. İnsanlar kimi gün kestirme yoldan gidiyor, kimi gün parkta gereksiz görünen uzun bir yürüyüş yapıyordu. Şehir onları hatırladıkça daha yararlı olabilir, ama kimi şeyleri unutmayı öğrendikçe daha saygılı da olabilirdi. {kahraman} bunun tek kişinin çözebileceği bir sorun olmadığını biliyordu. Onu sevindiren, artık soruyu birlikte soran insanların bulunmasıydı. Bu, geleceğin en umut verici yanıydı.
