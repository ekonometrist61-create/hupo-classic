---
baslik: "Mizah Gazetesinin İlk Sayısı"
slug: "hr076-mizah-gazetesinin-ilk-sayisi"
fis_kodu: "HR-076"
tur: mizah
konu: mizah_haber_kurmaca
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D15]
yetiskin_uygun: false
tanitim: "Okul gazetesinin ilk şakası bir düzeltme köşesiyle bitiyor. Mizah nerede biter, nerede başlar?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [dayanisma]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D15
  ogrenme_hedefleri:
    - {id: parodi_hr076, tur: lexeme, etiket: "parodi", yuva: hr076_parodi, islev: first_hint}
    - {id: abarti_hr076, tur: lexeme, etiket: "abartı", yuva: hr076_abarti, islev: application}
    - {id: deyim_hr076, tur: idiom, etiket: "Gözleri parlamak", yuva: hr076_gozleri, islev: application}
    - {id: kavram_hr076, tur: concept, etiket: "Haber, kurmaca ve parodi ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Duyuru panosundaki kâğıtta hangi cümle yazıyordu?", secenekler: [{id: A, metin: "Mizah kulübü kapandı."}, {id: B, metin: "Bu okulda mizah yasaklanmıştır!"}, {id: C, metin: "Şenlik iptal edildi."}, {id: D, metin: "Gazete çıkmayacak."}], dogru: B, aciklama: "Kâğıtta “Bu okulda mizah yasaklanmıştır!” yazıyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Yoldaşın bir haberin altına “Abartı olduğunu belirtelim” önermesinin amacı neydi?", secenekler: [{id: A, metin: "Gerçek olmayan bir haberin gerçek sanılmasını önlemek"}, {id: B, metin: "Gazetenin sayfa sayısını ve boyutunu artırmak"}, {id: C, metin: "Haberin kimin yazdığını okurdan tamamen gizlemek"}, {id: D, metin: "Okuru bilerek kızdırıp gazeteyi okutmamak"}], dogru: A, aciklama: "Uydurma bir haberin gerçek sanılmaması için kurmaca olduğu belirtilmelidir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 11, metin: "Öğretmene göre bir şakaya gülmeyen kişi için ne yapılmalıdır?", secenekler: [{id: A, metin: "Onu anlayışsız ilan edip bu konuyu kapatmak"}, {id: B, metin: "Gazetedeki bütün şakaları bir hafta durdurmak"}, {id: C, metin: "Şakayı daha yüksek sesle tekrarlamak"}, {id: D, metin: "Şakayı açıklamak, gerekirse değiştirmek"}], dogru: D, aciklama: "Mizahın karşılığı kişiden kişiye değişebilir; şaka açıklanabilir ya da yeniden yazılabilir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 9, metin: "Metinde geçen abartı ne anlama gelir?", secenekler: [{id: A, metin: "Gazetenin her sayfasında yer alan küçük bir köşe"}, {id: B, metin: "Bir durumu olduğundan çok büyük ya da küçük göstermek"}, {id: C, metin: "Karikatürde kullanılan renkli bir boyama tekniği"}, {id: D, metin: "Bahçede yetişen, yapraklarında desen bulunan bir bitki"}], dogru: B, aciklama: "Abartı, bir şeyi olduğundan büyük ya da küçük göstermektir."}
deyim_cumleleri:
  hr076_gozleri: "{kahraman:ilgi} gözleri parladı."
---
@omurga
Okulun koridorundaki duyuru panosuna asılan kâğıtta kocaman bir cümle yazıyordu: Bu okulda mizah yasaklanmıştır! Altında daha küçük harflerle, “Şaka yapmıyoruz, sadece gülüşmeleri denetliyoruz,” denmişti. Okuyan öğrenciler önce şaşırdılar, ardından kahkaha attılar. Kâğıdı asan {kahraman}, uzaktan arkadaşlarına başparmağını kaldırdı. Yanındaki {yoldas:yalin|bir arkadaş} ise kaşlarını çatmıştı. {isaret:yildiz}

“Bu, haber değil,” dedi {yoldas:yalin|bir arkadaş}. “Duyurunun gerçek sanılması mümkün.”

“İşte komik olan da bu,” diye karşılık verdi {kahraman}. “Herkes bir anlık şaşırıyor.”

Üçüncü arkadaşları Ela, duyurunun altına kırmızı kalemle bir söz ekledi: Mizah Kulübü deneme başlığıdır; gerçek duyuru değildir. Sonra ikisine döndü. “Bence bir mizah gazetesi çıkaralım. Böylece çocuklar bunun bir şaka olduğunu baştan anlar.”

