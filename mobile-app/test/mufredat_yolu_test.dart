// WP5: Müfredat yolu ekranı — yükleniyor / hata / boş / dolu durumları ve oran kuralı (5–8. sınıf, ≥6 cevap).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/models/mufredat_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/mufredat_yolu_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';

const _ders = 'Matematik';

/// Sunucu yanıtını taklit eden sahte depo. [haritaYaniti] null ise yükleniyor durumu (hiç bitmez).
class _FakeRepo extends Fake implements QuizRepository {
  _FakeRepo({this.haritaYaniti, this.hata = false});

  final Map<String, dynamic>? haritaYaniti;
  final bool hata;
  final soruCagrilari = <String>[];

  @override
  Future<MufredatHaritasi> fetchMufredatHaritasi(String ders) async {
    if (hata) throw Exception('ağ hatası');
    final yanit = haritaYaniti;
    if (yanit == null) {
      // Hiç tamamlanmayan istek: yükleniyor durumunu sabitler.
      return Completer<MufredatHaritasi>().future;
    }
    return MufredatHaritasi.fromMap(yanit);
  }

  @override
  Future<List<Question>> fetchMufredatSorulari({
    required String ders,
    required String mod,
    int? hafta,
    List<String>? kazanimKodlari,
    int limit = 10,
  }) async {
    soruCagrilari.add(mod);
    return const [];
  }
}

Map<String, dynamic> _kazanim({
  required String kod,
  int? ilk,
  int soru = 0,
  int cevap = 0,
  int dogru = 0,
}) =>
    {
      'kod': kod,
      'metin': 'Kazanım $kod metni',
      'ilk_hafta': ilk,
      'soru_sayisi': soru,
      'cevaplanan': cevap,
      'dogru': dogru,
    };

Map<String, dynamic> _harita({
  required int sinif,
  required List<Map<String, dynamic>> kazanimlar,
  int bugun = 2,
  bool tatilHaftasi = false,
  int ekSoru = 3,
}) =>
    {
      'sinif': sinif,
      'ders': _ders,
      'bugun_hafta': bugun,
      'haftalar': [
        {
          'hafta': 1,
          'baslangic': '2026-09-14',
          'bitis': '2026-09-18',
          'tatil': false,
          'unite_tema': 'GEOMETRİK ŞEKİLLER',
          'konular': ['Temel Geometrik Çizimler'],
          'kazanimlar': kazanimlar,
        },
        {
          'hafta': 2,
          'baslangic': '2026-09-21',
          'bitis': '2026-09-25',
          'tatil': tatilHaftasi,
          'unite_tema': tatilHaftasi ? null : 'SAYILAR',
          'konular': tatilHaftasi ? [] : ['Doğal Sayılar'],
          'kazanimlar': tatilHaftasi
              ? []
              : [_kazanim(kod: 'MAT.5.1.2', ilk: 2, soru: ekSoru)],
        },
        {
          'hafta': 9,
          'baslangic': '2026-11-16',
          'bitis': '2026-11-20',
          'tatil': false,
          'unite_tema': 'ÖLÇME',
          'konular': ['Uzunluk Ölçme'],
          'kazanimlar': [_kazanim(kod: 'MAT.5.4.1', ilk: 9, soru: ekSoru)],
        },
      ],
    };

