# HR-131 · Babam ve Kayıp Başlığın İzinde · Düzeltme günlüğü

Dosya: `icerik/okuma/hikaye/hr131-baba-kayip-basligin-izinde.hikaye.md`
Girdi: HR-131-ajan-a.md, HR-131-ajan-b.md
Sonuç: 10 bulgudan 9'u tam, 1'i kısmen uygulandı, 0 atlandı. Durum `taslak`, `denetim` alanları `pending` olarak bırakıldı.

## Uygulanan bulgular

1. **[A orta] İlk fotoğrafın tarihinin kaynağı yazılmamıştı** (s2 ve s3 zinciri bu tarihe dayanıyor)
   - Önce: "Tarihleri karşılaştırdı ve aralarında bir hafta bulunduğunu gördü."
   - Sonra: "{kahraman}, ... düşündü. İlk fotoğrafın tarihini gazetenin tarih bilgisinden biliyordu. Tarihleri karşılaştırdı ve aralarında bir hafta bulunduğunu gördü."
   - Not: Kaynağın "gazetenin tarih bilgisi" olarak seçilmesi kurgusal bir ayrıntıdır (olgusal bir dış iddia değildir). Editör başka bir kayıt tercih ederse değiştirebilir.

2. **[A düşük + B orta] `{yoldas:yalin|bir arkadaş}` yer tutucusu, front matter'da `yoldas` tanımı yok**
   - Önce: "Yanında çalışan {yoldas:yalin|bir arkadaş}, eski gazete dizinini getirdi."
   - Sonra: "Yanında çalışan bir arkadaş, eski gazete dizinini getirdi ve “Belki bu bir okuma günüdür,” dedi."
   - Front matter'a dokunulmadı; yer tutucu düz metne çevrildi. Bu aynı zamanda yardımcı karakterin tek replik almasını sağladı (B orta, gerilim bulgusunun parçası).

3. **[A düşük] s2 açıklaması ikinci gerekçeyi (sepet) söylemiyordu**
   - Önce: "Tarihler karşılaştırılınca iki fotoğrafın farklı günlere ait olduğu anlaşıldı."
   - Sonra: "... anlaşıldı; fotoğraftaki sepet de farklıydı."
   - Soru tek doğru şıkka (C) daraltılmadı; açıklama metindeki her iki gerekçeyi anıyor.

4. **[B yüksek] Sayfa 5 son paragraflarda açık ders**
   - Önce: "“Bir fotoğraf bize çok şey anlatır,” dedi, “ama her sorunun cevabını tek başına vermez.”" ve "...onun ardındaki araştırmayı da merak ediyordu."
   - Sonra: "Öğrenci fotoğrafa yeniden baktı ve altındaki kaynak açıklamasını okudu." (replik çıkarıldı, sonu eylemle bitiyor.)

5. **[B orta] Sayfa 2 karakter doğrudan kural koyuyordu**
   - Önce: "{kahraman}, yalnızca görüntüye bakarak etkinliğe ad vermenin doğru olmayacağını söyledi."
   - Sonra: çıkarıldı. Sayfa 2 "İkisi “okuma günü” başlığını aradı, ancak uygun kayıt bulamadı." ile biter; karakterin tutumu arama eyleminde görünür.

6. **[B orta] Gerilim zayıf: KISMEN**
   - Yardımcı karakter artık tek replik alıyor ve dizinde yanıltıcı bir "okuma günü" ipucu var (sayfa 2).
   - Yapılmayan: rapor, "afişteki tarih okunamıyor" gibi yeni bir engel ya da yeni bir olay önerdi. Kural 5 ("yeni olay ekleme, düzeltme minimal olsun") gereği eklenmedi. Gerilimin yeterli olup olmadığı editör kararına bırakıldı.

7. **[B düşük] Sayfa 4 içsel onaylama ("bilgilerin birbirini desteklediğini anladı")**
   - Önce: "{kahraman}, gazeteyi ve duyuru defterini birlikte inceleyince bilgilerin birbirini desteklediğini anladı."
   - Sonra: "{kahraman}, gazeteyi ve duyuru defterini birlikte inceledi."

8. **[B düşük] s1 doğru şık en kısaydı ve kökle örtüşüyordu**
   - Önce: "Altındaki başlık" → Sonra: "Fotoğrafın altındaki başlık".

9. **[B düşük] s4 beceri etiketi yanlıştı** (cevap metinde doğrudan geçiyor)
   - Önce: `beceri: yorumlama` → Sonra: `beceri: hatirlama`. Soru metni değişmedi.

10. **[B düşük] Front matter `yetiskin_uygun` eksik**
    - `yetiskin_uygun: false` eklendi.

## Atlanan bulgular
Yok.

## Doğrulanamayan olgular (değiştirilmedi, listelendi)
- `onceki_program: true` (sınıf 4): kazanım kodu yok (`curriculum_status: source_pending`); kazanım eşlemesi doğrulanamadı.
- TDK karşılıkları ("arşiv", "dizin", "kayıt") doğrulanmadı (`sozluk_tdk: pending`).
- D6 ve D16 değer kodlarının anlamı doğrulanmadı.
- Etkinlik adları, arşiv kayıtları ve gazete dizinleri kurgusal; gerçek bir kuruma veya kişiye atıf yok.
