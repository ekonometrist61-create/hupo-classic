---
baslik: "Mars'a Giden Sessiz Mesaj"
slug: "hr061-marsa-giden-sessiz-mesaj"
fis_kodu: "HR-061"
tur: bilim_kurgu
konu: uzay_iletisim_gecikme
sinif_alt: 6
sinif_ust: 6
okuma_bandi: 3
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D16]
yetiskin_uygun: false
tanitim: "Mars'tan gelen mesaj 'şimdi' diyor. Ama mesaj on bir dakika önce gönderilmiş. Kapı şimdi mi açılmalı?"
durum: taslak
uretim_kaynak: chatgpt_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 5
  kavram_zorlugu: 5
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, kesif]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: gecikme_hr061, tur: lexeme, etiket: "gecikme", yuva: hr061_gecikme, islev: first_hint}
    - {id: simulasyon_hr061, tur: lexeme, etiket: "simülasyon", yuva: hr061_simulasyon, islev: application}
    - {id: protokol_hr061, tur: lexeme, etiket: "protokol", yuva: hr061_protokol, islev: application}
    - {id: deyim_hr061, tur: idiom, etiket: "Gözleri parlamak", yuva: hr061_gozleri_parladi, islev: application}
    - {id: kavram_hr061, tur: concept, etiket: "Zaman damgası ve doğrulama", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (6. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: review_needed, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Ekranda “Kapıyı şimdi aç” mesajı belirdi.", metin: "Mars maketinden ekrana gelen komut hangisidir?", secenekler: [{id: A, metin: "Robotu geri döndür"}, {id: B, metin: "Kapıyı şimdi aç"}, {id: C, metin: "Örneği dışarı çıkar"}, {id: D, metin: "Işıkları tamamen kapat"}], dogru: B, aciklama: "Gelen komut kapının açılmasıdır."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 1, dayanak: "Mesajın gönderildiği an ile alındığı an arasında on bir dakika vardı.", metin: "Mesajdaki “şimdi” sözü neden güvenilir sayılmadı?", secenekler: [{id: A, metin: "Kumanda ekranı bir süre kararmıştı"}, {id: B, metin: "Mesajı gönderen kişi emin görünmüyordu"}, {id: C, metin: "Kapının dış kolları kırılmış görünüyordu"}, {id: D, metin: "Mesaj eski bir durumu anlatıyordu"}], dogru: D, aciklama: "Mesaj on bir dakika önce gönderilmişti; “şimdi” sözü o andaki durumu anlatıyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "Ekip, kapı komutundan önce güncel basınç göstergesini ve zaman damgasını karşılaştırdı.", metin: "Kapıyı açmadan önce ekip neyi doğruladı?", secenekler: [{id: A, metin: "Basınç ve zaman damgasını"}, {id: B, metin: "Kapının dış rengini ve boyunu"}, {id: C, metin: "Gezgin aracın tekerlek sayısını"}, {id: D, metin: "Mesajı yazan ekibin adını"}], dogru: A, aciklama: "Açma kararı güncel durum doğrulamasına dayanır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 1, dayanak: "İletişimde gecikme, mesajın gönderilmesinden sonra alıcıya ulaşana dek geçen süreydi.", metin: "“Gecikme” bu görevde hangi durumu anlatır?", secenekler: [{id: A, metin: "Pilin yeniden dolmasını"}, {id: B, metin: "Robotun yön değiştirmesini"}, {id: C, metin: "Mesajın geç ulaşmasını"}, {id: D, metin: "Haritanın yenilenmesini"}], dogru: C, aciklama: "Gecikme mesajın ulaşma süresidir."}
deyim_cumleleri:
  hr061_gozleri_parladi: "{kahraman:ilgi} gözleri parladı."
---
@omurga
Ekranda “Kapıyı şimdi aç” mesajı belirdi. {kahraman}, kontrol düğmesinin üstündeki kapağı kaldırmak için elini uzattı. {yoldas:yalin|bir arkadaş}, ekranın sol köşesindeki küçük saate işaret etti. Mesajın altında, gönderildiği andaki zaman yazıyordu. Mesajın gönderildiği an ile alındığı an arasında on bir dakika vardı. {kahraman} elini düğmeden çekti; laboratuvar maketinin camı arkasında kırmızı bir ışık yanıp sönüyordu.

İkisi, uzak bir gezegendeki araştırma istasyonunu canlandıran eğitim merkezinde görevliydi. Burada gerçek bir uzay aracını yönetmiyorlardı; büyük bir {kelime:hr061_simulasyon} odasında, Mars'taki hava kilidi maketinin komutlarını çalışıyorlardı. Dışarıda Mars yüzeyini gösteren kırmızı bir görüntü, içeride ise kapının basınç göstergeleri vardı. Kumanda odası Dünya'yı, maket Mars'ı temsil ediyordu. Mars'tan gelen yazılı mesajlar on bir dakika gecikmeli ulaşıyordu; maketin basınç göstergeleri ise odaya doğrudan bağlıydı ve canlı çalışıyordu. Eğitim için kapı komutunun maket kapıya hemen ulaşması kabul edilmişti.

{kahraman}, iletişimde {kelime:hr061_gecikme} kaydını açtı. İletişimde gecikme, mesajın gönderilmesinden sonra alıcıya ulaşana dek geçen süreydi. “Oradaki ekip ‘şimdi’ derken başka bir anı söylüyordu,” dedi. {yoldas:yalin|bir arkadaş}, ekranda en son kaydedilen basınç değerini buldu; değer mesajdan daha yeni görünüyordu. Kapı henüz açılmamıştı ama dış bölümdeki ışık değişmişti.
---
@omurga
Simülasyon odasının duvarındaki büyük haritada Dünya ve Mars birbirinden ayrı noktalarda gösteriliyordu. Aralarında ince bir ışık çizgisi vardı. {kahraman}, yerdeki uzun çizginin iki ucuna yürüyüp hangi noktanın mesaj göndericiyi temsil ettiğini kontrol etti. Uzakta bekleyen küçük gezgin araç maketi, kapıyla aynı ölçekte çizilmişti. Bu düzen, odanın içinde saatler süren bir görevi birkaç ekranda görmeyi sağlıyordu.

Kontrol masasında üç ayrı ekran bulunuyordu. Birincisi geçmiş mesajları, ikincisi maketin içindeki basıncı, üçüncüsü de gönderilecek komutları gösteriyordu. {kahraman}, düğmeyi açmak yerine ekranların saatlerini karşılaştırdı. İkinci ekrandaki son değerin birkaç saniye önce güncellendiği görülüyordu. İlk ekrandaki komut ise on bir dakika önce yazılmıştı. İki kayıt aynı anda gerçekleşmiş olayları anlatmıyordu.

Masada, önceki görevlerden kalma kalın bir {kelime:hr061_protokol} dosyası duruyordu. Dosyada kapı açılmadan önce hangi göstergelerin kontrol edileceği adım adım yazılmıştı. {yoldas:yalin|bir arkadaş}, dosyayı açıp ilk maddeyi okudu: “Her komutun gönderim zamanını denetle.” İkinci maddede, iç ve dış bölüm basınçlarının uygun aralıkta olması isteniyordu. Üçüncü maddede, komutu göndermeden önce kapının son durumunun doğrulanması bulunuyordu.

{kahraman}, maketin dış kamerasını büyüttü. Hava kilidinin önündeki küçük gezgin araç geri geri hareket ediyordu; tekerleklerinden biri kapının önündeki çizgiye çok yaklaşmıştı. Kapı açılırsa araçla arasında yeterince boşluk kalmayabilirdi. {yoldas:yalin|bir arkadaş}, bu gözlemi kontrol çizelgesinin kenarına yazdı. Eğitmen, kararlarını aceleye getirmeden sürdürebileceklerini söyledi.
---
@omurga
Ekip, kapı komutundan önce güncel basınç göstergesini ve zaman damgasını karşılaştırdı. İç bölümün basıncı izin verilen aralığa yakındı ama dış bölümün göstergesinde kırmızı çizgi duruyordu. {kahraman}, eğitmenin verdiği maket krokisine baktı. Basınç eşitlenmeden kapının açılması, puan kaybıyla sonuçlanacaktı. Geçmişte gönderilmiş bir mesajı şimdiki duruma uygulamak da aynı hataya yol açabilirdi.

{yoldas:yalin|bir arkadaş}, gezgin aracın kamera görüntüsünün hangi zamanda çekildiğini kontrol etti. Görüntü günceldi. Araç, kapının önünden güvenli bölgeye geçince ekranda yeni bir işaret belirdi. {kahraman} sonraki komutu yazmaya hazırlanıyordu, ancak basınç hâlâ eşitlenmemişti. Önce basınç ayarlama işlemine ilişkin simülasyon komutunu seçti. Maketteki küçük fanlar çalışmaya başladı.

Basınç göstergelerindeki fark yavaşça azaldı. {kahraman} her değişimi kayıt defterine yazdı; yanında oturan arkadaşı da sistemin verdiği yanıtları kontrol etti. Fark uygun aralığa düştüğünde ekranın kırmızı ışığı sarıya döndü. Bu sırada eski mesajlar kutusuna yeni bir ileti daha geldi. Metin kısaydı: “Araç kapıdan uzaklaşıyor.” Altındaki saat yine on bir dakika önceyi gösteriyordu.
---
@omurga
{kahraman}, yeni mesajı okuyunca derin bir nefes aldı. [[deyim:hr061_gozleri_parladi]] {yoldas:yalin|bir arkadaş} defterin kenarına küçük bir yıldız çizdi. Ancak düğme hâlâ kapalıydı. Ekrandaki “araç kapıdan uzaklaşıyor” yazısı ile canlı kamera görüntüsü arasında uyuşma olup olmadığını kontrol ettiler.

Maketin canlı görüntüsünde araç gerçekten çizginin gerisinde duruyordu. {kahraman} son basınç değerlerini yeniden okudu. İki gösterge de protokolde yazılı aralıktaydı. Öğretmen, “Artık kararınızı kayda alabilirsiniz,” dedi. {yoldas:yalin|bir arkadaş}, komut ekranının yanındaki küçük açıklama kutusuna “Güncel görüntü ve basınç kontrol edildi” yazdı. {kahraman} sonra kapı açma komutunu seçti.

Hava kilidi maketinin iç kapısı yavaşça hareket etti. Kapı tamamen açılınca ışıklar yeşile döndü. Salondaki diğer öğrenciler camın arkasından alkışladı. {kahraman}, ekranın sağ üst köşesindeki komut saatiyle açılma saatini karşılaştırdı. İkisi arasında kısa bir işlem süresi vardı; bu, on bir dakikalık uzak iletişim bekleyişiyle aynı değildi. Ekranda iki sürenin ayrı ayrı kaydedildiği küçük bir tablo oluştu.
---
@omurga
Görev bittiğinde eğitmen, çocuklara iki görüntü gösterdi. İlkinde kapı açılır açılmaz gezgin aracın tekerleği kapıya çarpıyor, ikincisinde araç güvenli alanda bekliyordu. Birinci görüntü, komutun zamanına bakmadan verilmesi durumunda oluşabilecek sonucu gösteren kayıtlı bir senaryoydu. {kahraman}, kendi yürüttükleri görevin ekranını ikinci görüntünün yanına getirdi.

{yoldas:yalin|bir arkadaş}, eski mesajlar kutusunda en üstte duran “şimdi” sözcüğünü işaret etti. “Ekran onu en yeni mesaj gibi gösteriyordu,” dedi. {kahraman} sıralama ayarını açtı; mesajların geliş saatine ve gönderim saatine göre farklı biçimlerde dizilebildiğini gördü. İki dizilişi bir kâğıda çizdi. Aynı mesaj, iki listede farklı yerde görünüyordu.

Öğretmen, gerçek uzay görevlerinde ışık hızının bile uzaklık yüzünden bekleme süresi oluşturduğunu anlattı. Çocuklar masanın üzerindeki küçük Mars ve Dünya maketlerini birbirinden uzaklaştırdı. Araya daha uzun bir çizgi çizdiler. {kahraman}, kendi görevindeki on bir dakikalık sürenin yanına “örnek senaryo” yazdı; uzaklık değiştikçe iletişim süresinin de değişeceğini belirtti.

Çıkış zili çalınca {yoldas:yalin|bir arkadaş} çizimlerin kopyasını aldı. {kahraman} kontrol masasının üstündeki kırmızı düğmenin koruyucu kapağını indirdi, görev dosyasını kapattı ve son kayıt saatini defterine işledi.
