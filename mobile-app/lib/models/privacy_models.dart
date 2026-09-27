// Günlük hedef ve gizlilik (onay) modelleri.

/// public.get_daily_goal() sonucu.
class DailyGoal {
  const DailyGoal({
    required this.goal,
    required this.today,
    required this.completed,
    required this.shields,
  });

  /// Günlük soru hedefi (5, 10, 15 veya 20).
  final int goal;

  /// Bugün çözülen soru sayısı.
  final int today;
  final bool completed;

  /// Kazanılmış seri kalkanı sayısı (0-2).
  final int shields;

  static const options = [5, 10, 15, 20];

  double get progress => goal <= 0 ? 0 : (today / goal).clamp(0.0, 1.0).toDouble();
  int get remaining => (goal - today).clamp(0, goal);

  factory DailyGoal.fromMap(Map<String, dynamic> map) => DailyGoal(
        goal: (map['hedef'] as num).toInt(),
        today: (map['bugun'] as num).toInt(),
        completed: map['tamamlandi'] as bool? ?? false,
        shields: (map['seri_kalkani'] as num?)?.toInt() ?? 0,
      );
}

/// Veli rızası durumu.
enum ParentConsent { none, given, withdrawn }

/// public.get_consent_status() sonucu.
class ConsentStatus {
  const ConsentStatus({required this.noticeRead, required this.parentConsent});

  /// Verilen sürümdeki aydınlatma metni okundu mu.
  final bool noticeRead;
  final ParentConsent parentConsent;

  factory ConsentStatus.fromMap(Map<String, dynamic> map) => ConsentStatus(
        noticeRead: map['aydinlatma_okundu'] as bool? ?? false,
        parentConsent: switch (map['veli_riza'] as String?) {
          'verildi' => ParentConsent.given,
          'geri_cekildi' => ParentConsent.withdrawn,
          _ => ParentConsent.none,
        },
      );
}
