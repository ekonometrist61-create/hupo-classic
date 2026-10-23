---
baslik: "Fırtına Öncesi Son Sefer"
slug: "hr085-firtina-oncesi-son-sefer"
fis_kodu: "HR-085"
tur: macera
konu: firtina_risk_karar
sinif_alt: 7
sinif_ust: 7
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Deniz sakin görünüyor. Ama tabletteki tahmin ve telsizden gelen uyarı farklı şeyler söylüyor. Dönmek mi, devam etmek mi?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 7
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [kesif, guvenlik]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: tahmin_hr085, tur: lexeme, etiket: "tahmin", yuva: hr085_tahmin, islev: first_hint}
    - {id: uyari_hr085, tur: lexeme, etiket: "uyarı", yuva: hr085_uyari, islev: application}
    - {id: deyim_hr085, tur: idiom, etiket: "Aklına gelmek", yuva: hr085_aklina, islev: application}
    - {id: kavram_hr085, tur: concept, etiket: "Öngörü ile kesin bilgi ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (7. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 11, metin: "Kıyıya on dakika kala tekneye ne vurdu?", secenekler: [{id: A, metin: "İlk sert rüzgâr"}, {id: B, metin: "Büyük bir dalga"}, {id: C, metin: "Yağmur"}, {id: D, metin: "Bir kuş sürüsü"}], dogru: A, aciklama: "Kıyıya on dakika kala teknenin burnuna ilk sert rüzgâr vurmuştu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 8, metin: "Metne göre tahminler hakkında hangi sonuç çıkarılabilir?", secenekler: [{id: A, metin: "Kesin sözler değil, verilere dayanan olasılıklardır"}, {id: B, metin: "Kesin ve değişmez bilgilerdir"}, {id: C, metin: "Hiç kullanılmamalıdır"}, {id: D, metin: "Yalnız ilk saatler için geçerlidir"}], dogru: A, aciklama: "Tahminler, koşullara göre değişebilen olasılık değerlendirmeleridir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 2, metin: "Deniz Hanım'ın bu sözüne göre fazla görünen bir tedbir nasıl değerlendirilmelidir?", secenekler: [{id: A, metin: "Fazla görünen bir tedbir, otomatik olarak gereksiz sayılmaz"}, {id: B, metin: "Her tedbir mutlaka gereksizdir"}, {id: C, metin: "Tedbir hiç alınmamalıdır"}, {id: D, metin: "Yalnız bilgisayar tedbiri belirler"}], dogru: A, aciklama: "Güvenlik açısından alınan bir önlem, sonradan gereksiz görünse de değerli olabilir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 21, metin: "Metinde geçen tahmin ne anlama gelir?", secenekler: [{id: A, metin: "Gelecekteki koşullara ilişkin olasılık değerlendirmesi"}, {id: B, metin: "Bir tür tekne"}, {id: C, metin: "Bir yüzme yarışı"}, {id: D, metin: "Bir güvenlik yeleği"}], dogru: A, aciklama: "Tahmin, gelecekteki hava ve deniz koşullarına dair olasılık değerlendirmesidir."}
deyim_cumleleri:
  hr085_aklina: "Selim Bey'in sözü aklına geldi: “Hava ile pazarlık yapamayız.”"
---
@omurga
Sabah henüz altı olmamıştı. Limanın üstündeki hava serindi ama deniz, mavi bir cam gibi dümdüz uzanıyordu. {kahraman}, araştırma teknesinin güvertesine adım atarken bunun kusursuz bir gün olacağını düşündü. İki haftadır kıyıdaki deniz çayırlarını gözlemlemek için hazırlanıyorlardı. Bu hafta sonunda su sıcaklığı, görünürlük ve canlı çeşitliliğine ilişkin kayıtlar tamamlanacak, okulun kıyı araştırmaları sergisinde gösterilecekti. {isaret:deniz}

“Bu kadar sakin denizde ne olabilir ki?” dedi arkadaşı {yoldas:yalin|bir arkadaş}, çantasını bir kenara bırakırken.

Deniz araştırmaları merkezinin sorumlusu Deniz Hanım başını kaldırdı. “Bunu denizde uzun süre çalışanlara sorarsan farklı cevaplar alırsın,” dedi. “Sakin görünmesi, birkaç saat sonra da sakin kalacağını göstermez.”

Teknenin adı *Kuzey Yıldızı*ydı. Kaptan Selim Bey, ekibe güvenlik yeleklerinin nasıl takılacağını yeniden gösteriyordu. Kimse bunu eğlenceli bulmuyordu; hatta {yoldas:yalin|bir arkadaş} geçen haftaki eğitimi hatırladığını söyleyerek omuzlarını silkti. Selim Bey gülümsedi. “Hatırlıyor olman iyi. O zaman bugün de doğru yaparsın.”
---
@omurga
{kahraman} yeleğinin kopçasını sıkıştırdı. Araştırma merkezinde gönüllü çalışmaya başladığında deniz canlılarını gözlemlemeyi düşünmüştü; hava raporu okumayı değil. Ama artık bu iki işin birbirinden ayrı olmadığını öğreniyordu. Deniz Hanım tabletindeki {kelime:hr085_tahmin} açtı. Sabah rüzgâr zayıftı. Öğleden sonraya doğru ise basınç düşüşü ve kuvvetli rüzgâr olasılığı artıyordu. Saat tahmini kesin değildi; hücrelerin nerede ve ne zaman güçleneceği değişebilirdi.

“Planlanan ölçüm alanı limana yirmi dakika mesafede,” dedi Selim Bey. “Dokuzdan önce dönme hedefimiz var. Ancak koşullar erken bozulursa hiç beklemeden döneceğiz.”

{yoldas:yalin|bir arkadaş}, “Bir saatlik çalışma için fazla tedbir değil mi?” diye sordu.

Deniz Hanım çantasını kapattı. “**Tedbirin fazlası ile gereksizi aynı şey değildir**. Yapacağımız iş önemli, ama bugünün en önemli başarısı herkesin güvenle geri gelmesi.”

Tekne yavaşça hareket ederken {kahraman} arkasına döndü. Kıyıdaki evler sabah ışığında birer küçük kutu gibiydi. Henüz hiçbir şey başlamamış olmasına rağmen, bu sözler ona yolculuğun heyecanından daha kalıcı geldi.
---
@omurga
Araştırma başlamadan bir hafta önce merkezde küçük bir hazırlık provası yapılmıştı. {kahraman}, {yoldas:yalin|bir arkadaş} ve başka üç öğrenci rüzgâr yönünü ölçen cihazın yanında sıra bekliyordu. {yoldas:yalin|bir arkadaş} her seferinde oku eliyle çevirmeye kalkmış, Deniz Hanım bunun cihazın doğal hareketini bozacağını söylemişti. “İyi niyetle dokunmak bile veriyi değiştirebilir,” demişti. O gün öğrendikleri, sahada neden hiçbir şeye rastgele müdahale etmemeleri gerektiğini açıklıyordu.

Provada her gruba üç senaryo verilmişti. Birinde hava sakin kalıyor, ikincisinde yağış başlıyor, üçüncüsünde ise beklenmedik rüzgâr uyarısı geliyordu. {yoldas:yalin|bir arkadaş} her durumda ölçümü tamamlamayı seçmişti; diğer öğrenciler farklı düşünmüştü. {kahraman} üçüncü senaryoda geri dönmeyi savununca arkadaşları onu fazla temkinli olmakla suçlamıştı. {kahraman} o anda cevap bulamamış, yalnız kendini savunmak için yüksek sesle konuşmuştu.

Akşam annesiyle yürürken bu olayı anlatmıştı. Annesi, okul gezilerinde zor kararlar vermek zorunda kalmış bir sağlık görevlisiydi. “Bir grubun seni cesur bulmasını mı, yoksa herkesin güvenli olmasını mı istersin?” diye sormuştu. {kahraman} sorunun basit göründüğünü, ama arkadaşlarının önünde cevap vermenin zor olduğunu söylemişti. Annesi, “Bazen doğru kararın ödülü alkış değildir,” demişti. “Sadece bir sonraki günü sağlıklı karşılamaktır.”
---
@omurga
Şimdi gerçek sefer başladığında {kahraman} o konuşmayı hatırlıyordu. Fakat bu kez hayalî bir senaryo değil, değişken bir deniz vardı önlerinde. Güverteden kıyıdaki küçük camiye ve liman ışığına baktı. Birazdan gördüklerini not ederken hem meraklı hem de dikkatli olabileceğini kendine hatırlattı.
---
@omurga
İlk gözlem noktası kayalık burnun güneyindeydi. Ekip deniz çayırlarının bulunduğu koyu koruma programı kapsamında kayıt altına alıyordu. Kimse canlılara dokunmuyor, yalnız onaylı cihazlarla ve merkez çalışanlarının gözetiminde ölçüm yapıyordu. Suyun üzerinde küçük dalgalar vardı. Deniz Hanım sıcaklık sensörünü hazırladı; {kahraman} değerleri kayıt formuna yazdı.

“On yedi virgül altı,” dedi Deniz Hanım.

{kahraman} rakamı not etti, sonra birimi ekledi: “Santigrat derece.”

“Güzel. Birim yazılmazsa rakamın ne anlama geldiği kaybolabilir.”

{yoldas:yalin|bir arkadaş}, suyun berraklığını ölçen diski aşağı indirdi. Disk gözden kaybolana kadar ip üzerindeki işaretleri saydı. İlk denemesinde son işareti kaçırdı. “Bir daha yapalım,” dedi. Çabuk karar vermiş olmaktan rahatsızdı. Geçen ay bütün işlerde en hızlı öğrencinin kendisi olduğunu düşünüyordu; araştırma merkezinde ise yanlış kaydı en hızlı alan kişi olmak istemediğini öğrenmişti.

İkinci istasyonda {kahraman}, su yüzeyinin renginin biraz koyulaştığını fark etti. Gökyüzü hâlâ açıktı. “Deniz daha derin olduğu için mi?” diye sordu. Deniz Hanım olabileceğini söyledi, ama tek açıklama olmayabileceğini hatırlattı. Bulutların açısı, dip yapısı ve ışık da görünüşü etkileyebilirdi. {kahraman}, gördüğü şeyle vardığı sonucu ayrı satırlara yazdı.
---
@omurga
Saat sekizi biraz geçiyordu. Selim Bey'in telsizi kısa bir ses çıkardı. Liman görevlisi kıyının batısında rüzgârın beklenenden erken sertleştiğini bildirdi. Selim Bey tablete baktı. Bölgedeki {kelime:hr085_uyari} henüz en yüksek seviyede değildi; yine de tahminin hızla değiştiği görülüyordu.

“Üçüncü noktaya geçmeyelim,” dedi.

{yoldas:yalin|bir arkadaş} bir an yüzünü buruşturdu. “Ama sergide tam o noktanın verisi eksik kalacak.”

{kahraman} de bunu düşündü. Üçüncü istasyon, deniz çayırlarının azaldığı sınırdı. Burası olmazsa çalışmanın sonuçları daha zayıf olacaktı. Selim Bey dümeni limana doğru çevirdi. “Bugün eksik veriyle döneriz,” dedi. “Eksik veri tamamlanabilir. Güvenli dönüş ise ertelenemez.”

{kahraman}, formdaki boş hücreye baktı. Henüz limandan uzaklaşmış sayılmazlardı. Fakat o küçük boşluk, yapacakları araştırmanın nasıl anlatılacağını şimdiden değiştiriyordu.

İkinci ölçüm istasyonuna geldiklerinde Deniz Hanım {kahraman:yonelme} önceki üç haftanın sıcaklık verilerini gösterdi. Aynı noktada yapılan ölçümler arasında küçük farklar vardı. {kahraman}, bir haftanın diğerinden biraz daha sıcak olmasını denizin her yerde ısındığının kanıtı saymak üzereydi. Deniz Hanım onu durdurdu: “Aynı saatte mi, aynı derinlikte mi, aynı cihazla mı ölçtüğümüzü bilmeden böyle geniş bir sonuç çıkaramayız.” {kahraman}, sıcaklık değerlerinin yanına ölçüm koşullarını da ekledi.
---
@omurga
{yoldas:yalin|bir arkadaş} görünürlük diskinin suya eğik indiğini fark ettiğinde ölçümü baştan almak zorunda kaldı. Her iki denemeyi de defterine yazmak istemiyordu. İlk rakam işini zorlaştırıyordu. Selim Bey'in yardımcısı ona farklı bir noktadan seslendi: “Yanlış deneme bile neyi kontrol etmen gerektiğini gösterir. Onu yok sayma, neden tekrar ettiğini belirt.” {yoldas:yalin|bir arkadaş} bu kez ölçümü düzeltti ve iki değerin yanına kısa açıklama koydu.

Güneş yükselirken {kahraman:ilgi} gözleri kayalık kıyının önündeki siyah lekeye takıldı. Uzaktan bakıldığında kirlilik gibi görünüyordu. Deniz Hanım bunun deniz çayırı kümelerinin bulunduğu alan olabileceğini söyledi ama son sözü gözleme bıraktı. Teknenin güvenli gözlem noktasından çekilen fotoğraflar geçmiş yılların görüntüleriyle karşılaştırılacaktı. Çocukların neye baktığını iyi anlaması için tek bir işaret yetmiyordu.

Tam o sırada limandan gelen ilk telsiz sesi duyuldu. Araştırmanın yarattığı küçük heyecan, bir anda başka tür bir dikkate dönüştü. Selim Bey konuşmayı bitirince ekibe planı yeniden gözden geçirdiğini bildirdi. {yoldas:ilgi|bir arkadaşın} yüzünden isteksizlik okunuyordu. Fakat artık kararın yalnız eksik kalacak verilerle ilgili olmadığını herkes biliyordu.
---
@omurga
Dönüş yolunda {yoldas:yalin|bir arkadaş}, telefonunda başka bir hava uygulaması açtı. Orada yağmur ancak öğlene doğru görünüyordu. “Bakın,” dedi, “burada daha üç saat var.”

Deniz Hanım ekranı inceledi. “Bu uygulamanın haritası geniş bir bölgeyi gösteriyor. Merkezin kullandığı kısa süreli gözlemler ve deniz uyarıları başka bilgiler içeriyor. Farklı tahminleri anlamak önemlidir, ama yalnız hoşumuza gideni seçemeyiz.”

{kahraman} iki ekran arasındaki farkı düşündü. Birinde küçük bulutlar, diğerinde renkli rüzgâr okları vardı. İkisinin de sayıları vardı ama aynı şeyi göstermiyorlardı. Tahminler birer kesin söz değil, verilere dayalı olasılıklardı. Bu nedenle mevcut koşullarla birlikte değerlendirilmeliydi.

Kaptanın telsizine ikinci uyarı geldi. Kıyıdaki bir ölçüm şamandırası rüzgâr hızında belirgin artış kaydediyordu. Selim Bey kısaca cevap verdi, sonra hızlarını güvenli seyir için uygun düzeyde tuttu. {kahraman} güvertenin yanındaki hareketleri izledi. Uzakta, daha önce fark etmediği bulutların altı koyulaşmıştı.

{yoldas:yalin|bir arkadaş} bir şey söylemedi. Sonra usulca, “Yine de ölçümümüz yarım kaldı,” dedi.
---
@omurga
“Evet,” dedi {kahraman}. “Ama ne zaman yarım bırakmamız gerektiğini öğrendik.”

{yoldas:yalin|bir arkadaş} bu sözü hemen kabul etmedi. Araştırma sergisinde kendi grubunun en başarılı olmasını istiyordu. Diğer gruplar sonuç grafikleri hazırlarken onların üçüncü istasyonu boş kalacaktı. Son haftalarda yaptığı bütün hazırlıkların yarım kaldığını düşünmek ona ağır geliyordu.

Deniz Hanım yanlarına oturdu. “Bilimsel kayıtların içinde yalnız yaptığınız ölçümler bulunmaz,” dedi. “Hangi koşulda neyi neden yapamadığınızı da yazarsınız. Bu, çalışmanın sınırıdır; saklanması gereken bir kusur değildir.”

{kahraman} deftere şu cümleyi ekledi: “Üçüncü istasyon, güncel hava ve deniz uyarıları nedeniyle ziyaret edilmedi.” Bir anda boş hücre, açıklaması olan bir karar hâline gelmişti.

Kıyı araştırma merkezinde bir duvarda üç farklı harita asılıydı: Günlük rüzgâr gözlemleri, mevsimlik deniz akıntıları ve geçen yılın araştırma noktaları. {yoldas:yalin|bir arkadaş}, telsizdeki uyarıdan sonra ilk kez haritaların hepsine aynı anda bakmak istedi. Deniz Hanım'ın tableti bunların yalnızca bir bölümünü gösteriyordu. Her haritanın görevi ayrıydı ve hiçbiri tek başına bütün kararı veremezdi.
---
@omurga
{kahraman} açık denizdeki küçük beyaz köpükleri görmeye başladığında, bunları okul kitaplarındaki rüzgâr çizimleriyle karşılaştırdı. Çizimlerde oklar tertemizdi; gerçek denizde her dalga diğerini bozuyordu. İşte bu yüzden kaptanın deneyimi ile anlık ölçümlerin birlikte değerlendirilmesi gerekiyordu. {yoldas:yalin|bir arkadaş} telefonundaki güneşli hava simgesine yeniden bakmadı. Tekneyi sallayan rüzgâr artık soyut bir olasılık değildi.

Yine de {kahraman} paniklememeye çalışırken garip bir şey fark etti: Soluk alışverişini hızlandırdıkça başı dönüyordu. Deniz Hanım ona sakin şekilde nefes almasını ve oturduğu yerde kalmasını söyledi. {kahraman} birkaç saniye gözlerini güvertedeki sabit bir noktaya çevirdi. Korku tamamen gitmedi ama düşünmeye devam edebildi. Böyle bir anda kendini korkusuz göstermeye çalışmak yerine yardım istemek daha doğruydu.

{yoldas:yalin|bir arkadaş}, “Dönüş kararını tam zamanında verdiniz,” dedi Selim Bey'e. Kaptan yalnız kısa bir cevap verdi: “Hava ile pazarlık yapamayız.” Bu cümle onun için sert bir öğüt değildi; birkaç dakikalık değişken koşulların gösterdiği bir gerçekti.
---
@omurga
Kıyıya on dakika kala teknenin burnuna ilk sert rüzgâr vurdu. Suyun yüzeyindeki çizgiler kabardı. Selim Bey gökyüzüne baktı, sonra bir kez daha limanla haberleşti. Herkesin oturmasını, eşyaların sabitlenmesini istedi. {kahraman} çantasının fermuarını kapatıp yerine geçti. {yoldas:yalin|bir arkadaş} bu kez söylenenleri tekrar ettirmedi.

Dalgalar tekneyi hafifçe sallarken {kahraman} kalbinin hızlandığını hissetti. Korku, zihnine önce garip bir düşünce getirdi: Geri dönmeseydik ne olurdu? Soru bir yarışın sonucu gibi değildi. Cevabını bilmek istemiyordu.

Selim Bey sakin bir sesle komutlarını verdi. Görevi deneyimli kaptan yürütüyordu; çocuklar kendilerine belirtilen güvenli alanda bekliyordu. Deniz Hanım herkesi gözden geçirdi. “İyi misiniz?” diye sordu. {kahraman} başını salladı. {yoldas:ilgi|bir arkadaşın} elleri titriyordu ama konuşabiliyordu.

“İyiyim,” dedi, “sadece biraz heyecanlandım.”

“Bu normal,” dedi Deniz Hanım. “Korkunca kendimizi suçlamamız gerekmiyor. Yapmamız gereken, güvenlik kurallarını izlemek.”

Birkaç dakika sonra limanın korunaklı girişine ulaştılar. Kıyıda görevli ekip onları karşıladı. {kahraman} yere bastığında bacaklarında hafif bir titreme vardı. Deniz koyu görünüyordu ama limanın içi daha sakindi. Selim Bey tekneyi bağladı; Deniz Hanım katılımcıların durumunu kontrol etti. Sonra herkes araştırma merkezinin kapalı salonuna geçti.
---
@omurga
Bir süre kimse sergiden söz etmedi. Pencereden dışarı bakıyorlardı. Yağmur ince damlalarla başladı, ardından hızlandı. {yoldas:yalin|bir arkadaş} camdaki su izlerini seyrederken “Biraz daha kalsaydık...” diye mırıldandı.

{kahraman} onun cümlesini tamamlamadı. Çünkü kimse ne olacağını kesin bilemezdi. Bildikleri tek şey, koşullar kötüleşmeden önce güvenli geri dönüş kararının alındığıydı.

Merkeze döndüklerinde ekip yalnız dinlenmedi. Önce ölçüm cihazlarının güvenle toplandığından emin olundu, sonra kısa bir değerlendirme toplantısı yapıldı. Selim Bey, hangi uyarının ne zaman geldiğini, dönüş kararını neye dayandırdığını ve yolculuğun hangi bölümünde rüzgârın arttığını anlattı. Çocuklar konuşmaları kesmeden dinledi. Deniz Hanım, her öğrenciden yalnız gözlemlediği bir şeyi söylemesini istedi. “Sanırım” ile başlayan yorumlar ayrıca not edildi.

{kahraman}, “Kıyıya yaklaşırken uzaktaki bulutların altı koyulaştı,” dedi. {yoldas:yalin|bir arkadaş}, “Dalgalar liman dışında daha belirginleşti,” diye ekledi. İkisi de bu belirtilerden fırtınanın tam şiddetini hesaplayamayacaklarını biliyordu. Yine de gözlemler, anlık uyarıları anlamlandırmalarına yardımcı olmuştu.
---
@omurga
Toplantıda başka bir soru gündeme geldi. Araştırma ekibi bir sonraki hafta aynı istasyonlara gidecek olursa ne yapmalıydı? Deniz Hanım hemen tarih vermedi. Önce ölçüm hedeflerinin yeniden değerlendirileceğini, ardından güvenli hava penceresinin araştırılacağını söyledi. Üçüncü istasyonun verisini tamamlamak uğruna her uygun görünen günü değerlendirmek doğru değildi. {yoldas:yalin|bir arkadaş}, eksik veri karşısında sabırlı olmanın da araştırmacı davranışı sayılabileceğini ilk kez düşündü.

Ertesi gün okulda başka bir arkadaşları “Korktuğunuz için mi döndünüz?” diye sordu. {yoldas:yalin|bir arkadaş} tam itiraz edecekti ki {kahraman}, “Evet, korktuğumuz anlar oldu,” dedi. “Ama dönüş kararını yalnız korku değil, kaptanın gözlem ve uyarılarla yaptığı değerlendirme belirledi.” {yoldas:yalin|bir arkadaş} ona baktı. Bu cevabın utanılacak bir yanı olmadığını o anda anladı.
---
@omurga
Ertesi hafta okulda sergi panoları hazırlanırken {yoldas:yalin|bir arkadaş} üçüncü istasyon hücresini kırmızıyla boyamak istedi. “Eksik olduğu belli olsun,” dedi. {kahraman}, eksik veriyi bir hata veya kötü not gibi göstermemeyi önerdi. “Neden gidilmediğini yazalım. O zaman bilinçli karar verdiğimiz anlaşılır.”

Sınıftaki bazı öğrenciler rüzgâr hızındaki değişimi gösteren grafiğe baktığında şaşırdı. İlk saatlerde değerler düşüktü, sonra kısa aralıkta yükselmişti. Meteoroloji öğretmeni, kıyıda yerel değişimlerin hızlı olabileceğini, tek bir günün de genel iklimi göstermediğini anlattı. {kahraman} ikisini ayıran kelimeleri büyük harfle yazdı: Hava durumu belirli zaman ve yerdeki koşullardır; iklim uzun yılların örüntülerini ele alır.

{yoldas:yalin|bir arkadaş} serginin açılışında grubun temsilcisi olmayı önerdi. {kahraman} onun önemli bir şey öğrendiğini hissediyordu. Ziyaretçilere veri eksikliğini nasıl anlatacağını merak etti.

Bir anne panonun önüne geldiğinde, “Niçin son istasyon yok?” diye sordu. {yoldas:yalin|bir arkadaş} derin bir nefes aldı. “Hava koşulları beklenenden erken bozuldu,” dedi. “Güncel uyarıları değerlendiren kaptanımız dönüş kararı verdi. Bu yüzden ölçüm yapılmadı. Tahminleri karşılaştırmak ve ne zaman vazgeçileceğini bilmek araştırmanın parçasıymış.”
---
@omurga
{kahraman} onun sesindeki değişimi duydu. Önceden böyle konuşurken mazeret arayan biri gibi görünmekten korkardı. Şimdi alınan kararı gerekçesiyle açıklıyordu.

Ziyaretçi, “İyi ki dönmüşsünüz,” dedi. “Peki veri eksikse araştırmanız bitti mi?”

“Hayır,” dedi {yoldas:yalin|bir arkadaş}. “Uygun bir zamanda, uzmanlarla yeniden planlayabiliriz. Ama eksik veriyi tahmin ederek dolduramayız.”

Serginin kapanışında Deniz Hanım sınıfa bir mesaj gönderdi. “Bu çalışmanın en değerli sonucu,” yazmıştı, “denizi kontrol edemeyeceğimizi ama kararlarımızı dikkatle verebileceğimizi göstermeniz.” {kahraman} mesajı {yoldas:yonelme|bir arkadaşa} okudu. Arkadaşı deniz çayırlarının fotoğrafına baktı; sanki artık yalnız suyun altındaki bitkileri değil, bütün o araştırma gününü görüyordu.

Sergi hazırlıklarında beklemedikleri yeni bir anlaşmazlık çıktı. Grafik tasarımını yapan öğrenci, üçüncü istasyonun yerine ilk iki istasyonun ortalamasını yerleştirmeyi önerdi. “Ziyaretçi boşluk görünce çalışmanız eksik sanacak,” dedi. {kahraman} buna karşı çıktı. “Orada ölçüm yapmadık. Ortalama başka bir şey, gerçek gözlem başka bir şey.” Öğretmenleri tartışmayı duyunca her iki gruptan görüşlerini gerekçelendirmesini istedi. Grafik başına “Ölçülmeyen veri” notu koyma önerisi kabul edildi. Böylece eksikliği saklamadan sonuçları anlaşılır gösterebildiler.
---
@omurga
Bu küçük karar, {yoldas:yonelme|bir arkadaşa} denizdeki dönüş anını yeniden hatırlattı. O gün de önemli görünen bir hedef uğruna bilinmeyeni yok saymaya yaklaşmıştı. Şimdi kâğıt üzerinde aynı hatayı yapmak daha kolay görünüyordu. Kimse zarar görmeyecekti belki, ama yanlış gösterilen rakam sonraki okuyuculara güvenilmez bir sonuç sunacaktı.[[deyim:hr085_aklina]] Verilerle de pazarlık yapılamayacağını anladı.

Sergiye gelen iki ziyaretçi, gruba farklı sorular sordu. Biri, “Hiç fırtınaya yakalansaydınız daha heyecanlı bir hikâye olmaz mıydı?” dedi. {yoldas:yalin|bir arkadaş} başını salladı. “Belki hikâye olarak heyecanlı olurdu; ama bizim amacımız tehlike yaşamak değildi.” Diğeri, “Bu kadar erken dönerek araştırmaya zarar vermediniz mi?” diye sordu. {kahraman}, ölçümleri uygun koşullarda yeniden yapma planından söz etti. Çalışmanın güvenlik yüzünden ertelenmesiyle rastgele sonlandırılması aynı şey değildi.

Okulun bahçesine çıktıklarında hava durgundu. {yoldas:yalin|bir arkadaş} bir süre gökyüzüne baktı. Tek bir sakin günün insana verdiği güvenin ne kadar yanıltıcı olabileceğini düşünüyordu. Artık bulutları korkarak izlemiyordu; gördüklerini doğru yorumlamak için hangi bilgilere ihtiyaç duyduğunu merak ediyordu.
---
@omurga
Merkezin küçük toplantı salonunda asılı eski bir fotoğraf, {yoldas:ilgi|bir arkadaşın} dikkatini çekti. Fotoğrafta yıllar önce yapılan bir kıyı araştırmasının ekibi görülüyordu. Altına yalnız “Çalışma durduruldu: yüksek dalga” yazılmıştı. {yoldas:yalin|bir arkadaş} bunun başarısız bir araştırmanın fotoğrafı olduğunu düşündü. Deniz Hanım başka türlü açıkladı: “O ekip dalga koşulları nedeniyle geri çekilmiş, sonra çalışmalarını güvenli günlerde sürdürmüş. Raporları bugün bile kaynak olarak kullanılıyor.”

{kahraman}, fotoğrafın neden özellikle duvara asıldığını merak etti. Deniz Hanım, merkeze yeni katılanların yalnız başarılı ölçümleri değil, güvenli sınırları da öğrenmesini istediklerini söyledi. “Bir insanın cesareti bazen bir şeyi yapabilmesinde, bazen yapmaması gerektiğine karar verebilmesinde görünür,” dedi.

{yoldas:yalin|bir arkadaş}, bu sözden sonra ilk seferi anlatan sunumunu yeniden düzenledi. En baştaki başlık “Fırtınadan Kaçış”tı. Bunu “Değişen Koşullarda Karar” olarak değiştirdi. Yeni başlık daha az heyecanlı gelebilirdi; fakat yaşadıkları olaya daha sadıktı. Araştırmayı dinleyen öğrenciler belki bir gün kamp gezisinde, bisiklet turunda ya da okul etkinliğinde hava değişince bu örneği hatırlayacaktı.
---
@omurga
{kahraman} de sunuma küçük bir düşünme sorusu ekledi: “Hedefine çok yaklaşmışken durmak zorunda kalsan ne hissedersin?” Bu sorunun tek doğru cevabı yoktu. Hayal kırıklığı, korku, öfke ve rahatlama aynı anda yaşanabilirdi. Önemli olan duyguların varlığını kabul etmek ve kararın gerekçesini unutmamaktı. {yoldas:yalin|bir arkadaş} soruyu okuduğunda hiç tereddüt etmedi: “Ben o gün hepsini hissettim.”

Kulüp toplantısından sonra {kahraman} ve {yoldas:yalin|bir arkadaş}, deniz araştırmaları merkezinin hazırladığı hava raporu sözlüğünü okumaya karar verdi. “Kuvvetli rüzgâr”, “yerel sağanak”, “görüş mesafesi” ve “basınç değişimi” gibi ifadeleri daha önce haberlerde duymuşlardı; ama hepsinin aynı tür bilgi olmadığını yeni anlıyorlardı. {kahraman} sözlükte “uyarı” ile “tahmin”in birbirinin yerine kullanılmadığını gördü. Tahmin gelecekteki koşullara ilişkin olasılıkları değerlendirirken uyarı, belirli risklerin ciddiyetine dikkat çekiyordu. {yoldas:yalin|bir arkadaş} yanına büyük harflerle “Tek bir simgeye güvenme” yazdı.

Bir gün fen öğretmenleri küçük bir tartışma açtı: “Deniz durgunsa hava güvenlidir, diyebilir miyiz?” Bazı öğrenciler evet dedi; başka biri sabah durgun olan havanın öğleden sonra değişebileceğini hatırlattı. {yoldas:yalin|bir arkadaş} kendi yaşadıklarını anlattı, fakat herkesin onun örneğine dayanarak bütün denizler hakkında genelleme yapmasını istemedi. “Bizim günümüzde değişim hızlıydı,” dedi. “Başka günlerde farklı olabilir. Önemli olan güncel bilgi ve güvenlik planı.” Öğretmen bu ayrımı beğendi.
---
@omurga
{kahraman} okuldan eve dönerken telefonuna hava durumu bildirimleri geliyordu. Her bildirimi büyük bir tehlike sanmak da, hepsini önemsememek de doğru değildi. Bir planı etkileyebilecek bilgileri güvenilir kaynaklardan kontrol etmek, yaptığı etkinliğe göre değerlendirmek gerekiyordu. Bir sonraki hafta sınıf gezisi için hava bozulma ihtimali görülünce öğretmenleri geziyi kapalı bir müzeye çevirdi. {yoldas:yalin|bir arkadaş} bu kararı en hızlı destekleyen öğrencilerden biri oldu. “Macera başka gün de olur,” dedi gülerek. “Bir müzede de merak edecek şey buluruz.”

Öğrenciler, araştırma merkezindeki deneyimli ekipten bir kişinin de sunuma katılmasını istemişti. Merkez görevlisi Leyla Hanım, yıllar boyunca pek çok hava değişimine tanık olduğunu anlattı. “Bazen geri döndüğünüzde hava yeniden açılır,” dedi. “O zaman kararınızın gereksiz olduğunu düşünebilirsiniz. Oysa karar verirken bildiğiniz koşulları ve olası sonuçları değerlendirmiş olmanız gerekir. Daha sonra olanlar, o anda sahip olmadığınız bilgiyle verilmiş kararı otomatik olarak yanlış yapmaz.”
---
@omurga
{yoldas:yalin|bir arkadaş} bu söz üzerine, limana döndükten sonraki yağmuru ne kadar önemsediklerini fark etti. Şiddetli yağışın onları doğruladığını düşünmüşlerdi; ama yağmur hiç başlamasa bile uyarılar ve değişen koşullar karşısında geri dönmek gerekçeli bir karar olabilirdi. {kahraman} bunu defterine yazdı. Geleceği tam olarak bilmeden karar vermek zordu, fakat insanlar bu yüzden rastgele davranmak zorunda değildi.

Leyla Hanım öğrencilere bir örnek daha verdi. “Bir dağ yürüyüşünde hava kötüleşme ihtimali artarsa dönüş kararı verebilirsiniz. Sonradan güneş çıkması, o anki seçiminizi başarısız yapmaz. Öte yandan tehlikeli bir durumda şans eseri zarar görmeden kalmak da riskli davranışı doğruya dönüştürmez.” Çocuklar sessizce dinledi. Herkesin sonucu değil, kararın gerekçesini değerlendirmesi gerektiğini anlıyorlardı.

Serginin kapanışında {yoldas:yalin|bir arkadaş}, araştırma defterini eline alıp seyircilere gösterdi. “Buradaki en önemli rakam,” dedi, “belki yazamadığımız rakamdır. Çünkü onu uydurmadık.” Birkaç kişi alkışladı. {kahraman} gülümsedi. Arkadaşının ilk sabahki hâlini düşünüyordu: Veri eksik kalmasın diye en uzun yolu seçmek isteyen çocuk, şimdi doğru bir boşluğun da dürüstçe gösterilmesi gerektiğini savunuyordu.
---
@omurga
Bir ay sonra merkezden yeni tarih önerisi geldi. Hava uygun olduğunda üçüncü istasyona dönülebilecekti. Bu kez ön hazırlık toplantısına {yoldas:yalin|bir arkadaş} en erken gelen öğrenciydi. Tahmin ekranlarının hangi saatlerde güncellendiğini, uyarının nerede yayımlandığını ve geri dönüş koşullarını sordu. Selim Bey sorulara sabırla cevap verdi.

{kahraman}, “Sen iyice kaptan yardımcısı oldun,” diye takıldı.

{yoldas:yalin|bir arkadaş} güldü. “Hayır. Ben ancak neyi bilmediğimi daha iyi anlıyorum.”

O gün ölçüm ekibinin bir üyesi hastalandığı için sefer ertelendi. {yoldas:yalin|bir arkadaş} bu habere üzülse de kimseyi acele ettirmedi. Önceki ayki sergide öğrendiklerini unutmamıştı. Bir görevin doğru zamanda yapılması da görevin kendisi kadar önemliydi.

Okul koridorundaki sergi fotoğrafları kaldırılırken {kahraman}, pano başlığının altında hâlâ duran notlarına son kez baktı. Başlık Fırtına Öncesi Son Seferdi. Başta bu adı bir tehlikeden son anda kaçış gibi düşünmüşlerdi. Şimdi farklı geliyordu. Son sefer, zor koşulları yenmek için yapılan son hamle değildi; değişen koşullarda durmayı bilmenin hikâyesiydi.
---
@omurga
{yoldas:yalin|bir arkadaş} panoyu katlarken “Cesaret, bazen devam etmemekmiş,” dedi. {kahraman} başını salladı. İkisi limandaki ilk sabahı hatırladı: Sakin deniz, pırıl pırıl gökyüzü, güvertede bekleyen araştırma çantaları. O sabah her şeyin planlandığı gibi gideceğini sanmışlardı. Fakat yolculuğun en gerçek dersi, planı gerektiğinde değiştirebilmekti.

Dönüşün üzerinden aylar geçince okulun bilim kulübü, yeni başlayan öğrencilere araştırma etiğiyle ilgili küçük bir atölye düzenledi. {yoldas:yalin|bir arkadaş} konuşmasını bitirirken önüne iki fotoğraf koydu. Birinde sabahın sakin denizi, ötekinde daha sonra kıyıdan çekilmiş koyu bulutlar görünüyordu. “Sadece ilk fotoğrafa bakarak günün tamamını tahmin edebilir miyiz?” diye sordu. Çocuklar ikiye bölündü. Bazıları evet dedi, bazıları hayır. {yoldas:yalin|bir arkadaş} onlara tek bir görüntünün bütün zamanı temsil etmediğini anlattı.

{kahraman} ise araştırma defterinin kopyasını gösterdi. Üçüncü istasyon satırı hâlâ boştu. Yanında dönüş kararının nedeni yazıyordu. “Şimdi yeniden ölçebilme olanağımız var,” dedi. “Ama burada yazan kararı silmek istemiyoruz. O gün neyi neden yapmadığımız da araştırmamızın parçası.”
---
@omurga
Çocuklardan biri, “Hiç kızmadınız mı?” diye sordu. {yoldas:yalin|bir arkadaş} güldü. “Kızdım. Hatta ilk başta bunun başarısızlık olduğunu düşündüm. Sonra anladım ki bazı kararları doğru kılan şey, herkesin onu hemen beğenmesi değil.”

{kahraman} pencereden limanın bulunduğu tarafa baktı. Orada yeni bir gün, yeni bir hava durumu ve belki yeni bir araştırma bekliyordu. Denize döneceklerdi; ama artık onunla yarışmayacaklardı. Meraklarını yanlarına alacak, bilgilerini sınayacak, gerekirse tekrar geri döneceklerdi. Bu düşünce ona ilk seferin heyecanından daha güçlü bir güven verdi.

Kısa süre sonra okulda velilerin katıldığı bir toplantı yapıldı. Araştırma kulübü çalışmalarını anlatırken bazı veliler çocukların denize çıkmasından endişe duydu. Selim Bey hangi güvenlik kurallarının izlendiğini, hava koşullarının neden son kararda belirleyici olduğunu ve araştırma gezilerinin ancak gerekli izinlerle planlandığını açıkladı. Velilerden biri “Hiç risk olmamasını sağlayamaz mısınız?” diye sordu. Kaptan dürüstçe cevap verdi: “Sıfır risk sözü veremem. Ama değerlendirebilir, azaltabilir ve koşullar uygun değilse faaliyeti yapmayabiliriz.”
---
@omurga
{kahraman} bu cevabı duymaktan memnundu. Sonuç ne kadar güzel görünürse görünsün, gerçekleştirilemeyecek bir güvence vermek doğru olmazdı. {yoldas:yalin|bir arkadaş} artık kararın yalnız öğrencileri değil, aileleri, merkezi ve görevlilerin sorumluluklarını da etkilediğini görebiliyordu. O sabah dönüş kararına karşı çıktığında yalnız kendi istediği veriyi düşünmüştü. Şimdi bütün tabloyu görüyordu.

O yaz {kahraman} ile {yoldas:yalin|bir arkadaş} kıyıda yürürken uzakta araştırma teknesini gördü. Yanında yeni katılan gönüllüler vardı. Güvertede yelekleri düzgün takılmış, bir görevlinin açıklamasını dinliyorlardı. {yoldas:yalin|bir arkadaş} onlara seslenmek istedi, sonra vazgeçti. Her öğrenci aynı şeyi kendi yolculuğunda keşfedecekti. {kahraman}, “Tekne yine ölçüme çıkıyor,” dedi. {yoldas:yalin|bir arkadaş} sakin denize baktı. “Evet,” diye cevap verdi. “Ama hangi koşullarda döneceklerini de biliyorlar.” Bir zamanlar yalnız uzaklaşmanın macera olduğunu düşünürdü. Şimdi güvenle geri dönmenin de anlatılmaya değer bir hikâyesi olduğuna inanıyordu.

İşte o gün ikisi de araştırmanın yalnız topladıkları sayılardan ibaret olmadığını daha iyi kavradı; doğru zamanda, doğru gerekçeyle vazgeçmek de bilimsel sorumluluğun parçasıydı.
---
@omurga
{kahraman}, eve dönerken limandaki dalgaları izledi. Sabah aynı suyun yüzeyi bambaşka görünüyordu. Havanın değişmesiyle insanların kararları da değişmek zorunda kalmıştı. Babası günün nasıl geçtiğini sorunca “Denize açılmadık” demekle yetinmedi. Neden geri döndüklerini, hangi işaretleri gördüklerini ve güvenli bir kararın neden bazen görünmeyen bir başarı olduğunu anlattı.

Bu deneyim onların ileride yapacakları her geziye sessiz bir yol gösterici olarak eşlik edecekti.
