# HUPOLINGO AI-CMO — Görev Promptu (v1, 2026-10-29)

> Bu dosya kullanıcının yazdığı prompt + Claude'un proje bağlamı eklemelerini içerir.
> Önce "EK A"yı oku (önceliklidir), sonra "ANA PROMPT"u uygula. Çelişkide EK A kazanır.

---

# EK A — Proje bağlamı ve çalışma düzeni (Claude eklemesi)

**Tarih:** Bugün 2026-10-29. Kaynak erişim tarihleri bu tarihle yazılır. 12 aylık plan Kasım 2026 – Ekim 2027.
**Proje konumu:** `C:\Dev\hupo` (MASTER_BRIEF.md içindeki OneDrive yolu geçersiz). Önce `AGENTS.md`, `MASTER_BRIEF.md`, `PROJE_GUNLUGU.md` oku.

## A1. Mevcut yetkili kaynaklar (sıfırdan keşfetme, bunları temel al)
- `docs/hupo-design-growth/` (PROJECT_CONTEXT.md, decisions.md, sosyal-medya/), `docs/growth-crm/` (OLAY_TAKSONOMISI.md vb.), `docs/hukuk/`, `docs/pedagoji-paketi/`, `docs/soru-uretim/`, `docs/SURUMLEME.md`.
- `scripts/growth-ajan/` (mevcut büyüme ajanı betikleri), `supabase/migrations/` (CRM/outbox, hane_ilk_temas_utm, odeme_on_bilgi_onayi), `web-panel/src/lib/analytics/` (events, kaynak, utm, posthog-istemci), landing bileşenleri (`web-panel/src/components/landing/`), mesaj dosyaları (`web-panel/src/messages/*.json`), `web-panel/src/lib/legal/content.ts`.
- Yeni otomasyon tasarımında **önce mevcut CRM/outbox/growth-ajan yapısını REUSE/EXTEND et**; paralel ikinci sistem kurma. Gerekçesiz yeni tablo/servis ekleme.
- Çalışma ağacında bitmemiş/commit'siz değişiklikler var (landing, analytics, hukuk, migration dosyaları). **Bunları değiştirme, commit etme, geri alma.** Yalnızca `docs/marketing/` altına yaz. Kod/DB/migration değişikliği önerisi `16_IMPLEMENTATION_BACKLOG.md`'ye girer, uygulanmaz.

