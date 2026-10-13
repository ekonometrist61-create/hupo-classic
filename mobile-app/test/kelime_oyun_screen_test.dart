import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/kelime_models.dart';
import 'package:ogrenci_hazirlik/providers/kelime_providers.dart';
import 'package:ogrenci_hazirlik/screens/kelime/kelime_oyun_screen.dart';
import 'package:ogrenci_hazirlik/services/kelime_repository.dart';

import 'kelime_fake_repository.dart';

/// Telefon ve tablet/masaüstü boyutlarında taşma (overflow) olmadığını da denetler.
const List<Size> _boyutlar = [Size(390, 844), Size(1024, 768)];

Future<void> _pumpOyun(
  WidgetTester tester, {
  required Size boyut,
  required FakeKelimeRepository repo,
  KelimeIliskiTuru iliski = KelimeIliskiTuru.esAnlamli,
}) async {
  await tester.binding.setSurfaceSize(boyut);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [kelimeRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(home: KelimeOyunScreen(iliski: iliski)),
    ),
  );
  // postFrame başlatma + sahte gecikmesiz gelen yanıt
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  for (final boyut in _boyutlar) {
    final etiket = '${boyut.width.toInt()}x${boyut.height.toInt()}';

    testWidgets('soru ve şıklar görünür, taşma yok ($etiket)', (tester) async {
      final repo = FakeKelimeRepository(sorular: [kelimeSoru(id: 's1')]);
      await _pumpOyun(tester, boyut: boyut, repo: repo);

      expect(find.text('Mutlu kelimesinin eş anlamlısı hangisidir?'), findsOneWidget);
      expect(find.text('Üzgün'), findsOneWidget);
      expect(find.text('Sevinçli'), findsOneWidget);
      expect(find.text('Sessiz'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('doğru cevap: geri bildirim, açıklama ve XP gösterilir ($etiket)', (tester) async {
      final repo = FakeKelimeRepository(sorular: [kelimeSoru(id: 's1')]);
      await _pumpOyun(tester, boyut: boyut, repo: repo);

      await tester.tap(find.text('Sevinçli'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Harika, doğru bildin!'), findsOneWidget);
      expect(find.text('Açıklama metni.'), findsOneWidget);
      expect(find.text('+10 XP kazandın'), findsOneWidget);
      // Tek soruluk oyunda bu son sorudur: düğme "Sonucu gör" olur
      expect(find.text('Sonucu gör'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('yanlış cevap: açıklama, "başka soruyla tekrar" bilgisi ve kaydet düğmesi', (tester) async {
    final repo = FakeKelimeRepository(
      oyunYanitlari: [
        [kelimeSoru(id: 's1')],
        [kelimeSoru(id: 's1'), kelimeSoru(id: 's2', soruMetni: 'Mutlu ile aynı duyguyu hangisi anlatır?')],
      ],
    );
    await _pumpOyun(tester, boyut: const Size(390, 844), repo: repo);

    await tester.tap(find.text('Üzgün'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Bu kez olmadı. Açıklamaya bakalım.'), findsOneWidget);
    expect(find.text('Bu kelimeyi başka bir soruyla tekrar deneyeceğiz.'), findsOneWidget);
    expect(find.text('Bu kelimeyi kaydet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ipucu düğmesi ipucu metnini açar', (tester) async {
    final repo = FakeKelimeRepository(sorular: [kelimeSoru(id: 's1')]);
    await _pumpOyun(tester, boyut: const Size(390, 844), repo: repo);

    await tester.tap(find.text('İpucu göster'));
    await tester.pump();

    expect(find.text('Sevinç duygusuna bak.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('boş içerikte "henüz soru yok" durumu gösterilir', (tester) async {
    final repo = FakeKelimeRepository(sorular: const []);
    await _pumpOyun(tester, boyut: const Size(390, 844), repo: repo);

    expect(find.textContaining('için henüz soru yok.'), findsOneWidget);
    expect(find.text('Geri dön'), findsOneWidget);
  });

  testWidgets('sınıfı olmayan öğrenciye sınıf seçme yolu gösterilir', (tester) async {
    final repo = FakeKelimeRepository()
      ..oyunHatasi = const KelimeException(KelimeHatasi.sinifGerekli, 'Kelime oyunları için önce sınıfını seçmelisin.');
    await _pumpOyun(tester, boyut: const Size(390, 844), repo: repo);

    expect(find.text('Kelime oyunları için önce sınıfını seçmelisin.'), findsOneWidget);
    expect(find.text('Sınıfımı seç'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('soru kullanılamazsa "Sıradaki soruya geç" ile oyun ilerler', (tester) async {
    final repo = FakeKelimeRepository(sorular: [
      kelimeSoru(id: 's1'),
      kelimeSoru(id: 's2', soruMetni: 'İkinci soru metni burada?'),
    ])
      ..cevapYaniti = (istek) async {
        if (istek.soruId == 's1') {
          throw const KelimeException(KelimeHatasi.soruBulunamadi, 'Bu soru artık yok. Sıradaki soruya geçelim.');
        }
        return const KelimeCevapSonucu(dogru: true, dogruIndeks: 1, aciklama: 'a', kazanilanXp: 10, tekrar: false);
      };
    await _pumpOyun(tester, boyut: const Size(390, 844), repo: repo);

    await tester.tap(find.text('Sevinçli'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Sıradaki soruya geç'), findsOneWidget);
    // Düğme kaydırılabilir alanın altında kalabilir; dokunmadan önce görünür yap
    await tester.ensureVisible(find.text('Sıradaki soruya geç'));
    await tester.tap(find.text('Sıradaki soruya geç'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('İkinci soru metni burada?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ağ hatasında hata mesajı ve "Tekrar dene" düğmesi gösterilir', (tester) async {
    final repo = FakeKelimeRepository(sorular: [kelimeSoru(id: 's1')])
      ..cevapYaniti = (_) async => throw const KelimeException(
            KelimeHatasi.baglanti,
            'Cevap kaydedilemedi. İnternet bağlantını kontrol edip tekrar dene.',
          );
    await _pumpOyun(tester, boyut: const Size(390, 844), repo: repo);

    await tester.tap(find.text('Sevinçli'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Cevap kaydedilemedi. İnternet bağlantını kontrol edip tekrar dene.'), findsOneWidget);
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
