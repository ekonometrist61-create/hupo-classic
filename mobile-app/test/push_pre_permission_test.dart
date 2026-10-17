import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/push/push_pre_permission.dart';
import 'package:ogrenci_hazirlik/widgets/hupo/hupo.dart';

void main() {
  /// Ön izin ekranını açar, verilen düğmeye basar ve kullanıcının seçimini döndürür.
  Future<bool?> secimYap(WidgetTester tester, String dugme) async {
    bool? sonuc;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => sonuc = await showPushPrePermission(context),
            child: const Text('aç'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(dugme));
    await tester.pumpAndSettle();
    return sonuc;
  }

  testWidgets('"Evet, haber versin" true döner', (tester) async {
    expect(await secimYap(tester, 'Evet, haber versin'), isTrue);
  });

  testWidgets('"Şimdilik değil" false döner (sistem izni istenmez)', (tester) async {
    expect(await secimYap(tester, 'Şimdilik değil'), isFalse);
  });

  testWidgets('ekranda Hupo maskotu ve iki eşit ağırlıkta düğme var', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showPushPrePermission(context),
            child: const Text('aç'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();

    expect(find.byType(Hupo), findsOneWidget);
    expect(find.text('Şimdilik değil'), findsOneWidget);
    expect(find.text('Evet, haber versin'), findsOneWidget);
    // Düğmeler eşit genişlikte olmalı (baskı yaratan büyük "Evet" yok).
    final evet = tester.getSize(find.widgetWithText(FilledButton, 'Evet, haber versin'));
    final sonra = tester.getSize(find.widgetWithText(OutlinedButton, 'Şimdilik değil'));
    expect((evet.width - sonra.width).abs() < 1, isTrue, reason: 'evet=${evet.width} sonra=${sonra.width}');
  });
}
