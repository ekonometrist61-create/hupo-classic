import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/widgets/splash/hupo_giris_filmi.dart';

void main() {
  testWidgets('gecici: film baslar mi', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final anahtar = GlobalKey();
    var basladi = 0.0;
    var gecen = 0.0;
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: anahtar,
        child: HupoGirisFilmi(onFinished: () {}, hazirlikZamanAsimi: const Duration(seconds: 2), onBasladi: () => basladi = gecen + 1),
      ),
    ));
    for (var i = 0; i < 30 && basladi == 0; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump(const Duration(milliseconds: 100));
      gecen += 0.1;
    }
    // ignore: avoid_print
    print('DBG basladi=$basladi (0 = hic baslamadi) gecen=$gecen');
    await tester.pump(const Duration(milliseconds: 2200));
    final sinir = anahtar.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final r = await sinir.toImage(pixelRatio: 1.0);
      final b = await r.toByteData(format: ui.ImageByteFormat.png);
      File(r'C:\Users\cengi\AppData\Local\Temp\claude\c--Dev-hupo\7b37cb1e-3aa7-46fd-b9e7-ea568d49af4f\scratchpad\dbg_kare.png').writeAsBytesSync(b!.buffer.asUint8List());
    });
  });
}
