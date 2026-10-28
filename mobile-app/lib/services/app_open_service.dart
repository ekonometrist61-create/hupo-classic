// Açılış deneyiminin karar katmanı: uygulamanın nasıl açıldığını sınıflandırır
// ve hangi açılış sahnesinin oynatılacağına karar verir.
//
// Bu dosya animasyondan bağımsızdır: yalnızca "hangi sahne gösterilmeli?"
// sorusunu yanıtlar. Böylece oturum/ağ durumu animasyona yapay bağımlı olmaz.
//
// Gerçek durumlar yalnızca ikidir (bkz. docs/splash/ACILIS_SENARYOSU_PLANI.md §3):
//  * İlk açılış      → tam sahne + marka sesi.
//  * Sonraki açılış  → kısa sahne, sessiz.
// Arka plandan dönüşte `SplashGate` zaten yeniden kurulmaz; sahne oynamaz.
// Deep link eklendiğinde (şu an yok) buraya yeni bir durum eklenir.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulamanın açılış biçimi.
enum AppOpenKind {
  /// Cihazda ilk açılış: tam "Kanat İmzası" sahnesi ve marka sesi.
  firstLaunch,

  /// Sonraki soğuk açılışlar: kısa, sessiz sahne.
  coldStart,
}

/// Oynatılacak sahnenin türü.
enum AppOpenScene {
  /// Tam sahne: marka adı, halka, kıvılcımlar.
  full,

  /// Kısa sahne: Hupo uyanır, kanat imzası; marka adı ve ses yok.
  short,

  /// Hareket yok: kısa statik marka karesi.
  still,
}

/// Açılış sahnesinin ne olacağını ve süresini belirten karar.
class AppOpenPlan {
  const AppOpenPlan({
    required this.kind,
    required this.scene,
    required this.duration,
  });

  final AppOpenKind kind;
  final AppOpenScene scene;

  /// Sahnenin toplam hedef süresi.
  final Duration duration;

  /// Marka sesi yalnızca ilk açılışta ve hareketli tam sahnede çalınır.
  bool get playBrandSound =>
      kind == AppOpenKind.firstLaunch && scene == AppOpenScene.full;
}

/// Tam "Kanat İmzası" sahnesinin hedef süresi (ilk açılış).
const Duration kHupoSahneToplam = Duration(milliseconds: 2000);

/// Sonraki açılışlarda kısa sahnenin süresi (hedef ≤ 900 ms).
const Duration kHupoKisaSahne = Duration(milliseconds: 900);

/// Hareket azalt açıkken statik karenin süresi.
const Duration kHupoStatikKare = Duration(milliseconds: 500);

/// Dokunarak atlamanın açılacağı eşik: sahne bundan önce atlanamaz.
const Duration kHupoAtlamaEsigi = Duration(milliseconds: 600);

/// Karşılama bayrağının saklandığı anahtar. Bu bir **kullanıcı tercihi değil**,
/// cihaz/oturum yaşam döngüsü durumudur; ayarlardan sıfırlanmasına gerek yoktur.
const String _kFirstGreetingDone = 'hupo_first_greeting_done';

/// İlk karşılamanın cihazda bir kez gösterildiğini kalıcı olarak işaretler.
///
/// Oturum durumundan bağımsızdır (oturum kapatılıp açılsa da tam sahne tekrar oynamaz).
Future<void> markFirstGreetingDone(SharedPreferences prefs) =>
    prefs.setBool(_kFirstGreetingDone, true);

/// Tam sahnenin bu cihazda daha önce gösterilip gösterilmediği.
bool firstGreetingDone(SharedPreferences prefs) =>
    prefs.getBool(_kFirstGreetingDone) ?? false;

/// Açılış türüne göre plan üretir.
///
/// [reducedMotion] true ise hareketli sahneler kaldırılır; yalnızca statik bir
/// marka karesi kısa süre gösterilir.
AppOpenPlan planAppOpen({
  required AppOpenKind kind,
  required bool reducedMotion,
}) {
  if (reducedMotion) {
    return AppOpenPlan(
      kind: kind,
      scene: AppOpenScene.still,
      duration: kHupoStatikKare,
    );
  }
  switch (kind) {
    case AppOpenKind.firstLaunch:
      return const AppOpenPlan(
        kind: AppOpenKind.firstLaunch,
        scene: AppOpenScene.full,
        duration: kHupoSahneToplam,
      );
    case AppOpenKind.coldStart:
      return const AppOpenPlan(
        kind: AppOpenKind.coldStart,
        scene: AppOpenScene.short,
        duration: kHupoKisaSahne,
      );
  }
}

/// Açılış türünü cihaz bayrağından çıkarır.
///
/// Saf fonksiyondur (test edilebilir): yan etkisi yoktur, yalnızca karar verir.
AppOpenKind resolveAppOpenKind({required bool firstGreetingDone}) =>
    firstGreetingDone ? AppOpenKind.coldStart : AppOpenKind.firstLaunch;

/// Açılış sahnesinin ortak yumuşak eğrisi (giriş-çıkış).
const Curve kHupoEase = Curves.easeOutCubic;
