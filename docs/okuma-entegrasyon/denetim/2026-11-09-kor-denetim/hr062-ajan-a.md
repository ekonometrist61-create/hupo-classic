# HR-062 · Hafızası Karışan Android · Ajan A (olgu ve doğruluk) · kör-2026-11-09
Karar: pass
Özet: Robotun hatasının nedeni (komutların yanlış birleştirilmesi, sesteşlik/bağlam, hatalı görev verisi) iç tutarlı ve doğru anlatılıyor; sesteşlik örnekleri (yüz, gül) dilbilgisel olarak doğru. Cevap anahtarları metinle destekleniyor; yalnız s3'te dayanak yoruma dayalı.
Bulgular:
- [düşük] s3 (dayanak_sayfa 3) : Kök "Deniz Bey'in açıklamasına göre bir sistemin sonucu neye bağlıdır?" diyor; metinde algoritmanın "kuralları ve verileri kullanarak sonuç üretebildiği" ve "doğrulama, güvenlik sınırları ve insan denetiminin önemli" olduğu söyleniyor, "sonuç doğrulamaya bağlıdır" doğrudan yazmıyor. Doğru şık C tek makul seçenek, çeldiriciler açıkça alakasız. Alıntı: "Bir algoritma, verilen kuralları ve verileri kullanarak sonuç üretebilir". Öneri: Kökü "Deniz Bey'e göre yanlış sonucu yakalamak için neler önemlidir?" yap.
- [düşük] Sayfa 8 : "Masadaki üç kitaptan biri yerindeydi" ifadesi belirsiz (yerinde = taşınmamış mı, doğru yerde mi); iki kitabı alınca görevin bitmiş sayılması ile çelişkili görünebilir. Alıntı: "Oysa masadaki üç kitaptan biri yerindeydi." Öneri: "üç kitaptan biri henüz taşınmamıştı" yaz.
- [düşük] s2 açıklaması : Açıklama "tost/toz, çorap/çorabı" benzerliğini neden olarak sunuyor; metinde "çorapları topla" ile "çorabı hazırla" ayrı komutların birleşmesi anlatılıyor, "tost → çorap" eşleşmesinin mekanizması tam açıklanmıyor. Cevap D yine de metinle uyumlu. Alıntı: "Robot iki ayrı komutu yanlış birleştirmişti." Öneri: Açıklamayı metindeki cümleye bağla.
- [düşük] s1 çeldiricileri : "Kitaplar", "Defterler" şıkları hikâyedeki başka sahnelerden gelen nesneler; çeldirici olarak makul, ancak "Peynirli tost" (istenen şey) ayrıca ilginç bir çeldirici. Sorun yok, yalnız not.
Doğrulanamayan iddialar: yok ("yüz" (sayı) ve "yüz" (çehre), "gül" (çiçek) ve "gül-" (fiil) gerçekten sesteş; "hafıza" sözcüğünün robot için mecaz olduğu, robotun duygu/bilinç iddiasından kaçınılması bilimsel olarak ihtiyatlı).
Güçlü yanlar:
- Robotun "yalan söyleme"/"hafıza" gibi insan sözcüklerini mecaz olarak ayırması ve sistemin sınırlarını doğru çiziyor.
- s1, s2, s4 cevapları metinle birebir; s4'teki sesteşlik tanımı sayfa 7'de aynen geçiyor.
- Hata kaynağını hem veride (görev sayısı iki) hem komutta (belirsiz "mavi") hem sistemde bularak tanıtımdaki üç soruyu metinle gerçekten yanıtlıyor.
