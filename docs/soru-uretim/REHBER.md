# Hupo Soru Üretim Rehberi (v1) — V3 temelli, Hupo'ya uyarlanmış

Kaynak: `kaynak/SORU_UZMANI_REHBER_V3_orijinal.md` (Soru Uzmanı Blueprint v2 paketi) + pilot dersleri (Türkçe 4. sınıf, 2026-10-18).
Karar sahibi: kullanıcı. Bu belge `PLAN.md`'nin üretim kurallarını tanımlar; çelişkide bu belge geçerlidir.

## 1. Neyi aynen aldık (V3'ten)
- **Blueprint-first:** önce kazanım ve ölçülecek beceri, sonra soru. Sınav cümlesini taklit yok.
- **Üç örneklem ayrı tutulur:** resmî sınav (İOKBS/LGS) → MEB çalışma/kazanım testleri → yayınevi. Körlemesine birleştirilmez. Yayınevi yalnızca çeşitlilik ve hata örüntüsü içindir.
- **Analist / Yazar ayrımı (A8):** Analist kaynağı görür ve yalnızca özellik + hata mekanizması + `stil_kaniti` üretir. Yazar kaynağı **hiç görmez**; yalnızca hücre, soyut hata mekanizması ve bizim yazdığımız örnekleri görür.
- **Özellik ontolojisi:** çok boyutlu etiket (baskın yapı + yardımcı etiketler, olumsuzluk ayrı boole, bağlam işlevi, çeldirici hata mekanizması). Zorluk `model_tahmini` / `uzman_yargisi` / `ogrenci_verisi` ayrı alanlarda.
- **Bağlam gerekliliği testi (§8):** bağlam çıkarılınca soru aynı çözülüyorsa bağlam süstür, soru yeniden yazılır.
- **Çeldirici = makul yanlış akıl yürütme.** Aynı kelime/sayı değil, aynı hata mekanizmasının yeni örneği. Her çeldiriciye kısa "bu neden çekici" notu.
- **7 kapı + hücre yöntemi:** önce 1–5 madde, kapı, sonra batch. Tek çağrıda 100 madde yok.
- **Ağırlık formülü (A7):** `üretim_ağırlığı = α·resmî_sınav + β·güncel_müfredat + γ·öğrenci_ihtiyacı`. Başlangıç: α=0.4, β=0.6, γ=0 (öğrenci verisi yok). MEB standardı değildir; sürümlenir.
- **Dürüst durum etiketleri:** otomatik etiket "tahmin"dir; gerçekleşmeyen kontrol "yapıldı" yazılmaz.
- **Asgari çocuk verisi** (anonim id, ad/cinsiyet yok), araştırma ve pazarlama veri akışı ayrı.

## 2. Değiştirdiklerimiz (Hupo'ya uyarlama)
| V3 | Hupo |
|---|---|
| Kapsam 2–7. sınıf | **1–8. sınıf**, öncelik 4→5 geçiş; 5. sınıf İOKBS en yakın resmî kaynak |
| İnsan inceleme kuyruğu | İnsan havuzu yok (kullanıcı kararı). **Üç aşamalı yapay zekâ denetimi:** Denetçi A + Denetçi B (farklı model, kör) + uyuşmazlıkta **Hakem C** (üçüncü model). Hakem de kararsızsa soru `BEKLET`te kalır, yayınlanmaz |
| `YAYINA_HAZIR` için insan onayı | İki bağımsız AI onayı + otomatik kapılar + hakem gerekirse. Tartışmalı alanlar (Din Kültürü yorum soruları, kültürel hassasiyet) varsayılan `BEKLET`; **Din Kültürü'nde bu alan en başta ihtiyatlıdır** |
| Üründe etiket önerisi yok | Öğrenci/veli arayüzünde "yapay zekâ üretimi" etiketi **gösterilmez** (kullanıcı kararı); `kaynak_turu` yalnızca iç kayıt |
| Şık 2–5 | Standart **4 şık** (A–D). 1–3. sınıf için 3 şık yalnızca bilinçli istisna |
| Hedef zorluk 35/45/20 | Başlangıç **30/50/20** (ürün kararı; 1=kolay, 3=zor) |
| `kazanim_kodu` boş olabilir | Güncel MEB programından doğrulanmış kod **zorunlu** (pilotta `kazanim_4_turkce.json`) |

