// Kişisel rekor (Personal Best) servisi.
//
// Öğrencinin ders, konu veya genel bazda ulaştığı en yüksek başarı ve hız
// rekorlarını yerel depolamada saklar ve yeni bir rekor kırıldığında bildirim üretir.

import 'package:shared_preferences/shared_preferences.dart';

class PersonalBest {
  PersonalBest._(this._prefs);

  static PersonalBest? _instance;
  final SharedPreferences _prefs;

  static const _kPrefix = 'pb_';
  static const _kStreakRecordKey = 'personal_best_streak';
  static const _kSpeedRecordKey = 'personal_best_fastest_ms';

  static Future<PersonalBest> getInstance() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = PersonalBest._(prefs);
    return _instance!;
  }

  /// Öğrencinin en uzun seri rekoru.
  int getBestStreak() => _prefs.getInt(_kStreakRecordKey) ?? 0;

  /// Yeni seri kişisel rekor mu kontrol eder ve günceller.
  bool updateStreak(int currentStreak) {
    final best = getBestStreak();
    if (currentStreak > best) {
      _prefs.setInt(_kStreakRecordKey, currentStreak);
      return true;
    }
    return false;
  }

  /// Bir dersteki en yüksek doğru sayısı veya puanı.
  int getBestScore(String subject) =>
      _prefs.getInt('$_kPrefix${subject.toLowerCase()}_score') ?? 0;

  bool updateBestScore(String subject, int score) {
    final best = getBestScore(subject);
    if (score > best) {
      _prefs.setInt('$_kPrefix${subject.toLowerCase()}_score', score);
      return true;
    }
    return false;
  }

  /// Doğru cevaplanan en hızlı süre (milisaniye).
  int? getFastestAnswerMs(String subject) =>
      _prefs.getInt('$_kPrefix${subject.toLowerCase()}_fastest');

  bool updateFastestAnswer(String subject, int durationMs) {
    final current = getFastestAnswerMs(subject);
    if (current == null || durationMs < current) {
      _prefs.setInt('$_kPrefix${subject.toLowerCase()}_fastest', durationMs);
      return true;
    }
    return false;
  }
}
