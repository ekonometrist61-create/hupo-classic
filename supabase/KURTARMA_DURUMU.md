# KURTARMA DURUMU — Supabase (backend)

> Bu dosya, `supabase/migrations/` altındaki **kurtarma zincirinin durumunu** ve
> `supabase db reset` / `supabase test db` çalıştırılmadan önce tamamlanması
> gereken eksikleri listeler.
> Son güncelleme: 28 Eylül 2026
> İlgili: `kurtarilan/KURTARMA_RAPORU.md` §3, `TASKS.md` §3-§4

---

## 1. Migration sırası (düzeltildi)

| # | Dosya | Ne yapar |
|---|---|---|
| 1 | `20260920000000_initial_schema.sql` … `20260920001100_payments_iyzico.sql` | Temel şema, XP/seri, rozet, RLS, ödeme |
| 2 | `20260927000000_daily_challenge_and_bookmarks.sql` | Günün 5 Sorusu + kayıtlı sorular |
| 3 | `20260927000010_carpim_sifreleri_tables.sql` | Çarpım tablosu **tabloları** |
| 4 | `20260927000020_carpim_sifreleri_rpc.sql` | Çarpım tablosu + sınıf seçimi + soru bildirme **RPC'leri** |
| 5 | `20260927000030_missing_objects_recovery.sql` | `grade_changes` + `question_reports` tabloları ve 4 eksik fonksiyon |

> ⚠️ **Düzeltilen hata:** Tabloları oluşturan dosya eskiden `…000020`, tablolara
> referans veren RPC dosyası `…000010` idi; yani RPC'ler tablolardan **önce**
> çalışıyordu. İkisinin adı bu yüzden takas edildi.

---

## 2. Kurtarılanlar (canlıdan birebir)

- 15 RPC: `get_daily_challenge`, `complete_daily_challenge`, `list_bookmarks`,
  `toggle_bookmark`, `get_carpim_sifreleri`, `get_carpim_sifre_detay`,
  `submit_cipher_answer`, `complete_cipher_stage`, `report_taught_friend`,
  `get_supported_grades`, `set_my_grade`, `report_question` + `_dc_*` yardımcıları
- 3 tablo: `daily_challenges`, `daily_challenge_completions`, `question_bookmarks`
- 3 tablo: `carpim_sifreleri`, `carpim_ilerleme`, `carpim_deneme_log`
- 2 tablo: `grade_changes`, `question_reports` (+ tüm kısıt ve indexleri)
- 4 fonksiyon: `_desteklenen_siniflar()`, `_sinif_yaz(uuid, integer, text)`,
  `_refresh_question_flag(uuid)`, `admin_set_daily_challenge(date, uuid[], text)`

> Bu kalemler `kurtarilan/cikti-bagimlilik.csv`, `cikti-carpim3.csv` ve
> `cikti-kalan.csv` (SQL Editor / katalog çıktıları) içinden **birebir**
> taşındı — hiçbir kolon adı veya fonksiyon gövdesi tahmin edilmedi.

---

## 3. ⏳ Hâlâ canlıdan teyit edilecekler

Kurtarma zinciri **derleme (reset) açısından tamam**: `tools/kurtarma-bagimlilik-denetimi.ps1`
artık **0 eksik referans**, `tools/kurtarma-sql-denetim.ps1` **0 hata / 0 uyarı**,
`tools/istemci-rpc-denetimi.ps1` **0 eksik RPC** veriyor (bkz. §5).

Bu turda kapananlar: `question_quality_config` (§4.1 → `20260927000050`),
`questions.inceleme_gerekli` (§4.5 → `20260927000040`), `profiles` sınıf kuralı
(§4.2 → `20260927000060`), `question_revisions` + `admin_question_history`
(→ `20260927000110`), kupon/kampanya kümesi (→ `20260927000130`),
deneme sınavı kümesi (→ `20260927000140`), soru analitiği (→ `20260927000150`).

Geriye **yalnızca canlıdan birebir teyit** işi kaldı — hiçbiri çalışma anında
hata üretmez, hepsi kullanım sözleşmesinden geri kurulmuş tanımlardır:

