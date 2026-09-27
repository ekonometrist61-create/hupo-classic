// Lig, profil ilerlemesi ve bildirim modelleri.

import 'package:flutter/painting.dart' show Color;

/// public.get_league_status() sonucu. Sıralama ANONİMDİR: yalnızca sayılar gelir.
class LeagueStatus {
  const LeagueStatus({
    required this.code,
    required this.name,
    required this.tier,
    required this.colorHex,
    required this.icon,
    required this.weeklyXp,
    required this.rank,
    required this.total,
    required this.remainingSeconds,
    this.nextLeagueName,
    this.promotionXp,
  });

  final String code;
  final String name;

  /// 1 = en alt lig.
  final int tier;
  final String colorHex;
  final String icon;
  final int weeklyXp;

  /// Aynı ligdeki öğrenciler arasında bu haftaki sıran (1 = en iyi).
  final int rank;
  final int total;
  final int remainingSeconds;
  final String? nextLeagueName;

  /// Üst lige çıkmak için haftalık XP eşiği; en üst ligde null.
  final int? promotionXp;

  bool get isTopLeague => promotionXp == null;

  Color get color =>
      Color(int.parse('FF${colorHex.replaceFirst('#', '')}', radix: 16));

  /// 0.0 - 1.0; en üst ligde hep 1.
  double get promotionProgress {
    final target = promotionXp;
    if (target == null || target <= 0) return 1;
    return (weeklyXp / target).clamp(0.0, 1.0).toDouble();
  }

  int get xpToPromotion {
    final target = promotionXp;
    return target == null ? 0 : (target - weeklyXp).clamp(0, target);
  }

  factory LeagueStatus.fromMap(Map<String, dynamic> map) => LeagueStatus(
        code: map['kod'] as String,
        name: map['ad'] as String,
        tier: (map['sira_no'] as num).toInt(),
        colorHex: map['renk'] as String,
        icon: map['ikon'] as String? ?? 'shield',
        weeklyXp: (map['haftalik_xp'] as num).toInt(),
        rank: (map['sira'] as num).toInt(),
        total: (map['toplam'] as num).toInt(),
        remainingSeconds: (map['kalan_saniye'] as num).toInt(),
        nextLeagueName: map['sonraki_lig'] as String?,
        promotionXp: (map['yukselme_xp'] as num?)?.toInt(),
      );
}

class SubjectProgress {
  const SubjectProgress({
    required this.ders,
    required this.solved,
    required this.total,
    required this.success,
  });

  final String ders;

  /// Bu derste en az bir kez cevaplanan soru sayısı.
  final int solved;
  final int total;

  /// Doğru cevap yüzdesi (0-100).
  final int success;

  double get completion =>
      total == 0 ? 0 : (solved / total).clamp(0.0, 1.0).toDouble();

  factory SubjectProgress.fromMap(Map<String, dynamic> map) => SubjectProgress(
        ders: map['ders'] as String,
        solved: (map['cozulen'] as num).toInt(),
        total: (map['toplam'] as num).toInt(),
        success: (map['basari'] as num).toInt(),
      );
}

/// public.get_profile_overview() sonucu.
class ProfileOverview {
  const ProfileOverview({
    required this.totalSolved,
    required this.longestStreak,
    required this.subjects,
    this.joinedAt,
    this.accuracy,
  });

  final DateTime? joinedAt;
  final int totalSolved;

  /// Genel doğruluk yüzdesi; hiç soru çözülmediyse null.
  final int? accuracy;
  final int longestStreak;
  final List<SubjectProgress> subjects;

  factory ProfileOverview.fromMap(Map<String, dynamic> map) => ProfileOverview(
        joinedAt: map['uye_tarihi'] == null
            ? null
            : DateTime.parse(map['uye_tarihi'] as String).toLocal(),
        totalSolved: (map['toplam_soru'] as num?)?.toInt() ?? 0,
        accuracy: (map['dogruluk'] as num?)?.toInt(),
        longestStreak: (map['en_uzun_seri'] as num?)?.toInt() ?? 0,
        subjects: [
          for (final s in (map['ders_ilerleme'] as List? ?? const []))
            SubjectProgress.fromMap(Map<String, dynamic>.from(s as Map)),
        ],
      );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    required this.read,
    required this.createdAt,
  });

  final String id;

  /// rozet | seviye | lig | bilgi
  final String type;
  final String title;
  final String message;
  final String icon;
  final bool read;
  final DateTime createdAt;

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] as String,
        type: map['tur'] as String,
        title: map['baslik'] as String,
        message: map['mesaj'] as String,
        icon: map['ikon'] as String? ?? 'notifications',
        read: map['okundu'] as bool? ?? false,
        createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      );
}
