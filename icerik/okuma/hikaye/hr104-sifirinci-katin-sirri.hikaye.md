---
baslik: "Sıfırıncı Katın Sırrı"
slug: "hr104-sifirinci-katin-sirri"
fis_kodu: "HR-104"
tur: gizem
konu: soylenti_kanit_etiket
sinif_alt: 8
sinif_ust: 8
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Asansörde 0 katı var mı? {kahraman} ile {yoldas:yalin|bir arkadaşı}, söylentiyi kanıttan ve yanlış etiketi gerçek bir kattan ayırmayı öğrenir."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 8
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [kesif, bilim_teknoloji]
  ders_baglantisi: [turkce, fen]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: soylenti_hr104, tur: lexeme, etiket: "söylenti", yuva: hr104_soylenti, islev: first_hint}
    - {id: lejand_hr104, tur: lexeme, etiket: "lejand", yuva: hr104_lejand, islev: application}
    - {id: tutarli_hr104, tur: lexeme, etiket: "tutarlı", yuva: hr104_tutarli, islev: application}
    - {id: kanit_hr104, tur: lexeme, etiket: "kanıt", yuva: hr104_kanit, islev: transfer}
    - {id: deyim_hr104, tur: idiom, etiket: "Omuz silkmek", yuva: hr104_omuz, islev: application}
    - {id: kavram_hr104, tur: concept, etiket: "Söylenti ile kanıtı ayırmak", islev: application}
  kanit_duzeyi: C
  program_surumu: "Önceki program (8. sınıf; geçiş dönemi, resmî program eşleştirmesi insan editörce yapılacak)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Asansörün ekranında hangi tuhaf sayı görünüyordu?", secenekler: [{id: A, metin: "-1"}, {id: B, metin: "G"}, {id: C, metin: "1"}, {id: D, metin: "0"}], dogru: D, aciklama: "Asansörün ekranında tuhaf bir sayı olarak 0 görünüyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 15, metin: "Yoldaşın bu benzetmesine göre sıfır ne anlama gelebilir?", secenekler: [{id: A, metin: "Kullanıldığı bağlama göre farklı anlamlar taşıyabilen bir işaret"}, {id: B, metin: "Her yerde aynı anlamı taşıyan kesin bir gizli kat"}, {id: C, metin: "Binanın kesinlikle var olmayan bir katı"}, {id: D, metin: "Yalnızca ziyaretçi için anlamı olan bir sayı"}], dogru: A, aciklama: "Sıfır, hangi plan ya da sistemde kullanıldığına göre farklı bir görev taşır."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 27, metin: "Mert Bey'in “Her kapalı kapı sır değildir” sözü ne anlatır?", secenekler: [{id: A, metin: "Kapalı her kapının bir sırrı vardır"}, {id: B, metin: "Kapalı bir kapı her zaman tehlikelidir"}, {id: C, metin: "Kapalı bir kapının her zaman bir gerekçesi olabilir; gizli bir sır olmak zorunda değildir"}, {id: D, metin: "Kapıların hiçbir zaman kapalı olmamalıdır"}], dogru: C, aciklama: "Kapalı bir alan güvenlik ya da işletme gerekçesiyle kapalı olabilir; bu, sır olduğu anlamına gelmez."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 15, metin: "Bu bağlamda “tutarlı” sözcüğü ne anlama gelir?", secenekler: [{id: A, metin: "Çok uzun ve ayrıntılı"}, {id: B, metin: "Birbiriyle çelişmeyen, uyumlu"}, {id: C, metin: "Yalnızca bir kişiye ait"}, {id: D, metin: "Hızlı değişen"}], dogru: B, aciklama: "Tutarlı isimler, plan boyunca aynı yer için çelişmeyen adlar kullanılması anlamına gelir."}
  - {id: s5, beceri: degerlendirme, dayanak_sayfa: 34, metin: "Kahramanın notuna göre bir yanlışı düzeltmek ne anlama gelmez?", secenekler: [{id: A, metin: "Bilgiyi güncellemek"}, {id: B, metin: "Kullanıcıyı doğru yönlendirmek"}, {id: C, metin: "Kaynağı yeniden kontrol etmek"}, {id: D, metin: "Geçmişte hiç yanılmadığını iddia etmek"}], dogru: D, aciklama: "Hatayı düzeltmek, önceki yanlışın kabul edilmesini gerektirir; yanılmadığını iddia etmek anlamına gelmez."}
deyim_cumleleri:
  hr104_omuz: "Bir öğrenci “Yine de orada bir şey saklıyor olabilirler,” dediğinde {kahraman} omuz silkti."
---
@omurga
Yeni bilim merkezindeki asansörün ekranında tuhaf bir sayı vardı: 0. Oysa binanın giriş katı zaten G olarak işaretlenmişti; üstünde 1, 2, 3 yazıyordu. Sekizinci sınıf öğrencisi {kahraman}, asansöre bindiğinde sıfıra basıp ne olacağını merak etti. Düğme yanmıyordu. Telefonundaki bina rehberinde ise “Kat 0 — erişim kısıtlı” yazısı görünüyordu.

Okul gezisinde öğrencilerin çoğu bunu önemsemedi. Ta ki biri kapalı bir merdiven kapısının yanında eski bir şema bulana kadar. Şemada asansör çizgisi G katının altına uzanıyor, en altta 0 etiketi duruyordu. Bir arkadaş “Burası gizli laboratuvar,” dedi. Bir başkası “Yasak deneyler yapılıyor olabilir,” diye ekledi. O akşam okul grubunda “Sıfırıncı Kat” başlığı altında onlarca mesaj dolaşıyordu.

