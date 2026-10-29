# Görselli soru üretim programı

Seçilen ders ve sınıf için şekilli/görselli çoktan seçmeli soruları üretir. LLM yazmaz: şablon soruyu kurar, çizim motoru şekli çizer, cevap ve çeldiriciler kodla hesaplanır. Tasarım, garantiler ve kararlar: `docs/soru-uretim/GORSELLI_SORU_PLANI.md` §11.5.

## Hızlı kullanım
```
node tools/gorsel-motoru/testler.mjs                                  # tüm testler (42)
node tools/gorsel-motoru/uret.mjs --dogrula                           # kayıt sözleşmesi
node tools/gorsel-motoru/uret.mjs --liste                             # şablon listesi
node tools/gorsel-motoru/uret.mjs --ders matematik --sinif 5 --kod MAT.5.5.1 --adet 40 --tohum 7 --klasor <dizin>
node tools/gorsel-motoru/uret.mjs --hepsi --adet 20 --tohum 1 --klasor <dizin>     # her kazanım kodu için bir klasör + ozet.json
node tools/gorsel-motoru/uret.mjs --kor-sonuc <klasor>                # kör çözüm cevaplarını uygula, kararı yaz
```
Ortak seçenekler: `--adet` (1–200, varsayılan 20), `--tohum` (varsayılan 1; aynı tohum aynı çıktı), `--png-yok` (PNG adımını atla).

## Çıktı klasörü
```
<klasor>/
  sorular.json     üretilmiş kayıtlar (durum: "beklemede", insan_onayi: null)
  rapor.json       karar, üretim sayıları, harf dengesi, kapı sonuçları, kör çözüm sonucu
  kontak.html      insan onayı sayfası (soru, şekil, işaretli cevap, gerekçeler)
  kor/             kör çözüm girdileri ve cevapları (git dışı)
    kor_gorselli.json     soru + PNG yolu (cevap anahtarı YOK)
    kor_gorselsiz.json    yalnız soru ve şıklar (cevap anahtarı YOK)
    svg/, png/            görsel dosyaları
    gorselli_cevap*.json  Haiku'nun PNG'ye bakarak verdiği cevaplar  ← elle eklenir
    gorselsiz_cevap.json  Haiku'nun şekilsiz verdiği cevaplar        ← elle eklenir
```

## Kararlar
| Karar | Anlamı | Çıkış kodu |
|---|---|---|
| `KAPI_RED` | Metin ya da görsel kapısı en az bir soruyu reddetti | 1 |
| `EKSIK_URETIM` | İstenen adet üretilemedi (şablonun farklı soru kapasitesi yetmedi) | 3 |
| `KOR_BEKLIYOR` | Kapılar geçti; kör çözüm cevapları henüz yok | 0 |
| `KOR_GECTI` / `KOR_GECMEDI` | n ≥ 40 ile kör çözüm kararı | 0 / 1 |
| `ON_GECTI` / `ON_GECMEDI` | n < 40; yalnız ön bilgi | 0 |
| (kullanım/kayıt hatası) | | 2 |

Kör çözüm eşikleri: görselli uyum ≥ %95 (şekle bakarak doğru çözülmeli), görselsiz uyum ≤ %40 (şekilsiz çözülmemeli; şans ≈ %25). Karar için n ≥ 40 gerekir.

## Kör çözüm adımı (elle, Haiku ile)
1. `kor/kor_gorselli.json` içindeki her PNG'yi görerek çöz → `kor/gorselli_cevap.json` (`[{"id","cevap","gerekce","belirsiz"}]`).
2. `kor/kor_gorselsiz.json` yalnız metinle çöz → `kor/gorselsiz_cevap.json` (`[{"id","cevap","belirsiz"}]`).
3. `node tools/gorsel-motoru/uret.mjs --kor-sonuc <klasor>` → rapor güncellenir, karar yazılır.
Çözücüye `sorular.json` ve `rapor.json` verilmez (cevap anahtarı içerir).

## Yeni ders veya şablon
1. Gerekirse yeni **şekil tipi**: `tipler.mjs` ya da `tipler-ek.mjs` içine `render(parametreler, profil) → { sahne, alt, olgular }` ekle ve `TIPLER` / `TIPLER_EK`'ye kaydet. `olgular` çözücüdür (cevabı şekilden kodla hesaplar). `alt` cevabı, skala değerlerini ya da sınır değerlerini yazmamalı.
2. **Şablon**: `sablonlar/<ad>.mjs`. `kur({R, sec, karistir, ekle, konum})` üreticileri döndürür; `KAYIT` dizisi `{id, ders, sinif, idOnek, mufredat_surum, kodlar: [tek kod], fabrika, uret}` verir.
   - Kazanım kodu yalnız `docs/soru-uretim/pilot/kazanim_<sınıf>_<ders>.json` içinde olmalı; yoksa `--dogrula` hata verir.
   - Doğru şık konumu: şablon `konum()` ile yeri alır; şıklar sabit sıralıysa doğru şık tam o indekse konur (`konum_uyumsuz` aksi halde).
   - Çeldiriciler tek bir parametreye işaret etmemeli (ardışık pencere ya da başka parametrelerin sonuçları); aksi halde şekilsiz çözülür.
3. `node tools/gorsel-motoru/uret.mjs --dogrula`, sonra `testler.mjs`, sonra üretim ve kör çözüm.

## Bilinen sınırlar
- Trafik ışığı (HB.1.2.3) şablonunda yalnız 6 farklı soru var; 20 istendiğinde `EKSIK_URETIM` çıkar. Kapasite artışı için yeni soru türü gerekir.
- Çubuk örüntüsü (MAT.5.2.3) kapasitesi 22: n ≥ 40 kararı verilemez, yalnız ön bilgi.
- Kör çözüm Haiku ile elle yapılır; program yalnız cevapları karşılaştırır.
- İngilizce ve Din Kültürü için kazanım kaynağı yok; şablon yazılmaz.
- Kayıt doğrulaması PNG ve kapı için Python 3 + PyMuPDF gerektirir (yoksa `png` atlanır ve `kor_png.tamam` false olur).

## Dosyalar
`uret.mjs` komut satırı · `uretici.mjs` üretim çekirdeği, kayıt doğrulaması, denge · `paket.mjs` çıktı klasörü, kapılar, karar · `kor.mjs` kör çözüm kuralı · `kapi-gorsel.mjs` görsel kapısı · `kontak.mjs` onay sayfası · `kor-karsilastir.mjs` kör çözüm CLI · `motor.mjs` spec→SVG · `lint.mjs` görsel kontrol · `cekirdek.mjs` sahne/palet/profil · `tipler.mjs` + `tipler-ek.mjs` şekil tipleri (14) · `sablonlar/` şablonlar (17) · `svg2png.py` PNG · `testler.mjs` ve `*.test.mjs` testler.
