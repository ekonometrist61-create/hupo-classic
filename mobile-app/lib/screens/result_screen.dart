import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/motion.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/hero_header.dart';
import '../widgets/hupo/hupo.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.results});

  final List<AnswerResult> results;

  @override
  Widget build(BuildContext context) {
    final total = results.length;
    final correct = results.where((r) => r.correct).length;
    final earnedXp = results.fold<int>(0, (sum, r) => sum + r.earnedXp);
    final last = results.isEmpty ? null : results.last;
    final ratio = total == 0 ? 0.0 : correct / total;

    final message = ratio >= 0.8
        ? 'Muhteşem bir iş çıkardın!'
        : ratio >= 0.5
            ? 'Çok iyi gidiyorsun, devam!'
            : 'Her deneme seni güçlendiriyor!';

    return Scaffold(
      body: Column(
        children: [
          HeroHeader(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 168,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      if (!reducedMotion(context))
                      Positioned(
                        top: 4,
                        right: 8,
                        child: Lottie.asset('assets/lottie/star.json', width: 80, height: 80),
                      ),
                      if (!reducedMotion(context))
                      Positioned(
                        top: 44,
                        left: 12,
                        child: Lottie.asset('assets/lottie/star.json', width: 56, height: 56),
                      ),
                      Hupo(
                        mood: ratio >= 0.5 ? HupoMood.resultHigh : HupoMood.resultLow,
                        variant: correct,
                        size: 160,
                        animated: true,
                      ),
                    ],
                  ),
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: appText(size: 28, weight: FontWeight.w900, color: Colors.white, height: 1.15),
                ),
                const SizedBox(height: 6),
                Text(
                  '$total sorunun $correct tanesini bildin!',
                  style: appText(
                    size: 18,
                    weight: FontWeight.w800,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _Figure(
                          icon: Icons.bolt_rounded,
                          color: AppColors.primary,
                          value: '+$earnedXp',
                          label: 'Kazanılan XP',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Figure(
                          icon: Icons.emoji_events_rounded,
                          color: AppColors.sunDark,
                          value: '${last?.level ?? 1}',
                          label: 'Seviye',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Figure(
                          icon: Icons.local_fire_department_rounded,
                          color: AppColors.coral,
                          value: '${last?.streakCount ?? 0}',
                          label: 'Seri (gün)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _TipCard(wrong: total - correct),
                  const Spacer(),
                  SafeArea(
                    top: false,
                    child: ChunkyButton(
                      label: 'Ana sayfaya dön',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
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

/// Yanlışlar ertesi gün tekrar listesine düşer (aralıklı tekrar); çocuğa bunu anlatır.
class _TipCard extends StatelessWidget {
  const _TipCard({required this.wrong});

  final int wrong;

  @override
  Widget build(BuildContext context) {
    final allCorrect = wrong == 0;
    return GameCard(
      color: allCorrect ? AppColors.mintSoft : AppColors.sunSoft,
      edgeColor: allCorrect ? AppColors.mint : AppColors.sun,
      child: Row(
        children: [
          Icon(
            allCorrect ? Icons.local_fire_department_rounded : Icons.replay_rounded,
            color: allCorrect ? AppColors.mintDark : AppColors.sunDark,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              allCorrect
                  ? 'Hepsini bildin! Serini korumak için yarın da gel.'
                  : 'Yanlış yaptığın $wrong soru yarın tekrar listende olacak. Böyle daha kalıcı öğrenirsin!',
              style: appText(size: 15, weight: FontWeight.w800, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(value, style: appText(size: 24, weight: FontWeight.w900)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: appText(size: 12, weight: FontWeight.w700, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
