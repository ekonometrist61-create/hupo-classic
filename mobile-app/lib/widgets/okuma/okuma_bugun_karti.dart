import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/okuma_models.dart';
import '../../providers/okuma_providers.dart';
import '../../screens/okuma/okuduklarim_ekrani.dart';
import '../../screens/okuma/okuma_akis_ekrani.dart';
import '../../screens/okuma/okuma_tema.dart';
import '../../services/okuma_geri_donus.dart';
import '../../theme/app_theme.dart';
import '../hupo/hupo.dart';
import '../ui/chunky_button.dart';
import '../ui/game_card.dart';

/// Öğren sekmesi giriş kartı: "Bugünkü hikâye" + okuma serisi.
///
/// Hedef: çocuk tek dokunuşla bugünkü hikâyeye ulaşır. Ana eylem: "Hikâyeye başla".
/// Durumlar: bayrak kapalı / yükleniyor / hata → kart HİÇ görünmez; açık → öneri + seri;
/// bugünkü hak dolduysa sakin "yarın yeni hikâye" metni ve "Okuduklarım"; 3+ gün okunmadıysa
/// nazik geri dönüş mesajı (push yok). Sunucu kartı yalnız `okuma_ozellik_durumu.erisim` ile açar.
class OkumaBugunKarti extends ConsumerWidget {
  const OkumaBugunKarti({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Çıkışta kişisel okuma verilerini silen bekçi; kart görünmese de çalışır.
    ref.watch(okumaOturumBekciProvider);
    final ozellik = ref.watch(okumaOzellikProvider).valueOrNull;
    if (ozellik == null || !ozellik.erisim) return const SizedBox.shrink();

    final durum = ref.watch(okumaSeriOneriProvider).valueOrNull;
    final depo = ref.watch(okumaCihazDeposuProvider);
    final simdi = ref.watch(okumaSimdiProvider)();
    final son = depo.sonOkuma;
    final geriDonus = geriDonusGerekli(sonOkuma: son, simdi: simdi) ? geriDonusMetni(simdi.difference(son!).inDays) : null;

    final kotaDolu = durum?.kotaDolu ?? false;
    final oneri = kotaDolu ? null : durum?.oneri;
    final seri = durum?.seri;
    final String aciklama;
    if (kotaDolu) {
      aciklama = OkumaMetin.kartKotaDolu;
    } else if (geriDonus != null) {
      aciklama = geriDonus;
    } else if (oneri != null) {
      aciklama = oneri.baslik;
    } else {
      aciklama = OkumaMetin.kartAciklama;
    }

    void ac(OkumaKatalogSatiri? satir) {
      Navigator.of(context)
          .push<void>(MaterialPageRoute(builder: (_) => OkumaAkisEkrani(baslangicSatiri: satir)))
          .then((_) {
        // Okuma bitince seri ve öneri tazelensin.
        ref.invalidate(okumaSeriOneriProvider);
        ref.invalidate(okumaOkuduklarimProvider);
      });
    }

    void okuduklarim() {
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (ctx) => OkuduklarimEkrani(
            onAc: (satir) {
              Navigator.of(ctx).pop();
              ac(satir);
            },
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GameCard(
        key: const ValueKey('okuma-bugun-karti'),
        color: AppColors.primarySoft,
        borderColor: AppColors.primaryLight,
        onTap: kotaDolu ? okuduklarim : () => ac(oneri),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Hupo(pose: HupoPose.merakEdiyor, size: OkumaTema.hupoKart, semanticLabel: ''),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(OkumaMetin.kartBaslik, style: appText(size: 19, weight: FontWeight.w900)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        aciklama,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: appText(size: 15, color: AppColors.muted, height: 1.35),
                      ),
                      if (seri != null && seri.seriDevam && seri.seriSayisi > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 20, color: AppColors.coralDark),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                OkumaMetin.kartSeri(seri.seriSayisi),
                                style: appText(size: 14, weight: FontWeight.w800, color: AppColors.coralDark),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (kotaDolu)
              ChunkyButton.light(label: OkumaMetin.kartOkuduklarim, onPressed: okuduklarim)
            else
              ChunkyButton(label: OkumaMetin.kartBasla, onPressed: () => ac(oneri)),
          ],
        ),
      ),
    );
  }
}
