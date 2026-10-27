---
baslik: "Yitik Zamanın Haritacıları"
slug: "hr110-yitik-zamanin-haritacilari"
fis_kodu: "HR-110"
tur: fantastik
konu: bellek_kanit
sinif_alt: 8
sinif_ust: 8
okuma_bandi: 3
dunya_tipi: masalsi
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Hatıralara göre değişen haritalar şehrinde {kahraman} ile {yoldas:yalin|bir arkadaş}, anı ile ortak kanıtı ayırmayı öğrenir ve kayıp mahalleyi bulur."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 8
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [kesif, bilim_teknoloji]
  ders_baglantisi: [turkce, sosyal]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: kanit_hr110, tur: lexeme, etiket: "kanıt", yuva: hr110_kanit, islev: first_hint}
    - {id: tanik_hr110, tur: lexeme, etiket: "tanık", yuva: hr110_tanik, islev: application}
    - {id: olcu_hr110, tur: lexeme, etiket: "ölçü", yuva: hr110_olcu, islev: application}
    - {id: tutarsiz_hr110, tur: lexeme, etiket: "tutarsız", yuva: hr110_tutarsiz, islev: transfer}
    - {id: deyim_hr110, tur: idiom, etiket: "Kulak kesilmek", yuva: hr110_kulak, islev: application}
    - {id: kavram_hr110, tur: concept, etiket: "Anı ile ortak kanıtı ayırmak", islev: application}
  kanit_duzeyi: C
  program_surumu: "Önceki program (8. sınıf; geçiş dönemi, resmî program eşleştirmesi insan editörce yapılacak)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 6, metin: "Kahramanın hatırasında Çınaraltı'na giden yol hangi köprüden geçiyordu?", secenekler: [{id: A, metin: "Balıkçı Köprüsü"}, {id: B, metin: "Saat Köprüsü"}, {id: C, metin: "Tuz Köprüsü"}, {id: D, metin: "Kumsaat Köprüsü"}], dogru: C, aciklama: "Kahramanın hatırasında yol Tuz Köprüsü'nden geçiyordu; yoldaşı ise Balıkçı Merdiveni'ni hatırlıyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 9, metin: "Kahramanın “Yani çok kişinin aynı şeyi söylemesi doğru olduğunu göstermez.” sözünden ne çıkarılabilir?", secenekler: [{id: A, metin: "Kalabalığın birlikte söylediği her şey kesinlikle doğrudur ve sorgulanmaz"}, {id: B, metin: "Kişisel hatıralar hiçbir durumda bilgi kaynağı olarak güvenilir sayılamaz"}, {id: C, metin: "Yalnızca haritacılar ve loncanın ustaları doğruyu bilebilir"}, {id: D, metin: "Bir bilginin çok kişi tarafından söylenmesi tek başına doğru olduğunu garanti etmez"}], dogru: D, aciklama: "İnsanlar birbirlerinden etkilenebilir; çok kişinin söylemesi, bilginin doğru olduğunu tek başına göstermez."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 8, metin: "Yoldaşa göre anı neyi söyler?", secenekler: [{id: A, metin: "Bir şeyin ölçüsünü kesin ve sayısal olarak"}, {id: B, metin: "Bir şeyi kimin, hangi amaçla yaptığını"}, {id: C, metin: "Bir şeyin bizim için nasıl olduğunu"}, {id: D, metin: "Bir şeyin tam olarak hangi yılda yapıldığını"}], dogru: C, aciklama: "Yoldaş, anının bir şeyin bizim için nasıl olduğunu söylediğini, başkasının doğrulayabileceği bilgi vermediğini belirtir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 9, metin: "Bu ifadede “bağımsız” ne anlama gelir?", secenekler: [{id: A, metin: "Parası olmayan, maddi sıkıntı içindeki"}, {id: B, metin: "Birbirinden etkilenmeden, ayrı ayrı karar veren"}, {id: C, metin: "Hiçbir konuda bilgisi olmayan ve düşünmeyen"}, {id: D, metin: "Aynı evde ve aynı odada birlikte yaşayan"}], dogru: B, aciklama: "Bağımsız iki kişi, birbirinden etkilenmeden aynı sonuca ulaşan kişilerdir."}
  - {id: s5, beceri: degerlendirme, dayanak_sayfa: 20, metin: "Metne göre haritadaki kanıt katmanı ne zaman değişebilir?", secenekler: [{id: A, metin: "Başka biri kontrol edip aynı sonuca vardığında"}, {id: B, metin: "Bir haritacı kendi çizgisinden çok emin olduğunda"}, {id: C, metin: "Kum saatinin üst camındaki kum tükendiğinde ve ters çevrildiğinde"}, {id: D, metin: "Şehirdeki herkes aynı şeyi hatırladığında ve tekrar ettiğinde"}], dogru: A, aciklama: "Kanıt katmanı, ancak başka biri kontrol edip aynı sonuca vardığında değişir; emin olmak ya da kalabalık olmak yetmez."}
deyim_cumleleri:
  hr110_kulak: "{yoldas:yalin|bir arkadaş} kulak kesildi."
