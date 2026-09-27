import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/motion.dart';
import '../hupo/hupo.dart';
import 'avatar_models.dart';

/// Evrimleşen avatar: HUPO, her evrede o evreye özel kıyafet ve aksesuarla büyür.
///
/// Hupo PNG'sinin (assets/hupo/ayakta.png) arkasına ve önüne vektör aksesuar katmanları
/// çizilir; aksesuarlar 900x900'lük bir tuvale göre konumlandırılır ve [size]'a ölçeklenir.
/// Animasyon yalnızca efsanevi evrede (alevli kanatlar) ve hareket azaltılmamışsa çalışır.
class EvolvingAvatarWidget extends StatefulWidget {
  const EvolvingAvatarWidget({
    super.key,
    required this.currentXP,
    this.size = 150,
    this.tier,
  });

  /// Toplam XP; [tier] verilmezse evre bundan hesaplanır.
  final int currentXP;

  /// Avatarın sığdığı karenin genişliği ve yüksekliği.
  final double size;

  /// Verilirse XP yerine bu evre çizilir (kutlama ve önizleme için).
  final AvatarTier? tier;

  @override
  State<EvolvingAvatarWidget> createState() => _EvolvingAvatarWidgetState();
}

class _EvolvingAvatarWidgetState extends State<EvolvingAvatarWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  AvatarTier get _tier =>
      widget.tier ?? AvatarEvolutionManager.getTierFromXP(widget.currentXP);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
  }

  void _syncAnimation() {
    final shouldRun = _tier == AvatarTier.efsanevi && !reducedMotion(context);
    if (shouldRun) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant EvolvingAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Karakterin arkasındaki yumuşak parlama (evre yükseldikçe güçlenir).
  Widget _aura(AvatarTier tier) {
    final strength = 0.30 + 0.07 * tier.index;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            tier.accentColor.withValues(alpha: strength + 0.1),
            tier.primaryColor.withValues(alpha: strength * 0.55),
            tier.primaryColor.withValues(alpha: 0),
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tier = _tier;
    final s = widget.size;
    final u = s / 900; // tuval birimi -> piksel
    return Semantics(
      label: '${tier.title} avatarı',
      image: true,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: SizedBox.square(
            dimension: s,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: _aura(tier)),
                Positioned.fill(
                  child: CustomPaint(painter: _GearPainter(tier, _controller, front: false)),
                ),
                Positioned(
                  left: 50 * u,
                  top: 100 * u,
                  width: 800 * u,
                  height: 800 * u,
                  child: const Hupo(pose: HupoPose.ayakta, size: 800),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _GearPainter(tier, _controller, front: true)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Renkler ve çizim yardımcıları (Hupo'nun lacivert dış çizgisiyle uyumlu)
// ---------------------------------------------------------------------------

const _ink = Color(0xFF0A2D4B);
const _leather = Color(0xFFA9703A);
const _leatherDark = Color(0xFF6B4530);
const _crimson = Color(0xFFD9342B);
const _crimsonDark = Color(0xFF9F1D1D);
const _gold = Color(0xFFFFC233);
const _goldDark = Color(0xFFD08A10);
const _goldLight = Color(0xFFFFE9A0);
const _steel = Color(0xFFB9C6D6);
const _navy = Color(0xFF16245A);
const _navyLight = Color(0xFF2C3F8C);
const _cyan = Color(0xFF19E3FF);
const _cyanLight = Color(0xFFB8FBFF);
const _flameRed = Color(0xFFE5391A);
const _flameOrange = Color(0xFFFF8A1F);
const _flameYellow = Color(0xFFFFD84A);
const _flameOutline = Color(0xFF8A2410);

Paint _fill(Color c) => Paint()..color = c;

Paint _stroke(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Dolgu (isteğe bağlı üstten alta renk geçişi) + koyu dış çizgi.
void _shape(
  Canvas c,
  Path p,
  Color fill, {
  Color? fill2,
  double w = 9,
  Color stroke = _ink,
}) {
  final paint = _fill(fill);
  if (fill2 != null) {
    final b = p.getBounds();
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [fill, fill2],
    ).createShader(b);
  }
  c
    ..drawPath(p, paint)
    ..drawPath(p, _stroke(stroke, w));
}

void _glowLine(Canvas c, Path p, Color color, {double width = 7, double blur = 9}) {
  c
    ..drawPath(
      p,
      _stroke(color.withValues(alpha: 0.85), width * 2.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    )
    ..drawPath(p, _stroke(color, width))
    ..drawPath(p, _stroke(Colors.white.withValues(alpha: 0.75), width * 0.35));
}

Path _poly(List<Offset> pts) {
  final p = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (final o in pts.skip(1)) {
    p.lineTo(o.dx, o.dy);
  }
  return p..close();
}

// ---------------------------------------------------------------------------
// Katman ressamı
// ---------------------------------------------------------------------------

class _GearPainter extends CustomPainter {
  _GearPainter(this.tier, this.anim, {required this.front}) : super(repaint: anim);

  final AvatarTier tier;
  final Animation<double> anim;
  final bool front;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 900, size.height / 900);
    final t = anim.value;
    if (front) {
      _paintFront(canvas, t);
    } else {
      _paintBack(canvas, t);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GearPainter old) => old.tier != tier || old.front != front;

  // ----- arka katman (Hupo'nun arkasında) -----

  void _paintBack(Canvas c, double t) {
    // Zemin gölgesi
    c.drawOval(
      Rect.fromCenter(center: const Offset(480, 846), width: 400, height: 46),
      _fill(Colors.black.withValues(alpha: 0.12)),
    );
    switch (tier) {
      case AvatarTier.bronz:
        break;
      case AvatarTier.gumus:
        _quiver(c);
        _bow(c, wood: true);
      case AvatarTier.altin:
        _banner(c);
        _cape(c);
      case AvatarTier.elmas:
        _holoPad(c);
        _borkTail(c);
        _bow(c, wood: false);
      case AvatarTier.efsanevi:
        _rays(c, t);
        _flameWings(c, t);
        _embers(c, t);
    }
  }

  // ----- ön katman (Hupo'nun önünde) -----

  void _paintFront(Canvas c, double t) {
    switch (tier) {
      case AvatarTier.bronz:
        _scarf(c, _crimson, _crimsonDark, tails: true);
      case AvatarTier.gumus:
        _scarf(c, const Color(0xFF2E9C8F), const Color(0xFF1B6E66), tails: true);
        _strap(c);
        _cap(c, base: _leather, rim: _leatherDark);
        _feather(c);
      case AvatarTier.altin:
        _scarf(c, _crimson, _crimsonDark, tails: false);
        _plate(c);
        _cap(c, base: _steel, rim: _goldDark, band: _gold);
        _plume(c);
      case AvatarTier.elmas:
        _neonCollar(c);
        _cyberPlate(c);
        _bork(c);
        _visor(c);
      case AvatarTier.efsanevi:
        _crest(c, t);
        _gorget(c);
    }
  }

  // ===== Çaylak Alp: atkı =====

  void _scarf(Canvas c, Color base, Color dark, {required bool tails}) {
    if (tails) {
      final a = Path()
        ..moveTo(548, 588)
        ..lineTo(606, 598)
        ..lineTo(594, 706)
        ..lineTo(572, 688)
        ..lineTo(548, 712)
        ..close();
      final b = Path()
        ..moveTo(600, 596)
        ..lineTo(652, 582)
        ..lineTo(672, 676)
        ..lineTo(648, 664)
        ..lineTo(626, 694)
        ..close();
      _shape(c, b, dark, fill2: base);
      _shape(c, a, base, fill2: dark);
      c
        ..drawLine(const Offset(552, 640), const Offset(598, 646), _stroke(Colors.white.withValues(alpha: 0.5), 6))
        ..drawLine(const Offset(640, 630), const Offset(662, 626), _stroke(Colors.white.withValues(alpha: 0.5), 6));
    }
    final band = Path()
      ..moveTo(366, 466)
      ..cubicTo(430, 522, 520, 552, 612, 552)
      ..cubicTo(652, 552, 684, 532, 704, 502)
      ..lineTo(710, 548)
      ..cubicTo(684, 588, 644, 604, 606, 604)
      ..cubicTo(508, 604, 420, 568, 370, 514)
      ..close();
    _shape(c, band, base, fill2: dark);
    c.drawPath(
        Path()
          ..moveTo(388, 500)
          ..cubicTo(450, 552, 540, 580, 640, 566),
        _stroke(Colors.white.withValues(alpha: 0.35), 7),
      );
    if (tails) {
      _shape(c, Path()..addOval(Rect.fromCenter(center: const Offset(604, 590), width: 62, height: 52)), base, fill2: dark);
    }
  }

  // ===== Genç Kemankeş: yay, ok kılıfı, şapka =====

  void _bow(Canvas c, {required bool wood}) {
    final arc = Path()
      ..moveTo(310, 290)
      ..cubicTo(70, 380, 70, 650, 280, 750);
    final string = Path()
      ..moveTo(310, 290)
      ..lineTo(280, 750);
    if (wood) {
      c
        ..drawPath(string, _stroke(_ink, 11))
        ..drawPath(string, _stroke(const Color(0xFFF6EBD0), 5))
        ..drawPath(arc, _stroke(_ink, 34))
        ..drawPath(arc, _stroke(_leather, 22))
        ..drawPath(
          arc.shift(const Offset(-4, -3)),
          _stroke(const Color(0xFFD9A066), 6),
        );
      // Tutamaç sargısı
      final grip = Path()
        ..moveTo(118, 500)
        ..lineTo(120, 560);
      c
        ..drawPath(grip, _stroke(_ink, 36))
        ..drawPath(grip, _stroke(_crimson, 24));
    } else {
      _glowLine(c, string, _cyan, width: 4, blur: 6);
      _glowLine(c, arc, _cyan, width: 11, blur: 10);
    }
  }

  void _quiver(Canvas c) {
    c
      ..save()
      ..translate(275, 600)
      ..rotate(0.42);
    // oklar
    for (final dx in [-14.0, 4.0, 22.0]) {
      final shaft = Path()
        ..moveTo(dx, -110)
        ..lineTo(dx + 2, -210);
      c
        ..drawPath(shaft, _stroke(_ink, 13))
        ..drawPath(shaft, _stroke(const Color(0xFFE9C58A), 6));
      final fletch = _poly([
        Offset(dx - 12, -200),
        Offset(dx + 2, -228),
        Offset(dx + 16, -200),
        Offset(dx + 2, -186),
      ]);
      _shape(c, fletch, _crimson, w: 6);
    }
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-34, -120, 68, 220),
      const Radius.circular(20),
    );
    final p = Path()..addRRect(body);
    _shape(c, p, _leather, fill2: _leatherDark);
    c
      ..drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-34, -120, 68, 26), const Radius.circular(12)),
        _fill(_leatherDark),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-34, -120, 68, 26), const Radius.circular(12)),
        _stroke(_ink, 7),
      )
      ..drawLine(const Offset(-14, -70), const Offset(-14, 80), _stroke(Colors.white.withValues(alpha: 0.3), 6))
      ..restore();
  }

  /// Sırtı ve göğsü çaprazlayan kayış.
  void _strap(Canvas c) {
    final p = Path()
      ..moveTo(372, 520)
      ..lineTo(400, 490)
      ..lineTo(640, 690)
      ..lineTo(608, 718)
      ..close();
    _shape(c, p, _leather, fill2: _leatherDark, w: 7);
    c.drawCircle(const Offset(520, 604), 15, _fill(_gold));
    c.drawCircle(const Offset(520, 604), 15, _stroke(_ink, 6));
  }

  void _cap(Canvas c, {required Color base, required Color rim, Color? band}) {
    final dome = Path()
      ..moveTo(398, 298)
      ..cubicTo(390, 222, 440, 190, 508, 190)
      ..cubicTo(592, 190, 642, 230, 648, 294)
      ..cubicTo(590, 268, 470, 268, 398, 298)
      ..close();
    _shape(c, dome, base, fill2: rim.withValues(alpha: 0.9));
    c.drawPath(
      Path()
        ..moveTo(430, 240)
        ..cubicTo(460, 212, 520, 206, 560, 214),
      _stroke(Colors.white.withValues(alpha: 0.45), 8),
    );
    final brim = Path()
      ..moveTo(394, 292)
      ..cubicTo(470, 262, 592, 262, 652, 288)
      ..lineTo(654, 318)
      ..cubicTo(592, 292, 470, 292, 392, 322)
      ..close();
    _shape(c, brim, band ?? rim, fill2: band == null ? _leatherDark : _goldDark);
  }

  void _feather(Canvas c) {
    final f = Path()
      ..moveTo(600, 222)
      ..cubicTo(636, 166, 690, 128, 742, 116)
      ..cubicTo(722, 164, 686, 222, 620, 252)
      ..close();
    _shape(c, f, _crimson, fill2: const Color(0xFFFF7A59), w: 7);
    c.drawPath(
      Path()
        ..moveTo(606, 236)
        ..cubicTo(650, 190, 700, 148, 736, 122),
      _stroke(const Color(0xFFFFE9C8), 5),
    );
  }

  // ===== Akıncı: pelerin, sancak, zırh, miğfer =====

  void _cape(Canvas c) {
    final p = Path()
      ..moveTo(430, 516)
      ..cubicTo(300, 526, 180, 620, 140, 800)
      ..lineTo(208, 772)
      ..lineTo(240, 826)
      ..lineTo(300, 778)
      ..lineTo(350, 830)
      ..lineTo(404, 764)
      ..cubicTo(384, 690, 402, 610, 480, 566)
      ..close();
    _shape(c, p, const Color(0xFFEF4B3C), fill2: _crimsonDark);
    c
      ..drawPath(
        Path()
          ..moveTo(150, 786)
          ..lineTo(208, 762)
          ..lineTo(240, 814)
          ..lineTo(300, 768)
          ..lineTo(350, 818)
          ..lineTo(398, 758),
        _stroke(_gold, 9),
      )
      ..drawPath(
        Path()
          ..moveTo(420, 540)
          ..cubicTo(300, 560, 220, 640, 190, 730),
        _stroke(Colors.white.withValues(alpha: 0.28), 8),
      );
  }

  void _banner(Canvas c) {
    // gönder
    final pole = RRect.fromRectAndRadius(const Rect.fromLTWH(838, 170, 16, 706), const Radius.circular(8));
    c
      ..drawRRect(pole, _fill(_leather))
      ..drawRRect(pole, _stroke(_ink, 7))
      ..drawCircle(const Offset(846, 150), 22, _fill(_gold))
      ..drawCircle(const Offset(846, 150), 22, _stroke(_ink, 7))
      ..drawCircle(const Offset(839, 143), 7, _fill(Colors.white.withValues(alpha: 0.6)));
    // bayrak
    final flag = Path()
      ..moveTo(842, 196)
      ..cubicTo(796, 184, 742, 226, 684, 204)
      ..lineTo(722, 290)
      ..lineTo(684, 376)
      ..cubicTo(742, 398, 796, 356, 842, 372)
      ..close();
    _shape(c, flag, const Color(0xFFEF4B3C), fill2: _crimsonDark);
    // altın kenar
    c.drawPath(
      Path()
        ..moveTo(834, 210)
        ..cubicTo(796, 200, 748, 236, 706, 220)
        ..moveTo(834, 360)
        ..cubicTo(796, 346, 748, 380, 706, 366),
      _stroke(_gold, 6),
    );
    // lale (tulip) motifi
    c.save();
    c.translate(776, 288);
    final petals = Path()
      ..moveTo(0, 42)
      ..cubicTo(-30, 34, -36, -16, -16, -36)
      ..lineTo(0, -12)
      ..lineTo(16, -36)
      ..cubicTo(36, -16, 30, 34, 0, 42)
      ..close();
    _shape(c, petals, _gold, fill2: _goldDark, w: 5);
    c
      ..drawPath(
        Path()
          ..moveTo(0, -12)
          ..lineTo(0, 34),
        _stroke(_goldDark, 4),
      )
      ..restore();
  }

  void _plate(Canvas c) {
    final p = Path()
      ..moveTo(420, 556)
      ..cubicTo(480, 596, 600, 610, 692, 552)
      ..lineTo(700, 640)
      ..cubicTo(692, 724, 612, 758, 548, 760)
      ..cubicTo(476, 756, 428, 724, 418, 640)
      ..close();
    _shape(c, p, _goldLight, fill2: _goldDark);
    c
      ..drawPath(
        Path()
          ..moveTo(432, 648)
          ..cubicTo(500, 672, 610, 668, 692, 640),
        _stroke(_goldDark, 6),
      )
      ..drawPath(
        Path()
          ..moveTo(448, 706)
          ..cubicTo(520, 728, 606, 722, 672, 696),
        _stroke(_goldDark, 6),
      );
    // lale rozeti
    c.save();
    c.translate(556, 650);
    c.scale(0.9);
    final petals = Path()
      ..moveTo(0, 36)
      ..cubicTo(-26, 30, -32, -14, -14, -32)
      ..lineTo(0, -10)
      ..lineTo(14, -32)
      ..cubicTo(32, -14, 26, 30, 0, 36)
      ..close();
    _shape(c, petals, _crimson, fill2: _crimsonDark, w: 5);
    c.restore();
  }

  void _plume(Canvas c) {
    final p = Path()
      ..moveTo(486, 206)
      ..cubicTo(462, 150, 492, 96, 548, 80)
      ..cubicTo(552, 128, 590, 152, 566, 206)
      ..close();
    _shape(c, p, const Color(0xFFEF4B3C), fill2: _crimsonDark, w: 7);
  }

  // ===== Siber Yeniçeri =====

  void _holoPad(Canvas c) {
    c
      ..drawOval(
        Rect.fromCenter(center: const Offset(480, 838), width: 520, height: 78),
        Paint()
          ..shader = RadialGradient(
            colors: [_cyan.withValues(alpha: 0.5), _cyan.withValues(alpha: 0)],
          ).createShader(Rect.fromCenter(center: const Offset(480, 838), width: 520, height: 78)),
      )
      ..drawOval(
        Rect.fromCenter(center: const Offset(480, 838), width: 440, height: 56),
        _stroke(_cyan, 6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      )
      ..drawOval(
        Rect.fromCenter(center: const Offset(480, 838), width: 330, height: 40),
        _stroke(_cyanLight.withValues(alpha: 0.8), 3),
      );
    // yüzen altıgen parçacıklar
    for (final o in const [Offset(120, 260), Offset(790, 420), Offset(770, 720), Offset(90, 720)]) {
      final hex = Path();
      for (var i = 0; i < 6; i++) {
        final a = math.pi / 3 * i;
        final p = Offset(o.dx + 18 * math.cos(a), o.dy + 18 * math.sin(a));
        i == 0 ? hex.moveTo(p.dx, p.dy) : hex.lineTo(p.dx, p.dy);
      }
      hex.close();
      c
        ..drawPath(hex, _fill(_cyan.withValues(alpha: 0.35)))
        ..drawPath(hex, _stroke(_cyan, 4));
    }
  }

  void _borkTail(Canvas c) {
    final p = Path()
      ..moveTo(430, 300)
      ..cubicTo(330, 296, 296, 390, 314, 540)
      ..lineTo(360, 522)
      ..cubicTo(352, 430, 384, 356, 448, 328)
      ..close();
    _shape(c, p, _navyLight, fill2: _navy);
    c.drawPath(
      Path()
        ..moveTo(326, 500)
        ..lineTo(350, 494),
      _stroke(_cyan, 6),
    );
  }

  void _neonCollar(Canvas c) {
    final band = Path()
      ..moveTo(366, 468)
      ..cubicTo(430, 522, 520, 552, 612, 552)
      ..cubicTo(652, 552, 684, 532, 704, 504)
      ..lineTo(708, 536)
      ..cubicTo(684, 572, 644, 586, 606, 586)
      ..cubicTo(508, 586, 420, 552, 370, 500)
      ..close();
    _shape(c, band, _navyLight, fill2: _navy);
    _glowLine(
      c,
      Path()
        ..moveTo(376, 490)
        ..cubicTo(436, 540, 522, 568, 606, 568)
        ..cubicTo(650, 568, 686, 546, 700, 522),
      _cyan,
      width: 5,
      blur: 6,
    );
  }

  Path _plateShape() => Path()
    ..moveTo(420, 556)
    ..cubicTo(480, 596, 600, 610, 692, 552)
    ..lineTo(700, 640)
    ..cubicTo(692, 724, 612, 758, 548, 760)
    ..cubicTo(476, 756, 428, 724, 418, 640)
    ..close();

  void _cyberPlate(Canvas c) {
    final p = _plateShape();
    _shape(c, p, _navyLight, fill2: _navy);
    // devre çizgileri
    final circuit = Path()
      ..moveTo(440, 690)
      ..lineTo(486, 690)
      ..lineTo(506, 716)
      ..moveTo(676, 690)
      ..lineTo(630, 690)
      ..lineTo(610, 716)
      ..moveTo(470, 620)
      ..lineTo(502, 632)
      ..moveTo(650, 620)
      ..lineTo(618, 632);
    c.drawPath(circuit, _stroke(_cyan.withValues(alpha: 0.9), 5));
    // çekirdek
    const core = Offset(556, 664);
    c
      ..drawCircle(core, 70, Paint()
        ..shader = RadialGradient(colors: [_cyan.withValues(alpha: 0.6), _cyan.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: core, radius: 70)))
      ..drawCircle(core, 34, _fill(_navy))
      ..drawCircle(core, 34, _stroke(_cyan, 7))
      ..drawCircle(core, 17, _fill(_cyanLight))
      ..drawCircle(core, 17, _stroke(Colors.white, 3));
  }

  void _bork(Canvas c) {
    final p = Path()
      ..moveTo(402, 304)
      ..cubicTo(392, 236, 420, 170, 470, 126)
      ..cubicTo(526, 94, 594, 108, 622, 152)
      ..cubicTo(650, 202, 652, 256, 648, 296)
      ..cubicTo(590, 272, 470, 272, 402, 304)
      ..close();
    _shape(c, p, _navyLight, fill2: _navy);
    // parlayan dikişler
    c
      ..drawPath(
        Path()
          ..moveTo(470, 132)
          ..cubicTo(446, 190, 440, 244, 448, 284),
        _stroke(_cyan.withValues(alpha: 0.85), 5),
      )
      ..drawPath(
        Path()
          ..moveTo(600, 124)
          ..cubicTo(618, 190, 620, 244, 616, 284),
        _stroke(_cyan.withValues(alpha: 0.85), 5),
      );
    // alt bant
    final band = Path()
      ..moveTo(400, 296)
      ..cubicTo(472, 264, 590, 264, 650, 290)
      ..lineTo(652, 318)
      ..cubicTo(590, 294, 472, 294, 398, 324)
      ..close();
    _shape(c, band, _navy, w: 8);
    _glowLine(
      c,
      Path()
        ..moveTo(410, 308)
        ..cubicTo(480, 282, 588, 282, 642, 304),
      _cyan,
      width: 4,
      blur: 5,
    );
    // ön rozet
    const g = Offset(526, 208);
    c
      ..drawCircle(g, 26, _fill(_navy))
      ..drawCircle(g, 26, _stroke(_ink, 6))
      ..drawCircle(g, 16, _fill(_cyan))
      ..drawCircle(g + const Offset(-5, -5), 5, _fill(Colors.white.withValues(alpha: 0.85)));
  }

  void _visor(Canvas c) {
    final v = Path()
      ..moveTo(392, 394)
      ..cubicTo(450, 344, 520, 322, 612, 316)
      ..cubicTo(672, 312, 716, 302, 740, 320)
      ..lineTo(738, 376)
      ..cubicTo(704, 398, 664, 412, 612, 434)
      ..cubicTo(540, 458, 462, 452, 404, 434)
      ..close();
    c.drawPath(
      v,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cyan.withValues(alpha: 0.42), _cyanLight.withValues(alpha: 0.16)],
        ).createShader(v.getBounds()),
    );
    _glowLine(c, v, _cyan, width: 6, blur: 7);
    // yansıma
    c.drawPath(
      _poly(const [Offset(470, 336), Offset(500, 330), Offset(462, 440), Offset(438, 436)]),
      _fill(Colors.white.withValues(alpha: 0.32)),
    );
    // yan kapsül
    final pod = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(372, 384, 44, 64), const Radius.circular(16)));
    _shape(c, pod, _navyLight, fill2: _navy, w: 7);
    c.drawCircle(const Offset(394, 416), 8, _fill(_cyan));
  }

  // ===== Efsanevi Anka =====

  /// Tek bir alev tüyü çizer: taban [origin], yön [angle] (radyan, +x = 0).
  void _flameFeather(Canvas c, Offset origin, double angle, double len, double wid) {
    c
      ..save()
      ..translate(origin.dx, origin.dy)
      ..rotate(angle);
    Path feather(double k) => Path()
      ..moveTo(0, -wid * 0.5 * k)
      ..cubicTo(len * 0.30, -wid * 1.0 * k, len * 0.66, -wid * 0.55 * k, len * k, -len * 0.06 * k)
      ..cubicTo(len * 0.70, wid * 0.22 * k, len * 0.36, wid * 0.85 * k, 0, wid * 0.5 * k)
      ..close();
    final outer = feather(1);
    c.drawPath(
      outer,
      Paint()
        ..shader = LinearGradient(
          colors: const [_flameRed, _flameOrange, _flameYellow],
          stops: const [0, 0.55, 1],
        ).createShader(Rect.fromLTWH(0, -wid, len, wid * 2)),
    );
    c.drawPath(outer, _stroke(_flameOutline, 6));
    final inner = feather(0.62);
    c.drawPath(
      inner,
      Paint()
        ..shader = LinearGradient(
          colors: [_flameYellow.withValues(alpha: 0.95), Colors.white.withValues(alpha: 0.9)],
        ).createShader(Rect.fromLTWH(0, -wid * 0.6, len * 0.62, wid * 1.2)),
    );
    c.restore();
  }

  void _rays(Canvas c, double t) {
    const center = Offset(480, 520);
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(t * 2 * math.pi);
    const n = 14;
    for (var i = 0; i < n; i++) {
      final a = 2 * math.pi * i / n;
      final p = Path()
        ..moveTo(0, 0)
        ..lineTo(math.cos(a - 0.06) * 470, math.sin(a - 0.06) * 470)
        ..lineTo(math.cos(a + 0.06) * 470, math.sin(a + 0.06) * 470)
        ..close();
      c.drawPath(
        p,
        Paint()
          ..shader = RadialGradient(
            colors: [_gold.withValues(alpha: 0.42), _gold.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: 470)),
      );
    }
    c.restore();
  }

  void _flameWings(Canvas c, double t) {
    final sway = math.sin(t * 2 * math.pi);
    double d(int deg) => deg * math.pi / 180;
    // (açı derece, uzunluk, genişlik) — sol (yakın) kanat büyük
    const left = [
      (238, 400.0, 130.0),
      (216, 450.0, 136.0),
      (194, 460.0, 136.0),
      (172, 420.0, 128.0),
      (152, 340.0, 116.0),
    ];
    const right = [
      (-64, 270.0, 100.0),
      (-42, 300.0, 104.0),
      (-20, 300.0, 104.0),
      (2, 270.0, 96.0),
    ];
    const lb = Offset(430, 610);
    const rb = Offset(640, 600);
    for (var i = 0; i < left.length; i++) {
      final (a, l, w) = left[i];
      final wob = sway * 0.045 * (i.isEven ? 1 : -1);
      _flameFeather(c, lb, d(a) + wob, l * (1 + 0.025 * sway), w);
    }
    for (var i = 0; i < right.length; i++) {
      final (a, l, w) = right[i];
      final wob = sway * 0.045 * (i.isEven ? -1 : 1);
      _flameFeather(c, rb, d(a) + wob, l * (1 + 0.025 * sway), w);
    }
    // kuyruk alevleri
    _flameFeather(c, const Offset(300, 720), d(140), 250, 80);
    _flameFeather(c, const Offset(300, 730), d(160), 280, 84);
  }

  void _embers(Canvas c, double t) {
    const seeds = [
      (110.0, 0.00), (200.0, 0.31), (330.0, 0.62), (720.0, 0.15), (800.0, 0.47),
      (620.0, 0.78), (150.0, 0.90), (760.0, 0.70), (260.0, 0.55), (860.0, 0.20),
    ];
    for (final (x, ph) in seeds) {
      final p = (t + ph) % 1.0;
      final y = 820 - p * 700;
      final xx = x + math.sin((p + ph) * 6) * 18;
      final a = (1 - p) * (p < 0.08 ? p / 0.08 : 1);
      c
        ..drawCircle(Offset(xx, y), 13, _fill(_flameOrange.withValues(alpha: 0.35 * a))..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5))
        ..drawCircle(Offset(xx, y), 6, _fill(_flameYellow.withValues(alpha: a)));
    }
  }

  void _crest(Canvas c, double t) {
    final sway = math.sin(t * 2 * math.pi);
    double d(int deg) => deg * math.pi / 180;
    _flameFeather(c, const Offset(466, 250), d(-118) + sway * 0.05, 150, 60);
    _flameFeather(c, const Offset(590, 236), d(-62) + sway * -0.05, 150, 60);
    _flameFeather(c, const Offset(528, 236), d(-90) + sway * 0.04, 190, 70);
  }

  void _gorget(Canvas c) {
    final band = Path()
      ..moveTo(366, 468)
      ..cubicTo(430, 522, 520, 552, 612, 552)
      ..cubicTo(652, 552, 684, 532, 704, 502)
      ..lineTo(708, 538)
      ..cubicTo(684, 574, 644, 588, 606, 588)
      ..cubicTo(508, 588, 420, 556, 370, 504)
      ..close();
    _shape(c, band, _goldLight, fill2: _goldDark);
    c.drawPath(
      Path()
        ..moveTo(386, 494)
        ..cubicTo(448, 540, 538, 566, 640, 552),
      _stroke(Colors.white.withValues(alpha: 0.55), 6),
    );
    // yakut kolye
    const g = Offset(560, 596);
    final pendant = Path()
      ..moveTo(g.dx, g.dy - 26)
      ..lineTo(g.dx + 30, g.dy)
      ..lineTo(g.dx, g.dy + 46)
      ..lineTo(g.dx - 30, g.dy)
      ..close();
    _shape(c, pendant, const Color(0xFFFF5A5A), fill2: _crimsonDark, w: 7);
    c.drawLine(Offset(g.dx - 10, g.dy - 6), Offset(g.dx - 2, g.dy - 14), _stroke(Colors.white.withValues(alpha: 0.85), 5));
  }
}
