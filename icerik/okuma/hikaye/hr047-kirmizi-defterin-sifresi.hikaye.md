---
baslik: "Kırmızı Defterin Şifresi"
slug: "hr047-kirmizi-defterin-sifresi"
fis_kodu: "HR-047"
tur: gizem
konu: oruntu_baglam
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D3]
yetiskin_uygun: false
tanitim: "Eski kırmızı bir defterde sayı dizileri var. Puan mı, kitap kodu mu, yoksa bir sistemin izi mi?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [gizem, okul]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D3
  ogrenme_hedefleri:
    - {id: oruntu_hr047, tur: lexeme, etiket: "örüntü", yuva: hr047_oruntu, islev: first_hint}
    - {id: sutun_hr047, tur: lexeme, etiket: "sütun", yuva: hr047_sutun, islev: application}
    - {id: etiket_hr047, tur: lexeme, etiket: "etiket", yuva: hr047_etiket, islev: application}
    - {id: kavram_hr047, tur: concept, etiket: "Örüntü ile bağlam ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 3, metin: "Defterin kapağında ne yazıyordu?", secenekler: [{id: A, metin: "Nöbet Devir Teslimi"}, {id: B, metin: "Satranç Turnuvası"}, {id: C, metin: "Kitap Kodları"}, {id: D, metin: "Kayıp Puanlar"}], dogru: A, aciklama: "Kapakta yalnızca “Nöbet Devir Teslimi” yazıyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 8, metin: "Sayıların farklı kurallarla artması neyi düşündürdü?", secenekler: [{id: A, metin: "Defterdeki sayıların tek bir oyun puanı olmayabileceğini"}, {id: B, metin: "Kapak rengi kırmızıydı"}, {id: C, metin: "Defter çok eskiydi"}, {id: D, metin: "Sayılar çok büyüktü"}], dogru: A, aciklama: "Farklı sayfalarda farklı kurallar olması, tek bir puan açıklamasını zayıflattı."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 8, metin: "Yoldaşın bu sözü neyi vurgular?", secenekler: [{id: A, metin: "Örüntünün her zaman doğru olduğunu"}, {id: B, metin: "Bir örüntü bulmak, onun neyi anlattığını bilmek anlamına gelmez"}, {id: C, metin: "Defterin tamamen değersiz olduğunu"}, {id: D, metin: "Kuralın hiç bulunamayacağını"}], dogru: B, aciklama: "Kuralı bulmak ile belgenin anlamını anlamak farklı işlerdir."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 13, metin: "Metinde geçen sütun ne anlama gelir?", secenekler: [{id: A, metin: "Bir kitap türü"}, {id: B, metin: "Bir yatay satır"}, {id: C, metin: "Tablonun dikey bölümlerinden biri"}, {id: D, metin: "Bir sayı kodu"}], dogru: C, aciklama: "Sütun, bir tablonun yukarıdan aşağıya uzanan bölümüdür."}
