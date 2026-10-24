// Okuma Dünyası görsel kabul testi: 5 ekran x 3 boyut x 2 yazı ölçeği. Gerçek Nunito yazı tipi yüklenir.
// PNG üretmek için: flutter test test/okuma_golden_test.dart --update-goldens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart' show currentUserIdProvider;
import 'package:ogrenci_hazirlik/providers/okuma_providers.dart' show okumaCikisAkisiProvider;
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/providers/okuma_akis.dart' show OkumaPdfSonucu;
import 'package:ogrenci_hazirlik/screens/okuma/anket_ekrani.dart';
import 'package:ogrenci_hazirlik/screens/okuma/okuma_tema.dart';
import 'package:ogrenci_hazirlik/screens/okuma/okuyucu_ekrani.dart';
import 'package:ogrenci_hazirlik/screens/okuma/sonuc_ekrani.dart';
import 'package:ogrenci_hazirlik/screens/okuma/sorular_ekrani.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/widgets/okuma/okuma_v3.dart';
import 'package:okuma_motoru/okuma_motoru.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _boyutlar = <String, Size>{
  '390x844': Size(390, 844),
  '1024x768': Size(1024, 768),
  '360x640': Size(360, 640),
  // En dar yaygın telefon: büyük yazıda başlıkların kelime ortasından kırılması burada görülür.
  '320x640': Size(320, 640),
};
const _olcekler = <double>[1.0, 2.0];

void _ayarla(WidgetTester tester, Size boyut, double olcek) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = boyut;
  tester.platformDispatcher.textScaleFactorTestValue = olcek;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

String _ad(String ekran, String boyut, double olcek) => 'okuma_golden/${ekran}_${boyut}_x${olcek.toStringAsFixed(0)}.png';

Widget _uygulama(Widget ev, SharedPreferences prefs) => ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentUserIdProvider.overrideWithValue('u1'),
        okumaCikisAkisiProvider.overrideWithValue(const Stream<void>.empty()),
      ],
      child: MaterialApp(debugShowCheckedModeBanner: false, theme: buildAppTheme(), home: ev),
    );

final _sayfalar = <List<Cikti>>[
  const [
    Cikti('Ece sabah erkenden kalktı. Bahçedeki ', Stil.normal),
    Cikti('uzun', Stil.kelime),
    Cikti(' gölgeyi görünce çok şaşırdı; ', Stil.normal),
    Cikti('çok önemli bir ipucu', Stil.onemli),
    Cikti(' bulmuştu. Arkadaşı Mert, ', Stil.normal),
    Cikti('eli kulağında', Stil.deyim),
    Cikti(' diyerek koşarak yanına geldi ve ikisi birlikte gizemi çözmeye karar verdi. ', Stil.normal),
    Cikti('Damlaya damlaya göl olur.', Stil.atasozu),
    Cikti(' Küçük adımlar büyük sonuçlar doğurur, diye düşündü Ece ve defterini açıp bütün gördüklerini sırayla yazmaya başladı.', Stil.normal),
  ],
  const [Cikti('İkinci sayfa. Gölge her saat biraz daha kısalıyordu.', Stil.normal)],
];

const _anlamlar = {'uzun': 'Boyu çok olan.', 'eli kulağında': 'Çok yakında.'};

