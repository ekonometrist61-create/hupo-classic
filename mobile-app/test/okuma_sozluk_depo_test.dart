import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/okuma_cihaz_deposu.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  OkumaSozlukKaydi kayit(String metin, {String anlam = 'anlam', DateTime? at}) =>
      OkumaSozlukKaydi(metin: metin, anlam: anlam, at: at ?? DateTime(2026, 10, 21));

  test('Sözlüğüm başlangıçta boş; kayıt eklenince bulunur', () async {
    SharedPreferences.setMockInitialValues({});
    final depo = OkumaCihazDeposu(await SharedPreferences.getInstance(), kullaniciId: 'a');
    expect(depo.sozlugum(), isEmpty);
    expect(depo.sozlugumde('Sabırla koruk helva olur.'), isFalse);

    await depo.sozlugeEkle(kayit('Sabırla koruk helva olur.', anlam: 'Acele etmeden olur.'));
    expect(depo.sozlugumde('Sabırla koruk helva olur.'), isTrue);
    expect(depo.sozlugum().single.anlam, 'Acele etmeden olur.');
  });

  test('aynı metin tekrar eklenmez; en yeni kayıt başa gelir', () async {
    SharedPreferences.setMockInitialValues({});
    final depo = OkumaCihazDeposu(await SharedPreferences.getInstance(), kullaniciId: 'a');
    await depo.sozlugeEkle(kayit('Bir elin nesi var.', anlam: 'eski'));
    await depo.sozlugeEkle(kayit('Damlaya damlaya göl olur.'));
    await depo.sozlugeEkle(kayit('Bir elin nesi var.', anlam: 'yeni'));

    final liste = depo.sozlugum();
    expect(liste.map((k) => k.metin), ['Bir elin nesi var.', 'Damlaya damlaya göl olur.']);
    expect(liste.first.anlam, 'yeni');
  });

  test('raf en çok $kSozlugumSiniri kayıt tutar; en eski düşer', () async {
    SharedPreferences.setMockInitialValues({});
    final depo = OkumaCihazDeposu(await SharedPreferences.getInstance(), kullaniciId: 'a');
    for (var i = 0; i < kSozlugumSiniri + 3; i++) {
      await depo.sozlugeEkle(kayit('söz $i'));
    }
    final liste = depo.sozlugum();
    expect(liste.length, kSozlugumSiniri);
    expect(depo.sozlugumde('söz 0'), isFalse);
    expect(depo.sozlugumde('söz ${kSozlugumSiniri + 2}'), isTrue);
  });

  test('raf hesap anahtarlıdır: başka hesap göremez', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await OkumaCihazDeposu(prefs, kullaniciId: 'a').sozlugeEkle(kayit('Sabır.'));
    final digeri = OkumaCihazDeposu(prefs, kullaniciId: 'b');
    expect(digeri.sozlugum(), isEmpty);
  });

  test('bozuk kayıt sessizce boş liste döner', () async {
    SharedPreferences.setMockInitialValues({'okuma_kisisel_sozlugum_a': '{bozuk'});
    final depo = OkumaCihazDeposu(await SharedPreferences.getInstance(), kullaniciId: 'a');
    expect(depo.sozlugum(), isEmpty);
  });
}
