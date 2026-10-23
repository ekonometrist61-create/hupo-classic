# HupoRead veri hattı: model karar önerileri (2026-10-23)

Bu belge öneridir. Yayına dönük son karar proje sahibindedir. Hiçbir mevcut dosya değiştirilmedi, uzak veritabanına dokunulmadı.

## 1. Sözlük (801 aday)

**Öneri:** `sozluk-onerileri.csv` esas alınarak aday listesi onaylansın: **evet 510 / hayır 44 / düzelt 247**.

- Düzeltmelerin 183'ü yalnızca es/zıt alanı temizliği (es 129, zıt 57). Aday satırlarının es/zıt alanı çoğunlukla gerçek eş/zıt anlam değil, "ilişkili sözcük" bağıdır (ör. harita–pusula, tempo–ritim, ihmal–denetim). Bu alanlar yayımlanırsa öğrenciye yanlış eşleştirme öğretir; boş bırakılması önerilir.
- Kalan 64 düzeltme: yazım/büyük harf (Uyum, Çarkların, Simetri vb. ortak adlar küçük harf), anlam hatası (işe el atmak, gözü karardı, boynunu bükmek, kaşlarını çatmak, bakır, uslu), tür hatası (deyim olarak etiketlenmiş sıradan söz öbekleri), `topoğrafya` yazımı.
- Hayır 44: deyim olmayanlar (kaşlarını oynatmak, karnını tutmak, ölçü tutmak, tartmadan konuşmak, üstünü başını bilmemek, gözlerini çevirmek, dikelmek), sınıf düzeyini aşanlar (higrometre, opak 3. sınıfta), bağlamla ilgisiz çeldiriciler, kopya (339, 657).
- Sistematik gözlemler: (a) iki satırda es/zıt kimliği var olmayan bir yuvaya işaret ediyor (hr015_solmak, hr026_kar_kazanc; ayrıca hr073_agirbasli, hr074_yorum, hr059_kovan); (b) `yazim` sütunu hikâyedeki çekimli biçimi taşıyor (albümünde, mandalı...), yalın biçim sözlük arayüzü kararına bağlı; (c) satır kimliği için CSV satır numarası kullanıldı, yuva kimlikleri bazı yerlerde tekrar ediyor.
- Sınırlama: zıt/eş kararları anlam bilgisine dayanır; resmî sözlük (TDK) ile satır satır karşılaştırma yapılmadı.

**İnsan incelemesi için en belirsiz 10 satır (hikâye + yazım):**
HR-023 gözlerini büyüttü · HR-024 gözü kaymak · HR-027 öne çıkmak · HR-033 dış görünüşe aldanmak · HR-043 elini kaldırdı · HR-050 kafası dağılmak · HR-063 boynunu bükmek · HR-073 aklında kalmak · HR-081 gözlerini devirdi · HR-090 gözü karardı

**Kanıt:** `icerik/okuma/tasnif/sozluk-adaylari-inceleme.csv` (girdi, `onay` sütununa dokunulmadı), `icerik/okuma/tasnif/sozluk-onerileri.csv` (çıktı; sütunlar model_karari, model_gerekce, model_duzeltme).

## 2. Kanıt düzeyi (kanit_duzeyi C)

**Öneri: 77 anotasyonun tamamı C kalsın.** (Anotasyon dosyası 77, 3-8. sınıf: 3.s 11, 4.s 12, 5.s 20, 6.s 20, 7.s 13, 8.s 1; görev metnindeki "76 hikâye, 5-7. sınıf" ifadesi tam değil.)