[[deyim:hr076_gozleri]] Gazeteye Gülme Payı adını koydular. {yoldas:yalin|bir arkadaş} haberlerin yazımını, Ela çizimleri, {kahraman} da esprileri üstlenecekti. İlk sayıyı okul şenliğine yetiştireceklerdi. Başlangıçta çok kolay görünüyordu: Komik bir başlık bul, kısa yazı yaz, birkaç resim çiz ve çoğalt. Ama daha ilk toplantıda gazetenin en zor sorusuyla karşılaştılar. Bir şeyi komik yapan neydi; birini komik duruma düşüren şey mutlaka iyi bir şaka mıydı?
---
@omurga
{kahraman}, öğretmenler odasının önündeki sırayı anlatan bir haber yazdı. “Öğretmenlerin Çay İçme Rekoru: Dünya Yeniden Şaşkın,” diye başlamıştı. Ela gülümserken {yoldas:yalin|bir arkadaş} itiraz etti. “Kimseyi hedef göstermiyor ama gerçekmiş gibi sunarsak yanlış anlaşılır. Abartı olduğunu belirtelim.” {kahraman} başlığı değiştirdi: “Öğretmenler Odasında Hayalî Bir Çay Rekoru.” Yazının altına da “Tamamen uydurma mizah haberi” ibaresini eklediler. Böylece ilk kurallarını koymuş oldular: Gerçek bilgiyle uydurma şakayı birbirine karıştırmayacaklardı.

Gazetenin adı bulunmuştu ama ilk toplantılarının bir diğer sorunu kimin neyi yazacağıydı. {kahraman}, “Ben en komik olduğuma göre başlıkları ben bulacağım,” deyince {yoldas:yalin|bir arkadaş} itiraz etti. “Peki haberlerin kontrolünü kim yapacak? Yanlış bir şey yazarsan kim fark edecek?” Ela iki arkadaşının bir yarış içindeymiş gibi konuştuğunu sezdi. Masanın ortasına üç renkli kalem koydu. Mavi kalem araştırma, yeşil kalem çizim, kırmızı kalem kontrol içindi. Her yazının üç kalemden de geçmesine karar verdiler. Böylece biri bir fikri tek başına sahiplenmeyecekti.
---
@omurga
İlk prova yazısı okulun uzun merdivenleri hakkındaydı. {kahraman}, “Merdivenler dün gece uzadı!” diye bir başlık önerdi. Ela altına nefes nefese çıkan bir öğrenci çizdi. {yoldas:yalin|bir arkadaş} ise habere bakıp, “Öğrenciler burada gerçekten zorlanıyor mu?” diye sordu. Birkaç arkadaşları, ağır çantayla merdiven çıkmanın yorucu olduğunu anlattı. Fakat bazıları yalnızca merdivenin kendisini sevmediği için şaka yapıyordu. Üç arkadaş, bir yandan komik bir çizim hazırlarken öte yandan sınıf arkadaşlarına çantalarını gereğinden fazla doldurmamalarını hatırlatan kısa bir kutu ekledi. Bir merdivenin gerçekten uzadığını söylemediler; bunu herkesin şaka olarak anlayacağı biçimde çizdiler.

{kahraman} ertesi gün evde kardeşine gazetelerini anlattı. Kardeşi, “Ben de bir espri yapayım mı?” diye sorup masadaki kalemi sakladı. {kahraman} kalemi ararken kardeşi güldü. Birkaç dakika sonra {kahraman:ilgi} canı sıkıldı; çizimlerini bitirmesi gerekiyordu. Kardeşi kalemi geri verince ikisi de şaşkın şaşkın baktı. Kısa bir şaka, karşıdaki kişinin ihtiyacı görülmediğinde kolayca can sıkıcı olabiliyordu. {kahraman}, kendi esprilerinin karşısındakini nasıl etkileyebileceğini yeniden düşündü.
---
@omurga
İkinci gün gazetenin kapağına büyük bir karikatür geldi. {kahraman}, okulun kantin görevlisi Hasan Bey'i dev bir hamburgerin altında ezilmiş gibi çizmişti. Başlık da “Hasan Bey Yüz Hamburgerle Savaştı” idi. {kahraman} çizime güldükçe gülüyordu. {yoldas:yalin|bir arkadaş} ise çizimi masaya bıraktı. “Hasan Bey'in bundan haberi var mı?” diye sordu.

“Karikatür için izin mi alınır?” dedi {kahraman}.

“Bir insanın yüzünü ve işini kullanınca onu da düşünmek gerekir,” dedi Ela. “Hasan Bey her gün bizi karşılıyor. Onun kendisini küçük düşürülmüş hissetmesini istemem.”

