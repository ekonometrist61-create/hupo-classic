import 'dart:async';

import 'package:flutter/foundation.dart';

import 'push_api.dart';
import 'push_backend.dart';

/// Push'u açma denemesinin sonucu.
enum PushEnableResult {
  enabled,

  /// Çocuk hesabı: velinin onayı yok (işletim sistemi izni HİÇ istenmedi).
  needsParentConsent,

  /// Kullanıcı işletim sistemi iznini vermedi.
  permissionDenied,

  /// Web, yapılandırılmamış derleme veya Firebase başlatılamadı.
  unavailable,

  /// Ağ/sunucu hatası.
  failed,
}

/// Push bildirimlerinin uygulama tarafı koordinatörü.
///
/// Güvenlik kuralları:
///  * İşletim sistemi izni YALNIZCA [enable] ile (Ayarlar'da kullanıcı açınca) istenir;
///    ilk açılışta ve [syncAfterLogin] içinde asla.
///  * Çocuk hesabında önce sunucu rıza kontrolü yapılır; onay yoksa izin penceresi hiç açılmaz.
///  * Hiçbir yöntem fırlatmaz: yapılandırma yoksa sessizce "kullanılamıyor" der.
class PushService {
  PushService({required this.backend, required this.api, void Function(String)? log})
      : _log = log ?? ((m) => debugPrint('Push: $m'));

  final PushBackend backend;
  final PushApi api;
  final void Function(String) _log;

  bool _initTried = false;
  bool _ready = false;
  String? _registeredToken;
  StreamSubscription<String>? _refreshSub;

  /// Bu derlemede push mümkün mü (web = hayır, yapılandırma yok = hayır).
  bool get supported => backend.supported;

  bool get ready => _ready;

  /// Firebase'i hazırlar (bir kez). Yapılandırma eksikse false döner ve log yazar.
  Future<bool> init() async {
    if (_initTried) return _ready;
    _initTried = true;
    if (!supported) {
      _log('yapılandırılmamış veya web: bildirimler kapalı');
      return false;
    }
    try {
      _ready = await backend.init();
    } catch (e) {
      _log('başlatılamadı: $e');
      _ready = false;
    }
    return _ready;
  }

  Stream<PushMessage> get foregroundMessages =>
      _ready ? backend.onForegroundMessage : const Stream.empty();

  Stream<PushMessage> get openedMessages =>
      _ready ? backend.onOpenedApp : const Stream.empty();

  Future<PushMessage?> initialMessage() async => _ready ? backend.initialMessage() : null;

  /// Kullanıcı Ayarlar'da bildirimleri açtı.
  Future<PushEnableResult> enable() async {
    if (!await init()) return PushEnableResult.unavailable;

    // 1) Önce sunucu: çocuk için veli onayı yoksa burada reddedilir, izin penceresi açılmaz.
    try {
      await api.setPreference(true);
    } on PushConsentRequired {
      return PushEnableResult.needsParentConsent;
    } catch (e) {
      _log('tercih kaydedilemedi: $e');
      return PushEnableResult.failed;
    }

    // 2) İşletim sistemi izni (kullanıcı bu adımı kendisi başlattı).
    var permission = await backend.permissionStatus();
    if (permission != PushPermission.granted) {
      permission = await backend.requestPermission();
    }
    if (permission != PushPermission.granted) {
      await _revertPreference();
      return PushEnableResult.permissionDenied;
    }

    // 3) Jeton kaydı.
    if (!await _registerCurrentToken()) {
      await _revertPreference();
      return PushEnableResult.failed;
    }
    _listenForTokenRefresh();
    return PushEnableResult.enabled;
  }

  /// Kullanıcı bildirimleri kapattı.
  Future<bool> disable() async {
    try {
      await api.setPreference(false);
    } catch (e) {
      _log('kapatılamadı: $e');
      return false;
    }
    await unregisterCurrentDevice();
    await _refreshSub?.cancel();
    _refreshSub = null;
    return true;
  }

  /// Oturum açıldıktan sonra: daha önce açılmışsa ve izin zaten verilmişse jetonu yeniler.
  /// ASLA izin istemez.
  Future<void> syncAfterLogin() async {
    try {
      if (!await init()) return;
      final pref = await api.getPreference();
      if (!pref.enabled) return;
      if (await backend.permissionStatus() != PushPermission.granted) return;
      if (await _registerCurrentToken()) _listenForTokenRefresh();
    } catch (e) {
      _log('oturum sonrası eşitleme atlandı: $e');
    }
  }

  /// Çıkıştan ÖNCE çağrılır (sunucu çağrısı için oturum gerekir): bu cihazın jetonunu siler.
  Future<void> unregisterCurrentDevice() async {
    if (!_ready) return;
    try {
      final token = _registeredToken ?? await backend.getToken();
      if (token != null) await api.unregisterToken(token);
    } catch (e) {
      _log('jeton kaldırılamadı: $e');
    }
    _registeredToken = null;
  }

  /// Oturum kapandıktan sonra: yerel jetonu geçersiz kıl (sunucuda kalmış olsa bile işe yaramaz).
  Future<void> onSignedOut() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    if (_ready) await backend.deleteToken();
    _registeredToken = null;
  }

  Future<bool> _registerCurrentToken() async {
    try {
      final token = await backend.getToken();
      if (token == null) return false;
      await api.registerToken(token, backend.platform);
      _registeredToken = token;
      return true;
    } catch (e) {
      _log('jeton kaydedilemedi: $e');
      return false;
    }
  }

  void _listenForTokenRefresh() {
    _refreshSub ??= backend.onTokenRefresh.listen((token) async {
      try {
        await api.registerToken(token, backend.platform);
        _registeredToken = token;
      } catch (e) {
        _log('yenilenen jeton kaydedilemedi: $e');
      }
    });
  }

  Future<void> _revertPreference() async {
    try {
      await api.setPreference(false);
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
  }
}