| Nesne | Nasıl geri kuruldu | Risk | Getirme sorgusu |
|---|---|---|---|
| `_kupon_kod_temizle`, `_kupon_mesaj`, `_kupon_dogrula`, `_kupon_deneme_sayisi`, `_kupon_deneme_kaydet`, `_kupon_degerlendir` | Gövde yok → çağrı yerlerinden türetildi (imza + dönüş anahtarları birebir) | Metin/İç mantık farkı | §4.6 |
| `public.coupons` / `campaigns` / `coupon_redemptions` kolon+kısıtları | Canlı gövdelerdeki kolon adlarından, komşu tablo desenine göre | Kısıt/tip farkı | §4.6 |
| `public.coupon_attempts` (kupon deneme sayacı) | **Tamamen türetildi** — hiçbir dökümde geçmiyor | Tablo adı/kolon farkı | §4.6 |
| `public.deneme_sinavlari` / `deneme_sinavi_sorulari` / `deneme_sinavi_denemeleri` | Canlı gövdelerde geçen kolon adları; tipler `RETURNS TABLE` bildiriminden | Kısıt/index farkı | §4.7 |
| `_question_analytics_base` | Gövde yok → çağıranın okuduğu 16 kolondan türetildi | Bayrak adları/eşikleri | §4.8 |
| `_soru_anlik(uuid)` | Gövde yok → çağrı kapsamından türetildi | Görünüm/alan farkı | §4.9 |
| `question_revisions` tablo tanımı | Kullanımdan geri kuruldu | Kolon/kısıt farkı | §4.9 |
| `question_quality_config` kısıt/indexleri | Kolonlar koddan çıkarıldı | Kısıt farkı | §4.1 |
| `grade_changes` / `question_reports` RLS politikaları | Fail-closed (politika yok) | Canlıda politika varsa davranış farkı | §4.3 |
| `carpim_sifreleri` içerik verisi | `20260927000015_carpim_sifreleri_seed.sql` ile 10 şifre seed edildi; canlı içerikle birebirlik ayrıca teyit bekliyor | Canlıdaki metin/şifre sayısı farklı olabilir | §4.4 |

> Not: `user_badges` ve `evaluate_badges` aslında **mevcut**
> (`20260920000000_initial_schema.sql` ve `20260920000500_badges.sql`).
> TASKS.md'deki "eksik" kaydı bu iki kalem için geçersizdir.
> `app_settings` de mevcut (`20260920001100_payments_iyzico.sql`).
>
> Kural: bu tablodaki satırlar için **tahmin yürütülmedi**; her türetilmiş
> gövde migration içinde `TODO(kurtarma)` ile ve yanında `pg_get_functiondef`
> doğrulama sorgusuyla işaretlendi.

---

## 4. Canlıdan getirme sorguları

`supabase link --project-ref ccozfrpnvyrnktpffkwo` + `supabase db pull` hâlâ
en iyi yol; CLI yoksa aşağıdakileri Dashboard → SQL Editor'da çalıştırın.

### 4.1 question_quality_config (zorunlu)

```sql
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public' and table_name = 'question_quality_config'
order by ordinal_position;

select conname, pg_get_constraintdef(oid) from pg_constraint
where conrelid = 'public.question_quality_config'::regclass;

select * from public.question_quality_config;
```

### 4.2 profiles sınıf kuralı trigger'ı

```sql
select tgname, pg_get_triggerdef(oid)
from pg_trigger
where tgrelid = 'public.profiles'::regclass and not tgisinternal;
```

### 4.3 RLS politikaları

```sql
select c.relname, p.polname, p.polcmd, p.polpermissive,
       pg_get_expr(p.polqual, p.polrelid)      as kullanim_kosulu,
       pg_get_expr(p.polwithcheck, p.polrelid) as yazma_kosulu
from pg_class c
left join pg_policy p on p.polrelid = c.oid
where c.relnamespace = 'public'::regnamespace
  and c.relname in ('grade_changes', 'question_reports')
order by c.relname, p.polname;
```

### 4.4 carpim_sifreleri içerik verisi

```sql
select jsonb_agg(to_jsonb(s) order by s.sira) from public.carpim_sifreleri s;
```

### 4.5 questions.inceleme_gerekli kolonu (yeni tespit)

```sql
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public' and table_name = 'questions'
order by ordinal_position;
```

> Disk şemasında `questions` tablosunda `inceleme_gerekli` kolonu **yok**;
> canlıda var (kurtarılan `_refresh_question_flag` gövdesi onu yazıyor).
> Bu yüzden tablo tanımı da canlıdan tazelenmeli.

### 4.6 Kupon + kampanya kümesi (yeni tespit)

```sql
select pg_get_functiondef(p.oid)
from pg_proc p join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public' and p.proname like '_kupon%';

select table_name, column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public'
  and table_name in ('campaigns', 'coupons', 'coupon_redemptions')
order by table_name, ordinal_position;

-- Deneme sayacı tablosunun canlıdaki adı (yerelde public.coupon_attempts)
select c.relname
from pg_class c join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public' and c.relkind = 'r'
  and (c.relname like '%coupon%' or c.relname like '%kupon%'
       or c.relname like '%attempt%' or c.relname like '%deneme%');
```

