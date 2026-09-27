import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/league_models.dart';
import '../models/membership_models.dart';
import '../models/models.dart';
import '../models/privacy_models.dart';

/// Supabase ile konuşan tek katman.
///
/// Not: `questions` tablosunda dogru_sik sütununa istemci erişemez
/// (bkz. 20260920000300_hide_correct_answer.sql), bu yüzden sütunlar açıkça
/// listelenir ve cevap kontrolü sunucudaki submit_answer() ile yapılır.
class QuizRepository {
  QuizRepository(this._client);

  final SupabaseClient _client;

  static const _questionColumns =
      'id, ders, konu, alt_konu, zorluk, soru_metni, siklar';

  String get _uid {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthException('Oturum bulunamadı');
    return user.id;
  }

  Future<Profile?> fetchProfile() async {
    final row = await _client
        .from('profiles')
        .select('id, role, full_name')
        .eq('id', _uid)
        .maybeSingle();
    return row == null ? null : Profile.fromMap(row);
  }

  Future<StudentStats> fetchStats() async {
    final row = await _client
        .from('student_stats')
        .select('xp, level, streak_count, last_active_date, seri_kalkani')
        .eq('student_id', _uid)
        .maybeSingle();
    return row == null ? const StudentStats() : StudentStats.fromMap(row);
  }

  /// Onaylı sorusu olan dersler ve soru sayıları.
  Future<List<SubjectInfo>> fetchSubjects() async {
    final rows = await _client
        .from('questions')
        .select('ders')
        .eq('onay_durumu', 'onaylandi');

    final counts = <String, int>{};
    for (final row in rows) {
      final ders = row['ders'] as String;
      counts[ders] = (counts[ders] ?? 0) + 1;
    }
    final subjects = [
      for (final e in counts.entries)
        SubjectInfo(ders: e.key, questionCount: e.value),
    ]..sort((a, b) => a.ders.compareTo(b.ders));
    return subjects;
  }

  Future<List<String>> _dueQuestionIds() async {
    final rows = await _client
        .from('user_answers')
        .select('question_id')
        .eq('student_id', _uid)
        .lte('sonraki_tekrar_tarihi', DateTime.now().toUtc().toIso8601String());
    return [for (final r in rows) r['question_id'] as String];
  }

  Future<int> fetchDueCount() async => (await _dueQuestionIds()).length;

  /// Bir ders için soru seti: önce hiç çözülmemiş / tekrar zamanı gelmiş
  /// sorular, sonra kalanlar; her grup kendi içinde karıştırılır.
  Future<List<Question>> fetchQuizQuestions(String ders, {int limit = 10}) async {
    final rows = await _client
        .from('questions')
        .select(_questionColumns)
        .eq('onay_durumu', 'onaylandi')
        .eq('ders', ders);
    final questions = [for (final r in rows) Question.fromMap(r)];
    if (questions.isEmpty) return [];

    final answered = await _client
        .from('user_answers')
        .select('question_id, sonraki_tekrar_tarihi')
        .eq('student_id', _uid)
        .inFilter('question_id', [for (final q in questions) q.id]);

    final now = DateTime.now();
    final notDue = <String>{
      for (final a in answered)
        if (DateTime.parse(a['sonraki_tekrar_tarihi'] as String).isAfter(now))
          a['question_id'] as String,
    };

    final priority = questions.where((q) => !notDue.contains(q.id)).toList()
      ..shuffle();
    final rest = questions.where((q) => notDue.contains(q.id)).toList()
      ..shuffle();
    return [...priority, ...rest].take(limit).toList();
  }

  /// Tekrar zamanı gelmiş sorular (aralıklı tekrar).
  Future<List<Question>> fetchReviewQuestions({int limit = 10}) async {
    final ids = await _dueQuestionIds();
    if (ids.isEmpty) return [];

    final rows = await _client
        .from('questions')
        .select(_questionColumns)
        .eq('onay_durumu', 'onaylandi')
        .inFilter('id', ids);
    final questions = [for (final r in rows) Question.fromMap(r)]..shuffle();
    return questions.take(limit).toList();
  }

