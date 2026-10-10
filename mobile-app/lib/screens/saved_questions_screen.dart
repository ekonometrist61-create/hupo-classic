// Kayıtlı Sorular (Yer İmleri / Yıldızlananlar) ekranı.
//
// Soruları ders → konu hiyerarşisinde gruplar; her soruda şıklar, doğru cevap ve çözüm gösterilir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/question_text.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/ui/responsive_page.dart';

class SavedQuestionsScreen extends ConsumerWidget {
  const SavedQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedQuestionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Kayıtlı Sorular',
          style: appText(size: 18, weight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: savedAsync.when(
            data: (questions) {
              if (questions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark_border_rounded,
                            size: 64, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text(
                          'Kayıtlı sorun yok',
                          style: appText(size: 18, weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kaydettiklerim. Yıldızladığın soruları görmek için dokun.',
                          textAlign: TextAlign.center,
                          style: appText(size: 14, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final gruplar = _grupla(questions);
              return ListView(
                children: [
                  for (final entry in gruplar.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DersGrubu(
                        ders: entry.key,
                        konular: entry.value,
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(
                'Sorular yüklenemedi, sorun değil! Birazdan tekrar deneyelim.',
                style: appText(size: 14, color: AppColors.coral),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Map<String, Map<String, List<SavedQuestion>>> _grupla(List<SavedQuestion> liste) {
  final sonuc = <String, Map<String, List<SavedQuestion>>>{};
  for (final s in liste) {
    final ders = s.question.ders.isEmpty ? 'Diğer' : s.question.ders;
    final konu = s.question.konu.isEmpty ? 'Genel' : s.question.konu;
    sonuc.putIfAbsent(ders, () => {}).putIfAbsent(konu, () => []).add(s);
  }
  return sonuc;
}

class _DersGrubu extends StatelessWidget {
  const _DersGrubu({required this.ders, required this.konular});

  final String ders;
  final Map<String, List<SavedQuestion>> konular;

  @override
  Widget build(BuildContext context) {
    final toplam = konular.values.fold<int>(0, (a, l) => a + l.length);
    return GameCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        shape: const Border(),
        title: Text(ders, style: appText(weight: FontWeight.w800)),
        subtitle: Text('$toplam soru', style: appText(size: 12, color: AppColors.muted)),
        children: [
          for (final konu in konular.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                konu.key,
                style: appText(size: 13, weight: FontWeight.w700, color: AppColors.primaryDark),
              ),
            ),
            for (final item in konu.value) Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SavedQuestionTile(item: item),
            ),
          ],
        ],
      ),
    );
  }
}

class _SavedQuestionTile extends StatelessWidget {
  const _SavedQuestionTile({required this.item});

  final SavedQuestion item;

  @override
  Widget build(BuildContext context) {
    final dogru = item.correctOption;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.question.altKonu ?? item.question.konu,
                  style: appText(size: 12, color: AppColors.muted),
                ),
              ),
              BookmarkButton(questionId: item.questionId),
            ],
          ),
          const SizedBox(height: 6),
          SoruMetni(item.question.text, style: appText(size: 15)),
          const SizedBox(height: 10),
          for (final opt in item.question.options.entries)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: opt.key == dogru ? AppColors.mintSoft : null,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: opt.key == dogru ? AppColors.mint : AppColors.line,
                ),
              ),
              child: Text(
                '${opt.key}) ${opt.value}',
                style: appText(
                  size: 14,
                  weight: opt.key == dogru ? FontWeight.w800 : FontWeight.w500,
                  color: opt.key == dogru ? AppColors.mintDark : AppColors.ink,
                ),
              ),
            ),
          if (dogru == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Bu soru bir deneme sınavında kullanıldığı için cevabı burada gösterilmiyor.',
                style: appText(size: 12, color: AppColors.muted),
              ),
            ),
          if (item.steps.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final adim in item.steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('• $adim', style: appText(size: 13)),
              ),
          ],
        ],
      ),
    );
  }
}
