---
baslik: "Müzik Kutusunun Şifresi"
slug: "hr038-muzik-kutusunun-sifresi"
fis_kodu: "HR-038"
tur: gizem
konu: ritim_aile_bellegi
sinif_alt: 4
sinif_ust: 4
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D6, D18]
yetiskin_uygun: false
tanitim: "Ceviz sandığındaki müzik kutusu açılmak istemiyor. Doğru ritim hangisi?"
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 4
  okuma_zorlugu: 3
  kavram_zorlugu: 3
  ilgi_egilimi: ortak
  temalar: [gizem, aile, kultur_miras]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D6
    yardimci_deger: D18
  ogrenme_hedefleri:
    - {id: nota_hr038, tur: lexeme, etiket: "nota", yuva: hr038_nota, islev: first_hint}
    - {id: melodi_hr038, tur: lexeme, etiket: "melodi", yuva: hr038_melodi, islev: application}
    - {id: duraklama_hr038, tur: lexeme, etiket: "duraklama", yuva: hr038_duraklama, islev: application}
    - {id: deyim_hr038, tur: idiom, etiket: "Gözleri dolmak", yuva: hr038_gozleri_doldu, islev: application}
    - {id: kavram_hr038, tur: concept, etiket: "Ritim ve tekrar ile çıkarım", islev: application}
  kanit_duzeyi: C
  program_surumu: "Önceki program (4. sınıf; geçiş dönemi, resmî program eşleştirmesi insan editörce yapılacak)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "Müzik kutusunda kaç düğme vardı?", secenekler: [{id: A, metin: "Dört"}, {id: B, metin: "İki"}, {id: C, metin: "Altı"}, {id: D, metin: "Üç"}], dogru: A, aciklama: "Kutunun üzerinde dört küçük düğme vardı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 5, metin: "Büyükanne gözleri neden doldu?", secenekler: [{id: A, metin: "Kutunun kırık kanadını onarmakta zorlandığı ve üzüldüğü için"}, {id: B, metin: "Sınıfındaki çocuklarla her gün yüksek sesle tartıştığı için"}, {id: C, metin: "Melodiyi arkadaşıyla birlikte bestelediğini ve yıllardır hatırladığını"}, {id: D, metin: "Torunları için akşam yemeği hazırladığı ve mutlu olduğu için"}], dogru: C, aciklama: "Mektubu okuyunca melodinin ve arkadaşlığın anısı canlandı."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 5, metin: "Kahramanın “şifre yalnızca nota değil, bir hatıra” sözü neyi gösterir?", secenekler: [{id: A, metin: "Kutunun hiçbir zaman açılamayacağını ve atılması gerektiğini"}, {id: B, metin: "Nota bilgisinin tamamen önemsiz ve gereksiz olduğunu"}, {id: C, metin: "Kutunun saf altından yapılmış ve çok değerli olduğunu"}, {id: D, metin: "Kutunun açılmasının notalardan çok anılarla bağlı olduğunu"}], dogru: D, aciklama: "Kutunun sırrı, aile belleğindeki bir anıyla bağlantılıydı."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 3, metin: "Metinde geçen duraklama sözcüğü ne anlama gelir?", secenekler: [{id: A, metin: "Sesin bir süre durması"}, {id: B, metin: "Sesin giderek hızlanması"}, {id: C, metin: "Sesin tizleşip yükselmesi"}, {id: D, metin: "Kutunun kapağının kırılması"}], dogru: A, aciklama: "Duraklama, bir sesin ya da hareketin kısa süre durmasıdır."}
deyim_cumleleri:
  hr038_gozleri_doldu: "Büyükanne mektubu okuyunca gözleri doldu."
---
@omurga
Büyükannesi Zeliha, eski ceviz sandığını açtığında içinden avuç içi kadar bir müzik kutusu çıktı. Kapağındaki küçük kuşun kanadı kırılmıştı; altındaki kilit ise anahtarsızdı.

"Bu kutu eskiden şarkı söylerdi," dedi Zeliha. "Ama nasıl açıldığını unuttum."

Torunları {kahraman} ve {yoldas:yalin|bir arkadaş} kutuyu incelemeye başladılar. Üzerinde dört küçük düğme vardı. Her düğmeye basınca başka bir {kelime:hr038_nota} duyuluyordu: do, re, mi, sol.

