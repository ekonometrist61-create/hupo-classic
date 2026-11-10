# HR-127 · Baba ve Ters Çevrilen Fotoğraf · Düzeltme-2 günlüğü

Kaynak bulgular: HR-127-ajan-a.md, HR-127-ajan-b.md (yeniden denetim).

## Uygulananlar

| Bulgu | Önem | Değişiklik |
|---|---|---|
| Yılın 1969'a nasıl daraldığı açık değil (A orta) | orta | Sayfa 4: takvimin yetersizliği belirtildi; arkadaşın gazetenin o haftaki sayısındaki bir haberin tarihine ve bir önceki sayının tarihine baktığı, ikisinin de 1969'u gösterdiği yazıldı. s3 ve s4 dayanakları (`iki ayrı sayıyı karşılaştırarak`, `kaynakları yeniden kontrol etti`) aynen korundu. |
| Numara ile basılı sayı arasında bağlantı yok (B orta) | orta | Sayfa 3: "Bu numara, fotoğrafın gazetenin hangi basılı sayısından alındığını gösteriyordu." eklendi. |
| s2 beceri "cikarim" ama cevap sayfa 3'te doğrudan (B orta) | orta | Beceri `hatirlama` yapıldı. |
| `{yoldas:yalin|bir arkadaş}` yer tutucusu, frontmatter'da `yoldas` yok (A düşük, B düşük) | düşük | Sayfa 2 ve 4'teki yer tutucular düz "bir arkadaş" yapıldı. |
| Başlık "Babam ..." birinci tekil, metin üçüncü kişi (B düşük) | düşük | "Baba ve Ters Çevrilen Fotoğraf" (slug değişmedi). |
| Tanıtım çözümü baştan veriyor (B düşük) | düşük | "Fotoğrafçı {kahraman}, bunun nedenini ve fotoğrafın yılını kaynaklara bakarak araştırır." |
| Sayfa 4 uzun cümle (B düşük) | düşük | Takvim cümlesi, "Bu yüzden yıl için başka bir kaynak gerekiyordu." ile ayrılarak kısaltıldı. |
| s4 çeldirici A en uzun şık (B düşük) | düşük | A: "Sadece tek fotoğrafa bakılarak" (doğru şık D'ye yakın uzunluğa çekildi). |

## Atlananlar

Yok.

## Dikkat
- Sayfa 4'e eklenen "bir önceki sayının tarihi" ve "1969 gösteriyordu" ayrıntıları kurgusal kanıt; gerçek bir gazete arşiviyle doğrulanmadı. Hikâye kurgusal olduğu için olgusal iddia sayılmaz, ancak `kanit_duzeyi: C` ve `source_pending` durumu korunur.
- 17 Mayıs 1969'un Cumartesi olduğu takvim hesabıyla yeniden kontrol edildi (1 Ocak 1969 Çarşamba; 17 Mayıs 137. gün, Cumartesi). Doğru.

## Denetim
`node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz yok, karşılıksız ad yok, art arda tekrar yok. Cevap harfi dağılımı (A=2, B=0, C=1, D=1) sorun oluşturmuyor.
