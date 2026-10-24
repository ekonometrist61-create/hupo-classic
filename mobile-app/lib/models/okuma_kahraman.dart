// Okuma Dünyası: kahraman seçimi (yalnız cihaz belleği).
//
// Gizlilik: [KahramanSecimi.ad] ve [KahramanSecimi.yoldasAd] sunucuya, günlüğe, Sentry'ye ve hata
// metinlerine ASLA gitmez. Sunucuya yalnız tür kodu (`kod`) ve "yol arkadaşı var mı" bilgisi gider.
// Cinsiyet sorusu yoktur.

/// Kahraman türleri (sunucudaki `izinli_turler` kodlarıyla birebir).
enum KahramanTuru { hazir, ben, anne, baba, kardes, arkadas, baskaBiri, hayvan, arac, hayali }

/// Hazır isim önerileri. Her türde çocuk kendi adını da yazabilir.
const Map<KahramanTuru, List<String>> kOnerilenIsimler = {
  KahramanTuru.hayvan: ['Kedi', 'Köpek', 'Tavşan', 'Kuş', 'Kaplumbağa', 'Balık'],
  KahramanTuru.arac: ['Roket', 'Tren', 'Balon', 'Kamyon', 'Gemi'],
  KahramanTuru.hayali: ['Gökkuşağı Perisi', 'Uzay Kedisi', 'Dev Kurbağa', 'Işık Muhafızı'],
};

/// "Hazır Hupo" kahramanının sabit adı.
const String kHazirKahramanAdi = 'Hupo';

extension KahramanTuruBilgi on KahramanTuru {
  String get kod => switch (this) {
        KahramanTuru.hazir => 'hazir',
        KahramanTuru.ben => 'ben',
        KahramanTuru.anne => 'anne',
        KahramanTuru.baba => 'baba',
        KahramanTuru.kardes => 'kardes',
        KahramanTuru.arkadas => 'arkadas',
        KahramanTuru.baskaBiri => 'baska_biri',
        KahramanTuru.hayvan => 'hayvan',
        KahramanTuru.arac => 'arac',
        KahramanTuru.hayali => 'hayali',
      };

  String get etiket => switch (this) {
        KahramanTuru.hazir => 'Hazır Hupo',
        KahramanTuru.ben => 'Ben',
        KahramanTuru.anne => 'Annem',
        KahramanTuru.baba => 'Babam',
        KahramanTuru.kardes => 'Kardeşim',
        KahramanTuru.arkadas => 'Arkadaşım',
        KahramanTuru.baskaBiri => 'Başka biri',
        KahramanTuru.hayvan => 'Hayvan',
        KahramanTuru.arac => 'Araç',
        KahramanTuru.hayali => 'Çizgi film tarzı karakter',
      };

  /// Bu türde ad zorunlu mu? "Hazır Hupo" kendi adıyla gider.
  bool get adIster => this != KahramanTuru.hazir;

  /// Allah, peygamber ve din büyükleri adları yalnız hayvan, araç ve hayalî karakterlerde yasaktır
  /// (K-0024, E-8). İnsan adı olarak serbesttir.
  bool get dinAdiYasakli =>
      this == KahramanTuru.hayvan || this == KahramanTuru.arac || this == KahramanTuru.hayali;

  static KahramanTuru? koddan(String? kod) {
    for (final t in KahramanTuru.values) {
      if (t.kod == kod) return t;
    }
    return null;
  }
}

/// Ekranın ürettiği seçim. Yalnız cihaz belleğinde yaşar.
class KahramanSecimi {
  const KahramanSecimi({required this.tur, required this.ad, this.yoldasAd});

  final KahramanTuru tur;
  final String ad;
  final String? yoldasAd;

  bool get yoldasVar => yoldasAd != null && yoldasAd!.trim().isNotEmpty;

  /// Aynı kahraman raftan mı geldi ya da raftakiyle aynı mı (kopya eklememek için).
  bool ayniMi(KahramanSecimi o) => tur == o.tur && ad == o.ad && yoldasAd == o.yoldasAd;

  Map<String, dynamic> toMap() => {'tur': tur.kod, 'ad': ad, if (yoldasAd != null) 'yoldas': yoldasAd};

  static KahramanSecimi? fromMap(Map<String, dynamic> m) {
    final tur = KahramanTuruBilgi.koddan(m['tur'] as String?);
    final ad = m['ad'];
    if (tur == null || ad is! String || ad.trim().isEmpty) return null;
    return KahramanSecimi(tur: tur, ad: ad, yoldasAd: m['yoldas'] as String?);
  }
}

