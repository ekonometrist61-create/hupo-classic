---
baslik: "Güneş Dağının Haritası"
slug: "hr086-gunes-dagi-haritasi"
fis_kodu: "HR-086"
tur: macera
konu: yukselti_harita_olcu
sinif_alt: 7
sinif_ust: 7
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Haritadaki kırmızı rota kısa ve kolay görünüyor. Ama üç rakam birbirini tutmuyor. Hangi sayı doğru?"
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
    - {id: topografya_hr086, tur: lexeme, etiket: "topoğrafya", yuva: hr086_topografya, islev: first_hint}
    - {id: egim_hr086, tur: lexeme, etiket: "eğim", yuva: hr086_egim, islev: application}
    - {id: deyim_hr086, tur: idiom, etiket: "Gözlerini çevirmek", yuva: hr086_gozler, islev: application}
    - {id: kavram_hr086, tur: concept, etiket: "Net yükselti farkı ile toplam tırmanış ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (7. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 2, metin: "Haritadaki iki yükseklik değeri hangileriydi?", secenekler: [{id: A, metin: "1.200 ve 1.400"}, {id: B, metin: "1.240 ve 1.360"}, {id: C, metin: "1.500 ve 1.250"}, {id: D, metin: "1.250 ve 1.450"}], dogru: D, aciklama: "Yükseklik çizgilerinin yanında 1.250 ve 1.450 yazıyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 5, metin: "Başlangıç ile bitiş yüksekliği farkı küçük olan bir yol neden zor olabilir?", secenekler: [{id: A, metin: "Yol çok uzun olduğu için"}, {id: B, metin: "İnişli çıkışlı olduğu için toplamda birçok kez tırmanış gerekebilir"}, {id: C, metin: "Haritada çizgi olmadığı için"}, {id: D, metin: "Yükseklik ölçülemediği için"}], dogru: B, aciklama: "Net yükselti farkı küçük olsa da yol boyunca toplam tırmanış fazla olabilir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 5, metin: "Yoldaşın bu sözüyle ne kastedilir?", secenekler: [{id: A, metin: "Haritalar tamamen yanlıştır"}, {id: B, metin: "Kısa yollar her zaman daha güvenlidir"}, {id: C, metin: "Haritalar hiç kullanılmamalıdır"}, {id: D, metin: "Haritadaki kısalık, yürüyüşteki yorgunluğu tam yansıtmayabilir"}], dogru: D, aciklama: "Kâğıt üzerindeki mesafe ve yükselti, arazide yaşanan zorluğun tamamını göstermeyebilir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 4, metin: "Metinde geçen yükselti ne anlama gelir?", secenekler: [{id: A, metin: "Bir tür yürüyüş ayakkabısı"}, {id: B, metin: "Bir yön levhası"}, {id: C, metin: "Bir yerin deniz seviyesinden yüksekliği"}, {id: D, metin: "Bir hava olayı"}], dogru: C, aciklama: "Yükselti, bir noktanın deniz seviyesine göre yüksekliğidir."}
deyim_cumleleri:
  hr086_gozler: "Önemli olan, gözlerini yalnız zirveye değil, o zirveye güvenli biçimde gitmeyi sağlayan bilgiye de çevirmeyi öğrenmiş olmalarıydı."
---
@omurga
Güneş Dağı'nın zirvesi sabahları gerçekten güneşe benziyordu. Yakındaki köyde yaşayanlar, ilk ışıkların dağın tepesindeki açık renk kayalara düşmesini öyle tarif ederdi. Yedinci sınıftan {kahraman} ise bu ismi fazla romantik buluyordu. Ona göre dağın asıl ilginç yanı, yamacında birbirinden çok farklı üç yürüyüş rotası bulunmasıydı. {isaret:gunes}

Okulun doğa kulübü, rehber eşliğinde yapılan bir gündüz gezisine hazırlanıyordu. Amaç zirveye çıkmak değildi; orman sınırındaki seyir terasına ulaşmak, bölgede görülen bitkileri fotoğraflamak ve yer şekillerini incelemekti. Kulübün danışmanı Nihan Öğretmen, yürüyüşün herkes için güvenli ve erişilebilir biçimde planlanacağını açıklamıştı. Öğrencilerin görevi, uzmanların seçtiği resmi rotanın neden uygun olduğunu anlamaktı.

{kahraman} bilgisayar başında üç renkli çizgiyi karşılaştırıyordu. Mavi rota kısa ama dik, yeşil rota uzun fakat yumuşak {kelime:hr086_egim} görünüyordu. Kırmızı rotanın yanında ise “Toplam yükselme: 120 metre” yazıyordu. Eğer bu değer doğruysa kırmızı yol hem kısa hem kolay olabilirdi.
---
@omurga
“Bence kırmızıyı seçelim,” dedi arkadaşı {yoldas:yalin|bir arkadaş}. “Bir saatte varırız.”

Yanlarında duran Elif şaşırdı. “Bu kadar kısa yolun nasıl az yükseldiğini anlamadım. Haritada çizgi yukarı kıvrılıyor.”

