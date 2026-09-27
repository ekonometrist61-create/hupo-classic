import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/push/push_api.dart';
import 'package:ogrenci_hazirlik/services/push/push_backend.dart';
import 'package:ogrenci_hazirlik/services/push/push_config.dart';
import 'package:ogrenci_hazirlik/services/push/push_providers.dart';
import 'package:ogrenci_hazirlik/services/push/push_service.dart';
import 'package:ogrenci_hazirlik/services/push/push_settings_card.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';

class _FakeBackend implements PushBackend {
  _FakeBackend({
    this.initThrows = false,
    this.permission = PushPermission.notDetermined,
    this.grantOnRequest = true,
  });

  final bool initThrows;
  PushPermission permission;
  final bool grantOnRequest;
  String? token = 'fcm-token-1234567890abcdef';

  int permissionRequests = 0;
  int deleteTokenCalls = 0;
  final refresh = StreamController<String>.broadcast();

  @override
  bool get supported => true;
  @override
  String get platform => 'android';
  @override
  Future<bool> init() async {
    if (initThrows) throw Exception('firebase yok');
    return true;
  }

  @override
  Future<PushPermission> permissionStatus() async => permission;
  @override
  Future<PushPermission> requestPermission() async {
    permissionRequests++;
    permission = grantOnRequest ? PushPermission.granted : PushPermission.denied;
    return permission;
  }

  @override
  Future<String?> getToken() async => token;
  @override
  Future<void> deleteToken() async => deleteTokenCalls++;
  @override
  Stream<String> get onTokenRefresh => refresh.stream;
  @override
  Stream<PushMessage> get onForegroundMessage => const Stream.empty();
  @override
  Stream<PushMessage> get onOpenedApp => const Stream.empty();
  @override
  Future<PushMessage?> initialMessage() async => null;
}

class _FakeApi implements PushApi {
  _FakeApi({this.needsConsent = false, this.enabled = false, this.failSet = false});

  bool needsConsent;
  bool enabled;
  bool failSet;
  final setCalls = <bool>[];
  final registered = <String>[];
  final unregistered = <String>[];
  String? lastPlatform;

  @override
  Future<PushPreference> getPreference() async => PushPreference(
        enabled: enabled && !needsConsent,
        quietStart: '20:00',
        quietEnd: '08:00',
        needsParentConsent: needsConsent,
      );

  @override
  Future<PushPreference> setPreference(bool value) async {
    setCalls.add(value);
    if (failSet) throw Exception('ağ');
    if (value && needsConsent) throw const PushConsentRequired();
    enabled = value;
    return getPreference();
  }

  @override
  Future<void> registerToken(String token, String platform) async {
    registered.add(token);
    lastPlatform = platform;
  }

  @override
  Future<void> unregisterToken(String token) async => unregistered.add(token);
}

