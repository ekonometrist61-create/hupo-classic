import 'package:flutter/material.dart';

import '../models/league_models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/motion.dart';
import 'badge_icons.dart';
import 'ui/game_card.dart';

/// Yarıştığı lig: haftalık XP, anonim sıra, yükselme hedefi ve haftanın kalan süresi.
/// Sıralamada başka çocukların adı gösterilmez; yalnızca "N öğrenci arasında K. sıra".
class LeagueCard extends StatelessWidget {
  const LeagueCard({
    super.key,
    required this.status,
    this.compact = false,
    this.onTap,
  });

  final LeagueStatus status;

  /// Ana ekran için küçültülmüş görünüm.
  final bool compact;
  final VoidCallback? onTap;

  String get _rankText => status.total >= 2
      ? '${status.total} öğrenci arasında ${status.rank}. sıradasın'
      : 'Ligin ilk öğrencilerinden birisin!';

  String get _goalText {
    if (status.isTopLeague) {
      return 'Zirvedesin! ${status.name} içinde kalmak için soru çözmeye devam et.';
    }
    final next = status.nextLeagueName ?? 'bir üst lig';
    return status.xpToPromotion > 0
        ? '$next için ${status.xpToPromotion} XP daha!'
        : 'Harika! Hedefi tamamladın, hafta sonunda $next seni bekliyor!';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = formatRemaining(status.remainingSeconds);

    return GameCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 14 : 20),
      child: compact
          ? Row(
              children: [
                _LeagueMedal(status: status, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(status.name, style: appText(size: 17, weight: FontWeight.w900)),
                      Text(
                        'Bu hafta ${status.weeklyXp} XP • $remaining kaldı',
                        style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 28),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _LeagueMedal(status: status, size: 64),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(status.name, style: appText(size: 22, weight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text(
                            _rankText,
                            style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bu hafta ${status.weeklyXp} XP',
                        style: appText(size: 16, weight: FontWeight.w900),
                      ),
                    ),
                    if (!status.isTopLeague)
                      Text(
                        'Hedef: ${status.promotionXp} XP',
                        style: appText(size: 13, weight: FontWeight.w800, color: AppColors.muted),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: status.promotionProgress),
                    duration: motionMs(context, 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 14,
                      backgroundColor: AppColors.primarySoft,
                      valueColor: const AlwaysStoppedAnimation(AppColors.sun),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(_goalText, style: appText(size: 14, weight: FontWeight.w800, color: AppColors.primary)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_bottom_rounded, size: 20, color: AppColors.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Haftanın bitmesine $remaining',
                          style: appText(size: 14, weight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _LeagueMedal extends StatelessWidget {
  const _LeagueMedal({required this.status, required this.size});

  final LeagueStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final edge = Color.lerp(status.color, Colors.black, 0.28)!;
    return Semantics(
      label: status.name,
      image: true,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: status.color,
            boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 4))],
          ),
          child: Icon(badgeIcon(status.icon), color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }
}
