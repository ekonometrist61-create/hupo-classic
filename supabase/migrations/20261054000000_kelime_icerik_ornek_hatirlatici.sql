-- =====================================================================
-- KELİME EVRENİ — ilişkilere örnek cümle, hatırlatıcı ve hafıza tekniği
--
-- Kaynak: docs/kelime-evreni/veritabani/sinif-*.json (dogrula.mjs geçti).
-- Her alan ilişki bazındadır. Yalnızca eşleşen satırlar güncellenir; yeni satır eklenmez.
-- =====================================================================

set client_encoding = 'UTF8';

alter table public.kelime_iliskileri
  add column if not exists ornek text check (ornek is null or length(btrim(ornek)) between 5 and 300),
  add column if not exists hatirlatici text check (hatirlatici is null or length(btrim(hatirlatici)) between 5 and 300),
  add column if not exists teknik text check (teknik is null or length(btrim(teknik)) between 2 and 40);

comment on column public.kelime_iliskileri.ornek is 'İlişkiyi gösteren örnek cümle (öğrenciye gösterim).';
comment on column public.kelime_iliskileri.hatirlatici is 'Çocuk için hafıza ipucu.';
comment on column public.kelime_iliskileri.teknik is 'Kullanılan hafıza tekniği etiketi (çağrışım, hikâye, görsel, hareket, ses, eşleştirme, karşıtlık).';

create temp table kelime_icerik_girdi (
  ka text not null, kan text not null, ha text not null, han text not null, tur text not null,
  ornek text not null, hatirlatici text not null, teknik text not null
) on commit drop;

