// Veli anketleri: `anket_aktif_listem` yanıtının modeli ve yanıt kuralları.
//
// Yetkili kurallar sunucudadır: 20261007000030 (_anket_sorulari_hatasi, anket_yanit_gonder)
// ve 20261029000000_anket_yuzeyler.sql. Buradaki kontroller yalnızca arayüzü yönlendirir:
// tanınmayan veya bozuk bir soru sessizce atlanır, sunucu her yanıtı yeniden doğrular.

/// Soru türleri. Sunucudaki `tur` değerleriyle birebir eşleşir.
enum AnketSoruTuru { kisaMetin, uzunMetin, tekSecim, nps, csat, onay }

/// Koşul operatörü (sunucu yalnızca lte / gte / eq kabul eder).
enum AnketKosulOp { lte, gte, eq }

AnketSoruTuru? _soruTuruCevir(Object? ham) => switch (ham) {
      'kisa_metin' => AnketSoruTuru.kisaMetin,
      'uzun_metin' => AnketSoruTuru.uzunMetin,
      'tek_secim' => AnketSoruTuru.tekSecim,
      'nps' => AnketSoruTuru.nps,
      'csat' => AnketSoruTuru.csat,
      'onay' => AnketSoruTuru.onay,
      _ => null,
    };

AnketKosulOp? _kosulOpCevir(Object? ham) => switch (ham) {
      'lte' => AnketKosulOp.lte,
      'gte' => AnketKosulOp.gte,
      'eq' => AnketKosulOp.eq,
      _ => null,
    };

/// Metin yanıtının sunucu üst sınırı (karakter).
const int kAnketMetinUstSiniri = 2000;

/// Bir sorunun yalnızca önceki bir sorunun sayısal yanıtına bağlı olması.
class AnketKosulu {
  const AnketKosulu({required this.sorusuId, required this.op, required this.deger});

  final String sorusuId;
  final AnketKosulOp op;
  final num deger;

  /// Bağlı sorunun yanıtı yoksa ya da sayısal değilse koşul sağlanmış sayılmaz.
  bool karsilanir(Object? yanit) {
    if (yanit is! num) return false;
    return switch (op) {
      AnketKosulOp.lte => yanit <= deger,
      AnketKosulOp.gte => yanit >= deger,
      AnketKosulOp.eq => yanit == deger,
    };
  }

  static AnketKosulu? fromJson(Object? ham) {
    if (ham is! Map) return null;
    final soruId = ham['soru_id'];
    final op = _kosulOpCevir(ham['op']);
    final deger = ham['deger'];
    if (soruId is! String || soruId.isEmpty || op == null || deger is! num) return null;
    return AnketKosulu(sorusuId: soruId, op: op, deger: deger);
  }
}

class AnketSorusu {
  const AnketSorusu({
    required this.id,
    required this.tur,
    required this.baslik,
    this.secenekler = const [],
    this.kosul,
  });

  final String id;
  final AnketSoruTuru tur;
  final String baslik;

  /// Yalnızca [AnketSoruTuru.tekSecim] için (en az 2).
  final List<String> secenekler;
  final AnketKosulu? kosul;

  /// Koşul, o anda kabul edilmiş yanıtlara göre sağlanıyor mu.
  /// Koşulsuz sorular her zaman görünür.
  bool gorunur(Map<String, Object> kabulEdilen) {
    final k = kosul;
    if (k == null) return true;
    return k.karsilanir(kabulEdilen[k.sorusuId]);
  }

  /// Sunucunun kabul edeceği biçim: nps 0-10 tam sayı, csat 1-5 tam sayı,
  /// onay bool, tek_secim seçeneklerden biri, metinler en fazla 2000 karakter.
  bool degerGecerli(Object deger) => switch (tur) {
        AnketSoruTuru.nps => deger is int && deger >= 0 && deger <= 10,
        AnketSoruTuru.csat => deger is int && deger >= 1 && deger <= 5,
        AnketSoruTuru.onay => deger is bool,
        AnketSoruTuru.tekSecim => deger is String && secenekler.contains(deger),
        AnketSoruTuru.kisaMetin ||
        AnketSoruTuru.uzunMetin =>
          deger is String && deger.isNotEmpty && deger.length <= kAnketMetinUstSiniri,
      };

