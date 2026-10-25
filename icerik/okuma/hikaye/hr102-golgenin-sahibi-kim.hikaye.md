---
baslik: "Gölgenin Sahibi Kim?"
slug: "hr102-golgenin-sahibi-kim"
fis_kodu: "HR-102"
tur: gizem
konu: iddia_kanit_medya
sinif_alt: 8
sinif_ust: 8
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Meydanda beliren bir gölge bir bekçinin ruhu mu, yoksa ışığın oyunu mu? Nil ve Kaan, korkuyu ve iddiayı kanıttan ayırmayı öğrenir."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 8
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [kesif]
  ders_baglantisi: [turkce, fen]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: iddia_hr102, tur: lexeme, etiket: "iddia", yuva: hr102_iddia, islev: first_hint}
    - {id: kanit_hr102, tur: lexeme, etiket: "kanıt", yuva: hr102_kanit, islev: application}
    - {id: belirsiz_hr102, tur: lexeme, etiket: "belirsiz", yuva: hr102_belirsiz, islev: application}
    - {id: guvenilir_hr102, tur: lexeme, etiket: "güvenilir", yuva: hr102_guvenilir, islev: transfer}
    - {id: deyim_hr102, tur: idiom, etiket: "Hayal kırıklığına uğramak", yuva: hr102_hayal, islev: application}
    - {id: kavram_hr102, tur: concept, etiket: "Gözlem ile yorumu ayırmak", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (8. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "İlk gölge hangi gece görülmüştü?", secenekler: [{id: A, metin: "Pazar sabahı"}, {id: B, metin: "Cuma öğleden sonra"}, {id: C, metin: "Salı akşamı"}, {id: D, metin: "Perşembe gecesi"}], dogru: D, aciklama: "Metinde ilk gölge perşembe gecesi duvarda belirmişti."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 11, metin: "Nil'e göre iki olayın aynı saatte gerçekleşmesi ne anlama gelir?", secenekler: [{id: A, metin: "Olaylar arasında kesin bir neden-sonuç ilişkisi vardır"}, {id: B, metin: "Gölge gerçekten bir insandır"}, {id: C, metin: "Olaylar tesadüfen de aynı saatte olabilir ve bu tek başına neden değildir"}, {id: D, metin: "Işıklar bozuk olduğunda gölge görünür"}], dogru: C, aciklama: "Nil, aynı saatte olmanın neden-sonuç ilişkisini tek başına kanıtlamadığını söyler."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 36, metin: "Bu metne göre hayal kurmak ile sorun arasındaki fark nedir?", secenekler: [{id: A, metin: "Hayal kurmak her zaman yanlıştır"}, {id: B, metin: "Hayal kurmak ile kanıt aynı şeydir"}, {id: C, metin: "Hayal kurmanın hiçbir değeri yoktur"}, {id: D, metin: "Hayal kurmak tek başına sorun değildir; sorun hayali kanıt gibi sunmaktır"}], dogru: D, aciklama: "Masal ve hayal kurmak sorun değildir; hayal ürününü kanıt gibi sunmak sorundur."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 10, metin: "Metinde “korkuyu kanıt yerine koymak” ne anlatır?", secenekler: [{id: A, metin: "Korkunun, kanıtın yerine geçirilmesi"}, {id: B, metin: "Kanıtların korkutucu olması"}, {id: C, metin: "Korkmadan önce kanıt toplamak"}, {id: D, metin: "Kanıtların hepsini yok etmek"}], dogru: A, aciklama: "Duygu, yani korku, kanıtın yerine konduğunda araştırma yanıltıcı sonuçlara götürebilir."}
  - {id: s5, beceri: degerlendirme, dayanak_sayfa: 25, metin: "Sunumun son slaydındaki cümle neyi vurgular?", secenekler: [{id: A, metin: "İlgi çeken her iddia doğrudur"}, {id: B, metin: "Kanıta gerek yoktur"}, {id: C, metin: "İlgi çekici bir iddia, doğru olduğu anlamına gelmez"}, {id: D, metin: "Gölgeler hakkında konuşmak yasaktır"}], dogru: C, aciklama: "Son slayt, ilgi çekici bir iddianın doğrulanması için kanıt gerektiğini söyler."}
deyim_cumleleri:
  hr102_hayal: "{yoldas:yalin|bir arkadaş} biraz hayal kırıklığına uğradı."
---
@omurga
Kent meydanının taş duvarında ilk gölge perşembe gecesi belirdi. Bir insan siluetine benziyordu ama boyu normal bir insanın neredeyse iki katıydı. Kollarından biri uzun, başı hafif yana dönüktü. Duvarın üstündeki saat on bire yaklaşırken görüntü birden kayboldu. O an meydandan geçen biri telefonuyla birkaç saniyelik video çekmişti. Video sabaha karşı binlerce kez izlendi.

Sekizinci sınıf öğrencisi {kahraman}, videoyu kahvaltıda gördü. Altında “Kayıp nöbetçinin gölgesi geri döndü” yazıyordu. Kentte yıllar önce meydanı koruduğu söylenen bir bekçi hakkında hikâyeler anlatılırdı. Kimisi onun yağmurlu gecelerde ortaya çıktığını, kimisi de gölgenin yalnızca yeni ayda görüldüğünü {kelime:hr102_iddia} ediyordu. {kahraman} ilk anda ürperdi; sonra videoyu yavaşlattı. Siluetin alt kısmı, yerdeki taşlarla aynı yönde uzanıyordu. Ama görüntünün nereden geldiği belli değildi.

Arkadaşı {yoldas:yalin|bir arkadaş} aradı. “Bu akşam gidiyoruz,” dedi. “Gölgeyi kendi gözümüzle görelim.” {kahraman} hemen kabul etmedi. Meydan gece geç saatte boşalıyordu ve tek başlarına gitmeleri doğru değildi. Babasıyla konuştu, okulun bilim kulübü öğretmeniyle birlikte akşam erken saatlerde izinli gözlem yapabileceklerini öğrendi.[[deyim:hr102_hayal]] “Gizemlerin hepsi güvenlik formuna mı bağlanacak?” diye şakalaştı. {kahraman}, “Gizem çözmekle kendimizi riske atmak aynı şey değil,” dedi.
---
@omurga
Ertesi gün okulda gölge hakkında konuşmayan kalmamıştı. Bir grup öğrenci fotoğraflara kırmızı daireler çiziyor, görüntüde olmayan yüzler görüyordu. {kahraman}, kırmızı daire çizilen yerde yalnızca iki çatlak taşı seçebiliyordu. “Bir şeyi aradığında benzer şekilleri her yerde görebilirsin,” dedi. {yoldas:yalin|bir arkadaş} telefonunu kapattı. “Öyleyse önce neyi gerçekten gördüğümüzü yazalım.”
---
@omurga
Bilim kulübü öğretmeni Leyla Hanım çocuklara basit bir düzenek gösterdi: beyaz perde, küçük oyuncak figür ve ışık kaynağı. Figür ışığa yakın durduğunda perde üzerindeki gölgesi büyüyordu. Işık başka bir yöne kaydırıldığında gölgenin boyu ve yeri değişiyordu. Leyla Hanım, “Bu yalnızca temel bir model,” dedi. “Meydandaki görüntünün nedeni olduğunu kanıtlamaz. Ama hangi değişkenlere bakacağımızı gösterebilir.”

{kahraman} defterine sorular yazdı: Gölgede ışık kaynağı var mıydı? Kaynağın yüksekliği neydi? Duvarın açısı ne kadar etkiliydi? Gölgenin kaybolduğu anda hangi ışıklar sönmüştü? {yoldas:yalin|bir arkadaş} videodaki sesleri dinledi; arka planda bir araç geçiyor, sonra uzaktan müzik sesi duyuluyordu. Hiçbiri tek başına belirleyici değildi.

Akşam öğretmen ve velilerinden biriyle meydana gittiler. Henüz karanlık çökmemişti. Belediyenin aydınlatma direkleri, bir kafeden gelen küçük ışıklar ve karşı binadaki reklam ekranı duvara farklı yönlerden bakıyordu. {kahraman} duvarın önünde durup kendi gölgesini gözledi. Işık açısına göre uzuyor, kısalıyor, bazen iki ayrı gölgeye ayrılıyordu.
---
@omurga
{yoldas:yalin|bir arkadaş} videonun çekildiği noktayı tahmin edip fotoğraf çekti. {kahraman} aynı görüntüyü elde edemediklerini söyledi. “Çünkü saat farklı, ışıklar farklı, belki de kamera konumu farklı,” dedi. Leyla Hanım her denemede tek bir değişkeni değiştirmelerini önerdi. Böylece hangi etkinin nereden geldiğini anlamaları kolaylaşacaktı.

Meydanın kenarındaki fırından çıkan Hasan Bey yanlarına yaklaştı. “Gölgeyi mi arıyorsunuz?” diye sordu. “Ben de gördüm sandım ama sonra bir şey olmadı.” {kahraman} ne gördüğünü sordu. Hasan Bey, “Yandaki binanın önünden biri geçiyordu, duvarda kocaman göründü,” dedi. {yoldas:yalin|bir arkadaş} heyecanlandı. “Demek insan!” Leyla Hanım hemen uyardı: “Hasan Bey'in gözlemi önemli bir ipucu, ama hangi ışığın gölgeyi oluşturduğunu hâlâ bilmiyoruz.”
---
@omurga
İlk bilim kulübü toplantısında Leyla Hanım, öğrencilerin ölçüm cetveline bakarken neden aynı nesne için farklı sayılar yazdıklarını sordu. {kahraman} ile {yoldas:yalin|bir arkadaş} önce cetvellerin yanlış olduğunu sandı. Sonra çizimleri karşılaştırınca herkesin ışık kaynağını farklı uzaklığa koyduğunu gördüler. Öğretmen, “Tek bir değişkeni kontrol etmezseniz deneyinizin sonucu {kelime:hr102_belirsiz} kalır,” dedi. Masadaki küçük figürü sabit tuttular. Işığı on santimetre ileri, sonra geri aldılar; gölgenin boyu belirgin biçimde değişiyordu.

{yoldas:yalin|bir arkadaş} bir tablo hazırladı. Her denemede ışığın figüre uzaklığını, figürün perdeye uzaklığını ve gölgenin yaklaşık uzunluğunu not ettiler. Bazı ölçümler tam uyuşmuyordu. {kahraman} başlangıçta bunları silmek istedi. Leyla Hanım buna karşı çıktı. “Yanlış veya beklenmedik sonucu görmeden temiz tablo yaparsanız, deneyin ne kadar güvenilir olduğunu anlayamazsınız.” Sonraki ölçümlerde cetvelin eğik tutulduğunu fark ettiler. Düzeltince fark azaldı.

Öğleden sonra {kahraman} videodaki siluetin neden başının yana dönük gibi göründüğünü tartıştı. Belki aradaki cismin kenarı başka bir nesnenin gölgesiyle birleşmişti. Leyla Hanım, insan zihninin belirsiz şekilleri tanıdık görüntülere benzetme eğilimine değindi. Çocuklar bir bulut fotoğrafında tavşan, bir ağaç gövdesinde yüz görebiliyordu. Bu, görüntünün içine gerçekten tavşan veya yüz yerleştirilmiş olduğu anlamına gelmiyordu.
---
@omurga
{yoldas:yalin|bir arkadaş} günlüğüne şu cümleyi yazdı: “Gördüğüm şekil ile ona verdiğim anlam farklı olabilir.” {kahraman} bundan hoşlandı. Gizemleri çözmeye çalışırken ilk önce kendi gözlerinin anlattığı hikâyeye de soru sormaları gerekiyordu.
---
@omurga
Okulda ertesi gün yeni bir video yayıldı. Bu kez gölgenin gözlerinin parladığı iddia ediliyordu. {kahraman} videoyu orijinaliyle karşılaştırdı. Göz gibi görünen iki noktanın parlaklığı yalnızca ikinci videoda artmıştı. Ayrıca görüntü keskinleştirilmiş ve üzerine ürkütücü ses eklenmişti. {yoldas:yalin|bir arkadaş} bu değişiklikleri fark edince şaşırdı. “Biri bilerek korkutmaya mı çalışıyor?” diye sordu.

{kahraman} kesin bir suçlama yapmadı. Görüntünün kimin tarafından işlendiğini bilmiyorlardı. Düzenlenmiş video ile asıl kayıt arasındaki farkı işaretleyip açıklayıcı bir not hazırladılar. Notta görüntü düzenleme araçlarının bazen ayrıntıları belirginleştirdiğini, bazen de yanıltıcı biçimde değiştirebildiğini anlattılar. Ancak henüz gölgenin gerçek kaynağını söylemediler. {isaret:anahtar}

Okul panosuna asılan not beklediklerinden çok ilgi gördü. Öğrencilerden biri “O zaman ilk video kesin sahte,” dedi. {kahraman} başını salladı. “Hayır. **Gölgenin gerçekten görünmüş olması, hakkında yapılan bütün yorumların doğru olduğu anlamına gelmiyor**. Bir videonun sonradan işlenmiş olması da ilk kaydın bütünüyle uydurma olduğunu kanıtlamaz.”
---
@omurga
Bu ayrımı yapmak kolay değildi. {yoldas:yalin|bir arkadaş} kendisinin de ilk gün görüntüde bir yüz gördüğünü itiraf etti. {kahraman}, “Ben de önce ürktüm,” dedi. “Korkmak, düşündüğümüz şeyi doğru yapmıyor. Yine de duygumuz gerçek.” İkisi birlikte okulda küçük bir medya atölyesi düzenlemeye karar verdi. Öğrencilere video kaynaklarını, çekim tarihini, kırpılan bölümleri ve eklenen sesleri kontrol etmeyi göstereceklerdi.
---
@omurga
Yeni videonun yayılmasından sonra meydandaki fırının önünde akşam müşterileri azaldı. Hasan Bey buna üzülüyordu. Komşularından biri dükkânı daha erken kapatmasını tavsiye etmiş, başka biri de gölgenin yakınındaki sokaktan geçmemeye başlamıştı. {kahraman} ve {yoldas:yalin|bir arkadaş}, söyledikleri sözlerin insanların günlük kararlarını etkilediğini görünce araştırmanın önemini daha iyi anladı.

Okul gazetesi konuyla ilgili haber hazırlamak istedi. Gazete kulübünden Öykü, {kahraman:yonelme} “Gölgenin sırrı çözüldü mü?” diye sordu. {kahraman}, “Henüz değil,” dedi. “Şimdilik bazı açıklamaları deniyoruz.” Öykü heyecanlı bir başlık yazmayı düşünüyordu ama kaynakları doğrulamadan kesin hüküm vermenin güven kaybettirebileceğini kabul etti. Haber başlığı “Kent Meydanındaki Gölgenin Kaynağı Araştırılıyor” oldu.

Haberde herkesin adı geçmedi. Videoyu çeken kişinin izni olmadan görüntüsü kullanılmadı. Yine de yayımlanan her yeni parça yorumları hareketlendiriyordu. Bir kullanıcı, “Öğrenciler gerçeği saklıyor,” yazdı. Başka biri, “Demek ki belediye bir deney yapıyor,” diye iddia etti. {kahraman} bu yorumları okuyunca şaşırdı. İnsanlar onun açıkça söylemediği şeyleri aralara yerleştiriyordu.
---
@omurga
{yoldas:yalin|bir arkadaş}, “Tek tek cevap verelim,” dedi. Leyla Hanım daha sakin bir yöntem önerdi. Ellerinde doğrulanmış verileri, denenen açıklamaları ve henüz bilinmeyenleri ayıran küçük bir bilgilendirme hazırlayacaklardı. Bu metin bir tartışma kazanmak için değil, okuyanların neyin gözlem neyin varsayım olduğunu görebilmesi için yazılacaktı.

Ertesi gün {kahraman} bilgilendirme afişinin altına bir cümle ekledi: “Korkmuş olmak utanılacak bir şey değildir; korkuyu {kelime:hr102_kanit} yerine koymak ise bizi yanıltabilir.” Hasan Bey afişi görünce teşekkür etti. “Ben de gördüğümü anlamamıştım,” dedi. “Ama hiçbir şey bilmeden komşularımı korkutmak istemiyorum.” {kahraman} ilk kez araştırmasının yalnızca bir bilim kulübü projesi olmadığını hissetti. Toplum içindeki sözlerin de sonuçları vardı.
---
@omurga
Bir hafta sonra belediye, meydandaki aydınlatma düzeniyle ilgili çalışma yapılacağını duyurdu. {kahraman} bu ilanı tesadüfen gördü. Gölgenin görüldüğü gece, reklam ekranında da yeni bir program denenmiş olabileceğini düşündü. Ancak belediyeyi suçlamak için hiçbir neden yoktu. Öğretmenleri aracılığıyla resmî bilgi istediler.

Gelen yanıtta meydandaki ışıkların saat programlarının bakım ekibi tarafından değiştirildiği yazıyordu. Işıkların bazıları gece belirli saatte otomatik sönüyordu. Bu bilgi, gölgenin kaybolduğu saatle uyumlu olabilirdi. {yoldas:yalin|bir arkadaş} hemen sonuca ulaşmak istedi. {kahraman} onu durdurdu. “Bir iki saatin çakışması neden-sonuç ilişkisini kanıtlamaz,” dedi. “Işık kaynağının yerini de bulmamız gerekiyor.”

Bir sonraki gözlem için öğretmenleriyle birlikte meydanın önceden izin verilen bölümünde basit ölçümler yaptılar. Bir ışığın gücüyle değil, geliş yönüyle ve aradaki cismin konumuyla ilgilendiler. Yakındaki binanın girişinde uzun, metal bir heykel bulunuyordu. Heykel gündüz kimsenin dikkatini çekmiyor, akşamları vitrin ışıklarıyla gölge oluşturuyordu. {yoldas:yalin|bir arkadaş} duvarın karşısına geçince siluet uzaktan bir insan gibi göründü.
---
@omurga
{kahraman} heykelin konumunu not aldı, ardından ışığı gözleriyle izledi. Fakat iki nokta uyuşmuyordu: Heykelin gölgesi duvarın alt kısmına düşüyordu; videodaki gölge daha yüksekteydi. “Yine erken sonuca gittik,” dedi. {yoldas:yalin|bir arkadaş} bu kez itiraz etmedi. Üstelik bir heykelin varlığı, insan gölgesini de imkânsız kılmazdı.

Gözlem sonunda öğretmenleri küçük bir öneride bulundu: Ertesi hafta belediyenin teknik görevlisiyle açık bir görüşme ayarlayabilirlerdi. Böylece ışıkların konumu ve çalışma saati hakkında doğrudan bilgi alabileceklerdi. {yoldas:yalin|bir arkadaş} bu kez sabırsızlanmadı. “Gizem kaçmıyor,” dedi. “Duvar yarın da burada.”
---
@omurga
Bakım görevlileriyle yapılan görüşmede ekrana yansıyan ışığın çevresinde başka yüzeyler de olduğunu fark ettiler. Karşı binanın camları, otobüs durağının şeffaf panelleri ve metal heykel farklı biçimde ışığı yansıtıyordu. {yoldas:yalin|bir arkadaş} ilk anda bunların hepsini tek bir kaynak gibi düşünmek istedi. {kahraman} ise her yüzeyin etkisini ayrı gözlemek gerektiğini söyledi. Öğretmenleri güvenli gözlem sınırlarını belirledi; belediye personelinin görev alanına izinsiz girmediler.

{kahraman} bir akşam önce çekilen başka bir güvenlik kamerası görüntüsünün varlığından söz edildiğini duydu. Hemen görüntüyü istemek yerine öğretmenine danıştı. Kamerada meydandan geçen insanların özel bilgileri bulunabilirdi. Bu nedenle kayıtların kendilerine verilmesi uygun olmayabilirdi. Teknik görevli, kişilerin görüntülerini paylaşmadan aydınlatma değişikliklerine ilişkin kayıtları sağlayabileceğini söyledi. {kahraman} bunun araştırma için yeterli olabileceğini fark etti.

Aydınlatma çizelgesinde saat on bire yakın bir parlaklık değişimi vardı. Ancak ışığın değişmesi, görüntünün o gece kesin aynı biçimde oluştuğunu ispatlamıyordu. {kahraman} deneyi yeniden düzenledi. Önce heykelin gölgesini ölçtüler. Ardından yetkili görevlinin belirlediği güvenli noktadan geçen bir kişinin oluşturduğu gölgeyi gözlediler. İki şekil üst üste geldiğinde uzun bir kol görüntüsü oluşuyordu. {yoldas:yalin|bir arkadaş} videoya baktı. Birkaç saniyeliğine herkesin korktuğu şey, sıradan iki gölgenin birleşimi gibi göründü.
---
@omurga
{kahraman} yine de rapora ölçüm hatalarını yazdı. Kamera açıları tam aynı değildi; duvarın üzerindeki yüzey dokusu gölgelerin kenarlarını değiştiriyordu. Bir görüntüyü kabaca benzetmek, geçmişteki bütün koşulları yeniden yaratmak değildi. “Belki gölgeyi açıklıyoruz ama videodaki her ayrıntıyı değil,” dedi. {yoldas:yalin|bir arkadaş} ilk günkü hâlini hatırlayıp gülümsedi. “Daha önce bir cümleyle bütün gizemi çözmek isterdim,” diye itiraf etti. “Şimdi iki kelime daha çok hoşuma gidiyor: olabilir, çünkü.”
---
@omurga
Teknik görevli Selçuk Bey, meydanın aydınlatma planını gösterdi. Yeni reklam ekranının arkasındaki güçlü ışığın bazı gecelerde duvara doğru yönlendiğini, ancak sistemin belirli saatlerde parlaklık değiştirdiğini anlattı. {kahraman} plandaki açıyı çizdi. Işık, heykelin yanındaki dar geçitten yansıma alıyor olabilirdi. Ama görüntünün insan biçimindeki kolu hâlâ açıklanmamıştı.

Selçuk Bey çocukları bakım saatinde, yetkili yetişkinler eşliğinde yapılan güvenli bir gözleme davet etti. Işıklar kontrollü biçimde çalıştırıldığında heykelin gölgesi duvarda belirdi. Ardından geçitten servis görevlisi yürüdü. Heykelin gölgesiyle kişinin gölgesi kısa süre üst üste gelince videodaki tuhaf siluete şaşırtıcı biçimde benzeyen bir şekil oluştu. Herkes sustu.

{yoldas:yalin|bir arkadaş} telefonunu çıkardı. {kahraman} hemen “Aynı noktadan çekelim,” dedi. Çekim için görevliden izin aldılar. Kamera açısı, yükseklik ve saat kaydedildi. Deneme iki kez tekrarlandı. Her ikisinde de benzer görüntü oluştu, fakat orijinal videoyla birebir aynı değildi. Selçuk Bey, aydınlatma programının o günden beri değiştirildiğini hatırlattı. Bu yüzden ancak güçlü bir açıklama önerdiklerini, geçmişteki görüntünün tüm koşullarını yeniden oluşturamadıklarını söylediler.
---
@omurga
{kahraman} bundan memnundu. Bir insan gölgesinin başka bir cisimle birleşmesi hem büyük silueti hem de biçimdeki tuhaflığı açıklıyordu. Saat programı, görüntünün aniden kaybolmasını da makul kılıyordu. Yine de rapora “kesin kanıt” yazmadı. “Elimizdeki verilerle en iyi uyuşan açıklama,” dedi.
---
@omurga
Kontrollü gözlemin ardından {yoldas:yalin|bir arkadaş} bir deney daha önerdi. Öğretmenlerinden izin alarak sınıfta basit bir karton model hazırladılar. Modelde duvarı beyaz kâğıt, heykeli karton figür, insanı küçük tahta çubuk temsil ediyordu. Işık kaynağını farklı yüksekliklere koyup iki gölgenin ne zaman birleştiğini gözlediler. Her birleşme aynı görüntüyü oluşturmuyordu. Bazıları bir insanı çağrıştırıyor, bazılarıysa yalnızca düzensiz bir leke gibi görünüyordu.

{kahraman}, aynı şekli gören üç öğrenciden farklı yorumlar aldı. Biri “Bekçi,” dedi; bir başkası “Ağaç,” üçüncüsü “Uzun kollu robot.” Elif adlı arkadaşları hiçbir şey söylemedi, sadece “Eğik bir çizgi ve oval şekil görüyorum” diye tarif etti. {kahraman} bu dört cevabı yan yana yazdı. İnsanların nesneye verdikleri adlar, gördükleri çizgilerden daha farklıydı. Böylece deneylerinde gözlem ile yorum arasındaki sınır somutlaştı.

{yoldas:yalin|bir arkadaş}, öğretmenine “O hâlde gözlerimiz bize yalan mı söylüyor?” diye sordu. Leyla Hanım gülümsedi. “Gözlerimiz çevremizi anlamamız için çok işe yarar,” dedi. “Ama beynimiz gördüklerini yorumlar. Yanılabileceğimiz için ölçüm, karşılaştırma ve farklı kişilerin gözlemleri değerlidir.” Çocuklar deneyin fotoğraflarını tarih ve ışık yerleriyle birlikte kaydetti; okuldaki sunumda gerçek meydan görüntüsüyle maket görüntüsünü karıştırmayacak biçimde etiketlemeye karar verdiler.
---
@omurga
Deneyin sonundaki küçük tartışma en az sonuç kadar öğreticiydi. {yoldas:yalin|bir arkadaş}, “Bence gizemi çözdük,” diyordu. {kahraman} ise “Güçlü bir açıklama bulduk,” diye ısrar ediyordu. Leyla Hanım ikisine de rapordaki iddia cümlesini yeniden okumalarını istedi. Sonunda birlikte şu ifadeyi seçtiler: “Mevcut veriler, gölgenin birden fazla ışık ve cismin birleşmesiyle oluşmuş olabileceğini destekliyor.” Bu cümle daha uzundu ama neyi bildiklerini daha doğru anlatıyordu.
---
@omurga
Gölge videosunun yayıldığı günlerde sekizinci sınıftan Baran, akşam kursundan eve dönerken meydandan geçmemeye başlamıştı. Daha uzun bir yol seçiyor, bazı günler eve geç kalıyordu. {kahraman} bunu duyunca, videonun yalnızca bir eğlence konusu olmadığını daha iyi anladı. Baran'la konuşurken “Korkulacak bir şey yok” demedi. Böyle bir cümle hem onu küçümseyebilir hem de henüz tam kanıtlanmamış bir güvence verebilirdi.

“Orada ne olduğunu bilmiyorum,” dedi Baran. “Ama video her karşıma çıktığında korkuyorum.” {kahraman} ona şimdiye kadar yaptıkları güvenli gözlemleri anlattı, ışık ve gölge ilişkisini gösterdi. Baran dikkatle dinledi ama bir anda rahatlamadı. “Beynim hâlâ o görüntüyü hatırlıyor,” dedi. {kahraman} bunu anlayabiliyordu. Korku, bir tabloya bakınca hemen silinmeyebilirdi.

Öğretmenleri, endişe yaşayan öğrencilerin güvendikleri yetişkinlerle konuşmasını, gece gözlemine kendi başlarına çıkmamalarını söyledi. Baran da ailesiyle konuşup kurs saatinden sonra daha güvenli bir dönüş düzeni belirledi. Bu, gizemi çözmekten ayrı ama önemli bir ihtiyaçtı. {kahraman}, bir olayı açıklamanın insanların duygularıyla ilgilenmeyi gereksiz kılmadığını öğrendi.
---
@omurga
Ertesi hafta Baran bilim kulübüne katıldı. İlk iş olarak sınıftaki gölge deneyini izledi. Aynı cisimden iki farklı gölge çıktığını görünce şaşırdı. “Videodaki gibi!” dedi. Sonra küçük bir kart aldı, üstüne Bir gölge gördüm, bir hikâye düşündüm yazdı. {kahraman} kartı kulüp panosuna astı. Bazen öğrenme, korkunun ortadan kaybolmasından önce onun hakkında soru sorabilmekle başlardı.
---
@omurga
Okul gazetesinden Öykü, ilk videonun yalnızca on iki saniyelik olduğunu fark etti. “Öncesi ve sonrası yok,” dedi. “Oysa bir ışığın açılıp kapanması gibi olayları anlamak için daha uzun zaman aralığı gerekebilir.” {kahraman} videoyu çeken kişinin yeniden görüşmeye izin verip vermeyeceğini sordu. İzin verilirse, çekim koşulları hakkında sorular soracaklardı; verilmezse bu sınıra saygı duyacaklardı.

Videoyu çeken kişi öğretmenlerinin aracılığıyla kısa bir görüşmeyi kabul etti. Gece oradan geçerken durup ilginç bir görüntü gördüğünü, hızlıca telefonunu çıkardığını anlattı. “Korkutucu bir şey çektiğimi düşünmedim,” dedi. “Sabah videonun bu kadar yayıldığını görünce şaşırdım.” Görüntüye eklenen müziğin kendisine ait olmadığını da belirtti.

{kahraman}, “Videonun öncesinde ne oldu?” diye sordu. Kişi, reklam ekranının parladığını hatırladığını ama emin olmadığını söyledi. Bu ifade teknik kayıtlarla uyumlu olabilirdi. Fakat {kahraman} onu kesin tanık saymadı. Hafıza ile cihaz kaydı birbirinden farklı türde bilgi sunuyordu.
---
@omurga
{yoldas:yalin|bir arkadaş} da ilk yayımlanan metnin “bekçi geri döndü” şeklinde yazılmadığını öğrendi. Bu yorum, videoyu paylaşan başka hesaplardan birinde eklenmişti. O anda mesele yalnızca ışık değil, bilgi zinciriydi: Görüntüyü kim çekmişti, kim kesmişti, kim müzik eklemişti, kim başlık yazmıştı? Bir iddianın yolu uzadıkça kaynağı unutuluyordu.

İkili bu zinciri çizerek sunumlarına ekledi. Oklar, paylaşımın farklı aşamalarını gösteriyordu. Bazı bağlantılar belirsizdi ve öyle işaretlendi. {kahraman}, “Bir videonun hikâyesi de videodaki olay kadar araştırılabilir,” dedi. {yoldas:yalin|bir arkadaş}, “Belki daha bile zor,” diye karşılık verdi. Çünkü ışığın gölgesi duvara düşerken, sözlerin gölgesi insanların zihninde uzuyordu.
---
@omurga
Araştırmaları ilerledikçe bir öğrenci grubu bu kez “Gölgeyi bilim kulübü yaptı” söylentisini yaydı. Bir fotoğrafta {yoldas:ilgi|bir arkadaşın} elinde ışık ölçerle görülmesi, bazılarına göre bunun kanıtıydı. {yoldas:yalin|bir arkadaş} çok sinirlendi. “Biz açıklamaya çalışırken suçlu olduk,” dedi. {kahraman} bunun can sıkıcı olduğunu kabul etti. “Ama hemen karşı suçlamaya başlarsak aynı hatayı yaparız,” diye hatırlattı.

Öğretmenleriyle birlikte, fotoğrafın ne zaman çekildiğini ve bilim kulübünün hangi amaçla ölçüm yaptığını açıklayan kısa bir bilgi yayımladılar. Fotoğrafın asıl paylaşıldığı sayfada tarihin yazdığı görülebiliyordu: İlk gölge videosundan sonraki gün. Demek ki fotoğraf, ilk olayın nedeni olarak gösterilemezdi. {yoldas:yalin|bir arkadaş} bunu kanıtla açıklayınca bir miktar rahatladı.

Yine de birkaç kişi söylentiye inanmaya devam etti. Leyla Hanım çocuklara, doğru bir açıklamanın herkesi anında ikna etmek zorunda olmadığını anlattı. “Sizin sorumluluğunuz, elinizdeki kanıtı dürüstçe sunmak ve gerektiğinde hatanızı düzeltmektir,” dedi. “Herkesin duygusunu ve düşüncesini kontrol edemezsiniz.”
---
@omurga
{kahraman} akşam defterine iki sütun çizdi. Bir tarafta bildiklerim, diğerinde başkalarının iddiaları yazıyordu. İlk sütunda ölçüm sonuçları, ışık kaydı ve tekrar edilen gölge deneyi vardı. İkinci sütunda geceleri dolaşan bekçi, gizli düzenek ve bilim kulübü suçlaması. Bu iki sütunu karıştırmadığında düşünmek daha kolaydı.
---
@omurga
Meydanın duvarına asılan eski gölge videosu günlerce konuşulmuştu. {kahraman} ve {yoldas:yalin|bir arkadaş} hazırladıkları raporu okulun bilim gününde sundu. İlk slaytta orijinal görüntü, ikinci slaytta farklı ışık kaynaklarının çizimi, üçüncü slaytta kontrollü gözlem vardı. Son slaytta ise şu cümle yazıyordu: Bir iddia ilgi çekici olabilir; doğru sayılması için kanıt gerekir.

Sunumdan sonra bir öğrenci, “Yani bütün efsaneler yalan mı?” diye sordu. {kahraman}, “Efsaneler kültürün bir parçası olabilir,” dedi. “Ama tarihsel veya bilimsel bir iddiayı doğrulamak istediğimizde başka yöntemlere ihtiyacımız var.” Öğretmenleri de insanların hikâyelerden keyif alabileceğini, bunun {kelime:hr102_guvenilir} bilgi aramaya engel olmadığını anlattı.

{yoldas:yalin|bir arkadaş}, ilk gün gölgeyi bir korku filmi gibi izlediğini söyledi. Şimdi en heyecan verici anın tuhaf bir şey görmek değil, yavaş yavaş nasıl oluştuğunu anlamak olduğunu düşünüyordu. {kahraman} ise insanların birbirlerinin korkusuyla alay etmeden de kuşkucu olabileceğini öğrenmişti. Birinin endişesini küçümsemek, onu doğru bilgiye yaklaştırmıyordu.
---
@omurga
Meydandaki duvar bir süre sonra yeniden sıradan görünmeye başladı. Ama akşam olduğunda {kahraman} hâlâ duvarın önünden geçerken ışıklara bakıyordu. Bir gölgenin her zaman bir sahibi olması gerekmiyordu; bazen birçok kaynağın kısa bir anda buluşmasıydı. Bu düşünce ona gizemli gelmeye devam etti. Yalnızca artık korkudan değil, meraktan ürperiyordu.
---
@omurga
Yerel bir haber sitesi okulun araştırmasını duyurmak istedi. Muhabir, {kahraman} ve {yoldas:ilgi|bir arkadaşın} hazırladığı notları okuyunca heyecanlandı. “Gölgenin sırrını çözen çocuklar” başlığını önerdi. {kahraman} nazikçe itiraz etti. “Güçlü bir açıklama bulduk ama geçmişteki bütün koşulları birebir yeniden oluşturmadık,” dedi. Muhabir bir süre düşündü. “Bu başlık fazla iddialıymış,” diyerek yeni bir öneri getirdi: “Öğrenciler meydandaki gizemi ışık ve kanıtlarla araştırdı.”

Röportajda {yoldas:yalin|bir arkadaş}, ilk gün nasıl heyecanlandığını anlattı. “Ben de hemen bir hikâyeye inandım,” dedi. “Sonra kendi ilk tahminimin yanılabileceğini öğrendim.” Muhabir, “Peki bu sizi cesaretsiz yapmadı mı?” diye sordu. {yoldas:yalin|bir arkadaş} şaşırdı. “Tam tersi. Yanılabileceğimi bildiğim için yeniden denemeye cesaret ettim.” {kahraman} bunun güzel bir cevap olduğunu düşündü; arkadaşının heyecanı artık tek bir kesin sonuca bağlı değildi.

Haber yayımlandığında bazı okuyucular teşekkür etti, bazıları daha fazla kanıt istedi. Birkaç kişi hâlâ eski bekçi hikâyesini anlatıyordu. {kahraman} buna kızmadı. İnsanlar hikâye anlatmayı sürdürebilir, yine de gündelik kararlarında güvenilir bilgilere dayanmayı öğrenebilirdi. Haberin altına eklenen küçük bir bağlantı, öğrencilerin gözlem tablolarını ve bulguların sınırlarını gösteriyordu. Böylece isteyenler yalnızca sonuç cümlesine bakmak yerine süreci de inceleyebilecekti.
---
@omurga
Ertesi sabah sınıfa gelen Leyla Hanım iki haber başlığını tahtaya yazdı. İlki “Gizem çözüldü!” diyordu. İkincisi “Öğrenciler olası ışık düzenini açıkladı” şeklindeydi. “Hangisi daha çok dikkat çeker?” diye sordu. Çoğu öğrenci ilkini seçti. “Hangisi elimizdeki kanıta daha uygun?” diye sorunca neredeyse hepsi ikinciyi işaretledi. Öğretmen gülümsedi. “Dikkat çekmek ile doğru anlatmak arasında seçim yapmak zorunda değiliz; ama doğruyu bozarsak uzun vadede güveni kaybederiz.”
---
@omurga
Okulun görsel sanatlar kulübü, meydan projesine katılmak için küçük bir sergi hazırladı. Öğrenciler ışığın düştüğü açıya göre değişen gölgeler çiziyordu. Bir çalışmada heykel ve insan gölgesi iki ayrı renkle gösterilmiş, üst üste gelen bölgede üçüncü bir renk ortaya çıkmıştı. {kahraman} çizimi görünce deneyin fiziksel düzenini anlatmak için ne kadar yararlı olduğunu fark etti.

Serginin açılışında sanat öğretmeni, “Bir görüntüyü sanat eseri olarak yorumlamakla bilimsel kanıt olarak sunmak farklı iştir,” dedi. “Buradaki resimler açıklamayı kolaylaştırır ama yerinde yapılan ölçümlerin yerine geçmez.” {yoldas:yalin|bir arkadaş} bu ayrımı sevdi. Video hakkında çıkan söylentilerde insanlar hayal güçlerini kanıt gibi kullanmıştı. Oysa hayal gücü bir soruyu sormaya, bir model kurmaya ve anlatımı zenginleştirmeye de yardım edebilirdi.

Öğrenciler sergiye küçük bir oyun ekledi. Ziyaretçiler aynı gölge şekline bakıp ne gördüklerini yazıyordu. Bir çocuk ejderha, biri kule, biri koşan bir insan gördü. Yanlarında ışık kaynaklarının yerleri gösterildiğinde gölge fiziksel olarak değişmiyordu; değişen insanların yorumu oluyordu. {kahraman} oyunun sonunda “Görmek ve anlamlandırmak aynı adım değil,” diye açıkladı.
---
@omurga
Bir veli gölgenin hâlâ korkutucu görünüp görünmediğini sordu. {kahraman} dürüstçe, “Bazen evet,” dedi. “Ama artık gördüğüm şeyin kaynağını merak ediyorum.” Veli onun cevabını sevdi. Çünkü bir soruyu araştırmak, bütün duyguları silmek zorunda değildi.
---
@omurga
Bir akşam bilim kulübü erken saatlerde meydanda son gözlemini yaptı. Bu kez öğrencilerin yanında ışık kaynaklarının krokisi, ölçüm notları ve güvenli gözlem planı vardı. {yoldas:yalin|bir arkadaş} duvarın önüne geldiğinde birkaç ay önce aynı noktada korkutucu bir hikâye dinlediğini hatırladı. Şimdi aynı duvarda güneşin batışıyla uzayan sıradan gölgeler görüyordu. Nesneler değişmemişti; onun bakışı değişmişti.

Hasan Bey fırından çıkıp yanlarına simit getirdi. “Artık kimse gölgeyi konuşmuyor sanıyordum,” dedi. {kahraman} gülümsedi. “Konuşuyoruz, ama başka türlü.” Hasan Bey ışık haritasını inceledi. Duvarın yanındaki metal heykeli, karşı binanın ekranını ve geçitten yürüyen kişinin oluşturabileceği gölgeyi gördü. “Bazen gözümüzün önündeki şeyleri bile anlamak zaman alıyor,” dedi.

{yoldas:yalin|bir arkadaş}, “Yalnızca bakmakla değil, doğru soruları sormakla,” diye ekledi. Sonra meydanın öbür ucunda oynayan çocuklara baktı. Onlardan biri elini ışığa uzatıp duvarda kuş şekli yaptı. Arkadaşları kahkahalarla güldü. Aynı duvar, bu kez korku değil oyun taşıyordu.
---
@omurga
{kahraman} defterine son bir cümle yazdı: Gölgenin sahibini bulmaya çalışırken, onun kaynağını sormayı öğrendik. Defteri kapattı. Yeni bir ışık yakıldığında yeni gölgeler oluşacaktı. Belki başka bir gün birileri onları da yanlış anlayacaktı. O zaman çocukların elinde korkudan daha güçlü bir araç vardı: merak, dikkat ve kanıt arama alışkanlığı.
---
@omurga
Bilim kulübünün son toplantısında Leyla Hanım, bütün ışıkları kapatıp ekranda aynı gölge şeklinin çizimini gösterdi. “Şimdi bunun gerçek bir insana ait olduğunu düşünseniz ne hissedersiniz?” diye sordu. Bazı öğrenciler tedirgin oldu, bazıları gülmeye başladı. Sonra aynı şeklin heykel ve insan gölgelerinin birleşimiyle oluşabildiğini anlatan model açıldı. Duygular değişti ama görüntünün kendisi pek değişmemişti.

{kahraman}, “Bir açıklama öğrenmek, görüntüye bakışımızı değiştirebiliyor,” dedi. {yoldas:yalin|bir arkadaş} da bunun tek yönlü olmadığını ekledi. “Bazen çok korktuğumuz için gördüğümüz şekle daha korkutucu bir anlam da veriyoruz.” Öğretmen, hislerin gerçek olduğunu fakat tek başına bir iddiayı kanıtlamadığını hatırlattı.

Sınıfça bir olayın nasıl araştırılacağını anlatan küçük bir poster hazırladılar. Önce gözlemi ve yorumu ayırmak, ardından kaynağı bulmak, değişkenleri belirlemek, güvenli koşullarda denemek ve sonucun sınırlarını yazmak gerekiyordu. {yoldas:yalin|bir arkadaş} posterin en başına “Merak et!” yazdı. {kahraman} en alta “Emin olmadığında bunu da söyle” cümlesini ekledi. İki söz yan yana olduğunda merak ve dikkat birbirini tamamlıyordu.
---
@omurga
Posteri gören Baran, kendisinin gölgeden korktuğu günleri hatırladı. “İlk başta herkes bana gülüyor sanmıştım,” dedi. {kahraman} onunla konuşmanın en önemli adımlardan biri olduğunu düşündü. Eğer yalnızca “Korkma” deseydi Baran belki de bilim kulübüne hiç gelmeyecekti. Onu dinlemek araştırmanın sayısal sonuçları kadar gerekliydi.

Gün sonunda Leyla Hanım, “Peki gerçek bir söylentiyle karşılaştığınızda nasıl davranacaksınız?” diye sordu. Öğrenciler bir ağızdan “Paylaşmadan önce kontrol edeceğiz” dedi. {yoldas:yalin|bir arkadaş} ekledi: “Ve hemen birini suçlamayacağız.” {kahraman} de “Korkmuş birini küçümsemeyeceğiz,” diye tamamladı.

O akşam meydandan geçen {kahraman}, taş duvarda iki kısa gölge gördü. Bir an durup kaynaklarına baktı. Birisi lambadan, diğeri geçen bir bisikletten oluşuyordu. Görüntü sıradandı; yine de ışığın çizdiği çizgileri dikkatle izledi. Korkutucu hikâyenin sonunda bulduğu şey, gölgelerden daha ilginçti: Soru sormaktan vazgeçmemişti.

Meydandaki çalışma sonrasında okul gazetesi, {kahraman:ilgi} araştırma defterinden izin verilen bazı sayfaları yayımladı. Sayfalarda yalnızca başarılı denemeler değil, tutmayan ölçümler de vardı. Okuyuculardan biri neden yanlış sonuçları saklamadıklarını sordu. {kahraman}, “Çünkü neyi neden değiştirdiğimizi gösteriyorlar,” diye yanıt verdi. Başka bir çocuk, evde el feneriyle duvarda kuş şekli yapmayı denediğini anlattı. {kahraman} ona bunu güvenli, uygun bir ortamda yetişkin bilgisiyle yaptığını söyleyince sevindi; araştırmanın yeni sorular doğurması hoşuna gitmişti.
---
@omurga
Bilim kulübü son toplantısında bir oyun oynadı. Öğretmen her gruba aynı bulanık fotoğrafı verdi, fakat açıklama cümlelerini farklı yazdı. Bir gruba “Gizemli yaratık”, başka bir gruba “Ağaç dalı”, üçüncü gruba “Belirsiz nesne” başlığı gösterildi. Öğrenciler görüntüyü farklı yorumladı. Başlıkların bakışı etkileyebildiğini kendi deneyimleriyle gördüler. {kahraman} artık yalnızca videoyu değil, videonun yanında yazanı da kontrol edeceğini söyledi. Çünkü bir görüntünün önüne konan birkaç kelime, insanların ona yüklediği anlamı değiştirebilirdi.

{yoldas:yalin|bir arkadaş} son olarak “Eğer yarın başka bir gölge görünürse ne yaparız?” diye sordu. {kahraman} düşünmeden yanıt vermedi. “Önce güvende kalırız,” dedi. “Sonra kimin ne gördüğünü, hangi ışıkların bulunduğunu ve elimizde hangi kayıtların olduğunu sorarız. Yeni olayın eskisine benzediğini söyleyebiliriz ama aynı nedenle oluştuğunu varsayamayız.” {yoldas:yalin|bir arkadaş} başını salladı. Gerçek araştırma, her yeni soruya aynı cevabı yapıştırmak değildi.
---
@omurga
Bir hafta sonra {kahraman:ilgi} okuluna medya okuryazarlığı atölyesi için gelen gazeteci, öğrencilerden aynı videoya iki ayrı başlık yazmalarını istedi. Bir grup “Gece yarısı meydanda korkunç yaratık” dedi. Diğer grup “Meydandaki siluetin kaynağı araştırılıyor” başlığını seçti. Aynı görüntü, ilk başlığın altında sanki kesinleşmiş bir olağanüstü olaydı; ikinci başlığın altında ise açıklanmayı bekleyen gözlemdi.

{yoldas:yalin|bir arkadaş} hangisinin daha çok tıklanacağını tahmin edebiliyordu. Bunun onu rahatsız etmesi şaşırttı. “Birilerini heyecanlandırmak için emin olmadığımız şeyleri kesinmiş gibi söylemek kolay,” dedi. {kahraman} ona, meydanda geç saatlere kadar korkuyla bekleyen komşularını hatırlattı. Sözcükler eğlence olarak yazılmış olsa da sonuçları gerçek olabiliyordu.

Atölye çıkışında küçük bir öğrenci, “Ama masallar da gerçek değil; onları niçin seviyoruz?” diye sordu. {kahraman} bu soruyu beğendi. “Masalda baştan kurmaca bir dünyaya girdiğimizi biliyoruz,” dedi. “Sorun hayal kurmakta değil, hayali kanıt diye sunmakta.” O günden sonra meydandaki duvarın önünden her geçtiğinde aynı şeyi düşündü: İnsan gölgesinden korkabilir; fakat gölge hakkında kurduğu hikâyenin sorumluluğunu da taşır.
---
@omurga
{kahraman}, sunumun son slaydına iki cümle yazdı: “Gördüğümüz şey bir gölgedir. Gölgenin neden oluştuğu ise ayrıca araştırılmalıdır.” {yoldas:yalin|bir arkadaş} ilk cümleye itiraz etmedi; ikinci cümleyi görünce gülümsedi. İki satır arasında heyecanı yok eden bir boşluk değil, gerçeğe ulaşmak için yürünecek bir yol vardı.
