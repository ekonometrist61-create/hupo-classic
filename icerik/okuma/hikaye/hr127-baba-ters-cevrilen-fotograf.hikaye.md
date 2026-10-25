---
baslik: "Babam ve Ters Çevrilen Fotoğraf"
slug: "hr127-baba-ters-cevrilen-fotograf"
fis_kodu: "HR-127"
tur: gizem
konu: tarihleme_kaynak_kontrol
sinif_alt: 4
sinif_ust: 4
kahraman_turu: baba
deger_anahtarlari: [D6, D12]
tanitim: "Arşivdeki eski bir fotoğrafta meydanın düzeni ters görünür. Fotoğrafçı {kahraman}, sorunun ters basılmış bir kopyadan kaynaklandığını kaynakları karşılaştırarak bulur."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-10-24"
etiketler:
  ana_sinif: 4
  maarif: {ana_deger: D6, yardimci_deger: D12}
  kanit_duzeyi: C
  curriculum_status: source_pending
  onceki_program: true
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: arsiv_hr127, tur: lexeme, etiket: "arşiv", islev: first_hint}
  - {id: baski_hr127, tur: lexeme, etiket: "baskı", islev: application}
  - {id: belge_hr127, tur: lexeme, etiket: "belge", islev: application}
  - {id: kaynak_hr127, tur: lexeme, etiket: "kaynak", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "İlk fotoğrafta dikkat çeken neydi?"
    secenekler:
      - {id: A, metin: "Çeşme ve kulenin yerleri"}
      - {id: B, metin: "Şenliğin hiç yapılmadığı"}
      - {id: C, metin: "Saatin çalışmadığı"}
      - {id: D, metin: "Dükkânların erken kapanması"}
    dogru: A
    dayanak: "Fotoğrafta meydandaki saat kulesi, çeşmenin solunda görünüyordu."
    aciklama: "Fotoğrafta kule çeşmenin solundaydı; bugünkü düzen bunun tersiydi."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 3
    metin: "Meydan neden farklı görünüyordu?"
    secenekler:
      - {id: A, metin: "Çeşme başka bir yere taşınmıştı"}
      - {id: B, metin: "Kule yeni yapılmıştı"}
      - {id: C, metin: "Fotoğraf ters basılmıştı"}
      - {id: D, metin: "Gazete kaybolmuştu"}
    dogru: C
    dayanak: "Kutudaki fotoğraf ters basılmıştı."
    aciklama: "Kutudaki baskı ters çevrilmişti; çeşmenin yeri hiç değişmemişti."
  - id: s3
    beceri: hatirlama
    dayanak_sayfa: 4
    metin: "Doğru yılı belirlemek için ne yaptılar?"
    secenekler:
      - {id: A, metin: "İki gazete sayısını karşılaştırdılar"}
      - {id: B, metin: "Yalnızca tahminde bulunup sonucu bekledi"}
      - {id: C, metin: "Fotoğrafı boyayıp düzelttiler"}
      - {id: D, metin: "Meydandaki saate baktılar"}
    dogru: A
    dayanak: "{kahraman} iki ayrı sayıyı karşılaştırarak doğru yılı belirledi."
    aciklama: "Yılı, iki ayrı gazete sayısındaki haberlerin tarihini karşılaştırarak buldular."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "Sonucun güvenilirliği nasıl artırıldı?"
    secenekler:
      - {id: A, metin: "Fotoğraf dikkatlice gizlenerek"}
      - {id: B, metin: "Haber birkaç satır kısaltılarak"}
      - {id: C, metin: "Tarih kısmı tamamen silinerek"}
      - {id: D, metin: "Kaynaklar yeniden incelenerek"}
    dogru: D
    dayanak: "Bulduğu sonucu arşiv kartına yazmadan önce kaynakları yeniden kontrol etti."
    aciklama: "Sonuç kartlara yazılmadan önce kaynaklar yeniden kontrol edildi."
---
@omurga
Mahallenin eski gazetesinde fotoğrafçı olan {kahraman}, arşiv kutularını düzenlerken ilginç bir kare buldu. Fotoğrafta meydandaki saat kulesi, çeşmenin solunda görünüyordu. Oysa bugün çeşme kulenin solundaydı. “Acaba meydan yeniden mi düzenlendi?” diye düşündü. Fotoğrafın arkasına yalnızca “Bahar şenliği” yazılmıştı; tarih yoktu. Bu küçük ayrıntı, {kahraman} için yeni bir araştırmanın başlangıcı oldu.
---
@omurga
Gazetenin arşivinde çalışan {yoldas:yalin|bir arkadaş}, aynı şenlikten kalan iki başka kare getirdi. İlk karede bir bando, ikinci karede süslenen dükkânlar vardı. {kahraman}, her fotoğrafın kenarlarını ve tabelaların yerini karşılaştırdı. Bir karede kulenin saati üçü gösterirken diğerinde dördü gösteriyordu. Saat farkı bir günün farklı anlarını gösterebilirdi; ama meydanın yer değiştirdiğini kanıtlamıyordu.
---
@omurga
{kahraman}, fotoğrafı tarayıcıya yerleştirirken kâğıdın arkasındaki küçük numarayı gördü. Ardından gazetenin basılı sayısını buldular. Gazetede kullanılan görüntü ile kutudaki baskıyı yan yana koyunca sorun anlaşıldı: Kutudaki fotoğraf ters basılmıştı. Çeşmenin yeri aslında hiç değişmemişti. {kahraman} gülümseyerek “Bir ayrıntıya takılıp bütün hikâyeyi yanlış kurmuşum,” dedi.
---
@omurga
Araştırma burada bitmedi. Fotoğrafın çekildiği yılı da öğrenmek istiyorlardı. Şenliğe ait bir ilanda gün ve ay vardı, fakat yıl yazmıyordu. {yoldas:yalin|bir arkadaş}, gazetenin o haftaki sayısındaki başka haberlerin tarihine baktı. {kahraman} iki ayrı sayıyı karşılaştırarak doğru yılı belirledi. Bulduğu sonucu arşiv kartına yazmadan önce kaynakları yeniden kontrol etti.
---
@omurga
Sonraki sayıda, eski fotoğrafın yanına bugünkü meydanın görüntüsünü koydular. Fotoğrafın neden ters göründüğünü ve tarihin nasıl doğrulandığını kısa bir notla anlattılar. Mahalle sakinleri iki görüntüyü dikkatle inceledi. Ertesi gün {kahraman} fotoğrafı tekrar arşive koydu.
