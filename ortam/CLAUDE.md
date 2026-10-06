# Ortam El Kitabı — Claude Code için

> Bu dosya `CLAUDE.md` olarak da kullanılabilir. Ortam kurallarını içerir; proje kuralları
> her ürünün kendi `CLAUDE.md` dosyasında yaşar.

## Bu ortam ne

Kişisel Yazılım Fabrikası: laptop (Windows + WSL2, 8 GB) ve Oracle Always Free sunucu
(4 vCPU / 24 GB). Kodun tek doğruluk kaynağı GitHub'dır.

## Donanım sınırları — bunu bil

**Laptop 8 GB RAM.** Bu, ortamın en kısıtlayıcı kuralı:

- Docker, Android emülatörü, Chrome ve VS Code **aynı anda açık olmaz**. Öncelik:
  Claude Code > VS Code > Chrome > Docker.
- Yerel Supabase/Postgres yalnızca veritabanı işi yaparken açılır, sonra kapatılır.
- Mobil geliştirmede emülatör değil **gerçek telefon** (Expo Go) kullanılır.
- `htop` içinde WSL swap kullanıyorsa Docker'ı kapat ve kullanıcıya söyle.
- Uzun süreli build, EAS ve Playwright işleri **sunucuda** çalıştırılır.

## Dosya sistemi

- Projeler `~/dev/projects/<ad>` altında, her biri ayrı Git deposu.
- Projeyi `/mnt/c/...` altına koyma (Rehber 4.5). Yalnızca bu `ortam/` klasörü
  `/mnt/c` üzerinde yaşar, çünkü kurulum dosyalarıdır.
- Yolda boşluk ve Türkçe karakter olmasın.
- Claude'u **her zaman proje klasöründe** başlat, ev klasöründe değil.

## Komutlar

```bash
# Lokal (WSL2)
cd ~/dev/projects/<proje> && git switch -c feat/is && claude
claude --version && node -v && pnpm -v

# Sunucu
ssh fabrika-sunucu
cd ~/dev/projects/<proje> && tmux new -s is && claude   # uzun işler tmux'ta

# Sağlık
tail -f /var/log/fabrika-health.log
docker compose --profile staging up -d
```

## Çalışma kuralları

1. **Sunucuda `main` dalına kod yazma.** Değişiklik gerekiyorsa dal aç, PR aç, laptopta birleştir.
2. **Üretim veritabanına doğrudan yazma.** Migration öner, dev'de test et, CI/CD uygulasın.
3. Sırları sohbete yapıştırma, `.env` okumayı `.claude/settings.json` deny kuralıyla kapat.
4. `NEXT_PUBLIC_` ile başlayan değişkene gizli anahtar koyma.
5. `SUPABASE_SERVICE_ROLE_KEY` yalnızca sunucu/CI'da; mobil ve tarayıcı kodunda asla.
6. Değişiklik sonunda: test/build çalıştır, sonucu gerçek komut çıktısıyla doğrula, tahmin etme.
7. Gerçek kişisel veri (öğrenci listesi vb.) kullanma; sahte veri üret.
8. Bir PR'ı "bitti" saymadan önce Definition of Done'u kontrol et.

## Git

- Dal adı: `feat/...`, `fix/...`, `chore/...`. Her dal tek iş.
- `main` korumalı: PR + CI olmadan birleşmez, force push yasak.
- Anlamlı mesaj: `feat: soru ekranına ipucu butonu eklendi`.
- Sunucu sadece `git pull` yapar; laptopa hiçbir şey kopyalanmaz (`sync-strategy.md`).

## Güvenlik

- İzin modları: ilk haftalar **Plan + Manual**. `--dangerously-skip-permissions` bu ortamda **asla** kullanılmaz (laptopta ve sunucuda).
- Sandbox açık (`bubblewrap`/`socat` kurulu). `/sandbox` panelinde eksi varsa haber ver.
- `.env`, `.env.*`, `secrets/` okumak deny.
- Sunucuda root girişi ve parola girişi kapalı; internette yalnızca SSH (Tailscale sonrası tamamen kapalı).

## Ücretsiz Arka Plan Kaldırma Aracı (rembg)

Görsellerin arka planını kaldırmak için **ücretli API kullanma**; bilgisayarda lokal
çalışan açık kaynaklı `rembg` aracını kullan. Kurulu (Python 3.12 + `rembg[cpu,cli]`).

Komut:

```bash
rembg i GIRDI_GORSELI CIKTI_GORSELI
```

Örnek:

```bash
rembg i mobile-app/assets/hupo/hizli.png mobile-app/assets/generated/hizli-transparent.png
```

Kurallar:

- Arka plan kaldırmada ücretli API yerine **her zaman rembg** tercih edilir.
- Saydam çıktılar **PNG** olarak kaydedilir.
- Orijinal dosya **değiştirilmez**.
- Üretilen dosyalar `assets/generated/` altına konur (bu depoda
  `mobile-app/assets/generated/`).

> Windows notu: `rembg` komutu Python Scripts klasörü (PATH'te) üzerinden gelir.
> Komut bulunamazsa terminali yeniden aç veya tam yolu kullan:
> `%LOCALAPPDATA%\Programs\Python\Python312\Scripts\rembg.exe`. İlk çalıştırmada
> u2net modeli bir kez indirilir.

## Tanıtım (Aşama 4 mobil) için

- Gerçek telefon + Expo Go; mağazaya çıkış ancak development build ile.
- Apple/Google hesap doğrulamaları günler sürer — başvuruyu Aşama 0'da yap.
- İmzalama anahtarlarını EAS'ta sakla; kaybolursa güncelleme yayınlanamaz.
