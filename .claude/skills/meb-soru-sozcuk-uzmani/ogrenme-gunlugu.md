# MEB soru-sözcük uzmanı: öğrenme günlüğü

Her girişte: tarih | sınıf | konu | öğrenilen | kanıt | durum (ONAYLI / ÖNERİ / KARAR BEKLİYOR).
Kural değişikliği yalnızca kullanıcı onayıyla ONAYLI olur. Ajan ve model önerileri ÖNERİ olarak girer.

## 2026-11-10 · kör denetim-3 (20 hikâye, 16 rapor) · kararlar hikâye `denetim:` alanına işlendi · DB'ye yazılmadı
- **Kanıt:** `docs/okuma-entegrasyon/denetim/2026-11-09-kor-denetim-3/ozet.md`. Ajan A pass 9, Ajan B pass 1 (HR-024, iki ajan pass). HR-052 Ajan B fail. Kritik yok.
- **Yapılan:** 20 dosyada `denetim: {ajan_a, ajan_b, insan: pending}` alanları raporlara göre güncellendi; `durum` ve `published`/`editor_approved` değişmedi.
- **Öğrenilen:** Panel (Hikâye Atölyesi) karneyi sunucudaki RPC'lerden okuyor; sunucuya yazmak yönetici oturumu ve ayrı onay gerektirir. İçe aktarma (`okuma_paket_ice_aktar`) ile yansıtılır.
- **Açık:** HR-052 düzeltmesi; 18 review_needed hikâye için tur seçimi; HR-024 insan incelemesi.

## 2026-11-09 · kör denetim tamamlandı (36 hikâye, 12 ajan) · 0 pass (iki ajan) · düzeltme ve karar bekliyor
- **Kanıt:** `docs/okuma-entegrasyon/denetim/2026-11-09-kor-denetim/ozet.md` (karar tablosu ve sistematik bulgular); 72 ajan raporu yerine 36 hikâye × 2 ajan yerine 12 ajan (her ajan 6 hikâye), hepsi kör.
- **Sonuç:** Ajan A'da 17 pass; Ajan B hiçbir hikâyeye pass vermedi; 20 hikâye Ajan B'de fail. Kritik bulgu yok.
- **Öğrenilen (önemli):** Uzunluk ve vaaz bulguları HR-049–062 kümesinde yoğunlaşıyor (1870–3030 kelime, 5. sınıf editoryal ~650). HR-057–062'nin soru nesnelerinde `dayanak` alanı yok; yalnız `dayanak_sayfa` var. Bu, birebir dayanak kontrolünü engelliyor ve ayrı bir yapı sorunu.
- **Öğrenilen:** Seçenek dengeleme aracı (`okuma-secenek-dengele.mjs --uygula`) bir hikâyede (HR-126) sayfa ayracını cümleye yapıştırdı. Araç çıktısı için ayraç satırı kontrolü eklenmeli.
- **Öğrenilen:** Ajanların "dayanak alanı yok" notu doğru çıktı; ama bu bulgu sayıya dahil edilmedi. Yapısal eksikler artık sayıma dahil edilmeli.
- **ÖNERİ (onaysız):** Vaaz ve uzunluk düzeltmesi ile HR-057–062 dayanak yapısı için editör kararı; sonra yalnızca değişen hikâyelerde yeniden kör denetim.

## 2026-11-09 · düzeltme dördüncü tur (HR-123, 125, 126, 127, 128, 132) + temizlenen 30 hikâyenin kontrolü · DÜZELTME UYGULANDI, KÖR DENETİM YAPILMADI
- **Kanıt:** Düzeltilen dosyalar `icerik/okuma/hikaye/hr123…`, `hr125…`, `hr126…`, `hr127…`, `hr128…`, `hr132…`. Girdi raporları `docs/okuma-entegrasyon/denetim/2026-11-08-hr121-132-yeniden-3/`. `tools/okuma-hikaye-denetim.mjs --ayrinti`: 104 hikâye, 432 soru, sorusuz yok, karşılıksız ad yok. Dayanak cümleleri 6 hikâyede birebir metinde (0 kaçırma).
- **Temizlik kontrolü (30 hikâye):** Silinen bloklar `@omurga`-etiketli editör notlarıydı; kalan `@omurga` satırları bölüm ayıracıdır. HR-015 sonu okundu, hikâye yapısı bozulmamış. Frontmatter `program_surumu` ve `Not:` kaynak beyanları duruyor.
- **Yapılan (6 hikâye):** HR-123: s4 haberi "planlandı" yerine tamamlanmış olaya çevrildi (ajan A yüksek bulgu); çeldiriciler metinle ilgisiz nesnelerden çıkarıldı; s2 doğru şık en uzun olmaktan çıkarıldı; s2 dayanağı metinle birebir. HR-125: "yankı" → "tını" (hedef id `tini_hr125`); s3 çeldiricileri metinde geçmeyen eylemlerle değişti, s3 çıkarım oldu; "Acele karar verdik" öğüdü çıkarıldı. HR-126: s4 "güvenle" amacı metinde yoktu, kök ve doğru şık metindeki uzaklık bilgisine indirildi; eğim cümlesi yatay mesafe hatasından çıkarıldı; `yetiskin_uygun: false` eklendi; tanıtım metne hizalandı. HR-127: 1969 yılı karşılaştırma bölümünden önce açığa çıkmıyor; s1 doğru şık en uzun değil; `yetiskin_uygun: false` eklendi. HR-128: "sorumluluk" hedefi son blokta sahneye girdi; `yetiskin_uygun: false` eklendi; s2 açıklaması metne bağlandı; s4 kökü şıkla çakışmıyor. HR-132: s2 açıklaması metne bağlandı; s4 kökü dayanakla hizalandı; s3 sözcük bağlamı sorusu (telafi) eklendi, s5 çıkarıldı.
- **Öğrenilen:** Ajanların "dayanak birebir değil" ve "kök dayanağa uymuyor" bulguları, dayanak cümlesini metinle yeniden karşılaştıran küçük bir kontrolle doğrulanabiliyor. Bu kontrol her düzeltmeden sonra yapılmalı.
- **Öğrenilen:** Düzeltme metni "yayın kanıtı" değildir. Bu turda iki bağımsız (kör) denetim yapılmadı; ana oturum düzeltmeyi yaptı ve kendi kendini kontrol etti. Yayın kararı için ayrı kör denetim gerekiyor.
- **Açık (bilerek bırakıldı):** `tur: bilim` ile kurgusal tren hikâyeleri (HR-128, HR-132) uyuşmuyor; HR-126 metni ~340–360 kelime (3. sınıf pilot ölçütü 330); HR-125 ritim sorularında bir çıkarım sorusu hâlâ hatırlama ağırlıklı; HR-128 s5 doğru şık dayanakla neredeyse aynı. Tüm hikâyelerde kazanım kodu `source_pending`, TDK sözlük onayı `pending`.
- **ÖNERİ (onaysız):** 6 hikâye ve 30 temizlenmiş hikâye için iki bağımsız kör denetim (Ajan A/B) ayrı bir turda yapılsın. Yayın kapısı kullanıcı onayına kalsın.

## 2026-11-08 · DEVİR · hikâye denetimi (HR-015–132) · başka sohbette buradan devam
- **Durum:** Hiçbir hikâye yayın adayı değil (`published=false`, `editor_approved=false` dokunulmadı).
  - HR-015–114 (92): ilk A/B tam turu tamam (184 rapor). Ajan A pass 71; Ajan B pass 0; fail 3 (HR-060/061/062 editör notu kritik bulgusu — notlar temizlendi, yeniden denetim bekliyor). Özet: `docs/okuma-entegrasyon/denetim/2026-11-08-hr015-114/ozet.md`.
  - Editör notu temizliği: 30 hikâye (HR-015–062), yalnız etiketli editör blokları silindi, git diff'te ekleme 0. `Not:` kaynak beyanları korundu.
  - HR-121–132 (12): HR-121, 122, 124, 129, 130, 131 iki ajandan pass. Açık 6: HR-123, 125, 126, 127, 128, 132. Üç düzeltme turu yapıldı; üçüncü turda açık sayı 6'da kaldı. Özet: `docs/okuma-entegrasyon/denetim/2026-11-08-hr121-132-yeniden-3/ozet.md`.
- **Yeni sohbette ilk iş:** Kullanıcıdan iki karar al: (1) temizlenen 30 hikâye yeniden denetlensin mi (öneri: evet); (2) açık 6 için dördüncü tur mu, editör düzeltmesi mi. Ayrıca "Not:" kaynak beyanlarının silinip silinmeyeceği.
- **Açık kalan teknik:** Sınıf kelime/cümle bandı ölçütü (pedagoji paketi `docs/pedagoji-paketi/skills/hupo-s*-hikaye/SKILL.md`) denetçilere tam verilmedi; uzunluk bulguları gözlem. TDK sözlük onayı (`sozluk_tdk pending`) ve kazanım kodları (`source_pending`) doğrulanmadı.
- **Süreç notu:** Ajan bazen raporu dosyaya yazmıyor (HR-121–124 yeniden-2 örneği). Prompt'a "dosyaya yazmak zorunlu" eklendi ve işe yaradı. Oturum limiti (429) bir turu yarıda kesti; eksik raporlar diskten sayılıp yeniden başlatıldı. Denetim sayımı her zaman diskten yapılmalı.
- **Düzeltme:** Önceki özetteki ajan A sayısı 8/4 yazılmıştı; doğrusu 9/3.

