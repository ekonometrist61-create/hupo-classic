---
baslik: "Trenin Dinlediği Raylar"
slug: "hr155-arac-trenin-dinledigi-raylar"
fis_kodu: "HR-155"
tur: bilim
konu: ray_temasi_gozlemi
sinif_alt: 6
sinif_ust: 6
kahraman_turu: arac
deger_anahtarlari: [D16, D12]
tanitim: "Bir tren, viraj çıkışında alışılmadık bir sarsıntı hissediyor. {kahraman} güvenli bakım tamamlanana kadar raylardaki işaretleri izliyor."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 6
  maarif: {ana_deger: D16, yardimci_deger: D12}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr155, tur: lexeme, etiket: "sürtünme", islev: first_hint}
  - {id: sozcuk2_hr155, tur: lexeme, etiket: "titreşim", islev: application}
  - {id: sozcuk3_hr155, tur: lexeme, etiket: "peron", islev: application}
  - {id: sozcuk4_hr155, tur: lexeme, etiket: "kontrol", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Sarsıntı hangi bölgede fark ediliyordu?"
    secenekler:
      - {id: A, metin: "Tünel sonrası virajda"}
      - {id: B, metin: "İstasyon kapısında"}
      - {id: C, metin: "Yolcu vagonunda"}
      - {id: D, metin: "Bakım merkezinin girişinde"}
    dogru: A
    dayanak: "Sarsıntı yalnızca bir virajdan çıkarken beliriyordu."
    aciklama: "Metindeki \"Sarsıntı yalnızca bir virajdan çıkarken beliriyordu.\" ifadesi doğru seçeneği destekler."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "İnce kumun bulunması neden önemliydi?"
    secenekler:
      - {id: A, metin: "Bilet fiyatını belirlediği için"}
      - {id: B, metin: "Sarsıntıyla ilişkili bir etken olabileceği için"}
      - {id: C, metin: "Peronu büyüttüğü için"}
      - {id: D, metin: "Rayın rengini değiştirdiği için"}
    dogru: B
    dayanak: "Fakat yağmurdan sonra bir noktada ince kum biriktiği fark edildi."
    aciklama: "Metindeki \"Fakat yağmurdan sonra bir noktada ince kum biriktiği fark edildi.\" ifadesi doğru seçeneği destekler."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: "“Birikinti” ifadesi bağlamda neyi anlatır?"
    secenekler:
      - {id: A, metin: "Hız göstergesini"}
      - {id: B, metin: "Yeni bir vagonu"}
      - {id: C, metin: "Bir noktada toplanan maddeyi"}
      - {id: D, metin: "İstasyon tabelasını"}
    dogru: C
    dayanak: "Ray çevresindeki birikinti temizlendi, drenaj kontrol edildi."
    aciklama: "Metindeki \"Ray çevresindeki birikinti temizlendi, drenaj kontrol edildi.\" ifadesi doğru seçeneği destekler."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "Hat niçin yalnızca son test uygun bulununca açıldı?"
    secenekler:
      - {id: A, metin: "Gecikmeyi artırmak için"}
      - {id: B, metin: "Treni başka yere satmak için"}
      - {id: C, metin: "Bütün istasyonları kapatmak için"}
      - {id: D, metin: "Güvenli kullanımın doğrulanması için"}
    dogru: D
    dayanak: "Test sonuçları uzman ekip tarafından değerlendirildi ve hat ancak uygun görülünce açıldı."
    aciklama: "Metindeki \"Test sonuçları uzman ekip tarafından değerlendirildi ve hat ancak uygun görülünce açıldı.\" ifadesi doğru seçeneği destekler."
---

@omurga

{kahraman} dağ eteklerinden geçen bir yolcu treniydi. Her seferinde tüneli geçtikten sonra kısa bir sarsıntı hissediyordu. Kontrol sistemleri normal çalışsa da bu değişikliğin anlaşılması gerekiyordu. {kahraman} bakım merkezine girdiğinde teknisyenler yeni kayıtları inceledi. İstasyon görevlisi gecikmeye ilişkin duyuruyu güncelledi. {kahraman} seferlerin değişmesinin yolcuları etkilediğini biliyordu. Ancak bakım kararı belirsiz bir söylentiye değil, kayıtlarla doğrulanan bir inceleme ihtiyacına dayanıyordu. Bekleyenlere alternatif saatler sunuldu. Böylece teknik önlem, insanların planlarına saygılı biçimde uygulanmış oldu. Sarsıntı yalnızca bir virajdan çıkarken beliriyordu. Tren, bu düzensizliğe alışıp görmezden gelmek istemiyordu. Yolcuların güvenliği için küçük bir farklılığın bile dikkatle değerlendirilmesi gerektiğini biliyordu. Bakım ekibi ölçümleri tamamlayana kadar planlanan sefer değiştirildi. Bu karar bazı yolcuları bekletse de güvenliğin öncelikli olduğu açıklandı.

---

@omurga

Rayların bulunduğu bölümde uzman ekip çalıştı. İki yüzey birbirine değdiğinde oluşan sürtünme, trenin hareketini etkileyebiliyordu. Ekip, tekerlek ve ray temasındaki ölçümleri kontrol etti. Ardından kayıt cihazındaki titreşim bilgilerini dinamik bir grafik üzerinde inceledi. Tekerlek yüzeyindeki izler incelenirken uzmanlar bakım geçmişine de baktı. {kahraman} her rayda aynı sesin oluşmadığını anımsıyordu. Bu ayrıntı, sorunun bütün hatta yayılan bir bozukluk olmayabileceğini düşündürdü. Ekip farklı olasılıkları listeden birer birer kontrol etti; henüz kanıtlanmamış bir tahmini sonuç diye yazmadı. İlk incelemede raylarda büyük bir bozukluk görünmüyordu. Fakat yağmurdan sonra bir noktada ince kum biriktiği fark edildi. {kahraman} aynı bölgeden geçen önceki seferlerin kayıtlarını anımsıyordu. Değişiklik, kumun artmaya başladığı günlerde belirginleşmişti. Teknisyenler bu bağlantıyı not etti ama başka olasılıkları da incelemeye devam etti.

---

@omurga

Hattın ilgili bölümü yetkililerce güvenli çalışmaya kapatıldı. Ray çevresindeki birikinti temizlendi, drenaj kontrol edildi. {kahraman} daha sonra boş olarak test yolculuğuna çıktı. Bir teknisyen kontrol ekranındaki değerleri izliyordu. Deneme sürüşünün ardından elde edilen grafikler üst üste getirildi. Bazı değerler azalmıştı ama hepsi aynı miktarda değişmemişti. {kahraman} bunu fark ettiğinde daha fazla ölçüm yapılmasının iyi olacağını düşündü. Teknisyenler farklı hız aralıklarında izin verilen koşulları karşılaştırdı. Küçük ayrıntılar birlikte incelendiğinde daha açık bir tablo oluştu. Sarsıntı azalmıştı; fakat viraj çıkışında hafif bir hareket hâlâ hissediliyordu. Ekip bu kez ray bağlantılarındaki küçük ayar farklılığını inceledi. İki ölçüm arasındaki fark net biçimde kaydedildi. {kahraman} değişikliğin nedenini tek bir olaya bağlamanın ne kadar yanıltıcı olabileceğini gördü. Birden fazla küçük etken bir araya gelmişti.

---

@omurga

Gerekli bakım tamamlanınca tekrar deneme yapıldı. Ray boyunca kontrol noktaları işaretlenmişti. Tren her birinden geçerken hareket verileri kaydedildi. Test sonuçları uzman ekip tarafından değerlendirildi ve hat ancak uygun görülünce açıldı. Peronun kenarında bekleyen yolculara yaklaşma çizgisinin gerisinde durmaları hatırlatıldı. {kahraman} duraklamanın ve yeniden hareket etmenin de yolculuğun önemli parçaları olduğunu düşünüyordu. Güvenli bir hat tek başına yeterli değildi; istasyondaki açık işaretler ve düzenli duyurular da yolculuğun tamamını destekliyordu. Bu ayrıntılar bakım notlarından bağımsız değildi. {kahraman} istasyona yaklaşırken peronun aydınlık çizgisini gördü. Peron, yolcuların tren beklediği yükseltilmiş bölümdü. Yolcular yeniden düzenlenen sefer saatini tabeladan öğrendi. Gecikme için açıklama yapılmıştı. Yolculuk sırasında saklanan bir sorun kalmamış olması, herkesi rahatlattı.

---

@omurga

Sonraki hafta {kahraman} aynı virajı geçerken sarsıntıyı hissetmedi. Ama bakım kayıtlarının düzenli tutulması devam etti. Tren, her şey yolundayken yapılan kontrollerin de önemli olduğunu biliyordu. İstasyonda bir çocuk pencerenin ardından dağları gösterdi. Dağ manzarası vagondaki pencerelerden birer birer geçiyordu. {kahraman} eski sarsıntıyı artık hissetmemekle yetinmedi; düzenli kontrollerin sürmesini değerli buldu. Çünkü bir sorun ortadan kalktığında ona yol açan koşulları hatırlamak gelecekteki işleri kolaylaştırırdı. İstasyonda tutulan dosya bunun için hazırlanmıştı. Yolcular sessizce yolculuğuna devam etti. {kahraman} raylardan yükselen düzenli sesi dinledi. Artık bu ses ona yalnızca yolculuğu değil, dikkatli çalışmanın sonucunu da hatırlatıyordu. Bir trenin gücü hızlı gitmesinde değil, yolcularını güvenli biçimde hedefe ulaştırmasındaydı. Dağlar geride kalırken yol devam etti.
