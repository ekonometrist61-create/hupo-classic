import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../utils/haptics.dart';

/// Oyunlardaki gibi "kabartmalı" düğme: basınca aşağı çöker.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.shadowColor = AppColors.primaryDark,
    this.textColor = Colors.white,
    this.icon,
    this.loading = false,
    this.expanded = true,
    this.height = 56,
  });

  factory ChunkyButton.success({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
  }) =>
      ChunkyButton(
        key: key,
        label: label,
        onPressed: onPressed,
        color: AppColors.mint,
        shadowColor: AppColors.mintDark,
      );

  factory ChunkyButton.danger({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
  }) =>
      ChunkyButton(
        key: key,
        label: label,
        onPressed: onPressed,
        color: AppColors.coral,
        shadowColor: AppColors.coralDark,
      );

  /// Beyaz zemin üzerinde, renkli yazılı ikincil düğme.
  factory ChunkyButton.light({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool expanded = true,
  }) =>
      ChunkyButton(
        key: key,
        label: label,
        onPressed: onPressed,
        icon: icon,
        expanded: expanded,
        color: Colors.white,
        shadowColor: AppColors.lineDark,
        textColor: AppColors.primary,
      );

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final IconData? icon;
  final bool loading;
  final bool expanded;
  final double height;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  static const _depth = 5.0;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final color = _enabled ? widget.color : AppColors.line;
    final edge = _enabled ? widget.shadowColor : AppColors.lineDark;
    final textColor = _enabled ? widget.textColor : AppColors.muted;

    final content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 3, color: textColor),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, color: textColor, size: 22),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: appText(size: 17, weight: FontWeight.w800, color: textColor),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: _enabled
              ? () {
                  AppHaptics.selection();
                  widget.onPressed!();
                }
              : null,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 70),
            padding: EdgeInsets.only(
              top: _pressed ? _depth : 0,
              bottom: _pressed ? 0 : _depth,
            ),
            child: Container(
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: _pressed
                    ? null
                    : [BoxShadow(color: edge, offset: const Offset(0, _depth))],
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
