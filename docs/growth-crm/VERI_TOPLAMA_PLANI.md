# Müşteri 360 — Veri Toplama Katmanı Planı

Tarih: 2026-10-13
Amaç: Web, mobil uygulama ve pazarlama formlarından (ör. herkese açık deneme sınavı ön kaydı) gelen kişi verisini tek müşteri kartında (`growth_households`) toplamak; sonra e-posta / SMS / push / dijital reklam kitleleri için kullanılabilir kılmak.

## Mevcut durum (2026-10-13)
- Müşteri 360 ekranı, RPC'ler (`admin_musteri_360_*`), tablolar ve view'lar HAZIR (`20261014*`).
- EKSİK: `growth_households` yalnızca admin elle oluşturunca dolar. Hiçbir kaynak otomatik beslemez.

## Tek kural: tek müşteri kartı, çok kaynak
Kişi e-posta (küçük harf) ile eşlenir. Aynı kişi önce deneme sınavına, sonra landing formuna, sonra uygulamaya kayıt olsa BİR kart olur; her temas `growth_events` satırı olarak kalır.

| Kaynak | Ne zaman | Karta ne yazar | İzin |
|---|---|---|---|
| `profiles` (veli) | hesap açılınca | ad, core_parent_user_id, lifecycle `registered` | `iletisim_tercihleri` (mevcut) |
| `profiles` (öğrenci) | hesap açılınca / veliye bağlanınca | `growth_customer_people` (öğrenci, sınıf) | — |
| `subscriptions` | değişince | plan, abonelik durumu, lifecycle `trial`/`paid`/`churned` | — |
| `payments` | değişince | `growth_financial_transactions` + ciro toplamları | — |
| `veli_adaylari` | landing formu | lifecycle `lead`, kaynak | `pazarlama_izni` → e-posta |
| `deneme_sinavi_on_kayitlari` | deneme ön kaydı | veli adı, telefon, çocuk (sınıf), kaynak `deneme_on_kayit` | e-posta / SMS / telefon ayrı ayrı + sürüm |

## Kararlar
1. **İzin asla tahmin edilmez.** Kaynakta açık kutu yoksa durum `unknown` kalır. Hesabı olan veli için kaynak `iletisim_tercihleri`; hesabı olmayan kişi için yeni `growth_household_izinleri` (kanal, izin, kaynak, sürüm, zaman). `growth_consents` tablosu hâlâ YOK.
2. **Doldur, ezme.** Senkron yalnızca boş alanı doldurur; admin'in elle yazdığı değeri (ad, telefon, sahip, not) ezmez. İlk temas kaynağı (`source`, UTM) bir kez yazılır.
3. **Çocuk verisi minimum.** Çocuk yalnızca takma ad/ad + sınıf olarak `growth_customer_people`'a yazılır; pazarlama kitle çıkarımına dahil edilmez.
4. **Müşteri no:** `HUP-000001` biçimi, sıra numarasıyla.
5. **Yazma yolu tetikleyici + SECURITY DEFINER.** İstemciye yeni yazma yetkisi verilmez. Tetikleyici hatası asıl işlemi (kayıt, ödeme) bozmaz: hata yutulur, `RAISE WARNING` ile loglanır.
6. **Uzak veritabanına uygulama ayrı onaydır.** Migration yazılır ve test edilir; `db:deploy` kullanıcı onayıyla.

## Fazlar
- **V1 (bu iş):** migration (senkron + tetikleyici + geri doldurma + izin tablosu), `admin_musteri_360_listele` kaynak/izin filtresi, "Veri toplama" özeti RPC'si, panelde kaynak/izin filtreleri ve özet kartları.
- **V2:** Flutter uygulamasından yetkili kullanıcı olayları (`growth_olay_kaydet`, izinli olay listesiyle), UTM yakalama landing + /ogrenci.
- **V3:** Kitle dışa aktarımı (segment → e-posta/SMS/push listesi, yalnızca `granted`), iletişim kampanyalarına bağlama.
- **V4:** Meta / Google reklam kitlesi (hash'li e-posta), yalnızca açık izinli kayıtlar.

## Kabul kriterleri (V1)
- Yeni veli hesabı açılınca 360 listesinde kart görünür.
- Deneme ön kaydı yapan kişi kartta çocuk (sınıf), telefon, kanal izinleri ve kaynakla görünür; izin verilmeyen kanal `denied`.
- Aynı e-posta ikinci formla gelince kart çoğalmaz, olay eklenir.
- Ödeme `basarili` olunca ciro ve ödeme sayısı güncellenir, lifecycle `paid` olur.
- Admin'in elle girdiği ad/telefon senkronla değişmez.
- Mevcut veri geri doldurulur; geri doldurma tekrar çalışsa çoğaltmaz.
