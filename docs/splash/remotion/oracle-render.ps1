<#
Remotion kompozisyonlarini Oracle sunucusunda render eder (mevcut video-studio-render imajindan tek seferlik kapsayici,
2 cekirdek / 4 GB, --rm). Servislere ve ~/hupo-motion'a dokunmaz. Dosya ASCII tutulur (PowerShell 5.1).

  kareler  : tum kareleri kucuk JPEG dizisi olarak uretir (gozle inceleme icin)
  video    : H.264 MP4 (+ -Webm ile VP9 WebM) ve -Poster ile PNG kare uretir
Ornek:
  powershell -File docs/splash/remotion/oracle-render.ps1 -Mod kareler -Comp HupoGirisMobil -OutDir $env:TEMP\giris
  powershell -File docs/splash/remotion/oracle-render.ps1 -Mod video -Comp HupoGirisMobil,HupoGirisWeb -Webm -PosterFrame 150 -OutDir docs/splash/giris-film
Yazi tipi (Nunito) render sirasinda ag gerektirir.
#>
param(
    [ValidateSet('kareler', 'video')][string]$Mod = 'kareler',
    [Parameter(Mandatory)][string[]]$Comp,
    [Parameter(Mandatory)][string]$OutDir,
    [double]$Olcek = 0.4,
    [int]$Crf = 18,
    [switch]$Webm,
    [int]$PosterFrame = -1
)
$ErrorActionPreference = 'Stop'
$Comp = $Comp | ForEach-Object { $_ -split ',' }  # -File ile gelen "A,B" tek metin olur
$here = $PSScriptRoot
$repo = Resolve-Path (Join-Path $here '..\..\..')
$oracle = 'C:\Dev\video-studio\scripts\oracle\oracle.ps1'
if (-not (Test-Path $oracle)) { throw "Oracle koprusu yok: $oracle" }

$stage = Join-Path $env:TEMP ('hupo-giris-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force "$stage\public" | Out-Null
Copy-Item -Recurse "$here\src" "$stage\src"
Copy-Item -Recurse "$here\data" "$stage\data"
Copy-Item "$here\audio\giris_ses.wav" "$stage\public\giris_ses.wav"
$ass = Join-Path $repo 'mobile-app\assets\hupo\splash'
foreach ($f in 'hupo_govde_kanatsiz', 'hupo_kanat_sag', 'hupo_kanat_sol', 'hupo_goz_kapali', 'hupo_goz_mutlu', 'hupo_govde', 'hupo_kanat') {
    Copy-Item "$ass\$f.webp" "$stage\public\$f.webp"
}

$R = '/app/node_modules/.bin/remotion'
$cmd = New-Object System.Collections.Generic.List[string]
foreach ($c in $Comp) {
    if ($Mod -eq 'kareler') {
        $cmd.Add("$R render src/index.ts $c out/$c-kare --sequence --image-format=jpeg --jpeg-quality=80 --scale=$Olcek --public-dir=public --concurrency=2 --log=error 2>&1 | tail -6")
    } else {
        $cmd.Add("$R render src/index.ts $c out/$c.mp4 --public-dir=public --codec=h264 --crf=$Crf --pixel-format=yuv420p --concurrency=2 --log=error 2>&1 | tail -6")
        if ($Webm) { $cmd.Add("$R render src/index.ts $c out/$c.webm --public-dir=public --codec=vp9 --crf=32 --concurrency=2 --log=error 2>&1 | tail -6") }
        if ($PosterFrame -ge 0) { $cmd.Add("$R still src/index.ts $c out/$c-poster.png --frame=$PosterFrame --public-dir=public --log=error 2>&1 | tail -3") }
    }
}
$cmdText = $cmd -join "`n"
$task = @"
#!/usr/bin/env bash
cd "`$(dirname "`$0")"
chmod -R 777 input output
cat > input/run.sh <<'EOS'
set -e
cd /work
ln -sfn /app/node_modules node_modules
mkdir -p out
$cmdText
EOS
START=`$(date +%s)
sudo docker run --rm --cpus=2 --memory=4g --shm-size=1g --user "`$(id -u):`$(id -g)" -e HOME=/tmp -v "`$PWD/input:/work" --entrypoint sh video-studio-render:latest /work/run.sh
echo "render suresi: `$((`$(date +%s) - START)) sn"
cp -r input/out/. output/
du -sh output
"@
Set-Content -Path "$stage\task.sh" -Value $task -Encoding ASCII
New-Item -ItemType Directory -Force $OutDir | Out-Null
$inputDir = Join-Path $stage 'in'
New-Item -ItemType Directory -Force $inputDir | Out-Null
Move-Item "$stage\src", "$stage\data", "$stage\public" $inputDir
& $oracle task -Script "$stage\task.sh" -InputDir $inputDir -OutDir $OutDir
Remove-Item -Recurse -Force $stage
Get-Content (Join-Path $OutDir 'job.log') | Select-Object -Last 25
