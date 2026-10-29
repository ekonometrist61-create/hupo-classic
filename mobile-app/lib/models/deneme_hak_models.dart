/// Ücretsiz deneme durumu (`deneme_hak_durumu` RPC'si). Çocuk kendi hanesinin durumunu görür.
///
/// Ayrıştırma hoşgörülüdür: eksik alan hata değil, "bilinmiyor" ya da boş değerdir.
class DenemeHak {
  const DenemeHak({
    this.known = true,
    this.deneme = false,
    this.premium = false,
    this.bitis,
    this.sonBitis,
    this.kalanGun,
    this.ozellikler = const [],
  });

  /// RPC yok / hata: hiçbir şey gösterilmez.
  static const unknown = DenemeHak(known: false);

  final bool known;
  final bool deneme;
  final bool premium;
  final DateTime? bitis;
  final DateTime? sonBitis;
  final int? kalanGun;
  final List<DenemeOzellik> ozellikler;

  /// Deneme bitmiş ve hesap ücretli değilse "bitti" durumu.
  bool get bitti => known && !deneme && !premium && sonBitis != null;

  /// Sayaç yalnız kalan 5 veya daha az iken gösterilir (sınır kuralı; "son gün" dili yok).
  List<DenemeOzellik> get sayacGoster => ozellikler.where((o) => o.kalan <= 5).toList();

  factory DenemeHak.fromMap(Map<String, dynamic> map) {
    DateTime? tarih(Object? v) => v is String ? DateTime.tryParse(v) : null;
    final liste = map['ozellikler'];
    return DenemeHak(
      deneme: map['deneme'] == true,
      premium: map['premium'] == true,
      bitis: tarih(map['bitis']),
      sonBitis: tarih(map['son_bitis']),
      kalanGun: (map['kalan_gun'] as num?)?.toInt(),
      ozellikler: liste is List
          ? liste
              .whereType<Map>()
              .map((e) => DenemeOzellik.fromMap(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

/// Tek özelliğin sınırı ve kalan hakkı.
class DenemeOzellik {
  const DenemeOzellik({
    required this.ozellik,
    required this.sinir,
    required this.pencere,
    required this.kalan,
  });

  final String ozellik;
  final int sinir;
  final String pencere; // 'gunluk' | 'deneme'
  final int kalan;

  bool get gunluk => pencere == 'gunluk';

  factory DenemeOzellik.fromMap(Map<String, dynamic> m) => DenemeOzellik(
        ozellik: m['ozellik'] as String? ?? '',
        sinir: (m['sinir'] as num?)?.toInt() ?? 0,
        pencere: m['pencere'] as String? ?? 'gunluk',
        kalan: (m['kalan'] as num?)?.toInt() ?? 0,
      );

  /// Çocuğa gösterilen Türkçe ad.
  String get etiket => switch (ozellik) {
        'soru' => 'soru',
        'kelime_evreni' => 'Kelime Evreni',
        'carpim_sifresi' => 'çarpım adımı',
        'okuma_hikayesi' => 'okuma hikâyesi',
        'meydan_okuma' => 'meydan okuma',
        'deneme_sinavi' => 'deneme sınavı',
        _ => ozellik,
      };
}
