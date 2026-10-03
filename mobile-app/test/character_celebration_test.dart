// Karakter kutlama dinleyicisi testleri.
//
// Dialog'u tetikleyen (yeni karakter açılan) senaryo, assets/characters/
// klasöründe henüz görsel olmadığı için ayrı bırakıldı.
// Görseller eklendiğinde "yeni karakter açılınca dialog gösterir" testi
// buraya eklenebilir.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ogrenci_hazirlik/models/character_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/widgets/character/character_celebration_listener.dart';

CharacterCard _kart(String kod, {bool kazanildi = true}) => CharacterCard(
      kod: kod,
      ad: 'Test $kod',
      aciklama: 'Test',
      ikon: 'placeholder.png',
      sinif: KarakterSinifi.ozgurRuhlar,
      sinifSira: 1,
      karakterSira: 1,
      kosulTuru: KosulTuru.xp,
      kosulDeger: 100,
      kazanildi: kazanildi,
    );

/// _charSource ile myCharactersProvider'ı testlerde kontrol ediyoruz.
final _charSource =
    StateProvider<List<CharacterCard>>((ref) => const []);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  List<CharacterCard> baslangic = const [],
  Map<String, Object> stored = const {},
}) async {
  SharedPreferences.setMockInitialValues(stored);
  final prefs = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      currentUserIdProvider.overrideWithValue('u1'),
      _charSource.overrideWith((ref) => baslangic),
      myCharactersProvider.overrideWith(
        (ref) async => ref.watch(_charSource),
      ),
    ],
    child: const MaterialApp(
      home: CharacterCelebrationListener(child: Text('ana ekran')),
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  return ProviderScope.containerOf(tester.element(find.text('ana ekran')));
}

void main() {
  test('storageKey kullanıcı kimliğini içerir', () {
    expect(CharacterCelebrationListener.storageKey('abc123'),
        'unlocked_chars_abc123');
    expect(CharacterCelebrationListener.storageKey('u42'), 'unlocked_chars_u42');
  });

  group('CharacterCelebrationListener', () {
    testWidgets('ilk yüklemede karakterleri kaydeder, dialog açmaz',
        (tester) async {
      await _pump(tester, baslangic: [_kart('akinci'), _kart('kahraman')]);

      // Uygulama devam ediyor; dialog yok
      expect(find.text('ana ekran'), findsOneWidget);

      // Prefs'e ilk listeyi yazmış olmalı
      final prefs = await SharedPreferences.getInstance();
      final kayitli = prefs.getStringList('unlocked_chars_u1')?.toSet();
      expect(kayitli, containsAll(['akinci', 'kahraman']));
    });

    testWidgets('aynı liste tekrar gelirse dialog açılmaz', (tester) async {
      final c = await _pump(
        tester,
        baslangic: [_kart('akinci')],
        stored: {
          'unlocked_chars_u1': <Object>['akinci']
        },
      );

      // Listeyi değiştirmeden güncelle
      c.read(_charSource.notifier).state = [_kart('akinci')];
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(Dialog), findsNothing);
      expect(find.text('ana ekran'), findsOneWidget);
    });

    testWidgets('kilitli karakter sayılmaz', (tester) async {
      await _pump(
        tester,
        baslangic: [_kart('akinci', kazanildi: false)],
      );

      final prefs = await SharedPreferences.getInstance();
      // Kazanılmamış karakter prefs'e yazılmamalı
      final kayitli = prefs.getStringList('unlocked_chars_u1') ?? [];
      expect(kayitli, isEmpty);
    });

    testWidgets('kullanıcı null iken hiçbir şey yazmaz', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          currentUserIdProvider.overrideWithValue(null),
          myCharactersProvider.overrideWith(
            (ref) async => [_kart('akinci')],
          ),
        ],
        child: const MaterialApp(
          home: CharacterCelebrationListener(child: Text('ana ekran')),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('ana ekran'), findsOneWidget);
      // Kullanıcı yokken hiçbir anahtar yazılmamalı
      expect(prefs.getKeys(), isEmpty);
    });

    testWidgets('karakterler boşsa prefs değişmez', (tester) async {
      await _pump(tester, baslangic: []);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('unlocked_chars_u1'), isNull);
    });
  });
}
