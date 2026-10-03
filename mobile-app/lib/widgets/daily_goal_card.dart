import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/privacy_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/motion.dart';
import 'hupo/hupo.dart';
import 'ui/game_card.dart';

/// Günlük hedef: bugün kaç soru çözüldü, hedefe ne kadar kaldı ve (varsa) seri kalkanı.
class DailyGoalCard extends ConsumerWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(dailyGoalProvider).valueOrNull;
    if (goal == null) return const SizedBox.shrink();
    return DailyGoalView(goal: goal);
  }
}

class DailyGoalView extends StatelessWidget {
  const DailyGoalView({super.key, required this.goal});

  final DailyGoal goal;

  @override
  Widget build(BuildContext context) {
    final done = goal.completed;
    final accent = done ? AppColors.mint : AppColors.primary;

    return GameCard(
      color: done ? AppColors.mintSoft : AppColors.surface,
      borderColor: done ? AppColors.mint : AppColors.line,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Semantics(
            label: 'Günlük hedef',
            value: '${goal.today} / ${goal.goal} soru',
            child: ExcludeSemantics(
              child: SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: goal.progress),
                        duration: motionMs(context, 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => CircularProgressIndicator(
                          value: value,
                          strokeWidth: 7,
                          strokeCap: StrokeCap.round,
                          backgroundColor: AppColors.line,
                          valueColor: AlwaysStoppedAnimation(accent),
                        ),
                      ),
                    ),
                    Icon(
                      done ? Icons.check_rounded : Icons.flag_rounded,
                      color: accent,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Günlük hedef: ${goal.today}/${goal.goal} soru',
                  style: appText(size: 17, weight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  done
                      ? 'Bugünkü hedefini tamamladın, süpersin!'
                      : '${goal.remaining} soru kaldı, sen yaparsın!',
                  style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (done) ...[
            const SizedBox(width: 8),
            const Hupo(mood: HupoMood.goalComplete, size: 60),
          ],
          if (goal.shields > 0)
            Tooltip(
              message: 'Seri kalkanı: bir gün ara verirsen serin korunur',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${goal.shields}',
                      style: appText(size: 14, weight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
