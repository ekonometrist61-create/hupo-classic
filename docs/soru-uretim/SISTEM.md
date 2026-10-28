# Soru ve Deneme Sistemi — tek kaynak (2026-10-24)

Bu belge soru üretimi, denetimi ve deneme derlemesinin **tek mantığıdır**. REHBER, PLAN, pedagoji paketi ve skill'ler ayrıntı verir; çelişkide bu belge geçer. Önceki ONAYLI kararlar (telif, 3 göz, kanıt tablosu, uzunluk tek başına red değildir) aynen korundu. Bu yapı kullanıcının "tek mantığa oturt" yönlendirmesiyle kuruldu; işaretli maddeler ajan önerisidir.

## 1. Değişmezler — hiçbir hız veya kolaylık bunları aşmaz
1. **Özgünlük/telif.** MEB veya yayınevi sorusu, şıkkı, görseli ya da yakın parafrazı çoğaltılmaz. Kaynak yalnız blueprint olur (kazanım, bilişsel eylem, çeldirici deseni). Yazar kaynak soruyu görmez. Üçüncü taraf arşivler repoya girmez.
2. **Tek doğru cevap.** Hesaplı sorularda sayısal doğrulama, diğerlerinde anahtarsız bağımsız çözüm anahtarla uyuşur. Uyuşmazlıkta soru düzeltilir, anahtar değiştirilmez.
3. **Kazanım beyanı.** Kod yalnız kaynakta görülürse yazılır; uydurulmaz. 2026–27'de 4. ve 8. sınıf önceki programdır: kod "önceki program" etiketiyle yazılır, A verilmez.
4. **Çocuk verisi.** Gerçek ad, konum, fotoğraf içerikte ve kayıtta yok; kişiselleştirme yer tutucuyla.
5. **Yayın insan kararıdır.** Otomatik kapıyı geçmek yayın değildir. Veri tabanına her giriş `beklemede`; `onaylandi` yalnız kullanıcı onayıyla.
6. **Dürüst rapor.** Yapılmayan kontrol "yapıldı" yazılmaz; kaynakta olmayan kota, tarih veya kod uydurulmaz.
7. **Vaat yok.** Puan, sıralama, garanti, "MEB onaylı" iddiası yok.

Bunların dışındaki her şey **kalite kuralıdır**: REHBER §18 yazar, `kapi.cjs` denetler; ihlal soruyu düzeltir, hattı durdurmaz.

## 2. Soru hattı — 5 adım, 4 rol
| # | Adım | Kim | Çıktı |
|---|---|---|---|
| 1 | **Üret**: hücre = sınıf × ders × kazanım; özgün, blueprint-first | Sonnet | taslak |
| 2 | **Otomatik kapı**: `tools/soru-uretim/kapi.cjs` (şema, kod, hesap, şık dengesi, benzerlik 6-gram). Türkçe pasaj sorularında ek: `soru_kontrol.mjs` | Haiku çalıştırır | RED / KONTROL |
| 3 | **Kör çözüm**: anahtarsız çözülür | Haiku | uyuşur / uyuşmaz |
| 4 | **Kör kalite**: geçerlik, çeldirici, dil, yaş. Üretici kendi işini puanlamaz; ayrı oturum, anahtar sonra açılır | Sonnet (Opus yalnız hassas konu: din, tarih, siyaset) | GEÇER / DÜZELT / RED |
| 5 | **Aktarım ve onay**: `beklemede` → kullanıcı onayı → `onaylandi` | Haiku aktarır, kullanıcı onaylar | DB durumu |

Başka durum etiketi yok. DB: `beklemede` / `onaylandi` / `reddedildi`; `kalite_durumu`: `sari` (insan örneklemi yapılmadı) / `yesil`. **BEKLET** = benzerlik şüphesi: aktarılmaz, kullanıcı bakar. Pass kavramı yok: kapı "KONTROL" der, onay insandır.

## 3. Kanıt (kazanım) düzeyi — A / B / C
Kural tablosu `meb-soru-sozcuk-uzmani/SKILL.md` "Kanıt düzeyi" bölümündedir (ONAYLI) ve değişmedi. Özet: **A** = resmî metinde bulunan okuma/çözümleme kazanımı + dayanak pasajda birebir + program TYMM. **B** = tahmin, yorum, yazma, anahtar kelime vb. veya A koşulu eksik. **C** = `source_pending` (resmî metin yok, 4 ve 8. sınıf). D yok: üretimden çıkar (RED). Her yeni soru bir kod taşır; kaynakta kod bulunamayan hücre kapalı kalır (örnek: İngilizce 2, K-0105).

## 4. Deneme = derleme, üretim değil
Deneme sınavı, **onaylı havuzdan seçilen soru listesidir** (`deneme_sinavlari` + `deneme_sinavi_sorulari`). Deneme için ayrı kalite hattı yoktur; yeni soru gerekiyorsa §2 çalışır.

