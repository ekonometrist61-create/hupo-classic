import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/breakpoints.dart';

/// Ekranların üstündeki menekşe degrade, alt köşeleri yuvarlak başlık alanı.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.child,
    this.padding,
    this.maxContentWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  /// Geniş ekranda (>= 600) başlık içeriğinin üst genişliği; arka plan tam genişlik kalır.
  /// Verilmezse tablet 720, masaüstü 1100. Telefonda etkisizdir.
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final icerik = SizedBox(width: double.infinity, child: child);
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
              child: isWide(context)
                  ? Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxContentWidth ?? contentMaxWidth(context),
                        ),
                        child: icerik,
                      ),
                    )
                  : icerik,
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
