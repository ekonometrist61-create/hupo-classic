import 'dart:convert';
import 'dart:io';

import 'package:okuma_motoru/hikaye_cozucu.dart';
import 'package:okuma_motoru/paket.dart';
import 'package:test/test.dart';

// Fikstürler: atolye/cikti/feneri-kim-yakiyor.paket.json (derleyici çıktısı) ve örnek sözlük.
// Derleyici değişirse fikstürü yeniden kopyalayın.
String duz(List<Cikti> c) => c.map((x) => x.metin).join();

void main() {
  final paket = jsonDecode(File('test/fixtures/feneri-kim-yakiyor.paket.json').readAsStringSync())
      as Map<String, dynamic>;
  final sozluk = jsonDecode(File('test/fixtures/sozluk.ornek.json').readAsStringSync())
      as Map<String, dynamic>;
  final yuvalar = yuvalarFromSozluk(sozluk);
  final hikaye = hikayeFromPaket(paket, yuvalar);

  test('paket 4 omurga sayfasıyla okunur', () {
    expect(hikaye.sayfalar.length, 4);
    expect(hikaye.izinliTurler, containsAll(['hayvan', 'hayali', 'ben']));
  });

  test('hayvan kahraman: ad, hareket sahnesi ve yol arkadaşı birlikte çözülür', () {
    final s = sayfalariCoz(
      hikaye,
      const Baglam(
        kahramanAdi: 'Pati',
        kahramanTuru: 'hayvan',
        sinif: 4,
        yoldasAdi: 'Ali',
        degerler: ['D20'],
      ),
    );
    final ilk = duz(s[0]);
    expect(ilk, contains('Pati sahilde bunu fark etti.'));
    expect(ilk, contains('Patileriyle kumu ezerek fenerin kapısına yürüdü.'));
    expect(duz(s[1]), contains("Pati yardım etmek istedi ve Ali'ye seslendi."));
    expect(duz(s[1]), contains('Fenerin kırık camını temizleyip'));
  });

  test('yol arkadaşı yoksa yedek metin kullanılır', () {
    final s = sayfalariCoz(
      hikaye,
      const Baglam(kahramanAdi: 'Pati', kahramanTuru: 'hayvan', sinif: 4),
    );
    expect(duz(s[1]), contains('bir dostuna seslendi.'));
  });

  test('hayalî kahraman kendi hareket varyantını alır', () {
    final s = sayfalariCoz(
      hikaye,
      const Baglam(kahramanAdi: 'Işık Muhafızı', kahramanTuru: 'hayali', sinif: 5),
    );
    expect(duz(s[0]), contains('Parlayan izler bırakarak'));
  });

  test('sınıfa uygun sözcük seçilir; görülen sözcük tekrarlanmaz', () {
    final yeni = sayfalariCoz(
      hikaye,
      const Baglam(kahramanAdi: 'Efe', kahramanTuru: 'ben', sinif: 4),
    );
    expect(duz(yeni[2]), contains('Mekanizmanın içinde parlak bir anahtar'));

    final gorulmus = sayfalariCoz(
      hikaye,
      const Baglam(kahramanAdi: 'Efe', kahramanTuru: 'ben', sinif: 4, gorulen: {'parlak'}),
    );
    expect(duz(gorulmus[2]), contains('Mekanizmanın içinde ışıltılı bir anahtar'));
  });

  test('stiller paket sonrası da korunur', () {
    final s = sayfalariCoz(
      hikaye,
      const Baglam(kahramanAdi: 'Efe', kahramanTuru: 'ben', sinif: 4),
    );
    expect(s[0].any((c) => c.stil == Stil.isaret), isFalse);
    expect(s[3].any((c) => c.stil == Stil.atasozu), isTrue);
    expect(s[2].any((c) => c.stil == Stil.kelime), isTrue);
  });

  test('desteklenmeyen paket sürümü reddedilir', () {
    final bozuk = Map<String, dynamic>.from(paket)..['paket_surumu'] = 2;
    expect(() => hikayeFromPaket(bozuk, yuvalar), throwsA(isA<HikayeHatasi>()));
  });
}