## 3. Çıkardıklarımız / kullanmadıklarımız
- `altin_ornekler.json` **few-shot olarak kullanılmaz:** ALTIN_5_TUR_001 çeldiricisinde "her zaman" var (kendi kuralına aykırı); ALTIN_3_HAY_001'de çeldiriciler saçma ve doğru şık belli; ikisinde kazanım kodu yok. Kendi altın örneklerimizi yazarız.
- `zorluk_tahmini` ve `soru_tipi` alanları **yön göstericidir**: kural tabanlı zayıf etiket (resmî Türkçe'de zorluk 1/2/3 = 75/80/5). Dağılımın kendisi hedef olarak kopyalanmaz.
- `kod/kalite_kapilari.py` olduğu gibi çalıştırılmaz (aşağıda uyarlamalar).
- PDF/PNG teslimatları ve ham 1,8 MB parmak izi dosyası repoya alınmadı; paketten okunur.

## 4. Pilottan eklenen kurallar (30 sorunun 20'si düzeltme gerektirdi)
1. **İpucu cevabı ya da yerini vermez.** (8 soruda ihlal.)
2. **Doğru şık en uzun/yapısal farklı olamaz;** şık uzunlukları ±%30.
3. **İçerik bilgisi doğrulanır** (örn. "mavi balina en büyük *hayvan*dır"). Metne gerçek dünya bilgisi koyarken yanlış genelleme yok.
4. **Soru kökü anlamlı ve tanım hatasız.** Konu dışı (Fen bilgisi ölçen Türkçe sorusu) yok.
5. **Yazım/noktalama sorularında TDK kesin kural;** kazanımda olmayan işaret/konu kullanılmaz (noktalı virgül gibi). Konuşma çizgisi karakteri doğru kullanılır.
6. **Zorluk etiketi iddialı konmaz;** emin değilsen bir alt düzey yaz.
7. **Denetçi kör olmak zorunda:** pilotta Opus denetçisi cevap anahtarını görmüştü; bu bağımsız çözüm sayılmaz. Turda A ve B anahtarsız çözer, gerekçe yazar; anahtar sonra açılır.

## 5. Hupo madde şeması (V3 + pilot)
Zorunlu: `id, sinif, ders, mufredat_surum, kazanim_kodu, surec_bileseni, konu, alt_konu, soru_metni, siklar{A-D}, dogru_sik, ipucu, cozum_adimlari, celdirici_gerekce{harf:neden_cekici}, zorluk, zorluk_kaynagi("model_tahmini"), soru_tipi, olumsuzluk(bool), baglam_islevi("gerekli|ipucu|suslu"), gorsel_gerekli(bool), kaynak_turu("ozgun_ai"), blueprint_surum, denetim{ajan_a,ajan_b,hakem}, durum`.
Durumlar: `RED → BEKLET → KONTROL_ADAYI → YAYINA_HAZIR`. `YAYINA_HAZIR` = şema + hesap + benzerlik + A onay + B onay (+ hakem). Görselli soru: gerçek görsel ve cihaz render kontrolü olmadan yayınlanmaz.

## 6. Kapı uyarlamaları (`kalite_kapilari.py` benzeri kendi betiğimiz için)
- Çözüm son satırı `Doğru cevap X seçeneğidir.` zorunluluğu **kaldırılır**; bizim şemada `cozum_adimlari` serbest.
- Olumsuz kök kontrolü Markdown `**` yerine **BÜYÜK HARF** vurgusunu kabul eder; `'NOT'` kontrolü kaldırılır.
- Benzerlik eşiği sıkılaştırılır: `ortak_6gram ≥ 2` ya da `jaccard ≥ 0.15` → `BEKLET` (V3: 0,26). Yalnız n-gram yakalar, paraphrase yakalamaz; yapısal bakış Denetçi B görevidir.
- Kontrol kümesi hash'i paketten (`parmak_izleri_madde.jsonl.gz`) gelir; anahtarlı blake2b kullanıyor, geri çevrilemez.
- Hesap doğrulaması mümkün her sayısal soruda zorunlu (`sayisal_dogrulama`).

## 7. Blueprint kaynak düzeni (güncel)
- **5. sınıf resmî:** `veri/blueprint_meb_sinav.json` (İOKBS 2020–2026, ders başına 160 soru, 640 toplam). Pilotta bizim 140 kayıtlık taslak yerine bu kullanılır. `n=160` olsa da etiketler zayıf; konu kırılımı küçük n'de yön gösterici.
- **4. sınıf:** resmî çoktan seçmeli kaynak yok; kazanım (`kazanim_4_turkce.json`) + 5. sınıf İOKBS tarzı aşağı ölçeklenir. Dağılım "yön gösterici" işaretlenir.
- **1–3, 6–8:** veri açığı. 6–7 İOKBS ve 8 LGS (MEB, resmî) önce toplanır; 1–2 için MEB çalışma yaprakları. Veri yokken nicel "resmî dağılım" yazılmaz.
- Hedef ağırlık: `veri/blueprint_hedef_taslak.json` (öneri) — üretim 30/50/20 ile hizalanır.

## 8. Sıradaki işler (öncelik sırası)
1. **Pilot tur 2:** 20 DÜZELT sorusunu §4 kurallarıyla düzelt; **kör** Denetçi A (Haiku→farklı model) + kör Denetçi B (Opus) + gerekirse Hakem C; ölçüm: kapı geçme, uyuşma, düzeltme oranı.
2. **Analist/Yazar köprüsü:** 5. sınıf İOKBS Türkçe'den (Downloads'taki 4–5 PDF + paket indeksi) `stil_kaniti.json` üret; Yazar yalnızca bunu görür.
3. Kendi altın örneklerimiz (hücre başı 2–3), sonra batch.
4. Kapı betiğini yaz (`tools/soru-uretim/`), pilot sorular üzerinde çalıştır.
5. `questions` tablosu için provenance migration (ayrı onayla).

