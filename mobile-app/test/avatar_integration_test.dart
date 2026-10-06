import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/avatar_models.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/avatar_progress_card.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/evolving_avatar_widget.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/tier_celebration_listener.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/tier_up_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _card(int xp) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: AvatarProgressCard(currentXP: xp))),
    );

/// Testte XP'yi değiştirmek için kaynak.
final _xpSource = StateProvider<int>((ref) => 0);

Future<SharedPreferences> _prefs([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return SharedPreferences.getInstance();
}

Future<ProviderContainer> _pumpListener(
  WidgetTester tester, {
  required int startXp,
  Map<String, Object> stored = const {},
  bool reduceMotion = false,
}) async {
  final prefs = await _prefs(stored);
  await tester.binding.setSurfaceSize(const Size(420, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      currentUserIdProvider.overrideWithValue('u1'),
      _xpSource.overrideWith((ref) => startXp),
      statsProvider.overrideWith(
        (ref) async => StudentStats(xp: ref.watch(_xpSource)),
      ),
    ],
    child: MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: const TierCelebrationListener(child: Scaffold(body: Text('ana ekran'))),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  return ProviderScope.containerOf(tester.element(find.text('ana ekran')));
}

Future<void> _setXp(WidgetTester tester, ProviderContainer c, int xp) async {
  c.read(_xpSource.notifier).state = xp;
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  // Pencere, çizim sonrası açılır; açılış animasyonu (350 ms) bitene kadar kare çiz.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  group('AvatarProgressCard', () {
    testWidgets('unvan, evre, XP aralığı ve dinamik motivasyon metni', (tester) async {
      await tester.pumpWidget(_card(3000));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Akıncı'), findsOneWidget);
      expect(find.text('Evre 3/5'), findsOneWidget);
      expect(find.text('3000 XP'), findsOneWidget);
      expect(find.text('3500 XP'), findsOneWidget);
      expect(
        find.text('Siber Yeniçeri olmana ve Neon Siperlik açmana sadece 500 XP kaldı!'),
        findsOneWidget,
      );
      expect(find.byType(EvolvingAvatarWidget), findsOneWidget);
    });

    testWidgets('ilerleme çubuğu evre içi oranı gösterir', (tester) async {
      await tester.pumpWidget(_card(3000));
      await tester.pump(const Duration(seconds: 1));
      final bar = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(bar.value, closeTo(0.75, 1e-9));
    });

    testWidgets('kalan XP, XP arttıkça anında güncellenir', (tester) async {
      await tester.pumpWidget(_card(1400));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('sadece 100 XP kaldı'), findsOneWidget);

      await tester.pumpWidget(_card(1450));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('sadece 50 XP kaldı'), findsOneWidget);
    });

    testWidgets('yeni evreye geçince unvan ve hedef değişir', (tester) async {
      await tester.pumpWidget(_card(1499));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Genç Kemankeş'), findsOneWidget);

      await tester.pumpWidget(_card(1500));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Akıncı'), findsOneWidget);
      expect(find.text('3500 XP'), findsOneWidget);
    });

    testWidgets('en üst evrede "Zirve" ve tam çubuk', (tester) async {
      await tester.pumpWidget(_card(9000));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Efsanevi Anka'), findsOneWidget);
      expect(find.text('Zirve'), findsOneWidget);
      expect(find.text('Zirvedesin! Efsanevi Anka unvanı sonsuza kadar senin.'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(bar.value, 1);
    });
  });

  group('Kutlama kararı (saf mantık)', () {
    test('kayıt yoksa kutlama yapılmaz', () {
      expect(
        TierCelebrationListener.tierToCelebrate(storedTierIndex: null, current: AvatarTier.altin),
        isNull,
      );
    });

    test('yükselme kutlanır; aynı veya alt evre kutlanmaz', () {
      expect(
        TierCelebrationListener.tierToCelebrate(storedTierIndex: 1, current: AvatarTier.altin),
        AvatarTier.altin,
      );
      expect(
        TierCelebrationListener.tierToCelebrate(storedTierIndex: 2, current: AvatarTier.altin),
        isNull,
      );
      expect(
        TierCelebrationListener.tierToCelebrate(storedTierIndex: 3, current: AvatarTier.altin),
        isNull,
      );
    });
  });

  group('Kutlama penceresi', () {
    testWidgets('mesaj, unvan ve düğme; konfeti hareket açıkken var', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TierUpView(tier: AvatarTier.altin)));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Evrim zamanı!'), findsOneWidget);
      expect(
        find.text('Tebrikler! Akıncı unvanını ve Akıncı Pelerini ve Sancağı kostümünü kazandın!'),
        findsOneWidget,
      );
      expect(find.text('Harika!'), findsOneWidget);
      expect(find.byType(LottieBuilder), findsOneWidget);
      expect(find.byType(EvolvingAvatarWidget), findsOneWidget);
    });

    testWidgets('hareket azaltılmışsa konfeti yok, pencere yine var', (tester) async {
      await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const TierUpView(tier: AvatarTier.elmas),
      ));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(LottieBuilder), findsNothing);
      expect(find.textContaining('Siber Yeniçeri unvanını'), findsOneWidget);
    });
  });

  group('Kutlama dinleyicisi (ana ekran entegrasyonu)', () {
    testWidgets('ilk kullanımda sessizce kaydeder, kutlama açmaz', (tester) async {
      final c = await _pumpListener(tester, startXp: 600);
      expect(find.text('Evrim zamanı!'), findsNothing);
      expect(c.read(sharedPreferencesProvider).getInt(TierCelebrationListener.storageKey('u1')), 1);
    });

    testWidgets('yeni evreye çıkınca pencere açılır, kayıt güncellenir, kapatılabilir', (tester) async {
      final c = await _pumpListener(
        tester,
        startXp: 600,
        stored: {TierCelebrationListener.storageKey('u1'): 1},
      );
      expect(find.text('Evrim zamanı!'), findsNothing);

      await _setXp(tester, c, 1600); // gümüş → altın
      expect(find.text('Evrim zamanı!'), findsOneWidget);
      expect(
        find.text('Tebrikler! Akıncı unvanını ve Akıncı Pelerini ve Sancağı kostümünü kazandın!'),
        findsOneWidget,
      );
      expect(c.read(sharedPreferencesProvider).getInt(TierCelebrationListener.storageKey('u1')), 2);

      await tester.tap(find.text('Harika!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Evrim zamanı!'), findsNothing);
    });

    testWidgets('aynı evre içinde XP artışı kutlama açmaz', (tester) async {
      final c = await _pumpListener(
        tester,
        startXp: 1600,
        stored: {TierCelebrationListener.storageKey('u1'): 2},
      );
      await _setXp(tester, c, 1700);
      await _setXp(tester, c, 3000);
      expect(find.text('Evrim zamanı!'), findsNothing);
    });

    testWidgets('iki evre birden atlanırsa ulaşılan en yüksek evre bir kez kutlanır', (tester) async {
      final c = await _pumpListener(
        tester,
        startXp: 100,
        stored: {TierCelebrationListener.storageKey('u1'): 0},
      );
      await _setXp(tester, c, 4000); // bronz → elmas
      expect(find.text('Siber Yeniçeri'), findsOneWidget);
      expect(find.byType(TierUpView), findsOneWidget);

      await tester.tap(find.text('Harika!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await _setXp(tester, c, 4100); // aynı evre: tekrar kutlama yok
      expect(find.byType(TierUpView), findsNothing);
    });

    testWidgets('hareket azaltılmışsa pencere konfetisiz açılır', (tester) async {
      final c = await _pumpListener(
        tester,
        startXp: 100,
        stored: {TierCelebrationListener.storageKey('u1'): 0},
        reduceMotion: true,
      );
      await _setXp(tester, c, 600);
      expect(find.text('Evrim zamanı!'), findsOneWidget);
      expect(find.byType(LottieBuilder), findsNothing);
    });
  });
}