{kahraman} yükseklik çizgilerini yakınlaştırdı. Bir çizginin yanında 1.250, diğerinde 1.450 yazıyordu. Aralarındaki fark 200 metreydi; oysa rota açıklamasında 120 görünüyordu. Bu sayılar hangi noktalara aitti? {kahraman} hesap makinesini açtı, sonra durdu. Önce hangi değerlerin karşılaştırıldığını anlamak gerekiyordu.

Nihan Öğretmen, çocukların çizdiği tabloyu görünce “İyi bir soru bulmuşsunuz,” dedi. “Ama rotayı kendi yorumumuzla değiştirmeyeceğiz. İşaretli ve görevli tarafından onaylanan güzergâha uyacağız. Sizden istediğim, haritanın ne söylediğini dikkatle incelemeniz.”

{yoldas:yalin|bir arkadaş} biraz bozularak başını salladı. “Ben yalnız kısa yol seçmek istemiştim.”

{kahraman} gülümsedi. “Belki de ilk adımımız yol seçmek değil, haritadaki farkın nedenini bulmak.”

{yoldas:yalin|bir arkadaş} o akşam evde babasının çektiği yürüyüş fotoğraflarına baktı. Bazı karelerde yamaç çok dik, bazılarında neredeyse dümdüz görünüyordu. Babası kameranın açısının görüntüyü değiştirebileceğini anlattı. {yoldas:yalin|bir arkadaş} ertesi gün aynı yamacı iki farklı açıdan çizdi ve arkadaşlarına gösterdi. Resimlerden hangisinin daha doğru olduğunu sorduklarında cevap şaşırtıcıydı: İkisi de aynı yerin gerçek görüntüsüydü ama her biri farklı bir özelliğini öne çıkarıyordu.
---
@omurga
{kahraman} bu örneği haritalarla karşılaştırdı. Bir harita da gerçek arazinin kendisi değildi; belli bilgileri öne çıkaran bir gösterimdi. Bir turizm broşürü patikanın manzarasını vurgularken {kelime:hr086_topografya} haritası yüksekliği, bir güvenlik planıysa tahliye noktalarını gösterebilirdi. Bunların her biri işe yarardı, fakat hiçbirini tek başına bütün gerçek sanmamak gerekiyordu. Çocuklar kendi harita notlarında bu farkı açıkça belirttiler.

Elif, rotanın başlangıç ve bitiş yüksekliğini hesaplamak için dört işlemden çok dikkat gerektiğini fark etti. Sayıları önce ters çıkarınca sonuç negatif görünmüştü. “Yanlış yapınca fark ettim,” dedi. Nihan Öğretmen, hatanın çözümünü yalnız doğru rakamı söylemekte bulmamalarını istedi. Hangi sayıdan hangisinin çıkarıldığını cümleyle anlattılar. Böylece arkadaşlarının da aynı hesabı kontrol edebilmesi mümkün oldu.

Toplantı sonunda {yoldas:yalin|bir arkadaş} telefonundaki yürüyüş uygulamasına baktı. Uygulama, parkurun kolay olduğunu iddia ediyordu. Oysa yorumlardan bazıları onu zor bulmuştu. {kahraman} bunun çelişki değil, farklı deneyimlerin sonucu olabileceğini söyledi. Yürüyen kişinin hazırlığı, ayakkabısı, dinlenme ihtiyacı ve hava koşulları zorluk algısını etkileyebilirdi. Ekranda tek bir “kolay” etiketinin görünmesi herkese kolay olacağını kanıtlamıyordu.
---
@omurga
Ertesi gün kulüp odasında eski bir topoğrafya haritası açıldı. Nihan Öğretmen çocuklara eş yükselti eğrilerini gösterdi. Birbirine yakın çizgiler arazinin daha dik olabileceğini, uzak çizgiler ise daha az eğimli bölümleri anlatıyordu. Ancak bu işaretleri yorumlamak için haritanın ölçeğini ve eğriler arasındaki yükselti farkını bilmek gerekiyordu.

Elif elini kaldırdı. “Yani iki çizginin yakın olması yürümeyi mutlaka zorlaştırır mı?”

“Genellikle dikliğe işaret eder,” dedi öğretmen, “ama yüzeyin kayganlığı, taşlı olması, hava ve yürüyenlerin özellikleri de önemlidir. **Harita bir bilgi kaynağıdır, arazinin tamamı değildir**.”

{yoldas:yalin|bir arkadaş} kırmızı çizgiye yeniden baktı. “O zaman burada yalnız 120 metre yükselme yazması bizi yanıltmış olabilir.”

{kahraman} sayıları kâğıda geçirdi. Rota 1.240 metre yükseklikte başlıyor, 1.500 metreye kadar çıkıyor, sonra 1.360 metreye iniyor, seyir terasına ulaşırken yeniden yükseliyordu. Başlangıçla bitiş arasındaki fark yalnız 120 metre olabilirdi; fakat yol boyunca toplam tırmanış daha fazlaydı.
---
@omurga
“Demek iki ayrı şey var,” dedi Elif. “Net yükseklik farkı ile toplam çıkılan yükseklik.”

{kahraman} önce bunu karıştırdığını fark etti. İkisi aynı rakamı verebilirdi, ama her zaman değil. Bir yol inişli çıkışlıysa başlangıç ve son arasındaki fark küçük olsa bile birçok kez tırmanmak gerekebilirdi.

