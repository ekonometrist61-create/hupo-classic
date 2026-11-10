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
duzeltme_tarihi: "2026-11-09"
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
  - {id: karsilastirma_hr123, tur: lexeme, etiket: "karşılaştırmak", islev: application}
  - {id: kanit_hr123, tur: lexeme, etiket: "kanıt", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Eski fotoğrafta hangi ayrıntı dikkati çekti?"
    secenekler:
      - {id: A, metin: "Bir heykel"}
      - {id: B, metin: "Bir çeşme"}
      - {id: C, metin: "Bir kafe tabelası"}
      - {id: D, metin: "Bir kuyu"}
    dogru: A
    dayanak: "Meydanın kenarında küçük bir heykel vardı; oysa bugün aynı yerde çiçek tarhları bulunuyordu."
    aciklama: "Fotoğrafta meydanın kenarında küçük bir heykel vardır."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 2
    metin: "İlk düşünülen yıldan neden kuşku duyuldu?"
    secenekler:
      - {id: A, metin: "Komşu tarihi değiştirmek istediği için"}
      - {id: B, metin: "Gazetenin arşiv kaydı eksik olduğu için"}
      - {id: C, metin: "Fotoğrafın bir köşesi yırtık olduğu için"}
      - {id: D, metin: "Şenlik yılı fotoğrafında heykel yoktu"}
    dogru: D
    dayanak: "Şenlik yılının bir sayısında hem şenlik ilanı hem meydan fotoğrafı vardı; ama o fotoğrafta heykel görünmüyordu. Fotoğrafın çerçevesi dar olabilirdi, bu yüzden yılın öteki sayılarına da bakıldı; ikinci bir meydan fotoğrafında da heykel yoktu."
    aciklama: "Şenlik yılının gazetesindeki fotoğrafta heykel görünmüyordu; kadraj dar olabileceği için yılın ikinci bir fotoğrafına da bakıldı ve orada da heykel yoktu. Bu yüzden ilk yıl kesin sayılmadı."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 4
    metin: "Hikâyede “kanıt” hangi anlamda kullanılıyor?"
    secenekler:
      - {id: A, metin: "Doğrulamaya yarayan bilgi"}
      - {id: B, metin: "Fotoğrafı çeken makinenin markası"}
      - {id: C, metin: "Duvara asılmak için seçilmiş bir resim"}
      - {id: D, metin: "Komşunun anlattığı bir söylenti"}
    dogru: A
    dayanak: "Haber, komşunun sözlerini destekledi; {kahraman} bu haberi bir kanıt olarak kenara ayırdı."
    aciklama: "Metinde gazete haberi, komşunun sözünü doğrulayan bir kanıt olarak kullanılır; yani kanıt doğrulamaya yarayan bilgidir."
  - id: s4
    beceri: hatirlama
    dayanak_sayfa: 4
    metin: "Komşunun anlattıkları hangi yolla doğrulandı?"
    secenekler:
      - {id: A, metin: "Eski bir harita çizimiyle"}
      - {id: B, metin: "Kısa bir şarkı sözüyle"}
      - {id: C, metin: "Gazetedeki bir haberle"}
      - {id: D, metin: "Mahalledeki bir söylentiyle"}
    dogru: C
    dayanak: "Gerçekten de bir haberde meydanın yeniden düzenlendiği ve heykelin kasabanın kültür bahçesine taşındığı yazıyordu."
    aciklama: "Komşunun sözleri, heykelin kaldırılıp taşındığını bildiren gazete haberiyle desteklendi."
---
@omurga
Yerel gazetede fotoğrafçı olan {kahraman}, sabah eski fotoğrafları düzenliyordu. Sararmış bir karede mahallenin meydanını gördü. Meydanın kenarında küçük bir heykel vardı; oysa bugün aynı yerde çiçek tarhları bulunuyordu. {kahraman} fotoğrafın arkasındaki “Yaz şenliği” notunu okudu. “Bu fotoğrafı şenlik yılında çekmiş olmalıyız,” diye düşündü. Sonra fotoğrafı ayırdı; daha kesin bir tarih bulmak istiyordu.
---
@omurga
Gazetenin arşiv görevlisi, düzenli saklanan eski gazete sayılarını, yani eski belgeleri getirdi. {kahraman} ile arşiv görevlisi gazetelerdeki meydan fotoğraflarını karşılaştırdı. Şenlik yılının bir sayısında hem şenlik ilanı hem meydan fotoğrafı vardı; ama o fotoğrafta heykel görünmüyordu. Fotoğrafın çerçevesi dar olabilirdi, bu yüzden yılın öteki sayılarına da bakıldı; ikinci bir meydan fotoğrafında da heykel yoktu. “Demek ki ilk düşündüğümüz yıl şüpheli,” dedi {kahraman}. Bu farkı ilk bakışta gözden kaçırmıştı. Bir sonraki yılın gazetesinde ise heykelin açılış haberi yer alıyordu.
---
@omurga
Arşiv görevlisi haberin altındaki tarihi işaretledi. {kahraman}, açılış fotoğrafını elindeki eski kareyle karşılaştırdı. Heykelin arkasındaki ağaç da iki fotoğrafta benzer görünüyordu. Üstelik meydanın taş döşemesi de aynı desendeydi. Böylece şenlik yılı sanılan fotoğrafın, heykelin açıldığı yılda ya da sonrasında çekildiği anlaşıldı.
---
@omurga
Mahallede uzun zamandır yaşayan yaşlı bir komşu, “Heykel kaldırıldığında meydan düzenleniyordu,” dedi. {kahraman} bu anlatıyı hemen kesin bilgi saymadı. Gazetenin sonraki sayılarını taradı. Gerçekten de bir haberde meydanın yeniden düzenlendiği ve heykelin kasabanın kültür bahçesine taşındığı yazıyordu. Haber, komşunun sözlerini destekledi; {kahraman} bu haberi bir kanıt olarak kenara ayırdı.
---
@omurga
{kahraman} iki fotoğrafı ve gazete haberini bir panoda yan yana sergiledi. Altına yalnızca doğrulayabildiği bilgileri yazdı. Mahalle sakinleri eski meydanın nasıl değiştiğini gördü. Ertesi gün fotoğrafı tekrar arşive koydu.