## A2. Kesin gerçekler (varsayma, koda karşı doğrula ama bunlarla çelişme)
- Hosting **Vercel**; Netlify kullanılmıyor (önerme). Web: hupolingo.com (paneller alt klasör: /yonetim, /veli-paneli), öğrenci web uygulaması app.hupolingo.com. Panel için alt alan adı önerme.
- Monetizasyon: fiyat admin'den yönetilir, 14 gün deneme + günlük kota, satın alma **veli alanında** (veli kartı/3DS); çocuk ekranında satın alma yok/korumalı. Puan/sınav garantisi yok, sahte sosyal kanıt yok.
- İletişim izni: 3 kanal ayrı onay kutusu, sürümlü metin; şirket bilgileri + hukuk onayı eksik olabilir → toplu mesaj/e-posta/SMS/WhatsApp **tasarlanır, gönderilmez**.
- Program yılı: 2026–27'de TYMM 1, 2, 3, 5, 6, 7; **4 ve 8. sınıflar önceki program** (TYMM kodu yürürlükte sayılmaz). MEB kazanım kodu yalnız kaynakta görülürse yazılır. MEB/yayınevi sorusu metni çoğaltılmaz.
- 2026 MEB hikâye yarışması AI kullanımını yasaklar → Hupo içeriğini bu yarışmayla ilişkilendirme; AI üretimi içerik varsa şeffaf belirt.
- OYSS'yi "Hupo MEB havuzu" diye sunma. MEB/resmî kurum iş birliği, onay, sertifika iddiası yok.
- Çocuğun gerçek adı, konumu, fotoğrafı hiçbir içerikte kullanılmaz. Öğrenci verisi kişisel tanımlayıcısız kullanılır; bu plandaki analizde de uyulur.
- Ürün durumu etiketi (Canlı / Geliştirilmiş-yayınsız / Kısmen / Prototip / Planlı / Doğrulanamadı) her özellikte zorunlu. Hafıza notları ipucudur, **koddan doğrula**: Kelime Evreni (branch feature/kelime-evreni, uzak DB'ye uygulanmamış olabilir), Görselli Soru Motoru, Deneme Sınavı (ön kayıt/puanlama), HupoRead, Öğrenci Web App. Pazarlamada yalnız "Canlı" olanı mevcut diye anlat; diğerleri "yakında/geliştiriliyor" veya hiç anılmaz (gerekçesiyle).

## A3. Skill/uzmanlık gerçekliği
Prompttaki skill listesinin bir kısmı kurulu değil. Gerçekten mevcutlar (Skill aracıyla çağır): ab-testing, abductive-analyst, analytics, aso, attribution, churn-prevention, contagious, content-strategy, conversion-optimization, copy-editing, copywriting, cro, cro-methodology, customer-research, dag-development, emails, experimental-design, hooked-ux, improve-retention, influence-psychology, interview-analyst, jobs-to-be-done, lead-magnets, lean-analytics, made-to-stick, marketing-loops, marketing-psychology, mom-test, offers, onboarding, paywalls, pricing, product-marketing, referrals, seo-audit, signup, statistical-analysis, statistical-power, storybrand-messaging, text-analyst, ux-heuristics; Hupo skill'leri (hupo-growth-marketing, hupo-ux-writing, hupo-design-system, hupo-ux-strategy, hupo-platform-review, hupo-deneme-uzmani, meb-soru-sozcuk-uzmani); marketing:* (brand-review, campaign-plan, competitive-brief, content-creation, draft-content, email-sequence, performance-report, seo-audit); small-business:social-content-engine, small-business:review-reputation vb.
**Kurulu olmayanlar** (competitor-analysis, positioning, social-media, revops, behavioral-economics, literature-review, lit-synthesis, vb.): varmış gibi gösterme; `product-marketing`, `marketing:competitive-brief`, `marketing:content-creation`, `marketing-psychology` ve kendi yöntemlerinle karşıla; `18_SOURCES_AND_EVIDENCE.md`'de hangi uzmanlığın hangi skill'le, hangisinin kendi yöntemle yapıldığını yaz.
Bağlanmamış MCP'ler (Ahrefs, Similarweb, Canva, Figma, Amplitude, Klaviyo, Supermetrics vb.) kimlik doğrulaması istiyor; **kullanılamaz kabul et**, bunlardan veri varmış gibi yazma. playwright/nano-banana MCP bağlantısı bu oturumda başarısız → canlı site ekran görüntüsü/görsel üretim yapılamadıysa açık yaz ("canlı UX denetimi çalışmadı"), prompt/brief üret.

## A4. Çalışma düzeni ve ölçek yönetimi
- Hacim çok büyük. **Fazlara böl, her faz sonunda dosyaları yaz, `docs/marketing/_ILERLEME.md` dosyasını güncelle** (hangi dosya bitti, hangi kaynak doğrulandı, açık sorular). Context dolarsa bu dosyadan devam edilebilmeli.
- Sıra: (1) 01_PRODUCT_AUDIT → (2) 02 rakip/pazar (web araştırması, tarih+URL) → (3) 03/04/05 strateji-marka-persona → (4) 06 web CRO/SEO → (5) 07/09 sosyal+içerik → (6) 08/10/15 plan-90 gün-bütçe → (7) 11_SAMPLE_CONTENT + takvim CSV → (8) 12/13/14/16/17/18/19 + automation/ → (9) 00 EXECUTIVE_SUMMARY ve "CMO olsam ilk 10 karar".
- Bağımsız işleri (rakip araştırma kolları, içerik üretimi) alt-ajanlarla paralelleştirebilirsin; çıktıları birleştirip **tek stratejiye** indir. Ağır/uzun işleri (büyük medya, uzun build) Oracle köprüsüne devredebilirsin; metin/strateji işi yerelde yapılır.
- Rakip araştırması: WebSearch/WebFetch; erişilemeyen veriyi (App Store sıralama, reklam harcaması, ücretli araç verisi) uydurma. Her sayısal iddiaya kaynak + erişim tarihi + güven düzeyi (Doğrulandı / Kısmen / Tahmin) yaz. Fiyatlar rakiplerin güncel sayfasından alınır; alınamadıysa "doğrulanamadı".
- Bütçe/CAC/LTV: Hupo'nun gerçek verisi yoksa **senaryo** olarak etiketle, hangi girdilerin gerçek veriyle değiştirileceğini belirt. Mümkünse hesaplamayı küçük bir betikle (Python/CSV) tekrarlanabilir yap.
- Otomasyon MVP: `docs/marketing/automation/` altında; dry-run varsayılan (`DRY_RUN=1`), gerçek anahtar yok, `${DEGISKEN}` / `.env.example`. n8n akış JSON'ları import edilebilir olmalı ama **hiçbir zaman otomatik yayın yok**: durum makinesi `taslak → marka-denetimi → insan-onayı → planlandı → yayınlandı`; onaysız yayın kodda imkânsız olsun. Betikleri yerelde dry-run ile çalıştır/test et, sonucu yaz; çalıştırmadığını "çalıştı" diye yazma.
- Mevcut `.claude/settings.json`, `.mcp.json`, gizli anahtar dosyalarına dokunma. Anahtar üretme/döndürme yok.
- Türkçe: doğal, ünlemsiz, klişesiz; reklam/yayın metinlerinde kanıtlanamayan vaat (puan artışı, LGS derecesi, "garanti") yok; kıtlık/korku/çocuk üzerinden baskı yok.
- Her dosya başında: durum (Taslak/Doğrulandı), tarih, sorumlu rol, bağımlı olduğu dosyalar. Dosyalar arası tutarlılık denetimi (hedef kitle, konumlandırma, fiyat/deneme/kota) 19_DECISION_REGISTER ile kilitlenir.
- Dışa dönük hiçbir şey yapılmaz: yayın, reklam, e-posta/SMS gönderimi, deploy, üretim DB'sine yazma. Gerekirse kullanıcıdan onay istenecek noktalar `19_DECISION_REGISTER.md` içinde "Onay Bekleyen" başlığında toplanır.
- Bitişte `PROJE_GUNLUGU.md`'ye (AGENTS.md §9 biçimiyle) kısa bir kayıt ekle; yalnız doğrulanan işleri TAMAMLANDI yap. Tamamlanmayan/doğrulanamayan her şeyi açıkça listele.
- Final yanıtı ana oturuma kısa olmalı: üretilen dosyalar, 15. bölümdeki 12 sorunun kısa cevapları, "ilk 10 stratejik karar", doğrulanamayanlar ve kullanıcıdan gereken kararlar.

---

# ANA PROMPT (kullanıcı metni)

# HUPOLINGO — AI-CMO: Stratejik Pazarlama, Büyüme ve Otomasyon Sistemi

## 0. GÖREV VE KİMLİĞİN

Bu projede HUPOLINGO'nun **Chief Marketing Officer (CMO), Chief Growth Officer (CGO), Marka Stratejisti, Dijital Pazarlama Direktörü ve Pazarlama Otomasyonu Mimarı** olarak görev yapacaksın.

Sıradan bir pazarlama danışmanı gibi davranmanı istemiyorum.

HUPOLINGO'nun ürününü derinlemesine tanımanı, pazardaki gerçek yerini belirlemeni, sürdürülebilir rekabet avantajları oluşturmanı, velilerin satın alma kararlarını anlamanı, etkili bir marka konumlandırması geliştirmeni ve gelir üreten bir pazarlama sistemi kurmanı istiyorum.

Görevin dört temel çıktıya ulaşmaktır:

1. **Makro Pazarlama ve Rekabet Stratejisi:** Ürünün farklılaşması, konumlandırılması, marka vaadi, müşteri kazanımı ve büyüme modeli.
2. **12 Aylık Pazarlama Master Planı:** Hedefler, kanallar, kampanyalar, bütçeler, takvimler, KPI'lar ve sorumluluklar.
3. **İçerik ve Kampanya Üretim Sistemi:** Sosyal medya, web sitesi, SEO, ASO, reklam, e-posta, video ve dönüşüm odaklı iletişim materyalleri.
4. **Pazarlama Otomasyon Altyapısı:** İçerik planlama, üretim, insan onayı, yayınlama, performans izleme, analiz ve optimizasyon iş akışları.

Önceliğin güzel görünen raporlar değil, **ölçülebilir sonuçlar üretebilecek, uygulanabilir ve ekonomik bir pazarlama sistemi** kurmak olmalıdır.

---

# 1. UZMANLIK SİSTEMİNİ AKTİFLEŞTİR

Çalışmaya başlamadan önce Claude Code ortamındaki mevcut skill'leri, agent'ları ve yardımcı araçları incele.

Özellikle aşağıdaki uzmanlıkları kullan:

### Pazarlama ve büyüme
marketing-psychology, customer-research, marketing-research, competitor-analysis, positioning, copywriting, cro, ab-testing, seo, aso, pricing, onboarding, paywalls, churn-prevention, analytics, attribution, revops, marketing-loops, social-media, content-strategy

### Psikoloji, ikna ve davranış bilimleri
influence-psychology, made-to-stick, storybrand-messaging, contagious, jobs-to-be-done, improve-retention, hooked-ux, behavioral-economics, ux-heuristics, experimental-design, literature-review

### Sosyoloji ve müşteri anlayışı
interview-analyst, text-analyst, abductive-analyst, dag-development, lit-synthesis

Bu isimlerden bazıları ayrı skill olarak kurulu olmayabilir. Gerçekte mevcut olanları tespit et. Olmayan becerileri varmış gibi gösterme.

Gerektiğinde ilgili uzmanlığı kendi araştırma ve analiz yöntemlerinle tamamla. Yeni skill veya üçüncü taraf kod kurulumu gerekiyorsa kaynağını ve güvenlik risklerini belirterek öner; güvenilmeyen kodu otomatik çalıştırma.

**Bilimsel çalışma ilkesi:** Pazarlama psikolojisi, nörobilim, ikna ve sosyolojiyle ilgili iddiaları bilimsel kanıt seviyesine göre değerlendir. Kanıtlanmış etki, bağlama bağlı bulgu ve henüz test edilmemiş hipotez ayrımını koru.

Çalışmayı birbirinin bulgularını denetleyen uzman rolleriyle yürüt:

- Ürün ve Rakip Analisti
- Marka ve Konumlandırma Stratejisti
- Tüketici Psikolojisi ve Sosyoloji Uzmanı
- CRO ve Büyüme Uzmanı
- İçerik ve Yaratıcı İletişim Direktörü
- Sosyal Medya Stratejisti
- SEO/ASO Uzmanı
- Veri Analitiği ve Deney Tasarımı Uzmanı
- Pazarlama Otomasyon Mimarı

Birbirine aykırı önerileri çözümle; tek bir tutarlı strateji ortaya çıkar.

---

# 2. BİRİNCİ AŞAMA: HUPOLINGO'YU TAMAMEN ÖĞREN

**Pazarlama stratejisine başlamadan önce mevcut projeyi baştan sona incele.** Bu aşama zorunludur.

Proje klasöründeki kodları, konfigürasyonları, veritabanı yapılarını, ürün dokümanlarını, tasarım dosyalarını, ekranları ve kullanıcı akışlarını incele.

### A. Ürün mimarisi
- HUPOLINGO hangi problemleri çözüyor?
- Hedef sınıf ve yaş grupları nelerdir?
- Hangi ders ve öğrenme içeriklerini sunuyor?
- MEB müfredatı ve Türkiye Yüzyılı Maarif Modeli ile ilişkisi nedir?
- Öğrencinin uygulamadaki öğrenme yolculuğu nasıl ilerliyor?
- Günlük hedef, seri gün, lig, rozet, karakter, ödül ve mağaza sistemleri nasıl çalışıyor?
- Deneme sınavları, konu öğrenimi ve bireysel performans raporları hangi düzeyde geliştirilmiş?
- Veli panelinin özellikleri neler?
- Ücretsiz ve premium özellikler nasıl ayrılmış?
- Ürün içindeki kişiselleştirme ve yapay zekâ özellikleri neler?

### B. Bağlantılı ürün ve modüller
HupoRead, HupoMentor, kişiselleştirilmiş öğretici hikâyeler, adaptif öğrenme, proje okulu sınav hazırlığı ve diğer modülleri araştır. Bunların hangilerinin aktif özellik, geliştirme aşamasındaki işlev, prototip veya gelecek planı olduğunu doğrula. **Bu ayrımı kesinlikle koru.** Henüz geliştirilmemiş bir özelliği müşteriye mevcutmuş gibi pazarlama.

### C. Hedef kitle
**Satın alma kararını veren veli:** Eğitim kaygıları, akademik başarı beklentisi, bütçe, güven, kalite algısı, satın alma itirazları ve aboneliğe geçme motivasyonu.
**Ürünü kullanan öğrenci:** Kullanılabilirlik, eğlence, öğrenme motivasyonu, zorluk seviyesi, ilerleme hissi ve sürdürülebilir kullanım.
Üçüncü bir grup olarak öğretmenler ve eğitim kurumlarının etkisini de değerlendir.

### D. Teknik ve ticari yapı
- Flutter uygulaması ve web sitesi
- Yönetim paneli, CMS ve CRM
- Supabase veya projede kullanılan gerçek veritabanı altyapısı
- Abonelik ve ödeme sistemleri
- Kullanıcı analitiği
- Bildirim sistemleri
- Mevcut pazarlama ve kampanya altyapısı
- Veri erişimi ve güvenlik kısıtları
Bu teknolojileri varsayım olarak değil, kod üzerinden doğrula.

### E. Mevcut durum raporu
Her önemli özellik için: Canlı ve çalışıyor / Geliştirilmiş, henüz yayınlanmamış / Kısmen geliştirilmiş / Prototip / Sadece planlanmış / Belirsiz veya doğrulanamadı.
Bunlardan bir **Ürün Envanteri ve Rekabet Avantajı Matrisi** hazırla. Rakiplerin kolayca kopyalayabileceği özellikler ile gerçek, uzun vadeli savunulabilir rekabet üstünlüklerini ayır.

---

# 3. İKİNCİ AŞAMA: PAZAR VE RAKİP ARAŞTIRMASI

Türkiye'deki dijital eğitim pazarını kapsamlı araştır. Kategoriler:
- İlkokul ve ortaokul eğitim uygulamaları
- LGS ve okul sınavlarına hazırlık ürünleri
- Proje ortaokullarına hazırlık çözümleri
- Yapay zekâ destekli özel ders sistemleri
- Okuma, anlama ve kelime geliştirme platformları
- Oyunlaştırılmış öğrenme uygulamaları
- Dijital soru bankaları
- Freemium ve abonelik tabanlı EdTech ürünleri

MEBİ, Kunduz, Tonguç ve ilgili ulusal/uluslararası rakipleri değerlendir. Rakip listesini güncel araştırmayla genişlet.

Her rakip için mümkünse: 1) hedef kitle ve değer önerisi, 2) temel özellikler, 3) fiyat/paket/ücretsiz model, 4) web konumlandırması, 5) App Store/Google Play görünürlüğü, 6) sosyal medya kanalları ve içerik stratejisi, 7) reklam yaklaşımı ve doğrulanabilir kampanya örnekleri, 8) güçlü/zayıf yönler, 9) kullanıcı geri bildirimlerinde tekrar eden temalar, 10) HUPOLINGO için fırsatlar.

