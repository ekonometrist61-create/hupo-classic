---
baslik: "Karlı Gecenin Son Seferi"
slug: "hr124-arac-karli-gecenin-son-seferi"
fis_kodu: "HR-124"
tur: bilim
konu: karar_gecikme_dogrulama
sinif_alt: 5
sinif_ust: 5
kahraman_turu: arac
deger_anahtarlari: [D16, D5]
tanitim: "Dağ hattının son gece treni kar yüzünden güzergâh değiştirir. Hat görevlisi, kısa görünen kestirmeyi reddedip doğrulanmış notlara göre karar verir."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-08"
etiketler:
  ana_sinif: 5
  maarif: {ana_deger: D16, yardimci_deger: D5}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: guzergah_hr124, tur: lexeme, etiket: "güzergâh", islev: first_hint}
  - {id: sefer_hr124, tur: lexeme, etiket: "sefer", islev: application}
  - {id: ongoru_hr124, tur: lexeme, etiket: "öngörü", islev: application}
  - {id: guvenlik_hr124, tur: lexeme, etiket: "güvenlik", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 2
    metin: "Seferin güzergâhı neden değişti?"
    secenekler:
      - {id: A, metin: "Biletler bittiği için"}
      - {id: B, metin: "Vagonlar boş olduğu için"}
      - {id: C, metin: "İstasyon kapandığı için"}
      - {id: D, metin: "Yoğun kar yüzünden"}
    dogru: D
    dayanak: "Dağın kısa geçidindeki hat, yoğun kar nedeniyle geçici olarak kapatılmıştı."
    aciklama: "Kısa geçidin hattı yoğun kar yüzünden kapatılmıştı."
  - id: s2
    beceri: cikarim
    dayanak_sayfa: 3
    metin: "Kestirme yolu reddetmelerine neden olan eksik bilgi neydi?"
    secenekler:
      - {id: A, metin: "Yolun daha kısa göründüğü"}
      - {id: B, metin: "Kar altında geçişin güvenli olup olmadığı"}
      - {id: C, metin: "Yolcuların hangi vagonda oturduğu"}
      - {id: D, metin: "Kestirmenin sefer için yeterli durağı olduğu"}
    dogru: B
    dayanak: "Ancak kar altında bu yoldan geçişin güvenli olup olmadığı bilinmiyordu."
    aciklama: "Kestirme yolda kar altında geçişin güvenli olup olmadığı bilinmiyordu; kestirme bu yüzden seçilmedi."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 4
    metin: "“Öngörü” bu hikâyede ne anlama gelir?"
    secenekler:
      - {id: A, metin: "Geçmişteki olayları tamamen unutmak"}
      - {id: B, metin: "Ayrıntılı bir harita çizmek"}
      - {id: C, metin: "Olası sonucu önceden düşünmek"}
      - {id: D, metin: "Yolcuların hepsini saymak"}
    dogru: C
    dayanak: "Kuzey dolanma hattı açıktı, ama yolculuk daha uzun sürecekti. Hat görevlisi gecikmeyi öngördü."
    aciklama: "Öngörü, eldeki bilgilerle olacakları önceden düşünmektir."
  - id: s4
    beceri: yorumlama
    dayanak_sayfa: 5
    metin: "Bazı yolcuların buluşmalarını ertelemesinin nedeni neydi?"
    secenekler:
      - {id: A, metin: "Gecikmenin bir süre gizlenmesi"}
      - {id: B, metin: "İstasyonun kapanması"}
      - {id: C, metin: "Yolun kısalması"}
      - {id: D, metin: "Yeni saatin duyurulması"}
    dogru: D
    dayanak: "Yolculara yeni varış saati duyuruldu."
    aciklama: "Yeni varış saatinin duyurulması, yolcuların planlarını güncellemesini sağladı."
  - id: s5
    beceri: degerlendirme
    dayanak_sayfa: 4
    metin: "Tren ve görevli hangi bilgiyi esas aldı?"
    secenekler:
      - {id: A, metin: "Bir yolcunun kişisel tahminini"}
      - {id: B, metin: "Doğrulanmış hat notlarını"}
      - {id: C, metin: "Eskiden kalma bir söylentiyi"}
      - {id: D, metin: "İlk gördükleri haritayı"}
    dogru: B
    dayanak: "Hat görevlisi işletmenin güncel hat haritasını açtı ve sinyal merkezinden gelen doğrulanmış notları inceledi."
    aciklama: "Karar, sinyal merkezinden gelen doğrulanmış notlara dayandı."
---
@omurga
Dağ hattının son gece seferine hazırlanan {kahraman}, istasyonun ışıkları altında bekliyordu. Vagonları doluydu. Yolcuların hepsi dağ yamacındaki ortak buluşma noktasına gidecekti; kimi akrabasıyla görüşecek, kimi sabahki toplantıya yetişecekti. {kahraman} bir gece treni olarak sefer saatlerine özen gösterirdi. Peronda bir yolcu biletini arıyor, çantasının bütün ceplerini telaşla yokluyordu. Hat görevlisi yolcuya yardım etti. Sonunda bilet bulundu, kapılar kapandı ve sefer başladı.
---
@omurga
Tren yükseldikçe kar taneleri çoğaldı. Bir süre sonra hat görevlisinden haber geldi: Dağın kısa geçidindeki hat, yoğun kar nedeniyle geçici olarak kapatılmıştı. Seferin güzergâhı, yani izlenecek yolu değişmeliydi. {kahraman} durdu. Hat görevlisi yolculara gecikme olacağını bildirdi. Birkaçı aynı yerde inmek istiyordu; kimi akrabasına, kimi sabahki toplantısına yetişmek için acele ediyordu. “Söz verdiğimiz saate yetişebilir miyiz?” diye sordular. Hat görevlisi henüz yanıt veremedi.
---
@omurga
Bir yolcu eski bir servis yolunu gösteren küçük bir harita açtı. “Bu kestirme daha kısa görünüyor,” dedi. Ancak kar altında bu yoldan geçişin güvenli olup olmadığı bilinmiyordu. {kahraman} kestirme yola girmedi. Yolcu haritasını katladı.
---
@omurga
Hat görevlisi işletmenin güncel hat haritasını açtı ve sinyal merkezinden gelen doğrulanmış notları inceledi. Kuzey dolanma hattı açıktı, ama yolculuk daha uzun sürecekti. Hat görevlisi gecikmeyi öngördü. Görevli, merkezin izin verdiği yeni güzergâhı teyit etti. Kontrol bitmeden {kahraman} hareket etmedi.
---
@omurga
Yolculara yeni varış saati duyuruldu. Bazıları yakınlarını bilgilendirdi; bazıları buluşmalarını ertelemeye karar verdi. Hat görevlisi onlara neden gecikeceklerini açıkça anlattı. Yakınına haber veren bir yolcu, “Yakınıma haber verince erken inmem gerekmedi,” dedi. Tren, açık olan raylardan ağır ağır ilerledi. Pencerelerde karın örttüğü ağaçlar göründü. Vagonun içindeki telaş yerini sakin bir bekleyişe bıraktı.
---
@omurga
Gece ilerlediğinde tren buluşma noktasına ulaştı. Tarifeden geç kalmıştı ama herkes güvenle inmişti. {kahraman}, son yolcu inene kadar kapılarını açık tuttu. Son yolcu da ayrılınca hat görevlisi ertesi seferin çizelgesine baktı. Bu kez olası gecikmeler için bilgilendirme planı da hazırlandı.
