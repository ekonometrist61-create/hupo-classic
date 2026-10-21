// Okuma Dünyası: varlık manifesti çözümleme ve yedek davranışı.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_varlik.dart';

Map<String, dynamic> _json(String yol) => json.decode(File(yol).readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('gerçek manifestler çözülür; kimlikler benzersiz, dosyalar kurala uygun', () {
    final k = _json('assets/okuma/karakter_manifest.json');
    final i = _json('assets/okuma/ikon_manifest.json');
    final kat = OkumaVarlikKatalogu.coz(k, i);
    expect(kat.karakterler.length, (k['karakterler'] as List).length, reason: 'bozuk satır yok');
    expect(kat.ikonlar.length, (i['ikonlar'] as List).length);
    expect(kat.karakterler.length, greaterThanOrEqualTo(24));
    expect(kat.ikonlar.length, greaterThanOrEqualTo(80));
    expect({for (final x in kat.karakterler) x.id}.length, kat.karakterler.length);
    expect({for (final x in kat.ikonlar) x.id}.length, kat.ikonlar.length);
    for (final x in kat.karakterler) {
      expect(x.dosya, startsWith('karakterler/karakter_'));
      expect(x.sinifMin <= x.sinifMax, isTrue);
      // Üretildi diye işaretlenen her varlığın dosyası gerçekten var olmalı.
      if (x.uretildi) expect(File('assets/okuma/${x.dosya}').existsSync(), isTrue, reason: x.id);
    }
    for (final x in kat.ikonlar) {
      if (x.uretildi) expect(File('assets/okuma/${x.dosya}').existsSync(), isTrue, reason: x.id);
    }
  });

  test('üretilmemiş varlık için kart görseli null (yedek ikon kullanılır)', () {
    final kat = OkumaVarlikKatalogu.coz(
      {
        'karakterler': [
          {'id': 'a', 'kategori': 'insan', 'etiket': 'A', 'sinifMin': 2, 'sinifMax': 4, 'dosya': 'karakterler/a.webp', 'uretildi': false, 'kartTuru': 'ben'},
          {'id': 'b', 'kategori': 'insan', 'etiket': 'B', 'sinifMin': 2, 'sinifMax': 4, 'dosya': 'karakterler/b.webp', 'uretildi': true, 'kartTuru': 'anne'},
          'bozuk',
        ],
      },
      null,
    );
    expect(kat.karakterler.length, 2);
    expect(kat.kartGorseli('ben'), isNull);
    expect(kat.kartGorseli('anne')?.id, 'b');
    expect(OkumaVarlikKatalogu.coz(null, null).karakterler, isEmpty);
  });
}