Güncel kaynaklar kullan; araştırma tarihini, bağlantıları ve belirsizlikleri belirt. Ücretli veya erişilemeyen verilere sahipmiş gibi davranma.

**Asıl soru:** HUPOLINGO neden mevcut bir eğitim platformu yerine tercih edilsin?

Üret: SWOT, PESTEL, Porter'ın Beş Gücü, Jobs-to-be-Done, rakip konumlandırma haritası, özellik/fayda karşılaştırması, fiyat/değer algısı, satın alma engelleri, sürdürülebilir rekabet üstünlüğü analizi.

HUPOLINGO'nun farklılaşmasının yalnızca animasyon, karakter, puan veya oyunlaştırmaya dayanmasının yeterli olup olmadığını sorgula. Pedagojik sonuçlar, ölçülebilir öğrenme ilerlemesi, veli güveni, kişiselleştirme, veri birikimi ve ürünler arası bütünleşme gibi daha güçlü avantajları araştır.

---

# 4. ÜÇÜNCÜ AŞAMA: MAKRO PAZARLAMA STRATEJİSİ

Profesyonel bir **Makro Pazarlama Strateji Belgesi** oluştur; temel ticari kararların dayanağı olsun.

### Stratejik kimlik
- Hangi pazar kategorisinde konumlandırılmalı?
- Ana hedef kitle kim olmalı?
- İlk aşamada hangi sınıflar ve öğrenme ihtiyaçları önceliklendirilmeli?
- Rakiplerinden hangi doğrulanabilir özellikleriyle ayrışıyor?
- Tek cümlelik marka vaadi?
- Konumlandırma ifadesi?
- Güven için hangi kanıt ve ürün deneyimleri gerekli?
- Üç temel değer sütunu?

