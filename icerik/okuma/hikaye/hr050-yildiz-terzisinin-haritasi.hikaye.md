---
baslik: "Yıldız Terzisinin Haritası"
slug: "hr050-yildiz-terzisinin-haritasi"
fis_kodu: "HR-050"
tur: bilim
konu: gokyuzu_gozlem
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: masalsi
izinli_turler: [ben, arkadas, hayali]
deger_anahtarlari: [D6, D3]
yetiskin_uygun: false
tanitim: "Gökyüzünden bir düğme düşer. Yıldız Terzisi haritasını yeniden çizebilecek mi?"
durum: taslak
uretim_kaynak: chatgpt_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, kesif]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D3
  ogrenme_hedefleri:
    - {id: teleskop_hr050, tur: lexeme, etiket: "teleskop", yuva: hr050_teleskop, islev: first_hint}
    - {id: pusula_hr050, tur: lexeme, etiket: "pusula", yuva: hr050_pusula, islev: application}
    - {id: takimyildizi_hr050, tur: lexeme, etiket: "takımyıldızı", yuva: hr050_takimyildizi, islev: application}
    - {id: deyim_hr050, tur: idiom, etiket: "Kafası karışmak", yuva: hr050_kafasi_karismak, islev: application}
    - {id: kavram_hr050, tur: concept, etiket: "Gözlem ile yorum ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: review_needed, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Gece yarısı gökten gümüş bir düğme düştü.", metin: "Yıldız Terzisi’nin haritasından ne kopmuştur?", secenekler: [{id: A, metin: "Mavi bir ip"}, {id: B, metin: "Gümüş bir düğme"}, {id: C, metin: "Kırmızı bir taş"}, {id: D, metin: "Yeşil bir yaprak"}], dogru: B, aciklama: "Gökyüzünden düşen nesne gümüş düğmedir."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, dayanak: "{kahraman}, haritadaki çizgilerin yıldızları birleştiren hayalî yollar olduğunu defterine yazdı.", metin: "Haritadaki çizgiler gökyüzünde gerçekte neyi gösteriyordu?", secenekler: [{id: A, metin: "Gökyüzüne gerilmiş gerçek gümüş iplikleri"}, {id: B, metin: "Rüzgârın bahçede estiği farklı yönleri"}, {id: C, metin: "Düğmenin gökten düştüğü uzun patikayı"}, {id: D, metin: "Yıldızları birleştiren hayalî yolları"}], dogru: D, aciklama: "Yıldızlar arasındaki çizgiler gerçek ip değil, hayalî yollardır."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 2, dayanak: "Terzi, çizimdeki boşluğu bulmak için teleskopla yıldızların konumunu karşılaştırdı.", metin: "Yıldız Terzisi kayıp noktayı saptamak için neye başvurmuştur?", secenekler: [{id: A, metin: "Gökyüzü gözlemine"}, {id: B, metin: "Renkli kumaşlara"}, {id: C, metin: "Eski masal kitabına"}, {id: D, metin: "Saatin çan sesine"}], dogru: A, aciklama: "Yer tespitinde gökyüzü gözlemi kullanılır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, dayanak: "Masadaki {kelime:hr050_pusula} kuzeyi gösterince haritayı o yöne çevirdiler.", metin: "“Pusula” bu sahnede hangi işe yaramaktadır?", secenekler: [{id: A, metin: "Parlaklık ölçmeye"}, {id: B, metin: "Sesleri kaydetmeye"}, {id: C, metin: "Yönü belirlemeye"}, {id: D, metin: "Düğme dikmeye"}], dogru: C, aciklama: "Pusula yön belirlemek için kullanılır."}
deyim_cumleleri:
  hr050_kafasi_karismak: "Parlayan çiğ taneleri arasında {yoldas:ilgi|bir arkadaşın} kafası karışmıştı."
---
@omurga
Gece yarısı gökten gümüş bir düğme düştü. {kahraman}, bahçedeki taş masanın üstüne çarpan küçücük sesi duyunca pencereyi açtı. Düğme, soğuk bir ay ışığı gibi parlıyordu. Arkasında dört delik, önünde de ince bir yıldız deseni vardı. Üst kattaki odada yaşayan {yoldas:yalin|bir arkadaş} da ışığı görüp bahçeye indi. Tam düğmeyi kaldıracakları sırada bir rulo kâğıt masanın üstüne süzüldü.

Kâğıt, göğün haritasına benziyordu. Bazı noktaların çevresinde gümüş iplikten kıvrımlar vardı; bir noktaysa boş kalmıştı. Kâğıdın altından minik, şapkalı bir adam çıktı. Kendini Yıldız Terzisi diye tanıttı. “Haritamın düğmesi kopunca desen eksildi,” dedi. “Yanlış yere dikersem bütün harita kayar.” {kahraman}, terzinin elindeki {kelime:hr050_teleskop} teleskop çantasını gördü.

Terzi, kâğıdı taş masaya serdi. “Düğmenin düştüğü yeri biliyorum, fakat ait olduğu noktayı bilmiyorum.” {yoldas:yalin|bir arkadaş}, en parlak yıldızı gösterdi. “Buraya diksek olur.” {kahraman} ışığa baktı; en parlak nokta ötekilerden çok uzaktaydı. “Önce yönümüzü bulalım,” dedi. Terzi ceketinin cebinden küçük bir pusula çıkarıp masanın kenarına koydu.
---
@omurga
Yıldız Terzisi, masanın köşesine üç ince renkli iplik koydu. Her iplik ayrı bir yıldızın kâğıttaki yerini işaretlemek içindi. Kırmızı iplik, doğu tarafındaki noktaya; mavi iplik, göğün tepesindeki noktaya uzandı. Fakat üçüncü ipliği bağlayacağı yer belirsiz kaldı. Terzi ipliğin ucunu parmağına doladı, gözlerini kısarak başını yukarı kaldırdı.

Masadaki {kelime:hr050_pusula} kuzeyi gösterince haritayı o yöne çevirdiler. {kahraman}, gökyüzünün geniş bir bölümünü kâğıtla karşılaştırdı. Üç parlak yıldız neredeyse düz bir sıra oluşturuyor, dördüncü yıldız onların üstünde duruyordu. Kâğıtta aynı dört nokta işaretlenmişti, fakat aralarındaki gümüş dikişler birbirinden kopmuştu. Terzi, kayıp düğmeyi önce dördüncü noktanın yanına tuttu ama düğme ışıldamadı.

“Belki düğmenin parlaması başka şeye bağlıdır,” dedi {kahraman}. Yıldız Terzisi küçük teleskobunu kurdu. Çocuklar sırayla baktı. Gökyüzündeki şeklin yanında çok sönük bir yıldız daha vardı; çıplak gözle seçilmiyordu. Terzi, çizimdeki boşluğu bulmak için teleskopla yıldızların konumunu karşılaştırdı. Haritanın kenarına yeni bir nokta işaretledi.

{yoldas:yalin|bir arkadaş} kâğıttaki çizgileri parmağıyla izledi. “Bu ipler gerçekten yıldızların arasında mı?” Terzi, çizgilerin yalnızca hayalî olduğunu söyledi. {kahraman}, haritadaki çizgilerin yıldızları birleştiren hayalî yollar olduğunu defterine yazdı. Çocuk, şeklin yanına {kelime:hr050_takimyildizi} sözcüğünü de ekledi. Terzi, boş noktayı gümüş iğnesiyle çevreledi ama henüz dikişe başlamadı.
---
@omurga
Birden rüzgâr çıktı. Haritanın bir kenarı havalandı; gümüş düğme masadan yuvarlanıp çiçeklerin arasına düştü. {kahraman} diz çöküp aradı. Çimlerin üzerinde çok sayıda çiğ tanesi vardı; her biri bir düğme gibi parlıyordu. [[deyim:hr050_kafasi_karismak]] {yoldas:yalin|bir arkadaş} sayısız parlak nokta arasında hangisinin düğme olduğunu bir türlü seçemiyordu. Terzi, kâğıdı düzleştirip büyütecini uzattı.

{kahraman} çiğ tanelerine dokunmadan bakınca, birinin altında dört küçük delik seçti. Düğmeyi nazikçe kaldırıp masaya getirdi. Terzi bu kez dikişten önce haritanın kenarındaki ay işaretini gökyüzündeki Ay'ın konumuyla karşılaştırdı. İşaret, harita döndürülünce yerinden sapmıştı. Pusulaya yeniden baktılar, sonra kâğıdı doğru yöne çevirdiler.

Düğmenin konması gereken boşluk artık üç yıldızın hemen altındaydı. Yalnız kâğıtta bu noktanın çevresindeki çizgi kesik kesikti. {kahraman}, defterine bir gözlem daha ekledi: “Dört delikli düğme yalnızca bu kesik çizgiye sığıyor.” Terzi iğneyi kaldırdı, gümüş ipliğin ucunu düğmenin deliğinden geçirdi. Tam ilk dikişi atarken uzaktan gelen saat çanı gecenin sessizliğini yardı.
---
@omurga
Rüzgâr dinip bahçeye sessizlik çökünce taş masanın üzerindeki iplikler birbirine karışmadı. {yoldas:yalin|bir arkadaş}, ay ışığında yansıyan çizgilerin duvara düştüğünü gördü. Parmaklarıyla gölgeyi takip etti; kâğıttaki desenle duvardaki desen aynı açıda değildi. Terzi masanın ayaklarından birini küçük bir taşla yükselterek kâğıdı düzleştirdi.

Saat çanı sustuğunda düğmenin etrafındaki çizgiler hafifçe titreşti. Terzi ipliği çekip düğmeyi sabitledi; haritadaki kesik yollar ince bir ışıkla birleşti. Ancak kâğıdın sağ alt köşesi hâlâ karanlıktı. {yoldas:yalin|bir arkadaş}, terzinin yüzüne baktı. “Demek işimiz bitmedi.” Terzi ışığı elinin tersiyle örttü. Karanlık köşede daha önce göremedikleri çok küçük noktalar belirdi.

{kahraman}, teleskopla gökyüzünün aynı bölümüne yeniden baktı. Sönük noktalar orada da vardı. Terzi, haritaya bütün yıldızların tek tek işlenmesinin yıllar süreceğini söyledi. “Ben yalnızca bu gecenin desenini tamamlamak istemiştim.” Çocuk, defterindeki iki çizimi yan yana koydu: biri ilk gördüğü şekil, öteki yeni işaretlenen yıldızlar. Terzi çizimlerin tarihine bakıp eski haritaya minicik bir tarih daha attı.

{yoldas:yalin|bir arkadaş} düğmenin düşerken çıkardığı sesi taklit edince üçü birden güldü. Harita kâğıdının üstündeki ışık, terzinin küçücük makarasına geri dolmaya başladı. Terzi şapkasını düzeltip kâğıdı rulo yaptı. Kapanırken haritanın son çizgisi bir an bahçe duvarına yansıdı. {kahraman}, duvarda beliren yeni noktayı defterine çizip yanına o gecenin saatini yazdı.
