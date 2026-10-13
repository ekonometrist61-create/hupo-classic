import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/duyuru_models.dart';
import 'package:ogrenci_hazirlik/services/duyuru_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _duyuruJson({Object? bitisAt = '2099-01-01T00:00:00Z'}) => {
      'id': 'd1',
      'baslik': '  Yeni sınav dönemi  ',
      'metin': ' Deneme sınavları bu hafta başlıyor. ',
      'bitis_at': bitisAt,
    };

void main() {
  group('Duyuru.fromJson', () {
    test('geçerli duyuruyu okur ve metinleri kırpar', () {
      final d = Duyuru.fromJson(_duyuruJson());
      expect(d, isNotNull);
      expect(d!.id, 'd1');
      expect(d.baslik, 'Yeni sınav dönemi');
      expect(d.metin, 'Deneme sınavları bu hafta başlıyor.');
      expect(d.bitisAt, DateTime.parse('2099-01-01T00:00:00Z'));
    });

    test('bitis_at yoksa veya null ise bitisAt null, duyuru yine geçerli', () {
      final d = Duyuru.fromJson(_duyuruJson(bitisAt: null));
      expect(d, isNotNull);
      expect(d!.bitisAt, isNull);
    });

    test('bozuk bitis_at duyuruyu düşürmez, yalnızca bitiş bilgisini atar', () {
      final d = Duyuru.fromJson(_duyuruJson(bitisAt: 'yarın bir ara'));
      expect(d, isNotNull);
      expect(d!.bitisAt, isNull);
    });

    test('JSON null ve nesne olmayan değerler null döner', () {
      expect(Duyuru.fromJson(null), isNull);
      expect(Duyuru.fromJson('d1'), isNull);
      expect(Duyuru.fromJson(<Object?>[]), isNull);
    });

    test('eksik veya boş alanlı duyuru null döner', () {
      for (final eksik in ['id', 'baslik', 'metin']) {
        final json = _duyuruJson()..remove(eksik);
        expect(Duyuru.fromJson(json), isNull, reason: '$eksik eksikken');
      }
      expect(Duyuru.fromJson(_duyuruJson()..['baslik'] = '   '), isNull);
      expect(Duyuru.fromJson(_duyuruJson()..['metin'] = ''), isNull);
      expect(Duyuru.fromJson(_duyuruJson()..['id'] = ' '), isNull);
    });

    test('tipi uymayan alan duyuruyu düşürür', () {
      expect(Duyuru.fromJson(_duyuruJson()..['id'] = 42), isNull);
      expect(Duyuru.fromJson(_duyuruJson()..['baslik'] = 7), isNull);
      expect(Duyuru.fromJson(_duyuruJson()..['metin'] = true), isNull);
    });
  });

  group('DuyuruKapatma', () {
    final duyuru = Duyuru.fromJson(_duyuruJson())!;
    const digeri = Duyuru(id: 'd2', baslik: 'Başka', metin: 'Metin');

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('kapatılmamış duyuru gösterilir (kayıt yok)', () async {
      final prefs = await SharedPreferences.getInstance();
      final kapatma = DuyuruKapatma(prefs);
      expect(kapatma.kapatildiMi(duyuru), isFalse);
    });

    test('kapatılan duyuru aynı oturumda ve yeniden açılışta gizli kalır', () async {
      final prefs = await SharedPreferences.getInstance();
      await DuyuruKapatma(prefs).kapat(duyuru);

      expect(DuyuruKapatma(prefs).kapatildiMi(duyuru), isTrue);
      expect(prefs.getBool('duyuru_kapatildi_d1'), isTrue);
    });

    test('kapatma yalnızca o duyuru kimliğini etkiler', () async {
      final prefs = await SharedPreferences.getInstance();
      final kapatma = DuyuruKapatma(prefs);
      await kapatma.kapat(duyuru);
      expect(kapatma.kapatildiMi(digeri), isFalse);
    });

    test('önceden yazılmış kayıt okunur', () async {
      SharedPreferences.setMockInitialValues({'duyuru_kapatildi_d1': true});
      final prefs = await SharedPreferences.getInstance();
      expect(DuyuruKapatma(prefs).kapatildiMi(duyuru), isTrue);
    });
  });
}
