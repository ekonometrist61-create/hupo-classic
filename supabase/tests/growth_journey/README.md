# Growth journey motoru testi

Gerçek migration zincirini (`20261014000000` → `20261015000000` → `20261099000000`) WASM Postgres
(PGlite) üzerinde çalıştırır. Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.

Kapsam:
- giriş (`growth_journey_giris_al`): aynı journey + hane için tekrar kayıt açılmaz; duraklatılmış,
  taslak journey ve bloklu hane reddedilir
- bayrak `growth_journey_motoru_acik` kapalıyken `growth_journey_ilerlet` hiçbir satıra dokunmaz
- mesaj adımı yalnız `growth_message_log`'a `kuyrukta` yazar; izinsiz veya bastırılmış hane `izin_yok` alır
- SMS ve WhatsApp kuyruğa alınmaz (`kanal_kapali`)
- bekleme adımı `next_run_at` değerini ileri alır; vadesi gelmeyen kayıt işlenmez
- desteklenmeyen adım kaydı `failed` yapar ve `error` alanını doldurur
- son adımdan sonra kayıt `completed` olur
- anon ve authenticated fonksiyonları çalıştıramaz; service_role çalıştırabilir
- migration ikinci kez çalıştırılınca açık bayrak kapanmaz ve zamanlayıcı çoğalmaz

Çalıştırma (PowerShell):

```powershell
cd supabase\tests\growth_journey
npm install
npm test
```

Beklenen son satır: `SONUÇ: 40 geçti, 0 başarısız`.

Notlar:
- `stubs.sql` Supabase ortamını taklit eder (auth, roller, pg_cron, profiles, abonelik ve plan tabloları).
  Gerçek migration dosyaları değiştirilmeden yüklenir.
- `create extension` satırları (pgcrypto, pg_cron) yalnızca harness'ta yorum satırına çevrilir. PGlite
  bu eklentileri içermez; gen_random_uuid ve sha256 PostgreSQL yerleşiğidir.
- Bu test pgTAP değildir. `supabase test db` ile çalışmaz.
