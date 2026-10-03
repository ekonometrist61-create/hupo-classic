-- =====================================================================
--  SORU BANKASI: Matematik Bölüm 1 — 50 örnek soru (MAT-001 … MAT-050)
--  Proje   : ccozfrpnvyrnktpffkwo — Öğrenci Hazırlık / Hupo
--  Tarih   : 2026-10-03
--  Kaynak  : soru-bankasi/matematik-bolum-1.md
--
--  UYARI: Bu maddeler 4-5. sınıf kazanımlarına göre hazırlanmış ÖRNEK
--  sorulardır. Kaynak, sınav yılı ve okul adı doğrulanmamıştır.
--  Tüm kayıtlar onay_durumu = 'beklemede' olarak eklenmektedir.
--  Kullanılmadan önce admin panelinden incelenip onaylanmalıdır.
--
--  Kolon başvurusu (bu migration çalışırken var olması gereken şema):
--    public.questions: okul, sinif, ders, konu, alt_konu, zorluk,
--                      soru_metni, siklar, dogru_sik, onay_durumu,
--                      cozum_adimlari, inceleme_gerekli
--  Tüm bu kolonlar 20260920000000 + 20260920000400 + 20260927000040
--  migration'larından sonra mevcuttur.
-- =====================================================================

set client_encoding = 'UTF8';

insert into public.questions
  (okul, sinif, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu, cozum_adimlari)
values

