import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Beyaz, yuvarlak köşeli, alttan "kalın kenarlı" kart. [onTap] verilirse basınca çöker.
class GameCard extends StatefulWidget {
  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.surface,
    this.borderColor = AppColors.line,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  static const _depth = 4.0;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null;
    final card = AnimatedPadding(
      duration: const Duration(milliseconds: 70),
      padding: EdgeInsets.only(
        top: _pressed ? _depth : 0,
        bottom: _pressed ? 0 : _depth,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(color: widget.borderColor, width: 2),
          boxShadow: _pressed
              ? null
              : [BoxShadow(color: widget.borderColor, offset: const Offset(0, _depth))],
        ),
        child: widget.child,
      ),
    );

    if (!tappable) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: card,
    );
  }
}