Çocuklar karton üzerine üç rota için basit yükselti profilleri çizdi. {yoldas:yalin|bir arkadaş} kırmızı yolu temsil eden zikzak çizgiye bakınca kaşlarını kaldırdı. “Kâğıtta kısa olması ayaklarımız için kısa hissettirmeyebilir,” dedi.

Nihan Öğretmen başıyla onayladı. “Bu yüzden planları tek bir sayıya indirgemeyiz. Ayrıca yürüyüşü yürütme sorumluluğu uzman görevlilerde. Sizin fark ettiğiniz uyuşmazlığı ilgili birime bildiririz.”

Rota bilgisinin hazırlanmış olduğu belediyenin açık doğa haritaları sayfasından iletişim adresi bulundu. {kahraman} gözlemlerini yazdı: başlangıç ve bitiş yükseklikleri, ara zirve işareti, “toplam yükselme” etiketinin belirsizliği. Hiçbir kişiyi suçlamadı; yalnız doğrulanabilir bir tutarsızlık bildirdi.
---
@omurga
Gezinin önceki akşamı Nihan Öğretmen, öğrencilerden rotayı neden seçtiklerini kendi sözleriyle açıklamalarını istemişti. {kahraman} “Yeşil rota daha uzun ama daha dengeli eğimli ve görevli tarafından uygun bulunmuş,” dedi. {yoldas:yalin|bir arkadaş} “Kırmızı rotanın açıklamasında net yükselti farkıyla toplam tırmanış karışmış olabilir,” diye ekledi. Elif ise grubun ihtiyaçlarını hatırlattı: “Daha kısa bir rota her zaman daha güvenli sayılmaz. Üstelik herkes aynı hızda yürümeyecek.” Öğretmen onların yalnız bilgi değil, birlikte karar vermenin gerekçelerini de öğrendiğini gördü.

Sabah servis hareket ederken {yoldas:yalin|bir arkadaş} otobüsün penceresinden dağın yamacına baktı. Uzaktan sanki düz bir çizgi hâlinde yükselen arazi, yaklaştıkça vadiler ve küçük sırtlar şeklinde ayrılıyordu. “Haritada her şey daha sade görünüyor,” dedi. {kahraman}, haritanın görevinin ayrıntıları bir düzene sokmak olduğunu, yoksa her taşı göstermek olmadığını söyledi. Elif bir çocuğun ilk kez okuyacağı harita için fazla ayrıntının kafa karıştırıcı olabileceğini düşündü. İyi bir açıklama hem doğru hem anlaşılır olmalıydı.
---
@omurga
Yürüyüşün başında Melek Hanım çocukların karşısında durup birkaç örnek işaret gösterdi. Sarı yön levhası ana patikayı gösteriyor, kırmızı uyarı levhası ise girilmeyecek bölgeyi belirtiyordu. {yoldas:yalin|bir arkadaş}, haritadaki renklerle sahadaki levha renklerinin aynı anlamı taşımayabileceğini fark etti. “Demek işaretin anlamını bulunduğu sistemde öğrenmek gerekiyor,” dedi. Melek Hanım onu onayladı. “İşaretlere bakmak güzel. Ama hangi kurumun hangi işareti kullandığını bilmek daha önemli.”

{kahraman} bu cümleyi not aldı. Aynı renk bazen iki ayrı çizelgede farklı şey anlatabiliyordu; bu nedenle işaret açıklamalarını atlamamak gerekiyordu. Gezide ilk öğrendiği şey yürümek değil, gördüğü sembolü aceleyle yorumlamamaktı.

{kahraman} dağ gezisine hazırlanırken büyükannesinin anlattığı bir anıyı hatırladı. Yıllar önce kasabaya yeni yol yapılmadan önce insanlar pazara ulaşmak için dağın çevresini dolanırmış. “Şimdi bir tünelden geçiyoruz, ama o zaman herkes patikayı bilirdi,” demişti büyükannesi. {kahraman} bunu dinlerken eski yolların yalnız mesafe hesaplarından oluşmadığını düşünmüştü. Bir yol, insanların alışkanlıklarını ve günlük hayatlarını da etkilerdi. Geziye çıkmadan önce büyükannesine eski yolun neden bırakıldığını sordu. “Kışın geçmek güçleşirdi,” dedi büyükannesi. “Yeni yol daha güvenliydi.”
---
@omurga
{kahraman} bu bilgiyi sınıfa getirdiğinde öğretmenleri onu dikkatle dinledi. Sonra anının değerli olduğunu, ancak hangi tarihlerde hangi yolun kullanıldığını doğrulamak için yerel kayıtların da incelenebileceğini söyledi. {kahraman} bunu yadırgamadı. Büyükannesine güveniyor, yine de bir anının herkes için aynı ayrıntılarla hatırlanmayabileceğini biliyordu. Böylece sözlü tarih ile haritayı birbirine rakip değil, farklı sorulara cevap veren kaynaklar olarak görmeye başladı.

