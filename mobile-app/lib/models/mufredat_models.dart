// Müfredat yolu modelleri (public.get_mufredat_haritasi jsonb yanıtı).
// Sözleşme: docs/mufredat/PLAN_HAFTA_ETIKETLEME.md §4.2.

int? _asInt(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

DateTime? _asDate(Object? v) => v is String ? DateTime.tryParse(v) : null;

/// Bir kazanım ve kullanıcının o kazanımdaki sayıları.
class MufredatKazanim {
  const MufredatKazanim({
    required this.kod,
    required this.metin,
    this.ilkHafta,
    this.soruSayisi = 0,
    this.cevaplanan = 0,
    this.dogru = 0,
  });

  final String kod;
  final String metin;

  /// Kazanımın ilk işlendiği hafta; bilinmiyorsa null.
  final int? ilkHafta;

  /// Onaylı ve bu kazanıma etiketli soru sayısı.
  final int soruSayisi;

  /// Kullanıcının bu kazanımdaki toplam cevabı.
  final int cevaplanan;
  final int dogru;

  /// Doğruluk oranı yalnız [yeterliEsik] cevaptan sonra hesaplanır (veli panelindeki kuralla aynı).
  static const int yeterliEsik = 6;

  bool get sorusuVar => soruSayisi > 0;

  /// [bugun] haftası dahil ve öncesinde işlenmiş mi. [bugun] 0 ise hiçbiri işlenmiş sayılmaz.
  bool islendi(int bugun) {
    final ilk = ilkHafta;
    return bugun > 0 && ilk != null && ilk <= bugun;
  }

  /// Yüzde (0-100). [oranGosterilir] false ise (1–4. sınıf) ya da yeterli cevap yoksa null.
  int? oranYuzde(bool oranGosterilir) {
    if (!oranGosterilir || cevaplanan == 0 || cevaplanan < yeterliEsik) return null;
    return (dogru * 100 / cevaplanan).round();
  }

  factory MufredatKazanim.fromMap(Map<String, dynamic> map) => MufredatKazanim(
        kod: map['kod'] as String? ?? '',
        metin: map['metin'] as String? ?? '',
        ilkHafta: _asInt(map['ilk_hafta']),
        soruSayisi: _asInt(map['soru_sayisi']) ?? 0,
        cevaplanan: _asInt(map['cevaplanan']) ?? 0,
        dogru: _asInt(map['dogru']) ?? 0,
      );
}

/// Bir okul haftası: tarih aralığı, ünite/tema, konular ve kazanımlar.
class MufredatHafta {
  const MufredatHafta({
    required this.hafta,
    this.baslangic,
    this.bitis,
    this.tatil = false,
    this.uniteTema,
    this.konular = const [],
    this.kazanimlar = const [],
  });

  final int hafta;
  final DateTime? baslangic;
  final DateTime? bitis;
  final bool tatil;
  final String? uniteTema;
  final List<String> konular;
  final List<MufredatKazanim> kazanimlar;

  factory MufredatHafta.fromMap(Map<String, dynamic> map) => MufredatHafta(
        hafta: _asInt(map['hafta']) ?? 0,
        baslangic: _asDate(map['baslangic']),
        bitis: _asDate(map['bitis']),
        tatil: map['tatil'] as bool? ?? false,
        uniteTema: map['unite_tema'] as String?,
        konular: [
          for (final k in (map['konular'] as List? ?? const [])) k.toString(),
        ],
        kazanimlar: [
          for (final k in (map['kazanimlar'] as List? ?? const []))
            MufredatKazanim.fromMap(Map<String, dynamic>.from(k as Map)),
        ],
      );
}

/// Bir dersin müfredat haritası. [bugunHafta] null ise hangi haftada olunduğu bilinmiyor.
class MufredatHaritasi {
  const MufredatHaritasi({
    required this.ders,
    this.sinif,
    this.bugunHafta,
    this.haftalar = const [],
  });

  final String ders;

  /// Öğrencinin sınıfı (sunucudan). 1–4 ve 8 dışındaki değerlerde oran gösterimi kuralı için kullanılır.
  final int? sinif;
  final int? bugunHafta;
  final List<MufredatHafta> haftalar;

  /// Bugünkü hafta; bilinmiyorsa 0 (hiçbir hafta işlenmiş sayılmaz).
  int get bugun => bugunHafta ?? 0;

  /// Doğruluk yüzdesi yalnız 5–8. sınıfta gösterilir; sınıf bilinmiyorsa gösterilmez.
  bool get oranGosterilir {
    final s = sinif;
    return s != null && s >= 5 && s <= 8;
  }

  /// Hiçbir kazanımda onaylı soru yok.
  bool get hicSoruYok => haftalar.every(
        (h) => h.kazanimlar.every((k) => !k.sorusuVar),
      );

  factory MufredatHaritasi.fromMap(Map<String, dynamic> map) => MufredatHaritasi(
        ders: map['ders'] as String? ?? '',
        sinif: _asInt(map['sinif']),
        bugunHafta: _asInt(map['bugun_hafta']),
        haftalar: [
          for (final h in (map['haftalar'] as List? ?? const []))
            MufredatHafta.fromMap(Map<String, dynamic>.from(h as Map)),
        ],
      );
}
