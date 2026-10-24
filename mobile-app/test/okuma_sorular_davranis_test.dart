// Soru ekranı davranışları: otomatik geçiş yok (WCAG 2.2.1) ve her zaman görünen geri düğmesi.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/screens/okuma/okuma_tema.dart';
import 'package:ogrenci_hazirlik/screens/okuma/sorular_ekrani.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';

const _sorular = [
  OkumaSoru(
    id: 'q1',
    metin: 'Birinci soru?',
    secenekler: [OkumaSecenek(id: 'a', metin: 'Bir'), OkumaSecenek(id: 'b', metin: 'İki')],
  ),
  OkumaSoru(
    id: 'q2',
    metin: 'İkinci soru?',
    secenekler: [OkumaSecenek(id: 'a', metin: 'Üç'), OkumaSecenek(id: 'b', metin: 'Dört')],
  ),
];

Widget _ekran({required VoidCallback onGeri}) => MaterialApp(
      theme: buildAppTheme(),
      home: SorularEkrani(
        sorular: _sorular,
        cevapKontrol: (soruId, secenekId) async => const OkumaCevapSonucu(
          dogru: false,
          aciklama: 'Açıklama metni.',
          dogruSecenekId: 'a',
        ),
        onBitti: (_) {},
        onGeri: onGeri,
      ),
    );

void main() {
  testWidgets('yanlış cevaptan sonra soru kendiliğinden değişmez', (tester) async {
    await tester.pumpWidget(_ekran(onGeri: () {}));
    await tester.pump();
    await tester.tap(find.text('İki'));
    await tester.pump();
    await tester.tap(find.text(OkumaMetin.soruCevapla));
    await tester.pump();
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Birinci soru?'), findsOneWidget);
    expect(find.text(OkumaMetin.soruSonraki), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('geri düğmesi her zaman görünür ve onGeri çağırır', (tester) async {
    var geriSayisi = 0;
    await tester.pumpWidget(_ekran(onGeri: () => geriSayisi++));
    await tester.pump();
    await tester.tap(find.byTooltip(OkumaMetin.geri));
    await tester.pump();
    expect(geriSayisi, 1);
  });
}
