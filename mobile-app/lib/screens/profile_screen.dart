import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/league_models.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/badges_section.dart';
import '../widgets/character/active_character_chip.dart';
import 'collection_screen.dart';
import 'settings_screen.dart';
import 'subject_topics_screen.dart';
import 'grade_picker_screen.dart';
import 'saved_questions_screen.dart';
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
  const ProfileScreen({super.key, this.embedded = false});

  /// Alt sekme olarak gömülüyse geri düğmesi gösterilmez.
  final bool embedded;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(statsProvider);
    ref.invalidate(badgesProvider);
    ref.invalidate(leagueProvider);
    ref.invalidate(overviewProvider);
    ref.invalidate(membershipProvider);
    ref.invalidate(myCharactersProvider);
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
                      if (!embedded)
                        IconButton(
                          tooltip: 'Geri',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 28),
                        )
                      else
                        const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Profilim',
                          style: appText(size: 24, weight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Kayıtlı Sorular',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SavedQuestionsScreen()),
                        ),
                        icon: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 28),
                      ),
                      IconButton(
                        tooltip: 'Sınıfını Değiştir',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GradePickerScreen()),
                        ),
                        icon: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
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
                  const Hupo(pose: HupoPose.ayakta, animated: true),
                  const SizedBox(height: 4),
                  Text(
                    name.isEmpty ? 'Şampiyon' : name,
                    style: appText(size: 24, weight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const AktifKarakterChip(koyuZemin: true),
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
                    builder: (o) => ProgressCard(
                      overview: o,
                      onDersDetay: (ders) => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => SubjectTopicsScreen(ders: ders)),
                      ),
                    ),
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
                  const SizedBox(height: 16),
                  _KoleksiyonKarti(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CollectionScreen()),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _VeliIcinSection(),
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
          const Hupo(mood: HupoMood.retry, size: 84),
          const SizedBox(height: 8),
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

// ── Koleksiyon önizleme kartı ─────────────────────────────────────────────────

class _KoleksiyonKarti extends ConsumerWidget {
  const _KoleksiyonKarti({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncKarakterler = ref.watch(myCharactersProvider);
    final kazanilan =
        asyncKarakterler.valueOrNull?.where((k) => k.kazanildi).length ?? 0;
    final toplam = asyncKarakterler.valueOrNull?.length ?? 40;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Karakterlerim',
                    style: appText(
                        weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$kazanilan / $toplam karakter kazanıldı',
                    style: appText(size: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.primary, size: 24),
          ],
        ),
      ),
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
          style: appText(weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ChunkyButton(label: 'Tekrar dene', expanded: false, onPressed: onRetry, height: 48),
      ],
    );
  }
}

const _premiumUrl = 'https://hupolingo.com/premium';
const _veliRaporuUrl = 'https://hupolingo.com/veli';

class _VeliIcinSection extends StatelessWidget {
  const _VeliIcinSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Velim için', style: appText(size: 18, weight: FontWeight.w900)),
        const SizedBox(height: 10),
        _VeliLinkSatiri(
          ikon: Icons.bar_chart_rounded,
          baslik: 'Veli raporu',
          aciklama: 'Gelişimini ve konu ilerlemeni göster',
          renk: AppColors.primary,
          onTap: () => _ac(_veliRaporuUrl),
        ),
        const SizedBox(height: 8),
        _VeliLinkSatiri(
          ikon: Icons.star_rounded,
          baslik: 'Premium hakkında',
          aciklama: 'Tüm özellikler ve fiyatlandırma',
          renk: AppColors.sun,
          onTap: () => _ac(_premiumUrl),
        ),
      ],
    );
  }

  Future<void> _ac(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _VeliLinkSatiri extends StatelessWidget {
  const _VeliLinkSatiri({
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    required this.renk,
    required this.onTap,
  });

  final IconData ikon;
  final String baslik;
  final String aciklama;
  final Color renk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: renk.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(ikon, color: renk, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: appText(size: 14, weight: FontWeight.w800)),
                  Text(aciklama, style: appText(size: 12, color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}
