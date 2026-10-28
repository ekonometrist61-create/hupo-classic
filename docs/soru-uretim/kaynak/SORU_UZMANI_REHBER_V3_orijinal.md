# SORU UZMANI
## Blueprint-first + Gerçek Soru Anatomisi: Soru Hazırlama ve Ölçme-Değerlendirme Rehberi
**Sürüm:** 3.0 — 18 Ekim 2026; V2 korunarak genişletildi  
**Kapsam:** 2–7. sınıf / Türkçe, Matematik, Fen Bilimleri, Hayat Bilgisi, Sosyal Bilgiler, İngilizce, Din Kültürü ve Ahlak Bilgisi; varsa ayrı Görsel Akıl Yürütme modu  
**Kullanım:** Hupolingo başta olmak üzere özgün, pedagojik ve denetlenebilir öğrenme-soru havuzu kurmak.

### 1. Bu rehberin temel ilkesi
Önce sorunun ölçmesi gereken kazanım/öğrenme çıktısı ve düşünme eylemi tanımlanır, ardından soru yazılır. **Sınavdaki cümleyi taklit etmek yerine, sınavın ölçtüğü beceriyi özgün bir problemle ölç.** Uzun paragraf, kalabalık şekil veya birbirine benzeyen sayısal değerler tek başına “yeni nesil” soru oluşturmaz. Verilen bağlam, doğru yanıta ulaşmanın ayrılmaz parçası olmalıdır.

Bu yaklaşım, MEB'in 2026'da duyurduğu bağlam temelli soru yazım yaklaşımı ve Türkiye Yüzyılı Maarif Modeli'nin beceri odaklı değerlendirme ilkeleriyle tutarlı bir ürün stratejisidir. Aynı zamanda yayınevlerinin metinlerini kopyalamadan soru türü, konum ve zorluk özelliklerini incelemeye izin veren bir işletme modelidir.

### 2. Kalibrasyon hiyerarşisi: üç farklı örneklem, üç farklı amaç
**A. Resmî sınav örneklemi (en güçlü sınav stili referansı).** İOKBS için 5. sınıf 2020–2026 A kitapçıkları; aynı yöntem ileride 6, 7. sınıf İOKBS ve 8. sınıf LGS ile genişletilir. Bu örneklem *hangi sınavda hangi tür maddeye rastlandığını* ölçer. Ancak geçmiş sınavların konusu, güncel yılın hangi kazanımlarının öğretilmesi gerektiğinin tek kaynağı değildir.

**B. MEB çalışma ve kazanım materyalleri (öğretim stili referansı).** Çalışma soruları, çalışma yaprakları, süreç değerlendirme etkinlikleri, kazanım ve beceri testleri. Çoktan seçmeli olmayanlar üretim modunda ayrı tutulur; resmî sınav blueprint'inin paydasına katılmaz.

**C. Yayınevi soru bankaları (çeşitlilik ve hata örüntüsü).** MEB kaynaklarının ikinci sırasında; çeldirici, soru bağlamı ve güçlük çeşitliliğini görmede yararlı. Bu kaynakların sayıca fazla olması MEB sınav profilini istatistiksel olarak bastıramaz. Kaynağın basım yılı, program dönemi ve lisans durumu ayrı işaretlenir.

Bu üç örneklem için ayrı JSON tutulur: `blueprint_meb_sinav.json`, `blueprint_meb_karma.json`, `blueprint_yayinevi.json`; yalnız karşılaştırma amacıyla `blueprint_tum_kaynaklar.json`. Farklı türleri körlemesine birleştirme.

### 3. Özellik ontolojisi: tek bir “soru tipi” yetmez
Her maddeye birbirinden bağımsız, çok boyutlu etiketler ver:

| Boyut | Örnek değerler | Kontrol |
|---|---|---|
| Öğretim | sınıf, ders, tema, öğrenme çıktısı, konu, alt konu | Güncel MEB programıyla doğrula; otomatik konu etiketi yalnız ipucu |
| Baskın yapı | bilgi-anlama, çıkarım, işlem, paragraf, öncüllü, tablo/grafik, olumsuz kök | Birincil etiket + çoklu yardımcı etiket; olumsuzluk ayrıca boole |
| Zihinsel süreç | hatırlama, anlama, uygulama, çözümleme, değerlendirme, yaratma | Kök uzunluğuna bakarak tek başına kesin hüküm verme |
| Zorluk | 1 kolay, 2 orta, 3 zor | Başlangıç tasarım hedefi; sonradan öğrenci verisiyle kalibre et |
| Bağlam | soyut bilgi, gerçek yaşam, metin, tablo/veri, deney, şekil/görsel | Kullanılan bağlam ölçülen beceri için gerekli mi? |
| Biçim | kök kelime sayısı, şık sayısı, doğru şık konumu | Otomatik sayım; metin ayrıştırma hatası kontrol |
| Çeldirici | yaygın işlem yanlışı, kavram yanılgısı, yüzeysel okuma, aşırı genelleme | Otomatik tespiti tahmin, uzman denetimi zorunlu |
| Kanıt | resmî sınav, MEB çalışma, yayınevi; yıl, PDF sayfası | Her özelliğin kaynağı ve güven düzeyi |

