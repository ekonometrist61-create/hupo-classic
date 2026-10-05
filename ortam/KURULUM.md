# Kişisel Yazılım Fabrikası — Kurulum Kılavuzu

> Rehberin Aşama 1 (Çekirdek) ve Aşama 5 (Olgunluk / sunucu) adımlarını bu donanıma göre uygular.
> Bu klasördeki her dosya **sır içermez** ve Git'e girebilir.

## 0. Senin donanımın ve kararlarım

| | |
| --- | --- |
| İşlemci | i5-1135G7 (4 çekirdek, 2.4 GHz) |
| RAM | 8 GB → **sistem darboğazı budur** |
| İşletim sistemi | Windows x64 |
| Lokal OS kararı | **WSL2** (Rehber 1.1: sandbox yerel Windows'ta çalışmıyor) |
| Docker | **Lokalde kurulmaz** (varsayılan). Sadece `INSTALL_DOCKER=1` ile |
| Android emülatörü | **Kurulmaz**; Expo Go + gerçek telefon (Rehber 7.4) |
| Python | **Gerekmiyor.** Rehber'de yer almıyor; Node + Flutter var. Flutter SDK kendi Python'unu getirmez ama tooling'e gerekirse `uv` ile tek komut. |
| Node.js | 24 LTS (26 Current — kurma) |
| Paket yöneticisi | pnpm |
| Docker | Sunucuda kurulur (24 GB rahat) |

Neden Docker yok: VS Code + Chrome + WSL + Docker + Android Studio + Claude Code aynı anda 8 GB'da donar. Rehber 7.4'te "Docker kurulu olsun, sürekli açık olmasın" deniyor; 8 GB'da benim önerim bir kademe daha geride kalmak.

## 1. Lokal kurulum (laptop)

### Adım 1 — Windows tarafı (PowerShell, yönetici olarak)

```powershell
cd "C:\Users\cengi\OneDrive\Desktop\çıkarıldı\Fırsat Bulucu-Ürün Geliştirme\ortam"
.\setup-local.ps1
```
Bu betik: WSL2 kontrolü, gerekli özellikleri etkinleştirir ve `%USERPROFILE%\.wslconfig` içine **4 GB RAM + 2 GB swap** yazar. Sonra bilgisayarı yeniden başlat.

### Adım 2 — Ubuntu ilk açılış
Başlat menüsünden "Ubuntu"yu aç, kullanıcı adı ve parola belirle.

### Adım 3 — Çekirdek araçlar (Ubuntu içinde)

```bash
cd "/mnt/c/Users/cengi/OneDrive/Desktop/çıkarıldı/Fırsat Bulucu-Ürün Geliştirme/ortam"
chmod +x setup-local.sh && ./setup-local.sh
```
Kurulan: git, gh, Node 24 + pnpm, Claude Code, rg/fd/htop/tmux/rsync, `~/dev/{projects,templates,experiments,scripts}`.

### Adım 4 — Kimlik ve ilk doğrulama
```bash
gh auth login          # SSH anahtarı üretir ve sorar
cat ~/.ssh/id_ed25519.pub   # GitHub > Settings > SSH keys > New SSH key
claude                 # ilk giriş (abonelik)
```

**Aşama 1'in bitti ölçütü:**
```bash
mkdir -p ~/dev/projects && cd ~/dev/projects && mkdir deneme && cd deneme && git init
claude
# "Basit bir web sayfası yap ve özel GitHub deposuna gönder."
```

## 2. Sunucu kurulumu (Oracle Always Free)

1. Oracle Cloud'da Ubuntu 22.04/24.04 (4 OCPU, 24 GB) instance aç.
2. SSH ile bağlan, `~/` altına bu klasörün `setup-server.sh` dosyasını kopyala (ör. `scp` ile ya da `curl` ile).
3. Çalıştır: `bash setup-server.sh`
4. Betik ne yapar:
   - temel paketler, kullanıcı, **parola ve root girişi kapalı SSH**
   - **UFW: internete sadece 22. port açık** (fail2ban ile)
   - Node 24 + pnpm, Claude Code, `~/dev/*`
   - Docker Engine (24 GB için)
   - **Tailscale** (kurulu, `sudo tailscale up --ssh` ile bağlanacaksın)
   - 5 dakikada bir disk/RAM kaydı + log rotasyonu
5. Tailscale bağlandıktan sonra 22. portu kapat:
   ```bash
   sudo ufw delete allow 22/tcp && sudo ufw --force reload
   # artık yalnızca: ssh fabrika-sunucu
   ```
6. Sunucuda Claude: `ssh fabrika-sunucu && claude` → `/login`

## 3. VS Code Remote Development

**WSL2 (lokal):** `wsl` eklentisini kur, Ubuntu'da `cd ~/dev/projects/<proje> && code .`

**Remote-SSH (sunucu):**
1. Eklenti: `ms-vscode-remote.remote-ssh`
2. `Ctrl+Shift+P` → **Remote-SSH: Add New SSH Host** → `ssh fabrika-sunucu`
3. **Remote-SSH: Connect to Host** → `fabrika-sunucu`
4. Klasörü aç: `/home/ubuntu/dev/projects/<proje>` ( **`/mnt/c` değil** )
5. Ayarlar: `~/.vscode-user/settings.json` (laptop) ve `~/.vscode-server/data/Machine/settings.json` (sunucu) içine `vscode-config.json` içeriğini kopyala.

## 4. Ortam değişkenleri

```bash
cp .env.template ~/dev/.env.example    # şablon
```
Gerçek sırlar **şablona yazılmaz**:
- Laptop: `.env` (git'e girmez, `.gitignore`'da)
- GitHub: Actions Secrets
- Sunucu: `/home/ubuntu/dev/projects/<proje>/.env` (600 izin)
- Vercel / Supabase / Expo: kendi panellerinde

**`SUPABASE_SERVICE_ROLE_KEY` asla mobil veya tarayıcı kodunda olmaz.**

## 5. Monitoring ve loglama

| Ne | Nerede |
| --- | --- |
| Uygulama hataları | Sentry (ilk gerçek kullanıcıdan itibaren — Rehber 13.4) |
| Çalışma zamanı | Uptime Kuma (`docker compose --profile staging up -d`, port 3001, sadece Tailscale) |
| Sunucu kaynakları | `tail -f /var/log/fabrika-health.log` (5 dk'da bir) |
| Log rotasyonu | `/etc/logrotate.d/fabrika` (haftalık, 8 kopya) |
| Uygulama logları | `docker compose logs -f web` (log sınırı 10 MB × 5) |

## 6. Yedekleme

- **Kod:** GitHub + şifreli harici SSD
- **Sunucu:** Restic → Backblaze B2 (Object Lock). Aşama 5; kurulum yardımı iste.
- **WSL:** `wsl --export` ile ayda bir dışa aktarım
- **Sırlar:** parola yöneticisi + şifreli çevrimdışı kopya
- **Test:** 3 ayda bir geri yükle ve çalıştır (`sync-strategy.md` §7)

## 7. CI/CD (basit)

`.github/workflows/ci.yml` — her PR'da: install → typecheck → lint → test → build. `main`'e birleşince Vercel yayınlar. **Sunucuyu CI'ye bağlama** (gerekçe: `sync-strategy.md` §8).

## 8. Dosya listesi

| Dosya | Ne işe yarar |
| --- | --- |
| `setup-local.ps1` | Windows: WSL2 + `.wslconfig` (4 GB) |
| `setup-local.sh` | Ubuntu/WSL2: git, gh, Node 24, pnpm, Claude Code, dizinler |
| `setup-server.sh` | Ubuntu sunucu: SSH sertleştirme, UFW, Docker, Tailscale, monitoring |
| `.env.template` | Değişken şablonu (sır yok) |
| `docker-compose.yml` | Sunucu katmanı: Caddy, web, Postgres, Uptime Kuma, Loki (opsiyonel) |
| `vscode-config.json` | Remote-SSH/WSL ayarları |
| `sync-strategy.md` | Senkronizasyon, çakışma kuralları, yedekleme, CI/CD |
| `health-check.sh` | 5 dakikada bir disk/RAM/Docker kaydı |
| `claude-settings.json` | `.claude/settings.json` için izin + sandbox şablonu |
| `git-guard.sh` | Stop hook: kaydedilmemiş değişikliği uyarır, `main`'de çalışmayı engeller |
| `CLAUDE.md` | Ortam kurallarını Claude'a anlatan proje el kitabı |

## 9. Bilinçen yapılmayanlar

- **Docker kurulu değil (lokal)** — 8 GB. Veritabanı işi yapacaksan `INSTALL_DOCKER=1 ./setup-local.sh`, iş bitince kapat.
- **Python yok** — ihtiyaç duyarsan `curl -LsSf https://astral.sh/uv/install.sh | sh`.
- **Staging ortamı yok** — Rehber: ilk gerçek kullanıcıdan önce. Aşama 3'te eklenir.
- **Restic + B2 kurulu değil** — Aşama 5, teknik yardım iste.
- **Fluter/Android tooling bu klasörde yok** — Aşama 4 (mobil) için ayrı kurulum.

## 10. Claude izin katmanı (Aşama 0-1)

Her yeni projede:
```bash
cp ~/dev/.claude/settings.json <proje>/.claude/settings.json   # veya bu klasördeki claude-settings.json
mkdir -p ~/dev/scripts && cp ortam/git-guard.sh ~/dev/scripts/   # Stop hook
```
- İlk haftalar Claude Code'u **Plan** modunda çalıştır.
- `sandbox.enabled: true` + `failIfUnavailable: true` → WSL2'de bubblewrap/socat kurulu
  olduğu için komutlar yalıtılır. `/sandbox` panelinde eksi görürsen haber ver.
- `.env`, `secrets/`, `~/.ssh`, `~/.aws/credentials` okumak **deny**.
- `--dangerously-skip-permissions` bu ortamda (laptopta da sunucuda da) **asla** kullanılmaz.