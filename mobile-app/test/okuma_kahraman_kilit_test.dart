// Kahraman seçim ekranı: katalogda hikâyesi olmayan türler kilitlenir; katalog yüklenmiyor ya da
// hata veriyorsa hiçbir tür kilitlenmez. Sahte depo ve ProviderScope kullanılır (Supabase yok).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/providers/okuma_providers.dart';
import 'package:ogrenci_hazirlik/screens/okuma/kahraman_secim_ekrani.dart';
import 'package:ogrenci_hazirlik/screens/okuma/okuma_tema.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'okuma_fake_repository.dart';

/// Katalog hiç yanıt vermez (yükleniyor durumu).
class _YukleniyorDepo extends FakeOkumaRepository {
  @override
  Future<List<OkumaKatalogSatiri>> katalog({String? kahramanTuru, int limit = 24}) =>
      Completer<List<OkumaKatalogSatiri>>().future;
}

/// Katalog çağrısı hata verir.
class _HataliDepo extends FakeOkumaRepository {
  @override
  Future<List<OkumaKatalogSatiri>> katalog({String? kahramanTuru, int limit = 24}) async {
    throw Exception('ağ hatası');
  }
}

Future<void> _ac(WidgetTester tester, FakeOkumaRepository repo) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        okumaRepositoryProvider.overrideWithValue(repo),
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentUserIdProvider.overrideWithValue('u1'),
        okumaCikisAkisiProvider.overrideWithValue(const Stream<void>.empty()),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        home: KahramanSecimEkrani(onDevam: (_) {}),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

Future<void> _dokun(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 150, scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(f.first);
  await tester.pump();
  await tester.tap(f.first);
  await tester.pump();
}

void main() {
  testWidgets('katalogda hikâyesi olmayan türler kilitlenir; hayvan açık kalır', (tester) async {
    // Varsayılan sahte katalog: yalnız hayvan, hayalî, ben, başka biri türlerinde hikâye var.
    await _ac(tester, FakeOkumaRepository());
    expect(find.text('Yakında'), findsNWidgets(3), reason: 'Ailem, Arkadaşım ve Araçlar kilitli');

    await _dokun(tester, find.text('Araçlar'));
    expect(find.text(OkumaMetin.kahramanDevamPasif), findsOneWidget, reason: 'kilitli Araçlar seçilemez');

    await _dokun(tester, find.text('Hayvan Dostlarımız'));
    expect(find.text(OkumaMetin.kahramanDevamPasif), findsNothing, reason: 'açık hayvan seçilir');
  });

  testWidgets('katalog hata verirse hiçbir tür kilitlenmez', (tester) async {
    await _ac(tester, _HataliDepo());
    expect(find.text('Yakında'), findsNothing);

    await _dokun(tester, find.text('Araçlar'));
    expect(find.text(OkumaMetin.kahramanDevamPasif), findsNothing, reason: 'hata anında eski davranış');
  });

  testWidgets('katalog yüklenirken hiçbir tür kilitlenmez', (tester) async {
    await _ac(tester, _YukleniyorDepo());
    expect(find.text('Yakında'), findsNothing);

    await _dokun(tester, find.text('Araçlar'));
    expect(find.text(OkumaMetin.kahramanDevamPasif), findsNothing, reason: 'yükleme sırasında kilit yok');
  });
}
