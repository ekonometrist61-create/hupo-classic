---
baslik: "Üç Renkli Takım"
slug: "hr028-uc-renkli-takim"
fis_kodu: "HR-028"
tur: arkadaslik
konu: takim_calismasi
sinif_alt: 3
sinif_ust: 3
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D4, D16]
yetiskin_uygun: false
tanitim: "Üç arkadaş, üç farklı yetenek. Birinci olamasalar da neyi kazandılar?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 3
  okuma_zorlugu: 2
  kavram_zorlugu: 2
  ilgi_egilimi: ortak
  temalar: [dostluk, dayanisma]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D4
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: bulmaca_hr028, tur: lexeme, etiket: "bulmaca", yuva: hr028_bulmaca, islev: first_hint}
    - {id: engel_hr028, tur: lexeme, etiket: "engel", yuva: hr028_engel, islev: application}
    - {id: sifre_hr028, tur: lexeme, etiket: "şifre", yuva: hr028_sifre, islev: application}
    - {id: kavram_hr028, tur: concept, etiket: "Bireysel güçlü yönler ve takım", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pass, ajan_b: review_needed, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, dayanak: "{kahraman} ip atlamayı, {yoldas:yalin|bir arkadaş} top sürmeyi, Cem ise {kelime:hr028_bulmaca} çözmeyi seviyordu.", metin: "Cem hangi işi seviyordu?", secenekler: [{id: A, metin: "İp atlayıp zıplamayı"}, {id: B, metin: "Bulmaca çözmeyi"}, {id: C, metin: "Top sürmeyi"}], dogru: B, aciklama: "Cem bulmaca çözmeyi seviyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, dayanak: "Kırmızı, maviden önce; sarı, kırmızıdan sonra; mavi ise en sonda.", metin: "Notun söylediğine göre kartlar hangi sırayla dizilmeliydi?", secenekler: [{id: A, metin: "Sarı, mavi, kırmızı"}, {id: B, metin: "Kırmızı, sarı, mavi"}, {id: C, metin: "Kırmızı, mavi, sarı"}], dogru: B, aciklama: "Kırmızı maviden önce, sarı kırmızıdan sonra, mavi en sonda olmalıydı."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, dayanak: "{yoldas:yalin|bir arkadaş} kartı alıp görevliye teslim etti.", metin: "Cem, arkadaşının en hızlı olduğu şeyin yalnız koşmak olmadığını neden düşündü?", secenekler: [{id: A, metin: "Düşen kartı geri verdiği için"}, {id: B, metin: "Herkesten çok hızlı koştuğu için"}, {id: C, metin: "Topu sert attığı için"}], dogru: A, aciklama: "Arkadaşı başka takımın düşen kartını görevliye teslim etti; Cem de yalnız hızın değil yardımın da değerli olduğunu gördü."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 1, dayanak: "İlk durakta ip atlayarak bir {kelime:hr028_engel} aşılacak, ikinci durakta top hedefe atılacak, son durakta renkli kartların {kelime:hr028_sifre} çözülecekti.", metin: "“İp atlayarak bir engel aşılacak” cümlesinde engel ne demektir?", secenekler: [{id: A, metin: "Takımın aldığı kurdele"}, {id: B, metin: "Arkadaşa verilen renkli kart"}, {id: C, metin: "Geçmeyi zorlaştıran şey"}], dogru: C, aciklama: "Engel, geçilmesi zor olan şeydir."}
---
@omurga
Okul bahçesinde “Üç Renkli Oyun” yapılacaktı. Takımlar üç kişiydi. {kahraman} ip atlamayı, {yoldas:yalin|bir arkadaş} top sürmeyi, Cem ise {kelime:hr028_bulmaca} çözmeyi seviyordu. Üçü aynı takıma seçilince {yoldas:yalin|bir arkadaş} homurdandı: “Biz hiç aynı oyunu sevmiyoruz.”

Öğretmenleri kuralları açıkladı. İlk durakta ip atlayarak bir {kelime:hr028_engel} aşılacak, ikinci durakta top hedefe atılacak, son durakta renkli kartların {kelime:hr028_sifre} çözülecekti. Takımın başarısı için üç görev de gerekliydi.

Başlama işareti verilince {yoldas:yalin|bir arkadaş} öne fırladı. Fakat ilk durakta ipe takıldı ve yere oturdu. {kahraman} ona yavaşça gösterdi: “Önce sağ ayak, sonra sol. Acele etme.” {yoldas:yalin|bir arkadaş} denedi ve geçti.
---
@omurga
Top durağında {kahraman} topu iki kez kaçırdı. {yoldas:yalin|bir arkadaş} kızmak üzereydi, sonra ilk durakta aldığı yardımı hatırladı. “Topu sert değil, kontrollü gönder,” dedi. {kahraman} bu kez hedefi buldu. Cem alkışladı.

Son durakta masaya üç kart koyulmuştu: kırmızı, mavi ve sarı. Yanlarındaki notta şöyle yazıyordu: Kırmızı, maviden önce; sarı, kırmızıdan sonra; mavi ise en sonda. Cem kartları sıraya dizdi. Fakat öğretmen ilk dizilişi onaylamadı.

Cem dikkatle düşündü. “Sarı, kırmızıdan sonra olabilir; ama maviden önce olmak zorunda mı?” diye sordu. {kahraman}, “Mavi en son,” dedi. “Öyleyse sıra kırmızı, sarı, mavi!”
---
@omurga
Tam son kartı yerleştirirken bir rüzgâr çıktı ve mavi kart uçtu. {yoldas:yalin|bir arkadaş} arkasından koşmaya kalktı, fakat öğretmen bahçe sınırını gösterdi. {kahraman}, görevliden yedek kart istedi. Yarış biraz gecikti ama kurallara uydular.

Yarışın sonlarına doğru başka bir takımın kartlarından biri de yere düştü. {yoldas:yalin|bir arkadaş} onu görünce bir an tereddüt etti. Kartı geri vermek için durursa kendi takımları daha da yavaşlayacaktı. {kahraman} gözleriyle ne yapacağını sordu. {yoldas:yalin|bir arkadaş} kartı alıp görevliye teslim etti. “Onlar da oyunu bitirebilsin,” dedi. Cem hafifçe gülümsedi; {yoldas:ilgi|bir arkadaşın} en hızlı olduğu şeyin yalnız koşmak olmadığını düşündü.
---
@omurga
Son kartları dizdikten sonra üç arkadaş ellerini üst üste koydu. {kahraman} ip atlamayı bilmeyenlere yeniden göstermeyi, {yoldas:yalin|bir arkadaş} topu korkmadan deneyenlere cesaret vermeyi, Cem ise zor bilmecelerin ipuçlarını paylaşmayı teklif etti. {isaret:kalp}

Sonuçlar açıklandığında birinci olamadılar, üçüncü oldular. Görevli üç arkadaşa birer kurdele verdi: kırmızı, mavi ve sarı. {yoldas:yalin|bir arkadaş} kurdelesini boynuna takarken biraz üzgündü. Cem üç kurdeleyi yan yana dizdi. “Tıpkı kart sırası gibi,” dedi. {kahraman} sarı kurdeleyi kırmızının yanına koydu.

Ertesi gün {yoldas:yalin|bir arkadaş} bir öneriyle geldi: “Bu kez herkesin sevdiği bir oyunu birlikte deneyelim.” Önce ip atladılar, sonra top oynadılar, en sonda Cem'in bilmecelerini çözdüler. {kahraman} her oyunun başında kurdelesini koluna bağladı.