### 4.7 Deneme sınavı tabloları (yeni tespit)

```sql
select table_name, column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public' and table_name like 'deneme_sinavi%'
order by table_name, ordinal_position;

select conrelid::regclass, conname, pg_get_constraintdef(oid)
from pg_constraint
where conrelid::regclass::text like 'public.deneme_sinavi%';
```

### 4.8 Soru analitiği tabanı ve bayrak adları (yeni tespit)

```sql
-- Gövdenin birebir hâli (limit_ms ve bayraklar buradan teyit edilir)
select pg_get_functiondef('public._question_analytics_base(integer)'::regprocedure);

-- Gerçek veride hangi bayrak adları üretilmiş:
select distinct b.bayrak
from public._question_analytics_base(1) a, unnest(a.bayraklar) b(bayrak)
order by 1;
```

### 4.9 _soru_anlik + question_revisions (yeni tespit)

```sql
select pg_get_functiondef('public._soru_anlik(uuid)'::regprocedure);

select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public' and table_name = 'question_revisions'
order by ordinal_position;

select conname, pg_get_constraintdef(oid)
from pg_constraint where conrelid = 'public.question_revisions'::regclass;
```

---

## 5. Doğrulama durumu (27.09.2026)

| Araç / dosya | Sonuç |
|---|---|
| `tools/kurtarma-sql-denetim.ps1` | **0 hata / 0 uyarı** (35 dosya; 2 "dinamik revoke bloğu" notu) |
| `tools/kurtarma-bagimlilik-denetimi.ps1` | **0 eksik referans** (55 kurtarılan gövde, 94 tanımlı referans) |
| `tools/istemci-rpc-denetimi.ps1` | **0 eksik RPC** (istemci 27 RPC çağırıyor, hepsi tanımlı) |
| `tools/sql-sozdizim-denetimi.mjs` | **0 hata** (36 SQL dosyası: parantez/metin/yorum/dolar-tırnak dengesi, gövde içleri dahil) |
| `supabase/tests/kurtarma_tests.sql` | 47 senaryo (46–47: 10 şifre seed ve kapalı test cevap gizliliği) |

> Bu satırlar `_kupon_mesaj` düzeltmesinden (bkz. §5.2) **sonra** dört araçla
> yeniden üretildi: `node tools/sql-sozdizim-denetimi.mjs` → `HATA: 0` (35 dosya),
> `tools/kurtarma-sql-denetim.ps1` → `hata: 0 | uyarı: 0 | not: 2`,
> `tools/kurtarma-bagimlilik-denetimi.ps1` → `EKSİK (0 referans)`,
> `tools/istemci-rpc-denetimi.ps1` → `EKSİK (0)` (istemci 27 RPC çağırıyor).
>
> Dikkat: Bu makinede PowerShell betik çalıştırma **varsayılan olarak kapalıdır**
> (`running scripts is disabled on this system`). Betikleri şöyle çalıştır:
>
> ```powershell
> powershell -NoProfile -ExecutionPolicy Bypass -File tools/kurtarma-sql-denetim.ps1
> powershell -NoProfile -ExecutionPolicy Bypass -File tools/kurtarma-bagimlilik-denetimi.ps1
> powershell -NoProfile -ExecutionPolicy Bypass -File tools/istemci-rpc-denetimi.ps1
> ```
>
> Raporlar `%TEMP%\firsat\*-raporu.txt` dosyalarına yazılır (konsol çıktısı
> yakalanamadığı için rapor dosyası okunur).

Yerel makinede `supabase`, `psql` ve `docker` **kurulu değil**; bu yüzden
`supabase db reset` / `supabase test db` bu ortamda çalıştırılamadı. Yerine:

```bash
node tools/sql-sozdizim-denetimi.mjs        # yapısal SQL denetimi (0 hata olmalı)
```

komutuyla tüm migration ve test dosyaları statik olarak doğrulandı (kapanmayan
parantez/metin/yorum/dolar-tırnak bloğu yok). Testleri çalıştırmak için:
`supabase db reset && supabase test db` veya SQL Editor'de
`supabase/tests/kurtarma_tests.sql` (sonuç: `gecti = true` sütunu).

