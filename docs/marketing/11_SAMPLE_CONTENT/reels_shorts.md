# 11 / Reels ve YouTube Shorts senaryoları (R01–R10, TASLAK)

Durum: Taslak · Tarih: 2026-10-29 · Rol: İçerik Direktörü · Bağımlı: 04, 07, 11/instagram

Biçim: 9:16, 1080×1920, 30 fps, 20–45 sn. Güvenli alan: üst ~250 px, alt ~340 px boş. Altyazı ≤100 karakter/ekran, kodla bindirilir (Nunito). Ses: telifsiz müzik ya da sessiz+altyazı; seslendirme gerçek insan sesi (AI ses/çocuk sesi yok). Çocuk yüzü/sesi yok; ekran kayıtları gerçek (örnek veri etiketli). CTA kartı: "Örnek soruları dene → bio". Her videonun kanıtı `olgular.json` kaydıdır. Videolar Oracle'a gerekmez (≥3 video veya ≥5 sn nihai kalite render'ında Oracle köprüsü kullanılır).

## R01 · "10 soru kaç dakika?" (S1) 
- Hook (0–3 sn): ekranda "10 soru = ?" sayaç yok; ekran kaydı hızlı çözüm. Not: süre yalnız **gerçek ölçüm** ile; ölçüm yoksa "Kısa bir görev" yaz, dakika yazma.
- Sahne: 1) Soru ekranı (3 sn) 2) cevap seçimi, çözüm adımı (6 sn) 3) 10/10 bitiş kartı (4 sn) 4) Kapanış: "Küçük görev, net bitiş."
- Metin (altyazı): "Ders çalışmak bazen büyük görünür." / "Hupolingo'da görev 10 soruyla biter." / "Örnek soruları hesap açmadan dene."
- Hipotez: somut görev boyutu başlatmayı kolaylaştırır. 

## R02 · "Bu akşam ders kavgası yerine" (S1, duygusal rahatlama) 
- Hook: "Akşam ders saati gergin mi geçiyor?" (metin kartı, 2 sn) — korku/suçlama yok.
- Sahne: Hupo animasyonu (hupo-motion kopyası, `HupoGelir`) → "Bugünün görevi hazır" ekranı → 10 soru → "Bugünlük bitti".
- Metin: "Küçük bir görev, net bir bitiş." / "Bitince siz de özeti görürsünüz." CTA kartı.
- Dikkat: "kavga" kelimesi test edilecek (negatif çerçeve riski). Alternatif başlık: "Akşam çalışma saati için küçük bir rutin."

## R03 · "Yanlış cevap bir son değil" (S1/S3)
- Hook: yanlış seçilen şık, yumuşak ton (X işareti yok).
- Sahne: yanlış cevap → çözüm adımı (adım adım) → "Tekrar listesine eklendi" → ertesi gün tekrar kartı.
- Metin: "Yanlış cevap, tekrar edilecek konunun işaretidir." Kanıt: faq "Yanlış cevap verilirse ne olur?"

## R04 · "Veli raporu 20 saniyede" (S3)
- Sahne: ÖRNEK RAPOR ekranı kaydırılıyor; üstte "ÖRNEK VERİ" rozeti; ders tablosu → tekrar önerisi.
- Altyazı: "Hangi derste kaç soru çözüldü?" / "Hangi konuyu tekrar etmeli?" / "Az veri varsa yüzde göstermeyiz."

## R05 · "10 saniyede güven" (S4)
- Hook: "Çocuk uygulamasında üç şey yok." Sahne: kart kart: "Reklam yok" / "Konum izni yok" / "Veli onayı olmadan veri yok" — her biri 2 sn, Hupo küçük.
- Kapanış: "Pilot sürümdeyiz, geri bildirimle geliştiriyoruz."
- Kanıt: trust; "veri yok" ifadesi landing metnine uygun ("Veli onayı olmadan veli paneline veri düşmez") — hassas: bunu aynen kullan.

## R06 · Soru ekranı turu (U1, S3)
- Sahne: soru → şık → çözüm → sonuç; "Her cevaptan sonra adım adım çözüm görünür." Hupo küçük köşede.
- Süre 25 sn. Kanıt: benefits.

## R07 · "Günde kaç soru yeterli?" (E2, S2)
- Hook: soru kartı. İçerik: "Tek bir doğru sayı yok. Çocuğun yaşına ve gününe bağlı. Başlangıç için 5–10, sonra birlikte ayarlayın." Hupolingo günlük hedef 5–20, varsayılan 10.
- Dikkat: pedagojik kesin iddia yok. CTA yok ya da yumuşak.

## R08 · Tekrar listesi nasıl çalışır (U3)
- Sahne: yanlış sorular → listeye düşer → ertesi gün "Tekrar" ekranı → listeden çıkar.
- Doğrulama: tekrar mantığı kodla doğrulanmalı (`mobile-app/lib/screens/review_screen.dart`); aksi halde yayınlama.

## R09 · "Tatilde 20 dakika" (mevsimlik, S1)
- Mevsim doğrulanınca (ör. ara tatil). Sahne: haftalık çizelge (görsel, kodla); Hupolingo tek bir araç; "Dinlenme günü de planın parçası."

## R10 · Hupo evreni (S5)
- Sahne: Hupo master pozları, 3 karakter ifadesi; "8 dünya, 40 karakter" altyazı. Müzik telifsiz. Kanıt: characters. Çocuğa hitap yok; "çocuğunuzun motivasyonunu destekleyen küçük ödüller" çerçevesi.

## YouTube Shorts yeniden kullanım
R01, R03, R04, R05, R06, R08 → Shorts (aynı dosya, başlıkta #Shorts gerekmez). Açıklama alanında UTM'li bağlantı: `https://hupolingo.com/demo?utm_source=youtube&utm_medium=organic_social&utm_campaign=sm-YYYY-MM-hN&utm_content=<kod>`.

## Üretim notları
- Hupo animasyonu: `~/hupo-motion` Oracle projesi **değiştirilmez**; kopya `~/pazarlama-motion` türetilir (onay).
- Dosya adı: `YYYYMMDD_instagram_veli-rutini_reel_v1.mp4`; çıktı yolu repo dışı. Kare kontrolü (başı/ortası/sonu) yapılmadan teslim yok; bu oturumda **hiçbir video üretilmedi** (görsel kontrol yapılmadı).
