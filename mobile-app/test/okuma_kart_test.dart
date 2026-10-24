// Öğren sekmesi "Bugünkü hikâye" kartı: özellik bayrağı kapalıyken HİÇ görünmez; açıkken öneri, seri,
// kota dolu ve geri dönüş durumları; üç ekran boyutu ve büyük yazı.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/providers/okuma_providers.dart';
import 'package:ogrenci_hazirlik/screens/learn_screen.dart';
import 'package:ogrenci_hazirlik/services/okuma_repository.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tool/screen_previews_test.dart' show loadFonts, overrides;
import 'okuma_fake_repository.dart';

Future<void> _ogren(
  WidgetTester tester,
  OkumaRepository repo, {
  Size boyut = const Size(390, 844),
  double yaziOlcegi = 1.0,
  Map<String, Object> onceki = const {},
}) async {
  SharedPreferences.setMockInitialValues(onceki);
  final prefs = await SharedPreferences.getInstance();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = boyut;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...overrides,
        currentUserIdProvider.overrideWithValue('u1'),
        sharedPreferencesProvider.overrideWithValue(prefs),
        okumaRepositoryProvider.overrideWithValue(repo),
        okumaCikisAkisiProvider.overrideWithValue(const Stream<void>.empty()),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(yaziOlcegi)),
          child: child!,
        ),
        home: const LearnScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

const _kart = ValueKey('okuma-vitrin-kart');

