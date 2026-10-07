// Arena sekmesi: Ay Ligi, günün meydan okuması ve (yakında) arkadaşla yarışma.
// Dramatik yüzey: Deep Navy üst bölüm; altı sakin krem.
// Sıralamada başka çocukların adı gösterilmez (LeagueCard kuralı).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/daily_challenge_card.dart';
import '../widgets/hupo/hupo.dart';
import '../widgets/league_card.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/responsive_page.dart';
import 'challenge_screen.dart';
import 'daily_challenge_screen.dart';
import 'home_screen.dart';
import 'league_screen.dart';
import 'mock_exam_screen.dart';

const String _baslik = 'Arena';
const String _altBaslik = 'Ligde yüksel, günün meydan okumasını tamamla.';
const String _ligYuklenemedi = 'Lig bilgin yüklenemedi, tekrar deneyelim.';
const String _arkadasBaslik = 'Arkadaşına meydan oku';
const String _arkadasAciklama =
    'Kod paylaş, arkadaşın katılsın — 10 soruda kim daha iyi?';
class ArenaScreen extends ConsumerWidget {
  const ArenaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lig = ref.watch(leagueProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(leagueProvider);
          ref.invalidate(dailyChallengeProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _ArenaUst(),
            ResponsivePage(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  lig.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => InlineRetry(
                      text: _ligYuklenemedi,
                      onRetry: () => ref.invalidate(leagueProvider),
                    ),
                    data: (durum) => LeagueCard(
                      status: durum,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LeagueScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DailyChallengeCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DenemeSinaviKarti(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MockExamsListScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ArkadasKarti(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChallengeHubScreen()),
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

class _ArenaUst extends StatelessWidget {
  const _ArenaUst();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navySoft, AppColors.navyDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _baslik,
                      style: appText(size: 32, weight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _altBaslik,
                      style: appText(
                        size: 15,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Hupo(mood: HupoMood.hurry, size: 110, animated: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _DenemeSinaviKarti extends StatelessWidget {
  const _DenemeSinaviKarti({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deneme Sınavları', style: appText(size: 15, weight: FontWeight.w900)),
                Text(
                  'Sınav pratiği yap, sonuçlarını gör.',
                  style: appText(size: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _ArkadasKarti extends StatelessWidget {
  const _ArkadasKarti({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
            child: const Icon(Icons.group_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_arkadasBaslik, style: appText(weight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  _arkadasAciklama,
                  style: appText(size: 13, color: AppColors.muted, height: 1.3),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
