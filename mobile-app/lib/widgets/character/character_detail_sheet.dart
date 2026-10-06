// Karakter detay bottom sheet — kazanılmış veya kilitli karakter bilgisi.
// Kazanılmış karakter "aktif karakterim yap" ile ana ekranda gösterilen
// karakter olarak seçilebilir (sunucu-otoriter: yalnızca kazanılmış karakter).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/character_models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../ui/chunky_button.dart';
import 'character_art.dart';

const String _degistirilemedi =
    'Karakter değiştirilemedi, birazdan tekrar deneyelim.';

class CharacterDetailSheet extends ConsumerStatefulWidget {
  const CharacterDetailSheet({super.key, required this.karakter});

  final CharacterCard karakter;

  @override
  ConsumerState<CharacterDetailSheet> createState() =>
      _CharacterDetailSheetState();
}

class _CharacterDetailSheetState extends ConsumerState<CharacterDetailSheet> {
  bool _gonderiliyor = false;

  CharacterCard get karakter => widget.karakter;

  Future<void> _aktifYap() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _gonderiliyor = true);
    try {
      await ref.read(quizRepositoryProvider).setActiveCharacter(karakter.kod);
      ref.invalidate(statsProvider);
      ref.invalidate(myCharactersProvider);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('${karakter.ad} artık senin karakterin! 🎉')),
      );
    } catch (_) {
      if (mounted) setState(() => _gonderiliyor = false);
      messenger.showSnackBar(const SnackBar(content: Text(_degistirilemedi)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final aktifKod = ref.watch(activeCharacterProvider)?.kod;
    final buKarakterAktif = aktifKod == karakter.kod;

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
              // Aktif karakter eylemi (yalnızca kazanılmış karakterlerde)
              if (karakter.kazanildi) ...[
                const SizedBox(height: 20),
                if (buKarakterAktif)
                  const _AktifRozeti()
                else
                  ChunkyButton.success(
                    label: 'Aktif karakterim yap',
                    onPressed: _gonderiliyor ? null : _aktifYap,
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

/// "Bu senin aktif karakterin" göstergesi.
class _AktifRozeti extends StatelessWidget {
  const _AktifRozeti();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mint, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 20),
          const SizedBox(width: 8),
          Text(
            'Aktif karakterin bu',
            style: appText(weight: FontWeight.w800, color: AppColors.mintDark),
          ),
        ],
      ),
    );
  }
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
      vurgu: true,
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
