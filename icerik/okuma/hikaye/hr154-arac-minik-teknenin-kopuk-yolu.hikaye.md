---
baslik: Minik Teknenin Köpük Yolu
slug: hr154-arac-minik-teknenin-kopuk-yolu
fis_kodu: HR-154
tur: doga
konu: gol_temizligi
sinif_alt: 3
sinif_ust: 3
kahraman_turu: arac
deger_anahtarlari:
  - D18
  - D9
tanitim: Küçük bir temizlik teknesi gölde değişen bir köpük çizgisi görüyor. {kahraman} canlıları rahatsız etmeden kıyıyı temizliyor.
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: 2026-11-10
etiketler:
  ana_sinif: 3
  okuma_zorlugu: 2
  kavram_zorlugu: 2
  ilgi_egilimi: ortak
  temalar:
    - doga
  ders_baglantisi:
    - turkce
  maarif:
    ana_deger: D18
    yardimci_deger: D9
  ogrenme_hedefleri:
    - id: sozcuk1_hr154
      tur: lexeme
      etiket: kıyı
      yuva: hr154_kiyi
      islev: first_hint
    - id: sozcuk2_hr154
      tur: lexeme
      etiket: birikinti
      yuva: hr154_birikinti
      islev: application
    - id: sozcuk3_hr154
      tur: lexeme
      etiket: ağ
      yuva: hr154_ag
      islev: application
    - id: sozcuk4_hr154
      tur: lexeme
      etiket: akıntı
      yuva: hr154_akinti
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
    metin: Teknenin ilk gördüğü şey neydi?
    secenekler:
      - id: A
        metin: Suyu kesen büyük bir köprü
      - id: B
        metin: Uzun bir köpük çizgisi
      - id: C
        metin: Kıyıya düşmüş yaşlı bir ağaç
    dogru: B
    aciklama: Metindeki "Bir gün suyun üzerinde uzun bir köpük çizgisi gördü." cümlesi B seçeneğini doğrular. Köprü, düşmüş ağaç ve yeni iskele metinde hiç geçmez.
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "{kahraman} neden köpüğe rastgele madde dökmedi?"
    secenekler:
      - id: A
        metin: Teknenin boyası ve rengi zarar görmesin diye
      - id: B
        metin: Durumu bilmeden zarar vermemek için
      - id: C
        metin: Toplama kutusunda yer kalmadığı için
    dogru: B
    aciklama: Metindeki "Köpüğün nedenini bilmeden hiçbir maddeyi suya dökmedi." cümlesi, tekneyi sebebini bilmediği bir durumda zarar vermekten kaçındığını gösterir. Teknenin rengi, batan güneş ve dolu kutu metinde bu kararın nedeni olarak geçmez.
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: “Birikinti” sözcüğü neyi belirtir?
    secenekler:
      - id: A
        metin: Bir yerde toplanan parçaları
      - id: B
        metin: Güneşin suya vuran yansımasını
      - id: C
        metin: Kıyıda ziyaretçilerin oturduğu yeri
    dogru: A
    aciklama: Metindeki "Rüzgâr yön değiştirince yüzeydeki birikinti de başka yere kaydı." cümlesinde birikinti, yüzeyde bir araya gelmiş parçalardır; rüzgârla birlikte kayması bunu gösterir. Gölün derinliği, yansıma ve oturma yeri kayabilecek şeyler değildir.
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 3
    metin: Tekne sazlıklara neden girmedi?
    secenekler:
      - id: A
        metin: Köpüğün biriktiği yerden daha çok toplamak için
      - id: B
        metin: Görevliyi bekletmek için
      - id: C
        metin: Dinlenen kuşu ürkütmemek için
    dogru: C
    aciklama: Metindeki "Kıyıdaki sazlar arasında küçük bir kuş dinleniyordu." cümlesi, teknenin sazlığa girmeyerek kuşu ürkütmemeyi seçtiğini gösterir. Yolu kısaltmak, daha çok köpük toplamak ve görevliyi bekletmek metinde sazlıktan kaçınmanın nedeni değildir.
okuma_bandi: 1
dunya_tipi: gercekci
izinli_turler:
  - arac
yetiskin_uygun: false
---
@omurga

{kahraman} gölde çalışan küçük bir temizlik teknesiydi. Her sabah {kelime:hr154_kiyi} yakınındaki yaprakları ve çöpleri toplardı. Bir gün suyun üzerinde uzun bir köpük çizgisi gördü. Köpük, hafif {kelime:hr154_akinti} ile gölün bir köşesine taşınıyordu. {kahraman} oraya hızla gitmedi. Çünkü kıyıda dinlenen ördekleri ürkütmek istemiyordu. Önce yavaşça ilerledi, sonra yüzeyde biriken parçaları gözledi.

---

@omurga

{yoldas:yalin|Nazlı} köpüğün nereden geldiğini anlamak için suyu inceledi. {kahraman} ise yalnızca güvenli bölgede çalışıyordu. Önündeki geniş {kelime:hr154_ag} suyun üzerindeki küçük çöpleri topluyordu. Ağ, suyun içindeki canlılara zarar vermeyecek biçimde kullanılıyordu. Gölün kenarında bir plastik kap yüzüyordu. {kahraman} dikkatle yaklaşıp kabı toplama bölümüne aldı. Köpüğün nedenini bilmeden hiçbir maddeyi suya dökmedi.

---

@omurga

Rüzgâr yön değiştirince yüzeydeki {kelime:hr154_birikinti} de başka yere kaydı. {kahraman} görevlinin belirlediği yeni yola yöneldi. Sığ alanda hızını düşürdü. Su üstündeki çöp parçaları yavaşça ağa doldu. Kıyıdaki sazlar arasında küçük bir kuş dinleniyordu. {kahraman} o bölgeye girmedi. {yoldas:yalin|Nazlı}, gölün temiz kalması için çöplerin kıyıda da toplanması gerektiğini söyledi.

---

@omurga

Öğleden sonra kıyıya dönen {kahraman}, topladığı atıkları ayrılmış kutulara bıraktı. Görevli köpüğün nedenini anlamak için uzman incelemesinin sürdüğünü anlattı. Her köpüğün aynı sebeple oluşmadığını, bu yüzden acele karar verilmemesi gerektiğini belirtti. {kahraman} işinin bittiğini sanmadı. Ertesi gün için yeni bir kontrol rotası hazırladı. Dalgalar teknenin yanına usulca vuruyordu.

---

@omurga

Ertesi sabah göl daha temiz görünüyordu. Ördekler kıyıda sakin sakin yüzüyordu. {kahraman} suyun üstündeki son yaprakları topladı. Kıyı boyunca çöpler için yeni kutular konmuştu. Ziyaretçiler atıklarını buralara bırakmaya başladı. Küçük tekne kocaman gölün tamamını bir günde değiştiremezdi. Ama her sabah kıyıdan bir avuç yaprak ve çöp eksiliyor, ördeklerin yüzdüğü su biraz daha berraklaşıyordu.
