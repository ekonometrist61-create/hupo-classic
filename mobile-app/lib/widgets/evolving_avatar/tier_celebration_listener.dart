import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/models.dart';
import '../../providers/app_providers.dart';
import '../../settings/app_settings.dart';
import 'avatar_models.dart';
import 'tier_up_dialog.dart';

/// Toplam XP değişince yeni bir evreye geçilip geçilmediğine bakar ve
/// her evre için YALNIZCA BİR KEZ kutlama penceresini açar.
///
/// Kural (yalnızca yükselme):
///  * Bu cihazda o kullanıcı için daha önce kayıt yoksa (ilk kullanım / güncelleme):
///    mevcut evre sessizce kaydedilir, geçmiş evreler için kutlama yapılmaz.
///  * Kayıtlı evreden yüksek bir evreye çıkılmışsa: önce kayıt güncellenir (çift gösterim
///    olmasın), sonra ulaşılan en yüksek evre için pencere açılır.
class TierCelebrationListener extends ConsumerStatefulWidget {
  const TierCelebrationListener({super.key, required this.child});

  final Widget child;

  /// Kayıt anahtarı (kullanıcı başına ayrı).
  static String storageKey(String userId) => 'avatar_tier_$userId';

  /// Saf karar fonksiyonu: kutlanacak evre (yoksa null).
  static AvatarTier? tierToCelebrate({
    required int? storedTierIndex,
    required AvatarTier current,
  }) {
    if (storedTierIndex == null) return null;
    return current.index > storedTierIndex ? current : null;
  }

  @override
  ConsumerState<TierCelebrationListener> createState() => _TierCelebrationListenerState();
}

class _TierCelebrationListenerState extends ConsumerState<TierCelebrationListener> {
  ProviderSubscription<AsyncValue<StudentStats>>? _subscription;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<AsyncValue<StudentStats>>(
      statsProvider,
      (previous, next) {
        final xp = next.valueOrNull?.xp;
        if (xp != null) _check(xp);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  Future<void> _check(int xp) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final key = TierCelebrationListener.storageKey(userId);
    final current = AvatarEvolutionManager.getTierFromXP(xp);
    final stored = prefs.getInt(key);

    final celebrate = TierCelebrationListener.tierToCelebrate(
      storedTierIndex: stored,
      current: current,
    );

    if (stored == null || celebrate != null) {
      await prefs.setInt(key, current.index);
    }
    if (celebrate == null) return;

    // Pencere, çizim aşaması bittikten sonra güvenle açılır.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _showing) return;
      _showing = true;
      await showTierUpDialog(context, celebrate);
      _showing = false;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
