// Karakter detay bottom sheet — kazanılmış veya kilitli karakter bilgisi.

import 'package:flutter/material.dart';

import '../../models/character_models.dart';
import '../../theme/app_theme.dart';
import 'character_art.dart';

class CharacterDetailSheet extends StatelessWidget {
  const CharacterDetailSheet({super.key, required this.karakter});

  final CharacterCard karakter;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tutamaç
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Karakter resmi — büyük
              _BuyukResim(karakter: karakter),
              const SizedBox(height: 16),
              // İsim
              Text(
                karakter.kazanildi ? karakter.ad : '???',
                style: appText(size: 22, weight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Sınıf rozeti
              _SinifRozeti(sinif: karakter.sinif),
              const SizedBox(height: 12),
              // Açıklama
              Text(
                karakter.kazanildi
                    ? karakter.aciklama
                    : 'Bu karakteri açmak için ${karakter.kosulTuru.aciklamaMetni(karakter.kosulDeger)}.',
                textAlign: TextAlign.center,
                style: appText(size: 14, color: AppColors.muted, height: 1.5),
              ),
              if (karakter.kazanildi && karakter.kazanildiAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${_tarihFormatla(karakter.kazanildiAt!)} tarihinde kazandın 🎉',
                  textAlign: TextAlign.center,
                  style: appText(size: 12, color: AppColors.muted),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static String _tarihFormatla(DateTime dt) =>
      '${dt.day}.${dt.month}.${dt.year}';
}

class _BuyukResim extends StatelessWidget {
  const _BuyukResim({required this.karakter});

  final CharacterCard karakter;

  @override
  Widget build(BuildContext context) {
    // Ekran yüksekliğinin ~%38'i kadar, en çok 280: küçük telefonda sheet taşmasın.
    final boyut = (MediaQuery.sizeOf(context).height * 0.38).clamp(160.0, 280.0);
    return KarakterGorseli(
      karakter: karakter,
      boyut: boyut,
      yaricap: 28,
      kalinlik: 4,
    );
  }
}

class _SinifRozeti extends StatelessWidget {
  const _SinifRozeti({required this.sinif});

  final KarakterSinifi sinif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: sinif.renk.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        sinif.ad,
        style: appText(size: 12, color: sinif.renk),
      ),
    );
  }
}
