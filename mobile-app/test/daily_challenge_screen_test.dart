import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/daily_challenge_models.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/daily_challenge_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';

/// Sunucu yerine geçen sahte servis: doğru şık her zaman B.
class FakeRepository extends Fake implements QuizRepository {
  @override
  Future<AnswerResult> submitAnswer({
    required String questionId,
    required String? selectedOption,
    required int durationMs,
    String? requestId,
    String? kurtarmaOf,
  }) async {
    final correct = selectedOption == 'B';
    return AnswerResult(
      correct: correct,
      correctOption: 'B',
      earnedXp: correct ? 10 : 0,
      xp: correct ? 10 : 0,
      level: 1,
      streakCount: 1,
      steps: const ['Birinci adım.', 'İkinci adım.'],
    );
  }
}

const _challenge = DailyChallenge(
  gun: '2026-10-27',
  mevcut: true,
  toplam: 2,
  sorular: [
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
  ],
);

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        quizRepositoryProvider.overrideWithValue(FakeRepository()),
        dailyChallengeProvider
            .overrideWith((ref) async => _challenge),
      ],
      child: const MaterialApp(home: DailyChallengeScreen()),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('yanlış cevap: doğru şık ve çözüm adımları gösterilir',
      (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Çirkin'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Doğru cevap: B) Hoş'), findsOneWidget);
    expect(find.text('1. Birinci adım.'), findsOneWidget);
    expect(find.text('2. İkinci adım.'), findsOneWidget);
  });

  testWidgets('doğru cevap: açıklama kutusu gösterilmez', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Hoş'));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Doğru cevap:'), findsNothing);
    expect(find.text('Birinci adım.'), findsNothing);
  });
}
