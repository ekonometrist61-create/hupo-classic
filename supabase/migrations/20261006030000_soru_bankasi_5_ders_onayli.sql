-- =====================================================================
--  SORU BANKASI: 5 ders (100 soru) + Matematik seed onayı — onay_durumu = 'onaylandi'
--  Üretici : node tools/soru_bankasi_sql.mjs   (kaynak: soru-bankasi/*-bolum-1.md)
--  Dağılım : Türkçe 20, Fen Bilimleri 20, Sosyal Bilgiler 20, Din Kültürü ve Ahlak Bilgisi 20, İngilizce 20
--
--  KARAR (2026-10-06, ürün sahibi): bu örnek sorular, kaynak/sınav yılı/okul adı
--  doğrulanmadan 'onaylandi' olarak yayına alınır. İçerik 4. sınıf kazanımlarına göre
--  hazırlanmış ÖRNEK sorulardır; çıkmış sınav sorusu olarak sunulmaz.
--
--  İdempotent: aynı (ders, soru_metni) varsa yeniden eklenmez. Matematik'in 50 sorusu zaten
--  20261003000001 ile 'beklemede' eklendi; burada yalnızca onaylanır (seed satırları 'İpucu:' ile başlar).
-- =====================================================================

set client_encoding = 'UTF8';

create temporary table _soru_bankasi_5_ders (
  okul text, sinif smallint, ders text, konu text, alt_konu text, zorluk smallint,
  soru_metni text, siklar jsonb, dogru_sik text, cozum_adimlari jsonb
) on commit drop;

insert into _soru_bankasi_5_ders
values
(
  'ortaokul', 5, $$Türkçe$$, $$Sözcükte Anlam$$, $$Eş Anlamlılık$$, 1,
  $$"Bu güzel haberi duyunca çok **sevindi**." cümlesindeki altı koyu sözcüğün eş anlamlısı aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$üzüldü$$, 'B', $$mutlu oldu$$, 'C', $$kızdı$$, 'D', $$korktu$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Eş anlamlı sözcükler, yazılışları farklı olsa da aynı anlamı taşır. "Sevinmek" bir kişinin iç dünyasında oluşan olumlu bir duygudur. Hangi seçenek de aynı olumlu duyguyu anlatır?$$,
    $$Adım 1: Eş anlamlı sözcük, bir sözcüğün yerine kullanıldığında cümlenin anlamını değiştirmeyen sözcüktür.$$,
    $$Adım 2: "Sevinmek" = neşelenmek, mutlu olmak demektir. Üzülmek, kızmak ve korkmak ise olumsuz duygulardır.$$,
    $$Adım 3: "Sevindi" yerine "mutlu oldu" getirildiğinde cümlenin anlamı bozulmaz. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Sözcükte Anlam$$, $$Zıt (Karşıt) Anlamlılık$$, 1,
  $$"Cömert" sözcüğünün zıt (karşıt) anlamlısı aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$eli açık$$, 'B', $$cimri$$, 'C', $$yardımsever$$, 'D', $$paylaşımcı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Zıt anlamlı sözcükler birbirine tamamen ters anlam taşır. "Cömert" kişi, elindekini kolayca paylaşan kişidir. Peki elindekini hiç paylaşmak istemeyen kişiye ne denir?$$,
    $$Adım 1: "Cömert" = elindeki imkânı başkalarıyla isteyerek paylaşan kişidir.$$,
    $$Adım 2: "Eli açık", "yardımsever" ve "paylaşımcı" aslında cömert ile yakın (eş) anlamlıdır, zıt değildir.$$,
    $$Adım 3: Paylaşmaktan kaçınan, eli sıkı kişiye "cimri" denir. Bu, cömertin tam zıttıdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Sözcükte Anlam$$, $$Gerçek ve Mecaz Anlam$$, 2,
  $$"Öğretmenimiz çok **tatlı** bir insandır." cümlesinde "tatlı" sözcüğü hangi anlamda kullanılmıştır?$$,
  jsonb_build_object('A', $$gerçek (temel) anlamda$$, 'B', $$mecaz anlamda$$, 'C', $$terim anlamında$$, 'D', $$eş sesli olarak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Tatlı" sözcüğü aslında şekerli, bal gibi yiyecekler için kullanılır. Ama bir insan için söylenince ağızla tat alınmaz. O zaman sözcük asıl anlamından uzaklaşmış demektir.$$,
    $$Adım 1: Bir sözcüğün ilk akla gelen, sözlükteki anlamı gerçek (temel) anlamdır. "Tatlı" nın gerçek anlamı "şekerli, hoş tatta olan" demektir.$$,
    $$Adım 2: Bir öğretmenin tadına bakılamaz. Burada "tatlı" = sevimli, cana yakın anlamında kullanılmıştır.$$,
    $$Adım 3: Sözcük gerçek anlamından uzaklaşıp başka bir anlam kazanmışsa buna mecaz anlam denir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Söz Varlığı$$, $$Deyimler$$, 2,
  $$"İşleri yoluna girince **rahat bir nefes aldı**." cümlesindeki deyimin anlamı aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Nefes almakta zorlandı.$$, 'B', $$Sıkıntısı geçip rahatladı.$$, 'C', $$Hastalanıp yatağa düştü.$$, 'D', $$Koşmaya başladı.$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Deyimler, sözcüklerin gerçek anlamıyla açıklanamaz. "İşleri yoluna girmek" olumlu bir durumdur. Bu durumda insan kendini nasıl hisseder?$$,
    $$Adım 1: Deyim, en az iki sözcükten oluşan, kalıplaşmış ve genellikle mecaz anlam taşıyan söz grubudur.$$,
    $$Adım 2: Cümlede önce bir sıkıntı (işlerin bozuk olması), sonra çözüm (işlerin yoluna girmesi) vardır.$$,
    $$Adım 3: "Rahat bir nefes almak" = üzerindeki sıkıntıdan kurtulup rahatlamak demektir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Söz Varlığı$$, $$Atasözleri$$, 2,
  $$"Sakla samanı, gelir zamanı." atasözünün vermek istediği asıl mesaj aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Samanı mutlaka saklamak gerekir.$$, 'B', $$İşe yaramaz şeyler hemen atılmalıdır.$$, 'C', $$Bugün gereksiz görünen bir şey ileride işe yarayabilir; tutumlu olmalıyız.$$, 'D', $$Hayvanlar kışın saman yer.$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Atasözleri bize bir öğüt verir. Buradaki "saman" aslında bir örnektir. "Gelir zamanı" sözü, ileride ona ihtiyaç duyulacağını anlatır.$$,
    $$Adım 1: Atasözleri, atalarımızdan kalan, öğüt veren kalıplaşmış sözlerdir.$$,
    $$Adım 2: "Saman" burada "şu an işe yaramaz görünen her şey" anlamında kullanılmıştır.$$,
    $$Adım 3: Atasözü, elimizdeki şeyleri israf etmeden saklamayı, tutumlu olmayı öğütler; çünkü bir gün gerekebilir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Yazım Kuralları$$, $$Büyük Harfin Kullanımı$$, 2,
  $$Aşağıdaki cümlelerin hangisinde büyük harf **yanlış** kullanılmıştır?$$,
  jsonb_build_object('A', $$Atatürk, Samsun'a çıktı.$$, 'B', $$Kardeşim Ayşe bugün okula gitti.$$, 'C', $$Biz Türkçe dersini çok severiz.$$, 'D', $$Yaz tatilinde Karadeniz'e Gittik.$$),
  'D',
  to_jsonb(ARRAY[
    $$İpucu: Büyük harf yalnızca cümlenin başında ve özel isimlerde kullanılır. Cümlenin ortasında, özel isim olmayan bir sözcüğün büyük harfle başlaması yanlıştır.$$,
    $$Adım 1: Özel isimler (Atatürk, Samsun, Ayşe, Türkçe, Karadeniz) ve cümle başları büyük harfle yazılır.$$,
    $$Adım 2: D seçeneğinde "Gittik" sözcüğü cümlenin ortasındadır ve özel isim değildir; bir eylemdir.$$,
    $$Adım 3: Doğrusu "...Karadeniz'e gittik." olmalıdır. Büyük harf yanlış kullanılmıştır. Doğru cevap D seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Noktalama İşaretleri$$, $$Soru İşareti$$, 1,
  $$Aşağıdaki cümlelerin hangisinin sonuna soru işareti (?) konulmalıdır?$$,
  jsonb_build_object('A', $$Dışarıda hava çok soğuk$$, 'B', $$Acaba yarın hava nasıl olacak$$, 'C', $$Ne kadar güzel bir manzara$$, 'D', $$Lütfen kapıyı kapat$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Soru işareti, bir şey sorulan, cevap beklenen cümlelerin sonuna konur. "Acaba" sözcüğü bir ipucudur.$$,
    $$Adım 1: Soru anlamı taşıyan, karşıdan cevap beklenen cümlelerin sonuna soru işareti konur.$$,
    $$Adım 2: A bilgi veren, C hayranlık bildiren (ünlem), D istek/emir cümlesidir.$$,
    $$Adım 3: "Acaba yarın hava nasıl olacak?" cümlesi bir sorudur ve cevap bekler. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Noktalama İşaretleri$$, $$Virgül$$, 2,
  $$"Pazardan elma armut kiraz ve üzüm aldık." cümlesinde virgül (,) kaç yere konulmalıdır?$$,
  jsonb_build_object('A', $$1$$, 'B', $$2$$, 'C', $$3$$, 'D', $$4$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Virgül, art arda sıralanan eş görevli sözcüklerin arasına konur. Ancak "ve" bağlacından önce virgül konmaz.$$,
    $$Adım 1: Sıralanan sözcükler: elma, armut, kiraz, üzüm.$$,
    $$Adım 2: "elma" ile "armut" arasına ve "armut" ile "kiraz" arasına virgül konur: "elma, armut, kiraz".$$,
    $$Adım 3: "kiraz" ile "üzüm" arasında "ve" bağlacı olduğu için oraya virgül konmaz. Böylece toplam 2 virgül olur: "elma, armut, kiraz ve üzüm". Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Ses Bilgisi$$, $$Hece$$, 1,
  $$"Kütüphane" sözcüğü kaç hecelidir?$$,
  jsonb_build_object('A', $$3$$, 'B', $$4$$, 'C', $$5$$, 'D', $$2$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir sözcükte kaç sesli (ünlü) harf varsa o kadar hece vardır. Sözcüğü parçalara ayırarak oku.$$,
    $$Adım 1: Sözcüğü hecelerine ayıralım: kü - tüp - ha - ne.$$,
    $$Adım 2: İçindeki ünlü harfler: ü, ü, a, e — yani 4 ünlü.$$,
    $$Adım 3: Ünlü sayısı kadar hece olduğundan sözcük 4 hecelidir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Sözcük Türleri$$, $$Sıfat (Ön Ad)$$, 2,
  $$"**Kırmızı** elbiseli kız hızla koştu." cümlesinde altı koyu "kırmızı" sözcüğünün türü (görevi) aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$isim$$, 'B', $$sıfat (ön ad)$$, 'C', $$fiil (eylem)$$, 'D', $$zamir (adıl)$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir varlığın rengini, biçimini, sayısını belirten; ismin önüne gelerek onu niteleyen sözcüklere sıfat denir. "Nasıl bir elbise?" sorusunun cevabına bak.$$,
    $$Adım 1: "Kırmızı" sözcüğü "elbise" isminin önüne gelmiştir.$$,
    $$Adım 2: "Nasıl bir elbise?" sorusunu sorduğumuzda cevap "kırmızı" olur; yani elbisenin rengini belirtir.$$,
    $$Adım 3: İsmin önüne gelip onu niteleyen/belirten sözcük sıfattır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Sözcük Türleri$$, $$Fiil (Eylem)$$, 1,
  $$Aşağıdaki sözcüklerden hangisi bir **eylem (fiil)** bildirir?$$,
  jsonb_build_object('A', $$kitap$$, 'B', $$koşmak$$, 'C', $$güzel$$, 'D', $$ev$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Eylemler bir iş, oluş veya hareket bildirir. Sonuna "-mak / -mek" ekleyebildiğin sözcükler genellikle fiildir.$$,
    $$Adım 1: "Kitap" ve "ev" birer varlık adıdır (isim), "güzel" ise bir niteleme sözcüğüdür (sıfat).$$,
    $$Adım 2: "Koşmak" bir hareketi, yapılan bir işi anlatır.$$,
    $$Adım 3: İş, oluş veya hareket bildiren sözcük fiildir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Sözcükte Anlam$$, $$Eş Sesli (Sesteş) Sözcükler$$, 2,
  $$"Yüz" sözcüğü aşağıdaki cümlelerin hangisinde "surat, çehre" anlamında kullanılmıştır?$$,
  jsonb_build_object('A', $$Havuzda tam yüz metre yüzdü.$$, 'B', $$Sevinçten onun yüzü gülüyordu.$$, 'C', $$Bu kalem yüz lira.$$, 'D', $$Hadi gel, benimle denizde yüz.$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Yüz" yazılışı aynı ama farklı anlamlara gelen bir sözcüktür: sayı (100), yüzmek eylemi ve surat. Hangi cümlede insanın yüzünden söz ediliyor?$$,
    $$Adım 1: A ve D seçeneğinde "yüz" = suda yüzme hareketidir; C'de "yüz" = 100 sayısıdır.$$,
    $$Adım 2: B seçeneğinde "yüzü gülüyordu" denerek insanın suratından söz edilmektedir.$$,
    $$Adım 3: "Surat, çehre" anlamı B seçeneğindedir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Cümlede Anlam$$, $$Neden - Sonuç İlişkisi$$, 2,
  $$"Çok çalıştığı **için** sınavı kazandı." cümlesinde hangi anlam ilişkisi vardır?$$,
  jsonb_build_object('A', $$amaç - sonuç$$, 'B', $$neden - sonuç$$, 'C', $$koşul (şart)$$, 'D', $$karşılaştırma$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir olayın hangi sebeple olduğu açıklanıyorsa neden-sonuç ilişkisi vardır. "Niçin kazandı?" diye sor; cevabı sebebi verir.$$,
    $$Adım 1: "Sınavı kazandı" bir sonuçtur. "Niçin kazandı?" sorusunu soralım.$$,
    $$Adım 2: Cevap: "Çok çalıştığı için." Bu, kazanmanın sebebidir.$$,
    $$Adım 3: Bir işin sebebi ile sonucu birlikte veriliyorsa buna neden-sonuç ilişkisi denir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Okuduğunu Anlama$$, $$Paragrafta Bilgi Bulma$$, 2,
  $$"Kitap okumak hayal gücümüzü geliştirir, bize yeni dünyaların kapılarını açar ve kelime hazinemizi zenginleştirir." Bu paragrafta kitap okumanın faydalarından hangisine **değinilmemiştir**?$$,
  jsonb_build_object('A', $$Hayal gücünü geliştirmesi$$, 'B', $$Kelime hazinesini zenginleştirmesi$$, 'C', $$Yeni dünyalar tanıtması$$, 'D', $$Göz sağlığını koruması$$),
  'D',
  to_jsonb(ARRAY[
    $$İpucu: Soru "değinilmemiştir" diyor; yani metinde geçmeyen seçeneği bulacaksın. Paragrafı tekrar oku ve her seçeneğin karşılığını metinde ara.$$,
    $$Adım 1: Paragrafta sırasıyla "hayal gücü", "yeni dünyaların kapısı" ve "kelime hazinesi" fayda olarak verilmiştir.$$,
    $$Adım 2: A, B ve C seçeneklerinin karşılığı metinde vardır.$$,
    $$Adım 3: "Göz sağlığı" paragrafta hiç geçmez; bu yüzden değinilmeyen faydadır. Doğru cevap D seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Yazım Kuralları$$, $$"de / da" nın Yazımı$$, 3,
  $$Aşağıdaki cümlelerin hangisinde "de" nin yazımı **yanlıştır**?$$,
  jsonb_build_object('A', $$Ben de sinemaya geleceğim.$$, 'B', $$Evde kimse yoktu.$$, 'C', $$Sende mi geldin?$$, 'D', $$Kalemi masada buldum.$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "da / de" eğer "-ılması" anlamı katmayıp "ayrıca, dahi" anlamı veriyorsa ayrı yazılır. Cümleden "de" yi atabiliyorsan ve cümle anlamlı kalıyorsa ayrı yazılır.$$,
    $$Adım 1: B ve D'de "-de / -da" bulunma eki olup sözcüğe bitişik doğru yazılmıştır (evde, masada).$$,
    $$Adım 2: A'da "de" ayrıca anlamı katar ve ayrı yazılır; bu doğrudur.$$,
    $$Adım 3: C'de "Sende mi" denmiş ama buradaki "de" ayrıca anlamı katıyor ("Sen de mi geldin?"); ayrı yazılmalıdır. Bitişik yazılması yanlıştır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Yazım Kuralları$$, $$Soru Eki "mi" nin Yazımı$$, 2,
  $$Aşağıdaki cümlelerin hangisinde soru eki "mi" **yanlış** yazılmıştır?$$,
  jsonb_build_object('A', $$Yemeğini yedin mi?$$, 'B', $$Bizimle gelmiyor musun?$$, 'C', $$Buraya sen mi geldin?$$, 'D', $$Okula gittinmi?$$),
  'D',
  to_jsonb(ARRAY[
    $$İpucu: Soru eki "mi / mı / mu / mü" her zaman kendinden önceki sözcükten ayrı yazılır.$$,
    $$Adım 1: Soru eki "mi" ayrı yazılan bir ektir.$$,
    $$Adım 2: A, B ve C'de "mi / musun / mi" ayrı yazılmıştır; doğrudur.$$,
    $$Adım 3: D'de "gittinmi" bitişik yazılmış; doğrusu "gittin mi?" olmalıdır. Doğru cevap D seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Cümlede Anlam$$, $$Karşılaştırma$$, 1,
  $$"Ali, Veli'den **daha** uzun boyludur." cümlesinde aşağıdaki anlam ilişkilerinden hangisi vardır?$$,
  jsonb_build_object('A', $$neden - sonuç$$, 'B', $$karşılaştırma$$, 'C', $$abartma$$, 'D', $$amaç$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İki varlık bir özellik bakımından birbiriyle ölçülüyorsa karşılaştırma vardır. "daha", "en", "kadar" sözcükleri ipucu olabilir.$$,
    $$Adım 1: Cümlede iki kişi (Ali ve Veli) vardır.$$,
    $$Adım 2: İkisi "boy" özelliği bakımından kıyaslanıyor ve "daha uzun" denerek birinin üstünlüğü belirtiliyor.$$,
    $$Adım 3: İki varlığın bir yönden ölçülmesine karşılaştırma denir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Sözcükte Anlam$$, $$Eş Anlamlılık$$, 1,
  $$"Kara" sözcüğünün eş anlamlısı aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$beyaz$$, 'B', $$siyah$$, 'C', $$kır$$, 'D', $$mavi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Eş anlamlı sözcük, aynı anlama gelen farklı sözcüktür. "Kara" bir renktir; hangi renkle aynı anlama gelir?$$,
    $$Adım 1: "Kara" sözcüğü bir rengin adıdır.$$,
    $$Adım 2: "Beyaz" ve "mavi" farklı renklerdir; "beyaz" zaten karanın zıttıdır.$$,
    $$Adım 3: "Kara" ile "siyah" aynı rengi anlatır, yani eş anlamlıdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Sözlük Kullanımı$$, $$Alfabetik Sıralama$$, 2,
  $$"elma, armut, incir, çilek" sözcükleri sözlük sırasına (alfabetik) göre dizildiğinde hangisi **en başta** yer alır?$$,
  jsonb_build_object('A', $$elma$$, 'B', $$armut$$, 'C', $$incir$$, 'D', $$çilek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Türk alfabesinde sıra: a, b, c, ç, d, e, f, g, ... şeklindedir. Sözcüklerin ilk harflerine bakarak alfabede en önce geleni bul.$$,
    $$Adım 1: Sözcüklerin ilk harfleri: elma → e, armut → a, incir → i, çilek → ç.$$,
    $$Adım 2: Alfabede bu harflerin sırası: a, ç, e, i.$$,
    $$Adım 3: En önce gelen harf "a" olduğundan "armut" en başta yer alır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Türkçe$$, $$Sözcük Yapısı$$, $$Kök$$, 2,
  $$"Kitaplık" sözcüğünün kökü aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$kitap$$, 'B', $$kitaplı$$, 'C', $$lık$$, 'D', $$kitapçı$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Kök, bir sözcüğün anlamlı en küçük parçasıdır; ekler atıldığında geriye kalan kısımdır. Sözcüğün sonundaki eki atmayı dene.$$,
    $$Adım 1: "Kitaplık" sözcüğünden "-lık" ekini atalım.$$,
    $$Adım 2: Geriye "kitap" kalır ve bu tek başına anlamlı bir sözcüktür.$$,
    $$Adım 3: Ek atıldığında geriye kalan anlamlı en küçük parça kök olduğundan kök "kitap" tır. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Dünya'mız$$, $$Dünya'nın Şekli$$, 1,
  $$Dünya'mızın şekli aşağıdakilerden hangisine benzer?$$,
  jsonb_build_object('A', $$kare$$, 'B', $$küreye (yuvarlağa)$$, 'C', $$üçgene$$, 'D', $$dikdörtgene$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Uzaydan çekilen fotoğraflarda Dünya'nın top gibi yuvarlak göründüğünü hatırla.$$,
    $$Adım 1: Dünya düz değildir; uzaydan bakıldığında yuvarlak (top gibi) görünür.$$,
    $$Adım 2: Bu top benzeri geometrik şekle küre denir.$$,
    $$Adım 3: Dünya kutuplardan hafif basık bir küre biçimindedir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Dünya'nın Hareketleri$$, $$Gece ve Gündüzün Oluşması$$, 2,
  $$Dünya üzerinde gece ve gündüzün oluşmasının temel nedeni aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Dünya'nın Güneş'in çevresinde dolanması$$, 'B', $$Dünya'nın kendi ekseni etrafında dönmesi$$, 'C', $$Ay'ın Dünya çevresinde dönmesi$$, 'D', $$Mevsimlerin değişmesi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Dünya dönerken bir yüzü Güneş'e döner (orası aydınlık/gündüz), diğer yüzü karanlıkta kalır (orası gece). Bu dönüş günde bir kez olur.$$,
    $$Adım 1: Dünya kendi ekseni etrafında bir günde (24 saatte) bir tam tur döner.$$,
    $$Adım 2: Dönerken Güneş'e dönük olan kısımda gündüz, karanlıkta kalan kısımda gece yaşanır.$$,
    $$Adım 3: Yani gece-gündüz, Dünya'nın kendi ekseni etrafındaki dönmesiyle oluşur. (Güneş çevresindeki dolanma ise mevsimleri oluşturur.) Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Ay$$, $$Ay'ın Dolanımı$$, 2,
  $$Ay, Dünya'nın çevresindeki dolanımını yaklaşık ne kadar sürede tamamlar?$$,
  jsonb_build_object('A', $$1 günde$$, 'B', $$1 haftada$$, 'C', $$yaklaşık 1 ayda (yaklaşık 28 günde)$$, 'D', $$1 yılda$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "Ay" sözcüğü sana süreyle ilgili bir ipucu veriyor. Ay'ın bir turu, takvimdeki bir ay kadar sürer.$$,
    $$Adım 1: Ay, Dünya'nın uydusudur ve Dünya'nın çevresinde döner.$$,
    $$Adım 2: Bu dolanım yaklaşık 28 gün, yani yaklaşık bir ay sürer.$$,
    $$Adım 3: Bu süre zarfında Ay'ı farklı şekillerde (evreler) görürüz. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Besinlerimiz$$, $$Besin İçerikleri$$, 2,
  $$Kemiklerimizin ve dişlerimizin sağlıklı gelişmesi için gerekli olan, süt ve süt ürünlerinde bol bulunan mineral aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Demir$$, 'B', $$Kalsiyum$$, 'C', $$C vitamini$$, 'D', $$Şeker$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Büyüklerimiz "kemiklerin güçlensin diye süt iç" der. Sütteki hangi madde kemikleri güçlendirir?$$,
    $$Adım 1: Süt, yoğurt, peynir gibi süt ürünleri kemik sağlığı için önemlidir.$$,
    $$Adım 2: Bu besinlerde bol bulunan ve kemik-diş gelişimini sağlayan mineral kalsiyumdur.$$,
    $$Adım 3: Demir kana, C vitamini hastalıklara direnç için gereklidir; kemik için temel olan kalsiyumdur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Maddeyi Tanıyalım$$, $$Hâl Değişimi (Erime)$$, 1,
  $$Buzun eriyerek suya dönüşmesi, maddenin hangi hâlinden hangi hâline geçişidir?$$,
  jsonb_build_object('A', $$Katı hâlden sıvı hâle$$, 'B', $$Sıvı hâlden gaz hâle$$, 'C', $$Gaz hâlden katı hâle$$, 'D', $$Sıvı hâlden katı hâle$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Buz serttir, elinde tutabilirsin (katı). Su ise akar (sıvı). Buz ısınınca ne olur?$$,
    $$Adım 1: Buz, suyun katı hâlidir; su ise sıvı hâldir.$$,
    $$Adım 2: Buz ısı alınca yumuşayıp akan suya dönüşür.$$,
    $$Adım 3: Katı bir maddenin ısı alarak sıvıya dönüşmesine erime denir; yani katı hâlden sıvı hâle geçiştir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Maddeyi Tanıyalım$$, $$Hâl Değişimi (Donma)$$, 1,
  $$Suyun soğuyarak buz hâline gelmesi olayına ne ad verilir?$$,
  jsonb_build_object('A', $$Erime$$, 'B', $$Buharlaşma$$, 'C', $$Donma$$, 'D', $$Yoğuşma$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Suyu buzlukta beklettiğimizde ne olur? Bu olayın adını düşün.$$,
    $$Adım 1: Su (sıvı) soğutulunca ısı kaybeder.$$,
    $$Adım 2: Yeterince soğuyunca sertleşip buza (katı) dönüşür.$$,
    $$Adım 3: Sıvı bir maddenin ısı vererek katıya dönüşmesine donma denir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Kuvveti Tanıyalım$$, $$Kuvvetin Etkileri$$, 1,
  $$Duran bir topa ayağımızla vurduğumuzda top harekete geçer. Buna göre kuvvet, cisimler üzerinde ne yapabilir?$$,
  jsonb_build_object('A', $$Sadece rengini değiştirir.$$, 'B', $$Duran cisimleri hareket ettirebilir.$$, 'C', $$Yalnızca cisimleri ısıtır.$$, 'D', $$Cisimlerin kokusunu değiştirir.$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Topa vurmadan önce top duruyordu, vurduktan sonra hareket etti. Bu değişikliği ne sağladı?$$,
    $$Adım 1: Topa ayakla vurmak bir itme kuvveti uygulamaktır.$$,
    $$Adım 2: Bu kuvvetten önce top duruyordu, sonra hareket etti.$$,
    $$Adım 3: Demek ki kuvvet duran cisimleri hareket ettirebilir (ayrıca hareketliyi durdurabilir, yön ve şekil değiştirebilir). Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Kuvveti Tanıyalım$$, $$İtme ve Çekme$$, 2,
  $$Aşağıdaki hareketlerden hangisi bir **çekme** kuvvetine örnektir?$$,
  jsonb_build_object('A', $$Arabayı arkadan iterek hareket ettirmek$$, 'B', $$Çekmeceyi kendimize doğru açmak$$, 'C', $$Topu uzağa fırlatmak$$, 'D', $$Kapıyı iterek kapatmak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Çekme, bir cismi kendimize doğru yaklaştırmaktır. İtme ise kendimizden uzaklaştırmaktır.$$,
    $$Adım 1: İtmede cisim bizden uzağa gider; çekmede cisim bize doğru gelir.$$,
    $$Adım 2: A, C ve D seçeneklerinde cisimler bizden uzağa (itme) gönderilir.$$,
    $$Adım 3: Çekmeceyi kendimize doğru açarken onu bize doğru çekeriz; bu bir çekme kuvvetidir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Aydınlatma$$, $$Işık Kaynakları$$, 1,
  $$Aşağıdakilerden hangisi **doğal** bir ışık kaynağıdır?$$,
  jsonb_build_object('A', $$Lamba$$, 'B', $$El feneri$$, 'C', $$Güneş$$, 'D', $$Mum$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Doğal ışık kaynakları insan yapımı değildir, kendiliğinden vardır. İnsan eliyle yapılanlar yapay kaynaktır.$$,
    $$Adım 1: Lamba, el feneri ve mum insan tarafından üretilen yapay ışık kaynaklarıdır.$$,
    $$Adım 2: Güneş ise doğada kendiliğinden bulunan, insan yapımı olmayan bir kaynaktır.$$,
    $$Adım 3: Bu yüzden Güneş doğal bir ışık kaynağıdır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Aydınlatma$$, $$Işık Kaynağı ve Yansıma$$, 2,
  $$Aşağıdakilerden hangisi kendiliğinden ışık **üretmez**, yalnızca üzerine gelen ışığı yansıtır?$$,
  jsonb_build_object('A', $$Yıldız$$, 'B', $$Ayna$$, 'C', $$Mum$$, 'D', $$Şimşek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Karanlık bir odada ayna ışık verir mi? Yoksa ancak ona bir ışık tutunca mı parlar?$$,
    $$Adım 1: Yıldız, mum ve şimşek kendileri ışık üretir (ışık kaynağıdır).$$,
    $$Adım 2: Ayna karanlıkta hiç ışık vermez; ancak üzerine ışık geldiğinde onu yansıtır.$$,
    $$Adım 3: Kendi ışığını üretmeyip gelen ışığı yansıtan cisim aynadır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Basit Elektrik Devreleri$$, $$Devre Elemanları$$, 1,
  $$Basit bir elektrik devresinde ampulün ışık verebilmesi için aşağıdakilerden hangisi mutlaka gereklidir?$$,
  jsonb_build_object('A', $$Pil (enerji kaynağı)$$, 'B', $$Su$$, 'C', $$Mıknatıs$$, 'D', $$Buz$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: El fenerinin ışık vermesi için içine ne koyarız? Bittiğinde neyi değiştiririz?$$,
    $$Adım 1: Ampulün yanması için elektrik enerjisine ihtiyaç vardır.$$,
    $$Adım 2: Basit devrede bu enerjiyi pil sağlar.$$,
    $$Adım 3: Su, mıknatıs ve buz ampulü yakmaz; enerji kaynağı olan pil gereklidir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Basit Elektrik Devreleri$$, $$İletken ve Yalıtkan Maddeler$$, 2,
  $$Aşağıdaki maddelerden hangisi elektriği **iletir**?$$,
  jsonb_build_object('A', $$Plastik$$, 'B', $$Cam$$, 'C', $$Bakır tel$$, 'D', $$Tahta$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Evdeki elektrik kablolarının içinde hangi madde bulunur? Metaller elektriği iletir.$$,
    $$Adım 1: Elektriği ileten maddelere iletken, iletmeyenlere yalıtkan denir.$$,
    $$Adım 2: Plastik, cam ve tahta elektriği iletmez; bunlar yalıtkandır.$$,
    $$Adım 3: Bakır bir metaldir ve elektriği iletir; bu yüzden kablolarda kullanılır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$İnsan ve Çevre$$, $$Geri Dönüşüm$$, 1,
  $$Aşağıdakilerden hangisi geri dönüştürülebilen bir atıktır?$$,
  jsonb_build_object('A', $$Meyve kabuğu$$, 'B', $$Cam şişe$$, 'C', $$Yemek artığı$$, 'D', $$Çay posası$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Geri dönüşüm kutularında kâğıt, cam, metal ve plastik toplanır. Yiyecek atıkları ise organik çöptür.$$,
    $$Adım 1: Meyve kabuğu, yemek artığı ve çay posası organik (çürüyebilen) atıklardır.$$,
    $$Adım 2: Cam şişe eritilip yeniden cam ürünlere dönüştürülebilir.$$,
    $$Adım 3: Bu yüzden geri dönüştürülebilen atık cam şişedir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Maddeyi Tanıyalım$$, $$Ölçme Araçları (Kütle)$$, 1,
  $$Bir cismin kütlesini ölçmek için aşağıdaki araçlardan hangisi kullanılır?$$,
  jsonb_build_object('A', $$Termometre$$, 'B', $$Cetvel$$, 'C', $$Eşit kollu terazi$$, 'D', $$Saat$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Pazarda meyve-sebze tartılırken hangi araç kullanılır? Kütle "ağırlık" ölçer gibi düşün.$$,
    $$Adım 1: Termometre sıcaklığı, cetvel uzunluğu, saat zamanı ölçer.$$,
    $$Adım 2: Kütle, bir cisimdeki madde miktarıdır ve terazi ile ölçülür.$$,
    $$Adım 3: Eşit kollu terazi kütle ölçmek için kullanılır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Maddeyi Tanıyalım$$, $$Ölçme Araçları (Sıcaklık)$$, 1,
  $$Bir ortamın ya da cismin sıcaklığını ölçmek için kullanılan araç aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Terazi$$, 'B', $$Termometre$$, 'C', $$Mezura$$, 'D', $$Kronometre$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Hastalandığında ateşini ölçmek için koltuk altına konan araç hangisidir?$$,
    $$Adım 1: Terazi kütle, mezura uzunluk, kronometre süre ölçer.$$,
    $$Adım 2: Sıcaklık ölçen araç termometredir.$$,
    $$Adım 3: Vücut ateşi de hava sıcaklığı da termometre ile ölçülür. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Dünya'mız$$, $$Güneş$$, 1,
  $$Gündüzleri çevremizi aydınlatan, Dünya'mıza ışık ve ısı veren gök cismi aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Ay$$, 'B', $$Güneş$$, 'C', $$Yıldızlar$$, 'D', $$Bulut$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sabah doğup bizi ısıtan, akşam batan parlak gök cismini düşün.$$,
    $$Adım 1: Ay geceleri görülür ve kendi ışığı yoktur; Güneş'in ışığını yansıtır.$$,
    $$Adım 2: Dünya'ya ışık ve ısı veren gök cismi Güneş'tir.$$,
    $$Adım 3: Güneş aynı zamanda en yakın yıldızımızdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Besinlerimiz$$, $$Vitaminler$$, 2,
  $$Portakal, limon ve mandalina gibi meyvelerde bol bulunan, hastalıklara karşı direncimizi artıran vitamin aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$A vitamini$$, 'B', $$C vitamini$$, 'C', $$D vitamini$$, 'D', $$K vitamini$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kışın grip olmayalım diye annelerimiz bize portakal yedirir. Turunçgillerde bol bulunan vitamini düşün.$$,
    $$Adım 1: Portakal, limon, mandalina turunçgil denen meyvelerdir.$$,
    $$Adım 2: Bu meyvelerde bol bulunan vitamin C vitaminidir.$$,
    $$Adım 3: C vitamini vücudun hastalıklara karşı direncini artırır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Geçmişten Günümüze Teknoloji$$, $$Haberleşme Araçları$$, 3,
  $$Haberleşmede kullanılan araçlar eskiden yeniye doğru sıralandığında aşağıdakilerden hangisi doğrudur?$$,
  jsonb_build_object('A', $$Akıllı telefon → mektup → telgraf$$, 'B', $$Mektup → telgraf → akıllı telefon$$, 'C', $$Telgraf → akıllı telefon → mektup$$, 'D', $$Akıllı telefon → telgraf → mektup$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: En eski haberleşme yöntemi, elle yazılıp gönderilen kâğıttı. Akıllı telefon ise en yeni teknolojidir.$$,
    $$Adım 1: İnsanlar çok eskiden haberlerini mektupla (elle yazılan kâğıt) gönderirdi.$$,
    $$Adım 2: Daha sonra elektrikle çalışan telgraf bulundu; mesajlar daha hızlı iletildi.$$,
    $$Adım 3: Günümüzde ise en yeni teknoloji akıllı telefondur. Doğru sıralama: mektup → telgraf → akıllı telefon. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Vücudumuz$$, $$Duyu Organları$$, 1,
  $$Yediğimiz yiyeceklerin tadını almamızı sağlayan duyu organımız aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Göz$$, 'B', $$Dil$$, 'C', $$Kulak$$, 'D', $$Burun$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Tatlı, tuzlu, acı, ekşi tatları ağzımızdaki hangi organla ayırt ederiz?$$,
    $$Adım 1: Göz görmeyi, kulak duymayı, burun koku almayı sağlar.$$,
    $$Adım 2: Tat alma duyusunu dilimiz sağlar.$$,
    $$Adım 3: Dil üzerindeki tat alma bölgeleri tatlı, tuzlu, acı ve ekşiyi ayırt eder. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Fen Bilimleri$$, $$Maddeyi Tanıyalım$$, $$Hâl Değişimi (Buharlaşma)$$, 2,
  $$Islak çamaşırların güneşte asılı kalarak kuruması, suyun hangi hâl değişimine örnektir?$$,
  jsonb_build_object('A', $$Donma$$, 'B', $$Erime$$, 'C', $$Buharlaşma$$, 'D', $$Yoğuşma$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Çamaşırdaki su kuruyunca nereye gitti? Sıvı su, ısı alınca görünmez su buharına dönüşür.$$,
    $$Adım 1: Islak çamaşırdaki su, güneşin ısısıyla ısınır.$$,
    $$Adım 2: Isınan sıvı su, su buharına (gaz) dönüşerek havaya karışır; böylece çamaşır kurur.$$,
    $$Adım 3: Sıvı bir maddenin ısı alarak gaza dönüşmesine buharlaşma denir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Kültür ve Miras$$, $$Milli Bayramlar$$, 1,
  $$29 Ekim'de kutladığımız milli bayramımız aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$23 Nisan Ulusal Egemenlik ve Çocuk Bayramı$$, 'B', $$19 Mayıs Atatürk'ü Anma, Gençlik ve Spor Bayramı$$, 'C', $$29 Ekim Cumhuriyet Bayramı$$, 'D', $$30 Ağustos Zafer Bayramı$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Soruda verilen tarih 29 Ekim'dir. Hangi bayramın adında bu tarih geçer?$$,
    $$Adım 1: 29 Ekim 1923'te Cumhuriyet ilan edilmiştir.$$,
    $$Adım 2: Bu olayın yıl dönümü her yıl 29 Ekim'de kutlanır.$$,
    $$Adım 3: Bu bayramın adı Cumhuriyet Bayramı'dır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Kültür ve Miras$$, $$23 Nisan$$, 2,
  $$23 Nisan Ulusal Egemenlik ve Çocuk Bayramı, hangi önemli olayın yıl dönümünde kutlanır?$$,
  jsonb_build_object('A', $$Cumhuriyet'in ilan edilmesi$$, 'B', $$Türkiye Büyük Millet Meclisi'nin (TBMM) açılması$$, 'C', $$İstanbul'un fethi$$, 'D', $$Kurtuluş Savaşı'nın kazanılması$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Ulusal egemenlik" milletin kendi kendini yönetmesi demektir. Bu egemenliğin simgesi olan meclis hangi tarihte açılmıştır?$$,
    $$Adım 1: 23 Nisan 1920'de Türkiye Büyük Millet Meclisi (TBMM) açılmıştır.$$,
    $$Adım 2: Meclisin açılması, milletin kendi kendini yönetmesinin, yani ulusal egemenliğin başlangıcıdır.$$,
    $$Adım 3: Atatürk bu bayramı dünya çocuklarına armağan etmiştir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Kültür ve Miras$$, $$Atatürk'ün Hayatı$$, 1,
  $$Mustafa Kemal Atatürk aşağıdaki şehirlerden hangisinde doğmuştur?$$,
  jsonb_build_object('A', $$Ankara$$, 'B', $$İstanbul$$, 'C', $$Selanik$$, 'D', $$İzmir$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Atatürk'ün doğduğu şehir bugün ülkemizin sınırları dışında, komşu bir ülkededir.$$,
    $$Adım 1: Mustafa Kemal 1881 yılında Selanik'te doğmuştur.$$,
    $$Adım 2: Selanik bugün Yunanistan sınırları içindedir.$$,
    $$Adım 3: Ankara, İstanbul ve İzmir onun doğduğu yer değildir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$İnsanlar, Yerler ve Çevreler$$, $$Yönler$$, 1,
  $$Güneş her gün hangi yönden doğar?$$,
  jsonb_build_object('A', $$Batı$$, 'B', $$Doğu$$, 'C', $$Kuzey$$, 'D', $$Güney$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Güneşin doğduğu yön ile battığı yön birbirinin tam tersidir. Sabahları Güneşe baktığında yüzün hangi yöne döner?$$,
    $$Adım 1: Güneş sabahları bir yönden doğar, akşam karşı yönden batar.$$,
    $$Adım 2: Güneşin doğduğu yön doğu, battığı yön batıdır.$$,
    $$Adım 3: Bu nedenle Güneş doğudan doğar. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$İnsanlar, Yerler ve Çevreler$$, $$Yön Bulma Araçları$$, 1,
  $$Yönümüzü bulmak için kullanılan, ibresi her zaman kuzeyi gösteren araç aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Termometre$$, 'B', $$Pusula$$, 'C', $$Cetvel$$, 'D', $$Saat$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Dağcılar ve denizciler kaybolmamak için bu küçük aracı kullanır; içindeki ibre hep kuzeyi gösterir.$$,
    $$Adım 1: Termometre sıcaklığı, cetvel uzunluğu, saat zamanı ölçer.$$,
    $$Adım 2: Yön bulmaya yarayan araç pusuladır.$$,
    $$Adım 3: Pusulanın mıknatıslı ibresi her zaman kuzeyi gösterir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$İnsanlar, Yerler ve Çevreler$$, $$Ana ve Ara Yönler$$, 2,
  $$Aşağıdakilerden hangisi ana yönlerden biri **değildir**?$$,
  jsonb_build_object('A', $$Kuzey$$, 'B', $$Güney$$, 'C', $$Kuzeydoğu$$, 'D', $$Batı$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Ana yönler dörttür. İki ana yönün adının birleşiminden oluşan yönler ise ara yöndür.$$,
    $$Adım 1: Ana yönler: kuzey, güney, doğu, batı.$$,
    $$Adım 2: "Kuzeydoğu" iki ana yönün (kuzey + doğu) arasında kalan bir ara yöndür.$$,
    $$Adım 3: Bu nedenle kuzeydoğu ana yön değildir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Birey ve Toplum$$, $$Çocuk Hakları$$, 2,
  $$Aşağıdakilerden hangisi her çocuğun sahip olduğu temel haklardan biridir?$$,
  jsonb_build_object('A', $$Çalışıp para kazanmak zorunda olmak$$, 'B', $$Eğitim görme (okula gitme) hakkı$$, 'C', $$Araba kullanma (ehliyet alma) hakkı$$, 'D', $$Seçimlerde oy kullanma hakkı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Çocuk hakları, çocukların sağlıklı büyümesi ve gelişmesi içindir. Araba kullanmak ve oy vermek yetişkinlere tanınan haklardır.$$,
    $$Adım 1: Çalışmak zorunda olmak bir hak değil, çocuğu koruyan yasalarla engellenen bir durumdur.$$,
    $$Adım 2: Ehliyet ve oy kullanma yalnızca belirli yaştan büyükler içindir.$$,
    $$Adım 3: Her çocuğun eğitim görme (okula gitme) hakkı vardır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Üretim, Dağıtım ve Tüketim$$, $$İhtiyaç ve İstek$$, 1,
  $$Aşağıdakilerden hangisi insanın yaşamını sürdürebilmesi için gerekli olan temel bir **ihtiyaçtır**?$$,
  jsonb_build_object('A', $$Oyuncak$$, 'B', $$Beslenme (yemek yemek)$$, 'C', $$Bilgisayar oyunu$$, 'D', $$Pahalı bir ayakkabı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İhtiyaç, olmadan yaşayamayacağımız şeylerdir. İstek ise olmasa da yaşayabileceğimiz, hoşumuza giden şeylerdir.$$,
    $$Adım 1: Oyuncak, bilgisayar oyunu ve pahalı ayakkabı birer istektir; olmadan da yaşanır.$$,
    $$Adım 2: Beslenme (yemek) olmadan insan yaşamını sürdüremez.$$,
    $$Adım 3: Bu yüzden beslenme temel bir ihtiyaçtır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Üretim, Dağıtım ve Tüketim$$, $$Bütçe$$, 2,
  $$Gelirlerimiz ile giderlerimizi önceden planlayarak tasarruf etmemizi sağlayan plana ne ad verilir?$$,
  jsonb_build_object('A', $$Bütçe$$, 'B', $$Fatura$$, 'C', $$Reklam$$, 'D', $$Borç$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Harçlığını "ne kadar geldi, ne kadar harcayacağım, ne kadar biriktireceğim" diye planlarsan bir çeşit ne yapmış olursun?$$,
    $$Adım 1: Gelir elimize giren para, gider ise harcadığımız paradır.$$,
    $$Adım 2: Gelir ve gideri önceden planlamaya bütçe yapmak denir.$$,
    $$Adım 3: Bütçe sayesinde gereksiz harcamadan kaçınıp tasarruf edebiliriz. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$İnsanlar, Yerler ve Çevreler$$, $$Kroki$$, 2,
  $$Bir yerin kuş bakışı görünüşünün, kabataslak biçimde kâğıt üzerine çizilmesine ne ad verilir?$$,
  jsonb_build_object('A', $$Fotoğraf$$, 'B', $$Kroki$$, 'C', $$Portre$$, 'D', $$Grafik$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir arkadaşına evinin yerini tarif ederken çizdiğin basit yol çizimini düşün. "Kuş bakışı" yukarıdan bakış demektir.$$,
    $$Adım 1: "Kuş bakışı", bir yere tam tepeden (yukarıdan) bakmak demektir.$$,
    $$Adım 2: Bir yerin yukarıdan görünüşünün kabaca kâğıda çizilmesine kroki denir.$$,
    $$Adım 3: Fotoğraf makineyle çekilir, grafik ise sayıları gösterir; aranan çizim krokidir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Kültür ve Miras$$, $$Milli Mücadele$$, 2,
  $$Mustafa Kemal, Kurtuluş Savaşı'nı başlatmak amacıyla 19 Mayıs 1919'da hangi şehre çıkmıştır?$$,
  jsonb_build_object('A', $$Ankara$$, 'B', $$Samsun$$, 'C', $$Erzurum$$, 'D', $$Sivas$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: 19 Mayıs tarihini ve bu tarihte kutladığımız bayramı hatırla; Atatürk'ün bu yolculuğu milli mücadelenin başlangıcıdır.$$,
    $$Adım 1: Mustafa Kemal 19 Mayıs 1919'da bir gemiyle yola çıkmıştır.$$,
    $$Adım 2: Çıktığı liman kenti Samsun'dur ve bu olay Kurtuluş Savaşı'nın başlangıcı sayılır.$$,
    $$Adım 3: Erzurum ve Sivas kongreleri daha sonra yapılmıştır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Etkin Vatandaşlık$$, $$Kamu Kurumları$$, 2,
  $$Kimlik kartı (nüfus cüzdanı) almak veya doğum kaydı yaptırmak için aşağıdaki kurumlardan hangisine başvururuz?$$,
  jsonb_build_object('A', $$Hastane$$, 'B', $$Nüfus Müdürlüğü$$, 'C', $$Okul$$, 'D', $$İtfaiye$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kimlik ve nüfus işlemleri "nüfus" sözcüğünü içeren bir kurumda yapılır.$$,
    $$Adım 1: Hastane sağlık, okul eğitim, itfaiye yangın hizmeti verir.$$,
    $$Adım 2: Kimlik kartı, doğum ve nüfus kayıtları Nüfus Müdürlüğü'nde yapılır.$$,
    $$Adım 3: Bu nedenle kimlik almak için Nüfus Müdürlüğü'ne başvururuz. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$İnsanlar, Yerler ve Çevreler$$, $$Doğal Varlıklar$$, 2,
  $$Aşağıdakilerden hangisi **doğal** bir varlıktır?$$,
  jsonb_build_object('A', $$Köprü$$, 'B', $$Baraj$$, 'C', $$Dağ$$, 'D', $$Bina$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Doğal varlıklar kendiliğinden, insan eli değmeden oluşur. İnsanın yaptığı yapılar ise beşeri unsurdur.$$,
    $$Adım 1: Köprü, baraj ve bina insan tarafından yapılmış beşeri (yapay) unsurlardır.$$,
    $$Adım 2: Dağ ise doğada kendiliğinden oluşmuş bir yer şeklidir.$$,
    $$Adım 3: Bu yüzden dağ doğal bir varlıktır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$İnsanlar, Yerler ve Çevreler$$, $$Beşeri Unsurlar$$, 2,
  $$Aşağıdakilerden hangisi insan eliyle oluşturulmuş (beşeri) bir unsurdur?$$,
  jsonb_build_object('A', $$Nehir$$, 'B', $$Orman$$, 'C', $$Yol$$, 'D', $$Göl$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Bir önceki sorunun tersini düşün: bunlardan hangisini insanlar inşa etmiştir?$$,
    $$Adım 1: Nehir, orman ve göl doğada kendiliğinden bulunan doğal varlıklardır.$$,
    $$Adım 2: Yol ise insanlar tarafından yapılmıştır.$$,
    $$Adım 3: İnsan eliyle oluşturulan unsurlara beşeri unsur denir; bu nedenle cevap yoldur. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Bilim, Teknoloji ve Toplum$$, $$İcatlar$$, 2,
  $$Elektrik ampulünü geliştirerek gecelerin aydınlanmasına büyük katkı sağlayan bilim insanı aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Graham Bell$$, 'B', $$Thomas Edison$$, 'C', $$Isaac Newton$$, 'D', $$Wright Kardeşler$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Her bilim insanı farklı bir icatla tanınır: biri telefon, biri uçak, biri yer çekimi... Ampulü kim geliştirdi?$$,
    $$Adım 1: Graham Bell telefonla, Wright Kardeşler uçakla, Newton yer çekimiyle anılır.$$,
    $$Adım 2: Elektrik ampulünü geliştiren bilim insanı Thomas Edison'dur.$$,
    $$Adım 3: Edison'un ampulü sayesinde geceleri aydınlatma kolaylaşmıştır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Birey ve Toplum$$, $$Sorumluluk$$, 2,
  $$Ailemizin, okulumuzun ve toplumun bir bireyi olarak üzerimize düşen görevleri eksiksiz yerine getirmeye ne ad verilir?$$,
  jsonb_build_object('A', $$Hak$$, 'B', $$Sorumluluk$$, 'C', $$Özgürlük$$, 'D', $$İstek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Ödevini yapmak, odanı toplamak gibi "yapmam gereken görevler" senin neyin olur?$$,
    $$Adım 1: Hak, bize tanınan yetkilerdir; özgürlük ise serbestçe davranabilmektir.$$,
    $$Adım 2: Üzerimize düşen görevleri yerine getirmeye sorumluluk denir.$$,
    $$Adım 3: Ödevini yapmak, kurallara uymak birer sorumluluktur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Kültür ve Miras$$, $$Kültürel Miras$$, 2,
  $$Aşağıdakilerden hangisi ülkemizin kültürel mirasına (geçmişten gelen değerlerine) örnek gösterilebilir?$$,
  jsonb_build_object('A', $$Cep telefonu$$, 'B', $$Geleneksel el sanatları (çini, halı, ebru)$$, 'C', $$Televizyon$$, 'D', $$Otomobil$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kültürel miras, atalarımızdan bize kalan; gelenek, sanat ve değerlerdir. Hangi seçenek yüzyıllardır bize ait bir sanattır?$$,
    $$Adım 1: Cep telefonu, televizyon ve otomobil modern teknoloji ürünleridir.$$,
    $$Adım 2: Çini, halı ve ebru gibi el sanatları geçmişten gelen, bize özgü geleneksel değerlerdir.$$,
    $$Adım 3: Bu geleneksel sanatlar kültürel mirasımızdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Birey ve Toplum$$, $$Afetlerden Korunma$$, 2,
  $$Deprem anında bina içindeysek yapmamız gereken en doğru davranış aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Hemen asansöre binip aşağı inmek$$, 'B', $$Balkona ya da pencere kenarına koşmak$$, 'C', $$Sağlam bir masanın altına girip "çök-kapan-tutun" yapmak$$, 'D', $$Koşarak merdivenlerden inmeye çalışmak$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Deprem sırasında koşmak ve asansör tehlikelidir. Kendini düşen eşyalardan koruyacak güvenli bir yer bulmalısın.$$,
    $$Adım 1: Deprem anında asansör ve merdiven tehlikelidir; koşmak düşmeye yol açar.$$,
    $$Adım 2: En güvenli davranış sağlam bir masanın altına girip başını korumak, yani "çök-kapan-tutun" yapmaktır.$$,
    $$Adım 3: Sarsıntı bitince güvenli şekilde dışarı çıkılır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Küresel Bağlantılar$$, $$Ülkemizin Konumu$$, 2,
  $$Ülkemiz Türkiye, toprakları bakımından hangi iki kıta üzerinde yer alır?$$,
  jsonb_build_object('A', $$Asya ve Avrupa$$, 'B', $$Asya ve Afrika$$, 'C', $$Avrupa ve Amerika$$, 'D', $$Afrika ve Avrupa$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Ülkemizin büyük bölümü Asya'dadır; İstanbul Boğazı'nın bir yakası ise başka bir kıtadadır.$$,
    $$Adım 1: Türkiye topraklarının büyük kısmı Asya kıtasındaki Anadolu'dur.$$,
    $$Adım 2: Trakya bölümü ise Avrupa kıtasındadır.$$,
    $$Adım 3: Bu nedenle Türkiye hem Asya hem Avrupa kıtası üzerinde yer alır. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Sosyal Bilgiler$$, $$Kültür ve Miras$$, $$Milli Bayramlar$$, 2,
  $$"19 Mayıs Atatürk'ü Anma, Gençlik ve Spor Bayramı" hangi kesime armağan edilmiştir?$$,
  jsonb_build_object('A', $$Çocuklara$$, 'B', $$Gençlere$$, 'C', $$Yaşlılara$$, 'D', $$Çiftçilere$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bayramın tam adının içinde, armağan edildiği kesimin adı geçiyor.$$,
    $$Adım 1: Bayramın adında "Gençlik ve Spor" ifadeleri geçer.$$,
    $$Adım 2: Atatürk 19 Mayıs'ı Türk gençliğine armağan etmiştir.$$,
    $$Adım 3: 23 Nisan çocuklara, 19 Mayıs ise gençlere armağan edilmiştir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Temel Dini Bilgiler$$, $$İbadet Yeri$$, 1,
  $$Müslümanların topluca ibadet ettikleri yere ne ad verilir?$$,
  jsonb_build_object('A', $$Kilise$$, 'B', $$Cami$$, 'C', $$Havra$$, 'D', $$Kütüphane$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Minaresi olan, ezanın okunduğu ibadet yerini düşün.$$,
    $$Adım 1: Kilise Hristiyanların, havra Yahudilerin ibadet yeridir.$$,
    $$Adım 2: Müslümanların ibadet ettiği, minareli yapıya cami denir.$$,
    $$Adım 3: Camilerde ezan okunur ve namaz topluca kılınır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Temel Dini Bilgiler$$, $$Kutsal Kitap$$, 1,
  $$Müslümanların kutsal kitabı aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Tevrat$$, 'B', $$İncil$$, 'C', $$Kur'an-ı Kerim$$, 'D', $$Zebur$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Camilerde okunan, Hz. Muhammed'e gönderilen kutsal kitabı hatırla.$$,
    $$Adım 1: Tevrat, Zebur ve İncil daha önceki peygamberlere gönderilmiş kutsal kitaplardır.$$,
    $$Adım 2: Müslümanların kutsal kitabı Kur'an-ı Kerim'dir.$$,
    $$Adım 3: Kur'an-ı Kerim, Hz. Muhammed'e vahyedilmiştir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Temel Dini Bilgiler$$, $$Peygamberimiz$$, 1,
  $$İslam dininin peygamberi aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Hz. Musa$$, 'B', $$Hz. İsa$$, 'C', $$Hz. Muhammed$$, 'D', $$Hz. İbrahim$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Kur'an-ı Kerim'in kendisine gönderildiği son peygamberi düşün.$$,
    $$Adım 1: Hz. Musa, Hz. İsa ve Hz. İbrahim daha önce yaşamış peygamberlerdir.$$,
    $$Adım 2: İslam dininin peygamberi ve son peygamber Hz. Muhammed'dir.$$,
    $$Adım 3: Kur'an-ı Kerim ona gönderilmiştir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Hz. Muhammed'in Hayatı$$, $$Doğum Yeri$$, 2,
  $$Hz. Muhammed hangi şehirde doğmuştur?$$,
  jsonb_build_object('A', $$Medine$$, 'B', $$Mekke$$, 'C', $$Kudüs$$, 'D', $$İstanbul$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kâbe'nin bulunduğu, Müslümanların hac için gittiği kutsal şehri düşün.$$,
    $$Adım 1: Hz. Muhammed, içinde Kâbe'nin bulunduğu Mekke şehrinde doğmuştur.$$,
    $$Adım 2: Daha sonra Mekke'den Medine'ye göç (hicret) etmiştir.$$,
    $$Adım 3: Doğduğu şehir Mekke'dir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$İbadetler$$, $$Namaz$$, 1,
  $$Müslümanlar bir günde kaç vakit namaz kılar?$$,
  jsonb_build_object('A', $$3$$, 'B', $$4$$, 'C', $$5$$, 'D', $$6$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Sabah, öğle, ikindi, akşam ve yatsı vakitlerini say.$$,
    $$Adım 1: Namaz vakitleri: sabah, öğle, ikindi, akşam ve yatsıdır.$$,
    $$Adım 2: Bunları saydığımızda toplam 5 vakit eder.$$,
    $$Adım 3: Günde 5 vakit namaz kılınır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$İbadetler$$, $$Oruç$$, 1,
  $$Müslümanların oruç tuttuğu kutsal ay aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Muharrem$$, 'B', $$Ramazan$$, 'C', $$Şaban$$, 'D', $$Recep$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sahur ve iftar sofralarının kurulduğu, bir ay boyunca oruç tutulan ayı düşün.$$,
    $$Adım 1: İslam'da oruç, belirli bir ay boyunca tutulur.$$,
    $$Adım 2: Bu ay Ramazan ayıdır.$$,
    $$Adım 3: Ramazan boyunca imsaktan iftara kadar oruç tutulur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Dua ve Dini İfadeler$$, $$Besmele$$, 2,
  $$Bir işe veya yemeğe başlarken söylediğimiz, "Allah'ın adıyla başlıyorum" anlamına gelen söz aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Elhamdülillah$$, 'B', $$Bismillah$$, 'C', $$İnşallah$$, 'D', $$Maşallah$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Yemeğe başlamadan önce büyüklerimizin söylediği, "besmele çekmek" denilen sözü hatırla.$$,
    $$Adım 1: Besmele, "Bismillahirrahmanirrahim" sözünün kısaltmasıdır.$$,
    $$Adım 2: Anlamı "Allah'ın adıyla başlarım" demektir.$$,
    $$Adım 3: Bir işe başlarken "Bismillah" denir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Dua ve Dini İfadeler$$, $$Şükür$$, 2,
  $$Bir nimete kavuştuğumuzda ya da bir iş sonunda Allah'a teşekkür etmek için söylediğimiz söz aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Bismillah$$, 'B', $$Elhamdülillah$$, 'C', $$Estağfurullah$$, 'D', $$Günaydın$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Yemeği bitirince ya da iyi bir haber alınca "şükürler olsun" anlamında söylenen sözü düşün.$$,
    $$Adım 1: "Bismillah" başlarken, "Estağfurullah" af dilerken söylenir.$$,
    $$Adım 2: Allah'a şükretmek, teşekkür etmek için "Elhamdülillah" denir.$$,
    $$Adım 3: Anlamı "Hamd (övgü) Allah'adır, şükürler olsun" demektir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Güzel Ahlak$$, $$İyi Davranışlar$$, 1,
  $$Aşağıdakilerden hangisi güzel (iyi) bir ahlaki davranıştır?$$,
  jsonb_build_object('A', $$Yalan söylemek$$, 'B', $$Büyüklere saygı göstermek$$, 'C', $$Arkadaşıyla kavga etmek$$, 'D', $$Başkasının hakkını yemek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Dinimizin ve toplumumuzun bizden beklediği, insanı sevdiren davranışı seç.$$,
    $$Adım 1: Yalan söylemek, kavga etmek ve hak yemek kötü (olumsuz) davranışlardır.$$,
    $$Adım 2: Büyüklere saygı göstermek güzel bir ahlaki davranıştır.$$,
    $$Adım 3: Güzel ahlak, insanı hem Allah katında hem toplumda değerli kılar. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Güzel Ahlak$$, $$Dürüstlük$$, 1,
  $$Hiç yalan söylemeden her zaman doğruyu söyleyen, sözünde duran kişiye ne denir?$$,
  jsonb_build_object('A', $$Cömert$$, 'B', $$Dürüst$$, 'C', $$Cimri$$, 'D', $$Bencil$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Doğru sözlü, güvenilir" anlamına gelen güzel huyu düşün.$$,
    $$Adım 1: Cömert paylaşan, cimri paylaşmayan, bencil yalnızca kendini düşünen kişidir.$$,
    $$Adım 2: Her zaman doğruyu söyleyen, sözünü tutan kişiye dürüst denir.$$,
    $$Adım 3: Dürüstlük, güzel ahlakın en önemli özelliklerindendir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Güzel Ahlak$$, $$Cömertlik$$, 2,
  $$Elindeki imkânları başkalarıyla isteyerek paylaşan, ihtiyaç sahiplerine yardım eden kişinin bu güzel özelliğine ne ad verilir?$$,
  jsonb_build_object('A', $$Cimrilik$$, 'B', $$Cömertlik$$, 'C', $$Bencillik$$, 'D', $$Kıskançlık$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Paylaşmayı seven, yardımsever kişilerin bu güzel huyunu düşün. Bu, cimriliğin tam tersidir.$$,
    $$Adım 1: Cimrilik, bencillik ve kıskançlık olumsuz huylardır.$$,
    $$Adım 2: Elindekini isteyerek paylaşan, yardım eden kişinin huyu cömertliktir.$$,
    $$Adım 3: Cömertlik dinimizin önem verdiği güzel bir davranıştır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Temizlik ve İbadet$$, $$Abdest$$, 2,
  $$Namaz kılmadan önce belli uzuvları (el, yüz, kol, ayak gibi) usulüne göre yıkayarak yapılan temizliğe ne ad verilir?$$,
  jsonb_build_object('A', $$Duş$$, 'B', $$Abdest$$, 'C', $$Tıraş$$, 'D', $$Çamaşır$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Namazdan önce yapılan, belirli bölgeleri yıkamayı içeren temizliği düşün.$$,
    $$Adım 1: Namaz ibadeti için temiz olmak gerekir.$$,
    $$Adım 2: Namaz öncesi el, yüz, kol ve ayakların usulünce yıkanmasına abdest denir.$$,
    $$Adım 3: Abdest hem bir temizlik hem de ibadete hazırlıktır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Dua ve İbadet$$, $$Dua$$, 1,
  $$Allah'tan bir şey istemek, O'na şükretmek veya yardım dilemek için yaptığımız içten yakarışa ne ad verilir?$$,
  jsonb_build_object('A', $$Dua$$, 'B', $$Selam$$, 'C', $$Şiir$$, 'D', $$Masal$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Ellerimizi açıp Allah'tan iyilik istediğimiz, içimizden geçenleri O'na söylediğimiz ibadeti düşün.$$,
    $$Adım 1: Selam karşılaşınca verilir, şiir ve masal ise edebi metinlerdir.$$,
    $$Adım 2: Allah'tan bir şey istemek, O'na yakarmak için yapılan içten dileğe dua denir.$$,
    $$Adım 3: Dua her zaman ve her yerde yapılabilir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Güzel Ahlak$$, $$Selamlaşma$$, 1,
  $$Müslümanlar birbirleriyle karşılaştıklarında hangi sözle selamlaşır?$$,
  jsonb_build_object('A', $$Günaydın$$, 'B', $$Selamün aleyküm$$, 'C', $$İyi günler$$, 'D', $$Hoşça kal$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İçinde "selam" ve "barış" anlamı bulunan, Müslümanlara özgü selamlaşma sözünü hatırla.$$,
    $$Adım 1: "Günaydın" ve "iyi günler" günlük selamlaşma sözleridir; "hoşça kal" ise ayrılırken söylenir.$$,
    $$Adım 2: Müslümanların selamı "Selamün aleyküm" (üzerinize selam olsun) sözüdür.$$,
    $$Adım 3: Karşıdaki kişi "Ve aleyküm selam" diyerek karşılık verir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Dini Bayramlar$$, $$Ramazan Bayramı$$, 2,
  $$Ramazan ayında tutulan oruçların ardından kutlanan dini bayram aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Kurban Bayramı$$, 'B', $$Ramazan Bayramı$$, 'C', $$Cumhuriyet Bayramı$$, 'D', $$23 Nisan Bayramı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir ay boyunca oruç tutulduktan sonra kutlanan, adını o aydan alan bayramı düşün.$$,
    $$Adım 1: Cumhuriyet Bayramı ve 23 Nisan dini değil, milli bayramlardır.$$,
    $$Adım 2: Ramazan ayındaki oruçların sonunda kutlanan bayram Ramazan Bayramı'dır.$$,
    $$Adım 3: Bu bayram 3 gün sürer ve "Şeker Bayramı" olarak da anılır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Hz. Muhammed'in Hayatı$$, $$El-Emin Lakabı$$, 3,
  $$Hz. Muhammed'e, peygamberlikten önce bile doğruluğu ve güvenilirliği sebebiyle çevresindekiler tarafından verilen lakap (unvan) aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$El-Emin (güvenilir)$$, 'B', $$Sultan$$, 'C', $$Halife$$, 'D', $$Fatih$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Bu lakap, "kendisine her konuda güvenilen kişi" anlamına gelir ve onun dürüstlüğünü anlatır.$$,
    $$Adım 1: Sultan ve halife devlet yöneticilerine verilen unvanlardır; "Fatih" ise fetheden demektir.$$,
    $$Adım 2: Hz. Muhammed, doğruluğu ve güvenilirliği nedeniyle "El-Emin" (güvenilir kişi) olarak anılmıştır.$$,
    $$Adım 3: İnsanlar değerli eşyalarını bile ona emanet ederdi. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Güzel Ahlak$$, $$Büyüklere Saygı$$, 1,
  $$Aşağıdakilerden hangisi büyüklerimize karşı göstermemiz gereken doğru bir davranıştır?$$,
  jsonb_build_object('A', $$Sözlerini dinlememek$$, 'B', $$Saygı gösterip sözlerini dinlemek$$, 'C', $$Onlarla alay etmek$$, 'D', $$Kaba sözler söylemek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Anne, baba, dede, nine ve öğretmenlerimize nasıl davranmamız gerektiğini düşün.$$,
    $$Adım 1: Sözlerini dinlememek, alay etmek ve kaba konuşmak saygısızlıktır.$$,
    $$Adım 2: Büyüklerimize saygı gösterip sözlerini dinlemek güzel bir davranıştır.$$,
    $$Adım 3: Büyüklere saygı, dinimizin ve kültürümüzün önemli bir değeridir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Temel Dini Bilgiler$$, $$Yaratan İnancı$$, 1,
  $$İslam inancına göre evreni, dünyayı ve tüm canlıları yaratan kimdir?$$,
  jsonb_build_object('A', $$İnsanlar$$, 'B', $$Allah$$, 'C', $$Melekler$$, 'D', $$Doğa$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Gökyüzünü, denizleri, hayvanları ve insanı var eden yüce varlığı düşün.$$,
    $$Adım 1: İnsanlar ve melekler de birer yaratılmış varlıktır; doğa kendi kendine var olmamıştır.$$,
    $$Adım 2: İslam inancına göre her şeyi yoktan var eden Allah'tır.$$,
    $$Adım 3: Allah evrenin ve tüm canlıların yaratıcısıdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Ahlaki Değerler$$, $$İsraftan Kaçınma$$, 2,
  $$Aşağıdaki davranışlardan hangisi israftır (gereksiz yere harcama)?$$,
  jsonb_build_object('A', $$Dişimizi fırçalarken suyu açık bırakmak$$, 'B', $$Ekmeğimizi yiyeceğimiz kadar almak$$, 'C', $$Odadan çıkarken ışığı kapatmak$$, 'D', $$Kullanmadığımız cihazı fişten çekmek$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: İsraf, bir şeyi gereğinden fazla ve boş yere harcamaktır. Hangi seçenekte kaynak boşa gidiyor?$$,
    $$Adım 1: Ekmeği gereği kadar almak, ışığı kapatmak ve cihazı fişten çekmek tasarruflu davranışlardır.$$,
    $$Adım 2: Dişimizi fırçalarken suyu açık bırakmak, temiz suyun boşa akmasına yol açar.$$,
    $$Adım 3: Gereksiz yere kaynak harcamak israftır; dinimiz israfı hoş görmez. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$Din Kültürü ve Ahlak Bilgisi$$, $$Güzel Ahlak$$, $$Yardımlaşma ve Dayanışma$$, 2,
  $$"Komşusu açken tok yatan bizden değildir." sözü bize aşağıdakilerden hangisini öğütler?$$,
  jsonb_build_object('A', $$Yalnızca kendimizi düşünmemizi$$, 'B', $$İhtiyaç sahiplerine yardım edip paylaşmamızı$$, 'C', $$Çok yemek yememizi$$, 'D', $$Erken yatmamızı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sözde "komşusu açken" deniyor. Bize komşumuzun, çevremizdekilerin ihtiyacını görmemizi hatırlatıyor.$$,
    $$Adım 1: Bu söz, çevremizdeki ihtiyaç sahiplerine duyarsız kalmamamızı anlatır.$$,
    $$Adım 2: Komşusu aç olanın onu görüp yardım etmesi beklenir.$$,
    $$Adım 3: Yani söz, yardımlaşma ve paylaşmayı öğütler. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Greetings$$, $$Hâl Hatır Sorma$$, 1,
  $$"- Hello! How are you? - ______, thank you." Boşluğa gelmesi gereken en uygun ifade hangisidir?$$,
  jsonb_build_object('A', $$Good morning$$, 'B', $$I'm fine$$, 'C', $$Goodbye$$, 'D', $$Yes, please$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "How are you?" (Nasılsın?) sorusuna hâlimizi anlatan bir cevap verilir.$$,
    $$Adım 1: "How are you?" = "Nasılsın?" demektir.$$,
    $$Adım 2: Bu soruya "I'm fine" (İyiyim) diye hâlimizi söyleyerek cevap veririz.$$,
    $$Adım 3: "Good morning" selam, "Goodbye" vedadır; soruya uygun cevap "I'm fine" dır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Colors$$, $$Renkler$$, 1,
  $$Which one is a **color**? (Hangisi bir renktir?)$$,
  jsonb_build_object('A', $$Apple$$, 'B', $$Blue$$, 'C', $$Dog$$, 'D', $$Table$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Renk sözcüklerini düşün: red, blue, green, yellow...$$,
    $$Adım 1: Apple = elma, Dog = köpek, Table = masa anlamındadır.$$,
    $$Adım 2: Blue = mavi demektir ve bir renktir.$$,
    $$Adım 3: Bu nedenle renk olan sözcük "Blue" dur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Animals$$, $$Sözcük Anlamı$$, 1,
  $$"Cat" sözcüğünün Türkçe anlamı aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$Köpek$$, 'B', $$Kedi$$, 'C', $$Kuş$$, 'D', $$Balık$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Miyav" diyen, evlerde beslenen küçük hayvanı düşün.$$,
    $$Adım 1: Dog = köpek, Bird = kuş, Fish = balık demektir.$$,
    $$Adım 2: "Cat" sözcüğü Türkçede kedi anlamına gelir.$$,
    $$Adım 3: Bu nedenle doğru anlam "Kedi" dir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Numbers$$, $$Sayılar$$, 1,
  $$Which number is "**seven**"? ("seven" hangi sayıdır?)$$,
  jsonb_build_object('A', $$5$$, 'B', $$6$$, 'C', $$7$$, 'D', $$8$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: one, two, three, four, five, six, seven... diye sayarak ilerle.$$,
    $$Adım 1: İngilizce sayılar: five = 5, six = 6, seven = 7, eight = 8.$$,
    $$Adım 2: "Seven" sözcüğü 7 sayısına karşılık gelir.$$,
    $$Adım 3: Bu nedenle doğru sayı 7'dir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Days$$, $$Günler$$, 2,
  $$Which day comes **after** "Monday"? ("Monday" gününden sonra hangi gün gelir?)$$,
  jsonb_build_object('A', $$Sunday$$, 'B', $$Tuesday$$, 'C', $$Friday$$, 'D', $$Saturday$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Monday = Pazartesi. Haftanın günlerini sırayla say: Monday, Tuesday, Wednesday...$$,
    $$Adım 1: Monday = Pazartesi demektir.$$,
    $$Adım 2: Pazartesiden sonra gelen gün Salı, yani "Tuesday" dır.$$,
    $$Adım 3: Sunday = Pazar, Friday = Cuma, Saturday = Cumartesidir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Weather$$, $$Hava Durumu$$, 2,
  $$"It is raining. We need an ______." (Yağmur yağıyor. Bize bir ______ gerek.)$$,
  jsonb_build_object('A', $$umbrella$$, 'B', $$ice cream$$, 'C', $$book$$, 'D', $$ball$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Yağmurda ıslanmamak için neye ihtiyacımız olur?$$,
    $$Adım 1: "It is raining" = "Yağmur yağıyor" demektir.$$,
    $$Adım 2: Yağmurda ıslanmamak için şemsiye gerekir; şemsiye İngilizcede "umbrella" dır.$$,
    $$Adım 3: Diğer seçenekler (dondurma, kitap, top) yağmurla ilgili değildir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Fruits$$, $$Sözcük Grubu$$, 1,
  $$"Apple, banana, orange" sözcükleri hangi gruba aittir?$$,
  jsonb_build_object('A', $$Animals$$, 'B', $$Colors$$, 'C', $$Fruits$$, 'D', $$Jobs$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Apple = elma, banana = muz, orange = portakal. Bunlar ne tür yiyeceklerdir?$$,
    $$Adım 1: Apple (elma), banana (muz), orange (portakal) birer yiyecektir.$$,
    $$Adım 2: Bunların hepsi meyvedir; İngilizce meyve "fruits" tır.$$,
    $$Adım 3: Animals = hayvanlar, Colors = renkler, Jobs = meslekler olduğundan grup "Fruits" tır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Nationality$$, $$Milliyet$$, 2,
  $$"I am from Turkey. I am ______." (Türkiye'denim. Ben ______.)$$,
  jsonb_build_object('A', $$English$$, 'B', $$Turkish$$, 'C', $$German$$, 'D', $$French$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Türkiye'den olan birinin milliyeti nedir? Ülke "Turkey", milliyeti ise ...$$,
    $$Adım 1: "I am from Turkey" = "Türkiye'denim" demektir.$$,
    $$Adım 2: Türkiye'den olan kişinin milliyeti "Turkish" (Türk) tür.$$,
    $$Adım 3: English = İngiliz, German = Alman, French = Fransız demektir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Feelings$$, $$Duygular$$, 2,
  $$"The boy is laughing. He is ______." (Çocuk gülüyor. O ______.)$$,
  jsonb_build_object('A', $$sad$$, 'B', $$angry$$, 'C', $$happy$$, 'D', $$tired$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Gülen bir kişi kendini nasıl hisseder? Mutlu mu, üzgün mü?$$,
    $$Adım 1: "Laughing" = "gülüyor" demektir.$$,
    $$Adım 2: Gülen bir çocuk mutludur; mutlu İngilizcede "happy" dir.$$,
    $$Adım 3: sad = üzgün, angry = kızgın, tired = yorgun olduğundan doğru duygu "happy" dir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Classroom Rules$$, $$Sınıf İçi Yönergeler$$, 2,
  $$Teacher says: "______ the door, please." (Öğretmen "Lütfen kapıyı kapat." diyor.) Boşluğa hangi sözcük gelmelidir?$$,
  jsonb_build_object('A', $$Open$$, 'B', $$Close$$, 'C', $$Stand up$$, 'D', $$Sit down$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Kapat" anlamına gelen İngilizce komutu düşün. "Open" tam tersidir.$$,
    $$Adım 1: Cümlenin Türkçesi "Lütfen kapıyı kapat." tır.$$,
    $$Adım 2: "Kapat" İngilizcede "Close" demektir.$$,
    $$Adım 3: Open = aç, Stand up = ayağa kalk, Sit down = otur olduğundan doğru komut "Close" dur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Food (Likes & Dislikes)$$, $$Hoşlanma$$, 2,
  $$"I ______ chocolate. It is yummy!" (Çikolatayı ______. Çok lezzetli!)$$,
  jsonb_build_object('A', $$like$$, 'B', $$don't like$$, 'C', $$hate$$, 'D', $$am$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "It is yummy!" (Çok lezzetli!) demek, konuşanın çikolatayı sevdiğini gösterir.$$,
    $$Adım 1: "Yummy" = "lezzetli, nefis" demektir; bu olumlu bir ifadedir.$$,
    $$Adım 2: Bir şeyi lezzetli bulan kişi onu sever; "severim" İngilizcede "I like" tır.$$,
    $$Adım 3: "don't like" ve "hate" sevmemek/nefret anlamı taşıdığından uygun değildir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Jobs$$, $$Meslekler$$, 2,
  $$"A ______ works in a hospital and helps sick people." (Bir ______ hastanede çalışır ve hasta insanlara yardım eder.)$$,
  jsonb_build_object('A', $$teacher$$, 'B', $$doctor$$, 'C', $$driver$$, 'D', $$cook$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Hastanede çalışıp hastaları iyileştiren meslek sahibini düşün.$$,
    $$Adım 1: Cümle "hastanede çalışır ve hastalara yardım eder" diyor.$$,
    $$Adım 2: Bu kişi doktordur; doktor İngilizcede "doctor" dır.$$,
    $$Adım 3: teacher = öğretmen, driver = şoför, cook = aşçı olduğundan doğru meslek "doctor" dır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Grammar$$, $$Plurals (Çoğul)$$, 2,
  $$"One book, two ______." (Bir kitap, iki ______.)$$,
  jsonb_build_object('A', $$book$$, 'B', $$books$$, 'C', $$bookes$$, 'D', $$book's$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İngilizcede bir sözcüğü çoğul yapmak için genellikle sonuna "-s" eklenir.$$,
    $$Adım 1: "Book" = kitap, tekildir. İki kitaptan söz edildiği için çoğul gerekir.$$,
    $$Adım 2: İngilizcede çoğul genellikle sözcüğün sonuna "-s" eklenerek yapılır: book → books.$$,
    $$Adım 3: "bookes" yanlış yazım, "book's" ise iyelik ekidir. Doğru çoğul "books" tır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Colors$$, $$Nesne-Renk Eşleştirme$$, 1,
  $$"The sky is ______." (Gökyüzü ______.)$$,
  jsonb_build_object('A', $$blue$$, 'B', $$pizza$$, 'C', $$run$$, 'D', $$happy$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Açık bir günde gökyüzü hangi renktedir?$$,
    $$Adım 1: Cümlede gökyüzünün rengi sorulmaktadır.$$,
    $$Adım 2: Gökyüzü mavidir; mavi İngilizcede "blue" dur.$$,
    $$Adım 3: pizza bir yiyecek, run bir eylem, happy bir duygudur; renk olan "blue" dur. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Animals$$, $$Sözcük Ayırt Etme$$, 1,
  $$Which one is an **animal**? (Hangisi bir hayvandır?)$$,
  jsonb_build_object('A', $$Car$$, 'B', $$Elephant$$, 'C', $$Red$$, 'D', $$Seven$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Hayvan adlarını düşün: cat, dog, elephant, lion...$$,
    $$Adım 1: Car = araba, Red = kırmızı, Seven = yedi demektir.$$,
    $$Adım 2: Elephant = fil demektir ve bir hayvandır.$$,
    $$Adım 3: Bu nedenle hayvan olan sözcük "Elephant" tır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Greetings$$, $$Vedalaşma$$, 2,
  $$"Goodbye" sözcüğü hangi durumda kullanılır?$$,
  jsonb_build_object('A', $$Biriyle yeni tanışırken$$, 'B', $$Vedalaşırken (ayrılırken)$$, 'C', $$Teşekkür ederken$$, 'D', $$Özür dilerken$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir yerden ayrılırken, "hoşça kal" anlamında söylenen sözü düşün.$$,
    $$Adım 1: Tanışırken "Nice to meet you", teşekkürde "Thank you" kullanılır.$$,
    $$Adım 2: "Goodbye" = "Hoşça kal / Güle güle" demektir ve ayrılırken söylenir.$$,
    $$Adım 3: Bu nedenle "Goodbye" vedalaşırken kullanılır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Family$$, $$Aile Bireyleri$$, 2,
  $$"My mother and father are my ______." (Annem ve babam benim ______.)$$,
  jsonb_build_object('A', $$friends$$, 'B', $$parents$$, 'C', $$teachers$$, 'D', $$pets$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Anne ve babayı birlikte anlatan tek sözcüğü düşün.$$,
    $$Adım 1: Mother = anne, father = baba demektir.$$,
    $$Adım 2: Anne ve babaya birlikte "parents" (ebeveyn) denir.$$,
    $$Adım 3: friends = arkadaşlar, teachers = öğretmenler, pets = evcil hayvanlar olduğundan doğru sözcük "parents" tır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$About Me$$, $$Yaş Söyleme$$, 2,
  $$"How old are you? - I am ten years ______." (Kaç yaşındasın? - Ben on yaşında______.)$$,
  jsonb_build_object('A', $$old$$, 'B', $$new$$, 'C', $$tall$$, 'D', $$big$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Yaş söylerken kullanılan kalıp "... years old" şeklindedir.$$,
    $$Adım 1: "How old are you?" = "Kaç yaşındasın?" demektir.$$,
    $$Adım 2: Yaş söylerken "I am ... years old" kalıbı kullanılır.$$,
    $$Adım 3: Bu nedenle boşluğa "old" gelir: "I am ten years old." Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Hobbies / Abilities$$, $$Yapabilme (can)$$, 2,
  $$"I can ______ a bike." (Bisiklet ______.)$$,
  jsonb_build_object('A', $$eat$$, 'B', $$ride$$, 'C', $$read$$, 'D', $$sing$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bisikletle yapılan eylemi düşün: onu yeriz mi, okuruz mu, yoksa süreriz mi?$$,
    $$Adım 1: eat = yemek, read = okumak, sing = şarkı söylemek demektir.$$,
    $$Adım 2: Bisiklet için kullanılan eylem "ride" (binmek/sürmek) tır.$$,
    $$Adım 3: "I can ride a bike" = "Bisiklet sürebilirim" olur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 5, $$İngilizce$$, $$Clothes$$, $$Mevsime Göre Giysi$$, 2,
  $$"In winter, I wear a ______ to keep warm." (Kışın sıcak tutması için bir ______ giyerim.)$$,
  jsonb_build_object('A', $$swimsuit$$, 'B', $$coat$$, 'C', $$shorts$$, 'D', $$sandals$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kışın soğukta bizi sıcak tutan kalın giysiyi düşün. Mayo ve şort yazlıktır.$$,
    $$Adım 1: "In winter" = "kışın", "to keep warm" = "sıcak tutması için" demektir.$$,
    $$Adım 2: Kışın sıcak tutan kalın giysi "coat" (mont/palto) tur.$$,
    $$Adım 3: swimsuit = mayo, shorts = şort, sandals = sandalet olup bunlar yazlıktır. Doğru cevap B seçeneğidir.$$
  ]::text[])
)
;

insert into public.questions
  (okul, sinif, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu, cozum_adimlari)
select v.okul, v.sinif, v.ders, v.konu, v.alt_konu, v.zorluk, v.soru_metni, v.siklar, v.dogru_sik,
       'onaylandi', v.cozum_adimlari
  from _soru_bankasi_5_ders v
 where not exists (
   select 1 from public.questions q where q.ders = v.ders and q.soru_metni = v.soru_metni
 );

update public.questions q
   set onay_durumu = 'onaylandi'
  from _soru_bankasi_5_ders v
 where q.ders = v.ders
   and q.soru_metni = v.soru_metni
   and q.onay_durumu = 'beklemede';

-- Matematik seed (20261003000001): 50 soru, yalnızca 'beklemede' olanlar onaylanır.
update public.questions
   set onay_durumu = 'onaylandi'
 where ders = 'Matematik'
   and onay_durumu = 'beklemede'
   and created_by is null
   and cozum_adimlari ->> 0 like 'İpucu:%';
