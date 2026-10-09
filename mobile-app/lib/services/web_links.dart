import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

import '../config/env.dart';

/// Hupolingo web sitesinde bir sayfayı dış tarayıcıda açar.
///
/// Açılamazsa (tarayıcı yok, platform hatası) false döner; çağıran taraf kullanıcıya
/// bir mesaj göstermekten sorumludur.
Future<bool> openWebPage(String path) =>
    _launchExternal(Uri.parse('${Env.webBaseUrl}$path'));

/// Hupolingo uygulamasının web sürümünü (app.hupolingo.com) dış tarayıcıda açar.
/// Dönüş değeri [openWebPage] ile aynıdır.
Future<bool> openAppWebsite() => _launchExternal(Uri.parse(Env.appWebUrl));

Future<bool> _launchExternal(Uri uri) async {
  try {
    // Web'de sayfa yeni sekmede açılır; uygulama sekmesi yerine geçilmez.
    // Mobilde davranış değişmez (webOnlyWindowName yalnızca web'de kullanılır).
    return await launchUrl(
      uri,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      webOnlyWindowName: kIsWeb ? '_blank' : null,
    );
  } catch (_) {
    return false;
  }
}