## 9. Bilinen riskler
- İnsan denetimi olmadan çocuk içeriği: pilotta 20/30 düzeltme gerektirdi, en kritik hatalar (yanlış bilgi, çift doğru cevap) yalnız ikinci, **güçlü** modelin kalite denetiminde yakalandı. Denetçi B bu yüzden en güçlü modeldir; ucuz modele düşürülmez.
- Zorluk etiketleri öğrenci verisi gelene kadar yalnızca tahmindir; ürün içinde "kolay/zor" vaadi verilmez.
- Resmî MEB sorularının kendisi ürüne alınmaz; yalnızca özellikleri kullanılır (V3 ile aynı).

## 10. Yazım ve noktalama kontrol listesi (TDK Yazım Kılavuzu)

Kaynak: TDK Yazım Kılavuzu, yazim.tdk.gov.tr — "Noktalama İşaretleri" (09), "Bazı Kelime ve Eklerin Yazılışı" (03), "Büyük Harflerin Kullanıldığı Yerler" (05), "Birleşik Kelimelerin Yazılışı" (06). Erişim: 2026-10-18. Bu liste yalnızca az bilinen veya sık yanlış yapılan kuralları içerir; soru yazarı ve denetçi soru metni ile şıkları bu maddelere göre tarar.

### 10.1 de/da ve ki: ayrı mı, bitişik mi?
- **Bağlaç "de/da"** ayrı yazılır ve kesmeyle ayrılmaz: "Ayşe de geldi." DOĞRU. "Ayşe’de geldi." YANLIŞ (kılavuz: bağlaç da/de'yi kesmeyle ayırmak yanlıştır).
- **Bulunma eki "-da/-de"** bitişik yazılır: "evde", "okulda". Özel ada geliyorsa kesmeyle: "Ankara’da".
- **Bağlaç "ki"** ayrı yazılır: "Duydum ki yarın…", "Bilmem ki…". Kalıplaşmış olanlar bitişik: belki, çünkü, oysaki, sanki, mademki.
- **Ek "-ki"** bitişik: "ekteki", "bugünkü".

### 10.2 Kesme işareti: az bilinen istisnalar
- Özel ada gelen ek kesmeyle: "Ankara’ya", "Atatürk’ün", "Ayşe’nin".
- **Kurum, kuruluş, kurul, iş yeri adlarına gelen ek KESMESİZ:** "Türk Dil Kurumundan", "Türkiye Büyük Millet Meclisine".
- Sayılara gelen ek kesmeyle: "1985’te", "8’inci madde".
- Kısaltmaya gelen ek kesmeyle: "TDK’nin", "TBMM’de".
- Belirli tarih bildiren ay adına gelen ek kesmeyle: "17 Aralık’a kadar".
- Özel adın sonundaki sert ünsüzün yumuşaması (Ahmet → Ahmedi) soruda kullanılmaz; kural ayrı bilgi gerektirir.

### 10.3 Büyük harf
- **"dünya, güneş, ay"** gezegen ya da gök cismi anlamı dışında küçük harfle başlar. "Dünya’da yaşayan" YANLIŞ, "dünyada yaşayan" DOĞRU (TR4-017 hatası).
- Gün adlarının büyük-küçük harf kuralı bu sayfada açıkça yazılmıyor; kesin kural bulunmadan gün adı yazımını sınayan soru kurulmaz (TR4-015 kararı).
- Cümle başı, özel ad, kurum adı kuralları standarttır; soruda sık hata yerleridir, denetçi kontrol eder.

### 10.4 Noktalama
- **Konuşma çizgisi (—, uzun çizgi):** Satır başına alınan konuşmayı gösterir. Tırnak içinde verilen konuşmada kullanılmaz.
- **Kısa çizgi (–):** Satır sonunda bölme, cümle içi ara söz (iki yanında, bitişik: "-dört inekle birkaç koyun-"), kök ve ek ayırma (al-ış). Konuşma çizgisi yerine kısa çizgi kullanılmaz (TR4-021 hatası).
- **Tırnak içindeki alıntının sonundaki işaret tırnak içinde kalır:** “Gelir misin?” diye sordu.
- **Alıntı ve "dedi":** Kılavuz örneği: "Adana’ya yarın gideceğim, dedi." Alıntıdan sonra virgül, sonra "dedi". Aynı alıntıda iki nokta ile girip "dedi" ile bitirmek kılavuz örneklerinde yer almaz; ikisinden birini seç (TR4-025 hatası, kılavuz örneklerinden çıkarım).
- **Tekrarlı bağlaçlardan önce ve sonra virgül konmaz:** "Hem gider hem ağlar." "Ya bu deveyi gütmeli ya bu diyardan gitmeli."

### 10.5 Soru yazarı için kurallar
1. Yazım kuralını sınayan bir soruda yalnızca bu bölümde açıkça yazılan kuralı kullan. Belirsiz kural (gün adları, sert ünsüz yumuşaması) için soru kurma.
2. Metin ve şıklarda kesme, de/da, ki ve büyük harf yazımını yukarıdaki listeye göre tara. Denetçi B bunu kontrol eder.
3. Çeldirici olarak gerçek yazım hatası kullanılıyorsa, hata kuralı sorunun sınadığı kuralla tutarlı olmalı; başka bir kuralı çelişkiye sokmamalı.
4. Doğru şıkta da kurallı yazım kullan; yazım sınayan soruda doğru cevap kılavuzda kayıtlı yazımdır.

## 11. Matematik kuralları (4. sınıf pilotu öncesi tasarım; sınanacak)
Kaynak: 2026 İlkokul Matematik DÖP (1–4) — `pilot/kazanim_4_matematik.json` (34 kazanım, 4.1–4.4 temaları). Erişim: 2026-10-18.
1. **Sayısal doğrulama zorunlu:** Her işlem ve problem sorusunda `sayisal_dogrulama.ifade` (ör. `"8*12-29"`) ve `beklenen_sonuc` yazılır. Betik ifadeyi hesaplar, şıkla eşleşmezse soru RED.
2. **Tek doğru cevap:** Kesir ve ölçü sorularında eşdeğer ifadeler (ör. 1/2 = 2/4, 1 m = 100 cm) ayrı şık olarak yer almaz.
3. **Birim tutarlılığı:** Verilenler ve istenen aynı birimde ya da dönüşüm kazanımda açıkça gösterilerek sorulur.
4. **Çeldirici kaynakları:** İşlem sırası hatası, birim karıştırma, ara sonucu nihai sanma, basamak değeri karıştırma (ör. 3 ve 300). Yakın ama yanlış sayılar tek bir hata mekanizması üretsin.
5. **Şekil/grafik:** Geometri (4.3) ve veri (4.4) sorularında `gorsel_gerekli` true olur; görsel üretilmeden yayınlanmaz. Pilotta görselli soru yazılmaz, yalnızca metin tanımıyla kurulabilenler seçilir (açı türü, çevre hesabı gibi).
6. **Sayı büyüklüğü:** 4. sınıf en fazla altı basamak (4.1.1). Sayılar bu sınırın içinde olsun.
7. **Kesirlerde** paydaları eşit kesir toplama (4.1.11) ve birim kesir karşılaştırma (4.1.8) gibi açık kazanımlar tercih edilir; karışık sayı işlemleri pilotta yok.

## 12. Kazanım eşleşmesi zorunlu (her ders için)
- Her soru `kazanim_kodu` alanında **mevcut bir kazanım kodu** taşır (`kazanim_<sinif>_<ders>.json` içinde aranır). Kod yoksa soru RED.
- Her soru tek bir kazanımı ölçer. Birden fazla kazanım gerekiyorsa soru yeniden kurulur.
- Kazanım metni ile soru arasındaki ilişki denetçi tarafından kontrol edilir (kod var olması yetmez).
- Kazanım tablosu ders bazında pilottan önce çıkarılır (Türkçe 4 ✓, Matematik 4 ✓).

## 13. Ders pilot sırası
Her ders için 4. sınıfta 20–30 soru, aynı ölçüm: anahtar uyumu, denetim geçme oranı, düzeltme oranı.
1. Türkçe 4 — **kapandı** (28 soru; 2 soru tartışmalı noktalama nedeniyle çıkarıldı: TR4-025, TR4-027)
2. Matematik 4 — **sırada** (tasarım §11)
3. Fen Bilimleri 4 — görsel ağırlıklı; önce deney tanımlı metin sorularıyla başlanır
4. Hayat Bilgisi / Sosyal Bilgiler 4 — kültür ve değer içeriği; denetçi kurallarına ayrıca bakılır
5. İngilizce 4 — dil düzeyi için MEB programı ayrıca doğrulanır
6. Din Kültürü 4 — programla sınırlı, yorum soruları yasak; en son

## 14. Sınıf kademe planı
- **4 sınıf:** kazanım tablosu var; Türkçe kapandı, Matematik sırada.
- **5 sınıf:** İOKBS 2020–2026 (640 soru) resmî veri; tarz referansı. Pilot 4. sınıftan sonra.
- **8 sınıf:** LGS çalışma materyalleri ve kazanım tablosu gerekli; resmî veri yok, önce kazanım tablosu çıkarılır.
- **6–7 sınıf:** İOKBS serileri henüz veri setinde değil; önce toplanır.
- **1–3 sınıf:** Kaynak zayıf. 2. sınıf için resmî kaynak yok. Bu kademeler kendi kazanım tablolarıyla ayrı pilota girer.

## 15. İnsan örneklemi (KARAR BEKLİYOR)
Kullanıcı insan denetçi havuzu olmadığını belirtti. Yapay zekâ denetimi kör noktalar taşıyor (tur 2'de Opus, uzun doğru şıkkı kaçırdı). Öneri: yayına çıkmadan önce her ders-sınıf için rastgele %10 örneklemin bir öğretmen tarafından gözden geçirilmesi. Bu karar kullanıcıya aittir; pilotlar yapay zekâ denetimiyle sürer, yayın kararı insan örneklemine bağlanır.

## 16. Fen Bilimleri kuralları (4. sınıf pilotu; görselsiz kapsam)
Kaynak: 2026 İlkokul Fen DÖP (1–4) — `pilot/kazanim_4_fen.json`. Kapsam kararı: görselli (şekil, tablo, grafik, deney düzeneği resmi) sorular pilota alınmaz; gözlem ve deney sonuçları metinle verilir.
1. **Görselsiz kurgu:** Deney, gözlem ve tablo bilgisi soru metninde yazılı olur; "şekilde gösterilen" ifadesi kullanılmaz.
2. **Tek kavram, tek kazanım:** Bir soru tek fen kavramını (ör. ışık, ısı, besin zinciri) ölçer.
3. **Deney sorularında:** Değiştirilen ve sabit tutulan değişken metinde açıkça yazılır; sonuç verilen gözlemle çelişmez. Gerçekleşmemiş bir sonuç "deney sonucu" diye sunulmaz (REHBER V3 §6).
4. **Bilgi doğruluğu:** Bilimsel bilgi güncel ve kesin olmalı. Tartışmalı ya da yaygın yanlış kanıları ölçülüyorsa çeldirici olarak kullanılır, doğru şık yapılmaz.
5. **Çeldiriciler:** Kavram yanılgıları (ör. "güneş ışığı olmadan bitki büyümez" yerine "bitki toprağa bağlı olduğu için büyür") ve değişken karıştırma.
6. **Zorluk:** Tek adımlı bilgi 1; iki kavram arasında ilişki 2; deney tasarımı ve çıkarım 3.
7. **Dil:** TDK kuralları (§10) geçerli; bilim terimleri Türkçe karşılıklarıyla kullanılır.
8. **Güvenlik:** Çocuk deneyi kurgusunda sıcak su, ateş, asit, iyot gibi kimyasal ya da yanma riski taşıyan madde kullanılmaz; deney yalnızca yetişkin gözetiminde yapılabilecek kurguyla ve ev/okul ortamında güvenli malzemelerle anlatılır. Güvenlik riski görülen soru denetçi raporunda RED sayılır (Fen 4 pilotu: FEN4-014, 70 °C su).

## 17. Sosyal Bilgiler kuralları (4. sınıf pilotu; görselsiz kapsam)
Kaynak: Sosyal Bilgiler DÖP (tymm.meb.gov.tr, 2026-09-02 yüklemesi; içerik 2024 Maarif Modeli temelli) — `pilot/kazanim_4_sosyal.json` (14 kazanım). Kaynak notu: yükleme tarihi ile program sürümü ayrı; MEB telafi belgesine göre 4. sınıfta yeni program 2027–2028'de uygulanacak.
1. **Ölçülebilir olan ölçülür:** "Fikir üretebilme", "yansıtabilme" gibi tutum kazanımları için soru yalnızca bilgi, kavram ve çözümleme düzeyinde kurulur (ör. demokratik karar süreci adımları, bir ürünün üretim-tüketim sırası). Değer yargısı doğru/yanlış sorusu yazılmaz.
2. **Tarih ve kültür:** Atatürk, Millî Mücadele ve Cumhuriyet içerikleri MEB'in ana çizgisine uygun, kesin ve yanlış genelleme içermeyen bilgilerle kurulur. Tarih bilgisi doğrulanabilir olmalı; tarih ve isim yoksa uydurulmaz.
3. **Gündelik hayat bağlamı:** Aile, okul, mahalle ve çevre örnekleri çocuğun deneyimleyebileceği biçimde kurulur. Sosyoekonomik önkabul (ör. belirli meslek veya aile yapısının "doğal" varsayılması) cevabı belirlemez.
4. **Afet, çevre ve dijital güvenlik:** Doğru davranış MEB kılavuzları ve genel kabul görmüş güvenlik kurallarına göre belirlenir; korku yaratan ya da yanlış yönlendiren içerik yazılmaz.
5. **Çeldiriciler:** Yaygın kavram karışıklıkları (hak-sorumluluk, ihtiyaç-istek, üretim-tüketim, kural-örnek) ve tarihsel sıra hataları.
6. **Yasak kalıplar:** Dini ya da siyasi yargı içeren doğru şıklar; "her zaman" ve "hiçbir zaman" kesinlik ifadeleriyle ipucu veren doğru şıklar.
7. **Zorluk:** Tek kavram bilgisi 1; iki kavram arasında ilişki ve çözümleme 2; kronoloji ya da çok adımlı çıkarım 3.

## 18. MEB Bağlam Temelli Çoktan Seçmeli Soru Yazım Kılavuzu (2026-03, resmî) — zorunlu kurallar
Kaynak: MEB, "Türkiye Yüzyılı Maarif Modeli Bağlam Temelli Çoktan Seçmeli Soru Yazım Kılavuzu", Mart 2026 (tymm.meb.gov.tr/upload/kilavuz/coktan-secmeli-soru-yazim-kilavuzu.pdf). Bu bölüm, kılavuzun 2.5.2–2.5.4 hata tablolarından çıkarıldı. Kılavuz, bizim §4 ve §16–17 kurallarıyla uyumludur; çelişkide bu bölüm geçerlidir.
1. **Bağlam:** Ölçülen süreç bileşeni bağlamla birlikte kurulur; bağlam çıkarılırsa soru çözülemiyorsa bağlam zorunludur (§8). Aynı bağlamda birden fazla soru varsa, sorular birbirinin ipucu olmaz (ilk sorunun cevabı ikincinin ön koşulu olamaz).
2. **Kök:** Olumsuzluk tek ve net ("değildir", altı çizili ya da kalın). Çift olumsuzluk ("söylenemez" + "olmadığı") yasak. Öznel kök ("Sizce...") yasak; metne referans verilir ("Metne göre...", "Yazarın vurguladığı...").
3. **Kökte konu anlatımı yok:** Kök yalnızca öğrenciyi yönlendirir; bilgi bağlamda verilir.
4. **Seçenekler:** "Hepsi", "Hiçbiri", "A ve B" gibi kapsayıcı şıklar yasak.
5. **Doğru şık görsel ipucu olamaz:** Doğru şık bariz şekilde daha uzun ya da ayrıntılı olamaz. Tüm şıkların kelime sayısı, satır uzunluğu ve dil yapısı benzer olmalı.
6. **Metin eşleştirme yasak:** Metindeki bir cümle ya da kelime grubu aynen şıklarda geçmez; şıklar anlamca özdeş ama farklı sözcüklerle yazılır.
7. **Çeldiriciler:** Yalnızca genel kültürle elenebilen ya da bariz yanlış şıklar yasak; çeldiriciler öğrencinin konuyu eksik öğrenmesinden ya da yanlış yapılandırmasından doğan yanılgılardan seçilir (§7 ile aynı).
8. **Dilsel sadelik:** Hedef yaşa uygun kelime ve cümle yapısı.
9. **Kapı uygulaması:** kapi.cjs bu kuralların otomatik kontrollerini yapar (hepsi/hiçbiri/A ve B, çift olumsuzluk, kökte "bilgi" uzunluğu, bağlamın kökte bulunması). Anlamca tekrar ve metin eşleştirme denetçi kalitesinde kontrol edilir.
10. **Bağlam öğrencinin gördüğü yerde yazılır (2026-10-25):** Öğrenci yalnız `soru_metni` ve şıkları görür; `dayanak`, `ipucu`, `cozum_adimlari`, açıklama ve geri bildirim görünmez sayılır. Çözüm için gereken sayı, ad, nesne, cümle ve ilişki kökte olur; "Yukarıdaki cümle / Bu modele göre / Aynı kuralla / Parçaya göre" gibi göndermelerin hedefi kökte yazılıdır; `gorsel_gerekli=false` iken görsel öğeler metinle anlatılır. Sınama: kök + şıklar tek başına bir çocuğa verilse cevaplanabilir mi? Panelde "Ali'nin geriye kaç bilyesi kaldı?" gibi 22 bağlamsız 1. sınıf sorusu bu kuralın ihlaliydi (`DUZELTME_PLANI_BAGLAM_2026-10-24.md`). Kapı: `baglam_kokte_yok` (RED), `dayanak_kokte_yok` (uyarı; hedef özel ad/sayı içermeyen gönderme için insan bakar).
