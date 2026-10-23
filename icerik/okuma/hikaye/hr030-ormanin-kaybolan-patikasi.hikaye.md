---
baslik: "Ormanın Kaybolan Patikası"
slug: "hr030-ormanin-kaybolan-patikasi"
fis_kodu: "HR-030"
tur: macera
konu: harita_guzergah
sinif_alt: 4
sinif_ust: 4
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D16, D5]
yetiskin_uygun: false
tanitim: "Eski patika kısa ama kapalı. Üç arkadaş güvenli yolu nasıl buldu?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 4
  okuma_zorlugu: 3
  kavram_zorlugu: 3
  ilgi_egilimi: ortak
  temalar: [doga, guvenlik]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D16
    yardimci_deger: D5
  ogrenme_hedefleri:
    - {id: kroki_hr030, tur: lexeme, etiket: "kroki", yuva: hr030_kroki, islev: first_hint}
    - {id: guzergah_hr030, tur: lexeme, etiket: "güzergâh", yuva: hr030_guzergah, islev: application}
    - {id: olcek_hr030, tur: lexeme, etiket: "ölçek", yuva: hr030_olcek, islev: application}
    - {id: kavram_hr030, tur: concept, etiket: "Kısa yol her zaman güvenli değildir", islev: application}
  kanit_duzeyi: C
  program_surumu: "TYMM 2026-27 (4. sınıf; okuma evresi insan editörce kontrol edilecek)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Patika neden kapatılmıştı?", secenekler: [{id: A, metin: "Yağmur yüzünden toprak kaymıştı"}, {id: B, metin: "Park ücretsiz değildi"}, {id: C, metin: "Gölet kurumuştu"}, {id: D, metin: "Kuş yuvası vardı"}], dogru: A, aciklama: "Şiddetli yağmur bazı yerlerde toprağı kaydırmıştı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 3, metin: "Öğretmen eski kısa patikayı neden kullanmadı?", secenekler: [{id: A, metin: "Kısa yol her zaman güvenli değildi; güncel levha ve görevliler daha doğru bilgi veriyordu"}, {id: B, metin: "Gölet yoktu"}, {id: C, metin: "Yağmur yağıyordu"}, {id: D, metin: "Harita yanlıştı"}], dogru: A, aciklama: "Güncel levhalar ve görevliler, hangi yolun güvenli olduğunu gösterir."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 6, metin: "Selin'in defterine yazdığı cümleye göre iyi bir yol nasıl olmalı?", secenekler: [{id: A, metin: "Güvenle ulaştırmalı"}, {id: B, metin: "Hızlı olmalı"}, {id: C, metin: "Kısa olmalı"}, {id: D, metin: "Renkli olmalı"}], dogru: A, aciklama: "İyi yol, hedefe güvenle ulaştıran yoldur."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 3, metin: "Metinde geçen ölçek sözcüğü ne anlama gelir?", secenekler: [{id: A, metin: "Haritada gerçek uzaklığı küçülterek gösteren oran"}, {id: B, metin: "Yürüyüş ayakkabısı"}, {id: C, metin: "Park görevlisi"}, {id: D, metin: "Bir tür levha"}], dogru: A, aciklama: "Harita ölçeği, gerçek uzaklığın küçültülmüş oranını gösterir."}
---
@omurga
Orman parkındaki yürüyüşe hazırlanırken öğretmenleri, haritadaki ince yeşil çizgiyi gösterdi. “Bu, gölete ulaşan eski patikamız,” dedi. Ancak park girişindeki görevli onları durdurdu. Geceki şiddetli yağmur yüzünden bazı yerlerde toprak kaymış, patika geçici olarak kapatılmıştı. {isaret:orman}

“Bütün gezi iptal mi?” diye sordu {kahraman}.

Görevli, güvenli ve açık bir başka yol olduğunu, yeni yön levhalarının henüz yerleştirilmediğini söyledi. {kahraman}, arkadaşları {yoldas:yalin|bir arkadaş} ve Nisa ile görevliden alternatif yolun {kelime:hr030_kroki} aldı. Öğretmenleri çocukların bir keşif görevi yapmasına izin verdi: Yürüyüş boyunca yalnızca açık {kelime:hr030_guzergah} izleyecek, eksik levhaları not edeceklerdi.
---
@omurga
İlk kavşakta iki yol ayrılıyordu. Haritada sağ taraftaki yolun sonunda piknik alanı, soldaki yolun sonunda gözlem terası görünüyordu. {yoldas:yalin|bir arkadaş} sağa dönmek istedi, çünkü oradan kuş sesi geliyordu. Nisa ise haritadaki okları işaret etti. “Kuş sesi yönümüzü göstermiyor. Terasa gitmek için önce sola dönmeliyiz.”

