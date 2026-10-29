# Sosyal medya kanal yönetimi ve otomasyon planı (taslak)

- **Tarih:** 2026-10-29 · **Hazırlayan:** MAR-OTO-AI · **Durum:** PLAN, ONAY BEKLİYOR (hiçbir hesap bağlanmadı, hiçbir şey yayınlanmadı)
- **Yüzey:** sosyal medya (organik) → landing `/demo` · **Hedef kitle:** veli · **Ana eylem:** "Örnek soruları dene" · **Ana metrik:** UTM'li sosyal oturumlardan `demo_tamamlandi` (baseline yok; ilk 4 hafta yalnız ölçüm)
- **Önkoşul:** `STRATEJI_DEGERLENDIRME.md` §0 "Yayın öncesi zorunlu kontrol listesi" (mağaza rozetleri, güven rozetleri, robots.txt) kapanmadan trafik yönlendirilmez. Şu an geliştirme aşamasında olduğu için bu düzeltmeler satıştan hemen önce yapılacak; hesaplar açılana kadar footer'daki sosyal bağlantılar çalışmıyor sayılır (§10).
- **Takvim:** sabit tarih yok. T0 = hesapların açıldığı gün; Y = ilk yayın günü (§11).

## 1. Kanal seçimi ve rolleri

Güven etiketi: tüm kanal seçimleri **Hipotez** (Türkiye veli kitlesi için ölçülmüş veri yok).

| Kanal | Rol | Format | Sıklık (ilk 4 hafta) | Karar |
|---|---|---|---|---|
| **Instagram** (`@hupolingo`, hesap sahipliği teyitli değil) | Ana kanal: veli keşfi, güven | Reels, kaydırmalı carousel, story | 4 gönderi/hafta + story | ÖNER — aktif |
| **YouTube Shorts** (`@hupolingo`) | Instagram Reels'in aynı dikey videosunu yeniden kullanır; arama ömrü | Dikey kısa video | 2/hafta (Reels'ten) | ÖNER — aktif, ek üretim yok |
| **LinkedIn** (şirket sayfası) | Kurumsal şeffaflık; öğretmen/eğitim paydaşı | Metin + tek görsel | 1/2 hafta | ÖNER — düşük öncelik |
| Facebook veli grupları | Doğrudan gönderme yok; topluluk kuralı ve spam riski | — | — | ÖNERİLMEZ (hesap sahibi gündeme getirirse ayrı karar) |
| TikTok | Çocuk kitlesi ağır; çocuğa ticari baskı çizgisine yakın; hesap açılmadı | — | — | ERTELE (ilk veri sonrası) |
| X/Twitter | Veli kitlesine sinyal zayıf | — | — | ÖNERİLMEZ |

**Seçim gerekçesi (ICE):** Instagram etki 4 × güven 3 × kolaylık 4; YouTube Shorts yeniden kullanım nedeniyle kolaylık 5. Ücretli reklam bu planda **yok**; harcama yalnız ayrı onayla ve manuel `growth_harcama` tablosuna girilir.

**Kanal kuralları (hepsi):** Çocuk gerçek adı/fotoğrafı/sesi yok; gerçek öğrenci verisi ve ekranı yok (örnek rapor "ÖRNEK" etiketli); mağaza "indir" CTA'sı yok; yorum/DM'de çocuk verisi toplanmaz; kullanıcı yorumu, sayı, uzman, basın logosu yok.

## 2. İçerik sütunları

| Sütun | Payı | Veli için amaç | Kanıt kaynağı |
|---|---|---|---|
| 1. **Küçük adım** (alışkanlık) | %30 | Soru çözme rutinini kurma | Genel öneri; "araştırma gösterdi" yok |
| 2. **Veli rehberi** (evde pratik, ekran, yanlış cevap) | %25 | Faydalı olmak, kaydedilir/paylaşılır içerik | Genel öneri; MEB/kazanım iddiası yok |
| 3. **Ürünün içinden** (demo, etiketli örnek rapor) | %25 | Gerçek deneyimi göstermek | Landing/demo (gerçek ekran görüntüsü gerekir) |
| 4. **Güven ve şeffaflık** | %10 | Güven itirazına cevap | Landing güven bölümü + manifest taraması |
| 5. **Hupo evreni** | %10 | Marka sıcaklığı | Onaylı Hupo posları |

