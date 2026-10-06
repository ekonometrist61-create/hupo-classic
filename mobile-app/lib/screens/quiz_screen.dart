import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/question_text.dart';
import '../utils/haptics.dart';
import '../utils/motion.dart';
import '../widgets/answer_option.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/report_question_button.dart';
import '../widgets/quiz_top_bar.dart';
import '../widgets/result_sheet.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/hupo/hupo.dart';
import 'result_screen.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.title, required this.questions});

  final String title;
  final List<Question> questions;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final _stopwatch = Stopwatch();
  final _results = <AnswerResult>[];
  Timer? _ticker;

  int _index = 0;
  int _remaining = 0;
  String? _selected;
  AnswerResult? _result;
  bool _submitting = false;

  Question get _question => widget.questions[_index];
  bool get _isLast => _index == widget.questions.length - 1;
  int get _sessionXp => _results.fold(0, (sum, r) => sum + r.earnedXp);

  @override
  void initState() {
    super.initState();
    _remaining = _question.timeLimitSeconds;
    _stopwatch.start();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        timer.cancel();
        _submit(null); // süre doldu
      }
    });
  }

  /// Sunucu, günlük ücretsiz soru hakkı bittiğinde P0402 koduyla reddeder.
  bool _isQuotaError(Object e) => e.toString().contains('P0402');

  Future<void> _showQuotaDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Bugünlük harikaydın!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hupo(mood: HupoMood.correct, semanticLabel: 'Hupo, seni tebrik ediyor'),
            SizedBox(height: 12),
            Text(
              'Bugünkü ücretsiz sorularını tamamladın. Yarın yeni sorularla devam edebilirsin. Daha fazlası için velinle konuşabilirsin.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _submit(String? option) async {
    if (_submitting || _result != null) return;
    _ticker?.cancel();
    _stopwatch.stop();
    setState(() {
      _submitting = true;
      _selected = option;
    });
    AppHaptics.selection();

    final limitMs = _question.timeLimitSeconds * 1000;
    final durationMs = _stopwatch.elapsedMilliseconds.clamp(0, limitMs);

    AnswerResult? result;
    try {
      result = await ref.read(quizRepositoryProvider).submitAnswer(
            questionId: _question.id,
            selectedOption: option,
            durationMs: durationMs,
          );
    } catch (e) {
      if (_isQuotaError(e)) {
        if (mounted) await _showQuotaDialog();
        return;
      }
      if (option == null) {
        // Süre dolduysa akış kopmasın; sonuç yalnızca ekranda gösterilir.
        result = AnswerResult.unsavedTimeout(
          _results.isEmpty ? null : _results.last,
        );
      }
    }

    if (!mounted) return;

    if (result == null) {
      // Şık gönderilemedi: seçimi geri al, süreyi kaldığı yerden sürdür.
      setState(() {
        _selected = null;
        _submitting = false;
      });
      _stopwatch.start();
      _startTicker();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cevabın gönderilemedi, bir kez daha dene!'),
        ),
      );
      return;
    }

    if (result.correct) {
      AppHaptics.medium();
    } else {
      AppHaptics.heavy();
    }
    setState(() {
      _result = result;
      _results.add(result!);
      _submitting = false;
    });
  }

  void _next() {
    if (_isLast) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(results: _results),
      ));
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _result = null;
      _remaining = _question.timeLimitSeconds;
    });
    _stopwatch
      ..reset()
      ..start();
    _startTicker();
  }

  OptionState _optionState(String key) {
    final result = _result;
    if (result == null) {
      return key == _selected ? OptionState.pending : OptionState.idle;
    }
    if (key == result.correctOption) return OptionState.correct;
    if (key == _selected) return OptionState.wrong;
    return OptionState.dimmed;
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    final total = widget.questions.length;
    final result = _result;
    final locked = _submitting || result != null;

    final mood = switch (result) {
      null => (_remaining > 0 && _remaining <= 5)
          ? HupoMood.hurry
          : HupoMood.question,
      AnswerResult(correct: true) => HupoMood.correct,
      _ => HupoMood.wrong,
    };

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  QuizTopBar(
                    title: widget.title,
                    questionLabel: 'Soru ${_index + 1}/$total',
                    progress: (_index + (result != null ? 1 : 0)) / total,
                    sessionXp: _sessionXp,
                    remainingSeconds: _remaining,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(
                        // Alttan açılan pencere şıkları örtmesin diye boşluk.
                        bottom: result == null
                            ? 16
                            : MediaQuery.sizeOf(context).height * 0.45,
                      ),
                      children: [
                        Row(
                          children: [
                            Hupo(mood: mood, variant: _index, size: 72),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                        child: Text(
                                          '${question.konu}  •  ${question.difficultyLabel}',
                                          overflow: TextOverflow.ellipsis,
                                          style: appText(
                                            size: 13,
                                            weight: FontWeight.w800,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    BookmarkButton(questionId: question.id, size: 20),
                                    ReportQuestionButton(questionId: question.id),
                                  ],
                                ),
                        const SizedBox(height: 4),
                        GameCard(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            child: SoruMetni(
                              question.text,
                              textAlign: TextAlign.center,
                              style: appText(size: 21, weight: FontWeight.w800, height: 1.3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final entry in question.options.entries)
                          AnswerOption(
                            key: ValueKey('${question.id}-${entry.key}'),
                            label: entry.key,
                            text: entry.value,
                            state: _optionState(entry.key),
                            onTap: locked ? null : () => _submit(entry.key),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (result != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ResultSheet(
                key: ValueKey('sheet-$_index'),
                result: result,
                isLast: _isLast,
                onContinue: _next,
              ),
            ),
          if (result != null && result.correct && !reducedMotion(context))
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/confetti.json',
                  key: ValueKey('confetti-$_index'),
                  repeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
