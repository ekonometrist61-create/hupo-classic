---
baslik: "Bulut Postacısının Son Mektubu"
slug: "hr024-bulut-postacisinin-son-mektubu"
fis_kodu: "HR-024"
tur: fantastik
konu: yon_adres
sinif_alt: 3
sinif_ust: 3
okuma_bandi: 2
dunya_tipi: masalsi
izinli_turler: [hayali]
deger_anahtarlari: [D16, D5]
yetiskin_uygun: false
tanitim: "Zarftaki adres yanlış mı, yoksa pusula mı yanılıyor? Pofuduk doğru eve nasıl ulaştı?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 3
  okuma_zorlugu: 2
  kavram_zorlugu: 2
  ilgi_egilimi: ortak
  temalar: [kesif, dostluk]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D16
    yardimci_deger: D5
  ogrenme_hedefleri:
    - {id: pusula_hr024, tur: lexeme, etiket: "pusula", yuva: hr024_pusula, islev: first_hint}
    - {id: adres_hr024, tur: lexeme, etiket: "adres", yuva: hr024_adres, islev: application}
    - {id: yon_hr024, tur: lexeme, etiket: "yön", yuva: hr024_yon, islev: application}
    - {id: deyim_hr024, tur: idiom, etiket: "Gözleri parlamak", yuva: hr024_gozleri_parladi, islev: application}
    - {id: kavram_hr024, tur: concept, etiket: "Yön bilgisi ile süs arasındaki fark", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Zarfta hangi adres yazıyordu?", secenekler: [{id: A, metin: "Deniz Kıyısı, Kırmızı Ev"}, {id: B, metin: "Kuzey Tepesi, Mavi Pencereli Ev"}, {id: C, metin: "Güney Vadisi"}], dogru: B, aciklama: "Zarfın üzerinde Kuzey Tepesi, Mavi Pencereli Ev yazıyordu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 1, metin: "Pofuduk'un bir terslik olduğunu anlamasının nedeni neydi?", secenekler: [{id: A, metin: "Çantası çok ağırdı"}, {id: B, metin: "Yağmur başlamıştı"}, {id: C, metin: "Pusula kuzeyi gösterirken kendisi güneye gidiyordu"}], dogru: C, aciklama: "Pusulanın gösterdiği yönle uçuş yönü uyuşmuyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 2, metin: "Pofuduk zarftaki yıldız hakkında ne sonuca vardı?", secenekler: [{id: A, metin: "Yön göstermeyen, yalnızca süs olan bir resim"}, {id: B, metin: "Hazine haritası"}, {id: C, metin: "Ev numarası"}], dogru: A, aciklama: "Pofuduk yıldızın yön göstermediğini, sadece süs olduğunu anladı."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, metin: "Metinde geçen yön sözcüğü ne anlama gelir?", secenekler: [{id: A, metin: "Bir mektup türü"}, {id: B, metin: "Gidilecek doğrultu"}, {id: C, metin: "Bir bulut rengi"}], dogru: B, aciklama: "Yön, bir yere giderken izlenecek doğrultudur."}
deyim_cumleleri:
  hr024_gozleri_parladi: "Zarfı açınca gözleri parladı."
---
@omurga
Bulutlar Şehri'nde herkesin bir görevi vardı. Yağmur Bulutu bahçeleri sular, {yoldas:yalin|bir arkadaş} yelkenlere yardım eder, Postacı {kahraman} ise mektupları götürürdü. O sabah {kahraman:ilgi} çantasında yalnızca bir zarf kalmıştı. Üzerinde şu {kelime:hr024_adres} yazıyordu: Kuzey Tepesi, Mavi Pencereli Ev.

{kahraman} kuzeye uçtuğunu sanıyordu. Fakat birkaç dakika sonra altındaki deniz yerine kocaman bir çöl gördü. “Bu işte bir terslik var,” diye mırıldandı. Çantasındaki {kelime:hr024_pusula} çıkardı. İbre kuzeyi gösterirken kendisi güneye ilerliyordu.

{yoldas:yalin|bir arkadaş} yanına sokuldu. “Ben seni sürükledim, özür dilerim.”

“Önemli değil,” dedi {kahraman}. “Ama mektup sahibini bekletmeyelim.”
---
@omurga
İkisi birlikte {kelime:hr024_yon} düzeltti. Derken birbirine benzeyen iki tepe gördüler. Birinde kırmızı çatılı, diğerinde mavi pencereli ev vardı. {kahraman} hemen aşağı inecekti ki bir ayrıntıyı fark etti: Mavi pencere güneş ışığından mı mavi görünüyordu, yoksa gerçekten maviye mi boyanmıştı?

Aşağıdaki kuş sürüsüne seslendi. Kuşların lideri, mavi pencereli evin kuzeydeki ikinci tepede olduğunu söyledi. {kahraman} teşekkür etti; adresin yalnızca renk değil, yön bilgisi de verdiğini anladı.

{kahraman} evin çatısına konmadan önce çantasını kontrol etti. Yağmur Bulutu biraz önce yanından geçmişti; zarfın ıslanmaması için onu dikkatle saklamıştı. Zarfın köşesindeki pulun üzerinde küçük bir yıldız vardı. Postacı, yıldızın yön göstermediğini, yalnız süs olduğunu fark etti. Bir resim, her zaman haritadaki bir işaret değildi. {isaret:yildiz}
---
@omurga
Tam mektubu bırakacağı sırada evin penceresi açıldı. İçeriden gelen ses, “Mavi pencereyi mi arıyorsun?” diye sordu. {kahraman} adresi bir kez daha okudu ve tepeyi teyit etti. Yanlış bir eve gidip başkasının haberini paylaşmak istemiyordu. Zarfın üzerindeki ismi ve kapıdaki ismi karşılaştırdı. İkisi de aynıydı. Ancak ondan sonra yaklaşarak mektubu verdi.

Evde yaşlı bir teyze yaşıyordu.

Evde yaşlı bir teyze yaşıyordu.[[deyim:hr024_gozleri_parladi]] Uzakta okuyan torunu, kendi yaptığı çizimin fotoğrafını göndermişti. Mektupta Büyüyünce bulut ressamı olacağım yazıyordu.

{kahraman} teyzenin gülümsemesini görünce yorgunluğunu unuttu. “Bir mektup bu kadar önemli olabilir mi?” diye sordu.
---
@omurga
“Elbette,” dedi teyze. “Bazen bir haber, uzağı yakın eder.”

{kahraman} dönüş yolunda çantasını boş buldu ama kendisini eksik hissetmedi. O gün bir zarfın yalnız kâğıt değil, sevincin taşıyıcısı olduğunu öğrenmişti. Yeni bir mektup geldiğinde adresin yönünü iki kez kontrol edecekti.

Bulutlar Şehri'ne döndüğünde pusulasını girişteki panoya astı. Altına küçük bir not ekledi: Bir yere yetişmek kadar, **doğru yere varmak** da önemlidir. {yoldas:yalin|bir arkadaş} notu okuyup güldü. “Bir dahaki sefere önce birlikte haritaya bakalım!” dedi.

Dil hedefi: kuzey–güney, adres, yön bilgisi; Kavram/değer: sorumluluk, özür, duygusal bağ. İkon önerileri: bulut, zarf, pusula. Okuma sonrası: {kahraman} hangi hatayı fark etti? Mektup neden değerliydi?
