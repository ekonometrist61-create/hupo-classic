import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import 'push_api.dart';
import 'push_backend.dart';
import 'push_service.dart';

/// Push yapılandırılmadı, her zaman boş arka uç döner.
final pushBackendProvider = Provider<PushBackend>((ref) {
  return const NoopPushBackend();
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
