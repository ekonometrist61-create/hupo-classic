import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'push_backend.dart';
import 'push_config.dart';

/// Gerçek arka uç: Firebase Cloud Messaging. Yalnızca mobilde ve yapılandırma tamsa kullanılır
/// (bkz. push_providers.dart). Her çağrı hataya karşı korumalıdır.
class FirebasePushBackend implements PushBackend {
  FirebasePushBackend(this._config);

  final PushConfig _config;
  bool _ready = false;

  @override
  bool get supported => _config.isUsable;

  @override
  String get platform => defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  @override
  Future<bool> init() async {
    if (_ready) return true;
    if (!supported) return false;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: _config.apiKey,
            appId: _config.appId,
            projectId: _config.projectId,
            messagingSenderId: _config.messagingSenderId,
          ),
        );
      }
      // Uygulama açıkken sistem bildirimi göstermeyiz; bunu uygulama içi afiş yapar.
      await _fcm.setForegroundNotificationPresentationOptions(
          alert: false, badge: false, sound: false);
      _ready = true;
    } catch (e) {
      debugPrint('Push: Firebase başlatılamadı, bildirimler kapalı kalacak ($e)');
      _ready = false;
    }
    return _ready;
  }

  PushPermission _map(AuthorizationStatus s) => switch (s) {
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional =>
          PushPermission.granted,
        AuthorizationStatus.notDetermined => PushPermission.notDetermined,
        // denied ve (yeni sürümlerdeki) deniedPermanently
        _ => PushPermission.denied,
      };

  @override
  Future<PushPermission> permissionStatus() async {
    if (!_ready) return PushPermission.notDetermined;
    try {
      return _map((await _fcm.getNotificationSettings()).authorizationStatus);
    } catch (_) {
      return PushPermission.notDetermined;
    }
  }

  @override
  Future<PushPermission> requestPermission() async {
    if (!_ready) return PushPermission.notDetermined;
    try {
      return _map((await _fcm.requestPermission()).authorizationStatus);
    } catch (_) {
      return PushPermission.notDetermined;
    }
  }

  @override
  Future<String?> getToken() async {
    if (!_ready) return null;
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    if (!_ready) return;
    try {
      await _fcm.deleteToken();
    } catch (_) {}
  }

  PushMessage _toMessage(RemoteMessage m) => PushMessage(
        title: m.notification?.title,
        body: m.notification?.body,
        data: {for (final e in m.data.entries) e.key: '${e.value}'},
      );

  @override
  Stream<String> get onTokenRefresh =>
      _ready ? _fcm.onTokenRefresh : const Stream<String>.empty();

  @override
  Stream<PushMessage> get onForegroundMessage =>
      _ready ? FirebaseMessaging.onMessage.map(_toMessage) : const Stream<PushMessage>.empty();

  @override
  Stream<PushMessage> get onOpenedApp => _ready
      ? FirebaseMessaging.onMessageOpenedApp.map(_toMessage)
      : const Stream<PushMessage>.empty();

  @override
  Future<PushMessage?> initialMessage() async {
    if (!_ready) return null;
    try {
      final m = await _fcm.getInitialMessage();
      return m == null ? null : _toMessage(m);
    } catch (_) {
      return null;
    }
  }
}
