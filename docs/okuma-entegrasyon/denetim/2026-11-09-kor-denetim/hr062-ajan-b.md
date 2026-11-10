# HR-062 · Hafızası Karışan Android · Ajan B (uygunluk ve kalite) · kör-2026-11-09
Karar: fail
Özet: Çorap/tost açılışı eğlenceli ve yapay zekâ güvenliği/mahremiyeti dikkatle işleniyor; fakat metin 5. sınıf için ~2030 kelime, olay birkaç kez baştan başlıyor ve vaaz ile belgesel anlatım ağır basıyor.
Bulgular:
- [yüksek] Metin geneli / uzunluk : 5. sınıf için ~2030 kelime (hedef ~650). Testler, kartlar, bölümler benzer dersi yineliyor. Alıntı: "Teknolojinin nasıl çalıştığını anlamak, onu ne gereksiz yere küçümsemek ne de olduğundan fazla büyütmek demekti." Öneri: Çorap/tost sorunu, sesteşlik oyunu ve güvenlik sınırı sahnelerini tutup 600-800 kelimeye indir.
- [yüksek] Vaaz : Açık ders ve özet cümleler çok; tabela ve son sahne öğüt formunda. Alıntı: "Hatalardan öğrenmek, bir daha hiç hata yapmamak demek değildi. Önemli olan her yeni durumda dikkatli ve sorgulayıcı kalabilmekti." ve "İletişim yalnız karşıdakinin anlamasını beklemek değildi; anlatanın da düşüncesini açık kurması gerekiyordu." Öneri: Dersleri eylem ve diyaloğa çevir, sondaki özetleri sil.
- [yüksek] Yapı / sahne tekrarı : Olay Cumartesi sabahı çözülmüş gibi kapanıyor, sonra testler, kartlar ve "ilk test" yeniden başlıyor; "şenlik" ve "kulüp gösterisi" önceden kurulmadan beliriyor. Alıntı: "Cumartesi sabahı ARO yeniden kahvaltı masasına geldi." ... sonra "{yoldas:yalin|bir arkadaş}, sorunu çözmeden önce ailece bir liste hazırlamalarını önerdi." ve "Şenlik sonrası ailece akşam yemeğinde ARO yeniden “Bugünkü göreviniz nedir?” diye sordu." Öneri: Tek zaman çizgisi kur, çözülmüş sorunu yeniden çözme.
- [orta] Soru s3 : Kök ile metin uyuşmuyor; Deniz Bey "sonuç kural ve verilerle üretilir, doğrulama önemlidir" diyor, "sonuç doğrulamaya bağlıdır" demiyor; "yorumlama" etiketi hatırlama düzeyinde. Alıntı: "Deniz Bey'in açıklamasına göre bir sistemin sonucu neye bağlıdır?" Öneri: Kökü metindeki ifadeyle eşleştir; çeldiriciler ("hava durumu tahminleri") fazla saçma, yenile.
- [orta] Anlatım kesintisi : Mahremiyet ve güvenlik uyarıları anlatıyı bölen yan notlar olarak giriyor. Alıntı: "Ama sistemin geçmiş konuşmaları gereksiz yere kaydetmesine de gerek yoktu. Yalnız gerekli veriler kullanılmalıydı." Öneri: Uyarıyı karakter kararına dönüştür veya çıkar.
- [düşük] Soru s4 : Doğru şık en uzun (55 karakter, diğerleri ~46) ve tanım metinde aynen. Alıntı: "Aynı yazılış ve sesle farklı anlamlar taşıyan sözcükler". Öneri: Şıkları dengele, bağlamdan çıkarım gerektir.
- [düşük] Soru s2 : Açıklama kayıtların ("tost/toz") karıştığını söylerken doğru şık "komutları yanlış birleştirmesi" biçiminde belirsiz; çeldiriciler bariz. Alıntı: "Komutları yanlış birleştirmesi ve sözcükleri karıştırması" Öneri: Doğru şıkkı daha somut yaz.
- [düşük] Etiket : tur bilim_kurgu, dunya_tipi gercekci; izinli_turler hayali. Öneri: Etiketleri tutarlı hale getir.
Doğrulanamayan iddialar: Ev robotlarının sınırlı yetkilerle çalışması ve "güven düzeyi" gibi çıktılar kurgusal; "karar ağacı" ve "belirsizlik bildirimi" ifadeleri genel olarak makul; D6/D16 eşleşmesi.
Güçlü yanlar:
- Yapay zekâya insan özelliği atfetmeme, mahremiyet (hayalî kişi örnekleri), tehlikeli/yetkisiz görevi reddetme gibi güvenlik değerleri çok iyi işleniyor.
- Sesteşlik örnekleri ("yüz", "gül") doğru ve çocuğa uygun.
- Açılış (çorap/tost) esprili ve sınıf düzeyine uygun.