{yoldas:yalin|bir arkadaş}, {kahraman:ilgi} anlattığından yola çıkarak “Belki bizim kırmızı rotamız da eskiden kullanılıyordu,” dedi. Elif, bunun yalnız bir ihtimal olduğunu hatırlattı. Melek Hanım'ın onaylamadığı bir patikaya gitmek için eski bir söylenti yeterli değildi. {kahraman} haritadaki kırmızı çizginin yanına not düştü: “Tarihî kullanım olasılığı araştırılabilir; güncel yürüyüş rotası olarak önerilmez.” Öğrendikleri şey yalnız geçmişi anlatmak değil, geçmiş bilgisinin bugünkü karara nasıl ve ne kadar katılacağını ölçmekti.
---
@omurga
Geziden bir gün önce hava koşulları yeniden kontrol edildi. Rehberleri, resmi yeşil rotanın uygun olduğunu onayladı. Nihan Öğretmen her öğrencinin su, uygun ayakkabı ve hava durumuna göre kıyafet hazırladığından emin oldu. {kahraman}, uzun süredir yürüyüş yapmayan arkadaşlarının da geleceğini biliyordu. Herkesin aynı tempoda yürümesi gerekmeyebilirdi, ama kimse geride bırakılmamalıydı.

Sabah köy meydanında toplandıklarında {yoldas:yalin|bir arkadaş} neşeliydi. “Bakın,” dedi, “uzun yol da macera sayılıyor.”

Elif sırt çantasını düzeltti. “Kısa olduğuna inanıp yanlış yola girmekten iyidir.”

Rehberleri Melek Hanım, rotanın başında kısa bir bilgilendirme yaptı. Patikadan ayrılmayacaklar, yaban hayvanlarına yaklaşmayacaklar, bitki örneği toplamayacaklar, fotoğrafları işaretli dinlenme yerlerinde çekeceklerdi. Yürüyüş temposunu en hızlı kişi değil, grubun birlikte ilerleyebilmesi belirleyecekti.

İlk yarım saat boyunca yol açık renk taşların arasından kıvrıldı. {kahraman}, haritadaki mavi dere işaretiyle gerçek derenin yerini karşılaştırdı. Derede su azdı ama taşların üzerinde nemli izler görülüyordu. Rehber bu işaretlerin mevsime göre değişebileceğini söyledi. Haritada işaretlenen akarsu yatağı, her gün aynı miktarda su taşımak zorunda değildi.
---
@omurga
{yoldas:yalin|bir arkadaş} patikaya paralel uzanan dik yamaca bakıp “Kırmızı rota galiba buradan gidiyor,” dedi. Melek Hanım onun işaret ettiği tarafın işaretli gezi yoluna ait olmadığını açıkladı. “Oraya yaklaşmayacağız. Haritadaki tartışmamız bizi tehlikeli bir karşılaştırmaya sürüklemesin.”

{kahraman} haritasını çantasına koydu. Her çizgi gerçek bir karar gerektiriyordu; ama çizgileri çözmek için oraya yürümek gerekmiyordu.

Rehber grup için bir mola verdiğinde Elif küçük bir matematik oyunu önerdi. Önlerindeki tepeye çıkan iki hayalî yol çizdi: Biri bir kilometrede yüz metre yükseliyor, öteki iki kilometrede aynı yüksekliğe çıkıyordu. “Hangisinin ortalama eğimi daha az?” diye sordu. {yoldas:yalin|bir arkadaş} ikinci yolu işaret etti. {kahraman}, bunun yalnız basitleştirilmiş bir örnek olduğunu belirtti. Gerçek patikalar boyunca eğim sürekli değişebilirdi. Ancak örnek, bir yükselti farkının tek başına yolun nasıl hissedileceğini anlatmadığını göstermeye yetiyordu.

Melek Hanım konuşmalarını dinleyince onları patika kenarında duran bilgilendirme panosuna götürdü. Panoda bitki örtüsüyle ilgili kısa notlar vardı. Öğrencilerden biri çiçekleri görmek için iki adım aşağı inmeyi teklif etti. Rehber buna izin vermedi; alan koruma altındaydı ve işaretli yolun dışına çıkılmamalıydı. {kahraman} uzaktan fotoğraf çekti. Bir gözlemi doğru yapmak için her şeyi eline almanın gerekmediğini artık biliyordu.
---
@omurga
Mola sonunda {yoldas:yalin|bir arkadaş} çantasındaki suyu Elif'le paylaşmak istedi. Elif kendi suyunun yeterli olduğunu, fakat yürüyüş temposunu biraz yavaşlatmak istediğini söyledi. {yoldas:yalin|bir arkadaş} yardım etmeyi yalnız bir şey vermek sanmıştı; bazen birinin ihtiyacını dinlemek daha önemliydi. {kahraman} bu konuşmaya karışmadı. Arkadaşlarının birbirinin isteğini sormasını izlerken rota planlamanın haritadaki çizgiden çok daha fazla şey içerdiğini düşündü.

Yürüyüş sürerken grup küçük bir köprüden geçti. Dere yatağı kurak görünüyordu, fakat köprü yaklaşımındaki taşlar nemliydi. Melek Hanım durup geçiş sırasını düzenledi. Çocuklar güvenlik talimatlarına uygun biçimde sırayla yürüdü. {kahraman} bir kez daha haritaya bakıp “köprü” işaretini buldu. İşaret oradaydı; ama taşların o sabah nasıl görüneceğini hiçbir çizgi anlatmıyordu.
---
@omurga
Yürüyüşün ortasında grup dinlenme noktasına ulaştı. Elif'in ayakkabı bağı gevşemişti; arkadaşlarından durmalarını istedi. {yoldas:yalin|bir arkadaş} ilk başta yolun yavaşlamasına üzüldü, sonra düşüncesini değiştirdi. Yürüyüşte herkesin farklı ihtiyacı olabilirdi. Bir kişi için kolay olan taşlı bölüm, başka biri için zor olabilirdi.