/// Ad kuralı: 1–24 karakter; harf, boşluk, nokta, kesme ve kısa çizgi.
final RegExp _adKurali = RegExp(r"^\p{L}[\p{L} .'\-]{0,23}$", unicode: true);

const String kAdBos = 'Bir ad yaz.';
const String kAdUzun = 'En fazla 24 harf olabilir.';
const String kAdKarakter = 'Ad yalnızca harf, boşluk, kesme ya da kısa çizgiden oluşmalı.';
const String kAdYasakli = 'Bu ad kullanılamaz. Başka bir ad dene.';

/// Yasak ad listesi (K-0024, E-8). Liste kodda tutulur; yeni ad eklemek ya da çıkarmak kod incelemesi ister.
/// (a) Allah, peygamber ve din büyükleri: [KahramanTuruBilgi.dinAdiYasakli] türlerinde yasak.
/// (b) Küfür, hakaret ve cinsel sözcükler: tüm türlerde yasak.
/// (c) Bilinen çizgi film, oyun ve marka karakter adları: tüm türlerde yasak (telif).
/// (d) Kamuya açık gerçek kişilerin adları: tüm türlerde yasak.
/// Liste Türkçe harfler sadeleştirilmiş (ç→c, ş→s, ı→i ...) biçimde tutulur; ad sözcüklere bölünüp tam sözcük
/// olarak karşılaştırılır. Küfür kökleri çekimli biçimleri de yakalamak için başlangıç eşleşmesiyle kontrol edilir.
const Set<String> _dinAdlari = {
  'allah', 'tanri', 'peygamber', 'muhammed', 'mevlana', 'ebubekir', 'omer', 'osman', 'ali', 'hasan',
  'huseyin', 'fatima', 'aise', 'hatice', 'adem', 'nuh', 'ibrahim', 'musa', 'isa', 'davud', 'suleyman',
  'yusuf', 'meryem', 'cebrail', 'mikail', 'azrail',
};
const Set<String> _kufurAdlari = {
  'amk', 'aq', 'amcik', 'orospu', 'pic', 'sik', 'siktir', 'yarak', 'yarrak', 'got', 'ibne', 'kahpe',
  'gavat', 'pezevenk', 'surtuk', 'fahise', 'porno', 'seks', 'sex',
};
const List<String> _kufurKokleri = ['orospu', 'amcik', 'siktir', 'yarrak', 'pezevenk', 'surtuk', 'fahise', 'kahpe'];
const Set<String> _markaAdlari = {
  'pikachu', 'mickey', 'minnie', 'batman', 'superman', 'spiderman', 'pokemon', 'doraemon', 'naruto',
  'shrek', 'barbie', 'sonic', 'mario', 'hulk', 'goofy',
};
const Set<String> _gercekKisiAdlari = {
  'ataturk', 'tarkan', 'messi', 'ronaldo', 'ronaldinho', 'neymar', 'erdogan', 'obama', 'trump', 'putin',
  'hitler', 'elon', 'musk',
};

/// Ad sadeleştirme: Türkçe büyük/küçük harf ve ayırt edici harfler ASCII'ye indirilir.
String _sadelestir(String ad) {
  const harita = {'ç': 'c', 'ğ': 'g', 'ı': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u', 'â': 'a', 'î': 'i', 'û': 'u'};
  final kucuk = ad.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
  return kucuk.split('').map((c) => harita[c] ?? c).join();
}

bool _yasakliMi(String ad, {KahramanTuru? tur}) {
  final dinYasak = tur?.dinAdiYasakli ?? false;
  final sozcukler = _sadelestir(ad).split(RegExp(r'[^a-z]+')).where((s) => s.isNotEmpty);
  for (final s in sozcukler) {
    if (_kufurAdlari.contains(s) || _kufurKokleri.any(s.startsWith)) return true;
    if (_markaAdlari.contains(s) || _gercekKisiAdlari.contains(s)) return true;
    if (dinYasak && _dinAdlari.contains(s)) return true;
  }
  return false;
}

/// Ad hatası: null ise ad geçerlidir. [tur] verilirse türe özgü kurallar (din adları) da uygulanır.
String? adKontrol(String ad, {KahramanTuru? tur}) {
  final t = ad.trim();
  if (t.isEmpty) return kAdBos;
  if (t.runes.length > 24) return kAdUzun;
  if (!_adKurali.hasMatch(t)) return kAdKarakter;
  if (_yasakliMi(t, tur: tur)) return kAdYasakli;
  return null;
}
