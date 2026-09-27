// ignore_for_file: invalid_use_of_visible_for_testing_member
// Ekran görüntüsü (önizleme) üretici. Tasarımı telefon olmadan görmek için:
//   flutter test tool/screen_previews_test.dart --update-goldens
// Çıktılar tool/previews/ klasörüne PNG olarak yazılır.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ogrenci_hazirlik/auth/login.dart';
import 'package:ogrenci_hazirlik/models/league_models.dart';
import 'package:ogrenci_hazirlik/models/membership_models.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/models/privacy_models.dart';
import 'package:ogrenci_hazirlik/screens/privacy_notice_screen.dart';
import 'package:ogrenci_hazirlik/screens/settings_screen.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/home_screen.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/avatar_models.dart';
import 'package:ogrenci_hazirlik/widgets/evolving_avatar/tier_up_dialog.dart';
import 'package:ogrenci_hazirlik/screens/notifications_screen.dart';
import 'package:ogrenci_hazirlik/screens/profile_screen.dart';
import 'package:ogrenci_hazirlik/screens/quiz_screen.dart';
import 'package:ogrenci_hazirlik/screens/result_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/widgets/ui/chunky_button.dart';
import 'package:ogrenci_hazirlik/widgets/ui/game_card.dart';
import 'package:ogrenci_hazirlik/widgets/ui/hero_header.dart';
import 'package:ogrenci_hazirlik/widgets/hupo/hupo.dart';
import 'package:ogrenci_hazirlik/widgets/ui/stat_pill.dart';

Future<void> loadFonts() async {
  final loader = FontLoader('Nunito')
    ..addFont(rootBundle.load('assets/fonts/Nunito.ttf'));
  await loader.load();

  final lexend = FontLoader('Lexend')
    ..addFont(rootBundle.load('assets/fonts/Lexend.ttf'));
  await lexend.load();

  // Material ikon yazı tipi (testte varsayılan olarak kare görünür)
  final root = Platform.environment['FLUTTER_ROOT'] ?? 'C:/src/flutter';
  final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await iconLoader.load();
  }
}

class FakeRepo extends Fake implements QuizRepository {
  @override
  Future<void> signOut() async {}
  @override
  Future<void> markAllNotificationsRead() async {}
  @override
  Future<List<Question>> fetchReviewQuestions({int limit = 10}) async => [];
  @override
  Future<List<Question>> fetchQuizQuestions(String ders, {int limit = 10}) async => [];
  @override
  Future<AnswerResult> submitAnswer({
    required String questionId,
    required String? selectedOption,
    required int durationMs,
  }) async {
    final ok = selectedOption == 'C';
    return AnswerResult(
      correct: ok,
      correctOption: 'C',
      earnedXp: ok ? 10 : 0,
      xp: ok ? 240 : 230,
      level: 3,
      streakCount: 4,
      steps: const [
        'Paydaları eşitle: 1/2 = 2/4.',
        'Payları topla: 2/4 + 1/4 = 3/4.',
        'Sonuç 3/4 olur, doğru şık C.',
      ],
    );
  }
}

final sampleBadges = [
  BadgeInfo(code: 'a', name: 'İlk Adım', description: 'İlk sorunu çöz.', icon: 'flag', conditionType: 'soru_sayisi', threshold: 1, earned: true, earnedAt: DateTime(2026, 9, 12), progress: 1),
  BadgeInfo(code: 'b', name: 'Çalışkan Arı', description: '25 farklı soru çöz.', icon: 'menu_book', conditionType: 'soru_sayisi', threshold: 25, earned: true, earnedAt: DateTime(2026, 9, 15), progress: 25),
  const BadgeInfo(code: 'c', name: 'Soru Avcısı', description: '100 farklı soru çöz.', icon: 'track_changes', conditionType: 'soru_sayisi', threshold: 100, earned: false, progress: 32),
  const BadgeInfo(code: 'd', name: 'Isınma Turu', description: '3 gün üst üste soru çöz.', icon: 'local_fire_department', conditionType: 'streak', threshold: 3, earned: false, progress: 2),
  const BadgeInfo(code: 'e', name: 'Alev Alev', description: '7 gün üst üste soru çöz.', icon: 'whatshot', conditionType: 'streak', threshold: 7, earned: false, progress: 2),
  const BadgeInfo(code: 'f', name: 'Matematik Ustası', description: 'Matematik dersinde en az 10 soru çöz ve %90 başarı yakala.', icon: 'calculate', conditionType: 'ders_basari', threshold: 90, ders: 'Matematik', earned: false, progress: 72, attempts: 5),
];

