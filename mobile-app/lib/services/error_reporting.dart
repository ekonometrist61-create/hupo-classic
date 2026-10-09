import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Hata raporlama kurulumu.
///
/// * [dsn] verilmişse (`--dart-define=SENTRY_DSN=...`) hatalar Sentry'ye gider.
///   Sentry kendi FlutterError ve PlatformDispatcher kancalarını kurar; bu yüzden
///   burada onları ezmiyoruz.
/// * [dsn] boşsa yalnızca yerel debugPrint kancası kurulur (geliştirme ve test).
///
/// Çocuk verisi taşıdığı için Sentry olaylarında kişisel veri gitmez:
/// kullanıcı bilgisi yok (sendDefaultPii kapalı), hata mesajı ve istisna metni
/// gizlenir (yalnızca hata türü kalır), breadcrumb'lar gönderilmez.
Future<void> baslatHataRaporlama(
  Future<void> Function() uygulamaBaslat, {
  required String dsn,
}) async {
  if (dsn.isEmpty) {
    installErrorReporting();
    await uygulamaBaslat();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = dsn;
      options.sendDefaultPii = false;
      options.tracesSampleRate = 0;
      options.environment = kReleaseMode ? 'production' : 'development';
      options.beforeSend = kisisiVerileriTemizle;
    },
    appRunner: uygulamaBaslat,
  );
}

/// Sentry'ye gitmeden önce olayı temizler. Mesaj ve istisna metinleri e-posta veya
/// ad içerebilir; bunlar yerine sabit bir etiket konur. Breadcrumb'lar tamamen atılır.
SentryEvent? kisisiVerileriTemizle(SentryEvent event, Hint hint) {
  return event.copyWith(
    message: const SentryMessage('[gizlendi]'),
    throwable: '[gizlendi]',
    exceptions: event.exceptions
        ?.map((istisna) => istisna.copyWith(value: '[gizlendi]'))
        .toList(),
    breadcrumbs: const [],
  );
}

/// Sentry yokken (DSN boş) yakalanmamış hataları yalnızca yerel olarak yazar.
/// Hata mesajı bilerek yazılmaz: kişisel veri içerebilir (AGENTS.md §5).
void installErrorReporting() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    reportError(details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    reportError(error, stack);
    return true;
  };
}

void reportError(Object error, StackTrace? stack) {
  debugPrint('Yakalanmamış hata: ${error.runtimeType}');
  if (stack != null) debugPrint(stack.toString());
}
