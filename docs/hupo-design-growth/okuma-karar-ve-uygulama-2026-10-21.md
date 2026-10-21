# HupoRead görsel yükseltme: kararlar ve uygulama (2026-10-21)

- Durum: **F1 uygulandı.** F2 (okuyucuda Oku / Keşfet / Düşün adımları) bekliyor.
- Önceki belgeler: [plan](okuma-gorsel-yukseltme-plani-2026-10-21.md), [direktör ortak kararı](okuma-direktor-ortak-karar-2026-10-21.md).
- Kullanıcı K7 için marka adını verdi; K3, K5, K8, K9, K10, K1, K2, K4, K6 için kararı uygulama ekibine bıraktı. Aşağıdaki seçimler bu yetkiyle alındı.

## 1. Kararlar (son hâl)

| Karar | Seçim | Gerekçe | Durum |
|---|---|---|---|
| K1 Palet | `AppColors` tek kaynak; PDF aynı değerleri kullanır. | Okuyucu zaten bu paleti kullanıyor; zip tokenları repoyla doğrulanmamış. | Uygulandı (PDF) |
| K2 Düşün | İlk sürüm atasözü ve anlamıyla açılır; düşünme soruları K6 sonrasına kalır. | Mevcut veriyle yapılabilir; uydurma içerik yok. | Karar alındı; okuyucu adımı F2 |
| K3 İkon | Emoji yok, katalog SVG'si var. PDF: sayfa başına en fazla 2 (2–4. sınıf) veya 1 (5–8. sınıf). Okuyucu: Zengin modda en fazla 2; Sade modda 0 (mevcut ürün kuralı korunur). | Emoji glifi cihazdan cihaza değişiyordu. | Uygulandı |
| K4 Görselsiz ilk faz | Kapak vektör sahne (güneş, dalga, maskot). Sayfa içinde illüstrasyon yok. Raster sahne üretimi F4'e kalır. | Brief §2.2: iç sayfalarda tam sayfa illüstrasyon yok. | Uygulandı (PDF) |
| K5 Maskot | Ana maskot `assets/hupo/uygulama/rehber_sol.webp`. Metin içinde maskot basılmaz. `karakter_hayvan_hupo_kus` etiketi düzeltildi. | Dosya doğrulandı; etiket yanlıştı. | Uygulandı |
| K6 Canlı içerik | Bu turda uzak veritabanına dokunulmadı. Yeni alanlar (`dusun`, ikon anotasyonu) sonraki turda, geriye uyumlu ve ayrı onayla. | Uzak DB değişikliği kullanıcı onayı gerektirir. | Ertelendi (F3) |
| K7 Marka adı | Sayfa üst bilgisinde "Senin Hikâyen"; alt bilgide "Hupolingo · Senin Hikâyen". | Kullanıcı kararı; uygulamadaki ad da bu. | Uygulandı |
| K8 Okuyucu ve Hupo | Hupo okuyucu metninde yok (kapak dışında yok). Okuyucu ikonları yalnız süs amaçlı, ekran okuyucuda atlanır. | Şartname A.6 ve dikkat dağıtmama. PNG'den bilinçli sapma. | Uygulandı |
| K9 PDF stili | Başlıklar serif (Literata Bold); etiketler ve sorular Nunito; sayfa içinde sahne yok; kapakta vektör sahne. | Brief §3.2; kullanıcının "en kaliteli" isteği. | Uygulandı |
| K10 "Sözlüğe ekle" | Yerel kayıt, nötr metin ("defterine eklendi"), XP veya ödül animasyonu yok. | Sunucu kaydı yok; öğrenme metriği XP ile karıştırılmaz. | Karar alındı; uygulama F2 |

## 2. Uygulanan değişiklikler

