---
baslik: "Üç Dakikalık Kesinti"
slug: "hr070-uc-dakikalik-kesinti"
fis_kodu: "HR-070"
tur: bilim
konu: hipotez_veri_dogrulama
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Bilgisayarlar aynı saatte kapanıyor. Gizemli bir saldırı mı, yoksa eski bir ayar mı?"
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
    - {id: hipotez_hr070, tur: lexeme, etiket: "hipotez", yuva: hr070_hipotez, islev: first_hint}
    - {id: zamanlayici_hr070, tur: lexeme, etiket: "zamanlayıcı", yuva: hr070_zamanlayici, islev: application}
    - {id: veri_hr070, tur: lexeme, etiket: "veri", yuva: hr070_veri, islev: application}
    - {id: deyim_hr070, tur: idiom, etiket: "Gözlerini dikmek", yuva: hr070_gozlerini_dikti, islev: application}
    - {id: kavram_hr070, tur: concept, etiket: "Aynı zaman, aynı neden ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Ekranlar kaçta kapandı?", secenekler: [{id: A, metin: "On bir kırk iki"}, {id: B, metin: "On iki"}, {id: C, metin: "Dokuz kırk"}, {id: D, metin: "On bir otuz"}], dogru: A, aciklama: "Ekranlar tam on bir kırk ikide birer birer karardı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 4, metin: "Genel elektrik kesintisi açıklaması neden zayıfladı?", secenekler: [{id: A, metin: "Laboratuvarın ışıkları yanmaya devam ediyordu ve diğer sınıfların bilgisayarları kapanmıyordu"}, {id: B, metin: "Işıklar hiç çalışmıyordu"}, {id: C, metin: "Bilgisayarlar çok yeniydi"}, {id: D, metin: "Sınıfta kimse yoktu"}], dogru: A, aciklama: "Elektrik kesintisi olsaydı ışıklar da sönerdi; diğer sınıflar da etkilenirdi."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 7, metin: "Kerem'in bu cümlesi neyi anlatır?", secenekler: [{id: A, metin: "İki olayın aynı zamanda olması, birinin diğerinin nedeni olduğunu kanıtlamaz"}, {id: B, metin: "Olaylar hiç birlikte olmaz"}, {id: C, metin: "Saat hiç kullanılmamalı"}, {id: D, metin: "Her olay aynı nedenden doğar"}], dogru: A, aciklama: "Zamansal birliktelik nedensellik için yeterli kanıt değildir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 11, metin: "Metinde geçen zamanlayıcı ne işe yarar?", secenekler: [{id: A, metin: "Belirlenen saatte bir işlemi otomatik başlatan ya da durduran düzenek"}, {id: B, metin: "Bir tür ekran"}, {id: C, metin: "Bir çeşit kablo"}, {id: D, metin: "Bir oyun kartı"}], dogru: A, aciklama: "Zamanlayıcı, önceden ayarlanmış saatte bir işlemi yürütür."}
deyim_cumleleri:
  hr070_gozlerini_dikti: "Dersin birinde kesinti bekledikleri saat yaklaşırken herkes gözlerini saate dikti."
---
@omurga
Saat tam on bir kırk iki olduğunda bilgisayar ekranları birer birer karardı. Önce ön sıradaki Eylül'ün ekranı söndü, ardından arkasındaki {yoldas:ilgi|bir arkadaşın}. Son olarak laboratuvarın duvarındaki büyük ekran da kapandı. Oysa sınıf, okul gazetesi için hazırladığı dijital sergiyi o anda sunacaktı. {isaret:gunes}

"Biri sistemi kapattı!" diye bağırdı {yoldas:yalin|bir arkadaş}. Yanında oturan {kahraman} sandalyeye yaslandı. "Kim?" {yoldas:yalin|bir arkadaş} cam kenarını gösterdi. "Dün akşam buraya giren öğrenciler vardı. Belki onların yüzünden." {kahraman} bu sözden rahatsız oldu. "Bir şey olduğunu gördük ama kimin yaptığını bilmiyoruz," dedi. Öğretmenleri Burcu Hanım, bilgisayarlara dokunmamalarını ve yerlerinde sakin biçimde beklemelerini istedi.

Okulun bilgisayar laboratuvarında son günlerde garip bir kesinti yaşanıyordu. Derslerin bir bölümünde, neredeyse aynı saatte ekranlar kapanıyor; birkaç dakika sonra sistem yeniden kullanılabilir hâle geliyordu. Teknik sorumlu daha önce sorunu kısa süreli bir elektrik dalgalanması sanmış, ancak diğer odalarda böyle bir durum görülmediğini fark etmişti. Burcu Hanım, öğrencilerin teknik ayarlara erişmeden gözlem yapmasını önerdi.
---
@omurga
"Bize düşen şey bilgisayarın içine girmek değil," dedi. "Sorunun ne zaman ve hangi koşullarda ortaya çıktığını güvenli biçimde kaydetmek. Gerisini yetkili kişi inceleyecek." Eylül defterine büyük bir başlık attı: Üç Dakikalık Kesinti. {yoldas:yalin|bir arkadaş}, bu adın bir gizem kitabına benzediğini söyledi. {kahraman} ise altına ilk soruyu yazdı: "Kesinti gerçekten üç dakika mı sürüyor?"

İlk gün, çocuklar başlangıç ve bitiş saatlerini farklı biçimde hatırladıklarını gördü. {yoldas:yalin|bir arkadaş} "on bir kırk" diyordu, Eylül "on bir kırk iki" diye ısrar ediyordu. Burcu Hanım, bir sonraki gözlemde sınıfın duvar saatini tek referans olarak kullanmalarını önerdi. "Hafızamız faydalıdır, ama zaman ölçerken kayıt almak gerekir," dedi. {kahraman} iki sütunlu bir tablo çizdi.
---
@omurga
Ertesi gün laboratuvar kullanılmadan önce teknik sorumlu Can Bey geldi. Bilgisayarların eğitim ağına bağlı olduğunu, öğrencilerin ayarlara dokunmaması gerektiğini anlattı. Çocuklardan yalnızca ne gördüklerini ve ne zaman olduğunu yazmalarını istedi. Ders sırasında belirlenen zamanda ekranlar yine kapandı. {kahraman} süreyi not etti: iki dakika elli yedi saniye. {yoldas:yalin|bir arkadaş} hayal kırıklığına uğradı. "Adı üç dakika ama tam üç dakika bile değil," dedi. Eylül güldü. "Yaklaşık üç dakika diyebiliriz."

Grup üç olası açıklama hazırladı. Birincisi genel elektrik kesintisiydi. İkincisi bilgisayarların aynı anda başlayan bir program yüzünden kapanmasıydı. Üçüncüsü, ağ veya yönetim ayarlarıyla ilgili zamanlanmış bir işlemdi. Burcu Hanım bunun yalnızca birer {kelime:hr070_hipotez} olduğunu, henüz hiçbirinin doğrulanmadığını belirtti. {yoldas:yalin|bir arkadaş} hemen üçüncüyü işaretledi: "En gizemli olan bu."
---
@omurga
{kahraman}, "Gizemli olması doğru olmasını sağlamaz," dedi. Eylül sorunu sınıflandırdı: "Önce odadaki lambalar sönüyor mu? Diğer sınıflarda aynı anda ne oluyor?" Öğretmen gerekli izinleri alarak gözlem yapabilecekleri bilgileri topladı. Kesinti sırasında laboratuvarın ışıkları yanmaya devam ediyordu. Diğer sınıfların bilgisayarları aynı anda kapanmıyordu. Böylece genel elektrik kesintisi açıklaması zayıfladı.

Tam o sırada {yoldas:yalin|bir arkadaş}, başka sınıftan bir öğrencinin laboratuvara girip çıktığını gördüğünü anlattı. Eylül, "Bunu soruyla ilişkilendirmek için nedenimiz var mı?" dedi. {yoldas:yalin|bir arkadaş} duraksadı. Öğrencinin yalnızca kitap bıraktığını hatırlıyordu. "Yok," dedi. "Ama acaba..." Burcu Hanım araya girdi: "Biri hakkında kanıtsız kuşku üretmeyelim. Sistem arızası insanları suçlamak için bahane olamaz."
---
@omurga
Kesinti ilk kez yaşandığında sınıfta çizim yapan Bora'nın bütün çalışması kaybolmuştu. Bora yeniden başlamak zorunda kalınca öfkelenmiş, klavyenin başında uzun süre sessiz kalmıştı. {kahraman}, "Keşke dosyanı daha önce kaydetseydin," deyince Bora kendisini suçlanmış hissetti. "Sanki sorunu ben çıkardım," dedi. {kahraman} söylediklerinin yanlış anlaşıldığını fark etti. "Seni suçlamak istemedim," diye cevap verdi. "Ben de bazen kaydetmeyi unutuyorum. İstersen çalışmanı birlikte yeniden yapabiliriz." İkisi teneffüste yan yana oturup çizimin ilk hâlini hatırlamaya çalıştı. Bu küçük yardım, teknik bir sorunun duygusal etkisini de görünür kıldı.

Burcu Hanım, kesinti yaşayan sınıflarda sık görülen tepkileri tahtaya yazdı: sinirlenmek, paniklemek, birini suçlamak, yardım istemek, önlem almak. Çocuklardan hangisini seçtiklerini ve bunun nedenini düşünmelerini istedi. {yoldas:yalin|bir arkadaş}, "Ben hemen suçlu aradım," dedi. Eylül, "Ben de ekranım kapanınca ilk önce korktum; sonra ne zaman olduğunu düşündüm," diye anlattı. Burcu Hanım, duyguların gerçek olduğunu, fakat bir karar verirken kanıtlara da ihtiyaç duyulduğunu vurguladı. {yoldas:yalin|bir arkadaş} ilk defa öfkesinin onu acele bir sonuca götürdüğünü fark etti.
---
@omurga
Laboratuvarın kapısında o gün bir duyuru vardı: "Öğrenci hesaplarını koruyun. Parola paylaşmayın. Teknik arıza için öğretmene haber verin." Eylül duyuruyu okuyup "Kesinti için ne yapabiliriz?" diye sordu. Burcu Hanım, dosyalarını okulun onaylı sistemine zamanında kaydetmelerini, işleri bölümlere ayırmalarını ve bir sorun gördüklerinde kendilerinin yönetim ayarlarını değiştirmeye çalışmamalarını söyledi. Çocuklar teknolojiyi kullanmanın yalnızca düğmelere basmak değil, güvenli çalışma alışkanlıkları edinmek olduğunu öğrendi.

İlk üç günün kayıtları yan yana konunca ilginç bir fark ortaya çıktı. Bir öğrencinin saati iki dakika ilerideydi. Başka birinin saatinde saniyeler bile görünmüyordu. Bu yüzden hepsi aynı olayı farklı anlarda başlamış gibi anlatmıştı. {kahraman}, "Ölçüm için ortak bir kaynak seçmemiz gerekiyor," dedi. Burcu Hanım sınıfın duvar saatini gösterdi; daha güvenilir olması için teknik görevlinin okul saatini kontrol etmesini istedi. Böylece öğrenciler, ölçüm araçlarının uyumu konusunda düşünmüş oldu. Doğru bir tablo çizmek, yalnız güzel cetvel kullanmak değil, {kelime:hr070_veri} nasıl toplandığını da bilmekti.
---
@omurga
Üçüncü gün {yoldas:yalin|bir arkadaş}, bilgisayarların hepsinin aynı anda kapandığını söylemişti. Eylül ise ilk ekranla son ekran arasında birkaç saniye fark gördüğünü hatırlıyordu. {kahraman}, "Bir sonraki gözlemde sayalım," dedi. Ancak Burcu Hanım, sırf kesintiyi görmek için ders akışını riske atmayacaklarını hatırlattı. Yetkili teknik görevli izin verdiğinde sınıf yalnızca kayıt alacaktı. Bir sonraki gözlemde ekranların neredeyse aynı anda kapandığı görüldü. {yoldas:ilgi|bir arkadaşın} anlatımı genel olarak doğruydu ama "hepsi tam aynı saniyede" ifadesi ölçülmeden söylenemeyecek kadar kesindi. Bunu defterine yazıp düzeltti.

Sınıfa yeni katılan Yasin, önceki gün laboratuvarda başka bir grubun bulunduğunu anlattı. {yoldas:yalin|bir arkadaş} yine kuşkulandı. "Onlar ayrıldıktan sonra kesinti başladı," dedi. Yasin bu söze şaşırdı. "Ben sadece ders yaptıklarını söyledim," diye karşılık verdi. {kahraman} iki olayın art arda gerçekleşmesinin birinin diğerine neden olduğunu kanıtlamadığını anlattı. Burcu Hanım sınıfa günlük bir örnek verdi: Yağmurdan önce sokakta çok araba görülebilir, ama arabaların görünmesi yağmurun nedeni değildir. Çocuklar sırayla başka örnekler buldu. {yoldas:yalin|bir arkadaş}, "Aynı saatte olmak, aynı sebepten olmak değildir," cümlesini defterine yazdı.
---
@omurga
Bu konuşmadan sonra {yoldas:yalin|bir arkadaş}, hakkında kuşku uyandırdığı öğrenciyle konuşmak istedi. Öğretmen eşliğinde karşılaştıklarında özür diledi. "Seni bir şeyle suçlayacak bilgim yoktu. Yine de adını söyledim," dedi. Diğer öğrenci, birkaç arkadaşının kendisine tuhaf baktığını, bundan rahatsız olduğunu anlattı. {yoldas:yalin|bir arkadaş} özrün tek başına yeterli olmayabileceğini fark etti. Sınıf grubunda belirsiz söylentiyi düzeltmeyi kabul etti. Böylece araştırmanın insan ilişkileri üzerindeki sorumluluğu da ortaya çıktı.

Can Bey gözlem defterini ilk incelediğinde {yoldas:ilgi|bir arkadaşın} çizdiği bir tabloyu özellikle beğendi. Tablo her gün için tarih, saat ve olayın süresini ayrı gösteriyordu. "Bununla nereye bakacağımızı daha kolay seçebiliriz," dedi. Ama teknik sorumlu, öğrencilerin yardım etmiş olmasının kendilerine sistem yönetim yetkisi vermediğini de açıkladı. {yoldas:yalin|bir arkadaş} ilk anda bunun güvenilmediği anlamına geldiğini sandı. Can Bey, "Görev ayrımı güvenliğin bir parçasıdır," dedi. "Pilot uçağı kullanır, teknisyen bakım yapar. İkisi de önemli ama görevleri aynı değildir."
---
@omurga
Sınıfın veri tablosu daha sonra matematik dersinde de kullanıldı. Öğrenciler yaklaşık üç dakikalık süreleri karşılaştırdı, farklı günlerdeki küçük farkları inceledi. Bir çocuk, "Ortalama süreyi bulduk, artık nedeni biliyoruz," dedi. {kahraman}, "Ortalama bize sürenin nasıl değiştiğini gösterir, ama nedenini tek başına söylemez," diye düzeltti. Matematik öğretmenleri bu ayrımı geliştirdi. Veriler hangi soruya cevap veriyorsa o sorunun sınırında kalmak gerekiyordu. Kesintinin süresini ölçmek bir aşamaydı; nedeni için teknik kayıtlar ve farklı kanıtlar gerekiyordu.

Bora'nın çizimi okul gazetesi için önemliydi. Üç arkadaş ona yeniden hazırlamasında yardımcı olurken projenin aslında bir çevre temalı dijital sergi olduğunu hatırladılar. Kapanan ekranlar yüzünden günlerdir hiçbir yeni tasarım yapmamışlardı. "Gizem bizi işimizden uzaklaştırdı," dedi Eylül. Burcu Hanım, sorunu araştırırken asıl amaçlarını unutmamalarını önerdi. Böylece görevleri paylaştırdılar: Eylül gözlem çizelgesini sürdürecek, {kahraman} sonuçları düzenleyecek, {yoldas:yalin|bir arkadaş} teknik sorumluya iletilecek soruları hazırlayacak, diğerleri sergi tasarımına devam edecekti. Sorunun çözümü sınıfın bütün zamanını yutmamalıydı.
---
@omurga
[[deyim:hr070_gozlerini_dikti]] Eylül bunun kendi öğrenmelerini engellediğini fark etti. Burcu Hanım, "Gözlem yaparken yaşamı durdurmamalıyız," dedi. Çocuklar bilgisayarlarına dönüp çalışmaya devam etti. Saat geldiğinde ekranlar yine kapandı; ama bu defa kimse paniklemedi. Kayıt yapıldı, öğretmene haber verildi ve önceden belirlenen güvenli alternatif etkinliğe geçildi. Bir sorun karşısında hazırlıklı olmak, sorunun hemen çözülmesinden bağımsız bir beceriydi.

Can Bey üçüncü gün laboratuvara geldiğinde gözlem defterini inceledi. Çocuklardan dosyalarını kaydetmelerini, sonra gerekli teknik kontrolü kendisine bırakmalarını istedi. Eylül, laboratuvarın daha önce başka bir amaçla kullanılıp kullanılmadığını sordu. Can Bey, bir süre önce burada düzenli bakım saatleri için ayarlar yapıldığını, fakat güncel ders programının değiştiğini söyledi. {kahraman} dikkat kesildi. "Yani eski plan hâlâ çalışıyor olabilir mi?"
---
@omurga
Can Bey, "Bu araştırılabilir bir olasılık," dedi. Yönetim ekranındaki zamanlanmış görevleri yetkili hesabıyla inceledi. Çocuklar uzaktan yalnızca işlemin sonucunu öğrenmek için bekliyordu; parolalar veya teknik ayrıntılar gösterilmiyordu. Birkaç dakika sonra Can Bey laboratuvarın bazı bilgisayarlarını belirli saatte oturumdan çıkarıp kısa bir bakım sürecine alan eski bir {kelime:hr070_zamanlayici} bulunduğunu açıkladı.

"Demek biri bize şaka yapmamış," dedi {yoldas:yalin|bir arkadaş}. {kahraman}, "Henüz bütün ayrıntıyı öğrenmedik ama kesintinin düzenli saatini bu ayar açıklıyor," diye karşılık verdi. Can Bey, ayarın ders saatleriyle çakıştığını, ilgili görevlilerle birlikte uygun bir zamana taşınacağını söyledi. Çocuklar bu işlemi izlemek yerine defterlerine buldukları sonucu yazdı: Kesintinin zamanı, eski bakım planıyla örtüşüyor.

Bir sonraki ders aynı saatte geldiğinde herkes duvar saatine bakıyordu. On bir kırk bir, on bir kırk iki, on bir kırk üç... Ekranlar açık kaldı. {yoldas:yalin|bir arkadaş} sessizce alkışladı; sınıf ona katıldı. Eylül, "Bir kez olmaması yeterli mi?" diye sordu. Burcu Hanım, "İyi bir soru," dedi. "Tekrar gözlemlemek, çözümün işe yarayıp yaramadığını anlamamızı sağlar."
---
@omurga
Bir hafta boyunca sınıf kesinti yaşanıp yaşanmadığını not etti. Sorun tekrarlanmadı. Can Bey de teknik kayıtlarla çözümü doğruladı. {kahraman} sonuca ulaşmanın yalnız "ayar bulundu" demek olmadığını, yapılan düzeltmenin gözlenmesini de gerektirdiğini fark etti. Bu yaklaşımı matematikte çözdüğü sorulara benzetti: İşlemi yapmak kadar sonucu kontrol etmek de önemliydi.

Okul gazetesi için hazırlanan dijital sergi nihayet açıldığında çocuklar ilk sayfaya kesintinin öyküsünü koydu. Fakat insanları suçlayan bir başlık seçmediler. Üç Dakikalık Kesinti: Bir Sorunu Nasıl Araştırdık? başlığını kullandılar. Altına zaman çizelgesini, hipotezlerini ve hangi kanıtın hangi açıklamayı desteklediğini yazdılar. Kişisel veriler, hesap bilgileri ve teknik güvenlik ayrıntıları yayımlanmadı.

Serginin açılışında {yoldas:yalin|bir arkadaş} söz aldı. "Başta birisinin bilerek yaptığını düşünmüştüm," dedi. "Ama elimde kanıt yoktu. En önemli öğrendiğim şey, sorunu çözerken arkadaşlarımı suçlamamayı öğrenmek." {kahraman} gülümsedi. Eylül ise, "Ben de küçük farkların önemli olduğunu gördüm. Yaklaşık üç dakika demek, tam üç dakika demek değildir," dedi.
---
@omurga
Burcu Hanım çocukların hazırladığı tabloyu panoya astı. Üç sütun vardı: Gözlem, Hipotez, Sonuç. Eylül, sonuna dördüncü bir sütun ekledi: Doğrulama. O kadar küçük bir sözcüktü ki sınıfın birkaç günlük çalışmasını özetliyordu. Çünkü bazen en güç sorun, birinin iyi bir fikri bulmasını değil, o fikrin gerçekten işe yarayıp yaramadığını kontrol etmesini beklerdi.

Teknik düzeltmeden önce Can Bey, öğretmenlere ayarın niçin yapılmış olabileceğini de açıkladı. Önceki dönem laboratuvar farklı saatlerde kullanılmış, düzenli bakım için boş olduğu düşünülen bir zaman seçilmişti. Yeni ders çizelgesi hazırlanırken bu ayarın unutulması, sistemin yanlış zamanda işlem yapmasına yol açmıştı. {kahraman}, "O zaman program kendi başına karar vermedi," dedi. "Eskiden verilen bir komutu sürdürdü." Burcu Hanım başını salladı. Çocuklar bilgisayarı insan gibi suçlamamak gerektiğini öğrendi. Bir otomatik işlem belirli koşullarda çalışabilir; fakat sonuçlarını anlayıp gerekli düzeltmeyi yapmak insanların sorumluluğundaydı.
---
@omurga
Düzeltme toplantısında teknik sorumlu ve okul yönetimi yalnızca bugünkü sorunu çözmekle yetinmedi. Ders saatleri değiştiğinde bakım planlarının da kontrol edilmesi gerektiğini görüştüler. Çocuklar bu görüşmenin teknik kısmına katılmadı; ama sonucunu öğrendi. Eylül, "Bir arızayı onardık ama neden tekrar olabileceğini de düşündük," dedi. {kahraman} bunu öğretmenlerinin matematik sorularındaki kontrol adımına benzetti. Hatanın görünen sonucunu düzeltmek bazen yeterliydi; fakat aynı hatanın yeniden oluşmasını önleyecek süreci düşünmek daha kalıcı olabiliyordu.

Bir hafta sonra başka bir sınıftan öğrenci sergi panosunu gördü ve "Siz bu bilgisayarların şifresini mi kırdınız?" diye sordu. {yoldas:yalin|bir arkadaş} başını iki yana salladı. "Hayır. Biz zamanları kaydettik. Yetkili teknik görevli ayarları kontrol etti." Öğrenci hayal kırıklığına uğramış göründü. "O zaman macerası kalmamış," dedi. Eylül karşı çıktı: "Tam tersine. Bir sorunu çözmek için kuralları çiğnemek gerekmemesi bence iyi bir şey." Çocuk, hazırladıkları çizelgeyi inceleyince gözlemin de bir dedektif işi olabileceğini fark etti.
---
@omurga
Okul gazetesi yayımlandığında okurlar en çok açıklamalı soru bölümüne ilgi gösterdi. Burada çocuklara "Aynı saatte bir sorun olması neyi düşündürür?" soruluyordu. Şıklarda "Kesin şaka", "Kesin elektrik arızası" ve "Zamanla ilişkili bir neden araştırılabilir" seçenekleri vardı. Çoğu öğrenci üçüncüyü seçti. Yanlış seçim yapanlara azarlayan bir mesaj yerine, "Gözlediğin düzenli saat önemli bir ipucu, fakat tek başına nedenin kanıtı değil," açıklaması verildi. {kahraman}, okuldaki küçük etkinliğin başka çocuklara da düşünme biçimi öğretebildiğini görünce sevindi.

Eylül bir gün kesinti süresini üç dakika yerine iki dakika elli yedi saniye olarak yazmasının neden önemli olduğunu açıkladı. "Bu fark bazen çok küçük olabilir," dedi, "ama kayıt doğru olmalı." Burcu Hanım bunun her zaman gereğinden fazla ayrıntıya boğulmak anlamına gelmediğini vurguladı. Bir okul sergisinde yaklaşık süre yeterli olabilirdi; teknik incelemede ise kesin kayda ihtiyaç duyulabilirdi. Çocuklar bilginin amaca uygun ayrıntıyla aktarılmasını öğrendi. Eylül çizelgesindeki tüm sayıları gururla korudu, ama arkadaşlarına açıklarken kolay anlaşılır dil kullanmaya da özen gösterdi.
---
@omurga
Serginin ikinci haftasında laboratuvarda başka bir sorun çıktı: bir öğrenci oturum açmakta güçlük çekti. {yoldas:yalin|bir arkadaş} hemen "Eski zamanlayıcı geri döndü!" dedi. {kahraman} gülerek "Bunu nasıl biliyoruz?" diye sordu. Can Bey sorunu inceledi ve bu kez farklı bir hesap erişim meselesi olduğunu açıkladı. {yoldas:yalin|bir arkadaş} önce utandı, sonra gülümseyerek "Benzer görünen sorunların her zaman aynı nedeni olmayabileceğini öğrendim," dedi. Sınıf yeni olayı eski tablonun üzerine eklemedi; çünkü ilgisiz iki durumu tek veri kümesinde karıştırmak istemiyorlardı.

Öğretmenlerinin isteğiyle çocuklar küçük bir "Sorun Gözlem Kartı" tasarladı. Kartta "Ne oldu?", "Ne zaman oldu?", "Kim gördü?", "Hangi cihazlar etkilendi?", "Yetkiliye haber verildi mi?" gibi başlıklar vardı. Kişisel parola veya özel bilgiler sorulmuyordu. Amaç öğrencilerin teknik sorun yaşadığında paniğe kapılmadan bilgi verebilmesiydi. Eylül kartı çantasına koydu. Birkaç gün sonra okul kütüphanesindeki yazıcı çalışmadığında aynı karttan yararlanarak görevliye ne gördüğünü açıkça anlatabildi.
---
@omurga
Burcu Hanım dönem sonunda sınıfa tek bir açık uçlu soru sordu: "Sorunun çözüldüğünü nasıl anladık?" {yoldas:yalin|bir arkadaş} "Ekranlar kapanmadı," dedi. {kahraman} "Bir haftalık kayıt tuttuk," diye ekledi. Eylül "Yetkili kişi teknik kontrolleri yaptı," dedi. Bora ise "Projemizi kesintisiz bitirebildik," diye tamamladı. Öğretmen, dört cevabın da ayrı bir yön gösterdiğini anlattı. Bir sorunun çözümünü değerlendirirken hem teknik kanıta hem de insanların gerçek işlerinin yeniden yürüyebilmesine bakmak gerekiyordu.

{yoldas:yalin|bir arkadaş} sergi panosunun kenarına asılan ilk yanlış tahminini kaldırmak istedi. "Herkes okuyor, çok kötü görünüyorum," dedi. {kahraman}, yanlış bir insan suçlamasının düzeltilmesinin önemli olduğunu, ama kendi düşünce süreçlerini göstermenin de değerli olabileceğini söyledi. {yoldas:yalin|bir arkadaş} bir süre düşündü, sonra tahminin yanına büyük bir not ekledi: Bu görüş kanıtsızdı; daha sonra düzelttim. Böylece onu saklamamış, sorumluluğunu da üstlenmiş oldu. Pano önünde duran öğrenciler, iyi bir araştırmacının bazen fikrini değiştirdiğini görebiliyordu.
---
@omurga
Yıl sonunda laboratuvar yeniden düzenlendiğinde çocukların çizelgesi öğretmenler odasında saklandı. Burcu Hanım, yeni sınıflarla çalışırken sorun çözme örneği olarak ondan söz edecekti. Eylül bunu öğrenince sevindi ama Can Bey'in verdiği desteği unutmamak gerektiğini söyledi. "Biz yalnızca belirtileri gözledik; ayarı değiştiren görevliydi," dedi. {yoldas:yalin|bir arkadaş} de "Herkesin görevi farklıydı," diye ekledi. Böylece çözüme katkı verenlerin emeklerini doğru anlatmaya özen gösterdiler.

Son gün Bora, ilk kesintide kaybettiği çizimin yeniden hazırlanmış hâlini ekranda açtı. Resimde yağmurdan sonra aydınlanan bir okul bahçesi vardı. Bilgisayarlar çalışıyor, sınıf arkadaşları gülüyordu. Resmin köşesine küçük bir saat eklemişti; ibreler on bir kırk ikiyi gösteriyordu. {kahraman} gülerek "Neden o saat?" diye sordu. Bora, "Çünkü eskiden bizi durduran zaman şimdi hikâyemizin parçası," dedi. {yoldas:yalin|bir arkadaş} de "Ve kimseyi suçlamadan çözdüğümüz bir hikâyenin," diye ekledi.
---
@omurga
Okul gazetesi çalışmalarının son haftasında sınıfın hazırladığı soru kartları başka öğretmenlerin de dikkatini çekti. Matematik öğretmeni, veri toplama çalışmasının nasıl yapıldığını öğrencilere anlattırdı. {yoldas:yalin|bir arkadaş} tahtaya dört günün başlangıç saatini yazdı. Bir öğrenci, günlerden birinde kesinti yaşanmadığını görünce "O günü çıkaralım," dedi. {kahraman}, "Hayır, kesinti yaşanmaması da önemli bir gözlem," diye karşılık verdi. Çünkü bir tahmini destekleyen verileri seçip diğerlerini gizlemek yanlış bir sonuca götürebilirdi. Öğretmen bu yaklaşımı özellikle vurguladı. İyi veri, yalnız beklediğimizi gösteren sayılardan oluşmazdı.

Sınıfta küçük bir tartışma daha oldu. Bazıları teknik arızanın çözüldüğünü öğrenince neden hâlâ konuyu konuştuklarını soruyordu. Eylül, "Arıza çözüldü ama yöntemi başka sorunlarda da kullanabiliriz," dedi. Bora, yazıcının çalışmadığı bir günü hatırlattı. {yoldas:yalin|bir arkadaş}, "O zaman her sorunda eski zamanlayıcıyı aramayacağız," diye şakalaştı. Çocuklar birlikte güldü. Bir yöntemi öğrenmek, bütün soruların aynı cevabı olduğunu sanmak değildi. Önce belirtilere bakmak, sonra uygun hipotezler kurmak gerekiyordu.
---
@omurga
{kahraman} eve gittiğinde küçük kardeşi tabletinin şarjı bittiği için çok öfkeliydi. "Biri bozdu!" diye söylendi. {kahraman} onu azarlamadı. "Önce ne olduğuna bakalım," dedi. Cihazın şarj göstergesinin boş olduğunu fark ettiler. Kardeşi, "Demek biri kapatmamış," dedi. {kahraman} gülümsedi. "Şimdilik gördüğümüz bu. Cihazı güvenli biçimde şarj edip yetişkine haber verelim." Kardeşi ertesi gün aynı olayın tekrarlanmadığını görünce sevinçle {kahraman:yonelme} koştu. {kahraman}, laboratuvarda öğrendiği düşünme yönteminin evde de işe yarayabildiğini fark etti.

{yoldas:yalin|bir arkadaş} de ailesine sınıfta söylediği acele suçlamayı anlattı. Babası dikkatle dinledi ve "Özür diledin mi?" diye sordu. {yoldas:yalin|bir arkadaş} başını salladı. "Ama söylediklerim hemen unutulmadı." Babası, güvenin bazen tek cümleyle bozulup yeniden kurulması için zamana ihtiyaç duyulabileceğini anlattı. {yoldas:yalin|bir arkadaş} ertesi gün o arkadaşına okul gazetesindeki çalışmasını gösterip fikrini sordu. Arkadaşı bazı cümleleri değiştirmesini önerdi. {yoldas:yalin|bir arkadaş} önerileri dikkate aldı. Birlikte çalışmak, aralarında oluşan soğukluğu yavaş yavaş azaltmaya başlamıştı.
---
@omurga
Eylül zaman çizelgesinin en altına dört sözcük yazdı: **Gözle, karşılaştır, doğrula, paylaş**. {kahraman} bunlara beşinciyi ekledi: Saygı göster. Çünkü çözüm yalnız teknik değildi; sınıfta yanlış kuşkuların ortaya çıkmasını da engellemek gerekiyordu. {yoldas:yalin|bir arkadaş} altıncı sözcüğü yazmak istedi: Düzelt. Hep birlikte altı sözcüğü panonun üstüne astılar. Okul laboratuvarına giren öğrenciler önce renkli grafiklere, sonra bu küçük ilkelere bakıyordu. Ekranlar hâlâ aynı masalarda duruyor, saat yine aynı duvarda asılıydı. Değişen en önemli şey, o ekrana bakan çocukların düşünme biçimiydi.

Dönem bitmeden Burcu Hanım çocuklardan ilk günkü defterlerini yeniden okumalarını istedi. {yoldas:yalin|bir arkadaş} kendi yazdığı "Biri yaptı" cümlesine baktı ve bir süre konuşmadı. Eylül yanlış ölçtüğü saati fark etti. {kahraman} ise sürekli arkadaşlarının fikirlerini düzeltmeye çalıştığı anları hatırladı. Üçü de başka insanların söylediklerini dinlerken daha sabırlı olmayı öğrenmişti. Burcu Hanım, "Araştırma yalnız doğru cevabı aramaz; düşünme alışkanlığınızı da gösterir," dedi. Her öğrenciden bu cümlenin altına kendisi için bir hedef yazmasını istedi. {yoldas:yalin|bir arkadaş} "Önce kanıt", Eylül "Ölçmeden kesin konuşma", {kahraman} ise "Düzeltirken nazik ol" yazdı.
---
@omurga
Küçük bir yanlış anlaşılma yeniden ortaya çıktığında bu hedefleri uygulamaları gerekti. Başka sınıftan biri arızanın tamiri için öğrencilerin bilgisayarı açıp parçaları değiştirdiğini söylüyordu. {yoldas:yalin|bir arkadaş}, "Hayır, böyle bir şey olmadı," dedi. Ardından sakin bir açıklama yaptı: Teknik görevli yönetim ayarını değiştirmiş, öğrenciler yalnızca zamanları kaydetmişti. Söylentiyi düzeltti ama kimseyle alay etmedi. {kahraman} ona bakıp gülümsedi; defterdeki cümle yalnız yazılı kalmamıştı.

Ders bitiminde {yoldas:yalin|bir arkadaş} duvar saatine baktı. On bir kırk iki çoktan geçmişti. Ekranlarda hazırladıkları gazete duruyordu. Bir hafta önce aynı saatte yalnız karanlık bir ekran görmüşlerdi. Şimdi aynı saat ona başka bir şeyi hatırlatıyordu: Gizemleri çözmek için aceleyle suçlu aramak yerine, sabırla veri toplamak ve doğru soruları sormak gerekiyordu. Üstelik ortaya çıkan sonuç hoşuna gitmese bile onu olduğu gibi kabul etmek, yanlışsa düzeltmek ve başka insanların emeğine saygı göstermek gerekiyordu. {yoldas:yalin|bir arkadaş} artık araştırmacı olmanın yalnız bilgisayarların nasıl çalıştığını anlamak değil, kendi davranışlarını da dikkatle, anlayışla, iyilikle ve sorumlulukla yeniden gözden geçirmek olduğunu artık gerçekten çok daha iyi biliyordu.