**Yasak içerik:** sınav kaygısı/korku, "çocuğunuz geride kalıyor", sayaç/stok baskısı, "ücretsiz deneme", "otomatik yenilenir", "KVKK uyumlu", "garanti", "1 numara", "resmî", "bilimsel olarak kanıtlandı", okul adı, MEB kazanım kodu (kaynak görülmeden), 2026 MEB hikâye yarışması içeriği (AI yasak).

## 3. Haftalık ritim (öneri)

| Gün | Instagram | YouTube Shorts | LinkedIn |
|---|---|---|---|
| Pazartesi | Reel (sütun 1/3) | Aynı Reel | — |
| Çarşamba | Carousel (sütun 2) | — | (iki haftada bir) |
| Cuma | Reel: örnek soru (sütun 3) | Aynı video | — |
| Pazar | Carousel/Story seti (sütun 4/5/2) | — | — |
| Cumartesi | Story: Hupo anı + anket (veli sorusu) | — | — |

Yayın saati: **Hipotez** — hafta içi 20:00–21:30, hafta sonu 11:00 (ev ödev saati sonrası). İlk 4 haftada saat değişkeni tek tek denenir; sonuç "kayıtlı" tutulur, yayın saati kararı 4. haftadan sonra.

## 4. Onay akışı (taslak → insan onayı → yayın)

```
FİKİR → TASLAK → OTOMATİK KONTROL → İÇERİK DENETİMİ → SAHİP ONAYI → ZAMANLANDI → YAYINLANDI → ÖLÇÜLDÜ
(ajan)   (ajan)   (lint, kural)     (MAR-OTO-AI)      (proje sahibi)  (insan)       (insan)       (haftalık)
```

| Aşama | Kim | Kapı |
|---|---|---|
| Taslak üretimi | MAR-OTO-AI veya growth-ajan `content_planner` (AI = taslak) | Çıktı `durum=taslak` |
| Otomatik kontrol | Betik (§5.3) | Yasaklı ifade, girdide olmayan sayı, `ücretsiz deneme`, çocuk adı/PII → **reddedildi** |
| İçerik denetimi | MAR-OTO-AI ikinci okuma (kontrol listesi: kırmızı çizgiler, kanıt etiketi, UTM) | Her gönderi için "kanıt" alanı dolu |
| Sahip onayı | Proje sahibi (tek tık, gönderi bazlı veya haftalık paket) | Onaysız gönderi **zamanlanamaz** |
| Zamanlama/yayın | **İnsan**, platformun kendi aracında (Meta Business Suite / YouTube Studio) | API token yok |
| Ölçüm girişi | İnsan (platform istatistiği) veya CSV içe aktarma | Haftalık, Pazartesi |

Acil durdurma: sahip, tek mesajla bir gönderiyi kaldırtır; yorumlar için moderasyon kuralı (§7).

## 5. Mevcut altyapıya bağlanma (REUSE → EXTEND → CREATE)

**Doğrulanan mevcut parçalar:** `scripts/growth-ajan/ajan.py` (taslak + sayı doğrulama + prompt-injection kuralı, 3 ajan); `docs/growth-crm/ajan-ciktilari/` (taslak çıktı klasörü); `admin_audit_log`; `growth_harcama` (manuel harcama); `growth_events`/`growth_web_olay_kaydet` (UTM beyaz listeli olay); n8n yalnız loopback (`127.0.0.1:5678`, karar 2026-10-28); pg_cron ile haftalık rapor taslağı; Büyüme Özeti ekranı (`/yonetim/buyume-ozeti`).

### 5.1 REUSE (kod yok)
- `content_planner` ajanı mantığı ve **sayı doğrulaması**: sosyal metinlerde yalnız girdideki olgu kaydındaki sayılar geçebilir (örnek: "en fazla 10 soru", "5 örnek soru", "40 karakter", "8 dünya"). Olgu kaydı = küçük JSON (`sosyal-medya/olgular.json`, **henüz yok**, bu plan onaylanınca yazılır).
- Onay kapısı olarak mevcut "taslak → yönetici onayı" modeli (Faz 2 haftalık rapor).
- UTM + `growth_harcama` yalnız ileride ücretli reklam gelirse.

