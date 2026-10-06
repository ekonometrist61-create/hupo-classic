---
name: hupo-design-system
description: "Hupolingo marka kimliğini UI tasarımına taşır; Hupo yerleşimi, renk ve semantik tokenlar, tipografi, bileşenler, responsive ve hareket kuralları üretir. Görsel tasarım, ana/soru/sonuç ekranı, bileşen veya tasarım sistemi çalışmasında kullan."
---
# Hupo tasarım sistemi
## İş akışı
1. `docs/hupo-design-growth/BRAND_AND_VISUAL_RULES.md` ve mevcut token/bileşen dosyalarını oku. Varsa çalışan sistemi genişlet; paralel tasarım sistemi kurma.
2. Marka paletini işlevsel renkten ayır. Arka plan, metin, kenarlık, odak, eylem, hata, başarı, uyarı, XP, premium ve rarity rollerini tanımla.
3. Mevcut fontu değerlendir; Türkçe karakter, okunabilirlik, lisans ve yükleme maliyetini kontrol et. Gövde metninde dekoratif font kullanma.
4. Platformun yerel ölçü biriminde tipografi/boşluk ölçeği oluştur. Web px/rem değerlerini native dp/pt değerleriyle mekanik eşitleme.
5. Mevcut buton, kart, seçenek, ilerleme, toast ve dialog bileşenlerine loading/disabled/focus/error durumlarını ekle. Tokenları koda bağla; sadece görsel rehber bırakma.
6. Gerçek Türkçe içerik ve uzun metinlerle örnek ekran üret. Raster referansları tasarım ilhamı olarak kullan; mevcut maskotu yeniden icat etme.
7. Platform review skill'iyle ekran görüntüsü, kontrast, taşma ve etkileşim incelemesi yap.

## Hupo yerleşimleri
- Ana ekran: orta ölçekte Hupo + tek motivasyon cümlesi; bugünün görevi/başla eylemi ilk bakışta görünür. XP ve sonraki karakter ikincil bilgi olsun.
- Soru ekranı: küçük veya gerektiğinde görünen Hupo; soru ve seçenek alanını işgal etmesin. İpucu ve feedback için kullan. Yanıt gönderilmeden doğruluk işareti verme.
- Sonuç ekranı: daha belirgin kutlama; doğru/yanlış, tamamlanan konu, yeniden çalışma önerisi ve devam eylemi önce anlaşılır olsun. Ödül animasyonu atlanabilir olsun.
- Veli alanı: maskotu azalt; veri açıklaması ve sonraki öğrenme önerisine yer aç.
- Admin: marka küçük logo/aksanla taşınsın; animasyon ve ödül dili operasyon ekranlarında kullanılmasın.

## Görsel disiplin
- Altın sarısını Hupo, XP/ödül ve özel vurgu için değerli tut. Her butonu sarı yapma.
- Yanlış cevap için yumuşak tekrar tonu; ödeme hatası/tehlikeli admin işlemi için ayrı güçlü danger semantiği kullan.
- Premium ile Mythic rarity aynı işlev değildir; ayrı tokenlar kullan, metin/ikonla ayırt et.
- Renk tek bilgi taşıyıcısı olmasın. Doğru cevap, progress ve rarity etiket/ikonla anlaşılabilsin.
- Hupo'nun 9–11 yaş hissini koru: cinsiyetsiz, enerjik, premium ve aşırı bebeksi olmayan.
- Hareketi geri bildirim için kullan; soru çözerken sürekli parallax/confetti oynatma. Reduced motion ve düşük cihaz bütçesi tanımla.
- Web'de normal metin kontrastı en az 4.5:1, büyük metin 3:1, gerekli UI göstergeleri 3:1 hedefiyle ölçüm yap; hex seçimini test sonucu yerine sayma.

## Çıktı
Görsel yön ve gerekçe; kaynak/onay durumu; token eşlemesi; bileşen durumları; Hupo yerleşimleri; uygulanmış dosyalar; ölçülen kontrast ve görüntü incelemesi. Yeni renkleri öneri olarak işaretle; onaylı kaynakla karıştırma.

## Ortak bağlam
Proje köküne göre `docs/hupo-design-growth/PROJECT_CONTEXT.md` dosyasını oku. İlgili mevcut brief, kod ve tasarım kararlarını kontrol et; repo dışındaki geçmiş konuşmalara erişimin varmış gibi davranma. Eksik ama kritik olmayan bilgiyi varsayım olarak işaretleyerek ilerle. Güncel kullanıcı talimatını esas al; çelişkileri kısa kaydet.
Talep yalnızca analiz ise uygulama kodunu değiştirme. Uygulama istenmişse mevcut stack ve bileşenlerle çalış. Kaynak dosyaları, çalıştırılan kontrolleri ve doğrulanamayan noktaları raporla. Başarı/gelir/öğrenme etkisi garantisi verme.
