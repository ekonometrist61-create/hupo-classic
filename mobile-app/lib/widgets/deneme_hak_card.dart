import 'package:flutter/material.dart';

import '../models/deneme_hak_models.dart';
import '../theme/app_theme.dart';
import 'hupo/hupo.dart';
import 'ui/game_card.dart';

/// Profilde "Ücretsiz deneme" kartı (çocuk yüzeyi, nötr ton).
///
/// Deneme aktifken: kalan gün ve sınırda olan (kalan ≤ 5) özellikler.
/// Deneme bitince: ilerlemenin açık kaldığı ve deneme sınavlarının kapandığı bilgisi.
/// Satın alma düğmesi yoktur (çocuk güvenliği; bkz. membership_card.dart).
class DenemeHakCard extends StatelessWidget {
  const DenemeHakCard({super.key, required this.durum});

  final DenemeHak durum;

  @override
  Widget build(BuildContext context) {
    if (durum.deneme) return _Aktif(durum: durum);
    if (durum.bitti) return const _Bitti();
    return const SizedBox.shrink();
  }
}

class _Aktif extends StatelessWidget {
  const _Aktif({required this.durum});

  final DenemeHak durum;

  String _satir(DenemeOzellik o) {
    if (o.kalan <= 0) {
      return o.gunluk
          ? 'Bugünlük ${o.etiket} hakkın doldu. Yarın yeniden açılır. Tekrar listen açık.'
          : 'Bu denemedeki ${o.etiket} hakkın doldu. Tekrar listen açık, oradan devam edebilirsin.';
    }
    return o.gunluk
        ? 'Bugün ${o.etiket}: ${o.kalan} hakkın kaldı.'
        : 'Bu denemede ${o.etiket}: ${o.kalan} hakkın kaldı.';
  }

  @override
  Widget build(BuildContext context) {
    final kalan = durum.kalanGun;
    final sinirda = durum.sayacGoster;
    return GameCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Hupo(pose: HupoPose.harika, size: 72),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ücretsiz deneme',
                    style: appText(size: 13, weight: FontWeight.w800, color: AppColors.muted)),
                Text(
                  kalan != null ? 'Denemen $kalan gün daha açık' : 'Denemen açık',
                  style: appText(size: 20, weight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Denemen sırasında her özelliği sınırlı sayıda kullanabilirsin.',
                  style: appText(size: 14, weight: FontWeight.w700),
                ),
                for (final o in sinirda) ...[
                  const SizedBox(height: 6),
                  Text(
                    _satir(o),
                    style: appText(size: 14, weight: FontWeight.w800, color: AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bitti extends StatelessWidget {
  const _Bitti();

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Hupo(pose: HupoPose.merakEdiyor, size: 72),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ücretsiz deneme',
                    style: appText(size: 13, weight: FontWeight.w800, color: AppColors.muted)),
                Text('Denemen bitti', style: appText(size: 20, weight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(
                  'Tekrar listen ve temel derslerin açık. Deneme sınavları şimdi kapalı.',
                  style: appText(size: 14, weight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