### 5.2 EXTEND (küçük, onaylı)
1. `ajan.py` içine dördüncü ajan `sosyal_taslak_yazari` (talimat: yalnız olgu kaydı; çocuk adı yok; yasaklı ifade listesi dışı). Mevcut `dogrula()` değişmez. *Kod bu işte yazılmadı.*
2. **Yasaklı ifade / kural linter'ı**: `scripts/growth-ajan/sosyal_lint.py` — taslak JSON/Markdown'ı tarar; regex listesi §2'deki yasak içerik + "ücretsiz", "garanti", "%100", "otomatik yenil", "KVKK", "resmî", "MEB", kazanım kodu deseni (`[A-Z]\.\d\.\d`), çocuk adı için büyük harf+yaş deseni uyarısı. *Yazılmadı; spesifikasyon bu belgededir.*
3. UTM bağlantı üreticisi (aynı betik): gönderi kodundan `?utm_...` üretir.

### 5.3 CREATE (ancak onaylı ve ihtiyaç kanıtlanınca)
- `growth_sosyal_gonderi` tablosu (kod, kanal, format, durum, yayın_tarihi, utm_content, onaylayan, onay_tarihi, kanit_notu) + `admin_*` RPC + yönetim sayfası. **Migration yazılmadı**; yeni migration kuralları (migrasyon sahipliği) ve `growth` bayrakları senin kararındır. İlk 4 hafta **dosya tabanlı takvim** (Markdown/JSON) yeterli: öğrenme önce, tablo sonra.
- Metrik girişi için `growth_harcama` benzeri `growth_sosyal_metrik` (tarih, kanal, gönderi_kodu, erişim, kaydetme, paylaşım, profil_ziyareti, bağlantı_tıkı) — manuel giriş; hesap bağlama yok.

### 5.4 Yapılmayacaklar
- Instagram/YouTube/LinkedIn **API'siyle otomatik yayın** ve hesap OAuth bağlama (dış hesap bağlama onay ister; ayrıca token saklama güvenlik yükü). İlk aşamada gerek yok.
- Otomatik DM/yorum botu (çocuk/kişisel veri riski, platform kuralları).
- E-posta/SMS/push ile sosyal içerik dağıtımı: ticari ileti izni (`/ticari-ileti-izni`) ve hukuk onayı olmadan hayır. Organik sosyal gönderi ticari ileti izni kapsamı dışındadır, e-posta için geçerli kapılar aynen sürer.

## 6. Ölçüm

### 6.1 UTM şeması (öneri)
`https://hupolingo.com/demo?utm_source={instagram|youtube|linkedin}&utm_medium=organic_social&utm_campaign={sm-YYYY-MM-hN}&utm_content={gonderi_kodu}`
- Instagram caption'da bağlantı tıklanmaz: **bio linki** tek (`utm_content=bio`), story'de bağlantı sticker'ı gönderi başına (`utm_content=s-g06`). Reel/post bazında doğru atıf bu yüzden **sınırlı**; gönderi bazlı öğrenme için platform içi metrik (kaydetme/paylaşım/profil ziyareti) kullanılır.
- YouTube: açıklama alanına UTM'li bağlantı (tıklanır).
- `utm_term` kullanılmaz; kişisel bilgi/çocuk/okul bilgisi UTM'ye yazılmaz.

### 6.2 Olay planı (mevcut olaylarla; yeni olay yok)
`hero_cta_tiklandi` → `demo_tamamlandi` → `veli_kayit_baslatildi` → (sunucu) hesap/ödeme olayları. **GÜNCEL (2026-10-29, K-0199): UTM olay özellikleri uygulandı.** `hero_cta_tiklandi`, `demo_tamamlandi`, `veli_kayit_baslatildi`, `fiyat_tiklandi` ve `$pageview` olaylarına `utm_source`, `utm_medium`, `utm_campaign`, `utm_content` eklenir (`web-panel/src/lib/analytics/utm.ts`; taksonomi satırı `OLAY_TAKSONOMISI.md` §2). Kural: URL'den yalnız bellekte yakalanır, rıza öncesi hiçbir depoya yazılmaz, "Kabul et" sonrası oturum kapsamlı `sessionStorage`, oturumda ilk değer korunur. Sınırlar: (1) onay vermeyen ziyaretçi hiç görünmez; (2) sekme kapanınca ilk temas kaybolur (kalıcı çerez/localStorage bilerek yok); (3) tam sayfa yenilemede URL'de UTM yoksa bellek boşalır, oturum deposu ise rıza varsa korur. **Hane/kaynak kaydı henüz yok** (migration + RPC gerekir): ana oturum kararı, öneri `decisions.md` "Hane/kaynak kaydı için öneri" satırında.

