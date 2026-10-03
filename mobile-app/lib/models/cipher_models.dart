// Çarpım Tablosu Şifreleri veri modelleri.
//
// Kaynak: public.get_carpim_sifreleri(), public.get_carpim_sifre_detay(),
//         public.submit_cipher_answer(), public.complete_cipher_stage() RPC'leri.
// APK sınıf adları: MathCipher, MathCipherDetail, CipherExample, CipherExercise,
//                   CipherTestItem, CipherStageProgress, CipherStageCompletion,
//                   CipherAnswerResult, CipherReminder.

/// Bir şifrenin adım adım çözülen örnek ders anlatımı.
class CipherExample {
  const CipherExample({
    required this.soru,
    this.adimlar = const [],
  });

  final String soru;
  final List<String> adimlar;

  factory CipherExample.fromMap(Map<String, dynamic> map) => CipherExample(
        soru: map['soru'] as String? ?? '',
        adimlar: [
          for (final a in (map['adimlar'] as List? ?? const [])) a.toString(),
        ],
      );

  Map<String, dynamic> toMap() => {
        'soru': soru,
        'adimlar': adimlar,
      };
}

/// Açık alıştırma sorusu (cevap istemcide bulunur, öğrenmeye yöneliktir).
class CipherExercise {
  const CipherExercise({
    required this.soru,
    required this.cevap,
    this.cozum = const [],
  });

  final String soru;
  final int cevap;
  final List<String> cozum;

  factory CipherExercise.fromMap(Map<String, dynamic> map) => CipherExercise(
        soru: map['soru'] as String? ?? '',
        cevap: (map['cevap'] as num?)?.toInt() ?? 0,
        cozum: [
          for (final c in (map['cozum'] as List? ?? const [])) c.toString(),
        ],
      );

  Map<String, dynamic> toMap() => {
        'soru': soru,
        'cevap': cevap,
        'cozum': cozum,
      };
}

/// Kapalı test sorusu (güvenlik gereği doğru cevap sunucuda saklanır, istemciye gönderilmez).
class CipherTestItem {
  const CipherTestItem({
    required this.soru,
  });

  final String soru;

  factory CipherTestItem.fromMap(Map<String, dynamic> map) => CipherTestItem(
        soru: map['soru'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'soru': soru,
      };
}

/// Öğrencinin bir şifredeki aşama ilerlemesi.
class CipherStageProgress {
  const CipherStageProgress({
    this.acikBitti = false,
    this.kapaliBitti = false,
    this.kapaliYildiz = 0,
    this.ogretti = false,
  });

  final bool acikBitti;
  final bool kapaliBitti;
  final int kapaliYildiz;
  final bool ogretti;

  factory CipherStageProgress.fromMap(Map<String, dynamic> map) =>
      CipherStageProgress(
        acikBitti: map['acik_bitti'] as bool? ?? false,
        kapaliBitti: map['kapali_bitti'] as bool? ?? false,
        kapaliYildiz: (map['kapali_yildiz'] as num?)?.toInt() ?? 0,
        ogretti: map['ogretti'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'acik_bitti': acikBitti,
        'kapali_bitti': kapaliBitti,
        'kapali_yildiz': kapaliYildiz,
        'ogretti': ogretti,
      };
}

/// Yanlış cevap verildiğinde gösterilen şifre hatırlatıcı kart verisi.
class CipherReminder {
  const CipherReminder({
    required this.isim,
    required this.tanim,
  });

  final String isim;
  final String tanim;

  factory CipherReminder.fromMap(Map<String, dynamic> map) => CipherReminder(
        isim: map['isim'] as String? ?? '',
        tanim: map['tanim'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'isim': isim,
        'tanim': tanim,
      };
}

/// public.submit_cipher_answer() RPC yanıtı.
class CipherAnswerResult {
  const CipherAnswerResult({
    required this.dogru,
    this.cozum = const [],
    this.sifreHatirlatma,
    this.ilkDeneme = true,
    this.yildizKazanildi = false,
  });

  final bool dogru;
  final List<String> cozum;
  final CipherReminder? sifreHatirlatma;
  final bool ilkDeneme;
  final bool yildizKazanildi;

  factory CipherAnswerResult.fromMap(Map<String, dynamic> map) =>
      CipherAnswerResult(
        dogru: map['dogru'] as bool? ?? false,
        cozum: [
          for (final c in (map['cozum'] as List? ?? const [])) c.toString(),
        ],
        sifreHatirlatma: map['sifre_hatirlatma'] is Map<String, dynamic>
            ? CipherReminder.fromMap(
                map['sifre_hatirlatma'] as Map<String, dynamic>)
            : null,
        ilkDeneme: map['ilk_deneme'] as bool? ?? true,
        yildizKazanildi: map['yildiz_kazanildi'] as bool? ?? false,
      );
}

/// public.complete_cipher_stage() veya public.report_taught_friend() sonucu.
class CipherStageCompletion {
  const CipherStageCompletion({
    this.yeniRozetler = const [],
  });

