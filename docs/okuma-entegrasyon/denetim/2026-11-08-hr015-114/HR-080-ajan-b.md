# HR-080 · Robot Kentin Son Ağacı · Ajan B (uygunluk ve kalite)
Karar: review_needed
Özet: Veri ile kullanıcı görüşü ayrımı ve erişilebilirlik bağlamı (tekerlekli sandalye, yaşlı komşu, yaya güvenliği) iyi kurulmuş; ancak bold ve son bölümdeki ders cümleleri vaaz riski taşıyor, metin uzun ve iki Türkçe dizim hatası var.

Bulgular:
- [yüksek] bold ifade ve son bölüm: Vaaz. Alıntı: "**Ağaç bir süs değildi; kent yaşamının parçasıydı**." ; "Kent herkesin ortak alanıdır" ; "Teknoloji bize yollar gösterebilir; hangi yolu neden seçeceğimizi birlikte düşünmeliyiz." Öneri: Bold ders cümlesini Kahraman'ın sözüne dönüştür ya da çıkar; "Kent herkesin ortak alanıdır" sloganını çıkar; defter cümlesini somut bir sahneyle değiştir.
- [orta] bütün metin (uzunluk): Yaklaşık 34 bölüm, tahmini 5.000'in üzerinde kelime; sayım yapılmadı. Öneri: Kelime sayımı yap; ilk çizim, makete dönüş ve rota tartışması gibi tekrar eden anlatı bloklarını birleştir.
- [orta] s4 (sozcuk_baglami): Doğru şık en uzun ve metindeki kelimeyi tekrar ediyor. Alıntı: "Güneşten korunmayı sağlayan, gölge veren alan". Öneri: Doğru şıkkı kısalt, "gölge veren" tekrarını kaldır, çeldiricileri uzunlukta eşitle.
- [orta] gövde, ilk bölüm: Türkçe dizim. Alıntı: "Ağacın {kelime:hr080_kok} kaldırımı hafifçe kabartmış" ve "ağacın {kelime:hr080_golge} dururdu". Öneri: "ağacın kökleri" ve "ağacın gölgesinde" olacak biçimde cümleyi yeniden kur; kelime tokenının çekim aldığını doğrula.
- [orta] gövde, bölüm ortası: Ayraç düz metinde kalıyor ve deyim cümlesi bağlamla uyumsuz. Alıntı: "yerine koymuyordu.[[deyim:hr080_dikkat]] Gölgeyi". Deyim cümlesi ("Çocuklar bunun üzerine şehrin ağaç bakım planına dikkat çekti.") yeni fidan tartışmasıyla örtüşmüyor. Öneri: Ayracı kaldır; deyimi bu bağlama uygun biçimde yeniden yaz.

Doğrulanamayan iddialar: Kelime sayısı ve sınıf sınırı ölçülmedi. Kelime tokenlarının çekimli çıktığı ve ayraçların işlendiği doğrulanmadı.

Güçlü yanlar: "Sıcaklık ölçümleri ile kullanıcı görüşleri ayrı bölümlerde" ayrımı açıkça yapılıyor. Yaşlı ve tekerlekli kullanıcı temsili somut ve doğru yerleştirilmiş.