{kahraman} söylentiyi ilgiyle okudu, sonra planın tarihine baktı. Köşesinde eski bir sürüm numarası vardı. Bilim merkezinin yöneticisi Aslı Hanım, çocukların sorularını duyunca planın eski bir taslak olabileceğini söyledi. “Ama izinsiz kapıları açmaya çalışmayın,” diye uyardı. “Bina içinde teknik alanlar bulunabilir. Güvenliğin nedenini anlamak için yetkili kişilere sorabilirsiniz.”
---
@omurga
{kahraman} ve arkadaşı {yoldas:yalin|bir arkadaş}, bu açıklamayla yetinmedi ama kuralları da bozmadı. Yönetimden görüşme izni aldılar. Asansörün sıfırıncı katı neden göstermediğini, uygulamanın neden orayı listelediğini ve eski planda hangi bölümün işaretlendiğini öğrenmek istiyorlardı. {yoldas:yalin|bir arkadaş} ayrıca “Gizem çözmek güzel, ama insanları korkutmak istemiyorum,” dedi. {kahraman} gülümsedi. “O zaman ilk iş korkutucu başlığı değiştirelim.”
---
@omurga
Bina görevlisi Mert Bey, görüşmeye üç farklı plan getirdi. İlki inşaat öncesi taslak, ikincisi kullanım izni alınmış son plan, üçüncüsü de ziyaretçi rehberiydi. {kahraman} bunların birbiriyle tamamen aynı olmadığını fark etti. Eski planda kat numaraları -1, 0, 1 diye sıralanmıştı. Yeni planda ziyaretçilerin kullandığı giriş katı G, üst katlar 1, 2, 3 olarak yazılıydı. Teknik alanlar ayrı bir kodla işaretlenmişti.

Mert Bey, “Bir binayı anlatmak için kullanılan kat numarası bazen farklı sistemlerde değişir,” dedi. “Mimari çizim, yazılım veri tabanı ve ziyaretçi tabelası aynı amaca hizmet etmez.” {kahraman}, “O zaman 0 gerçek bir kat değil mi?” diye sordu. Mert Bey kesin cevap vermedi. “Önce hangi sistemde 0 olarak tanımlandığına bakalım.”

{yoldas:yalin|bir arkadaş}, ziyaretçi uygulamasında asansör haritasının yanlışlıkla eski veriyle birleştirilmiş olabileceğini düşündü. Yönetici bu ihtimali teknik ekibe iletti. Yazılım uzmanı onları bekleyen soruları yanıtladı: İçerik yönetim sistemine yüklenen tabloda giriş katının eski kodu 0 olarak kalmıştı. Yeni etiket G olmuş, ancak bir harita alanındaki veri güncellenmemişti.
---
@omurga
{kahraman} rahatladı. “Demek gizli kat yok,” dedi. Uzman başını salladı. “Henüz bunu söylemek için erken. Bu, uygulamada neden 0 gördüğünüzü açıklıyor. Bina planındaki bütün teknik bölümleri değil.” {yoldas:yalin|bir arkadaş} bu ayrımı sevdi. Bir sorunun cevabı bütün soruları otomatik çözmüyordu.
---
@omurga
{kahraman} ve {yoldas:yalin|bir arkadaş} yönetimden ayrıldıktan sonra okulun matematik kulübüne uğradı. Ellerinde aynı binanın iki farklı kat planı vardı. Birinin üzerinde G, diğerinde 0 yazıyordu. Kulüp başkanı Duru, ikisini dikkatle inceledi. “Planları karşılaştırmadan önce ölçek ve yön işaretlerini kontrol edelim,” dedi. İlk plan kuzeyi yukarıda, ikinci plan ise giriş kapısı yukarıda olacak biçimde çizilmişti. Bunları fark etmeden sayfaları üst üste koymak, farklı koridorların aynı yerdeymiş gibi görünmesine yol açıyordu.

Duru, iki planı doğru yöne çevirip ortak noktaları eşleştirdi. Aynı merdiven boşluğu her ikisinde de duruyordu. Farklı görünen alanların bir bölümü çizim yönteminden kaynaklanıyordu. Bir bölüm ise binanın yapımı sırasında değiştirilmişti. {kahraman}, “Demek tek fark kat numarası değil,” dedi. {yoldas:yalin|bir arkadaş} güncellenmiş dosyaların tarihlerine baktı; eski taslakla yeni kullanıma açık plan arasında birkaç revizyon vardı.

Matematik kulübü bunu bir problem olarak çözmek istedi. Öğrencilerden biri iki plan arasındaki oranı hesapladı, biri de işaretlerin açıklamalarını yazdı. Ders kitabında öğrendikleri ölçek, koordinat ve yön kavramları bir anda gerçek bir mekânı anlamak için işe yarıyordu. {kahraman}, plan üzerindeki “M” harfinin gizli bir laboratuvar adı olduğunu düşünmüşken bunun mekanik tesisat işareti olduğunu öğrendiğinde kendi tahminine güldü.
---
@omurga
{yoldas:yalin|bir arkadaş}, “Bir sembolü bilmediğimizde aklımıza gelen ilk anlamı seçiyoruz,” dedi. Duru başını salladı. “Bu yüzden haritaların {kelime:hr104_lejand} vardır. Bilgi yalnızca çizgilerde değil, çizgilerin nasıl okunacağını anlatan kurallarda da saklıdır.” {kahraman} bu cümleyi telefonuna kaydetti.
---
@omurga
Bir ziyaretçi, eski uygulamayı kullanırken G yerine 0'a gitmek istediğinde hata mesajı aldığını anlattı. {kahraman} bunu duyunca “Belki bir güvenlik açığı var,” diye düşündü. {yoldas:yalin|bir arkadaş}, bir hata mesajının tek başına güvenlik açığı kanıtı olmayacağını söyledi. İkili ziyaretçinin karşılaştığı ekranı yeniden üretmek için yetkili teknik ekibin deneme hesabını kullandı. Başka kullanıcıların özel verilerine erişmeye çalışmadılar.

Ekranda “Bu kata erişim yetkiniz yok” yazıyordu. Teknik uzman, bu metnin eski sistemden kalmış genel bir hata mesajı olduğunu açıkladı. Asıl neden bulunamayan bir kat kimliğiydi. Mesaj teknik olarak hatalıydı ve kullanıcıyı yanlış yönlendiriyordu. {yoldas:yalin|bir arkadaş}, “O zaman insanlar gizli kat söylentisini bu mesajdan da çıkarmış olabilir,” dedi. Uzman, mesajı “Bu kat mevcut ziyaretçi planında bulunmuyor” şeklinde değiştirdi.

