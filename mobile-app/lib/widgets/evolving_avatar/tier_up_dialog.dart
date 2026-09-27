import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../theme/app_theme.dart';
import '../../utils/motion.dart';
import '../ui/chunky_button.dart';
import '../hupo/hupo.dart';
import 'avatar_models.dart';
import 'evolving_avatar_widget.dart';

/// Yeni evreye geçince tam ekran konfetiyle açılan kutlama penceresi.
/// Hareket azaltılmışsa konfeti gösterilmez; pencere yine açılır.
Future<void> showTierUpDialog(BuildContext context, AvatarTier tier) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Kutlama',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: motionMs(context, 350),
    transitionBuilder: (context, animation, _, child) => ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      child: FadeTransition(opacity: animation, child: child),
    ),
    pageBuilder: (context, _, __) => TierUpView(tier: tier),
  );
}

class TierUpView extends StatelessWidget {
  const TierUpView({super.key, required this.tier});

  final AvatarTier tier;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: tier.accentColor, width: 4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Hupo(mood: HupoMood.celebrate, size: 84, animated: true),
                      Text(
                        'Evrim zamanı!',
                        style: appText(size: 30, weight: FontWeight.w900, color: tier.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      EvolvingAvatarWidget(currentXP: tier.minXp, tier: tier, size: 200),
                      const SizedBox(height: 8),
                      Text(
                        tier.title,
                        textAlign: TextAlign.center,
                        style: appText(size: 26, weight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tier.unlockMessage,
                        textAlign: TextAlign.center,
                        style: appText(
                          size: 16,
                          weight: FontWeight.w800,
                          color: AppColors.muted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ChunkyButton(
                        label: 'Harika!',
                        color: tier.primaryColor,
                        edgeColor: Color.lerp(tier.primaryColor, Colors.black, 0.35)!,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Tam sayfa konfeti (dokunmayı engellemez); hareket azaltılmışsa yok.
        if (!reducedMotion(context))
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/lottie/confetti.json',
                repeat: false,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
    );
  }
}
