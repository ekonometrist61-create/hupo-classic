// W8: Arkadaşa Meydan Oku modelleri
import 'models.dart';

class ChallengeSession {
  const ChallengeSession({
    required this.id,
    required this.kod,
    required this.sorular,
    required this.sureDakika,
    required this.durum,
    required this.baslangic,
  });

  final String id;
  final String kod;
  final List<Question> sorular;
  final int sureDakika;
  final String durum; // bekliyor | aktif | bitti
  final DateTime baslangic;

  DateTime get bitisHedefi => baslangic.add(Duration(minutes: sureDakika));
  int get kalanSaniye {
    final k = bitisHedefi.difference(DateTime.now()).inSeconds;
    return k < 0 ? 0 : k;
  }

  factory ChallengeSession.fromMap(Map<String, dynamic> map) {
    final sorularRaw = map['sorular'] as List? ?? [];
    return ChallengeSession(
      id: map['id'] as String,
      kod: map['kod'] as String,
      sorular: [
        for (final s in sorularRaw) _soruFromMap(Map<String, dynamic>.from(s as Map)),
      ],
      sureDakika: (map['sure_dakika'] as num?)?.toInt() ?? 5,
      durum: map['durum'] as String? ?? 'bekliyor',
      baslangic: DateTime.now(),
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

class ChallengeScore {
  const ChallengeScore({
    required this.dogru,
    required this.yanlis,
    required this.puan,
    required this.bitti,
  });

  final int dogru;
  final int yanlis;
  final double puan;
  final bool bitti;

  factory ChallengeScore.fromMap(Map<String, dynamic> map) => ChallengeScore(
        dogru: (map['dogru'] as num?)?.toInt() ?? 0,
        yanlis: (map['yanlis'] as num?)?.toInt() ?? 0,
        puan: (map['puan'] as num?)?.toDouble() ?? 0,
        bitti: map['bitti'] as bool? ?? false,
      );
}

class ChallengeResult {
  const ChallengeResult({
    required this.id,
    required this.durum,
    required this.kod,
    this.ben,
    this.rakip,
  });

  final String id;
  final String durum;
  final String kod;
  final ChallengeScore? ben;
  final ChallengeScore? rakip;

  bool get bitti => durum == 'bitti';
  bool get rakipBitti => rakip?.bitti ?? false;
  bool? get kazandim {
    if (ben == null || rakip == null) return null;
    if (ben!.puan > rakip!.puan) return true;
    if (ben!.puan < rakip!.puan) return false;
    return null; // beraberlik
  }

  factory ChallengeResult.fromMap(Map<String, dynamic> map) => ChallengeResult(
        id: map['id'] as String,
        durum: map['durum'] as String? ?? 'bitti',
        kod: map['kod'] as String? ?? '',
        ben: map['ben'] != null && map['ben'] is Map
            ? ChallengeScore.fromMap(Map<String, dynamic>.from(map['ben'] as Map))
            : null,
        rakip: map['rakip'] != null && map['rakip'] is Map
            ? ChallengeScore.fromMap(Map<String, dynamic>.from(map['rakip'] as Map))
            : null,
      );
}