### 6.3 KPI (baseline yok; hedef rakam verilmez)
| Seviye | Metrik | Not |
|---|---|---|
| Keşif | Erişim, izlenme, profil ziyareti | Platform içi |
| Kalite | Kaydetme + paylaşım / erişim | "Faydalı" sinyali; en güvenilir erken gösterge (Hipotez) |
| Trafik | UTM'li oturum, bağlantı tıkı | Rıza şartı; onay vermeyen ziyaretçi görünmez (eksik sayım) |
| Aktivasyon | Sosyal kaynaklı `demo_tamamlandi` | Ana metrik adayı |
| Koruma | Şikâyet/olumsuz yorum, takipten çıkma, gizlilik/çocuk verisi sorusu | Artarsa duraklat |

Raporlama: Pazartesi, tek sayfa; veri azsa (<5) "yetersiz" yazılır; kanal bazlı CAC **hesaplanmaz** (karar 2026-10-28 kriteri).

## 7. Moderasyon ve yanıt kuralları
- Yorum yanıtı süresi: iş günü içinde (insan). Şablonlar yalnız insan onaylı.
- Çocuk bilgisi (ad, okul, fotoğraf) paylaşan yorum: yanıtta tekrar etme, gizle/sil, DM'de "bu bilgiyi paylaşmayın" notu.
- Fiyat/deneme/iade sorusu: "Plan ve fiyat bilgisi netleştiğinde hupolingo.com'da yayınlanacak" (kanıtlanana kadar; tarih sözü yok).
- Hukuki/güvenlik şikâyeti (KVKK, veri): ana oturuma yönlendir; ihlal prosedürü `docs/hukuk/VERI_IHLALI_PROSEDURU.md`.
- Destek e-postası: `iletisim@hupolingo.com` yalnız yer tutucu (decisions 2026-10-16); doğrulanana kadar yanıtlarda e-posta verme.

## 8. Uygulama fazları
| Faz | İçerik | Kod | Dış etki |
|---|---|---|---|
| 0 | Bu plan + 2 haftalık paket; P0 site düzeltmeleri; hesap sahipliği teyidi | Yok | Yok |
| 1 | Manuel yayın (platform zamanlayıcısı), dosya takvimi, sosyal_lint betiği | Küçük betik | Sahip onaylı yayın |
| 2 | ~~UTM olay özellikleri~~ (yapıldı, K-0199) + hane kaynağı + `growth_sosyal_metrik` manuel giriş | Migration + panel (ana oturum, onaylı) | Yok |
| 3 | 4 haftalık inceleme → kanal/format kararı | — | — |
| 4 | (ancak veri varsa) ücretli test planı; yalnız ayrı onay | — | Harcama |

**Durdurma koşulu:** 4 hafta sonunda kaydetme/paylaşım zayıf ve UTM'li demo tamamlama sıfıra yakınsa Instagram'ı küçült, içeriği SEO/e-posta rehberine kaydır. (Yüzdelik hedef verilmez.)

## 9. Açık kararlar
Bu belgenin sonundaki liste `AÇIK_KARARLAR.md` yerine `ICERIK_PAKETI_2_HAFTA.md` sonundaki "Açık kararlar" bölümünde birleştirilmiştir.

## 10. Hesap açılış kontrol listesi (T0 öncesi ve sırasında)

Hesaplar henüz yok. **Footer'daki `instagram.com/hupolingo`, `youtube.com/@hupolingo`, `linkedin.com/company/hupolingo` bağlantıları (`web-panel/src/components/landing/Footer.tsx`) hesaplar açılıp doğrulanana kadar çalışmıyor sayılır.** Bu sürede ya footer'dan kaldırılır ya da hesaplar açılınca doğrulanır; **trafik yönlendirilmeden önce** üç bağlantı da tıklanıp gerçek hesaba gittiği görülmelidir. Hesap kullanıcı adı farklı çıkarsa Footer, bio, e-posta imzası ve bu belge birlikte güncellenir. Hesabı açma ve ödeme/telefon doğrulaması **proje sahibinin** işidir (kimlik doğrulama, dış hesap).

