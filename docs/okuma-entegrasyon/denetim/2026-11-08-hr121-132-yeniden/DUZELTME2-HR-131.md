# HR-131 · Düzeltme 2 günlüğü

Dosya: `icerik/okuma/hikaye/hr131-baba-kayip-basligin-izinde.hikaye.md`
Girdi: `HR-131-ajan-a.md`, `HR-131-ajan-b.md` (yeniden denetim)

## Uygulananlar

| Bulgu | Önem | Değişiklik |
|---|---|---|
| s1 kök-cevap örtüşmesi; doğru şık en uzun şık (B-orta) | orta | Kök "Fotoğrafın hangi bölümü eksikti?" → "Yırtılan kısım neydi?". Doğru şık "Fotoğrafın altındaki başlık" → "Fotoğrafın alt başlığı" (22 karakter; diğer şıklar 20–24). Dayanak ve açıklama değişmedi (sayfa 1 cümlesi birebir). |
| Beceri dağılımı 3 hatırlama / 1 çıkarım; s3 ve s4 dayanakları neredeyse aynı (B-orta) | orta | s4 çıkarıma çevrildi: "Sergi etiketine bilginin dayandığı belgeler neden eklendi?" Doğru şık "Kaynağı ziyaretçinin kontrol etmesi için". Dayanak sayfa 5: "Öğrenci fotoğrafa yeniden baktı ve altındaki kaynak açıklamasını okudu." Çıkarım sayfa 4 (belge eklenmesi) + sayfa 5 (öğrencinin kaynak açıklamasını okuması) üzerine kurulu. Dağılım artık 2 hatırlama / 2 çıkarım. |
| s2 açıklaması ikinci neden ("sepet de farklıydı") veriyor, şıklarda yok (B-düşük) | düşük | Açıklamadan ikinci neden çıkarıldı. |
| s2 çeldirici D "Fotoğraflar tamamen renksizdi" metinle ilgisiz (B-düşük) | düşük | D → "İkinci fotoğrafın altında yazı yoktu". Sayfa 3 metni bu fotoğrafın altında "Açık Hava Kitap Paylaşımı" yazdığını söylediği için şık metinle çelişiyor. |
| Sayfa 3 "gazetenin tarih bilgisi" belirsiz (B-düşük) | düşük | "gazete sayısındaki tarih bilgisinden" olarak netleştirildi. |
| Sayfa 2 afişi betimleniyor ama yazı okunmuyor; eşleşme yalnız tarih/ağaçla kuruluyor (A-düşük) | düşük | Afişe "Afişin üst satırında “Kitap” sözcüğü okunuyordu." eklendi. Sözcük defterdeki "Mahalle Kitap Değişim Buluşması" kaydıyla tutarlı; yeni karakter ya da sahne yok. |
| YAML: `duzeltme_tarihi` | — | "2026-11-08" yapıldı. |

## Atlananlar

| Bulgu | Gerekçe |
|---|---|
| Etiket: tür "gizem" → "bilim" ya da "kanıt" (B-düşük) | Tür etiketi insan kararı; rapor da "karar insanda" diyor. Dosyada değiştirilmedi. |

## Dokunulmayanlar

- `durum: taslak`, `uretim_kaynak`, `etiketler.denetim`, `etiketler.curriculum_status`, `onceki_program`, `sozluk_tdk`: değişmedi.
- Kahraman rolü (baba) ve sahne sırası değişmedi; yeni karakter ya da sahne eklenmedi.
- Doğrulanamayan iddialar (dışarıdan kanıtlanamayan): `yetiskin_uygun: false` alanının anlamı belirsiz (metinde yetişkin teması yok); `deger_anahtarlari` (D6, D16) ve maarif kodlarının içerik karşılığı kod kitabı olmadan doğrulanamadı; `okuma_bandi`, `okuma_zorlugu`, `kavram_zorlugu`, `ilgi_egilimi` alanları raporda değerlendirilmedi.

## Doğrulama

- Dayanak cümleleri (s1 sayfa 1, s2 sayfa 3, s3 sayfa 4, s4 sayfa 5) metnin ilgili sayfalarında birebir mevcut.
- Doğru şıklar dayanak ve açıklamayla tutarlı; çeldiriciler metinle çelişiyor ya da metinde yok.
- `node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz yok, karşılıksız ad yok, art arda tekrar yok.
