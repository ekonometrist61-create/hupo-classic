# Kelime Evreni — MEB'e göre söz varlığı veri tabanı

Kapsam: 1–8. sınıf. Eş anlamlı, zıt anlamlı ve eş sesli sözcük ilişkileri. Oyunun içerik kaynağıdır; veritabanına (uzak Supabase) henüz **uygulanmadı**.

## Dosyalar

| Dosya | İçerik |
|---|---|
| `mufredat.json` | MEB programlarından birebir alınmış 18 kazanım alt maddesi (kod, sınıf, resmî metin, kaynak) |
| `sinif-1.json` … `sinif-8.json` | Her sınıfın ilişkileri (118 kayıt) |
| `dogrula.mjs` | Yapısal doğrulama: alan tipleri, id tekrarı, sözcük türü çakışması, kazanım eşleşmesi, örnek cümlede hedef sözcük |

Çalıştırma: `node docs/kelime-evreni/veritabani/dogrula.mjs` (HATA: yok, 2026-10-21 son durum)

## Kayıt yapısı

```json
{
  "id": "s4-10",
  "tur": "es_anlamli",
  "a": { "kelime": "gayret", "anlam": "...", "sozcuk_turu": "isim" },
  "b": { "kelime": "çaba",   "anlam": "...", "sozcuk_turu": "isim" },
  "ornek": "Sınava hazırlanırken gösterdiğim gayret ve çaba meyvesini verdi.",
  "teknik": "hareket",
  "hatirlatici": "Gayret ve çaba aynı yolda birlikte yürür.",
  "kazanim": "T.O.4.2.h",
  "kazanim_ek": ["T.K.4.2.ğ", "T.Y.4.2.ı"]
}
```

- `tur`: `es_anlamli`, `zit_anlamli`, `es_sesli`. Eş sesli kayıtta iki sözcük aynı yazılışta, anlamları farklıdır.
- `sozcuk_turu`: `isim`, `sifat`, `fiil`, `zarf`, `baglac`, `diger`. Aynı (kelime, anlam) çifti farklı sınıflarda tekrar edebilir; çelişen sözcük türü validator'da hata sayılır.
- `teknik`: çocuğa öğretilirken kullanılan hafıza tekniği (çağrışım, hikâye, görsel, hareket, ses, eşleştirme, karşıtlık).
- `kazanim` ve `kazanim_ek`: `mufredat.json` anahtarları. Anahtar bulunmazsa validator hata verir.

Veritabanına aktarım için eşleme: `a`/`b` → `kelime_anlamlari` (kelime, anlam, sozcuk_turu); `tur` → `kelime_iliskileri.iliski_turu`; `sinif` → `kelime_sorulari.sinif` (soru üretimi ayrı bir adım).

## Kaynaklar ve kazanım eşlemesi

Kazanım kodları ve metinleri MEB'in iki resmî programından **alındı**; kod uydurulmadı.

- 1–4. sınıflar: *Türkçe Dersi (1, 2, 3 ve 4. Sınıflar) Öğretim Programı* (2026), mufredat.meb.gov.tr, `202681493354625-Türkçe (1-4) DÖP TTKB.pdf`. Sözcük kazanımları T.O.x.2 (okuma), T.K.x.2 (konuşma), T.Y.x.2 (yazma) alt maddelerinde geçer.
- 5–8. sınıflar: *Ortaokul Türkçe Dersi Öğretim Programı* (2025), mufredat.meb.gov.tr, `202582516532361-ortaokul türkçe.pdf`. Eş ve yakın anlamlı, zıt anlamlı ve eş sesli sözcükler **T.K.5.22 / 6.22 / 7.22 / 8.22 (b)** kazanımında ortaktır. Yazma açıklaması T.Y.x.18 ve okuma açıklaması T.O.x.21 kavram alanı olarak bu sözcükleri anar.

| Sınıf | Program durumu | Eş anlamlı | Zıt anlamlı | Eş sesli |
|---|---|---|---|---|
| 1 | Açık kazanım yok (hazırlık) | 0 | 8 | 0 |
| 2 | Yalnızca zıt anlamlı (T.O.2.2.f, T.K.2.2.d) | 0 | 12 | 0 |
| 3 | Zıt ve eş anlamlı (T.O.3.2.h) | 8 | 6 | 0 |
| 4 | Üç tür (T.O.4.2.h) | 5 | 6 | 6 |
| 5 | T.K.5.22.b | 8 | 8 | 2 |
| 6 | T.K.6.22.b | 7 | 8 | 2 |
| 7 | T.K.7.22.b | 8 | 8 | 1 |
| 8 | T.K.8.22.b | 7 | 7 | 1 |

Eş sesli sayısı bilerek düşük tutuldu. Yalnızca köken olarak ayrı, yazılışı aynı sözcükler alındı (ör. `yüz`, `yaş`, `kaz`, `at`). Aynı kökten gelen çok anlamlı sözcükler (ör. `ay` gök cismi/takvim ayı, `dil` organ/dil, `kanat`, `kök`) eş sesli sayılmadı; bunlar ayrı bir "çok anlamlılık" kategorisine aittir.

