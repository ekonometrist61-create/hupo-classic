# Veli ve Öğretmen Paneli — Ar-Ge ve Plan

Tarih: 2026-10-29 · Durum: **ÖNERİ, onay bekliyor** · Kod yazılmadı, migration yok.
Hazırlayan: Claude (ana oturum). Bağlı belgeler: `docs/hupo-design-growth/PROJECT_CONTEXT.md`, `docs/paketler/ESNEK_PAKET_VE_ODEME_MIMARISI.md`, `PROJE_GUNLUGU.md` K-0009 / GÖR-032 / GÖR-058.

## 1. Özet

Veli panelinin temeli sağlam: 10 sayfa, rıza kapısı, ders ve konu başarısı, tekrar listesi, deneme geçmişi, okuma ve sözcük özetleri çalışıyor. Eksik olan üç şey var:

1. **Kazanım ekseni yok.** Veri `kazanim_kodu` ile müfredat haftasına bağlanabiliyor, ama bu harita yalnız öğrenci tarafında var. Veli "okulda bu hafta ne işleniyor, çocuğum nerede" sorusunu panelden cevaplayamıyor.
2. **"Ne yapmalıyım" cevabı yok.** Panel durumu gösteriyor, ama veliye bu hafta yapacağı somut şeyi söylemiyor.
3. **Zaman ve bütünlük yok.** Dört ürünün (soru, okuma, sözcük, deneme) verisi ayrı kartlarda duruyor. "Başlangıçtan bugüne ne değişti" cevabı ve dönemlik karne yok.

Öğretmen tarafı çok ince: tek RPC (`ogretmen_siniflarim`), yalnız toplu özet, en az 3 öğrenci eşiği. Bireysel veri için hukuki dayanak açık (GÖR-032).

Önerilen yön: veliye **üç soruya cevap veren** bir panel (nerede ilerledi → neye destek gerekiyor → bu hafta ne yapabilirim), öğretmene **kimliksiz sınıf içgörüsü**, ikisinin arasında da **velinin kontrol ettiği paylaşım** köprüsü.

## 2. Bugün ne var (kodda doğrulandı)

| Alan | Durum | Kaynak |
|---|---|---|
| Veli menüsü | Genel Bakış, Dersler, Çocuklarım, Tekrar, Denemeler, Okuma Dünyası, Hedefler, Başarılar, Aktivite, Üyelik (10) | `layout/VeliSidebar.tsx` |
| Genel Bakış | Sonraki adım, Bu hafta (süre, soru, doğru, tekrar), ders başarısı, haftalık çalışma, tekrar konuları, deneme kaydı ve geçmişi, sözcük kartı | `ParentDashboard.tsx`, `BuHaftaOzeti.tsx` |
| Veli veri RPC'leri | `get_student_dashboard`, `get_child_topic_progress`, `get_child_exam_history`, `kelime_veli_ozeti`, `okuma_veli_ozeti`, `veli_sonraki_adim` | `supabase/migrations` |
| Rıza kapısı | Veli rızası yoksa çocuk verisi dönmez | `20261013000000_veli_riza_kapisi.sql` |
| Zaman serisi | `answer_events`: her cevap için doğru/yanlış, süre (ms), zaman. Trend ve kalıcılık bundan hesaplanabilir | `20260920000200_parent_dashboard.sql` |
| Aralıklı tekrar | `user_answers`: `ease_factor`, `tekrar_sayisi`, `aralik_gun`, `sonraki_tekrar_tarihi` | `20260920000000_initial_schema.sql` |
| Kazanım ve müfredat | `questions.kazanim_kodu`, `mufredat_hafta`, `mufredat_takvim`; öğrenci haritası `get_mufredat_haritasi`. Veli/öğretmen karşılığı yok | `20261086000000_mufredat_rpc.sql` |
| Okuma özeti | Beceri bazlı doğruluk, ölçme türü, kavram/atasözü/sözcük durumu (gördü→tanıdı→hatırladı), tema ve değer dağılımı, zorluk seyri, çocuğun puanı | `20261078000000_okuma_dashboard_genislet.sql` |
| Öğretmen | `ogretmen` rolü, `siniflar`, `sinif_uyelikleri` (üyeliği admin kurar), `ogretmen_siniflarim()` yalnız toplu (n≥3), okuma sınıf özeti | `20261003000010`, `20261041000000` |
| Paket kapısı | `paketler.rapor_kapsami` (`ozet`/`modul`/`birlesik`), `paket_modul`, `has_access` | `20261130000000_paket_modul_erisim.sql` |
| Kullanım süresi | `kullanim_olaylari` bilerek kimliksiz; veli/öğretmene gösterilemez. Çalışma süresi `answer_events.sure_ms`'den gelir | `20261066000000_kullanim_suresi.sql` |

