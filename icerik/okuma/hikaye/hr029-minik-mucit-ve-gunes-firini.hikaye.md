---
baslik: "Minik Mucit ve Güneş Fırını"
slug: "hr029-minik-mucit-ve-gunes-firini"
fis_kodu: "HR-029"
tur: bilim
konu: gunes_enerjisi
sinif_alt: 3
sinif_ust: 3
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D3, D12]
yetiskin_uygun: false
tanitim: "İki kutu, bir termometre. Güneşte ısınan kutu neden farklı davrandı?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 3
  okuma_zorlugu: 3
  kavram_zorlugu: 3
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, sabir_emek]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D3
    yardimci_deger: D12
  ogrenme_hedefleri:
    - {id: termometre_hr029, tur: lexeme, etiket: "termometre", yuva: hr029_termometre, islev: first_hint}
    - {id: saydam_hr029, tur: lexeme, etiket: "saydam", yuva: hr029_saydam, islev: application}
    - {id: olcum_hr029, tur: lexeme, etiket: "ölçüm", yuva: hr029_olcum, islev: application}
    - {id: kavram_hr029, tur: concept, etiket: "Ölçüm ve koşul kontrolü", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (3. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Ece iki kutunun içine ne koydu?", secenekler: [{id: A, metin: "Termometre"}, {id: B, metin: "Yiyecek"}, {id: C, metin: "Su kabı"}], dogru: A, aciklama: "Ece iki kutunun içine de termometre koydu."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 2, metin: "Güneşte duran kutu neden daha sıcaktı?", secenekler: [{id: A, metin: "Güneş enerjisi kutuyu ısıtıyordu"}, {id: B, metin: "İçinde ateş vardı"}, {id: C, metin: "Kutu daha büyüktü"}], dogru: A, aciklama: "Kutunun içinde ateş yoktu; güneşten gelen enerji kutuyu ısıtıyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 3, metin: "Ece'nin “tek bir sonuç” düşüncesi neyi gösterir?", secenekler: [{id: A, metin: "Birden fazla ölçümü ve koşulu birlikte değerlendirmek gerektiğini"}, {id: B, metin: "Deneyin hiç yapılmaması gerektiğini"}, {id: C, metin: "Sonucun her zaman doğru olduğunu"}], dogru: A, aciklama: "Bulutlar gibi değişkenler sonucu etkileyebildiği için tek ölçüm yetmez."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, metin: "Metinde geçen saydam sözcüğü ne anlama gelir?", secenekler: [{id: A, metin: "Işığın geçebildiği kadar açık, şeffaf"}, {id: B, metin: "Renkli"}, {id: C, metin: "Ağır"}], dogru: A, aciklama: "Saydam, ışığı geçiren malzeme demektir."}
---
@omurga
{kahraman}, okulun bilim gününde güneş enerjisini anlatmak istiyordu. Ama güneşi bir kavanoza dolduramayacağına göre, onun ısısını nasıl gösterecekti? Öğretmeniyle birlikte bir kutu modeli hazırlamaya karar verdi.

Öğretmen iki eş boy karton kutunun içini aynı koyu renkli kâğıtla kapladı. İkisine de aynı tür {kelime:hr029_saydam} kapak yerleştirdi. {kahraman} ikisinin içine de {kelime:hr029_termometre} koydu. Hiçbirine yiyecek koymadılar; amaç **yalnız sıcaklığı gözlemekti**.

“Birini güneşte, birini gölgede bekleteceğiz,” dedi {kahraman}. “Başka koşulları mümkün olduğunca aynı tutmalıyız.” {isaret:gunes}

Arkadaşı {yoldas:yalin|bir arkadaş} ilk {kelime:hr029_olcum} deftere yazdı. Her iki termometre de yaklaşık aynı değeri gösteriyordu. On dakika sonra güneşte duran kutunun sıcaklığı daha yüksek çıktı. {yoldas:yalin|bir arkadaş} hemen bağırdı: “Süper! Kutunun içinde ateş var!”
---
@omurga
{kahraman} güldü. “Ateş yok. Ama güneşten gelen enerji kutuyu ısıtıyor olabilir.”

Öğretmen, saydam kapağın ışığın bir kısmını içeri aldığını ve kutunun ısı kaybını azaltmaya yardımcı olduğunu anlattı. {kahraman} elini kutuya uzatınca öğretmeni uyardı: “Ölçüm için termometreyi kullanalım. Isınan yüzeylere dokunmak gerekmiyor.”

Deneyin başında {yoldas:yalin|bir arkadaş} güneşteki kutuyu daha sık açmak istemişti. Öğretmen, kapağın her açılışında içerdeki koşulların değişebileceğini hatırlattı. Bunun üzerine ölçüm zamanlarını önceden belirlediler. {kahraman} çizdiği tabloya saatleri, iki sıcaklığı ve havanın durumunu yazdı. Böylece yalnız “sıcak” veya “soğuk” demek yerine sayıları karşılaştırabildi.
---
@omurga
İkinci ölçümde {yoldas:yalin|bir arkadaş}, gölgede duran kutunun da biraz ısındığını görünce şaşırdı. “O kutuya doğrudan güneş gelmedi,” dedi. Öğretmen, havanın sıcaklığının da değişebileceğini söyledi. {kahraman}, “Öyleyse iki kutunun farkına birlikte bakmalıyız,” diyerek her ikisinin değerini yeniden okudu. Bir deneyde tek bir sonucun her şeyi anlatmayacağını fark etmişti.

Öğleye doğru bulutlar güneşin önünü kapattı.

Öğleye doğru bulutlar güneşin önünü kapattı. İkinci ölçüm bekledikleri kadar yüksek çıkmadı. {yoldas:yalin|bir arkadaş}, “Deney bozuldu,” diye üzüldü. {kahraman} defterdeki önceki değerleri gösterdi. “Hayır, yeni bir bilgi öğrendik. Hava durumu da sonucu etkileyebiliyor.”
---
@omurga
{kahraman} deney başında yazdığı tahmini okudu. Sonuç tam beklediği gibi değildi; özellikle bulutlu saatte fark azalmıştı. Tahminini değiştirmesi gerektiğini düşündü. Bu kez defterine bir sonuç cümlesi yerine yeni bir soru yazdı: “Farklı günlerde ölçsek aynı sonuç çıkar mı?”

Bilim gününde çocuklar kutuları masaya yerleştirdi. {kahraman} ziyaretçilere hangi kutunun nerede durduğunu sordu; sonra ölçümleri gösterdi. Küçük bir öğrenci “Bununla yemek pişirebilir miyiz?” diye sorunca {kahraman} dikkatli cevap verdi: “Güneş ısısından yararlanan gerçek düzenekler var. Bizim yaptığımız ise öğretmen gözetiminde kullanılan bir ölçüm modeli.”
---
@omurga
Sergi sonunda öğretmen ona bir yıldız çıkartması verdi. {kahraman} yıldızı defterine yapıştırmadı; kutuların fotoğrafının yanına koydu. Çünkü en çok, ilk tahminlerini ölçerek karşılaştırabilmiş olmasına seviniyordu.

Dil hedefi: ısı, sıcak–soğuk, karşılaştırma; Kavram/değer: güneş enerjisi, ölçüm, güvenli deney. İkon önerileri: güneş, kutu, termometre. Okuma sonrası: Hangi kutu neden daha çok ısındı? Bulutlar ölçümü nasıl etkiledi?
