# KURTARMA DURUMU — Supabase (backend)

> Bu dosya, `supabase/migrations/` altındaki **kurtarma zincirinin durumunu** ve
> `supabase db reset` / `supabase test db` çalıştırılmadan önce tamamlanması
> gereken eksikleri listeler.
> Son güncelleme: 27 Eylül 2026
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

## 3. ⏳ Hâlâ eksik olanlar (canlıdan alınacak)

`20260927000030_missing_objects_recovery.sql` ile `grade_changes`,
`question_reports`, `_desteklenen_siniflar()`, `_sinif_yaz()`,
`_refresh_question_flag()` ve `admin_set_daily_challenge()` **kurtarıldı**.
Geriye yalnızca şu dört kalem kaldı:

| Nesne | Tür | Etki | Getirme sorgusu |
|---|---|---|---|
| `public.question_quality_config` | tablo | `report_question()` **çalışma anında hata verir** | §4.1 |
| `public.questions.inceleme_gerekli` | kolon | `_refresh_question_flag()` çağrılınca hata verir | §4.5 |
| `profiles` sınıf kuralı | trigger | 30 gün / 24 saat kuralı uygulanmaz | §4.2 |
| `grade_changes` / `question_reports` RLS politikaları | politika | Şu an fail-closed (kimse göremez) | §4.3 |
| `carpim_sifreleri` içerik verisi (10–12 şifre) | veri | Şifre listesi boş görünür | §4.4 |

> Not: `user_badges` ve `evaluate_badges` aslında **mevcut**
> (`20260920000000_initial_schema.sql` ve `20260920000500_badges.sql`).
> TASKS.md'deki "eksik" kaydı bu iki kalem için geçersizdir.
> `app_settings` de mevcut (`20260920001100_payments_iyzico.sql`).

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

---

## 5. Geçici not

`question_reports` tablosunun indexleri artık `20260927000030` içindedir;
`20260927000010`'daki eski "yorumda bekletilen index" notu kaldırıldı.
