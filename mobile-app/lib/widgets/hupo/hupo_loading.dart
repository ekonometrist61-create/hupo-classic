import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'hupo.dart';

/// Yükleniyor durumu: düşünen Hupo ve cesaretlendirici bir cümle.
///
/// Hupo hafifçe süzülür; "hareketi azalt" açıksa ([Hupo] içinde) durağan kalır.
class HupoLoading extends StatelessWidget {
  const HupoLoading({
    super.key,
    this.message = 'Hupo senin için hazırlıyor…',
    this.compact = false,
  });

  final String message;

  /// true: satır içi (liste bölümleri) için küçük ve yatay düzen.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hupo = Hupo(
      mood: HupoMood.thinking,
      size: compact ? 56 : 104,
      animated: true,
      semanticLabel: 'Hupo düşünüyor',
    );
    final text = Text(
      message,
      textAlign: TextAlign.center,
      style: appText(
        size: compact ? 14 : 16,
        weight: FontWeight.w800,
        color: AppColors.muted,
      ),
    );
    return Semantics(
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Center(
          child: compact
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [hupo, const SizedBox(width: 8), Flexible(child: text)],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [hupo, const SizedBox(height: 8), text],
                ),
        ),
      ),
    );
  }
}
