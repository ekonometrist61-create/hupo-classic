---
baslik: "Sisli Gecede Yan Hat Kararı"
slug: "hr128-arac-sisli-istasyonun-isiklari"
fis_kodu: "HR-128"
tur: macera
konu: sorumluluk_karar_kosul
sinif_alt: 5
sinif_ust: 5
kahraman_turu: arac
deger_anahtarlari: [D16, D5]
yetiskin_uygun: false
tanitim: "Sisli bir gecede bir tren, kısa görünen yan hattı kullanmak isteyen yolcularla karşılaşır. Kontrol merkezinin bilgisine göre karar verir."
durum: taslak
uretim_kaynak: llm_taslak
duzeltme_tarihi: "2026-11-09"
etiketler:
  ana_sinif: 5
  maarif: {ana_deger: D16, yardimci_deger: D5}
  kanit_duzeyi: C
  curriculum_status: source_pending
  denetim: {ajan_a: pending, ajan_b: pending, insan: pending}
  sozluk_tdk: pending
ogrenme_hedefleri:
  - {id: sefer_hr128, tur: lexeme, etiket: "sefer", islev: first_hint}
  - {id: guzergah_hr128, tur: lexeme, etiket: "güzergâh", islev: application}
  - {id: ongoru_hr128, tur: lexeme, etiket: "öngörü", islev: application}
  - {id: sorumluluk_hr128, tur: lexeme, etiket: "sorumluluk", islev: transfer}
sorular:
  - id: s1
    beceri: hatirlama
    dayanak_sayfa: 2
    metin: "Hız sınırı niçin düşürüldü?"
    secenekler:
      - {id: A, metin: "Raylar yeni boyandığı için"}
      - {id: B, metin: "Vagon sayısı bu gece arttığı için"}
      - {id: C, metin: "Sisin görüşü azalttığı için"}
      - {id: D, metin: "Güneş ufukta erken doğduğu için"}
    dogru: C
    dayanak: "Sis nedeniyle bir kesimde sinyalin görülmesi zorlaşmıştı."
    aciklama: "Sis yüzünden sinyal zor görülüyordu; bu yüzden hız sınırı düşürüldü."
  - id: s2
    beceri: hatirlama
    dayanak_sayfa: 3
    metin: "Yan hat neden kullanılmadı?"
    secenekler:
      - {id: A, metin: "Yan hat açık olduğu için"}
      - {id: B, metin: "Bakımda olduğu için"}
      - {id: C, metin: "Daha uzun olduğu için"}
      - {id: D, metin: "Biletler tükendiği için"}
    dogru: B
    dayanak: "Merkez, yan hattın bakım için kapalı olduğunu bildirdi."
    aciklama: "Merkez yan hattın bakımda olduğunu bildirdi; bu yüzden kullanılmadı."
  - id: s3
    beceri: sozcuk_baglami
    dayanak_sayfa: 4
    metin: "“Öngörü” sözcüğü neyi anlatır?"
    secenekler:
      - {id: A, metin: "Geçmişi anlatan belgeyi"}
      - {id: B, metin: "Her zaman kesin olarak bilinen bilgiyi"}
      - {id: C, metin: "İstasyonun eski adını"}
      - {id: D, metin: "Koşullara göre yapılan tahmini"}
    dogru: D
    dayanak: "{kahraman} bu yeni saatin bir öngörü olduğunu açıkladı."
    aciklama: "Öngörü, eldeki koşullara göre yapılan tahmindir."
  - id: s4
    beceri: hatirlama
    dayanak_sayfa: 4
    metin: "Görevli yolculara hangi bilgiyi duyurdu?"
    secenekler:
      - {id: A, metin: "Yan hattın o gece açık olduğunu"}
      - {id: B, metin: "Makinistin değiştiğini"}
      - {id: C, metin: "Tahminî varış saatini"}
      - {id: D, metin: "Gecikmenin yalnızca bakımdan olduğunu"}
    dogru: C
    dayanak: "Makinist dikkatle ilerledi, görevli de tahminî varış saatini yolculara duyurdu."
    aciklama: "Görevli, tahminî varış saatini yolculara duyurdu."
  - id: s5
    beceri: yorumlama
    dayanak_sayfa: 6
    metin: "Sefer defterine neden açıklama eklendi?"
    secenekler:
      - {id: A, metin: "Makinistin mesaisini kayda geçirmek için"}
      - {id: B, metin: "Sonraki yolculuklarda kullanılacak bilgiyi bırakmak için"}
      - {id: C, metin: "Yan hattın açık olduğunu kanıtlamak için"}
      - {id: D, metin: "Hızı biraz daha artırmak için"}
    dogru: B
    dayanak: "Ertesi sefer için bu kayıtlar işe yarayacaktı."
    aciklama: "Kayıtlar, sonraki seferlerde kullanılacak bilgi olarak tutuldu."
---
@omurga
{kahraman}, dağ hattında çalışan konuşkan bir gece treniydi. Günün son seferine başlarken vagonlarındaki yolcuları selamladı. Küçük istasyondan ayrılırken görevliden yeni bir duyuru geldi: Yüksek kesimlerde sis artıyordu. Sefer çizelgesinde varış saati belliydi; buna karşılık yol koşulları değişebilirdi. {kahraman}, söz verdiği saatte varmak istiyordu; ama önce yol koşullarını öğrenmek gerekiyordu.
---
@omurga
Bir iş insanı, ertesi sabah yapılacak bir toplantıya yetişmek için erken varmak istediğini anlattı. Başka biri ise karşı istasyonda bekleyen kardeşine haber vermeyi düşünüyordu. Yolcular farklı ihtiyaçlar dile getirince vagonda tartışma başladı. {kahraman}, makiniste ve hat görevlilerine ulaşan bildirimleri dinledi. Sis nedeniyle bir kesimde sinyalin görülmesi zorlaşmıştı. Bu yüzden hız sınırı düşürülmüştü.
---
@omurga
Arka vagondaki yolculardan biri, “Eski yan hattı kullansak daha çabuk gideriz,” dedi. {kahraman} yan hattın o gece açık olup olmadığını bilmiyordu. Makinist, hat kontrol merkezinden doğrulama istedi. “Bilmeden yan hattı açmayalım,” dedi. Merkez, yan hattın bakım için kapalı olduğunu bildirdi.
---
@omurga
{kahraman}, güvenli güzergâhta devam etmek için verilen talimata uydu. Makinist dikkatle ilerledi, görevli de tahminî varış saatini yolculara duyurdu. {kahraman} bu yeni saatin bir öngörü olduğunu açıkladı. Her yolcu gecikmenin nedenini öğrendi. Toplantıya yetişecek kişi, yeni saate göre planını değiştirmek için haber gönderdi.
---
@omurga
Sis gittikçe yoğunlaştı, ancak hat kontrolü ve işaretler izlenerek yolculuk sürdü. Yolcular pencereden yalnızca yakındaki ışıkları seçebiliyordu. {kahraman}, her işaretten sonra hat kontrolüne yeniden bildirdi. Gecikme can sıkıcıydı.
---
@omurga
Son istasyonda yolcular indiğinde görevli gecikme bilgisini sefer defterine kaydetti. {kahraman}, verilen kararın sorumluluğunu üstlenerek nedenlerini de not ettirdi: yoğun sis, sınırlı görüş ve kapalı yan hat. Ertesi sefer için bu kayıtlar işe yarayacaktı. Gece treni dinlenmeye çekilirken kayıtlar sefer defterinde duruyordu.
