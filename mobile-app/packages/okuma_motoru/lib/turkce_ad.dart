/// Türkçe özel ad çekimi (F1).
///
/// Kapsam: 3. tekil, kesme işaretli çekim; 6 hal (yalın, belirtme, yönelme,
/// bulunma, ayrılma, ilgi). Ünlü uyumu son ünlüye göre yapılır.
/// Bilinen sınır: "ince l" istisnaları (Nihal, Hilal vb.) bu sürümde yok;
/// bunlar altın vektörlerle ayrıca doğrulanacak.
library;

enum Hal { yalin, belirtme, yonelme, bulunma, ayrilma, ilgi }

const _sertUnsuzler = 'fstkçşhp';
const _unluler = 'aeıioöuü';

/// Türkçe küçük harf dönüşümü: I→ı, İ→i (Dart'ın varsayılanı yanlış eşler).
String _kucukHarf(String s) => s.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();

/// Son ünlüye göre 2'li uyum: kalın → a, ince → e.
String _ikili(String sonUnlu) => 'aıou'.contains(sonUnlu) ? 'a' : 'e';

/// Son ünlüye göre 4'lü uyum: a/ı→ı, e/i→i, o/u→u, ö/ü→ü.
String _dortlu(String sonUnlu) {
  switch (sonUnlu) {
    case 'a':
    case 'ı':
      return 'ı';
    case 'e':
    case 'i':
      return 'i';
    case 'o':
    case 'u':
      return 'u';
    default:
      return 'ü';
  }
}

/// [ad] adına [hal] ekini getirir. Örn: ekle('Efe', Hal.yonelme) → "Efe'ye".
String ekle(String ad, Hal hal) {
  final temiz = ad.trim();
  if (temiz.isEmpty) throw ArgumentError('Ad boş olamaz.');
  if (hal == Hal.yalin) return temiz;

  final kucuk = _kucukHarf(temiz);
  final sonHarf = kucuk[kucuk.length - 1];
  final sonUnluMu = _unluler.contains(sonHarf);
  final sonUnlu = _sonUnlu(kucuk);
  final sert = _sertUnsuzler.contains(sonHarf);

  final String ek;
  switch (hal) {
    case Hal.yonelme:
      ek = (sonUnluMu ? 'y' : '') + _ikili(sonUnlu);
    case Hal.belirtme:
      ek = (sonUnluMu ? 'y' : '') + _dortlu(sonUnlu);
    case Hal.ilgi:
      ek = (sonUnluMu ? 'n' : '') + _dortlu(sonUnlu) + 'n';
    case Hal.bulunma:
      ek = (sert ? 't' : 'd') + _ikili(sonUnlu);
    case Hal.ayrilma:
      ek = (sert ? 't' : 'd') + _ikili(sonUnlu) + 'n';
    case Hal.yalin:
      ek = '';
  }
  return "$temiz'$ek";
}

String _sonUnlu(String kucuk) {
  for (var i = kucuk.length - 1; i >= 0; i--) {
    if (_unluler.contains(kucuk[i])) return kucuk[i];
  }
  throw ArgumentError('Adda ünlü yok: $kucuk');
}