{kahraman} biraz bozuldu. “Yani hiçbir şeyle şaka yapamayacak mıyız?”

{yoldas:yalin|bir arkadaş} sakin kaldı. “Kişiyle değil, durumla şaka yapabiliriz.” Bir örnek verdi: “Kantinde simitler sabah sekizde meydan okuyacak kadar çıtır” yazabilirlerdi. {kahraman} bunun da komik olabileceğini kabul etti ama çizimini bırakmak istemedi.
---
@omurga
İçlerinden biri Hasan Bey'e sormayı önerdi. Kantin boşken çizimi gösterdiler. Hasan Bey önce güldü, sonra ciddi bir ifadeyle konuştu. “Benimle dalga geçildiğini sanan olur,” dedi. “Çünkü geçen yıl kantinde bir tepsi düşürdüm, birkaç çocuk günlerce bunu taklit etti. O kadar çok tekrarlandı ki sonunda işimi yaparken çekinir oldum.”

{kahraman:ilgi} gülüşü söndü. Hasan Bey'in böyle bir anısı olduğunu bilmiyordu. “Özür dilerim,” dedi. “Bunu hiç düşünmemiştim.” Hasan Bey, “İnsan bir kez güler, sorun olmayabilir,” diye karşılık verdi. “Ama aynı kişiye sürekli dönüp gülersen o kişi kendini yalnız hissedebilir.”

Gazetenin karikatürü değişti. Artık dev hamburgerin altında kimse ezilmiyordu; hamburger, küçük bir simitten kaçıyor, simit de “Ben kahvaltının gerçek kahramanıyım!” diye bağırıyordu. Hasan Bey yeni çizimi görünce rahatça güldü. “Şimdi herkesin güleceği bir şaka olmuş,” dedi. {kahraman} o akşam defterine bir cümle yazdı: Şaka, gülenlerin sayısı kadar, gülmeyenleri de düşünmektir.
---
@omurga
Hasan Bey'le konuştuktan sonra üçü kantinin yanındaki küçük masaya oturdu. Ela, “İnsan önce kendi çizimine âşık olunca eleştiriyi duyması zorlaşıyor,” dedi. {kahraman} bunu kabul etti. Karikatürünü ilk çizerken hamburgerin komik görüntüsünü düşünmüştü; Hasan Bey'in hayatını değil. {yoldas:yalin|bir arkadaş}, mizahın bazen bir konuyu yumuşak biçimde eleştirmeye yarayabileceğini anlattı. “Ama bunun için asıl sorunu da görmeliyiz,” dedi. Kantinde kuyruk uzunsa, tek bir çalışanla alay etmek yerine kuyruk düzenini ya da bekleyenlerin sabırsızlığını anlatabilirlerdi.

Ertesi gün öğrencilerin önerileriyle yeni bir karikatür hazırladılar. Çizimde kantin kuyruğunun başına kocaman bir saat konmuştu. Saat, “Siz beklerken ben yaşlanıyorum,” diye yakınıyordu. Arkasındaki öğrenciler birer kalem gibi ince uzun çizilmişti; herkesin önünde aynı sayıda insan vardı ama herkes kendisinin daha uzun beklediğini sanıyordu. {kahraman} buraya bir başlık buldu: “Kuyruk Uzun, Sabır Kısa.” {yoldas:yalin|bir arkadaş}, başlığın bir gerçeği abartarak anlattığını, kimseyi hedef almadığını söyledi. Hasan Bey de karikatürü görünce, “Bunu masamın arkasına asabilirim,” diye güldü.
---
@omurga
Bu sohbetten sonra gazetenin ilk yeni sayfasına küçük bir kutu açtılar: Haber mi, hayal mi? Gerçek olaylara dayanan yazılarda kaynak gösterilecek, uydurma haberlerde {kelime:hr076_parodi} olduğu belirtilecek, kişileri konu alan yazılar ise izinsiz yayımlanmayacaktı. Ela bu kutunun gazetenin görünümünü bozacağından korktu. Sonra yanına küçük bir büyüteç çizdi. Artık kural, tasarımın bir parçası olmuştu. Çocuklar onu okurken kendilerini uyarılmış değil, oyuna davet edilmiş hissedebilirdi.
---
@omurga
Gazetenin üçüncü sayfasında röportaj yer alacaktı. Ela, okul bahçesindeki çok yaşlı çınar ağacıyla hayalî bir konuşma yazmayı teklif etti. Ağaç, öğrencilerin yıllardır aynı yerde sıraya girmesinden sıkıldığını anlatacaktı. Başlık Çınar Ağacı İtiraf Etti: “Teneffüsleri Ben de Seviyorum” oldu. {yoldas:yalin|bir arkadaş} metnin başına “Hayalî röportaj” yazdı. {kahraman}, ağacın ağzından komik cevaplar buldu. “Yapraklarım sınav döneminde dökülüyor, ben de stresliyim,” gibi bir cümle ekledi.

