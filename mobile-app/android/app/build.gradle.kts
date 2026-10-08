import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Yayin (release) imzasi: android/key.properties dosyasi varsa kullanilir.
// Yoksa debug anahtariyla imzalanir (sadece test icin; Play Store bunu KABUL ETMEZ).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKey = keystorePropertiesFile.exists()
if (hasReleaseKey) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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
        minSdk = flutter.minSdkVersion
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
