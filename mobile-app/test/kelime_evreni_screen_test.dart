import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/kelime_models.dart';
import 'package:ogrenci_hazirlik/providers/kelime_providers.dart';
import 'package:ogrenci_hazirlik/screens/kelime/kelime_evreni_screen.dart';
import 'package:ogrenci_hazirlik/services/kelime_repository.dart';

import 'kelime_fake_repository.dart';

/// Özet çağrısı her zaman hata verir (ağ/sunucu hatası durumunu denemek için).
class OzetHatali extends FakeKelimeRepository {
  @override
  Future<KelimeOzet> ozet() async => throw const KelimeException(KelimeHatasi.baglanti, 'Bilgiler yüklenemedi.');
}

Future<void> _pump(WidgetTester tester, KelimeRepository repo, Size boyut) async {
  await tester.binding.setSurfaceSize(boyut);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [kelimeRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: KelimeEvreniScreen()),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  for (final boyut in const [Size(390, 844), Size(1024, 768)]) {
    final etiket = '${boyut.width.toInt()}x${boyut.height.toInt()}';

    testWidgets('üç oyun kartı ve boş kaydedilen listesi görünür ($etiket)', (tester) async {
      await _pump(tester, FakeKelimeRepository(), boyut);

      expect(find.text('Anlam Köprüleri'), findsOneWidget);
      expect(find.text('Zıtlık Vadisi'), findsOneWidget);
      expect(find.text('Aynalar Ormanı'), findsOneWidget);
      expect(find.text('Kaydettiğim kelimeler'), findsOneWidget);
      expect(find.textContaining("'Bu kelimeyi kaydet'"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('özet alınamazsa hata metni ve "Tekrar dene" gösterilir', (tester) async {
    await _pump(tester, OzetHatali(), const Size(390, 844));

    expect(find.text('Bilgiler yüklenemedi.'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
