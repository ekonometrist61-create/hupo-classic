// Alt gezinmeli kabuk: sekmeler arası geçiş ve geri tuşu davranışı.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/root_shell.dart';

import '../tool/screen_previews_test.dart' show loadFonts, pumpScreen;

void main() {
  setUpAll(loadFonts);

  testWidgets('beş sekme var ve Öğren / Arena sekmeleri açılır', (tester) async {
    await pumpScreen(tester, const RootShell());

    for (final etiket in ['Ana Sayfa', 'Öğren', 'Arena', 'Koleksiyon', 'Profil']) {
      expect(find.text(etiket), findsWidgets, reason: etiket);
    }

    await tester.tap(find.widgetWithText(NavigationDestination, 'Öğren'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Çalışma araçların'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Arena'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Arkadaşına meydan oku'), findsOneWidget);
    expect(find.text('Yakında'), findsOneWidget);
  });

  testWidgets('sekme sağlayıcısı değişince kabuk o sekmeye geçer', (tester) async {
    await pumpScreen(tester, const RootShell());
    final container = ProviderScope.containerOf(tester.element(find.byType(RootShell)));

    container.read(shellTabProvider.notifier).state = 2;
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Ligde yüksel, günün meydan okumasını tamamla.'), findsOneWidget);
  });
}
