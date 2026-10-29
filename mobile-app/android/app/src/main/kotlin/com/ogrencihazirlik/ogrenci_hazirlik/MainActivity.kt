package com.ogrencihazirlik.ogrenci_hazirlik

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+ sistem splash'inin solma animasyonunu kapat: Flutter'ın ilk
            // karesi aynı Hupo'yu aynı yerde çizer, solma yalnız titreme yaratır.
            // (docs.flutter.dev/platform-integration/android/splash-screen)
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }
        super.onCreate(savedInstanceState)
    }
}
