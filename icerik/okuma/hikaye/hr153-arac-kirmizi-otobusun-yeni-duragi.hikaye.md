---
baslik: Kırmızı Otobüsün Yeni Durağı
slug: hr153-arac-kirmizi-otobusun-yeni-duragi
fis_kodu: HR-153
tur: arkadaslik
konu: otobus_durak_uyumu
sinif_alt: 3
sinif_ust: 3
kahraman_turu: arac
deger_anahtarlari:
  - D14
  - D20
tanitim: Yeni kaldırım otobüse binmeyi güçleştiriyor. {kahraman} herkesin daha rahat yolculuğa başlayacağı durak düzenini bekliyor.
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: 2026-11-10
etiketler:
  ana_sinif: 3
  okuma_zorlugu: 2
  kavram_zorlugu: 2
  ilgi_egilimi: ortak
  temalar:
    - dostluk
  ders_baglantisi:
    - turkce
  maarif:
    ana_deger: D14
    yardimci_deger: D20
  ogrenme_hedefleri:
    - id: sozcuk1_hr153
      tur: lexeme
      etiket: kaldırım
      yuva: hr153_kaldirim
      islev: first_hint
    - id: sozcuk2_hr153
      tur: lexeme
      etiket: rampa
      yuva: hr153_rampa
      islev: application
    - id: sozcuk3_hr153
      tur: lexeme
      etiket: işaret
      yuva: hr153_isaret
      islev: application
    - id: sozcuk4_hr153
      tur: lexeme
      etiket: sıra
      yuva: hr153_sira
      islev: transfer
  kanit_duzeyi: C
  program_surumu: TYMM 2026-27 (3. sınıf); kazanım kodu yok (source_pending)
  denetim:
    ajan_a: pending
    ajan_b: pending
    insan: pending
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: Durağın önündeki sorun neydi?
    secenekler:
      - id: A
        metin: Kaldırımın zor geçilmesi
      - id: B
        metin: Otobüsün renginin değişmesi
      - id: C
        metin: Bütün lambaların sönmesi
    dogru: A
    aciklama: Metindeki "Yeni yapılan kaldırım yüzünden bekleyenler kapıya rahat ulaşamıyordu." cümlesi A seçeneğini doğrular. Otobüsün rengi değişmemiş, biletler kaybolmamış ve lambalar sönmemişti; B, C ve D bu yüzden yanlıştır.
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: Rampanın açılabilmesi neden önemlidir?
    secenekler:
      - id: A
        metin: Herkes güvenle binebilsin diye
      - id: B
        metin: Camların daha temiz kalması için
      - id: C
        metin: Durakta daha çok ışık olması için
    dogru: A
    aciklama: Metindeki "Kapısındaki rampa güvenle açılabilmeliydi." cümlesi, rampanın herkesin güvenle binmesi için gerektiğini gösterir. Hız, camların temizliği ve durağın aydınlığı metinde rampayla ilişkilendirilmez.
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: “Sıra” sözcüğü burada neyi anlatır?
    secenekler:
      - id: A
        metin: Otobüsün büyük tekerleğini
      - id: B
        metin: Bekleyenlerin dizilişini
      - id: C
        metin: Yolun uzayıp giden kısmını
    dogru: B
    aciklama: Metindeki "Biletini hazırlayanlar sıra boyunca ilerledi." cümlesinde sıra, yolcuların art arda dizilmiş hâlidir. Tekerlek, tabela ve yolun kısmı bu cümlede ilerleyen kişilerle ilgili değildir.
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: İşaret neden yeniden taşındı?
    secenekler:
      - id: A
        metin: Çöp kutusunu büyütmek için
      - id: B
        metin: Durağı başka yere almak için
      - id: C
        metin: Daha kolay görülsün diye
    dogru: C
    aciklama: Metindeki "Bunun üzerine işaret daha görünür bir yere taşındı." cümlesi, bazı kişilerin yerini şaşırması üzerine işaretin daha kolay görülsün diye taşındığını gösterir. Otobüsü saklamak, çöp kutusunu büyütmek ya da durağı başka yere almak metinde yoktur.
okuma_bandi: 1
dunya_tipi: gercekci
izinli_turler:
  - arac
yetiskin_uygun: false
---
@omurga

{kahraman} kırmızı bir şehir otobüsüydü. Her gün mahalledeki aynı duraklara uğrardı. Bir gün son durakta büyük bir kalabalık gördü. Yeni yapılan {kelime:hr153_kaldirim} yüzünden bekleyenler kapıya rahat ulaşamıyordu. {kahraman} durdu ve kapılarını açmadan önce güvenli yanaşma yerini aradı. Kaldırımın başında bir {kelime:hr153_isaret} vardı ama biraz ötede kalmıştı. İnsanlar nereye sıraya gireceklerini bilemiyordu. {kahraman} bu karışıklığın çözülmesini istiyordu.

---

@omurga

{yoldas:yalin|Ece}, duraktaki sorunu ulaşıma bildirdi. {kahraman} ertesi gün aynı yere geldiğinde yeni bir çizgi çekildiğini gördü. Çizgi, sıranın başlayacağı yeri gösteriyordu. Fakat kapının açıldığı yerde hâlâ dar bir boşluk vardı. {kahraman} kaldırımın doğru noktasına yanaştı. Kapısındaki {kelime:hr153_rampa} güvenle açılabilmeliydi. Rampa, tekerleklerin düz bir geçişle otobüse ulaşmasını sağlayan eğimli yüzeydi. Bu kez kimse telaşla kapıya koşmadı.

---

@omurga

Durağın çevresinde ölçüm yapıldı. Bekleme çizgisi biraz geri alındı. Çöp kutusu da geçiş yolundan uzaklaştırıldı. {kahraman} yeni yere yanaştığında kapının önü açıktı. Biletini hazırlayanlar {kelime:hr153_sira} boyunca ilerledi. Bir yolcu bastonuyla rahatça yürüyebildi. Sıranın sonundakiler öne geçmeye çalışmadan beklediler. {kahraman} herkesin yolculuğa aynı rahatlıkla başlamasını istedi. Güneş otobüsün camından içeri vuruyordu.

---

@omurga

İlk deneme yolculuğunda {yoldas:yalin|Ece} durakta bekledi. Birkaç kişinin yerini şaşırdığını gördü. Bunun üzerine işaret daha görünür bir yere taşındı. {kahraman} ikinci kez yanaştığında herkes kapının nerede açılacağını biliyordu. Kapı önünde sıkışma olmadı. Rampanın önü boş kaldı. Ulaşım görevlisi notlarına “Sıra çizgisi işe yaradı” yazdı. Kocaman bir otobüs için bile küçük bir çizgi büyük fark yaratmıştı.

---

@omurga

Akşam olunca {kahraman} son seferine çıktı. Yenilenen durakta bekleyenler düzenli bir sıra oluşturdu. Kapısı açılınca herkes rahatça bindi. Önceki günkü karışıklık yoktu. {kahraman} yola çıkarken aynasında düzgün kaldırımı gördü. Çizgiyi çekenleri, ölçüm yapanları ve işareti taşıyanları düşündü. Küçük bir düzeltme, bütün durağın gününü değiştirmişti. Kırmızı otobüs sonraki durağa huzurla ilerledi.
