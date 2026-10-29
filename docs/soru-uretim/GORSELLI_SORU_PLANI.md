# Görselli Soru Modülü — Plan (2026-10-28)

Durum: **PLAN, onay bekliyor.** Kod ve migration yazılmadı. Bu belge [SISTEM.md](SISTEM.md)'in uzantısıdır; çelişkide SISTEM.md geçer (özellikle §1 değişmezler).

## 1. Neden ayrı modül
Bugünkü hat görselsiz soru üretir: `kapi.cjs` `gorsel_gerekli=true` soruyu RED eder ("gorselli_soru_pilotta_yasak"), `questions` tablosunda görsel kolonu yok, mobil quiz `id, ders, konu, alt_konu, zorluk, soru_metni, siklar` seçer. Soru Atölyesi'nde yalnız `gorsel_gerekli` bayrağı var. Gerçek sınav sorularında görsel ağırlığı yüksek:

| Kaynak (incelendi) | Sayfa | Gömülü görsel | Vektör çizim | Ne içeriyor |
|---|---|---|---|---|
| `ba505684fe.pdf` — MEB Fen 1. dönem 1. yazılı | 9 | 11 | 4.213 | Ay evreleri fotoğrafı + Güneş-Dünya-Ay modeli, dinamometre ölçeği, deney tablosu; açık uçlu a/b/c alt soruları |
| `100_Soruda_5_Sınıf…Fasikülü_2026.pdf` — yayınevi | 22 | 77 | 6.388 | Çember/doğru/ışın çizimleri, kareli zeminde paralellik, kesişen doğrularda açı, renkli çizgili küp, sembol tablosu |

Sonuç: şekil türü sınırlı ve **parametrik** (açı, uzunluk, sayı, konum, renk). Fotoğraf yalnız azınlık. Bu yüzden "resmi çiz" değil "şekli tarif et, motor çizsin" yaklaşımı.

## 2. Mevcut sistem (bulundu)
- **Hupo içi hat:** `docs/soru-uretim/` (SISTEM, REHBER, PLAN_V2, paketler, pilot dosyaları) + `tools/soru-uretim/kapi.cjs` + `soru_kontrol.mjs` + skill `meb-soru-sozcuk-uzmani`. 5 adım: üret → otomatik kapı → kör çözüm → kör kalite → insan onayı.
- **Soru Atölyesi:** `C:\Dev\Soru-Cevap Hazırlama Programı` (TypeScript CLI: ingest, enrich, vary, qa, export; Claude/Gemini PDF girişi, `varyant.ts` şablon motoru, hakem, inceleme sunucusu). **Git deposu değil** (`.git` yok). BRIEF/PLAN eski (2026-10-17); SISTEM.md'den önceki "birebir aktarım" kararı SISTEM §1.1 ile geçersiz: MEB/yayınevi görseli çoğaltılmaz.
- **Yeniden kullanılacaklar:** `kapi.cjs` sayısal doğrulama deseni, Atölye `ingest/aday.ts` + `lib/gemini-dosya.ts` (PDF'i modele verme), `vary/varyant.ts` (slot + kodla cevap), `qa/mukerrer.ts`, Hupo ikon kataloğu (`mobile-app/tool/ikon_katalogu_uret.dart`, 89 kavram SVG), `flutter_svg` (pubspec'te var).

## 3. Temel tasarım: spec → deterministik SVG
**Model SVG/piksel çizmez; yapısal `gorsel_spec` (JSON) yazar. Motor SVG üretir.** Nedenleri: (1) cevap spec'ten kodla hesaplanır, yanlış şekil olamaz; (2) çocuk verisi/telif riski yok; (3) aynı spec'ten sınıfa göre stil, açık/koyu tema, farklı sayılar; (4) küçük dosya (SVG ≤ 30 KB), mobil+web aynı.

```
Yazar (LLM) ──► soru + gorsel_spec ──► Motor ──► SVG + alt_metin + çözülmüş_olgular
                                          │
                                  Çözücü (kodla): "açı=50°", "paralel: k∥m" → dogru_sik ile eşleşmeli
```

### 3.1 Şekil kataloğu (tip kaydı)
Her tip bir kayıt: `tip_id`, parametre şeması (JSON Schema), render fonksiyonu, **çözücü** (olguları hesaplar), çeldirici kuralları (yaygın yanılgılar), sınıf/ders/kazanım eşlemesi, alt-metin üreticisi, doğrulayıcılar. Üç dalga:

| Dalga | İçerik | Örnek tipler |
|---|---|---|
| **A — hesaplı çizim** (kod çizer, cevap kodda) | Matematik çekirdeği | sayı doğrusu, kesir/ondalık modeli, nesne sayma, örüntü dizisi, çokgen/çember elemanları, doğru-ışın-doğru parçası, açı+iletki, kareli zeminde paralel/dik/simetri/döndürme/alan-çevre, birim küp yapıları ve üstten-önden-yandan görünüm, cisim ağı, saat, cetvel, tablo, sütun/çizgi/daire grafiği, koordinat sistemi, Venn |
| **B — diyagram şablonları** | Fen, Sosyal, İnkılap, Türkçe | **Ay evreleri (aydınlık oranı hesaplanır, fotoğraf gerekmez)**, Güneş-Dünya-Ay modeli, dinamometre/termometre/mezür okuma, basit devre, kuvvet okları, besin zinciri, su döngüsü, parçacık modeli, ışın diyagramı, deney düzeneği, zaman şeridi, pusula/ızgara harita, aile ağacı; Türkçede belge şablonları (afiş, ilan, davetiye, tablo, sözlük maddesi) |
| **C — varlık tabanlı** | Hayat Bilgisi, İngilizce, 1–3. sınıf | ikon kompoziti (sahne, sayma, "hangi resim"), trafik/güvenlik işaretleri, renk soruları, resimli kelime kartı; Natural Earth tabanlı Türkiye/dünya haritası |

