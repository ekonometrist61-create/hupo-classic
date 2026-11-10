# DUZELTME3 · HR-126 · Yağmur Bahçesinin Planı

Girdi: HR-126-ajan-a.md, HR-126-ajan-b.md (yeniden-2). Dosya: icerik/okuma/hikaye/hr126-anne-yagmur-bahcesinin-plani.hikaye.md

## Bulgu → değişiklik

| Bulgu | Seviye | Değişiklik |
|---|---|---|
| Eğim tanımı: metin yalnızca 20 cm yükseklik farkını veriyor, "eğim" diyor (A) | yüksek | Metinde "eğim" kaldırıldı; "yükseklik farkı" ve "yamacın ne kadar dik olduğunu bu fark gösteriyordu" yazıldı. Öğrenme hedefi `egim_hr126` etiketi "eğim" → "yamaç" (id korundu). Oran/eğim tanımı eklenmedi (3. sınıf için fazla yük). |
| Bölüm 2 cümle yükü, 21 sözcük (B) | orta | Cümle ikiye bölündü; ilk cümlede ipin işlevi ("ölçümün düz bir hat üzerinde yapılmasını sağlıyordu") tek cümleyle açıklandı (A düşük bulgu ile birleşti). |
| s3 şıkları farklı türde; "Hiçbir modelde çiçeklik yoktu" metinle çelişiyor (B) | orta | Şıklar aynı türde kuruldu: "Birinci model", "İkinci model", "İkisi birden", "Hiçbiri". Stem "Suyu hangi model topladı?" oldu. Doğru cevap B kaldı. Dayanak metinle birebir. |
| s2 beceri "cikarim" ama doğru şık metinde doğrudan yazılı (A) | düşük | Beceri "hatirlama" yapıldı. |
| s4 beceri "hatirlama" ama soru yorum istiyor (B) | düşük | Beceri "yorumlama" yapıldı. |
| Bölüm 4 açık ders ("Böylece çalışma güvenli yapılabilecekti.") (B) | düşük | Ders cümlesi kaldırıldı; sahneye indirildi: plana "yağmur bahçesinin yolla arasındaki uzaklığı" yazıldı. s4 dayanağı bu sahneye bağlandı; açıklama "amaçlar" diye yumuşatıldı. |
| Transfer hedefi "denetlemek" metinde yalnızca "denetledi" (B) | düşük | Transfer hedefi etiketi "denetlemek" → "kontrol" (id korundu); metinde "kontrol" geçiyor. |

## Atlananlar

- `{kahraman}` yer tutucusunun render'da doldurulup doldurulmadığı (B, düşük): Metin düzeltmesi değil, yayın öncesi render kontrolü. Bu turda render çalıştırılmadı; atlandı.

## Doğrulanamayan (uzman teyidi gerekir)

- Yağmur bahçesinin tanımı ve birikintiyi yürüyüş yolundan uzaklaştırma iddiası (peyzaj/çevre mühendisi).
- İp-cetvelle yükseklik farkı ölçümünün fen açısından doğruluğu.
- "Çevre mühendisinin ölçüleri yeniden denetlemesi" ve "uzman kontrolü" sürecinin kurumsal gerçekliği (A).
- Sınıf 3 kazanım kodu: `curriculum_status: source_pending`; kaynak yok, metadata değiştirilmedi.

## Dokunulmayanlar

YAML `durum: taslak`; `denetim`, `published`, `editor_approved`, `pending` alanları; editör notu bloğu yok (gövde sonunda yalnız hikâye metni var).
Başka dosya değiştirilmedi.

## Kontrol

`node c:\Dev\hupo\tools\okuma-hikaye-denetim.mjs --ayrinti`: sorusuz yok; karşılıksız ad 0; art arda tekrar yok. Bu hikâyenin cevap dizisi (D, C, B, D) tek harfte 3+ tekrar içermiyor.
