# HR-125 · Hupo ve Kaybolan Ritim · Düzeltme-2 günlüğü

Kaynak bulgular: HR-125-ajan-a.md, HR-125-ajan-b.md (yeniden denetim).
Ritim kuralı (hızlı ses = küçük nokta, yavaş ses = uzun çizgi) değiştirilmedi.

## Uygulananlar

| Bulgu | Önem | Değişiklik |
|---|---|---|
| s2 dayanağı metinde yok ("bu ses levhanın sesine benziyordu") | yüksek (A), orta (B) | Dayanak, metinde birebir geçen sayfa 3 cümlesine çevrildi: "Rüzgâr durduğunda levha sallanmadı; ama yapraklardan üç damla yine düştü, yavaş ses ise gelmedi." |
| s2 soru sayfa 2'de, çizelge değişikliği sayfa 3'te | orta (A) | `dayanak_sayfa: 2` → `3`; dayanak sayfa 3 cümlesiyle eşleşti. |
| s2 açıklaması "farklı ton" diyor, metin "daha tok" diyor | orta (A) | Açıklama, levha sallanmadığında yavaş sesin gelmediğine bağlandı: "Levha sallanmadığında yavaş ses gelmedi; bu yüzden yavaş sesin levhadan geldiği anlaşıldı." |
| s3 beceri "yorumlama" ama cevap doğrudan metinde | düşük (B) | Beceri `hatirlama` yapıldı. |
| s3 çeldirici B "Acele karar verdi" metnin yakın kopyası | düşük (B) | "Sesi dinlemeden çizelgeyi sildi" ile değiştirildi (metinde geçmeyen eylem). |
| Sayfa 2 "serçe" küçük harf | düşük (B) | "Serçe" olarak düzeltildi. |
| Tanıtım zaman kipi ve belirsiz "levha sesi" | düşük (B) | "ama bir levhanın sesi ritmi bozuyordu." |

## Atlananlar

| Bulgu | Önem | Gerekçe |
|---|---|---|
| "tok" sözlük onayı (TDK) belirtilmeli | düşük (A) | TDK doğrulaması dış kaynak gerektirir; uydurma olmaması için yapılmadı. `sozluk_tdk: pending` alanına dokunulmadı (kural 5). |
| Sayfa 5 son cümle "anlayabiliyordu" | düşük (B) | Cümle somut bir sonucu anlatıyor, vaaz veya kalıp bitiş değil; değişiklik gerekmedi. |
| "tok" transfer hedefi için soru yok | düşük (B) | Yeni soru eklemek soru yapısını değiştirir; düşük öncelik. Atlandı. |

## Denetim
`node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz yok, karşılıksız ad yok, art arda tekrar yok. Bu hikâye cevap harfi dağılımında 3+ tekrar sorunu taşımıyor (A=2, B=1).
