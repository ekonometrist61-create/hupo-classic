import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/providers/okuma_providers.dart';
import 'package:ogrenci_hazirlik/screens/okuma/okuduklarim_ekrani.dart';
import 'package:ogrenci_hazirlik/screens/okuma/okuma_tema.dart';
import 'package:ogrenci_hazirlik/services/okuma_cihaz_deposu.dart';

// Hupo maskotu sürekli animasyon içerir; pumpAndSettle kullanılmaz (diğer okuma testleriyle aynı kural).
Future<void> _ac(WidgetTester tester, List<OkumaSozlukKaydi> sozlugum) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        okumaOkuduklarimProvider.overrideWith((ref) => const []),
        okumaSozlugumProvider.overrideWith((ref) => sozlugum),
      ],
      child: MaterialApp(home: OkuduklarimEkrani(onAc: (_) {})),
    ),
  );
  await tester.pump();
  await tester.tap(find.widgetWithText(ChoiceChip, OkumaMetin.sozlugumSekme));
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  testWidgets('Sözlüğüm sekmesi eklenen atasözünü ve anlamını gösterir', (tester) async {
    await _ac(tester, [
      OkumaSozlukKaydi(metin: 'Sabırla koruk helva olur.', anlam: 'Acele etmeden iyi sonuç alınır.', at: DateTime(2026, 10, 21)),
    ]);
    expect(find.text('“Sabırla koruk helva olur.”'), findsOneWidget);
    expect(find.text('Acele etmeden iyi sonuç alınır.'), findsOneWidget);
    expect(find.text(OkumaMetin.sozlugumBos), findsNothing);
  });

  testWidgets('Sözlüğüm boşsa nazik davet gösterir; puan veya sayaç yoktur', (tester) async {
    await _ac(tester, const []);
    expect(find.text(OkumaMetin.sozlugumBos), findsOneWidget);
    expect(find.textContaining('kelime'), findsNothing);
  });
}
