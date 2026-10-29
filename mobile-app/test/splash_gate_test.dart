import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/screens/splash_screen.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/services/app_open_service.dart';
import 'package:ogrenci_hazirlik/widgets/splash/hupo_giris_filmi.dart';
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
    expect(find.byType(HupoGirisFilmi), findsOneWidget);

    // Kapanmadan önce: karşılama hâlâ var.
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(HupoGirisFilmi), findsOneWidget);

    // Hazırlık + ses bekleme (≤ 1,85 sn), film süresi, solma (350 ms); sonra ağaçtan kalkar.
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(kHupoSahneToplam);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byType(HupoGirisFilmi), findsNothing);
    expect(find.text('asıl uygulama'), findsOneWidget);
  });

  testWidgets('hareket azaltılmışsa yalnız statik kare gösterilir, çökme olmaz',
      (tester) async {
    await tester.pumpWidget(await _uygulama(ilkAcilis: false, azalt: true));
    await tester.pump();
    // Hareket azalt: hareketli sahne yok; statik kare (Hupolingo) görünür.
    expect(find.text('Hupolingo'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.byType(HupoSignatureEntrance), findsNothing);
    expect(find.text('asıl uygulama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sonraki açılışta kısa sahne oynar ve 900 ms + perdede biter',
      (tester) async {
    await tester.pumpWidget(await _uygulama(ilkAcilis: false));
    await tester.pump();
    expect(find.byType(HupoSignatureEntrance), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byType(HupoSignatureEntrance), findsNothing);
    expect(find.text('asıl uygulama'), findsOneWidget);
  });

  testWidgets('dokunma 600 ms öncesinde sahneyi atlamaz, sonrasında atlar',
      (tester) async {
    await tester.pumpWidget(await _uygulama());
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(HupoGirisFilmi));
    await tester.pump(const Duration(milliseconds: 500));
    // Hâlâ oynuyor (eşik dolmadı).
    expect(find.byType(HupoGirisFilmi), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(HupoGirisFilmi));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byType(HupoGirisFilmi), findsNothing);
    expect(find.text('asıl uygulama'), findsOneWidget);
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