---
@omurga
{kahraman:ilgi} bu maceraya özel bir nedeni daha vardı. Geçen dönem satranç turnuvasında bütün hamlelerini hesapladığını düşünmüş, son oyunda acele bir karar verip yenilmişti. Herkes ona "Biraz düşünseydin" demişti. O günden beri rakamlarla ilgili bir yarış gördüğünde kendini ispatlamak istiyordu. Kırmızı defter de ona böyle bir fırsat gibi görünmüştü. Fakat {yoldas:ilgi|bir arkadaşın} sakinliği ve Baran'ın farklı soruları, araştırmanın turnuvadan farklı bir şey olduğunu hatırlatacaktı. Bu kez kazanılacak tek bir madalya yoktu. Bir belgenin ne anlattığını birlikte anlamaları gerekiyordu.
---
@omurga
Defteri ilk fark eden Baran olmuştu. Satranç tahtalarının kaldırıldığı dolabın en altında, tahta kutuların arasına sıkışmıştı. Kırmızı kapak yıpranmıştı ama köşesine yapıştırılan küçük beyaz {kelime:hr047_etiket} hâlâ duruyordu. {yoldas:yalin|bir arkadaş} defteri bulduklarında hemen açmamalarını önerdi. Kulüp odası okulun ortak alanıydı; bulunan eşya başka bir birime ait olabilirdi. Öğretmenlerine haber verdikten sonra defterin okulun eski kütüphane deposundan taşınan malzemelerden biri olduğu anlaşıldı. Bu açıklama, sayıların oyun puanı olabileceği fikrini zayıflatmadı; çünkü eski yıllarda kütüphane kulüpleri de yarışmalar düzenlemiş olabilirdi. {kahraman} iki seçeneği de not etti. Daha araştırmaya başlamadan farklı açıklamaların mümkün olduğunu görmüştü.
---
@omurga
Okulun satranç kulübü, boş bir sınıfta eski bir kırmızı defter buldu. Defterin kapağında yalnızca Nöbet Devir Teslimi yazıyordu. İçinde küçük tablolar, okunması zor notlar ve uzun sayı dizileri vardı. Altıncı sınıftan Baran'ın satranç oyunlarından öğrendiği bir alışkanlık vardı: Bir hamle yapmadan önce karşı tarafın ne yapabileceğini düşünmek. {kahraman} bunu çoğu zaman yavaşlık sanırdı. Kırmızı defterdeyse Baran'ın sabrı işe yaradı; ilk sayfada görülen sayıların arkasında başka bir düzen olabileceğini ondan önce fark etmişti. {yoldas:yalin|bir arkadaş} iki arkadaşın yöntemlerini birleştirmelerini önerdi. "{kahraman} hızlı örüntü buluyor, Baran ayrıntıyı kontrol ediyor. İkiniz de gerekli bir iş yapıyorsunuz," dedi. {isaret:kitap}
---
@omurga
{kahraman} sayılarla çalışmayı severdi, fakat başkalarının zihninden daha hızlı işlem yapabildiğini sanması bazen sorun yaratıyordu. Satranç kulübünde hamlesini hemen yapar, arkadaşlarının uzun düşünmesini sıkıcı bulurdu. Baran ise dikkatliydi; bazen bir hamlenin sonucunu görmek için birkaç dakika susabilirdi. Bu ikisinin anlaşması kolay değildi. Kırmızı defter onların birlikte çözeceği ilk ciddi araştırmaydı. {yoldas:yalin|bir arkadaş}, "Burada yarışmıyoruz," dedi. "Önemli olan kimin önce bildiği değil, nasıl bildiğimiz." {kahraman} itiraz etmek üzereydi ama defterin kapağındaki eski etikete bakınca susmayı seçti.

{yoldas:yalin|bir arkadaş} kırmızı defteri açtığında ilk olarak sayfa numaralarını kontrol etti. Bazı sayfalarda küçük lekeler vardı ama yazıların çoğu okunabiliyordu. {kahraman} sayılar üzerinde çalışmak için sabırsızlanırken Baran kapağın içindeki eski okul mührünü fark etti. Mühür, defterin hangi kuruma ait olabileceğine ilişkin önemli bir ipucuydu. {yoldas:yalin|bir arkadaş}, "Önce belgenin kimliğini anlayalım," dedi. {kahraman} bu kez onun sözünü kesmedi. Çünkü mühür olmasa defterdeki sayıların okul kütüphanesiyle ilişkisini çok daha geç kuracaklardı.
---
@omurga
{kahraman} ilk sayfaya baktığında şaşırdı: 104, 107, 110, 113... Her yeni sayı bir öncekinden üç büyüktü.

"Bu bir oyun skoru olabilir," dedi takım arkadaşı Baran. "Belki kazananlara üç puan vermişler."

{kahraman} itiraz etmedi. Ama hemen yanındaki listede 502, 504, 506 gibi başka bir dizi vardı. Puanların neden bir sayfada üçer, başka sayfada ikişer arttığını anlamıyordu. Defteri bulan kulüp başkanı {yoldas:yalin|bir arkadaş}, kapakta "Nöbet" yazdığına dikkat çekti.

"Önce defterin ne için tutulduğunu öğrenmeliyiz," dedi. "Başkasının eşyasını izinsiz karıştırmak da doğru değil."

Öğretmenleri Arif Bey'e danıştılar. Öğretmen, defterin yıllar önce okul kütüphanesinde görevli olan öğrenciler tarafından tutulmuş olabileceğini söyledi. Defter okulun eski evrakları arasından çıkmıştı; içindekilerin incelenmesi için kütüphane sorumlusuyla görüşeceklerdi.

