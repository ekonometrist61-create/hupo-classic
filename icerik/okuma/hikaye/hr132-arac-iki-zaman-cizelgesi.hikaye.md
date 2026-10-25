---
baslik: "Araç ve İki Zaman Çizelgesi"
slug: "hr132-arac-iki-zaman-cizelgesi"
fis_kodu: "HR-132"
tur: bilim
konu: bilgi_guncelligi_tarih
sinif_alt: 5
sinif_ust: 5
kahraman_turu: arac
deger_anahtarlari: [D16, D1]
tanitim: "İstasyon panosunda eski ve yeni iki sefer çizelgesi asılıdır. Gece treni, hangi çizelgenin geçerli olduğunu tarihlere bakarak belirler."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-10-24"
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
      - {id: A, metin: "Yeni düzenlenmiş çizelge"}
      - {id: B, metin: "İkisi birden geçerliydi"}
      - {id: C, metin: "Eski çizelge"}
      - {id: D, metin: "Kıyı hattının ayrı çizelgesi"}
    dogru: C
    dayanak: "Bu gece eski çizelge geçerliydi."
    aciklama: "Yeni çizelge ertesi sabah yürürlüğe girecekti; bu gece eski çizelge geçerliydi."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Çizelgeleri ayıran önemli bilgi neydi?"
    secenekler:
      - {id: A, metin: "Kâğıtların rengi"}
      - {id: B, metin: "Yazıların büyüklüğü ve şekli"}
      - {id: C, metin: "Pano yüksekliği"}
      - {id: D, metin: "Üzerlerindeki tarihler"}
    dogru: D
    dayanak: "{kahraman}, iki kâğıdın üzerindeki tarihleri dikkatle karşılaştırdı."
    aciklama: "Çizelgeleri birbirinden ayıran, üzerindeki tarihlerdi."
  - id: s3
    beceri: hatirlama
    dayanak_sayfa: 3
    metin: "Tren neden ek bekleme yaptı?"
    secenekler:
      - {id: A, metin: "Bilet kontrolü için"}
      - {id: B, metin: "Yolcular uyuduğu için yavaşladı"}
      - {id: C, metin: "Teknik inceleme nedeniyle"}
      - {id: D, metin: "Yağmur başladı diye"}
    dogru: C
    dayanak: "Kontrol merkezi, geçici teknik inceleme nedeniyle trenin bir istasyonda daha uzun beklemesi gerektiğini duyurdu."
    aciklama: "Merkez, geçici teknik inceleme nedeniyle ek bekleme yapılmasını istedi."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 3
    metin: "Bekleme süresi niçin kendiliğinden değiştirilmedi?"
    secenekler:
      - {id: A, metin: "Görevli talimatı gerekliydi"}
      - {id: B, metin: "Çizelge tamamen kaybolmuştu"}
      - {id: C, metin: "İstasyon o gece kapanmıştı"}
      - {id: D, metin: "Saat bozulmuş olabilirdi"}
    dogru: A
    dayanak: "{kahraman}, duraklama sürelerinin görevli talimatlarına bağlı olduğunu biliyordu."
    aciklama: "Duraklama süreleri görevli talimatlarına bağlıydı; bu yüzden değiştirilmedi."
  - id: s5
    beceri: hatirlama
    dayanak_sayfa: 6
    metin: "Son durakta panoya ne eklendi?"
    secenekler:
      - {id: A, metin: "Eski fotoğraflar"}
      - {id: B, metin: "Açık tarih etiketleri"}
      - {id: C, metin: "Ayrıntılı bir yol haritası"}
      - {id: D, metin: "Yemek listesi"}
    dogru: B
    dayanak: "Son durakta istasyon görevlisi panodaki iki çizelgenin üzerine açık tarih etiketleri koydu."
    aciklama: "Görevli, iki çizelgenin üzerine açık tarih etiketleri koydu."
---
@omurga
{kahraman}, kıyı hattıyla dağ hattını birbirine bağlayan bir gece treniydi. O akşam istasyon panosunda iki farklı zaman çizelgesi asılıydı. Birinde eski sefer saatleri, diğerinde yeni düzenleme yazıyordu. Yolcular hangi saatin geçerli olduğunu sorunca {kahraman} şaşırdı. Bir yolcu aktarmasını kaçırmaktan, başka biri de karşı istasyonda uzun süre beklemekten endişeleniyordu. {kahraman}, kesin bilgi almadan yola çıkmamak gerektiğini düşündü.
---
@omurga
Makinist, kontrol merkeziyle görüştü. Merkez, yeni çizelgenin ertesi sabah yürürlüğe gireceğini bildirdi. Bu gece eski çizelge geçerliydi. {kahraman}, iki kâğıdın üzerindeki tarihleri dikkatle karşılaştırdı. Eski çizelgede bir küçük istasyonda beş dakikalık bekleme vardı. Yeni çizelgede bu bekleme kaldırılmıştı. Tarih bilgisi gözden kaçırılsaydı yolcular yanlış yönlendirilebilirdi.
---
@omurga
Sefer başladıktan sonra hattın ilerleyen bölümünde beklenmedik bir durum ortaya çıktı. Kontrol merkezi, geçici teknik inceleme nedeniyle trenin bir istasyonda daha uzun beklemesi gerektiğini duyurdu. Bazı yolcular, kaybedilen zamanı sonraki durakta daha az bekleyerek telafi etmeyi önerdi. {kahraman}, duraklama sürelerinin görevli talimatlarına bağlı olduğunu biliyordu. Bu yüzden önerileri doğrudan uygulamak yerine makinistin merkezden bilgi almasını bekledi.
---
@omurga
Görevliler yolculuğun kalan bölümünü yeniden planladı. Güncel tahmini varış saati vagonda duyuruldu. Bir yolcu sonraki bağlantısını kontrol etmek için istasyon görevlisinden yardım istedi; başka biri kendisini karşılayacak kişiye haber gönderdi. {kahraman}, herkese aynı çözümün uymadığını fark etti. Tren için ortak güzergâh vardı ama yolcuların sonraki adımları kendi koşullarına göre değişiyordu.
---
@omurga
Kalan yolculuk boyunca {kahraman}, eski ve yeni çizelgeleri zihninde karşılaştırdı. Bir çizelge, belli bir zamanda yapılması planlanan işleri gösteriyordu. Oysa plan, değişen koşullar karşısında yetkili kişilerce güncellenebilirdi.
---
@omurga
Son durakta istasyon görevlisi panodaki iki çizelgenin üzerine açık tarih etiketleri koydu. Böylece ertesi gün gelecek yolcular hangi bilgiyi kullanacağını anlayacaktı. {kahraman} sefer raporuna yaşanan beklemeyi ve yapılan duyuruları ekledi. Gece boyunca çizelgeler panoda kaldı; sabaha kadar kimse yanlış bilgiyle yola çıkmadı.
