---
baslik: "Babam ve Kayıp Başlığın İzinde"
slug: "hr131-baba-kayip-basligin-izinde"
fis_kodu: "HR-131"
tur: gizem
konu: kanit_kaynak_tarih
sinif_alt: 4
sinif_ust: 4
kahraman_turu: baba
deger_anahtarlari: [D6, D16]
tanitim: "Eski bir gazete fotoğrafının başlığı yırtılmıştır. Fotoğrafçı {kahraman}, arşivdeki duyuru defteriyle etkinliği bulur ve kaynağını sergi etiketine yazar."
yetiskin_uygun: false
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-08"
etiketler:
  ana_sinif: 4
  maarif: {ana_deger: D6, yardimci_deger: D16}
  kanit_duzeyi: C
  curriculum_status: source_pending
  onceki_program: true
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: arsiv_hr131, tur: lexeme, etiket: "arşiv", islev: first_hint}
  - {id: dizin_hr131, tur: lexeme, etiket: "dizin", islev: application}
  - {id: kayit_hr131, tur: lexeme, etiket: "kayıt", islev: application}
  - {id: kaynak_hr131, tur: lexeme, etiket: "kaynak", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 1
    metin: "Yırtılan kısım neydi?"
    secenekler:
      - {id: A, metin: "Fotoğrafın alt başlığı"}
      - {id: B, metin: "Kenardaki ince çizgiler"}
      - {id: C, metin: "Tarihi gösteren bir saat"}
      - {id: D, metin: "Ağacın kalın gövdesi"}
    dogru: A
    dayanak: "Ancak fotoğrafın altındaki başlık yırtılmıştı."
    aciklama: "Fotoğrafın altındaki başlık yırtılmıştı."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 3
    metin: "İki fotoğraf neden aynı etkinlik sayılmadı?"
    secenekler:
      - {id: A, metin: "İkisi de yeniydi"}
      - {id: B, metin: "Ağaç bulunmuyordu"}
      - {id: C, metin: "Aralarında bir hafta vardı"}
      - {id: D, metin: "İkinci fotoğrafın altında yazı yoktu"}
    dogru: C
    dayanak: "Tarihleri karşılaştırdı ve aralarında bir hafta bulunduğunu gördü."
    aciklama: "Tarihler karşılaştırılınca iki fotoğrafın farklı günlere ait olduğu anlaşıldı."
  - id: s3
    beceri: hatirlama
    dayanak_sayfa: 4
    metin: "Etkinliğin adı hangi kayıtta bulundu?"
    secenekler:
      - {id: A, metin: "Harita kitabında"}
      - {id: B, metin: "Alışveriş listesinde"}
      - {id: C, metin: "Sınıf günlüğünde"}
      - {id: D, metin: "Duyuru defterinde"}
    dogru: D
    dayanak: "Defterde ilk fotoğrafın tarihine ait “Mahalle Kitap Değişim Buluşması” kaydı vardı."
    aciklama: "Etkinliğin adı, eski duyuru defterindeki kayıtta yer alıyordu."
  - id: s4
    beceri: cikarim
    dayanak_sayfa: 5
    metin: "Sergi etiketine bilginin dayandığı belgeler neden eklendi?"
    secenekler:
      - {id: A, metin: "Kaynağı ziyaretçinin kontrol etmesi için"}
      - {id: B, metin: "Etiketi daha uzun göstermek için"}
      - {id: C, metin: "Eserlerin satış fiyatını bildirmek için"}
      - {id: D, metin: "Fotoğrafçının adını tanıtmak için"}
    dogru: A
    dayanak: "Öğrenci fotoğrafa yeniden baktı ve altındaki kaynak açıklamasını okudu."
    aciklama: "Kaynak açıklaması, bilginin hangi belgeye dayandığını gösterir; ziyaretçi bu sayede bilginin nereden geldiğini kontrol edebilir."
---
@omurga
Fotoğrafçı {kahraman}, mahalle gazetesinin eski sayılarından bir sergi hazırlıyordu. Bir fotoğrafta çocuklar büyük bir ağacın çevresinde kitap okuyordu. Ancak fotoğrafın altındaki başlık yırtılmıştı. {kahraman}, sergide yanlış bilgi vermemek için görüntünün hangi etkinliğe ait olduğunu bulmak istedi. Arşivde aynı yıla ait çok sayıda gazete vardı; hepsini okumak zaman alacaktı.
---
@omurga
{kahraman} önce fotoğraftaki ayrıntıları sıraladı: masa üzerinde bir sepet, ağacın altında küçük bir afiş ve çocukların elindeki kitaplar. Afişin üst satırında “Kitap” sözcüğü okunuyordu. Yanında çalışan bir arkadaş, eski gazete dizinini getirdi ve “Belki bu bir okuma günüdür,” dedi. Dizinde haberler tarih ve konuya göre sıralanmıştı. İkisi “okuma günü” başlığını aradı, ancak uygun kayıt bulamadı.
---
@omurga
Bir sonraki sayıda aynı ağacın önünde çekilmiş başka bir fotoğraf vardı. Bu fotoğrafın altında “Açık Hava Kitap Paylaşımı” yazıyordu. Ne var ki fotoğraftaki sepet farklıydı. {kahraman}, bu iki görüntünün farklı günlerde çekilmiş olabileceğini düşündü. İlk fotoğrafın tarihini gazete sayısındaki tarih bilgisinden biliyordu. Tarihleri karşılaştırdı ve aralarında bir hafta bulunduğunu gördü. Böylece ilk fotoğrafı yanlış etkinlikle eşleştirmekten vazgeçti.
---
@omurga
Arşiv sorumlusu eski bir duyuru defteri getirdi. Defterde ilk fotoğrafın tarihine ait “Mahalle Kitap Değişim Buluşması” kaydı vardı. Kaydın yanındaki küçük çizimde ağacın bulunduğu meydan işaretlenmişti. {kahraman}, gazeteyi ve duyuru defterini birlikte inceledi. Sergi etiketi için etkinliğin adını ve tarihini yazdı. Ayrıca bilginin hangi belgelere dayandığını ekledi.
---
@omurga
Sergi açıldığında ziyaretçiler fotoğrafın altında kaynak açıklamasını gördü. Bir öğrenci “Bu başlığı nasıl buldunuz?” diye sordu. {kahraman}, yırtık kâğıdı ve karşılaştırdığı kayıtları gösterdi. Öğrenci fotoğrafa yeniden baktı ve altındaki kaynak açıklamasını okudu.
