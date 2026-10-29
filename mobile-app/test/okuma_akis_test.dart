// Okuma Dünyası: akış testleri (sahte depo + ProviderScope). Gerçek Supabase çağrısı YOKTUR.
// Kapsam: kahraman → katalog → okuyucu → sorular → anket → sonuç; kota dolu; çevrimdışı tekrar okuma;
// önbellek; soru ilerlemesi (otomatik geçiş yok); hareket azaltma; büyük yazı; PDF hak denetimi;
// ad gizliliği. Ekran boyutları: 390×844 ve 1024×768.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/okuma_models.dart';
import 'package:ogrenci_hazirlik/providers/app_providers.dart';
import 'package:ogrenci_hazirlik/providers/okuma_providers.dart';
import 'package:ogrenci_hazirlik/providers/okuma_akis.dart' show OkumaPdfSonucu;
import 'package:ogrenci_hazirlik/screens/okuma/okuma_akis_ekrani.dart';
import 'package:ogrenci_hazirlik/screens/okuma/sonuc_ekrani.dart';
import 'package:ogrenci_hazirlik/services/okuma_pdf_hizmeti.dart';
import 'package:ogrenci_hazirlik/services/okuma_repository.dart';
import 'package:ogrenci_hazirlik/settings/app_settings.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tool/screen_previews_test.dart' show loadFonts;
import 'okuma_fake_repository.dart';

const _ad = 'Zeynel'; // bellekte kalması gereken kahraman adı; sunucuya gitmemeli

class _Ortam {
  _Ortam(this.repo, this.prefs, this.pdfIstekleri);

  final FakeOkumaRepository repo;
  final SharedPreferences prefs;
  final List<OkumaPdfIstegi> pdfIstekleri;
}

Future<_Ortam> _ac(
  WidgetTester tester,
  FakeOkumaRepository repo, {
  Size boyut = const Size(390, 844),
  double yaziOlcegi = 1.0,
  bool hareketAzalt = false,
  Map<String, Object> onceki = const {},
  OkumaKatalogSatiri? baslangic,
}) async {
  SharedPreferences.setMockInitialValues(onceki);
  final prefs = await SharedPreferences.getInstance();
  final pdfler = <OkumaPdfIstegi>[];
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = boyut;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        okumaRepositoryProvider.overrideWithValue(repo),
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentUserIdProvider.overrideWithValue('u1'),
        okumaPdfUreticiProvider.overrideWithValue((istek) async => pdfler.add(istek)),
        okumaCikisAkisiProvider.overrideWithValue(const Stream<void>.empty()),
      ],
      child: MaterialApp(
        theme: buildAppTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(yaziOlcegi),
            disableAnimations: hareketAzalt,
          ),
          child: child!,
        ),
        home: OkumaAkisEkrani(baslangicSatiri: baslangic),
      ),
    ),
  );
  await _bekle(tester);
  return _Ortam(repo, prefs, pdfler);
}

Future<void> _bekle(WidgetTester tester, [int ms = 350]) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: ms));
}

/// Ekranda görünene kadar kaydırır, sonra dokunur.
Future<void> _tikla(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 150, scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(f.first);
  await tester.pump();
  await tester.tap(f.first);
  await _bekle(tester);
}