**Önemli:** Baskın soru tipi bir kolaylaştırmadır. Örneğin aynı soru hem “paragraf”, hem “olumsuz kök”, hem “çıkarım” etiketli olabilir. İstatistiksel analizde çoklu etiket oranları toplamı yüzde 100 olmak zorunda değildir; `soru_tipi` baskın etiket dağılımı ise toplam yüzde 100'dür.

### 4. Blueprint nasıl hesaplanır?
1. Her kaynak soruda yalnız **özellikleri** ve gerektiğinde **geri çevrilemeyen hash izlerini** sakla. Eski kaynak metin deposu erişim yetkileriyle sınırlandırılmalı; yeni üretici ajan ona bakmamalıdır.
2. İki katmanlı rapor oluştur: (i) yalnız resmî sınav, (ii) sınıf/dersin resmî çalışma materyali. Yayınevi bir üçüncü rapor olsun.
3. Her hücrede örnek sayısını, etiketleme güvenini, sınıf düzeyini ve müfredat dönemini göster. `n < 50` veya taranmış PDF ayrıştırma riski varsa *dağılımı yön gösterici* olarak işaretle.
4. Kazanım ağırlığını yalnız geçmiş sınav frekansına göre belirleme: güncel öğrenme çıktıları, öğretim süresi, ölçülmesi gereken beceri ve öğrencilerin zorlandığı konular daha önemlidir.
5. Kaynağın 2018–2019 gibi geçmiş programa dayalı olması durumunda eski konuyu güncel kazanım gibi yazma; eşleştirme tablosu ve uzman onayı gerekir.
6. `blueprint_hedef_taslak.json` önerilen ilk tasarım ağırlığıdır; buradaki 35/45/20 kolay/orta/zor hedefi **MEB'in resmî güçlük oranı değildir**, değiştirilebilir ürün kararıdır.

### 5. Sınıf düzeyinde soru yazımı
**2. sınıf:** Çok kısa kök, tek bir zihinsel işlem, çocuğun günlük hayatından sözcükler, baskıdan bağımsız anlaşılır seçenekler. Çıktı veya resim varsa gerçek bir çözüm desteği sağlamalı. Şu an **kaynak yetersizliği** nedeniyle bu sınıf için yüzdesel resmî kalibrasyon yayımlama.

**3. sınıf:** Basit olay/işlem ve somut nesneler; sözcük anlamı, eş/zıt/eşsesli sözcükler, basamak değeri, günlük sorumluluklar, temel gözlem ve basit İngilizce. Resimle cevaplanabilir maddelerde nesne sayısı, açıları, okunurluk önemli. BİLSEM tarzı görsel akıl yürütmeyi normal Matematik veya Türkçe kazanımıymış gibi sınıflama.

**4. sınıf:** Çok adımlılığa geçiş, birincil çıkarım ve anlam ilişkileri, sayısal problemi doğru modelleme. Yaklaşık 16 kelimelik cümle hedefi yazım için yararlı olabilir ama bağlamı bölerek anlamsız kısa cümleler üretme. Yüklenen 4. sınıf çalışma yaprağı içinden otomatik çıkarılabilen çoktan seçmeli örnek sayısı düşük; nicel dağılımlar güvenilir değil.

**5. sınıf:** Sınav tarzında kelime/cümle/paragraf yorumlama, işlem ile muhakemenin birleşimi, fen deney/görsel okuma, sosyal bağlamda hak/sorumluluk ve kültür yorumlama. 2020–2026 İOKBS A kitapçıklarından her ders için 160 soru, dengeli tarihsel referans sağlıyor.

**6. sınıf:** Veriyi karşılaştırma, birden fazla öncül değerlendirme, orantısal düşünme, deneyin değişkenlerini yorumlama; Türkçede paragraf ve anlam ilişkileri. Ders düzeyi değişken; konu bazlı küçük sayılı örnekleri aşırı genelleme.

**7. sınıf:** Birden fazla koşullu mantıksal akıl yürütme, grafik/veri okuma, çok adımlı problem, metnin dolaylı anlamını çözme. Zor soru, gereksiz uzun soru demek değildir. İOKBS 7. sınıf kitapçıkları sisteme eklendikten sonra resmî sınav/çalışma ayrımı yeniden hesaplanmalıdır.

