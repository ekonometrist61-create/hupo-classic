# =====================================================================
#  kurtarma-sql-denetim.ps1 — migration'lar için statik denetim
#  (Supabase CLI/Docker yoksa "supabase db reset" yerine geçmez; onu
#   tamamlayan hızlı bir ön kontroldür.)
#
#  Denetimler:
#   1) Dolar-tırnak ($$ / $function$ / $fn$) sayısı çift mi? (gövde kapanmış mı)
#   2) "security definer" olan her fonksiyonda "set search_path" var mı?
#   3) Her create function için bir "revoke execute on function <ad>" var mı?
#      (dinamik "execute format('revoke execute ...')" blokları tüm dosya
#       için yeterli sayılır — yanlış pozitif üretmez)
#   4) "[DEVAM" gibi yarım kalmış düzenleme işaretçisi var mı?
#   5) Her dosya son satırında noktalı virgülle mi bitiyor?
#
#  Kullanım:  powershell -NoProfile -File tools\kurtarma-sql-denetim.ps1
#  Rapor:     %TEMP%\firsat\denetim-raporu.txt  (UTF-8, aranabilir kopya)
# =====================================================================

$ErrorActionPreference = 'Stop'
$kok = Split-Path -Parent $PSScriptRoot
$mig = Join-Path $kok 'supabase\migrations'
$tst = Join-Path $kok 'supabase\tests'

$hata = 0
$uyari = 0
$bilgi = 0
$rapor = New-Object System.Collections.Generic.List[string]

function Yaz-Satir([string]$metin, [string]$renk) {
  $script:rapor.Add($metin)
  Write-Host $metin -ForegroundColor $renk
}
function Yaz-Hata([string]$metin) {
  $script:hata++
  Yaz-Satir "  HATA  $metin" 'Red'
}
function Yaz-Uyari([string]$metin) {
  $script:uyari++
  Yaz-Satir "  UYARI $metin" 'Yellow'
}
function Yaz-Bilgi([string]$metin) {
  $script:bilgi++
  Yaz-Satir "  NOT   $metin" 'DarkGray'
}

$sqlDosyalar = @()
$sqlDosyalar += Get-ChildItem -Path $mig -Filter '*.sql' | Sort-Object Name
$sqlDosyalar += Get-ChildItem -Path $tst -Filter '*.sql' | Sort-Object Name

# Repo geneli: tüm "revoke execute on function ..." adları (fonksiyon yetkisi kanıtı)
$tumMetin = ($sqlDosyalar | ForEach-Object { Get-Content -Raw $_.FullName }) -join "`n"
$revokeAdlari = [System.Collections.Generic.HashSet[string]]::new()
foreach ($m in [regex]::Matches($tumMetin, '(?i)revoke\s+execute\s+on\s+function\s+public\.([a-z0-9_]+)')) {
  [void]$revokeAdlari.Add($m.Groups[1].Value.ToLower())
}

foreach ($dosya in $sqlDosyalar) {
  $ham = Get-Content -Raw $dosya.FullName
  $satirlar = Get-Content $dosya.FullName
  $ad = $dosya.Name
  $sorunVar = $false

  # Dosyada dinamik revoke bloğu var mı? (execute format('revoke execute ...'))
  $dinamikRevoke = ($ham -match "(?i)execute\s+format\(\s*'[^']*revoke\s+execute\s+on\s+function")

  # 1) Dolar-tırnak dengeleri
  foreach ($etiket in @('$$', '$function$', '$fn$', '$kurtarma$')) {
    $adet = ([regex]::Matches($ham, [regex]::Escape($etiket))).Count
    if ($adet % 2 -ne 0) {
      Yaz-Hata "$ad : $etiket etiketi tek sayıda ($adet) — gövde kapanmamış olabilir"
      $sorunVar = $true
    }
  }

  # 2) security definer → set search_path  (aşağıdaki satır taramasında)
  $satirNo = 0
  foreach ($satir in $satirlar) {
    $satirNo++
    if ($satir -match '(?i)create\s+(or\s+replace\s+)?function\s+public\.([a-z0-9_]+)') {
      $fnAd = $Matches[2].ToLower()
      # başlık bitene kadar (dolar-tırnak etiketine kadar) geniş pencere tara
      $bitis = [Math]::Min($satirNo + 40, $satirlar.Count)
      $baslikMetni = ($satirlar[($satirNo - 1)..($bitis - 1)] -join "`n")
      if ($baslikMetni -match '(?i)security\s+definer' -and $baslikMetni -notmatch '(?i)set\s+search_path') {
        Yaz-Hata "${ad}:${satirNo} : $fnAd security definer ama 'set search_path' yok"
        $sorunVar = $true
      }
      if (-not $revokeAdlari.Contains($fnAd) -and -not $dinamikRevoke) {
        Yaz-Uyari "${ad}:${satirNo} : $fnAd için repo genelinde 'revoke execute' bulunamadı"
        $sorunVar = $true
      }
    }
  }

  # 3b) dinamik revoke bloğu bilgisi (statik taramanın göremediği yetki kanıtı)
  if ($dinamikRevoke) {
    Yaz-Bilgi "$ad : dinamik revoke bloğu var (execute format) — per-fonksiyon taraması atlandı"
  }

  # 4) yarım kalmış düzenleme işaretçisi
  if ($ham -match '\[DEVAM|\[TEST-DEVAM') {
    Yaz-Hata "$ad : yarım kalmış düzenleme işaretçisi ([DEVAM) kalmış"
    $sorunVar = $true
  }

  # 5) dosya sonu (yalnızca son anlamlı satır yorum değilse anlamlıdır)
  $sonAnlamli = ($satirlar | Where-Object { $_.Trim() -ne '' } | Select-Object -Last 1)
  if ($sonAnlamli -and $sonAnlamli.Trim() -notmatch '^--' -and $sonAnlamli.Trim() -notmatch ';$') {
    Yaz-Uyari "$ad : son anlamlı satır noktalı virgülle bitmiyor: $($sonAnlamli.Trim())"
    $sorunVar = $true
  }

  if (-not $sorunVar) {
    Yaz-Satir "  TAMAM $ad" 'Green'
  }
}

Yaz-Satir "" 'Gray'
Yaz-Satir "Denetlenen dosya: $($sqlDosyalar.Count) | hata: $hata | uyarı: $uyari | not: $bilgi" 'Gray'

$raporYolu = Join-Path $env:TEMP 'firsat\denetim-raporu.txt'
$raporDizin = Split-Path -Parent $raporYolu
if (-not (Test-Path $raporDizin)) { New-Item -ItemType Directory -Force -Path $raporDizin | Out-Null }
Set-Content -Path $raporYolu -Value $rapor -Encoding utf8
Write-Host "Rapor: $raporYolu" -ForegroundColor Gray

if ($hata -gt 0) { exit 1 } else { exit 0 }