void main() {
  group('PushService: yapılandırma yokken güvenli bozulma', () {
    test('NoopPushBackend ile hiçbir yöntem fırlatmaz ve sunucuya dokunmaz', () async {
      final api = _FakeApi();
      final service = PushService(backend: const NoopPushBackend(), api: api, log: (_) {});

      expect(service.supported, isFalse);
      expect(await service.init(), isFalse);
      expect(await service.enable(), PushEnableResult.unavailable);
      await service.syncAfterLogin();
      await service.unregisterCurrentDevice();
      await service.onSignedOut();
      expect(await service.initialMessage(), isNull);
      expect(api.setCalls, isEmpty);
      expect(api.registered, isEmpty);
    });

    test('Firebase başlatılırken hata olursa çökmez, "kullanılamıyor" der', () async {
      final logs = <String>[];
      final service = PushService(
        backend: _FakeBackend(initThrows: true),
        api: _FakeApi(),
        log: logs.add,
      );
      expect(await service.enable(), PushEnableResult.unavailable);
      expect(service.ready, isFalse);
      expect(logs, isNotEmpty);
    });

    test('Eksik yapılandırma push\'u kapalı tutar (web dahil)', () {
      expect(const PushConfig().isUsable, isFalse);
      expect(const PushConfig(apiKey: 'a', appId: 'b', projectId: 'c').isComplete, isFalse);
      // Test ortamında dart-define yok: varsayılan arka uç Firebase'e hiç dokunmaz.
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(pushBackendProvider).supported, isFalse);
    });
  });

  group('PushService: açma akışı', () {
    test('başarılı: sunucu tercihi + izin (bir kez) + jeton kaydı', () async {
      final backend = _FakeBackend();
      final api = _FakeApi();
      final service = PushService(backend: backend, api: api, log: (_) {});

      expect(await service.enable(), PushEnableResult.enabled);
      expect(api.setCalls, [true]);
      expect(backend.permissionRequests, 1);
      expect(api.registered, [backend.token]);
      expect(api.lastPlatform, 'android');
    });

    test('veli onayı yoksa işletim sistemi izni HİÇ istenmez', () async {
      final backend = _FakeBackend();
      final api = _FakeApi(needsConsent: true);
      final service = PushService(backend: backend, api: api, log: (_) {});

      expect(await service.enable(), PushEnableResult.needsParentConsent);
      expect(backend.permissionRequests, 0);
      expect(api.registered, isEmpty);
    });

    test('izin reddedilirse tercih geri alınır ve jeton kaydedilmez', () async {
      final backend = _FakeBackend(grantOnRequest: false);
      final api = _FakeApi();
      final service = PushService(backend: backend, api: api, log: (_) {});

      expect(await service.enable(), PushEnableResult.permissionDenied);
      expect(api.setCalls, [true, false]);
      expect(api.enabled, isFalse);
      expect(api.registered, isEmpty);
    });

    test('ağ hatası: failed döner, izin istenmez', () async {
      final backend = _FakeBackend();
      final service =
          PushService(backend: backend, api: _FakeApi(failSet: true), log: (_) {});
      expect(await service.enable(), PushEnableResult.failed);
      expect(backend.permissionRequests, 0);
    });

    test('kapatınca tercih kapanır ve jeton sunucudan silinir', () async {
      final backend = _FakeBackend();
      final api = _FakeApi();
      final service = PushService(backend: backend, api: api, log: (_) {});
      await service.enable();

      expect(await service.disable(), isTrue);
      expect(api.enabled, isFalse);
      expect(api.unregistered, [backend.token]);
    });
  });

  group('PushService: oturum ve jeton yenileme', () {
    test('oturum sonrası eşitleme ASLA izin istemez', () async {
      final backend = _FakeBackend(); // izin: belirlenmemiş
      final api = _FakeApi(enabled: true);
      final service = PushService(backend: backend, api: api, log: (_) {});

      await service.syncAfterLogin();
      expect(backend.permissionRequests, 0);
      expect(api.registered, isEmpty);
    });

    test('tercih açık ve izin zaten varsa jeton yenilenir', () async {
      final backend = _FakeBackend(permission: PushPermission.granted);
      final api = _FakeApi(enabled: true);
      final service = PushService(backend: backend, api: api, log: (_) {});

      await service.syncAfterLogin();
      expect(api.registered, [backend.token]);
    });

    test('tercih kapalıysa jeton kaydedilmez', () async {
      final backend = _FakeBackend(permission: PushPermission.granted);
      final api = _FakeApi(enabled: false);
      final service = PushService(backend: backend, api: api, log: (_) {});

      await service.syncAfterLogin();
      expect(api.registered, isEmpty);
    });

    test('jeton yenilenince yeni jeton kaydedilir', () async {
      final backend = _FakeBackend();
      final api = _FakeApi();
      final service = PushService(backend: backend, api: api, log: (_) {});
      await service.enable();

      backend.refresh.add('yeni-jeton-1234567890abcdef');
      await Future<void>.delayed(Duration.zero);
      expect(api.registered.last, 'yeni-jeton-1234567890abcdef');
      await service.dispose();
    });

    test('çıkışta yerel jeton geçersiz kılınır', () async {
      final backend = _FakeBackend();
      final service = PushService(backend: backend, api: _FakeApi(), log: (_) {});
      await service.enable();
      await service.unregisterCurrentDevice();
      await service.onSignedOut();
      expect(backend.deleteTokenCalls, 1);
    });
  });

  group('Ayarlar: Bildirimler kartı', () {
    Future<void> pump(WidgetTester tester, PushBackend backend, PushApi api) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          pushBackendProvider.overrideWithValue(backend),
          pushApiProvider.overrideWithValue(api),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(body: SingleChildScrollView(child: PushSettingsCard())),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    Switch sw(WidgetTester tester) => tester.widget<Switch>(find.byKey(const Key('push-switch')));

    testWidgets('varsayılan KAPALI; sessiz saat bilgisi görünür', (tester) async {
      await pump(tester, _FakeBackend(), _FakeApi());
      expect(sw(tester).value, isFalse);
      expect(sw(tester).onChanged, isNotNull);
      expect(find.textContaining('20:00 - 08:00'), findsOneWidget);
    });

    testWidgets('çocuk için veli onayı yoksa anahtar kilitli ve açıklama var', (tester) async {
      await pump(tester, _FakeBackend(), _FakeApi(needsConsent: true));
      expect(sw(tester).onChanged, isNull);
      expect(find.textContaining('Velinin onayı gerekiyor'), findsOneWidget);
    });

    testWidgets('bu cihazda destek yoksa (web/yapılandırma yok) anahtar kilitli', (tester) async {
      await pump(tester, const NoopPushBackend(), _FakeApi());
      expect(sw(tester).onChanged, isNull);
      expect(find.textContaining('henüz kullanılamıyor'), findsOneWidget);
    });

    testWidgets('açma: önce açıklama penceresi; "Şimdi değil" izin istemez', (tester) async {
      final backend = _FakeBackend();
      final api = _FakeApi();
      await pump(tester, backend, api);

      await tester.tap(find.byKey(const Key('push-switch')));
      await tester.pumpAndSettle();
      expect(find.text('Bildirimleri açalım mı?'), findsOneWidget);
      expect(find.textContaining('20:00 ile sabah 08:00'), findsOneWidget);

      await tester.tap(find.text('Şimdi değil'));
      await tester.pumpAndSettle();
      expect(backend.permissionRequests, 0);
      expect(api.setCalls, isEmpty);
    });

    testWidgets('açma: onaylayınca izin istenir ve anahtar açık görünür', (tester) async {
      final backend = _FakeBackend();
      final api = _FakeApi();
      await pump(tester, backend, api);

      await tester.tap(find.byKey(const Key('push-switch')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Evet, aç'));
      await tester.pumpAndSettle();

      expect(backend.permissionRequests, 1);
      expect(api.registered, isNotEmpty);
      expect(sw(tester).value, isTrue);
      expect(find.textContaining('Bildirimler açıldı'), findsOneWidget);
    });

    testWidgets('metinlerde suçlayıcı/baskıcı ifade yok', (tester) async {
      await pump(tester, _FakeBackend(), _FakeApi());
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .join(' ');
      for (final bad in ['üzül', 'kaybed', 'mecbur', 'sakın', 'kaçırma']) {
        expect(texts.contains(bad), isFalse, reason: bad);
      }
    });
  });
}
