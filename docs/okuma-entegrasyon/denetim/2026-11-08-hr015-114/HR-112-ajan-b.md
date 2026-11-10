# HR-112 · 2055: Hatırlayan Şehir · Ajan B (uygunluk ve kalite)
Karar: review_needed
Özet: Veri minimizasyonu ve tahmin ile kaydın ayrımı sınıf düzeyinde öğretici biçimde işleniyor. Ancak sistem adı HAFIZA'nın açılımı harf karşılığını tutmuyor, metin sonunda ders cümleleri var ve iki soruda doğru şık en uzun şık.
Bulgular:
- [yüksek] satır 48: Kısaltma tutarsız. "HAFIZA" kısaltması H-A-F-I-Z-A harflerinden oluşuyor, ama açılım "Hareket Analizi ve Fırsatları İzleme Akıllısı" olduğu için Z harfinin karşılığı yok ve "ve" bağlacı açılımda harf üretmiyor. Alıntı: "Hareket Analizi ve Fırsatları İzleme Akıllısı". Öneri: Açılımı harf karşılığı tutan biçimde yeniden kur, ör. "Hareket Analizi ve Fırsatları İzleme Zekâ Asistanı" (H-A-F-İ-Z-A).
- [yüksek] satır 160, 169, 193, 280: Vaaz. Kalın yazılmış ders ("Kolay anlatmak, eksiltmek değildir"), anlatıcı açıklaması ("Yardım etmek ile kişinin iradesini elinden almak arasındaki çizgi, bazen yalnızca bir soruyu ne zaman ve nasıl sorduğunda saklıydı.") ve kapanış ("Bu, geleceğin en umut verici yanıydı.") dersi sahneye yapıştırıyor. Öneri: Kalın cümleyi kaldır; satır 169 ve 193'teki açıklamaları sahneden sil; metni "Bu, geleceğin en umut verici yanıydı." cümlesi yerine Ömer'in NEDEN? kartıyla ya da başka bir eylemle kapat.
- [orta] s3 (satır 41): Doğru şık ("Bilmek ile tahmin etmek arasındaki farkı fark etmesi") en uzun şık (52 karakter; diğerleri 41-44) ve açıklama soruyu aynen cevaplıyor. Kök "afişteki sözü" diyor ama sözün ne olduğu tırnakla verilmemiş. Öneri: Sözü kökte tırnakla yaz; şıkları uzunlukça eşitle.
- [orta] s5 (satır 43): Doğru şık ("Uzmanların değerlendirmesine güvenmek ve dikkatli davranmak") en uzun şıklardan biri (59 karakter; diğerleri 46-53). Öneri: Doğru şıkkı kısalt; çeldiricileri uzunlukta yaklaştır.
- [orta] Uzunluk (tüm metin): 3.931 kelime, 452 cümle, ortalama 8,7 kelime; teknik kavramlar (veri minimizasyonu, tahmin, kayıt, güven puanı) aynı metinde yoğun. Öneri: Okuma bandı 3 için kısalt; kavramları bağlamda tanıt.
- [düşük] Metin içi işaretler (satır 50, 142, 228): "{kelime:hr112_kayit}", "[[deyim:hr112_agirlik]]", "{isaret:anahtar}". Öneri: Render kontrolü; deyim cümlesinin konuşan kişiyle uyumunu da kontrol et.
Doğrulanamayan iddialar: Okuma bandı kelime/cümle eşiği bu denetimde okunmadığı için değerlendirilemedi. dayanak_sayfa numaraları sayfa düzeni olmadığı için doğrulanamadı. Veri koruma ilkeleri (saklama süresi, silme hakkı) kurgusal olarak tartışılıyor; yasal doğruluğu bu denetimin kapsamında değil.
Güçlü yanlar:
- Kayıt ve çıkarım ayrımı, kendi defterine iki sütun çizerek öğrenciye somut bir araç veriyor.
- Mina'nın hata ve düzeltme deneyimi ile büyükbabanın "bütün amaçlarımı bilmek zorunda değil" sözü, veri koruma sorusunu insan açısından somutlaştırıyor.
