import 'package:flutter/material.dart';

import '../models/league_models.dart';
import '../theme/app_theme.dart';
import '../utils/motion.dart';
import 'ui/game_card.dart';
import 'ui/subject_style.dart';

/// Genel ilerleme: toplam çözülen soru, doğruluk, en uzun seri ve ders bazlı ilerleme.
class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, required this.overview, this.onDersDetay});

  final ProfileOverview overview;

  /// Ders adıyla konu detay ekranına yönlendirme (opsiyonel).
  final void Function(String ders)? onDersDetay;

  @override
  Widget build(BuildContext context) {
    final accuracy = overview.accuracy;

    return GameCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İlerlemem', style: appText(size: 20, weight: FontWeight.w900)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Mini(value: '${overview.totalSolved}', label: 'Çözülen soru'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Mini(
                  value: accuracy == null ? '-' : '%$accuracy',
                  label: 'Doğruluk',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Mini(value: '${overview.longestStreak} gün', label: 'En uzun seri'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (overview.subjects.isEmpty)
            Text(
              'Soru çözdükçe ders ilerlemen burada görünecek.',
              style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted),
            )
          else
            for (final s in overview.subjects)
              _SubjectRow(
                progress: s,
                onTap: onDersDetay == null ? null : () => onDersDetay!(s.ders),
              ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: appText(size: 20, weight: FontWeight.w900, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: appText(size: 11, weight: FontWeight.w800, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.progress, this.onTap});

  final SubjectProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = subjectStyle(progress.ders);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(style.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          progress.ders,
                          style: appText(size: 15, weight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        '${progress.solved}/${progress.total} soru',
                        style: appText(size: 12, weight: FontWeight.w800, color: AppColors.muted),
                      ),
                      if (onTap != null)
                        const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: progress.completion),
                      duration: motionMs(context, 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: AppColors.line,
                        valueColor: AlwaysStoppedAnimation(style.color),
                      ),
                    ),
                  ),
                  if (progress.solved > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Başarı %${progress.success}',
                        style: appText(size: 12, weight: FontWeight.w800, color: AppColors.muted),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
