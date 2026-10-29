---
baslik: "Hafızası Karışan Android"
slug: "hr062-hafizasi-karisan-android"
fis_kodu: "HR-062"
tur: bilim_kurgu
konu: veri_dogrulama
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas, hayali]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Ev robotu kahvaltıya çorap getirdi. Hata nerede: robotta mı, komutta mı, verideki bir eksikte mi?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, guvenlik]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: algoritma_hr062, tur: lexeme, etiket: "algoritma", yuva: hr062_algoritma, islev: first_hint}
    - {id: sesteslik_hr062, tur: lexeme, etiket: "sesteşlik", yuva: hr062_sesteslik, islev: application}
    - {id: dogrulama_hr062, tur: lexeme, etiket: "doğrulama", yuva: hr062_dogrulama, islev: application}
    - {id: kavram_hr062, tur: concept, etiket: "Veri, hata ve doğrulama", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Robot kahvaltı masasına ne getirdi?", secenekler: [{id: A, metin: "Peynirli tost"}, {id: B, metin: "Kitaplar"}, {id: C, metin: "Üç çift çorap"}, {id: D, metin: "Defterler"}], dogru: C, aciklama: "Robot, tost yerine üç çift çorap getirdi."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Robotun çorap getirmesinin nedeni neydi?", secenekler: [{id: A, metin: "Mutfakta çorapların o gün daha çok stokta bulunduğu için"}, {id: B, metin: "Ailenin o sabah kahvaltıya özellikle çorap istemiş olması"}, {id: C, metin: "Mutfakta tost için gereken malzemenin o sabah tamamen bitmesi"}, {id: D, metin: "Komutları yanlış birleştirmesi ve sözcükleri karıştırması"}], dogru: D, aciklama: "“Tost” ve “toz”, “çorap” ve “çorabı” gibi benzer kayıtlar karışmıştı."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, metin: "Deniz Bey'in açıklamasına göre bir sistemin sonucu neye bağlıdır?", secenekler: [{id: A, metin: "Yalnızca robotun ekranındaki renklere"}, {id: B, metin: "Robotun ne kadar hızlı hareket ettiğine"}, {id: C, metin: "Kurallara, verilere ve doğrulamaya"}, {id: D, metin: "Her gün değişen hava durumu tahminlerine"}], dogru: C, aciklama: "Sonuç, kuralların, verilerin ve kontrol süreçlerinin birlikte doğru çalışmasına bağlıdır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 7, metin: "Metinde sesteşlik ne anlama gelir?", secenekler: [{id: A, metin: "Aynı anlamı taşıyan farklı yazılışlı sözcükler"}, {id: B, metin: "Aynı yazılış ve sesle farklı anlamlar taşıyan sözcükler"}, {id: C, metin: "Zıt anlamlı iki sözcüğün yan yana kullanılması"}, {id: D, metin: "Bir cümlede iki farklı dilin birlikte kullanılması"}], dogru: B, aciklama: "Sesteş sözcükler, yazılışları ve sesleri aynı olup anlamları farklı olan kelimelerdir."}
---
@omurga
Ev robotu ARO, o sabah kahvaltı masasının üzerine üç çift çorap getirdi. “Günaydın,” dedi. “İstenen kahvaltı hazır.”

Beşinci sınıftan {kahraman} önce gülmeye başladı, sonra şaşırdı. “ARO, biz senden peynirli tost istemiştik.”

Robot başını sağa çevirdi. “Talep kaydı: Tost. Eşleşen nesne: Çorap. Güven düzeyi: düşük.”

{kahraman:ilgi} ablası robotun ekranına baktı; yanlarında {yoldas:yalin|bir arkadaş} da duruyordu. Bir gün önce evdeki yardımcı yapay zekâ sisteminin güncellemesi yapılmıştı. ARO konuşulan sözcükleri bazen yanlış sınıflandırıyor, istekleri karıştırıyordu. Ailesi robotu ev işlerinde güvenli ve sınırlı görevler için kullanıyordu; mutfaktaki ısıtıcı araçları kendi başına çalıştırmasına izin verilmiyordu. Neyse ki çorapları masaya koymaktan başka bir iş yapmamıştı.

“Belki de belleği silindi,” dedi {kahraman}.

{yoldas:yalin|bir arkadaş} hemen itiraz etmedi. “Bu bir olasılık,” dedi. “Ama önce neyin yanlış gittiğini öğrenmeliyiz.”
---
@omurga
ARO'nun ekranında son komutlar açıldı. “Tost getir” ifadesi yanında “toz getir” yazıyordu. Bir başka satırda “çorapları topla” talebi “çorabı hazırla” biçiminde kayıtlıydı. Robot iki ayrı komutu yanlış birleştirmişti. {kahraman}, “İşte, hafızası karışmış!” dedi.

{yoldas:yalin|bir arkadaş}, “Hafıza” sözcüğünün burada mecaz gibi kullanıldığını açıkladı. Robotun bir insan gibi anılar yaşadığını söylemek doğru değildi. Sistem verileri kaydediyor, belirli kurallarla işliyordu. Yanlış sonuç çıktığında veri, yazılım ve verilen komutlar birlikte kontrol edilmeliydi.

Aile, ARO'nun otomatik görevlerini geçici olarak durdurdu. {yoldas:yalin|bir arkadaş} öğretmenleriyle okulun teknoloji kulübünde üzerinde çalıştıkları basit karar ağacını hatırladı. “Önce güvenli denemeler yapabiliriz,” dedi. “Ama kişisel kayıtları izinsiz paylaşmayalım.” Aile, yalnız örnek komutlarla bir test hazırlamayı kabul etti. Hiç kimsenin özel konuşmaları deney malzemesi olmayacaktı.
---
@omurga
İlk testte {kahraman} “Mavi kitabı masaya koy” dedi. ARO doğru kitabı getirdi. İkinci testte {yoldas:yalin|bir arkadaş} “Masadaki kırmızı defteri bul” dedi. Robot önce mavi kitaba yöneldi, sonra durdu. “İki benzer nesne var. {kelime:hr062_dogrulama} gerekli,” dedi. {yoldas:yalin|bir arkadaş} bu yanıtı olumlu buldu. Yanlış nesneyi kesin doğru sanmaktansa soru sorması daha iyiydi.

Üçüncü testte robot “oda” sözcüğünü “odun” olarak algıladı. {kahraman} kahkahasını tutamadı. “ARO, biz evde odun istemiyoruz.” {yoldas:yalin|bir arkadaş} ses benzerliğinin tek başına anlamı belirlemediğini anlattı. Sözcüğün kullanıldığı cümle, önceki konuşma ve mevcut görev bilgisi önemliydi. Ama sistemin geçmiş konuşmaları gereksiz yere kaydetmesine de gerek yoktu. Yalnız gerekli veriler kullanılmalıydı.

Teknoloji kulübünün öğretmeni Deniz Bey, çocukların hazırladığı test tablosunu inceledi. “Bir {kelime:hr062_algoritma}, verilen kuralları ve verileri kullanarak sonuç üretebilir,” dedi. “Ama verdiği sonuç yanlış olabilir. Bu yüzden doğrulama, güvenlik sınırları ve insan denetimi önemlidir.” {kahraman}, “Robot yanıldığını söyleyebilir mi?” diye sordu. Öğretmen, sistemlerin belirsizlik bildirimi yapabilecek şekilde tasarlanabileceğini anlattı.
---
@omurga
{yoldas:yalin|bir arkadaş} ile {kahraman} bunun üzerine ARO için üç yeni ekran hazırladı. Birinci ekran “İsteği anladım”, ikincisi “Emin değilim, tekrar soracağım”, üçüncüsü “Bu görevi güvenle yapamam” diyordu. Çocuklar en çok üçüncü ekrana şaşırdı. Bir robotun her komuta “Evet” demesi iyi bir yardımcılık değildi. Tehlikeli veya yetkisiz görevleri durdurması da önemliydi.

{kahraman} ilk gün robotun yanlışlarını komik buluyordu. Fakat bir an düşündü. ARO yanlış bir kitabı getirdiğinde sorun küçük olabilirdi; ama yanlış bir ilaç kutusunu seçseydi çok daha ciddi sonuçlar doğabilirdi. Bu yüzden aile, robotun sağlık, güvenlik veya önemli kişisel kararlar üzerinde bağımsız yetkisi olmaması gerektiğini açıkça belirledi. Robot bu tür taleplerde yetişkinlere başvurulmasını hatırlatacaktı.

Bir hafta sonunda ARO'nun komutları daha iyi ayırdığı görüldü. Ancak {yoldas:yalin|bir arkadaş} bunu “Artık hiç hata yapmaz” diye anlatmadı. Yalnızca yaptıkları denemelerde daha az karışıklık gözlediklerini söyledi. {kahraman}, evdeki teknoloji panosuna “Sistem başarılı olabilir, yine de kontrol gerekir” yazdı.
---
@omurga
Cumartesi sabahı ARO yeniden kahvaltı masasına geldi. “Günaydın,” dedi. “Bugünkü görev: Masadaki kitapları düzenlemek. Başlamadan önce onay istiyorum.”

{kahraman} gülümsedi. “Onaylıyorum. Ama çorapları mutfağa getirme.”

ARO kısa bir duraklamadan sonra cevap verdi: “Çoraplar kahvaltı malzemesi değildir. Bilgi güncellendi.”

{yoldas:yalin|bir arkadaş} kahkahaya boğuldu. Robotun insan gibi öğrenip öğrenmediği üzerine uzun uzun tartışmaya girmediler. Önemli olan, sistemi daha güvenli ve anlaşılır kullanabileceklerini öğrenmiş olmalarıydı. {kahraman}, teknolojinin yalnız ne yapabildiğini değil, ne zaman durması ve soru sorması gerektiğini de düşünmenin gerekli olduğunu artık biliyordu.

ARO'nun evde ilk kullanılmaya başlandığı günleri {kahraman} hâlâ hatırlıyordu. Robot, oyuncak kutusunu taşımasına yardım etmiş, masanın üzerindeki defterleri renklerine göre ayırmıştı. {kahraman} o zaman ARO'yu kusursuz bir yardımcı sanmıştı. Ablası ise her yeni cihazın belirli sınırları olduğunu söylemişti. “Bir robotun hızlı hareket etmesi, ne istediğimizi her zaman doğru anlayacağı anlamına gelmez,” demişti. {kahraman} bu uyarıyı çok ciddiye almamıştı. Çoraplı kahvaltı günü gelince ablasının ne demek istediğini daha iyi anlamıştı.
---
@omurga
{yoldas:yalin|bir arkadaş}, sorunu çözmeden önce ailece bir liste hazırlamalarını önerdi. Robotun hangi işleri yapmasına izin vardı? Hangi işlerde önce onay istemesi gerekiyordu? Hangi işleri kesinlikle yapmamalıydı? Herkes kendi önerisini söyledi. {kahraman} kitapları taşımak ve oyuncak kutusunu düzenlemek gibi güvenli görevler önerdi. Annesi, kapıları açma veya bir cihazı çalıştırma gibi işlerde insan kontrolünün gerekli olduğunu vurguladı. Babası da kişisel bilgilerin başkalarıyla paylaşılmaması gerektiğini söyledi. Liste tamamlandığında herkesin beklentisi daha açık hâle geldi.

ARO için hazırlanan ilk test kartında iki ayrı fotoğraf bulunuyordu. Birinde mavi bir kitap, diğerinde lacivert bir defter vardı. {kahraman} “Mavi olanı getir” dediğinde robot hangisini seçeceğini bilemedi. {yoldas:yalin|bir arkadaş} bunu hata olarak işaretlemek üzereydi, fakat durdu. Renk adları birbirine yakın olabilir, ayrıca iki nesne de koyu mavi görünebilirdi. “Belki de sorumuz yeterince açık değil,” dedi. {kahraman} komutu değiştirdi: “Kapakta uçurtma resmi olan mavi kitabı getir.” Robot bu kez doğru kitabı seçti. Çocuklar, doğru cevabın yalnız iyi bir sistemle değil, açık bir istekle de ilişkili olduğunu öğrendi.
---
@omurga
İkinci kartta aynı sözcük farklı cümlelerde kullanılıyordu. “Yüz sayfalık defter” ile “Yüzünü yıka” cümleleri yan yana yazılmıştı. {kahraman}, “ARO bu iki yüz sözcüğünü nasıl ayırıyor?” diye sordu. {yoldas:yalin|bir arkadaş}, Türkçede bazı sözcüklerin aynı yazılış ve sesle farklı anlamlar taşıyabildiğini anlattı. Buna {kelime:hr062_sesteslik} dendiğini öğrendiler. Sözcüğün çevresindeki diğer kelimeler ne anlama geldiğini anlamaya yardım ediyordu. ARO'nun cümledeki bağlamı değerlendirmesi bu yüzden önemliydi. {kahraman} bu bölüm için küçük bir kelime oyunu hazırladı.

Oyunda birinci kartta “gül” yazıyordu. ARO önce çiçek resmini gösterdi. {kahraman}, “Peki ‘Gül, çünkü çok komik’ cümlesinde?” diye sordu. Robot önce durdu, sonra fiil olan gülmekle ilgili açıklamayı seçti. {yoldas:yalin|bir arkadaş}, iki örneğin sesteş sözcüklerin anlamını göstermeye yardımcı olduğunu belirtti. Ama gerçek dilin bundan daha karmaşık olduğunu da söyledi. Kelimeler yalnız sözlük listelerinden ibaret değildi; insanlar onları cümlede, konuşmada ve çeşitli bağlamlarda kullanıyordu.
---
@omurga
Testlerin ortasında ARO'nun ekranında yanlış bir uyarı belirdi: “Görev tamamlandı.” Oysa masadaki üç kitaptan biri yerindeydi. {kahraman} bunu görünce “Robot yalan söylüyor,” dedi. {yoldas:yalin|bir arkadaş}, “Yalan söylemek insanın niyetiyle ilgili bir söz,” diye karşılık verdi. “Burada sistem yanlış sonuç üretiyor olabilir.” Robotun görevi nasıl tamamlandı saydığını araştırdılar. Yazılım, taşınması gereken kitap sayısını iki olarak kaydetmişti. ARO iki kitabı alınca işi tamamlanmış sayıyordu. Sorun yalnız robotun görmesinde değil, hazırlanan görev verisindeydi. {kahraman}, yanlış sonucun nedenini bulunca kendini gerçek bir araştırmacı gibi hissetti.

Deniz Bey okul kulübünde bu örneği anlattığında çocuklara bir soru sordu: “**Yanlış cevabı her zaman cihaz mı üretir**, yoksa bizim hazırladığımız bilgiler de hatalı olabilir mi?” Bir öğrenci “İkisi de,” dedi. Öğretmen, teknolojik sistemlerde veri kalitesi, açık görev tanımı ve kontrol süreçlerinin önemini anlattı. {yoldas:yalin|bir arkadaş} robotu kötülemek istemiyordu; ama başarılı görünen sonuçlara da sorgulamadan güvenmenin doğru olmadığını öğrenmişti. Bu yaklaşımı kulüp panosunda küçük bir şema hâline getirdi: İstek → Yorum → İşlem → Sonuç → Doğrulama.
---
@omurga
{kahraman:ilgi} en sevdiği görev, ARO'nun yanlış anladığı cümleleri düzeltmekti. Fakat bir süre sonra arkadaşlarıyla ilgili örnekler vermek istediğinde {yoldas:yalin|bir arkadaş} onu durdurdu. “Başka insanların özel konuşmalarını izin almadan kullanamayız,” dedi. Bunun yerine hayalî kişilerle örnek cümleler yazdılar. “Ali kırmızı kutuyu istiyor” ve “Zeynep mavi kitabı seçiyor” gibi basit, kimseye ait özel bilgi içermeyen testler hazırladılar. ARO'nun öğrenme örnekleri için gerçek aile sohbetlerinin kaydedilmesine gerek yoktu. {kahraman}, kişisel veri sözcüğünü ilk kez bu kadar somut bir olayda düşünüyordu.

Bir akşam ARO, “{yoldas:ilgi|bir arkadaşın} ödevini tamamlayabilirim,” diye öneride bulundu. {yoldas:yalin|bir arkadaş}, robotun kendisi yerine ödev yazmasını istemedi. “Bana konuyu araştırmak için soru sorabilirsin,” dedi, “ama sonucu benim anlamam ve yazmam gerekiyor.” {kahraman} bunun üzerine dijital yardımın da sınırları olabileceğini düşündü. Bir teknoloji her işi bizim yerimize yaparsa bazı becerileri kendimiz geliştiremeyebilirdik. {yoldas:yalin|bir arkadaş}, ARO'dan kendisine üç araştırma sorusu hazırlamasını istedi; cevapları kitaptan ve öğretmeniyle konuşarak bulacaktı.
---
@omurga
Kulüp gösterisi günü ARO küçük bir masanın üzerinde durdu. {kahraman} üç farklı komut kartı okudu. Birincisi açık ve güvenliydi; robot doğru davranışı gösterdi. İkincisi belirsizdi; robot “Tekrar açıklar mısınız?” diye sordu. Üçüncü kart ise izin verilmemiş bir görev içeriyordu. ARO “Bu görevi gerçekleştiremiyorum,” diyerek durdu. İzleyenler üçüncü yanıtı da alkışladı. {kahraman} şaşırdı. İnsanlar bir robotun durmasını neden başarı sayıyordu? Deniz Bey, “Çünkü her talebi düşünmeden uygulamamak da güvenli tasarımın parçası,” dedi.

Gösterinin sonunda bir öğrenci “Robot gerçekten düşündü mü?” diye sordu. {yoldas:yalin|bir arkadaş}, ARO'nun insanlar gibi duygular yaşadığına veya düşünme biçimine sahip olduğuna ilişkin bir iddiada bulunamayacaklarını söyledi. Bildikleri şey, onun verileri ve programlanan işlemleri kullanarak sonuç ürettiğiydi. {kahraman}, daha önce robotuna kızdığında ona insanmış gibi davrandığını fark etti. Teknolojinin nasıl çalıştığını anlamak, onu ne gereksiz yere küçümsemek ne de olduğundan fazla büyütmek demekti. En doğrusu yararlarını, sınırlılıklarını ve risklerini birlikte değerlendirmekti.
---
@omurga
Şenlik sonrası ailece akşam yemeğinde ARO yeniden “Bugünkü göreviniz nedir?” diye sordu. Annesi, “Şimdi dinlenme zamanı,” dedi. Robot sessiz moda geçti. {kahraman} güldü. “Bence bugün en iyi yaptığı şey bu.” {yoldas:yalin|bir arkadaş}, bir teknolojinin sürekli çalışmasının gerekmediğini hatırlattı. İnsanlar bazen ekranlardan ve makinelerden uzaklaşıp birbirleriyle konuşmak isterdi. ARO sessizce beklerken aile masada günlerinin nasıl geçtiğini anlattı. {kahraman} robotun sessizliğini ilk kez rahatsız edici değil, dinlendirici buldu.

Ertesi gün {kahraman} yeni bir hikâye yazmaya başladı. Başlığı “Çoraplı Kahvaltı” idi. Hikâyesinde bir robot, bütün eşyaları karıştırıyor ve evdeki herkes onu düzeltmeye çalışıyordu. Ama öykünün sonunda robot bir anda kusursuz hâle gelmiyordu. Aile, doğru soru sormayı, sınırlar koymayı ve birbirini dinlemeyi öğreniyordu. {kahraman} bu sonu sevdi. Çünkü kendi yaşadıkları da böyleydi. Bir hata, onların teknoloji hakkında daha dikkatli düşünmesine yol açmıştı. En komik günlerinden biri, en öğretici günlerinden birine dönüşmüştü.
---
@omurga
Bir ay sonra ARO'nun yazılımına yeni bir özellik eklendi. Robot, görev tamamlandığında yalnız “Bitti” demek yerine ne yaptığını kısa biçimde açıklıyordu. {kahraman} bu özelliği çok sevdi. Çünkü sonuç doğru görünse bile hangi işlemlerden geçtiğini anlamak istiyordu. Bir gün ARO kitapları dizerken iki defteri yanlış rafa koydu. {kahraman}, robotun açıklamasına bakınca kararını yalnız kapak rengine göre verdiğini gördü. Oysa raflar konuya göre düzenleniyordu. {yoldas:yalin|bir arkadaş}, “İşte yine veriyle amaç arasındaki fark,” dedi. Robotun işi yaparken hangi kurala dayandığını anlamak, doğru sonuca ulaşmayı kolaylaştırıyordu.

Teknoloji kulübü bu deneyimi küçük bir oyun hâline getirdi. Öğrenciler üç farklı talimat kartı hazırladı. Bir kart bilerek belirsiz yazılmıştı: “Şunu oraya götür.” İkinci kart daha açıktı: “Masanın sağındaki kitabı rafa koy.” Üçüncü kart ise koşullu ifadeler içeriyordu: “Kitap mavi kapaklıysa önce sahibini doğrula, değilse görevliye sor.” Çocuklar kartları karşılaştırdığında dilin açık kullanılmasının teknoloji için ne kadar önemli olabileceğini gördüler. Deniz Bey, bazı koşullu komutların günlük yaşamda da bulunduğunu anlattı. “Yağmur yağarsa şemsiyeni al,” cümlesi basit bir koşula dayanıyordu. {isaret:kitap}
---
@omurga
{kahraman} eve döndüğünde küçük kardeşiyle aynı oyunu oynadı. Birisi robot olacak, diğeri komut verecekti. “Kitabı getir” dediğinde kardeşi masadaki herhangi bir kitabı seçti. {kahraman} önce “Yanlış!” demek istedi, sonra komutunun yeterince açık olmadığını fark etti. “Üzerinde yeşil ağaç resmi bulunan kitabı getir,” diye düzeltti. Kardeşi doğru kitabı buldu. İkisi güldü. İletişim yalnız karşıdakinin anlamasını beklemek değildi; anlatanın da düşüncesini açık kurması gerekiyordu.

ARO bir gün “Bir hata olduğunda yardım istiyorum,” cümlesini seslendirdi. {kahraman} onun gerçek anlamda yardım istediğini sanıp güldü. {yoldas:yalin|bir arkadaş}, bunun programlanan bir bilgilendirme cümlesi olduğunu anlattı. İnsanların yardıma ihtiyaç duyduğu zamanlarla teknolojik sistemlerin uyarı verdiği durumları aynı saymamak gerekiyordu. Ama iki durumda da iyi bir iletişim önemliydi. {kahraman}, robotun insan gibi hissettiğini düşünmeden ona daha güvenli görevler verebileceğini anladı.
---
@omurga
Yıl sonunda teknoloji kulübü çalışmalarını sergilediğinde {kahraman} bir tabelaya yalnız üç kısa buyruk yazdı: “Sor. Kontrol et. Koru.” Yanına küçük çorap resmi çizdi. Ziyaretçiler bunun neden orada olduğunu sorunca yaşadıkları komik kahvaltıyı anlattı. Sonra açıklamasını ekledi: “Bir robotun hata yapması bizi güldürebilir. Ama yanlış bilgiyle yapılan ciddi işlerde daha dikkatli olmalıyız.” {yoldas:yalin|bir arkadaş} bu açıklamayı gururla dinledi. ARO da masanın yanında sessizce duruyordu. Kimse ondan çorap getirmesini istememişti. Bu bile iyi bir başlangıç sayılabilirdi.

{kahraman:ilgi} öğretmeni, sınıf içindeki yazılı anlatım etkinliğinde “Çoraplı Kahvaltı” hikâyesini okumak istedi. {kahraman} kabul etti. Arkadaşları robotun komik yanlışlarına güldü, sonra ondan ne öğrendiklerini tartıştı. Kimi “Komutları açık vermek,” dedi, kimi “Bilgiyi kontrol etmek.” Bir öğrenci “Bir şey yanlış giderse kimin suçlu olduğunu hemen aramak yerine nedenini araştırmak,” diye ekledi. {kahraman} bu yanıtı özellikle sevdi. Çünkü ilk gün ARO'ya kızmış, sonra kendi sözlerinin de bazen belirsiz olduğunu fark etmişti.
---
@omurga
Hikâye okunduktan sonra {kahraman}, arkadaşlarının önerileriyle küçük bir düzeltme yaptı. Robotun son sahnede “Her şeyi öğrendim,” demesini çıkardı. Yerine “Yeni görevlerde yine doğrulama gerekebilir” cümlesini yazdı. Böylece robot kusursuz görünmüyordu. {kahraman} bunun daha inandırıcı ve daha öğretici olduğuna karar verdi. Hatalardan öğrenmek, bir daha hiç hata yapmamak demek değildi. Önemli olan her yeni durumda dikkatli ve sorgulayıcı kalabilmekti.
---
@omurga
- Kavramlar: Algoritma, veri, belirsizlik, doğrulama, insan denetimi. - Dil: Oda–odun benzerliği; bağlam, çok anlamlılık ve mecaz kullanım. - Dijital güven: Kişisel verilerin korunması; yüksek riskli görevlerde insan kontrolü.
