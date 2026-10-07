// Koleksiyon ekranında tek karakter kartı.
//
// Kazanılmışsa: renkli görsel + isim.
// Kilitliyse: karartılmış gölge görsel + kilit koşulu etiketi.

import 'package:flutter/material.dart';

import '../../models/character_models.dart';
import '../../theme/app_theme.dart';
import 'character_art.dart';

const String _kilitliKarakter = 'Kilitli karakter';

class CharacterCardWidget extends StatelessWidget {
  const CharacterCardWidget({
    super.key,
    required this.karakter,
    this.onTap,
    this.boyut = 104,
    this.etiketGoster = true,
  });

  final CharacterCard karakter;
  final VoidCallback? onTap;
  final double boyut;

  /// false ise yalnızca görsel çizilir (isim başka yerde yazılıyorsa).
  final bool etiketGoster;

  @override
  Widget build(BuildContext context) {
    final kosul = karakter.kosulTuru.aciklamaMetni(karakter.kosulDeger);

    return Semantics(
      button: onTap != null,
      label: karakter.kazanildi ? karakter.ad : '$_kilitliKarakter, $kosul',
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: boyut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KarakterGorseli(karakter: karakter, boyut: boyut),
                if (etiketGoster) ...[
                  const SizedBox(height: 6),
                  _KarakterEtiket(karakter: karakter, kosul: kosul),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KarakterEtiket extends StatelessWidget {
  const _KarakterEtiket({required this.karakter, required this.kosul});

  final CharacterCard karakter;
  final String kosul;

  @override
  Widget build(BuildContext context) {
    if (karakter.kazanildi) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            karakter.ad,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: appText(size: 12, weight: FontWeight.w800, height: 1.2),
          ),
          Text(
            karakter.nadirlik.ad,
            style: appText(size: 10, weight: FontWeight.w700, color: karakter.nadirlik.renk),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_rounded, size: 12, color: AppColors.muted),
        const SizedBox(height: 2),
        Text(
          kosul,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: appText(size: 11, color: AppColors.muted, height: 1.2),
        ),
      ],
    );
  }
}
