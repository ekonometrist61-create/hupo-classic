// Günün 5 Sorusu özet kartı (Ana ekranda gösterilir).
//
// Öğrencinin bugünkü 5 soruyu çözüp çözmediğini, bonus XP'yi ve durumunu gösterir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_challenge_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'ui/game_card.dart';

class DailyChallengeCard extends ConsumerWidget {
  const DailyChallengeCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(dailyChallengeProvider);

    return challengeAsync.when(
      data: (dc) {
        if (!dc.mevcut || dc.toplam == 0) return const SizedBox.shrink();

        final bool isDone = dc.tamamlandi;
        final int doneCount = dc.cevaplanan;
        final int totalCount = dc.toplam;

        return GameCard(
          color: isDone ? AppColors.mintSoft : AppColors.sunSoft,
          borderColor: isDone ? AppColors.mint : AppColors.sun,
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.mint : AppColors.sun,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : Icons.star_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Günün 5 Sorusu',
                          style: appText(
                            size: 16,
                            weight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.mintDark : AppColors.sunDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+25 XP',
                            style: appText(size: 12, weight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDone
                          ? 'Tamamlandı! Yarın yeni sorular seni bekliyor!'
                          : (doneCount > 0
                              ? '$doneCount / $totalCount tamamlandı, devam et!'
                              : 'Bugünün 5 sorusu hazır. Bitirince bonus XP seni bekliyor!'),
                      style: appText(
                        size: 13,
                        weight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.muted),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