İlk prova sırasında dördüncü sınıftan bir öğrenci, ağacın gerçekten konuştuğunu sanıp öğretmenine sordu. Ela durumu açıkladı. “Sözlerimizi açık yazmamışız,” dedi. Yazının yanına çizgi roman tarzında büyük bir konuşma balonu yerleştirdiler ve altına “Ağacın gerçek sözleri değil, bizim hayalimiz” açıklamasını eklediler.
---
@omurga
{kahraman} bunun üzerine ironi ve {kelime:hr076_abarti} arasındaki farkı merak etti. {yoldas:yalin|bir arkadaş}, “Abartıda bir durumu bilerek olduğundan çok büyük ya da küçük gösteririz,” dedi. “İronideyse bazen söylediğimizin tersini düşündürerek eleştiri yaparız.” Örnek ararken bahçedeki geri dönüşüm kutusuna rastladılar. Kutunun kapağı açık kalmış, kâğıtlar rüzgârda savrulmuştu. {kahraman}, “Ne güzel, kâğıtlar geri dönüşüm kutusundan dışarıya terfi etmiş!” diye yazdı. Ela güldü: Bu cümle gerçekte yanlış yapılan bir işi övüyormuş gibi söyleyerek eleştiriyordu.

{yoldas:yalin|bir arkadaş}, “Ama okuyan herkes ironi olduğunu fark etmeyebilir,” diye uyardı. Yazının yanında, rüzgârda uçan kâğıtları toplamaya çalışan çocukları çizdiler. Böylece mizahın neyi eleştirdiği daha anlaşılır hâle geldi. Ayrıca yapılabilecek doğru davranışı da gösterdiler: Kutunun kapağını kapatmak ve çevreye saçılan kâğıtları toplamak.
---
@omurga
Gazete büyüdükçe okulda farklı öneriler gelmeye başladı. Beşinci sınıflardan bir grup, matematik sınavında çözemediği soruyu anlatan karikatür istedi. {kahraman}, tahtadan aşağı doğru akan rakamlar çizdi. Bir başka grup, kitaplıkta sessiz olunmasını çok sıkıcı buluyordu. Ela, rafların arasında fısıldaşan kitaplar resmi yaptı. Kitaplardan biri “Benim sonumu söylemeyin, henüz okunmadım,” diyordu. Bu çizime herkes güldü. {yoldas:yalin|bir arkadaş} bir kez daha hatırlattı: Şaka çocukları okumaktan uzaklaştırmamalı, belki merak etmeye yöneltmeliydi. Bu yüzden karikatürün altına haftanın kitap önerisi için küçük bir alan ayırdılar.

Bir öğrenci sınıf arkadaşının sürekli yanlış cevap vermesiyle ilgili espri göndermişti. {kahraman} ilk okuduğunda gülümsedi ama sonra kâğıdı sessizce geri verdi. “Bu kişinin adını çıkaralım demek yetmez,” dedi. “Olayı da değiştirmeliyiz. Yanlış cevap üzerinden değil, bir soruyu birlikte çözmenin güçlüğü üzerinden espri yapabiliriz.” O ana kadar {yoldas:ilgi|bir arkadaşın} uyarılarına kızan {kahraman:ilgi} kendiliğinden böyle düşünmesi Ela'yı sevindirdi. Karikatür, sınıftaki herkesin aynı anda el kaldırdığı, öğretmenin de “Sırayla, sırayla!” diye şaşırdığı bir sahneye dönüştü. Hata yapan tek bir öğrenci yoktu; ortak bir telaş vardı.
---
@omurga
Bir hafta sonra {kahraman}, mizah kitapları aramak için kütüphaneye gitti. Kütüphaneci ona hiciv, parodi ve karikatür sözcükleriyle ilgili kaynaklar gösterdi. {kahraman} bu kavramların aynı olmadığını öğrendi. Birinde bir davranış eleştiriliyor, diğerinde bilinen bir anlatım biçimi taklit edilerek yeni anlam oluşturulabiliyordu. Ama hepsinde okur ile yazar arasında bir anlaşma gerekiyordu: Okur, metnin hangi cümlesinin gerçek bilgi, hangisinin kurgu olduğunu ayırt edebilmeliydi. {kahraman} defterine bir örnek yazdı: “Okulun en hızlı kalemi kaçtı.” Altına hemen ikinci bir satır ekledi: “Bu gerçek bir olay değildir; kalemler koşmaz.” Sonra güldü. Bazen iyi mizah açıklamasını da yanında taşıyabilirdi.

