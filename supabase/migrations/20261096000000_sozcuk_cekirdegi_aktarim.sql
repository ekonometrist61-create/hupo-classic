-- Üretici: docs/kelime-evreni/veritabani/uret-cekirdek-aktarim.mjs (232 anlam).
-- Zorluk kuralı (editoryal başlangıç): sınıf_alt 1-3 -> 1, 4-6 -> 2, 7-8 -> 3; eş sesli ilişkide +1 (en çok 3).
-- Örnek cümle yalnız hedef sözcüğü (ek almış hâliyle) içeriyorsa yazılır; yoksa boş kalır.
set client_encoding = 'UTF8';

update public.kelime_anlamlari k
   set ornek_cumle = coalesce(k.ornek_cumle, v.ornek),
       sinif_alt   = v.alt,
       sinif_ust   = v.ust,
       zorluk      = v.zorluk
  from (values
  ('büyük', 'Boyu ya da miktarı fazla olan', 'Büyük topu, küçük topun yanına koyduk.', 1, 1, 1),
  ('küçük', 'Boyu ya da miktarı az olan', 'Büyük topu, küçük topun yanına koyduk.', 1, 3, 1),
  ('sıcak', 'Isısı yüksek olan', 'Çorba sıcak, limonata soğuktu.', 1, 1, 1),
  ('soğuk', 'Isısı düşük olan', 'Çorba sıcak, limonata soğuktu.', 1, 1, 1),
  ('uzun', 'Boyu ya da uzunluğu fazla olan', 'Uzun ipi kestik, kısa ip kaldı.', 1, 1, 1),
  ('kısa', 'Boyu ya da uzunluğu az olan', 'Uzun ipi kestik, kısa ip kaldı.', 1, 1, 1),
  ('açık', 'Kapalı olmayan, önünde engel bulunmayan', 'Kapı açık, pencere kapalıydı.', 1, 1, 1),
  ('kapalı', 'Açık olmayan, kapanmış olan', 'Kapı açık, pencere kapalıydı.', 1, 1, 1),
  ('dolu', 'İçi boş olmayan, doldurulmuş', 'Sepet dolu, kutu boştu.', 1, 7, 2),
  ('boş', 'İçinde hiçbir şey bulunmayan', 'Sepet dolu, kutu boştu.', 1, 1, 1),
  ('hızlı', 'Çabuk hareket eden', 'Tavşan hızlı koşar, kaplumbağa yavaş yürür.', 1, 1, 1),
  ('yavaş', 'Az hızla hareket eden', 'Tavşan hızlı koşar, kaplumbağa yavaş yürür.', 1, 1, 1),
  ('yüksek', 'Yerden uzaklığı çok olan', 'Dağ yüksek, tepe alçaktır.', 1, 1, 1),
  ('alçak', 'Yerden uzaklığı az olan', 'Dağ yüksek, tepe alçaktır.', 1, 1, 1),
  ('ıslak', 'Su ya da başka bir sıvıyla bulaşmış, nemli', 'Islak elbiseyi astık; kuru elbiseyi giydik.', 1, 1, 1),
  ('kuru', 'Su almamış, nemi olmayan', 'Islak elbiseyi astık; kuru elbiseyi giydik.', 1, 1, 1),
  ('temiz', 'Kirli olmayan, pak', 'Ellerim yıkanınca temiz oldu; çamurla oynayınca kirli kaldı.', 2, 2, 1),
  ('kirli', 'Kir ya da leke taşıyan', 'Ellerim yıkanınca temiz oldu; çamurla oynayınca kirli kaldı.', 2, 2, 1),
  ('güzel', 'Görünüşü ya da sesi hoşa giden', 'Bahçedeki çiçekler güzel, çöp yığını çirkin görünüyordu.', 2, 2, 1),
  ('çirkin', 'Güzel olmayan, hoş görünmeyen', 'Bahçedeki çiçekler güzel, çöp yığını çirkin görünüyordu.', 2, 2, 1),
  ('kolay', 'Zahmeti az olan, zor olmayan', 'Toplama işlemi kolay, bölme işlemi bana zor geldi.', 2, 2, 1),
  ('zor', 'Güçlük çıkaran, kolay olmayan', 'Toplama işlemi kolay, bölme işlemi bana zor geldi.', 2, 2, 1),
  ('ucuz', 'Fiyatı düşük olan', 'Pazardan ucuz elma aldık, mağazadaki ayakkabı pahalıydı.', 2, 2, 1),
  ('pahalı', 'Fiyatı yüksek olan', 'Pazardan ucuz elma aldık, mağazadaki ayakkabı pahalıydı.', 2, 2, 1),
  ('geniş', 'Alanı ya da içi ferah olan', 'Oyun alanımız geniş, koridor ise dardı.', 2, 2, 1),
  ('dar', 'Alanı ya da içi az, sıkışık olan', 'Oyun alanımız geniş, koridor ise dardı.', 2, 2, 1),
  ('ince', 'Kalınlığı az olan', 'İnce kâğıdı defterime koydum, kalın sözlüğü rafa kaldırdım.', 2, 2, 1),
  ('kalın', 'Kalınlığı fazla olan', 'İnce kâğıdı defterime koydum, kalın sözlüğü rafa kaldırdım.', 2, 2, 1),
  ('iyi', 'Kötü olmayan, olumlu', 'Yalan söylemek kötüdür, dürüst olmak iyidir.', 2, 2, 1),
  ('kötü', 'İyi olmayan, olumsuz', 'Yalan söylemek kötüdür, dürüst olmak iyidir.', 2, 2, 1),
  ('doğru', 'Gerçeğe uygun, yanlış olmayan', 'Sorunun cevabını doğru bulunca sevindim; yanlış yapınca tekrar denedim.', 2, 2, 1),
  ('yanlış', 'Doğru olmayan, hatalı', 'Sorunun cevabını doğru bulunca sevindim; yanlış yapınca tekrar denedim.', 2, 5, 1),
  ('gündüz', 'Güneş ışığının aydınlattığı zaman', 'Gündüz okula gidiyoruz, gece uyuyoruz.', 2, 2, 1),
  ('gece', 'Güneşin battığı andan doğuşuna kadar süren karanlık zaman', 'Gündüz okula gidiyoruz, gece uyuyoruz.', 2, 2, 1),
  ('ön', 'Bir şeyin ilerideki, yüze bakan kısmı', 'Sınıfta ön sıraya oturdum, arkadaşım arka sırada oturuyordu.', 2, 2, 1),
  ('arka', 'Bir şeyin geride kalan kısmı', 'Sınıfta ön sıraya oturdum, arkadaşım arka sırada oturuyordu.', 2, 2, 1),
  ('içeri', 'Bir yerin iç kısmına doğru', 'Yağmur başlayınca içeri girdik, hava açılınca dışarı çıktık.', 2, 2, 1),
  ('dışarı', 'Bir yerin dış kısmına doğru', 'Yağmur başlayınca içeri girdik, hava açılınca dışarı çıktık.', 2, 2, 1),
  ('yeni', 'Yakın zamanda yapılmış, eskimemiş olan', 'Yeni ayakkabımı giydim, eskisini kutuya koydum.', 2, 2, 1),
  ('eski', 'Yıllar önce yapılmış, yıpranmış olan', 'Yeni ayakkabımı giydim, eskisini kutuya koydum.', 2, 2, 1),
  ('mutlu', 'Sevinç duyan, neşeli', 'Bayram sabahı herkes mutlu ve sevinçli uyandı.', 3, 3, 1),
  ('sevinçli', 'Sevinç duyan, mutlu', 'Bayram sabahı herkes mutlu ve sevinçli uyandı.', 3, 3, 1),
  ('hızlı', 'Çabuk hareket eden, süratli', 'Hızlı koşan çocuk yarışı çabuk bitirdi.', 3, 3, 1),
  ('çabuk', 'Kısa sürede gerçekleşen, hızlı', 'Hızlı koşan çocuk yarışı çabuk bitirdi.', 3, 3, 1),
  ('arkadaş', 'Birlikte vakit geçirilen, yakın olunan kişi', 'Okuldaki arkadaşım aynı zamanda en iyi dostumdur.', 3, 3, 1),
  ('dost', 'Sevgi ve güvenle bağlı olunan yakın kişi', 'Okuldaki arkadaşım aynı zamanda en iyi dostumdur.', 3, 3, 1),
  ('ev', 'İnsanların yaşadığı yer', 'Ailem yeni bir ev aldı; bu konut okula yakın.', 3, 3, 1),
  ('konut', 'İnsanların oturduğu yapı, mesken', 'Ailem yeni bir ev aldı; bu konut okula yakın.', 3, 3, 1),
  ('yanıt', 'Bir soruya verilen karşılık', 'Öğretmenin sorusuna doğru yanıt verdim, cevabım alkışlandı.', 3, 3, 1),
  ('cevap', 'Bir soruya ya da söze karşılık olarak verilen yanıt', 'Öğretmenin sorusuna doğru yanıt verdim, cevabım alkışlandı.', 3, 3, 1),
  ('kent', 'Kalabalık, büyük yerleşim yeri', 'Bu kent, yani bu şehir, kalabalık bir yerleşim yeridir.', 3, 3, 1),
  ('şehir', 'Kalabalık ve gelişmiş yerleşim birimi', 'Bu kent, yani bu şehir, kalabalık bir yerleşim yeridir.', 3, 3, 1),
  ('minik', 'Çok küçük, ufacık', 'Minik kuş, küçük bir dalda ötüyordu.', 3, 3, 1),
  ('sevinç', 'Bir şeyden dolayı duyulan mutluluk', 'Doğum günümde sevinç ve neşe doluydum.', 3, 3, 1),
  ('neşe', 'Canlı ve sevinçli olma hâli', 'Doğum günümde sevinç ve neşe doluydum.', 3, 3, 1),
  ('cesur', 'Korkmayan, yiğit', 'Cesur çocuk karanlık odaya girdi, korkak kardeşi kapıda kaldı.', 3, 3, 1),
  ('korkak', 'Kolay korkan, cesareti az olan', 'Cesur çocuk karanlık odaya girdi, korkak kardeşi kapıda kaldı.', 3, 3, 1),
  ('zengin', 'Parası ve malı çok olan', 'Zengin tüccar, fakir çiftçiye yardım etti.', 3, 3, 1),
  ('fakir', 'Parası ve malı az olan, yoksul', 'Zengin tüccar, fakir çiftçiye yardım etti.', 3, 3, 1),
  ('güçlü', 'Kuvvetli, dayanıklı', 'Güçlü pehlivan ağır çuvalı kaldırdı, zayıf çocuk zorlandı.', 3, 3, 1),
  ('zayıf', 'Gücü az olan, kuvvetsiz', 'Güçlü pehlivan ağır çuvalı kaldırdı, zayıf çocuk zorlandı.', 3, 3, 1),
  ('ağır', 'Ağırlığı çok olan', 'Taş ağırdı, tüy ise hafifti.', 3, 3, 1),
  ('hafif', 'Ağırlığı az olan', 'Taş ağırdı, tüy ise hafifti.', 3, 3, 1),
  ('sert', 'Dokunulunca içine girilmeyen, katı', 'Taş sert, yastık yumuşaktır.', 3, 3, 1),
  ('yumuşak', 'Dokunulunca kolayca basılan, sert olmayan', 'Taş sert, yastık yumuşaktır.', 3, 3, 1),
  ('dağınık', 'Düzensiz, karışık', 'Odam dağınıktı; temizledikten sonra düzenli oldu.', 3, 3, 1),
  ('düzenli', 'Düzeni olan, yerli yerinde olan', 'Odam dağınıktı; temizledikten sonra düzenli oldu.', 3, 3, 1),
  ('yüz', 'Başın ön tarafında, alın ile çene arasındaki bölüm, surat', 'Yüzünü yıkadım; sınıfta yüz öğrenci vardı.', 4, 4, 3),
  ('yüz', 'Doksan dokuzdan sonra gelen sayının adı', 'Yüzünü yıkadım; sınıfta yüz öğrenci vardı.', 4, 4, 3),
  ('gül', 'Dikenli dalında kokulu çiçek açan bitki', 'Bahçedeki gül güzel kokuyordu; şakaya herkes güldü.', 4, 4, 3),
  ('gül', 'Sevinç ya da eğlenceyle yüzü açılıp ses çıkarmak (gülmek)', 'Bahçedeki gül güzel kokuyordu; şakaya herkes güldü.', 4, 4, 3),
  ('yaz', 'Yılın en sıcak mevsimi', 'Yaz tatilinde defterime yeni kelimeleri yazdım.', 4, 4, 3),
  ('yaz', 'Kâğıt üzerine harf, kelime ya da rakam geçirmek', 'Yaz tatilinde defterime yeni kelimeleri yazdım.', 4, 4, 3),
  ('çay', 'Yaprağı demlenerek içilen sıcak içecek', 'Bardağımdaki çayı içtim, sonra çayın kenarında yürüdüm.', 4, 4, 3),
  ('çay', 'Dereden büyük, ırmaktan küçük akarsu', 'Bardağımdaki çayı içtim, sonra çayın kenarında yürüdüm.', 4, 4, 3),
  ('yaş', 'Doğuştan beri geçen ve yıl birimi ile ölçülen zaman', 'Büyükbabamın yaşı yetmiş; yaş odunu sobaya koymadık.', 4, 4, 3),
  ('yaş', 'Nemli, ıslak', 'Büyükbabamın yaşı yetmiş; yaş odunu sobaya koymadık.', 4, 4, 3),
  ('bağ', 'Üzüm yetiştirilen bahçe', 'Bağdan üzüm topladık; ayakkabımın bağını bağladım.', 4, 4, 3),
  ('bağ', 'İki şeyi birbirine bağlayan ip ya da şerit', 'Bağdan üzüm topladık; ayakkabımın bağını bağladım.', 4, 4, 3),
  ('kuşku', 'Bir durum hakkında kesin karar verememe hâli', 'Hikâyedeki bilgiye kuşkuyla yaklaştım, içimde şüphe kaldı.', 4, 4, 2),
  ('şüphe', 'Doğruluğundan emin olamama durumu', 'Hikâyedeki bilgiye kuşkuyla yaklaştım, içimde şüphe kaldı.', 4, 4, 2),
  ('hatıra', 'Geçmişte yaşanan bir olayın akılda kalan izi', 'Bu fotoğraf bana güzel bir hatıra bıraktı; eski anılarımızı konuştuk.', 4, 4, 2),
  ('anı', 'Geçmişte yaşanmış olayların akılda kalan parçası', 'Bu fotoğraf bana güzel bir hatıra bıraktı; eski anılarımızı konuştuk.', 4, 4, 2),
  ('yarışma', 'Birkaç kişinin üstünlük için karşılaşması', 'Okulda bilgi yarışması vardı; müsabakada ilk üçe girdim.', 4, 4, 2),
  ('müsabaka', 'Spor ya da bilgi alanında yapılan karşılaşma, yarış', 'Okulda bilgi yarışması vardı; müsabakada ilk üçe girdim.', 4, 4, 2),
  ('gayret', 'İstekle, emek vererek bir işe çalışma', 'Sınava hazırlanırken gösterdiğim gayret ve çaba meyvesini verdi.', 4, 4, 2),
  ('çaba', 'Bir iş için gösterilen uğraş', 'Sınava hazırlanırken gösterdiğim gayret ve çaba meyvesini verdi.', 4, 6, 2),
  ('sakin', 'Gürültüsüz, huzurlu, telaşsız', 'Sakin bir göl ve dingin bir akşam vardı.', 4, 4, 2),
  ('dingin', 'Sessiz, durgun, huzurlu', 'Sakin bir göl ve dingin bir akşam vardı.', 4, 4, 2),
  ('tembel', 'İş yapmaktan kaçınan, ağır işleyen', 'Tembel çocuk ödevini yapmadı; çalışkan kardeşi erkenden bitirdi.', 4, 4, 2),
  ('çalışkan', 'Çok çalışan, işini severek yapan', 'Tembel çocuk ödevini yapmadı; çalışkan kardeşi erkenden bitirdi.', 4, 4, 2),
  ('geçmiş', 'Geride kalan, eski zaman', 'Geçmişte yaşananları anlatırken geleceği de düşündük.', 4, 4, 2),
  ('gelecek', 'Henüz gelmemiş olan zaman', 'Geçmişte yaşananları anlatırken geleceği de düşündük.', 4, 4, 2),
  ('az', 'Miktarı ya da sayısı küçük olan', 'Az su içtim, kardeşim çok su içti.', 4, 4, 2),
  ('çok', 'Miktarı ya da sayısı fazla olan', 'Az su içtim, kardeşim çok su içti.', 4, 4, 2),
  ('yakın', 'Uzaklığı az olan', 'Evimiz okula yakın, hastane ise uzaktır.', 4, 4, 2),
  ('uzak', 'Uzaklığı fazla olan', 'Evimiz okula yakın, hastane ise uzaktır.', 4, 4, 2),
  ('kalabalık', 'İnsanların çok olduğu, dolu', 'Pazar yeri kalabalıktı; dağ yolu ise tenhaydı.', 4, 4, 2),
  ('tenha', 'İnsan bulunmayan, ıssız', 'Pazar yeri kalabalıktı; dağ yolu ise tenhaydı.', 4, 4, 2),
  ('dost', 'Sevgi ve güvenle bağlı olunan kişi', 'Dost acı günde belli olur; düşman ise kötülük düşünür.', 4, 4, 2),
  ('düşman', 'Bir kişiye karşı kötü duygu besleyen, zarar vermek isteyen kimse', 'Dost acı günde belli olur; düşman ise kötülük düşünür.', 4, 4, 2),
  ('kaygı', 'Olumsuz bir şey olacağı düşüncesiyle duyulan huzursuzluk', 'Sınav kaygısı yaşayan öğrenci, sınav yaklaştıkça büyük bir endişe duyuyordu.', 5, 5, 2),
  ('endişe', 'Gelecek hakkında duyulan tasa ve huzursuzluk', 'Sınav kaygısı yaşayan öğrenci, sınav yaklaştıkça büyük bir endişe duyuyordu.', 5, 5, 2),
  ('cesaret', 'Korkmadan bir işe girişebilme gücü', 'Yiğitlik ve cesaret, zor günde insanı ayakta tutar.', 5, 5, 2),
  ('yiğitlik', 'Korkmadan, gözü pek davranma hâli', 'Yiğitlik ve cesaret, zor günde insanı ayakta tutar.', 5, 5, 2),
  ('tutum', 'Bir durum karşısında takınılan duruş, tavır', 'Olaya karşı tavrı çok sertti; tutumunu kimseye anlatmadı.', 5, 5, 2),
  ('tavır', 'Bir durum karşısında takınılan tutum, davranış biçimi', 'Olaya karşı tavrı çok sertti; tutumunu kimseye anlatmadı.', 5, 5, 2),
  ('kanıt', 'Bir iddiayı doğrulayan belge ya da işaret', 'Mahkemede delil ve kanıt sunuldu.', 5, 5, 2),
  ('delil', 'Bir iddiayı destekleyen ve doğrulayan şey', 'Mahkemede delil ve kanıt sunuldu.', 5, 5, 2),
  ('gerçek', 'Var olan, olmuş ve doğru olan şey', 'Olayın gerçeğini öğrenmek istedim; hakikati bize söylediler.', 5, 5, 2),
  ('hakikat', 'Doğru olan, gerçek olan şey', 'Olayın gerçeğini öğrenmek istedim; hakikati bize söylediler.', 5, 5, 2),
  ('önemli', 'Değeri ve etkisi büyük olan', 'Bu toplantı önemli; alınacak kararlar mühim olacak.', 5, 5, 2),
  ('mühim', 'Kendisine özen gösterilmesi gereken, dikkate değer, ehemmiyetli', 'Bu toplantı önemli; alınacak kararlar mühim olacak.', 5, 5, 2),
  ('anlatmak', 'Bir olayı ya da durumu sözle ya da yazıyla bildirmek', null, 5, 5, 2),
  ('açıklamak', 'Bir şeyi ayrıntılarıyla anlaşılır hâle getirmek', null, 5, 5, 2),
  ('başarı', 'Amaca ulaşma, iyi sonuç alma', 'Geçen yıl başarısızlık yaşadım; bu yıl başarı yakaladım.', 5, 5, 2),
  ('başarısızlık', 'Amaca ulaşamama durumu', 'Geçen yıl başarısızlık yaşadım; bu yıl başarı yakaladım.', 5, 5, 2),
  ('kazanmak', 'Yarışta ya da bir işte üstün gelmek', null, 5, 5, 2),
  ('kaybetmek', 'Yarışta yenilmek ya da bir şeyi yitirmek', null, 5, 5, 2),
  ('kabul', 'Bir isteği ya da öneriyi uygun bulup onaylama', 'Önerisini kabul etti, arkadaşının teklifini ise reddetti.', 5, 5, 2),
  ('ret', 'Bir isteği ya da öneriyi uygun bulmayıp geri çevirme', null, 5, 5, 2),
  ('sevgi', 'Birine ya da bir şeye karşı duyulan sıcak bağlılık', 'Ailesine sevgiyle bağlıydı; haksızlığa karşı nefret duyuyordu.', 5, 5, 2),
  ('nefret', 'Bir kişiye ya da şeye karşı duyulan güçlü tiksinti', 'Ailesine sevgiyle bağlıydı; haksızlığa karşı nefret duyuyordu.', 5, 5, 2),
  ('genç', 'Yaşı az olan', 'Genç torun, yaşlı dedesinin elinden tuttu.', 5, 5, 2),
  ('yaşlı', 'Yaşı ilerlemiş olan', 'Genç torun, yaşlı dedesinin elinden tuttu.', 5, 5, 2),
  ('ilk', 'Sıranın başında ya da önce gelen', 'Sıranın ilk öğrencisi bendim; son öğrenci ise çok geç geldi.', 5, 5, 2),
  ('son', 'Sıranın sonunda ya da en sonda gelen', 'Sıranın ilk öğrencisi bendim; son öğrenci ise çok geç geldi.', 5, 5, 2),
  ('saygı', 'Birine ya da bir değere gösterilen değer ve hürmet', 'Büyüklerimize saygı gösteririz; saygısızlık etmeyiz.', 5, 5, 2),
  ('saygısızlık', 'Birine ya da bir değere karşı saygı göstermeme davranışı', 'Büyüklerimize saygı gösteririz; saygısızlık etmeyiz.', 5, 5, 2),
  ('sol', 'Sağın karşısındaki yön', 'Sol elimle piyanoda sol notasına bastım.', 5, 5, 3),
  ('sol', 'Müzikte yedi ana notadan biri', 'Sol elimle piyanoda sol notasına bastım.', 5, 5, 3),
  ('kaz', 'Bir tür kümes hayvanı', 'Göl kenarında bir kaz yüzüyordu; babam bahçeye çukur kazdı.', 5, 5, 3),
  ('kaz', 'Toprağı kürekle ya da elle derin açmak (kazmak)', 'Göl kenarında bir kaz yüzüyordu; babam bahçeye çukur kazdı.', 5, 5, 3),
  ('kalıcı', 'Uzun süre devam eden, sürekli', 'Bu iz kalıcıdır; kar ise geçici bir şeydi.', 5, 5, 2),
  ('geçici', 'Belli bir süre için olan, kalıcı olmayan', 'Bu iz kalıcıdır; kar ise geçici bir şeydi.', 5, 5, 2),
  ('hatalı', 'Yanlışı olan, hata içeren', 'Hatalı cevabı düzeltince yanlış bir şey kalmadı.', 5, 5, 2),
  ('amaç', 'Bir işle ulaşılmak istenen son nokta', 'Okuma amacım, sınav hedefime ulaşmaktır.', 6, 6, 2),
  ('hedef', 'Ulaşılmak istenen yer ya da amaç', 'Okuma amacım, sınav hedefime ulaşmaktır.', 6, 6, 2),
  ('yaşam', 'Canlının var olduğu süre ya da yaşama durumu', 'Doğanın yaşamı için su gerekir; hayatın her anı değerlidir.', 6, 6, 2),
  ('hayat', 'Canlıların yaşadığı süreç, yaşam', 'Doğanın yaşamı için su gerekir; hayatın her anı değerlidir.', 6, 6, 2),
  ('emek', 'Bir iş için harcanan güç, zaman ve gayret', 'Bu bahçe benim emeğimin ve çabamın ürünüdür.', 6, 6, 2),
  ('tehlike', 'Zarar görme olasılığı, tehdit', 'Karda kayarken tehlike vardı; riski göze alarak yola devam ettik.', 6, 6, 2),
  ('risk', 'Zarar görme ihtimali olan durum', 'Karda kayarken tehlike vardı; riski göze alarak yola devam ettik.', 6, 6, 2),
  ('sorun', 'Çözülmesi gereken durum ya da mesele', 'Sınıftaki gürültü sorununu konuştuk; bu problemi çözmek için fikir ürettik.', 6, 6, 2),
  ('problem', 'Çözüm bekleyen durum, sorun', 'Sınıftaki gürültü sorununu konuştuk; bu problemi çözmek için fikir ürettik.', 6, 6, 2),
  ('önyargı', 'Bilgi edinmeden önceden oluşan olumlu ya da olumsuz kanı', null, 6, 6, 2),
  ('peşin hüküm', 'Araştırılmadan önceden verilmiş yargı', 'Yeni arkadaşıma ön yargıyla bakmamalıyım; peşin hüküm vermemeliyim.', 6, 6, 2),
  ('övgü', 'Bir kişinin ya da şeyin iyi yanlarını dile getirme', 'Başarımdan dolayı öğretmenimden övgü ve takdir aldım.', 6, 6, 2),
  ('takdir', 'Beğenerek değer verme, övme', 'Başarımdan dolayı öğretmenimden övgü ve takdir aldım.', 6, 6, 2),
  ('dürüst', 'Doğru söyleyen, güvenilir olan', 'Dürüst çocuk hatasını kabul etti; yalancı ise yalan uyduruyordu.', 6, 6, 2),
  ('yalancı', 'Yalan söyleyen, gerçeği söylemeyen', 'Dürüst çocuk hatasını kabul etti; yalancı ise yalan uyduruyordu.', 6, 6, 2),
  ('cömert', 'Elindekini başkalarıyla paylaşmaktan çekinmeyen', 'Cömert dayı herkese şeker dağıttı; cimri komşu kapısını açmadı.', 6, 6, 2),
  ('cimri', 'Malını harcamaktan kaçınan, eli sıkı', 'Cömert dayı herkese şeker dağıttı; cimri komşu kapısını açmadı.', 6, 6, 2),
  ('verimli', 'Ürün veren, bol ürünlü', 'Verimli topraktan bol ürün aldık; kuraklıkta tarla kısır kaldı.', 6, 6, 2),
  ('kısır', 'Ürün vermeyen, verimsiz', 'Verimli topraktan bol ürün aldık; kuraklıkta tarla kısır kaldı.', 6, 6, 2),
  ('gizli', 'Saklı, açığa vurulmamış', 'Gizli bir planımız vardı; plan belli olunca herkes şaşırdı.', 6, 6, 2),
  ('belli', 'Görünen, anlaşılan, bilinen', 'Gizli bir planımız vardı; plan belli olunca herkes şaşırdı.', 6, 6, 2),
  ('yükseliş', 'Yukarı doğru çıkma, artış', 'Termometrede bir yükseliş vardı; sonra sıcaklıkta düşüş başladı.', 6, 6, 2),
  ('düşüş', 'Aşağı doğru inme, azalma', 'Termometrede bir yükseliş vardı; sonra sıcaklıkta düşüş başladı.', 6, 6, 2),
  ('çoğalmak', 'Sayısı ya da miktarı artmak', null, 6, 6, 2),
  ('azalmak', 'Sayısı ya da miktarı eksilmek', null, 6, 6, 2),
  ('mutluluk', 'Sevinçli ve huzurlu olma hâli', 'Doğum günümdeki mutluluk, kaybettiğim oyuncağın üzüntüsüyle karıştı.', 6, 6, 2),
  ('üzüntü', 'Keder, acı duyma hâli', 'Doğum günümdeki mutluluk, kaybettiğim oyuncağın üzüntüsüyle karıştı.', 6, 6, 2),
  ('yar', 'Dik, derin uçurum', 'Derin bir yarığa yaklaşıp aşağı baktık; sel kayayı yardı.', 6, 6, 3),
  ('yar', 'Yarmak eylemi, bir şeyi ikiye ayırmak', 'Derin bir yarığa yaklaşıp aşağı baktık; sel kayayı yardı.', 6, 6, 3),
  ('kur', 'Para birimlerinin birbirine göre değeri, döviz kuru', 'Doların kuru yükseldi; sofrayı kur!', 6, 6, 3),
  ('kur', 'Bir şeyi yerleştirip düzenlemek, kurmak (emir)', 'Doların kuru yükseldi; sofrayı kur!', 6, 6, 3),
  ('eksik', 'Tamamlanmamış, noksan olan', 'Yapbozun parçaları eksik kaldı; tam olunca resmi gördük.', 6, 6, 2),
  ('tam', 'Eksiksiz, bütün', 'Yapbozun parçaları eksik kaldı; tam olunca resmi gördük.', 6, 6, 2),
  ('hayal', 'Zihinde canlandırılan, gerçek olmayan görüntü', 'Hayalimde büyük bir kale vardı; gece düşümde onu gördüm.', 7, 7, 3),
  ('düş', 'Zihinde canlanan, gerçek olmayan imge', 'Hayalimde büyük bir kale vardı; gece düşümde onu gördüm.', 7, 7, 3),
  ('tedirgin', 'Bir olay karşısında endişeli, huzursuz olan', 'Sınav sonucunu beklerken tedirgin ve huzursuzdum.', 7, 7, 3),
  ('huzursuz', 'Rahat olmayan, tedirgin olan', 'Sınav sonucunu beklerken tedirgin ve huzursuzdum.', 7, 7, 3),
  ('aşırı', 'Olması gerekenden çok fazla olan', 'Aşırı gürültü beni rahatsız etti; fazla gürültü kimseye iyi gelmez.', 7, 7, 3),
  ('fazla', 'Gereğinden çok olan, aşırı', 'Aşırı gürültü beni rahatsız etti; fazla gürültü kimseye iyi gelmez.', 7, 7, 3),
  ('karakter', 'İnsanın davranış ve düşünce biçimini belirleyen ayırt edici özellikler', 'Arkadaşımın kişiliği ve karakteri çok güzel.', 7, 7, 3),
  ('kişilik', 'Bir kişiyi diğerlerinden ayıran özellikler bütünü', 'Arkadaşımın kişiliği ve karakteri çok güzel.', 7, 7, 3),
  ('eşsiz', 'Bir benzeri olmayan', 'Bu kitap eşsiz; dünyada benzersiz bir hikâye anlatıyor.', 7, 7, 3),
  ('benzersiz', 'Benzeri bulunmayan, eşsiz', 'Bu kitap eşsiz; dünyada benzersiz bir hikâye anlatıyor.', 7, 7, 3),
  ('tanık', 'Bir olaya bizzat görerek ya da yaşayarak katılan kişi', 'Mahkemede olayın şahidi ifade verdi; tanık da aynı şeyi anlattı.', 7, 7, 3),
  ('şahit', 'Bir olayı görmüş ve bildirebilen kişi', 'Mahkemede olayın şahidi ifade verdi; tanık da aynı şeyi anlattı.', 7, 7, 3),
  ('ortaya çıkarmak', 'Gizli olan bir şeyi görünür hâle getirmek', null, 7, 7, 3),
  ('açığa vurmak', 'Gizli bir şeyi belli etmek, açığa çıkarmak', null, 7, 7, 3),
  ('sadakat', 'Bir kişiye ya da değere bağlılık, vefa', 'Dostuna sadakatle bağlı kaldı; ihanet etmeyi aklından bile geçirmedi.', 7, 7, 3),
  ('ihanet', 'Güvenilen birine karşı yapılan kötülük, vefasızlık', 'Dostuna sadakatle bağlı kaldı; ihanet etmeyi aklından bile geçirmedi.', 7, 7, 3),
  ('içten', 'Samimi, gönülden, yapmacıksız', 'İçten bir gülümsemeyle karşıladı; yapmacık sözleri dinlemek istemedim.', 7, 7, 3),
  ('yapmacık', 'Doğal olmayan, zorlama, sahte', 'İçten bir gülümsemeyle karşıladı; yapmacık sözleri dinlemek istemedim.', 7, 7, 3),
  ('ikna etmek', 'Bir kişiyi bir düşünceye ya da işe inandırmak', null, 7, 7, 3),
  ('caydırmak', 'Bir kişiyi bir işten vazgeçirmek', null, 7, 7, 3),
  ('tutarlı', 'Sözü ve davranışları birbiriyle uyumlu olan', 'Tutarlı öğrenci sözünü davranışıyla birleştirir; tutarsız olan bunu yapmaz.', 7, 7, 3),
  ('tutarsız', 'Sözü ve davranışları birbiriyle uyuşmayan', 'Tutarlı öğrenci sözünü davranışıyla birleştirir; tutarsız olan bunu yapmaz.', 7, 7, 3),
  ('gelişmek', 'İlerleyerek daha iyi bir duruma gelmek', null, 7, 7, 3),
  ('gerilemek', 'Geriye gitmek, önceki duruma dönmek ya da kötüleşmek', null, 7, 7, 3),
  ('birleşmek', 'Bir araya gelerek tek bir bütün olmak', null, 7, 7, 3),
  ('ayrılmak', 'Birbirinden uzaklaşmak, bölünmek', null, 7, 7, 3),
  ('uzlaşmak', 'Görüş ayrılığını bir anlaşmayla gidermek', null, 7, 7, 3),
  ('çatışmak', 'Birbirine karşı çıkmak, anlaşamamak', 'Tartıştıktan sonra uzlaştılar; önceki gün ise çatışmışlardı.', 7, 7, 3),
  ('çoğunluk', 'Sayıca fazla olan kesim', 'Oylamada çoğunluk kabul etti; azınlık ise itiraz etti.', 7, 7, 3),
  ('azınlık', 'Sayıca az olan kesim', 'Oylamada çoğunluk kabul etti; azınlık ise itiraz etti.', 7, 7, 3),
  ('dolu', 'Bir yağış türü, havadan düşen buz parçaları', 'Dolu yağınca bahçe buzla kaplandı; sepetimiz elmayla doluydu.', 7, 7, 3),
  ('sadık', 'Bağlılığını sürdüren, değişmeyen', 'Sadık köpek sahibini bekledi; vefalı dost hiç yüz çevirmedi.', 7, 7, 3),
  ('vefalı', 'Dostluğuna ve sözüne bağlı, vefa sahibi', 'Sadık köpek sahibini bekledi; vefalı dost hiç yüz çevirmedi.', 7, 7, 3),
  ('gereksinim', 'Yaşam için eksik olan ve karşılanması gereken şey', 'Su, canlıların temel bir gereksinimidir; su ihtiyacımız her gün vardır.', 8, 8, 3),
  ('ihtiyaç', 'Yaşamak ya da bir amaca ulaşmak için gerekli olan şey', 'Su, canlıların temel bir gereksinimidir; su ihtiyacımız her gün vardır.', 8, 8, 3),
  ('olağan', 'Her zaman görülen, alışılmış', 'Bu olağan bir durumdu; herkes normal davrandı.', 8, 8, 3),
  ('normal', 'Olağan, alışılmış, herkesçe beklenen', 'Bu olağan bir durumdu; herkes normal davrandı.', 8, 8, 3),
  ('tasarı', 'Yapılması düşünülen, planlanan iş', 'Okul bahçesi için bir tasarı hazırladık; proje ekibi onayladı.', 8, 8, 3),
  ('proje', 'Bir işi gerçekleştirmek için hazırlanan plan', 'Okul bahçesi için bir tasarı hazırladık; proje ekibi onayladı.', 8, 8, 3),
  ('değiştirmek', 'Bir şeyi başka bir şeyle ya da başka hâle getirmek', null, 8, 8, 3),
  ('dönüştürmek', 'Bir şeyi biçim ya da nitelik bakımından başka bir hâle sokmak', null, 8, 8, 3),
  ('alışkanlık', 'Bir davranışı sürekli yapmaya dayanan eğilim', 'Her sabah kitap okumak güzel bir alışkanlıktır; bu yararlı âdeti hayatımız boyunca sürdürmeliyiz.', 8, 8, 3),
  ('âdet', 'Sürekli yapılan davranış, huy', 'Her sabah kitap okumak güzel bir alışkanlıktır; bu yararlı âdeti hayatımız boyunca sürdürmeliyiz.', 8, 8, 3),
  ('çekingen', 'Sıkılgan, kendini geri tutan', 'Yeni sınıfta çekingen durdu; utangaç bir çocuk olduğu için sessiz kaldı.', 8, 8, 3),
  ('utangaç', 'Çevresinde kendini rahat hissetmeyen, sıkılgan', 'Yeni sınıfta çekingen durdu; utangaç bir çocuk olduğu için sessiz kaldı.', 8, 8, 3),
  ('tedbirli', 'Önlem alan, dikkatli', 'Tedbirli davranan sürücü, yolda dikkatli sürer.', 8, 8, 3),
  ('dikkatli', 'Özenli, dikkat eden', 'Tedbirli davranan sürücü, yolda dikkatli sürer.', 8, 8, 3),
  ('gerçekçi', 'Gerçeğe uygun düşünen, ayakları yere basan', 'Gerçekçi bir plan yaptı; hayalci arkadaşı imkânsız hayaller kurdu.', 8, 8, 3),
  ('hayalci', 'Gerçeklikten uzak, hayallerle yaşayan', 'Gerçekçi bir plan yaptı; hayalci arkadaşı imkânsız hayaller kurdu.', 8, 8, 3),
  ('bağımsız', 'Başkasına bağlı olmayan, özgür', 'Bağımsız bir birey kendi kararını verir; bağımlı olan başkasının desteğine muhtaçtır.', 8, 8, 3),
  ('bağımlı', 'Bir şeye ya da birine bağlı olan', 'Bağımsız bir birey kendi kararını verir; bağımlı olan başkasının desteğine muhtaçtır.', 8, 8, 3),
  ('sadelik', 'Süs ve karmaşadan uzak olma hâli', 'Tasarımın sadeliği hoşuma gitti; karmaşıklık ise kafamı karıştırdı.', 8, 8, 3),
  ('karmaşıklık', 'Birçok parçadan oluşan, karışık olma hâli', 'Tasarımın sadeliği hoşuma gitti; karmaşıklık ise kafamı karıştırdı.', 8, 8, 3),
  ('olumlu', 'İyi sonuç veren, yararlı, kabul edilen', 'Olumlu bir sonuç aldık; olumsuz hava nedeniyle geziyi erteledik.', 8, 8, 3),
  ('olumsuz', 'Kötü sonuç veren, istenmeyen, olumlu olmayan', 'Olumlu bir sonuç aldık; olumsuz hava nedeniyle geziyi erteledik.', 8, 8, 3),
  ('yapıcı', 'Yeni ve iyi şeyler kuran, geliştiren', 'Yapıcı bir eleştiri yaptı; yıkıcı sözler ise kimseye yarar sağlamadı.', 8, 8, 3),
  ('yıkıcı', 'Var olanı bozan, zarar veren', 'Yapıcı bir eleştiri yaptı; yıkıcı sözler ise kimseye yarar sağlamadı.', 8, 8, 3),
  ('bilinçli', 'Ne yaptığının farkında olan, kasıtlı', 'Bilinçli seçimler yaptı; bilinçsiz davranışlardan kaçındı.', 8, 8, 3),
  ('bilinçsiz', 'Ne yaptığının farkında olmayan, dikkatsiz', 'Bilinçli seçimler yaptı; bilinçsiz davranışlardan kaçındı.', 8, 8, 3),
  ('karanlık', 'Işığın az olduğu ya da hiç olmadığı durum', 'Karanlıkta yolunu bulmakta zorlandı; aydınlıkta ise her şeyi gördü.', 8, 8, 3),
  ('aydınlık', 'Işığın bol olduğu, ışıklı durum', 'Karanlıkta yolunu bulmakta zorlandı; aydınlıkta ise her şeyi gördü.', 8, 8, 3),
  ('at', 'Üzerine binilen, dört ayaklı hayvan', 'Atın üstüne bindik; topu uzağa at!', 8, 8, 3),
  ('at', 'Bir şeyi fırlatmak, uzağa savurmak (emir)', 'Atın üstüne bindik; topu uzağa at!', 8, 8, 3)
  ) as v(kelime, anlam, ornek, alt, ust, zorluk)
 where k.kelime = v.kelime and k.anlam = v.anlam;

