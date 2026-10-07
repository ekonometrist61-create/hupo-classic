import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../utils/motion.dart';
import 'hupo/hupo.dart';
import 'ui/chunky_button.dart';

/// Cevap sonrası alttan açılan yeşil/kırmızı sonuç penceresi.
/// Adım adım çözüm metni, adımlar sırayla belirerek gösterilir.
class ResultSheet extends StatefulWidget {
  const ResultSheet({
    super.key,
    required this.result,
    required this.isLast,
    required this.onContinue,
    this.onRecover,
  });

  final AnswerResult result;
  final bool isLast;
  final VoidCallback onContinue;

  /// Yalnızca yanlış cevapta ve aynı konudan bir soru kuyruktaysa dolu olur.
  /// Dolu ise "Benzer Soru Çöz" düğmesi gösterilir.
  final VoidCallback? onRecover;

  @override
  State<ResultSheet> createState() => _ResultSheetState();
}

class _ResultSheetState extends State<ResultSheet> {
  static const _stepInterval = Duration(milliseconds: 700);

  Timer? _reveal;
  int _visibleSteps = 0;

  @override
  void initState() {
    super.initState();
    final total = widget.result.steps.length;
    if (total > 0) {
      _reveal = Timer.periodic(_stepInterval, (timer) {
        if (!mounted) return;
        setState(() => _visibleSteps++);
        if (_visibleSteps >= total) timer.cancel();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hareket azaltılmışsa çözüm adımlarının hepsi hemen görünür.
    if (reducedMotion(context)) {
      _reveal?.cancel();
      _visibleSteps = widget.result.steps.length;
    }
  }

  @override
  void dispose() {
    _reveal?.cancel();
    super.dispose();
  }

  String get _title {
    final r = widget.result;
    if (r.correct) return r.isRecovery ? 'Kurtardın!' : 'Harikasın!';
    return r.timedOut ? 'Süre doldu, ama pes yok!' : 'Sorun değil, denemek öğretir!';
  }

  String get _subtitle {
    final r = widget.result;
    if (!r.saved) return 'İnternet bağlantında sorun var, bu cevap kaydedilemedi.';
    if (r.correct) {
      if (r.isRecovery) return 'Yanlış cevap gitti, öğrendiğin bilgi kaldı! +${r.earnedXp} XP';
      return r.earnedXp > 0
          ? '+${r.earnedXp} XP kazandın, böyle devam!'
          : 'Doğru! Bunu zaten biliyordun.';
    }
    return r.correctOption.isEmpty ? '' : 'Doğru cevap: ${r.correctOption}';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final ok = r.correct;
    final background = ok ? AppColors.mintSoft : AppColors.coralSoft;
    final strong = ok ? AppColors.mintDark : AppColors.coralDark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: motionMs(context, 420),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => FractionalTranslation(
        translation: Offset(0, 1 - t),
        child: child,
      ),
      child: Semantics(
        liveRegion: true,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Yanlışta kırmızı X yok: sıcak amber "tekrar" simgesi.
                      if (reducedMotion(context) || !ok)
                        Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: strong, shape: BoxShape.circle),
                          child: Icon(
                            ok ? Icons.check_rounded : Icons.refresh_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      else
                        Lottie.asset(
                          'assets/lottie/correct.json',
                          width: 56,
                          height: 56,
                          repeat: false,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title,
                              style: appText(size: 22, weight: FontWeight.w900, color: strong),
                            ),
                            if (_subtitle.isNotEmpty)
                              Text(
                                _subtitle,
                                style: appText(size: 14, weight: FontWeight.w700, color: strong),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (r.steps.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Hupo(mood: HupoMood.solution, variant: r.steps.length, size: 44),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Birlikte çözelim: adım adım',
                            style: appText(size: 13, weight: FontWeight.w900, color: strong),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.28,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var i = 0; i < r.steps.length; i++)
                              _StepTile(
                                number: i + 1,
                                text: r.steps[i],
                                visible: i < _visibleSteps,
                                color: strong,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (ok)
                    ChunkyButton.success(
                      label: widget.isLast ? 'Sonucunu gör' : 'Sonraki soru',
                      onPressed: widget.onContinue,
                    )
                  else if (widget.onRecover != null) ...[
                    ChunkyButton.danger(
                      label: 'Benzer Soru Çöz',
                      onPressed: widget.onRecover,
                    ),
                    const SizedBox(height: 8),
                    ChunkyButton.light(
                      label: widget.isLast ? 'Sonucunu gör' : 'Sonraki soru',
                      onPressed: widget.onContinue,
                    ),
                  ] else
                    ChunkyButton.danger(
                      label: widget.isLast ? 'Sonucunu gör' : 'Sonraki soru',
                      onPressed: widget.onContinue,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.text,
    required this.visible,
    required this.color,
  });

  final int number;
  final String text;
  final bool visible;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Yer baştan ayrılır, böylece adımlar belirirken pencere zıplamaz.
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 350),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.25),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  '$number',
                  style: appText(size: 13, weight: FontWeight.w900, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: appText(size: 15, weight: FontWeight.w700, height: 1.35),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