Dalga dışı: **fotoğraf** yalnız lisans kaydı olan CC0/PD/CC-BY kaynaklardan (Wikimedia Commons, NASA, Natural Earth); lisans ve atıf kaydı zorunlu. **AI görsel üretimi (nano-banana)** yalnız süs/sahne için; sayı, ölçü, renk, konum taşıyan hiçbir görsel üretilmez (nano-banana şu an bağlanamıyor, plan ona bağlı değil).

### 3.2 Sınıf profili
Her sınıfa stil bütçesi: yazı boyu, çizgi kalınlığı, en çok renk, en çok nesne, karmaşıklık.
- 1–2: büyük ikon, ≤3 renk, sayma ≤20, metin etiketi az.
- 3–4: tablo, basit grafik, kareli zemin, ≤5 renk.
- 5–8: teknik diyagram, çok seri grafik, izometrik cisim, harita, işlem hatası tuzakları.

### 3.3 Renk kuralı
Renk **anlam taşıyorsa** (örüntü, grafik serisi, harita lejandı, karışım): (a) renk körlüğü simülasyonunda (deuteranopi/protanopi/tritanopi) seriler ayırt edilebilir olmalı; (b) renge ek olarak desen/etiket (renk tek başına taşıyıcı değil); (c) renk adı soruda geçiyorsa SVG'de o renk kodu; (d) şekil kartı sabit açık zemin (koyu temada ters renk riski yok); (e) belirgin kontrast eşiği.

### 3.4 Ölçek ve ipucu sızıntısı
Spec'te `olcekli: true|false`. Ölçüm şekilden okunacaksa (iletki, cetvel) ölçekli; değilse MEB geleneği gibi "şekil ölçekli çizilmemiştir" ve çizim bilerek **cevaba göre değil** sabit düzende. Kapı, şeklin kendisinin cevabı göz kararıyla ele vermesini denetler (örnek: 130° ile 50° açı çiziminden hangisi büyük görünüyor).

## 4. Soru şeması eki (Soru Paketi v2 önerisi)
Mevcut alanlara ek (hepsi null olabilir; mevcut sorular bozulmaz):
```
soru_tipi        : coktan_secmeli | (Faz 2) siralama | eslestirme | tablo_doldur | gorsel_isaretle
gorsel           : { tur: svg_spec|svg_varlik|foto, svg, alt_metin, olcekli, yerlesim, kaynak? }
sik_gorselleri   : { A:{svg,alt_metin}, B:… }          // şıkları görsel olan sorular (örnek: 4 Ay evresi)
gorsel_spec      : { tip_id, parametreler, cozulmus_olgular }   // yalnız yazar/denetçi/panel; öğrenciye KAPALI
```
Kural: `gorsel_spec` cevap ipucu taşıyabilir → `dogru_sik` gibi kolon yetkisiyle öğrenciden gizlenir; `gorsel` (SVG) cevaptan önce okunur. `siklar` jsonb tipi **değiştirilmez** (mobil/web/RPC bozulmasın), görsel şıklar ayrı kolonda.

