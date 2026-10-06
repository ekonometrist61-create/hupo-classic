// Uygulama genelinde kullanılan veri modelleri.

class Profile {
  const Profile({required this.id, required this.role, this.fullName});

  final String id;
  final String role; // 'veli' | 'ogrenci'
  final String? fullName;

  bool get isStudent => role == 'ogrenci';

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as String,
        role: map['role'] as String,
        fullName: map['full_name'] as String?,
      );
}

class StudentStats {
  const StudentStats({
    this.xp = 0,
    this.level = 1,
    this.streakCount = 0,
    this.lastActiveDate,
    this.shields = 0,
    this.aktifKarakter,
  });

  final int xp;
  final int level;
  final int streakCount;
  final DateTime? lastActiveDate;

  /// Kazanılmış seri kalkanı sayısı (0-2).
  final int shields;

  /// Çocuğun koleksiyondan seçtiği aktif karakterin kodu; seçilmemişse null.
  final String? aktifKarakter;

  /// Her seviye 100 XP (veritabanındaki kuralla aynı).
  double get levelProgress => (xp % 100) / 100;
  int get xpToNextLevel => 100 - (xp % 100);

  /// Son aktif gün dünden eskiyse seri kopmuştur; veritabanı bunu bir sonraki
  /// doğru cevapta sıfırlar, ekranda ise şimdiden 0 göstermek doğrudur.
  int streakAt(DateTime today) {
    final last = lastActiveDate;
    if (last == null) return 0;
    final t = DateTime(today.year, today.month, today.day);
    final l = DateTime(last.year, last.month, last.day);
    final gap = t.difference(l).inDays;
    if (gap <= 1) return streakCount;
    // Tam bir gün ara verildiyse ve kalkan varsa seri korunur (kalkan sonraki cevapta harcanır).
    if (gap == 2 && shields > 0) return streakCount;
    return 0;
  }

  factory StudentStats.fromMap(Map<String, dynamic> map) => StudentStats(
        xp: map['xp'] as int,
        level: map['level'] as int,
        streakCount: map['streak_count'] as int,
        lastActiveDate: map['last_active_date'] == null
            ? null
            : DateTime.parse(map['last_active_date'] as String),
        shields: (map['seri_kalkani'] as num?)?.toInt() ?? 0,
        aktifKarakter: map['aktif_karakter'] as String?,
      );
}

class Question {
  const Question({
    required this.id,
    required this.ders,
    required this.konu,
    required this.zorluk,
    required this.text,
    required this.options,
    this.altKonu,
  });

  final String id;
  final String ders;
  final String konu;
  final String? altKonu;
  final int zorluk; // 1 kolay, 2 orta, 3 zor
  final String text;

  /// Şık anahtarı (A, B, C...) → şık metni; anahtara göre sıralı.
  final Map<String, String> options;

  String get difficultyLabel => switch (zorluk) {
        1 => 'Kolay',
        2 => 'Orta',
        _ => 'Zor',
      };

  /// Soru başına verilen süre (saniye): kolay 45, orta 60, zor 90.
  int get timeLimitSeconds => switch (zorluk) {
        1 => 45,
        2 => 60,
        _ => 90,
      };

  factory Question.fromMap(Map<String, dynamic> map) {
    final raw = Map<String, dynamic>.from(map['siklar'] as Map);
    final keys = raw.keys.toList()..sort();
    return Question(
      id: map['id'] as String,
      ders: map['ders'] as String,
      konu: map['konu'] as String,
      altKonu: map['alt_konu'] as String?,
      zorluk: map['zorluk'] as int,
      text: map['soru_metni'] as String,
      options: {for (final k in keys) k: raw[k].toString()},
    );
  }
}

class SubjectInfo {
  const SubjectInfo({required this.ders, required this.questionCount});

  final String ders;
  final int questionCount;
}

/// public.submit_answer() fonksiyonunun sonucu.
class AnswerResult {
  const AnswerResult({
    required this.correct,
    required this.correctOption,
    required this.earnedXp,
    required this.xp,
    required this.level,
    required this.streakCount,
    this.steps = const [],
    this.timedOut = false,
    this.saved = true,
  });

  final bool correct;
  final String correctOption;
  final int earnedXp;
  final int xp;
  final int level;
  final int streakCount;

  /// Adım adım çözüm metni (boş olabilir).
  final List<String> steps;

  /// Süre dolduğu için cevap verilmedi.
  final bool timedOut;

