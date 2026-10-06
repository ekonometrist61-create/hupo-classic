import 'dart:math';

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

  SupabaseClient get supabaseClient => _client;

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
    Future<Map<String, dynamic>?> oku(String kolonlar) => _client
        .from('student_stats')
        .select(kolonlar)
        .eq('student_id', _uid)
        .maybeSingle();

    Map<String, dynamic>? row;
    try {
      row = await oku(
          'xp, level, streak_count, last_active_date, seri_kalkani, aktif_karakter');
    } on PostgrestException catch (e) {
      // 42703: sütun yok (aktif_karakter migration'ı uzak veritabanına henüz uygulanmadı).
      if (e.code != '42703') rethrow;
      row = await oku('xp, level, streak_count, last_active_date, seri_kalkani');
    }
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

  static final _rng = Random.secure();

  static String _newRequestId() {
    final b = List<int>.generate(16, (_) => _rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}'
        '-${h.substring(16, 20)}-${h.substring(20)}';
  }

  /// [selectedOption] null ise süre dolmuştur (yanlış sayılır).
  /// [requestId] çift gönderim ve ağ tekrarını önler; null ise sunucu eski davranışı uygular.
  Future<AnswerResult> submitAnswer({
    required String questionId,
    required String? selectedOption,
    required int durationMs,
    String? requestId,
  }) async {
    requestId ??= _newRequestId();
    final params = {
      'p_question_id': questionId,
      'p_secilen_sik': selectedOption,
      'p_sure_ms': durationMs,
    };
    Object? data;
    try {
      data = await _client.rpc('submit_answer', params: {
        ...params,
        'p_request_id': requestId,
      });
    } on PostgrestException catch (e) {
      // Sunucuda requestId'li yeni imza henüz yoksa (migration uygulanmadı) eski imzayla dene.
      if (e.code != 'PGRST202') rethrow;
      data = await _client.rpc('submit_answer', params: params);
    }
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

  // ── Kurtarılan RPC'ler ──────────────────────────────────────────────

  /// public.get_app_config()
  Future<Map<String, dynamic>> fetchAppConfig() async {
    try {
      final res = await _client.rpc('get_app_config');
      return Map<String, dynamic>.from(res as Map);
    } catch (_) {
      return {};
    }
  }

  /// public.get_carpim_sifreleri()
  Future<List<Map<String, dynamic>>> fetchCiphers() async {
    final res = await _client.rpc('get_carpim_sifreleri');
    return [
      for (final item in (res as List? ?? const []))
        Map<String, dynamic>.from(item as Map),
    ];
  }

  /// public.get_carpim_sifre_detay(p_sifre_id)
  Future<Map<String, dynamic>> fetchCipherDetail(String sifreId) async {
    final res = await _client.rpc('get_carpim_sifre_detay', params: {'p_sifre_id': sifreId});
    return Map<String, dynamic>.from(res as Map);
  }

  /// public.submit_cipher_answer(p_sifre_id, p_asama, p_soru_index, p_cevap)
  Future<Map<String, dynamic>> submitCipherAnswer({
    required String sifreId,
    required String asama,
    required int soruIndex,
    required int cevap,
  }) async {
    final res = await _client.rpc('submit_cipher_answer', params: {
      'p_sifre_id': sifreId,
      'p_asama': asama,
      'p_soru_index': soruIndex,
      'p_cevap': cevap,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  /// public.complete_cipher_stage(p_sifre_id, p_asama)
  Future<Map<String, dynamic>> completeCipherStage({
    required String sifreId,
    required String asama,
  }) async {
    final res = await _client.rpc('complete_cipher_stage', params: {
      'p_sifre_id': sifreId,
      'p_asama': asama,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  /// public.report_taught_friend(p_sifre_id)
  Future<Map<String, dynamic>> reportTaughtFriend(String sifreId) async {
    final res = await _client.rpc('report_taught_friend', params: {'p_sifre_id': sifreId});
    return Map<String, dynamic>.from(res as Map);
  }

  /// public.get_daily_challenge()
  Future<Map<String, dynamic>> fetchDailyChallenge() async {
    final res = await _client.rpc('get_daily_challenge');
    return Map<String, dynamic>.from(res as Map);
  }

  /// public.complete_daily_challenge()
  Future<Map<String, dynamic>> completeDailyChallenge() async {
    final res = await _client.rpc('complete_daily_challenge');
    return Map<String, dynamic>.from(res as Map);
  }

  /// public.list_bookmarks()
  Future<List<Map<String, dynamic>>> fetchSavedQuestions() async {
    final res = await _client.rpc('list_bookmarks');
    return [
      for (final item in (res as List? ?? const []))
        Map<String, dynamic>.from(item as Map),
    ];
  }

  /// public.toggle_bookmark(p_question_id)
  Future<bool> toggleBookmark(String questionId) async {
    final res = await _client.rpc('toggle_bookmark', params: {'p_question_id': questionId});
    return res as bool? ?? false;
  }

  /// public.report_question(p_question_id, p_neden, p_not)
  Future<Map<String, dynamic>> reportQuestion({
    required String questionId,
    required String neden,
    String? notMetni,
  }) async {
    final res = await _client.rpc('report_question', params: {
      'p_question_id': questionId,
      'p_neden': neden,
      'p_not': notMetni,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  /// public.get_supported_grades()
  Future<List<int>> fetchSupportedGrades() async {
    final res = await _client.rpc('get_supported_grades');
    final map = Map<String, dynamic>.from(res as Map);
    final siniflar = map['siniflar'] as List? ?? const [];
    return [for (final s in siniflar) (s as num).toInt()];
  }

  /// public.set_my_grade(p_sinif)
  Future<int> setMyGrade(int sinif) async {
    final res = await _client.rpc('set_my_grade', params: {'p_sinif': sinif});
    return (res as num).toInt();
  }

  /// public.get_my_characters()
  Future<List<Map<String, dynamic>>> fetchMyCharacters() async {
    final res = await _client.rpc('get_my_characters');
    return [
      for (final item in (res as List? ?? const []))
        Map<String, dynamic>.from(item as Map),
    ];
  }

  /// public.set_active_character(p_kod) — aktif karakteri değiştirir.
  /// Sunucu yalnızca kazanılmış karakteri kabul eder.
  Future<void> setActiveCharacter(String kod) async {
    await _client.rpc('set_active_character', params: {'p_kod': kod});
  }
}