  /// Tanınmayan tür, bozuk alan veya ayrıştırılamayan koşul → null (soru atlanır).
  static AnketSorusu? fromJson(Object? ham) {
    if (ham is! Map) return null;
    final id = ham['id'];
    final tur = _soruTuruCevir(ham['tur']);
    final baslik = ham['baslik'];
    if (id is! String || id.isEmpty || tur == null) return null;
    if (baslik is! String || baslik.trim().isEmpty) return null;

    final secenekHam = ham['secenekler'];
    final secenekler = <String>[];
    if (secenekHam is List) {
      for (final s in secenekHam) {
        if (s is String && s.isNotEmpty) secenekler.add(s);
      }
    }
    if (tur == AnketSoruTuru.tekSecim && secenekler.length < 2) return null;

    final kosulHam = ham['kosul'];
    AnketKosulu? kosul;
    if (kosulHam != null) {
      kosul = AnketKosulu.fromJson(kosulHam);
      if (kosul == null) return null;
    }

    return AnketSorusu(
      id: id,
      tur: tur,
      baslik: baslik.trim(),
      secenekler: secenekler,
      kosul: kosul,
    );
  }
}

class Anket {
  const Anket({
    required this.id,
    required this.ad,
    required this.anonim,
    required this.surum,
    required this.sorular,
  });

  final String id;
  final String ad;

  /// true ise yanıt kimlikle ilişkilendirilmez (sunucu veli_id yazmaz).
  final bool anonim;

  /// Sorular değişince artar; erteleme anahtarı sürüme bağlıdır.
  final int surum;
  final List<AnketSorusu> sorular;

  String get ertelemeAnahtari => '$id:$surum';

  /// Bozuk anket (kimliksiz, anonimlik belirsiz, hiç geçerli sorusu yok) → null.
  /// Koşulun bağlı olduğu soru atlandıysa koşullu soru da atlanır.
  static Anket? fromJson(Object? ham) {
    if (ham is! Map) return null;
    final id = ham['id'];
    final ad = ham['ad'];
    final anonim = ham['anonim'];
    final surum = ham['surum'];
    if (id is! String || id.isEmpty) return null;
    if (ad is! String || ad.trim().isEmpty) return null;
    if (anonim is! bool) return null;
    if (surum is! num) return null;

    final sorularHam = ham['sorular'];
    if (sorularHam is! List) return null;

    final sorular = <AnketSorusu>[];
    final gorulen = <String>{};
    for (final s in sorularHam) {
      final soru = AnketSorusu.fromJson(s);
      if (soru == null || gorulen.contains(soru.id)) continue;
      final kosul = soru.kosul;
      if (kosul != null && !gorulen.contains(kosul.sorusuId)) continue;
      gorulen.add(soru.id);
      sorular.add(soru);
    }
    if (sorular.isEmpty) return null;

    return Anket(
      id: id,
      ad: ad.trim(),
      anonim: anonim,
      surum: surum.toInt(),
      sorular: List.unmodifiable(sorular),
    );
  }
}

/// `anket_aktif_listem` dizisini ayrıştırır; bozuk öğeler atlanır.
List<Anket> anketListesiFromJson(Object? ham) {
  if (ham is! List) return const [];
  final liste = <Anket>[];
  for (final a in ham) {
    final anket = Anket.fromJson(a);
    if (anket != null) liste.add(anket);
  }
  return liste;
}

/// Bir anketin ekranda gösterilecek soruları ve gönderilecek yanıtları.
///
/// Sorular sırayla değerlendirilir: koşul yalnızca önceden kabul edilmiş bir
/// sayısal yanıtla sağlanır. Görünmeyen sorunun değeri, ekranda kalmış olsa bile
/// gönderilmez (sunucu bu yanıtları reddeder).
class AnketDegerlendirme {
  AnketDegerlendirme._(this.gorunenSorular, this.gecerliYanitlar);

  final List<AnketSorusu> gorunenSorular;

  /// Gönderilecek yanıtlar: yalnızca görünen, boş olmayan ve biçimi geçerli olanlar.
  final Map<String, Object> gecerliYanitlar;

  bool get gonderilebilir => gecerliYanitlar.isNotEmpty;

  factory AnketDegerlendirme.hesapla(List<AnketSorusu> sorular, Map<String, Object?> ham) {
    final gorunen = <AnketSorusu>[];
    final kabul = <String, Object>{};
    for (final soru in sorular) {
      if (!soru.gorunur(kabul)) continue;
      gorunen.add(soru);

      final ilk = ham[soru.id];
      final deger = ilk is String ? ilk.trim() : ilk;
      if (deger == null) continue;
      if (!soru.degerGecerli(deger)) continue;
      kabul[soru.id] = deger;
    }
    return AnketDegerlendirme._(List.unmodifiable(gorunen), Map.unmodifiable(kabul));
  }
}
