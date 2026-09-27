// Buyuk ZIP'leri acarken PowerShell'in Expand-Archive modulu
// "Merkezi Dizinin Sonu kaydı bulunamadi" hatasini veriyor.
// .NET'in ZipFile API'sini dogrudan kullanarak aciyoruz.
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const zip = process.argv[2];
const dest = process.argv[3];

fs.mkdirSync(dest, { recursive: true });

// .NET'in System.IO.Compression.FileSystem tek assembly olarak yuklenir.
// ExtractToFile tek tek cagrilir; 40k+ girdiye dayanir.
const ps = `
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$a = [System.IO.Compression.ZipFile]::OpenRead('${zip.replace(/'/g, "''")}')
$n = 0
try {
  foreach ($e in $a.Entries) {
    $t = Join-Path '${dest.replace(/'/g, "''")}' ($e.FullName -replace '/', '\\')
    if ($e.FullName.EndsWith('/')) { New-Item -ItemType Directory -Path $t -Force | Out-Null; continue }
    $p = Split-Path $t -Parent
    if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e, $t, $true)
    $n++
    if ($n % 5000 -eq 0) { Write-Output "  ... $n" }
  }
} finally { $a.Dispose() }
Write-Output "acilan dosya: $n"
`;

fs.writeFileSync(path.join(require("os").tmpdir(), "unzip-helper.ps1"), ps, "utf8");
const out = execFileSync(
  "powershell.exe",
  ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", path.join(require("os").tmpdir(), "unzip-helper.ps1")],
  { encoding: "utf8" }
);
process.stdout.write(out);
