// Veli ana ekranı testleri: çocuk yok / çocuk var / rıza yok / yükleniyor / hata.
// Supabase'e bağlanılmaz; provider'lar override edilir ve hiçbir RPC çağrılmaz.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/models/survey_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/screens/home_screen.dart';
import 'package:ogrenci_hazirlik/services/quiz_repository.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/widgets/ui/chunky_button.dart';
import 'package:ogrenci_hazirlik/widgets/veli/veli_cocuk_veri.dart';
import 'package:ogrenci_hazirlik/widgets/veli/veli_ilerleme_bolumu.dart';

const _ece = VeliCocuk(id: 'c1', adSoyad: 'Ece Demir', kullaniciAdi: 'ece.d');

const _verili = CocukOzeti(
  riza: VeliRiza.verildi,
  xp: 1250,
  seviye: 4,
  seriGun: 3,
  haftaDakika: 42.4,
  haftaSoru: 58,
  tekrarKonulari: ['Kesirler', 'Oranlar'],
);

const _rizaYok = CocukOzeti(riza: VeliRiza.yok);

/// Sunucuya gitmeyen sahte depo. Yalnızca çıkış düğmesinin tear-off'u için gerekir.
class _FakeRepo extends Fake implements QuizRepository {
  @override
  Future<void> signOut() async {}
}

