import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:ogrenci_hazirlik/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lottie animasyonları', () {
    for (final name in ['correct', 'wrong', 'star', 'confetti']) {
      test('$name.json geçerli bir Lottie dosyası', () async {
        final data = await rootBundle.load('assets/lottie/$name.json');
        final composition = await LottieComposition.fromByteData(data);
        expect(composition.duration.inMilliseconds, greaterThan(0));
      });
    }
  });

  group('Question.fromMap', () {
    test('şıkları anahtara göre sıralar ve Türkçe karakterleri korur', () {
      final q = Question.fromMap({
        'id': 'q1',
        'ders': 'Türkçe',
        'konu': 'Sözcükte Anlam',
        'alt_konu': null,
        'zorluk': 2,
        'soru_metni': '"Güzel" sözcüğünün eş anlamlısı hangisidir?',
        'siklar': {'C': 'Büyük', 'A': 'Çirkin', 'B': 'Hoş'},
      });
      expect(q.options.keys.toList(), ['A', 'B', 'C']);
      expect(q.options['B'], 'Hoş');
      expect(q.difficultyLabel, 'Orta');
      expect(q.ders, 'Türkçe');
    });
  });

  group('StudentStats', () {
    test('seviye ilerlemesi 100 XP üzerinden hesaplanır', () {
      const stats = StudentStats(xp: 130, level: 2);
      expect(stats.levelProgress, closeTo(0.3, 1e-9));
      expect(stats.xpToNextLevel, 70);
    });

    test('dün aktifse seri korunur, daha eskiyse 0 gösterilir', () {
      final today = DateTime(2026, 9, 20);
      expect(
        StudentStats(streakCount: 4, lastActiveDate: DateTime(2026, 9, 19))
            .streakAt(today),
        4,
      );
      expect(
        StudentStats(streakCount: 4, lastActiveDate: DateTime(2026, 9, 20))
            .streakAt(today),
        4,
      );
      expect(
        StudentStats(streakCount: 4, lastActiveDate: DateTime(2026, 9, 17))
            .streakAt(today),
        0,
      );
      expect(const StudentStats().streakAt(today), 0);
    });
  });

  group('AnswerResult.fromMap', () {
    test('submit_answer çıktısını okur', () {
      final r = AnswerResult.fromMap({
        'dogru_mu': true,
        'dogru_sik': 'C',
        'kazanilan_xp': 20,
        'xp': 120,
        'level': 2,
        'streak_count': 3,
        'sonraki_tekrar_tarihi': '2026-09-21T10:00:00Z',
      });
      expect(r.correct, isTrue);
      expect(r.correctOption, 'C');
      expect(r.earnedXp, 20);
      expect(r.level, 2);
    });
  });
}
