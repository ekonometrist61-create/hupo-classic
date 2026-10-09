import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/question_text.dart';
import '../services/audio/audio_event.dart';
import '../services/audio/audio_manager.dart';
import '../utils/breakpoints.dart';
import '../utils/haptics.dart';
import '../utils/motion.dart';
import '../widgets/answer_option.dart';
import '../widgets/bookmark_button.dart';
import '../widgets/report_question_button.dart';
import '../widgets/quiz_top_bar.dart';
import '../widgets/result_sheet.dart';
import '../widgets/ui/game_card.dart';
import '../widgets/hupo/hupo.dart';
import '../widgets/veli_mesaji_sheet.dart';
import 'result_screen.dart';

// Web / klavye metinleri (const).
const String _cikisBaslik = 'Çıkmak istiyor musun?';
const String _cikisGovde =
    'Çözdüğün sorular kayıtlı kalır. Kalan sorular için sonra yeni bir tur başlatabilirsin. Sen karar verirken süre durur.';
const String _cikisDevam = 'Devam et';
const String _cikisCik = 'Çık';
const String _klavyeIpucu =
    'Klavye: 1–4 veya A–D ile seç · Enter ile devam et · Esc ile çık';

/// Cevap sonucu göründükten sonra Enter'ın hemen "devam"a basmaması için bekleme.
const Duration _enterBekleme = Duration(milliseconds: 400);

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
  late final List<Question> _queue = List.of(widget.questions);
  Timer? _ticker;

  int _index = 0;
  int _remaining = 0;
  String? _selected;
  AnswerResult? _result;
  bool _submitting = false;

  /// "Benzer Soru Çöz" ile kuyruğa taşınan sorunun hangi yanlış soruyu
  /// kurtarmaya çalıştığı; bir sonraki gönderimde tüketilir (tek seferlik).
  String? _pendingKurtarmaOf;

  // Klavye (web/masaüstü): quiz genel odağı, şık odakları, Enter bekleme ve çıkış diyaloğu.
  final _klavyeOdagi = FocusNode(debugLabel: 'quizKlavye', skipTraversal: true);
  final _sikOdaklari = <FocusNode>[];
  bool _enterHazir = false;
  Timer? _enterZamanlayici;
  bool _cikisDiyaloguAcik = false;

  /// Tablette kısayol ipucu, ilk klavye olayından sonra görünür (dokunmatikte hiç görünmez).
  bool _klavyeKullanildi = false;

  FocusNode _sikOdagi(int i) {
    while (_sikOdaklari.length <= i) {
      _sikOdaklari.add(FocusNode(debugLabel: 'sik${_sikOdaklari.length}'));
    }
    return _sikOdaklari[i];
  }

  Question get _question => _queue[_index];
  bool get _isLast => _index == _queue.length - 1;
  int get _sessionXp => _results.fold(0, (sum, r) => sum + r.earnedXp);

  /// Yanlış cevaplanan [konu]dan, kuyrukta henüz sorulmamış bir soru varsa
  /// onun sırasını döner; yoksa null (uydurma seçenek sunulmaz).
  int? _benzerSoruIndex(String konu) {
    for (var i = _index + 1; i < _queue.length; i++) {
      if (_queue[i].konu == konu) return i;
    }
    return null;
  }

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
    _enterZamanlayici?.cancel();
    _klavyeOdagi.dispose();
    for (final n in _sikOdaklari) {
      n.dispose();
    }
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
            Hupo(
                mood: HupoMood.correct,
                semanticLabel: 'Hupo, seni tebrik ediyor'),
            SizedBox(height: 12),
            Text(
              'Bugünkü ücretsiz sorularını tamamladın. Yarın yeni sorularla devam edebilirsin.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            // Velinin göreceği mesajı hazırlar; çocuk burada satın almaz.
            onPressed: () => showVeliMesajiSheet(ctx),
            child: const Text('Velime mesaj hazırla'),
          ),
          TextButton(
            autofocus: true, // Enter ile kapanır
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
    // Odaklı şık kilitlenince klavye odağı quiz'e dönsün (Enter/Esc çalışmaya devam eder).
    _klavyeOdagi.requestFocus();

    final limitMs = _question.timeLimitSeconds * 1000;
    final durationMs = _stopwatch.elapsedMilliseconds.clamp(0, limitMs);
    final kurtarmaOf = _pendingKurtarmaOf;

    AnswerResult? result;
    try {
      result = await ref.read(quizRepositoryProvider).submitAnswer(
            questionId: _question.id,
            selectedOption: option,
            durationMs: durationMs,
            kurtarmaOf: kurtarmaOf,
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
      // Çıkış diyaloğu açıkken süre durur; diyalog kapanınca sürdürülür.
      if (!_cikisDiyaloguAcik) {
        _stopwatch.start();
        _startTicker();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cevabın gönderilemedi, bir kez daha dene!'),
        ),
      );
      return;
    }

    if (result.correct) {
      AppHaptics.medium();
      // correct → kısa delay → xpGain (XP varsa)
      if (result.earnedXp > 0) {
        AudioManager.instance.playSequence(
          [AudioEvent.correct, AudioEvent.xpGain],
          questionId: _question.id,
        );
      } else {
        AudioManager.instance
            .play(AudioEvent.correct, questionId: _question.id);
      }
    } else {
      AppHaptics.heavy();
      // Yanlış + yeniden deneme hakkı varsa "bir daha dene" sesi
      if (_benzerSoruIndex(_question.konu) != null) {
        AudioManager.instance.play(AudioEvent.retry, questionId: _question.id);
      }
    }
    setState(() {
      _result = result;
      _enterHazir = false;
      _results.add(result!);
      _submitting = false;
      _pendingKurtarmaOf = null;
    });
    // Geri bildirimi okumadan Enter ile atlamayı önler (ilk 400 ms yok sayılır).
    _enterZamanlayici?.cancel();
    _enterZamanlayici = Timer(_enterBekleme, () => _enterHazir = true);
  }

  void _next() {
    if (_isLast) {
      // Quiz bitince görev ilerlemesi ve istatistikler güncellenmiş olabilir.
      ref.invalidate(myQuestsProvider);
      ref.invalidate(statsProvider);
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
    _klavyeOdagi.requestFocus();
  }

  // ── Klavye ve çıkış onayı (web/masaüstü) ─────────────────────────────

  /// Çıkış isteği (X, Esc, tarayıcı/sistem geri). Yalnızca web'de onay sorulur;
  /// telefon/native davranışı değişmez. Onay boyunca süre durur.
  Future<void> _cikisIste() async {
    if (!kIsWeb) {
      Navigator.of(context).pop();
      return;
    }
    if (_cikisDiyaloguAcik) return;
    _cikisDiyaloguAcik = true;
    _ticker?.cancel();
    _stopwatch.stop();

    final cik = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(_cikisBaslik),
        content: const Text(_cikisGovde),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(_cikisCik),
          ),
          // Varsayılan odak: Devam et (Enter / Esc ile de devam edilir).
          ElevatedButton(
            autofocus: true,
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(_cikisDevam),
          ),
        ],
      ),
    );
    _cikisDiyaloguAcik = false;
    if (!mounted) return;
    if (cik == true) {
      Navigator.of(context).pop();
      return;
    }
    // Devam: cevap bekleniyorsa süre kaldığı yerden sürer.
    if (_result == null && !_submitting) {
      _stopwatch.start();
      _startTicker();
    }
    _klavyeOdagi.requestFocus();
  }

  /// Şıklar arasında odak gezdirir (Tab ile aynı mantık, döngüsel).
  void _sikOdagiGezdir(int yon) {
    final n = _question.options.length;
    if (n == 0) return;
    var simdiki = -1;
    for (var i = 0; i < n && i < _sikOdaklari.length; i++) {
      if (_sikOdaklari[i].hasFocus) simdiki = i;
    }
    final hedef =
        simdiki == -1 ? (yon > 0 ? 0 : n - 1) : (simdiki + yon + n) % n;
    _sikOdagi(hedef).requestFocus();
  }

  /// 1–4 / A–D tuşunun şık sırası (yoksa null).
  int? _sikSirasi(LogicalKeyboardKey k) {
    const rakamlar = [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
    ];
    const sayiTuslari = [
      LogicalKeyboardKey.numpad1,
      LogicalKeyboardKey.numpad2,
      LogicalKeyboardKey.numpad3,
      LogicalKeyboardKey.numpad4,
    ];
    const harfler = [
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyB,
      LogicalKeyboardKey.keyC,
      LogicalKeyboardKey.keyD,
    ];
    for (final liste in [rakamlar, sayiTuslari, harfler]) {
      final i = liste.indexOf(k);
      if (i != -1) return i;
    }
    return null;
  }

  KeyEventResult _tusuIsle(FocusNode node, KeyEvent event) {
    // Üstte diyalog/başka rota varsa kısayollar çalışmaz.
    final rota = ModalRoute.of(context);
    if (rota == null || !rota.isCurrent) return KeyEventResult.ignored;
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    if (!_klavyeKullanildi) setState(() => _klavyeKullanildi = true);

    final hw = HardwareKeyboard.instance;
    if (hw.isControlPressed || hw.isMetaPressed || hw.isAltPressed) {
      return KeyEventResult.ignored;
    }

    final tus = event.logicalKey;
    final sira = _sikSirasi(tus);
    final enter = tus == LogicalKeyboardKey.enter ||
        tus == LogicalKeyboardKey.numpadEnter;
    final yon = tus == LogicalKeyboardKey.arrowDown
        ? 1
        : tus == LogicalKeyboardKey.arrowUp
            ? -1
            : 0;
    final esc = tus == LogicalKeyboardKey.escape;

    // Tuş tekrarı (basılı tutma) hiçbir eylemi yinelemez: çift gönderim olmaz.
    if (event is KeyRepeatEvent) {
      return (sira != null || enter || esc)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }

    if (esc) {
      if (!kIsWeb) return KeyEventResult.ignored;
      _cikisIste();
      return KeyEventResult.handled;
    }

    if (_result != null) {
      // Cevap sonrası: Enter -> Devam/Bitir (ilk 400 ms yok sayılır).
      if (!enter) return KeyEventResult.ignored;
      if (!_enterHazir) {
        return KeyEventResult.handled;
      }
      // Tab ile başka bir düğmeye (ör. "Benzer Soru Çöz") gidildiyse o düğme çalışsın.
      if (FocusManager.instance.primaryFocus != node) {
        return KeyEventResult.ignored;
      }
      _next();
      return KeyEventResult.handled;
    }

    // Cevap bekleniyor.
    if (_submitting) {
      return (sira != null || yon != 0)
          ? KeyEventResult.handled
          : KeyEventResult.ignored;
    }
    if (sira != null) {
      final anahtarlar = _question.options.keys.toList();
      if (sira >= anahtarlar.length) return KeyEventResult.ignored;
      _submit(anahtarlar[sira]);
      return KeyEventResult.handled;
    }
    if (yon != 0) {
      _sikOdagiGezdir(yon);
      return KeyEventResult.handled;
    }
    // Enter/Space: odakta şık varsa varsayılan Activate eylemi gönderir.
    return KeyEventResult.ignored;
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
    final total = _queue.length;
    final result = _result;
    final locked = _submitting || result != null;

    final mood = switch (result) {
      null => (_remaining > 0 && _remaining <= 5)
          ? HupoMood.hurry
          : HupoMood.question,
      AnswerResult(correct: true) => HupoMood.correct,
      _ => HupoMood.wrong,
    };

    final genis = isWide(context);
    final masaustu = isDesktop(context);
    final yukseklik = MediaQuery.sizeOf(context).height;
    // Alttan açılan pencere şıkları örtmesin diye boşluk. Geniş/yüksek ekranda
    // (>= 600) yüksekliğin %45'i aşırı büyür; 360 ile sınırlanır. Telefon aynı.
    final sonucBoslugu =
        genis ? math.min(yukseklik * 0.45, 360.0) : yukseklik * 0.45;
    var sikSirasi = 0;

    // Web'de tarayıcı/sistem geri tuşu da çıkış onayını açar; native'de değişmez.
    return PopScope(
      canPop: !kIsWeb,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cikisIste();
      },
      child: Scaffold(
        body: Focus(
          focusNode: _klavyeOdagi,
          autofocus: true,
          onKeyEvent: _tusuIsle,
          child: Stack(
            children: [
              SafeArea(
                // İçerik tek sütun, ortalı ve en fazla [kQuizMaxWidth] (telefonda etkisiz).
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: kQuizMaxWidth),
                    // Yatay 10 + 6: odak halkası (5 px taşma) liste kenarında kırpılmasın;
                    // toplam boşluk eski 16 ile aynı.
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: QuizTopBar(
                              title: widget.title,
                              questionLabel: 'Soru ${_index + 1}/$total',
                              progress:
                                  (_index + (result != null ? 1 : 0)) / total,
                              sessionXp: _sessionXp,
                              remainingSeconds: _remaining,
                              onClose: _cikisIste,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.only(
                                left: 6,
                                right: 6,
                                bottom: result == null ? 16 : sonucBoslugu,
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
                                          borderRadius:
                                              BorderRadius.circular(14),
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
                                    BookmarkButton(
                                        questionId: question.id, size: 20),
                                    ReportQuestionButton(
                                        questionId: question.id),
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
                                      style: appText(
                                          size: masaustu ? 24 : 21,
                                          weight: FontWeight.w800,
                                          height: 1.3),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                for (final entry in question.options.entries)
                                  AnswerOption(
                                    key:
                                        ValueKey('${question.id}-${entry.key}'),
                                    label: entry.key,
                                    text: entry.value,
                                    state: _optionState(entry.key),
                                    focusNode: _sikOdagi(sikSirasi++),
                                    onTap: locked
                                        ? null
                                        : () => _submit(entry.key),
                                  ),
                                // Klavye ipucu: web masaüstünde; tablette ilk klavye olayından sonra.
                                if (kIsWeb && (masaustu || (genis && _klavyeKullanildi)))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      _klavyeIpucu,
                                      textAlign: TextAlign.center,
                                      style: appText(
                                          size: 13, color: AppColors.muted),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    onRecover: result.correct
                        ? null
                        : _benzerSoruIndex(question.konu) == null
                            ? null
                            : () {
                                final hedef = _benzerSoruIndex(question.konu)!;
                                final soru = _queue.removeAt(hedef);
                                _queue.insert(_index + 1, soru);
                                _pendingKurtarmaOf = question.id;
                                _next();
                              },
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
        ),
      ),
    );
  }
}
