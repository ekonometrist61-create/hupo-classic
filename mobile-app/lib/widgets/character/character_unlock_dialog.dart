// Yeni karakter açılınca tam ekran konfetiyle gösterilen kutlama penceresi.
// TierUpDialog ile aynı tasarım dilini kullanır.

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../models/character_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/motion.dart';
import '../hupo/hupo.dart';
import '../ui/chunky_button.dart';
import 'character_art.dart';

Future<void> showCharacterUnlockDialog(
    BuildContext context, CharacterCard karakter) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Karakter Açıldı',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: motionMs(context, 350),
    transitionBuilder: (context, animation, _, child) => ScaleTransition(
      scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      child: FadeTransition(opacity: animation, child: child),
    ),
    pageBuilder: (context, _, __) => CharacterUnlockView(karakter: karakter),
  );
}

class CharacterUnlockView extends StatelessWidget {
  const CharacterUnlockView({super.key, required this.karakter});

  final CharacterCard karakter;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Semantics(
              liveRegion: true,
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: karakter.sinif.renk, width: 4),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Hupo(
                          mood: HupoMood.celebrate, size: 84, animated: true),
                      Text(
                        'Yeni karakter açıldı!',
                        style: appText(
                            size: 26,
                            weight: FontWeight.w900,
                            color: karakter.sinif.renk),
                      ),
                      const SizedBox(height: 16),
                      KarakterGorseli(
                        karakter: karakter,
                        boyut: 200,
                        yaricap: 28,
                        kalinlik: 4,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        karakter.ad,
                        textAlign: TextAlign.center,
                        style: appText(size: 22, weight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      _SinifRozeti(sinif: karakter.sinif),
                      const SizedBox(height: 12),
                      Text(
                        karakter.aciklama,
                        textAlign: TextAlign.center,
                        style: appText(
                            size: 15,
                            color: AppColors.muted,
                            height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ChunkyButton(
                        label: 'Harika!',
                        color: karakter.sinif.renk,
                        shadowColor:
                            Color.lerp(karakter.sinif.renk, Colors.black, 0.35)!,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Tam sayfa konfeti; hareket azaltılmışsa gösterilmez.
        if (!reducedMotion(context))
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/lottie/confetti.json',
                repeat: false,
                fit: BoxFit.cover,
              ),
            ),
          ),
      ],
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
