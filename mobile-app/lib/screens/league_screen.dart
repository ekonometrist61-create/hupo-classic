// Ay Ligi tam ekranı: güncel durum + tüm lig basamaklarının merdiveni.
// Sıralama anonimdir (bkz. league_card.dart); burada da başka öğrencinin
// adı/avatarı gösterilmez, yalnızca basamak adları ve "buradasın" işareti.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/league_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/badge_icons.dart';
import '../widgets/league_card.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/responsive_page.dart';
import 'home_screen.dart' show InlineRetry;

const String _baslik = 'Ay Ligi';
const String _merdivenBasligi = 'Lig merdiveni';
const String _merdivenAciklama = 'Her hafta yeterli XP toplarsan bir üst basamağa çıkarsın.';
const String _yuklenemedi = 'Lig bilgin yüklenemedi, tekrar deneyelim.';
const String _buradasin = 'Buradasın';
const String _tamamlandi = 'Geçtin';
const String _kilitli = 'Kilitli';

class LeagueScreen extends ConsumerWidget {
  const LeagueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(leagueProvider);
    final merdiven = ref.watch(leagueLadderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(leagueProvider);
          ref.invalidate(leagueLadderProvider);
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _LigUst(durum: durum.valueOrNull),
            ResponsivePage(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  durum.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, __) => InlineRetry(
                      text: _yuklenemedi,
                      onRetry: () => ref.invalidate(leagueProvider),
                    ),
                    data: (d) => LeagueCard(status: d),
                  ),
                  const SizedBox(height: 28),
                  Text(_merdivenBasligi, style: appText(size: 19, weight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(_merdivenAciklama, style: appText(size: 13, color: AppColors.muted)),
                  const SizedBox(height: 14),
                  merdiven.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    // Üstteki kart zaten hatayı gösterdi; burada sessizce atla.
                    error: (_, __) => const SizedBox.shrink(),
                    data: (tiers) => _Merdiven(
                      tiers: tiers,
                      guncelSira: durum.valueOrNull?.tier,
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

class _LigUst extends StatelessWidget {
  const _LigUst({required this.durum});

  final LeagueStatus? durum;

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
          padding: const EdgeInsets.fromLTRB(8, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Geri',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        durum?.name ?? _baslik,
                        style: appText(size: 30, weight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    if (durum != null)
                      Icon(badgeIcon(durum!.icon), color: Colors.white, size: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Merdiven extends StatelessWidget {
  const _Merdiven({required this.tiers, required this.guncelSira});

  final List<LeagueTier> tiers;

  /// Öğrencinin şu anki lig basamağı; yüklenemediyse null (hepsi nötr görünür).
  final int? guncelSira;

  @override
  Widget build(BuildContext context) {
    if (tiers.isEmpty) return const SizedBox.shrink();
    // En üst basamak en üstte: tırmanış hissi.
    final siraliTersten = tiers.toList()..sort((a, b) => b.tier.compareTo(a.tier));

    return Column(
      children: [
        for (final tier in siraliTersten)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MerdivenBasamagi(
              tier: tier,
              durum: guncelSira == null
                  ? null
                  : tier.tier < guncelSira!
                      ? _BasamakDurumu.gecildi
                      : tier.tier == guncelSira!
                          ? _BasamakDurumu.burada
                          : _BasamakDurumu.kilitli,
            ),
          ),
      ],
    );
  }
}

enum _BasamakDurumu { gecildi, burada, kilitli }

class _MerdivenBasamagi extends StatelessWidget {
  const _MerdivenBasamagi({required this.tier, required this.durum});

  final LeagueTier tier;
  final _BasamakDurumu? durum;

  @override
  Widget build(BuildContext context) {
    final burada = durum == _BasamakDurumu.burada;
    final kilitli = durum == _BasamakDurumu.kilitli;
    final renk = kilitli ? AppColors.muted : tier.color;

    // "Buradasın" vurgusu, lig renginden bağımsız her zaman aynı marka rengiyle
    // gösterilir: Gümüş/Bronz gibi gri/kahve tonlu ligler griye yakın olduğu için
    // kendi rengiyle vurgulanırsa "kilitli" ile karışabilir.
    return GameCard(
      color: burada ? AppColors.primarySoft : AppColors.surface,
      borderColor: burada ? AppColors.primary : AppColors.line,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Opacity(
            opacity: kilitli ? 0.45 : 1,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
              child: Icon(badgeIcon(tier.icon), color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.name,
                  style: appText(
                    weight: FontWeight.w900,
                    color: kilitli ? AppColors.muted : AppColors.ink,
                  ),
                ),
                if (tier.promotionXp != null)
                  Text(
                    'Çıkış: ${tier.promotionXp} XP/hafta',
                    style: appText(size: 12, color: AppColors.muted),
                  ),
              ],
            ),
          ),
          _DurumRozeti(durum: durum),
        ],
      ),
    );
  }
}

class _DurumRozeti extends StatelessWidget {
  const _DurumRozeti({required this.durum});

  final _BasamakDurumu? durum;

  @override
  Widget build(BuildContext context) {
    return switch (durum) {
      _BasamakDurumu.burada => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _buradasin,
            style: appText(size: 12, weight: FontWeight.w900, color: Colors.white),
          ),
        ),
      _BasamakDurumu.gecildi => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 18),
            const SizedBox(width: 4),
            Text(_tamamlandi, style: appText(size: 12, weight: FontWeight.w800, color: AppColors.mintDark)),
          ],
        ),
      _BasamakDurumu.kilitli => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, color: AppColors.muted, size: 16),
            const SizedBox(width: 4),
            Text(_kilitli, style: appText(size: 12, weight: FontWeight.w800, color: AppColors.muted)),
          ],
        ),
      null => const SizedBox.shrink(),
    };
  }
}
