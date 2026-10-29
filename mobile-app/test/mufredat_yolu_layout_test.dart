// Müfredat yolu ekranı: 320/390 px, %130 yazı boyutu, uzun Türkçe metin ve alt sayfa düzen kontrolü.
// Cihaz ekran kontrolü değildir; taşma (RenderFlex) ve istisna kontrolüdür.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/models/mufredat_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/mufredat_yolu_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';

const _ders = 'Türkçe';

const _uzunMetin =
    'Dinlediklerinde/izlediklerinde geçen, bilmediği kelimelerin anlamını tahmin eder. '
    'Öğrencilerin tahminlerini kelimelerin sözlük anlamları ile karşılaştırmaları sağlanır';

class _FakeRepo extends Fake implements QuizRepository {
  _FakeRepo(this.yanit);

  final Map<String, dynamic> yanit;

  @override
  Future<MufredatHaritasi> fetchMufredatHaritasi(String ders) async =>
      MufredatHaritasi.fromMap(yanit);

  @override
  Future<List<Question>> fetchMufredatSorulari({
    required String ders,
    required String mod,
    int? hafta,
    List<String>? kazanimKodlari,
    int limit = 10,
  }) async =>
      const [];
}

Map<String, dynamic> _kazanim(String kod,
        {int? ilk, int soru = 0, int cevap = 0, int dogru = 0}) =>
    {
      'kod': kod,
      'metin': _uzunMetin,
      'ilk_hafta': ilk,
      'soru_sayisi': soru,
      'cevaplanan': cevap,
      'dogru': dogru,
    };

/// Uzun tema ve konu adları, birkaç işlenmiş ve gelecek hafta, bir tatil haftası.
Map<String, dynamic> _uzunHarita() => {
      'sinif': 4,
      'ders': _ders,
      'bugun_hafta': 4,
      'haftalar': [
        for (var h = 1; h <= 6; h++)
          {
            'hafta': h,
            'baslangic': '2026-10-05',
            'bitis': '2026-10-09',
            'tatil': h == 3,
            'unite_tema': h == 3
                ? null
                : 'ÇOCUK DÜNYASI | BİLİM VE TEKNOLOJİ | DOĞA VE EVREN',
            'konular': h == 3
                ? <String>[]
                : [
                    'ÇOCUKLUĞUM BİTTİ Mİ? (Dinleme/İzleme Metni) / SÖZÜN GÜCÜ (Serbest Okuma Metni)',
                  ],
            'kazanimlar': h == 3
                ? <Map<String, dynamic>>[]
                : [
                    _kazanim('T.4.1.$h', ilk: h, soru: 5, cevap: 8, dogru: 6),
                    _kazanim('T.4.2.$h', ilk: h + 2, soru: 0),
                  ],
          },
      ],
    };

Future<void> _pump(WidgetTester tester,
    {required Size boyut, double yazi = 1.0}) async {
  await tester.binding.setSurfaceSize(boyut);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        quizRepositoryProvider.overrideWithValue(_FakeRepo(_uzunHarita()))
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data:
              MediaQuery.of(ctx).copyWith(textScaler: TextScaler.linear(yazi)),
          child: child!,
        ),
        home: const MufredatYoluScreen(ders: _ders),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  for (final boyut in const [Size(320, 640), Size(390, 844)]) {
    testWidgets('${boyut.width.toInt()} px: uzun metinlerle taşma yok',
        (tester) async {
      await _pump(tester, boyut: boyut);
      expect(tester.takeException(), isNull);
      expect(find.text('Bu haftanın konuları'), findsOneWidget);
      expect(find.text('6. hafta'), findsOneWidget);
    });

    testWidgets('${boyut.width.toInt()} px, %130 yazı: taşma yok',
        (tester) async {
      await _pump(tester, boyut: boyut, yazi: 1.3);
      expect(tester.takeException(), isNull);
      expect(find.text('Konu seç'), findsOneWidget);
    });

    testWidgets('${boyut.width.toInt()} px: Konu seç sayfası taşmadan açılır',
        (tester) async {
      await _pump(tester, boyut: boyut, yazi: 1.3);
      await tester.tap(find.text('Konu seç'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.text('Hangi konuyu çözmek istersin?'), findsOneWidget);
    });

    testWidgets(
        '${boyut.width.toInt()} px: gelecek kazanım bilgi sayfası taşmadan açılır',
        (tester) async {
      await _pump(tester, boyut: boyut, yazi: 1.3);
      final kazanim = find.text('T.4.2.1').first;
      await tester.ensureVisible(kazanim);
      await tester.tap(kazanim);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
      expect(find.text('Kapat'), findsOneWidget);
    });
  }
}
