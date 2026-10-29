# 11 / Instagram içerikleri (30 günlük paket, TASLAK)

Durum: Taslak, yayınlanmadı · Tarih: 2026-10-29 · Rol: İçerik Direktörü · Bağımlı: 04, 07, 09, 12, 17 · Yeniden kullanım: Y+N gün ofsetleri (Y = ilk yayın günü)

**Mevcut paketle ilişki:** `docs/hupo-design-growth/sosyal-medya/ICERIK_PAKETI_2_HAFTA.md` G01–G10 + L01–L02 (Y+0…Y+13) zaten yazılıdır; burada **tekrar edilmez**. Bu dosya Y+0…Y+29'u kapatan tamamlayıcı paket: P01–P10 (gönderi), C01–C05 (carousel), parent edu (E1–E5), ürün (U1–U5), topluluk (T1–T5). Örtüşme tablosu en altta. Reels: `reels_shorts.md`; YouTube: `youtube.md`.

Ortak kural (her gönderi): CTA yalnız "Örnek soruları dene" (bio linki, `utm_content=bio` ya da story sticker); "indir/ücretsiz deneme/garanti/fiyat/KVKK uyumlu/MEB onaylı" yok; çocuk adı/fotoğrafı yok; görseller onaylı Hupo posları + gerçek ekran kaydı; örnek rapor "ÖRNEK RAPOR" etiketli. Her gönderide kanıt alanı: `olgular.json` kaydı. Hashtag: en çok 4 (Türkçe, düşük spam).

## 30 günlük yerleşim (Y+N)
| Gün | Kod | Biçim | Sütun |
|---|---|---|---|
| Y+14 | P01 | Statik + caption | S1 |
| Y+15 | E1 | Carousel (6) = C01 | S2 |
| Y+16 | U1 | Reel (R06) | S3 |
| Y+17 | T1 | Story anketi | S5 |
| Y+18 | P02 | Statik | S4 |
| Y+19 | U2 | Carousel (5) = C02 | S3 |
| Y+20 | E2 | Reel (R07) | S2 |
| Y+21 | P03 | Statik | S1 |
| Y+22 | T2 | Story: Hupo anı | S5 |
| Y+23 | C03 | Carousel (7) | S2 |
| Y+24 | P04 | Statik | S1 |
| Y+25 | U3 | Reel (R08) | S3 |
| Y+26 | E3 | Statik veya Carousel (C04) | S2 |
| Y+27 | T3 | Story anketi | S2 |
| Y+28 | P05 | Statik | S4 |
| Y+29 | C05 | Carousel (6) 4 haftanın özeti | S1/S4 |
Kalan P06–P10, U4–U5, E4–E5, T4–T5 4. ve 5. hafta yedeği/yeniden kullanım; sıra ölçüme göre.

---

## STATİK GÖNDERİLER (P01–P10)

### P01 · S1 · Segment P1 · Amaç: alışkanlık farkındalığı
- **Hook (görsel üstü, kodla bindirilir):** "Günde 10 soru, uzun bir ders değildir."
- **Caption:** Ders çalışmayı büyük bir iş gibi görmek, başlamayı zorlaştırır. Küçük bir görev ise kolay başlanır, kolay bitirilir. Hupolingo'da günlük hedefi siz belirlersiniz: 5 ile 20 soru arası, varsayılan 10. Çocuğunuz bitirir, ertesi gün kaldığı yerden devam eder. Sizin için de bir ölçüsü olur: bugün yapıldı mı, yapılmadı mı. Bio'daki bağlantıdan örnek soruları hesap açmadan deneyebilirsiniz.
- **CTA:** Örnek soruları dene (bio).
- **Görsel brief:** 1080×1350, krem zemin, ortada büyük "10", altında soru çubuğu (gerçek ekranın 10/10 durumu); köşede Hupo (gülümseyen poz `ifade/*`). Metin kodla.
- **Alt metin:** "10 soruluk bir günlük görev tamamlandı ekranı; köşede altın sarı baykuş Hupo."
- **Etiket:** #çocukeğitimi #ortaokulahazırlık #velirehberi #dersçalışma
- **Performans hipotezi:** Somut sayı kancası kaydetmeyi artırır (Hipotez, K3). **Kanıt:** `landing.benefits` (hedef 5–20, varsayılan 10).

