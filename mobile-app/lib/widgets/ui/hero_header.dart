import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Ekranların üstündeki menekşe degrade, alt köşeleri yuvarlak başlık alanı.
class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          // Hafif dekoratif daireler
          const Positioned(
            top: -40,
            right: -30,
            child: _Bubble(size: 150, alpha: 0.10),
          ),
          const Positioned(
            bottom: 20,
            left: -50,
            child: _Bubble(size: 120, alpha: 0.07),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: padding ?? const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      ),
    );
  }
}
