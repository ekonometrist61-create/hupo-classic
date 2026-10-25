---
baslik: "Kuledeki Son Işık"
slug: "hr043-kuledeki-son-isik"
fis_kodu: "HR-043"
tur: macera
konu: hava_gozlem
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D3]
yetiskin_uygun: false
tanitim: "Eski kulede yanıp sönen bir ışık var. Gizli bir mesaj mı, yoksa hava gözleminin bir parçası mı?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [gizem, bilim_teknoloji]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D3
  ogrenme_hedefleri:
    - {id: anten_hr043, tur: lexeme, etiket: "anten", yuva: hr043_anten, islev: first_hint}
    - {id: meteoroloji_hr043, tur: lexeme, etiket: "meteoroloji", yuva: hr043_meteoroloji, islev: application}
    - {id: olasilik_hr043, tur: lexeme, etiket: "olasılık", yuva: hr043_olasilik, islev: application}
    - {id: sagnak_hr043, tur: lexeme, etiket: "sağanak", yuva: hr043_sagnak, islev: application}
    - {id: deyim_hr043, tur: idiom, etiket: "El kaldırmak", yuva: hr043_el_kaldirmak, islev: application}
    - {id: kavram_hr043, tur: concept, etiket: "Gözlem, tahmin ve kanıt ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Nehir kulede geçen ay ne görmüştü?", secenekler: [{id: A, metin: "Kırık bir pencere"}, {id: B, metin: "Büyük bir balon"}, {id: C, metin: "Yenilenen bir anten"}, {id: D, metin: "Eski bir saat"}], dogru: C, aciklama: "Nehir, tepede yenilenmiş bir anten görmüştü."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Emir'in gizli haberleşme fikri neden zayıfladı?", secenekler: [{id: A, metin: "Kulede meteoroloji sensörlerinin yenilendiği öğrenildi"}, {id: B, metin: "Kule yıkıldı"}, {id: C, metin: "Kimse gözlem yapmadı"}, {id: D, metin: "Hava güneşli oldu"}], dogru: A, aciklama: "Yenilenen sensörler, kulenin hava ölçümü için kullanıldığını gösterdi."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 4, metin: "Öğretmenin açıklamasına göre hava tahmini nedir?", secenekler: [{id: A, metin: "Yalnızca bulutlara bakmak"}, {id: B, metin: "Gelecekte olacak her olayı kesin bilmek"}, {id: C, metin: "Sıcaklık, basınç, nem ve rüzgâr gibi verilerin birlikte değerlendirilmesi"}, {id: D, metin: "Yalnızca termometre okumak"}], dogru: C, aciklama: "Tahmin, birçok verinin birlikte yorumlanmasıdır ve bir kesinlik derecesi taşır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 5, metin: "Metinde geçen sağanak sözcüğü ne anlama gelir?", secenekler: [{id: A, metin: "Çok sıcak bir rüzgâr"}, {id: B, metin: "Kısa süreli, şiddetli yağmur"}, {id: C, metin: "Kuru bir bulut"}, {id: D, metin: "Kar fırtınası"}], dogru: B, aciklama: "Sağanak, aniden başlayıp kısa süren şiddetli yağmurdur."}
deyim_cumleleri:
  hr043_el_kaldirmak: "{yoldas:yalin|bir arkadaş} elini kaldırdı."
---
@omurga
Yağmurdan sonraki serin akşamda, kasabanın üzerindeki eski gözlem kulesinin penceresinde üç kez ışık göründü. Beşinci sınıf öğrencisi Nehir, balkonlarında otururken ışığın önce kısa, sonra uzun aralıklarla yandığını fark etti. Herkes kulenin yıllardır kullanılmadığını söylüyordu. Nehir ise geçen ay aynı tepede yenilenen bir {kelime:hr043_anten} görmüştü.

"Anne, kulede biri olabilir mi?" diye sordu.

Annesi perdeyi açıp baktı. "Olabilir. Ama gece tek başımıza oraya gitmek doğru olmaz. Yarın belediyenin bilgi hattına sorabiliriz."

Nehir ertesi sabah okulda gördüklerini en yakın arkadaşı {yoldas:yonelme|bir arkadaşa} anlattı. {yoldas:yalin|bir arkadaş} doğa olaylarıyla ilgili videolar izlemeyi severdi. "Belki gizli bir haberleşme sistemi," dedi heyecanla.

Üçüncü arkadaşları Defne ise hemen karşı çıktı. "Ya bakım lambasıysa? Önce gözlemimizi yazalım."

Öğretmenleri Meryem Hanım bir bilim gözlem etkinliği planlıyordu. Çocukların notlarını görünce kulenin bulunduğu tepeyi gösteren eski bir fotoğraf çıkardı. Fotoğrafta kulenin yanında rüzgâr yönünü gösteren bir ok vardı. "Bu yer eskiden hava gözlemleri için kullanılmış," dedi. "Bugünkü işlevini bilmiyoruz. Birlikte araştırabiliriz."
---
@omurga
{yoldas:yalin|bir arkadaş} çantasından çizgili defterini çıkarıp kuleye ait bir resim çizdi. Üzerine üç ışık işareti koydu. Nehir dikkatle baktı. "Ben üç ışık gördüm ama aralarında eşit süre var mıydı, bilmiyorum," dedi. Defne "O zaman aralıklara eşit çizgi koymayalım," diye önerdi. Çizimin altına **yaklaşık gözlem** yazdılar. {yoldas:yalin|bir arkadaş}, bu küçük kelimenin neden önemli olduğunu o an kavradı. Kesin olmayan bir şeyi kesinmiş gibi göstermek, resme bakacak herkesi yanlış yönlendirebilirdi. Bir sonraki gözlem için saat tutmayı, rüzgâr ve hava durumunu da not etmeyi planladılar. Her birinin ayrı görevi olacaktı. Nehir görsel kaydı, {yoldas:yalin|bir arkadaş} zamanlamayı, Defne notları kontrol edecekti. Böylece aynı olayı üç kişinin farklı bakışla inceleyebileceğini düşündüler.

İlk görevleri, kuleye yaklaşmadan güvenilir bilgi bulmaktı. Belediye sayfasındaki duyuruları incelediler. Kulede bazı {kelime:hr043_meteoroloji} sensörlerinin yenilendiğini öğrenince {yoldas:ilgi|bir arkadaşın} gizli haberleşme fikri zayıfladı. Yine de geceki ışığın ne anlama geldiği açıklanmamıştı.
---
@omurga
Bir gün önce Nehir'in küçük kardeşi rüzgâr gülünü döndürmekte zorlanmıştı. Nehir ona, "Rüzgâr yoksa dönmez," demişti. Kardeşi üfleyerek çarkı döndürünce ikisi gülmüştü. Okuldaki gözlem köşesinde Nehir bu anıyı anlattı. Öğretmenleri hava hareketinin farklı hızlarda olabileceğini, ölçüm araçlarının doğru kullanılmasının önemini açıklarken çocuklardan gözlemlerini basit cümlelerle yazmalarını istedi. {yoldas:yalin|bir arkadaş} başlangıçta "çok rüzgârlı" diye not aldı. Defne ona "Ne kadar?" diye sordu. Sınıftaki rüzgâr ölçerin değerini ve saati eklediler. Bu küçük değişiklik, bir gözlemden daha karşılaştırılabilir bir kayda geçmelerini sağladı.
---
@omurga
Meryem Hanım, öğrencileri okulun küçük hava köşesine götürdü. Termometre, yağmur ölçer ve rüzgâr yönünü gösteren basit bir düzenek vardı. Nehir sabah sıcaklığını deftere yazdı. {yoldas:yalin|bir arkadaş} gökyüzündeki bulutların şeklini çizdi. Defne ise rüzgârın aniden yön değiştirdiğini fark etti.

"Hava tahmini yalnızca bulutlara bakmak mıdır?" diye sordu {yoldas:yalin|bir arkadaş}.

"Hayır," dedi öğretmenleri. "Sıcaklık, basınç, nem, rüzgâr ve daha birçok veri birlikte değerlendirilir. Üstelik tahminin kesinlik derecesi vardır."

Okuldaki hava köşesinin termometresi güneş altında kaldığında daha yüksek değer gösterebiliyordu. Defne, farklı yere taşındığında ölçümün niçin değiştiğini merak etti. Öğretmenleri, ölçümlerin karşılaştırılabilir olması için araçların doğru yere konması ve aynı yöntemle kullanılması gerektiğini anlattı. Nehir, evlerinin balkonunda tuttuğu sıcaklık notlarıyla okul kayıtlarının neden farklı olduğunu anladı. {yoldas:yalin|bir arkadaş} yağmur ölçerin boşaltılması gerektiğini unuttuğu bir günü hatırladı. "Demek sayı kadar sayının nasıl elde edildiği de önemli," dedi. Meryem Hanım, "Bunu raporunuzun en üstüne yazın," diye önerdi. Çocuklar artık meteorolojiyle ilgili bir sözcük öğrendiklerinde onu doğrudan örneklerle ilişkilendirebiliyordu: nem, yağış, basınç ve rüzgâr yalnızca kitapta gördükleri kelimeler değildi.
---
@omurga
O gün okulun küçük bahçe şenliğinin duyurusu yapılacaktı. Sınıf süslemeleri hazırlıyordu. Nehir hava tahmini sitesinde akşam için gök gürültülü {kelime:hr043_sagnak} {kelime:hr043_olasilik} gördü. Arkadaşı Tuna, "Burada güneş var, yağmur gelmez," dedi. Defne buna itiraz etti: "Bir yerde güneş olması, birkaç saat sonra başka bir hava olayı yaşanmayacağını göstermez."

Çocuklar öğretmenlerinden resmi tahmin ve uyarıların nereden takip edildiğini öğrendi. Başka kaynaklarda farklı ifadeler görünce de tek bir videoya bakarak karar vermemeleri gerektiğini anladılar. O akşam notlarını gözden geçirirken "hava durumu" ile "hava tahmini" sözcüklerini aynıymış gibi kullanmış olduğunu gördü. Öğretmeninin anlattıklarını hatırladı: Biri belirli bir zamanda gözlenen durumu, diğeri geleceğe ilişkin değerlendirmeyi anlatıyordu. Defterindeki iki cümleyi düzeltti. Bu küçük ayrım, sonraki günün sorularını daha açık sormasına yardım edecekti.
---
@omurga
Nehir akşamki kule ışıklarının havayla ilişkili olabileceğini düşünmeye başladı.

Öğle arasında duyuru panosuna küçük bir çizelge astılar: Gözlem, tahmin, gerçekleşen hava. Sınıftaki diğer öğrenciler de kendi gözlemlerini ekledi. Kimileri bulutları resmetti, kimileri rüzgârı hissettiğini yazdı. Çizelge giderek bir dedektif panosuna benziyordu. Fakat bu kez dedektiflerin peşinde bir insan değil, değişen hava vardı.
---
@omurga
Meryem Hanım, meteoroloji bölge müdürlüğündeki eski öğrencisi Burcu Hanım'ı çevrim içi görüşmeye davet etti. Burcu Hanım bir hava uzmanıydı. Öğrenciler sırayla sorularını yöneltti. {yoldas:yalin|bir arkadaş} kuledeki yanıp sönen ışığın gizli bir mesaj olup olmadığını sordu.

"Kulede ekipman kontrolü için kullanılan ışıklar olabilir," dedi uzman. "Ama görüntüye bakarak görevini kesin söyleyemem. Hangi sistem olduğunu kurumdan doğrulamamız gerekir."

Nehir, "Bir hava istasyonu tehlikeyi nasıl bildirir?" diye sordu.

Burcu Hanım, otomatik istasyonların ölçümleri elektronik yollarla iletebildiğini anlattı. Gözlem verileri uzmanlarca incelenir, uygun görülürse resmî uyarılar yayımlanırdı. Kuledeki ışık tek başına halka yönelik bir alarm anlamına gelmiyordu.
---
@omurga
Burcu Hanım çevrim içi görüşmede bir örnek de gösterdi. İki haritada aynı bölgenin farklı zamanlardaki hava durumunu simgelerle işaretlemişti. Bir haritada yağmur olasılığı görünürken ötekinde yağışın gerçekleştiği alan gösteriliyordu. {yoldas:yalin|bir arkadaş} iki haritayı ilk anda aynı sandı. Burcu Hanım, "Biri tahmin, biri gözlem," dedi. "Birbirine benzeyebilirler ama görevleri farklıdır." Çocuklar bir tahmini değerlendirirken ne zaman yayımlandığına ve hangi süreyi kapsadığına dikkat etmeleri gerektiğini öğrendi. Nehir bunu çok yararlı buldu; çünkü internette dolaşan eski bir uyarıyı güncel sanmanın da yanlış kararlar doğurabileceğini fark etti. Defne, sınıf panosuna tarihi olmayan hiçbir uyarı resmi asmayacaklarına karar verdi.

Görüşme bittikten sonra Meryem Hanım önemli bir soru sordu: "Bir ipucu gördüğünüzde hikâyeyi kim tamamlıyor?"

[[deyim:hr043_el_kaldirmak]] "Bazen biz tamamlıyoruz. Ama kafamızdan." Sınıf güldü.
---
@omurga
"O hâlde bilmediğimiz kısmı araştırmadan kesin konuşmayacağız," dedi öğretmenleri.

Nehir yine de kulenin ışığını unutamıyordu. Ertesi akşam balkondan baktığında ışık bir kez daha yandı. Bu kez saatini not etti ve annesiyle birlikte görüntünün kısa bir videosunu çekti. Videoda uzaktaki kule görünüyordu ama ışığın niçin yandığı belli değildi. Nehir kameranın sınırlarını da fark etti: Bir görüntü, her sorunun cevabı değildi.

Şenlikten bir gün önce sınıf içinde küçük bir tartışma yaşanmıştı. Tuna, hava tahmininin bazen tutmadığını söyleyerek uyarılara hiç güvenmemeyi savunuyordu. Defne ise bir tahminin olasılık bildirdiğini, bu yüzden gerçekleşmeyen bir olayın bütün tahmin yöntemlerini geçersiz kılmayacağını anlattı. Meryem Hanım çocuklardan iki cümleyi karşılaştırmalarını istedi: "Mutlaka yağmur yağacak" ve "Sağanak olasılığı bulunuyor." Nehir ikinci cümlenin daha doğru olduğunu söyledi; kesinlik bildiren sözcükler farklı kararlar doğurabilirdi. Öğretmenleri bunun üzerine kısa bir etkinlik yaptırdı. Çocuklar meteoroloji bültenlerindeki "olası", "bekleniyor", "yerel" gibi sözcükleri işaretledi. Tuna sonunda "Demek hava tahmini kehanet değil," dedi. Sınıf güldü. Meryem Hanım, "Evet, bilimsel verilere dayalı bir değerlendirme," diye tamamladı.
---
@omurga
Cuma sabahı hava açık başladı. Okul bahçesindeki masalara kitaplar dizildi, öğrencilerin yaptığı afişler asıldı. Nehir görevlilerden biriydi. Ancak öğleye doğru rüzgâr kuvvetlendi. Hafif afişler sallanıyor, bazı bulutlar kısa sürede çoğalıyordu. Meryem Hanım, okul idaresiyle birlikte güncel hava uyarılarını kontrol etti.

Şenliğin açık hava bölümü ertelendi. Bazı öğrenciler üzüldü. Tuna, "Belki yağmur yağmayacak. Boşuna hazırlanmış olduk," dedi.

Nehir, "Belki yağmaz," diye cevap verdi, "ama uyarı varsa önlem almak doğru. Bütün masaları içeri taşıyabiliriz."

Masalardan birinin üzerinde, geçen yılki öğrencilerin hazırladığı çizim kitabı duruyordu. Nehir onu almak için geri dönecekti ama öğretmeni bahçedeki görevin sona erdiğini söyledi. Bir görevli kitabı güvenle içeri getirdi. Nehir önce kendi başına çıkabileceğini düşünmüştü. Sonra kararın neden yetişkinler tarafından verildiğini hatırladı; sert hava koşullarında kontrolsüz hareket etmek yeni riskler oluşturabilirdi. İçeri girdiklerinde başka bir sınıfın üzgün öğrencileriyle karşılaştılar. {yoldas:yalin|bir arkadaş}, "Şenlik iptal olmadı, sadece yer değiştirdi," dedi. Tuna ve arkadaşları masaları yeniden kurdu; kitapların yanına bulut çizimleri asıp salonu küçük bir bilim müzesine çevirdiler. Böylece herkesin emeği değerlendi.
---
@omurga
Çocuklar öğretmenlerin yönlendirmesiyle kitapları kapalı salona taşıdı. İçeri taşınan masaların biri diğerlerine göre ağırdı. Nehir önce onu tek başına kaldırmayı denedi, sonra öğretmeninden yardım istedi. Birlikte taşırken "Bugün yalnızca hava değil, ekip çalışması da öğrendik," diye şaka yaptı. Tuna kütüphane kitaplarının ıslanmadığını görünce rahatladı. Çünkü bir ay boyunca resimledikleri öyküleri ilk kez ziyaretçilere gösterecekti.

Kısa süre sonra yağmur başladı. Pencereden dışarı bakarken sert damlaların bahçedeki boş masalara vurduğunu gördüler. Eşyalar zarar görmemiş, öğrenciler içeride güvendeydi.

Tuna Nehir'e dönüp "Ben yalnızca şimdiki güneşe baktım," dedi. "Sen sonraki saatleri de düşündün."
---
@omurga
Tuna o gün Nehir'le birlikte salonun penceresinden bahçeyi izledi. Yağmurdan sonra rüzgâr hafifledi, bulutların bir kısmı dağıldı. Tuna "Şimdi dışarı çıkabiliriz," dedi. Nehir, etkinliğin yeniden dışarı taşınıp taşınmayacağına öğretmenlerinin karar vereceğini hatırlattı. Çünkü hava yalnızca o anda pencereden görünen manzaradan ibaret değildi. Okul yönetimi etkinliği içeride sürdürmeyi uygun buldu. Bu karar ilk başta bazılarına gereksiz göründü ama içerideki program da çok güzel geçti. Çocuklar çizimlerini korumuş, misafirler rahatça kitapları incelemişti. Tuna, bir günün başarılı olması için bütün planların ilk biçimiyle gerçekleşmesinin gerekmediğini anladı.

"Aslında bunu öğretmenimiz ve uzmanların uyarısı sayesinde yaptık," diye karşılık verdi Nehir.

Meryem Hanım çocuklardan günün sonunda bir karşılaştırma yapmalarını istedi. Sabah planlanan şenlikle gerçekleşen şenlik arasında hangi farklar vardı? Nehir masaların yerinin değiştiğini, Tuna bazı oyunların içeride oynanabildiğini, Defne ise kimi süslemelerin kaldırıldığını yazdı. Fakat ortak amaç değişmemişti: Öğrencilerin hazırladığı kitapları ve çizimleri paylaşmak. Nehir, bir planı uyarlamanın vazgeçmek anlamına gelmediğini fark etti. Sınıfın küçük gazetesi için yeni bir başlık buldu: "Yağmurlu Günün Kitap Şenliği."
---
@omurga
Şenlik içeride devam etti. Çocuklar kitaplarını anlattı, hazırladıkları hava gözlem tablosunu misafirlere gösterdi. {yoldas:yalin|bir arkadaş} masaya, "Hava bir sır saklamaz; sadece onu anlamak için veri gerekir," yazılı küçük bir kart koydu.
---
@omurga
Nehir belediyeye soruyu yöneltirken annesinin yardımını almıştı. Başvuruda kişisel bir şikâyet değil, gözlemlenen ışığın hangi amaçla kullanıldığını öğrenmek istediklerini açıklamıştı. Yanıt kısa ama anlaşılırdı; ilgili birim, tesisin bakım kontrolleri hakkında genel bilgi vermişti. Nehir metni sınıf panosuna olduğu gibi asmak yerine öğretmeniyle birlikte özetledi. Kurum adını, yanıtın tarihini ve sorulan soruyu da eklediler. Böylece arkadaşları bilgiyi nereden öğrendiklerini görebilecekti. {yoldas:yalin|bir arkadaş}, "Keşke ışığın mors alfabesiyle mesaj verdiği doğru çıksaydı," diye şaka yaptı. Defne, "O zaman da bunu kanıtlamak gerekirdi," dedi.

Hafta sonunda belediyeden yanıt geldi. Yenilenen kuledeki ışık, bakım sırasında belirli aralıklarla yapılan bir ekipman kontrolünün parçasıydı. Kule, hava verilerini ölçen sistemlerden birini barındırıyordu. Işık, Nehir'in düşündüğü gibi insanları doğrudan uyaran bir mesaj değildi. Yine de kule, hava gözlemi için önemliydi. {isaret:bulut}
---
@omurga
"Aslında çocukken ben de bulutların her şeklini bir işaret sanırdım," dedi öğretmenleri. "Hayal kurmak güzeldir. Bilim yaparken ise hayalimizin hangi bölümünün kanıtlandığını bilmemiz gerekir." {yoldas:yalin|bir arkadaş} bu sözlere sevindi. Gizemli öyküler yazmaktan vazgeçmeyecekti. Sadece bilim gözlemleriyle kurmaca hikâyeleri birbirine karıştırmamayı öğrenecekti.

{yoldas:yalin|bir arkadaş} biraz utanarak, "Ben onu gizli bir istasyon sandım," dedi.

Defne gülümsedi. "Aslında istasyon kısmını doğru tahmin etmişsin. Gizli kısmını kanıtlamamıştık."

Öğretmenleri raporlarını üç bölüme ayırmalarını istedi: Ne gördük? Ne düşündük? Ne öğrendik? Defne yazıyı yüksek sesle okuyunca bir cümlede tarih eksik olduğunu fark ettiler. Hemen eklediler; çünkü bir gözlemin ne zaman yapıldığı, ne görüldüğü kadar önemliydi.

Nehir ilk bölümde gece görülen ışığı, ikinci bölümde olası açıklamaları, üçüncü bölümde ise doğrulanmış bilgiyi yazdı. {yoldas:yalin|bir arkadaş}, kanıtlanmayan fikrini silmek yerine yanına "ilk varsayım" notu düştü.
---
@omurga
Nehir okul gazetesine bir yazı hazırladı. İlk başlığı "Kulede Gizli Alarm!" olmuştu. Defne bunun gerçekte bulunmayan bir tehlike duygusu yaratacağını söyledi. Nehir başlığı "Eski Kulenin Yeni Görevi" olarak değiştirdi. Yazısına ışık hakkında öğrendiklerini, resmî hava uyarılarına nasıl ulaşabileceklerini ve alınan önlemlerin önemini ekledi. Yazı yayımlandığında en çok sorulan soru "Kuleye nasıl gireriz?" değil, "Hava tahmini ne kadar önce hazırlanır?" olmuştu.

Sonraki hafta kule yine ışık verdiğinde Işığı gördüğü ilk gün gözlemini kaydetmeseydi hangi ayrıntıları hatırlayıp hangilerini unutacağını düşündü. Küçük notların büyük yanlış anlamaları önleyebildiğini fark etti. Bundan sonra şaşırdığı her şeyi önce dikkatle gözlemlemeye karar verdi.

Nehir artık korkmadı. Ama bu kez yalnızca kuleye bakmadı; telefonundaki resmî hava tahminlerini ve gökyüzündeki bulutları da karşılaştırdı. İnsanların hava hakkında sorular sormasının, geçmişteki basit gözlemlerden bugünkü gelişmiş ölçümlere kadar uzanan büyük bir öğrenme yolculuğu olduğunu düşündü.
---
@omurga
Nehir eve döndüğünde balkonundan kuleyi yeniden gördü. Artık ışığa bakınca aklına yalnızca gizem gelmiyordu; orada çalışan görevlilerin emeğini de düşünüyordu. Bir veri işlenmeden, kontrol edilmeden ve doğru zamanda paylaşılmadan insanların karar vermesine yardım etmeyebilirdi. Bu farkındalıkla sınıf panosunda kendi adının çok büyük yazıldığını fark etti ve yanına {yoldas:yalin|bir arkadaş} ile Defne'nin adlarının da aynı boyda yazılmasını istedi. Çünkü bütün araştırmayı birlikte yürütmüşlerdi. Hatta kulenin işlevini öğrenmelerini sağlayan uzmanların adını da kaynak bölümüne eklediler. Nehir bilimi tek başına parlak bir fikir bulmak değil, farklı insanların ortak dikkati olarak görmeye başladı.

Son kez kuleye bakan Nehir, ilk günkü korkusunu hatırladı. Bir ışığın neden yandığını bilmemek, onu hemen tehlike saymayı gerektirmiyordu. Doğru kaynakları araştırmak, hem merakı koruyor hem de gereksiz korkuyu azaltıyordu. Sınıf arkadaşlarının da bunu anlamasını istiyordu.
---
@omurga
Defterinin son sayfasına şunu yazdı: Her ışık bir mesaj olabilir; ama hangi mesaj olduğunu ancak doğru kaynaklarla anlayabiliriz. Altına bir kule, bir bulut ve küçük bir soru işareti çizdi. Çünkü ona göre iyi bir araştırmacının çantasında üç şey bulunmalıydı: dikkatli gözler, sabırlı bir akıl ve yeni sorular.
