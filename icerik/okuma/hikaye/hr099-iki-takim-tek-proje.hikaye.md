---
baslik: "İki Takım, Tek Proje"
slug: "hr099-iki-takim-tek-proje"
fis_kodu: "HR-099"
tur: arkadaslik
konu: kullanici_ihtiyaci_dostluk
sinif_alt: 7
sinif_ust: 7
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Okul sergisi için iki takım tek bir proje yapmak zorunda. {kahraman} ve Melis, rekabetin yerine kullanıcının ihtiyacını dinlemeyi öğrenir."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 7
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [dostluk, dayanisma]
  ders_baglantisi: [turkce, sosyal]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: kanit_hr099, tur: lexeme, etiket: "kanıt", yuva: hr099_kanit, islev: first_hint}
    - {id: erisilebilirlik_hr099, tur: lexeme, etiket: "erişilebilirlik", yuva: hr099_erisilebilirlik, islev: application}
    - {id: veri_hr099, tur: lexeme, etiket: "veri", yuva: hr099_veri, islev: application}
    - {id: guvenilir_hr099, tur: lexeme, etiket: "güvenilir", yuva: hr099_guvenilir, islev: transfer}
    - {id: deyim_hr099, tur: idiom, etiket: "Ağzını açmak", yuva: hr099_agiz, islev: application}
    - {id: kavram_hr099, tur: concept, etiket: "Kullanıcının ihtiyacını teknik çözümden önce anlamak", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (7. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 11, metin: "Pano değiştikten sonra iki takımın ortak adı ne oldu?", secenekler: [{id: A, metin: "Ortak Adım — Kıvılcım ve Pusula"}, {id: B, metin: "Akıllı Durak: Pusula Takımı"}, {id: C, metin: "Akıllı Durak 2"}, {id: D, metin: "Kıvılcım Takımı"}], dogru: A, aciklama: "Pano değiştikten sonra proje adı “Ortak Adım — Kıvılcım ve Pusula” oldu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 12, metin: "Bu metne göre bir hatayı kabul etmek ile kendini bütünüyle suçlamak arasındaki fark nedir?", secenekler: [{id: A, metin: "İkisi aynı şeydir"}, {id: B, metin: "Hatayı kabul etmek sorumluluk almaktır; kendini bütünüyle suçlamak ise bu sorumluluğu aşmaktır"}, {id: C, metin: "Hatayı kabul etmek kendini suçlamaktır"}, {id: D, metin: "Hiçbir hata kabul edilmemelidir"}], dogru: B, aciklama: "Hatayı kabul etmek sorumluluk almaktır; her şeyi üzerine almak ise gereğinden fazla suçlamaktır."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 14, metin: "Nisan'ın iyi proje hakkındaki sözüne göre iyi proje neyi açıklar?", secenekler: [{id: A, metin: "Her şeyi yaptığını"}, {id: B, metin: "Yalnızca kazandığı ödülleri"}, {id: C, metin: "Takımların adlarını"}, {id: D, metin: "Neyi yaptığını ve neyi yapmadığını"}], dogru: D, aciklama: "Nisan'a göre iyi proje, neyi yaptığını ve neyi yapmadığını açıklayan projedir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 13, metin: "Metinde “kod” sözcüğü bu bağlamda ne anlama gelir?", secenekler: [{id: A, metin: "Bilgisayar programı"}, {id: B, metin: "Bir ödül belgesi"}, {id: C, metin: "Bir bilgiyi kısaca ifade eden işaret ya da ad"}, {id: D, metin: "Bir sergi salonu"}], dogru: C, aciklama: "Bu bağlamda kod, bir güzergâhı kısaca gösteren işaret ya da addır."}
  - {id: s5, beceri: degerlendirme, dayanak_sayfa: 14, metin: "Öğrencilerin sergide seçtiği yaklaşım neyi öne çıkarır?", secenekler: [{id: A, metin: "Projenin sınırlarını dürüstçe açıklamayı"}, {id: B, metin: "Kusursuz bir ürün sunmayı"}, {id: C, metin: "Rakip takımı eleştirmeyi"}, {id: D, metin: "Jürinin beğenisini kazanmak için iddialı konuşmayı"}], dogru: A, aciklama: "Öğrenciler, projenin neyi yapıp neyi yapamadığını açıkça göstermeyi seçmiştir."}
deyim_cumleleri:
  hr099_agiz: "{yoldas:yalin|bir arkadaş} maket fikrini anlatmak için ağzını açtı, sonra vazgeçti."
---
@omurga
Okulun teknoloji atölyesindeki büyük ekranda bir cümle yanıp sönüyordu: “Şehir ve İnsan: Ortak Bir Gelecek.” Altında sergiye on iki gün kaldığını gösteren sayaç vardı. {kahraman}, ekrandaki sıfırlara bakıp çantasından dizüstü bilgisayarını çıkardı. Geçen yılki robot yarışmasının kupası pencere önünde duruyordu. Kupayı kazanan ekip kendi ekibiydi: Kıvılcım.

“Bu yıl da biz yaparız,” dedi yanındaki {yoldas:yalin|bir arkadaş}. “Zaten en sağlam kod bizde.”

Kapı açıldı. Atlas, Efe ve Nisan içeri girdi. Üçünün yakalarında da kendi takımlarının hazırladığı mavi kartlar asılıydı: Pusula. Atlas, {kahraman:ilgi} önündeki masaya baktı.

“Oraya biz oturuyorduk.”

“Dün siz oturuyordunuz,” dedi {kahraman}. “Bugün sıra bizde.”

Atölye öğretmeni Selin Hanım iki grubun arasına geçip elindeki duyuruyu masaya bıraktı. “Sergide bu sene tek okul standı olacak. İki takım ayrı ürün sunmayacak. Birlikte çalışacaksınız.”

Atölyede sandalye gıcırtıları duyuldu. {yoldas:yalin|bir arkadaş} itiraz etmek üzere doğruldu ama öğretmen devam etti: “Şehir yaşamını kolaylaştıran, erişilebilir ve gerçekten kullanılabilir bir çözüm istiyorum. Sunum kadar araştırma sürecini de değerlendireceğim.”
---
@omurga
Atlas gülümsedi. “Demek ki herkes bizim harita sistemimizi kullanacak.”

{kahraman} da aynı sakinlikle cevap verdi: “İnsanların neye ihtiyaç duyduğunu bilmeden harita tasarlamak pek işe yaramaz.”

Öğretmen, onların bu karşılıklı sözlerini not aldı. “Güzel. İlk probleminiz teknik değil: Birbirinizi duymuyorsunuz.” Sonra sınıfın ışığını açtı. “Bugün kod yazmayacaksınız. Önce sorunu tanımlayacaksınız.”

{kahraman} bunu zaman kaybı saydı. Atlas ise bir zafer işareti olarak gördü. İkisi de yanlış anlamıştı; fakat o sabah henüz bunun farkında değillerdi.
---
@omurga
Selin Hanım masalara büyük birer şehir krokisi dağıttı. Üzerinde okul, kütüphane, park, sağlık merkezi, belediye binası ve otobüs durakları işaretlenmişti. “Burada yaşamayı düşünün,” dedi. “Sizi zorlayan bir durumu seçin.”

Efe hemen tabletini açtı. “Otobüsleri canlı takip eden bir uygulama yapabiliriz. Harita, konum, tahmin… Hepsi hazır.”

{yoldas:yalin|bir arkadaş} başını salladı. “Hazır parçaları birleştirmekten proje olmaz. Biz sensörlü durak maketi yapacağız; otobüs yaklaşınca ışık yanacak.”

“Yağmurda elektronik devre bozulursa?” diye sordu Nisan.

“Su geçirmez kutu kullanırız,” dedi {yoldas:yalin|bir arkadaş}.

“Görme güçlüğü yaşayan biri o ışığı nasıl fark edecek?”

{yoldas:yalin|bir arkadaş} bir an durdu. “Ses koyarız.”

Atlas söze karıştı: “Peki durakta yaşayan herkesi aynı anda yüksek sesle uyarmak iyi fikir mi?”

Masadaki tartışma, öneriyi geliştirmek yerine önerinin sahibini savunmaya dönüşmüştü. {kahraman} çizim kâğıdına iki ayrı sütun açtı: Kıvılcım ve Pusula. Her ekip kendi fikirlerini yazdı. Ortaya ortak proje değil, yan yana getirilmiş iki alışveriş listesi çıktı.
---
@omurga
Öğretmen masanın başında durdu. “Bu çizelgedeki en büyük eksik nedir?”

“Bütçe,” dedi Efe.

“Malzeme,” dedi {yoldas:yalin|bir arkadaş}.

Nisan daha önce kimsenin bakmadığı boş alana işaret etti. “Kullanıcılar.”

“Kim?” diye sordu {kahraman}.

“Otobüsü kullanacak insanlar. Onlara sormadık.”

Selin Hanım, Nisan'a bir kalem uzattı. “O zaman yeni bir sütun aç. Kimin fikri olduğu değil, kimin ihtiyacını karşıladığı önemli.”

Öğle arasında iki takım okul çevresinde gözlem yapmayı kararlaştırdı. Kimse birbirinden özür dilemedi. Ancak ilk defa ikisi de kendi tasarımlarının eksik olabileceğini düşünüyordu.
---
@omurga
Ertesi gün izin belgeleri ve öğretmenleriyle birlikte okulun yakınındaki durakta yarım saat geçirdiler. Öğretmen, kimsenin görüntüsünü çekmemeleri ve görüşme yapmak istedikleri kişilerden önce izin istemeleri konusunda onları uyarmıştı. Öğrenciler de isim kaydetmeden not tutacaktı.

İlk konuşmayı Efe yaptı. Otobüsün ne zaman geleceğini telefondan takip eden genç bir adama, uygulamayı kullanırken en çok neye ihtiyaç duyduğunu sordu. Adam ekranı gösterdi. “Harita var ama dakika bilgisi bazen değişiyor. Bana kesinmiş gibi göstermeyin. Tahmin olduğunu bileyim.”

{kahraman} bunu not etti: Belirsizliği açıkça belirt.

İkinci kişi elinde pazar çantaları taşıyan yaşlı bir kadındı. Nisan, “Bilgi almak için hangi yöntemi kullanırsınız?” diye sordu. Kadın telefonunun olmadığını, duraktaki yazıları da uzaktan okuyamadığını anlattı. “Bir düğme olsa, kaç dakika kaldığını yüksek sesle söylese güzel olur,” dedi. Sonra düşündü. “Ama çok bağırmasın. Sabah erken saatlerde kimseyi rahatsız etmek istemem.”
---
@omurga
Üçüncü kişi tekerlekli sandalye kullanan bir yolcuydu. Yolcu, öğrencilerin tasarladığı krokide durağın yanında bulunan yüksek kaldırıma işaret etti. “Dakikayı bilmek güzel,” dedi, “ama rampası olmayan araç geldiğinde o bilgi tek başına işime yaramıyor.”

{kahraman} cevap veremedi.[[deyim:hr099_agiz]] Konuşmanın sonunda Atlas ilk kez soru sormayı bırakıp uzun süre düşündü.

Okula dönerlerken Efe, telefonuna çizdiği yeni ekranı gösterdi: otobüs saati, rampa simgesi, sesli uyarı seçeneği. “Artık tek bir uygulama değil, durakta da çalışan bir sistem lazım,” dedi.

{kahraman} karşılık verdi: “Evet. İnternete veya telefona bağımlı olmayacak bir parçası olmalı.”

Yol boyunca birbirlerine hak vermediler; fakat aynı sorunun etrafında konuşmaya başlamışlardı. Bu, aralarındaki değişimin ilk işaretiydi.
---
@omurga
Pazartesi herkes atölyeye erken geldi. İki takım ayrı masalarda çalışmaya başladı. Pusula ekibi harita ekranı tasarladı, Kıvılcım karton ve elektronik parçalarla durak maketi kurdu. {kahraman:ilgi} programı ışığı yakabiliyor, fakat Efe'nin uygulamasıyla haberleşemiyordu. Atlas'ın haritası ise bilgisayarda güzel görünüyor, ama maketteki düğmeyle konuşamıyordu.

“Senin sistemin bize veri göndermiyor,” dedi Efe.

“Çünkü hangi bilgiyi istediğini doğru söylemedin,” dedi {yoldas:yalin|bir arkadaş}.

Atlas araya girdi. “Kodunuzu gösterebilir misiniz?”

{kahraman} bilgisayarının kapağını yarıya kadar indirdi. “Geçen yarışmada da bizim çözümümüzü görmeye çalışmıştınız.”

Atlas'ın yüzü sertleşti. “O yarışmada bizim sensörümüz bozuldu. Sizin fikirlerinizi almadık.”

Tartışma yükselirken Nisan duvarın ortasına bir çizgi çekti. Sol tarafa “Bildiğimiz”, sağ tarafa “Sandığımız” yazdı. “Geçen yıl olanı konuşabiliriz,” dedi. “Ama hangi kısmını gerçekten biliyoruz?”

{kahraman}, mavi kartonun üstündeki cümlelere baktı. Gerçekten bildiği şeyler azdı: Geçen yarışmada Pusula'nın sensörü bozulmuş, jüri karşısında çalışmamıştı. Sonra Atlas'ın, kendi proje masalarının yakınından geçtiğini görmüştü. Geri kalanı yorumdu.
---
@omurga
Atlas da duraksadı. {kahraman:ilgi} kendilerini kopyacılıkla suçladığını düşünüyordu. Oysa {kahraman} bunu daha önce açıkça söylememişti; davranışından anlam çıkarmıştı.

“Belki bu yüzden kodlarını paylaşmak istemiyorlar,” dedi Nisan. “Ama bugün birbirimizi denetleyebileceğimiz bir yöntem kurabiliriz.”

Efe bir öneri getirdi: Her modülün görevi, gönderdiği veri ve değişiklik geçmişi ortak belgede yazılacaktı. Kodlar birbirlerinin emeğini silmeyecek şekilde sürüm kontrolünde tutulacaktı. Kararlar tek kişinin onayıyla değiştirilmeyecekti.

{yoldas:yalin|bir arkadaş} itiraz etti: “Bu işimizi yavaşlatır.”

“Yanlış anlaşılmaları azaltır,” dedi {kahraman}. “Bence deneyebiliriz.”

Duvarın ortasındaki çizgi silinmedi. İlerleyen günlerde ekip ona yeniden dönecekti.
---
@omurga
İlk ortak deneme perşembe günü yapıldı. Maketin üzerindeki küçük ekranda “6 dakika” yazısı belirdi; düğmeye basıldığında ses aynı bilgiyi okuyordu. Atlas'ın haritası ekrana yön bilgisi de gönderiyordu. Herkes alkışladı. Efe, telefonundan kısa bir video kaydetmek istedi; Selin Hanım yalnızca cihazı görüntülemesini, öğrencilerin yüzlerini kaydetmemesini hatırlattı.

Sistem beş dakika sonra tuhaflaştı. Maket bir otobüs için “1 dakika” dedi, ardından “9 dakika” gösterdi. Öğretmen durdurdu. “İlk değeri gören bir yolcu ne düşünür?”

“Otobüsün hemen geleceğini,” dedi Nisan.

“Peki sonra?”

“Bize güvenmeyeceğini,” dedi Atlas.

Efe kayıtlara baktı. Denemede kullandıkları {kelime:hr099_veri} dosyasında otobüsün durağa ulaşması için verilen sürenin bazen değiştiğini fark etti. Gerçek şehir ulaşım sistemiyle bağlantıları yoktu; bu yalnızca bir gösterim senaryosuydu. Yine de yanlış izlenim oluşturuyordu.

{yoldas:yalin|bir arkadaş} “En küçük sayıyı gösterelim,” dedi. “Böylece kullanıcı beklemeye hazırlanır.”

{kahraman} başını salladı. “En küçük sayıyı seçmek, elimizdeki bilgiyi olduğundan kesin göstermek olur.”
---
@omurga
Atlas “Tahmini süre” yazısını ekledi. Nisan ise yanına küçük bir soru işareti koydu; dokunulduğunda bilginin nasıl hesaplandığı sade biçimde açıklanacaktı. Sesli uyarı da “Yaklaşık altı dakika” diyecekti.

Bir başka sorun daha vardı. Maket, “Erişilebilir araç” bilgisini yalnızca yeşil renkle gösteriyordu. Renkleri ayırt etmekte zorlanan birinin bu işareti kaçırabileceğini fark ettiler. Yeşil simgenin yanına belirgin bir rampa şekli ve metin eklediler.

{kahraman} masanın sonunda iç geçirdi. “Kod yazdığımız kadar yazmadığımız şeyleri de düşünmemiz gerekiyormuş.”

Atlas güldü. “Bu da proje için iyi bir cümle. Sergi afişine yazalım mı?”

“Yaz,” dedi {kahraman}. “Ama altına kim söyledi diye değil, ne anlama geliyor diye açıklama koy.”
---
@omurga
Sergiye yedi gün kala okul panosuna bir duyuru asıldı. Projelerin isimleri, takım temsilcileri ve sunum saatleri ilan edilmişti. Onlarınki “Akıllı Durak: Pusula Takımı” olarak görünüyordu. Kıvılcım'ın adı yoktu.

{yoldas:yalin|bir arkadaş} duyuruyu gördüğü anda atölyeye yürüdü. {kahraman} arkasından yetişti. Efe, panoda yalnızca Atlas'ın gönderdiği eski taslak adının kullanıldığını söyledi. Atlas açıklama yapmaya çalıştı: “Başvuru formunu ilk doldurduğumda böyleydi. Sonra değiştirmeyi unuttum.”

“Unutmak kolay,” dedi {yoldas:yalin|bir arkadaş}. “Özellikle eksilen başkasının emeğiyse.”

{kahraman} bu kez hemen konuşmadı. Önce başvuru formunun tarihine baktı. Gerçekten de ortak çalışma kararı alınmadan önce doldurulmuştu. Atlas, yeni ekip adını bildirmemişti; fakat bunu kasıtlı yaptığına ilişkin bir {kelime:hr099_kanit} yoktu.

“Bunun nedeni ne olursa olsun düzeltilmesi gerekiyor,” dedi {kahraman}. “Kime haber vereceğiz?”

Selin Hanım birlikte müdür yardımcısına gitmelerini önerdi. Atlas, yanlışlığı kendisinin açıklamasını kabul etti. Bir saat sonra pano değişti: “Ortak Adım — Kıvılcım ve Pusula.” Temsilci bölümünde tek isim yerine bütün ekip üyeleri sıralandı.
---
@omurga
Düzeltmeden sonra {yoldas:yalin|bir arkadaş} hâlâ sinirliydi. Atlas yanına geldi. “Sana neden kızdığını anlıyorum. Bir formdaki eski isim, gerçekten çalışmamışsınız gibi görünmenize yol açtı.”

“Ben de sana hemen kötü niyet yükledim,” dedi {yoldas:yalin|bir arkadaş}. “Ama sorunun düzelmesini istemem haksız olduğum anlamına gelmez.”

“Öyle zaten,” dedi Atlas.

İkisinin arasındaki sessizlik bu kez düşmanca değildi. **Bir hatayı kabul etmekle kendini bütünüyle suçlamak arasındaki farkı öğreniyorlardı**.
---
@omurga
Ekip ertesi gün iki gönüllü öğretmen ve okul idaresinin izniyle bir öğrenciden prototipi denemesini istedi. Denemelerin gerçek bir otobüs bilgisi sağlamadığını baştan açıkladılar. Amaç arayüzün anlaşılırlığını görmekti. Kullanıcılardan kişisel bilgi toplamadılar.

İlk öğretmen küçük harfleri okumakta zorlandı. Efe yazı boyutunu artırdı. İkinci öğretmen sesli uyarı düğmesini bulamadı. Nisan düğmenin yerini yeniden düzenledi. Öğrenci ise ekrandaki “B” harfinin ne anlama geldiğini sordu. Atlas onun “B güzergâhı” kodu olduğunu söyledi.

“Bunu sadece siz biliyorsunuz,” dedi öğrenci. “Ben ilk defa görüyorum.”

Atlas açıklamayı metinle değiştirdi. {yoldas:yalin|bir arkadaş} ise maketin üstüne kalın bir düğme yerleştirdi. Dokununca hafif bir tık sesi duyuluyordu. “Bu, düğmeye bastığını anlamaya yardımcı olabilir,” dedi. “Ama gerçek ürün için uzmanların da değerlendirmesi gerekir.”

{kahraman}, test defterindeki bir çizelgeyi gösterdi. Her önerinin yanında “Değiştirildi”, “Denenecek” veya “Bu sürümde yapılamadı” yazıyordu. Bazı şeyleri yetiştiremeyeceklerini kabul etmek kolay değildi. Örneğin canlı araç verisi sağlayamıyorlardı; belediyenin resmî sistemine bağlantı kurmak için izin ve teknik iş birliği gerekecekti. Bu yüzden sergide gösterilecek verilerin örnek olduğunu açıkça belirteceklerdi.
---
@omurga
“Bence eksik kaldık,” dedi Efe.

“Eksiklerimizi saklasak daha mı iyi olurdu?” diye sordu {kahraman}.

Efe düşündü. “Hayır. O zaman izleyen kişi sistemin gerçekten çalıştığını sanır.”

“İyi proje,” dedi Nisan, “her şeyi yaptığını söyleyen proje olmayabilir. Neyi yaptığını ve neyi yapmadığını açıklayan proje olabilir.”

Efe bunu test defterinin kapağına yazdı. İlk gün herkes kendi grubunun daha iyi olduğunu kanıtlamaya çalışıyordu. Şimdi ikisi de aynı ürünün sınırlarını dürüstçe anlatmaya uğraşıyordu. {isaret:anahtar}
---
@omurga
Atölyede başka bir sorun daha baş gösterdi. Efe, yazılımın deneme ekranını hazırlarken geçen hafta durakta konuştukları üç kişiye ait notları dijital dosyaya aktarmıştı. Görüşme kayıtlarında isim yoktu ama dosyanın en altına “pazar çantalı kadın”, “tekerlekli sandalye kullanan yolcu” ve “telefonlu genç” yazmıştı. İlk bakışta bunlar kimlik belirtmiyor gibiydi. Ne var ki sınıfın başka bir öğrencisi, görüşmelerin hangi gün ve hangi durakta yapıldığını duyunca kişilerden birini tanıyabileceğini söyledi.

Nisan ekrana yaklaştı. “Görüşmeyi yapan biziz diye onların anlattıklarını istediğimiz gibi yayımlayabilir miyiz?” diye sordu.

Efe şaşırdı. “Kimsenin adını yazmadım.”

“Ad olmayınca tanınmazlar diye bir kural yok,” dedi Nisan. “Yer, zaman, özel durum gibi ayrıntılar bazen bir insanı işaret edebilir.”

{kahraman} notlarını açtı. Kadın onların sorusuna izin vermişti, ama sözlerinin okul sergisinde aynen yayımlanmasına ilişkin ayrıca konuşmamışlardı. Atlas, cümleleri tanınabilir ayrıntılardan arındırıp genel ihtiyaç biçiminde yazmayı önerdi. “Örneğin ‘Bir yolcu telefonsuz erişim istedi’ diyebiliriz.”
---
@omurga
{yoldas:yalin|bir arkadaş} hemen karşı çıktı. “Ama o zaman bu sözleri uydurmuş gibi görünmez miyiz?”

“İstersen yöntemimizi de yazarız,” dedi Nisan. “İzinli kısa görüşmeler yaptığımızı, kişisel bilgi saklamadığımızı, notları ihtiyaç başlıklarına dönüştürdüğümüzü açıklayabiliriz. Kimsenin ağzından tam cümleymiş gibi aktarmayız.”

Efe dosyayı kapatıp yeni bir tablo oluşturdu. Tablonun sütunları “İhtiyaç”, “Gözlem yöntemi” ve “Tasarım kararı” oldu. Kimlik belirtebilecek ayrıntılar çıkarıldı. En alta kısa bir uyarı yazdı: Az sayıda görüşme yaptık; sonuçlar bütün yolcuları temsil etmez.

Bu cümle Atlas'ın hoşuna gitmedi. “Böyle yazarsak proje çok küçük görünmez mi?”

“Proje zaten küçük,” dedi {kahraman}. “Biz bir şehir kadar büyük görünmesini istiyoruz. Bunlar aynı şey değil.”

Atlas bilgisayar ekranında duran üç görüşme notuna baktı. Birkaç insanla konuşmak, herkesin ihtiyacını bilmek demek değildi. Ama kimseyle konuşmamaktan daha iyi bir başlangıçtı. Ekip bunu kabul ettiğinde kendini küçülmüş değil, daha sağlam hissediyordu.
---
@omurga
Selin Hanım belgeyi okuyunca, “Bu bölüm ödül kazandırmayabilir,” dedi. “Fakat ileride gerçek bir projede insanlarla çalışırsanız en çok bunu hatırlamanızı isterim.”

O gün {kahraman} başka bir ayrıntı daha fark etti: Pusula ekibi harita verisinin güvenilirliğini sorgularken, Kıvılcım ekibi fiziksel cihazın güvenliğini kontrol ediyordu. İki ayrı uzmanlık alanı, aynı sorumluluğun farklı yüzleriydi. Bir ekip diğerinin yerine geçmeye çalışmadığında ikisi de daha iyi çalışıyordu.
---
@omurga
Prova öncesindeki öğle arasında Nisan masanın kenarına küçük bir kâğıt bıraktı. Üzerinde “Duraktaki düğmeye basamayan biri ne yapacak?” yazıyordu. Kimse fark etmedi. Atlas projeksiyondaki haritanın açılma hızını ölçüyor, {yoldas:yalin|bir arkadaş} kartların boyunu ayarlıyor, Efe de bir hata mesajını araştırıyordu.

{kahraman} notu gördüğünde Nisan çoktan pencereden dışarı bakmaya başlamıştı. “Bu soru iyi,” dedi. “Niye yüksek sesle söylemedin?”

“Söyledim,” diye cevap verdi Nisan. “İki kez. Herkes başka şey konuşuyordu.”

{kahraman} ilk refleksle “Ben duymadım,” demek istedi. Sonra bunun cevap olmadığını fark etti. Duymamak, birinin konuşmadığı anlamına gelmiyordu. Öğretmenden toplantı için beş dakika istediler.

Selin Hanım herkesin sırayla tek bir eksik söylemesini, diğerlerinin o sırada çözüm önermeden dinlemesini istedi. Nisan düğmenin yüksekliğini ve {kelime:hr099_erisilebilirlik} anlattı. Efe ekranın internet yokken nasıl davranacağını sorguladı. {yoldas:yalin|bir arkadaş} cihazın güvenliğini, Atlas veri kaynaklarını, {kahraman} ise yazılardaki kesinlik ifadesini gündeme getirdi. Hiçbiri tek başına bütün sorunları görememişti.
---
@omurga
Nisan'ın önerisiyle karton maketi farklı yüksekliklerde denediler. Düğmenin yerini değiştirince bazı kişiler için daha kolay, bazıları için daha zor olabileceğini fark ettiler. Bu nedenle tek denemeyle “herkese uygun” sonucuna varmadılar. Standda bu konunun geliştirilmesi gerektiğini yazmaya karar verdiler.

Toplantı bittiğinde Atlas, Nisan'ın bıraktığı kâğıdı çöpe atmadı. Proje dosyasına koydu. “Bir fikrin sessiz kalması,” dedi, “fikrin önemli olmadığı anlamına gelmiyormuş.”

Nisan güldü. “Bunu anlamanız için kâğıt yazmam gerekiyormuş.”

“Bir dahaki sefere sözünü bitirmeni bekleyeceğiz,” dedi {yoldas:yalin|bir arkadaş}.

Bu küçük sözün ertesi gün unutulmaması gerekiyordu. {kahraman} ortak masanın ortasına bir not yerleştirdi: Toplantıda herkes konuştu mu? O not, sergide gösterilecek hiçbir parçaya benzemiyordu. Ama projenin nasıl yapıldığını değiştiren en etkili araçlardan biri oldu.
---
@omurga
Sergi hazırlıkları sırasında Efe bir şey daha önerdi. “Görüşmelerimizi neden paylaşmıyoruz?” diye sordu. {kahraman} onun hangi bilgiyi kastettiğini anlamak için durdu. Efe, öğrendikleri tasarım ilkelerini anlatan kısa, kişisel bilgi içermeyen bir poster hazırlamayı öneriyordu. Böylece başka bir okul aynı hataları baştan yapmak zorunda kalmayacaktı. {yoldas:yalin|bir arkadaş} ilk anda tereddüt etti. “O zaman yarışmada bizim farkımız kalmaz,” dedi. Atlas da aynı şeyi düşünmüş olduğunu itiraf etti. Fakat Nisan, posterin çalışan yazılımı değil, denenmiş soruları ve karşılaştıkları sınırları paylaşacağını hatırlattı. “Bir problemi çözmek için öğrendiğimiz yöntem başkalarına da yarıyorsa bu, bizim çalışmamızı değersizleştirmez,” dedi. Sonunda posterin başına şu soruyu yazdılar: Bir teknoloji herkes için gerçekten kullanılabilir mi? Altına kesin bir yanıt koymadılar; çünkü hâlâ öğreniyorlardı.
---
@omurga
Sergiden iki gün önce, atölyede kötü bir koku duyuldu. Küçük bir bağlantı kablosu ısınmıştı. {yoldas:yalin|bir arkadaş} hemen güç kaynağını kapattı ve öğretmeni çağırdı. Selin Hanım devreyi kendisi inceledi; öğrencilere cihazı yeniden açmamalarını söyledi. Sorunun uygun olmayan bağlantı ve fazla yükten kaynaklanabileceğini, gerekli parçayı değiştirmeden denemeye devam etmeyeceklerini açıkladı.

Böylece maketin ışıklı bildirim bölümü kullanılamaz duruma geldi. Ekip suskunlaştı. Sergiye kırk sekiz saatten az kalmıştı.

Atlas, “Işıksız gösterelim,” dedi. “Harita çalışıyor.”

{yoldas:yalin|bir arkadaş} “Ama fikir zaten durakta telefon olmadan bilgi almak,” diye itiraz etti.

{kahraman} sandalyeye oturup ilk görüşmelerden aldığı notları açtı. Yaşlı kadının söylediği cümleyi hatırladı: “Bir düğme olsa, söylese.” Sesli sistem sağlamdı. Işık yanmasa bile maketin en önemli ihtiyacı karşılayan parçası korunabiliyordu. Fakat yeni devreyi kontrolsüz çalıştırmak doğru olmazdı.

Selin Hanım güvenli bir alternatif önerdi: Elektronik ışık yerine elle değiştirilen büyük, yüksek kontrastlı bilgi kartları kullanacaklardı. Sesli örnek, öğretmenin kontrol ettiği güvenli bir cihazda gösterilecekti. Sergi metninde bu değişiklik açıkça yazılacaktı.
---
@omurga
{yoldas:yalin|bir arkadaş} önce hayal kırıklığına uğradı. Haftalardır hazırladığı ışık dizisi kullanılmayacaktı. Sonra Nisan'ın yaptığı büyük kartları gördü. Kartlarda yalnızca renkler değil, yazı ve simgeler de vardı.

“Bunu yaparken keşfettiğimiz şey yine işe yarıyor,” dedi {yoldas:yalin|bir arkadaş}. “Işığın çalışmaması iyi değil ama herkesin bilgiye ulaşabilmesi tek yola bağlı değil.”

Atlas, “Yedek planımızın olması gerekiyor,” diye ekledi.

İki ekip geceye kadar çalışmadı. Öğretmen saatinde atölyeyi kapattı. Eve giderken yapılacak işleri paylaştılar: Efe açıklama ekranını, Nisan kullanıcı senaryolarını, {kahraman} test kayıtlarını, {yoldas:yalin|bir arkadaş} güvenli maketi, Atlas sunum akışını düzenleyecekti. Herkesin bir görevi vardı; kimse bütün sorumluluğu üstlenmiyordu.
---
@omurga
Sergi öncesi son provada her şey iyi başlıyordu. {kahraman} ihtiyacı anlatıyor, Atlas haritayı gösteriyor, {yoldas:yalin|bir arkadaş} durak maketindeki düğmeyi tanıtıyordu. Sonra Efe uzun bir teknik açıklamaya geçiyordu. Nisan elindeki kullanıcı notlarını açacak zaman bulamadan prova bitiyordu.

“Bir dakika,” dedi Nisan. “Ben niçin konuşamıyorum?”

Atlas saate baktı. “Sunum süresi kısa. Teknik tarafı atlayamayız.”

“Benim söyleyeceklerim teknik değil diye önemsiz mi?”

{kahraman}, ilk gün kâğıda açtıkları iki sütunu hatırladı. Yine aynı hatayı farklı biçimde yapmışlardı: Birinin işi somut ve görünür, diğerininki sanki ek bilgiymiş gibi duruyordu.

“Sahneyi baştan kuralım,” dedi. “Önce Nisan'ın görüşmelerinden bir ihtiyacı duyalım. Sonra teknoloji o ihtiyacı nasıl karşıladığını göstersin.”

Bu kez Nisan ilk sözü aldı. “Bir durakta bekleyen herkesin cebinde telefon olmayabilir. Ayrıca aynı bilgi herkese aynı biçimde ulaşmaz.” {kahraman} bunun üzerine proje problemini tanımladı. Atlas örnek verinin sınırını açıkladı. Efe uygulama ile durak ekranı arasındaki bağlantıyı kısa bir örnekle gösterdi. {yoldas:yalin|bir arkadaş} güvenli maketi tanıttı ve yapılan testlerin sonuçlarını anlattı.
---
@omurga
Prova sonunda Selin Hanım alkışlamadı. Bunun yerine “Bir sorum var,” dedi. “Siz iki takımın aynı işi yaptığını mı düşünüyorsunuz?”

“Hayır,” dedi {kahraman}.

“Peki biri diğerinden önemli mi?”

Atlas gülerek başını salladı. “Başta öyle sanıyorduk. Şimdi bir parça eksik olunca kalanların da anlamı değişiyor.”

Öğretmen bu kez alkışladı. {yoldas:yalin|bir arkadaş} ile Nisan birbirlerine baktı. Alkışın sebebi kusursuz ürün değildi; öğrendikleri şeyi artık gösterebiliyor olmalarıydı.
---
@omurga
Okul salonu sabah dokuzda dolmaya başladı. Masalarda geri dönüşüm, su tasarrufu, akıllı trafik ve kent bahçeleri üzerine projeler vardı. “Ortak Adım” standının önünde renkli bir maket, büyük yazılı kartlar ve bir dizüstü bilgisayar duruyordu. Ekranın köşesinde özellikle şu cümle yer alıyordu: “Gösterilen ulaşım verileri örnektir; gerçek zamanlı hizmet sunulmamaktadır.”

İlk ziyaretçi küçük bir öğrenciydi. Maketin düğmesine uzandı. Nisan onunla birlikte senaryoyu başlattı. Ses, örnek bir aracın yaklaşık beş dakika sonra geleceğini söyledi. Atlas ekranın yanındaki rampa simgesini gösterdi.

“Buna neden ihtiyaç var?” diye sordu öğrenci.

{yoldas:yalin|bir arkadaş} cevapladı: “Çünkü bir yolculuk yalnızca aracın ne zaman geleceğini bilmek değildir. Ona güvenli biçimde binebilmek de önemlidir.”

Bir jüri üyesi devrenin neden ışık vermediğini sordu. Efe, önce konuşmak istedi ama {yoldas:yalin|bir arkadaş} elini kaldırdı. “Bir bağlantı problemi yaşadık. Güvenli olmadığı için devreyi çalıştırmadık. Bunun yerine bilgiyi birden fazla yöntemle verebilen yedek bir sunum hazırladık.”
---
@omurga
Jüri üyesi başını salladı. “Sorunu gizlememeniz önemli.”

Başka bir jüri üyesi, “Bu sistem gerçek duraklarda çalışabilir mi?” diye sordu. Atlas'ın aklına ilk başta hazırladığı iddialı afiş geldi: “Her durağa akıllı çözüm.” Artık o cümleyi kullanmıyordu. “Şu anda yalnızca prototip,” dedi. “Gerçek kullanım için kurumlarla iş birliği, güvenlik testleri, erişilebilirlik değerlendirmesi ve güvenilir veri gerekir.”

{kahraman} arkadaşına baktı. Atlas bu soruyu yarışma puanı kaybetmemek için kaçamak bir cevapla geçiştirebilirdi. Yapmadı. Yanıtı, projeye olan güveni artırmıştı.

Günün sonuna doğru bir kadın standın önünde durdu. Yakındaki durakta görüştükleri yaşlı kadındı. Öğretmeninin davetiyle sergiye gelmişti. Maketin sesini dinledi, büyük kartlara yakından baktı.

“Demek o gün sorduğunuz şey bunun içindi,” dedi. “Benim sözümü de değerlendirdiniz mi?”

“Evet,” dedi Nisan. “Telefonu olmayan birinin de bilgiyi alabilmesini sizin sözünüzden öğrendik.”

Kadın gülümsedi. “Öyleyse bu yalnızca sizin icadınız değil. Biraz da dinlemeyi öğrenmişsiniz.”
---
@omurga
{kahraman}, sergi boyunca duyduğu bütün övgüler arasında en çok bu cümleyi sevdi.
---
@omurga
Ödül sonuçları açıklanırken salonda ışıklar hafifçe kısıldı. Sunucu teknoloji dalındaki birinciliği başka bir okula verdi. Kıvılcım ile Pusula'nın oluşturduğu Ortak Adım, “Kullanıcı İhtiyacını Anlama ve Etik Tasarım” özel takdirine değer görülmüştü. {yoldas:yalin|bir arkadaş} bir an sessiz kaldı. Atlas'ın yüzü de pek neşeli değildi.

“Demek birinci olamadık,” dedi Efe.

Nisan ödül belgesini çevirdi. “Ama tam çalıştığımız konuda takdir aldık.”

{kahraman}, Atlas'ın bir şey söylemesini bekledi. Atlas alçak sesle, “Geçen yıl sensörümüz bozulunca dünyamız yıkılmıştı,” dedi. “Bu yıl da maketin bir parçası bozuldu. Ama bu kez sorun ortaya çıktığında birbirimize kızmak yerine çözüm aradık.”

{yoldas:yalin|bir arkadaş} belgenin altındaki takım adlarını okudu. “Yine de birinci olmayı istemek yanlış değil,” dedi.

“Yanlış değil,” dedi {kahraman}. “Yalnızca başka şeyler de kazanmış olabiliriz.”

Okula döndüklerinde Selin Hanım iki takımın eski masalarını ayırmadı. Öğrenciler kendi kararıyla ortak masanın etrafına oturdu. Atölye panosunda hâlâ Nisan'ın çizdiği iki sütun duruyordu: Bildiğimiz ve Sandığımız. {kahraman}, bu kez altına üçüncü bir başlık ekledi: Birlikte Öğrendiğimiz.
---
@omurga
Herkes bir cümle yazdı. Efe “Veri, açıklanmadan {kelime:hr099_guvenilir} görünmemeli” dedi. {yoldas:yalin|bir arkadaş} “Bir tasarım bozulduğunda güvenli seçeneklerden vazgeçilmez” yazdı. Nisan “Kullanıcı olmadan kullanıcı dostu ürün tasarlanmaz” notunu düştü. Atlas'ın cümlesi kısaydı: “Dinlemek de üretmektir.”

{kahraman} en son yazdı: “Birbirimize rakip olduğumuzu düşünürken asıl sorunu kaçırıyorduk.”

Masadaki eski kupayı kaldırıp yeni takdir belgesinin yanına koydu. Artık ikisi de aynı yerde duruyordu. Biri geçmişte kazanılmış bir yarışmanın, öteki birlikte öğrenilmiş bir işin hatırasıydı.
---
@omurga
Sergiden bir hafta sonra okulun öğrenci meclisinden bir e-posta geldi. Daha fazla öğrenci okul çıkışındaki durakta beklerken yaşadığı sorunları anlatmak istiyordu. Selin Hanım mesajı okuduğunda heyecanlandı ama çocukları uyardı: “Bir prototip yaptığınız için gerçek ulaşım hizmeti verebileceğinizi düşünmeyin. Önce veri toplamadan, kişisel bilgileri koruma yöntemini ve kurum izinlerini konuşacağız.”

Bu kez kimse “Hemen uygulama yapalım,” demedi. {kahraman} küçük bir toplantı önerdi. Efe, soruların kişisel bilgi istememesi gerektiğini söyledi. {yoldas:yalin|bir arkadaş} güvenlik ve dayanıklılık koşullarını, Nisan farklı kullanıcıların nasıl katılabileceğini, Atlas ise elde edilen bulguların belediyeye nasıl açık ve abartısız aktarılabileceğini düşündü.

İlk oturumda herkes sırayla konuştu. {kahraman}, Atlas'ın önerisini dinlerken bilgisayarın kapağını kapattı. Atlas da {yoldas:ilgi|bir arkadaşın} cümlesi bitmeden kendi fikrini anlatmaya başlamadı. Bu küçücük hareketler ilk günün atölyesinde pek mümkün görünmezdi.

Toplantının sonunda proje dosyasına bir isim bulmaları gerekiyordu. Efe “Akıllı Durak 2” dedi. {yoldas:yalin|bir arkadaş} “Yeni Ortak Adım” önerdi. Nisan ise masadaki krokide yalnızca durakları değil, insanların yürüdüğü yolları gösterdi.
---
@omurga
“Bence,” dedi, “yeni projenin adı henüz belli olmasın. Ne yapacağımıza karar vermeden ad koyarsak yine çözümü sorundan önce seçmiş oluruz.”

{kahraman} kalemi bıraktı. Atlas gülümsedi. Hiç kimse bu öneriye karşı çıkmadı.

Pencerenin dışında okul servisleri sırayla hareket ediyordu. Bir araç durağa yaklaşırken yol kenarında bekleyen öğrenciler çantalarını omuzlarına aldı. Atölyedekiler henüz yeni bir makine tasarlamamıştı. Hatta yeni projenin ne olacağını da bilmiyorlardı. Ama kimin ihtiyacını dinleyeceklerini, hangi soruları soracaklarını ve emin olmadıkları noktaları nasıl belirteceklerini öğrenmişlerdi.

{kahraman} defterinin son sayfasına tek bir cümle yazdı: Birlikte çalışmak, herkesin aynı fikri savunması değil; farklı fikirlerin aynı problemi anlamak için yan yana gelmesidir.

Sonra defteri kapattı. Bu kez masanın hangi ucuna oturduğunun hiçbir önemi yoktu.
---
@omurga
- Dil: Önyargı, müzakere, varsayım, kanıt, bağlam; neden-sonuç ve ana düşünce. - Disiplinler: Teknoloji tasarımı, erişilebilirlik, etik veri kullanımı, güvenlik, kullanıcı araştırması. - Değerler: İş birliği, dürüstlük, sorumluluk, saygıyla anlaşmazlık çözme. - İkon adayları: durak, harita, rampa, düğme, kroki. - Yayın denetimi: Resmî kazanım kodu ve kaynak/telif denetimi henüz yapılmadı. Hikâyedeki prototip, gerçek yolcu bilgilendirme hizmeti değildir.
