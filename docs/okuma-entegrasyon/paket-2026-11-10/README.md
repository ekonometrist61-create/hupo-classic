# İçe aktarma paketleri · 2026-11-10

Kaynak: `icerik/okuma/hikaye/*.hikaye.md`. Paketler, şema doğrulaması için derleyici `derle` ile üretildi (`C:\Dev\Senin Hikayen - HupoRead\atolye\src\cli.ts`). Dayanak alanı paket şemasında yok; derleme kopyalarında kaldırıldı, repo dosyalarında duruyor.

## Derlenen 18 paket (bu klasörde)

HR-024, 025, 026, 028, 048, 049, 050, 051, 052, 053, 054, 056, 057, 058, 059, 060, 061, 062.

Tümünde `durum: taslak`, `denetim.insan: pending`. Denetim değerleri (kör denetim-3):

| Hikâye | Ajan A | Ajan B |
|---|---|---|
| HR-024 | pass | pass |
| HR-025 | pass | review_needed |
| HR-026 | review_needed | review_needed |
| HR-028 | pass | review_needed |
| HR-048 | review_needed | review_needed |
| HR-049 | review_needed | review_needed |
| HR-050 | review_needed | review_needed |
| HR-051 | pass | review_needed |
| HR-052 | review_needed | fail |
| HR-053 | review_needed | review_needed |
| HR-054 | pass | review_needed |
| HR-056 | pass | review_needed |
| HR-057 | review_needed | review_needed |
| HR-058 | review_needed | review_needed |
| HR-059 | pass | review_needed |
| HR-060 | review_needed | review_needed |
| HR-061 | review_needed | review_needed |
| HR-062 | pass | review_needed |

HR-055 ayrıca `denetim` için değil, derleme için bekliyor (aşağıda). Bu denetim değerleri Sonnet düzeltmesinden SONRA yapılmadı: HR-024, 025, 026, 028, 049, 051, 052, 053 için düzeltme yapıldı, kör yeniden denetim yapılmadı. Panele aktarmadan önce bu sekiz hikâyenin yeniden denetimi gerekir.

## Derlenemeyen 2 hikâye

- **HR-055:** deyim yuvası `hr055_agzi_kulaklarina` sözlükte yok. Sözlüğe girdi eklenmeli ya da deyim değiştirilmeli (editoryal karar).
- **HR-126:** 3. sınıf için 3 şık gerekli (şu an 4). Ayrıca sözlük dosyası yok; ölçüm, yamaç, model ve kontrol sözcüklerinin sözlüğe girmesi gerekiyor.

## Kalite uyarıları (derleyici zorunlu tutmaz)

- HR-024 s2, HR-025 s4, HR-026 s3: doğru şık diğerlerinden uzun.

## İçe aktarma

Panelde yönetici olarak Hikâye Atölyesi → İçe Aktar sekmesinden paketi yükleyin, önce **kuru çalıştırma** ile kontrol edin, sonra yazın.
