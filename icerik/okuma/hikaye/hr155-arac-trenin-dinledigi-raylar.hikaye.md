---
baslik: Trenin Dinlediği Raylar
slug: hr155-arac-trenin-dinledigi-raylar
fis_kodu: HR-155
tur: bilim
konu: ray_temasi_gozlemi
sinif_alt: 6
sinif_ust: 6
kahraman_turu: arac
deger_anahtarlari:
  - D16
  - D12
tanitim: Bir tren, viraj çıkışında alışılmadık bir sarsıntı hissediyor. {kahraman} güvenli bakım tamamlanana kadar raylardaki işaretleri izliyor.
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: 2026-11-10
etiketler:
  ana_sinif: 6
  okuma_zorlugu: 3
  kavram_zorlugu: 3
  ilgi_egilimi: ortak
  temalar:
    - bilim_teknoloji
  ders_baglantisi:
    - turkce
  maarif:
    ana_deger: D16
    yardimci_deger: D12
  ogrenme_hedefleri:
    - id: sozcuk1_hr155
      tur: lexeme
      etiket: sürtünme
      yuva: hr155_surtunme
      islev: first_hint
    - id: sozcuk2_hr155
      tur: lexeme
      etiket: titreşim
      yuva: hr155_titresim
      islev: application
    - id: sozcuk3_hr155
      tur: lexeme
      etiket: bakım
      yuva: hr155_bakim
      islev: application
    - id: sozcuk4_hr155
      tur: lexeme
      etiket: kontrol
      yuva: hr155_kontrol
      islev: transfer
  kanit_duzeyi: C
  program_surumu: TYMM 2026-27 (6. sınıf); kazanım kodu yok (source_pending)
  denetim:
    ajan_a: pending
    ajan_b: pending
    insan: pending
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: Sarsıntı hangi bölgede fark ediliyordu?
    secenekler:
      - id: A
        metin: Tünel sonrası virajda
      - id: B
        metin: İstasyon kapısında
      - id: C
        metin: Yolcu vagonunda
      - id: D
        metin: Bakım merkezinin girişinde
    dogru: A
    aciklama: Metindeki "Sarsıntı yalnızca bir virajdan çıkarken beliriyordu." ifadesi doğru seçeneği destekler.
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: İnce kumun bulunması neden önemliydi?
    secenekler:
      - id: A
        metin: Bilet fiyatını ve seferleri belirlediği için
      - id: B
        metin: Sarsıntıyla ilgili olabileceği için
      - id: C
        metin: Peronu büyütüp genişlettiği için
      - id: D
        metin: Rayın rengini değiştirdiği için
    dogru: B
    aciklama: Metindeki "Fakat yağmurdan sonra bir noktada ince kum biriktiği fark edildi." cümlesi, kumun sarsıntının olası bir etkeni olarak incelendiğini gösterir; metinde değişikliğin kumun arttığı günlerde belirginleştiği de yazar. Bilet fiyatı, peronun boyutu ve rayın rengi kumla ilişkilendirilmez.
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: “Birikinti” ifadesi bağlamda neyi anlatır?
    secenekler:
      - id: A
        metin: Trenin hız göstergesindeki ibreyi
      - id: B
        metin: Hatta yeni eklenen bir vagonu
      - id: C
        metin: Bir noktada toplanan maddeyi
      - id: D
        metin: İstasyonun girişindeki büyük tabelayı
    dogru: C
    aciklama: Metindeki "Ray çevresindeki birikinti temizlendi, drenaj kontrol edildi." cümlesinde birikinti, rayın çevresinde toplanıp temizlenen maddedir; önceki bölümde biriken ince kum da bunu destekler. Hız göstergesi, vagon ve tabela temizlenen şeyler değildir.
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: Hat niçin yalnızca son test uygun bulununca açıldı?
    secenekler:
      - id: A
        metin: Gecikmeyi artırmak için
      - id: B
        metin: Treni başka yere satmak için
      - id: C
        metin: Bütün istasyonları kapatmak için
      - id: D
        metin: Güvenliği doğrulamak için
    dogru: D
    aciklama: Metindeki "Test sonuçları uzman ekip tarafından değerlendirildi ve hat ancak uygun görülünce açıldı." cümlesi, hattın güvenliği doğrulanmadan açılmadığını gösterir. Gecikmeyi artırmak, treni satmak ya da istasyonları kapatmak metinde hiç amaç olarak geçmez.
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler:
  - arac
yetiskin_uygun: false
---
@omurga

{kahraman} dağ eteklerinden geçen bir yolcu treniydi. Her seferinde tüneli geçtikten sonra kısa bir sarsıntı hissediyordu. Sarsıntı yalnızca bir virajdan çıkarken beliriyordu. Kontrol sistemleri normal çalışsa da bu değişikliğin anlaşılması gerekiyordu. {kahraman} {kelime:hr155_bakim} merkezine girdiğinde teknisyenler yeni kayıtları inceledi. {yoldas:yalin|Ferhat} gecikmeye ilişkin duyuruyu güncelledi, bekleyenlere alternatif saatler sunuldu. {kahraman} seferlerin değişmesinin yolcuları etkilediğini biliyordu. Yine de bakım kararı belirsiz bir söylentiye değil, kayıtlarla doğrulanan bir inceleme ihtiyacına dayanıyordu. Küçük bir farklılığı görmezden gelmek, yolcuların güvenliğini şansa bırakmak olurdu. Bakım ekibi ölçümleri tamamlayana kadar planlanan sefer değiştirildi. Bu karar bazı yolcuları bekletti ama gerekçesi duyuruda açıklandı.

