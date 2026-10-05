# =====================================================================
# Kişisel Yazılım Fabrikası - Windows tarafi hazirlik (AŞAMA 0-1)
# i5-1135G7 / 8 GB RAM icin WSL2 + .wslconfig
# Yonetici olarak PowerShell'de calistir.
# =====================================================================
$ErrorActionPreference = 'Stop'
$WslMemGB  = 4     # fiziksel 8 GB -> WSL'ye 4 GB
$WslSwapGB = 2
$WslRoot   = "$env:USERPROFILE"

Write-Host "`n== 1/5 WSL2 kontrolu ==" -ForegroundColor Cyan
$wsl = Get-Command wsl -ErrorAction SilentlyContinue
if (-not $wsl) { throw "wsl bulunamadi. Windows 11 guncelleyin veya 'wsl --install' calistirin." }

$status = (wsl --status 2>&1 | Out-String)
Write-Host $status
$dists = (wsl -l -q 2>&1 | Out-String).Trim()
if (-not $dists) {
    Write-Host "  Dagitim bulunamadi, Ubuntu kuruluyor..." -ForegroundColor Yellow
    wsl --install -d Ubuntu
    Write-Host "Bilgisayari YENIDEN BASLATIN, sonra bu betigi tekrar calistirin." -ForegroundColor Green
    exit 0
}
Write-Host "  Kurulu dagitimlar: $dists" -ForegroundColor DarkGray

Write-Host "`n== 2/5 WSL2 sanallastirma kontrolu ==" -ForegroundColor Cyan
$feat = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue
$vm   = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue
Write-Host ("  WSL      : {0}" -f $feat.State)
Write-Host ("  VM Platform: {0}" -f $vm.State)
if ($feat.State -ne 'Enabled') {
    Write-Host "  Etkinlestiriliyor..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
}
if ($vm.State -ne 'Enabled') {
    Write-Host "  Etkinlestiriliyor..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
}

Write-Host "`n== 3/5 .wslconfig yaziliyor (RAM siniri) ==" -ForegroundColor Cyan
$cfg = @"
# Kisisel Yazilim Fabrikasi - 8 GB RAM icin WSL2 ayarlari
[wsl2]
memory=${WslMemGB}GB
swap=${WslSwapGB}GB
localhostForwarding=true
# Docker Desktop VE Android Studio ayni anda acilmayacak; bu satir
# VM bellek disini kullanmayi zorlar.
[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
"@
$cfgPath = Join-Path $WslRoot '.wslconfig'
Set-Content -Path $cfgPath -Value $cfg -Encoding UTF8
Write-Host "  Yazildi: $cfgPath  (memory=${WslMemGB}GB swap=${WslSwapGB}GB)" -ForegroundColor Green

Write-Host "`n== 4/5 Disk sifreleme durumu ==" -ForegroundColor Cyan
$enc = try { Get-BitLockerVolume -MountPoint 'C:' -ErrorAction Stop | Select-Object -ExpandProperty VolumeStatus } catch { 'Yok (Home surumu: ayarlar > Gizlilik ve guvenlik > Cihaz sifreleme)' }
Write-Host "  BitLocker: $enc" -ForegroundColor DarkGray

Write-Host "`n== 5/5 Acilacak terminal ==" -ForegroundColor Cyan
$here = (Get-Location).Path -replace '\\','/' -replace '^([A-Za-z]):','/$1'
$hereLower = $here.ToLower()
Write-Host @"
  1) Yeniden baslat (yoksa: wsl --shutdown)
  2) Baslat menusunden 'Ubuntu' ac, kullanici adi/parola belirle
  3) Ubuntu icinde bu klasore git ve calistir:
       cd $hereLower
       chmod +x setup-local.sh && ./setup-local.sh
  Not: Proje dosyalari /mnt/c altinda DEGIL, ~/dev/projects altinda tutulacak.
"@ -ForegroundColor Green
Write-Host "`nBitince: 'Ubuntu' icinde 'claude --version' calistirip sonucu bana yaz." -ForegroundColor Cyan