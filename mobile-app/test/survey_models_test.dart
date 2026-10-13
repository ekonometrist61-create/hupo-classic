import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/survey_models.dart';
import 'package:ogrenci_hazirlik/services/survey_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _anketJson({bool anonim = false, List<Object?>? sorular}) => {
      'id': 'a1',
      'ad': 'Memnuniyet anketi',
      'anonim': anonim,
      'surum': 2,
      'sorular': sorular ??
          [
            {'id': 'nps', 'tur': 'nps', 'baslik': 'Tavsiye eder misin?'},
            {
              'id': 'neden',
              'tur': 'kisa_metin',
              'baslik': 'Neden?',
              'kosul': {'soru_id': 'nps', 'op': 'lte', 'deger': 6},
            },
            {
              'id': 'csat',
              'tur': 'csat',
              'baslik': 'Memnuniyet',
            },
          ],
    };

void main() {
  group('Anket.fromJson', () {
    test('geçerli anketi okur', () {
      final anket = Anket.fromJson(_anketJson());
      expect(anket, isNotNull);
      expect(anket!.id, 'a1');
      expect(anket.anonim, isFalse);
      expect(anket.surum, 2);
      expect(anket.sorular.map((s) => s.id), ['nps', 'neden', 'csat']);
      expect(anket.sorular[1].kosul!.sorusuId, 'nps');
      expect(anket.sorular[1].kosul!.op, AnketKosulOp.lte);
      expect(anket.ertelemeAnahtari, 'a1:2');
    });

    test('bilinmeyen soru türü sessizce atlanır', () {
      final anket = Anket.fromJson(_anketJson(sorular: [
        {'id': 'x', 'tur': 'video', 'baslik': 'Bilinmeyen'},
        {'id': 'nps', 'tur': 'nps', 'baslik': 'Tavsiye'},
      ]));
      expect(anket!.sorular.map((s) => s.id), ['nps']);
    });

    test('koşulun bağlı olduğu soru yoksa koşullu soru da atlanır', () {
      final anket = Anket.fromJson(_anketJson(sorular: [
        {'id': 'nps', 'tur': 'bilinmeyen', 'baslik': 'Atlanan'},
        {
          'id': 'neden',
          'tur': 'kisa_metin',
          'baslik': 'Neden?',
          'kosul': {'soru_id': 'nps', 'op': 'lte', 'deger': 6},
        },
      ]));
      expect(anket, isNull, reason: 'hiç geçerli soru kalmadı');
    });

    test('bilinmeyen koşul operatörü soruyu geçersiz kılar', () {
      final anket = Anket.fromJson(_anketJson(sorular: [
        {'id': 'nps', 'tur': 'nps', 'baslik': 'Tavsiye'},
        {
          'id': 'neden',
          'tur': 'kisa_metin',
          'baslik': 'Neden?',
          'kosul': {'soru_id': 'nps', 'op': 'like', 'deger': 6},
        },
      ]));
      expect(anket!.sorular.map((s) => s.id), ['nps']);
    });

    test('anonim alanı bool değilse anket hiç yüklenmez', () {
      final json = _anketJson()..['anonim'] = 'evet';
      expect(Anket.fromJson(json), isNull);
    });

    test('tek seçimde en az iki seçenek gerekir', () {
      final anket = Anket.fromJson(_anketJson(sorular: [
        {'id': 'nps', 'tur': 'nps', 'baslik': 'Tavsiye'},
        {'id': 'tek', 'tur': 'tek_secim', 'baslik': 'Tek', 'secenekler': ['Tek']},
      ]));
      expect(anket!.sorular.map((s) => s.id), ['nps']);
    });

    test('listede bozuk öğe varsa yalnızca o öğe atlanır', () {
      final liste = anketListesiFromJson([null, 'bozuk', _anketJson()]);
      expect(liste.length, 1);
      expect(anketListesiFromJson(null), isEmpty);
    });
  });

  group('AnketDegerlendirme (koşullu görünürlük)', () {
    final anket = Anket.fromJson(_anketJson())!;

    test('koşul sağlanınca bağlı soru görünür ve gönderilir', () {
      final d = AnketDegerlendirme.hesapla(anket.sorular, {'nps': 4, 'neden': 'Kötü'});
      expect(d.gorunenSorular.map((s) => s.id), ['nps', 'neden', 'csat']);
      expect(d.gecerliYanitlar, {'nps': 4, 'neden': 'Kötü'});
    });

    test('koşul sağlanmayınca bağlı soru gizlenir ve yanıtı GÖNDERİLMEZ', () {
      final d = AnketDegerlendirme.hesapla(anket.sorular, {'nps': 9, 'neden': 'Ekranda kaldı'});
      expect(d.gorunenSorular.map((s) => s.id), ['nps', 'csat']);
      expect(d.gecerliYanitlar, {'nps': 9});
      expect(d.gecerliYanitlar.containsKey('neden'), isFalse);
    });

    test('koşulun bağlı olduğu sorunun yanıtı yoksa bağlı soru gizli kalır', () {
      final d = AnketDegerlendirme.hesapla(anket.sorular, {'neden': 'Yanıt verildi ama koşul yok'});
      expect(d.gorunenSorular.map((s) => s.id), ['nps', 'csat']);
      expect(d.gecerliYanitlar.containsKey('neden'), isFalse);
      expect(d.gonderilebilir, isFalse);
    });

    test('koşulun bağlı olduğu soru sayısal değilse koşul sağlanmaz', () {
      final d = AnketDegerlendirme.hesapla(anket.sorular, {'nps': 'üç', 'neden': 'x'});
      expect(d.gorunenSorular.map((s) => s.id), ['nps', 'csat']);
      expect(d.gecerliYanitlar.containsKey('neden'), isFalse);
    });

    test('boş metin ve null yanıtlar gönderilmez', () {
      final d = AnketDegerlendirme.hesapla(anket.sorular, {'nps': null, 'csat': 4, 'neden': '   '});
      expect(d.gecerliYanitlar, {'csat': 4});
    });

    test('sunucunun kabul etmeyeceği biçimdeki değerler gönderilmez', () {
      final d = AnketDegerlendirme.hesapla(anket.sorular, {'nps': 11, 'csat': 0});
      expect(d.gecerliYanitlar, isEmpty);
      expect(d.gonderilebilir, isFalse);
    });

    test('nps 0-10 tam sayı, csat 1-5 sınırları', () {
      final nps = anket.sorular.firstWhere((s) => s.id == 'nps');
      expect(nps.degerGecerli(0), isTrue);
      expect(nps.degerGecerli(10), isTrue);
      expect(nps.degerGecerli(10.5), isFalse);
      final csat = anket.sorular.firstWhere((s) => s.id == 'csat');
      expect(csat.degerGecerli(1), isTrue);
      expect(csat.degerGecerli(5), isTrue);
      expect(csat.degerGecerli(6), isFalse);
    });

    test('tek seçim yalnızca tanımlı seçeneği kabul eder', () {
      final tek = Anket.fromJson(_anketJson(sorular: [
        {'id': 'tek', 'tur': 'tek_secim', 'baslik': 'Seç', 'secenekler': ['A', 'B']},
      ]))!;
      final d = AnketDegerlendirme.hesapla(tek.sorular, {'tek': 'C'});
      expect(d.gecerliYanitlar, isEmpty);
      final d2 = AnketDegerlendirme.hesapla(tek.sorular, {'tek': 'B'});
      expect(d2.gecerliYanitlar, {'tek': 'B'});
    });
  });

  group('anketHatasiKodu (sunucu kodu → hata)', () {
    test('bilinen SQLSTATE kodları eşlenir', () {
      expect(anketHatasiKodu('42501'), AnketHatasi.yetkisiz);
      expect(anketHatasiKodu('23505'), AnketHatasi.yakinZamanda);
      expect(anketHatasiKodu('22023'), AnketHatasi.gecersizYanit);
      expect(anketHatasiKodu('P0002'), AnketHatasi.bulunamadi);
      expect(anketHatasiKodu('XX000'), AnketHatasi.bilinmeyen);
      expect(anketHatasiKodu(null), AnketHatasi.bilinmeyen);
    });
  });

  group('SurveyDeferral', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('ertelenen anket 1 gün gizli kalır, sonra yeniden görünür', () async {
      final prefs = await SharedPreferences.getInstance();
      var simdi = DateTime(2026, 10, 13, 9);
      final erteleme = SurveyDeferral(prefs, simdi: () => simdi);
      final anket = Anket.fromJson(_anketJson())!;

      expect(erteleme.erteleniyorMu(anket), isFalse);
      await erteleme.ertele(anket);
      expect(erteleme.erteleniyorMu(anket), isTrue);

      simdi = DateTime(2026, 10, 13, 20);
      expect(erteleme.erteleniyorMu(anket), isTrue);

      simdi = DateTime(2026, 10, 14, 9, 1);
      expect(erteleme.erteleniyorMu(anket), isFalse);
    });

    test('yeni sürüm ertelemeyi sıfırlar', () async {
      final prefs = await SharedPreferences.getInstance();
      final erteleme = SurveyDeferral(prefs, simdi: () => DateTime(2026, 10, 13));
      final anket = Anket.fromJson(_anketJson())!;
      await erteleme.ertele(anket);

      final yeniSurum = Anket.fromJson(_anketJson()..['surum'] = 3)!;
      expect(erteleme.erteleniyorMu(yeniSurum), isFalse);
    });
  });
}