### P02 · S4 · Segment P3 · Amaç: güven
- **Hook:** "Çocuk uygulamasında reklam yok."
- **Caption:** Çocuğunuzun çalıştığı ekranda reklam görmemesi bizim için varsayılan. Uygulama konum izni de istemiyor. Çocuk çalışırken sizin ayrı bir veli ekranınız var; çocuğun çalışma verisinin sizde görünmesi için onayı siz verirsiniz, istediğiniz zaman geri çekebilirsiniz. Her şeyi yaptığımızı söylemiyoruz; yaptıklarımızı söylüyoruz. Pilot sürümdeyiz.
- **CTA:** Güven bölümünü oku: bio.
- **Görsel:** 3 madde ikon listesi (reklam yok, konum yok, veli onayı); Hupo küçük. **Alt metin:** "Üç güven maddesi: reklam varsayılan kapalı, konum izni yok, veli onayı."
- **Hipotez:** P3 segmentinde profil ziyaretini artırır. **Kanıt:** `landing.trust`, manifest taraması. **Dikkat:** "KVKK uyumlu" yazılmaz.

### P03 · S1 · Amaç: motivasyon bağı
- **Hook:** "Yanlış cevap bir son değil."
- **Caption:** Bir soruyu yanlış yapmak çocuğun yavaş olduğunu göstermez; o konunun daha net anlatılması gerektiğini gösterir. Hupolingo'da her cevaptan sonra adım adım çözüm görünür, yanlış yapılan sorular ertesi gün tekrar listesine düşer. Hedef, hızlı bitirmek değil, aynı hatayı iki kez yapmamak.
- **Görsel:** soru ekranından çözüm adımı (gerçek ekran), "Tekrar listesine eklendi" kartı. **Alt metin:** "Bir soruda çözüm adımları ve tekrar listesi bildirimi."
- **Kanıt:** `landing.faq` "Yanlış cevap verilirse ne olur?" **Hipotez:** Soru-açıklama görseli kaydetme yaratır.

### P04 · S1 · Amaç: ebeveyn rolü
- **Hook:** "Başında durmadan destek olmak mümkün."
- **Caption:** Her akşam başında oturmak herkesin yapabileceği bir şey değil. Kısa bir görev, net bir bitiş ve sonunda sizin için bir özet; aradaki sürtünmeyi azaltmayı hedefliyoruz. Sonucu garanti edemeyiz; düzenli pratiğin görünür olmasını sağlıyoruz.
- **Görsel:** Hupo + akşam masası illüstrasyonu (onaylı poz; çocuk yüzü yok). Alt metin: "Hupo, defter ve lamba ile çalışma masası."
- **Hipotez:** Duygusal rahatlama çerçevesi (korku değil). **Kanıt:** genel öneri; iddia yok.

### P05 · S4 · Amaç: dürüst sınır
- **Hook:** "Sınav garantisi vermiyoruz. Ne yapıyoruz?"
- **Caption:** Puan artışı ya da kazanma sözü vermiyoruz; bunu kimse dürüstçe veremez. Yaptığımız şey: kısa görevlerle düzenli pratiği desteklemek, tekrar edilmesi gereken konuları görünür kılmak. Bu kadar. Pilot sürümdeyiz ve geri bildirimlerle geliştiriyoruz.
- **Görsel:** düz metin kartı (navy zemin, krem yazı). **Kanıt:** `landing.trust` "Dürüst kapsam". **Hipotez:** Dürüst çerçeve P3/P2'de güven yaratır, dönüşümü düşürebilir (koruma metriği: bio tıkı).