{kahraman} sayıların bir dil gibi olduğunu düşünmeye başlamıştı. Eğer dili çözebilirlerse kimin, ne zaman, neyi kaydettiğini öğrenebileceklerdi. Fakat şifrenin anlamını bulmak için daha fazla ipucu gerekiyordu.
---
@omurga
İlk araştırma oturumunda Münevver Hanım öğrencilere renkli küçük kâğıtlar verdi. Her kâğıda bir varsayım yazmalarını istedi: "Oyun puanı", "Kitap kodu", "Sıra numarası" ve "Başka bir kayıt". Ardından her varsayımın altına onu destekleyen veya zayıflatan bilgileri koyacaklardı. Baran ilk kâğıda sımsıkı sarıldı; çünkü fikri onundu. {kahraman} ise kitap kodu seçeneğini ortaya atmış olmanın gururunu yaşıyordu. {yoldas:yalin|bir arkadaş}, "Sevdiğimiz fikri korumaya değil, doğru olanı bulmaya çalışıyoruz," dedi. İki arkadaş önce itiraz etti, sonra bu yöntemle soruları daha kolay sıraya koyabildiklerini gördü.
---
@omurga
Münevver Hanım masanın üzerine temiz bir örtü serdi. Eski defteri doğrudan güneş ışığı almayan bir yerde açmalarını istedi. {kahraman}, kayıtlı sayıların hepsini fotoğraflamak için telefonuna uzandı. Münevver Hanım, "Önce hangi sayfalara bakabileceğinizi belirleyelim," dedi. Bazı sayfalarda eski öğrencilere ait kişisel bilgiler olabilirdi. Baran ve {yoldas:yalin|bir arkadaş} de buna hak verdi. {kahraman}, eskiden tarihî belge sandığı her şeyi paylaşmanın iyi bir şey olduğunu düşünürdü. Şimdi bilgiye ulaşabilmekle onu herkese yayabilmenin farklı haklar olduğunu anlamaya başladı.

Ertesi gün kütüphane sorumlusu Münevver Hanım, defteri kontrollü biçimde incelemelerine izin verdi. Bazı sayfalarda öğrenci isimleri olduğu için bunları herkesin göreceği şekilde paylaşmamalarını istedi. Çocuklar yalnızca kitap kodu olabilecek sayıları inceleyeceklerdi.
---
@omurga
{kelime:hr047_oruntu} ilk kuralını bulunca Baran bir oyun önerdi. {kahraman} gözlerini kapatacak, Baran dizinin herhangi bir noktasını okuyacaktı. {kahraman} bir önceki ve bir sonraki sayıyı tahmin edecekti. İlk denemelerde zorlanmadı. Fakat Baran 104 yerine 105 ile başlayan bir dizi seçince {kahraman} aynı kuralı hemen uyguladı ve şaşırdı. Yeni dizinin farkı farklıydı. "Kuralı öğrenmek yetmiyor," dedi. "Hangi diziye uyguladığını da bilmen gerek." {yoldas:yalin|bir arkadaş} bu sözü defterine yazdı. Matematikte kurallar güçlü araçlardı ama her durumda aynı kural kullanılmazdı.

{kahraman} kâğıda ilk diziyi yazdı: 104, 107, 110, 113. Ardından 116 sayısını ekledi. Baran, "Gördün mü, kural bu!" dedi. {yoldas:yalin|bir arkadaş} ise "Bir örüntü bulduk, ama neyi gösterdiğini bilmiyoruz," diye hatırlattı.

Aynı sayfanın altındaki ikinci dizi 502, 504, 506, 508 diye gidiyordu. Üçüncü sayfada ise 211, 311, 411 vardı. {kahraman} bir süre düşündü. Sayılar farklı kurallarla artıyordu. Bu durum oyun puanı açıklamasını zayıflatıyordu.
---
@omurga
Rafların önünde renkli etiketler vardı. {kahraman} bunların yalnızca dekorasyon olduğunu sanmıştı; oysa her renk farklı türde kitapları bulmayı kolaylaştırıyordu. Münevver Hanım, daha küçük öğrenciler için konu resimleri de eklediklerini anlattı. {kahraman} ilk anda onlara kitap kodunu söylemeye hazırlanmıştı. Ancak çocuklar henüz kodları öğrenmediklerini söyledi. Baran rafın üzerindeki hayvan resmini göstererek yardımcı oldu. {kahraman}, farklı yaşlarda aynı bilgiye ulaşmak için farklı yollar kullanılabileceğini gördü. Bu deneyim ileride hazırlayacakları oyun etkinliğinin tasarımını da etkiledi.

