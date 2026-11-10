# DUZELTME HR-123 · Meydandaki Kayıp Heykel

Dosya: `icerik/okuma/hikaye/hr123-baba-meydandaki-kayip-heykel.hikaye.md`
Girdi: HR-123-ajan-a.md (karar review_needed), HR-123-ajan-b.md (karar review_needed)
Kapsam: durum, etiketler (`onceki_program`, `curriculum_status`), denetim alanları ve pending değerleri değiştirilmedi. `duzeltme_tarihi` 2026-11-08 yapıldı.
Not: Ajan B'nin sayfa numaraları dosyadaki @omurga bloklarıyla eşleşmiyor (dosyada 5 sayfa var; "sayfa 6" ifadesi yok). Düzeltmeler dosya içeriğine göre yapıldı; dayanak_sayfa değerleri içerikle uyumlu olduğu için değiştirilmedi.

## Uygulanan bulgular

1. **[orta, A+B] S2 kanıt mantığı (sayfa 2, doğru D, açıklama).** Tek bir gazete karesinde heykelin görünmemesi, heykelin o yıl "henüz olmadığını" kesinleştirmiyordu (kadraj dışı olabilir).
   - Metin önce: `ama o fotoğrafta heykel henüz yoktu. “Demek ki ilk düşündüğümüz yıl olamaz,” dedi {kahraman}.`
   - Metin sonra: `ama o karede heykel görünmüyordu. “Demek ki ilk düşündüğümüz yıl şüpheli,” dedi {kahraman}.`
   - Kök önce: `İlk düşünülen yılın yanlış olduğu nasıl anlaşıldı?` → sonra: `İlk düşünülen yıldan neden kuşku duyuldu?`
   - Şık D önce: `O yıl heykel henüz olmadığı için` → sonra: `O karede heykel görünmediği için`
   - Dayanak önce: `...ama o fotoğrafta heykel henüz yoktu.` → sonra: `...ama o karede heykel görünmüyordu.`
   - Açıklama önce: `Şenlik yılının gazetesindeki fotoğrafta heykel bulunmadığı için o yıl yanlıştır.` → sonra: `Şenlik yılının gazetesindeki fotoğrafta heykel görünmüyordu; bu yüzden ilk yıl kesin sayılmadı.`
   - Doğru şık yine D.

2. **[orta, A] Ağaç boyutu tarihleme kanıtı (sayfa 3).** Ağaç büyüdüğü için iki yıllık karede aynı boyutta görünmesi tarihleme kanıtı değildi.
   - Önce: `İki fotoğrafta da heykelin arkasındaki ağaç aynı büyüklükteydi.`
   - Sonra: `Heykelin arkasındaki ağaç da iki fotoğrafta benzer görünüyordu.` (Taş döşeme deseni destekleyici ayrıntı olarak kaldı.)

3. **[orta, B] Anlatı içi gloss (sayfa 2 ve 4).**
   - Sayfa 2, önce: `Arşiv, belgelerin korunup gerektiğinde bulunabildiği yerdi.` → sonra: silindi (arşiv görevlisinin eylemi zaten gösteriyor).
   - Sayfa 4, önce: `Haber, komşunun sözlerini destekleyen bir kanıttı. Kanıt, bir düşüncenin doğru olup olmadığını anlamaya yardım eden bilgiydi.` → sonra: `Haber, komşunun sözlerini destekleyen bir kanıttı.`

4. **[orta, B] S3 dayanağı tanımı kopyalıyordu (sayfa 4).** Dayanak tanımın kendisiydi.
   - Dayanak önce: `Kanıt, bir düşüncenin doğru olup olmadığını anlamaya yardım eden bilgiydi.` → sonra: `Haber, komşunun sözlerini destekleyen bir kanıttı.`
   - Açıklama önce: `Metinde kanıt, bir düşüncenin doğruluğunu destekleyen bilgi anlamındadır.` → sonra: `Metinde gazete haberi, komşunun sözünü doğrulayan bir kanıt olarak kullanılır; yani kanıt doğrulamaya yarayan bilgidir.`
   - Doğru şık (A) değişmedi.

5. **[orta, B] Son replikteki öğüt (sayfa 5).**
   - Önce: `“Karşılaştırmak bana acele etmemeyi öğretti.” Ertesi gün fotoğrafı tekrar arşive koydu.`
   - Sonra: `Ertesi gün fotoğrafı tekrar arşive koydu.`

6. **[orta, B] Açılıştaki tarih ipucu açılmadan kalıyordu (sayfa 1).** Heykelin altındaki tarih hiçbir yerde okunmuyor, gizemin parçası olarak kalıyordu.
   - Önce: `Heykelin altında belli belirsiz bir tarih görünüyordu.` → sonra: silindi.

7. **[düşük, A] Öğrenme hedefi etiketi.** Metinde "karşılaştırma" isim olarak geçmiyor, yalnız fiiller geçiyor.
   - Etiket önce: `karşılaştırma` → sonra: `karşılaştırmak` (id `karsilastirma_hr123` korundu).

## Uygulanmayan bulgular

- **[düşük, B] S1 kökü dayanakla aynı bilgiyi tekrar ediyor.** Uygulanmadı. Hatırlama sorusu; kök metinde ilk sayfadaki ayrıntıyı doğrudan soruyor ve bu düzeyde kabul edilebilir. Kök değiştirilmedi (düşük ve isteğe bağlı).
- **[düşük, B] `okuma_bandi` ve `yetiskin_uygun` alanları.** Uygulanmadı; doğrulanmış değer yok.
- **[gözlem, uygulanmadı] Sayfa 5'teki çocuk replikiyle ilgili sözleri.** `Tek bir fotoğrafla karar verseydin tarihi yanlış yazacaktın,` replik bulgu olarak raporlanmadı; kapsam dışı bırakıldı. Ders niteliği taşıdığı için kullanıcı son okumada değerlendirebilir.

## Doğrulanamayan olgular

- `okuma_bandi` ve `yetiskin_uygun` değerleri.
- D12 ve D6 değer kodlarının anlamı.
- 4. sınıf kazanım uyumu: `onceki_program: true` ve `curriculum_status: source_pending`; kazanım kodu bu denetimde yok.
- Arşiv ve gazete süreçleri (ilan, kapak, açılış haberi, meydan düzenlemesi) kaynakla doğrulanmadı; kurgu olarak değerlendirildi.

## Doğrulama

- `node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz hikâye yok, karşılıksız ad yok, art arda tekrar yok.
- Dört dayanak cümlesi gövdede birebir geçiyor.
- Doğru şıklar değişmedi (S1 A, S2 D, S3 A, S4 C).