{kahraman} bir anda kullanıcı arayüzlerinin nasıl güçlü bir etki yaratabildiğini anladı. Kırmızı bir kilit simgesi, gerçek bir tehlike olmasa bile kullanıcıda yasak veya gizem duygusu uyandırıyordu. Teknik ekip simgenin doğru olup olmadığını yeniden değerlendirdi. Bazen küçük bir ikon, uzun bir açıklamadan daha çok şey söylüyordu; bu yüzden onu yanlış bağlama koymak da bir bilgi hatasıydı.
---
@omurga
Öğretmenleri öğrencilere iki taslak ekran gösterdi. Birinde büyük kırmızı bir ünlem vardı; diğerinde açık mavi bir bilgi işareti ve kısa açıklama bulunuyordu. Hangi taslağın daha anlaşılır olduğunu tartıştılar. {yoldas:yalin|bir arkadaş}, kullanıcıyı korkutmadan doğru yönlendiren açıklamayı savundu. {kahraman} da bir hata mesajının yalnızca sorunun varlığını değil, kullanıcının ne yapabileceğini de anlatması gerektiğini söyledi.
---
@omurga
Ertesi gün okulda, kat hakkındaki hikâyeler büyümüştü. Biri sıfırıncı kattan gece mavi ışık geldiğini söylüyordu. Başka biri, asansörün gizlice oraya indiğine dair bir video paylaşmıştı. {kahraman} videoyu açtı. Ekranda asansörün -1 düğmesi yanıyor, ardından kapı açılıyordu. Altına “0'a iniş” yazılmıştı. {yoldas:yalin|bir arkadaş}, “Videonun başlığındaki iddia ile görüntüdeki sayı aynı değil,” dedi.

İkili videonun kaynağını araştırdı. Başka bir binadan çekildiği anlaşılınca bunu arkadaşlarına anlattı. Ama birkaç kişi videoyu paylaşmayı sürdürdü. “Eğlenceli,” diyorlardı. {yoldas:yalin|bir arkadaş}, eğlenceyle yanlış bilginin birbirine karışabileceğini fark etti. İnsanlar gerçek bir mekânda bulunmayan şeyleri varmış gibi gösterebiliyordu. Bir {kelime:hr104_soylenti} tekrar etmek, onu doğruya dönüştürmüyordu.

Öğretmenleri çocuklara küçük bir etkinlik hazırladı: İlk öğrenciye “Asansörün yazılımında eski kat kodu var” cümlesini söyledi. Cümle sırayla aktarıldığında en son öğrenci “Bina gizli laboratuvar saklıyor” diye duyduğunu anlattı. Sınıf güldü. Öğretmen, “Gördünüz mü, yalnızca birkaç ağızdan geçince bile bilgi değişebiliyor,” dedi. “Bu yüzden kaynağına dönmek önemlidir.”
---
@omurga
{kahraman}, söylenti zincirini tahtaya çizdi. İlk cümle bir veri hatasıydı; sonraki cümlelerde varsayım, abartı ve korku eklenmişti. {yoldas:yalin|bir arkadaş} yanına şu notu yazdı: Bir şeyin mümkün olması, gerçekleştiğini göstermez.
---
@omurga
Cuma sabahı okul grubuna yeni bir görüntü düştü. Bodrum koridorundaki metal kapının üstünde kırmızı bir uyarı levhası vardı. Görüntüyü paylaşan kişi altına “Artık kesin: Sıfırıncı kat var” yazmıştı. Birkaç öğrenci korku filmi afişi hazırlamaya başladı. {kahraman} ise levhanın sağ alt köşesinde küçük bir yapıştırıcı izi fark etti. Resim kırpılmıştı; yazının tamamı görünmüyordu.

Arkadaşı {yoldas:yalin|bir arkadaş}, “Bundan gizli laboratuvar sonucu çıkaramayız,” dedi. “Belki elektrik odasıdır.”

“Belki,” dedi {kahraman}, “ama şimdi biz de tahmin yürütüyoruz.”

Görüntüyü gönderen öğrenciye kaynağını sordular. Öğrenci onu başka bir gruptan almıştı. Grubun yöneticisi fotoğrafı bir ziyaretçinin hesabında görmüştü. Sonunda görüntünün iki yıl önce aynı binada yapılan tadilat sırasında çekildiği anlaşıldı. Levhanın tam hâlinde Yetkisiz giriş tehlikelidir — teknik servis yazıyordu. Yeni binada birçok teknik servis odası bulunması doğaldı; fotoğraf, bu odanın hangi katta olduğuna bile kanıt oluşturmuyordu.

{kahraman} önce bütün gruba “Sahte fotoğraf” yazmayı düşündü. Sonra vazgeçti. Fotoğrafın kendisi gerçekti. Yanlış olan, bağlamı koparılmış fotoğrafa yüklenen anlamdı. {yoldas:yalin|bir arkadaş} ile birlikte görüntünün kaynak zincirini ve eksik kalan kadrajı gösteren kısa bir açıklama hazırladılar. Yorumlarda kimseyi küçük düşürmediler; herkesin aynı hatayı yapabileceğini biliyorlardı.
---
@omurga
Ne var ki ertesi gün başka bir sorun çıktı. Okuldan iki öğrenci, kapının bulunduğu tahmini yeri bulmak için bilim merkezindeki koridorları dolaşmış, görevlinin yönlendirmesini dinlememişti. Kimseye zarar gelmemişti ama görevli ziyaretçilerin teknik bölümlere yaklaşmasının risk oluşturabileceğini anlattı. {kahraman} bu haberi duyunca rahatsız oldu. “Biz bir sayının ne olduğunu merak ettik,” dedi. “Başkaları bu merakı tehlikeli bir oyuna çevirdi.”

