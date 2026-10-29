---
baslik: "Keloğlan ve Akıllı Terazi"
slug: "hr032-keloglan-ve-akilli-terazi"
fis_kodu: "HR-032"
tur: tarih_kultur
konu: olcu_adalet
sinif_alt: 4
sinif_ust: 4
okuma_bandi: 2
dunya_tipi: masalsi
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D1, D6]
yetiskin_uygun: false
tanitim: "Terazi eksik tartıyor mu? Keloğlan ölçüyü nasıl kontrol etti?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 4
  okuma_zorlugu: 3
  kavram_zorlugu: 3
  ilgi_egilimi: ortak
  temalar: [kultur_miras, dayanisma]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D1
    yardimci_deger: D6
  ogrenme_hedefleri:
    - {id: denetim_hr032, tur: lexeme, etiket: "denetim", yuva: hr032_denetim, islev: first_hint}
    - {id: agirlik_hr032, tur: lexeme, etiket: "ağırlık", yuva: hr032_agirlik, islev: application}
    - {id: bakir_hr032, tur: lexeme, etiket: "bakır", yuva: hr032_bakir, islev: application}
    - {id: deyim_hr032, tur: idiom, etiket: "Ölçüp biçmek", yuva: hr032_olcup_bicmek, islev: application}
    - {id: kavram_hr032, tur: concept, etiket: "Doğru ölçü ve güven", islev: application}
  kanit_duzeyi: C
  program_surumu: "Önceki program (4. sınıf; geçiş dönemi, resmî program eşleştirmesi insan editörce yapılacak)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Keloğlan pazara ne almak için gitti?", secenekler: [{id: A, metin: "Ekmek"}, {id: B, metin: "Peynir"}, {id: C, metin: "Şeker"}, {id: D, metin: "Bulgur"}], dogru: D, aciklama: "Keloğlan annesi için bulgur almaya gitmişti."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 1, metin: "Satıcı neden müşterilere eksik vermiş olabilirdi?", secenekler: [{id: A, metin: "Bulgur kalmamıştı"}, {id: B, metin: "Keloğlan yardım etmedi"}, {id: C, metin: "Pazar kapanmıştı"}, {id: D, metin: "Terazinin ayarı bozuktu"}], dogru: D, aciklama: "Terazinin ayarı bozulunca tartılan miktar yanlış çıkıyordu."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 4, metin: "Hikâyeye göre güven nasıl yeniden kurulur?", secenekler: [{id: A, metin: "Güzel sözlerle"}, {id: B, metin: "Sessiz kalmakla"}, {id: C, metin: "Pazarı değiştirmekle"}, {id: D, metin: "Yapılan doğru işlerle"}], dogru: D, aciklama: "Güven, doğru işler yapıldığında yeniden kazanılır."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 1, metin: "Metinde geçen denetim ağırlığı ne anlama gelir?", secenekler: [{id: A, metin: "Bir yemek türü"}, {id: B, metin: "Doğruluğu kontrol etmek için kullanılan standart ağırlık"}, {id: C, metin: "Bir tür sepet"}, {id: D, metin: "Satıcının adı"}], dogru: B, aciklama: "Denetim ağırlığı, teraziyi kontrol etmek için kullanılan bilinen bir ağırlıktır."}
deyim_cumleleri:
  hr032_olcup_bicmek: "Teyze, “İşte buna ölçüp biçmek derler,” diye gülümsedi."
---
@omurga
{kahraman}, kasabanın pazarına annesi için bulgur almaya gitti. Sepetinde birkaç {kelime:hr032_bakir} para ve düzgünce katlanmış bir alışveriş listesi vardı. İlk tezgâhta satıcı, bir kese bulguru teraziye koydu. Terazinin bir kefesi aşağı indi, öteki hafifçe havada kaldı. {kahraman} keseye, sonra satıcının kullandığı ağırlığa baktı.

“Usta, bunun tam bir ölçü olduğundan emin miyiz?” diye sordu.

Satıcı kaşlarını kaldırdı. “Bunca yıldır tartıyorum. Sen mi öğreteceksin?”

{kahraman} tartışmak istemedi. “Ben de öğrenmeye çalışıyorum,” dedi. “Aynı ağırlığı başka terazide ölçebilir miyiz?”

Yan tezgahta çalışan {yoldas:yalin|bir arkadaş}, herkesin kullanabildiği {kelime:hr032_denetim} {kelime:hr032_agirlik} gösterdi. {kahraman}, pazardaki belediye görevlisinden de yardım istedi. Görevli önce terazinin dengeli bir zemine oturup oturmadığını kontrol etti. Ardından standart ağırlıkla bir deneme yaptı. İlk terazinin ayarının bozulduğu ortaya çıktı.
---
@omurga
Satıcının yüzü kızardı. “Demek müşterilere eksik vermiş olabilirim,” dedi. “Kasten yapmadım, ama yine de sorun var.”

Pazar görevlisi, ölçme aracının bakım için ayrılması gerektiğini anlattı. Satıcı, o gün satış yaptığı müşterilere durumu duyurmayı ve gerekli düzeltmeleri yapmayı kabul etti. {kahraman} da kimseyi küçük düşürmeden sorunu çözebildikleri için sevindi.