Sınırlar:
- 1–4. sınıf denemede puan ve sıra gösterilmez (GÖR-058; `20261138000000`).
- Kazanım doğruluk oranı en az 6 cevapta gösterilir; okuma oranları en az 3 soruda.
- Zorluk etiketleri **tahmini** (PROJE_GUNLUGU, zorluk notu). Arayüzde kesin gibi sunulmaz.

## 3. Ürün envanteri: velinin ve öğretmenin görebileceği kanıt

| Ürün | Ürettiği veri | Veliye gösterilebilir | Öğretmene gösterilebilir (toplu) |
|---|---|---|---|
| Soru bankası + tekrar | doğru/yanlış, süre, zorluk, SM-2 alanları | kazanım durumu, kalıcılık, tekrar yükü, çalışma biçimi | kazanım dağılımı, yaygın yanılgı |
| Müfredat haritası | kazanım kodu, hafta | "okulda bu hafta işlenen" ile çocuğun durumu | sınıfın haftalık kazanım durumu |
| Deneme sınavı | puan %, konu kırılımı, süre | trend, konu kırılımı, ilk ölçümden fark | sınıf deneme dağılımı |
| Okuma Dünyası | 5 beceri, ölçme türü, hedef durumu, okunan kelime, tema/değer | beceri profili, pekişen kavramlar, okuma hacmi | beceri dağılımı, kavram tanıyan/hatırlayan sayısı |
| Kelime Evreni | ustalık, ipucusuz doğru | sözcük dağarcığı gelişimi | sınıf sözcük pekişmesi |
| Görselli sorular | soru türü (geometri vb.) | tür bazlı doğruluk (sonraki sürüm) | — |
| Çarpım şifreleri | akıcılık (mevcut RPC var) | işlem akıcılığı | — |
| Oyunlaştırma | XP, seri, görev, lig, rozet, karakter | "çocuğun macerası" (öğrenme ölçüsü değil) | katılım dağılımı |

## 4. Rakip ve küresel analiz

Güven notu: aşağıdakiler **ürünlerin kendi blog ve yardım sayfalarından** alındı; bir kısmı 2020–2023 tarihli, özellikler değişmiş olabilir. Ekran görüntüleri ve PDF kılavuzları okunamadı. Bağımsız doğrulama yok.

| Ürün | Veli/öğretmen tarafında sundukları | Hupo için çıkarım |
|---|---|---|
| **IXL** | Real-Time Diagnostic (sınıf düzeyi yerleşimi, kişisel eylem planı, aylık yeniden ölçüm önerisi). Trouble Spots (veli çocuğun kaçırdığı soruları görür, birlikte çözmesi önerilir). Score Chart (SmartScore, ustalık yüzdesi). Student Summary: gelişim grafiği, güçlü ve zayıf beceriler, evde kaynaklar (yalnız sınıf lisansında) | Tanı → eylem planı. "Yanlış sorulara birlikte bak". Ölçümü periyodik tekrarla |
| **Prodigy** | Veli panosu: hedefler, son etkinlik, performans gösterdiği sınıf düzeyi, haftalık soru (okul + ev), müfredat ilerlemesi %. Aylık e-posta Rapor Kartı: toplam doğru %, beceri bazlı kırılım, aylık karşılaştırma. Hedef→ödül (velinin koyduğu soru hedefi, oyun içi ödül). Sınıf içi ödevlerin görünürlüğü. Zorlanma tespiti (en üst ücretli katman) | Aylık karne e-postası. Okul–ev görünürlüğü. Ödül döngüsünde dışsal motivasyon riski |
| **Tassomai** (UK) | Pazartesi e-postası, şifresiz tek tık bağlantı, günlük hedef tamamlama, "Ağaç" ile bilgi boşluğu görseli, önerilen kaynaklar. Okul MIS entegrasyonuyla veli kaydı gerekmez. Onay alınan velilere ücretli ek teklifler | Düzenli itme (push) > velinin giriş yapmasına bağımlı pano. Çocuk verisi için şifresiz bağlantıyı **önermiyorum** (KVKK) |
| **Lexia Core5** | Haftalık kullanım hedefi (20–80 dk, aylık yeniden hesaplanır), risk düzeyleri, "Öğretimsel Öncelik" bayrağı, iki kez desteğe düşen öğrenci için "Zorlanıyor" sekmesi, öğretmenin yazdırdığı veli raporu | Öğretmene "kime önce destek" mantığı (bizde yalnız toplu). Hedefin öğrenme sonucuna bağlanması satıcının kendi iddiası; biz süre hedefi koymayız |
| **Khan Academy** | 4 ustalık düzeyi (Denendi, Tanıdık, Yeterli, Ustalaşıldı). Öğretmen Etkinlik/Beceriler/Ustalık raporları. "Ustalaşıldı" ayrı bir testte tam doğru ister | Nitel ustalık merdiveni; sayısal yüzde yerine durum |
| **EBA (MEB)** | Veli e-Devlet ile girer; sınav tarihleri, çalışmalar, ders performansı, kullanım oranı, e-portfolyo | Türkiye'de veli beklentisi: katılım + sınav sonucu |
| **Morpa Kampüs** | Veli üyeliği ücretsiz ve çocuğun üyeliğine bağlı; sınav başarısı ve katılım izleme (2014–2017 haberleri) | Aynı |