## 2026-11-08 · editör notu temizliği + üçüncü düzeltme turu · 6 açık hikâye hâlâ açık
- **Kanıt:** `docs/okuma-entegrasyon/denetim/2026-11-08-hr121-132-yeniden-3/ozet.md`; temizlik 30 hikâyede (HR-015–062), yalnız etiketli editör blokları silindi, "Not:" kaynak beyanları korundu. git numstat: temizlenen 30 dosyada ekleme 0.
- **Öğrenilen:** Editör notu kalıbı tek satır değil; bazı hikâyelerde operatör talimatı ve "Durum özeti" sayfaları da vardı (HR-032). Temizlik öncesi kuru çalıştırma ile silinecek satırlar tek tek gözden geçirildi.
- **Öğrenilen:** Üçüncü tur sonrası 6 açık hikâye değişmedi (6 → 6). Son turlar bulguları yer değiştirdi; dördüncü düzeltme turu verimsiz görünüyor. Kalan iş editör kararı gerektiriyor.
- **ÖNERİ (onaysız):** Temizlenen 30 hikâye yeniden denetlensin (B'nin fail/review sebebinin bir kısmı artık çözüldü). Yayın için kalan vaaz ve soru bulguları editöre bırakılsın.

## 2026-11-08 · hikâye A/B denetimi, tam tur (HR-015–114 + HR-121–132) · 0 yayın adayı · insan kararı bekliyor
- **Kanıt:** `docs/okuma-entegrasyon/denetim/2026-11-08-hr121-132-yeniden-2/ozet.md` (12 hikâye: 6 iki ajan pass, 6 açık); `docs/okuma-entegrasyon/denetim/2026-11-08-hr015-114/ozet.md` (92 hikâye, 184 rapor: pass 71, review 110, fail 3).
- **Öğrenilen (önemli):** Ajan B, 92 hikâyenin hiçbirinde pass vermedi. Ana sebep vaaz ve sondaki editör notu bloğu ("Kavramlar / Dil / Güvenlik"). Bu blok bazı hikâyelerde kritik (HR-060, 061, 062), çoğunda yüksek. Yayın öncesi toplu temizlik gerekiyor.
- **Öğrenilen (süreç):** Bir ajan (Ajan A, HR-121–124 yeniden-2) raporu dosyaya yazmadı, metni mesajda verdi; ana oturum dosyaları mesajdan yazdı. Denetim promptunda "dosyaya yazmak zorunlu" kuralı eklendi ve sonraki turlarda işe yaradı. Bir tur oturum limiti (429) yüzünden yarıda kaldı; eksik raporlar diskten sayılıp yeniden başlatıldı.
- **Düzeltme:** Önceki özet ajan A sayısını 8/4 yazmıştı; doğrusu 9/3 (düzeltildi).
- **ÖNERİ (onaysız):** Editör notu bloğu temizliği tüm hikâyelerde toplu yapılsın; sonra yalnız değişen hikâyeler yeniden denetlensin. Açık 6 hikâye için üçüncü düzeltme turu kullanıcı kararı.

## 2026-11-08 · 1.–3. sınıf hikâye (HR-121–132) · A/B denetim turu · önceki tur (özet)
- **Kanıt:** `docs/okuma-entegrasyon/denetim/2026-11-08-hr121-132/` (PLAN.md, ozet.md, 24 ajan raporu). Mekanik kontrol `tools/okuma-hikaye-denetim.mjs --ayrinti`: sorusuz hikâye yok, karşılıksız ad yok.
- **Öğrenilen (önemli):** HR-121–132 için A/B raporu yoktu; 2026-10-25 grup denetimleri tek denetçili ve farklı biçimdi, A/B yerine geçmez. Hikâye mtime'ı 10-25/10-27'de değişmiş; HR-015–114 A/B raporları eski metne ait. Kapsam tespitinde mtime değil rapor varlığı ve rapor tarihi karşılaştırıldı.
- **Sonuç:** Ajan A 9 pass / 3 review_needed; Ajan B 0 pass / 12 review_needed (sayım düzeltildi: önceki yazım 8/4 idi); kritik ve fail yok. Yüksek bulgular: HR-125 (ritim çizelgesi çelişkisi, A ve B), HR-128 ve HR-131 (sonda ders, B).
- **Öğrenilen:** Vaaz tonu (sonda "fark etti/öğrendi" ve ahlak repliği) bu turda en sık tekrar eden B bulgusu; yazım aşamasında kaldırılmalı.
- **ÖNERİ (onaysız):** HR-015–114 için 92 hikâyenin A/B yeniden denetimi ayrı tur olarak planlansın (kullanıcı kararı).

## 2026-10-27 · 6. sınıf Matematik MAT.6.1.2 · 6 soru üretildi, otomatik kapılar ve kör çözüm geçti (K-0154) · insan denetimi bekliyor
- **Kanıt:** `docs/soru-uretim/pilot/uretim_mat612_gor070_2026-10-27.json`, `kapi_sonuc_mat612_gor070_2026-10-27.md`; resmî DÖP PDF'i 67. sayfa metin katmanı.
- **Öğrenilen (önemli):** Kazanım JSON'undaki ana cümle PDF satır sonu tire bölünmesinden kırpıktı ("çıka-"). Betik bunu "kazanım metni kaynakla farklı" diye yakaladı. Düzeltme için önce resmî PDF metni çıkarıldı ve karşılaştırıldı; düzeltme kanıtla yapıldı. Tahmine dayalı düzeltme yapılmadı.
- **Öğrenilen:** Betiğin `kanit_kural_ile_A` kuralı matematikte de A verebiliyor. Skill tablosu A adayını okuma çözümlemesiyle sınırlar. Betik, matematik için bu ayrımı yapmıyor; kayıt B kaldı.
- **Öğrenilen:** Betiğin `dogru_sik_en_uzun` kontrolü eşit uzunlukta şıklarda ilk şıkkı (A) üst kabul ediyor. Eşit uzunluk için doğru şıkkı A dışında tutmak gerekti.
- **Öğrenilen:** Aynı model ailesinde kör çözüm ve ikinci denetim "iki farklı yapay zekâ" kuralını tam karşılamaz; kayıtta belirtildi.
- **ÖNERİ (onaysız):** 105 numaralı sorunun pedagojik denetimi tekrar edilsin; betiğe matematik ayrımı eklensin.
- **Uygulandı (Sonnet kararı, 2026-10-27; kullanıcı delege etti):** `soru_kontrol.mjs` kanıt kuralı: kazanım kodu `T.O.` değilse B. Gerekçe: SKILL.md tablosu A'yı okuma çözümlemesi kazanımlarına bağlıyor; betik bunu uygulamıyordu. Tablo değiştirilmedi. **Kullanıcı onayı bekleniyor** (yorum uygulaması olarak günlüğe yazıldı).
- **Uygulandı:** kazanım JSON'unda MAT.6.1.2 alt maddeleri ve `program_surumu` resmî PDF metniyle düzeltildi (K-0154).

## 2026-10-27 · 6. sınıf Matematik MAT.6.1.2 + 2–3. sınıf Türkçe eş/zıt (GÖR-070) · KARAR BEKLİYOR (blueprint: docs/soru-uretim/BLUEPRINT_GOR070_MAT612_2026-10-27.md)
- **Kanıt:** `docs/soru-uretim/pilot/kazanim_2_turkce.json` (kapsam notu 2026-10-22), `kazanim_6_matematik.json`, `docs/mufredat/yillik_plan_2026_2027.json` (T.K.2.2 / T.K.3.2 / T.O.2.2 satırları), DB salt okunur sayım.
- **Öğrenilen (önemli):** Kazanım kodunu yalnız "kod ve dersin planında var" diye kabul etmek yetmiyor; **kapsam notu** (konuşma kazanımları kapsam_disi) ve **kod–sınıf–madde uyumu** de bakılmalı. `T.O.2.2` kodu 2. sınıf metninde a–c taşır; zıt anlam maddesi (f) 3. sınıf satırında kodsuz değil yanlış kodla duruyor. Bu tür kodu kullanmadan önce kaynak kodunu bul.
- **Öğrenilen:** Onaylı ama `kazanim_kodu` boş sorular (2. ve 3. sınıf eş/zıt) kazanım kanıtı sayılmaz; mevcut sayı yanıltıcı olur.
- **Öğrenilen:** Kazanım JSON'unda `program_surumu` ile kod sınıfı çelişebilir (6. sınıf kodu, "5. sınıf DÖP" etiketi). Etiket düzeltilmeden A verilmez.
- **Kanıt düzeyi:** MAT.6.1.2 için B (kesik metin, PDF teyidi yok). Türkçe için kanıt yok, bloke.
- **ÖNERİ (ÖNERİ, onaylı değil):** Türkçe hedefi için karar gerekli (kullanıcı K-0151'de).

## 2026-10-25 · 2. sınıf · HR-017 düzeltme adayı (sürüm 4) · KARAR BEKLİYOR (insan editör; DB'ye yazılmadı)
- **Kanıt:** `docs/okuma-entegrasyon/duzeltme/HR-017-surum4-aday/` (aday paket, öneri raporu). Denetim girdisi `denetim/2026-10-24/denetim-girdi/HR-017.txt` (sürüm 3, sha 28ff45…). Önceki 10-23 A/B raporları.
- **Öğrenilen (önemli):** 2026-10-24 denetim raporları yalnızca metni değerlendirmiş; soruları değerlendirmemiş. Aynı hikâyenin 10-23 raporundaki kritik soru bulgusu (s2 cevap anahtarı metinle çelişiyor) 10-24 "pass" ile örtülmüş. **Denetim raporunun kapsamı (metin / soru / sözlük) rapor başlığında yazılmalı;** kapsamı belirsiz "pass" yayın kanıtı sayılmaz.
- **Öğrenilen (kök kuralı):** Dayanak cümlesi kökte yoksa soru çözülemez (kural 14). s2 ve s3 bu nedenle yeniden kuruldu: kök, öğrencinin gerektirdiği olayı içerir.
- **Öğrenilen (şık sayısı):** `soru_kontrol.mjs` her soruda dört şık bekliyor; doğrulayıcı üç şığa izin veriyor. Üç şıklı sorularda araç kapsam ve şık kontrollerini çalıştırmıyor. **ÖNERİ:** betiğin şık sayısı kontrolü 3–4 olmalı.
- **Öğrenilen (hedef):** Ölçülmeyen hedef bırakılmamalı. "Denge" metinde işlenmiyor (çıkarıldı); atasözü `background` (editör kararı). "yeni" için soru eklendi.
- **Kanıt düzeyi:** 2. sınıf resmî metni depoda yok; kazanım kodu yok; kanıt C kalır, A verilmedi.
- **Kontroller:** dayanak 5/5 birebir; doğru şık en uzun değil 5/5; cevap dağılımı A2 B1 C2; olculen tutarlı; kelime 199 (aynı yöntemle eski sürüm 215).
- **Açık:** kör çözüm ve bağımsız denetim yapılmadı; sunucu doğrulayıcısı (kuru çalıştırma) admin oturumu gerektirir.
- **Yerel doğrulama (2026-10-25):** gerçek `okuma_paket_ice_aktar` PGlite'te (üretim dışı) çalıştırıldı. Eski sürüm ve aday: `gecerli=true`, `hatalar=[]`; aday ayrı sürüm olarak yazıldı. Uzak veritabanına yazılmadı.
- **Karar (ONAYLI, kullanıcı 2026-10-25):** (1) "Denge" hedefi çıkarıldı; (2) atasözü hedefi `background` kalır.
- **Karar bekleniyor:** (3) s2 kurgusu (kullanıcı henüz onaylamadı), (4) insan son okuması.
- **Açık (üretim):** katalogda `kavram_hr017` (onaysız) sürüm 3'ün içe aktarımından kalmış; aday kullanmaz. Silinmesi isteğe bağlı.

## 2026-10-24 · Okuma Dünyası: kahraman brief'leri (Hazır Hupo 3, Annem 3, Babam 4, Araç 5) ve izinli_turler adayları · TASLAK (yayın yok, insan onayı en sonda)
- **Kanıt:** `docs/okuma-entegrasyon/brief/README.md`, `izin-eslestirme-adaylari.md`; yerel paket taraması (94 paket: ben/arkadas 94, anne/baba/hazir/arac 0); veritabanı 45 farklı hikâye, 109 sürüm.
- **Öğrenilen:** Kahraman türü eşleşmesi yalnız etiketle yapılamaz; `{kahraman}` yer tutucusu çocuk adı taşır, ama rol (anne, baba, araç) metin mantığını değiştirir. Metinde "anne" geçmesi annenin kahraman olabileceği anlamına gelmez. Babam (4. sınıf) önceki programdadır; TYMM kodu yazılmaz.
- **Kazanım:** Brief'lerde kod yazılmadı; 5. sınıf TYMM metninde T.O.5.* kodları görüldü, eşleme metin okunduktan sonra yapılacak (`source_pending`).
- **Sayı düzeltmesi:** Yerelde veritabanında olmayan hikâye sayısı 49 değil 67 (taslak SQL ona göre üretildi).
- **Kanıt düzeyi:** Yeni brief'ler C ile başlar.
- **ONAYLI değil:** Brief'lerin içeriği ve değer kodları (D-kodları) kullanıcı/editör kararı bekliyor.

## 2026-10-24 · 3. sınıf Matematik pilotu (meb-odsgm-3mat, otomatik aşamalar) · KANIT (ölçek ve hakem kararı kullanıcıda)
- **Kanıt:** ingest 12 aday (kaynakta 70 madde; yalnız 12'si çoktan seçmeli); enrich 12; hakem 12 yeni, kör çözüm 12/12 anahtarla uyumlu; qa 10 yeşil, 2 sarı (okunabilirlik: ortalama cümle 25 kelime, 3. sınıf üst sınırı 16; ipucu sızıntı şüphesi), 0 kırmızı.
- **Öğrenilen:** Ölçek hedefini kaynak sayımıyla baştan doğrula: çoktan seçmeli oranı düşük kaynaklardan ~100 soru çıkmaz. Hakem modeli üreticiyle aynıysa (`HAKEM_MODEL` tanımlı değil) hakem notu bağımsız denetim sayılmaz (SISTEM §2 adım 4).
- **Açık:** Pilot ölçeği ve hakem modeli kararı kullanıcıda; insan incelemesi yapılmadı.

## 2026-10-24 · 4., 6. ve 8. sınıf · 6. sınıf kazanım metinleri ve 8. sınıf kararı · ONAYLI (kullanıcı kararları; DB yazımı uygulandı)
- **Kanıt:** `docs/soru-uretim/pilot/kazanim_6_turkce.json` 91 kod; 23 ana cümle değişti (8 bilinen + 15 ek). Betik `verify_k6.mjs`: 91/91 ana cümle resmî metinde kodun yakınında. DB (`sinif=6`): 15 Türkçe kodun metni eski ve bozuk; 3'ü resmîyle aynı; 5'inin kaydı yok.
- **Öğrenilen:** DB `kazanim_metni` "ana cümle | a) … | b) …" biçiminde. Karşılaştırma yalnız ana cümleyle yapılmalı; tüm metinle yapılan ilk karşılaştırma yanlış hizalandı. Bileşenler (a/b/c) çoğu kodda yanlış satırdan geliyor; ana cümle doğrulaması bileşeni doğrulamaz.
- **Kural (8. sınıf):** Kazanım kodu taşımayan kayıt (2026-10-07 seed, 60 kayıt) geçersiz kod gerekçesiyle `beklemede` yapılmaz. Kod taşıyan 2026–27 önceki program kaydı K-0118 ile `beklemede` olur.
- **Karar (ONAYLI):** 4. sınıfta kodlu 109 soru `beklemede` yapıldı; DB yazma izni verildi ve uygulandı; bileşenler yeniden çıkarıldı ve DB ile eşitlendi (fark 0).
- **Açık:** 8. sınıf yedek üretimi için kaynak kararı.

## 2026-10-24 · hupo-deneme-uzmani uçtan uca testi (6. sınıf Türkçe haftalık) · ONAYLI (kullanıcı talebi)
- **Kurulum:** Harici "Deneme V3 / 20 uzman" paketi incelendi; yalnızca tek skill (`hupo-deneme-uzmani`) kuruldu. 100 okul verisi, 19 skill ve şablonlar alınmadı: paketin kendi testi başarısız (20 skill, 17/42/45 bekliyor) ve kılavuz iddiaları doğrulanamadı (Beyoğlu PDF metni okunamadı, Adapazarı 2026 bulunamadı).
- **Test 1:** Haiku üretti (10 soru, 2 pasaj). Betik: dayanak 10/10, kanıt A 10/10 aşırı iddia 0, doğru şık en uzun 0/10, benzerlik 0. Kör çözüm (Sonnet): 10/10. Blueprint K4 kaydı eksik olduğu için "taslak" kaldı; skill doğru davrandı.
- **Test 2:** 4. sınıf okul grubu talebi BLOKE (K2, K3, K4); soru üretilmedi.
- **Düzeltmeler:** Betik, "ana cümle | süreç bileşenleri" biçimli kazanım dosyalarında yanlış alarm veriyordu; yalnız ana cümle karşılaştırılıyor. T6-TUR-005'in ikinci savunulabilir şıkkı (D) netçe yanlış yapıldı.
- **Kararlar:** Uygulama içi Deneme Sınavı resmî üründür; skill ona içerik/blueprint üretir. Genelge için hukuk görüşü gerekmez (kullanıcı kararı); skill'de "haberlere göre" etiketi kaldı.
- **Not:** Test pasajları kısa (~150 kelime), yayın için değil; gerçek deneme için 6. sınıf uzunluk bandı uygulanmalı.

## 2026-10-24 · 5. sınıf Türkçe 30 soru testi (skill vs skill'siz) · ONAYLI (kullanıcı talebi)
- **Kanıt:** Skill'siz kol 22 soruyu A işaretledi; kurala göre 4 aşırı iddia (T5-A-11, 12, 26, 27: söz sanatı/yorum/yazma). Skill kolu tablo kuralıyla 17 A, 13 B atadı; aşırı iddia 0.
- **Şık dengesi:** Skill'siz kolda doğru şık en uzun 19/30. Skill kolunun ilk taslağında 17/30 idi; kontrol betiği bunu yakaladı ve yanlış şıklar uzatılarak 0/30'a indirildi. Bu, yazım sonrası kontrolün gerekli olduğunu gösterir.
- **Cevap dağılımı:** Skill'siz kol A 3, B 20, C 7, D 0 verdi; ciddi konum yanlılığı. Skill kolu 8/7/8/7.
- **Kör çözüm (Haiku, anahtarsız):** İki kol da 30/30. 7. sınıf B-22'nin düzeltilmiş hâli de doğru çözüldü (D).
- **Kazanım kapsamı:** Skill 19/21, skill'siz 18/21. Kod metinleri resmî metinle eşleşti. Benzerlik 6-gram sıfır.
- **Öğrenilen:** Konum yanlılığı ve şık uzunluğu, kanıt kuralıyla aynı kontrol betiğinde izlenmeli. Tek bir taslağın kontrolü geçmesi yeterli değil; kontrol sonrası düzeltme adımı şart.
- **Not:** Test dosyaları (`scratchpad/test30`) geçicidir; sonuçlar yalnızca bu kayıtta tutulur.

## 2026-10-24 · 7. sınıf Türkçe 32 soru testi (skill vs skill'siz) · ONAYLI (kullanıcı kararı: kanıt kuralı düzeltmesi, skill güncellemesi, günlük)
- **Kanıt:** Skill kolu bütün 32 soruyu A işaretlemişti. Kural uygulandığında 21/32 A kaldı; 11 soru (tahmin, yorum, anahtar kelime, şiir biçimi, söz varlığı geliştirme, bütün T.Y.*) en fazla B. Skill'siz kol kendi beyanında 18 A / 13 B / 1 C verdi; kuralla 25/32 A, 1 aşırı iddia (T7-A-21, yazma sorusu). Dayanak: `scripts/soru_kontrol.mjs` çıktısı; girdi 8 pasaj, 22 kapsam kodu.
- **Şık dengesi:** Doğru şık en uzun: skill kolu 15/32, skill'siz kol 20/32. İki kol da kuralı ihlal ediyor; yazımdan sonra şık uzunluğu kontrolü zorunlu yapıldı (SKILL.md).
- **Kör çözüm (Haiku, anahtarsız):** İki kol da 31/32. Skill'siz kolda çözücü hatası (A-17). Skill kolunda B-22 (yazım sorusu): C şıkkında "Dersler bitince, yeniden gideceğim." virgül kusuru tartışma yarattı; C düzeltildi. Düzeltilmiş soru yeniden çözülmeli (bkz. aşağıdaki sonuç).
- **Kazanım kapsamı:** Skill 19/22, skill'siz 17/22. Her iki kolda kod metinleri resmî metinle eşleşti (script).
- **Benzerlik:** 6-gram en yüksek Jaccard 0 (60 mevcut 7. sınıf kaydıyla).
- **Öğrenilen:** Kanıt etiketi ajanın beyanıyla değil, tablo kuralıyla atanmalı. Yazma ve yorum soruları A değildir. Yazım sorusunda tek bir kusurlu çeldirici ikinci doğru cevap yaratır.
- **Not:** Test dosyaları (`scratchpad/test32`) geçicidir; sonuçlar yalnızca bu kayıtta tutulur.

## 2026-10-24 · 4. sınıf Sosyal Bilgiler 8 soru testi (skill vs skill'siz) · ONAYLI (kullanıcı kararı)
- Skill'siz kol 8 sorunun tamamına SB.4.x kodu ve "DÖP 2026-09-02" sürümü yazdı. Skill kolu kazanım kodunu boş bırakıp `source_pending` işaretledi.
- Kaynak: `curriculum_registry.json`: 4. sınıf GECIS_ONCEKI_PROGRAM, `do_not_assume_tymm_2026_applies: true`.
- **Sonuç:** Program yılı kuralı skill'in asıl katkısıdır; kalite kurallarında fark küçüktür.
- **Sorun:** Mevcut 4. sınıf Sosyal seti (`uretim_sosyal_4*.json`, ~28 soru) aynı SB.4.x kodu hatasını taşıyor. Bu kayıt 2026-10-24 kararıyla `source_pending` olarak işaretlendi.

## 2026-10-24 · 4 ve 8. sınıf kayıtlarının işaretlenmesi · ONAYLI (kullanıcı kararı)
- `docs/soru-uretim/pilot` ve `paket` altında 4 ve 8. sınıf soru kayıtlarına (373 kayıt) `curriculum_status: source_pending` ve `program_note` eklendi. Kazanım kodları silinmedi.
- Bu klasörler git'te izlenmiyor; önceki hâli geçici yedekte tutuldu.
- **Güncelleme:** K-0116'daki 8. sınıf 24 soru kullanıcı onayıyla DB'de `onaylandi` → `beklemede` yapıldı (K-0118). Doğrulandı: 8. sınıf beklemede 24, onaylandi 60. Kalan 60 kayıt (2026-10-07 seed) için karar bekleniyor.

## 2026-10-24 · pedagoji paketi entegrasyonu (HUPO_PEDAGOJI_1_8_SINIF_25_SKILL_V1) · ONAYLI (kullanıcı talebi)
- Paket `docs/pedagoji-paketi/` altına kopyalandı (46 dosya: docs, data, scripts, examples, 24 sınıf skill'i, kök belgeler). `references/` (büyük Hupo arşivi) kopyalanmadı; repodaki icerik ile aynı içeriktir. Mevcut dosyalara dokunulmadı; `CLAUDE.md` değiştirilmedi.
- Paket 24 sınıf skill'i ve ana orkestratör içerir; bu skill tek giriş noktası olarak onları yönlendirir.
- **Program yılı:** 2026–27: TYMM 1, 2, 3, 5, 6, 7; 4 ve 8 önceki program (`do_not_assume_tymm_2026_applies: true`). Bu oturumda 8. sınıf için TYMM kodlarıyla yapılan kazanım eşlemeleri 2026–27'de geçerli sayılmaz; A verilmez, `source_pending`.
- **Kanıt eşlemesi:** A = official_outcome_verified; B = thematic_candidate; source_pending = erişim yok ya da yıl uygulanmıyor; teacher_approved ayrı insan kaydı.
- **Kırmızı çizgiler:** 2026 MEB hikâye yarışması AI kullanımını yasaklar (HupoRead üretimi o yarışmaya sunulamaz). MEB ya da yayınevi sorusu metni, şıkları veya görseli çoğaltılmaz. 241 aday kavram zorunlu MEB listesi değildir. OYSS yetkili öğretmen uygulamasıdır; Hupo MEB havuzu diye sunamaz.
- **Kapılar:** draft → editorial_review → curriculum_verified → piloted → approved → published; varsayılan `published=false`.
- **Çelişki:** paketin "kazanım kodu yalnız gerçekten görülürse yazılır" kuralı ile bu skill'in önceki TYMM 8 eşlemesi çelişiyordu; paket kuralı geçerli kabul edildi.
- KARAR BEKLİYOR: `CLAUDE.md`'ye paketin "Hupo bölümü" eklenmesi (paketin kurulum talimatı gereği; ben dokunmadım). Ayrıca paketteki 2026 MEB hikâye yarışması kısıtı ile mevcut yarışma-benzeri hedeflerin uyumu.

## 2026-10-23 · 7. ve 8. sınıf hikâyeleri · ONAYLI
- Derleyici `-yla`/`-le` ad eklerini çözemiyor (Asya'yla, Umay'la). Kahraman veya yol arkadaşı belirteci kaldırılır ya da ek "ile" ile değiştirilir. Kanıt: K-0112, K-0114.
- Paragraf anahtarı başlıklara değil gövde paragrafına bağlanmalı; kahraman adı içermemeli. Kanıt: HR-099 derleme hatası (başlık), HR-102 (ad tokeni).
- Tema `arkadaslik` şemada geçersiz; `dayanisma` veya `kesif` kullanılır. Kanıt: K-0112.

## 2026-10-24 · sözlük denetimi · ONAYLI
- Sonnet ilk kararları (801 aday): 510 evet, 44 hayır, 247 düzelt. Düzeltmelerin 183'ü eş/zıt temizliğiydi; çoğu "ilişkili sözcük" bağıydı, gerçek eş/zıt değildi. Kanıt: `tasnif/karar-onerileri.md`.
- Ana aday metindeki biçimde olmalı ve silinemez (HR-023, HR-040, HR-043, HR-077, HR-086, HR-104 "lejand"). Kanıt: uygula.mjs çıktısı.
- Yeni 225 aday için iki ajan (A doğruluk, B uygunluk): 170 iki ajandan da geçti; 5 red; 50 beklemede. Kanıt: `sozluk-adaylari-inceleme.csv`.

## 2026-10-24 · kanıt düzeyi · ONAYLI
- Kanıt düzeyi A yalnızca soru bazında doğrulanmış kazanımla verilir: soru id + dayanak + kazanım kodu. Soru türü eşleşmesi A değildir.
- Metin okunmadan toplu A (5–8. sınıf ajan çıktıları) reddedildi; ajanlar yeniden çalıştırılacak.
- Resmî kaynak: TYMM Ortaokul Türkçe programı, 5–8. sınıf. 3–4. sınıf için resmî metin yok; C kalır.
- Doğrulanmış okuma kodları (8. sınıf): T.O.8.3, T.O.8.4, T.O.8.5, T.O.8.6. Kaynak: `docs/meb/ortaokul-turkce-tymm-program-metni.txt`.

## 2026-10-24 · ölçme ilkeleri · ONAYLI
- MEB ilkeleri: dil becerisi ölçmeleri öğrenci düzeyine uygun ve Türkçenin doğru kullanımını yansıtmalı; yönerge açık ve sade olmalı; geri bildirim betimleyici olmalı. Kaynak: programın ölçme ve değerlendirme ilkeleri (1.2.11, madde 2, 3, 6, 8).

## 2026-10-23/24 · soru yayını (K-0108, K-0110) · KARAR BEKLİYOR
- Yayında 1060 soru `onaylandi` (5. ve 7. sınıf Türkçe 58 yeni soru dahil). 17 bayraklı soru geri çekildi (`beklemede`); revize edildi ve kullanıcı kararıyla kabul edildi, veritabanına aktarım henüz yapılmadı (GÖR-055).
- Bayraklı sorulardan bir kısmı düşük örtüşmeli (jaccard ≤ 0,06) ve kullanıcı kararıyla yayında kaldı; bu tür kabul edilen riskler kayda yazılır.
- İnsan örneklemi (REHBER §15) yapılmadı; yayın kararı kullanıcıdadır.
- 5 ve 7. sınıf Türkçe kazanım metinleri "DÖP ile resmî teyit" maddesi K-0113'te kapatıldı; resmî kaynak artık `docs/meb/ortaokul-turkce-tymm-program-metni.txt`.
- ÖNERİ: Her soru için kazanım kodunun resmî metinden (T.O / DYS) doğrulanması kanıt düzeyi A ile aynı standartta tutulmalı.

## 2026-10-24 · soru hazırlamada model kullanımı (hedefli arama) · ÖNERİ + kanıt
Kaynak: `C:\Dev\Soru-Cevap Hazırlama Programı\veri\` (hakem.json, denetim/ai-oneri.json, zengin/varyant) ve `docs/soru-uretim/PLAN_V2.md`.
- İki hat var. (1) Soru-Cevap programı: üretim, zenginleştirme, hakem ve AI önerisi hepsi gemini-3.8-flash. (2) `docs/soru-uretim` paketleri: Sonnet yazar, Haiku kör çözüm, Sonnet kör kalite (PLAN_V2 madde 2, 5).
- Hakem puanları (88 kayıt, tek model): ortalama dil 4,98; seviye 4,99; tek doğru 4,98; çeldirici 4,92; ipucu güvenliği 4,65. Üreten ve puanlayan aynı aile olduğunda kusurlar kaçıyor.
- AI önerileri: 73 onaylanabilir, 16 düzeltilmeli. Düzeltme nedenlerinin büyük kısmı ipucunun cevabı açması; ikincisi kök ifadesinin şıkta aynen geçmesi; üçüncüsü metin dışı çeldirici ("B şıkkı metinde geçmez") ve yazım hatası ("ölçüve").
- ÖNERİ: §18 kuralları ve yukarıdaki üç kusur, Soru-Cevap hakem kalıbına kontrol listesi olarak eklensin; hakem modeli üretim modelinden farklı olsun.
- Kanıt: Sonnet yazar + Haiku çözüm + Sonnet kalite hattında kalite kayıtları ayrı paketlerde (`docs/soru-uretim/paket/*.json`, "kalite 'sari'" durumu). İnsan örneklemi (%10) hâlâ bekliyor.

## 2026-10-24 · diğer oturumlardan kullanıcı kararları (tarama) · KARAR BEKLİYOR / ONAYLI işaretli
Kaynak: `~/.claude/projects/c--Dev-hupo/*.jsonl` kullanıcı mesajları (anahtar kelime süzmesi). Ajan geri bildirimleri ve API anahtarları dahil edilmedi.
- **Token tasarrufu esastır; işleri zorluğa göre dağıt, uygun olanı Haiku'ya ver.** ONAYLI (kullanıcı, birçok oturum).
- **Denetim göz sayısı:** 4 göz yerine 3 göz: iki AI denetçi (A, B) + kullanıcı üçüncü göz. ONAYLI (kullanıcı).
- **Son insan okuması:** kullanıcı çocuk içeriğini kendisi okuyacak; AI "ön filtre" (pedagoji, MEB müfredatı, rehberlik, Türkçe uzmanı) önce çalışır. ONAYLI.
- **Yol arkadaşı hikâyeye işlenmeli;** yalnız adı geçen ama hikâyede rol almayan yol arkadaşı kabul edilmez. ONAYLI (kullanıcı).
- **Kahraman ve yol arkadaşı yer tutucuları:** kahraman `{kahraman}`, yol arkadaşı `{yoldas}` tokenı. ONAYLI.
- **Uzunluk:** tek başına red sebebi değil; soru ve cevap doğruysa kabul. Ancak şık dengesi (REHBER §18) ayrı bir yapısal kuraldır; "uzunluk = red" ile karıştırılmaz. ONAYLI (kullanıcı, 2026-10-24).
- **Benzerlik kontrolü yeni soru yazmadan önce** yapılır (kaynak parmak izi ve 6-gram). ONAYLI.
- **Zorluk 3 hedefi için uğraşılmaz;** vekil ölçüm kullanılır (kullanıcı kararı; ingilizce kazanım ölçeği yok). ONAYLI.
- **Sözcük veri tabanı:** MEB müfredatına göre; kazanım bilgisi ilişki tablosunda; örnek cümle ve hatırlatıcı veri tabanında (JSON'da kalmaz). ONAYLI.
- **Kelime Evreni amacı:** eş anlamlı, zıt anlamlı, eşsesli kelimeleri oyunla ve hafıza teknikleriyle 1–8. sınıfa öğretmek. ONAYLI.
- **Hikâye öğrenme hedefi:** deyim, atasözü, kelime türleri, okuduğunu anlama bağlam içinde öğretilir; hikâyeye uymayan atasözü eklenmez. ONAYLI.
- **Yayın eşiği:** kullanıcı "%90 ve üstü güvenli her şeyi yayına al" dedi; REHBER §15 ise insan örneklemi istiyor. Çelişki: KARAR BEKLİYOR.
- **Telif (ONAYLI, kullanıcı kararı):** kaynak soru yalnız blueprint olarak kullanılır; yeni kök, bağlam ve şıklar yazılır; isim/yer değiştirme tek başına dönüşüm değildir; benzerlik kontrolü geçmeyen soru kullanılmaz; kaynak lisansı kayda yazılır. Gerekçe: paketin "çok yakın parafraz yapma" kırmızı çizgisi.
- **Güvenlik:** birkaç oturumda API anahtarları açık metin olarak yazılmış. Bu skill'e alınmadı; anahtarların döndürülmesi kullanıcı kararıdır.

## 2026-10-24 · HR-110 · KARAR BEKLİYOR
- HR-110 metni yazar üretimi bir taslaktır; katalogda yalnızca özet vardı. Editöryel inceleme ve iki ajan denetimi bekliyor.

## 2026-10-24 · HR-015…032 uyumu · KARAR BEKLİYOR
- Uzak veritabanındaki elle yazılmış sürüm ile yerel paketler farklı. Kullanıcı kararı bekleniyor (yerel kaynak, uzak kaynak veya bekle).

## 2026-10-24 · ilk deneme sınavları (2.–4. sınıf) · KARAR BEKLİYOR
- Blueprint: `docs/deneme-sinavi/ilk-deneme-blueprint-2026-27.json` (yapı ve havuz sayımı; PDF içeriği kullanılmadı).
- Kapsam kapısı (K4) açık: hiçbir sınıf için öğretmen veya veli onaylı işlenmiş konu yok. Madde üretilmedi.
- Havuz (questions, onaylı, salt okunur): 2. sınıf TR 44 / MAT 42 / HB 48; 3. sınıf her ders 10; 4. sınıf TR 38 / MAT 38 / SOS 38 / FEN 35.
- Açık kararlar: işlenmiş konu tanımı; 1–4. sınıfta puan ve sıralama (sınav motoru sıralama üretiyor); süre; 4. sınıfta HB/SB uyumsuzluğu. Kayıt: PROJE_GUNLUGU K-0120.
- Uzak DB'ye yazılmadı; `published=false`.

## 2026-10-24 · 1–2. sınıf müfredat kaynağı · KARAR BEKLİYOR
- TYMM yıllık planlarından (taslak) hafta-konu-kod çıkarıldı: `docs/soru-uretim/mufredat/tymm-1-2-taslak-2026-27.json`.
- ODSGM 1. dönem dağılım tabloları yalnızca 5–8. sınıfları kapsıyor; 1–2. sınıf için yayımlanmış dağılım yok. Varsayım doğrulanmadı.
- Öneri ve açık kararlar: `docs/deneme-sinavi/1-2-sinif-dagilim-onerisi.md`. Kayıt: K-0127.
- Hata notu: önce "havuz yeterli" dedim; kapsam yanlış sınıfa baktı. Kapsam sınıfı, havuz sınıfı ile kontrol edilmeli.

## 2026-10-24 · HupoRead yeni kahraman paketi HR-121…132 · DOĞRULANMADI
- **Kanıt:** `icerik/okuma/hikaye/hr121…hr132-*.hikaye.md` (12 taslak, `published=false`); `scratchpad/kontrol.cjs` yerel kontrolü: 0 sorun. `PROJE_GUNLUGU.md` K-0134.
- **Öğrenilen (kontrol listesine göre):**
  1. Doğru şık en uzun olma sorunu 12 hikâyenin çoğunda vardı; çeldiriciler uzatılarak giderildi. Hiçbiri / İki model de tipi şıklar kaldırıldı.
  2. Yer tutucu hâli: `{kahraman}ın` gibi ekli kullanımlar `{kahraman:ilgi}` olmalı; soru kökünde ad yerine rol adı ("köprü mühendisinin") yazıldı.
  3. Hikâyeler kalıp tekrarı içeriyor: üç hikâye (HR-122/126/130) aynı olay örgüsünü izliyor. Bu, kontrol listesinde yoktu; kullanıcı kararı ONAYLI: hikâyeler olduğu gibi kalır, yeniden kurgu yapılmaz. Bu bir kontrol listesi maddesine dönüşmedi.
  4. Derleyici repoda bulunamadı (`tolye/` yok); anotasyon/sözlük/paket katmanı bu iş kapsamında üretilmedi.
- **Açık:** TDK sözlük doğrulaması yapılmadı; kazanım kodu `source_pending`; insan onayı yok.

## 2026-10-25 · 1. sınıf soru bankası: bağlamsız kökler · KISMEN DOĞRULANDI (B1 bölümü)
- **Tetikleyici:** kullanıcı panelde "Ali'nin geriye kaç bilyesi kaldı?", "Bu modele göre hangi cümle doğrudur?" gibi sorular gördü; durum bilgisi yoktu.
- **Kök neden:** paket şemasında bağlam alanı yok; üretici durum bilgisini `dayanak` ve `cozum_adimlari` içine yazdı, panel yalnız `soru_metni` gösteriyor. Hiçbir kapı bunu yakalamadı (kapi.cjs ve soru_kontrol.mjs dayanağın kökte bulunmasına bakmıyordu).
- **Kanıt:** 661 soruluk tarama + 65 adayın elle okunması: kesin bağlamsız 22 soru, hepsi 1. sınıf (tr1-21..24, mat1-01..07/09..11/13/14, hb1-05/06/08/09/10); ayrıca hb1-* ipuçları ve çözümleri kökte olmayan "pasaj"a gönderme yapıyordu. Düzeltme: `docs/soru-uretim/paket/soru_paketi_1sinif*_2026-10-24.json` (26 kök yeniden yazıldı); doğrulama betiği: dayanak kökte, şıkta kök cümlesi yok, doğru şık tek en uzun değil → 0 sorun. Veri tabanına yazılmadı.
- **Öğrenilen (kurallar SKILL "Önce kontrol et" 14–18, REHBER §18.10, kapi.cjs `baglam_kokte_yok`):**
  1. Öğrenci yalnız kök + şıkları görür; durum bilgisi başka alanda ise soru yazılmamıştır.
  2. "Yukarıdaki/Bu modele/Aynı kuralla" göndermesinin hedefi kökte olmalı.
  3. Görselsiz soruda kart, kavanoz, tablo gibi öğeler metinle anlatılır.
  4. İpucu ve çözüm "pasaj"dan söz ediyorsa kökte pasaj olmalı; yoksa üretici pasajı kafasında kurup yazmamıştır.
  5. Yazım sorusunda cümle tek kusur taşır (tr1-21: noktasız cümle iki doğru cevap doğururdu).
  6. Kör çözüm ("48/48 uyuştu") bu hatayı yakalamadı çünkü çözücüye anahtarla birlikte dayanak da verilmiş olabilir; kör çözüm yalnız öğrencinin göreceği alanlarla (kök + şıklar) yapılmalı. **ÖNERİ**, doğrulanmadı.
- **Açık:** B2–B5 bölümlerinde yalnız bağlam taraması yapıldı; kapı çalıştırmaları, kör çözüm ve stil geçişi yapılmadı. `docs/soru-uretim/paket/` git'te izlenmiyor (untracked).

## 2026-10-25 · B2: 2. sınıf (104 soru) kalite geçişi · KISMEN DOĞRULANDI
- **Kanıt:** `kapi.cjs` (uyarlayıcıyla): 104 KONTROL, 0 RED; yalnız 2 uzunluk uyarısı (mat2-034, tr2-058, ikisi de zararsız). Elle okuma: 35 matematik sorusunun hepsi elle çözüldü, anahtarlar tuttu; Türkçe ve Hayat Bilgisi kökleri bağlamı kendi içinde taşıyor. Betik taraması: ipucu doğru şıkkı açmıyor, "pasaj"a boş gönderme yok, yanlış şık geri bildirimleri eksiksiz. Doğru şık harfi dağılımı A30 B28 D24 C22 (en çok %29).
- **Düzeltme:** yok. Küçük not: mat2-009'daki "25 lira" çeldiricisi gerçekçi değil (değiştirilmedi).
- **Yapılmadı:** farklı model ailesiyle kör çözüm; 2. sınıfın kazanım kodlarının resmî metinle karşılaştırılması; paketin `dayanak` alanı yok, bu yüzden `baglam_kokte_yok` kapısı bu pakette devre dışı (kök sağlığı elle okunarak denetlendi).
- **Öğrenilen:** `kapi.cjs` paket şemasıyla doğrudan çalışmıyor (id/soru_tipi/celdirici_gerekce adları farklı); her bölümde uyarlayıcı gerekiyor. Dayanak alanı olmayan paketlerde bağlam kontrolü elle okuma ister. **ÖNERİ:** kapıya paket şemasını (soru_id, yanlis_sik_geri_bildirimi) doğrudan tanıyan mod eklensin.

## 2026-10-25 · B3a: 4. sınıf (109 soru, paket 2026-10-21) · KISMEN DOĞRULANDI
- **Kanıt:** `kapi.cjs` (uyarlayıcıyla) tüm B3 paketi (314): 0 RED, 78 uzunluk uyarısı (doğru şık en uzun 53 = %17, şans düzeyi %25'in altında; sistematik şık ipucu yok). 4. sınıfın 109 sorusu tamamen elle okundu: 28 matematik sorusunun hepsi elle çözüldü, anahtarlar tuttu; Türkçe, Fen, Sosyal kökleri bağlamı içinde taşıyor; dilbilgisi ve yazım soruları doğru şıkkı tek.
- **Düzeltme:** yok. **Not:** 4. sınıf 2026–27'de önceki programdır; kazanım kodları `source_pending` kalır (bu turda kod değiştirilmedi).
- **Yapılmadı:** farklı model ailesiyle kör çözüm; Fen/Sosyal olgularının dış kaynakla doğrulanması (yalnız genel bilgiyle okundu).

## 2026-10-25 · B3 tamamı: paket 2026-10-21 (4., 5., 6. sınıf; 314 soru) · KISMEN DOĞRULANDI
- **Kanıt:** `kapi.cjs` 314 KONTROL, 0 RED. Betik taraması (5–6. sınıf 205 soru): kökte olmayan "pasaj/yukarıdaki" göndermesi yok, ipucu doğru şıkkı açmıyor, doğru harf dağılımı dengeli (A53 B56 C49 D47). Elle okuma: 4. sınıf 109 soru tamamen; 5–6. sınıfta 66 matematik sorusunun hepsi elle çözüldü (anahtarlar tuttu); Fen ve Sosyal 139 sorunun kök sonu ve doğru şıkkı okundu, sayısal olan 4 soru (sos5-027, sos5-e-019, sos6-026, fen5-024) tam metinle çözüldü, tuttu. Yeni bağlam kapısı bu pakette de devre dışı (pakette `dayanak` yok).
- **Düzeltme:** yok. **Küçük not:** sos5-e-016 "Tabloda üç katkıyı yazdı" bu üç katkıyı saymıyor; elemeyle çözülebilir, değiştirilmedi.
- **Yapılmadı:** kör çözüm (farklı model); Fen/Sosyal olguları dış kaynakla doğrulanmadı; Fen/Sosyal çeldiricileri tek tek okunmadı (yalnız soru kökü ve doğru şık), bu yüzden "ikinci doğru şık" riski bu iki derste tam elenmiş sayılmaz.
- **Öğrenilen (işlem):** `yanlis_sik_geri_bildirimi` bu pakette doğru şıkkı da açıklıyor; kapıya "doğru şıkta geri bildirim yok" kontrolü koymayın, tasarım gereği. Betik çıktısını her zaman sayıya indir (200+ satırlık döküm token israfı oldu).

## 2026-10-25 · B3 kapanış: kör çözüm (Gemini) + Fen/Sosyal çeldirici okuma + olgu kontrolü · KISMEN DOĞRULANDI
- **Kanıt:** Gemini (`gemini-3.8-flash`, yalnız kök + şıklar, anahtarsız, temperature 0) 314 sorunun 314'ünü anahtarla aynı çözdü; "ikinci doğru olabilir" ve "olgu hatası" işareti 0. Çözücü çalışıyor mu kontrolü: bilerek yanlış anahtar verilen 3 soruyu ve bir çift şıkkı yakaladı (4/4). Fen ve Sosyal'in 192 sorusunun tüm şıkları tek tek okundu (4: Fen 25, Sos 28; 5: Fen 35, Sos 38; 6: Fen 36, Sos 30); 2 hesap sorusu elle yeniden çözüldü. Dış kaynak: Tekalif-i Milliye (7–8 Ağustos 1921) ve TÜRKSOY kültür başkenti uygulaması doğrulandı.
- **Bulgu (düzeltilmedi, karar sende):** (1) sos5-e-015 "yaklaşık 11 bin yıl" yazıyor; bulunan kaynaklar Göbeklitepe için ~12 bin yıl veriyor, cevap değişmez. (2) bos6-006: ergenlikte ortak değişim sorusunda B "sesin belirgin kalınlaşması"; bulunan okul materyalleri ses kalınlaşmasını erkeğe özgü sayıyor, cevap A kalır, ama MEB ders kitabı metniyle karşılaştırılmadı. (3) fen4-012 A şıkkı ("kabın her yerine yayılıp doldurur") gaz tanımı; yanlış ama ince.
- **Hâlâ yapılmadı:** TÜRKSOY merkezinin Ankara olması bulunan kaynaklarda teyit edilmedi (bilgi sorunun içinde, cevabı etkilemiyor). Kazanım kodları resmî metinle karşılaştırılmadı. Gemini ve Claude aynı olguyu aynı yanlış bilebilir; "ikinci doğru yok" kanıtı bu yüzden tam değil.
- **Öğrenilen:** kör çözüm betiğine her çalıştırmada bozuk anahtarlı kontrol soruları katılmalı; "0 uyuşmazlık" tek başına kanıt değil.

## 2026-10-25 · B4: 5., 7., 8. sınıf Türkçe (83 soru) · KISMEN DOĞRULANDI
- **Kanıt:** paket dosyalarında 83 soru var (5: 29, 7: 30, 8: 24); plandaki "71" sayısı yanlıştı. Gemini kör çözümü 83/83 uyuştu, 1 olgu işareti (tr8-012). 83 sorunun pasajı, kökü ve şıkları tek tek okundu: cevap anahtarları tuttu; şiir sorularında dize/kıta/uyak elle sayıldı (tr5-011, tr7-012, tr8-009); tr5-026'daki "Türk Dil Kurumu'ndan" şıkkı TDK kuralına göre (kurum adına gelen ek kesmesiz) gerçekten yanlış, B doğru.
- **Bulgu:** tr8-012 B "Ayşe de geldi, ama erken gitti.": TDK, "ama/fakat" önüne noktalı virgülü "konabilir" diyerek önerir, virgül yaygın kullanımdır. Diğer üç şık kesin yanlış olduğundan tek doğru yine B, ama soru "noktalama kurallarına uygun" dediği için katı bir okurda tartışma çıkar. **ÖNERİ:** virgülü noktalı virgül yap veya noktalamayı sorudan çıkar. Ayrıca doğru şık tek en uzun olan 30/83 (%36; şans %25): tr8 ve tr7 sınıflandırma/ikna sorularında belirgin.
- **Gözlem:** 8. sınıf 24 sorunun çoğu 5. sınıf düzeyinde (tr8-009 dize say, tr8-010 kişileştirme, tr8-024 bağlaç). LGS hazırlığı için zorluk uygun değil; 8. sınıf zaten önceki programda.
- **Yapılmadı:** kazanım kodları resmî metinle karşılaştırılmadı; paketler panele/DB'ye aktarılmadı.
## 2026-10-25 · B5 (tr6 + revizyon + düzeltme, 114 soru) ve kazanım kodu karşılaştırması (B1–B5, 661 soru) · KISMEN DOĞRULANDI
- **Sayı:** B5 paketlerinde 114 kayıt var (91 + 17 + 6), plandaki "156" yanlıştı; 12 kimlik birden çok sürümde (tr6-o-002, o-012, o-017, o-018, o-019, y-011, y-012, y-015, y-017, y-e02, dk-030, e15-001): en yeni sürüm revizyon/düzeltme dosyalarında. Gemini kör çözümü 114/114 uyuştu; 2 "ikinci doğru olabilir" işareti (tr6-dk-013 örnekleme/karşılaştırma, tr6-o-017 düzeltme sürümü tanık gösterme/karşılaştırma) elle okundu, doğru şık yine tek; tr6-o-017'de metin örtük bir karşılaştırma da içeriyor, düşük risk.
- **Kazanım kodu, resmî metinle (tymm 2026-09-02 PDF'leri ve MEB DÖP PDF'leri indirilip metin katmanı çıkarıldı):** 661 sorunun 634'ünde kod + ana cümle PDF'te birebir. 27 sapma: 2'si (mat4-012, mat4-020) PDF'teki yumuşak tire kaynaklı yanlış alarm; 25'i tr6 paketinde `kazanim_metni` alanının bozuk/eski olması (başka kodun bileşenleri karışmış). Kodlar PDF'te var. PDF düzeni: öğrenme çıktısı başlığı kendi kod satırından ÖNCE gelir; T.Y.6.12–6.14 ve T.D.6.18–6.20 elle teyit edildi, `kazanim_6_turkce.json` ile tutuyor.
- **Kod-içerik uyumsuzluğu (en güncel sürümlerde, 13 soru, %2):** tr6-dk-004 (T.D.6.6 yerine 6.5: açık bilgi), tr6-dk-015 (T.D.6.17: ikna tekniği, söz varlığı değil), tr6-dk-018 (T.D.6.23: eleştiri, 6.21), tr6-dk-032 (T.K.6.18: eleştiri, 6.17), tr6-dk-033 (T.K.6.20: düşünceyi geliştirme, 6.19), tr6-dk-035 (T.K.6.22: ikna, bağlantı ifadesi değil), tr6-o-019 düzeltme sürümü (T.O.6.9: çözüm üretme, 6.24), tr6-y-017 düzeltme sürümü (T.Y.6.14: geri bildirimle yazma sürecini değerlendirme, 6.19; K-0115'in düzeltmesi resmî tabloya göre yanlış çıkıyor), tr4-016 (T.Y.4.2) ve tr4-030 (T.K.4.2): okuma/söz varlığı soruları yazma/konuşma koduyla, sos4-e1-01 (SB.4.1.3: harita lejantı), sos4-e1-06 (SB.4.6.2: rol/sorumluluk), mat6-016 (MAT.6.3.2: eşkenar dörtgen, 6.3.3/6.3.4'e yakın). Hiçbiri düzeltilmedi; DB'deki durum sorgulanmadı.
- **Gözlem:** Gemini'ye göre 167 soru "kısmen" uyumlu; çoğu Fen kodlarının süreç becerisi (hipotez kurma, model oluşturma) olması, soruların bilgi düzeyinde kalması. tr6'da 37 dinleme/konuşma sorusu var; 5, 7, 8. sınıf ve 2. sınıf için T.D/T.K "kapsam dışı" kararı verilmişti. 6. sınıf için tutarsız, karar gerek.
- **Düzeltilen:** `soru_paketi_tr6_2026-10-21.json` içindeki 39 bozuk kapanış tırnağı (`â€` + gizli karakter, kapanış `”` olmalıydı) paket dosyasında düzeltildi. Aynı bozukluk `pilot/uretim_turkce_6_*.json` kaynak dosyalarında duruyor; canlı DB'de bu sorular için kontrol yapılmadı. tr8-012 A/B şıklarından "ama" cümleciği çıkarıldı ("Ayşe de bizimle sinemaya geldi." / "Ayşe’de bizimle sinemaya geldi."), doğru şık B.
- **Öğrenilen:** paketteki `kazanim_metni` alanına güvenme, kodu resmî PDF'e karşı doğrula; tr6 paketinin `kazanim_metni` alanı 25 kayıtta bozuk. Aynı kimlikli sürümler tek dosyada birleştirilmeden denetlenirse eski sürüm yanıltır (revizyon önceliği).
## 2026-10-25 · Kod düzeltmesi, bozuk tırnak ve kapsam kararı (canlı DB) · TAMAMLANDI (uygulandı, doğrulandı)
- **Kod düzeltmesi (8 satır, canlı DB + paket):** tr6-dk-004 T.D.6.6→T.D.6.5; tr6-dk-018 T.D.6.23→T.D.6.21; tr6-dk-032 T.K.6.18→T.K.6.17; tr6-dk-033 T.K.6.20→T.K.6.19; tr6-o-019 T.O.6.9→T.O.6.24; tr6-y-017 T.Y.6.14→T.Y.6.19; mat6-016 MAT.6.3.2→MAT.6.3.3; sos4-e1-01 SB.4.1.3→SB.4.2.1 (resmî PDF'te "Konum ve yön bulmada haritaları okuyabilme"). Her satır eski kodu doğrulayarak güncellendi (8/8).
- **Uygulanmayanlar (5, kararın sende):** tr6-dk-015 ve tr6-dk-035 (ikna teknikleri): resmî PDF'te ikna kazanımları 7–8. sınıfta; 6. sınıfta karşılığı yok. tr6-dk-015 kodu T.D.6.17 olarak kalıyor (kazanım metni ile soru uyuşmuyor). tr4-016 ve tr4-030: canlı DB'de zaten eski program kodları (T.4.3.12, T.4.3.11) var ve içerikle uyuşuyor; dosyadaki 2026 kodları (T.Y.4.2, T.K.4.2) yanlış. Dosya değiştirilmedi. sos4-e1-06 (tiyatro kulübü sorumluluğu): 2026 4. sınıf programında uygun kod bulunamadı; SB.4.6.2 (bilim insanları) yanlış, karar bekliyor.
- **Bozuk tırnak (canlı DB):** 27 soru_metni, 2 cozum_adimlari, 1 ipuclari; hepsi “â€” + U+009D” kalıbı; ” ile değiştirildi. Doğrulama: kalan 0.
- **Kapsam dışı (canlı DB):** 6. sınıf Türkçe T.D/T.K sorularının 45'i onaylandi → beklemede (silinmedi). Geri almak için aynı filtreyle onaylandi. Kullanıcı: "şimdilik kapsam dışı, gelecek sürümlere eklemek istiyor".
- **Paket dosyaları:** soru_paketi_2026-10-21.json (2), soru_paketi_tr6_2026-10-21.json (4), soru_paketi_tr6_duzeltme_2026-10-24.json (2) güncellendi.
- **Web panel (ayrı iş):** sorular ekranına "Filtredekileri onayla (N)" eklendi: yalnız durum filtresi Beklemede iken etkin; filtredeki tüm bekleyen sorular sayfa sayfa toplanıp 500'lük parçalarla admin_set_question_status ile onaylanır; onay penceresi sayı gösterir. tsc temiz. Dağıtım (Vercel) yapılmadı; tarayıcıda canlı deneme yapılmadı.
## 2026-10-25 · Kalan 5 kod kararı (ajan kararı, kullanıcı "karar ver" dedi) · UYGULANDI
- **tr6-dk-015, tr6-dk-035 (ikna):** ikna kazanımı resmî programda yalnız 7–8. sınıfta; 6. sınıfta yok. Yanlış kod bırakmak yerine kazanim_kodu/metni boşaltıldı (canlı DB + paket); sorular beklemede, kazanımsız listesine düşer. Gelecek sürümde 7. sınıf ikna kazanımıyla (T.D.7.17 / T.K.7.x) sınıf değiştirilerek yeniden kullanılabilir.
- **tr4-016, tr4-030:** canlı DB'deki eski program kodları (T.4.3.12, T.4.3.11) içerikle uyuşuyor; DB değişmedi. Paket dosyası DB'ye eşitlendi (T.Y.4.2/T.K.4.2 yanlıştı).
- **sos4-e1-06:** SB.4.1.3 ("Toplumsal birliği sürdürmeye yönelik fikir üretebilme"; öğretme notları toplumdaki roller ve rollere ilişkin sorumluluklar) atandı. Aynı kodlu sos4-e1-04 ve sos4-s-003 satırlarının bozuk kazanım metni (başka kazanımların bileşenleri karışmıştı) PDF'teki a–c bileşenleriyle değiştirildi. Canlı DB 3 satır.
## 2026-11-10 · Hikâye ve sözlük yazım taraması · DOSYALARDA UYGULANDI, DB'ye gitmedi
- **Kapsam:** icerik/okuma/{hikaye 104, sozluk 92, paket 94, anotasyon 92} düzyazı alanları + docs/okuma-entegrasyon/paket-2026-11-10 + Kelime Evreni/Okuma migration dizgileri (salt okuma).
- **Yöntem:** (1) ASCII'ye düşmüş sözcük: diyakritikli ikizi derlemde bulunan ASCII sözcükler (dogru/doğru türü), (2) kök eşleştirme, (3) ünlü uyumu ihlali, (4) sık yanlış yazım listesi, (5) mojibake. Sonuç: ASCII'ye düşmüş gerçek hata yok; kalan adaylar kimlik/slug/geçerli sözcük.
- **Düzeltilen (91 satır, 57 dosya):** sıfat -î (tarihî yapı/sokak/bilim merkezi, resmî belge/plan/rota/güvenlik/tahmin, hayalî kanıt/senaryo, temsilî kart/çizim, tahminî süre/konum/varış/yer/zaman/bağlantı/olarak), tezgâh, kâse (hr066), hâle gel/get/ol, hâlde, hâlinde.
- **Kural:** aynı yüzey biçimi ad hâlinde değişmez ("resmi çizdi", "tarihi yazdı", "tahmini not etti" doğru). Sıfat mı ad mı bağlamla belirlenir; otomatik toplu değişim yapılmaz.
- **Dokunulmadı:** icerik/okuma/kaynak/*.md (kaynak metin kuralı). Uzak DB eski metinde kalır; migration ile eşitleme ayrıca onay ister.

## 2026-11-10 · Okuma paketleri: kardes / baska_biri izinli tür ekleme (etiket denetimi) · DOSYALARDA UYGULANDI, DB'ye gitmedi
- **Kapsam:** icerik/okuma/paket 77 paket. kardes +74, baska_biri +72 (kardes 3 ve baska_biri 5 hikâyede zaten vardı). hr027, kahraman adı sabit 16 hikâye ve kahramansız hr025 dokunulmadı. anne / baba eklenmedi.
- **Kanıt:** etiket denetimi raporu Tablo 1 hedef planı; yalnız izinli_turler dizisi metin düzeyinde değişti (girinti, satır sonu ve BOM korundu). Doğrulama: 77 dosya dışındaki paket aynı; tekrar yok; supabase/tests/okuma_dunyasi/kos.mjs (OKUMA_PAKET_DIZINI ile 94 paket + kayip-defter fixture) 189/189 ve export 7/7.
- **Migrasyon:** supabase/migrations/20261213000000_okuma_izinli_tur_guncelle.sql hazır, uygulanmadı. Yerel PGlite'ta 77/77 yeni TASLAK sürüm yazıldı, en yeni sürümlerde kardes/baska_biri tutarlı. 20261212 dosyası zaten vardığı için 20261213 kullanıldı.
- **Açık karar:** 18 paketin (hr040, hr042, hr066, hr074, hr079, hr082, hr086, hr088, hr091, hr099, hr102–105, hr111–114) çalışma ağacında commit'lenmemiş, izinli dışı farkları var; migrasyon bunları da taslak sürüme alır. Uygulamadan önce içerikleri onaylanmalı.
- **Hikâye .md front matter:** izinli_turler alanı değiştirilmedi. 69 dosya eski paket listesiyle aynı; 6 dosya (hr026, hr028–hr032) önceden sapmıştı. Paket ile .md eşitlenmesi ayrı karar.

## 2026-11-10 · HR-141–166 editöryel düzeltme (başlık, doğru şık, dayanak ölçümü) · DOSYALARDA UYGULANDI, COMMIT EDİLDİ
- **Başlık:** HR-157 başlığındaki "Sessiz" kaldırıldı ("Bulutların Altındaki Uçuş"). Dosya adı ve slug korundu; yeniden adlandırma uzak referansları kırabilir.
- **Doğru şık:** 104 soruda doğru şık en uzun değil (karakter ölçümü; önceki 53/56 sorunun çeldirici uzatmasıyla düzeltildiği doğrulandı). Ölçüm scratchpad betiğiyle yapıldı.
- **Dayanak:** 104/104 birebir (soru_kontrol.mjs). Hepsi/hiçbiri ve olumsuz kök yok.
- **Kelime:** 250–667. Pilot bant (3:330 … 7:950) altında; commit edilmiş HR-121–126 (191–346) ile aynı aralıkta. Bant kararı kullanıcıda.
- **Kanıt:** kazanım kodu yok; C ve source_pending. soru_kontrol kapsam sonucu bu yüzden anlamsız ("kod kapsamda yok"). Ajan A/B pending.
- **Öğrenilen:** kazanım kodu olmayan hikâyede soru_kontrol kapsam satırını boş üretir; hikâye için dayanak birebirliği ve doğru şık uzunluğu asıl kontroldür.
- **Açık (insan editörü):** TDK onayı yok (pervane, hatıra); HR-160 s2/s4 dayanakları zayıf; HR-153 s3 ve HR-159 çeldiricileri yapay; HR-144 güneşte kurutma ve HR-145 gönüllü ayrıntıları onay bekliyor. Uzak DB ve paket dönüşümü onay bekliyor.

## 2026-11-11 · HR-141–166 paket dönüşümü ve yerel doğrulama · YEREL TAMAM, UZAK DB BEKLİYOR
- **Kapsam:** 26 hikâye (anne 141–146, baba 147–152, araç 153–158, hayvan 159–166); commit 5051ef3.
- **Öğrenilen:** derleyici hikâye .md'sinden önce ön yüz şemasını ister (okuma_bandi, dunya_tipi, izinli_turler, etiketler.ogrenme_hedefleri); ChatGPT çıktısı doğrudan .hikaye.md olduğunda donustur.mjs uret kullanılmaz, derle + sözlük yeter. Yol arkadaşı kuralı (en az 2 yer) anonim bir kişiye ad verilerek, olay örgüsü değiştirilmeden karşılanabiliyor.
- **Kanıt:** derle 26/26 hatasız (sözlük ile); paket 26 üretildi. Migrasyon PGlite zincirinde (20261214) hatasız uygulandı: 26 hikâye, 26 taslak sürüm, 104 hedef bağlantısı. Denetim aracı (tools/okuma-hikaye-denetim.mjs): sorusuz 0, karşılıksız ad 0, tekrar 0.
- **Açık:** uzak DB'de 20261213 (önceki oturum) ile birlikte bekliyor; sözlük adayları TDK onayı; yol arkadaşı editör okuması; kazanım kodu yok (C, source_pending).

## 2026-11-12 | 3-7 | Landing demo soruları (25) bağımsız denetim | ÖNERİ
- Öğrenilen: Kör çözümde 25/25 soru anahtarla uyuştu (şekilli 10 soruda veri DemoFigure çizim koduna göre okundu). Bulgular: D4-04 doğru şık belirgin en uzundu (çeldiriciler uzatıldı); D6-04 "temiz kan" terimi eskimiş/yanıltıcı (akciğer atardamarı) -> "kalpten uzaklaştırıp organlara taşıyan" diye yeniden yazıldı; D4-04 çözüm adımında "piline" ek hatası ve alt metin düzeltildi; D3-05 son adım netleştirildi.
- Kanıt: web-panel/src/components/demo/demoQuestions.ts; kazanım kodu yok (kaynak teyidi yok); tsc --noEmit temiz. Denetçi Sonnet ailesi; insan örneklemesi hâlâ gerekir.
