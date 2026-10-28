# A/B deney olay ingest'i: tasarım taslağı

Durum: **taslak, kod ve veritabanı değişikliği yok.** Tarih: 2026-10-28. Amaç: `admin_ab_karar_kaydet` içindeki sayıların (kontrol/deney oranları, n) yönetici girişi yerine veritabanındaki toplulaştırılmış olaylardan hesaplanabilmesi.

## 1. Neden gerekli
Şu an karar kaydındaki sayılar yönetici tarafından girilir ve doğrulanmaz (`ab_karar` sınırı). Bağımsız doğrulama için dönüşüm olaylarının deney kollarıyla eşlenmiş toplu hali gerekir.

## 2. Gizlilik sınırı (zorunlu)
- Olay tablosunda kullanıcı kimliği tutulmaz. Kullanıcı yalnızca kol ataması sırasında (ab_kol) ve olay anında bir kez kullanılır; saklanan şey (deney, kol, metrik, gün) ve sayıdır.
- Kullanıcı başına "ilk dönüşüm" tekilliği için yaklaşım gerekir (aşağıda karar D1). Tekilliği kimlik üzerinden kurmak, kimliği saklamak anlamına gelir; bu kabul edilmez.
- Küçük hücre kuralı: kol başına n < 30 olan günler raporlanmaz; çocuk verisi ayrı tutulur, deney metriklerine girmez.

## 3. Önerilen yaklaşım (karar bekliyor)
- Uygulama (web/mobil) dönüşümde `ab_olay_kaydet(deney_id, metrik, kol_hash?)` çağırır. Kol, istemcide değil sunucuda `ab_kol` ile belirlenir; istemci kolu gönderemez.
- Sunucu tarafı tekillik: `ab_kullanici_olay` yerine, deney + kullanıcı için kısa ömürlü bir tekillik kaydı tutulur ve 7 gün içinde silinir. Sadece "bu kullanıcı bu metriği bu deneyde zaten verdi mi" bilgisi için. Silme işi pg_cron ile.
- Günlük toplulaştırma: `ab_olay_gunluk(deney_id, kol, metrik, gun, n, x)`; ham olay tablosu toplulaştırmadan sonra temizlenir.
- Analiz: `admin_ab_sayilar(deney_id)` toplulaştırılmış n ve x döndürür; karar formu bunları otomatik doldurabilir.

## 4. Açık kararlar (kullanıcı)
- **D1 (tekillik):** 7 günlük geçici tekillik kaydı kabul edilir mi? Alternatif: tekillik olmadan olay sayımı (kullanıcı başına birden fazla olay sayılır; metrik tanımı buna göre yazılır).
- **D2 (birincil metrik):** İlk deneme için hangi metrik? (önerim: 7 gün içinde ücretli ödeme oranı)
- **D3 (uygulama tarafı):** Olay çağrısı web ve mobilde mi, yalnızca web'de mi? Mobil deneyler ayrı onay gerektirir.
- **D4 (saklama):** Günlük toplulaştırılmış tablo ne kadar tutulur? (önerim: deney bitişinden 400 gün; hukuk onayıyla)

## 5. Aşamalar (her biri ayrı onaylı)
| Aşama | İçerik | Kapı |
|---|---|---|
| I0 | Bu taslağın kararları | Kullanıcı yanıtı (D1–D4) |
| I1 | Toplulaştırılmış tablo + `ab_olay_kaydet` + testler | Deploy onayı |
| I2 | Tekillik temizleme işi (pg_cron) + testler | Deploy onayı |
| I3 | `admin_ab_sayilar` ve karar formunda otomatik doldurma | Deploy onayı |
| I4 | Uygulama entegrasyonu (web, sonra mobil) | Ürün onayı, sürüm planı |

## 6. Kabul ölçütleri
- Veritabanında kullanıcı kimliği içeren kalıcı tablo yok (şema testi).
- İstemci kol bilgisi gönderemez (test).
- n < 30 günler raporlanmaz (test).
- Tekillik kaydı 7 gün sonra silinir (test: zaman ilerletme).
