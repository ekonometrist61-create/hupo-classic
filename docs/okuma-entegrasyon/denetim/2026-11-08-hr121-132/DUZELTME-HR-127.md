# DUZELTME · HR-127 · Babam ve Ters Çevrilen Fotoğraf

Dosya: `icerik/okuma/hikaye/hr127-baba-ters-cevrilen-fotograf.hikaye.md`
Kaynak bulgular: HR-127-ajan-a.md, HR-127-ajan-b.md
Ön bilgi alanları (durum, etiketler, denetim) değiştirilmedi.

## Uygulanan bulgular

### 1. [orta, A] Fotoğrafın arkası: "yalnızca ... tarih yoktu" ile sayfa 3'teki "küçük numara" çelişiyordu
- Sayfa 1, önce: "Fotoğrafın arkasına yalnızca “Bahar şenliği” yazılmıştı; tarih yoktu."
- Sayfa 1, sonra: "Fotoğrafın arkasına “Bahar şenliği” yazılmıştı; tarih yoktu."
- Numara (sayfa 3) korundu; yazı ile numara artık çelişmiyor.

### 2. [orta, A+B] Yılın nasıl belirlendiği açıklanmıyordu; yıl hiçbir yerde verilmiyordu
- Sayfa 4, önce: "Şenliğe ait bir ilanda gün ve ay vardı, fakat yıl yazmıyordu. {yoldas:yalin|bir arkadaş}, gazetenin o haftaki sayısındaki başka haberlerin tarihine baktı. {kahraman} iki ayrı sayıyı karşılaştırarak doğru yılı belirledi."
- Sayfa 4, sonra: "Şenliğe ait bir ilanda “Cumartesi, 17 Mayıs” yazıyordu, fakat yıl yazmıyordu. Takvime bakınca bu gün ve ayın cumartesiye denk geldiği yıllar birkaç yılda bir çıkıyordu. {yoldas:yalin|bir arkadaş}, gazetenin o haftaki sayısındaki başka haberlerin tarihine ve bir önceki sayıya baktı. {kahraman} iki ayrı sayıyı karşılaştırarak doğru yılı belirledi. Fotoğraf 1969 yılında çekilmişti."
- Doğrulama: 17 Mayıs 1969 günü Cumartesi'dir (PowerShell `Get-Date` takvim kontrolü; 1960–2000 arasında 17 Mayıs Cumartesi denk gelen yıllar 1969, 1975, 1980, 1986, 1997). "Birkaç yılda bir" ifadesi bu liste ile uyumlu.
- Gazete sayılarındaki haber tarihlerinin içeriği kurgusaldır; gerçek bir arşive atıf yapılmadı.
- s3 dayanağı ("{kahraman} iki ayrı sayıyı karşılaştırarak doğru yılı belirledi.") değişmedi.

### 3. [orta, B] Hedef sözcük "belge" metinde yoktu
- Sayfa 1, önce: "{kahraman}, arşiv kutularını düzenlerken ilginç bir kare buldu."
- Sayfa 1, sonra: "{kahraman}, arşiv kutularını düzenlerken ilginç bir arşiv belgesi buldu: bir fotoğraf."

### 4. [düşük, B] Yön ifadesinde referans noktası yoktu
- Sayfa 1, önce: "Fotoğrafta meydandaki saat kulesi, çeşmenin solunda görünüyordu."
- Sayfa 1, sonra: "Fotoğrafta meydandaki saat kulesi, fotoğrafa bakanın gözünde çeşmenin solundaydı."
- s1 dayanağı aynı cümleyle eşitlendi.

### 5. [düşük, B] Ders ve özet cümleleri
- Sayfa 3, önce: "{kahraman} gülümseyerek “Bir ayrıntıya takılıp bütün hikâyeyi yanlış kurmuşum,” dedi."
- Sayfa 3, sonra: "{kahraman} gülümsedi."
- Sayfa 5, çıkarıldı: "Fotoğrafın neden ters göründüğünü ve tarihin nasıl doğrulandığını kısa bir notla anlattılar."

## Uygulanmayan bulgular

- [düşük, B] s2 ve s4 dayanakları metindeki cümlelerle neredeyse aynı. Atlandı: dayanakları parafrazlamak metindeki cümleyi değiştirmeyi gerektirir ve düşük öncelikli; mevcut sorular dayanakla tutarlı. Gerekirse ayrı bir iş olarak yapılabilir.

## Doğrulanamayan olgular / alanlar

- Arşivdeki bir baskının ters basılması ve arka yüzdeki numaradan basılı gazete sayısına ulaşılması, arşiv numaralandırma pratiği: arşivci teyidi yapılmadı (ajan-a da doğrulayamadı).
- {yoldas:yalin|bir arkadaş} şablonu: frontmatter'da yoldas tanımlı değil; metinde yalnızca "bir arkadaş" görünecek. Bu bir içerik kararı; değiştirilmedi.
- maarif değerleri D6 ve D12 ile içerik uyumu ve onceki_program işareti doğrulanamadı.
- yetiskin_uygun, okuma_bandi, okuma_zorlugu, kavram_zorlugu, ilgi_egilimi alanları dosyada yok.
- curriculum_status: source_pending.

## Sonuç

Denetim betiği (`--ayrinti`) çalıştırıldı: bu hikâye için soru eksikliği, karşılıksız ad veya art arda tekrar bildirilmedi.
