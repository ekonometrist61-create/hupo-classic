# Sunucu–Lokal Senkronizasyon Stratejisi

> İki makine arasında dosya **kopyalanmaz**. Tek doğruluk kaynağı (single source of truth) **GitHub**'dır. Bu dosya, "hangi veri nerede durur, ne senkronize edilmez" sorusunu cevaplar.

## 1. Temel ilke

| Katman | Nerede yaşar | Senkronizasyon |
| --- | --- | --- |
| Kod | GitHub (özel depo) | `git push` / `git clone` — otomatik |
| WSL2 dosya sistemi | Laptopta `~/dev/` | Yalnızca Git üzerinden; **rsync yok** |
| Sunucu kodu | Sunucuda `~/dev/projects/<ad>` | Sunucuda `git pull` — laptopa hiçbir şey kopyalanmaz |
| Sırlar | Parola yöneticisi + GitHub Secrets | Manuel, tek tek, parola yöneticisinden |
| Çalışan sunucu verisi | Sunucu diski | **Sunucuda kalır** (laptopa gelmez) |
| Yedekler | Restic → Backblaze B2 | Sunucudan otomatik; laptop yedeği ayrı |

**Neden rsync/syncthing yok?** İki Git çalışma ağacı açık olursa hangisinin doğru olduğunu kimse bilemez. Senkronizasyon çatışması, kayıp koddan daha sık ve daha pahalı bir hatadır. Tek yönlü akış: **laptop → GitHub → sunucu**.

## 2. Günlük akış

### Laptopta (geliştirme — asıl yer)
```bash
cd ~/dev/projects/<proje>
git switch -c feat/yeni-ozellik
# ... çalış ...
git add -A && git commit -m "feat: yeni özellik"
git push -u origin feat/yeni-ozellik
gh pr create --fill
```

### Sunucuda (uzun süreli işler — CI, EAS build, toplu veri)
```bash
ssh fabrika-sunucu
cd ~/dev/projects/<proje>
git switch main && git pull          # yalnızca main güncel
tmux new -s oturum                   # bağlantı koparsa iş devam eder
claude                               # sunucuda Claude Code
```

Sunucuda uzun süreli (build, migration, toplu script) işleri **her zaman `tmux`** içinde çalıştır. SSH koptuğunda iş ölmez; `tmux attach` ile geri dönersin.

## 3. Çakışmayı önleyen kurallar

| Kural | Neden |
| --- | --- |
| **Sunucuda `main` dalında kod değiştirme.** | `main` korumalı; PR olmadan birleşmez. Sunucuda yaptığın değişiklik `git pull` ile kaybolur. |
| Sunucuda değişiklik **zorundaysa**: yeni dal aç, commit et, GitHub'a PR aç, laptopta incele ve birleştir. | Böylece laptop her zaman güncel koda sahip olur. |
| Aynı anda **iki makinede aynı dalda** çalışma. | Ortak Git deposu bunu engellemez; `git pull --rebase` çatışması verir. |
| `git pull` öncesi `git status` çalıştır, temiz olduğundan emin ol. | Çalışma ağacındaki kaydedilmemiş iş sessizce ezilmez ama karışır. |
| Veritabanı migration'larını yalnızca **laptopta** yaz; sunucuda `supabase db push` çalıştır. | Aynı migration'un iki yerde uygulanması şema sapması üretir. |
| Sunucuda `.env` **bulunur**, ama Git'e girmez ve laptopa kopyalanmaz. | Ortam değişkenleri platform panellerinden yeniden üretilir. |

## 4. Ne senkronize edilmez (asla)

- `.env`, `.env.*` (`.env.example` hariç)
- `node_modules/`, `.next/`, `build/`, `.dart_tool/`
- `~/.ssh/`, `~/.aws/`, API anahtarları, parola veritabanı
- Gerçek kişisel veri (öğrenci listeleri vb.) — geliştirme verisi **sahte** olmalı
- Yerel veritabanı dump'ları (Supabase kendi yedeğini yapar; `supabase db dump` çıktısını laptopa taşıma)
- `~/dev/experiments/` — deneme klasörü, ürün değil; yedeklenmez, senkronize edilmez

## 5. Sunucuda ne zaman çalıştırılır

