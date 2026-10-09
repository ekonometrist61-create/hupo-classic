import 'package:flutter/material.dart';

import '../models/membership_models.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/motion.dart';
import 'hupo/hupo.dart';
import 'ui/game_card.dart';
import 'veli_mesaji_sheet.dart';

/// Profilde "Üyelik" kartı.
///
/// Çocuk uygulamasında bilerek satın alma düğmesi/bağlantısı YOKTUR
/// (mağaza kuralları ve çocuk güvenliği); yalnızca durum gösterilir ve
/// Premium için veliye yönlendiren yumuşak bir cümle yer alır.
/// [MembershipStatus.known] false ise hiçbir şey çizilmez.
class MembershipCard extends StatelessWidget {
  const MembershipCard({super.key, required this.status});

  final MembershipStatus status;

  @override
  Widget build(BuildContext context) {
    if (!status.known) return const SizedBox.shrink();
    return status.active ? _Active(status: status) : _Free(status: status);
  }
}

class _Active extends StatelessWidget {
  const _Active({required this.status});

  final MembershipStatus status;

  @override
  Widget build(BuildContext context) {
    final ends = status.endsAt;
    final left = status.remainingDays;
    final name = status.planName ?? 'Premium';

    return GameCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Hupo(pose: HupoPose.harika, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Üyelik',
                        style: appText(size: 13, weight: FontWeight.w800, color: AppColors.muted)),
                    Text(name, style: appText(size: 22, weight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      'Harikasın, tüm özellikler açık!',
                      style: appText(size: 14, weight: FontWeight.w700, color: AppColors.mintDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (ends != null || left != null) ...[
            const SizedBox(height: 14),
            if (ends != null)
              Text('Bitiş: ${formatDate(ends)}',
                  style: appText(size: 15, weight: FontWeight.w800)),
            if (left != null) ...[
              const SizedBox(height: 2),
              Text('Kalan: $left gün',
                  style: appText(size: 15, weight: FontWeight.w800, color: AppColors.primary)),
              const SizedBox(height: 8),
              _RemainingBar(progress: status.progress, daysLeft: left),
            ],
          ],
          if (status.fromParent) ...[
            const SizedBox(height: 10),
            Text(
              'Bu üyelik velin sayesinde açık. Ona teşekkür etmeyi unutma!',
              style: appText(size: 13, weight: FontWeight.w700, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Free extends StatelessWidget {
  const _Free({required this.status});

  final MembershipStatus status;

  String? get _quotaLine {
    if (!status.gatingActive) return null;
    final today = status.freeQuestionsLeftToday;
    if (today != null) return 'Bugün kalan ücretsiz soru: $today';
    final daily = status.freeDailyQuestions;
    if (daily != null && daily > 0) return 'Günlük ücretsiz soru hakkın: $daily';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final quota = _quotaLine;
    return GameCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Hupo(pose: HupoPose.merakEdiyor, size: 72),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Üyelik',
                    style: appText(size: 13, weight: FontWeight.w800, color: AppColors.muted)),
                Text('Ücretsiz üyelik', style: appText(size: 22, weight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  'Soru çözmeye ve gelişmeye devam edebilirsin.',
                  style: appText(size: 14, weight: FontWeight.w700),
                ),
                if (quota != null) ...[
                  const SizedBox(height: 6),
                  Text(quota,
                      style: appText(size: 14, weight: FontWeight.w800, color: AppColors.primary)),
                ],
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => showVeliMesajiSheet(context),
                    icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                    label: Text(
                      'Velime mesaj hazırla',
                      style: appText(size: 14, weight: FontWeight.w800, color: AppColors.primary),
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

class _RemainingBar extends StatelessWidget {
  const _RemainingBar({required this.progress, required this.daysLeft});

  final double progress;
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Üyelikte $daysLeft gün kaldı',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: progress),
          duration: motionMs(context, 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: 12,
            backgroundColor: AppColors.primarySoft,
            valueColor: const AlwaysStoppedAnimation(AppColors.mint),
          ),
        ),
      ),
    );
  }
}
