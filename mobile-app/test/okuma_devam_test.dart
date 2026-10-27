// Yarım kalan hikâye kaydı (yalnız cihazda): yazılır, okunur, aynı hikâye bitince silinir,
// başka bir hikâye bitince kalır.

import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/okuma_cihaz_deposu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'okuma_fake_repository.dart';

void main() {
  late OkumaCihazDeposu depo;
  final simdi = DateTime(2026, 10, 24, 10);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    depo = OkumaCihazDeposu(prefs, kullaniciId: 'u1');
  });

  test('devamYaz ile yazılan kayıt devam() ile geri okunur ve oran doğru hesaplanır', () async {
    await depo.devamYaz(testSatiri(), sayfa: 1, toplam: 4, simdi: simdi);
    final d = depo.devam();
    expect(d, isNotNull);
    expect(d!.satir.hikayeId, kTestHikayeId);
    expect(d.sayfa, 1);
    expect(d.toplam, 4);
    expect(d.oran, closeTo(0.5, 1e-9));
  });

  test('toplam sayfa bilinmiyorsa oran 0 olur', () async {
    await depo.devamYaz(testSatiri(), sayfa: 0, toplam: 0, simdi: simdi);
    expect(depo.devam()!.oran, 0);
  });

  test('aynı hikâye bitince devam kaydı silinir', () async {
    await depo.devamYaz(testSatiri(), sayfa: 2, toplam: 4, simdi: simdi);
    await depo.okunduYaz(testSatiri(), simdi: simdi);
    expect(depo.devam(), isNull);
  });

  test('başka bir hikâye bitince devam kaydı korunur', () async {
    await depo.devamYaz(testSatiri(), sayfa: 2, toplam: 4, simdi: simdi);
    await depo.okunduYaz(testSatiri(id: 'baska-hikaye'), simdi: simdi);
    expect(depo.devam(), isNotNull);
    expect(depo.devam()!.satir.hikayeId, kTestHikayeId);
  });

  test('bozuk devam kaydı sessizce yok sayılır', () async {
    SharedPreferences.setMockInitialValues({'okuma_kisisel_devam_u1': '{bozuk'});
    final prefs = await SharedPreferences.getInstance();
    final bozukDepo = OkumaCihazDeposu(prefs, kullaniciId: 'u1');
    expect(bozukDepo.devam(), isNull);
  });
}
