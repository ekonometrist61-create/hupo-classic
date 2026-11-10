---
baslik: "Şifreli Arı Dansı"
slug: "hr059-sifreli-ari-dansi"
fis_kodu: "HR-059"
tur: bilim
konu: ari_iletisim
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas, hayvan]
deger_anahtarlari: [D6, D9]
yetiskin_uygun: false
tanitim: "Bahçedeki ayçiçekleri neden az büyüdü? Arılar çiçeği nasıl buluyor?"
durum: taslak
uretim_kaynak: chatgpt_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [doga, hayvanlar]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D9
  ogrenme_hedefleri:
    - {id: tozlasma_hr059, tur: lexeme, etiket: "tozlaşma", yuva: hr059_tozlasma, islev: first_hint}
    - {id: nektar_hr059, tur: lexeme, etiket: "nektar", yuva: hr059_nektar, islev: application}
    - {id: polen_hr059, tur: lexeme, etiket: "polen", yuva: hr059_polen, islev: application}
    - {id: kavram_hr059, tur: concept, etiket: "Birden çok etkenle açıklama", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pass, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Bu yıl bahçedeki ayçiçeklerinin yarısı eskisi kadar büyümemişti.", metin: "Bahçedeki hangi bitkiler beklenenden küçük kalmıştır?", secenekler: [{id: A, metin: "Gül çalıları"}, {id: B, metin: "Fesleğenler"}, {id: C, metin: "Ayçiçekleri"}, {id: D, metin: "Nane yaprakları"}], dogru: C, aciklama: "Küçük kalan bitkiler ayçiçekleridir."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, dayanak: "Aynı bahçede su, ışık ve böcek ziyaretleri de farklılık gösteriyordu.", metin: "Ayçiçeklerinin küçük kalmasında ne etkili olmuş olabilir?", secenekler: [{id: A, metin: "Yalnızca arıların hiç gelmemesi"}, {id: B, metin: "Su, ışık ve arı ziyaretlerinin farkı"}, {id: C, metin: "Tohumların başka yerden alınması"}, {id: D, metin: "Toprağın bütün sıralarda aynı olması"}], dogru: B, aciklama: "Su, ışık ve böcek ziyaretleri sıralar arasında farklıydı; tek bir sebep yoktu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "Sallanma ne kadar uzun sürerse çiçek o kadar uzaktaydı.", metin: "Bir arının sallanması çok uzun sürerse çiçek hakkında ne söylenebilir?", secenekler: [{id: A, metin: "Çiçek kovanın hemen yanındadır"}, {id: B, metin: "Çiçek yalnızca sabah açmıştır"}, {id: C, metin: "Çiçekte hiç nektar kalmamıştır"}, {id: D, metin: "Çiçek kovandan uzaktadır"}], dogru: D, aciklama: "Sallanma ne kadar uzun sürerse çiçek o kadar uzaktadır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 1, dayanak: "Arı, çiçeğin içindeki nektar denen şekerli sıvıyı topluyordu.", metin: "“Nektar” sözcüğü çiçekte neyi anlatır?", secenekler: [{id: A, metin: "Şekerli çiçek sıvısı"}, {id: B, metin: "Kuru taç yaprağı"}, {id: C, metin: "Sert odun kabuğu"}, {id: D, metin: "İnce bir toprak tanesi"}], dogru: A, aciklama: "Nektar çiçeğin şekerli sıvısıdır."}
---
@omurga
Bu yıl bahçedeki ayçiçeklerinin yarısı eskisi kadar büyümemişti. {kahraman}, dedesinin bahçesinde yan yana duran iki sıraya baktı. Bir sıradaki başlar iri, ötekindekiler küçük ve seyrek tohumluydu. Dedesi her iki sırayı da aynı gün ekmişti. {yoldas:yalin|bir arkadaş}, “Belki arılar hiç gelmedi,” dedi. {kahraman} hemen karar vermek istemedi; defterine bitkilerin boyunu yazdı.

Bahçenin kenarındaki kovandan birkaç arı çıkıyordu. Dedesi arıların davranışlarını uzaktan izlemeleri için çocuklara güvenli bir yer gösterdi. Çiçeklerin arasında dolaşan arılar, sarı başların içinden {kelime:hr059_nektar} topluyordu. Arı, çiçeğin içindeki nektar denen şekerli sıvıyı topluyordu. Bir başka arının bacaklarında sarı tozlar görünüyordu. {kahraman}, bu tozların {kelime:hr059_polen} olduğunu not etti.

Dedesi, arıların bir çiçekten diğerine polen taşımasının {kelime:hr059_tozlasma} sürecine katkı verebildiğini söyledi. Fakat bütün bitkilerin gelişmesini tek başına buna bağlamadı. {kahraman} iki sıranın arasındaki toprağı eline aldı. Bir taraf daha kuru, diğer taraf daha nemliydi. Dedenin eski sulama kabı, bahçenin güneşli tarafında duruyordu. Çocuklar ölçümler için ayrı bir sayfa açtı.
---
@omurga
{kahraman} ve arkadaşı, bitki sıralarını küçük karelere ayırıp gözlem yaptı. İlk karenin toprağı gevşekti; ikinci karede toprak sertleşmişti. Üçüncü kareye komşu ağacın gölgesi düşüyordu. Aynı bahçede su, ışık ve böcek ziyaretleri de farklılık gösteriyordu. {yoldas:yalin|bir arkadaş}, arıların geçtiği çiçeklerin yanına küçük noktalar koydu.

Dedesi kovanın camlı gözlem bölümünü gösterdi. İçerideki arıların bir kısmı hareket ederek diğerlerinin yanına geliyor, sonra yeniden uzaklaşıyordu. {kahraman}, bir arının gövdesini sallayarak yaptığı hareketi defterine çizdi. Hareketin açısını ve ne kadar sürdüğünü tam ölçememişti. Dedesi, arıların bu hareketlerle yiyeceğin yeri hakkında bilgi iletebildiğini anlattı.

{yoldas:yalin|bir arkadaş}, dansın yönüyle bahçedeki çiçeklerin yerini karşılaştırmak istedi. Güneşin bulunduğu yönü kâğıtta işaretlediler. Kovanın dışına çıkıp çiçek sıralarına doğru uçan arıları uzaktan izlediler. Bazıları iri ayçiçeklerine yöneliyor, bazıları bahçenin dışındaki küçük mor çiçekleri seçiyordu. Çocuklar her uçuşun aynı sonuca varmadığını görünce kayıtlarına ayrı işaretler koydu.
---
@omurga
Arının sallanarak yaptığı dans, besin kaynağının yönüyle ilgili ipucu taşıyordu. Kovanın camında arı sallanarak kısa bir çizgi çiziyor, sonra başa dönüp aynı çizgiyi yeniden yürüyordu. Dedesi, çizginin yönünün çiçeğin güneşe göre yerini gösterdiğini söyledi. Sallanma ne kadar uzun sürerse çiçek o kadar uzaktaydı. {kahraman} bu kez arıyı saniye sayarak izledi: Kısa sallanma yakındaki ayçiçeklerini, uzun sallanma bahçenin dışındaki mor çiçekleri gösteriyordu. {kahraman} bu bilgiyi, kendi gözlemlediği arıları tek tek saymakla karıştırmadı; gördüklerini ve okuduklarını ayrı satırlara yazdı. Kovanın önündeki gölgede kalıp arıların uçuşunu bir süre daha izlediler.

Çocuklar, güneşin konumunu göstermek için bahçe çitinin üstündeki gölgeyi çizdi. Sabah gölgenin altında kalan yapraklar öğleye doğru ışık alıyordu. Komşu ağacın dallarıysa küçük ayçiçeklerinin üzerine uzun süre gölge düşürüyordu. {kahraman} dalları koparmadan önce bu gözlemi yalnızca çizimle kaydetti. Dedesi, eski bir fotoğraf çıkardı; fotoğraftaki ağaç dallarının bugünkünden daha kısa olduğu görülüyordu.

Bahçenin küçük kalan ayçiçekleri için başka bir kayıt daha vardı. Dedesi geçen hafta sulama hortumunun bir ucunun tıkandığını gösterdi. Hortumun ucundaki delikler kuru sıraya bakıyordu, fakat su oraya ulaşmamıştı. {kahraman}, kuruyan toprağın yanına bir çizgi çekti. Daha az suyun, gelişmeyi etkileyebileceğini yazdı. Arkadaşı, gölge yapan ağacın dalını da ölçüm çizimine ekledi.

Çocuklar çiçeklerin üstüne konan böcekleri sayarken bir arı uzun süre aynı yerde durdu. Bacaklarındaki sarı yük belirginleşmişti. Ardından başka bir çiçeğe geçti. {kahraman}, bu kısa hareketi görmeden önce bir tohumun oluşmasında nelerin etkili olabileceğini yalnızca tahmin ediyordu. Şimdi defterinde sulama, ışık ve böcek ziyaretleri için üç ayrı sütun bulunuyordu.
---
@omurga
Kovanın çevresinde çiçek kokusu artmıştı. Dedesi, bazı arıların bahçeden daha uzak alanlara uçtuğunu gösterdi. {yoldas:yalin|bir arkadaş} bütün arıları tek tek takip edemeyeceğini söyleyince {kahraman} izledikleri alanı küçük bir kareyle sınırladı. Bu karenin içinde belirli bir süre boyunca yapılan ziyaretleri saydılar. Ardından sayıları kâğıda geçirip ölçmedikleri yerler için boşluk bıraktılar.

Öğleden sonra bahçenin kenarındaki su kabının gölgesi uzadı. Dedesi tıkalı hortumu temizleyip suyu kuru sıraya yönlendirdi. {kahraman}, iki sıraya verilen su miktarının kayıtlarını tuttu. {yoldas:yalin|bir arkadaş} gün boyunca ziyaret edilen çiçekleri işaretlediği haritayı getirdi. Haritada bazı çiçeklerin çevresinde çok, bazılarında az nokta vardı.

Dedesi küçük tohumları ayırmak için boş bir tabağı masaya koydu. Çocuklar iri ve küçük başlardan alınmış tohum örneklerini ayrı kaplara yerleştirdi. Aynı ağırlıkta olup olmadıklarını görmek için teraziyi kullandılar. {kahraman}, ayçiçeklerinin hepsinin yalnızca arı ziyaretlerine bağlı olmadığını düşünüyordu; ama arıların taşıdığı polenin de göz ardı edilmesini istemiyordu.

Bahçenin üstünden geçen birkaç arı, komşu taraftaki çiçeklere doğru uçtu. {yoldas:yalin|bir arkadaş}, kuşların uçuşuyla arıların uçuşunun ne kadar farklı göründüğünü söyledi. Çocuklar kovanın önünden uzaklaşıp toprağın yanına döndü. Dedesi, yeni sulama düzeninin sonuçlarını birkaç gün sonra karşılaştırmayı önerdi. {kahraman}, defterindeki ilk güne ait tarihi yuvarlak içine aldı, ayçiçeği çiziminin altına yeni ölçüm için boş bir satır açtı.
