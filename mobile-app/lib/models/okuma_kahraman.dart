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

/// Ad hatası: null ise ad geçerlidir.
String? adKontrol(String ad) {
  final t = ad.trim();
  if (t.isEmpty) return kAdBos;
  if (t.runes.length > 24) return kAdUzun;
  if (!_adKurali.hasMatch(t)) return kAdKarakter;
  return null;
}
