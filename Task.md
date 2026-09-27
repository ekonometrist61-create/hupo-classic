# Task — Proje toparlama ve doğrulama
> Ana çalışma dosyası: `MASTER_BRIEF.md`
> Kurallar: `AGENTS.md`
> Temizlik kararları: `TEMIZLIK_RAPORU.md`

## Durum
- [x] APK telefondan alındı ve `kurtarilan/` içine kaydedildi.
- [x] APK'daki fontlar `mobile-app/assets/fonts/` içine geri getirildi.
- [x] `MASTER_BRIEF.md` oluşturuldu.
- [x] `AGENTS.md` oluşturuldu.
- [x] `TEMIZLIK_RAPORU.md` oluşturuldu.
- [x] `kurtarilan/SEMA_DOKUM.sql` düzeltildi (`polname`, güvenli tablo kontrolü).
- [ ] Supabase SQL Editor çıktısı alınacak ve eksik RPC migration'ları yazılacak.
- [x] `Silinecekler/` karantina klasörü oluşturuldu; içerik kalıcı olarak silinmedi.
- [ ] Web paneli lint ve build doğrulanacak. (Lint: mevcut 15 hata + 1 uyarı; build 120 sn içinde bitmedi.)
- [ ] Admin paneli tarayıcıda açılıp doğrulanacak. (Dev sunucusu ortamda kalıcı başlatılamadı.)
- [ ] Mobil uygulama analyze ve test doğrulanacak. (Flutter, sistem PATH'inde Git olmadığı için başlayamadı.)

## Son test notu
Web bağımlılıkları test için kuruldu, sonra tekrar `Silinecekler/` içine taşındı.
Üretim koduna test sırasında eklenen bir dosya bırakılmadı. Web lint hataları mevcut
kaynakta; özellikle `any` kullanımları ve effect içinden senkron state güncellemeleri.
Flutter testi için Git kurulmalı veya PATH'e eklenmeli.

## Çalışma sırası
1. **Supabase:** Güncel `kurtarilan/SEMA_DOKUM.sql` dosyasını SQL Editor'da çalıştır.
2. Sonuçları kaydet; eksik RPC ve tablo tanımlarını migration olarak ekle.
3. `Silinecekler/` klasörünü kontrol et; içeriği hemen silme.
4. Web panelini `npm install`, `npm run lint`, `npm run build` ile doğrula.
5. Admin panelini tarayıcıda `/tr/yonetim` ile doğrula.
6. Mobilde `flutter pub get`, `flutter analyze`, `flutter test` çalıştır.
7. Hataları düzelttikten sonra temiz proje durumunu güncelle.

## Katman bağımlılığı
`Supabase migration/RPC` → `mobile-app` ve `web-panel` → ortak mesajlar.
Supabase sonucu alınmadan yeni mobil özelliklerde RPC gövdeleri uydurulmayacak.

## Not
`Silinecekler/` geçici karantina alanıdır. Bu klasör içindeki hiçbir şey, kullanıcı
son kontrolünü yapmadan kalıcı olarak silinmeyecek.