{yoldas:yalin|bir arkadaş}, araştırmalarına yeni bir kural koymayı önerdi: Merakın bedeli başkasının güvenliğine yüklenmemeliydi. {kahraman} kabul etti. Soracakları sorular için randevu alacak, ziyaretçilere açık olmayan yerlere yönelmeyeceklerdi.
---
@omurga
Cumartesi günkü bilim etkinliğinde asıl sorunun neden önemli olduğunu gördüler. {yoldas:ilgi|bir arkadaşın} teyzesi, işitme cihazı kullanan ve kalabalıkta sesli anonsları kolay takip edemeyen bir ziyaretçiydi. Atölyeyi bulmak için telefonundaki rehberi açtı. Rehber “G katı” diyordu; koridor levhasındaki eski işaret ise “0.” {yoldas:ilgi|bir arkadaşın} teyzesi bir süre yanlış koridorda yürüdü. Görevli onu fark edip doğru yere yönlendirdi.

“Böyle küçük karışıklıklar beni daha çok yoruyor,” dedi teyzesi. “Herkes yardım edebilir sanılıyor ama her zaman bir görevliyi kolayca bulamayabilirim.”

{kahraman} gizli laboratuvar söylentisini ilk kez bütünüyle unuttu. Aynı bilgi hatası, birileri için heyecanlı bir oyun, birileri için gerçek bir erişim sorunu olabiliyordu. {yoldas:yalin|bir arkadaş} çantasından defterini çıkardı. Yönlendirmelerin görsel açıklık taşıması, sesli duyuruların tek iletişim yolu olmaması ve uygulamada aynı kat adlarının kullanılması gerektiğini not aldı.

“Bizim önerimiz yeterli mi?” diye sordu {kahraman}.

“Teyzeme soralım,” dedi {yoldas:yalin|bir arkadaş}. “Kendi deneyimimiz herkesin deneyimi değil.”
---
@omurga
Teyzesi onların hazırladığı ilk yön tabelasına baktı. Ok işaretini kolay gördü, ancak küçük yazılmış bölüm adlarını okumakta güçlük çekebilecek kişiler bulunduğunu hatırlattı. {yoldas:yalin|bir arkadaş} büyüklüğü artırdı. {kahraman}, harita üzerindeki tek renkli gösterimin anlaşılması için farklı simgeler de ekledi. Birkaç ziyaretçinin düşüncesini daha dinlediler. Herkesin önerisi aynı değildi; bazıları daha kısa metin, bazıları ayrıntılı açıklama istiyordu. Öğrenciler iki gereksinimi bir arada düşünmeye çalıştı.

O gün {kahraman} defterine “Gerçek soru: Kullanıcı nereye gitmek istiyor?” yazdı. Başına büyük harflerle “0 NEREDE?” yazdığı eski sayfayla karşılaştırınca aralarındaki farkı gördü. İlk soru binanın gizemini çözmek istiyordu; ikincisi insanların binayı güvenle kullanmasını.
---
@omurga
Ertesi hafta Mert Bey, mimari çizimlerle ilgili kısa bir atölye düzenledi. Çocuklara aynı binanın üç planını verdi. Birincisi ilk tasarımın kesit çizimiydi; ikincisi inşaatın tamamlanmasından sonraki teknik kayıt; üçüncüsü ziyaretçilerin kullandığı kat haritasıydı. Üçünde de farklı işaretler vardı.

{kahraman} ilk plana bakıp “Burada sıfır, zeminin altını gösteriyor,” dedi. Mert Bey gülümsedi. “Dikkatli ol. Bunun burada neyi temsil ettiğini önce lejandan okuyalım.”

Lejand incelendiğinde sıfırın bir ölçüm düzeyine ait işaret olduğu görüldü. Teknik çizimdeki başka bir sıfır ise belli bir düzenin başlangıç noktasını ifade ediyordu. Uygulama veritabanındaki sıfırınsa ziyaretçi için anlamı olmayan bir kayıt kimliği olduğu sonradan anlaşılacaktı. Aynı sayı üç farklı bağlamda üç farklı görev üstleniyordu.

{yoldas:yalin|bir arkadaş} yan yana dizilmiş planlara baktı. “Bir sözcüğün farklı metinlerde farklı anlam taşıması gibi,” dedi. “Sıfır tek başına ‘gizli kat’ demiyor.”

Mert Bey çocukların önüne boş bir kart koydu. “Bir mimarın çizimini bir yazılımcı kullanacaksa neye ihtiyaç duyar?” diye sordu. {kahraman} “Açıklama” dedi. {yoldas:yalin|bir arkadaş} “Birbiriyle {kelime:hr104_tutarli} isimler” diye ekledi. Mert Bey ikisini de yazdı. Ardından üçüncü bir madde istedi. Bir süre sustular.
---
@omurga
“Değişiklik kaydı,” dedi {yoldas:yalin|bir arkadaş} sonunda. “Plan yenilendiğinde eski bilgi neden ve ne zaman değişti, bunu görmeliyiz.”

Bu cevap {kahraman:ilgi} aklına okulun eski bina krokisini getirdi. Sınıflardan biri geçen yıl yer değiştirmiş, ancak panodaki yönlendirme güncellenmemişti. Yanlış bilgi yalnızca dijital sistemlerde oluşmuyordu. Her gösterimin, bir gün onu kullanacak başka bir insana açıklanabilmesi gerekiyordu.
---
@omurga
Söylentinin okul içinde nasıl yayıldığını anlamak için küçük bir etkinlik planladılar. Öğretmenlerinden izin alarak gerçek öğrenci isimlerini kullanmadan, “Sıfırıncı katta gizli bir oda var” cümlesini sekiz kişilik örnek bir aktarım zincirinde denediler. Her öğrenci duyduğunu bir sonrakine aktardı; kimse söyleneni kasıtlı olarak değiştirmeyecekti.

Son kişiye ulaşan cümle şuydu: “Merkezin altında kimsenin bilmediği bir laboratuvar saklanıyor.” {kahraman} iki ifadeyi yan yana yazdı. İlk cümlenin kanıtsız olduğu açıktı, ancak son cümlede eminlik tonu daha da artmıştı. Üstelik “kimsenin bilmediği” sözleri, insanların neyin kanıt sayılacağını sormasını güçleştiriyordu. Her itiraz, hikâyeyi anlatanlarca “Zaten saklıyorlar” diye karşılanabilirdi.

