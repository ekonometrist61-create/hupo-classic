// W4: Günlük görevler ekranı testleri.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/quests_screen.dart';

const _gorevler = [
  Quest(
    kod: 'gunluk_10_soru',
    baslik: 'Günlük soru',
    aciklama: 'Bugün 10 soru çöz',
    hedefDeger: 10,
    odulXp: 20,
    ilerleme: 7,
    tamamlandi: false,
    odulAlindi: false,
  ),
  Quest(
    kod: 'gunluk_5_dogru',
    baslik: 'Doğru seri',
    aciklama: 'Bugün 5 doğru cevap ver',
    hedefDeger: 5,
    odulXp: 20,
    ilerleme: 5,
    tamamlandi: true,
    odulAlindi: false,
  ),
  Quest(
    kod: 'gunluk_kurtarma',
    baslik: 'Yanlışlarını tekrar et',
    aciklama: 'Bugün 2 kurtarma yap',
    hedefDeger: 2,
    odulXp: 30,
    ilerleme: 2,
    tamamlandi: true,
    odulAlindi: true,
  ),
];

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myQuestsProvider.overrideWith((ref) async => _gorevler),
      ],
      child: const MaterialApp(home: QuestsScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('üç görev başlıkları görünür', (tester) async {
    await _pump(tester);

    expect(find.text('Günlük soru'), findsOneWidget);
    expect(find.text('Doğru seri'), findsOneWidget);
    expect(find.text('Yanlışlarını tekrar et'), findsOneWidget);
  });

  testWidgets('tamamlanmamış görevde Ödülü al butonu yok', (tester) async {
    await _pump(tester);

    // 'Günlük soru' tamamlanmadı → Ödülü al butonu olmamalı.
    expect(find.text('Ödülü al'), findsOneWidget); // Yalnızca 'Doğru seri' için.
  });

  testWidgets('ödül zaten alınmış görevde Tamamlandı rozeti var', (tester) async {
    await _pump(tester);

    expect(find.text('Tamamlandı'), findsOneWidget); // gunluk_kurtarma
  });

  testWidgets('geri düğmesi önceki ekrana döner', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          myQuestsProvider.overrideWith((ref) async => _gorevler),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuestsScreen()),
                ),
                child: const Text('aç'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();
    expect(find.byType(QuestsScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.byType(QuestsScreen), findsNothing);
  });
}
