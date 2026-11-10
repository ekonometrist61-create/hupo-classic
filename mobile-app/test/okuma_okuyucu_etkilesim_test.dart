// Okuyucu etkileşimi: kelime paneli gerçek okuyucu içinden açılıp kapanır; uzun sayfada otomatik
// kaydırma kullanıcının kendi kaydırmasını engellemez.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart' show currentUserIdProvider;
import 'package:ogrenci_hazirlik/providers/okuma_providers.dart' show okumaCikisAkisiProvider;
import 'package:ogrenci_hazirlik/screens/okuma/okuyucu_ekrani.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:okuma_motoru/okuma_motoru.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kisaSayfalar = <List<Cikti>>[
  [
    Cikti('Ece sabah erkenden kalktı. Bahçedeki ', Stil.normal),
    Cikti('uzun', Stil.kelime),
    Cikti(' gölgeyi görünce çok şaşırdı.', Stil.normal),
  ],
];

final _uzunSayfalar = <List<Cikti>>[
  [for (var i = 0; i < 60; i++) Cikti('Ece bahçede yürüdü ve gölgeyi izledi $i. ', Stil.normal)],
];

Future<void> _okuyucuAc(WidgetTester tester, List<List<Cikti>> sayfalar) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      currentUserIdProvider.overrideWithValue('u1'),
      okumaCikisAkisiProvider.overrideWithValue(const Stream<void>.empty()),
    ],
    child: MaterialApp(
      theme: buildAppTheme(),
      home: OkuyucuEkrani(
        sayfalar: sayfalar,
        anlamlar: const {'uzun': 'Boyu çok olan.'},
        onBitti: () {},
        baslik: 'Test',
        onGeri: () {},
        tur: 'gizem',
      ),
    ),
  ));
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  setUpAll(() async {
    final yukle = FontLoader('Nunito')
      ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Nunito.ttf').readAsBytesSync())));
    await yukle.load();
  });

  testWidgets('kelime paneli okuyucudan açılır ve kapat simgesiyle kapanır', (tester) async {
    await _okuyucuAc(tester, _kisaSayfalar);

    // "uzun" kelimesinin ekrandaki merkezine dokun.
    final rt = tester.renderObject<RenderParagraph>(
        find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('uzun')));
    final metin = rt.text.toPlainText();
    final baslangic = metin.indexOf('uzun');
    final kutu = rt.getBoxesForSelection(TextSelection(baseOffset: baslangic, extentOffset: baslangic + 4)).first;
    await tester.tapAt(rt.localToGlobal(kutu.toRect().center));
    await tester.pumpAndSettle();
    expect(find.text('Boyu çok olan.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Boyu çok olan.'), findsNothing);
  });

  testWidgets('uzun sayfada otomatik kaydırma sonrası kullanıcı yukarı kaydırabilir', (tester) async {
    await _okuyucuAc(tester, _uzunSayfalar);

    final liste = find.byType(ListView).first;
    final pozisyon = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
    expect(pozisyon.maxScrollExtent, greaterThan(0), reason: 'sayfa taşmalı');

    // Zamanlayıcı (3 sn) ve animasyon ayrı karelerde ilerlesin.
    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pump(const Duration(milliseconds: 2000));
    expect(pozisyon.pixels, greaterThan(0), reason: 'otomatik kayma başlamalı');

    // Kullanıcı aşağı kaydırır: otomatik kaydırma bu dokunuşla durmalı.
    await tester.drag(liste, const Offset(0, -3000));
    await tester.pumpAndSettle();
    final altta = pozisyon.pixels;
    expect(altta, greaterThan(300));

    // Kullanıcı yukarı kaydırır: piksel azalmalı.
    await tester.drag(liste, const Offset(0, 300));
    await tester.pump(const Duration(milliseconds: 500));
    expect(pozisyon.pixels, lessThan(altta - 100), reason: 'kullanıcı geri kaydırabilmeli');
  });
}