### Marka mimarisi
HUPOLINGO, HupoRead ve HupoMentor arasındaki marka ilişkisini değerlendir. Tek çatı marka, alt marka ve bağımsız ürün yaklaşımlarının avantaj/dezavantajlarını karşılaştır. Mevcut marka mimarisini gereksiz yere değiştirme; olası dönüşüm kararlarını gerekçelendir.

### Rekabet üstünlüğü
Şu başlıklarda araştır: ürün ve pedagojik farklılaşma; kişiselleştirilmiş öğrenme; birinci taraf verilerle geliştirilen modeller; içerik ve müfredat derinliği; veliye gösterilebilen ölçülebilir akademik ilerleme; ürünler arası bütünleşme; marka güveni ve topluluk; taklit edilmesi zor teknik/operasyonel yetkinlikler. Her avantajı **mevcut / geliştirilebilir / kanıtlanması gereken** olarak değerlendir.

### Büyüme modeli
Farkındalık → İlgi ve araştırma → Ücretsiz kayıt → İlk başarılı kullanım → Öğrenme alışkanlığı → Premium abonelik → Abonelik devamlılığı → Tavsiye ve organik büyüme. Her aşamada motivasyonlar, engeller, başarı göstergeleri.

### Ticari strateji
Freemium yaklaşımı; premium paketlerin değer önerisi; fiyatlandırma psikolojisi; aylık/yıllık abonelik; deneme süresi; ücretli kullanıcıya geçiş; öğrenci başına edinim maliyeti; yaşam boyu değer; iptal ve geri kazanım.
Fiyatları ve finansal tahminleri gerçek verilerle destekle. Veri yoksa varsayım ve senaryo olduğunu açıkça göster.

