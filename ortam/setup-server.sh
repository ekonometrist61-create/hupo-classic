#!/usr/bin/env bash
# =====================================================================
# Kişisel Yazılım Fabrikası - SUNUCU kurulumu
# Hedef: Oracle Cloud Always Free (4 vCPU / 24 GB RAM, Ubuntu 22.04/24.04)
# Kurulum: ilk SSH girisinden sonra 'bash setup-server.sh' olarak calistir.
# Idempotenttir; tekrar calistirilabilir.
# =====================================================================
set -euo pipefail

USER_NAME="${FABRIKA_USER:-ubuntu}"
SSH_PORT="${SSH_PORT:-22}"
DOMAIN="${DOMAIN:-}"            # varsa HTTPS icin (bos birakilirsa yalnizca Tailscale)
INSTALL_TAILSCALE="${INSTALL_TAILSCALE:-1}"
INSTALL_DOCKER="${INSTALL_DOCKER:-1}"

log()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m  [OK]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m  [!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m  [X]\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] && SUDO="" || SUDO="sudo"
command -v curl >/dev/null || { $SUDO apt-get update -qq && $SUDO apt-get install -y -qq curl ca-certificates; }

# ---------- 1. Temel paketler ----------
log "1/8 Temel paketler"
export DEBIAN_FRONTEND=noninteractive
$SUDO apt-get update -qq
$SUDO apt-get install -y -qq \
  git curl wget unzip jq build-essential tmux htop rsync \
  ufw fail2ban chrony unattended-upgrades ripgrep fd-find tree
ok "paketler"

# ---------- 2. Yeni kullanici ve anahtar tabanli giris ----------
log "2/8 Kullanici ve SSH"
if ! id "$USER_NAME" >/dev/null 2>&1; then
  $SUDO adduser --disabled-password --gecos "" "$USER_NAME"
  $SUDO usermod -aG sudo "$USER_NAME"
  ok "$USER_NAME olusturuldu (parola sonra parola yoneticisinden)"
fi
mkdir -p "/home/$USER_NAME/.ssh"
chmod 700 "/home/$USER_NAME/.ssh"
touch "/home/$USER_NAME/.ssh/authorized_keys"
chmod 600 "/home/$USER_NAME/.ssh/authorized_keys"
if ! grep -qs . "/home/$USER_NAME/.ssh/authorized_keys"; then
  if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    cat "$HOME/.ssh/id_ed25519.pub" >> "/home/$USER_NAME/.ssh/authorized_keys"
    ok "bu makinenin SSH anahtari eklendi"
  else
    warn "SSH anahtarin yok. Once 'ssh-keygen -t ed25519' uret ve sunucuya ekle."
  fi
fi
chown -R "$USER_NAME:$USER_NAME" "/home/$USER_NAME/.ssh"

# root girisi ve parola girisi kapat
cat > /etc/ssh/sshd_config.d/99-fabrika-hardening.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
X11Forwarding no
MaxAuthTries 3
EOF
sshd -t && $SUDO systemctl reload ssh 2>/dev/null || $SUDO systemctl reload sshd 2>/dev/null || warn "sshd reload edilemedi; yeniden baglanma hatasini bekle."
ok "SSH sifreli, root/parola girisi kapali"

# ---------- 3. Firewall ----------
log "3/8 Firewall (UFW)"
$SUDO ufw default deny incoming
$SUDO ufw default allow outgoing
$SUDO ufw allow "$SSH_PORT/tcp" || true
$SUDO ufw --force enable
$SUDO systemctl enable --now fail2ban
ok "yalnizca SSH acik; diger tum portlar internete KAPALI"

# ---------- 4. Node + pnpm ----------
log "4/8 Node.js 24 + pnpm"
export NVM_DIR="/home/$USER_NAME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  $SUDO -u "$USER_NAME" bash -c 'curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
fi
sudo_bash() { $SUDO -u "$USER_NAME" bash -lc "$1"; }
sudo_bash 'export NVM_DIR="$HOME/.nvm"; . "$NVM_DIR/nvm.sh"; nvm install 24; nvm alias default 24; npm i -g pnpm@latest; echo OK'
ok "node 24 + pnpm ($USER_NAME icinde)"

