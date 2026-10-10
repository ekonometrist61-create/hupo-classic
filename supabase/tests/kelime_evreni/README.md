# Kelime Evreni — yerel SQL testleri (PGlite)

Docker olmadan migration ve RLS senaryolarını çalıştırır. Gerçek Supabase'e bağlanmaz ve
hiçbir şeyi uzak veritabanına yazmaz.

```powershell
cd supabase\tests\kelime_evreni
npm install
npm test
```

Beklenen son satır: `SONUÇ: 40/40 senaryo geçti`.

## Ne kapsar, ne kapsamaz

- `stubs.sql`: `auth.uid()`, `profiles`, `is_admin()`, `is_parent_of()`, `current_user_role()`,
  `log_admin_action()`, `award_xp_and_streak()` için çağrı sözleşmesini taklit eder.
  Supabase'in varsayılan `anon` / `authenticated` yetkileri de açılır; migration'ın `revoke`
  satırları bunu kapatmalıdır.
- Kapsar: tablo yetkileri, RLS, RPC yetkileri, idempotency, XP çağrısı kuralı, ustalık tavanı,
  hız sınırı, dört göz, onay akışı, veli gizliliği.
- Kapsamaz: gerçek `award_xp_and_streak` (seri, lig, bildirim), eşzamanlılık yükü, gerçek
  Supabase rolleri ve `pg_cron`. Bunlar staging'de `supabase db reset` ve `supabase test db`
  ile doğrulanmalıdır.

## Yeni senaryo eklemek

`../kelime_evreni_tests.sql` içine yeni blok ekleyin: `no := no + 1; senaryo := '...';` ve
`gecti` / `detay` atamaları. Doğrudan tablo okuması gerekiyorsa `pg_temp.kelime_sorgu_text(...)`
kullanın (süper kullanıcı olarak okur).