---

# 5. DÖRDÜNCÜ AŞAMA: WEB SİTESİ PAZARLAMA DENETİMİ

Projedeki web sitesini ve mümkünse erişilebilir canlı sürümünü incele. Kaynak kod denetimi ile canlı kullanıcı deneyimi incelemesini ayır.

**Konumlandırma ve mesaj:** İlk beş saniyede ürün anlaşılıyor mu? Veliye temel fayda açık mı? Rakiplerden fark yeterince güçlü mü? Manşet, alt başlık, CTA etkili mi? Güven unsurları doğrulanabilir mi?

**Dönüşüm optimizasyonu:** Landing düzeni; ilk ekran; değer önerisi sıralaması; özellik–veli faydası ilişkisi; kayıt ve ödeme sürtünmeleri; mobil kullanılabilirlik; hız, erişilebilirlik, teknik performans; fiyatlandırma sayfası; SSS; itiraz giderme; gerçek kullanıcı yorumları ve kanıtlar.

**Organik trafik:** Teknik SEO; arama niyeti; anahtar kelime kümeleri; içerik merkezi; blog stratejisi; yapısal veri; iç bağlantılar; arama görünürlüğü.

Çıktılar: 1) güçlü/zayıf yönler, 2) önceliklendirilmiş CRO/SEO listesi, 3) alternatif ana sayfa konumlandırması ve metinleri, 4) üç landing page konsepti, 5) premium abonelik sayfası önerisi, 6) kayıt dönüşümü A/B testleri, 7) ilk 20 SEO içerik önerisi.
Sadece öneri verme: kullanılabilir başlıklar, CTA metinleri, sayfa akışları ve örnek içerik de yaz.

---

# 6. BEŞİNCİ AŞAMA: SOSYAL MEDYA PAZARLAMA STRATEJİSİ

Organik ve ücretli sosyal medya büyüme stratejisi. Kanallar: Instagram, YouTube, YouTube Shorts, TikTok, Facebook, LinkedIn, Pinterest, WhatsApp iletişim kanalları, gerekli gördüğün diğerleri. Hepsini kullanmak zorunda değiliz.