**Doğrulanamayanlar:** Duolingo Family'nin veli raporları (resmî kaynak bulunamadı), Khan Academy Kids veli panosu, Squirrel AI veli raporları, Vitamin ve Okulistik veli panelleri (ayrıntı bulunamadı). Bunlar hakkında iddia kurulmadı.

**Araştırma kanıtı (zayıf ama yönlendirici):**
- ASSISTments: veliye otomatik bildirim → veli katılımı ve ödev tamamlama artışı raporlanıyor. Çalışmayı yürütenler sınıfların öğretmenleri, 176 öğrenciyle küçük bir örnek.
- WPI: haftalık otomatik mesaj, rastgele deney (yalnız tez özeti okundu).
- PBS KIDS: veli raporları olumlu algılandı; davranış değişimi ölçülmedi.
- Veli panoları için kontrollü tasarım karşılaştırması bulunamadı. Aşağıdaki tasarım ilkeleri kanıt değil, **sentez ve hipotezdir**.

**Fırsat (kanıt değil, çıkarım):** Taradığım kaynaklarda MEB kazanım koduna bağlı, soru + okuma-anlama becerisi + sözcük + deneme verisini tek veli görünümünde birleştiren bir ürün görmedim. Bu "yoktur" kanıtı değildir ve pazarlamada "tek" veya "ilk" iddiası olarak kullanılamaz.

## 5. Tasarım ilkeleri

1. Her sayfa tek soruya cevap verir: *Nerede ilerledi? Neye destek gerekiyor? Bu hafta ne yapabilirim?* (`hupo-ux-strategy`)
2. **Öğrenme, düzen ve oyun ayrı katmanlar.** XP, süre ve seri öğrenme ölçüsü değildir; panelde bu açıkça yazılır.
3. **Yetersiz veri dürüstçe söylenir.** Eşiğin altında oran yerine "henüz yeterli veri yok" yazılır. Tahmin, puan veya sınav garantisi verilmez.
4. 1–4. sınıfta sayısal yüzde ve sıra yerine **nitel durum** (Gelişiyor, Pekişiyor, Güçlü).
5. Veli dili tanı koymaz: "zorlanıyor" yerine "bu kazanımda destek istiyor". Çocuğu başkalarıyla kıyaslamaz.
6. Her bulgunun yanında bir eylem vardır. Eylemsiz grafik eklenmez.
7. Bildirim sıklığı, sessiz saat ve kapatma tercihi akışın parçasıdır.
8. Öğretmen yalnız kimliksiz toplu veri görür; bireysel veri yalnız velinin açık paylaşımıyla veya hukuk onayıyla.
9. Panel bölümleri paket matrisine bağlanır (kodda sabit değil).

## 6. Gösterge sözlüğü (kritik parametreler)

Eşikler **öneridir**; pilot veriyle kalibre edilmeden kesinleşmez.

