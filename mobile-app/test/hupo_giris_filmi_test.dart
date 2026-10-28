// Giriş filmi ("Kelime Evreni") testleri: yaşam döngüsü, ses sözleşmesi ve çizim sağlamlığı.
//
// İsteğe bağlı çıktılar (ortam değişkeni verilmezse atlanır, normal çalıştırmayı yavaşlatmaz):
//  * HUPO_KARE_DIR=<klasör>  → anahtar kareleri PNG olarak yazar (gözle inceleme).
//  * HUPO_OLCUM=1            → kare başına CPU süresini (build+layout+paint kaydı) yazdırır.
// NOT: Gerçek cihazda kare süresi (raster dahil) bu testlerle ölçülmez; bkz. docs/splash/GIRIS_FILMI.md.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/app_open_service.dart';
import 'package:ogrenci_hazirlik/widgets/splash/hupo_giris_filmi.dart';

Widget _film({
  required VoidCallback onFinished,
  Future<void> Function()? ses,
  Duration zamanAsimi = Duration.zero,
  Key? anahtar,
  VoidCallback? basladi,
}) =>
    MaterialApp(
      home: RepaintBoundary(
        key: anahtar,
        child: HupoGirisFilmi(
          onFinished: onFinished,
          sesiBaslat: ses,
          hazirlikZamanAsimi: zamanAsimi,
          onBasladi: basladi,
        ),
      ),
    );

/// Varlıklar (görsel + nokta verisi) gerçek G/Ç ile yüklenip film başlayana kadar bekler.
Future<void> _baslamayiBekle(WidgetTester tester, bool Function() basladi) async {
  for (var i = 0; i < 150 && !basladi(); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 1));
  }
  expect(basladi(), isTrue, reason: 'varlıklar yüklenmedi: film başlamadı');
}

