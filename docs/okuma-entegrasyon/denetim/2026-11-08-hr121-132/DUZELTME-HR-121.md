# DUZELTME HR-121 · Hupo ve Karışan Yankı

Dosya: `icerik/okuma/hikaye/hr121-hupo-yankinin-karisan-sozcukleri.hikaye.md`
Girdi: HR-121-ajan-a.md (karar pass), HR-121-ajan-b.md (karar review_needed)
Kapsam: durum, etiketler, denetim alanları ve pending değerleri değiştirilmedi. `duzeltme_tarihi` 2026-11-08 yapıldı.

## Uygulanan bulgular

1. **[orta, A+B] S2 gerekçesi (sayfa 3 ve aciklama).** Ayrıntı ("harflerin hepsi vardı") ilk tahmini tek başına çürütmüyordu; metinde gerekçe ile ayrıntı arasında bağ kurulmamıştı.
   - Metin önce: `Söylediği sözcükteki harflerin hepsi vardı; yalnızca sıraları değişmişti. “Tahmin etmek yetmedi,” dedi.`
   - Metin sonra: `Söylediği sözcükteki harflerin hepsi vardı; yalnızca sıraları değişmişti. Demek ki asıl mesele harf eksikliği değil, sıraydı. “Tahmin etmek yetmedi,” dedi.`
   - Açıklama önce: `Hupo, defterdeki ayrıntıyı görünce ilk tahminini bıraktı.`
   - Açıklama sonra: `Defterdeki ayrıntı yalnızca harflerin sırasının değiştiğini gösterdi; bu yüzden ilk tahmin yetmedi ve dikkatli dinleme gerekti.`
   - Doğru şık (B) değişmedi. Dayanak cümlesi birebir korundu.

2. **[orta, B] Sonda öğüt cümlesi (sayfa 4).** Kapanış vaaz içeriyordu.
   - Önce: `Hupo defterinin altına şöyle yazdı: “Dikkatli dinle, karşılaştır, sonra karar ver.”`
   - Sonra: `Hupo defterinin altına doğrulanan iki sözcüğü yazdı: masa ve kitap.` (Sayfa 4'te "masa" ve "kitap" zaten doğrulanmış sözcükler olarak geçiyor.)

3. **[düşük, B] Tür belirsizliği (sayfa 1).** `Hupo, kemerin altına kondu` → `Hupo, kemerin altına geçti` (fiil tür belirtmiyor).

4. **[düşük, A] Kurgu notunun görünürlüğü (tanıtım).** Tanıtımda yankının kurgu olduğu belirtilmiyordu.
   - Önce: `...sözcükleri karıştırarak geri getiren bir yankı.`
   - Sonra: `...sözcükleri karıştırarak geri getiren kurgusal bir yankı.`

## Uygulanmayan bulgular

- **[düşük, B] `okuma_bandi` ve `yetiskin_uygun` alanlarının eklenmesi.** Uygulanmadı. Bu alanların değerleri için doğrulanmış bir kaynak yok; değer uydurmak kural 2'ye aykırı. Alanlar eklenmedi; bant ve yetişkin uygunluğu doğrulanamadı olarak kalıyor.

## Doğrulanamayan olgular

- `okuma_bandi` ve `yetiskin_uygun` değerleri (bant uyumu ve güvenlik).
- D12 ve D3 değer kodlarının anlamı (dosyada tanım yok).
- Gerçek yankının sesi aynen geri döndürmesi (sayfa 4 notu). Genel bilgi olarak doğru görünüyor, ancak kaynak dosyası yok; doğrulanmadı.

## Doğrulama

- `node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz hikâye yok, karşılıksız ad yok, art arda tekrar yok (dört hikâyenin hepsi için).
- Dört dayanak cümlesi gövdede birebir geçiyor.
- Cevap dağılımı (bu hikâye): B=2, D=1 (önceki ile aynı; doğru şık değişmedi).