### A. Öğrenme
| # | Gösterge | Tanım (öneri) | Kaynak | Durum |
|---|---|---|---|---|
| 1 | Kazanım durumu | Henüz yeterli veri yok (<6 cevap) · Gelişiyor (oran <%60) · Pekişiyor (%60–79, veya ≥%80 ama aralıklı tekrar yok) · Güçlü (≥%80, ≥2 farklı gün, en az 1 aralıklı tekrarda doğru) | `answer_events`, `user_answers`, `questions.kazanim_kodu` | Türetilir |
| 2 | Kalıcılık oranı | Aralıklı tekrarla (`tekrar_sayisi` ≥1) sorulan sorulardan doğru oranı. "Bugün bildi mi, birkaç gün sonra da biliyor mu?" | `user_answers` | Türetilir |
| 3 | İlk denemede doğru oranı (trend) | Daha önce görülmemiş sorulardaki ilk cevap doğruluğu. Tekrar etkisinden arınmış öğrenme göstergesi | `answer_events` | Türetilir |
| 4 | Tekrar yükü | Vadesi gelen soru sayısı + son 7 günde tamamlanan | `user_answers` | Var |
| 5 | Çalışma biçimi | Süre medyanı + doğruluk: çok kısa+yanlış = "acele", çok uzun+yanlış = "zorlanma". Eşik sınıf ve zorluk medyanından | `answer_events.sure_ms` | Türetilir |
| 6 | Zorluk basamağı | Kolay/orta/zor doğru oranı. Etiket "tahmini" | `questions.zorluk` | Var |
| 7 | Okuma becerileri | Hatırlama, çıkarım, yorumlama, değerlendirme, sözcük bağlamı; ölçme türü; ≥3 soru | `okuma_veli_ozeti` | Var |
| 8 | Kavram/sözcük pekişmesi | Gördü → tanıdı → hatırladı → aktardı | `okuma_veli_ozeti`, `kelime_veli_ozeti` | Var |
| 9 | Deneme gelişimi | Puan % trendi, konu kırılımı; 1–4. sınıfta puan/sıra yok | `get_child_exam_history` | Var |
| 10 | Başlangıçtan bugüne | İlk 14 gün ile son 14 gün (#3 üzerinden). "Gözlenen değişim"; nedensel iddia yok | `answer_events` + anlık görüntü | Yeni tablo |

### B. Düzen (öğrenme değildir)
Aktif gün/hafta · günlük çalışma süresi (cevap başına 5 dk üst sınır, mevcut kural) · gün içi çalışma saati (gece geç kullanım uyarısı) · okuma hacmi (okunan kelime, hikâye) · hedef tamamlama.

### C. Oyun ve motivasyon
XP, seviye, seri, rozet, karakter, lig. Başlık altında "Bu bölüm öğrenme ölçüsü değildir."

### D. Destek
- Haftalık destek önerisi: 1 öncelikli kazanım + 10 dakikalık etkinlik + bir konuşma sorusu. Kural tabanlı (kazanım durumu + tekrar vadesi), içerik editoryal ve pedagojiyle denetli.
- Veli eylemi: önerilen etkinliği "yaptık" işaretleme. Velinin katılımını ölçmenin tek yolu bu.

## 7. Hedef veli paneli

Menüyü 10'dan 9'a toplayıp her sayfaya tek amaç veriyorum:

| Sayfa | Amaç | İçerik | Ana eylem |
|---|---|---|---|
| **Genel Bakış** | Bu hafta ne oldu, ne yapmalı | Tek cümle durum · 3 kart (Öğrenme, Düzen, Destek) · "Dikkat" şeridi (2 hafta pasif, tekrar yığılması, gece geç kullanım) | Önerilen etkinliği aç |
| **Öğrenme Haritası** | Okulla hizalı kazanım durumu | Ders → hafta/ünite → kazanım; durum rozeti; "okulda bu hafta işlenen"; "destek isteyenler" filtresi | Bir kazanıma gir |
| **Destek Planı** | Bu hafta evde ne yapılır | 1–3 öneri · "Birlikte bak" (yanlış yapılan sorular + açıklama) · konuşma soruları · etkinlik kartları | "Yaptık" işaretle |
| **Okuma ve Dil** | Okuma ve sözcük gelişimi | Okuma Dünyası + Kelime Evreni birleşik: beceri profili, pekişen kavramlar, okuma hacmi, sevilen temalar | Bir hikâyeyi birlikte konuş |
| **Deneme ve Gelişim** | Sınav hazırlığı | Deneme trendi, konu kırılımı, ilk ölçümden fark, sonraki deneme | Sonraki denemeyi planla |
| **Gelişim Karnesi** | Dönemlik bütün resim | Aylık/dönemlik özet; yazdır/PDF; "öğretmenle paylaş" (süreli, iptal edilebilir bağlantı) | Karneyi paylaş / indir |
| **Çocuğun Macerası** | Motivasyon | Hedefler + Başarılar + Aktivite birleşik; ortak hedef | Hedef koy |
| **Bildirim ve Gizlilik** | Kontrol | Haftalık özet kanalı/gün/saat, sessiz saat, rıza durumu, öğretmen paylaşımı | Tercihi kaydet |
| **Üyelik** | Mevcut | — | — |

Paket kapısı: her bölüm `has_access(modül)` ile, `rapor_kapsami` ile birlikte okunur. **Hangi bölümün hangi pakette olacağı panel matrisinden gelir ve kullanıcı kararıdır** (bkz. D4); ben önermiyorum.

## 8. Hedef öğretmen paneli

Kural: toplu, kimliksiz, hücre bazında k-anonimlik. Mevcut eşik n≥3; hücre bazında n≥5 öneriyorum (hukuk teyidi gerekir).

| Sayfa | İçerik | Not |
|---|---|---|
| Sınıf Özeti (var, genişler) | Katılım dağılımı (bu hafta aktif / seyrek / hiç — yalnız sayı), ortalama kazanım durumu | Mevcut RPC'yi genişletir |
| **Kazanım Isı Haritası** | Haftanın kazanımları × durum dağılımı (Güçlü/Pekişiyor/Gelişiyor %) · "Sınıfın %X'i bu kazanımda destek alanında" | Müfredat haftasına hizalı |
| **Yaygın Yanılgılar** | Kazanım içinde en çok seçilen yanlış şık (n≥5) | **Yeni veri gerekir:** `answer_events`'te seçilen şık yok |
| Okuma Sınıf Raporu (var) | Beceri dağılımı, zorluk seyri, kavramı tanıyan/hatırlayan sayısı | `okuma_ogretmen_sinif_ozeti` |
| Sınıf Hedefi (yazma, yeni) | Öğretmen haftanın kazanımını seçer, öğrenciye "sınıf görevi" çıkar; toplu tamamlanma % | Hukuk onayına bağlı, son dilim |
| Veli Görüşmesi | Yalnız velinin paylaştığı çocuğun Gelişim Karnesi | Bireysel veri **yalnız veli paylaşımıyla** |
| Sınıf Raporu PDF | Toplu özet (veli toplantısı) | Kimliksiz |

Hukuki duruş: GÖR-032 açık. Bireysel veriyi öğretmene vermenin KVKK 5/2 dayanağı (açık rıza / meşru menfaat / sözleşme) netleşmeden **bireysel ekran yapılmaz**. Velinin süreli ve iptal edilebilir paylaşımı, bu riski azaltan seçenektir; yine de hukuk teyidi ister.

## 9. Uygulama dilimleri

Efor göreli (S/M/L). Sıra: F0 → F1 ∥ F2 → F3 → F4 → F5 → F6 → F7.

| Dilim | Kapsam | Yeni backend | Bağımlılık | Efor |
|---|---|---|---|---|
| **F0 Karar** | Gösterge sözlüğü onayı, `admin_kazanim_kapsam` ile kazanım doluluğunu ölçme, hukuk görüşü başvurusu, D1–D8 | yok | Kullanıcı | S |
| **F1 Genel Bakış v2** | Tek cümle durum, 3 kart, "Dikkat" şeridi, yetersiz-veri durumları, kural tabanlı destek önerisi (sabit 20 öneri) | az/yok | F0 | S–M |
| **F2 Öğrenme Haritası + kalıcılık** | `veli_kazanim_haritasi`, kazanım durumu, kalıcılık, acele/zorlanma. `answer_events` indeksi. Rıza kapısı korunur | RPC'ler | F0, kazanım doluluğu | M–L |
| **F3 Destek Planı + haftalık özet** | Öneri motoru, etkinlik kütüphanesi (editoryal), haftalık e-posta/push, "yaptık" işareti, sessiz saat | tablo + kuyruk | GIE Faz 2 gönderim kararı, 3 kanal izni | M |
| **F4 Okuma ve Dil + Deneme ve Gelişim** | Mevcut RPC'lerle UI ağırlıklı birleştirme; veli deneme gelişimi | az | — | M |
| **F5 Gelişim Karnesi** | Haftalık anlık görüntü tablosu, PDF/yazdır, paylaşım bağlantısı (süreli, denetim günlüğü) | tablo + RPC | F2 | L |
| **F6 Öğretmen v2** | Isı haritası, yanılgılar (`answer_events.secilen_sik`), sınıf hedefi | RPC + kolon | Hukuk, F2 | L |
| **F7 Sertleştirme** | Gerçek hesapla tarayıcı doğrulaması, 390 px, koyu mod, erişilebilirlik, e2e | — | Test hesapları (GÖR-056) | M |

Uygulama başladığında metin ve ekran işinde `mar-oto-ai` ve `hupo-design-growth-director` devreye girer; backend, rıza ve paket kararları ana oturumda kalır (CLAUDE.md). Bu plan aşamasında onları çağırmadım.

## 10. Ölçüm ve kabul kriterleri

Başarı = velinin çocuğuna doğru destek vermesi ve devamlılık. Buton tıklaması tek başına değer sayılmaz.

- **Anlama testi** (yapılmadı): 5 veli, 60 sn içinde "Çocuğum yolunda mı? Bu hafta ne yapmalıyım?" sorusuna doğru cevap veriyor mu. Hedef ≥4/5.
- **Davranış:** haftalık özet açılma oranı; "yaptık" işareti; Gelişim Karnesi indirme/paylaşım; panele 30. gün geri dönüş.
- **Gözlemsel (nedensel değil):** Destek Planı kullanan ve kullanmayan hanelerde 4 hafta sonra aktif gün sayısı. Bildirimli/bildirimsiz **A/B** mevcut `ab_deneyler` altyapısıyla.
- **Gizlilik testleri:** rıza yokken sıfır öğrenci verisi (mevcut davranış korunur); öğretmen k-anonimlik hücre testleri (PGlite paketleri, mevcut `ogretmen_sinif_raporu` paketinin genişletilmesi).
- **Her ekranda:** yükleniyor, boş, yetersiz veri, hata, 390 px, koyu mod durumları.

## 11. Riskler ve doğrulanmayanlar

1. **Kazanım doluluğu bilinmiyor.** `kazanim_kodu` boş sorular çok olabilir; harita boş görünür. F0'da ölçülür.
2. **Hukuki dayanak açık** (GÖR-032, K-0009). Öğretmen bireysel ekranı buna bağlı.
3. **Eşikler ve durum kuralları tahmin.** Pilot veriyle kalibre edilmeli; kesin yeterlilik sonucu olarak sunulmaz.
4. **Zorluk etiketleri tahmini.**
5. **Veli kaygısı ve çocuğa baskı riski.** Ton, "çocuğunuzla konuşun" çerçevesi ve karşılaştırma yasağı gerekir.
6. **Veri hacmi.** `answer_events` büyür; özet tabloları ve indeks planı F2'de.
7. **Okuma modülü bayrağı** (`okuma_ayarlari`) varsayılan KAPALI ve içerik sınırlı; o bölüm koşullu görünür.
8. **Çalışma ağacı kirli.** Git durumunda çok sayıda değişmiş dosya var; uygulamadan önce ayrı dal ve temiz başlangıç gerekir.
9. **Doğrulanmadı:** bu çalışmada panel tarayıcıda açılmadı, uzak veritabanına sorgu atılmadı, görsel kontrol yok. Rakip bilgileri üçüncü taraf/satıcı kaynaklı.

## 12. Kararlar (kullanıcı yanıtı, 2026-10-29)

Durum: **ONAYLANDI.** Aşağıdaki tablo özgün öneriler; kesin kararlar bu kutudadır.

- **D1:** Öğretmen = kurum öğretmeni.
- **D2:** Öğretmen yalnız toplu veri + velinin açık paylaşımı. Hukuk teyidi (GÖR-032) açık kalır.
- **D3:** Kazanım durum adları ve eşikler (§6 #1) Claude kararıyla kabul; pilot veriyle kalibre edilir. 1–4. sınıfta yalnız nitel durum.
- **D4:** Bölüm→paket kararı Claude'a bırakıldı. Karar: paket matrisi **veri olarak** panelden tutulur, kodda sabit yok. Önerilen ilk matris: *Genel Bakış, Çocuğun Macerası, Bildirim ve Gizlilik, Üyelik* herkese (rıza varsa) açık; temel gelişim raporu ve tekrar listesi sınırlanmaz (`DENEME_SINIR_KURALI.md`); *Okuma ve Dil* okuma modülü erişimini, *Deneme ve Gelişim* deneme modülü erişimini izler; *Öğrenme Haritası* ve *Destek Planı* ücretsizde önizleme (sınırlı kazanım), tam hali `rapor_kapsami = birlesik` paketlerde; *Gelişim Karnesi* PDF/paylaşım `birlesik`. Fail-closed kuralı geçerli.
- **D5:** Haftalık özet hem e-posta hem push. Kullanıcının/öğretmenin mobil uygulaması kuruluysa (geçerli push kaydı) **push**, değilse **e-posta**. Varsayılan açık/kapalı ve hizmet mesajı–ticari ileti ayrımı hukuk teyidine bağlı; teyit gelene kadar gönderim yok (F3).
- **D6:** Velinin hedef→ödül döngüsü ilk sürümde YOK (Claude önerisi kabul).
- **D7:** Karne dili "gözlenen değişim"; "Hupolingo sayesinde" yok.
- **D8:** F1 ve F2 paralel; ajanlarla, token tasarrufu esas, yeterli olan işte Haiku.

## 12b. Özgün öneri tablosu (referans)

| # | Karar | Önerim |
|---|---|---|
| D1 | Öğretmen kim: kurum/okul öğretmeni mi, Hupo'nun kendi eğitmeni mi? | Önce netleşmeli; paket türü `kurum` ile bağlantılı |
| D2 | Öğretmen bireysel veri: yalnız toplu + veli paylaşımı mı? | Evet; hukuk teyidi sonrası genişler |
| D3 | Kazanım durum adları ve eşikleri (§6 #1) | Kabul, pilotla kalibre |
| D4 | Hangi bölüm hangi pakette (panel matrisi) | Kullanıcı kararı; cevapsız yayınlanmaz |
| D5 | Haftalık özet: e-posta/push, gün/saat, varsayılan açık/kapalı; hizmet mesajı mı ticari ileti mi (hukuk) | Varsayılan kapalı, ilk girişte kullanıcıya sor |
| D6 | Velinin koyduğu "hedef→ödül" (Prodigy tarzı) | İlk sürümde yok; dışsal motivasyon riski |
| D7 | Karne dili: "gözlenen değişim", "Hupolingo sayesinde" yok | Kabul |
| D8 | Başlangıç sırası | F0 → F1 ve F2 paralel |

## Kaynaklar

- IXL: https://blog.ixl.com/2023/07/17/how-to-track-your-childs-progress-on-ixl/ · https://blog.ixl.com/2020/09/23/how-to-spot-and-address-your-childs-learning-gaps/
- Prodigy: https://prodigygame.com/blog/report-card-tool · https://prodigygame.com/blog/learning-progress-support
- Tassomai: https://tassomai.com/strategy-parent-reports · https://tassomai.com/school-parents
- Khan Academy: https://support.khanacademy.org/hc/en-us/articles/360031129891 · https://support.khanacademy.org/hc/tr/articles/5548760867853
- Lexia Core5: https://community.lexialearning.com/student-progress-reports-97/mylexia-reports-core5-class-skill-progress-1563 · https://community.lexialearning.com/student-progress-reports-97/mylexia-reports-core5-class-overview-1554
- ASSISTments: https://www.assistments.org/blog-posts/our-research-parent-notification · WPI: https://digital.wpi.edu/show/6q182k231
- PBS KIDS: https://cresst.org/publication/supporting-childrens-progress-through-the-pbs-kids-learning-analytics-platform/
- EBA veli: https://bianet.org/haber/meb-veliler-icin-egitim-bilisim-agi-tanitim-videosu-hazirladi-221587
- Morpa Kampüs: https://www.karar.com/morpa-kampus-giris-nasil-yapilir-ucretsiz-uyelik-islemleri-son-dakika-haberi-249726
