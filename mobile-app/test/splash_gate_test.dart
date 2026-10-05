import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/screens/splash_screen.dart';

Widget _uygulama({bool azalt = false}) => MaterialApp(
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: azalt),
        child: c!,
      ),
      home: const SplashGate(child: Scaffold(body: Text('asıl uygulama'))),
    );

void main() {
  testWidgets('açılış karşılaması üstte görünür, asıl uygulama altta hazırdır', (tester) async {
    await tester.pumpWidget(_uygulama());

    expect(find.text('asıl uygulama'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Kapanmadan önce: karşılama hâlâ var.
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(Image), findsOneWidget);

    // 1500ms sonra solmaya başlar, solma bitince ağaçtan kalkar.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(Image), findsNothing);
    expect(find.text('asıl uygulama'), findsOneWidget);
  });

  testWidgets('hareket azaltılmışsa karşılama anında kalkar, çökme olmaz', (tester) async {
    await tester.pumpWidget(_uygulama(azalt: true));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('karşılama kalkmadan sayfa kapanırsa zamanlayıcı sızmaz', (tester) async {
    await tester.pumpWidget(_uygulama());
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });
}