Melek Hanım bir taşın üzerindeki yosunu gösterdi. “Yükseklik profiline bakarken buradaki nemi göremezsiniz,” dedi. “Bu yüzden yalnız eğim hesabı güvenlik planı değildir.” Çocuklar yosuna dokunmadan gözlem yaptı. Güneş ışığı taşların bir tarafına vuruyor, gölgede kalan yüzey daha nemli görünüyordu.

{kahraman} defterine “harita = model, arazi = gözlenen yer” yazdı. Sonra yanına bir soru ekledi: Model bize neyi gösteriyor, neyi göstermiyor? Bu soru son günlerde zihninden çıkmıyordu. İnternette gördüğü bir grafik, bir sayının yanında bulunmadığı için gerçeği değiştirmiyordu; ancak okuyucunun gerçeği anlama biçimini değiştirebiliyordu.

Yeşil rota, ormanın kenarında açık bir çayıra çıktı. Burada farklı bitki türleri vardı. Nihan Öğretmen çocuklardan bitki isimlerini bilmeden etiket uydurmamalarını istedi. {kahraman} küçük sarı çiçekleri fotoğrafladı, gördüğü yerin özelliklerini yazdı. Adını bilmediği bir çiçeğe hemen isim vermek yerine uzmana sorabilecekti.
---
@omurga
Seyir terasına vardıklarında manzara genişledi. Dağın karşı yamacında gölgeli bir vadi uzanıyordu. {yoldas:yalin|bir arkadaş}, kırmızı rotanın geçtiği bölgeyi uzaktan seçmeye çalıştı. “Şimdi daha açık görüyorum,” dedi, “ama buradan bakmak bile her ayrıntıyı göstermiyor.”

Elif gülümsedi. “O yüzden haritalarla, gözlemlerle ve uzman bilgisiyle birlikte çalışıyoruz.”

Seyir terasında çekilen fotoğraflar okulda gösterildiğinde başka bir öğrenci, dağdaki taşların rengini yanlış yorumladı. Uzaktaki açık tonların kar olduğunu düşündü. Elif, fotoğrafın sıcak bir eylül sabahı çekildiğini hatırlattı. “Beyaz görünmesi kar olduğu anlamına gelmez,” dedi. Nihan Öğretmen, ışığın ve kamera ayarlarının renkleri değiştirebileceğini anlattı. {kahraman}, fotoğraf altına “Açık renkli kaya” yazdı. Doğru açıklama bazen heyecanlı tahminden daha sade oluyordu.

Bir sonraki ders coğrafya öğretmeni çocuklara harita ölçeğiyle ilgili basit bir karşılaştırma yaptırdı. Aynı yol, küçük ölçekli haritada kısa bir çizgi, ayrıntılı haritada çok sayıda kıvrım olarak görünüyordu. {yoldas:yalin|bir arkadaş} artık “Bu çizgi kısa” demeden önce kâğıdın ölçeğini soruyordu. Elif bunun yalnız haritalarda değil, haber grafiklerinde de işe yarayabileceğini söyledi. Bir görseli okurken kullanılan ölçek ve işaretlerin anlamını bilmek şarttı.
---
@omurga
{kahraman} belediyeye gönderdikleri e-postanın kopyasını sınıfa gösterdi. İlk taslaklarında “Haritanız yanlış” yazmıştı. Son taslakta ise hangi satırın hangi veriyle uyuşmadığını gösteren somut bir açıklama vardı. Öğretmen, eleştirinin kişiler üzerinden değil, doğrulanabilir bilgi üzerinden kurulmasını değerli buldu. {yoldas:yalin|bir arkadaş}, doğruyu bulmanın yanı sıra onu nasıl söylediğinin de önemli olduğunu fark etti.

O akşam belediyeden gelen teşekkür mesajını Elif ailesine okudu. Mesajda “Gözlemleriniz verinin anlaşılır sunulmasına katkı sağladı” yazıyordu. Elif, bir dağa gerçekten çıkmadan, yalnız kaynakları dikkatle okuyarak da yararlı olunabileceğini düşündü. Üstelik amaç birini mahcup etmek değil, başkalarının da hataya düşmesini önlemekti.

Gezinin sonuna doğru bir öğrenci yürüyüş sırasında nefes nefese kaldığını söyleyince rehber tempoyu yeniden ayarladı. Çocuk kendisini arkadaşlarının yavaşlamasına neden olmuş gibi hissediyordu. {kahraman}, “Sen söylemeseydin belki başka biri de zorlandığını saklayacaktı,” dedi. Elif, bir grupta en yavaş görünen kişiyi suçlamak yerine yürüyüş planının herkes için uygun olup olmadığını düşünmeleri gerektiğini söyledi. Rehber uygun mola noktasında bekletti; gerekirse planı değiştireceklerini açıkladı.
---
@omurga
Bu olay {yoldas:ilgi|bir arkadaşın} zihninde eski bir düşünceyi yıktı. O, “En iyi rota” sözünü sanki bütün insanlar için geçerli tek bir cevap gibi kullanmıştı. Oysa aynı yolda farklı insanları düşünmek gerekiyordu. Kısa yol, hızlı kişi için çekici olabilir, fakat gruptaki herkes için uygun olmayabilirdi. Doğru plan, hedefi ve katılımcıların durumunu birlikte değerlendirmeliydi.

