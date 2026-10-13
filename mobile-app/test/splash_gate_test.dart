import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/screens/splash_screen.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/widgets/splash/hupo_signature_entrance.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SplashGate Riverpod (sharedPreferencesProvider / settingsProvider) ister.
/// [ilkAcilis] false ise ilk karşılama bayrağı işaretli (coldStart) gelir.
/// [azalt] true ise hareket azalt ayarı açık gelir (settings prefs üzerinden).
Future<Widget> _uygulama({
  bool ilkAcilis = true,
  bool azalt = false,
}) async {
  SharedPreferences.setMockInitialValues({
    if (!ilkAcilis) 'hupo_first_greeting_done': true,
    if (azalt) 'reduce_motion': true,
  });
  final prefs = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const MaterialApp(
      home: SplashGate(child: Scaffold(body: Text('asıl uygulama'))),
    ),
  );
}

void main() {
  testWidgets('açılış karşılaması üstte görünür, asıl uygulama altta hazırdır',
      (tester) async {
    await tester.pumpWidget(await _uygulama());
    await tester.pump();

    expect(find.text('asıl uygulama'), findsOneWidget);
    expect(find.byType(HupoSignatureEntrance), findsOneWidget);

    // Kapanmadan önce: karşılama hâlâ var.
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(HupoSignatureEntrance), findsOneWidget);

    // Sahne bitince solar (350 ms), sonra ağaçtan kalkar.
    await tester.pump(kSignatureEntranceDuration);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byType(HupoSignatureEntrance), findsNothing);
    expect(find.text('asıl uygulama'), findsOneWidget);
  });

  testWidgets('hareket azaltılmışsa karşılama anında kalkar, çökme olmaz',
      (tester) async {
    await tester.pumpWidget(await _uygulama(ilkAcilis: false, azalt: true));
    await tester.pump();
    // Hareket azalt: tam sahne oynatılmaz, yalnızca kısa statik karşılama.
    expect(find.byType(HupoSignatureEntrance), findsNothing);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.text('asıl uygulama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('karşılama kalkmadan sayfa kapanırsa zamanlayıcı sızmaz',
      (tester) async {
    await tester.pumpWidget(await _uygulama());
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });
}
