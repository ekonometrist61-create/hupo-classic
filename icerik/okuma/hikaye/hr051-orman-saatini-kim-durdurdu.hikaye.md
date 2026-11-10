---
baslik: "Orman Saatini Kim Durdurdu?"
slug: "hr051-orman-saatini-kim-durdurdu"
fis_kodu: "HR-051"
tur: doga
konu: mevsim_gozlem
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: masalsi
izinli_turler: [ben, arkadas, hayvan, hayali]
deger_anahtarlari: [D6, D9]
yetiskin_uygun: false
tanitim: "Orman saati sonbaharda takıldı ama çiçekler açıyor. Saati kim durdurdu?"
durum: taslak
uretim_kaynak: chatgpt_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [doga, hayvanlar]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D9
  ogrenme_hedefleri:
    - {id: goc_hr051, tur: lexeme, etiket: "göç", yuva: hr051_goc, islev: first_hint}
    - {id: nem_hr051, tur: lexeme, etiket: "nem", yuva: hr051_nem, islev: application}
    - {id: mecaz_hr051, tur: lexeme, etiket: "mecaz", yuva: hr051_mecaz, islev: application}
    - {id: deyim_hr051, tur: idiom, etiket: "Kulaktan kulağa yayılmak", yuva: hr051_kulaktan_kulaga, islev: application}
    - {id: kavram_hr051, tur: concept, etiket: "Gözlem ile çıkarım ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pass, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Orman saatinin uzun kolu sonbahar yaprağında durmuştu.", metin: "Orman saatinin kolu hangi mevsimde durmuştur?", secenekler: [{id: A, metin: "İlkbaharda"}, {id: B, metin: "Sonbaharda"}, {id: C, metin: "Yaz başında"}, {id: D, metin: "Kış sonunda"}], dogru: B, aciklama: "Saatin kolu sonbahar yaprağındadır."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, dayanak: "Kuşlar, uçuş kararını saatin koluna değil rüzgâra ve yiyeceğe göre veriyordu.", metin: "Kuşların uçuşa hazırlanma kararı neye dayanıyordu?", secenekler: [{id: A, metin: "Saatin koluna ve çan sesine"}, {id: B, metin: "Kirpinin ve tavşanın uyarısına"}, {id: C, metin: "Dere kenarında açan çiçeklere"}, {id: D, metin: "Rüzgâra ve yiyecek miktarına"}], dogru: D, aciklama: "Kuşlar kararlarını saate değil, rüzgâra ve yiyeceğe göre verdi."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "{kelime:hr051_nem} yüzünden şişen tahta parçası dişlinin arasına sıkışmıştı.", metin: "İnceleme sonunda hangi durum saatin kolunu sıkıştırmıştır?", secenekler: [{id: A, metin: "Nemlenen tahta parçası"}, {id: B, metin: "Kırılan cam bardak"}, {id: C, metin: "Yuvarlanan küçük çakıl taşı"}, {id: D, metin: "Kopan çiçek yaprağı"}], dogru: A, aciklama: "Nemle şişen tahta dişliyi sıkıştırmıştır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 3, dayanak: "Baykuş, “orman uyandı” sözünün {kelime:hr051_mecaz} olduğunu söyledi.", metin: "“Mecaz” sözcüğü bu olayda hangi kullanımı anlatır?", secenekler: [{id: A, metin: "Kesin sayılarla yapılan bir ölçüm"}, {id: B, metin: "Kapıya asılan gizli işaret"}, {id: C, metin: "Gerçek anlamının dışında kullanım"}, {id: D, metin: "Resmî yazıyla yapılan sözleşme"}], dogru: C, aciklama: "“Orman uyandı” sözü gerçek anlamının dışında, benzetmeli kullanılmıştır."}
deyim_cumleleri:
  hr051_kulaktan_kulaga: "Mevsimlerin karıştığı haberi kulaktan kulağa yayıldı."
---
@omurga
Orman saatinin uzun kolu sonbahar yaprağında durmuştu. Saat, büyük meşenin gövdesine asılmış yuvarlak bir tahta levhaydı. Üzerinde sayıların yerine dört mevsimin simgeleri bulunuyordu. Kırlangıçlar güneye doğru uçuş hazırlığı yaparken dere kenarında beyaz çiçekler açmıştı. Sincap Mavi, “Biri mevsimleri birbirine karıştırdı,” diye bağırdı. Sözü duyan tavşan komşusuna, tavşan da kirpiye seslendi. [[deyim:hr051_kulaktan_kulaga]]

{kahraman}, orman okulunun avlusuna vardığında herkes saatin altında toplanmıştı. Bir kirpi saatin yeniden dönmesini bekliyor, küçük bir serçe çiçeklerin gerçekten açıp açmadığını kontrol ediyordu. Baykuş Usta kulaklarını dikip herkesi dinledi. Haber çoktan en uzak kovuğa ulaşmıştı.

Sincap, çiçeklerin görülmesini bir işaret sayıyordu. “Saat sonbaharda kaldı diye bütün ağaçlar şaşırdı,” dedi. {kahraman} yere eğilip çiçeğin sapını inceledi. Sap sağlamdı; yakınında ılık suyun aktığı küçük bir kaynak vardı. Baykuş, uçan kuşların {kelime:hr051_goc} hazırlığını işaret etti. “Aynı anda iki farklı olay görüyoruz,” dedi. {kahraman}, saatle kaynak arasındaki uzaklığı ölçmek için avludaki ipi aldı.
---
@omurga
Ormanın en yaşlı kaplumbağası, saatin altındaki taşta duran bir sepet gösterdi. Sepetin içinde önceki mevsimlerden toplanmış yaprak örnekleri vardı. Sarı bir yaprak neredeyse kâğıt gibi kurumuştu; yeşil olanı ise hâlâ esnekti. {kahraman} bunları saatin çevresindeki ağaçların yapraklarıyla karşılaştırdı. Kırlangıçlar yükselirken uçuş yönüne savrulan yapraklar da rüzgârın değiştiğini gösteriyordu.

Kuşlar, uçuş kararını saatin koluna değil rüzgâra ve yiyeceğe göre veriyordu. Sürünün öncüsü, bu sabah dere boyunca daha az böcek gördüklerini söyledi. Kırlangıçlar dallardaki yaprakların sararmasına da bakmıştı. {kahraman}, duyduklarını küçük defterine sırayla yazdı. Saatin durmuş olması başka, kuşların uçmaya hazırlanması başka olaydı.

Derenin kenarındaki çiçekler saatten uzaktaydı. Toprağa yakın bir yerde sıcak su kabarcıkları yükseliyor, suyun üstünde ince bir buğu oluşuyordu. Tavşan, “Demek bütün orman ısındı,” dedi. {kahraman}, kaynağın hemen ilerisindeki toprağa dokundu; orası soğuktu. İki noktaya da birer tahta çubuk diktiler. Kaynağın yanındaki çiçekler açıktı, uzak çubuğun dibinde ise yalnız tomurcuk bulunuyordu.

Baykuş, gözlemleri yazdığı kâğıdı saat levhasına astı. Sincap kâğıdı okurken gözlerini büyüttü. “Çiçekler yalnız sıcak suyun yanında açmış!” dedi. {kahraman} sırtını meşe gövdesine yasladı; saatten hafif bir gıcırtı geliyordu. Sesi duyan kirpi, kulaklarını gövdeye yaklaştırdı. Gıcırtı her rüzgâr esişinde tekrarlanıyor, sonra birden kesiliyordu.
---
@omurga
Kirpi, saatin altındaki küçük tahta kapağı gösterdi. Kapağın içinden dişlilerin bir bölümü görünüyordu. Baykuş, saat sahibinin bıraktığı anahtarı getirip kapağı açtı. {kelime:hr051_nem} yüzünden şişen tahta parçası dişlinin arasına sıkışmıştı. Parçanın üstünde ince su damlacıkları vardı. {kahraman}, nem sözcüğünü not defterine yazarken Baykuş, yağıştan sonra ahşabın su alıp genişleyebileceğini anlattı.

Sincap hemen parçayı çekmek istedi. Baykuş elini durdurdu. “Dişliyi zedeleyebiliriz,” dedi. İnce bir tahta kamayı gevşetip küçük parçayı kenara aldı. Saatin kolu bir anda dönmedi; çünkü yay gerginliğini yitirmişti. Kirpi, saati kurmak için kullanılan pirinç anahtarı buldu. Usta, anahtarı çevirmeye hazırlanırken {kahraman} eski tahta parçanın nereye takıldığını bir çizimle kaydetti.

Tam o sırada ağaçtan bir yaprak düşüp saatin önüne kondu. Sincap, “Orman uyandı!” diye seslendi. Baykuş, “orman uyandı” sözünün {kelime:hr051_mecaz} olduğunu söyledi. Tavşan güldü; meşenin gözlerini açıp esnediğini hayal etmişti. Usta yayı yavaşça çevirdi. Saatin içinden üç düzenli tıkırtı duyuldu, fakat ibre bir yaprak kadar ilerleyip yeniden durdu.
---
@omurga
Tavşan, saatin sesini duyabilmek için yerdeki kuru dalları kenara taşıdı. Birkaç sincap meşe gövdesine tırmanıp dallarda beklemeye başladı. Herkes sessizleşince mekanizmanın içindeki ince sürtünme sesi daha açık işitildi. Kirpi sesin kapağın alt bölümünden geldiğini söyledi; {kahraman} çizimini bu bölgeyi de gösterecek biçimde genişletti.

“Bir yerde daha sürtünüyor,” dedi Baykuş. {kahraman}, ilk çizimde işaretlediği dişliye baktı. Tahta kıymıklarından biri alttaki küçük yuvada kalmıştı. Usta kıymığı yumuşak bir fırçayla çıkardı. Bu kez saat kurulduğunda kol sonbahar yaprağından kış simgesine doğru ağır ağır yürüdü. Meşe gövdesine yaslanan çocuklar, düzgün tıkırtıyı işitince gülümsedi.

Sincap yine çiçeklere baktı. “Saat düzeldi ama bunlar hâlâ burada,” dedi. Kaynağın çevresindeki buğu yerinde duruyordu. Kırlangıçların öncüsü son kez su içmek için dereye indi. Sonra sürü, ağaçların üzerinden dönerek yükseldi. Saatin kolu kendi ritmiyle ilerliyor, kuşlar rüzgârdaki uygun anı kolluyordu.

{kahraman}, defterindeki üç çizime göz gezdirdi: çiçeklerin yeri, nemli tahta parçası ve kuşların uçuş yönü. Sincap ilk sayfanın köşesine kocaman bir saat resmi yaptı. Kirpi de resmin yanına küçük bir kaynak çizdi; suyunu gerçek derenin kıvrımlarına benzetmek için kâğıdı birkaç kez çevirdi.

Baykuş kapağı kapatıp saatin altına bir parça kuru örtü yerleştirdi. {kahraman} kirpiye anahtarı uzattı. Kirpi anahtarı Baykuş'un eline bıraktı; ardından yere düşen sarı yaprağı kaldırıp saatin yanındaki tahtaya iliştirdi.
