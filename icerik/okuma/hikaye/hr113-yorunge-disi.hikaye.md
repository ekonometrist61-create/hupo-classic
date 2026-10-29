---
baslik: "Yörünge Dışı"
slug: "hr113-yorunge-disi"
fis_kodu: "HR-113"
tur: bilim_kurgu
konu: olasilik_risk_gerekce
sinif_alt: 8
sinif_ust: 8
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Bir uydunun yakın geçişinde {kahraman} ve ekibi belirsiz verilerle karar vermeyi öğrenir. Kesinlikten çok, kararın gerekçesi önemlidir."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 8
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, dayanisma]
  ders_baglantisi: [fen, matematik]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: belirsizlik_hr113, tur: lexeme, etiket: "belirsizlik", yuva: hr113_belirsizlik, islev: first_hint}
    - {id: model_hr113, tur: lexeme, etiket: "model", yuva: hr113_model, islev: application}
    - {id: olasilik_hr113, tur: lexeme, etiket: "olasılık", yuva: hr113_olasilik, islev: application}
    - {id: varsayim_hr113, tur: lexeme, etiket: "varsayım", yuva: hr113_varsayim, islev: transfer}
    - {id: deyim_hr113, tur: idiom, etiket: "Görmezden gelmek", yuva: hr113_gormezden, islev: application}
    - {id: kavram_hr113, tur: concept, etiket: "Belirsizlik altında karar vermek", islev: application}
  kanit_duzeyi: C
  program_surumu: "Önceki program (8. sınıf; geçiş dönemi, resmî program eşleştirmesi insan editörce yapılacak)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 2, metin: "Kırmızı noktanın adı neydi?", secenekler: [{id: A, metin: "Mirza-4"}, {id: B, metin: "K-17"}, {id: C, metin: "Arel-2"}, {id: D, metin: "K-71"}], dogru: B, aciklama: "Kırmızı noktanın adı K-17 idi."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Öğrencilerin ilk hatası neydi?", secenekler: [{id: A, metin: "Ekrandaki bir işareti bütün gerçeğin kendisi sanmak"}, {id: B, metin: "Kampın günlüğüne her gün yanlış bir tarih yazmak"}, {id: C, metin: "Uydunun adını kâğıda yanlış yazmak ve notları karıştırmak"}, {id: D, metin: "Yörünge çizgilerini sonradan kâğıda hiç aktarmamak"}], dogru: A, aciklama: "Öğrenciler, ekrandaki bir işareti bütün gerçeğin kendisi sanmışlardı."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 6, metin: "Selçuk Bey'e göre beklemek ne zaman bir karar olur?", secenekler: [{id: A, metin: "Her zaman, hiçbir koşul aranmadan"}, {id: B, metin: "Hiçbir zaman, ne bilgi gelirse gelsin"}, {id: C, metin: "Yalnızca uydu gerçekten zarar gördüğünde"}, {id: D, metin: "Koşulları ve neden beklediği bilindiğinde"}], dogru: D, aciklama: "Beklemek de, koşulları ve gerekçesi açıkça belirlenmiş bir karar olabilir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 1, metin: "Metinde “kurgusal” sözcüğü ne anlatır?", secenekler: [{id: A, metin: "Gerçek olmayan, eğitim amacıyla oluşturulmuş"}, {id: B, metin: "Çok eski ve uzun süredir bilinen bir durum"}, {id: C, metin: "Uzayda bulunan, gözle görülebilen bir nesne"}, {id: D, metin: "Hızlı hareket eden, yörüngede dönen bir uydu"}], dogru: A, aciklama: "Kurgusal, bu çalışmada eğitim için oluşturulmuş, gerçek olmayan nesneleri anlatır."}
  - {id: s5, beceri: degerlendirme, dayanak_sayfa: 15, metin: "Hikâyeye göre bir riski azaltmak ile bir kazayı kesin olarak önlemek arasındaki ilişki nedir?", secenekler: [{id: A, metin: "Riski azaltmak ile kazayı önlemek birbirinin aynısıdır"}, {id: B, metin: "Risk azaltılsa da kazanın kesin olarak önlendiği söylenemez"}, {id: C, metin: "Risk azaltılırsa kaza kesin olarak önlenmiş olur"}, {id: D, metin: "Riskin azaltılması, değerlendirmede hiçbir önem taşımaz"}], dogru: B, aciklama: "Riski azaltmak, gerçekleşmemiş bir kazanın kesin olarak önlendiği anlamına gelmez."}
deyim_cumleleri:
  hr113_gormezden: "“Çelişen veriyi görmezden gelip kesinlik gösteremeyiz,” dedi."
---
@omurga
Uzay Gözlem Merkezi'nin tavanı açıldığında ekrandaki Dünya ağır ağır dönüyordu. Mavi kürenin çevresinde ince çizgiler ve sayısız küçük işaret vardı. Bunların çoğu etkin uyduları, bazıları görevini tamamlamış araçları, bir kısmı ise izlenen uzay atıklarını temsil ediyordu. On dört yaşındaki {kahraman}, ışıklı işaretlerin arasında küçük kırmızı bir noktanın art arda yanıp söndüğünü görünce nefesini tuttu.

“Bu gerçek bir alarm mı?” diye sordu.

Merkez eğitmeni Selçuk Bey gülümsedi. “Gerçek verilere benzeyen bir eğitim senaryosu. Kontrol ettiğimiz uydular ve yörüngeler bu çalışmada kurgusal. Ama çözmeye çalışacağınız problem gerçek uzay araştırmalarının türünden.”