  final List<String> yeniRozetler;

  factory CipherStageCompletion.fromMap(Map<String, dynamic> map) =>
      CipherStageCompletion(
        yeniRozetler: [
          for (final r in (map['yeni_rozetler'] as List? ?? const []))
            r.toString(),
        ],
      );
}

/// Şifre listesindeki özet kart modeli (public.get_carpim_sifreleri()).
class MathCipher {
  const MathCipher({
    required this.id,
    required this.sira,
    required this.anahtar,
    required this.isim,
    required this.ikon,
    required this.renk,
    required this.kapsam,
    required this.kesif,
    required this.tanim,
    required this.formul,
    this.ornek,
    this.alistirmaSayisi = 0,
    this.testSayisi = 0,
    this.durum = 'acildi',
    this.yildiz = 0,
    this.ogretti = false,
  });

  final String id;
  final int sira;
  final String anahtar;
  final String isim;
  final String ikon;
  final String renk;
  final String kapsam;
  final String kesif;
  final String tanim;
  final String formul;
  final CipherExample? ornek;
  final int alistirmaSayisi;
  final int testSayisi;
  final String durum; // 'acildi' | 'alistirma_tamam' | 'tamamlandi'
  final int yildiz;
  final bool ogretti;

  bool get isCompleted => durum == 'tamamlandi';
  bool get isExerciseCompleted => durum == 'alistirma_tamam' || isCompleted;

  factory MathCipher.fromMap(Map<String, dynamic> map) => MathCipher(
        id: map['id'] as String,
        sira: (map['sira'] as num).toInt(),
        anahtar: map['anahtar'] as String,
        isim: map['isim'] as String,
        ikon: map['ikon'] as String? ?? 'key',
        renk: map['renk'] as String? ?? '#4F46E5',
        kapsam: map['kapsam'] as String? ?? '',
        kesif: map['kesif'] as String? ?? '',
        tanim: map['tanim'] as String? ?? '',
        formul: map['formul'] as String? ?? '',
        ornek: map['ornek'] is Map<String, dynamic>
            ? CipherExample.fromMap(map['ornek'] as Map<String, dynamic>)
            : null,
        alistirmaSayisi: (map['alistirma_sayisi'] as num?)?.toInt() ?? 0,
        testSayisi: (map['test_sayisi'] as num?)?.toInt() ?? 0,
        durum: map['durum'] as String? ?? 'acildi',
        yildiz: (map['yildiz'] as num?)?.toInt() ?? 0,
        ogretti: map['ogretti'] as bool? ?? false,
      );
}

/// Bir şifrenin tüm detayları (public.get_carpim_sifre_detay()).
class MathCipherDetail {
  const MathCipherDetail({
    required this.id,
    required this.sira,
    required this.anahtar,
    required this.isim,
    required this.ikon,
    required this.renk,
    required this.kapsam,
    required this.kesif,
    required this.tanim,
    required this.formul,
    required this.ornek,
    this.alistirma = const [],
    this.test = const [],
    required this.progress,
  });

  final String id;
  final int sira;
  final String anahtar;
  final String isim;
  final String ikon;
  final String renk;
  final String kapsam;
  final String kesif;
  final String tanim;
  final String formul;
  final CipherExample ornek;
  final List<CipherExercise> alistirma;
  final List<CipherTestItem> test;
  final CipherStageProgress progress;

  factory MathCipherDetail.fromMap(Map<String, dynamic> map) =>
      MathCipherDetail(
        id: map['id'] as String,
        sira: (map['sira'] as num).toInt(),
        anahtar: map['anahtar'] as String,
        isim: map['isim'] as String,
        ikon: map['ikon'] as String? ?? 'key',
        renk: map['renk'] as String? ?? '#4F46E5',
        kapsam: map['kapsam'] as String? ?? '',
        kesif: map['kesif'] as String? ?? '',
        tanim: map['tanim'] as String? ?? '',
        formul: map['formul'] as String? ?? '',
        ornek: CipherExample.fromMap(
          (map['ornek'] as Map<String, dynamic>?) ?? const {},
        ),
        alistirma: [
          for (final a in (map['alistirma'] as List? ?? const []))
            CipherExercise.fromMap(Map<String, dynamic>.from(a as Map)),
        ],
        test: [
          for (final t in (map['test'] as List? ?? const []))
            CipherTestItem.fromMap(Map<String, dynamic>.from(t as Map)),
        ],
        progress: CipherStageProgress.fromMap(
          (map['progress'] as Map<String, dynamic>?) ?? const {},
        ),
      );
}