Bir sonraki toplantıda gazeteye mektup yazan bir öğrenci, insanların her şakaya gülmek zorunda olup olmadığını sordu. {yoldas:yalin|bir arkadaş} bunu iyi bir soru olarak gördü. Öğretmenleriyle konuştular. Öğretmen, “Mizahın farklı insanlarda farklı karşılıklar bulması doğaldır,” dedi. “Bir kişi gülmediyse onu anlayışsız ilan etmeyin. Şakayı açıklayın, gerekiyorsa değiştirin.” {kahraman} bunu duyunca geçen yıl okul gösterisinde yaptığı bir espriyi hatırladı. Kimse gülmemişti, o da dinleyenlere kızmıştı. Şimdi sorunun bazen seyircide değil, anlatımda olabileceğini kabul ediyordu.
---
@omurga
Gazeteye “Okurun Gözünden” adlı küçük bir alan açtılar. Bir çizimin yanına iki farklı yorum koydular. Bir öğrenci, okul zilinin konuşmasını yalnızca komik bulmuştu; bir başkası ise zili sürekli duymanın bazı çocukları yorabileceğini yazmıştı. Ela, bu yorumları karikatürün altına sığdırmak için yeni bir düzen tasarladı. Her şeyin tek bir yoruma sığmadığını göstermek hoşuna gitti. {kahraman} ilk kez kendi esprisine itiraz edilmesini de gazetede görmeye razı olmuştu.
---
@omurga
Şenlikten iki gün önce biri gazetenin taslak sayfalarından birini fotoğraflayıp sınıf grubuna gönderdi. Görselin üstünde {kahraman:ilgi} henüz düzenlemediği bir başlık vardı: “Altıncı Sınıfın En Yavaş Koşanı Belli Oldu!” Başlığın altında bir öğrencinin adının geçtiği görülüyordu. Bu aslında {kahraman:ilgi} ilk karalama sayfasıydı; adı geçen öğrenci geçen hafta beden eğitimi dersinde düşmüştü. {kahraman} metni baskıya koymayacaktı ama taslağı silmeyi unutmuştu.

Ertesi sabah adı geçen öğrenci Deniz okula sessiz geldi. Teneffüste arkadaşlarının kendisine dönüp güldüğünü düşündü. Bir kısmı taslağı hiç görmemişti; yine de Deniz telaşlıydı. Ela hemen yanına gitti. “O fotoğrafı biz yayımlamadık. Yanlıştı, kaldıracağız,” dedi. Deniz, “Ama herkes gördü,” diye karşılık verdi. Bu cümle Ela'yı durdurdu. Bir şeyi geri çekmek, onun hiç yaşanmadığı anlamına gelmiyordu.
---
@omurga
Üç arkadaş rehber öğretmene durumu anlattı. Kimseyi suçlamak yerine taslağın nasıl yayıldığını anlamaya çalıştılar. Fotoğrafı paylaşan öğrenci kötü niyetli olmadığını söyledi; sadece komik bir başlık sandığını anlatıyordu. Ancak niyetin iyi olması, sonucun zararını ortadan kaldırmıyordu. Gruptaki paylaşımın silinmesi istendi. {kahraman} Deniz'den özür diledi, o da bu özrü hemen kabul etmek zorunda olmadığını söyledi. {kahraman} ilk kez bir şakanın sona ermesi için yalnız özür dilemenin yeterli olmayabileceğini anladı.

