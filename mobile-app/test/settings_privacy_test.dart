import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:ogrenci_hazirlik/content/privacy_notice.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/models/privacy_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/privacy_notice_screen.dart';
import 'package:ogrenci_hazirlik/screens/quiz_screen.dart';
import 'package:ogrenci_hazirlik/screens/settings_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/utils/haptics.dart';
import 'package:ogrenci_hazirlik/widgets/daily_goal_card.dart';
import 'package:ogrenci_hazirlik/widgets/result_sheet.dart';
import 'package:ogrenci_hazirlik/widgets/hupo/hupo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repo extends Fake implements QuizRepository {
  int noticeCalls = 0;
  String? noticeVersion;
  bool failNotice = false;
  final goalCalls = <int>[];
  int exportCalls = 0;
  int deleteCalls = 0;

  @override
  Future<DailyGoal> fetchDailyGoal() async =>
      const DailyGoal(goal: 10, today: 3, completed: false, shields: 1);

  @override
  Future<void> setDailyGoal(int goal) async => goalCalls.add(goal);

  @override
  Future<void> recordNoticeRead(String version) async {
    noticeCalls++;
    noticeVersion = version;
    if (failNotice) throw Exception('ağ hatası');
  }

  @override
  Future<Map<String, dynamic>> exportMyData() async {
    exportCalls++;
    return {'profil': {'ad_soyad': 'Ayşe'}, 'cevaplar': <Object>[]};
  }

  @override
  Future<void> deleteMyAccount() async => deleteCalls++;

  @override
  Future<AnswerResult> submitAnswer({
    required String questionId,
    required String? selectedOption,
    required int durationMs,
  }) async =>
      const AnswerResult(
        correct: true,
        correctOption: 'B',
        earnedXp: 10,
        xp: 10,
        level: 1,
        streakCount: 1,
        steps: ['Birinci adım.'],
      );
}

