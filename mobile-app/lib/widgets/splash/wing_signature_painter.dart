// Kanat İmzası: Hupo'nun kanadından çıkan altın ışık izi ve kıvılcımlar.
//
// Bu dosya yalnızca çizime odaklanır (CustomPainter). Zamanlama ve animasyon
// kontrolü `hupo_signature_entrance.dart` içindedir. Böylece çizim yeniden
// kullanılabilir ve testte tek kare sabit ilerlemeyle doğrulanabilir.
//
// Tasarım ilkeleri:
//  * Aşırı partikül yok (en fazla 3 kıvılcım + tek ışık izi).
//  * Tam ekran beyaz parlama yok; iz yumuşak ve ince.
//  * Gözü rahatsız eden flaş yok; opaklık 0.55'i geçmez.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Sahne ilerlemesine (0→1) göre ışık izini ve kıvılcımları çizer.
///
/// [progress] 0 = sahne başlangıcı, 1 = sahne sonu. Sahne 3 (Wing Signature)
/// için tasarlanmıştır; sahne dışında etkisizdir.
class WingSignaturePainter extends CustomPainter {
  const WingSignaturePainter({
    required this.progress,
    required this.wingOrigin,
    this.enabled = true,
  });

  /// 0→1 arası sahne ilerlemesi.
  final double progress;

  /// Kanadın ekran içindeki başlangıç noktası (üst-sol oranla: 0→1).
  final Alignment wingOrigin;

  /// false ise hiçbir şey çizilmez (hareket azalt / düşük performans).
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled || progress <= 0) return;

    final origin = Offset(
      wingOrigin.x * size.width,
      wingOrigin.y * size.height,
    );
    final target = Offset(size.width * 0.62, size.height * 0.38);

    // İz yalnızca sahnenin ilk %70'inde görünür; sonra yumuşakça kaybolur.
    final trailT =
        Curves.easeOutCubic.transform(progress.clamp(0.0, 0.7) / 0.7);
    final fade =
        progress < 0.7 ? 1.0 : (1.0 - (progress - 0.7) / 0.3).clamp(0.0, 1.0);

    _drawTrail(canvas, size, origin, target, trailT, fade);
    _drawSparks(canvas, size, origin, trailT, fade);
  }

  void _drawTrail(
    Canvas canvas,
    Size size,
    Offset origin,
    Offset target,
    double t,
    double fade,
  ) {
    if (t <= 0) return;

    // İz, Hupo'nun kanadından hedefe doğru uzayan bir yaydır.
    final kontrol = Offset(
      origin.dx + (target.dx - origin.dx) * 0.15,
      origin.dy + (target.dy - origin.dy) * 0.75,
    );
    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(kontrol.dx, kontrol.dy, target.dx, target.dy);

    // İzin yalnızca t kadarı çizili: ucun ilerlemesini kırp.
    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * t);

    // Geniş, düşük opaklıkta taban parıltısı + ince altın çekirdek.
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.width * 0.02
        ..color = AppColors.sun.withValues(alpha: 0.16 * fade),
    );
    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size.shortestSide * 0.008
        ..shader = ui.Gradient.linear(
          origin,
          target,
          [
            AppColors.sun.withValues(alpha: 0.0),
            AppColors.sun.withValues(alpha: 0.55 * fade),
            AppColors.sunSoft.withValues(alpha: 0.75 * fade),
          ],
          const [0.0, 0.6, 1.0],
        ),
    );

    // İz ucunda küçük, yumuşak bir parıltı (flaş değil).
    final uc = metric.getTangentForOffset(metric.length * t)?.position;
    if (uc != null) {
      canvas.drawCircle(
        uc,
        size.shortestSide * 0.02,
        Paint()
          ..shader = ui.Gradient.radial(
            uc,
            size.shortestSide * 0.02,
            [
              AppColors.sunSoft.withValues(alpha: 0.5 * fade),
              AppColors.sun.withValues(alpha: 0.0),
            ],
          ),
      );
    }
  }

  void _drawSparks(
    Canvas canvas,
    Size size,
    Offset origin,
    double t,
    double fade,
  ) {
    if (t <= 0) return;

    const adet = 3; // Aşırı partikül yok.
    for (var i = 0; i < adet; i++) {
      // Her kıvılcım farklı açı ve gecikmeyle çıkar.
      final gecikme = i * 0.12;
      final yerelT = ((t - gecikme) / (1 - gecikme)).clamp(0.0, 1.0);
      if (yerelT <= 0) continue;

      final egri = Curves.easeOut.transform(yerelT);
      final aci = (-0.9 + i * 0.35) + math.sin(yerelT * math.pi * 2) * 0.08;
      final mesafe = size.shortestSide * (0.10 + i * 0.03) * egri;

      final konum = Offset(
        origin.dx + math.cos(aci) * mesafe,
        origin.dy + math.sin(aci) * mesafe,
      );

      final boyut = size.shortestSide * 0.008 * (1 - yerelT * 0.4);
      canvas.drawCircle(
        konum,
        boyut,
        Paint()..color = AppColors.sunSoft.withValues(alpha: 0.8 * fade),
      );
      canvas.drawCircle(
        konum,
        boyut * 2.4,
        Paint()..color = AppColors.sun.withValues(alpha: 0.18 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WingSignaturePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.wingOrigin != wingOrigin ||
      oldDelegate.enabled != enabled;
}
