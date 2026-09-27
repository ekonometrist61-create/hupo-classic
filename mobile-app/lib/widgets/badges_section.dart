import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'badge_tile.dart';
import 'ui/game_card.dart';
import 'hupo/hupo.dart';

/// Rozet ızgarası: kazanılanlar renkli, kilitliler gri + kilit simgeli.
/// Herhangi bir rozete dokunulunca kazanma şartı popup'ı açılır.
class BadgesSection extends StatelessWidget {
  const BadgesSection({super.key, required this.badges});

  final List<BadgeInfo> badges;

  @override
  Widget build(BuildContext context) {
    final earnedCount = badges.where((b) => b.earned).length;

    return GameCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Rozetlerim', style: appText(size: 20, weight: FontWeight.w900)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.sunSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '$earnedCount / ${badges.length}',
                  style: appText(size: 14, weight: FontWeight.w900, color: AppColors.sunDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (badges.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    const Hupo(mood: HupoMood.empty, size: 90),
                    Text(
                      'Rozetler çok yakında burada olacak!',
                      style: appText(color: AppColors.muted, weight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.72,
              children: [
                for (final badge in badges)
                  BadgeTile(
                    badge: badge,
                    onTap: () => showBadgeDialog(context, badge),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