{kahraman} denetim işlemini dikkatle izlerken pazara iki müşteri daha geldi. Biri satıcıya sertçe çıkışmak istedi. {kahraman} araya girip, “Önce sorunu anlayalım; yanlış teraziyi kullanmayı durdurmak herkes için iyi,” dedi. Satıcı da özür dileyerek terazisini düzelttireceğini yineledi. Pazarda yüksek sesle tartışmak yerine açık konuşmanın daha çok işe yaradığını gördüler.
---
@omurga
Görevli, doğru tartımın yalnız alıcıya değil satıcıya da güven sağladığını açıkladı. {kahraman} defterine ağırlık birimlerini yazdı. Bir kilogramın bin gram ettiğini hatırladı; ancak elindeki iki torbanın hangisinin ağır olduğunu görünüşlerine bakıp söyleyemiyordu. İçindeki tanelerin boyutu, torbanın ağırlığını tek başına göstermiyordu. {isaret:kitap}

{yoldas:yalin|bir arkadaş} ona iki torba gösterdi.

{yoldas:yalin|bir arkadaş} ona iki torba gösterdi. Birinde iri taneli, diğerinde ince taneli bulgur vardı. “İkisi de aynı ağırlıkta olabilir mi?” diye sordu.

{kahraman} torbaları elinde tartar gibi yaptı, sonra vazgeçti. “Görünüşe bakıp karar veremem. Teraziye ihtiyacım var.”
---
@omurga
[[deyim:hr032_olcup_bicmek]] “Bir işe girişmeden önce düşünmek, kontrol etmek.”

Bir müşteri, “Benim aldığım ürünler için de aynı kontrol yapılacak mı?” diye sordu. Satıcı adlarını ve alışveriş saatlerini not ederek geri dönenlerin ölçümünü yeniden yapacağını söyledi. {kahraman} işin burasında kendi payını düşündü: “Bir yanlışlığı görmek yetmez; düzeltilmesine de yardım etmek gerekir.” {yoldas:yalin|bir arkadaş} onayladı. Güven, söylenen güzel sözlerle değil, yapılan doğru işlerle yeniden kuruluyordu.

{kahraman} doğru ayarlanmış terazide ihtiyacı kadar bulguru aldı. Eve döndüğünde annesi keseyi açıp sordu: “Pazarda neden bu kadar geç kaldın?”
---
@omurga
“Bulgur aldım, bir de akıl,” dedi {kahraman}. “İkisini de ölçerek aldım.”

Annesi gülerek, “Akıl terazide tartılır mı hiç?” diye karşılık verdi. {kahraman} sepetini bıraktı. “Tartılmaz ama doğru ölçüyle iş yapmak akıllıca olur.”

Ertesi pazar satıcı, tezgâhına yeni denetlenmiş bir terazi koymuştu. Yanına da küçük bir yazı asmıştı: **Ölçüde doğruluk, alışverişte güven**. {kahraman} bu yazıyı görünce başıyla selam verdi. Satıcı da ona teşekkür etti. Kasabada o gün belki büyük bir hazine bulunmamıştı; ama herkesin hakkını koruyan küçük bir adım atılmıştı.

Dil hedefi: adil–haksız, deyim: ölçüp biçmek; Kavram/değer: ölçme, adalet, dürüstlük ve onarıcı sorumluluk. İkon önerileri: terazi, pazar, sepet. Okuma sonrası: Terazinin hatası nasıl kanıtlandı? Deyimdeki “ölçüp biçmek” gerçek ölçme midir?
---
@omurga
1. Kaynak anahtarı mevcut katalogdaki `HR-###` ID’sidir. Tam metin yalnızca eşleşen kayıtların `full_text` alanına taslak olarak eklenmelidir; yeni ID üretilmemeli ve önceki içerik silinmemelidir. 2. Metin gövdesi `<!-- STORY_START:HR-### -->` ile `<!-- STORY_END:HR-### -->` arasında yer alır. Bu işaretlerin dışındaki açıklamalar içerik metnine eklenmemelidir. 3. `grade`, `genre`, `rights_class`, `language`, `concepts`, `icon_suggestions` için ilk katalog kayıtları temel alınmalıdır. Sınıf başına kelime sınırı otomatik doğrulanmalıdır. 4. `status = editorial_review`, `curriculum_verified = false`, `rights_cleared = false` ve `published = false` olarak tut. Özellikle geleneksel tiplere ilişkin yeni metinler için benzerlik/hak kontrolü yapılmalı. 5. Her hikâye için okuduğunu anlama soruları metindeki gerçek olaylara dayalı hazırlanmalı; kelime ve kavram açıklamaları diyalog akışından koparılmamalı. 6. 2–4. sınıf ekranlarında özgün inline ikonlar ve açılır bilgi kartları bulunabilir; ancak metin gövdesine platform emojileri gömmek yerine yapısal etiketler kullan.
---
@omurga
Durum özeti: Bu parti 15 metindir. Önceki 17 uzunluk-uygun metinle birlikte 32/120 hikâye uzunluk bakımından tamamlandı; 88 hikâye tam metin üretimi bekliyor. Bu sayı editoryal yayın onayı anlamına gelmez.
