# MASTER_BRIEF — Proje Okulu / Öğrenci Hazırlık (Hupo)

> Bu dosya, projenin **tek doğruluk kaynağıdır**. Yeni bir sohbete başlarsan
> önce bu dosyayı, sonra `AGENTS.md`'yi oku.
> Son güncelleme: 27 Eylül 2026

---

## 1. Proje ne?

**Öğrenci Hazırlık** — Türkiye'de ortaokul öğrencileri için matematik çalıştırma
uygulaması. Flutter mobil uygulama + Next.js veli/yönetim paneli + Supabase backend.

| Parça | Klasör | Teknoloji | Durum |
|---|---|---|---|
| Öğrenci uygulaması | `mobile-app/` | Flutter, Riverpod, Supabase | ⚠️ **Kısmi** |
| Panel | `web-panel/` | Next.js 16, next-intl, Tailwind v4 | ✅ Çalışıyor |
| Backend | `supabase/` | PostgreSQL, RPC, Edge Functions | ⚠️ **Kısmi** |

**Paket adı:** `com.ogrencihazirlik.ogrenci_hazirlik` (sürüm 1.0.0+1)
**Supabase projesi:** `ccozfrpnvyrnktpffkwo`
**Konum:** `C:\Users\cengi\OneDrive\Desktop\çıkarıldı\Fırsat Bulucu-Ürün Geliştirme`

---

## 2. ⚠️ Projenin şu anki kritik durumu

**27 Eylül 2026'da diskteki kaynak dosyaların bir kısmı silinmişti.** Yapılan
kurtarma çalışmasının tamamı `kurtarilan/KURTARMA_RAPORU.md` içinde.

### Geri gelen
- `mobile-app/assets/fonts/Nunito.ttf` ve `Lexend.ttf` — APK'dan **birebir** çıkarıldı.
  Bu iki dosya olmadan uygulama hiç derlenmiyordu.
- Telefondaki APK → `kurtarilan/ogrenci_hazirlik-base.apk` (66,7 MB)
- Dart AOT anlık görüntüsü → `kurtarilan/libapp.so`

### Hâlâ eksik olan
1. **22 Dart dosyası** — APK'da var, diskte yok (bkz. rapor bölüm 2)
2. **12 backend RPC** — canlı veritabanında var, `supabase/migrations/` altında yok
   (bkz. rapor bölüm 3)
3. **153 Türkçe metin** — APK'da var, diskteki kaynakta yok

> ### Gerçek şudur
> `libapp.so` bir **derlenmiş makine kodu**. Kaynak kod içermez. Yani eksik dosyalar
> **yeniden yazılmalı**; birebir kopyalanamaz. Elimizdeki: dosya yolları, sınıf adları,
> provider adları, RPC imzaları, JSON alan adları, tüm Türkçe metinler.
> Bu belgeler yeterli — rapor bölüm 4'e bak.

### Kurtarma için geriye kalan tek yol
**Canlı Supabase Dashboard.** `supabase/migrations/` altındaki RPC'ler birebir oradan
alınabilir. Bu, en değerli ve en kolay adımdır. Erişim için bkz. bölüm 6.

---

## 3. Özellik envanteri

Tam döküm: `kurtarilan/KURTARMA_RAPORU.md` bölüm 4.

### Çalışan (diskte var)
| Özellik | Dosya |
|---|---|
| Giriş / kayıt | `mobile-app/lib/auth/` |
| Ana ekran, seri, lig, rozet | `screens/home_screen.dart`, `widgets/` |
| Soru çözme, sonuç | `screens/quiz_screen.dart`, `result_screen.dart` |
| Profil, ayarlar, gizlilik | `screens/profile_screen.dart`, `settings_screen.dart` |
| Bildirimler (push) | `services/push/` |
| Veli & yönetim paneli | `web-panel/src/app/[locale]/(admin)/` |
| Ödeme (iyzico) | `supabase/functions/payments-*` |

