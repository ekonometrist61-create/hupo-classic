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

---

## 3. 🚫 Blokaj — bunlar olmadan `supabase db reset` HATA verir

Aşağıdaki nesneler canlı veritabanında var ama diskteki migration'larda **yok**.
Uydurulmadı; canlıdan alınması gerekiyor.

| Nesne | Tür | Kim kullanıyor |
|---|---|---|
| `public.grade_changes` | tablo | `set_my_grade` (30 gün / 24 saat kuralı) |
| `public.question_reports` | tablo | `report_question` (kişi başı 20/gün) |
| `public._desteklenen_siniflar()` | fonksiyon | `get_supported_grades` (`language sql` → **oluşturma anında doğrulanır**) |
| `public._sinif_yaz(uuid, integer, text)` | fonksiyon | `set_my_grade` |
| `public._refresh_question_flag(uuid)` | fonksiyon | `report_question` |
| `public.admin_set_daily_challenge(...)` | fonksiyon | yönetici paneli (günlük havuzu doldurma) |
| `carpim_sifreleri` **içerik verisi** (10–12 şifre) | veri | `get_carpim_sifreleri` |

> Not: `user_badges` ve `evaluate_badges` aslında **mevcut**
> (`20260920000000_initial_schema.sql` ve `20260920000500_badges.sql`).
> TASKS.md'deki "eksik" kaydı bu iki kalem için geçersizdir.

### Kurtarma yolu (canlı Supabase, `ccozfrpnvyrnktpffkwo`)

Dashboard → SQL Editor:

```sql
-- 1) Tablo/kolon tanımları
select table_name, column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public'
  and table_name in ('grade_changes', 'question_reports')
order by table_name, ordinal_position;

-- 2) Kısıtlar
select conrelid::regclass as tablo, conname, pg_get_constraintdef(oid) as tanim
from pg_constraint
where connamespace = 'public'::regnamespace
  and conrelid::regclass::text in ('public.grade_changes', 'public.question_reports');

-- 3) Fonksiyon gövdeleri (birebir)
select pg_get_functiondef(oid)
from pg_proc
where pronamespace = 'public'::regnamespace
  and proname in ('_desteklenen_siniflar', '_sinif_yaz',
                  '_refresh_question_flag', 'admin_set_daily_challenge');
```

Alternatif (önerilen, tam sonuç): `supabase link --project-ref ccozfrpnvyrnktpffkwo`
ardından `supabase db pull`.

---

## 4. Geçici not

`question_reports` tablosu gelene kadar ilgili index
(`question_reports_durum_idx`) `20260927000010` içinde **yorum satırında**
tutulmaktadır. Tablo kurtarıldığında yorum kaldırılmalıdır.
