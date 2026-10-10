// HUPO SIGNATURE ENTRANCE — kanat imzası.
//
// Uygulama açılışında Hupo'yu tanıtan ve ana sayfaya kesintisiz bağlanan
// marka sahnesi. Dört sahne tek bir AnimationController zaman çizelgesinde
// birleşir:
//
//   Sahne 1 (0–300 ms)    FIRST SPARK     → zemin belirir (Hupo henüz yok)
//   Sahne 2 (300–750 ms)  HUPO AWAKENS    → Hupo yumuşak girişle canlanır
//   Sahne 3 (750–1150 ms) WING SIGNATURE → altın ışık izi + 3 kıvılcım
//   Sahne 4 (1150–1600 ms) READY TO EXC. → Hupo nihai konuma yerleşir, çocuk
//                                          görünür olur ve sahne içeriğe bırakır
//
// Önemli: Karakter tek bir görseldir (`hero_splash.webp`); ayrı göz/kanat
// katmanı asseti YOKTUR. Bu yüzden göz kırpma ve kanat açılışı, gövdenin
// yumuşak ölçek/pozisyon hareketiyle TAKLİT edilir; katman varmış gibi
// gösterilmez. Gerçek katmanlar için bkz. docs/splash/BAKIM.md.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'wing_signature_painter.dart';

/// Sahne karakter asseti (tek katman — gövde).
const String kHupoEntranceAsset = 'assets/hupo/uygulama/hero_splash.webp';

/// Tam sahnenin toplam süresi (Sahne 1–4).
const Duration kSignatureEntranceDuration = Duration(milliseconds: 1600);

/// Sahne zaman sınırları (0→1 aralığında).
class _Faz {
  static const sparkBit = 300 / 1600; // 0.1875
  static const uyanmaBit = 750 / 1600; // 0.46875
  static const imzaBit = 1150 / 1600; // 0.71875
}

/// Açılışta sahnenin ulaştığı durum; ana sayfaya geçiş sinyali üretir.
enum EntrancePhase { playing, finished }

/// Marka açılış sahnesi. Kendi controller'ını kurar ve bitince [onFinished]
/// çağırır. Üstteki `SplashGate` bu sinyalle sahneyi kaldırır.
class HupoSignatureEntrance extends StatefulWidget {
  const HupoSignatureEntrance({
    super.key,
    required this.onFinished,
    this.assetPath = kHupoEntranceAsset,
    this.reducedMotion = false,
    this.lowPerformance = false,
  });

  /// Sahne tamamlandığında çağrılır (bir kez).
  final VoidCallback onFinished;

  /// Karakter görseli. Testte değiştirilebilir.
  final String assetPath;

  /// Hareket azalt: animasyon yerine kısa statik marka karesi.
  final bool reducedMotion;

  /// Düşük donanım: ışık izi ve kıvılcımlar kaldırılır, yalnızca geçiş kalır.
  final bool lowPerformance;

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
          ? const Duration(milliseconds: 500)
          : kSignatureEntranceDuration,
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
    // Hareket azalt: animasyon yerine statik marka karesi (kısa tutulur).
    if (widget.reducedMotion) {
      return _StatikMarkaKaresi(assetPath: widget.assetPath);
    }

    final izGorunur = !widget.lowPerformance;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        // ── Sahne 1: FIRST SPARK — zemin yumuşakça belirir ──────────────────
        final zeminT = Curves.easeOut.transform(
          (t / _Faz.sparkBit).clamp(0.0, 1.0),
        );

        // ── Sahne 2: HUPO AWAKENS — Hupo alttan yükselir, hafif büyür ───────
        final uyanmaHam = ((t - _Faz.sparkBit) /
                (_Faz.uyanmaBit - _Faz.sparkBit))
            .clamp(0.0, 1.0);
        final uyanmaT = Curves.easeOutCubic.transform(uyanmaHam);

        // ── Sahne 3: WING SIGNATURE — ışık izi çizilir ──────────────────────
        final imzaHam =
            ((t - _Faz.uyanmaBit) / (_Faz.imzaBit - _Faz.uyanmaBit))
                .clamp(0.0, 1.0);

        // ── Sahne 4: READY TO EXPLORE — nihai konuma yerleşir ───────────────
        final yerlesmeHam = ((t - _Faz.imzaBit) / (1 - _Faz.imzaBit))
            .clamp(0.0, 1.0);
        final yerlesmeT = Curves.easeOut.transform(yerlesmeHam);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Sahne 1 — marka turkuazı zemin, yumuşak dikey geçiş.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(AppColors.primaryDark, AppColors.primary, zeminT)!,
                    Color.lerp(AppColors.primary, AppColors.primaryLight, zeminT)!,
                  ],
                ),
              ),
            ),

            // Sahne 2/4 — Hupo. Üstte duran dalga efekti (kanat açılışı taklidi)
            // gövdenin hafif supurmasıyla birleşir.
            if (uyanmaHam > 0)
              Align(
                alignment: Alignment(0, 0.28 - 0.06 * yerlesmeT),
                child: _HupoGovdesi(
                  uyanmaT: uyanmaT,
                  imzaHam: imzaHam,
                  yerlesmeT: yerlesmeT,
                  assetPath: widget.assetPath,
                  dalgaGoster: izGorunur,
                ),
              ),

            // Sahne 3 — kanattan çıkan altın iz ve kıvılcımlar.
            if (izGorunur && t >= _Faz.uyanmaBit)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: WingSignaturePainter(
                      progress: imzaHam,
                      wingOrigin: const Alignment(0.18, 0.30),
                    ),
                  ),
                ),
              ),

            // Sahne 4 — marka adı sahnenin sonunda belirir.
            if (yerlesmeHam > 0)
              Align(
                alignment: const Alignment(0, 0.72),
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
        );
      },
    );
  }
}

/// Hupo gövdesi: yükselme, hafif büyüme ve yerleşme hareketlerini uygular.
///
/// Kanat açılışı, gövdenin hafif yatay supurması ve döngüsel sönümle taklit
/// edilir; ayrı kanat katmanı olmadığı için bu dürüst geçici çözümdür.
class _HupoGovdesi extends StatelessWidget {
  const _HupoGovdesi({
    required this.uyanmaT,
    required this.imzaHam,
    required this.yerlesmeT,
    required this.assetPath,
    required this.dalgaGoster,
  });

  final double uyanmaT;
  final double imzaHam;
  final double yerlesmeT;
  final String assetPath;
  final bool dalgaGoster;

  @override
  Widget build(BuildContext context) {
    final genislik = MediaQuery.sizeOf(context).width;
    final tabanBoy = math.min(genislik * 0.62, 360.0);

    // Sahne 2: alttan yükselme + gözle görülür canlanma (kanat açılışı hissi).
    final yukseklik = -30 * uyanmaT;

    // Sahne 3: imza anında karakter hafifçe "nefes alır".
    final nefes = dalgaGoster ? math.sin(imzaHam * math.pi) : 0.0;

    // Sahne 4: nihai konumda hafif büyüme tamamlanır.
    final olcek = 0.92 + 0.08 * uyanmaT + 0.02 * nefes + 0.01 * yerlesmeT;

    return Transform.translate(
      offset: Offset(0, yukseklik),
      child: Transform.scale(
        scale: olcek,
        alignment: Alignment.bottomCenter,
        child: Opacity(
          opacity: uyanmaT.clamp(0.0, 1.0),
          child: SizedBox(
            width: tabanBoy,
            height: tabanBoy,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hareket azalt için statik marka karesi (animasyon yok).
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
              style: appText(size: 30, weight: FontWeight.w900, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