-- Taslak soruların zorluğu sınıf vekilinden anlamın editoryal zorluğuna geçer (yayındakilere dokunulmaz).
update public.kelime_sorulari s
   set zorluk = a.zorluk
  from public.kelime_anlamlari a
 where a.id = s.anlam_id and a.zorluk is not null and s.durum = 'taslak';

-- Hikâye sözlüğü girdileri çekirdeğe anlam olarak girer (kelime en çok 60 karakter); aynı (kelime, anlam) tek satırdır.
insert into public.kelime_anlamlari (kelime, anlam, tur, sinif_alt, sinif_ust)
select g.yazim, g.anlam, g.tur, min(g.sinif_alt), max(g.sinif_ust)
  from public.okuma_sozluk_girdileri g
 where length(btrim(g.yazim)) between 1 and 60 and length(btrim(g.anlam)) between 2 and 300
 group by g.yazim, g.anlam, g.tur
on conflict (kelime, anlam) do nothing;

-- Aynı metinli eşleşme kesindir -> onayli. Çekirdekte aynı yazımlı başka anlam varsa öneri olarak eklenir (insan bakar).
insert into public.kelime_hikaye_baglari (anlam_id, sozluk_girdi_id, durum)
select a.id, g.id, 'onayli'
  from public.okuma_sozluk_girdileri g
  join public.kelime_anlamlari a on a.kelime = g.yazim and a.anlam = g.anlam
