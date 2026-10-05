import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/character_models.dart';
import 'package:ogrenci_hazirlik/widgets/character/character_art.dart';

// Sunucudaki 40 karakterlik tohum verisi: ('kod', 'ad', 'aciklama', 'ikon', 'sinif', ...)
final _tohumSatiri = RegExp(r"'([a-z_]+\.png)',\s*'([a-z_]+)',\s*(\d),\s*(\d),");

CharacterCard _kart(String ikon, String sinif, int sira, {bool kazanildi = true}) =>
    CharacterCard(
      kod: ikon,
      ad: 'Deneme',
      aciklama: 'Deneme',
      ikon: ikon,
      sinif: KarakterSinifi.fromKod(sinif),
      sinifSira: 1,
      karakterSira: sira,
      kosulTuru: KosulTuru.xp,
      kosulDeger: 10,
      kazanildi: kazanildi,
    );

List<CharacterCard> _tohumKartlari() {
  final sql = File('../supabase/migrations/20260928000010_character_system.sql')
      .readAsStringSync();
  return [
    for (final m in _tohumSatiri.allMatches(sql))
      _kart(m.group(1)!, m.group(2)!, int.parse(m.group(4)!)),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SQL tohumunda 8 sınıf x 5 = 40 karakter var', () {
    final kartlar = _tohumKartlari();
    expect(kartlar, hasLength(40));
    for (final sinif in KarakterSinifi.values) {
      expect(kartlar.where((k) => k.sinif == sinif), hasLength(5), reason: sinif.kod);
    }
  });

  test('assetPath sınıf klasörünü ve .webp uzantısını üretir', () {
    final k = _kart('ozgur_ruh.png', 'ozgur_ruhlar', 1);
    expect(k.assetPath, 'assets/characters/ozgur_ruhlar/ozgur_ruh.webp');
  });

  test('her karakterin görseli pakette var ve boş değil', () async {
    for (final k in _tohumKartlari()) {
      final data = await rootBundle.load(k.assetPath);
      expect(data.lengthInBytes, greaterThan(10000), reason: k.assetPath);
    }
  });

  testWidgets('açık ve kilitli karakter görseli hatasız çizilir', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              KarakterGorseli(
                karakter: _kart('oba_muhafizi.png', 'ozgur_ruhlar', 5),
                boyut: 120,
              ),
              KarakterGorseli(
                karakter: _kart('oba_muhafizi.png', 'ozgur_ruhlar', 5, kazanildi: false),
                boyut: 120,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