{yoldas:yalin|bir arkadaş} etkinliğin bir hatasını fark etti. “Bu, herkesin söylentiyi mutlaka büyüttüğünü kanıtlamaz,” dedi. “Biz yalnızca küçük bir örnek yaptık.”

Öğretmenleri başını salladı. “Doğru. Sınıf deneyinin sınırını bilmeniz önemli. İnsanlar bazı durumlarda bilgiyi düzeltir, bazen değiştirir, bazen de olduğu gibi aktarır.”
---
@omurga
{kahraman} bu kez iki farklı duyuru hazırladı. Birincisinde yalnızca söylentinin yanlış olduğunu söylüyordu. İkincisinde hangi planın ne zaman hazırlandığını, fotoğrafın nereden geldiğini ve yönetimin hangi açıklamayı yaptığını kısa bağlantılarla gösteriyordu. Arkadaşlarına hangisini daha ikna edici bulduklarını sordu. Çoğu ikinci duyuruyu seçti; çünkü yalnızca “Bize inanın” demiyordu, kendilerinin de kontrol edebileceği izler bırakıyordu.

Etkinlik sonunda {kahraman} gruba bir özür yazdı. İlk günlerde gizemi eğlenceli bulduğu için belirsiz ifadeler kullandığını kabul etti. Bazı arkadaşları ona gereksiz yere özür dilediğini söyledi. {kahraman}, “Bence merak etmekte sorun yoktu,” dedi. “Sorun, merakımı bir iddia gibi paylaşmamdı.” Bu ayrım, onun için gizli katın bulunmasından daha önemli hâle gelmişti.
---
@omurga
Söylentinin yanlış olduğuna dair duyuru yayımlandıktan sonra bile okulun duvar gazetesinde sıfırıncı kat hakkında çizilmiş bir karikatür asılı kaldı. Resimde uzaylılar asansöre binmeye çalışıyor, kapıda ise “Giren Geri Dönemez” yazıyordu. {yoldas:yalin|bir arkadaş} ilk bakışta güldü; sonra karikatürün altına gerçek bir öğrenci adı yazıldığını gördü. Adı geçen çocuk, gezinin ilk günü yanlışlıkla teknik koridora yönelen öğrenciydi. Birkaç kişi onu “gizli laboratuvarı bulan kahraman” diye çağırıyor, birkaç kişi de beceriksizlikle suçluyordu.

{kahraman} karikatürü hazırlayan arkadaşına konuşmayı önerdi. “Bu bir şaka,” diye karşılık aldı. {kahraman} başını salladı. “Şaka olabilir. Ama adını yazdığın kişi bunu istemediğini söylüyorsa başka bir şey düşünmeliyiz.” Gazeteyi hazırlayan grup önce itiraz etti, sonra karikatürü isimsiz yayımlamaya karar verdi. Bu küçük tartışma, söylentilerin yalnızca binaları değil, insanları da yanlış bir hikâyenin içine yerleştirebildiğini gösterdi.

O gün okul çıkışında söz konusu öğrenci {kahraman:yonelme} teşekkür etti. “Ben korktum çünkü kapıda elektrik uyarısı vardı,” dedi. “Birileri bana cesur, birileri korkak dedi. Oysa yalnızca yanlış yere gittiğimi anlayıp geri döndüm.” {kahraman}, bu cümleyi araştırma raporuna yazıp yazamayacağını sordu. Arkadaşı yalnızca ismi kullanılmayacaksa izin verdi. {kahraman} kabul etti. Kanıt toplamak, insanların hikâyelerini izinsiz sahiplenmek anlamına gelmemeliydi.
---
@omurga
Araştırmanın sonunda {kahraman}, {yoldas:yalin|bir arkadaş} ve Aslı Hanım üç ayrı toplantı yaptı. İlk toplantıda binanın teknik ekibi vardı. Onlara planların hangi aşamada değiştiğini ve veri etiketinin nereden geldiğini sordular. İkinci toplantıda ziyaretçiler yer alıyordu. Onlara gizli katı değil, yön bulurken nerelerde zorlandıklarını sordular. Üçüncü toplantı öğrencilerleydi. Onlara da söylentiyi hangi bilgiye dayanarak paylaştıklarını sordular.

Cevaplar birbirinden farklıydı. Teknik ekibin sorunu kayıtların uyumsuzluğuydu. Ziyaretçilerin sorunu aynı yer için farklı adlar kullanılmasıydı. Öğrencilerin sorunu ise eğlenceli bir açıklamayı doğrulamadan yaymaktı. {kahraman} bu üç cevabın hangisinin en önemli olduğunu seçmeye çalıştı. {yoldas:yalin|bir arkadaş} “Belki de hepsi farklı sorulara cevap,” dedi. “Tek bir doğru cevabı ararken aynı yerde yaşayan insanların başka sorunlarını görmüyoruz.”

