// Günün 5 Sorusu (Daily Challenge) veri modelleri.
//
// Kaynak: public.get_daily_challenge() ve public.complete_daily_challenge() RPC'leri.
// APK sınıf adları: DailyChallenge, DailyChallengeCompletion.

import 'models.dart';

/// public.get_daily_challenge() yanıt modeli.
class DailyChallenge {
  const DailyChallenge({
    required this.gun,
    required this.mevcut,
    this.anahtar,
    this.sorular = const [],
    this.toplam = 0,
    this.cevaplanan = 0,
    this.cevaplananIdler = const [],
    this.tamamlandi = false,
    this.dogruSayisi = 0,
    this.bonusXp = 0,
  });

  final String gun;
  final bool mevcut;
  final String? anahtar;
  final List<Question> sorular;
  final int toplam;
  final int cevaplanan;
  final List<String> cevaplananIdler;
  final bool tamamlandi;
  final int dogruSayisi;
  final int bonusXp;

  /// Kalan soru sayısı.
  int get kalanSoru => (toplam - cevaplanan).clamp(0, toplam);

  /// Günün soruları tamamen bitti mi (tamamlandı RPC'si çağrılabilir mi).
  bool get hepsiCevaplandi => toplam > 0 && cevaplanan >= toplam;

  factory DailyChallenge.fromMap(Map<String, dynamic> map) => DailyChallenge(
        gun: map['gun'] as String? ?? '',
        mevcut: map['mevcut'] as bool? ?? false,
        anahtar: map['anahtar'] as String?,
        sorular: [
          for (final q in (map['sorular'] as List? ?? const []))
            Question.fromMap(Map<String, dynamic>.from(q as Map)),
        ],
        toplam: (map['toplam'] as num?)?.toInt() ?? 0,
        cevaplanan: (map['cevaplanan'] as num?)?.toInt() ?? 0,
        cevaplananIdler: [
          for (final id in (map['cevaplanan_idler'] as List? ?? const []))
            id.toString(),
        ],
        tamamlandi: map['tamamlandi'] as bool? ?? false,
        dogruSayisi: (map['dogru_sayisi'] as num?)?.toInt() ?? 0,
        bonusXp: (map['bonus_xp'] as num?)?.toInt() ?? 0,
      );

  DailyChallenge copyWith({
    String? gun,
    bool? mevcut,
    String? anahtar,
    List<Question>? sorular,
    int? toplam,
    int? cevaplanan,
    List<String>? cevaplananIdler,
    bool? tamamlandi,
    int? dogruSayisi,
    int? bonusXp,
  }) =>
      DailyChallenge(
        gun: gun ?? this.gun,
        mevcut: mevcut ?? this.mevcut,
        anahtar: anahtar ?? this.anahtar,
        sorular: sorular ?? this.sorular,
        toplam: toplam ?? this.toplam,
        cevaplanan: cevaplanan ?? this.cevaplanan,
        cevaplananIdler: cevaplananIdler ?? this.cevaplananIdler,
        tamamlandi: tamamlandi ?? this.tamamlandi,
        dogruSayisi: dogruSayisi ?? this.dogruSayisi,
        bonusXp: bonusXp ?? this.bonusXp,
      );
}

/// public.complete_daily_challenge() RPC yanıtı.
class DailyChallengeCompletion {
  const DailyChallengeCompletion({
    required this.tamamlandi,
    this.yeni = false,
    this.dogruSayisi = 0,
    this.bonusXp = 0,
  });

  final bool tamamlandi;
  final bool yeni;
  final int dogruSayisi;
  final int bonusXp;

  factory DailyChallengeCompletion.fromMap(Map<String, dynamic> map) =>
      DailyChallengeCompletion(
        tamamlandi: map['tamamlandi'] as bool? ?? false,
        yeni: map['yeni'] as bool? ?? false,
        dogruSayisi: (map['dogru_sayisi'] as num?)?.toInt() ?? 0,
        bonusXp: (map['bonus_xp'] as num?)?.toInt() ?? 0,
      );
}
