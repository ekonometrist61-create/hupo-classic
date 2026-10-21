import 'package:okuma_motoru/hikaye_cozucu.dart';
import 'package:okuma_motoru/turkce_ad.dart';
import 'package:test/test.dart';

// Test verisi: örnek hikâyenin küçük bir sürümü. Gerçek çocuk adı yok; yer tutucu adlar.
Hikaye ornek({Map<String, Sahne>? degerSahneleri, List<String>? izinli}) => Hikaye(
      sayfalar: [
        [
          const KahramanAd(),
          const Metin(' defter buldu. '),
          const KelimeYuva('gizemli_sifat'),
          const Metin(' bir harita çıktı.'),
        ],
        [
          const KahramanAd(Hal.ilgi),
          const Metin(' dikkati değişti. '),
          const DegerSahnesi('karar'),
        ],
        [
          const YoldasAd(Hal.yonelme, 'bir dostuna'),
          const Metin(' seslendi. '),
          const Vurgu('birlikte'),
          const Metin(' çözdüler. '),
          const DeyimCumlesi('el_ele'),
          const Metin(' '),
          const AtasozuYuva('isbirligi'),
        ],
      ],
      izinliTurler: izinli ?? const ['ben', 'baba', 'anne', 'kardes', 'baska_biri'],
      degerSahneleri: degerSahneleri ??
          const {
            'karar': Sahne({
              'D6': [Metin('Defteri teslim etti.')],
              'D20': [Metin('Yardım istedi.')],
              '_default': [Metin('Düşündü.')],
            }),
          },
      deyimCumleleri: const {
        'el_ele': [Metin('Arkadaşlarıyla el ele verip ipuçlarını birleştirdi.')],
      },
      yuvalar: const {
        'gizemli_sifat': [
          YuvaAdayi('gizemli', 4, 5),
          YuvaAdayi('esrarengiz', 5, 6),
        ],
        'isbirligi': [YuvaAdayi('Bir elin nesi var, iki elin sesi var.', 4, 6)],
      },
    );

Baglam baglam({int sinif = 4, List<String> degerler = const [], Set<String> gorulen = const {}, String? yoldas}) =>
    Baglam(
      kahramanAdi: 'Efe',
      kahramanTuru: 'ben',
      sinif: sinif,
      yoldasAdi: yoldas,
      degerler: degerler,
      gorulen: gorulen,
    );

String duz(List<Cikti> c) => c.map((x) => x.metin).join();

