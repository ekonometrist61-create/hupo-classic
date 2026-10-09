// Paylaşılan klavye odağı + fare üzerine gelme sarmalayıcısı (Flutter Web / masaüstü).
//
// - Tıklanabilir öğelerde imleç "el" olur, devre dışıyken varsayılan kalır.
// - Odak halkası yalnızca klavye odağında görünür (FocusHighlightMode.traditional).
// - Hover yalnızca fare/pointer ile tetiklenir; dokunmatikte hiçbir şey değişmez.
// - Enter / Space (ActivateIntent) [onActivate]'i çağırır.

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

typedef HupoFocusBuilder = Widget Function(BuildContext context, bool hovered);

class HupoFocus extends StatefulWidget {
  const HupoFocus({
    super.key,
    required this.builder,
    required this.onActivate,
    this.borderRadius = 24,
    this.onDarkSurface = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// Hover durumunu alarak çocuğu kurar.
  final HupoFocusBuilder builder;

  /// null ise öğe devre dışıdır: odaklanmaz, imleç varsayılan kalır, halka çıkmaz.
  final VoidCallback? onActivate;

  /// Sarılan bileşenin köşe yarıçapı; halka bunun dışına çizilir.
  final double borderRadius;

  /// Koyu (navy/hero) zeminde halka beyaz olur.
  final bool onDarkSurface;

  final FocusNode? focusNode;
  final bool autofocus;

  /// Halkanın bileşenden dışarı taşma payı (2 px boşluk + 3 px halka).
  /// Halka kırpılmasın diye çevredeki boşluk en az bu kadar olmalıdır.
  static const double ringOutset = 5;
  static const double ringWidth = 3;

  @override
  State<HupoFocus> createState() => _HupoFocusState();
}

class _HupoFocusState extends State<HupoFocus> {
  bool _hovered = false;
  bool _showRing = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onActivate != null;
    final ring = enabled && _showRing;

    return FocusableActionDetector(
      enabled: enabled,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (v) {
        if (_showRing != v) setState(() => _showRing = v);
      },
      onShowHoverHighlight: (v) {
        if (_hovered != v) setState(() => _hovered = v);
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onActivate?.call();
            return null;
          },
        ),
      },
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          widget.builder(context, enabled && _hovered),
          if (ring)
            Positioned(
              left: -HupoFocus.ringOutset,
              top: -HupoFocus.ringOutset,
              right: -HupoFocus.ringOutset,
              bottom: -HupoFocus.ringOutset,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      widget.borderRadius + HupoFocus.ringOutset,
                    ),
                    border: Border.all(
                      color: widget.onDarkSurface
                          ? Colors.white
                          : AppColors.primary,
                      width: HupoFocus.ringWidth,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
