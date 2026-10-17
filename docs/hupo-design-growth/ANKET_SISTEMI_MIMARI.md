# Anket sistemi: mimari ve yönetim tasarımı

Tarih: 2026-10-16 (karar güncellemesi aynı gün)
Kapsam: 8–14 yaş, tüm veli hesapları (kayıt sonrası ve mevcut üyeler). Soru içeriği `ONBOARDING_ANKETI_ON_ARASTIRMA.md` içinde.
Durum: **Kararlar verildi (§1). Kod yazılmadı, uzak veritabanına dokunulmadı.** Kalan küçük açık noktalar §12'de.
Yazılı için: geliştirici ve yönetim paneli sorumlusu.

## 1. Kararlar

| Konu | Karar | Uygulama notu |
|---|---|---|
| **Anket silinmez** | **Hiçbir anket kaybolmaz; arşive alınır.** Yeni bir anket yayınlanınca önceki yayındaki anket otomatik kapatılıp arşive alınır (yayın ekranında onay kutusu, varsayılan işaretli) | Anket silme yolu yok (bugün de yok, PROJE_GUNLUGU §17). Ek olarak `anket_yanitlari.anket_id` bugün `on delete cascade`; arşiv sorununu önlemek için `restrict` yapılır (D1) |
| Etkileşim bütçesi | **24 saatte en fazla 1 kart** (anket, push ön izni ve benzeri ortak) | `etkilesim_butcesi` tek tablo; PROJE_GUNLUGU §23 ile birleşir |
| Atlama takvimi | **3 gün → 14 gün → 90 gün** (kademeli soğuma) | 1. atlama 3 gün, 2. atlama 14 gün, 3. ve sonraki her atlama 90 gün. Sayaç sıfırlanmaz (§12-1) |
| Web sitesi yüzeyi | **Anket yüzeyi olarak kaldırılır** | Yalnız anketler için. Duyuru şeridi `web_sitesi` yüzeyini kullanmaya devam eder (PROJE_GUNLUGU §15). Ziyaretçiye yönelik hafif widget ayrı tasarımdır (§12-4) |
| Yanıt birimi | **Hibrit, soru bazında:** çocuk başına sorular (ör. "Çocuğunuz matematikte nerede zorlanıyor?") her çocuk için; veli başına sorular (ör. "Ders çalıştırırken siz ne kadar zorlanıyorsunuz?", "Hangi saatlerde evde oluyorsunuz?") bir kez | Her soru `kapsam` alanı taşır: `cocuk` veya `veli`. Veli kapsamlı soru zaten yanıtlanmışsa ikinci çocukta atlanır |
| Soru tavanı | **Hedef 7, sert tavan 7** | Yayın engeli: 7'den fazla soru kaydedilemez. İlerleme çubuğu: "Soru 2/7" |
| Sessiz saat | **22:00–08:00, cihazın yerel saati.** Bu saatlerde anket kartı ve pazarlama/bilgilendirme push'u gönderilmez | İşlemsel bildirimler (ödeme, hesap güvenliği) kapsam dışı. Kapsam ve işlemsel liste hukuk ve ürün onayı bekler (§12-A). Mevcut push sessiz saati 20:00 ile başlıyor; D2'de 22:00'e çekilir |
| Saklama | **Ham yanıt 24 ay → anonimleştirilir** (kimlik alanları silinir, yalnız toplu istatistik kalır). Gösterim olayları 180 gün. Taslaklar 30 gün | Anonimleştirme görevi (cron) D1'de. Hukuk onayı gerekir |
| Fayda | Gönderimden sonra **2–3 maddelik kural tabanlı öneri** (en fazla 3) | Garanti dili yok |
| Oyun ekranı | Anket **hiçbir zaman** çocuğun öğrenme ekranında çıkmaz, yalnız veli alanında | Mevcut karar, onaylandı |

## 2. Mevcut durum: ne var, ne eksik

