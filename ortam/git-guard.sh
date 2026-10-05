#!/usr/bin/env bash
# Stop hook: Claude bir isi bitirdiginde calisir.
# Amac: degisiklikleri Git'e kaydetmeden oturumu kapatmasin.
# Kurulum: her projenin .claude/settings.json icindeki hooks.Stop ile bagli.
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0

branch=$(git branch --show-current)
dirty=$(git status --porcelain | wc -l)

if [ "$branch" = "main" ] && [ "$dirty" -gt 0 ]; then
  echo "main dalinda $dirty degisik var. PR acmak icin yeni dal olustur:"
  echo "  git switch -c feat/yeni-is"
  exit 0
fi

if [ "$dirty" -gt 0 ]; then
  echo "$dirty dosya kaydedilmedi. Bitirmeden once:"
  echo "  git add -A && git commit -m 'feat: ...'"
fi
exit 0