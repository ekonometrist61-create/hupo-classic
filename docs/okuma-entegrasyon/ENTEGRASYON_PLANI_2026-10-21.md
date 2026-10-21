# HupoRead → Hupolingo entegrasyonu: değerlendirme ve plan (2026-10-21)

Durum: **ONAY BEKLİYOR.** Bu oturumda kod, veritabanı ve içerik değiştirilmedi; yalnız okundu.
Önceki planlar: `C:\Dev\Senin Hikayen - HupoRead\docs\HUPO_ENTEGRASYON_PLANI.md` (§10 kesinleşen kararlar hâlâ geçerli), `docs/hupo-design-growth/okuma-*.md`, `PROJE_GUNLUGU.md` K-0080…K-0091.

## 1. Tespit: "entegre edilecek" şey aslında iki çatal

Modül Hupolingo'da büyük ölçüde zaten var. Asıl iş **iki kopyayı tek kaynakta birleştirmek** ve canlıya hazırlamak.

| Parça | Hupolingo (`C:\Dev\hupo`) | Bağımsız prototip (`Senin Hikayen - HupoRead\flutter_prototip`) |
|---|---|---|
| Veri | Gerçek RPC'ler, 7 migration uzakta uygulanmış (`20261050…`–`20261051…`) | `ornek_veri.dart` (122 KB gömülü), cevap kontrolü yerelde |
| Mobil/Web ekranları | 9 ekran, `okuma_motoru` paketi, Bugün kartı, Okuduklarım + Sözlüğüm, Düşün kartı, SVG çıkartma, yeni PDF | **V3 görsel dil** (`okuma_v3.dart`), sahne görselleri (8 jpg), gösterim kuralları, süre etiketi, soru otomatik geçişi |
| Yönetim | Hikâye Atölyesi (8 sekme) | yok |
| Veli / öğretmen | `/veli-paneli/okuma-dunyasi`; öğretmen kartı `/yonetim/siniflar` içinde | yok |
| Canlı durum | Bayrak KAPALI, yayında hikâye yok, sözlük yüklenmedi | APK telefonda |

## 2. Değerlendirme (kanıtlı bulgular)

1. **En büyük risk: okuma işi git'te değil.** `git ls-files` yalnız 2 okuma dosyası gösteriyor. Mobil modül, web panel sayfaları, testler ve **uzakta uygulanmış 7 migration** commit'siz (untracked). Disk ya da dal kazası, canlı DB ile repo arasında kopukluk yaratır.
2. **Görsel kalite açığı Hupolingo tarafında.** Kullanıcının istediği V3 arayüz yalnız prototipte; Hupolingo okuyucusu K-0078/K-0083 dönemindeki sade hâlde. Port gerekiyor.
3. **Sahne görseli için sunucu sözleşmesi yok.** Sözleşmedeki "sahne" anlatı varyantıdır (`deger_sahneleri` vb.), görsel değil. Prototip 8 jpg'yi (3,6 MB) uygulamaya gömüyor; bu ölçeklenmez.
4. **Sözleşme boşlukları (V3 içeriği için):** Bilgi Kutusu, eş/zıt anlam, Düşün soruları için onaylı veri alanı yok (prototipte taslak, editör onaysız). `dusun` alanı (≤3) uzakta var ama içerik yok.
5. **Gösterim kuralları yalnız prototipte.** "Hikâye başına en çok 2 atasözü" kuralı kodda bile zorlanmıyor; panel içe aktarması da kontrol etmiyor.
6. **İçerik hazır değil (kritik yol):** 24 taslak denetimsiz (Ajan A/B + insan okuması yok), sözlük yüklenmedi, "Hazır Hupo" kahramanı için hikâye yok, süreler tahmin.
7. **Ticari taraf yarım:** Kota ve PDF hakkı (`okuma_gunluk_hikaye=1`, `okuma_pdf_aylik_ucretsiz=3`) DB'de var. Landing, fiyat sunumu ve Planlar ekranında okuma yok.
8. **Web (Flutter Web) doğrulanmadı:** PDF indirme/paylaşma (`printing`, `file_saver`) web'de, 2,8 MB okuma varlığının ilk yüklemeye etkisi ve 1024 px düzeni test edilmedi.
9. **Hukuk ve güvenlik kapıları açık:** GÖR-045 (KVKK m.6 sorusu, saklama, AI metin telifi), GÖR-049 (dört göz için iki yönetici hesabı), GÖR-001 (Gemini anahtarı döndürme).

