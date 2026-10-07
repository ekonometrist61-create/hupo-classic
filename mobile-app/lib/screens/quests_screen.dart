// Günlük görevler ekranı: bugünkü üç görev, ilerleme çubukları, ödül alma.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/app_providers.dart';
import '../services/audio/audio_event.dart';
import '../services/audio/audio_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/ui/responsive_page.dart';
import 'home_screen.dart' show InlineRetry;

const String _baslik = 'Günlük görevler';
const String _altBaslik = 'Her gün tamamlandığında yenilenir.';
const String _yuklenemedi = 'Görevler yüklenemedi, tekrar deneyelim.';
const String _odulAlindi = 'Ödül alındı!';
const String _odeliAl = 'Ödülü al';
const String _tamamlandiBadge = 'Tamamlandı';
const String _xpSuffix = 'XP';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gorevler = ref.watch(myQuestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(myQuestsProvider),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Ust(onRefresh: () => ref.invalidate(myQuestsProvider)),
              ResponsivePage(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: gorevler.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => InlineRetry(
                    text: _yuklenemedi,
                    onRetry: () => ref.invalidate(myQuestsProvider),
                  ),
                  data: (list) => list.isEmpty
                      ? const _BosGorev()
                      : Column(
                          children: [
                            for (final g in list)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _GorevKarti(
                                  gorev: g,
                                  onOdulAl: () => _odul(context, ref, g.kod),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _odul(BuildContext context, WidgetRef ref, String kod) async {
    try {
      await ref.read(quizRepositoryProvider).claimQuestReward(kod);
      ref.invalidate(myQuestsProvider);
      ref.invalidate(statsProvider);
      AudioManager.instance.play(AudioEvent.xpGain);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(_odulAlindi)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ödül alınamadı: $e')),
        );
      }
    }
  }
}

class _Ust extends StatelessWidget {
  const _Ust({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navySoft, AppColors.navyDeep],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Geri',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_baslik, style: appText(size: 22, weight: FontWeight.w900, color: Colors.white)),
                Text(_altBaslik, style: appText(size: 13, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GorevKarti extends StatelessWidget {
  const _GorevKarti({required this.gorev, required this.onOdulAl});

  final Quest gorev;
  final VoidCallback onOdulAl;

  @override
  Widget build(BuildContext context) {
    final tamamlandi = gorev.tamamlandi;
    final odulAlindi = gorev.odulAlindi;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tamamlandi && !odulAlindi ? AppColors.primary : AppColors.line,
          width: tamamlandi && !odulAlindi ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  gorev.baslik,
                  style: appText(
                    size: 15,
                    weight: FontWeight.w800,
                    color: odulAlindi ? AppColors.muted : AppColors.ink,
                  ),
                ),
              ),
              if (odulAlindi)
                const _Rozet(label: _tamamlandiBadge, renk: AppColors.mint)
              else
                _XpEtiket(xp: gorev.odulXp),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            gorev.aciklama,
            style: appText(size: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          _IlerlemeCubugu(oran: gorev.oran),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${gorev.ilerleme} / ${gorev.hedefDeger}',
                style: appText(size: 12, color: AppColors.muted),
              ),
              if (tamamlandi && !odulAlindi)
                TextButton(
                  onPressed: onOdulAl,
                  child: Text(
                    _odeliAl,
                    style: appText(size: 13, weight: FontWeight.w800, color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IlerlemeCubugu extends StatelessWidget {
  const _IlerlemeCubugu({required this.oran});

  final double oran;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: oran,
        minHeight: 10,
        backgroundColor: AppColors.line,
        color: oran >= 1 ? AppColors.mint : AppColors.primary,
      ),
    );
  }
}

class _Rozet extends StatelessWidget {
  const _Rozet({required this.label, required this.renk});

  final String label;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: renk,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: appText(size: 12, weight: FontWeight.w800, color: Colors.white)),
    );
  }
}

class _XpEtiket extends StatelessWidget {
  const _XpEtiket({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: AppColors.sun, size: 16),
        const SizedBox(width: 2),
        Text('+$xp $_xpSuffix', style: appText(size: 12, weight: FontWeight.w800, color: AppColors.sun)),
      ],
    );
  }
}

class _BosGorev extends StatelessWidget {
  const _BosGorev();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          'Bugün için henüz görev tanımlanmamış.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
