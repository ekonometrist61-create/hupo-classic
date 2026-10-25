---
baslik: "Ay'a Giden İlk Posta"
slug: "hr035-ay-a-giden-ilk-posta"
fis_kodu: "HR-035"
tur: bilim_kurgu
konu: uzay_iletisim
sinif_alt: 4
sinif_ust: 4
okuma_bandi: 2
dunya_tipi: gercekci
izinli_turler: [ben, arkadas]
deger_anahtarlari: [D5, D16]
yetiskin_uygun: false
tanitim: "Dünya'dan Ay'a giden bir mektup neden bir anda kesildi? Çocuklar iletişimin nasıl çalıştığını öğrendi."
durum: taslak
uretim_kaynak: llm_taslak
tarih: "2026-10-22"
etiketler:
  ana_sinif: 4
  okuma_zorlugu: 3
  kavram_zorlugu: 4
  ilgi_egilimi: ortak
  temalar: [bilim_teknoloji, dayanisma]
  ders_baglantisi: [turkce]
  maarif:
    ana_deger: D5
    yardimci_deger: D16
  ogrenme_hedefleri:
    - {id: uydu_hr035, tur: lexeme, etiket: "uydu", yuva: hr035_uydu, islev: first_hint}
    - {id: maket_hr035, tur: lexeme, etiket: "maket", yuva: hr035_maket, islev: application}
    - {id: gecikme_hr035, tur: lexeme, etiket: "gecikme", yuva: hr035_gecikme, islev: application}
    - {id: kavram_hr035, tur: concept, etiket: "Veri aktarımı ve iletişim gecikmesi", islev: application}
  kanit_duzeyi: C
  program_surumu: "Önceki program (4. sınıf; geçiş dönemi, resmî program eşleştirmesi insan editörce yapılacak)"
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
sorular:
  - {id: s1, beceri: hatirlama, dayanak_sayfa: 1, metin: "İlk mektubu yazma hakkını kimler kazanmıştı?", secenekler: [{id: A, metin: "Öğretmen ve öğrenci"}, {id: B, metin: "Görevli ve teyze"}, {id: C, metin: "Üç arkadaş"}, {id: D, metin: "İki kardeş"}], dogru: D, aciklama: "Eylül ve Can, Ay Üssü'ne giden ilk özel mektubu yazma hakkını kazanmıştı."}
  - {id: s2, beceri: cikarim, dayanak_sayfa: 3, metin: "Mesaj kaybolmadığı için görevli ne yaptı?", secenekler: [{id: A, metin: "Mektubu çöpe attı"}, {id: B, metin: "Hemen Ay'a gönderdi"}, {id: C, metin: "Kâğıdı yaktı"}, {id: D, metin: "Mesajın kopyası güvende olduğu için bağlantının yeniden kurulmasını bekledi"}], dogru: D, aciklama: "Görevli, mesajın kopyasının güvende olduğunu bildiği için önce bağlantıyı bekledi."}
  - {id: s3, beceri: yorumlama, dayanak_sayfa: 2, metin: "Çocuklar iletişim hakkında ne fark etti?", secenekler: [{id: A, metin: "İletişimin çok kolay olduğunu"}, {id: B, metin: "Mektubun hiç gitmediğini"}, {id: C, metin: "İletişimin birçok aşaması ve dikkat gerektiren adımları olduğunu"}, {id: D, metin: "Ayın yakın olduğunu"}], dogru: C, aciklama: "Mesaj, kopyalanma, parçalama ve doğrulama gibi adımlardan geçiyordu."}
  - {id: s4, beceri: sozcuk_baglami, dayanak_sayfa: 2, metin: "Metinde geçen maket ne demektir?", secenekler: [{id: A, metin: "Bir tür mektup"}, {id: B, metin: "Bir şeyin küçültülmüş modeli"}, {id: C, metin: "Bir uydu"}, {id: D, metin: "Bir ekran"}], dogru: B, aciklama: "Maket, gerçek bir şeyin küçültülmüş modelidir."}
---
@omurga
Ay Üssü'ne gidecek ilk özel mektubu yazma hakkını iki kardeş kazanmıştı. {kahraman}, Dünya'daki sınıfının resmini çizmiş; {yoldas:yalin|bir arkadaş} ise altına yalnızca bir cümle yazmıştı: "Burada sizi merak eden arkadaşlarınız var." {isaret:ay}

