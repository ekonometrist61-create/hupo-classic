# DUZELTME HR-122 · Taş Köprünün Sırrı

Dosya: `icerik/okuma/hikaye/hr122-anne-tas-koprunun-sirri.hikaye.md`
Girdi: HR-122-ajan-a.md (karar pass), HR-122-ajan-b.md (karar review_needed)
Kapsam: durum, etiketler, denetim alanları ve pending değerleri değiştirilmedi. `duzeltme_tarihi` 2026-11-08 yapıldı.

## Uygulanan bulgular

1. **[orta, A] Ölçüm yöntemi (sayfa 2).** Cetvel ve ip ile çatlağın uzaktan ölçülmesi fiziksel olarak mümkün değil; ölçülen büyüklük tanımsızdı.
   - Önce: `Çatlağı uzaktan fotoğraflayıp güvenli bir noktadan ölçüm yaptılar. Ölçüm, bir büyüklüğün ne kadar olduğunu belirlemek demekti. Cetvel ve işaretli bir ip kullandılar.`
   - Sonra: `Çatlağın fotoğrafını güvenli bir noktadan çektiler. Sonra çatlağın köprü kenarına olan uzaklığını görevlilerin izniyle, yakından cetvel ve bölmeli bir ip kullanarak ölçtüler.`
   - Ölçülen büyüklük (köprü kenarına uzaklık) tanımlandı; yakın temas için görevli izni notu eklendi.

2. **[orta, B] Anlatı içi sözlük gloss'ları (sayfa 1, 2).**
   - Önce: `yani henüz doğrulanmamış bir düşünce olduğunu biliyordu` → Sonra: `yalnızca bir tahmin olduğunu biliyordu`.
   - Önce: `Ölçüm, bir büyüklüğün ne kadar olduğunu belirlemek demekti.` → Sonra: silindi (bulgu 1 ile birlikte).

3. **[orta, B] S3 dayanağı tanımı birebir veriyordu (sayfa 3).** Dayanak "yani yüke karşı ne kadar sağlam kaldığını" tanımını taşıyordu ve soru bağlamdan değil eşleştirmeden çözülüyordu.
   - Önce (metin): `“Bu taşın dayanıklılığını, yani yüke karşı ne kadar sağlam kaldığını uzman ekip incelemeli,” dedi {kahraman}.`
   - Sonra (metin): `“Bu taşın dayanıklılığına, köprünün ağırlığını yıllarca taşıyıp taşıyamayacağına uzman ekip bakmalı,” dedi {kahraman}.`
   - Dayanak aynı cümleye göre güncellendi. Doğru şık (B: "Taşın sağlam kalabilmesini") değişmedi; anlam artık "ağırlığını yıllarca taşıyıp taşıyamayacağı" bağlamından çıkarılıyor.
   - Açıklama: `...köprünün ağırlığını uzun süre taşıyabilme, yani sağlam kalabilme anlamındadır.`

4. **[orta, B] Son replikteki öğüt (sayfa 5).**
   - Önce: `{kahraman} da gülümsedi. “İlk tahminim yanlış olabilir. Önemli olan, elimizdeki bilgilere göre doğru kararı vermek.” Sonra ölçüm defterini kapattı.`
   - Sonra: `{kahraman} da gülümsedi. Sonra ölçüm defterini kapattı.`

5. **[düşük, A+B] S4 beceri ve kök (yorumlama → hatirlama; kök hizalama).** Cevap metinde doğrudan verilmiş bilgi; kök "fikir" ile metindeki "tahmin" sözcüğünü eşleştirmiyordu.
   - Beceri: `yorumlama` → `hatirlama`.
   - Kök önce: `Kasabalılar köprü mühendisinin fikrini nasıl değiştirdiğini nereden öğrendi?` → Kök sonra: `Kasabalılar mühendisin önceki tahmininin neden değiştiğini nereden öğrendi?` (Dayanak "önceki tahmininin neden değiştiğini" ile hizalı.)

6. **[düşük, B] Sınıf 3 sözcük yükü.** Açıklayıcı sözcükler sadeleştirildi: `bağlantı noktalarını` → `birleştiği yerleri`; `işaretli bir ip` → `bölmeli bir ip`. Hedef sözcükler (ölçüm, çatlak, dayanıklılık, tahmin) korundu.

## Uygulanmayan bulgular

- **[düşük, A] S2 kayıt penceresi.** Uygulanmadı. Kayıtların hangi süreyi kapsadığını yazmak yeni bir olgu eklemek olur (kural 2). Metin zaten "doğru olmayabilir" diye temkinli; dayanak ("daha önceki haftalarda") korundu.
- **[düşük, B] `okuma_bandi` ve `yetiskin_uygun` alanları.** Uygulanmadı; doğrulanmış değer yok, alan eklenmedi.
- **[düşük, B] `{kahraman}` yer tutucusunun dayanak alanında geçmesi.** Hikâye metni değil, render kontrolü gerektiriyor. Dayanak, gövdedeki birebir metni tutsun diye yer tutucu korundu. Render'da dayanak metninin de doldurulduğu doğrulanmalı (aşağıda).

## Doğrulanamayan olgular

- `okuma_bandi` ve `yetiskin_uygun` değerleri (bant uyumu ve güvenlik).
- D6 ve D16 değer kodlarının anlamı.
- Köprü ölçüm ve onarım süreci ayrıntıları (kaynak yok; kurgu olarak değerlendirildi).
- `{kahraman}` yer tutucusunun S4 dayanağında uygulamada doldurulup doldurulmadığı.

## Doğrulama

- `node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz hikâye yok, karşılıksız ad yok, art arda tekrar yok.
- Dört dayanak cümlesi gövdede birebir geçiyor.
- Doğru şıklar değişmedi (S1 C, S2 A, S3 B, S4 C).
