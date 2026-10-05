import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/motion.dart';
import 'hupo_pose.dart';

export 'hupo_pose.dart';

const double _kartYaricapOrani = 0.22;

/// Hupo: uygulamanın baykuş rehberi. Saydam duruşları ve Master Hupo ifade kartlarını gösterir.
///
/// Ya doğrudan bir [pose] verilir ya da bir an ([mood]) ve isteğe bağlı [variant] verilir.
class Hupo extends StatefulWidget {
  const Hupo({
    super.key,
    this.pose,
    this.mood,
    this.variant = 0,
    this.size = 120,
    this.animated = false,
    this.semanticLabel = 'Hupo, baykuş rehberin',
  }) : assert(pose != null || mood != null, 'pose ya da mood verilmeli');

  final HupoPose? pose;
  final HupoMood? mood;
  final int variant;
  final double size;

  /// true ise Hupo hafifçe süzülür ve nefes alır (hareket azaltılmışsa durağan kalır).
  final bool animated;
  final String semanticLabel;

  HupoPose get resolvedPose => pose ?? mood!.pose(variant);

  @override
  State<Hupo> createState() => _HupoState();
}

class _HupoState extends State<Hupo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  void _syncAnimation() {
    if (widget.animated && !reducedMotion(context)) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
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
  void didUpdateWidget(covariant Hupo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pose = widget.resolvedPose;
    final genislik = widget.size * pose.oran;
    final piksel = (genislik * MediaQuery.devicePixelRatioOf(context)).round();

    final resim = Image.asset(
      pose.assetPath,
      fit: pose.kart ? BoxFit.cover : BoxFit.contain,
      alignment: pose.kart ? Alignment.center : Alignment.bottomCenter,
      cacheWidth: piksel,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );

    // Master Hupo kartları mavi fonlu karedir: yuvarlatılıp çıkartma gibi gösterilir.
    final image = SizedBox(
      width: genislik,
      height: widget.size,
      child: pose.kart
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.size * _kartYaricapOrani),
                border: Border.all(
                  color: Colors.white,
                  width: (widget.size * 0.03).clamp(1.5, 4.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.size * _kartYaricapOrani),
                child: resim,
              ),
            )
          : resim,
    );

    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: !widget.animated
            ? image
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = math.sin(_controller.value * math.pi);
                  return Transform.translate(
                    offset: Offset(0, -t * widget.size * 0.03),
                    child: Transform.scale(
                      scale: 1 + t * 0.015,
                      alignment: Alignment.bottomCenter,
                      child: child,
                    ),
                  );
                },
                child: image,
              ),
      ),
    );
  }
}
