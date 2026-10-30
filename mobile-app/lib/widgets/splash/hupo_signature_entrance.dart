// HUPO SIGNATURE ENTRANCE — kanat imzası.
//
// Dört sahne tek bir AnimationController zaman çizelgesinde:
//
//   Sahne 1 (0–300 ms)    FIRST SPARK     → zemin + bokeh partiküller
//   Sahne 2 (300–750 ms)  HUPO AWAKENS    → Hupo yumuşak girişle canlanır
//   Sahne 3 (750–1150 ms) WING SIGNATURE  → hilal altın yay + 3 kıvılcım
//   Sahne 4 (1150–1600 ms) READY          → altın halka Hupo etrafında oluşur
//
// Karakter tek katman (hero_splash.webp); ayrı göz/kanat katmanı yok.
// Kanat açılışı: ölçek/pozisyon hareketiyle taklit edilir.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/app_open_service.dart';
import '../../theme/app_theme.dart';
import 'wing_signature_painter.dart';

const String kHupoEntranceAsset = 'assets/hupo/uygulama/hero_splash.webp';

const Duration kSignatureEntranceDuration = Duration(milliseconds: 2000);

/// Sistem (native) splash'indeki Hupo'nun en uzun kenarı (dp).
///
/// Android 12+ ikonu ve iOS launch görseli bu ölçüyle üretilir
/// (`tool/splash_varliklari_uret.py`); sahne ilk karede Hupo'yu aynı boyutta ve
/// ekran ortasında çizer, böylece sistemden uygulamaya geçişte sıçrama olmaz.
const double kNativeSplashHupoBoyu = 144;

class _Faz {
  static const sparkBit   = 300 / 1600;  // 0.1875
  static const uyanmaBit  = 750 / 1600;  // 0.46875
  static const imzaBit    = 1150 / 1600; // 0.71875
  static const yerlesmeBit = 0.85;       // marka adı/halka tamamlanır
  static const cikisBas    = 0.90;       // ön plan solmaya başlar (perde)
}

/// Marka açılış sahnesi.
class HupoSignatureEntrance extends StatefulWidget {
  const HupoSignatureEntrance({
    super.key,
    required this.onFinished,
    this.assetPath = kHupoEntranceAsset,
    this.reducedMotion = false,
    this.lowPerformance = false,
    this.kisa = false,
  });

  final VoidCallback onFinished;
  final String assetPath;
  final bool reducedMotion;
  final bool lowPerformance;

  /// Sonraki açılışlar için kısa sahne: aynı akış daha hızlı, marka adı yok.
  final bool kisa;

  @override
  State<HupoSignatureEntrance> createState() => _HupoSignatureEntranceState();
}

