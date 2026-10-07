# HUPO MATURE DESIGN LANGUAGE v2.0

## Tasarım vaadi
**Sevimli ama bebeksi değil. Eğlenceli ama gürültülü değil. Oyunlu ama öğrenmeyi gölgelemiyor. Premium ama soğuk değil.**

Hupolingo iki algıyı aynı anda üretmelidir: çocuk için *“Burada ilerlemek ve karakter açmak istiyorum”*; veli için *“Bu sistem çocuğumun öğrenmesini ölçüyor ve yönetiyor.”*

## 1. Yaş spektrumu
- **3–5. sınıf:** renk, Hupo ve keşif biraz daha görünür.
- **6–8. sınıf:** daha temiz ekran, daha fazla lacivert/nötr, daha seyrek maskot, daha güçlü mastery/statü dili.
- Ayrı ürün yok; aynı design system içinde **density/maturity adaptation** var. Kullanıcı sınıfı arttıkça kart dekorasyonu ve maskot frekansı azaltılabilir.

## 2. Hupo kullanımı
- Onaylı Hupo asset'leri `assets/hupo/poses/` klasöründedir. Eski placeholder baykuş YASAK.
- Normal ekranlarda Hupo toplam görünür alanın yaklaşık %10–20'sini geçmez.
- Büyük kullanım: onboarding, seviye atlama, ders tamamlanması, karakter unlock, premium hero.
- Küçük kullanım: ipucu, doğru/yanlış mikro geri bildirim, hatırlatma, veli içgörüsü.
- Her ekranda Hupo gösterme. Maskot görünürlüğü “anlamlı an” ile bağlanmalı.

## 3. Renk hiyerarşisi
Ana marka tokenları korunur: Hupo Gold `#F5C842`, Leaf Green `#6DA940`, Sky Blue `#4EA9D9`, Learning Teal `#2BB7A9`, Deep Navy `#102A43`, Cloud Cream `#F8F7F2`.

**Gold scarcity:** sarı/altın arayüzün varsayılan rengi değildir. Hupo, XP, rarity, premium ve büyük başarı için saklanır. Bir normal ekranda gold alanı yaklaşık %10'u geçmemelidir.

Ana aksiyon: güçlü mavi. Öğrenme/ilerleme: teal. Başarı: yeşil. Retry: mercan-kırmızı ama yalnız lokal bileşende.

## 4. Biçim ve yoğunluk
- Ana kart radius: 18px. İç bileşenler: 12–14px.
- Sürekli “pill” kullanımından kaçın. Pill yalnız filtre, status, compact metrics.
- İnce border + hafif shadow. Kalın glow ve cam efekti yalnız rarity/premium/celebration.
- 390×844 referansta yatay kenar boşluğu 18px. Minimum dokunma alanı 48px.

## 5. Tipografi
- Production önerisi: **Inter** veya uygulamada lisanslı eşdeğer modern grotesk.
- Başlık: 800–850. Body: 450–600.
- Bubble/display font yalnız logo ve nadir kutlama başlıklarında.
- Tüm-caps en fazla rarity/class micro-label.

## 6. Oyun + eğitim dengesi
Ana döngü: **Öğren → geri bildirim → mastery → XP → görev → karakter/lig → geri dön.**
XP tek başına amaç değildir. Çocuk “20 XP aldım”dan çok “Gece Kartalı'na 80 XP kaldı” gibi ilerlemeyi hissetmelidir.

## 7. Feedback yoğunluğu
- Sıradan doğru: check + küçük XP.
- 5'li combo / konu ustalığı: mikro celebration.
- Ders/günlük hedef: orta celebration.
- Seviye/rarity/karakter açılışı: büyük sinematik an.
Bu sayede ödül enflasyonu oluşmaz.

## 8. Yanlış cevap ilkesi
Kırmızı ekran YOK. “Başarısız”, “yanlış yaptın yine” gibi shame dili YOK.
Örnek: **“Bir noktayı kaçırdın. İstersen ipucu al, sonra tekrar dene.”**
Yanlış cevap bir öğrenme düğümüdür: açıklama → benzer soru → düzeltilmiş mastery → recovery XP.

## 9. Karakter koleksiyonu
Brawl Stars benzeri statü ve koleksiyon psikolojisi; fakat Hupo kimliği ve eğitim etiği içinde.
- Common → Rare → Epic → Legendary → Mythic
- Görsel ağırlık rarity arttıkça yükselir: siluet, çerçeve, ışık, arka plan, hareket.
- Kozmetik/statü verir; **pay-to-win öğrenme avantajı vermez.**
- 8 sınıfın her biri kendine ait renk/atmosfer taşır; uygulamanın ana design system'ini bozmaz.

## 10. Veli deneyimi
Çocuk tarafındaki oyuncaklık burada azaltılır. Hupo küçük rehberdir. Öncelik: süre, doğruluk, mastery, güçlü/zayıf konular, tekrar önerisi, deneme analizi, bildirim ve üyelik.
Veli ekranının ana mesajı: **“Eğleniyor” değil, “ölçülebilir biçimde ilerliyor.”**

## 11. Production'da yasaklar
- emoji icon seti
- her doğru cevapta konfeti
- dev Hupo her ekranda
- sarı CTA'lar her yerde
- açık sohbet
- gerçek isimle herkese açık leaderboard
- çocuk ekranından tek dokunuşla satın alma
- görünürlük için neon renk yığını
- karakter kartında aşırı chibi/bebek oranları