**Var ve kalır:**
- `anketler`, `anket_yanitlari`, `anket_katilimlari`; sorular `jsonb`, `surum`, koşullu soru (`kosul`), anonimlik, `tekrar_gosterim_gun`, arşiv kolonu `arsivlendi_at` (`20261032000000`).
- Yüzeyler: `mobil`, `web_app`, `web_sitesi`, `veli_paneli` (`20261029000000`). Anket için `web_sitesi` çıkar, duyuru için kalır.
- Yanıt doğrulaması hem sunucuda (`anket_yanit_gonder`) hem istemcide (`survey_models.dart`, `anketMantik.ts`).
- Mobil kart (`SurveyPromptCard`, `SurveySheet`) ve web kart (`AnketIstemi`). Web kartı otomatik açmıyor.
- Yönetim: `SurveysManager.tsx` içinde önizleme, koşul, yüzey seçimi, arşiv (Aktif / Arşiv sekmeleri, silme yok).
- Çocuk rızası için `consents` tablosu (`20260920000800`).

**Eksik:**

| # | Eksik | Sonuç |
|---|---|---|
| E1 | Hedef yalnızca `veli` (CHECK), katılım `(anket_id, veli_id)` | Çocuk başına soru ve yanıt yok |
| E2 | Sürüm anlık görüntüsü yok; yayındayken sorular değişince yalnızca `surum` artıyor | Eski soru metni kaybolur |
| E3 | Admin yayındaki sorunun `id`'sini değiştirebiliyor | Analiz sütunları kopar |
| E4 | Gösterim, atlama, kapatma olayı kaydedilmiyor | Yanıt oranı ve "sıkma" ölçülemez |
| E5 | Global frekans sınırı yok; "Şimdi değil" mobilde ve webde yalnız tarayıcıda | Aynı veli birden çok istek görür |
| E6 | Tetikleyici yok | Değer görmeden kart çıkar |
| E7 | Taslak, önizleme yok; yayınla anında canlıya yazar | Hatalı soru canlıda kalır |
| E8 | Öneri kuralı ve çocuk profili yok | Veli karşılığını görmez |
| E9 | Çocuk verisi için yeni amaç rıza türü yok | Çocuk kapsamlı anket dayanaksız |
| E10 | `web_sitesi` anket yüzeyi: ziyaretçi oturumu olmadığı için kart çizilmiyor | Yüzey fiilen işlevsiz (§1 kaldırma kararı) |
| E11 | Kart `veli-paneli/layout.tsx` içinde, her sayfada çıkıyor | Sıklık kontrolsüz |
| E12 | Arşiv kuralı: yayındaki anket arşivlenemez; yenisi yayınlanınca otomatik arşiv yok | Yeni karar için kural değişmeli |
| E13 | `anket_yanitlari.anket_id` `on delete cascade` | Anket silinirse yanıtlar da gider; arşiv güvencesi zayıf |
| E14 | Tek aktif anket kuralı yok | Birden çok anket aynı anda yayında olabilir |

## 3. Hedef mimari

```
Veli istemcisi (mobil / web_app / veli paneli ana sayfası)
  │  1. anket_siradaki_kart(p_yuzey)
  │       → en fazla 1 kart; bütçe, sessiz saat, tetikleyici, çocuk ve rıza kontrolü
  │  2. Çocuk seçimi (birden çok çocukta)
  │       → önce cocuk kapsamlı sorular, sonra (ilk çocukta) veli kapsamlı ve yanıtlanmamışlar
  │  3. anket_taslak_kaydet(...)           → her adımda kısmi kayıt
  │  4. anket_yanit_gonder(anket, cocuk, yanitlar, yuzey)
  │        ├─ anket_yanitlari        (sürüm, cocuk_id, cocuk_sinif anlık görüntüsü)
  │        ├─ anket_cevaplari        (normalize, soru_kodu başına satır, veli_id + cocuk_id)
  │        ├─ cocuk_ogrenme_profili  (öneri kuralları → profil)
  │        ├─ anket_katilimlari      (anket, veli, cocuk)
  │        └─ anket_gosterimleri     (olay: tamamlandi)
  │  5. öneri (2–3 madde) → sonuç ekranı
  │
  └─ atlandi / ertelendi / kapatildi → etkilesim_butcesi güncellenir

Yönetim paneli (require_admin)
  admin_anket_taslak_kaydet → admin_anket_onizle → admin_anket_yayinla
      (yayın: önceki yayındaki anket kapatılır + arşive alınır; sürüm yazılır)
  admin_anket_arsivle (yayında olmayan) · admin_anket_arsivden_kopyala (taslak kopyası)
  admin_anket_surumleri · admin_anket_sonuc_kirilim · admin_anket_disa_aktar (audit)
  admin_oneri_kurali_kaydet
```