### 6. Ders düzeyinde madde kuralları
**Türkçe:** Öğrenme çıktısını seç: sözcükte anlam, cümlede anlam, metinden çıkarım, ana düşünce, metin yapısı, yazım/noktalama. Metnin her ayrıntısını soru köküne yığma. Paragraf 3–5 cümle olabilir, fakat hedeflenen beceriye göre uzunluğu ayarla. Olumsuz kökte “değildir/yoktur/çıkarılamaz” gibi kritik ifadeyi kalınlaştır; çift olumsuz kullanma. Çeldiricileri paragraftaki *yakın ama desteklenmeyen* çıkarımlardan üret. Her çeldiriciye “bu yanlış neden çekici?” açıklaması yaz.

**Matematik:** Önce denklemi/işlemi kodda kur, sonra problem bağlamını yaz. “İşlem doğru ama bağlama uygun olmayan” yanlış seçeneği ile “yanlış işlem” çeldiricisini ayır. Sayıları rastgele değiştirerek kaynak soruyu kopyalama. Ölçü birimlerini ve verilenleri açık tut. Tek doğru şık için matematiksel aralık/yuvarlama/yorum olasılıklarını kontrol et. Grafik veya şekil şartsa erişilebilir özgün çizim iste ve iki kez kontrol et.

**Fen Bilimleri:** Kavram-yasa ezberi yerine uygun olduğunda hipotez, deney tasarımı, kontrol değişkeni, gözlem ve kanıt yorumu kullan. Gerçekte gerçekleşmeyen gözlemi kaynak göstermeden “deney sonucu” diye sunma. Görsel/kroki ölçeğini gerektiği yerde belirt; bilgi görselde bulunuyorsa yalnız metinle soruyu çözebilecek hale getirme.

**Sosyal Bilgiler ve Hayat Bilgisi:** Gündelik yaşamda haklar, sorumluluklar, karar verme, toplumsal yaşam, kültürel miras ve çevre bilinci. Düşünceyi değil programda tanımlanan bilgiyi/beceriyi ölç; kültürel veya sosyoekonomik önkabullerin cevabı belirlemesini engelle.

**İngilizce:** Tek kazanımı ölç; kısa iletişim bağlamları, sınıf düzeyinde kelime ve görsel eşleşmesi, gereksiz dilbilgisi yükü olmadan kullanım. Şıkların dilsel biçimleri anahtarı ele vermesin. Dil düzeyi MEB programına göre doğrulanmalı.

**Din Kültürü ve Ahlak Bilgisi:** Programın öğrenme çıktılarıyla sınırlı; kavramsal doğruluk, yaşa uygun dil ve farklılıklara saygı esastır. Bir dinî/ahlaki yargıyı yanlış bağlama taşıma; tartışmalı ifadelerde alan uzmanı incelemesi zorunludur.

### 7. Çeldirici tasarımı
Yanlış seçenekler *makul ama hatalı düşünme yollarını* temsil etsin: eksik bilgiyle karar, grafiğin eksenini yanlış okuma, işlem sırasını değiştirme, birimi karıştırma, metindeki yan bilgiyi ana fikir sanma, deneyde değişkenleri karıştırma. Tümü benzer dil uzunluğu ve dilbilgisel yapıda olsun. “Kesinlikle”, “her zaman” gibi güçlü sözcüklerle anahtara ipucu verme. “Hepsi/hiçbiri” seçeneklerine otomatik bağımlılık oluşturma. Kaynak sorunun çeldirici metnini taklit etme.

### 8. “Bağlam gerekliliği testi”
Sorudan bağlamı çıkarınca öğrenci aynı bilgiyle aynı yanıtı veriyorsa, bağlam büyük olasılıkla yalnız süslemedir. Bağlamın en az bir sayısal verisi, ilişkisi, deneysel gözlemi veya metin ipucu çözüm için zorunlu olmalıdır. Yaşa uygunluk “kolay sözcük” ile sınırlı değildir; öğrencinin deneyimleyebileceği sosyal bağlamları seçmeyi de içerir.

### 9. Soru üretimi: hücre yöntemi
Hücre anahtarı: `müfredat_sürümü × sınıf × ders × öğrenme çıktısı × soru tipi × bilişsel düzey × zorluk × bağlam × sınav modu`. Çok nadir hücreleri yok etmek yerine “uzman tasarım” olarak örnekle. Tek bir çağrıda 100 madde yazdırma: önce 1–5 özgün madde, kapı denetimi, sonra batch. Yeni soruda kaynak `sayfa` veya `birebir` alanı kullanılmaz; `kaynak_turu=ozgun_uretim` gerekir.

