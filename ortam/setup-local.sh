#!/usr/bin/env bash
# =====================================================================
# Kişisel Yazılım Fabrikası - AŞAMA 1 (ÇEKİRDEK) kurulum betiği
# Hedef donanım: i5-1135G7 / 8 GB RAM  -> Docker, Android emülatör ve
# Chrome'u aynı anda ACMAYACAK şekilde kurulur.
#
# Çalıştırma (Ubuntu/WSL2 içinde):
#   chmod +x setup-local.sh && ./setup-local.sh
# Yeniden çalıştırmak güvenlidir (idempotent).
# =====================================================================
set -euo pipefail

# ---------- Yapılandırma ----------
NODE_MAJOR=24                       # Rehber Bölüm 1.2: Node 24 LTS, 26 Current
WSL_MEM_GB=4                        # 8 GB fiziksel RAM -> WSL'ye 4 GB tavan
WSL_SWAP_GB=2
DEV_ROOT="$HOME/dev"
LOG_DIR="$DEV_ROOT/.setup-logs"

log()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m  [OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  [!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m  [X]\033[0m %s\n' "$*" >&2; exit 1; }

command -v sudo >/dev/null || die "sudo bulunamadı. Bu betiği Ubuntu/WSL2 kullanıcısı olarak çalıştır."

mkdir -p "$LOG_DIR"

# ---------- 0. Temel paketler ----------
log "0/9 Temel paketler"
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq \
  build-essential git curl wget unzip jq ca-certificates gnupg \
  bash-completion zsh ripgrep fd-find tree htop tmux rsync \
  jq openssh-client software-properties-common
# Claude Code sandbox'i icin (Rehber 6.1)
sudo apt-get install -y -qq bubblewrap socat || warn "bubblewrap/socat kurulamadı; /sandbox paneli eksi gösterebilir."
ok "temel paketler"

# ---------- 1. Git ----------
log "1/9 Git"
git config --global init.defaultBranch main
git config --global core.autocrlf input       # WSL2 -> LF (sonsuz CRLF uyarısı)
git config --global core.longpaths true       # Windows ile paylaşılan depo yolları
git config --global pull.rebase true
git config --global fetch.prune true
# GitHub kimlik doğrulaması: sonraki bölümde 'gh auth login' ile yapılacak.
ok "git $(git --version | awk '{print $3}')"

# ---------- 2. GitHub CLI ----------
log "2/9 GitHub CLI (gh)"
if ! command -v gh >/dev/null; then
  (cd /tmp && gh_ver="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest | jq -r .tag_name)" \
   && curl -fsSL -o gh.tgz "https://github.com/cli/cli/releases/download/${gh_ver}/gh_${gh_ver#v}_linux_amd64.tar.gz" \
   && tar -xzf gh.tgz && sudo mv "gh_${gh_ver#v}_linux_amd64/bin/gh" /usr/local/bin/gh \
   && sudo chmod +x /usr/local/bin/gh && rm -rf "gh_${gh_ver#v}_linux_amd64" gh.tgz) \
   || warn "gh kurulamadı; elle kur: https://github.com/cli/cli/releases"
fi
gh config set git_protocol ssh || true
ok "gh $(gh --version 2>/dev/null | head -1 || echo 'kurulu değil')"

# ---------- 3. Node.js 24 LTS + pnpm ----------
log "3/9 Node.js ${NODE_MAJOR} LTS + pnpm"
if ! command -v nvm >/dev/null; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
fi
nvm install "$NODE_MAJOR" && nvm alias default "$NODE_MAJOR" && nvm use default
npm i -g pnpm@latest
# nvm kurulumu yeni kabuklarda da geçerli olsun
touch "$HOME/.bashrc"
grep -q NVM_DIR "$HOME/.bashrc" || cat >> "$HOME/.bashrc" <<'EOF'

# --- nvm ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
EOF
ok "node $(node -v) / pnpm $(pnpm -v)"

# ---------- 4. Claude Code ----------
log "4/9 Claude Code"
curl -fsSL https://claude.ai/install.sh | bash
ok "claude $(claude --version 2>/dev/null || echo 'kuruldu, PATH için yeni terminal aç')"

# ---------- 5. Dizin yapısı (Rehber 4.1) ----------
log "5/9 Dizin yapısı"
mkdir -p "$DEV_ROOT"/{projects,templates,experiments,scripts}
cp -f "$(dirname "$0")/setup-local.sh" "$DEV_ROOT/scripts/" 2>/dev/null || true
ok "$DEV_ROOT/{projects,templates,experiments,scripts}"

# ---------- 6. Performans: 8 GB RAM için ayarlar ----------
log "6/9 Performans ayarları (8 GB donanım)"
# WSL2'de: Windows kullanıcısı profilinde .wslconfig yazılacak (bkz KURULUM.md).
# Linux tarafında: swap ve disk üzerinde önbellek
sudo fallocate -l 2G /swapfile 2>/dev/null || true
swapon --show | grep -q /swapfile || sudo chmod 600 /swapfile && sudo mkswap /swapfile >/dev/null && sudo swapon /swapfile || true
grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
# İşlemciye göre paralellik
nproc
ok "swap hazır; ağır işleri (Android Studio, Docker) kapalı tut"

# ---------- 7. Docker (OPSİYONEL - varsayılan KAPALI) ----------
log "7/9 Docker (varsayılan: kurulmaz)"
if [ "${INSTALL_DOCKER:-0}" = "1" ]; then
  warn "8 GB RAM'te Docker Desktop pahalı. Docker Engine (Linux içinde) kuruluyor."
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
  sudo tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "live-restore": true
}
EOF
  sudo systemctl restart docker
  sudo systemctl enable --now docker
  ok "Docker Engine kuruldu (yalnızca veritabanı/migrasyon için aç)"
else
  warn "Docker kurulmadı. Gerekirse: INSTALL_DOCKER=1 ./setup-local.sh"
  warn "Yerel Supabase/Postgres için Aşama 2'de Docker'ı sadece o zaman aç."
fi

# ---------- 8. VS Code ayarları ----------
log "8/9 VS Code Remote ayarları"
SRC="$(dirname "$0")"
if [ -f "$SRC/vscode-config.json" ]; then
  mkdir -p "$DEV_ROOT/.vscode-user"
  cp -f "$SRC/vscode-config.json" "$DEV_ROOT/.vscode-user/settings.json"
  cp -f "$SRC/vscode-config.json" "$HOME/.config/Code/User/settings.json" 2>/dev/null || true
  ok "settings.json kopyalandı"
fi

# ---------- 9. Ortam değişkeni şablonu ----------
log "9/9 .env şablonu"
if [ -f "$SRC/.env.template" ]; then
  cp -f "$SRC/.env.template" "$DEV_ROOT/.env.example"
  ok "$DEV_ROOT/.env.example (gerçek anahtarları BURAYA DEĞİL, parola yöneticisine koy)"
fi

# ---------- Özet ----------
log "Kurulum tamamlandı. Sıradaki ADIMLAR (elle):"
cat <<EOF
 1. GitHub kimlik:   gh auth login     (SSH anahtarı üretir)
 2. SSH kopyala:     cat ~/.ssh/id_ed25519.pub  -> GitHub > Settings > SSH keys
 3. Yeni terminal aç (nvm PATH için), sonra:  claude   (ilk giriş)
 4. .wslconfig: Windows PowerShell'de $WSL_MEM_GB GB RAM sınırı koy (KURULUM.md)
 5. Test:            mkdir -p ~/dev/projects && cd ~/dev/projects && git init deneme && claude
    Sonra: 'basit bir web sayfası yap ve özel GitHub deposuna gönder'  (Aşama 1 bitti ölçütü)

Docker gerektiren işler (veritabanı, EAS build) için:
    INSTALL_DOCKER=1 ./setup-local.sh
Loglar: $LOG_DIR
EOF