### Kayıp (yeniden yazılacak)
| Özellik | Ana dosyalar | Zorluk |
|---|---|---|
| Çarpım Tablosu Şifreleri | `screens/cipher/*`, `models/cipher_models.dart` | ⭐⭐⭐ En büyük |
| Günün 5 Sorusu | `screens/daily_challenge_screen.dart` | ⭐⭐ |
| Günün Tekrarı | `screens/review_screen.dart` | ⭐⭐ |
| Kayıtlı Sorular | `screens/saved_questions_screen.dart` | ⭐ |
| Soru bildirme | `widgets/report_question_button.dart` | ⭐ |
| Sınıf seçimi | `screens/grade_picker_screen.dart` | ⭐⭐ |
| Bakım modu | `widgets/maintenance_gate.dart` | ⭐ |
| AdMob banner | `ads/*` | ⭐ |

### Önerilen yazım sırası
`models/` (4) → `services/personal_best.dart` → `widgets/` (8) → `screens/` (6) → `ads/` (2)

---

## 4. Önemli kurallar

### Proje kuralları (AGENTS.md'ye bak)
- Türkçe arayüz, Türkçe yorum ve isimlendirme (`sinif`, `dogru`, `rozet_sayisi`)
- Yeni RPC'ler `SECURITY DEFINER` + `set search_path` ile yazılır
- Öğrenci verisi RLS ile korunur; veli bağlama sadece `service_role` ile yapılır
- Çocuk güvenliği (COPPA) varsayılanları açık

### Güvenlik — önemli
- `service_role` / `sb_secret_` anahtarı **ASLA** uygulamaya konmaz.
  APK'da arandı, **bulunamadı** (doğru davranış).
- `web-panel/.env.local` içindeki publishable key istemciye açık olabilir — sorun değil.
- PII (öğrenci adı, veli e-postası) log'a yazılmaz.
- `kurtarilan/` klasörü 84 MB binary içerir; **git'e girmemeli**.

---

## 5. Bilinen tuzaklar

| Tuzak | Açıklama |
|---|---|
| **`reports/` ve `research_notes/` bu projeye ait değil** | İthalat fırsat ürünü için ayrı bir iş fikri fizibilite raporları. Silinebilir. |
| **`proje-okulu-app/` eski kova** | 2026-09-20 tarihli ilk migration'ın **kopyası** (12 KB). Ana `supabase/` ile karışmasın, silinebilir. |
| **`kurtarilan/strings-*.txt` çoğu gereksiz** | 5 farklı döküm denemesi. Sadece `turkish-utf16.txt`, `missing-turkish.txt`, `feature-tokens.txt` ve `tokens.txt` gerekli. |
| **`.next/` ve `node_modules/`** | Yeniden üretilebilir, 1 GB. Silinebilir. |
| **İki ayrı proje kopyası var** | `Desktop\Fırsat Bulucu-Ürün Geliştirme` bu klasörün **birebir aynısı** (59/59 dosya doğrulandı). Silinebilir. |
| `e.innerText)` ve `e.innerText)})` | Yanlış adla oluşmuş dosyalar (muhtemelen terminal çıktısı). Silinebilir. |
| `tools/unzip*.{ps1,js}` | Flutter SDK çıkarma araçları, tek seferlik. |
| **`supabase/config.toml` yok** | `proje-okulu-app/supabase/config.toml` var. Ana klasöre taşınmalı veya silinmeli. |

---

## 6. Supabase'a erişim

### 6.1 Doğrulanmış canlı durum
Anon (publishable) key ile yapılan denemeler, 27 Eylül 2026:

| Deneme | Sonuç |
|---|---|
| `get_app_config` RPC | ✅ **200** — çalışıyor, şema aşağıda |
| `get_carpim_sifreleri` RPC | 401 — oturum istiyor |
| `get_supported_grades` RPC | 401 |
| `get_daily_challenge` RPC | 401 |
| `list_bookmarks` RPC | 401 |
| `GET /rest/v1/` (OpenAPI şeması) | 401 — şema gizli |
| `GET /rest/v1/profiles` | 404 |

**Sonuç:** Publishable key ile yalnızca `get_app_config` okunabiliyor.
Şema dökümü için **ya Dashboard erişimi ya da DB şifresi** şart.

