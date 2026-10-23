---
baslik: "Kayıp Sandığın Şifresi"
slug: "hr021-kayip-sandigin-sifresi"
fis_kodu: "HR-021"
tur: macera
konu: ortak_hafiza
sinif_alt: 4
sinif_ust: 4
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D4, D16]
yetiskin_uygun: false
tanitim: "Sandığın dört yuvası, dört cümle ve dört fotoğraf. Şifre hangisi?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 4
  okuma_zorlugu: 3
  kavram_zorlugu: 3
  ilgi_egilimi: ortak
  temalar: [gizem, okul]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D4
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: album_hr021, tur: lexeme, etiket: "albüm", yuva: hr021_album, islev: first_hint}
    - {id: mandal_hr021, tur: lexeme, etiket: "mandal", yuva: hr021_mandal, islev: application}
    - {id: hatira_hr021, tur: lexeme, etiket: "hatıra", yuva: hr021_hatira, islev: application}
    - {id: deyim_hr021, tur: idiom, etiket: "Sözünü kesmek", yuva: hr021_sozunu_kesmek, islev: application}
    - {id: kavram_hr021, tur: concept, etiket: "Ortak hafıza", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (4. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 4, metin: "Sandıktan ne çıktı?", secenekler: [{id: A, metin: "Dört küçük defter, fotoğraflar ve kuru tohum"}, {id: B, metin: "Altın ve gümüş"}, {id: C, metin: "Eski haritalar"}, {id: D, metin: "Bir kitap ve bir anahtar"}], dogru: A, aciklama: "Sandıkta altın değil, defterler, fotoğraflar ve tohum çıktı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 5, metin: "Ömer neden hayal kırıklığına uğradı?", secenekler: [{id: A, metin: "Sandıkta altın çıkmadığı için"}, {id: B, metin: "Şifreyi çözemedikleri için"}, {id: C, metin: "Görevlinin kızdığı için"}, {id: D, metin: "Tohumların çok büyük olduğu için"}], dogru: A, aciklama: "Ömer altın bekliyordu ama içinden değerli bir hatıra çıktı."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 5, metin: "Ece'nin sandık için yazdığı cümleye göre en değerli şey nedir?", secenekler: [{id: A, metin: "İnsanların birlikte biriktirdiği anılar"}, {id: B, metin: "Altın ve gümüş"}, {id: C, metin: "Eski haritalar"}, {id: D, metin: "Kilitli bir kutu"}], dogru: A, aciklama: "Ece'ye göre sandığın en değerli şifresi birlikte biriktirilen anılardır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, metin: "Metinde geçen albüm ne demektir?", secenekler: [{id: A, metin: "Fotoğrafların saklandığı kitap"}, {id: B, metin: "Bir tür sandık"}, {id: C, metin: "Okulun bahçesi"}, {id: D, metin: "Eski bir harita"}], dogru: A, aciklama: "Albüm, fotoğrafların yerleştirilip saklandığı defter benzeri bir kitaptır."}
deyim_cumleleri:
  hr021_sozunu_kesmek: "{yoldas:yalin|bir arkadaş} sözünü kesti: “Peki ‘uzakları yakın eden’ neden dalga olsun?”"
---
@omurga
Kütüphanenin taşınacağı gün, dört arkadaş tozlu bir sandık buldu. Üzerinde güneş, yaprak, dalga ve yıldız şekilleri vardı. Fakat şekillerin bulunduğu dört küçük yuva boştu. Sandığın yanında, yıllar önce hazırlanmış bir not duruyordu: Bu sandık, bir sınıfın unutmadığı şeylerle açılır.

“İçinde ne olabilir?” diye fısıldadı {yoldas:yalin|bir arkadaş}.

“Eski haritalar!” dedi Defne. “Belki de gizli bir kulübün defteri.”

Kütüphane görevlisi sandığın okula ait olduğunu, önce içindekileri kayıt altına almaları gerektiğini söyledi. Kilidi zorlamamalarını da hatırlattı. Çocuklar notu dikkatle inceledi. Altında dört cümle daha vardı: Bizi ısıtan; büyümemizi sağlayan; uzakları yakın eden; gece yol gösteren.
---
@omurga
{kahraman} ilk cümleyi okuyunca güneşi düşündü. Ancak güneşin yerine hangi şeklin konacağını bilmiyorlardı. Okulun eski fotoğraf {kelime:hr021_album} aynı dört simgenin bulunduğu bir sayfa keşfettiler. Sayfanın altında “Dördüncü Sınıf Hatıra Projesi” yazıyordu. Albümde, öğrencilerin güneşli bir günde fidan diktiği, dere kıyısında temizlik yaptığı, yıldızları gözlediği ve uzaktaki bir sınıfa mektup gönderdiği fotoğraflar vardı. {isaret:kitap}

Albümün kenarında ayrıca dört farklı el yazısı vardı. Güneş fotoğrafının yanına “Birlikte ısındık”, fidanların altına “**Birlikte büyüttük**”, dere temizliğine “Birlikte koruduk”, yıldız gözlemine “Birlikte merak ettik” yazılmıştı. Defne bu cümleleri yüksek sesle okuduğunda {kahraman} sandığın notuyla aynı sözcüklerin tekrarlandığını fark etti. “Sanki biri hatırlamamızı istemiş,” dedi.
---
@omurga
{yoldas:yalin|bir arkadaş} sandığı açmak için sabırsızlanıyordu. “Bir denesek ne olur? Belki doğru şekil kendiliğinden oturur.” Görevli, parçaları zorlamanın eski kartonları kırabileceğini hatırlattı. Dört arkadaş masanın üzerinde kâğıttan bir sandık resmi çizdi, şekilleri önce oraya yerleştirdi. Bir şeyin cevabını bulmak için her zaman asıl nesneyi kurcalamak gerekmediğini keşfettiler.

Kerem, dört cümleyi fotoğraflarla eşleştirmek istedi.

Kerem, dört cümleyi fotoğraflarla eşleştirmek istedi. “Bizi ısıtan güneş. Büyümemizi sağlayan yaprak,” dedi.[[deyim:hr021_sozunu_kesmek]]

Defne bir fotoğrafı gösterdi. Dere kıyısındaki çalışmanın ardından çocuklar, temiz suyun uzak yerlerdeki canlılar için de önemli olduğunu anlatan bir mektup hazırlamışlardı. Ama dalganın doğrudan uzakları yakın ettiği kesin değildi. {kahraman}, “Belki notu yanlış yorumluyoruz,” diye düşündü. Yeniden albüme döndüler.
---
@omurga
Son sayfada küçük bir şiir vardı: Güneş sabahı getirir, yaprak yaşamı büyütür, dalga sesimizi taşır, yıldız geceyi süsler. Çocuklar bunun şifreyi değil, sınıfın dört etkinliğini hatırlatan bir sıra olduğunu anladı. Sandığın yanındaki çekmecede kartondan yapılmış dört şekil bulundu. Şekilleri albümdeki sıraya göre yerleştirdiklerinde sandığın mekanik {kelime:hr021_mandal} tık etti. Görevli kapağı kendisi açtı.

İçeriden altın çıkmadı. Dört küçük defter, öğrencilerin çekilmiş fotoğrafları ve bir paket kuru tohum çıktı. Defterlerin birinde şu cümle yazılıydı: Yıllar sonra açacak olanlara: Biz bu okulu yalnızca derslerimizle değil, birlikte yaptıklarımızla hatırlıyoruz.
---
@omurga
{yoldas:yalin|bir arkadaş} önce biraz hayal kırıklığına uğradı. Sonra tohum paketini eline aldı. “Bunları dikebilir miyiz?” diye sordu. Görevli, tohumların eski olduğu için filizlenmeyebileceğini, yine de denemelerini önerdi.

Çocuklar sandığın içindekileri düzenleyip okul arşivine teslim etti. Çekmecedeki dört şeklin kopyalarını da yeni {kelime:hr021_hatira} panosuna yerleştirdiler. Bir hafta sonra sınıflarına ait bir fotoğraf çektiler. Fotoğrafın arkasına herkes bir cümle yazdı. {kahraman:ilgi} cümlesi şuydu: Bir sandığın en değerli şifresi, insanların birlikte biriktirdiği anılardır.

Dil hedefi: eşleştirme, çıkarım, tahmin ve kanıt; Kavram/değer: mantıksal sıralama, ortak hafıza, iş birliği. İkon önerileri: sandık, şifre, fotoğraf. Okuma sonrası: Şifreyi çözmelerini sağlayan kanıt hangisiydi? Defterler neden değerliydi?