{yoldas:yalin|bir arkadaş}, gazeteye bir düzeltme köşesi eklemeyi önerdi. İlk yazı kendi hatalarına ayrılacaktı: “Bir taslakta bir arkadaşımızın adını kullandık. Bu doğru değildi. Mizahın amacı birinin zorlandığı anı tekrar tekrar göstermemeli.” Deniz'in adını tekrar yazmadılar. Rehber öğretmen metni gördü ve kişisel ayrıntıların paylaşılmadığından emin oldu. Böylece gazete ilk sayısında kendi yanlışından da söz etmiş oldu.
---
@omurga
Deniz'in adının paylaşıldığı olay, üç arkadaşın gazeteyi çıkarma isteğini sarsmıştı. Ela bir akşam “Belki hiçbir şey yayımlamasak daha iyi,” dedi. {yoldas:yalin|bir arkadaş} buna katılmadı. Hata yapmışlardı ama bu, sorumluluğu bırakmalarını gerektirmiyordu. {kahraman} ilk kez bir başlığı yazmadan önce kendisini Deniz'in yerine koymaya çalıştığını anlattı. “Biri benim zorlandığım anı gazetenin kapağına taşısa, başkalarının ne düşündüğünü merak edip dururdum,” dedi. Üçü gazeteyi yayımlamaya devam etmeye karar verdi; ama her yazı için küçük bir denetim sorusu oluşturdu: Bu bilgi doğru mu? Bu şaka kimi etkiler? Okur bunun kurgu olduğunu anlayabilir mi? Bir hata varsa nasıl düzelteceğiz?
---
@omurga
Şenlik hazırlıkları sırasında okul gazeteciliğinin teknik kısmıyla da uğraştılar. İzinli yazılar için öğrencilerden kısa onay aldılar. Fotoğraf kullanmak istediklerinde yüzü görünenlerin ve okul yönetiminin iznini aradılar. Sonunda yüz fotoğrafı yerine kendi çizimlerini kullanmak daha uygun geldi. Gazete hem daha özgün görünüyordu hem de insanların özel anlarını istemeden paylaşma riskini azaltıyordu. {yoldas:yalin|bir arkadaş} yazım denetimini yüksek sesle yaptı; bir kelimenin yanlış yazılınca anlamı değişebileceğini fark ettiler. “Yazım hatası bazen kendiliğinden mizah üretir,” dedi {kahraman}. “Ama biz yine de hatayı amaçlamayalım.”

Gazeteyi çoğaltacak öğretmen baskı düzenini gösterdi. Sayfaların kenarlarındaki yazılar kâğıttan taşmamalı, renkler birbirine karışmamalıydı. Ela ilk baskı örneğine bakınca konuşma balonlarından birinin yarısının kesildiğini gördü. “Önemli sözü tam sınırda bırakmışım,” dedi. Yeniden düzenledi ve sorunu çözdü. Çizimin güzel olması tek başına yetmiyordu; okunabilir olması da gerekiyordu. Son sayfa çıktığında üçü masanın başında birbirine baktı. Başlangıçta yalnız gülmek istemişlerdi. Şimdi biten şeyin bir gazete kadar ortak bir emek olduğunu hissediyorlardı.
---
@omurga
Baskıdan önce sayfaları başka bir sınıfa gösterdiler. Bir öğrenci “uçan kâğıtlar” başlığını gerçek bir haber sandı; Ela bu kez hemen savunmaya geçmedi. Başlığın altına küçük ama görünür bir “Hayalî öykü” notu eklediler. Bir başka çocuk şakayı anlamadığını söyleyince {kahraman}, “O zaman onu daha anlaşılır yazmalıyız,” dedi. {yoldas:yalin|bir arkadaş} gülmenin yalnız yazarın niyetine bağlı olmadığını düşündü; okurun gördüğü ve hissettiği de önemliydi. Son prova, gazetenin en komik sayfasını değil, en açık anlatılmış sayfasını bulmalarına yardım etti.
---
@omurga
Şenlik sabahı öğrenciler masalarını bahçeye kurdu. Gazetenin ilk yeni sayfaları oldukça rengârenkti: konuşan ağaçla hayalî röportaj, simitle hamburgerin atışması, uçan kâğıtlara ilişkin ironik köşe, “Sıra beklerken zaman yavaşlar mı?” adlı eğlenceli bilim yazısı. Son yazıda saniyelerin gerçekte değişmediği, beklerken zamanın uzun hissedilebileceği anlatılıyordu. {kahraman} buna “Zil Bilimi Enstitüsü” adını koymuştu. {yoldas:yalin|bir arkadaş} hemen altına “Hayalî kurum” ibaresini eklemişti.

Masaya ilk gelenlerden biri Deniz oldu. Gazetenin kapağını inceledi. {kahraman} bir şey söylemek için ağzını açtı ama Deniz önce kendi seçtiği sayfayı okumak istedi. Konuşan ağaç hikâyesine gülümsedi. Sonra düzeltme köşesini gördü ve bir süre sessiz kaldı. “Hatanızı saklamamanız iyi olmuş,” dedi. “Ama bir daha taslaklarda da arkadaşlarınızın adını izinsiz kullanmayın.” {kahraman} başını salladı. “Haklısın,” dedi. “Söz veriyorum.”
---
@omurga
Öğretmenler ve öğrenciler gazetenin yanına öneri kutusu bıraktılar. Bir çocuk okulun en uzun kuyruğunu çizmelerini istedi. Başka biri koridorlarda çanta taşımanın zorluğuyla ilgili bir karikatür önerdi. Hasan Bey, kantinde çayın sürekli soğumasından yakınan bir simit karakteri eklemek istedi. {yoldas:yalin|bir arkadaş}, yeni fikirleri bir listeye yazarken her biri için küçük bir soru soruyordu: “Bu şaka kimi hedef alıyor, okuyan nasıl anlayacak, biri rahatsız olabilir mi?” {kahraman}, “Mizah komisyonu kurduk resmen,” diye takıldı. Ela ise cevap verdi: “Hayır, yalnızca birbirimize karşı sorumlu davranıyoruz.”

