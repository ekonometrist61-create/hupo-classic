# Soru Üretim Planı v2 — sınıf × ders üretim takvimi

Tarih: 2026-10-18. Önceki plan: [PLAN.md](PLAN.md). Üretim kuralları: [REHBER.md](REHBER.md). Bu belge yalnızca PLAN'dır; yayın (veritabanı aktarımı) en son ve kullanıcı onayıyla yapılır.

## 1. Hedef
1–8. sınıf, ders başına 20–30 onaylı soru. Onay = kapı + çözücü + kalite denetimi geçmiş, DÜZELT/RED çıkarılmış.

## 2. Kapsam matrisi (sınıf × ders)
Ders listesi sınıfa göre (doğrulanacak; aşağıdaki "açık" işaretliler):

| Sınıf | Dersler | Kazanım kaynağı | Durum |
|---|---|---|---|
| 1 | Türkçe, Matematik, Hayat Bilgisi | Türkçe 1-4 DÖP, Matematik 1-4 DÖP (2026) | Kazanım tablosu yok; kaynak açık (Hayat Bilgisi 1–3 DÖP'u bulunacak) |
| 2 | Türkçe, Matematik, Hayat Bilgisi, İngilizce | Yukarıdakiler + İngilizce (açık) | Resmî soru kaynağı yok |
| 3 | Türkçe, Matematik, Hayat Bilgisi, Fen, İngilizce | Fen DÖP 3–8 (2026) | Kazanım tablosu yok |
| 4 | Türkçe, Matematik, Fen, Sosyal, İngilizce, Din | Türkçe ✓, Matematik ✓, Fen ✓, Sosyal ✓ (kazanim_4_*.json); İngilizce açık; Din açık | **Pilot durumu:** Türkçe 28, Matematik 29, Fen 25, Sosyal 28 (final) |
| 5 | Türkçe, Matematik, Fen, Sosyal, İngilizce, Din | DÖP kazanımları (5. sınıf DÖP bulunacak); İOKBS 2020–2026 yalnız stil referansı | Pilot yok |
| 6 | Aynı 6 ders | DÖP (bulunacak); İOKBS 6 serisi (eklenecek) | Pilot yok |
| 7 | Aynı 6 ders | DÖP (bulunacak); İOKBS 7 serisi (eklenecek) | Pilot yok |
| 8 | Türkçe, Matematik, Fen, İngilizce, Din, **T.C. İnkılap** | LGS dersleri (Sosyal yerine İnkılap); LGS kaynakları | Pilot yok; resmî veri yok |

Not: 4. sınıf programı tymm'de 2026-09 yüklemesiyle; telafi belgesine göre 4. sınıf yeni programa 2027–2028'de geçecek. Bu yüzden 4. sınıf kazanımlarının "şu an uygulanan" program olup olmadığı yayın öncesi doğrulanmalı.

## 3. Üretim hattı (her sınıf-ders hücresi için aynı)
1. **Kazanım tablosu:** DÖP PDF → `kazanim_<sinif>_<ders>.json` (kod, metin, ünite). Kapı: kod yoksa RED.
2. **Yazar (Sonnet 5.5):** Hücre başına 3 parti × 12 soru. Girdi: REHBER ilgili bölümü + kazanım listesi + mevcut kökler (tekrarı önlemek için). Kaynak soru prompt'a girmez.
3. **Otomatik kapı (`tools/soru-uretim/kapi.cjs`):** şema, kazanım kodu, sayısal doğrulama, doğru şık en uzun değil (±%30), çeldirici gerekçesi. Eklenecek kontroller: mutlak ifade ("yalnızca", "sadece", "tamamen", "hiçbir", "her zaman"), kök tekrarı (benzerlik), harf dağılımı.
4. **Çözücü (Haiku, kör):** Anahtarsız çözüm. Anahtarla uyuşmayan soru → RED.
5. **Kalite (Sonnet 5.5, kör):** GEÇER / DÜZELT / RED. Anahtar görmez.
6. **Gemini:** Kalite denetiminde kullanılmaz (K-0054, K-0056, K-0057: kalite kararında güvenilmez). Çözücü olarak ikinci görüş isteğe bağlı.
7. **Sonuç:** DÜZELT ve RED çıkarılır. Harf dengesi için şık sırası değişebilir; metin değişmez. Hücre < 20 soru ise yeni parti (adım 2).
8. **Dosya:** `pilot/uretim_<ders>_<sinif>.json` (final). Denetim notları `scratchpad`'te, kayıt K-numarasıyla PROJE_GUNLUGU'nda.

## 4. Sıra (öncelik)
1. **4. sınıf kapanış:** İngilizce 4 (program bağlantısı bekleniyor), Din Kültürü 4 (program bulunacak), Sosyal 4 final kalite (Sonnet). Kapanış = 4 ders × ≥20 soru.
2. **5. sınıf** (4→5 geçişin hedef sınıfı; İOKBS 2020–2026 stil referansı): 6 ders.
3. **8. sınıf** (LGS, resmî referans): 6 ders.
4. **6–7. sınıf:** 12 hücre.
5. **1–3. sınıf:** 1 (3 ders), 2 (4 ders), 3 (5 ders). 1 ve 2. sınıflar için resmî soru kaynağı yok; kazanım tablosu ve yazar tek başına üretecek, kalite kriteri daha sıkı.

## 5. Bütçe ve parti sayısı
- Hücre başına ~3 yazar partisi + 1 kalite denetimi + 1 çözücü (Haiku ucuz). Tahmin: hücre başı ~200–250 bin token (pilotlardan).
- 42 hücre ≈ 8–10 milyon token: tek seferde değil, öncelik sırasına göre bölüm bölüm.
- Her hücre sonunda token harcaması K-kaydına yazılır; bütçe aşılırsa sonraki hücre ertelenir.

## 6. Kabul ölçütleri (hücre başına)
- Kapı: 100 % geçiş (RED = 0 final dosyada).
- Çözücü anahtar uyumu ≥ %95; altında kalan soruda anahtar kontrolü.
- Kalite GEÇER oranı ≥ %70; üzerinde kalan DÜZELT/RED çıkarılmış olmalı.
- Final ≥ 20 soru; kazanım kapsamı tam (her kod ≥ 1 soru).
- Zorluk dağılımı yaklaşık 30/50/20 (1/2/3); doğru şık dağılımı A–D her biri en fazla %35.
- Her soru görselsiz; gorsel_gerekli = false.

## 7. Yayın kapısı (veritabanına en son)
- Hücre kabul ölçütleri geçtikten sonra, kullanıcı kararıyla: (a) insan örneklemi (§15, karar bekliyor), (b) provenance alanları (`kaynak_turu`, `kazanim_kodu`, `denetim`), (c) `questions` tablosuna `beklemede` olarak aktarım.
- Yayınlanmış soru uygulamada "yapay zekâ üretimi" etiketi taşımaz (kullanıcı kararı).


## 0. Kararlar (2026-10-18, ajan tarafından; gerekçeli, değiştirilebilir)
Ölçüt: en fazla kullanıcıya fayda, en hızlı güvenilir içerik, uzun vadeli sürdürülebilirlik.
1. **Öncelik sırası:** 4 (kapanış) → 8 (LGS: en büyük talep, resmî kaynak var) → 5 (4→5 geçişin hedef sınıfı) → 6–7 → 1–3. Gerekçe: LGS kitlesi en büyük; 4→5 projenin çekirdeği; 1–3 kaynağı zayıf.
2. **Ders öncelik:** Türkçe ve Matematik her sınıfta ilk; Fen ve Sosyal ikinci; İngilizce ve Din üçüncü. Gerekçe: en yüksek talep ve en güçlü kazanım verisi.
3. **8. sınıf:** Sosyal yerine T.C. İnkılap Tarihi ve Atatürkçülük (LGS yapısı).
4. **1–3. sınıf dersleri:** 1 = Türkçe, Matematik, Hayat Bilgisi; 2 = + İngilizce; 3 = + Fen. Program doğrulaması hücre başlamadan yapılır; doğrulanamazsa o ders atlanır.
5. **Çözücüler:** Haiku ve Gemini (ikisi de anahtarsız çözer; iki farklı aile). Gemini'nin kalite rolü kalkar.
6. **Kalite denetçisi:** Sonnet 5.5 (tek kalite denetçisi). Opus ve Gemini kalite rolünde kullanılmaz; maliyet ve tutarlılık gerekçesi.
7. **Yayın kapısı:** Bir soru yayına girmeden iki bağımsız çözücü + Sonnet kalite GEÇER olmalı. İnsan örneklemi (%10, hücre başı) yayın için zorunlu ürün kuralı; uygulayacak kişi kullanıcı tarafından atanacak. Atanana kadar hücre "KONTROL_ADAYI" statüsünde kalır, yayınlanmaz.
8. **Etiket:** Ürün içinde "yapay zekâ üretimi" etiketi yok (kullanıcı kararı).
9. **Fiyatlandırma ve paketleme:** Bu plan kapsamında karar verilmedi; mevcut monetizasyon kararları (K-kayıtları) geçerli. Soru bankası ürünü için fiyat ve paket kararı kullanıcıda.
10. **Bütçe:** Hücre başına üst sınır ~250 bin token. Sıra 4 → 8 → 5. Her hücre bitince K-kaydı.
11. **Telif:** Yayınevi sorusu üretime girmez; yalnız istatistik ve parmak izi (kullanıcı onayı, avukat görüşü istenmedi).
## 8. Önceki açık kararlar (yukarıdaki kararlarla kapatıldı; 3 ve 6 hâlâ bekliyor)
1. 1–3. sınıfta hangi dersler (Hayat Bilgisi, Fen ve İngilizce başlangıcı) — program doğrulaması yapılsın mı?
2. 8. sınıf: Sosyal yerine T.C. İnkılap Tarihi ve Atatürkçülük kullanılsın mı?
3. İngilizce ve Din 4. sınıf programı: PDF bağlantısı ya da dosya adı.
4. Gemini'nin kalite rolü kaldırılsın mı (öneri: evet, yalnız çözücü)?
5. İnsan örneklemi (§15): yayın öncesi her hücreden %10 öğretmen kontrolü istiyor musunuz?
6. Bütçe: tüm 42 hücre mi, yoksa önce 4 ve 5. sınıf mı?

## 9. Sonraki adım
Karar 6 maddesi netleştikten sonra: (1) İngilizce 4 ve Din 4 programını bul, (2) Sosyal 4 final kalite denetimi (Sonnet), (3) 5. sınıf DÖP ve kazanım tablosu.
