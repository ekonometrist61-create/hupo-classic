// Karakter görseli.
//
// Açık karakter: renkli, sınıf renginde yumuşak bir hale ile.
// Kilitli karakter: şeffaf görselin ALFA maskesinden çıkan gerçek silüet.
//   koyu lacivert dolgu + sınıf renginde parlayan dış hat + arkada ışık huzmeleri + "?" kıvılcımı.
//   Şeklin hatları görünür, kim olduğu belli olmaz; merak uyandırır.
// Kart, detay sayfası ve kutlama penceresi aynı bileşeni kullanır.
//
// Not: Silüet için assets/characters/** görselleri şeffaf (RGBA) olmalıdır.

import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../models/character_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/motion.dart';

const String _karakterYuklenemedi = 'Karakter görseli yüklenemedi';
const Color _siluetRengi = Color(0xFF0B1B2E);

class KarakterGorseli extends StatefulWidget {
  const KarakterGorseli({
    super.key,
    required this.karakter,
    required this.boyut,
    this.yaricap = 20,
    this.kalinlik = 3,
    this.vurgu = false,
  });

  final CharacterCard karakter;
  final double boyut;
  final double yaricap;
  final double kalinlik;

  /// Kilitli karakterde ışık huzmeleri dönüp nabız atar (sıradaki hedef karakter için).
  final bool vurgu;

  @override
  State<KarakterGorseli> createState() => _KarakterGorseliState();
}

