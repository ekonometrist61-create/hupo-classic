import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/widgets/badges_section.dart';
import 'package:ogrenci_hazirlik/widgets/level_card.dart';

final _earned = BadgeInfo(
  code: 'ilk_soru',
  name: 'İlk Adım',
  description: 'İlk sorunu çöz.',
  icon: 'flag',
  conditionType: 'soru_sayisi',
  threshold: 1,
  earned: true,
  earnedAt: DateTime(2026, 9, 12),
  progress: 1,
);

const _locked = BadgeInfo(
  code: 'matematik_90',
  name: 'Matematik Ustası',
  description: 'Matematik dersinde en az 10 soru çöz ve %90 başarı yakala.',
  icon: 'calculate',
  conditionType: 'ders_basari',
  threshold: 90,
  ders: 'Matematik',
  earned: false,
  progress: 72,
  attempts: 5,
);

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('BadgeInfo', () {
    test('fromMap sunucu çıktısını okur', () {
      final b = BadgeInfo.fromMap({
        'kod': 'streak_7',
        'ad': 'Alev Alev',
        'aciklama': '7 gün üst üste soru çöz.',
        'ikon': 'local_fire_department',
        'kosul_turu': 'streak',
        'esik': 7,
        'ders': null,
        'min_deneme': 10,
        'kazanildi': false,
        'kazanma_tarihi': null,
        'ilerleme': 3,
        'deneme': null,
      });
      expect(b.earned, isFalse);
      expect(b.earnedAt, isNull);
      expect(b.progressLabel, '3 / 7 gün');
      expect(b.progressFraction, closeTo(3 / 7, 1e-9));
    });

    test('ders başarısında yavaş ilerleyen şart ilerlemeyi belirler', () {
      // Başarı %72/%90 = 0.8, soru sayısı 5/10 = 0.5 → 0.5
      expect(_locked.progressFraction, closeTo(0.5, 1e-9));
      expect(_locked.progressLabel, 'Başarı %72 / %90  •  5 / 10 soru');
    });

    test('kazanılmış rozette ilerleme tamamdır', () {
      expect(_earned.progressFraction, 1);
    });
  });

  group('BadgesSection', () {
    testWidgets('kilitli rozetin üzerinde kilit simgesi, kazanılanda yok', (tester) async {
      await tester.pumpWidget(_host(BadgesSection(badges: [_earned, _locked])));

      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget); // yalnızca kilitli olanda
    });

    testWidgets('kilitli rozete dokununca kazanma şartı popup olarak açılır', (tester) async {
      await tester.pumpWidget(_host(BadgesSection(badges: [_earned, _locked])));

      await tester.tap(find.text('Matematik Ustası'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Kazanma şartı'), findsOneWidget);
      expect(
        find.text('Matematik dersinde en az 10 soru çöz ve %90 başarı yakala.'),
        findsOneWidget,
      );
      expect(find.text('Kilitli'), findsOneWidget);
      expect(find.text('Başarı %72 / %90  •  5 / 10 soru'), findsOneWidget);

      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('kazanılan rozette kazanma tarihi görünür', (tester) async {
      await tester.pumpWidget(_host(BadgesSection(badges: [_earned, _locked])));

      await tester.tap(find.text('İlk Adım'));
      await tester.pumpAndSettle();

      expect(find.text('Kazanıldı • 12.09.2026'), findsOneWidget);
      expect(find.text('İlk sorunu çöz.'), findsOneWidget);
      // İlerleme çubuğu yalnızca kilitli rozetlerde
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('rozet yoksa bilgi metni gösterilir', (tester) async {
      await tester.pumpWidget(_host(const BadgesSection(badges: [])));
      expect(find.text('Rozetler çok yakında burada olacak!'), findsOneWidget);
    });
  });

  testWidgets('LevelCard seviye, XP ve seriyi gösterir', (tester) async {
    await tester.pumpWidget(_host(LevelCard(
      stats: StudentStats(
        xp: 230,
        level: 3,
        streakCount: 4,
        lastActiveDate: DateTime(2026, 9, 19),
      ),
      today: DateTime(2026, 9, 20),
    )));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Seviye 3'), findsOneWidget);
    expect(find.text('230 XP'), findsOneWidget);
    expect(find.text('Sonraki seviyeye sadece 70 XP kaldı!'), findsOneWidget);
    expect(find.text('4 günlük seri, devam et!'), findsOneWidget);
  });
}
