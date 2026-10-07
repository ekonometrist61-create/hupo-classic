// W3: Ay Ligi tam ekranı — merdiven, geçilen/buradasın/kilitli durumları.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/league_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/league_screen.dart';

const _durum = LeagueStatus(
  code: 'altin',
  name: 'Altın Ligi',
  tier: 3,
  colorHex: '#FFC533',
  icon: 'shield',
  weeklyXp: 120,
  rank: 4,
  total: 18,
  remainingSeconds: 3 * 86400,
  nextLeagueName: 'Zümrüt Ligi',
  promotionXp: 200,
);

const _merdiven = [
  LeagueTier(code: 'bronz', name: 'Bronz Ligi', tier: 1, colorHex: '#CD7F32', icon: 'shield', promotionXp: 100),
  LeagueTier(code: 'gumus', name: 'Gümüş Ligi', tier: 2, colorHex: '#9AA5B1', icon: 'shield', promotionXp: 150),
  LeagueTier(code: 'altin', name: 'Altın Ligi', tier: 3, colorHex: '#FFC533', icon: 'shield', promotionXp: 200),
  LeagueTier(code: 'zumrut', name: 'Zümrüt Ligi', tier: 4, colorHex: '#22C58B', icon: 'shield', promotionXp: 250),
  LeagueTier(code: 'elmas', name: 'Elmas Ligi', tier: 5, colorHex: '#2FB8FF', icon: 'diamond'),
];

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(420, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        leagueProvider.overrideWith((ref) async => _durum),
        leagueLadderProvider.overrideWith((ref) async => _merdiven),
      ],
      child: const MaterialApp(home: LeagueScreen()),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('güncel lig adı üstte, merdivende doğru durumlar gösterilir', (tester) async {
    await _pump(tester);

    // Üst başlık + LeagueCard + merdivendeki kendi satırı: üç kez geçer.
    expect(find.text('Altın Ligi'), findsNWidgets(3));

    // Altında (tier 1-2): geçildi. Kendisi (tier 3): buradasın. Üstü (4-5): kilitli.
    expect(find.text('Geçtin'), findsNWidgets(2)); // Bronz, Gümüş
    expect(find.text('Buradasın'), findsOneWidget); // Altın
    expect(find.text('Kilitli'), findsNWidgets(2)); // Zümrüt, Elmas

    expect(find.text('Bronz Ligi'), findsOneWidget);
    expect(find.text('Elmas Ligi'), findsOneWidget);
    // Elmas'ın (en üst) yükselme eşiği yoktur.
    expect(find.text('Çıkış: 250 XP/hafta'), findsOneWidget); // Zümrüt
  });

  testWidgets('geri düğmesi önceki ekrana döner', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leagueProvider.overrideWith((ref) async => _durum),
          leagueLadderProvider.overrideWith((ref) async => _merdiven),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LeagueScreen()),
                  ),
                  child: const Text('aç'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();
    expect(find.byType(LeagueScreen), findsOneWidget);

    await tester.tap(find.byTooltip('Geri'));
    await tester.pumpAndSettle();
    expect(find.byType(LeagueScreen), findsNothing);
    expect(find.text('aç'), findsOneWidget);
  });
}
