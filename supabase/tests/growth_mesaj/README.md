# Growth mesaj günlüğü ve şablon render testi

Kapsam:
- `supabase/functions/_shared/sablon.ts` (saf `sablonDoldur`): {{ad}} / {{ ad }} yerleştirme,
  bilinmeyen değişkenin yer tutucuda kalması ve `eksikDegiskenler` listesi, HTML kaçışı (`htmlKacis`).
- `supabase/migrations/20261100000000_growth_mesaj_gunlugu.sql`: `growth_mesaj_kaydet`,
  `growth_mesaj_durum_guncelle`, kampanya sayaçları için tetikleyici, durum kısıtı.
  Testte yetki (yalnız service_role), doğrulama, tek sefer sayım, doğrudan UPDATE/INSERT savunması ve
  migration'ın idempotent olması denenir.

Gerçek core (`20261014000000_growth_crm_core.sql`) ve mesaj migration'ı WASM Postgres (PGlite)
üzerinde çalışır. Dış bağımlılıklar (`profiles`, `iletisim_tercihleri`, `subscriptions`, `plans`,
`student_stats`) `stubs.sql` ile karşılanır. Docker gerekmez. Supabase'e bağlanmaz, uzak veritabanına
dokunmaz. pgTAP değildir; `supabase test db` ile çalışmaz.

Çalıştırma (PowerShell):

```powershell
cd supabase\tests\growth_mesaj
npm install
npm test
```

`npm test` iki adım çalıştırır:
1. `node --test ../../functions/_shared/sablon.test.ts` (sablon birim testleri, 13 test).
   Deno ile: `deno test supabase/functions/_shared/sablon.test.ts` (aynı dosya, `node:test` kullanır).
2. `node test.mjs` (PGlite). Beklenen son satır: `SONUÇ: 57 geçti, 0 başarısız`.

Notlar:
- `stubs.sql` içinde `service_role` BYPASSRLS taşır (Supabase'teki gibi). Diğer roller RLS ve REVOKE ile sınırlıdır.
- Core migration `create extension pgcrypto` içerir; PGlite'ın `contrib/pgcrypto` paketi yüklenir.
- Durum kısıtı `NOT VALID` eklenir: mevcut satırlar denetlenmez, yeni satırlar denetlenir.
