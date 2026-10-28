# Growth kural tabanlı öneri üreticisi testi

`growth_oneri_uret()` (migration `20261102000000_growth_oneri_uretici.sql`) için PGlite testi.
Gerçek migration zinciri (`20261014000000` → `20261027000000` → `20261102000000`) WASM Postgres
üzerinde çalışır. Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.

Kapsam: dört kural (deneme bitiyor, pasif aile, ödeme sorunu, ilk temas), bayrak kapalıyken 0,
idempotentlik (açık öneri varken tekrar üretilmez), reddedilen önerinin yeniden üretilebilmesi,
`p_limit` sınırı, gerekçe metinlerinde çocuk/PII/garanti ifadesi olmaması, `anon` ve
`authenticated` çağıramaz, security definer ve `search_path = ''`, pg_cron kaydı.

Çalıştırma:

```powershell
cd supabase\tests\growth_oneri
npm install
npm test
```

Beklenen son satır: `SONUÇ: 47 geçti, 0 başarısız`.

Notlar:
- `stubs.sql` yalnızca dış bağımlılıkları karşılar (auth, roller, pg_cron, core tablolar:
  profiles, subscriptions, plans, payments, iletisim_tercihleri, deneme_donemleri ve iki tetikleyici
  tablosu). Growth migration'ları değiştirilmeden yüklenir.
- `pgcrypto` PGlite eklentisi olarak yüklenir (`20261014` içindeki `create extension` için).
- pg_cron gerçek değildir: test, `cron.job` kaydını stub üzerinde doğrular. Gerçek zamanlayıcının
  Supabase'de çalıştığı bu testle doğrulanamaz.
- Bayrak açma/kapama testte doğrudan `update public.growth_oneri_ayar` ile yapılır (yönetim RPC'si yok).