---
@omurga
Kumsaat Şehri'nde haritalar kâğıda çizilmezdi, hatıraya çizilirdi. Bir haritacı gözlerini kapatıp bir sokağı yeterince canlı hatırlarsa kâğıdın üzerinde ince mürekkep çizgileri kendiliğinden belirirdi. Çeşmeler, çınarlar, merdivenler yerlerini bulurdu. Şehrin ortasındaki saat kulesinde dev bir kum saati dururdu. Üstteki camdan alttakine kum aktıkça şehirdeki herkesin anıları birbirine biraz daha yaklaşırmış, derlerdi.

{kahraman} on dört yaşındaydı ve haritaların kıpırdadığını o sabah gerçekten fark etti. Odasının duvarındaki mahalle haritasında Fırın Sokağı bir gecede sola kaymıştı. Dün akşam babası ile fırının önünde simit yediğini hatırlıyordu ve fırın sağdaydı. Harita ise başka bir şey söylüyordu. {kahraman} bir süre baktı. Sonra kendi hatırasından emin olmadığını düşündü. Tam o anda sokağın çizgisi titredi ve bu kez ortaya doğru kaydı.

{kahraman} haritayı duvardan indirip pencerenin önüne götürdü. Dışarıda fırın gerçekten sağdaydı, bacasından ince bir duman çıkıyordu. Yani harita yanılıyordu. Ya da harita, {kahraman:ilgi} yarım yamalak hatırasına uyum sağlıyordu. Bu ikinci ihtimal onu ürpertti. Çünkü haritaların güvenilir olduğuna inanarak büyümüştü. Şimdi ise elindeki kâğıdın, kendisinin ne kadar emin olduğuna göre biçim değiştirdiğini görüyordu. Bir yolu bulmak için hatırlamak gerekiyordu, ama hatırlamanın kendisi yolu değiştiriyordu.
---
@omurga
{kahraman} o gün çıraklık sınavı için Haritacılar Loncası'na gitti. Lonca, eski bir tahıl ambarının içindeydi. Duvarlarda binlerce harita asılıydı ve hepsi çok hafif nefes alıyormuş gibi oynuyordu. Başharitacı Orhan Usta sınava gelenlere kısa bir konuşma yaptı.

“Bir harita, hatırlayanın kalbinden akar,” dedi. “Hatırayı güçlü olan, yolu en iyi çizer.”

{kahraman} bu cümleyi defterine yazdı, ama yanına küçük bir soru işareti koydu. Güçlü hatıra, doğru hatıra demek miydi? Babası bir keresinde ona çocukken geçtiği bir nehri anlatmıştı. Nehir o hikâyede kocamandı. Büyüyünce aynı nehre gittiklerinde {kahraman} onun bir dere kadar dar olduğunu görmüştü. Hatıra yalan söylememişti belki, ama ölçüsünü de vermemişti.

Sınav basitti ve bir o kadar da zordu. Her aday, çocukluğundan bir sokağı gözlerini kapatıp çizecekti. {kahraman} kendi evinin önündeki kaldırımı çizdi. Çizgiler akıcıydı, renkler canlıydı. Fakat sınav bitince gözcü haritacı, kaldırımdaki taşların sayısını sordu. {kahraman} bilemedi. Gözcü kafasını salladı, ama sınavı geçirdi. “Hatırlama gücün iyi,” dedi. “Merak gücün daha da iyi. Bu lonca ikisine de ihtiyaç duyar.” {kahraman} bu sözün bir övgü mü yoksa bir uyarı mı olduğunu çıkışta bile çözemedi.
---
@omurga
Sınavı geçenler iki kişilik ekipler kurdu. {kahraman:yonelme} {yoldas:yalin|bir arkadaş} adında, sessiz ve dikkatli bir çocuk düştü. {yoldas:ilgi|bir arkadaşın} cebinde daima bir ölçü ipi, kulağının arkasında da kısa bir kurşun kalem bulunurdu. Haritayı hatırayla çizmeyi becermek zorundaydı ama bunu pek sevmiyordu.

“Ben bir yeri hatırlayınca ne çizdiğimi bilemiyorum,” dedi ilk gün. “Çizgi çıkıyor, ama o benim anım mı yoksa gerçek mi, ayıramıyorum.”

{kahraman} ona şaşkınlıkla baktı. Aynı soruyu sabahtan beri kendi kendine soruyordu. “Peki ne yapıyorsun?” diye sordu.

“Ölçüyorum,” dedi {yoldas:yalin|bir arkadaş} ve ipini gösterdi. “Adım sayıyorum. İpin boyunu bir yere yazıyorum.”

Orhan Usta'nın onlara verdiği ilk görev tuhaftı. Şehrin eski bir mahallesi olan Çınaraltı, haritalardan silinmeye başlamıştı.