Otobüse döndüklerinde öğrenciler kendi gözlem formlarını doldurdu. {yoldas:yalin|bir arkadaş} “Yürüyüş zor muydu?” sorusuna bir puan vermek yerine neden öyle düşündüğünü yazdı: bazı bölümlerde kolay, bazı taşlı alanlarda dikkat gerektiriyordu. {kahraman} formdaki bir başka soruya, “Haritayla arazide hangi farkı gördün?” cevabını verdi. Harita ölçülecek ilişkileri gösteriyor, deneyim ise zeminin o günkü durumunu ortaya koyuyordu. Elif, “Daha iyi plan için ne gerekirdi?” sorusuna, “Herkesin ihtiyaçlarını önceden daha dikkatli dinlemek,” yazdı.
---
@omurga
Geziden iki gün sonra belediyeden cevap geldi. Haritadaki “toplam yükselme” alanı otomatik olarak başlangıç ve bitiş yüksekliği farkını göstermiş, fakat açıklamasında bu fark belirtilmemişti. İlgili birim etiketin düzeltilmesi için işlem başlatmıştı. {kahraman}, cevabı okuyunca sevinçle {yoldas:yonelme|bir arkadaşa} seslendi.

“Bak! Yaptığımız gözlem işe yaramış.”

{yoldas:yalin|bir arkadaş} önce sessiz kaldı. “Ben de kısa yolu seçmek için acele etmiştim,” dedi. “İyi ki Elif sayıların uyuşmadığını fark etti.”

Elif bilgisayarın önüne geldi. “Hepimiz farklı yere baktık,” dedi. “Sen kısa süreyi, {kahraman} çizgileri, ben yükseklikleri düşündüm. Bir araya getirince tutarsızlığı gördük.”

Nihan Öğretmen, belediyeden gelen yanıtı sınıf panosuna asabileceklerini söyledi. Ancak yazışmada yer alan kişisel iletişim bilgilerinin paylaşılmamasına dikkat edildi. Çocuklar yalnız hata açıklamasını ve düzeltilen örnek grafiği kullandı.

Pano başlığı konusunda tartıştılar. {yoldas:yalin|bir arkadaş} “Yanlış Haritayı Çözen Takım” yazmak istedi. {kahraman} bu başlığın hem kendilerini fazla öne çıkardığını hem de haritanın tümünün yanlış olduğu izlenimi verdiğini düşündü. Elif daha uygun bir öneri getirdi: Bir Etiket, İki Farklı Yükseklik. Başlığın altına “Net yükselti farkı” ve “Toplam tırmanış” kavramlarını kısa örneklerle yerleştirdiler.
---
@omurga
Sunum sırasında bir öğrenci, “Haritadaki her sayıya şüpheyle mi bakmalıyız?” diye sordu. {kahraman} cevap vermeden önce düşündü. “Her sayıyı yanlış saymak da doğru olmaz,” dedi. “Ne ölçtüğünü anlamalıyız. Eğer birbiriyle uyuşmayan bilgi varsa doğrulamalıyız.”

Melek Hanım daha sonra okula gelip panoyu gördü. “Böyle bir çalışma hem meraklı hem de sorumlu olmayı gösteriyor,” dedi. {kahraman:ilgi} aklına gezinin ilk sabahı geldi. Başta tek amacı en iyi rotayı bulmaktı. Şimdi bir harita bilgisinin nasıl okunduğuyla da ilgileniyordu.

Sunumdan önce çocuklar birbirlerinin notlarını kontrol etti. {yoldas:yalin|bir arkadaş}, {kahraman:ilgi} çizdiği yükselti profilinde başlangıç noktasının eksen sıfırı gibi göründüğünü fark etti. {kahraman} grafiği düzeltti. Eğer yükseklik ekseninin başlangıcını açıkça belirtmezlerse izleyiciler tırmanışın olduğundan fazla olduğunu sanabilirdi. Elif bu ayrıntıyı görünce “Bir grafiği doğru okumak için onun neyi göstermek istediğini bilmek yetmez, nasıl çizildiğini de görmeliyiz,” dedi.

