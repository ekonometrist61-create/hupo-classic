import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/motion.dart';
import 'hupo_focus.dart';

/// Beyaz, yuvarlak köşeli, alttan "kalın kenarlı" kart. [onTap] verilirse basınca çöker.
/// Fare ile üzerine gelince hafifçe yükselir, klavye odağında halka çıkar (HupoFocus).
class GameCard extends StatefulWidget {
  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.surface,
    this.borderColor = AppColors.line,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.hoverColor,
    this.focusNode,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Fare üzerindeyken zemin rengi (yalnızca [onTap] varsa). null ise zemin değişmez.
  final Color? hoverColor;

  /// Klavye ile odak gezdirmek isteyen üst bileşenler için (ör. quiz şıkları).
  final FocusNode? focusNode;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  static const _depth = 4.0;
  bool _pressed = false;

  Widget _card(BuildContext context, {required bool hovered}) {
    // Kenar yalnızca varsayılan (nötr) kartlarda hover'da vurgulanır;
    // renkli (doğru/yanlış/uyarı) kartlar hover ile anlam değiştirmez.
    final neutralEdge = widget.borderColor == AppColors.line;
    final edge =
        hovered && neutralEdge ? AppColors.primaryLight : widget.borderColor;
    final fill = hovered && widget.hoverColor != null
        ? widget.hoverColor!
        : widget.color;
    final lift = hovered && !_pressed ? -2.0 : 0.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 70),
      padding: EdgeInsets.only(
        top: _pressed ? _depth : 0,
        bottom: _pressed ? 0 : _depth,
      ),
      child: AnimatedContainer(
        duration: hovered || lift != 0
            ? motionMs(context, 120)
            : const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, lift, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: edge, width: 2),
          boxShadow: _pressed
              ? null
              : [BoxShadow(color: edge, offset: const Offset(0, _depth))],
        ),
        child: widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    if (!tappable) return _card(context, hovered: false);

    return HupoFocus(
      onActivate: widget.onTap,
      borderRadius: widget.radius,
      focusNode: widget.focusNode,
      builder: (context, hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: _card(context, hovered: hovered),
      ),
    );
  }
}
