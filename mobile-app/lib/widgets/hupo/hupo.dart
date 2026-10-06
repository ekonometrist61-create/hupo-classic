import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../utils/motion.dart';
import 'hupo_pose.dart';

export 'hupo_pose.dart';

/// Hupo: uygulamanın baykuş rehberi (şeffaf Master Hupo duruşları).
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
    final piksel = (widget.size * MediaQuery.devicePixelRatioOf(context)).round();

    // Şeffaf kare tuval: Hupo zemine serbestçe oturur.
    final image = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Image.asset(
        pose.assetPath,
        fit: BoxFit.contain,
        alignment: Alignment.bottomCenter,
        cacheWidth: piksel,
        gaplessPlayback: true,
        excludeFromSemantics: true,
      ),
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
