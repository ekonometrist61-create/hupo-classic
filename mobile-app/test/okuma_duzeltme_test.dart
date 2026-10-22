// Okuma Dünyası düzeltmeleri: kelime paneli kapanır, anket isteğe bağlı, sonuç motivasyonu düğmelerin üstünde.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/screens/okuma/anket_ekrani.dart';
import 'package:ogrenci_hazirlik/screens/okuma/okuma_tema.dart';
import 'package:ogrenci_hazirlik/screens/okuma/sonuc_ekrani.dart';
import 'package:ogrenci_hazirlik/providers/okuma_akis.dart' show OkumaPdfSonucu;
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/widgets/okuma/okuma_v3.dart';

void _boyut(WidgetTester tester, Size boyut) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = boyut;
  addTearDown(tester.view.reset);
}

void main() {
  // Gerçek yazı tipi: test ortamının varsayılanı Ahem'dir (her harf tam punto genişliğinde) ve taşmaları abartır.
  setUpAll(() async {
    final yukle = FontLoader('Nunito')..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Nunito.ttf').readAsBytesSync())));
    await yukle.load();
  });

  testWidgets('kelime paneli: anlam görünür, kapat simgesi ve Kapat düğmesi paneli kapatır', (tester) async {
    _boyut(tester, const Size(390, 844));
    await tester.pumpWidget(MaterialApp(
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
                  anlam: 'Boyu çok olan, göze uzak görünen.',
                  ornek: 'Gölge sabah çok uzun olmuştu.',
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
    expect(find.text('Boyu çok olan, göze uzak görünen.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Boyu çok olan, göze uzak görünen.'), findsNothing);

    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OkumaMetin.kapat).last);
    await tester.pumpAndSettle();
    expect(find.text('Boyu çok olan, göze uzak görünen.'), findsNothing);
  });

  testWidgets('anket: hiçbir şey seçilmeden Atla → onBitti(null)', (tester) async {
    _boyut(tester, const Size(390, 844));
    OkumaAnketYaniti? donen;
    var bitti = false;
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: AnketEkrani(onBitti: (y) {
        bitti = true;
        donen = y;
      }),
    ));
    await tester.pumpAndSettle();
    expect(find.text(OkumaMetin.anketAtla), findsOneWidget);
    expect(find.text(OkumaMetin.anketGonder), findsNothing);

    await tester.tap(find.text(OkumaMetin.anketAtla));
    await tester.pumpAndSettle();
    expect(bitti, isTrue);
    expect(donen, isNull);
  });

  testWidgets('anket: yalnız öneri seçilince Gönder; puan boş kalabilir (yildiz null)', (tester) async {
    _boyut(tester, const Size(390, 844));
    OkumaAnketYaniti? donen;
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: AnketEkrani(onBitti: (y) => donen = y),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daha komik olsun'));
    await tester.pumpAndSettle();
    expect(find.text(OkumaMetin.anketGonder), findsOneWidget);

    await tester.tap(find.text(OkumaMetin.anketGonder));
    await tester.pumpAndSettle();
    expect(donen, isNotNull);
    expect(donen!.yildiz, isNull);
    expect(donen!.iyilestirmeKodlari, {'daha_komik'});
  });

  for (final boyut in const [Size(360, 640), Size(390, 844)]) {
    testWidgets('sonuç ${boyut.width.toInt()}x${boyut.height.toInt()}: motivasyon kartı düğmelerin üstünde ve görünür', (tester) async {
      _boyut(tester, boyut);
      await tester.pumpWidget(MaterialApp(
        theme: buildAppTheme(),
        home: SonucEkrani(
          sonuc: const OkumaSonuc(soruSayisi: 4, dogruSayisi: 1, dogruOrani: 25, kazanilanXp: 10),
          onYeni: () {},
          onKahraman: () {},
          onPdf: () async => OkumaPdfSonucu.hazir,
          onKapat: () {},
        ),
      ));
      await tester.pumpAndSettle();
      final motivasyon = tester.getRect(find.text(OkumaMetin.sonucTekrarGel));
      final yeni = tester.getRect(find.text(OkumaMetin.sonucYeni));
      expect(motivasyon.bottom, lessThanOrEqualTo(yeni.top), reason: 'motivasyon düğmenin altında kalıyor');
      expect(motivasyon.bottom, lessThanOrEqualTo(boyut.height), reason: 'motivasyon ekranın dışında');
    });
  }
}