const _sorular = [
  OkumaSoru(
    id: 'q1',
    metin: 'Ece bahçedeki gölgeyi görünce neden bu kadar şaşırdı ve ardından arkadaşı Mert ile birlikte hangi kararı verdi?',
    secenekler: [
      OkumaSecenek(id: 'a', metin: 'Gölge normalden çok daha uzun göründüğü için; ikisi birlikte gizemi çözmeye karar verdiler.'),
      OkumaSecenek(id: 'b', metin: 'Gölge hiç görünmediği için eve dönmeye karar verdiler.'),
      OkumaSecenek(id: 'c', metin: 'Bahçede başka biri olduğunu sandığı için öğretmene haber vermeye gitti.'),
      OkumaSecenek(id: 'd', metin: 'Kısa bir süre sonra hava karardığı için oyunu bırakıp uyudular.'),
    ],
  ),
  OkumaSoru(id: 'q2', metin: 'İkinci soru?', secenekler: [OkumaSecenek(id: 'a', metin: 'Evet'), OkumaSecenek(id: 'b', metin: 'Hayır')]),
];

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    final yukle = FontLoader('Nunito')..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Nunito.ttf').readAsBytesSync())));
    await yukle.load();
    // Material simgeleri: yüklenmezse test ortamında kare (tofu) görünür.
    var dizin = File(Platform.resolvedExecutable).parent;
    for (var i = 0; i < 8; i++) {
      final ikon = File('${dizin.path}/material_fonts/MaterialIcons-Regular.otf');
      final ikon2 = File('${dizin.path}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
      final bulunan = ikon.existsSync() ? ikon : (ikon2.existsSync() ? ikon2 : null);
      if (bulunan != null) {
        final y = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.sublistView(bulunan.readAsBytesSync())));
        await y.load();
        break;
      }
      dizin = dizin.parent;
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  for (final b in _boyutlar.entries) {
    for (final olcek in _olcekler) {
      final etiket = '${b.key} x$olcek';

      testWidgets('okuyucu $etiket', (tester) async {
        _ayarla(tester, b.value, olcek);
        await tester.pumpWidget(_uygulama(
          OkuyucuEkrani(sayfalar: _sayfalar, anlamlar: _anlamlar, onBitti: () {}, baslik: 'Gölgeyi Kim Büyüttü?', onGeri: () {}, tur: 'gizem'),
          prefs,
        ));
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile(_ad('okuyucu', b.key, olcek)));
      });

      testWidgets('kelime paneli $etiket', (tester) async {
        _ayarla(tester, b.value, olcek);
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) => OkumaKelimePaneli(
                      etiket: OkumaMetin.sozlukKelime,
                      metin: 'uzun',
                      anlam: 'Boyu çok olan, gözle bakıldığında diğerlerinden belirgin biçimde daha fazla yer kaplayan, uzaktan bile seçilebilen.',
                      ornek: 'Gölge sabah çok uzun olmuştu ve bütün bahçeyi kaplıyordu.',
                      onKapat: () => Navigator.pop(ctx),
                    ),
                  ),
                  child: const Text('aç'),
                ),
              ),
            ),
          ),
        ));
        await tester.tap(find.text('aç'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile(_ad('kelime_paneli', b.key, olcek)));
      });

      testWidgets('sorular (cevap sonrası) $etiket', (tester) async {
        _ayarla(tester, b.value, olcek);
        await tester.pumpWidget(_uygulama(
          SorularEkrani(
            sorular: _sorular,
            cevapKontrol: (soruId, secenekId) async => const OkumaCevapSonucu(
              dogru: false,
              aciklama: 'Metinde Ece gölgenin normalden çok uzun olduğunu fark eder ve Mert ile gizemi çözmeye karar verir; doğru seçenek birinci şıktır.',
              dogruSecenekId: 'a',
            ),
            onBitti: (_) {},
            onGeri: () {},
          ),
          prefs,
        ));
        await tester.pump(const Duration(milliseconds: 600));
        final yanlisSik = find.text('Bahçede başka biri olduğunu sandığı için öğretmene haber vermeye gitti.');
        await tester.scrollUntilVisible(yanlisSik, 80, scrollable: find.byType(Scrollable).first);
        await tester.ensureVisible(yanlisSik);
        await tester.pump();
        await tester.tap(yanlisSik);
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.text(OkumaMetin.soruCevapla));
        // Cevap geldi -> geri bildirim kurulur -> otomatik kaydırma (350 ms) çalışır.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 600));
        expect(tester.takeException(), isNull);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile(_ad('sorular', b.key, olcek)));
      });

      testWidgets('anket $etiket', (tester) async {
        _ayarla(tester, b.value, olcek);
        await tester.pumpWidget(_uygulama(AnketEkrani(onBitti: (_) {}), prefs));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile(_ad('anket', b.key, olcek)));
      });

      testWidgets('sonuç $etiket', (tester) async {
        _ayarla(tester, b.value, olcek);
        await tester.pumpWidget(_uygulama(
          SonucEkrani(
            sonuc: const OkumaSonuc(soruSayisi: 4, dogruSayisi: 1, dogruOrani: 25, kazanilanXp: 10),
            onYeni: () {},
            onKahraman: () {},
            onPdf: () async => OkumaPdfSonucu.hazir,
            onKapat: () {},
          ),
          prefs,
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(find.byType(MaterialApp), matchesGoldenFile(_ad('sonuc', b.key, olcek)));
      });
    }
  }
}