### 10. Yedi otomatik kapı + çift bağımsız uzman
- **Kapı 1 — Şema:** bütün alanlar, seçenek harfleri, 2–5 şık, yinelenmeyen metin, anahtar-çözüm tutarlılığı.
- **Kapı 2 — Tek doğru:** bağımsız çözüm sonucu; her yanlış şıkkın neden yanlış olduğu denetlenir.
- **Kapı 3 — Sayısal doğrulama:** mümkün olan sorularda hesap makinesi/kod; zaman, ölçü, yuvarlama ve eşdeğer ifade kontrolleri.
- **Kapı 4 — Kör çözüm:** doğru şık görünmeyen bağımsız çözüm oturumu. Üretici modelin kendi verdiği anahtara bakarak çözmesi *kör çözüm değildir*.
- **Kapı 5 — Özgünlük:** 6-gram özet hash eşleşmeleri + yeterli durumlarda semantik/yapısal benzerlik incelemesi. Tam olarak aynı n-gramın yokluğu mutlak telif garantisi değildir. Ortak müfredat terimleri yanlış pozitif oluşturabilir.
- **Kapı 6 — Öğrenme/ürün:** kazanım, gelişim dönemi, anlam açıklığı, çocuk güvenliği, uygunsuz önkabul, görsel erişilebilirlik.
- **Kapı 7 — Kalibrasyon:** model tahmini güçlük **geçici**; gerçek öğrenci doğru yanıtı, yanıt süresi ve madde ayırt ediciliğiyle güncellenir.
- **İki bağımsız yapay zekâ ajanı:** Ajan A (müfredat/alan doğruluğu) ve Ajan B (ölçme/pedagoji/çeldirici). Her biri cevap anahtarını görmeden çözer; görüşler ayrı oturumlarda oluşur. Anahtar veya gerekçe uyuşmazlığında insan denetimi. Bu pakette ajan yönergeleri **hazır**, fakat dış model çalıştırılması **henüz gerçekleşmedi**.

### 11. Yayına çıkış kararları
`RED`: şema, doğruluk, telif benzerliği, birden çok doğru veya bilimsel hata.  
`INSAN_INCELEMESI`: iki ajanın uyuşmaması, belirsiz görsel/kazanım, küçük örneklem, değer ve kültür hassasiyeti.  
`KONTROL_ADAYI`: otomatik kontroller başarılı ama bağımsız iki ajan veya insan onayı bekliyor.  
`YAYINA_HAZIR`: doğrulanmış müfredat ve kazanım, özgünlük/telif kontrolü, en az iki bağımsız ajan ve gerekli insan onayı tamam.

Üretilmiş sorular uygulamaya girmeden önce en az bir kez son render (mobil/web) ve font/şık taşması kontrolünden geçmeli. `gorsel_gerekli=true` olan sorunun gerçek görsel dosyası, resim alt metni ve cihaz boyutundaki görünümü doğrulanmadan yayına alınmaz.

### 12. Uygulama verisiyle kendini geliştiren sistem
İlk deneme ve tekrar çözümlerini ayır. Gerçek güçlük için `p` (ilk denemede doğru yanıt oranı), ayırt edicilik için düzeltilmiş madde-toplam ilişkisi, çeldirici için şık seçilme oranı ve güven aralığı hesapla. Yanıt sayısı yetersizse etiketi sabit tut. Bir öğrenci o gün zorlanıyorsa rastgele zor soru yığmak yerine ipucu, basamaklı uygulama, hatırlama ve ertelenmiş tekrar sun. Uygulama sürümü, konu düzeyi, öğrenme modu ve yayın versiyonu kırılımları tut.

Bu verilerin saklanması çocukların kişisel verilerine özen gösterilerek yapılmalı; ad/cinsiyet/kamera gibi ölçme için gerekmeyen bilgileri maddede tutma. Araştırma ve pazarlama veri akışını ayır; veli panelinde hatalı “kesin başarı” ifadeleri değil, açıklanabilir kazanım/konu gelişimi göster.

### 13. Nicel sonuçları yorumlama
2020–2026 5. sınıf İOKBS'de toplam 640 soru, dört derste 160'ar soru ölçüldü. 2020–2023 her yıl ders başına 25, 2024–2026 her yıl 20 soru vardır. `analiz/KALIBRASYON_RAPORU.md` sınıf/ders dağılımlarını ve hangi sınıflarda veri açığı olduğunu gösterir. “Tahmini zorluk” metin uzunluğu ve anahtar sözcüklere dayanan zayıf bir vekildir; bu nedenle sınavların gerçek psikometrik zorluk sıralamasını temsil etmez.