Birinci sınıftan gelen iki çocuk hayvanlar hakkındaki kitabı arıyordu. Baran onları uygun rafa yönlendirdi. Çocuklar kitabı bulunca sevinçle teşekkür etti. {kahraman}, kütüphane düzeninin sıradan gibi görünen ayrıntılarının bile okurlara yardımcı olabildiğini fark etti. Eski defterdeki sayıların da zamanında böyle bir işlevi olabilir miydi?
---
@omurga
Kütüphanenin raflarında dolaşırken Baran bir kitabın sırtındaki etikete dikkat etti. Etikette harfler ve sayılar vardı. Münevver Hanım, bazı kütüphanelerde kitapların konularına veya kayıt sırasına göre kodlandığını anlattı. Bu okulun eski sistemi ise bugünkünden farklıydı.

"Belki defterdeki diziler de kitaplarla ilgili," dedi {kahraman}. {yoldas:yalin|bir arkadaş} hemen yeni bir tablo oluşturdu: Sayı, olası açıklama, kanıt. İlk satıra "104 — kitap kodu olabilir — henüz doğrulanmadı" yazdı.

Araştırma sırasında {kahraman:ilgi} aklına eski defterin niçin kırmızı olduğu takıldı. Baran bunun gizli kulüp rengini temsil ettiğini söyledi. Münevver Hanım gülerek cevap verdi: "Belki de o yıllarda kırtasiyede yalnızca kırmızı defter bulunuyordu." Çocuklar bir nesnenin her özelliğinin özel anlam taşımak zorunda olmadığını fark etti. Yine de kapak rengi onlara güzel bir isim vermişti: Kırmızı Defterin Şifresi. {kahraman} bu adı araştırma defterinin başına yazdı ama altına küçük harflerle "Şifre sözcüğü burada merak için kullanılmıştır" notunu ekledi.
---
@omurga
İlk kartı incelerken {kahraman} kitabın adını yanlış okudu. Eski el yazısındaki harfler birbirine benziyordu. {yoldas:yalin|bir arkadaş} daha yavaş okuyup kitabın gerçek adını yazdı. "Ben olsam ilk gördüğüm gibi kaydederdim," dedi Baran. {kahraman} bu kez acele etmedi. "Belki başka kartta daha okunaklıdır," diye önerdi. Aradılar ve kitabın ikinci bir kaydını buldular. İki kayıt arasındaki farkı belirleyince bir sayının tek başına kaybolmuş bir kitabı göstermediğini, bazen aynı kitap için farklı kayıtlar da bulunduğunu anladılar.

Katalog kartlarının köşeleri farklı renklerle boyanmıştı. {kahraman} bunun kitapların içerikleriyle ilgili olduğunu düşündü. Münevver Hanım renklerin eski bir raf sistemine bağlı olabileceğini söyledi, ancak elindeki kayıtta açık bir açıklama bulunmadığını ekledi. Çocuklar bunu araştırma listesine yeni bir soru olarak yazdılar.
---
@omurga
Münevver Hanım çocuklara eski katalog kartlarından birini gösterdi. Kartta kitap adı, yazar, kayıt numarası ve eski raf yeri yazıyordu. Baran eski kartlardan birinde 107 sayısını görünce sevinçle bağırdı: "Şifreyi çözdük!"

{yoldas:yalin|bir arkadaş} onu durdurdu. "Bir tane eşleşme yeterli değil." {kahraman} ikinci kitabın kartını açtı; burada 110 yazıyordu. Sonra başka bir kartta 113'ü buldular. Üç farklı eşleşme artık tesadüf ihtimalini azaltıyordu.

{yoldas:yalin|bir arkadaş} diziyi bir de yatay satırlar hâlinde okumalarını istedi. Baran bu kez soruyu {kahraman:yonelme} yöneltti: "Bir tabloyu yanlış sırayla okursan doğru sayılar seni yanlış sonuca götürür mü?" {kahraman}, "Evet," dedi. "Rakamlar değişmez ama aralarındaki ilişkiyi yanlış anlayabiliriz." Bunun üzerine üç arkadaş, küçük sınıfların kullanabileceği çizimli bir tablo hazırladı. İçinde meyve sepetleri vardı ve sayılar her sütunda farklı biçimde ilerliyordu. Böylece soyut buldukları ilişkiyi anlaşılır bir örnekle göstermiş oldular. Münevver Hanım bu etkinliği daha sonra kulüp saatinde kullanabileceklerini söyledi.
---
@omurga
{kahraman} kâğıda üç sütun çizdi. Birinci {kelime:hr047_sutun} 104, 107, 110; ikinciye 105, 108, 111; üçüncüye 106, 109, 112 yazdı. Sayfayı dikey okuyunca her sütun üçer artıyordu. Yatay okuyunca sayılar birer birer ilerliyordu. Baran'ın yüzü aydınlandı. "Aynı sayılar, okuma yönüne göre farklı bir dizi gibi görünmüş!" dedi. {yoldas:yalin|bir arkadaş}, "Demek tablo biçimini bilmeden yalnızca rakamlara bakmak yetmez," diye ekledi. Bu küçük keşif, çocuklara basit bir satır-sütun düzeninin ne kadar önemli olduğunu gösterdi.