{kahraman:ilgi} yanında üç kişi vardı. Matematik yarışmalarını seven {yoldas:yalin|bir arkadaş}, {kelime:hr113_model} uğraşmayı seven Aras ve yeni okuluna henüz alışmakta olan Ceyda. Dördü, gençler için düzenlenen Yörünge Güvenliği Kampı'nda aynı ekibe seçilmişti. İki gün içinde simülasyondaki araştırma uydusunu, yakına gelmesi beklenen atık parçalarından koruyacak bir karar tasarlamaları gerekiyordu.
---
@omurga
Kırmızı noktanın adı K-17 idi. Küçük bir metal parçasını temsil ediyordu. Nokta, ekranda araştırma uydusu Mirza-4'ün yörüngesine yakın bir çizgi boyunca ilerliyordu. {kahraman} hemen, “Uydunun yönünü değiştirelim,” dedi. {yoldas:yalin|bir arkadaş} itiraz etti: “Önce gerçekten tehlike var mı, onu hesaplamalıyız.” Aras ise simülasyonun menüsünü inceliyordu. “Yön değiştirmek yakıt kullanıyor. Sonra istasyona gereken rota kalmayabilir.”

Ceyda tek bir soru sordu: “Kırmızı noktanın tam yerinden emin miyiz?”

Diğerleri durdu. Ekranın altında küçük bir ibare vardı: Tahmini konum — ölçüm belirsizliği içerir. İlk kararları henüz verilmemişti ama ilk hatalarını yapmaya çok yaklaşmışlardı: Bir işareti, bütün gerçeğin kendisi sanmışlardı.
---
@omurga
Selçuk Bey öğrencilere üç ayrı veri görünümü açtı. İlkinde cisimlerin yörünge çizgileri, ikincisinde hızları ve zamanları, üçüncüsünde ise konumların belirsizlik aralıkları gösteriliyordu. Gökyüzüne tek fotoğrafmış gibi bakıldığında birbirine dokunacak sanılan iki nokta, farklı zamanlarda farklı yerlerden geçebilirdi. Tersi de mümkündü: Haritada ayrı duran iki işaret, ileride aynı bölgeye yaklaşabilirdi.

{yoldas:yalin|bir arkadaş} çizgileri kâğıda aktardı. “Sadece yolların kesişmesine bakamayız. Orada ne zaman bulunacaklarını da bilmeliyiz.”

{kahraman} başını salladı. “O zaman saatleri eşleştirelim.”

Aras simülasyonun zaman kaydırıcısını hareket ettirdi. K-17'nin uydunun yakınından geçeceği bir an buldular. Yaklaşımın ne kadar yakın olacağını gösteren sayı her yeni ölçümle biraz değişiyordu. Ceyda bunun nedenini sordu. Selçuk Bey, uzaktan yapılan ölçümlerde hata payı bulunduğunu, bir cismin konumunun ve hızının daha iyi ölçüldükçe tahminin değişebileceğini anlattı.

“Yani yarın daha doğru bilgi gelebilir,” dedi Ceyda.

“Evet. Ama her kararı sonsuza kadar erteleyemeyiz. Bazı manevraların uygulanması zaman alır. Riskli durumlarda ne kadar bilgiyle ve ne zaman karar vereceğiniz önemlidir.”
---
@omurga
Öğrenciler ekip masasının üzerine dört kutu çizdi: Bildiğimiz, tahmin ettiğimiz, bilmediğimiz, karar vermek için gerekli olan. {kahraman} en çok üçüncü kutunun dolduğunu görünce ürktü. Daha önce bilimsel soruların doğru cevabını bulunca işin biteceğini düşünürdü. Burada ise hiçbir yanıt, sonraki gözlem olmadan kesinleşmiyordu.

O akşam kampın yemekhanesinde başka ekiplerin kararlarını öğrendiler. Bir takım, uydunun hemen manevra yapmasını önermişti. Başka biri, beklemenin en güvenli yol olduğunu düşünüyordu. {yoldas:yalin|bir arkadaş} karşılaştırma yaparken şöyle dedi: “İki ekipten biri cesur, diğeri korkak değil. Farklı risklere öncelik veriyorlar.” {kahraman} buna başta katılmadı. Sonra kendi aceleciliğinin de bir tercih olduğunu kabul etti.
---
@omurga
Ertesi gün Mirza-4'ün simülasyonunda küçük bir yakıt göstergesi belirdi. Uydunun sonraki aylarda yapmak zorunda olduğu bilimsel gözlemler için belirli bir hareket payı ayrılmıştı. Gereksiz bir manevra bu payı azaltabilirdi. Öte yandan yaklaşan bir atık gerçekten çarpışırsa görev sona erebilirdi. Her çözüm bir bedel taşıyordu; yalnızca bedellerin türü farklıydı.

Aras iki ayrı manevra seçeneği gösterdi. Biri erken ve küçük bir düzeltmeydi. Diğeri daha geç bir zamanda daha güçlü müdahale gerektiriyordu. Ancak bunlar gerçek bir uyduya uygulanacak hazır talimatlar değildi; eğitim senaryosunun sunabildiği seçeneklerdi. {yoldas:yalin|bir arkadaş}, “Erken hareket etmek her zaman daha mı iyi?” diye sordu. Selçuk Bey, “Hayır,” dedi. “Ölçüm belirsizliği, başka araçlarla etkileşim ve görev gereksinimleri nedeniyle kararın bütün bağlamı incelenir.”

Ceyda ekip tahtasına bir çizelge hazırladı. İlk sütunda olası faydaları, ikincisinde zararları yazdılar. Üçüncü sütununu boş bıraktı. {kahraman} nedenini sorunca, “Şu anda bilmediklerimizi de göstermeliyiz,” dedi. Sonra üçüncü sütuna büyük harflerle BİLİNMİYOR yazdı.
---
@omurga
{kahraman} buna itiraz etti. “Jüri önünde zayıf görünürüz.”

{yoldas:yalin|bir arkadaş}, “Bilmediğimizi saklamak, riski azaltmaz,” dedi.

Bir saat sonra kontrol odasından yeni simülasyon verileri geldi. İlk tahmine göre yakın geçiş tehlikesi küçülmüştü. {kahraman} rahatladı. Hemen manevrayı iptal etmeyi önerdi. Ceyda yine aynı soruyu sordu: “Yeni verinin {kelime:hr113_belirsizlik} ne kadar?” Gözlemlerin bir kısmı henüz birbiriyle uyumlu değildi. Tehlike tamamen ortadan kalkmış sayılmazdı.