Toplantıların notlarını bir sayfaya sığdırmaları gerekiyordu. {kahraman} ilk taslakta teknik terimleri uzun uzun anlattı. {yoldas:yalin|bir arkadaş} bunun bir binayı kullanmaya çalışan ziyaretçiye pek yardımcı olmayacağını söyledi. İkinci taslakta {kahraman} bütün ayrıntıları çıkardı. Bu kez açıklama o kadar kısaldı ki “hata düzeltildi” dışında hiçbir şey söylemiyordu. Üçüncü taslağı birlikte hazırladılar: “Eski teknik kod, ziyaretçi ekranında yanlış görünüyordu. Yeni yönlendirmeler güncellendi. Sorun yaşarsanız danışmaya başvurabilirsiniz.” Altına ayrıntılı inceleme bağlantısı eklediler.
---
@omurga
“Demek uzun bilgiyle anlaşılır bilgi aynı şey değil,” dedi {kahraman}. {yoldas:yalin|bir arkadaş} gülerek “Ama ayrıntıya ihtiyacı olan da bulabilmeli,” diye tamamladı. Daha sonra raporu okul panosuna asıp öğretmenlerinden geri bildirim aldılar. Bir öğretmen, kapalı teknik alanların giriş yerlerinin açıkça paylaşılmaması gerektiğini hatırlattı. {yoldas:yalin|bir arkadaş} yön çizimlerinde bu ayrıntıyı çıkardı. Bilgiyi açık anlatmakla güvenliği ihmal etmek arasında bir tercih yapmak zorunda değillerdi; her ikisini de koruyan bir yol bulunabilirdi.
---
@omurga
İki hafta sonra bilim merkezinden küçük bir teşekkür mektubu geldi. İçinde öğrencilerin yaptığı kullanıcı testiyle ilgili bir değerlendirme vardı. Yeni tabelalarla yön bulma süresi bazı denemelerde kısalmıştı; ancak merkez bunun her ziyaretçi için aynı sonucu vereceğini iddia etmiyordu. Farklı yaş grupları ve erişim ihtiyaçları için yeni testler planlanmıştı.

{kahraman} mektubu görünce okul grubuna hemen “Sorunu çözdük!” yazmak istedi. Sonra cümlesini değiştirdi: “Sorunun bir bölümünün çözümüne katkı verdik; merkez testlere devam ediyor.” {yoldas:yalin|bir arkadaş} metni okuyup onayladı. Daha az görkemliydi ama daha doğruydu. {kahraman} bunun bir kayıp olmadığını düşünüyordu. Gizli bir laboratuvar bulamamışlardı. Fakat herkesin gördüğü bir ekranın arkasında görünmeyen bir yanlışlığı ortaya çıkarmış, insanların işini kolaylaştırmışlardı.

Evine dönerken asansör yerine merdiveni kullandı. Basamakları saymadı. Koridordaki yeni levhayı okudu; sonra ilk gün hiç dikkat etmediği çıkış yönünü gösteren oku fark etti. Bir yapının iyi anlaşılması için yalnızca gizli yerlerinin değil, en sıradan işaretlerinin de doğru olması gerekiyordu. Bu kez bir sayıdan korkutucu bir hikâye çıkarmak yerine, yanlış anlaşılmayacak bir hikâye anlatabildikleri için sevindi.
---
@omurga
Bilim merkezi yöneticisi Aslı Hanım, meraklı öğrencilerin soruları için küçük bir bilgilendirme düzenledi. Binada ziyaretçilere açık olmayan bölümlerin bulunduğunu, bunların bakım, depolama ve teknik işleyiş için gerekli olabileceğini anlattı. Çocukların istediği her yeri gezemeyeceğini açıkça söyledi, ancak bu durumun kendisinin gizemli bir amaç taşıdığı anlamına gelmediğini de belirtti.

{kahraman}, “Bir yerin kapalı olması bizi neden bu kadar meraklandırıyor?” diye sordu. Aslı Hanım bunun yalnızca teknolojiyle ilgili olmadığını, insanların eksik bilgiyi bazen kendi beklentileriyle doldurduğunu anlattı. Bir kapıda sebep açıklanmamışsa söylentiler kolayca çoğalabiliyordu. Yönetim, güvenliği tehlikeye atmadan daha anlaşılır işaretler kullanabilirdi. “Teknik alan — görevli dışında giriş yok” yazısı bazı belirsizlikleri azaltıyordu.

Bu bilgilendirme sırasında bir veli, binanın erişilebilirlik düzenini sordu. Asansörün gerçekten hangi katlara çıktığı, acil durumlarda hangi yönlendirmelerin kullanılacağı ve farklı kullanıcıların işaretleri kolay okuyup okuyamadığı önemliydi. Öğrenciler, gizli kat söylentisini araştırırken daha gerçek bir ihtiyaçla karşılaştı: Kullanıcıların binada yön bulma güveni.
---
@omurga
{yoldas:yalin|bir arkadaş} bu konuyu proje dosyasına ekledi. Teknik uzmanlarla birlikte yön tabelalarının okunabilirliğini ve asansör düğmelerinin açıklığını incelediler. Uzmanların belirlediği güvenlik kurallarını değiştirmediler; yalnızca kullanıcı deneyimini değerlendirdiler. Bir öğrencinin G harfini anlamakta zorlandığını fark ettiler. Yeni tabelaya “Giriş katı (G)” ifadesi eklendi.

{kahraman} o akşam arkadaş grubuna kısa bir mesaj yazdı: “Sıfırıncı kat söylentisi, aslında binanın yön bulma tasarımındaki bazı açıklık sorunlarını fark etmemize yardım etti.” Arkadaşlarından biri “Bu kadar sıkıcı bir sonuç olur mu?” diye cevap verdi. {kahraman} güldü. “Gerçek çözüm bazen gizli kapıdan daha işe yarıyor.”
---
@omurga
Sergi görevlilerinden biri, ziyaretçilerin hiç görmediği hazırlık sürecini anlattı. Bir bina açılmadan önce farklı ekipler güvenlik denetimleri yapar, işaretleri düzenler, erişim kurallarını belirlerdi. {kahraman}, asansör panelinde gördüğü küçük sayının ardında bu kadar çok kişinin çalıştığını düşünmemişti. Hatalar bazen büyük bir gizemin değil, karmaşık işlerin arasında güncellenmesi unutulmuş bir bilginin sonucuydu.

Teknik ekipten bir çalışan, eski planın nasıl yanlışlıkla uygulamada kaldığını anlattı. Binanın teslim sürecinde bir dosya adı değiştirilmiş, başka dosya yeni sürüm sanılmıştı. Bu olay kimseyi suçlama fırsatı olarak görülmemişti; ekip süreci tekrar incelemiş ve daha açık sürüm takibi kuralları oluşturmuştu. {yoldas:yalin|bir arkadaş} bir veri kaydının doğru kaynağa bağlı olması gerektiğini not etti.

