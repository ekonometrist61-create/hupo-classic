# HupoRead hikâye denetimi · Grup 9 · 2026-10-25

Kapsam: HR-113, HR-114, HR-121, HR-122, HR-123, HR-124.
Yöntem: Güncel hikâye metni okundu; 2026-10-24 ajan A/B raporları (yalnız HR-113 ve HR-114 için mevcut) güncel metne karşı kontrol edildi. Sorular dayanak sayfalarına göre doğrulandı.
Doğrulama: `node tools/okuma-hikaye-denetim.mjs` çalıştırıldı. Dağılım A=108 / B=108 / C=108 / D=107, soru 431, sorusuz yok, karşılıksız ad 0, art arda tekrar yok. Dosyalar parse edildi.

## Eski raporlardaki bulguların güncel durumu (HR-113, HR-114)
Aşağıdakiler eski rapor metninde vardı, güncel metinde zaten düzelmişti; yeniden işlem yapılmadı:
- HR-113 tanıtım "Deniz" → güncel metinde `{kahraman}`.
- HR-114 tanıtım ve s2/s5 "Leyla" → güncel metinde `{kahraman}` ve "Kahraman/Kahramana".
- HR-113 s2 ile sayfa 2 ilk hata cümlesi hizalı.
- HR-113 deyim (`hr113_gormezden`) ve HR-114 deyim (`hr114_panik`) işaretleri metinde yer alıyor (sayfa 21 ve sayfa 4); cümle yalnızca ön yüzde değil, gövdede de görünür.

## HR-113 · Yörünge Dışı — hüküm: review_needed
Düzeltildi:
- s2 çeldiricileri (B, C, D) uzunluk dengesi için yeniden yazıldı: "Hiç hesap yapmamak" → "Kampın günlüğüne her gün yanlış bir tarih yazmak"; "Uydunun adını yanlış yazmak" → "Uydunun adını kâğıda yanlış yazmak ve notları karıştırmak"; "Yörünge çizgilerini çizmemek" → "Yörünge çizgilerini sonradan kâğıda hiç aktarmamak". Dogru (A) değişmedi.
- s3 çeldiricileri (A, B, C) uzunluk dengesi için yeniden yazıldı: "Her zaman" → "Her zaman, hiçbir koşul aranmadan"; "Hiçbir zaman" → "Hiçbir zaman, ne bilgi gelirse gelsin"; "Yalnızca uydu zarar gördüğünde" → "Yalnızca uydu gerçekten zarar gördüğünde".
- s4 çeldiricileri (B, C, D) yeniden yazıldı: "Çok eski ve bilinen", "Uzayda bulunan", "Hızlı hareket eden" → 42–44 karakterlik, açıkça yanlış anlamlı karşılıklar.
- s5 çeldiricileri (A, D) yeniden yazıldı: "Aynı şeydir" → "Riski azaltmak ile kazayı önlemek birbirinin aynısıdır"; "Riskin hiçbir önemi yoktur" → "Riskin azaltılması, değerlendirmede hiçbir önem taşımaz".
- Sayfa 9 (olgu): "Rüzgâr ve boşluk arasında hareket eden iki uyduyu" → "Boşlukta hareket eden iki uyduyu" (uzayda rüzgâr yok).
- Sayfa 34 (süreklilik): "{kahraman} cevap vermeden önce Selçuk Bey'in söylediğini hatırladı: Hatalar saklanırsa tekrarlanır." → "{kahraman} cevap vermeden önce düşündü: Hatalar saklanırsa tekrarlanır." (metinde bu söz daha önce geçmiyor.)
Editör:
- Vaaz tonu (yüksek): Ders cümleleri birçok sayfada açıkça tekrarlanıyor (ajan B listesi: sayfa 6, 8, 14, 22, 32, 34). Yeniden yazım gerekli.
- Tekrar: Sayfa 29–34 aynı tezi üç kez söylüyor (karar notu, kapanış, defter/tavan çıkartmaları). Sayfa 31–33 birleştirilmeli.
- Sayfa 17–20 arası renkli grafik / atık sorusu / sorumluluk tartışması tek sohbet gibi okunuyor; bölüm çıkarılması yazar kararı.
- Uzunluk: 34 sayfa, yaklaşık 3.950 kelime. Kısaltma bu görevde yapılmadı.
- Program etiketi: ön yüz önceki program (8. sınıf) olarak işaretli; resmî eşleştirme insan editörde.
- Sözlük dosyası (kapsam dışı, düzenlenmedi): `icerik/okuma/sozluk/hr113-yorunge-disi.sozluk.json` içinde "kesinlik" yazımı iki girdide geçiyor; hr113_onkabul ("önkabul") TDK doğrulaması bekliyor. Ajan A'nın çekimli girdi bulgusu (belirsizlik/model/olasılık/varsayım) için sözlük temel biçim kararı gerekli.

