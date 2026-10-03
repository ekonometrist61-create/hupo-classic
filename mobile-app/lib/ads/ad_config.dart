// AdMob reklam yapılandırması ve sağlayıcıları.
//
// Çocuk güvenliği (COPPA) kuralları gereği, çocuk odaklı reklam parametreleri
// etkinleştirilir ve kişiselleştirilmiş izleme yapılmaz.

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Test banner reklam birimi kimlikleri (Google AdMob resmi test kimlikleri).
class AdConfig {
  static const String testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testBannerIos = 'ca-app-pub-3940256099942544/2934735716';

  /// Platforma göre geçerli test banner kimliğini döner.
  static String get testBannerUnitId {
    if (Platform.isIOS) {
      return testBannerIos;
    }
    return testBannerAndroid;
  }
}

/// Öğrenci ekranlarında gösterilecek banner reklam kimliğini belirleyen provider.
final studentBannerAdUnitIdProvider = Provider<String?>((ref) {
  // Canlı yapılandırma henüz çekilmediyse veya sunucu reklamları kapalıysa null döner.
  return null;
});
