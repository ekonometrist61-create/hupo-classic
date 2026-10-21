import 'package:test/test.dart';
import 'package:okuma_motoru/okuma_motoru.dart' show Cikti, Stil;
import 'package:okuma_motoru/gosterim_kurallari.dart';

Cikti n(String m) => Cikti(m, Stil.normal);
Cikti k(String m) => Cikti(m, Stil.kelime);
Cikti d(String m) => Cikti(m, Stil.deyim);
Cikti o(String m) => Cikti(m, Stil.onemli);

void main() {
  test('bütçe tablosu: sınıf ve moda göre', () {
    expect(sayfaButcesi(4, sade: false).vurgu, 3);
    expect(sayfaButcesi(4, sade: false).kelime, 2);
    expect(sayfaButcesi(4, sade: false).cikartma, 2);
    expect(sayfaButcesi(6, sade: false).vurgu, 2);
    expect(sayfaButcesi(6, sade: false).cikartma, 1);
    expect(sayfaButcesi(8, sade: false).cikartma, 0);
    expect(sayfaButcesi(4, sade: true).vurgu, 1);
    expect(sayfaButcesi(4, sade: true).cikartma, 0);
  });

  test('aynı cümlede tek vurgu: yüksek öncelikli kalır', () {
    final s = hikayeSecimi([
      [n('Ayşe '), o('çok'), n(' '), k('parlak'), n(' bir gün gördü.')],
    ], sinif: 4, sade: false);
    expect(s.single.vurgu, {3});
  });

  test('aynı kelime hikâyede yalnız ilk geçtiği yerde vurgulanır', () {
    final s = hikayeSecimi([
      [k('parlak'), n(' ışık vardı.')],
      [n('Yine '), k('parlak'), n(' bir sabahtı.')],
    ], sinif: 4, sade: false);
    expect(s[0].vurgu, {0});
    expect(s[1].vurgu, isEmpty);
  });

  test('sayfa başına en çok 2 kelime ve 3 vurgu; öncelik kelime > deyim > önemli', () {
    final s = hikayeSecimi([
      [k('a1'), n(' x. '), k('b2'), n(' y. '), k('c3'), n(' z. '), d('el ele'), n(' w. '), o('önemli'), n(' v.')],
    ], sinif: 4, sade: false);
    // k:2 sınırı, toplam 3: iki kelime + deyim; önemli yer dışarıda.
    expect(s.single.vurgu, {0, 2, 6});
  });

  test('7. sınıf: 2 vurgu, 1 kelime, çıkartma yok', () {
    final s = hikayeSecimi([
      [k('a1'), n(' x. '), k('b2'), n(' y. '), d('el ele'), n(' w. '), const Cikti('x', Stil.isaret, ikonId: 'sun')],
    ], sinif: 7, sade: false);
    expect(s.single.vurgu.length, 2);
    expect(s.single.cikartma, isEmpty);
  });

  test('Sade mod: tek vurgu, çıkartma yok', () {
    final s = hikayeSecimi([
      [k('a1'), n(' x. '), d('el ele'), n(' y.'), const Cikti('x', Stil.isaret, ikonId: 'sun')],
    ], sinif: 4, sade: true);
    expect(s.single.vurgu, {0});
    expect(s.single.cikartma, isEmpty);
  });

  test('ikon kimliği olmayan çıkartma sayılmaz; sınır 2', () {
    final s = hikayeSecimi([
      [
        const Cikti('x', Stil.isaret),
        const Cikti('x', Stil.isaret, ikonId: 'sun'),
        const Cikti('x', Stil.isaret, ikonId: 'star'),
        const Cikti('x', Stil.isaret, ikonId: 'heart'),
      ],
    ], sinif: 4, sade: false);
    expect(s.single.cikartma, {1, 2});
  });
}

