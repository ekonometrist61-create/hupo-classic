# DUZELTME HR-124 · Karlı Gecenin Son Seferi

Dosya: `icerik/okuma/hikaye/hr124-arac-karli-gecenin-son-seferi.hikaye.md`
Girdi: HR-124-ajan-a.md (karar pass), HR-124-ajan-b.md (karar review_needed)
Kapsam: durum, etiketler (`curriculum_status`), denetim alanları ve pending değerleri değiştirilmedi. `tur` (bilim) değiştirilmedi. `duzeltme_tarihi` 2026-11-08 yapıldı.
Not: Ajan B'nin sayfa numaraları (3 ve 6) dosyadaki @omurga bloklarıyla eşleşiyor; dayanak_sayfa değerleri de uyumlu.

## Uygulanan bulgular

1. **[orta, B] Vaaz cümleleri (sayfa 3 ve sayfa 6).**
   - Sayfa 3, önce: `“Yolcu güvenliği, yetişme isteğimizden önce gelir.” Yolcu haritasını katladı. O da doğru bilgi olmadan karar vermemek gerektiğini kabul etti.` → sonra: `Yolcu haritasını katladı.`
   - Sayfa 6, önce: `Hat görevlisi, “Daha hızlı görünene değil, doğrulanmış olana güvendik,” dedi.` → sonra: silindi. Hikâye, hazırlanan bilgilendirme planıyla biten sahneyle kapanıyor.

2. **[orta, A+B] S2 gerekçe eksikliği.** Metinde ilk gerekçe "tren raylarına bağlı değildi", ikinci gerekçe "üstelik" ile eklenen güvenlik. Şıklarda birinci gerekçe yoktu.
   - Kök önce: `Önerilen kestirme yol neden seçilmedi?` → sonra: `Kestirme yolun reddedilmesine yol açan ikinci gerekçe neydi?`
   - Şık A önce: `Vagonların geç geldiği için` → sonra: `Tren raylarına bağlı olmadığı için` (birinci gerekçe; "ikinci" kökü yüzünden yanlış şık).
   - Doğru şık B ("Güvenliği bilinmediği için") değişmedi.
   - Açıklama: `Kestirme yol önce raylara bağlı değildi (birinci gerekçe); ikinci olarak kar altında güvenliği bilinmiyordu.`

3. **[orta, A+B] "öngörü" gloss'u ve S3 dayanağı (sayfa 4).** Tanım anlatıda verilmiş, doğru şık bu tanımla neredeyse aynıydı.
   - Metin önce: `{kahraman} gecikmeyi öngördü; öngörü, eldeki bilgilerden yararlanarak olacakları önceden düşünmekti.` → sonra: `{kahraman} gecikmeyi öngördü.`
   - Dayanak önce: `{kahraman} gecikmeyi öngördü; öngörü, eldeki ... düşünmekti.` → sonra: `Kuzey dolanma hattı açıktı, ama yolculuk daha uzun sürecekti. {kahraman} gecikmeyi öngördü.` (Bağlam, "olası sonucu önceden düşünme" çıkarımını sağlıyor.)
   - Doğru şık C değişmedi.

4. **[orta, B] Diyalog repliği belirsizdi (sayfa 5).**
   - Önce: `Bir yolcu, “Benim erken inmem gerekmiyormuş; haber verince sorun çözüldü,” dedi.`
   - Sonra: `Yakınına haber veren bir yolcu, “Benim erken inmem gerekmiyormuş; haber verince sorun çözüldü,” dedi.`

5. **[orta, B] Yolcu bilgilendirme cümlesi (sayfa 2, düşük).** `Birkaçı aynı yerde inmek istese de farklı nedenlerle acele ediyordu.` → `Birkaçı aynı yerde inmek istiyordu; kimi akrabasına, kimi sabahki toplantısına yetişmek için acele ediyordu.` (Nedenler sayfa 1'deki bilgiden alındı.)

6. **[düşük, A] Öğrenme hedefi "sorumluluk" metinde geçmiyordu.** Etiket `sorumluluk` → `güvenlik` (metinde "Yolcu güvenliği" ve "güvenle" geçiyor; id `sorumluluk_hr124` korundu).

7. **[düşük, B] S4 kökü hatırlama düzeyinde.** Cevap doğrudan bir cümlenin karşılığıydı.
   - Kök önce: `Yolcuların planlarını değiştirmesine ne yardım etti?` → sonra: `Bazı yolcuların buluşmalarını ertelemesinin nedeni neydi?` (Doğru şık D: "Yeni saatin duyurulması" değişmedi; kök, ertelemenin nedenini açıklatıyor.)

## Uygulanmayan bulgular

- **[düşük, A] Tür etiketi `bilim` ile anlatım (tren ve görevlinin konuşması).** Uygulanmadı. `tur` şema değeridir ve bu bir sınıflandırma kararı; kullanıcıya bırakıldı. Tanıtım metni zaten "tren ve hat görevlisi" olarak kurguyu gösteriyor.
- **[düşük, B] `okuma_bandi` ve `yetiskin_uygun` alanları.** Uygulanmadı; doğrulanmış değer yok, alan eklenmedi.

## Doğrulanamayan olgular

- `okuma_bandi` ve `yetiskin_uygun` değerleri.
- D16 ve D5 değer kodlarının anlamı.
- 5. sınıf kazanım uyumu: `curriculum_status: source_pending`; kazanım kodu yok.
- Demiryolu güzergâh, sinyal merkezi, kuzey dolanma hattı ve kar altı işletme kuralları gerçek işletme kurallarıyla doğrulanmadı; kurgu olarak değerlendirildi.

## Doğrulama

- `node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz hikâye yok, karşılıksız ad yok, art arda tekrar yok.
- Beş dayanak cümlesi gövdede birebir geçiyor.
- Doğru şıklar değişmedi (S1 D, S2 B, S3 C, S4 D, S5 B).
