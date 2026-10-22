// Hikâye paketinin içindeki sözlük (hikâyeye özgü anlamlar) uygulamaya ulaşır ve kelime dokununca gösterilir.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/okuma_sozluk.dart';
import 'package:okuma_motoru/okuma_motoru.dart' show Stil;

import 'package:ogrenci_hazirlik/models/okuma_models.dart';

void main() {
  test('derlenmiş paket: sözlük anlamları çıkar ve sayfa kelimeleri anlamla eşleşir', () {
    final ham = jsonDecode(File('test/fixtures/okuma/hr002.paket.json').readAsStringSync()) as Map<String, dynamic>;
    final paket = OkumaPaketi(
      hikayeId: 'test',
      surumId: 'test',
      surum: 1,
      sha256: 'test',
      minMotorSurumu: 1,
      paket: ham,
    );

    final sozluk = okumaSozluguKur(paket);
    expect(sozluk.anlamlar, isNotEmpty, reason: 'paketteki sözlük anlamları okunmadı');

    // Sayfalardaki kelime parçalarının hepsinin bir anlamı olmalı.
    final kelimeler = {
      for (final sayfa in okumaSayfalariniCoz(paket, sozluk, kahramanAdi: 'Ece', kahramanTuru: 'ben'))
        for (final c in sayfa)
          if (c.stil == Stil.kelime || c.stil == Stil.deyim) c.metin,
    };
    expect(kelimeler, isNotEmpty);
    for (final k in kelimeler) {
      expect(sozluk.anlamlar[k], isNotNull, reason: '"$k" için anlam yok');
    }
  });
}
