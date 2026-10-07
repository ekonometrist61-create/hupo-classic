import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../content/privacy_notice.dart';
import '../models/app_config.dart';
import '../models/character_models.dart';
import '../models/cipher_models.dart';
import '../models/daily_challenge_models.dart';
import '../models/league_models.dart';
import '../models/membership_models.dart';
import '../models/models.dart';
import '../models/privacy_models.dart';
import '../models/review_models.dart';
import '../services/quiz_repository.dart';

final supabaseProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final quizRepositoryProvider =
    Provider<QuizRepository>((ref) => QuizRepository(ref.watch(supabaseProvider)));

final profileProvider = FutureProvider.autoDispose<Profile?>(
    (ref) => ref.watch(quizRepositoryProvider).fetchProfile());

final statsProvider = FutureProvider.autoDispose<StudentStats>(
    (ref) => ref.watch(quizRepositoryProvider).fetchStats());

final subjectsProvider = FutureProvider.autoDispose<List<SubjectInfo>>(
    (ref) => ref.watch(quizRepositoryProvider).fetchSubjects());

/// Bir dersteki konu bazlı ilerleme (Öğren sekmesi konu kırılımı).
final topicProgressProvider = FutureProvider.autoDispose
    .family<List<TopicProgress>, String>(
        (ref, ders) => ref.watch(quizRepositoryProvider).fetchTopicProgress(ders));

final dueCountProvider = FutureProvider.autoDispose<int>(
    (ref) => ref.watch(quizRepositoryProvider).fetchDueCount());

final badgesProvider = FutureProvider.autoDispose<List<BadgeInfo>>(
    (ref) => ref.watch(quizRepositoryProvider).fetchBadges());

final leagueProvider = FutureProvider.autoDispose<LeagueStatus>(
    (ref) => ref.watch(quizRepositoryProvider).fetchLeague());

/// Tüm lig basamakları (Ay Ligi tam ekran merdiveni); öğrenciye özgü değil.
final leagueLadderProvider = FutureProvider.autoDispose<List<LeagueTier>>(
    (ref) => ref.watch(quizRepositoryProvider).fetchLeagueLadder());

final membershipProvider = FutureProvider.autoDispose<MembershipStatus>(
    (ref) => ref.watch(quizRepositoryProvider).fetchMembership());

/// Bugünkü görevler: ilerleme ve ödül durumu. Quiz bittikten sonra invalidate edilir.
final myQuestsProvider = FutureProvider.autoDispose<List<Quest>>(
    (ref) => ref.watch(quizRepositoryProvider).fetchMyQuests());

final overviewProvider = FutureProvider.autoDispose<ProfileOverview>(
    (ref) => ref.watch(quizRepositoryProvider).fetchOverview());

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
    (ref) => ref.watch(quizRepositoryProvider).fetchNotifications());

final unreadCountProvider = FutureProvider.autoDispose<int>(
    (ref) => ref.watch(quizRepositoryProvider).fetchUnreadCount());

final dailyGoalProvider = FutureProvider.autoDispose<DailyGoal>(
    (ref) => ref.watch(quizRepositoryProvider).fetchDailyGoal());

final consentProvider = FutureProvider.autoDispose<ConsentStatus>(
    (ref) => ref.watch(quizRepositoryProvider).fetchConsent(kPrivacyNoticeVersion));

/// Oturum açmış kullanıcının kimliği (yoksa null). Testlerde override edilir.
final currentUserIdProvider = Provider<String?>(
    (ref) => ref.watch(supabaseProvider).auth.currentUser?.id);

// --- Kurtarılan Provider'lar ---

final appConfigFetcherProvider = FutureProvider<AppConfig>((ref) async {
  final repo = ref.watch(quizRepositoryProvider);
  final map = await repo.fetchAppConfig();
  if (map.isEmpty) return AppConfig.varsayilan;
  return AppConfig.fromMap(map);
});

final appConfigProvider = Provider<AppConfig>((ref) {
  return ref.watch(appConfigFetcherProvider).value ?? AppConfig.varsayilan;
});

