@echo off
chcp 65001 >nul
title Uygulamayi Telefonda Ac
set "PATH=C:\src\flutter\bin;%PATH%"
cd /d "%~dp0.."

echo.
echo ================================================
echo   Uygulama hazirlaniyor... (ilk seferde 3-6 dk surebilir)
echo   Lutfen bu pencereyi KAPATMAYIN.
echo ================================================
echo.

call flutter pub get
if errorlevel 1 goto hata
call flutter build web --release
if errorlevel 1 goto hata

set "IP="
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1).IPv4Address.IPAddress"`) do set "IP=%%i"
if "%IP%"=="" set "IP=BILGISAYAR-IP-ADRESI"

echo.
echo ================================================
echo   HAZIR!  Telefonunuzun tarayicisina su adresi yazin:
echo.
echo        http://%IP%:8080
echo.
echo   * Telefon bu bilgisayarla AYNI Wi-Fi'ye bagli olmali.
echo   * Bu pencere acik kaldigi surece uygulama calisir.
echo   * Kapatmak icin: bu pencereyi kapatin veya Ctrl+C.
echo ================================================
echo.
call dart run "%~dp0sunucu.dart" build\web 8080
goto son

:hata
echo.
echo BIR HATA OLDU. Bu pencerenin fotografini/ekran goruntusunu bize gonderin.
:son
pause