class _KarakterGorseliState extends State<KarakterGorseli>
    with SingleTickerProviderStateMixin {
  late final AnimationController _kontrol = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  bool get _canli => !widget.karakter.kazanildi && widget.vurgu;

  void _senkronla() {
    if (_canli && !reducedMotion(context)) {
      if (!_kontrol.isAnimating) _kontrol.repeat();
    } else {
      _kontrol
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _senkronla();
  }

  @override
  void didUpdateWidget(covariant KarakterGorseli oldWidget) {
    super.didUpdateWidget(oldWidget);
    _senkronla();
  }

  @override
  void dispose() {
    _kontrol.dispose();
    super.dispose();
  }

  Widget _resim({Color? boya, double olcek = 1}) {
    final piksel = (widget.boyut * MediaQuery.devicePixelRatioOf(context)).round();
    Widget r = Image.asset(
      widget.karakter.assetPath,
      width: widget.boyut,
      height: widget.boyut,
      fit: BoxFit.contain,
      cacheWidth: piksel,
      excludeFromSemantics: true,
      errorBuilder: (_, __, ___) => Tooltip(
        message: _karakterYuklenemedi,
        child: Icon(
          Icons.broken_image_rounded,
          size: widget.boyut * 0.4,
          color: AppColors.muted,
        ),
      ),
    );
    if (boya != null) {
      r = ColorFiltered(colorFilter: ColorFilter.mode(boya, BlendMode.srcIn), child: r);
    }
    if (olcek != 1) r = Transform.scale(scale: olcek, child: r);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    final karakter = widget.karakter;
    final boyut = widget.boyut;
    final renk = karakter.sinif.renk;
    final kazanildi = karakter.kazanildi;
    final ic = widget.yaricap - widget.kalinlik;

    final Widget icerik = kazanildi ? _kazanilmis(renk) : _kilitli(renk, boyut);

    return RepaintBoundary(
      child: Container(
        width: boyut,
        height: boyut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.yaricap),
          border: widget.kalinlik > 0
              ? Border.all(
                  color: kazanildi ? renk : renk.withValues(alpha: 0.55),
                  width: widget.kalinlik,
                )
              : null,
          boxShadow: kazanildi
              ? [
                  BoxShadow(
                    color: renk.withValues(alpha: 0.35),
                    blurRadius: 8 + karakter.nadirlik.sira * 2,
                    offset: const Offset(0, 4),
                  ),
                  if (karakter.nadirlik.sira >= 4)
                    BoxShadow(
                      color: karakter.nadirlik.renk.withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                ]
              : widget.vurgu
                  ? [BoxShadow(color: renk.withValues(alpha: 0.45), blurRadius: 18)]
                  : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ic < 0 ? 0 : ic),
          child: icerik,
        ),
      ),
    );
  }

  Widget _kazanilmis(Color renk) {
    final nadirlik = widget.karakter.nadirlik;
    final boyut = widget.boyut;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [renk.withValues(alpha: 0.28), renk.withValues(alpha: 0.06)],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(boyut * 0.04),
          child: _resim(),
        ),
        // Efsanevi ve Mitik karakterler küçük bir parıltı rozetiyle öne çıkar.
        if (nadirlik.sira >= 4)
          Positioned(
            top: boyut * 0.04,
            right: boyut * 0.04,
            child: Semantics(
              label: nadirlik.ad,
              child: ExcludeSemantics(
                child: Container(
                  padding: EdgeInsets.all(boyut * 0.035),
                  decoration: BoxDecoration(
                    color: nadirlik.renk,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: nadirlik.renk.withValues(alpha: 0.6), blurRadius: 6),
                    ],
                  ),
                  child: Icon(
                    nadirlik == KarakterNadirlik.mitik
                        ? Icons.local_fire_department_rounded
                        : Icons.auto_awesome_rounded,
                    size: boyut * 0.11,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _kilitli(Color renk, double boyut) {
    final blur = boyut * 0.035;
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF1E3F5F), Color(0xFF0B1B2E)],
              radius: 0.9,
            ),
          ),
        ),
        // Arkadan ışık huzmeleri.
        AnimatedBuilder(
          animation: _kontrol,
          builder: (context, _) => CustomPaint(
            painter: _IsinPainter(
              renk: renk,
              donus: _kontrol.value * 2 * math.pi,
              guc: widget.vurgu
                  ? 0.8 + 0.2 * math.sin(_kontrol.value * 2 * math.pi * 7)
                  : 0.45,
            ),
          ),
        ),
        // Dış hat parlaması: silüetin sınıf renginde, bulanık ve büyütülmüş kopyası.
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur * 1.6, sigmaY: blur * 1.6, tileMode: TileMode.decal),
          child: Padding(
            padding: EdgeInsets.all(boyut * 0.08),
            child: _resim(boya: renk, olcek: 1.06),
          ),
        ),
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blur * 0.4, sigmaY: blur * 0.4, tileMode: TileMode.decal),
          child: Padding(
            padding: EdgeInsets.all(boyut * 0.08),
            child: _resim(boya: renk.withValues(alpha: 0.95), olcek: 1.025),
          ),
        ),
        // Silüetin kendisi.
        Padding(
          padding: EdgeInsets.all(boyut * 0.08),
          child: _resim(boya: _siluetRengi),
        ),
        // Merak kıvılcımı ve küçük kilit.
        Positioned(
          top: boyut * 0.06,
          right: boyut * 0.08,
          child: Text(
            '?',
            style: appText(
              size: boyut * 0.24,
              weight: FontWeight.w900,
              color: AppColors.sun,
            ),
          ),
        ),
        Positioned(
          bottom: boyut * 0.06,
          right: boyut * 0.08,
          child: Icon(
            Icons.lock_rounded,
            size: boyut * 0.16,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _IsinPainter extends CustomPainter {
  _IsinPainter({required this.renk, required this.donus, required this.guc});

  final Color renk;
  final double donus;
  final double guc;

  static const int _huzmeSayisi = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final merkez = size.center(Offset.zero);
    final yaricap = size.longestSide * 0.85;
    final boya = Paint()
      ..shader = RadialGradient(
        colors: [renk.withValues(alpha: 0.6 * guc), renk.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: merkez, radius: yaricap));

    const yariAci = math.pi / (_huzmeSayisi * 2) * 0.9;
    for (var i = 0; i < _huzmeSayisi; i++) {
      final a = donus + i * 2 * math.pi / _huzmeSayisi;
      final yol = Path()
        ..moveTo(merkez.dx, merkez.dy)
        ..lineTo(merkez.dx + yaricap * math.cos(a - yariAci), merkez.dy + yaricap * math.sin(a - yariAci))
        ..lineTo(merkez.dx + yaricap * math.cos(a + yariAci), merkez.dy + yaricap * math.sin(a + yariAci))
        ..close();
      canvas.drawPath(yol, boya);
    }
  }

  @override
  bool shouldRepaint(covariant _IsinPainter eski) =>
      eski.renk != renk || eski.donus != donus || eski.guc != guc;
}
