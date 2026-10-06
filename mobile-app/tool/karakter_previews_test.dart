// Karakter görseli önizleme üretici (kilitli silüet, vurgulu silüet, kazanılmış):
//   flutter test tool/karakter_previews_test.dart --update-goldens
// Çıktı: tool/previews/karakterler_*.png
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/character_models.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/widgets/character/character_art.dart';

Future<void> _yaziTipleri() async {
  final nunito = FontLoader('Nunito')..addFont(rootBundle.load('assets/fonts/Nunito.ttf'));
  await nunito.load();
  final root = Platform.environment['FLUTTER_ROOT'] ?? 'C:/src/flutter';
  final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

/// Her sınıftan alfabetik ilk karakter dosyası.
List<CharacterCard> _ornekler({required bool kazanildi}) {
  final kok = Directory('assets/characters');
  final sonuc = <CharacterCard>[];
  var sira = 0;
  for (final sinif in KarakterSinifi.values) {
    final dizin = Directory('${kok.path}/${sinif.kod}');
    if (!dizin.existsSync()) continue;
    final dosyalar = dizin
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.webp'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    if (dosyalar.isEmpty) continue;
    final ad = dosyalar.first.uri.pathSegments.last.replaceAll('.webp', '');
    sonuc.add(CharacterCard(
      kod: ad,
      ad: ad,
      aciklama: '',
      ikon: '$ad.png',
      sinif: sinif,
      sinifSira: sira++,
      karakterSira: 1,
      kosulTuru: KosulTuru.xp,
      kosulDeger: 100,
      kazanildi: kazanildi,
    ));
  }
  return sonuc;
}

const _krem = Color(0xFFFFF9ED);

void main() {
  setUpAll(_yaziTipleri);

  Future<void> cek(WidgetTester tester, Widget govde, String ad, {Duration ileri = Duration.zero}) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(1000, 760) * 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Scaffold(
        backgroundColor: _krem,
        body: RepaintBoundary(
          key: const ValueKey('shot'),
          child: ColoredBox(color: _krem, child: Center(child: govde)),
        ),
      ),
    ));
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(Scaffold));
      for (final k in [..._ornekler(kazanildi: false)]) {
        await precacheImage(AssetImage(k.assetPath), ctx);
      }
    });
    await tester.pump(const Duration(milliseconds: 300));
    if (ileri > Duration.zero) await tester.pump(ileri);
    await expectLater(find.byKey(const ValueKey('shot')), matchesGoldenFile('previews/$ad.png'));
  }

  Widget satir(String baslik, List<CharacterCard> k, {bool vurgu = false, double boyut = 104}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: appText(size: 14, weight: FontWeight.w900)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [for (final c in k) KarakterGorseli(karakter: c, boyut: boyut, vurgu: vurgu)],
            ),
          ],
        ),
      );

  testWidgets('kilitli silüet, vurgulu silüet ve kazanılmış karakterler', (tester) async {
    await cek(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          satir('Kazanılmış', _ornekler(kazanildi: true)),
          satir('Kilitli (liste)', _ornekler(kazanildi: false)),
          satir('Kilitli, sıradaki hedef (vurgulu)', _ornekler(kazanildi: false).take(4).toList(), vurgu: true, boyut: 150),
        ],
      ),
      'karakterler_silüet'.replaceAll('ü', 'u'),
      ileri: const Duration(milliseconds: 2500),
    );
  });
}
