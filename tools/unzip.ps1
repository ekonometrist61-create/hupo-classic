$ErrorActionPreference = 'Stop'
# Buyuk ZIP'leri acarken PowerShell'in Expand-Archive modulu
# "Merkezi Dizinin Sonu kaydı bulunamadi" hatasini veriyor.
# .NET'in ZipFile API'sini dogrudan kullanarak aciyoruz.
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = $args[0]
$dest = $args[1]

if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
}

$archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
$count = 0
try {
    foreach ($entry in $archive.Entries) {
        $target = Join-Path $dest ($entry.FullName -replace '/', '\')
        if ($entry.FullName.EndsWith('/')) {
            New-Item -ItemType Directory -Path $target -Force | Out-Null
            continue
        }
        $parent = Split-Path $target -Parent
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $target, $true)
        $count++
    }
} finally {
    $archive.Dispose()
}
Write-Output "acilan dosya: $count"
