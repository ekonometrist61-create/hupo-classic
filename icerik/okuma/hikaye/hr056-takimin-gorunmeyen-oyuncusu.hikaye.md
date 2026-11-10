---
baslik: "Takımın Görünmeyen Oyuncusu"
slug: "hr056-takimin-gorunmeyen-oyuncusu"
fis_kodu: "HR-056"
tur: arkadaslik
konu: takim_kapsayicilik
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D4, D20]
yetiskin_uygun: false
tanitim: "Takımın listesinde adı yok. Robotik yarışı, sessiz bir çocuğun fikirleriyle nasıl değişti?"
durum: taslak
uretim_kaynak: chatgpt_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [dostluk, dayanisma]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D4
    yardimci_deger: D20
  ogrenme_hedefleri:
    - {id: parkur_hr056, tur: lexeme, etiket: "parkur", yuva: hr056_parkur, islev: first_hint}
    - {id: sensor_hr056, tur: lexeme, etiket: "sensör", yuva: hr056_sensor, islev: application}
    - {id: viraj_hr056, tur: lexeme, etiket: "viraj", yuva: hr056_viraj, islev: application}
    - {id: deyim_hr056, tur: idiom, etiket: "İçi burkulmak", yuva: hr056_ici_burkulmak, islev: application}
    - {id: kavram_hr056, tur: concept, etiket: "Katkıyı görmek ve kapsayıcılık", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pass, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Deniz'in adı yarış listesinde yalnızca yedek bölümünde vardı.", metin: "Deniz başlangıçta yarış takımında hangi roldedir?", secenekler: [{id: A, metin: "Sunum sorumlusu"}, {id: B, metin: "Yedek öğrenci"}, {id: C, metin: "Takım kaptanı"}, {id: D, metin: "Malzeme denetçisi"}], dogru: B, aciklama: "Deniz yedek listesine yazılmıştır."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, dayanak: "Robot, keskin dönüşe hızlı girince siyah çizginin dışına taşıyordu.", metin: "Deniz neden virajdan önce hızı azaltmayı önermiştir?", secenekler: [{id: A, metin: "Pil sabah daha çok dolsun diye"}, {id: B, metin: "Çizgi değişsin diye"}, {id: C, metin: "Parkur uzasın diye"}, {id: D, metin: "Robot çizgiyi aşmasın diye"}], dogru: D, aciklama: "Hızı azaltmak çizgiden çıkmayı önleyebilir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "Takım, Deniz'e rota denetimi görevini verdi.", metin: "Takım, Deniz’in katkısını nasıl karşıladı?", secenekler: [{id: A, metin: "Ona rota denetimi görevini verdi"}, {id: B, metin: "Onu yine yedek listesinde bıraktı"}, {id: C, metin: "Defterini malzeme kutusuna kaldırdı"}, {id: D, metin: "Sunum görevini ondan geri aldı"}], dogru: A, aciklama: "Deniz’in çalışması fark edildi ve ona rota denetimi görevi verildi."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, dayanak: "Çizgiyi izleyen sensör, zemindeki koyu şeridi okuyordu.", metin: "“Sensör” sözcüğü robotun hangi parçasını anlatır?", secenekler: [{id: A, metin: "Ekran süsünü"}, {id: B, metin: "Tekerlek kapağını"}, {id: C, metin: "Çizgiyi algılayan parçayı"}, {id: D, metin: "Gövde üzerindeki eski etiketi"}], dogru: C, aciklama: "Sensör zemindeki çizgiyi algılar."}
deyim_cumleleri:
  hr056_ici_burkulmak: "Deniz kızmadı ama içi burkuldu."
---
@omurga
Deniz'in adı yarış listesinde yalnızca yedek bölümünde vardı. Robotik turnuvasına üç gün kala diğer öğrencilerin görevleri belirlenmişti: kodlama, malzeme, sunum ve zaman tutma. Deniz yeni geldiği için çoğu arkadaşı onun neyle ilgilendiğini bilmiyordu. Sessizce oturuyor, teneffüslerde robotun çizimini defterine yapıyordu. {kahraman} ise takımın deneme sürüşlerini takip ediyordu.

Salondaki {kelime:hr056_parkur}, siyah çizgilerle işaretlenmiş uzun bir yoldu. Çizgi iki kez kıvrılıyor, ardından dar bir kapıdan geçiyordu. Robot, düz yolda hızla ilerleyip ilk dönüşte çizginin dışına çıkıyordu. Takım üç denemede de aynı hatayı görünce motoru değiştirmeyi düşündü. Deniz kalemini defterinin üzerine bıraktı. “Önce dönüşe bakalım,” dedi. Sesini çok az kişi duydu.

{yoldas:yalin|bir arkadaş} saate bakıp “Başka işlerimiz de var,” diye karşılık verdi. Deniz oturduğu yere geri döndü. [[deyim:hr056_ici_burkulmak]] Defterinin açık sayfasında dönüşün başladığı yer işaretliydi. {kahraman}, çizimdeki ince kırmızı çizgiyi görünce Deniz'in yanına geldi; sayfanın kenarındaki kırmızı işareti ve çizimi dikkatle inceledi.
---
@omurga
Deniz’in çizim defterinde yalnızca robotun dış görünüşü yoktu. Her sayfada küçük oklar, tarihleri yazılmış deneme sonuçları ve kendi tuttuğu süreler bulunuyordu. {kahraman} çizimleri incelerken bazı okların kırmızı, bazılarının mavi olduğunu gördü. Kırmızılar hatalı dönüşleri, maviler sorunsuz geçen bölümleri gösteriyordu. Deniz bu renkleri kimseye anlatmamış, yalnızca sonraki denemelerde kullanmak için işaretlemişti.

Deniz, robotun her denemede tam aynı noktada çizgiden çıktığını gösterdi. Robot, keskin dönüşe hızlı girince siyah çizginin dışına taşıyordu. Çizimde, dönüşten iki karış önce bir ok vardı. Deniz, motoru değiştirmeden önce bu noktada hızı azaltmayı önerdi. {kahraman}, elindeki kronometreyi masaya bıraktı. “Bir deneme yapalım,” dedi.

Takım robotu başlangıç çizgisine geri koydu. {yoldas:yalin|bir arkadaş}, ilk dönüşün öncesindeki {kelime:hr056_viraj} işaretini kalınlaştırdı. Deniz, robottaki çizgi izleme {kelime:hr056_sensor} bölümünü gösterdi. Çizgiyi izleyen sensör, zemindeki koyu şeridi okuyordu. Ancak robot çok hızlı dönerse sensör çizginin dışına çıkıyordu.

{kahraman}, Deniz'in çizdiği yavaşlama noktasını kodlama görevindeki arkadaşına gösterdi. Kod değiştirildi; robot aynı yolun başına bırakıldı. Bu kez dönüşe yaklaşırken kısa süreliğine yavaşladı. İlk virajı geçti. Salondan küçük bir alkış yükseldi. Ne var ki ikinci dönüşte robot tekrar çizgiyi kaybetti. Deniz defterini çevirdi; ikinci dönüşün daha dar olduğunu önceden işaretlemişti.
---
@omurga
Takım ikinci dönüşü ölçmek için yere küçük cetveller koydu. İlk viraj ile ikinci virajın açıları farklıydı. Deniz, aynı yavaşlama süresinin iki dönemeç için yeterli olmayabileceğini söyledi. {kahraman} tahtaya iki ayrı değer yazdı; takım bu değerleri denemelerde sırayla değiştirdi. Üçüncü denemede robot dar dönüşü de geçince herkes pistin sonunda toplandı.

Sunum görevindeki öğrenci, “Peki bunu yarışta kim anlatacak?” diye sordu. Deniz sessizce defterine baktı. {kahraman}, defterin sayfalarını açıp çizimlerin altındaki tarihleri gösterdi. Deniz'in sorun üzerinde birkaç gündür çalıştığı belliydi. Takım, Deniz'e rota denetimi görevini verdi. Sunumu hazırlayanlar da robotun farklı dönüşlerdeki hızını gösteren çizimi gösteriye ekledi.

Deniz adının yazıldığı yeni listeyi bir süre inceledi. {yoldas:yalin|bir arkadaş} yanına gelip, “İlk söylediğinde seni duymadım,” dedi. “Yarın denemeyi sen başlatır mısın?” Deniz başını salladı. Kronometreyi aldı, başlangıç çizgisine çömeldi. Robotu çalıştırınca herkes gözünü aynı keskin dönüşe çevirdi. Robot siyah çizginin üzerinde ilerledi, ışıkları bir an söndü, ardından yeniden yandı.
---
@omurga
Takım yarış alanına geldiğinde kalabalığın arasından bitiş çizgisini görmek kolay olmadı. Deniz, çantasındaki defteri çıkarıp pistin kenarına geçti. Önceden hazırladıkları değerlerin yanına boş bir sütun ekledi; yeni dönüşlerin ölçülerini oraya yazacaktı. {yoldas:yalin|bir arkadaş}, geçen denemeden kalan küçük siyah bandı cebinden çıkardı. Bandın ucu kıvrılmıştı; bunu malzeme kutusuna geri koydu.

Yarış günü salondaki parkur deneme pistinden farklıydı. İlk viraj biraz daha keskin, ikinci dönüşse daha genişti. Takım kurallarda izin verilen hazırlık süresini kullanarak robotun hız değerlerini yeniden kontrol etti. Deniz, pistin kenarında çömelip dönüşleri çizdi. {kahraman} ona kâğıt uzattı, süreyi birlikte hesapladılar.

Başlama işareti verildiğinde robot siyah çizgiyi izlemeye koyuldu. İlk dar dönüşe yaklaşırken hafifçe yavaşladı. İkinci dönüşte tekerleklerinden biri çizginin dışına çok az taştı; salonda nefesler tutuldu. Sensör çizgiyi yeniden bulunca robot yoluna devam etti. Son kapıdan geçip bitiş çizgisinde durduğunda takım birbirine sarıldı.

Jüri, robotun neden hız değiştirdiğini sordu. {kahraman}, elindeki çizimi Deniz'e verdi. Deniz, dönüşlerin açılarını ve yaptıkları denemeleri anlattı. Kimse onun sözünü kesmedi. Gösteri bitince malzeme masasındaki görevli, takım listesini son kez kontrol etti. Deniz'in adı bu kez diğerleriyle aynı büyüklükte yazılmıştı.

{yoldas:yalin|bir arkadaş} robotu kutuya kaldırırken küçük defteri de almak istedi. Deniz defteri kendi çantasına koydu, sonra boş bir sayfa açıp yeni parkurun ilk çizgisini çizdi.