const sampleQuestions = [
  Question(id: 'q1', ders: 'Matematik', konu: 'Kesirler', zorluk: 1, text: '1/2 + 1/4 işleminin sonucu kaçtır?', options: {'A': '1/6', 'B': '2/6', 'C': '3/4', 'D': '1'}),
  Question(id: 'q2', ders: 'Matematik', konu: 'Yüzdeler', zorluk: 2, text: "200 sayısının yüzde 15'i kaçtır?", options: {'A': '15', 'B': '20', 'C': '30', 'D': '35'}),
];

const sampleLeague = LeagueStatus(
  code: 'gumus',
  name: 'Gümüş Ligi',
  tier: 2,
  colorHex: '#9AA5B1',
  icon: 'shield',
  weeklyXp: 95,
  rank: 3,
  total: 14,
  remainingSeconds: 2 * 86400 + 5 * 3600,
  nextLeagueName: 'Altın Ligi',
  promotionXp: 150,
);

final sampleOverview = ProfileOverview(
  joinedAt: DateTime.now().subtract(const Duration(days: 8)),
  totalSolved: 42,
  accuracy: 81,
  longestStreak: 5,
  subjects: const [
    SubjectProgress(ders: 'Fen Bilimleri', solved: 3, total: 4, success: 100),
    SubjectProgress(ders: 'Matematik', solved: 4, total: 4, success: 75),
    SubjectProgress(ders: 'Türkçe', solved: 1, total: 4, success: 50),
  ],
);

final sampleNotifications = [
  AppNotification(id: '1', type: 'lig', title: 'Yeni lige yükseldin!', message: 'Tebrikler, artık Gümüş Ligi içinde yarışıyorsun!', icon: 'shield', read: false, createdAt: DateTime.now().subtract(const Duration(minutes: 12))),
  AppNotification(id: '2', type: 'rozet', title: 'Yeni rozet kazandın!', message: '"Çalışkan Arı" rozeti artık senin. Harikasın!', icon: 'menu_book', read: false, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
  AppNotification(id: '3', type: 'seviye', title: 'Seviye atladın!', message: 'Artık Seviye 3! Böyle devam.', icon: 'emoji_events', read: true, createdAt: DateTime.now().subtract(const Duration(days: 1))),
  AppNotification(id: '4', type: 'rozet', title: 'Yeni rozet kazandın!', message: '"İlk Adım" rozeti artık senin. Harikasın!', icon: 'flag', read: true, createdAt: DateTime.now().subtract(const Duration(days: 8))),
];

final overrides = [
  dailyGoalProvider.overrideWith((ref) async => const DailyGoal(goal: 10, today: 4, completed: false, shields: 1)),
  consentProvider.overrideWith((ref) async => const ConsentStatus(noticeRead: true, parentConsent: ParentConsent.none)),
  leagueProvider.overrideWith((ref) async => sampleLeague),
  overviewProvider.overrideWith((ref) async => sampleOverview),
  notificationsProvider.overrideWith((ref) async => sampleNotifications),
  unreadCountProvider.overrideWith((ref) async => 2),
  quizRepositoryProvider.overrideWithValue(FakeRepo()),
  profileProvider.overrideWith((ref) async => const Profile(id: 'x', role: 'ogrenci', fullName: 'Ayşe Yılmaz')),
  statsProvider.overrideWith((ref) async => StudentStats(xp: 230, level: 3, streakCount: 4, lastActiveDate: DateTime.now())),
  subjectsProvider.overrideWith((ref) async => const [
        SubjectInfo(ders: 'Fen Bilimleri', questionCount: 4),
        SubjectInfo(ders: 'Matematik', questionCount: 4),
        SubjectInfo(ders: 'Türkçe', questionCount: 4),
      ]),
  dueCountProvider.overrideWith((ref) async => 5),
  badgesProvider.overrideWith((ref) async => sampleBadges),
];

/// Animasyonların ilerlemesi için birden fazla kare çizer.
Future<void> settle(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms / 100; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  double height = 1688,
  double textScale = 1.0,
  String fontFamily = 'Nunito',
  List<Override> extra = const [],
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  tester.view.devicePixelRatio = 2.0;
  tester.view.physicalSize = Size(780, height);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...overrides,
      currentUserIdProvider.overrideWithValue(null),
      sharedPreferencesProvider.overrideWithValue(prefs),
      ...extra,
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(fontFamily: fontFamily),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: screen,
    ),
  ));
  await tester.runAsync(() async {
    final ctx = tester.element(find.byType(MaterialApp));
    for (final p in HupoPose.values) {
      await precacheImage(AssetImage(p.assetPath), ctx);
    }
  });
  await tester.pump();
  await settle(tester, 1200);
}

