// Kanat İmzası: Hilal şeklinde altın ışık yayı (Scene 3) ve kanat kıvılcımları.
//
// v2 değişiklikleri:
//  * Düz bezier yerine ekranı büyük yay ile kesen hilal ark (alt-sol → üst-sağ).
//  * maskFilter blur ile gerçek ışıma (glow) efekti.
//  * Üç glow katmanı: geniş dış hale → orta → parlak çekirdek.
//  * Kıvılcımlar wingOrigin'den ayrı tutulur (karakter yakını).

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Sahne ilerlemesine (0→1) göre hilal yayı ve kanat kıvılcımlarını çizer.
class WingSignaturePainter extends CustomPainter {
  const WingSignaturePainter({
    required this.progress,
    required this.wingOrigin,
    this.enabled = true,
  });

  final double progress;

  /// Kanat kıvılcımları için ekran oranı (Alignment.x * W, Alignment.y * H).
  final Alignment wingOrigin;

  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled || progress <= 0) return;

    // İz: progress 0-70% arasında uzar, 70-100% arasında solar.
    final trailT =
        Curves.easeOutCubic.transform(progress.clamp(0.0, 0.82) / 0.82);
    final fade = progress < 0.70
        ? 1.0
        : (1.0 - (progress - 0.70) / 0.30).clamp(0.0, 1.0);

    _drawCrescentArc(canvas, size, trailT, fade);
    _drawSparks(canvas, size, trailT, fade);
  }

  // ── Hilal Yayı ──────────────────────────────────────────────────────────────
  void _drawCrescentArc(
    Canvas canvas,
    Size size,
    double t,
    double fade,
  ) {
    if (t <= 0) return;

    // Quadratic bezier: alt-sol → sağ dışına çık → üst-sağ
    // Kontrol noktası ekran dışında (x > 1) → doğal hilal eğrisi.
    final arcStart = Offset(size.width * 0.10, size.height * 0.70);
    final arcEnd   = Offset(size.width * 0.88, size.height * 0.08);
    final ctrl     = Offset(size.width * 1.12, size.height * 0.38);

    final path = Path()
      ..moveTo(arcStart.dx, arcStart.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, arcEnd.dx, arcEnd.dy);

    final metric = path.computeMetrics().first;
    final drawn  = metric.extractPath(0, metric.length * t);

    // Katman 1 — dış hale (blurlu, geniş)
    canvas.drawPath(
      drawn,
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.065
        ..strokeCap  = StrokeCap.round
        ..color      = AppColors.sun.withValues(alpha: 0.10 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // Katman 2 — orta parıltı (hafif blurlu)
    canvas.drawPath(
      drawn,
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.020
        ..strokeCap  = StrokeCap.round
        ..color      = AppColors.sun.withValues(alpha: 0.42 * fade)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Katman 3 — parlak çekirdek (blur yok, keskin)
    canvas.drawPath(
      drawn,
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.004
        ..strokeCap  = StrokeCap.round
        ..color      = Colors.white.withValues(alpha: 0.78 * fade),
    );

    // Uç parıltısı (flaş değil — yumuşak radial)
    final tangent = metric.getTangentForOffset(metric.length * t);
    if (tangent != null) {
      final uc = tangent.position;
      final r  = size.shortestSide * 0.030;
      canvas.drawCircle(
        uc,
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            uc,
            r,
            [
              Colors.white.withValues(alpha: 0.75 * fade),
              AppColors.sun.withValues(alpha: 0.30 * fade),
              AppColors.sun.withValues(alpha: 0.0),
            ],
            const [0.0, 0.45, 1.0],
          ),
      );
    }
  }

  // ── Kanat Kıvılcımları ──────────────────────────────────────────────────────
  void _drawSparks(
    Canvas canvas,
    Size size,
    double t,
    double fade,
  ) {
    if (t <= 0) return;

    final ox = wingOrigin.x * size.width;
    final oy = wingOrigin.y * size.height;
    final origin = Offset(ox, oy);

    const adet = 3;
    for (var i = 0; i < adet; i++) {
      final gecikme = i * 0.12;
      final yerelT  = ((t - gecikme) / (1 - gecikme)).clamp(0.0, 1.0);
      if (yerelT <= 0) continue;

      final egri     = Curves.easeOut.transform(yerelT);
      final aci      = (-0.95 + i * 0.38) + math.sin(yerelT * math.pi * 2) * 0.07;
      final mesafe   = size.shortestSide * (0.09 + i * 0.035) * egri;
      final konum    = Offset(
        origin.dx + math.cos(aci) * mesafe,
        origin.dy + math.sin(aci) * mesafe,
      );
      final boyut = size.shortestSide * 0.009 * (1 - yerelT * 0.45);

      // Çekirdek
      canvas.drawCircle(
        konum,
        boyut,
        Paint()..color = AppColors.sunSoft.withValues(alpha: 0.85 * fade),
      );
      // Hale
      canvas.drawCircle(
        konum,
        boyut * 2.8,
        Paint()
          ..color      = AppColors.sun.withValues(alpha: 0.20 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WingSignaturePainter old) =>
      old.progress != progress ||
      old.wingOrigin != wingOrigin ||
      old.enabled != enabled;
}
