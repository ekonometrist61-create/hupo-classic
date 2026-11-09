import 'package:okuma_motoru/turkce_ad.dart';
import 'package:test/test.dart';

// Altın vektörler: her ad için 5 çekim. Yer tutucu/genel adlar; gerçek çocuk adı yok.
void main() {
  const vektorler = <String, List<String>>{
    // ad: [yönelme, belirtme, ilgi, bulunma, ayrılma]
    'Efe': ["Efe'ye", "Efe'yi", "Efe'nin", "Efe'de", "Efe'den"],
    'Ece': ["Ece'ye", "Ece'yi", "Ece'nin", "Ece'de", "Ece'den"],
    'Murat': ["Murat'a", "Murat'ı", "Murat'ın", "Murat'ta", "Murat'tan"],
    'Ali': ["Ali'ye", "Ali'yi", "Ali'nin", "Ali'de", "Ali'den"],
    'Pati': ["Pati'ye", "Pati'yi", "Pati'nin", "Pati'de", "Pati'den"],
    'Deniz': ["Deniz'e", "Deniz'i", "Deniz'in", "Deniz'de", "Deniz'den"],
    'Hupo': ["Hupo'ya", "Hupo'yu", "Hupo'nun", "Hupo'da", "Hupo'dan"],
    'Kemal': ["Kemal'a", "Kemal'ı", "Kemal'ın", "Kemal'da", "Kemal'dan"],
    // Sert ünsüzle biten adlar: bulunma/ayrılma t'ye döner.
    'Cenk': ["Cenk'e", "Cenk'i", "Cenk'in", "Cenk'te", "Cenk'ten"],
    // Ünlüyle biten adlar: yönelme/belirtme y kaynaştırması alır.
    'Ayşe': ["Ayşe'ye", "Ayşe'yi", "Ayşe'nin", "Ayşe'de", "Ayşe'den"],
    // Dörtlü ve ikili uyum, ön ünlüler (ö/ü).
    'Ömer': ["Ömer'e", "Ömer'i", "Ömer'in", "Ömer'de", "Ömer'den"],
    'Ömür': ["Ömür'e", "Ömür'ü", "Ömür'ün", "Ömür'de", "Ömür'den"],
    'Oğuz': ["Oğuz'a", "Oğuz'u", "Oğuz'un", "Oğuz'da", "Oğuz'dan"],
    'Hüseyin': ["Hüseyin'e", "Hüseyin'i", "Hüseyin'in", "Hüseyin'de", "Hüseyin'den"],
    'Mavi Şimşek': [
      "Mavi Şimşek'e",
      "Mavi Şimşek'i",
      "Mavi Şimşek'in",
      "Mavi Şimşek'te",
      "Mavi Şimşek'ten",
    ],
  };

  const haller = [Hal.yonelme, Hal.belirtme, Hal.ilgi, Hal.bulunma, Hal.ayrilma];

  vektorler.forEach((ad, beklenen) {
    test('$ad: 5 hal doğru çekiliyor', () {
      for (var i = 0; i < haller.length; i++) {
        expect(ekle(ad, haller[i]), beklenen[i], reason: '$ad / ${haller[i].name}');
      }
    });
  });

  test('yalın hâl adı değiştirmez', () {
    expect(ekle('Efe', Hal.yalin), 'Efe');
  });

  test('boş ad reddedilir', () {
    expect(() => ekle('  ', Hal.ilgi), throwsArgumentError);
  });

  test('ünlüsüz ad reddedilir', () {
    expect(() => ekle('Pst', Hal.yonelme), throwsArgumentError);
  });

  test('I/İ dönüşümü: İ ve I Türkçe küçük harfe çevrilir', () {
    expect(ekle('İlker', Hal.yonelme), "İlker'e");
    expect(ekle('Irmak', Hal.belirtme), "Irmak'ı");
  });

  test('baştaki ve sondaki boşluklar atılır', () {
    expect(ekle('  Efe ', Hal.yonelme), "Efe'ye");
  });

  // Özellik testi: yer tutucu adlar (gerçek çocuk adı değil). Her son ünlü ve
  // her sert/yumuşak ünsüz için ekin ünlüsü ve ünsüzü bağımsız olarak hesaplanır.
  group('özellik: uyum ve ünsüz kuralları', () {
    const sonUnlular = 'aeıioöuü';
    const kalin = 'aıou';
    const dortlu = {'a': 'ı', 'ı': 'ı', 'e': 'i', 'i': 'i', 'o': 'u', 'u': 'u', 'ö': 'ü', 'ü': 'ü'};
    const sertler = 'fstkçşhp';

    String ikili(String v) => kalin.contains(v) ? 'a' : 'e';

    // Ad: ünsüzle biten (ör. "Kavk") ve ünlüyle biten (ör. "Kava") biçimleri.
    final adlar = <String>[
      for (final v in sonUnlular.split(''))
        for (final c in ['k', 't', 'n', 'l', 'ş', 'ç', 'p', 'z']) 'K$v$c',
      for (final v in sonUnlular.split('')) 'K$v',
    ];

    for (final ad in adlar) {
      test('$ad: ek ünlüleri ve ünsüzleri uyumlu', () {
        final sonHarf = ad[ad.length - 1];
        final sonUnluMu = sonUnlular.contains(sonHarf);
        final sonUnlu = ad.split('').lastWhere(sonUnlular.contains);
        final sert = sertler.contains(sonHarf);

        expect(ekle(ad, Hal.yonelme), '$ad\'${sonUnluMu ? 'y' : ''}${ikili(sonUnlu)}');
        expect(ekle(ad, Hal.belirtme), '$ad\'${sonUnluMu ? 'y' : ''}${dortlu[sonUnlu]}');
        expect(ekle(ad, Hal.ilgi), '$ad\'${sonUnluMu ? 'n' : ''}${dortlu[sonUnlu]}n');
        expect(ekle(ad, Hal.bulunma), '$ad\'${sert ? 't' : 'd'}${ikili(sonUnlu)}');
        expect(ekle(ad, Hal.ayrilma), '$ad\'${sert ? 't' : 'd'}${ikili(sonUnlu)}n');
      });
    }

    test('her çıktıda tek kesme işareti var ve ad aynen korunur', () {
      for (final ad in adlar) {
        for (final hal in Hal.values.where((h) => h != Hal.yalin)) {
          final sonuc = ekle(ad, hal);
          expect(sonuc.split("'").length, 2, reason: '$ad / ${hal.name}');
          expect(sonuc.startsWith(ad), isTrue, reason: '$ad / ${hal.name}');
        }
      }
    });
  });
}
