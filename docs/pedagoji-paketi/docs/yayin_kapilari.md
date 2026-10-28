# Kalite kapıları — İçerik onay kuralı

**G0 İş emri:** `grade`, `school_year`, `subject`, `mode` ve kullanıcı isterse öğrenci özel okuma gereksinimi.
**G1 Resmî kaynak:** doğru program sürümü, tam öğrenme çıktısı veya açıkça candidate; 2026–27 4/8 eski.
**G2 Pedagojik tutarlılık:** ön koşul, bilişsel eylem, uygun hedef sayısı, farklılaştırma ve geri çağırma planı.
**G3 Alan doğruluğu:** fen/matematik/tarih, birimler, alternatif yanıtlar, deyim/atasözü TDK.
**G4 Metin/madde bütünlüğü:** yaşa uygun Türkçe, tür, anlatıda nedensellik, soruda tek doğru/işlevsel bağlam.
**G5 Teknik QA:** JSON alanları, tekil kimlikler, kelime bandı (yalnız tam hikâye), açık uçlu rubrik, anahtar.
**G6 Hukuk/çocuk koruma:** telif/özgünlük, güvenlik, mahremiyet, ayrımcılık, erişilebilirlik.
**G7 Bağımsız kontroller:** en az alan öğretmeni/pedagog + Türkçe veya soru editörü; gerekiyorsa kaynak danışmanı.
**G8 Pilot ve veri:** sahada ölçülen güçlük, hatalar ve anlama; yeni sürümde yeniden kalibrasyon.

Bir kapıda başarısızlık `fail`, kanıt eksikliği `review_needed` demektir. `pass` sadece gerçek kanıt ve yetkili editör kaydıyla verilir; otomatik kontrol *yayın sertifikası* değildir.

**Hikâye rubrik örneği (editoryal pilot 100 puan):** anlatı/edebî özgünlük 30, yaş/dil 20, bilimsel/müfredat doğruluğu 15, bütüncül öğrenme 15, çıkarım ve kanıt soruları 10, erişilebilirlik/güvenlik 10. Telif ihlali veya ciddi güvenlik riski varsa toplam puandan bağımsız reddet. Bu oranlar MEB standardı değildir.

**Soru rubrik pilotu (100):** geçerlik/program 25, tekillik-doğru çözüm 25, bilişsel eylem/bağlam 20, yanılgı/çeldirici 15, dil/erişilebilirlik 10, telif/provenans 5. Yanlış anahtar -> otomatik fail.
