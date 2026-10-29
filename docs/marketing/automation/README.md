# Pazarlama otomasyonu MVP (dry-run, yayın yok)

Durum: Taslak MVP (yerelde test edildi) · Tarih: 2026-10-29 · Rol: Pazarlama Otomasyon Mimarı · Üst belge: `../12_AUTOMATION_ARCHITECTURE.md`

## Ne var
| Parça | Yol | Durum |
|---|---|---|
| Kural linter'ı (yasaklı ifade, uydurma sayı, UTM) | `scripts/sosyal_lint.py` | Yerelde test edildi |
| Durum makinesi `taslak → marka-denetimi → insan-onayi → planlandi → yayinlandi` | `scripts/pazarlama_akis.py` | Yerelde test edildi |
| Testler (14) | `tests/test_akis.py` | 14/14 geçti (`python -I tests/test_akis.py`) |
| Bütçe/CAC senaryo modeli | `scripts/butce_modeli.py` → `examples/butce_senaryolari.csv` | Çalıştırıldı |
| Olgu kaydı (tek doğruluk kaynağı) | `examples/olgular.json` | 8 olgu, kaynaklı |
| Gönderi/metrik şemaları | `schemas/*.json` | JSON geçerli |
| Gönderi şablonu | `templates/gonderi_sablonu.md` | — |
| n8n iskeletleri (import edilebilir, `active:false`) | `workflows/*.n8n.json` | JSON geçerli; **n8n'de import/çalıştırma test EDİLMEDİ** |

## Güvenceler (kodla zorunlu)
1. Hiçbir ağ kodu yok (test: `test_ag_kodu_yok`). Betik yayın yapamaz, mesaj gönderemez, API çağırmaz.
2. Durum atlanamaz. `insan-onayi` için insan adı + metnin SHA-256 özeti gerekir; ajan/bot adı reddedilir; onaydan sonra metin değişirse `planlandi`/`yayinlandi` reddedilir.
3. `yayinlandi` yalnız insanın platformda yayınlamasından sonra, gönderi URL'si kanıtıyla kaydedilir.
4. `DRY_RUN` varsayılan **1**: dosyaya yazılmaz (yalnız `DRY_RUN=0` ile yazar).
5. Gerçek anahtar yok. Gerekirse `.env.example` dışında değişken adı kullanılmaz (bu MVP anahtar gerektirmez).
6. Metindeki her sayı `olgular.json` içinde olmalı (ajan.py "girdide olmayan sayıyı reddet" kuralının aynısı).

## Kullanım
```powershell
cd docs\marketing\automation\scripts
$env:DRY_RUN='1'
python -I pazarlama_akis.py lint ..\examples\gonderi_ornek.json ..\examples\olgular.json
python -I pazarlama_akis.py gec ..\examples\gonderi_ornek.json marka-denetimi --olgular ..\examples\olgular.json
python -I pazarlama_akis.py gec <dosya> insan-onayi --onaylayan "Ad Soyad" --olgular ..\examples\olgular.json
python -I pazarlama_akis.py utm https://hupolingo.com/demo instagram sm-2027-01-h1 p01
python -I butce_modeli.py ..\examples\butce_senaryolari.csv
python -I ..\tests\test_akis.py
```
Gerçek yazım: `DRY_RUN=0`. Onay/yayın kaydı yalnız insan tarafından.

## REUSE → EXTEND → CREATE
- **REUSE:** `scripts/growth-ajan/ajan.py` kuralları (sayı doğrulama, prompt-injection kuralı); `docs/growth-crm/ajan-ciktilari/` taslak klasör deseni; UTM kuralları `web-panel/src/lib/analytics/utm.ts` ile aynı karakter kümesi; Büyüme Özeti; `growth_harcama`.
- **EXTEND (öneri, `16`):** `ajan.py` içine `sosyal_taslak_yazari`; `sosyal_lint` mantığını `scripts/growth-ajan/` altına taşımak; kanal CAC için hane kaynak alanı.
- **CREATE (yalnız onay):** `growth_sosyal_gonderi` / `growth_sosyal_metrik` tabloları — ilk 4 hafta dosya tabanlı yeter.

## n8n notları
Sunucudaki n8n yalnız loopback (`127.0.0.1:5678`), SSH tüneli ile (karar 2026-10-28). İskeletler yüklenmedi; Oracle servislerine dokunulmadı. "Execute Command" düğmesi n8n sürümünde kapalı olabilir; kullanılmasa da tüm akış elle `pazarlama_akis.py` ile yürür. Zamanlayıcı düğümü bilerek devre dışı ve workflow `active:false`.

## Yapılmayanlar
Meta/YouTube/LinkedIn API bağlama, OAuth, otomatik yayın, otomatik DM/yorum, e-posta/SMS gönderimi, reklam hesabı bağlama, yönetim paneli (G bileşeni) — `16` backlog (Büyüme Özeti sayfasına mevcut sosyal bölümü eklemek EXTEND).