- Gerekçe: Depoda hikâye düzeyinde doğrulanabilir bir MEB kazanım eşleşmesi yok. `icerik/okuma/tools/donustur.mjs` satır 289 `kazanim_kodu: null` üretir; anotasyonlarda `program_surumu` yalnızca "TYMM 2026-27 (N. sınıf; okuma evresi insan editörce kontrol edilecek)" der.
- `sema/etiket-sozlugu.v1.json` (`sinif_olcutleri`) bu depoda bulunamadı; `tasnif/OLCUT.md` onu anıyor ama değerlerin "PILOT_HEDEF, MEB kotası değildir" olduğunu söylüyor. Uzunluk ölçütü zaten kanıt düzeyi için kullanılamaz.
- Depoda yalnızca sözcük kazanımlarını kapsayan resmî alıntı var: `docs/kelime-evreni/veritabani/mufredat.json` (18 alt madde, T.K.x.22, T.O.x.2 vb.; kaynak: MEB 1-4 sınıf 2026 ve ortaokul 2025 Türkçe programları). Bu, tek tek hikâyeyi değil, yalnızca sözcük/anlam kazanımını kanıtlar; hikâyenin kazanımla eşleştiği anlamına gelmez.
- Web taranmadı.
- **Yükseltme için gereken belge:** (1) MEB Türkçe 1-4 (2026) ve Ortaokul Türkçe (2025) öğretim programlarının tam kazanım listesi (T.O./T.D.) depoya alınmış hâli; (2) her hikâye için editörün imzaladığı "hikâye → kazanım kodu" eşleme tablosu (kod, sınıf, kanıt cümlesi); (3) 8. sınıf HR-099 vb. için sınıf düzeyi teyidi. Bunlar olmadan B'ye çıkmak yanıltıcı olur.

**Kanıt:** `icerik/okuma/anotasyon/hr*.json` (77), `icerik/okuma/tools/donustur.mjs`, `docs/kelime-evreni/veritabani/mufredat.json`, `PROJE_GUNLUGU.md` satır 89 ve 108.

## 3. Uyum: HR-015…032, uzak taslak ile yerel paket

**Öneri: BEKLE (hold); uzağa yazma, yerel paketlerle uzak taslakların üzerine yazma.** Eğilim: içerik kaynağı olarak uzak (elle düzenlenmiş) sürüm daha olgun; yerel paketler yalnızca anotasyon/sözlük adayı üretimi için "kaynak metin birebir derleme" olarak kalsın.

Doğrulanan (migration dosyalarından, JSON ayrıştırılarak karşılaştırıldı):
- Uzak taslaklar iki migration'da: `supabase/migrations/20261062000000_okuma_pilot3_4_icerik.sql` (15 hikâye: 015, 018, 019, 021-032; `uretim.kaynak = elle`, sözlük yok) ve `supabase/migrations/20261077000000_okuma_ikon_sozluk_taslak.sql` (45 hikâyeye yeni TASLAK sürüm; ikon eşleşmeleri ve hikâyeye özgü `sozluk` paket içinde). Aralıkta HR-016 ve HR-017 yalnızca uzakta var (yerel paket yok; `supabase/tests/okuma_dunyasi/hr016-...hikaye.md` izlenmeyen dosya olarak duruyor).
- Yerel paketler (`icerik/okuma/paket/hr015…hr032-*.paket.json`): 15 hikâye (015, 018, 019, 021-032; 016 ve 017 yok), `uretim.kaynak = llm_taslak`, her ikisinde `paket_surumu = 1`. **Sürüm numarası ayırt etmiyor.**
- Fark içerik düzeyinde: 15 ortak hikâyenin 15'inde `sayfalar`, `sorular`, `uretim` ve `sozluk` farklı. Sayfa sayısı yerelde 4-7, uzakta 7-9; soru sayısı yerelde 3-4, uzakta 5-6. Kelime sayısı örnek: HR-015 yerel 585 / uzak 643; HR-018 612 / 703; HR-032 860 / 723. HR-032 başlığı uzakta "Pazardaki Akıllı Terazi", yerelde "Keloğlan ve Akıllı Terazi". Uzak metin kahraman jetonlu ve kısaltılmış (HR-015 ilk cümlede "pencere kenarında" düşmüş); yerel metin `kaynak/p15yeni-2parti.md` ile aynı yazarın özgün metni.
- Eksik satır: yerelde HR-016 ve HR-017 paketi yok (uzakta var).
- `PROJE_GUNLUGU.md` GÖR-054 ve satır 127 bu kararı "K-0110 / K-0108, bekliyor" olarak açıkça işaretliyor; bu oturumdan uzağa yazılmadığını belirtiyor.