### 6.2 `get_app_config` yanıtı (birebir)
```json
{
  "bakim_modu":  { "aktif": false, "mesaj": "" },
  "min_surum":   { "ios": "1.0.0", "android": "1.0.0", "web": "1.0.0", "mesaj": "" },
  "reklamlar":   { "ogrenci_acik": false, "veli_paneli_acik": false,
                   "admob_app_id_android": null, "admob_banner_id_android": null,
                   "admob_app_id_ios": null,     "admob_banner_id_ios": null,
                   "adsense_publisher_id": null, "adsense_slot_id": null }
}
```
→ Reklamlar **kapalı**, bakım modu **kapalı**, zorunlu güncelleme yok.
Yeni kod varsayılan olarak kapalı kalmalı (AGENTS.md kural 6).

### 6.3 Şifre gerekiyor — iki yol

**A. Supabase CLI (önerilen, tam sonuç verir)**
```bash
npm i -g supabase
supabase login                       # tarayıcıda açılır
supabase link --project-ref ccozfrpnvyrnktpffkwo
supabase db pull                     # şemayı supabase/ altına indirir
```

**B. Dashboard'dan elle**
- Dashboard → SQL Editor
```sql
-- Şema dökümü (sonucu kurtarilan/supabase-schema.sql olarak kaydet)
select table_name, column_name, data_type
from information_schema.columns
where table_schema = 'public' order by table_name, ordinal_position;
```
```sql
-- Fonksiyon dökümü
select routine_name, routine_definition
from information_schema.routines
where routine_schema = 'public'
  and routine_name in (
    'get_carpim_sifreleri','get_carpim_sifre_detay','submit_cipher_answer',
    'complete_cipher_stage','report_taught_friend','get_daily_challenge',
    'complete_daily_challenge','get_supported_grades','set_my_grade',
    'get_app_config','toggle_bookmark','list_bookmarks','report_question'
  );
```

**C. Kullanıcıya ne lazım:** Supabase Dashboard'a giriş yapabilir mi?
Yoksa veritabanı şifresi (Dashboard → Settings → Database) yeterli.

### 6.4 Güvenlik kontrolü — olumlu
APK'nın `libapp.so` içinde `service_role` / `sb_secret_` anahtarı **arandı,
bulunamadı**. Yani uygulama şifreleri düzgünce gizliyor. (Bir `sb_secret_B`
dizgisi göründü ama bu string tablosunda komşu baytlarla birleşmiş bir
yanlış pozitiftir — arkasında anahtar yok.)

---

## 7. Sıradaki adımlar

1. **Supabase şemasını kurtar** — bölüm 6. Bu yapılmadan hiçbir yeni özellik çalışmaz.
2. **`models/` altındaki 4 dosyayı yaz** — en kolay, RPC'lere birebir bağlı.
3. **Çarpım Tablosu Şifreleri** — en değerli özellik, en çok iş.
4. **`web-panel/.next/` ve `node_modules/` temizliği** — bkz. `TEMIZLIK_RAPORU.md`

---

## 8. Dosya haritası

```
Fırsat Bulucu-Ürün Geliştirme/
├── MASTER_BRIEF.md          ← bu dosya
├── AGENTS.md                ← ajan kuralları
├── TEMIZLIK_RAPORU.md       ← silinecekler
├── DURUM.md                 ← eski oturum notu
├── mobile-app/              Flutter uygulama
│   ├── lib/                 59 dosya (22'si eksik)
│   └── assets/              23 hupo PNG, 4 lottie, 2 font
├── web-panel/               Next.js panel (src/ = kaynak, gerisi üretilir)
├── supabase/                Backend (28 dosya — 12 RPC eksik)
├── kurtarilan/              APK + AOT + metin dökümleri (84 MB)
├── tools/                   tek seferlik yardımcı scriptler
├── proje-okulu-app/         ← ESKİ KOVA, silinebilir
├── reports/                 ← BAŞKA PROJE, silinebilir
└── research_notes/          ← BAŞKA PROJE, silinebilir
```
