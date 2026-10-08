-- =====================================================================
--  SORU BANKASI: 1-8. sınıflar (360 soru) — onay_durumu = 'onaylandi'
--  Üretici : node tools/soru_bankasi_sql_tum_siniflar.mjs
--  Kaynak  : soru-bankasi/sinif-{1..8}/*.md
--  Dağılım : 1. sınıf 30, 2. sınıf 40, 3. sınıf 50, 4. sınıf 60, 6. sınıf 60, 7. sınıf 60, 8. sınıf 60
--
--  KARAR (2026-10-07, ürün sahibi): bu örnek sorular TEST AMAÇLI üretilmiştir.
--  MEB kazanımlarına uygun, tek cevaplı ve seviyeye göre hazırlanmıştır; ancak
--  çıkmış sınav sorusu DEĞİLDİR. Test/demo amacıyla 'onaylandi' olarak yayına alınır.
--
--  NOT: 5. sınıf soruları (20261003000001 + 20261006030000) korunur; bu dosya
--  onlara dokunmaz. Idempotent: aynı (ders, sinif, soru_metni) varsa eklenmez.
-- =====================================================================

set client_encoding = 'UTF8';

create temporary table _soru_bankasi_tum_siniflar (
  okul text, sinif smallint, ders text, konu text, alt_konu text, zorluk smallint,
  soru_metni text, siklar jsonb, dogru_sik text, cozum_adimlari jsonb
) on commit drop;

insert into _soru_bankasi_tum_siniflar
values
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Okul Yaşamı$$, $$Sınıf kuralları$$, 1,
  $$Öğretmen ders anlatırken bir öğrenci ne yapmalıdır?$$,
  jsonb_build_object('A', $$Yüksek sesle konuşmalı$$, 'B', $$Sessizce dinlemelidir$$, 'C', $$Sınıfta koşmalı$$, 'D', $$Arkadaşına not atmalı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sınıfta dersin anlaşılması için herkesin uyması gereken bir kural vardır.$$,
    $$Adım 1: Sınıfta öğrenmenin gerçekleşmesi için sınıfın sakin olması gerekir.$$,
    $$Adım 2: Öğretmen konuşurken onu dikkatle dinlemek doğrudur.$$,
    $$Adım 3: Öğrenci sessizce dinlemelidir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Sağlık ve Temizlik$$, $$El temizliği$$, 1,
  $$Yemek yemeden önce ne yapmalıyız?$$,
  jsonb_build_object('A', $$Dişlerimizi fırçalamalıyız$$, 'B', $$Ellerimizi yıkamalıyız$$, 'C', $$Saçımızı taramalıyız$$, 'D', $$Ayakkabımızı giymeliyiz$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Elimizdeki mikropların yemeğe geçmesini engellemek için hangi temizlik yapılır?$$,
    $$Adım 1: Ellerimiz gün içinde birçok yere dokunduğu için mikropları taşıyabilir.$$,
    $$Adım 2: Bu mikropların yemeğe geçmemesi için yemekten önce el yıkanmalıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Güvenlik$$, $$Yol güvenliği$$, 1,
  $$Yaya geçidinde karşıdan karşıya geçmeden önce ne yapmalıyız?$$,
  jsonb_build_object('A', $$Koşarak karşıya geçmeliyiz$$, 'B', $$Sağa ve sola bakıp araçların durmasını beklemeliyiz$$, 'C', $$Gözlerimizi kapatıp geçmeliyiz$$, 'D', $$Araçların arasından geçmeliyiz$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Güvenli geçiş için önce çevreyi kontrol etmek gerekir.$$,
    $$Adım 1: Karşıdan karşıya geçerken en önemli şey güvenliktir.$$,
    $$Adım 2: Yaya geçidinde önce sağa ve sola bakıp araçların durmasını bekleriz.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Aile ve Toplum$$, $$Aile üyeleri$$, 1,
  $$Annemin annesine ne deriz?$$,
  jsonb_build_object('A', $$hala$$, 'B', $$teyze$$, 'C', $$büyükanne (nine)$$, 'D', $$abla$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Ailemizin büyükleri vardır: anne ve babanın anne-babalarına ne denir?$$,
    $$Adım 1: Ailenin büyükleri annenin ve babanın anne-babalarıdır.$$,
    $$Adım 2: Annenin annesine büyükanne (nine) denir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Okul Yaşamı$$, $$Arkadaşlık$$, 1,
  $$Arkadaşımız oyun oynarken düşüp ağlarsa ne yapmalıyız?$$,
  jsonb_build_object('A', $$Gülmeliyiz$$, 'B', $$Yardım edip onu teselli etmeliyiz$$, 'C', $$Onu görmezden gelmeliyiz$$, 'D', $$Kaçmalıyız$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İyi bir arkadaş, zor durumda olan arkadaşına nasıl davranır?$$,
    $$Adım 1: Arkadaşlar birbirine yardım eder ve iyi davranır.$$,
    $$Adım 2: Düşen arkadaşa yardım edip onu teselli etmek doğru davranıştır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Doğa ve Çevre$$, $$Doğa olayları$$, 1,
  $$Yağmur yağdıktan sonra gökyüzünde renkli bir köprü gibi görünen şeye ne denir?$$,
  jsonb_build_object('A', $$gökkuşağı$$, 'B', $$bulut$$, 'C', $$yıldız$$, 'D', $$güneş$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Yağmur ve güneş bir arada olduğunda gökyüzünde renkler oluşur.$$,
    $$Adım 1: Yağmurdan sonra havada su damlacıkları kalır.$$,
    $$Adım 2: Güneş ışığı bu damlacıklarda renklere ayrılır.$$,
    $$Adım 3: Bu renkli görüntüye gökkuşağı denir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Sağlık ve Temizlik$$, $$Diş sağlığı$$, 2,
  $$Günde kaç kez dişlerimizi fırçalamamız önerilir?$$,
  jsonb_build_object('A', $$Ayda bir$$, 'B', $$Haftada bir$$, 'C', $$Günde en az iki kez$$, 'D', $$Yılda bir$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Ağız sağlığı için diş fırçalama sık tekrarlanmalıdır. Sabah ve akşam düşün.$$,
    $$Adım 1: Dişler yemeklerden sonra kirlenir ve mikroplardan korunmalıdır.$$,
    $$Adım 2: Bu yüzden dişler düzenli olarak, her gün fırçalanmalıdır.$$,
    $$Adım 3: Sağlık için günde en az iki kez (sabah ve akşam) fırçalanır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Güvenlik$$, $$Evde güvenlik$$, 2,
  $$Evde yalnızken tanımadığımız biri kapıyı çalarsa ne yapmalıyız?$$,
  jsonb_build_object('A', $$Hemen kapıyı açmalıyız$$, 'B', $$Kapıyı açmamalıyız$$, 'C', $$Onunla dışarı çıkmalıyız$$, 'D', $$Adresimizi söylemeliyiz$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Tanımadığımız kişilere karşı kendimizi nasıl koruruz?$$,
    $$Adım 1: Tanımadığımız kişilere kapı açmak güvenli değildir.$$,
    $$Adım 2: Evde yalnızken tanımadığımız birine kapıyı açmamalıyız.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Okul Yaşamı$$, $$Ders araçları$$, 1,
  $$Yazı yazmak için kullandığımız araç hangisidir?$$,
  jsonb_build_object('A', $$makas$$, 'B', $$kalem$$, 'C', $$cetvel$$, 'D', $$silgi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Deftere yazı yazarken elimize aldığımız aracı düşün.$$,
    $$Adım 1: Makas kesmek, cetvel ölçmek, silgi ise silmek için kullanılır.$$,
    $$Adım 2: Yazı yazmak için kalem kullanılır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Hayat Bilgisi$$, $$Doğa ve Çevre$$, $$Mevsimler$$, 2,
  $$Ağaçların yapraklarının döküldüğü, havaların serinlediği mevsim hangisidir?$$,
  jsonb_build_object('A', $$ilkbahar$$, 'B', $$yaz$$, 'C', $$sonbahar$$, 'D', $$kış$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Yaprakların sararıp döküldüğü mevsim, yazdan sonra gelir.$$,
    $$Adım 1: İlkbaharda doğa canlanır, yazın hava sıcak olur, kışın kar yağar.$$,
    $$Adım 2: Yaprakların döküldüğü, havanın serinlediği mevsim sonbahardır.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Doğal Sayılar$$, $$Nesne sayısı$$, 1,
  $$Ayşe'nin 7 kalemi vardır. Bir kalem daha alırsa kaç kalemi olur?$$,
  jsonb_build_object('A', $$6$$, 'B', $$7$$, 'C', $$8$$, 'D', $$9$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "Bir kalem daha" demek, var olan sayının 1 artması demektir. 7'den sonra gelen sayıyı bul.$$,
    $$Adım 1: Ayşe'nin başlangıçta 7 kalemi vardır.$$,
    $$Adım 2: Bir kalem daha alınca 7 + 1 işlemi yapılır.$$,
    $$Adım 3: 7 + 1 = 8 kalem olur. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Doğal Sayılar$$, $$Sayıları karşılaştırma$$, 1,
  $$Aşağıdaki sayılardan en büyüğü hangisidir?$$,
  jsonb_build_object('A', $$9$$, 'B', $$12$$, 'C', $$20$$, 'D', $$15$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Onluk ve birlikleri düşün. İki basamaklı sayılar, tek basamaklılardan büyüktür. Onluk sayısı çok olan daha büyüktür.$$,
    $$Adım 1: 9 tek basamaklıdır, bu yüzden diğerlerinden küçüktür.$$,
    $$Adım 2: 12, 15 ve 20 iki basamaklıdır. Onluklarına bakalım: 1, 1 ve 2 onluk.$$,
    $$Adım 3: En fazla onluğu olan 20 (2 onluk) en büyüktür. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Toplama$$, $$20'ye kadar toplama$$, 1,
  $$6 + 5 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$10$$, 'B', $$11$$, 'C', $$12$$, 'D', $$13$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: 6'nın üzerine 5 kez birer birer say: 7, 8, 9, 10, 11.$$,
    $$Adım 1: 6 sayısından başlayıp 5 ileri sayarız.$$,
    $$Adım 2: 7, 8, 9, 10, 11 şeklinde sayarız.$$,
    $$Adım 3: Son sayı 11'dir. 6 + 5 = 11. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Çıkarma$$, $$20'ye kadar çıkarma$$, 1,
  $$14 - 6 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$6$$, 'B', $$7$$, 'C', $$8$$, 'D', $$9$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: 14'ten geriye 6 kez birer birer say: 13, 12, 11, 10, 9, 8.$$,
    $$Adım 1: 14 sayısından geriye doğru 6 adım sayarız.$$,
    $$Adım 2: 13, 12, 11, 10, 9, 8 şeklinde geri sayarız.$$,
    $$Adım 3: Son sayı 8'dir. 14 - 6 = 8. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Geometrik Şekiller$$, $$Şekilleri tanıma$$, 1,
  $$Dört kenarı ve dört köşesi olan, bütün kenarları eşit şekle ne denir?$$,
  jsonb_build_object('A', $$üçgen$$, 'B', $$kare$$, 'C', $$daire$$, 'D', $$dikdörtgen$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kenar sayısını say. Sekiz değil, dört kenar. Bütün kenarları eşit olan şekli seç.$$,
    $$Adım 1: Üçgenin 3, dairenin kenarı yoktur, dikdörtgenin ise karşılıklı kenarları eşittir.$$,
    $$Adım 2: Dört kenarı olan ve tüm kenarları eşit olan şekil karedir.$$,
    $$Adım 3: Cevap karedir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Örüntü$$, $$Basit sayı örüntüsü$$, 2,
  $$2, 4, 6, 8, ... örüntüsünde bir sonraki sayı kaçtır?$$,
  jsonb_build_object('A', $$9$$, 'B', $$10$$, 'C', $$11$$, 'D', $$12$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sayılar birer değil ikişer ikişer artıyor. 8'den sonra 2 ekle.$$,
    $$Adım 1: Örüntüde sayılar 2, 4, 6, 8 şeklinde ikişer ikişer artmaktadır.$$,
    $$Adım 2: Son sayı 8'dir, buna 2 ekleriz.$$,
    $$Adım 3: 8 + 2 = 10. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Paralarımız$$, $$Para toplama$$, 2,
  $$Ali'nin 5 lirası var. Babası 10 lira daha verirse Ali'nin toplam kaç lirası olur?$$,
  jsonb_build_object('A', $$5$$, 'B', $$10$$, 'C', $$15$$, 'D', $$20$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Elindeki paraya eklenen parayı topla: 5 + 10.$$,
    $$Adım 1: Ali'nin başlangıçta 5 lirası vardır.$$,
    $$Adım 2: Babası 10 lira daha verir.$$,
    $$Adım 3: 5 + 10 = 15 lira olur. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Saatler$$, $$Tam saat okuma$$, 2,
  $$Akrep 3'ü, yelkovan 12'yi gösteriyorsa saat kaçtır?$$,
  jsonb_build_object('A', $$12.00$$, 'B', $$3.00$$, 'C', $$6.00$$, 'D', $$9.00$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Yelkovan 12'deyse tam saattir. Akrep hangi sayıyı gösteriyorsa saat o sayıdır.$$,
    $$Adım 1: Yelkovan 12'yi gösterdiği için saat tam saattir.$$,
    $$Adım 2: Akrep 3'ü göstermektedir.$$,
    $$Adım 3: Saat 3.00'dır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Toplama$$, $$Üç sayının toplamı$$, 2,
  $$4 + 3 + 2 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$8$$, 'B', $$9$$, 'C', $$10$$, 'D', $$11$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Önce ilk iki sayıyı topla, sonra bulduğun sonuca üçüncü sayıyı ekle.$$,
    $$Adım 1: Önce 4 + 3 = 7 bulunur.$$,
    $$Adım 2: Bulunan sonuca üçüncü sayı eklenir: 7 + 2.$$,
    $$Adım 3: 7 + 2 = 9. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Matematik$$, $$Doğal Sayılar$$, $$Onluk ve birlik$$, 2,
  $$17 sayısında kaç onluk ve kaç birlik vardır?$$,
  jsonb_build_object('A', $$1 onluk 7 birlik$$, 'B', $$7 onluk 1 birlik$$, 'C', $$1 onluk 1 birlik$$, 'D', $$17 onluk 0 birlik$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Sol taraftaki rakam onluk, sağ taraftaki rakam birlik sayısını verir.$$,
    $$Adım 1: 17 sayısının sol rakamı 1, sağ rakamı 7'dir.$$,
    $$Adım 2: Sol rakam onluk, sağ rakam birlik sayısını gösterir.$$,
    $$Adım 3: 1 onluk ve 7 birlik vardır. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Harf Bilgisi$$, $$Sesli harfler$$, 1,
  $$Aşağıdaki harflerden hangisi sesli (ünlü) harftir?$$,
  jsonb_build_object('A', $$k$$, 'B', $$m$$, 'C', $$a$$, 'D', $$s$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Sesli harfleri ağzından rahatça, tek başına çıkarabilirsin. "a, e, ı, i, o, ö, u, ü" sesli harflerdir.$$,
    $$Adım 1: Alfabemizdeki sesli harfler a, e, ı, i, o, ö, u, ü'dür.$$,
    $$Adım 2: k, m ve s harfleri tek başına söylenemez; bunlar sessiz harflerdir.$$,
    $$Adım 3: "a" sesli (ünlü) bir harftir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Hece Bilgisi$$, $$Hece sayma$$, 1,
  $$"kalem" sözcüğü kaç hecelidir?$$,
  jsonb_build_object('A', $$1$$, 'B', $$2$$, 'C', $$3$$, 'D', $$4$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Her sesli harf bir hece oluşturur. Sözcükteki sesli harfleri say.$$,
    $$Adım 1: Sözcükteki sesli harfleri buluruz: "kalem" sözcüğünde a ve e sesli harfleri vardır.$$,
    $$Adım 2: Her sesli harf bir hece demektir.$$,
    $$Adım 3: ka-lem → 2 hece. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Okuma-Anlama$$, $$Cümlede anlam$$, 1,
  $$"Ali okula gitti." cümlesinde Ali nereye gitmiştir?$$,
  jsonb_build_object('A', $$parka$$, 'B', $$eve$$, 'C', $$okula$$, 'D', $$markete$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Cümleyi dikkatli oku: Ali nereye gittiği cümlede açıkça yazıyor.$$,
    $$Adım 1: Cümle "Ali okula gitti." şeklindedir.$$,
    $$Adım 2: Cümlede gidilen yer "okul"dur.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Zıt Anlam$$, $$Karşıt anlamlı sözcükler$$, 1,
  $$"büyük" sözcüğünün zıt (karşıt) anlamlısı hangisidir?$$,
  jsonb_build_object('A', $$küçük$$, 'B', $$uzun$$, 'C', $$geniş$$, 'D', $$ağır$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Zıt anlamlı sözcükler birbirinin tam tersini anlatır. "Büyük" olmayan şeye ne deriz?$$,
    $$Adım 1: "Büyük" bir şeyin boyutunun fazla olduğunu anlatır.$$,
    $$Adım 2: Bunun tam tersi, boyutu az olan yani "küçük"tür.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Yazım Kuralları$$, $$Cümle başlangıcı$$, 1,
  $$Aşağıdaki cümlelerden hangisinin ilk harfi doğru yazılmıştır?$$,
  jsonb_build_object('A', $$bugün hava güzel.$$, 'B', $$Bugün hava güzel.$$, 'C', $$bUgün hava güzel.$$, 'D', $$BUgün hava güzel.$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir cümle her zaman büyük harfle başlar ve yalnızca ilk harfi büyük olur.$$,
    $$Adım 1: Her cümle büyük harfle başlar.$$,
    $$Adım 2: A ve C seçenekleri küçük harfle başlamıştır, D seçeneğinde ise iki harf büyük yazılmıştır.$$,
    $$Adım 3: Yalnızca ilk harfi büyük olan "Bugün hava güzel." doğrudur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Noktalama İşaretleri$$, $$Cümle sonu işareti$$, 1,
  $$"Bugün okula gittim" cümlesinin sonuna hangi noktalama işareti gelmelidir?$$,
  jsonb_build_object('A', $$soru işareti (?)$$, 'B', $$nokta (.)$$, 'C', $$virgül (,)$$, 'D', $$ünlem (!)$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Cümle bir soru sormuyor, bir şey anlatıyor. Anlatan cümlelerin sonuna ne konur?$$,
    $$Adım 1: Cümle soru anlamı taşımıyor, bir bilgi veriyor.$$,
    $$Adım 2: Bilgi veren (haber) cümlelerinin sonuna nokta konur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Sözcükte Anlam$$, $$Eş anlamlılık$$, 2,
  $$"Öğretmen" sözcüğünün eş anlamlısı hangisidir?$$,
  jsonb_build_object('A', $$öğrenci$$, 'B', $$müdür$$, 'C', $$muallim$$, 'D', $$veli$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Eş anlamlı sözcükler aynı anlamı taşır. Öğretmene eskiden başka bir sözcük de denirdi.$$,
    $$Adım 1: Eş anlamlı sözcükler yazılışı farklı ama anlamı aynı olan sözcüklerdir.$$,
    $$Adım 2: "Öğretmen" sözcüğünün eş anlamlısı "muallim"dir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Alfabetik Sıralama$$, $$Harf sırası$$, 2,
  $$Aşağıdaki sözcüklerden hangisi sözlükte en önce gelir?$$,
  jsonb_build_object('A', $$masa$$, 'B', $$araba$$, 'C', $$kalem$$, 'D', $$silgi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sözlükte sıralama ilk harfe göre yapılır. Alfabede en önce gelen harfle başlayan sözcüğü bul.$$,
    $$Adım 1: Sözcüklerin ilk harflerine bakalım: m, a, k, s.$$,
    $$Adım 2: Alfabede "a" harfi en önce gelir.$$,
    $$Adım 3: "araba" sözcüğü alfabetik olarak ilktir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Okuma-Anlama$$, $$Cümlede konu$$, 2,
  $$"Kedi bahçede sütü içti." cümlesinde ne içildi?$$,
  jsonb_build_object('A', $$su$$, 'B', $$süt$$, 'C', $$çay$$, 'D', $$meyve suyu$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Cümlede neyin içildiği açıkça yazıyor. Nesnenin adını bul.$$,
    $$Adım 1: Cümlemiz "Kedi bahçede sütü içti." şeklindedir.$$,
    $$Adım 2: Cümlede içilen şey "süt" olarak belirtilmiştir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 1, $$Türkçe$$, $$Yazım Kuralları$$, $$Özel adların yazımı$$, 2,
  $$Aşağıdaki cümlelerden hangisinde kişi adı doğru yazılmıştır?$$,
  jsonb_build_object('A', $$ayşe okula gitti.$$, 'B', $$Ayşe okula gitti.$$, 'C', $$ayŞe okula gitti.$$, 'D', $$AYŞE okula gitti.$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kişi adları özel addır ve her zaman büyük harfle başlar, yalnızca ilk harfi büyük olur.$$,
    $$Adım 1: Kişi adları özel ad olduğu için büyük harfle başlar.$$,
    $$Adım 2: A ve C seçeneklerinde küçük harfle başlamış, D'de ise tüm harfler büyük yazılmıştır.$$,
    $$Adım 3: Yalnızca ilk harfi büyük olan "Ayşe" doğrudur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Okul Yaşamı$$, $$Sınıf araçları$$, 1,
  $$Tahtaya yazı yazmak için öğretmen hangi aracı kullanır?$$,
  jsonb_build_object('A', $$silgi$$, 'B', $$kalem$$, 'C', $$tebeşir$$, 'D', $$defter$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Tahtaya yazı yazmak için kalem değil, özel bir araç kullanılır.$$,
    $$Adım 1: Tahtaya yazı yazmak için kalem kullanılmaz.$$,
    $$Adım 2: Tahtaya yazmak için tebeşir kullanılır.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Sağlıklı Yaşam$$, $$Dengeli beslenme$$, 1,
  $$Sağlıklı büyümek için hangisini tüketmemeliyiz?$$,
  jsonb_build_object('A', $$süt$$, 'B', $$meyve$$, 'C', $$sebze$$, 'D', $$aşırı şekerli yiyecek$$),
  'D',
  to_jsonb(ARRAY[
    $$İpucu: Hangisi sağlığa zararlı ve aşırı tüketildiğinde dişlere zarar verir?$$,
    $$Adım 1: Süt, meyve ve sebze sağlıklı besinlerdir.$$,
    $$Adım 2: Aşırı şekerli yiyecekler sağlığa zararlıdır ve fazla tüketilmemelidir.$$,
    $$Adım 3: Doğru cevap D seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Güvenlik$$, $$Acil durum$$, 2,
  $$Yangın çıktığında hangi numarayı aramalıyız?$$,
  jsonb_build_object('A', $$112$$, 'B', $$155$$, 'C', $$110$$, 'D', $$156$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Acil yardım gerektiren yangın, kaza gibi durumlarda aranan tek numara vardır.$$,
    $$Adım 1: Yangın gibi acil durumlarda hızlıca itfaiye/ambulans çağrılmalıdır.$$,
    $$Adım 2: Acil çağrı numarası 112'dir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Aile ve Toplum$$, $$Görev ve sorumluluklar$$, 1,
  $$Evde kendi odamızı toplamak hangi sorumluluğumuza girer?$$,
  jsonb_build_object('A', $$okul sorumluluğu$$, 'B', $$ev sorumluluğu$$, 'C', $$arkadaşlık$$, 'D', $$oyun$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Odamız evde olduğumuz yerdir; bu görev hangi ortama ait?$$,
    $$Adım 1: Kendi odamız evimizin bir bölümüdür.$$,
    $$Adım 2: Odayı toplamak evle ilgili bir sorumluluktur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Doğa ve Çevre$$, $$Çevreyi koruma$$, 1,
  $$Yerde çöp gördüğümüzde ne yapmalıyız?$$,
  jsonb_build_object('A', $$Üzerine basmalıyız$$, 'B', $$Çöp kutusuna atmalıyız$$, 'C', $$Görmezden gelmeliyiz$$, 'D', $$Tekmelemeliyiz$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Çevremizi temiz tutmak için çöpü nereye atarız?$$,
    $$Adım 1: Çevreyi temiz tutmak hepimizin görevidir.$$,
    $$Adım 2: Yerde gördüğümüz çöpü çöp kutusuna atmalıyız.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Sağlıklı Yaşam$$, $$Uyku düzeni$$, 2,
  $$Çocukların sağlıklı büyümesi için günde yaklaşık kaç saat uyuması önerilir?$$,
  jsonb_build_object('A', $$3-4 saat$$, 'B', $$5-6 saat$$, 'C', $$9-11 saat$$, 'D', $$15 saat$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Çocuklar yetişkinlerden daha çok uykuya ihtiyaç duyar; büyüme uykuda olur.$$,
    $$Adım 1: Uyku, çocukların büyüyüp dinlenmesi için çok önemlidir.$$,
    $$Adım 2: İlkokul çağındaki çocukların günde yaklaşık 9-11 saat uyuması önerilir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Ülkemiz$$, $$Başkent$$, 2,
  $$Türkiye'nin başkenti hangi şehirdir?$$,
  jsonb_build_object('A', $$İstanbul$$, 'B', $$İzmir$$, 'C', $$Ankara$$, 'D', $$Bursa$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Ülkemizin yönetildiği, meclisin bulunduğu şehir hangisidir?$$,
    $$Adım 1: Türkiye'nin en büyük şehri İstanbul olsa da başkenti farklıdır.$$,
    $$Adım 2: Ülkemizin başkenti Ankara'dır.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Okul Yaşamı$$, $$Okul kuralları$$, 1,
  $$Zil çaldığında ne yapmalıyız?$$,
  jsonb_build_object('A', $$Koridorda koşmalıyız$$, 'B', $$Sınıfımıza geçip yerimize oturmalıyız$$, 'C', $$Bahçeye kaçmalıyız$$, 'D', $$Bağırmalıyız$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Ders başlayacağını gösteren zil çalınca nereye gitmeliyiz?$$,
    $$Adım 1: Zil, dersin başladığını ya da bittiğini bildirir.$$,
    $$Adım 2: Ders zili çalınca sınıfa geçip yerimize otururuz.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Güvenlik$$, $$Elektrik güvenliği$$, 2,
  $$Prizle oynamak neden tehlikelidir?$$,
  jsonb_build_object('A', $$Çok eğlencelidir$$, 'B', $$Elektrik çarpabilir$$, 'C', $$Prizi bozar$$, 'D', $$Ucuzdur$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Prizde görünmeyen, bizi yaralayabilecek bir güç vardır.$$,
    $$Adım 1: Prizde elektrik akımı bulunur.$$,
    $$Adım 2: Prizle oynamak elektrik çarpmasına yol açabilir, bu çok tehlikelidir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Hayat Bilgisi$$, $$Aile ve Toplum$$, $$Nezaket sözcükleri$$, 1,
  $$Birinden bir şey isterken hangi sözcüğü kullanmalıyız?$$,
  jsonb_build_object('A', $$"Ver!"$$, 'B', $$"lütfen"$$, 'C', $$"hemen"$$, 'D', $$"çabuk"$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Nazik bir istek nasıl yapılır? Sihirli sözcük hangisidir?$$,
    $$Adım 1: İsteklerimizi nazikçe belirtmeliyiz.$$,
    $$Adım 2: Bir şey isterken "lütfen" demek nezaket gereğidir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Greetings (Selamlaşma)$$, $$Selamlaşma sözcükleri$$, 1,
  $$Sabah karşılaşan iki kişi İngilizce nasıl selamlaşır?$$,
  jsonb_build_object('A', $$Good night$$, 'B', $$Good morning$$, 'C', $$Good evening$$, 'D', $$Goodbye$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "morning" sabah anlamına gelir. Sabah söylenen selam hangisidir?$$,
    $$Adım 1: "Good morning" sabah selamıdır.$$,
    $$Adım 2: "Good night" gece ayrılırken, "Good evening" akşam söylenir.$$,
    $$Adım 3: Sabah için "Good morning" kullanılır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Colors (Renkler)$$, $$Renk adları$$, 1,
  $$"red" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$mavi$$, 'B', $$yeşil$$, 'C', $$kırmızı$$, 'D', $$sarı$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Elmaların rengini düşün. "red" hangi renktir?$$,
    $$Adım 1: "red" İngilizce'de kırmızı rengi ifade eder.$$,
    $$Adım 2: Mavi "blue", yeşil "green", sarı "yellow"dur.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Numbers (Sayılar)$$, $$1-10 arası sayılar$$, 1,
  $$"five" sayısı kaçtır?$$,
  jsonb_build_object('A', $$3$$, 'B', $$4$$, 'C', $$5$$, 'D', $$6$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "five", "four"dan sonra gelen sayıdır.$$,
    $$Adım 1: İngilizce sayılar: one, two, three, four, five...$$,
    $$Adım 2: "five" sıralamada beşinci sayıdır.$$,
    $$Adım 3: "five" = 5. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Family (Aile)$$, $$Aile üyeleri$$, 2,
  $$"mother" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$baba$$, 'B', $$anne$$, 'C', $$kardeş$$, 'D', $$dede$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "father" baba demektir. "mother" onun eşidir.$$,
    $$Adım 1: "father" baba, "mother" anne demektir.$$,
    $$Adım 2: Bu iki sözcük aile üyelerini ifade eder.$$,
    $$Adım 3: "mother" = anne. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Animals (Hayvanlar)$$, $$Hayvan adları$$, 1,
  $$"cat" hangi hayvandır?$$,
  jsonb_build_object('A', $$köpek$$, 'B', $$kedi$$, 'C', $$kuş$$, 'D', $$balık$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Miyavlayan ev hayvanının İngilizce adıdır.$$,
    $$Adım 1: "cat" evde beslenen, miyavlayan hayvandır.$$,
    $$Adım 2: Köpek "dog", kuş "bird", balık "fish"tir.$$,
    $$Adım 3: "cat" = kedi. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Classroom Objects$$, $$Sınıf nesneleri$$, 2,
  $$"book" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$defter$$, 'B', $$kitap$$, 'C', $$kalem$$, 'D', $$çanta$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Okumak için kullandığımız, sayfaları olan nesnedir.$$,
    $$Adım 1: "book" okunacak nesnedir, yani kitap.$$,
    $$Adım 2: Defter "notebook", kalem "pencil", çanta "bag"dir.$$,
    $$Adım 3: "book" = kitap. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Numbers (Sayılar)$$, $$Sayı sıralaması$$, 2,
  $$"three, four, ____, six" boşluğa hangi sayı gelir?$$,
  jsonb_build_object('A', $$two$$, 'B', $$five$$, 'C', $$seven$$, 'D', $$eight$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sayılar birer birer artıyor. "four"dan sonra, "six"ten önce hangi sayı gelir?$$,
    $$Adım 1: Sayılar üç, dört, ..., altı şeklinde birer artmaktadır.$$,
    $$Adım 2: Dörtten sonra beş gelir, sonra altı.$$,
    $$Adım 3: Boşluğa "five" (5) gelir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Greetings (Selamlaşma)$$, $$Veda$$, 1,
  $$Bir yerden ayrılırken İngilizce ne denir?$$,
  jsonb_build_object('A', $$Hello$$, 'B', $$Goodbye$$, 'C', $$Good morning$$, 'D', $$Thank you$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Hello" karşılaşınca söylenir. Ayrılırken ne söylenir?$$,
    $$Adım 1: "Hello" karşılaşma, "Goodbye" ise ayrılık sırasında söylenir.$$,
    $$Adım 2: "Thank you" teşekkür etmektir.$$,
    $$Adım 3: Ayrılırken "Goodbye" denir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Colors (Renkler)$$, $$Renk adları$$, 2,
  $$"blue" ve "yellow" renkleri karışınca hangi renk oluşur?$$,
  jsonb_build_object('A', $$kırmızı$$, 'B', $$yeşil$$, 'C', $$siyah$$, 'D', $$turuncu$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Mavi (blue) ile sarı (yellow) boyayı karıştırırsan hangi renk çıkar?$$,
    $$Adım 1: "blue" mavi, "yellow" sarı renktir.$$,
    $$Adım 2: Mavi ile sarı karışınca yeşil oluşur.$$,
    $$Adım 3: Yeşilin İngilizcesi "green"dir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$İngilizce$$, $$Introduction (Kendini tanıtma)$$, $$Ad sorma$$, 2,
  $$"What is your name?" sorusunun Türkçe anlamı hangisidir?$$,
  jsonb_build_object('A', $$Kaç yaşındasın?$$, 'B', $$Adın ne?$$, 'C', $$Nerede yaşıyorsun?$$, 'D', $$Nasılsın?$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "name" sözcüğü ad anlamına gelir.$$,
    $$Adım 1: "name" ad, "your" senin demektir.$$,
    $$Adım 2: "What is your name?" = "Senin adın ne?" sorusudur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Doğal Sayılar$$, $$Basamak değerleri$$, 1,
  $$58 sayısındaki 5 rakamının basamak değeri kaçtır?$$,
  jsonb_build_object('A', $$5$$, 'B', $$50$$, 'C', $$58$$, 'D', $$500$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: 58 sayısında 5 onlar basamağındadır. Onlar basamağındaki rakamın değeri, rakamın 10 ile çarpımıdır.$$,
    $$Adım 1: 58 sayısında 5 rakamı onlar basamağındadır.$$,
    $$Adım 2: Onlar basamağındaki bir rakamın basamak değeri, o rakamın 10 ile çarpımıdır.$$,
    $$Adım 3: 5 × 10 = 50. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Toplama$$, $$Eldeli toplama$$, 1,
  $$38 + 27 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$55$$, 'B', $$60$$, 'C', $$65$$, 'D', $$66$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Önce birlikleri topla: 8 + 7 = 15. 5 yazılır, 1 elde var. Sonra onlukları ve eldeyi topla.$$,
    $$Adım 1: Birlikleri toplarız: 8 + 7 = 15 (1 elde).$$,
    $$Adım 2: Onlukları ve eldeyi toplarız: 3 + 2 + 1 = 6.$$,
    $$Adım 3: Sonuç 65'tir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Çıkarma$$, $$Onluk bozma$$, 2,
  $$72 - 45 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$27$$, 'B', $$28$$, 'C', $$37$$, 'D', $$33$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: 2'den 5 çıkmaz. Onlar basamağından 1 onluk bozup 2'ye ekle: 12 olur. Sonra 12 - 5 yap.$$,
    $$Adım 1: 2'den 5 çıkmadığı için onlar basamağından bir onluk alırız: 12 - 5 = 7.$$,
    $$Adım 2: Onlar basamağı 7'den 6'ya düştü: 6 - 4 = 2.$$,
    $$Adım 3: Sonuç 27'dir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Çarpma$$, $$Çarpım tablosu$$, 1,
  $$4 × 6 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$20$$, 'B', $$22$$, 'C', $$24$$, 'D', $$28$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: 4 tane 6'nın toplamı: 6 + 6 + 6 + 6.$$,
    $$Adım 1: Çarpma, aynı sayının tekrar tekrar toplanmasıdır.$$,
    $$Adım 2: 4 × 6 = 6 + 6 + 6 + 6 şeklinde yazılabilir.$$,
    $$Adım 3: 6 + 6 + 6 + 6 = 24. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Çarpma$$, $$Problem çözme$$, 2,
  $$Her birinde 5 bilye olan 3 torba vardır. Toplam kaç bilye vardır?$$,
  jsonb_build_object('A', $$8$$, 'B', $$10$$, 'C', $$15$$, 'D', $$20$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: 3 torbanın her birinde 5 bilye var. 3 kez 5'i topla ya da 3 × 5 yap.$$,
    $$Adım 1: Her torbada 5 bilye, 3 torba olduğu için 3 × 5 işlemi yapılır.$$,
    $$Adım 2: 3 × 5 = 5 + 5 + 5 şeklinde hesaplanır.$$,
    $$Adım 3: 5 + 5 + 5 = 15 bilye vardır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Geometri$$, $$Kenar ve köşe$$, 1,
  $$Bir üçgenin kaç köşesi vardır?$$,
  jsonb_build_object('A', $$2$$, 'B', $$3$$, 'C', $$4$$, 'D', $$5$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Üçgenin adında kaç sayısını duyuyorsun? Adı ona göre verilmiştir.$$,
    $$Adım 1: "Üçgen" adı "üç" sözcüğünden gelir.$$,
    $$Adım 2: Bu, şeklin üç kenarı ve üç köşesi olduğunu gösterir.$$,
    $$Adım 3: Üçgenin 3 köşesi vardır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Uzunluk Ölçme$$, $$Santimetre ve metre$$, 2,
  $$1 metre kaç santimetredir?$$,
  jsonb_build_object('A', $$10$$, 'B', $$50$$, 'C', $$100$$, 'D', $$1000$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: 1 metre, cetvelle ölçtüğümüz 100 tane santimetrenin toplamına eşittir.$$,
    $$Adım 1: Uzunluk ölçmede metre ve santimetre kullanılır.$$,
    $$Adım 2: 1 metre, 100 santimetreye eşittir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Doğal Sayılar$$, $$Ritmik sayma$$, 1,
  $$5'er 5'er sayarken hangi sayı gelmez?$$,
  jsonb_build_object('A', $$10$$, 'B', $$15$$, 'C', $$22$$, 'D', $$25$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: 5'er sayarken sayıların sonu 0 ya da 5 ile biter. Hangi sayı bu kurala uymuyor?$$,
    $$Adım 1: 5'er ritmik saymada sayılar: 5, 10, 15, 20, 25... şeklindedir.$$,
    $$Adım 2: Bu sayıların birler basamağı 0 veya 5'tir.$$,
    $$Adım 3: 22 sayısının sonu 2'dir, bu yüzden gelmez. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Zaman Ölçme$$, $$Yarım saat$$, 2,
  $$Yarım saat kaç dakikadır?$$,
  jsonb_build_object('A', $$15$$, 'B', $$30$$, 'C', $$45$$, 'D', $$60$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: 1 tam saat 60 dakikadır. Yarım, ikiye bölünmüş demektir.$$,
    $$Adım 1: 1 saat 60 dakikaya eşittir.$$,
    $$Adım 2: Yarım saat, 60 dakikanın yarısıdır.$$,
    $$Adım 3: 60 ÷ 2 = 30 dakika. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Matematik$$, $$Toplama$$, $$Üç sayıyla toplama$$, 2,
  $$23 + 15 + 12 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$40$$, 'B', $$45$$, 'C', $$50$$, 'D', $$52$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Önce 23 ile 15'i topla, çıkan sonuca 12 ekle.$$,
    $$Adım 1: Önce 23 + 15 = 38 bulunur.$$,
    $$Adım 2: Sonuca üçüncü sayıyı ekleriz: 38 + 12.$$,
    $$Adım 3: 38 + 12 = 50. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Sözcükte Anlam$$, $$Eş anlamlılık$$, 1,
  $$"konuk" sözcüğünün eş anlamlısı hangisidir?$$,
  jsonb_build_object('A', $$komşu$$, 'B', $$misafir$$, 'C', $$arkadaş$$, 'D', $$aile$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Eş anlamlı sözcükler aynı anlamı taşır. Eve gelen kişilere ne denir?$$,
    $$Adım 1: "Konuk", birinin evine gelip bir süre kalan kişidir.$$,
    $$Adım 2: Bu kişiye "misafir" de denir; bu iki sözcük eş anlamlıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Sözcükte Anlam$$, $$Zıt anlamlılık$$, 1,
  $$"açık" sözcüğünün zıt anlamlısı hangisidir?$$,
  jsonb_build_object('A', $$kapalı$$, 'B', $$geniş$$, 'C', $$aydın$$, 'D', $$boş$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Zıt anlam, bir şeyin tam tersidir. Kapı açıksa karşıt hâli nedir?$$,
    $$Adım 1: "Açık" bir şeyin kapalı olmadığını anlatır.$$,
    $$Adım 2: Bunun tam tersi "kapalı"dır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Hece Bilgisi$$, $$Hece sayma$$, 1,
  $$"kelebek" sözcüğü kaç hecelidir?$$,
  jsonb_build_object('A', $$2$$, 'B', $$3$$, 'C', $$4$$, 'D', $$5$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Her sesli harf bir hecedir. Sözcükteki sesli harfleri say: e-e-e.$$,
    $$Adım 1: "kelebek" sözcüğündeki sesli harfler e, e, e'dir.$$,
    $$Adım 2: Her sesli harf bir hece oluşturur.$$,
    $$Adım 3: ke-le-bek → 3 hece. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Cümlede Anlam$$, $$Neden-sonuç$$, 2,
  $$"Yağmur yağdığı için oyun oynayamadık." cümlesinde oyun oynayamamanın nedeni nedir?$$,
  jsonb_build_object('A', $$Hava çok sıcaktı$$, 'B', $$Yağmur yağmıştı$$, 'C', $$Arkadaşlar gelmedi$$, 'D', $$Ev temizdi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "için" sözcüğünden önceki kısım nedeni gösterir. Neden gerçekleşti?$$,
    $$Adım 1: Cümlede "için" bağlacından önceki bölüm nedeni belirtir.$$,
    $$Adım 2: "Yağmur yağdığı için" ifadesi nedeni gösterir.$$,
    $$Adım 3: Oyun oynayamamanın nedeni yağmur yağmasıdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Adlar (İsimler)$$, $$Özel ad$$, 2,
  $$Aşağıdaki sözcüklerden hangisi özel addır?$$,
  jsonb_build_object('A', $$öğrenci$$, 'B', $$şehir$$, 'C', $$Ankara$$, 'D', $$okul$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Özel adlar tek bir varlığa verilen isimdir ve büyük harfle başlar.$$,
    $$Adım 1: "Öğrenci", "şehir", "okul" genel varlıkları anlatan tür adlarıdır.$$,
    $$Adım 2: "Ankara" ise tek bir şehre verilmiş özel bir addır ve büyük harfle başlar.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Yazım Kuralları$$, $$"de/da" yazımı$$, 2,
  $$Aşağıdaki cümlelerden hangisinde "de" doğru yazılmıştır?$$,
  jsonb_build_object('A', $$Ben de geleceğim.$$, 'B', $$Bende geleceğim.$$, 'C', $$Ben da geleceğim.$$, 'D', $$Bende gelecegim.$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "de/da" bağlacı ayrı yazılır. "Ben de" ifadesinde de ayrı mı bitişik mi olmalı?$$,
    $$Adım 1: "de/da" bağlacı her zaman ayrı yazılır.$$,
    $$Adım 2: "Bende" bitişik yazılmıştır, bu yanlıştır. "da" ise bağlaç değil, yanlış kullanımdır.$$,
    $$Adım 3: Doğru yazım "Ben de geleceğim." şeklindedir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Noktalama İşaretleri$$, $$Soru işareti$$, 1,
  $$"Nereye gidiyorsun" cümlesinin sonuna hangi işaret gelmelidir?$$,
  jsonb_build_object('A', $$nokta (.)$$, 'B', $$virgül (,)$$, 'C', $$soru işareti (?)$$, 'D', $$ünlem (!)$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Cümle bir bilgi vermiyor, bir soru soruyor. Soru cümlesinin sonuna ne konur?$$,
    $$Adım 1: "Nereye gidiyorsun" cümlesi bir soru sormaktadır.$$,
    $$Adım 2: Soru anlamı taşıyan cümlelerin sonuna soru işareti konur.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Sözcükte Anlam$$, $$Sesteş sözcükler$$, 2,
  $$"Gül" sözcüğü hangi cümlede çiçek anlamında kullanılmıştır?$$,
  jsonb_build_object('A', $$Bahçedeki gül çok güzel kokuyor.$$, 'B', $$Arkadaşım bana bakıp güldü.$$, 'C', $$O olaya hepimiz güldük.$$, 'D', $$Çocuk neşeyle güldü.$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "Gül" iki anlama gelebilir: bir çiçek ya da gülme eylemi. Çiçek anlamı hangisinde?$$,
    $$Adım 1: B, C ve D seçeneklerinde "gülmek" eylemi anlatılmaktadır.$$,
    $$Adım 2: A seçeneğinde ise kokusu olan bir çiçekten söz edilmektedir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Harf Bilgisi$$, $$Ünlü ve ünsüz harfler$$, 1,
  $$Alfabemizde kaç harf vardır?$$,
  jsonb_build_object('A', $$26$$, 'B', $$28$$, 'C', $$29$$, 'D', $$30$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Türk alfabesindeki harf sayısını düşün: 8 sesli, 21 sessiz.$$,
    $$Adım 1: Türk alfabesinde 8 sesli, 21 sessiz harf bulunur.$$,
    $$Adım 2: 8 + 21 = 29 eder.$$,
    $$Adım 3: Alfabemizde 29 harf vardır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 2, $$Türkçe$$, $$Yazım Kuralları$$, $$"-ki" ekinin yazımı$$, 3,
  $$Aşağıdaki cümlelerden hangisinde "-ki" doğru yazılmıştır?$$,
  jsonb_build_object('A', $$Sen ki geleceksin.$$, 'B', $$Benim ki çok güzel.$$, 'C', $$Benimki çok güzel.$$, 'D', $$Sen ki çok iyisin.$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "-ki" eki, sözcüğün sonuna eklenirken bitişik yazılır. "Benim" sözcüğüne eklenirse nasıl yazılır?$$,
    $$Adım 1: "Benimki" sözcüğünde "-ki" aitlik eki olarak sözcüğe bitişik yazılmıştır ve doğrudur.$$,
    $$Adım 2: "Benim ki" ayrı yazımı yanlıştır; bu eki başka sözcükten ayırmayız.$$,
    $$Adım 3: "Sen ki" yazımında ise burada bir bağlaç değil ek gerektiğinden ayrı yazım yanlıştır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Duyu Organları$$, $$Duyuların işlevi$$, 1,
  $$Koku almak için hangi duyu organımızı kullanırız?$$,
  jsonb_build_object('A', $$göz$$, 'B', $$kulak$$, 'C', $$burun$$, 'D', $$dil$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Çiçeğin kokusunu hangi organımızla hissederiz?$$,
    $$Adım 1: Göz görme, kulak duyma, dil tatma organımızdır.$$,
    $$Adım 2: Koku alma organı burundur.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Canlılar$$, $$Canlı-cansız ayrımı$$, 1,
  $$Aşağıdakilerden hangisi canlıdır?$$,
  jsonb_build_object('A', $$taş$$, 'B', $$ağaç$$, 'C', $$masa$$, 'D', $$su$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Canlılar büyür, beslenir ve çoğalır. Hangisi büyüyebilir?$$,
    $$Adım 1: Taş, masa ve su cansızdır; büyümez ve beslenmez.$$,
    $$Adım 2: Ağaç büyür, su ve besin alır, bu yüzden canlıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Madde$$, $$Maddenin halleri$$, 2,
  $$Suyun katı hâli nedir?$$,
  jsonb_build_object('A', $$buhar$$, 'B', $$buz$$, 'C', $$yağmur$$, 'D', $$nem$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Su donunca neye dönüşür?$$,
    $$Adım 1: Suyun gaz hâli buhar, sıvı hâli sudur.$$,
    $$Adım 2: Su donduğunda katı hâle yani buza dönüşür.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Işık$$, $$Işık kaynakları$$, 1,
  $$Aşağıdakilerden hangisi doğal ışık kaynağıdır?$$,
  jsonb_build_object('A', $$ampul$$, 'B', $$güneş$$, 'C', $$mum$$, 'D', $$el feneri$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Doğal ışık kaynakları insan yapımı değildir. Hangisi kendiliğinden ışık verir?$$,
    $$Adım 1: Ampul, mum ve el feneri insan yapımıdır (yapay kaynak).$$,
    $$Adım 2: Güneş kendiliğinden ışık veren doğal bir kaynaktır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Ses$$, $$Ses kaynağı$$, 1,
  $$Ses nasıl oluşur?$$,
  jsonb_build_object('A', $$Isı ile$$, 'B', $$Titreşim ile$$, 'C', $$Işık ile$$, 'D', $$Renk ile$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir gitar telini çekip bıraktığında tel titrer ve ses çıkar.$$,
    $$Adım 1: Sesin oluşması için bir kaynağın titremesi gerekir.$$,
    $$Adım 2: Titreşim sonucu ses oluşur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Kuvvet ve Hareket$$, $$İtme ve çekme$$, 2,
  $$Bir kapıyı kendimize doğru açmak hangi kuvvet uygulamasıdır?$$,
  jsonb_build_object('A', $$itme$$, 'B', $$çekme$$, 'C', $$döndürme$$, 'D', $$sallama$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kapıyı kendine doğru açarken onu kendine yaklaştırırsın. Bu itmek mi çekmek mi?$$,
    $$Adım 1: Kuvvet uygulayarak cisimler itilebilir ya da çekilebilir.$$,
    $$Adım 2: Kapıyı kendimize doğru açarken onu çekeriz.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Çevre$$, $$Geri dönüşüm$$, 2,
  $$Aşağıdakilerden hangisi geri dönüştürülebilir?$$,
  jsonb_build_object('A', $$plastik şişe$$, 'B', $$yemek artığı$$, 'C', $$kullanılmış peçete$$, 'D', $$bozuk yumurta$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Geri dönüşüm kutusuna atılabilecek, temiz ve yeniden kullanılabilir malzeme hangisidir?$$,
    $$Adım 1: Plastik, cam, kâğıt ve metal geri dönüştürülebilen malzemelerdir.$$,
    $$Adım 2: Yemek artığı, kullanılmış peçete ve bozuk yumurta geri dönüştürülemez.$$,
    $$Adım 3: Plastik şişe geri dönüştürülebilir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Duyu Organları$$, $$Duyu ve sağlık$$, 2,
  $$Aşırı yüksek sesle müzik dinlemek en çok hangi duyu organımıza zarar verir?$$,
  jsonb_build_object('A', $$göz$$, 'B', $$kulak$$, 'C', $$burun$$, 'D', $$deri$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sesle ilgili duyu organımız hangisidir?$$,
    $$Adım 1: Sesleri kulaklarımızla duyarız.$$,
    $$Adım 2: Aşırı yüksek ses kulak sağlığına zarar verir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Canlılar$$, $$Bitkilerin büyümesi$$, 2,
  $$Bir bitkinin büyümek için ihtiyaç duyduğu şeylerden biri hangisidir?$$,
  jsonb_build_object('A', $$karanlık$$, 'B', $$güneş ışığı$$, 'C', $$tuz$$, 'D', $$buz$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bitkiler fotosentez için hangi doğal kaynağa ihtiyaç duyar?$$,
    $$Adım 1: Bitkiler büyümek için su, hava ve besin maddelerine ihtiyaç duyar.$$,
    $$Adım 2: Fotosentez için güneş ışığına da ihtiyaçları vardır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Fen Bilimleri$$, $$Madde$$, $$Maddenin özellikleri$$, 3,
  $$Aşağıdakilerden hangisi maddenin hâllerinden biri **değildir**?$$,
  jsonb_build_object('A', $$katı$$, 'B', $$sıvı$$, 'C', $$gaz$$, 'D', $$ışık$$),
  'D',
  to_jsonb(ARRAY[
    $$İpucu: Maddenin üç hâli vardır. Hangisi madde hâli değil?$$,
    $$Adım 1: Maddenin katı, sıvı ve gaz olmak üzere üç hâli vardır.$$,
    $$Adım 2: Işık bir madde hâli değildir; bir enerji türüdür.$$,
    $$Adım 3: Doğru cevap D seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$Okul Yaşamı$$, $$Grup çalışması$$, 1,
  $$Grup çalışmasında başarılı olmak için ne yapmalıyız?$$,
  jsonb_build_object('A', $$Herkes kendi bildiğini yapmalı$$, 'B', $$Birlikte plan yapıp iş bölümü yapmalıyız$$, 'C', $$Sadece en iyi öğrenci çalışmalı$$, 'D', $$Kimse konuşmamalı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Grup çalışmasında herkesin bir görevi olursa daha kolay başarıya ulaşılır.$$,
    $$Adım 1: Grup çalışmasında birlikte hareket etmek önemlidir.$$,
    $$Adım 2: Plan yapıp görevleri paylaşmak başarıyı getirir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$Sağlıklı Yaşam$$, $$Hastalıklardan korunma$$, 2,
  $$Hastalanmamak için aşağıdakilerden hangisini yapmalıyız?$$,
  jsonb_build_object('A', $$Açıkta satılan yiyecekleri yemek$$, 'B', $$Düzenli spor yapmak ve dengeli beslenmek$$, 'C', $$Çok az su içmek$$, 'D', $$Geç saatlere kadar uyanık kalmak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sağlıklı olmak için vücudumuza iyi bakmamız gerekir: hareket ve doğru beslenme.$$,
    $$Adım 1: Düzenli spor ve dengeli beslenme vücudu güçlendirir.$$,
    $$Adım 2: Açıkta satılan yiyecekler, az su içmek ve az uyku ise sağlığa zararlıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$Güvenlik$$, $$Trafik kuralları$$, 1,
  $$Trafik ışığında yayalar hangi renkte karşıya geçer?$$,
  jsonb_build_object('A', $$kırmızı$$, 'B', $$sarı$$, 'C', $$yeşil$$, 'D', $$mavi$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Kırmızı "dur" demektir. Hangi renk "geç" anlamına gelir?$$,
    $$Adım 1: Trafik ışıklarında kırmızı "dur", sarı "hazırlan" demektir.$$,
    $$Adım 2: Yeşil ışık yayaların karşıya geçebileceğini gösterir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$Ülkemiz$$, $$Millî değerler$$, 2,
  $$23 Nisan hangi bayram olarak kutlanır?$$,
  jsonb_build_object('A', $$Cumhuriyet Bayramı$$, 'B', $$Ulusal Egemenlik ve Çocuk Bayramı$$, 'C', $$Zafer Bayramı$$, 'D', $$Gençlik ve Spor Bayramı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bu bayram çocuklara armağan edilmiş dünyada eşsiz bir bayramdır.$$,
    $$Adım 1: 23 Nisan, TBMM'nin açıldığı gündür.$$,
    $$Adım 2: Bu gün Ulusal Egemenlik ve Çocuk Bayramı olarak kutlanır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$İletişim$$, $$Etkili iletişim$$, 2,
  $$Konuşan birini dinlerken ne yapmalıyız?$$,
  jsonb_build_object('A', $$Sözünü kesmeliyiz$$, 'B', $$Göz teması kurup sonuna kadar dinlemeliyiz$$, 'C', $$Başka şeylerle ilgilenmeliyiz$$, 'D', $$Yüksek sesle konuşmalıyız$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İyi bir dinleyici, karşısındakinin sözünü kesmez ve ona dikkat eder.$$,
    $$Adım 1: Etkili iletişim için karşıdakini dikkatle dinlemek gerekir.$$,
    $$Adım 2: Göz teması kurmak ve sözünü kesmemek doğru davranıştır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$Doğa ve Çevre$$, $$Su tasarrufu$$, 2,
  $$Suyu tasarruflu kullanmak için ne yapmalıyız?$$,
  jsonb_build_object('A', $$Diş fırçalarken musluğu açık bırakmak$$, 'B', $$Diş fırçalarken musluğu kapatmak$$, 'C', $$Suyu boşa akıtmak$$, 'D', $$Kullanılmış suyu içmek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Su kaynağı sınırsız değildir. Kullanmadığımız anda musluk ne olmalı?$$,
    $$Adım 1: Su tasarrufu, suyu gereksiz yere harcamamaktır.$$,
    $$Adım 2: Diş fırçalarken musluğu kapatmak suyu korur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$Aile ve Toplum$$, $$Komşuluk ilişkileri$$, 2,
  $$Komşularımıza karşı nasıl davranmalıyız?$$,
  jsonb_build_object('A', $$Gürültü yapmalıyız$$, 'B', $$Saygılı ve yardımcı olmalıyız$$, 'C', $$Onları görmezden gelmeliyiz$$, 'D', $$Kapılarını çalıp kaçmalıyız$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İyi komşuluk ilişkileri karşılıklı saygı ve yardımlaşma ile olur.$$,
    $$Adım 1: Komşularımızla iyi geçinmek toplumsal huzuru sağlar.$$,
    $$Adım 2: Onlara saygılı davranmak ve yardım etmek doğrudur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$Okul Yaşamı$$, $$Okulda güvenlik$$, 1,
  $$Okul koridorunda koşmak neden tehlikelidir?$$,
  jsonb_build_object('A', $$Yorucudur$$, 'B', $$Çarpışıp düşebiliriz$$, 'C', $$Ses çıkarır$$, 'D', $$Zaman kaybettirir$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Koridorda başkaları da yürür. Hızlı koşmak başkalarına çarpmaya neden olabilir.$$,
    $$Adım 1: Koridorlarda başka öğrenciler de bulunur.$$,
    $$Adım 2: Koşarken çarpışıp yaralanabiliriz.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$Sağlıklı Yaşam$$, $$Kişisel bakım$$, 1,
  $$Aşağıdakilerden hangisi kişisel bakıma örnektir?$$,
  jsonb_build_object('A', $$Oyun oynamak$$, 'B', $$Dişlerimizi düzenli fırçalamak$$, 'C', $$Televizyon izlemek$$, 'D', $$Resim yapmak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kişisel bakım, vücudumuzun temizliğiyle ilgilidir.$$,
    $$Adım 1: Kişisel bakım, vücut temizliği ve sağlığı için yapılanlardır.$$,
    $$Adım 2: Diş fırçalamak kişisel bakımın bir parçasıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Hayat Bilgisi$$, $$Ülkemiz$$, $$Yönetim$$, 3,
  $$Ülkemizde seçme ve seçilme hakkı hangi yönetim biçiminin gereğidir?$$,
  jsonb_build_object('A', $$monarşi$$, 'B', $$cumhuriyet$$, 'C', $$krallık$$, 'D', $$padişahlık$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Halkın kendi yöneticilerini oyla seçtiği yönetim biçimi hangisidir?$$,
    $$Adım 1: Cumhuriyette yönetim halkın seçtiği kişilerce yürütülür.$$,
    $$Adım 2: Seçme ve seçilme hakkı cumhuriyet yönetiminin temelidir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Greetings$$, $$Nasılsın$$, 1,
  $$"How are you?" sorusuna uygun cevap hangisidir?$$,
  jsonb_build_object('A', $$I am fine, thank you.$$, 'B', $$Good night.$$, 'C', $$My name is Ali.$$, 'D', $$Goodbye.$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "How are you?" "Nasılsın?" demektir. Buna karşılık nasıl cevap verilir?$$,
    $$Adım 1: "How are you?" nasıl olduğumuzu sorar.$$,
    $$Adım 2: Buna "I am fine, thank you." (İyiyim, teşekkürler.) diye cevap verilir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Numbers$$, $$1-20 arası sayılar$$, 1,
  $$"ten" sayısı kaçtır?$$,
  jsonb_build_object('A', $$8$$, 'B', $$9$$, 'C', $$10$$, 'D', $$11$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "nine" 9 demektir. Ondan sonra gelen sayı hangisidir?$$,
    $$Adım 1: İngilizce sayılar: ...eight, nine, ten...$$,
    $$Adım 2: "ten" sayısı 10'dur.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Body Parts$$, $$Vücut bölümleri$$, 2,
  $$"eye" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$kulak$$, 'B', $$göz$$, 'C', $$burun$$, 'D', $$ağız$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Görmemizi sağlayan organın İngilizce adıdır. İki tanedir.$$,
    $$Adım 1: "eye" görme organımızdır, yani gözdür.$$,
    $$Adım 2: Kulak "ear", burun "nose", ağız "mouth"tur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Family$$, $$Aile üyeleri$$, 2,
  $$"sister" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$abla/kız kardeş$$, 'B', $$ağabey/erkek kardeş$$, 'C', $$anne$$, 'D', $$teyze$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "brother" erkek kardeş demektir. "sister" ise kız kardeştir.$$,
    $$Adım 1: "brother" erkek kardeş, "sister" kız kardeş demektir.$$,
    $$Adım 2: Bu iki sözcük kardeşleri ifade eder.$$,
    $$Adım 3: "sister" = kız kardeş/abla. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Colors$$, $$Renkler$$, 1,
  $$"green" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$sarı$$, 'B', $$yeşil$$, 'C', $$mavi$$, 'D', $$beyaz$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Çimenlerin ve yaprakların rengidir.$$,
    $$Adım 1: "green" doğadaki yaprakların rengidir.$$,
    $$Adım 2: Sarı "yellow", mavi "blue", beyaz "white"tır.$$,
    $$Adım 3: "green" = yeşil. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Animals$$, $$Hayvanlar$$, 2,
  $$"bird" hangi hayvandır?$$,
  jsonb_build_object('A', $$balık$$, 'B', $$kuş$$, 'C', $$at$$, 'D', $$inek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Uçabilen hayvanların İngilizce adıdır.$$,
    $$Adım 1: "bird" uçabilen bir hayvandır, yani kuş.$$,
    $$Adım 2: Balık "fish", at "horse", inek "cow"dur.$$,
    $$Adım 3: "bird" = kuş. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Numbers$$, $$Sayı sıralaması$$, 2,
  $$"eleven, twelve, ____, fourteen" boşluğa hangi sayı gelir?$$,
  jsonb_build_object('A', $$ten$$, 'B', $$thirteen$$, 'C', $$fifteen$$, 'D', $$sixteen$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sayılar birer artıyor: 11, 12, ..., 14. Aradaki sayı hangisidir?$$,
    $$Adım 1: Sayılar 11, 12, ..., 14 şeklinde birer artmaktadır.$$,
    $$Adım 2: 12'den sonra 13 gelir.$$,
    $$Adım 3: "thirteen" (13) boşluğa gelir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Food$$, $$Yiyecek adları$$, 2,
  $$"bread" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$su$$, 'B', $$süt$$, 'C', $$ekmek$$, 'D', $$peynir$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Kahvaltıda yediğimiz temel gıdanın İngilizce adıdır.$$,
    $$Adım 1: "bread" ekmek demektir.$$,
    $$Adım 2: Su "water", süt "milk", peynir "cheese"tir.$$,
    $$Adım 3: "bread" = ekmek. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Greetings$$, $$Tanışma$$, 1,
  $$"Hello! My name is Ayşe." cümlesinde kişi ne yapmaktadır?$$,
  jsonb_build_object('A', $$veda ediyor$$, 'B', $$kendini tanıtıyor$$, 'C', $$yemek yiyor$$, 'D', $$sayı sayıyor$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "My name is..." "Benim adım..." demektir. Bu bir tanışma ifadesidir.$$,
    $$Adım 1: "My name is Ayşe." cümlesi kişinin adını söylediğini gösterir.$$,
    $$Adım 2: Bu, kendini tanıtma ifadesidir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$İngilizce$$, $$Classroom Objects$$, $$Sınıf nesneleri$$, 2,
  $$"pencil" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$silgi$$, 'B', $$kalem$$, 'C', $$cetvel$$, 'D', $$defter$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Yazı yazmak için kullandığımız aracın İngilizce adıdır.$$,
    $$Adım 1: "pencil" yazı yazma aracıdır, yani kurşun kalem.$$,
    $$Adım 2: Silgi "eraser", cetvel "ruler", defter "notebook"tur.$$,
    $$Adım 3: "pencil" = kalem. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Doğal Sayılar$$, $$Üç basamaklı sayılar$$, 1,
  $$"Dört yüz yirmi beş" sayısı hangisidir?$$,
  jsonb_build_object('A', $$425$$, 'B', $$452$$, 'C', $$4205$$, 'D', $$245$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Yüzler, onlar ve birler basamağını sırayla yaz: 4, 2, 5.$$,
    $$Adım 1: "Dört yüz" = 400 (yüzler basamağı 4).$$,
    $$Adım 2: "yirmi" = 20 (onlar basamağı 2), "beş" = 5 (birler basamağı 5).$$,
    $$Adım 3: Sayı 425'tir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Doğal Sayılar$$, $$Sayı karşılaştırma$$, 1,
  $$Aşağıdaki sayılardan en küçüğü hangisidir?$$,
  jsonb_build_object('A', $$342$$, 'B', $$324$$, 'C', $$432$$, 'D', $$243$$),
  'D',
  to_jsonb(ARRAY[
    $$İpucu: Önce yüzler basamağına bak. Yüzler basamağı küçük olan daha küçüktür.$$,
    $$Adım 1: Yüzler basamaklarına bakalım: 3, 3, 4, 2.$$,
    $$Adım 2: En küçük yüzler basamağı 2'dir (243).$$,
    $$Adım 3: 243 en küçük sayıdır. Doğru cevap D seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Toplama$$, $$Eldeli toplama$$, 2,
  $$247 + 156 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$393$$, 'B', $$403$$, 'C', $$413$$, 'D', $$303$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Birliklerden başla: 7 + 6 = 13. Onlar: 4 + 5 + 1 = 10. Yüzler: 2 + 1 + 1.$$,
    $$Adım 1: Birlikler: 7 + 6 = 13 → 3 yazılır, 1 elde.$$,
    $$Adım 2: Onlar: 4 + 5 + 1 = 10 → 0 yazılır, 1 elde.$$,
    $$Adım 3: Yüzler: 2 + 1 + 1 = 4. Sonuç 403. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Çıkarma$$, $$Eldeli çıkarma$$, 2,
  $$500 - 236 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$264$$, 'B', $$274$$, 'C', $$364$$, 'D', $$254$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Sıfırdan 6 çıkmaz, komşudan onluk bozarak çıkar.$$,
    $$Adım 1: 0'dan 6 çıkmaz; yüzlerden onluk bozarak ilerleriz.$$,
    $$Adım 2: 10 - 6 = 4; ardından onlar ve yüzler basamağı düzenlenir: 490 → 236.$$,
    $$Adım 3: 500 - 236 = 264. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Çarpma$$, $$İki basamaklı çarpma$$, 2,
  $$23 × 4 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$82$$, 'B', $$88$$, 'C', $$92$$, 'D', $$96$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Önce 20 × 4, sonra 3 × 4 hesapla ve topla.$$,
    $$Adım 1: 20 × 4 = 80 bulunur.$$,
    $$Adım 2: 3 × 4 = 12 bulunur.$$,
    $$Adım 3: 80 + 12 = 92. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Bölme$$, $$Kalansız bölme$$, 2,
  $$48 ÷ 6 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$6$$, 'B', $$7$$, 'C', $$8$$, 'D', $$9$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "6 kere kaç 48 eder?" diye düşün. 6 × 8 kaçtır?$$,
    $$Adım 1: Bölme, çarpmanın tersidir.$$,
    $$Adım 2: 6 × 8 = 48 olduğuna göre 48 ÷ 6 = 8'dir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Kesirler$$, $$Basit kesir$$, 2,
  $$Bir bütünün 4 eşit parçasından 3'ünü gösteren kesir hangisidir?$$,
  jsonb_build_object('A', $$3/4$$, 'B', $$4/3$$, 'C', $$1/3$$, 'D', $$3/3$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Pay (üstteki sayı) alınan parça, payda (alttaki) toplam parça sayısıdır.$$,
    $$Adım 1: Bütün 4 eşit parçaya ayrılmıştır, yani payda 4'tür.$$,
    $$Adım 2: Bunlardan 3'ü alınmıştır, yani pay 3'tür.$$,
    $$Adım 3: Kesir 3/4'tür. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Geometri$$, $$Açılar$$, 2,
  $$Dik açının ölçüsü kaç derecedir?$$,
  jsonb_build_object('A', $$45$$, 'B', $$60$$, 'C', $$90$$, 'D', $$180$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Kitabın köşesi gibi "L" şeklinde olan açı dik açıdır.$$,
    $$Adım 1: Dik açı, birbirine dik iki doğrunun oluşturduğu açıdır.$$,
    $$Adım 2: Bu açının ölçüsü 90 derecedir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Problemler$$, $$Para problemi$$, 3,
  $$Bir kalem 15 lira, bir defter 25 liradır. 2 kalem ve 1 defter alan biri kaç lira öder?$$,
  jsonb_build_object('A', $$40$$, 'B', $$45$$, 'C', $$55$$, 'D', $$65$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Önce 2 kalemin fiyatını bul (15 × 2), sonra defteri ekle.$$,
    $$Adım 1: 2 kalem: 15 × 2 = 30 lira.$$,
    $$Adım 2: 1 defter: 25 lira.$$,
    $$Adım 3: Toplam: 30 + 25 = 55 lira. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Matematik$$, $$Ölçme$$, $$Tartma$$, 2,
  $$1 kilogram kaç gramdır?$$,
  jsonb_build_object('A', $$10$$, 'B', $$100$$, 'C', $$1000$$, 'D', $$10000$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Kilogram, gramın 1000 katıdır.$$,
    $$Adım 1: Ağırlık ölçmede gram ve kilogram kullanılır.$$,
    $$Adım 2: 1 kilogram = 1000 gram.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Sözcükte Anlam$$, $$Mecaz anlam$$, 2,
  $$"Çocuk, annesinin sözlerine çok **kırıldı**." cümlesinde "kırılmak" sözcüğü hangi anlamda kullanılmıştır?$$,
  jsonb_build_object('A', $$gerçek anlam$$, 'B', $$mecaz anlam$$, 'C', $$terim anlam$$, 'D', $$eş anlam$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Kırılmak" bir cam için gerçek, bir insanın duygusu için mecaz anlamdır. Burada çocuk mu kırıldı, gönlü mü?$$,
    $$Adım 1: Gerçek anlamda "kırılmak", bir cismin parçalanmasıdır.$$,
    $$Adım 2: Burada çocuğun gönlü (duygusu) incinmiştir, cisim kırılmamıştır.$$,
    $$Adım 3: Bu kullanım mecaz anlamdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Sözcükte Anlam$$, $$Terim anlam$$, 3,
  $$"Üçgenin **kenar** uzunlukları eşittir." cümlesinde "kenar" sözcüğü hangi anlamda kullanılmıştır?$$,
  jsonb_build_object('A', $$gerçek anlam$$, 'B', $$mecaz anlam$$, 'C', $$terim anlam$$, 'D', $$deyim$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "Kenar" burada bir matematik kavramını ifade ediyor. Bir bilim dalına özgü anlamlar terim anlamdır.$$,
    $$Adım 1: "Kenar" sözcüğü burada geometrideki kenarı ifade etmektedir.$$,
    $$Adım 2: Bir bilim veya sanat dalına özgü anlama terim anlam denir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Deyimler$$, $$Deyimin anlamı$$, 2,
  $$"Ağzı kulaklarına varmak" deyiminin anlamı nedir?$$,
  jsonb_build_object('A', $$Çok üzülmek$$, 'B', $$Çok sevinmek$$, 'C', $$Çok korkmak$$, 'D', $$Çok yorulmak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İnsan çok sevinince yüzünde nasıl bir ifade olur? Gülümsemek ağzı nasıl gösterir?$$,
    $$Adım 1: "Ağzı kulaklarına varmak", gülümsemenin çok geniş olmasıdır.$$,
    $$Adım 2: Bu durum, kişinin çok sevindiğini gösterir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Cümlede Anlam$$, $$Amaç-sonuç$$, 3,
  $$"Sınavı kazanmak **için** çok çalıştı." cümlesinde çalışmanın amacı nedir?$$,
  jsonb_build_object('A', $$Yorulmak$$, 'B', $$Sınavı kazanmak$$, 'C', $$Oyun oynamak$$, 'D', $$Uyumak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "için" sözcüğünden önceki kısım amacı gösterir.$$,
    $$Adım 1: "için" edatı amaç ilişkisi kurar.$$,
    $$Adım 2: "Sınavı kazanmak için" ifadesi amacı belirtir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Sıfatlar$$, $$Sıfatı tanıma$$, 2,
  $$"Kırmızı elbiseyi giydi." cümlesinde sıfat (ön ad) hangi sözcüktür?$$,
  jsonb_build_object('A', $$elbiseyi$$, 'B', $$kırmızı$$, 'C', $$giydi$$, 'D', $$kırmızı elbise$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sıfat, ismin önüne gelip onu niteleyen ya da belirten sözcüktür. Burada ismin önündeki sözcük hangisi?$$,
    $$Adım 1: "elbise" bir isimdir.$$,
    $$Adım 2: Onun önüne gelip rengini belirten "kırmızı" sözcüğü sıfattır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Yazım Kuralları$$, $$Büyük harf kullanımı$$, 2,
  $$Aşağıdaki cümlelerden hangisinde büyük harf doğru kullanılmıştır?$$,
  jsonb_build_object('A', $$Bu yaz ankara'ya gideceğiz.$$, 'B', $$Bu yaz Ankara'ya gideceğiz.$$, 'C', $$Bu Yaz Ankara'ya gideceğiz.$$, 'D', $$bu yaz ankara'ya gideceğiz.$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Şehir adları özel addır ve büyük harfle başlar; cümle de büyük harfle başlar.$$,
    $$Adım 1: Cümle başında ilk harf büyük olmalıdır.$$,
    $$Adım 2: Şehir adı "Ankara" bir özel ad olduğu için büyük harfle başlar.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Noktalama İşaretleri$$, $$Virgül$$, 2,
  $$"Elma armut ve çilek aldım." cümlesinde "armut"tan sonra hangi işaret gelmelidir?$$,
  jsonb_build_object('A', $$nokta$$, 'B', $$virgül$$, 'C', $$soru işareti$$, 'D', $$ünlem$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sıralanan sözcükler arasına konan işaret hangisidir? Elma, armut, çilek...$$,
    $$Adım 1: Cümlede meyveler sıralanmıştır: elma, armut, çilek.$$,
    $$Adım 2: Sıralı sözcükler arasına virgül konur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Sözcükte Anlam$$, $$Eş anlamlılık$$, 1,
  $$"hekim" sözcüğünün eş anlamlısı hangisidir?$$,
  jsonb_build_object('A', $$hasta$$, 'B', $$doktor$$, 'C', $$hemşire$$, 'D', $$eczacı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Hekim" hastaları tedavi eden kişidir. Bunun diğer adı nedir?$$,
    $$Adım 1: "Hekim", hastalıkları tedavi eden kişidir.$$,
    $$Adım 2: Bu kişiye "doktor" da denir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Atasözleri$$, $$Atasözü anlamı$$, 3,
  $$"Damlaya damlaya göl olur." atasözü bize ne anlatır?$$,
  jsonb_build_object('A', $$Suyun çok olduğunu$$, 'B', $$Küçük birikimlerin zamanla büyüdüğünü$$, 'C', $$Göllerin derin olduğunu$$, 'D', $$Yağmurun faydasız olduğunu$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir damla su küçük ama sürekli birikince ne olur? Bu atasözü tutumlu olmayı anlatır.$$,
    $$Adım 1: Bir damla su tek başına azdır.$$,
    $$Adım 2: Ancak sürekli biriktiğinde göl oluşur, yani büyük bir şey ortaya çıkar.$$,
    $$Adım 3: Küçük birikimler zamanla büyür. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 3, $$Türkçe$$, $$Cümlede Anlam$$, $$Karşılaştırma$$, 2,
  $$"Ali, Veli'den daha uzundur." cümlesinde kim daha uzundur?$$,
  jsonb_build_object('A', $$Ali$$, 'B', $$Veli$$, 'C', $$İkisi eşit$$, 'D', $$Bilgi yok$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "daha uzun" ifadesi karşılaştırma yapar. Kim, kimden daha uzun deniyor?$$,
    $$Adım 1: Cümle Ali ile Veli'yi boyca karşılaştırmaktadır.$$,
    $$Adım 2: "Ali, Veli'den daha uzundur" denmektedir.$$,
    $$Adım 3: Buna göre Ali daha uzundur. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Ahlak ve Değerler$$, $$Doğruluk$$, 1,
  $$Doğru sözlü olmak bize ne kazandırır?$$,
  jsonb_build_object('A', $$Güven$$, 'B', $$Korku$$, 'C', $$Yalnızlık$$, 'D', $$Üzüntü$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Hep doğruyu söyleyen birine çevresi nasıl yaklaşır?$$,
    $$Adım 1: Doğru sözlü kişiye herkes güvenir.$$,
    $$Adım 2: Güven, sağlam ilişkilerin temelidir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Temel Değerler$$, $$Yardımlaşma$$, 1,
  $$Yardıma ihtiyacı olan birine yardım etmek hangi değerle ilgilidir?$$,
  jsonb_build_object('A', $$kıskançlık$$, 'B', $$yardımseverlik$$, 'C', $$bencillik$$, 'D', $$kibir$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Başkasına el uzatmak hangi güzel davranıştır?$$,
    $$Adım 1: Yardım eden kişi yardımseverdir.$$,
    $$Adım 2: Yardımseverlik güzel bir ahlaki değerdir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Ahlak ve Değerler$$, $$Sabır$$, 2,
  $$Zor bir işi bitirmek için beklemek ve dayanmak hangi değerdir?$$,
  jsonb_build_object('A', $$sabır$$, 'B', $$öfke$$, 'C', $$korku$$, 'D', $$acele$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Güçlükler karşısında dayanma ve bekleme yeteneğine ne denir?$$,
    $$Adım 1: Zorluklara dayanma ve bekleme yeteneğine sabır denir.$$,
    $$Adım 2: Sabır, güzel bir ahlaki davranıştır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Aile Değerleri$$, $$Büyüklere saygı$$, 1,
  $$Aile büyüklerimize nasıl davranmalıyız?$$,
  jsonb_build_object('A', $$Saygılı ve sevgiyle$$, 'B', $$Saygısızca$$, 'C', $$Umursamadan$$, 'D', $$Sert bir şekilde$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Büyüklerimiz bizim için tecrübeli kişilerdir; onlara nasıl davranılır?$$,
    $$Adım 1: Aile büyüklerimiz saygıyı hak eder.$$,
    $$Adım 2: Onlara sevgi ve saygıyla davranmalıyız.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Temel Değerler$$, $$Paylaşma$$, 2,
  $$Yiyeceğimizi arkadaşımızla paylaşmak bize ne öğretir?$$,
  jsonb_build_object('A', $$Cimrilik$$, 'B', $$Paylaşmayı ve cömertliği$$, 'C', $$Kıskançlığı$$, 'D', $$Yalnızlığı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Paylaşan kişi hangi güzel davranışı gösterir?$$,
    $$Adım 1: Paylaşmak, elindekini başkasıyla bölüşmektir.$$,
    $$Adım 2: Bu davranış cömertlik ve paylaşmayı öğretir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Çevre Bilinci$$, $$Doğa sevgisi$$, 2,
  $$Doğayı korumak için aşağıdakilerden hangisi doğrudur?$$,
  jsonb_build_object('A', $$Ağaçları kesmek$$, 'B', $$Ağaç dikmek ve çevreyi temiz tutmak$$, 'C', $$Yerlere çöp atmak$$, 'D', $$Hayvanlara zarar vermek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Doğa bize emanettir; onu korumak için yapıcı davranışlar gerekir.$$,
    $$Adım 1: Doğa, tüm canlıların ortak yaşam alanıdır.$$,
    $$Adım 2: Ağaç dikmek ve çevreyi temiz tutmak doğayı korur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Ahlak ve Değerler$$, $$Dürüstlük$$, 2,
  $$Yere düşürdüğümüz bir parayı sahibine geri vermek hangi değerdir?$$,
  jsonb_build_object('A', $$dürüstlük$$, 'B', $$tembellik$$, 'C', $$kıskançlık$$, 'D', $$kibir$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Doğru olanı yapmak, emanete sahip çıkmak hangi değerle ilgilidir?$$,
    $$Adım 1: Bulunan bir şeyi sahibine vermek dürüstlüktür.$$,
    $$Adım 2: Dürüstlük, güvenilir bir insan olmanın gereğidir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Aile Değerleri$$, $$Kardeşlik ve sevgi$$, 1,
  $$Kardeşimizle iyi geçinmek için ne yapmalıyız?$$,
  jsonb_build_object('A', $$Sürekli kavga etmeliyiz$$, 'B', $$Sevgi ve hoşgörü göstermeliyiz$$, 'C', $$Onu görmezden gelmeliyiz$$, 'D', $$Eşyalarını izinsiz almalıyız$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sevgi ve hoşgörü, aile içi huzurun anahtarıdır.$$,
    $$Adım 1: Kardeşler arasında sevgi ve hoşgörü olmalıdır.$$,
    $$Adım 2: Bu davranış aile içinde huzur sağlar.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Temel Değerler$$, $$Hoşgörü$$, 3,
  $$Hoşgörülü olmak ne anlama gelir?$$,
  jsonb_build_object('A', $$Herkese aynı şekilde kızmak$$, 'B', $$Başkalarının farklılıklarını anlayışla karşılamak$$, 'C', $$Kimseyle konuşmamak$$, 'D', $$Sadece kendini düşünmek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Hoşgörü, başkalarının farklı düşünce ve davranışlarını anlayışla karşılamaktır.$$,
    $$Adım 1: İnsanlar farklı düşünebilir ve davranabilir.$$,
    $$Adım 2: Hoşgörü, bu farklılıkları anlayışla karşılamaktır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Din Kültürü$$, $$Ahlak ve Değerler$$, $$Sözünde durmak$$, 2,
  $$Verdiğimiz sözü tutmak neden önemlidir?$$,
  jsonb_build_object('A', $$Zaman kaybettirir$$, 'B', $$Bize güvenilmesini sağlar$$, 'C', $$Kimse fark etmez$$, 'D', $$Gereksizdir$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sözünü tutan kişiye çevresi nasıl davranır?$$,
    $$Adım 1: Sözünü tutan kişi güvenilir olur.$$,
    $$Adım 2: Güven, sağlam ilişkiler kurar.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$Yer Kabuğu ve Dünya$$, $$Fosiller$$, 2,
  $$Fosiller nasıl oluşur?$$,
  jsonb_build_object('A', $$Canlıların aniden yok olmasıyla$$, 'B', $$Canlı kalıntılarının kayaçlar içinde uzun zaman kalmasıyla$$, 'C', $$İnsanların toprağı kazmasıyla$$, 'D', $$Suyun buharlaşmasıyla$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Eski canlıların kalıntıları milyonlarca yıl yer altında kalır ve taşlaşır.$$,
    $$Adım 1: Fosil, eski canlıların kalıntı veya izleridir.$$,
    $$Adım 2: Bu kalıntılar kayaçlar içinde çok uzun zaman kalarak taşlaşır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$Besinler$$, $$Besin içerikleri$$, 2,
  $$Vücudumuzun temel enerji kaynağı olan besin içeriği hangisidir?$$,
  jsonb_build_object('A', $$proteinler$$, 'B', $$karbonhidratlar$$, 'C', $$vitaminler$$, 'D', $$su$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Ekmek, patates gibi besinlerde bulunan ve bize güç veren içerik hangisidir?$$,
    $$Adım 1: Proteinler yapıcı-onarıcı, vitaminler düzenleyicidir.$$,
    $$Adım 2: Karbonhidratlar vücuda enerji sağlar.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$Kuvvet ve Hareket$$, $$Mıknatıs$$, 2,
  $$Mıknatıs aşağıdakilerden hangisini çeker?$$,
  jsonb_build_object('A', $$tahta$$, 'B', $$cam$$, 'C', $$demir$$, 'D', $$plastik$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Mıknatıs yalnızca demir, nikel, kobalt gibi metalleri çeker.$$,
    $$Adım 1: Mıknatıs bazı metallere çekim kuvveti uygular.$$,
    $$Adım 2: Demir mıknatısın çektiği maddelerdendir.$$,
    $$Adım 3: Tahta, cam ve plastik çekilmez. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$Madde$$, $$Hâl değişimi$$, 2,
  $$Suyun buhar hâline geçmesi için ne gerekir?$$,
  jsonb_build_object('A', $$soğutulması$$, 'B', $$ısıtılması$$, 'C', $$dondurulması$$, 'D', $$karıştırılması$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kaynama sonucu su buharlaşır. Kaynamak için ne gerekir?$$,
    $$Adım 1: Su ısıtıldığında kaynar ve buhar hâline geçer.$$,
    $$Adım 2: Soğutulursa donar (katı hâl), ısıtılırsa buharlaşır (gaz hâl).$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$Işık$$, $$Saydam-cisim$$, 2,
  $$Aşağıdakilerden hangisi saydam (içinden ışık geçen) maddedir?$$,
  jsonb_build_object('A', $$tahta$$, 'B', $$cam$$, 'C', $$taş$$, 'D', $$kitap$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Saydam maddelerin arkası görünür. Pencere hangi maddeden yapılır?$$,
    $$Adım 1: Saydam maddenin arkasındaki nesneler görünür.$$,
    $$Adım 2: Cam saydam bir maddedir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$Ses$$, $$Sesin yayılması$$, 2,
  $$Ses maddelerde yayılır. Ses en hızlı hangi ortamda yayılır?$$,
  jsonb_build_object('A', $$boşluk$$, 'B', $$havada$$, 'C', $$suda$$, 'D', $$katı maddede$$),
  'D',
  to_jsonb(ARRAY[
    $$İpucu: Sesin yayılması için tanecikler gerekir. Tanecikler hangi ortamda en sık?$$,
    $$Adım 1: Sesin yayılması için maddesel ortam gerekir; boşlukta yayılmaz.$$,
    $$Adım 2: Tanecikler katı maddede en sık olduğundan ses katıda en hızlı yayılır.$$,
    $$Adım 3: Doğru cevap D seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$Elektrik$$, $$Basit devre$$, 3,
  $$Basit bir elektrik devresinin çalışması için ne gereklidir?$$,
  jsonb_build_object('A', $$Yalnızca ampul$$, 'B', $$Pil, kablo ve ampulden oluşan kapalı devre$$, 'C', $$Yalnızca kablo$$, 'D', $$Yalnızca pil$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Ampulün yanması için elektriğin kesintisiz bir yol izlemesi gerekir.$$,
    $$Adım 1: Elektrik devresinde akımın dolaşması için kapalı bir yol olmalıdır.$$,
    $$Adım 2: Pil (güç), kablo (yol) ve ampul (tüketici) birlikte gerekir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$İnsan Sağlığı$$, $$İskelet ve kaslar$$, 2,
  $$Vücudumuza şekil veren ve organlarımızı koruyan yapı hangisidir?$$,
  jsonb_build_object('A', $$kaslar$$, 'B', $$iskelet$$, 'C', $$deri$$, 'D', $$kan$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kemiklerin birleşerek oluşturduğu yapı, vücudun çatısıdır.$$,
    $$Adım 1: Kemikler birleşerek iskeleti oluşturur.$$,
    $$Adım 2: İskelet vücuda şekil verir ve iç organları korur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$Madde$$, $$Saf madde-karışım$$, 3,
  $$Aşağıdakilerden hangisi bir karışımdır?$$,
  jsonb_build_object('A', $$saf su$$, 'B', $$tuzlu su$$, 'C', $$oksijen gazı$$, 'D', $$altın$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Karışım, birden fazla maddenin bir araya gelmesiyle oluşur ve kolayca ayrılabilir.$$,
    $$Adım 1: Saf su, oksijen ve altın tek bir maddeden oluşur.$$,
    $$Adım 2: Tuzlu su, su ve tuzun bir araya gelmesiyle oluşan bir karışımdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Fen Bilimleri$$, $$Çevre$$, $$Kaynakları koruma$$, 2,
  $$Elektrik enerjisini tasarruflu kullanmak için ne yapmalıyız?$$,
  jsonb_build_object('A', $$Kullanılmayan ışıkları açık bırakmak$$, 'B', $$Gereksiz ışıkları kapatmak$$, 'C', $$Bütün cihazları sürekli çalıştırmak$$, 'D', $$Pencereyi açıp ışığı yakmak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kullanmadığımız elektrikli cihazlar ve ışıklar açık kalırsa enerji boşa harcanır.$$,
    $$Adım 1: Elektrik enerjisi sınırlı bir kaynaktır.$$,
    $$Adım 2: Kullanılmayan ışıkları kapatmak enerjiyi korur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Greetings$$, $$Selamlaşma$$, 1,
  $$"Good evening!" selamı günün hangi zamanında kullanılır?$$,
  jsonb_build_object('A', $$sabah$$, 'B', $$öğle$$, 'C', $$akşam$$, 'D', $$gece yarısı$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "evening" akşam anlamına gelir.$$,
    $$Adım 1: "morning" sabah, "afternoon" öğleden sonra, "evening" akşamdır.$$,
    $$Adım 2: "Good evening" akşam selamıdır.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Numbers$$, $$Büyük sayılar$$, 2,
  $$"twenty" sayısı kaçtır?$$,
  jsonb_build_object('A', $$12$$, 'B', $$20$$, 'C', $$22$$, 'D', $$200$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "twelve" 12, "twenty" ise iki onluk demektir.$$,
    $$Adım 1: "twelve" 12 sayısıdır, "twenty" ise 20'dir.$$,
    $$Adım 2: "twenty" iki onluktan oluşur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Colors$$, $$Renkler$$, 1,
  $$"black" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$beyaz$$, 'B', $$siyah$$, 'C', $$gri$$, 'D', $$kahverengi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Gecenin rengidir.$$,
    $$Adım 1: "black" karanlıkta gördüğümüz renktir, yani siyah.$$,
    $$Adım 2: Beyaz "white", gri "grey", kahverengi "brown"dır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Family$$, $$Aile üyeleri$$, 2,
  $$"grandfather" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$dede$$, 'B', $$baba$$, 'C', $$amca$$, 'D', $$ağabey$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "father" baba demektir. "grandfather", babanın babasıdır.$$,
    $$Adım 1: "grand" öneki büyüklüğü belirtir; "grandfather" dededir.$$,
    $$Adım 2: "father" baba, "brother" kardeş, "uncle" amcadır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Classroom$$, $$Sınıf nesneleri$$, 2,
  $$"chair" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$masa$$, 'B', $$sandalye$$, 'C', $$kapı$$, 'D', $$tahta$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Üzerine oturduğumuz sınıf eşyasıdır.$$,
    $$Adım 1: "chair" oturulan eşyadır, yani sandalye.$$,
    $$Adım 2: Masa "table", kapı "door", tahta "board"dur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Body Parts$$, $$Vücut bölümleri$$, 1,
  $$"hand" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$ayak$$, 'B', $$el$$, 'C', $$kol$$, 'D', $$baş$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kalem tuttuğumuz vücut bölümüdür.$$,
    $$Adım 1: "hand" tutmamızı sağlayan organımızdır, yani el.$$,
    $$Adım 2: Ayak "foot", kol "arm", baş "head"tir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Food and Drinks$$, $$Yiyecekler$$, 2,
  $$"water" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$su$$, 'B', $$süt$$, 'C', $$çay$$, 'D', $$meyve suyu$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Her canlının içtiği, renksiz ve şeffaf sıvıdır.$$,
    $$Adım 1: "water" içtiğimiz su demektir.$$,
    $$Adım 2: Süt "milk", çay "tea", meyve suyu "juice"tır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Animals$$, $$Hayvanlar$$, 2,
  $$"fish" hangi hayvandır?$$,
  jsonb_build_object('A', $$kuş$$, 'B', $$balık$$, 'C', $$kedi$$, 'D', $$köpek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Suda yaşayan hayvanın İngilizce adıdır.$$,
    $$Adım 1: "fish" suda yaşayan bir hayvandır, yani balık.$$,
    $$Adım 2: Kuş "bird", kedi "cat", köpek "dog"dur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Time$$, $$Saat sorma$$, 3,
  $$"What time is it?" sorusunun Türkçe anlamı hangisidir?$$,
  jsonb_build_object('A', $$Saat kaç?$$, 'B', $$Bugün günlerden ne?$$, 'C', $$Neredesin?$$, 'D', $$Nasılsın?$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "time" zaman/saat, "what" ne demektir.$$,
    $$Adım 1: "time" saat/zaman anlamına gelir.$$,
    $$Adım 2: "What time is it?" = "Saat kaç?" sorusudur.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$İngilizce$$, $$Greetings$$, $$Tanışma$$, 2,
  $$"How old are you?" sorusunun Türkçe anlamı hangisidir?$$,
  jsonb_build_object('A', $$Adın ne?$$, 'B', $$Kaç yaşındasın?$$, 'C', $$Nerelisin?$$, 'D', $$Nasılsın?$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "old" yaşlı/yaş anlamına gelir; bu soru yaş sorar.$$,
    $$Adım 1: "How" nasıl/ne kadar, "old" yaş, "you" sen demektir.$$,
    $$Adım 2: "How old are you?" = "Kaç yaşındasın?" sorusudur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Doğal Sayılar$$, $$Basamak ve bölük$$, 2,
  $$604 128 sayısının binler bölüğündeki rakamların basamak değerleri toplamı kaçtır?$$,
  jsonb_build_object('A', $$604$$, 'B', $$604 000$$, 'C', $$128$$, 'D', $$600 000$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Binler bölüğü "604"tür. Bölüğün basamak değerleri toplamı, bölüğün kendisi çarpı 1000'dir.$$,
    $$Adım 1: 604 128 sayısının binler bölüğü 604, birler bölüğü 128'dir.$$,
    $$Adım 2: Binler bölüğündeki rakamların basamak değerleri: 6×100 000 + 0×10 000 + 4×1 000 = 604 000.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Doğal Sayılar$$, $$Çözümleme$$, 2,
  $$3×10 000 + 5×1 000 + 2×10 + 7 olarak çözümlenen sayı hangisidir?$$,
  jsonb_build_object('A', $$35 207$$, 'B', $$3 527$$, 'C', $$35 027$$, 'D', $$30 527$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Her çarpımı hesaplayıp topla: 30 000 + 5 000 + 20 + 7.$$,
    $$Adım 1: 3×10 000 = 30 000.$$,
    $$Adım 2: 5×1 000 = 5 000; 2×10 = 20; 7 = 7.$$,
    $$Adım 3: 30 000 + 5 000 + 20 + 7 = 35 207. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Dört İşlem$$, $$Çarpma$$, 2,
  $$345 × 6 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$1 870$$, 'B', $$2 070$$, 'C', $$2 170$$, 'D', $$2 700$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Basamak basamak çarp: 5×6, 4×6, 3×6 ve eldeleri ekle.$$,
    $$Adım 1: 5 × 6 = 30 → 0 yazılır, 3 elde.$$,
    $$Adım 2: 4 × 6 = 24, 24 + 3 = 27 → 7 yazılır, 2 elde.$$,
    $$Adım 3: 3 × 6 = 18, 18 + 2 = 20. Sonuç 2 070. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Dört İşlem$$, $$Bölme$$, 2,
  $$742 ÷ 7 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$106$$, 'B', $$16$$, 'C', $$1 006$$, 'D', $$116$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: 7 yüzlükten 7'ye böl: 100. Sonra onlar ve birleri böl.$$,
    $$Adım 1: 700 ÷ 7 = 100.$$,
    $$Adım 2: 42 ÷ 7 = 6.$$,
    $$Adım 3: 100 + 6 = 106. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Kesirler$$, $$Kesir karşılaştırma$$, 2,
  $$Aşağıdaki kesirlerden hangisi en büyüktür?$$,
  jsonb_build_object('A', $$1/2$$, 'B', $$2/5$$, 'C', $$3/4$$, 'D', $$1/3$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Paydaları eşitleyip karşılaştır ya da bütüne yakınlığına bak. 3/4 bütüne çok yakındır.$$,
    $$Adım 1: Kesirleri ondalık olarak yazalım: 1/2 = 0,5; 2/5 = 0,4; 3/4 = 0,75; 1/3 ≈ 0,33.$$,
    $$Adım 2: En büyük değer 0,75'tir.$$,
    $$Adım 3: 3/4 en büyüktür. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Ondalık Gösterim$$, $$Ondalık okuma$$, 3,
  $$"Sıfır tam yüzde yirmi beş" sayısının ondalık gösterimi hangisidir?$$,
  jsonb_build_object('A', $$0,25$$, 'B', $$0,025$$, 'C', $$25$$, 'D', $$2,5$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "Yüzde yirmi beş" = 25/100 demektir. Bunu virgüllü nasıl yazarız?$$,
    $$Adım 1: "Tam" kısmı 0'dır.$$,
    $$Adım 2: "Yüzde yirmi beş" = 25/100 = 0,25.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Geometri$$, $$Açılar$$, 2,
  $$Ölçüsü 90 dereceden küçük olan açıya ne denir?$$,
  jsonb_build_object('A', $$dik açı$$, 'B', $$dar açı$$, 'C', $$geniş açı$$, 'D', $$doğru açı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: 90 dereceden küçük açı, "L" şeklinden daha kapalı bir açıdır.$$,
    $$Adım 1: 90 derecelik açı dik açıdır.$$,
    $$Adım 2: 90 dereceden küçük açı dar açıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Ölçme$$, $$Çevre$$, 3,
  $$Kısa kenarı 4 cm, uzun kenarı 7 cm olan dikdörtgenin çevresi kaç cm'dir?$$,
  jsonb_build_object('A', $$11$$, 'B', $$14$$, 'C', $$22$$, 'D', $$28$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Dikdörtgenin çevresi = 2 × (kısa kenar + uzun kenar).$$,
    $$Adım 1: Kısa ve uzun kenar toplamı: 4 + 7 = 11.$$,
    $$Adım 2: Dikdörtgenin karşılıklı kenarları eşit olduğu için 2 ile çarpılır.$$,
    $$Adım 3: 2 × 11 = 22 cm. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Problemler$$, $$Zaman problemi$$, 3,
  $$Bir otobüs 09.15'te hareket edip 3 saat 45 dakika sonra varmıştır. Otobüs saat kaçta varmıştır?$$,
  jsonb_build_object('A', $$12.45$$, 'B', $$13.00$$, 'C', $$13.15$$, 'D', $$12.15$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Önce 3 saat ekle: 09.15 → 12.15. Sonra 45 dakika daha ekle.$$,
    $$Adım 1: 09.15 + 3 saat = 12.15 bulunur.$$,
    $$Adım 2: 12.15 + 45 dakika = 13.00 olur.$$,
    $$Adım 3: Otobüs 13.00'te varmıştır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Matematik$$, $$Doğal Sayılar$$, $$Yuvarlama$$, 2,
  $$4 678 sayısı en yakın yüzlüğe yuvarlanırsa hangisi elde edilir?$$,
  jsonb_build_object('A', $$4 600$$, 'B', $$4 700$$, 'C', $$4 680$$, 'D', $$5 000$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Onlar basamağına bak. 7, 5'ten büyük olduğu için yukarı yuvarlanır.$$,
    $$Adım 1: Yüzlüğe yuvarlarken onlar basamağına bakılır: 7.$$,
    $$Adım 2: 7 ≥ 5 olduğu için yüzler basamağı 1 artırılır.$$,
    $$Adım 3: 4 678 ≈ 4 700. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Birey ve Toplum$$, $$Kimlik bilgileri$$, 1,
  $$Aşağıdakilerden hangisi kişisel bir bilgidir?$$,
  jsonb_build_object('A', $$ad ve soyad$$, 'B', $$hava durumu$$, 'C', $$mevsim$$, 'D', $$gün adı$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Kişiye özel, onu tanıtan bilgi hangisidir?$$,
    $$Adım 1: Hava durumu, mevsim ve gün adı herkes için aynıdır.$$,
    $$Adım 2: Ad ve soyad ise kişiye özeldir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Kültür ve Miras$$, $$Millî kültür$$, 2,
  $$Aşağıdakilerden hangisi millî kültürümüzün bir unsurudur?$$,
  jsonb_build_object('A', $$folklor oyunları$$, 'B', $$trafik işaretleri$$, 'C', $$alfabe dışı simgeler$$, 'D', $$yabancı diller$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Bir topluma özgü gelenek, halk oyunu, türkü gibi ögeler millî kültürü oluşturur.$$,
    $$Adım 1: Millî kültür, bir toplumun kendine özgü değerleridir.$$,
    $$Adım 2: Folklor oyunları (halk oyunları) millî kültürümüzün bir parçasıdır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Yer-Yön$$, $$Yön bulma$$, 2,
  $$Pusulanın renkli ucu (kırmızı iğne) hangi yönü gösterir?$$,
  jsonb_build_object('A', $$kuzey$$, 'B', $$güney$$, 'C', $$doğu$$, 'D', $$batı$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Pusulanın kırmızı ucu kuzeyi gösterir; bu yüzden pusula ile yön bulunur.$$,
    $$Adım 1: Pusula, yön bulmada kullanılan bir araçtır.$$,
    $$Adım 2: Kırmızı iğne daima kuzey yönünü gösterir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Doğal Afetler$$, $$Deprem$$, 2,
  $$Deprem anında bina içindeysek ne yapmalıyız?$$,
  jsonb_build_object('A', $$Asansöre binmeliyiz$$, 'B', $$Sağlam bir eşyanın yanına çöküp başımızı korumalıyız$$, 'C', $$Camdan atlamalıyız$$, 'D', $$Koşarak merdivenlerden inmeye çalışmalıyız$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Deprem sarsıntısı geçene kadar en güvenli davranış: çök, kapan, tutun.$$,
    $$Adım 1: Deprem anında panik yapmak tehlikelidir.$$,
    $$Adım 2: Sağlam bir eşyanın yanına çöküp başımızı korumak doğru davranıştır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Ekonomik Yaşam$$, $$İhtiyaç-istek$$, 3,
  $$Aşağıdakilerden hangisi temel bir ihtiyaçtır?$$,
  jsonb_build_object('A', $$oyuncak$$, 'B', $$beslenme$$, 'C', $$süs eşyası$$, 'D', $$çikolata$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Temel ihtiyaçlar yaşamak için zorunludur; istekler ise olmasa da yaşayabiliriz.$$,
    $$Adım 1: Oyuncak, süs eşyası ve çikolata olmadan yaşayabiliriz.$$,
    $$Adım 2: Beslenme ise yaşam için zorunlu temel bir ihtiyaçtır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Birey ve Toplum$$, $$Sorumluluk$$, 2,
  $$Okulda uymamız gereken kuralların amacı nedir?$$,
  jsonb_build_object('A', $$Öğrencileri sıkmak$$, 'B', $$Düzeni ve güvenliği sağlamak$$, 'C', $$Dersleri zorlaştırmak$$, 'D', $$Zamanı geçirmek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kurallar, herkesin daha rahat ve güvenli olması için konur.$$,
    $$Adım 1: Kurallar toplu yaşamı düzenlemek için vardır.$$,
    $$Adım 2: Okul kuralları düzeni ve güvenliği sağlar.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Kültür ve Miras$$, $$Tarihî eserler$$, 3,
  $$Aşağıdakilerden hangisi tarihî bir eserdir?$$,
  jsonb_build_object('A', $$modern alışveriş merkezi$$, 'B', $$tarihî bir kale$$, 'C', $$yeni bir köprü$$, 'D', $$plastik bir heykel$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Tarihî eserler geçmişten günümüze kalan, korunması gereken yapılardır.$$,
    $$Adım 1: Tarihî eserler eski dönemlerden kalan yapı ve nesnelerdir.$$,
    $$Adım 2: Tarihî bir kale geçmişten günümüze kalmış bir eserdir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Yer-Yön$$, $$Kroki$$, 3,
  $$Kroki neyi gösterir?$$,
  jsonb_build_object('A', $$Bir yerin kuş bakışı basit çizimini$$, 'B', $$Bir kişinin fotoğrafını$$, 'C', $$Hava durumunu$$, 'D', $$Bir yemeğin tarifini$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Kroki, bir yerin üstten bakıldığında nasıl göründüğünü basit çizgilerle anlatır.$$,
    $$Adım 1: Kroki, bir yerin basitleştirilmiş çizimidir.$$,
    $$Adım 2: Ölçekli olması gerekmez, kuş bakışı gösterir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Doğal Afetler$$, $$Sel$$, 2,
  $$Sel baskınlarına karşı alınabilecek önlem hangisidir?$$,
  jsonb_build_object('A', $$Dere yataklarına ev yapmak$$, 'B', $$Ağaç dikip yeşil alanı artırmak$$, 'C', $$Çöpleri dereye atmak$$, 'D', $$Yağmurda dışarıda oynamak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bitki örtüsü, toprağın suyu emmesine yardımcı olur ve seli azaltır.$$,
    $$Adım 1: Ağaçlar ve bitkiler toprağın su tutmasını sağlar.$$,
    $$Adım 2: Yeşil alanı artırmak sel riskini azaltır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Sosyal Bilgiler$$, $$Birey ve Toplum$$, $$Farklılıklara saygı$$, 2,
  $$Arkadaşımızın bizden farklı bir özelliği varsa nasıl davranmalıyız?$$,
  jsonb_build_object('A', $$Onunla alay etmeliyiz$$, 'B', $$Ona saygı duymalıyız$$, 'C', $$Onu dışlamalıyız$$, 'D', $$Görmezden gelmeliyiz$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Her insan farklıdır; bu farklılıklar bizi zenginleştirir.$$,
    $$Adım 1: İnsanlar birbirinden farklı özelliklere sahiptir.$$,
    $$Adım 2: Bu farklılıklara saygı göstermek doğru davranıştır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Sözcükte Anlam$$, $$Gerçek ve mecaz anlam$$, 2,
  $$"Öğretmenin sıcak sözleri hepimizi mutlu etti." cümlesinde "sıcak" sözcüğü hangi anlamda kullanılmıştır?$$,
  jsonb_build_object('A', $$gerçek anlam$$, 'B', $$mecaz anlam$$, 'C', $$terim anlam$$, 'D', $$eş anlam$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sıcaklık ölçülebilir bir şeydir. "Sıcak söz" ölçülebilir mi, yoksa duygu mu anlatır?$$,
    $$Adım 1: Gerçek anlamda "sıcak", dokunulabilen sıcaklıktır.$$,
    $$Adım 2: Burada "sıcak sözler" gönül alan, içten sözler anlamındadır.$$,
    $$Adım 3: Bu kullanım mecaz anlamdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Deyimler$$, $$Deyim anlamı$$, 3,
  $$"Göz atmak" deyiminin anlamı nedir?$$,
  jsonb_build_object('A', $$Gözüyle zarar vermek$$, 'B', $$Kısaca bakmak, incelemek$$, 'C', $$Gözünü kapatmak$$, 'D', $$Uyumak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Deyimler sözcüklerin gerçek anlamının dışında bir anlam taşır. "Göz atmak" kısa bir bakıştır.$$,
    $$Adım 1: "Göz atmak" deyimi gerçekten göz çıkarmak değildir.$$,
    $$Adım 2: Bir şeye kısaca bakmak, gözden geçirmek anlamına gelir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Cümlede Anlam$$, $$Duygu ifadesi$$, 2,
  $$"Yaşasın, yarın tatile çıkıyoruz!" cümlesi hangi duyguyu anlatır?$$,
  jsonb_build_object('A', $$üzüntü$$, 'B', $$korku$$, 'C', $$sevinç$$, 'D', $$öfke$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "Yaşasın" sözcüğü olumlu, coşkulu bir duyguyu ifade eder.$$,
    $$Adım 1: "Yaşasın" ünlemi sevinç duygusunu gösterir.$$,
    $$Adım 2: Tatil beklentisi de bu sevinci artırır.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Atasözleri$$, $$Atasözü anlamı$$, 3,
  $$"Ağaç yaş iken eğilir." atasözü bize ne anlatır?$$,
  jsonb_build_object('A', $$Ağaçların sulanması gerektiğini$$, 'B', $$Eğitimin küçük yaşta verilmesi gerektiğini$$, 'C', $$Ağaçların kesilmemesi gerektiğini$$, 'D', $$Yaşlı insanlara saygıyı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Yaş ağaç kolayca şekil alır; kurumuş ağaç zor eğilir. Bu, insan için ne anlatır?$$,
    $$Adım 1: Yaş ağaç kolayca istenilen yöne eğilebilir.$$,
    $$Adım 2: Bu, çocukluk döneminde kolayca eğitim verilebileceğini anlatır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Sözcük Türleri$$, $$Fiil (eylem)$$, 2,
  $$"Sabah erkenden okula koştu." cümlesinde fiil (eylem) hangi sözcüktür?$$,
  jsonb_build_object('A', $$sabah$$, 'B', $$okula$$, 'C', $$koştu$$, 'D', $$erkenden$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Eylemler bir işi, oluşu ya da hareketi bildirir. Cümlede hareket bildiren sözcük hangisi?$$,
    $$Adım 1: "Sabah", "erkenden" zamanla ilgili; "okula" yer bildiren sözcüklerdir.$$,
    $$Adım 2: "Koştu" bir hareket, yani eylem bildirir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Yazım Kuralları$$, $$"mi" soru eki$$, 2,
  $$Aşağıdaki cümlelerden hangisinde "mi" doğru yazılmıştır?$$,
  jsonb_build_object('A', $$Bu kitabı okudunmu?$$, 'B', $$Bu kitabı okudun mu?$$, 'C', $$Bu kitabı okudunmi?$$, 'D', $$Bu kitabı okudunMu?$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Soru eki "mi" her zaman ayrı yazılır.$$,
    $$Adım 1: Soru eki "mi" kendinden önceki sözcüğe bitişik yazılmaz.$$,
    $$Adım 2: A ve C seçeneklerinde bitişik, D'de büyük harfle yazılmıştır.$$,
    $$Adım 3: Doğru yazım "okudun mu?" şeklindedir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Noktalama İşaretleri$$, $$Kesme işareti$$, 2,
  $$"Ali İzmir'e gitti." cümlesinde "İzmir'e" sözcüğünde kesme işareti neden kullanılmıştır?$$,
  jsonb_build_object('A', $$Özel ada gelen ek ayrıldığı için$$, 'B', $$Cümle bittiği için$$, 'C', $$Sıralama yapıldığı için$$, 'D', $$Soru sorulduğu için$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Kesme işareti özel adlara gelen çekim eklerini ayırmak için kullanılır.$$,
    $$Adım 1: "İzmir" bir özel addır.$$,
    $$Adım 2: Özel adlara gelen çekim ekleri kesme işaretiyle ayrılır.$$,
    $$Adım 3: Bu yüzden "İzmir'e" şeklinde yazılır. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Söz Sanatları$$, $$Kişileştirme$$, 3,
  $$"Rüzgar, yapraklarla fısıldaşıyordu." cümlesinde hangi söz sanatı vardır?$$,
  jsonb_build_object('A', $$benzetme$$, 'B', $$kişileştirme$$, 'C', $$abartma$$, 'D', $$konuşturma$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Rüzgar gerçekten fısıldaşabilir mi? İnsana ait bir özellik doğaya verilmiş.$$,
    $$Adım 1: "Fısıldaşmak" insana ait bir özelliktir.$$,
    $$Adım 2: Bu özellik rüzgara verilmiştir, yani rüzgar kişileştirilmiştir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Okuma-Anlama$$, $$Ana fikir$$, 3,
  $$"Kitap okumak, insanın hayal dünyasını genişletir ve kelime hazinesini artırır." cümlesinin ana fikri nedir?$$,
  jsonb_build_object('A', $$Kitaplar pahalıdır$$, 'B', $$Kitap okumanın faydaları vardır$$, 'C', $$Kitaplar ağırdır$$, 'D', $$Okumak yorucudur$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Cümle kitap okumanın olumlu sonuçlarını sayıyor.$$,
    $$Adım 1: Cümlede kitap okumanın iki faydası belirtiliyor.$$,
    $$Adım 2: Bu, kitap okumanın yararlı olduğunu anlatır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ilkokul', 4, $$Türkçe$$, $$Sözcükte Anlam$$, $$Eş anlamlılık$$, 1,
  $$"öğrenci" sözcüğünün eş anlamlısı hangisidir?$$,
  jsonb_build_object('A', $$talebe$$, 'B', $$öğretmen$$, 'C', $$okul$$, 'D', $$sınıf$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Eş anlamlı sözcükler aynı anlamı taşır. Öğrenciye başka hangi sözcük denir?$$,
    $$Adım 1: "Öğrenci", okula gidip ders alan kişidir.$$,
    $$Adım 2: Bu kişiye "talebe" de denir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$İnanç$$, $$İslam'ın şartları$$, 2,
  $$İslam'ın beş temel şartından biri hangisidir?$$,
  jsonb_build_object('A', $$Namaz kılmak$$, 'B', $$Kitap okumak$$, 'C', $$Spor yapmak$$, 'D', $$Seyahat etmek$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: İbadetle ilgili olan temel şartlardan biri hangisidir?$$,
    $$Adım 1: İslam'ın şartları ibadet ve inançla ilgili temel esaslardır.$$,
    $$Adım 2: Namaz kılmak bu temel şartlardan biridir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$Ahlak$$, $$Doğruluk$$, 1,
  $$Doğruluk ve dürüstlük hangi davranışla ilgilidir?$$,
  jsonb_build_object('A', $$Yalan söylemek$$, 'B', $$Sözünde durmak$$, 'C', $$Emanete ihanet etmek$$, 'D', $$Dedikodu yapmak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Doğru sözlü kişi verdiği sözü tutar.$$,
    $$Adım 1: Doğruluk, doğru söylemek ve sözünde durmaktır.$$,
    $$Adım 2: Sözünde durmak dürüstlüğün gereğidir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$Değerler$$, $$Paylaşma$$, 2,
  $$İhtiyaç sahiplerine yardım etmek hangi değeri yansıtır?$$,
  jsonb_build_object('A', $$Cimrilik$$, 'B', $$Yardımseverlik ve paylaşma$$, 'C', $$Kıskançlık$$, 'D', $$Bencillik$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Elindekini başkasıyla paylaşan kişi hangi değeri gösterir?$$,
    $$Adım 1: Yardım etmek, ihtiyaç sahibini gözetmektir.$$,
    $$Adım 2: Bu davranış yardımseverlik ve paylaşma değerini yansıtır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$Çevre$$, $$Doğa ve emanet$$, 2,
  $$Doğayı korumak niçin önemlidir?$$,
  jsonb_build_object('A', $$Doğa bize emanettir$$, 'B', $$Doğa değersizdir$$, 'C', $$Doğa zararlıdır$$, 'D', $$Doğa sınırsızdır$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Doğa, tüm canlıların ortak yaşam alanıdır ve korunması bir sorumluluktur.$$,
    $$Adım 1: Doğa, insanın yaşamını sürdürdüğü ortamdır.$$,
    $$Adım 2: Onu korumak bir sorumluluk, bir emanettir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$Değerler$$, $$Hoşgörü$$, 2,
  $$Farklı düşünen birine nasıl davranmalıyız?$$,
  jsonb_build_object('A', $$Ona baskı yapmalıyız$$, 'B', $$Ona saygı ve hoşgörü göstermeliyiz$$, 'C', $$Onu dışlamalıyız$$, 'D', $$Onunla alay etmeliyiz$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Herkesin farklı düşünebileceğini kabul etmek hoşgörüdür.$$,
    $$Adım 1: İnsanlar farklı düşünebilir.$$,
    $$Adım 2: Bu farklılıklara saygı ve hoşgörü göstermeliyiz.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$İbadet$$, $$Temizlik$$, 2,
  $$İbadetlerden önce yapılması gereken temizlik davranışı hangisidir?$$,
  jsonb_build_object('A', $$Abdest almak$$, 'B', $$Koşmak$$, 'C', $$Uyumak$$, 'D', $$Oyun oynamak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Beden temizliği için su ile yapılan hazırlık hangisidir?$$,
    $$Adım 1: İbadetten önce bedenin temiz olması gerekir.$$,
    $$Adım 2: Bu temizlik abdest ile sağlanır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$Ahlak$$, $$Sabır$$, 3,
  $$Sabırlı olmak ne anlama gelir?$$,
  jsonb_build_object('A', $$Zorluklara dayanıp acele etmemek$$, 'B', $$Her şeye kızmak$$, 'C', $$Her zaman üzülmek$$, 'D', $$Kimseyle konuşmamak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Güçlükler karşısında dayanma ve soğukkanlılık hangi değerdir?$$,
    $$Adım 1: Sabır, güçlükler karşısında dayanma ve bekleyebilme gücüdür.$$,
    $$Adım 2: Sabırlı kişi acele etmez, zorluğa dayanır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$Değerler$$, $$Adalet$$, 3,
  $$Adaletli olmak ne demektir?$$,
  jsonb_build_object('A', $$Herkese eşit ve hak ettiği gibi davranmak$$, 'B', $$Sadece kendini düşünmek$$, 'C', $$Güçlüyü kayırmak$$, 'D', $$Taraf tutmak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Adalet, hak sahibine hakkını vermektir.$$,
    $$Adım 1: Adalet, herkese hak ettiği şekilde davranmaktır.$$,
    $$Adım 2: Kayırmak ve taraf tutmak adalete aykırıdır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$Ahlak$$, $$İsraf$$, 3,
  $$İsraftan kaçınmak ne anlama gelir?$$,
  jsonb_build_object('A', $$Gereksiz harcamadan kaçınıp tutumlu olmak$$, 'B', $$Her şeyi harcamak$$, 'C', $$Yiyecekleri atmak$$, 'D', $$Suyu boşa akıtmak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Kaynakları gereksiz yere harcamamak hangi değerdir?$$,
    $$Adım 1: İsraf, kaynakları gereksiz yere harcamaktır.$$,
    $$Adım 2: İsraftan kaçınmak, tutumlu ve ölçülü olmaktır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Din Kültürü$$, $$Değerler$$, $$Selamlaşma$$, 1,
  $$Selam vermek ve almak bize ne kazandırır?$$,
  jsonb_build_object('A', $$Sevgi ve barış ortamı$$, 'B', $$Korku$$, 'C', $$Üzüntü$$, 'D', $$Kızgınlık$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Selam, insanlar arasında sevgi bağı kurar.$$,
    $$Adım 1: Selamlaşmak, insanlar arasında yakınlık kurar.$$,
    $$Adım 2: Bu davranış sevgi ve barış ortamı oluşturur.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Güneş Sistemi$$, $$Gezegenler$$, 2,
  $$Güneş'e en yakın gezegen hangisidir?$$,
  jsonb_build_object('A', $$Venüs$$, 'B', $$Merkür$$, 'C', $$Dünya$$, 'D', $$Mars$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Güneş sistemindeki gezegenler sıralanırken en başta olan hangisidir?$$,
    $$Adım 1: Güneş'e yakınlıklarına göre gezegenler sıralanır.$$,
    $$Adım 2: En içteki, yani Güneş'e en yakın gezegen Merkür'dür.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Vücut Sistemleri$$, $$Sindirim sistemi$$, 2,
  $$Besinlerin kana geçebilecek kadar küçük parçalara ayrılmasına ne denir?$$,
  jsonb_build_object('A', $$solunum$$, 'B', $$sindirim$$, 'C', $$dolaşım$$, 'D', $$boşaltım$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Yediğimiz besinlerin parçalanması hangi sistemin işidir?$$,
    $$Adım 1: Besinler sindirim sistemiyle parçalanır.$$,
    $$Adım 2: Bu parçalanma olayına sindirim denir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Kuvvet ve Hareket$$, $$Bileşke kuvvet$$, 3,
  $$Aynı yönde uygulanan 5 N ve 8 N'luk iki kuvvetin bileşkesi kaç N'dur?$$,
  jsonb_build_object('A', $$3$$, 'B', $$13$$, 'C', $$40$$, 'D', $$8$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Aynı yöndeki kuvvetler toplanır.$$,
    $$Adım 1: Kuvvetler aynı yönde olduğu için toplanır.$$,
    $$Adım 2: 5 + 8 = 13.$$,
    $$Adım 3: Bileşke kuvvet 13 N'dur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Madde ve Isı$$, $$Isı iletimi$$, 2,
  $$Isıyı iyi ileten maddelere ne denir?$$,
  jsonb_build_object('A', $$yalıtkan$$, 'B', $$iletken$$, 'C', $$saydam$$, 'D', $$esnek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Isıyı ileten maddeler "iletken", iletmeyenler "yalıtkan"dır.$$,
    $$Adım 1: Maddeler ısıyı iletme özelliklerine göre ayrılır.$$,
    $$Adım 2: Isıyı iyi ileten maddelere iletken denir (ör. metaller).$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Ses$$, $$Sesin özellikleri$$, 3,
  $$Sesin yüksekliği (incelik-kalınlık) neye bağlıdır?$$,
  jsonb_build_object('A', $$Sesin şiddetine$$, 'B', $$Titreşim sıklığına$$, 'C', $$Sesin hızına$$, 'D', $$Ortamın rengine$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Hızlı titreşen kaynaklar ince ses üretir.$$,
    $$Adım 1: Bir kaynağın titreşim sıklığı arttıkça ses incelir.$$,
    $$Adım 2: Sesin yüksekliği titreşim sıklığına bağlıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Elektrik$$, $$İletken-yalıtkan$$, 2,
  $$Aşağıdakilerden hangisi elektriği iletmez?$$,
  jsonb_build_object('A', $$bakır tel$$, 'B', $$plastik$$, 'C', $$demir çivi$$, 'D', $$alüminyum folyo$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Elektriği iletmeyen maddeler yalıtkandır.$$,
    $$Adım 1: Bakır, demir ve alüminyum metallerdir ve elektriği iletir.$$,
    $$Adım 2: Plastik bir yalıtkandır, elektriği iletmez.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Canlılar$$, $$Bitki ve hayvan hücresi$$, 3,
  $$Bitki hücresinde olup hayvan hücresinde olmayan yapı hangisidir?$$,
  jsonb_build_object('A', $$çekirdek$$, 'B', $$hücre zarı$$, 'C', $$kloroplast$$, 'D', $$sitoplazma$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Fotosentez yapan yeşil yapı, bitkiye özgüdür.$$,
    $$Adım 1: Çekirdek, zar ve sitoplazma hem bitki hem hayvan hücresinde vardır.$$,
    $$Adım 2: Kloroplast, yeşil renkli bitki hücrelerine özgüdür.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Vücut Sistemleri$$, $$Solunum sistemi$$, 2,
  $$Soluk alıp vermede görevli temel organ hangisidir?$$,
  jsonb_build_object('A', $$kalp$$, 'B', $$akciğer$$, 'C', $$mide$$, 'D', $$böbrek$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Oksijen alıp karbondioksit verdiğimiz organ hangisidir?$$,
    $$Adım 1: Solunum, oksijen alıp karbondioksit verme işidir.$$,
    $$Adım 2: Bu işi akciğerler yapar.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Madde ve Isı$$, $$Genleşme$$, 3,
  $$Isıtılan metallerin hacmi nasıl değişir?$$,
  jsonb_build_object('A', $$Azalır$$, 'B', $$Artar$$, 'C', $$Değişmez$$, 'D', $$Yok olur$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Isınan maddelerin tanecikleri daha hızlı hareket eder ve birbirinden uzaklaşır.$$,
    $$Adım 1: Isıtılan maddenin tanecikleri hızlanır ve aralarındaki mesafe artar.$$,
    $$Adım 2: Bu yüzden maddenin hacmi artar; bu olaya genleşme denir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Fen Bilimleri$$, $$Kuvvet ve Hareket$$, $$Dengeleyici kuvvet$$, 3,
  $$Zıt yönde uygulanan 10 N ve 6 N'luk iki kuvvetin bileşkesi kaç N'dur ve hangi yöndedir?$$,
  jsonb_build_object('A', $$16 N, büyük kuvvet yönünde$$, 'B', $$4 N, büyük kuvvet yönünde$$, 'C', $$4 N, küçük kuvvet yönünde$$, 'D', $$60 N, büyük kuvvet yönünde$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Zıt yönlü kuvvetler çıkarılır; bileşke büyük kuvvetin yönündedir.$$,
    $$Adım 1: Zıt yönlü kuvvetlerde büyükten küçük çıkarılır: 10 - 6 = 4.$$,
    $$Adım 2: Bileşke kuvvet, büyük kuvvetin (10 N) yönündedir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Introducing Yourself$$, $$Kişisel bilgi$$, 2,
  $$"Where are you from?" sorusunun Türkçe anlamı hangisidir?$$,
  jsonb_build_object('A', $$Nerelisin?$$, 'B', $$Kaç yaşındasın?$$, 'C', $$Adın ne?$$, 'D', $$Nasılsın?$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "from" -den/-dan anlamına gelir; bu soru memleketi sorar.$$,
    $$Adım 1: "Where" nerede, "from" -den demektir.$$,
    $$Adım 2: "Where are you from?" = "Nerelisin?" sorusudur.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Daily Routine$$, $$Günlük rutin$$, 2,
  $$"I wake up at seven o'clock." cümlesinin Türkçe anlamı hangisidir?$$,
  jsonb_build_object('A', $$Saat yedide uyanırım.$$, 'B', $$Saat yedide yatarım.$$, 'C', $$Saat yedide yerim.$$, 'D', $$Saat yedide giderim.$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "wake up" uyanmak anlamına gelir.$$,
    $$Adım 1: "wake up" uyanmak demektir.$$,
    $$Adım 2: "at seven o'clock" saat yedide anlamına gelir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Jobs$$, $$Meslekler$$, 2,
  $$"teacher" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$doktor$$, 'B', $$öğretmen$$, 'C', $$mühendis$$, 'D', $$aşçı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "teach" öğretmek demektir. Bu işi yapan kişi kimdir?$$,
    $$Adım 1: "teach" öğretmek anlamına gelir.$$,
    $$Adım 2: Bu işi yapan kişiye "teacher" (öğretmen) denir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Hobbies$$, $$Hobiler$$, 2,
  $$"I like reading books." cümlesinde kişi ne yapmayı seviyor?$$,
  jsonb_build_object('A', $$Kitap okumayı$$, 'B', $$Yüzmeyi$$, 'C', $$Koşmayı$$, 'D', $$Şarkı söylemeyi$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "reading books" ifadesi ne anlama gelir?$$,
    $$Adım 1: "reading" okumak, "books" kitaplar demektir.$$,
    $$Adım 2: "I like reading books." = "Kitap okumayı severim." anlamına gelir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Family$$, $$Aile$$, 1,
  $$"brother" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$kız kardeş$$, 'B', $$erkek kardeş$$, 'C', $$kuzen$$, 'D', $$amca$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "sister" kız kardeş ise "brother" nedir?$$,
    $$Adım 1: "sister" kız kardeş, "brother" erkek kardeş demektir.$$,
    $$Adım 2: Bu iki sözcük kardeşleri ifade eder.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Time$$, $$Saat ifadeleri$$, 2,
  $$"It is half past three." saat kaçı gösterir?$$,
  jsonb_build_object('A', $$3.00$$, 'B', $$3.30$$, 'C', $$4.30$$, 'D', $$2.30$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "half past" buçuk anlamına gelir; "three" saati belirtir.$$,
    $$Adım 1: "half past" buçuk demektir.$$,
    $$Adım 2: "half past three" = üç buçuk.$$,
    $$Adım 3: Bu 3.30'dur. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Directions$$, $$Yer-yön$$, 3,
  $$"turn left" ifadesinin Türkçe anlamı hangisidir?$$,
  jsonb_build_object('A', $$sağa dön$$, 'B', $$sola dön$$, 'C', $$düz git$$, 'D', $$geri dön$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "left" sol, "right" sağ demektir.$$,
    $$Adım 1: "left" sol, "right" sağ anlamına gelir.$$,
    $$Adım 2: "turn left" = sola dön demektir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Present Simple$$, $$Geniş zaman$$, 3,
  $$"She ____ to school every day." boşluğa hangi sözcük gelmelidir?$$,
  jsonb_build_object('A', $$go$$, 'B', $$goes$$, 'C', $$going$$, 'D', $$went$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Üçüncü tekil kişi (she/he/it) ile fiile "-s" eklenir.$$,
    $$Adım 1: Geniş zamanda "she" öznesiyle fiile "-es/-s" eklenir.$$,
    $$Adım 2: "go" fiili "she" ile "goes" olur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Weather$$, $$Hava durumu$$, 2,
  $$"It is sunny today." cümlesinde hava nasıldır?$$,
  jsonb_build_object('A', $$yağmurlu$$, 'B', $$güneşli$$, 'C', $$karlı$$, 'D', $$rüzgarlı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "sun" güneş demektir; "sunny" güneşli anlamına gelir.$$,
    $$Adım 1: "sun" güneş, "sunny" güneşli demektir.$$,
    $$Adım 2: "It is sunny today." = "Bugün hava güneşli." anlamına gelir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$İngilizce$$, $$Likes and Dislikes$$, $$Sevme-sevmeme$$, 3,
  $$"I don't like fish." cümlesi ne anlatır?$$,
  jsonb_build_object('A', $$Balığı severim$$, 'B', $$Balığı sevmem$$, 'C', $$Balık yerim$$, 'D', $$Balık pişiririm$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "don't" olumsuzluk ekidir; "like" sevmek demektir.$$,
    $$Adım 1: "don't" olumsuzluk bildirir.$$,
    $$Adım 2: "I don't like fish." = "Balığı sevmem." anlamına gelir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$Çarpanlar ve Katlar$$, $$EBOB$$, 2,
  $$12 ve 18 sayılarının en büyük ortak böleni (EBOB) kaçtır?$$,
  jsonb_build_object('A', $$2$$, 'B', $$3$$, 'C', $$6$$, 'D', $$36$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: İki sayıyı da tam bölen en büyük sayıyı ara. 12 ve 18'in ortak bölenleri: 1, 2, 3, 6.$$,
    $$Adım 1: 12'nin bölenleri: 1, 2, 3, 4, 6, 12.$$,
    $$Adım 2: 18'in bölenleri: 1, 2, 3, 6, 9, 18.$$,
    $$Adım 3: Ortak bölenlerin en büyüğü 6'dır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$Çarpanlar ve Katlar$$, $$EKOK$$, 2,
  $$4 ve 6 sayılarının en küçük ortak katı (EKOK) kaçtır?$$,
  jsonb_build_object('A', $$8$$, 'B', $$12$$, 'C', $$16$$, 'D', $$24$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: 4'ün katları: 4, 8, 12... 6'nın katları: 6, 12... İlk ortak katı bul.$$,
    $$Adım 1: 4'ün katları: 4, 8, 12, 16...$$,
    $$Adım 2: 6'nın katları: 6, 12, 18...$$,
    $$Adım 3: İlk ortak kat 12'dir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$İşlemler$$, $$İşlem önceliği$$, 3,
  $$3 + 4 × 5 - 2 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$33$$, 'B', $$21$$, 'C', $$25$$, 'D', $$17$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İşlem önceliğinde önce çarpma yapılır, sonra toplama ve çıkarma.$$,
    $$Adım 1: Önce çarpma: 4 × 5 = 20.$$,
    $$Adım 2: Sonra soldan sağa: 3 + 20 = 23; 23 - 2 = 21.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$Kesirler$$, $$Kesirlerde toplama$$, 3,
  $$1/2 + 1/3 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$2/5$$, 'B', $$1/6$$, 'C', $$5/6$$, 'D', $$2/6$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Önce paydaları eşitle: 1/2 = 3/6 ve 1/3 = 2/6. Sonra topla.$$,
    $$Adım 1: Paydaları eşitleriz: 1/2 = 3/6, 1/3 = 2/6.$$,
    $$Adım 2: Payları toplarız: 3 + 2 = 5, payda 6 kalır.$$,
    $$Adım 3: Sonuç 5/6'dır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$Ondalık Gösterim$$, $$Ondalık çarpma$$, 2,
  $$0,4 × 0,5 işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$0,2$$, 'B', $$2,0$$, 'C', $$0,02$$, 'D', $$0,9$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Virgülsüz çarp: 4 × 5 = 20. İki ondalık basamak olduğu için virgülü iki basamak kaydır.$$,
    $$Adım 1: Virgülleri yok sayarak çarparız: 4 × 5 = 20.$$,
    $$Adım 2: İki sayının toplam ondalık basamak sayısı 2'dir.$$,
    $$Adım 3: 20 → 0,20 = 0,2. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$Oran$$, $$Oran kurma$$, 2,
  $$3 kalemin fiyatı 15 lira ise 5 kalemin fiyatı kaç liradır?$$,
  jsonb_build_object('A', $$20$$, 'B', $$25$$, 'C', $$30$$, 'D', $$35$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Önce bir kalemin fiyatını bul: 15 ÷ 3.$$,
    $$Adım 1: 1 kalemin fiyatı: 15 ÷ 3 = 5 lira.$$,
    $$Adım 2: 5 kalemin fiyatı: 5 × 5.$$,
    $$Adım 3: 5 × 5 = 25 lira. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$Cebir$$, $$Basit denklem$$, 3,
  $$x + 7 = 15 ise x kaçtır?$$,
  jsonb_build_object('A', $$6$$, 'B', $$7$$, 'C', $$8$$, 'D', $$22$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Eşitliğin iki tarafından da 7 çıkar.$$,
    $$Adım 1: x + 7 = 15 denkleminde her iki taraftan 7 çıkarılır.$$,
    $$Adım 2: x = 15 - 7 olur.$$,
    $$Adım 3: x = 8. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$Geometri$$, $$Üçgenin iç açıları$$, 2,
  $$Bir üçgenin iç açıları toplamı kaç derecedir?$$,
  jsonb_build_object('A', $$90$$, 'B', $$180$$, 'C', $$270$$, 'D', $$360$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Her üçgenin iç açıları toplamı aynı sabit sayıdır.$$,
    $$Adım 1: Bir üçgenin iç açıları toplamı her zaman aynıdır.$$,
    $$Adım 2: Bu toplam 180 derecedir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$Ölçme$$, $$Alan$$, 2,
  $$Kenar uzunluğu 6 cm olan karenin alanı kaç cm²'dir?$$,
  jsonb_build_object('A', $$12$$, 'B', $$24$$, 'C', $$36$$, 'D', $$6$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Karenin alanı = kenar × kenar.$$,
    $$Adım 1: Karenin alanı kenar uzunluğunun karesidir.$$,
    $$Adım 2: 6 × 6 işlemi yapılır.$$,
    $$Adım 3: 36 cm². Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Matematik$$, $$İşlemler$$, $$Üslü ifade$$, 3,
  $$2⁴ ifadesinin değeri kaçtır?$$,
  jsonb_build_object('A', $$8$$, 'B', $$16$$, 'C', $$24$$, 'D', $$6$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: 2⁴ = 2 × 2 × 2 × 2 demektir.$$,
    $$Adım 1: Üs, tabanın kaç kez çarpılacağını gösterir: 2 × 2 × 2 × 2.$$,
    $$Adım 2: 2 × 2 = 4; 4 × 2 = 8; 8 × 2 = 16.$$,
    $$Adım 3: 2⁴ = 16. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Coğrafya$$, $$İklim$$, 2,
  $$Bir yerin uzun yıllar boyunca gösterdiği ortalama hava durumuna ne denir?$$,
  jsonb_build_object('A', $$hava durumu$$, 'B', $$iklim$$, 'C', $$mevsim$$, 'D', $$gün$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kısa süreli durum "hava durumu", uzun yılların ortalaması ise başka bir kavramdır.$$,
    $$Adım 1: Hava durumu kısa süreli değişiklikleri gösterir.$$,
    $$Adım 2: Uzun yılların ortalaması iklimdir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Tarih$$, $$İlk Türk devletleri$$, 3,
  $$Türk tarihinde bilinen ilk yazılı belge hangisidir?$$,
  jsonb_build_object('A', $$Orhun Yazıtları$$, 'B', $$Kur'an-ı Kerim$$, 'C', $$Divanü Lugati't-Türk$$, 'D', $$Nutuk$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Göktürkler döneminde yazılan, Türk adının geçtiği ilk yazılı belgelerdir.$$,
    $$Adım 1: Türkçe yazılı ilk belgeler Göktürk dönemine aittir.$$,
    $$Adım 2: Bunlar Orhun Yazıtları'dır (Göktürk Yazıtları).$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Coğrafya$$, $$Türkiye'nin konumu$$, 2,
  $$Türkiye hangi iki kıta üzerinde yer alır?$$,
  jsonb_build_object('A', $$Asya ve Avrupa$$, 'B', $$Afrika ve Asya$$, 'C', $$Avrupa ve Afrika$$, 'D', $$Amerika ve Asya$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Boğazlar, iki kıtayı birbirinden ayırır ve Türkiye her ikisinde de toprağa sahiptir.$$,
    $$Adım 1: Türkiye'nin bir bölümü Asya, bir bölümü Avrupa'dadır.$$,
    $$Adım 2: Bu iki kıta İstanbul ve Çanakkale boğazlarıyla ayrılır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Yönetim$$, $$Demokrasi$$, 2,
  $$Demokraside yöneticiler nasıl belirlenir?$$,
  jsonb_build_object('A', $$Veraset yoluyla$$, 'B', $$Halkın oylarıyla (seçimle)$$, 'C', $$Zorla$$, 'D', $$Kura ile$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Demokrasi, halkın egemenliğine dayanır.$$,
    $$Adım 1: Demokraside egemenlik halka aittir.$$,
    $$Adım 2: Yöneticiler halkın oylarıyla seçilir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Ekonomi$$, $$Üretim-tüketim$$, 2,
  $$Bir ürünün yetiştirilmesi veya yapılmasına ne denir?$$,
  jsonb_build_object('A', $$tüketim$$, 'B', $$üretim$$, 'C', $$dağıtım$$, 'D', $$pazarlama$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Mal ve hizmetlerin ortaya çıkarılması hangi kavramdır?$$,
    $$Adım 1: Ürünün ortaya çıkarılması üretimdir.$$,
    $$Adım 2: Bu ürünün kullanılması ise tüketimdir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Kültür$$, $$Kültürel miras$$, 2,
  $$Aşağıdakilerden hangisi somut olmayan kültürel mirasa örnektir?$$,
  jsonb_build_object('A', $$tarihî bir cami$$, 'B', $$bir türkü$$, 'C', $$bir müze binası$$, 'D', $$bir kale$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Elle tutulup görülemeyen, kuşaktan kuşağa aktarılan kültür ögeleri hangileridir?$$,
    $$Adım 1: Somut miras yapı ve nesnelerdir (cami, müze, kale).$$,
    $$Adım 2: Türkü ise kuşaktan kuşağa aktarılan, elle tutulmayan bir mirastır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Haklar$$, $$Çocuk hakları$$, 2,
  $$Her çocuğun hangi hakka sahip olduğu söylenebilir?$$,
  jsonb_build_object('A', $$Çalışma hakkı$$, 'B', $$Eğitim hakkı$$, 'C', $$Oy kullanma hakkı$$, 'D', $$Ehliyet alma hakkı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Çocukların yaşlarına uygun olan hak hangisidir?$$,
    $$Adım 1: Oy kullanmak ve ehliyet almak belirli bir yaş gerektirir.$$,
    $$Adım 2: Eğitim hakkı her çocuğun temel hakkıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Coğrafya$$, $$Yeryüzü şekilleri$$, 3,
  $$Çevresine göre yüksek olan, geniş düzlüklere ne denir?$$,
  jsonb_build_object('A', $$ova$$, 'B', $$plato$$, 'C', $$vadi$$, 'D', $$körfez$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Yüksekte yer alan, üzeri düz geniş alanlardır.$$,
    $$Adım 1: Ova alçakta ve düz, vadi akarsuyun açtığı çukur, körfez denizin kara içine girdiği yerdir.$$,
    $$Adım 2: Yüksekte bulunan geniş düzlükler platodur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Tarih$$, $$Zaman kavramı$$, 3,
  $$Bir olayın hangi döneme ait olduğunu anlamak için kullanılan ölçü hangisidir?$$,
  jsonb_build_object('A', $$yüzyıl$$, 'B', $$metre$$, 'C', $$kilogram$$, 'D', $$litre$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Tarihî zamanı ifade eden, 100 yıllık döneme ne denir?$$,
    $$Adım 1: Tarihî olaylar zaman içinde sıralanır.$$,
    $$Adım 2: 100 yıllık döneme yüzyıl (asır) denir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Sosyal Bilgiler$$, $$Ekonomi$$, $$Kaynakların kullanımı$$, 3,
  $$Doğal kaynakları bilinçli kullanmak neden önemlidir?$$,
  jsonb_build_object('A', $$Kaynaklar sınırsızdır$$, 'B', $$Kaynaklar tükenebilir, gelecek nesillere de kalmalıdır$$, 'C', $$Kullanmak yasaktır$$, 'D', $$Kaynaklar değersizdir$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Doğal kaynaklar sınırsız değildir; onları korumamız gerekir.$$,
    $$Adım 1: Su, orman, maden gibi kaynaklar sınırlıdır.$$,
    $$Adım 2: Bilinçli kullanım, kaynakların gelecek nesillere kalmasını sağlar.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Sözcükte Anlam$$, $$Mecaz anlam$$, 2,
  $$"Bu işte çok **pişti**." cümlesinde "pişmek" sözcüğü hangi anlamda kullanılmıştır?$$,
  jsonb_build_object('A', $$gerçek anlam$$, 'B', $$mecaz anlam$$, 'C', $$terim anlam$$, 'D', $$eş anlam$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Pişmek" yemek için gerçektir; bir işte tecrübe kazanmak için mecazdır.$$,
    $$Adım 1: Gerçek anlamda "pişmek", ısıyla yemeğin olgunlaşmasıdır.$$,
    $$Adım 2: Burada bir işte tecrübe kazanmak anlatılmaktadır.$$,
    $$Adım 3: Bu kullanım mecaz anlamdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Deyimler$$, $$Deyim anlamı$$, 3,
  $$"Etekleri zil çalmak" deyiminin anlamı nedir?$$,
  jsonb_build_object('A', $$Çok korkmak$$, 'B', $$Çok sevinmek$$, 'C', $$Çok üzülmek$$, 'D', $$Çok yorulmak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Deyim sevinçten dolayı yerinde duramamayı anlatır.$$,
    $$Adım 1: "Etekleri zil çalmak" deyimi sevinçten coşmak anlamına gelir.$$,
    $$Adım 2: Kişinin aşırı sevindiğini gösterir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Cümlede Anlam$$, $$Neden-sonuç$$, 2,
  $$"Hava soğuk olduğu için montunu giydi." cümlesinde sonuç hangisidir?$$,
  jsonb_build_object('A', $$Havanın soğuk olması$$, 'B', $$Montunu giymesi$$, 'C', $$Kış mevsimi$$, 'D', $$Montun yeni olması$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "için"den önceki kısım nedeni, sonraki kısım sonucu gösterir.$$,
    $$Adım 1: Neden: havanın soğuk olması.$$,
    $$Adım 2: Sonuç: montunu giymesi.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Söz Sanatları$$, $$Benzetme$$, 3,
  $$"Gözleri elmas gibi parlıyordu." cümlesinde hangi söz sanatı vardır?$$,
  jsonb_build_object('A', $$kişileştirme$$, 'B', $$benzetme$$, 'C', $$abartma$$, 'D', $$konuşturma$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bir şey, başka bir şeye "gibi" sözcüğüyle benzetiliyor.$$,
    $$Adım 1: Gözler, elmasa benzetilmektedir.$$,
    $$Adım 2: Benzetme, "gibi" edatıyla yapılmıştır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Sözcük Türleri$$, $$Fiil kipleri$$, 3,
  $$"Yarın okula gideceğim." cümlesindeki "gideceğim" fiili hangi zamandadır?$$,
  jsonb_build_object('A', $$şimdiki zaman$$, 'B', $$gelecek zaman$$, 'C', $$geçmiş zaman$$, 'D', $$geniş zaman$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Yarın" sözcüğü gelecek bir zamanı gösterir.$$,
    $$Adım 1: Cümlede "yarın" ifadesi gelecek zamanı belirtir.$$,
    $$Adım 2: "-ecek/-acak" eki gelecek zaman ekidir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Yazım Kuralları$$, $$Sayıların yazımı$$, 3,
  $$Aşağıdaki cümlelerden hangisinde sayı doğru yazılmıştır?$$,
  jsonb_build_object('A', $$Kitabın 3'üncü sayfasını açtı.$$, 'B', $$Kitabın üçüncü sayfasını açtı.$$, 'C', $$Kitabın 3üncü sayfasını açtı.$$, 'D', $$Kitabın üç üncü sayfasını açtı.$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sıra bildiren sayılar yazıyla yazıldığında bitişik yazılır: "üçüncü".$$,
    $$Adım 1: Sıra sayıları yazıyla "üçüncü" şeklinde bitişik yazılır.$$,
    $$Adım 2: "3'üncü" yazımı yaygın olsa da doğru kullanım yazıyla yazmaktır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Noktalama İşaretleri$$, $$İki nokta$$, 3,
  $$"Şu dersleri çok severim: matematik, fen ve Türkçe." cümlesinde iki nokta neden kullanılmıştır?$$,
  jsonb_build_object('A', $$Cümleyi bitirmek için$$, 'B', $$Açıklama veya örnek sıralamak için$$, 'C', $$Soru sormak için$$, 'D', $$Alıntı yapmak için$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İki noktadan sonra bir açıklama ya da örnekler sıralanıyor.$$,
    $$Adım 1: İki noktadan sonra örnekler sıralanmıştır.$$,
    $$Adım 2: İki nokta, açıklama ve örnek vermek için kullanılır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Sözcükte Anlam$$, $$Terim anlam$$, 3,
  $$"Bu şiirde **ölçü** çok düzgündür." cümlesinde "ölçü" sözcüğü hangi anlamda kullanılmıştır?$$,
  jsonb_build_object('A', $$gerçek anlam$$, 'B', $$mecaz anlam$$, 'C', $$terim anlam$$, 'D', $$yan anlam$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "Ölçü" burada edebiyatla ilgili bir kavramdır; bir sanat dalına özgü anlam terim anlamdır.$$,
    $$Adım 1: Şiirdeki "ölçü", edebiyata özgü bir kavramdır.$$,
    $$Adım 2: Bir bilim veya sanat dalına özgü anlam terim anlamdır.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Cümlede Anlam$$, $$Öznellik-nesnellik$$, 3,
  $$"Bu kitap çok sürükleyici." cümlesi için hangisi doğrudur?$$,
  jsonb_build_object('A', $$Nesnel bir yargıdır$$, 'B', $$Öznel bir yargıdır$$, 'C', $$Bir sayı belirtir$$, 'D', $$Bir soru içerir$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Kişisel beğeni ve duygu bildiren yargılar özneldir.$$,
    $$Adım 1: "Sürükleyici" ifadesi kişisel bir beğenidir.$$,
    $$Adım 2: Kişisel beğeni bildiren yargılar öznel yargılardır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 6, $$Türkçe$$, $$Atasözleri$$, $$Atasözü anlamı$$, 3,
  $$"Bir elin nesi var, iki elin sesi var." atasözü bize ne anlatır?$$,
  jsonb_build_object('A', $$Ellerin çok olduğunu$$, 'B', $$İşbirliği ve yardımlaşmanın önemini$$, 'C', $$Sesin gür çıktığını$$, 'D', $$Yalnız çalışmanın yararını$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Tek başına yapılanla birlikte yapılanı karşılaştırıyor.$$,
    $$Adım 1: Atasözü tek kişi ile iki kişinin işini karşılaştırır.$$,
    $$Adım 2: Birlikte çalışmanın daha başarılı olacağını anlatır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$İnanç$$, $$Melek inancı$$, 2,
  $$Görünmeyen, nurdan yaratılmış varlıklara ne denir?$$,
  jsonb_build_object('A', $$melek$$, 'B', $$insan$$, 'C', $$hayvan$$, 'D', $$bitki$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Gözle görülmeyen, nurdan yaratılan varlıklar hangileridir?$$,
    $$Adım 1: Melekler görünmeyen, nurdan yaratılmış varlıklardır.$$,
    $$Adım 2: İnsan, hayvan ve bitki görünen varlıklardır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$Ahlak$$, $$Doğruluk$$, 2,
  $$Doğru sözlü olmak neden önemlidir?$$,
  jsonb_build_object('A', $$İnsanların bize güvenmesini sağlar$$, 'B', $$Bizi yalnızlaştırır$$, 'C', $$Sorun çıkarır$$, 'D', $$Zaman kaybettirir$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Doğru sözlü kişiye çevresi nasıl davranır?$$,
    $$Adım 1: Doğru sözlü kişiye güvenilir.$$,
    $$Adım 2: Güven, sağlam ilişkilerin temelidir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$Ahlak$$, $$Adalet$$, 3,
  $$Adaletli davranmak ne demektir?$$,
  jsonb_build_object('A', $$Herkese hak ettiğini vermek$$, 'B', $$Sadece arkadaşları kayırmak$$, 'C', $$Taraf tutmak$$, 'D', $$Güçlüyü desteklemek$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Adalet, hak sahibine hakkını vermektir.$$,
    $$Adım 1: Adalet, hakların gözetilmesidir.$$,
    $$Adım 2: Herkese hak ettiği şekilde davranmak adalettir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$Değerler$$, $$Hoşgörü$$, 2,
  $$Hoşgörülü insan nasıl davranır?$$,
  jsonb_build_object('A', $$Başkalarının farklılıklarını anlayışla karşılar$$, 'B', $$Herkesle kavga eder$$, 'C', $$Kimseyi dinlemez$$, 'D', $$Sadece kendini düşünür$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Hoşgörü, farklılıkları anlayışla karşılamaktır.$$,
    $$Adım 1: Hoşgörü, farklı görüş ve davranışlara saygıdır.$$,
    $$Adım 2: Hoşgörülü kişi, başkalarını anlayışla karşılar.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$İnanç$$, $$Ahiret inancı$$, 3,
  $$Ahiret inancının kişiye etkisi nedir?$$,
  jsonb_build_object('A', $$Sorumluluk bilincini artırır$$, 'B', $$Sorumluluğu azaltır$$, 'C', $$Umursamazlığı artırır$$, 'D', $$Bencilliği artırır$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Ahirete inanan kişi davranışlarının hesabını vereceğini bilir.$$,
    $$Adım 1: Ahiret inancı, yapılanların karşılığının olacağını bildirir.$$,
    $$Adım 2: Bu, kişide sorumluluk bilincini artırır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$Ahlak$$, $$Yardımlaşma$$, 2,
  $$Yardımlaşmanın topluma katkısı nedir?$$,
  jsonb_build_object('A', $$Birlik ve dayanışmayı güçlendirir$$, 'B', $$İnsanları uzaklaştırır$$, 'C', $$Kavgayı artırır$$, 'D', $$Güveni azaltır$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Yardımlaşan toplumda insanlar birbirine nasıl bağlanır?$$,
    $$Adım 1: Yardımlaşma, insanların birbirine destek olmasıdır.$$,
    $$Adım 2: Bu, toplumda birlik ve dayanışmayı güçlendirir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$Çevre$$, $$Doğa ve sorumluluk$$, 2,
  $$Doğayı korumak neden bir sorumluluktur?$$,
  jsonb_build_object('A', $$Doğa, tüm canlıların ortak yaşam alanıdır$$, 'B', $$Doğa değersizdir$$, 'C', $$Doğa sınırsızdır$$, 'D', $$Doğa zararlıdır$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: İnsan ve diğer canlılar aynı ortamı paylaşır.$$,
    $$Adım 1: Doğa, tüm canlıların ortak yaşam alanıdır.$$,
    $$Adım 2: Bu yüzden onu korumak herkesin sorumluluğudur.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$Değerler$$, $$Sabır ve şükür$$, 3,
  $$Şükretmek ne anlama gelir?$$,
  jsonb_build_object('A', $$Eldekilerin değerini bilip teşekkür etmek$$, 'B', $$Sürekli şikâyet etmek$$, 'C', $$Hiçbir şeyi beğenmemek$$, 'D', $$Kimseye teşekkür etmemek$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Şükür, sahip olunanların değerini bilmektir.$$,
    $$Adım 1: Şükür, elde olanların farkına varmaktır.$$,
    $$Adım 2: Bu, kişinin teşekkür etmesini ve huzurlu olmasını sağlar.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$Aile$$, $$Aile değerleri$$, 2,
  $$Aile içinde huzuru sağlayan temel değer hangisidir?$$,
  jsonb_build_object('A', $$Sevgi ve saygı$$, 'B', $$Kızgınlık$$, 'C', $$Kıskançlık$$, 'D', $$İnatlaşma$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Aile bireyleri birbirine nasıl davranırsa ev huzurlu olur?$$,
    $$Adım 1: Aile, sevgi ve saygı ile bir arada olur.$$,
    $$Adım 2: Bu değerler aile içinde huzuru sağlar.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Din Kültürü$$, $$Ahlak$$, $$Dürüstlük ve emanet$$, 3,
  $$Kendisine emanet edilen bir şeyi korumak hangi değerle ilgilidir?$$,
  jsonb_build_object('A', $$Emanete sahip çıkmak$$, 'B', $$İsraf etmek$$, 'C', $$Kayıtsız kalmak$$, 'D', $$Önemsememek$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Bırakılan bir eşyayı korumak hangi değerdir?$$,
    $$Adım 1: Emanet, korunması gereken bir güven unsurudur.$$,
    $$Adım 2: Emaneti korumak, dürüstlük ve güvenilirliği gösterir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$Güneş Sistemi ve Ötesi$$, $$Yıldızlar$$, 2,
  $$Kendi ışığını üreten gök cisimlerine ne denir?$$,
  jsonb_build_object('A', $$gezegen$$, 'B', $$yıldız$$, 'C', $$uydu$$, 'D', $$kuyruklu yıldız$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Güneş gibi kendi ışığını veren cisimler hangi gruptandır?$$,
    $$Adım 1: Gezegenler ve uydular ışığı yansıtır, kendileri üretmez.$$,
    $$Adım 2: Kendi ışığını üreten gök cismi yıldızdır (ör. Güneş).$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$Vücut Sistemleri$$, $$Dolaşım sistemi$$, 2,
  $$Kanı vücutta pompalayan organ hangisidir?$$,
  jsonb_build_object('A', $$akciğer$$, 'B', $$kalp$$, 'C', $$böbrek$$, 'D', $$karaciğer$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Dolaşım sisteminin merkezindeki kaslı organdır.$$,
    $$Adım 1: Dolaşım sistemi kanı vücuda taşır.$$,
    $$Adım 2: Kanı pompalayan organ kalptir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$Kuvvet ve Enerji$$, $$İş$$, 3,
  $$Bir cisme kuvvet uygulanıp cisim kuvvet yönünde yol alıyorsa ne yapılmıştır?$$,
  jsonb_build_object('A', $$Enerji harcanmamıştır$$, 'B', $$İş yapılmıştır$$, 'C', $$Kuvvet uygulanmamıştır$$, 'D', $$Cisim durmuştur$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İş, kuvvet ile yolun çarpımıdır. Yol varsa iş vardır.$$,
    $$Adım 1: İş yapılması için kuvvet ve yol birlikte gerekir.$$,
    $$Adım 2: Kuvvet uygulanıp cisim yol alıyorsa iş yapılmıştır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$Madde$$, $$Atom$$, 2,
  $$Maddenin en küçük yapı taşına ne denir?$$,
  jsonb_build_object('A', $$hücre$$, 'B', $$atom$$, 'C', $$molekül$$, 'D', $$doku$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Maddenin kendine özgü özelliklerini taşıyan en küçük parçasıdır.$$,
    $$Adım 1: Madde atomlardan oluşur.$$,
    $$Adım 2: Maddenin en küçük yapı taşı atomdur.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$Işık$$, $$Işığın soğurulması$$, 3,
  $$Siyah renkli cisimler ışığı nasıl davranır?$$,
  jsonb_build_object('A', $$Tamamen yansıtır$$, 'B', $$Çoğunu soğurur$$, 'C', $$Hiç etkileşmez$$, 'D', $$Işık üretir$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Siyah cisimler neden yazın daha çok ısınır?$$,
    $$Adım 1: Siyah cisimler ışığın büyük kısmını soğurur.$$,
    $$Adım 2: Soğurulan ışık enerjisi ısıya dönüşür, cisim ısınır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$Elektrik$$, $$Elektrik devresi$$, 3,
  $$Bir devrede ampulün parlaklığını artırmak için ne yapılabilir?$$,
  jsonb_build_object('A', $$Pil sayısını artırmak$$, 'B', $$Pil sayısını azaltmak$$, 'C', $$Kabloyu uzatmak$$, 'D', $$Ampulü çıkarmak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Daha çok pil, devreye daha çok enerji verir.$$,
    $$Adım 1: Devredeki gerilim arttıkça ampul daha parlak yanar.$$,
    $$Adım 2: Pil sayısını artırmak gerilimi artırır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$Canlılar$$, $$Üreme$$, 2,
  $$Bitkilerde tozlaşmayı sağlayan canlılar hangileridir?$$,
  jsonb_build_object('A', $$arılar ve kelebekler$$, 'B', $$balıklar$$, 'C', $$yılanlar$$, 'D', $$solucanlar$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Çiçekten çiçeğe konan, polen taşıyan canlıları düşün.$$,
    $$Adım 1: Tozlaşma, polenin bir çiçekten diğerine taşınmasıdır.$$,
    $$Adım 2: Arılar ve kelebekler çiçeklere konarak tozlaşmayı sağlar.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$Kuvvet ve Enerji$$, $$Enerji dönüşümü$$, 3,
  $$Bir elektrik süpürgesinde hangi enerji dönüşümü gerçekleşir?$$,
  jsonb_build_object('A', $$Elektrik enerjisi → hareket enerjisi$$, 'B', $$Isı enerjisi → ışık enerjisi$$, 'C', $$Kimyasal enerji → ses enerjisi$$, 'D', $$Hareket enerjisi → kimyasal enerji$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Süpürge elektrikle çalışır ve motoru döner.$$,
    $$Adım 1: Süpürge elektrik enerjisiyle çalışır.$$,
    $$Adım 2: Motor dönerek hareket enerjisi üretir.$$,
    $$Adım 3: Dönüşüm elektrik → hareket enerjisidir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$Madde$$, $$Karışımların ayrılması$$, 3,
  $$Tuzlu suyu ayırıp tuzu elde etmek için hangi yöntem kullanılır?$$,
  jsonb_build_object('A', $$Süzme$$, 'B', $$Buharlaştırma$$, 'C', $$Mıknatısla ayırma$$, 'D', $$Eleme$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Suyu uçurup geriye tuzu bırakan yöntem hangisidir?$$,
    $$Adım 1: Tuzlu suda tuz çözünmüş hâldedir, süzme ile ayrılmaz.$$,
    $$Adım 2: Suyu buharlaştırırsak geriye tuz kalır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Fen Bilimleri$$, $$İnsan Sağlığı$$, $$Denetleyici sistem$$, 3,
  $$Vücudumuzdaki sistemlerin çalışmasını düzenleyen ve denetleyen sistem hangisidir?$$,
  jsonb_build_object('A', $$sindirim sistemi$$, 'B', $$sinir sistemi$$, 'C', $$iskelet sistemi$$, 'D', $$boşaltım sistemi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Beyin ve omurilikle ilgili olan, hızlı ileti taşıyan sistem hangisidir?$$,
    $$Adım 1: Sinir sistemi, beyin ve omurilikten oluşur.$$,
    $$Adım 2: Diğer sistemlerin çalışmasını düzenler ve denetler.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Comparatives$$, $$Karşılaştırma$$, 3,
  $$"An elephant is ____ than a mouse." boşluğa hangi sözcük gelmelidir?$$,
  jsonb_build_object('A', $$big$$, 'B', $$bigger$$, 'C', $$biggest$$, 'D', $$more big$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: İki şeyi karşılaştırırken kısa sıfatlara "-er" eklenir.$$,
    $$Adım 1: "than" sözcüğü karşılaştırma yapıldığını gösterir.$$,
    $$Adım 2: Kısa sıfatlarda karşılaştırma "-er" ekiyle yapılır: bigger.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Simple Past$$, $$Geçmiş zaman$$, 3,
  $$"I ____ to the cinema yesterday." boşluğa hangi sözcük gelmelidir?$$,
  jsonb_build_object('A', $$go$$, 'B', $$goes$$, 'C', $$went$$, 'D', $$going$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "yesterday" geçmiş zamanı gösterir; "go" fiilinin geçmiş hâli nedir?$$,
    $$Adım 1: "yesterday" geçmiş zaman ifadesidir.$$,
    $$Adım 2: "go" fiilinin geçmiş hâli "went"tir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Future Plans$$, $$Gelecek zaman$$, 3,
  $$"I am going to visit my grandmother tomorrow." cümlesinde kişi ne yapacak?$$,
  jsonb_build_object('A', $$Büyükannesini ziyaret edecek$$, 'B', $$Sinemaya gidecek$$, 'C', $$Kitap okuyacak$$, 'D', $$Spor yapacak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "visit my grandmother" ifadesi ne anlama gelir?$$,
    $$Adım 1: "visit" ziyaret etmek, "grandmother" büyükanne demektir.$$,
    $$Adım 2: Cümle yarın büyükannesini ziyaret edeceğini söyler.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Health$$, $$Sağlık$$, 2,
  $$"You should see a doctor." cümlesi ne tavsiye eder?$$,
  jsonb_build_object('A', $$Bir doktora görünmeni$$, 'B', $$Eve gitmeni$$, 'C', $$Yemek yemeni$$, 'D', $$Uyumanı$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "should" tavsiye bildirir; "doctor" doktor demektir.$$,
    $$Adım 1: "should" tavsiye anlamı taşır.$$,
    $$Adım 2: "see a doctor" bir doktora görünmek demektir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Environment$$, $$Çevre$$, 3,
  $$"We should recycle paper and plastic." cümlesi bize neyi öneriyor?$$,
  jsonb_build_object('A', $$Kâğıt ve plastiği geri dönüştürmeyi$$, 'B', $$Suyu boşa akıtmayı$$, 'C', $$Çöpü yere atmayı$$, 'D', $$Ağaçları kesmeyi$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "recycle" geri dönüştürmek demektir.$$,
    $$Adım 1: "recycle" geri dönüştürmek anlamına gelir.$$,
    $$Adım 2: Cümle kâğıt ve plastiği geri dönüştürmeyi öneriyor.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Preferences$$, $$Tercihler$$, 2,
  $$"I prefer tea to coffee." cümlesine göre kişi hangisini tercih eder?$$,
  jsonb_build_object('A', $$kahveyi$$, 'B', $$çayı$$, 'C', $$suyu$$, 'D', $$sütü$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "prefer A to B" = "B yerine A'yı tercih ederim".$$,
    $$Adım 1: "prefer ... to ..." kalıbında ilk sözcük tercih edilendir.$$,
    $$Adım 2: "tea" (çay) kahveye tercih edilmiştir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Superlatives$$, $$En üstünlük$$, 3,
  $$"Mount Everest is the ____ mountain in the world." boşluğa hangi sözcük gelmelidir?$$,
  jsonb_build_object('A', $$high$$, 'B', $$higher$$, 'C', $$highest$$, 'D', $$more high$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "the" ve "in the world" ifadeleri en üstünlük derecesini gösterir.$$,
    $$Adım 1: "in the world" ifadesi karşılaştırılan en üstün durumu belirtir.$$,
    $$Adım 2: Kısa sıfatlarda en üstünlük "-est" ile yapılır: highest.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Simple Past$$, $$Olumsuz geçmiş zaman$$, 3,
  $$"She didn't come to school." cümlesinin anlamı hangisidir?$$,
  jsonb_build_object('A', $$Okula geldi$$, 'B', $$Okula gelmedi$$, 'C', $$Okula gelecek$$, 'D', $$Okula gidiyor$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "didn't" olumsuzluk ekidir ve geçmiş zamanı gösterir.$$,
    $$Adım 1: "didn't" geçmiş zamanda olumsuzluk bildirir.$$,
    $$Adım 2: "come to school" okula gelmek demektir.$$,
    $$Adım 3: Cümle "Okula gelmedi." anlamına gelir. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Directions$$, $$Yol tarifi$$, 2,
  $$"Go straight ahead." ifadesinin Türkçe anlamı hangisidir?$$,
  jsonb_build_object('A', $$Düz git$$, 'B', $$Sağa dön$$, 'C', $$Sola dön$$, 'D', $$Geri dön$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "straight" düz, "ahead" ileri demektir.$$,
    $$Adım 1: "straight" düz, "ahead" ileri anlamına gelir.$$,
    $$Adım 2: "Go straight ahead." = "Düz git." demektir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$İngilizce$$, $$Weather$$, $$Hava durumu$$, 2,
  $$"It is raining." cümlesinde hava nasıldır?$$,
  jsonb_build_object('A', $$yağmurlu$$, 'B', $$güneşli$$, 'C', $$karlı$$, 'D', $$rüzgarlı$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "rain" yağmur demektir.$$,
    $$Adım 1: "rain" yağmur anlamına gelir.$$,
    $$Adım 2: "It is raining." = "Yağmur yağıyor." demektir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Tam Sayılar$$, $$Tam sayılarda işlem$$, 2,
  $$(-5) + (+8) işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$-13$$, 'B', $$3$$, 'C', $$-3$$, 'D', $$13$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Zıt işaretli sayılarda büyükten küçük çıkarılır, sonucun işareti büyük olanın işaretidir.$$,
    $$Adım 1: İki sayı zıt işaretlidir.$$,
    $$Adım 2: 8 - 5 = 3; büyük olan (+8) pozitif olduğu için sonuç pozitiftir.$$,
    $$Adım 3: Sonuç 3'tür. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Rasyonel Sayılar$$, $$Ondalık-rasyonel dönüşüm$$, 3,
  $$3/4 kesrinin ondalık gösterimi hangisidir?$$,
  jsonb_build_object('A', $$0,34$$, 'B', $$0,75$$, 'C', $$0,43$$, 'D', $$0,80$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: 3'ü 4'e böl: 3 ÷ 4.$$,
    $$Adım 1: Kesri ondalığa çevirmek için payı paydaya böleriz.$$,
    $$Adım 2: 3 ÷ 4 = 0,75.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Cebir$$, $$Cebirsel ifade$$, 3,
  $$x = 4 için 3x + 5 ifadesinin değeri kaçtır?$$,
  jsonb_build_object('A', $$12$$, 'B', $$17$$, 'C', $$20$$, 'D', $$9$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: x yerine 4 yaz: 3 × 4 + 5.$$,
    $$Adım 1: x = 4 değerini yerine koyarız: 3 × 4 + 5.$$,
    $$Adım 2: Önce çarpma: 3 × 4 = 12.$$,
    $$Adım 3: 12 + 5 = 17. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Oran-Orantı$$, $$Doğru orantı$$, 3,
  $$4 kalem 20 lira ise 7 kalem kaç liradır?$$,
  jsonb_build_object('A', $$28$$, 'B', $$32$$, 'C', $$35$$, 'D', $$40$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Bir kalemin fiyatını bul, sonra 7 ile çarp.$$,
    $$Adım 1: 1 kalemin fiyatı: 20 ÷ 4 = 5 lira.$$,
    $$Adım 2: 7 kalemin fiyatı: 5 × 7.$$,
    $$Adım 3: 5 × 7 = 35 lira. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Yüzdeler$$, $$Yüzde hesaplama$$, 3,
  $$200 liranın %15'i kaç liradır?$$,
  jsonb_build_object('A', $$15$$, 'B', $$20$$, 'C', $$30$$, 'D', $$45$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: %15 = 15/100. Bunu 200 ile çarp.$$,
    $$Adım 1: 200'ün %15'i = 200 × 15/100.$$,
    $$Adım 2: 200 ÷ 100 = 2; 2 × 15 = 30.$$,
    $$Adım 3: Sonuç 30 liradır. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Geometri$$, $$Dörtgenler$$, 2,
  $$Karşılıklı kenarları eşit ve paralel, bütün açıları dik olan dörtgene ne denir?$$,
  jsonb_build_object('A', $$eşkenar dörtgen$$, 'B', $$dikdörtgen$$, 'C', $$yamuk$$, 'D', $$paralelkenar$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bütün açıları 90 derece olan dörtgen hangisidir?$$,
    $$Adım 1: Eşkenar dörtgenin açıları dik değildir.$$,
    $$Adım 2: Bütün açıları dik olan ve karşılıklı kenarları eşit olan şekil dikdörtgendir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Geometri$$, $$Çokgenler$$, 3,
  $$Bir dörtgenin iç açıları toplamı kaç derecedir?$$,
  jsonb_build_object('A', $$180$$, 'B', $$270$$, 'C', $$360$$, 'D', $$540$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Dörtgeni bir köşegenle iki üçgene ayır; her üçgen 180 derecedir.$$,
    $$Adım 1: Dörtgen, bir köşegenle iki üçgene ayrılır.$$,
    $$Adım 2: Her üçgenin iç açıları toplamı 180 derecedir.$$,
    $$Adım 3: 2 × 180 = 360 derece. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Veri$$, $$Ortalama$$, 2,
  $$6, 8, 10, 12 sayılarının aritmetik ortalaması kaçtır?$$,
  jsonb_build_object('A', $$8$$, 'B', $$9$$, 'C', $$10$$, 'D', $$36$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Önce tüm sayıları topla, sonra sayı adedine böl.$$,
    $$Adım 1: Sayıların toplamı: 6 + 8 + 10 + 12 = 36.$$,
    $$Adım 2: 4 sayı olduğu için 4'e böleriz.$$,
    $$Adım 3: 36 ÷ 4 = 9. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Rasyonel Sayılar$$, $$Sıralama$$, 3,
  $$1/2, 2/3, 3/5 kesirlerinden en büyüğü hangisidir?$$,
  jsonb_build_object('A', $$1/2$$, 'B', $$2/3$$, 'C', $$3/5$$, 'D', $$Hepsi eşit$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Ondalığa çevir: 1/2 = 0,5; 2/3 ≈ 0,67; 3/5 = 0,6.$$,
    $$Adım 1: 1/2 = 0,5; 3/5 = 0,6.$$,
    $$Adım 2: 2/3 ≈ 0,67'dir.$$,
    $$Adım 3: En büyük 2/3'tür. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Matematik$$, $$Cebir$$, $$Denklem çözme$$, 3,
  $$2x - 3 = 11 ise x kaçtır?$$,
  jsonb_build_object('A', $$4$$, 'B', $$7$$, 'C', $$8$$, 'D', $$14$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Önce her iki tarafa 3 ekle: 2x = 14. Sonra ikiye böl.$$,
    $$Adım 1: 2x - 3 = 11 → her iki tarafa 3 eklenir: 2x = 14.$$,
    $$Adım 2: Her iki taraf 2'ye bölünür: x = 7.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$İletişim$$, $$Kitle iletişim$$, 2,
  $$Aşağıdakilerden hangisi kitle iletişim aracıdır?$$,
  jsonb_build_object('A', $$televizyon$$, 'B', $$kitap defteri$$, 'C', $$kalem$$, 'D', $$silgi$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Aynı anda çok sayıda kişiye bilgi ulaştıran araçlar kitle iletişim aracıdır.$$,
    $$Adım 1: Kitle iletişim araçları çok sayıda insana aynı anda ulaşır.$$,
    $$Adım 2: Televizyon böyle bir araçtır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$Nüfus ve Göç$$, $$Göç nedenleri$$, 3,
  $$Aşağıdakilerden hangisi göçün ekonomik nedenidir?$$,
  jsonb_build_object('A', $$İş bulmak için başka şehre taşınmak$$, 'B', $$Deprem sonrası evden ayrılmak$$, 'C', $$Savaştan kaçmak$$, 'D', $$Kuraklık nedeniyle yer değiştirmek$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Ekonomi, iş ve gelirle ilgilidir. Hangi seçenek iş bulmayla ilgilidir?$$,
    $$Adım 1: Göç nedenleri ekonomik, sosyal ve doğal olabilir.$$,
    $$Adım 2: İş bulmak için taşınmak ekonomik bir göç nedenidir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$Osmanlı Tarihi$$, $$Kuruluş$$, 3,
  $$Osmanlı Devleti'nin kurucusu kimdir?$$,
  jsonb_build_object('A', $$Osman Bey$$, 'B', $$Fatih Sultan Mehmet$$, 'C', $$Kanuni Sultan Süleyman$$, 'D', $$Yavuz Sultan Selim$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Devlet, adını kurucusundan almıştır.$$,
    $$Adım 1: Osmanlı Devleti'nin kurucusu Osman Bey'dir.$$,
    $$Adım 2: Devlet adını da ondan alır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$Demokrasi$$, $$Temel haklar$$, 2,
  $$Düşüncelerini özgürce açıklayabilmek hangi hakla ilgilidir?$$,
  jsonb_build_object('A', $$Eğitim hakkı$$, 'B', $$İfade özgürlüğü$$, 'C', $$Sağlık hakkı$$, 'D', $$Barınma hakkı$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Düşünceyi açıklama hangi özgürlüktür?$$,
    $$Adım 1: Düşünce ve görüşleri açıklama hakkı vardır.$$,
    $$Adım 2: Bu, ifade özgürlüğüdür.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$Ekonomik Gelişme$$, $$Üretim faktörleri$$, 3,
  $$Bir üretim faaliyeti için gereken temel unsurlardan biri hangisidir?$$,
  jsonb_build_object('A', $$Emek$$, 'B', $$Tatil$$, 'C', $$Oyun$$, 'D', $$Eğlence$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Üretim için insan gücü, sermaye ve doğal kaynak gerekir.$$,
    $$Adım 1: Üretim faktörleri emek, sermaye, doğal kaynak ve girişimcidir.$$,
    $$Adım 2: Emek, insan gücünü ifade eder.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$Nüfus$$, $$Nüfus yoğunluğu$$, 3,
  $$Bir yerde nüfus yoğunluğunun fazla olmasının nedeni hangisi olabilir?$$,
  jsonb_build_object('A', $$İş imkânlarının fazla olması$$, 'B', $$Ulaşımın zor olması$$, 'C', $$İklimin çok sert olması$$, 'D', $$Tarım alanlarının az olması$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: İnsanlar iş ve yaşam kolaylığı olan yerlere yerleşir.$$,
    $$Adım 1: Nüfus, yaşam koşullarının uygun olduğu yerlerde yoğunlaşır.$$,
    $$Adım 2: İş imkânlarının fazlalığı nüfusu artırır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$Uluslararası İlişkiler$$, $$Uluslararası kuruluşlar$$, 3,
  $$Ülkeler arası barış ve işbirliğini sağlamak amacıyla kurulan uluslararası örgüt hangisidir?$$,
  jsonb_build_object('A', $$Birleşmiş Milletler$$, 'B', $$Bir mahalle derneği$$, 'C', $$Bir okul aile birliği$$, 'D', $$Bir spor kulübü$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Ülkelerin temsil edildiği, barışı amaçlayan büyük örgüttür.$$,
    $$Adım 1: Uluslararası barış ve işbirliği için örgütler kurulmuştur.$$,
    $$Adım 2: Bunların en büyüğü Birleşmiş Milletler'dir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$Osmanlı Tarihi$$, $$İstanbul'un fethi$$, 3,
  $$İstanbul'u fethederek Osmanlı Devleti'nin başkenti yapan padişah kimdir?$$,
  jsonb_build_object('A', $$Osman Bey$$, 'B', $$Fatih Sultan Mehmet$$, 'C', $$Kanuni Sultan Süleyman$$, 'D', $$Orhan Bey$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: 1453'te İstanbul'u fetheden padişahtır.$$,
    $$Adım 1: İstanbul 1453'te fethedilmiştir.$$,
    $$Adım 2: Fetheden padişah Fatih Sultan Mehmet'tir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$İletişim$$, $$Medya okuryazarlığı$$, 3,
  $$İnternette karşılaştığımız bir bilgiyi paylaşmadan önce ne yapmalıyız?$$,
  jsonb_build_object('A', $$Hemen paylaşmalıyız$$, 'B', $$Bilginin doğruluğunu araştırmalıyız$$, 'C', $$Görmezden gelmeliyiz$$, 'D', $$Değiştirip yaymalıyız$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Yanlış bilgi yaymak zararlı olabilir; bu yüzden önce doğruluğunu kontrol etmeliyiz.$$,
    $$Adım 1: İnternette yanlış bilgiler bulunabilir.$$,
    $$Adım 2: Paylaşmadan önce bilginin doğruluğu araştırılmalıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Sosyal Bilgiler$$, $$Ekonomik Gelişme$$, $$Vergi$$, 3,
  $$Vergi ödemenin toplumsal amacı nedir?$$,
  jsonb_build_object('A', $$Devlete gelir sağlayıp kamu hizmetlerini finanse etmek$$, 'B', $$Kişisel zenginlik elde etmek$$, 'C', $$Rekabeti artırmak$$, 'D', $$Ticareti durdurmak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Vergiler yollar, okullar, hastaneler gibi hizmetler için kullanılır.$$,
    $$Adım 1: Vergi, devletin temel gelir kaynağıdır.$$,
    $$Adım 2: Bu gelir kamu hizmetlerine harcanır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Paragrafta Anlam$$, $$Ana düşünce$$, 3,
  $$"Spor yapmak, sağlıklı bir yaşamın vazgeçilmez parçasıdır. Düzenli egzersiz kalbi güçlendirir, stresi azaltır ve uyku kalitesini artırır." paragrafının ana düşüncesi nedir?$$,
  jsonb_build_object('A', $$Spor pahalıdır$$, 'B', $$Spor yapmak sağlık için önemlidir$$, 'C', $$Uyku her şeyden önemlidir$$, 'D', $$Spor sadece çocuklar içindir$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Paragraf sporu ve sağlığı ilişkilendiriyor.$$,
    $$Adım 1: Paragraf sporun yararlarını sıralamaktadır.$$,
    $$Adım 2: Bu, sporun sağlık için önemli olduğunu gösterir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Fiiller$$, $$Fiil kipleri$$, 3,
  $$"Keşke burada olsaydı." cümlesindeki "olsaydı" fiili hangi kiptedir?$$,
  jsonb_build_object('A', $$istek kipi$$, 'B', $$dilek-koşul kipi$$, 'C', $$gereklilik kipi$$, 'D', $$emir kipi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "-se/-sa" eki dilek-koşul kipini oluşturur.$$,
    $$Adım 1: "olsaydı" fiilinde "-sa" eki bulunur.$$,
    $$Adım 2: "-se/-sa" eki dilek-koşul kipidir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Cümlenin Ögeleri$$, $$Özne$$, 3,
  $$"Küçük çocuk parkta top oynadı." cümlesinin öznesi hangisidir?$$,
  jsonb_build_object('A', $$küçük çocuk$$, 'B', $$parkta$$, 'C', $$top$$, 'D', $$oynadı$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Özne, cümlede işi yapan varlıktır. Oynayan kim?$$,
    $$Adım 1: Cümlede oynama işini yapan varlık "küçük çocuk"tur.$$,
    $$Adım 2: İşi yapan öğe öznedir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Söz Sanatları$$, $$Kişileştirme$$, 3,
  $$"Bulutlar ağlıyordu o gün." cümlesinde hangi söz sanatı vardır?$$,
  jsonb_build_object('A', $$benzetme$$, 'B', $$kişileştirme$$, 'C', $$abartma$$, 'D', $$konuşturma$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Ağlamak insana özgüdür; bu özellik buluta verilmiştir.$$,
    $$Adım 1: "Ağlamak" insana ait bir özelliktir.$$,
    $$Adım 2: Bu özellik bulutlara verilerek bulutlar kişileştirilmiştir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Sözcükte Anlam$$, $$Deyim$$, 3,
  $$"Kulak kabartmak" deyiminin anlamı nedir?$$,
  jsonb_build_object('A', $$Kulağı ağrımak$$, 'B', $$Dikkatlice dinlemek$$, 'C', $$Kulağını tutmak$$, 'D', $$Sağır olmak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Deyim, belli etmeden dinlemeye çalışmayı anlatır.$$,
    $$Adım 1: "Kulak kabartmak" gerçekten kulağı hareket ettirmek değildir.$$,
    $$Adım 2: Bir konuşmayı dikkatle, belli etmeden dinlemek anlamına gelir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Cümlede Anlam$$, $$Neden-sonuç$$, 3,
  $$"Sınavı kazandı, çünkü düzenli çalıştı." cümlesinde neden hangisidir?$$,
  jsonb_build_object('A', $$Sınavı kazanması$$, 'B', $$Düzenli çalışması$$, 'C', $$Sınavın kolay olması$$, 'D', $$Şanslı olması$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "çünkü" bağlacından sonraki kısım nedeni gösterir.$$,
    $$Adım 1: "çünkü" bağlacı neden bildirir.$$,
    $$Adım 2: Düzenli çalışmak, sınavı kazanmanın nedenidir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Yazım Kuralları$$, $$Düzeltme işareti ve yazım$$, 3,
  $$Aşağıdaki cümlelerden hangisinde yazım yanlışı yoktur?$$,
  jsonb_build_object('A', $$Herşey yolunda gidiyor.$$, 'B', $$Her şey yolunda gidiyor.$$, 'C', $$Herşeyyolunda gidiyor.$$, 'D', $$Herşey yolun da gidiyor.$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "Her şey" her zaman ayrı yazılır.$$,
    $$Adım 1: "Her şey" sözcüğü her zaman ayrı yazılır.$$,
    $$Adım 2: A, C ve D seçeneklerinde yazım yanlışı vardır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Cümlenin Ögeleri$$, $$Nesne$$, 3,
  $$"Kitabı masaya koydu." cümlesinde belirtili nesne hangisidir?$$,
  jsonb_build_object('A', $$kitabı$$, 'B', $$masaya$$, 'C', $$koydu$$, 'D', $$yok$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Nesne, işten etkilenen varlıktır. Koyulan şey nedir?$$,
    $$Adım 1: Koyma işinden etkilenen varlık "kitap"tır.$$,
    $$Adım 2: "-ı" belirtme ekini alan nesne belirtili nesnedir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Sözcükte Anlam$$, $$Mecaz anlam$$, 2,
  $$"Toplantı çok **sıcak** geçti." cümlesinde "sıcak" sözcüğü hangi anlamda kullanılmıştır?$$,
  jsonb_build_object('A', $$gerçek anlam$$, 'B', $$mecaz anlam$$, 'C', $$terim anlam$$, 'D', $$eş anlam$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Toplantı sıcaklık ölçülebilir mi? Burada "tartışmalı, hararetli" anlamındadır.$$,
    $$Adım 1: Gerçek anlamda "sıcak" ölçülebilir bir sıcaklıktır.$$,
    $$Adım 2: Burada toplantının hararetli, tartışmalı geçtiği anlatılır.$$,
    $$Adım 3: Bu mecaz anlamdır. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 7, $$Türkçe$$, $$Noktalama$$, $$Noktalı virgül$$, 3,
  $$Noktalı virgül (;) genellikle hangi amaçla kullanılır?$$,
  jsonb_build_object('A', $$Cümleyi bitirmek için$$, 'B', $$Anlamca birbirine bağlı ama virgülle ayrılamayacak cümleleri ayırmak için$$, 'C', $$Soru sormak için$$, 'D', $$Alıntı yapmak için$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Noktalı virgül, virgülden daha güçlü ama noktadan daha zayıf bir ayrım yapar.$$,
    $$Adım 1: Noktalı virgül, cümle içinde grupları ayırır.$$,
    $$Adım 2: Anlamca bağlı cümleleri ayırmak için kullanılır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$Kader ve Kaza$$, $$Kader$$, 3,
  $$İnsanın özgür iradesiyle yaptığı seçimlere ne denir?$$,
  jsonb_build_object('A', $$cüz'i irade$$, 'B', $$kader$$, 'C', $$kaza$$, 'D', $$ecel$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: İnsana tanınan sınırlı seçme özgürlüğüdür.$$,
    $$Adım 1: İnsan, yaptığı seçimlerden sorumludur.$$,
    $$Adım 2: Bu sınırlı seçme özgürlüğüne cüz'i irade denir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$İbadet$$, $$Zekât$$, 3,
  $$Zekât kimlere verilir?$$,
  jsonb_build_object('A', $$İhtiyaç sahibi olanlara$$, 'B', $$Zengin olanlara$$, 'C', $$Sadece akrabalara$$, 'D', $$Yalnızca komşulara$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Zekât, malın belli bir kısmının ihtiyaç sahiplerine verilmesidir.$$,
    $$Adım 1: Zekât, belirli şartları taşıyan kişilerin malından vermesidir.$$,
    $$Adım 2: Bu yardım ihtiyaç sahiplerine verilir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$Değerler$$, $$Sadaka$$, 2,
  $$Karşılık beklemeden yapılan her türlü iyiliğe ne denir?$$,
  jsonb_build_object('A', $$sadaka$$, 'B', $$faiz$$, 'C', $$israf$$, 'D', $$kibir$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Zekâtın dışında, gönüllü yapılan iyiliklerdir.$$,
    $$Adım 1: Karşılık beklenmeden yapılan yardım ve iyiliklere sadaka denir.$$,
    $$Adım 2: Sadaka, maddi ya da manevi olabilir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$Ahlak$$, $$Doğruluk$$, 2,
  $$Peygamberimizin "el-Emin" lakabı hangi özelliğinden dolayı verilmiştir?$$,
  jsonb_build_object('A', $$Güvenilir ve dürüst olması$$, 'B', $$Çok konuşması$$, 'C', $$Uzun boylu olması$$, 'D', $$Hızlı yürümesi$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "Emin" sözcüğü güvenilir anlamına gelir.$$,
    $$Adım 1: "el-Emin" güvenilir kişi demektir.$$,
    $$Adım 2: Peygamberimiz dürüst ve güvenilir olduğu için bu lakabı almıştır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$Din ve Hayat$$, $$Çalışma ve emek$$, 3,
  $$İslam'a göre çalışıp emek harcayarak kazanmak nasıl değerlendirilir?$$,
  jsonb_build_object('A', $$Teşvik edilir$$, 'B', $$Yasaklanır$$, 'C', $$Gereksiz görülür$$, 'D', $$Değersiz sayılır$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Alın teriyle kazanç sağlamak hangi değerle ilgilidir?$$,
    $$Adım 1: İslam, çalışıp helal yolla kazanmayı teşvik eder.$$,
    $$Adım 2: Emek ve alın teri değerlidir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$Ahlak$$, $$Adalet$$, 3,
  $$Adaletli davranmak hangi sonucu doğurur?$$,
  jsonb_build_object('A', $$Toplumsal huzur ve güven$$, 'B', $$Kavga ve güvensizlik$$, 'C', $$Kargaşa$$, 'D', $$Yalnızlık$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Herkesin hakkını aldığı toplumda nasıl bir ortam oluşur?$$,
    $$Adım 1: Adalet, herkese hakkının verilmesidir.$$,
    $$Adım 2: Bu, toplumda huzur ve güven oluşturur.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$Değerler$$, $$İsraf$$, 2,
  $$İsraf etmek neden doğru değildir?$$,
  jsonb_build_object('A', $$Kaynakları boşa harcadığı için$$, 'B', $$Çok kazanç sağladığı için$$, 'C', $$Zaman kazandırdığı için$$, 'D', $$Yardım ettiği için$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: İsraf, kaynakları gereksiz yere tüketmektir.$$,
    $$Adım 1: İsraf, kaynakların gereksiz kullanılmasıdır.$$,
    $$Adım 2: Bu, hem kişiye hem topluma zarar verir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$Ahlak$$, $$Hoşgörü ve barış$$, 2,
  $$Farklı inanç ve görüşteki insanlara nasıl davranmalıyız?$$,
  jsonb_build_object('A', $$Saygı ve hoşgörüyle$$, 'B', $$Baskıyla$$, 'C', $$Alayla$$, 'D', $$Dışlayarak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Her insanın inancına ve görüşüne saygı duymak gerekir.$$,
    $$Adım 1: İnsanlar farklı inanç ve görüşlere sahip olabilir.$$,
    $$Adım 2: Bu farklılıklara saygı ve hoşgörü gösterilmelidir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$Kader ve Kaza$$, $$Sorumluluk$$, 3,
  $$İnsanın yaptığı iyi ya da kötü işlerden sorumlu olması hangi kavramla ilgilidir?$$,
  jsonb_build_object('A', $$irade ve sorumluluk$$, 'B', $$kader$$, 'C', $$kaza$$, 'D', $$ecel$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Özgür iradeyle seçim yapan kişi, sonucundan da sorumludur.$$,
    $$Adım 1: İnsan, iradesiyle seçim yapar.$$,
    $$Adım 2: Yaptığı seçimlerden sorumludur.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Din Kültürü$$, $$Ahlak$$, $$Yardımlaşma ve dayanışma$$, 2,
  $$Toplumda dayanışmayı artıran davranış hangisidir?$$,
  jsonb_build_object('A', $$İhtiyaç sahiplerine yardım etmek$$, 'B', $$Sadece kendi çıkarını düşünmek$$, 'C', $$Başkalarını görmezden gelmek$$, 'D', $$Yardımı engellemek$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Dayanışma, insanların birbirine destek olmasıdır.$$,
    $$Adım 1: Dayanışma, toplumun birlikte hareket etmesidir.$$,
    $$Adım 2: İhtiyaç sahiplerine yardım etmek dayanışmayı artırır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$Mevsimler ve İklim$$, $$Mevsimlerin oluşumu$$, 3,
  $$Mevsimlerin oluşmasının temel nedeni nedir?$$,
  jsonb_build_object('A', $$Dünya'nın kendi ekseni etrafında dönmesi$$, 'B', $$Dünya'nın eksen eğikliği ile Güneş çevresinde dolanması$$, 'C', $$Ay'ın Dünya çevresinde dönmesi$$, 'D', $$Güneş'in kendi ekseninde dönmesi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Dünya'nın ekseni eğiktir ve Güneş çevresinde döner; bu, ışınların açısını değiştirir.$$,
    $$Adım 1: Mevsimler, Güneş ışınlarının bir yere geliş açısına bağlıdır.$$,
    $$Adım 2: Eksen eğikliği ve Güneş çevresindeki hareket bu açıyı değiştirir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$DNA ve Kalıtım$$, $$Kalıtım$$, 3,
  $$Kalıtsal özellikleri taşıyan ve nesilden nesile aktaran yapı hangisidir?$$,
  jsonb_build_object('A', $$DNA$$, 'B', $$protein$$, 'C', $$yağ$$, 'D', $$su$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Hücre çekirdeğinde bulunan, kalıtım bilgisini taşıyan moleküldür.$$,
    $$Adım 1: Kalıtsal bilgiler hücre çekirdeğinde saklanır.$$,
    $$Adım 2: Bu bilgiyi DNA taşır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$Basınç$$, $$Katı basıncı$$, 3,
  $$Bir cismin yere uyguladığı basıncı artırmak için ne yapılabilir?$$,
  jsonb_build_object('A', $$Yüzey alanını artırmak$$, 'B', $$Yüzey alanını azaltmak$$, 'C', $$Ağırlığı azaltmak$$, 'D', $$Cismi kaldırmak$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Basınç = Kuvvet ÷ Yüzey alanı. Alan azalırsa basınç ne olur?$$,
    $$Adım 1: Basınç, kuvvetin yüzey alanına bölünmesiyle bulunur.$$,
    $$Adım 2: Aynı kuvvetle alan azalırsa basınç artar.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$Madde ve Endüstri$$, $$Kimyasal tepkime$$, 3,
  $$Kimyasal bir tepkimede aşağıdakilerden hangisi korunur?$$,
  jsonb_build_object('A', $$Atom sayısı$$, 'B', $$Maddenin rengi$$, 'C', $$Sıcaklık$$, 'D', $$Hacim$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Tepkimede atomlar yok olmaz, yalnızca yer değiştirir.$$,
    $$Adım 1: Kimyasal tepkimede atomlar yok olmaz ve yeniden oluşmaz.$$,
    $$Adım 2: Bu yüzden tepkime öncesi ve sonrası atom sayısı eşittir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$Basit Makineler$$, $$Kaldıraç$$, 3,
  $$Bir kaldıraçta destek noktasına yakın kuvvet uygulandığında ne olur?$$,
  jsonb_build_object('A', $$Kuvvetten kazanç artar$$, 'B', $$Kuvvetten kazanç azalır$$, 'C', $$Hiçbir değişiklik olmaz$$, 'D', $$Yük kaybolur$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Kuvvet kolu uzadıkça daha az kuvvetle iş yapılır.$$,
    $$Adım 1: Kaldıraçta kuvvet kolu uzadıkça kuvvetten kazanç artar.$$,
    $$Adım 2: Destek noktasına yakın kuvvet uygulamak kuvvet kolunu uzatır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$Enerji Dönüşümleri$$, $$Sürtünme$$, 3,
  $$Sürtünen yüzeylerde mekanik enerjinin bir kısmı hangi enerjiye dönüşür?$$,
  jsonb_build_object('A', $$Isı enerjisi$$, 'B', $$Işık enerjisi$$, 'C', $$Kimyasal enerji$$, 'D', $$Ses enerjisi$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Ellerini birbirine sürttüğünde ne hissedersin?$$,
    $$Adım 1: Sürtünme, hareketi zorlaştırır ve enerjinin bir kısmını harcar.$$,
    $$Adım 2: Bu enerji ısıya dönüşür.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$Elektrik$$, $$Elektriklenme$$, 3,
  $$Bir cismin sürtünme sonucu elektrik yükü kazanmasına ne denir?$$,
  jsonb_build_object('A', $$Elektriklenme$$, 'B', $$Isınma$$, 'C', $$Erime$$, 'D', $$Donma$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Saçını tarakla tarayınca tarağın kâğıt parçalarını çekmesinin nedeni budur.$$,
    $$Adım 1: Sürtünen cisimler yük kazanabilir.$$,
    $$Adım 2: Bu olaya elektriklenme denir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$Madde ve Endüstri$$, $$Asit-baz$$, 3,
  $$Turnusol kâğıdını kırmızıya çeviren madde hangisidir?$$,
  jsonb_build_object('A', $$asit$$, 'B', $$baz$$, 'C', $$tuz$$, 'D', $$saf su$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Limon suyu gibi maddeler turnusolü kırmızıya çevirir.$$,
    $$Adım 1: Asitler turnusol kâğıdını kırmızıya çevirir.$$,
    $$Adım 2: Bazlar ise maviye çevirir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$Mevsimler ve İklim$$, $$İklim ve hava olayları$$, 2,
  $$Hava olaylarını inceleyen bilim dalı hangisidir?$$,
  jsonb_build_object('A', $$meteoroloji$$, 'B', $$jeoloji$$, 'C', $$biyoloji$$, 'D', $$astronomi$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Günlük hava durumu tahminlerini yapan bilim dalıdır.$$,
    $$Adım 1: Hava olayları kısa süreli atmosfer durumlarıdır.$$,
    $$Adım 2: Bunları inceleyen bilim dalı meteorolojidir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Fen Bilimleri$$, $$Basit Makineler$$, $$Makara$$, 3,
  $$Sabit bir makara kullanmanın sağladığı kolaylık nedir?$$,
  jsonb_build_object('A', $$Kuvvetten kazanç sağlar$$, 'B', $$Kuvvetin yönünü değiştirir$$, 'C', $$Yükü hafifletir$$, 'D', $$İşi tamamen ortadan kaldırır$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Sabit makara kuvvetten kazanç sağlamaz ama uygulama yönünü değiştirir.$$,
    $$Adım 1: Sabit makara kuvvetin büyüklüğünü değiştirmez.$$,
    $$Adım 2: Ancak kuvvetin uygulanma yönünü değiştirir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$Friendship$$, $$Arkadaşlık$$, 2,
  $$"My best friend always helps me." cümlesinde kişi arkadaşı hakkında ne söylüyor?$$,
  jsonb_build_object('A', $$Ona her zaman yardım ettiğini$$, 'B', $$Onu görmediğini$$, 'C', $$Ona kızdığını$$, 'D', $$Onunla oynamadığını$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "always helps me" ifadesi ne anlama gelir?$$,
    $$Adım 1: "always" her zaman, "helps" yardım eder demektir.$$,
    $$Adım 2: Cümle, arkadaşının ona her zaman yardım ettiğini söyler.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$Teen Life$$, $$Hobiler ve tercihler$$, 3,
  $$"I am interested in playing the guitar." cümlesine göre kişi neye ilgi duyar?$$,
  jsonb_build_object('A', $$Gitar çalmaya$$, 'B', $$Kitap okumaya$$, 'C', $$Yüzmeye$$, 'D', $$Resim yapmaya$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "playing the guitar" ifadesi ne anlama gelir?$$,
    $$Adım 1: "playing the guitar" gitar çalmak demektir.$$,
    $$Adım 2: "interested in" bir şeye ilgi duymak anlamına gelir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$In the Kitchen$$, $$Mutfak$$, 3,
  $$"Could you please pass me the salt?" cümlesi ne rica eder?$$,
  jsonb_build_object('A', $$Tuzu uzatmasını$$, 'B', $$Suyu içmesini$$, 'C', $$Yemek yapmasını$$, 'D', $$Masayı temizlemesini$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "pass me the salt" ifadesi ne anlama gelir?$$,
    $$Adım 1: "pass" uzatmak, "salt" tuz demektir.$$,
    $$Adım 2: Cümle, tuzu uzatmasını rica etmektedir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$On the Phone$$, $$Telefonda konuşma$$, 3,
  $$"Hold on a minute, please." cümlesi ne anlama gelir?$$,
  jsonb_build_object('A', $$Bir dakika bekleyin, lütfen$$, 'B', $$Hemen geliyorum$$, 'C', $$Telefonu kapatın$$, 'D', $$Numarayı yanlış çevirdiniz$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "hold on" beklemek anlamına gelir.$$,
    $$Adım 1: "hold on" beklemek demektir.$$,
    $$Adım 2: "a minute" bir dakika anlamına gelir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$Internet$$, $$İnternet kullanımı$$, 3,
  $$"I usually search for information on the internet." cümlesine göre kişi ne yapar?$$,
  jsonb_build_object('A', $$İnternette bilgi arar$$, 'B', $$Oyun oynar$$, 'C', $$Film izler$$, 'D', $$Mesaj yazar$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "search for information" ifadesi ne anlama gelir?$$,
    $$Adım 1: "search for information" bilgi aramak demektir.$$,
    $$Adım 2: "on the internet" internette anlamına gelir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$Adventures$$, $$Macera$$, 3,
  $$"We went rafting last summer." cümlesine göre kişiler ne yapmıştır?$$,
  jsonb_build_object('A', $$Nehirde rafting yapmışlar$$, 'B', $$Dağa tırmanmışlar$$, 'C', $$Yüzmüşler$$, 'D', $$Bisiklete binmişler$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "rafting" nehirde yapılan bir su sporudur.$$,
    $$Adım 1: "rafting" bir su sporudur.$$,
    $$Adım 2: "last summer" geçen yaz anlamına gelir.$$,
    $$Adım 3: Cümle geçen yaz rafting yaptıklarını söyler. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$Tourism$$, $$Turizm$$, 3,
  $$"Turkey is famous for its historical places." cümlesine göre Türkiye neyle ünlüdür?$$,
  jsonb_build_object('A', $$Tarihî yerleriyle$$, 'B', $$Yemekleriyle$$, 'C', $$Futboluyla$$, 'D', $$Müziğiyle$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "historical places" ifadesi ne anlama gelir?$$,
    $$Adım 1: "historical" tarihî, "places" yerler demektir.$$,
    $$Adım 2: Cümle Türkiye'nin tarihî yerleriyle ünlü olduğunu söyler.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$Friendship$$, $$Kişilik özellikleri$$, 2,
  $$"generous" sözcüğünün Türkçe karşılığı hangisidir?$$,
  jsonb_build_object('A', $$cimri$$, 'B', $$cömert$$, 'C', $$kıskanç$$, 'D', $$tembel$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Elindekini paylaşan kişiyi tanımlayan sözcüktür.$$,
    $$Adım 1: "generous" paylaşmayı seven, cömert kişiyi tanımlar.$$,
    $$Adım 2: Cimri "stingy", kıskanç "jealous", tembel "lazy"dir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$In the Kitchen$$, $$Yemek yapma$$, 3,
  $$"First, chop the onions." cümlesinde ne yapılması isteniyor?$$,
  jsonb_build_object('A', $$Soğanları doğramak$$, 'B', $$Soğanları yıkamak$$, 'C', $$Soğanları pişirmek$$, 'D', $$Soğanları atmak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "chop" doğramak anlamına gelir.$$,
    $$Adım 1: "chop" doğramak, "onions" soğanlar demektir.$$,
    $$Adım 2: Cümle, önce soğanların doğranmasını söyler.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$İngilizce$$, $$Teen Life$$, $$Öneri$$, 3,
  $$"You should do your homework regularly." cümlesi ne önerir?$$,
  jsonb_build_object('A', $$Ödevini düzenli yapmasını$$, 'B', $$Erken yatmasını$$, 'C', $$Spor yapmasını$$, 'D', $$Kitap okumasını$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "do your homework" ödevini yapmak demektir.$$,
    $$Adım 1: "should" tavsiye bildirir.$$,
    $$Adım 2: "do your homework regularly" ödevini düzenli yapmak demektir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Çarpanlar ve Katlar$$, $$Asal çarpanlar$$, 3,
  $$60 sayısının asal çarpanlarına ayrılmış hâli hangisidir?$$,
  jsonb_build_object('A', $$2² × 3 × 5$$, 'B', $$2 × 3 × 5$$, 'C', $$2² × 3²$$, 'D', $$2 × 5²$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: 60 = 2 × 2 × 3 × 5 şeklinde ayır.$$,
    $$Adım 1: 60'ı asal çarpanlarına ayırırız: 60 = 2 × 30 = 2 × 2 × 15 = 2 × 2 × 3 × 5.$$,
    $$Adım 2: 2² × 3 × 5 = 4 × 3 × 5 = 60.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Üslü İfadeler$$, $$Üslü işlemler$$, 3,
  $$2³ × 2⁴ işleminin sonucu kaçtır?$$,
  jsonb_build_object('A', $$2⁷$$, 'B', $$2¹²$$, 'C', $$4⁷$$, 'D', $$2¹$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Aynı tabanlı üsler çarpılırken üsler toplanır.$$,
    $$Adım 1: Tabanlar aynı (2) olduğu için üsler toplanır.$$,
    $$Adım 2: 3 + 4 = 7.$$,
    $$Adım 3: Sonuç 2⁷'dir. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Kareköklü İfadeler$$, $$Karekök$$, 3,
  $$√144 kaçtır?$$,
  jsonb_build_object('A', $$11$$, 'B', $$12$$, 'C', $$13$$, 'D', $$14$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Hangi sayının karesi 144'tür?$$,
    $$Adım 1: Karekök, karesi verilen sayıyı bulmaktır.$$,
    $$Adım 2: 12 × 12 = 144.$$,
    $$Adım 3: √144 = 12. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Cebir$$, $$Özdeşlik$$, 3,
  $$(x + 3)² ifadesinin açılımı hangisidir?$$,
  jsonb_build_object('A', $$x² + 9$$, 'B', $$x² + 6x + 9$$, 'C', $$x² + 3x + 9$$, 'D', $$x² + 6x + 3$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: (a + b)² = a² + 2ab + b² özdeşliğini uygula.$$,
    $$Adım 1: (x + 3)² = x² + 2 × x × 3 + 3².$$,
    $$Adım 2: = x² + 6x + 9.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Doğrusal Denklemler$$, $$Denklem çözme$$, 3,
  $$3x + 4 = 19 ise x kaçtır?$$,
  jsonb_build_object('A', $$5$$, 'B', $$6$$, 'C', $$7$$, 'D', $$15$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Önce her iki taraftan 4 çıkar: 3x = 15. Sonra 3'e böl.$$,
    $$Adım 1: 3x + 4 = 19 → 3x = 19 - 4 = 15.$$,
    $$Adım 2: Her iki tarafı 3'e böleriz: x = 5.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Geometri$$, $$Üçgende açı$$, 3,
  $$Bir üçgenin iki iç açısı 50° ve 60° ise üçüncü açısı kaç derecedir?$$,
  jsonb_build_object('A', $$60$$, 'B', $$70$$, 'C', $$80$$, 'D', $$110$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Üçgenin iç açıları toplamı 180°dir. 180 - (50 + 60) işlemini yap.$$,
    $$Adım 1: İki açının toplamı: 50 + 60 = 110.$$,
    $$Adım 2: Üçüncü açı = 180 - 110.$$,
    $$Adım 3: = 70°. Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Geometri$$, $$Pisagor$$, 3,
  $$Dik kenarları 3 cm ve 4 cm olan dik üçgenin hipotenüsü kaç cm'dir?$$,
  jsonb_build_object('A', $$5$$, 'B', $$6$$, 'C', $$7$$, 'D', $$12$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Pisagor: hipotenüs² = 3² + 4².$$,
    $$Adım 1: 3² + 4² = 9 + 16 = 25.$$,
    $$Adım 2: Hipotenüs = √25.$$,
    $$Adım 3: √25 = 5 cm. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Veri ve Olasılık$$, $$Olasılık$$, 3,
  $$Bir zar atıldığında çift sayı gelme olasılığı kaçtır?$$,
  jsonb_build_object('A', $$1/6$$, 'B', $$1/3$$, 'C', $$1/2$$, 'D', $$2/3$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Zarın yüzleri 1-6'dır. Çift sayılar: 2, 4, 6 (3 tanedir).$$,
    $$Adım 1: Toplam durum sayısı 6'dır.$$,
    $$Adım 2: Çift sayılar 2, 4, 6 olmak üzere 3 tanedir.$$,
    $$Adım 3: Olasılık = 3/6 = 1/2. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Cebir$$, $$Çarpanlara ayırma$$, 3,
  $$x² - 9 ifadesinin çarpanlara ayrılmış hâli hangisidir?$$,
  jsonb_build_object('A', $$(x - 3)(x + 3)$$, 'B', $$(x - 9)(x + 1)$$, 'C', $$(x - 3)²$$, 'D', $$(x + 9)(x - 1)$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: İki kare farkı: a² - b² = (a - b)(a + b). Burada b = 3.$$,
    $$Adım 1: x² - 9 = x² - 3² şeklinde yazılır.$$,
    $$Adım 2: İki kare farkı özdeşliği: a² - b² = (a - b)(a + b).$$,
    $$Adım 3: (x - 3)(x + 3). Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Matematik$$, $$Eşitsizlik$$, $$Basit eşitsizlik$$, 3,
  $$x + 5 > 12 eşitsizliğini sağlayan en küçük tam sayı kaçtır?$$,
  jsonb_build_object('A', $$6$$, 'B', $$7$$, 'C', $$8$$, 'D', $$12$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: x > 12 - 5 = 7. 7'den büyük en küçük tam sayı hangisidir?$$,
    $$Adım 1: x + 5 > 12 → x > 7.$$,
    $$Adım 2: 7'den büyük tam sayılar 8, 9, 10...'dur.$$,
    $$Adım 3: En küçüğü 8'dir. Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$Kurtuluş Savaşı$$, $$Kongreler$$, 3,
  $$"Manda ve himaye kabul edilemez." kararı ilk kez hangi kongrede alınmıştır?$$,
  jsonb_build_object('A', $$Sivas Kongresi$$, 'B', $$Erzurum Kongresi$$, 'C', $$Balıkesir Kongresi$$, 'D', $$Alaşehir Kongresi$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Bu karar, ulusal bağımsızlık vurgusuyla ilk kez toplanan doğu illeri kongresinde alınmıştır.$$,
    $$Adım 1: Erzurum Kongresi'nde ulusal sınırlar ve bağımsızlık vurgulanmıştır.$$,
    $$Adım 2: "Manda ve himaye kabul edilemez" kararı burada alınmıştır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$Kurtuluş Savaşı$$, $$Cepheler$$, 3,
  $$Kurtuluş Savaşı'nda Batı Cephesi'nde kazanılan, "Türk milletinin makûs talihini yendiği" savaş hangisidir?$$,
  jsonb_build_object('A', $$I. İnönü$$, 'B', $$II. İnönü$$, 'C', $$Sakarya Savaşı$$, 'D', $$Büyük Taarruz$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "Makûs talih" sözü bu zaferle ilişkilendirilir; son savunma savaşıdır.$$,
    $$Adım 1: Sakarya Savaşı, Türk ordusunun son savunma savaşıdır.$$,
    $$Adım 2: Bu zaferle Türk milletinin "makûs talihi yenilmiştir".$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$İnkılaplar$$, $$Siyasi inkılaplar$$, 2,
  $$Saltanat hangi yıl kaldırılmıştır?$$,
  jsonb_build_object('A', $$1920$$, 'B', $$1922$$, 'C', $$1923$$, 'D', $$1924$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Cumhuriyet'in ilanından bir yıl önce kaldırılmıştır.$$,
    $$Adım 1: Saltanat 1 Kasım 1922'de kaldırılmıştır.$$,
    $$Adım 2: Cumhuriyet ise 1923'te ilan edilmiştir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$İnkılaplar$$, $$Cumhuriyet'in ilanı$$, 2,
  $$Cumhuriyet hangi tarihte ilan edilmiştir?$$,
  jsonb_build_object('A', $$29 Ekim 1923$$, 'B', $$23 Nisan 1920$$, 'C', $$19 Mayıs 1919$$, 'D', $$30 Ağustos 1922$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Bu tarih, Cumhuriyet Bayramı olarak kutlanır.$$,
    $$Adım 1: Cumhuriyet 29 Ekim 1923'te ilan edilmiştir.$$,
    $$Adım 2: Bu tarih her yıl Cumhuriyet Bayramı olarak kutlanır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$Atatürkçülük$$, $$İlkeler$$, 3,
  $$"Egemenlik kayıtsız şartsız milletindir." sözü hangi ilkeyle doğrudan ilgilidir?$$,
  jsonb_build_object('A', $$cumhuriyetçilik$$, 'B', $$laiklik$$, 'C', $$devletçilik$$, 'D', $$inkılapçılık$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Egemenliğin millete ait olması hangi yönetim anlayışıdır?$$,
    $$Adım 1: "Egemenlik milletindir" ifadesi halkın yönetimde söz sahibi olmasıdır.$$,
    $$Adım 2: Bu, cumhuriyetçilik ilkesiyle ilgilidir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$Atatürkçülük$$, $$İlkeler$$, 3,
  $$Din ve devlet işlerinin ayrılması hangi ilkeyle ilgilidir?$$,
  jsonb_build_object('A', $$laiklik$$, 'B', $$milliyetçilik$$, 'C', $$halkçılık$$, 'D', $$cumhuriyetçilik$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Devletin din işlerine karışmaması, her inanca eşit mesafede olması hangi ilkedir?$$,
    $$Adım 1: Laiklik, din ve devlet işlerinin ayrılmasıdır.$$,
    $$Adım 2: Devlet, tüm inançlara eşit mesafede durur.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$İnkılaplar$$, $$Harf inkılabı$$, 2,
  $$Yeni Türk harfleri hangi yıl kabul edilmiştir?$$,
  jsonb_build_object('A', $$1923$$, 'B', $$1926$$, 'C', $$1928$$, 'D', $$1934$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: Latin alfabesine geçiş bu yıl gerçekleşmiştir.$$,
    $$Adım 1: Harf inkılabı 1928 yılında yapılmıştır.$$,
    $$Adım 2: Latin harflerine dayalı yeni alfabe kabul edilmiştir.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$Demokrasi$$, $$Kadın hakları$$, 3,
  $$Türk kadınına milletvekili seçme ve seçilme hakkı hangi yıl verilmiştir?$$,
  jsonb_build_object('A', $$1926$$, 'B', $$1930$$, 'C', $$1933$$, 'D', $$1934$$),
  'D',
  to_jsonb(ARRAY[
    $$İpucu: Bu hak, dünyadaki pek çok ülkeden önce verilmiştir.$$,
    $$Adım 1: Türk kadını 1930'da yerel, 1933'te muhtarlık seçimlerinde oy kullanma hakkı elde etti.$$,
    $$Adım 2: Milletvekili seçme ve seçilme hakkı 1934'te verilmiştir.$$,
    $$Adım 3: Doğru cevap D seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$Ekonomi$$, $$Ekonomik kalkınma$$, 3,
  $$Cumhuriyet'in ilk yıllarında ekonomik kalkınma için hangi uygulamaya ağırlık verilmiştir?$$,
  jsonb_build_object('A', $$Tarım ve sanayinin desteklenmesi$$, 'B', $$Ticaretin durdurulması$$, 'C', $$Vergilerin kaldırılması$$, 'D', $$Üretimin yasaklanması$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Genç Cumhuriyet, kalkınmak için üretimi artırmayı hedeflemiştir.$$,
    $$Adım 1: Kalkınma için üretimin artırılması gerekiyordu.$$,
    $$Adım 2: Tarım ve sanayi desteklenerek ekonomik gelişme sağlandı.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Sosyal Bilgiler$$, $$Kurtuluş Savaşı$$, $$Amasya Genelgesi$$, 3,
  $$"Milletin bağımsızlığını yine milletin azim ve kararı kurtaracaktır." ifadesi hangi belgede yer alır?$$,
  jsonb_build_object('A', $$Amasya Genelgesi$$, 'B', $$Sivas Kongresi kararları$$, 'C', $$Misak-ı Millî$$, 'D', $$Lozan Antlaşması$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Kurtuluş Savaşı'nın gerekçesini ve yöntemini ilk kez açıklayan belgedir.$$,
    $$Adım 1: Amasya Genelgesi, Kurtuluş Savaşı'nın gerekçe ve yöntemini açıklar.$$,
    $$Adım 2: "Milletin bağımsızlığını milletin azmi kurtaracaktır" ifadesi burada yer alır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Fiilimsiler$$, $$Sıfat-fiil$$, 3,
  $$"Koşan çocuk düştü." cümlesinde "koşan" sözcüğü hangi fiilimsidir?$$,
  jsonb_build_object('A', $$isim-fiil$$, 'B', $$sıfat-fiil$$, 'C', $$zarf-fiil$$, 'D', $$fiil$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "-an/-en" ekini alıp ismi niteleyen fiilimsidir.$$,
    $$Adım 1: "Koşan" sözcüğü "-an" ekini almıştır ve "çocuk" ismini nitelemektedir.$$,
    $$Adım 2: İsmi niteleyen fiilimsiler sıfat-fiildir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Paragrafta Anlam$$, $$Ana düşünce$$, 3,
  $$"Okumak, insanı başka dünyalara götüren bir yolculuktur. Kitaplar sayesinde farklı hayatları tanır, yeni bilgiler ediniriz." paragrafının ana düşüncesi nedir?$$,
  jsonb_build_object('A', $$Kitaplar pahalıdır$$, 'B', $$Okumak insanı geliştirir$$, 'C', $$Yolculuk yorucudur$$, 'D', $$Bilgi gereksizdir$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Paragraf okumanın yararlarını anlatıyor.$$,
    $$Adım 1: Paragraf okumayı bir yolculuğa benzetip yararlarını sıralıyor.$$,
    $$Adım 2: Bu, okumanın insanı geliştirdiğini gösterir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Cümlenin Ögeleri$$, $$Yer tamlayıcısı$$, 3,
  $$"Kitabı arkadaşıma verdim." cümlesinde yer tamlayıcısı (dolaylı tümleç) hangisidir?$$,
  jsonb_build_object('A', $$kitabı$$, 'B', $$arkadaşıma$$, 'C', $$verdim$$, 'D', $$yok$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: "-e, -de, -den" ekini alan ve yön/yer bildiren öge hangisidir?$$,
    $$Adım 1: "arkadaşıma" sözcüğü "-e" ekini almıştır.$$,
    $$Adım 2: Yönelme bildiren bu öge yer tamlayıcısıdır.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Cümle Türleri$$, $$Yapısına göre cümle$$, 3,
  $$"Hava güzel olduğu için pikniğe gittik." cümlesi yapısına göre hangi cümledir?$$,
  jsonb_build_object('A', $$basit cümle$$, 'B', $$birleşik cümle$$, 'C', $$sıralı cümle$$, 'D', $$bağlı cümle$$),
  'B',
  to_jsonb(ARRAY[
    $$İpucu: Cümlede birden fazla yargı var mı? "olduğu için" bir yan cümle kurmuş.$$,
    $$Adım 1: Cümlede "hava güzel olduğu için" bir yan cümle oluşturmuştur.$$,
    $$Adım 2: İçinde yan cümle bulunan cümleler birleşik cümledir.$$,
    $$Adım 3: Doğru cevap B seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Söz Sanatları$$, $$Abartma$$, 3,
  $$"Sana bin kere söyledim." cümlesinde hangi söz sanatı vardır?$$,
  jsonb_build_object('A', $$benzetme$$, 'B', $$kişileştirme$$, 'C', $$abartma$$, 'D', $$konuşturma$$),
  'C',
  to_jsonb(ARRAY[
    $$İpucu: "Bin kere" gerçekten bin kez mi söylenmiştir, yoksa çok söylendiği mi abartılıyor?$$,
    $$Adım 1: "Bin kere" ifadesi gerçek sayı değildir.$$,
    $$Adım 2: Bir şeyi olduğundan fazla göstermek abartmadır.$$,
    $$Adım 3: Doğru cevap C seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Yazım Kuralları$$, $$Birleşik sözcükler$$, 3,
  $$Aşağıdaki cümlelerden hangisinde yazım yanlışı yoktur?$$,
  jsonb_build_object('A', $$Bugün hava çok güzel.$$, 'B', $$Bugün hava çok güzelmi?$$, 'C', $$Bugün hava çokgüzel.$$, 'D', $$Bugün hava çokgüzelmi?$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "mi" ayrı, "çok güzel" ayrı yazılır.$$,
    $$Adım 1: "çok güzel" sözcükleri ayrı yazılır.$$,
    $$Adım 2: "mi" soru eki de her zaman ayrı yazılır.$$,
    $$Adım 3: Yalnızca A seçeneği doğrudur. Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Sözcükte Anlam$$, $$Deyim$$, 3,
  $$"Eli kulağında olmak" deyiminin anlamı nedir?$$,
  jsonb_build_object('A', $$Çok yakında olmak$$, 'B', $$Uzakta olmak$$, 'C', $$Sağır olmak$$, 'D', $$Yorgun olmak$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Bir olayın hemen gerçekleşeceğini anlatan deyimdir.$$,
    $$Adım 1: "Eli kulağında olmak", olması çok yakın olmak demektir.$$,
    $$Adım 2: Yakında gerçekleşecek bir durumu ifade eder.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Fiilimsiler$$, $$İsim-fiil$$, 3,
  $$"Yüzmeyi çok severim." cümlesinde "yüzmeyi" sözcüğü hangi fiilimsidir?$$,
  jsonb_build_object('A', $$isim-fiil$$, 'B', $$sıfat-fiil$$, 'C', $$zarf-fiil$$, 'D', $$çekimli fiil$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: "-me/-ma" ekini alıp isim görevinde kullanılan fiilimsidir.$$,
    $$Adım 1: "Yüzme" sözcüğü "-me" ekini almıştır ve cümlede nesne görevindedir.$$,
    $$Adım 2: "-me/-ma" ekini alan fiilimsiler isim-fiildir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Paragrafta Anlam$$, $$Konu$$, 3,
  $$"Arılar, çiçekten çiçeğe konarak bal yapar. Bu sırada bitkilerin çoğalmasına da yardımcı olurlar." paragrafının konusu nedir?$$,
  jsonb_build_object('A', $$Arıların faydaları$$, 'B', $$Balın tadı$$, 'C', $$Çiçeklerin rengi$$, 'D', $$Bahçe bakımı$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Paragraf kimden/neyden söz ediyor ve ne anlatıyor?$$,
    $$Adım 1: Paragraf arıların yaptıklarından söz eder.$$,
    $$Adım 2: Bal yapmaları ve bitkilere yardım etmeleri arıların faydasıdır.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
),
(
  'ortaokul', 8, $$Türkçe$$, $$Noktalama$$, $$Üç nokta$$, 3,
  $$Üç nokta (...) hangi durumda kullanılır?$$,
  jsonb_build_object('A', $$Tamamlanmamış cümlelerin sonunda$$, 'B', $$Soru cümlelerinin sonunda$$, 'C', $$Cümleyi güçlendirmek için$$, 'D', $$Sayıları ayırmak için$$),
  'A',
  to_jsonb(ARRAY[
    $$İpucu: Cümlenin bitmediğini, devamının olduğunu gösteren işarettir.$$,
    $$Adım 1: Üç nokta, cümlenin tamamlanmadığını gösterir.$$,
    $$Adım 2: Ayrıca sıralamaların devam ettiğini belirtir.$$,
    $$Adım 3: Doğru cevap A seçeneğidir.$$
  ]::text[])
)
;

insert into public.questions
  (okul, sinif, ders, konu, alt_konu, zorluk, soru_metni, siklar, dogru_sik, onay_durumu, cozum_adimlari)
select v.okul, v.sinif, v.ders, v.konu, v.alt_konu, v.zorluk, v.soru_metni, v.siklar, v.dogru_sik,
       'onaylandi', v.cozum_adimlari
  from _soru_bankasi_tum_siniflar v
 where not exists (
   select 1 from public.questions q
    where q.ders = v.ders and q.sinif = v.sinif and q.soru_metni = v.soru_metni
 );
