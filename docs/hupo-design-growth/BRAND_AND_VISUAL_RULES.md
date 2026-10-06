# Hupo marka ve görsel kuralları
## Kaynak durumu
Bu rehber kullanıcı kimlik tercihlerini ve uygulama önerilerini ayırır. Yerel repo'da daha yeni onaylı token veya master asset varsa onu esas al. Buradaki önerileri onaylı eski tasarım kararları diye sunma.

## Kimlik
Hupo enerjik, meraklı, cesaretlendirici, cinsiyetsiz bir okul çocuğu baykuştur. Hissiyat 9–11; tombul ama bebek/chibi-bebek olmayan premium cel-shaded stil. Altın sarı armut gövde, krem kalp yüz ve göğüs, mavi gözler, yeşil püskül/kanat, kısa kuyruk kimlik çapalarıdır. Onaylı master Hupo çizimini kullan; kaş/gaga/ayak gibi ayrıntıları yeniden yorumlama. Yeni raster asset istendiğinde tek karakter/tek poz/transparan PNG yaklaşımı uygundur; soru üstüne metin çizme.

## Palet ve roller
| Rol | Değer | Durum / kullanım |
|---|---|---|
| Hupo Gold | #F5C842 | Kullanıcı kimlik rengi; maskot, XP ve özel ödül vurgusu |
| Cloud Cream | #FFEFC9 | Kullanıcı kimlik rengi; yüz/göğüs, sınırlı sıcak yüzey |
| Leaf Green | #6DA940 | Önceki kimlik referansı; repo'nun güncel tonu varsa onu koru |
| Sky Blue | #4EA9D9 | Kullanıcı kimlik rengi; gözler ve destekleyici vurgu |
| Learning Teal | #147D82 | Bu paketin UI önerisi; ana öğrenme eylemi için değerlendir |
| Deep Navy | #17324D | Bu paketin UI önerisi; ana metin için değerlendir |
| Surface | #F8FAFC | Öneri; nötr ekran zemini |
| Correct | #237A4B | Öneri; ikon+metin ile doğru cevap |
| Retry | #A64B24 | Öneri; yanlış/yeniden deneme tonu |
| Warning | #8A5B00 | Öneri; uyarı metni/ikon |
| Danger | #B42318 | Öneri; işlem/ödeme hatası, yıkıcı işlem |
| Premium | #6D4AAF | Öneri; veli abonelik bilgisi |
| Rarity | Ayrı semantik grup | Common/Rare/Epic/Legendary/Mythic için mevcut tabloyu koru; yoksa öneri üret |
Renklerin kontrastı henüz ekran üzerinde ölçülmemiştir. Sarı veya mavi yüzeyde otomatik beyaz yazı kullanma; gerçek token çiftlerini ölç. Gold ile XP'nin ilişkisi, premium ve rarity ile aynı işlev anlamına gelmez. Rarity için metin/yıldız/ikon kullan.

## Yüzey dili
- Öğrenci: açık nötr alan, büyük anlaşılır eylem, az eşzamanlı bilgi; ödüller öğrenme akışını bölmesin.
- Veli satış sitesi: açık fayda, gerçek demo, sakin güven ve anlaşılır planlar; maskot markayı taşısın, içerik yerine geçmesin.
- Veli paneli: tarih aralığı, yeterli örnek, konu ilerlemesi ve sonraki tekrar önerisi; grafik süsleme yerine anlaşılır veri.
- Admin: yoğun ama taranabilir tablolar, tutarlı kolonlar, açık işlem durumu; marka küçük aksanlarla taşınsın.

## Ana / soru / sonuç ekranı
Ana ekranda Hupo karşılama ve günlük görevin yanında; Başla eylemi dekorasyon altında kaybolmasın. Soru ekranında Hupo küçük, statik veya ihtiyaç anında görünen yardımcı; soru okuma alanı ve seçenekler serbest kalsın. Sonuçta Hupo kutlasın; öğrenme sonucu, tekrar konusu ve devam eylemi XP gösterisinden önce anlaşılır olsun.
Kostümsüz teşvik pozu için yön: enerjik, sakin güven, “bir daha dene”; üzgünlükle baskı kurma. Hareketlere süre/bütçe ve reduced-motion karşılığı ekle. Büyük assetleri ekranda gereksiz tam çözünürlükte yükleme.

## Bileşen ve durumlar
Var olan sistemle eşleştir: HupoButton, QuestionOption, HupoProgress, HupoXPBar, HupoCharacter, HupoReward, ParentMetricCard, PricingCard, SocialProofBlock, TrustBlock ve admin tabloları. Adları sırf bu listeye benzesin diye mevcut bileşenleri yeniden adlandırma.
Her ilgili bileşende focus, disabled, loading, success ve error hali bulunmalı. Ekran durumları görsel + metin + eylem olarak tasarlanmalı.
