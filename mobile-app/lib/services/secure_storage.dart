// Supabase oturum tokenlarını platform güvenli deposuna (Android Keystore /
// iOS Keychain) kaydeden LocalStorage uygulaması.
//
// SharedPreferences yerine kullanılır; anahtar hiçbir zaman düz metin
// olarak diskte kalmaz.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase oturum deposunu platforma göre seçer.
///
/// Mobilde [SecureLocalStorage] kullanılır. Web'de FlutterSecureStorage kullanılmaz;
/// null dönerse supabase_flutter varsayılan depoyu (tarayıcı localStorage) kullanır.
LocalStorage? supabaseLocalStorage() => kIsWeb ? null : SecureLocalStorage();

class SecureLocalStorage extends LocalStorage {
  static const _kSessionKey = 'sb_session';

  final _storage = const FlutterSecureStorage(
    // Android API 23+ — EncryptedSharedPreferences kullanır.
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    // iOS — uygulamanın ilk kilit açılışından sonra erişilebilir.
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() => _storage.read(key: _kSessionKey);

  @override
  Future<bool> hasAccessToken() async {
    final token = await _storage.read(key: _kSessionKey);
    return token != null;
  }

  @override
  Future<void> persistSession(String persistSessionString) =>
      _storage.write(key: _kSessionKey, value: persistSessionString);

  @override
  Future<void> removePersistedSession() =>
      _storage.delete(key: _kSessionKey);
}