### 14. Kapsam ve telif sınırı
Bu dokümanlar, kaynak eserleri yayımlamak için değil, soru özelliklerinden hareketle özgün ürün tasarlamak içindir. Önceki SQLite sorular ve şıklar içermektedir; yeni özellik veritabanı bunları tekrarlamaz. Üçüncü kişi sorularını Hupolingo'ya yükleme; telif izni verildiğinde dahi lisans kapsamını kaydet. Görsel kaynaklar, uzun okuma parçaları ve marka unsurları için ayrıca hak denetimi uygula.

### 15. Yeni PDF geldiğinde
Yeni PDF -> SHA256 ve yayınevi/yıl/kitapçık/sınıf doğrulaması -> metin blok ayrımı veya resim işareti -> yalnız özellikler -> cevap anahtarı ve sayfa doğrulaması -> kaynak ağırlığı -> mevcut blueprint ile değişim raporu -> yeni sürüm. Eski raporu silme. `n` değişimini yaz; güven aralığı olmadan küçük farkları trend sayma. Sınıf-ders örtüşmeyen veri kaynaklarını birleştirme.

**Ekler:** `veri/` (JSON, SQLite, hash izleri); `ajanlar/` (üç ajan talimatı ve hücre üretim promptu); `kod/` (yeniden çalıştırılabilir etiketleme ve kalite kapıları); `ornekler/` (tamamı bu çalışma için özgün yazılmış taslak sorular, henüz iki ajan onaysız); `analiz/` (dağılımlar, kaynak eksikleri, QA logları).


---

# EK A — GERÇEK SORU ANATOMİSİ VE SINAV TARZI KALİBRASYONU (V3)

## A1. Neden V2 tek başına yetmiyordu?
V2'deki konu/tip/zorluk oranları soru **biçimini** kabaca belirler; sorunun kurduğu *akıl yürütme tuzağı*, doğru yanıta götüren kanıt yolu, çeldiricinin yanlış düşünceyle ilişkisi, yönerge türü ve bağlamın çözümdeki işlevi büyük oranda dışarıda kalır. Özellikle `soru_tipi` tek baskın etiket olarak çıkarılmışsa `paragraf + olumsuz kök + çıkarım + öncül` aynı soruda birlikte bulunduğunda bilgi kaybı oluşur. Uzunluk, Bloom düzeyi ve zorluk mevcut V2 verisinde büyük ölçüde sezgisel/kurala dayalıdır; bu sonuçlara dayanarak sınavın gerçek güçlük dağılımı kesinleştirilemez.

**Yeni zorunlu iş:** Her sınıf/ders için kaynak soruların *gerçek sayfalarına dönülerek* tabakalı örneklemde detaylı nitel inceleme. V2'nin 640 resmî 5. sınıf İOKBS sorusunda sayısal/otomatik etiketleme vardır; **640 sorunun tamamı, aşağıdaki insan/çok-modlu madde-anatomisi kodlamasından geçmiş değildir**. Dürüst veri statüsü buna göre tutulmalıdır.

## A2. Kaynak hiyerarşisi ve müfredat uyarlama
1. **MEB gerçek sınavı:** İOKBS'nin ilgili sınıfı ve yılı; sınav modundaki biçim ve gerçek yaygınlık dağılımı için birincil kanıt. Başka sınıfın LGS soruları üst sınır/ilham olabilir, hedef sınıf dağılımının yerine geçmez.
2. **MEB kazanım ve çalışma soruları:** Öğrenme çıktısı, bilişsel çeşitlilik, sınıfa uygunluk ve konu ilerleyişi için birincil; İOKBS ile aynı havuza koşulsuz katılmaz.
3. **Ticarî yayınevi materyali:** çeldirici ve bağlam çeşitliliği, alternatif soru kurguları ve hata örüntüsü için ikinci kanıt; çok hacimli olmaları oranları belirlememeli.
4. Her kayda *sınav türü, takvim yılı, öğretim programı sürümü, dosya-kaynak kimliği, baskı/PDF sayfası, veri kalitesi* işlenir. Hedef kazanımlar güncel öğretim programından ayrıca doğrulanır; eski sınav oranları zorunlu güncel müfredat kotası değildir.

## A3. Gerçek soru anatomisinin dokuz katmanı
Bu boyutlar kaynak metni kopyalamadan kayıt edilir; insan doğrulaması olmayanlar `tahmin` statüsündedir.

