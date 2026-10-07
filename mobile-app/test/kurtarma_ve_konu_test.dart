// W1: kurtarma (recovery) akışı, Öğren konu kırılımı ve Öğren sekmesi yönlendirmesi.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/learn_screen.dart';
import 'package:ogrenci_hazirlik/screens/quiz_screen.dart';
import 'package:ogrenci_hazirlik/screens/subject_topics_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';

class _SubmitCall {
  _SubmitCall(this.questionId, this.selectedOption, this.kurtarmaOf);
  final String questionId;
  final String? selectedOption;
  final String? kurtarmaOf;
}

/// Doğru şık her zaman 'B'. Kurtarma: doğru VE kurtarmaOf doluysa isRecovery=true.
class _FakeRepo extends Fake implements QuizRepository {
  final calls = <_SubmitCall>[];
  List<Question> quizResult = const [];
  List<TopicProgress> topics = const [];
  List<SubjectInfo> subjects = const [];

  @override
  Future<AnswerResult> submitAnswer({
    required String questionId,
    required String? selectedOption,
    required int durationMs,
    String? requestId,
    String? kurtarmaOf,
  }) async {
    calls.add(_SubmitCall(questionId, selectedOption, kurtarmaOf));
    final correct = selectedOption == 'B';
    final recovery = correct && kurtarmaOf != null;
    return AnswerResult(
      correct: correct,
      correctOption: 'B',
      earnedXp: correct ? (recovery ? 15 : 10) : 0,
      xp: correct ? (recovery ? 15 : 10) : 0,
      level: 1,
      streakCount: 1,
      isRecovery: recovery,
    );
  }

  @override
  Future<List<Question>> fetchQuizQuestions(String ders, {String? konu, int limit = 10}) async =>
      quizResult;

  @override
  Future<List<TopicProgress>> fetchTopicProgress(String ders) async => topics;

  @override
  Future<List<SubjectInfo>> fetchSubjects() async => subjects;

  @override
  Future<int> fetchDueCount() async => 0;
}

const _r1 = Question(
  id: 'r1',
  ders: 'Matematik',
  konu: 'Kesirler',
  zorluk: 1,
  text: 'Soru 1?',
  options: {'A': 'Yanlış', 'B': 'Doğru'},
);
const _r2 = Question(
  id: 'r2',
  ders: 'Matematik',
  konu: 'Kesirler',
  zorluk: 1,
  text: 'Soru 2?',
  options: {'A': 'Yanlış', 'B': 'Doğru'},
);
const _r3 = Question(
  id: 'r3',
  ders: 'Matematik',
  konu: 'Başka Konu',
  zorluk: 1,
  text: 'Soru 3?',
  options: {'A': 'Yanlış', 'B': 'Doğru'},
);

Future<_FakeRepo> _pumpQuiz(
  WidgetTester tester, {
  required List<Question> questions,
}) async {
  final repo = _FakeRepo();
  await tester.binding.setSurfaceSize(const Size(420, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [quizRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: QuizScreen(title: 'Matematik', questions: questions),
      ),
    ),
  );
  await tester.pump();
  return repo;
}

void main() {
  group('Kurtarma akışı (Benzer Soru Çöz)', () {
    testWidgets('aynı konudan soru yoksa Benzer Soru Çöz gösterilmez', (tester) async {
      await _pumpQuiz(tester, questions: const [_r1, _r3]); // farklı konular
      await tester.tap(find.text('Yanlış'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Benzer Soru Çöz'), findsNothing);
      expect(find.text('Sonraki soru'), findsOneWidget);
    });

    testWidgets('aynı konudan soru varsa buton görünür ve kuyruğu yeniden sıralar',
        (tester) async {
      // r2 (aynı konu) r1'in hemen ardında DEĞİL; buton kuyruğu yeniden sıralamalı.
      final repo = await _pumpQuiz(tester, questions: const [_r1, _r3, _r2]);

      await tester.tap(find.text('Yanlış'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Benzer Soru Çöz'), findsOneWidget);
      await tester.tap(find.text('Benzer Soru Çöz'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // r2, r3'ün önüne geçmeli (yeniden sıralama).
      expect(find.text('Soru 2?'), findsOneWidget);
      expect(find.text('Soru 3?'), findsNothing);

      await tester.tap(find.text('Doğru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(repo.calls.last.questionId, 'r2');
      expect(repo.calls.last.kurtarmaOf, 'r1');
      expect(find.text('Kurtardın!'), findsOneWidget);
      expect(find.textContaining('+15 XP'), findsOneWidget);

      // Kurtarma tek seferliktir: sonraki sorunun gönderiminde kurtarmaOf taşınmaz.
      await tester.tap(find.text('Sonraki soru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Soru 3?'), findsOneWidget);
      await tester.tap(find.text('Doğru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(repo.calls.last.kurtarmaOf, isNull);
    });

    testWidgets('Sonraki soru seçilirse kurtarma denenmeden devam edilir', (tester) async {
      final repo = await _pumpQuiz(tester, questions: const [_r1, _r2]);

      await tester.tap(find.text('Yanlış'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Sonraki soru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('Doğru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(repo.calls.last.kurtarmaOf, isNull);
      expect(find.text('Kurtardın!'), findsNothing);
      expect(find.text('Harikasın!'), findsOneWidget);
    });
  });

  group('Öğren sekmesi: konu kırılımı', () {
    Future<void> pumpLearn(WidgetTester tester, _FakeRepo repo) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [quizRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(home: LearnScreen()),
        ),
      );
      await tester.pump();
    }

    testWidgets('ders seçilince SubjectTopicsScreen açılır', (tester) async {
      final repo = _FakeRepo()
        ..subjects = const [SubjectInfo(ders: 'Matematik', questionCount: 12)];
      await pumpLearn(tester, repo);

      await tester.tap(find.text('Matematik'));
      await tester.pumpAndSettle();

      expect(find.byType(SubjectTopicsScreen), findsOneWidget);
      expect(find.text('Karışık çalış (tüm konular)'), findsOneWidget);
    });

    testWidgets('6 sorudan az konu "Yetersiz veri" gösterir, 6+ olan oran gösterir',
        (tester) async {
      final repo = _FakeRepo()
        ..topics = const [
          TopicProgress(konu: 'Kesirler', toplam: 8, dogru: 6, oran: 75),
          TopicProgress(konu: 'Ondalık', toplam: 2, dogru: 2),
        ];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [quizRepositoryProvider.overrideWithValue(repo)],
          child: const MaterialApp(home: SubjectTopicsScreen(ders: 'Matematik')),
        ),
      );
      await tester.pump();

      expect(find.text('%75'), findsOneWidget);
      expect(find.textContaining('Yetersiz veri'), findsOneWidget);
    });
  });
}
