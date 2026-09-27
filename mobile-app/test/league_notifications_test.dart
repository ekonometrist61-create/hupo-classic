import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/league_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/notifications_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';
import 'package:ogrenci_hazirlik/utils/format.dart';
import 'package:ogrenci_hazirlik/widgets/league_card.dart';
import 'package:ogrenci_hazirlik/widgets/notification_bell.dart';
import 'package:ogrenci_hazirlik/widgets/progress_card.dart';

const _league = LeagueStatus(
  code: 'bronz',
  name: 'Bronz Ligi',
  tier: 1,
  colorHex: '#CD7F32',
  icon: 'shield',
  weeklyXp: 60,
  rank: 3,
  total: 12,
  remainingSeconds: 2 * 86400 + 5 * 3600 + 120,
  nextLeagueName: 'Gümüş Ligi',
  promotionXp: 100,
);

LeagueStatus _leagueWith({int weeklyXp = 60, int total = 12, int? promotionXp = 100}) =>
    LeagueStatus(
      code: 'x',
      name: 'Bronz Ligi',
      tier: 1,
      colorHex: '#CD7F32',
      icon: 'shield',
      weeklyXp: weeklyXp,
      rank: 1,
      total: total,
      remainingSeconds: 3600,
      nextLeagueName: promotionXp == null ? null : 'Gümüş Ligi',
      promotionXp: promotionXp,
    );

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

class _FakeRepo extends Fake implements QuizRepository {
  _FakeRepo(this.items);

  final List<AppNotification> items;
  int markCalls = 0;

  @override
  Future<List<AppNotification>> fetchNotifications({int limit = 40}) async => items;

  @override
  Future<void> markAllNotificationsRead() async => markCalls++;
}

AppNotification _notif(String id, {bool read = false, String type = 'rozet'}) =>
    AppNotification(
      id: id,
      type: type,
      title: 'Başlık $id',
      message: 'Mesaj $id',
      icon: 'star',
      read: read,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    );

