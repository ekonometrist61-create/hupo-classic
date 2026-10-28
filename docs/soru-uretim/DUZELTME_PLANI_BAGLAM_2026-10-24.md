# Soru bankası düzeltme planı: bağlamsız soru kökleri (2026-10-24)

Tetikleyici: panelde "Ali'nin geriye kaç bilyesi kaldı?", "Bu modele göre hangi cümle doğrudur?" gibi sorular bağlamsız görünüyor.
Kural dayanağı: skill "Soru kuralları" ve REHBER §18: bağlam ölçülen süreçle birlikte verilir; kök metne referans verir; ipucu cevabı açmaz.

## 1. Kök neden (kanıtlı)
Paket şemasında (`docs/soru-uretim/paket/*.json`) soru için **bağlam/pasaj alanı yok**. Alanlar: `soru_metni`, `siklar`, `dayanak`, `cozum_adimlari`, `ipucu`…
Yazar durum bilgisini `dayanak` ve `cozum_adimlari[0]` içine yazmış; bunlar öğrenciye gösterilmiyor. Örnek: `mat1-09` dayanağı "Ali'nin 15 bilyesi vardı. Ali 4 bilyesini arkadaşına verdi"; `soru_metni` yalnız "Ali'nin geriye kaç bilyesi kaldı?". Çözüm adımı "15 - 4" bilgisini öğrenci hiç görmüyor. `hb1-*` çözümlerinde "Pasaja göre…" geçiyor ama pasaj yok.
Türkçe 5–8 sorularında pasaj `soru_metni` içine gömülü; orada sorun yok.

## 2. Tarama sonucu (661 soru, 12 paket dosyası, betikle; `_db_` kopyaları hariç)
Yöntem: kök kısa + dayanak kökte yok + "Yukarıdaki/Bu/Aynı…" göstergesi; ikinci geçişte dayanaktaki sayı ve adların kök+şıklarda bulunmaması. Sonra 65 adayın tamamı elle okundu.

| Bölüm | Sınıf / ders | Soru | Bağlamı eksik (kesin) | Not |
|---|---|---|---|---|
| B1 | 1. sınıf (Türkçe, Matematik, HB) | 46 | **22**: tr1-21..24, mat1-01..07, 09..11, 13, 14, hb1-05, 06, 08, 09, 10 | mat1-12, hb1-01/02/04/07 kökü bağımsız; yalnız çözümde "pasaj" dili düzelir |
| B2 | 2. sınıf (+ek2) | 74 | 0 kesin | Kökler kendi başına anlaşılıyor; stil gözden geçirmesi (aşağıdaki §4) |
| B3 | 4. sınıf ve 5. sınıf Fen/Sosyal (paket 2026-10-21) | 314 | 0 kesin | Aynı: stil geçişi |
| B4 | 5, 7, 8. sınıf Türkçe | 71 | 0 | Pasaj gömülü; yalnız şık dengesi/kanıt kontrolü |
| B5 | tr6, tr6_duzeltme, revizyon_geri17 | 156 | 0 | Aynı |

Dürüst sınır: bu bir sezgisel tarama + elle okuma. `soru_kontrol.mjs` ve `kapi.cjs` çalıştırılmadı; şık uzunluğu, ipucu sızıntısı, tek doğru cevap ve kanıt düzeyi bu turda ölçülmedi. Uzak veri tabanındaki satırlar ayrıca kontrol edilmedi (panel orayı gösteriyor; paket JSON'u kaynak kabul edildi).

## 3. Düzeltme yöntemi (B1 için)
Şema değiştirmeden: `dayanak` içindeki durum bilgisi `soru_metni`'nin **başına** taşınır (Türkçe 5–8'de zaten böyle). Panel yalnız `soru_metni`'ni gösterdiği için yeni alan gerekmez.
Kurallar:
- Kök kendi başına anlaşılır: kim, ne var, ne soruluyor.
- Sabit ad yerine hikâye kahramanı kullanılabilir ama çocuk adı/gerçek veri yok (çocuk verisi kuralı); mevcut Ali/Ayşe adları korunur.
- Görsel gerektiren öğeler (kartlar, kavanoz, oy tablosu, aile resmi, model) **metinle** anlatılır; `gorsel_gerekli` false kalır.
- Cevap/şık değişmez; yalnız kök zenginleşir. İpucu ve çözüm, eklenen bağlamla çelişmeyecek biçimde güncellenir; "Pasaja göre" ifadeleri kaldırılır.
- "Yukarıdaki cümle" soruları (tr1-21..24): cümle kökün içine yazılır.
- Kök, şıkta aynen geçen cümle taşımaz; ipucu cevabı vermez (skill kuralı 11–12).
- Her düzeltilen soru için `revizyon` alanına "2026-10-24 bağlam eklendi" notu; `onay_durumu` `beklemede`, `kalite_durumu` `sari` kalır.

