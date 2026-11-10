# HR-083 · Kayıp Kodun Ardındaki İnsan · Ajan B (uygunluk ve kalite)
Karar: review_needed
Özet: Veri, yetki ve güven ilişkisi ile dürüst hata bildirimi (kimlik avı yerine doğrulanmış düzeltme) iyi kurulmuş; ancak sonda bold ve defter cümleleriyle açık ders cümleleri var, metin uzun ve giriş bölümünde bir dizim hatası bulunuyor.

Bulgular:
- [yüksek] son bölümler ve bold ifade: Vaaz. Alıntı: "**Bir sistemin amacı bütün kapıları kapatmak değil, hangi kapının kim için ve neden açılacağını dikkatle belirlemekti**." ; "Bir gizemin en iyi çözümü, mutlaka bir suçlu bulmak değildir." ; "Sorumluluk, hatayı saklamak yerine düzeltmek ve tekrarını önlemekle ilgiliydi." Öneri: Bold ifadeyi Aras'ın tek cümlelik sözüne indir ya da çıkar; defter cümlesini somut bir eylemle değiştir; "Sorumluluk..." cümlesini kaldır.
- [orta] gövde, ilk bölüm: Türkçe dizim. Alıntı: "Okul kütüphanesinin dijital {kelime:hr083_katalog} ilk gariplik pazartesi sabahı fark edildi." Öneri: "dijital kataloğunda ilk garip değişiklik" gibi yer bildiren bir biçimde cümleyi yeniden kur; kelime tokenının çekimini doğrula.
- [orta] bütün metin (uzunluk): Yaklaşık 35 bölüm, tahmini 5.000'in üzerinde kelime; sayım yapılmadı. Yetki, söylenti, duyuru ve kulüp tartışması birkaç kez tekrarlanıyor. Öneri: Kelime sayımı yap; söylenti ve duyuru bölümlerini birleştir.
- [orta] gövde, bölüm sonu: Ayraç düz metinde kalıyor ve deyim cümlesi bağlamla uyumsuz. Alıntı: "yanlış bilgiye dönüşebilir.”[[deyim:hr083_kafasina]] Çocuklar güldü." Öneri: Ayracı kaldır; deyim cümlesini gövdede bağlamlı biçimde yaz.
- [düşük] s1 (hatirlama): Doğru şık diğerlerinden (50-52 karakter) biraz uzun (55). Alıntı: "Bilim kurgu kitabının masal kategorisinde görünmesi". Öneri: Doğru şıkkı kısalt.
- [düşük] s3 (yorumlama): Üç çeldirici açıkça hatalı ya da suçlayıcı ("asıl sorumlusudur", "hiçbir zaman yapılmamalıdır"); doğru şık tek nötr seçenek. Öneri: Çeldiricileri makul yanlış çıkarımlar olarak yaz.
- [düşük] gövde, bölüm ortası: Özne-yüklem uyumu. Alıntı: "Bazı öğrenciler öneri sistemine güvenemediği için yeni liste hazırlamak istemiyordu." Öneri: "güvenemedikleri" olarak düzelt.

Doğrulanamayan iddialar: Kelime sayısı ve 7. sınıf okuma bandı sınırı ölçülmedi. Tokenların ve [[deyim:...]] ayraçlarının işleme sonrası temiz çıktığı doğrulanmadı.

Güçlü yanlar: Doğrulanmamış söylentiye karşı kimlik avından uzak durulması ve yetkisiz erişim denemelerinin reddedilmesi güvenlik ve mahremiyet açısından doğru bir tutum. "Öneri motoru ile resmî katalog" ayrımı kavramsal olarak net.
