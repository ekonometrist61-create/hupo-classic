# HupoRead görsel yükseltme: direktör değerlendirmesi ve ortak kararlar

- Tarih: 2026-10-21
- Durum: **KARAR BEKLİYOR.** Kod ve içerik değiştirilmedi.
- Girdi: [okuma-gorsel-yukseltme-plani-2026-10-21.md](okuma-gorsel-yukseltme-plani-2026-10-21.md) ve `hupo-design-growth-director` ajanının salt okunur incelemesi.
- Bu belge planın K1–K6 bölümünü günceller. Planın ilgili maddeleri bu belgenin gerisinde kalır.

## 1. Planın düzeltilen yanlışları

1. **Maskot teşhisi yanlıştı (K5).** `assets/hupo/uygulama/rehber_sol.webp` onaylı Hupo varlığı görünümünde: sarı gövde, yeşil tepe ve kanat, mavi göz. PNG'deki kuşla aynı karakter. PDF kodu da bunu kullanıyor (`okuma_pdf_hikaye.dart:26`). Asıl sorun `karakter_hayvan_hupo_kus.webp`: bir çocuk çiziyor ama manifestte onaylı master olarak etiketli (`karakter_manifest.json`, ajanın raporuna göre 377–387. satırlar).
2. **"Brief ile uyumlu" yanlıştı.** Brief başlık için serif veya display font istiyor (§3.2). PDF başlıkları Nunito kullanıyor (`okuma_pdf_hikaye.dart:29-30`).
3. **F1 kabul ölçütü uygulanamaz.** 360x640 önizlemesi mevcut üretici ile alınamıyor; üretici yalnız 390 ve 1024 px üretiyor (denetim §8).
4. **Okuyucu şartnamesi eksikti.** `OKUMA_DUNYASI_EKRANLARI.md` (harici depo, taslak) ekran hedeflerini, ana eylemleri ve durumları tanımlıyor. Plan bu belgeye bağlanmamıştı.

## 2. Ortak kararlar (K1–K6, güncellenmiş)

| Karar | Ortak öneri | Durum |
|---|---|---|
| **K1 Palet** | Onay. `AppColors` tek kaynak; PDF tokenları ondan türetilir. Turkuaz `#48AFCC` küçük metinde kullanılmaz (ajan hesabı: krem zeminde yaklaşık 2.4:1). PDF'deki soluk metin `#6E8290` yaklaşık 3.8:1; küçük metinde 4.5:1'e çıkarılır. | Onay bekliyor |
| **K2 Düşün adımı** | Değiştir. Adım ilk aşamada mevcut atasözü ve anlam verisiyle açılır ("Atasözü + Anlamı"). Düşünme soruları K6 sonrasına kalır. Soru yoksa adım boş ekran göstermeden kapanır. | Onay bekliyor |
| **K3 Emoji → SVG** | Koşullu onay. Tek ikon bütçesi tanımlanır: ajanın raporuna göre harici rehber sayfa başına en fazla 5 işaret, Zengin modda en fazla 1 sahne işareti, Sade modda 0 diyor. Kod ise Zengin modda 3 kullanıyor. Bütçe, insan QA ve ikon lisans kaydı F1 kabul kriteri olur. `🦉` eşlemesi kaldırılır (`ikon_kayit.dart:79`). | Bütçe kararı gerekli (K8) |
| **K4 Görselsiz ilk fazlar** | Onay. Kapak vektör sahne olarak pilotlanabilir (brief "yeni vektörel fener sahnesi" diyor; `design_tokens.json` kapağa sahne izni veriyor). Sayfa içi büyük sahneler brief §2.2 ile çelişiyor ("iç sayfalarda tam sayfa illüstrasyon yok"); bu ayrı bir karar (K9). | Onay bekliyor |
| **K5 Maskot** | Değiştir. Ana maskot adayı `rehber_sol.webp`; sahibi teyit etmeli. `karakter_hayvan_hupo_kus` etiketi düzeltilir ve gizli tutulur. Marka metni "baykuş" diyor, çizim kuş/papağan benzeri; bu fark da teyide bağlı. | Teyit bekliyor |
| **K6 Canlı içerik** | Koşullu onay. Önce eski paketlerde alan yokken uygulama davranışı ve sürüm kuralı tanımlanır. Yayın yalnızca son okuma ve kullanıcı onayıyla yapılır (K-0069 yayın kapısı). `onayli=false` tek başına yeterli değil. | Onay bekliyor |