| İş | Laptopta mı sunucuda mı | Neden |
| --- | --- | --- |
| Kod yazma, refactor, test | Laptop | 8 GB'da VS Code + WSL + Claude Code zaten sınırda |
| `pnpm build`, EAS build | Sunucu | 4 vCPU / 24 GB; laptop ısınıp yavaşlar |
| CI testleri | GitHub Actions | Bilgisayarın açıkken de koşar |
| Veritabanı migration (prod) | CI/CD | Rehber 6.5: üretimde Claude doğrudan yazmaz |
| Playwright E2E | Sunucu | Başsız (headless) çalışır, ekran gerektirmez |
| Restic yedek | Sunucu + laptop | İki ayrı kaynak |

## 6. 8 GB laptop için gerçek sınır

Bu makine (i5-1135G7 / 8 GB) üç katmanı aynı anda kaldırmaz. Kural:

1. **WSL2'ye 4 GB** tavan (`.wslconfig`), geri kalanı Windows'a.
2. Docker kurulu olsa bile **sürekli açık değil**. Veritabanı/migrasyon işi bitince kapat.
3. Android emülatörü yerine **gerçek telefon** (Expo Go). Emülatör 4 GB yer.
4. Chrome + VS Code + Claude Code + Docker aynı anda = donma. Öncelik sırası: Claude Code > VS Code > Chrome > Docker.

Ölçüm noktası: `htop` içinde WSL'in swap kullandığını görüyorsan, Docker'ı kapat.

## 7. Yedekleme ve felaket kurtarma (3-2-1-1-0)

| Ne | Nerede | Sıklık | Araç |
| --- | --- | --- | --- |
| Kod | GitHub + sunucu diski + şifreli harici SSD | her commit | git |
| Sunucu: `/home/ubuntu/dev`, `/etc` yapılandırmaları | Restic → Backblaze B2 (Object Lock) | günlük 30 / haftalık 12 / aylık 12 | restic |
| Laptop: `~/dev`, `~/.ssh/config`, `~/.claude` | Şifreli harici SSD | haftada 1 | Windows Yedekleme + disk |
| Sırlar | Parola yöneticisi şifreli çevrimdışı kopya | değişiklikte | 1Password/Bitwarden |
| WSL dağıtımı | `wsl --export` yedek dosyası | ayda 1 | `wsl --export` |

**Restore testi (3 ayda bir, Rehber 9.3):** boş klasöre geri yükle, `pnpm install`, derle, çalıştır. Test edilmemiş yedek yedek değildir.

Sunucu için asıl felaket senaryosu: Oracle hesabı kapanırsa kod GitHub'da durur; yedekten `~/dev` geri gelir, `setup-server.sh` yeniden çalışır, 30–40 dakikada ayağa kalkar. Bu yüzden `setup-server.sh` bu depoda versiyonlanır.

## 8. CI/CD fikri (basit, iki katman)

```
push → GitHub Actions (typecheck, lint, test, build)
        ├─ yeşil → main'e birleşince Vercel otomatik yayınlar
        └─ main → EAS build → TestFlight / dahili test
```
Sunucuyu CI'ye **bağlama**. Sunucu yalnızca elle, SSH + tmux ile kullanılan bir çalışma makinesidir; otomatik deploy hedefi değil. Bu, sunucu yanlışlıkla üretime yazan tek yolun önünü keser.

İleride gerçek bir sunucu hizmeti gerekirse (Rehber 7.1 üretim ortamı), ayrı bir `deploy` işi ve GitHub Environment koruması eklenir; o zaman GitHub secrets'ta `SSH_KEY`, `FABRIKA_SERVER_HOST` tutulur.

## 9. Aylık bakım listesi

- [ ] Tüm projelerde `git status` temiz, GitHub'a gönderilmiş
- [ ] Sunucuda `apt update && apt upgrade`
- [ ] Sunucu disk kullanımı < %70 (`df -h`)
- [ ] `tail /var/log/fabrika-health.log` içinde UYARI yok
- [ ] Bir projeyi yedekten geri yükleyip çalıştırdım (restore testi, 3 ayda bir)
- [ ] Tailscale bağlantısı çalışıyor; 22. port internete kapalı mı?