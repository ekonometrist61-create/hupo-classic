import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../models/models.dart';
import '../providers/app_providers.dart';
import '../settings/app_settings.dart';
import '../theme/app_theme.dart';
import '../utils/motion.dart';
import 'hupo/hupo.dart';
import 'ui/chunky_button.dart';
import 'ui/game_card.dart';

/// "Seri kalkanı kazandın!" kartı: Hupo kutlar, kalkan sayısı gösterilir.
/// Hem kutlama penceresinde hem bildirim merkezinde kullanılır.
class ShieldEarnedBanner extends StatelessWidget {
  const ShieldEarnedBanner({super.key, this.shields, this.compact = false});

  /// Kazanılmış toplam kalkan sayısı (biliniyorsa gösterilir).
  final int? shields;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final count = shields;
    return Semantics(
      liveRegion: true,
      label: 'Seri kalkanı kazandın! Bir gün ara verirsen serin korunur.',
      child: ExcludeSemantics(
        child: GameCard(
          color: AppColors.primarySoft,
          borderColor: AppColors.primary,
          padding: EdgeInsets.all(compact ? 12 : 18),
          child: Row(
            children: [
              Hupo(mood: HupoMood.shieldEarned, size: compact ? 64 : 96, animated: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Seri kalkanı kazandın!',
                            style: appText(size: compact ? 16 : 20, weight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count == null
                          ? 'Düzenli çalıştığın için Hupo seninle gurur duyuyor. '
                              'Bir gün ara verirsen serin korunur.'
                          : 'Şu an $count kalkanın var. Bir gün ara verirsen serin korunur; '
                              'Hupo seninle gurur duyuyor!',
                      style: appText(
                        size: compact ? 13 : 15,
                        weight: FontWeight.w700,
                        color: AppColors.muted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kalkan kazanılınca açılan kutlama penceresi (hareket azaltılmışsa konfeti yok).
Future<void> showShieldEarnedDialog(BuildContext context, int shields) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false, // ignore: avoid_redundant_argument_values — kapanmaması guvenlik geregi
    barrierLabel: 'Kutlama',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: motionMs(context, 300),
    transitionBuilder: (context, animation, _, child) => ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      child: FadeTransition(opacity: animation, child: child),
    ),
    pageBuilder: (context, _, __) => Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShieldEarnedBanner(shields: shields),
                    const SizedBox(height: 14),
                    ChunkyButton(label: 'Harika!', onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!reducedMotion(context))
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset('assets/lottie/confetti.json', repeat: false, fit: BoxFit.cover),
            ),
          ),
      ],
    ),
  );
}

/// Kalkan sayısı artınca (7 günlük seri => +1) kutlama penceresini açar.
///
/// Kalkan sayısı cihazda kullanıcı başına saklanır. İlk kullanımda mevcut sayı sessizce
/// kaydedilir; yalnızca kayıtlı sayıdan YÜKSEK bir değer görülünce kutlanır.
class ShieldCelebrationListener extends ConsumerStatefulWidget {
  const ShieldCelebrationListener({super.key, required this.child});

  final Widget child;

  static String storageKey(String userId) => 'shield_count_$userId';

  /// Saf karar fonksiyonu: kutlanmalı mı?
  static bool shouldCelebrate({required int? storedShields, required int current}) =>
      storedShields != null && current > storedShields;

  @override
  ConsumerState<ShieldCelebrationListener> createState() => _ShieldCelebrationListenerState();
}

class _ShieldCelebrationListenerState extends ConsumerState<ShieldCelebrationListener> {
  ProviderSubscription<AsyncValue<StudentStats>>? _subscription;
  bool _showing = false;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<AsyncValue<StudentStats>>(
      statsProvider,
      (previous, next) {
        final shields = next.valueOrNull?.shields;
        if (shields != null) _check(shields);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }

  Future<void> _check(int shields) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final key = ShieldCelebrationListener.storageKey(userId);
    final stored = prefs.getInt(key);
    final celebrate = ShieldCelebrationListener.shouldCelebrate(
      storedShields: stored,
      current: shields,
    );
    if (stored != shields) await prefs.setInt(key, shields);
    if (!celebrate) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _showing) return;
      _showing = true;
      await showShieldEarnedDialog(context, shields);
      _showing = false;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