{kahraman} daha önce okulun müzik dersinde seslerin yüksekliğiyle süresinin aynı şey olmadığını öğrenmişti. İnce ve kalın sesler bir özelliği, kısa ve uzun süreler başka bir özelliği anlatıyordu. {yoldas:yalin|bir arkadaş}, "Ben en yüksek sesi bulmamız gerektiğini sanmıştım," dedi. {kahraman}, "Belki notalar doğru ama çalma biçimimiz yanlış," diye cevap verdi. Bu yüzden acele etmek yerine duyduklarını küçük işaretlerle yazmaya karar verdiler.
---
@omurga
{yoldas:yalin|bir arkadaş} düğmelere rastgele bastı. Kutu küçük bir tık sesi çıkardı ama açılmadı. {kahraman}, kapağın kenarındaki işaretleri gösterdi: iki kısa çizgi, bir uzun çizgi ve küçük bir nokta. {isaret:anahtar}

"Bunlar seslerin süresini anlatıyor olabilir," dedi.

Çocuklar masaya dört renkli kâğıt koydu. Her notaya bir renk verdiler ve duydukları sesleri sırayla yazdılar. İlk deneme başarısızdı. İkinci denemede müzik kutusu dört nota çaldı ama yine kapalı kaldı.

"Belki sırayı doğru, ritmi yanlış çalıyoruz," diye düşündü {kahraman}.

Büyükanne pencerenin yanından eski bir fotoğraf getirdi. Fotoğrafta genç Zeliha, küçük bir çocukla birlikte piyano başındaydı. Kenarına şu cümle yazılmıştı: **Önce iki kısa, sonra bir uzun. Sonunda hep birlikte sus.**
---
@omurga
{yoldas:yalin|bir arkadaş} heyecanlandı. "Sonunda bir ses daha yok. Bir {kelime:hr038_duraklama} var!"

{kahraman} notaları doğru sırayla çaldı; son düğmeden sonra bir an bekledi. Kapağın içinden yumuşak bir çıtırtı duyuldu. Kilit açılmıştı.

{yoldas:yalin|bir arkadaş}, kapağı açmadan hemen önce bir kez daha durdu. "Büyükanne, ya içindeki şey kırılacak kadar hassassa?" diye sordu. Zeliha bir bez getirdi ve masanın üzerine serdi. Çocuklar kutuyu onun üstüne koyup kapağını yavaşça kaldırdılar. Sır çözmek onları heyecanlandırıyordu fakat eski eşyalara dikkatle davranmak da önemliydi. Sonradan fark ettiler ki kapakta küçük bir çizik vardı; onu zorlayarak açmaya kalksalardı hatıraya zarar verebilirlerdi.
---
@omurga
Kutunun içinde altın ya da mücevher yoktu. Küçük bir kart, sararmış bir fotoğraf ve sarı kurdeleli bir mektup vardı. Mektupta, Zeliha'nın çocukluk arkadaşının uzak bir kente taşınmadan önce bu {kelime:hr038_melodi}yi armağan ettiği yazıyordu.

"Çocukken birlikte oyun oynardık," diye anlattı Zeliha. "Bir gün bu küçük melodiyi her buluşmamızda çalmaya söz verdik. Sonra taşındılar. Aradan yıllar geçti ama bir melodiyi duyunca sanki arkadaşım yanımdaymış gibi olur." {kahraman}, müziğin yalnızca notalardan oluşmadığını düşündü. Bir şarkı, insanın belleğinde uzak bir güne açılan kapı da olabilirdi. {yoldas:yalin|bir arkadaş} ise fotoğraftaki iki çocuğun yüzlerini dikkatle inceledi; şimdi büyükannesi olan küçük kızın gülüşünü hemen tanıdı.
---
@omurga
[[deyim:hr038_gozleri_doldu]] "Bu melodiyi birlikte bestelemiştik," dedi. "Yıllardır nerede sakladığımı düşünürdüm."

{kahraman}, "Demek kutunun şifresi yalnızca nota değil, bir hatıraymış," dedi.

{yoldas:yalin|bir arkadaş} kutuyu yeniden çaldı. Bu kez duraklamayı unutmadı. Büyükanne de müziğe hafifçe eşlik etti.

O akşam aile albümünden başka fotoğraflar çıkardılar. {yoldas:yalin|bir arkadaş} her fotoğrafın arkasına kimlerin bulunduğunu yazmayı önerdi. {kahraman} ise büyükanneye anılarını kaydedecek küçük bir defter armağan etti. Çünkü bir gün başkalarının da bu hikâyeleri öğrenmesini istiyorlardı.

Müzik kutusunun kanadı hâlâ kırıktı. Ama artık onun için önemli olan kusursuz görünüşü değil, içinde sakladığı seslerdi.