| Boyut | Sorulacak analitik soru | Önerilen alan |
|---|---|---|
| Ölçülen gizil beceri | Öğrenci aslında hangi bilgiyi/işlemi ortaya koymalı? | `olculen_beceri` |
| Kanıt zinciri | Soruyu çözmek için hangi sırada kaç *zorunlu* çıkarım gerekiyor? | `cozum_islem_sayisi`, `kanit_yolu_kodlari` |
| Soru mimarisi | Tek adımlı tanıma mı, durumdan kural bulma mı, öğrencinin hatasını seçme mi, birden çok öncülü birleştirme mi? | `kurgu_arkitipi` |
| Kökün eylemi | Kök ne istiyor: hangisine ulaşılamaz, en uygunu, örnek, çelişki, neden, yorum? | `kok_eylemi`, `olumsuzluk` |
| Bağlamın işlevi | Bağlam vazgeçilmez veri mi, ipucu mu, yoksa süs mü? | `baglam_islevi` |
| Çeldiricinin gerekçesi | Hatalı şık hangi yanlış akıl yürütmeye cazip geliyor? | `celdirici_hata_siniflari` |
| Bilgi/şekil gösterimi | Metin-grafik-tablo-deney ilişkisi çözümde gerçekten gerekli mi? | `temsil_bilesimi`, `gorsel_gerekli` |
| Yük ve zorluk | Okuma yükü, bellek yükü, işlem derinliği ve alan bilgisi ayrı ayrı ne kadar? | `okuma_yuku`, `muhakeme_yuku`, `hesap_yuku` |
| Özgünlük toleransı | Özgün soru kaynakla aynı senaryo/çeldirici sırası/iskeletten mi ilerliyor? | `yapisal_benzerlik_riski` |

**Kural:** `kolay/orta/zor` tek başına yeterli değildir. 100 kelimelik kolay soru ile 20 kelimelik zor soru mümkündür. Bilişsel düzey ile fiil eşleştirmesi otomatik yapılmaz: “bulunuz” fiili uygulama, hatırlama veya çözümleme gerektirebilir.

## A4. Sahadan doğrulanabilen örüntülere *somut*, fakat sınırlı bakış
- **2023 İOKBS 5. sınıf Türkçe, basılı s. 3:** Zıt anlamlı sözcüğü doğrudan eşleştirtmek yerine aday cümlelerdeki kullanım üzerinden tanıma; ayrıca numaralı metin cümlelerinden *koşul* ilişkisinin seçilmesi. Bunlar farklı arketiplerdir: `baglamda_sozcuk_anlami` ve `numarali_cumlede_anlam_iliskisi`. Kaynak: kullanıcının `04171811_5_SINIF_YOKBS.pdf` dosyası, PDF sayfa 3.
- **2024 İOKBS 5. sınıf Türkçe, basılı s. 2:** Tek sözcüğün belirli anlamda kullanımını cümlelerle ayırt etme; metin içinde bulunmayan hikâye unsurunu saptama. Kök eylemleri `anlam_karsilama` ve `yoklugu_saptama`; ikincisi olumsuz kök içerir. Kaynak: `22174119_5_sinif_a_24.pdf`, PDF sayfa 2.
- **2025 İOKBS 5. sınıf Türkçe, basılı s. 3:** Sözcüğün verilen cümledeki anlamına uyan *başka* kullanımı seçme; bir metinde belirtilmeyen hikâye unsurunu belirleme. Bu, 2024'te de görülen soru ailesinin başka senaryoda sürdürülmesidir; *frekans* kanıtı için tüm sorular kodlanmalıdır. Kaynak: `28174038_5_sinif_a_25.pdf`, PDF sayfa 3.
- **2026 İOKBS 5. sınıf Türkçe, basılı s. 2:** Öğretmenin verdiği yönerge, dört öğrencinin cümle ve açıklamalarıyla birlikte sunuluyor; öğrencinin eşleştirme hatası değerlendiriliyor. Arketip `baskasinin_akil_yurutmesini_denetle`; yalnız “sözcükte anlam” etiketi bu sorunun kurgusunu açıklamaz. Kaynak: `5_sinifA_26.pdf`, PDF sayfa 2.

Bu dört belge, soru tasarımı üzerine *nitel kaynak örnekleridir*. Dört örnekten bütün Türkçe dersinin yüzdelik soru tipi veya gerçek zorluk dağılımı çıkarılamaz. Örneklerin asıl soru metni burada tekrarlanmaz.

## A5. Tam külliyatı anlamak için iki aşamalı gözlem
**Aşama 1 — hızlı makine taraması:** bütün sorularda sınıf/ders/konu, kök sözcük sayısı, şık sayısı, olumsuzluk, sayfa, numara, görsel işareti, olası bilişsel/tür; ayrıştırma güvenirliği. Bu aşama *ucuz istatistik* üretir ve V2'de ağırlıklı olarak budur.

