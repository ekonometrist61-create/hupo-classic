import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/league_models.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/badges_section.dart';
import 'settings_screen.dart';
import '../utils/format.dart';
import '../widgets/league_card.dart';
import '../widgets/level_card.dart';
import '../widgets/membership_card.dart';
import '../widgets/progress_card.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/hero_header.dart';
import '../widgets/hupo/hupo.dart';
import '../widgets/hupo/hupo_loading.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(statsProvider);
    ref.invalidate(badgesProvider);
    ref.invalidate(leagueProvider);
    ref.invalidate(overviewProvider);
    ref.invalidate(membershipProvider);
    await Future.wait([
      ref.read(statsProvider.future),
      ref.read(badgesProvider.future),
      ref.read(leagueProvider.future),
      ref.read(overviewProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final stats = ref.watch(statsProvider);
    final badges = ref.watch(badgesProvider);
    final league = ref.watch(leagueProvider);
    final overview = ref.watch(overviewProvider);
    // Hata/yüklenme sırasında sessizce hiçbir şey gösterme (üyelik bilgisi zorunlu değil).
    final membership = ref.watch(membershipProvider).valueOrNull;
    final name = (profile?.fullName ?? '').trim();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            HeroHeader(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Geri',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 28),
                      ),
                      Expanded(
                        child: Text(
                          'Profilim',
                          style: appText(size: 24, weight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Ayarlar',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                        icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const Hupo(pose: HupoPose.ayakta, size: 120, animated: true),
                  const SizedBox(height: 4),
                  Text(
                    name.isEmpty ? 'Şampiyon' : name,
                    style: appText(size: 24, weight: FontWeight.w900, color: Colors.white),
                  ),
                  if (overview.valueOrNull?.joinedAt != null) ...[
                    const SizedBox(height: 8),
                    _MembershipPill(joinedAt: overview.valueOrNull!.joinedAt!),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                children: [
                  _Section<LeagueStatus>(
                    value: league,
                    retryLabel: 'Lig bilgin yüklenemedi, tekrar deneyelim.',
                    onRetry: () => ref.invalidate(leagueProvider),
                    builder: (status) => LeagueCard(status: status),
                  ),
                  const SizedBox(height: 16),
                  LevelCard(
                    stats: stats.valueOrNull ?? const StudentStats(),
                    today: DateTime.now(),
                  ),
                  if (membership != null && membership.known) ...[
                    const SizedBox(height: 16),
                    MembershipCard(status: membership),
                  ],
                  const SizedBox(height: 16),
                  _Section<ProfileOverview>(
                    value: overview,
                    retryLabel: 'İlerleme bilgin yüklenemedi, tekrar deneyelim.',
                    onRetry: () => ref.invalidate(overviewProvider),
                    builder: (o) => ProgressCard(overview: o),
                  ),
                  const SizedBox(height: 16),
                  badges.when(
                    loading: () => const HupoLoading(
                      message: 'Hupo rozetlerini topluyor…',
                      compact: true,
                    ),
                    error: (_, __) => _RetryMessage(
                      onRetry: () => ref.invalidate(badgesProvider),
                    ),
                    data: (list) => BadgesSection(badges: list),
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

/// Bir veri bölümünü yüklenirken/hatada/başarıda çizer.
class _Section<T> extends StatelessWidget {
  const _Section({
    required this.value,
    required this.builder,
    required this.onRetry,
    required this.retryLabel,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const HupoLoading(
        message: 'Hupo ilerlemeni hazırlıyor…',
        compact: true,
      ),
      error: (_, __) => Column(
        children: [
          Text(
            retryLabel,
            textAlign: TextAlign.center,
            style: appText(size: 15, weight: FontWeight.w700, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          ChunkyButton(label: 'Tekrar dene', expanded: false, height: 44, onPressed: onRetry),
        ],
      ),
      data: builder,
    );
  }
}

class _MembershipPill extends StatelessWidget {
  const _MembershipPill({required this.joinedAt});

  final DateTime joinedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Üyelik: ${formatDate(joinedAt)} • ${membershipLabel(joinedAt, DateTime.now())}',
        textAlign: TextAlign.center,
        style: appText(size: 13, weight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Hupo(mood: HupoMood.error, size: 96),
        const SizedBox(height: 8),
        Text(
          'Rozetlerin yüklenemedi, tekrar deneyelim.',
          textAlign: TextAlign.center,
          style: appText(size: 16, weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ChunkyButton(label: 'Tekrar dene', expanded: false, onPressed: onRetry, height: 48),
      ],
    );
  }
}
