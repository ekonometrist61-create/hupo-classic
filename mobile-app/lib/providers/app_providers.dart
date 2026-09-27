import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/league_models.dart';
import '../models/membership_models.dart';
import '../content/privacy_notice.dart';
import '../models/models.dart';
import '../models/privacy_models.dart';
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

final dueCountProvider = FutureProvider.autoDispose<int>(
    (ref) => ref.watch(quizRepositoryProvider).fetchDueCount());

final badgesProvider = FutureProvider.autoDispose<List<BadgeInfo>>(
    (ref) => ref.watch(quizRepositoryProvider).fetchBadges());

final leagueProvider = FutureProvider.autoDispose<LeagueStatus>(
    (ref) => ref.watch(quizRepositoryProvider).fetchLeague());

final membershipProvider = FutureProvider.autoDispose<MembershipStatus>(
    (ref) => ref.watch(quizRepositoryProvider).fetchMembership());

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
