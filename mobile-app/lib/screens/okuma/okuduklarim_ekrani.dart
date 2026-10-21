import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/okuma_models.dart';
import '../../providers/okuma_providers.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import 'okuma_tema.dart';

/// Kişisel raf. İki sekme: "Okuduklarım" (bitirilen hikâyeler) ve "Sözlüğüm" (Düşün bölümünden
/// eklenen atasözleri). Hedef: çocuk bitirdiklerini ve öğrendiklerini bir yerde görür; dilerse
/// hikâyeyi yeniden okur. Rozet, sıralama, sayı ve baskı yoktur. Kayıt yalnız bu cihazdadır
/// (hesaba bağlı, çıkışta silinir). Durumlar: dolu liste, boş raf (davet).
class OkuduklarimEkrani extends ConsumerStatefulWidget {
  const OkuduklarimEkrani({super.key, required this.onAc});

  /// Hikâyeyi yeniden oku. Ekranı kapatmak çağıranın işidir.
  final void Function(OkumaKatalogSatiri satir) onAc;

  @override
  ConsumerState<OkuduklarimEkrani> createState() => _OkuduklarimEkraniState();
}

class _OkuduklarimEkraniState extends ConsumerState<OkuduklarimEkrani> {
  bool _sozlukte = false;

  @override
  Widget build(BuildContext context) {
    return OkumaEkranIskeleti(
      baslik: OkumaMetin.okuduklarimBaslik,
      geri: () => Navigator.of(context).maybePop(),
      icerik: [
        Wrap(
          spacing: OkumaTema.bosluk8,
          runSpacing: OkumaTema.bosluk8,
          children: [
            ChoiceChip(
              label: const Text(OkumaMetin.okuduklarimSekme),
              selected: !_sozlukte,
              onSelected: (_) => setState(() => _sozlukte = false),
            ),
            ChoiceChip(
              label: const Text(OkumaMetin.sozlugumSekme),
              selected: _sozlukte,
              onSelected: (_) => setState(() => _sozlukte = true),
            ),
          ],
        ),
        const SizedBox(height: OkumaTema.bosluk16),
        if (_sozlukte) ..._sozlugum() else ..._okuduklarim(),
      ],
    );
  }

  List<Widget> _okuduklarim() {
    final liste = ref.watch(okumaOkuduklarimProvider);
    if (liste.isEmpty) {
      return [
        DurumEkrani(
          poz: HupoPose.merakEdiyor,
          baslik: OkumaMetin.okuduklarimBos,
          birincilEtiket: OkumaMetin.hikayelereDon,
          birincil: () => Navigator.of(context).maybePop(),
        ),
      ];
    }
    return [
      Text(
        OkumaMetin.okuduklarimAlt,
        style: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, satir: 1.4),
      ),
      const SizedBox(height: OkumaTema.bosluk16),
      for (final o in liste)
        Padding(
          padding: const EdgeInsets.only(bottom: OkumaTema.bosluk12),
          child: OkumaKart(
            etiket: '${o.satir.baslik}. ${OkumaMetin.okuduklarimTekrar}.',
            onTap: () => widget.onAc(o.satir),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: OkumaTema.mintDark, size: OkumaTema.ikonBuyuk - 12),
                const SizedBox(width: OkumaTema.bosluk12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.satir.baslik,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OkumaTema.yazi(OkumaTema.yaziSecenek, kalinlik: OkumaTema.kalinlikVurgu, satir: 1.25),
                      ),
                      Text(
                        _tarih(o.okunduAt),
                        style: OkumaTema.yazi(OkumaTema.yaziEtiket, renk: OkumaTema.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: OkumaTema.bosluk8),
                const Icon(Icons.replay_rounded, color: OkumaTema.primary),
              ],
            ),
          ),
        ),
    ];
  }

  List<Widget> _sozlugum() {
    final liste = ref.watch(okumaSozlugumProvider);
    if (liste.isEmpty) {
      return [
        DurumEkrani(
          poz: HupoPose.merakEdiyor,
          baslik: OkumaMetin.sozlugumBos,
          birincilEtiket: OkumaMetin.hikayelereDon,
          birincil: () => Navigator.of(context).maybePop(),
        ),
      ];
    }
    return [
      Text(
        OkumaMetin.sozlugumAlt,
        style: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, satir: 1.4),
      ),
      const SizedBox(height: OkumaTema.bosluk16),
      for (final k in liste)
        Padding(
          padding: const EdgeInsets.only(bottom: OkumaTema.bosluk12),
          child: OkumaKart(
            etiket: '${k.metin}. ${k.anlam}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“${k.metin}”',
                  style: OkumaTema.yazi(OkumaTema.yaziSecenek, kalinlik: OkumaTema.kalinlikVurgu, satir: 1.3)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: OkumaTema.bosluk4),
                Text(
                  k.anlam,
                  style: OkumaTema.yazi(OkumaTema.yaziYardimci, satir: 1.4),
                ),
                const SizedBox(height: OkumaTema.bosluk4),
                Text(
                  _tarih(k.at),
                  style: OkumaTema.yazi(OkumaTema.yaziEtiket, renk: OkumaTema.muted),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  static String _tarih(DateTime t) => '${t.day}.${t.month}.${t.year}';
}