**Aşama 2 — soru anatomisi derin denetimi:** her ders/yıl/kazanım/tip/zorluk diliminden rastlantısal ve az görülen arketiplere fazla örnek veren tabakalı seçki oluştur; görselli sorularda sayfa görüntüsünü mutlaka oku. Başlangıç hedefi: veri izin verdiği ölçüde **ders × sınav yılı başına en az 15–20 madde**; 20 soruluk testlerde mümkünse tamamı. İki kodlayıcı aynı soruyu önce bağımsız değerlendirir; uyuşma oranını raporla, ihtilaflıları gözden geçir. Tüm resmî 5. sınıf 640 sorunun anatomisi kodlanırsa doğrudan tam sayım elde edilir. Bu hedefler gerçekleşmiş sonuç olarak gösterilmez.

**Denetçi soruları:** Bu sorunun püf noktası nedir? Öğrenci hangi yanlış yolu kullanır? Şıklar eşit derecede makul mü? Kısa yoldan ipucu var mı? Bağlam çıkarılırsa soru çözülebilir mi? Metindeki hangi bilgi gereksiz? Gerçek görsel olmadan karar verilemez mi? Sorunun güçlüğü konu bilgisi mi, okuma yükü mü, muhakeme zinciri mi?

## A6. Çeldirici atlası: gerçekte rastlanan hatalardan özgün tasarım
Şu *hipotez sınıfları* her kaynak için gözlemle doğrulanarak ya korunur ya revize edilir:
- Metinden çıkarım: `metinde_gecen_ama_sorunun_cevabi_olmayan`, `asamali_cikarimi_yarida_kesme`, `olumsuz_koku_pozitif_okuma`.
- Matematik: `toplama_yerine_carpma`, `birimi_donusturmeme`, `ara_sonucu_nihai_sonuc_sanma`, `oran_bilesenlerini_tersleme`, `sirayi_karistirma`.
- Fen: `neden_sonuc_yonunu_tersleme`, `degiskenleri_karistirma`, `tek_veriyi_asiri_genelleme`, `gorunen_sekli_gercek_olcek_sanma`.
- Sosyal: `kural_ile_ornegi_karistirma`, `tarihsel_sureci_siralamama`, `hak_ile_sorumlulugu_karistirma`.
- İngilizce: `yalniz_anahtar_sozcuge_bakma`, `iletisim_niyetini_yanlis_okuma`.

Bunlar MEB'in resmî çeldirici sınıfları diye sunulmaz; Soru Uzmanı'nın doğrulaması gereken *araştırma etiketleridir*. Kaynak soruda her yanlış şık için kısa bir mantık notu çıkar; yeni özgün soruda **aynı kelimeyi/sayıyı/cümleyi değil aynı hata mekanizmasının yeni bir örneğini** kur.

## A7. Gerçek dağılımları koruyan blueprint
Her sınıf/ders/kaynak türü/yıl için frekans tablosunda `n`, tespit yöntemi, gözlem güvenirliği, güven aralığı, kayıp görsel oranı ve program dönemi bulunmalı. **Sınav gerçekliği katmanı** ile **ürün öğrenme hedefi katmanı** ayrıdır:

`Onerilen_Uretim_Agirligi = alpha × Resmi_Sinav_Gozlemi + beta × Guncel_Mufredat_Hedefi + gamma × Ogrenci_Ihtiyaci`.

`alpha + beta + gamma = 1`; katsayılar uygulama amacına göre açıkça kaydedilir. Örnek: sınav simülasyonunda `alpha` yüksek; eksik öğrenmeyi tamamlama oyununda `gamma` yüksek. Öğrenci verisi yoksa `gamma` için sıfır veya açık etiketli geçici varsayım kullan. Bu denklem **MEB ölçme standardı değildir**; sürümlenebilir ürün kararıdır.

Kritik düzeltme: Mevcut V2'nin `35/45/20` dağılımı, **saha ölçümü olmayan bir taslak üretim hedefidir**. Öğrenci yanıt istatistiği olmadan “MEB sınavlarının güçlük dağılımı böyledir” denmez. Saha zorluğu için sınavı çözen öğrenci örneklemi ve madde güçlük/ayırt edicilik analizi gerekir.

## A8. Gerçek soru görmeden yeni soru üretme tuzağını önleme
Soru üretim sistemi iki güvenlik alanına bölünür:
1. **Analist (kaynağı görür):** PDF sayfası, gerektiğinde cevap anahtarı ve görseller üzerinden soru anatomisi öğrenir. Metni üreticiye aktarmaz; etiket, yapısal çözüm yolu, çeldirici mekanizması ve kaynak kanıtı üretir.
2. **Yazar (kaynağı görmez):** yalnız hücre blueprint'i, soyut hata mekanizması ve **bizim yazdığımız lisanslı/özgün örnekler** üzerinden bütünüyle yeni durum, sayılar, nesneler, aktörler, metin ve şıklar oluşturur.