Future<ProviderContainer Function()> _prefsScope() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return () => ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
}

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  required _Repo repo,
  bool reduceMotion = false,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(const Size(420, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(ProviderScope(
    overrides: [
      quizRepositoryProvider.overrideWithValue(repo),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: home,
    ),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

const _questions = [
  Question(
    id: 'q1',
    ders: 'Türkçe',
    konu: 'Sözcükte Anlam',
    zorluk: 1,
    text: 'Soru metni?',
    options: {'A': 'Bir', 'B': 'İki'},
  ),
];

void main() {
  group('Ayarların saklanması', () {
    test('varsayılanlar', () async {
      final make = await _prefsScope();
      final s = make().read(settingsProvider);
      expect(s.reduceMotion, isFalse);
      expect(s.haptics, isTrue);
      expect(s.font, AppFont.nunito);
      expect(s.textSize, TextSizeOption.normal);
    });

    test('değişiklikler kalıcıdır: yeni bir örnek aynı değerleri okur', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final first = SettingsNotifier(prefs)
        ..setReduceMotion(true)
        ..setHaptics(false)
        ..setFont(AppFont.lexend)
        ..setTextSize(TextSizeOption.xlarge);
      expect(first.state.font, AppFont.lexend);

      final second = SettingsNotifier(prefs);
      expect(second.state.reduceMotion, isTrue);
      expect(second.state.haptics, isFalse);
      expect(second.state.font, AppFont.lexend);
      expect(second.state.textSize, TextSizeOption.xlarge);
      expect(AppHaptics.enabled, isFalse);

      AppHaptics.enabled = true; // diğer testleri etkilemesin
    });

    test('bozuk kayıtlı değer varsayılana döner', () async {
      SharedPreferences.setMockInitialValues({'font': 'yok-boyle-bir-font', 'text_size': '???'});
      final prefs = await SharedPreferences.getInstance();
      final s = SettingsNotifier(prefs).state;
      expect(s.font, AppFont.nunito);
      expect(s.textSize, TextSizeOption.normal);
    });

    test('seçilen yazı tipi temaya yansır', () {
      expect(buildAppTheme(fontFamily: 'Lexend').textTheme.bodyMedium?.fontFamily, 'Lexend');
      expect(buildAppTheme().textTheme.bodyMedium?.fontFamily, 'Nunito');
    });
  });

  group('Hareketi azalt', () {
    testWidgets('Hupo süzülür; hareket azaltılınca durur', (tester) async {
      Widget host(bool reduce) => MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
              child: child!,
            ),
            home: const Scaffold(body: Hupo(pose: HupoPose.ayakta, animated: true)),
          );

      await tester.pumpWidget(host(false));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(host(true));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('sonuç penceresi: tüm çözüm adımları hemen görünür, Lottie yerine simge', (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: ResultSheet(
            result: const AnswerResult(
              correct: true,
              correctOption: 'B',
              earnedXp: 10,
              xp: 10,
              level: 1,
              streakCount: 1,
              steps: ['Birinci adım.', 'İkinci adım.'],
            ),
            isLast: false,
            onContinue: () {},
          ),
        ),
        repo: _Repo(),
        reduceMotion: true,
      );

      double opacityOf(String text) => tester
          .widget<AnimatedOpacity>(find.ancestor(
            of: find.text(text),
            matching: find.byType(AnimatedOpacity),
          ).first)
          .opacity;

      expect(opacityOf('Birinci adım.'), 1);
      expect(opacityOf('İkinci adım.'), 1);
      expect(find.byType(LottieBuilder), findsNothing);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('soru ekranı: doğru cevapta konfeti yalnızca hareket açıkken çıkar', (tester) async {
      Future<void> answer(bool reduce) async {
        await _pump(
          tester,
          const QuizScreen(title: 'Türkçe', questions: _questions),
          repo: _Repo(),
          reduceMotion: reduce,
        );
        await tester.tap(find.text('İki'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      await answer(false);
      expect(find.byType(LottieBuilder), findsWidgets); // konfeti + doğru animasyonu

      await answer(true);
      expect(find.byType(LottieBuilder), findsNothing);
      expect(find.text('Harikasın!'), findsOneWidget); // geri bildirim yine var
    });
  });

  group('Günlük hedef', () {
    test('fromMap ve ilerleme', () {
      final g = DailyGoal.fromMap({'hedef': 10, 'bugun': 3, 'tamamlandi': false, 'seri_kalkani': 2});
      expect(g.progress, closeTo(0.3, 1e-9));
      expect(g.remaining, 7);
      expect(g.shields, 2);
    });

    testWidgets('kart: ilerleme, kalan soru ve seri kalkanı görünür', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DailyGoalView(goal: DailyGoal(goal: 10, today: 3, completed: false, shields: 1)),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Günlük hedef: 3/10 soru'), findsOneWidget);
      expect(find.text('7 soru kaldı, sen yaparsın!'), findsOneWidget);
      expect(find.byIcon(Icons.shield_rounded), findsOneWidget);
    });

    testWidgets('hedef tamamlanınca kutlama metni', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DailyGoalView(goal: DailyGoal(goal: 5, today: 6, completed: true, shields: 0)),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Bugünkü hedefini tamamladın, süpersin!'), findsOneWidget);
      expect(find.byIcon(Icons.shield_rounded), findsNothing);
    });
  });

  group('Seri kalkanı (istatistik)', () {
    final today = DateTime(2026, 9, 20);

    test('tam bir gün ara + kalkan varsa seri gösterilmeye devam eder', () {
      expect(
        StudentStats(streakCount: 5, lastActiveDate: DateTime(2026, 9, 18), shields: 1).streakAt(today),
        5,
      );
    });

    test('kalkan yoksa veya ara daha uzunsa seri 0 gösterilir', () {
      expect(StudentStats(streakCount: 5, lastActiveDate: DateTime(2026, 9, 18)).streakAt(today), 0);
      expect(
        StudentStats(streakCount: 5, lastActiveDate: DateTime(2026, 9, 17), shields: 2).streakAt(today),
        0,
      );
    });

    test('fromMap seri_kalkani alanını okur, yoksa 0', () {
      expect(
        StudentStats.fromMap({
          'xp': 0, 'level': 1, 'streak_count': 0, 'last_active_date': null, 'seri_kalkani': 2,
        }).shields,
        2,
      );
      expect(
        StudentStats.fromMap({'xp': 0, 'level': 1, 'streak_count': 0, 'last_active_date': null}).shields,
        0,
      );
    });
  });

  group('Gizlilik bildirimi', () {
    test('ConsentStatus.fromMap', () {
      final c = ConsentStatus.fromMap({'aydinlatma_okundu': true, 'veli_riza': 'geri_cekildi'});
      expect(c.noticeRead, isTrue);
      expect(c.parentConsent, ParentConsent.withdrawn);
      expect(ConsentStatus.fromMap({'veli_riza': 'verildi'}).parentConsent, ParentConsent.given);
      expect(ConsentStatus.fromMap({'veli_riza': 'yok'}).parentConsent, ParentConsent.none);
      expect(ConsentStatus.fromMap({}).noticeRead, isFalse);
    });

    testWidgets('tüm bölümler çocuğa sade dille gösterilir', (tester) async {
      await _pump(tester, const PrivacyNoticeScreen(firstRun: true), repo: _Repo());
      for (final s in kPrivacySections) {
        expect(find.text(s.title), findsOneWidget);
      }
      expect(find.text('Anladım'), findsOneWidget);
    });

    testWidgets('"Anladım" okundu kaydını gönderir ve devam edilir', (tester) async {
      final repo = _Repo();
      var accepted = 0;
      await _pump(
        tester,
        PrivacyNoticeScreen(firstRun: true, onAccepted: () => accepted++),
        repo: repo,
      );
      await tester.tap(find.text('Anladım'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(repo.noticeCalls, 1);
      expect(repo.noticeVersion, kPrivacyNoticeVersion);
      expect(accepted, 1);
    });

    testWidgets('kayıt başarısızsa ilerlenmez ve nazik uyarı çıkar', (tester) async {
      final repo = _Repo()..failNotice = true;
      var accepted = 0;
      await _pump(
        tester,
        PrivacyNoticeScreen(firstRun: true, onAccepted: () => accepted++),
        repo: repo,
      );
      await tester.tap(find.text('Anladım'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(accepted, 0);
      expect(find.text('Kaydedilemedi, bir kez daha dener misin?'), findsOneWidget);
    });

    testWidgets('Ayarlar\'dan açılınca salt okunurdur: kayıt göndermez', (tester) async {
      final repo = _Repo();
      await _pump(tester, const PrivacyNoticeScreen(), repo: repo);
      expect(find.text('Tamam'), findsOneWidget);
      await tester.tap(find.text('Tamam'));
      await tester.pump();
      expect(repo.noticeCalls, 0);
    });
  });

  group('Ayarlar ekranı', () {
    testWidgets('yazı boyutu ve yazı tipi seçimi ayarları değiştirir', (tester) async {
      await _pump(tester, const SettingsScreen(), repo: _Repo());
      final container = ProviderScope.containerOf(tester.element(find.byType(SettingsScreen)));

      await tester.tap(find.text('Çok büyük'));
      await tester.tap(find.text('Okumayı kolaylaştıran'));
      await tester.pump();

      final s = container.read(settingsProvider);
      expect(s.textSize, TextSizeOption.xlarge);
      expect(s.font, AppFont.lexend);
    });

    testWidgets('anahtarlar hareketi ve titreşimi kapatır', (tester) async {
      await _pump(tester, const SettingsScreen(), repo: _Repo());
      final container = ProviderScope.containerOf(tester.element(find.byType(SettingsScreen)));

      await tester.tap(find.byType(Switch).at(0));
      await tester.tap(find.byType(Switch).at(1));
      await tester.pump();

      expect(container.read(settingsProvider).reduceMotion, isTrue);
      expect(container.read(settingsProvider).haptics, isFalse);
      AppHaptics.enabled = true;
    });

    testWidgets('günlük hedef seçimi sunucuya gönderilir', (tester) async {
      final repo = _Repo();
      await _pump(tester, const SettingsScreen(), repo: repo);

      await tester.tap(find.text('15 soru'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(repo.goalCalls, [15]);
    });

    testWidgets('"Bilgilerimi kopyala" verileri panoya JSON olarak koyar', (tester) async {
      final clipboard = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard.add((call.arguments as Map)['text'] as String);
        }
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      final repo = _Repo();
      await _pump(tester, const SettingsScreen(), repo: repo);
      await tester.ensureVisible(find.text('Bilgilerimi kopyala'));
      await tester.tap(find.text('Bilgilerimi kopyala'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(repo.exportCalls, 1);
      expect(clipboard.single, contains('"ad_soyad": "Ayşe"'));
      expect(find.textContaining('panoya kopyalandı'), findsOneWidget);
    });

    testWidgets('hesap silme: "SİL" yazılmadan onaylanamaz; vazgeçilirse silinmez', (tester) async {
      final repo = _Repo();
      await _pump(tester, const SettingsScreen(), repo: repo);

      await tester.ensureVisible(find.text('Hesabımı sil'));
      await tester.tap(find.text('Hesabımı sil'));
      await tester.pumpAndSettle();
      expect(find.text('Hesabını silmek istiyor musun?'), findsOneWidget);

      // Yazmadan onay düğmesi pasif
      await tester.tap(find.text('Hesabı sil'));
      await tester.pumpAndSettle();
      expect(find.text('Hesabını silmek istiyor musun?'), findsOneWidget);
      expect(repo.deleteCalls, 0);

      // Vazgeç
      await tester.tap(find.text('Vazgeç'));
      await tester.pumpAndSettle();
      expect(repo.deleteCalls, 0);
    });

    testWidgets('hesap silme: doğru onay yazılınca silinir (küçük harf/i de kabul)', (tester) async {
      final repo = _Repo();
      await _pump(tester, const SettingsScreen(), repo: repo);

      await tester.ensureVisible(find.text('Hesabımı sil'));
      await tester.tap(find.text('Hesabımı sil'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'sil');
      await tester.pump();
      await tester.tap(find.text('Hesabı sil'));
      await tester.pumpAndSettle();

      expect(repo.deleteCalls, 1);
    });
  });
}