Future<void> _pumpBolum(
  WidgetTester tester,
  List<Override> overrides, {
  VoidCallback? onPanelAc,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: VeliIlerlemeBolumu(onPanelAc: onPanelAc ?? () {}),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  group('Çocuk ve özet ayrıştırma', () {
    test('boş ad kullanıcı adına, o da yoksa genel etikete düşer', () {
      expect(
        VeliCocuk.fromMap({'id': 'c1', 'full_name': '  ', 'username': 'ece.d'}).gorunenAd,
        'ece.d',
      );
      expect(
        VeliCocuk.fromMap({'id': 'c2', 'full_name': null, 'username': null}).gorunenAd,
        'Çocuğunuz',
      );
    });

    test('rıza yoksa çocuk verisi okunmaz (sunucu yalnızca riza döner)', () {
      final ozet = CocukOzeti.fromMap({
        'riza': 'yok',
        'ozet': null,
        'haftalik': [],
        'ders_basari': [],
        'tekrar_konulari': [],
      });
      expect(ozet.riza, VeliRiza.yok);
      expect(ozet.verisiGorunur, isFalse);
      expect(ozet.haftaDakika, 0);
    });

    test('rıza verildiyse haftalık toplam ve tekrar konuları okunur', () {
      final ozet = CocukOzeti.fromMap({
        'riza': 'verildi',
        'ozet': {'xp': '1250', 'level': 4, 'streak_count': 3, 'last_active_date': null},
        'haftalik': [
          {'gun': '2026-10-13', 'sure_dk': '12.5', 'soru_sayisi': 4},
          {'gun': '2026-10-14', 'sure_dk': 7, 'soru_sayisi': 3},
        ],
        'tekrar_konulari': [
          {'konu': 'Kesirler'},
          {'konu': '  '},
        ],
      });
      expect(ozet.verisiGorunur, isTrue);
      expect(ozet.haftaDakika, 19.5);
      expect(ozet.haftaSoru, 7);
      expect(ozet.xp, 1250);
      expect(ozet.tekrarKonulari, ['Kesirler']);
    });

    test('özet boşsa seviye 1 ve XP 0 varsayılır', () {
      final ozet = CocukOzeti.fromMap({
        'riza': 'verildi',
        'ozet': null,
        'haftalik': [],
        'tekrar_konulari': [],
      });
      expect(ozet.seviye, 1);
      expect(ozet.xp, 0);
    });
  });

  group('Veli ana ekranı çocuk bölümü', () {
    testWidgets('çocuk yoksa bağlantı açıklaması ve "Veli panelini aç" görünür',
        (tester) async {
      await _pumpBolum(tester, [
        veliCocuklarProvider.overrideWith((ref) async => const <VeliCocuk>[]),
      ]);

      expect(find.text('Henüz bağlı çocuk yok'), findsOneWidget);
      expect(find.textContaining('Ayarlar → Veline bağlan'), findsOneWidget);
      expect(find.text('Veli panelini aç'), findsOneWidget);
      expect(find.text('Çocuğumun ilerlemesi'), findsNothing);
    });

    testWidgets('çocuk varsa ad, son 7 gün özeti ve ana eylem görünür', (tester) async {
      await _pumpBolum(tester, [
        veliCocuklarProvider.overrideWith((ref) async => const [_ece]),
        veliCocukOzetiProvider.overrideWith((ref, cocukId) async => _verili),
      ]);

      expect(find.text('Ece Demir'), findsOneWidget);
      expect(find.text('42 dk'), findsOneWidget);
      expect(find.text('58'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Önerilen tekrar: Kesirler'), findsOneWidget);
      expect(
        find.textContaining('Oyun ilerlemesi: Seviye 4 · 1.250 XP'),
        findsOneWidget,
      );
      expect(find.text('Çocuğumun ilerlemesi'), findsOneWidget);
      expect(find.text('Veli panelini aç'), findsNothing);
    });

    testWidgets('ana eyleme dokununca onPanelAc çağrılır', (tester) async {
      var acildi = false;
      await _pumpBolum(
        tester,
        [
          veliCocuklarProvider.overrideWith((ref) async => const [_ece]),
          veliCocukOzetiProvider.overrideWith((ref, cocukId) async => _verili),
        ],
        onPanelAc: () => acildi = true,
      );

      await tester.tap(find.text('Çocuğumun ilerlemesi'));
      await tester.pump();

      expect(acildi, isTrue);
    });

    testWidgets('ana eylem dokunma hedefi en az 44 piksel', (tester) async {
      await _pumpBolum(tester, [
        veliCocuklarProvider.overrideWith((ref) async => const [_ece]),
        veliCocukOzetiProvider.overrideWith((ref, cocukId) async => _verili),
      ]);

      final dugme = tester.getSize(find.byType(ChunkyButton).first);
      expect(dugme.height, greaterThanOrEqualTo(44));
    });

    testWidgets('veri onayı yoksa çocuğun çalışma sayıları gösterilmez', (tester) async {
      await _pumpBolum(tester, [
        veliCocuklarProvider.overrideWith((ref) async => const [_ece]),
        veliCocukOzetiProvider.overrideWith((ref, cocukId) async => _rizaYok),
      ]);

      expect(find.textContaining('veri işleme onayı vermeniz'), findsOneWidget);
      expect(find.text('42 dk'), findsNothing);
      expect(find.text('Çocuğumun ilerlemesi'), findsOneWidget);
    });

    testWidgets('çocuk listesi yüklenemezse sakin hata, Tekrar dene ve ana eylem görünür',
        (tester) async {
      await _pumpBolum(tester, [
        veliCocuklarProvider.overrideWith((ref) async => throw Exception('ağ hatası')),
      ]);

      expect(find.text('Çocuk bilgileri şu an yüklenemedi.'), findsOneWidget);
      expect(find.text('Tekrar dene'), findsOneWidget);
      expect(find.text('Çocuğumun ilerlemesi'), findsOneWidget);
    });

    testWidgets('çocuk listesi yüklenirken yükleniyor metni görünür', (tester) async {
      final tamamlanmaz = Completer<List<VeliCocuk>>();
      await _pumpBolum(tester, [
        veliCocuklarProvider.overrideWith((ref) => tamamlanmaz.future),
      ]);

      expect(find.text('Çocuklarınız yükleniyor…'), findsOneWidget);
      expect(find.text('Çocuğumun ilerlemesi'), findsOneWidget);
    });

    testWidgets('özet alınamazsa kartta sakin hata ve Tekrar dene görünür', (tester) async {
      await _pumpBolum(tester, [
        veliCocuklarProvider.overrideWith((ref) async => const [_ece]),
        veliCocukOzetiProvider.overrideWith((ref, cocukId) async => throw Exception('ağ')),
      ]);

      expect(find.text('Bu çocuğun özeti şu an alınamadı.'), findsOneWidget);
      expect(find.text('Tekrar dene'), findsOneWidget);
      expect(find.text('Ece Demir'), findsOneWidget);
    });
  });

  group('Veli ana ekranı (HomeScreen veli dalı)', () {
    testWidgets('öğrenci dışı metin kalktı; selamlama, çocuk ve çıkış görünür',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(
              (ref) async => const Profile(id: 'v1', role: 'veli', fullName: 'Ayşe Yılmaz'),
            ),
            quizRepositoryProvider.overrideWithValue(_FakeRepo()),
            aktifDuyuruProvider.overrideWith((ref) async => null),
            aktifAnketlerProvider.overrideWith((ref) async => const <Anket>[]),
            veliCocuklarProvider.overrideWith((ref) async => const [_ece]),
            veliCocukOzetiProvider.overrideWith((ref, cocukId) async => _verili),
          ],
          child: MaterialApp(theme: buildAppTheme(), home: const HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Merhaba, Ayşe'), findsOneWidget);
      expect(find.text('Bu uygulama yalnızca öğrenci hesapları içindir.'), findsNothing);
      expect(find.text('Ece Demir'), findsOneWidget);
      expect(find.text('Çıkış yap'), findsOneWidget);
    });
  });
}
