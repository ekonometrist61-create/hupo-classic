// Koleksiyon ızgarasında tek karakter kartı.
//
// Kazanılmışsa: renkli PNG gösterir ve isim görünür.
// Kilitliyse: ColorFilter ile siyah silhouette + koşul etiketi.

import 'package:flutter/material.dart';

import '../../models/character_models.dart';
import '../../theme/app_theme.dart';

class CharacterCardWidget extends StatelessWidget {
  const CharacterCardWidget({
    super.key,
    required this.karakter,
    this.onTap,
  });

  final CharacterCard karakter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _KarakterResim(karakter: karakter),
          const SizedBox(height: 6),
          _KarakterEtiket(karakter: karakter),
        ],
      ),
    );
  }
}

// ── Resim katmanı ────────────────────────────────────────────────────────────

class _KarakterResim extends StatelessWidget {
  const _KarakterResim({required this.karakter});

  final CharacterCard karakter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: karakter.kazanildi
            ? karakter.sinif.renk.withValues(alpha: 0.12)
            : AppColors.line.withValues(alpha: 0.5),
        shape: BoxShape.circle,
        border: Border.all(
          color: karakter.kazanildi ? karakter.sinif.renk : AppColors.line,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: karakter.kazanildi
            ? _RenkliResim(assetPath: karakter.assetPath)
            : _SilhouetteResim(assetPath: karakter.assetPath),
      ),
    );
  }
}

class _RenkliResim extends StatelessWidget {
  const _RenkliResim({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: 56,
      height: 56,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.person_rounded,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }
}

class _SilhouetteResim extends StatelessWidget {
  const _SilhouetteResim({required this.assetPath});

  final String assetPath;

  // Tüm pikselleri siyaha dönüştüren ColorFilter
  static const _silhouetteFilter = ColorFilter.matrix(<double>[
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 0, 0, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: _silhouetteFilter,
      child: Opacity(
        opacity: 0.35,
        child: Image.asset(
          assetPath,
          width: 56,
          height: 56,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.person_rounded,
            size: 40,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }
}

// ── Etiket katmanı ───────────────────────────────────────────────────────────

class _KarakterEtiket extends StatelessWidget {
  const _KarakterEtiket({required this.karakter});

  final CharacterCard karakter;

  @override
  Widget build(BuildContext context) {
    if (karakter.kazanildi) {
      return Text(
        karakter.ad,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: appText(
          size: 11,
          weight: FontWeight.w700,
          color: AppColors.ink,
          height: 1.2,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_rounded, size: 12, color: AppColors.muted),
        const SizedBox(height: 2),
        Text(
          karakter.kosulTuru.aciklamaMetni(karakter.kosulDeger),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: appText(size: 10, weight: FontWeight.w500, color: AppColors.muted),
        ),
      ],
    );
  }
}
