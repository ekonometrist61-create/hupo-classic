import 'package:url_launcher/url_launcher.dart';

import '../config/env.dart';

/// Hupolingo web sitesinde bir sayfayı dış tarayıcıda açar.
///
/// Açılamazsa (tarayıcı yok, platform hatası) false döner; çağıran taraf kullanıcıya
/// bir mesaj göstermekten sorumludur.
Future<bool> openWebPage(String path) async {
  final uri = Uri.parse('${Env.webBaseUrl}$path');
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