/// Ad alanı alt kısımda olabilir (ListView tembel kurulur): önce görünür kıl.
Future<void> _adYaz(WidgetTester tester, String ad) async {
  final alan = find.byType(TextField);
  if (alan.evaluate().isEmpty) {
    await tester.scrollUntilVisible(alan, 150, scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(alan.first);
  await tester.pump();
  await tester.enterText(alan.first, ad);
  await tester.pump();
}

Future<void> _kahramanSec(WidgetTester tester, {String tur = 'Hayvan Dostlarımız', String ad = _ad}) async {
  await _tikla(tester, find.text(tur));
  await _adYaz(tester, ad);
  await _tikla(tester, find.text('Hikâyeleri gör'));
}

Future<void> _hikayeAc(WidgetTester tester) async {
  await _tikla(tester, find.text('Feneri Kim Yakıyor?'));
  await _bekle(tester, 600);
}

Future<void> _sayfalariOku(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await _tikla(tester, find.text('Sonraki sayfa'));
  }
  await _tikla(tester, find.text('Sorulara geç'));
}

Future<void> _soruCevapla(WidgetTester tester, String harf, {bool bekle = false}) async {
  await _tikla(tester, find.text(harf));
  await _tikla(tester, find.text('Cevapla'));
  if (bekle) await _bekle(tester, 600);
}

/// Fikstürdeki doğru şıklar (sunucu tarafında): s1=C s2=B s3=A s4=C.
const _dogru = ['C', 'B', 'A', 'C'];
const _yanlis = ['A', 'A', 'B', 'A'];

/// 4 soruyu verilen harflerle cevaplar ve "Sonucu gör"e basar.
Future<void> _sorulariCevapla(WidgetTester tester, List<String> harfler) async {
  for (var i = 0; i < 4; i++) {
    await _soruCevapla(tester, harfler[i], bekle: true);
    await _tikla(tester, find.text(i == 3 ? 'Sonucu gör' : 'Sonraki soru'));
  }
}

void main() {
  setUpAll(loadFonts);

  for (final boyut in const [Size(390, 844), Size(1024, 768)]) {
    final etiket = '${boyut.width.toInt()}x${boyut.height.toInt()}';

    testWidgets('tam akış: kahraman → hikâye → okuma → sorular → anket → sonuç ($etiket)', (tester) async {
      final repo = FakeOkumaRepository();
      final o = await _ac(tester, repo, boyut: boyut);

      // Kahraman: cinsiyet sorusu yok, gizlilik notu var.
      expect(find.text('Kahramanın kim olsun?'), findsOneWidget);
      expect(find.textContaining('cinsiyet'), findsNothing);
      await tester.scrollUntilVisible(find.text('Yazdığın adlar yalnızca bu cihazda kalır.'), 150, scrollable: find.byType(Scrollable).first);
      expect(find.text('Yazdığın adlar yalnızca bu cihazda kalır.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _kahramanSec(tester);
      expect(find.text('Hangi hikâyeyi okuyalım?'), findsOneWidget);
      expect(find.text('Feneri Kim Yakıyor?'), findsOneWidget);
      expect(repo.cagrilar.firstWhere((c) => c.$1 == 'okuma_katalog_filtre').$2['p_kahraman_turu'], 'hayvan');
      expect(tester.takeException(), isNull);

      await _hikayeAc(tester);
      expect(find.text('Sayfa 1 / 4'), findsOneWidget);
      // Ad yalnız cihazda çözülen metinde görünür.
      expect(find.textContaining(_ad, findRichText: true), findsWidgets);
      expect(tester.takeException(), isNull);

      await _sayfalariOku(tester);
      expect(find.text('Soru 1 / 4'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Soru 1: yanlış (A), Soru 2-4: sonraki ile ilerle.
      await _soruCevapla(tester, 'A', bekle: true);
      expect(find.text('Bu kez olmadı.'), findsOneWidget);
      expect(find.text('Doğru cevap bu'), findsOneWidget, reason: 'doğru şık cevaptan sonra gösterilir');
      await _tikla(tester, find.text('Sonraki soru'));
      expect(find.text('Soru 2 / 4'), findsOneWidget);
      for (var i = 2; i <= 4; i++) {
        await _soruCevapla(tester, _dogru[i - 1], bekle: true);
        await _tikla(tester, find.text(i == 4 ? 'Sonucu gör' : 'Sonraki soru'));
      }
      expect(find.text('Bu hikâye nasıldı?'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Anket: yanıt yokken "Atla" görünür (puan zorunlu değil); yanıt verilince "Gönder".
      expect(find.text('Atla'), findsOneWidget);
      await _tikla(tester, find.byTooltip('4 yıldız'));
      await _tikla(tester, find.text('Daha komik olsun'));
      await _tikla(tester, find.text('Gönder'));
      await _bekle(tester, 600);

      expect(find.text('Hikâyeyi bitirdin.'), findsOneWidget);
      expect(find.textContaining('+'), findsWidgets, reason: 'sunucunun verdiği XP gösterilir');
      expect(find.textContaining('günlük okuma serisi'), findsOneWidget);
      expect(find.text('Sıradaki hikâye'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Sunucu çağrıları: sıra ve anket kodu.
      final adlar = repo.cagrilar.map((c) => c.$1).toList();
      expect(adlar, containsAllInOrder(['okuma_katalog_filtre', 'okuma_hikaye_getir', 'okuma_oturum_baslat', 'okuma_cevap_kontrol', 'okuma_oturum_bitir', 'okuma_geri_bildirim_gonder', 'okuma_seri_ve_oneri']));
      expect(repo.cagrilar.firstWhere((c) => c.$1 == 'okuma_geri_bildirim_gonder').$2['p_iyilestirme_kodlari'], ['daha_komik']);
      expect(repo.sayac('okuma_cevap_kontrol'), 4);

      // GİZLİLİK: ad hiçbir sunucu parametresinde yok.
      expect(repo.cagrilar.map((c) => c.$2.toString()).join(' ').contains(_ad), isFalse);
      // GİZLİLİK: ad cihaz depolamasında da yok (Kahramanlarım kapalıydı).
      expect(o.prefs.getKeys().map((k) => '$k=${o.prefs.get(k)}').join(' ').contains(_ad), isFalse);
      // Okuduklarım ve son okuma cihaza yazıldı.
      expect(o.prefs.getKeys().any((k) => k.startsWith('okuma_kisisel_okunanlar_')), isTrue);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  }

  testWidgets('kota dolu: sakin "yarın yeni hikâye" ekranı, ödeme/kart isteği yok', (tester) async {
    final repo = FakeOkumaRepository()..getirHatasi = okumaHatasiCevir('KOTA_DOLDU');
    await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester);

    expect(find.text('Bugünkü hikâyeni okudun'), findsOneWidget);
    expect(find.text('Yarın yeni bir hikâye seni bekliyor. Şimdi kısa bir mola verebilirsin.'), findsOneWidget);
    expect(find.text('Tamam'), findsOneWidget);
    expect(find.textContaining('Premium'), findsNothing);
    expect(find.textContaining('kart'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('oturum başlatılırken kota dolarsa da kota ekranı açılır', (tester) async {
    final repo = FakeOkumaRepository()..oturumHatasi = okumaHatasiCevir('KOTA_DOLDU');
    await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester);
    expect(find.text('Bugünkü hikâyeni okudun'), findsOneWidget);
  });

  testWidgets('önbellek: sha256 eşleşince paket tekrar indirilmez', (tester) async {
    final repo = FakeOkumaRepository();
    await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester);
    expect(repo.sayac('okuma_hikaye_getir'), 1);
    expect(find.text('Sayfa 1 / 4'), findsOneWidget);

    // Okuyucudan listeye dön ve aynı hikâyeyi yeniden aç.
    await _tikla(tester, find.byTooltip('Geri'));
    expect(find.text('Hangi hikâyeyi okuyalım?'), findsOneWidget);
    await _hikayeAc(tester);
    expect(find.text('Sayfa 1 / 4'), findsOneWidget);
    expect(repo.sayac('okuma_hikaye_getir'), 1, reason: 'önbellekten açıldı, kota harcanmadı');
    expect(repo.sayac('okuma_oturum_baslat'), 2);
  });

  testWidgets('çevrimdışı tekrar okuma: eski paket cihazdan açılır, sorular için bağlantı istenir', (tester) async {
    final repo = FakeOkumaRepository();
    await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester); // paket önbelleğe yazıldı
    await _tikla(tester, find.byTooltip('Geri'));

    // İnternet kesildi, sürüm de değişti (sha farklı): yine de son indirilen sürüm okunur.
    repo
      ..katalogSatirlari[0] = testSatiri(sha: 'sha-yeni')
      ..getirHatasi = okumaBaglantiHatasi
      ..oturumHatasi = okumaBaglantiHatasi;
    await _hikayeAc(tester);
    expect(find.text('Sayfa 1 / 4'), findsOneWidget);
    expect(find.textContaining('İnternet yok'), findsOneWidget);

    await _sayfalariOku(tester);
    expect(find.textContaining('Sorulara geçmek için internet bağlantısı gerekiyor'), findsOneWidget);
    expect(find.text('Yeniden dene'), findsOneWidget);

    // Bağlantı geri geldi: yeniden dene → sorular açılır.
    repo.oturumHatasi = null;
    await _tikla(tester, find.text('Yeniden dene'));
    expect(find.text('Soru 1 / 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('internet yoksa ve önbellek de yoksa hata + yeniden dene', (tester) async {
    final repo = FakeOkumaRepository()..getirHatasi = okumaBaglantiHatasi;
    await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester);
    expect(find.text('Bağlantı kurulamadı. İnternetini kontrol edip yeniden dene.'), findsOneWidget);
    repo.getirHatasi = null;
    await _tikla(tester, find.text('Yeniden dene'));
    await _bekle(tester, 600);
    expect(find.text('Sayfa 1 / 4'), findsOneWidget);
  });

  testWidgets('soru geçişi: otomatik geçiş yok (WCAG 2.2.1); yalnız "Sonraki soru" ile ilerler', (tester) async {
    final repo = FakeOkumaRepository();
    await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester);
    await _sayfalariOku(tester);

    // Soru 1: doğru C. Açıklama okunsun diye süre geçse de soru değişmez.
    await _soruCevapla(tester, 'C');
    expect(find.text('Doğru!'), findsWidgets);
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Soru 1 / 4'), findsOneWidget, reason: 'otomatik geçiş olmamalı');
    expect(tester.takeException(), isNull);
    await _tikla(tester, find.text('Sonraki soru'));
    expect(find.text('Soru 2 / 4'), findsOneWidget);

    // Soru 2: yanlış. Yanlışta da kendiliğinden geçiş yok.
    await _soruCevapla(tester, 'A');
    expect(find.text('Bu kez olmadı.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Soru 2 / 4'), findsOneWidget, reason: 'yanlışta da otomatik geçiş olmamalı');
    await _tikla(tester, find.text('Sonraki soru'));
    expect(find.text('Soru 3 / 4'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Soru 3 ve 4: son soruda sonuç düğmesi ekranda kalır.
    await _soruCevapla(tester, 'A', bekle: true);
    await _tikla(tester, find.text('Sonraki soru'));
    expect(find.text('Soru 4 / 4'), findsOneWidget);
    await _soruCevapla(tester, 'A', bekle: true);
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Sonucu gör'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('cevap kaydedilemezse hata gösterilir; yeniden denince sonuç gelir', (tester) async {
    final repo = FakeOkumaRepository();
    await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester);
    await _sayfalariOku(tester);

    repo.cevapHatasi = okumaBaglantiHatasi;
    await _tikla(tester, find.text('C'));
    await _tikla(tester, find.text('Cevapla'));
    expect(find.text('Cevabın kaydedilmedi. Yeniden dene.'), findsOneWidget);
    expect(find.text('Doğru!'), findsNothing, reason: 'sunucu onaylamadan doğruluk işareti verilmez');

    repo.cevapHatasi = null;
    await _tikla(tester, find.text('Yeniden dene'));
    await _bekle(tester, 600);
    expect(find.text('Doğru!'), findsWidgets);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('PDF: hak yoksa nazik premium bilgisi, kart isteme yok; hak varsa üretilir, PDF\'te ad yok', (tester) async {
    final repo = FakeOkumaRepository(pdfIzni: false);
    final o = await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester);
    await _sayfalariOku(tester);
    await _sorulariCevapla(tester, _dogru);
    await _tikla(tester, find.text('Atla'));
    await _bekle(tester, 600);

    await _tikla(tester, find.text('Hikâyeyi PDF olarak indir'));
    await _bekle(tester, 600);
    expect(find.text('PDF hakkın bu ay doldu'), findsOneWidget);
    expect(find.text('Bu özellik için velinle devam et. Okuma ve sorular her zaman açık.'), findsOneWidget);
    expect(o.pdfIstekleri, isEmpty);
    await _tikla(tester, find.text('Kapat'));

    repo.pdfIzni = true;
    await _tikla(tester, find.text('Hikâyeyi PDF olarak indir'));
    await _bekle(tester, 600);
    expect(o.pdfIstekleri.length, 1);
    final pdf = o.pdfIstekleri.single;
    expect(pdf.baslik, 'Feneri Kim Yakıyor?');
    // Sayfalar nötr adla çözüldü: çocuğun yazdığı ad PDF'e girmedi.
    final govde = pdf.sayfalar.expand((s) => s).map((c) => c.metin).join(' ');
    expect(govde.contains(_ad), isFalse);
    expect(govde, isNotEmpty);
    // Cevap anahtarı: oturumda öğrenilen doğru şıklar.
    expect(pdf.sorular.every((s) => s.dogru != null), isTrue);
    expect(pdf.dosyaAdi, 'feneri-kim-yakiyor.pdf');
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('Kahramanlarım rafı: yalnız izin verilirse kaydedilir; raftan tek dokunuşla devam', (tester) async {
    final repo = FakeOkumaRepository();
    final o = await _ac(tester, repo);
    expect(find.text('Kahramanlarım'), findsNothing);

    await _tikla(tester, find.text('Hayvan Dostlarımız'));
    await _adYaz(tester, 'Pati');
    // Anahtarı aç: bu cihaza kaydet.
    final kaydetSatiri = find.text('Bu kahramanı bu cihaza kaydet');
    await tester.scrollUntilVisible(kaydetSatiri, 150, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.descendant(of: find.ancestor(of: kaydetSatiri, matching: find.byType(Row)).first, matching: find.byType(Switch)));
    await tester.pump();
    await _tikla(tester, find.text('Hikâyeleri gör'));
    expect(o.prefs.getKeys().any((k) => k.startsWith('okuma_kisisel_kahramanlar_u1')), isTrue);
    // Sunucuya yine ad gitmedi.
    expect(repo.cagrilar.map((c) => c.$2.toString()).join(' ').contains('Pati'), isFalse);
  });

  testWidgets('raftaki kahraman açılışta görünür ve tek dokunuşla hikâyelere geçer', (tester) async {
    final repo = FakeOkumaRepository();
    await _ac(tester, repo, onceki: {
      'okuma_kisisel_kahramanlar_u1': '[{"tur":"hayvan","ad":"Pati"}]',
    });
    expect(find.text('Kahramanlarım'), findsOneWidget);
    await _tikla(tester, find.text('Pati'));
    expect(find.text('Hangi hikâyeyi okuyalım?'), findsOneWidget);
    expect(repo.cagrilar.first.$2['p_kahraman_turu'], 'hayvan');
  });

  testWidgets('başka hesabın rafı görünmez', (tester) async {
    await _ac(tester, FakeOkumaRepository(), onceki: {
      'okuma_kisisel_kahramanlar_baska': '[{"tur":"hayvan","ad":"Gizli"}]',
    });
    expect(find.text('Kahramanlarım'), findsNothing);
    expect(find.text('Gizli'), findsNothing);
  });

  testWidgets('büyük yazı (2.0) ve hareket azaltma: taşma yok, tüm adımlar çalışır', (tester) async {
    final repo = FakeOkumaRepository();
    await _ac(tester, repo, yaziOlcegi: 2.0, hareketAzalt: true);
    expect(tester.takeException(), isNull);
    await _kahramanSec(tester);
    expect(tester.takeException(), isNull);
    await _hikayeAc(tester);
    expect(tester.takeException(), isNull);
    await _sayfalariOku(tester);
    expect(tester.takeException(), isNull);
    for (var i = 0; i < 4; i++) {
      await _soruCevapla(tester, _dogru[i], bekle: true);
      expect(tester.takeException(), isNull, reason: 'soru ${i + 1}');
      await _tikla(tester, find.text(i == 3 ? 'Sonucu gör' : 'Sonraki soru'));
    }
    expect(tester.takeException(), isNull);
    await _tikla(tester, find.text('Atla'));
    await _bekle(tester, 600);
    // Hepsi doğru: hareket azaltmada kutlama animasyonu (Lottie) oynamaz, metin yine görünür.
    expect(find.text('Hepsini doğru bildin!'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Harika bir okuma oldu.'), 150, scrollable: find.byType(Scrollable).first);
    expect(find.text('Harika bir okuma oldu.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('sonuç ekranı kota doluyken "yarın yeni hikâye" der ve yeni hikâye önermez', (tester) async {
    final repo = FakeOkumaRepository(kotaDolu: true);
    await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester);
    await _sayfalariOku(tester);
    await _sorulariCevapla(tester, _yanlis);
    await _tikla(tester, find.text('Atla'));
    await _bekle(tester, 600);
    expect(find.text('Bugünkü hikâyeni okudun. Yarın yeni bir hikâye seni bekliyor.'), findsOneWidget);
    expect(find.text('Sıradaki hikâye'), findsNothing);
    expect(find.text('Tamam'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sonuç alınamazsa hata + yeniden dene; sunucu idempotent', (tester) async {
    final repo = FakeOkumaRepository()..bitirHatasi = okumaBaglantiHatasi;
    await _ac(tester, repo);
    await _kahramanSec(tester);
    await _hikayeAc(tester);
    await _sayfalariOku(tester);
    await _sorulariCevapla(tester, _dogru);
    await _tikla(tester, find.text('Atla'));
    await _bekle(tester, 600);
    expect(find.text('Bağlantı kurulamadı. İnternetini kontrol edip yeniden dene.'), findsOneWidget);
    repo.bitirHatasi = null;
    await _tikla(tester, find.text('Yeniden dene'));
    await _bekle(tester, 600);
    expect(find.text('Hepsini doğru bildin!'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('Öğren kartından gelen öneri kahraman seçildikten sonra doğrudan açılır', (tester) async {
    final repo = FakeOkumaRepository();
    await _ac(tester, repo, baslangic: testSatiri());
    await _kahramanSec(tester);
    await _bekle(tester, 600);
    expect(find.text('Sayfa 1 / 4'), findsOneWidget);
    expect(find.text('Hangi hikâyeyi okuyalım?'), findsNothing);
  });

  testWidgets('bu kahramana uygun hikâye yoksa nazik boş durum', (tester) async {
    final repo = FakeOkumaRepository(katalogSatirlari: []);
    await _ac(tester, repo);
    await _kahramanSec(tester);
    expect(find.text('Hikâyeler hazırlanıyor'), findsOneWidget);
    expect(find.text('Kahramanı değiştir'), findsOneWidget);
  });

  testWidgets('katalog yüklenemezse hata ve yeniden dene', (tester) async {
    final repo = FakeOkumaRepository()..katalogHatasi = okumaBaglantiHatasi;
    await _ac(tester, repo);
    await _kahramanSec(tester);
    expect(find.text('Bağlantı kurulamadı. İnternetini kontrol edip yeniden dene.'), findsOneWidget);
    repo.katalogHatasi = null;
    await _tikla(tester, find.text('Yeniden dene'));
    expect(find.text('Feneri Kim Yakıyor?'), findsOneWidget);
  });

  testWidgets('3+ gün okunmadıysa hikâye listesinde nazik geri dönüş mesajı çıkar', (tester) async {
    final repo = FakeOkumaRepository();
    final eski = DateTime.now().subtract(const Duration(days: 5)).toIso8601String();
    await _ac(tester, repo, onceki: {'okuma_kisisel_son_okuma_u1': eski});
    await _kahramanSec(tester);
    expect(find.textContaining('gündür yeni bir hikâye okumadın. Seni bekliyoruz!'), findsOneWidget);
  });

  testWidgets('okuma modu Sade seçilince cihaza yazılır ve oturuma sade gider', (tester) async {
    final repo = FakeOkumaRepository();
    final o = await _ac(tester, repo, onceki: {'okuma_modu': 'sade'});
    await _kahramanSec(tester);
    await _hikayeAc(tester);
    expect(o.prefs.getString('okuma_modu'), 'sade');
    expect(repo.cagrilar.firstWhere((c) => c.$1 == 'okuma_oturum_baslat').$2['p_okuma_modu'], 'sade');
  });

  testWidgets('yol arkadaşı adı sunucuya gitmez, yalnız "var mı" gider', (tester) async {
    final repo = FakeOkumaRepository();
    await _ac(tester, repo);
    await _tikla(tester, find.text('Hayvan Dostlarımız'));
    await _adYaz(tester, 'Pati');
    await tester.scrollUntilVisible(find.text('Yol arkadaşı ekle (isteğe bağlı)'), 150, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'Bulut');
    await tester.pump();
    await _tikla(tester, find.text('Hikâyeleri gör'));
    await _hikayeAc(tester);
    final oturum = repo.cagrilar.firstWhere((c) => c.$1 == 'okuma_oturum_baslat').$2;
    expect(oturum['p_yoldas_var'], isTrue);
    expect(repo.cagrilar.map((c) => c.$2.toString()).join(' ').contains('Bulut'), isFalse);
    expect(repo.cagrilar.map((c) => c.$2.toString()).join(' ').contains('Pati'), isFalse);
  });

  // Sonuç ekranı: kısa telefon + sistem yazı ölçeği 2.0 → taşma yok, başlık ve ana eylem görünür.
  for (final boyut in const [Size(320, 568), Size(360, 640)]) {
    for (final hepsiDogru in const [true, false]) {
      testWidgets(
        'sonuç ekranı ${boyut.width.toInt()}x${boyut.height.toInt()} yazı 2.0 (${hepsiDogru ? 'hepsi doğru' : 'karışık'}): taşma yok, başlık görünür',
        (tester) async {
          tester.view.devicePixelRatio = 1.0;
          tester.view.physicalSize = boyut;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            MaterialApp(
              theme: buildAppTheme(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2.0), disableAnimations: true),
                child: child!,
              ),
              home: SonucEkrani(
                sonuc: OkumaSonuc(
                  soruSayisi: 4,
                  dogruSayisi: hepsiDogru ? 4 : 2,
                  dogruOrani: hepsiDogru ? 100 : 50,
                  kazanilanXp: 20,
                  seri: const OkumaSeri(seriSayisi: 3),
                ),
                onYeni: () {},
                onKahraman: () {},
                onPdf: () async => OkumaPdfSonucu.hazir,
                onKapat: () {},
                oneri: testSatiri(),
                onOneri: () {},
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull);
          expect(find.text(hepsiDogru ? 'Hepsini doğru bildin!' : 'Hikâyeyi bitirdin.'), findsOneWidget);
          final baslik = find.text(hepsiDogru ? 'Hepsini doğru bildin!' : 'Hikâyeyi bitirdin.');
          final alan = tester.getRect(find.byType(Scaffold));
          final liste = tester.getRect(find.byType(ListView));
          // Kaydırmadan, ilk ekranda başlığın tamamı kaydırılan alanın içinde olmalı (eskiden alt kısmı kesiliyordu).
          expect(tester.getRect(baslik).bottom, lessThanOrEqualTo(liste.bottom), reason: 'başlık ilk ekranda tam görünür');
          expect(tester.getRect(baslik).top, greaterThanOrEqualTo(alan.top), reason: 'başlık ekranın üstünden taşmaz');
          expect(tester.getRect(baslik).left, greaterThanOrEqualTo(0));
          expect(tester.getRect(baslik).right, lessThanOrEqualTo(boyut.width));
          // Ana eylem ve ikincil eylemler alt alanda, ekranın içinde kalır.
          expect(find.text('Yeni hikâye seç'), findsOneWidget);
          expect(tester.getRect(find.text('Yeni hikâye seç')).bottom, lessThanOrEqualTo(boyut.height));
        },
      );
    }
  }
}
