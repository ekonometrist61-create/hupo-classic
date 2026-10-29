# Veri İhlali Müdahale Prosedürü (KVKK m.12)

**Durum:** TASLAK. Hukukçu onayı bekliyor.
**Son güncelleme:** 2026-10-29
**Sorumlu:** [Veri sorumlusu adına görevli kişi — doldurulacak]
**Dayanak:** Gizlilik metni (`web-panel/src/lib/legal/content.ts`, "Güvenlik" bölümü) "en geç 72 saat içinde Kişisel Verileri Koruma Kurulu'na bildirim" sözü verir. Bu belge o sözü yerine getirecek iş akışını tanımlar.

## 1. Ne sayılır?

Kişisel verinin hukuka aykırı biçimde üçüncü kişilerin eline geçmesi. Örnekler:

- Yetkisiz erişim (ör. bir tablonun anonim kullanıcıya açılması, ele geçirilmiş hesap)
- Verinin yanlış alıcıya gönderilmesi (ör. yanlış veliye bildirim)
- Sızıntı: anahtar, parola veya yedek dosyanın dışarı çıkması
- Kayıp veya yanlışlıkla silinme

## 2. Tespit kaynakları

- Supabase kayıtları ve Edge Function günlükleri (`payments-*`, `eposta-gonder`, `olay-kutusu-gonder`)
- Sentry hata ve uyarıları (kişisel veri temizliği açık olmalı)
- Kullanıcı, veli veya Kurul'dan gelen bildirimler (iletişim e-postası)
- Anahtar sızıntısı uyarıları (GitHub secret scanning, Vercel, Supabase)
- Üçüncü taraf bildirimleri (iyzico, Brevo, Resend, Firebase)

## 3. Süreler ve adımlar

| Süre | İş | Sorumlu |
|---|---|---|
| Hemen (0–1 saat) | Olayı kayda geçir (tespit zamanı, kaynak, etkilenen sistem). Erişimi kes: sızan anahtarı döndür, tabloyu veya fonksiyonu kilitle. | Teknik sorumlu |
| 0–24 saat | Kapsamı belirle: hangi veri, kaç kişi, çocuk verisi var mı, olası zarar. Delilleri koru (log dışa aktarımı, silme yok). | Teknik sorumlu + hukuk |
| En geç 72 saat | Kişisel Verileri Koruma Kurulu'na bildirim (Kurul'un resmi ihlal bildirim formu, kvkk.gov.tr). Süre aşılırsa gecikme gerekçesi yazılır. | Veri sorumlusu + hukuk |
| Gecikmeden | Etkilenen kişilere bildirim. Çocuk verisinde bildirim veli üzerinden yapılır. | Ürün + hukuk |
| Olaydan sonra 30 gün | Kök neden analizi, düzeltme, bu prosedürün ve gizlilik metninin güncellenmesi. | Teknik sorumlu |

## 4. Kurul'a bildirimde bulunması gerekenler

- İhlalin gerçekleşme ve tespit tarihi
- Etkilenen kişi kategorileri ve yaklaşık sayısı; veri kategorileri (çocuk verisi ayrıca)
- Olası sonuçlar
- Alınan ve planlanan önlemler
- İletişim kişisi

## 5. İhlal defteri (her olay için bir kayıt)

Kayıt silinmez; değişiklik gerekirse eklenir.

```
No:                  IHL-AAAA-NNN
Tespit zamanı:       
Kaynak:              (log / kullanıcı bildirimi / üçüncü taraf / Kurul)
Etkilenen sistem:    
Veri kategorileri:   
Etkilenen kişi:      (sayı, çocuk verisi var mı)
Olası sonuç:         
Alınan önlemler:     
Kurul bildirimi:     (tarih / gerekçe)
Kişi bildirimi:      (tarih / kanal)
Kök neden ve düzeltme:
```

## 6. Etkilenen kişilere bildirim (taslak)

> Merhaba, [tarih] tarihinde [olayın kısa açıklaması] fark edildi. Bu olayda [veri kategorileri] etkilenmiş olabilir. Şunları yaptık: [önlemler]. Senin yapabileceklerin: [ör. parolanı değiştir]. Sorun için [iletişim e-postası] adresine yazabilirsin.

## 7. Projenin bugünkü durumu (2026-10-29 kontrolü)

| Konu | Durum | Not |
|---|---|---|
| Tüm tablolarda RLS | Açık | Statik tarama 163 tablo; okuma ve sözlük tabloları döngü migration'ında kapatılmış. |
| `anon` erişimi | Kısmen kapalı | `kullanim_olaylari_gonder` için kapatma migration'ı (20261108) henüz uzak veritabanında uygulanmadı. |
| E-posta doğrulama | Yerelde açıldı | `supabase/config.toml` güncellendi; uzak projede Dashboard'dan açılmalı. |
| Servis anahtarı | Yalnızca sunucuda | `service_role` istemciye ve repoya girmez (AGENTS.md §5). |
| Sentry kişisel veri temizliği | Doğrulanmadı | Gizlilik metni söz veriyor; yayından önce kontrol edilmeli. |
| Yedekler | Doğrulanmadı | Şifreli Google Drive yedeği ve 30 günlük saklama kurulumla birlikte doğrulanmalı. |