class _HupoSignatureEntranceState extends State<HupoSignatureEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _bildirildi = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.reducedMotion
          ? kHupoStatikKare
          : (widget.kisa ? kHupoKisaSahne : kSignatureEntranceDuration),
    );
    _controller.addStatusListener(_durumDinle);
    _controller.forward();
  }

  void _durumDinle(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_bildirildi) {
      _bildirildi = true;
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_durumDinle);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sahne Scaffold/Material dışında çizilir: Material olmadan Text, Flutter'ın
    // "eksik Material" stilini (tek aralıklı font + çift alt çizgi) alır.
    // Saydam Material doğru DefaultTextStyle'ı sağlar.
    return Material(
      type: MaterialType.transparency,
      child: _sahne(context),
    );
  }

  Widget _sahne(BuildContext context) {
    if (widget.reducedMotion) {
      return _StatikMarkaKaresi(assetPath: widget.assetPath);
    }

    if (widget.kisa) {
      final genislikK = MediaQuery.sizeOf(context).width;
      final tabanK = math.min(genislikK * 0.62, 360.0);
      return _KisaGirisSahnesi(
        animation: _controller,
        assetPath: widget.assetPath,
        tabanBoy: tabanK,
        baslangicOlcek: kNativeSplashHupoBoyu / tabanK,
      );
    }

    final izGorunur = !widget.lowPerformance;
    final genislik = MediaQuery.sizeOf(context).width;
    final tabanBoy = math.min(genislik * 0.62, 360.0);
    // İlk karede Hupo, sistem splash'indeki ölçüde başlar.
    final baslangicOlcek = kNativeSplashHupoBoyu / tabanBoy;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        // Sahne 1
        final zeminT = Curves.easeOut.transform(
          (t / _Faz.sparkBit).clamp(0.0, 1.0),
        );

        // Sahne 2
        final uyanmaHam = ((t - _Faz.sparkBit) /
                (_Faz.uyanmaBit - _Faz.sparkBit))
            .clamp(0.0, 1.0);
        final uyanmaT = Curves.easeOutCubic.transform(uyanmaHam);

        // Sahne 3
        final imzaHam =
            ((t - _Faz.uyanmaBit) / (_Faz.imzaBit - _Faz.uyanmaBit))
                .clamp(0.0, 1.0);

        // Sahne 4
        // Yerleşme %85'te biter; %85–90 marka adı tam görünür kalır (okunsun).
        final yerlesmeHam = ((t - _Faz.imzaBit) / (_Faz.yerlesmeBit - _Faz.imzaBit))
            .clamp(0.0, 1.0);
        final yerlesmeT = Curves.easeOut.transform(yerlesmeHam);

        // Çıkış: yalnız ön plan (Hupo, iz, ad) son %8'de kaybolur; geriye düz
        // zemin kalır ve SplashGate onu perde gibi açar. Böylece altındaki içerik
        // büyük Hupo'nun hayaletiyle üst üste görünmez.
        final cikisT = ((t - _Faz.cikisBas) / (1 - _Faz.cikisBas)).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            // ── Zemin: ilk karede sistem splash'iyle aynı düz turkuaz ────────
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    Color.lerp(
                        AppColors.primary, AppColors.primaryLight, zeminT)!,
                  ],
                ),
              ),
            ),

            Opacity(
              opacity: 1 - cikisT,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Sahne 1: Bokeh partiküller (sağ üst köşe atmosferi) ────
                  if (izGorunur && zeminT > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _BokehPainter(progress: zeminT),
                        ),
                      ),
                    ),

                  // ── Hupo + altın halka: ilk kareden itibaren görünür ──────
                  Align(
                    alignment: Alignment(
                      0,
                      0.28 * uyanmaT - 0.06 * yerlesmeT,
                    ),
                    child: _HupoGovdesi(
                      uyanmaT: uyanmaT,
                      imzaHam: imzaHam,
                      yerlesmeT: yerlesmeT,
                      baslangicOlcek: baslangicOlcek,
                      assetPath: widget.assetPath,
                      dalgaGoster: izGorunur,
                    ),
                  ),

                  // ── Sahne 3: Hilal yay + kıvılcımlar ──────────────────────
                  if (izGorunur && t >= _Faz.uyanmaBit)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: WingSignaturePainter(
                            progress: imzaHam,
                            wingOrigin: const Alignment(0.62, 0.42),
                          ),
                        ),
                      ),
                    ),

                  // ── Sahne 4: Marka adı (kısa sahnede yok) ─────────────────
                  if (!widget.kisa && yerlesmeHam > 0)
                    Align(
                      alignment: const Alignment(0, 0.78),
                      child: Opacity(
                        opacity: yerlesmeT,
                        child: Text(
                          'Hupolingo',
                          style: appText(
                            size: 34,
                            weight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Kısa Giriş Sahnesi (her açılış, 900 ms) ──────────────────────────────────
//
// İlk kare sistem splash'indeki Hupo ile aynıdır (aynı boy, ortada); sonra Hupo
// yerinde büyür, bir kez göz kırpar ve gözlerinin etrafında altın bir yay tamamlanır.
// Yazı ve ses yoktur; film ile aynı renk ve göz yaması (hupo_goz_kapali) kullanılır.

const String _kGozKapaliAsset = 'assets/hupo/uygulama/hupo_goz_kapali.webp';

class _KisaGirisSahnesi extends StatelessWidget {
  const _KisaGirisSahnesi({
    required this.animation,
    required this.assetPath,
    required this.tabanBoy,
    required this.baslangicOlcek,
  });

  final Animation<double> animation;
  final String assetPath;
  final double tabanBoy;
  final double baslangicOlcek;

  @override
  Widget build(BuildContext context) {
    // Hupo tuvali 845x900; göz yaması (165,121) konumunda, 416x320 boyutunda.
    final genislik = tabanBoy * 845 / 900;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final ms = animation.value * kHupoKisaSahne.inMilliseconds;
        final olcek = baslangicOlcek +
            (1 - baslangicOlcek) *
                Curves.easeOutCubic.transform((ms / 520).clamp(0.0, 1.0));
        final kirpiyor = ms >= 170 && ms < 250;
        final parlama = Curves.easeOut.transform(((ms - 250) / 450).clamp(0.0, 1.0));
        final yay = ((ms - 300) / 520).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.primary),
            // Hupo'nun arkasında yumuşak sıcak hale (film ile aynı mantık)
            Opacity(
              opacity: 0.30 * parlama,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [AppColors.sunSoft, Color(0x00FEF3CC)],
                  ),
                ),
              ),
            ),
            Center(
              child: Transform.scale(
                scale: olcek,
                child: SizedBox(
                  width: genislik,
                  height: tabanBoy,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.fill,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                      // Göz kırpma: yama yalnız kırpma anında görünür (önceden çözülür)
                      Positioned(
                        left: genislik * 165 / 845,
                        top: tabanBoy * 121 / 900,
                        width: genislik * 416 / 845,
                        height: tabanBoy * 320 / 900,
                        child: Opacity(
                          opacity: kirpiyor ? 1 : 0,
                          child: Image.asset(
                            _kGozKapaliAsset,
                            fit: BoxFit.fill,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Altın yay: Hupo'nun etrafında sol üstten sağa tamamlanır
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _KisaAltinYayPainter(
                    ilerleme: yay.toDouble(),
                    yaricap: tabanBoy * 0.62,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KisaAltinYayPainter extends CustomPainter {
  const _KisaAltinYayPainter({required this.ilerleme, required this.yaricap});

  final double ilerleme;
  final double yaricap;

  @override
  void paint(Canvas canvas, Size size) {
    if (ilerleme <= 0) return;
    final merkez = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: merkez, radius: yaricap);
    const baslangic = -math.pi * 0.80;
    final aci = math.pi * 1.05 * Curves.easeInOutCubic.transform(ilerleme);

    canvas.drawArc(
      rect,
      baslangic,
      aci,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..color = AppColors.sun.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawArc(
      rect,
      baslangic,
      aci,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = AppColors.sun,
    );
    canvas.drawArc(
      rect,
      baslangic,
      aci,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.9),
    );

    final ucAci = baslangic + aci;
    canvas.drawCircle(
      Offset(merkez.dx + yaricap * math.cos(ucAci), merkez.dy + yaricap * math.sin(ucAci)),
      6,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _KisaAltinYayPainter old) =>
      old.ilerleme != ilerleme || old.yaricap != yaricap;
}

// ── Hupo Gövdesi ──────────────────────────────────────────────────────────────

class _HupoGovdesi extends StatelessWidget {
  const _HupoGovdesi({
    required this.uyanmaT,
    required this.imzaHam,
    required this.yerlesmeT,
    required this.baslangicOlcek,
    required this.assetPath,
    required this.dalgaGoster,
  });

  final double uyanmaT;
  final double imzaHam;
  final double yerlesmeT;

  /// İlk karedeki ölçek: sistem splash'indeki Hupo boyuna eşit.
  final double baslangicOlcek;
  final String assetPath;
  final bool dalgaGoster;

  @override
  Widget build(BuildContext context) {
    final genislik   = MediaQuery.sizeOf(context).width;
    final tabanBoy   = math.min(genislik * 0.62, 360.0);
    final ringBoy    = tabanBoy * 1.28;

    final nefes     = dalgaGoster ? math.sin(imzaHam * math.pi) : 0.0;
    final olcek     = baslangicOlcek + (1 - baslangicOlcek) * uyanmaT +
        0.02 * nefes + 0.01 * yerlesmeT;

    // Merkezden ölçeklenir: ilk karede Hupo ekran ortasında, native ikonla aynı yerde.
    return Transform.scale(
      scale: olcek,
      child: SizedBox(
        width: ringBoy,
        height: ringBoy,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Altın halka — Sahne 4'te kanat izinden oluşur
            if (yerlesmeT > 0)
              SizedBox.expand(
                child: CustomPaint(
                  painter: _GoldenRingPainter(progress: yerlesmeT),
                ),
              ),

            // Karakter görseli (native splash gibi ortalı)
            SizedBox(
              width: tabanBoy,
              height: tabanBoy,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Statik Marka Karesi (hareket azalt) ──────────────────────────────────────

class _StatikMarkaKaresi extends StatelessWidget {
  const _StatikMarkaKaresi({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hupolingo',
              style: appText(
                  size: 30, weight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bokeh Painter (Sahne 1 atmosferi) ────────────────────────────────────────

/// Sağ-üst köşede beliren altın/krem bokeh partikülleri.
/// Pozisyonlar deterministik (sin/cos tabanlı) — her karede aynı, titreme yok.
class _BokehPainter extends CustomPainter {
  const _BokehPainter({required this.progress});

  final double progress;

  // [xFrac, yFrac, sizeFrac, alpha] — sağ üst bölgede yoğunlaşır
  static const _particles = [
    [0.71, 0.03, 0.030, 0.50],
    [0.84, 0.06, 0.018, 0.38],
    [0.92, 0.02, 0.036, 0.28],
    [0.78, 0.14, 0.022, 0.48],
    [0.96, 0.11, 0.013, 0.42],
    [0.88, 0.21, 0.028, 0.22],
    [0.63, 0.07, 0.016, 0.34],
    [0.99, 0.05, 0.021, 0.38],
    [0.74, 0.26, 0.012, 0.28],
    [0.86, 0.31, 0.010, 0.18],
    [0.93, 0.27, 0.024, 0.23],
    [0.68, 0.17, 0.014, 0.44],
    [0.81, 0.38, 0.009, 0.15],
    [0.97, 0.19, 0.017, 0.32],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final fade = Curves.easeOut.transform(progress.clamp(0.0, 1.0));

    for (final d in _particles) {
      final cx = d[0] * size.width;
      final cy = d[1] * size.height;
      final r  = d[2] * size.shortestSide;
      final a  = (d[3] * fade).clamp(0.0, 1.0);

      // Dış hale
      canvas.drawCircle(
        Offset(cx, cy),
        r * 2.4,
        Paint()..color = AppColors.sunSoft.withValues(alpha: a * 0.22),
      );
      // Çekirdek
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()..color = Colors.white.withValues(alpha: a * 0.72),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BokehPainter old) => old.progress != progress;
}

// ── Golden Ring Painter (Sahne 4 altın halka) ─────────────────────────────────

/// Hupo etrafında saat yönünün tersinde süpürülerek oluşan altın halka.
class _GoldenRingPainter extends CustomPainter {
  const _GoldenRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final cx     = size.width / 2;
    final cy     = size.height * 0.50;
    final radius = size.shortestSide * 0.44;
    final rect   = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    final eased  = Curves.easeOut.transform(progress);
    final sweep  = -math.pi * 2 * eased; // saat tersine süpürme

    // Dış glow (blurlu)
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap  = StrokeCap.round
        ..color      = AppColors.sun.withValues(alpha: 0.20 * eased)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );

    // Orta halka
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap  = StrokeCap.round
        ..color      = AppColors.sun.withValues(alpha: 0.60 * eased),
    );

    // Parlak çekirdek çizgi
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap  = StrokeCap.round
        ..color      = Colors.white.withValues(alpha: 0.80 * eased),
    );
  }

  @override
  bool shouldRepaint(covariant _GoldenRingPainter old) =>
      old.progress != progress;
}