Gazeteyi tasarlarken Ela ayrıca bir renk sorunu fark etmişti. Sarı kâğıt üzerine açık yeşil yazı koyduğunda bazı arkadaşları başlıkları güçlükle okuyordu. Bunun üzerine koyu renk yazılarla denemeler yaptılar. {kahraman} “Mizah her renkte komik olur,” diye şaka yaptı. Ela, “Ama önce okunması gerekir,” diye cevap verdi. Bu küçük ayrıntı gazeteyi yalnız görsel olarak değil, daha fazla öğrenci için kullanışlı hâle getirdi. Çalışmalarını panoya asmadan önce küçük bir grupla test ettiler; onların anlamadığı yerlere yeniden baktılar.
---
@omurga
Gazetenin tam ortasında herkesin rahatça görebildiği büyük karikatür herkesin ilgisini çekti. Bir öğrenci, okuldaki kayıp eşyaların gizli bir toplantı yaptığı odayı çizmişti. Bir çorap “Ben spor salonundan kaçtım,” diyor, bir su şişesi “Kapağımı bulursanız kimliğimi açıklarım,” diye bağırıyordu. Okuyan çocuklar hep birlikte hem gülüyor hem de eşyalarına isim yazmanın faydasını konuşuyordu. Kimsenin adı geçmiyor, kimse utandırılmıyordu. Şaka yine de güçlüydü.

Şenlik için hazırlanmış başka bir köşede “Yanlış Anlaşılan Başlıklar” adlı küçük bir oyun bulunuyordu. Ziyaretçiler iki başlıktan hangisinin gerçekten okul duyurusu olabileceğini seçiyordu. Biri “Okul Bahçesinde Yarın Ağaç Dikimi Var”, öteki “Ağaçlar Sınıf Başkanlığına Aday” idi. Küçük öğrenciler ikinci başlığa gülüyor, ama sonra ilk başlığın gerçek bir duyuru olabileceğini söylüyordu. {yoldas:yalin|bir arkadaş} burada çocuklara kaynak işaretini gösterdi: Gerçek duyurularda tarih, yer ve sorumlu kişi bulunuyordu. Mizah metinlerinde ise kurmaca olduğu açıkça belirtiliyordu. Böylece şaka, çocukların dikkatli okuma becerisine de hizmet etti.
---
@omurga
Öğleden sonra okul müdürü yanlarına uğradı. Gazetenin çıkış amacını dinledi, düzeltme köşesini okudu. Sonra “İlk sayınızda hangi haberi doğrulamak en zor oldu?” diye sordu. {yoldas:yalin|bir arkadaş}, bekleme süresinin herkese uzun gelmesinden söz etti; bunu nesnel bir gerçek gibi yazmamak gerektiğini anlattı. Müdür, “Bu iyi bir ayrım,” dedi. “Duygu ile ölçüm birbirine karışınca haber yanıltıcı olabilir.” Ela, gazeteye isteyenlerin gözlemlerini paylaşabileceği yeni bir alan koymayı önerdi; fakat kimsenin sözünü ölçüm sonucu gibi sunmamaya dikkat edeceklerdi.

Şenlik bitiminde Selin Hanım üç arkadaşın yanına geldi. “İlk sayıyı çıkarabildiniz,” dedi. “Peki en çok ne öğrendiniz?”

{kahraman}, “En komik şakanın bazen ilk aklıma gelen olmadığını,” diye cevap verdi. {yoldas:yalin|bir arkadaş}, “Doğru bilgiyle kurmacanın karıştırılmaması gerektiğini,” dedi. Ela ise gülümseyerek, “Dinleyenin duygusunu düşünmenin şakayı öldürmediğini, bazen daha yaratıcı yaptığını,” söyledi.
---
@omurga
Şenlikte bir grup küçük öğrenci karikatürleri anlamakta zorlandığını söyledi. Ela onlarla konuştu ve bazı konuşma balonlarının çok uzun olduğunu fark etti. Bir sonraki sayıda daha kısa cümleler, daha okunaklı yazılar kullanmaya karar verdi. {yoldas:yalin|bir arkadaş} metinlerin yanında küçük “Bu bir kurgu” etiketini büyük ve anlaşılır tutacaktı. {kahraman} ise herkesin hemen anlayabileceği bir görsel şaka bulmak istedi. Böylece her geri bildirim, kendilerini eleştirilmiş hissetmelerine değil, yeni bir tasarım denemesine dönüşüyordu.

