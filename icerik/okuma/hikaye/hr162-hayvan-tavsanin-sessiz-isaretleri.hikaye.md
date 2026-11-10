---
baslik: "Tavşanın Kozalak İzleri"
slug: "hr162-hayvan-tavsanin-sessiz-isaretleri"
fis_kodu: "HR-162"
tur: arkadaslik
konu: orman_yon_bulma
sinif_alt: 5
sinif_ust: 5
kahraman_turu: hayvan
deger_anahtarlari: [D4, D5]
tanitim: "Yağmur orman patikalarındaki eski işaretleri silmiş. {kahraman} arkadaşlarıyla birlikte herkesin aynı şeyi anlayacağı kozalak işaretleri kuruyor."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 5
  maarif: {ana_deger: D4, yardimci_deger: D5}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr162, tur: lexeme, etiket: "işaret", islev: first_hint}
  - {id: sozcuk2_hr162, tur: lexeme, etiket: "rota", islev: application}
  - {id: sozcuk3_hr162, tur: lexeme, etiket: "durak", islev: application}
  - {id: sozcuk4_hr162, tur: lexeme, etiket: "anlaşma", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Meyve paylaşım günü yaklaşırken eski yol işaretlerine ne olmuştu?"
    secenekler:
      - {id: A, metin: "Renkleri solup maviye dönmüştü"}
      - {id: B, metin: "Bütün işaretler başka yere taşınmıştı"}
      - {id: C, metin: "Yağmur bir kısmını silmişti"}
      - {id: D, metin: "Üzerleri çiçeklerle örtülmüştü"}
    dogru: C
    dayanak: "Ancak yeni yağan yağmur, eski yol işaretlerinin bir kısmını silmişti."
    aciklama: "Metindeki \"Ancak yeni yağan yağmur, eski yol işaretlerinin bir kısmını silmişti.\" cümlesi C seçeneğini doğrular. İşaretlerin rengi değişmemiş, taşınmamış ve çiçeklerle örtülmemişti; bu yüzden A, B ve D yanlıştır."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "{kahraman} üç kozalaklı ilk işareti neden değiştirdi?"
    secenekler:
      - {id: A, metin: "Sincap onu oyun sandığı için"}
      - {id: B, metin: "Kozalaklar çok ağır olduğu için"}
      - {id: C, metin: "Köprü çok yüksek olduğu için"}
      - {id: D, metin: "Yol çok kısa olduğu için"}
    dogru: A
    dayanak: "Fakat sincap, üç kozalağı görünce bunun bir oyun işareti olduğunu sandı."
    aciklama: "Metindeki \"Fakat sincap, üç kozalağı görünce bunun bir oyun işareti olduğunu sandı.\" cümlesi, işaretin yol bilgisi olarak okunmadığını gösterir; bu yüzden yeni bir anlaşma gerekti. Kozalakların ağırlığı, köprünün yüksekliği ve yolun uzunluğu metinde değişiklik nedeni olarak geçmez."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 2
    metin: "“Rota” sözcüğü bu cümlede hangi anlamda kullanılmıştır?"
    secenekler:
      - {id: A, metin: "Meyvelerin tadı"}
      - {id: B, metin: "İzlenecek yol"}
      - {id: C, metin: "Ağaçların gölgesi"}
      - {id: D, metin: "Kozalakların rengi"}
    dogru: B
    dayanak: "{kahraman} sincapla birlikte ilk rotayı tekrar yürüdü."
    aciklama: "Metindeki \"{kahraman} sincapla birlikte ilk rotayı tekrar yürüdü.\" cümlesinde rota, yürünen yolu, yani izlenecek güzergâhı anlatır. Meyvenin tadı, gölge ve kozalağın rengi yürünebilecek bir şey değildir."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 5
    metin: "{kahraman} neden günün sonunda kozalakları toplamaya çıktı?"
    secenekler:
      - {id: A, metin: "Yeni bir oyun başlatmak için"}
      - {id: B, metin: "Buluşmayı unutturmak için"}
      - {id: C, metin: "Köprüyü kapatmak için"}
      - {id: D, metin: "Ormanı doğal bırakmak için"}
    dogru: D
    dayanak: "Ormanın doğal görüntüsünün korunmasını istiyordu."
    aciklama: "Metindeki \"Ormanın doğal görüntüsünün korunmasını istiyordu.\" cümlesi, toplama nedeninin ormanı olduğu gibi bırakmak olduğunu gösterir. Oyun başlatmak, buluşmayı unutturmak ya da köprüyü kapatmak metinde hiç amaç olarak geçmez."
---

@omurga

{kahraman} çalılıkların kenarında yaşayan bir tavşandı. Ormanın açıklığında her sonbahar meyve paylaşım günü kurulurdu. Bu kez canlılar farklı patikalardan gelecekti. Ancak yeni yağan yağmur, eski yol işaretlerinin bir kısmını silmişti. Patika başlarındaki boyalı çubuklar çamura gömülmüş, ayrım noktalarındaki izler akıp gitmişti. {kahraman} önce yol boyundaki taşları işaret olarak kullanmayı düşündü. Ama kimi taşlar yaşlı kaplumbağanın güneşlendiği yerlerdi, kimilerinin altında böcek yuvaları vardı. Yol, hiçbir şeyi yerinden oynatmadan gösterilmeliydi. Yerde bol bulunan kozalaklar bu iş için uygun görünüyordu. İşi bitince alınıp götürülebilirlerdi. {kahraman} açıklığa giden rotayı zihninde yürüdü: yüksek bir taş, iki çam ağacı, küçük bir köprü. İşaretleri bu üç noktaya koyacaktı. Tek kaygısı vardı. Kendisine açık gelen bir işaret, başkası için hiçbir şey söylemeyebilirdi.

---

@omurga

İlk durak yüksek taşın önüydü. {kahraman} oraya üç kozalak dizdi. Kozalaklar köprünün yönünü gösteriyordu. Fakat sincap, üç kozalağı görünce bunun bir oyun işareti olduğunu sandı. Kozalakları sayarak zıpladı, sonra yanlış patikaya daldı. {kahraman} peşinden seslenmedi; işaretin gerçekten anlaşılıp anlaşılmadığını görmek istiyordu. Sincap çamın dibinde yolunu kaybedip geri dönünce ikisi de güldü. Sorun sincapta değil, işaretteydi. Birlikte küçük bir anlaşma yaptılar: yan yana iki kozalak düz yolu, köşeye konan tek kozalak dönüşü gösterecekti. Üç kozalaklı dizilişi bir daha kullanmadılar. Ağaç gövdesine çizik atılmadı, dallar kırılmadı. {kahraman} sincapla birlikte ilk rotayı tekrar yürüdü. Bu kez sincap her işareti doğru okudu.

---

@omurga

Köprünün az ötesinde patika ikiye ayrılıyordu. Kısa yol çamurluydu. Uzun yol ise düz ve kuruydu. {kahraman} kaplumbağanın kısa yolda çamura saplanacağını düşündü. Yavaş yürüyen biri için hızlı görünen yol, aslında en uzun yol olabilirdi. Düz patikanın başına iki kozalak koydu, çamurlu yolun girişine ise hiçbir şey koymadı. Sonra kaplumbağayla birlikte yola çıkıp işaretleri denedi. Kaplumbağa kuru patikada rahatça ilerledi. Yalnız bir yerde kozalaklar uzun otların arasında kaybolmuştu. Kaplumbağa durup başını çevirdi, çünkü dönüşü göremiyordu. {kahraman} kozalakları otların üstüne, göz hizasına taşıdı. Sincap da bir şey fark etti: İşareti koymak kadar, yoldan geçenin onu nereden göreceğini düşünmek de gerekiyordu.

---

@omurga

Paylaşım günü ilk gelenler işaretleri sorunsuz izledi. Öğleye doğru çisenen yağmur köprünün yanındaki kozalağı yuvarlayıp çamura itti. {kahraman} bunu görünce sincapla birlikte kozalağı sağlam bir taşın dibine, eğimin yukarı tarafına yerleştirdi. Artık kaymıyordu. Açıklıkta herkesin getirdiği meyveler sergileniyordu. Kimi canlı elmayı, kimi yaban eriğini seviyordu. {kahraman} meyveleri tek yığın yapmak yerine türlerine göre ayırdı ve herkes istediği bölümden aldı. Bazı canlılar erken geldi, bazıları geç. Geç gelenleri kimse azarlamadı; onlara da ayrı bir pay kaldı. Kaplumbağa kuru patikadan en son geldi ama meyve bölümüne hiç acele etmeden, ilk gelenlerle aynı rahatlıkla yaklaştı.

---

@omurga

Akşam olunca {kahraman} yolda kalan kozalakları toplamak için patikayı baştan yürüdü. Ormanın doğal görüntüsünün korunmasını istiyordu. Sincap da yanına katıldı. “Artık bütün patikaları biliyoruz,” dedi. Bir kozalağı hatıra olarak saklamak istiyordu. {kahraman} buna karşı çıkmadı, yalnızca ormandan bir kozalağın eksileceğini söyledi. Sincap biraz düşündü, kozalağı olduğu yere bıraktı ve yerine bir çam iğnesi aldı. Köprünün başındaki son kozalağı da toplarken {kahraman} yarını düşündü. Orman değişirse işaretler de değişebilirdi. Bunu yine birlikte konuşup yine birlikte deneyeceklerdi.
