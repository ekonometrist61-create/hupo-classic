import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/motion.dart';
import '../ui/game_card.dart';
import 'avatar_models.dart';
import 'evolving_avatar_widget.dart';

/// Avatarın mevcut evresi, unvanı, evre içi ilerlemesi ve sonraki hedefe kalan XP.
///
/// [currentXP] TOPLAM XP'dir (student_stats.xp). Evre asla geri gitmez.
class AvatarProgressCard extends StatelessWidget {
  const AvatarProgressCard({super.key, required this.currentXP});

  final int currentXP;

  @override
  Widget build(BuildContext context) {
    final tier = AvatarEvolutionManager.getTierFromXP(currentXP);
    final target = tier.nextTargetXp;

    return GameCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      borderColor: tier.accentColor,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            EvolvingAvatarWidget(currentXP: currentXP, size: 150),
            const SizedBox(height: 10),
            Text(
              'Evre ${tier.index + 1}/${AvatarTier.values.length}',
              style: appText(size: 12, weight: FontWeight.w900, color: AppColors.muted),
            ),
            const SizedBox(height: 6),
            _TitleBadge(tier: tier),
            const SizedBox(height: 18),
            _EvolutionBar(tier: tier, xp: currentXP),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentXP XP',
                  style: appText(size: 13, weight: FontWeight.w900),
                ),
                Text(
                  target == null ? 'Zirve' : '$target XP',
                  style: appText(size: 13, weight: FontWeight.w800, color: AppColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              AvatarEvolutionManager.motivationText(currentXP),
              textAlign: TextAlign.center,
              style: appText(
                size: 15,
                weight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Büyük, parlak unvan rozeti.
class _TitleBadge extends StatelessWidget {
  const _TitleBadge({required this.tier});

  final AvatarTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tier.accentColor, tier.primaryColor],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: tier.primaryColor.withValues(alpha: 0.5),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Color.lerp(tier.primaryColor, Colors.black, 0.35)!,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        tier.title,
        textAlign: TextAlign.center,
        style: appText(
          size: 24,
          weight: FontWeight.w900,
          color: Colors.white,
        ).copyWith(
          shadows: const [Shadow(color: Color(0x66000000), offset: Offset(0, 2), blurRadius: 3)],
        ),
      ),
    );
  }
}

/// Kalın çerçeveli evrim çubuğu (oyunlardaki "XP bar" görünümü).
class _EvolutionBar extends StatelessWidget {
  const _EvolutionBar({required this.tier, required this.xp});

  final AvatarTier tier;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final progress = AvatarEvolutionManager.progressInTier(xp);
    final edge = Color.lerp(tier.primaryColor, Colors.black, 0.45)!;

    return Semantics(
      label: 'Evrim ilerlemesi',
      value: '${(progress * 100).round()} yüzde',
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: edge,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(3),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: motionMs(context, 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 20,
                backgroundColor: tier.accentColor.withValues(alpha: 0.35),
                valueColor: AlwaysStoppedAnimation(tier.primaryColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