Bir veli de gazeteyi okudu, “Çocuklar okul kurallarıyla alay ediyor mu?” diye sordu. Ela ona parodi köşesini gösterdi. Veli çizimdeki konuşan zil sesine güldü ve açıklamayı okudu. “Demek yazıyla görsel birbirini tamamlıyor,” dedi. Bu cümle {kahraman:ilgi} aklında kaldı. Komik bir çizim, okuyanın doğru düşünmesine de yardımcı olabilirdi. Ama yanlış anlaşılma ihtimali varsa yazarın bunu görmezden gelmemesi gerekirdi. Üç arkadaş öneri kutusunu şenlikten sonra da kaldırmadı. Kimse yazı göndermese bile bir sonraki sayıda okurlara soracakları yeni sorular olduğunu biliyorlardı.
---
@omurga
Baskının ardından {yoldas:yalin|bir arkadaş} gazeteyi eve götürüp küçük kardeşine okuttu. Kardeşi konuşan ağaç röportajında gerçekten bir ağacın konuştuğuna inanmamıştı ama ağacın neden sessizliği istediğini anlamakta zorlandı. {yoldas:yalin|bir arkadaş} ona bunu “İnsanlar ağacın yanında çok yüksek sesle konuşuyor” diye açıklayınca kardeşi gülümsedi. Gazetede bazen tek bir açıklayıcı cümlenin bütün farkı oluşturabildiğini gördü. Ertesi gün Ela'ya bir öneriyle geldi: Karikatürün yanına uzun bir ders notu değil, hikâyeyi anlamayı kolaylaştıran küçük bir işaret koyabilirlerdi. Ela, konuşma balonunun köşesine “hayal” simgesi ekledi. İlk sayının son baskısı daha anlaşılır olmuştu.

{kahraman} da gazetenin arkasına kendi kendine küçük bir soru yazdı: Bir şakayı anlamak için kimi dinlemeliyim? Altına üç cevap koydu: yazanı, şakaya konu olanı ve okuyucuyu. Hepsi aynı fikirde olmayabilirdi ama üçünün bakış açısı da önemliydi. Bunu kabul etmek {kahraman:yonelme} önceleri gereksiz bir yük gibi gelmişti. Şimdi yeni bir karikatür çizerken eskisinden daha çok seçenek buluyordu. Zorlandığında şakayı bırakmak yerine başka bir anlatım yolu arıyordu.
---
@omurga
Akşam okulun panosuna ikinci sayı için yeni bir duyuru asıldı: Mizah serbesttir. Düşünmek zorunlu değildir ama çok tavsiye edilir. Altında küçük bir not vardı: Bu bir mizah gazetesi duyurusudur. Gerçek okul kurallarını yönetim duyurularından öğreniniz.

{kahraman} kâğıda bakıp güldü. “Bu kadar açıklama ekleyince komik olmuyor sanıyordum,” dedi.

{yoldas:yalin|bir arkadaş} omzunu silkti. “Bence asıl komik olan, **önce yanlış anladığımız şeyin doğruyu öğrenince de gülümsetmesi**.”

Bir sonraki sayı için masaya oturduklarında üç arkadaş artık önce “En komik ne yazabiliriz?” diye sormadı. Önce ne anlatmak istediklerini belirledi. Sonra o düşünceyi gülümseten bir biçimde söylemeye çalıştı. Bu sıralama onları sıkıcı yapmadı; aksine gazetenin bambaşka yeni fikirlerle dolmasını sağladı. Ela boş sayfaya kocaman bir gülen yüz çizdi, {yoldas:yalin|bir arkadaş} yanına küçük bir büyüteç koydu, {kahraman} ise altına şunu yazdı: Bak, düşün, sonra gül.
---
@omurga
Ela gazeteyi katladı. İkinci sayının boş sayfaları onu bekliyordu. Bu kez yeni sayı için ne yazacağını henüz tam olarak bilmiyordu; ama neyi yazmaması gerektiğini daha iyi biliyordu. Bu, çocukların hayal gücünü daraltan değil, ona yeni ve daha dikkatli bir yön veren gerçek bir başlangıçtı.