{kahraman} ile {yoldas:yalin|bir arkadaş} ilk günü loncanın avlusunda, yan yana oturup geçirdi. Birbirlerinden çok farklı çalışıyorlardı. {kahraman} gözlerini kapatıyor, dakikalarca sessiz kalıyor, sonra kâğıda seri seri çizgiler döküyordu. {yoldas:yalin|bir arkadaş} ise hiçbir şeye hemen inanmıyor, her çizgiyi iki kez kontrol ediyordu. Başta birbirlerini yavaş ya da sakar buldular. Akşama doğru ise bu farkın bir eksiklik değil, birbirini tamamlayan iki bakış olduğunu sezmeye başladılar. Avludaki çeşmenin başında su içerken ikisi de aynı anda gülümsedi.
---
@omurga
Çınaraltı'nı bütün yaşlılar bilirdi. Bir zamanlar dar sokakları, taş çeşmeleri ve yüz yıllık çınarlarıyla ünlüydü. Fakat son aylarda şehir haritalarında Çınaraltı'nın yerinde sadece bulanık, gri bir leke vardı. Haritacılar onu çizmeye çalıştıkça çizgiler birbiriyle çelişiyor, sokaklar bir sabah bir yerde, ertesi sabah başka yerde beliriyordu.

Şehir meclisi de endişeliydi. Çınaraltı'nda hâlâ yaşayan birkaç aile vardı ve onlara su taşıyan arabalar her gün uzun bir yol yapıyordu. Meclis, kaynağı bulacak kişiye ödül vaat etmişti, ama haritalar anlaşamadığı için kimse nereden başlayacağını bilmiyordu. Her haritacı kendi çizgisini savunuyor, öbürünün haritasına şüpheyle bakıyordu. Loncada günlerdir yüksek sesli tartışmalar yapılıyordu ve bu tartışmaların her biri haritaları biraz daha buruşturuyordu.

Üstelik şehirde su sorunu başlamıştı. Çınaraltı çeşmelerinin kaynağı kurumuş, kaynağın hangi yolla şehre ulaştığını da kimse hatırlamıyordu. Orhan Usta masaya yirmi kadar harita serdi.

“Hepsi aynı mahalleyi gösteriyor,” dedi. “Fakat hiçbiri öbürüne benzemiyor. Doğru olanı bulun.”
---
@omurga
{kahraman} bir haritaya, {yoldas:yalin|bir arkadaş} ise ötekine baktı. Sonra birbirlerine döndüler. İkisi de kendi haritasının doğru olduğundan çok emindi.

Orhan Usta, bu işin neden kolay olmadığını anlattı. Çınaraltı'nı hatırlayabilecek insanlar şehrin her yerine dağılmıştı. Bir kısmı taşınmış, bir kısmı yaşlanmıştı. Gençler ise mahallenin yalnızca hikâyesini duymuştu. Üstelik bir hatıra ne kadar çok anlatılırsa o kadar parlıyor, ama o kadar da değişiyordu. “Haritalar hatıraları taşır,” dedi Usta. “Hatıralar da zamanla yolda dökülür.” Sonra gözlerini kısıp çocuklara baktı. “Siz bu yolda dökülenleri toplayacaksınız.”
---
@omurga
{kahraman:ilgi} hatırasında Çınaraltı'na giden yol, Tuz Köprüsü'nden geçiyordu. Çocukken dedesinin elinden tutup o köprüyü aşmış, karşıda çınarların gölgesine girmişti. Hatırası o kadar canlıydı ki haritasında köprünün taş korkulukları bile ayrıntılıydı.

{yoldas:ilgi|bir arkadaşın} haritasında ise köprü hiç yoktu. Onun çizgileri bir merdivenden başlıyordu. Balıkçı Merdiveni denen bu yokuştan inilince Çınaraltı'nın kapısına varılırdı. {yoldas:yalin|bir arkadaş} bunu annesinin her cumartesi onu o merdivenden pazara götürmesinden biliyordu.

“Köprü vardı,” dedi {kahraman}.

“Merdiven vardı,” dedi {yoldas:yalin|bir arkadaş}.

İki harita masanın üzerinde yan yana durdu. {kahraman:ilgi} çizdiği köprü ile {yoldas:ilgi|bir arkadaşın} çizdiği merdiven, aynı yerde üst üste binmeye çalıştı ve kâğıt kıvrılıp buruştu.

{kahraman} bir an haritasını yırtıp atmak istedi. Sonra bunun hiçbir şeyi çözmeyeceğini düşündü. {yoldas:yalin|bir arkadaş} da kendi çizgilerine bakıp omuzlarını düşürmüştü. Onlar için asıl zor olan, kendi anılarının başkasının anılarıyla çatıştığını görmekti. Çünkü bir hatıranın yanlış çıkabileceğini kabul etmek, kendi geçmişinden bir parçayı bırakmak gibi geliyordu. Yine de ikisi de biliyordu ki iki haritanın ikisi birden tam doğru olamazdı. Biri yanılıyordu ya da ikisi de eksikti.
---
@omurga
Tartışmayı bırakıp eski saat kulesine gittiler. Kulenin bekçisi Nine Seher, kum saatinin yanında oturup çorap örüyordu. Kırk yıldır kuleye bakıyordu ve şehrin pek çok sırrını bildiği söylenirdi.

“Çınaraltı mı?” dedi. “Orası bir zamanlar çok güzeldi. Köprüyü de hatırlıyorum, merdiveni de.”

“İkisi birden mi?” diye sordu {kahraman}.