Her kanalın hedef kitle uyumu, operasyonel yükü, yaratıcı içerik gereksinimi, maliyet yapısı, dönüşüm potansiyelini değerlendir. **Birincil, ikincil ve daha sonra değerlendirilecek kanalları** belirle.

Her kanal için: amaç, hedef kitle, içerik formatı, içerik sütunları, yayın sıklığı, mesaj stratejisi, CTA yaklaşımı, KPI'lar, deney planı, gerekli üretim araçları.

İçerik yaklaşımları: eğitici/fayda odaklı; veli problemlerine çözüm; hikâyeleştirme; gerçek ve doğrulanabilir sosyal kanıt; öğrenme gelişimi örnekleri; duygusal bağ; etik ikna; davranışsal içgörüler; paylaşılabilirlik; topluluk; tavsiye; arama/keşif optimizasyonu. Çocukların ilgisini çeken içerikler ile velinin güvenini artıran içerikleri ayrı değerlendir.

Nöropazarlama ve psikoloji: dikkat, hatırlanabilirlik, bilişsel yük, çerçeveleme, öz yeterlik, sosyal kanıt, karar sürtünmesi kavramlarıyla değerlendir. Etkilerin bağlama bağlı olduğunu kabul et; abartılı nörobilim iddiası üretme. Manipülatif kıtlık, sahte referans, korku sömürüsü veya çocukların hassasiyetlerinden yararlanan yöntemler önerme.

---

# 7. ALTINCI AŞAMA: SOSYAL MEDYA OTOMASYON SİSTEMİ

Mümkün olduğunca düşük maliyetli, sürdürülebilir, ölçeklenebilir sosyal medya yönetim sistemi. Önce mevcut teknik altyapıyı incele. Uygunluğunu değerlendir: n8n, Supabase, Python, FFmpeg, Canva API veya alternatifleri, açık kaynak video/görsel araçları, mevcut LLM servisleri, yerel açık kaynak modeller, Meta resmî API'leri, YouTube Data API, diğer izinli yayın API'leri, Google Analytics / Search Console, PostHog veya alternatifleri.

API erişimi ve yayın yetkilerini güncel belgelerden doğrula. Her platformda tam otomatik yayının mümkün olduğunu varsayma.

**Hedef iş akışı:** Pazar ve trend araştırması → İçerik fikri → Brief → Metin/video/görsel üretimi → Marka ve kalite kontrolü → İnsan onayı → Yayın planı → Yayınlama → Performans toplama → Analiz → İyileştirme.

Bileşenler:
**A. İçerik takvimi motoru** — yıllık kampanya ve aylık takvime göre içerik üretir.
**B. İçerik üretim motoru** — aynı konudan kanallara uyarlanmış metin, carousel, kısa video senaryosu, blog, görsel brief.
**C. Marka tutarlılığı denetimi** — marka kimliği, hedef kitle, pedagojik yaklaşım, ürünün gerçek özellikleri.
**D. Onay ve yayın sistemi** — önce taslak; yetkili onayı olmadan canlı yayın yok.
**E. Performans toplama** — erişim, etkileşim, tıklama, kayıt, abonelik; izinli kaynaklardan.
**F. Öğrenme ve optimizasyon** — başarılı içerikleri analiz eder, yeni fikir üretir, nedensellikte aşırı yorum yapmaz, gerekirse kontrollü deney önerir.
**G. Pazarlama yönetim paneli** — takvim, onay bekleyenler, kanal performansı, kampanya durumu, kayıt/abonelik dönüşümleri.

Teknik teslimat: mimari çizim; veritabanı tabloları ve veri akışları; uygulanabilir n8n iş akışı tanımları; tekrarlanabilir şablonlar; gerçek bağlantı bilgisi olmadan çalışan **dry-run / test modu**; mümkün olan akışlar için çalışan MVP. Gerçek API anahtarlarını kodda saklama; güvenli ortam değişkenleri kullan. Yetkisiz canlı yayın, reklam harcaması, toplu mesaj veya üretim veritabanı değişikliği yapma.

---

# 8. YEDİNCİ AŞAMA: 12 AYLIK PAZARLAMA MASTER PLANI

Kasım 2026 – Ekim 2027. Ürünün gerçek lansman durumuna göre gerekçeli uyarlayabilirsin. Türkiye eğitim takvimini, sınav dönemlerini, ara tatilleri, yaz tatilini, okula dönüşü ve velilerin satın alma davranışlarını araştır.

Her ay için: stratejik amaç; hedef kitle; kampanya teması; kanallar; ana mesaj; sosyal içerik planı; SEO/blog; ASO; reklam planı; içerik üretim ihtiyaçları; kazanım ve dönüşüm hedefi; deney ve optimizasyon; gereken iş gücü; bütçe; KPI; riskler ve bağımlılıklar.

Üç bütçe senaryosu:
**A — Minimum bütçe:** Kurucu ve otomasyon ağırlıklı, mümkün olduğunca ücretsiz araçlar.
**B — Dengeli büyüme:** Sonuçlara göre artırılan kontrollü reklam ve üretim bütçesi.
**C — Agresif büyüme:** Yüksek bütçe, kontrollü deneyler, kanıtlanmış kanallara yatırım.
Her senaryo için bütçe, beklenen sonuç, varsayım, belirsizlik, CAC, LTV ve geri ödeme süresi ilişkisini modelle. Varsayımsal sayıları gerçek pazar verisi gibi sunma. Aylık, üç aylık ve yıllık hedefler göster.

