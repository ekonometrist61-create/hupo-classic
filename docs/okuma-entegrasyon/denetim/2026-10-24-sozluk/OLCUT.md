# Sözlük adayları: bağımsız A/B denetim ölçütü (2026-10-24)

Kapsam: `bekleyen-50.csv` içindeki 50 aday (HR-099…HR-114, 7. ve 8. sınıf). Bu denetim yalnız ajan kararıdır; insan onayı yerine geçmez.

Girdi: aday satırı (`hikaye`, `sinif`, `yuva`, `tur`, `yazim`, `anlam`, `es`, `zit`) ve ilgili hikâye dosyası `icerik/okuma/hikaye/<hikaye-slug>.hikaye.md` (slug: `hr099-*` gibi önek ile bulunur).

## Ajan A: doğruluk
1. `yazim` doğru Türkçe yazım mı?
2. `anlam` Türkçe sözlük anlamıyla uyuşuyor mu, bir cümlelik ve kendi içinde tutarlı mı?
3. Yuva sözcüğü (ya da deyimi) hikâyede gerçekten geçiyor mu ve `anlam` o bağlamda doğru mu?
4. `es` ve `zit` alanları gerçek eş/zıt anlamlı sözcük mü? Yuva kimliğine (`hr099_veri` gibi), yuvanın kendisine ya da anlamsız bir değere işaret ediyorsa hata.

## Ajan B: uygunluk
1. Sınıf düzeyi: 7. ve 8. sınıf öğrencisi için sözcük ve anlam düzeyi uygun mu?
2. `tur` (kelime / deyim) doğru mu?
3. Çocuğa uygunluk: anlam ve örnek bağlam uygunsuz, ayrımcı ya da korkutucu değil mi?
4. Öğrenme değeri: aday hikâyede öğretilecek bir sözcük olarak anlamlı mı, yoksa yan bir ayrıntı mı?

## Karar (her aday için tek)
- `evet`: sorun yok.
- `duzelt`: düzeltilebilir sorun var; `gerekce` ve `oneri` alanında ne değişmeli yazılır.
- `hayir`: aday yanlış, uygunsuz ya da hikâyede hiç geçmiyor.

## Çıktı
Yalnız kendi dosyanıza yazın:
- Ajan A: `ajan-a.csv`
- Ajan B: `ajan-b.csv`

Sütunlar: `hikaye,yuva,karar,gerekce,oneri`. Gerekçe en fazla 15 sözcük; virgül içeriyorsa tırnak kullanın.

Kurallar:
- Hikâye dosyalarını, `bekleyen-50.csv`yi, sözlük CSV'sini ve diğer denetçinin raporunu değiştirmeyin veya okumayın. Bağımsız çalışın.
- Emin olmadığınız bir olguyu uydurmayın; `oneri` alanında "doğrulanamadı" yazın.
- Son mesajınız kısa olsun: `A|B: evet N, duzelt N, hayir N; dosya <yol>`.
