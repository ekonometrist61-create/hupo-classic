// Aktif karakter rozeti: çocuk sahip olduğu karakteri ekranın üstünde her zaman görür.
// Ana ekran, soru ekranı ve sonuç ekranı aynı bileşeni kullanır.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'character_art.dart';

class AktifKarakterChip extends ConsumerWidget {
  const AktifKarakterChip({
    super.key,
    this.onTap,
    this.koyuZemin = false,
    this.kompakt = false,
  });

  /// Verilirse rozet dokunulabilir olur (örn. koleksiyonu açar).
  final VoidCallback? onTap;

  /// Yalnızca karakter resmi (ad yok); soru ekranı gibi dar şeritler için.
  final bool kompakt;

  /// Teal/koyu bir şerit üzerinde mi duruyor (yarı saydam beyaz zemin kullanılır).
  final bool koyuZemin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aktif = ref.watch(activeCharacterProvider);
    if (aktif == null) return const SizedBox.shrink();

    final renk = aktif.sinif.renk;
    final yazi = koyuZemin ? Colors.white : AppColors.ink;

    return Semantics(
      button: onTap != null,
      label: 'Karakterin: ${aktif.ad}',
      child: ExcludeSemantics(
        child: Material(
          color: koyuZemin
              ? Colors.white.withValues(alpha: 0.18)
              : AppColors.surface,
          shape: StadiumBorder(
            side: BorderSide(color: koyuZemin ? Colors.white54 : renk, width: 2),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(4, 4, kompakt ? 4 : 14, 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  KarakterGorseli(karakter: aktif, boyut: 36, yaricap: 18, kalinlik: 0),
                  if (!kompakt) ...[
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        aktif.ad,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appText(size: 14, weight: FontWeight.w900, color: yazi),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