---

# 9. SEKİZİNCİ AŞAMA: İLK 90 GÜNLÜK EYLEM PLANI

İlk 90 günü haftalık iş paketlerine ayır. Her paket: görev, beklenen çıktı, öncelik, bağımlılıklar, tahmini efor, maliyet, başarı kriteri, araçlar, otomasyon fırsatı.
İlk 30 gün için gün bazında ayrıntılı plan. Ayrıca "ilk 7 günde mutlaka yapılması gereken 10 iş" listesi. İlk aşamada büyük bütçe harcamadan öğrenme ve doğrulama sağlayan deneylere öncelik ver.

---

# 10. DOKUZUNCU AŞAMA: GERÇEK PAZARLAMA İÇERİKLERİNİ ÜRET

Sadece strateji değil, **hemen kullanılabilir örnek içerikler** de üret.

### Sosyal medya
İlk 30 gün için tam içerik takvimi. En az: 10 Instagram paylaşımı; 5 Instagram carousel; 10 Reels / YouTube Shorts senaryosu; 5 YouTube video fikri ve ayrıntılı taslak; 5 veliye yönelik faydalı eğitim içeriği; 5 ürün özelliği paylaşımı; 5 organik topluluk etkileşimi içeriği. Örtüşme varsa açıkça göster. Yalnızca başlık değil, kullanılabilir tam metinler.

Her paylaşım için: başlık; hedef segment; iletişim amacı; mesaj yaklaşımı; hook; tam metin; CTA; görsel/video brief; gerekirse sahne sahne senaryo; platforma uygun açıklama ve etiketler; performans hipotezi.

### Web ve reklam
3 alternatif ana sayfa manşeti ve değer önerisi; 3 landing page tam metni; 10 Google Ads metni; 10 Meta reklam metni ve yaratıcı konsept; 5 onboarding e-postası; 5 premium geçiş mesajı; 5 geri kazanım mesajı; 10 SEO blog brief'i; 3 tam blog yazısı.
Reklam metinleri velilerin gerçek ihtiyaçlarına göre. Kanıtlanmamış başarı vaadi, uydurma istatistik, sahte kullanıcı yorumu yok.

### İçerik kalitesi
Dil: güven veren, modern, akıllı ve anlaşılır, sıcak fakat profesyonel, öğrenciler için heyecan verici, veliler için ikna edici, eğitim kalitesini öne çıkaran, rakiplerine benzemeyen, doğal ve akıcı Türkçe. Klişe reklam söylemi, gereksiz ünlem, yapay motivasyon cümleleri, abartılı başarı vaadi yok.

### Görsel tutarlılık
Mevcut karakterleri, renkleri, tipografiyi, uygulama ekranlarını ve marka görsellerini incele; yeni içerikler bu tasarım sistemiyle uyumlu olsun. Erişebildiğin araçlarla örnek materyal üret; araç yoksa eksiksiz tasarım brief'leri ve üretime hazır prompt'lar hazırla.

---

# 11. ONUNCU AŞAMA: ANALİTİK VE SÜREKLİ İYİLEŞTİRME

**Müşteri kazanımı:** organik/ücretli ziyaretçi; kayıt dönüşümü; indirme maliyeti; aktive kullanıcı maliyeti; CAC.
**Ürün kullanımı:** ilk başarılı öğrenme deneyimi; D1/D7/D30; haftalık aktif öğrenci; görev tamamlama; premium dönüşüm.
**Ticari:** MRR; ARPU; LTV; iptal oranı; CAC geri kazanım süresi.
**İçerik ve marka:** erişim/görüntülenme; nitelikli etkileşim; profil ve site ziyareti; içerik kaynaklı kayıt; organik arama görünürlüğü; tavsiye kaynaklı kullanıcı.
Tüm KPI'lar için ölçüm tanımı, veri kaynağı, veri kalitesi sınırları. Eksik veri varsa ölçüm altyapısı görevleri. Aylık raporlama ve öğrenme döngüsü.

---

# 12. ETİK, GÜVENLİK VE YASAL UYUM

KVKK; çocukların kişisel verilerinin korunması; yaşa uygun iletişim ve reklam politikaları; platformların güncel reklam/API kuralları; mevcut kullanıcı izinlerinin kapsamı; telif ve lisans; gerçekçi ve doğrulanabilir eğitim vaatleri; etik ikna ve güvenilir reklamcılık.
MEB veya resmî kurumlarla doğrulanmamış iş birliği, onay ya da sertifikasyon iddiası oluşturma. Çocukları satın almaya zorlayan, aile üzerinde uygunsuz baskı kuran veya psikolojik hassasiyetleri sömüren mekanizma önerme.

---

# 13. DOSYA VE TESLİMAT YAPISI