İki alan arasındaki köprü `stil_kaniti.json` dosyasıdır: `oruntu_id`, `oruntu_aciklamasi`, `ornek_sayisi`, `kaynak_ailesi`, `donem`, `guven`, `hata_mekanizmasi`, `yasak_kopyalama_notu`. Sorunun birebir metni, yayınevi görseli, benzersiz anlatı örgüsü veya seçenek dizilişi köprüye girmez.

## A9. Kaynak anlama sınavı: üretimden önce ajan kendini kanıtlar
Her sınıf-ders modülüne geçmeden önce Soru Uzmanı:
1. 10–20 kaynak maddelik *ayrılmış değerlendirme örneklemini* yanlış şıkların neden çekici olduğunu da açıklayarak kodlar.
2. Kodlamasını ikinci bağımsız denetçiyle karşılaştırır; tutarsız etiketler uzman kararıyla düzeltilir.
3. Aynı soru tipini üç farklı özgün bağlamla, kaynak metninden bağımsız yeniden kurar.
4. Yeni soruların çözüm zincirlerini ve en az bir makul öğrenci yanlışını gösterir.
5. Kaynakla **kelime düzeyinde ve yapısal** benzerlik denetimini geçirir.

Bu kapı geçilmeden “MEB tarzını öğrendim”, “güçlüğü kalibre ettim” veya “MEB ile eşdeğer soru ürettim” iddiası kullanılamaz.

## A10. Çift denetim görev ayrımı ve insan masası
**Denetçi 1 — Sınav anatomisti:** Kaynağa bakmadan özgün üretilmiş sorunun hedef blueprint hücresini, kanıt zincirini, soru arketipini ve hatalı şıkların mekanizmasını değerlendirir.

**Denetçi 2 — Alan ve müfredat uzmanı:** Öğrenme çıktısına uyum, bilimsel ve matematiksel kesinlik, tek doğru, dil ve sınıf uygunluğunu sınar.

İki denetçiden biri `BELIRSIZ` veya `RED` verirse insan kuyruğuna gidilir. Üretici ile denetçi aynı yanıtı yeniden üretirse buna iki bağımsız ajan doğrulaması denemez. Gerçek ajan çağrıları gerçekleştiğinde model sürümü, ayrı oturum kimliği, cevap ve karar kaydedilir.

## A11. Sürdürülebilir bilgi birikimi ve sahada geri besleme
- Kaynak inceleme sürümleri ve `oruntu_atlasi` append-only / değişiklik kayıtlı tutulur; yeni PDF, önceki oranları sessizce değiştiremez.
- Sorunun ham metni üretim **blueprint katmanında** saklanmaz; lisans izinli ayrı arşivde yalnız yetkili analist erişebilir. Benzerlik hash'leri için kaynak fingerprint yeterlidir ancak tek başına tam kopya tespiti değildir.
- Hupolingo öğrencilerinin ilk deneme doğru oranı, süre, çeldirici seçimi, ipucu kullanımı, tekrar sonrası gelişimi ayrı tutulur. Madde zorluğu `model_tahmini` / `uzman_yargisi` / `ogrenci_verisi` diye üç ayrı alanda sürümlenir.
- Özellikle çocuk verilerinde asgari veri ilkesi, uygun anonimleştirme/pseudonimleştirme, ebeveyn yetkisi ve saklama süresi denetimi yapılır.

## A12. V3 için somut geçiş işleri ve durumu
| İş | Durum |
|---|---|
| 18 PDF için V2 otomatik metadata / 5. sınıf İOKBS 640 maddelik sınıf-ders indeksi | Mevcut; otomatik ve hataya açık |
| 640 sorunun tamamının tek tek çok-modlu soru anatomisi denetimi | **Henüz yapılmadı** |
| 6–7. sınıf İOKBS tam sınav serileri / 2. sınıf resmî kaynaklar | **Henüz kapsanmadı** |
| Kaynak bazında tüm çeldiricilerin mantık gerekçesi | **Henüz doğrulanmadı** |
| Öğrenci cevap verileriyle gerçek güçlük ve ayırt edicilik | **Veri bekleniyor** |
| Çift bağımsız AI denetçisinin API/ayrı oturumlarda fiilî çalıştırılması | **Henüz yapılmadı** |
| Kaynak anlama sınavı ve özgün soru yazarı kapısı | Bu V3 rehberinde kural ve şema olarak tanımlandı |

**Başarı ölçütü:** Daha çok soru üretmek değil; kaynak soru **mantığını açıklayabilmek**, özgün bir senaryoya taşıyabilmek, şık başına yanlış düşünceyi ispatlayabilmek ve bunu sınıf/ders bazında gerçek sınav dağılımıyla uyumlu şekilde yapabilmektir.
