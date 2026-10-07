// Karakter koleksiyonu modelleri.
// 8 sınıf × 5 karakter = 40 karakter.
// Kilit durumu sunucudan gelir; istemci asla kendi kendine açamaz.

import 'package:flutter/material.dart';

/// Bir koleksiyon karakterinin tanım ve kilit durumu.
class CharacterCard {
  const CharacterCard({
    required this.kod,
    required this.ad,
    required this.aciklama,
    required this.ikon,
    required this.sinif,
    required this.sinifSira,
    required this.karakterSira,
    required this.kosulTuru,
    required this.kosulDeger,
    required this.kazanildi,
    this.kazanildiAt,
  });

  factory CharacterCard.fromMap(Map<String, dynamic> m) => CharacterCard(
        kod: m['kod'] as String,
        ad: m['ad'] as String,
        aciklama: m['aciklama'] as String,
        ikon: m['ikon'] as String,
        sinif: KarakterSinifi.fromKod(m['sinif'] as String),
        sinifSira: (m['sinif_sira'] as num).toInt(),
        karakterSira: (m['karakter_sira'] as num).toInt(),
        kosulTuru: KosulTuru.fromKod(m['kosul_turu'] as String),
        kosulDeger: (m['kosul_deger'] as num).toInt(),
        kazanildi: m['kazanildi'] as bool? ?? false,
        kazanildiAt: m['kazanildi_at'] == null
            ? null
            : DateTime.parse(m['kazanildi_at'] as String),
      );

  final String kod;
  final String ad;
  final String aciklama;
  final String ikon;
  final KarakterSinifi sinif;
  final int sinifSira;
  final int karakterSira;
  final KosulTuru kosulTuru;
  final int kosulDeger;
  final bool kazanildi;
  final DateTime? kazanildiAt;

  /// karakter_sira (1-5) aynı zamanda nadirliktir: 1 = Sıradan … 5 = Mitik
  /// (bkz. KARAKTER_KOLEKSIYON_PLANI.md §4).
  KarakterNadirlik get nadirlik => KarakterNadirlik.fromSira(karakterSira);

  /// Flutter'da gösterilecek asset yolu: `assets/characters/sinif/kod.webp`.
  /// Sunucudaki `ikon` 'ozgur_ruh.png' biçiminde gelir; uzantı istemcide .webp'e çevrilir.
  String get assetPath {
    final kodAdi = ikon.replaceFirst(_uzantiDeseni, '');
    return 'assets/characters/${sinif.kod}/$kodAdi.webp';
  }

  static final _uzantiDeseni = RegExp(r'\.[A-Za-z0-9]+$');
}

/// Karakter sınıfı (8 adet).
enum KarakterSinifi {
  ozgurRuhlar('ozgur_ruhlar', '🦅 Özgür Ruhlar', Color(0xFF6C4DF6)),
  firtina('firtina', '🌪️ Fırtına', Color(0xFF2FB8FF)),
  kasifler('kasifler', '🏹 Kaşifler', Color(0xFFFFC533)),
  bozkir('bozkir', '🐺 Bozkır', Color(0xFFD4845A)),
  zihinUstalari('zihin_ustalari', '🧠 Zihin Ustaları', Color(0xFF9B59B6)),
  muhafizlar('muhafizlar', '🛡️ Muhafızlar', Color(0xFF22C58B)),
  ustalar('ustalar', '🏹 Ustalar', Color(0xFFE67E22)),
  efsaneler('efsaneler', '👑 Efsaneler', Color(0xFFFF5470));

  const KarakterSinifi(this.kod, this.ad, this.renk);

  final String kod;
  final String ad;
  final Color renk;

  static KarakterSinifi fromKod(String kod) =>
      KarakterSinifi.values.firstWhere(
        (s) => s.kod == kod,
        orElse: () => KarakterSinifi.ozgurRuhlar,
      );
}

/// Nadirlik: karakter_sira (sınıf içindeki 1-5 konumu) ile birebir eşlenir.
/// Üst nadirlikler koleksiyon ekranında daha belirgin çerçeve/rozet alır.
enum KarakterNadirlik {
  siradan(1, 'Sıradan', Color(0xFF9AA5B1)),
  nadir(2, 'Nadir', Color(0xFF4EA9D9)),
  epik(3, 'Epik', Color(0xFF9B59B6)),
  efsanevi(4, 'Efsanevi', Color(0xFFF5C842)),
  mitik(5, 'Mitik', Color(0xFFD63384));

  const KarakterNadirlik(this.sira, this.ad, this.renk);

  final int sira;
  final String ad;
  final Color renk;

  static KarakterNadirlik fromSira(int sira) => KarakterNadirlik.values.firstWhere(
        (n) => n.sira == sira,
        orElse: () => KarakterNadirlik.siradan,
      );
}

/// Kilit açma koşulu türü.
enum KosulTuru {
  baslangic('baslangic'),
  xp('xp'),
  streak('streak'),
  soruSayisi('soru_sayisi'),
  seviye('seviye'),
  dersBAsari('ders_basari');

  const KosulTuru(this.kod);

  final String kod;

  static KosulTuru fromKod(String kod) =>
      KosulTuru.values.firstWhere(
        (t) => t.kod == kod,
        orElse: () => KosulTuru.xp,
      );

  /// Kullanıcıya gösterilecek kısa açıklama.
  String aciklamaMetni(int deger) {
    switch (this) {
      case KosulTuru.baslangic:
        return 'Başlangıç karakteri';
      case KosulTuru.xp:
        return '$deger XP kazan';
      case KosulTuru.streak:
        return '$deger günlük seri yap';
      case KosulTuru.soruSayisi:
        return '$deger soru çöz';
      case KosulTuru.seviye:
        return '${_seviyeAdi(deger)} seviyesine ulaş';
      case KosulTuru.dersBAsari:
        return '$deger derste ustalaş';
    }
  }

  static String _seviyeAdi(int seviye) {
    switch (seviye) {
      case 1:
        return 'Bronz';
      case 2:
        return 'Gümüş';
      case 3:
        return 'Altın';
      case 4:
        return 'Elmas';
      case 5:
        return 'Efsanevi';
      default:
        return 'Seviye $seviye';
    }
  }
}

/// Bir sınıfın tüm 5 karakteri bir arada.
class KarakterSinifGrubu {
  const KarakterSinifGrubu({
    required this.sinif,
    required this.karakterler,
  });

  final KarakterSinifi sinif;
  final List<CharacterCard> karakterler;

  int get kazanilanSayi => karakterler.where((k) => k.kazanildi).length;
  bool get tamTamamlandi => kazanilanSayi == karakterler.length;

  static List<KarakterSinifGrubu> grupla(List<CharacterCard> tumKarakterler) {
    final gruplar = <String, List<CharacterCard>>{};
    for (final k in tumKarakterler) {
      gruplar.putIfAbsent(k.sinif.kod, () => []).add(k);
    }
    return [
      for (final sinif in KarakterSinifi.values)
        if (gruplar.containsKey(sinif.kod))
          KarakterSinifGrubu(
            sinif: sinif,
            karakterler: gruplar[sinif.kod]!
              ..sort((a, b) => a.karakterSira.compareTo(b.karakterSira)),
          ),
    ];
  }
}