on conflict do nothing;

insert into public.kelime_hikaye_baglari (anlam_id, sozluk_girdi_id, durum)
select a.id, g.id, 'oneri'
  from public.okuma_sozluk_girdileri g
  join public.kelime_anlamlari a
    on lower(translate(a.kelime, 'İI', 'iı')) = lower(translate(g.yazim, 'İI', 'iı')) and a.anlam <> g.anlam
 where g.tur = 'kelime' and a.tur = 'kelime'
on conflict do nothing;

-- Aynı zaman damgasında çelişen kayıtlarda temkinli sıra: pass olmayan kayıt "son" sayılır.
create or replace function public._kelime_iki_model_gecti(p_tur text, p_id text, p_sonra timestamptz)
returns boolean
language sql
stable
set search_path = ''
as $fn$
  select coalesce(
           count(distinct t.denetci_aile) filter (where t.karar = 'pass') >= 2
           and bool_and(t.karar = 'pass'),
           false)
    from (
      select distinct on (k.denetci_model) k.denetci_model, k.denetci_aile, k.karar
        from public.kelime_denetim_kayitlari k
       where k.hedef_tur = p_tur and k.hedef_id = p_id
         and (p_sonra is null or k.created_at >= p_sonra)
       order by k.denetci_model, k.created_at desc, (k.karar = 'pass')
    ) t;
$fn$;