Future<_FakeRepo> _pump(
  WidgetTester tester, {
  Map<String, dynamic>? harita,
  bool hata = false,
  Size boyut = const Size(420, 900),
}) async {
  final repo = _FakeRepo(haritaYaniti: harita, hata: hata);
  await tester.binding.setSurfaceSize(boyut);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [quizRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(
        home: MufredatYoluScreen(ders: _ders),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return repo;
}

void main() {
  group('Müfredat yolu durumları', () {
    testWidgets('yükleniyor durumu gösterilir', (tester) async {
      await _pump(tester);
      expect(find.text('Müfredat yolun hazırlanıyor...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('hata durumunda metin ve Yeniden dene düğmesi görünür', (tester) async {
      await _pump(tester, hata: true);
      expect(find.text('Müfredat yolu yüklenemedi, tekrar deneyelim.'), findsOneWidget);
      expect(find.text('Yeniden dene'), findsOneWidget);
    });

    testWidgets('hiç onaylı soru yoksa boş durum gösterilir', (tester) async {
      await _pump(
        tester,
        harita: _harita(sinif: 5, ekSoru: 0, kazanimlar: [_kazanim(kod: 'MAT.5.1.1', ilk: 1)]),
      );
      expect(find.text('Bu derste henüz müfredata bağlı soru yok. Yakında!'), findsOneWidget);
      expect(find.text('Bu haftanın konuları'), findsNothing);
    });

    testWidgets('dolu durumda eylemler ve haftalar görünür', (tester) async {
      await _pump(
        tester,
        harita: _harita(sinif: 5, kazanimlar: [_kazanim(kod: 'MAT.5.1.1', ilk: 1, soru: 4)]),
      );
      expect(find.text('Bu haftanın konuları'), findsOneWidget);
      expect(find.text('Bugüne kadar karışık'), findsOneWidget);
      expect(find.text('Konu seç'), findsOneWidget);
      expect(find.text('1. hafta'), findsOneWidget);
      expect(find.text('Bugün 2. hafta'), findsOneWidget);
      expect(find.text('Bu hafta'), findsOneWidget); // 2. hafta
      expect(find.text('Henüz işlenmedi'), findsWidgets); // 9. hafta
      expect(find.text('Hangi konuyu çözmek istersin?'), findsNothing);
    });

    testWidgets('tatil haftası Tatil kartı olarak görünür', (tester) async {
      await _pump(
        tester,
        harita: _harita(
          sinif: 5,
          kazanimlar: [_kazanim(kod: 'MAT.5.1.1', ilk: 1, soru: 4)],
          tatilHaftasi: true,
        ),
      );
      expect(find.text('Tatil · 2. hafta'), findsOneWidget);
    });

    testWidgets('320 px genişlikte taşma olmadan çizilir', (tester) async {
      await _pump(
        tester,
        harita: _harita(sinif: 5, kazanimlar: [_kazanim(kod: 'MAT.5.1.1', ilk: 1, soru: 4, cevap: 8, dogru: 6)]),
        boyut: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Bu haftanın konuları'), findsOneWidget);
    });
  });

  group('Doğruluk oranı kuralı', () {
    Map<String, dynamic> hariteliKazanim({required int cevap, required int dogru}) => _harita(
          sinif: 5,
          kazanimlar: [
            _kazanim(kod: 'MAT.5.1.1', ilk: 1, soru: 4, cevap: cevap, dogru: dogru),
          ],
        );

    testWidgets('5. sınıfta 6 cevapta oran görünür', (tester) async {
      await _pump(tester, harita: hariteliKazanim(cevap: 6, dogru: 3));
      expect(find.text('%50'), findsOneWidget);
    });

    testWidgets('5. sınıfta 5 cevapta oran gizli', (tester) async {
      await _pump(tester, harita: hariteliKazanim(cevap: 5, dogru: 5));
      expect(find.text('%100'), findsNothing);
    });

    testWidgets('1–4. sınıfta yeterli cevap olsa da oran gizli', (tester) async {
      final harita = _harita(
        sinif: 3,
        kazanimlar: [_kazanim(kod: 'MAT.3.1.1', ilk: 1, soru: 4, cevap: 10, dogru: 5)],
      );
      await _pump(tester, harita: harita);
      expect(find.text('%50'), findsNothing);
    });

    testWidgets('sınıf bilinmiyorsa oran gizli', (tester) async {
      final harita = _harita(
        sinif: 5,
        kazanimlar: [_kazanim(kod: 'MAT.5.1.1', ilk: 1, soru: 4, cevap: 10, dogru: 5)],
      )..remove('sinif');
      await _pump(tester, harita: harita);
      expect(find.text('%50'), findsNothing);
    });
  });

  group('Gelecek haftalar', () {
    testWidgets('gelecek kazanıma dokununca bilgi gösterilir, quiz başlamaz', (tester) async {
      final repo = await _pump(
        tester,
        harita: _harita(sinif: 5, kazanimlar: [_kazanim(kod: 'MAT.5.1.1', ilk: 1, soru: 4)]),
      );
      await tester.ensureVisible(find.text('Kazanım MAT.5.4.1 metni'));
      await tester.tap(find.text('Kazanım MAT.5.4.1 metni'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Bu kazanım 9. haftada işlenecek. O hafta gelince sorular açılır.'),
          findsOneWidget);
      expect(repo.soruCagrilari, isEmpty);
    });

    testWidgets('Bu haftanın konuları düğmesi bu_hafta modunu çağırır', (tester) async {
      final repo = await _pump(
        tester,
        harita: _harita(sinif: 5, kazanimlar: [_kazanim(kod: 'MAT.5.1.1', ilk: 1, soru: 4)]),
      );
      await tester.tap(find.text('Bu haftanın konuları'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(repo.soruCagrilari, ['bu_hafta']);
    });
  });
}
