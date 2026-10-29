// Hupolingo açılış deneyimi testleri.
//
// Kapsam:
//  * Açılış türü (AppOpenKind) ve plan (AppOpenPlan) kararları — saf fonksiyon.
//  * İlk karşılama bayrağının kalıcılığı.
//  * Marka sesi yalnız ilk açılışta.
//  * Marka sahnesinin oynayıp bitmesi, kısa sahne ve hareket azalt kolu.
//  * "Hupolingo" yazısının geri dönüş stiliyle (alt çizgi) çizilmemesi.
//  * Dokunarak atlama ve sahnenin içeriği bloke etmemesi.
//
// NOT: Cihaz davranışı (kare süresi, native geçiş) docs/splash/baseline-* ve
// ACILIS_SENARYOSU_PLANI.md'deki cihaz kayıtlarıyla doğrulanır.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/screens/splash_screen.dart';
import 'package:ogrenci_hazirlik/services/app_open_service.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/widgets/splash/hupo_giris_filmi.dart';
import 'package:ogrenci_hazirlik/widgets/splash/hupo_signature_entrance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('resolveAppOpenKind', () {
    test('ilk karşılama yapılmadıysa firstLaunch', () {
      expect(
        resolveAppOpenKind(firstGreetingDone: false),
        AppOpenKind.firstLaunch,
      );
    });

    test('karşılama yapıldıysa coldStart', () {
      expect(
        resolveAppOpenKind(firstGreetingDone: true),
        AppOpenKind.coldStart,
      );
    });
  });

  group('planAppOpen', () {
    test('ilk açılışta giriş filmi (5 sn) ve marka sesi', () {
      final plan = planAppOpen(
        kind: AppOpenKind.firstLaunch,
        reducedMotion: false,
      );
      expect(plan.scene, AppOpenScene.full);
      expect(plan.duration, kHupoSahneToplam);
      expect(kHupoSahneToplam, const Duration(milliseconds: 5000));
      expect(plan.playBrandSound, isTrue);
    });

    test('sonraki açılışta kısa sahne (≤ 900 ms) ve ses yok', () {
      final plan = planAppOpen(
        kind: AppOpenKind.coldStart,
        reducedMotion: false,
      );
      expect(plan.scene, AppOpenScene.short);
      expect(plan.duration.inMilliseconds, lessThanOrEqualTo(900));
      expect(plan.playBrandSound, isFalse);
    });

    test('hareket azalt açıkken statik kare, ses yok', () {
      for (final kind in AppOpenKind.values) {
        final plan = planAppOpen(kind: kind, reducedMotion: true);
        expect(plan.scene, AppOpenScene.still, reason: kind.name);
        expect(plan.duration.inMilliseconds, lessThanOrEqualTo(600));
        expect(plan.playBrandSound, isFalse, reason: kind.name);
      }
    });
  });

  group('ilk karşılama bayrağı', () {
    test('başlangıçta false, işaretlenince true', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(firstGreetingDone(prefs), isFalse);
      await markFirstGreetingDone(prefs);
      expect(firstGreetingDone(prefs), isTrue);
    });
  });

  group('HupoSignatureEntrance', () {
    testWidgets('sahne oynar ve bitince onFinished çağrılır', (tester) async {
      var bitti = false;
      await tester.pumpWidget(MaterialApp(
        home: HupoSignatureEntrance(onFinished: () => bitti = true),
      ));

      expect(bitti, isFalse);

      await tester.pump(kSignatureEntranceDuration);
      await tester.pumpAndSettle();
      expect(bitti, isTrue);
    });

    testWidgets('kısa sahne 900 ms içinde biter ve marka adını göstermez',
        (tester) async {
      var bitti = false;
      await tester.pumpWidget(MaterialApp(
        home: HupoSignatureEntrance(
          onFinished: () => bitti = true,
          kisa: true,
        ),
      ));
      await tester.pump(kHupoKisaSahne - const Duration(milliseconds: 50));
      expect(find.text('Hupolingo'), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(bitti, isTrue);
    });

    testWidgets('hareket azalt statik kare gösterir', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: HupoSignatureEntrance(
          onFinished: _noop,
          reducedMotion: true,
        ),
      ));
      expect(find.text('Hupolingo'), findsOneWidget);
    });

    // Regresyon: sahne Scaffold dışında (SplashGate katmanı) çizilir. Material
    // olmazsa MaterialApp'in "eksik Material" stili (çift alt çizgi, tek
    // aralıklı font) yazıya bulaşır.
    testWidgets('Hupolingo yazısı alt çizgisiz ve tek aralıklı fontsuz çizilir',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Stack(
          children: [
            Positioned.fill(
              child: HupoSignatureEntrance(
                onFinished: _noop,
                reducedMotion: true,
              ),
            ),
          ],
        ),
      ));
      final yazi = tester.widget<Text>(find.text('Hupolingo'));
      final stil = DefaultTextStyle.of(tester.element(find.text('Hupolingo')))
          .style
          .merge(yazi.style);
      expect(stil.decoration, anyOf(isNull, TextDecoration.none));
      expect(stil.fontFamily, isNot('monospace'));
    });
  });

  group('SplashGate', () {
    testWidgets('ilk açılışta giriş filmi oynar', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: SplashGate(child: _IsaretMetni()),
        ),
      ));
      await tester.pump();

      expect(find.byType(HupoGirisFilmi), findsOneWidget);
      expect(find.byType(HupoSignatureEntrance), findsNothing);
      expect(find.byType(_IsaretMetni), findsOneWidget);
    });

    testWidgets('film bitince içerik açığa çıkar ve bayrak işaretlenir',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(
          home: SplashGate(child: _IsaretMetni()),
        ),
      ));
      await tester.pump();

      // Hazırlık zaman aşımı (1,5 sn) + ses bekleme (0,35 sn), sonra film süresi.
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(kHupoSahneToplam);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byType(HupoGirisFilmi), findsNothing);
      expect(firstGreetingDone(prefs), isTrue);
    });
  });
}

void _noop() {}

class _IsaretMetni extends StatelessWidget {
  const _IsaretMetni();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('İÇERİK'));
}