| # | Adım | Ayrıntı | Doğrulama | Sahibi | Durum |
|---|---|---|---|---|---|
| 1 | **Kullanıcı adı tutarlılığı** | Hedef: üç kanalda aynı ad (`hupolingo`). Önce üçünün de boş olup olmadığı kontrol edilir (kayıt sayfasında). Biri doluysa tüm kanallarda aynı alternatif seçilir (örnek `hupolingo.tr`, yalnız üçünde de boşsa); biri başka addaysa tutarsızlık yerine ortak ad bulunur. Marka adı yazımı: "Hupolingo" | Üç profil adresi tarayıcıda açılır, aynı adı gösterir | Proje sahibi | Açık |
| 2 | **İşletme/şirket hesabı** | Instagram: "Profesyonel hesap" (İşletme veya İçerik üretici değil; eğitim kategorisi) + Meta Business Suite bağlantısı. YouTube: **marka hesabı** (kişisel Google kanalı değil), yönetici en az 2 kişi. LinkedIn: şirket sayfası, sayfa yöneticisi kişisel profilden atanır. Şirket unvanı/MERSİS/adres hukuk kayıtları tamamlanmadan sayfada resmi şirket bilgisi yazılmaz (`ILETISIM_EKSIKLERI_PLANI`, K-0196 açık maddeler) | Hesap türü ayarlarında "Professional/Business/Brand" görünür | Proje sahibi | Açık |
| 3 | **Biyografi taslağı** | Instagram (≈150 karakter): "Hupolingo · Hupo ile kısa soru çalışmaları / Veliler: ilerleyişi ve tekrar konularını görün / Pilot sürüm, garanti vermeyiz" + bağlantı. YouTube kanal açıklaması: aynı ilk iki satır + "Çocuklar için değil, velilere yöneliktir" notu. LinkedIn: tek paragraf, "Hupolingo, Türkçe soru çalışması ve veli raporu üzerine kurulu bir eğitim teknolojisi girişimidir (pilot)". **Yasak:** "indir", "ücretsiz deneme", garanti, "1 numara", "resmî", okul adı, kullanıcı sayısı, "KVKK uyumlu" | `sosyal_lint` benzeri kontrol + sahip onayı | MAR-OTO-AI (metin), proje sahibi (onay) | Taslak hazır (içerik paketi §0) |
| 4 | **Bağlantı + UTM'li bio linki** | Instagram: tek bio linki `https://hupolingo.com/demo?utm_source=instagram&utm_medium=organic_social&utm_campaign=bio&utm_content=bio`. YouTube: `utm_source=youtube`...`utm_content=bio`. LinkedIn: `utm_source=linkedin&utm_medium=organic_social&utm_campaign=bio&utm_content=profil`. Link kısaltıcı/üçüncü taraf link-in-bio aracı **kullanılmaz** (takip betiği ve ek rıza yükü). Yalnızca `utm_source/medium/campaign/content` (`utm_term` yok; kişisel bilgi yok) | Linke mobilde tıkla: `/demo` açılıyor; çerez onayı verince PostHog olayında `utm_source` görülüyor (canlıda doğrulanmadı) | MAR-OTO-AI (URL), proje sahibi (yapıştırma) | Açık |
| 5 | **Güvenlik / 2FA** | Her hesapta 2FA **uygulama tabanlı** (SMS değil). Kurtarma kodları şifre yöneticisinde. Her kanal için ayrı güçlü parola. Kayıt e-postası: kişisel e-posta yerine şirket/rol e-postası (doğrulanana kadar `iletisim@hupolingo.com` yer tutucu, doğrulanmadan kayıt e-postası olarak kullanılmaz). Üçüncü taraf uygulama yetkisi (OAuth, zamanlayıcı araçları) verilmez | Her hesapta "2FA açık" ekranı görülür; çıkış yapıp giriş denenir | Proje sahibi | Açık |
| 6 | **Sahiplik ve erişim** | Hesapların hukuki ve fiilî sahibi şirket/proje sahibi olmalı; tek kişiye bağlı kalmasın: yedek yönetici (güvenilir ikinci kişi), erişim listesi dosyası **parolasız** (kimde hangi rol). Ajan/AI hesaba giriş yapmaz, parola görmez; yayın platformun kendi aracında insan eliyle. Reklam hesabı açılmaz (ücretli yok) | Rol listesi dosyası güncel; yöneticilerden biri çıkarılıp tekrar eklenebiliyor | Proje sahibi | Açık |
| 7 | **Profil görseli ve kapak** | Profil: onaylı Hupo logosu (`web-panel/public/hupo/logo-icon*.webp`); kapak: onaylı Hupo pozu. Çocuk fotoğrafı yok. Boyutlar güncel platform şartnamesinden doğrulanır | Üç kanalda mobil ve masaüstü önizlemesi gerçek ekranda görüldü | MAR-OTO-AI (brief), proje sahibi | Açık |
| 8 | **Çocuk politikası ayarları** | Instagram/YouTube: hesap "çocuklara yönelik" olarak işaretlenmez (hedef veli); YouTube'da "bu video çocuklara yönelik mi" sorusu için ürün/hedef kitle kararı ve platform politikası teyidi gerekir (yanlış işaretleme yorum/öneri özelliklerini kapatır veya politika ihlali yaratır). Yorum filtresi açık, mesaj isteği filtresi açık | Her kanalın ayar ekranı görüntüsü kayıt altında | Proje sahibi (karar), MAR-OTO-AI (kontrol) | Açık |
| 9 | **Footer bağlantılarının doğrulanması** | Hesaplar açılıp §1'deki ad netleşince `Footer.tsx` üç URL'si gerçek adreslerle karşılaştırılır; yanlış/çalışmayanlar düzeltilir veya kaldırılır. Bu **yayın öncesi** listedeki (`STRATEJI_DEGERLENDIRME.md` §0) maddedir | Footer'dan üç bağlantıya tıkla, hesap açılıyor | Proje sahibi + ana oturum (kod) | Açık |
| 10 | **Moderasyon hazırlığı** | §7 yanıt şablonları sahip onaylı; destek e-postası doğrulanmadan yorum yanıtında e-posta verilmez; sabitlenmiş yorum: "Örnek sorular resmî sınav sorusu değildir" | Şablon dosyası onaylandı | Proje sahibi | Açık |

