# izinli_turler eşleştirme adayları (2026-10-24)

Durum: **ADAY LİSTESİ**. Hiçbir etiket değiştirilmedi. Bir hikâyeye yeni kahraman türü eklemek, o hikâyenin o kahramanla **okunabilir ve doğru** olmasını gerektirir; bu, metin okunarak verilen editoryal bir karardır.

## Yöntem

- Yerel paketlerden (94) `izinli_turler`, sınıf ve `{kahraman}` yer tutucusu sayısı çıkarıldı.
- Metinde ilgili anahtar sözcükler (anne/annem, baba/babam, araba/tren/gemi/balon/roket vb.) sayıldı. Bu bir **ön eleme**; metinde "anne" geçmesi annenin kahraman olabileceğini göstermez.
- Sabit çocuk adı taşıyan (ör. "Mete") ya da kahramanı rolünden ayıran olay örgüsü olan hikâyeler düşük öncelik aldı.

## Mevcut dağılım (yerel paketler)

| Kahraman | Hikâye sayısı |
|---|---|
| ben | 94 |
| arkadas | 94 |
| hayali | 16 |
| baska_biri | 6 |
| hayvan | 3 |
| kardes | 3 |
| **hazir, anne, baba, arac** | **0** |

Sınıf dağılımı: 2. sınıf 2, 3. sınıf 11, 4. sınıf 12, 5. sınıf 20, 6. sınıf 20, 7. sınıf 15, 8. sınıf 14.

## Öncelik ve adaylar

### Annem (`anne`)
Sınıf 3–5 öncelikli, kahraman tokeni olan adaylar: hr015 (3), hr023 (3), hr032 (4), hr040 (4), hr049 (5), hr058 (5).
- hr023 "Hoca ve Görünmeyen Misafir": 13 kahraman tokeni, sınıf 3. Kahramanın rolü öğretmen/hoca ise anneye uyarlamak yeniden yazım gerektirir.
- hr015 "Tohumun Küçük Sırrı": 11 tokeni var, ama kahraman yaşı ve olay bağı bir çocuk-gözlemci gibi; anneye uyarlama için yeniden okuma gerekir.
- **Öneri:** Bu sınıf aralığında yeni hikâye (`anne.md` brief'i) daha güvenli.

### Babam (`baba`)
Sınıf 4–6, kahraman tokeni olan adaylar: hr021 (4), hr030 (4), hr031 (4), hr037 (4), hr078 (6).
- hr078 "Gölün Sessiz Alarmı" (sınıf 6): çevre konusu, kahraman tokeni var; babanın rolüne uygun olup olmadığı okunmalı.
- **Öneri:** Sınıf 4 için yeni hikâye (`baba.md`).

### Araç (`arac`)
Sınıf 5–7 öncelikli: hr058 "Gökyüzündeki Balonun Sırrı" (5; balon ana öğe ama kahraman çocuk), hr068 "Kayıp Geminin Günlüğü" (6; sabit çocuk adı "Mete" var, güvenli değil), hr092 "Denizaltı 09'dan Mesaj" (7), hr100 "Son Turda Yön Değiştirmek" (7).
- Hiçbiri araç-kahraman olarak yazılmamış; araç kahramanına çevirmek anlatıcı değişikliği gerektirir.
- **Öneri:** Yeni hikâye (`arac.md`).

### Hazır Hupo (`hazir`)
Mevcut hikâyelerde hiçbir `hazir` etiketi yok. Hupo'nun kuş olarak kahramanlığı yeni bir dünya ister.
- **Öneri:** Yeni hikâye (`hazir-hupo.md`). Yeniden etiketleme yapılmaz.

### Diğer zayıf kahramanlar (bilgi için)
- Kardeşim (3 hikâye), Hayvan (3), Başka biri (6): ek hikâye ihtiyacı var; bu brief setinin kapsamı dışında.

## Eşleşmeyi tamamlamak için gereken adımlar

1. Yeni hikâyeler `draft` olarak üretilir ve yukarıdaki yayın kapısından geçer.
2. Mevcut adaylar için sınıf 3–5 hikâyeler metin okunarak değerlendirilir; yalnızca kahramanın yerine geçebileceği açıkça görülen hikâyeye etiket eklenir.
3. Her etiket değişikliği ayrı kayıt olarak yazılır (hangi hikâye, hangi tür, gerekçe).

## Yerelde olup veritabanında olmayan hikâyeler

67 hikâye yerelde var, veritabanında yok (sınıf dağılımına dahil). İçe aktarma taslağı: `docs/okuma-entegrasyon/CANLI_TASLAK_yerel_hikayeler_2026-10-24.sql` (uygulanmadı; ayrı onay gerekir; `db:deploy` bekleyen diğer migration dosyalarını da uygular).
