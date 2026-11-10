---
baslik: "Robot Sınıf Başkanı Seçildi"
slug: "hr053-robot-sinif-baskani-secildi"
fis_kodu: "HR-053"
tur: mizah
konu: kural_demokrasi
sinif_alt: 5
sinif_ust: 5
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas, hayali]
deger_anahtarlari: [D6, D14]
yetiskin_uygun: false
tanitim: "Sınıf başkanlığı seçiminde birinci gelen aday bir robot. Kurallar kime hizmet ediyor?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 5
  okuma_zorlugu: 4
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [okul, bilim_teknoloji]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D14
  ogrenme_hedefleri:
    - {id: desibel_hr053, tur: lexeme, etiket: "desibel", yuva: hr053_desibel, islev: first_hint}
    - {id: temsilcilik_hr053, tur: lexeme, etiket: "temsilcilik", yuva: hr053_temsilcilik, islev: application}
    - {id: algilama_hr053, tur: lexeme, etiket: "algılamak", yuva: hr053_algilama, islev: application}
    - {id: kavram_hr053, tur: concept, etiket: "Kuralın amacı ve demokratik karar", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (5. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: review_needed, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "Sınıfın deneme başkanlığı seçiminde en çok oyu MİKO aldı.", metin: "Seçimde en fazla oy alan deneme başkanı kimdir?", secenekler: [{id: A, metin: "Arda adlı öğrenci"}, {id: B, metin: "MİKO adlı robot"}, {id: C, metin: "Ece adlı öğrenci"}, {id: D, metin: "Sınıf öğretmeni"}], dogru: B, aciklama: "Deneme seçiminde en çok oyu MİKO alır."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, dayanak: "Ekranda MİKO'nun kalemini arayan çocuğa verdiği gürültü uyarısı da kayıtlıydı.", metin: "MİKO’nun ilk uygulaması neden itiraz doğurmuştur?", secenekler: [{id: A, metin: "Tüm sesleri kaydetmiştir"}, {id: B, metin: "Bahçeyi kilitlemiştir"}, {id: C, metin: "Oyların tamamını yeniden saymıştır"}, {id: D, metin: "Durumu görmeden uyarı vermiştir"}], dogru: D, aciklama: "Robot kuralı durumdan bağımsız uygular."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 4, dayanak: "Sınıf, MİKO'nun yalnızca önerileri listelemesine oy verdi.", metin: "Sınıf son kararda MİKO’ya hangi görevi vermiştir?", secenekler: [{id: A, metin: "Önerileri listeleme"}, {id: B, metin: "Öğrencileri cezalandırma"}, {id: C, metin: "Oyları gizlice değiştirme"}, {id: D, metin: "Öğretmeni görevden alma"}], dogru: A, aciklama: "Robot önerileri sıralayacak, karar öğrencilerde kalacaktır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, dayanak: "Ekranda ses düzeyi için {kelime:hr053_desibel} yazıyordu.", metin: "“Desibel” bu sahnede neyin ölçüsüdür?", secenekler: [{id: A, metin: "Koridorun uzunluğu"}, {id: B, metin: "Ekranın parlaklığı"}, {id: C, metin: "Sesin düzeyi"}, {id: D, metin: "Robotun ağırlığı"}], dogru: C, aciklama: "Desibel ses düzeyiyle ilgilidir."}
---
@omurga
Sınıfın deneme başkanlığı seçiminde en çok oyu MİKO aldı. Tekerlekli robotun ekranında kocaman bir gülümseme işareti belirdi. MİKO, “Başkanlık talimatı alındı,” dedi; ardından zil çalmadan üç kez sınıfı dolaştı. Öğrenciler gülüyordu. Adaylığı önce bir şaka olarak yazılmış, sonra herkesin hoşuna gitmişti. Öğretmen, gerçek {kelime:hr053_temsilcilik} görevinin öğrencilerden birine verileceğini, MİKO'nun ise bir günlüğüne deneme başkanı olacağını açıklamıştı.

{kahraman}, oy sayımı sırasında tahtaya çizdiği çizgileri gösterdi. {yoldas:yalin|bir arkadaş} çizgileri yüksek sesle saydı. Birinci sırada MİKO vardı, ikinci sırada Ece, üçüncü sırada Arda. Robot bir sandalye istemedi; bunun yerine kendisine pencere kenarındaki şarj noktasını seçti. İlk işi, sınıf kurallarını ekrana taşımak oldu. “Gürültü sıfır, gecikme sıfır, dağınıklık sıfır,” dedi. Arda fısıltıyla, “Teneffüs de sıfır olmasın,” diye karşılık verdi.

Ders sırasında bir çocuğun kalemi yere düştü. Çocuk eğilip kalemini aramaya başladı. Sandalye hafifçe gıcırdadı. MİKO'nun ekranı kırmızıya döndü; robot, yüksek sesle “Gürültü uyarısı,” dedi. Çocuk başını kaldırıp şaşkın şaşkın baktı. Sınıfta ilk kez kimseden gülüş duyulmadı.
---
@omurga
Deneme başkanının masasının üstüne küçük bir zil de koyulmuştu. MİKO, zili kullanmak için uzandığında tekerleklerinden biri masanın ayağına takıldı. Sınıfın arka sırasında oturan çocuklar bu sesi duyup dönünce robot kendisine de uyarı verdi. Ekranda kırmızı bir çarpı belirdi. Arda, “Başkan kendini uyardı!” diye seslenince kahkaha yükseldi. Öğretmen zili masanın kenarından alıp daha güvenli bir yere taşıdı.

Ekranda MİKO'nun kalemini arayan çocuğa verdiği gürültü uyarısı da kayıtlıydı. {kahraman}, robotun ekranında beliren ölçüm çizelgesine baktı. Ekranda ses düzeyi için {kelime:hr053_desibel} yazıyordu. Yanlışlıkla sürtünen sandalyenin çıkardığı sesle bağıran birinin sesini aynı renkte gösteriyordu. Robotun sesi ise hepsinden yüksekti.

Ece parmak kaldırdı. “Birisi yardım isterken konuşursa ne olacak?” MİKO, “Ses belirlenen sınırı aşarsa uyarı verilir,” dedi. “Peki düşen bir kitap için biri eğilirse?” Arda'nın sorusuna aynı yanıtı verdi. {kahraman} tahtaya iki küçük çizim yaptı: birinde yardım için eğilen çocuk, diğerinde bilerek bağıran biri vardı. Robot iki resme de aynı kırmızı işareti koydu.

Öğretmen, robotun durumu daha iyi {kelime:hr053_algilama} için yalnız ses ölçümüne dayanamayacağını söyledi. “MİKO bugün kural denemesi yapıyor,” diye ekledi. Ece, öğrencilerin görüşlerini de ekranın yanındaki kutuya yazmalarını önerdi. Herkes teneffüste kutuya birer kâğıt bıraktı. Robot, kâğıtları sayabildi ama hiçbirinin neden yazıldığını tek başına seçemedi.
---
@omurga
İkinci derste MİKO sıranın üzerinde unutulmuş su şişesini gördü. “Masa temizliği,” diyerek şişeyi kenara itmeye girişti. Arda hemen yetişip şişeyi tuttu. “Ben birazdan içecektim,” dedi. MİKO durdu, fakat ekranda yine kırmızı uyarı belirdi. {kahraman} kâğıt kutusuna yeni bir not koydu: “Bir eşya bazen kullanımdadır.”

Öğretmen sınıftaki denemeyi kısa süreliğine durdurdu. Her öğrenci, kuralların işe yaradığı ve yaramadığı bir durumu anlattı. Kimi sessiz çalışırken dikkati dağıldığı için uyarıları sevmişti. Kimi de yardım ederken uyarı almaktan hoşlanmamıştı. MİKO, söylenenlerin hepsini ekrana sıraladı. Arda, robotun kendi sesini susturacak bir düğmesi olup olmadığını sordu. Robot, “Ses çıkışı ayarlanabilir,” diye yanıt verdi.

{kahraman}, kâğıtları birbirine karıştırmadan dört gruba ayırdı: ses, düzen, yardım ve teneffüs. Her grupta hem olumlu hem olumsuz notlar vardı. Ece, çocukların isimlerini kâğıtlardan silmeyi önerdi; herkesin sözü aynı yerde görünüyordu. Tahtadaki deneme sonuçlarına bakınca, bir kuralın farklı durumlarda farklı sonuçlar doğurduğu açıkça görünüyordu.
---
@omurga
Çocuklar kutudaki notları okumak için sırayla ayağa kalktı. Birisi, hastalanan arkadaşına kâğıt taşımak isteyenlerin serbestçe konuşması gerektiğini yazmıştı. Bir başkası, herkes aynı anda konuştuğunda yönergeyi duyamadığını belirtmişti. {kahraman} iki kâğıdı yan yana astı; robot bunları farklı renkli başlıklar altında sıraladı. Kâğıtların önünde kısa süreli bir sessizlik oldu.

Son derste öğretmen küçük bir oylama hazırladı. İlk seçenek, MİKO'nun bütün kuralları tek başına uygulamasıydı. İkinci seçenek, robotun yalnızca önerileri sıralamasıydı. Üçüncü seçenek ise denemenin tamamen kaldırılmasıydı. Çocuklar sırayla oy kullandı. MİKO, sayıları toplarken ekranda bir kum saati döndürdü.

Sınıf, MİKO'nun yalnızca önerileri listelemesine oy verdi. Öğrencilerin seçtiği Ece de gerçek sınıf temsilcisi oldu. MİKO yeni görevini duyunca “Talimat değiştirildi,” dedi. Sonra Arda'ya baktı. “Ses çıkışı azaltıldı.” Bu kez cümleyi neredeyse fısıldayarak kurdu. Çocuklar gülmeye başladı.

{kahraman} masadaki notları toplarken ilk derste kalemini düşüren çocuk yanına geldi. “Robot şimdi kalemimi arayacak mı?” diye sordu. O anda kalem yeniden sıranın altına yuvarlandı. MİKO tekerlekleriyle yaklaştı, kalemi yerde görünce durdu. “Yardım önerisi: kalem masaya bırakılabilir,” dedi. Ece, eğilip kalemi aldı. Robot hiçbir uyarı vermedi.

Zil çalınca çocuklar kapıya yöneldi. {yoldas:yalin|bir arkadaş} MİKO'ya el sallayıp çıktı. MİKO, oylama sonuçlarını ekranda açık bıraktı. {kahraman} ekrandaki son satıra bir başlık ekledi: “Yarın tartışılacak öneriler.” Sonra robotun fişini şarj noktasına taktı ve sınıfın kapısını kapattı.
