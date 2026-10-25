---
baslik: "Meydandaki Kayıp Heykel"
slug: "hr123-baba-meydandaki-kayip-heykel"
fis_kodu: "HR-123"
tur: gizem
konu: kanit_tarihleme
sinif_alt: 4
sinif_ust: 4
kahraman_turu: baba
deger_anahtarlari: [D12, D6]
tanitim: "Eski bir fotoğrafta mahallenin meydanında heykel vardır. Fotoğrafçı {kahraman}, tarihi tek bir kareye bakarak değil, gazete kayıtlarını karşılaştırarak bulur."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-10-24"
etiketler:
  ana_sinif: 4
  maarif: {ana_deger: D12, yardimci_deger: D6}
  kanit_duzeyi: C
  curriculum_status: source_pending
  onceki_program: true
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: arsiv_hr123, tur: lexeme, etiket: "arşiv", islev: first_hint}
  - {id: belge_hr123, tur: lexeme, etiket: "belge", islev: application}
  - {id: karsilastirma_hr123, tur: lexeme, etiket: "karşılaştırma", islev: application}
  - {id: kanit_hr123, tur: lexeme, etiket: "kanıt", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Eski fotoğrafta hangi ayrıntı dikkati çekti?"
    secenekler:
      - {id: A, metin: "Bir heykel"}
      - {id: B, metin: "Bir otobüs"}
      - {id: C, metin: "Bir gölet"}
      - {id: D, metin: "Bir bisiklet"}
    dogru: A
    dayanak: "Meydanın kenarında küçük bir heykel vardı; oysa bugün aynı yerde çiçek tarhları bulunuyordu."
    aciklama: "Fotoğrafta meydanın kenarında küçük bir heykel vardır."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "İlk düşünülen yılın yanlış olduğu nasıl anlaşıldı?"
    secenekler:
      - {id: A, metin: "Komşu öyle istediği için tarihi değiştirdi"}
      - {id: B, metin: "Gazete kaybolduğu için okunamadı"}
      - {id: C, metin: "Fotoğraf yırtıldığı için eksik kaldı"}
      - {id: D, metin: "O yıl heykel henüz olmadığı için"}
    dogru: D
    dayanak: "Bir sayının kapağında şenlik ilanı vardı, ama o fotoğrafta heykel henüz yoktu."
    aciklama: "Şenlik yılının gazetesindeki fotoğrafta heykel bulunmadığı için o yıl yanlıştır."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 4
    metin: "Hikâyede “kanıt” hangi anlamda kullanılıyor?"
    secenekler:
      - {id: A, metin: "Doğrulamaya yarayan bilgi"}
      - {id: B, metin: "Odayı süslemeye yarayan eşya"}
      - {id: C, metin: "Yalnızca eski bir eşya"}
      - {id: D, metin: "Bir gazetenin büyük başlığı"}
    dogru: A
    dayanak: "Kanıt, bir düşüncenin doğru olup olmadığını anlamaya yardım eden bilgiydi."
    aciklama: "Metinde kanıt, bir düşüncenin doğruluğunu destekleyen bilgi anlamındadır."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 4
    metin: "Komşunun anlattıkları hangi yolla doğrulandı?"
    secenekler:
      - {id: A, metin: "Eski bir harita çizimiyle"}
      - {id: B, metin: "Kısa bir şarkı sözüyle"}
      - {id: C, metin: "Gazetedeki bir haberle"}
      - {id: D, metin: "Mahalledeki bir söylentiyle"}
    dogru: C
    dayanak: "Gerçekten de bir haberde meydanın yeniden düzenleneceği ve heykelin kasabanın kültür bahçesine taşınacağı yazıyordu."
    aciklama: "Komşunun sözleri, gazete haberiyle desteklendi."
---
@omurga
Yerel gazetede fotoğrafçı olan {kahraman}, sabah eski fotoğrafları düzenliyordu. Sararmış bir karede mahallenin meydanını gördü. Meydanın kenarında küçük bir heykel vardı; oysa bugün aynı yerde çiçek tarhları bulunuyordu. Heykelin altında belli belirsiz bir tarih görünüyordu. {kahraman} fotoğrafın arkasındaki “Yaz şenliği” notunu okudu. “Bu fotoğrafı şenlik yılında çekmiş olmalıyız,” diye düşündü. Sonra fotoğrafı ayırdı; daha kesin bir tarih bulmak istiyordu.
---
@omurga
Gazetenin arşiv görevlisi, düzenli saklanan eski gazete sayılarını getirdi. Arşiv, belgelerin korunup gerektiğinde bulunabildiği yerdi. İki arkadaş gazetelerdeki meydan fotoğraflarını karşılaştırdı. Bir sayının kapağında şenlik ilanı vardı, ama o fotoğrafta heykel henüz yoktu. “Demek ki ilk düşündüğümüz yıl olamaz,” dedi {kahraman}. Bu küçük farkı gözden kaçırmıştı. Bir sonraki yılın gazetesinde ise heykelin açılış haberi yer alıyordu.
---
@omurga
Arkadaşı haberin altındaki tarihi işaretledi. {kahraman}, açılış fotoğrafını elindeki eski kareyle karşılaştırdı. İki fotoğrafta da heykelin arkasındaki ağaç aynı büyüklükteydi. Üstelik meydanın taş döşemesi de aynı desendeydi. Böylece şenlik yılı sanılan fotoğrafın daha sonraki bir döneme ait olduğu anlaşıldı. Fotoğraf tek başına her şeyi söylemiyordu; başka belgeler ona yol gösteriyordu.
---
@omurga
Mahallede uzun zamandır yaşayan yaşlı bir komşu, “Heykel kaldırıldığında meydan düzenleniyordu,” dedi. {kahraman} bu anlatıyı hemen kesin bilgi saymadı. Gazetenin sonraki sayılarını taradı. Gerçekten de bir haberde meydanın yeniden düzenleneceği ve heykelin kasabanın kültür bahçesine taşınacağı yazıyordu. Haber, komşunun sözlerini destekleyen bir kanıttı. Kanıt, bir düşüncenin doğru olup olmadığını anlamaya yardım eden bilgiydi.
---
@omurga
{kahraman} iki fotoğrafı ve gazete haberini bir panoda yan yana sergiledi. Altına yalnızca doğrulayabildiği bilgileri yazdı. Mahalle sakinleri eski meydanın nasıl değiştiğini gördü. Çocuklardan biri, “Tek bir fotoğrafla karar verseydin tarihi yanlış yazacaktın,” dedi. {kahraman} başını salladı. “Karşılaştırmak bana acele etmemeyi öğretti.” Ertesi gün fotoğrafı tekrar arşive koydu.
