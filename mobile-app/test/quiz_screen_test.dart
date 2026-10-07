import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/quiz_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';

/// Sunucu yerine geçen sahte servis: doğru şık her zaman B.
class FakeRepository extends Fake implements QuizRepository {
  final calls = <String?>[];

  @override
  Future<AnswerResult> submitAnswer({
    required String questionId,
    required String? selectedOption,
    required int durationMs,
    String? requestId,
    String? kurtarmaOf,
  }) async {
    calls.add(selectedOption);
    final correct = selectedOption == 'B';
    return AnswerResult(
      correct: correct,
      correctOption: 'B',
      earnedXp: correct ? 10 : 0,
      xp: correct ? 10 : 0,
      level: 1,
      streakCount: 1,
      steps: const ['Birinci adım.', 'İkinci adım.'],
      timedOut: selectedOption == null,
    );
  }
}

const _questions = [
  Question(
    id: 'q1',
    ders: 'Türkçe',
    konu: 'Sözcükte Anlam',
    zorluk: 1,
    text: '"Güzel" sözcüğünün eş anlamlısı hangisidir?',
    options: {'A': 'Çirkin', 'B': 'Hoş', 'C': 'Büyük'},
  ),
  Question(
    id: 'q2',
    ders: 'Türkçe',
    konu: 'Noktalama',
    zorluk: 3,
    text: 'İkinci soru?',
    options: {'A': 'Bir', 'B': 'İki'},
  ),
];

Future<FakeRepository> _pump(WidgetTester tester) async {
  final repo = FakeRepository();
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [quizRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        home: QuizScreen(title: 'Türkçe', questions: _questions),
      ),
    ),
  );
  await tester.pump();
  return repo;
}

double _opacityOf(WidgetTester tester, String text) {
  final finder = find.ancestor(
    of: find.text(text),
    matching: find.byType(AnimatedOpacity),
  );
  return tester.widget<AnimatedOpacity>(finder.first).opacity;
}

void main() {
  testWidgets('üst şerit: süre geri sayar, XP ve soru sayacı görünür',
      (tester) async {
    await _pump(tester);

    expect(find.text('0:45'), findsOneWidget); // kolay soru: 45 sn
    expect(find.text('+0 XP'), findsOneWidget);
    expect(find.textContaining('Soru 1/2'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0:44'), findsOneWidget);
  });

  testWidgets('doğru cevap: yeşil pencere, konfeti ve XP; çözüm adımları sırayla açılır',
      (tester) async {
    final repo = await _pump(tester);

    await tester.tap(find.text('Hoş'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(repo.calls, ['B']);
    expect(find.text('Harikasın!'), findsOneWidget);
    expect(find.text('+10 XP kazandın, böyle devam!'), findsOneWidget);
    expect(find.text('Birlikte çözelim: adım adım'), findsOneWidget);

    // Adımlar başta görünmez, 700 ms aralıkla belirir.
    expect(_opacityOf(tester, 'Birinci adım.'), 0);
    await tester.pump(const Duration(milliseconds: 750));
    expect(_opacityOf(tester, 'Birinci adım.'), 1);
    expect(_opacityOf(tester, 'İkinci adım.'), 0);
    await tester.pump(const Duration(milliseconds: 700));
    expect(_opacityOf(tester, 'İkinci adım.'), 1);

    // Anlık XP üst şeritte güncellenir.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('+10 XP'), findsWidgets);
  });

  testWidgets('yanlış cevap: kırmızı pencere ve doğru şık bilgisi', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Çirkin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Sorun değil, denemek öğretir!'), findsOneWidget);
    expect(find.text('Doğru cevap: B'), findsOneWidget);
    expect(find.text('Harikasın!'), findsNothing);
  });

  testWidgets('süre dolunca boş cevap gönderilir', (tester) async {
    final repo = await _pump(tester);

    await tester.pump(const Duration(seconds: 46));
    await tester.pump(const Duration(milliseconds: 500));

    expect(repo.calls, [null]);
    expect(find.text('Süre doldu, ama pes yok!'), findsOneWidget);
  });

  testWidgets('sonraki soruya geçince süre ve pencere sıfırlanır', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Hoş'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Sonraki soru'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('İkinci soru?'), findsOneWidget);
    expect(find.text('Harikasın!'), findsNothing);
    expect(find.text('1:30'), findsOneWidget); // zor soru: 90 sn
    expect(find.textContaining('Soru 2/2'), findsOneWidget);
  });
}