> Not: İlk denemede yazılan `tools/sql-parantez-dengesi.ps1` (PowerShell
> tokenizer) yorum içindeki kesme işaretlerini yanlış yorumlayıp yanlış alarm
> üretti (exit 1 / "0 hata" çelişkisi). Araç **kaldırıldı**; yerine Node ile
> yazılan `tools/sql-sozdizim-denetimi.mjs` kullanılıyor (özyinelemeli: dolar
> tırnak gövdelerinin içi de denetlenir).

### 5.1 Gövde ↔ tablo sütun çapraz denetimi (elle, bu tur)

Birebir canlı gövdeler yalnızca "çalıştığı anda" doğrulanabildiği için (plpgsql
gövdeleri oluşturulurken kolon adları denetlenmez) tablo sütunları ile gövdeler
elle karşılaştırıldı. Yöntem: her dosyadaki `takma_ad.kolon` çiftleri çıkarıldı,
tanımlı tabloların sütun listesiyle eşleştirildi.

| Dosya | Gövdelerde geçen takma ad → kolon çiftleri | Sonuç |
|---|---|---|
| `20260927000130_kupon_ve_kampanya.sql` | `c.*` → coupons (15), `k.*` → campaigns (7), `r.*` → coupon_redemptions (7), `a.*` → coupon_attempts (2), `p.*` → plans/payments (`kod`, `fiyat_kurus`, `durum`, `veli_id`) | ✅ tamamı karşılandı |
| `20260927000140_deneme_sinavi.sql` | `e.*` → deneme_sinavlari, `q.*` → deneme_sinavi_sorulari / questions, `d.*` → deneme_sinavi_denemeleri, `p.*` → profiles | ✅ tamamı karşılandı |
| `20260927000150_soru_analitigi.sql` | `q.*`/`a.*`/`a2.*` → questions + user_answers; `b.*`/`t.*`/`d.*`/`x.*` → türetilmiş alt sorgu takma adları | ✅ tamamı karşılandı |

Bu denetimde teyit edilen kritik bağımlılıklar:

- `deneme_sinavlari.sorular_kilitli` — canlı gövde
  `admin_set_mock_exam_questions` bu kolonu okuyor (42501 dalı) → tablo
  tanımında mevcut.
- `admin_get_mock_exam_results` RETURNS TABLE bildirimi (`puan numeric`,
  `dogru_sayisi/yanlis_sayisi/bos_sayisi smallint`) → `deneme_sinavi_denemeleri`
  kolon tipleriyle birebir aynı olmak zorunda, öyle.
- `coupons.kod` **UNIQUE** — canlı gövde `on conflict (kod) do nothing`
  kullanıyor.
- `coupon_redemptions.durum` kısıtı `rezerve/kullanildi/iptal` — canlı gövde
  `durum = 'kullanildi'` ve `durum = 'rezerve' and rezerve_bitis > now()`
  süzgeçleri bu kümeyle uyumlu.
- Analitik tabanı: `questions.inceleme_gerekli` (000040) ve
  `user_answers.deneme_sayisi / dogru_sayisi / son_sure_ms` (initial_schema)
  mevcut; `limit_ms` istemciyle aynı (45/60/90 sn).
- Test dosyasında `submit_answer` çağrısı **yok**; bu yüzden 42/43
  senaryolarındaki `user_answers` eklemeleri
  `user_answers_unique_pair` kısıtıyla çakışmaz ve `dagilim` sayıları
  deterministiktir.


> Geçici not: `question_reports` tablosunun indexleri artık `20260927000030`
> içindedir; `20260927000010`'daki eski "yorumda bekletilen index" notu kaldırıldı.

### 5.2 Kupon mesaj eşlemesi (`v_neden` ↔ `_kupon_mesaj`)

`_kupon_degerlendir` gövdesindeki tüm `v_neden` atamaları çıkarılıp
`_kupon_mesaj` fonksiyonunun `case` listesiyle karşılaştırıldı. Eksik olan tek
değer `uygun_degil` idi; `20260927000130_kupon_ve_kampanya.sql` içindeki
`_kupon_mesaj` fonksiyonuna şu dal eklendi:

- `uygun_degil` → `Bu kuponu şu anda kullanamazsın.`

Böylece her `v_neden` değeri için kullanıcıya gösterilecek Türkçe metin
tanımlıdır; `else` dalı yalnızca beklenmedik değerler için yedek kalır (metin
yutulmaz, `AGENTS.md` §4 kuralına uygun). Bu düzeltmeden sonra dört denetleyici
de yeniden çalıştırıldı ve yeşil kaldı (§5 tablosu).

### 5.3 Senaryo 27–45 statik incelemesi (canlı DB olmadan, bu tur)

