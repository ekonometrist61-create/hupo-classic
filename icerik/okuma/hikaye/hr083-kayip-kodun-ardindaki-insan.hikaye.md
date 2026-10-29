---
baslik: "Kayıp Kodun Ardındaki İnsan"
slug: "hr083-kayip-kodun-ardindaki-insan"
fis_kodu: "HR-083"
tur: gizem
konu: veri_yetki_guven
sinif_alt: 7
sinif_ust: 7
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D15]
yetiskin_uygun: false
tanitim: "Kütüphanenin dijital kataloğunda kitaplar sessizce yer değiştiriyor. Suçlu bir kod mu, yoksa bir karar mı?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 7
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, dayanisma]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D15
  ogrenme_hedefleri:
    - {id: katalog_hr083, tur: lexeme, etiket: "katalog", yuva: hr083_katalog, islev: first_hint}
    - {id: yetki_hr083, tur: lexeme, etiket: "yetkili", yuva: hr083_yetki, islev: application}
    - {id: deyim_hr083, tur: idiom, etiket: "Kafasına göre", yuva: hr083_kafasina, islev: application}
    - {id: kavram_hr083, tur: concept, etiket: "Veri, yetki ve güven ilişkisi", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (7. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Kahramanın fark ettiği ilk garip değişiklik neydi?", secenekler: [{id: A, metin: "Bilim kurgu kitabının masal kategorisinde görünmesi"}, {id: B, metin: "Kütüphanedeki bütün kitapların bir gecede kaybolması"}, {id: C, metin: "Kütüphanenin hafta sonu erken kapanmaya başlaması"}, {id: D, metin: "Ödünç alınan kitapların iade tarihlerinin silinmesi"}], dogru: A, aciklama: "Kahraman, ayırttığı bilim kurgu kitabının masal kategorisinde göründüğünü fark etti."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 3, metin: "Öneri motoru ile resmî katalog arasındaki fark nedir?", secenekler: [{id: A, metin: "Öneri birden fazla başlık gösterebilir, ama raf konumu yalnız bir yerdedir"}, {id: B, metin: "İkisi aynı görevi yapar; öneri ile katalog birbirinin yerine geçer"}, {id: C, metin: "Öneri motoru kitabın raf numarasını ve konumunu her gün yeniden belirler"}, {id: D, metin: "Katalog yalnız öneri yapar, kitabın konumunu hiçbir zaman göstermez"}], dogru: A, aciklama: "Bir kitap birden çok öneri listesinde yer alabilir; fiziksel rafı ise tek bir yerdedir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 7, metin: "Kahramanın “Aynı etkinlikte tanıtılmaları, değişikliğin nedeni olduğunu göstermiyor.” sözü neyi vurgular?", secenekler: [{id: A, metin: "Etkinliğe katılan öğrenciler değişikliklerin asıl sorumlusudur"}, {id: B, metin: "Kitapların etkinlikte tanıtılması hiçbir zaman yapılmamalıdır"}, {id: C, metin: "Ortak bir özellik, tek başına neden-sonuç kanıtı değildir"}, {id: D, metin: "Değişikliği bir kullanıcının kasıtlı kararı olarak görmek gerekir"}], dogru: C, aciklama: "İki olayın aynı ortak özelliği paylaşması, birinin diğerinin nedeni olduğunu kanıtlamaz."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 7, metin: "Metinde geçen sınıflandırma ne anlama gelir?", secenekler: [{id: A, metin: "Kitap kapaklarının renklerine göre dizilmesi ve süslenmesi"}, {id: B, metin: "Kitapların konu, tür ve raf düzenine göre gruplandırılması"}, {id: C, metin: "Kitapların ödünç alma süresini belirleyen bir yazılım"}, {id: D, metin: "Öğrencilerin en çok okuduğu kitapları seçen bir yarışma"}], dogru: B, aciklama: "Sınıflandırma, kitapların düzenli gruplara ayrılmasıdır."}
deyim_cumleleri:
  hr083_kafasina: "{yoldas:yalin|bir arkadaş} de küçük bir şaka yaptı: “Robotun kitap zevki olsa bile rafların yerini kafasına göre değiştirmemeli.”"
---
@omurga
Okul kütüphanesinin dijital {kelime:hr083_katalog} ilk gariplik pazartesi sabahı fark edildi. Yedinci sınıf öğrencisi {kahraman}, geçen hafta ayırttığı bilim kurgu kitabının artık “masal” kategorisinde göründüğünü söyledi. Arkadaşı {yoldas:yalin|bir arkadaş}, bunun yalnız etiket hatası olduğunu düşündü. Ancak ikinci bir kitapta aynı değişiklik ortaya çıkınca durum tuhaflaştı. Kütüphaneci Aylin Hanım kayıtları kontrol ettiğinde bazı kitapların kategorileriyle raf numaralarının gece boyunca değiştiğini gördü.

“Sisteme biri mi girdi?” diye sordu {yoldas:yalin|bir arkadaş}.

Aylin Hanım hemen cevap vermedi. “Henüz bilmiyoruz,” dedi. “Bir insanın değişiklik yapmış olması da, bir yazılım işleminin kayıtları etkilemiş olması da mümkün. Bunu {kelime:hr083_yetki} kişiler incelemeli.”

{kahraman}, kitap kulübünde yürüttükleri okuma listesini düşündü. Liste yanlış kategoriler yüzünden karışırsa öğrenciler istedikleri kitapları bulmakta zorlanacaktı. Bazı arkadaşlarının yeni okuma alışkanlığı kazanmak için hazırladığı öneriler de doğru görünmüyordu. Bu nedenle konuyu şaka gibi görmedi. Ancak internetteki filmlerde gördüğü gibi gizli bir kullanıcı aramaya kalkmak da istemiyordu. {isaret:kitap}
---
@omurga
Üçüncü arkadaşları Aras, bilgisayar kulübündeydi. {yoldas:yalin|bir arkadaş} ona, “Sen bu işlerden anlıyorsun, kim değiştirmiş bulur musun?” dedi. Aras başını iki yana salladı. “Benim öğrenci hesabımla başka kullanıcıların kayıtlarını araştırmam doğru değil,” dedi. “Önce kütüphaneciye ve okulun bilişim sorumlusuna haber verelim.” {kahraman} bu cevaba sevindi. Gizemi çözmek isterken başka insanların mahremiyetini ihlal etmeyeceklerdi.

İlk karışıklığın olduğu gün {kahraman} bir kitabı rafta ararken daha küçük bir öğrencinin üzüldüğünü gördü. Çocuk, sevdiği fantastik serinin ikinci kitabını bulamadığı için ilk kitabı bile okumak istemiyordu. “Bütün sistem yanlışsa buraya niye geleyim?” diye sordu. {kahraman} o anda hatanın yalnız ekrandaki bir yazı olmadığını fark etti. Bir çocuğun okumaya duyduğu ilgiyi bile etkileyebiliyordu. Aylin Hanım kitabı elle arayıp bulmalarına yardım etti. Çocuk mutlu oldu, fakat {kahraman} onu bir sonraki sefer aynı yardımı alabilecek mi diye düşündü. Katalogun güvenilir olması özellikle tek başına kitap seçmek isteyen öğrenciler için önemliydi.
---
@omurga
Okulda kütüphane sistemi yeni bir öneri motoruyla geliştirilmişti. Öğrencilerin kendi tercih ettikleri türleri bulabilmesi amaçlanıyordu. Ancak öneri motoruyla resmî katalog aynı görevde değildi. {kahraman} bunu kütüphaneciden öğrendi. Bir kitap okurun ilgisine göre birden fazla başlık altında önerilebilir, yine de rafta yalnız belirli bir konumda bulunurdu. Örneğin tarihî bir macera romanı hem tarih hem de macera önerileri arasında yer alabilir; bu onun raf etiketini otomatik olarak değiştirmeyi gerektirmezdi. {kahraman} sistemin karışıklığının neden kitap seçmeyi zorlaştırdığını daha iyi anladı.

{yoldas:yalin|bir arkadaş} ise kütüphanede insanların neden dijital katalog kullandığını merak etti. “Raflara bakarak seçsek olmaz mı?” diye sordu. Aylin Hanım, bunun da mümkün olduğunu söyledi; fakat kitapların çok olduğu yerlerde, erişim ihtiyaçları farklı olan öğrenciler için arama sistemlerinin büyük kolaylık sağladığını anlattı. Bazı çocuklar yazar adını biliyor, bazıları yalnız konuyu hatırlıyor, bazıları da kapak resminden kitabı tanıyordu. İyi bir katalog farklı arama yolları sunmalıydı. Böylece bir hata, yalnız teknoloji meraklılarını değil, pek çok okuru etkileyebilirdi.
---
@omurga
Bilişim sorumlusu Murat Bey öğleden sonra kütüphaneye geldi. Sistemin yönetici bölümünü yalnız kendisi ve yetkili çalışanlar açabiliyordu. Çocukların ekranına kişisel kayıtlar veya hesap bilgileri yansıtılmadı. Murat Bey, güvenli bir özet hazırladı. Bazı kitap etiketleri gece saatlerinde otomatik bir işlem sırasında değişmiş görünüyordu. İşlem kaydında kullanıcı adı yerine genel bir hizmet tanımı vardı.

{yoldas:yalin|bir arkadaş} bu kelimeyi duyunca heyecanlandı. “Demek kimliğini gizleyen biri var.”

Aras, “Bir hizmet hesabı otomatik işlem yapıyor olabilir,” dedi. “Adı insan adı değil diye kötü niyetli olduğunu söyleyemeyiz.” Murat Bey onları destekledi. “Dijital sistemlerde bazı işlemleri programlar yapar. Ama programların hangi yetkiyle çalışacağına insanlar karar verir. Önce bu zinciri anlamalıyız.”

{kahraman}, “O zaman değişiklikleri sistem kendisi mi yaptı?” diye sordu.

“Muhtemel,” dedi Murat Bey. “Ancak hangi işlemin hangi veriyi değiştirdiğini henüz doğrulamadık.”

Aylin Hanım yanlış görünen kitapların listesini çıkardı. Bu liste yalnız kitap adları, kategori etiketleri ve raf işaretlerinden oluşuyordu. Öğrencilerin hangi kitabı ödünç aldığı veya hangi hesapla giriş yaptığı gibi kişisel bilgiler paylaşılmadı. {kahraman} ve {yoldas:yalin|bir arkadaş}, kitapları fiziksel olarak bulup raf bilgileriyle karşılaştırma görevini aldı. Aras da değişen etiketlerin hangi kurala göre benzerlik taşıyabileceğini inceleyecekti. Böylece araştırmaya yetkilerini aşmadan katkı verebiliyorlardı.
---
@omurga
Murat Bey'in hazırladığı özet tabloda geceleri yapılan birkaç otomatik işlem görünüyordu. {yoldas:yalin|bir arkadaş} saatlere dikkat etti. Değişikliklerin herkes evdeyken yapılması, ona kasıtlı bir davranış gibi gelmişti. Aras otomatik bakım işlerinin bazen kullanıcıların sistemi daha az kullandığı saatlerde çalıştırılabildiğini söyledi. Bu, gece yapılan her işlemin şüpheli olduğu anlamına gelmiyordu. Ancak yanlış sonuç ortaya çıkmışsa nedeninin araştırılması gerekiyordu. {kahraman}, saat bilgisinin tek başına bir kişi hakkında suçlayıcı sonuç üretmeye yetmeyeceğini not etti.

Çocuklar kitapların hatalı sınıflarını karşılaştırırken ilginç bir ayrıntı fark etti. Bazı kitaplar iki ayrı öneri listesinde doğru görünüyordu; resmî raf numarası ise değişmişti. Bu, birinin kitap adlarını rastgele değiştirmesinden farklı bir izlenim veriyordu. Aras, öneri alanlarıyla katalog alanları arasındaki ilişkinin yanlış kurulmuş olabileceğini düşündü. Yine de kesin konuşmadı. Aylin Hanım'a yalnız şu gözlemi ilettiler: Öneri etiketleri ile raf etiketleri bazı kayıtlarda birbirine karışmış görünüyor. Bu cümle bir çözüm değildi; uzman incelemesinin başlangıcıydı.
---
@omurga
{kahraman}, kitap etiketlerinin neden bu kadar farklı olduğunu anlamak için kütüphanedeki basılı sınıflandırma açıklamasını okudu. Bir kitabın konusu, türü ve raftaki yeri aynı bilgi değildi. Tür okura kitabın anlatım biçimi hakkında ipucu verirken konu birden fazla alanı kapsayabilirdi. Raf numarası ise kütüphanenin düzenine göre belirlenirdi. Bu ayrımı öğrenince, dijital tabloda yan yana duran sütunların yanlış eşlenmesinin neden büyük bir karışıklığa yol açabileceğini gördü. Yeni öğrendiği bilgiyi {yoldas:yonelme|bir arkadaşa} anlattı. {yoldas:yalin|bir arkadaş}, “Demek kod bazen iki farklı şeyi aynı şey sanabilir,” diye karşılık verdi. Aras onu düzeltti: “Kod kendi kendine bir şey sanmaz; nasıl tasarlandığına göre işlem yapar.”
---
@omurga
İlk bakışta yanlışlıklar rastgele görünüyordu. Bir bilim kurgu romanı masal, bir tarih kitabı genel bilgi, bir biyografi de öykü olarak işaretlenmişti. Fakat {kahraman} listede ortak bir özellik fark etti. Değişen kitapların çoğu geçen ay düzenlenen okuma etkinliğinde tanıtılmıştı. {yoldas:yalin|bir arkadaş}, “Demek etkinlikte bulunan biri yapmış,” dedi. {kahraman} bu sonucu aceleci buldu. “Aynı etkinlikte tanıtılmaları, değişikliğin nedeni olduğunu göstermiyor.”

Aylin Hanım kitap kulübünün öneri listesini açtı. Etkinliğe katılan öğrenciler, kitapları daha kolay bulmak için kendi seçtikleri ilgi alanı etiketleri hazırlamıştı. Uzay, gizem, eski zamanlar, hayal gücü gibi sözcükler vardı. Bu liste yalnız öneri amacı taşıyordu; kütüphanenin resmî sınıflandırmasını değiştirmemeliydi.

Aras, “Belki bu iki sistem birbiriyle karıştı,” dedi. Murat Bey, teknik kayıtları inceledikten sonra bunun araştırılmaya değer bir olasılık olduğunu söyledi. Yeni bir içerik aktarımı yapılmıştı ve bazı alanların eşleştirilmesi beklenenden farklı çalışmış olabilirdi. Ancak çocukların bunu doğrulamak için yönetici paneline girmesine gerek yoktu. Görevli ekip test ortamında kontroller yapacaktı.
---
@omurga
{yoldas:yalin|bir arkadaş} bu açıklamayı duyunca biraz hayal kırıklığı yaşadı. Gizli bir saldırganın peşine düşeceklerini düşünmüştü. {kahraman}, “Gerçek bir sorun çözmek, filmdeki gibi olması gerekmiyor,” dedi. “Önemli olan kitapları doğru yere geri getirmek.”

Okul gazetesinde kısa bir haber hazırlanacaktı. Öğrenci editör, başlığa “Kütüphaneye Gizli Saldırı” yazmayı önerdi. {kahraman} bunun doğrulanmadığını söyledi. Haber henüz yayımlanmadan öğretmenle görüşüldü. Başlık “Katalogda Etiket Karışıklığı” olarak değiştirildi; yazıda öğrencilerin kitap bulmak için kütüphane görevlilerinden yardım isteyebileceği açıklandı. Böylece okurlar hem doğru bilgi alacak hem de paniğe kapılmadan ne yapacaklarını bilecekti. {yoldas:yalin|bir arkadaş}, ilgi çekici başlığın her zaman en doğru başlık olmayabileceğini gördü.

Bu sırada kitap kulübü toplantısı geldi. Bazı öğrenciler öneri sistemine güvenemediği için yeni liste hazırlamak istemiyordu. {kahraman} basılı kitapları birlikte incelemeyi önerdi. İsteyenler kendi seçtikleri kitapları tanıttı; isteyenler kütüphane görevlisinin önerilerinden yararlandı. Böylece dijital sistem onarılana kadar okuma etkinliği sürdürülmüş oldu. Aras, teknolojinin yardımcı bir araç olduğunu, bütün öğrenme ve okuma isteğini tek başına taşımaması gerektiğini düşündü. Bir sistem aksadığında insanların birlikte oluşturduğu başka yollar da işe yarayabilirdi.
---
@omurga
{yoldas:ilgi|bir arkadaşın} dikkatini çeken bir başka mesele, hatadan en çok kimin etkilendiğiydi. Kütüphaneyi sık kullanan öğrenciler aradıkları kitapları yine bulabiliyordu. Ama okuma alışkanlığı henüz gelişen bazı çocuklar ilk yanlış sonuçta vazgeçiyordu. {kahraman}, yeni gelen öğrencilere yardımcı olacak kısa bir kütüphane rehberi hazırlamayı önerdi. Rehber, kategori etiketleri, raf işaretleri ve görevliye soru sorma yollarını anlatıyordu. Bu küçük çalışma sorunu çözmese de etkisini azaltmıştı. Murat Bey, teknik onarım sürerken kullanıcıların ihtiyaçlarını düşünmelerini değerli buldu.
---
@omurga
Sorun birkaç gün içinde öğrencilerin günlük hayatına da yansıdı. Beşinci sınıftan Deniz, öneri ekranında “bilim kurgu” seçtiğinde alakasız kitaplar görmeye başladı. Bir arkadaşı istediği kitabı bulamadığı için kütüphaneden eli boş döndü. Aylin Hanım kitapları elle kontrol ederek yardım ediyordu, fakat katalogdaki hata devam ettikçe öğrenciler sisteme güvenmekte zorlanıyordu.

{yoldas:yalin|bir arkadaş}, “Bütün katalog yanlış olabilir,” dedi. Aras, “Bunu bilmiyoruz,” diye karşılık verdi. Yalnız belirli kayıtlar etkilenmişti; sistemin tamamıyla ilgili genelleme yapmak gereksiz korku yaratabilirdi. {kahraman} öneri sayfasında geçici bir uyarı bulunmasını teklif etti: “Bazı kategori etiketlerinde düzeltme çalışması yapılıyor. Kitap bulmak için kütüphane görevlisinden yardım alabilirsiniz.” Aylin Hanım bu öneriyi okul yönetimine iletti. Uyarı hem dürüst hem de yol göstericiydi.

Bir öğle arasında {yoldas:ilgi|bir arkadaşın} sınıfından bir öğrenci, değişiklikleri kütüphane görevlilerinden birinin bilerek yaptığını ileri sürdü. Sosyal grupta “Kesin biri şaka yapıyor,” yazılı mesajlar dolaşmaya başladı. {kahraman} buna itiraz etti. “Buna dair kanıtımız yok,” dedi. “Birini suçlamak sistemi düzeltmez.” Murat Bey'e gidip söylentilerin büyüdüğünü anlattılar. Okul yönetimi kişileri hedef almayan kısa bir bilgilendirme yaptı: Sorun araştırılıyordu, öğrencilerden hesap bilgisi istenmeyecek, yetkisiz giriş denemeleri yapılmayacaktı.
---
@omurga
Aras bu açıklamanın önemli olduğunu düşündü. Çünkü bir hata karşısında insanların kendilerini korumak için hemen suçlu araması, asıl sorunun çözümünü geciktirebilirdi. Kütüphanede çalışan insanlar da öğrenciler kadar bu karışıklıktan etkileniyordu. Güven, yalnız sistemin doğru çalışmasına değil, hata olduğunda dürüstçe açıklama yapılmasına da bağlıydı.

Söylentiler büyürken sınıftan bazı öğrenciler hizmet hesabının arkasındaki insanın kim olduğunu bulabileceklerini iddia etti. {kahraman}, kimlik avının yanlış yöne gittiğini fark etti. Hesabın adı doğrudan bir kişiyi göstermiyordu. Bir arayüzde görünen belirsiz etikete bakıp bir çalışanı suçlamak haksızlık olabilirdi. Aras, yetkisiz kişilerin gerçek hesap kayıtlarını incelemesinin mahremiyet ihlali yaratabileceğini söyledi. Murat Bey de okulun ilgili kayıtlarını yalnız görev gereği erişmesi gereken yetkililerin değerlendireceğini açıkladı.

{yoldas:yalin|bir arkadaş}, bu açıklamadan sonra kendi merakını yönlendirecek bir soru buldu: Hangi bilgiler öğrencilerle güvenli biçimde paylaşılabilir? Murat Bey'den basitleştirilmiş bir örnek istedi. Bilişim sorumlusu kimlik bilgisi içermeyen bir tablo hazırladı. Tabloda yalnız işlem türleri, etkilenen alanlar ve test sonuçları yer alıyordu. {kahraman} bunu inceleyince sorunu anlamak için herkesin şifresini ya da kişisel geçmişini bilmeye ihtiyaç olmadığını gördü. Aras, sistemleri güvenli kılan ilkelerden birinin gerekli olandan fazla bilgiye erişmemek olduğunu söyledi.
---
@omurga
Aylin Hanım, kütüphane çalışanlarının da bu süreçte yorulduğunu anlattı. Her gün birçok öğrenci aynı soruyu soruyor, kimi zaman haksız suçlamalar duyuluyordu. {kahraman} bu nedenle kitap kulübünde kısa bir duyuru yaptı: “Sorun bildirmekten çekinmeyelim ama çalışanları hedef göstermeyelim.” Çocuklar yanlış kaydı fotoğraflamak yerine kitap adıyla raf bilgilerini görevliye iletme yolunu seçti. Böylece kullanıcıların ekranlarında kişisel bilgiler varsa gereksiz paylaşım yapma riskini de azaltmış oldular.
---
@omurga
{yoldas:yalin|bir arkadaş} bir akşam Aras'a mesaj gönderdi. “Bir arkadaşım, yönetici bağlantısını tahmin edebileceğimizi söyledi,” yazmıştı. Aras hemen cevap verdi: “Bunu denemeyeceğiz. İzin verilmemiş bir bölüme girmek sorunu çözmek değildir.” Ertesi gün konuşurken {yoldas:yalin|bir arkadaş} bunun neden bu kadar önemli olduğunu sordu. Aras, bir sistemin güvenliğinin yalnız iyi niyetle korunamayacağını anlattı. Hesapların kim tarafından, hangi görev için kullanıldığı belli olmalıydı. Bir öğrencinin merakı, başka öğrencilerin kayıtlarını açma yetkisi vermezdi.

{kahraman} de konuşmaya katıldı. “Ayrıca yanlış bir yere dokunursak verileri daha çok bozabiliriz,” dedi. {yoldas:yalin|bir arkadaş} içini çekti. “O zaman yalnız bekleyecek miyiz?” Aras başını salladı. “Hayır. Biz yanlış görünen kitapları belgeleyebilir, hangi işlemlerden sonra değiştiğini sorabilir ve çözümü test ederken yardımcı olabiliriz. Ama yetkili incelemeyi görevliler yapmalı.”

Bu konuşmadan sonra {yoldas:ilgi|bir arkadaşın} merakı azalmadı; yalnız yönü değişti. Yönetici şifresini bulmaya çalışmak yerine “Bir hata olduğunda nasıl güvenli rapor hazırlanır?” sorusunu araştırdı. Okulun bilişim sorumlusundan bir örnek istedi. Murat Bey gerçek kullanıcı bilgisi içermeyen bir deneme formu gösterdi: sorun tanımı, görülme zamanı, etkilenen işlev, yeniden gözlemleme adımları ve yapılan güvenli kontrol. {yoldas:yalin|bir arkadaş} bunları dikkatle inceledi. İyi bir hata bildirimi hazırlamak da teknik bir beceriydi.
---
@omurga
Teknik onarım sırasında Aras'ın aklına bir soru geldi. “Yetki ayarı düzeltildiğinde her şey kesinlikle güvenli olur mu?” Murat Bey bunun tek başına yeterli olmadığını anlattı. Her değişiklikten sonra sistemin beklendiği gibi çalıştığı doğrulanmalı, yeni sorunlar olup olmadığı izlenmeliydi. Ayrıca kullanım amacı değiştikçe yetkiler yeniden gözden geçirilebilirdi. Çocuklar bu yaklaşımın bir kere kapıyı kilitleyip işi bitirmekten farklı olduğunu anladı. Dijital güvenlik düzenli dikkat ve sorumluluk gerektiriyordu.

{kahraman}, düzeltme sürecini anlatan yeni bir çizelge hazırladı. İlk satırda yanlış etiketler, ikinci satırda uzman incelemesi, üçüncüde güvenli test, dördüncüde kullanıcı doğrulaması vardı. {yoldas:yalin|bir arkadaş} son satıra “Sorunu anlatmak” yazdı. Aylin Hanım bu başlığın önemli olduğunu söyledi. Çünkü kullanıcılar neden hata yaşadığını ve şimdi ne yapabileceğini bilmezse güvensizlik devam edebilirdi. Aras da tabloyu beğendi; teknik düzeltmenin insanlarla iletişimden ayrı olmadığını gösteriyordu.

Murat Bey, çocukların katkılarından birini özellikle vurguladı. Yanlış kaydı bulduklarında ekran görüntülerini herkese göndermemiş, kütüphaneciye düzenli bilgi vermişlerdi. Böylece sorun izlenebilir hâle gelirken gereksiz veri yayılması önlenmişti. {yoldas:yalin|bir arkadaş} artık izinsiz bir bağlantı arama fikrinin ne kadar yanlış olduğunu açıkça görüyordu. Merakını kaybetmemiş, yalnız daha sorumlu bir araştırma yolu öğrenmişti. Bu değişim onun gözünde bir başarıydı.
---
@omurga
Dördüncü gün Murat Bey inceleme sonucunu açıkladı. Kütüphane öneri sistemiyle resmî katalog arasında kurulan yeni bağlantı, bazı kategori alanlarını yanlış eşleştirmişti. İşlemi otomatik olarak çalışan bir hizmet hesabı gerçekleştirmişti. Ancak bu hesabın hangi alanları değiştirebileceğini belirleyen yetki ayarı fazla geniş tutulmuştu. Yanlış düzenleme bir öğrencinin gece gizlice sisteme girmesinden kaynaklanmıyordu.

{yoldas:yalin|bir arkadaş}, “Demek suçlu robot,” diye şaka yaptı. Murat Bey gülümsemedi. “Bir programı suçlamak kolay,” dedi. “Ama sistemi tasarlayan ve denetleyen insanlar olarak biz de sorumluluk almalıyız. Hataları düzeltmek ve bir daha yaşanmaması için gerekli kontrolleri yapmak bizim işimiz.”

Yönetici ekip yanlış yetki ayarını daralttı, etkilenen kayıtları doğrulanmış yedekten ve fiziksel katalogla karşılaştırarak düzeltti. Güncellemeler önce ayrı bir test ortamında denendi. Çocuklar teknik ayrıntıları yönetmedi; fakat kendilerine sunulan örnek kayıtların doğru görünüp görünmediğini kontrol etti. {kahraman}, daha önce “masal” olarak görünen bilim kurgu kitabının artık doğru kategoride olduğunu gördü. Birkaç başka kitapta da düzeltme yapılmıştı.
---
@omurga
Murat Bey, “Her şey düzeldi,” demek için acele etmedi. Önce farklı sınıflardan öğrencilerin kullandığı arama seçenekleriyle test yaptılar. Kitap adı, yazar, tür ve raf bilgisi ayrı ayrı kontrol edildi. Aylin Hanım fiziksel raflarla katalog arasındaki uyumu inceledi. Sadece ekranda güzel görünen bir sonuç yeterli değildi; öğrencilerin gerçekten kitabı bulabilmesi gerekiyordu.

Birkaç gün sonra yeni bir söylenti ortaya çıktı. Bazı öğrenciler “Katalogdaki bütün eski kayıtlar silinmiş,” diye konuşuyordu. Aras bunun doğru olup olmadığını merak etti ama yine de yönetici ekranına girmeyi düşünmedi. Murat Bey'den okulun kamuya açık bilgilendirmesini istedi. Orada etkilenen etiket alanlarının onarıldığı, kitap ödünç alma bilgilerinin bu hata kapsamında değişmediğinin doğrulandığı yazıyordu. Aras bu açıklamayı arkadaşlarıyla paylaştı. Yanlış bilgiyi durdurmak için çoğu zaman daha çok söylenti değil, doğru kaynağa yönlendirme gerekiyordu.
---
@omurga
{yoldas:yalin|bir arkadaş} ise bu olayın kendisinde bıraktığı etkiyi fark etti. İlk gün gizli bir kullanıcı bulma fikri ona heyecan vermişti. Şimdi aynı merakı daha iyi soru sormak için kullanıyordu. “Hangi bilgi değişti?”, “Nasıl fark edildi?”, “Kim doğruladı?”, “Düzeltme sonrasında ne test edildi?” sorularını bir deftere yazdı. Bunların cevapları hem güvenlik sınırlarını aşmadan öğrenilebiliyor hem de sorunun anlaşılmasına yardımcı oluyordu. {kahraman} ona bakıp gülümsedi. Merak duygusu, doğru yönlendirildiğinde insanları birbirinden şüphe etmeye değil, birlikte çözüm aramaya götürebilirdi.
---
@omurga
Sorun çözülünce Aras eski başlığı tekrar düşündü: Kayıp kodun ardındaki insan. Ortada kaybolmuş bir kod yoktu; yalnız yanlış çalıştığı için görünmez kalan bir karar vardı. Hizmet hesabı değişiklikleri yapmıştı ama bu hesabın yetkisini bir insan belirlemişti. Başka insanlar da sorunu fark etmiş, çözmüş, sonuçları test etmişti. “Demek kodun ardında tek bir kişi yok,” dedi. “Bir ekip var. Ve her kararın sonuçları başka insanları etkileyebiliyor.”

{kahraman}, sistemin yeniden güvenilir olması için yalnız teknik düzeltmenin yeterli olmadığını söyledi. Öğrencilere açık, anlaşılır bir açıklama yapılmalıydı. Aylin Hanım bu isteği kabul etti. Kütüphanenin duyuru panosuna kısa bir metin asıldı: “Bazı kitap etiketleri aktarım hatası nedeniyle yanlış görünmüştür. Kayıtlar kontrol edilerek düzeltilmiştir. Sorun bildiren öğrencilere teşekkür ederiz.” Kişisel veri veya gereksiz teknik ayrıntı paylaşılmadı.

{yoldas:yalin|bir arkadaş} duyuruyu okuduğunda başta hayal ettiği suçlu hikâyesinin yerini daha karmaşık ama daha anlamlı bir öykünün aldığını fark etti. Bir hata bazen kötü niyet olmadan da önemli sonuçlara yol açabilirdi. Sorumluluk, hatayı saklamak yerine düzeltmek ve tekrarını önlemekle ilgiliydi. Üstelik öğrenciler, hesaplara izinsiz girmeden de bu sürece katkı verebilmişti.
---
@omurga
Onarımın ardından okulun teknoloji kulübü küçük bir tartışma düzenledi: “Her otomatik karar doğru mudur?” Öğrencilerden biri, bilgisayarın hızlı çalıştığını ve bu yüzden insanlardan daha güvenilir olabileceğini savundu. Bir başkası yanlış veri verilirse hızlı biçimde yanlış sonuç üretilebileceğini söyledi. Aras ikisinin de bazı yönlerden haklı olduğunu düşündü. Hız, doğruluğun garantisi değildi; insan kontrolü de tek başına kusursuzluk sağlamıyordu. İyi sistemler açık görev tanımları, uygun yetki ve düzenli denetimle çalışırdı. Bu nedenle teknolojiye güvenmek, onu sorgulamadan kabul etmek anlamına gelmiyordu.

{kahraman} sınıfa kitap arama örneğini anlattı. “Bir öneri listesinde masal kelimesi görmek güzeldir,” dedi. “Ama raf numarasını değiştiriyorsa yanlış bilgiye dönüşebilir.”[[deyim:hr083_kafasina]] Çocuklar güldü. Aras hemen ekledi: “Zevki olmasa da aldığı talimatlar yanlışsa değiştirebilir.” Şaka bile onların yeni öğrendiği ayrımı görünür kılıyordu. Otomatik sistemin ne yaptığı, arkasındaki insan kararlarıyla bağlantılıydı.
---
@omurga
Okul kütüphanesinin yıl sonu etkinliğinde öğrenciler “Kitap bulmanın kaç yolu var?” adlı küçük bir oyun oynadı. Bir masada yalnız başlık, başka bir masada yalnız konu, üçüncüde kapak resmi bulunuyordu. Çocuklar kitapların yerini farklı ipuçlarından hareketle bulmaya çalıştı. {kahraman} bu oyunun eski katalog hatasıyla nasıl bağlantılı olduğunu anlattı. Bir kitabın farklı yönlerden tanınabilmesi güzeldi; ama bütün bu bilgilerin aynı alan olarak kaydedilmesi karışıklık doğurabilirdi. Her etiketin bir görevi vardı. Etiketler doğru bağlandığında kitaplar kolay bulunuyordu.

Aylin Hanım etkinlikten sonra {kahraman:yonelme} teşekkür etti. “Sadece hatayı görmediniz,” dedi. “Çocukların okuma isteğini de korumaya çalıştınız.” {kahraman} bu sözleri duyunca ilk gün elindeki kitabı bulamayan küçük öğrenciyi hatırladı. O gün kaybolan şeyin bir kod değil, biraz da güven olduğunu düşünmüştü. Şimdi o güvenin yeniden oluştuğunu görmek hoşuna gidiyordu. Aras, sistemdeki yeni kontrollerin düzenli sürdürülmesi gerektiğini hatırlattı. Hiç kimse teknolojiye bir daha hata yapmayacakmış gibi bakmıyordu; ama sorun çıktığında ne yapacaklarına dair daha iyi bir yöntemleri vardı.
---
@omurga
Okulun duyuru panosunda yeni bir bölüm açıldı: “Sorun gördüğünde ne yapabilirsin?” {kahraman}, bu başlığı hazırlarken öğrencilerin kişisel bilgilerini açıklamalarını isteyen hiçbir cümle bulunmamasına dikkat etti. Aras teknik şikâyetlerin hangi yetkiliye iletileceğini, Aylin Hanım ise yanlış yerleştirilmiş bir kitabı nasıl bildirebileceklerini yazdı. Beşinci sınıftan bir öğrenci “Ben bilgisayar bilmiyorum, yine de yardım edebilir miyim?” diye sordu. {kahraman} gülümsedi: “Elbette. Bir kitabı aradığın yerde bulamaman da önemli bir bilgi.” Sorunu fark etmek, yalnız uzmanların yapabileceği bir iş değildi.
---
@omurga
Bir hafta sonra kütüphane yeniden yoğunlaştı. Beşinci sınıftan Deniz, bilim kurgu rafında aradığı kitabı bulduğunda yüzü güldü. {kahraman} bu küçük anın neden önemli olduğunu anladı. Büyük bir teknoloji gizemi çözmüş gibi hissetmek güzeldi, ama asıl başarı insanların kitaplara yeniden güvenle ulaşabilmesiydi.

Aras bilişim kulübünde yaşananları anlattı. Arkadaşlarına güvenli hata bildirim formunu gösterdi. “Bir sorun gördüğünüzde bunu yetkili kişiye anlatmak, bazen gizli bir yol aramaktan daha yararlı,” dedi. {yoldas:yalin|bir arkadaş} arka sıradan seslendi: “Ayrıca ortada görünmeyen bir kişi var diye hemen şüpheli aramayın.” Sınıf gülümsedi.

{kahraman}, kütüphaneden çıkarken Aylin Hanım'ın masasına uğradı. “Bir daha böyle bir şey olursa bize haber verir misiniz?” diye sordu. Kütüphaneci başını salladı. “Elbette. Ama umarım daha iyi kontroller sayesinde daha az sorunla karşılaşırız.”

Koridordaki ekranda kitapların kapakları sıralanıyordu. {kahraman} artık o görüntülere başka gözle bakıyordu. Her doğru etiketin ardında yalnız birkaç satır yazılım değil; dikkatle verilmiş kararlar, denetimler ve sorumluluk vardı. Güvenilir bir dijital dünya, merak eden ama başkalarının sınırlarına saygı duyan insanlarla kurulabilirdi.
---
@omurga
Sorun çözüldükten sonra {kahraman} bir hafta boyunca kütüphaneyi izledi. Önceki günlerde her öğrenci ekrana güvensiz bakıyor, bazıları görevliye aynı soruyu tekrar tekrar soruyordu. Şimdi kitaplar doğru yerde göründükçe insanlar rahatlamaya başladı. Fakat iki öğrenci hâlâ dijital aramayı kullanmaktan çekiniyordu. {kahraman} onların neden tereddüt ettiğini sordu. “Ya yine yanlış çıkarsa?” dediler. {kahraman}, bir sistemin güvenini yeniden kazanmasının yalnız düzeltme duyurusuyla bitmediğini düşündü. Kullanıcılar tekrar tekrar doğru deneyim yaşadıkça kendilerini daha güvende hissedebilecekti.

Aylin Hanım bu görüşü dinleyince yeni bir yardım masası kurdu. İsteyen öğrenciler bir kitabı hem katalogda arıyor hem de rafta bulmayı öğreniyordu. Aras dijital aramanın nasıl çalıştığını teknik terimlere boğmadan anlattı; {yoldas:yalin|bir arkadaş} de ekrandaki tür ve konu etiketlerinin farklı görevlerini gösterdi. Küçük bir öğrenci aradığı kitabı bulduğunda “Ben yapabildim,” diye sevindi. {kahraman}, iyi bir sistemin yalnız doğru bilgi göstermesi değil, kullanıcıya kendi başına hareket etme güveni de vermesi gerektiğini fark etti.
---
@omurga
Bir süre sonra Murat Bey, öğrenci kulübünden gelen soruları topladı. Bazıları hata kayıtlarının nasıl tutulduğunu, bazıları yetki ayarlarının neden sınırlandırıldığını öğrenmek istiyordu. Bilişim sorumlusu gizli ayrıntılara girmeden genel ilkeleri anlattı. {kahraman} bu toplantıda en çok “görevi kadar yetki” düşüncesini sevdi. Bir kitabın öneri etiketini düzenlemekle bütün katalogun raf numaralarını değiştirmek aynı yetkiyi gerektirmiyordu. Bu ayrım, okulda yapılan işler için de anlaşılırdı: Bir kulüp afişi hazırlayan öğrencinin bütün okul duyurularını tek başına değiştirmesi beklenmezdi.

Bir sonraki kulüp toplantısında {yoldas:yalin|bir arkadaş}, arkadaşlarına kısa bir öykü yazdı. Öykünün kahramanı, her kitabı tek bir rafta görmek isteyen inatçı bir robot olacaktı. Robot, “Bir kitabın yalnız bir türü vardır,” diyerek her yeni etiketi siliyordu. Çocuklar hikâyeye gülüyordu ama {kahraman} küçük bir düzeltme önerdi: “Gerçek sistemde robotun kendi isteği yoktu. Hata, verilen görevlerin yanlış bağlanmasından çıkmıştı.” {yoldas:yalin|bir arkadaş} öyküyü iki bölüme ayırdı. İlk bölümde hayalî robotun komik hataları, ikinci bölümde ise gerçek katalog sorununun nasıl çözüldüğü anlatılacaktı. Böylece kurgu ile teknik açıklama karışmayacaktı.
---
@omurga
Aras da afişe büyük bir kilit simgesi çizdi. Ama kilidin altına “Herkese kapalı” yazmadı. Onun yerine “Doğru kişiye, doğru görev için erişim” cümlesini koydu. {kahraman} bu yaklaşımı beğendi. Kütüphane bilgisi öğrencilerin kitap bulabilmesi için görünür olmalıydı; özel kullanıcı kayıtlarıysa korunmalıydı. **Bir sistemin amacı bütün kapıları kapatmak değil, hangi kapının kim için ve neden açılacağını dikkatle belirlemekti**. Bu, dijital mahremiyet konusunda öğrendikleri en önemli düşüncelerden biriydi.

{kahraman} bir akşam eve giderken kendisine şu soruyu sordu: “Hiç kimsenin hata yapmadığı bir sistem kurmak mümkün mü?” Kesin cevap veremiyordu. Ama hataların fark edilip güvenli biçimde düzeltilebileceği bir sistem kurmanın mümkün olduğunu görmüştü. Okul kütüphanesi bunun küçük bir örneğiydi. Aras doğru bilgiyi yetkiliden istemiş, {yoldas:yalin|bir arkadaş} söylentilerin peşinden gitmek yerine hata bildirimini öğrenmiş, Aylin Hanım da öğrencilerin okuma alışkanlığını korumaya çalışmıştı. Hepsinin katkısı farklıydı. {kahraman} artık dijital güvenliği yalnız kod yazanların işi olarak görmüyordu; kullanıcıların bilinçli davranışları da güvenin bir parçasıydı.
---
@omurga
Bir başka sabah arama sistemi yine sorunsuz çalıştığında {kahraman} artık bunu sıradan bir durum olarak görmedi. Görünmeyen bu düzenin ardında pek çok insanın emeği vardı. O emek, kullanıcı istediği kitabı bulduğunda sessizce amacına ulaşıyordu. {kahraman} için gizemin asıl cevabı da buydu: Teknolojinin gerisinde unutulmaması gereken insanlar bulunuyordu.

{kahraman} defterinin sonuna bir cümle yazdı: Bir gizemin en iyi çözümü, mutlaka bir suçlu bulmak değildir. Bazen sorunun nedenini anlayıp insanların yeniden güvenmesini sağlamaktır. Sonra kütüphaneye dönüp bir kitap aldı. Kapağını açtığında bu kez hiçbir şifre aramıyordu. Yalnız iyi bir hikâye okumak istiyordu.
