@echo off
setlocal
title Imza anahtari olustur (Ogrenci Hazirlik)
echo ======================================================================
echo   UYGULAMA IMZA ANAHTARI (KEYSTORE) OLUSTURMA
echo ======================================================================
echo.
echo   !!! COK ONEMLI - LUTFEN OKUYUN !!!
echo   Bu islem bir "anahtar dosyasi" (.jks) uretir. Uygulamanin her
echo   guncellemesi bu anahtarla imzalanir.
echo     * Bu dosyayi veya sifresini KAYBEDERSENIZ uygulamayi bir daha
echo       guncelleyemezsiniz (Google ile ugrasmak gerekir, haftalar surer).
echo     * Dosyayi ve sifreyi en az 2 yere yedekleyin (USB bellek + e-posta
echo       veya sifreli bulut). Sifreyi bir kagida da yazin.
echo     * Dosyayi ve sifreyi KIMSEYLE paylasmayin, internete yuklemeyin.
echo.
echo   Sifre icin sadece HARF ve RAKAM kullanin (ozel isaret KULLANMAYIN:
echo   ! %% ^& ^< ^> gibi isaretler bu programi bozar). En az 8 karakter.
echo ======================================================================
echo.
pause

rem ---- keytool'u bul ----
set "KEYTOOL="
where keytool >nul 2>nul && set "KEYTOOL=keytool"
if not defined KEYTOOL if defined JAVA_HOME if exist "%JAVA_HOME%\bin\keytool.exe" set "KEYTOOL=%JAVA_HOME%\bin\keytool.exe"
if not defined KEYTOOL if exist "%ProgramFiles%\Android\Android Studio\jbr\bin\keytool.exe" set "KEYTOOL=%ProgramFiles%\Android\Android Studio\jbr\bin\keytool.exe"
if not defined KEYTOOL if exist "%LOCALAPPDATA%\Programs\Android Studio\jbr\bin\keytool.exe" set "KEYTOOL=%LOCALAPPDATA%\Programs\Android Studio\jbr\bin\keytool.exe"
if not defined KEYTOOL (
  echo.
  echo HATA: keytool ^(Java^) bulunamadi.
  echo Once Android Studio'yu kurun ^(store\ANDROID_KURULUM.md, Adim 1^),
  echo sonra bu dosyayi tekrar calistirin.
  pause
  exit /b 1
)
echo keytool bulundu: %KEYTOOL%
echo.

set "DIR=%USERPROFILE%\ogrenci-hazirlik-anahtar"
set "JKS=%DIR%\upload-keystore.jks"
if exist "%JKS%" (
  echo HATA: Zaten bir anahtar dosyasi var: %JKS%
  echo Uzerine YAZMIYORUM ^(eskisini kaybetmemeniz icin^). Gerekirse elle tasiyin.
  pause
  exit /b 1
)
if not exist "%DIR%" mkdir "%DIR%"

set /p ADSOYAD=Adiniz Soyadiniz (Turkce harf kullanmayin, ornek: Ali Yilmaz): 
set /p KURUM=Kurum/firma adi (yoksa bos birakip Enter): 
if "%KURUM%"=="" set "KURUM=Bireysel"
set /p SIFRE=Bir sifre belirleyin (sadece harf-rakam, en az 8 karakter): 
if "%SIFRE%"=="" (
  echo Sifre bos olamaz.
  pause
  exit /b 1
)

"%KEYTOOL%" -genkeypair -v -keystore "%JKS%" -storetype JKS -alias upload -keyalg RSA -keysize 2048 -validity 10000 -storepass "%SIFRE%" -keypass "%SIFRE%" -dname "CN=%ADSOYAD%, O=%KURUM%, C=TR"
if errorlevel 1 (
  echo.
  echo HATA: Anahtar olusturulamadi. Yukaridaki mesaji kontrol edin.
  pause
  exit /b 1
)

rem ---- android\key.properties dosyasini yaz ----
set "PROJ=%~dp0.."
set "JKSFWD=%JKS:\=/%"
(
  echo storePassword=%SIFRE%
  echo keyPassword=%SIFRE%
  echo keyAlias=upload
  echo storeFile=%JKSFWD%
) > "%PROJ%\android\key.properties"

echo.
echo ======================================================================
echo   TAMAM! Anahtar olusturuldu:
echo     %JKS%
echo   Ayar dosyasi yazildi:
echo     %PROJ%\android\key.properties
echo.
echo   SIMDI YAPIN: %DIR% klasorunu USB bellege ve baska bir
echo   guvenli yere KOPYALAYIN. Sifreniz: %SIFRE%  (bir kagida yazin)
echo ======================================================================
pause
