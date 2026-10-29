# GÖR-070 blueprint: 6. sınıf Matematik · MAT.6.1.2 (bölünebilme kriterleri)

Durum: **BLUEPRINT (üretim yapılmadı).** Tarih: 2026-10-27. Kayıt: PROJE_GUNLUGU.md K-0151.

## Kimlik (her çıktıda zorunlu)
- school_year: 2026-2027
- grade: 6
- subject: Matematik
- curriculum_status: TYMM (kayıt: `data/curriculum_registry.json`, 6. sınıf `applicable=TYMM`)
- kazanim_kodu: MAT.6.1.2
- learning_outcome_source: `docs/soru-uretim/pilot/kazanim_6_matematik.json` (kaynak_url: `mufredat.meb.gov.tr … Matematik (5-8) DÖP.pdf`, 2026 Maarif DÖP)
- verification_status: **review_needed** (kazanım metni PDF ayrıştırması; satır sonu tireleri nedeniyle kesik. Metin PDF'ten insan tarafından teyit edilmeden kanıt düzeyi A verilmez.)
- review_flags: `kazanim_metni_kesik`, `kaynak_program_etiketi` (dosyada `program_surumu: "Maarif Modeli 5. sınıf DÖP (MAT)"` yazıyor, kod ise 6. sınıf; etiket düzeltilmeli)

## Kazanım
"Bir doğal sayının 2, 3, 4, 5, 6, 9 ve 10 ile tam bölünebilme kriterlerine ilişkin çıkarım yapabilme."
Alt maddeler (kaynakta): a) katlar ve basamak değerleri ile varsayım; b) katlar ve basamak değerlerini inceleyerek genelleme; c) genellemenin varsayımı karşılayıp karşılamadığını örneklerle sınama; ç) kriterlere ilişkin açıklama; d) kriterlerin farklı durumlardaki uygulanışı.

## Mevcut havuz (2026-10-27, salt okunur sayım)
- MAT.6.1.2 için 1 onaylı soru var: "9 ile tam bölünebilme" (apartman kapı kodu, zorluk 2, kod taşıyor).
- Kapsam boşluğu: 2, 3, 4, 5, 6, 10 kriterleri ölçülmüyor. Yeni sorular 9 bağlamını tekrar etmez.

## Hücreler (6 yeni soru)
| # | Hücre | Kriter | Beceri etiketi | Zorluk | Açıklama |
|---|-------|--------|----------------|--------|----------|
| 1 | C1 | 2 ve 5 (son basamak) | uygulama | 1 | Son basamağa bakarak tam bölünebilme |
| 2 | C2 | 10 (son basamak ve 0) | uygulama | 2 | 10 kriterinin 2 ve 5 ile ilişkisi; çeldirici: yalnız 2 ya da yalnız 5 sağlayan sayı |
| 3 | C3 | 3 (rakam toplamı) | uygulama | 2 | 9 değil 3 kriteri; 9 sorusunu tekrar etmez |
| 4 | C4 | 4 (son iki basamak) | uygulama | 2 | Son iki basamağın 4 ile bölünmesi |
| 5 | C5 | 6 (2 ve 3 birlikte) | çıkarım | 2 | Kriterleri birleştirme; kökte her iki koşul yazılır |
| 6 | C6 | Genelleme sınaması (alt madde c) | değerlendirme | 3 | Öğrencinin verilen genellemenin varsayımını örnekle çürütmesi |

Her hücrede: çoktan seçmeli, 4 şık, tek doğru cevap. Sayısal doğru cevap `soru_kontrol.mjs` kapısında koddan yeniden hesaplanır.

## Kurallar (uygulama sırasında)
- Kök tek bağlamda; sayılar ve koşullar kökte yazılır (kural 14). Bağlam: genel sayı problemi, günlük hayattan kısa durum (kapı kodu, koli, kutu sayısı); apartman kapı kodunu tekrar etmez.
- Çeldiriciler öğrencinin yaygın yanılgısından seçilir: son basamağa bakmak yerine rakam toplamına bakmak; "her çift sayı 4 ile bölünür" gibi yanlış genelleme.
- Şık uzunlukları ölçülür; doğru şık en uzun olmaz (2026-10-24 testi kuralı).
- "Hepsi / Hiçbiri / A ve B" şıkları yok; çift olumsuzluk yok.
- Aynı cevap harfi üst üste en fazla iki kez; cevap dağılımı kontrol edilir.
- Telif: kaynak DÖP örnek soruları kullanılmaz; yeni kök, yeni bağlam, yeni şıklar.

## Kanıt düzeyi
- Kayıt: **B** (editör önerisi) şimdilik. A, kazanım metni PDF'ten insan tarafından teyit edilip her soru için dayanak (kökteki koşul) gösterildikten sonra verilir. Matematikte "dayanak" metin pasajı değil, kökteki koşul ve kuraldır; kanıt tablosu buna göre yorumlanır.

## Kapılar (üretim sonrası, sırayla)
1. Şema: 4 şık, tek doğru, `dogru_sik` şıkta var.
2. Hesap: sayısal cevap koddan yeniden hesaplanır (kapı 2).
3. Kör çözüm: farklı model ailesi, anahtarsız; uyuşmazlık elenir ya da düzeltilir.
4. Benzerlik: mevcut onaylı MAT.6.1.2 sorusu (id listesi üretim kaydında) ile n-gram kontrolü.
5. Zorluk vekili: hedef zorluk ile çözüm adım sayısı tutarlılığı.
6. Dil ve sınıf düzeyi: 6. sınıf okunabilirliği.
7. İnsan denetimi: yayın öncesi zorunlu; `published=false`.

## Yapılmayanlar (bu blueprint'in kapsamı dışı)
- Soru üretimi, DB yazımı, yayın, onay: yok.
- Türkçe hedefleri: bu blueprint'te yok (aşağıdaki karar notu).

## Türkçe hedefleri (2–3. sınıf eş/zıt anlam): bloke
Kullanıcının seçtiği hedef (6. bölünebilme + 2–3. Türkçe eş/zıt) için Türkçe kısmı mevcut kaynak ve kapsam kurallarıyla üretilemez:
- **T.K.2.2 d** (zıt anlamlı sözcük kullanma) ve **T.K.3.2 f** (eş anlamlı sözcük kullanma) konuşma kazanımları. `kazanim_2_turkce.json` notu (2026-10-22 kapsam kararı): "yalnız metinle sınanabilen kazanımlar üretilir; konuşma kazanımları kapsam_disi." Bu kurala göre üretilmez.
- **T.O.2.2 f** (okuduğu metindeki zıt anlamlı sözcüğü bulma): 2. sınıf resmî DÖP metninde T.O.2.2 yalnız a, b, c maddelerini taşıyor; zıt anlam maddesi yok. 3. sınıf satırındaki f maddesi kod-sınıf tutarsızlığı taşıyor (kod 2. sınıf, madde 3. sınıf). 3. sınıf resmî metni depoda yok.
- 1. sınıf eş anlam kazanımı kaynakta yok.
Karar için seçenekler PROJE_GUNLUGU K-0151'de.
