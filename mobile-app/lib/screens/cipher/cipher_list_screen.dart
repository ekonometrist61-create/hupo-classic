// Çarpım Tablosu Şifreleri liste ekranı.
//
// Şifrelerin listelendiği, ilerlemenin ve kazanılan unvanların takip edildiği ekran.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cipher_models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/haptics.dart';
import '../../widgets/cipher_icons.dart';
import '../../widgets/ui/chunky_button.dart';
import '../../widgets/ui/game_card.dart';
import '../../widgets/ui/responsive_page.dart';
import 'cipher_lesson_screen.dart';
import 'genel_alistirma_screen.dart';

class CipherListScreen extends ConsumerWidget {
  const CipherListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ciphersAsync = ref.watch(ciphersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Çarpım Tablosu Şifreleri',
          style:
              appText(size: 18, weight: FontWeight.w800, color: AppColors.ink),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _GenelAlistirmaCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const GenelAlistirmaScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Şifreleri çöz, çarpım tablosunu ustaca öğren!',
                style: appText(
                    size: 15, weight: FontWeight.w600, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ciphersAsync.when(
                  data: (ciphers) {
                    if (ciphers.isEmpty) {
                      return Center(
                        child: Text(
                          'Şifreler hazırlanıyor...',
                          style: appText(size: 14, color: AppColors.muted),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: ciphers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, idx) {
                        final cipher = ciphers[idx];
                        return _CipherTile(cipher: cipher);
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Şifreler yüklenemedi, birazdan tekrar deneyelim.',
                          style: appText(size: 14, color: AppColors.coral),
                        ),
                        const SizedBox(height: 12),
                        ChunkyButton(
                          label: 'Tekrar Dene',
                          icon: Icons.refresh_rounded,
                          color: AppColors.primary,
                          shadowColor: AppColors.primaryDark,
                          onPressed: () => ref.invalidate(ciphersProvider),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenelAlistirmaCard extends StatelessWidget {
  const _GenelAlistirmaCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GameCard(
      color: AppColors.primarySoft,
      borderColor: AppColors.primary,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flash_on_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Genel Çarpım Tablosu Alıştırması',
                  style: appText(
                      size: 16, weight: FontWeight.w800, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                Text(
                  'İstediğin tabloyu seç, hızlıca pratik yap!',
                  style: appText(size: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _CipherTile extends StatelessWidget {
  const _CipherTile({required this.cipher});

  final MathCipher cipher;

  @override
  Widget build(BuildContext context) {
    Color hexColor;
    try {
      hexColor = Color(int.parse(cipher.renk.replaceAll('#', '0xFF')));
    } catch (_) {
      hexColor = AppColors.primary;
    }

    return GameCard(
      onTap: () {
        AppHaptics.light();
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => CipherLessonScreen(sifreId: cipher.id)),
        );
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hexColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(cipherIcon(cipher.ikon), color: hexColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cipher.isim,
                      style: appText(
                          size: 16,
                          weight: FontWeight.w800,
                          color: AppColors.ink),
                    ),
                    const SizedBox(width: 8),
                    if (cipher.isCompleted)
                      const Icon(Icons.check_circle_rounded,
                          size: 16, color: AppColors.mint)
                    else if (cipher.isExerciseCompleted)
                      const Icon(Icons.star_rounded,
                          size: 16, color: AppColors.sunDark),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cipher.kapsam,
                  style: appText(size: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: AppColors.muted),
        ],
      ),
    );
  }
}