### P06 · S2 · "Ekran süresi" · Amaç: itiraz
- **Hook:** "Ekran süresi mi, öğrenme süresi mi?"
- **Caption:** Ekranda geçen süreyi sadece dakikayla ölçmek yanıltıcı olabilir. Sorulabilecek daha iyi soru: bu ekranda çocuk ne yaptı? Hupolingo'da görev 10 soruyla biter, sonrasında oyun akışı devam etmez; özet veli ekranında görünür. (Not: sonsuz kaydırma yok — kod doğrulaması gerekir, `olgular.json` kaydı yoksa yayınlama.)
- **Kanıt boşluğu:** "sonsuz akış yok" iddiası kodla doğrulanmadı → yayından önce doğrula. **Etiket:** Varsayım.

### P07 · S5 · Hupo evreni · Amaç: marka sıcaklığı
- **Hook:** "Hupo kim?"
- **Caption:** Hupo, altın sarı bir baykuş. Meraklı, enerjik, soru çözerken yanında. Çocuklar düzenli pratikle yeni karakterler kazanır; 8 dünyada toplam 40 karakter var. Karakterler bir ödül; asıl hedef soruyu anlamak.
- **Görsel:** Hupo master pozu (ifade/*). **Kanıt:** `landing.characters`. **Hipotez:** Marka bağı, takipçi artışı.

### P08 · S3 · Örnek rapor · Amaç: somutluk
- **Hook:** "Veli raporu böyle görünür."
- **Caption:** Bu ekran örnek veridir; gerçek bir öğrenciye ait değildir. Ders bazında çözülen soru, doğru oranı ve tekrar önerisi. Yeterli veri yoksa (6 sorudan az) yüzde göstermiyoruz; çünkü az veriyle kesin sonuç çıkarmak yanıltıcı olur.
- **Görsel:** ÖRNEK RAPOR etiketli ekran, üst köşede "ÖRNEK VERİ". **Kanıt:** `landing.report`. **Hipotez:** "yüzde göstermeme" ayrışma noktası.

### P09 · S2 · Rehber · "Yaz tatilinden önce 4 hazırlık" → yerine mevsime göre uyarlanır
- Mevsimsel şablon (mevsim bilgisi doğrulanınca doldurulur): "Ara tatilde 20 dakika yeter." Caption: tatilde çalışma planı: günde bir görev, hafta sonu tekrar listesi, bir gün tam dinlenme. CTA: örnek sorular. Kanıt: genel öneri.

### P10 · S4 · Şeffaflık günlüğü
- **Hook:** "Bu hafta ne geliştirdik, ne yapmıyoruz?"
- **Caption şablonu:** *Yapılan:* (olgular.json'dan 1–2 cümle). *Yapılmayan:* sınav garantisi, çocuk reklamları, otomatik yenilenen abonelik (yalnız ödeme canlıysa ve ön bilgilendirme yayındaysa). *Soru:* hangi konuyu görmek istersiniz?

---

## CAROUSEL (C01–C05)

### C01 · "Çocuk ders çalışmak istemiyor" (E1, 6 slayt) · S2 · Amaç: itirazı karşıla
1. **Kapak:** "Ders çalışmak istemiyor mu? Önce bunlara bakın."
2. "Görev uzun mu?" — Başlamak için gereken eforu küçültün: 10 soru.
3. "Ne zaman çalışıyor?" — Aç ve yorgun saatleri dışında sabit, kısa bir saat seçin.
4. "Kim karar veriyor?" — Küçük bir seçim verin (hangi ders önce).
5. "Bitişi var mı?" — Net bir bitiş duygusu motivasyonu korur.
6. **Kapanış:** "Hupolingo'da görev 10 soruyla biter. Örnek soruları hesap açmadan deneyin: bio."
- Caption: Bunlar genel önerilerdir; her çocuk farklıdır. **Kanıt:** genel pedagojik öneri (K3), kesin iddia yok. **Alt metin** her slayt için slayt başlığı.

### C02 · "Örnek raporu okumayı öğrenin" (U2, 5 slayt) · S3
1. "Veli raporunda ne görürsünüz?" 2. Ders bazında çözülen soru. 3. Doğru oranı, yeterli veri varsa. 4. Tekrar önerisi. 5. "Bu ekran örnek veridir. Gerçek öğrenciye ait değildir."
Hipotez: Rapor eğitimi paylaşılır.

### C03 · "Doğru oranı neden tek başına yanıltıcı?" (7 slayt) · S2
1) Kapak. 2) 3 soruda 3 doğru = %100, ama ne anlama geliyor? 3) Örneklem küçük. 4) Konu zorluğu farklı. 5) Hızlı mı yavaş mı, bilemeyiz. 6) Bu yüzden 6 sorudan az veri varsa yüzde göstermiyoruz. 7) Siz neye bakıyorsunuz? (yorum sorusu). Kanıt: report.insufficient (6 soru eşiği).

### C04 · "Okul ve ek uygulamalar nasıl birlikte kullanılır?" (E3, 6 slayt) · S2
Nötr: "Okul dersi, MEBİ gibi kaynaklar ve ek bir günlük pratik birbirinin yerine geçmez." Slaytlar: okul = ana kaynak; MEBİ = ücretsiz resmî kaynaklar; Hupolingo = 10 soruluk günlük ritim; veli neye bakmalı; tek seferde çok şey eklemeyin. **Dikkat:** MEBİ iş birliği ima etme; yalnız kamuya açık bilgiyi nötr belirt. Kanıt: MEBİ sayfası (erişim 2026-10-29).

### C05 · "4 haftanın özeti" (6 slayt) · S1/S4 · Amaç: şeffaflık
Slaytlar: ne yayınladık, ne öğrendik (ölçülen gerçek veriden; yoksa "yeterli veri yok"), ne yapmıyoruz, sonraki ay, soru. Sayı yalnız ölçüm CSV'sinden; uydurma yok.

---

## VELİ EĞİTİM (E1–E5)
E1=C01; E2 = Reel R07 ("kaç soru yeterli"); E3=C04; E4 "Tekrar listesi neden önemli" (statik, açıklama + ekran); E5 "Haftada 3 gün 10 soru" planı (görsel takvim, takvim şablonu indirme yok, yalnız görsel).

## ÜRÜN ÖZELLİĞİ (U1–U5)
U1 (R06) soru ekranı + açıklama; U2 (C02) örnek rapor; U3 (R08) tekrar listesi; U4 karakter koleksiyonu (P07 uyarlama, "motivasyon aracı" çerçevesi); U5 günlük hedef ayarı (veli/çocuk ayarı doğrulanınca; şu an `landing.benefits` "Günlük hedefi siz belirlersiniz" — kod doğrulaması gerek). **Yalnız Canlı olan özellikler.** Kelime Evreni, Okuma, Görselli soru, Deneme sınavı **anılmaz**.

## TOPLULUK ETKİLEŞİMİ (T1–T5, kişisel veri toplamayan)
T1 Story anketi: "Çocuğunuz en çok hangi saatte çalışır?" (Akşam/Okul sonrası/Hafta sonu/Değişir) → içeriğe girdi. T2 Hupo anı: "Hupo bugün hangi derse bakıyor?" (eğlence story). T3 Story kutusu: "Veli olarak en çok neyi merak ediyorsunuz?" → yanıtlar genel olarak ele alınır, kimse etiketlenmez. T4 İki seçenek: "10 soru mu, 5 soru mu?" (yorum sorusu). T5 "Bir sonraki rehber ne olsun?" (3 seçenek). Moderasyon: KANAL_OTOMASYON_PLANI §7.

## Örtüşme tablosu
G01–G10 (Y+0…Y+13) mevcut paket; R01–R05 (Reels) onlarla örtüşebilir (aynı video G01, G03, G06, G08 olabilir). C01=E1, C04=E3, C02=U2, R06=U1, R07=E2, R08=U3: bilinçli örtüşme (aynı parça iki gereksinime sayılır).
