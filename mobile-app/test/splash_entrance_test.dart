// Hupolingo açılış deneyimi testleri.
//
// Kapsam:
//  * Açılış türü (AppOpenKind) ve plan (AppOpenPlan) kararları — saf fonksiyon.
//  * İlk karşılama bayrağının kalıcılığı.
//  * Marka sahnesinin oynayıp bitmesi ve ana sayfaya geçiş sinyali üretmesi.
//  * Hareket azalt durumunda sahnenin statik kareye dönmesi.
//  * Sahnenin içeriği bloke etmemesi (içerik altta hazır).
//
// NOT: Cihaz/emülatör üzerinde çalıştırılmadı; bunlar widget testleridir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/screens/splash_screen.dart';
import 'package:ogrenci_hazirlik/services/app_open_service.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/widgets/splash/hupo_signature_entrance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('resolveAppOpenKind', () {
    test('ilk karşılama yapılmadıysa firstLaunch', () {
      expect(
        resolveAppOpenKind(
          firstGreetingDone: false,
          resumedFromBackground: false,
          isDeepLink: false,
        ),
        AppOpenKind.firstLaunch,
      );
    });

    test('karşılama yapıldıysa coldStart', () {
      expect(
        resolveAppOpenKind(
          firstGreetingDone: true,
          resumedFromBackground: false,
          isDeepLink: false,
        ),
        AppOpenKind.coldStart,
      );
    });

    test('arka plandan dönüş resume kazanır', () {
      expect(
        resolveAppOpenKind(
          firstGreetingDone: false,
          resumedFromBackground: true,
          isDeepLink: true,
        ),
        AppOpenKind.resume,
      );
    });

    test('deep link directRedirect', () {
      expect(
        resolveAppOpenKind(
          firstGreetingDone: false,
          resumedFromBackground: false,
          isDeepLink: true,
        ),
        AppOpenKind.directRedirect,
      );
    });
  });

  group('planAppOpen', () {
    test('ilk/cold açılışta tam sahne 1600 ms', () {
      final plan = planAppOpen(
        kind: AppOpenKind.firstLaunch,
        reducedMotion: false,
      );
      expect(plan.playFullBrandScene, isTrue);
      expect(plan.microGreeting, isFalse);
      expect(plan.duration, kHupoSahneToplam);
      expect(plan.skip, isFalse);
    });

    test('hareket azalt açıkken tam sahne oynatılmaz', () {
      final plan = planAppOpen(
        kind: AppOpenKind.coldStart,
        reducedMotion: true,
      );
      expect(plan.playFullBrandScene, isFalse);
      expect(plan.microGreeting, isTrue);
      expect(plan.duration.inMilliseconds, lessThanOrEqualTo(600));
    });

    test('sıcak açılışta kısa mikro karşılama', () {
      final plan = planAppOpen(
        kind: AppOpenKind.warmStart,
        reducedMotion: false,
      );
      expect(plan.playFullBrandScene, isFalse);
      expect(plan.microGreeting, isTrue);
      expect(plan.duration, kHupoMikroKarsilama);
    });

    test('resume ve deep link sahneyi atlar', () {
      for (final kind in [AppOpenKind.resume, AppOpenKind.directRedirect]) {
        final plan = planAppOpen(kind: kind, reducedMotion: false);
        expect(plan.skip, isTrue, reason: kind.name);
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

      // Başlangıçta bitmemiş olmalı.
      expect(bitti, isFalse);

      // Sahne süresini aşacak kadar ilerlet.
      await tester.pump(kSignatureEntranceDuration);
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
      // Statik kare: Hupolingo marka adı görünür, animasyon beklenmez.
      expect(find.text('Hupolingo'), findsOneWidget);
    });
  });

  group('SplashGate', () {
    testWidgets('ilk açılışta tam sahne oynar', (tester) async {
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

      // Tam sahne widget'ı görünür.
      expect(find.byType(HupoSignatureEntrance), findsOneWidget);
      // İçerik altta hazır olmalı.
      expect(find.byType(_IsaretMetni), findsOneWidget);
    });

    testWidgets('sahne bitince içerik açığa çıkar ve bayrak işaretlenir',
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

      // Sahne + fade-out tamamlanana kadar ilerlet.
      await tester.pump(kSignatureEntranceDuration);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.byType(HupoSignatureEntrance), findsNothing);
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
