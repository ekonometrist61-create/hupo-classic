# =====================================================================
#  kurtarma-bagimlilik-denetimi.ps1 — kurtarılan gövdelerin bağımlılıkları
#
#  Ne yapar?
#    kurtarilan/parcalar/*.sql  (canlıdan BİREBİR çıkarılmış fonksiyon gövdeleri)
#    içindeki  public.<ad>  referanslarını toplar ve bunları
#    supabase/migrations/*.sql  içindeki TANIMLARLA karşılaştırır.
#
#  Neden?
#    Canlı gövde, diskte HİÇ bulunmayan bir tablo/fonksiyona atıfta bulunuyorsa
#    "supabase db reset" yeşil kalır ama fonksiyon ÇALIŞMA ANINDA hata verir.
#    Bu araç o boşlukları tek listede gösterir (bkz. supabase/KURTARMA_DURUMU.md §3).
#
#  Kullanım:  powershell -NoProfile -File tools\kurtarma-bagimlilik-denetimi.ps1
#  Rapor   :  %TEMP%\firsat\bagimlilik-raporu.txt  (UTF-8)
# =====================================================================

$ErrorActionPreference = 'Stop'
$kok   = Split-Path -Parent $PSScriptRoot
$mig   = Join-Path $kok 'supabase\migrations'
$tst   = Join-Path $kok 'supabase\tests'
$parca = Join-Path $kok 'kurtarilan\parcalar'

$rapor = New-Object System.Collections.Generic.List[string]
function Yaz([string]$metin) { $script:rapor.Add($metin) }

# --- 1) Disk + kurtarma migration'larındaki TANIMLI nesneler -----------------
$tanimli = [System.Collections.Generic.HashSet[string]]::new()
$tanimliFonksiyon = [System.Collections.Generic.HashSet[string]]::new()

$migrationDosyalari = @()
$migrationDosyalari += Get-ChildItem -Path $mig -Filter '*.sql'
$migrationDosyalari += Get-ChildItem -Path $tst -Filter '*.sql'

foreach ($d in $migrationDosyalari) {
  $t = Get-Content -Raw $d.FullName
  foreach ($m in [regex]::Matches($t, '(?i)create\s+(or\s+replace\s+)?function\s+public\.([a-z0-9_]+)')) {
    [void]$tanimli.Add($m.Groups[2].Value.ToLower())
    [void]$tanimliFonksiyon.Add($m.Groups[2].Value.ToLower())
  }
  foreach ($m in [regex]::Matches($t, '(?i)create\s+table\s+(if\s+not\s+exists\s+)?public\.([a-z0-9_]+)')) {
    [void]$tanimli.Add($m.Groups[2].Value.ToLower())
  }
  foreach ($m in [regex]::Matches($t, '(?i)create\s+(materialized\s+)?view\s+(if\s+not\s+exists\s+)?public\.([a-z0-9_]+)')) {
    [void]$tanimli.Add($m.Groups[3].Value.ToLower())
  }
  foreach ($m in [regex]::Matches($t, '(?i)create\s+type\s+public\.([a-z0-9_]+)')) {
    [void]$tanimli.Add($m.Groups[1].Value.ToLower())
  }
}

# --- 2) Kurtarılan gövdelerdeki REFERANSLAR ---------------------------------
$govdeDosyalari = Get-ChildItem -Path $parca -Filter '*.sql' | Sort-Object Name
$referanslar = @{}   # ad -> HashSet<dosya>

foreach ($g in $govdeDosyalari) {
  $t = Get-Content -Raw $g.FullName
  foreach ($m in [regex]::Matches($t, '(?i)\bpublic\.([a-z0-9_]+)')) {
    $ad = $m.Groups[1].Value.ToLower()
    if (-not $referanslar.ContainsKey($ad)) {
      $referanslar[$ad] = [System.Collections.Generic.HashSet[string]]::new()
    }
    [void]$referanslar[$ad].Add($g.Name)
  }
}

# --- 3) Rapor ---------------------------------------------------------------
Yaz "# Kurtarılan gövdelerin bağımlılık denetimi"
Yaz "# gövde dosyası: $($govdeDosyalari.Count) | migration dosyası: $($migrationDosyalari.Count)"
Yaz ""

$eksik = @()
$var = 0
foreach ($ad in ($referanslar.Keys | Sort-Object)) {
  if ($tanimli.Contains($ad)) { $var++; continue }
  $eksik += [pscustomobject]@{ Ad = $ad; Dosyalar = ($referanslar[$ad] | Sort-Object) -join ', ' }
}

Yaz "## TANIMLI ($var referans)"
Yaz ""
Yaz "## EKSİK ($($eksik.Count) referans) — canlıda var, disk+kurtarmada YOK"
foreach ($e in $eksik) {
  Yaz ("  {0,-38} <- {1}" -f $e.Ad, $e.Dosyalar)
}
Yaz ""

# --- 4) Gövdesi kurtarılmış ama migration'a HENÜZ yazılmamış fonksiyonlar ---
Yaz "## Gövdesi kurtarılmış, migration'da TANIMI olan/olmayan fonksiyonlar"
foreach ($g in $govdeDosyalari) {
  $ad = $g.BaseName.ToLower()
  $durum = if ($tanimliFonksiyon.Contains($ad)) { 'TANIMLI ' } else { 'EKSİK   ' }
  Yaz ("  {0} {1}" -f $durum, $g.BaseName)
}

$raporDizin = Join-Path $env:TEMP 'firsat'
if (-not (Test-Path $raporDizin)) { New-Item -ItemType Directory -Force -Path $raporDizin | Out-Null }
$raporYolu = Join-Path $raporDizin 'bagimlilik-raporu.txt'
Set-Content -Path $raporYolu -Value $rapor -Encoding utf8

foreach ($s in $rapor) { Write-Host $s }
Write-Host ""
Write-Host "Rapor: $raporYolu" -ForegroundColor Gray
if ($eksik.Count -gt 0) { exit 1 } else { exit 0 }