## HR-114 · Dünyanın Son Kütüphanesi — hüküm: review_needed
Düzeltildi:
- s4 çeldiricileri (A, B, C) uzunluk dengesi için yeniden yazıldı: "Kütüphanedeki boş bir raf" → "Kütüphanedeki boş bir rafın yerini gösteren işaret"; "Bir sayfanın kenarındaki boşluk" → "Bir sayfanın kenarında bırakılmış geniş boş alan"; "Arşivin kapalı olduğu gün" → "Arşiv görevlisinin tatilde olmasından doğan bir gecikme".
- s5 çeldiricileri (B, C, D) yeniden yazıldı: 50–62 karakter. Dogru (A) 68 karakterle hâlâ en uzun seçenek; fark azaltıldı ama tamamen giderilmedi (dogru metinde açık, değiştirilmedi).
Editör:
- Vaaz tonu (yüksek): Ders cümleleri neredeyse her sahnede tekrar ediyor (ajan B listesi: sayfa 8, 12, 16, 18, 26, 33). Yeniden yazım gerekli.
- Tekrar: Sayfa 26–35 arası kütüphanenin açılışı, ad tartışması, ziyaretçi defteri ve final aynı kapanış tezini tekrar ediyor. Sayfa 31–35 birleştirilmeli.
- Sayfa 13–15 düzeltme zinciri ve dijital kılavuz ayrıntıları tek bölümde toplanabilir; okuyucu yükü yüksek; yazar kararı.
- Hak/telif (sayfa 17): genel ilke doğru; ülkeye özgü telif süresi ve çeviri hakkı ayrıntısı hukuki doğrulama gerektirir.
- Sözlük dosyası (kapsam dışı, düzenlenmedi): `hr114-dunyanin-son-kutuphanesi.sozluk.json` içindeki "envanter", "teyit", "uydurma" ve "telaşlanmak" girdileri metinde hiç geçmiyor (kelime sayımı 0). Ajan A'nın çekimli girdi bulgusu (arşiv/tanıklık/panik) için temel biçim kararı gerekli.

## HR-121 · Hupo ve Karışan Yankı — hüküm: pass
Düzeltildi:
- Sayfa 4 notu: "hikâyedeki sözcüklerin tersine dönmesi kurgudur" → "hikâyedeki sözcüklerin harflerinin karışması kurgudur." ("pitak", "kitap"un tersi değil; "patik" olurdu. Not, metindeki gerçek kuralla hizalandı.)
Editör: yok.
Not: Dogru cevaplar (s1 B, s2 B, s3 D) metinde kanıtlı; çeldiriciler makul.

## HR-122 · Taş Köprünün Sırrı — hüküm: pass
Düzeltildi:
- s4 çeldiricisi D: "Arkadaşından duyunca" → "Yerel radyo yayınından duyunca". (Arkadaşın sözü sayfa 5'te yalnızca "fikrini değiştirmeni gördü" diyor; kaynak belirsizliği yaratıyordu.)
Editör: yok.

## HR-123 · Meydandaki Kayıp Heykel — hüküm: pass
Düzeltildi: yok. Sorular ve dayanak sayfaları doğrulandı; s2 dogru (heykel henüz yoktu) metinle tutarlı.
Editör: yok. (Ön yüzde onceki_program: true; sınıf 4 önceki program kuralına uygun.)

## HR-124 · Karlı Gecenin Son Seferi — hüküm: pass
Düzeltildi:
- Tanıtım: "Makinist ve hat görevlisi" → "Tren ve hat görevlisi" (gövdede makinist yok; kahraman tren). Uzunluk 155 karakter.
- s2 çeldiricisi A: "Vagonların çok kalabalık olduğu için" → "Vagonların geç geldiği için" (sayfa 1 "vagonları doluydu" ile çakışıp ikinci bir makul cevap yaratabiliyordu).
Editör: yok.

## Özet
| Hikâye | Hüküm | Düzeltme (Edit) |
|---|---|---|
| HR-113 | review_needed | 7 |
| HR-114 | review_needed | 2 |
| HR-121 | pass | 1 |
| HR-122 | pass | 1 |
| HR-123 | pass | 0 |
| HR-124 | pass | 2 |

Toplam düzeltme: 13. Sözlük dosyaları ve diğer dosyalar değiştirilmedi.
