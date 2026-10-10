import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/challenge_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/challenge_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';

/// Kelime meydanı çağrısını kaydeder. Bekleme ekranına (zamanlayıcılı) geçilmesin diye hata döner.
class FakeArenaRepository extends Fake implements QuizRepository {
  final List<String?> kelimeCagrilari = [];

  @override
  Future<ChallengeSession> createKelimeChallenge({String? iliskiTuru}) async {
    kelimeCagrilari.add(iliskiTuru);
    throw Exception('Yeterli soru bulunamadı');
  }
}

Future<FakeArenaRepository> _pump(WidgetTester tester) async {
  final repo = FakeArenaRepository();
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [quizRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: ChallengeHubScreen()),
    ),
  );
  await tester.pump();
  return repo;
}

void main() {
  testWidgets('hub\'da Kelime Evreni ile meydan okuma düğmesi var', (tester) async {
    await _pump(tester);
    expect(find.text('Kelime Evreni ile Meydan Oku'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tür seçimi doğru ilişki türünü kelime meydanına gönderir', (tester) async {
    final repo = await _pump(tester);

    await tester.tap(find.text('Kelime Evreni ile Meydan Oku'));
    await tester.pumpAndSettle();
    expect(find.text('Hangi kelime oyunu?'), findsOneWidget);

    await tester.tap(find.text('Anlam Köprüleri'));
    await tester.pumpAndSettle();

    expect(repo.kelimeCagrilari, ['es_anlamli']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('"Karışık" seçilirse ilişki türü null gider', (tester) async {
    final repo = await _pump(tester);

    await tester.tap(find.text('Kelime Evreni ile Meydan Oku'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karışık'));
    await tester.pumpAndSettle();

    expect(repo.kelimeCagrilari, [null]);
  });

  testWidgets('yetersiz soru hatası Türkçe mesajla gösterilir', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('Kelime Evreni ile Meydan Oku'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karışık'));
    await tester.pumpAndSettle();

    expect(find.text('Bu tür için yeterli soru yok. Başka bir tür dene.'), findsOneWidget);
  });
}