“Belki ikisi de vardı, belki biri sonradan yapıldı. Ben yaşlandıkça hatıralarımın tarihlerini karıştırıyorum.” Nine Seher ellerini dizine koydu. “Kum saati bize zamanın aktığını gösterir, ama neyin ne zaman olduğunu söylemez. Onu başka şeylerden öğrenmek gerekir.”

[[deyim:hr110_kulak]] “Nelerden?” dedi.

“Yazıdan, taştan, ölçüden. Ve senin bilmediğin birinin sözünden.”

{kahraman} kum saatinin camına yaklaştı. Kum taneleri ince bir iplik gibi akıyordu. Cama dokununca serin bir titreşim hissetti. Nine Seher gülümseyerek, “Her gelen çocuk önce buna dokunur,” dedi. “Sanırlar ki zamanın içinden bir şey duyacaklar. Oysa zaman sadece akar. Onun içine ne koyduğumuz bize kalmış.” Sonra çorabına döndü ve çocuklara yeni bir soru bıraktı: “Anıyı bir tohum sayın. Tohumdan ağaç çıkar. Ama tohum ile ağaç aynı şey değil. Siz tohumla ağacı birbirinden ayırabilir misiniz?”
---
@omurga
O akşam defterlerini yan yana koyup oturdular. {kahraman}, anılarının neleri anlattığını yazmaya karar verdi. Köprünün taş korkuluklarını, dedesinin elini, çınarların altındaki serinliği, havadaki ekmek kokusunu hatırlıyordu. Her ayrıntı onun için canlıydı.

{yoldas:yalin|bir arkadaş} sayfaya dikkatle baktı. “Bunların hepsi gerçek olabilir,” dedi. “Ama bir şey var. Bunlar senin nasıl hissettiğini anlatıyor. Köprünün kaç adım olduğunu, hangi yıl yapıldığını, kim yaptığını yazmamışsın.”

“Çünkü bilmiyorum.”

“İşte,” dedi {yoldas:yalin|bir arkadaş}. “**Anı bize bir şeyin bizim için nasıl olduğunu söylüyor**. Başkasının da kontrol edebileceği bir şeyi söylemiyor.”

{kahraman} bu cümleyi bir süre düşündü. Kendi anısının değersiz olmadığını biliyordu. Ama tek başına haritaya yetmediğini de ilk kez bu kadar açık görüyordu.

Düşündükçe anılarının bir başka özelliğini de fark etti. Hepsi onun bakış açısından anlatılıyordu. Dedesinin elini hatırlıyordu ama dedesinin o gün neden o yolu seçtiğini bilmiyordu. Havadaki ekmek kokusunu biliyordu ama kokunun hangi fırından geldiğini bilmiyordu. Anı bir pencere gibiydi: bir yeri çok net gösteriyor, ama pencerenin dışında kalanları karanlık bırakıyordu. Bu yüzden anılar çok değerli, ama tek başlarına eksik bir yol göstericiydi.
---
@omurga
Ertesi sabah {yoldas:yalin|bir arkadaş} defterine yeni bir sayfa açtı ve iki sütun çizdi. Soldaki sütuna “Anılar” yazdı. Sağdakine ise “Ortak kanıt” başlığını koydu.

“Bir şeyin {kelime:hr110_kanit} sayılması için,” dedi, “benden başka birinin de gidip bakabilmesi, ölçebilmesi ya da aynı sonuca ulaşabilmesi gerekir.”

“Peki ya herkes aynı şeyi hatırlıyorsa?”

“O zaman bile hatıralar birbirinden etkilenmiş olabilir. İnsanlar bir şeyi birbirlerine anlata anlata aynı biçime sokabilir.”

{kahraman} kaşlarını çattı. “Yani çok kişinin aynı şeyi söylemesi doğru olduğunu göstermez.”

“Her zaman göstermez. Ama birbirinden bağımsız iki kişinin, ayrı ayrı ve ölçülebilir bir şeyi aynı bulması başka bir durum.”

İkisi de haritacılığın bu kısmını hiç öğrenmediklerini fark ettiler. Loncada kimse ne hatırladığını sorgulamıyordu.

{kahraman} sağ sütuna ilk satırı yazmakta zorlandı. Sonunda “Köprü ayağı” yazıp üstünü çizdi ve “Kıyıda taş bir kütle var” diye değiştirdi. {yoldas:yalin|bir arkadaş} onun bu özenine gülümsedi. “Doğru yaptın,” dedi. “Köprü demek bir yorum. Taş kütle demek ise herkesin bakıp görebileceği bir şey.” {kahraman} bu ayrımı çok sevdi. Gördüğü ile yorumladığını ayırmak, düşünmeye başka bir kapı açıyordu. O akşam yalnız bir sayfa doldurdular ama ikisi de bir günde bu kadar öğrendiğini sanmıyordu.
---
@omurga
Önce Tuz Köprüsü'nün olması gereken yere gittiler. Nehir yatağında bir iz aradılar. Kıyıda köprünün taş ayağından kalma yosunlu bir kütle buldular. {kahraman} sevinçle bağırdı. Fakat {yoldas:yalin|bir arkadaş} ipini çıkarıp kıyıdaki taşın boyunu ölçtü, ayaklarını yere basarak adımlarını saydı.

