// Çarpım Tablosu Şifresi ders, açık alıştırma ve kapalı test ekranı.
//
// Akış: Şifre Tanıtımı / Örnek -> Açık Alıştırma -> Kapalı Test -> Tamamlama.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cipher_models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/haptics.dart';
import '../../widgets/cipher_badges_dialog.dart';
import '../../widgets/ui/chunky_button.dart';
import '../../widgets/ui/game_card.dart';
import '../../widgets/ui/responsive_page.dart';

class CipherLessonScreen extends ConsumerStatefulWidget {
  const CipherLessonScreen({super.key, required this.sifreId});

  final String sifreId;

  @override
  ConsumerState<CipherLessonScreen> createState() => _CipherLessonScreenState();
}

enum _CipherStage { lesson, openExercise, closedTest, completed }

class _CipherLessonScreenState extends ConsumerState<CipherLessonScreen> {
  _CipherStage _stage = _CipherStage.lesson;
  int _currentQuestionIndex = 0;
  final _answerController = TextEditingController();
  CipherAnswerResult? _lastResult;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer(MathCipherDetail detail, bool isClosed) async {
    final text = _answerController.text.trim();
    if (text.isEmpty || _isSubmitting) return;
    final ans = int.tryParse(text);
    if (ans == null) return;

    setState(() => _isSubmitting = true);
    AppHaptics.light();

    try {
      final repo = ref.read(quizRepositoryProvider);
      final res = await repo.submitCipherAnswer(
        sifreId: widget.sifreId,
        asama: isClosed ? 'kapali' : 'acik',
        soruIndex: _currentQuestionIndex,
        cevap: ans,
      );
      final result = CipherAnswerResult.fromMap(res);

      if (mounted) {
        setState(() {
          _lastResult = result;
        });
        if (result.dogru) {
          AppHaptics.success();
        } else {
          AppHaptics.error();
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _nextStep(MathCipherDetail detail) async {
    final isClosed = _stage == _CipherStage.closedTest;
    final total = isClosed ? detail.test.length : detail.alistirma.length;

    if (_currentQuestionIndex < total - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answerController.clear();
        _lastResult = null;
      });
    } else {
      // Aşama bitti
      try {
        final repo = ref.read(quizRepositoryProvider);
        await repo.completeCipherStage(
          sifreId: widget.sifreId,
          asama: isClosed ? 'kapali' : 'acik',
        );
        ref.invalidate(ciphersProvider);
        ref.invalidate(cipherDetailProvider(widget.sifreId));

        if (mounted) {
          if (!isClosed) {
            setState(() {
              _stage = _CipherStage.closedTest;
              _currentQuestionIndex = 0;
              _answerController.clear();
              _lastResult = null;
            });
          } else {
            setState(() {
              _stage = _CipherStage.completed;
            });
            AppHaptics.celebration();
            showCipherBadgesDialog(
              context,
              unvan: '${detail.isim} Ustası',
              aciklama:
                  'Artık bu şifre senin! İstersen bir arkadaşına da öğretebilirsin.',
            );
          }
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(cipherDetailProvider(widget.sifreId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          detailAsync.value?.isim ?? 'Şifre Dersi',
          style:
              appText(size: 18, weight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: detailAsync.when(
            data: (detail) {
              return switch (_stage) {
                _CipherStage.lesson => _buildLessonView(detail),
                _CipherStage.openExercise => _buildExerciseView(detail, false),
                _CipherStage.closedTest => _buildExerciseView(detail, true),
                _CipherStage.completed => _buildCompletedView(detail),
              };
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: Text(
                'Şifre detayları yüklenemedi, birazdan tekrar deneyelim.',
                style: appText(size: 14, color: AppColors.coral),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonView(MathCipherDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GameCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Şifre Kuralı',
                style: appText(
                    size: 18,
                    weight: FontWeight.w800,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                detail.tanim,
                style: appText(
                    size: 15,
                    height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Formül: ${detail.formul}',
                  style: appText(
                      size: 14,
                      weight: FontWeight.w700,
                      color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (detail.ornek.adimlar.isNotEmpty)
          GameCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Birlikte çözelim: adım adım',
                  style: appText(
                      weight: FontWeight.w800,
                      color: AppColors.mintDark),
                ),
                const SizedBox(height: 6),
                Text(
                  detail.ornek.soru,
                  style: appText(
                      size: 15, weight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ...detail.ornek.adimlar.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right_rounded,
                              color: AppColors.mint, size: 20),
                          Expanded(
                            child: Text(s,
                                style: appText(size: 14)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        const Spacer(),
        ChunkyButton(
          label: 'Açık Alıştırmaya Başla',
          icon: Icons.play_arrow_rounded,
          onPressed: () {
            setState(() {
              _stage = _CipherStage.openExercise;
              _currentQuestionIndex = 0;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExerciseView(MathCipherDetail detail, bool isClosed) {
    final questionText = isClosed
        ? detail.test[_currentQuestionIndex].soru
        : detail.alistirma[_currentQuestionIndex].soru;
    final total = isClosed ? detail.test.length : detail.alistirma.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              isClosed ? 'Kapalı Test' : 'Açık Alıştırma',
              style: appText(
                  weight: FontWeight.w800, color: AppColors.primary),
            ),
            const Spacer(),
            Text(
              '${_currentQuestionIndex + 1} / $total',
              style: appText(
                  size: 14, weight: FontWeight.w700, color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GameCard(
          child: Column(
            children: [
              Text(
                questionText,
                textAlign: TextAlign.center,
                style: appText(
                    size: 28, weight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: appText(
                    size: 22, weight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: 'Cevabın',
                  hintStyle: appText(size: 18, color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.line, width: 2),
                  ),
                ),
                onSubmitted: (_) {
                  if (_lastResult == null) {
                    _submitAnswer(detail, isClosed);
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_lastResult != null)
          GameCard(
            color:
                _lastResult!.dogru ? AppColors.mintSoft : AppColors.coralSoft,
            borderColor: _lastResult!.dogru ? AppColors.mint : AppColors.coral,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _lastResult!.dogru
                          ? Icons.check_circle_rounded
                          : Icons.refresh_rounded,
                      color: _lastResult!.dogru
                          ? AppColors.mintDark
                          : AppColors.coralDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _lastResult!.dogru
                          ? 'Harikasın, doğru!'
                          : 'Olmadı, hadi doğrusuna bakalım',
                      style: appText(
                        size: 15,
                        weight: FontWeight.w800,
                        color: _lastResult!.dogru
                            ? AppColors.mintDark
                            : AppColors.coralDark,
                      ),
                    ),
                  ],
                ),
                if (_lastResult!.cozum.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._lastResult!.cozum.map((c) =>
                      Text(c, style: appText(size: 13))),
                ],
                if (_lastResult!.sifreHatirlatma != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Şifre: ${_lastResult!.sifreHatirlatma!.tanim}',
                    style: appText(
                        size: 13,
                        weight: FontWeight.w700,
                        color: AppColors.coralDark),
                  ),
                ],
              ],
            ),
          ),
        const Spacer(),
        if (_lastResult == null)
          ChunkyButton(
            label: _isSubmitting ? 'Kontrol ediliyor...' : 'Cevapla',
            icon: Icons.check_rounded,
            onPressed:
                _isSubmitting ? null : () => _submitAnswer(detail, isClosed),
          )
        else
          ChunkyButton(
            label: _currentQuestionIndex < total - 1
                ? 'Sonraki Soru'
                : 'Aşamayı Tamamla',
            icon: Icons.arrow_forward_rounded,
            color: AppColors.mint,
            shadowColor: AppColors.mintDark,
            onPressed: () => _nextStep(detail),
          ),
      ],
    );
  }

  Widget _buildCompletedView(MathCipherDetail detail) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.stars_rounded, size: 80, color: AppColors.sun),
        const SizedBox(height: 16),
        Text(
          'Tebrikler!',
          style:
              appText(size: 24, weight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Artık bu şifre senin! İstersen bir arkadaşına da öğretebilirsin.',
          textAlign: TextAlign.center,
          style: appText(size: 15, color: AppColors.muted),
        ),
        const SizedBox(height: 24),
        ChunkyButton(
          label: 'Bunu bir arkadaşıma anlattım!',
          icon: Icons.share_rounded,
          color: AppColors.sun,
          shadowColor: AppColors.sunDark,
          onPressed: () async {
            final repo = ref.read(quizRepositoryProvider);
            await repo.reportTaughtFriend(detail.id);
            if (mounted) {
              AppHaptics.celebration();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Harikasın! Arkadaşına öğrettiğin için teşekkürler.',
                      style: appText(size: 14, color: Colors.white)),
                  backgroundColor: AppColors.mintDark,
                ),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        ChunkyButton(
          label: 'Listeye Dön',
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