{kahraman} sandalyesine yaslandı. Hızlı karar verebilmekle iyi karar vermek arasındaki farkı öğrenmeye başlamıştı. Yine de beklemek zor geliyordu. Sanki bir şey yapmamak, görevini yapmamakla aynıydı. Selçuk Bey onun yüzündeki sıkıntıyı görünce “Bir kararı ertelemek de koşulları belli bir karar olabilir,” dedi. “Önemli olan neden beklediğini ve hangi bilgi gelirse fikrini değiştireceğini bilmen.”
---
@omurga
Öğle arasında kontrol sistemi birkaç veri paketini geç gösterdi. Aras bunun bir yazılım hatası olduğunu düşündü; {yoldas:yalin|bir arkadaş} ise farklı ekranların zaman damgalarının karşılaştırılmasını istedi. İncelediklerinde iki simülasyon bileşeninden birinin başka bir zaman ayarıyla çalıştığını fark ettiler. Bu, K-17'nin öngörülen yakın geçiş saatini etkiliyordu. Hata bir alarm gibi bağırmıyor, yalnızca hesapların içine küçük bir kayma bırakıyordu.

“Bütün tabloyu yeniden kurmamız gerekiyor,” dedi {yoldas:yalin|bir arkadaş}. Sesinde öfke vardı. Öğleye kadar yaptıkları hesaplar şimdi işe yaramaz görünüyordu.

Aras savunmaya geçti. “Ben zaman ayarını değiştirmedim.”

“Kim değiştirdi demiyorum. Fark etmeliydin.”

{kahraman} araya girdi. “Ben de kırmızı noktayı görür görmez manevra demiştim. Herkes bir şeyi kaçırabilir. Önce hatayı düzeltelim.”

Ceyda, “Hatanın kimden kaynaklandığını değil, hangi sonuçları etkilediğini not edelim,” diye önerdi. Bu söz tartışmanın yönünü değiştirdi. {yoldas:yalin|bir arkadaş} bir süre sessiz kaldı, sonra Aras'tan özür diledi. Birlikte zaman verilerini eşleştirdiler. Yeni hesap, yakın geçiş tahminini tekrar değiştirdi. Şimdi daha az endişeliydiler, fakat önceki sonuçları neden değiştirdiklerini de açıklayabiliyorlardı.
---
@omurga
Selçuk Bey kontrol ederken “Bilimde bir düzeltme yapmak yenilgi değildir,” dedi. “Çoğu zaman güvenilir sonuca giden yolun parçasıdır.” {isaret:anahtar}

O akşam öğrenciler kamp günlüğüne bir hata kaydı yazdı. Aras sorunun nasıl anlaşıldığını çizimle gösterdi. {yoldas:yalin|bir arkadaş} eski ve yeni hesapların neden farklılaştığını anlattı. {kahraman}, ilk tepkisinin acelecilik olduğunu kabul etti. Ceyda ise hepsinin altına şu cümleyi ekledi: Hata düzeltme kaydı, sonraki ekibin aynı yanılgıya düşmesini önler.
---
@omurga
Senaryonun ikinci aşamasında yeni bir bilgi geldi. Mirza-4'ün manevra seçeneklerinden biri başka bir eğitim uydusunun planlanan hareketiyle çakışabilirdi. Bu yeni uyduya Arel-2 adı verilmişti. Ekip ilk kez yalnızca kendi araçlarını kurtarmanın yeterli olmadığını gördü. Bir manevra, başka araçlar ve gelecekteki görevler açısından da değerlendirilmeliydi.

{kahraman}, “Bize sadece Mirza-4'ü korumamız söylenmişti,” diye itiraz etti. Selçuk Bey, “Siz görevinizi böyle anladınız,” dedi. “Ama yörüngeleri paylaşan araçlar birbirinden bağımsız karar veremez.”

Boşlukta hareket eden iki uyduyu gösteren canlandırmaya baktılar. Simülasyon bütün nesneleri eksiksiz modellemiyordu; ekrandaki sonuçlar çalışmanın tanımladığı varsayımlara bağlıydı. {yoldas:yalin|bir arkadaş}, “Arel-2'nin ekibinden veri isteyebilir miyiz?” diye sordu. Gözlem merkezi bu imkânı açtı. Diğer ekip önce kendi planını değiştirmek istemedi; onların da bilimsel gözlem saatleri vardı.

Kısa bir görüntülü toplantı yaptılar. {kahraman} başta diğer ekibin onlara engel olduğunu sandı. Fakat onların raporunu dinleyince farklı bir şey gördü: Onlar da kendi uydularından sorumluydu. Ceyda karşı tarafın önerisini not etti, {yoldas:yalin|bir arkadaş} iki planın zaman çizelgesini yan yana koydu. Sonunda iki ekip, senaryo içinde yeni bir seçenek deneyebildi.
---
@omurga
Ortak planın herkes için kusursuz olmadığını biliyorlardı. Mirza-4'ün bir gözlem turu ertelenecekti. Arel-2 ise yakıt tasarrufundan biraz vazgeçecekti. Fakat iki görevin toplam riski daha iyi yönetiliyordu. {kahraman}, gerçek bir ekip çalışmasının herkesin ilk istediğini yapması demek olmadığını öğrendi. Bazen iyi karar, kimsenin tek başına seçmeyeceği ama birlikte açıklayabileceği bir çözümdü.
---
@omurga
Üçüncü gün sabahı simülasyonda Mirza-4'ün bağlantısı kısa süreliğine kesildi. Eğitim gereği yaşatılan bu iletişim boşluğu, öğrencilerin kontrol merkezindeki bütün ölçümlere anında ulaşamadığı bir durumu temsil ediyordu. {kahraman} karanlık ekrana bakıp, “Şimdi hiçbir şey yapamayız,” dedi. Selçuk Bey, “Bağlantı kesilince bütün bilgiler yok olmaz,” diye cevap verdi. “Son güvenilir veriler, önceden belirlenen güvenli davranışlar ve bağlantı geri geldiğinde yapılacak doğrulamalar vardır.”

