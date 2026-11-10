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
uretim_kaynak: chatgpt_taslak
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
  denetim: {ajan_a: pass, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Robot kahvaltı masasına üç çift çorap bıraktı.", metin: "Ev robotu kahvaltı masasına hangi eşyayı getirmiştir?", secenekler: [{id: A, metin: "Peynirli tost"}, {id: B, metin: "Sıcak çorba"}, {id: C, metin: "Üç çift çorap"}, {id: D, metin: "Bir kâse meyve"}], dogru: C, aciklama: "Getirilen nesneler üç çift çoraptır."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 1, dayanak: "Robot, iki farklı ses kaydını tek komut sanmıştı.", metin: "Robotun yanlış eşyayı getirmesinde ne etkili oldu?", secenekler: [{id: A, metin: "İki ayrı kaydın birleşmesi"}, {id: B, metin: "Robotun kolundaki arıza"}, {id: C, metin: "Mikrofonların fişten çıkması"}, {id: D, metin: "Ekmeğin masadan düşmesi"}], dogru: A, aciklama: "Birleştirilen kayıtlar yanlış komut üretir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "{kahraman} ve arkadaşı, robotun duyduğu komutu önce ekranda göstermesini sağladı.", metin: "Robottan yeniden görev istemeden önce ne yapıldı?", secenekler: [{id: A, metin: "Robotun kol parçasını değiştirdiler"}, {id: B, metin: "Mutfaktaki mikrofonu çıkarıp sakladılar"}, {id: C, metin: "Mutfağın tüm ışıklarını kapattılar"}, {id: D, metin: "Komutu ekranda görüp onayladılar"}], dogru: D, aciklama: "Robotun duyduğu komut önce ekranda gösterildi ve onaylandı."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 1, dayanak: "Ekrandaki algoritma, robotun izleyeceği işlem adımlarını gösteriyordu.", metin: "“Algoritma” sözcüğü bu olayda neyi belirtir?", secenekler: [{id: A, metin: "Robotun süslerini"}, {id: B, metin: "İşlem adımlarını"}, {id: C, metin: "Odaların rengini"}, {id: D, metin: "Günlük hava durumunu"}], dogru: B, aciklama: "Algoritma görev için işlem adımlarıdır."}
---
@omurga
Robot kahvaltı masasına üç çift çorap bıraktı. “İstenen kahvaltı hazır,” dedi ve metal kollarını iki yana açtı. {kahraman} bir an çoraplara baktı, sonra gülmeye başladı. Evdeki yardımcı robot ARO'dan peynirli tost istenmişti. Sepetinde ekmek, peynir ve tabak yerine kalın yün çoraplar bulunuyordu. {yoldas:yalin|bir arkadaş}, robotun ekranındaki küçük uyarı işaretini gösterdi.

Ekranda şöyle yazıyordu: “İşlem tamamlandı. Güven: düşük.” {kahraman}, bunun nedenini görmek için kayıt bölümünü açtı. Ekranda {kelime:hr062_algoritma} başlığı altında birkaç adım sıralanmıştı: sesi al, sözcükleri ayır, eşya seç, getir. Ekrandaki algoritma, robotun izleyeceği işlem adımlarını gösteriyordu. Fakat adımların yanındaki ses parçaları birbirine karışmış gibiydi.

Sabah mutfakta iki kişi aynı anda konuşmuştu. Biri “tost hazırla” demiş, diğeri koridordan “çorapları getir” diye seslenmişti. Robot, iki farklı ses kaydını tek komut sanmıştı. {kahraman} kayıt çizgisini dinledi; ilk cümlenin sonu ile ikinci cümlenin başı aynı yerde birleşmişti. ARO bu birleşik kaydı uygulamış, yalnızca eşyaları seçerken de kararsız kaldığını bildirmişti.
---
@omurga
{yoldas:yalin|bir arkadaş}, robotu yeniden mutfağa göndermek istedi. {kahraman} önce kaydı durdurdu. “Aynı şeyi tekrar duyarsa başka çorap da getirebilir,” dedi. Robotun üzerinde iki küçük mikrofon vardı; mutfaktaki sesleri iki yönden alıyordu. Birinin önüne yanlışlıkla bırakılmış kâğıt poşet sürtünüyordu. Kâğıt hışırdadıkça bazı sözcükler boğuklaşıyordu.

ARO'nun ekranında bir sözlük bölümü de vardı. {yoldas:yalin|bir arkadaş}, robotun “yüz” gibi aynı sesli sözcükleri karıştırmış olabileceğini düşündü. {kahraman}, sözlükteki {kelime:hr062_sesteslik} örneğini açtı. “Yüz” sözcüğünün insanın yüzü, yüz sayısı ve yüzme eylemiyle ilgili farklı anlamları gösteriliyordu. Kaydı baştan sona taradılar; böyle bir sözcük yoktu. Sorun, iki ayrı cümlenin yanlış birleştirilmesiydi. {kahraman} ekrana “Birleşen kayıt” başlıklı bir not ekledi.

