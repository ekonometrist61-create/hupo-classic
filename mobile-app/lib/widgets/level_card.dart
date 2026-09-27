import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/motion.dart';
import 'ui/game_card.dart';

/// Mevcut seviye, XP ilerlemesi ve seri özeti.
class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.stats, required this.today});

  final StudentStats stats;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final streak = stats.streakAt(today);

    return GameCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _LevelRing(level: stats.level, progress: stats.levelProgress),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seviye ${stats.level}',
                      style: appText(size: 26, weight: FontWeight.w900, color: AppColors.primary),
                    ),
                    Text('${stats.xp} XP', style: appText(size: 17, weight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      'Sonraki seviyeye sadece ${stats.xpToNextLevel} XP kaldı!',
                      style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: streak > 0 ? AppColors.coralSoft : AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: streak > 0 ? AppColors.coral : AppColors.muted,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    streak > 0
                        ? '$streak günlük seri, devam et!'
                        : 'Bugün bir soru çöz, serini başlat!',
                    style: appText(size: 15, weight: FontWeight.w800),
                  ),
                ),
                if (stats.shields > 0)
                  Tooltip(
                    message: 'Seri kalkanı: bir gün ara verirsen serin korunur',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${stats.shields}',
                            style: appText(size: 13, weight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ],
                      ),
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

class _LevelRing extends StatelessWidget {
  const _LevelRing({required this.level, required this.progress});

  final int level;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Seviye $level, sonraki seviyeye ${(progress * 100).round()} yüzde',
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: motionMs(context, 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.primarySoft,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
            Text(
              '$level',
              style: appText(size: 32, weight: FontWeight.w900, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
