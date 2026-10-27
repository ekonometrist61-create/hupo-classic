---
baslik: "Zaman Kapsülünün Şifresi"
slug: "hr079-zaman-kapsulunun-sifresi"
fis_kodu: "HR-079"
tur: bilim_kurgu
konu: zaman_kapsulu_gelecek_soru
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Kapsülün içindeki son sayfa boş. Bir şifre mi, bir unutuş mu, yoksa geleceğe bırakılmış bir soru mu?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [kesif, bilim_teknoloji]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: sifre_hr079, tur: lexeme, etiket: "şifre", yuva: hr079_sifre, islev: first_hint}
    - {id: tahmin_hr079, tur: lexeme, etiket: "tahmin", yuva: hr079_tahmin, islev: application}
    - {id: deyim_hr079, tur: idiom, etiket: "İlgisini çekmek", yuva: hr079_ilgisini, islev: application}
    - {id: kavram_hr079, tur: concept, etiket: "Tahmin ile kanıt ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Silindirin kapağındaki tarihler hangileriydi?", secenekler: [{id: A, metin: "2068 ve 2098"}, {id: B, metin: "2038 ve 2098"}, {id: C, metin: "2028 ve 2068"}, {id: D, metin: "2038 ve 2068"}], dogru: D, aciklama: "Kapakta 2038–2068 yazıyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Dedesinin sözüne göre hangisi doğrudur?", secenekler: [{id: A, metin: "Teknoloji ve insan ihtiyaçları birlikte, aynı hızda değişir"}, {id: B, metin: "İnsan ihtiyaçları hiç değişmez; yalnız teknoloji değişir"}, {id: C, metin: "Teknoloji hiç değişmez; insanların ihtiyaçları hızla değişir"}, {id: D, metin: "Teknoloji hızlı değişirken bazı insan ihtiyaçları kolay değişmez"}], dogru: D, aciklama: "Dedesi, hızlı değişen şeyler ile kolay değişmeyen ihtiyaçları ayırıyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 4, metin: "Aslı Hanım'a göre gerçekleşmeyen tahminler ne olur?", secenekler: [{id: A, metin: "Tamamen değersiz olur"}, {id: B, metin: "Değersiz olmaz; geçmişin umutlarını gösterir"}, {id: C, metin: "Bilim insanlarına bırakılır"}, {id: D, metin: "Hemen yok edilmelidir"}], dogru: B, aciklama: "Gerçekleşmeyen tahmin de, insanların o dönemde neyi umduğunu anlatır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 4, metin: "Metinde geçen kapsül ne anlama gelir?", secenekler: [{id: A, metin: "Bir tür kuş"}, {id: B, metin: "Bir çeşit sayfa"}, {id: C, metin: "Geleceğe bırakılmak üzere eşyaların saklandığı kapalı kutu"}, {id: D, metin: "Bir oyun konsolu"}], dogru: C, aciklama: "Kapsül, bir dönemin bilgilerini ileride açılmak üzere saklayan kutudur."}
deyim_cumleleri:
  hr079_ilgisini: "{kahraman:ilgi} ilgisini çeken, metalin üzerindeki küçük bir işaretti: iç içe geçmiş iki soru işareti."
---
@omurga
2068 yılının eylül ayında, Armoni Ortaokulu'nun eski spor salonu yenilenirken yerin altında metal bir silindir bulundu. Silindirin kapağında iki tarih yazılıydı: 2038–2068. Yanında da küçük bir uyarı vardı: Geleceğin öğrencilerine. Açmadan önce birlikte karar verin.

Altıncı sınıf öğrencisi {kahraman}, silindirin ilk fotoğrafını okulun tarih panosunda görünce heyecanlandı. Arkadaşı {yoldas:yalin|bir arkadaş}, “Belki içinde eski bir oyun konsolu vardır,” dedi. Sera, “Bir mesaj olabilir,” diye düşündü. Baha ise kapağın üzerindeki ikinci cümleye takıldı. “Açmadan önce neye karar vereceğiz? Zaten bize bırakılmış.”

Okul müdürü, kapsülü yetkili arşiv uzmanlarıyla birlikte açacaklarını duyurdu. İçeride eski öğrencilerin mektupları, okulun 2038 yılındaki görüntüleri ve dijital kayıtlar bulunabilirdi. Herkesin önünde açmak yerine önce koruma koşulları incelenecekti; eski malzemeleri yanlış biçimde kullanmak zarar verebilirdi. Bu nedenle çocuklar ilk gün yalnız şeffaf koruma kutusunun arkasından silindiri gördüler. {isaret:gunes}
---
@omurga
[[deyim:hr079_ilgisini]] Kapsülün kapağındaki sayı dizisini not etti. {yoldas:yalin|bir arkadaş} bunun bir {kelime:hr079_sifre} olabileceğini söyledi. Sera ise “Belki de bir süs,” dedi. Dördü, öğretmenleri Aslı Hanım'ın gözetiminde tarih ve teknoloji kulübüne katılmaya karar verdi. Arşiv uzmanı, kapsül açılmadan önce eski okul gazetelerini ve mezuniyet kayıtlarını incelemelerine izin verecekti.

{kahraman} o gece dedesinden 2038 yılına ait hatıralar dinledi. Dedesi o dönemde okulun yakınındaki kitapçıda çalışıyordu. İnsanların teknolojiyle ilgili heyecanını hatırlıyordu; herkes, birkaç yıl sonra işleri makinelerin bütünüyle yapacağını konuşuyordu. Oysa aynı yıllarda çocuklar hâlâ arkadaşlarıyla tartışıyor, kaybettikleri kalemleri arıyor, teneffüs zilini bekliyordu. “Bazı şeyler çok hızlı değişir,” dedi dedesi. “Bazı ihtiyaçlar ise kolay değişmez.” {kahraman} bu sözün üzerine düşündü. Geleceğe gönderilecek bir kapsülde yalnız yeni cihazların fotoğrafları mı bulunmalıydı, yoksa insanların nasıl hissettiği de anlatılmalı mıydı?
---
@omurga
Ertesi gün kulüp toplantısında {yoldas:yalin|bir arkadaş} eski teknolojik cihazları incelemek istedi. Veri kartındaki dosya biçimini hiç duymamıştı. Uzmanların açıklamasını dinleyince, bilgiyi saklamanın yalnız bir kutuya koymak olmadığını anladı. Bir cihazın kırılmaması bile yetmeyebilirdi; yıllar sonra ona erişecek yazılım bulunmayabilirdi. Sera “Kâğıtlar daha mı güvenli?” diye sordu. Arşiv uzmanı, kâğıdın da nemden, ışıktan ve yanlış saklamadan zarar görebileceğini anlattı. Çocuklar sorunun tek bir teknoloji seçmekten çok, bilginin ileride okunabilmesini düşünmek olduğunu gördü.

Kapsülün üzerine yazılmış birlikte karar verin uyarısının nedeni de yavaş yavaş belirginleşiyordu. İçindeki mektuplar, başka çocukların bir zamanlar gönüllü olarak bıraktığı kişisel düşüncelerdi. Onları okulun herkes tarafından görülen duvarına gelişigüzel asmak doğru olmayabilirdi. Okul yönetimi arşiv koşullarını ve paylaşım izinlerini kontrol etti. Bazı belgeler eğitim amaçlı sergilenebilirken bazıları yalnız araştırma için incelenecekti. {kahraman}, birine geçmişten mektup göndermekle onu tüm dünyaya yayımlamanın aynı şey olmadığını anladı.
---
@omurga
Kapsül açıldığında sınıfta küçük bir sergi hazırlandı. İçinden kâğıt mektuplar, bir çocuk çizimi, dönemin okul fotoğrafı ve çalışır durumda olup olmadığı bilinmeyen bir veri kartı çıktı. Kâğıtlar koruma uzmanı tarafından ayrıldı. Veri kartıysa güvenli, çevrimdışı bir ortamda incelenecekti. Öğrencilere, “Eski dijital dosyalar da dikkatli açılmalı,” dendi. “Hangi yazılımla üretildiğini bilmiyorsak veri kaybına ya da güvenlik sorununa yol açabiliriz.”

Mektuplarda 2038'in çocukları geleceği hayal ediyordu. Biri bütün kitapların havada uçacağını yazmış, diğeri her çocuğun uzaya gideceğini tahmin etmişti. Sera, “Bu {kelime:hr079_tahmin} gerçekleşmedi,” deyince Aslı Hanım, “Gerçekleşmemesi onları değersiz kılmaz,” dedi. “Geleceği anlamanın bir yolu, geçmişte insanların neyi umduğuna bakmaktır.”

Çocuklar veri kartından kurtarılan metinleri incelerken bir dosya buldu: Son Sayfa. Dosya açıldığında yalnızca boş bir sayfa görünüyordu. {kahraman} bunun teknik hata olduğunu düşündü. {yoldas:yalin|bir arkadaş}, “Belki asıl şifre boşlukta,” dedi. Baha, “Belki yazmayı unutmuşlar,” diye karşılık verdi. Aslı Hanım dosyanın oluşturulma tarihini, biçimini ve kontrol kayıtlarını gösterdi. Sayfa gerçekten boş bırakılmış gibi görünüyordu; dosyada kayıp içerik olduğuna dair bir kanıt yoktu.
---
@omurga
“Bunu neden yapmış olabilirler?” diye sordu Sera.

Aslı Hanım, “Bir tahmin yürütelim, ama tahminimizi kanıtla karıştırmayalım,” dedi. Çocuklar dört olasılık yazdı: unutulmuş olabilir; hata olmuş olabilir; gelecek öğrencilerinin doldurması için boş bırakılmış olabilir; bir soruya işaret ediyor olabilir. {kahraman}, kapağın üzerindeki cümleyi tekrar okudu: Açmadan önce birlikte karar verin. Belki kapsülün asıl amacı yalnız geçmişi göstermek değil, bugünün çocuklarına bir seçim yaptırmaktı.

Dijital metinlerde bir de küçük ses dosyası bulundu. Uzmanlar dosyayı güvenli ortamda açtıklarında gürültülü bir okul bahçesi duyuldu. Çocukların kahkahaları ve uzaktan gelen bir zil sesi, {kahraman:yonelme} kendi okulunu hatırlattı. Sonra bir öğrenci, “Otuz yıl sonra bu sesi hâlâ duyacaklar mı?” diye soruyordu. Ses kaydı kısa sürüyordu. {yoldas:yalin|bir arkadaş}, “Bizim okulda zil daha farklı çalıyor,” dedi. Baha, “Ama teneffüse sevinmek pek değişmemiş,” diye ekledi. Ses kaydı onları tanımadıkları çocuklara yaklaştırmıştı. Geçmiş bir tarih tablosu değil, bir zamanlar nefes almış insanların yaşadığı gerçek bir dönemdi.
---
@omurga
Sera mektuplardan birinde küçük bir tohum resmi gördü. Mektubu yazan öğrenci, okul bahçesinde diktikleri fidanın büyüyüp büyümediğini merak ediyordu. Çocuklar okulun bahçesine çıktılar. Eski fotoğraflarla karşılaştırdıklarında güney duvarındaki büyük ağacın yıllardır orada olabileceğini düşündüler. Ancak fotoğraflardan kesin olarak aynı ağaç olduğunu söyleyemiyorlardı. Belediye kayıtlarında bahçeye dikilen ağaçlarla ilgili bilgiler bulundu. Müdürün yardımıyla ilgili kayıtları incelediler. Bir kısmı fidanın yerini doğruluyordu. {kahraman}, bir çocuğun yıllar önce bıraktığı küçük bir soruyu yanıtlamak için belge araştırmanın ne kadar heyecanlı olabileceğini gördü.

Baha, eski yazıları okurken 2038 çocuklarının kullandığı bazı sözcükleri anlamakta zorlandı. O dönemde popüler olan oyunların isimleri, moda ifadeler ve kısaltmalar bugün farklıydı. Aslı Hanım, dilin de zamanla değiştiğini hatırlattı. Çocuklar bilinmeyen kelimeleri hemen kendi dönemlerinin anlamıyla yorumlamak yerine, eski kaynakların bağlamına baktı. Böylece kapsül yalnız bir tarih oyunu olmaktan çıktı; bir metni anlamak için yazıldığı zamanı bilmenin önemini gösteren bir çalışmaya dönüştü.
---
@omurga
Arşivde bulunan okul gazetesinde 2038 yılında yapılan bir toplantının haberi yer alıyordu. Haberin başlığı şuydu: “Zaman Kapsülüne Ne Koyalım?” Eski öğrenciler kendi geleceklerini anlatan birer mektup yazmıştı. Ancak son sayfanın neden boş olduğu haberde açıklanmıyordu. Haberin altında küçücük bir alıntı vardı: Gelecek, yalnız bizim cevaplarımızla tamamlanmayacak.

Baha bu cümleyi görünce, “O zaman boş sayfa gerçekten bilinçli,” dedi. {yoldas:yalin|bir arkadaş} tam emin değildi. “Bir alıntı var diye dosyanın neden boş olduğunu bildiğimizi söyleyemeyiz,” diye uyardı. Arşiv uzmanı onların dikkatini çekti: Belgeler farklı kişiler tarafından yazılmıştı. Gazetedeki söz, kapsülü hazırlayanların bütün düşüncelerini yansıtmayabilirdi. Öğrenciler eski mezunlardan hâlâ ulaşılabilecek kişilerin olup olmadığını araştırmak istedi. Okul yönetimi kamuya açık mezunlar derneği üzerinden uygun bir iletişim kurdu. Kişilerin özel bilgilerine izinsiz ulaşılmadı.
---
@omurga
Birkaç gün sonra kapsül projesinde yer almış olan emekli öğretmen Derya Hanım çevrim içi bir görüşmeye katıldı. Çocuklar ilk önce kapsülün yapımını sordu. Öğretmen, o günlerde gelecekteki yaşamı hayal etmenin sınıfı çok heyecanlandırdığını anlattı. “Hepimiz geleceği bilebileceğimizi sandık,” dedi. “Sonra çocuklardan biri, ‘Gelecektekiler bizim tahminlerimizi beğenmezse ne olacak?’ diye sordu. İşte o anda farklı bir şey yapmaya karar verdik.”

“Son sayfayı bu yüzden mi boş bıraktınız?” diye sordu {kahraman}.

“Evet,” dedi Derya Hanım. “Ama boşluğun kendisi bir cevap değildi. Geleceğin öğrencilerine kendi sorularını sorma hakkı tanıdık. Biz geçmişten seslenebilirdik; onların yerine karar veremezdik.”

{yoldas:yalin|bir arkadaş} bir an düşündü. “O zaman biz de geleceğe bir soru bırakabiliriz.”
---
@omurga
Derya Hanım görüşmenin sonunda öğrencilerin merak ettiği bir ayrıntıyı anlattı. Kapsülü hazırlayan sınıfta herkes aynı fikri savunmamıştı. Bazıları onu yalnız eğlenceli bir hatıra olarak görmüş, bazıları gelecek kuşaklara uyarı yazmak istemişti. Bir öğrenci gelecekte hiçbir problemin kalmayacağını hayal etmiş, diğeri bunun imkânsız olduğunu söylemişti. Öğretmenleri, yazacakları mektuplarda tek bir ortak görüşe zorlamamıştı. Bunun yerine her öğrencinin kendi umut ve kaygılarını gerekçesiyle anlatmasını istemişti. Bu yüzden kapsülden birbirine benzemez mektuplar çıkmıştı. {kahraman}, geleceği tek bir resim gibi çizmenin herkesin dünyasını daraltacağını düşündü.

Çocuklar yeni kapsül için sınıflarından öneri topladı. Bazıları ilerideki öğrencilerin aynı okul bahçesinde oyun oynayıp oynamayacağını soruyordu. Bazıları suyun yeterli olup olmayacağını, kimi de dillerin nasıl değişeceğini merak ediyordu. {yoldas:yalin|bir arkadaş} ilk başta bütün önerileri tek bir soru altında toplamaya çalıştı. Sonra bunun bazı çocukların sesini kaybettireceğini fark etti. Ortak bir soru hazırlanabilir, ama yanında farklı soruların da bulunmasına izin verilmeliydi. Okul yönetimi öğrencilerin paylaşmayı kabul ettiği soruları küçük bir seçki hâlinde kapsüle koymayı uygun gördü. Böylece çoğunluğun kararı azınlığın merakını tamamen ortadan kaldırmıyordu.
---
@omurga
{kahraman}, arkadaşlarının geleceğe dair kaygılarını okurken biraz huzursuz oldu. Belki otuz yıl sonra şehirlerde bazı sorunlar çözülmüş, yenileri ortaya çıkmış olacaktı. Hiç kimse bunun ayrıntılarını bilemezdi. Aslı Hanım, bilim kurgu öykülerinin bazen kesin tahminden çok olası gelecekleri düşünmek için yazıldığını anlattı. {kahraman} kendi hayalinde 2098'deki bir öğrencinin kapsülü açtığını canlandırdı. Bu öğrenci onların kullandığı kimi sözcükleri anlamayabilir, kimi korkularını gereksiz bulabilir, fakat mektuptaki merak duygusunu tanıyabilirdi. Bu düşünce, geleceğe gönderilecek sorunun biçimini değiştirdi.

Bir ders günü Aslı Hanım sınıfa uzun bir kâğıt şerit getirdi. Şeridin bir ucuna 2038, ortasına 2068, öbür ucuna 2098 yazdı. Öğrenciler kendi ailelerinin anlattığı olayları, okulun kuruluşunu ve kapsüllerin tarihlerine ilişkin bilgileri uygun yerlere yerleştirdi. {yoldas:yalin|bir arkadaş} önce bütün tarihlerden bir hikâye çıkarmanın kolay olduğunu düşündü. Sonra bir olayın sonucunu başka bir olayın nedeni sanmanın mümkün olduğunu fark etti. Öğretmen, aynı dönemde yaşanan iki olayın mutlaka birbirine bağlı olmadığını anlattı. Tarih çizelgesi yalnız “ne zaman” sorusuna cevap veriyordu; “neden” için başka kaynaklar gerekiyordu.
---
@omurga
{kahraman} dedesinin anlattığı bir olayı şeride yazdı, sonra karşısına “aile hatırası” notunu düştü. Aslı Hanım bunu görünce sevindi. Anılar tarihi anlamanın önemli parçalarıydı ama resmi belgeyle aynı türden bilgi değildi. Bir öğrenci “O zaman anılara güvenmeyelim,” dedi. Öğretmen, “Güvenmemek ile kaynağın sınırını bilmek aynı şey değil,” diye cevap verdi. {kahraman} bundan etkilendi. Kapsülde bulunan mektuplar da geleceğe dair kesin rapor değildi; çocukların o günkü düşüncelerini anlatan değerli tanıklıklardı.

Zaman şeridinin sonuna yaklaştıklarında 2098 için boş bir alan bırakıldı. {yoldas:yalin|bir arkadaş} “Buraya uçan arabalar çizelim,” dedi. Sera bunun yanına ağaçlar koymak istedi. Baha, gelecekte okulda oynanacak oyunları düşündü. Aslı Hanım hepsine farklı renkli kalem verdi ve şeridin sonunda küçük bir başlık açtı: Tahminlerimiz. Hiçbiri bu çizimleri gerçekleşmiş olay gibi sunmadı. {kahraman} boş alanın ne kadar büyük göründüğünü fark etti. Geleceğe dair çizilen şeylerin kesin olmaması bir eksiklik değildi; henüz yaşanmamış zamanın doğasında vardı.
---
@omurga
Okul, yeni bir kapsül hazırlamaya karar verdi. Bu kapsül 2098'de açılacaktı. Öğrenciler yine mektup yazabilecekti, ancak bu kez ortak bir sorunun da kapsüle konması istendi. Dört arkadaş görev aldı: Geleceğin öğrencilerine sorulacak soruyu bulacaklardı.

İlk öneriler eğlenceliydi. {yoldas:yalin|bir arkadaş}, “Uçan arabalar hâlâ var mı?” diye yazdı. Baha, “Robotlar ödev yapıyor mu?” dedi. Sera, “İnsanlar doğayı korumayı öğrendi mi?” sorusunu önerdi. {kahraman} ise “Gelecekte çocuklar ne kadar özgür olacak?” diye sordu. Her soru başka bir düşünce taşıyordu. Ama hangisi otuz yıl sonra anlamlı kalacaktı?

Tartışma büyüdü. {yoldas:yalin|bir arkadaş}, teknolojinin geleceği değiştirdiğini savunuyordu. Sera, doğanın korunmadığı bir gelecekte teknolojinin tek başına çözüm olmadığını söylüyordu. Baha, okul hayatını daha somut buluyordu. {kahraman} ise herkesin cevabını içine alabilecek bir soru istiyordu. Bir süre hiçbirinde anlaşamadılar. Sonra Aslı Hanım, “Sorunuzun yanıtını gelecektekilerin bulması gerekmiyor,” dedi. “Belki soru onlara neyi düşünmeleri gerektiğini değil, neyi düşünmek istediklerini hatırlatmalı.”
---
@omurga
Bu fikir onları yeniden masaya oturttu. İlk olarak otuz yıl sonraki öğrencilerin bugünkü yaşamlarını bilmeyeceğini düşündüler. Aynı zamanda kendi tahminlerinin de eksik kalabileceğini kabul ettiler. Bir zamanlar gelecekteki herkesin uzaya gideceğini düşünen çocukların mektupları gibi, kendi beklentileri de gerçekleşmeyebilirdi. Soru, kesin tahmin gerektirmemeliydi.

Kapsül için seçilen sorunun son biçimi kolay bulunmadı. Sera, doğa konusunda bir sorunun hiç yer almamasına razı değildi. {yoldas:yalin|bir arkadaş}, teknolojiyi doğrudan anmayan bir cümlenin yetersiz olduğunu söylüyordu. Baha ise bütün çocukların cevaplayabileceği bir soru istiyordu. Tartışma sertleşince Aslı Hanım kâğıtları kenara bıraktırdı. “Şimdi herkes diğerinin kaygısını kendi sözleriyle anlatsın,” dedi. {yoldas:yalin|bir arkadaş} Sera'nın gelecekte yaşam alanlarının korunmasını önemsediğini söyledi. Sera, {yoldas:ilgi|bir arkadaşın} yeniliklerin insanların hayatını nasıl değiştireceğini merak ettiğini açıkladı. Baha ise {kahraman:ilgi} tek bir gruba ait olmayan açık bir soru aradığını dile getirdi. Birbirlerinin sözlerini doğru anladıklarında yeni bir cümle kurmak kolaylaştı.
---
@omurga
Son cümlede sorun sözcüğünü kullanıp kullanmayacakları da tartışıldı. Kimi öğrencilere göre gelecek yalnız sorunlardan ibaret değildi. {kahraman}, “Bugün bildiklerinizle hangi iyiliği büyütebilirsiniz?” diye sordu. {yoldas:yalin|bir arkadaş}, bunun fazla belirsiz olduğunu düşündü. Bir süre sonra iki soruyu aynı yerde kullanabileceklerini gördüler: Geleceğin çocukları hem çözmek istedikleri sorunları hem de korumak istedikleri güzel şeyleri anlatabilirdi. Böylece kapsüle konacak ortak metin, bir talimat değil, açık bir davet hâline geldi. Kapsülün içindeki boş sayfanın anlamını şimdi daha iyi kavrıyorlardı: Gelecek öğrencileri yalnız cevap verecek değil, yeni sorular da yazacaktı.

Kapsülün hazırlık komitesi, geleceğe nelerin konmaması gerektiğini de tartıştı. Baha okulun öğrencilerinin kişisel iletişim bilgilerini bir anı defterine eklemeyi önerdi. Sera bunun uygun olmadığını söyledi. İnsanların yıllar sonra kimin okuyacağını bilmediği kişisel bilgilerini saklamak riskliydi. Müdür ve arşiv uzmanı, paylaşılabilecek belgeler için gerekli izinlerin kontrol edilmesini istedi. Bazı öğrenciler yalnız ismini yazmak, bazıları ise hiçbir kişisel bilgi paylaşmamak istiyordu. Bu tercihlere saygı duyulmalıydı. {kahraman}, “Gelecek bizim her ayrıntımızı bilmek zorunda değil,” dedi.
---
@omurga
Bir başka tartışma, hangi mektupların seçileceği hakkındaydı. Sadece en güzel yazanların mektupları mı kalmalıydı? {yoldas:yalin|bir arkadaş} başlangıçta böyle düşündü; iyi yazılar gelecekte daha çok beğenilirdi. Aslı Hanım, kapsülün bir yarışma olmadığını açıkladı. Çocukların farklı seslerini korumak önemliydi. Daha kısa yazan ya da farklı biçimde kendisini ifade eden öğrencilerin düşünceleri de değerliydi. Bunun üzerine isteyenlerin çizimlerini, kısa notlarını veya sınıfça hazırlanan ortak kayıtları ekleyebilecekleri bir yöntem oluşturuldu. İçerikler güvenli ve onaylı biçimde saklanacaktı. Böylece geleceğin öğrencileri yalnız en güzel cümleleri değil, bir sınıfın ne kadar farklı biçimde düşünebildiğini görebilecekti.
---
@omurga
Baha, eski kapsülün kapağındaki iç içe geçmiş soru işaretlerini gösterdi. “Bence iki soru işareti iki zamanı anlatıyor,” dedi. “**Geçmiş bize soruyor, gelecek bize soracak**.” Bu yorum doğrulanmış değildi ama güzel bir fikirdi. Sera çizimi yeniden yaptı: Bir soru işaretinin ucuna küçük bir tohum, diğerine yıldız koydu. {kahraman}, geçmişten gelen bir sorunun gelecekte yeni bir soruya dönüşmesini düşündü.

Sonunda ortak cümlelerini buldular: Bugün bildiklerinizle hangi sorunu çözebilirsiniz ve bizden daha iyi anlamak istediğiniz şey nedir? {yoldas:yalin|bir arkadaş} bu cümleyi teknolojiye, Sera doğaya, Baha okul yaşamına, {kahraman} insan haklarına bağlayabiliyordu. Fakat soru hiçbirini tek başına dayatmıyordu. Herkes kendi cevabını verebilir, hatta soruyu değiştirmeyi seçebilirdi.
---
@omurga
Kapsüle kişisel bilgiler değil, öğrencilerin yayınlanmasına izin verdiği ortak çalışmalar kondu. Çocuklar geleceğe gönderilecek kayıtların güvenli biçimde saklanması ve yıllar sonra okunabilmesi için yetişkinlerle birlikte farklı arşivleme yöntemlerini konuştu. Derya Hanım eski veri kartlarının açılmasının ne kadar zor olduğunu hatırlattı. {kahraman}, “Belki kâğıtla dijital kopyayı birlikte saklamak daha iyi olur,” dedi. Uzmanlar uygun malzeme ve saklama koşulları konusunda karar verdi. Çocuklar güvenli arşivleme işinin sandık seçmekten daha karmaşık olduğunu öğrendi.

Kapsülün kapanacağı gün okul bahçesinde küçük bir tören yapıldı. Herkes bir mektup yazmıştı. {yoldas:yalin|bir arkadaş}, uçan araçlar yerine güvenli ulaşım sorununa odaklanan bir not bırakmıştı. Sera doğa gözlemlerinden söz ediyordu. Baha okulda herkesin öğrenebileceği farklı yollar olmasını istiyordu. {kahraman:ilgi} mektubu ise tek cümleyle başlıyordu: Sizin yerinize her şeyi bildiğimi sanmıyorum.
---
@omurga
Eski kapsülden çıkan boş sayfanın görüntüsü yeni kapsülün üzerine işlendi. Altına da öğrencilerin hazırladığı ortak soru eklendi. Çocuklar kapağın kapanışını izlerken geçmiş ile geleceğin birbirine bağlandığını hissetti. Zaman bir çizgi gibi uzanıyordu; ama çizginin üzerindeki her insan kendi yerinden bir soru sorabiliyordu.

Törende herkes kendi mektubunu okumadı. Kimi çocuk yazdıklarını başkalarıyla paylaşmak istemiyordu; bu tercihine saygı duyuldu. Sadece gönüllü olanlar kısa bölümler okudu. Bir öğrenci gelecekte de arkadaşlıkların değerli olmasını diliyordu. Başka biri geleceğin okullarında herkesin erişebileceği farklı öğrenme yolları olmasını istiyordu. Sera, en çok doğa gözlem defterlerini kapsüle koymakla gurur duydu. {yoldas:yalin|bir arkadaş} ise hazırladıkları dijital arşivin ileride açılabilir olması için uzmanların yaptığı testleri merak ediyordu. Kapsül kapanınca hiçbiri kendi isteğinin tek doğru gelecek olduğunu düşünmüyordu.
---
@omurga
{kahraman}, kapağın son kez kapanmasını izlerken kendisini kısa süreliğine 2098'de hayal etti. Belki o zamanki öğrenciler bugün ona olağanüstü gelen bazı araçları sıradan bulacaktı. Belki kendi dönemlerinin dertleri ve sevinçleri bambaşka olacaktı. Ama yine de bir kutunun içinden çıkan eski bir mektubu okurken benzer bir heyecan yaşayabilirlerdi. Bu düşünce {kahraman:belirtme} rahatlatmıştı. Geleceğin neye benzeyeceğini tamamen kontrol edemezdi; fakat bugünün insanlarına karşı sorumluluk alabilir, bir sonraki kuşağın kendi yolunu bulması için yer bırakabilirdi.

Kapsülü hazırlayan çocukların en çok tartıştığı konu aslında ne kadar çok bilgi gönderecekleriydi. {yoldas:yalin|bir arkadaş} okulun her gününü kaydetmek istiyordu. Sera, böyle yaparlarsa önemli olanı seçemeyeceklerini söyledi. Dört arkadaş mektupları incelerken geçmişteki öğrencilerin ne kadar az şeyle çok şey anlatabildiğini görmüştü. Bir eski defter sayfasında yalnız “Bugün en yakın arkadaşımla barıştım” yazıyordu. Bu kısa cümle, o günün sevinci hakkında uzun bir rapordan daha fazla duygu taşıyordu. {kahraman} kendi mektubunda çok sayıda tahmin yerine bir günü anlatmaya karar verdi: Okul bahçesinde dört arkadaşın tartışıp sonra birlikte bir soru bulduğu günü.
---
@omurga
Mektupları yazarken öğretmen, cevaplanması zor bir soru sordu: “Geleceğin çocukları sizin yazdıklarınızı okuduktan sonra sizi nasıl tanısın isterdiniz?” Baha kendilerinin yalnız teknolojiyle ilgilenen insanlar gibi görünmesini istemiyordu. {yoldas:yalin|bir arkadaş}, bugün kullandıkları araçların yıllar sonra komik gelebileceğini kabul etti. Sera, o zamanki öğrencilerin doğaya verilen önemle ilgilenmesini umdu. {kahraman} ise en çok birlikte karar vermeye çalıştıklarının anlaşılmasını istiyordu. Aralarındaki farklar artık bir engel değil, kapsülü zenginleştiren ayrı seslerdi.

Yeni kapsül kapanmadan önce çocuklar eskisindeki boş sayfanın kopyasını masaya koydu. Her biri o sayfayı ilk gördüğünde ne düşündüğünü anlattı. {yoldas:yalin|bir arkadaş} dosyanın bozuk olduğunu sanmıştı. Baha yazılacak şeyin unutulduğunu düşünmüştü. Sera boşluğun kendisine bir anlam yüklemişti. {kahraman} ise bunun arkasındaki soruyu bulmak istemişti. Aynı sayfaya bakmış, dört ayrı açıklama üretmişlerdi. Sonra kaynak aramış, bir tanığa ulaşmış ve düşüncelerini değiştirmişlerdi. Bu süreç, buldukları cevaptan daha önemli görünüyordu.
---
@omurga
Aslı Hanım, “Hikâyenizi geleceğe anlatmak için yalnız sonucu yazmayın,” dedi. “Hangi adımlardan geçerek anladığınızı da anlatın.” Çocuklar son sayfanın yanına kısa bir araştırma günlüğü ekledi. Böylece 2098 öğrencileri yalnız boş sayfanın anlamını değil, o anlama ulaşırken sorulan soruları da görebilecekti. Belki onlar da kendi zamanlarında bir başka gizemi çözerken aynı yöntemden yararlanacaktı.

Baha, artık şifrenin bir sayı dizisi olmadığını düşünüyordu. Şifre, geçmişten gelen işaretin arkasındaki düşünceyi anlamak için kullanılan sorulardaydı. {yoldas:yalin|bir arkadaş} buna itiraz etti: “Kapsülün gerçek şifresi de vardı; onu uzmanlar çözdü.” İkisi güldü. Bazen bir kelimenin gerçek ve mecaz anlamı aynı hikâyede buluşabiliyordu. {kahraman}, “O zaman ikisini de öğrendik,” dedi.
---
@omurga
Tören için hazırlanan kutunun içine herkes bir eşya bırakmak istemişti. Baha eski bir oyun kartı, Sera kendi çizdiği küçük bir harita, {yoldas:yalin|bir arkadaş} ise geleceğin araçlarıyla ilgili tahmin listesi getirdi. {kahraman}, kutuya sığacak yerin sınırlı olduğunu hatırlattı. Bunun üzerine çocuklar nesneleri neden seçtiklerini anlattı. Kimi anısını saklamak, kimi gelecek öğrencilere bir soru bırakmak istiyordu. Sonunda yalnız seçilmiş birkaç nesneyi koydular; diğerlerinin hikâyesini ortak deftere yazdılar. Kapsül artık her şeyi biriktiren bir kutu değil, düşünülerek hazırlanmış bir mesajdı.
---
@omurga
Törenden sonra {kahraman} eve giderken dedesine uğradı. Dedesi ona çocukluğunda telefonların nasıl değiştiğini anlattı. Bir zamanlar cep telefonunun bile şaşırtıcı olduğunu, sonra görüntülü konuşmanın sıradanlaştığını söyledi. {kahraman}, “Demek ki geleceği tahmin etmek çok zor,” dedi. Dedesi gülümsedi. “Zor,” dedi. “Ama geleceği etkilemek için onu tam tahmin etmek gerekmez. Bugün yaptığın şeyler de yarının bir parçasıdır.”

{kahraman} ertesi sabah okul bahçesindeki yeni toprağa baktı. Kapsül görünmüyordu; üzerinde küçük bir levha vardı. Levhada açılacağı tarih ve bir soru bulunuyordu: 2098'de neyi yeniden düşünmek istersiniz? {kahraman}, dün yazdıkları sorunun burada başka bir biçime dönüştüğünü gördü. Aslı Hanım, çocukların sorularını korumak yerine gelecekte sorunun değişmesine izin vermenin önemli olduğunu söyledi.

Baha, “Peki ya 2098'de kapsülü açanlar bizim sorumuzu saçma bulursa?” diye sordu. {yoldas:yalin|bir arkadaş} güldü. “O zaman kendi sorularını yazsınlar.” Sera, “Belki bizim bilmediğimiz şeyleri biliyor olacaklar,” diye ekledi. {kahraman}, “Ya da bizim çözdüğümüz bir problemi yeniden çözmek zorunda kalacaklar,” dedi. Dördü bir süre sessiz kaldı. Gelecek yalnız ilerleme değil, dikkat isteyen sorumluluklar da taşıyabilirdi.
---
@omurga
{kahraman} eski kapsülden çıkan boş sayfayı düşündü. Artık ona eksiklik gibi görünmüyordu. Bazen bir boşluk, unutulmuş bir cevap değil, gelecek bir insan için ayrılmış yerdi. Otuz yıl sonra başka çocuklar bu sayfayı açacak, belki onları hiç tanımadan aynı merakı hissedecekti. {kahraman} defterine son bir cümle yazdı: İyi bir soru, zamanın içinden geçip başka birinin düşüncesinde yeniden başlayabilir.
