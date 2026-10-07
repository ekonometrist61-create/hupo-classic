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
import 'daily_challenge_screen.dart';
import 'home_screen.dart';

const String _baslik = 'Arena';
const String _altBaslik = 'Ligde yüksel, günün meydan okumasını tamamla.';
const String _ligYuklenemedi = 'Lig bilgin yüklenemedi, tekrar deneyelim.';
const String _arkadasBaslik = 'Arkadaşına meydan oku';
const String _arkadasAciklama =
    'Hazır seçeneklerle, sohbet olmadan güvenli yarışma. Çok yakında burada!';
const String _yakinda = 'Yakında';

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
                    data: (durum) => LeagueCard(status: durum),
                  ),
                  const SizedBox(height: 12),
                  DailyChallengeCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _ArkadasKarti(),
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

/// Arkadaşla yarışma henüz yok: sahte veri göstermeyiz, dürüstçe "yakında" deriz.
class _ArkadasKarti extends StatelessWidget {
  const _ArkadasKarti();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.8,
      child: GameCard(
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sunSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _yakinda,
                style: appText(size: 12, weight: FontWeight.w900, color: AppColors.coralDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
