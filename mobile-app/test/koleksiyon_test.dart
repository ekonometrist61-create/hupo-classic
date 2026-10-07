// W2: koleksiyon ekranı — sınıf filtresi ve nadirlik rozetleri.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/character_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/collection_screen.dart';

CharacterCard _kart({
  required String kod,
  required KarakterSinifi sinif,
  required int karakterSira,
  bool kazanildi = true,
}) =>
    CharacterCard(
      kod: kod,
      ad: 'Test $kod',
      aciklama: 'Açıklama',
      ikon: 'placeholder.png',
      sinif: sinif,
      sinifSira: 1,
      karakterSira: karakterSira,
      kosulTuru: KosulTuru.xp,
      kosulDeger: 100,
      kazanildi: kazanildi,
    );

final _karakterler = [
  _kart(kod: 'siradan1', sinif: KarakterSinifi.ozgurRuhlar, karakterSira: 1),
  _kart(kod: 'mitik1', sinif: KarakterSinifi.ozgurRuhlar, karakterSira: 5),
  _kart(
    kod: 'epik1',
    sinif: KarakterSinifi.firtina,
    karakterSira: 3,
    kazanildi: false,
  ),
];

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(420, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myCharactersProvider.overrideWith((ref) async => _karakterler),
      ],
      child: const MaterialApp(home: CollectionScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('sınıf filtre çipleri bölümleri gösterir/gizler', (tester) async {
    await _pump(tester);

    // Başlangıçta: "Tümü" seçili, iki sınıf da görünür (çip + başlık).
    expect(find.text('Tümü'), findsOneWidget);
    expect(find.text('🦅 Özgür Ruhlar'), findsNWidgets(2));
    expect(find.text('🌪️ Fırtına'), findsNWidgets(2));

    final firtinaCipi = find.byKey(const ValueKey('sinif-cipi-firtina'));
    await tester.ensureVisible(firtinaCipi); // çip, dar ekranda yatay kaydırmada olabilir
    await tester.tap(firtinaCipi);
    await tester.pump();

    // Fırtına seçilince yalnızca onun bölümü kalır; Özgür Ruhlar çipi durur ama başlığı kaybolur.
    expect(find.text('🌪️ Fırtına'), findsNWidgets(2));
    expect(find.text('🦅 Özgür Ruhlar'), findsOneWidget);

    final tumuCipi = find.byKey(const ValueKey('sinif-cipi-tumu'));
    await tester.ensureVisible(tumuCipi);
    await tester.tap(tumuCipi);
    await tester.pump();
    expect(find.text('🦅 Özgür Ruhlar'), findsNWidgets(2));
  });

  testWidgets('kazanılmış karakterler nadirlik etiketi gösterir', (tester) async {
    await _pump(tester);

    expect(find.text('Sıradan'), findsOneWidget);
    expect(find.text('Mitik'), findsOneWidget);
    // Kilitli karakterde isim/nadirlik metni gösterilmez (gizem korunur).
    expect(find.text('Epik'), findsNothing);
  });

  testWidgets('karakter_sira doğru nadirliğe eşlenir', (tester) async {
    expect(KarakterNadirlik.fromSira(1), KarakterNadirlik.siradan);
    expect(KarakterNadirlik.fromSira(2), KarakterNadirlik.nadir);
    expect(KarakterNadirlik.fromSira(3), KarakterNadirlik.epik);
    expect(KarakterNadirlik.fromSira(4), KarakterNadirlik.efsanevi);
    expect(KarakterNadirlik.fromSira(5), KarakterNadirlik.mitik);
  });
}