1. `mobile-app/lib/services/okuma_pdf_hikaye.dart`: PDF yeniden yazıldı. Paletin uygulama renkleri, serif başlıklar, vektör kapak sahnesi (`CustomPaint`: güneş ve iki dalga), atasözü bloğu, sayfa başına ikon sınırı, metin içinde maskot yok. Türkçe büyük harf hatası düzeltildi ("SENİN HİKÂYEN" sabit yazılıyor; `toUpperCase()` "i"yi "I" yapardı).
2. `mobile-app/lib/screens/okuma/okuyucu_ekrani.dart`: Emoji metni yerine `flutter_svg` ile katalog SVG'si çiziliyor; maskot atlanıyor; süs ikonu ekran okuyucuda atlanıyor.
3. `mobile-app/lib/screens/okuma/okuma_tema.dart`: `okumaCikartmaZengin` 3'ten 2'ye (K3).
4. `mobile-app/assets/okuma/karakter_manifest.json`: `karakter_hayvan_hupo_kus` için etiket, açıklama ve kaynak düzeltildi; "onayli_hupo_master" kaldırıldı.
5. `mobile-app/pubspec.yaml`: `flutter_svg: ^2.3.0` eklendi. `flutter pub add` `pubspec.lock` içinde 4 bağımlılığı da değiştirdi.

## 3. Doğrulama

- `flutter analyze` (3 değişen dosya): sorun yok.
- `flutter test test/okuma_*`: 70 test geçti. PDF testi çalıştı ve dosyalar üretildi.
- PDF görsel kontrolü (PyMuPDF ile PNG'ye çevrildi):
  - 5. sınıf renkli: kapak, hikâye sayfası, sorular, cevap anahtarı. Düzeltmeler sonrası tekrar kontrol edildi.
  - 2. ve 8. sınıf: hikâye sayfası. Yazı boyutu ve aralıklar sınıf bandına uygun.
  - Ink-saver PDF'ler üretildi; görsel olarak ayrıca bakılmadı.

## 4. Doğrulanmayanlar

- Okuyucunun SVG ikonları cihazda görülmedi. Widget testleri geçti, ama gerçek görünüm için emülatör ekran görüntüsü gerekiyor.
- 360x640 önizlemesi mevcut üreticiyle alınamıyor (yalnız 390 ve 1024 üretiyor).
- Baskı ve ink-saver kâğıt çıktısı yazıcıda denenmedi.
- Manifest etiketinin kahraman kartında görünüp görünmediği UI'da kontrol edilmedi (`kartTuru: hazir` alanı duruyor; direktör raporuna göre bu yol kullanılmıyor).

## 5. Kalan işler

- **F2 (okuyucu): uygulandı.** Oku · Düşün göstergesi (yalnız anlamı olan atasözü varsa); son sayfada isteğe bağlı Düşün kartı (atasözü, anlamı, "Sözlüğe ekle"). Kayıt cihazda, hesap anahtarlı "Sözlüğüm" rafında (en çok 100). Keşfet davranışı (kelime ve atasözü dokununca alt sayfa) aynen kaldı. Kullanıcı Düşün'ün isteğe bağlı olmasını onayladı. Sözlüğüm için liste ekranı yok; ayrı karar.
- **F3 (içerik sözleşmesi): uzakta uygulandı** (`20261051000000_okuma_dusun_alani.sql`, kullanıcı onayıyla). Yalnız doğrulayıcıya isteğe bağlı `hikaye.dusun` eklendi. Düşün soruları içeriği henüz yok; istemci kartı içerik gelince gösterir.
- **Sözlüğüm yerleşimi:** Okuduklarım ekranında ikinci sekme (kullanıcı kararı: "sen karar ver"; gerekçe: aynı kişisel raf ve giriş noktası).
- **F4 (görseller): tamamlandı (K-0081).** Varlık seti diskte mevcut (47 karakter, 80 ikon, tümü şeffaf RGBA, manifestlerle tutarlı). Denetimde 4 düzeltme yapıldı: voksel karakter yeni kâşif karakteriyle değiştirildi, iki ikonun kutu arka planı temizlendi, maskot dosyası onaylı master kopyasına alındı. Bu oturumda toplu üretim yapılmadı; mevcut setin kökeni belgelenmemiş. Büyücü karakteri editör onayı bekliyor.
- _Eski not:_ Nano-banana anahtarı kullanıcı ortamında doğrulandı (değerleri eşleşiyor); bu oturumun süreci eskiyi taşıdığı için Claude Code yeniden başlatılmalı. Sonra karakter ve ikon stil testi (3 karakter + 8 ikon) başlar.
- **Güvenlik:** Bu oturumun bir çıktısında `GEMINI_API_KEY` değeri göründü; anahtarın döndürülmesi önerilir.
