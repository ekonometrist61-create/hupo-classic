---
baslik: "Müzedeki Eksik Parça"
slug: "hr048-muzedeki-eksik-parca"
fis_kodu: "HR-048"
tur: macera
konu: kanit_miras
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D1]
yetiskin_uygun: false
tanitim: "Tabakta bir parça eksik. Hırsızlık mı, yoksa koruma çalışması mı?"
durum: taslak
uretim_kaynak: chatgpt_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [kultur_miras, gizem]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D1
  ogrenme_hedefleri:
    - {id: konservasyon_hr048, tur: lexeme, etiket: "konservasyon", yuva: hr048_konservasyon, islev: first_hint}
    - {id: restorasyon_hr048, tur: lexeme, etiket: "restorasyon", yuva: hr048_restorasyon, islev: application}
    - {id: vitrin_hr048, tur: lexeme, etiket: "vitrin", yuva: hr048_vitrin, islev: application}
    - {id: deyim_hr048, tur: idiom, etiket: "Aklını kurcalamak", yuva: hr048_gozunu_kurcalamak, islev: application}
    - {id: kavram_hr048, tur: concept, etiket: "Varsayım ile kanıt ayrımı", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: review_needed, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Müzede sergilenen seramik tabağın ortasında üçgen biçimli bir boşluk vardı.", metin: "Tabağın ortasındaki boşluk nasıl bir biçimdeydi?", secenekler: [{id: A, metin: "Dikdörtgen biçimli"}, {id: B, metin: "Üçgen biçimli"}, {id: C, metin: "Yuvarlak biçimli"}, {id: D, metin: "Yıldız biçimli"}], dogru: B, aciklama: "Metinde boşluk, tabağın ortasında üçgen biçimli olarak anlatılır."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, dayanak: "Görevli, tabağın ne zaman yer değiştirdiğini görmek için taşıma çizelgesini açtı.", metin: "Görevli neden taşıma çizelgesini açmıştır?", secenekler: [{id: A, metin: "Yeni biletleri yeniden basmak için"}, {id: B, metin: "Gezi saatini uzatmak için"}, {id: C, metin: "Şüpheliyi suçlamak için"}, {id: D, metin: "Taşınma saatini bulmak için"}], dogru: D, aciklama: "Çizelge yer değiştirme zamanını gösterir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "Bakım fişinde çıkarılan parçanın ölçüsü ve tarihi yazılıydı.", metin: "Çocukların incelemesinde hangi bilgi daha güvenilir sayılabilir?", secenekler: [{id: A, metin: "Kayıtlı bakım fişi"}, {id: B, metin: "Koridordaki söylenti"}, {id: C, metin: "Ziyaretçinin tahmini"}, {id: D, metin: "Rastgele bir yorum"}], dogru: A, aciklama: "Tarihli bakım fişi doğrulanabilir kanıttır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 3, dayanak: "Görevli, konservasyon çalışmalarının eseri bozulmaktan korumaya yönelik olduğunu söyledi.", metin: "“Konservasyon” sözcüğü bu müze sahnesinde hangi işlemi anlatır?", secenekler: [{id: A, metin: "Eserleri satmayı"}, {id: B, metin: "Tabakları boyamayı"}, {id: C, metin: "Eserleri korumayı"}, {id: D, metin: "Vitrinleri taşımayı"}], dogru: C, aciklama: "Konservasyon, eseri korumaya yönelik çalışmadır."}
deyim_cumleleri:
  hr048_gozunu_kurcalamak: "{kahraman:ilgi} aklını kurcalayan tek şey, tabağın ortasındaki boşluktu."
---
@omurga
Müzede sergilenen seramik tabağın ortasında üçgen biçimli bir boşluk vardı. {kahraman} sabahki gezi boyunca en çok bu mavi tabağı görmek istemişti. Önceki gün sergi duyurusundaki fotoğrafta, ortasındaki yıldızın bütün parçaları yerli yerindeydi. Şimdiyse yıldızın bir köşesi yoktu. Camın üzerine eğildi; {kelime:hr048_vitrin} vitrin öyle temizdi ki kendi yüzünü tabakla yan yana gördü.

“Biri parçayı almış,” dedi {yoldas:yalin|bir arkadaş}. Sesindeki kesinlik, yanında bekleyen iki ziyaretçinin ve küçük bir çocuğun başını çevirmesine yol açtı. {kahraman}, arkadaşının koluna hafifçe dokundu. “Henüz bilmiyoruz,” diye fısıldadı. Vitrinin altındaki küçük kartta, tabağın on altı parçadan bir araya getirildiği yazıyordu. Kartın bir köşesinde yeni yapıştırılmış soluk bir etiket vardı: “Koruma incelemesi sürüyor.”

Yan salondan gelen görevli, çocukların önünde durdu. “Bir şey mi arıyorsunuz?” diye sordu. {kahraman} fotoğrafı gösterip bugünkü boşluğu işaret etti. Görevli önce fotoğrafa, sonra tabağa baktı. “Dünkü bakım kayıtlarını getireyim,” dedi. Çocukları dokunulmaz şeridin gerisinde beklemeye çağırdı. Giderken vitrinin camında küçücük bir mavi iplik parçası ışıldadı; {kahraman} gördüğü şeyi defterine çizdi.
---
@omurga
Müze koridorunda, duvara asılmış başka bir tabak fotoğrafı da vardı. Bu fotoğrafta yıldızın mavi boyası daha koyu görünüyordu. {kahraman} ışığın renkleri değiştirebildiğini düşündü ve ilk fotoğrafın çekildiği yeri aradı. Müze salonunda iki ayrı pencereden gelen gün ışığı, camın üzerinde farklı yansımalar oluşturuyordu. Fotoğraflar arasında renk farkı bulunması parçanın kaybolduğunu tek başına göstermiyordu.

Görevli, tabağın ne zaman yer değiştirdiğini görmek için taşıma çizelgesini açtı. Çizelgede parçanın sabah dokuzda bakım masasına alındığı yazıyordu. “Belki biri sonradan almıştır,” dedi {yoldas:yalin|bir arkadaş}. Görevli, masaya ikinci bir dosya koydu. Dosyanın ilk sayfasında, tabağın yıldız biçimli bölümünü gösteren ayrıntılı bir çizim vardı.

{kahraman} eksik yere benzeyen şeklin çevresindeki kırmızı noktaları saydı. Tam üç nokta vardı; vitrin camının kenarında da üç küçük kırmızı işaret bulunuyordu. “Bu noktalar niçin aynı?” diye sordu. Görevli bunun işlem sırasında kullanılan yer belirleme işareti olduğunu söyledi; parça aynı yerden, kayıtlı bir işlemle çıkarılmıştı. Sonra dosyadaki tarihleri yan yana koydu. Önce fotoğraf çekilmiş, sonra eser geçici olarak bakım masasına taşınmıştı.

{yoldas:yalin|bir arkadaş}, “Demek hırsız yok,” diye atıldı. {kahraman} başını salladı ama defterindeki mavi ipliği gösterdi. “Yine de o parçaya ne olduğunu görmedik.” Görevli, koruma odasının camlı bölümüne bakmalarına izin verdi. Koridorun sonunda, içeri girenlerin eldiven giydiği küçük bir oda görünüyordu. Masadaki büyütecin yanında, tabağın desenine çok benzeyen turkuaz bir parça yatıyordu.
---
@omurga
Camın ardındaki uzman, çocukların sorusunu duyunca dosyadaki fotoğrafı onlara çevirdi. Bakım fişinde çıkarılan parçanın ölçüsü ve tarihi yazılıydı. Fotoğrafta parçanın kenarında ince bir çatlak görünüyordu; uzman, çatlağın büyümesini engellemek için parçayı geçici olarak ayırdıklarını anlattı. “Bu işin adı {kelime:hr048_konservasyon},” dedi. Görevli, konservasyon çalışmalarının eseri bozulmaktan korumaya yönelik olduğunu söyledi.

Masada küçük fırçalar, yumuşak destekler ve numaralanmış kaplar vardı. Uzman, başka bir eserin kırık kenarlarını tamamlamak için kullanılan {kelime:hr048_restorasyon} çizimlerini açtı. “Her eksik yer hemen yapıştırılmaz,” dedi. “Önce eski yüzeyin durumu incelenir.” {kahraman} camın gerisinden çatlağı daha iyi görebilmek için yana kaydı. Çizimdeki çatlak, yıldızın en ince ucuna kadar uzanıyordu.

Arkadaşı vitrindeki mavi ipliği sordu. Uzman güldü. “O iplik temizleme bezinden kalmış olabilir, ama emin olmak için bakarım.” Bir fırçanın ucuyla benzer lifleri gösterdi. {kahraman}, sayfasına iki ayrı sütun çizdi: “Gördüklerimiz” ve “Tahmin ettiklerimiz.” İpliği ilk sütuna, hırsızlık düşüncesini ikinci sütuna yazdı. Araya uzun bir çizgi çekti; bir süre ikisinin de üzerine yeni söz eklemedi.
---
@omurga
Uzman, çıkarılan parçayı geri koymadan önce çatlak kenarının büyüteçle yeniden inceleneceğini belirtti. Masanın üstündeki küçük saate bakıp inceleme için hazırladığı eldivenleri giydi. Ardından camlı pencerenin önüne, yeni fotoğrafın çekileceği beyaz zeminli levhayı yerleştirdi. Çocuklar dışarıdan izlerken levhanın üzerinde eski tabağın şekli belirginleşti.

Koruma odasından çıktıklarında az önceki küçük çocuk hâlâ tabağı izliyordu. “Hırsız bulunmuş mu?” diye sordu. {yoldas:yalin|bir arkadaş}, biraz önce yüksek sesle söylediği sözü hatırlayıp kızardı. {kahraman} çocuğa bakım fişindeki tarihi gösterdi. “Parça burada, ama çatlak yüzünden bir süre takılmayacak,” dedi. Küçük çocuk camın arkasındaki çalışma masasına gözlerini dikti.

{kahraman}, girişteki ziyaretçi defterinin yanına geldi. Bir önceki ziyaretçinin yazdığı “Yıldızın ucu nerede?” cümlesini gördü. Kendi sayfasına baktı. [[deyim:hr048_gozunu_kurcalamak]] Çizimin yanına küçük bir soru işareti koydu. Ardından gözlemlerinin tarihlerini yazdı.

Görevli, “İsterseniz yarın bakım masasındaki yeni fotoğrafı da sergileyeceğiz,” dedi. {kahraman} önce dünün fotoğrafına, sonra bugünün çizimine baktı. İki görüntü aynı tabağa aitti; aralarındaki fark, üstüne yazılan açıklamayla birlikte daha belirginleşmişti. Arkadaşı çıkışa yönelirken dönüp “İplik için de soracak mıyız?” dedi. {kahraman} başıyla onayladı, görevlinin uzattığı ince kalemi aldı ve ziyaretçi defterine iplikle ilgili sorusunu yazdı.
