/// Üyelik durumu (`my_subscription_status` RPC'si).
///
/// Çocuk hesabı, bağlı velinin üyeliğini görür (`source == 'veli'`).
/// Ayrıştırma bilinçli olarak hoşgörülüdür: eksik/bozuk alanlar hata değil,
/// "bilinmiyor" ya da boş değer olur; arayüzde alarm verici hiçbir şey çıkmaz.
class MembershipStatus {
  const MembershipStatus({
    this.known = true,
    this.active = false,
    this.planCode,
    this.planName,
    this.endsAt,
    this.remainingDays,
    this.totalDays,
    this.source,
    this.gatingActive = false,
    this.freeDailyQuestions,
    this.freeQuestionsLeftToday,
  });

  /// RPC yok / hata: hiçbir şey göstermeyiz.
  static const unknown = MembershipStatus(known: false);

  final bool known;
  final bool active;
  final String? planCode;
  final String? planName;
  final DateTime? endsAt;
  final int? remainingDays;

  /// Sunucu toplam süreyi gönderirse (isteğe bağlı `toplam_gun`) çubuk kesinleşir.
  final int? totalDays;

  /// 'kendi' | 'veli'
  final String? source;

  /// Ücretsiz kota uygulaması açık mı (yalnızca görüntülenir; istemci zorlamaz).
  final bool gatingActive;

  /// Günlük ücretsiz soru hakkı (`ucretsiz_gunluk_soru`).
  final int? freeDailyQuestions;

  /// Bugün kalan ücretsiz soru; yalnızca sunucu gönderirse dolu.
  final int? freeQuestionsLeftToday;

  bool get fromParent => source == 'veli';

  /// Kalan gün / toplam süre, 0.0 - 1.0. Toplam bilinmiyorsa en yakın standart
  /// süreye (30/90/180/365/730 gün) göre yaklaşık hesaplanır.
  double get progress {
    final left = remainingDays;
    if (!active || left == null || left <= 0) return 0;
    var total = totalDays;
    if (total == null || total <= 0) {
      total = const [30, 90, 180, 365, 730]
          .firstWhere((d) => d >= left, orElse: () => left);
    }
    return (left / total).clamp(0.0, 1.0).toDouble();
  }

  factory MembershipStatus.fromMap(Map<String, dynamic> map) {
    int? asInt(Object? v) => v is num ? v.toInt() : int.tryParse('$v');
    String? asStr(Object? v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    final endsRaw = asStr(map['bitis']);
    DateTime? ends;
    if (endsRaw != null) {
      final parsed = DateTime.tryParse(endsRaw);
      // Saat dilimi kaymasıyla gün değişmesin: tarihi yerel takvim günü olarak al.
      ends = parsed == null
          ? null
          : (endsRaw.length <= 10 ? parsed : parsed.toLocal());
    }
    final source = asStr(map['kaynak']);

    return MembershipStatus(
      active: map['aktif'] == true,
      planCode: asStr(map['plan_kod']),
      planName: asStr(map['plan_ad']),
      endsAt: ends,
      remainingDays: asInt(map['kalan_gun']),
      totalDays: asInt(map['toplam_gun']),
      source: (source == 'kendi' || source == 'veli') ? source : null,
      gatingActive: map['gating_aktif'] == true,
      freeDailyQuestions: asInt(map['ucretsiz_gunluk_soru']),
      freeQuestionsLeftToday: asInt(map['bugun_kalan_ucretsiz_soru']),
    );
  }
}
