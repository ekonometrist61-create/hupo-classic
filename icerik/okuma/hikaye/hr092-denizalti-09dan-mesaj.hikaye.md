---
baslik: "Denizaltı 09'dan Mesaj"
slug: "hr092-denizalti-09dan-mesaj"
fis_kodu: "HR-092"
tur: bilim_kurgu
konu: iletisim_gecikme_dogrulama
sinif_alt: 7
sinif_ust: 7
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Kontrol odasında kırmızı bir ışık yanıyor. Denizaltı yirmi bir dakikadır sessiz. Gelen her satır aracın mesajı mı?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 7
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, guvenlik]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: sinyal_hr092, tur: lexeme, etiket: "sinyal", yuva: hr092_sinyal, islev: first_hint}
    - {id: hipotez_hr092, tur: lexeme, etiket: "hipotez", yuva: hr092_hipotez, islev: application}
    - {id: deyim_hr092, tur: idiom, etiket: "Yüzünü buruşturmak", yuva: hr092_yuz, islev: application}
    - {id: kavram_hr092, tur: concept, etiket: "Zaman damgası, kaynak ve doğrulama", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (7. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Son bağlantı saat kaçta görülmüştü?", secenekler: [{id: A, metin: "14.42"}, {id: B, metin: "15.03"}, {id: C, metin: "15.00"}, {id: D, metin: "16.10"}], dogru: A, aciklama: "Ekranda son bağlantı 14.42 olarak yazıyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 5, metin: "“Yeni görünen her satırı beklenen cevap sanmak ne kadar kolaydı.” Bu cümle hangi dikkat hatasını anlatır?", secenekler: [{id: A, metin: "Yeni görünen her veriyi beklenen cevap sanmak"}, {id: B, metin: "Gelen verilerin hepsini hemen unutup yeni bilgi aramamak"}, {id: C, metin: "Ekrana hiç bakmadan yalnız başkalarının sözüne güvenmek"}, {id: D, metin: "Saatleri hiç kontrol etmeden zaman damgalarını tamamen yok saymak"}], dogru: A, aciklama: "Yeni bir satır, beklenen cevap olmayabilir; etiketi okumadan karar verilmemelidir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 5, metin: "Derya'ya göre hipotez nedir?", secenekler: [{id: A, metin: "Kesin ve tartışılmayan bir sonuç"}, {id: B, metin: "Sınanabilen bir açıklama önerisi"}, {id: C, metin: "Veriyi doğrudan gösteren bir ekran"}, {id: D, metin: "Gönderilen her mesajın kayıt numarası"}], dogru: B, aciklama: "Hipotez, veriyle sınanabilen bir açıklama önerisidir; kesin sonuç değildir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 7, metin: "Metinde geçen zaman damgası ne anlama gelir?", secenekler: [{id: A, metin: "Ekranda yalnız saati gösteren küçük bir dijital saat"}, {id: B, metin: "Denizin altındaki görüntüleri kaydeden küçük bir kamera"}, {id: C, metin: "Bir verinin oluşturulduğu veya alındığı zamanı gösteren kayıt"}, {id: D, metin: "Kayıp aracı yüzeye çıkarmak için görevlendirilen kurtarma ekibi"}], dogru: C, aciklama: "Zaman damgası, bir kaydın hangi zamanda oluşturulduğunu veya işlendiğini gösterir."}
deyim_cumleleri:
  hr092_yuz: "{yoldas:yalin|bir arkadaş} yüzünü buruşturdu."
---
@omurga
Araştırma merkezindeki ekranın köşesinde küçük, kırmızı bir ışık yandı. {kahraman} ışığı hemen fark etti, çünkü iki saattir tam o köşeyi izliyordu. Ekranda “Denizaltı 09 — son bağlantı: 14.42” yazıyordu. Saat 15.03'tü. Kendi kendine “Yirmi bir dakika” diye mırıldandı. {isaret:deniz}

On üçüncü yaş gününde hediye alacağına, okulun bilim kulübüyle birlikte kıyı araştırma merkezine gelmeyi seçmişti. Bugün merkezdeki uzmanlar, deniz tabanını haritalayan insansız araştırma aracının görevini ziyaretçilere anlatacaktı. {kahraman} araçların devasa pencereleri olan denizaltılar gibi göründüğünü sanmıştı. Oysa Denizaltı 09, kırmızı-beyaz bir kapsül kadar küçüktü; içinde insan değil, sensörler, bataryalar ve yön bulma sistemi vardı.

“Yirmi bir dakika haber alamamak kötü mü?” diye sordu.

Mühendis Derya, bilgisayarı kontrol ederken acele etmedi. “Önce beklenen bağlantı zamanına bakmamız gerek,” dedi. “Araç her an aynı şekilde iletişim kuramaz. Suyun altında bağlantı yöntemleri havadakinden farklı.”

{kahraman:ilgi} arkadaşı {yoldas:yalin|bir arkadaş} yanındaki boş sandalyeye oturdu. “Telefon çekmeyince biraz yer değiştiriyoruz,” dedi. “Denizaltı da yer değiştirirse olur mu?”
---
@omurga
Derya, suyun radyo dalgalarını birçok koşulda güçlü biçimde zayıflattığını, bu nedenle su altı iletişiminde çoğu zaman akustik {kelime:hr092_sinyal} kullanıldığını açıkladı. “Ama akustik bağlantının veri hızı sınırlıdır, denizin koşulları da sinyali etkiler. Araç bazen verisini saklar, planlanan noktada yüzeye gelip radyo bağlantısıyla aktarır.”

Görevin planında Denizaltı 09'un saat 15.00 civarında yeni bir konum mesajı yollaması bekleniyordu. Gelen mesaj yoktu. Derya'nın yüzü ciddileşti. “Bu tek başına tehlike kanıtı değil. Ancak kontrol etmemiz gereken bir sapma,” dedi.

{yoldas:yalin|bir arkadaş} aniden ekrandaki sarı simgeyi gösterdi. “Bakın! Deniz tabanında kırmızı bir bölge var. Robot oraya mı düştü?”

{kahraman} ekranın açıklamasını okudu. Kırmızı renk robotun düştüğü bir çukuru değil, önceki ölçümlerde düşük sıcaklık saptanan alanı gösteriyordu. “Renklerin anlamı var,” dedi. “Ben de ilk bakınca alarm sandım.”

Derya onlara küçük bir not defteri uzattı. “İsterseniz bugün sizin göreviniz gördüğünüz olayları sırayla yazmak olsun. Yalnız ekranın üzerinde olanı değil, neyin gözlem, neyin yorum olduğunu da ayırın.”
---
@omurga
{kahraman} ilk satıra şunu yazdı: Planlanan bağlantı gecikti. Nedeni bilinmiyor.

O sırada merkezde ikinci bir zil çaldı. Bu zil duyulduğunda teknedeki ekip yeni bir durum mesajı göndermeliydi. {kahraman} bunun yalnız bir okul gezisi olmadığını anladı. Bir odadaki ışık, kilometrelerce ötede çalışan insanların kararlarını etkileyebiliyordu.
---
@omurga
Kontrol odasında kimse bağırmıyordu. {kahraman} bunu garip buldu. Filmlerde böyle anlarda herkes koşar, ekranlarda dev kırmızı yazılar belirirdi. Burada ise Derya ve deniz teknisyeni Barış sırayla kontrol listesine bakıyor, gelen verinin zaman damgalarını karşılaştırıyordu.

“İki ayrı sessizliği karıştırmayalım,” dedi Barış. “Birincisi araçtan yeni veri gelmemesi. İkincisi ise bizim gönderdiğimiz komuta cevap gelmemesi. Bunların nedenleri aynı olmak zorunda değil.”

Derya, aracın planlanan son görev noktasını açtı. Araç düşük hızla deniz tabanının belirli bir hattında ölçüm yapıyor, batarya ve sensör durumunu görev bilgisayarına kaydediyordu. Belirlenen sınırların dışına çıkarsa güvenlik davranışları vardı: görevi kesmek, emniyetli duruma geçmek ve uygun koşullarda yüzeye yönelmek gibi. Bunların nasıl çalışacağı aracın modeline ve görev planına bağlıydı.

{kahraman} “O zaman robot kendini kurtarır,” dedi.

“Buna güvenlik mekanizması diyebiliriz, ama sonuç garanti değil,” diye cevap verdi Derya. “Bu yüzden karadan ve denizden takip ediyoruz.”
---
@omurga
Görev teknesindeki kaptanla kısa bir görüşme yapıldı. Deniz sakindi, teknede acil bir durum yoktu. Yine de kaptan bölgedeki hava ve deniz koşullarını yeniden doğruluyor, aracı izlemek için önceden hazırlanmış prosedürü uyguluyordu. {kahraman} kapalı bir alanda durdukları hâlde herkesin dışarıdaki rüzgârı neden bu kadar önemsediğini şimdi daha iyi anlıyordu.

{yoldas:yalin|bir arkadaş} veri grafiğini yakınlaştırdı. Son ulaşan kayıt, aracın yavaşladığını gösteriyordu. “Bir şeye takılmış olabilir,” dedi.

{kahraman} başka ihtimalleri sıraladı: “Bir ölçüm noktasına yaklaşmış olabilir. Otomatik olarak hız düşürmüş olabilir. Sensör farklı kaydetmiş olabilir.”

Derya onların söylediklerini yazmalarına izin verdi. “Bunlar {kelime:hr092_hipotez},” dedi. “Bir hipotez, sınanabilir bir açıklama önerisidir. Şu an hangisinin doğru olduğunu söyleyemeyiz.”

Tam o sırada sistemde yeni bir satır belirdi. {yoldas:yalin|bir arkadaş} ayağa fırladı. Fakat satır, Denizaltı 09'un mesajı değildi. Kıyı istasyonundan gelen zaman eşitleme kaydıydı. {kahraman} bir an için kalbinin hızlandığını hissetti. Yeni görünen her satırı beklenen cevap sanmak ne kadar kolaydı.
---
@omurga
Barış, öğrencilerin bu karışıklığını fark etti. “Bazen zihnimiz görmek istediğimiz şeye daha hızlı yönelir,” dedi. “Bu nedenle ekrandaki etiketleri okumadan karar vermeyiz.”

Görev teknesinden gelen ikinci mesajda, aracın son konumundaki sualtı akıntısının beklentilerin üzerinde olabileceği bildirildi. Bu bilgi hemen kesin neden kabul edilmedi. Kaptan, aynı saatteki başka sensörlerle karşılaştırma yapılmasını istedi.

{kahraman} defterinin ikinci sayfasına üç sütun açtı: Bildiğimiz, bilmediğimiz, sınayabileceğimiz. {yoldas:yalin|bir arkadaş} son sütuna ilk maddeyi yazdı: “Yeni gelen mesajın gerçekten araçtan olduğunu doğrulamak.”
---
@omurga
Bir süre sonra kontrol odasındaki hoparlörlerden kısa bir ses dizisi duyuldu. Derya hemen kulaklığını taktı. Ses, birbirine benzeyen tıkırtılardan oluşuyordu. {kahraman} bunun robotun yardım çağrısı olabileceğini düşündü; fakat Derya herhangi bir yorum yapmadan kayıt numarasını not etti.

“Bu akustik sinyalin cihazımızın beklediği biçimde olup olmadığını inceleyeceğiz,” dedi. “Dışarıdan gelen sesler, yankılar veya başka bir sistemin iletileri de olabilir.”

{yoldas:yalin|bir arkadaş} sesin ortasında bir boşluk fark etmişti. “On beş saniye sonra aynı şey tekrar etti,” dedi. Derya bunun önemli bir gözlem olduğunu söyledi; ancak düzenli tekrarın tek başına kaynağı belirlemediğini de ekledi.

Bilgisayardaki zaman çizelgesini büyüttüler. Bazı paketlerin oluşturulma zamanı ve merkezde alınma zamanı farklıydı. {kahraman} önce saatlerin bozuk olduğunu düşündü. Barış, iletinin işlenmesi, iletilmesi ve kaydedilmesi sırasında gecikmeler olabileceğini anlattı; ayrıca saatler tam eşitlenmediyse zaman damgalarının karşılaştırılmasının yanıltıcı olabileceğini gösterdi.

“Yani bize yeni gelmiş bir mesaj, eski bir durumu anlatıyor olabilir,” dedi {kahraman}.
---
@omurga
“Evet,” dedi Derya. “Bunun için mesajın üretildiği zaman ile bize ulaştığı zamanı ayrı tutuyoruz.”

{yoldas:yalin|bir arkadaş} ekrandaki en yeni paketi açtı. Paketin üzerinde aracın adı görünmüyordu; yalnız kod ve kimlik doğrulama alanları vardı. {kahraman:ilgi} aklına geçen yıl sınıfta yaptıkları sahte mesaj oyunu geldi. Herkes kendi adını yazdığı bir kâğıdı zarfa koymuş, ama zarflar karışınca kimin yazdığını bulmak için yazı biçimlerine bakmışlardı. Burada ise tahmin etmek yeterli değildi; teknik doğrulama gerekiyordu.

Derya, paketin beklenen protokole uygun olup olmadığını ve gerçekten göreve ait kimlik bilgilerini taşıyıp taşımadığını kontrol etti. Sonuç olumsuzdu. Sesin kaynağı Denizaltı 09 değildi.[[deyim:hr092_yuz]] “Boşuna sevinmişiz.”

“Boşuna değil,” dedi {kahraman}. “Yanlış alarmı ayırt etmeyi öğrendik.”

Barış başıyla onayladı. “Yanlış kaynağı elemek de ilerlemedir. Ama bu, aracı bulduğumuz anlamına gelmez.”

Yarım saatlik süreç boyunca {kahraman} defterine küçük simgeler çizdi: bir dalga, saat ve soru işareti. Simgeler çocukça görünmüyordu; ölçümün hangi aşamada olduğunu hatırlatıyordu. {yoldas:yalin|bir arkadaş} en baştaki kırmızı alarm simgesinin yanına iki farklı not ekledi: İletişim gecikmesi olabilir ve Görev sapması olabilir.
---
@omurga
Derya masanın kenarına dayanıp çocuklara baktı. “Bugün heyecanı kontrol etmeyi de öğreniyorsunuz,” dedi. “Bazen en zor iş, sonuca ulaştığınızı zannettiğiniz anda bir kez daha kontrol etmektir.”

{kahraman}, denizin altında sessiz kalan küçük kapsülü düşündü. Su karanlıktı, sıcaklık düşük olabilirdi, ama araç korkmuyor ve telaşlanmıyordu. Korku ve telaş onları izleyen insanlara aitti. İnsanların görevi bu duyguların karar vermeyi yönetmesine izin vermemekti.
---
@omurga
Saat 16.10'da görev teknesinden farklı bir haber geldi. Ekip, araştırma aracının planlanan konuma yakın bir yerde yüzeyde olabileceğini düşündüren kısa bir sinyal yakalamıştı. Ancak dalga hareketleri ve yansıma nedeniyle konum kesin değildi. Derya bir koordinat okumak yerine kaptanla birlikte kaydın güvenilirliğini değerlendirdi.

“Robot bizi bekliyor olabilir mi?” diye sordu {yoldas:yalin|bir arkadaş}.

Barış, böyle bir cümlede bile iki varsayım bulunduğunu söyledi: Robotun yüzeye çıktığı ve onların yerini beklediği varsayımı. “Henüz ikisini de doğrulamadık.”

{kahraman} ilk kez bunun bir matematik problemi gibi yalnız sonuçtan ibaret olmadığını düşündü. Burada her karar başka bir kararı etkileyebilirdi. Deniz üstündeki ekip yalnız robotu aramıyor, kendi güvenliğini de koruyordu. Havanın bozacağı olası bir durumda aramayı ertelemek zorunda kalabilirlerdi. **Kimse bir araştırma cihazı uğruna insanları tehlikeye atmak istemiyordu**.

Kontrol odasında küçük bir tartışma başladı. Genç teknisyenlerden biri son mesajın aracın acil yükselme komutuyla ilişkili olabileceğini düşündü. Bir başkası bunun normal görev sonu mesajı olduğundan şüpheleniyordu. Derya ikisinin de iddiasını dinledi. Hangi paketlerin hangi kimlikle, hangi sırada geldiğini tek tek gösterdi. Aracın çalışma biçimi hakkındaki dokümantasyon olmadan sembolleri sezgiyle yorumlamamak gerektiğini hatırlattı.
---
@omurga
{kahraman} büyüklerin birbirini dinlerken seslerini yükseltmemesine hayran kaldı. “Farklı düşününce tartışmıyorlar mı?” diye fısıldadı {yoldas:yonelme|bir arkadaşa}.

“Tartışıyorlar,” dedi {yoldas:yalin|bir arkadaş}. “Ama galiba fikirleri tartışıyorlar, birbirlerini değil.”

Bir süre sonra teknedeki operatör, yüksek yansımaya neden olan bir bölgeden uzaklaşıp ekipmanın izin verdiği başka bir gözlem noktasında dinleme yaptıklarını bildirdi. Yeni kayıt daha temizdi. Derya ve Barış paketin kaynağını doğruladı. Bu kez mesaj gerçekten Denizaltı 09'a aitti. Ama içinde tek bir bilgi vardı: İşlem süreci tamamlanamadı. Kaydedilmiş veriler korunuyor.

“Yani robot sağ mı?” diye sordu {yoldas:yalin|bir arkadaş}. Soruyu sorar sormaz cansız bir araca canlıymış gibi seslendiğini fark edip gülümsedi.

Derya da gülümsedi. “Aracın yanıt verdiğini biliyoruz, ama durumunun tamamını henüz bilmiyoruz. Kayıtların korunması iyi haber.”

{kahraman:yonelme} göre bu küçük mesaj bütün günün en heyecanlı anıydı. Sanki karanlık suyun içinden gelen tek satırlık bir kartpostal almışlardı. Ancak Derya onların sevinmesine rağmen doğrulamayı bırakmadı. Son görev komutunu, sistemin beklediği yanıt biçimini ve güvenlik kurallarını karşılaştırdı. Teknedeki ekip de kendi prosedürünü uygulamayı sürdürdü.
---
@omurga
Sonraki mesajda aracın yüzeye çıktığına dair konum bilgisi vardı. Tekne ekibi gözle doğrulama yapıncaya kadar kontrol odasında kimse “bulduk” demedi. {kahraman} beklemenin nasıl ağırlaştığını hissetti. Belirsizlik sona yaklaşırken daha da zor olabiliyordu.

Kırk dakika sonra kaptanın sesi duyuldu: “Araç yüzeyde görüldü. Ekip güvenli şekilde yaklaşma hazırlığında.”

Kontrol odasındaki herkes rahat bir nefes aldı. {yoldas:yalin|bir arkadaş} sandalyesinden zıplayarak kalktı. “Şimdi bulduk, değil mi?”

“Şimdi gördük,” dedi Derya. “Birazdan güvenli alım işlemini tamamlayacağız.”

{kahraman} güldü. Artık sözcüklerin küçük ayrımlarına sinir olmuyordu. Tam tersine, bu ayrımlar sayesinde olayların gerçek sırasını takip edebiliyordu.
---
@omurga
Araç merkeze getirildiğinde öğrenciler onu kapalı bakım alanının dışındaki camdan izledi. Gövdesinde birkaç küçük çizik bulunuyordu; ancak bunların o gün mü oluştuğu henüz belli değildi. Derya ve ekibi önce güvenlik kontrollerini yaptı, ardından veri belleğini inceliyordu. {kahraman} eldivenli mühendislerin çalışmasını sessizce izledi.

“İçinde bütün günün videosu var mı?” diye sordu.

“Hayır,” dedi Derya. “Bu görevde bazı sensörlerin ölçümleri, konum ve sistem kayıtları tutuldu. Her araştırma aracında kamera bulunması gerekmez. Kamerası olsa bile sürekli video kaydetmesi şart değildir.”

{kahraman} hayal kırıklığına uğramadı. Verilerin de hikâyesi olabileceğini artık biliyordu. Zaman çizelgesindeki küçük iniş çıkışlar, suyun altında yapılan hareketlere ilişkin izlerdi. Bunları yorumlamak ise dikkat gerektiriyordu.

İlk kontrol, aracın planlanan bir ölçüm noktasında beklenenden uzun kaldığını gösterdi. Sonra görevin durdurulduğu, sistemin güvenlik prosedürüne geçtiği görülüyordu. Ancak iletişimin niçin kesildiğine ilişkin birden fazla olasılık vardı. Akustik bağlantıyı etkileyen ortam koşulları, sinyal gölgelenmesi, zamanlama uyuşmazlığı ya da sistemin işlem sırasındaki gecikme dikkate alınmalıydı. Ekip, kayıtlara dayanmayan bir arıza iddiası oluşturmadı.
---
@omurga
{yoldas:yalin|bir arkadaş} daha önce “robot bir şeye takıldı” demişti. Şimdi bu tahminini yeniden düşünüyordu. “Elimizde buna dair iz yok,” dedi. “Başta öyle söylemem yanlıştı.”

Derya, “Tahmin etmek tek başına yanlış değil,” diye karşılık verdi. “Önemli olan onu kanıt gibi sunmamak ve yeni bilgi gelince değiştirebilmek.”

Veri kayıtlarında en ilginç bölüm, ölçümün yapıldığı bölgede su sıcaklığının kısa süreli değişmesiydi. Derya bunun farklı su kütleleriyle ilgili olabileceğini, ama tek kayıtla nedenini açıklayamayacaklarını söyledi. {kahraman}, o bölgeyi haritada buldu. Kıyıdan uzak değildi; buna rağmen kıyıdaki su ile derindeki su birbirinden farklı koşullara sahip olabilirdi.

Barış onlara suyun farklı derinliklerde sıcaklık, tuzluluk ve basınç gibi özellikler bakımından değişebileceğini anlattı. Böylece deniz, yalnız üst yüzeyi görünen tek renkli bir göl olmaktan çıktı; katmanları, hareketleri ve geçişleri olan karmaşık bir dünya hâline geldi.

“Denizaltı 09'un başına gelen şey gerçekten tehlike miydi?” diye sordu {kahraman}.
---
@omurga
Derya cevap vermeden önce ekranı kapattı. “Görev için bir risk oluştu, güvenlik sistemi devreye girdi ve ekip gerekli kontrolleri yaptı. Sonuçta araç güvenli biçimde alındı. Ama sonucun iyi olması, riskin başta önemsiz olduğu anlamına gelmez.”

{kahraman} bunu defterine özellikle yazdı. Bazen bir olayda kötü sonuç olmaması, dikkatli kararların işe yaradığını gösteriyordu.
---
@omurga
Denizaltı 09'un veri kayıtları üzerinde çalışıldıktan birkaç gün sonra Derya okul kulübüne küçük bir görev gönderdi. Bir grafik, bir harita ve üç ayrı açıklama vardı. Öğrencilerden, grafikte görülen sıcaklık değişiminin hangi açıklamayı desteklediğini düşünmeleri isteniyordu. {kahraman} ve {yoldas:yalin|bir arkadaş} sınıfın penceresi önündeki masaya oturdu.

Grafikte belirli bir derinlikte sıcaklık önce yavaşça azalmış, ardından kısa bir aralıkta daha hızlı düşmüştü. İlk açıklamada bunun suyun tabanından yükselen soğuk bir kaynak nedeniyle olduğu, ikincisinde aracın başka su kütlesine geçtiği, üçüncüsünde ise sensörün hatalı ölçmüş olabileceği yazıyordu.

{yoldas:yalin|bir arkadaş} birinci açıklamayı seçti. “Soğuk su kaynağı maceramıza daha çok yakışıyor,” dedi.

{kahraman} gülümsedi. “Hikâyeye yakışması, doğru olduğunu kanıtlamıyor.”

İkisi grafiğin yanında verilen sensör bilgilerine baktı. Verinin hangi cihazdan geldiği ve cihazın ne zaman kontrol edildiği belirtiliyordu. Fakat suyun tuzluluğuna ilişkin aynı anda alınmış yeterli ölçüm yoktu. {kahraman} yalnız bu sıcaklık grafiğiyle üç olasılıktan birini kesin seçemeyeceklerini düşündü. Derya'ya “Daha fazla veri gerekir” yanıtını gönderdiler.
---
@omurga
Derya'nın dönüş mesajında “İyi başlangıç” yazıyordu. Ardından iki yeni grafik eklemişti. Biri aracın derinlik kaydı, diğeri aynı bölgede başka bir zamanda alınmış ölçümlerdi. Bu yeni bilgiler, açıklamaları değerlendirmelerini sağlıyordu; fakat hâlâ tek bir sonuca kilitlemiyordu. {kahraman} bunun bir oyun olmadığını fark etti. Cevabı bilen bir öğretmenin hazırladığı bulmacada, yeni veriler hep doğru seçeneği belirginleştirebilirdi. Gerçek araştırmada ise veri bazen yeni sorular da doğurabilirdi.

Kulüp arkadaşları Selim, “Madem kesinleşmiyor, neden uğraşıyoruz?” diye sordu. {yoldas:yalin|bir arkadaş} bu kez cevap verdi: “Çünkü olasılıkları daraltıyoruz. Başta neler olabileceğini bile bilmiyorduk.”

Derya ertesi gün çevrim içi görüşmede onları dinledi. “Açıklamalarınızın her birini hangi verinin desteklediğini ve hangisinin eksik kaldığını söylemeniz, tek bir cevabı tahmin etmenizden daha yararlı,” dedi. “Bilimsel çalışma bazen ‘henüz bilmiyoruz’ cümlesini daha ayrıntılı ve daha dürüst hâle getirmektir.”

{kahraman} bu konuşmayı defterine yazarken Denizaltı 09'un görevini hatırladı. Araç yüzeye dönmüştü, ama ölçümün her ayrıntısı kendiliğinden açıklanmamıştı. Robotun belleğindeki sayılar bir hikâyeyi anlatıyordu; bu hikâyeyi doğru okumak için yöntem, bağlam ve sabır gerekiyordu.
---
@omurga
Bilim kulübü gezisinin ikinci gününde başka bir konu konuşulmuştu. Görev teknesindeki ekibin araç arama sırasında zaman zaman konum değiştirmesi gerekmişti. Bazı öğrenciler, ekibin neden daha hızlı gitmediğini sormuştu. Kaptan, gemideki insanların güvenliğiyle aracın kurtarılmasının farklı öncelikler olduğunu açıklamıştı. Uygun olmayan hava koşullarında acele etmek, aranan cihazdan daha büyük bir risk yaratabilirdi.

{kahraman} bu konuyu okulun güvenlik kulübüyle paylaştı. Öğrenciler afet ve kaza haberlerinde sık görülen “kahramanca atıldı” cümlesini tartışmaya açtı. Yardım etmek istemek değerliydi; fakat eğitimsiz kişilerin tehlikeli bir alana girmesi yeni bir soruna yol açabilirdi. {kahraman}, kontrol odasında hiçbir çocuğun komuta cihazına yaklaşmamasının nedenini şimdi daha iyi anlıyordu.

{yoldas:yalin|bir arkadaş} “Ama biz sadece izledik,” dedi.

“Yalnız izlemek değil,” diye düzeltti {kahraman}. “Gördüğümüzü anlamaya çalıştık. Bir şeyi yanlış sanınca sorduk. Bence bu da işin bir parçası.”

Derya'nın gönderdiği son raporun halka açık özetinde aracın güvenli biçimde geri alındığı, bağlantı kayıtlarının incelendiği ve sonraki görev öncesi testlerin güncellendiği yazıyordu. Raporda yer almayan ayrıntıları çocuklar kendi hayalleriyle doldurmadı. {yoldas:yalin|bir arkadaş} bir robotun son saniyede kaya düşmesinden kurtulduğu bir çizgi roman yapmak istedi. {kahraman} bunu eğlenceli buldu ama çizgi romanın başına “Bilimden esinlenen kurgu” yazmayı önerdi. Böylece gerçek görev raporuyla hayalî macera karışmayacaktı.
---
@omurga
Çizgi romanda Denizaltı 09'un iki konuşan yardımcısı vardı. Biri sürekli acele ediyor, diğeri her şeyi üç kez kontrol ediyordu. İlk taslakta aceleci yardımcı kötü, kontrollü yardımcı ise kusursuzdu. {yoldas:yalin|bir arkadaş} bunu okuduğunda hikâyenin fazla basit olduğunu düşündü. “İkisinin de iyi yanı olmalı,” dedi. “Biri hızlı karar verebilmeli, diğeri kanıta bakmalı. En iyi çözümü birlikte bulsunlar.”

{kahraman} bu fikirle son bölümü yeniden yazdı. Robotlar bir sorun karşısında önce hazır güvenlik adımlarını izliyor, sonra uygun zamanda verileri kontrol ederek karar veriyordu. Kahramanlıkları kuralları hiçe saymalarında değil, birlikte çalışabilmelerindeydi.

Sınıfın küçük çocukları çizgi romanı okuyunca karakterleri sevdi. Bir öğrenci “Gerçek robotlar da böyle konuşuyor mu?” diye sordu. {yoldas:yalin|bir arkadaş} gülerek “Hayır, biz onlara ses verdik,” dedi. “Gerçek robotlardan aldığımız fikir, veriye bakma ve güvenli çalışma alışkanlığı.”
---
@omurga
Birkaç hafta sonra merkez, öğrencilerden gezinin kendilerinde bıraktığı izlenimleri yazmalarını istedi. {kahraman} ilk taslağında “Robot kayboldu, biz onu kurtardık” demişti. Cümleyi okuyunca durdu. Araçla ilgili işleri mühendisler ve kaptan yürütmüştü. Kendileri yalnızca gözlemciydi. Bu yüzden metni değiştirdi: “Denizaltı 09'un bağlantısı gecikti; kontrol odasında uzmanların kararlarını nasıl doğruladığını izledik.”

{yoldas:yalin|bir arkadaş} onun düzeltmesini gördü. “Böyle yazınca biz daha az kahraman gibi görünüyoruz,” dedi.

{kahraman} bunu düşündü. “Belki de gerçek kahramanlık, olmayan şeyi yapmış gibi anlatmamak,” diye cevap verdi.

İkisi birlikte Derya'ya teşekkür mektubu hazırladı. Mektupta tek bir soruya yer ayırdılar: “Bir cihazın gönderdiği bilgiye güvenmek için en önemli üç şey nedir?” Derya kısa ama dikkatli bir yanıt verdi: Bilginin kaynağı, kaydedildiği zaman ve elde edilme yöntemi bilinmeli; ayrıca mümkünse başka verilerle karşılaştırılmalıydı. “Üç madde başlangıçtır,” diye ekledi. “Her görevde başka ayrıntılar da gerekebilir.”
---
@omurga
{kahraman} bu cevabı kesip defterinin içine koydu. Gün boyunca duyduğu bütün terimlerden sonra aslında en basit soruya dönmüşlerdi: Neyi nereden biliyoruz? Denizaltı 09'un sesi, onlara bu sorunun önemini hatırlatmıştı.
---
@omurga
{kahraman} bilim günü sunumunu hazırlarken haritadaki bir oku ters yönde çizdi. Oku gören {yoldas:yalin|bir arkadaş} “Araç kıyıya dönmüş” dedi, fakat kayıt aracı o saatte hâlâ görev hattında gösteriyordu. İkisi haritanın üzerindeki kuzey işaretini inceledi. Ekran görüntüsünü döndürürken yön simgesini yanlışlıkla sabit bırakmışlardı.

“Demek aynı noktalar başka yöne çevrilince bambaşka bir rota gibi görünebiliyor,” dedi {kahraman}. {yoldas:yalin|bir arkadaş} bu hatayı saklamadan sınıf sunumuna küçük bir örnek olarak koymayı önerdi. Bir haritanın neyi gösterdiğini anlamak için ölçek, yön ve kaynak bilgisinin birlikte okunması gerektiğini anlatabileceklerdi.

Sınıfın önünde haritayı önce yanlış hâliyle gösterdiler. Öğrencilerin çoğu aracın kuzeye ilerlediğini söyledi. Sonra yön işaretini düzelttiklerinde herkesten şaşkın sesler yükseldi. “Bir ok yüzünden mi?” diye sordu Selim. {kahraman} başını salladı. “Bir ok bazen bütün hikâyenin yönünü değiştirebilir.”

Derya da sunuma kısa bir sesli mesaj gönderdi. “Haritalar, grafikler ve sensör kayıtları aynı özenle okunmalı,” diyordu. “Aracımızın sorunu yalnız iletişim cihazında değildi; onu izleyen insanların da gelen bilgiyi doğru yorumlaması gerekiyordu.” Bu son cümle, {kahraman:yonelme} bütün gezinin özeti gibi geldi.
---
@omurga
Kulüp daha sonra küçük bir oyun geliştirdi. Oyuncular doğru yöne gitmek için üç kartı eşleştiriyordu: Konum, zaman, kaynak. Yanlış eşleşmede bir ceza sesi çıkmıyor; bunun yerine “Hangi bilgiyi yeniden kontrol etmek istersin?” sorusu görünüyordu. {yoldas:yalin|bir arkadaş} cezadan çok bu soruyu sevdi. Hata yapınca oyunun bitmemesi, yeniden düşünmeye yer bırakıyordu.

{kahraman:ilgi} hazırladığı oyunu ilk deneyenlerden biri küçük kardeşi oldu. Kardeşi yanlış koordinatı seçince ekranda yalnız “Tekrar dene” yazıyordu. Çocuk üzülüp oyunu kapatmak istedi. {kahraman} ekranı değiştirdi: “Saat doğru, ama konumu yeniden inceleyebilirsin.” Sonraki denemede kardeşi neyi kontrol edeceğini bildiği için daha dikkatli oynadı. {kahraman}, öğretici bir geri bildirimin yalnız hata olduğunu söylemekle kalmaması gerektiğini anladı.

{yoldas:yalin|bir arkadaş} bu düşünceyi genişletti. Oyundaki robot başarısız olduğunda başa dönmek yerine güvenli bir kontrol noktasında duracak, kullanıcıya hangi veriye yeniden bakmak istediğini soracaktı. Bu yaklaşım, Denizaltı 09'un gerçek görevindeki güvenlik süreçlerinden ilham alıyordu; ama birebir teknik uygulamayı taklit etmiyordu. Derya taslağı görünce çocukların hatayı cezalandırmak yerine anlamaya çalışmasını beğendi.
---
@omurga
Ertesi hafta okulda bilim günü düzenlendi. {kahraman} ve {yoldas:yalin|bir arkadaş}, gezide öğrendiklerini anlatan küçük bir masa hazırladı. Masanın ortasında su altı araştırma aracının kartondan yapılmış bir modeli vardı. Yanında üç farklı haber örneği bulunuyordu. Birinde “Kayıp Denizaltı Felaketten Döndü” yazıyordu. İkincisinde “Araştırma Aracının Bağlantısı Gecikti; Ekip Kontrol Sürecini Uyguladı” cümlesi vardı. Üçüncüsü ise yalnız “Robot Denizde Kayboldu” diyordu.

“Hangisini paylaşırdınız?” diye sordular ziyaretçilere. Çoğu öğrenci ilk başlığı heyecanlı buluyordu. {kahraman} kimseyi azarlamadı. Onlara üç başlıkta hangilerinin doğrulanmış bilgiye, hangilerinin yorum ve abartıya dayandığını sordu.

Bir öğrenci “Bütün gün beklediniz, demek gerçekten büyük bir tehlike vardı,” dedi. {yoldas:yalin|bir arkadaş}, görev sapmalarının ciddiyetle ele alınmasının doğru olduğunu; fakat “büyük felaket” sözcüğünün eldeki kayıtlarla desteklenmediğini anlattı. {kahraman} ikinci başlığın daha sakin olmasına rağmen olayın özünü daha iyi aktardığını söyledi.

Öğretmenleri, bilim gününde öğrencilerin yalnız doğru cevabı göstermekle yetinmemesini sevmişti. “İnsanların yanlış cevaba neden yöneldiğini anlamak da önemlidir,” dedi. {kahraman} filmlerdeki hızlı kurtarma sahnelerini düşündü. Gerçek kontrol odasında en etkileyici şey yüksek sesler değil, kimsenin acele hüküm vermemesi olmuştu.
---
@omurga
Sergi bitiminde Derya'dan kısa bir video geldi. Denizaltı 09 bakım tamamlandıktan sonra yeni bir göreve hazırlanıyordu. Bu kez sistemin bağlantı kontrol adımları gözden geçirilmiş, test süreçlerine yeni bir kayıt eklenmişti. “Bir sorun yaşandığında yalnız aracı geri getirmek yetmez,” dedi videoda. “Ne öğrendiğimizi sonraki göreve taşımamız gerekir.”

{kahraman} son kez defterine baktı. İlk sayfada “Bağlantı gecikti, nedeni bilinmiyor” yazıyordu. Son sayfada ise pek çok kavram sıralanmıştı: sinyal, zaman damgası, hipotez, doğrulama, güvenlik, veri. İlk gün bu sözcüklerin ne anlama geldiğini tam bilmiyordu. Şimdi her birinin bir olayla bağlantısı vardı.

{yoldas:yalin|bir arkadaş} defteri görmek isteyince {kahraman} ona son sayfadaki üç sütunu gösterdi. Bir zamanlar “Bildiğimiz” bölümünde tek bir satır bulunuyordu. Şimdi daha çok bilgi vardı, ama “Bilmediğimiz” sütunu da tamamen boşalmamıştı.

“Bunca şeyden sonra hâlâ bilmediğimiz var,” dedi {yoldas:yalin|bir arkadaş}.

“Olacak,” dedi {kahraman}. “Ama artık neyi bilmediğimizi daha iyi biliyoruz.”
---
@omurga
Tam çıkacaklarken telefonuna yeni bir mesaj düştü. Gönderen Derya'ydı. Mesajın yanında küçük bir su altı ses kaydı simgesi bulunuyordu: “Bu kez araçtan değil, derin deniz canlılarının seslerini araştıran ekipten bir kayıt. Sonraki kulüp etkinliğiniz için uygun olabilir.”

{kahraman} kaydı hemen açmadı. Önce açıklamasına ve kaynağına baktı. {yoldas:yalin|bir arkadaş} bunu görünce gülmeye başladı. “Sen artık gelen bütün mesajların kimden çıktığını sorgulayacaksın.”

“Güzel değil mi?” dedi {kahraman}. “Merakımı biraz daha güvenilir yapıyor.”

O akşam sahilde yürürken dalgalar taşlara vuruyordu. Denizaltı 09 artık suyun altında değildi, ama {kahraman} denizin altında hâlâ cevap bekleyen çok sayıda soru bulunduğunu biliyordu. Dalgaların sesi ona bir mesaj gibi geliyordu. Bu kez mesajı hemen çözmeye çalışmadı. Önce dinledi, sonra ertesi gün neyi araştırabileceğini düşündü.
---
@omurga
Kulübün son toplantısında {yoldas:yalin|bir arkadaş} tahtaya kocaman bir soru işareti çizdi. “Bu sembol artık bana başarısızlığı hatırlatmıyor,” dedi. “Bir şey daha kontrol edebileceğimizi hatırlatıyor.” {kahraman} onun yanına küçük bir saat ve pusula çizdi. Çocuklar ilk günkü alarmı yeniden konuştu; kimsenin acele etmeden güvenlik planına bakmasını hatırladılar. Selim “Robot geri dönmeseydi ne yapardınız?” diye sordu. {kahraman} bir an sustu. Böyle bir durumda uzman ekip kendi planına göre çalışacak, öğrenciler de güvenli yerlerinde kalacaktı. Hikâyeler bazen kurtarma sahnesini kahramanlıkla doldururdu; gerçek hayatta doğru görev paylaşımı daha önemliydi. {kahraman} defterini kapattı. Bilmediği çok şey vardı, ama bilmediğini söylemek artık onu korkutmuyordu.

Kontrol odasından ayrılırken {kahraman} duvardaki büyük saati fark etti. İlk gelişinde yalnız geciken dakikaları saymıştı. Şimdi aynı saat ona kayıtların ne zaman oluşturulduğunu, hangi sırayla ulaştığını ve neden doğru karşılaştırılması gerektiğini hatırlatıyordu. {yoldas:yalin|bir arkadaş} “Yine saate baktın,” dedi. {kahraman} gülümsedi. “Bu kez yalnız kaç dakika geçtiğini değil, o dakikalarda ne öğrendiğimizi de düşünüyorum.”
---
@omurga
Çalışma masasında duran karton denizaltıyı son kez eline aldığında {yoldas:yalin|bir arkadaş} gövdesinin üstüne küçük bir yıldız çizdi. {kahraman} bunun bir ödül işareti olduğunu sandı. {yoldas:yalin|bir arkadaş} başını salladı. “Yıldız benim kahramanlığım için değil,” dedi. “Derya Hanım ve ekip arkadaşları için. Bir şey ters gittiğinde paniğe kapılmadan sorumluluk aldılar.” {kahraman} yıldızın yanına küçük bir dalga çizdi. Sonra karton modeli kulüp dolabına yerleştirdiler. Bir sonraki yıl başka öğrenciler bu hikâyeyi okuduğunda, denizin altındaki sessizliğin insanların düşünmesini nasıl öğrettiğini görebilecekti.