Fakat dizi neden üçer artıyordu? Kütüphane sorumlusu, eski sistemde bazı raf listelerinin birden fazla sütun hâlinde tutulduğunu söyledi. Defterdeki sayılar üçer artarken başka sütunlardaki kayıtlar aradaki numaraları tamamlıyor olabilirdi. Çocuklar defteri dikkatlice inceleyince yan sayfada 105, 108, 111 sayılarını buldular.
---
@omurga
Baran heyecanla yeni bir kâğıt aldı ve tabloyu kendi başına yeniden kurdu. İlk sütunu doğru yazdı ama ikinci sütunun son sayısını unuttu. {yoldas:yalin|bir arkadaş} eksik kısmı kendisinin tamamlaması yerine Baran'a yatay satırları kontrol etmesini önerdi. Baran, sayının nerede kaybolduğunu kendi bulunca sevindi. Bu küçük an, yardım etmenin bazen cevabı söylemek yerine yöntemi hatırlatmak olduğunu gösterdi.

"Demek bu bir tek sıra değil," dedi {kahraman}. "Aynı tablodaki farklı sütunları ayrı ayrı okumuşuz."

O anda Baran yanlış rafta duran bir kitap fark etti. Sırtında eski bir kod vardı ama raftaki yeni etiketle uyuşmuyordu. Münevver Hanım kitabı alıp güncel katalogdan kontrol etti. Gerçekten de yanlış rafa konmuştu. Defterin sayıları, yıllar önceki kayıtların nasıl tutulduğunu anlamalarına yardım ediyordu.
---
@omurga
Kırmızı çizginin yanında küçük bir yıldız da vardı. Baran bunun kayıp kitabı işaretlediğine neredeyse emindi. {kahraman} bu kez hemen kabul etmedi. Sorumluya danışınca yıldızın o gün kontrol edilen kayıtları belirtmek için kullanılmış olabileceğini öğrendiler. Fakat bunu doğrulayacak açıklama defterde yoktu. {yoldas:yalin|bir arkadaş} "Kesinlikle yıldız bunu gösteriyor" yazmadı; "Olası açıklama, doğrulanmadı" diye not etti. Baran önce hayal kırıklığına uğradı. Sonra bir araştırmacının bütün sorulara aynı anda yanıt bulmasının gerekmeyebileceğini anladı.
---
@omurga
O sabah okulun kütüphanesinde küçük bir kitap değiştirme etkinliği vardı. Baran, araştırmaya katılmak yerine arkadaşlarıyla kitap seçmek istiyordu. {kahraman} bundan rahatsız oldu. "Tam sonuca yaklaşmışken gidiyorsun," dedi. Baran, "Bir saat sonra devam ederiz. Kütüphane yalnızca kayıt çözmek için değil, kitap okumak için de var," diye karşılık verdi. {yoldas:yalin|bir arkadaş} ikisinin de haklı yanlarını gördü. Birlikte zaman planı yaptılar: önce etkinliğe katılacak, sonra araştırma masasına döneceklerdi. {kahraman}, iyi bir ekip çalışmasının yalnızca tek bir kişinin merakına göre ilerleyemeyeceğini fark etti.

Araştırmanın üçüncü günü {kahraman} kırmızı bir kalemle işaretlenmiş sayfayı gördü. Sayfanın tepesine Tamamlanmadı yazılmıştı. Altında beş kitap adı vardı. Üçünün yanında onay, ikisinin yanında boş kare bulunuyordu.

"Acaba bu kitaplar kayıp mı?" diye sordu Baran.
---
@omurga
Münevver Hanım, bunun kesin olmadığını söyledi. "Belki o tarihte sayım tamamlanmadı, belki kitaplar başka bir bölümdeydi. Önce kayıtları karşılaştıralım."

