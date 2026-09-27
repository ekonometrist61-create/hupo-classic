$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zip = 'C:\Users\cengi\Downloads\flutter.zip'
$dest = 'C:\Users\cengi\Downloads\flutter-sdk'

if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
}

$archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
$n = 0
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
        $n++
        if ($n % 20000 -eq 0) { Write-Output "  ... $n" }
    }
} finally {
    $archive.Dispose()
}
Write-Output "DONE: $n dosya"
