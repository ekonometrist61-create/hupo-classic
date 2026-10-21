/// Genel semantik ikon kaydı (Okuma Dünyası ve PDF'ler için ortak).
///
/// Katalog `ikon_katalogu.g.dart` dosyasındadır ve `tool/ikon_katalogu_uret.dart` ile
/// manifestten üretilir. Bu dosya kimlik çözümlemeyi yapar: düz kimlik, eski emoji
/// kodları (`ipucu`, `kedi`…) ve ham emoji karakterleri aynı kavrama bağlanır. Böylece
/// mevcut hikâye içeriği değişmeden yeni, platformdan bağımsız ikonlara geçer.
library;

import 'ikon_katalogu.g.dart';

export 'ikon_katalogu.g.dart' show ikonKatalogu;

final class IkonKaydi {
  const IkonKaydi({
    required this.id,
    required this.kategori,
    required this.etiket,
    required this.etiketler,
    required this.sinifAraligi,
    required this.oncelik,
    required this.dekoratif,
    required this.satirIci,
    required this.renkliDosya,
    required this.sadeDosya,
  });

  final String id;
  final String kategori;

  /// Türkçe görünen ad; ekran okuyucu metni için de kullanılır.
  final String etiket;
  final List<String> etiketler;
  final String sinifAraligi;
  final String oncelik;

  /// Süs amaçlı mı? `false` ise anlamı taşır ve alternatif metin gerekir.
  final bool dekoratif;

  /// Metin satırının içinde kullanılabilir mi?
  final bool satirIci;

  /// Asset klasörüne göre dosya adları (`assets/okuma/hikaye_ikonlari/`).
  final String renkliDosya;
  final String sadeDosya;
}

/// Onaylı Hupo maskotu. Katalogda çizim yoktur; maskot kimliği korunur, yeniden çizilmez.
const kMaskotIkonKimligi = 'hupo';

/// Asset klasörü (pubspec ile aynı).
const kIkonVarlikKlasoru = 'assets/okuma/hikaye_ikonlari/';

/// Eski emoji kodları → katalog kimliği. Mevcut hikâye verisi bu kodları kullanır.
const _eskiKodlar = <String, String>{
  'ipucu': 'magnifier',
  'yildiz': 'star',
  'kitap': 'book',
  'anahtar': 'key',
  'hupo': kMaskotIkonKimligi,
  'roket': 'rocket',
  'kalp': 'heart',
  'kedi': 'cat',
  'kus': 'bird',
  'ay': 'moon',
  'bulut': 'cloud',
  'ucak': 'plane',
  'balik': 'fish',
  'orman': 'forest',
  'deniz': 'wave',
  'gunes': 'sun',
};

/// Ham emoji → katalog kimliği (varyasyon seçici U+FE0F çıkarıldıktan sonra aranır).
const _emojiler = <String, String>{
  '🔎': 'magnifier',
  '⭐': 'star',
  '📖': 'book',
  '🔑': 'key',
  '🦉': kMaskotIkonKimligi,
  '🚀': 'rocket',
  '💛': 'heart',
  '🐱': 'cat',
  '🐦': 'bird',
  '🌙': 'moon',
  '☁': 'cloud',
  '✈': 'plane',
  '🐟': 'fish',
  '🌲': 'forest',
  '🌊': 'wave',
  '☀': 'sun',
};

final Map<String, IkonKaydi> _kayitlar = {for (final k in ikonKatalogu) k.id: k};

/// Kimlikle kayıt bulur; bilinmeyen kimlik için `null` döner.
IkonKaydi? ikonBul(String id) => _kayitlar[id];

/// Verilen kaynağı (katalog kimliği, eski kod veya emoji) katalog kimliğine çözer.
/// Maskot için [kMaskotIkonKimligi] döner. Tanınmayan kaynak için `null`:
/// çağıran ikonu atlar, metin aynen kalır.
String? ikonKimligiCoz(String kaynak) {
  if (_kayitlar.containsKey(kaynak) || kaynak == kMaskotIkonKimligi) return kaynak;
  final eski = _eskiKodlar[kaynak];
  if (eski != null) return eski;
  return _emojiler[kaynak.replaceAll('️', '')];
}