Doğrulanmayanlar: bu oturumda `flutter analyze/test`, `npm run build/lint` çalıştırılmadı; günlükteki test sayıları (PGlite 171/172, Flutter okuma testleri 70+) rapordan alınmıştır.

## 3. Hedef mimari ve ilkeler

- **Tek kaynak: `C:\Dev\hupo`.** Prototip dondurulur (README'ye "arşiv, geliştirme Hupolingo'da" notu). `okuma_motoru`, derleyici (`atolye`) ve içerik taslakları da Hupolingo'ya taşınır (`tools/okuma-atolye`, `docs/okuma/`, `soru-bankasi` benzeri `icerik/`).
- Öğrenci: **Flutter tek kod** (mobil + `app.hupolingo.com`). Veli/yönetim/öğretmen: Next.js.
- Sahne görselleri sunucudan: Storage'da sürümlü dosya, pakette `sahne{yol,alt_metin,sha256}` alanı, cihazda önbellek. Uygulamaya gömülmez.
- Öğrenme çekirdeği (okuma, sorular, geri bildirim) kısıtlanmaz; fark veli içgörüsü ve PDF'te (önceki karar).
- Canlıya dönük her adım (db:deploy, bayrak, içerik yükleme/yayın, push, landing yayını) ayrı kullanıcı onayı ister.

## 4. Plan

### Faz 0 — Sabitleme (1 gün, kod değişikliği yok denecek kadar az)
1. Dal: `feature/huporead-entegrasyon`. Okuma dosyalarını (mobil, web panel, testler, migration, docs) mantıklı commit'lere böl. `learn_screen`, `VeliSidebar`, `adminNav`, `SiniflarManager` farkları yalnız okuma satırlarını içersin; öteki birikmiş değişiklikler (Kelime Evreni vb.) ayrı commit.
2. `npm run db:status`: repo migration'ları uzakla birebir mi? (7 dosya.)
3. Taban çizgisi: `flutter analyze`, `flutter test`, `supabase/tests/okuma_dunyasi` (PGlite), web `lint` + `build`. Sonuçlar yazılır.
4. Prototipi dondur; bu planı `PROJE_GUNLUGU.md`'ye kayıt et (GÖR-053 kapanır).

### Faz 1 — V3 arayüzünü Hupolingo'ya taşı (öğrenci mobil + web)
Sıra: (a) gösterim kuralları → `okuma_motoru` (saf Dart, birim test; ≤2 atasözü, sayfa bütçesi, Sade/Zengin) → (b) `okuma_v3` bileşenleri `mobile-app/lib/widgets/okuma/` altına, mevcut `okuma_tema`/`AppColors`/`GameCard`/`ChunkyButton` ile; Düşün, Sözlüğüm ve SVG çıkartma korunur → (c) hikâye kartında "N dk", soru ekranında otomatik geçiş (hareket azaltmada animasyonsuz) → (d) sahne görseli: önce yedek sahne (görselsiz çalışır), sonra Faz 2'deki alanla → (e) PDF: Hupolingo üreticisi esas; prototipin kapak kırpma kusuru ve yeni sahne bandı kontrol edilir.
Kabul: 390×844 ve 1024×768 (+360×640 ve 2.0 yazı ölçeği) ekran görüntüsü; gerçek cihazda uçtan uca; web'de PDF indirme; APK/web paket boyutu farkı ölçülür (>1 MB artış bütçe dışı).

### Faz 2 — Sunucu sözleşmesi ve içerik (ayrı onaylı migration)
1. Paket şemasına isteğe bağlı, geriye uyumlu alanlar: `sahne` (görsel), `bilgi_kutusu`, kelime `benzer/zit` (yalnız onaylı veri). Doğrulayıcı, içe aktarma, derleyici, panel önizlemesi birlikte güncellenir. `db:preview` → onay → `db:deploy`.
2. Sözlük yükleme (yuva anlamları, sınıf bantları), "Hazır Hupo" hikâyeleri.
3. İçerik hattı: 24 taslak → Ajan A (bilgi) + Ajan B (dil/edebiyat) → insan okuması → ilk yayın seti **4–5. sınıf, 12–24 hikâye**. Süreler gerçek okuma ölçümüyle güncellenir (pilotta).
4. Sahne görsellerini üret/seç (8 mevcut + yenileri); kahraman çocuğun seçimi olduğu için sahnede sabit yüz yok (mevcut kural).

### Faz 3 — Paneller
- **Yönetim (Hikâye Atölyesi):** sahne görseli yükleme + önizleme; Düşün/Bilgi Kutusu/benzer anlam editörü ve onay; içe aktarmada gösterim-kuralı denetimi (hata/uyarı); sözlük yükleme ekranı; karne eşik uyarıları (tamamlama ≥%70, anlama ≥%60 vb.); ayarlara kota/PDF hakkı. GÖR-049 çözülmeden "dört göz" yalnız test hesaplarıyla denenir.
- **Veli (`/veli-paneli/okuma-dunyasi`):** rıza yoksa kilitli kart; değer önceliği (≤5/20); açıklanabilir özet (işlem türü, hedef durumu, tema/değer); PDF; geri dönüş bildirim tercihi (hukuk onayına kadar kapalı); ücretsiz/premium farkı net ve dürüst (puan/sınav garantisi yok). Planlar/abonelik sayfasında okuma hakları görünür.
- **Öğretmen:** ayrı panel yok; `/yonetim/siniflar` içindeki sınıf kartı kalır (toplulaştırma, min-N). Hikâye atama ve okul paketi sonraki faz.

### Faz 4 — Web sitesi (hupolingo.com)
Şu an landing/demo'da okuma yok. Önerilen sıra: (1) **içerik ve pilot sonuçları gelmeden iddia yok**; (2) veli odaklı bölüm "Çocuğun kahramanı olduğu hikâyeler": Maarif değerleri, sınıfa uygun kelime/deyim/atasözü, açıklanabilir veli özeti, PDF; sahte sosyal kanıt, sınav/puan garantisi yok, "MEB onaylı değildir" ifadesi; (3) `/demo`'ya statik tek örnek hikâye (kayıt gerektirmez); (4) fiyat sayfasında hak kalemi olarak (ayrı SKU yok); (5) SEO sayfası ("sınıfa göre okuduğunu anlama"), tasarım ajanıyla (`hupo-design-growth-director`). Yayın, pilot bitişi + hukuk onayı sonrası.

### Faz 5 — Kapalı pilot
İzinli 4–5. sınıf hesapları, bayrak yalnız onlara; ölçütler ve eşikler önceki plan §3'teki gibi; GÖR-045 kapanmadan açılmaz; push veli onayıyla ve hukuk sonrası. Çıkışta: bayrak genel açılış kararı (kullanıcı).

### Faz 6 — Sonra
İngilizce (K-0091'deki ön analiz), Storage/CDN'e geçiş (egress eşiği), sesli okuma (TTS kararı), hikâye atama, 1. sınıf ayrı pilot, release imzası.

## Faz 1 ilerleme
- (a) TAMAM: gösterim kuralları okuma_motoru'na taşındı (gosterim_kurallari.dart, 7 test), okuyucu bütçesi bu tek kaynağa bağlandı (ilk geçiş, cümle başına tek vurgu, sınıf/moda göre bütçe). dart test 47/47, lutter analyze okuma temiz, okuma ekran testleri geçti.
- (b) TAMAM: V3 bileşenleri `lib/widgets/okuma/okuma_v3.dart` (başlık bandı, tür/sınıf/süre çipleri, ilerleme, adım rozeti, sahne yedeği, atasözü kartı, Anlamı kutusu, kelime paneli, geri sayım). Okuyucu ve soru ekranı bunlara bağlandı. Süre kuralı tek kaynağa alındı (`sure.dart`, 5 test). Geri sayım çubuğu eklendi; hareket azaltmada çubuk yerine süre metni. Testler: okuma 82/82, motor 53/53, V3 5/5. Önizleme 390 ve 1024 genişlikte kontrol edildi.
- (b) ertelenen kalemler (veri sözleşmesi yok): Kelime Keşfi (eş/zıt anlam alanı), Bilgi Kutusu, Düşünme soruları, sahne görseli (Faz 2), üst bar düğmesi (mevcut app bar yeterli).
- (b) karar bekleyen: V3 başlık bandındaki Hupo maskotu okuyucuda kapalı (K8). Açmak için tek satır (`maskot: true`). Kullanıcı kararı gerekir.
- (b) süre uyumsuzluğu bulundu ve düzeltildi: derleyici ile belge farklıydı (2→60, 3→80 … ve yarım dakika). Derleyici belgeye hizalandı; önceki derlemelerdeki süre değerleri eski kalır, yeniden derlenince güncellenir. Prototip klasörü ayrı bir git deposu; `atolye/src/derle.ts` ve `sema/etiket-sozlugu.v1.json` orada commit'lenmedi.

## Faz 2.0 ilerleme (fiş katmanı, yerel)
- Migration: `supabase/migrations/20261057000000_okuma_hikaye_fisleri.sql` (tablo, doğrulayıcı, idempotent içe aktarma, listeleme). Metin alanı yok; hak/müfredat onayı içe aktarmayla değişmez; brief_draft dışı fiş güncellenmez.
- PGlite: 16 yeni senaryo geçti (yetki, kuru çalıştırma, idempotency, atomiklik, bilinmeyen alan, sınıf-bant, içerik koruması, 120 fiş). RPC envanter kilidi 27→29 olarak güncellendi.
- Sürüm numarası çakışması: ilk taslak 20261054000000 idi; Kelime Evreni aynı numarayı uzakta kullanmış. 20261057000000'a taşındı.
- `db:preview`: 2 migration bekliyor: `20261056000000_kelime_teyit_duzeltmeleri.sql` (Kelime Evreni, bu işe ait değil, test edilmedi) ve `20261057000000_okuma_hikaye_fisleri.sql`. `db:deploy` ikisini birlikte uygular; ayrı onay gerekir.
- Hikâye metni üretimi yok; ChatGPT'den tam metinler bekleniyor.
- **Uzakta uygulandı (2026-10-21, kullanıcı onayı):** `20261057000000_okuma_hikaye_fisleri.sql`. `db:preview` sonrası `db:deploy` çalıştı; ardından `db:preview` "Remote database is up to date" verdi. 20261056 deploy öncesi zaten uzakta uygulanmış görüldü (Kelime Evreni çalışması).

## 4b. Kararlar ve ek gereksinimler (kullanıcı, 2026-10-21)

**Kararlar:** Faz 0 başlatıldı. Prototip dondurulur, geliştirme Hupolingo'da. Sahne görselleri sunucudan. Landing bölümü pilot sonrası (önce `/demo` örneği). Yayın setinin insan okumasını kullanıcı yapar.

**Ek gereksinimler (her biri bir faza bağlandı):**
1. **Veli ve öğretmen dashboard'u (Faz 3):** çocuğun öğrendiği kavramlar (hedef durumu: tanıştı → tanıdı → aktardı), okunan hikâyeler, öğrenilen kelime sayısı, doğru/yanlış dağılımı (işlem türüne göre), aldığı değerler (Maarif), tema ilgisi, zorluk seyri, okuma süresi. Öğretmende sınıf düzeyinde toplulaştırma (min-N). Mevcut RPC'ler (`okuma_veli_ozeti`, öğretmen raporu) hangi alanları verdiği denetlenir; eksik metrikler için ek RPC. Öğrenme metriği XP/süre ile karıştırılmaz.
2. **Yönetimde hikâye yaşam döngüsü (Faz 3):** yükleme (var: `okuma_paket_ice_aktar`), **düzenleme** (şimdi sürümler değişmez; düzenleme = yeni taslak sürüm üretip eskiyi arşivleme; panelde metin editörü + kuru çalıştırma), **çıkarma** (yayından kaldır = arşiv, var), **silme** (yalnız taslak/arşiv ve oturumu olmayan hikâyeler; oturumu olanlar için yumuşak silme; `log_admin_action` ile kayıt). Toplu işlem. Genel istatistikler: karne + boşluk haritası var, genel özet panosu eklenir.
3. **Kullanım süresi analitiği (yeni, Faz 3b):** mobil + Flutter Web + web sitesi + paneller için "nerede ne kadar vakit". Bugün yalnız web-panelde PostHog var (`AnalyticsProvider.tsx`, çerez onaylı); Flutter tarafında kullanım süresi ölçümü yok. Önerilen tasarım: tek olay şeması (`yuzey` = mobil/flutter-web/site/veli/yonetim, `ekran`, `sure_sn`, anonim oturum), Flutter'da hafif ekran-süresi gözlemcisi (uygulama arka plana gidince oturum kapanır, boşta süre sayılmaz), sunucuda özet tablo + yönetim panosu (yüzey × ekran × süre). Çocuk verisi için KVKK: kimliksiz veya sözde-kimlikli, rıza/aydınlatma güncellemesi (GÖR-045 kapsamı). Mevcut Growth CRM olay altyapısı (`20261014000000_growth_crm_core.sql`) yeniden kullanılabilir mi, Faz 3b başında incelenir.
4. **120 hikâyelik içerik hattı (Faz 2):** kullanıcı `.md` hikâyeleri verecek; ben bunları Atölye biçimine (`.hikaye.md` + derleyici, etiketler, hedefler, sınıf bandı, sorular) uyarlarım. Önce 2–3 hikâyelik pilot dönüşüm ve kullanıcı onayı, sonra toplu (Haiku ile mekanik dönüşüm, Sonnet ile doğrulama). Kullanıcının verdiği metne içerik düzeyinde dokunmam; uygunsuzluk veya sınıf-seviye uyumsuzluğu işaretlenir, değiştirilmez. Derleyici hata/uyarı raporu kullanıcıya özetlenir; insan okuması kullanıcıda.

## 4c. "120 hikâye" paketinin değerlendirmesi (ChatGPT çıktısı, `HupoRead_Ilk_120_Hikaye_Arsivi.zip`)

**Ne olduğu:** 120 hikâye değil, **120 üretim fişi** (kimlik HR-001…HR-120, başlık, 86–145 karakterlik öykü çekirdeği, sınıf, tür, söz varlığı kategorisi, değer, ikon önerisi, telif sınıfı). Dosya kendisi de "tam hikâye değildir" diyor. Kullanıcının "hikâyeleri biçime uyarlayacaksın" beklentisi bu yüzden yerine **üretim işi** olarak okunmalı: 120 tam metin yazmak gerekiyor.

**Doğrulanan (ölçüldü):** 120 benzersiz kimlik ve başlık; sınıf dağılımı 2:15, 3:12, 4:13, 5:20, 6:20, 7:20, 8:20 (1. sınıf yok); tür 11 çeşit; telif sınıfı Ö=93, A=18, K=9; durum hepsi `brief_draft`, `rights_cleared=false`, `curriculum_verified=false` (dürüst bayraklar). Sabit kahraman adı yalnız 2 fişte geçiyor (Hupo/Ela/Ali tipi); gerisi kahraman-token modeline uygun.

**Eksikler / riskler:**
1. **Sözleşme uyumsuzluğu.** Fişte somut kelime, deyim, atasözü, kazanım kodu, soru ve sınıf bandı bilgisi yok; yalnız kategori ("yön bildiren sözcükler"). Sistemimiz bunları somut istiyor (sözlük yuvaları, hedefler, ≤2 atasözü, sorular). Üretimde sözlükten seçilecek; ilk adım fiş → hedef listesi çıkarımı.
2. **Sözlükte olmayan hedef yok kuralı.** Hedef yapılacak her kelime/deyim/atasözü onaylı sözlükte (Ajan A/B + insan) olmalı; fişteki "sesteş: yüz — sınıf uygunluğu editörce kontrol edilecek" gibi notlar bu kapıya girer.
3. **İkon eşleşmesi zayıf (kaba ölçüm, tam sözcük eşleşmesi):** 216 benzersiz ikon önerisinin yalnız 63'ü (~%29) katalogdaki etiket/etikette var. En sık eksikler: gölge, terazi, fotoğraf, kapı, kutu, el, taş, oba, zarf, sözlük, ekran, kopuz, sofra, ok. İki yol: önerileri kataloğa en yakın ikona eşle, kalan özgün kavramları yeni ikon olarak üret (80+ ikon, her biri insan QA).
4. **Telif/kaynak (A=18, K=9):** Kaynak bağlantısı, edisyon ve hak durumu fiş başına kayıtlı değil; yayın koşulu olarak her A/K için editör kaydı gerekir. Kamu malı çekirdekler (Ezop, Grimm, Verne, Ö. Seyfettin, Mesnevî, Dede Korkut) makul görünüyor; ancak çeviriler/sadeleştirmeler korunur, **hikâye sıfırdan anlatılmalı**. Hukuki doğrulama bizde yok (GÖR-045/GÖR-043 kapsamı); hukukçu onayı gerekir.
5. **İçerik duyarlılığı:** 8. sınıf "Yalnız Efe" (HR-117) savaş/şiddet çerçevesi içerir; yaş uygunluğu ve duyarlılık incelemesi şart. Mizah/Nasreddin fıkra uyarlamalarında kalıp yargı riski kontrol edilmeli.
6. **Kapsam:** 4–5. sınıf pilot kümesi 33 fiş (13+20). 1. sınıf yok; mevcut 24 taslak (sınıf 1–8, 3'er) ile çakışma/mükerrer tema denetimi gerekir. Seri/devam hikâyesi var mı belirsiz.
7. **Uzunluk hedefleri** (ör. 8. sınıf 1.200–1.800 sözcük) mevcut taslakların (bazıları hedefin altında) ve ekran/okuma süresi modelinin üstünde; bu uzunlukta 120 hikâye = yaklaşık 100 bin sözcük. Maliyet ve insan okuma yükü (kullanıcı okuyacak) büyük; **dalgalı yayın** şart.
8. **Prompt hatası:** ChatGPT'nin istediği "uçtan uca 2., 5., 8. sınıf pilot" bizim hattımıza uyuyor; ancak "tekrar kayıt oluşturmadan, ID'leri koruyarak içe aktar" yalnız fiş katmanı için mümkün (tam sürüm paketi olmadan `okuma_paket_ice_aktar` çalışmaz).

**Kullanıcı notu (2026-10-21):** ChatGPT yalnız kurguyu yazmış; tam metinleri üretmesi için ona talimat verildi. Hikâye üretimine ben başlamıyorum; ChatGPT metinleri gelince 2.1 (içe aktarma) ve doğrulama adımları uygulanır. Bu arada fiş katmanı, ikon eşlemesi ve sözleşme işleri hazırlanabilir.

**Eklenen işler (Faz 2 altında, sırayla):**
- **2.0 Fiş katmanı (migration, ayrı onay):** `okuma_hikaye_fisleri` (fis_kodu HR-xxx benzersiz, idempotent upsert, alanlar yukarıdaki fişle birebir, `durum`, `hikaye_id` bağı, telif kayıt alanları: kaynak/edisyon/hak notu/onaylayan). `okuma_hikaye_surumleri`'ne dokunulmaz. Yönetim panelinde "Fişler" sekmesi: filtre, durum, tam metne bağlama, telif kaydı, silme/düzenleme yok değil (taslak fiş serbest düzenlenir).
- **2.1 İçe aktarma betiği:** katalog JSON → fişler (kuru çalıştırma, ID koruma, tekrar çalıştırmada kayıt çoğalmaz); md bölümleri doğrulama için okunur, tek kaynak JSON.
- **2.2 Pilot üretim (2., 5., 8. sınıf, 3 fiş):** fiş → hedef çıkarımı (sözlükten) → tam metin (sınıf bandı, token'lı kahraman) → derleyici → Ajan A/B → kullanıcı okuması. Ölçüt: derleyici hatasız, gösterim kuralları geçer, telif kaydı dolu, kullanıcı onayı. Sonuç kaliteyi belirler, kalan 117 için şablon çıkar.
- **2.3 Dalga üretimi:** önce 4–5. sınıf (33 fiş) → 6–8 → 2–3; her dalga 10–15 hikâye, insan okumasını kullanıcı yapar; üretimde mekanik/ön taslak işi Haiku, redaksiyon ve kural denetimi Sonnet.
- **2.4 İkon kapsamı:** fişlerden çıkan ikon önerileri → kataloğa eşleme tablosu; eksik özgün ikonlar toplu üretim listesi (öncelik: pilot dalga).
- **2.5 Önce çözülecek engel:** PGlite'taki kırmızı test (atölyede 5 pakette `ogrenme_hedefleri[6].etiket` kuralı); yeni hikâyeler aynı doğrulayıcıdan geçeceği için üretim şablonu bu kuralı baştan karşılar.

## 5. Kullanıcıdan gereken kararlar

1. Faz 0'ı başlatayım mı (commit bölme, dal, taban testleri)? Commit onayı sizde.
2. Prototip dondurulsun, tüm geliştirme Hupolingo'da mı? (Önerim: evet.)
3. Sahne görselleri sunucudan (Storage + paket alanı) mı, ilk pilotta gömülü mü? (Önerim: sunucudan; Faz 1'de yedek sahne ile görselsiz çalışır.)
4. Landing bölümü pilot sonrasına mı kalsın? (Önerim: evet; öncesinde yalnız `/demo` örneği.)
5. İlk yayın seti 4–5. sınıf, 12–24 hikâye ve insan okuması için kim (siz mi, bir Türkçe öğretmeni mi)?