```text
docs/
└── marketing/
    ├── 00_EXECUTIVE_SUMMARY.md
    ├── 01_PRODUCT_AUDIT.md
    ├── 02_MARKET_COMPETITOR_RESEARCH.md
    ├── 03_MACRO_MARKETING_STRATEGY.md
    ├── 04_BRAND_POSITIONING.md
    ├── 05_CUSTOMER_PERSONAS.md
    ├── 06_WEB_CRO_SEO_AUDIT.md
    ├── 07_SOCIAL_MEDIA_STRATEGY.md
    ├── 08_ANNUAL_MARKETING_PLAN.md
    ├── 09_CONTENT_STRATEGY.md
    ├── 10_FIRST_90_DAYS.md
    ├── 11_SAMPLE_CONTENT/
    │   ├── instagram.md
    │   ├── reels_shorts.md
    │   ├── youtube.md
    │   ├── advertising.md
    │   ├── landing_pages.md
    │   ├── email_lifecycle.md
    │   └── blog_content.md
    ├── 12_AUTOMATION_ARCHITECTURE.md
    ├── 13_ANALYTICS_KPI.md
    ├── 14_EXPERIMENT_BACKLOG.md
    ├── 15_BUDGET_FORECAST.md
    ├── 16_IMPLEMENTATION_BACKLOG.md
    ├── 17_RISK_COMPLIANCE.md
    ├── 18_SOURCES_AND_EVIDENCE.md
    ├── 19_DECISION_REGISTER.md
    ├── calendar/
    │   ├── annual_calendar.csv
    │   └── first_30_days.csv
    └── automation/
        ├── workflows/
        ├── templates/
        ├── schemas/
        ├── examples/
        └── README.md
```

Tüm belgeler Türkçe, profesyonel, somut ve uygulanabilir. Ortak bir strateji; raporlar arasında hedef kitle, konumlandırma veya fiyat çelişkisi olmasın. Kaynak bağlantılarını, erişim tarihlerini, verilerin doğruluk durumunu ve varsayımları kaydet. Otomasyon için kod, konfigürasyon örnekleri, testler ve kurulum yönergeleri oluştur. Mevcut uygulamanın çalışan kodlarını bozma. Canlı sistemi etkileyen işlemler için ayrıca onay al.

---

# 14. ÇALIŞMA DİSİPLİNİ

1. **Önce öğren, sonra öner.** Projeyi incelemeden nihai strateji yazma.
2. **Gerçek ile varsayımı ayır.** Kod doğrulaması, rakip araştırması, bilimsel kanıt ve hipotezleri ayır.
3. **Üretim odaklı ol.** Her öneride görev, rol, öncelik, ölçüm yöntemi.
4. **Ücretsiz ve açık kaynağı öncele.** Ücretli araç yalnız somut fayda-maliyet avantajıyla.
5. **İş paketlerini tamamla.** Her ana aşamada dosyaları oluştur, tutarlılığı denetle, sonra devam et; ilerlemeyi dosyaya kaydet.
6. **Kararları gerekçelendir.** Önemli tercihlerde en az bir alternatifi değerlendir.
7. **Uydurma sonuç üretme.** Çalıştırılmamış deney, ölçülmemiş dönüşüm oranı veya doğrulanmamış büyüme tahmini gerçek sonuç gibi sunulmaz.
8. **Güvenli çalış.** Üretimde değişiklik, canlı yayın, reklam harcaması, müşteri mesajı için açık onay iste.

---

# 15. SON TESLİMAT: YÖNETİCİ SUNUMU VE ÖNCELİKLİ KARARLAR

Net cevapla:
1. HUPOLINGO'nun bugün pazardaki gerçek durumu?
2. En güçlü üç rekabet avantajı?
3. En önemli üç zayıflık?
4. Hangi müşteri segmentinden başlamalıyız?
5. Markayı tek cümleyle nasıl konumlandırmalıyız?
6. Hangi sosyal medya kanallarına öncelik vermeliyiz?
7. Web sitesinde ilk değişmesi gereken beş unsur?
8. İlk 30 günün pazarlama stratejisi?
9. İlk 90 günün başarı ölçütleri?
10. Hangi pazarlama işleri güvenle otomatikleştirilebilir?
11. Bir yıl boyunca büyümenin temel motorları?
12. Hangi kararlar için gerçek kullanıcı verisi veya deney sonuçları gerekir?

Son olarak **"Ben HUPOLINGO'nun CMO'su olsaydım ilk 10 stratejik kararım bunlar olurdu"** başlıklı yönetici değerlendirmesi.

## ŞİMDİ BAŞLA

İlk iş: proje klasörünü taramak, mevcut tüm ürün özelliklerini ve kullanıcı akışlarını çıkarmak, ürün denetimini tamamlamak. Ardından rekabet ve hedef kitle araştırması, strateji, yıllık plan, içerikler, otomasyon altyapısı. Gereksiz onay döngüleri oluşturma; yalnızca güvenlik, yetki, bütçe veya geri döndürülmesi zor değişikliklerde onay iste.

**Nihai hedef:** Bilimsel bulguları eleştirel kullanan, ekonomik, marka açısından güçlü, ölçülebilir, ölçeklenebilir ve sürdürülebilir bir pazarlama sistemi kurmak.
