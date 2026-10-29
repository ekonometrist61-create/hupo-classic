# Claude Code Remote Control başlatıcı
# Kullanım: .\remote-claude.ps1 [-Name "oturum-adi"]
param(
    [string]$Name = "Cengizhan-PC"
)

$claudeExe = "$env:USERPROFILE\.local\bin\claude.exe"

if (-not (Test-Path $claudeExe)) {
    Write-Error "Claude Code bulunamadi: $claudeExe"
    exit 1
}

Write-Host "Remote Control oturumu baslatiliyor..." -ForegroundColor Cyan
Write-Host "Telefonundan Claude uygulamasini acip bu oturumu secebilirsin." -ForegroundColor Yellow
Write-Host "Bu pencereyi KAPATMAYIN - oturum kapanir." -ForegroundColor Red
Write-Host ""

& $claudeExe remote-control --name $Name
