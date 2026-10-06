import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/quiz_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';

/// Sunucu günlük ücretsiz soru hakkı bitince P0402 koduyla reddeder.
class _QuotaRepo extends Fake implements QuizRepository {
  @override
  Future<AnswerResult> submitAnswer({
    required String questionId,
    required String? selectedOption,
    required int durationMs,
    String? requestId,
  }) async {
    throw Exception('PostgrestException(message: Günlük ücretsiz soru hakkın doldu, code: P0402)');
  }
}

const _questions = [
  Question(
    id: 'q1',
    ders: 'Türkçe',
    konu: 'Sözcükte Anlam',
    zorluk: 1,
    text: 'Soru?',
    options: {'A': 'Bir', 'B': 'İki'},
  ),
];

void main() {
  testWidgets('günlük ücretsiz hak bitince nazik mesaj gösterilir ve quiz kapanır', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [quizRepositoryProvider.overrideWithValue(_QuotaRepo())],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const QuizScreen(title: 'Türkçe', questions: _questions),
                  )),
                  child: const Text('başla'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('başla'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('İki'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Bugünlük harikaydın!'), findsOneWidget);
    expect(find.textContaining('velinle konuşabilirsin'), findsOneWidget);
    expect(find.textContaining('bir kez daha dene'), findsNothing);

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();
    expect(find.byType(QuizScreen), findsNothing);
  });
}