## Doğrulama durumu

1. **Yapısal:** `dogrula.mjs` geçiyor (0 hata).
2. **Dil denetimi, tur 1 (Sonnet 5.5):** 118 kayıt incelendi. 70 kayıtta bulgu çıktı (6 kritik, 15 yüksek). Kritik bulgular: çok anlamlı kayıtların eş sesli olarak etiketlenmesi (ay, dil, kanat, kök, ağız, kulak), eş anlamlı olmayan `tutum–davranış` çifti, bazı örnek cümlelerde hedef sözcüğün bulunmaması. Hepsi düzeltildi.
3. **Dil denetimi, tur 2 (Sonnet 5.5):** Karar "küçük düzeltme gerekir". Yüksek bulgu olarak `s7-03` (sağlık mesajı içeren örnek) işaretlendi ve düzeltildi. Orta/düşük maddelerin çoğu (örnek cümle, hatırlatıcı, tanım) uygulandı.
4. **Son yama turu:** Tur 2'deki önerilere göre yapılan son düzeltmeler (17 kayıt) Sonnet tarafından **yeniden denetlenmedi**.

### Açık şüpheler (yayın öncesi dil uzmanı ve TDK kontrolü gerekir)

- `s7-16` `dolu` ve `s6-15` `yar`: sözlükle doğrulandı (teyit bölümüne bakın). `yar` 6. sınıf için seyrek olabilir; editör kararı.
- `s5-15` `sol` (yön/nota): sözlükte bulunamadı.
- `s4-01` `yüz` (sayı) sözcük türü `diger` olarak bırakıldı; şemada "sayı" türü yok.
- `s4-04` `çay`, `s4-06` `bağ`, `s4-03` `yaz`, `s4-02` `gül`: köken ayrımı büyük olasılıkla doğru ama TDK'da ayrı madde olduğu doğrulanmadı.
- TDK (sozluk.gov.tr) doğrulaması yapılamadı: denemelerde 502 hatası alındı.

## Sözlük teyidi (dilbilgisi.net, 2026-10-21)

Kaynak: dilbilgisi.net eş anlamlı, zıt anlamlı ve eş sesli sözlükleri (harf sayfaları). Kayıt bazındaki sonuçlar `teyit-dilbilgisi.json` dosyasında.

| Durum | Adet | Anlamı |
|---|---|---|
| `dogrulandi` | 75 | Çift sözlükte karşılıklı listelenmiş |
| `kismi` | 5 | Kelimeler var, ama çift farklı veriliyor: s6-01 amaç–hedef, s6-08 dürüst–yalancı, s8-05 alışkanlık–âdet, s8-09 bağımsız–bağımlı, s8-11 olumlu–olumsuz |
| `sozlukte_yok` | 38 | Çift bulunamadı. Kayıt yanlış sayılmaz; sözlük sınırlıdır |

- **Eş sesli:** 12 çiftin 10'u sözlükle doğrulandı. `yar` sözlükte "uçurum" ve "yarmak" olarak geçiyor; "sevgili" anlamı sözlükte yok, kaldırıldı. `sol` (yön/nota) sözlükte yok; kayıt korundu, ayrıca kontrol edilmeli.
- **Siteye göre düzeltilenler:** s4-16 kalabalık–ıssız → kalabalık–tenha; s6-10 verimli–verimsiz → verimli–kısır; `yüz`, `çay`, `yaş`, `kaz`, `dolu` tanımları sözlük metnine yaklaştırıldı.
- **Doğrulanamayanlar:** 38 çiftin yayın öncesi ikinci bir kaynakla (TDK, dil uzmanı) kontrol edilmesi gerekir.
- **Olumlu–olumsuz:** sözlük müspet/menfi karşılıklarını veriyor; çift dolaylı.
- Veri tabanına aktarılmadı; uzak Supabase'e yazım için ayrıca onay gerekir.

## Bilinen sınırlar

- MEB 5–8. sınıf kazanımı sınıflar arasında ortak metinle yazılı; sınıf bazlı ayrım yalnızca sözcük zorluğunda yapıldı.
- 1. sınıfta eş/zıt anlam kazanımı programda yok. Bu kayıtlar `kapsam: hazirlik` ile işaretli ve oyuna girmeden editör onayı gerekir.
- Eski program (2019) kazanım kodları (ör. T.4.3.7–9) okul dökümanlarında görüldü ama resmî metinde doğrulanmadı; kullanılmadı.
- Mevcut uzak veritabanındaki 93 anlamlık başlangıç içeriği (`20261022000001_kelime_evreni_baslangic_icerik.sql`) ile birleştirme kararı verilmedi. Çakışan kayıtlar yalnızca `(kelime, anlam)` çifti üzerinden eşleşir.
- Kelime soruları (`kelime_sorulari`) bu veritabanında yok. İlişkilerden üretilecek; ayrı bir adımdır.
- Uzak Supabase'e uygulama için kullanıcı onayı gerekir (`npm run db:preview` / `db:deploy`).