  /// [selectedOption] null ise süre dolmuştur (yanlış sayılır).
  Future<AnswerResult> submitAnswer({
    required String questionId,
    required String? selectedOption,
    required int durationMs,
  }) async {
    final data = await _client.rpc('submit_answer', params: {
      'p_question_id': questionId,
      'p_secilen_sik': selectedOption,
      'p_sure_ms': durationMs,
    });
    return AnswerResult.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<List<BadgeInfo>> fetchBadges() async {
    final data = await _client.rpc('get_student_badges', params: {
      'p_student_id': _uid,
    });
    return [
      for (final row in (data as List))
        BadgeInfo.fromMap(Map<String, dynamic>.from(row as Map)),
    ];
  }

  Future<LeagueStatus> fetchLeague() async {
    final data = await _client.rpc('get_league_status', params: {'p_student_id': _uid});
    return LeagueStatus.fromMap(Map<String, dynamic>.from(data as Map));
  }

  /// Üyelik durumu. RPC henüz yoksa ya da hata verirse "bilinmiyor" döner;
  /// çağıran taraf bu durumda hiçbir şey göstermez.
  Future<MembershipStatus> fetchMembership() async {
    try {
      final data = await _client.rpc('my_subscription_status');
      final row = data is List ? (data.isEmpty ? null : data.first) : data;
      if (row is! Map) return MembershipStatus.unknown;
      return MembershipStatus.fromMap(Map<String, dynamic>.from(row));
    } catch (_) {
      return MembershipStatus.unknown;
    }
  }

  Future<ProfileOverview> fetchOverview() async {
    final data = await _client.rpc('get_profile_overview', params: {'p_student_id': _uid});
    return ProfileOverview.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<List<AppNotification>> fetchNotifications({int limit = 40}) async {
    final rows = await _client
        .from('notifications')
        .select('id, tur, baslik, mesaj, ikon, okundu, created_at')
        .eq('alici_id', _uid)
        .order('created_at', ascending: false)
        .limit(limit);
    return [for (final r in rows) AppNotification.fromMap(r)];
  }

  Future<int> fetchUnreadCount() async {
    final rows = await _client
        .from('notifications')
        .select('id')
        .eq('alici_id', _uid)
        .eq('okundu', false)
        .limit(100);
    return rows.length;
  }

  Future<void> markAllNotificationsRead() async {
    await _client.rpc('mark_notifications_read');
  }

  Future<DailyGoal> fetchDailyGoal() async {
    final data = await _client.rpc('get_daily_goal', params: {'p_student_id': _uid});
    return DailyGoal.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> setDailyGoal(int goal) async {
    await _client.rpc('set_daily_goal', params: {'p_hedef': goal});
  }

  Future<ConsentStatus> fetchConsent(String version) async {
    final data = await _client.rpc('get_consent_status', params: {
      'p_cocuk_id': _uid,
      'p_surum': version,
    });
    return ConsentStatus.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> recordNoticeRead(String version) async {
    await _client.rpc('record_notice_read', params: {'p_surum': version});
  }

  /// Kullanıcının kendi verilerinin tamamı (JSON metni olarak).
  Future<Map<String, dynamic>> exportMyData() async {
    final data = await _client.rpc('export_my_data');
    return Map<String, dynamic>.from(data as Map);
  }

  /// Hesabı ve bağlı tüm verileri kalıcı olarak siler, ardından oturumu kapatır.
  Future<void> deleteMyAccount() async {
    await _beforeSignOut();
    await _client.rpc('delete_my_account');
    await _client.auth.signOut();
  }

  Future<void> signOut() async {
    await _beforeSignOut();
    await _client.auth.signOut();
  }

  /// Push için: çıkıştan ÖNCE (oturum varken) bu cihazın bildirim jetonu silinir.
  /// PushHost tarafından atanır; hata çıkışı asla engellemez.
  Future<void> Function()? onBeforeSignOut;

  Future<void> _beforeSignOut() async {
    try {
      await onBeforeSignOut?.call();
    } catch (_) {}
  }
}
