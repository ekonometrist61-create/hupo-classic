import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/utils/format.dart';

void main() {
  group('Tarih biçimi (GG.AA.YYYY)', () {
    test('gün ve ay iki haneli yazılır', () {
      expect(formatDate(DateTime(2026, 9, 2)), '02.09.2026');
      expect(formatDate(DateTime(2026, 12, 25)), '25.12.2026');
      expect(formatDate(DateTime(2027, 1, 1)), '01.01.2027');
    });
  });

  group('Para birimi (₺)', () {
    test('binlik ayırıcı nokta, ondalık ayırıcı virgül', () {
      expect(formatTry(0), '₺0,00');
      expect(formatTry(12.5), '₺12,50');
      expect(formatTry(1234.5), '₺1.234,50');
      expect(formatTry(1234567.891), '₺1.234.567,89');
      expect(formatTry(-2399), '-₺2.399,00');
    });
  });

  group('Kod tabanı taraması', () {
    final sources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    test('kaynak kodda dolar/euro para birimi yok', () {
      // (?<!\.) hariç: r.$1, r.$2 gibi Dart kayıt alanı erişimlerini (record fields) eşleştirmez
      final pattern = RegExp(r'USD|EUR|€|£|(?<!\.)\$[0-9]');
      for (final file in sources) {
        expect(pattern.hasMatch(file.readAsStringSync()), isFalse,
            reason: '${file.path} ₺ dışında bir para birimi içeriyor');
      }
    });

    test('tarihler ay adıyla değil GG.AA.YYYY biçiminde gösteriliyor', () {
      final months = RegExp(
          r'Ocak|Şubat|Mart|Nisan|Mayıs|Haziran|Temmuz|Ağustos|Eylül|Ekim|Kasım|Aralık');
      for (final file in sources) {
        expect(months.hasMatch(file.readAsStringSync()), isFalse,
            reason: '${file.path} ay adıyla tarih biçimi içeriyor');
      }
    });
  });

  group('Teşvik edici dil', () {
    BadgeInfo badge({required bool earned, int progress = 0}) => BadgeInfo(
          code: 'x',
          name: 'X',
          description: 'd',
          icon: 'star',
          conditionType: 'soru_sayisi',
          threshold: 10,
          earned: earned,
          progress: progress,
        );

    test('kazanılan rozet tebrik eder', () {
      expect(badge(earned: true).encouragement, 'Tebrikler, bu rozeti hak ettin!');
    });

    test('yarısını geçen kilitli rozet "az kaldı" der', () {
      expect(badge(earned: false, progress: 6).encouragement,
          'Az kaldı, neredeyse tamam!');
    });

    test('yeni başlayan kilitli rozet cesaretlendirir', () {
      expect(badge(earned: false, progress: 1).encouragement,
          'Adım adım ilerle, sen yaparsın!');
    });
  });
}