“Bu bir köprü ayağı olabilir,” dedi. “Ama bir iskele de olabilir. Eski balıkçılar buraya tekne bağlıyor olabilir.”

“Ama ben köprüyü hatırlıyorum.”

“Biliyorum. Bu hatıranı yok saymak değil. Sadece taşın kendi başına neyi kanıtladığına bakıyoruz.”

{kahraman} içindeki öfkenin bir anda söndüğünü hissetti. {yoldas:yalin|bir arkadaş} ona karşı çıkmıyordu. Onun anısını kenara koymuyor, yalnızca onu sağlamlaştırabilecek şeyler arıyordu. Harita o sırada {kahraman:ilgi} cebinde hafifçe ısındı.

Dönüş yolunda {yoldas:yalin|bir arkadaş} ona kıyıdan aldığı üç ölçüyü gösterdi. Taşın boyu, genişliği ve nehre olan uzaklığı. “Yarın bunları başkasına da ölçtüreceğim,” dedi. “Aynı sayıları bulursa, bu taşın boyu artık benim fikrim olmaktan çıkar. Ortak bir bilgi olur.” {kahraman} başını salladı. Kendi hatırasını da böyle ortak bir bilgiye çevirmenin yolu olup olmadığını merak etti. Ama bir an sonra bunun pek mümkün olmadığını anladı. Anı kimseye geçmezdi. Ona yalnızca kendi anlatabilirdi.
---
@omurga
Üçüncü gün çarşıya indiler ve kime rastlarsa Çınaraltı'nı sormaya başladılar. Simitçi Cemal Amca, köprüden geçtiğini söyledi. Eski bir pabuççu, merdivenin kırk basamaklı olduğunu anlattı. Çocuk yaştaki iki kardeş ise mahalleye dere kenarından giden bir patikayı hatırlıyordu.

{yoldas:yalin|bir arkadaş} her birinin sözünü defterine tarihiyle birlikte yazdı. Kimin ne zaman, nerede, kimden duyduğunu da not aldı.

“Bu insanlar {kelime:hr110_tanik},” dedi. “Ama her tanığın sözü aynı ağırlıkta değil. Kendi gözüyle görene daha çok bakarız. Duyduğunu söyleyene daha az.”

“Kim kimden duymuş, nasıl anlayacağız?”

“Soracağız. ‘Siz mi gördünüz, yoksa size mi anlatıldı?’ diye.”

Bu soru çoğu insanı duraksattı. Bazıları, dürüstçe, bir şeyi çok defa dinlediklerinden artık kendi anıları gibi hatırladıklarını söyledi.

Gün sonunda defterde yirmi iki kayıt vardı. Bunların yalnızca altısı, anlatanın kendi gözüyle gördüğü şeylere dayanıyordu. {kahraman} bu oranı görünce şaşırdı. Şehrin hatıralarını sandıklarından çok daha az insan doğrudan yaşamıştı. Gerisi anlatılan, duyulan, tahmin edilen ve zamanla kesinleşmiş görünen şeylerdi. {yoldas:yalin|bir arkadaş} bunun kimseyi yalancı yapmadığını, ama herkese biraz daha dikkatli olma sorumluluğu verdiğini söyledi. {kahraman} o gece haritanın neden bu kadar kıpırdadığını daha iyi anlıyordu.
---
@omurga
Ertesi sabah Cemal Amca'nın tezgâhına bir kez daha uğradılar. Simitçi, köprüden geçtiğini söylerken bu kez bir şey ekledi: “Ama köprünün adını ben sonradan öğrendim. O zaman ‘tahta geçit’ derdik.” {kahraman} hemen defterine yazdı. Anlatıcı aynı olaya zamanla başka bir ad vermişti. Bu da anıların yalnızca görüntüden ibaret olmadığını, sözcüklerle de şekillendiğini gösteriyordu. {yoldas:yalin|bir arkadaş} sevindi, çünkü bu küçük ayrıntı, iki haritanın neden birbirine benzemediğini açıklayabilirdi. Yine de acele etmeyip yeni bilgiyi “henüz doğrulanmadı” başlığıyla soldaki sütuna ekledi.
---
@omurga
Defterlerinde iki sütun doldukça şaşırtıcı bir şey oldu. Anılar sütunundaki ifadeler çelişiyordu. Köprü, merdiven, patika. Kanıt sütununda ise yalnızca birkaç satır vardı. Ama o satırlar birbirini tutuyordu.

{kahraman} bu yüzden bir çizgiyi daha sevdi. Sağ sütundaki çizgiler çok zayıftı, ama aynı yere işaret ediyordu. Sol sütundaki çizgiler ise canlıydı, fakat birbirini tutmuyordu.

“Orhan Usta, en güçlü hatırayı çizmemizi söylemişti,” dedi {kahraman}. “Ama güçlü hatıralar {kelime:hr110_tutarsiz}.”

“Çünkü güçlü hatıra, çok duyguyla bağlı hatıradır,” dedi {yoldas:yalin|bir arkadaş}. “Duygu bir anıyı büyütür. Ama ölçüsünü korumaz.”