Arama sırasında aynı başlığı taşıyan iki farklı kitap gördüler. {kahraman} ilkini seçmeye hazırlanırken {yoldas:yalin|bir arkadaş} yayım bilgilerini karşılaştırdı. Bir kitapta yazar adı farklıydı. Baran da aradıkları kitabın sayfa sayısının eski kayıttakine benzemediğini fark etti. İkili birbirlerini uyarınca {kahraman} doğru sonuca ulaştı. Defterdeki kodun yalnızca bir kapı anahtarı olmadığını, başka kayıtlarla birlikte kullanıldığında anlam kazandığını gördü. Öğretmenlerine hazırladıkları tabloda "eşleşti" ve "kontrol edilecek" sütunlarını ayrı tuttular.

Çocuklar kitabın adını, yazarını ve eski kodunu kullanarak tarama yaptı. İki kitabın farklı bir sınıf kitaplığına aktarılmış olduğunu gösteren belge bulundu. Böylece "kayıp" sözcüğünü kullanmadan önce neden dikkatli olunması gerektiğini anladılar.
---
@omurga
{kahraman}, sayı dizilerine bakıp bir anda bütün şifreleri çözebildiğini sanmıştı. Şimdi her rakamın, yanında yazan kelimeye ve kullanıldığı zamana göre anlam kazandığını görüyordu. Matematikte örüntüyü bulmak önemliydi; gerçek bir belgeyi anlamak için örüntünün bağlamını da bilmek gerekiyordu.

Sunum hazırlıkları sırasında küçük bir tartışma çıktı. {kahraman}, sayıların nasıl çözüldüğünü anlatan uzun bir metin yazmıştı. Baran, bunun dinleyenleri sıkacağını söyledi. {yoldas:yalin|bir arkadaş} ikisini de dinledi ve metni üç parçaya ayırmayı önerdi: önce merak sorusu, sonra ipuçları, en sonunda çözüm. Böylece hem {kahraman:ilgi} ayrıntıları korunacak hem de dinleyiciler yolu takip edebilecekti. {kahraman} metninin bir kısmını kısaltmayı istemiyordu. Fakat provasını yaptıklarında arkadaşları hangi sayıların neyi gösterdiğini karıştırdı. İkinci denemede daha açık cümleler kullandılar. {kahraman} o gün bilgiyi bulmanın kadar anlaşılır anlatmanın da emek istediğini gördü.
---
@omurga
{kahraman} bu sunumu yalnızca öğretmenine göstermek istemişti. Münevver Hanım küçük öğrencilerin de katılacağını söyleyince biraz endişelendi. "Ya sayı tabloları onlara zor gelirse?" dedi. {yoldas:yalin|bir arkadaş}, örnekleri renkli kâğıtlarla gösterebileceklerini önerdi. Baran da kitap etiketlerinin fotoğraflarını hazırladı. Böylece soyut görünen sayı ilişkilerini gerçek nesnelere bağladılar.

Araştırmaları bitince Münevver Hanım, çocuklardan elde ettikleri bilgileri herkesin anlayacağı kısa bir sunuma dönüştürmelerini istedi. {kahraman} sayı dizilerini anlattı, {yoldas:yalin|bir arkadaş} kanıt tablosunu gösterdi, Baran eski katalog kartlarının nasıl kullanıldığını açıkladı.

Münevver Hanım öğrencilerin sunumunu dinlerken eski kütüphanede kullanılan sisteme ilişkin kendi hatıralarını da anlattı. Ancak bazı yılları tam hatırlamadığı için öğrencilerden notlarına "sözlü bilgi" etiketi koymalarını istedi. {kahraman} başını salladı. Belgeler ve anılar birbirini tamamlayabilirdi ama aynı türde kanıt değildi. {yoldas:yalin|bir arkadaş} hazırladığı tabloyu son kez kontrol etti; hangi sayıyı hangi karttan aldıkları görünür hâle gelmişti. Baran ise yanlış puan varsayımının üzerini çizmek yerine küçük bir açıklama eklemeyi önerdi. Böylece araştırmanın nasıl ilerlediği de anlaşılacaktı.
---
@omurga
Baran defteri ilk bulduğu sabah kurduğu hazine hayalini hatırladı. Başta bir kapının açılacağını, arkasından eski madalyalar çıkacağını düşünmüştü. Şimdi sıradan kitap kodlarının daha ilginç bir şeye dönüştüğünü görüyordu: Okulun yıllar önce bilgi düzenlemek için geliştirdiği bir yönteme. "Bazen gerçek hikâye hayal ettiğinden daha sessizdir," dedi. {kahraman} buna karşı çıktı: "Ama daha çok kişiye dokunabilir." Çünkü kodlar doğru okunursa birçok öğrenci doğru kitabı daha kolay bulabilirdi.

