// Avatar önizleme üretici:
//   flutter test tool/avatar_previews_test.dart --update-goldens
// Çıktılar tool/previews/ klasörüne PNG olarak yazılır.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/avatar_models.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/evolving_avatar_widget.dart';
import 'package:ogrenci_hazirlik/widgets/hupo/hupo.dart';
import 'package:ogrenci_hazirlik/widgets/hupo/hupo_loading.dart';
import 'package:ogrenci_hazirlik/widgets/shield_earned_banner.dart';

Future<void> loadFonts() async {
  final nunito = FontLoader('Nunito')..addFont(rootBundle.load('assets/fonts/Nunito.ttf'));
  await nunito.load();
  final root = Platform.environment['FLUTTER_ROOT'] ?? 'C:/src/flutter';
  final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await iconLoader.load();
  }
}

const _bg = Color(0xFFF1EEFF);

Future<void> _pump(WidgetTester tester, Widget child, Size logical) async {
  tester.view.devicePixelRatio = 2.0;
  tester.view.physicalSize = logical * 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(fontFamily: 'Nunito'),
    home: Scaffold(
      backgroundColor: _bg,
      body: RepaintBoundary(key: const ValueKey('shot'), child: ColoredBox(color: _bg, child: Center(child: child))),
    ),
  ));
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(Scaffold));
    for (final p in HupoPose.values) {
      await precacheImage(AssetImage(p.assetPath), ctx);
    }
  });
  await tester.pump(const Duration(milliseconds: 1500));
}

Widget _labeled(AvatarTier t, double size, {bool label = true}) => Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EvolvingAvatarWidget(currentXP: 0, tier: t, size: size),
          if (label) Text(t.title, style: appText(size: 14, weight: FontWeight.w800)),
        ],
      ),
    );

void main() {
  setUpAll(loadFonts);

  Future<void> shot(WidgetTester tester, String name) =>
      expectLater(find.byKey(const ValueKey('shot')), matchesGoldenFile('previews/$name.png'));

  testWidgets('beş evre yan yana', (tester) async {
    await _pump(
      tester,
      Row(mainAxisSize: MainAxisSize.min, children: [for (final t in AvatarTier.values) _labeled(t, 150)]),
      const Size(880, 240),
    );
    await shot(tester, 'avatar_tiers');
  });

  for (final t in AvatarTier.values) {
    testWidgets('${t.name} 300', (tester) async {
      await _pump(tester, _labeled(t, 300, label: false), const Size(340, 340));
      await shot(tester, 'avatar_${t.name}_300');
    });
  }

  testWidgets('küçük boy 60', (tester) async {
    await _pump(
      tester,
      Row(mainAxisSize: MainAxisSize.min, children: [for (final t in AvatarTier.values) _labeled(t, 60, label: false)]),
      const Size(420, 90),
    );
    await shot(tester, 'avatar_small');
  });

  testWidgets('kalkan kutlaması ve yükleniyor', (tester) async {
    await _pump(
      tester,
      const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShieldEarnedBanner(shields: 1),
            SizedBox(height: 16),
            HupoLoading(message: 'Hupo senin için hazırlıyor…'),
          ],
        ),
      ),
      const Size(420, 420),
    );
    await shot(tester, 'kalkan_ve_yukleniyor');
  });
}
