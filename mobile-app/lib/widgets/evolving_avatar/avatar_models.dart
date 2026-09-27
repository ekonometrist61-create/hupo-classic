import 'package:flutter/painting.dart' show Color;

/// Avatarın evrim evreleri. TOPLAM XP'ye göre belirlenir ve asla geri gitmez
/// (XP düşmediği için). Haftalık yarışma liglerinden (Bronz Ligi vb.) BAĞIMSIZDIR;
/// karışıklık olmasın diye ekranda evre adı değil unvan gösterilir.
enum AvatarTier { bronz, gumus, altin, elmas, efsanevi }

/// Evreye ait metin, XP ve renk bilgileri.
extension AvatarTierInfo on AvatarTier {
  /// Bu evreye ulaşmak için gereken toplam XP.
  int get minXp => switch (this) {
        AvatarTier.bronz => 0,
        AvatarTier.gumus => 500,
        AvatarTier.altin => 1500,
        AvatarTier.elmas => 3500,
        AvatarTier.efsanevi => 7500,
      };

  /// Çocuğa gösterilen unvan.
  String get title => switch (this) {
        AvatarTier.bronz => 'Çaylak Alp',
        AvatarTier.gumus => 'Genç Kemankeş',
        AvatarTier.altin => 'Akıncı',
        AvatarTier.elmas => 'Siber Yeniçeri',
        AvatarTier.efsanevi => 'Efsanevi Anka',
      };

  /// Bu evrede açılan kostümün adı.
  String get costumeName => switch (this) {
        AvatarTier.bronz => 'Çaylak Atkısı',
        AvatarTier.gumus => 'Deri Şapka ve Yay',
        AvatarTier.altin => 'Akıncı Pelerini ve Sancağı',
        AvatarTier.elmas => 'Neon Siperlik',
        AvatarTier.efsanevi => 'Anka Kanatları ve Alevli Taç',
      };

  /// Ana renk (aura, rozet ve ilerleme çubuğu için).
  Color get primaryColor => switch (this) {
        AvatarTier.bronz => const Color(0xFFB87333),
        AvatarTier.gumus => const Color(0xFF8E9AAF),
        AvatarTier.altin => const Color(0xFFF2A900),
        AvatarTier.elmas => const Color(0xFF12B5CB),
        AvatarTier.efsanevi => const Color(0xFFFF7A00),
      };

  /// Yardımcı (vurgu / parlama) renk.
  Color get accentColor => switch (this) {
        AvatarTier.bronz => const Color(0xFFE9B384),
        AvatarTier.gumus => const Color(0xFFD5DBE1),
        AvatarTier.altin => const Color(0xFFFFE08A),
        AvatarTier.elmas => const Color(0xFF7CF3FF),
        AvatarTier.efsanevi => const Color(0xFFFFD54F),
      };

  /// Sonraki evre; son evrede null.
  AvatarTier? get next => index + 1 < AvatarTier.values.length
      ? AvatarTier.values[index + 1]
      : null;

  /// Sonraki evreye ulaşmak için gereken toplam XP; son evrede null.
  int? get nextTargetXp => next?.minXp;

  /// Yeni evreye geçince gösterilen kutlama cümlesi.
  String get unlockMessage =>
      'Tebrikler! $title unvanını ve $costumeName kostümünü kazandın!';
}

class AvatarEvolutionManager {
  const AvatarEvolutionManager._();

  /// Toplam XP'ye göre evre (eksi değerler bronz sayılır).
  static AvatarTier getTierFromXP(int xp) {
    var tier = AvatarTier.bronz;
    for (final t in AvatarTier.values) {
      if (xp >= t.minXp) tier = t;
    }
    return tier;
  }

  /// Sonraki evreye kalan XP; en üst evrede 0.
  static int xpToNextTier(int xp) {
    final target = getTierFromXP(xp).nextTargetXp;
    return target == null ? 0 : (target - xp).clamp(0, target);
  }

  /// Mevcut evre içindeki ilerleme (0.0 - 1.0); en üst evrede 1.
  static double progressInTier(int xp) {
    final tier = getTierFromXP(xp);
    final target = tier.nextTargetXp;
    if (target == null) return 1;
    final span = target - tier.minXp;
    return ((xp - tier.minXp) / span).clamp(0.0, 1.0).toDouble();
  }

  /// [from] evresinden [to] evresine geçiş bir yükselme mi?
  static bool isPromotion(AvatarTier from, AvatarTier to) => to.index > from.index;

  /// Sonraki evreyi anlatan motivasyon cümlesi.
  static String motivationText(int xp) {
    final tier = getTierFromXP(xp);
    final next = tier.next;
    if (next == null) {
      return 'Zirvedesin! ${tier.title} unvanı sonsuza kadar senin.';
    }
    return '${next.title} olmana ve ${next.costumeName} açmana '
        'sadece ${xpToNextTier(xp)} XP kaldı!';
  }
}