-- ── MAT-001 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Basamak ve Bölük Kavramı$$,
  1,
  $$"704 250" doğal sayısının binler bölüğündeki rakamların basamak değerleri toplamı kaçtır?$$,
  jsonb_build_object('A', $$704$$, 'B', $$704 000$$, 'C', $$250$$, 'D', $$700 000$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Bir sayının bölüklerini hatırla: en sağdaki üç basamak birler bölüğü, solundaki grup ise binler bölüğüdür. Basamak değerini bulurken rakamı bulunduğu basamağın değeriyle (1 000, 10 000, 100 000) çarpmalısın.$$,
    $$Adım 1: 704 250 sayısını bölüklerine ayıralım: Binler bölüğü = 704, Birler bölüğü = 250.$$,
    $$Adım 2: Binler bölüğündeki rakamlar 7, 0 ve 4'tür. Basamak değerleri: 7 × 100 000 = 700 000; 0 × 10 000 = 0; 4 × 1 000 = 4 000.$$,
    $$Adım 3: Basamak değerleri toplamı: 700 000 + 4 000 = 704 000. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-002 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Sayıların Okunuşu ve Yazılışı$$,
  1,
  $$Okunuşu "Sekiz yüz beş bin kırk iki" olan doğal sayı aşağıdakilerden hangisidir?$$,
  jsonb_build_object('A', $$850 042$$, 'B', $$805 420$$, 'C', $$805 042$$, 'D', $$85 042$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: "Bin" kelimesini gördüğün yere kadar olan kısım binler bölüğüdür. "Sekiz yüz beş" → 805. Kalan kısım ise 3 basamaklı birler bölüğünü oluşturmalıdır: "kırk iki" üç basamaklı olarak nasıl yazılır?$$,
    $$Adım 1: Binler bölüğü "Sekiz yüz beş" yani 805'tir.$$,
    $$Adım 2: Birler bölüğü 3 basamaklı olmalıdır. "Kırk iki" sayısı yüzler basamağı sıfır konularak "042" şeklinde yazılır.$$,
    $$Adım 3: Bölükleri birleştirdiğimizde sayımız 805 042 olur. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-003 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Basamak Değeri Farkı$$,
  2,
  $$"536 348" doğal sayısındaki "3" rakamlarının basamak değerleri arasındaki fark kaçtır?$$,
  jsonb_build_object('A', $$29 700$$, 'B', $$27 000$$, 'C', $$30 300$$, 'D', $$29 970$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Sayıdaki her iki 3 rakamının hangi basamaklarda olduğuna bak. Biri on binler basamağında, diğeri yüzler basamağındadır. Basamak değerlerini bulup birbirinden çıkar.$$,
    $$Adım 1: İlk 3 rakamı on binler basamağındadır: 3 × 10 000 = 30 000.$$,
    $$Adım 2: İkinci 3 rakamı yüzler basamağındadır: 3 × 100 = 300.$$,
    $$Adım 3: Fark: 30 000 − 300 = 29 700. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-004 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Rakamları Farklı En Büyük / En Küçük Sayı$$,
  2,
  $$0, 3, 5, 8, 9 rakamları birer kez kullanılarak yazılabilecek beş basamaklı en küçük tek doğal sayı kaçtır?$$,
  jsonb_build_object('A', $$30 589$$, 'B', $$30 859$$, 'C', $$30 895$$, 'D', $$35 089$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Sayının en küçük olması için sol başa 0 gelemeyeceğinden en küçük rakam olan 3 gelmeli. Tek sayı olması için birler basamağına tek bir rakam (5 ya da 9) kalmalı; büyük rakamları sona doğru yerleştirmelisin.$$,
    $$Adım 1: Beş basamaklı en küçük sayı için başa 0 gelemeyeceğinden 3 ile başlarız: 3 _ _ _ _.$$,
    $$Adım 2: İkinci basamağa en küçük rakam olan 0 konur: 3 0 _ _ _.$$,
    $$Adım 3: Kalan rakamlar 5, 8, 9'dur. Sayının küçük olması için yüzler basamağına 5, onlar basamağına 8, birler basamağına 9 konur (birler basamağı 9 → sayı tektir).$$,
    $$Adım 4: Elde edilen sayı 30 589'dur. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-005 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$En Yakın Yüzlüğe Yuvarlama$$,
  2,
  $$En yakın yüzlüğe yuvarlandığında 4 700 olan en büyük doğal sayı ile en küçük doğal sayının toplamı kaçtır?$$,
  jsonb_build_object('A', $$9 400$$, 'B', $$9 399$$, 'C', $$9 401$$, 'D', $$9 499$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: En yakın yüzlüğe yuvarlarken onlar ve birler basamağına bakarız. 50 ve üzeri → bir üst yüzlüğe, 49 ve altı → kendi yüzlüğüne yuvarlanır. En küçük sayı 4 650, en büyük sayı 4 749'dur.$$,
    $$Adım 1: 4 700'e yuvarlanan en küçük doğal sayı onlar basamağı 5 olan 4 650'dir.$$,
    $$Adım 2: 4 700'e yuvarlanan en büyük doğal sayı onlar basamağı 4 olan 4 749'dur.$$,
    $$Adım 3: Toplam: 4 650 + 4 749 = 9 399. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-006 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Sayı Örüntüleri$$,
  2,
  $$7, 13, 19, 25, A, 37, B ... kuralı verilen sayı örüntüsünde (B − A) farkı kaçtır?$$,
  jsonb_build_object('A', $$6$$, 'B', $$12$$, 'C', $$18$$, 'D', $$24$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Örüntünün artış miktarını bulmak için ardışık terimler arasındaki farka bak (13 − 7 = ?). A ve B harflerine denk gelen sayıları bu kurala göre hesapla.$$,
    $$Adım 1: 13 − 7 = 6, 19 − 13 = 6... Örüntü 6'şar artmaktadır.$$,
    $$Adım 2: 25'ten sonraki sayı A = 25 + 6 = 31.$$,
    $$Adım 3: 37'den sonraki sayı B = 37 + 6 = 43.$$,
    $$Adım 4: B − A = 43 − 31 = 12. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-007 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Doğal Sayıları Çözümleme$$,
  1,
  $$(4 × 100 000) + (6 × 1 000) + (2 × 100) + (5 × 1) şeklinde çözümlenmiş olan doğal sayı kaçtır?$$,
  jsonb_build_object('A', $$460 205$$, 'B', $$406 250$$, 'C', $$406 205$$, 'D', $$462 005$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Çözümlemede verilmeyen basamakların (on binler ve onlar basamağı) yerine "0" yazmayı unutma!$$,
    $$Adım 1: Yüz binler = 4, On binler = 0 (verilmedi), Binler = 6, Yüzler = 2, Onlar = 0 (verilmedi), Birler = 5.$$,
    $$Adım 2: Sayı: 406 205. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-008 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$Toplama İşleminde Verilmeyen Rakamı Bulma$$,
  2,
  $$  A 4 7 8
+ 3 B 2 5
----------
  8 1 0 3
Yukarıdaki toplama işlemine göre (A + B) toplamı kaçtır?$$,
  jsonb_build_object('A', $$10$$, 'B', $$11$$, 'C', $$12$$, 'D', $$13$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Birler basamağından başlayarak eldeleri takip et. 8 + 5 = 13 (elde 1 var). 7 + 2 + 1 = 10 (yine elde 1 var). Yüzler basamağında 4 + B + 1 işleminin sonucunun son basamağı 1 olmalı.$$,
    $$Adım 1: Birler: 8 + 5 = 13 → 3 yazılır, elde 1.$$,
    $$Adım 2: Onlar: 7 + 2 + 1 = 10 → 0 yazılır, elde 1.$$,
    $$Adım 3: Yüzler: 4 + B + 1 = 11 olmalı → B = 6.$$,
    $$Adım 4: Binler: A + 3 + 1 = 8 → A = 4.$$,
    $$Adım 5: A + B = 4 + 6 = 10. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-009 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$Çıkarma İşleminde Terimler Arası İlişki$$,
  2,
  $$Bir çıkarma işleminde eksilen, çıkan ve farkın toplamı 4 860'tır. Buna göre eksilen sayı kaçtır?$$,
  jsonb_build_object('A', $$1 620$$, 'B', $$2 430$$, 'C', $$3 240$$, 'D', $$2 400$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Çıkarma işleminin temel kuralını hatırla: Eksilen = Çıkan + Fark. O halde (Çıkan + Fark) yerine "Eksilen" yazabilirsin!$$,
    $$Adım 1: Kural: Eksilen = Çıkan + Fark.$$,
    $$Adım 2: Eksilen + Çıkan + Fark = 4 860.$$,
    $$Adım 3: (Çıkan + Fark) da Eksilen'e eşit olduğundan: Eksilen + Eksilen = 4 860.$$,
    $$Adım 4: 2 × Eksilen = 4 860 → Eksilen = 2 430. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-010 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$Çarpma İşleminde Verilmeyen Rakamlar$$,
  3,
  $$Üç basamaklı bir doğal sayı ile 24 çarpılırken ikinci çarpım bir basamak sola kaydırılmadan doğrudan alt alta yazılmış ve sonuç 846 bulunmuştur. İşlemin doğru sonucu kaçtır?$$,
  jsonb_build_object('A', $$3 384$$, 'B', $$3 154$$, 'C', $$2 820$$, 'D', $$3 564$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: İkinci satır sola kaydırılmadığında sayı 20 ile değil sadece 2 ile çarpılmış olur. Yani toplamda sayı (4 + 2 = 6) ile çarpılmıştır. 846'yı 6'ya bölerek asıl sayıyı bul!$$,
    $$Adım 1: Normalde 24 ile çarparken 1. satır (sayı × 4), 2. satır sola kaydırılarak (sayı × 20) toplanır.$$,
    $$Adım 2: Hatalı işlemde sola kaydırılmadığı için: (sayı × 4) + (sayı × 2) = sayı × 6 = 846.$$,
    $$Adım 3: Çarpılan sayı = 846 ÷ 6 = 141.$$,
    $$Adım 4: Doğru sonuç: 141 × 24 = 3 384. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-011 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$Kalanlı Bölme İşlemi Özellikleri$$,
  2,
  $$Bir bölme işleminde bölen 18, bölüm 25 olduğuna göre bölünen sayı EN FAZLA kaç olabilir?$$,
  jsonb_build_object('A', $$450$$, 'B', $$467$$, 'C', $$468$$, 'D', $$475$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Bir bölme işleminde kalan sayı daima bölenden küçük olmalıdır (Kalan < Bölen). Kalanın alabileceği en büyük değeri bulup Bölünen = (Bölen × Bölüm) + Kalan formülünü uygula.$$,
    $$Adım 1: Bölünen = (Bölen × Bölüm) + Kalan.$$,
    $$Adım 2: Bölen = 18 → kalanın alabileceği en büyük değer 17'dir.$$,
    $$Adım 3: Bölünen en fazla = (18 × 25) + 17 = 450 + 17 = 467. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-012 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$Zihinden Çarpma ve Bölme$$,
  1,
  $$Bir sayıyı 50 ile kısa yoldan çarpmak isteyen Zeynep, aşağıdaki işlemlerden hangisini yapmalıdır?$$,
  jsonb_build_object(
    'A', $$Sayıyı 100 ile çarpıp 2'ye bölmelidir.$$,
    'B', $$Sayıyı 10 ile çarpıp 5'e bölmelidir.$$,
    'C', $$Sayıyı 2 ile çarpıp 100'e bölmelidir.$$,
    'D', $$Sayının yanına iki sıfır eklemelidir.$$
  ),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: 50 sayısı 100'ün yarısıdır (100 ÷ 2 = 50). Bu eşitliği işlem pratiğinde nasıl kullanırsın?$$,
    $$Adım 1: 50 = 100 ÷ 2 olduğundan, bir sayıyı 50 ile çarpmak: o sayıyı 100 ile çarpıp 2'ye bölmek demektir.$$,
    $$Adım 2: Örnek: 14 × 50 = (14 × 100) ÷ 2 = 1 400 ÷ 2 = 700. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-013 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Kat Problemleri$$,
  2,
  $$Bir çiftlikteki koyun ve tavukların toplam sayısı 72'dir. Tavukların sayısı koyunların sayısının 3 katı olduğuna göre bu çiftlikteki toplam ayak sayısı kaçtır?$$,
  jsonb_build_object('A', $$180$$, 'B', $$196$$, 'C', $$216$$, 'D', $$252$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Koyunlara 1 kat dersen tavuklar 3 kat olur → toplam 4 kat = 72. Koyun ve tavuk sayılarını bulduktan sonra koyunun 4, tavuğun 2 ayağı olduğunu hatırla!$$,
    $$Adım 1: Koyun = 1 kat, Tavuk = 3 kat → toplam = 4 kat = 72.$$,
    $$Adım 2: Koyun = 72 ÷ 4 = 18; Tavuk = 18 × 3 = 54.$$,
    $$Adım 3: Koyun ayakları = 18 × 4 = 72; Tavuk ayakları = 54 × 2 = 108.$$,
    $$Adım 4: Toplam ayak = 72 + 108 = 180. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-014 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Sıra ve Adım Problemleri$$,
  3,
  $$Bir bilet kuyruğunda Ahmet baştan 17. sırada, Mehmet ise sondan 23. sıradadır. Ahmet ile Mehmet arasında 5 kişi olduğuna ve Ahmet gişeye daha yakın olduğuna göre bu kuyrukta toplam kaç kişi vardır?$$,
  jsonb_build_object('A', $$43$$, 'B', $$44$$, 'C', $$45$$, 'D', $$35$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Ahmet gişeye daha yakınsa kuyruğun ön tarafındadır. Gişeden itibaren: Ahmet'e kadar 17 kişi, arada 5 kişi, sonra Mehmet ve Mehmet'in arkasında 22 kişi vardır.$$,
    $$Adım 1: Ahmet dahil ön grupta 17 kişi vardır.$$,
    $$Adım 2: Ahmet ile Mehmet arasında 5 kişi bulunmaktadır.$$,
    $$Adım 3: Mehmet sondan 23. sırada → Mehmet ve arkasındakiler toplam 23 kişidir.$$,
    $$Adım 4: 17 + 5 + 23 = 45 kişi. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-015 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$İşlem Önceliği ve Parantezli İşlemler$$,
  2,
  $$120 − 24 ÷ 6 + 4 × 5 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$36$$, 'B', $$100$$, 'C', $$136$$, 'D', $$144$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: İşlem önceliği kuralını hatırla: Önce çarpma ve bölme (soldan sağa), ardından toplama ve çıkarma yapılır.$$,
    $$Adım 1: 24 ÷ 6 = 4.$$,
    $$Adım 2: 4 × 5 = 20.$$,
    $$Adım 3: İfade: 120 − 4 + 20.$$,
    $$Adım 4: 120 − 4 = 116; 116 + 20 = 136. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-016 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Basamak Değeri ile Sayı Değeri Farkı$$,
  1,
  $$"947 165" sayısındaki "4" rakamının basamak değeri ile sayı değeri arasındaki fark kaçtır?$$,
  jsonb_build_object('A', $$39 996$$, 'B', $$39 960$$, 'C', $$40 004$$, 'D', $$36 000$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Sayı değeri rakamın kendi değeridir (4). Basamak değeri ise on binler basamağındaki değeridir (4 × 10 000 = 40 000).$$,
    $$Adım 1: "4" rakamı on binler basamağında → basamak değeri = 40 000.$$,
    $$Adım 2: Sayı değeri = 4.$$,
    $$Adım 3: Fark = 40 000 − 4 = 39 996. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-017 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Yaş Problemleri$$,
  2,
  $$Bir annenin yaşı, iki çocuğunun yaşları toplamının 3 katından 4 eksiktir. Çocukların yaşları toplamı 14 olduğuna göre 5 yıl sonra annenin yaşı kaç olur?$$,
  jsonb_build_object('A', $$38$$, 'B', $$43$$, 'C', $$47$$, 'D', $$52$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Önce annenin bugünkü yaşını bul: Çocukların yaşları toplamını (14) 3 ile çarpıp 4 çıkar. 5 yıl sonraki yaşı için annenin bugünkü yaşına 5 ekle.$$,
    $$Adım 1: Annenin bugünkü yaşı = (14 × 3) − 4 = 42 − 4 = 38.$$,
    $$Adım 2: 5 yıl sonra = 38 + 5 = 43. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-018 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$Bölme İşleminde Basamak Sayısı Belirleme$$,
  2,
  $$Dört basamaklı 6A42 sayısı 65'e bölündüğünde bölümün İKİ basamaklı olması için "A" yerine yazılabilecek en büyük rakam kaçtır?$$,
  jsonb_build_object('A', $$4$$, 'B', $$5$$, 'C', $$6$$, 'D', $$9$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: 4 basamaklı bir sayı 2 basamaklı bir sayıya bölündüğünde; sayının ilk iki basamağı (6A), bölenden (65) KÜÇÜK olursa bölüm iki basamaklı olur. 6A < 65 şartını sağlayan en büyük A rakamını bul!$$,
    $$Adım 1: Bölünenin ilk iki basamağı "6A", bölen 65 ile karşılaştırılır.$$,
    $$Adım 2: 6A ≥ 65 olsaydı bölüm 3 basamaklı çıkardı.$$,
    $$Adım 3: Bölümün 2 basamaklı olması için 6A < 65 → A ∈ {0, 1, 2, 3, 4}.$$,
    $$Adım 4: En büyük rakam 4'tür. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-019 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Sayı Yuvarlama ve Tahmini İşlem$$,
  2,
  $$Ali 438 ile 286 sayılarını en yakın onluğa yuvarlayarak topluyor. Gerçek sonuç ile Ali'nin tahmini sonucu arasındaki fark kaçtır?$$,
  jsonb_build_object('A', $$0$$, 'B', $$4$$, 'C', $$6$$, 'D', $$10$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Gerçek toplama sonucunu bul. Ardından her iki sayıyı birler basamağına bakarak en yakın onluğa yuvarla ve iki sonucu karşılaştır.$$,
    $$Adım 1: Gerçek sonuç: 438 + 286 = 724.$$,
    $$Adım 2: Onluğa yuvarlama: 438 → 440 (8 ≥ 5); 286 → 290 (6 ≥ 5).$$,
    $$Adım 3: Tahmini toplam: 440 + 290 = 730.$$,
    $$Adım 4: Fark: 730 − 724 = 6. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-020 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Para Problemleri ve Eşit Paylaşım$$,
  2,
  $$Dört arkadaş bir restoranda gelen 540 TL'lik hesabı eşit olarak paylaşacaktır. İçlerinden biri parasının olmadığını söyleyince diğerleri hesabı eşit olarak ödemiştir. Buna göre kişi başına düşen pay kaç TL artmıştır?$$,
  jsonb_build_object('A', $$35$$, 'B', $$40$$, 'C', $$45$$, 'D', $$50$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: İlk durumda 540 TL 4 kişiye bölünecekti. İkinci durumda 1 kişi ödemeyince 540 TL 3 kişiye bölündü. İki durumdaki kişi başı tutarları çıkar.$$,
    $$Adım 1: 4 kişi ödeseydi kişi başı: 540 ÷ 4 = 135 TL.$$,
    $$Adım 2: 3 kişi ödediğinde kişi başı: 540 ÷ 3 = 180 TL.$$,
    $$Adım 3: Artış: 180 − 135 = 45 TL. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-021 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$Eksik Rakamlı Çıkarma İşlemi$$,
  2,
  $$  7 K 4 2
- 3 8 L 6
----------
  3 6 8 6
Yukarıdaki çıkarma işlemine göre (K + L) kaçtır?$$,
  jsonb_build_object('A', $$9$$, 'B', $$10$$, 'C', $$11$$, 'D', $$12$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Çıkarma işleminde onluk bozmalara dikkat et: 2'den 6 çıkmaz, yandan bir onluk alınır: 12 − 6 = 6. Kalan 3'ten L çıkınca 8 kalması için yine bir onluk alınması gerekir.$$,
    $$Adım 1: Birler: 12 − 6 = 6 (onlar basamağındaki 4, 3 kaldı).$$,
    $$Adım 2: Onlar: 3'ten L çıkıp 8 kalması için K'den 1 onluk alınır → 13 − L = 8 → L = 5.$$,
    $$Adım 3: Yüzler: (K − 1) − 8 = 6 olabilmesi için binlerden 1 onluk alınmalı → 10 + K − 1 − 8 = 6 → K = 5.$$,
    $$Adım 4: Binler kontrolü: 6 − 3 = 3 ✓.$$,
    $$Adım 5: K + L = 5 + 5 = 10. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-022 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Roma Rakamları$$,
  1,
  $$Roma rakamlarıyla "XXIV" ve "XVI" olarak yazılan iki sayının toplamı Roma rakamıyla nasıl gösterilir?$$,
  jsonb_build_object('A', $$XXXX$$, 'B', $$XL$$, 'C', $$LX$$, 'D', $$L$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: X = 10, V = 5, I = 1, L = 50. XXIV ve XVI sayılarının değerlerini bulup topla, ardından 40 sayısının Roma rakamıyla nasıl yazıldığını hatırla (50'den 10 eksik).$$,
    $$Adım 1: XXIV = 10 + 10 + (5 − 1) = 24.$$,
    $$Adım 2: XVI = 10 + 5 + 1 = 16.$$,
    $$Adım 3: Toplam = 24 + 16 = 40.$$,
    $$Adım 4: 40 = L (50)'nin soluna X (10) konularak XL şeklinde yazılır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-023 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Fazlalık / Eksiklik Problemleri$$,
  2,
  $$Ayşe'nin parası, Burak'ın parasından 60 TL fazla, Can'ın parasından ise 40 TL eksiktir. Üçünün toplam parası 550 TL olduğuna göre Burak'ın kaç TL'si vardır?$$,
  jsonb_build_object('A', $$130$$, 'B', $$190$$, 'C', $$230$$, 'D', $$150$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Burak'a 1 kutu de. Ayşe = 1 kutu + 60 TL; Can = Ayşe + 40 TL = 1 kutu + 100 TL. Fazlalıkları toplam paradan çıkarıp 3'e böl!$$,
    $$Adım 1: Burak = 1 kat.$$,
    $$Adım 2: Ayşe = 1 kat + 60 TL.$$,
    $$Adım 3: Can = 1 kat + 100 TL.$$,
    $$Adım 4: Toplam = 3 kat + 160 TL = 550 → 3 kat = 390.$$,
    $$Adım 5: Burak = 390 ÷ 3 = 130 TL. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-024 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$Kalansız Bölünebilme Mantığı$$,
  2,
  $$840 adet ceviz her pakette eşit sayıda olacak şekilde paketlenecektir. Bir paketteki ceviz sayısı aşağıdakilerden hangisi OLAMAZ?$$,
  jsonb_build_object('A', $$14$$, 'B', $$18$$, 'C', $$24$$, 'D', $$35$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Paketteki ceviz sayısının 840'ı kalansız bölmesi gerekir. Şıklardaki sayıları 840'a bölerek kalansız bölmeyen seçeneği bul.$$,
    $$Adım 1: 840 ÷ 14 = 60 (tam bölünür).$$,
    $$Adım 2: 840 ÷ 18 = 46 kalan 12 (tam bölünmez).$$,
    $$Adım 3: 840 ÷ 24 = 35 (tam bölünür).$$,
    $$Adım 4: 840 ÷ 35 = 24 (tam bölünür).$$,
    $$Adım 5: 18 sayısı 840'ı kalansız bölmediği için ceviz sayısı olamaz. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-025 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Adım / Mesafe Problemleri$$,
  3,
  $$Bir çocuk 5 adım ileri, 2 adım geri atarak ilerlemektedir. Bu çocuk toplam 62 adım attığında başlangıç noktasından kaç adım ilerlemiş olur?$$,
  jsonb_build_object('A', $$26$$, 'B', $$28$$, 'C', $$30$$, 'D', $$32$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Her döngüde çocuk 5 + 2 = 7 adım atar ve net 3 adım ilerler. 62'nin içinde kaç tane 7 adımlık döngü olduğunu ve kalanı hesapla.$$,
    $$Adım 1: 1 döngü = 7 adım → net 3 adım ilerleme.$$,
    $$Adım 2: 62 ÷ 7 = 8 döngü (tam), kalan = 6 adım.$$,
    $$Adım 3: 8 döngü = 8 × 3 = 24 adım ilerleme.$$,
    $$Adım 4: Kalan 6 adım: 5 ileri + 1 geri → net +4 adım ilerleme.$$,
    $$Adım 5: Toplam ilerleme = 24 + 4 = 28 adım. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-026 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Tek ve Çift Sayılar$$,
  1,
  $$Aşağıdaki sayılardan hangisi çifttir?$$,
  jsonb_build_object('A', $$7 315$$, 'B', $$8 421$$, 'C', $$6 708$$, 'D', $$9 999$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Birler basamağı 0, 2, 4, 6 veya 8 olan sayılar çifttir.$$,
    $$6 708 sayısının birler basamağı 8'dir; bu nedenle sayı çifttir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-027 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Karşılaştırma ve Sıralama$$,
  1,
  $$45 608, 45 680, 45 086 ve 46 008 sayılarının küçükten büyüğe sıralanışı hangisidir?$$,
  jsonb_build_object(
    'A', $$45 086 < 45 608 < 45 680 < 46 008$$,
    'B', $$45 608 < 45 086 < 45 680 < 46 008$$,
    'C', $$46 008 < 45 680 < 45 608 < 45 086$$,
    'D', $$45 086 < 45 680 < 45 608 < 46 008$$
  ),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Önce binler bölüğünü, eşitse yüzler ve onlar basamaklarını karşılaştır.$$,
    $$45 086, 45 608 ve 45 680 sayıları 45 binlidir; son üç basamakları karşılaştırılır: 86 < 608 < 680. 46 008 diğerlerinden büyüktür. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-028 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$En Büyük ve En Küçük Sayı$$,
  2,
  $$2, 4, 6 ve 9 rakamları birer kez kullanılarak yazılabilecek dört basamaklı en büyük çift sayı kaçtır?$$,
  jsonb_build_object('A', $$9 624$$, 'B', $$9 642$$, 'C', $$9 426$$, 'D', $$6 924$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: En büyük sayı için büyük rakamları solda tut; son basamak çift olmalı.$$,
    $$Binler basamağına 9, yüzler basamağına 6, onlar basamağına 4, birler basamağına 2 yerleştirilir. Sayı 9 642 olur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-029 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Yuvarlama$$,
  1,
  $$7 349 sayısının en yakın yüzlüğe yuvarlanmış hâli kaçtır?$$,
  jsonb_build_object('A', $$7 300$$, 'B', $$7 350$$, 'C', $$7 400$$, 'D', $$7 000$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Yüzlüğe yuvarlamada onlar basamağına bak.$$,
    $$7 349'un onlar basamağı 4'tür. 5'ten küçük olduğu için aşağı yuvarlanır: 7 300. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-030 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Yuvarlama$$,
  1,
  $$62 501 sayısının en yakın binliğe yuvarlanmış hâli kaçtır?$$,
  jsonb_build_object('A', $$62 000$$, 'B', $$62 500$$, 'C', $$63 000$$, 'D', $$60 000$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Binliğe yuvarlarken yüzler basamağına bak.$$,
    $$62 501'in yüzler basamağı 5'tir. 5 ve üzeri olduğu için 63 000'e yuvarlanır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-031 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Çözümleme$$,
  1,
  $$58 204 sayısının çözümlemesi hangisidir?$$,
  jsonb_build_object(
    'A', $$50 000 + 8 000 + 200 + 4$$,
    'B', $$5 000 + 800 + 20 + 4$$,
    'C', $$50 000 + 800 + 20 + 4$$,
    'D', $$50 000 + 8 000 + 20 + 4$$
  ),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Her rakamı bulunduğu basamak değeriyle yaz.$$,
    $$58 204 = 50 000 + 8 000 + 200 + 0 + 4. Sıfır terimi yazılmadığından A seçeneği doğrudur.$$
  ]::text[])
),

-- ── MAT-032 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Toplama$$,
  $$Doğal Sayılarla Toplama$$,
  1,
  $$28 475 + 6 309 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$34 684$$, 'B', $$34 784$$, 'C', $$35 784$$, 'D', $$33 784$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Birler basamağından başlayarak basamakları hizala.$$,
    $$28 475 + 6 309 = 34 784. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-033 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Çıkarma$$,
  $$Doğal Sayılarla Çıkarma$$,
  1,
  $$50 000 − 27 846 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$22 154$$, 'B', $$22 254$$, 'C', $$23 154$$, 'D', $$23 254$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Sıfırlardan ödünç alırken basamakları dikkatle takip et.$$,
    $$50 000 − 27 846 = 22 154. Kontrol: 22 154 + 27 846 = 50 000. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-034 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Çarpma$$,
  $$Doğal Sayılarla Çarpma$$,
  1,
  $$306 × 7 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$2 042$$, 'B', $$2 142$$, 'C', $$2 242$$, 'D', $$2 362$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: 300 × 7 ile 6 × 7'yi ayrı hesapla.$$,
    $$306 × 7 = 300 × 7 + 6 × 7 = 2 100 + 42 = 2 142. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-035 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Bölme$$,
  $$Kalansız Bölme$$,
  1,
  $$936 ÷ 9 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$94$$, 'B', $$104$$, 'C', $$114$$, 'D', $$124$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Sonucunu 9 ile çarparak kontrol et.$$,
    $$9 × 104 = 936 olduğundan 936 ÷ 9 = 104. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-036 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Toplama Problemi$$,
  1,
  $$Bir kütüphanede 1 248 Türkçe, 967 matematik kitabı vardır. Toplam kaç kitap vardır?$$,
  jsonb_build_object('A', $$2 115$$, 'B', $$2 205$$, 'C', $$2 215$$, 'D', $$2 315$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: İki kitap grubunu birleştirdiğin için toplama yap.$$,
    $$1 248 + 967 = 2 215 kitap. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-037 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Çıkarma Problemi$$,
  1,
  $$3 500 sayfalık bir kitabın 1 275 sayfası okunmuştur. Kaç sayfa kalmıştır?$$,
  jsonb_build_object('A', $$2 125$$, 'B', $$2 225$$, 'C', $$2 325$$, 'D', $$2 425$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Toplamdan okunan sayfa sayısını çıkar.$$,
    $$3 500 − 1 275 = 2 225 sayfa kalır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-038 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Çarpma Problemi$$,
  1,
  $$Her kutuda 24 kalem bulunan 6 kutuda toplam kaç kalem vardır?$$,
  jsonb_build_object('A', $$120$$, 'B', $$134$$, 'C', $$144$$, 'D', $$154$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Eşit grupları bulmak için kutu sayısı ile bir kutudaki kalem sayısını çarp.$$,
    $$24 × 6 = 144 kalem. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-039 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Bölme Problemi$$,
  1,
  $$168 elma 7 sepete eşit paylaştırılırsa her sepete kaç elma konur?$$,
  jsonb_build_object('A', $$21$$, 'B', $$24$$, 'C', $$27$$, 'D', $$28$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: 168'i 7 eşit gruba ayır.$$,
    $$168 ÷ 7 = 24. Her sepete 24 elma konur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-040 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$İşlem Önceliği$$,
  2,
  $$18 + 6 × 4 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$42$$, 'B', $$48$$, 'C', $$72$$, 'D', $$96$$),
  'A', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Çarpma, toplama işleminden önce yapılır.$$,
    $$Önce 6 × 4 = 24, sonra 18 + 24 = 42. Doğru cevap A seçeneğidir.$$
  ]::text[])
),

-- ── MAT-041 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$Parantezli İşlem$$,
  2,
  $$(36 + 24) ÷ 6 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$6$$, 'B', $$10$$, 'C', $$12$$, 'D', $$14$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Parantez içindeki işlemi önce tamamla.$$,
    $$36 + 24 = 60; 60 ÷ 6 = 10. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-042 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem$$,
  $$İşlem Önceliği$$,
  2,
  $$72 − (18 ÷ 3 + 5) işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$55$$, 'B', $$61$$, 'C', $$67$$, 'D', $$79$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Önce parantez içindeki bölme ve toplamayı tamamla.$$,
    $$18 ÷ 3 = 6; 6 + 5 = 11; 72 − 11 = 61. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-043 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Bölükler$$,
  1,
  $$3 407 025 sayısında kaç tane bölük vardır?$$,
  jsonb_build_object('A', $$2$$, 'B', $$3$$, 'C', $$4$$, 'D', $$5$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Sayıyı sağdan başlayarak üçerli gruplara ayır.$$,
    $$3 | 407 | 025 → üç grup: milyonlar, binler ve birler bölüğü. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-044 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Basamak Değeri$$,
  2,
  $$2 305 418 sayısında 5 rakamının basamak değeri kaçtır?$$,
  jsonb_build_object('A', $$5$$, 'B', $$500$$, 'C', $$5 000$$, 'D', $$50 000$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: 5 rakamının bulunduğu basamağı soldan sağa say.$$,
    $$5 rakamı binler basamağındadır. Basamak değeri = 5 × 1 000 = 5 000. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-045 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Tahmin$$,
  2,
  $$3 984 + 2 117 işleminin en yakın yüzlüklere yuvarlanarak yapılan tahmini sonucu kaçtır?$$,
  jsonb_build_object('A', $$5 900$$, 'B', $$6 000$$, 'C', $$6 100$$, 'D', $$6 200$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Her sayıyı ayrı ayrı en yakın yüzlüğe yuvarla.$$,
    $$3 984 → 4 000; 2 117 → 2 000. Tahmini toplam: 4 000 + 2 000 = 6 000. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-046 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$İki İşlemli Problem$$,
  2,
  $$Bir çiftlikte 8 kümeste 15'er tavuk vardır. Tavukların 27'si satılırsa kaç tavuk kalır?$$,
  jsonb_build_object('A', $$83$$, 'B', $$93$$, 'C', $$103$$, 'D', $$123$$),
  'B', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Önce toplam tavuk sayısını bul, sonra satılanları çıkar.$$,
    $$8 × 15 = 120 tavuk; 120 − 27 = 93 tavuk kalır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),

-- ── MAT-047 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Kalanlı Bölme Problemi$$,
  2,
  $$125 öğrenci, her sırada 4 öğrenci olacak şekilde oturtulacaktır. En az kaç sıra gerekir?$$,
  jsonb_build_object('A', $$30$$, 'B', $$31$$, 'C', $$32$$, 'D', $$33$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: 125'i 4'e böl. Kalan öğrenci için yeni bir sıra gerekir.$$,
    $$125 ÷ 4 = 31 kalan 1. 31 sıra 124 öğrenciyi alır; kalan 1 öğrenci için 1 sıra daha gerekir. Toplam 32 sıra. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-048 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Doğal Sayılar$$,
  $$Örüntü$$,
  2,
  $$2, 5, 11, 23, 47, ... örüntüsünde sıradaki sayı kaçtır?$$,
  jsonb_build_object('A', $$71$$, 'B', $$94$$, 'C', $$95$$, 'D', $$96$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Her terimin önceki terimle ilişkisini incele: 2'den 5'e, 5'ten 11'e geçiş nasıl olmuş?$$,
    $$Her sayı 2 ile çarpılıp 1 eklenerek elde edilir: 47 × 2 + 1 = 95. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-049 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Birim Fiyat$$,
  2,
  $$5 defterin fiyatı 175 TL'dir. Aynı fiyattan 8 defter kaç TL olur?$$,
  jsonb_build_object('A', $$240$$, 'B', $$260$$, 'C', $$280$$, 'D', $$300$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Önce bir defterin fiyatını, sonra 8 defterin fiyatını bul.$$,
    $$Bir defter: 175 ÷ 5 = 35 TL; 8 defter: 8 × 35 = 280 TL. Doğru cevap C seçeneğidir.$$
  ]::text[])
),

-- ── MAT-050 ────────────────────────────────────────────────────────────
(
  'ortaokul', 5, 'Matematik',
  $$Dört İşlem Problemleri$$,
  $$Mantık ve İşlem$$,
  3,
  $$Bir sayının 4 katının 12 eksiği 68'dir. Bu sayı kaçtır?$$,
  jsonb_build_object('A', $$14$$, 'B', $$16$$, 'C', $$20$$, 'D', $$24$$),
  'C', 'beklemede',
  to_jsonb(ARRAY[
    $$İpucu: Önce 68'e 12 ekleyerek sayının 4 katını bul, sonra 4'e böl.$$,
    $$Sayının 4 katı: 68 + 12 = 80; sayı: 80 ÷ 4 = 20. Doğru cevap C seçeneğidir.$$
  ]::text[])
)

;
