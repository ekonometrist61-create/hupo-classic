import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/survey_models.dart';
import '../../providers/app_providers.dart';
import '../../services/error_reporting.dart';
import '../../theme/app_theme.dart';
import '../ui/chunky_button.dart';
import 'survey_sheet.dart';

const String _etiket = 'Hupolingo anketi';
const String _hataMetni = 'Anket yüklenemedi. Birazdan tekrar deneyelim.';
const String _tekrarDene = 'Tekrar dene';
const String _doldurEtiketi = 'Anketi doldur';
const String _ertele = 'Şimdi değil';

/// Veli ana ekranında, ertelenmemiş aktif bir anket varsa gösterilen küçük kart.
/// Anket yoksa, yükleniyorsa veya veli değilse hiçbir şey çizmez.
class SurveyPromptCard extends ConsumerWidget {
  const SurveyPromptCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anketler = ref.watch(aktifAnketlerProvider);
    return anketler.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _HataKarti(
        onRetry: () => ref.invalidate(aktifAnketlerProvider),
      ),
      data: (liste) {
        if (liste.isEmpty) return const SizedBox.shrink();
        return _AnketKarti(anket: liste.first);
      },
    );
  }
}

class _AnketKarti extends ConsumerWidget {
  const _AnketKarti({required this.anket});

  final Anket anket;

  Future<void> _sonra(WidgetRef ref) async {
    try {
      await ref.read(surveyDeferralProvider).ertele(anket);
    } on Exception catch (e, s) {
      // Kayıt yazılamadıysa anket bu oturumda yine de bellekten ertelenmiş kalır.
      reportError(e, s);
    }
    ref.invalidate(aktifAnketlerProvider);
  }

  void _doldur(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => SurveySheet(anket: anket),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soruSayisi = anket.sorular.length;
    return Semantics(
      container: true,
      label: '$_etiket: ${anket.ad}',
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.poll_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _etiket,
                        style: appText(size: 13, weight: FontWeight.w800, color: AppColors.muted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        anket.ad,
                        style: appText(size: 17, weight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$soruSayisi kısa soru',
                        style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ChunkyButton(
              label: _doldurEtiketi,
              height: 52,
              onPressed: () => _doldur(context),
            ),
            const SizedBox(height: 8),
            ChunkyButton.light(
              label: _ertele,
              onPressed: () => _sonra(ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _HataKarti extends StatelessWidget {
  const _HataKarti({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _hataMetni,
            style: appText(size: 15, weight: FontWeight.w700, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: ChunkyButton.light(
              label: _tekrarDene,
              expanded: false,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}
