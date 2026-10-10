import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kelime_models.dart';
import '../services/kelime_repository.dart';
import 'app_providers.dart';

final kelimeRepositoryProvider = Provider<KelimeRepository>(
  (ref) => SupabaseKelimeRepository(ref.watch(supabaseProvider)),
);

/// Ana ekran özeti. Oyundan dönüldüğünde `ref.invalidate` ile yenilenir.
final kelimeOzetProvider = FutureProvider.autoDispose<KelimeOzet>(
  (ref) => ref.watch(kelimeRepositoryProvider).ozet(),
);

final kelimeKaydedilenlerProvider = FutureProvider.autoDispose<List<KelimeKaydi>>(
  (ref) => ref.watch(kelimeRepositoryProvider).kaydedilenler(),
);