Aras önceki kayıtları açtı. {yoldas:yalin|bir arkadaş} son ölçümlerin geçerlilik zamanını kontrol etti. Ceyda bildikleriyle varsaydıklarını iki ayrı kartta gösterdi. Böylece belirsizlik arttığında daha çok bağırmak yerine hangi bilginin hâlâ kullanılabilir olduğunu belirlemeye başladılar. {kahraman} bu kez kararın yazılı gerekçesini hazırladı: Bağlantı yokken yeni tahminlerle aşırı kesin hareket etmeyeceğiz; belirlenmiş güvenlik koşullarına göre bekleme ve yeniden değerlendirme yapacağız.

Bir saat sonra bağlantı geri geldi. Ekran yeni verilerle doldu. İlk kayıtları gördüklerinde göğüslerinden bir yük kalktı; fakat {yoldas:yalin|bir arkadaş}, “Önce saatler eşleşiyor mu?” diye hatırlattı. Önceki hatalarını unutmamışlardı. Yeni ölçümleri tek tek karşılaştırdılar, tutarsız noktaları işaretlediler. Risk tahmini bu kez manevra gerektirebilecek düzeyde görünüyordu. Artık eylem ve bekleme arasındaki tercih daha ciddiydi.
---
@omurga
Selçuk Bey, öğrencilerin vereceği kararın gerçek bir uyduya komut göndermeyeceğini tekrar belirtti. Bu yalnızca eğitim aracıydı. Buna rağmen {kahraman:ilgi} eli titredi. Çünkü sonucu ekrandaki sayıdan ibaret görmüyordu. Bir araştırma uydusunun uzun emeklerle hazırlanmış görevini korumak, henüz yapılmamış bilimsel gözlemleri de korumak demekti.

Ceyda masaya oturdu. “Bence önce kendimize soralım,” dedi. “Hangi sonuç çıkarsa kararımızı değiştireceğiz?” Bunu yazmadan harekete geçmek istemiyordu. Herkes bir koşul önerdi; kararları ilk kez yalnızca sezgiye değil, önceden açıklanmış gerekçelere dayanmaya başladı.
---
@omurga
{kahraman} ekranda parlak bir seçeneğe takıldı: Geniş kaçınma manevrası. Bu seçenek, Mirza-4'ü K-17'den uzak gösterecek kadar büyük bir değişiklik yapıyordu. Yalnızca kırmızı noktaya bakan biri için en güvenli yol gibi görünüyordu. Ancak programın ikinci görünümünde başka sonuçlar vardı: gelecekteki bilimsel gözlem planları bozuluyor, yakıt rezervi azalıyor ve yeni yörünge farklı nesnelerle yeniden değerlendirme gerektiriyordu.

“Yörünge dışına çıkmak her sorunu çözmüyor,” dedi Aras.

{yoldas:yalin|bir arkadaş} daha küçük bir manevra seçeneğini inceledi. Son ölçümlere göre simülasyondaki yakın geçiş riskini azaltıyor, fakat etkisinin doğru hesaplanması için yeni izleme gerektiriyordu. Ceyda riskin yalnızca tek bir sayı olmadığını hatırlattı. Hesaplara giren veri, belirsizlik ve başka araçlarla etkileşim birlikte değerlendirilmeliydi. Bir riskin “sıfır” olduğunu söylemek kolaydı; **bunu doğrulamak ise çoğu zaman mümkün değildi**.

Dört öğrenci bir karar notu yazdı. Not, önerdikleri sınırlı manevranın koşullarını, neden geniş manevrayı seçmediklerini ve komut uygulanmadan önce simülasyonda hangi kontrollerin yapılması gerektiğini içeriyordu. Selçuk Bey bir şey daha sordu: “Ya yeni veri, manevranın gereksiz olduğunu gösterirse?”
---
@omurga
“Önerimizi gözden geçiririz,” dedi {kahraman}.

“Ya manevra beklenenden az etkili olursa?”

“Yeni durumu doğrularız. Aynı planı inatla sürdürmeyiz.”

{kahraman} bu cümleleri söylerken iki gün önceki kendisini düşündü. Kırmızı noktayı görür görmez yön değiştirmek isteyen çocuğun yerinde şimdi kararını değiştirmeye de hazır biri vardı. Bu korkaklık değildi. Olasılıklar değişince gerekçeleri yeniden incelemek, sağlam düşünmenin bir parçasıydı.

Komutu simülasyona girdiklerinde kontrol ekranı birkaç saniye sessiz kaldı. Sonra yörünge çizgisi hafifçe kaydı. Kırmızı noktanın parlaklığı azaldı ama kaybolmadı. Mirza-4 çalışmaya devam ediyordu. Ekip sevinçle birbirine baktı; henüz sonuca değil, uygulanması gerekçelendirilmiş bir adıma ulaşmışlardı.
---
@omurga
Simülasyonun ertesi turunda yakın geçiş gerçekleşti. K-17, Mirza-4'e çarpmadı. Ekranda yeşil bir işaret belirdi; görev sürüyordu. {kahraman} sevinçle ayağa kalktı ama {yoldas:yalin|bir arkadaş} ona hemen bir soru sordu: “Manevra yapmasaydık da çarpışma olmayabilir miydi?”

{kahraman} oturdu. Riskin azaltılmasıyla gerçekleşmemiş bir kazanın kesin olarak önlendiğini söylemek aynı şey değildi. Bir çarpışma {kelime:hr113_olasilik} varsa ve çarpışma gerçekleşmemişse, tek sonuca bakarak seçilen kararın her koşulda en iyi karar olduğu çıkarılamazdı. Bu fikir ilk başta heyecanını azalttı. Sonra ona başka bir rahatlık verdi: Bilimsel değerlendirme, zafer ilan etmekten daha dürüst bir işti.

