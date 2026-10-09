import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/error_reporting.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  test('Sentry olayı kişisel veri taşımadan temizlenir', () {
    final olay = SentryEvent(
      message: const SentryMessage('ali@ornek.com hata verdi'),
      throwable: 'ali@ornek.com',
      exceptions: [
        const SentryException(type: 'PostgrestException', value: 'ali@ornek.com'),
      ],
      breadcrumbs: [Breadcrumb(message: 'GET /rest/v1/profiles?email=ali')],
    );

    final temiz = kisisiVerileriTemizle(olay, Hint());

    expect(temiz, isNotNull);
    expect(temiz!.message!.formatted, '[gizlendi]');
    expect(temiz.throwable, '[gizlendi]');
    expect(temiz.exceptions!.single.value, '[gizlendi]');
    // Hata türü kalır: gruplama ve teşhis için yeterli, kişisel veri değil.
    expect(temiz.exceptions!.single.type, 'PostgrestException');
    expect(temiz.breadcrumbs, isEmpty);
  });
}