final ciphersProvider = FutureProvider.autoDispose<List<MathCipher>>((ref) async {
  final repo = ref.watch(quizRepositoryProvider);
  final list = await repo.fetchCiphers();
  return [for (final m in list) MathCipher.fromMap(m)];
});

final cipherDetailProvider = FutureProvider.autoDispose.family<MathCipherDetail, String>((ref, id) async {
  final repo = ref.watch(quizRepositoryProvider);
  final map = await repo.fetchCipherDetail(id);
  return MathCipherDetail.fromMap(map);
});

final dailyChallengeProvider = FutureProvider.autoDispose<DailyChallenge>((ref) async {
  final repo = ref.watch(quizRepositoryProvider);
  final map = await repo.fetchDailyChallenge();
  return DailyChallenge.fromMap(map);
});

final savedQuestionsProvider = FutureProvider.autoDispose<List<SavedQuestion>>((ref) async {
  final repo = ref.watch(quizRepositoryProvider);
  final list = await repo.fetchSavedQuestions();
  return [for (final m in list) SavedQuestion.fromMap(m)];
});

class BookmarksNotifier extends StateNotifier<Set<String>> {
  BookmarksNotifier(this._repo) : super({});
  final QuizRepository _repo;

  void setInitial(Set<String> ids) {
    state = ids;
  }

  Future<bool> toggle(String questionId) async {
    final contains = state.contains(questionId);
    if (contains) {
      state = {...state}..remove(questionId);
    } else {
      state = {...state, questionId};
    }
    try {
      final saved = await _repo.toggleBookmark(questionId);
      if (saved) {
        state = {...state, questionId};
      } else {
        state = {...state}..remove(questionId);
      }
      return saved;
    } catch (_) {
      // Geri al
      if (contains) {
        state = {...state, questionId};
      } else {
        state = {...state}..remove(questionId);
      }
      rethrow;
    }
  }
}

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, Set<String>>((ref) {
  return BookmarksNotifier(ref.watch(quizRepositoryProvider));
});

final supportedGradesProvider = FutureProvider.autoDispose<List<int>>((ref) async {
  return ref.watch(quizRepositoryProvider).fetchSupportedGrades();
});

final gradeGateBypassedProvider = StateProvider<bool>((ref) => false);

/// Öğrencinin tüm 40 karakteri (kazanılmış + kilitli).
final myCharactersProvider =
    FutureProvider.autoDispose<List<CharacterCard>>((ref) async {
  final repo = ref.watch(quizRepositoryProvider);
  final list = await repo.fetchMyCharacters();
  return [for (final m in list) CharacterCard.fromMap(m)];
});

/// Çocuğun gösterilecek aktif karakteri.
///
/// Sıra: student_stats.aktif_karakter koduna sahip kazanılmış karakter;
/// seçilmemişse kazanılmış karakterler içinde en üst kademeli olan
/// (sınıf sırası, sonra karakter sırası). Hiç karakter kazanılmamışsa null.
final activeCharacterProvider = Provider.autoDispose<CharacterCard?>((ref) {
  final karakterler = ref.watch(myCharactersProvider).valueOrNull;
  if (karakterler == null || karakterler.isEmpty) return null;

  final kazanilanlar = karakterler.where((k) => k.kazanildi).toList();
  if (kazanilanlar.isEmpty) return null;

  final secilenKod = ref.watch(statsProvider).valueOrNull?.aktifKarakter;
  if (secilenKod != null) {
    for (final k in kazanilanlar) {
      if (k.kod == secilenKod) return k;
    }
  }

  // Yedek: kazanılmışlar içinde en üst kademeli karakter.
  kazanilanlar.sort((a, b) {
    final s = a.sinifSira.compareTo(b.sinifSira);
    return s != 0 ? s : a.karakterSira.compareTo(b.karakterSira);
  });
  return kazanilanlar.last;
});

/// Alt gezinme çubuğunun seçili sekmesi: 0 Ana Sayfa, 1 Öğren, 2 Arena, 3 Koleksiyon, 4 Profil.
final shellTabProvider = StateProvider<int>((ref) => 0);
