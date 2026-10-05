#!/usr/bin/env bash
# Sunucu saglik kontrolu - /etc/cron.d/fabrika-monitor her 5 dakikada bunu cagirir.
# Cikisi /var/log/fabrika-health.log'a eklenir. Uyari esigi asilirsa e-posta yoksa
# en azindan Tailscale uzerinden gorunur (journalctl -u fabrika-izle).
set -uo pipefail
THRESHOLD_DISK=85   # yuzde
THRESHOLD_RAM=90

disk=$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')
ram=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')
load=$(awk '{print $1}' /proc/loadavg)
ts=$(date -Is)

disk_status="OK"; [ "$disk" -ge "$THRESHOLD_DISK" ] && disk_status="UYARI"
ram_status="OK";  [ "$ram"  -ge "$THRESHOLD_RAM" ]  && ram_status="UYARI"

echo "$ts disk=$disk%($disk_status) ram=$ram%($ram_status) load=$load"

# Docker varsa konteyner sagligi
if command -v docker >/dev/null; then
  down=$(docker ps -q --filter "health=unhealthy" 2>/dev/null | wc -l)
  running=$(docker ps -q 2>/dev/null | wc -l)
  echo "$ts docker: $running calisiyor, $down sagliksiz"
fi

# Disk %85 asildiysa en buyuk 5 dizini yaz (elle mudahale icin)
if [ "$disk" -ge "$THRESHOLD_DISK" ]; then
  echo "$ts --- en buyuk dizinler ---"
  du -xh --max-depth=1 / 2>/dev/null | sort -rh | head -6
fi