import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/paket_erisim_models.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../hupo/hupo.dart';
import '../ui/game_card.dart';

/// Çocuk yüzeyinde modül kapısı (`my_access` üzerinden).
///
/// * Erişim yeterliyse [child] gösterilir.
/// * Erişim yoksa ya da yükleme hatalıysa kilitli kart çıkar. Kart satın alma, fiyat ya da
///   dış bağlantı içermez (K-0196, GÖR-081): çocuk ekranında ödeme yönlendirmesi yok.
/// * Yükleme sürerken hiçbir içerik gösterilmez (fail-closed).
///
/// Route kökünde kullanılır: kilitli ve yükleme durumları kendi Scaffold'unu getirir (geri tuşu için).
class ModulKapisi extends ConsumerWidget {
  const ModulKapisi({
    super.key,
    required this.modul,
    required this.gereken,
    required this.child,
  });

  /// Modül kodu (`my_access` anahtarı), ör. 'kelime_evreni', 'deneme'.
  final String modul;

  /// Bu ekran için gereken en düşük seviye.
  final ModulErisimSeviyesi gereken;

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final erisim = ref.watch(modulErisimProvider);
    return erisim.when(
      loading: () => const _KapiIskelet(child: CircularProgressIndicator()),
      error: (_, __) => const _KapiIskelet(child: _KilitliKart()),
      data: (harita) {
        final kayit = harita[modul] ?? ModulErisim.kapali;
        return kayit.yeterli(gereken) ? child : const _KapiIskelet(child: _KilitliKart());
      },
    );
  }
}

/// Kapı durumları için iskelet: geri tuşlu başlık çubuğu ve ortalanmış içerik.
class _KapiIskelet extends StatelessWidget {
  const _KapiIskelet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: child),
    );
  }
}

class _KilitliKart extends StatelessWidget {
  const _KilitliKart();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GameCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Hupo(pose: HupoPose.merakEdiyor, size: 72),
            const SizedBox(height: 12),
            Text(
              'Bu bölüm şu an açık değil',
              textAlign: TextAlign.center,
              style: appText(size: 18, weight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Tekrar listen ve temel derslerin açık. Bu bölüm için veli panelinden devam edebilirsin.',
              textAlign: TextAlign.center,
              style: appText(size: 14, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
