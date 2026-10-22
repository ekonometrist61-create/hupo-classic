import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/kullanim_suresi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime saat;
  late List<List<Map<String, dynamic>>> gonderilen;
  late bool baglantiVar;
  var anahtarNo = 0;

  KullanimSuresi yap() {
    saat = DateTime.utc(2026, 10, 22, 10);
    gonderilen = [];
    baglantiVar = true;
    anahtarNo = 0;
    return KullanimSuresi(
      gonderici: (olaylar) async {
        if (!baglantiVar) return false;
        gonderilen.add(olaylar);
        return true;
      },
      rolBulucu: () => 'ogrenci',
      simdi: () => saat,
      anahtarUretici: () => 'oturum_anahtari_${++anahtarNo}_xxxxxxxx',
      yuzey: 'mobil',
    );
  }

  void gec(int sn) => saat = saat.add(Duration(seconds: sn));

  test('ekran süresi ekran değişince kapanır ve saniye olarak hesaplanır', () {
    final k = yap();
    k.ekranDegis('/ana');
    gec(42);
    k.ekranDegis('/profil');
    gec(7);
    k.ekranDegis('/ana');
    expect(k.bekleyenler.length, 2);
    expect(k.bekleyenler[0]['ekran'], '/ana');
    expect(k.bekleyenler[0]['sure_sn'], 42);
    expect(k.bekleyenler[1]['ekran'], '/profil');
    expect(k.bekleyenler[1]['sure_sn'], 7);
    expect(k.bekleyenler[0]['rol'], 'ogrenci');
    expect(k.bekleyenler[0]['yuzey'], 'mobil');
    expect(k.bekleyenler[0]['oturum_anahtari'], k.bekleyenler[1]['oturum_anahtari']);
  });

  test('1 saniyeden kısa süre kaydedilmez, aynı ekran tekrarında sayaç sıfırlanmaz', () {
    final k = yap();
    k.ekranDegis('/ana');
    saat = saat.add(const Duration(milliseconds: 300));
    k.ekranDegis('/baska');
    expect(k.kuyrukUzunlugu, 0);
    gec(5);
    k.ekranDegis('/baska');
    gec(5);
    k.ekranDegis('/ana');
    expect(k.bekleyenler.single['sure_sn'], 10);
  });

  test('arka plana gidince süre kapanır, boşta süre sayılmaz, dönüşte yeni oturum', () async {
    final k = yap();
    k.ekranDegis('/ana');
    gec(20);
    k.arkaPlanDurumu(false);
    await Future<void>.delayed(Duration.zero);
    expect(gonderilen.single.single['sure_sn'], 20);
    final ilkOturum = gonderilen.single.single['oturum_anahtari'];
    gec(3600); // arka planda geçen süre
    k.arkaPlanDurumu(true);
    gec(15);
    k.ekranDegis('/profil');
    expect(k.bekleyenler.single['ekran'], '/ana');
    expect(k.bekleyenler.single['sure_sn'], 15);
    expect(k.bekleyenler.single['oturum_anahtari'], isNot(ilkOturum));
  });

  test('çevrimdışı: kuyrukta kalır, bağlantı gelince gönderilir; sunucu reddi grubu düşürür', () async {
    final k = yap();
    baglantiVar = false;
    k.ekranDegis('/a');
    gec(5);
    k.ekranDegis('/b');
    await k.gonder();
    expect(k.kuyrukUzunlugu, 1);
    baglantiVar = true;
    await k.gonder();
    expect(k.kuyrukUzunlugu, 0);
    expect(gonderilen.length, 1);
  });

  test('kuyruk en çok 200 olay tutar (en eski düşer)', () {
    final k = yap();
    baglantiVar = false;
    for (var i = 0; i < 260; i++) {
      k.ekranDegis('/e$i');
      gec(2);
    }
    k.ekranDegis('/son');
    expect(k.kuyrukUzunlugu, kullanimKuyrukLimiti);
    expect(k.bekleyenler.last['ekran'], '/e259');
    expect(k.bekleyenler.first['ekran'], '/e60');
  });

  test('gönderim 50\'şerli gruplarla yapılır', () async {
    final k = yap();
    for (var i = 0; i < 120; i++) {
      k.ekranDegis('/e$i');
      gec(2);
    }
    k.ekranDegis('/son');
    await k.gonder();
    expect(gonderilen.map((g) => g.length).toList(), [50, 50, 20]);
  });

  test('ekran adı: sorgu atılır, kimlikler maskelenir, 60 karakterle sınırlanır', () {
    expect(kullanimEkranAdi('/okuma/hikaye?id=5&ad=Ali'), '/okuma/hikaye');
    expect(kullanimEkranAdi('/cocuk/123/rapor'), '/cocuk/:id/rapor');
    expect(kullanimEkranAdi('/x/3f2b8c1e-1111-4222-8333-444455556666'), '/x/:id');
    expect(kullanimEkranAdi('Ali ders'), 'Ali_ders');
    expect(kullanimEkranAdi(null), 'bilinmeyen');
    expect(kullanimEkranAdi('/${'a' * 100}').length, 60);
  });

  test('oturum anahtarı 24 karakter ve sunucu desenine uyar', () {
    final a = kullanimOturumAnahtari();
    expect(RegExp(r'^[A-Za-z0-9_-]{16,64}$').hasMatch(a), isTrue);
    expect(a, isNot(kullanimOturumAnahtari()));
  });

  test('geçersiz rol ziyaretçiye düşer', () {
    final k = KullanimSuresi(
      gonderici: (_) async => true,
      rolBulucu: () => 'cocuk-adi',
      simdi: () => saat,
      yuzey: 'flutter_web',
    );
    saat = DateTime.utc(2026, 1, 1);
    k.ekranDegis('/a');
    saat = saat.add(const Duration(seconds: 3));
    k.ekranDegis('/b');
    expect(k.bekleyenler.single['rol'], 'ziyaretci');
    expect(k.bekleyenler.single['yuzey'], 'flutter_web');
  });

  testWidgets('NavigatorObserver rota adını bildirir', (tester) async {
    final k = yap();
    final obs = KullanimNavigatorObserver(() => k);
    await tester.pumpWidget(WidgetsApp(
      color: const Color(0xFF000000),
      navigatorObservers: [obs],
      onGenerateRoute: (s) => PageRouteBuilder<void>(
        settings: s,
        pageBuilder: (_, __, ___) => const SizedBox(),
      ),
      initialRoute: '/',
    ));
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.pushNamed('/ayarlar');
    await tester.pumpAndSettle();
    expect(k.aktifEkran, '/ayarlar');
    nav.pop();
    await tester.pumpAndSettle();
    expect(k.aktifEkran, 'kok');
  });
}