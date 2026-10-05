// Karakter görseli: açık karakter renkli, kilitli karakter karartılmış ve bulanık
// "gölge" olarak çizilir (silüet ipucu merak uyandırır, kim olduğu belli olmaz).
// Kart, detay sayfası ve kutlama penceresi aynı bileşeni kullanır.

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../models/character_models.dart';
import '../../theme/app_theme.dart';

const String _karakterYuklenemedi = 'Karakter görseli yüklenemedi';

class KarakterGorseli extends StatelessWidget {
  const KarakterGorseli({
    super.key,
    required this.karakter,
    required this.boyut,
    this.yaricap = 20,
    this.kalinlik = 3,
  });

  final CharacterCard karakter;
  final double boyut;
  final double yaricap;
  final double kalinlik;

  // Parlaklığı düşürüp lacivert bir tona çeker; renkler kaybolur, şekil kalır.
  static const _golgeFiltresi = ColorFilter.matrix(<double>[
    0.085, 0.286, 0.029, 0, 14,
    0.085, 0.286, 0.029, 0, 16,
    0.117, 0.393, 0.040, 0, 46,
    0, 0, 0, 1, 0,
  ]);

  // Küçük kartta aynı bulanıklık silüeti yok eder; boyutla orantılı tutulur.
  static const double _bulaniklikOrani = 0.011;

  @override
  Widget build(BuildContext context) {
    final renk = karakter.sinif.renk;
    final kazanildi = karakter.kazanildi;
    final piksel = (boyut * MediaQuery.devicePixelRatioOf(context)).round();

    final resim = Image.asset(
      karakter.assetPath,
      width: boyut,
      height: boyut,
      fit: BoxFit.cover,
      cacheWidth: piksel,
      excludeFromSemantics: true,
      errorBuilder: (_, __, ___) => Tooltip(
        message: _karakterYuklenemedi,
        child: Icon(
          Icons.broken_image_rounded,
          size: boyut * 0.4,
          color: AppColors.muted,
        ),
      ),
    );

    return Container(
      width: boyut,
      height: boyut,
      decoration: BoxDecoration(
        color: AppColors.line.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(yaricap),
        border: Border.all(color: kazanildi ? renk : AppColors.line, width: kalinlik),
        boxShadow: kazanildi
            ? [
                BoxShadow(
                  color: renk.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(yaricap - kalinlik),
        child: kazanildi
            ? resim
            : Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: boyut * _bulaniklikOrani,
                      sigmaY: boyut * _bulaniklikOrani,
                      tileMode: TileMode.decal,
                    ),
                    child: ColorFiltered(colorFilter: _golgeFiltresi, child: resim),
                  ),
                  Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: boyut * 0.28,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