Günün sonunda hazırladıkları üç boyutlu karton model sergiye kondu. Modelin bir yanı dik, öteki yanı daha geniş bir kıvrımla yükseliyordu. Çocuklar aynı noktaya farklı yönlerden gidilebileceğini görüyordu. {yoldas:yalin|bir arkadaş} ziyaretçilere “Kısa olan her zaman kolay değildir,” diye anlattı. Bir öğrenci karton dağa dokunup “Gerçek dağ böyle sert mi?” diye sordu. {kahraman}, modelin büyütülmüş yükseltiler içerdiğini açıkladı. “Bunu arazi yerine koymayın,” dedi. “Bununla bazı ilişkileri anlamayı deneyin.”
---
@omurga
Melek Hanım ziyaretçilere rehberli yürüyüşlerin neden belirlenmiş rotalardan yapıldığını anlattı. Güvenlik yalnız patikanın eğimine değil, bakım durumuna, mevsime ve katılımcıların ihtiyaçlarına bağlıydı. Elif, bir modelin en iyi hâlinin bile gerçek hayattaki kararın yerini tutamayacağını o anda bir kez daha anladı.
---
@omurga
Sonbaharda dağa kar yağdığında, okul koridorundaki pano hâlâ duvardaydı. Bu kez dağa yeni bir gezi planlanmıyordu. {kahraman} fotoğraflara bakarken karlı görüntünün yürüyüş koşullarını nasıl değiştirebileceğini düşündü. Aynı yükseklik ve eğim çizgileri duruyordu; ama zeminin kayganlığı, görünürlük ve hava bambaşkaydı.

{yoldas:yalin|bir arkadaş} elinde yeni bir broşürle geldi. “Belediye haritanın etiketini düzeltmiş,” dedi. “Bak, artık iki değeri ayrı yazıyorlar.”

{kahraman} kâğıdı aldı. Küçücük iki sözcük eklenmişti: Net fark. Altına Toplam tırmanış için yeni bir satır açılmıştı. {kahraman} bu iki sözcüğün birilerini yanlış beklentiye girmekten koruyabileceğini düşündü.

Elif yanlarına geldiğinde {kahraman} ona broşürü gösterdi. “İlk soruyu sen sordun,” dedi. “Sen olmasaydın ikimiz de en kısa rotanın en kolay rota olduğunu sanabilirdik.”

Elif başını salladı. “Ben de harita ölçeğine bakmadan konuşacaktım. Neyse ki birlikte kontrol ettik.”

Üçü pencere kenarında dağın uzaktan görünen karla kaplı tepesine baktı. Dağın adı yine sabah ışığında parlıyordu. {kahraman} artık Güneş Dağı'nı yalnız bir manzara olarak görmüyordu. Ona göre dağ, bir sorunun nasıl doğru sorulacağını gösteren büyük bir haritaydı. Bütün çizgileri çözmek gerekmiyordu; önce ne anlama geldiklerini öğrenmek gerekiyordu.
---
@omurga
Dağın karşı yamacına kar yağmaya başladığında {yoldas:yalin|bir arkadaş} yeniden en kısa yolu sormadı. Bunun yerine ertesi bahar yapılabilecek gözlem çalışmasının hangi kaynaklardan planlanacağını merak etti. {kahraman} ona topoğrafya haritasını, güncel uyarıları ve rehberin verdiği güzergâh açıklamasını gösterdi. “Birlikte bakacağız,” dedi. Elif ekledi: “Ve önce herkesin ihtiyacını dinleyeceğiz.”

Bu kez yolculuk için acele etmiyorlardı. Bir gün yeniden Güneş Dağı'nı görebilirlerdi; belki aynı seyir terasından farklı bir manzaraya bakacaklardı.[[deyim:hr086_gozler]] Bir haritadaki küçük yanlış işaret, onların düşünme biçiminde kalıcı bir düzeltmeye dönüşmüştü.

Bahar geldiğinde okula başka bir sınıftan üç öğrenci ziyarete geldi. Kütüphanelerindeki harita etkinliği için yükselti profili hazırlamak istiyorlardı. {kahraman} onlara doğrudan hazır cevabı vermedi; önce bir çizgiyi nasıl okuyacaklarını gösterdi. {yoldas:yalin|bir arkadaş} ise örnek bir rota için başlangıç ve bitiş yüksekliklerini hesaplatıp sonra aradaki iniş çıkışları eklemelerini istedi. Öğrenciler iki sonucun neden farklı olabildiğini kendi çizimleri üzerinde gördü. Elif, anlatımın sonuna küçük bir soruyla katıldı: “Peki yürüyüşe karar vermek için bunlar yeterli mi?”
---
@omurga
Ziyaretçiler durup düşündü. Biri hava koşullarını, diğeri zemini, üçüncüsü de insanların hazırlığını saydı. {kahraman} gülümsedi. Bir zamanlar kendisi de yalnız çizgilere bakıyordu. Şimdi soruyu başka çocukların doğru yerden sormasını sağlayabiliyordu. Güneş Dağı uzakta yine ışıldıyordu; ama onların elindeki harita, bir yarışın başlangıç çizgisi değil, daha dikkatli düşünmenin aracıydı.

Bir sonraki dönem {kahraman}, okulun yeni doğa kulübü üyelerine küçük bir uygulama yaptırdı. Bir kâğıda düz çizgi, diğerine kıvrımlı bir rota çizdi. İki çizginin de uçlarına aynı başlangıç ve bitiş yüksekliklerini yazdı. “Hangisi daha çok tırmanış gerektirir?” diye sordu. Bazı öğrenciler ikisinin de eşit olduğunu düşündü. {kahraman} onlardan ara noktaların yüksekliklerini hayal edip çizimlerine eklemelerini istedi. Çizgiler birden değişti. Bir yolda çıkış hiç durmazken diğerinde iki iniş, üç çıkış vardı. Çocuklar toplam tırmanışın neden ayrı bir değer olduğunu kendileri buldu.