# ---------- 5. Claude Code + tmux/git yapilandirmasi ----------
log "5/8 Claude Code + kabuk"
sudo_bash 'curl -fsSL https://claude.ai/install.sh | bash'
$SUDO -u "$USER_NAME" git config --global init.defaultBranch main
$SUDO -u "$USER_NAME" git config --global core.autocrlf input
$SUDO -u "$USER_NAME" git config --global pull.rebase true
# GitHub kimlik: kullanicinin kendi anahtarisini sunucuya baglamasi icin
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  $SUDO -u "$USER_NAME" bash -c 'mkdir -p ~/.ssh && cat /dev/stdin >> ~/.ssh/authorized_keys' < "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || true
fi
ok "claude + git + tmux hazir"
warn "Sunucuda '/login' yapmayi UNUTMA. Kimlik dogrulama yapmadan calismaz."

# ---------- 6. Docker (opsiyonel katman) ----------
log "6/8 Docker"
if [ "$INSTALL_DOCKER" = "1" ]; then
  curl -fsSL https://get.docker.com | sh
  $SUDO usermod -aG docker "$USER_NAME"
  $SUDO tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "5" },
  "live-restore": true
}
EOF
  $SUDO systemctl enable --now docker
  ok "Docker Engine kuruldu (24 GB RAM icin rahat)"
else
  warn "Docker kurulmadi"
fi

# ---------- 7. Tailscale (uzaktan erisim - SSH yerine) ----------
log "7/8 Tailscale"
if [ "$INSTALL_TAILSCALE" = "1" ]; then
  if ! command -v tailscale >/dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
  fi
  $SUDO systemctl enable --now tailscaled
  ok "tailscale kuruldu. Baglanmak icin:"
  echo "     sudo tailscale up --ssh --hostname fabrika-sunucu"
  echo "     Sonra laptopta da 'tailscale up' calistir; iki taraf da ayni agda olur."
else
  warn "Tailscale kurulmadi - sunucu yalnizca internetten SSH ile erisilebilir"
fi

# ---------- 8. Dizinler, monitoring, logrotate ----------
log "8/8 Dizinler, kaynak izleme, log rotasyonu"
for d in projects templates experiments scripts; do
  $SUDO mkdir -p "/home/$USER_NAME/dev/$d"
  $SUDO chown -R "$USER_NAME:$USER_NAME" "/home/$USER_NAME/dev"
done
# Basit performans izleme: her 5 dakikada disk/RAM kaydi
cat > /etc/cron.d/fabrika-monitor <<EOF
*/5 * * * * $USER_NAME /home/$USER_NAME/dev/scripts/health-check.sh >> /var/log/fabrika-health.log 2>&1
EOF
chmod 644 /etc/cron.d/fabrika-monitor
# Log rotasyonu
cat > /etc/logrotate.d/fabrika <<'EOF'
/var/log/fabrika*.log {
    weekly
    rotate 8
    compress
    missingok
    notifempty
    create 0644 root adm
}
EOF
$SUDO systemctl enable --now cron || $SUDO systemctl enable --now crond
ok "dizinler + 5 dakikalik saglik kaydi + log rotasyonu"

# ---------- Ozet ----------
log "Sunucu hazir. Siradaki ADIMLAR:"
cat <<EOF
 1) Bu pencereden cik. Su anki SSH oturumunu KAPAT ve tekrar baglan:
      ssh -p $SSH_PORT $USER_NAME@SUNUCU_IP
    (Parola girisi kapali oldugu icin anahtarin taninmis olmali.)
 2) Tailscale baglantisi (browser acilacak):
      sudo tailscale up --ssh --hostname fabrika-sunucu
 3) Artik sunucuya SADECE Tailscale uzerinden eris:
      ssh fabrika-sunucu        (yoksa IP ile, ama o zaman 22. port internete acik kalir)
 4) Claude kurulumu tamamla:
      claude                   -> /login
 5) Projeyi bagla:
      git clone <depo> ~/dev/projects/<ad>
      cd ~/dev/projects/<ad> && claude
 6) VS Code Remote: 'Remote-SSH: Connect to Host' -> fabrika-sunucu
      (Kaynak klasoru /home/$USER_NAME/dev/projects/... yap; VS Code uzerinden baglanma)

Guvenlik notu: 22. port internete acik kaldiysa bunu Tailscale baglandiktan SONRA kapat:
      sudo ufw delete allow $SSH_PORT/tcp && sudo ufw --force reload
      (Tailscale SSH aktifse yerel 22. portu kapatabilirsin)
EOF
warn "CI/CD ve staging icin su an Docker kuruldu ama compose dosyasi '$DOMAIN' degiskenine bagli; bkz KURULUM.md"