void main() {
  setUpAll(loadFonts);

  testWidgets('tasarım sistemi', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            HeroHeader(
              child: Column(
                children: [
                  Text('Merhaba Ayşe, hazır mısın?',
                      style: appText(size: 24, weight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Hupo(pose: HupoPose.sevimli, size: 96),
                      Hupo(pose: HupoPose.muthis, size: 96),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Hupo(pose: HupoPose.dusunen, size: 96),
                      Hupo(pose: HupoPose.tesvik, size: 96),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Wrap(spacing: 10, children: [
                    StatPill(icon: Icons.emoji_events, iconColor: AppColors.sunDark, value: '3', label: 'Seviye'),
                    StatPill(icon: Icons.bolt, iconColor: AppColors.primary, value: '230', label: 'XP'),
                    StatPill(icon: Icons.local_fire_department, iconColor: AppColors.coral, value: '4', label: 'Seri'),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GameCard(
                    onTap: () {},
                    child: Text('Matematik  •  12 soru', style: appText(size: 18, weight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                  ChunkyButton(label: 'Başla', onPressed: () {}),
                  const SizedBox(height: 12),
                  ChunkyButton.success(label: 'Sonraki soru', onPressed: () {}),
                  const SizedBox(height: 12),
                  ChunkyButton.danger(label: 'Tekrar dene', onPressed: () {}),
                  const SizedBox(height: 12),
                  ChunkyButton.light(label: 'Ana sayfaya dön', onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await expectLater(find.byType(Scaffold), matchesGoldenFile('previews/00_design_system.png'));
  });

  Future<void> shot(WidgetTester tester, String name) => expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('previews/$name.png'),
      );

  testWidgets('Hupo galerisi', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final p in HupoPose.values) Hupo(pose: p, size: 110)],
          ),
        ),
      ),
    );
    await shot(tester, '00_hupo_galerisi');
  });

  testWidgets('giriş', (tester) async {
    await pumpScreen(tester, const LoginScreen());
    await shot(tester, '01_giris');
  });

  testWidgets('ana ekran', (tester) async {
    await pumpScreen(tester, const HomeScreen());
    await shot(tester, '02_ana_ekran');
  });

  testWidgets('soru: cevap bekleniyor', (tester) async {
    await pumpScreen(tester, const QuizScreen(title: 'Matematik', questions: sampleQuestions));
    await shot(tester, '03_soru');
  });

  testWidgets('soru: doğru cevap', (tester) async {
    await pumpScreen(tester, const QuizScreen(title: 'Matematik', questions: sampleQuestions));
    await tester.tap(find.text('3/4'));
    await tester.pump();
    await settle(tester, 2600);
    await shot(tester, '04_soru_dogru');
  });

  testWidgets('soru: doğru cevap (konfeti)', (tester) async {
    await pumpScreen(tester, const QuizScreen(title: 'Matematik', questions: sampleQuestions));
    await tester.tap(find.text('3/4'));
    await tester.pump();
    await settle(tester, 700);
    await shot(tester, '04b_soru_konfeti');
  });

  testWidgets('soru: yanlış cevap', (tester) async {
    await pumpScreen(tester, const QuizScreen(title: 'Matematik', questions: sampleQuestions));
    await tester.tap(find.text('1/6'));
    await tester.pump();
    await settle(tester, 2600);
    await shot(tester, '05_soru_yanlis');
  });

  testWidgets('sonuç', (tester) async {
    await pumpScreen(tester, ResultScreen(results: [
      const AnswerResult(correct: true, correctOption: 'C', earnedXp: 10, xp: 240, level: 3, streakCount: 4),
      const AnswerResult(correct: true, correctOption: 'B', earnedXp: 20, xp: 260, level: 3, streakCount: 4),
      const AnswerResult(correct: false, correctOption: 'A', earnedXp: 0, xp: 260, level: 3, streakCount: 4),
    ]));
    await shot(tester, '06_sonuc');
  });

  testWidgets('profil', (tester) async {
    await pumpScreen(tester, const ProfileScreen(), height: 3900);
    await shot(tester, '07_profil');
  });

  testWidgets('profil + üyelik (premium)', (tester) async {
    await pumpScreen(
      tester,
      const ProfileScreen(),
      height: 4300,
      extra: [
        membershipProvider.overrideWith((ref) async => MembershipStatus(
              active: true,
              planName: 'Aylık Premium',
              endsAt: DateTime(2026, 10, 20),
              remainingDays: 22,
              source: 'veli',
            )),
      ],
    );
    await shot(tester, '07b_profil_uyelik_premium');
  });

  testWidgets('profil + üyelik (ücretsiz)', (tester) async {
    await pumpScreen(
      tester,
      const ProfileScreen(),
      height: 4300,
      extra: [
        membershipProvider.overrideWith((ref) async => const MembershipStatus(gatingActive: true, freeDailyQuestions: 5)),
      ],
    );
    await shot(tester, '07c_profil_uyelik_ucretsiz');
  });

  testWidgets('bildirimler', (tester) async {
    await pumpScreen(tester, const NotificationsScreen());
    await shot(tester, '08_bildirimler');
  });

  testWidgets('ayarlar', (tester) async {
    await pumpScreen(tester, const SettingsScreen(), height: 3000);
    await shot(tester, '09_ayarlar');
  });

  testWidgets('gizlilik bildirimi (ilk giriş)', (tester) async {
    await pumpScreen(tester, const PrivacyNoticeScreen(firstRun: true));
    await shot(tester, '10_gizlilik');
  });

  // Erişilebilirlik: en büyük yazı boyutu + Lexend ile taşma olmamalı.
  // (Taşma olursa test "RenderFlex overflowed" hatasıyla başarısız olur.)
  testWidgets('erişilebilirlik: ana ekran 1.3x + Lexend', (tester) async {
    await pumpScreen(tester, const HomeScreen(), textScale: 1.3, fontFamily: 'Lexend', height: 2600);
    await shot(tester, '11_ana_ekran_buyuk_yazi');
  });

  testWidgets('erişilebilirlik: soru ekranı 1.3x + Lexend', (tester) async {
    await pumpScreen(tester, const QuizScreen(title: 'Matematik', questions: sampleQuestions), textScale: 1.3, fontFamily: 'Lexend');
    await tester.tap(find.text('3/4'));
    await tester.pump();
    await settle(tester, 2600);
    await shot(tester, '12_soru_buyuk_yazi');
  });

  testWidgets('erişilebilirlik: profil 1.3x + Lexend', (tester) async {
    await pumpScreen(tester, const ProfileScreen(), textScale: 1.3, fontFamily: 'Lexend', height: 4800);
    await shot(tester, '13_profil_buyuk_yazi');
  });

  testWidgets('erişilebilirlik: ayarlar 1.3x + Lexend', (tester) async {
    await pumpScreen(tester, const SettingsScreen(), textScale: 1.3, fontFamily: 'Lexend', height: 3800);
    await shot(tester, '14_ayarlar_buyuk_yazi');
  });

  testWidgets('ana ekran + evrimleşen avatar (Akıncı)', (tester) async {
    await pumpScreen(
      tester,
      const HomeScreen(),
      height: 3400,
      extra: [
        statsProvider.overrideWith((ref) async => StudentStats(xp: 3000, level: 31, streakCount: 4, lastActiveDate: DateTime.now(), shields: 1)),
      ],
    );
    await shot(tester, '15_ana_ekran_avatar');
  });

  testWidgets('kutlama penceresi (Akıncı)', (tester) async {
    await pumpScreen(tester, const TierUpView(tier: AvatarTier.altin));
    await settle(tester, 900);
    await shot(tester, '16_kutlama_akinci');
  });

  testWidgets('kutlama penceresi (Efsanevi Anka)', (tester) async {
    await pumpScreen(tester, const TierUpView(tier: AvatarTier.efsanevi));
    await settle(tester, 900);
    await shot(tester, '17_kutlama_anka');
  });
}