void main() {
  test('kahraman adı yalın ve ilgi hâlinde doğru çekilir', () {
    final s = sayfalariCoz(ornek(), baglam());
    expect(duz(s[0]), 'Efe defter buldu. gizemli bir harita çıktı.');
    expect(duz(s[1]).startsWith("Efe'nin dikkati"), isTrue);
  });

  test('yol arkadaşı seçilirse adı, seçilmezse yedek metin kullanılır', () {
    final yedekli = duz(sayfalariCoz(ornek(), baglam())[2]);
    expect(yedekli.startsWith('bir dostuna seslendi.'), isTrue);

    final adli = duz(sayfalariCoz(ornek(), baglam(yoldas: 'Ali'))[2]);
    expect(adli.startsWith("Ali'ye seslendi."), isTrue);
  });

  test('değer sahnesi: öncelik sırası belirler, yoksa _default', () {
    expect(duz(sayfalariCoz(ornek(), baglam(degerler: ['D20']))[1]).endsWith('Yardım istedi.'), isTrue);
    expect(duz(sayfalariCoz(ornek(), baglam(degerler: ['D9', 'D6', 'D20']))[1]).endsWith('Defteri teslim etti.'),
        isTrue);
    expect(duz(sayfalariCoz(ornek(), baglam())[1]).endsWith('Düşündü.'), isTrue);
  });

  test('_default olmayan değer sahnesi hata verir', () {
    final bozuk = ornek(degerSahneleri: const {
      'karar': Sahne({'D6': [Metin('x')]}),
    });
    expect(() => sayfalariCoz(bozuk, baglam()), throwsA(isA<HikayeHatasi>()));
  });

  test('sözlük yuvası sınıfa göre aday seçer', () {
    expect(duz(sayfalariCoz(ornek(), baglam(sinif: 4))[0]), contains('gizemli bir'));
    expect(duz(sayfalariCoz(ornek(), baglam(sinif: 6))[0]), contains('esrarengiz bir'));
  });

  test('görülen aday tekrar edilmez; başka aday varsa o seçilir', () {
    final s = sayfalariCoz(ornek(), baglam(sinif: 5, gorulen: {'esrarengiz'}));
    expect(duz(s[0]), contains('gizemli bir'));
    final s2 = sayfalariCoz(ornek(), baglam(sinif: 5, gorulen: {'gizemli'}));
    expect(duz(s2[0]), contains('esrarengiz bir'));
  });

  test('sınıf için aday yoksa hata verir', () {
    expect(() => sayfalariCoz(ornek(), baglam(sinif: 2)), throwsA(isA<HikayeHatasi>()));
  });

  test('deyim cümlesi ve atasözü yerleşir', () {
    final son = duz(sayfalariCoz(ornek(), baglam())[2]);
    expect(son, contains('Arkadaşlarıyla el ele verip ipuçlarını birleştirdi.'));
    expect(son.endsWith('Bir elin nesi var, iki elin sesi var.'), isTrue);
  });

  test('stiller: sözcük, atasözü ve önemli yer ayrı işaretlenir', () {
    final s = sayfalariCoz(ornek(), baglam());
    final kelime = s[0].firstWhere((c) => c.stil == Stil.kelime);
    expect(kelime.metin, 'gizemli');
    final vurgu = s[2].firstWhere((c) => c.stil == Stil.onemli);
    expect(vurgu.metin, 'birlikte');
    expect(s[2].any((c) => c.stil == Stil.atasozu), isTrue);
  });

  test('kahraman türü izinli değilse hikâye başlatılmaz', () {
    final tur = Baglam(kahramanAdi: 'Pati', kahramanTuru: 'hayvan', sinif: 4);
    expect(() => sayfalariCoz(ornek(), tur), throwsA(isA<HikayeHatasi>()));
  });

  test('hareket sahnesi: kahraman türüne göre varyant seçilir', () {
    final hikaye = Hikaye(
      sayfalar: const [
        [KahramanAd(), Metin(' geldi. '), HareketSahnesi('geliş')],
      ],
      izinliTurler: const ['ben', 'hayvan'],
      hareketSahneleri: const {
        'geliş': Sahne({
          'hayvan': [Metin('Patileriyle yürüdü.')],
          '_default': [Metin('Yürüyerek geldi.')],
        }),
      },
    );
    final hayvan = Baglam(kahramanAdi: 'Pati', kahramanTuru: 'hayvan', sinif: 4);
    expect(duz(sayfalariCoz(hikaye, hayvan)[0]), 'Pati geldi. Patileriyle yürüdü.');
    final ben = Baglam(kahramanAdi: 'Efe', kahramanTuru: 'ben', sinif: 4);
    expect(duz(sayfalariCoz(hikaye, ben)[0]), 'Efe geldi. Yürüyerek geldi.');
  });

  test('bilinmeyen işaret ve sonsuz deyim döngüsü hata verir', () {
    const isaretli = Hikaye(
      sayfalar: [
        [Isaret('bilinmeyen')],
      ],
      izinliTurler: ['ben'],
    );
    expect(() => sayfalariCoz(isaretli, baglam()), throwsA(isA<HikayeHatasi>()));

    const dongu = Hikaye(
      sayfalar: [
        [DeyimCumlesi('a')],
      ],
      izinliTurler: ['ben'],
      deyimCumleleri: {
        'a': [DeyimCumlesi('a')],
      },
    );
    expect(() => sayfalariCoz(dongu, baglam()), throwsA(isA<HikayeHatasi>()));
  });
}
