# =====================================================================
#  kurtarilan-govdeleri-cikar.ps1
#
#  AMAÇ
#    canlı Supabase (ccozfrpnvyrnktpffkwo) katalog dökümünden üretilen
#    kurtarilan/cikti-kalan.csv içindeki HER fonksiyon gövdesini ayrı bir
#    .sql dosyasına çıkarır.
#
#  NEDEN
#    Kurtarma migration'larına fonksiyon gövdelerini elle kopyalamak
#    tırnak/kaçış ('' ve $$) hatalarına açıktır. Bu betik CSV'nin kaçış
#    kurallarını Import-Csv'ye bırakır; gövde diske BİREBİR yazılır
#    (AGENTS.md §7: "metin ve isim birebir").
#
#  ÇIKTI
#    kurtarilan/parcalar/<fonksiyon_adi>.sql   (git'e girmez, kanıt alanı)
#    kurtarilan/parcalar/_ozet.txt             (ad, imza, yetki satırı)
#
#  KULLANIM
#    powershell -ExecutionPolicy Bypass -File tools\kurtarilan-govdeleri-cikar.ps1
# =====================================================================

[CmdletBinding()]
param(
  [string] $KaynakCsv,
  [string] $HedefKlasor
)

$ErrorActionPreference = 'Stop'

# $PSScriptRoot parametre bloğunda boş gelebiliyor; bu yüzden gövdede çözülür.
$betikKoku = $PSScriptRoot
if ([string]::IsNullOrEmpty($betikKoku)) {
  $betikKoku = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if ([string]::IsNullOrEmpty($KaynakCsv)) {
  $KaynakCsv = Join-Path $betikKoku '..\kurtarilan\cikti-kalan.csv'
}
if ([string]::IsNullOrEmpty($HedefKlasor)) {
  $HedefKlasor = Join-Path $betikKoku '..\kurtarilan\parcalar'
}

if (-not (Test-Path -LiteralPath $KaynakCsv)) {
  throw "Kaynak CSV bulunamadı: $KaynakCsv"
}

$KaynakCsv = (Resolve-Path -LiteralPath $KaynakCsv).Path
if (-not (Test-Path -LiteralPath $HedefKlasor)) {
  New-Item -ItemType Directory -Path $HedefKlasor -Force | Out-Null
}

$satirlar = Import-Csv -LiteralPath $KaynakCsv -Encoding UTF8
$ozet = New-Object System.Collections.Generic.List[string]
$yazilan = 0
$atlanan = 0

foreach ($satir in $satirlar) {
  $govde = [string] $satir.govde
  if ([string]::IsNullOrWhiteSpace($govde)) { $atlanan++; continue }

  # İlk satır: "fonksiyon_adi [argümanlar]"
  $govdeSatirlari = $govde -split "`r?`n"
  $baslik = $govdeSatirlari[0].Trim()

  # Adı yalnızca güvenli karakterlere indir (dosya adı için)
  $ad = ($baslik -split '\s+')[0]
  $ad = $ad -replace '[^A-Za-z0-9_]', ''
  if ([string]::IsNullOrWhiteSpace($ad)) { $atlanan++; continue }

  $hedef = Join-Path $HedefKlasor "$ad.sql"
  Set-Content -LiteralPath $hedef -Value $govde -Encoding UTF8

  # Yetki özeti: "-- secdef: true | path: ... | anon: false | auth: true | servis: true"
  $yetki = ($govdeSatirlari | Where-Object { $_ -match '^\s*--\s*secdef' } | Select-Object -First 1)
  if (-not $yetki) { $yetki = '(yetki satırı yok)' }

  $ozet.Add("$ad`t$baslik`t$($yetki.Trim())")
  $yazilan++
}

$ozet.Insert(0, "kaynak: $KaynakCsv")
$ozet.Insert(1, "yazılan: $yazilan | atlanan: $atlanan")
$ozet.Insert(2, "ad`timza`tyetki")
Set-Content -LiteralPath (Join-Path $HedefKlasor '_ozet.txt') -Value $ozet -Encoding UTF8

Write-Host "Çıkarıldı: $yazilan dosya -> $HedefKlasor"
