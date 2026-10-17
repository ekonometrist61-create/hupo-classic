import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import 'push_api.dart';
import 'push_backend.dart';
import 'push_backend_firebase.dart';
import 'push_config.dart';
import 'push_service.dart';

/// Yapılandırma tamsa (dart-define) Firebase arka ucu; değilse boş arka uç.
final pushBackendProvider = Provider<PushBackend>((ref) {
  final config = PushConfig.fromEnvironment();
  return config.isUsable ? FirebasePushBackend(config) : const NoopPushBackend();
});

final pushApiProvider =
    Provider<PushApi>((ref) => SupabasePushApi(ref.watch(supabaseProvider)));

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(
    backend: ref.watch(pushBackendProvider),
    api: ref.watch(pushApiProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// Sunucudaki push tercihi (Ayarlar kartı için).
final pushPreferenceProvider = FutureProvider.autoDispose<PushPreference>(
    (ref) => ref.watch(pushApiProvider).getPreference());
