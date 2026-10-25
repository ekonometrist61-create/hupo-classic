---
baslik: "Robot Kentin Son Ağacı"
slug: "hr080-robot-kentin-son-agaci"
fis_kodu: "HR-080"
tur: bilim_kurgu
konu: kent_agac_tasarim_veri
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Robot en kısa yolu gösteriyor, ama çınar ağacının kökleri o yolun altında. Kent planı kimin ihtiyacına göre çizilmeli?"
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
    - {id: golge_hr080, tur: lexeme, etiket: "gölge", yuva: hr080_golge, islev: first_hint}
    - {id: kok_hr080, tur: lexeme, etiket: "kök", yuva: hr080_kok, islev: application}
    - {id: deyim_hr080, tur: idiom, etiket: "Dikkat çekmek", yuva: hr080_dikkat, islev: application}
    - {id: kavram_hr080, tur: concept, etiket: "Veri ile kullanıcı görüşü ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Ağacın dalları nereye uzanmıştı?", secenekler: [{id: A, metin: "İki binanın arasına"}, {id: B, metin: "Kaldırımın altına"}, {id: C, metin: "Meydanın ortasına"}, {id: D, metin: "Nehrin üzerine"}], dogru: A, aciklama: "Ağacın dalları iki binanın arasına uzanmıştı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Yoldaşın projeyle ilgili uyardığı risk neydi?", secenekler: [{id: A, metin: "Bütçenin yetmemesi"}, {id: B, metin: "Robotların bozulması"}, {id: C, metin: "Yaya yollarının kapanması"}, {id: D, metin: "Ağaca zarar verme riski"}], dogru: D, aciklama: "Çizilen en düz yol kök bölgesinden geçtiği için ağaca zarar verme riski vardı."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 8, metin: "Rota'nın yanıtına göre sorun neydi?", secenekler: [{id: A, metin: "Robot bozulmuştu"}, {id: B, metin: "Koruma sınırı bilgisi eksikti; veri yetersizdi"}, {id: C, metin: "Harita çok büyüktü"}, {id: D, metin: "Çocuklar yanlış soru sormuştu"}], dogru: B, aciklama: "Sistem, eksik veriyle yetersiz bir öneri sunabilir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 5, metin: "Metinde geçen gölgelik alan ne anlama gelir?", secenekler: [{id: A, metin: "Su birikintisi"}, {id: B, metin: "Bir tür bisiklet yolu"}, {id: C, metin: "Güneşten korunmayı sağlayan, gölge veren alan"}, {id: D, metin: "Kapalı bir oda"}], dogru: C, aciklama: "Gölgelik alan, güneşin etkisini azaltan alandır."}
deyim_cumleleri:
  hr080_dikkat: "Çocuklar bunun üzerine şehrin ağaç bakım planına dikkat çekti."
---
@omurga
Nova Kent'te kaldırımları robotlar temizler, otobüsler yoğunluğu hesaplayarak seferlerini ayarlar, binaların ışıkları gün boyunca enerji tüketimini denetlerdi. Şehrin planı öyle düzenliydi ki sokaklarda rastgele duran bir banka rastlamak neredeyse imkânsızdı. Ancak bu mükemmel çizgilerin arasında, eski meydanın kenarında kocaman bir çınar ağacı vardı. Ağacın {kelime:hr080_kok} kaldırımı hafifçe kabartmış, dalları iki binanın arasına uzanmıştı. {isaret:orman}

Altıncı sınıf öğrencisi {kahraman}, her gün okuldan dönerken ağacın {kelime:hr080_golge} dururdu. Arkadaşı {yoldas:yalin|bir arkadaş} doğrudan eve gider, “On dakika kaybediyorsun,” diye takılırdı. {kahraman} ise o on dakikada şehrin gürültüsünden uzaklaştığını söylerdi. Bir gün akıllı bilekliğinde sıcaklık uyarısı göründü. Şehirde hava çok sıcaktı. Meydanın açık kısmından geçince güneş yüzünü yakar gibi hissettirdi. Çınarın altına geldiğindeyse rüzgâr biraz daha serin esiyor gibi geldi.
---
@omurga
O sırada ağacın çevresinde üç bakım robotu durdu. Gövdelerindeki ışıklar art arda yanıp sönüyordu. En öndeki robot, “Yeni yaya düzenlemesi için geçiş alanı gerekiyor,” dedi. “Eski ağacın çevresindeki yol sınırları uygun değil.” {kahraman} irkildi. “Yoksa çınarı mı kaldıracaksınız?” Robot, “Plan henüz onaylanmadı,” diye cevap verdi. {kahraman} rahatlamadı. Şehrin yeni planında ağaç küçük gri bir işaret olarak görünüyordu.

{yoldas:yalin|bir arkadaş} akşam okul projesi için bu planı açınca asıl meseleyi fark etti. Şehir yönetimi meydandan geçen araçları azaltmak, yaya yollarını genişletmek istiyordu. Bu iyi bir amaçtı. Ancak çizilen en düz yol, çınarın kök bölgesinden geçiyordu. Projeyi değiştirmeden uygulamak, ağaca zarar verme riski taşıyabilirdi. {kahraman}, {yoldas:yalin|bir arkadaş} ve arkadaşları Erva, çözüm aramak için okulun kent tasarımı kulübüne başvurdu.
---
@omurga
{kahraman} ağacın çevresinde yeni yol planı yapılacağını duyunca internette çok çarpıcı bir paylaşım gördü: “Nova Kent doğayı tamamen yok ediyor!” Görselde gri binalar arasında tek bir ağaç kalmıştı. {yoldas:yalin|bir arkadaş} hemen paylaşmak istedi. Erva ise görselin kaynağını sordu. Görüntünün başka bir şehirden alınmış eski bir tasarım çalışması olduğu anlaşıldı. {kahraman} öfkelendi; çünkü gerçek bir sorun varken yanlış resim kullanılması, konunun ciddiye alınmasını zorlaştırabilirdi. Üç arkadaş kendi fotoğraflarını ve doğrulayabildikleri bilgileri kullanmaya karar verdi. İlk adımları kent yönetiminin yayımladığı taslak planı okumak oldu. Böylece yalnız duydukları bir söylentiyi değil, gerçekten tartışılması gereken bir projeyi anlayabildiler.
---
@omurga
Taslak planda açıklayıcı işaretler vardı: yaya yolu, bisiklet yolu, bakım alanı, oturma noktası. {yoldas:yalin|bir arkadaş} ilk başta bütün çizgilerin kendiliğinden anlaşılır olduğunu sanmıştı. Erva, haritanın anahtarını gösterince bazı gri çizgilerin yeni duvar değil, mevcut yüzey sınırları olduğunu fark etti. {kahraman}, tek bir görseli yanlış yorumlamanın insanlarda gereksiz korku oluşturabileceğini düşündü. Bunun üzerine okul kulübü bir “Haritayı Okuma Günü” düzenledi. Öğretmenleri, planın farklı sürümlerini yan yana gösterdi. Çocuklar değişen unsurları işaretledi, ancak teknik konularda kendi tahminlerini uzman görüşü gibi sunmadı.

Ağacın köklerinin nasıl büyüdüğüne ilişkin bir kitap da okudular. {kahraman} daha önce ağaçların yalnız görünen gövde ve dallardan ibaret olmadığını biliyordu; ama köklerin çevredeki toprakla ilişkisini hiç böyle düşünmemişti. Selma Hanım, sağlıklı bir kök alanının korunması için uzman değerlendirmesinin gerekli olduğunu anlattı. Öğrenciler bir ağaca zarar vermemek için bile bazen çevresindeki toprağa dokunmamak gerektiğini öğrendi. Ağaca en çok değer veren kişinin mutlaka ona en çok yaklaşan ya da bir şey yapan kişi olmadığını fark ettiler.
---
@omurga
Kulübün öğretmeni Selma Hanım, ilk toplantıda bir soru sordu: “Ağacın şehrin son ağacı olduğundan emin misiniz?” {kahraman} şaşırdı. Meydandaki ağaç gerçekten tekti. Ancak bütün şehirde başka ağaç bulunup bulunmadığını bilmiyordu. Erva, kent haritasının yeşil alan katmanını açtı. Şehrin dış kesimlerinde parklar vardı; meydan çevresindeki yoğun yapılaşmada ise ağaç sayısı çok azdı.

“Başlığımızı değiştirelim,” dedi Erva. “Burası şehirdeki son ağaç değil, eski meydanda ayakta kalan tek büyük ağaç.” {yoldas:yalin|bir arkadaş}, bu uzun başlığın afişe sığmayacağını söyledi. {kahraman} gülümsedi. “O zaman hikâyemizin adı yine Son Ağaç olsun, ama içerikte neyi kastettiğimizi anlatalım.” Selma Hanım bu ayrımı beğendi. Dikkat çeken bir başlık seçmek mümkündü; yeter ki yanlış bir bilgiye dönüşmesin.

Çocuklar ağacın neden önemli olduğunu araştırmaya başladı. Çınarın gölgesi insanların dinlenmesine yardımcı oluyordu. Yapraklar, kuşlar ve bazı küçük canlılar için yaşam alanı oluşturuyordu. Ağaç ve çevresindeki toprak, kent ekosisteminin bir parçasıydı. Ancak {kahraman}, bunun ağacın her durumda tek başına bütün şehri serinleteceği anlamına gelmediğini öğrendi. Kentin sıcaklığı; binalar, yollar, gölgelik alanlar ve başka pek çok etkene bağlıydı.
---
@omurga
Selma Hanım, doğal ve yapay gölgeliklerin karşılaştırıldığı bir proje önerdi. Öğrenciler uzman gözetiminde, aynı günün belirli saatlerinde meydandaki farklı noktalarda güvenli sıcaklık gözlemleri yapacaktı. Bir yanda çınarın gölgesi, diğer yanda binanın gölgesi, başka bir noktada açık kaldırım vardı. Aletleri ve ölçüm yöntemlerini yetişkinlerin yönlendirmesiyle kullanacaklardı. Sonuçları tek günlük çalışma üzerinden bütün mevsime genellemeyeceklerdi.

Kulüpte hazırladıkları ilk çizim, kâğıt üzerinde çok güzel görünüyordu. Fakat {kahraman} yolu ağacın öteki yanına taşıyınca yaya geçidinin okul girişine uzaklaştığını fark etti. {yoldas:yalin|bir arkadaş}, en kısa yolu çizmekle en kullanışlı yolu çizmenin aynı şey olmadığını söyledi. Erva ise bir köşeye koydukları bankın engelli rampasının önünü kapattığını gördü. Üçü taslağı yeniden çizdi. Her düzeltme başka bir ayrıntıyı ortaya çıkarıyordu. Başlangıçta bunu bir başarısızlık gibi gördüler; sonra tasarımın deneme ve gözden geçirme gerektiren bir süreç olduğunu kabul ettiler.
---
@omurga
Asena Hanım onlara başka bir harita gösterdi: Kentin yağmur suyu akışını anlatan bir plan. Bazı sert yüzeylerden suyun hızla uzaklaştığını, daha geçirgen yüzeylerin farklı davranabildiğini söyledi. Ancak her alanda aynı malzemenin kullanılmayacağını; bakım, güvenlik ve yerel koşulların değerlendirilmesi gerektiğini açıkladı. {yoldas:yalin|bir arkadaş}, “O zaman gölge kadar yağmur suyu da önemli,” dedi. {kahraman}, ağacın çevresinin yalnız sıcak günlerde değil, yağmurda da nasıl kullanılacağını düşünmeleri gerektiğini anladı. Asena Hanım bu bağlantıyı beğendi ama herhangi bir uygulamanın mutlaka uzman tasarımı gerektireceğini hatırlattı.

Rota'nın ekranında iki seçeneği karşılaştırdılar. Birincisi çok kısa ama ağacın koruma alanına giriyordu. İkincisi daha uzun fakat güvenli geçiş ölçütlerine daha çok uyuyordu. Üçüncü seçenekse bazı yönlerden iyi, bazı yönlerden yetersizdi. Çocuklar bütün ölçütlere tek bir sayı vermenin zor olduğunu fark etti. {yoldas:yalin|bir arkadaş}, “Robot bize en kısa yolu söylerken hangisinin en iyi olduğunu da söylüyormuş gibi düşündüm,” dedi. Erva, “Oysa neyin önemli olduğuna önce biz karar veriyoruz,” diye karşılık verdi. Bu düşünce şehir planını okurken de günlük hayatlarında kullandıkları uygulamalara bakarken de işlerine yarayacaktı.
---
@omurga
Şehirde bakım robotlarına yardımcı olan küçük bir eğitim robotu vardı. Adı Rota'ydı. Öğrencilerin hazırladığı haritaları okuyabiliyor, rota seçenekleri gösterebiliyordu. {kahraman}, ona çınarın çevresinden geçen yeni yolu sordu. Rota ekranda düz bir çizgi gösterdi. “En kısa rota budur,” dedi. {yoldas:yalin|bir arkadaş}, “Ama kökler?” diye sordu. Robot, kök bölgelerine ait güncel koruma bilgisinin harita katmanında bulunmadığını söyledi.

Erva, “Demek sen ağacı görmüyor musun?” diye sordu. Rota, “Ağacın konumu kayıtlı, ancak koruma sınırı eksik,” dedi. Bu cevap çocukları şaşırttı. Robot yanlış bir hesap yapmış gibi görünüyordu; oysa kendisine verilen veriler eksikti. {kahraman}, bir sistemin ne kadar iyi çalışırsa çalışsın eksik bilgiyle yetersiz öneri sunabileceğini anladı.
---
@omurga
Kent yönetiminden Asena Hanım okul kulübünü ziyaret etti. Şehir planlamacısıydı. Çocukların hazırladığı soruları dinledi. “Ağaç hakkında karar verirken yalnız gövdesinin yerini düşünemeyiz,” dedi. “Kök çevresi, bakım gereksinimi, yaya güvenliği ve ekolojik değer de incelenir.” {kahraman}, “Yolu değiştirebilir miyiz?” diye sordu. Asena Hanım, bunun teknik inceleme gerektirdiğini ama alternatiflerin değerlendirilebileceğini söyledi. Çocukları yetişkinlerin karar vereceği konularda söz sahibi olmaya davet etti; planı tek başlarına değiştirmelerini istemedi.

Rota'ya güncellenmiş koruma alanı verildiğinde yeni rotalar oluşturuldu. Bunlardan biri biraz daha uzundu. {yoldas:yalin|bir arkadaş}, “Yüz metre fazlası insanları kızdırabilir,” dedi. {kahraman}, “Peki herkes için erişilebilir mi?” diye sordu. Yeni yolun yalnız uzunluğu değil, eğimi ve geçiş genişliği de önemliydi. Asena Hanım, çocukların bu noktayı sormasına sevindi. Bir ağacı korurken yayaların güvenli ulaşımını göz ardı etmek de iyi bir tasarım olmazdı.
---
@omurga
{yoldas:yalin|bir arkadaş}, Melek Hanım'ın anlattıklarından sonra kendi büyükbabasını düşündü. Büyükbabası uzun süre yürüyebiliyor ama dinlenecek güvenli bir yer bulamadığında yoruluyordu. Bu yüzden yeni plandaki bankları yalnız süs gibi değil, gerçek bir ihtiyaç olarak görmeye başladı. {kahraman} ise okuldan çıkan küçük çocukların yaya geçidinde görünür olmasının önemini düşündü. Kentin kullanıcıları yalnız yetişkinler değildi. Erva, kaldırım düzenlemelerinde farklı yaşların, bedenlerin ve hareket biçimlerinin birlikte ele alınması gerektiğini defterine yazdı.

Kulüp küçük bir görüşme çalışması yaptı. Öğrenciler sorularını öğretmenle hazırladı; karşılaştıkları insanlardan gönüllü olarak, kişisel ayrıntı toplamadan yanıt istedi. “Bu meydanı ne zaman kullanıyorsunuz?”, “Sizin için en zor yer neresi?”, “Nerede dinlenmek istiyorsunuz?” sorularını sordular. Çıkan cevaplar birbirinden farklıydı. Bazı insanlar gölgeyi, bazıları düz yolu, bazıları güvenli bisiklet geçişini önemsiyordu. Kimse bir tek kişinin yanıtını bütün kent adına sunmadı. Selma Hanım, küçük bir görüşme grubunun yalnız bir başlangıç sağlayacağını anlattı.
---
@omurga
Meydanın en yoğun olduğu saatte çocuklar güvenli bir noktadan insan akışını gözlemledi. Sabah işe yetişenler hızlı yürüyordu, öğleden sonra bazı aileler yavaş geçiyordu. Bu durum, kentin ihtiyaçlarının gün içinde bile değişebildiğini gösteriyordu. {kahraman} çınarın altında kitap okuyan çocuğun yerini işaretledi. {yoldas:yalin|bir arkadaş}, yeni yolun yakınından geçen bisikletleri gözlemledi. Erva, herkesin aynı çizgiden ilerlemediğini fark etti. Proje yalnız geometrik bir şekil değil, hareket eden ve farklı ihtiyaçları olan insanların buluştuğu bir yerdi.
---
@omurga
Çınarın altında her gün dinlenen yaşlı bir komşuları vardı: Melek Hanım. {kahraman} onunla konuşurken, buranın neden önemli olduğunu daha iyi anladı. Melek Hanım marketten dönerken oturup dinlenmeye ihtiyaç duyuyordu. Gölge olmasa yolu iki kez durarak geçmesi gerekebileceğini söyledi. Başka bir komşu, tekerlekli sandalyesiyle kabaran kaldırımdan geçmenin zor olduğunu anlattı. İkisi de farklı ihtiyaçlardan söz ediyordu; biri ağacın korunmasını, diğeri güvenli geçişi önemsiyordu.

{yoldas:yalin|bir arkadaş}, “Bu ikisinden birini seçmek zorundayız,” dedi. Erva ise “Belki aynı anda ikisini de iyileştirebiliriz,” diye düşündü. Çocuklar sorunların listesini çıkardı. Mevcut kaldırım dar ve bazı yerlerde engebeliydi. Gölge alanı değerliydi. Yakındaki metal bank öğle güneşinde fazla ısınıyordu. Rota'nın önerdiği en kısa yol da güvenli geçiş için yeterince iyi değildi.
---
@omurga
Asena Hanım, farklı çözüm seçeneklerini birlikte değerlendirmelerini istedi. Bir seçenek ağacın uzağından geçen yeni bir yoldu; başka bir seçenek yaya yolunun genişliğini ve oturma alanlarını yeniden düzenlemekti. Ancak uzman ağaç bakım ekibinin kök bölgesini incelemesi gerekecekti. Çocuklar çizimler yaptı, ölçüleri uzmanlar doğruladı, kullanıcıların görüşleri kaydedildi. Amaç, en güzel görünen resim değil, gerçekten işe yarayan bir plan hazırlamaktı.

{kahraman}, artık ağacı yalnız bir anı olarak görmüyordu. Onun çevresinde insanlar dinleniyor, kuşlar yaşıyor, su toprağa ulaşıyor ve çocuklar buluşuyordu. **Ağaç bir süs değildi; kent yaşamının parçasıydı**. Aynı şekilde kaldırım da yalnız bir çizgi değildi; herkesin güvenle kullanması gereken bir yoldu.
---
@omurga
Ölçüm günlerinden birinde {yoldas:yalin|bir arkadaş} aceleyle not aldığı sayıları karıştırdı. İki noktadaki ölçümlerin saatlerini ters yazmıştı. Bunun sonuca etkisi olabileceğini fark edince durumu öğretmene anlattı. Selma Hanım, eksik ya da yanlış kayıtları düzeltirken neyin değiştirildiğinin açıkça belirtilmesi gerektiğini söyledi. {yoldas:yalin|bir arkadaş} utandı ama hatayı saklamadı. Arkadaşları onun üzerine gitmek yerine kayıtları birlikte kontrol etti. Bu küçük olay, veri toplamanın sadece rakam yazmak olmadığını gösterdi. Bir ölçümün güvenilirliği, dürüstçe kaydedilip kaydedilmediğine de bağlıydı.

Erva ayrıca insanların gölgeyi nasıl hissettiğini sormanın ölçümden farklı olduğunu fark etti. Kimi insanlar daha serin hissettiklerini söylüyor, kimi ise rüzgârın olduğu yerleri tercih ediyordu. Bu deneyimler değerliydi ama sıcaklık ölçümleriyle aynı veri türü değildi. Çocuklar sunumlarında iki ayrı bölüm açtı: Ölçülen değerler ve kullanıcıların görüşleri. İkisini birbirine karıştırmadan birlikte göstermek daha açıklayıcı olmuştu. Asena Hanım, bu ayrımı kent tasarımında sık sık yapmaları gerektiğini söyledi.
---
@omurga
Öğrencilerin sıcaklık gözlem çalışmasında ilginç sonuçlar çıktı. Çınarın altındaki noktalarda bazı ölçümler açık alandan daha düşük görünüyordu. Ancak başka zamanlarda rüzgâr ve binaların gölgesi sonuçları etkiliyordu. {yoldas:yalin|bir arkadaş}, “Demek ağaç her zaman aynı derecede serinlik sağlamıyor,” dedi. Selma Hanım, bunun beklenebileceğini anlattı. Tek bir ölçüm, bütün koşulları açıklamazdı. Öğrenciler gün, saat ve hava durumunu kaydetmeye devam etti.

Erva, elde ettikleri değerleri çizgi grafiğine aktardı. {kahraman}, grafiğin dikey eksenine yanlış birim yazıldığını fark etti. Birimin yanlış olması, grafiğe bakan kişinin sonucu yanlış yorumlamasına yol açabilirdi. Düzelttiler. Sonra renkleri seçerken erişilebilirliği düşündüler; birbirine çok benzeyen renkler yerine farklı çizgi işaretleri kullandılar. Grafik güzel görünüyordu ama asıl önemli olan okunabilir olmasıydı.

{yoldas:yalin|bir arkadaş} toplantıda “Gölge iyi, yol da gerekli; ikisini de sağlayacak bir düzen kurulabilir,” dedi. Asena Hanım, “Bu bir tasarım hedefi,” diye yanıtladı. “Gerçekleşip gerçekleşmeyeceğini incelemek gerekir.” Çocuklar artık kesin sonuç yerine gerekçeli öneri vermeyi öğrenmişti. Hazırladıkları sunumda ölçüm sınırlarını, kullanıcı görüşlerini ve uzman incelemesi gereken noktaları ayrıca belirttiler.
---
@omurga
Sergi hazırlıkları sırasında {kahraman} bir afişe “Bir ağaç şehri kurtarır” başlığını yazdı. {yoldas:yalin|bir arkadaş} bunun fazla iddialı olduğunu söyledi. “Bir ağaç çok değerli olabilir,” dedi, “ama bütün şehir tek ağaçla değişmez.” Erva yeni bir başlık önerdi: “Bir ağacı korumak, daha iyi bir kent tasarımının başlangıcı olabilir.” {kahraman} önce bu cümleyi uzun buldu; sonra daha doğru anlatımın her zaman en kısa cümle olmadığını düşündü. Sonunda iki satırlı, büyük puntolu bir başlık yaptılar. Yanında hem ağacın gölgesini hem de güvenli yürüyüş yolunu gösteren bir çizim vardı.

Sunumu gezen bir mühendis, çocuklara bazı uygulamaların pahalı olabileceğini sordu. {yoldas:yalin|bir arkadaş}, “Bunu hesaplamadık,” dedi. {kahraman} de bütçe konusu olmadan tasarımın tamamlanmış sayılmayacağını kabul etti. Asena Hanım, planların maliyet, bakım ve uygulama süresi gibi koşullarla birlikte değerlendirildiğini anlattı. Çocukların hazırladığı öneriler, bütün teknik soruları çözmüyordu; ama doğru soruların sorulmasına yardım ediyordu. Bu ayrım, kendi çalışmalarına duydukları gururu azaltmadı. Aksine ne yaptıklarını ve neyi yetişkin uzmanlara bıraktıklarını daha iyi açıklayabiliyorlardı.
---
@omurga
Kent yönetiminin karar günü gelmeden önce {kahraman} küçük bir maket yaptı. Kartondan binalar, renkli kâğıttan yollar, kumaş parçalarından gölgelikler yerleştirdi. Çınarın yerini göstermek için kuru bir dal kullanmak istedi ama sonra ağacın gerçek büyüklüğünü temsil etmeyecek kadar küçük olduğunu fark etti. Ölçek konusu ona düşündüğünden zor geldi. {yoldas:yalin|bir arkadaş}, sınıfın matematik öğretmeninden yardım istemeyi önerdi. Öğretmen, gerçek uzunluklarla maket uzunluklarının orantılı olması gerektiğini anlattı. Çocuklar önce ölçek belirledi, sonra çizimlerini yeniden düzenledi. Böylece bir fikri anlatmanın yalnız güzel bir resim yapmak değil, ölçüye dayalı doğru bir temsil kurmak olduğunu öğrendiler.
---
@omurga
Maketin ilk denemesinde robot araçların yolunu çizerken çocukların yürüyüş alanını fazla dar bıraktılar. Erva bunun nedenini sordu. {yoldas:yalin|bir arkadaş}, Rota'nın en kısa güzergâhını makete olduğu gibi aktardığını itiraf etti. {kahraman}, “En kısa yol en iyi yol olmayabilir,” diye hatırlattı. Robotun önerisi önemliydi ama tartışılmadan uygulanacak bir karar değildi. Makette birkaç değişiklik yaptılar. Sonunda yalnız ağacı korumaya değil, herkesin güvenle ilerlemesine de dikkat eden yeni bir seçenek ortaya çıktı. Asena Hanım taslağı incelediğinde bunu nihai proje gibi sunmadı; fakat öğrencilerin dikkate aldığı ölçütleri başarılı buldu.
---
@omurga
Bir ay sonra kent yönetimi yeni meydan planını tanıttı. Ağaç uzmanlarının görüşü alınmış, köklerin korunacağı bir alan belirlenmişti. Yaya yolu yeniden düzenleniyor, engellere neden olan bazı eski parçalar güvenli biçimde onarılıyordu. Ayrıca uygun noktalara yeni ağaçlar dikilmesi ve bunların uzun dönem bakımının planlanması önerilmişti. Çınarın korunması tek başına bütün çevre sorunlarını çözmeyecekti; ancak daha iyi bir başlangıç olabilirdi.

Rota'nın ekranında artık ağacın çevresindeki koruma alanı görünüyordu. Robot, en kısa yolu değil, belirlenen güvenli koşulları karşılayan seçenekleri sıralıyordu. {yoldas:yalin|bir arkadaş}, “Sen de ağacı sevmeyi öğrendin mi?” diye sordu. Rota, “Sevmek bir insan deneyimidir,” diye yanıtladı. “Ben güncellenmiş veriler ve kurallar çerçevesinde rota öneriyorum.” {kahraman} bu cevabı beğendi. Robotun insan gibi duygu taşıdığını düşünmek hoş bir hikâye olabilirdi; ama gerçek kararlar için nasıl çalıştığını bilmek daha önemliydi.
---
@omurga
Şehrin öğrencileri son projelerini okul şenliğinde sergiledi. Bir tarafta çınarın fotoğrafı, diğer tarafta eski ve yeni yaya yolu çizimleri vardı. Merak eden çocuklar sıcaklık grafiklerini inceliyor, doğal ve yapay gölge alanlarının farklı özelliklerini tartışıyordu. Melek Hanım sergiye geldiğinde {kahraman:yonelme} teşekkür etti. Tekerlekli sandalye kullanan komşuları da yeni çizimdeki geçişleri görünce birkaç soru sordu. Çocuklar hiçbirini kendileri cevaplayamadığında Asena Hanım'a yönlendirdi. Bilmedikleri bir konuda kesin konuşmak istemiyorlardı.

Bir akşam yağmur başlayınca {kahraman} pencerenin önüne oturdu. Damlalar asfaltın üzerinde küçük yollar oluşturuyordu. Ağaçların çevresindeki toprak bazı yerlerde suyu emiyor, sert yüzeylerde ise su daha hızlı akıyordu. {kahraman} gördüğünü hemen bilimsel sonuca çevirmedi. Sabah öğretmenine bu farkı anlattı. Selma Hanım, kentte yağmur suyu yönetiminin toprak, eğim, yüzey malzemesi ve altyapıyla ilişkili olduğunu açıkladı. Böylece {kahraman}, çınarın çevresinin yalnız güneşli günlerde değil, yağışlı zamanlarda da değerlendirilmesi gerektiğini düşündü. Yeni meydanın uzun ömürlü olması için farklı mevsimlerin etkisi hesaba katılmalıydı.
---
@omurga
{yoldas:yalin|bir arkadaş} bir soruyla ortaya çıktı: “Yeni dikilen fidanlar ne kadar zamanda gölge verir?” Kimse net bir yıl söyleyemedi. Tür, büyüme koşulları ve bakım gibi birçok etken vardı. Asena Hanım, mevcut büyük ağaçları korumanın değerini bu nedenle de düşündüklerini söyledi. Yeni ağaçlar dikmek, yetişmiş bir ağacın sağladığı bütün özellikleri hemen yerine koymuyordu.[[deyim:hr080_dikkat]] Gölgeyi yalnız bugünkü fotoğrafta değil, gelecek yılların yaşayan kentinde düşünmek gerekiyordu.

Nova Kent'teki toplantıda çocukların karşısına yeni bir zorluk çıktı. Bazı komşular yolun daha kısa olmasını istiyor, bazıları ağaç nedeniyle değişiklik yapılmasına gerek olmadığını savunuyordu. Asena Hanım bütün görüşleri not aldı. {kahraman}, kendi fikrini anlatırken karşısındaki insanların niçin farklı düşündüğünü sormayı denedi. Bir komşu sabah işe yetişmek için yolu sık kullandığını söyledi. Başka biri, yeni çizimdeki bankın kendi evinin önüne fazla yakın olmasından kaygı duyuyordu. {kahraman}, bu soruların hiçbirini hazırladığı güzel resimle tek başına çözemezdi. Planın tartışılması gerektiğini kabul etti.
---
@omurga
Toplantıdan sonra {yoldas:yalin|bir arkadaş}, “Herkes aynı fikirde olsaydı daha kolay olurdu,” dedi. Erva, “Kolay olurdu ama ihtiyaçların bir kısmı görünmez kalırdı,” diye karşılık verdi. {kahraman}, çınarı sevmesinin başkalarının sorunlarını geçersiz kılmadığını gördü. Bir ağacı savunurken bile insanları dinlemek gerekiyordu. Ertesi gün hazırladıkları sunuma bir bölüm eklediler: Henüz çözülmemiş sorular. Bu bölümde uygulama maliyetleri, uzun dönem bakım, yaya güvenliği ve yeni fidanların yaşayacağı koşullar bulunuyordu. Çocuklar bunları cevaplanmış gibi göstermedi. Bir projenin güvenilirliği, eksik kalan yanlarını saklamamasına da bağlıydı.

Sunum provasında Rota, projenin “başarı oranını” yüzde yüz olarak gösteren parlak bir simge çıkardı. {kahraman} bunun hoş görünse de doğru olmadığını söyledi. “Henüz bütün geçişleri denemedik, yeni fidanların yıllar sonraki durumunu da bilmiyoruz.” {yoldas:yalin|bir arkadaş} simgeyi değiştirdi: “Denendi”, “gözlenecek” ve “uzman görüşü gerekiyor” alanları ekledi. Erva, eksiklerin açıkça gösterilmesinin önerilerini zayıflatmadığını, aksine başkalarının katkı sunmasını kolaylaştırdığını fark etti. Yeni plan yalnız daha güvenli bir yol değil, düzeltmeye açık bir çalışma biçimi de öneriyordu.
---
@omurga
Sonbahar geldiğinde çınarın yaprakları sarıya döndü. {kahraman} eskisi gibi gölgesinde duramıyordu; artık hava serinlemişti. Yine de ağacın yanından geçerken bakmadan edemiyordu. Yeni yolun çevresi düzenleniyordu. Şehirde başka ağaçların yetişebilmesi için uygun alanlar ayrılmıştı. Her fidanın büyümesi zaman alacaktı; yalnız dikmek yetmez, korumak ve bakımını sürdürmek de gerekirdi.

{yoldas:yalin|bir arkadaş} bir gün okul çıkışında durup ağaca baktı. “Başta burayı yalnız on dakika kaybettiğin yer sanmıştım,” dedi. {kahraman} gülümsedi. “Ben de yalnız ağacı kurtarmamız gerektiğini düşünmüştüm. Sonra yoldan geçmeye çalışan insanları fark ettim.” Erva, “Demek ikimiz de haritanın tamamını görmüyormuşuz,” diye ekledi.

Rota yanlarından geçerken “Yeni rota: güvenli yaya geçişi” diye konuştu. {kahraman} robotun ekranındaki yeşil simgeye baktı. Şehir için hazırlanan yeni plan mükemmel olmayabilirdi; uygulandıkça tekrar değerlendirilmesi gerekebilirdi. Ancak artık planın üzerinde tek bir düz çizgi değil, insanların ve doğanın gerçek ihtiyaçları vardı.
---
@omurga
{kahraman}, projelerinin sonunda eski meydanın fotoğrafını çekti. Resimde yalnız çınar yoktu; bankta oturan insanlar, yürüyen çocuklar ve kaldırımda ilerleyen robot da görünüyordu. İlk gün aynı yere baktığında yalnız kesilme tehlikesini fark etmişti. Şimdi daha geniş bir hikâye görüyordu. {yoldas:yalin|bir arkadaş} fotoğrafın altına “Kent herkesin ortak alanıdır,” diye yazdı. Erva ise küçük bir düzeltme önerdi: “Kent bütün canlıların da yaşam alanıdır.” Üçü bu iki cümleyi yan yana koydu. Yeni planlarının anlatmak istediği şey tam da buydu. Teknoloji, doğa ve insanlar birbirinden kopuk değildi; iyi bir şehir tasarımı bu ilişkileri birlikte düşünmek zorundaydı.

Çocuklar yıl sonu sergisinde yalnız sonucu değil, yanlış çizimlerini de gösterdi. {yoldas:yalin|bir arkadaş} ilk makete bakıp güldü: “Ağacı korumaya çalışırken yolu unutmuşuz.” Erva, “Sonraki çizimdeyse yolu düzeltirken bankı yanlış yere koymuşuz,” dedi. {kahraman} bu hataları saklamadıkları için mutluydu. Çünkü her yeni deneme, başka bir ayrıntıyı görmelerine yardım etmişti.
---
@omurga
{kahraman} defterinin son sayfasına şunu yazdı: Teknoloji bize yollar gösterebilir; hangi yolu neden seçeceğimizi birlikte düşünmeliyiz. Sonra çınarın altında duran yeni bankı gördü. Bir çocuk orada kitabını okuyordu. Ağaç hâlâ yerindeydi. Fakat onunla birlikte değişen şey, insanların şehre bakış biçimiydi.
