// Tekrar (Yanlışları Tekrar Çöz) ekranı.
//
// Öğrencinin aralıklı tekrar zamanı gelmiş yanlış sorularını gözden geçirmesini sağlar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/report_question_button.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/responsive_page.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  List<Question>? _questions;
  int _currentIndex = 0;
  String? _selectedOption;
  bool _answered = false;
  bool _isCorrect = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final repo = ref.read(quizRepositoryProvider);
      final list = await repo.fetchReviewQuestions(limit: 10);
      if (mounted) {
        setState(() {
          _questions = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSelect(Question q, String opt) async {
    if (_answered) return;
    setState(() {
      _selectedOption = opt;
      _answered = true;
    });

    final repo = ref.read(quizRepositoryProvider);
    try {
      final res = await repo.submitAnswer(
        questionId: q.id,
        selectedOption: opt,
        durationMs: 15000,
      );
      if (mounted) {
        setState(() {
          _isCorrect = res.correct;
        });
        if (res.correct) {
          AppHaptics.success();
        } else {
          AppHaptics.error();
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Günün Tekrarı',
          style: appText(size: 18, weight: FontWeight.w800, color: AppColors.ink),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_questions == null || _questions!.isEmpty)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 64, color: AppColors.mint),
                            const SizedBox(height: 16),
                            Text(
                              'Bugün tekrar yok, süpersin!',
                              textAlign: TextAlign.center,
                              style: appText(size: 20, weight: FontWeight.w800, color: AppColors.ink),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bugünlük tekrarların bitti, harikasın! Yarın yeni sorularla görüşürüz.',
                              textAlign: TextAlign.center,
                              style: appText(size: 14, color: AppColors.muted),
                            ),
                            const SizedBox(height: 24),
                            ChunkyButton(
                              label: 'Tamamdır',
                              icon: Icons.thumb_up_rounded,
                              color: AppColors.mint,
                              shadowColor: AppColors.mintDark,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildQuestionView(),
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final list = _questions!;
    final question = list[_currentIndex];
    final isLast = _currentIndex >= list.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (_currentIndex + 1) / list.length,
          backgroundColor: AppColors.line,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Tekrar ${_currentIndex + 1} / ${list.length}',
              style: appText(size: 14, weight: FontWeight.w700, color: AppColors.muted),
            ),
            const Spacer(),
            BookmarkButton(questionId: question.id),
            ReportQuestionButton(questionId: question.id),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          question.text,
          style: appText(size: 17, weight: FontWeight.w700, color: AppColors.ink),
        ),
        const SizedBox(height: 24),
        ...question.options.entries.map((opt) {
          final isSelected = _selectedOption == opt.key;
          Color btnColor = AppColors.surface;
          Color borderCol = AppColors.line;
          if (_answered && isSelected) {
            btnColor = _isCorrect ? AppColors.mintSoft : AppColors.coralSoft;
            borderCol = _isCorrect ? AppColors.mint : AppColors.coral;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: _answered ? null : () => _onSelect(question, opt.key),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: btnColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        opt.key,
                        style: appText(size: 14, weight: FontWeight.w800, color: AppColors.primaryDark),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        opt.value,
                        style: appText(size: 15, weight: FontWeight.w600, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        if (_answered)
          ChunkyButton(
            label: isLast ? 'Tekrarı Bitir' : 'Sonraki Soru',
            icon: isLast ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
            color: isLast ? AppColors.mint : AppColors.primary,
            shadowColor: isLast ? AppColors.mintDark : AppColors.primaryDark,
            onPressed: () {
              if (isLast) {
                Navigator.of(context).pop();
              } else {
                setState(() {
                  _currentIndex++;
                  _selectedOption = null;
                  _answered = false;
                });
              }
            },
          ),
      ],
    );
  }
}