**Girdi:** sınıf, kapsam, ders kotası (blueprint).
- **Kapsam kaynağı** (`kapsam_kaynagi`): `ogretmen` | `veli` | `onceki_sinif`. `onceki_sinif` yalnız sene başı sınavı için varsayılandır (çocuk önceki yılın kazanımlarını işlemiş sayılır; ÖNERİ, ONAY BEKLİYOR). Takvim ve üçüncü taraf site kapsam kanıtı değildir. Kapsam, kazanım kodu listesidir; havuzdaki sorular o kodlara etiketlidir.
- **Seçim kuralları:** yalnız `onaylandi`; sınav içinde tekrar yok; kapsam dışı soru yok; ders kotası tam; doğru şık harfi dengeli (her harf ≤ %35); zorluk dağılımı yaklaşık 40/40/20 (tahmin, vaat edilmez).
- **Havuz yetersizse** eksik hücreler listelenir ve §2 hattına gider; sınav eksik soruyla aktif edilmez.
- **Arşiv yapısı** (soru sayısı, ders dağılımı) yalnızca blueprint önerisidir: `docs/deneme-sinavi/ilk-deneme-blueprint-2026-27.json`.

**1–4. sınıf ürün kuralı (biçimlendirici):** puan, sınıf içi sıra, net ve süre baskısı yok; doğru sayısı ve konu geri bildirimi var. `sure_dakika` DB'de zorunlu (5–240); baskı yok ilkesiyle 120 önerilir (ÖNERİ). **Uygulama durumu:** `admin_get_mock_exam_results` sıra üretiyor ve veli paneli `CocukDenemeGecmisi` "puan · sıra" gösteriyor; bu düzeltilene kadar 1–4. sınıf sınavları `aktif=false` kalır.

**Modlar:** tek tablo `.claude/skills/hupo-deneme-uzmani/references/modlar.md`. LGS, OYSS, ortak yazılı ve okul adına yapı ayrı ürün sınırıdır; kılavuz veya senaryo belgesi yoksa üretilmez.

## 5. Kim ne yapar (token)
- **Haiku:** kapı çalıştırma, kör çözüm, sayım/envanter, aktarım JSON/SQL (kalıplı), havuz sorgusu, deneme derleme taslağı, biçim denetimi.
- **Sonnet:** soru üretimi, kör kalite, blueprint, çelişki çözümü.
- **Üst model:** yalnız hassas içerik denetimi, mimari, güvenlik, karmaşık SQL.
- **Kullanıcı:** onay, insan örneklemi, kapsam listesi, uzak DB yazma onayı.

## 6. Çelişki çözümleri
| Konu | Karar |
|---|---|
| Kod yoksa (RED / source_pending / thematic / review_needed) | Yeni soru: kod yoksa üretilmez. Eski içerik: C (`source_pending`). |
| Benzerlik: BEKLET mi RED mi | Eşik üstü = BEKLET (insan bakar); kaynakla aynı 6-gram dizisi = RED. |
| İnsan denetimi | 3 göz: iki otomatik/AI adım + kullanıcı (ONAYLI). %10 örneklem yapılmazsa `sari`. |
| Yayın bileşimi (A+B+Hakem C / iki çözücü / iki pass) | §2: kör çözüm + kör kalite + kullanıcı. Hakem C kaldırıldı. |
| Kalite denetçisi Opus mu Sonnet mi | Sonnet; Opus yalnız hassas konu. |
| Pass tanımı | Kaldırıldı: KONTROL (otomatik) ≠ onay (insan). |
| Şık sayısı | 4 (A–D). 1. sınıfta 3 şık gerekirse kapıya parametre, istisna kayıtlı. |
| Zorluk ölçeği | 1/2/3 (DB `smallint`); "kolay/orta/zor" kullanılmaz. |
| Bağlam | Zorunlu değil; varsa ipucu vermez, ölçülen süreçle birlikte verilir. |
| Mod adları | Deneme için `modlar.md`; soru üretiminde mod yok. |
| Kapı/aşama sayıları (G0–G8, 12 aşama, 10 adım, 7 kapı) | Soru ve deneme için kullanılmaz; yalnız §2. G0–G8 hikâye ve sözlük yayını için geçerli kalır. |
| Roller (15 ad) | Yazar, çözücü, kalite denetçisi, kullanıcı. "Ajan A/B" yalnız hikâye denetimi. |
| Kapı betikleri | Soru için `kapi.cjs`; Türkçe pasaj ek kontrolü `soru_kontrol.mjs`. `kalite_kapilari.py` ve `validate_content.py` bu hatta yok. |

Çözümü gerekmeyen planlama çelişkileri (5→8 sırası, 4. sınıf ilerleme sayıları, yayınevi hukuk görüşü) bu belgenin konusu değildir; kaynak PROJE_GUNLUGU'dur.

## 7. Kararlar (kullanıcı onayları, 2026-10-24)
1. **Onaylandı:** sene başı sınavının kapsamı önceki sınıf (`onceki_sinif`); 2. sınıf sene başı için kapsam 1. sınıf plan kazanımları. Süre 120 önerisi onaylandı (1–4 için baskısız).
2. **Onaylandı:** dağılım = TYMM taslak yıllık planın saat payı (1–2. sınıf için yayımlanmış soru dağılım tablosu yok; ODSGM tabloları 5–8).
3. **Onaylandı:** plan kazanım kodları resmî sayılır (kapsam dışı: dinleme, konuşma, yazılı anlatım ve görsel gerektiren kodlar).
4. **Açık:** 1–4. sınıf sıra/puan gizleme (GÖR-058); `questions` tablosuna kazanım kodu, dayanak, kanıt düzeyi alanı (migration); uzak DB'ye sınav ve soru yazma onayı.

Kanıt düzeyi notu: `soru_kontrol.mjs` matematik ve Hayat Bilgisi sorularını da mekanik olarak A işaretler. Skill'in tablosu A'yı yalnızca okuma-çözümleme kazanımlarında verir; paket matematik ve Hayat Bilgisi'ni B olarak işaretler.
