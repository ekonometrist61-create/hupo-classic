import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ogrenci_hazirlik/models/models.dart';
import 'package:ogrenci_hazirlik/theme/app_theme.dart';
import 'package:ogrenci_hazirlik/utils/soru_vurgu.dart';
import 'package:ogrenci_hazirlik/widgets/question_text.dart';

String birlesim(List<VurguParcasi> p) => p.map((e) => e.metin).join();

Widget sar(Widget w, {Brightness b = Brightness.light, double olcek = 1}) =>
    MaterialApp(
      theme: ThemeData(brightness: b),
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(olcek)),
        child: Scaffold(body: SizedBox(width: 200, child: w)),
      ),
    );

List<TextSpan> cocuklar(WidgetTester t) {
  final rt = t.widget<RichText>(find.byType(RichText).first);
  // Text.rich, verilen span'ı kendi kök span'ının tek çocuğu yapar.
  final benim = (rt.text as TextSpan).children!.single as TextSpan;
  return benim.children!.cast<TextSpan>();
}

void main() {
  group('vurguParcalari', () {
    const m = 'Aşağıdakilerden hangisi çift sayıdır?';

    test('geçerli aralık vurgulu parça verir, birleşim özgün metin', () {
      final p = vurguParcalari(m, const [VurguAraligi(16, 23)]);
      expect(p.where((e) => e.vurgulu).single.metin, 'hangisi');
      expect(birlesim(p), m);
    });

    test('kod noktası ofseti: emoji sonrası kayma yok', () {
      const e = '😀 Hangi sayı büyük?';
      final p = vurguParcalari(e, const [VurguAraligi(2, 7)]);
      expect(p.firstWhere((x) => x.vurgulu).metin, 'Hangi');
      expect(birlesim(p), e);
    });

    test('Türkçe karakterler doğru kesilir', () {
      final p = vurguParcalari('İSTANBUL ışığı', const [VurguAraligi(9, 14)]);
      expect(p.firstWhere((x) => x.vurgulu).metin, 'ışığı');
    });

    test('birden çok aralık ve bitişik aralıklar', () {
      final p = vurguParcalari(
          'abcdef', const [VurguAraligi(0, 2), VurguAraligi(4, 6)]);
      expect(p.map((e) => '${e.metin}:${e.vurgulu}').toList(),
          ['ab:true', 'cd:false', 'ef:true']);
      expect(
          vurguParcalari('abcd', const [VurguAraligi(0, 2), VurguAraligi(2, 4)])
              .every((e) => e.vurgulu),
          isTrue);
    });

    final gecersiz = <String, List<VurguAraligi>?>{
      'null': null,
      'boş': const [],
      'end > uzunluk': const [VurguAraligi(0, 99)],
      'negatif start': const [VurguAraligi(-1, 2)],
      'start == end': const [VurguAraligi(2, 2)],
      'start > end': const [VurguAraligi(3, 1)],
      'çakışan': const [VurguAraligi(0, 3), VurguAraligi(2, 4)],
      'sırasız': const [VurguAraligi(4, 6), VurguAraligi(0, 2)],
      'biri geçersiz': const [VurguAraligi(0, 2), VurguAraligi(5, 99)],
    };
    gecersiz.forEach((ad, h) {
      test('geçersiz ($ad) -> düz metin', () {
        final p = vurguParcalari('abcdef', h);
        expect(p.length, 1);
        expect(p.single.vurgulu, isFalse);
        expect(p.single.metin, 'abcdef');
      });
    });

    test('boş metin hata atmaz', () {
      expect(vurguParcalari('', const [VurguAraligi(0, 1)]).single.metin, '');
    });
  });

  group('vurguAraliklariCoz (jsonb)', () {
    test('geçerli jsonb', () {
      expect(
        vurguAraliklariCoz([
          {'start': 1, 'end': 3},
          {'start': 5.0, 'end': 8},
        ]),
        const [VurguAraligi(1, 3), VurguAraligi(5, 8)],
      );
    });
    test('bozuk biçimler boş liste verir', () {
      expect(vurguAraliklariCoz(null), isEmpty);
      expect(vurguAraliklariCoz('x'), isEmpty);
      expect(vurguAraliklariCoz([1, 2]), isEmpty);
      expect(
          vurguAraliklariCoz([
            {'start': '0', 'end': 2}
          ]),
          isEmpty);
      expect(
          vurguAraliklariCoz([
            {'start': 0.5, 'end': 2}
          ]),
          isEmpty);
      expect(
          vurguAraliklariCoz([
            {'start': 0}
          ]),
          isEmpty);
    });
    test('Question.fromMap highlights okur; yoksa boş', () {
      Map<String, dynamic> harita(Object? h) => {
            'id': 'q1',
            'ders': 'Türkçe',
            'konu': 'k',
            'zorluk': 1,
            'soru_metni': 'Altı çizili sözcük',
            'siklar': {'A': 'a', 'B': 'b'},
            if (h != null) 'highlights': h,
          };
      expect(Question.fromMap(harita(null)).highlights, isEmpty);
      expect(
        Question.fromMap(harita([
          {'start': 0, 'end': 4}
        ])).highlights,
        const [VurguAraligi(0, 4)],
      );
    });
  });

  group('QuestionRichText widget', () {
    testWidgets('vurgulu parça kalın 700 + altın alt çizgi, metin aynı',
        (t) async {
      await t.pumpWidget(sar(const QuestionRichText(
        'Altı çizili sözcüğü bul',
        highlights: [VurguAraligi(0, 4)],
      )));
      final c = cocuklar(t);
      expect(c.map((e) => e.text).join(), 'Altı çizili sözcüğü bul');
      final v = c.first.style!;
      expect(c.first.text, 'Altı');
      expect(v.fontWeight, FontWeight.w700);
      expect(v.decoration, TextDecoration.underline);
      expect(v.decorationColor, AppColors.vurguCizgi);
      expect(v.decorationThickness, 2.5);
      expect(v.color, AppColors.vurguMetin);
      expect(c.last.style, isNull);
      expect(find.text('Altı çizili sözcüğü bul', findRichText: true),
          findsOneWidget);
    });

    testWidgets('koyu temada koyu token çifti', (t) async {
      await t.pumpWidget(sar(
        const QuestionRichText('abc', highlights: [VurguAraligi(0, 1)]),
        b: Brightness.dark,
      ));
      final v = cocuklar(t).first.style!;
      expect(v.decorationColor, AppColors.vurguCizgiKoyu);
      expect(v.color, AppColors.vurguMetinKoyu);
    });

    testWidgets('geçersiz aralık -> düz metin, hiçbir parça vurgulu değil',
        (t) async {
      await t.pumpWidget(sar(const QuestionRichText('Düz soru',
          highlights: [VurguAraligi(3, 99)])));
      final c = cocuklar(t);
      expect(c.length, 1);
      expect(c.single.text, 'Düz soru');
      expect(c.single.style, isNull);
    });

    testWidgets('highlights yok -> düz metin; eski ** işareti geçişte çalışır',
        (t) async {
      await t.pumpWidget(sar(const QuestionRichText('Düz soru')));
      expect(cocuklar(t).single.style, isNull);
      await t.pumpWidget(sar(const QuestionRichText('a **b** c')));
      final c = cocuklar(t);
      expect(c[1].text, 'b');
      expect(c[1].style!.decoration, TextDecoration.underline);
    });

    testWidgets('dar ekran + 2x yazı büyütmede taşma hatası vermez',
        (t) async {
      await t.pumpWidget(sar(
        const QuestionRichText(
          'Aşağıdaki cümlelerden hangisinde yazım yanlışı vardır, bulunuz?',
          highlights: [VurguAraligi(36, 42), VurguAraligi(43, 51)],
        ),
        olcek: 2,
      ));
      expect(t.takeException(), isNull);
    });
  });
}
