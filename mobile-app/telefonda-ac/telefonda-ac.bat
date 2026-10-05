@echo off
chcp 65001 >nul
title Uygulamayi Telefonda Ac (Flutter web onizleme)
setlocal

rem ============================================================
rem  TELEFONDA ONIZLEME
rem  Flutter, OneDrive icindeki Turkce karakterli yola yazamadigi
rem  icin proje once ASCII bir calisma kopyasina aynalanir, orada
rem  web icin derlenir ve yerel agda yayinlanir. Telefonun
rem  tarayicisindan ekranda gorunen adres acilir.
rem ============================================================

rem --- Flutter SDK'yi otomatik bul -------------------------------------
set "FLUTTER_BIN="
for %%P in (
  "C:\Users\cengi\Downloads\flutter-sdk\flutter\bin"
  "C:\src\flutter\bin"
  "C:\flutter\bin"
  "%LOCALAPPDATA%\flutter\bin"
  "%USERPROFILE%\flutter\bin"
) do if not defined FLUTTER_BIN if exist "%%~P\flutter.bat" set "FLUTTER_BIN=%%~P"
if not defined FLUTTER_BIN for /f "delims=" %%i in ('where flutter 2^>nul') do if not defined FLUTTER_BIN set "FLUTTER_BIN=%%~dpi"
if not defined FLUTTER_BIN (
  echo.
  echo  HATA: Flutter SDK bulunamadi.
  echo  Cozum: Flutter'i kurun veya bu dosyadaki yol listesine ekleyin.
  goto son
)
set "PATH=%FLUTTER_BIN%;%PATH%"

rem --- Kaynak ve ASCII calisma kopyasi --------------------------------
set "KAYNAK=%~dp0.."
set "CALISMA=C:\Users\cengi\flutterwork\mobile-app"
set "PORT=8080"

echo.
echo ================================================
echo   Uygulama hazirlaniyor... (ilk seferde 3-6 dk surebilir)
echo   Lutfen bu pencereyi KAPATMAYIN.
echo ================================================
echo.

rem --- 1) Projeyi ASCII konuma aynala ---------------------------------
echo   [1/3] Proje hazirlaniyor: %CALISMA%
robocopy "%KAYNAK%" "%CALISMA%" /MIR /XD build .dart_tool .git /XF *.log >nul
if errorlevel 8 (
  echo.
  echo  HATA: Proje kopyalanamadi. Yol veya izin sorunu olabilir:
  echo         %CALISMA%
  goto son
)

rem --- 2) Derle ------------------------------------------------------
echo   [2/3] Uygulama derleniyor (web). Bu adim uzun surebilir...
pushd "%CALISMA%"
call flutter pub get
if errorlevel 1 goto derleme_hatasi
call flutter build web --release
if errorlevel 1 goto derleme_hatasi
popd

rem --- 3) Guvenlik duvari + sunucu -----------------------------------
echo   [3/3] Sunucu baslatiliyor...
net session >nul 2>&1
if not errorlevel 1 (
  netsh advfirewall firewall show rule name="Telefonda Ac %PORT%" >nul 2>&1
  if errorlevel 1 netsh advfirewall firewall add rule name="Telefonda Ac %PORT%" dir=in action=allow protocol=TCP localport=%PORT% profile=private >nul 2>&1
) else (
  echo   NOT: Yonetici olmadiginiz icin guvenlik duvari kurali eklenemedi.
  echo        Gerekirse OKU-BENI.md bolum 4.4'teki komutu yonetici olarak calistirin.
)

echo.
echo ================================================
echo   HAZIR!  Asagida "Sunucu calisiyor" yazisinin altindaki
echo   adresi telefonunuzun tarayicisina yazin. Ornek:
echo        http://192.168.1.91:%PORT%
echo.
echo   * Telefon bu bilgisayarla AYNI Wi-Fi'ye bagli olmali.
echo   * Bu pencere acik kaldigi surece uygulama calisir.
echo   * Kapatmak icin: bu pencereyi kapatin veya Ctrl+C.
echo ================================================
echo.

call dart run "%CALISMA%\telefonda-ac\sunucu.dart" "%CALISMA%\build\web" %PORT%
goto son

:derleme_hatasi
popd
goto hata

:hata
echo.
echo BIR HATA OLDU. Bu pencerenin ekran goruntusunu bize gonderin.
:son
pause