İki öğrenci okulun bilgisayar kulübünde bu olayı küçük bir çalışma olarak sundu. Her dosyaya sürüm numarası koymanın, tarih yazmanın ve değişiklikleri açıklamanın neden önemli olduğunu anlattılar. {kahraman}, “Dosya adı benziyor diye içerik aynı olmayabilir,” dedi. Bu söz sınıfta sıkça yaşanan bir sorunu hatırlattı: Ödevin eski sürümünü göndermek veya güncel notların yerine yanlış dosyayı açmak.
---
@omurga
{yoldas:yalin|bir arkadaş}, bu küçük hata ile büyük bir söylentinin nasıl birleştiğini gösteren bir akış çizdi. Birinci adım eski veri, ikinci adım belirsiz arayüz mesajı, üçüncü adım yanlış video başlığı, dördüncü adım paylaşılan söylentiydi. Son adımda ise kaynak doğrulama, teknik düzeltme ve bilgilendirme vardı. Öğrenciler akışın ortasına bir soru yerleştirdi: Hangi aşamada daha iyi bir açıklama yapılsaydı söylenti büyümezdi?
---
@omurga
Bina yöneticisi, çocukların merakı üzerine mimari planların kamuya açık bölümlerini anlatan bir oturum düzenledi. Mert Bey, teknik alanların her ziyaretçiye açık olmayabileceğini, bunun genellikle güvenlik ve işletme gerekçeleri taşıdığını belirtti. {kahraman} “Ama sır varsa nasıl bileceğiz?” diye sordu. Mert Bey güldü. “Her kapalı kapı sır değildir. Bazı kapıların neden kapalı olduğunu anlamak için yetkili bilgiye başvururuz.”

{yoldas:yalin|bir arkadaş}, planda görülen küçük boşluğa işaret etti. “Peki bu alan neden yazısız?” Mert Bey, planın bir kısmının ölçek yüzünden kısa kodlarla gösterildiğini anlattı. Çocuklar lejandı bulunca bazı harflerin elektrik tesisatı, mekanik bölümler ve servis geçişleri için kullanıldığını gördü. İlk başta boş sanılan bölüm, başka sayfada ayrıntılandırılmıştı.

{kahraman} bu küçük keşfe sevindi. “Lejandı okumadan haritayı anlayamayız,” dedi. {yoldas:yalin|bir arkadaş} de “Bir kelimenin sözlük anlamına bakmadan cümleyi yorumlamak gibi,” diye ekledi. Öğretmenleri bu benzetmeyi beğendi. Harita ve metin, ortak bir anlam kurmak için semboller kullanıyordu. Sembollerin açıklamalarını görmezden gelmek kolayca yanlış sonuca yol açabilirdi.
---
@omurga
Teknik ekip, uygulamanın eski kat kodunu bulduğunda bunun kaynağı tek bir satırdı. Veritabanında “floor_id: 0” yazıyor, ziyaretçi arayüzünde ise “floor_label: G” görünmesi gerekiyordu. Fakat eski bir sayfa bu iki alanı karıştırıyordu. {kahraman} kodu görünce “Bu kadar küçük bir hata mı?” dedi.

Uzman, küçük bir etiket hatasının kullanıcıları yanlış yönlendirebileceğini anlattı. Bir katın adı yanlış görünürse bir kişi aradığı yeri bulamayabilir; güvenlik açısından önemli bilgiler de yanlış yorumlanabilirdi. Bu yüzden düzeltmeyi yalnızca ekrandaki sayıyı silerek yapmadılar. Verinin kaynağını, kullanıcı akışını ve erişim izinlerini test ettiler.

{yoldas:yalin|bir arkadaş}, bu testleri izlerken yazılımın görünmeyen kurallarını düşündü. Bir uygulama hızlı ve güzel görünebilir, ama arkasındaki eski kayıtlar güncellenmediyse yanlış bilgi verebilirdi. Kullanıcının gördüğü sayı ile sistemin kullandığı kimlik kodu aynı şey değildi. “Demek ekranda görünen her bilgi doğrudan gerçeğin kendisi değil,” dedi.

Yeni sürüm yayımlandığında “Kat 0” yazısı kayboldu. Yerine doğru ziyaretçi katları geldi. Ancak {kahraman} ve {yoldas:ilgi|bir arkadaşın} merakı hâlâ canlıydı. Eski plandaki bütün bölümlerin neye karşılık geldiğini öğrenmek istiyorlardı. Mert Bey onları bir kez daha plana yönlendirdi. “Gizemi çözmenin en iyi yolu, yeni bir efsane uydurmadan soru sormaya devam etmek,” dedi.
---
@omurga
Serginin hazırlık günü {kahraman}, kapıdaki yeni yön levhalarını izlerken küçük bir ayrıntı fark etti. Levhaların altında açıklama vardı, fakat harfler camın parlaması yüzünden kapıdan girenlerin çoğuna görünmüyordu. Bir ziyaretçi levhaya yaklaşıyor, başını eğiyor, sonra danışmaya dönüyordu. {yoldas:yalin|bir arkadaş} bunun yeni bir kodlama hatası olmadığını söyledi. {kahraman}, “**Doğru bilgi yanlış yerde durursa yine işe yaramıyor**,” diye cevap verdi.

Aslı Hanım'dan izin alıp gözlem notlarını teknik ekibe ilettiler. Hiçbir ziyaretçiye fark ettirmeden fotoğraf çekmediler; yalnızca ışığın değiştiği saatleri ve levhanın okunabildiği açıları kaydettiler. Mert Bey, parlamayı azaltan kaplama örneklerini getirdi. Deneme sonunda biri güzel görünüyor, diğeri ise daha rahat okunuyordu. {kahraman} eskiden gösterişli olanı seçeceğini fark etti. Bu kez danışmaya daha az soru sorulmasını sağlayan seçeneği önerdi. Sıfırıncı katın sırrı çözülmüş görünüyordu; buna rağmen onu araştırmaları yeni ve gerçek bir sorunu görmelerine yardım etmişti.
---
@omurga
Bilim merkezi yeni kat etiketlerini yayımladıktan sonra {kahraman} ve {yoldas:yalin|bir arkadaş} küçük bir kullanıcı testi düzenledi. Farklı yaşlardan ziyaretçilere görevli izniyle “Kütüphaneyi bul”, “Atölyeye git” gibi basit yön bulma görevleri verdiler. Deneme sırasında kimsenin adı kaydedilmiyordu. Gözlemler, bazı ziyaretçilerin G harfini “garaj” olarak düşündüğünü gösterdi. Bu, bütün kullanıcıların aynı simgeleri aynı biçimde anlamayabileceğini kanıtlayan küçük bir örnekti.

