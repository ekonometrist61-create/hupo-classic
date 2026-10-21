// Okuma Dünyası: karakter ve ikon varlık manifesti (yalnız çözümleme; Flutter bağımlılığı yok).
//
// Manifest dosyaları `assets/okuma/karakter_manifest.json` ve `ikon_manifest.json`'dır.
// `uretildi == false` olan varlığın görsel dosyası yoktur; arayüz yedek ikona döner.

const String kOkumaVarlikKok = 'assets/okuma/';
const String kKarakterManifestYolu = '${kOkumaVarlikKok}karakter_manifest.json';
const String kIkonManifestYolu = '${kOkumaVarlikKok}ikon_manifest.json';

class OkumaKarakterVarligi {
  const OkumaKarakterVarligi({
    required this.id,
    required this.kategori,
    required this.etiket,
    required this.sinifMin,
    required this.sinifMax,
    required this.dosya,
    required this.aciklama,
    required this.uretildi,
    this.kartTuru,
  });

  final String id;
  final String kategori;
  final String etiket;
  final int sinifMin;
  final int sinifMax;

  /// `assets/okuma/` köküne göre yol.
  final String dosya;
  final String aciklama;
  final bool uretildi;

  /// Kahraman seçim kartında bu varlığın temsil edebileceği tür kodu (örn. `ben`).
  final String? kartTuru;

  String get varlikYolu => '$kOkumaVarlikKok$dosya';

  bool sinifaUygun(int sinif) => sinif >= sinifMin && sinif <= sinifMax;

  static OkumaKarakterVarligi? fromMap(Object? ham) {
    if (ham is! Map) return null;
    final id = ham['id'], kategori = ham['kategori'], etiket = ham['etiket'], dosya = ham['dosya'];
    final a = ham['sinifMin'], b = ham['sinifMax'];
    if (id is! String || kategori is! String || etiket is! String || dosya is! String || a is! int || b is! int) {
      return null;
    }
    return OkumaKarakterVarligi(
      id: id,
      kategori: kategori,
      etiket: etiket,
      sinifMin: a,
      sinifMax: b,
      dosya: dosya,
      aciklama: ham['aciklama'] is String ? ham['aciklama'] as String : '',
      uretildi: ham['uretildi'] == true,
      kartTuru: ham['kartTuru'] is String ? ham['kartTuru'] as String : null,
    );
  }
}

class OkumaIkonVarligi {
  const OkumaIkonVarligi({
    required this.id,
    required this.kategori,
    required this.etiket,
    required this.dosya,
    required this.uretildi,
  });

  final String id;
  final String kategori;
  final String etiket;
  final String dosya;
  final bool uretildi;

  String get varlikYolu => '$kOkumaVarlikKok$dosya';

  static OkumaIkonVarligi? fromMap(Object? ham) {
    if (ham is! Map) return null;
    final id = ham['id'], kategori = ham['kategori'], etiket = ham['etiket'], dosya = ham['dosya'];
    if (id is! String || kategori is! String || etiket is! String || dosya is! String) return null;
    return OkumaIkonVarligi(id: id, kategori: kategori, etiket: etiket, dosya: dosya, uretildi: ham['uretildi'] == true);
  }
}

/// Çözümlenmiş katalog. Bozuk satırlar atlanır; katalog hiçbir zaman istisna fırlatmaz.
class OkumaVarlikKatalogu {
  const OkumaVarlikKatalogu({this.karakterler = const [], this.ikonlar = const []});

  static const OkumaVarlikKatalogu bos = OkumaVarlikKatalogu();

  final List<OkumaKarakterVarligi> karakterler;
  final List<OkumaIkonVarligi> ikonlar;

  factory OkumaVarlikKatalogu.coz(Map<String, dynamic>? karakterManifest, Map<String, dynamic>? ikonManifest) {
    List<T> liste<T>(Map<String, dynamic>? m, String anahtar, T? Function(Object?) coz) {
      final ham = m?[anahtar];
      if (ham is! List) return const [];
      final sonuc = <T>[];
      for (final e in ham) {
        final v = coz(e);
        if (v != null) sonuc.add(v);
      }
      return sonuc;
    }

    return OkumaVarlikKatalogu(
      karakterler: liste(karakterManifest, 'karakterler', OkumaKarakterVarligi.fromMap),
      ikonlar: liste(ikonManifest, 'ikonlar', OkumaIkonVarligi.fromMap),
    );
  }

  /// Seçim kartında gösterilecek üretilmiş görsel; yoksa null (arayüz yedek ikona döner).
  OkumaKarakterVarligi? kartGorseli(String turKodu) {
    for (final k in karakterler) {
      if (k.uretildi && k.kartTuru == turKodu) return k;
    }
    return null;
  }

  OkumaIkonVarligi? ikon(String id) {
    for (final i in ikonlar) {
      if (i.id == id && i.uretildi) return i;
    }
    return null;
  }

  int get uretilenKarakter => karakterler.where((k) => k.uretildi).length;
  int get uretilenIkon => ikonlar.where((i) => i.uretildi).length;
}
