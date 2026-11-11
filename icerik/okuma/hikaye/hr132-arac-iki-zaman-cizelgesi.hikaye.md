---
baslik: "Araç ve İki Zaman Çizelgesi"
slug: "hr132-arac-iki-zaman-cizelgesi"
fis_kodu: "HR-132"
tur: macera
konu: bilgi_guncelligi_tarih
sinif_alt: 5
sinif_ust: 5
kahraman_turu: arac
deger_anahtarlari: [D16, D1]
tanitim: "İstasyon panosunda eski ve yeni iki sefer çizelgesi asılıdır. Hangi çizelgenin geçerli olduğu, kâğıtların üzerindeki tarihlere bakılarak anlaşılır."
yetiskin_uygun: false
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-09"
etiketler:
  ana_sinif: 5
  maarif: {ana_deger: D16, yardimci_deger: D1}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: cizelge_hr132, tur: lexeme, etiket: "çizelge", islev: first_hint}
  - {id: aktarma_hr132, tur: lexeme, etiket: "aktarma", islev: application}
  - {id: telafi_hr132, tur: lexeme, etiket: "telafi", islev: application}
  - {id: guzergah_hr132, tur: lexeme, etiket: "güzergâh", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 2
    metin: "Bu gece hangi çizelge geçerliydi?"
    secenekler:
      - {id: A, metin: "Yeni çizelge"}
      - {id: B, metin: "İkisi de geçerliydi"}
      - {id: C, metin: "Eski çizelge"}
      - {id: D, metin: "Bu gece hiçbiri geçerli değildi"}
    dogru: C
    dayanak: "Bu gece eski çizelge geçerliydi."
    aciklama: "Yeni çizelge ertesi sabah yürürlüğe girecekti; bu gece eski çizelge geçerliydi."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Hangi çizelgenin geçerli olduğunu hangi bilgi belirledi?"
    secenekler:
      - {id: A, metin: "Kâğıtların rengi"}
      - {id: B, metin: "Üzerlerindeki tarihler"}
      - {id: C, metin: "Yazıların büyüklüğü ve şekli"}
      - {id: D, metin: "Pano yüksekliği"}
    dogru: B
    dayanak: "İstasyon görevlisi, iki kâğıdın üzerindeki tarihleri dikkatle karşılaştırdı."
    aciklama: "İki kâğıtta farklı saatler yazıyordu; merkez yeni çizelgenin ertesi sabah geçerli olacağını bildirdi. Bu gece geçerli olanı kâğıtlardaki tarihler belirledi."
  - id: s3
    beceri: hatirlama
    dayanak_sayfa: 3
    metin: "Tren neden ek bekleme yaptı?"
    secenekler:
      - {id: A, metin: "Bilet kontrolü için"}
      - {id: B, metin: "Teknik inceleme nedeniyle"}
      - {id: C, metin: "Yolcular uyuyakaldığı için"}
      - {id: D, metin: "Yağmur başladı diye"}
    dogru: B
    dayanak: "Kontrol merkezi, geçici teknik inceleme nedeniyle trenin bir istasyonda daha uzun beklemesi gerektiğini duyurdu."
    aciklama: "Merkez, geçici teknik inceleme nedeniyle ek bekleme yapılmasını istedi."
  - id: s4
    beceri: cikarim
    dayanak_sayfa: 3
    metin: "Yolcuların telafi önerisi neden uygulanmadı?"
    secenekler:
      - {id: A, metin: "Yolcuların bekleme süresini kendilerinin seçmiş olması"}
      - {id: B, metin: "Kontrol merkezinin o gece kapalı olması"}
      - {id: C, metin: "Telafi önerilerinin zaten uygulanmış olması"}
      - {id: D, metin: "Duraklama sürelerinin görevli talimatına bağlı olması"}
    dogru: D
    dayanak: "Duraklama sürelerinin görevli talimatlarına bağlı olduğu biliniyordu."
    aciklama: "Ek bekleme merkezden bildirildi; duraklama süreleri ise görevli talimatlarına bağlıydı, bu yüzden yolcuların telafi önerisi doğrudan uygulanmadı."
  - id: s5
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: "Hikâyede “telafi” sözcüğü neyi anlatır?"
    secenekler:
      - {id: A, metin: "Kaybedilen zamanı başka bir biçimde kapatmayı"}
      - {id: B, metin: "Bileti iade etmeyi"}
      - {id: C, metin: "Yolu tamamen değiştirmeyi"}
      - {id: D, metin: "Treni durdurmayı"}
    dogru: A
    dayanak: "Bazı yolcular, kaybedilen zamanı sonraki durakta daha az bekleyerek telafi etmeyi önerdi."
    aciklama: "Telafi, kaybedilen zamanı sonraki durakta daha az bekleyerek kapatmak demektir."
---
@omurga
{kahraman}, kıyı hattıyla dağ hattını birbirine bağlayan bir gece treniydi. O akşam istasyon panosunda iki farklı zaman çizelgesi asılıydı. Birinde eski sefer saatleri, diğerinde yeni düzenleme yazıyordu. Yolcular hangi saatin geçerli olduğunu sorunca istasyon görevlisi bir an duraksadı. Bir yolcu aktarmasını kaçırmaktan, başka biri de karşı istasyonda uzun süre beklemekten endişeleniyordu. {kahraman}, kesin bilgi alınmadan yola çıkmadı.
---
@omurga
Makinist, kontrol merkeziyle görüştü. Merkez, yeni çizelgenin ertesi sabah yürürlüğe gireceğini bildirdi. Bu gece eski çizelge geçerliydi. İstasyon görevlisi, iki kâğıdın üzerindeki tarihleri dikkatle karşılaştırdı. Tarih bilgisi gözden kaçırılsaydı {kahraman} yanlış saatle yola çıkabilirdi.
---
@omurga
Sefer başladıktan sonra hattın ilerleyen bölümünde beklenmedik bir durum ortaya çıktı. Kontrol merkezi, geçici teknik inceleme nedeniyle trenin bir istasyonda daha uzun beklemesi gerektiğini duyurdu. Bazı yolcular, kaybedilen zamanı sonraki durakta daha az bekleyerek telafi etmeyi önerdi. Duraklama sürelerinin görevli talimatlarına bağlı olduğu biliniyordu. Bu yüzden {kahraman} önerileri uygulamadı; makinistin merkezden bilgi almasını bekledi.
---
@omurga
Görevliler yolculuğun kalan bölümünü yeniden planladı. Güncel tahminî varış saati vagonda duyuruldu. Bir yolcu sonraki bağlantısını kontrol etmek için istasyon görevlisinden yardım istedi; başka biri kendisini karşılayacak kişiye haber gönderdi. Görevliler, bağlantısı olan her yolcuya kendi güzergâhını ve sonraki aktarmasını ayrı ayrı sordu.
---
@omurga
Son durakta istasyon görevlisi, aynı iki çizelgenin asılı olduğu panoya açık tarih etiketleri koydu. Sefer raporuna yaşanan beklemeyi ve yapılan duyuruları görevliler ekledi. Gece boyunca iki çizelge de panoda, üzerlerindeki açık tarih etiketleriyle kaldı.
