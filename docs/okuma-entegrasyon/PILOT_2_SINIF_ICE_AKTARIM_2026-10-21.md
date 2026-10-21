# Pilot 2. sınıf: uzak veritabanına içe aktarım (2026-10-21)

Önceki adım: `PILOT_2_SINIF_URETIM_2026-10-21.md`. Bu adımda kullanıcı onayı ile uzak DB'ye yazıldı.

## 1. Uzak veritabanı

Uygulanan migration'lar (`npm run db:deploy`, önce `db:preview` ile yalnız bu iki dosya bekledi):

| Migration | İçerik |
|---|---|
| `20261058000000_okuma_paket_fis_kodu.sql` | Paket doğrulayıcısı `hikaye.fis_kodu` (HR-000) alanını kabul eder. Fiş tablosuna `hikaye_slug` eklenir. Doğrulayıcı tanımı 20261051 sürümünden alınır (düşün alanı korunur). |
| `20261059000000_okuma_pilot2_icerik.sql` | Yönetici profiliyle: pilot sözlük (39 girdi, 39 yuva), 15 fiş (HR-001…HR-017), 15 taslak paket. Fişler hikâyelere bağlanır. Bir adım başarısız olursa işlemin tamamı geri alınır. |

Sonuç: `db:preview` → "Remote database is up to date".

Beklenen durum (yerel provada doğrulandı): 15 hikâye taslak, denetim pending; 15 fiş `hikaye_slug` ile bağlı; sözlük yazıldı. Yayın bayrağı (`okuma_ayarlari`) değişmedi; hikâye yayınlanmadı.

## 2. Hikâye alanları (içe aktarıma dikkat edilenler)

| Alan | Durum |
|---|---|
| Fiş kodu | `fis_kodu` (front matter) → paket → sürüm içeriği; fiş tablosunda `hikaye_slug` ile bağlantı. |
| Okuma süresi | Derleyici hesaplar (`tahmini_sure_dk`), 2. sınıf hızı 60 kelime/dk, yukarı yuvarlanır. |
| Tanıtım ve merak metni | `tanitim` (en çok 160 karakter), her hikâyede. |
| Tür | `tur` (gizem, macera, bilim, doğa, mizah). |
| Öğrenilen kelimeler | Her hikâyede 2 kelime hedefi (`lexeme`), 30 yuva (`s2_*`). |
| Öğrenilen kavramlar | Her hikâyede 1 kavram hedefi (`concept`, kimlik `kavram_hrNNN`): 15 kavram. |
| Deyim / atasözü | 9 hikâyede 1 atasözü (`proverb`, `{atasozu:ata_*}`); diğer 6 hikâyede doğal yerleşmediği için yok. |
| Hikâye içi işaretler | Her hikâyede 1 `{isaret:kod}` (16 onaylı kod). Derleyici kavram ikonu eklemez (kavram sözlüğü boş). |
| Resimler | **Yok.** Raster illüstrasyon üretilmedi. Uygulama, tür renginde yedek sahneyi gösterir (`OkumaSahne`). Raster kararı ayrıdır. |

## 3. Kalan işler

1. Yayın: hiçbir hikâye yayında değil. Ajan A/B denetimi ve insan okuması yapılmadı.
2. Telif: A ve K kaynaklı hikâyeler (HR-005, 006, 007, 008, 010) için hak kaydı ve hukuk onayı yok.
3. Fiş: 120 katalogdan yalnız 15 pilot fiş yazıldı. Kalan 105 fiş yazılmadı; ayrı onay gerekir.
4. Resimler: raster illüstrasyon kararı (maliyet ve stil onayı) bekliyor.
5. Uzunluk: kullanıcı kararıyla olduğu gibi kalır (yaklaşık 160–220 kelime); sonraki dalgalarda dikkat edilecek.