## 3. Yeni kararlar (ajan önerisi)

- **K7 Marka adı.** Öneri: "Hupolingo · Senin Hikâyen". HupoRead çalışma adı olarak kalır. PDF'te görünen marka bu karara bağlı. **Bloke eder: PDF.**
- **K8 Okuyucuda Hupo ve sahne işareti.** Şartname okuyucuda Hupo'yu yasaklıyor (A.6) ve Keşfet'te ses veya ek görsel istemiyor (B3). PNG ise Hupo, balon ve ses içeriyor. Öneri: şartnameye uyulsun; tek ikon bütçesi tanımlansın. **Bloke eder: F1 (K3 ile birlikte).**
- **K9 PDF stili.** Öneri: başlıklar serif olsun; sayfa içinde sahne yok; kapakta vektör sahne. **Bloke eder: F1.**
- **K10 "Sözlüğe ekle" kaydı.** Bugün sunucuda kayıt RPC'si yok; yalnızca cihazdaki Okuduklarım ekranı var. Öneri: önce yerel kayıt; metin nötr olsun ("defterine ekledin"); XP veya Lottie ödülü verilmesin. **Bloke eder: F2.**

## 4. Ajanın öncesiz yapılabilecek işleri

Bu işler karar beklemez; ama kullanıcının onayı olmadan kod değiştirilmeyecek:
1. PDF paletini `AppColors`'tan türetmek.
2. Maskot filigranı yasağını regresyon testi olarak kilitlemek. (`PROJE_GUNLUGU.md` K-0048 kaydında "%13 soluk Hupo filigranı" geçiyor; kod şu an filigran içermiyor.)
3. `karakter_hayvan_hupo_kus` etiketini düzeltmek.

## 5. Ürün ilkeleri (ajanın önerileri, proje kurallarıyla uyumlu)

- Keşfet ve Düşün isteğe bağlı olsun. Sayaç, zorunlu adım ve "bitir" baskısı olmasın.
- "Yeni şey öğrendin" tek dokunuşla verilen bir rozet olmamalı. Öğrenme sinyali sunucudaki hedef durumu (`introduced` → `recognized`, `okuma_models.dart`) takip etmeli.
- Düşün için XP veya Lottie ödülü verilmez. Metin "defterine ekledin" olur.
- Suçluluk dili kaldırılır. "3 gündür okumadın" (OK-23) gibi ifadeler ve seri baskısı yok.
- Düşünme soruları editör ve kullanıcı onaylı olur; ad, serbest metin veya kazanım iddiası içermez.

## 6. Referans kalitesine en çok yaklaştıran 5 öncelik (görselsiz)

1. Okuyucu başlığı: tür ve yaş çipleri; 2.0 ölçeğinde kırılmayan başlık (OK-07).
2. Kart dili: krem sayfa kartı, sarı çubuklu atasözü bloğu, "Anlamı" kutusu. Tamamı mevcut tokenlarla.
3. Düşün adımı atasözü ve anlamla başlar; soru yoksa adım kapanır.
4. PDF kapağı: vektör sahne (pilot), tanıtım kartı ve `rehber_sol`. Maskot sayfa içine konmaz.
5. PDF başlık serif olur (K9); alt bilgi grisi 4.5:1'e çıkar.

## 7. Doğrulama sınırları

- Ajan okuduğu kaynakları raporladı; kontrast değerleri WCAG formülüyle hesaplandı, ölçüm değil.
- Doğrulanmadı: cihaz görünümü, gerçek PDF çıktısı ve baskı, nano-banana bağlantısı, ikon lisansının yasal geçerliliği.
- Bu oturumda doğrudan doğrulananlar: `rehber_sol.webp` görünümü; `_maskotVarlik` tanımı (`okuma_pdf_hikaye.dart:26`); başlık fontu (`:29-30`); `🦉` eşlemesi (`ikon_kayit.dart:79`).

## 8. Kullanıcıdan istenen yanıtlar

Öncelik sırasıyla:
1. **K7** marka adı.
2. **K8 + K3:** okuyucuda Hupo ve tek ikon bütçesi; şartnameye uyulsun mu?
3. **K9:** PDF başlık fontu ve sayfa içi sahne.
4. **K10:** "Sözlüğe ekle" için yerel kayıt yeterli mi?
5. **K5:** `rehber_sol.webp` ana maskot mu?
6. **K1, K2, K4, K6:** onay.
