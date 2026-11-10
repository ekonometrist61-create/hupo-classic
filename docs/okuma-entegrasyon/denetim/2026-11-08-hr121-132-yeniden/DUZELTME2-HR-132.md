# HR-132 · Düzeltme 2 günlüğü

Dosya: `icerik/okuma/hikaye/hr132-arac-iki-zaman-cizelgesi.hikaye.md`
Girdi: `HR-132-ajan-a.md`, `HR-132-ajan-b.md` (yeniden denetim)

## Kahraman kararı

Kahraman bir tren (`kahraman_turu: arac`) olarak kaldı. Tren insan eylemlerinden arındırıldı: soru sorma, rapor ekleme, tarih karşılaştırma ve "biliyordu" gibi eylemler görevlilere ya da makinist/merkeze verildi. Kahramanın kendi eylemleri araç eylemleriyle sınırlı tutuldu (yola çıkmak, yönlendirilmek, beklemek, önerileri uygulamamak).

## Uygulananlar

| Bulgu | Önem | Değişiklik |
|---|---|---|
| Kahraman tren ama soru soruyor, rapor ekliyor, tarih karşılaştırıyor, "şaşırdı" ve "biliyordu" (A-yüksek, B-orta) | yüksek / orta | Sayfa 1: "{kahraman} şaşırdı" → "istasyon görevlisi bir an duraksadı"; "{kahraman}, kesin bilgi almadan yola çıkmamak gerektiğini düşündü" → "{kahraman}, kesin bilgi alınmadan yola çıkmadı". Sayfa 2: tarih karşılaştırması "İstasyon görevlisi"ne verildi; son cümle "{kahraman} yanlış saatle yola çıkabilirdi" oldu. Sayfa 3: "{kahraman} ... biliyordu" → "Duraklama sürelerinin ... biliniyordu"; "{kahraman} önerileri doğrudan uygulamadı". Sayfa 4: yolcu sorusu "Görevliler" öznesine verildi. Son sayfa: "sefer raporu" ekleme "görevliler"e verildi. |
| s2 dayanağı tren karşılaştırması ("{kahraman}, ... karşılaştırdı") (A-yüksek) | yüksek | Dayanak "İstasyon görevlisi, iki kâğıdın üzerindeki tarihleri dikkatle karşılaştırdı." olarak metinle birebir eşitlendi. |
| s4 dayanağı tren "biliyordu" (A-yüksek) | yüksek | Dayanak "Duraklama sürelerinin görevli talimatlarına bağlı olduğu biliniyordu." (sayfa 3, metinle birebir). |
| s4 çeldirici D "Makinist bu kararı vermişti" metinle çelişmiyor (A-orta) | orta | D → "Telafi önerileri zaten uygulanmıştı". Metin "önerileri doğrudan uygulamak yerine" dediği için şık çelişiyor. Bu değişiklik "telafi" sözcüğünü de bir çeldiricide test ediyor. |
| Sayfa 5 dolgu: "Kalan yolculuk boyunca ... zihninde karşılaştırdı" (B-düşük) | düşük | Cümle silindi; sayfa bloğu kaldırıldı. Sonuç olarak son durak sayfa 6'dan sayfa 5'e kaydı; s5 `dayanak_sayfa` 6 → 5 yapıldı. Sayfa 2'deki karşılaştırmayla tekrar olan blok bu sayede gitti. |
| Son paragraf ders özeti: "Böylece ertesi gün gelecek yolcular ..." ve "sabaha kadar kimse yanlış bilgiyle yola çıkmadı" (B-düşük) | düşük | Her iki cümle silindi. Sahne "Gece boyunca iki çizelge de panoda, üzerlerindeki açık tarih etiketleriyle kaldı." ile panodaki etiketle bitiyor. |
| tanıtım: "{kahraman}, ... tarihlere bakarak anlar" (insan eylemi) | — | Tanıtım "Hangi çizelgenin geçerli olduğu, kâğıtların üzerindeki tarihlere bakılarak anlaşılır." olarak düzeltildi; kahraman bu cümlede yer almıyor. |
| YAML: `duzeltme_tarihi` | — | "2026-11-08" yapıldı. |

## Atlananlar

| Bulgu | Gerekçe |
|---|---|
| Hedef sözcükler "aktarma", "güzergâh" hiçbir soruda test edilmiyor (B-düşük) | Yalnız "telafi" çeldiricide test edildi. "Aktarma" ve "güzergâh" için soru eklemek ya da bir soruyu yeniden yazmak, sorular ve dayanak sayfaları üzerinde yeni tasarım gerektirirdi; bu tur yalnız bulguları uygulamak için sınırlandı. Kalan iki sözcük sonraki turda değerlendirilmeli. |
| Etiket: tür "bilim" (B-düşük) | Tür etiketi insan kararı; rapor da "karar insanda" diyor. Dosyada değiştirilmedi. |

## Dokunulmayanlar

- `durum: taslak`, `uretim_kaynak`, `etiketler.denetim`, `etiketler.curriculum_status`, `sozluk_tdk`: değişmedi.
- Kahraman türü (arac) ve sahne düzeni (dolgu bloğu dışında) korundu; yeni karakter ya da sahne eklenmedi.
- Doğrulanamayan iddialar (dışarıdan kanıtlanamayan): `yetiskin_uygun: false` alanının anlamı belirsiz (metinde yetişkin teması yok); `deger_anahtarlari` (D16, D1) ve maarif kodlarının içerik karşılığı kod kitabı olmadan doğrulanamadı; `okuma_bandi`, `okuma_zorlugu`, `kavram_zorlugu`, `ilgi_egilimi` alanları raporda değerlendirilmedi; cümle ve sözcük ölçüleri tahmini.

## Doğrulama

- Dayanak cümleleri (s1 sayfa 2, s2 sayfa 2, s3 sayfa 3, s4 sayfa 3, s5 sayfa 5) metnin ilgili sayfalarında birebir mevcut.
- s4 çeldiricileri "Yolcular bekleme süresini kendileri seçmişti" ve "Telafi önerileri zaten uygulanmıştı" metinle çelişiyor; "Kontrol merkezi o gece kapalıydı" da çelişiyor (merkez duyuru yaptı).
- `node tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz yok, karşılıksız ad yok, art arda tekrar yok.
