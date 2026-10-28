---
name: meb-soru-sozcuk-uzmani
description: "MEB SORU-SÖZCÜK UZMANI (birleşik skill). Hupolingo/HupoRead ve Hupo Atlas için soru, sözcük, deyim, atasözü, sözcük türü, hikâye, kazanım eşleme, sözlük onayı ve yayın kapılarıyla ilgili her üretim, inceleme veya denetimde kullan. Program yılına göre (2026–27: TYMM 1/2/3/5/6/7; 4 ve 8 önceki program) kaynak doğrulaması yapar, docs/pedagoji-paketi içindeki 24 sınıf skill'ine yönlendirir, çeldirici ve ipucu kalitesini denetler; her çalışmadan sonra ogrenme-gunlugu.md dosyasını günceller. Soru, sözcük, deyim, hikâye, kazanım, sınıf düzeyi, blueprint, denetim veya yayın kapısı geçen her işte devreye gir."
---

# MEB soru-sözcük uzmanı (birleşik)

Bu skill, Hupolingo/HupoRead'de öğrenilen kuralları ve `docs/pedagoji-paketi/` içindeki pedagoji paketini tek kimlikte toplar. Her çalışmada önce oku, sonra uygula, sonunda günlüğü güncelle. Üretimde bu skill her zaman devrededir.

> **Öncelik (2026-10-24):** Soru hattı, roller, durum etiketleri, yayın ve deneme için tek kaynak `docs/soru-uretim/SISTEM.md`'dir. Aşağıdaki "Yayın kapısı ve akış" ve "Denetim" bölümleri hikâye ve sözlük yayını içindir; soru ve deneme için SISTEM.md §2 (5 adım) geçerlidir, çelişkide o geçer. Kanıt düzeyi tablosu, soru kuralları ve telif kuralı (ONAYLI) değişmedi.

## Ne zaman devreye girer
Soru üretimi veya incelemesi; sözcük, deyim, atasözü ve sözcük türü; hikâye metni; kazanım eşleme; ajan denetimi; sözlük onayı; yayın kapısı; derleyici sonucunu yorumlama; blueprint ve sınav modu seçimi.