Tüm yazma yolu RPC ve `SECURITY DEFINER` ile. Tablolar `revoke all` ile kapalı (mevcut desen).

## 4. Veri modeli

**Değişen tablolar**

- `anketler`
  - `hedef` CHECK'i kaldırılır; hedef yerine soru bazında `kapsam` tutulur (§4 alt bölüm `sorular`).
  - Eklenir: `tetikleyici` (`ana_sayfa_kart` | `ilk_ogrenme_sonrasi` | `cocuk_eklendi` | `manuel`), `arsiv_nedeni` (`yenisi_yayinlandi` | `elle`), `baslangic_at`, `bitis_at` (isteğe bağlı), `tahmini_sure_sn` (sunucuda hesaplanır).
  - `yuzeyler` dizisinden `web_sitesi` çıkarılır (D1 veri temizliği: dizide yalnız `web_sitesi` kalan anket `veli_paneli`'ye taşınır).
  - `anket_yanit_gonder` ve `anket_aktif_listem` anket yüzeyleri listesine `web_sitesi` almaz.
- `anket_yanitlari`
  - `veli_id` (her zaman dolu, anonim anketler için de kalır; anonimlik ayrı bayrak olarak yönetilir), `cocuk_id` (null olabilir), `cocuk_sinif` (yanıt anındaki sınıf).
  - `anket_id` FK: `on delete cascade` → `on delete restrict`. Anket silme yolu zaten yok; bu, veri kaybını DB seviyesinde de engeller.
- `anket_katilimlari`
  - Birincil anahtar `(anket_id, veli_id, cocuk_id)`; `cocuk_id` null iken ifade indeksi.
- `consents`
  - `tur` CHECK'ine `anket_kisisellestirme` eklenir (hukuk onayından sonra).

**Soru tanımı (`anketler.sorular` ve `anket_surumleri.sorular` içinde):**
- `id` (soru kodu, kilitli), `tur`, `baslik`, `secenekler` (her seçeneğin kodu da kilitli), `kosul`, `amac` ("Neden soruyoruz?"), **`kapsam`** (`cocuk` | `veli`).

**Yeni tablolar**

- `anket_surumleri` (değişmez): `anket_id`, `surum`, `sorular jsonb`, `yayinlandi_at`, `kapandi_at`. `(anket_id, surum)` eşsiz. Yayınlanınca yazılır, güncellenmez.
- `anket_cevaplari` (normalize): `yanit_id`, `anket_id`, `surum`, `soru_kodu`, `kapsam`, `veli_id`, `cocuk_id` (veli kapsamlı ise null), `deger_sayi`, `deger_metin`, `secenek_kodu`, `cocuk_sinif`. Yanıtla aynı işlemde yazılır.
- `anket_taslaklari`: `veli_id`, `anket_id`, `cocuk_id`, `yanitlar jsonb`, `guncellendi_at`. 30 gün sonra temizlenir. Yalnız sahibi okur.
- `anket_gosterimleri`: `veli_id`, `anket_id` (null olabilir), `cocuk_id`, `yuzey`, `olay` (`gosterildi`, `ertelendi`, `atlandi`, `kapatildi`, `tamamlandi`), `created_at`. 180 gün tutulur.
- `etkilesim_butcesi`: `veli_id` (pk), `son_kart_at`, `atlama_sayisi`, `sessiz_kadar`. **Push ön izin tekrar sorma politikası (PROJE_GUNLUGU §23) da bu tabloyu kullanır.**
- `anket_oneri_kurallari`: `anket_id`, `soru_kodu`, `secenek_kodu` (ya da sayı koşulu), `oneri_kodu`, `aktif`, `surum`.
- `cocuk_ogrenme_profili`: `cocuk_id` (pk), `zorluk_alanlari text[]`, `hedef_kodu`, `calisma_gunu_kodu`, `kaynak_anket_surum`, `guncellendi_at`. V2'de öğrenci ekranında okunur.

**Bilinçli olarak yok:** çocuğa ait serbest metin profilde tutulmaz. Serbest metin yalnızca `anket_cevaplari`'nda ve yalnızca admin raporunda görünür.

## 5. Yerleşim ve zamanlama

| Yüzey | Yer | Kural |
|---|---|---|
| Mobil (veli ana sayfası) | Duyurudan sonra, bölümün ilk kartı | Bütçe ve sessiz saat |
| Veli paneli | **Yalnız `/veli-paneli` ana sayfası.** `layout.tsx`'ten kaldırılır (E11) | Bütçe ve sessiz saat |
| Web sitesi (public) | **Anket yok** (kaldırıldı) | Duyuru şeridi etkilenmez |
| Çocuk uygulaması | **Hiçbir zaman** | Öğrenme oturumu bölünmez |

**Tetikleyiciler:**
- `ilk_ogrenme_sonrasi`: çocuğun en az bir cevap olayı var (`user_answers` / `answer_events`) ve veli son 24 saatte kart görmedi.
- `cocuk_eklendi`: çocuk profili oluşturulalı 24 saat geçti.
- `ana_sayfa_kart`: genel kart, bütçe kuralına tabi.

**Etkileşim bütçesi:**
- 24 saatte en fazla **1** etkileşim kartı (anket veya push ön izni).
- Sessiz saatte kart ve pazarlama push'u yok (22:00–08:00, cihaz yerel saati).
- **Atlama** = "Şimdi değil", "Sonra" veya kart kapatma. Atlama sayacı `etkilesim_butcesi.atlama_sayisi`'nde tutulur:
  - 1. atlama → 3 gün sessiz
  - 2. atlama → 14 gün sessiz
  - 3. ve sonrası her atlama → 90 gün sessiz
- **Taslak bırakma** (anketi başlayıp yarıda kapatmak) atlama sayılmaz; kısmi kayıt korunur, bütçe içinde tekrar gösterilir.
- Tamamlanan anket `tekrar_gosterim_gun` (varsayılan 30) kadar tekrar gösterilmez, çocuk başına.

**Tek aktif anket (karar):** Aynı yüzeyde aynı anda en fazla bir yayında anket. Yenisi yayınlanınca önceki arşive alınır. Bu, "yenisi gelirse öncekini arşive koyabiliriz" kararının doğal sonucudur.

## 6. Uzunluk ve soru kuralları

- **Hedef = sert tavan = 7 soru.** Yayın engeli: 7'den fazla soru kaydedilemez.
- Bir çocuk için oturum en fazla 7 soru gösterir. Veli kapsamlı sorular ilk çocukta sorulur; sonraki çocukta zaten yanıtlanmışsa atlanır, oturum yine 7'yi aşmaz.
- İlerleme çubuğu: "Soru 2/7" biçiminde, yalnız görünür sorular sayılır (koşullu sorular dahil değil, sayım yolu üzerinden).
- Süre tahmini: tek seçim 5 sn, onay 3 sn, NPS/CSAT 4 sn, metin 30 sn. Önizlemede ve yayın kontrolünde gösterilir.
- Zorunlu soru en fazla 3. Kalanlar "atla" seçeneğiyle gelir.
- Koşul tek seviye (bir soru yalnız önceki bir soruya bağlanır).
- Mobilde ekran başına bir soru. Web kartında da bir soru, ilerleme çubuğu.
- Her soruda isteğe bağlı **"Neden soruyoruz?"** açıklaması (`amac`).
- Her adımda kısmi kayıt (`anket_taslaklari`).

## 7. Fayda döngüsü

Veli neden cevaplasın? Cevabın karşılığını hemen görürse:

1. **Gönderim sonucu:** "Hupo'nun başlangıç önerisi": 2–3 madde (en fazla 3), kural tabanlı (`anket_oneri_kurallari`). Dil: "başlangıç", "öneriyoruz", "deneyebilirsiniz". Garanti yok.
2. **Çocuk ana sayfası (V2):** `cocuk_ogrenme_profili` üzerinden "Bugünkü başlangıç" kartı. Yalnız veli onaylı kapsamda.
3. **Veli paneli:** "Verdiğim yanıtlar" bölümü: görme ve değiştirme. KVKK erişim ve düzeltme hakkının karşılığı.
4. **Rıza geri çekilince:** cocuk kapsamlı yanıtlar anonimleştirilir (`cocuk_id` boşaltılır) ve profil silinir.

Önerinin ürünün gerçekte yaptığıyla uyuşması şarttır. Yapılmayan bir kişiselleştirme "size özel" diye sunulmaz.

## 8. Yönetim paneli: soru revizyonu ve arşiv

**Akış:** Taslak → önizleme → yayın → kapat/arşivle. Yayın yalnız kontrol listesi geçilince açılır.

**Yayın anı (arşiv kuralı):**
- Yayın ekranında: "Şu anda yayında olan 'X' anketi kapatılıp arşive alınsın mı?" (varsayılan işaretli).
- İşaretliyse, tek transaction içinde: önceki anket `kapali` olur, `arsivlendi_at` ve `arsiv_nedeni = 'yenisi_yayinlandi'` yazılır, yeni anket yayınlanır. Hata olursa ikisi de yazılmaz.
- Önceki anketin sürümleri, yanıtları ve sonuç raporu olduğu gibi kalır.

**Arşiv kuralları:**
- Anket silinmez. Silme düğmesi ve RPC yoktur.
- Arşivdeki anket salt okunur. Sonuçlar, sürümler ve yanıtlar erişilebilir.
- Arşivden "kopya ile yeniden kullan": taslak olarak yeni bir anket oluşturulur. Eski anket değişmez.
- Yayında olmayan anket elle arşivlenebilir (`admin_anket_arsivle`).

**Düzenleme kuralları:**

| Değişiklik türü | Ne olur |
|---|---|
| Yazım düzeltmesi (başlık, seçenek metni) | Sürüm artmaz, kod ve anlam aynı |
| Anlamı değiştiren (tür, seçenek kapsamı, koşul, kapsam) | Yeni sürüm. Eski yanıtlar eski sürümle raporlanır. Onay: "Bu değişiklik önceki sonuçlarla karşılaştırmayı zorlaştırır" |
| Soru kodu ve seçenek kodu | Yanıt varsa **değişmez** (DB kısıtı). Yeni kod = yeni soru |
| Yayındaki sorunun kaldırılması | Yanıtlar silinmez. Soru "kaldırıldı" işaretlenir, yeni yanıt almaz |
| Kapsam değişikliği (`cocuk` ↔ `veli`) | Anlamı değiştirir: yeni soru kodu gerekir |
| Soru kütüphanesi | Ortak havuz. Anket havuzdan **kopya** alır, referans tutmaz |

**Ekranlar:**
- Taslak düzenleyici: mevcut `SurveysManager` editörü genişletilir. Eklenecekler: soru kodu (kilitli), `amac`, `kapsam` seçimi (çocuk başına / veli başına), süre tahmini, 7 soru sınırı göstergesi.
- Önizleme: mobil ve web kartı yan yana, koşul simülasyonu.
- Sürüm geçmişi: sürüm listesi, iki sürüm arası fark.
- Öneri kuralları: soru + seçenek → öneri kodu. Hiç tetiklenmeyen kural uyarısı.
- Yayın kontrol listesi: soru sayısı ≤ 7, her sorunun `kapsam`ı belirli, süre tahmini, yüzey (en az bir ve yalnız anket yüzeyleri), hedef, tetikleyici, rıza sürümü (çocuk kapsamı için), gizlilik metni sürümü, öneri kurallarının en az biri eşleşmiş, önceki yayındaki anketin arşivleme seçimi.
- Her yazma `log_admin_action` ile kaydedilir.

**Yetki:** `require_admin` yeterli. Ayrı içerik editörü rolü ertelendi.

## 9. Veri okuma ve raporlama

- **Kırılım:** soru × sınıf × ders. Hücrede n < 5 ise değer gösterilmez (anonim eşiği, tüm anketlere).
- **Veli kapsamlı sorular:** veli başına tekil yanıt; raporda veli sayısı üzerinden.
- **Tablo:** `anket_cevaplari` üzerinden SQL görünümü. Rapor JSON'a bağımlı değil.
- **Dışa aktarım:** yalnız admin, her dışa aktarım audit'e yazılır. `cocuk_id` ve `veli_id` dışarı çıkmaz; satır numarası ve sınıf çıkar. Serbest metin ayrı dosyada, varsayılan kapalı.
- **Talep sinyali panosu:** sınıf başına en çok seçilen zorluk alanı ve yüzdesi.
- **Etkileşim hunisi:** gösterildi → başladı → tamamlandı; ayrıca atlandı ve kapatıldı. `anket_gosterimleri`'nden.
- **Anonimleştirilmiş veri:** 24 ay sonra yalnız toplu istatistik kalır; bu veriler dönemler arası karşılaştırmada kullanılır.

## 10. Gizlilik ve saklama

- Çocuk kapsamlı anket, `anket_kisisellestirme` rızası yoksa **gösterilmez**. Rıza metni sürümlü (`consents.surum`).
- Rıza geri çekilince: yanıtlar anonimleşir, profil silinir, bekleyen kartlar kapanır.
- **Saklama (karar):**
  - Ham yanıt: 24 ay. Sonra anonimleştirme görevi (cron): `veli_id`, `cocuk_id`, `cocuk_sinif` boşaltılır; yanıt içeriği yalnız toplu sayıma dahil edilir.
  - Gösterim olayları: 180 gün.
  - Taslaklar: 30 gün.
- Anonimleştirme görevinin her çalışması audit'e yazılır.
- Tablolar `revoke all`. Okuma ve yazma yalnız SECURITY DEFINER RPC üzerinden.
- Veli kendi yanıtlarını görebilir ve silme talebi açabilir. Bu akış v1 dışında, ertelendi.
- Bu bölüm hukuki görüş değildir. Anonimleştirme yöntemi, aydınlatma metni, rıza metni ve saklama süreleri hukuk onayı olmadan yayına alınmaz.

## 11. Uygulama dilimleri

| Dilim | İçerik | Bağımlılık |
|---|---|---|
| D1 Şema ve güvence | `anket_surumleri`, soru ve seçenek kodu kilidi, `anket_gosterimleri`, `etkilesim_butcesi`, `anket_taslaklari`; `anket_yanitlari.anket_id` `restrict`; `web_sitesi` anket yüzeyi temizliği; `arsiv_nedeni`; tek aktif anket kuralı; yayın anında otomatik arşiv. Mevcut RPC'ler geriye uyumlu | — |
| D2 Tüketim | `anket_siradaki_kart`, bütçe ve sessiz saat, atlama sayacı (3/14/90), mobil ve veli paneli kartı, `layout.tsx`'ten kaldırma, web sitesi anket bileşeninin kaldırılması | D1 |
| D3 Çocuk kapsamı | `cocuk_id` ve `cocuk_sinif`, soru bazlı `kapsam`, `anket_cevaplari`, `anket_kisisellestirme` rızası, öneri kuralları, sonuç ekranı | D1, hukuk onayı |
| D4 Yönetim | Taslak, önizleme, yayın (arşiv seçeneğiyle), arşiv ve kopya, sürüm geçmişi, öneri editörü, kırılım ve CSV | D1 |
| D5 Test ve doğrulama | PGlite (`supabase/tests` deseni): arşiv ve yanıt koruması, cascade → restrict, bütçe ve atlama süreleri, sessiz saat. Flutter ve web `tsc`/eslint. Gerçek veli hesabıyla uçtan uca. 320 px ve karanlık mod | D2–D4 |
| D6 Saklama | Anonimleştirme görevi, saklama süreleri uygulaması | D3, hukuk onayı |

- Her dilim ayrı onay ister. Uzak veritabanına uygulama ayrı onaydır (PROJE_GUNLUGU §16'da önceki `db:deploy` denemesi reddedildi).
- Görsel kontrol (anket penceresi, karanlık mod, 320 px) PROJE_GUNLUGU §16'da açık; D2 kapanmadan tamam sayılmaz.
- **Arşiv testi açık:** PROJE_GUNLUGU §16'daki "arşivlenen ve yanıtı olan anketin yanıtlarının korunması" PGlite'ta henüz test edilmedi. D5'te kapatılır.

## 12. Kalan açık noktalar

**Onaylanan (kullanıcı, 2026-10-16):**

1. **90 gün sonrası atlama:** Sayaç sıfırlanmaz; her atlama 90 gün sessiz kalır.
2. **Sessiz saat kapsamı:** 22:00–08:00 arası anket kartı ve pazarlama bildirimleri gönderilmez. İşlemsel bildirimler kapsam dışıdır. Hangi bildirimlerin işlemsel sayılacağı hukuk ve ürün onayı bekler (§12-A).
3. **Tek aktif anket:** Aynı yüzeyde aynı anda en fazla bir yayında anket. Yenisi yayınlanınca önceki arşive alınır.
4. **Ziyaretçi için 1 soruluk widget:** Onaylandı. Anonim ziyaretçiden pazarlama izni alınamadığı için widget yalnızca kişisel veri toplamayan bir soru olabilir. Ayrı tasarım olarak hazırlanacak (§12-B).

**Son kararlar (asistan önerisi, kullanıcı netleştirme görevini devretti, 2026-10-16):**

5. **Veli kapsamlı soru tekrarı:** 365 gün ya da soru kodu değişene kadar sorulmaz. Atlanan veli sorusu yanıtlanmış sayılmaz; 90 gün sonra tekrar sorulabilir (atlama takvimiyle aynı).
6. **Kartı kapatma ("X"):** Atlama sayılır, kart başına bir kez. Anket içindeki "bu soruyu atla" ve yarıda bırakılan taslak atlama sayılmaz. Gerekçe: kapatma düğmesi "şimdi değil" niyetini taşır; sayılmazsa 3/14/90 takvimi anlamsızlaşır.

**§12-A (sessiz saat, mevcut durum ve eksikler):**
- Push altyapısında sessiz saat zaten var (`20260920001000_push_notifications.sql`): `push_in_quiet_hours` ve `push_allowed_now`, saat dilimi Europe/Istanbul, kullanıcı başına ayarlanabilir.
- Pazarlama kampanya dağıtımı (`20261036000000_kampanya_push_dagitim.sql`) sessiz saatte kampanyayı iptal eder (ertelemez değil). Bu davranış korunur.
- **Eksikler (D2):**
  1. Varsayılan 20:00–08:00 → 22:00–08:00. Varsayılanı kullanan mevcut kayıtlar için geçiş kararı gerekir. `push_tests.sql` 20:00 beklentisini kontrol ediyor; güncellenecek.
  2. Kural bugün tüm push'lara uygulanıyor (`push_allowed_now`). İşlemsel bildirimler muaf tutulmalı; muafiyet kategoriye göre yapılmalı. Hangi kategorilerin işlemsel olduğu listesi hukuk ve ürün onayı bekler.
  3. Anket kartı aynı kontrolü kullanmalı. `push_in_quiet_hours` yeniden kullanılabilir.

**§12-B (ziyaretçi widget'ı):** Ayrı belge olarak hazırlanacak. İçerik, yer ve metin ile ölçüm tanımı bu belgede olacak.

## 13. Riskler

- **Canlı veri:** Uzak veritabanındaki mevcut anket ve yanıt sayısı bilinmiyor. D1'den önce sayılmalı. `web_sitesi` temizliği ve cascade → restrict bu veriyi etkiler.
- **Küçük başlangıç kitlesi:** Tetikleyici kart az veliye ulaşabilir. Yanıt oranı tahmini yok. Erken veriler eğilim olarak okunmalı.
- **Düşük yanıt oranı:** İçerik kararı yanlış yönlenebilir. n < 5 gizleme ve dönem sınırı bunu sınırlar, ortadan kaldırmaz.
- **Bütçe çakışması:** Push ve anket aynı sayaçta değilse veli üst üste istek görür. Ortak bütçe bunu önler (PROJE_GUNLUGU §23).
- **Öneri yanıltıcılığı:** Kural tabanlı öneri, gerçek kişiselleştirme gibi sunulursa güven kaybettirir.
- **Arşiv karışıklığı:** Yeni anket yayınlanınca eski anketin sonuçları ortadan kalkmış gibi görünebilir. Arşiv sekmesi ve sayısı yönetim panelinde açık gösterilmeli.
- **Hukuki:** Anonimleştirme yönteminin KVKK'ya uygunluğu ve rıza metninin hukuk onayı gerekli. Bu tasarım hukuki görüş değildir.