void main() {
  group('LeagueStatus', () {
    test('fromMap sunucu çıktısını okur', () {
      final s = LeagueStatus.fromMap({
        'kod': 'gumus',
        'ad': 'Gümüş Ligi',
        'sira_no': 2,
        'renk': '#9AA5B1',
        'ikon': 'shield',
        'sonraki_lig': 'Altın Ligi',
        'yukselme_xp': 150,
        'haftalik_xp': 45,
        'sira': 4,
        'toplam': 20,
        'kalan_saniye': 90000,
      });
      expect(s.tier, 2);
      expect(s.promotionProgress, closeTo(0.3, 1e-9));
      expect(s.xpToPromotion, 105);
      expect(s.color, const Color(0xFF9AA5B1));
      expect(s.isTopLeague, isFalse);
    });

    test('en üst ligde hedef yoktur ve ilerleme tamamdır', () {
      final s = _leagueWith(promotionXp: null);
      expect(s.isTopLeague, isTrue);
      expect(s.promotionProgress, 1);
      expect(s.xpToPromotion, 0);
    });

    test('hedef aşılınca kalan XP 0, ilerleme 1', () {
      final s = _leagueWith(weeklyXp: 150);
      expect(s.xpToPromotion, 0);
      expect(s.promotionProgress, 1);
    });
  });

  group('ProfileOverview', () {
    test('fromMap: hiç soru yoksa doğruluk null, ders listesi okunur', () {
      final o = ProfileOverview.fromMap({
        'uye_tarihi': '2026-09-12T10:00:00Z',
        'toplam_soru': 0,
        'dogruluk': null,
        'en_uzun_seri': 3,
        'ders_ilerleme': [
          {'ders': 'Matematik', 'cozulen': 2, 'toplam': 4, 'basari': 75},
        ],
      });
      expect(o.accuracy, isNull);
      expect(o.longestStreak, 3);
      expect(o.joinedAt, isNotNull);
      expect(o.subjects.single.completion, 0.5);
    });
  });

  group('Biçim yardımcıları', () {
    test('membershipLabel', () {
      final now = DateTime(2026, 9, 20);
      expect(membershipLabel(DateTime(2026, 9, 20), now), 'Bugün aramıza katıldın!');
      expect(membershipLabel(DateTime(2026, 9, 12), now), '8 gündür aramızdasın');
      expect(membershipLabel(DateTime(2026, 6, 1), now), '3 aydır aramızdasın');
      expect(membershipLabel(DateTime(2024, 9, 1), now), '2 yıldır aramızdasın');
    });

    test('formatRemaining', () {
      expect(formatRemaining(2 * 86400 + 5 * 3600 + 120), '2 gün 5 saat');
      expect(formatRemaining(5 * 3600 + 20 * 60), '5 saat 20 dk');
      expect(formatRemaining(12 * 60), '12 dk');
      expect(formatRemaining(10), '1 dk');
      expect(formatRemaining(-5), '1 dk');
    });

    test('relativeTime', () {
      final now = DateTime(2026, 9, 20, 15, 0);
      expect(relativeTime(now.subtract(const Duration(seconds: 20)), now), 'Az önce');
      expect(relativeTime(now.subtract(const Duration(minutes: 5)), now), '5 dk önce');
      expect(relativeTime(now.subtract(const Duration(hours: 3)), now), '3 sa önce');
      expect(relativeTime(DateTime(2026, 9, 19, 9, 0), now), 'Dün');
      expect(relativeTime(DateTime(2026, 9, 12, 9, 0), now), '12.09.2026');
    });
  });

  group('LeagueCard', () {
    testWidgets('lig adı, anonim sıra, hedef ve kalan süre görünür', (tester) async {
      await tester.pumpWidget(_host(const LeagueCard(status: _league)));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Bronz Ligi'), findsOneWidget);
      expect(find.text('12 öğrenci arasında 3. sıradasın'), findsOneWidget);
      expect(find.text('Bu hafta 60 XP'), findsOneWidget);
      expect(find.text('Hedef: 100 XP'), findsOneWidget);
      expect(find.text('Gümüş Ligi için 40 XP daha!'), findsOneWidget);
      expect(find.text('Haftanın bitmesine 2 gün 5 saat'), findsOneWidget);
    });

    testWidgets('tek öğrenci varsa sıra yerine cesaretlendirici metin', (tester) async {
      await tester.pumpWidget(_host(LeagueCard(status: _leagueWith(total: 1))));
      expect(find.text('Ligin ilk öğrencilerinden birisin!'), findsOneWidget);
    });

    testWidgets('hedef tamamlanınca müjde, zirvede farklı metin', (tester) async {
      await tester.pumpWidget(_host(LeagueCard(status: _leagueWith(weeklyXp: 120))));
      expect(find.textContaining('Hedefi tamamladın'), findsOneWidget);

      await tester.pumpWidget(_host(LeagueCard(status: _leagueWith(promotionXp: null))));
      expect(find.textContaining('Zirvedesin'), findsOneWidget);
      expect(find.textContaining('Hedef:'), findsNothing);
    });

    testWidgets('kompakt görünüm kısa özet gösterir', (tester) async {
      await tester.pumpWidget(_host(const LeagueCard(status: _league, compact: true)));
      expect(find.text('Bu hafta 60 XP • 2 gün 5 saat kaldı'), findsOneWidget);
      expect(find.textContaining('sıradasın'), findsNothing);
    });
  });

  group('ProgressCard', () {
    testWidgets('toplamlar ve ders ilerlemesi', (tester) async {
      await tester.pumpWidget(_host(const ProgressCard(
        overview: ProfileOverview(
          totalSolved: 42,
          accuracy: 81,
          longestStreak: 5,
          subjects: [SubjectProgress(ders: 'Matematik', solved: 3, total: 4, success: 90)],
        ),
      )));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('42'), findsOneWidget);
      expect(find.text('%81'), findsOneWidget);
      expect(find.text('5 gün'), findsOneWidget);
      expect(find.text('3/4 soru'), findsOneWidget);
      expect(find.text('Başarı %90'), findsOneWidget);
    });

    testWidgets('hiç ders/soru yokken boş durum metni', (tester) async {
      await tester.pumpWidget(_host(const ProgressCard(
        overview: ProfileOverview(totalSolved: 0, longestStreak: 0, subjects: []),
      )));
      expect(find.text('-'), findsOneWidget); // doğruluk yok
      expect(find.text('Soru çözdükçe ders ilerlemen burada görünecek.'), findsOneWidget);
    });
  });

  group('Bildirim ekranı', () {
    Future<_FakeRepo> pump(WidgetTester tester, List<AppNotification> items) async {
      final repo = _FakeRepo(items);
      await tester.pumpWidget(ProviderScope(
        overrides: [
          quizRepositoryProvider.overrideWithValue(repo),
          unreadCountProvider.overrideWith((ref) async => 0),
        ],
        child: const MaterialApp(home: NotificationsScreen()),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      return repo;
    }

    testWidgets('bildirimler listelenir ve açılınca okundu işaretlenir', (tester) async {
      final repo = await pump(tester, [_notif('1'), _notif('2', read: true, type: 'lig')]);

      expect(find.text('Bildirimler'), findsOneWidget);
      expect(find.text('Başlık 1'), findsOneWidget);
      expect(find.text('Mesaj 2'), findsOneWidget);
      expect(find.text('5 dk önce'), findsNWidgets(2));
      expect(repo.markCalls, 1);
    });

    testWidgets('hepsi zaten okunduysa tekrar işaretleme çağrısı yapılmaz', (tester) async {
      final repo = await pump(tester, [_notif('1', read: true)]);
      expect(repo.markCalls, 0);
    });

    testWidgets('bildirim yoksa cesaretlendirici boş durum', (tester) async {
      await pump(tester, const []);
      expect(
        find.text('Şimdilik yeni bir şey yok. Soru çözdükçe burada güzel haberler olacak!'),
        findsOneWidget,
      );
    });
  });

  group('Bildirim zili', () {
    Future<void> pumpBell(WidgetTester tester, int unread) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [unreadCountProvider.overrideWith((ref) async => unread)],
        child: const MaterialApp(home: Scaffold(body: Center(child: NotificationBell()))),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('okunmamış sayısı rozette görünür', (tester) async {
      await pumpBell(tester, 3);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('9\'dan fazlaysa "9+" yazar', (tester) async {
      await pumpBell(tester, 12);
      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('okunmamış yoksa rozet görünmez', (tester) async {
      await pumpBell(tester, 0);
      expect(find.text('0'), findsNothing);
    });
  });
}
