---
baslik: "Yeniden Keşfedilen İskele"
slug: "hr156-arac-yeniden-kesfedilen-iskele"
fis_kodu: "HR-156"
tur: gezi_kultur
konu: elektrikli_feribot_duraklari
sinif_alt: 6
sinif_ust: 6
kahraman_turu: arac
deger_anahtarlari: [D17, D14]
tanitim: "Kıyıdaki bir iskele yeni ulaşım ihtiyacına cevap verebilir mi? {kahraman} enerji, güvenlik ve bekleme sürelerini birlikte değerlendiren bir rota keşfediyor."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 6
  maarif: {ana_deger: D17, yardimci_deger: D14}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr156, tur: lexeme, etiket: "rota", islev: first_hint}
  - {id: sozcuk2_hr156, tur: lexeme, etiket: "menzil", islev: application}
  - {id: sozcuk3_hr156, tur: lexeme, etiket: "iskele", islev: application}
  - {id: sozcuk4_hr156, tur: lexeme, etiket: "yoğunluk", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Yeni rota ihtiyacı neden doğdu?"
    secenekler:
      - {id: A, metin: "Feribotun boyası döküldüğü için"}
      - {id: B, metin: "Kıyılardan biri tamamen kapandığı için"}
      - {id: C, metin: "Bir iskelede yolcu yoğunluğu arttığı için"}
      - {id: D, metin: "Deniz haritası kaybolduğu için"}
    dogru: C
    dayanak: "Fakat yeni açılan bir yürüyüş alanı yüzünden bir iskelede yolcu yoğunluğu artmıştı."
    aciklama: "Metindeki \"Fakat yeni açılan bir yürüyüş alanı yüzünden bir iskelede yolcu yoğunluğu artmıştı.\" ifadesi doğru seçeneği destekler."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Eski iskele neden hemen kullanılmadı?"
    secenekler:
      - {id: A, metin: "Yolcu kullanımına güvenli olup olmadığı bilinmediği için"}
      - {id: B, metin: "Feribotun pencereleri küçük olduğu için"}
      - {id: C, metin: "Yeni tabela renkli olmadığı için"}
      - {id: D, metin: "Suyun rengi farklı olduğu için"}
    dogru: A
    dayanak: "Haritada yalnızca bakım alanı olarak işaretlenmişti; yolcu kullanımına uygun olup olmadığı bilinmiyordu."
    aciklama: "Metindeki \"Haritada yalnızca bakım alanı olarak işaretlenmişti; yolcu kullanımına uygun olup olmadığı bilinmiyordu.\" ifadesi doğru seçeneği destekler."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 2
    metin: "“Menzil” bu hikâyede ne demektir?"
    secenekler:
      - {id: A, metin: "Bir iskelede bekleyen kişi sayısı"}
      - {id: B, metin: "Enerjiyle gidilebilecek güvenli uzaklık"}
      - {id: C, metin: "Denizdeki dalgaların yüksekliği"}
      - {id: D, metin: "Feribotun içindeki koltuk sayısı"}
    dogru: B
    dayanak: "Menzil, bir aracın mevcut enerjiyle güvenle gidebileceği uzaklıktı."
    aciklama: "Metindeki \"Menzil, bir aracın mevcut enerjiyle güvenle gidebileceği uzaklıktı.\" ifadesi doğru seçeneği destekler."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "Ekip neden gecikmeleri de kaydetti?"
    secenekler:
      - {id: A, metin: "Sadece yeni levha hazırlamak için"}
      - {id: B, metin: "Yolculuğu zorlaştırmak için"}
      - {id: C, metin: "Eski rotayı gizlemek için"}
      - {id: D, metin: "Kararı eksiksiz verilere dayandırmak için"}
    dogru: D
    dayanak: "Ekip yalnızca başarılı örnekleri değil, gecikmeleri de kaydetti."
    aciklama: "Metindeki \"Ekip yalnızca başarılı örnekleri değil, gecikmeleri de kaydetti.\" ifadesi doğru seçeneği destekler."
---

@omurga

{kahraman} iki kıyı arasında yolcu taşıyan elektrikli bir feribottu. Günlük rotası kısa ve sakindi. Fakat yeni açılan bir yürüyüş alanı yüzünden bir iskelede yolcu yoğunluğu artmıştı. Herkes aynı feribota binmek isteyince bekleme süresi uzuyordu. Sabah ilk seferin kayıtlarında bekleme süresi özellikle iki saatte artıyordu. {kahraman} bu yoğunluk verisinin, yeni durak kararını nasıl etkilediğini anlamak istedi. Sakin saatlerde ek iskeleye uğramak yolcuları pek rahatlatmayacak, gereksiz enerji kullanacaktı. İşletme ekibi sayıları günlere göre de karşılaştırdı. {kahraman} yeni bir güzergâh düşünmeye başladı. Ancak hangi iskeleye uğrayacağına yalnızca kendi isteğiyle karar veremezdi. Kıyı işletmesinin güvenlik, zaman ve enerji planına uyması gerekiyordu. Feribotun kontrol sisteminde duraklardaki bekleme bilgileri toplanıyordu. Bu bilgiler sayesinde kalabalığın yalnızca hangi saatlerde oluştuğu değil, başka iskelelerin nasıl kullanıldığı da görülebilecekti.

---

@omurga

İlk incelemede kıyının daha sakin bir noktasında eski bir iskele bulundu. Haritada yalnızca bakım alanı olarak işaretlenmişti; yolcu kullanımına uygun olup olmadığı bilinmiyordu. {kahraman} bu konumu hemen rotasına eklemedi. Uzmanlar iskelenin yapısını, su derinliğini ve yanaşma koşullarını inceledi. Eski iskelenin girişinde kıyı boyunca uzanan taşlar vardı. Uzmanlar yolcu geçişinin bu alanla nasıl bağlantı kuracağını inceledi. {kahraman} yaklaşma açısının değişmesi hâlinde rotanın da yeniden hesaplanması gerektiğini biliyordu. Yanaşma düzeni ve erişim yolu aynı planda değerlendirildi. Yalnızca feribotun ulaşması yeterli değildi. Ayrıca bataryanın menzil sınırı hesaplandı. Menzil, bir aracın mevcut enerjiyle güvenle gidebileceği uzaklıktı. Yeni bir durak eklemek, yalnızca haritadaki çizgiyi uzatmak değildi. Şarj süresi, yolcu inişi ve hava koşulları da birlikte düşünülmeliydi. {kahraman} enerji göstergesindeki değişiklikleri izleyerek olası rotaları karşılaştırdı.

---

@omurga

Önerilen ilk rota bazı saatlerde beklemeyi azaltıyor ama günün sonunda fazla enerji tüketiyordu. İkinci öneri ise sakin iskeleyi yalnızca yoğun saatlerde kullanıyordu. {kahraman} bu seçeneğin daha dengeli olabileceğini fark etti. İşletme ekibi bekleme verilerini yeniden hesapladı. Yolculara da yeni düzenleme hakkında bilgi verildi. Yeni levhaların denenmesi için kıyıda küçük bir uygulama yapıldı. Bir görevli yolcu gibi yürüyerek her işareti takip etti. İki yön oku birbirine çok yakın duruyordu ve karışıklık yaratıyordu. {kahraman} bu yanlışlığın deneme başlamadan fark edilmesine sevindi. Levhaların biri kaydırıldı, duyuru metni de kısaltıldı. Kıyıda çalışan görevliler, durakların açıkça işaretlenmesi gerektiğini söyledi. Aksi hâlde insanlar yanlış sırada bekleyebilirdi. Yeni levhalar ve duyurular hazırlandı. Eski iskele uzman onayı almadan kullanılmadı. Böylece kolay görünen bir değişiklik, gerekli kontrollerle gerçek bir ulaşım planına dönüştü.

---

@omurga

Deneme günü {kahraman} yeni iskeleye güvenli hızla yaklaştı. İskele görevlileri hazırdı ve yolcular önceden belirtilmiş alanda bekliyordu. İlk yolculukta kapılar düzenli biçimde açıldı. Yaşlı bir ziyaretçi, yeni durak sayesinde uzun bir yürüyüş yapmadan sahile ulaştı. Deneme boyunca kıyının doğal alanlarına yaklaşılmadı. {kahraman} iskeleye ayrılan güvenli koridorun dışına çıkmadı. Yolcuların inişinden sonra kapılar kapanmadan hareket edilmedi. Ekibin çizelgesinde bu güvenlik adımları da yer alıyordu. Zaman kazanmak uğruna düzenli kontrol basamakları atlanmadı. Rota ancak bu koşullarla sürdürülebilirdi. {kahraman} enerji göstergesine baktı; beklenen değerlerin dışına çıkılmamıştı. Yolculuk sonunda personel zaman çizelgesini kontrol etti. Bazı seferlerde yine gecikme görülüyordu, fakat kalabalığın en yoğun olduğu saatlerde belirgin rahatlama yaşandı. Ekip yalnızca başarılı örnekleri değil, gecikmeleri de kaydetti.

---

@omurga

Bir ay sonra işletme yeni rotanın verilerini değerlendirdi. Yoğun saatlerdeki ek durak yararlı bulunmuş, sakin saatlerde kullanılmamasına karar verilmişti. {kahraman} böylece boş yere uzun yol gitmeyecekti. Enerji tasarrufu yapılırken yolcuların ihtiyacı da karşılanıyordu. Aylık değerlendirme toplantısında bir görevli bütün gün aynı rotayı kullanmayı önerdi. Başka bir görevli sakin saat verilerini gösterince karar yeniden ele alındı. {kahraman} koşullara göre değişen planın daha uygun olduğunu gördü. Kullanılmayan enerji, ilerideki seferler için korunacaktı. Kıyı yaşamı da gereksiz hareketle meşgul edilmeyecekti. Kıyı boyunca yürüyenler artık iki farklı iskele seçeneğini görebiliyordu. {kahraman} akşam son seferinden dönerken suyun üzerindeki ışıkları izledi. İyi bir rota yalnızca kısa olan değildi; doğru zamanda doğru yere uğrayandı. Eski harita tamamen atılmadı; üzerine yeni kullanım saatleri dikkatle eklendi.
