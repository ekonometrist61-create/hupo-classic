import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/motion.dart';
import 'character/active_character_chip.dart';

/// Soru ekranının üst şeridi: kapat, ilerleme çubuğu, kalan süre,
/// anlık kazanılan XP ve soru sayacı.
class QuizTopBar extends StatelessWidget {
  const QuizTopBar({
    super.key,
    required this.title,
    required this.questionLabel,
    required this.progress,
    required this.sessionXp,
    required this.remainingSeconds,
    required this.onClose,
  });

  final String title;
  final String questionLabel;

  /// 0.0 - 1.0
  final double progress;

  /// Bu oturumda kazanılan toplam XP.
  final int sessionXp;
  final int remainingSeconds;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Çık',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 30),
            ),
            Expanded(
              child: Semantics(
                label: 'İlerleme',
                value: '${(progress * 100).round()} yüzde',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: progress.clamp(0.0, 1.0)),
                    duration: motionMs(context, 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 16,
                      backgroundColor: AppColors.line,
                      valueColor: const AlwaysStoppedAnimation(AppColors.mint),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TimerPill(remainingSeconds: remainingSeconds),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                XpChip(xp: sessionXp),
                const SizedBox(width: 8),
                const AktifKarakterChip(kompakt: true),
              ],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '$title  •  $questionLabel',
                overflow: TextOverflow.ellipsis,
                style: appText(size: 14, weight: FontWeight.w800, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TimerPill extends StatelessWidget {
  const TimerPill({super.key, required this.remainingSeconds});

  final int remainingSeconds;

  static String format(int seconds) {
    final s = seconds < 0 ? 0 : seconds;
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final urgent = remainingSeconds <= 10;
    final fg = urgent ? Colors.white : AppColors.primary;
    return Semantics(
      label: 'Kalan süre',
      value: '$remainingSeconds saniye',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: urgent ? AppColors.coral : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: urgent ? AppColors.coralDark : AppColors.lineDark,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_rounded, size: 20, color: fg),
            const SizedBox(width: 4),
            Text(
              format(remainingSeconds),
              style: appText(weight: FontWeight.w900, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

class XpChip extends StatelessWidget {
  const XpChip({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.sun,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.sunDark, offset: Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 20, color: AppColors.ink),
          const SizedBox(width: 2),
          TweenAnimationBuilder<double>(
            tween: Tween(end: xp.toDouble()),
            duration: motionMs(context, 600),
            curve: Curves.easeOut,
            builder: (context, value, _) => Text(
              '+${value.round()} XP',
              style: appText(size: 15, weight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