{yoldas:yalin|bir arkadaş} tabelanın altına açıklama eklenmesini önerdi. {kahraman}, açıklamaların da çok uzun olmaması gerektiğini düşündü. Birlikte sade tasarım buldular: Büyük kat etiketi, kısa yer adı, okunabilir yön oku. Kullanıcı farklı bir ekrandaysa aynı kat adının kullanılması gerekiyordu. Böylece web rehberiyle fiziksel tabela birbirini çelişen bilgilerle karşılamayacaktı.

Bir çocuk “Sıfırıncı katı neden kaldırdınız? Orayı çok merak ediyordum,” diye sordu. {kahraman}, sayının yanlış veri eşleştirmesinden kaynaklandığını anlattı. Çocuk biraz üzüldü. {yoldas:yalin|bir arkadaş} ona bilim merkezindeki gerçek sergilerden birini gösterdi. “Merak edeceğin çok şey var,” dedi. “Üstelik bunların kapısını açmak için gizli şifre gerekmiyor.”
---
@omurga
Deneme bittiğinde Aslı Hanım teşekkür etti. Öğrencilerin katkısı bir binanın bütün tasarımını değiştirmemişti; ancak birkaç küçük belirsizliği gidermişti. {kahraman} bunun da değerli olduğunu düşündü. Büyük bir keşif peşinde başladıkları araştırma, gerçek kullanıcıların küçük sorunlarını çözmeye dönmüştü. Başlangıçta buna hayal kırıklığı derdi. Şimdi ise sorunun kendisine daha iyi bir cevap bulduklarını hissediyordu.
---
@omurga
Bilim merkezi, okulun araştırmasını küçük bir dijital okuryazarlık köşesinde sergilemeyi kabul etti. Panoda üç görüntü vardı: eski mimari taslak, yeni ziyaretçi planı ve yazılım ekranı. Her biri farklı amaçla hazırlanmıştı. Ziyaretçiler bu üç kaynağı karşılaştırıp sıfırıncı kat söylentisinin nasıl ortaya çıktığını görebiliyordu.

{kahraman}, sergi açılırken arkadaşlarına bir soru yöneltti: “Bina gerçekten değişti mi, yoksa bizim onu anlatışımız mı?” {yoldas:yalin|bir arkadaş}, “Bazen ikisi de değişir,” dedi. “Ama burada asıl karışan şey kodlama ile tabela.” Çocuklar bu cevabı yazılı bir kartta açıkladı. Kullanıcılara hangi katın hangi bölüm olduğunu net gösteren bir tablo hazırladılar.

Okul grubunda hâlâ gizli laboratuvar şakaları yapılıyordu. {kahraman} artık buna kızmıyordu. Yeter ki şaka olduğu belli olsun ve gerçek bilgiyle karıştırılmasın.[[deyim:hr104_omuz]] “Olabilir demek {kelime:hr104_kanit} değildir,” diye cevap verdi. {yoldas:yalin|bir arkadaş} de “Bize gerçekten neyin bulunduğunu açıklayan resmi planı gördük,” diye ekledi.
---
@omurga
Bir gün yeni ziyaretçilerden biri asansör ekranındaki G harfini gösterip “G ne demek?” diye sordu. {kahraman} ona giriş katı olduğunu anlattı. Küçük çocuk, “Neden sıfır değil?” dedi. {kahraman} biraz düşündü. “Çünkü farklı sistemler aynı yeri farklı biçimde adlandırabilir,” dedi. “Ama kullanan herkesin anlayacağı bir açıklama gerekir.” Çocuk başını sallayıp düğmeye bastı.

Kapı açıldığında içeride yalnızca aydınlık bir koridor vardı. {kahraman} gülümsedi. Bazen gizemli görünen bir sayı, yalnızca yanlış yere taşınmış bir etiketti. Yine de onu araştırırken daha büyük bir şey öğrenmişlerdi: Haritaya, ekrana ve söylentiye aynı gözle bakmamak gerektiğini.

Aslı Hanım, son raporu saklamak için öğrencilere bir klasör açtı. {kahraman} klasöre yalnızca “Sıfırıncı Kat” yazmak istedi. {yoldas:yalin|bir arkadaş} “Yönlendirme Hatası Araştırması” önerdi. İki başlığı yan yana yazınca hangisinin daha çok ilgi çekeceği belliydi. Fakat hangisinin gelecekte bu dosyayı arayan birine yardımcı olacağı da belliydi. Sonunda dosyanın adı ikinci seçenek oldu; ilk ad ise girişte söylentiyi açıklamak için kullanıldı.
---
@omurga
Bu basit karar {kahraman:yonelme} tuhaf biçimde zor gelmişti. Bir haftadır peşine düştüğü sırrı birkaç sözcüğe indirgemek istemiyordu. Sonra amacının sır üretmek olmadığını hatırladı. Gelecekte başka bir öğrenci aynı eski planı görürse, aradığını kolayca bulabilmeliydi. Bilgi, onu ilk bulan kişiye değil, sonra ihtiyacı olacak insanlara da ait olmalıydı. {isaret:anahtar}

{yoldas:yalin|bir arkadaş} dosyaya değişiklik tarihini ekledi. Önceki belgelerin üzerini silip yok etmediler; eski planları “önceki sürüm” etiketiyle sakladılar. Böylece araştırmaya neden başladıkları anlaşılacaktı. En sonunda {kahraman} bir not düştü: “Yanlışlığı düzeltmek geçmişte yanılmadığımızı iddia etmek değildir.”
