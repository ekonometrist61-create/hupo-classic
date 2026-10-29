# Growth iletişim uygunluk kapısı testi

`growth_iletisim_uygun_mu` (20261101) için: izin kapısı, sessiz saat, günlük ve haftalık
sıklık sınırı, yetki (anon / authenticated çağıramaz) ve sertleştirme kontrolleri.

Gerçek migration zincirini (`supabase/migrations`) WASM Postgres (PGlite) üzerinde çalıştırır.
Docker gerektirmez. Supabase'e bağlanmaz ve uzak veritabanına dokunmaz.

Çalıştırma:

```powershell
cd supabase\tests\growth_uygunluk
npm install
npm test
```

Notlar:
- `stubs.sql`, `bildirim_kampanya/stubs.sql` ve `stubs2.sql`'in kopyasıdır; ek olarak growth CRM
  çekirdeğinin (20261014000000) kullanılan iki tablosunu (`growth_households`, `growth_message_log`)
  sade biçimde içerir. Yabancı anahtarlar `growth_campaigns` / `growth_journeys` yerine düz uuid'dir.
- Sessiz saat ve haftalık sınır `iletisim_ayarlari` satırından okunur. Test her senaryodan önce
  satırı 21:00-09:00 / haftalık 3 değerlerine çeker. Satır yoksa fonksiyon aynı varsayılanları kullanır.
- Günlük sınır `growth_iletisim_limitleri` tek satırından okunur (varsayılan 1).
- Bu test pgTAP değildir. `supabase test db` ile çalışmaz.
