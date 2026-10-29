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
duzeltme_tarihi: "2026-10-24"
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
    dayanak: "Bu taşın dayanıklılığını, yani yüke karşı ne kadar sağlam kaldığını uzman ekip incelemeli"
    aciklama: "Metinde dayanıklılık, yüke karşı sağlam kalabilme anlamındadır."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "Kasabalılar köprü mühendisinin fikrini nasıl değiştirdiğini nereden öğrendi?"
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
Kasabanın küçük ırmağı üzerindeki taş köprü uzun yıllardır kullanılıyordu. Bir sabah köprünün yan duvarında ince bir çatlak görüldü. Köprü mühendisi {kahraman} oraya geldi. Çatlak, taşın üzerinde uzanan ince bir çizgi gibiydi. “Belki de su yükseldiği için oluştu,” dedi. Ancak bunun yalnızca bir tahmin, yani henüz doğrulanmamış bir düşünce olduğunu biliyordu. Güvenlik görevlileri köprüyü inceleme bitene kadar kullanıma kapattı.
---
@omurga
{kahraman} ve çizim uzmanı arkadaşı köprünün eski çizimlerini açtı. Çatlağı uzaktan fotoğraflayıp güvenli bir noktadan ölçüm yaptılar. Ölçüm, bir büyüklüğün ne kadar olduğunu belirlemek demekti. Cetvel ve işaretli bir ip kullandılar. Su düzeyinin daha önceki haftalarda yükselmediğini de kayıtlardan öğrendiler. “Demek ki ilk düşüncemiz doğru olmayabilir,” dedi {kahraman}.
---
@omurga
İki arkadaş eski çizimle yeni fotoğrafı yan yana koydu. Çatlağın, köprünün yıllar önce değiştirilmiş bir taşının yakınında olduğunu fark ettiler. “Bu taşın dayanıklılığını, yani yüke karşı ne kadar sağlam kaldığını uzman ekip incelemeli,” dedi {kahraman}. Köprünün neden çatladığını kesin olarak söylemek için daha fazla bilgi gerekiyordu. Ekip, taşın bağlantı noktalarını kontrol etti ve sorunlu bölgeyi belirledi.
---
@omurga
Kasabalılar köprünün ne zaman açılacağını merak ediyordu. {kahraman} onlara önceki tahmininin neden değiştiğini anlattı. “Kafa yorduk, ölçtük ve yeni bir iz bulduk,” dedi. Sonra uzmanlarla birlikte onarım planını hazırladı. İşçiler hasarlı taşı güvenli biçimde yeniledi. Kontrol tamamlanınca köprü yeniden açıldı.
---
@omurga
Köprüden ilk geçenler gülümseyerek birbirlerine el salladı. Arkadaşı, “Herkes senin fikrini değiştirmeni gördü,” dedi. {kahraman} da gülümsedi. “İlk tahminim yanlış olabilir. Önemli olan, elimizdeki bilgilere göre doğru kararı vermek.” Sonra ölçüm defterini kapattı.