Açık uçlu a/b/c yazılı soruları (MEB Fen PDF'i gibi) çoktan seçmeli değildir: Faz 1'de her alt soru ayrı çoktan seçmeliye bölünür; "ibaresini sıralayın / tabloyu doldurun" gibi olanlar Faz 2 soru tiplerine kalır.

## 5. Kalite hattı (SISTEM §2'ye eklenenler)
Yeni zorunlu kontroller (mevcut 5 adım aynen, ek kapılar işaretli):

| Adım | Ek |
|---|---|
| 1 Üret | Yazar kaynak soruyu **görmez** (§1.1). Blueprint = şekil tipi + parametre aralığı + bilişsel eylem. |
| 2 Otomatik kapı | **Spec şeması**, **çözücü = anahtar** (olgular `dogru_sik` ile birebir), **görsel lint** (etiket çakışması, sınır dışı, 360 px'te okunurluk, kontrast, renk körlüğü, SVG boyutu), alt-metin varlığı, ölçek/ipucu sızıntısı |
| 3 Kör çözüm | Haiku **PNG'yi görerek** çözer (anahtarsız). Okunamayan/çift anlamlı şekil burada yakalanır. |
| 3b **Görsel gerekli mi?** | Aynı soru **görselsiz** çözülür; şans düzeyinin üstünde çözüyorsa görsel süs sayılır → ya gerçek gereklilik eklenir ya görselsiz soruya çevrilir. Tersi: görselli çözüm başarısızsa RED. |
| 4 Kör kalite | Sonnet resmi görerek puanlar; ek rubrik: okunabilirlik, yaşa uygunluk, görsel-metin uyumu. Hassas görsel (din, tarih, siyaset, ölçüm) → Opus. |
| 5 İnsan onayı | Toplu **kontak sayfası** (12 soru/sayfa, gerçek ekran boyutunda PNG) + onay; `beklemede` → `onaylandi` yalnız kullanıcı. |

Uygulama tarafı doğrulaması: gerçek cihaz/web ekran görüntüsüyle (AGENTS.md; "kontrol çalışmadıysa açık yaz").

## 6. Şekil madenciliği: PDF + web → blueprint (kullanıcının "tarayıp üretsin" isteği)
Amaç: kaynaklardan **hangi şekil türleri, hangi parametre aralığında, hangi sınıf/kazanımda, hangi soru eylemiyle** kullanılıyor çıkarmak; bitmap'i değil **tarifi** saklamak.

```
PDF/URL ─► sayfa/şekil tespiti ─► tip sınıflama ─► parametre çıkarma ─► gorsel_blueprint
 (pymupdf: gömülü görsel +      (vision LLM: katalogdaki   (ör. çember+2 kiriş+     (tip_id, parametre aralığı,
  vektör kümeleme)               tip mi, yeni tip mi?)      merkez etiketi O)         sınıf, kazanım ipucu, eylem)
                                                                 │
                              yeni tip adayı ──► insan: kataloğa ekle / reddet ──► yeni renderer yazılır
```
- **Çıktı bitmap değil**: kaynak şekil kopyalanmaz/yeniden çizilmez; yeni parametrelerle özgün şekil üretilir. Kaynak PDF/görseller repoya girmez (§1.1), yalnız blueprint JSON girer; kaynak kaydı (url, sha256, tarih) tutulur.
- **Web taraması:** (a) kapsam/kazanım/şekil-tipi araştırması için herhangi açık sayfa taranır, yalnız tarif çıkarılır; (b) **görsel varlık** (foto/harita) yalnız lisans alanı doğrulanmış kaynaklardan (Wikimedia Commons API, NASA, Natural Earth, Openverse CC0/PDM) indirilir ve `kaynak_kaydi` (lisans, atıf, sha256) ile saklanır. robots.txt ve hız sınırı uygulanır; lisansı belirsiz görsel indirilmez.
- **Yeni tip adayları** önceliklenir (kaç kaynakta, hangi sınıfta geçiyor); renderer sırası veriyle seçilir.
- İlk iş: yukarıdaki iki PDF ile **şekil envanteri** (bunlar madencilik hattının ilk test girdisi).

## 7. Oracle sunucusu: ne zaman, ne için
Erişim doğrulandı (`oracle.ps1 status`: 4 çekirdek, 23 GB RAM, 24 GB boş disk, mevcut servisler çalışıyor, 0 iş). SVG üretimi milisaniyelik; **üretim yerelde yeter**. Oracle'ın yararı:
1. **Madencilik toplu işi** (yüzlerce PDF, sayfa rasterleştirme, vision çağrıları kuyruğu, web tarama; saatler sürer).
2. **Toplu görsel QA** (binlerce SVG → PNG → kör çözüm/görselsiz test).
3. Zamanlı işler (haftalık yeni kaynak tarama, kontak sayfası derleme).

Karar: **Faz 4'e kadar kurulmaz** (önce renderer ve kapı yerelde çalışmalı; sunucuya henüz taşınacak bir şey yok). Kurulumda: `~/soru-gorsel` içinde tek kapsayıcı (Node + Python, resvg, pymupdf), CPU/RAM sınırlı, **yeni port/güvenlik duvarı değişikliği yok**, Coolify/n8n/vs-render/`~/hupo-motion`'a dokunulmaz, iş `oracle.ps1 task/batch` ile, çıktı `sync` ile döner. Anahtar (`oracle_video.key`) ve LLM API anahtarı repoya/çıktıya girmez; API anahtarı sunucuda yalnız işin ortam değişkeninde. Öğrenci verisi gönderilmez (zaten yok).

## 8. Yol haritası
| Faz | İş | Kabul ölçütü |
|---|---|---|
| **0** (1–2 gün) | İki PDF'ten **şekil envanteri** (sayfa → şekil tipi → parametreler → soru eylemi); tip kataloğu taslağı; v2 şema taslağı | Envanter tablosu + her şekil bir tipe eşlenmiş ya da "yeni tip" |
| **1** (≈1 hafta) | Matematik **Dalga A çekirdeği** (~12 tip: doğru/ışın/doğru parçası, çember, açı, kareli paralellik, sayı doğrusu, kesir, grafik, tablo) + çözücü + görsel lint; `kapi.cjs` ek kapılar; **5. sınıf Matematik geometri pilotu 20 soru** (özgün) | Kapı %100, kör çözüm (PNG) ≥ %95, "görselsiz" testi geçer, kontak sayfası insan onayına hazır |
| **2** (paralel) | Uygulama: migration (kolon + **kolon yetkisi kararı**, `gorsel_spec` kapalı) → önizleme → `preview/deploy` (migrasyon sahipliği kuralı); Flutter `SvgPicture.string` + şıkta görsel + alt metin; web panel soru önizleme; **gerçek ekran kontrolü** | Öğrenci hesabında görsel görünür, `gorsel_spec` görünmez, 360 px'te okunur |
| **3** | Fen + Hayat Bilgisi + İngilizce: Ay evreleri, ölçü aletleri, devre, ikon kompoziti; renk soruları + renk körlüğü kapısı | Fen 5 ve Hayat Bilgisi 1–2'de ≥20 soru/hücre kapıdan geçer |
| **4** | **Madencilik hattı** (PDF+web → blueprint) ve **Oracle worker**; toplu görsel QA | 1 gecede ≥100 PDF işlenir, yeni tip adayı listesi çıkar |
| **5** | Sosyal/İnkılap (harita, zaman şeridi), Türkçe belge şablonları, foto varlık hattı (lisans kaydıyla); Faz-2 soru tipleri (sıralama, eşleştirme, tablo doldur, görsel işaretle) | Tip başına pilot + insan örneklemi |
| **6** | 1–8 sınıf × ders matrisinde ölçek (PLAN_V2 sırasıyla), Oracle batch | Hücre başına kabul ölçütleri (PLAN_V2 §6) + görsel kapılar |

Önerilen ilk adım: **Faz 0 + Faz 1 birlikte** (envanter hemen renderer listesini belirler).

## 9. Modül yeri (öneri)
`tools/gorsel-motoru/` Hupo deposunda (TypeScript, `kapi.cjs` ile aynı sürümleme; testler orada). Soru Atölyesi `vary` adımı motoru çağırır. Atölye klasörü git dışı olduğundan görsel kod orada **tutulmaz**. (Atölye'nin git'e alınması ayrı karar.)

## 10. Kararlar (kullanıcı, 2026-10-28)
1. **Modül yeri:** `tools/gorsel-motoru/` (Hupo deposu). Atölye git dışı olduğu için kod orada tutulmaz.
2. **SVG saklama (asistan kararı):** spec'ten üretilen SVG veritabanında metin kolonunda; **fotoğraf ve büyük varlık Supabase Storage'da** (URL kolonu). Gerekçe: SVG küçük, bağımlılıksız, spec'ten yeniden üretilebilir; foto için Storage zorunlu.
3. **Pilot:** 5. sınıf Matematik geometri. Hedef kapsam **tüm dersler ve 1–8. sınıflar**; matematik yalnız ilk dilim. Katalog ve şema ders-bağımsız tasarlanır, iki PDF yalnız örnektir.
4. **Fotoğraf politikası:** esnek; tüm lisans türleri kaydedilebilir (CC0, PD, CC-BY, CC-BY-SA, kullanıcı beyanı vb.). Her varlık `lisans_turu`, `atif` ve kaynak taşır; lisansı belirsiz veya "tüm hakları saklı" görsel kullanıcının açık onayı olmadan yayına girmez; atıf gerektirenler uygulamada atıf sayfasında listelenir. **Değişmez:** MEB/yayınevi görseli çoğaltılmaz (SISTEM §1.1).
5. **Din Kültürü:** kapsam dışı değil. Figürlü/hassas görseller Opus hassas denetimi + kullanıcı onayıyla ilerler (SISTEM §5); otomatik yayın yok.
6. **Oracle:** kurulum onayı **Faz 4'te sorulacak**; o zamana kadar kurulmaz.
7. **Açık uçlu yazılı sorular:** çoktan seçmeliye bölünür (alt soru = ayrı soru); bölünemeyenler Faz 5 soru tiplerine kalır. Modül her derste her tür şekil/görsel/renk sorusuna açık tasarlanır.

## 11. İlerleme (2026-10-28) — Faz 0 + Faz 1 ilk dilim
Yapılanlar (doğrulanmış):
- **Şekil envanteri:** `gorsel/SEKIL_ENVANTERI.md` (Haiku; iki PDF, 111 soru, 91'i şekilli, 64 şekil tipi; hiçbirinde renk anlam taşımıyor). Tarama kalitesi insan örneklemi görmedi.
- **Motor:** `tools/gorsel-motoru/` — `cekirdek.mjs` (sahne, palet, sınıf profili), `tipler.mjs` (6 tip: doğru/ışın/doğru parçası, çember elemanları, kesişen doğrular, kareli doğrular, sayı doğrusu, çokgen), `lint.mjs` (sınır, yazı–yazı ve yazı–çizgi çakışması, okunurluk, boyut, renk bütçesi, kontrast, renk körlüğü), `motor.mjs`, `kapi-gorsel.mjs`, `kontak.mjs`, `kor-karsilastir.mjs`, `sablonlar-geometri5.mjs`. Birim testi 10/10.
- **`kapi.cjs`:** görselli soruyu yalnız `gorsel` + `gorsel_spec` varsa kabul eder (önceki "pilotta yasak" kuralı kalktı).
- **Pilot:** `pilot/uretim_mat5_geometri_gorsel.json` — 20 özgün şablon sorusu (MAT.5.3.1/3.4/3.6), harf dağılımı 5/5/5/5, `kapi.cjs` 20/20 KONTROL, `kapi-gorsel` 20/20 KONTROL. İnsan kontrolü için `gorsel/KONTAK_mat5_geometri_pilot.html`.
- **Kör çözüm (Haiku, PNG görerek):** 20/20 anahtarla uyuştu (şekiller okunabilir).

Bulgu (açık): **"görselsiz çözülüyor" testi geçilmedi.** Görselsiz Haiku çözümü 20 soruda 11 doğru (şans ≈ 5). Düzeltilen G18–G20'de (çokgen) görselsiz çözüm yine doğru: hesaplı çeldiriciler (n(n−1)/2, n(n−3), n−3) kenar sayısını şıklardan ele veriyor. Diğer sorularda çeldiriciler tamamlayıcı açı gibi türetilmiş değerler. Sonuç: bu 20 soruda görsel kısmen "gerekli değil, okunabilir"; yayın öncesi çözülmesi gerekir.
Çözüm yönü: (1) çeldiricileri **başka n/θ değerleri için hesaplanmış yanılgılarla** üret (şıklar tek bir n'ye işaret etmesin), (2) kökte verilen sayıyı şekle taşı, (3) kapıya "görselsiz uyum ≤ %40" eşiği ekle, (4) 20 soruluk örneklemde sonuç yetmez; hücre başına ≥ 40 soruyla ölç.

Henüz yapılmayanlar: veritabanı migration'ı, Flutter/web gösterimi, gerçek ekran kontrolü, `PROJE_GUNLUGU.md` kaydı, insan onayı. Hiçbir soru `onaylandi` değil.

### 11.1 Güncelleme (aynı gün, çeldirici düzeltmesi sonrası)
- **Çokgen:** şıklar artık T(n−k)…T(n−k+3) penceresi (ardışık köşe sayıları); kökte kenar sayısı yok. Şıklar tek bir n'ye işaret etmiyor.
- **Kesişen doğrular:** "★ − ■" biçimi denendi ve **bırakıldı**: fark sıfırdan büyükse biri ters, biri komşu olmak zorunda, cevap hep 180−2θ → görselsiz 4/4 çözüldü. Tek bilinmeyenli (ters/komşu şekilden okunur) biçime dönüldü; bu tipte doğal tavan ≈ %50 şans.
- **Son kör çözüm (taze Haiku, 20 soru):** görselli **20/20**, görselsiz **7/20 (%35)** (şans ≈ %25, 20 soruda ±%10). `kor-karsilastir.mjs` eşikleri: görselli ≥ %95, görselsiz ≤ %40 → **GEÇTİ**. Görselsiz çözülenler: çember (G02, G03, G05), sembol (G07), açı (G16, G17), çokgen (G18) — çoğu şans veya tek bilinmeyenli ters/komşu ikilisi.
- **Sınır:** 20 soru istatistik için küçük; hücre başına ≥ 40 soruyla yeniden ölçülecek. İnsan onayı ve gerçek ekran kontrolü hâlâ yok.

### 11.2 Sürekli üretim programı (aynı gün)
`tools/gorsel-motoru/uret.mjs` — ders/sınıf/adet/tohum seçerek sınırsız, tekrarsız görselli soru üretir (kullanım: `tools/gorsel-motoru/README.md`). Şablonlar `sablonlar/` altında kayıt (KAYIT) olarak yüklenir; yeni ders = yeni şablon dosyası (+ gerekirse yeni şekil tipi). Her soru üretim sırasında görsel kapısından geçer, geçmeyen atılıp yenisi denenir; `--kapi`, `--kontak`, `--kor-paketi` seçenekleriyle kapılar, insan onayı sayfası ve anahtarsız kör çözüm dosyaları tek komutla çıkar.
Şu an kayıtlı şablonlar: Matematik 5 (çember elemanları, doğru/ışın/doğru parçası sembolü, kesişen doğrularda açı, kareli zeminde paralel/dik, çokgen köşegenleri), Fen Bilimleri 5 (dinamometre okuma — yeni şekil tipi). 14/14 birim testi geçer.
Ölçüm (taze Haiku kör çözümü, hücre ≥ eşik): **Matematik 5, 40 soru:** görselli 40/40, görselsiz 9/40 (%23). **Fen 5, 20 soru:** görselli 20/20, görselsiz 6/20 (%30). Eşikler (≥ %95 / ≤ %40) geçti. Üretilen setler: `pilot/uretim_mat5_geometri_gorsel_40.json`, `pilot/uretim_fen5_kuvvet_gorsel_20.json`; onay sayfaları `gorsel/KONTAK_*.html`. Hepsi `beklemede`; insan onayı yok.
Bilinen sınırlar: Fen'de yarım bölme okumaları için Haiku göz kontrolü önerdi (insan onayında bakılacak); `stroke-dasharray` denetim ortamında çizilmiyor (gerçek tarayıcıda doğrulanmadı); şablonu olmayan ders (ör. Türkçe, Hayat Bilgisi, Sosyal, Din) için program `şablon_yok` verir; doğru şık harfleri üretim sırasında A-B-C-D döngüsüdür, DB'ye aktarırken soru sırası karıştırılmalıdır.

### 11.3 Şablon genişletme turu (aynı gün) — 5 yeni şekil tipi, 6 yeni şablon
Yeni tipler (`tipler-ek.mjs`): sütun grafiği, çubuk örüntüsü, nesne sayma, yer haritası (yön + pusula), trafik ışığı. Yeni şablonlar (`sablonlar/`): Matematik 5 veri (MAT.5.5.1) ve şekil örüntüsü (MAT.5.2.3), Matematik 1 nesne sayma (MAT.1.1.2) ve en çok olan şekil (MAT.1.1.1), Sosyal Bilgiler 5 ana/ara yön (SB.5.2.1), Hayat Bilgisi 1 trafik ışığı (HB.1.2.3). Kayıtlı şablon sayısı 13; dersler: Matematik (1, 5), Fen Bilimleri (5), Sosyal Bilgiler (5), Hayat Bilgisi (1). Çekirdeğe çokgen çizimi ve "koyu zemin" renk seçeneği eklendi; testler 20/20.
Kör çözüm (taze Haiku): karma 64 soru — görselli **63/64 (%98)**, görselsiz **18/64 (%28)**. Şablon bazında görselsiz: sütun grafiği %19, nesne sayma %22, en çok olan şekil %33, ana yön %13, ara yön %0, trafik ışığı %50 (yalnız 6 soru; 3 ışık × 2 bakışla sınırlı). Tek görselli hata Haiku'nun kendi tutarsızlığıydı (gerekçe doğru, harf yanlış).
**Çubuk örüntüsü şablonu sınırda:** görselli 20/20, görselsiz 9/20 (%45, eşik ≤ %40, n=20, ±%11). Şıklara 2n+1/3n+1/4n+1 değerleri konarak ilk sürümün %60'ından düşürüldü; bilinen "kare dizisi 3n+1" kalıbı şıklarla tamamen gizlenemiyor. Yayın öncesi insan kontrolünde ayrıca bakılacak.
Bulunan ve düzeltilen: (1) kimlikler yalnız tek çalıştırmada benzersizdi → kimliğe tohum eklendi (`MAT1-SAY-S21-001`); (2) alt metin kontrolü tüm seçenekleri tarafsız sıralayan alt metni sızıntı sayıyordu → kural inceltildi; (3) `--kapi` yalnız Matematik/Fen kazanım dosyasını bulabiliyordu → kazanım dosyası sorunun dersinden türetiliyor; (4) "kare dizisi şıkları artış kadar aralıklı" ipucu vermesi → fark artıştan bağımsız, sonra çoklu kural çeldiricisi.
Kayıt: `pilot/uretim_gorsel_veri_oruntu_sayma_yon_trafik_72.json` (72 soru; kapı 72/72 KONTROL), onay sayfası `gorsel/KONTAK_veri_oruntu_sayma_yon_trafik_72.html`. Hepsi `beklemede`; insan onayı ve gerçek ekran kontrolü yok.
Henüz şablonu olmayan: Türkçe, İngilizce, Din Kültürü, T.C. İnkılap, ve diğer tüm sınıflar (2, 3, 4, 6, 7, 8). Sıradaki tipler: tablo/belge şablonları (Türkçe), resimli kelime (İngilizce), zaman şeridi (Sosyal/İnkılap), kesir modelleri ve sayı doğrusu (Matematik 4–7), Ay evreleri/devre (Fen).

### 11.4 İkinci şablon turu (aynı gün) — Türkçe, kesir, şekil örüntüsü, ekonomi grafiği
Yeni tipler: belge kartı (duyuru/ilan), kesir modeli (şerit ve pasta), örüntü dizisi. Yeni şablonlar: Türkçe 5 duyuru kartı okuma (T.O.5.6), Matematik 5 kesir modeli (MAT.5.1.3), Matematik 1 şekil örüntüsü (MAT.1.1.6), Sosyal Bilgiler 5 ekonomi grafiği (SB.5.5.3, sütun grafiği tipini yeniden kullanır). Toplam: **14 şekil tipi, 17 şablon**; testler 24/24. İngilizce ve Din Kültürü için kazanım dosyası olmadığından (SISTEM §1: kod kaynakta yoksa üretilmez) şablon yazılmadı.
Kör çözüm (taze Haiku, ilk ölçüm 56 soru): görselli **56/56**; görselsiz duyuru %25, ekonomi %17, **kesir %56 ve örüntü %58 (eşik dışı)**.
Düzeltmeler ve yeniden ölçüm:
- **Kesir:** farklı paydalı çeldiriciler yalnız iki aynı paydalı şık bırakıyordu (doğru + tümleyen = %50). Şıkların hepsi aynı paydalı yapıldı (doğru, tümleyeni, ikisinin ±1 parça hatası). Sonuç: görselli 24/24, görselsiz %13.
- **Şekil örüntüsü:** çeldirici sırası sabitti, araya sokulan doğru şık sıra dışı kalıp ele veriyordu → çeldirici sırası rastgele.
- **Önemli üretici kusuru (tüm setleri etkiler):** doğru şıkların harfi soru sırasında A-B-C-D döngüsündeydi; döngüsel tahmin yapan bir çözücü yüzde yüz buldu (örüntü görselsiz 20/20). Konum artık 4'lü bloklarda dengeli ama blok içi karışık (`uretici.mjs`). Aynı soru kümelerinde yeniden ölçüm: kesir görselsiz %25, örüntü görselsiz %25 (şans düzeyi). **Önceki setler (§11.2–11.3) döngüsel harf sırasıyla üretildi**; içerikleri geçerli ama yayından önce yeniden üretilmeli ya da soru sırası karıştırılmalı. Önceki görselsiz ölçümlerin çoğu çözücünün bu döngüyü kullanmadığını gösteriyor (örn. sütun grafiği %19); yine de kesin kabul için yeni üreticiyle yeniden ölçülmeli.
- Çubuk örüntüsü (§11.3) şablonu hâlâ sınırda sayılır (%45 ölçümü eski döngülü setle yapıldı; yeniden ölçülmedi).
Kayıt: `pilot/uretim_gorsel_belge_kesir_oruntu_ekonomi_72.json` (72 soru, son üreticiyle; kapı 72/72), onay sayfası `gorsel/KONTAK_belge_kesir_oruntu_ekonomi_72.html`. Hepsi `beklemede`; insan onayı ve gerçek ekran kontrolü yok.

## 11.5 Program sağlığı: tasarım, kapılar, test (2026-10-28, Haiku oturumu)
Hedef: tek akış — şablon → soru → kapılar → çıktı klasörü → kör çözüm → karar — güvenilir ve tekrarlanabilir çalışsın.

Denetimde bulunanlar: (1) şablonun doğru şıkkı koyduğu konum çalışma anında doğrulanmıyordu; (2) "Türkçe" ile "turkce" ders eşleşmesi çalışmıyordu; (3) kazanım kapısı, kör çözüm kararı ve çıktı dağınıktı, tek karar raporu yoktu; (4) pilot klasöründeki setlerin bir kısmı eski, döngüsel harf sırasıyla üretilmişti; (5) iki ayrı paket yazıcısı vardı, testler dizin argümanıyla çalışmıyordu.

Garantiler (kod ve testle korunur):
- G1 Tekrarlanabilirlik: aynı tohum ve aynı şablonlar aynı JSON'u verir.
- G2 Şık dengesi: her 4'lü blokta A–D birer kez; blok içi sıra tohumla karışık.
- G3 Konum sözleşmesi: şablon konum() ile rezerve edilen yere doğru şıkkı yazar; yazmazsa soru konum_uyumsuz ile atılır.
- G4 Tekrar yok: aynı kök, görsel ve şıklar iki kez çıkmaz.
- G5 Kazanım sözleşmesi: her şablon tam bir kazanım kodu taşır; kod docs/soru-uretim/pilot/kazanim_*.json içinde olmalı (SISTEM §1.3). Kayıt doğrulaması bozuksa üretim başlamaz.
- G6 Görsel kapısı: üretim sırasında lint + olgu doğrulaması; çıktıda yeniden çizim eşitliği.
- G7 Metin kapısı: tools/soru-uretim/kapi.cjs (şema, kazanım kodu, çözüm son satırı, şık kuralları).
- G8 Yayın kapısı: her kayıt durum="beklemede", insan_onayi=null. Hiçbir karar otomatik yayın değildir.
- G9 Kör çözüm kararı: görselli uyum ≥ %95 ve görselsiz uyum ≤ %40. Karar yalnız n ≥ 40 soruda tanıdır; n < 40 ise ön bilgidir (ON_GECTI / ON_GECMEDI).

Çıktı klasörü (her üretim için): sorular.json, rapor.json (karar, kapı sonuçları, denge, kör sonucu), kontak.html (insan onayı sayfası), kor/ (svg/, png/, kor_gorselli.json, kor_gorselsiz.json, cevap dosyaları; git dışı).

Kararlar ve çıkış kodları: KAPI_RED (1), KOR_GECMEDI (1), EKSIK_URETIM (3), KOR_BEKLIYOR (0), ON_GECTI / ON_GECMEDI (0, uyarı), KOR_GECTI (0). Kullanım hatası ve kayıt sorunu: 2.

Komutlar: --liste, --dogrula, --ders/--sinif/--kod ile tek seçim, --hepsi (her kazanım kodu grubu ayrı klasörde), --kor-sonuc <klasor>. Ortak: --adet (varsayılan 20), --tohum (varsayılan 1), --klasor, --png-yok.

Test matrisi (node tools/gorsel-motoru/testler.mjs): uretici (kayıt sözleşmesi, ders eşleşmesi, konum sözleşmesi, denge, determinizm, her şablonun duman testi), paket (dosya seti, kapılar, kör sonuç, eksik üretim), kor (karar kuralı ve eşikler), motor ve tipler-ek (çizim, lint, olgu).

Bilinen sınırlar: (a) trafik ışığı şablonunda yalnız 6 farklı soru vardır; 20 istendiğinde karar EKSIK_URETIM olur (dürüstçe bildirilir). (b) Kör çözüm Haiku ile elle yapılır; program yalnız cevapları karşılaştırır. (c) Çubuk örüntüsü görselsiz ölçümde sınırdadır. (d) İngilizce ve Din Kültürü için kazanım kaynağı yoktur; şablon yazılmaz.

## 11.6 Doğrulama sonuçları (2026-10-28, program sağlığı turu)
- Testler: 42/42 geçiyor (`node tools/gorsel-motoru/testler.mjs`).
- Kayıt sözleşmesi: 17 şablon, her biri tek kazanım kodu, her kod kaynak dosyada var (`uret.mjs --dogrula`).
- Kanonik üretim (`gorsel/paket-v1`, adet 20, tohum 1): 13 grup 20/20, kapılar geçti, karar KOR_BEKLIYOR. Trafik (HB.1.2.3) 6/20: EKSIK_URETIM (şablonun kapasitesi 6; dürüstçe bildirilir).
- Kör çözüm tanısı (n=40, taze Haiku): MAT.5.1.3 kesir: görselli 39/40 (%97,5), görselsiz 8/40 (%20) → KOR_GECTI; tek yanlış MAT5-KSR-S11-033 (B işaretlendi, anahtar D). SB.5.2.1 ana/ara yön: görselli 40/40 (%100), görselsiz 7/40 (%17,5) → KOR_GECTI.
- Kapasite sınırları: MAT.5.2.3 çubuk örüntüsü 22 farklı soru (n ≥ 40 kararı verilemez); HB.1.2.3 trafik 6.
- Bu turda düzeltilen gerçek hatalar: (1) tekrar kontrolü harf sırasına bakıyordu; aynı soru farklı harflerle 10 kez çıkabiliyordu (trafik). Artık kök + görsel + doğru metin + şık kümesiyle karşılaştırılıyor. (2) Doğru şık konumu şablonla eşleşmiyorsa sessizce yanlış yazılabiliyordu; artık konum_uyumsuz ile reddediliyor. (3) "Türkçe" ile "turkce" eşleşmiyordu; ascii eşleşmesi eklendi. (4) Dinamometre alt metni skala değerlerini yazıyordu; kapı bunu sızıntı sayıyordu (yanlış alarm, 3 soru); alt metin tarifi değiştirildi. (5) Çubuk örüntüsü soru aralığı 14'ten 22'ye çıkarıldı. (6) Yinelenen paket betiği (kor-paketi.mjs) kaldırıldı; çıktı klasörü ve karar tek modülde (paket.mjs).
- Eski döngüsel setler `pilot/arsiv-doneme-1` ve `gorsel/arsiv-doneme-1` altına taşındı; yerlerine paket-v1 kullanılır.
- Not: kesir ve yön doğrulama klasörü, ajanlar çalışırken bir kez yeniden üretildi (üretim deterministik, girdiler aynı). Cevap dosyaları yeniden üretimden sonra yazıldı.
- Açık: kör çözüm hâlâ elle (Haiku) yapılıyor; program yalnız karşılaştırır. Kanonik paket-v1 setleri henüz kör çözülmedi; onlar için karar KOR_BEKLIYOR.

## 11.7 Kapasite turu (2026-10-28, devam oturumu)
- **Trafik (HB.1.2.3):** yeni şekil tipi `trafik-kavsak` (iki yollu kavşak, ana/yan yol etiketli) ve şablon `sablonlar/hayat1-kavsak.mjs`. Durum (5: en fazla bir yol kırmızı dışı) × sürücü (2) × sıra (2) × biçim (dikey/yatay, 2) = 40. Grup kapasitesi 6 → **46**.
- **Çubuk örüntüsü (MAT.5.2.3):** altıgen türü eklendi (sıra 5n+1 çubuk; yan yana altıgenler kenar paylaşır). 3 tür × 14 adım = **42** (n ≥ 40 kararı artık tanılanabilir).
- **Renk düzeltmesi (lint):** trafik yeşili `#2E9E44` → `#00A37A`. Döteranopide kırmızıyla ΔE 16.7 kalıyordu (eşik 20); yeni ton 28.2. Yalnız trafik şekillerini etkiler (`tipler-ek.mjs`).
- Testler 44/44; `uret.mjs --dogrula` 18 şablon tamam. `paket.test.mjs` trafik beklentisi 46'ya güncellendi.
- **Kanonik set:** `gorsel/paket-v2` (adet 20, tohum 1): 14 grubun 14'ü 20/20, kapılar geçti, karar `KOR_BEKLIYOR`. `paket-v1` değişmedi (karşılaştırma için duruyor).
- **Görsel kontrol:** kavşak PNG'de etiketler ve yanan lamba okunuyor; altıgen PNG'de 1/2/3 altıgen (6/11/16 çubuk) doğru.
- **Açık:** yeni iki tip ve paket-v2 için kör çözüm (görselli ≥ %95, görselsiz ≤ %40, n ≥ 40) henüz yapılmadı. Kör çözüm bağımsız bir çözücüyle yapılmalı; yazan oturum (bu oturum) şablonların cevap mantığını bildiği için kendi sonucunu kanıt sayamaz.

## 11.8 Yönetim paneline aktarım (öneri, uygulanmadı)
Mevcut durum: panelde JSON paket içe aktarma zaten var (`PaketImport.tsx` → RPC `admin_import_questions_v2`, `supabase/migrations/20261047000000_soru_paketi_ice_aktarma.sql`). Parti, tekrar kontrolü, `beklemede` varsayılanı, geri alma (silmez, `reddedildi` yapar) çalışıyor. Eksik olan: görsel alanları (SVG, alt metin, `gorsel_spec`) ne tabloda ne RPC'de var.
Öneri üç katman:
1. **Veri ve onay (panele taşınır):** `questions` görsel kolonları (SVG metin, alt metin, kapalı `gorsel_spec`), RPC'nin görsel alanları kabul etmesi, admin önizleme (SVG `data:` URI ile `<img>`), onay/red. `kontak.html`'in yerini alır. Migration taslağı kullanıcıya gösterilmeden uygulanmaz.
2. **Üretici (panelde çalışmaz):** Node + Python/PyMuPDF + kazanım dosyaları Vercel'de çalıştırılmaz. Yerel kalır; Faz 4'te Oracle toplu işi olabilir.
3. **Kör çözüm (panelde çalışmaz):** LLM işi. Sonuç `rapor.json` ile panele karar olarak yüklenebilir.
Öncelik: önce 1 (migration kararı kullanıcıda), sonra Flutter `SvgPicture.string` gösterimi (plan §8 Faz 2).
Taslak: `docs/soru-uretim/gorsel/MIGRASYON_TASLAK.sql` (uygulanmadı; `supabase/migrations`'a taşınmadı). Görselli paket için v3 RPC taslağı henüz yok.

## 11.9 Kör çözüm sonuçları (2026-10-29, paket-v2 n=40, tohum 2)
Kör çözüm, görselli ve görselsiz için ayrı Haiku ajanlarıyla yapıldı (her grup için iki ajan; görselsiz ajanı PNG açmadı). Kaynak: `scratchpad/paket-v2-40` (git dışı, test seti; kanonik `paket-v2` değil).

| Grup | Görselli | Görselsiz | Karar |
|---|---|---|---|
| HB 1.2.3 (tek ışık + kavşak) | %98 | %43 | KOR_GECMEDI |
| MAT 1.1.1 | %100 | %33 | KOR_GECTI |
| MAT 1.1.2 | %100 | %25 | KOR_GECTI |
| MAT 1.1.6 | %100 | %43 | KOR_GECMEDI |
| FB 5.2.1 | %100 | %25 | KOR_GECTI |
| MAT 5.1.3 | %100 | %25 | KOR_GECTI |
| MAT 5.2.3 (çubuk, altıgen dahil) | %100 | %35 | KOR_GECTI |
| MAT 5.3.1 | %100 | %40 | KOR_GECTI (sınırda) |
| MAT 5.3.4 | %100 | %50 | KOR_GECMEDI |
| MAT 5.3.6 | %100 | %28 | EKSIK_URETIM (n=32, ön bilgi) |
| MAT 5.5.1 | %100 | %28 | KOR_GECTI |
| SB 5.2.1 | %100 | %18 | KOR_GECTI |
| SB 5.5.3 | %100 | %33 | KOR_GECTI |
| T.O 5.6 | %100 | %25 | KOR_GECTI |

Yorum ve sınırlar:
- Üç grup eşiği aşıyor (HB 1.2.3, MAT 1.1.6, MAT 5.3.4). Görselsiz %43 ve %50, n=40'ta ±%8 hata payıyla şans düzeyine (%25–33) yakın olsa da eşik kuralı (≤ %40) geçmiyor. Kural değiştirilmedi.
- HB 1.2.3 grubu tek ışık ve kavşağı birlikte içerdiği için yeni tip ayrı ölçülmedi. Kavşak için ayrı ölçüm gerekiyor.
- MAT 5.3.4 neden %50 çıktı, henüz incelenmedi. Görselsiz doğru olan soruların çeldiricilerine bakmak gerekir.
- Görselsiz çözücülerden bazıları (MAT 1.1.1) A-B-C-D döngüsüyle cevap yazdı. Şans düzeyini tek başına etkilemez; ancak tam sonuç için tekrar edilmeli.
- Paket-v1 hiç kör çözülmedi. v1 ile v2 aynı değil (üretici sonradan değişti, MAT 5.1.3 girdisi farklı); v2 kanonik kabul edildi.
- MAT 5.3.6 yalnız 32 soru üretebiliyor; karar için şablon genişletilmeli.
