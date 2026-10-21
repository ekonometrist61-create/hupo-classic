import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/screens/okuma/okuma_tema.dart';
import 'package:ogrenci_hazirlik/widgets/okuma/okuma_v3.dart';

Widget _sarmala(Widget child, {bool hareketAzalt = false}) => MaterialApp(
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: hareketAzalt),
        child: c!,
      ),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('başlık bandı: tür, sınıf ve yaklaşık süre çipi görünür', (tester) async {
    await tester.pumpWidget(_sarmala(const SizedBox(
      width: 360,
      child: OkumaBaslikBandi(baslik: 'Kayıp Çan', tur: 'macera', sinifEtiketi: '4. sınıf', dakika: 3),
    )));
    expect(find.text('Kayıp Çan'), findsOneWidget);
    expect(find.text('Macera'), findsOneWidget);
    expect(find.text('4. sınıf'), findsOneWidget);
    expect(find.text(OkumaMetin.hikayeSure(3)), findsOneWidget);
    expect(find.text('3 dk'), findsOneWidget);
  });

  testWidgets('bilinmeyen tür genel "Hikâye" çipine düşer', (tester) async {
    await tester.pumpWidget(_sarmala(const OkumaTurCipi(tur: 'yok-boyle-bir-tur')));
    expect(find.text('Hikâye'), findsOneWidget);
  });

  testWidgets('atasözü kartı dokununca onTap çalışır', (tester) async {
    var dokunuldu = false;
    await tester.pumpWidget(_sarmala(SizedBox(
      width: 360,
      child: OkumaAtasozuKarti(metin: 'Damlaya damlaya göl olur', onTap: () => dokunuldu = true),
    )));
    await tester.tap(find.text('“Damlaya damlaya göl olur”'));
    expect(dokunuldu, isTrue);
  });

  testWidgets('geri sayım: hareket açıkken çubuk zamanla küçülür', (tester) async {
    await tester.pumpWidget(_sarmala(const OkumaGeriSayim(sure: Duration(seconds: 3))));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    final bar = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(bar.value, closeTo(0.5, 0.05));
  });

  testWidgets('geri sayım: hareket azaltmada çubuk yok, yalnız süre metni var', (tester) async {
    await tester.pumpWidget(_sarmala(const OkumaGeriSayim(sure: Duration(seconds: 3)), hareketAzalt: true));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('3 sn sonra sonraki soruya geçilecek'), findsOneWidget);
  });
}
