# cron.job_run_details eski kayıtlarını bu bilgisayara yedekler, yedek doğrulanırsa uzaktan siler.
# Kullanım:  powershell -File scripts\cron-gunluk\arsivle.ps1 [-SaklamaGun 1] [-Sil]
# -Sil verilmezse yalnızca yedek alınır (kuru çalıştırma). Silme, dosyadaki satır sayısı
# veritabanındaki sayıyla eşleşmezse yapılmaz. Yedek git dışında durur.
param(
  [int]$SaklamaGun = 1,
  [string]$Hedef = 'C:\Dev\hupo-yedek\cron-gunlugu',
  [int]$Sayfa = 20000,
  [switch]$Sil
)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path (Split-Path $PSScriptRoot))
New-Item -ItemType Directory -Force $Hedef | Out-Null
$tmp = Join-Path $env:TEMP 'cron-arsiv.sql'

function Sorgu([string]$sql) {
  [IO.File]::WriteAllText($tmp, $sql, (New-Object Text.UTF8Encoding $false))
  $ham = cmd /c "npx supabase db query --linked --output-format json -f ""$tmp"" 2>nul" | Out-String
  $a = $ham.IndexOf('{'); $b = $ham.LastIndexOf('}')
  if ($a -lt 0 -or $b -le $a) { throw "CLI yanıtı okunamadı: $ham" }
  (($ham.Substring($a, $b - $a + 1)) | ConvertFrom-Json).rows
}

$ust = Sorgu "select coalesce(max(runid),0) maxr, count(*) n from cron.job_run_details where start_time < now() - interval '$SaklamaGun day'"
$maxr = [int64]$ust.maxr
if ($maxr -eq 0) { 'Arşivlenecek kayıt yok.'; return }
$beklenen = [int64](Sorgu "select count(*) n from cron.job_run_details where runid <= $maxr").n

$dosya = Join-Path $Hedef ("cron-job_run_details_{0}_runid-{1}.jsonl" -f (Get-Date -Format 'yyyyMMdd-HHmmss'), $maxr)
$son = 0L; $yazilan = 0L
while ($true) {
  $satirlar = Sorgu "select runid, jobid, job_pid, database, username, command, status, return_message, start_time, end_time from cron.job_run_details where runid > $son and runid <= $maxr order by runid limit $Sayfa"
  if (-not $satirlar -or @($satirlar).Count -eq 0) { break }
  $metin = (@($satirlar) | ForEach-Object { $_ | ConvertTo-Json -Compress }) -join "`n"
  [IO.File]::AppendAllText($dosya, $metin + "`n", (New-Object Text.UTF8Encoding $false))
  $yazilan += @($satirlar).Count
  $son = [int64]@($satirlar)[-1].runid
  "Yedeklendi: $yazilan / $beklenen"
}

$dosyadaki = (Get-Content $dosya | Measure-Object -Line).Lines
"Dosya: $dosya ($dosyadaki satır, beklenen $beklenen)"
if ($dosyadaki -ne $beklenen) { throw 'Satır sayısı eşleşmiyor, silme yapılmadı.' }
if (-not $Sil) { 'Kuru çalıştırma: silinmedi (-Sil ile sil).'; return }

Sorgu "with d as (delete from cron.job_run_details where runid <= $maxr returning 1) select count(*) n from d" | Out-Null
$kalan = (Sorgu "select count(*) n from cron.job_run_details").n
"Silindi. Veritabanında kalan kayıt: $kalan"