## 4. Sonraki dönüş: soru sorma tarzı (B2–B5)
Bağlam dışında, skill'in "Önce kontrol et" 1–13 maddeleri ve `soru_kontrol.mjs` her bölümde şu sırayla:
1. `kapi.cjs` + `soru_kontrol.mjs` (şık uzunluğu, hepsi/hiçbiri, dayanak birebirliği, 6-gram, kanıt asırı iddia).
2. Kök tarzı: "Aşağıdakilerden hangisi doğrudur?" gibi genel kökler, olumsuzluk, öznel kök.
3. Kör çözüm farklı model ailesiyle (üreten kendi işini puanlamaz).
4. Bölüm sonunda `ogrenme-gunlugu.md` girişi; kanıt etiketleri kurala göre yeniden atanır.

## 5. İş akışı ve onaylar
- Düzeltme paket JSON'larında yapılır (klasör şu an git'te izlenmiyor); uzak DB'ye aktarım ayrı adım ve **kullanıcı onayı** ister (SISTEM §7.4). Paket→DB aktarım betiği bu turda bulunamadı; aktarım öncesi bulunacak/doğrulanacak.
- `published`/`onaylandi` hiçbir adımda değişmez.
- Bölümler sırayla; her bölüm sonunda önce/sonra örnekleri gösterilir, onay sonrası sıradakine geçilir.

## 6. Durum
| Bölüm | Durum |
|---|---|
| Tarama + plan | TAMAMLANDI (bu belge) |
| B1 1. sınıf | Düzeltildi; uzak DB'ye 2026-10-25 uygulandı (26 satır, `docs/soru-uretim/uygulama/2026-10-25_1sinif_baglam_duzeltme.sql`); panelde kullanıcı kontrolü bekliyor |
| B2 2. sınıf (104 soru) | Tarandı 2026-10-25: düzeltme gerekmedi (günlükte kayıtlı); B3 sırada |
| B3 paket 2026-10-21 (4–6. sınıf, 314 soru) | Tarandı 2026-10-25: düzeltme gerekmedi (günlükte kayıtlı); B4 sırada |
| B3 ek geçiş (kör çözüm Gemini, Fen/Sosyal çeldirici okuma, olgu kontrolü) | Yapıldı 2026-10-25: 314/314 uyuştu; 3 küçük not günlükte, düzeltme yok |
| B4 5, 7, 8. sınıf Türkçe (gerçek sayı 83, plandaki 71 yanlıştı) | Denetlendi 2026-10-25: 83/83 uyuştu; tr8-012 noktalama belirsizliği (öneri günlükte), düzeltme yok |
| B4 düzeltme | tr8-012 şıkları sadeleştirildi (noktalama belirsizliği giderildi), 2026-10-25 |
| B5 tr6 + revizyon + düzeltme (gerçek sayı 114, plandaki 156 yanlıştı) | Denetlendi 2026-10-25: 114/114 uyuştu; tr6 paketinde 39 bozuk kapanış tırnağı düzeltildi |
| Kazanım kodu, resmî PDF'e karşı (B1–B5, 661 soru) | Yapıldı 2026-10-25: 634 birebir; 8 kod canlı DB'de düzeltildi; 5 karar bekliyor (ayrıntı ogrenme-gunlugu.md) |





