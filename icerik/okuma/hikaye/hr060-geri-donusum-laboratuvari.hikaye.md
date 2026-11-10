---
baslik: "Geri Dönüşüm Laboratuvarı"
slug: "hr060-geri-donusum-laboratuvari"
fis_kodu: "HR-060"
tur: bilim
konu: atik_ayristirma
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D18]
yetiskin_uygun: false
tanitim: "Mavi kutuya muz kabuğu, kâğıt kutusuna plastik şişe. Doğru ayrıştırmak neden bu kadar zor?"
durum: taslak
uretim_kaynak: chatgpt_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [doga, okul]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D18
  ogrenme_hedefleri:
    - {id: ayristirma_hr060, tur: lexeme, etiket: "ayrıştırma", yuva: hr060_ayristirma, islev: first_hint}
    - {id: geri_donusum_hr060, tur: lexeme, etiket: "geri dönüşüm", yuva: hr060_geri_donusum, islev: application}
    - {id: ambalaj_hr060, tur: lexeme, etiket: "ambalaj", yuva: hr060_ambalaj, islev: application}
    - {id: kavram_hr060, tur: concept, etiket: "Atık azaltma ve yeniden kullanım", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: review_needed, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Mavi kutudan muz kabuğu çıktı.", metin: "Okuldaki yanlış kutuya ne atılmıştır?", secenekler: [{id: A, metin: "Cam kavanoz"}, {id: B, metin: "Muz kabuğu"}, {id: C, metin: "Kuru yaprak"}, {id: D, metin: "Metal kaşık"}], dogru: B, aciklama: "Mavi kutuda muz kabuğu vardır."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, dayanak: "Görevli, işaretleri aceleyle taktığını ve yerlerini karıştırmış olabileceğini belirtti.", metin: "Kutulardaki karışıklığın nedeni neydi?", secenekler: [{id: A, metin: "Kutuların renkleri zamanla tamamen solmuştu"}, {id: B, metin: "Okulda kutu sayısı çok az olmuştu"}, {id: C, metin: "Koridor duvarları yeni boyanmıştı"}, {id: D, metin: "İşaretler yanlış kutulara takılmıştı"}], dogru: D, aciklama: "Görevli işaretleri aceleyle taktığını söyledi; bu yüzden işaretler yanlış kutulara takılmıştı."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "Yeniden kullanılan kavanoz sayesinde o gün yeni bir saklama kabı atılmadı.", metin: "Temiz kavanozun yeniden kullanılması hangi sonucu doğurdu?", secenekler: [{id: A, metin: "O gün yeni bir saklama kabı atılmadı"}, {id: B, metin: "Kutular okul koridorundan tamamen kaldırıldı"}, {id: C, metin: "Bütün kirli atıklar ayrı toplandı"}, {id: D, metin: "Koridordaki ambalajlar daha da çoğaldı"}], dogru: A, aciklama: "Kavanoz yeniden kullanıldığı için yeni bir saklama kabı atık olmadı."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, dayanak: "Temiz ambalaj, ürünü saran dış malzeme olarak tanımlandı.", metin: "“Ambalaj” bu hikâyede neyi anlatmaktadır?", secenekler: [{id: A, metin: "Paketin içindeki yiyeceği"}, {id: B, metin: "Atık kutusunun kapağını"}, {id: C, metin: "Ürünü saran dış malzemeyi"}, {id: D, metin: "Okulun toplama listesini"}], dogru: C, aciklama: "Ambalaj ürünü saran dış malzemedir."}
---
@omurga
Mavi kutudan muz kabuğu çıktı. Yanındaki kâğıt kutusunun ağzında ise iki plastik şişe sıkışmıştı. {kahraman}, okul koridorundaki kutulara bakıp şaşırdı. Kutular yeni alınmıştı; üzerlerinde farklı renklerde işaretler vardı. Fakat öğle arasında herkes elindeki şeyi en yakın kutuya atıyordu. {yoldas:yalin|bir arkadaş}, kâğıtların arasında ıslanmış bir peçete buldu.

Çevre kulübü, kutuların önünde küçük bir inceleme masası kurdu. Öğretmen, atıkları çıplak elle karıştırmamalarını, yalnız temiz örneklerle çalışmalarını istedi. {kahraman}, {kelime:hr060_ayristirma} sözcüğünü inceleme kâğıdının başlığına yazdı. Her kutunun üzerinde hangi tür malzemenin toplanacağı açıklanmıştı, fakat işaretlerin bir bölümü yanlış kutulara takılmıştı.

Kulüp üyeleri, temiz örnekleri masaya dizip farklı kutularla eşleştirdi. Plastik şişe, cam kavanoz, karton kutu ve metal kap ayrı ayrı duruyordu. Muz kabuğuna ise masada yer verilmedi; organik atık için hazırlanan kabın gösterge kartına resmini çizdiler. {kahraman}, her kabın üstüne yazılacak kısa sözcükleri belirledi. Ardından okulun hangi malzemeleri ayrı topladığını gösteren listeyi incelediler.
---
@omurga
Kulüp sabah topladığı kâğıtların bir kısmını yere sererek işaret örnekleri hazırladı. Her resmin altında kısa bir kelime bulunuyordu. Ancak küçük resimlerin bazılarında malzeme türü uzaktan seçilemiyordu. {kahraman} iki adım geri gidip resimlere baktı. Kâğıt için sayfa, cam için kavanoz, metal için küçük bir kutu resmi çizdiler. Öğretmen bu çizimleri koridorda kullanmadan önce okulun toplama listesiyle karşılaştırdı.

Çocuklar, kutuların üzerindeki yazıların birbirine karıştırıldığını gördü. Kâğıt kutusunun üstünde plastik şişe resmi, plastik kutusunun üzerinde ise buruşturulmuş kâğıt çizimi vardı. {yoldas:yalin|bir arkadaş}, yanlış resimlerin yeni kutular kurulurken yerlerinin değişmiş olabileceğini söyledi. Kulüp bu tahmini not etti, sonra kutuları yerleştiren görevliye sordu. Görevli, işaretleri aceleyle taktığını ve yerlerini karıştırmış olabileceğini belirtti.

Masadaki temiz {kelime:hr060_ambalaj} örneklerinden biri karton, biri plastikti. Temiz ambalaj, ürünü saran dış malzeme olarak tanımlandı. {kahraman}, iki örneği aynı anda kaldırdı. “Ürünü koruyan malzeme farklı türde olabiliyor,” dedi. Öğretmen, okulun yerel toplama uygulamasına göre doğru yönlendirme yapacaklarını hatırlattı.

{yoldas:yalin|bir arkadaş}, eski bir yoğurt kabını eline aldı. Kabın içi tertemizdi; daha önce küçük boya fırçalarını saklamak için kullanılmıştı. “Bu mutlaka atılacak mı?” diye sordu. {kahraman}, masadaki küçük kavanozu gösterdi. Önce atık oluşmasını azaltmanın başka yollarını tartıştılar; işaretleri düzeltmek için hazırladıkları kâğıtlara “yeniden kullan” başlığı da eklediler.
---
@omurga
Kulüp koridorda bir deneme alanı hazırladı. Bir tarafta yeniden kullanılabilecek temiz kaplar, diğer tarafta malzeme türlerine göre ayrılmış örnekler vardı. Öğrenciler sırayla masaya gelip hangi işareti izleyeceklerini seçti. İlk iki öğrenci kâğıt resmiyle karton kutuyu doğru eşleştirdi; üçüncü öğrenci parlak bir paketi plastik kutusuna götürdü. {kahraman}, paketin üzerinde birden fazla malzeme bulunduğunu gösterdi.

Okulun {kelime:hr060_geri_donusum} çalışmasında bütün ambalajların aynı biçimde işlenmediği anlatılıyordu. {kahraman}, görevlinin getirdiği toplama çizelgesindeki işaretleri örneklere aktardı. Kimi malzemeler ayrı toplanıyor, kimi kirli nesneler ise bu kutulara uygun görülmüyordu. Çocuklar açıklama kartlarına basit resimler ekledi.

{yoldas:yalin|bir arkadaş}, boya fırçalarını temiz kavanoza koyup masaya bıraktı. Yeniden kullanılan kavanoz sayesinde o gün yeni bir saklama kabı atılmadı. Kulüp, bu kavanozun yanına “Tekrar kullanılabilir” yazılı küçük bir kart koydu. {kahraman} kartları önce uzak mesafeden okudu; bazı harfler seçilmiyordu. Kalın uçlu kalemle başlıkları büyüttü. Koridordan geçen öğrenciler yeni işaretlere bakıp kutuların önünde durmaya başladı.
---
@omurga
Koridorda yeni işaretleri gören iki öğrenci yan yana durup küçük bir kutuyu inceledi. Kutunun dışı karton, içindeki koruyucu bölüm ise plastikti. {yoldas:yalin|bir arkadaş} farklı parçaları ayırıp ayıramayacaklarını kontrol etmeyi önerdi. Parçalar kolayca ayrılınca iki malzemeyi ayrı örnek kutularına koydular. {kahraman}, yeni bir görsel hazırlamak için bu iki parçayı masaya yan yana dizdi.

Ertesi gün öğle arasında kulüp üyeleri kutuların durumunu yeniden kontrol etti. Kâğıt kutusunda artık daha fazla temiz karton vardı, ancak bir köşede içi dolu içecek bardağı duruyordu. {kahraman} bunu görevliye gösterdi; kirli atığı onun güvenli biçimde ayırmasını beklediler. {yoldas:yalin|bir arkadaş} bardağın üzerindeki açıklama kartının ne kadar uzaktan okunabildiğine baktı.

Öğrenciler boş kaplarla dolu yeniden kullanım masasını da ziyaret etti. Bir çocuk, küçük metal kutuyu kalemlerini saklamak için almak istedi. Kutunun kenarı pürüzlüydü; görevli güvenli olmadığını söyleyince çocuk başka bir kap seçti. {kahraman}, kutunun yanındaki uyarı işaretini yeniden çizdi. Çocuklar bu kez sivri kenarları olan örnekleri sergileme masasından kaldırdı.

Günün sonunda yeni işaretlerin yanına küçük bir soru kutusu koydular. Hangi malzemenin nereye gideceğinden emin olmayanlar sorularını oraya bırakabilecekti. Kutuda ilk olarak parlak kâğıtla ilgili bir soru belirdi. {kahraman} soruyu aldı, karşılaştırma için toplama listesini açtı.

Koridor boşalırken {yoldas:yalin|bir arkadaş} temiz kartonları düzenledi. {kahraman} yeni soru kartını listede işaretlenen malzemenin yanına yerleştirdi, sonra panodaki kopmuş eski simgeyi çıkarıp yerine yenisini yapıştırdı.
