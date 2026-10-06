import 'package:flutter/foundation.dart';

/// Firebase bağlantı değerleri. Bunlar gizli anahtar DEĞİLDİR (istemciye açık kimliklerdir)
/// ama projeye özeldir; bu yüzden koda yazılmaz, derleme sırasında verilir:
///
///   flutter run
///     --dart-define=FIREBASE_API_KEY=...
///     --dart-define=FIREBASE_APP_ID=...
///     --dart-define=FIREBASE_PROJECT_ID=...
///     --dart-define=FIREBASE_MESSAGING_SENDER_ID=...
///
/// Değerler eksikse push tamamen devre dışı kalır; uygulama normal çalışır.
/// Kurulum: docs/PUSH_KURULUM.md
class PushConfig {
  const PushConfig({
    this.apiKey = '',
    this.appId = '',
    this.projectId = '',
    this.messagingSenderId = '',
  });

  factory PushConfig.fromEnvironment() => const PushConfig(
        
      );

  final String apiKey;
  final String appId;
  final String projectId;
  final String messagingSenderId;

  bool get isComplete =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      projectId.isNotEmpty &&
      messagingSenderId.isNotEmpty;

  /// Bu derlemede push kullanılabilir mi? (web'de asla)
  bool get isUsable => !kIsWeb && isComplete;
}
