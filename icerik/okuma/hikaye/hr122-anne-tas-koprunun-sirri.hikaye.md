---
baslik: "Taş Köprünün Sırrı"
slug: "hr122-anne-tas-koprunun-sirri"
fis_kodu: "HR-122"
tur: bilim
konu: olcum_tahmin_kanit
sinif_alt: 3
sinif_ust: 3
kahraman_turu: anne
deger_anahtarlari: [D6, D16]
tanitim: "Kasabanın taş köprüsünde bir çatlak görülür. Köprü mühendisi {kahraman}, ilk tahmini doğru mu diye ölçerek ve kayıtlara bakarak sınar."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-08"
etiketler:
  ana_sinif: 3
  maarif: {ana_deger: D6, yardimci_deger: D16}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: olcum_hr122, tur: lexeme, etiket: "ölçüm", islev: first_hint}
  - {id: catlak_hr122, tur: lexeme, etiket: "çatlak", islev: application}
  - {id: dayaniklilik_hr122, tur: lexeme, etiket: "dayanıklılık", islev: application}
  - {id: tahmin_hr122, tur: lexeme, etiket: "tahmin", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Köprüdeki çatlağın ilk nedeni olarak ne düşünüldü?"
    secenekler:
      - {id: A, metin: "Kuvvetli rüzgâr"}
      - {id: B, metin: "Yoğun trafik"}
      - {id: C, metin: "Yükselen su"}
      - {id: D, metin: "Yeni boya"}
    dogru: C
    dayanak: "Belki de su yükseldiği için oluştu"
    aciklama: "Mühendis ilk tahminini yükselen suya bağlamıştı."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "İlk düşüncenin değişmesine hangi bilgi katkı sağladı?"
    secenekler:
      - {id: A, metin: "Su düzeyinin yükselmemesi"}
      - {id: B, metin: "Köprünün rengi ve boyası"}
      - {id: C, metin: "Kasabanın adı ve tarihi"}
      - {id: D, metin: "Havanın sıcaklığı ve rüzgârı"}
    dogru: A
    dayanak: "Su düzeyinin daha önceki haftalarda yükselmediğini de kayıtlardan öğrendiler."
    aciklama: "Kayıtlar, su düzeyinin yükselmediğini gösterdi; ilk tahmin bu yüzden doğru değildi."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: "“Dayanıklılık” bu metinde neyi anlatır?"
    secenekler:
      - {id: A, metin: "Taşın rengini ve parlaklığını"}
      - {id: B, metin: "Taşın sağlam kalabilmesini"}
      - {id: C, metin: "Taşın yaşını ve geçmişini"}
      - {id: D, metin: "Taşın biçimini ve kalınlığını"}
    dogru: B
    dayanak: "“Bu taşın dayanıklılığına uzman ekip bakmalı,” dedi {kahraman}. Taş, köprünün ağırlığını yıllarca sağlam taşıyabilecek mi?"
    aciklama: "Metinde dayanıklılık, köprünün ağırlığını uzun süre taşıyabilme, yani sağlam kalabilme anlamındadır."
  - id: s4
    beceri: hatirlama
    dayanak_sayfa: 4
    metin: "Kasabalılar mühendisin önceki tahmininin neden değiştiğini nereden öğrendi?"
    secenekler:
      - {id: A, metin: "Bir yarışma duyurusundan"}
      - {id: B, metin: "Yazdığı kısa öyküden"}
      - {id: C, metin: "Kendisinden dinleyince"}
      - {id: D, metin: "Yerel radyo yayınından duyunca"}
    dogru: C
    dayanak: "{kahraman} onlara önceki tahmininin neden değiştiğini anlattı."
    aciklama: "Mühendis, değişikliği kasabalılara kendisi anlattı."
---
@omurga
Kasabanın küçük ırmağı üzerindeki taş köprü uzun yıllardır kullanılıyordu. Bir sabah köprünün yan duvarında ince bir çatlak görüldü. Köprü mühendisi {kahraman} oraya geldi. Çatlak, taşın üzerinde uzanan ince bir çizgi gibiydi. “Belki de su yükseldiği için oluştu,” dedi. Ancak bunun yalnızca bir tahmin olduğunu biliyordu. Güvenlik görevlileri köprüyü inceleme bitene kadar kullanıma kapattı.
---
@omurga
{kahraman} ve çizim uzmanı arkadaşı köprünün eski çizimlerini açtı. Çatlağın fotoğrafını güvenli bir noktadan çektiler. Sonra çatlağın köprü kenarına olan uzaklığını görevlilerin izniyle, yakından cetvel ve bölmeli bir ip kullanarak ölçtüler: çatlak kenara yalnızca iki adım uzaklıktaydı. Su düzeyinin daha önceki haftalarda yükselmediğini de kayıtlardan öğrendiler. “Demek ki ilk düşüncemiz doğru olmayabilir,” dedi {kahraman}.
---
@omurga
İki arkadaş eski çizimle yeni fotoğrafı yan yana koydu. Çatlağın, köprünün yıllar önce değiştirilmiş bir taşının yakınında olduğunu fark ettiler. “Bu taşın dayanıklılığına uzman ekip bakmalı,” dedi {kahraman}. Taş, köprünün ağırlığını yıllarca sağlam taşıyabilecek mi? Köprünün neden çatladığını kesin olarak söylemek için daha fazla bilgi gerekiyordu. Ekip, taşların birleştiği yerleri kontrol etti ve sorunlu bölgeyi belirledi.
---
@omurga
Kasabalılar köprünün ne zaman açılacağını merak ediyordu. {kahraman} onlara önceki tahmininin neden değiştiğini anlattı. “Kafa yorduk, ölçtük ve yeni bir iz bulduk,” dedi. Sonra uzmanlarla birlikte onarım planını hazırladı. İşçiler hasarlı taşı güvenli biçimde yeniledi. Kontrol tamamlanınca köprü yeniden açıldı.
---
@omurga
Köprüden ilk geçenler gülümseyerek birbirlerine el salladı. {kahraman} da gülümsedi. Sonra ölçüm defterini kapattı.
