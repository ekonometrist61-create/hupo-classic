# =====================================================================
#  istemci-rpc-denetimi.ps1 — istemci çağrıları ile şema uyumu
#
#  Ne yapar?
#    mobile-app/lib/**/*.dart  ve  web-panel/src/**/*.ts(x)  içindeki
#      supabase.rpc('ad')  /  client.rpc("ad")
#    çağrılarını toplar, supabase/migrations/*.sql içindeki
#    "create function public.<ad>" tanımlarıyla karşılaştırır.
#
#  Neden?
#    Diskte tanımı olmayan bir RPC'yi istemci çağırıyorsa o ekran
#    ÇALIŞMA ANINDA kırılır ("function ... does not exist").
#    Bu araç o kırılmaları migration yazmadan önce gösterir.
#
#  Kullanım:  powershell -NoProfile -File tools\istemci-rpc-denetimi.ps1
#  Rapor   :  %TEMP%\firsat\istemci-rpc-raporu.txt  (UTF-8)
# =====================================================================

$ErrorActionPreference = 'Stop'
$kok = Split-Path -Parent $PSScriptRoot
$mig = Join-Path $kok 'supabase\migrations'
$tst = Join-Path $kok 'supabase\tests'

$rapor = New-Object System.Collections.Generic.List[string]
function Yaz([string]$metin) { $script:rapor.Add($metin) }

# --- 1) İstemci çağrıları ---------------------------------------------------
$desenRpc = 'rpc\(\s*[''""]([a-z0-9_]+)[''""]'
$cagrilar = @{}          # ad -> HashSet<yer>
$cagriSayaci = 0

$dart = Get-ChildItem (Join-Path $kok 'mobile-app\lib') -Recurse -File -Filter '*.dart' -ErrorAction SilentlyContinue
$web  = Get-ChildItem (Join-Path $kok 'web-panel\src') -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in '.ts', '.tsx' }
$istemciDosyalari = @($dart) + @($web)

foreach ($f in $istemciDosyalari) {
  $satirlar = Get-Content -LiteralPath $f.FullName
  for ($i = 0; $i -lt $satirlar.Count; $i++) {
    foreach ($m in [regex]::Matches($satirlar[$i], $desenRpc)) {
      $ad = $m.Groups[1].Value.ToLower()
      if (-not $cagrilar.ContainsKey($ad)) {
        $cagrilar[$ad] = [System.Collections.Generic.HashSet[string]]::new()
      }
      [void]$cagrilar[$ad].Add("$($f.Name):$($i + 1)")
      $cagriSayaci++
    }
  }
}

# --- 2) Şemadaki fonksiyon tanımları ---------------------------------------
$tanimli = [System.Collections.Generic.HashSet[string]]::new()
foreach ($d in (@(Get-ChildItem -Path $mig -Filter '*.sql') + @(Get-ChildItem -Path $tst -Filter '*.sql'))) {
  $t = Get-Content -Raw $d.FullName
  foreach ($m in [regex]::Matches($t, '(?i)create\s+(or\s+replace\s+)?function\s+public\.([a-z0-9_]+)')) {
    [void]$tanimli.Add($m.Groups[2].Value.ToLower())
  }
}

# --- 3) Rapor --------------------------------------------------------------
Yaz "# İstemci RPC çağrıları ↔ şema uyumu"
Yaz "# istemci dosyası: $($istemciDosyalari.Count) | çağrı: $cagriSayaci | farklı RPC: $($cagrilar.Count)"
Yaz ""

$eksik = @($cagrilar.Keys | Where-Object { -not $tanimli.Contains($_) } | Sort-Object)

Yaz "## ÇAĞRILAN ($($cagrilar.Count))"
foreach ($ad in ($cagrilar.Keys | Sort-Object)) {
  $durum = if ($tanimli.Contains($ad)) { 'TANIMLI' } else { 'EKSİK  ' }
  Yaz ("  {0} {1,-40} {2}" -f $durum, $ad, (($cagrilar[$ad] | Sort-Object) -join ', '))
}
Yaz ""
Yaz "## EKSİK ($($eksik.Count)) — istemci çağırıyor, şemada tanım yok"
foreach ($ad in $eksik) {
  Yaz ("  {0,-40} <- {1}" -f $ad, (($cagrilar[$ad] | Sort-Object) -join ', '))
}

$raporDizin = Join-Path $env:TEMP 'firsat'
if (-not (Test-Path $raporDizin)) { New-Item -ItemType Directory -Force -Path $raporDizin | Out-Null }
$raporYolu = Join-Path $raporDizin 'istemci-rpc-raporu.txt'
Set-Content -Path $raporYolu -Value $rapor -Encoding utf8

foreach ($s in $rapor) { Write-Host $s }
Write-Host ""
Write-Host "Rapor: $raporYolu" -ForegroundColor Gray
if ($eksik.Count -gt 0) { exit 1 } else { exit 0 }