  /// false: sunucuya ulaşılamadı, sonuç yalnızca ekranda gösteriliyor.
  final bool saved;

  factory AnswerResult.fromMap(Map<String, dynamic> map) => AnswerResult(
        correct: map['dogru_mu'] as bool,
        correctOption: map['dogru_sik'] as String,
        earnedXp: (map['kazanilan_xp'] as num).toInt(),
        xp: (map['xp'] as num).toInt(),
        level: (map['level'] as num).toInt(),
        streakCount: (map['streak_count'] as num).toInt(),
        steps: [
          for (final s in (map['cozum_adimlari'] as List? ?? const []))
            s.toString(),
        ],
        timedOut: map['sure_doldu'] as bool? ?? false,
      );

  /// Süre dolduğunda sunucuya yazılamazsa, quiz akışı kopmasın diye kullanılır.
  factory AnswerResult.unsavedTimeout(AnswerResult? previous) => AnswerResult(
        correct: false,
        correctOption: '',
        earnedXp: 0,
        xp: previous?.xp ?? 0,
        level: previous?.level ?? 1,
        streakCount: previous?.streakCount ?? 0,
        timedOut: true,
        saved: false,
      );
}

/// Bir rozetin kataloğu + öğrencinin durumu (public.get_student_badges()).
class BadgeInfo {
  const BadgeInfo({
    required this.code,
    required this.name,
    required this.description,
    required this.icon,
    required this.conditionType,
    required this.threshold,
    required this.earned,
    required this.progress,
    this.ders,
    this.minAttempts = 10,
    this.attempts,
    this.earnedAt,
  });

  final String code;
  final String name;

  /// Kazanma şartı (popup'ta gösterilir).
  final String description;

  /// Uygulamadaki ikon anahtarı (bkz. badge_icons.dart).
  final String icon;

  /// soru_sayisi | streak | seviye | xp | ders_basari
  final String conditionType;
  final int threshold;
  final String? ders;
  final int minAttempts;
  final bool earned;
  final DateTime? earnedAt;

  /// Şu anki değer (ders_basari için yüzde).
  final int progress;

  /// Yalnızca ders_basari: o derste çözülen deneme sayısı.
  final int? attempts;

  /// 0.0 - 1.0 arası ilerleme.
  double get progressFraction {
    if (earned) return 1;
    double ratio(num value, num target) =>
        target <= 0 ? 0 : (value / target).clamp(0.0, 1.0).toDouble();

    if (conditionType == 'ders_basari') {
      // İki şart birden gerekli: yeterli soru ve yeterli başarı; yavaş olan belirler.
      return [
        ratio(progress, threshold),
        ratio(attempts ?? 0, minAttempts),
      ].reduce((a, b) => a < b ? a : b);
    }
    return ratio(progress, threshold);
  }

  /// Popup'ta gösterilen teşvik cümlesi.
  String get encouragement {
    if (earned) return 'Tebrikler, bu rozeti hak ettin!';
    return progressFraction >= 0.5
        ? 'Az kaldı, neredeyse tamam!'
        : 'Adım adım ilerle, sen yaparsın!';
  }

  /// "18 / 25 soru" gibi ilerleme metni.
  String get progressLabel => switch (conditionType) {
        'soru_sayisi' => '$progress / $threshold soru',
        'streak' => '$progress / $threshold gün',
        'seviye' => 'Seviye $progress / $threshold',
        'xp' => '$progress / $threshold XP',
        'ders_basari' =>
          'Başarı %$progress / %$threshold  •  ${attempts ?? 0} / $minAttempts soru',
        _ => '$progress / $threshold',
      };

  factory BadgeInfo.fromMap(Map<String, dynamic> map) => BadgeInfo(
        code: map['kod'] as String,
        name: map['ad'] as String,
        description: map['aciklama'] as String,
        icon: map['ikon'] as String? ?? 'star',
        conditionType: map['kosul_turu'] as String,
        threshold: (map['esik'] as num).toInt(),
        ders: map['ders'] as String?,
        minAttempts: (map['min_deneme'] as num?)?.toInt() ?? 10,
        earned: map['kazanildi'] as bool? ?? false,
        earnedAt: map['kazanma_tarihi'] == null
            ? null
            : DateTime.parse(map['kazanma_tarihi'] as String).toLocal(),
        progress: (map['ilerleme'] as num?)?.toInt() ?? 0,
        attempts: (map['deneme'] as num?)?.toInt(),
      );
}
