$ErrorActionPreference = 'Stop'

# Flutter'in OneDrive icindeki Turkce karakterli yoluna yazamama sorunu var
# (build/flutter_assets silinemiyor). Proje, temiz bir konumda sunuluyor.
$env:PATH = 'C:\Users\cengi\Downloads\flutter-sdk\flutter\bin;' + $env:PATH
$env:CHROME_EXECUTABLE = 'C:\Program Files\Google\Chrome\Application\chrome.exe'

Set-Location 'C:\Users\cengi\flutterwork\mobile-app'
& flutter.bat run -d web-server --web-port 8080 --web-hostname 127.0.0.1
