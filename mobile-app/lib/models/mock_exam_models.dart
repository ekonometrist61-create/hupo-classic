// Deneme sınavı modelleri (list_my_exams / start_mock_exam / submit_mock_exam).
import '../models/models.dart';

class MockExamSummary {
  const MockExamSummary({
    required this.id,
    required this.ad,
    required this.baslangicZamani,
    required this.sureDakika,
    required this.bitti,
    required this.puan,
    required this.dogruSayisi,
    required this.yanlisSayisi,
    required this.bosSayisi,
    this.denemelId,
  });

  final String id;
  final String ad;
  final DateTime baslangicZamani;
  final int sureDakika;
  final bool bitti;
  final double puan;
  final int dogruSayisi;
  final int yanlisSayisi;
  final int bosSayisi;
  final String? denemelId;

  bool get basladi => denemelId != null;

  DateTime get bitisHedefi => baslangicZamani.add(Duration(minutes: sureDakika));
  bool get sureDoldu => DateTime.now().isAfter(bitisHedefi);

  factory MockExamSummary.fromMap(Map<String, dynamic> map) => MockExamSummary(
        id: map['id'] as String,
        ad: map['ad'] as String,
        baslangicZamani: DateTime.parse(map['baslangic_zamani'] as String).toLocal(),
        sureDakika: (map['sure_dakika'] as num).toInt(),
        bitti: map['bitti'] as bool? ?? false,
        puan: (map['puan'] as num?)?.toDouble() ?? 0,
        dogruSayisi: (map['dogru_sayisi'] as num?)?.toInt() ?? 0,
        yanlisSayisi: (map['yanlis_sayisi'] as num?)?.toInt() ?? 0,
        bosSayisi: (map['bos_sayisi'] as num?)?.toInt() ?? 0,
        denemelId: map['deneme_id'] as String?,
      );
}

class MockExamSession {
  const MockExamSession({
    required this.denemelId,
    required this.sinavId,
    required this.ad,
    required this.sureDakika,
    required this.baslangicZamani,
    required this.bitisHedefi,
    required this.sorular,
  });

  final String denemelId;
  final String sinavId;
  final String ad;
  final int sureDakika;
  final DateTime baslangicZamani;
  final DateTime bitisHedefi;
  final List<Question> sorular;

  int get kalanSaniye {
    final kalan = bitisHedefi.difference(DateTime.now()).inSeconds;
    return kalan < 0 ? 0 : kalan;
  }

  bool get sureDoldu => DateTime.now().isAfter(bitisHedefi);

  factory MockExamSession.fromMap(Map<String, dynamic> map) {
    final sorularRaw = map['sorular'] as List? ?? [];
    return MockExamSession(
      denemelId: map['deneme_id'] as String,
      sinavId: map['sinav_id'] as String,
      ad: map['ad'] as String,
      sureDakika: (map['sure_dakika'] as num).toInt(),
      baslangicZamani: DateTime.parse(map['baslangic_zamani'] as String).toLocal(),
      bitisHedefi: DateTime.parse(map['bitis_hedefi'] as String).toLocal(),
      sorular: [
        for (final s in sorularRaw)
          _soruFromMap(Map<String, dynamic>.from(s as Map)),
      ],
    );
  }

  static Question _soruFromMap(Map<String, dynamic> map) {
    final raw = Map<String, dynamic>.from(map['siklar'] as Map);
    final keys = raw.keys.toList()..sort();
    return Question(
      id: map['id'] as String,
      ders: map['konu'] as String? ?? '',
      konu: map['konu'] as String? ?? '',
      zorluk: (map['zorluk'] as num?)?.toInt() ?? 2,
      text: map['soru_metni'] as String,
      options: {for (final k in keys) k: raw[k].toString()},
    );
  }
}

class MockExamResult {
  const MockExamResult({
    required this.dogruSayisi,
    required this.yanlisSayisi,
    required this.bosSayisi,
    required this.toplam,
    required this.puan,
  });

  final int dogruSayisi;
  final int yanlisSayisi;
  final int bosSayisi;
  final int toplam;
  final double puan;

  double get basariOrani => toplam > 0 ? dogruSayisi / toplam : 0;

  factory MockExamResult.fromMap(Map<String, dynamic> map) => MockExamResult(
        dogruSayisi: (map['dogru_sayisi'] as num).toInt(),
        yanlisSayisi: (map['yanlis_sayisi'] as num).toInt(),
        bosSayisi: (map['bos_sayisi'] as num).toInt(),
        toplam: (map['toplam'] as num).toInt(),
        puan: (map['puan'] as num).toDouble(),
      );
}