Harita masanın üzerinde bir an durdu. Çizgiler yan yana dizildi. Sanki harita da hangi sesi dinleyeceğini seçmek istiyordu.

{kahraman} cesaret edip sağ sütunun çizgilerini siyah mürekkeple sabitlemeyi denedi. Harita bu kez hiç kıpırdamadı. Soldaki mavi çizgiler ise nefes almaya devam etti. {yoldas:yalin|bir arkadaş} yan yana duran iki katmana baktı. “Demek ki harita, neye ne kadar güvendiğimizi gösteriyor,” dedi. “Biz neye çok emin davranırsak onu daha çok oynatıyor. Ölçtüğümüz şeyler ise yerinde kalıyor.” {kahraman} bu keşfi hemen deftere not etti. Haritacılığın en büyük sırlarından birine rastlamış olabileceklerini ikisi de hissediyordu.
---
@omurga
Lonca arşivinde, haritaların eski kopyalarının tutulduğu bir odada çalışmaya başladılar. Arşiv çok sessiz ve tozluydu. Raflar tavana kadar yükselir, her rafın ucunda bir kum saati küçük bir bekçi gibi dururdu. {kahraman} burada ilk kez bir haritanın yalnızca bir yer değil, aynı zamanda bir zaman olduğunu hissetti. Her kâğıdın köşesinde kimin, ne zaman çizdiği yazıyordu. Bu bilgi, çizginin ne kadar güvenilir olduğunu anlamak için bir ipucuydu. Arşiv görevlisi, mürekkebin yaşını yaklaşık olarak gösteren sarı bir cam vermişti. Camı bir çizgiye tutunca çizginin soluklaşma derecesi görünüyordu.

{kahraman} arşivdeki en eski Çınaraltı haritasını buldu. Üzerinde ne köprü vardı ne merdiven. Yalnızca nehir kenarında, kırmızı mürekkeple çizilmiş küçük bir daire duruyordu. Altında, çok silik bir yazıyla bir sayı vardı: kırk iki.

“Bu ne demek?” diye fısıldadı {kahraman}.

{yoldas:yalin|bir arkadaş} camı daireye tuttu. “Mürekkep çok eski. Şehirdeki bütün haritalardan eski. Bunu bir hatıra çizmemiş, çünkü o zamanlar haritalar hatıradan çizilmiyormuş. Birisi ölçmüş.”
---
@omurga
İkisi uzun süre sayıya baktı. Kırk iki neyin sayısıydı? Adım mı, kulaç mı, basamak mı?

Arşiv görevlisi onlara eski ölçü cetvellerini gösterdi. Şehrin kuruluş yıllarında haritacıların kulaç ölçüsünü kullandığı yazıyordu. Bir kulaç, iki kolu açan bir insanın uzunluğuydu. {yoldas:yalin|bir arkadaş} bir an durdu. “Ama herkesin kolu aynı uzunlukta değil,” dedi. Görevli gülümsedi. “O yüzden loncanın duvarında bronz bir kulaç çubuğu var. Herkes onunla ölçerdi.” {kahraman} bunun ne kadar akıllıca olduğunu düşündü. Ortak bir {kelime:hr110_olcu}, herkesin aynı şeye aynı sözcükle bakabilmesini sağlıyordu.
---
@omurga
O gece {yoldas:yalin|bir arkadaş} bir şey itiraf etti. “Ben ölçmeyi seviyorum çünkü hatırlamaktan korkuyorum,” dedi. “Küçükken bir kez kayboldum. Annem sonra benimle o gün hakkında konuşurken gördüğüm şeyleri anlattı. Bir süre sonra onun anlattıklarını mı hatırlıyorum, kendi gördüklerimi mi, karıştırmaya başladım.”

{kahraman} ona dikkatle baktı. “Peki şimdi?”

“Şimdi biliyorum ki bu sorun benim yanlış olduğumu göstermiyor. Sadece belleğin nasıl çalıştığını gösteriyor. Hatıralar hep yeniden yazılıyor. Kimi zaman bir yer, kimi zaman bir duygu, kimi zaman bir başkasının sözü ekleniyor.”

“O zaman anılarımız boşuna mı?”

“Hayır. {kahraman}, senin köprü hatıran bir şeye işaret ediyor. Ama neye, bunu başka şeylerle birlikte anlayacağız.”

{kahraman} bir süre sustu. Sonra cebinden dedesinden kalma küçük bir pusula çıkardı. “Dedem bunu bana o köprüde vermişti,” dedi. “İğnesi bozuk, hep biraz sağı gösteriyor. Ama ben onu hep doğru sanırdım.” İkisi birlikte pusulaya baktı. {yoldas:yalin|bir arkadaş} bir kâğıt parçasıyla pusulanın sapmasını ölçtü. {kahraman} bunun ne kadar önemsiz bir iş olduğunu düşündü. Ama bu küçük ölçü, ikisi arasındaki güveni büyüttü. {yoldas:yalin|bir arkadaş} anısını sorgulamıyor, onu doğru kullanmanın yolunu arıyordu.
---
@omurga
Ertesi gün Orhan Usta, iki çırağın çalışmasını görmek için çarşıya geldi. Çevresinde başka haritacılar da vardı. Hepsi kendi anılarından çizdikleri haritaları getirmişti ve hepsi birbirinden farklıydı.

