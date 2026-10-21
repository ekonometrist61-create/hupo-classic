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
}
