import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/motion.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/character/active_character_card.dart';
import '../widgets/character/active_character_chip.dart';
import '../widgets/league_card.dart';
import '../widgets/notification_bell.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/hero_header.dart';
import '../widgets/hupo/hupo.dart';
import '../widgets/hupo/hupo_loading.dart';
import '../widgets/shield_earned_banner.dart';
import '../widgets/ui/stat_pill.dart';
import '../widgets/ui/subject_style.dart';
import '../models/privacy_models.dart';
import 'privacy_notice_screen.dart';
import 'quiz_screen.dart';
import 'cipher/cipher_list_screen.dart';
import 'daily_challenge_screen.dart';
import 'review_screen.dart';
import '../widgets/character/character_celebration_listener.dart';
import '../widgets/daily_challenge_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static Future<void> openQuiz(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required Future<List<Question>> Function() load,
    required String emptyMessage,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    List<Question> questions;
    // Sorular gelirken Hupo düşünür (sayfa kapanınca overlay de kapanır).
    final loadingRoute = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: QuizLoadingCard(),
          ),
        ),
      ),
    );
    navigator.push(loadingRoute);
    try {
      questions = await load();
      navigator.removeRoute(loadingRoute);
    } catch (_) {
      navigator.removeRoute(loadingRoute);
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Sorular yüklenemedi, sorun değil! Birazdan tekrar deneyelim.'),
        ),
      );
      return;
    }
    if (questions.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(emptyMessage)));
      return;
    }

    await navigator.push(MaterialPageRoute(
      builder: (_) => QuizScreen(title: title, questions: questions),
    ));

    // Quiz'den dönünce özet verileri yenile.
    ref.invalidate(statsProvider);
    ref.invalidate(dueCountProvider);
    ref.invalidate(subjectsProvider);
    ref.invalidate(leagueProvider);
    ref.invalidate(unreadCountProvider);
    ref.invalidate(dailyGoalProvider);
    ref.invalidate(myCharactersProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final repo = ref.watch(quizRepositoryProvider);

    return Scaffold(
      body: profile.when(
        loading: () => const HupoLoading(),
        error: (_, __) => _Message(
          text: 'Profilin yüklenemedi, tekrar deneyelim.',
          actionLabel: 'Tekrar dene',
          onAction: () => ref.invalidate(profileProvider),
        ),
        data: (p) {
          if (p == null || !p.isStudent) {
            return _Message(
              text: 'Bu uygulama yalnızca öğrenci hesapları içindir.',
              actionLabel: 'Çıkış yap',
              onAction: repo.signOut,
            );
          }
          // İlk girişte (veya metin sürümü değişince) gizlilik bildirimi bir kez gösterilir.
          final consent = ref.watch(consentProvider).valueOrNull;
          if (consent != null && !consent.noticeRead) {
            return PrivacyNoticeScreen(
              firstRun: true,
              onAccepted: () => ref.invalidate(consentProvider),
            );
          }

          return ShieldCelebrationListener(
            child: CharacterCelebrationListener(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dailyGoalProvider);
                ref.invalidate(statsProvider);
                ref.invalidate(dueCountProvider);
                ref.invalidate(subjectsProvider);
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _Hero(
                    name: p.fullName,
                    onSignOut: repo.signOut,
                    onProfile: () => ref.read(shellTabProvider.notifier).state = 4,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (consent != null &&
                            consent.parentConsent != ParentConsent.given) ...[
                          const _ConsentNote(),
                          const SizedBox(height: 12),
                        ],

                        // ── 1) Bugünkü hedefin ──────────────────────────
                        const _SectionHeader('Bugünkü hedefin'),
                        const _StreakNudge(),
                        const DailyGoalCard(),
                        const SizedBox(height: 12),
                        DailyChallengeCard(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const DailyChallengeScreen()),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── 2) Kaldığın yer ──────────────────────────────
                        const _SectionHeader('Kaldığın yer'),
                        const _AvatarSection(),
                        const SizedBox(height: 12),
                        _KarakterKisayolu(
                          onTap: () => ref.read(shellTabProvider.notifier).state = 3,
                        ),
                        const SizedBox(height: 12),
                        _ReviewCard(
                          onStart: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ReviewScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _LeagueMini(
                          onOpen: () => ref.read(shellTabProvider.notifier).state = 2,
                        ),
                        const SizedBox(height: 28),

                        // ── 3) Bugünkü odakların ─────────────────────────
                        const _SectionHeader('Bugünkü odakların'),
                        SubjectList(
                          onSelect: (ders) => openQuiz(
                            context,
                            ref,
                            title: ders,
                            load: () => repo.fetchQuizQuestions(ders),
                            emptyMessage:
                                'Bu derse yakında yeni sorular gelecek. Şimdilik başka bir ders seçebilirsin!',
                          ),
                        ),
                        const SizedBox(height: 12),
                        GameCard(
                          color: AppColors.primarySoft,
                          borderColor: AppColors.primary,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CipherListScreen()),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.vpn_key_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Çarpım Tablosu Şifreleri',
                                      style: appText(weight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Şifreleri çöz, çarpım tablosunu ustaca öğren!',
                                      style: appText(size: 12, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.muted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({
    required this.name,
    required this.onSignOut,
    required this.onProfile,
  });

  final String? name;
  final VoidCallback onSignOut;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider).valueOrNull ?? const StudentStats();
    final firstName = (name ?? '').trim().split(' ').first;

    return HeroHeader(
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AktifKarakterChip(
                    koyuZemin: true,
                    onTap: () => ref.read(shellTabProvider.notifier).state = 3,
                  ),
                ),
              ),
              const NotificationBell(),
              IconButton(
                tooltip: 'Profilim ve rozetler',
                onPressed: onProfile,
                icon: const Icon(Icons.account_circle,
                    color: Colors.white, size: 30),
              ),
              IconButton(
                tooltip: 'Çıkış yap',
                onPressed: onSignOut,
                icon: const Icon(Icons.logout, color: Colors.white, size: 26),
              ),
            ],
          ),
          Row(
            children: [
              Hupo(
                mood: HupoMood.greeting,
                variant: DateTime.now().difference(DateTime(DateTime.now().year)).inDays,
                size: 104,
                animated: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  firstName.isEmpty
                      ? 'Merhaba şampiyon!'
                      : 'Merhaba $firstName, hazır mısın?',
                  style: appText(
                      size: 26,
                      weight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatPill(
                icon: Icons.emoji_events,
                iconColor: AppColors.sunDark,
                value: '${stats.level}',
                label: 'Seviye',
              ),
              StatPill(
                icon: Icons.bolt,
                iconColor: AppColors.primary,
                value: '${stats.xp}',
                label: 'XP',
              ),
              StatPill(
                icon: Icons.local_fire_department,
                iconColor: AppColors.coral,
                value: '${stats.streakAt(DateTime.now())}',
                label: 'Seri (gün)',
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: stats.levelProgress),
              duration: motionMs(context, 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 14,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(AppColors.sun),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sonraki seviyeye sadece ${stats.xpToNextLevel} XP kaldı!',
              style: appText(
                size: 13,
                weight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ana ekranı üç odağa ayıran bölüm başlığı (SCREEN_ARCHITECTURE kuralı:
/// aynı anda en fazla 3 birincil odak).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: appText(size: 21, weight: FontWeight.w900),
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(dueCountProvider).valueOrNull ?? 0;
    final active = due > 0;

    return GameCard(
      onTap: onStart,
      color: active ? AppColors.sunSoft : AppColors.surface,
      borderColor: active ? AppColors.sun : AppColors.line,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: active ? AppColors.sun : AppColors.mint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(active ? Icons.replay : Icons.check,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Günün Tekrarı',
                    style: appText(size: 19, weight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(
                  active
                      ? '$due soru seni bekliyor, hadi tekrar edelim!'
                      : 'Bugün tekrar yok, süpersin!',
                  style: appText(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.muted, size: 30),
        ],
      ),
    );
  }
}

/// Veli onayı henüz verilmediyse çocuğa yumuşak bir bilgi (engelleme yok).
class _ConsentNote extends StatelessWidget {
  const _ConsentNote();

  @override
  Widget build(BuildContext context) {
    return GameCard(
      color: AppColors.background,
      borderColor: AppColors.lineDark,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.family_restroom_rounded,
              color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Velinin veli panelinden onay vermesi bekleniyor. Onay verilince her şey tamam olacak!',
              style: appText(
                  size: 13,
                  weight: FontWeight.w800,
                  color: AppColors.muted,
                  height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aktif karakter kartı: çocuğun kazandığı aktif karakteri ve sıradaki gizli
/// karakterin gölgesini gösterir; dokununca koleksiyon ekranını açar.
class _AvatarSection extends StatelessWidget {
  const _AvatarSection();

  @override
  Widget build(BuildContext context) {
    return AktifKarakterKarti(
      onTap: () => ProviderScope.containerOf(context, listen: false)
          .read(shellTabProvider.notifier)
          .state = 3,
    );
  }
}

class _LeagueMini extends ConsumerWidget {
  const _LeagueMini({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final league = ref.watch(leagueProvider).valueOrNull;
    if (league == null) return const SizedBox.shrink();
    return LeagueCard(status: league, compact: true, onTap: onOpen);
  }
}

class SubjectList extends ConsumerWidget {
  const SubjectList({super.key, required this.onSelect});

  final void Function(String ders) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);

    return subjects.when(
      loading: () => const HupoLoading(
        message: 'Hupo dersleri hazırlıyor…',
        compact: true,
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: InlineRetry(
          text: 'Dersler yüklenemedi, tekrar deneyelim.',
          onRetry: () => ref.invalidate(subjectsProvider),
        ),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Hupo(mood: HupoMood.empty, variant: 1, size: 100),
                  const SizedBox(height: 8),
                  Text(
                    'Sorular yolda! Çok yakında burada olacak.',
                    textAlign: TextAlign.center,
                    style: appText(
                        color: AppColors.muted, weight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final s in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SubjectCard(subject: s, onTap: () => onSelect(s.ders)),
              ),
          ],
        );
      },
    );
  }
}

class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subject, required this.onTap});

  final SubjectInfo subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = subjectStyle(subject.ders);
    return GameCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: style.color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(style.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.ders,
                    style: appText(size: 19, weight: FontWeight.w900)),
                Text(
                  '${subject.questionCount} soru',
                  style: appText(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppColors.muted),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: AppColors.primary, size: 26),
          ),
        ],
      ),
    );
  }
}

class InlineRetry extends StatelessWidget {
  const InlineRetry({super.key, required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Hupo(mood: HupoMood.retry, size: 84),
        const SizedBox(height: 8),
        Text(text,
            style: appText(color: AppColors.muted, weight: FontWeight.w700)),
        const SizedBox(height: 12),
        ChunkyButton(
            label: 'Tekrar dene',
            expanded: false,
            onPressed: onRetry,
            height: 48),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Hupo(mood: HupoMood.error, size: 130),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: appText(size: 17, weight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            ChunkyButton(
                label: actionLabel, expanded: false, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

/// Dün çalışıldıysa ve seri bugün devam edecekse Hupo nazikçe hatırlatır (baskı yok, motivasyon var).
class _StreakNudge extends ConsumerWidget {
  const _StreakNudge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider).valueOrNull;
    final last = stats?.lastActiveDate;
    if (stats == null || last == null || stats.streakCount <= 0) {
      return const SizedBox.shrink();
    }
    final now = DateTime.now();
    final gap = DateTime(now.year, now.month, now.day)
        .difference(DateTime(last.year, last.month, last.day))
        .inDays;
    if (gap != 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GameCard(
        color: AppColors.primarySoft,
        borderColor: AppColors.primary,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Hupo(mood: HupoMood.streakRisk, variant: stats.streakCount, size: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${stats.streakCount} günlük serin çok değerli! Bugün bir soru çözersen seri devam eder, sen yaparsın!',
                style: appText(size: 15, weight: FontWeight.w800, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KarakterKisayolu extends ConsumerWidget {
  const _KarakterKisayolu({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncKarakterler = ref.watch(myCharactersProvider);
    final kazanilan =
        asyncKarakterler.valueOrNull?.where((k) => k.kazanildi).length ?? 0;
    final toplam = asyncKarakterler.valueOrNull?.length ?? 40;

    return GameCard(
      onTap: onTap,
      color: AppColors.primarySoft,
      borderColor: AppColors.primary,
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
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
                  style: appText(size: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.primary, size: 22),
        ],
      ),
    );
  }
}

class QuizLoadingCard extends StatelessWidget {
  const QuizLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const HupoLoading(message: 'Hupo soruları seçiyor…'),
    );
  }
}