Selçuk Bey öğrencilerin raporlarını topladı. “Sadece uydunun kurtulduğunu yazarsanız eksik olur,” dedi. “Kararınızı hangi bilgiyle verdiğinizi ve hangi sınırlar içinde savunduğunuzu da anlatın.”

Aras sonuç bölümünde yakıt tüketimini simülasyon birimiyle belirtti. {yoldas:yalin|bir arkadaş} risk değerlendirmesinde kullanılan varsayımları sıraladı. Ceyda ekipler arası veri paylaşımının etkisini yazdı. {kahraman} ise iletişim boşluğunda nasıl davranacaklarına ilişkin önceden belirlenmiş koşulların önemini anlattı. Hiçbiri kendisini gerçek uzay görevlerini yönetebilecek bir uzman olarak tanıtmadı. Yaptıkları çalışma bir öğrenme deneyimiydi; değeri de sınırlarının açık olmasındaydı.
---
@omurga
Öğle yemeğinde Aras, “Ben sana biraz kırgındım,” dedi {yoldas:yonelme|bir arkadaşa}. “Saat hatasını benim yaptığımı sanmıştın.” {yoldas:yalin|bir arkadaş} başını eğdi. “Biliyorum. Özür diledim ama neden kızdığını da yeni anlıyorum.” {kahraman} iki arkadaşının konuşmasını bölmedi. Bir gün önce birbirine güvenmeyen insanların verileri paylaşmasının ne kadar zor olabileceğini düşünüyordu. Teknik güvenlikle insan ilişkileri birbirinden bütünüyle ayrı değildi.
---
@omurga
Eğitmenler öğrencilere aynı senaryonun farklı varsayımlarla hazırlanmış iki sürümünü verdi. Birincisinde K-17'nin hızına ilişkin belirsizlik daha küçüktü; ikincisinde daha büyüktü. Görüntülerin renkleri ve çizgileri neredeyse aynıydı. Ancak risk hesapları farklı sonuçlara ulaşıyordu. {kahraman} önce simülasyonun bozulduğunu sandı. {yoldas:yalin|bir arkadaş}, “Veriye bakmadan rengin bizi kandırmasına izin vermeyelim,” dedi.

Masaya iki tablo koydular. İlk tabloyu kullanan ekip erken manevra önermiş, ikincisini kullanan ekip yeni gözlem beklemeyi seçmişti. Her ikisi de kendi verisiyle gerekçeli bir karar vermişti. Sorun kimin daha zeki olduğunu bulmak değildi; hangi tablonun mevcut ölçümlere daha uygun olduğunu anlamaktı. Ceyda bu yüzden tablonun hazırlanma saatini, kaynak türünü ve belirsizlik açıklamasını da rapora eklemek istedi.

“Jürinin bu kadar ayrıntıya bakacağını sanmıyorum,” dedi Aras.

“Belki bakmaz,” diye cevap verdi Ceyda. “Ama biz bakmadan karar verirsek çizimin parlaklığına güvenmiş oluruz.”

Selçuk Bey sonuç tablolarının aynı soruya farklı koşullarda cevap verdiğini anlattı. Bir modelin sonucunu kullanmak için içine hangi {kelime:hr113_varsayim} konduğunu bilmek gerekiyordu. {kahraman} düşündü: Günlük hayatta da yalnızca sonuçları görüyordu. Hava tahminindeki yüzdelik bir ifade, okul anketindeki ortalama, bir haber başlığındaki sayı... Bunların her biri “nasıl hesaplandı?” sorusunu hak ediyordu.
---
@omurga
Akşam küçük bir çalışma yaptılar. Ceyda aynı sonucun iki farklı renkli grafikle nasıl farklı algılanabileceğini gösterdi. {kahraman}, “Demek risk iletişimi de güvenliğin parçası,” dedi. “Sayı doğru olsa bile onu yanlış anlatırsak insanlar yanlış anlayabilir.” {yoldas:yalin|bir arkadaş} bu cümleyi raporun girişine ekledi.
---
@omurga
Kampın açık oturumunda Selçuk Bey, uzay atıklarının neden yalnızca bugünkü görevlerin sorunu olmadığını tartışmaya açtı. Çalışan uyduların yanında görevini tamamlamış parçalar ve geçmiş olaylardan kalan cisimler de bulunuyordu. Büyük nesneler izlenebiliyor, çok küçük parçaların takibi ise daha zor olabiliyordu. Her şeyi eksiksiz görebilen sihirli bir ekran yoktu.

Aras, “O zaman eski uyduların hepsini hemen temizlesek?” dedi. Selçuk Bey bu işin karmaşık ve maliyetli olduğunu, bilim insanlarıyla mühendislerin güvenli tasarım, görev sonu planlaması ve atık azaltma üzerinde çalıştıklarını anlattı. {kahraman}, “Yeni bir görev tasarlarken eski görevlerden kalan sorunu büyütmemek de gerekli,” diye ekledi.

Ceyda tahtaya iki soru yazdı: Bugün neyi korumalıyız? ve Yarın ne bırakıyoruz? Bu soruları görünce {kahraman} kendi odasındaki kullanılmayan elektronik aletleri hatırladı. Uzayla doğrudan aynı şey değildi elbette, ama bir ürünün kullanım sonrası ne olacağını düşünmeden üretmenin nasıl sorun yaratabileceğini anlıyordu.
---
@omurga
Açık oturuma katılan başka bir öğrenci, “Uzay herkesin, bu yüzden sorumluluk da herkesin mi?” diye sordu. Selçuk Bey çok sayıda ülkenin ve kuruluşun uzay faaliyetleri yaptığını, iş birliği ve ortak ilkelerin önemini anlattı. Çocuklar kısa bir tartışma düzenledi. Kimi uzay araştırmalarının bilimsel yararını vurguladı, kimi kaynakların Dünya'daki sorunlara harcanması gerektiğini söyledi. {kahraman} iki tarafı da dinledi. Böyle bir tartışmada tek cümlelik bir zafer cevabı bulunmadığını gördü.

