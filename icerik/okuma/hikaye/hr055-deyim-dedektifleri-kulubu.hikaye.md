---
baslik: "Deyim Dedektifleri Kulübü"
slug: "hr055-deyim-dedektifleri-kulubu"
fis_kodu: "HR-055"
tur: mizah
konu: deyim_baglam
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D14]
yetiskin_uygun: false
tanitim: "Okul duvarına on iki komik afiş asılmış. Her biri bir deyimin yanlış anlamını gösteriyor. Kim, neyi kastetti?"
durum: taslak
uretim_kaynak: chatgpt_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [okul, dostluk]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D14
  ogrenme_hedefleri:
    - {id: afis_hr055, tur: lexeme, etiket: "afiş", yuva: hr055_afis, islev: first_hint}
    - {id: sozluk_hr055, tur: lexeme, etiket: "sözlük", yuva: hr055_sozluk, islev: application}
    - {id: baglam_hr055, tur: lexeme, etiket: "bağlam", yuva: hr055_baglam, islev: application}
    - {id: deyim_hr055, tur: idiom, etiket: "Ağzı kulaklarına varmak", yuva: hr055_agzi_kulaklarina, islev: application}
    - {id: kavram_hr055, tur: concept, etiket: "Deyimin mecaz anlamı ve bağlam", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pass, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Okulun duvarına on iki {kelime:hr055_afis} asılmıştı.", metin: "Okul duvarında kaç yanlış anlamlı afiş vardır?", secenekler: [{id: A, metin: "Sekiz ayrı afiş"}, {id: B, metin: "On ayrı afiş"}, {id: C, metin: "On iki afiş"}, {id: D, metin: "Yirmi afiş"}], dogru: C, aciklama: "Afiş sayısı on ikidir."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 1, dayanak: "Kulüp, afişleri sökmeden önce her deyimin kullanıldığı cümleyi aradı.", metin: "Kulüp neden çizimleri hemen sökmemiştir?", secenekler: [{id: A, metin: "Kullanım cümlesini incelemek için"}, {id: B, metin: "Boya kurusun diye"}, {id: C, metin: "Duvarın bomboş kalmasını önlemek için"}, {id: D, metin: "Ders başlasın diye"}], dogru: A, aciklama: "Önce deyimlerin gerçek kullanımına bakarlar."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "Çizimler, deyimlerde anlatılan mecazı gerçek bir olay gibi gösteriyordu.", metin: "Yanlış çizimlerin ortak sorunu nedir?", secenekler: [{id: A, metin: "Kâğıtların köşelerinden yırtılması"}, {id: B, metin: "Afişlerin solması"}, {id: C, metin: "Yazıların silinmesi"}, {id: D, metin: "Mecazı gerçek sanmaları"}], dogru: D, aciklama: "Çizimler mecaz anlamı gerçek olay gibi sunar."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, dayanak: "Sude, {kelime:hr055_baglam} sözcüğünün yanına, cümlenin söylendiği durumu anlatan bir not düştü.", metin: "“Bağlam” sözcüğü kulüp incelemesinde neyi anlatır?", secenekler: [{id: A, metin: "Yazıdaki renkleri"}, {id: B, metin: "Sözün geçtiği durumu"}, {id: C, metin: "Resmin kâğıt boyunu"}, {id: D, metin: "Afişin duvara asıldığı yönü"}], dogru: B, aciklama: "Bağlam sözün içinde kullanıldığı durumdur."}
deyim_cumleleri:
  hr055_agzi_kulaklarina: "Afişin beğenildiğini duyan {kahraman:ilgi} ağzı kulaklarına vardı."
---
@omurga
Okulun duvarına on iki {kelime:hr055_afis} asılmıştı. Her birinde bilinen bir deyim, tuhaf bir resimle anlatılıyordu. “Pireyi deve yapmak” resminde küçücük pire, dev bir hayvana dönüşüyordu. “İpe un sermek” resminde biri çamaşır ipine avuç avuç un serpiyordu. Altıncı sınıftan {kahraman}, ilk afiş önünde güldü, üçüncüsünde durup yazıyı iki kez okudu. Resimlerin altında anlam açıklaması yoktu.

Deyim Dedektifleri Kulübü'nün dört üyesi teneffüste buluştu. {yoldas:yalin|bir arkadaş} fotoğraf çekti, Sude resimleri numaraladı, Ali de kâğıtların altındaki imzaya baktı. İmza, okulun dil gösterisi için hazırlanmış ortak çalışmaya aitti. Resimleri yapanların kim olduğu yazmıyordu. Kulüp, afişleri sökmeden önce her deyimin kullanıldığı cümleyi aradı.

Sude ilk çizimdeki pireyi işaret etti. “Birisi çok küçük bir olayı büyütürse bu söz söylenebilir,” dedi. Ali, küçük bir tartışmanın kocaman kavgaya dönüşmesini anlatan kısa bir cümle buldu. {kahraman}, resmi yeniden inceledi. Pire ile devenin yan yana çizilmesi komikti, ama açıklama olmadan yalnızca hayvanların değiştiği sanılabilirdi.

Koridordan geçen iki çocuk resme bakıp “Pire gerçekten deveye dönüşüyor mu?” diye sorunca kulüp üyeleri birbirine baktı. Gösterinin başlamasına yalnız iki gün kalmıştı.
---
@omurga
Çalışma odasına geçtiklerinde duvara aynı afişlerin küçük kopyalarını dizdiler. Ali, dijital {kelime:hr055_sozluk} ekranını açtı. Sude bir deyimin karşısındaki örnek cümleyi okudu; resimle cümle arasında belirgin bir fark vardı. “İpe un sermek”, bir işi ertelemek için bahaneler bulmak anlamında kullanılmıştı. Afişteki kişi ise gerçekten ipi unla kaplamıştı.

{kahraman}, afişin altına bir konuşma örneği yazdı: “Oyuna katılacağını söyledi ama her seferinde başka bir bahaneyle erteledi.” Ardından çizime küçük bir saat eklemeyi önerdi. {yoldas:yalin|bir arkadaş}, saatin yanına bekleyen iki çocuk çizdi. Resim artık yalnız un serpen kişiyi değil, bekletilen arkadaşları da gösteriyordu.

Sude, {kelime:hr055_baglam} sözcüğünün yanına, cümlenin söylendiği durumu anlatan bir not düştü. Ali farklı bir örnek getirdi: “Kolları sıvamak” resminde bir çocuk gerçekten gömleğinin kolunu katlıyordu. Oysa ikinci cümlede herkes zor bir işe birlikte başlamıştı. Kulüp iki çizimi karşılaştırdı; birini bırakıp diğerine koşan çocukların yüz ifadeleri farklıydı.

Kapının önündeki ayak sesleri yaklaşınca üyeler konuşmayı kesti. Gösteriyi hazırlayan küçük öğrencilerden ikisi kopyalara bakmak için içeri girmişti.
---
@omurga
Küçük öğrenciler çizimleri görünce heyecanla açıklama yaptı. “Pireyi deve yapmak resmi en komiği,” dedi biri. Diğeri, öğretmenlerinin komik görseller istediğini söyledi. {kahraman} resmin kenarındaki boş alanı gösterdi. “Komiklik kalsın, altına kullanılan anlamı da yazalım,” dedi. Küçük öğrenciler öneriyi beğendi; fakat bütün afişlere yeni yazı eklemek için fazla zamanları olmadığını düşündüler.

Kulüp, on iki afişi üç gruba ayırdı. İlk grupta anlamı kolayca gösterilebilecek deyimler, ikincide ek cümle isteyecek olanlar, üçüncüde ise resmin baştan değişmesi gerekenler vardı. Çizimler, deyimlerde anlatılan mecazı gerçek bir olay gibi gösteriyordu. Sude özellikle üçüncü gruptaki “Dili tutulmak” afişini kaldırdı. Resimde bir çocuğun dili gerçekten düğümlenmişti; konuşamayan çocuğun şaşkın yüzü ise hiç görünmüyordu.

Ali tahtaya “Ağzı kulaklarına varmak” yazdı. Önce komik eski resmi çizdi: Gerçekten kulaklara kadar uzayan koca bir ağız. Sonra karnesini gören bir çocuğun gülümsediği yeni bir resim yaptı. {kahraman}, karnesini ilk kez gösterdiği günün sevincini hatırladı. {yoldas:yalin|bir arkadaş}, kulaklara uzanan komik eski resmi de atmadı, yeni resmin yanına küçücük koydu.

Saat ilerlerken masada hâlâ düzeltilmeyi bekleyen dört afiş bulunuyordu.
---
@omurga
Akşam eve gitmeden önce kulüp, düzeltilecek son dört afişi masaya yaydı. Kalem uçları aşınmış, renkli kâğıtların bir kısmı kesilmişti. Sude bütün cümleleri sırayla okurken Ali, deyimler için seçilen resimleri kontrol etti. Bir cümlenin altındaki resim başka afişten alınmıştı; yerlerini değiştirdiler. {kahraman} yapıştırıcıyı kapatıp kartları kurumaları için pencere önündeki sıraya dizdi.

Gösteri sabahı okul koridoru renkli kâğıtlarla kaplandı. Kulüp üyeleri, düzeltilen afişlerin altındaki kısa cümleleri kontrol etmek için erkenden geldi. Sude, beşinci afişte bir kelimenin yanlış yazıldığını gördü. Ali, ince uçlu kalemle harfi düzeltti. Ardından ilk afişin köşesine iki küçük kutucuk çizdi: “Resimde görünen” ve “Sözün anlattığı”.

İlk ziyaretçiler üçüncü sınıf öğrencileriydi. Pire resmini görünce gülümsediler; sonra altındaki cümleyi okuyup aralarında küçük bir tartışmanın nasıl büyüyebileceğine dair örnekler söylediler. Bir öğrenci “İpe un sermek” afişinde saatin niçin olduğunu sordu. {yoldas:yalin|bir arkadaş} çocuğa bekleyen iki kişinin çizimini gösterdi. Çocuk başını sallayıp afişin altındaki cümleyi yeniden okudu.

Öğretmen, kulübün hazırladığı açıklamaları gördüğünde kâğıtların yanına küçük bir masa yerleştirdi. Masada boş kartlar bulunuyordu. Ziyaretçiler, anlamı farklı yorumladıkları deyimleri bu kartlara yazabileceklerdi. Öğleye kadar masada renkli bir kart yığını oluştu. {kahraman}, üstte duran kartı aldı; bir çocuk “Dört gözle beklemek” deyiminde neden dört göz çizildiğini sormuştu.
---
@omurga
{kahraman}, soruyu Sude'ye gösterdi. Sude iki ayrı çizim hazırladı: birinde dört gözlü komik bir yüz, diğerinde pencereden yolu özlemle izleyen bir çocuk vardı. Ali her iki çizimin yanına aynı deyimi yazdı. Ziyaretçilere resimlerden hangisinin kullanılmak istenen anlamı daha iyi taşıdığını sordu. Çoğu ikinci çizimi seçti; birkaç kişi ise ilk resmin daha komik olduğunu söyledi.

Kulüp iki görüşü de afişe taşıdı. Sol tarafta komik yanlış yorum, sağda cümlenin içindeki anlam vardı. Resmin altına, “Yolculuktan dönecek arkadaşımı dört gözle bekledim,” cümlesi yazıldı. Küçük öğrenciler gelip afişi kendi panolarına asmak için izin istedi. [[deyim:hr055_agzi_kulaklarina]] {kahraman} kâğıdın kenarına kulübün adını değil, hep birlikte çizdikleri küçük büyüteç işaretini koydu.

Törenin sonunda duvardaki on iki afişin yanına on üçüncü bir kart asıldı. Bu kartta hiçbir deyim yazmıyordu; yalnızca boş bir konuşma balonu vardı. {yoldas:yalin|bir arkadaş}, balonun altına renkli kalemleri yerleştirdi. Koridordan geçen bir çocuk kartı görünce durdu, kalemlerden birini aldı ve kendi duyduğu bir deyimi konuşma balonuna yazdı.