void _ekran(WidgetTester tester, Size boyut) {
  tester.view.physicalSize = boyut;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  // Varlık bildirimi (AssetManifest) gerçek zaman bölgesinde önbelleğe alınır: ilk testin sahte zaman
  // bölgesinde yarım kalan bir yükleme sonraki tüm görsel çözümlemelerini kilitlemesin.
  setUpAll(() async {
    await AssetManifest.loadFromAssetBundle(rootBundle);
    // Gerçek Nunito: testte varsayılan yazı tipi (Ahem) kutu çizer; düzen ölçüleri gerçeğe yakın olsun.
    final yazi = FontLoader('Nunito')..addFont(rootBundle.load('assets/fonts/Nunito.ttf'));
    await yazi.load();
  });

  setUp(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    rootBundle.evict(kGirisKaynakNoktalar);
  });

  group('HupoGirisFilmi yaşam döngüsü', () {
    testWidgets('film süresi bitince onFinished tam bir kez çağrılır', (tester) async {
      var biten = 0;
      await tester.pumpWidget(_film(onFinished: () => biten++));
      await tester.pump(const Duration(milliseconds: 5));
      expect(biten, 0);
      await tester.pump(kHupoSahneToplam - const Duration(milliseconds: 500));
      expect(biten, 0);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(biten, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ses başlamazsa film en çok 350 ms bekler ve sessiz oynar', (tester) async {
      var biten = 0;
      var cagri = 0;
      final hicBitmeyen = Completer<void>();
      await tester.pumpWidget(_film(
        onFinished: () => biten++,
        ses: () {
          cagri++;
          return hicBitmeyen.future;
        },
      ));
      await tester.pump(const Duration(milliseconds: 5));
      expect(cagri, 1);
      // Bekleme olmasaydı film 5000 ms'de biterdi; ≈350 ms gecikmeyle 5350 ms'de biter.
      await tester.pump(const Duration(milliseconds: 5100));
      expect(biten, 0);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(biten, 1);
    });

    testWidgets('ses hata verirse film çökmez, sessiz oynar', (tester) async {
      var biten = 0;
      await tester.pumpWidget(_film(
        onFinished: () => biten++,
        ses: () async => throw Exception('ses yok'),
      ));
      await tester.pump(const Duration(milliseconds: 5));
      await tester.pump(kHupoSahneToplam + const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(biten, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('film bitmeden ağaçtan kalkarsa sızıntı ve hata olmaz', (tester) async {
      await tester.pumpWidget(_film(onFinished: () {}));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 6));
      expect(tester.takeException(), isNull);
    });
  });

  group('HupoGirisFilmi çizim (gerçek varlıklarla)', () {
    final kareDizin = Platform.environment['HUPO_KARE_DIR'];
    final olcum = Platform.environment['HUPO_OLCUM'] == '1';

    // Anahtar anlar (sn): gece, yıldızlar, toplanma, beliriş, gözler açılır, sıçrama, imza, iz, son kare.
    const anlar = [0.1, 0.6, 1.2, 1.7, 2.2, 2.6, 3.05, 3.4, 3.8, 4.3, 4.95];

    for (final ekran in <(String, Size)>[
      ('portre', const Size(390, 844)),
      ('yatay', const Size(1280, 720)),
      ('küçük', const Size(320, 568)),
    ]) {
      testWidgets('${ekran.$1} ekranda her anda hatasız çizer', (tester) async {
        _ekran(tester, ekran.$2);
        final anahtar = GlobalKey();
        var basladi = false;
        await tester.pumpWidget(_film(
          onFinished: () {},
          anahtar: anahtar,
          zamanAsimi: const Duration(minutes: 5),
          basladi: () => basladi = true,
        ));
        await _baslamayiBekle(tester, () => basladi);

        var simdi = 0.0;
        for (final an in anlar) {
          await tester.pump(Duration(milliseconds: ((an - simdi) * 1000).round()));
          simdi = an;
          expect(tester.takeException(), isNull, reason: '${ekran.$1} @ $an sn');
          if (kareDizin != null) {
            final sinir = anahtar.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            await tester.runAsync(() async {
              final resim = await sinir.toImage();
              final veri = await resim.toByteData(format: ui.ImageByteFormat.png);
              final dosya = File('$kareDizin/${ekran.$1 == 'küçük' ? 'kucuk' : ekran.$1}_${an.toStringAsFixed(2)}.png');
              dosya.parent.createSync(recursive: true);
              dosya.writeAsBytesSync(veri!.buffer.asUint8List());
            });
          }
        }
      });
    }

    testWidgets('ölçüm: kare başına CPU süresi (build+layout+paint kaydı)', (tester) async {
      _ekran(tester, const Size(390, 844));
      var basladi = false;
      await tester.pumpWidget(_film(onFinished: () {}, zamanAsimi: const Duration(minutes: 5), basladi: () => basladi = true));
      await _baslamayiBekle(tester, () => basladi);

      final sureler = <double>[];
      final sayac = Stopwatch();
      for (var i = 0; i < 300; i++) {
        sayac
          ..reset()
          ..start();
        await tester.pump(const Duration(milliseconds: 16));
        sayac.stop();
        sureler.add(sayac.elapsedMicroseconds / 1000);
      }
      final sureler_ = List<double>.of(sureler); // zaman sırası (dilim istatistiği için)
      sureler.sort();
      final ort = sureler.reduce((a, b) => a + b) / sureler.length;
      final p95 = sureler[(sureler.length * 0.95).floor()];
      // ignore: avoid_print
      final dilim = <String>[];
      for (var d = 0; d < 5; d++) {
        final parca = [for (var i = d * 60; i < math.min((d + 1) * 60, 300); i++) sureler_[i]];
        dilim.add('$d-${d + 1}s: ${(parca.reduce((a, b) => a + b) / parca.length).toStringAsFixed(1)}/${parca.reduce(math.max).toStringAsFixed(0)}');
      }
      // ignore: avoid_print
      print('GIRIS_DILIM ort/maks ms -> ${dilim.join('  ')}');
      // ignore: avoid_print
      print('GIRIS_OLCUM kare=${sureler.length} ort=${ort.toStringAsFixed(2)} ms  p95=${p95.toStringAsFixed(2)} ms  maks=${sureler.last.toStringAsFixed(2)} ms');
      // Geniş bir güvenlik sınırı: bütçe 16,7 ms; bu makinede (zayıf PC) ortalama bunun altında kalmalı.
      expect(ort, lessThan(16.0));
    }, skip: !olcum);
  });
}