Biraz ileride yerde düşmüş bir levha gördüler. {kahraman} levhayı kaldırmak istedi, fakat öğretmeni önce çevreye bakmalarını söyledi. Yağmurdan sonra zemin kaygandı. Görevlinin not alması için levhanın yerini haritada işaretlediler; ona dokunmadan yürüdüler.

Gözlem terasına vardıklarında gölet uzaktan görünüyordu. {kahraman}, “Eski patika haritada daha kısa. Neden orayı kullanmıyoruz?” diye sordu.
---
@omurga
“**Çünkü kısa yol her zaman güvenli yol değildir**,” dedi öğretmeni. “Harita, yolun nerede olduğunu gösterir; güncel levhalar ve görevliler ise hangi yolu kullanabileceğimizi bildirir.”

Gözlem terasında beklerken Nisa, krokideki küçük karelerin ne işe yaradığını merak etti. Öğretmenleri bunların harita üzerindeki belirli yerleri gösterdiğini anlattı. {yoldas:yalin|bir arkadaş}, “Kâğıtta iki parmak uzaklıkta olan yerler gerçek hayatta niçin bu kadar uzak?” diye sordu. Öğretmen, haritaların gerçek yerleri küçülterek gösterdiğini söyledi; bunun için {kelime:hr030_olcek} kullanıldığını ekledi. Çocuklar adımlarını sayarak kısa bir mesafeyi karşılaştırdı ama yaklaşık sonuçları kesin ölçüm sanmamaları gerektiğini de öğrendi.
---
@omurga
{kahraman} yeni levhaların yalnız doğru yeri göstermesini değil, herkesçe anlaşılmasını istiyordu. Okuma güçlüğü yaşayan küçük çocukların da işaretleri anlayabilmesi için renk ve şeklin yazıyla birlikte kullanılmasını önerdi. Öğretmen öneriyi not etti.

Dönüşte park ofisinde görevli, çocukların işaretlediği noktaları inceledi.

Dönüşte park ofisinde görevli, çocukların işaretlediği noktaları inceledi. {yoldas:yalin|bir arkadaş} bazı levhalara hayvan resimleri konmasını önerdi. Nisa ise hem simge hem yazı bulunmasının daha anlaşılır olacağını söyledi. {kahraman}, “Bir de kavşaktan önce levha koyarsanız insanlar son anda yön değiştirmek zorunda kalmaz,” diye ekledi.
---
@omurga
Park görevlisi önerileri dinlerken Nisa küçük bir ayrıntı daha ekledi. Bazı renkleri ayırt etmekte zorlanan kişiler olabilirdi; bu yüzden yalnız renge güvenmemek gerektiğini söyledi. Levhalara ok, kısa sözcük ve kolay tanınan simgeler koymayı kararlaştırdılar. {yoldas:yalin|bir arkadaş} da çizdiği kuş resmini yol işaretinden ayırdı: “Güzel bir resim, her zaman açık bir işaret olmayabilir.”

Bir hafta sonra sınıf yeniden parka geldi. Kapatılmış patikanın girişinde hâlâ uyarı vardı, fakat açık yola yeni levhalar yerleştirilmişti. Levhalarda yön oklarının yanında küçük yaprak simgeleri bulunuyordu. Park görevlisi çocuklara teşekkür etti: “Gözlemleriniz, yürüyüşçülerin işini kolaylaştırdı.”
---
@omurga
{kahraman} eve gidince iki haritayı yan yana koydu: Biri eski patikayı, diğeri güncel ve güvenli güzergâhı gösteriyordu. Aralarındaki farkı renklendirerek çizdi. Defterinin altına şu cümleyi yazdı: İyi bir yol bulmak, yalnızca hedefe varmak değil, oraya güvenle ulaşmaktır.

Dil hedefi: rota, yön, uyarı; çözüm önerme; Kavram/değer: kroki, güvenli güzergâh, doğayı koruma. İkon önerileri: orman, pusula, levha. Okuma sonrası: Hangi kanıt yeni yolu seçmelerini sağladı? Bir levha tasarlasan neler koyardın?
