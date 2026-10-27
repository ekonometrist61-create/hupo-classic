// Hikâye seçim ekranında değer filtresi ve "Veli tercihleri" filtresi; kart rozeti.
// Sunucu alanları (ana_deger, yardimci_deger, deger_eslesmesi) katalog satırından okunur.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_degerler.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/screens/okuma/hikaye_secim_ekrani.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';

OkumaKatalogSatiri _satir(String ad, {String? ana, String? yardimci, bool eslesme = false}) => OkumaKatalogSatiri(
      hikayeId: 'h-$ad',
      surumId: 's-$ad',
      surumNo: 1,
      slug: ad.toLowerCase(),
      baslik: ad,
      tur: 'bilim',
      anaSinif: 3,
      sha256: 'x',
      anaDeger: ana,
      yardimciDeger: yardimci,
      degerEslesmesi: eslesme,
    );

Future<void> _pompala(WidgetTester tester, List<OkumaKatalogSatiri> katalog, {void Function(OkumaKatalogSatiri)? onSec}) async {
  // Liste tembel çizilir; tüm kartların görünmesi için ekran yüksek tutulur.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(800, 4000);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: HikayeSecimEkrani(
        katalog: katalog,
        kahramanAdi: 'Hupo',
        onSec: onSec ?? (_) {},
        onGeri: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('katalog satırı değer alanları', () {
    test('fromMap ana_deger, yardimci_deger ve deger_eslesmesi okur', () {
      final s = OkumaKatalogSatiri.fromMap({
        'hikaye_id': 'h1',
        'surum_id': 's1',
        'surum_no': 1,
        'slug': 'a',
        'baslik': 'A',
        'tur': 'bilim',
        'ana_sinif': 3,
        'sha256': 'x',
        'ana_deger': 'D6',
        'yardimci_deger': 'D16',
        'deger_eslesmesi': true,
      });
      expect(s.anaDeger, 'D6');
      expect(s.yardimciDeger, 'D16');
      expect(s.degerEslesmesi, isTrue);
    });

    test('değer alanı yoksa güvenli varsayılan kullanılır', () {
      final s = OkumaKatalogSatiri.fromMap({
        'hikaye_id': 'h1',
        'surum_id': 's1',
        'surum_no': 1,
        'slug': 'a',
        'baslik': 'A',
        'tur': 'bilim',
        'ana_sinif': 3,
        'sha256': 'x',
      });
      expect(s.anaDeger, isNull);
      expect(s.degerEslesmesi, isFalse);
    });

    test('toMap/fromMap değer alanlarını korur (Okuduklarım kaydı)', () {
      final s = _satir('Tur', ana: 'D12', yardimci: 'D3', eslesme: true);
      final geri = OkumaKatalogSatiri.fromMap(s.toMap());
      expect(geri.anaDeger, 'D12');
      expect(geri.yardimciDeger, 'D3');
      expect(geri.degerEslesmesi, isTrue);
    });
  });

  group('değer adları', () {
    test('bilinen kod adına, bilinmeyen kod kendisine çevrilir', () {
      expect(okumaDegerAdi('D6'), 'Dürüstlük');
      expect(okumaDegerAdi('D16'), 'Sorumluluk');
      expect(okumaDegerAdi('D99'), 'D99');
    });

    test('sıralama sayısal yapılır (D2 < D10)', () {
      final liste = ['D10', 'D2', 'D1']..sort((a, b) => okumaDegerSirasi(a).compareTo(okumaDegerSirasi(b)));
      expect(liste, ['D1', 'D2', 'D10']);
    });
  });

  group('hikâye seçim ekranı filtreleri', () {
    final katalog = [
      _satir('Alfa', ana: 'D6', yardimci: 'D16'),
      _satir('Beta', ana: 'D12', yardimci: 'D3', eslesme: true),
      _satir('Gama', ana: 'D16', yardimci: 'D6'),
    ];

    testWidgets('değer çipi, ana veya yardımcı değeri eşleşen hikâyeleri gösterir', (tester) async {
      await _pompala(tester, katalog);
      await tester.tap(find.widgetWithText(FilterChip, 'Dürüstlük'));
      await tester.pumpAndSettle();
      expect(find.text('Alfa'), findsOneWidget);
      expect(find.text('Gama'), findsOneWidget);
      expect(find.text('Beta'), findsNothing);
    });

    testWidgets('"Veli tercihleri" çipi yalnız eşleşen hikâyeleri gösterir', (tester) async {
      await _pompala(tester, katalog);
      await tester.tap(find.widgetWithText(FilterChip, 'Veli tercihleri'));
      await tester.pumpAndSettle();
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Alfa'), findsNothing);
      expect(find.text('Gama'), findsNothing);
    });

    testWidgets('kart üzerinde değer rozeti ve veli tercihi işareti görünür', (tester) async {
      await _pompala(tester, katalog);
      expect(find.text('Sorumluluk'), findsWidgets);
      expect(find.text('Sabır · Veli tercihi'), findsOneWidget);
    });

    testWidgets('değer çipi seçilmemişse liste değişmez', (tester) async {
      await _pompala(tester, katalog);
      expect(find.text('Alfa'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gama'), findsOneWidget);
    });

    testWidgets('değer alanı olmayan katalogda değer ve veli çipleri gösterilmez', (tester) async {
      await _pompala(tester, [_satir('Duz')]);
      expect(find.widgetWithText(FilterChip, 'Veli tercihleri'), findsNothing);
      expect(find.text('Duz'), findsOneWidget);
    });
  });
}
