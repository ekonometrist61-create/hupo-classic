// Günün 5 Sorusu (Daily Challenge) ana ekranı.
//
// Öğrencinin günlük soruları çözmesini, tamamlandığında bonus XP kazanmasını sağlar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_challenge_models.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/question_text.dart';
import '../services/audio/audio_event.dart';
import '../services/audio/audio_manager.dart';
import '../utils/haptics.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/report_question_button.dart';
import '../widgets/ui/chunky_button.dart';
import '../widgets/ui/responsive_page.dart';

class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  int _currentIndex = 0;
  String? _selectedOption;
  bool _answered = false;
  bool _isCorrect = false;
  bool _isCompleting = false;
  AnswerResult? _result;

  void _onOptionSelected(Question question, String option) async {
    if (_answered) return;
    setState(() {
      _selectedOption = option;
      _answered = true;
    });

    final repo = ref.read(quizRepositoryProvider);
    try {
      final res = await repo.submitAnswer(
        questionId: question.id,
        selectedOption: option,
        durationMs: 15000,
      );
      if (mounted) {
        setState(() {
          _result = res;
          _isCorrect = res.correct;
        });
        if (res.correct) {
          AppHaptics.success();
          AudioManager.instance.play(AudioEvent.correct, questionId: question.id);
        } else {
          AppHaptics.error();
          AudioManager.instance.play(AudioEvent.retry, questionId: question.id);
        }
      }
    } catch (_) {
      // Hata olsa da akış devam eder
    }
  }

  Future<void> _completeChallenge(DailyChallenge dc) async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    try {
      final repo = ref.read(quizRepositoryProvider);
      await repo.completeDailyChallenge();
      ref.invalidate(dailyChallengeProvider);
      ref.invalidate(statsProvider);
      if (mounted) {
        AppHaptics.celebration();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Harikasın! Günün 5 Sorusu tamam. +25 XP kazandın, böyle devam!',
              style: appText(size: 14, color: Colors.white),
            ),
            backgroundColor: AppColors.mintDark,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(dailyChallengeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Günün 5 Sorusu',
          style:
              appText(size: 18, weight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: challengeAsync.when(
            data: (dc) {
              if (!dc.mevcut || dc.sorular.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_outline_rounded,
                            size: 64, color: AppColors.muted),
                        const SizedBox(height: 16),
                        Text(
                          'Bugünün soruları hazırlanıyor',
                          style: appText(
                              size: 18,
                              weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yarın yeni sorular seni bekliyor!',
                          style: appText(size: 14, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (dc.tamamlandi) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 64, color: AppColors.mint),
                        const SizedBox(height: 16),
                        Text(
                          'Günün 5 Sorusu Tamamlandı!',
                          textAlign: TextAlign.center,
                          style: appText(
                              size: 20,
                              weight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${dc.dogruSayisi} doğru yaptın. Yarın yeni sorular seni bekliyor!',
                          textAlign: TextAlign.center,
                          style: appText(size: 15, color: AppColors.muted),
                        ),
                        const SizedBox(height: 24),
                        ChunkyButton(
                          label: 'Ana Sayfaya Dön',
                          icon: Icons.home_rounded,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final question = dc.sorular[_currentIndex];
              final isLast = _currentIndex >= dc.sorular.length - 1;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / dc.sorular.length,
                    backgroundColor: AppColors.line,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Soru ${_currentIndex + 1} / ${dc.sorular.length}',
                        style: appText(
                            size: 14,
                            weight: FontWeight.w700,
                            color: AppColors.muted),
                      ),
                      const Spacer(),
                      BookmarkButton(questionId: question.id),
                      ReportQuestionButton(questionId: question.id),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SoruMetni(
                    question.text,
                    style: appText(
                        size: 17,
                        weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),
                  ...question.options.entries.map((opt) {
                    final isSelected = _selectedOption == opt.key;
                    // Yanlışta doğru şık yeşil işaretlenir.
                    final dogruSik = _answered &&
                        !_isCorrect &&
                        _result?.correctOption == opt.key;
                    Color btnColor = AppColors.surface;
                    Color borderCol = AppColors.line;
                    if (_answered) {
                      if (isSelected) {
                        btnColor = _isCorrect
                            ? AppColors.mintSoft
                            : AppColors.coralSoft;
                        borderCol =
                            _isCorrect ? AppColors.mint : AppColors.coral;
                      }
                      if (dogruSik) {
                        btnColor = AppColors.mintSoft;
                        borderCol = AppColors.mint;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: _answered
                            ? null
                            : () => _onOptionSelected(question, opt.key),
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
                                  style: appText(
                                    size: 14,
                                    weight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  opt.value,
                                  style: appText(
                                      size: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (_result != null && !_result!.correct)
                    Expanded(
                      child: SingleChildScrollView(
                        child: _YanlisGeriBildirim(
                          result: _result!,
                          question: question,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  if (_answered)
                    ChunkyButton(
                      label: isLast ? 'Bitir ve XP Kazan' : 'Sonraki Soru',
                      icon: isLast
                          ? Icons.celebration_rounded
                          : Icons.arrow_forward_rounded,
                      color: isLast ? AppColors.sun : AppColors.primary,
                      shadowColor:
                          isLast ? AppColors.sunDark : AppColors.primaryDark,
                      onPressed: () {
                        if (isLast) {
                          _completeChallenge(dc);
                        } else {
                          setState(() {
                            _currentIndex++;
                            _selectedOption = null;
                            _answered = false;
                            _result = null;
                          });
                        }
                      },
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

/// Yanlış cevapta doğru şıkkı ve çözüm adımlarını gösterir.
class _YanlisGeriBildirim extends StatelessWidget {
  const _YanlisGeriBildirim({required this.result, required this.question});

  final AnswerResult result;
  final Question question;

  @override
  Widget build(BuildContext context) {
    final dogruMetin = question.options[result.correctOption];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mintSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dogruMetin == null
                ? 'Doğru cevap: ${result.correctOption}'
                : 'Doğru cevap: ${result.correctOption}) $dogruMetin',
            style: appText(
                size: 15, weight: FontWeight.w800, color: AppColors.mintDark),
          ),
          for (var i = 0; i < result.steps.length; i++) ...[
            const SizedBox(height: 10),
            Text(
              '${i + 1}. ${result.steps[i]}',
              style: appText(size: 14, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}
