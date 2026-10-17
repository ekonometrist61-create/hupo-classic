# Bildirim kampanyası ve kutu testi

Gerçek migration zincirini (`supabase/migrations`) WASM Postgres (PGlite) üzerinde çalıştırır.
Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.

Kapsam: duyuru kategorileri ve pazarlama koruması, kutu dağıtımı (`duyuru_inbox_yayinla`),
`get_bildirimler` görünürlüğü, okundu kalıcılığı, banner zamanlaması, pazarlama push kampanyası
(`kampanya_push_gonder`: segment, elle seçilen veli listesi, push izni, haftalık limit, sessiz saat,
öğrenci dışlama, cihaz kuyruğu), migration'ların idempotent olması.

Çalıştırma:

```powershell
cd supabase\tests\bildirim_kampanya
npm install
npm test
```

Beklenen son satır: `SONUÇ: 54 geçti, 0 başarısız`.

Notlar:
- `stubs.sql` ve `stubs2.sql` Supabase ortamını taklit eder (auth.uid, roller, pg_cron, bağımlı tablolar).
  Gerçek migration'lar değiştirilmeden yüklenir; stub'lar yalnızca dış bağımlılıkları karşılar.
- Testte yetki gerçekçidir: `authenticated` rolü ile çalışır, istemcinin doğrudan `notifications` update'i
  reddedilir (eski web zilinin hatasının regresyon testi).
- Bu test pgTAP değildir. `supabase test db` ile çalışmaz; repo `supabase/tests` düzeni için özel koşucudur.
