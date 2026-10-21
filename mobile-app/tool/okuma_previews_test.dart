// ignore_for_file: invalid_use_of_visible_for_testing_member
// "Senin Hikâyen" ekran görüntüleri (telefon olmadan görsel kontrol):
//   flutter test tool/okuma_previews_test.dart --update-goldens
// Çıktılar tool/previews/okuma_*.png. Sahte depo kullanılır; canlı veritabanı yoktur.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/providers/okuma_akis.dart' show OkumaPdfSonucu;
import 'package:ogrenci_hazirlik/screens/okuma/sonuc_ekrani.dart';
import 'package:ogrenci_hazirlik/providers/okuma_providers.dart';
import 'package:ogrenci_hazirlik/screens/okuma/okuma_akis_ekrani.dart';
import 'package:ogrenci_hazirlik/services/okuma_repository.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/widgets/hupo/hupo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/okuma_fake_repository.dart';
import 'screen_previews_test.dart' show loadFonts;

Future<void> _bekle(WidgetTester t, [int ms = 350]) async {
  await t.pump();
  await t.pump(Duration(milliseconds: ms));
}

Future<void> _tikla(WidgetTester t, Finder f) async {
  if (f.evaluate().isEmpty) await t.scrollUntilVisible(f, 150, scrollable: find.byType(Scrollable).first);
  await t.ensureVisible(f.first);
  await t.pump();
  await t.tap(f.first);
  await _bekle(t);
}

Future<void> _pompala(
  WidgetTester t,
  FakeOkumaRepository repo,
  Size boyut, {
  double olcek = 1.0,
  Map<String, Object> onceki = const {},
}) async {
  SharedPreferences.setMockInitialValues(onceki);
  final prefs = await SharedPreferences.getInstance();
  t.view.devicePixelRatio = boyut.width > 600 ? 1.0 : 2.0;
  t.view.physicalSize = boyut * t.view.devicePixelRatio;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        okumaRepositoryProvider.overrideWithValue(repo),
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentUserIdProvider.overrideWithValue('u1'),
        okumaCikisAkisiProvider.overrideWithValue(const Stream<void>.empty()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: TextScaler.linear(olcek)),
          child: child!,
        ),
        home: const OkumaAkisEkrani(),
      ),
    ),
  );
  await t.runAsync(() async {
    final ctx = t.element(find.byType(MaterialApp));
    for (final p in HupoPose.values) {
      await precacheImage(AssetImage(p.assetPath), ctx);
    }
  });
  await _bekle(t);
}

Future<void> _foto(WidgetTester t, String ad) async {
  // Maskot görselleri gerçek zamanda çözülür; kare almadan önce kısa bir süre tanı.
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 250)));
  await t.pump(const Duration(milliseconds: 100));
  await expectLater(find.byType(MaterialApp), matchesGoldenFile('previews/okuma_$ad.png'));
}

const _dogru = ['C', 'B', 'A', 'C'];

void main() {
  setUpAll(loadFonts);

  for (final (etiket, boyut) in [('390', const Size(390, 844)), ('1024', const Size(1024, 768))]) {
    testWidgets('akış ekranları $etiket', (t) async {
      final repo = FakeOkumaRepository();
      await _pompala(t, repo, boyut);
      await _foto(t, '1_kahraman_$etiket');

      await _tikla(t, find.text('Hayvan'));
      await t.scrollUntilVisible(find.byType(TextField), 150, scrollable: find.byType(Scrollable).first);
      await t.enterText(find.byType(TextField).first, 'Pati');
      await t.pump();
      await _foto(t, '2_kahraman_ad_$etiket');
      await _tikla(t, find.text('Hikâyeleri gör'));
      await _foto(t, '3_liste_$etiket');

      await _tikla(t, find.text('Feneri Kim Yakıyor?'));
      await _bekle(t, 600);
      await _foto(t, '4_okuyucu_$etiket');

      for (var i = 0; i < 3; i++) {
        await _tikla(t, find.text('Sonraki sayfa'));
      }
      await _tikla(t, find.text('Sorulara geç'));
      await _foto(t, '5_soru_$etiket');
      await _tikla(t, find.text('A'));
      await _tikla(t, find.text('Cevapla'));
      await _bekle(t, 600);
      await _foto(t, '6_soru_yanlis_$etiket');
      await _tikla(t, find.text('Sonraki soru'));
      await _tikla(t, find.text('B'));
      await _tikla(t, find.text('Cevapla'));
      await _bekle(t, 600);
      await _foto(t, '7_soru_dogru_$etiket');
      await _tikla(t, find.text('Sonraki soru'));
      for (var i = 2; i < 4; i++) {
        await _tikla(t, find.text(_dogru[i]));
        await _tikla(t, find.text('Cevapla'));
        await _bekle(t, 600);
        await _tikla(t, find.text(i == 3 ? 'Sonucu gör' : 'Sonraki soru'));
      }
      await _foto(t, '8_anket_$etiket');
      await _tikla(t, find.byTooltip('4 yıldız'));
      await _tikla(t, find.text('Gönder'));
      await _bekle(t, 600);
      await _foto(t, '9_sonuc_$etiket');
      await t.pumpAndSettle(const Duration(seconds: 1));
    });
  }

  testWidgets('kota dolu ekranı 390', (t) async {
    final repo = FakeOkumaRepository()..getirHatasi = null;
    await _pompala(t, repo, const Size(390, 844));
    await _tikla(t, find.text('Ben'));
    await t.scrollUntilVisible(find.byType(TextField), 150, scrollable: find.byType(Scrollable).first);
    await t.enterText(find.byType(TextField).first, 'Efe');
    await t.pump();
    await _tikla(t, find.text('Hikâyeleri gör'));
    repo.getirHatasi = okumaHatasiCevir('KOTA_DOLDU');
    await _tikla(t, find.text('Feneri Kim Yakıyor?'));
    await _bekle(t, 600);
    await _foto(t, 'kota_390');
  });

  // Sonuç ekranı, kısa telefon (360x640), sistem yazı ölçeği 2.0. Ad: okuma_sonuc_buyuk_yazi_360_<etiket>.png
  testWidgets('sonuç ekranı 360x640 yazı 2.0', (t) async {
    t.view.devicePixelRatio = 1.0;
    t.view.physicalSize = const Size(360, 640);
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        builder: (c, child) => MediaQuery(
          data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(2.0), disableAnimations: true),
          child: child!,
        ),
        home: SonucEkrani(
          sonuc: const OkumaSonuc(soruSayisi: 4, dogruSayisi: 4, dogruOrani: 100, kazanilanXp: 20, seri: OkumaSeri(seriSayisi: 3)),
          onYeni: () {},
          onKahraman: () {},
          onPdf: () async => OkumaPdfSonucu.hazir,
          onKapat: () {},
          oneri: testSatiri(),
          onOneri: () {},
        ),
      ),
    );
    await t.runAsync(() async {
      final ctx = t.element(find.byType(MaterialApp));
      for (final p in HupoPose.values) {
        await precacheImage(AssetImage(p.assetPath), ctx);
      }
    });
    await _bekle(t);
    await _foto(t, 'sonuc_buyuk_yazi_360_sonra');
  });

  testWidgets('büyük yazı 2.0: kahraman ve sonuç', (t) async {
    final repo = FakeOkumaRepository();
    await _pompala(t, repo, const Size(390, 844), olcek: 2.0);
    await _foto(t, 'buyuk_yazi_kahraman_390');
  });
}