Günün sonunda ekip raporuna küçük bir bölüm ekledi: Önerimiz yalnızca bu yakın geçiş içindir. Uzay atığı sorununu çözmez. Yeni görevlerin sorumlu planlanması ve uluslararası bilgi paylaşımı ayrıca önemlidir. {kahraman} bu cümleden gurur duydu. Çünkü önerisini olduğundan büyük göstermeden savunabiliyordu.
---
@omurga
Simülasyonun kritik anından önce ekip üyelerine tek tek söz hakkı verildi. Amaç, seçilecek manevrayı bir kez daha açıklamaktı. Aras yakıt hesabının senaryo içindeki varsayımlara uygun olduğunu söyledi. {yoldas:yalin|bir arkadaş} en son kullanılan ölçüm kümesini ve belirsizliklerini belirtti. Ceyda kararın hangi veriler gelirse yeniden değerlendirileceğini anlattı. {kahraman} ise bütün görüşleri bir araya getirip karar notunu okudu.

Tam o sırada başka bir ekibin temsilcisi itiraz etti. “Siz manevra yaptıktan sonra bizim uydumuzun konum tahminini etkileyebilirsiniz. Bu durumda planınız gerçekten ortak plan mı?” {kahraman} kısa bir an öfkelendi. İki ekip zaten görüşmüştü; şimdi yine mi başa döneceklerdi? {yoldas:yalin|bir arkadaş} onu durdurdu. “Yeni itiraz eski görüşmeyi geçersiz kılmaz,” dedi. “Ama onu incelememiz gerekebilir.”

Arel-2 ekibinin en yeni ölçümlerini açtılar. Planlarının küçük bir bölümünü yeniden gözden geçirdiler. Karar saatine çok az kalmıştı. {kahraman} ilk kez zaman baskısının neden insanları kolay cevaplara yönelttiğini hissetti. Yine de sesini yükseltmedi.[[deyim:hr113_gormezden]] “Yalnızca son doğrulanmış koşullarda karar verebiliriz.”
---
@omurga
Selçuk Bey çalışmanın süresi dolduğunda tüm ekipleri durdurdu. Çocukların bazıları hâlâ tablolarını inceliyordu. “Gerçek dünyada da süre sınırı vardır,” dedi. “Soru şu: Sınırlı zamanda karar verebilmek için hazırlığı ne kadar önceden yaptınız?”

{kahraman} bunu duyunca ilk gün hazırladıkları dört kutuyu hatırladı. Başlangıçta boş görünen karar vermek için gerekli olan kutusu şimdi bir liste dolusuydu. Belirsizliği tamamen yok edememişlerdi; ancak belirsizlik karşısında ne yapacaklarını önceden düşünebiliyorlardı. Bu, bir ekibin kazanabileceği gerçek beceriydi.
---
@omurga
Final raporunda imzaları hangi sırayla yazacakları konusunda küçük bir tartışma çıktı. Aras modelin çoğunu kendisinin hazırladığını söyledi. {yoldas:yalin|bir arkadaş} hesabın büyük bölümünü yaptığını hatırlattı. {kahraman} raporu sözlü olarak onun sunduğunu belirtti. Ceyda ise sessiz kaldı. Sonunda hepsi Ceyda'ya baktı.

“Benim katkımı saymak kolay değil,” dedi Ceyda. “Çünkü çoğu zaman bir hesap yapmadım, soru sordum.”

{kahraman} utandı. En başından beri ekibin aceleci adımlarını durduran sorular Ceyda'dan gelmişti. Soru sormak, yapılan işi engellemek değil; yanlış yola sapmadan ilerlemelerini sağlamak olmuştu. {yoldas:yalin|bir arkadaş}, “O zaman raporu görev dağılımı olarak yazalım,” diye önerdi. “Kim ne yaptı, gösterelim. İmzaları da aynı sırada değil, yan yana atalım.”

Raporun sonunda dördü ayrı ayrı kısa değerlendirmeler yazdı. Aras, teknik bir modeli anlatmanın onu kurmak kadar önemli olduğunu söyledi. {yoldas:yalin|bir arkadaş}, doğru hesapların yanlış zaman bilgisiyle kullanıldığında değerini kaybedebileceğini anlattı. Ceyda, itirazların insanları küçümsemeden de yapılabileceğini yazdı. {kahraman} ise kendi ilk düşüncesini kaydetti: Kırmızı noktayı gördüm ve hemen kaçmak istedim.
---
@omurga
Bu cümleyi silmedi. Çünkü gelişimini göstermek için başlangıçtaki yanılgısını saklaması gerekmiyordu. Her öğrenci kâğıdın altına adını yazdı. Ekrandaki uyduya bir komut göndermişlerdi; gerçek hayatta ise birbirlerini dinlemeyi öğrenmişlerdi. {kahraman} o gün hangisinin daha zor olduğunu kesin olarak söyleyemiyordu.
---
@omurga
Bir öğleden sonra Selçuk Bey ekranları kapattı. Öğrenciler şaşkınlıkla birbirine baktı. “Bugün bilgisayardan önce kâğıt kullanacağız,” dedi. Masalara birer büyük karton, cetvel ve ip bıraktı. Her ekip, yörüngeyi bir çizgiyle temsil ederek yakın geçiş problemini sözlü biçimde açıklayacaktı.

{kahraman} ilk çizdiği resimde Dünya'nın çevresine kusursuz iki çember yerleştirdi. {yoldas:yalin|bir arkadaş}, “Gerçekte bütün yörüngeleri böyle göstermek doğru değil,” diye uyardı. Eğitmenleri çizimin yalnızca temel fikirleri anlatacağını, gerçek uzay hareketinin bundan çok daha karmaşık olduğunu hatırlattı. Böylece altına ölçekli değildir; öğretici şemadır yazdılar. Küçük bir uyarının, resmi inceleyenlerin onu yanlış anlamasını önleyebileceğini gördüler.