“Bu çocuklar bir kâğıda anıları değil, ölçüleri çizmek istiyor,” dedi Orhan Usta. “Hatıra olmadan harita olur mu?”

{kahraman} öne çıktı. “Hatıra olmadan olmaz, Usta. Ama sadece hatırayla da olmaz.”

Haritacılardan biri sert bir sesle, “Bizim haritalarımız yüzyıllardır böyle çalıştı,” dedi.

“Evet,” dedi {yoldas:yalin|bir arkadaş}. “Çalıştı da, çünkü şehir küçüktü ve herkes aynı şeyi hatırlıyordu. Şimdi Çınaraltı gibi bir yeri hatırlayan insanların sayısı azalıyor. Kimin hatıraları doğru, kim bunu ölçecek?”

Çarşı bir an sessizleşti. Kimse kendi haritasına bu gözle bakmamıştı. Orhan Usta bir süre düşündü, sonra yavaşça başını salladı.

“Peki ne istiyorsunuz?” diye sordu. {yoldas:yalin|bir arkadaş}, defterini açıp iki sütunu gösterdi. “Anıları silmek istemiyoruz,” dedi. “Sadece hangisinin anı, hangisinin ortak kanıt olduğunu işaretlemek istiyoruz. Böylece biri bir haritaya baktığında neye güvenebileceğini bilir.” Haritacılardan biri homurdandı: “Bu çok yavaş bir iş olur.” {kahraman} cevap verdi: “Yavaş olur ama kimse yanlış yola sapıp suyu da kaybetmez.” Orhan Usta buna karşılık gülümsedi ve onlara bir hafta süre verdi.
---
@omurga
Arşivdeki sayıyı çözmek için nehir kıyısına döndüler. {yoldas:yalin|bir arkadaş}, ölçü ipini kırk iki kulaç uzattı. Bir ucunu eski köprü ayağının taşına bağladı, öbür ucunu çınarların olması gereken yöne doğru gerdi. İp kıyıdaki bir taş duvarda bitti.

Duvar yeni gibi görünüyordu. Üzerinde pazar yerinin yeni tezgâh numaraları yazılıydı. Ama {kahraman} eğilip duvarın dibine baktığında alt sıradaki taşlardan birinde yosunlu bir daire oyuğu gördü.

“Bak,” dedi. “Haritadaki daire.”

{yoldas:yalin|bir arkadaş} taşı elledi. “Bu duvar sonradan, eski yapının üstüne örülmüş. Yani Çınaraltı yok olmamış. Bir şeyin altında kalmış.”

Duvarın bir yerinde, yeni harçla sıvanmamış dar bir aralık vardı. {yoldas:yalin|bir arkadaş} oraya kulağını dayadı. İçeriden çok uzaktan gelen, ince bir su sesi duyuldu. Sesi {kahraman} da dinledi. Aynı sesi iki ayrı kişinin ayrı ayrı duyması {yoldas:yonelme|bir arkadaşa} yetmedi. Çarşıdan geçen iki esnafı çağırıp onlara da dinlettiler, ama nereyi dinleyeceklerini söylemediler. Her ikisi de aynı aralığı gösterdi. {yoldas:yalin|bir arkadaş} bunu deftere “bağımsız tanık: iki kişi” diye yazdı.
---
@omurga
İkisi yan yana diz çöküp taşı ellediler. {kahraman} kendi anısının köprüsünü hâlâ görüyordu ama bu kez ona yapışmıyordu. Anı yol göstermişti. Yolu açan ise ölçü ve taş olmuştu.

{yoldas:yalin|bir arkadaş} sevinçten ne yapacağını bilemedi. Hemen ipini çıkarıp taşın etrafını iki kez ölçtü. Sonra birbirinden bağımsız çalışması için {kahraman:ayrilma} da aynı ölçümü yapmasını istedi. İki ölçüm tam aynı çıktı. “Şimdi bu bir kanıt,” dedi {yoldas:yalin|bir arkadaş}. “Benim ya da senin duygumuz olmaktan çıktı.” {kahraman} gülerek taşı bir kez daha ellemek istedi ama durdu. Taş artık yalnızca bir hatıra değildi. Üzerinde yürüyen herkesin bakıp görebileceği bir gerçekti.
---
@omurga
Orhan Usta ve birkaç haritacı, ertesi gün duvarı birlikte açtılar. Altında eski bir sarnıç, daha ilerisinde ise Çınaraltı'nın bir zamanlar kullandığı kaynak kanalı çıktı. Kanal, yeni pazar inşa edilirken üstü örtülmüş ve unutulmuştu.

{kahraman} ile {yoldas:yalin|bir arkadaş} şehrin ilk iki sütunlu haritasını hazırladılar. Soldaki sütun mavi mürekkeple çizilen anılara aitti. Köprü, merdiven ve patika oradaydı. Sağdaki sütun siyah mürekkeple çizildi. Orada yalnızca iki kişinin ölçüp doğruladığı, ya da iki ayrı belgenin gösterdiği şeyler vardı.