Sunumun sonunda Baran gülerek, "Demek bu gizli bir oyun değilmiş," dedi.

{kahraman}, "Ama bundan iyi bir oyun çıkarabiliriz," diye karşılık verdi. Çocuklar bir sınıf etkinliği tasarladı. Her grubun önüne uydurma kitap kodlarından oluşan üç dizi koydular. Öğrencilerin görevi yalnızca diziyi devam ettirmek değil, farklı açıklamalar arasından hangisinin kanıtlarla uyuştuğunu seçmekti.
---
@omurga
Etkinlikte en çok tartışılan soru, verilen dizinin devamındaki sayının ne olacağı değildi. "Bu dizinin kitap kodu olduğunu nasıl anlarsınız?" sorusuydu. Bazı öğrenciler eski katalog kartlarını inceledi, bazıları başlıkların benzerliğine baktı. {kahraman}, bir grubun bütün sayıları doğru devam ettirdiği hâlde yanlış kitap seçtiğini gördü. Böylece örüntü kuralının doğru olmasıyla belgenin açıklamasının doğru olmasının farklı şeyler olduğunu daha iyi anladı. {yoldas:yalin|bir arkadaş}, oyunun sonunda çocuklardan yalnızca cevabı değil, kullandıkları kanıtı da yazmalarını istedi.

İlk gruptaki çocuklar sayıları çözdü ama yanlış sonuca vardı. {kahraman} onları hemen düzeltmedi. "Hangi bilgiye dayanıyorsunuz?" diye sordu. Çocuklar kartları yeniden inceledi ve kendi hatalarını buldu. {kahraman} öğretmeni gibi davranmaktan hoşlanmıştı; daha çok, bir ipucunu paylaşmanın sevincini yaşıyordu.
---
@omurga
Arşive kaldırılmadan önce {kahraman} son kez kapaktaki yıpranmış etikete baktı. İlk gün ona tuhaf gelen "Nöbet Devir Teslimi" sözünün ne anlattığını şimdi daha iyi anlıyordu. Öğrenciler bir zamanlar kitapların düzenli bulunması için birbirlerine görev devretmişti. Bu küçük sorumluluk, yıllar sonra başka öğrencilerin araştırmasına konu olmuştu. {kahraman} bunun şaşırtıcı bir bağlantı olduğunu düşündü: Birinin özenle tuttuğu kayıt, başka birinin doğruyu bulmasına yardım edebilirdi.

Kırmızı defter okul arşivine güvenle kaldırıldı. Kapak sayfasına, öğrencilere ait kişisel bilgiler paylaşılmadan hazırlanmış kısa bir açıklama eklendi. Münevver Hanım ayrıca buldukları eski katalog kartlarını sınıfta kullanılacak örneklerle karıştırmamalarını istedi. {kahraman} bunun nedenini sorunca, araştırma için hazırladıkları kopyalarla gerçek arşiv belgelerinin ayrı tutulmasının önemini anladı. Baran kopyaların üstüne "Etkinlik örneği" yazdı. {yoldas:yalin|bir arkadaş} gerçek kartların nerede korunduğunu dosyaya ekledi. Sonradan defteri inceleyen herkes böylece hangi belgenin asıl, hangisinin öğrenme amaçlı hazırlanmış örnek olduğunu ayırt edebilecekti.
---
@omurga
Böylece defterin geçmişte ne işe yaradığı ve neden korunduğu bilinecekti.

{yoldas:yalin|bir arkadaş} ile Baran kütüphanedeki raf düzeni hakkında küçük bir anket de yapmıştı. Bazı öğrenciler kitapları başlığa göre, bazıları türe göre aramayı tercih ediyordu. {kahraman} başlangıçta "Bir yöntem seçelim, herkes ona uysun," demişti. Münevver Hanım, farklı okurların ihtiyaçlarını dikkate almanın kütüphaneyi daha kullanışlı kılabileceğini anlattı. Çocuklar basit bir arama yönlendirmesi hazırladı: Aradığın kitabın adını biliyorsan katalogdan, konu arıyorsan raf etiketlerinden başla. Bu küçük öneri, çözülmüş bir sayı dizisinin gerçek hayatta nasıl işe yarayabileceğini gösterdi.
---
@omurga
Dönem sonu geldiğinde satranç kulübü yeni üyelerini karşılamak için tanışma günü düzenledi. {kahraman}, eski hâli gibi hemen en iyi hamleyi göstermedi. Yeni üye sonunda bir hamle yaptı ve kendi düşünme yolunu açıkladı. {kahraman} başlangıçta başka bir hamleyi tercih edecekti. Fakat arkadaşının gerekçesini dinleyince konumu farklı açıdan görmeye başladı. Baran "Kırmızı defter sana satrançta da işe yaradı," dedi. {kahraman} gülümsedi. "Önce hamlenin nereden geldiğini anlamak gerekiyor," diye karşılık verdi. Sayıların bağlamı olduğu gibi kararların da bağlamı vardı.