**T0 sayılma koşulu:** 1–8 numaralı adımlar tamam. 9 numara Y'den önce kapanır.

## 11. Göreli takvim (T0 / Y)

9 Kasım başlangıç önerisi **kaldırıldı** (hesaplar yok, ürün geliştirme aşamasında). Gerekçe: hazır olmadan başlamak boş hesap veya kanıtsız vaat riski doğurur; tarih ürün ve hesap durumuna bağlı olmalıdır. Güven etiketi: Varsayım (T0+3 ısınma süresi test edilmeli).

| Gün | Ne olur | Kapı |
|---|---|---|
| T0 | Hesaplar açık, §10 adım 1–8 tamam | Sahip onayı |
| T0+0…T0+2 | Profil, biyografi, kapak; ilk 10 gönderi onayı; gerçek ekran kaydı çekimi (**gerçek ekran kaydı** = uygulama veya demo ekranının gerçek kullanım sırasında cihazdan kaydı; çizim ya da mock-up değil. Neden: sahte görsel güveni ve mağaza/Meta politikalarını zedeler) | Onay + kayıt |
| T0+3 ve sonrası | Hazır olma koşulları (içerik paketi "Takvim" maddesi) sağlanınca ilk Pazartesi = **Y** | Trafik yönlendirilen sayfada yayın öncesi liste kapalı |
| Y+0 … Y+13 | İçerik paketi (`ICERIK_PAKETI_2_HAFTA.md`), gün etiketleri Y+N | Her gönderi sahip onaylı |
| Y+14 … Y+27 | Üçüncü ve dördüncü hafta paketi (yazılmadı; ilk iki hafta verisine göre) | İlk iki hafta ölçümü |
| Y+28 | 4 haftalık inceleme (§8 Faz 3) | Karar toplantısı |

Platform zamanlayıcısı kullanılırken gerçek tarih Y'den hesaplanır ve ölçüm tablosuna yazılır.
