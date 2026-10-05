import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/league_models.dart';
import 'package:ogrenci_hazirlik/models/membership_models.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/profile_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';
import 'package:ogrenci_hazirlik/widgets/hupo/hupo.dart';
import 'package:ogrenci_hazirlik/widgets/membership_card.dart';

class _FakeRepo extends Fake implements QuizRepository {
  _FakeRepo({this.status, this.fail = false});

  final MembershipStatus? status;
  final bool fail;

  @override
  Future<MembershipStatus> fetchMembership() async {
    if (fail) throw Exception('rpc yok');
    return status ?? MembershipStatus.unknown;
  }
}

Widget _card(MembershipStatus s, {bool reduce = false}) => MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: child!,
      ),
      home: Scaffold(body: SingleChildScrollView(child: MembershipCard(status: s))),
    );

const _sampleLeague = LeagueStatus(
  code: 'bronz',
  name: 'Bronz Ligi',
  tier: 1,
  colorHex: '#CD7F32',
  icon: 'shield',
  weeklyXp: 10,
  rank: 1,
  total: 3,
  remainingSeconds: 3600,
  nextLeagueName: 'Gümüş Ligi',
  promotionXp: 100,
);

Future<void> _pumpProfile(WidgetTester tester, QuizRepository repo) async {
  tester.view.devicePixelRatio = 2.0;
  tester.view.physicalSize = const Size(780, 4200);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      quizRepositoryProvider.overrideWithValue(repo),
      profileProvider.overrideWith((ref) async => const Profile(id: 'x', role: 'ogrenci', fullName: 'Ayşe')),
      statsProvider.overrideWith((ref) async => const StudentStats()),
      badgesProvider.overrideWith((ref) async => const <BadgeInfo>[]),
      leagueProvider.overrideWith((ref) async => _sampleLeague),
      overviewProvider.overrideWith((ref) async => const ProfileOverview(
            totalSolved: 0,
            accuracy: 0,
            longestStreak: 0,
            subjects: [],
          )),
    ],
    child: const MaterialApp(home: ProfileScreen()),
  ));
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
}

void main() {
  group('MembershipStatus.fromMap', () {
    test('aktif üyelik alanları', () {
      final s = MembershipStatus.fromMap({
        'aktif': true,
        'plan_kod': 'aylik',
        'plan_ad': 'Aylık Premium',
        'bitis': '2026-10-20',
        'kalan_gun': 15,
        'kaynak': 'veli',
        'gating_aktif': true,
        'ucretsiz_gunluk_soru': 5,
      });
      expect(s.known, isTrue);
      expect(s.active, isTrue);
      expect(s.planName, 'Aylık Premium');
      expect(s.endsAt, DateTime(2026, 10, 20));
      expect(s.fromParent, isTrue);
      expect(s.progress, closeTo(0.5, 0.001));
      expect(s.freeDailyQuestions, 5);
      expect(s.freeQuestionsLeftToday, isNull);
    });

    test('eksik / bozuk alanlar çökmez', () {
      final s = MembershipStatus.fromMap({'aktif': 'evet', 'kalan_gun': 'abc', 'kaynak': 'x'});
      expect(s.active, isFalse);
      expect(s.remainingDays, isNull);
      expect(s.source, isNull);
      expect(s.progress, 0);
    });

    test('toplam_gun gelirse çubuk kesinleşir; ilerleme 0-1 arasında kalır', () {
      const a = MembershipStatus(active: true, remainingDays: 100, totalDays: 400);
      expect(a.progress, closeTo(0.25, 0.001));
      const b = MembershipStatus(active: true, remainingDays: 999, totalDays: 30);
      expect(b.progress, 1.0);
    });
  });

  group('MembershipCard', () {
    testWidgets('aktif: plan, bitiş, kalan gün, harika pozu, satın alma yok', (tester) async {
      await tester.pumpWidget(_card(MembershipStatus(
        active: true,
        planName: 'Yıllık Premium',
        endsAt: DateTime(2027, 1, 5),
        remainingDays: 90,
        source: 'kendi',
      )));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Yıllık Premium'), findsOneWidget);
      expect(find.text('Bitiş: 05.01.2027'), findsOneWidget);
      expect(find.text('Kalan: 90 gün'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final hupo = tester.widget<Hupo>(find.byType(Hupo));
      expect(hupo.pose, HupoPose.harika);
      expect(find.textContaining('Premium için velinle konuş'), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('süresi dolmuş / yok: ücretsiz üyelik, velinle konuş, düğme yok', (tester) async {
      await tester.pumpWidget(_card(const MembershipStatus()));
      await tester.pump();
      expect(find.text('Ücretsiz üyelik'), findsOneWidget);
      expect(find.text('Premium için velinle konuş.'), findsOneWidget);
      expect(tester.widget<Hupo>(find.byType(Hupo)).pose, HupoPose.merakEdiyor);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('kota: yalnızca alan verilmişse gösterilir', (tester) async {
      await tester.pumpWidget(_card(const MembershipStatus(gatingActive: true, freeQuestionsLeftToday: 3)));
      await tester.pump();
      expect(find.text('Bugün kalan ücretsiz soru: 3'), findsOneWidget);

      await tester.pumpWidget(_card(const MembershipStatus(freeQuestionsLeftToday: 3)));
      await tester.pump();
      expect(find.textContaining('ücretsiz soru'), findsNothing);
    });

    testWidgets('çocuk: veliden gelen üyelik (kaynak veli)', (tester) async {
      await tester.pumpWidget(_card(const MembershipStatus(
        active: true,
        planName: 'Aylık Premium',
        remainingDays: 10,
        source: 'veli',
      )));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('velin sayesinde'), findsOneWidget);
    });

    testWidgets('bilinmiyor: hiçbir şey çizilmez', (tester) async {
      await tester.pumpWidget(_card(MembershipStatus.unknown));
      expect(find.byType(Hupo), findsNothing);
      expect(find.textContaining('Üyelik'), findsNothing);
    });

    testWidgets('hareket azaltılmış: çubuk animasyonsuz hemen dolar', (tester) async {
      await tester.pumpWidget(_card(
        const MembershipStatus(active: true, remainingDays: 15),
        reduce: true,
      ));
      await tester.pump();
      final bar = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(bar.value, closeTo(0.5, 0.001));
    });
  });

  group('ProfileScreen üyelik kartı', () {
    testWidgets('aktif üyelik profilde görünür', (tester) async {
      await _pumpProfile(
        tester,
        _FakeRepo(status: const MembershipStatus(active: true, planName: 'Aylık Premium', remainingDays: 20)),
      );
      expect(find.text('Aylık Premium'), findsOneWidget);
      expect(find.text('Kalan: 20 gün'), findsOneWidget);
    });

    testWidgets('hata: kart yok, alarm yok, ekranın kalanı çalışır', (tester) async {
      await _pumpProfile(tester, _FakeRepo(fail: true));
      expect(find.text('Ücretsiz üyelik'), findsNothing);
      expect(find.textContaining('yüklenemedi'), findsNothing);
      expect(find.text('Profilim'), findsOneWidget);
    });

    testWidgets('bilinmiyor: kart yok', (tester) async {
      await _pumpProfile(tester, _FakeRepo());
      expect(find.text('Ücretsiz üyelik'), findsNothing);
    });
  });
}