Yeni gelen bir öğrenci düşünürken sabırla bekledi. Baran bunu fark edip gülümsedi. "Kırmızı defter sana da bir şey öğretmiş," dedi. {kahraman} omuz silkti. "Evet. Bazen doğru cevabı ilk bulan kişi olmak en önemli şey değilmiş." {yoldas:yalin|bir arkadaş} onların konuşmasını duydu. Kütüphanede öğrendikleri sabır, artık satranç masasında da işe yarıyordu.
---
@omurga
Bir hafta sonra {yoldas:yalin|bir arkadaş}, {kahraman:ilgi} sırasına küçük bir not bıraktı: 7, 12, 17, 22, ? Altına "Bugün yeni bir bilmece var," yazmıştı. {kahraman} gülümsedi. "Yirmi yedi," diye cevap verdi.

Baran yanlarından geçerken "Peki bu sayı neyi gösteriyor?" diye sordu.

Artık kızgın ya da acele hissettiğinde de aynı soruyu kendisine yöneltiyordu: "Bunu nereden biliyorum?" Bu, her kararını mükemmel yapmıyordu. Ama düşünmeden konuştuğu anları daha kolay fark etmesine yardım ediyordu. Baran ve {yoldas:yalin|bir arkadaş} de yeni bir bulmaca gördüklerinde önce kanıt arıyorlardı.
---
@omurga
{kahraman} daha önce satranç maçlarında yenilince hemen yeni bir oyun oynamak isterdi. Bu kez kaybetmenin ardından aynı konuma bakmayı, yanlış hamlenin neden yanlış olduğunu anlamayı denedi. Baran ona kırmızı defterdeki ilk varsayımlarını hatırlattı. "Biz de puan sandık, sonra kontrol ettik," dedi. {yoldas:yalin|bir arkadaş}, hatanın kaynağını anlamanın yalnızca matematikte değil birçok konuda işe yaradığını söyledi. {kahraman} eski sayı tablosuna baktı. Sayıların ardında görmediği düzeni fark etmesi için yalnızca işlem yapması yetmemişti; defterin kim tarafından ve ne amaçla tutulduğunu da anlaması gerekmişti. Artık yeni bir bilmeceyle karşılaştığında ilk hamlesi tahmin yürütmek değil, soruyu dikkatle okumak olacaktı.

{kahraman} kalemi bıraktı. İlk gün olsaydı sayının bir puan, şifre veya gizli kapı olduğunu hemen söyleyebilirdi. Şimdi {yoldas:yonelme|bir arkadaşa} döndü: "Önce bunun ne için yazıldığını sorayım."
---
@omurga
{yoldas:yalin|bir arkadaş} güldü. "Haklısın. Bu sefer yalnızca bir örüntü oyunu."

Bir gün babası {kahraman:yonelme} evdeki alışveriş listesini gösterdi. Her ürünün yanında farklı sayılar vardı: miktar, fiyat ve tarih. "Bunların hepsini aynı kurala göre mi okursun?" diye sordu. {kahraman} güldü. "Hayır. Üç yumurta yazıyorsa yanındaki üç sayı puan değil; miktar!" Babası, "İşte bağlam," dedi. {kahraman} okul kütüphanesinde öğrendiklerinin markette bile karşısına çıkmasına şaşırdı. Matematiğin yalnızca kâğıttaki işlemlerden ibaret olmadığını, doğru anlamanın günlük yaşamla bağlantılı olduğunu düşündü.

{kahraman:ilgi} aklına kırmızı defterin kapağı geldi. İçinde çok sayıda rakam vardı ama hiçbiri tek başına gizemli değildi. Gizemi oluşturan, sayıların nerede, ne zaman ve ne amaçla kullanıldığıydı. Bazı sırlar bir kapının arkasında değil, **sıradan bir kaydın doğru okunmasında saklı** olabiliyordu.