Doğrulanamayan: Uzak veritabanındaki canlı satırlar. `docs/okuma-entegrasyon/FAZ_DURUMU_2026-10-23.md` satır 6 yerel ve uzak migration listesinin eşleştiğini söylüyor, ama veritabanına bağlanılmadı; panelden sonradan yapılan düzenlemeler (yeni taslak sürüm) bu depodan görülemez. Bu yüzden "uzak şu anda tam olarak şudur" denmez.

Neden bekle: iki taraf da "taslak", ikisi de insan okumasından geçmedi (`FAZ_DURUMU` satır 22 "insan okuması kullanıcıda"). Yerel tarafı uzağa yazmak elle düzenlenmiş içeriği silebilir; uzağı yerele çekmek ise anotasyon `spans`, `hedefler` ve sözlük adaylarını kaydırır (metin farklı). Önce 15 ortak hikâyenin alan bazlı farkı insan tarafından okunmalı.

**Kanıt:** yukarıdaki iki migration, `icerik/okuma/paket/hr015-*.paket.json … hr032-*.paket.json`, `icerik/okuma/anotasyon/hr015.json … hr032.json`, `docs/okuma-entegrasyon/FAZ_DURUMU_2026-10-23.md`, `docs/okuma-entegrasyon/UYUM_PLANI_2026-10-22.md`, `PROJE_GUNLUGU.md` (GÖR-054, satır 127, 377).

## 4. HR-111 / HR-112 (v1 ve v2)

**Öneri: v1 (`kaynak/HR-111.md`, `kaynak/HR-112.md`) esas alınsın.**
- Başlık aynı (Cam Şehrin Kırık Yasası; 2055: Hatırlayan Şehir), ikisi de 8. sınıf. Gövde kelime sayısı: v1 ≈ 3.950 / 3.940; v2 ≈ 4.010 / 4.010. Yani fark yaklaşık %2; "4.000-5.000" hedefini v2 de ancak sınırda yakalıyor.
- v2'de "Hedef kelime aralığı: 4.000-5.000" notu var; v1'de yok. Bu not `tasnif/OLCUT.md`te pilot üst sınırla (8. sınıf 1100) çelişen madde olarak zaten işaretli. İki sürüm de 8. sınıf sınırının yaklaşık 3,6 katı (T4).
- v1'de tür, dil hedefleri, kavramlar, ikon önerileri gibi anotasyona gereken künye var; v2'de yok ve 35 başlıklı (3A/3B gibi) üretim durumu belgesi içinde. Tür de değişmiş (Fantastik/distopya yerine Bilim kurgu/distopya). v1 daha temiz bir kaynak.
- Her iki sürümde de "editör incelemesi bekliyor".

**Kanıt:** `icerik/okuma/kaynak/HR-111.md`, `HR-112.md`, `p16-son-parti-HR111-112.md`, `icerik/okuma/tasnif/OLCUT.md` §3 ve §4.

## Sahibin onayı gereken

1. Sözlük: 44 "hayır" ve 247 "düzelt" satırı; özellikle es/zıt alanlarının toplu boşaltılması (183); 10 belirsiz satır.
2. Kanıt düzeyi: C'de kalma onayı ve hikâye→kazanım eşleme tablosunun kim tarafından, hangi belgeyle hazırlanacağı.
3. Uyum: HR-015…032 için hangi tarafın içerik kaynağı olacağı (öneri: bekle, alan bazlı fark okuması); HR-016/017 için yerel paket üretimi.
4. HR-111/112: v1'i esas almak ve 4.000-5.000 kelime hedefi ile 1100 pilot sınırı arasındaki çelişkiye karar vermek.
