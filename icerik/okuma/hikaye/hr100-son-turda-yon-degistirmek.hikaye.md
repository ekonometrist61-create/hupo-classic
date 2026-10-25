---
baslik: "Son Turda Yön Değiştirmek"
slug: "hr100-son-turda-yon-degistirmek"
fis_kodu: "HR-100"
tur: spor
konu: saglik_hedef_dayaniklilik
sinif_alt: 7
sinif_ust: 7
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Yarışa iki gün kala ağrı başlayan Defne, rekor peşinden koşmak yerine sağlığını ve hedefini yeniden düşünmeyi öğrenir."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 7
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [saglikli_yasam, dayanisma]
  ders_baglantisi: [turkce, hayat_bilgisi]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: sinir_hr100, tur: lexeme, etiket: "sınır", yuva: hr100_sinir, islev: first_hint}
    - {id: tempo_hr100, tur: lexeme, etiket: "tempo", yuva: hr100_tempo, islev: application}
    - {id: dinlenme_hr100, tur: lexeme, etiket: "dinlenme", yuva: hr100_dinlenme, islev: application}
    - {id: sakatlik_hr100, tur: lexeme, etiket: "sakatlık", yuva: hr100_sakatlik, islev: transfer}
    - {id: deyim_hr100, tur: idiom, etiket: "Dişini sıkmak", yuva: hr100_disini, islev: application}
    - {id: kavram_hr100, tur: concept, etiket: "Sağlık ile performans hedefini ayırmak", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (7. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Kahramanın telefonunda on bir gündür hangi sayı duruyordu?", secenekler: [{id: A, metin: "4.24"}, {id: B, metin: "4.52"}, {id: C, metin: "3.42"}, {id: D, metin: "4.42"}], dogru: D, aciklama: "Telefonunda 4.42 sayısı duruyordu; bu, bin iki yüz metrelik koşunun rekoruydu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 3, metin: "Deniz Hanım'a göre yorgunluk ile belirli bir noktadaki ağrı arasındaki fark nedir?", secenekler: [{id: A, metin: "İkisi aynı şeydir"}, {id: B, metin: "Ağrı her zaman yorgunluktan gelir"}, {id: C, metin: "Yorgunluk genel bir durumdur; belirli bir noktadaki ağrı ise dikkat gerektirir"}, {id: D, metin: "Yorgunluk önemli değildir"}], dogru: C, aciklama: "Genel yorgunlukla belirli bir noktadaki ağrı farklı durumlardır; ağrı sağlık açısından dikkate alınmalıdır."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 8, metin: "Deniz Hanım'ın bu sözüne göre güç nasıl ölçülür?", secenekler: [{id: A, metin: "Yalnızca acıya dayanmakla"}, {id: B, metin: "Doğru anda durabilmekle de"}, {id: C, metin: "Yalnızca en hızlı koşmakla"}, {id: D, metin: "Kronometredeki sayıyla"}], dogru: B, aciklama: "Güç yalnızca acıya dayanmakla değil, bazen doğru anda durabilmekle de ölçülür."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 26, metin: "Bu cümlede “heyecan” sözcüğü ne anlatır?", secenekler: [{id: A, metin: "Yoğun ilgi ve coşku duygusu"}, {id: B, metin: "Bir hastalık"}, {id: C, metin: "Bir yarışın kuralı"}, {id: D, metin: "Bir sıralama tablosu"}], dogru: A, aciklama: "Bu cümlede heyecan, yarışmanın uyandırdığı coşku ve ilgi duygusunu anlatır."}
  - {id: s5, beceri: degerlendirme, dayanak_sayfa: 27, metin: "Kahramanın benimsediği yaklaşıma göre kendini nasıl değerlendirmelidir?", secenekler: [{id: A, metin: "Başkasının süresiyle karşılaştırarak"}, {id: B, metin: "Yalnızca derecesine bakarak"}, {id: C, metin: "Arkadaşlarının yorumlarına göre"}, {id: D, metin: "Kendi durumuna ve sağlığına bakarak"}], dogru: D, aciklama: "Kahraman, kendini başkalarının süresiyle değil, kendi durumuna ve sağlığına bakarak değerlendirmeyi benimser."}
deyim_cumleleri:
  hr100_disini: "Bir süre dişini sıktı, sonra temposunu düşürdü."
---
@omurga
{kahraman:ilgi} telefonunda on bir gündür aynı sayı duruyordu: 4.42. Dört yüz metrelik okul koşusundaki derecesini değil, bin iki yüz metrelik koşunun dört dakika kırk iki saniyelik rekorunu gösteriyordu. Sayı, yakın arkadaşlarının fotoğraflarından daha çok baktığı bir görüntüye dönüşmüştü. Her sabah alarm çalınca önce buna bakıyor, sonra ayakkabılarını bağlıyordu.

İlçe gençlik koşusuna on gün kalmıştı. {kahraman} yedinci sınıftaydı ve okul atletizm takımının en istikrarlı koşucularından biriydi. Antrenörü Deniz Hanım, onu hızı kadar sabrıyla da tanımlardı. {kahraman} bir antrenmanda ilk sıralara geçemeyince yarışın bittiğini düşünmezdi. Fakat son haftalarda herkes ona başka bir gözle bakmaya başlamıştı. Okul panosunda adının yanında eski rekoru yazıyordu. Arkadaşları “Bu yarışta kesin kırarsın,” diyordu. Babası, koşu ayakkabılarını yenileyip “Sürprize hazır ol,” diye gülümsemişti.

İlk uyarıyı bir salı akşamı hissetti. Hafif tempolu koşunun son turunda sağ bacağının alt kısmı sızladı. {kahraman} hızını azalttı; ağrı birkaç adım sonra hafifledi. Eve geldiğinde bunu yoğun günün yorgunluğu saydı. Ertesi sabah merdivenlerden çıkarken aynı bölge yeniden kendini hatırlattı. Telefonundaki rekor sayısına baktı. “On gün dayanabilir,” diye düşündü.
---
@omurga
Antrenmana gittiğinde takım arkadaşı {yoldas:yalin|bir arkadaş} ona göz ucuyla baktı. “Topallıyor musun?” diye sordu. {kahraman} hemen dikleşti. “Hayır, ayakkabının bağı gevşedi.” {yoldas:yalin|bir arkadaş} aşağı baktı. Bağlar sıkıydı. {kahraman} onun başka bir şey söylemesine fırsat vermeden ısınma pistine yürüdü.
---
@omurga
Koşu başladığında gökyüzü açıktı. Öğrenciler pistin çevresinde nefeslerini düzenliyor, antrenörler süre tutuyordu. {kahraman} ilk turu alıştığından hızlı geçti. Kronometreye baktı; hedefin önündeydi. Fakat ikinci turda sağ bacağındaki sızı belirginleşti.[[deyim:hr100_disini]] Deniz Hanım düdüğünü çaldı. “{kahraman}, yanıma gel.”

{kahraman} durduğunda başı öne eğikti. “Biraz yoruldum, hepsi bu,” dedi. Antrenör onun yürüyüşünü izledi. “Yorgunluk ile belirli bir noktadaki ağrı aynı şey değil. Ağrı ne zamandır var?” {kahraman} önce “Bugün” diyecekti. Sonra antrenörünün gözündeki sakin ısrarı görünce dürüstçe yanıtladı. “Salıdan beri.”

Deniz Hanım, “Bunu daha önce söylemeliydin,” demedi. Bir sandalyeye oturmasını istedi, antrenmanı durdurdu ve okulun sağlık görevlisine haber verdi. {kahraman} kendini sanki yarışa girmemek için bahane uydurmuş gibi hissediyordu. {yoldas:yalin|bir arkadaş} uzaktan su şişesini getirdi. “Ben de gördüm,” dedi alçak sesle. “Bağın gevşek değildi.”

Sağlık görevlisi ağrının tek başına kesin tanı koydurmadığını, bir sağlık uzmanının değerlendirmesi gerektiğini anlattı. {kahraman} velisiyle birlikte muayeneye götürüldü. Muayene sonunda doktor, koşuya ara vermesini ve kendisine önerilen planı izlemesini söyledi. Ağrıyı bastırıp yarışa çıkmanın sorunu artırabileceğini, spora dönüş kararını da tıbbi değerlendirmeye göre vermek gerektiğini açıkladı.
---
@omurga
{kahraman} o akşam ayakkabılarını yatağının altına itti. Telefonundaki 4.42 sayısını kapattı. Ama kapatmak unutmak değildi. Başka öğrencilerin antrenman fotoğraflarını görünce boğazında bir düğüm oluşuyordu. “Ben bu yarış için çalıştım,” dedi annesine. “Şimdi herkes koşacak, ben izleyeceğim.”

Annesi onun yanına oturdu. “Emek verdiğin şeyin elinden alınmış gibi gelmesi çok zor,” dedi. “Ama bedeninle kavga etmek zorunda değilsin.” {kahraman} cevap vermedi. O gece ilk kez bir yarışın kaybı ile kendi değerini aynı şey sandığını fark etti. Yine de bunu değiştirmek kolay olmayacaktı.
---
@omurga
{kahraman:ilgi} yarışa ara vereceği haberi okula düşündüğünden hızlı yayıldı. Sınıfa girdiğinde iki arkadaşının konuşmayı aniden kestiğini gördü. Öğle arasında biri “Geçmiş olsun” dedi, diğeri “Yarışa giremeyeceğine üzüldüm,” diye ekledi. Hepsi iyi niyetliydi, ama {kahraman} sanki alnında kocaman bir “Koşamıyor” yazısı taşıyormuş gibi hissediyordu. Öğretmeni ona ders sonrası görüşmeyi önerdiğinde en çok bundan korktu. Konuşmak sorunu gerçek yapacaktı.

Türkçe öğretmeni Nermin Hanım koşu defterinden söz etti. “Yazdığın günlüklerde sadece süre yok,” dedi. “Bir de kendini nasıl hissettiğin var. Belki onları da okumalısın.” {kahraman} eve gidince defterinin ilk aylarını inceledi. İlk sayfalarda koştuğu mesafeler küçüktü; kenarlara “Bugün nefesim yetmedi,” “{yoldas:yalin|bir arkadaş} beni güldürdü,” “Yağmurdan sonra pist parlıyordu” gibi notlar almıştı. Aylar ilerledikçe cümleler kısalmış, yalnızca rakamlar kalmıştı.

Aynı akşam babası yemeğe otururken “Rekoru bu yıl kıramazsan seneye kırarsın,” dedi. {kahraman} bu sözden bile rahatsız oldu. “Ya hiç kıramazsam?” diye sordu. Babası şaşırdı. “Öyleyse başka hedef bulursun.” {kahraman} kaşığını bıraktı. “Ama siz hep hızlı koşmamı istiyorsunuz.”
---
@omurga
Babası bir süre sustu. Ayakkabılarını alırken onun koşmayı sevdiğini düşünmüş, fakat hediyeyi verirken söylediklerinin bir beklentiye dönüştüğünü fark etmemişti. “Senin için heyecanlandım,” dedi. “Belki çok fazla konuşmuşum. Rekor kırdığın için değil, sevdiğin bir şey için çabaladığın için gurur duyuyorum.” {kahraman} o an gözlerini kaldırdı. Babasının söyledikleri bir gecede bütün kırgınlığını geçirmedi, ama üzerine yüklenen baskının bir bölümünü indirdi.

Ertesi gün {kahraman} okulun panosunun önünde durdu. Adı hâlâ rekor listesinde yazıyordu. Altına küçük bir not iliştirmek istedi: Başarı yalnızca dereceden ibaret değildir. Sonra bunun herkes için aynı şekilde doğru anlaşılmayabileceğini düşündü. Bazı arkadaşları dereceler için çok emek veriyordu. Onların hedeflerini küçümsemek istemiyordu. Bunun yerine Deniz Hanım'a, spor panosuna sağlıklı antrenman ve takım emeği üzerine bir bölüm açmayı önerdi. Antrenör bunu kabul etti.
---
@omurga
Takımın ertesi antrenmanına seyirci olarak gitti. Deniz Hanım, sağlık değerlendirmesine göre dinlenmesi gerektiğini yeniden hatırlattı. {kahraman} tribünün en arka basamağına oturdu. Takımın ısınmasını izlemek başlangıçta dayanılmazdı. Her adımda onların bir şey kazandığını, kendisinin geride kaldığını sanıyordu.

{yoldas:yalin|bir arkadaş} yanına geldi. “İstersen süreleri not eder misin?” diye sordu. {kahraman} terslendi. “Koşamayınca sekreter mi oldum?” {yoldas:yalin|bir arkadaş} bir an durdu. “Hayır. Bizim tempomuz bazen bozuluyor. Sen bunu en iyi fark eden kişisin.”

{kahraman} defteri aldı ama özür dilemek aklına gelmedi. İlk grubun tur sürelerini yazdı. {yoldas:ilgi|bir arkadaşın} ilk turu çok hızlı geçtiğini, üçüncü turda belirgin biçimde yavaşladığını gördü. Koşan biri olarak hissettiği şeyleri dışarıdan daha açık görüyordu. Deniz Hanım notlara bakıp “Bu karşılaştırma iyi. Bir sonraki antrenmanda sabit tempo deneyeceğiz,” dedi.

O akşam {kahraman}, koşu defterinin eski sayfalarını karıştırdı. Hedefleri hep rakamlarla yazmıştı: daha hızlı tur, daha yüksek sıra, daha kısa süre. Bir sayfada yalnızca bir cümle vardı: Koşarken kendimi özgür hissediyorum. Bu cümleyi aylar önce yazmıştı. Neden unutmuştu?
---
@omurga
Ertesi gün okuldaki spor salonunda antrenörle konuştu. “Yarışa çıkamayacaksam bu kadar çalışmamın anlamı yok mu?” diye sordu. Deniz Hanım, “Bunu hissetmen anlaşılır,” dedi. “Ama çalışmanın tek sonucu bir yarış zamanı değil. Dayanıklılık, disiplin, arkadaşlarınla kurduğun bağ ve bedenini dinlemeyi öğrenmen de sonuç. Şu an en önemli hedefin iyileşme planına uymak.”

{kahraman}, “Beni zayıf bulacaklar,” diye fısıldadı. Antrenör gözlerini ondan ayırmadı. “Gücün yalnızca acıya dayanmakla ölçülmez. Bazen doğru anda durabilmek de güç ister.”
---
@omurga
{kahraman:ilgi} uzaktan çalışma sürecinde en çok zorlandığı şey hareketsiz kalmak değil, yapabildiği bir işi yapmıyor görünmekti. Sınıf arkadaşlarından bazıları onu korumak için beden eğitimi dersindeki her görevden uzak tutmaya çalışıyordu. {kahraman} zaman zaman buna kızıyordu; sporla ilgili düşünce ve bilgisi hâlâ yerindeydi. Öğretmeni, doktorun önerdiği {kelime:hr100_sinir} içinde kalmak şartıyla sınıfın spor etkinlikleri için bir gözlem görevi hazırlamayı teklif etti.

{kahraman} grupların koşu stratejilerini karşılaştıran kısa bir çizelge yaptı. İlk turda hızlı başlayanlarla dengeli başlayanların nasıl hissettiğini soracaktı. Bunun bilimsel bir araştırma sayılabilmesi için çok az kişiden veri topladıklarını, sonuçların herkes için geçerli olmadığını da rapora yazdı. {yoldas:yalin|bir arkadaş}, “Sen iyileşince spor bilimci olacaksın,” diye şaka yaptı. {kahraman}, “Önce kendi kötü varsayımlarımı fark edeyim,” dedi.

Bir gün kulüp toplantısına eski bir mezun, Burcu Abla geldi. Üniversitede spor eğitimi alıyordu ve gençlerle sağlıklı antrenman üzerine konuşacaktı. {kahraman} onun da zamanında {kelime:hr100_sakatlik} nedeniyle yarış kaçırdığını öğrenince çok dikkat kesildi. “O gün ne yaptın?” diye sordu. Burcu, “Önce çok kızdım,” dedi. “Sonra uzmanların değerlendirmesine uyup hedefimi yeniden kurdum. Ama bu süreçte kendimi yalnız hissettiğim günler de oldu.”
---
@omurga
{kahraman} şaşırdı. Başarılı bir sporcunun bazen kendinden emin olamayabileceğini hiç düşünmemişti. Burcu, genç sporcuların erken dönemde gelişen bedenlerini yetişkin performansıyla karşılaştırmamaları gerektiğini anlattı. Herkesin yüklenme kapasitesi ve iyileşme süreci farklıydı. Süre, kilo veya sosyal medyada görülen bir programın tek başına ölçü olmadığını vurguladı. {kahraman} telefonundaki bazı videoları hatırladı. Hepsinde hızlı sonuç vaat eden başlıklar vardı. Hiçbirinde o sporcunun koşulları anlatılmıyordu.

Konuşma bitince {kahraman} kendi defterine yeni bir soru yazdı: Bu tavsiye benim durumuma uygun mu? Artık gördüğü her antrenmanı taklit etmek yerine Deniz Hanım ve sağlık uzmanıyla görüşmeye karar vermişti. Bu düşünce onu yarıştan uzaklaştırmıyor, sağlıklı biçimde geri dönme ihtimaline daha dikkatli yaklaşmasını sağlıyordu.
---
@omurga
İlçe yarışına beş gün kalmıştı. Takım pistte {kelime:hr100_tempo} deniyordu. {kahraman}, küçük bir çizelge hazırlayıp koşucuların ilk ve son tur sürelerini karşılaştırdı. {yoldas:ilgi|bir arkadaşın} temposunu dengeli tutamadığını fark etti. “İlk turu biraz daha kontrollü koşmayı denersen sona güç bırakabilirsin,” dedi. {yoldas:yalin|bir arkadaş} onun önerisini dinledi ve sonraki denemede daha dengeli bir sonuç aldı.

{kahraman:bulunma} yeni bir alışkanlık oluştu: Yarışçıların yalnızca bitiş süresini değil, süreçlerini de incelemek. Kim hızlanırken nefesini kaybediyor, kim gereğinden erken güç harcıyor, kim su molasını unutuyordu? Not almak bir süre sonra onu tribündeki sessizlikten çıkardı. Fakat her gün kolay geçmedi. Bazen birinin koştuğunu görünce kendine kızıyor, sonra aynı düşünceyi tekrar tekrar yaşıyordu.

Bir akşam {yoldas:yalin|bir arkadaş}, “Sürekli gülümsüyorsun ama mutlu değilsin,” dedi. {kahraman} şaşırdı. “Belli oluyor mu?” {yoldas:yalin|bir arkadaş} omuz silkti. “Ben de geçen yıl seçmelere alınmamıştım. Herkes 'boş ver' dediğinde daha çok kızmıştım. Bazen sadece canım sıkıldı demek istiyordum.”
---
@omurga
{kahraman} ilk kez birine açıkça “Kıskanıyorum,” dedi. “Sizi kıskanıyorum. Çünkü yarışmak istiyorum.” {yoldas:yalin|bir arkadaş} bunu duyunca geri çekilmedi. “Bu kötü biri olduğun anlamına gelmiyor,” dedi. “Yine de bizimle ilgili ne yapacağına sen karar veriyorsun.”

O gece {kahraman} defterine iki sütun çizdi. İlkine “Kontrol edemediklerim” yazdı: yarış tarihinin yaklaşması, bacağının ne hızla iyileşeceği, başkalarının yorumları. İkincisine “Yapabileceklerim” yazdı: doktorun önerilerine uymak, antrenöre dürüst olmak, arkadaşlarına destek vermek, dinlenmek. Listeyi bitirdiğinde sorun ortadan kalkmamıştı. Yalnızca sorunun içinde kendisine ait küçük bir alan açılmıştı.
---
@omurga
Yarış sabahı otobüste herkes farklıydı. {yoldas:yalin|bir arkadaş} sessizce kulaklıklarını takmış, Duru ısınma listesini kontrol ediyor, {kahraman} ise takımdaki küçük spor çantasının fermuarını defalarca açıp kapatıyordu. Deniz Hanım, “Hepiniz aynı sonucu istemek zorunda değilsiniz,” dedi. “Hepimizin bugün yapabileceği doğru iş farklı olabilir.” {kahraman} bunu duyunca elindeki kronometreyi cebine koydu.

Sahanın girişinde rakip okuldan öğrencilerle karşılaştılar. Bazıları uzun süredir birbirini tanıyor, yarış öncesi şakalaşıyordu. {kahraman}, kendi rekoruna en çok yaklaşan öğrencilerden biri olan Eylül'ü gördü. Önce gözlerini kaçırdı. Eylül yanına gelip “Yarışmayacak mısın?” diye sordu. {kahraman} durumunu açıkladı. Eylül'ün yüzü ciddileşti. “Üzüldüm. Geçen sene ben de bir yarışı kaçırmıştım. İnsanın bütün planı değişiyor,” dedi.

{kahraman}, rakibini yalnızca saniyelerden oluşan bir çizelge gibi gördüğünü fark etti. Oysa Eylül de antrenmanlara gidiyor, sınavlara çalışıyor, bazen yoruluyor ve aynı pistte başka kaygılar taşıyordu. Bir süre birlikte yürüdüler. Eylül, “Geçen yıl bana en çok yardım eden şey, bir günün bütün sezon olmadığını anlamaktı,” dedi.
---
@omurga
İlk yarışlar başladığında {kahraman} tribünden takımı izledi. Bir koşucu başlangıçta dengesini kaybetti, ardından toparlanıp devam etti. İzleyenlerden bazıları yüksek sesle yorum yaptı. {kahraman} eski kendisi olsaydı hata üzerinde uzun uzun duracağını düşündü. Şimdi sporcuların herkesin önünde kararlar verdiğini, bazen de planları değiştirmek zorunda kaldığını görüyordu.

{yoldas:ilgi|bir arkadaşın} koşusu yaklaşırken takım kaptanı Duru yanına oturdu. “Sana bir şey söyleyeyim mi?” dedi. “Biz bazen senden çok hızlı olmanı bekledik. Bunu seni desteklemek sanıyorduk.” {kahraman} hiç beklemediği bu sözle gülümsedi. “Ben de her beklentiyi yerine getirmem gerektiğini sandım,” dedi. Duru elini onun omzuna koydu. “Birlikte daha iyi öğreniriz.”
---
@omurga
Yarış günü piste vardıklarında hava hafif rüzgârlıydı. {kahraman} takımın yanında duruyordu. Forma giymişti ama koşu numarası yoktu. Başlangıç çizgisine yaklaşırken içinden geçen acı duygusunu saklamadı. “Orada olmayı isterdim,” dedi antrenörüne. Deniz Hanım başını salladı. “Biliyorum.”

{yoldas:yalin|bir arkadaş} yarış öncesi yanına geldi. “Ne söyleyeceksin?” diye sordu. {kahraman} notlarını uzattı. “İlk turda hedefin değil, temponun peşinden git. Son turda ne kaldığına bak.” {yoldas:yalin|bir arkadaş} gülümsedi. “Sen de kronometreyi tut.”

Yarış başladı. {yoldas:yalin|bir arkadaş} ilk tura beklenenden biraz yavaş girdi. {kahraman} tribünden bunu gördü. Bir an içinden “Hızlan!” diye bağırmak geldi. Sonra kendi defterine baktı. İlk turdaki sabır, son turdaki gücün parçasıydı. İkinci turda {yoldas:yalin|bir arkadaş} kontrollü ilerledi. Son tur başladığında öndeki koşucular hızlanmıştı. {yoldas:yalin|bir arkadaş} de temposunu artırdı, fakat bitişte kendi rekorunu çok az geliştirdi. Birinci olmadı.

{kahraman} bitiş çizgisine koşmadı; takım arkadaşlarının olduğu bölüme yürüdü. {yoldas:yalin|bir arkadaş} nefesini toparlayınca, “Önerin işe yaradı,” dedi. {kahraman}, “Asıl sen uyguladın,” diye karşılık verdi. {yoldas:ilgi|bir arkadaşın} yüzündeki sevinci görünce kendi içinde yeni bir his belirdi: Başkasının başarısının kendisinden bir şey eksiltmediğini fark ediyordu.
---
@omurga
Ödül töreninde {kahraman:ilgi} adı okunmadı. Bunun ağır geldiği anlar oldu. Fakat takım fotoğrafında herkes onun yanına geldi. Fotoğrafçı, “Kronometreyi de gösterin,” dedi. {kahraman} kronometreyi eline aldı. Ekranda bu kez tek bir rekor değil, bütün koşucuların tur süreleri vardı. Bir an gülümsedi. Sayıların arkasında farklı emekler ve farklı öyküler bulunuyordu.
---
@omurga
Sezon değerlendirmesinde Deniz Hanım, öğrencilerden yalnızca koşu sonuçlarını değil, takım ortamını da değerlendirmelerini istedi. Herkes bir kâğıda kimsenin adını yazmadan bir öneri bıraktı. Kimisi yarış öncesi daha az baskı hissetmek istiyordu; kimisi antrenman planını daha iyi anlamayı; kimisi de bir süre kötü koştuğunda eleştirilmeyeceğinden emin olmayı. {kahraman} bu notları okuyunca herkesin kendi içinde görünmeyen bir mücadele taşıdığını fark etti.

{yoldas:yalin|bir arkadaş}, “Başarının ölçüsü yalnızca süre olsun istemiyorum,” dedi. Duru “Ama süreler de önemli,” diye hatırlattı. Deniz Hanım ikisine de hak verdi. “Performansı ölçmek sporda gerekli olabilir,” dedi. “Fakat sporcunun sağlığını ve insan olarak değerini tek ölçüye indiremeyiz.”

Takım birlikte yeni bir kural yazdı: Antrenmanda ağrı, olağan dışı belirti veya kaygı yaşayan biri bunu saklamadan yetişkinlere bildirebilecek; kimse bunun için küçümsenmeyecekti. Ayrıca {kelime:hr100_dinlenme} ve toparlanma konularında sağlık uzmanlarının değerlendirmelerine önem vereceklerdi. {kahraman} bir an telefonundaki eski rekorun kendisine verdiği baskıyı düşündü. Tek bir kural her şeyi değiştirmeyecekti, ama artık konuşulabilir bir alan vardı.
---
@omurga
O günden sonra okul panosunda derecelerin yanında yeni bir bölüm yer aldı: Bugün ne öğrendik? Bazen “Tempolu başlamak ile acele etmek farklıdır” yazıyor, bazen “Bir arkadaşımızı dinlemek de takım çalışmasıdır.” {kahraman} bu cümlelerin hepsine katılmıyordu; kimileri fazla genel geliyordu. Ama konuşmayı açmalarını seviyordu.

Bir gün küçük öğrencilerden biri panonun önünde durup, “En hızlı olmayan biri de atlet olabilir mi?” diye sordu. {kahraman} önce çok kolay bir soru olduğunu sandı. Sonra çocuğun yanıtı gerçekten merak ettiğini gördü. “Elbette,” dedi. “Atlet olmak, antrenman yapmak, öğrenmek ve sağlığını gözeterek gelişmekle de ilgilidir. Herkes aynı hızda koşmaz.” Çocuk gülümseyip defterine bir şey yazdı.

{kahraman} onun ne yazdığını sormadı. Bazen bir cümlenin bir insanın içinde nasıl yer bulacağını hemen bilemezsin. Yalnızca zamanla ortaya çıkar.
---
@omurga
Yarıştan iki gün sonra okulun spor hesabında bir video paylaşıldı. Videoda {yoldas:yalin|bir arkadaş} son metrelerde hızlanıyor, takım arkadaşları bağırıyor, {kahraman} de kronometreyi tutuyordu. Paylaşımın altına “Asıl kahramanlarımız koşanlar” yazılmıştı. {kahraman} cümleyi okuduğunda içinde yeniden o eski kırgınlık kabardı. Kendi emeğinin görünmez olmasına kızıyordu. Sonra bu düşüncesinden utandı; arkadaşlarının sevincini bozmak istemiyordu.

Akşam Duru onu aradı. “Yorumları gördün mü?” diye sordu. Birkaç kişi {kahraman:ilgi} yarışa neden katılmadığını merak etmişti. Bazıları, “Korktu mu?” diye yazmıştı. Duru videonun altına sağlık durumuyla ilgili açıklama yazmayı teklif etti. {kahraman} bir süre düşündü. Durumunu herkesin bilmesi gerektiğine inanmıyordu. “Teşekkür ederim,” dedi. “Ama benim adıma açıklama yapmayın. İstersem kendim söylerim.”

Ertesi sabah bu konuyu antrenörüyle konuştu. Deniz Hanım, öğrencilerin görüntülerinin paylaşılması için okulun izin ve güvenlik kurallarına uyulması gerektiğini, kişisel sağlık bilgisinin de herkesin merakına cevap olsun diye açıklanmaması gerektiğini söyledi. {kahraman} daha önce yalnızca koşu süresini özel bir bilgi gibi saklamıştı. Şimdi kendi bedeniyle ilgili açıklamayı ne zaman ve kiminle paylaşacağına karar vermenin de hakkı olduğunu düşünüyordu.
---
@omurga
Duru, paylaşım ekibiyle konuşup yorumları moderasyon kurallarına göre değerlendirmelerini istedi. Kimsenin sağlık durumuna ilişkin tahminde bulunmaması gerektiğini hatırlatan kısa bir not yayımlandı. {kahraman} bu notun kendi adını içermemesine sevindi. O gün sosyal medyadaki beğeni sayısı küçük bir konu hâline geldi. Bir süre sonra herkes yeni bir spor haberine geçti. {kahraman} ise öğrendiği şeyi unutmadı: İnsanlar senin hikâyenin yalnızca küçük bir karesini görür. O kare her şeyi anlatmaz. {isaret:anahtar}
---
@omurga
Haftalar sonra sağlık uzmanının değerlendirmesi ve dönüş önerileri doğrultusunda {kahraman} kontrollü hareketlere yeniden başladı. Başlangıçtaki hedefi hızlı koşmak değildi. Bedenini dinlemek, belirtileri takip etmek ve gerektiğinde durmaktı. İlk gün pistin kenarından çok yavaş ilerlediğinde kendini garip hissetti. Önceden tek turda geçtiği mesafe şimdi daha uzun sürüyordu. Yine de çizgiler tanıdıktı; rüzgâr aynıydı.

Deniz Hanım ona “Bugünkü hedefin nedir?” diye sordu. {kahraman} birkaç saniye düşündü. “Dün yaptığımın aynısını yapmak zorunda değilim,” dedi. “Bugün için güvenli ve gerçekçi olanı yapmak.”

Bir süre sonra takım arkadaşlarıyla yeniden aynı pistte bulundu. Gün gün ilerleyen dönüş planında kimi günler bekledi, kimi günler küçük bir aşama kaydetti. Eski telefon kaydı hâlâ duruyordu: 4.42. {kahraman} artık ona her sabah bakmıyordu. İlerleyişini yalnızca tek sayıyla ölçmenin kendisini nasıl daralttığını biliyordu.
---
@omurga
{kahraman:ilgi} kontrollü dönüş sürecinde, iyileştiğini düşündüğü hâlde beklemek zorunda kaldığı günler oldu. Bazen küçük bir ilerleme kaydettiğinde hemen eski hızını denemek istiyor, sonra daha önce yaşadığı kaygıyı hatırlıyordu. Deniz Hanım ona belirli bir hız sözü vermedi; sağlık uzmanının önerileri doğrultusunda güvenli hareketlerin ve dinlenmenin planlanmasını önemsediler. {kahraman} artık “Ne zaman eski hâlime dönerim?” sorusunu her gün sormamaya çalışıyordu.

Bir antrenman sonrası {yoldas:yalin|bir arkadaş} pistin kenarında oturup onunla konuştu. “Sen yarışa dönünce ben yine senden yavaş kalabilirim,” dedi. {kahraman} gülümsedi. “Bu seni rahatsız eder mi?” {yoldas:yalin|bir arkadaş} biraz düşündü. “Eskiden ederdi. Şimdi herkesin kendi koşusuna bakması gerektiğini daha iyi anlıyorum. Yine de yarışırken kazanmak isterim.”

{kahraman} bu dürüstlüğü sevdi. Rekabetin tek başına kötü olmadığını, ama arkadaşlığı tek bir sıralamaya bağlayınca ilişkiyi zorlaştırabildiğini düşündü. Birlikte küçük bir takım hedefi belirlediler: Yeni gelen öğrencilerin ısınma sürecini anlamasına yardım edeceklerdi. Böylece her antrenman yalnızca kendi performanslarına değil, birlikte oluşturdukları ortama da hizmet edecekti.
---
@omurga
İlk gün küçük öğrencilerden biri hareketleri hemen yapamadığı için ağlamak üzereydi. {kahraman} onun yanına çömelip “Bunu ilk denediğimde ben de zorlanmıştım,” dedi. Çocuğun yüzü biraz yumuşadı. {kahraman} başarısızlık sözcüğünü kullanmadı; öğrenmenin bazen birkaç deneme gerektirdiğini anlattı. “Bir şeyi yapamamakla henüz yapamamak aynı mı?” diye sordu. Çocuk başını kaldırdı. “Değil,” dedi, “henüz demek sonra öğrenebilirim.”

{kahraman} o gün eve döndüğünde günlüğünün sayfasına henüz sözcüğünü yazdı. Sağlıklı biçimde ilerlemek de bazen bu sözcüğe sabretmekti. İnsan bir hedefe doğru yürürken ara duraklarını kayıp sanmayabilirdi.
---
@omurga
Spor kulübü yıl sonu için bir sergi hazırlarken {kahraman:ayrilma} kısa bir yazı istendi. Başta istemedi; kendi yaşadıklarının herkesin önünde konuşulmasını istemiyordu. Sonra yalnızca izin verdiği kadarını anlatabileceğini düşünerek yazmaya karar verdi. Yazısında herhangi bir tanıdan ya da özel sağlık bilgisinden söz etmedi. “Bir gün hızımı kaybettim sandım,” diye başladı. “Sonra başka beceriler kazandığımı fark ettim.”

Yazısını sınıfta okuduğunda bazı öğrenciler onun sporla ilişkisinin değiştiğini düşünmüş, bazıları da hâlâ yarışmak isteyip istemediğini merak etmişti. {kahraman} soruya gülümseyerek cevap verdi. “Elbette istiyorum. Ama artık bir yarışın bütün hayatım olduğuna inanmıyorum.” Sınıf arkadaşları ona alkış tuttu. Bu alkış, bitiş çizgisini ilk geçtiğinde duyduğu alkıştan farklıydı. Bu kez kendisine ait bir düşünceyi açıkça ifade etmişti.

O gün babası eve gelirken küçük bir ajanda getirdi. İlk sayfasında tarih yerine boş bir çizgi vardı. “Yeni hedeflerini kendin yazarsın,” dedi. {kahraman} ajandaya hemen sayı koymadı. Önce iyi hissettiğim bir spor günü yazdı. Sonraki sayfaya arkadaşlarımı dinlemek ekledi. Üçüncü sayfada uzun süre durdu; ardından gerekirse yardım istemek cümlesini yazdı. Bir zamanlar yardım istemeyi yenilgi saymıştı. Şimdi bunun sorumluluk olabileceğini biliyordu.
---
@omurga
Dönem sonunda okulun spor şenliğinde küçük öğrenciler için bir dayanıklılık atölyesi düzenlendi. {kahraman}, “Rekor kırmak istiyorum” diyen bir çocuğa gülümsedi. “Harika bir hedef,” dedi. “Ama bedeninin sana söylediklerini de dinle. Hızlanmak bazen iyidir, bazen yavaşlamak gerekir.” Çocuk şaşkınlıkla sordu: “Yavaşlayınca kazanabilir miyim?” {kahraman} pisti gösterdi. “Bazen kazanmak, başka gün de sağlıklı biçimde koşabilmektir.”

Atölye bitince {yoldas:yalin|bir arkadaş} ona yeni sezonun hedeflerini sordu. {kahraman} telefonunun notlar bölümünü açtı. Birinci sırada süre yazmıyordu. Sağlıklı kalmak, antrenmandan keyif almak, takım arkadaşı olmak. Listenin en altına küçük bir sayı eklemişti. O sayıyı görünce hâlâ heyecanlanıyordu. Sadece artık bir sayının kendi hikâyesini tek başına anlatamayacağını biliyordu.
---
@omurga
Bir cuma günü okulda “Başarı ne demektir?” konulu söyleşi yapıldı. {kahraman} sahnede iki arkadaşıyla birlikte oturdu. Öğrenciler sorular sordukça herkesin başarıdan farklı şeyler anladığı ortaya çıktı. Bir öğrenci için en iyi notu almak, bir başkası için yeni bir arkadaş edinmek, başka biri için korktuğu bir konuda söz almak önemliydi. {kahraman} kendi örneğini anlatırken “Bazen bir hedefi değiştirmek de başarıdır,” dedi.

Salondaki küçük öğrencilerden biri el kaldırdı. “Hedefini değiştirince önceki çaban boşa gitmez mi?” diye sordu. {kahraman} bu soruyu duyunca yarış öncesi yaptığı bütün antrenmanları düşündü. Koşarken nefesini düzenlemeyi, zorlu günlerde tekrar denemeyi, arkadaşlarının farklı güçlü yönlerini görmeyi öğrenmişti. Yarışa katılamadığı için bunların hiçbiri yok olmamıştı. “Hayır,” dedi. “Önceki emeğin sana öğrettikleri seninle kalabilir. Ama her emek mutlaka istediğin sonucu getirmek zorunda değil.”

Başka bir öğrenci, “Peki yarışı kazanmak istemek yanlış mı?” diye sordu. {kahraman} başını iki yana salladı. “Yarışmanın heyecanı güzeldir. Sadece kazanmak uğruna sağlığını ve kendine saygını kaybetmemek gerekir.” Öğretmen ona teşekkür etti. {kahraman} sahneden inerken ilk kez başarı sözcüğünün tek bir karşılığı olmak zorunda olmadığını hissediyordu. Söyleşinin sonunda bir afiş asıldı: Hedefler değişebilir; öğrenmek devam eder.
---
@omurga
Yarış sezonunda kendi derecesini sürekli konuşan {kahraman}, şimdi farklı hedefleri olan insanları dinliyordu. **Bu, artık rekabeti sevmediği anlamına gelmiyordu**. Yalnızca yarışma isteğinin hayatındaki diğer şeyleri susturmasını istemiyordu.

Bir gün aile toplantısında amcası eski rekorunu sorunca {kahraman} artık gerilmiyordu. “O dereceyi bir zamanlar koştum,” dedi. “Şimdilik planım sağlıklı ilerlemek.” Amcası başka bir soru soracak gibi oldu ama {kahraman:ilgi} kararlı, sakin cevabını görünce konuyu değiştirdi. {kahraman} bunun küçük ama önemli bir adım olduğunu hissetti. Kendini açıklamak için herkesi ikna etmesi gerekmiyordu.

Okuldaki bir panoda “Yavaş olan geride kalır” yazılı bir slogan görünce daha önce bunu neden sevdiğini düşündü. Sonra sınıfça yeni sloganlar ürettiler: “Kendi hızında öğren”, “Dinlenmek de planın bir parçasıdır”, “Başkalarının emeğini gör”. {kahraman} hiçbirini tek doğru kabul etmedi; farklı durumlarda farklı sözcüklerin işe yarayacağını biliyordu. Yine de “Kendini başkasının süresiyle ölçme” cümlesi ona yakın geldi.
---
@omurga
İlçe takımından bir veli, çocukların yarışta zorlandığını görünce daha fazla çalışmaları gerektiğini söylemişti. Deniz Hanım bu tür kararların yalnızca daha fazla antrenman anlamına gelmediğini, yaşa, sağlık durumuna ve uzman değerlendirmesine göre planlanması gerektiğini hatırlattı. {kahraman} artık bunu bir yasak değil, uzun vadeli gelişimin şartlarından biri olarak görüyordu.

Yeni sezonda koşucular ısınırken {kahraman} küçük bir defter taşıdı. Defterin kapağında eski bir çıkartma vardı: Dört dakikalık rekoru hatırlatan rakam. Artık bu rakam onun bütün kimliği değildi; yalnızca bir hatıraydı. {kahraman} parmağıyla kapağı düzeltti, sahaya baktı ve arkadaşlarının yanına yürüdü. Önündeki çizgilerin nereye gideceğini henüz bilmiyordu. Ama yalnızca bitiş çizgisini değil, bütün yolu görmeye çalışmaya karar vermişti. Bitişin ne zaman geleceğini bilmiyordu; artık bunun tek ölçü olmadığını da biliyordu.
---
@omurga
Yeni sezondan önce {kahraman} bir akşam eski antrenman kayıtlarına dönüp baktı. En yüksek hızını yazdığı günlerin yanında çoğu kez aynı not vardı: Çok yorgundum. Oysa dinlenip arkadaşlarıyla keyifle çalıştığı günlerde yalnızca süreler değil, hissettiği enerji de daha düzenliydi. Antrenörüyle birlikte ölçüleri yeniden belirlediler. Bu kez hedef tek bir yarışın derecesi olmayacaktı. Ağrı olmadan sürdürülebilen antrenman, uyku ve dinlenme de defterde yer alacaktı. {kahraman} sayfanın altına bir cümle yazdı: Dayanıklılık, her uyarıyı susturmak değil; hangisini dinlemek gerektiğini öğrenmek.

Ertesi gün küçük bir öğrenci, ona hızlanmak için her gün daha fazla koşup koşmaması gerektiğini sordu. {kahraman} hemen cevap vermedi. “Bunu antrenörüne, ailenle birlikte sor,” dedi. “Herkesin bedeni ve ihtiyacı farklı. Ben bir şeyi geç öğrendim: Kendini zorlamanın da kendine bakmanın da ne zaman gerektiğini tek bir kronometre söyleyemez.”
