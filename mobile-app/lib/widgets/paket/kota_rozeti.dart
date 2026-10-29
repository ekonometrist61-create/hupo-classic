import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';

/// Bir modülün bugünkü ücretsiz hakkını gösteren küçük satır.
///
/// Kota yoksa (tam erişim, yükleme ya da hata) hiçbir şey göstermez: çocuğa yanlış bilgi verilmez.
/// Metin deneme kartıyla aynı tonda; satın alma ya da fiyat yok (K-0196).
class KotaRozeti extends ConsumerWidget {
  const KotaRozeti({super.key, required this.modul});

  /// Modül kodu (`my_kota_durumu` anahtarı), ör. 'kelime_evreni', 'deneme'.
  final String modul;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kota = ref.watch(kotaDurumuProvider).valueOrNull?[modul];
    if (kota == null) return const SizedBox.shrink();

    final metin = kota.kalan <= 0
        ? 'Bugünlük hakkın doldu. Yarın yeniden açılır.'
        : 'Bugün ${kota.kalan} hakkın kaldı.';

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        metin,
        style: appText(
          size: 13,
          weight: FontWeight.w800,
          color: kota.kalan <= 0 ? AppColors.muted : AppColors.primary,
        ),
      ),
    );
  }
}
