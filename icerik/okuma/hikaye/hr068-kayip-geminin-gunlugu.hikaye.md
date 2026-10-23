---
baslik: "Kayıp Geminin Günlüğü"
slug: "hr068-kayip-geminin-gunlugu"
fis_kodu: "HR-068"
tur: macera
konu: kanit_kaynak_elestirisi
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D5]
yetiskin_uygun: false
tanitim: "Müzedeki gemi maketi ve bir günlük. Gemi kayıp mı, yoksa sadece bir sefer mi eksik kaldı?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [kesif, kultur_miras]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D5
  ogrenme_hedefleri:
    - {id: seyir_hr068, tur: lexeme, etiket: "seyir", yuva: hr068_seyir, islev: first_hint}
    - {id: rota_hr068, tur: lexeme, etiket: "rota", yuva: hr068_rota, islev: application}
    - {id: numune_hr068, tur: lexeme, etiket: "numune", yuva: hr068_numune, islev: application}
    - {id: deyim_hr068, tur: idiom, etiket: "Gözleri parlamak", yuva: hr068_gozleri_parladi, islev: application}
    - {id: kavram_hr068, tur: concept, etiket: "Kanıt, yorum ve bilinmeyen ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Seyir defterinde ne eksikti?", secenekler: [{id: A, metin: "Son sayfası yırtılmıştı"}, {id: B, metin: "Kapağı"}, {id: C, metin: "Haritası"}, {id: D, metin: "Çanı"}], dogru: A, aciklama: "Defterin son sayfası yırtılmıştı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 5, metin: "Haritadaki çarpılar hangi anlama geliyordu?", secenekler: [{id: A, metin: "Su örneği alınan duraklar"}, {id: B, metin: "Batma noktaları"}, {id: C, metin: "Liman yerleri"}, {id: D, metin: "Tehlikeli kayalar"}], dogru: A, aciklama: "Açıklama kartı çarpıların örnek alınan durakları gösterdiğini belirtiyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 9, metin: "Sarp'ın öğrendiği ders neydi?", secenekler: [{id: A, metin: "Bir haritanın güzel çizilmiş olması onu doğru yapmaz"}, {id: B, metin: "Haritalar hiç kullanılmamalı"}, {id: C, metin: "Yalnız yeni haritalar doğrudur"}, {id: D, metin: "Haritalar kesinlikle doğrudur"}], dogru: A, aciklama: "Kaynağın güvenilirliği ve tarihi kontrol edilmelidir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 8, metin: "Metinde geçen numune ne anlama gelir?", secenekler: [{id: A, metin: "Araştırma için alınan örnek"}, {id: B, metin: "Bir gemi adı"}, {id: C, metin: "Bir harita işareti"}, {id: D, metin: "Bir kitap türü"}], dogru: A, aciklama: "Numune, incelemek üzere alınan örnektir."}
deyim_cumleleri:
  hr068_gozleri_parladi: "Çocukların gözleri parladı; sorular birden maceranın kapısına dönüşmüştü."
---
@omurga
{kelime:hr068_seyir} defterinin son sayfası yırtılmıştı. Sayfanın hemen öncesinde tek bir cümle yazılıydı: Işığı göremediğimiz gece, denizin sesi bize başka bir şey anlattı. {isaret:kitap}

Altıncı sınıf öğrencisi Mete, cümleyi üçüncü kez okudu. Kent denizcilik müzesinde sergilenen defterin kopyası, ahşap bir masaya açık bırakılmıştı. Defterin yanında küçük bir gemi maketi vardı. Maketin baş kısmına gümüş renkli harflerle Derya yazılmıştı. Altındaki açıklama, bu geminin uzun yıllar önce kıyı gözlemleri yapmak için kullanıldığını söylüyordu. Fakat sergi başlığında daha heyecanlı bir ifade vardı: Kayıp Geminin Sırrı.

"Bence gemi bir fırtınada batmış," dedi Mete'nin arkadaşı Sarp. Yanlarındaki {yoldas:yalin|bir arkadaş}, açıklama kartını gösterdi. "Burada battığı yazmıyor. Yalnızca seferin son günleriyle ilgili kayıtların eksik olduğu belirtilmiş." Sarp, "O zaman niye kayıp diyorlar?" diye sordu. Mete cevabı bilmiyordu. Sorunun peşine düşmeye karar verdi.
---
@omurga
Sınıfları müzeye tarih ve çevre araştırması için gelmişti. Öğretmenleri Aslı Hanım, çocuklardan sergideki nesneler hakkında soru geliştirmelerini istemişti. Her grup, bulduğu bilgileri doğrudan belge, yorum ve bilmediğimiz başlıkları altında toplayacaktı. Müze uzmanı Deniz Hanım, kopya belgelerle çalıştıklarını, asılların koruma bölümünde bulunduğunu anlattı.

Araştırmaya başlamadan önce öğretmenleriyle bir hazırlık yapmışlardı. Aslı Hanım sınıfa üç eski görünümlü belge kopyası dağıtmış ve her birinin üzerine gizli bir soru yazmıştı. Birinde "Bunu kim hazırladı?", diğerinde "Ne zaman yazıldı?", üçüncüsünde "Neyi kanıtlayabilir?" soruları vardı. Mete üçüncü soruyu en kolay sanmıştı. Fakat iki farklı kişinin aynı olayı anlatırken farklı ayrıntılar vurguladığını görünce işin zor olduğunu anlamıştı. Öğretmen, "Bir belgenin içinde yanlış olabilecek ifadeler bulunabilir; onu doğru kullanmak için bağlamını öğreniriz," demişti. Bu hazırlık müzede işlerine yarayacaktı.
---
@omurga
Müzenin girişinde büyük bir deniz haritası asılıydı. Kıyı çizgisi, küçük adalar ve derinlik işaretleri görülüyordu. Sarp, haritadaki noktalı çizgilerin gizli bir yolu gösterdiğini sanmıştı. Deniz Hanım bu çizgilerin denizcilikte kullanılan farklı anlamlara gelebileceğini, her haritada açıklama anahtarına bakılması gerektiğini gösterdi. Mete, deniz haritasının bir kara haritasına benzemesine rağmen bambaşka ihtiyaçlara göre düzenlendiğini fark etti. {yoldas:yalin|bir arkadaş}, "Bir kara yolunda engel olan tepe, deniz yolunda başka bir bilgiyle gösteriliyor," diye yorumladı. Üçü, haritaları karşılaştırırken sembolleri tahmin etmek yerine açıklamaları okumayı alışkanlık edindi.

Derya'nın maketine baktıklarında birbirinden farklı ayrıntılar göze çarpıyordu. Güvertedeki küçük sandıklar, direklerin konumu ve çanın asıldığı yer dikkatlerini çekti. Sarp, "Kaptan neden bu kadar küçük gemiyle araştırmaya çıkmış?" diye sordu. Müze panosunda geminin ölçülerine ilişkin tasarım bilgileri vardı. Deniz Hanım, maketin eğitim amacıyla oluşturulduğunu, her ayrıntısının tarihî geminin birebir ölçüsünü yansıtmayabileceğini hatırlattı. Mete bir kez daha gördüğü nesnenin kaynağını sorguladı. Maket, gerçek gemiyle ilgili fikir veriyordu; ama kendi başına eksiksiz bir kanıt değildi.
---
@omurga
"Neden gerçek defteri elimize veremiyorsunuz?" diye sordu Sarp. Deniz Hanım, "Eski kâğıtlar ışık, nem ve dokunmadan etkilenebilir," dedi. "Kopyalar, araştırma yaparken asılları korumamızı sağlar." Mete deftere yeniden baktı. Kâğıdın üzerinde koyu mavi mürekkeple yazılmış tarihler, hava notları ve kısa ölçümler vardı. Her şey bir maceradan çok sıradan bir çalışma günlüğüne benziyordu.

İlk kayıt şöyle başlıyordu: Sabah rüzgâr kuzeydoğudan. Kıyıdaki suyun görünümü dününkünden farklı. Ölçüm tekrarlanacak. Mete, "Bir kaptan niye suyun rengini yazsın?" diye sordu. Deniz Hanım, geminin o dönemde kıyı çevresini gözlemlemek amacıyla kullanıldığını, çalışanların su ve hava koşullarıyla ilgili notlar tuttuklarını açıkladı. "Geçmişte yapılan her ölçüm bugünkü yöntemlerle birebir aynı değildir," diye ekledi. "Yine de bir gözlem kaydı olarak incelenebilir."
---
@omurga
{yoldas:yalin|bir arkadaş} haritadaki noktaları izledi. Günlükte belirli günlerin karşısına konmuş küçük çarpılar bulunuyordu. Çarpılar kıyı boyunca ilerliyor, sonra geniş bir koyun yakınında bitiyordu. Sarp hemen koyu gösterdi. "İşte battığı yer!" {yoldas:yalin|bir arkadaş} itiraz etti: "Bir işaretin bittiği nokta, geminin battığı nokta olmak zorunda değil. Belki defterin eksik kısmı burada başlıyordur."

Mete iki görüş arasında kaldı. Gizem çözmek istiyordu; batık gemi fikri kulağa heyecanlı geliyordu. Fakat serginin amacını hatırladı. "Önce işaretlerin ne anlama geldiğini öğrenelim," dedi. Deniz Hanım onlara harita anahtarını verdi. Çarpılar batma noktası değil, su örneği alınan duraklar olarak açıklanmıştı. Sarp yüzünü buruşturdu. "İlk ipucumuz boşa gitti." {yoldas:yalin|bir arkadaş} güldü. "Hayır, yanlış bir yorumdan kurtulduk."
---
@omurga
Öğrenciler müzenin arşiv köşesinde ikinci bir belge buldu: liman görevlisinin imzaladığı teslim listesi. Listede Derya'nın kıyıdan getirdiği örnek kavanozları, ölçüm araçları ve işlenmiş haritalar vardı. Tarih, kayıp olduğu sanılan seferden birkaç gün sonraydı. Mete heyecanla "Demek gemi dönmüş!" dedi. Aslı Hanım, "Bu liste neyi kesin gösteriyor?" diye sordu. {yoldas:yalin|bir arkadaş}, "Malzemelerin limana teslim edildiğini," dedi. "Ama geminin kendisinin nasıl döndüğünü, listeden tek başına bilmiyoruz."

Sarp teslim listesindeki küçük notu işaret etti: Malzemeler kıyı aracılığıyla gönderildi. Bu kez herkes durdu. Geminin bütün yolculuğu hakkında hâlâ sorular vardı. Mete, bir belgenin doğru yorumlandığında bile bütün hikâyeyi anlatmadığını anladı. Üçü belgeleri tarih sırasına dizmeye karar verdi.
---
@omurga
Çalışma masasına ilk oturduklarında çocuklar farklı yöntemler önerdi. Sarp kayıp sayfanın ne yazdığını hayal ederek başlamalarını istiyordu. Mete önce bütün tarihleri sıralamakta ısrar etti. {yoldas:yalin|bir arkadaş} ikisini uzlaştırdı: "İki ayrı sütun açalım. Hayal ettiklerimizi kurgu olarak, belgeleri kanıt olarak yazalım." Böylece yaratıcılıkları engellenmedi ama bilimsel çalışma birbirine karışmadı. Sarp boş sayfaya "Sisli gecede gizli bir ada" başlıklı kısa bir öykü yazdı. Sonra onu katlayıp çantasına koydu. Bu hikâyeyi sınıfın edebiyat köşesine asabilirdi; araştırma panosuna değil.

Müze görevlileri çocuklara bir çalışma masası ayırdı. Mete tarihleri düzenledi, {yoldas:yalin|bir arkadaş} belgeleri türlerine ayırdı, Sarp harita işaretlerinin anlamını not etti. Ellerinde üç parçalı bir tablo oluştu: gözlem günlüğü, malzeme teslim listesi ve sonradan çizilmiş liman planı. Fakat üçüncü belgenin üzerindeki tarih diğer ikisinden daha yeniydi. "Bu harita o sefer sırasında kullanılmış olamaz," dedi Mete. "Sonradan çizilmiş."
---
@omurga
Liman teslim listesindeki sözcükler konusunda da anlaşmazlık çıktı. "{kelime:hr068_numune}" ifadesini Mete önce küçük bir malzeme parçası sanmıştı. Deniz Hanım, araştırma için alınan örnek anlamına geldiğini açıkladı. Çocuklar numune, örnek, gözlem ve ölçüm sözcüklerinin birbirine yakın olsa da aynı şeyi anlatmadığını konuştu. Bir su örneğinin alınması başka, o örnek üzerinde ölçüm yapılıp sonucun yazılması başkaydı. {yoldas:yalin|bir arkadaş} defterindeki başlıkları buna göre ayırdı: alınan örnekler, yazılı gözlemler, yorumlanan sonuçlar.

Bir öğleden sonra müzeye geri dönmelerine izin verildi. Bu kez Aslı Hanım çocukları kütüphane görevlisiyle tanıştırdı. Görevli, denizcilik tarihini anlatan güvenilir kaynakları bulmak için katalog aramasının nasıl yapıldığını gösterdi. Çocuklar kitabın adını, yazarını, basım yılını ve hangi belgelere dayandığını inceledi. Sarp bir internet sayfasında "Gizemli gemi bir gece yok oldu" başlığını görünce heyecanlandı. Fakat sayfanın kaynağı belirsizdi ve iddiasını destekleyen belge vermiyordu. "Bunu araştırma sonucuna yazamayız," dedi Mete. Sarp bu kez itiraz etmedi.
---
@omurga
Kütüphanede buldukları genel denizcilik kitabı, seyir defterlerinin hava, yön, mesafe ve olay notları içerebildiğini açıklıyordu. Mete geminin günlüklerindeki kısa cümleleri yeniden okumak istedi. Önceden sıkıcı sandığı satırlar şimdi birer ipucuna benziyordu. {yoldas:yalin|bir arkadaş} hava notlarını bir çizelgeye yerleştirdi. Bazı günler rüzgâr yönü değişmişti. Sarp bunun geminin hareketine nasıl etki edebileceğini sordu. Öğretmen kesin bir sonuç söylemek yerine, hava koşullarının {kelime:hr068_rota} planlamasında önem taşıdığını, fakat somut bir seferin kararlarını anlamak için o sefere ait daha fazla bilgi gerektiğini açıkladı.

Deniz Hanım, "İşte kaynak eleştirisi burada başlar," dedi. "Bir harita geçmişteki bir olayı gösterebilir, ama olaydan sonra hazırlanmışsa onu hazırlayan kişinin hangi bilgileri kullandığını da araştırmamız gerekir." Sarp bu sözleri defterine yazdı. Bir haritayı yalnızca güzel çizilmiş olduğu için doğru sayamayacağını yeni öğreniyordu.
---
@omurga
Serginin başka bölümünde Derya'nın küçük bir çanı bulunuyordu. Çanın kenarında geminin adı ve yapım yılı okunabiliyordu. Sarp, "Çan burada olduğuna göre gemi mutlaka battı," dedi. Mete, "Gemiden çıkarılıp saklanmış olabilir," diye karşılık verdi. {yoldas:yalin|bir arkadaş} üçüncü bir olasılık söyledi: "Gemi daha sonra başka amaçla kullanılmış olabilir." Aslı Hanım her olasılığın hangi yeni belgeyle sınanabileceğini sordu. Çocuklar artık "kesin" sözcüğünü daha az kullanıyordu.

Öğle arasında müzenin bahçesinde oturduklarında Sarp biraz sıkılmış görünüyordu. "Bence gizemi bozduk," dedi. "Ortada koca bir hazine haritası yok." Mete, "Ama günlükteki su ölçümlerini niye tuttuklarını öğrenmek istiyorum," dedi. {yoldas:yalin|bir arkadaş} de ekledi: "Belki gizem, geminin nerede battığı değil, neyi araştırdığıdır." Sarp bir süre düşünerek başını kaldırdı. "O zaman son sayfadaki ışık cümlesine dönelim."
---
@omurga
Yeniden içeri girdiklerinde Deniz Hanım, onlara kaptanın günlüğündeki bazı kelimelerin zamanla farklı anlamlarda kullanılmış olabileceğini hatırlattı. Çocuklar dönemin diline ait sözcükleri günümüz Türkçesiyle karşılaştırdı. "Seyir" yalnızca bakmak değil, denizde ilerleme ve izlenen yol anlamında da kullanılıyordu. "Rota" yolun yönünü anlatıyordu. Mete eski sözcükleri öğrenince metin biraz daha anlaşılır hâle geldi.

Son sayfaya yakın kayıtlarda, kıyı fenerinin sis yüzünden görünmediği belirtiliyordu. Gemidekiler ses işaretlerini dinleyerek kıyıya yaklaşmayı düşünmüş, ancak hava koşulları nedeniyle güvenli beklemeyi seçmişlerdi. "Belki 'denizin sesi' derken dalgalardan söz ediyorlar," dedi Sarp. {yoldas:yalin|bir arkadaş}, "Belki de başka bir uyarı sesinden. Metin açık değil," diye karşılık verdi. Mete, sayfanın boş kalan yerlerine hayalî cümleler yazmamaya karar verdi.
---
@omurga
Deniz Hanım, çocukları serginin arka bölümündeki çevre gözlem panosuna götürdü. Panoda suyun görünümü, kıyıdaki canlılar ve kirlenme gibi konuların zaman içinde nasıl araştırıldığı anlatılıyordu. Derya'nın günlüğündeki kısa notlar, o dönemin sınırlı araçlarıyla yapılan bir çalışma çabasını gösteriyordu. Çocuklar günümüzdeki bilimsel ölçümlerin farklı ve daha hassas yöntemler kullanabileceğini öğrendi. Mete'nin gözünde gemi artık yalnızca kaybolmuş bir araç değildi; insanların merakını taşıyan bir çalışma yeri hâline gelmişti.

Aslı Hanım çocukları düşünmeye zorlamak için başka bir kopya belge getirdi: Derya'ya benzer ad taşıyan farklı bir teknenin bakım kaydı. Mete ilk anda iki kaydı birbirine bağlamaya çalıştı. {yoldas:yalin|bir arkadaş} tarihlerden birinin çok farklı olduğunu fark etti. Ardından iki geminin yapım yerlerinin de uyuşmadığını gördüler. Sarp, "Aynı adla iki gemi olabilir mi?" diye sordu. Öğretmen başını salladı. İnsanların ve gemilerin adları tekrar edebilirdi; yalnız isim benzerliğine dayanarak kayıtları birleştiremezlerdi. Bu küçük tuzak, kimlik doğrulamanın neden önemli olduğunu gösterdi.
---
@omurga
Derya'nın günlüğünü okuyabilmek için eski yazı karakterlerini de incelemeleri gerekti. Müze görevlisi, defterin aslından hazırlanmış çevriyazı metnini gösterdi. Çocuklar çevriyazının araştırma amacıyla yazıldığını, yine de aslın yerine geçmediğini öğrendi. Mete bir kelimenin güç okunur olduğu satırda parantez içinde soru işareti gördü. "Bunu niye kesin yazmamışlar?" diye sordu. Deniz Hanım, "Okunamayan bir şeyi uydurmak yerine belirsizliği göstermek daha doğrudur," dedi. {yoldas:yalin|bir arkadaş} bu yaklaşımı kendi notlarına taşıdı; yanlış olduğundan emin olmadığı kelimenin yanına da soru işareti koydu.

Müze panosundaki "çevre araştırması" sözüyle ilgili yeni bir tartışma başladı. Sarp, "O dönemde herkes çevreyi bugünkü gibi korumayı mı düşünüyordu?" diye sordu. Deniz Hanım, geçmişteki insanların amaçlarını bugünkü düşüncelerle birebir aynı saymanın yanıltıcı olabileceğini söyledi. Kıyıdaki suyu inceleme nedeni balıkçılık, ulaşım, liman güvenliği veya başka bir pratik ihtiyaç olabilir; Derya'nın kayıtlarına bakmadan niyetini kesinleştiremezlerdi. Mete, "Ama bugün bu eski kayıtları çevredeki değişiklikleri düşünmek için kullanabiliriz," dedi. Uzman, yöntemleri ve karşılaştırılabilirliklerini incelemek şartıyla bunun araştırma sorusu olabileceğini açıkladı.
---
@omurga
Sınıfa döndüklerinde Aslı Hanım bir soru yöneltti: "Elinizdeki bilgilerle Derya'nın son seferi hakkında ne söyleyebilirsiniz?" Mete, "Kıyı araştırması yapıyordu; belirli noktalardan örnek alınmış," dedi. {yoldas:yalin|bir arkadaş}, "Malzemelerin daha sonra limana ulaştığını biliyoruz," diye ekledi. Sarp da, "Defterin eksik sayfası yüzünden bütün seferi kesin olarak yeniden kuramıyoruz," dedi. Öğretmen, kanıtın sınırını açıkça söylemelerini takdir etti.

Çocuklar araştırmalarını okul panosunda sunmaya karar verdi. Sarp ilk taslağın başlığına "Batık Geminin Büyük Gizemi" yazdı. Mete bu başlığın ilgi çekici olduğunu kabul etti ama doğru olmadığını söyledi. Uzun tartışmadan sonra "Kayıp Defter, Eksik Bilgi" başlığında anlaştılar. Altına da müzedeki başlığın ziyaretçi merakı uyandırdığını, fakat belgelerin geminin battığını kanıtlamadığını eklediler.
---
@omurga
Bir gün okulda sahte bir "kayıp gemi" haberi dolaştı. Haberde Derya'nın gizli bir ada yakınında kaybolduğu yazıyor, fakat kaynak gösterilmiyordu. Bazı öğrenciler Mete'ye gelip "Sırrı çözmüşsünüz!" dedi. Mete başta heyecanlandı; herkesin çalışmalarını duyması hoşuna gitmişti. Sonra haberin kendi ifadelerini çarpıttığını fark etti. {yoldas:yalin|bir arkadaş}, "Bir açıklama yazalım ama kimseyle alay etmeyelim," dedi. Üçü, ellerindeki kanıtları sakin bir dille özetledi ve kesin olarak bilinmeyen noktaları belirtti. Haber yayıldığı kadar çabuk unutulmadı; fakat yanlış bilginin nasıl düzeltileceği üzerine yararlı bir konuşma başladı.

Sarp haberi ilk paylaşan arkadaşına kızmıştı. "Bizi dinleseydin bunu yapmazdın," dedi. Arkadaşı üzülüp sessizleşti. Aslı Hanım çocukları yanına çağırdı. "Yanlış bilgi düzeltilmeli ama insanları küçük düşürmek başka bir yanlıştır," dedi. Sarp arkadaşından özür diledi. Sonra birlikte haberin başlığını incelediler. Bir başlığın dikkat çekici olmasının tek başına doğru olduğunu göstermediğini gördüler. Mete, "Gizemli" sözcüğünün kendisine bile bazen kanıttan daha çok güven verdiğini itiraf etti. Bu dürüstlük konuşmayı kolaylaştırdı.
---
@omurga
Sergi sunumunu düzenlerken çocuklar üç bölümlü bir pano tasarladı. Sol tarafta geminin maketi ve üzerinde açıklamalar, ortada defterden izinli kopya parçaları, sağ tarafta sorular yer alıyordu. En zor karar son bölümle ilgiliydi. Sarp, "Gemi nereye gitti?" sorusunu başlık yapmak istedi. {yoldas:yalin|bir arkadaş}, "Eğer cevap yoksa bunu açıkça belirtelim," dedi. Mete ise küçük bir kutu ekledi: Araştırmamızın sınırları. Burada eksik sayfa, belirsiz kelimeler ve tarihler arasındaki boşluklar yazılıydı. Öğrenciler ilk kez bulamadıkları bilgiye de sunumda yer vermenin değerini anladı.

Sunum günü herkes üç karttan birini seçti: Kanıt, Yorum, Bilinmeyen. Bir öğrenci "Gemi kıyıda su örneği toplamış," kartını kanıt bölümüne koydu. Başka biri "Gemi kesin fırtınada batmış," kartını yorum bölümüne yerleştirdi. Mete, belgelerde yalnızca bazı hava notları bulunduğunu, fırtınada batma sonucunun desteklenmediğini anlattı. Sarp ise "O hâlde bu cümleyi bilinmeyenlere taşıyalım," dedi.
---
@omurga
Sunumda dinleyicilere küçük bir oyun oynattılar. Üç kartın üzerinde sırayla şu cümleler yazıyordu: "Günlükte rüzgâr yönü kaydı var", "Kaptan sisli geceyi korkuyla geçirmiş olmalı", "Geminin bütün yolculuk rotası biliniyor". Dinleyiciler hangisinin belgeye dayandığını tartıştı. Mete ilk cümlenin doğrudan desteklendiğini, ikinci cümlenin duygusal yorum olduğunu, üçüncünün ise eldeki bilgilerle savunulamadığını açıkladı. Bu küçük oyun, uzun sunumun en çok ilgi gören bölümü oldu.

Müze görevlileri çocukların hazırladığı panoyu ziyaretçi eğitim alanında bir süre sergilemek istedi. Mete heyecanlandı ama yeni bir koşul koydu: Kendi çizdikleri harita, tarihî gerçek haritaymış gibi gösterilmemeliydi. Deniz Hanım bu öneriyi kabul etti. Panonun altına Öğrenci yorum çalışması ibaresi eklendi. Sarp da kurgu öyküsünü ayrı bir köşede yayımlamak için öğretmeninden izin aldı. Böylece tarih araştırması ve hayal gücü birbirini tamamladı, ama birbirinin yerine geçmedi.
---
@omurga
Bir süre sonra Sarp, defterindeki sisli gece öyküsünü arkadaşlarına okudu. Öyküde kaptan, bir ada ışığı gördüğünü sanıyor ama sonunda sisin içinde güvenli beklemeyi seçiyordu. Sarp, "Bu Derya'da gerçekten oldu demiyorum," diye özellikle belirtti. "Bu, araştırmadan esinlenerek yazdığım kurgu." Mete gülümseyerek onu alkışladı. {yoldas:yalin|bir arkadaş} de, "Araştırmamız eksik sayfayı dolduramadı ama sana güzel bir hikâye verdi," dedi. Sarp o gün hayal gücünün kanıtı değiştirmeden de özgür olabileceğini anladı.

Günün sonunda {yoldas:yalin|bir arkadaş} serginin karşısında durup, "Kayıp gemiyi bulamadık," dedi. Mete gülümsedi. "Belki başlangıçta yanlış şeyi arıyorduk." Sarp çanın fotoğrafına baktı. "Ben de batık hazine bulacağımızı sanmıştım," dedi. "Ama geminin yaptığını anlamak daha zor ve daha ilginçmiş."
---
@omurga
Yaz tatiline yaklaşırken Deniz Hanım çocuklara yeni bir mektup gönderdi. Mektupta, liman arşivindeki teslim listesinin daha iyi okunabilen bir kopyasına ulaşıldığı yazıyordu. Kopyada daha önce seçemedikleri bir satır netleşmişti: "Örnekler yardımcı tekneyle karaya taşındı." Mete bunun geminin seferini bütünüyle açıklamadığını biliyordu, fakat en azından malzemelerin nasıl ulaştığına ilişkin yeni bir bilgi sunuyordu. {yoldas:yalin|bir arkadaş} panodaki ilgili bölümü güncellemeyi önerdi. Sarp ise "Şimdi eski panomuz yanlış mı oldu?" diye sordu. Aslı Hanım, "O zamanki bilgilerle ne söylediğinizi ve yeni kaynağın ne eklediğini ayırırsanız araştırmanız gelişmiş olur," dedi.

Çocuklar panoya küçük bir tarih çizelgesi ekledi. İlk satırda ilk inceleme, ikinci satırda yeni belge, üçüncü satırda güncellenen yorum yazıyordu. Böylece ziyaretçiler bilginin nasıl değişebileceğini görebilecekti. Mete, bilimsel bir sonucun veya tarihsel yorumun yeni belgeler geldikçe yeniden değerlendirilebileceğini öğrendi. Bu durum onu rahatsız etmek yerine sevindirdi. Araştırmanın görevi ilk söylediğini sonsuza kadar savunmak değil, daha güçlü kanıtlarla daha doğru bir açıklamaya ulaşmaktı.
---
@omurga
Deniz Hanım çocukları izinli bir kıyı gözlemi etkinliğine de davet etti. Öğretmenler eşliğinde belediyenin güvenli seyir noktasından denizi incelediler. Hiçbiri suya girmedi, örnek toplamadı veya tehlikeli bir işe girişmedi. Yalnız dalga yönünü, rüzgârı ve kıyıdaki insanların faaliyetlerini gözlemlediler. Mete, günlüğe "su durgun" yazmanın denizin her noktasında aynı durumun olduğu anlamına gelmeyeceğini fark etti. Bulundukları açıdan sakin görünen yüzeyin biraz ileride farklı görünebildiğini söyleyen görevliyi dinledi. Gözlemin yeri ve zamanı en az gözlemin kendisi kadar önemliydi.

Kıyıdaki bir balıkçı, yıllardır aynı limana geldiğini anlattı. Sarp hemen eski gemiyi sorunca adam güldü. "O kadar yaşlı değilim," dedi. "Ama dedemden pek çok deniz hikâyesi duydum." {yoldas:yalin|bir arkadaş}, "Bunları dinleyebiliriz, fakat Derya'yla ilgili doğrudan kanıt olarak kullanamayız," dedi. Balıkçı, çocukların bu ayrımına şaşırdı. Sonra kendi çocukluğunda duyduğu bir fırtına hikâyesini anlattı. Mete hikâyeyi dikkatle dinledi ve anlatının yanına sözlü hatıra diye not düştü. İnsanların hafızasında saklanan deniz hikâyeleri değerliydi; ancak arşivdeki belgeyle aynı türden bilgi sunmuyorlardı.
---
@omurga
Dönüş otobüsünde herkes en çok neyin şaşırttığını anlattı. Sarp, "Ben en çok kendi uydurduğum öyküyü gerçek diye sunmamak gerektiğini öğrendim," dedi. {yoldas:yalin|bir arkadaş}, "Ben de arşiv belgesinin yeniden okununca yeni bilgi verebildiğini gördüm," diye ekledi. Mete ise "Bir geminin kaybolduğunu sandığımda, aslında bir dönemin araştırma yöntemlerini merak etmeye başlamışım," dedi. Aslı Hanım, bu üç cevabı duyunca gezi hedefine ulaştıklarını düşündü. Çocuklar yalnız yeni bilgi değil, bilgiyle nasıl ilişki kurulacağını da öğrenmişlerdi.

Yeni dönem başladığında küçük öğrenciler müzeye gitmeden önce Mete'lerden rehberlik istedi. Mete onlara "Denizcilik tarihini biz anlatacağız" demedi. Bunun yerine üç soru verdi: "Belgeyi kim hazırlamış? Ne zaman hazırlanmış? Hangi iddiayı gerçekten destekliyor?" Bir öğrenci bu soruların sıkıcı olduğunu söyleyince Sarp hemen "Ben de öyle sanıyordum," dedi. Sonra yırtık sayfanın fotoğrafını gösterdi. "Ama yanlış soruyla başlarsanız bütün gemiyi yanlış yerde ararsınız."[[deyim:hr068_gozleri_parladi]]
---
@omurga
Çalışmanın sonunda sınıf, arşivdeki belgeleri korumanın neden önemli olduğunu da konuştu. Aslı Hanım, eski kâğıtların zarar görmesi hâlinde üzerindeki bilgilerin bir kısmının geri getirilemeyebileceğini anlattı. Sarp, "Ama dijital kopyası varsa yeterli değil mi?" diye sordu. {yoldas:yalin|bir arkadaş}, kopyaların araştırmayı kolaylaştırdığını, fakat asıl belgenin malzemesi ve üzerindeki izler hakkında da bilgi taşıyabildiğini hatırlattı. Mete ise kopyaların doğru adlandırılması ve saklanmasının da önemli olduğunu söyledi. Bir dosyaya yalnızca "eski gemi" adı verilse hangi belge olduğunu karıştırmak çok kolaydı. Bunun üzerine okul bilgisayarında kullandıkları örnek dosyaların adlarına belge türü ve tarih eklediler.
---
@omurga
Mete bir akşam annesine, "Bir belgeden emin olmadığımızda ne yapmalıyız?" diye sordu. Annesi, bazen "Bilmiyorum" demenin en dürüst cevap olduğunu söyledi. Mete bunun kulağa kolay gelse de bir sunum sırasında zor olabileceğini itiraf etti. Herkes bir sonuç bekliyordu. Annesi, "Sonuç yalnızca kesin cevap olmak zorunda değil," dedi. "Hangi soruları aydınlattığını ve hangilerinin açık kaldığını söylemek de sonuçtur." Mete ertesi gün defterine bu fikri yazdı. Artık çalışmasını sunarken eksik sayfadan utanmıyor, bu boşluğu araştırmanın doğal bir parçası olarak görüyordu.

Sarp ise gemi maketiyle ilgili merakını küçük bir çizime dönüştürdü. {yoldas:yalin|bir arkadaş} ona seyir defterindeki tarihleri karıştırmamasını hatırlattı. Mete de çizimin altına "hayalî sahne" yazmasını önerdi. Sarp kabul etti. Bu küçük iş birliğiyle araştırma panosunun yanında bir sanat köşesi oluştu. Ziyaretçiler aynı gemiyi hem belgeye dayalı bilgilerle hem de hayalî bir resimle görebiliyor, ikisi arasındaki ayrımı okuyabiliyordu. Böylece tarih çalışması ile yaratıcı yazarlık birbirini engellemek yerine birbirini besliyordu.
---
@omurga
Mete eve giderken defterinin en son sayfasına yeni bir cümle yazdı: **Bir boşluğu hayal gücüyle doldurabilirsin; ama onu kanıt diye sunamazsın**. Bu cümleye baktığında yırtık sayfa artık ona kızdırıcı görünmüyordu. Tam tersine, her eksik bilginin doğru sorularla araştırılabileceğini hatırlatıyordu. Derya'nın günlüğü bitmemiş olabilirdi; çocukların merakı ise daha yeni başlamıştı. Artık onu aramak için gizli bir hazineye veya gerçeği açıklayan tek bir sihirli belgeye ihtiyaçları olmadığını biliyorlardı. Bir defter, bir harita ve birkaç çelişkili kayıt bile dikkatli bakıldığında pek çok soruya dönüşebiliyordu. Her soru yeni bir karşılaştırma, her karşılaştırma daha dürüst bir açıklama isteği doğuruyordu. Mete, bu yolculuğun sonunu değil, bir sonraki sorusunu ve onun peşinden gelecek yeni keşifleri merak ediyordu.
