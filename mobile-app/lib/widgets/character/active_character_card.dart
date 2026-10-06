// Ana ekran aktif karakter kartı.
// Çocuk kendi aktif karakterini (bilinen, renkli) görür; hemen altında
// sıradaki kilitli karakterin GÖLGESİNİ ve onu açmak için gereken koşulu
// görür — "açmak için ders çalış, soru çöz" motivasyonu burada doğar.
// Eski 5 evreli avatar (Çaylak Alp → Efsanevi Anka) yerine geçer.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/character_models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../ui/game_card.dart';
import 'character_art.dart';

class AktifKarakterKarti extends ConsumerWidget {
  const AktifKarakterKarti({super.key, required this.onTap});

  /// Koleksiyon ekranını açar.
  final VoidCallback onTap;

  static const _baslik = 'Karakterin';
  static const _bosDurum = 'İlk karakterini kazanmak için soru çözmeye başla!';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karakterler = ref.watch(myCharactersProvider).valueOrNull;
    final aktif = ref.watch(activeCharacterProvider);

    // Sıradaki kilitli karakter (katalog sırasında ilk kazanılmamış).
    CharacterCard? siradaki;
    if (karakterler != null) {
      final kilitliler = karakterler.where((k) => !k.kazanildi).toList()
        ..sort((a, b) {
          final s = a.sinifSira.compareTo(b.sinifSira);
          return s != 0 ? s : a.karakterSira.compareTo(b.karakterSira);
        });
      if (kilitliler.isNotEmpty) siradaki = kilitliler.first;
    }

    final renk = aktif?.sinif.renk ?? AppColors.primary;

    return GameCard(
      onTap: onTap,
      borderColor: renk,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (aktif != null)
                KarakterGorseli(karakter: aktif, boyut: 72, yaricap: 18)
              else
                _BosResim(renk: renk),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _baslik,
                      style: appText(
                          size: 12, weight: FontWeight.w900, color: AppColors.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      aktif?.ad ?? 'Henüz karakter yok',
                      style: appText(size: 20, weight: FontWeight.w900),
                    ),
                    if (aktif != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: renk.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          aktif.sinif.ad,
                          style: appText(size: 11, color: renk, weight: FontWeight.w800),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 4),
                      Text(
                        _bosDurum,
                        style: appText(size: 12, color: AppColors.muted, height: 1.3),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.muted, size: 22),
            ],
          ),
          if (siradaki != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: 12),
            _SiradakiSatir(karakter: siradaki),
          ],
        ],
      ),
    );
  }
}

/// Sıradaki kilitli karakteri gölge olarak ve açma koşuluyla gösterir.
class _SiradakiSatir extends StatelessWidget {
  const _SiradakiSatir({required this.karakter});

  final CharacterCard karakter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        KarakterGorseli(
          karakter: karakter,
          boyut: 84,
          kalinlik: 2,
          vurgu: true,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sıradaki gizli karakter: Kim olduğunu keşfet!',
                style: appText(
                    size: 11, weight: FontWeight.w900, color: AppColors.muted),
              ),
              const SizedBox(height: 2),
              Text(
                'Açmak için ${karakter.kosulTuru.aciklamaMetni(karakter.kosulDeger)}',
                style: appText(size: 13, weight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Hiç karakter yokken gösterilen boş yer tutucu.
class _BosResim extends StatelessWidget {
  const _BosResim({required this.renk});

  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.line.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line, width: 3),
      ),
      child: Icon(Icons.auto_awesome_rounded, color: renk, size: 32),
    );
  }
}
