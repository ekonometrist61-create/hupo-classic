import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/motion.dart';
import 'ui/game_card.dart';

enum OptionState { idle, pending, correct, wrong, dimmed }

class AnswerOption extends StatelessWidget {
  const AnswerOption({
    super.key,
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
    this.focusNode,
  });

  final String label;
  final String text;
  final OptionState state;

  /// null ise şık kilitlidir.
  final VoidCallback? onTap;

  /// Klavyeyle (1-4 / A-D, yön tuşları) şık odağını yönetmek için.
  final FocusNode? focusNode;

  Color get _color => switch (state) {
        OptionState.correct => AppColors.mint,
        OptionState.wrong => AppColors.coral,
        OptionState.pending => AppColors.primarySoft,
        _ => AppColors.surface,
      };

  Color get _edge => switch (state) {
        OptionState.correct => AppColors.mintDark,
        OptionState.wrong => AppColors.coralDark,
        OptionState.pending => AppColors.primary,
        _ => AppColors.line,
      };

  bool get _filled => state == OptionState.correct || state == OptionState.wrong;

  @override
  Widget build(BuildContext context) {
    final textColor = _filled ? Colors.white : AppColors.ink;
    final badgeBg = _filled
        ? Colors.white.withValues(alpha: 0.25)
        : AppColors.primarySoft;
    final badgeFg = _filled ? Colors.white : AppColors.primary;

    Widget tile = GameCard(
      onTap: onTap,
      focusNode: focusNode,
      hoverColor: state == OptionState.idle ? AppColors.primarySoft : null,
      color: _color,
      borderColor: _edge,
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
            child: switch (state) {
              OptionState.correct =>
                Icon(Icons.check_rounded, color: badgeFg, size: 24),
              OptionState.wrong =>
                Icon(Icons.refresh_rounded, color: badgeFg, size: 24),
              _ => Text(
                  label,
                  style: appText(weight: FontWeight.w900, color: badgeFg),
                ),
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: appText(size: 17, weight: FontWeight.w800, color: textColor),
            ),
          ),
        ],
      ),
    );

    final still = reducedMotion(context);
    if (!still && state == OptionState.wrong) {
      // Yanlış şık kısa süre yana titrer.
      tile = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        builder: (context, t, child) => Transform.translate(
          offset: Offset(math.sin(t * math.pi * 5) * (1 - t) * 12, 0),
          child: child,
        ),
        child: tile,
      );
    } else if (!still && state == OptionState.correct) {
      // Doğru şık hafifçe zıplar.
      tile = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: tile,
      );
    } else if (state == OptionState.dimmed) {
      tile = Opacity(opacity: 0.5, child: tile);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Semantics(
        button: true,
        label: 'Şık $label: $text',
        child: tile,
      ),
    );
  }
}