Mektup Ay'da çalışan teyzeleri Selin'e gönderilecekti. Yeni posta sistemi önce kâğıdı görüntüye dönüştürüyor, ardından uzaya veri olarak iletiyordu. Teyzeleri Ay Üssü'ndeki yazıcıdan aynı mektubu alacaktı.
---
@omurga
Posta merkezinde tavandan Dünya ve Ay'ın {kelime:hr035_maket} sarkıyordu. {yoldas:yalin|bir arkadaş} aralarındaki boşluğa baktı. "Ay şu kadar yakınsa mektup çabucak gider," dedi. Görevli iki maketi daha uzağa taşıdı. "Bunlar gerçeğe göre küçültülmüş. Uzaydaki uzaklıkları maketle göstermek çok zor," diye açıkladı. {kahraman}, mesajın nasıl ilerlediğini daha iyi anlamak için kabloları, anteni ve {kelime:hr035_uydu} görevini çizdi. Her ok bir aşamayı gösteriyordu. Çocuklar, iletişimin yalnızca bir tuşa dokunmaktan ibaret olmadığını fark etmeye başlamıştı.

Başlangıçta her şey yolundaydı. Fakat posta merkezinin ekranı birden kırmızıya döndü: Bağlantı kesildi.
---
@omurga
"Mektubumuz kayboldu mu?" diye sordu {yoldas:yalin|bir arkadaş}.

Görevli, "Hayır," dedi. "**Mesajın kopyası burada güvende**. Ancak şimdi göndermiyoruz. Önce bağlantının yeniden kurulması gerek."

{kahraman} üzülmüştü. Selin teyzesinin doğum gününe yalnızca bir gün kalmıştı. {yoldas:yalin|bir arkadaş} bir çözüm önerdi: "Mektubu aynı anda başka bir kanaldan göndersek?"

Görevli gülümsedi. "İyi düşünce. Fakat bütün kanallar aynı anda çalışmayabilir. Önce hangisinin güvenilir olduğuna bakmalıyız."

Çocuklar merkezin panosunda çizilmiş küçük bir şemayı inceledi. Bir çizgi Dünya istasyonundan yörüngedeki uyduya uzanıyor, ikinci çizgi uydudan Ay Üssü'ne gidiyordu.

{kahraman}, "Mesajı küçük parçalara ayırsak?" diye sordu. "Bağlantı dönünce eksik kısmı tamamlarız."
---
@omurga
Görevli, "Bu da veri aktarımında kullanılan yöntemlerden biridir," dedi. Ardından çocuklara mesajın birden fazla parçasının nasıl kontrol edildiğini gösterdi. Kısa bir bekleyişten sonra uydu bağlantısı tekrar açıldı.

Ekrana İleti ulaştı yazısı düşünce {yoldas:yalin|bir arkadaş} zıpladı. Fakat hemen bir soru sordu: "Ay'daki teyze cevap verirse onu anında duyar mıyız?"

Görevli başını salladı. "Hayır, sinyaller ışık hızında ilerlese de Dünya ile Ay arasındaki uzaklık yüzünden küçük bir {kelime:hr035_gecikme} olur."
---
@omurga
Görevli çocuklara gönderimden önce yaptıkları iki kontrolü de anlatmıştı: alıcının kimliği doğru muydu ve mesaj gerçekten bütünüyle gelmiş miydi? {yoldas:yalin|bir arkadaş} kendi mektubuna bakıp "Ya çizimimizin yarısı gitseydi?" diye sordu. {kahraman}, doğrulama işaretini gösterdi. "O zaman karşı taraf eksik parçayı isterdi." Mesajın güvenli iletimi artık ikisinin de zihninde bir bilmecenin çözümü gibiydi. Eve dönünce mektubun ilk taslağını sakladılar; günün sonunda öğrenilenlerin de bir hatıra olmasını istediler.

Ertesi akşam evde bir görüntü geldi. Selin teyze, elinde basılmış mektubu tutuyordu. "Sınıfınızın resmini duvarıma astım," dedi. "Ay'ın gökyüzünde Dünya çok güzel görünüyor. Ama sizin yazdıklarınız daha güzel."
---
@omurga
{yoldas:yalin|bir arkadaş}, "Biz de buradan seni görüyoruz!" diye seslendi.

Cevap hemen gelmedi. İki kardeş gülümseyerek bekledi. O küçük gecikme artık onları şaşırtmıyordu.

{kahraman}, postanın yalnızca zarf ve pul olmadığını anladı. Bazen sevgi bir kâğıtta, bazen de uzaklara giden küçük veri parçalarında yolculuk ediyordu. Yine de en önemli şey, karşıdaki insanı hatırlamaktı.

{yoldas:yalin|bir arkadaş} ertesi gün sınıfta öğrendiklerini arkadaşlarına anlattı. Sınıfça bir mesaj göndermeden önce adını, alıcısını ve içeriğini kontrol etmeye karar verdiler. Çünkü uzaklık ne kadar büyük olursa olsun, dikkatli iletişim küçük ama önemli adımlarla başlıyordu.