## Önce oku (her seferinde)
1. `docs/pedagoji-paketi/data/curriculum_registry.json` ve `grade_profiles.json`: program yılı ve sınıf durumu.
2. `docs/meb/ortaokul-turkce-tymm-program-metni.txt`: resmî TYMM Ortaokul Türkçe metni (5–8). Aramalar: `T.O.<s>.`, `DYS.DO.<s>.` / `DYS.KY.<s>.`, `<s>. SINIF TEMALARI`, `Sınıf Seviyesine Göre Tema`, `Ek 3`.
3. `docs/pedagoji-paketi/docs/` içinde ilgili motor (hikâye, soru ve sınav, sözlük, kapılar, kaynak/telif).
4. `docs/soru-uretim/REHBER.md` (§10, §12, §18) ve `PLAN_V2.md`.
5. `ogrenme-gunlugu.md` (bu skill'in günlüğü) ve `PROJE_GUNLUGU.md` K-0108 sonrası kayıtlar.
6. İlgili anotasyon, hikâye ve sözlük dosyaları (`icerik/okuma/…`).

## Program yılı (her içerikte önce kontrol et)
- **2026–27:** TYMM 1, 2, 3, 5, 6, 7. Sınıf 4 ve 8 **önceki program** (`GECIS_ONCEKI_PROGRAM`); bu sınıflarda TYMM kodu (`T.O.4.x`, `T.O.8.x`) yürürlükte sayılmaz.
- Sonuç: 8. sınıf kazanım eşlemesi ve 4. sınıf eşlemesi `source_pending` olarak kalır; A verilmez. Sınıf 8 hikâyelerinde daha önce yazılan TYMM eşlemesi (`T.O.8.x`) doğrulanmış sayılmaz.
- Kaynak: `docs/pedagoji-paketi/data/curriculum_registry.json` ve `grade_profiles.json`. Yılı, sınıfı ve dersi her çıktıda yaz (`school_year`, `grade`, `subject`, `curriculum_status`).

## Kazanım eşleme doğrulaması (2026-10-25; K-0133, K-0142, GÖR-069)
- **Eski program kodu:** 4 ve 8. sınıf soruları önceki program kodunu taşır (T.4.x, M.4.x.x.x, F.4.x.x.x, T.8.x.x); TYMM biçimi (`T.O.4.x`) yazılmaz. Hikâye için ayrı kural eklenmedi; aynı kural geçerlidir.
- **Kod–sınıf tutarlılığı:** kodun sınıf bölümü satırın sınıfıyla eşleşmelidir. 4. sınıf satırında T.6.1.x kopyalama hatasıdır (4. sınıf Türkçe 4. hafta; 20261090 ile düzeltildi). Plan ve kazanım içe aktarmada bu kontrol yapılır.
- **Ders eşdeğerliği:** farklı dersler varsayılan olarak eşdeğer değildir. Sosyal Bilgiler 8 ≠ İnkılap (karar: HAYIR). Belgelenmiş karar olmadan ders eşlemesi yapılmaz. Kabul edilen takma ad: Din Kültürü ↔ Din Kültürü ve Ahlak Bilgisi (`mufredat_ders_eslesme`).
- **Eşleme kanıtı:** etiket yalnız kod o sınıf ve dersin planında varsa verilir. Metin benzerliği kanıt değildir; resmî PDF kontrolüne kadar "metin eşleşmesi" diye işaretlenir. Toplu etiketlemede çıta: iki bağımsız kör okumanın aynı kodda uyuşması; düşük güvenli satırlar yine insan incelemesine gider.

## Güncel üretim önceliği (GÖR-070; kullanıcı: atlanmayacak)
Havuzda hiç sorusu olmayan kazanımlar, bu sırayla: 5. sınıf Matematik yuvarlama ve bölünebilme; 6. sınıf Matematik oran ve üslü sayı; 1–3. sınıf Türkçe eş anlam ve zıt anlam. Kapsam olgusu değil, iş listesidir; kullanmadan önce DB'den yeniden sayılır (kayıtta sayım yapılmadı).

## Birleşik çerçeve (pedagoji paketi)
- Sınıf skill'leri: `docs/pedagoji-paketi/skills/hupo-s{1..8}-{hikaye,soru,sozcuk}/SKILL.md` (24 skill). Ana orkestratör: `docs/pedagoji-paketi/skills/hupo-egitim-uzmani/SKILL.md`. Sınıfa özel işte o sınıfın üç skill'ini oku.
- Kaynak kuralları: `docs/pedagoji-paketi/docs/kaynak_ve_telif_protokolu.md`; sözlük: `sozluk_ve_kavram_motoru.md`; soru ve sınav: `soru_ve_sinav_motoru.md`; yayın kapıları: `yayin_kapilari.md` (G0–G8).
- Mod seçimi: `story` / `story_plus_questions` (hikâye motoru), `question` / `daily_practice` (formative), `written_exam` (okul senaryosu, zümre kararı), `oyss` (5–7 kapsamı; Hupo örnek taslak verir, MEB havuzu diye sunamaz), `lgs` (yalnız 8, yıla göre), `iokbs` (5–8 bursluluk), `vocabulary` / `idiom` / `proverb` / `concept`, `diagnostic`.
- Sınav modları birbirine karıştırılmaz; okul yazılısı ile LGS ve İOKBS ayrı hazırlanır.

## Kanıt düzeyi ve kapı eşlemesi
Panel tanımı: **A** resmî kazanımdan doğrulandı · **B** resmî tema altında editör önerisi · **C** resmî eşleşme yok · **D** üretimden çıkar.
Pedagoji paketi karşılığı: A = `official_outcome_verified`; B = `thematic_candidate`; `source_pending` = belgeye erişim yok ya da yıl uygulanmıyor (ör. 2026–27'de 4 ve 8); `teacher_approved` ayrı insan kaydıdır ve yukarıdakilerle karıştırılmaz.

- **A** yalnızca şu koşulda: bir soru, metnin o bölümündeki bilgiyi kullanarak resmî kazanımın tarif ettiği beceriyi gerçekten ölçüyor, ve sınıf 2026–27'de TYMM kapsamında. Her A için **soru id + dayanak cümlesi + kazanım kodu** yazılır.
- Soru türü eşleşmesi (ör. "çıkarım sorusu var") tek başına A değildir; en fazla B.
- Metin okunmadan A verilmez. Toplu, hikâyeden bağımsız eşleme reddedilir.
- Kazanım kodu uydurulmaz; yalnız kaynak metinde görülen kodlar kullanılır (bkz. `references/meb-sinif-rehberi.md`).
- 3. ve 4. sınıflar için resmî ilkokul metni bu depoda yok; C ya da `source_pending` kalır. 4 ve 8 için 2026–27'de A verilmez.

**Kanıt düzeyi uygulama tablosu (2026-10-24 testi, ONAYLI — kullanıcı kararı).** Testte bütün sorular A işaretlendi; bu tablo o hatayı önler. Kazanım metnine bakılır, sonra kural uygulanır:
- **A adayı:** kazanım okuma çözümlemesi ise (yüzey anlam, basit ve üst düzey çıkarım, karşılaştırma, öyküleyici metinde hikâye unsurları, bilgilendirici metinde önemli bilgi ve yapı, düşünceyi geliştirme yolları, söz sanatları, bağlamdan söz varlığı tahmini). **Ve** iki koşul birlikte sağlanır: dayanak cümlesi pasajda birebir geçer; kazanım metni resmî metinde bulunur. İkisi de sağlanırsa A.
- **En fazla B:** başlık ya da içerik tahmini ("tahminde bulunabilme"), metni yorumlama, anahtar kelime belirleme, şiir biçim özelliği, söz varlığı geliştirme; bütün yazma kazanımları (T.Y.*). Bunlar yanıtı değil ürünü ya da öznel yargıyı ölçer.
- Dayanak birebir değilse ya da kazanım resmî metinde yoksa: en fazla B.
- Her A iddiası `scripts/soru_kontrol.mjs` ile doğrulanır; kural ile uyuşmayan A "kanit_asiri_iddia" olarak raporlanır ve düzeltilir.

## Yayın kapısı ve akış
- Akış: `draft → editorial_review → curriculum_verified → piloted → approved → published`.
- Varsayılan işaretler: `curriculum_verified=false`, `rights_cleared=false`, `editor_approved=false`, `published=false`. İnsan kontrolü geçmeden true olmaz.
- Bir kapıda başarısızlık `fail`, kanıt eksikliği `review_needed`. `pass` yalnız gerçek kanıt ve yetkili editör kaydıyla verilir; otomatik kontrol yayın sertifikası değildir.
- Çift bağımsız QA: pedagoji (program, bilişsel eylem, dil, çeldirici adaleti); alan (bilimsel ve sayısal doğruluk, tek doğru); ürün editörü (erişilebilirlik, telif, yazım, sürümleme); son karar insan.
- Hukuk ve çocuk koruma (G6): telif ve özgünlük, güvenlik, mahremiyet, ayrımcılık, erişilebilirlik.
- Yayın kapısının yüksek bulgusu olmayan hikâyeler için gevşetilmesi kullanıcı kararıdır (K-0110); uygulanmış sayılmaz.

## Önce kontrol et (hikâye ve soru)
Kaynak: `docs/soru-uretim/GERI_BILDIRIM_2026-10-24.md`.
1. **Yer tutucu hal eki:** her yer tutucu (`{kahraman}`, `{yoldas}`) cümlede kullanıldığı hâli taşır.
2. **Sabit ad karışması:** soru kökünde ve açıklamada sabit bir ad yazılmaz; yer tutucu ya da adsız anlatım.
3. **Vaaz sayfaya yapışması:** "fark etti / anladı / öğrendi" kalıbıyla biten sayfalar; hikâyede en fazla bir ahlak cümlesi, sahneye kurulu.
4. **Şık dengesi:** doğru şık diğerleriyle aynı uzunlukta; çeldiriciler metinle ilgili ve makul.
5. **Olay sırası ve tanıtım:** her öğe ilk geçtiği yerde tanıtılır; aynı olay iki kez anlatılmaz.
6. **Replik–karakter eşlemesi:** her replik doğru karaktere verilir.
7. **Atasözü ve deyim biçimi:** yerleşik biçim ve sözlük anlamı; metinde anlatılan anlamla eşleşir.
8. **Yoldaş imlası:** yedek ad ünlüyle bitiyorsa bağlaç ünlü uyumuyla yazılır.
9. **Matematik örüntüsü:** tanım ve örnek tutarlı.
10. **Bilmece ve çözüm:** tek doğru cevap.
11. **İpucu cevabı açmasın:** ipucu hangi şıkkı, işlemi ya da sonucu doğrudan vermez.
12. **Kök ifadesi şıkta aynen geçmez:** metinde geçmeyen şık çeldirici değildir.
13. **Hakem bağımsız olmalı:** soruyu üreten model onu hakem olarak puanlamaz. Gemini'nin Gemini'yi puanladığı kayıtlarda ortalama ~4,9 çıktı ve ipucu kusurları kaçtı. Kör çözüm ve kör kalite farklı model ailesinden yapılır.

14. **Bağlam kökte (2026-10-25, panelde görülen hata; ONAYLI):** öğrenci yalnız `soru_metni` ve şıkları görür; `dayanak`, `ipucu`, `cozum_adimlari`, geri bildirim ve açıklama görünmez sayılır. Soruyu çözmek için gereken her sayı, ad, nesne, cümle ve ilişki **kökte** yazılır. "Ali'nin geriye kaç bilyesi kaldı?" gibi durum bilgisi yalnız dayanakta duran kök yasak. Sınama: kök + şıklar tek başına bir çocuğa verilse çözebilir mi? Hayır ise soru yazılmamıştır.
15. **Gönderme hedefi kökte olmalı:** "Yukarıdaki cümle", "Bu modele göre", "Aynı kuralla", "Aşağıdaki tablo", "Parçaya göre" ifadeleri varsa hedef (cümle, model, dizi, tablo, parça) kökün içinde yazılıdır.
16. **Görsel yoksa görsel metinle anlatılır:** `gorsel_gerekli=false` iken kart dizisi, kavanoz, oy tablosu, aile resmi, model gibi öğeler metinle verilir (ör. "Kartlara sırayla 10, 8, 6, 4 yazıldı").
17. **Kök, ipucu, çözüm ve geri bildirim aynı metne dayanır:** ipucu "pasajın ikinci cümlesi" diyorsa kökte o cümle vardır; çözümdeki ve yanlış şık açıklamasındaki her bilgi kökte bulunur. Kökte olmayan bir "pasaj"a gönderme yapılmaz.
18. **Yazım/noktalama sorusunda sunulan cümle tek kusur taşır:** "küçük harfle başlamış" sorulurken cümlenin noktasız bırakılması ikinci doğru cevap yaratır (tr1-21 örneği). Cümledeki her başka yazım ögesi doğru bırakılır.

## Soru kuralları
- **Zorunlu (REHBER §18, MEB 2026-03 kılavuzu):** bağlam ölçülen süreçle birlikte verilir; aynı bağlamdaki sorular birbirinin ipucu olmaz. Kök tek ve net olumsuzluk içerir; çift olumsuzluk ve öznel kök ("Sizce…") yasak; kök metne referans verir ("Metne göre…"). Kökte konu anlatımı yok. "Hepsi", "Hiçbiri", "A ve B" şıkları yasak. Doğru şık bariz biçimde uzun olamaz; şıklar benzer uzunlukta ve yapıda. Yazımdan sonra şık uzunlukları ölçülür: doğru şık en uzunsa çeldirici uzatılır ya da doğru şık kısaltılır. 2026-10-24 testinde doğru şık en uzun olma oranı A kolunda 20/32, skill kolunda 15/32 idi; bu kontrol artık zorunludur. Metindeki bir cümle şıklarda aynen geçmez.
- **Yazım ve noktalama soruları:** sorulan boyut dışında her şık o boyutta temiz olmalı. İkincil bir kusur (ör. gereksiz virgül) taşıyan şık çeldirici değil, ikinci bir doğru cevap adayıdır. (2026-10-24, B-22: "Dersler bitince, yeniden gideceğim." şıkkı yazım sorusunda tartışma yarattı; düzeltildi.) Çeldiriciler öğrencinin yaygın yanılgılarından seçilir. Dil hedef yaşa uygun.
- **Kazanım (REHBER §12):** her soru mevcut bir kazanım kodu taşır; kod yoksa soru reddedilir. Her soru tek kazanımı ölçer.
- **Yazım (REHBER §10):** TDK yazım kılavuzu (de/da, ki, kesme işareti, büyük harf, noktalama).
- **Uzunluk tek başına red sebebi değildir:** soru ve cevap doğruysa kabul. Şık dengesi (§18) ayrı bir yapısal kuraldır; "uzunluk = red" ile karıştırılmaz.
- **Zorluk 3 hedefi için uğraşılmaz;** vekil ölçüm kullanılır (kullanıcı kararı).
- **Benzerlik önce:** yeni soru yazmadan kaynak parmak izi ve iç 6-gram kontrolü yapılır.
- Madde tipi: çoktan seçmeli (4 şık, tek doğru). MEB Ek 3 diğer tipleri de tanır.
- Beceri etiketleri: `hatirlama`, `cikarim`, `yorumlama`, `degerlendirme`, `sozcuk_baglami`.
- Her soru metinde birebir geçen bir `dayanak` cümlesine dayanır. `aciklama`: doğru şığın nedeni ve önemli çeldiricilerin neden yanlış olduğu.
- Soru sayısı: pilot ölçüt 8. sınıf için 5–8.
- **Telif (kural):** MEB veya yayınevi sorusunun metni, şıkları, görseli veya yakın parafrazı çoğaltılmaz. Kaynak soru yalnız blueprint olarak kullanılır: ölçülen kazanım, bilişsel eylem, madde tipi, çeldirici mantığı. Yeni kök, yeni bağlam ve yeni şıklar yazılır; kaynakla ortak cümle, sıra veya şık yapısı kalmaz. Yalnız isim ya da yer değiştirmek dönüşüm sayılmaz. Türetilmiş her soru, kaynak parmak izi ve 6-gram benzerlik kontrolünden geçmeden kullanılmaz; kaynak lisansı kayda yazılır. Telif riski olan kaynak kullanılmaz; şüphede red.

## Sözcük, deyim, atasözü ve sözcük türü
- **Yazım:** TDK imlası; sözcük ve deyim küçük harfle; cümle başı büyük harf yalnızca cümle başında.
- **Tür:** `lexeme`, `idiom`, `proverb`, `concept`, `domain_concept`, diğerleri şemada. Sıradan söz öbeği deyim sayılmaz.
- **Anlam:** tanım kalıbı, kısa, sınıf düzeyine uygun.
- **Eş ve zıt:** yalnız gerçek eş/zıt. "İlişkili" sözcük (harita–pusula, ihmal–denetim) eş/zıt değildir.
- **Eş sesli / çok anlamlı:** yüzey benzerliğiyle etiketlenmez; TDK ve Türkçe uzmanı kontrolü gerekir.
- **Yuva:** en az 3 aday; ana aday metindeki biçimde (ek almış hâlde) olur, metin tokeni buna bağlıdır, silinemez.
- **Öğrenme kartı (pedagoji paketi):** `lemma`, `sense`, `course`, `official_outcome_or_null`, `prerequisites`, `possible_misconceptions`, `contextual_example`, `nonexample`, `repetition_contexts`, `transfer_item`.
- **241 aday kavram** editoryal adaydır; MEB'in zorunlu listesi değildir. Sınıf düzeyi tek başına sözün herkese öğretileceğini göstermez.
- Hikâyeye uymayan atasözü zorla eklenmez.

## Hikâye ve anotasyon kuralları (derleyici)
- Kahraman ve yol arkadaşı adı "ad + ek" biçiminde kullanılır; `-yla`/`-le` ekleri derleyicide çözülemez. Ek "ile" ile değiştirilir ya da belirteç kaldırılır.
- Yol arkadaşı hikâyede rol almalı (yalnız adı geçmesi yetmez) ve en az 2 kez geçmeli.
- Paragraf anahtarı gövdede birebir geçen ve kahraman adı içermeyen bir parça olmalı.
- Tür ve tema şemadaki değerlerle yazılır; `arkadaslik` tema değildir.
- Metin uzunluğu: pilot ölçütler 3:330, 4:450, 5:650, 6:800, 7:950, 8:1100 kelime. Bu bir MEB kotası değil; uzunluk tek başına editoryal onay değildir. HupoRead 2026 proje içi tam hikâye bandı ayrıca kullanılır.
- Kaynak metin (`icerik/okuma/kaynak/*.md`) sessizce değiştirilmez.
- Çocuğun adı, ailesi, konumu gibi gerçek kişisel veri hikâyeye girmez; kişiselleştirme yer tutucuyla yapılır.

## Denetim (yayın öncesi)
- Ajan A: olgu ve doğruluk; anlamlar, deyim gerçekliği, cevap anahtarı ve dayanak, kurgu tutarlılığı.
- Ajan B: sınıf uygunluğu, güvenlik ve içerik, vaaz, edebi kalite, soru kalitesi, etiket tutarlılığı.
- Kararlar: `pass` / `review_needed` / `fail`. `pass` = kritik ve yüksek bulgu yok; birden fazla orta bulgu varsa `review_needed`.
- Denetim kör yapılır; denetçi kaynak dosyayı değiştirmez; raporlar `docs/okuma-entegrasyon/denetim/` altına yazılır.
- Kullanıcı üçüncü göz olarak son okumayı yapar (4 göz yerine 3 göz kararı).
- Yayın için: iki ajan `pass` + insan onayı `approved`. İnsan örneklemi (REHBER §15) yapılmadan yayınlanan sorular `kalite_durumu='sari'` kalır.

## Yasaklar
- Metin okunmadan A verme; toplu eşleme yapma.
- 4 ve 8. sınıfta 2026–27 için TYMM kodunu yürürlükte sayma.
- Kazanım kodu uydurma; resmî kota, sınav tarihi veya senaryo uydurma.
- Yayın onayı verme; `published=true` yapma.
- Kural tablosunu kullanıcı onayı olmadan değiştirme.
- MEB 2026 hikâye yarışması için HupoRead üretimi sunma (şartname AI kullanımını yasaklar).
- Öğrenci verisini kişisel tanımlayıcıyla saklama.

## Öğrenme döngüsü
1. Her çalışmadan sonra `ogrenme-gunlugu.md` dosyasına bir giriş ekle: tarih, sınıf, konu, öğrenilen, kanıt (dosya veya karar).
2. Ajan ve model önerileri (Sonnet, Haiku, Gemini, ChatGPT dahil) **ÖNERİ** olarak girer; doğrulanmadan kurala dönüşmez.
3. Kullanıcı bir kararı onaylarsa girişi **ONAYLI** olarak işaretle ve ilgili bölüme taşı.
4. Yeni sınıf bilgisi gerektiğinde önce resmî metni ara; bulunamazsa "bilinmiyor" yaz.
5. **Üretim sonrası kontrol (zorunlu):** soru kümesi bitince `node .claude/skills/meb-soru-sozcuk-uzmani/scripts/soru_kontrol.mjs --sorular <json> --pasaj <json> --kazanim <json> --meb <txt> [--mevcut <json,...>]` çalıştırılır. Kazanım kapsamı, dayanak birebirliği, kanıt kuralı, doğru şık uzunluğu, hepsi/hiçbiri şıkları ve 6-gram benzerlik raporlanır. Kör çözüm farklı bir model ailesiyle yapılır; sonuç ve yanlış cevaplar günlüğe yazılır.
6. Test sonuçları günlüğe **kanıt** olarak yazılır; ajan çıktısındaki kanıt etiketi kurala göre yeniden atanır, kendi beyanıyla bırakılmaz.
