---
baslik: "Annem ve Şaşırtan Cetvel"
slug: "hr130-anne-saskinlik-cetvel"
fis_kodu: "HR-130"
tur: bilim
konu: olcum_hata_duzeltme
sinif_alt: 3
sinif_ust: 3
kahraman_turu: anne
deger_anahtarlari: [D6, D3]
tanitim: "Kütüphanenin yeni kitap köşesine raf sığmaz. Köprü mühendisi {kahraman}, kırık bir cetvelin hatalı ölçtüğünü fark edip ölçümü yeniden yapar."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-10-24"
etiketler:
  ana_sinif: 3
  maarif: {ana_deger: D6, yardimci_deger: D3}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: tahmin_hr130, tur: lexeme, etiket: "tahmin", islev: first_hint}
  - {id: olcum_hr130, tur: lexeme, etiket: "ölçüm", islev: application}
  - {id: yerlesim_hr130, tur: lexeme, etiket: "yerleşim", islev: application}
  - {id: kullanisli_hr130, tur: lexeme, etiket: "kullanışlı", islev: transfer}
sorular:
  - id: s1
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Raf neden boşluğa oturmadı?"
    secenekler:
      - {id: A, metin: "İlk ölçüm hatalıydı"}
      - {id: B, metin: "Duvarın yeni boyandığı için"}
      - {id: C, metin: "Kitap sayısı çok fazlaydı"}
      - {id: D, metin: "Rafın bir parçası kaybolmuştu"}
    dogru: A
    dayanak: "{kahraman}, önceki ölçümün hatalı olduğunu anladı."
    aciklama: "Önceki ölçüm yanlıştı; raf bu yüzden oturmadı."
  - id: s2
    beceri: hatirlama
    dayanak_sayfa: 2
    metin: "İlk cetvelin sorunu neydi?"
    secenekler:
      - {id: A, metin: "Çok renkliydi ve epey parlaktı"}
      - {id: B, metin: "Bir ucu duvara değmiyordu"}
      - {id: C, metin: "Okuldan yeni alınmıştı"}
      - {id: D, metin: "Sıfır noktası görünmüyordu"}
    dogru: D
    dayanak: "Bu nedenle cetvelin sıfır noktası görünmüyordu."
    aciklama: "Cetvelin başındaki kırık yüzünden sıfır noktası görünmüyordu."
  - id: s3
    beceri: hatirlama
    dayanak_sayfa: 3
    metin: "Eski rafın yerine ne yapıldı?"
    secenekler:
      - {id: A, metin: "Uygun boydaki raf seçildi"}
      - {id: B, metin: "Raf zorla boşluğa itildi"}
      - {id: C, metin: "Boşluk büyütüldü"}
      - {id: D, metin: "Kitaplar tamamen kaldırıldı"}
    dogru: A
    dayanak: "Eski rafı zorlayarak yerleştirmek yerine uygun boydaki rafı seçtiler."
    aciklama: "Eski raf zorlanmadı; uygun boydaki raf seçildi."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 2
    metin: "Ölçümü yeniden yapmak neyi sağladı?"
    secenekler:
      - {id: A, metin: "Köşenin tamamen kapanmasını"}
      - {id: B, metin: "Hatalı bilginin düzelmesini"}
      - {id: C, metin: "Cetvelin yeniden boyanmasını"}
      - {id: D, metin: "Çizimin tamamen atılmasını"}
    dogru: B
    dayanak: "Sağlam cetvelle genişliği bir kez daha ölçtü."
    aciklama: "Sağlam cetvelle yapılan ölçüm, hatalı bilgiyi düzeltti."
---
@omurga
Kasabanın küçük kütüphanesinde yeni bir kitap köşesi hazırlanıyordu. Köprü mühendisi {kahraman}, gönüllü olarak rafların yerleşimine yardım etti. Masanın üstünde bir çizim ve iki cetvel vardı. Görevli, duvarın önündeki boşluğun bir raf için uygun olduğunu söyledi. {kahraman} çizime bakarak rafın sığacağını tahmin etti. Fakat raf geldiğinde boşluğa tam oturmadı.
---
@omurga
{kahraman}, görevliyle birlikte duvarı yeniden ölçmeye başladı. İlk cetvelin başında küçük bir kırık vardı. Bu nedenle cetvelin sıfır noktası görünmüyordu. {kahraman}, önceki ölçümün hatalı olduğunu anladı. Sağlam cetvelle genişliği bir kez daha ölçtü. Yeni sonuç, raftan biraz daha küçüktü.
---
@omurga
“Bazen sorun düşündüğümüz yerde değildir,” dedi {kahraman}. Görevli başka bir raf önerdi, ancak bu rafın da yüksekliğini kontrol etmek gerekiyordu. Birlikte yeni rafın ölçülerini not ettiler. Kitap köşesinin çizimini değiştirdiler. Eski rafı zorlayarak yerleştirmek yerine uygun boydaki rafı seçtiler. Böylece duvara ve raflara zarar verme riskinden kaçındılar.
---
@omurga
Ertesi gün görevliler uygun rafı güvenli biçimde yerleştirdi. {kahraman}, çocuklar için alçak bir kitap sepetinin de çizimde gösterilmesini önerdi. Kitaplar düzenlenince okuma köşesi daha kullanışlı oldu. Görevli, “İlk bakışta cetvelin kırık ucunu gözden kaçırmışız,” dedi. {kahraman} gülümsedi: “Önemli olan bunu fark edince ölçümü yeniden yapabilmek.”
---
@omurga
Açılış günü çocuklar kitap köşesini çok sevdi. {kahraman} eski ve yeni çizimi yan yana astı. Yanına ölçülerin nasıl alındığını yazdı. Kütüphaneye gelenler yeni köşeyi uzun uzun inceledi.