“Anılar silinmeyecek,” dedi {kahraman}. “Çünkü şehrin hikâyesi onlar. Ama kanıt katmanı yalnızca başka biri kontrol edip aynı sonuca vardığında değişecek.”

Orhan Usta haritaya dokundu. “Eskiden haritalar bizi yanıltırdı,” dedi. “Şimdi hangi çizginin neye dayandığını görebiliyoruz.”

Haritanın altına küçük bir not da eklediler: “Mavi çizgi bir kişinin anısıdır. Siyah çizgi, en az iki kişinin birbirinden bağımsız olarak doğruladığı bilgidir. Bir çizgi mavi başlar, doğrulanırsa siyaha dönebilir.” {kahraman} bu notu yazarken içinde bir tür özgürlük hissetti. Artık anısının yanlış çıkması onu korkutmuyordu. Çünkü yanlış çıkması, anının silinmesi demek değildi. Yalnızca farklı bir yere taşınması demekti.
---
@omurga
Kanalı temizlemek haftalar sürdü. Çocuklar da yardım etti. Kimi kanalın içindeki tortuyu taşıdı, kimi duvar taşlarını sıraya dizdi. Bir sabah nehir kıyısında yüksek bir uğultu duyuldu ve kanaldan ince bir su çizgisi akmaya başladı. Çınaraltı'nın taş çeşmesi yıllar sonra ilk kez damladı.

Mahalleliler çeşmenin etrafında toplandı. Kimi sevinçten ağladı, kimi sessizce suya dokundu. Küçük bir çocuk, “Burada hep su varmış gibi geliyor,” dedi. Yanındaki yaşlı kadın ona, “Hayır yavrum, çok uzun zaman susmuştu,” diye cevap verdi. {kahraman} bu küçük konuşmayı dinlerken bir şeyi daha anladı. Aynı çeşmeye bakan iki kişi, aynı şeyi iki ayrı biçimde yaşayabilirdi. Biri için çeşme bir sürpriz, öbürü için bir kavuşmaydı. Bunların hiçbiri yanlış değildi.

Kalabalığın içinde Nine Seher de vardı. Eliyle suyu avucuna aldı. “Tadını hatırlıyorum,” dedi. “Ama tadı doğru hatırlıyor muyum, bilmiyorum.”

“Hatırlıyorsunuz,” dedi {kahraman} gülerek. “Bunu bir kâğıda yazmayacağız ama. Anı olarak kalacak.”
---
@omurga
Nine Seher güldü. “İyi ki ayırmışsınız,” dedi. “İkisine de ihtiyacımız var.”

Orhan Usta çocukların yanına geldi. Elinde loncanın en eski, en değerli çizim kalemi vardı. “Bunu on yıldır kimseye vermedim,” dedi. “Ama bugün size teşekkür etmenin başka yolunu bulamadım. Bana sağlam bir ders verdiniz. Hatıranın gücü, onun doğruluğunu göstermez. Ama hatıra olmadan hiçbir araştırma başlamaz da.” {kahraman} kalemi iki eliyle aldı. {yoldas:yalin|bir arkadaş} ise Usta'ya, bir zamanlar kendisinin de çok emin olduğu bir hatıranın yanlış çıktığını anlattı ve ikisi uzun uzun güldü.

Tuz Köprüsü'nün gerçekte var olup olmadığı o gün de bilinmiyordu. Fakat bir kütük arşivinde, sonradan bulunan eski bir belgede, geçmişte nehir üzerinde ahşap bir geçit olduğu yazıyordu. {kahraman:ilgi} hatırası, bir parça doğruydu.

Bu, {kahraman} için tatlı bir sürprizdi. Köprü, taştan bir yapı değil, ahşap bir geçitti. Ama o kadar da uzak değildi. {yoldas:ilgi|bir arkadaşın} merdiven anısı da boşa çıkmamıştı. Pazar yeri yapılırken eski bir geçit sökülmüş, yerine yeni bir merdiven örülmüştü. İki anı da farklı zamanlardan gelen farklı gerçeklere işaret ediyordu. Yani ikisi de haksız değildi. Sadece her biri hikâyenin bir parçasını görmüştü. {kahraman} bunu fark edince hem utandı hem de rahatladı.
---
@omurga
O akşam saat kulesine çıkıp kum saatinin başına oturdular. Üst camdaki kum tükenmişti. Nine Seher onu ters çevirdi. Kumlar yeniden akmaya başladı.

“Bu şehirde herkes biraz kendi haritasında yaşıyor,” dedi {yoldas:yalin|bir arkadaş}. “Önemli olan başkasının haritasına da bakabilmek.”

{kahraman} defterini açtı. Sol sütuna şunu yazdı: “Dedemin eliyle köprüden geçtim.” Sağ sütuna ise: “Nehir kıyısında kırk iki kulaç uzaklıkta eski bir daire oyuğu var.” İki cümle yan yana durdu ve birbirini boğmadı.

Aşağıda şehir yavaş yavaş ışıldıyordu. Sokaklar, çeşmeler, çınarlar yerli yerindeydi. Harita bu kez titremedi. Ya da titrediyse bile iki ayrı sütunun arasında, sakin bir çizgi olarak titredi.