insert into kelime_icerik_girdi (ka, kan, ha, han, tur, ornek, hatirlatici, teknik) values
  ('büyük', 'Boyu ya da miktarı fazla olan', 'küçük', 'Boyu ya da miktarı az olan', 'zit_anlamli', 'Büyük topu, küçük topun yanına koyduk.', 'Büyük ağabey yaşça büyüktür, küçük kardeş yaşça küçüktür.', 'çağrışım'),
  ('sıcak', 'Isısı yüksek olan', 'soğuk', 'Isısı düşük olan', 'zit_anlamli', 'Çorba sıcak, limonata soğuktu.', 'Sıcak çayı üflersin, soğuk buzla üşürsün.', 'hareket'),
  ('uzun', 'Boyu ya da uzunluğu fazla olan', 'kısa', 'Boyu ya da uzunluğu az olan', 'zit_anlamli', 'Uzun ipi kestik, kısa ip kaldı.', 'Zürafanın boynu uzun, tavşanın kuyruğu kısadır.', 'görsel'),
  ('açık', 'Kapalı olmayan, önünde engel bulunmayan', 'kapalı', 'Açık olmayan, kapanmış olan', 'zit_anlamli', 'Kapı açık, pencere kapalıydı.', 'Açık kapıdan içeri girersin; kapalı kapıyı açmadan geçemezsin.', 'hareket'),
  ('dolu', 'İçi boş olmayan, doldurulmuş', 'boş', 'İçinde hiçbir şey bulunmayan', 'zit_anlamli', 'Sepet dolu, kutu boştu.', 'Dolu sepete elma koyarsın; boş sepet bomboş kalır.', 'görsel'),
  ('hızlı', 'Çabuk hareket eden', 'yavaş', 'Az hızla hareket eden', 'zit_anlamli', 'Tavşan hızlı koşar, kaplumbağa yavaş yürür.', 'Tavşan ile kaplumbağanın yarışı: hızlı tavşan, yavaş kaplumbağa.', 'hikâye'),
  ('yüksek', 'Yerden uzaklığı çok olan', 'alçak', 'Yerden uzaklığı az olan', 'zit_anlamli', 'Dağ yüksek, tepe alçaktır.', 'Merdivenin üst basamağı yüksek, alt basamağı alçaktır.', 'hareket'),
  ('ıslak', 'Su ya da başka bir sıvıyla bulaşmış, nemli', 'kuru', 'Su almamış, nemi olmayan', 'zit_anlamli', 'Islak elbiseyi astık; kuru elbiseyi giydik.', 'Yağmurda ıslanan elbise güneşte kurur.', 'hikâye'),
  ('temiz', 'Kirli olmayan, pak', 'kirli', 'Kir ya da leke taşıyan', 'zit_anlamli', 'Ellerimi yıkayınca temiz oldu; çamurla oynayınca kirli kaldı.', 'Sabun temizler, çamur kirletir.', 'hareket'),
  ('güzel', 'Görünüşü ya da sesi hoşa giden', 'çirkin', 'Güzel olmayan, hoş görünmeyen', 'zit_anlamli', 'Bahçedeki çiçekler güzel, çöp yığını çirkin görünüyordu.', 'Çiçek bahçesi göz alır; çöp yığını gözü rahatsız eder.', 'görsel'),
  ('kolay', 'Zahmeti az olan, zor olmayan', 'zor', 'Güçlük çıkaran, kolay olmayan', 'zit_anlamli', 'Toplama işlemi kolay, bölme işlemi bana zor geldi.', 'Yürümek kolay, dağa tırmanmak zordur.', 'çağrışım'),
  ('ucuz', 'Fiyatı düşük olan', 'pahalı', 'Fiyatı yüksek olan', 'zit_anlamli', 'Pazardan ucuz elma aldık, mağazadaki ayakkabı pahalıydı.', 'Pazarda ucuz, mağazada pahalı: alışveriş hikâyesi.', 'hikâye'),
  ('geniş', 'Alanı ya da içi ferah olan', 'dar', 'Alanı ya da içi az, sıkışık olan', 'zit_anlamli', 'Oyun alanımız geniş, koridor ise dardı.', 'Geniş bahçede rahatça koşarsın; dar koridorda sıkışırsın.', 'görsel'),
  ('ince', 'Kalınlığı az olan', 'kalın', 'Kalınlığı fazla olan', 'zit_anlamli', 'İnce kâğıdı defterime koydum, kalın sözlüğü rafa kaldırdım.', 'Kalem ince, sözlük kalındır.', 'görsel'),
  ('iyi', 'Kötü olmayan, olumlu', 'kötü', 'İyi olmayan, olumsuz', 'zit_anlamli', 'Yalan söylemek kötüdür, dürüst olmak iyidir.', 'İyi olan gülümsetir, kötü olan üzer.', 'çağrışım'),
  ('doğru', 'Gerçeğe uygun, yanlış olmayan', 'yanlış', 'Doğru olmayan, hatalı', 'zit_anlamli', 'Sorunun cevabını doğru bulunca sevindim; yanlış yapınca tekrar denedim.', 'Doğru cevaba tik, yanlış cevaba çarpı koyarsın.', 'eşleştirme'),
  ('gündüz', 'Güneş ışığının aydınlattığı zaman', 'gece', 'Güneşin battığı andan doğuşuna kadar süren karanlık zaman', 'zit_anlamli', 'Gündüz okula gidiyoruz, gece uyuyoruz.', 'Gündüz güneş parlar, gece ay ve yıldızlar görünür.', 'hikâye'),
  ('ön', 'Bir şeyin ilerideki, yüze bakan kısmı', 'arka', 'Bir şeyin geride kalan kısmı', 'zit_anlamli', 'Sınıfta ön sıraya oturdum, arkadaşım arka sırada oturuyordu.', 'Otobüsün önünde şoför, arkasında yolcular oturur.', 'görsel'),
  ('içeri', 'Bir yerin iç kısmına doğru', 'dışarı', 'Bir yerin dış kısmına doğru', 'zit_anlamli', 'Yağmur başlayınca içeri girdik, hava açılınca dışarı çıktık.', 'Kapıdan içeri girersin, kapıdan dışarı çıkarsın.', 'hareket'),
  ('yeni', 'Yakın zamanda yapılmış, eskimemiş olan', 'eski', 'Yıllar önce yapılmış, yıpranmış olan', 'zit_anlamli', 'Yeni ayakkabımı giydim, eskisini kutuya koydum.', 'Yeni bisiklet parlar, eski bisiklet paslanmıştır.', 'hikâye'),
  ('mutlu', 'Sevinç duyan, neşeli', 'sevinçli', 'Sevinç duyan, mutlu', 'es_anlamli', 'Bayram sabahı herkes mutlu ve sevinçli uyandı.', 'Mutlu olan gülümser, sevinçli olan da gülümser: aynı duygu.', 'çağrışım'),
  ('hızlı', 'Çabuk hareket eden, süratli', 'çabuk', 'Kısa sürede gerçekleşen, hızlı', 'es_anlamli', 'Hızlı koşan çocuk yarışı çabuk bitirdi.', 'Yarışta hızlı koşan çabuk varır.', 'hareket'),
  ('arkadaş', 'Birlikte vakit geçirilen, yakın olunan kişi', 'dost', 'Sevgi ve güvenle bağlı olunan yakın kişi', 'es_anlamli', 'Okuldaki arkadaşım aynı zamanda en iyi dostumdur.', 'Arkadaş oyunda, dost sıkıntıda yanındadır.', 'hikâye'),
  ('ev', 'İnsanların yaşadığı yer', 'konut', 'İnsanların oturduğu yapı, mesken', 'es_anlamli', 'Ailem yeni bir ev aldı; bu konut okula yakın.', 'Ev de konut da insanın oturduğu yerdir.', 'görsel'),
  ('yanıt', 'Bir soruya verilen karşılık', 'cevap', 'Bir soruya ya da söze karşılık olarak verilen yanıt', 'es_anlamli', 'Öğretmenin sorusuna doğru yanıt verdim, cevabım alkışlandı.', 'Soruya verilen karşılık hem yanıt hem cevaptır.', 'eşleştirme'),
  ('kent', 'Kalabalık, büyük yerleşim yeri', 'şehir', 'Kalabalık ve gelişmiş yerleşim birimi', 'es_anlamli', 'Bu kent, yani bu şehir, kalabalık bir yerleşim yeridir.', 'Kent ile şehir: ikisi de kalabalık yerleşim, bir harita üstünde büyük noktalar.', 'görsel'),
  ('küçük', 'Boyu ya da miktarı az olan', 'minik', 'Çok küçük, ufacık', 'es_anlamli', 'Minik kuş, küçük bir dalda ötüyordu.', 'Minik, küçüğün de küçüğü: ufacık bir şey.', 'görsel'),
  ('sevinç', 'Bir şeyden dolayı duyulan mutluluk', 'neşe', 'Canlı ve sevinçli olma hâli', 'es_anlamli', 'Doğum günümde sevinç ve neşe doluydum.', 'Sevinç içten gelir, neşe dışarıya taşar.', 'ses'),
  ('cesur', 'Korkmayan, yiğit', 'korkak', 'Kolay korkan, cesareti az olan', 'zit_anlamli', 'Cesur çocuk karanlık odaya girdi, korkak kardeşi kapıda kaldı.', 'Cesur kahraman ileri atılır; korkak olan geri kaçar.', 'karşıtlık'),
  ('zengin', 'Parası ve malı çok olan', 'fakir', 'Parası ve malı az olan, yoksul', 'zit_anlamli', 'Zengin tüccar, fakir çiftçiye yardım etti.', 'Zenginin cüzdanı dolu, fakirin cüzdanı boştur.', 'hikâye'),
  ('güçlü', 'Kuvvetli, dayanıklı', 'zayıf', 'Gücü az olan, kuvvetsiz', 'zit_anlamli', 'Güçlü pehlivan ağır çuvalı kaldırdı, zayıf çocuk zorlandı.', 'Güçlü kol ağırı taşır; zayıf kol hafifi zor taşır.', 'hareket'),
  ('ağır', 'Ağırlığı çok olan', 'hafif', 'Ağırlığı az olan', 'zit_anlamli', 'Taş ağırdı, tüy ise hafifti.', 'Taşı elinde tartınca ağır, tüyü tartınca hafif gelir.', 'görsel'),
  ('sert', 'Dokunulunca içine girilmeyen, katı', 'yumuşak', 'Dokunulunca kolayca basılan, sert olmayan', 'zit_anlamli', 'Taş sert, yastık yumuşaktır.', 'Taşa dokun, sert; yastığa dokun, yumuşak.', 'eşleştirme'),
  ('dağınık', 'Düzensiz, karışık', 'düzenli', 'Düzeni olan, yerli yerinde olan', 'zit_anlamli', 'Odam dağınıktı; temizledikten sonra düzenli oldu.', 'Dağınık odada her şey yerde, düzenli odada her şey yerindedir.', 'hikâye'),
  ('yüz', 'Başın ön tarafında, alın ile çene arasındaki bölüm, surat', 'yüz', 'Doksan dokuzdan sonra gelen sayının adı', 'es_sesli', 'Yüzünü yıkadım; sınıfta yüz öğrenci vardı.', 'Aynı yazılış, iki anlam: yüz surattır, yüz de sayıdır.', 'eşleştirme'),
  ('gül', 'Dikenli dalında kokulu çiçek açan bitki', 'gül', 'Sevinç ya da eğlenceyle yüzü açılıp ses çıkarmak (gülmek)', 'es_sesli', 'Bahçedeki gül güzel kokuyordu; şakaya herkes güldü.', 'Gül çiçeği koklanır; insan sevinçle gülerken sesini duyarsın.', 'hikâye'),
  ('yaz', 'Yılın en sıcak mevsimi', 'yaz', 'Kâğıt üzerine harf, kelime ya da rakam geçirmek', 'es_sesli', 'Yaz tatilinde defterime yeni kelimeleri yazdım.', 'Yazın güneş parlar; yazarken kalem kâğıtta kayar.', 'çağrışım'),
  ('çay', 'Yaprağı demlenerek içilen sıcak içecek', 'çay', 'Dereden büyük, ırmaktan küçük akarsu', 'es_sesli', 'Bardağımdaki çayı içtik, sonra çayın kenarında yürüdük.', 'Bardakta içtiğin çay; dereden akan çay.', 'görsel'),
  ('yaş', 'Doğuştan beri geçen ve yıl birimi ile ölçülen zaman', 'yaş', 'Nemli, ıslak', 'es_sesli', 'Büyükbabamın yaşı yetmiş; yaş odunu sobaya koymadık.', 'Yaş yıllardır, yaş da ıslaklıktır: aynı yazılış, iki ayrı anlam.', 'çağrışım'),
  ('bağ', 'Üzüm yetiştirilen bahçe', 'bağ', 'İki şeyi birbirine bağlayan ip ya da şerit', 'es_sesli', 'Bağdan üzüm topladık; ayakkabımın bağını bağladım.', 'Bağda üzümler asmalara bağlıdır; bağ, bağlayan iptir.', 'hikâye'),
  ('kuşku', 'Bir durum hakkında kesin karar verememe hâli', 'şüphe', 'Doğruluğundan emin olamama durumu', 'es_anlamli', 'Hikâyedeki bilgiye kuşkuyla yaklaştım, içimde şüphe kaldı.', 'Kuşkulanınca şüphe duyarsın: iki sözcük, tek duygu.', 'eşleştirme'),
  ('hatıra', 'Geçmişte yaşanan bir olayın akılda kalan izi', 'anı', 'Geçmişte yaşanmış olayların akılda kalan parçası', 'es_anlamli', 'Bu fotoğraf bana güzel bir hatıra bıraktı; eski anılarımızı konuştuk.', 'Fotoğraf da anı da geçmişi hatırlatır.', 'görsel'),
  ('yarışma', 'Birkaç kişinin üstünlük için karşılaşması', 'müsabaka', 'Spor ya da bilgi alanında yapılan karşılaşma, yarış', 'es_anlamli', 'Okulda bilgi yarışması vardı; müsabakada ilk üçe girdim.', 'İkisi de üstünlük için yapılan karşılaşmadır.', 'eşleştirme'),
  ('gayret', 'İstekle, emek vererek bir işe çalışma', 'çaba', 'Bir iş için gösterilen uğraş', 'es_anlamli', 'Sınava hazırlanırken gösterdiğim gayret ve çaba meyvesini verdi.', 'Gayret ve çaba aynı yolda birlikte yürür.', 'hareket'),
  ('sakin', 'Gürültüsüz, huzurlu, telaşsız', 'dingin', 'Sessiz, durgun, huzurlu', 'es_anlamli', 'Sakin bir göl ve dingin bir akşam vardı.', 'Sakin ve dingin: sesi kısık, dalgası durgun bir göl.', 'ses'),
  ('tembel', 'İş yapmaktan kaçınan, ağır işleyen', 'çalışkan', 'Çok çalışan, işini severek yapan', 'zit_anlamli', 'Tembel çocuk ödevini yapmadı; çalışkan kardeşi erkenden bitirdi.', 'Tembel uyur, çalışkan koşar.', 'karşıtlık'),
  ('geçmiş', 'Geride kalan, eski zaman', 'gelecek', 'Henüz gelmemiş olan zaman', 'zit_anlamli', 'Geçmişte yaşananları anlatırken geleceği de düşündük.', 'Geçmiş arkada kalır, gelecek önümüzde bekler.', 'hikâye'),
  ('az', 'Miktarı ya da sayısı küçük olan', 'çok', 'Miktarı ya da sayısı fazla olan', 'zit_anlamli', 'Az su içtim, kardeşim çok su içti.', 'Bir bardak su azdır, bir kova su çoktur.', 'görsel'),
  ('yakın', 'Uzaklığı az olan', 'uzak', 'Uzaklığı fazla olan', 'zit_anlamli', 'Evimiz okula yakın, hastane ise uzaktır.', 'Yakın olan elinin altında, uzak olan ufukta.', 'görsel'),
  ('kalabalık', 'İnsanların çok olduğu, dolu', 'tenha', 'İnsan bulunmayan, ıssız', 'zit_anlamli', 'Pazar yeri kalabalıktı; dağ yolu ise tenhaydı.', 'Meydan insanla dolu; tenha yolda kimse yoktur.', 'görsel'),
  ('dost', 'Sevgi ve güvenle bağlı olunan kişi', 'düşman', 'Bir kişiye karşı kötü duygu besleyen, zarar vermek isteyen kimse', 'zit_anlamli', 'Dost acı günde belli olur; düşman ise kötülük düşünür.', 'Dost yanında durur, düşman karşında durur.', 'hikâye'),
  ('kaygı', 'Olumsuz bir şey olacağı düşüncesiyle duyulan huzursuzluk', 'endişe', 'Gelecek hakkında duyulan tasa ve huzursuzluk', 'es_anlamli', 'Sınav kaygısı yaşayan öğrenci sınavdan önce endişeliydi.', 'İçini kaplayan tedirginlik: kaygı ve endişe.', 'çağrışım'),
  ('cesaret', 'Korkmadan bir işe girişebilme gücü', 'yiğitlik', 'Korkmadan, gözü pek davranma hâli', 'es_anlamli', 'Yiğitlik ve cesaret, zor günde insanı ayakta tutar.', 'Korkusuzca davranmanın iki adı: cesaret ve yiğitlik.', 'çağrışım'),
  ('tutum', 'Bir durum karşısında takınılan duruş, tavır', 'tavır', 'Bir durum karşısında takınılan tutum, davranış biçimi', 'es_anlamli', 'Olaya karşı tavrı çok sertti; tutumunu kimseye anlatmadı.', 'Tutum ile tavır aynı duruşu anlatır.', 'hikâye'),
  ('kanıt', 'Bir iddiayı doğrulayan belge ya da işaret', 'delil', 'Bir iddiayı destekleyen ve doğrulayan şey', 'es_anlamli', 'Mahkemede delil ve kanıt sunuldu.', 'Dedektif hem kanıt hem delil arar: ikisi de gerçeği gösterir.', 'eşleştirme'),
  ('gerçek', 'Var olan, olmuş ve doğru olan şey', 'hakikat', 'Doğru olan, gerçek olan şey', 'es_anlamli', 'Olayın gerçeğini öğrenmek istedim; hakikati bize söylediler.', 'Gerçek ile hakikat aynı doğru yolda yürür.', 'ses'),
  ('önemli', 'Değeri ve etkisi büyük olan', 'mühim', 'Önemli, değerli, ehemmiyetli', 'es_anlamli', 'Bu toplantı önemli; alınacak kararlar mühim olacak.', 'Önemli bir iş, mühim bir iştir: ikisi de büyük değer taşır.', 'eşleştirme'),
  ('anlatmak', 'Bir olayı ya da durumu sözle ya da yazıyla bildirmek', 'açıklamak', 'Bir şeyi ayrıntılarıyla anlaşılır hâle getirmek', 'es_anlamli', 'Öğretmen olayı anlattı, sonra kuralı açıkladı.', 'Anlatmak hikâye kurmak; açıklamak anlaşılır kılmaktır.', 'hikâye'),
  ('başarı', 'Amaca ulaşma, iyi sonuç alma', 'başarısızlık', 'Amaca ulaşamama durumu', 'zit_anlamli', 'Geçen yıl başarısızlık yaşadım; bu yıl başarı yakaladım.', 'Başarı yukarı çıkar, başarısızlık aşağı iner.', 'karşıtlık'),
  ('kazanmak', 'Yarışta ya da bir işte üstün gelmek', 'kaybetmek', 'Yarışta yenilmek ya da bir şeyi yitirmek', 'zit_anlamli', 'Oyunu kazandık, kardeşim ise bu sefer kaybetti.', 'Kazanan kupayı alır, kaybeden alkışlar.', 'karşıtlık'),
  ('kabul', 'Bir isteği ya da öneriyi uygun bulup onaylama', 'ret', 'Bir isteği ya da öneriyi uygun bulmayıp geri çevirme', 'zit_anlamli', 'Önerisini kabul etti, arkadaşının teklifini ise reddetti.', 'Kabul kapıyı açmak, ret kapıyı kapatmaktır.', 'eşleştirme'),
  ('sevgi', 'Birine ya da bir şeye karşı duyulan sıcak bağlılık', 'nefret', 'Bir kişiye ya da şeye karşı duyulan güçlü tiksinti', 'zit_anlamli', 'Ailesine sevgiyle bağlıydı; haksızlığa karşı nefret duyuyordu.', 'Sevgi kalbi ısıtır, nefret kalbi soğutur.', 'çağrışım'),
  ('genç', 'Yaşı az olan', 'yaşlı', 'Yaşı ilerlemiş olan', 'zit_anlamli', 'Genç torun, yaşlı dedesinin elinden tuttu.', 'Genç koşar, yaşlı yavaş yürür.', 'görsel'),
  ('ilk', 'Sıranın başında ya da önce gelen', 'son', 'Sıranın sonunda ya da en sonda gelen', 'zit_anlamli', 'Sıranın ilk öğrencisi bendim; son öğrenci ise çok geç geldi.', 'Yarışta ilk geçen birinci, en sonda gelen sonuncudur.', 'görsel'),
  ('saygı', 'Birine ya da bir değere gösterilen değer ve hürmet', 'saygısızlık', 'Birine ya da bir değere karşı saygı göstermeme davranışı', 'zit_anlamli', 'Büyüklerimize saygı gösteririz; saygısızlık etmeyiz.', 'Saygı nazik bir selamdır; saygısızlık selamı almamaktır.', 'karşıtlık'),
  ('sol', 'Sağın karşısındaki yön', 'sol', 'Müzikte yedi nottan biri', 'es_sesli', 'Sol elimle piyanoda sol notasına bastım.', 'Yön olan sol ile nota olan sol: aynı yazılış, ayrı iki anlam.', 'eşleştirme'),
  ('kaz', 'Bir tür kümes hayvanı', 'kaz', 'Toprağı kürekle ya da elle derin açmak (kazmak)', 'es_sesli', 'Göl kenarında bir kaz yüzüyordu; babam bahçeye çukur kazdı.', 'Kaz suda yüzer; toprağı kazarsın.', 'görsel'),
  ('kalıcı', 'Uzun süre devam eden, sürekli', 'geçici', 'Belli bir süre için olan, kalıcı olmayan', 'zit_anlamli', 'Bu iz kalıcıdır; kar ise geçici bir şeydi.', 'Kalıcı kalır, geçici geçer.', 'karşıtlık'),
  ('hatalı', 'Yanlışı olan, hata içeren', 'yanlış', 'Doğru olmayan, hatalı', 'es_anlamli', 'Hatalı cevabı düzeltince yanlış bir şey kalmadı.', 'Hatalı ile yanlış, aynı durumu anlatır.', 'eşleştirme'),
  ('amaç', 'Bir işle ulaşılmak istenen son nokta', 'hedef', 'Ulaşılmak istenen yer ya da amaç', 'es_anlamli', 'Okuma amacım, sınav hedefime ulaşmaktır.', 'Amaç da hedef de ulaşmak istediğin yerdir.', 'çağrışım'),
  ('yaşam', 'Canlının var olduğu süre ya da yaşama durumu', 'hayat', 'Canlıların yaşadığı süreç, yaşam', 'es_anlamli', 'Doğanın yaşamı için su gerekir; hayatın her anı değerlidir.', 'Canlı olmanın adı hem yaşam hem hayattır.', 'ses'),
  ('emek', 'Bir iş için harcanan güç, zaman ve gayret', 'çaba', 'Bir iş için gösterilen uğraş', 'es_anlamli', 'Bu bahçe benim emeğimin ve çabamın ürünüdür.', 'Emek harcanan güçtür; çaba o işe gösterilen uğraştır.', 'hareket'),
  ('tehlike', 'Zarar görme olasılığı, tehdit', 'risk', 'Zarar görme ihtimali olan durum', 'es_anlamli', 'Karda kayarken tehlike vardı; riski göze alarak yola devam ettik.', 'Tehlike ve risk, zarar ihtimalini anlatır; ikisi de dikkat ister.', 'eşleştirme'),
  ('sorun', 'Çözülmesi gereken durum ya da mesele', 'problem', 'Çözüm bekleyen durum, sorun', 'es_anlamli', 'Sınıftaki gürültü sorununu konuştuk; bu problemi çözmek için fikir ürettik.', 'Sorun da problem de çözüm isteyen durumdur.', 'eşleştirme'),
  ('önyargı', 'Bilgi edinmeden önceden oluşan olumlu ya da olumsuz kanı', 'peşin hüküm', 'Araştırılmadan önceden verilmiş yargı', 'es_anlamli', 'Yeni arkadaşıma önyargıyla bakmamalıyım; peşin hüküm vermemeliyim.', 'Önyargı ile peşin hüküm, bakmadan verilen aynı türden kararlardır.', 'eşleştirme'),
  ('övgü', 'Bir kişinin ya da şeyin iyi yanlarını dile getirme', 'takdir', 'Beğenerek değer verme, övme', 'es_anlamli', 'Başarımdan dolayı öğretmenimden övgü ve takdir aldım.', 'Övgü sözle, takdir beğeniyle verilir; ikisi de iyi sözdür.', 'çağrışım'),
  ('dürüst', 'Doğru söyleyen, güvenilir olan', 'yalancı', 'Yalan söyleyen, gerçeği söylemeyen', 'zit_anlamli', 'Dürüst çocuk hatasını kabul etti; yalancı ise yalan uyduruyordu.', 'Dürüst kişinin sözü gerçektir; yalancının sözü gerçek değildir.', 'karşıtlık'),
  ('cömert', 'Elindekini başkalarıyla paylaşmaktan çekinmeyen', 'cimri', 'Malını harcamaktan kaçınan, eli sıkı', 'zit_anlamli', 'Cömert dayı herkese şeker dağıttı; cimri komşu kapısını açmadı.', 'Cömert el açık tutar; cimri el kapalı tutar.', 'hikâye'),
  ('verimli', 'Ürün veren, bol ürünlü', 'kısır', 'Ürün vermeyen, verimsiz', 'zit_anlamli', 'Verimli topraktan bol ürün aldık; kuraklıkta tarla kısır kaldı.', 'Verimli tarla sepeti doldurur; kısır tarla boş kalır.', 'görsel'),
  ('gizli', 'Saklı, açığa vurulmamış', 'belli', 'Görünen, anlaşılan, bilinen', 'zit_anlamli', 'Gizli bir planımız vardı; plan belli olunca herkes şaşırdı.', 'Gizli olan saklıdır, belli olan göz önündedir.', 'karşıtlık'),
  ('yükseliş', 'Yukarı doğru çıkma, artış', 'düşüş', 'Aşağı doğru inme, azalma', 'zit_anlamli', 'Termometrede bir yükseliş vardı; sonra sıcaklıkta düşüş başladı.', 'Balon yükselir, taş düşer.', 'hareket'),
  ('çoğalmak', 'Sayısı ya da miktarı artmak', 'azalmak', 'Sayısı ya da miktarı eksilmek', 'zit_anlamli', 'Bahçedeki çiçekler çoğaldı; kuşların sayısı azaldı.', 'Çoğalan çiçekler yayılır, azalan kuşlar eksilir.', 'görsel'),
  ('mutluluk', 'Sevinçli ve huzurlu olma hâli', 'üzüntü', 'Keder, acı duyma hâli', 'zit_anlamli', 'Doğum günümdeki mutluluk, kaybettiğim oyuncağın üzüntüsüyle karıştı.', 'Mutluluk gülümsemedir, üzüntü gözyaşıdır.', 'ses'),
  ('yar', 'Dik, derin uçurum', 'yar', 'Yarmak eylemi, bir şeyi ikiye ayırmak', 'es_sesli', 'Uçurumun yarına yaklaşıp aşağı baktık; sel kayayı yardı.', 'Yar uçurumdur; yar da yarmak demektir: iki ayrı anlam.', 'hikâye'),
  ('kur', 'Para birimlerinin birbirine göre değeri, döviz kuru', 'kur', 'Bir şeyi yerleştirip düzenlemek, kurmak (emir)', 'es_sesli', 'Doların kuru yükseldi; sofrayı kur!', 'Döviz kuru para dünyasında, kur! ise bir emirdir.', 'görsel'),
  ('eksik', 'Tamamlanmamış, noksan olan', 'tam', 'Eksiksiz, bütün', 'zit_anlamli', 'Yapbozun parçaları eksik kaldı; tam olunca resmi gördük.', 'Eksik olan bir parçaya muhtaçtır; tam olan bütündür.', 'karşıtlık'),
  ('hayal', 'Zihinde canlandırılan, gerçek olmayan görüntü', 'düş', 'Uyurken zihinde beliren görüntü, rüya', 'es_anlamli', 'Hayalimde büyük bir kale vardı; gece düşümde onu gördüm.', 'Hayal de düş de zihinde beliren bir görüntüdür.', 'görsel'),
  ('tedirgin', 'Bir olay karşısında endişeli, huzursuz olan', 'huzursuz', 'Rahat olmayan, tedirgin olan', 'es_anlamli', 'Sınav sonucunu beklerken tedirgin ve huzursuzdum.', 'Tedirgin ve huzursuz: içi kıpır kıpır, rahatlık yok.', 'ses'),
  ('aşırı', 'Olması gerekenden çok fazla olan', 'fazla', 'Gereğinden çok olan, aşırı', 'es_anlamli', 'Aşırı gürültü beni rahatsız etti; fazla gürültü kimseye iyi gelmez.', 'Aşırı ile fazla, gereğin üstüne taşan iki kavramdır.', 'çağrışım'),
  ('karakter', 'İnsanın davranış ve düşünce biçimini belirleyen ayırt edici özellikler', 'kişilik', 'Bir kişiyi diğerlerinden ayıran özellikler bütünü', 'es_anlamli', 'Arkadaşımın kişiliği ve karakteri çok güzel.', 'Karakter ve kişilik, insanın iç yapısını anlatan iki sözcüktür.', 'eşleştirme'),
  ('eşsiz', 'Bir benzeri olmayan', 'benzersiz', 'Benzeri bulunmayan, eşsiz', 'es_anlamli', 'Bu kitap eşsiz; dünyada benzersiz bir hikâye anlatıyor.', 'Parmak izin gibi eşsiz: benzeri yoktur.', 'görsel'),
  ('tanık', 'Bir olaya bizzat görerek ya da yaşayarak katılan kişi', 'şahit', 'Bir olayı görmüş ve bildirebilen kişi', 'es_anlamli', 'Mahkemede olayın şahidi ifade verdi; tanık da aynı şeyi anlattı.', 'Olayı bizzat yaşayan tanık; olayı gören ve bildiren şahit.', 'hikâye'),
  ('ortaya çıkarmak', 'Gizli olan bir şeyi görünür hâle getirmek', 'açığa vurmak', 'Gizli bir şeyi belli etmek, açığa çıkarmak', 'es_anlamli', 'Dedektif gizli gerçeği ortaya çıkardı; sonunda gerçeği açığa vurdu.', 'Perde açılınca sahne ortaya çıkar.', 'hareket'),
  ('sadakat', 'Bir kişiye ya da değere bağlılık, vefa', 'ihanet', 'Güvenilen birine karşı yapılan kötülük, vefasızlık', 'zit_anlamli', 'Dostuna sadakatle bağlı kaldı; ihanet etmeyi aklından bile geçirmedi.', 'Sadakat kapıyı açık tutar, ihanet arkadan kapatır.', 'karşıtlık'),
  ('içten', 'Samimi, gönülden, yapmacıksız', 'yapmacık', 'Doğal olmayan, zorlama, sahte', 'zit_anlamli', 'İçten bir gülümsemeyle karşıladı; yapmacık sözleri dinlemek istemedim.', 'İçten gülüş kalpten gelir; yapmacık gülüş sahte durur.', 'karşıtlık'),
  ('ikna etmek', 'Bir kişiyi bir düşünceye ya da işe inandırmak', 'caydırmak', 'Bir kişiyi bir işten vazgeçirmek', 'zit_anlamli', 'Arkadaşımı ikna ederek gezmeye katılmasını sağladım; kötü plandan da caydırdım.', 'İkna eden kapıyı açar, caydıran kapıyı kapatır.', 'hareket'),
  ('tutarlı', 'Sözü ve davranışları birbiriyle uyumlu olan', 'tutarsız', 'Sözü ve davranışları birbiriyle uyuşmayan', 'zit_anlamli', 'Tutarlı öğrenci sözünü davranışıyla birleştirir; tutarsız olan bunu yapmaz.', 'Tutarlı kişi her yerde aynı davranır; tutarsız kişi söylediğinin tersini yapar.', 'eşleştirme'),
  ('gelişmek', 'İlerleyerek daha iyi bir duruma gelmek', 'gerilemek', 'Geriye gitmek, önceki duruma dönmek ya da kötüleşmek', 'zit_anlamli', 'Çalışmalarımla gelişiyorum; ihmal edersem gerilerim.', 'Gelişen ileri gider, gerileyen geri döner.', 'hareket'),
  ('birleşmek', 'Bir araya gelerek tek bir bütün olmak', 'ayrılmak', 'Birbirinden uzaklaşmak, bölünmek', 'zit_anlamli', 'İki dere birleşerek büyük bir ırmak oldu; sonra ayrılıp ovaya yayıldı.', 'Birleşen yollar tek olur, ayrılan yollar ikiye bölünür.', 'hareket'),
  ('uzlaşmak', 'Görüş ayrılığını bir anlaşmayla gidermek', 'çatışmak', 'Birbirine karşı çıkmak, anlaşamamak', 'zit_anlamli', 'Tartıştıktan sonra uzlaştılar; önceki gün ise çatışmışlardı.', 'Uzlaşınca barış gelir, çatışınca tartışma büyür.', 'karşıtlık'),
  ('çoğunluk', 'Sayıca fazla olan kesim', 'azınlık', 'Sayıca az olan kesim', 'zit_anlamli', 'Oylamada çoğunluk kabul etti; azınlık ise itiraz etti.', 'Çoğunlukta çok kişi, azınlıkta az kişi vardır.', 'karşıtlık'),
  ('dolu', 'İçi boş olmayan, doldurulmuş', 'dolu', 'Bir yağış türü, havadan düşen buz parçaları', 'es_sesli', 'Dolu yağınca bahçe buzla kaplandı; sepetimiz elmayla doluydu.', 'Gökten dolu yağar; sepet dolu olur.', 'çağrışım'),
  ('sadık', 'Bağlılığını sürdüren, değişmeyen', 'vefalı', 'Dostluğuna ve sözüne bağlı, vefa sahibi', 'es_anlamli', 'Sadık köpek sahibini bekledi; vefalı dost hiç yüz çevirmedi.', 'Sadık olan bağlı kalır, vefalı olan dostunu unutmaz.', 'ses'),
  ('gereksinim', 'Yaşam için eksik olan ve karşılanması gereken şey', 'ihtiyaç', 'Yaşamak ya da bir amaca ulaşmak için gerekli olan şey', 'es_anlamli', 'Su, canlıların temel bir gereksinimidir; su ihtiyacımız her gün vardır.', 'Karnın acıkması ve insanın bir şeye muhtaç olması: gereksinim ve ihtiyaç.', 'çağrışım'),
  ('olağan', 'Her zaman görülen, alışılmış', 'normal', 'Olağan, alışılmış, herkesçe beklenen', 'es_anlamli', 'Bu olağan bir durumdu; herkes normal davrandı.', 'Alışılmış olan olağan, beklenen olan normaldir.', 'eşleştirme'),
  ('tasarı', 'Yapılması düşünülen, planlanan iş', 'proje', 'Bir işi gerçekleştirmek için hazırlanan plan', 'es_anlamli', 'Okul bahçesi için bir tasarı hazırladık; proje ekibi onayladı.', 'Tasarı da proje de bir işin planlanmasını anlatır.', 'hikâye'),
  ('değiştirmek', 'Bir şeyi başka bir şeyle ya da başka hâle getirmek', 'dönüştürmek', 'Bir şeyi biçim ya da nitelik bakımından başka bir hâle sokmak', 'es_anlamli', 'Ev düzenini değiştirdik; atık kâğıtları yeni bir ürüne dönüştürdük.', 'Değiştirmek rengini değiştirmek olabilir; dönüştürmek yapısını değiştirmektir.', 'hareket'),
  ('alışkanlık', 'Bir davranışı sürekli yapmaya dayanan eğilim', 'âdet', 'Sürekli yapılan davranış, huy', 'es_anlamli', 'Her sabah kahvaltı etmek bir alışkanlıktır; bayramda birlikte yemek yemek ise aile âdetimizdir.', 'Alışkanlık ve âdet, sürekli yapılan davranışın iki adı.', 'çağrışım'),
  ('çekingen', 'Sıkılgan, kendini geri tutan', 'utangaç', 'Çevresinde kendini rahat hissetmeyen, sıkılgan', 'es_anlamli', 'Yeni sınıfta çekingen durdu; utangaç bir çocuk olduğu için sessiz kaldı.', 'Çekingen adım atmaktan kaçınır; utangaç göz kaçırır.', 'ses'),
  ('tedbirli', 'Önlem alan, dikkatli', 'dikkatli', 'Özenli, dikkat eden', 'es_anlamli', 'Tedbirli davranan sürücü, yolda dikkatli sürer.', 'Tedbir önceden alınır, dikkat anda gösterilir.', 'eşleştirme'),
  ('gerçekçi', 'Gerçeğe uygun düşünen, ayakları yere basan', 'hayalci', 'Gerçeklikten uzak, hayallerle yaşayan', 'zit_anlamli', 'Gerçekçi bir plan yaptı; hayalci arkadaşı imkânsız hayaller kurdu.', 'Gerçekçi ayakları yerde, hayalci gökte gezer.', 'karşıtlık'),
  ('bağımsız', 'Başkasına bağlı olmayan, özgür', 'bağımlı', 'Bir şeye ya da birine bağlı olan', 'zit_anlamli', 'Bağımsız bir birey kendi kararını verir; bağımlı olan başkasının desteğine muhtaçtır.', 'Bağımsız kendi ayakları üstünde durur; bağımlı desteğe muhtaçtır.', 'hikâye'),
  ('sadelik', 'Süs ve karmaşadan uzak olma hâli', 'karmaşıklık', 'Birçok parçadan oluşan, karışık olma hâli', 'zit_anlamli', 'Tasarımın sadeliği hoşuma gitti; karmaşıklık ise kafamı karıştırdı.', 'Sade bir oda ferahtır; karmaşık bir oda kalabalıktır.', 'görsel'),
  ('olumlu', 'İyi sonuç veren, yararlı, kabul edilen', 'olumsuz', 'Kötü sonuç veren, istenmeyen, olumlu olmayan', 'zit_anlamli', 'Olumlu bir sonuç aldık; olumsuz hava nedeniyle geziyi erteledik.', 'Olumlu kapı açar, olumsuz kapıyı kapatır.', 'eşleştirme'),
  ('yapıcı', 'Yeni ve iyi şeyler kuran, geliştiren', 'yıkıcı', 'Var olanı bozan, zarar veren', 'zit_anlamli', 'Yapıcı bir eleştiri yaptı; yıkıcı sözler ise kimseye yarar sağlamadı.', 'Yapıcı yapar, yıkıcı yıkar.', 'karşıtlık'),
  ('bilinçli', 'Ne yaptığının farkında olan, kasıtlı', 'bilinçsiz', 'Ne yaptığının farkında olmayan, dikkatsiz', 'zit_anlamli', 'Bilinçli seçimler yaptı; bilinçsiz davranışlardan kaçındı.', 'Bilinçli insan ne yaptığını bilir; bilinçsiz insan farkında olmadan davranır.', 'karşıtlık'),
  ('karanlık', 'Işığın az olduğu ya da hiç olmadığı durum', 'aydınlık', 'Işığın bol olduğu, ışıklı durum', 'zit_anlamli', 'Karanlıkta yolunu bulmakta zorlandı; aydınlıkta ise her şeyi gördü.', 'Karanlık gölgedir, aydınlık ışıktır.', 'görsel'),
  ('at', 'Üzerine binilen, dört ayaklı hayvan', 'at', 'Bir şeyi fırlatmak, uzağa savurmak (emir)', 'es_sesli', 'Atın üstüne bindik; topu uzağa at!', 'At ahırda durur; at! diye emredince top fırlar.', 'görsel');

update public.kelime_iliskileri i
set ornek = g.ornek, hatirlatici = g.hatirlatici, teknik = g.teknik
from kelime_icerik_girdi g
join public.kelime_anlamlari ka on ka.kelime = g.ka and ka.anlam = g.kan
join public.kelime_anlamlari ha on ha.kelime = g.ha and ha.anlam = g.han
where i.iliski_turu = g.tur
  and ((i.kaynak_anlam_id = ka.id and i.hedef_anlam_id = ha.id)
    or (i.kaynak_anlam_id = ha.id and i.hedef_anlam_id = ka.id));
