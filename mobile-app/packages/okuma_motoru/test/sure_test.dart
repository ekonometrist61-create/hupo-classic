import 'package:okuma_motoru/okuma_motoru.dart'
    show Cikti, Stil, okumaDakikasi, okumaHizi;
import 'package:test/test.dart';

List<List<Cikti>> _sayfa(int kelime, {Stil stil = Stil.normal}) => [
      [Cikti(List.filled(kelime, 'söz').join(' '), stil)],
    ];

void main() {
  test('hız tablosu: sınıfa göre, aralık dışı en yakın uca sıkışır', () {
    expect(okumaHizi(1), 60);
    expect(okumaHizi(2), 60);
    expect(okumaHizi(3), 75);
    expect(okumaHizi(4), 90);
    expect(okumaHizi(5), 105);
    expect(okumaHizi(6), 115);
    expect(okumaHizi(7), 125);
    expect(okumaHizi(8), 135);
    expect(okumaHizi(12), 135);
  });

  test('süre yukarı yuvarlanır: 91 kelime, 4. sınıf (90/dk) → 2 dk', () {
    expect(okumaDakikasi(_sayfa(91), 4), 2);
  });

  test('tam bölünen sayı tam dakika verir: 90 kelime, 4. sınıf → 1 dk', () {
    expect(okumaDakikasi(_sayfa(90), 4), 1);
  });

  test('en az 1 dakika: çok kısa hikâye bile 1 dk gösterir', () {
    expect(okumaDakikasi(_sayfa(3), 8), 1);
  });

  test('çıkartmalar sayılmaz', () {
    final sayfalar = [
      [
        Cikti('bir iki üç', Stil.normal),
        Cikti('', Stil.isaret, ikonId: 'star')
      ],
    ];
    expect(okumaDakikasi(sayfalar, 2), 1);
    expect(
        okumaDakikasi([
          [Cikti('bir iki üç', Stil.normal)]
        ], 2),
        1);
  });

  test('sayfalar toplanır: iki sayfa 60 + 60 kelime, 2. sınıf (60/dk) → 2 dk',
      () {
    final sayfalar = [
      [Cikti(List.filled(60, 'söz').join(' '), Stil.normal)],
      [Cikti(List.filled(60, 'söz').join(' '), Stil.kelime)],
    ];
    expect(okumaDakikasi(sayfalar, 2), 2);
  });
}
