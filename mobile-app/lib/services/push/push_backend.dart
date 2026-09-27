/// Push altyapısı soyutlaması: gerçek uygulama Firebase'i, testler ve web sahte/boş
/// bir arka ucu kullanır. Bu dosya Firebase'e BAĞIMLI DEĞİLDİR.
library;

/// Bildirim izni durumu.
enum PushPermission { granted, denied, notDetermined }

/// Gelen bir push mesajının uygulamaya ilgili kısmı.
class PushMessage {
  const PushMessage({this.title, this.body, this.data = const {}});

  final String? title;
  final String? body;
  final Map<String, String> data;

  /// Dokununca gidilecek yer (şimdilik yalnızca "notifications").
  String? get route => data['route'];
}

abstract class PushBackend {
  /// Bu cihazda/derlemede push desteklenip yapılandırıldı mı?
  bool get supported;

  /// 'android' veya 'ios'.
  String get platform;

  /// Firebase'i hazırlar. Yapılandırma eksikse veya hata olursa false döner, ASLA fırlatmaz.
  Future<bool> init();

  Future<PushPermission> permissionStatus();

  /// İşletim sistemi izin penceresini gösterir. Yalnızca kullanıcı ayarlardan açınca çağrılır.
  Future<PushPermission> requestPermission();

  Future<String?> getToken();
  Future<void> deleteToken();

  Stream<String> get onTokenRefresh;
  Stream<PushMessage> get onForegroundMessage;
  Stream<PushMessage> get onOpenedApp;
  Future<PushMessage?> initialMessage();
}

/// Web, yapılandırılmamış derlemeler ve testler için: hiçbir şey yapmaz.
class NoopPushBackend implements PushBackend {
  const NoopPushBackend();

  @override
  bool get supported => false;
  @override
  String get platform => 'android';
  @override
  Future<bool> init() async => false;
  @override
  Future<PushPermission> permissionStatus() async => PushPermission.notDetermined;
  @override
  Future<PushPermission> requestPermission() async => PushPermission.notDetermined;
  @override
  Future<String?> getToken() async => null;
  @override
  Future<void> deleteToken() async {}
  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
  @override
  Stream<PushMessage> get onForegroundMessage => const Stream.empty();
  @override
  Stream<PushMessage> get onOpenedApp => const Stream.empty();
  @override
  Future<PushMessage?> initialMessage() async => null;
}