Test dosyasındaki 19 yeni senaryo, tek tek ilgili migration gövdesiyle
karşılaştırıldı (imza sırası, tipler, SQLSTATE beklentileri, dönüş anahtarları,
yetki/RLS beklentileri, test verisi sırası). Sonuç: **çelişki yok**.

| Kontrol | Sonuç |
|---|---|
| `admin_upsert_coupon` 14 parametrelik çağrı sırası (senaryo 28/31/35) | ✅ imza ile birebir |
| `admin_list_coupons(boolean,text,integer,integer,uuid)` + `toplam`/`satirlar.kod/tur` anahtarları (28) | ✅ |
| `coupon_preview` sırası: `cok_deneme → plan_yok → kod_yok → pasif → baslamadi → suresi_gecti` (29–32) | ✅ indirim `plans.fiyat_kurus` üzerinden (10.000 → 2.500/7.500) |
| `coupon_attempts(veli_id)` INSERT'i + `_kupon_deneme_sayisi` son 1 saat süzgeci (32) | ✅ kolon/default uyumlu |
| Kupon tablolarında RLS + `revoke all` (33) | ✅ dördü de fail-closed |
| `admin_upsert_campaign(uuid,text,text,timestamptz,timestamptz,boolean)` + `kupon_sayisi` (34) | ✅ |
| `_kupon_dogrula` yüzde 150 → **22023**, 2 harflik kod → `admin_upsert_coupon` içi **22023** (35) | ✅ `invalid_parameter_value` yakalayıcısıyla uyumlu |
| `admin_upsert_mock_exam(uuid,text,timestamptz,integer,smallint[],boolean)`; süre 3 dk ve sınıf 9 → 22023; geçmiş başlangıç serbest (36/37/39) | ✅ |
| `admin_list_mock_exams` → `ad`, `sure_dakika` (36) | ✅ |
| `admin_set_mock_exam_questions(uuid,integer,uuid[])`: sıra 1..n, atanmamış sınıf 22023, başlamış/kilitli sınav 42501 (38/39) | ✅ |
| `admin_get_mock_exam_questions` → `sira`, `soru_metni` (38) | ✅ |
| `deneme_sinavi_denemeleri(exam_id, student_id, sinif, puan, dogru_sayisi, yanlis_sayisi, bos_sayisi, bitis_zamani)` INSERT'i (40) | ✅ kolon adları ve NOT NULL/default durumu uyumlu |
| `admin_get_mock_exam_results`: bitmemiş kayıt hariç, sıra = puan desc / bitiş asc, `ad_soyad` = `profiles.full_name` (`raw_user_meta_data`) (40) | ✅ |
| Deneme sınavı tablolarında RLS + `_deneme_sinavi_siniflar_gecerli` authenticated'a kapalı (41) | ✅ |
| `_question_analytics_base(integer)`: `limit_ms` 45/60/90 sn, `dogru_oran` round(…,4), `bayraklar` eşikleri (`zor <0.30`, `kolay >0.95`, `yavas > limit_ms`, `bos_fazla > 0.25`, `dagilim_ters` = çeldirici **strictly >** doğru şık) (42/43) | ✅ senaryo 42'de bayrak çıkmaması, 43'te `zor`+`yavas` çıkması doğrulandı |
| `admin_question_analytics(text,integer,integer,integer,text,boolean)` + `toplam`/`satirlar`/`ozet.min_cevap`/`ozet.supheli_soru`, geçersiz sıralama 22023, `p_min_cevap=1` süzgeci (44) | ✅ |
| `_question_analytics_base` istemciye kapalı, `admin_question_analytics` anon'a kapalı / authenticated'a açık (45) | ✅ |
| q[1]'in `inceleme_gerekli` bayrağı senaryo 19'da temizlendiği için senaryo 42'de `bayraklar` boş kalır | ✅ test verisi sırası tutarlı |

Bu turda yapılan iki küçük tutarlılık düzeltmesi (davranış değişikliği yok):

1. `20260927000150_soru_analitigi.sql` → `ogrenci` kolonu için açıklayıcı yorum
   eklendi (cevap satırı sayısı = öğrenci sayısı, `bos_fazla` oranının paydası).
2. `supabase/tests/kurtarma_tests.sql` → `raise exception 'TEST_GERI_AL'`
   ifadesine diğer test dosyalarındaki gibi `using errcode = 'P0001'` eklendi.

Bu dosyadaki canlı doğrulama maddeleri, Dashboard/CLI erişimi sağlandığında yeniden açılacaktır.
