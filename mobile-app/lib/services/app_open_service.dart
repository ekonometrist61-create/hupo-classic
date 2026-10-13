// Açılış deneyiminin karar katmanı: uygulamanın nasıl açıldığını sınıflandırır
// ve ilk karşılamanın gösterilip gösterilmeyeceğine karar verir.
//
// Bu dosya animasyondan bağımsızdır: yalnızca "hangi sahne gösterilmeli?"
// sorusunu yanıtlar. Böylece oturum/ağ durumu animasyona yapay bağımlı olmaz.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulamanın açılış biçimi. Açılış sahnesinin uzunluğunu ve içeriğini belirler.
enum AppOpenKind {
  /// Cihazda ilk kez açılış: tam "Kanat İmzası" deneyimi oynatılır.
  firstLaunch,

  /// Soğuk açılış (süreç yeniden başladı): tam deneyim, kısa ilk kareyle.
  coldStart,

  /// Sıcak açılış (süreç bellekte kaldı): yalnızca çok kısa mikro karşılama.
  warmStart,

  /// Arka plandan dönüş (resume): animasyon YENİDEN oynatılmaz.
  resume,

  /// Tek sayfalık doğrudan yönlendirme (deep link / auth redirect).
  /// Ana sayfa animasyonuna zorla yönlendirilmez.
  directRedirect,
}

/// Açılış sahnesinin oynatılıp oynatılmayacağını ve süresini belirten karar.
class AppOpenPlan {
  const AppOpenPlan({
    required this.kind,
    required this.playFullBrandScene,
    required this.microGreeting,
    required this.duration,
  });

  final AppOpenKind kind;

  /// true ise Sahne 1–4'ün tamamı ("Kanat İmzası") oynatılır.
  final bool playFullBrandScene;

  /// true ise yalnızca kısa, sessiz bir mikro karşılama gösterilir.
  final bool microGreeting;

  /// Sahnenin toplam hedef süresi. Hiç animasyon yoksa [Duration.zero].
  final Duration duration;

  /// Sahne hiç gösterilmeyecekse doğrudan içeriğe geçilir.
  bool get skip => !playFullBrandScene && !microGreeting;
}

/// Tam "Kanat İmzası" sahnesinin hedef süresi (Sahne 1–4: 0–1600 ms).
const Duration kHupoSahneToplam = Duration(milliseconds: 1600);

/// Sıcak açılış mikro karşılaması (400–800 ms bandı).
const Duration kHupoMikroKarsilama = Duration(milliseconds: 600);

/// Karşılama bayrağının saklandığı anahtar. Bu bir **kullanıcı tercihi değil**,
/// cihaz/oturum yaşam döngüsü durumudur; ayarlardan sıfırlanmasına gerek yoktur.
const String _kFirstGreetingDone = 'hupo_first_greeting_done';

/// İlk karşılamanın cihazda bir kez gösterildiğini kalıcı olarak işaretler.
///
/// Bu bayrak `SharedPreferences` yerine yalnızca bu amaçla tutulur; oturum
/// durumundan bağımsızdır (oturum kapatılıp açılsa da tam sahne tekrar oynamaz).
Future<void> markFirstGreetingDone(SharedPreferences prefs) =>
    prefs.setBool(_kFirstGreetingDone, true);

/// Tam sahnenin bu cihazda daha önce gösterilip gösterilmediği.
bool firstGreetingDone(SharedPreferences prefs) =>
    prefs.getBool(_kFirstGreetingDone) ?? false;

/// Açılış türüne göre plan üretir.
///
/// [reducedMotion] true ise hareketli sahneler kaldırılır; yalnızca statik bir
/// marka karesi kısa süre gösterilir veya tamamen atlanır.
AppOpenPlan planAppOpen({
  required AppOpenKind kind,
  required bool reducedMotion,
}) {
  switch (kind) {
    case AppOpenKind.firstLaunch:
    case AppOpenKind.coldStart:
      if (reducedMotion) {
        // Hareket azalt: animasyon yok, kısa statik marka karesi.
        return const AppOpenPlan(
          kind: AppOpenKind.coldStart,
          playFullBrandScene: false,
          microGreeting: true,
          duration: Duration(milliseconds: 500),
        );
      }
      return const AppOpenPlan(
        kind: AppOpenKind.firstLaunch,
        playFullBrandScene: true,
        microGreeting: false,
        duration: kHupoSahneToplam,
      );
    case AppOpenKind.warmStart:
      return AppOpenPlan(
        kind: AppOpenKind.warmStart,
        playFullBrandScene: false,
        microGreeting: !reducedMotion,
        duration: reducedMotion ? Duration.zero : kHupoMikroKarsilama,
      );
    case AppOpenKind.resume:
    case AppOpenKind.directRedirect:
      return AppOpenPlan(
        kind: kind,
        playFullBrandScene: false,
        microGreeting: false,
        duration: Duration.zero,
      );
  }
}

/// Açılış türünü cihaz yaşam döngüsü ve bayraklardan çıkarır.
///
/// Saf fonksiyondur (test edilebilir): yan etkisi yoktur, yalnızca karar verir.
AppOpenKind resolveAppOpenKind({
  required bool firstGreetingDone,
  required bool resumedFromBackground,
  required bool isDeepLink,
}) {
  if (resumedFromBackground) return AppOpenKind.resume;
  if (isDeepLink) return AppOpenKind.directRedirect;
  if (!firstGreetingDone) return AppOpenKind.firstLaunch;
  return AppOpenKind.coldStart;
}

/// Açılış sahnesinin ortak yumuşak eğrisi (giriş-çıkış).
const Curve kHupoEase = Curves.easeOutCubic;
