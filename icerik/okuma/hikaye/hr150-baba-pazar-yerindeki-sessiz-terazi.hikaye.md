---
baslik: "Elmayı Farklı Tartan Teraziler"
slug: "hr150-baba-pazar-yerindeki-sessiz-terazi"
fis_kodu: "HR-150"
tur: mizah
konu: olcum_araci_kalibrasyonu
sinif_alt: 6
sinif_ust: 6
kahraman_turu: baba
deger_anahtarlari: [D1, D6]
tanitim: "Pazardaki iki terazi aynı elmayı farklı tartıyor. {kahraman} suçlama yerine ölçüm yaparak karışıklığı çözüyor."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-10"
etiketler:
  ana_sinif: 6
  maarif: {ana_deger: D1, yardimci_deger: D6}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sozcuk1_hr150, tur: lexeme, etiket: "kalibrasyon", islev: first_hint}
  - {id: sozcuk2_hr150, tur: lexeme, etiket: "sapma", islev: application}
  - {id: sozcuk3_hr150, tur: lexeme, etiket: "standart", islev: application}
  - {id: sozcuk4_hr150, tur: lexeme, etiket: "denge", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Tartışma hangi ürünün tartılmasıyla başladı?"
    secenekler:
      - {id: A, metin: "Elma kasası"}
      - {id: B, metin: "Ekmek sepeti"}
      - {id: C, metin: "Pirinç torbası"}
      - {id: D, metin: "Üzüm kutusu"}
    dogru: A
    dayanak: "Pazar yerinde iki satıcının terazisi aynı elma kasası için farklı ağırlık gösteriyordu."
    aciklama: "İki terazi aynı elma kasası için farklı ağırlık gösteriyordu. Ekmek, pirinç ve üzüm metinde geçmez."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "Terazilerden biri düz yüzeye alınınca fark küçüldü. Bunun nedeni ne olabilir?"
    secenekler:
      - {id: A, metin: "Kasadaki elmalar değiştirildiği için"}
      - {id: B, metin: "Masa biraz daha yüksek olduğu için"}
      - {id: C, metin: "Eğri zemin tartıyı etkilediği için"}
      - {id: D, metin: "Terazinin rengi açık olduğu için"}
    dogru: C
    dayanak: "Birinin ayağı eğri zeminde hafifçe havada kalıyordu."
    aciklama: "Bir terazinin ayağı eğri zeminde havada kaldığı için ölçüm bozuluyordu; düz yüzey bunu düzeltti. Elmalar değişmedi, masa yüksekliği ve renk de ölçümle ilgili değildir."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 3
    metin: "Karton parçası tartım sırasında dengeyi bozuyordu. Buradaki “denge” neyi anlatır?"
    secenekler:
      - {id: A, metin: "Meyvenin tatlı ya da ekşi olması"}
      - {id: B, metin: "Tartının sallanmadan durması"}
      - {id: C, metin: "Pazar yerindeki kalabalığın artması"}
      - {id: D, metin: "Satış saatinin uzun sürmesi"}
    dogru: B
    dayanak: "Karton, tartım sırasında dengeyi bozuyordu."
    aciklama: "Karton terazinin tablasına sıkışıp tartıyı sallantılı ve yanlış yapıyordu; denge, tartının düzgün durmasıdır. Tat, kalabalık ve satış saati bu anlama uymaz."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "Satıcı tabelasına “Terazim hiç şaşmaz” yazmak isteyince {kahraman} neden başka bir ifade önerdi?"
    secenekler:
      - {id: A, metin: "Tabelanın daha büyük olmasını istediği için"}
      - {id: B, metin: "Pazardaki tezgâh sayısını azaltmak için"}
      - {id: C, metin: "Elmaların adını değiştirmek için"}
      - {id: D, metin: "Doğrulanabilir bilgi vermek istediği için"}
    dogru: D
    dayanak: "Böylece müşterilere abartılı bir söz değil, güvenilir bir bilgi verilecekti."
    aciklama: "“Hiç şaşmaz” abartılı bir söz; kontrol edildiğini belirten ifade ise doğrulanabilir. Tabela boyutu, tezgâh sayısı ve elma adı konu dışıdır."
---

@omurga

Pazar yerinde iki satıcının terazisi aynı elma kasası için farklı ağırlık gösteriyordu. Kimse kimseyi suçlamak istemiyordu ama aradaki fark müşterileri şaşırtmıştı. Ölçüm uzmanı {kahraman}, satıcıların çağrısıyla pazara geldi. Önce elmaların gerçekten aynı kasadan alındığını kontrol etti, aynı elmaların iki terazide de tartılacağından emin oldu. Sonra iki teraziyi aynı masaya koydu. Satıcılar önce kendi terazilerini öne çıkarmaya çalıştı. Biri, “Benimki hep doğru çıkar,” dedi. Öteki, “Benimki daha yeni,” diye karşılık verdi. {kahraman} cihazların yaşına bakarak karar vermedi. Her teraziyi aynı sırayla, herkesin gözü önünde, ağırlıkları bilinen örneklerle denemeyi önerdi. Müşteriler de işlemi uzaktan izleyebiliyordu. Böylece kişilerin sözleri yerine ölçümler konuşacaktı.

---

@omurga

Masadaki özel ağırlıklar standart olarak kullanıldı. Standart, herkesin aynı sonuca ulaşmasına yardım eden ortak ölçüdür. {kahraman} her iki terazide de sıfır ayarını kontrol etti ve her ağırlığı tek tek, boş tablayla başlayarak denedi. Masa eğri bir zeminde duruyordu ve iki terazi de tam oturmuyordu. Birinin ayağı eğri zeminde hafifçe havada kalıyordu. {kahraman} standart ağırlıkları temizleyip uygun biçimde yerleştirdi ve masanın sallanmadığından emin oldu. Sonuç tablosuna ölçümün nerede ve nasıl yapıldığını da yazdı; koşulları bilinmeyen bir sayıya güvenmek zordu. İlk sapma buradan doğmuş olabilirdi. Terazi düz bir yüzeye alınınca fark küçüldü ama tamamen kaybolmadı. {kahraman} bu kez kalibrasyon yaptı; yani terazinin gösterdiği değerleri güvenilir ölçülerle karşılaştırıp ayarını kontrol etti. Satıcılar sonuçları küçük bir tabloya birlikte yazdı.

---

@omurga

Öğleye doğru pazarda komik bir söylenti yayıldı: “Elmalar sabah hafif, öğlen ağır oluyor!” Bir müşteri bunu duyunca gülmeye başladı. {kahraman} ölçüm koşullarını değiştirip yeniden denedi. Terazilerden birinin tablasına sıkışmış küçük bir karton parçası buldu. Karton, tartım sırasında dengeyi bozuyordu. Küçük bir ziyaretçi bir elmayı elinde tartar gibi sallayıp kaşlarını çattı ve elmaların gerçekten ağırlaşıp ağırlaşmadığını sordu. {kahraman} gülerek, önce ölçüm aracında sorun aramadan böyle bir sonuca varılamayacağını anlattı. Temizlik ve ayarın ardından iki terazi aynı standart ağırlık için uyumlu sonuç verdi. {kahraman} elma kasalarını yeniden tarttı; sonuçlar birbirine yakındı. Satıcılar sorunun elmada değil alette ve zeminde olduğunu görünce rahatladı.

---

@omurga

Pazar yönetimi bütün tezgâhlarda basit bir kontrol günü düzenlemeye karar verdi. {kahraman} hangi kontrollerin uzman gerektirdiğini, hangilerinin günlük olarak gözlemlenebileceğini anlattı. Terazinin düz yerde durması, boşken sıfırı göstermesi ve hasar belirtisi olup olmaması herkesin bakabileceği şeylerdi. Resmî ayar ve doğrulamayı ise yetkili kişiler yapmalıydı; satıcılar her şeyi kendi başlarına onarmaya kalkışmamalıydı. Duyuru kısa ve resimli hazırlandı, bütün tezgâhlara dağıtıldı. Satıcılardan biri tabelasına “Terazim hiç şaşmaz” yazmak istedi. {kahraman} bunun yerine ölçümlerin düzenli kontrol edildiğini belirten doğru bir ifade önerdi. Böylece müşterilere abartılı bir söz değil, güvenilir bir bilgi verilecekti.

---

@omurga

Akşam kasalar toplanırken iki satıcı birlikte elma tartıyordu. Sonuçlar birbirini doğruluyordu. Sabah şaşıran müşteri tekrar uğradı ve gülerek “Demek elmaların suçu yokmuş,” dedi. {kahraman} standart ağırlıkları tek tek sayıp ölçüm çantasına yerleştirdi ve çantayı kapattı. Pazar kapanırken iki satıcı birbirine elma ikram etti. {kahraman} tartışmanın başındaki cümleleri hatırladı: Biri yeniliğe, öteki alışkanlığa güvenmişti. Oysa ikisinin de ihtiyacı olan şey karşılaştırılabilir bir ölçüydü. Satıcılar ertesi gün tezgâhlarını kurarken masanın düz olup olmadığına bakmaya söz verdi. Adalet bazen büyük sözlerle değil, düzgün çalışan küçük araçlarla başlıyordu.