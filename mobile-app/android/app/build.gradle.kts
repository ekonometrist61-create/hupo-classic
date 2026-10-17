import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase (push): google-services.json okur. Yapılandırma dosyası yoksa derleme hata verir.
    id("com.google.gms.google-services")
}

// Yayin (release) imzasi: android/key.properties dosyasi varsa kullanilir.
// Yoksa: APK (assembleRelease) yalnizca yerel test icin debug anahtariyla imzalanir ve uyari verilir.
// AAB (bundleRelease) Play Store'a gider; release anahtari yoksa derlenmez (TASKS.md §11.3).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKey = keystorePropertiesFile.exists()
if (hasReleaseKey) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val releaseGorevleri = gradle.startParameter.taskNames
if (!hasReleaseKey && releaseGorevleri.any { it.contains("bundleRelease", ignoreCase = true) }) {
    throw GradleException("AAB yayin derlemesi icin android/key.properties (release anahtari) gerekli. Debug anahtariyla Play Store paketi uretilmez.")
}
if (!hasReleaseKey && releaseGorevleri.any { it.contains("assembleRelease", ignoreCase = true) }) {
    logger.warn("UYARI: release anahtari yok (android/key.properties). APK debug anahtariyla imzaladi; magaza icin kullanmayin.")
}

android {
    namespace = "com.ogrencihazirlik.ogrenci_hazirlik"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // DIKKAT: applicationId magazaya ilk yukleme yapildiktan sonra DEGISTIRILEMEZ.
        // Degistirmek istersen once store/KIMLIK_VE_HESAPLAR.md dosyasini oku.
        applicationId = "com.ogrencihazirlik.ogrenci_hazirlik"
        // flutter_secure_storage Android Keystore API'si minSdk 23 gerektirir.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        // Surum numaralari pubspec.yaml'daki "version: 1.0.0+1" satirindan gelir
        // (1.0.0 = versionName, +1 = versionCode; her magaza yuklemesinde +N artmali).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