{yoldas:yalin|bir arkadaş} uygulamanın ikinci kısmında soruları değiştirdi. “Peki hangisi daha güvenli?” dedi. Öğrenciler hemen cevap veremedi. Biri zemini, biri hava koşullarını, biri yolun bakımını sordu. Elif bu sorulara yürüyüşe katılacak kişilerin ihtiyaçlarını ekledi. Böylece cevap bir rakama bağlı kalmaktan çıktı. Güneş Dağı'nda yaşadıkları günün en önemli öğretisi artık bir sınıf oyununa dönüşmüştü.
---
@omurga
Uygulama bitince küçük bir çocuk, “Dağa hiç gitmeden bunu öğrenebilir miyiz?” diye sordu. {kahraman} gülümsedi. “Bir kısmını evet,” dedi. “Gidilecekse de güvenli, planlı ve yetkili kişilerle gidilir.” {yoldas:yalin|bir arkadaş} haritaları toplarken “Önce bilgi, sonra karar,” yazan kartı kapının yanına astı. {kahraman} o kartın yalnız dağlar için geçerli olmadığını düşünüyordu. İnternetteki bir bilgiyle, arkadaşından duyduğu bir iddiayla veya kendi ilk tahminiyle karşılaştığında da aynı soruyu sorabilirdi: Bu bilgi bana tam olarak ne söylüyor?

{kahraman} yaz tatilinde bir gün otobüsle Güneş Dağı'nın yakınından geçti. Yol, eski haritada göründüğünden daha genişti ve yeni kavşaklar yapılmıştı. Pencereden baktığında ilk gezilerindeki seyir terasını seçebildi. O gün oraya vardığında ne kadar yorulduklarını hatırladı, ama daha çok dinlenme noktasında öğrendiklerini düşündü. Haritaya yanlış bir etiket koyulduğu için insanlar birbirini suçlayabilirdi. Onlar bunun yerine açıklama istemiş, gelen cevabı da paylaşmıştı.
---
@omurga
Yan koltuktaki küçük kardeşi Deniz, dağın tepesini göstererek “Oraya en kısa yol hangisi?” diye sordu. {kahraman} hemen cevap vermedi. “Nereye gitmek istediğimize bağlı,” dedi. “Bir de hava nasıl, yolun durumu ne, kimler geliyor? Önce bunları düşünmek lazım.” Deniz şaşırmıştı. Ona göre en kısa çizgi doğru cevaptı. {kahraman} defterinden eski bir yükselti profili çıkarıp gösterdi. Kardeşi iki eğriyi incelerken “Aaa, burada aşağı inip yeniden çıkıyor,” dedi. {kahraman} gülümsedi. Öğrendiklerini başkasına anlatırken kendisi de daha iyi anlıyordu.

Otobüs dağı geride bırakırken {kahraman} defteri kapattı. Düşünceleri bir süre çizgiler arasında dolaştı. Büyüklere sık sık yön sorduğunda bazen tek kelimelik cevap beklerdi. Oysa iyi bir yön tarifi, doğru hedefe güvenle ulaşma ihtimalini artırmalıydı. Bir haritanın doğruluğu yalnız rakamlarda değil, o rakamların ne anlama geldiğini açıklayan sözcüklerde de saklıydı. Bu yüzden harita okurken soracağı ilk soru artık şuydu: “Bu sayı tam olarak hangi yolculuğu anlatıyor?”
---
@omurga
Sınıftan başka bir öğrenci, panoyu inceledikten sonra {kahraman:yonelme} yürüyüş sırasında neden en tepeye çıkmadıklarını sordu. {kahraman} bir an durdu. “Çünkü amacımız zirve değildi,” dedi. “Bitki örtüsünü ve yer şekillerini gözlemlemekti. Daha yükseğe çıkmak her zaman daha çok şey öğrenmek demek değildir.” Bu cevap {yoldas:ilgi|bir arkadaşın} hoşuna gitti. Başta dağın yüksekliğini bir başarı yarışı gibi düşündüğünü hatırladı. Oysa orman sınırındaki küçük seyir terasında gördükleri, bütün sorularını değiştirmişti. Elif, planın başarısını hedefe uygunlukla ölçmenin de bir beceri olduğunu ekledi.

{kahraman}, sorunun cevabını verdiğinde artık tek bir doğru rakam aramıyordu. Haritadaki veriyi okuyup yorumunu sınayabiliyor, gerekli durumlarda uzmanlara başvurabiliyordu.

Bu karar onların haritalara bakışını da arkadaşlıklarına bakışını da değiştirmişti. Artık en hızlı ilerlemeyi değil, birlikte doğru yere ulaşmayı önemsiyorlardı.

{kahraman} yeni haritayı çantasına koymadan önce eğim çizgilerinin yanına küçük bir not ekledi. Bu çizgilerin kâğıt üzerinde sessizce durmasına rağmen gerçekte insanların nefesini, adımlarını ve güvenliğini etkileyebileceğini düşünüyordu. Elif, notu okuyunca “Bir çizginin sorumluluğu varmış,” dedi. {kahraman} başını salladı. “Çizgiyi çizenin de,” diye cevap verdi. İkisi bu sözü unutmak istemedi.
---
@omurga
Hep birlikte daha dikkatli düşünmeyi öğrenmişlerdi.
