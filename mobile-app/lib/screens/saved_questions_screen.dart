// Kayıtlı Sorular (Yer İmleri / Yıldızlananlar) ekranı.
//
// Öğrencinin daha önce yıldızladığı soruları listeler, tekrar incelemesine olanak tanır.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
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
          style: appText(size: 18, weight: FontWeight.w800, color: AppColors.ink),
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
                        const Icon(Icons.bookmark_border_rounded, size: 64, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text(
                          'Kayıtlı sorun yok',
                          style: appText(size: 18, weight: FontWeight.w800, color: AppColors.ink),
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

              return ListView.separated(
                itemCount: questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final item = questions[idx];
                  return _SavedQuestionsTile(item: item);
                },
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

class _SavedQuestionsTile extends StatelessWidget {
  const _SavedQuestionsTile({required this.item});

  final SavedQuestion item;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.question.ders,
                  style: appText(size: 12, weight: FontWeight.w700, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.question.konu,
                style: appText(size: 13, weight: FontWeight.w600, color: AppColors.muted),
              ),
              const Spacer(),
              BookmarkButton(questionId: item.questionId),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.question.text,
            style: appText(size: 15, weight: FontWeight.w600, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
