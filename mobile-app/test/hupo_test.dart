import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/widgets/hupo/hupo.dart';

Widget _host(Widget child, {bool reduce = false}) => MaterialApp(
      builder: (context, c) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: c!,
      ),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('her duruşun PNG dosyası pakette var ve boş değil', () async {
    for (final pose in HupoPose.values) {
      final data = await rootBundle.load(pose.assetPath);
      expect(data.lengthInBytes, greaterThan(1000), reason: pose.assetPath);
    }
  });

  test('her HupoMood en az bir duruşa sahip ve varyant döngüsü güvenli', () {
    for (final mood in HupoMood.values) {
      expect(mood.poses, isNotEmpty);
      expect(mood.pose(0), isA<HupoPose>());
      expect(mood.pose(-7), isA<HupoPose>());
      expect(mood.pose(9999), isA<HupoPose>());
    }
  });

  test('yanlış cevap duruşları utandırmaz (kızan/ağlayan yok)', () {
    for (final p in HupoMood.wrong.poses) {
      expect(p, isNot(HupoPose.uzulen));
    }
  });

  testWidgets('Hupo Türkçe anlamsal etiketle görünür', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const Hupo(mood: HupoMood.correct, size: 100)));
    expect(find.bySemanticsLabel('Hupo, baykuş rehberin'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('animasyonlu Hupo süzülür; hareket azaltılınca çökmeden durur', (tester) async {
    await tester.pumpWidget(_host(const Hupo(pose: HupoPose.ayakta, animated: true)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(_host(const Hupo(pose: HupoPose.ayakta, animated: true), reduce: true));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tüm duruşlar hata vermeden çizilir (resim çözülür)', (tester) async {
    await tester.pumpWidget(_host(Wrap(children: [
      for (final p in HupoPose.values) Hupo(pose: p, size: 60),
    ])));
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(Wrap));
      for (final p in HupoPose.values) {
        await precacheImage(AssetImage(p.assetPath), ctx);
      }
    });
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