void main() {
  setUpAll(loadFonts);

  testWidgets('bayrak kapalıyken kart HİÇ görünmez ve öneri istenmez', (tester) async {
    final repo = FakeOkumaRepository(ozellik: const OkumaOzellikDurumu(erisim: false));
    await _ogren(tester, repo);
    expect(find.byKey(_kart), findsNothing);
    expect(find.text('Bugünkü hikâye'), findsNothing);
    expect(find.text('Hikâyeye başla'), findsNothing);
    expect(find.text('Dersler'), findsOneWidget, reason: 'Öğren sekmesi eskisi gibi');
    expect(repo.sayac('okuma_ozellik_durumu'), 1);
    expect(repo.sayac('okuma_seri_ve_oneri'), 0, reason: 'bayrak kapalıyken başka okuma çağrısı yapılmaz');
    expect(tester.takeException(), isNull);
  });

  testWidgets('bayrak okunamazsa (sunucu hatası) kart yine görünmez, hata gürültüsü yok', (tester) async {
    final repo = FakeOkumaRepository()..ozellikHatasi = okumaBaglantiHatasi;
    await _ogren(tester, repo);
    expect(find.byKey(_kart), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final boyut in const [Size(390, 844), Size(768, 1024), Size(1024, 768)]) {
    testWidgets('bayrak açıkken kart: öneri ve seri görünür (${boyut.width.toInt()}x${boyut.height.toInt()})', (tester) async {
      final repo = FakeOkumaRepository();
      await _ogren(tester, repo, boyut: boyut);
      expect(find.byKey(_kart), findsOneWidget);
      expect(find.text('Bugünkü hikâye'), findsOneWidget);
      expect(find.text('Feneri Kim Yakıyor?'), findsOneWidget);
      expect(find.text('3 günlük okuma serisi'), findsOneWidget);
      expect(find.text('Hikâyeye başla'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('büyük yazı (2.0): taşma yok', (tester) async {
    await _ogren(tester, FakeOkumaRepository(), yaziOlcegi: 2.0);
    expect(find.byKey(_kart), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bugünkü hak dolduysa kart "yarın yeni hikâye" der ve Okuduklarım sunar', (tester) async {
    final repo = FakeOkumaRepository(kotaDolu: true);
    await _ogren(tester, repo);
    expect(find.text('Bugünkü hikâyeni okudun'), findsOneWidget);
    expect(find.text('Yarın yeni bir hikâye seni bekliyor.'), findsOneWidget);
    expect(find.text('Okuduklarım'), findsOneWidget);
    expect(find.text('Hikâyeye başla'), findsNothing);
  });

  testWidgets('yarım kalan hikâye varsa "Maceran seni bekliyor!" ve kaldığı sayfa gösterilir', (tester) async {
    final devam = jsonEncode({
      'satir': testSatiri().toMap(),
      'sayfa': 2,
      'toplam': 4,
      'at': DateTime.now().toIso8601String(),
    });
    await _ogren(tester, FakeOkumaRepository(), onceki: {'okuma_kisisel_devam_u1': devam});
    expect(find.text('Maceran seni bekliyor!'), findsOneWidget);
    expect(find.text('Sayfa 3 / 4'), findsOneWidget);
    expect(find.text('Kaldığın yerden devam et'), findsOneWidget);
    expect(find.text('Hikâyeye başla'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('üç kategori kapağı görünür; sayı gerçek katalogdan gelir, boş kategori "Yakında" der', (tester) async {
    await _ogren(tester, FakeOkumaRepository());
    expect(find.text('Keşfetmeye hazır mısın?'), findsOneWidget);
    expect(find.text('Gizem'), findsOneWidget);
    expect(find.text('Uzay ve Bilim Kurgu'), findsOneWidget);
    expect(find.text('Macera'), findsOneWidget);
    // Fake katalogda yalnız bir macera hikâyesi var.
    expect(find.text('1 hikâye'), findsOneWidget);
    expect(find.text('Yakında'), findsNWidgets(2));
  });

  testWidgets('katalog boşken de kapaklar görünür (sayı uydurulmaz)', (tester) async {
    await _ogren(tester, FakeOkumaRepository(katalogSatirlari: const []));
    expect(find.text('Gizem'), findsOneWidget);
    expect(find.text('Yakında'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('katalog yüklenemezse kapaklar sayısız görünür, Tüm hikâyeler hata + yeniden dene gösterir', (tester) async {
    final repo = FakeOkumaRepository()..katalogHatasi = okumaBaglantiHatasi;
    await _ogren(tester, repo);
    expect(find.text('Gizem'), findsOneWidget);
    expect(find.text('Yakında'), findsNothing);
    await tester.tap(find.text('Tüm hikâyeler →'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Hikâyeler şu an yüklenemedi.'), findsOneWidget);
    expect(find.text('Yeniden dene'), findsOneWidget);
  });

  testWidgets('"Tüm hikâyeler" keşif ekranını açar ve yeni hikâye akışına giden düğme içerir', (tester) async {
    await _ogren(tester, FakeOkumaRepository());
    await tester.tap(find.text('Tüm hikâyeler →'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Hikâyemi oluştur'), findsOneWidget);
    expect(find.text('Hikâyeleri keşfet'), findsOneWidget);
    // Vitrin şeridi de aynı kategoriyi gösterdiği için (Learn ekranı yığında) birden çok olabilir.
    expect(find.text('1 hikâye'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('3+ gün okunmadıysa kartta nazik geri dönüş mesajı (push yok)', (tester) async {
    final eski = DateTime.now().subtract(const Duration(days: 4)).toIso8601String();
    await _ogren(tester, FakeOkumaRepository(), onceki: {'okuma_kisisel_son_okuma_u1': eski});
    expect(find.textContaining('gündür yeni bir hikâye okumadın. Seni bekliyoruz!'), findsOneWidget);
  });

  testWidgets('karta dokununca "Senin Hikâyen" kahraman seçimi açılır', (tester) async {
    await _ogren(tester, FakeOkumaRepository());
    await tester.tap(find.text('Hikâyeye başla'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Kahramanın kim olsun?'), findsOneWidget);
    // Profil adı önerisi yalnız cihazda: ilk sözcük.
    await tester.tap(find.text('Ben'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.scrollUntilVisible(find.text('Profil adımı kullan: Ayşe'), 150, scrollable: find.byType(Scrollable).first);
    expect(find.text('Profil adımı kullan: Ayşe'), findsOneWidget);
  });

  testWidgets('seri yoksa seri satırı gösterilmez', (tester) async {
    final repo = _SerisizRepo();
    await _ogren(tester, repo);
    expect(find.byKey(_kart), findsOneWidget);
    expect(find.textContaining('günlük okuma serisi'), findsNothing);
  });
}

class _SerisizRepo extends FakeOkumaRepository {
  @override
  Future<OkumaSeriVeOneri> seriVeOneri() async => OkumaSeriVeOneri(seri: const OkumaSeri(), oneri: testSatiri());
}