Ceyda bir ipin üzerine iki renkli düğüm bağladı. “Bunlar araçların belli andaki konumları olsun,” dedi. “Şimdi biri aynı noktadan erken, diğeri geç geçerse çarpışırlar mı?” Aras ipleri kaydırdı. “Hayır, yalnızca yolların kesiştiğini göstermek yetmez.” {kahraman} bu basit denemeyi sevdi. Ekranda sayılarla boğuşurken anlamını kaybettiği bir düşünce, kartonun üzerinde yeniden açık hale gelmişti.
---
@omurga
Öğretmenleri sıradaki soruyu sordu: “İkinci ipin düğümünün yeri tam bilinmiyorsa?” Ceyda düğümün yanına renkli bir bant bağladı. Bu, kesin konum değil, belirsizliği anlatan görsel bir işaretti. {kahraman} karar notunda yalnızca bir sayı değil, belirsizlik açıklaması da kullanacaklarını hatırladı.

Akşam kartonu çöpe atmadılar. Kampın fuayesinde küçük bir sergiye koydular. Yanına “Bu şema hesap yapmaz; soruyu anlamamıza yardım eder” yazdılar. {kahraman}, bazen teknolojiyi doğru kullanmanın ilk adımının onu birkaç dakikalığına kenara bırakmak olduğunu düşündü.
---
@omurga
Kamp sırasında yerel bir yayın organı öğrencilerin çalışmalarını haber yaptı. Başlıklardan biri şöyleydi: Gençler çarpışmayı önleyen kesin formülü buldu. {kahraman} bu başlığı görünce gülmekle kızmak arasında kaldı. Kesin formül bulmamışlardı; yalnızca varsayımları belirli bir simülasyonda gerekçeli karar geliştirmişlerdi.

Selçuk Bey gazeteye düzeltme göndermelerini önerdi. {kahraman} önce bunun gereksiz olduğunu söyledi. “Güzel bir şey yazmışlar,” dedi. Ceyda farklı düşündü: “Güzel görünmesi doğru olduğu anlamına gelmiyor. Başkaları da uzaydaki risklerin tek formülle çözüldüğünü sanabilir.”

Birlikte kısa açıklama yazdılar. Eğitim çalışmasının sınırlarını anlattılar; kullanılan uyduların kurgusal olduğunu, gerçek görevlerde uzman ekiplerin çok daha kapsamlı ölçümler ve prosedürler kullandığını belirttiler. Yayın organı başlığı düzeltti. Yazar, “İnsanların ilgisini çeksin istemiştik,” diye özür diledi. {kahraman}, ilginç olmakla doğru olmak arasında seçim yapmak zorunda olmadıklarını anlattı.

Sonra kampın internet sayfasında kendi çalışmaları için üç soru yayımladılar: Hangi veriye dayandık? Hangi varsayımları kullandık? Neyi henüz bilmiyoruz? Bu sorular başka ekiplerin de raporlarında yer aldı. {kahraman} bir gün haber okurken aynı soruları kendi kendine soracağına karar verdi.
---
@omurga
Dönüş yolculuğunda dört öğrenci yol üzerindeki dinlenme tesisinde mola verdi. Aras çantasından küçük karton modelini çıkardı; Ceyda düğümleri yeniden bağladı. O sırada yan masada oturan küçük bir çocuk merakla yaklaştı. “Bu bir oyun mu?” diye sordu. {kahraman}, “Hem oyun hem model,” dedi. “Bir şeyi anlamak için kullandığımız basit bir örnek.”

Çocuk kırmızı düğüme dokunmak istedi. {kahraman} izin verdi. Düğüm yer değiştirince {yoldas:yalin|bir arkadaş} şemayı yeniden kurdu. “Bak, bir işareti değiştirince sonuç da değişebilir,” dedi. Çocuk gülerek ipi eski yerine bıraktı. “O zaman doğru yeri bulmalıyız!”

“Evet,” dedi Ceyda, “ama bazen tam yerini bilemeyiz. O zaman bilmediğimizi de hesaba katarız.”

{kahraman}, küçücük bir çocuğa bu düşünceyi anlatmanın sayılarla dolu bir jüri sunumundan daha zor olduğunu fark etti. Buna rağmen açıklamayı basitleştirmek için gerçeği ters çevirmeleri gerekmiyordu. Kâğıttaki yörünge tam ölçü vermiyordu; ama doğru soruyu gösteriyordu.
---
@omurga
Otobüse döndüklerinde raporun kapağını yeniden açtılar. Dört kişinin adının yanında artık tek bir cümle vardı: Bir kararın değeri, yalnızca sonucun iyi çıkmasında değil, neden ve nasıl verildiğinin açıklanabilmesindedir. {kahraman} bu cümleyi içinden okudu. Yol boyunca gökyüzü mavi bir boşluk gibi görünüyordu. Fakat onun için bu boşluğun içinde artık sayılar kadar insanların sorumluluğu da vardı.
---
@omurga
Kampın sonunda her ekip üç dakikalık sunum yaptı. Kimi takım yakıt kullanımını azaltmış, kimi daha dikkatli bir gözlem planı hazırlamıştı. Ödüller açıklanmadan önce Selçuk Bey büyük ekrandaki mavi Dünya'yı gösterdi. “Bu görüntüye bakınca neler düşünüyorsunuz?” diye sordu.

“Evimi,” dedi Ceyda.

“Daha keşfedecek çok şey olduğunu,” dedi Aras.

“Düzenli görünen bir sistemde ne kadar belirsizlik bulunabileceğini,” dedi {yoldas:yalin|bir arkadaş}.

{kahraman} biraz durdu. “Aynı gökyüzünü paylaştığımızı,” dedi. “Bir uydunun güvenliği yalnızca onu kullananların sorunu değil. Başka araçlar, gelecekte yapılacak görevler ve hepimizin kullanacağı hizmetler de etkilenebilir.”