{yoldas:yalin|bir arkadaş}, robotun kollarının ucundaki kavrama parçasını inceledi. Çorapları masaya düzgünce koymuştu; getirme hareketinde bir arıza görünmüyordu. {kahraman} gülerek “Robotun kolları iyi, ama kulağı acele etmiş,” dedi. ARO, “Kulak birimi bulunamadı,” cevabını verince ikisi yeniden güldü.
---
@omurga
Kahvaltı masasının ucunda ince bir defter duruyordu. {kahraman} defterin ilk sayfasına robotun getirdiği nesneleri çizdi: çorap, tabak, ekmek ve peynir. Yanlarına hangi komutun hangi eşyayı getirmesi beklendiğini yazdı. {yoldas:yalin|bir arkadaş}, iki sesin aynı anda kaydedildiği saniyeyi işaretledi. Ekrandaki ses çizgileri, üst üste gelince tek uzun dalga gibi görünüyordu. Sonra aynı kayıtları iki farklı renkle ayırdılar.

{kahraman} ve arkadaşı, robotun duyduğu komutu önce ekranda göstermesini sağladı. Yeni {kelime:hr062_dogrulama} adımında ARO, bir işi yapmadan önce hangi görevi duyduğunu soruyordu. {kahraman} yavaşça “Bir dilim peynirli tost hazırla,” dedi. Robotun ekranına aynı cümle yazıldı. {yoldas:yalin|bir arkadaş}, “Onayla,” düğmesine dokundu. ARO bu kez çorap sepetine değil, mutfak tezgâhındaki ekmek kutusuna yöneldi.

Robot tost hazırlamak için kullanılabilir bir mutfak aleti değildi; yalnızca gerekli malzemeleri güvenle taşıyabiliyordu. Bu yüzden ARO ekmek, peynir ve tabağı masaya getirdi. {kahraman}, sıcak aleti bir yetişkinin kullanacağını söyledi. Robotun ekranında “Malzemeler getirildi” yazısı belirdi. Ardından daha önceki yanlış görevin kaydı da göründü.

{kahraman}, eski kaydı silmek yerine yanında küçük bir uyarı işareti bıraktı. Ekranın üst kısmında ilk ses parçası, altında ikinci ses parçası gösteriliyordu. {yoldas:yalin|bir arkadaş}, bu iki parçayı ayrı ayrı dinleyince seslerin farklı kişilerden geldiğini daha rahat seçti. Yeni işlem adımının nerede devreye girdiğini bulup deftere yazdılar.
---
@omurga
ARO kısa süreliğine kendi kaydını açtı. Ses parçalarından birinde mutfaktaki tabak sesi, diğerinde koridordaki kapı gıcırtısı bulunuyordu. {kahraman} tabak sesinin sözcüklerin arasına karıştığını gösterdi. Robotun iki mikrofonundan gelen verileri karşılaştırmak için ekranda yeni bir pencere açtılar. Böylece hangi kaydın hangi taraftan geldiği ayrı satırlarda görüntülendi.

Kahvaltı masasında tost kokusu yayılırken ARO köşede bekliyordu. {kahraman}, robotun ekranındaki onay kutusunu yeniden kontrol etti. Bu kez tek cümleye tek görev bağlanıyordu. Ancak {yoldas:yalin|bir arkadaş}, alçak sesle verilen komutta robotun bazı sözcükleri kaçırabileceğini düşündü. İkisi sessiz bir ortamda ikinci bir deneme hazırladı.

{kahraman} “Masadaki boş bardağı getir,” dedi. Ekrana “Boş bardak getir” yazısı geldi. ARO masadaki bardağı seçti, fakat yanında dolu bir bardak daha vardı. {yoldas:yalin|bir arkadaş}, ekrandaki nesne resimlerinin birbirinden ayırt edilebildiğini kontrol etti. Robot doğru bardağı kavrayıp getirdi. Sonra her iki öğrenci sonuç kartına birer küçük işaret koydu.

{kahraman}, ilk sabahın karışık kaydını yeniden dinledi. Tost sözüyle çorap sözü artık ayrı satırlarda görünüyordu. ARO, “Bir sonraki komut için hazırım,” dedi. {yoldas:yalin|bir arkadaş}, masadaki çorapları topladı, sepetlerine yerleştirdi. {kahraman} robotun ekranında kalan iki ses kaydını farklı renkle işaretledi; ardından kahvaltı tabağını önüne çekip ekmek dilimini aldı.
