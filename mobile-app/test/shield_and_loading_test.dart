import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/widgets/hupo/hupo_loading.dart';
import 'package:ogrenci_hazirlik/widgets/shield_earned_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _shieldSource = StateProvider<int>((ref) => 0);

Widget _wrap(Widget child, {bool reduced = false}) => MaterialApp(
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: c!,
      ),
      home: Scaffold(body: child),
    );

Future<ProviderContainer> _pumpListener(
  WidgetTester tester, {
  required int startShields,
  Map<String, Object> stored = const {},
}) async {
  SharedPreferences.setMockInitialValues(stored);
  final prefs = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(const Size(420, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      currentUserIdProvider.overrideWithValue('u1'),
      _shieldSource.overrideWith((ref) => startShields),
      statsProvider.overrideWith(
        (ref) async => StudentStats(shields: ref.watch(_shieldSource)),
      ),
    ],
    child: _wrap(const ShieldCelebrationListener(child: Text('ana ekran')), reduced: true),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return ProviderScope.containerOf(tester.element(find.text('ana ekran')));
}

void main() {
  group('ShieldCelebrationListener kararı', () {
    test('kayıt yoksa kutlanmaz', () {
      expect(ShieldCelebrationListener.shouldCelebrate(storedShields: null, current: 1), isFalse);
    });
    test('artış kutlanır, aynı ya da azalış kutlanmaz', () {
      expect(ShieldCelebrationListener.shouldCelebrate(storedShields: 0, current: 1), isTrue);
      expect(ShieldCelebrationListener.shouldCelebrate(storedShields: 1, current: 1), isFalse);
      expect(ShieldCelebrationListener.shouldCelebrate(storedShields: 2, current: 1), isFalse);
    });
  });

  group('ShieldCelebrationListener', () {
    testWidgets('ilk açılışta sessizce kaydeder', (tester) async {
      await _pumpListener(tester, startShields: 1);
      expect(find.text('Seri kalkanı kazandın!'), findsNothing);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(ShieldCelebrationListener.storageKey('u1')), 1);
    });

    testWidgets('kalkan artınca Hupo kutlama penceresi açılır', (tester) async {
      final c = await _pumpListener(tester, startShields: 0, stored: {'shield_count_u1': 0});
      c.read(_shieldSource.notifier).state = 1;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Seri kalkanı kazandın!'), findsOneWidget);
      expect(find.textContaining('1 kalkanın var'), findsOneWidget);
      await tester.tap(find.text('Harika!'));
      await tester.pumpAndSettle();
      expect(find.text('Seri kalkanı kazandın!'), findsNothing);
    });
  });

  testWidgets('ShieldEarnedBanner metni gösterir', (tester) async {
    await tester.pumpWidget(_wrap(const ShieldEarnedBanner(compact: true), reduced: true));
    expect(find.text('Seri kalkanı kazandın!'), findsOneWidget);
  });

  group('HupoLoading', () {
    testWidgets('mesajı gösterir; hareket azaltılmışsa animasyon yok', (tester) async {
      await tester.pumpWidget(_wrap(const HupoLoading(), reduced: true));
      expect(find.text('Hupo senin için hazırlıyor…'), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
      // pumpAndSettle takılmaz
      await tester.pumpAndSettle();
    });

    testWidgets('hareket açıkken Hupo süzülür', (tester) async {
      await tester.pumpWidget(_wrap(const HupoLoading(message: 'Hupo soruları seçiyor…')));
      expect(find.text('Hupo soruları seçiyor…'), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('compact düzen çizilir', (tester) async {
      await tester.pumpWidget(_wrap(const HupoLoading(compact: true), reduced: true));
      expect(tester.takeException(), isNull);
    });
  });
}