Çocukların raporu, kampın “kanıta dayalı ortak karar” ödülünü aldı. {kahraman} kupanın altındaki küçük yazıyı okudu. En iyi karar, her zaman en gösterişli hareket değildir. Ödül sevindiriciydi ama onun asıl hatırladığı şey {yoldas:ilgi|bir arkadaşın} saat hatası karşısında öfkelenmesi, Aras'ın buna verdiği tepki ve Ceyda'nın hiç acele etmeden sorduğu sorulardı. Çünkü risk tablosu yazmak başka, masanın etrafındaki insanlarla birlikte düşünmek başkaydı.
---
@omurga
Kampa giderken otobüste {kahraman:ilgi} kardeşi ona “Uzay çöpünü nasıl topladınız?” diye sordu. {kahraman} önce bir kahraman hikâyesi anlatmayı düşündü: bir düğmeye bastılar, uyduyu kurtardılar. Sonra başını salladı. “Toplamadık. Onunla olası karşılaşmayı simülasyonda değerlendirdik. Asıl mesele, bilmediğimizi de hesaba katmaktı.”

Kardeşi yüzünü buruşturdu. “Bu pek heyecanlı değilmiş.”

“Ekranda olunca heyecanlıydı,” dedi {kahraman}. “Ama güvenilir karar vermek için heyecanı bir süre kenara koymak gerekiyor.”
---
@omurga
Kampın son akşamında {kahraman} kendine küçük bir defter aldı. Kapağına İhtimaller yazdı. İlk sayfada “Kesinlikle olacak” diye düşündüğü fakat gerçekleşmeyen üç olay sıraladı: sınavda başarısız olacağı korkusu, arkadaşlarının onu dinlemeyeceği kuşkusu ve simülasyondaki kırmızı noktanın uyduya mutlaka çarpacağı düşüncesi. Sonra gerçekleşeceğinden emin olduğu halde değişen iki olayı yazdı. Hiçbirinin gerçekleşmemesi diğerlerini anlamsız kılmıyordu. Tahminler, ancak koşullarıyla ve sonuçlarıyla birlikte değerlendirildiğinde öğreticiydi.

Ceyda yanına gelip defteri gördü. “Bunun bir matematik defteri olacağını sanmıştım,” dedi. {kahraman}, “Biraz da öyle,” diye yanıtladı. “Ama rakamları doğru kullanabilmek için kendi aceleciliğimi de tanımam gerekiyor.”

Ceyda ilk sayfaya küçük bir not ekledi: Soru sormak zaman kaybı değildir. {yoldas:yalin|bir arkadaş} yanına “Ölçümün tarihini kontrol et” yazdı. Aras ise kendi cümlesini ekledi: Modelin çalıştığı koşulları unutma. Dört arkadaş sonunda ortak bir defter bırakmıştı. {kahraman} onu saklayacak, belki yıllar sonra kendi kararlarına dönüp bakarken ne kadar çok şeyi henüz bilmediğini hatırlayacaktı. Çünkü merak, yalnızca yeni bilgilere ulaşmak değil, bildiğini sandıklarını yeniden sınayabilmekti.
---
@omurga
Eve döndüğünde {kahraman} odasının tavanındaki eski yıldız çıkartmalarını gördü. Çocukluğunda gökyüzünü sabit bir desen sanırdı. Şimdi Dünya'nın çevresindeki uyduların hareketini, görevini bitirmiş araçları ve bir zamanlar küçücük diye önemsenmeyen metal parçalarını düşünüyordu. Gökyüzünün boş ve sahipsiz olmadığını anlamak onu ürkütmekten çok sorumlu hissettirdi.

Okulda kampı anlatması istendiğinde elinde bir yörünge çizimiyle tahtaya çıktı. Önce K-17'nin kırmızı işaretini gösterdi. Sonra yanına mavi bir alan çizdi. “Bu, kesin olarak bulunduğu yer değil,” dedi. “Ölçümlerden doğan belirsizliği anlatan eğitim resmi.” Öğretmeni küçük bir not ekledi: Gerçek uzay görevlerinde modellerin ve izleme yöntemlerinin çok daha karmaşık olduğu, bu resmin yalnızca temel düşünceyi göstermek için kullanıldığı belirtildi.

Bir öğrenci, “Madem sonuçta çarpmadı, bütün hesaplar gereksiz miydi?” diye sordu. {kahraman} gülümsedi. Bu soruyu kendisine de sormuştu. “Hayır,” dedi. “Bir riskin gerçekleşmemesi, onun değerlendirilmesinin gereksiz olduğunu kanıtlamaz. Ama sonuçların hepsini geriye dönüp incelememiz gerekir.”
---
@omurga
Başka bir öğrenci, “O zaman uzay görevlerinde hiç hata yapmamak mümkün mü?” diye sordu. {kahraman} cevap vermeden önce düşündü: Hatalar saklanırsa tekrarlanır. “Hiç hata olmayacağını garanti edemeyiz,” dedi. “Hataları fark etmek, kayıt altına almak ve onlardan öğrenmek için yöntemler kurabiliriz.”

Sunum bittikten sonra Ceyda'dan mesaj geldi. Kampa birlikte katıldıkları öğrenciler için bir gözlem kulübü kurmayı öneriyordu. Kulübün ilk toplantısında yıldızlara bakacak, ikinci toplantısında veri tablolarını okuyacaklardı. {kahraman} cevap yazdı: Olur. Ama bir kuralımız olsun: Bilmiyorsak bilmiyoruz deriz.

Gece ışıkları kapattığında tavandaki çıkartmalar eskisi gibi parladı. {kahraman} onları sökmedi. Yalnızca birinin yanına küçük bir kâğıt yapıştırdı: Bu noktaların arasında da düşünmemiz gereken yollar var. Sonra pencereyi açtı. Yıldızların arasından geçen hiçbir gerçek uyduyu o gece çıplak gözle ayırt edemedi. Yine de artık gökyüzüne baktığında tek bir kırmızı noktanın değil, birlikte verilmesi gereken dikkatli kararların hikâyesini görüyordu. Bir sonraki araştırmasında yeniden yanılabileceğini biliyordu. Ama artık bunu saklamaktan değil, fark edip düzeltmekten güç alacağını artık daha açıkça düşünüyordu.
