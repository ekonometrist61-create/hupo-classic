// Sunucu sözlüğü (okuma_sozluk_getir) paket sözlüğünün üstüne yalnız onaylı adaylarla konur.
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/services/okuma_sozluk.dart';
import 'package:okuma_motoru/okuma_motoru.dart';

void main() {
  const temel = OkumaSozluk(
    yuvalar: {
      'y1': [YuvaAdayi('gizemli', 4, 5)],
    },
    anlamlar: {'gizemli': 'paket anlamı'},
  );

  test('sunucu yanıtı yoksa paket sözlüğü aynen kalır', () {
    expect(okumaSozlugunuSunucuylaBirlestir(temel, null), same(temel));
  });

  test('sunucu yuva listesi boşsa paket sözlüğü aynen kalır', () {
    expect(okumaSozlugunuSunucuylaBirlestir(temel, {'yuvalar': <Object>[]}), same(temel));
  });

  test('yalnız onaylı adaylar alınır ve anlamı sunucudan gelir', () {
    final sonuc = okumaSozlugunuSunucuylaBirlestir(temel, {
      'yuvalar': [
        {
          'yuva': 'y1',
          'tur': 'kelime',
          'adaylar': [
            {'id': 'a', 'yazim': 'sunucu', 'anlam': 'sunucu anlamı', 'sinif_alt': 4, 'sinif_ust': 5, 'onayli': true},
            {'id': 'b', 'yazim': 'taslak', 'anlam': 'taslak anlamı', 'sinif_alt': 4, 'sinif_ust': 5, 'onayli': false},
          ],
        },
      ],
    });
    expect(sonuc.yuvalar['y1']!.map((a) => a.metin), ['sunucu']);
    expect(sonuc.anlamlar['sunucu'], 'sunucu anlamı');
    expect(sonuc.anlamlar.containsKey('taslak'), isFalse);
    expect(sonuc.anlamlar['gizemli'], 'paket anlamı');
  });

  test('onaylı aday yoksa o yuvanın paket adayları korunur', () {
    final sonuc = okumaSozlugunuSunucuylaBirlestir(temel, {
      'yuvalar': [
        {
          'yuva': 'y1',
          'adaylar': [
            {'yazim': 'x', 'anlam': 'x anlamı', 'sinif_alt': 4, 'sinif_ust': 5, 'onayli': false},
          ],
        },
      ],
    });
    expect(sonuc.yuvalar['y1']!.map((a) => a.metin), ['gizemli']);
  });

  test('bozuk kayıtlar atlanır, geçerli olanlar işlenir', () {
    final sonuc = okumaSozlugunuSunucuylaBirlestir(temel, {
      'yuvalar': [
        'bozuk',
        {'yuva': 'y2', 'adaylar': 'liste değil'},
        {
          'yuva': 'y3',
          'adaylar': [
            {'yazim': 5, 'anlam': 'sayı', 'sinif_alt': 4, 'sinif_ust': 5, 'onayli': true},
            {'yazim': 'iyi', 'anlam': 'iyi anlamı', 'sinif_alt': '4', 'sinif_ust': 5, 'onayli': true},
            {'yazim': 'tamam', 'anlam': 'tamam anlamı', 'sinif_alt': 4, 'sinif_ust': 5, 'onayli': true},
          ],
        },
      ],
    });
    expect(sonuc.yuvalar.containsKey('y2'), isFalse);
    expect(sonuc.yuvalar['y3']!.map((a) => a.metin), ['tamam']);
    expect(sonuc.yuvalar['y1']!.map((a) => a.metin), ['gizemli']);
  });
}
