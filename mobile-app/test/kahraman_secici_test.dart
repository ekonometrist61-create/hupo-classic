// Kahraman seçici: büyük/kompakt kartlar, hayvan ve araç alt seçenekleri, "Diğer" bölümü.
// Sunucuya yalnız tür kodu gider; alt seçenek (At, Otomobil) yalnız ad önerisidir.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_kahraman.dart';
import 'package:ogrenci_hazirlik/widgets/okuma/kahraman_secici.dart';

class _Kayit {
  KahramanTuru? tur;
  String? alt;
  String? isim;
}

Future<_Kayit> _ac(WidgetTester tester, {double yaziOlcegi = 1.0, Size boyut = const Size(390, 844)}) async {
  final kayit = _Kayit();
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = boyut;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(yaziOlcegi)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) => KahramanSecici(
              secili: kayit.tur,
              secilenAlt: kayit.alt,
              onSec: (tur, {alt, isim}) => setState(() {
                kayit
                  ..tur = tur
                  ..alt = alt
                  ..isim = isim;
              }),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return kayit;
}

Future<void> _dokun(WidgetTester tester, Finder bul) async {
  await tester.ensureVisible(bul);
  await tester.pump();
  await tester.tap(bul);
}

void main() {
  testWidgets('ana kartlar: Ben ve Hupo', (tester) async {
    final k = await _ac(tester);
    expect(find.text('Kahramanını seç'), findsOneWidget);
    await _dokun(tester, find.text('Ben'));
    await tester.pump();
    expect(k.tur, KahramanTuru.ben);
    await _dokun(tester, find.text('Hupo'));
    await tester.pump();
    expect(k.tur, KahramanTuru.hazir);
  });

  testWidgets('Hayvan Dostlarımız: tür hayvan, alt seçenekler at, aslan, fil; seçim ad önerir', (tester) async {
    final k = await _ac(tester);
    await _dokun(tester, find.text('Hayvan Dostlarımız'));
    await tester.pump();
    expect(k.tur, KahramanTuru.hayvan);
    for (final ad in ['At', 'Aslan', 'Fil', 'Kartal']) {
      expect(find.text(ad), findsOneWidget, reason: ad);
    }
    await _dokun(tester, find.text('Fil'));
    await tester.pump();
    expect(k.tur, KahramanTuru.hayvan);
    expect(k.alt, 'fil');
    expect(k.isim, 'Fil');
  });

  testWidgets('Araçlar: otomobil, vapur ve balon seçilebilir; tür arac', (tester) async {
    final k = await _ac(tester);
    await _dokun(tester, find.text('Araçlar'));
    await tester.pump();
    expect(k.tur, KahramanTuru.arac);
    for (final ad in ['Otomobil', 'Vapur', 'Balon']) {
      expect(find.text(ad), findsOneWidget, reason: ad);
    }
    await _dokun(tester, find.text('Otomobil'));
    await tester.pump();
    expect(k.alt, 'otomobil');
    expect(k.isim, 'Otomobil');
  });

  testWidgets('Ailem: annem, babam, kardeşim; tür kodları sunucudakiyle aynı, ad önerilmez', (tester) async {
    final k = await _ac(tester);
    await _dokun(tester, find.text('Ailem'));
    await tester.pump();
    expect(find.text('Annem'), findsOneWidget);
    expect(find.text('Babam'), findsOneWidget);
    expect(find.text('Kardeşim'), findsOneWidget);
    await _dokun(tester, find.text('Babam'));
    await tester.pump();
    expect(k.tur, KahramanTuru.baba);
    expect(k.isim, isNull, reason: 'aile üyesinin adını çocuk yazar');
  });

  testWidgets('Diğer seçenekler açılır: Hayalî karakter ve Başka biri', (tester) async {
    final k = await _ac(tester);
    expect(find.text('Başka biri'), findsNothing);
    await _dokun(tester, find.text('Diğer kahraman seçenekleri'));
    await tester.pump();
    expect(find.text('Hayalî karakter'), findsOneWidget);
    await _dokun(tester, find.text('Başka biri'));
    await tester.pump();
    expect(k.tur, KahramanTuru.baskaBiri);
  });

  testWidgets('hiçbir kartta büyükanne/büyükbaba görseli kullanılmaz', (tester) async {
    await _ac(tester);
    await _dokun(tester, find.text('Diğer kahraman seçenekleri'));
    await _dokun(tester, find.text('Ailem'));
    await tester.pump();
    final yollar = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => i.image)
        .whereType<ResizeImage>()
        .map((r) => r.imageProvider)
        .whereType<AssetImage>()
        .map((a) => a.assetName)
        .toList();
    expect(yollar, isNotEmpty);
    expect(yollar.where((y) => y.contains('buyukanne') || y.contains('buyukbaba')), isEmpty);
  });

  for (final olcek in [1.0, 2.0]) {
    testWidgets('taşma yok (yazı ölçeği $olcek, dar ekran)', (tester) async {
      await _ac(tester, yaziOlcegi: olcek, boyut: const Size(320, 640));
      await _dokun(tester, find.text('Hayvan Dostlarımız'));
      await tester.pump();
      await _dokun(tester, find.text('Diğer kahraman seçenekleri'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}