---

@omurga

Rayların bulunduğu bölümde uzman ekip çalıştı. İki yüzey birbirine değdiğinde oluşan {kelime:hr155_surtunme}, trenin hareketini etkileyebiliyordu. Ekip, tekerlek ve ray temasındaki ölçümleri {kelime:hr155_kontrol} etti. Ardından kayıt cihazındaki {kelime:hr155_titresim} bilgilerini bir grafik üzerinde inceledi. Tekerlek yüzeyindeki izler incelenirken uzmanlar bakım geçmişine de baktı. {kahraman} her rayda aynı sesin oluşmadığını anımsıyordu. Bu ayrıntı, sorunun bütün hatta yayılan bir bozukluk olmayabileceğini düşündürdü. Ekip farklı olasılıkları listeden birer birer kontrol etti; henüz kanıtlanmamış bir tahmini sonuç diye yazmadı. İlk incelemede raylarda büyük bir bozukluk görünmüyordu. Fakat yağmurdan sonra bir noktada ince kum biriktiği fark edildi. {kahraman} aynı bölgeden geçen önceki seferlerin kayıtlarını anımsıyordu. Değişiklik, kumun artmaya başladığı günlerde belirginleşmişti. Teknisyenler bu bağlantıyı not etti ama başka olasılıkları da incelemeye devam etti.

---

@omurga

Hattın ilgili bölümü yetkililerce güvenli çalışmaya kapatıldı. Ray çevresindeki birikinti temizlendi, drenaj kontrol edildi. {kahraman} daha sonra boş olarak test yolculuğuna çıktı. {yoldas:yalin|Ferhat} kontrol ekranındaki değerleri izliyordu. Deneme sürüşünün ardından elde edilen grafikler üst üste getirildi. Bazı değerler azalmıştı ama hepsi aynı miktarda değişmemişti. {kahraman} bunu fark ettiğinde daha fazla ölçüm yapılmasının iyi olacağını düşündü. Teknisyenler farklı hız aralıklarında izin verilen koşulları karşılaştırdı. Küçük ayrıntılar birlikte incelendiğinde daha açık bir tablo oluştu. Sarsıntı azalmıştı; fakat viraj çıkışında hafif bir hareket hâlâ hissediliyordu. Ekip bu kez ray bağlantılarındaki küçük ayar farklılığını inceledi. İki ölçüm arasındaki fark net biçimde kaydedildi. {kahraman} değişikliğin nedenini tek bir olaya bağlamanın ne kadar yanıltıcı olabileceğini gördü. Birden fazla küçük etken bir araya gelmişti.

---

@omurga

Gerekli bakım tamamlanınca tekrar deneme yapıldı. Ray boyunca kontrol noktaları işaretlenmişti. Tren her birinden geçerken hareket verileri kaydedildi. Test sonuçları uzman ekip tarafından değerlendirildi ve hat ancak uygun görülünce açıldı. Peronun kenarında bekleyen yolculara yaklaşma çizgisinin gerisinde durmaları hatırlatıldı. {kahraman} duraklamanın ve yeniden hareket etmenin de yolculuğun önemli parçaları olduğunu düşünüyordu. Güvenli bir hat tek başına yeterli değildi; istasyondaki açık işaretler ve düzenli duyurular da yolculuğun tamamını destekliyordu. {kahraman} istasyona yaklaşırken peronun aydınlık çizgisini gördü. Peron, yolcuların tren beklediği yükseltilmiş bölümdü. Yolcular yeniden düzenlenen sefer saatini tabeladan öğrendi. Gecikme için açıklama yapılmıştı. Yolculuk sırasında saklanan bir sorun kalmamış olması, herkesi rahatlattı.

---

@omurga

Sonraki hafta {kahraman} aynı virajı geçerken sarsıntıyı hissetmedi. Ama bakım kayıtlarının düzenli tutulması devam etti. Tren, her şey yolundayken yapılan kontrollerin de önemli olduğunu biliyordu. İstasyonda bir çocuk pencerenin ardından dağları gösterdi. Dağ manzarası vagondaki pencerelerden birer birer geçiyordu. {kahraman} eski sarsıntıyı artık hissetmemekle yetinmedi; düzenli kontrollerin sürmesini değerli buldu. Çünkü bir sorun ortadan kalktığında ona yol açan koşulları hatırlamak gelecekteki işleri kolaylaştırırdı. İstasyonda tutulan dosya bunun için hazırlanmıştı. Yolcular sessizce yolculuğuna devam etti. {kahraman} raylardan yükselen düzenli sesi dinledi. Ses düzgündü ve ritmi bir an bile aksamıyordu. Dağlar geride kalırken yol devam etti.
