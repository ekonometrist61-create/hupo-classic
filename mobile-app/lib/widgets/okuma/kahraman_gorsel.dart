// Okuma Dünyası: manifestten karakter görseli yükleyici ve küçük görsel bileşeni.
// Görsel yoksa ya da yüklenemezse çağıranın verdiği yedek (ikon) gösterilir; emoji/rastgele yedek yok.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/okuma_varlik.dart';

Future<OkumaVarlikKatalogu>? _onbellek;

Future<Map<String, dynamic>?> _oku(String yol) async {
  try {
    final ham = json.decode(await rootBundle.loadString(yol));
    return ham is Map<String, dynamic> ? ham : null;
  } catch (_) {
    return null;
  }
}

/// Katalog bir kez yüklenir; hata halinde boş katalog döner.
Future<OkumaVarlikKatalogu> okumaVarlikKatalogu() => _onbellek ??= () async {
      final k = await _oku(kKarakterManifestYolu);
      final i = await _oku(kIkonManifestYolu);
      return OkumaVarlikKatalogu.coz(k, i);
    }();

/// Test için önbelleği sıfırlar.
void okumaVarlikOnbelleginiSifirla() => _onbellek = null;

/// Kahraman türü için üretilmiş karakter görseli; yoksa [yedek].
/// Görsel dekoratiftir (kartın Semantics etiketi bilgiyi taşır).
class KahramanGorsel extends StatelessWidget {
  const KahramanGorsel({super.key, required this.turKodu, required this.boyut, required this.yedek});

  final String turKodu;
  final double boyut;
  final Widget yedek;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OkumaVarlikKatalogu>(
      future: okumaVarlikKatalogu(),
      builder: (context, an) {
        final v = an.data?.kartGorseli(turKodu);
        if (v == null) return yedek;
        return Image.asset(
          v.varlikYolu,
          width: boyut,
          height: boyut,
          fit: BoxFit.contain,
          cacheWidth: (boyut * MediaQuery.devicePixelRatioOf(context)).round(),
          excludeFromSemantics: true,
          errorBuilder: (_, __, ___) => yedek,
        );
      },
    );
  }
}
