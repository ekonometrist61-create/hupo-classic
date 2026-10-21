// Okuma Dünyası: cihazda kalan veriler (SharedPreferences; mobil + web aynı kod).
//
// 1) Hikâye paketi önbelleği (ad içermez; son 20 hikâye, sha256 ile).
// 2) Cihaz tercihleri ve kişisel raflar: okuma modu, "Kahramanlarım", "Okuduklarım", son okuma.
//    Kişisel raflar hesap kimliğine bağlı anahtarla tutulur; başka hesabın rafı okunmaz,
//    çıkışta ve hesap değişiminde silinir.
// Kahraman/yol arkadaşı adı YALNIZ "Kahramanlarım" rafında, kullanıcı açıkça isterse saklanır.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/okuma_kahraman.dart';
import '../models/okuma_models.dart';

/// Önbellekte tutulan en çok hikâye sayısı.
const int kOkumaOnbellekSiniri = 20;

/// "Okuduklarım" rafındaki en çok kayıt.
const int kOkuduklarimSiniri = 50;

/// "Kahramanlarım" rafındaki en çok kahraman.
const int kKahramanlarimSiniri = 8;

/// "Sözlüğüm" rafındaki en çok kayıt.
const int kSozlugumSiniri = 100;

/// Kullanıcının "Sözlüğe ekle" ile kaydettiği atasözü veya deyim ve anlamı.
class OkumaSozlukKaydi {
  const OkumaSozlukKaydi({required this.metin, required this.anlam, required this.at});

  final String metin;
  final String anlam;
  final DateTime at;
}

const String _onbellekSiraAnahtari = 'okuma_onbellek_sira';
const String _paketOneki = 'okuma_paket_';
const String _kisiselOnek = 'okuma_kisisel_';

class OkumaPaketOnbellegi {
  const OkumaPaketOnbellegi(this._prefs);

  final SharedPreferences _prefs;

  List<String> _sira() => _prefs.getStringList(_onbellekSiraAnahtari) ?? const [];

  /// Önbellekteki paket. Bozuk kayıt sessizce yok sayılır ve silinir.
  OkumaPaketi? oku(String hikayeId) {
    final ham = _prefs.getString('$_paketOneki$hikayeId');
    if (ham == null) return null;
    try {
      return OkumaPaketi.fromMap(Map<String, dynamic>.from(jsonDecode(ham) as Map));
    } on Object {
      _prefs.remove('$_paketOneki$hikayeId');
      return null;
    }
  }

  /// Katalog satırındaki sha256 ile eşleşen paket varsa döner (indirme gerekmez).
  OkumaPaketi? gecerliPaket(OkumaKatalogSatiri satir) {
    final p = oku(satir.hikayeId);
    return p != null && p.sha256.isNotEmpty && p.sha256 == satir.sha256 ? p : null;
  }

  Future<void> yaz(OkumaPaketi paket) async {
    await _prefs.setString('$_paketOneki${paket.hikayeId}', jsonEncode(paket.toMap()));
    final sira = [..._sira()]..remove(paket.hikayeId);
    sira.add(paket.hikayeId);
    while (sira.length > kOkumaOnbellekSiniri) {
      await _prefs.remove('$_paketOneki${sira.removeAt(0)}');
    }
    await _prefs.setStringList(_onbellekSiraAnahtari, sira);
  }

  /// Önbellekteki hikâye kimlikleri (eskiden yeniye).
  List<String> get kimlikler => List.unmodifiable(_sira());
}

/// Okuma modu ve harf stili gibi cihaz tercihleri ile hesaba bağlı kişisel raflar.
class OkumaCihazDeposu {
  OkumaCihazDeposu(this._prefs, {required String? kullaniciId}) : _kimlik = kullaniciId ?? 'anonim';

  final SharedPreferences _prefs;
  final String _kimlik;

  static const String _modAnahtari = 'okuma_modu';
  static const String _buyukAnahtari = 'okuma_buyuk_yazi';
  static const String _lexendAnahtari = 'okuma_lexend';

  String _anahtar(String ad) => '$_kisiselOnek${ad}_$_kimlik';

  // ── Tercihler (hesaptan bağımsız, ad içermez) ──────────────────────────────

  /// 'sade' | 'zengin' (varsayılan zengin).
  String get okumaModu => _prefs.getString(_modAnahtari) == 'sade' ? 'sade' : 'zengin';

  Future<void> okumaModuYaz(String mod) => _prefs.setString(_modAnahtari, mod == 'sade' ? 'sade' : 'zengin');

  bool get buyukYazi => _prefs.getBool(_buyukAnahtari) ?? false;

  Future<void> buyukYaziYaz(bool deger) => _prefs.setBool(_buyukAnahtari, deger);

  /// null: kullanıcı seçmedi, uygulamanın genel yazı tipi ayarı geçerli.
  bool? get lexend => _prefs.getBool(_lexendAnahtari);

  Future<void> lexendYaz(bool deger) => _prefs.setBool(_lexendAnahtari, deger);

  // ── Kişisel raflar (hesap kimliğine bağlı) ─────────────────────────────────

  /// Başka hesaplara ait kişisel kayıtları siler (hesap değişimi, kapanmış oturum artığı).
  Future<void> baskaHesaplariTemizle() async {
    final bizimki = '_$_kimlik';
    for (final k in _prefs.getKeys().toList()) {
      if (k.startsWith(_kisiselOnek) && !k.endsWith(bizimki)) await _prefs.remove(k);
    }
  }

  /// Çıkışta çağrılır: bu hesabın tüm kişisel kayıtlarını (ad dahil) siler.
  Future<void> kisiselVerileriSil() async {
    for (final k in _prefs.getKeys().toList()) {
      if (k.startsWith(_kisiselOnek)) await _prefs.remove(k);
    }
  }

  /// "Sözlüğüm": kullanıcının açıkça eklediği kayıtlar, en yeni başta.
  List<OkumaSozlukKaydi> sozlugum() {
    final ham = _prefs.getString(_anahtar('sozlugum'));
    if (ham == null) return const [];
    try {
      return [
        for (final m in (jsonDecode(ham) as List))
          OkumaSozlukKaydi(
            metin: (m as Map)['metin'] as String,
            anlam: m['anlam'] as String,
            at: DateTime.parse(m['at'] as String),
          ),
      ];
    } on Object {
      return const [];
    }
  }

  bool sozlugumde(String metin) => sozlugum().any((k) => k.metin == metin);

  /// Aynı metin varsa yenisiyle değiştirilir (tekrar etmez); sınırı aşan en eski kayıt düşer.
  Future<void> sozlugeEkle(OkumaSozlukKaydi kayit) async {
    final liste = [kayit, for (final k in sozlugum()) if (k.metin != kayit.metin) k];
    if (liste.length > kSozlugumSiniri) liste.removeRange(kSozlugumSiniri, liste.length);
    await _prefs.setString(
      _anahtar('sozlugum'),
      jsonEncode([
        for (final k in liste) {'metin': k.metin, 'anlam': k.anlam, 'at': k.at.toIso8601String()},
      ]),
    );
  }

  List<KahramanSecimi> kahramanlarim() {
    final ham = _prefs.getString(_anahtar('kahramanlar'));
    if (ham == null) return const [];
    try {
      return [
        for (final m in (jsonDecode(ham) as List))
          if (KahramanSecimi.fromMap(Map<String, dynamic>.from(m as Map)) case final k?) k,
      ];
    } on Object {
      return const [];
    }
  }

  Future<void> kahramanKaydet(KahramanSecimi secim) async {
    final liste = [for (final k in kahramanlarim()) if (!k.ayniMi(secim)) k, secim];
    while (liste.length > kKahramanlarimSiniri) {
      liste.removeAt(0);
    }
    await _prefs.setString(_anahtar('kahramanlar'), jsonEncode([for (final k in liste) k.toMap()]));
  }

  Future<void> kahramanSil(KahramanSecimi secim) async {
    final liste = [for (final k in kahramanlarim()) if (!k.ayniMi(secim)) k];
    if (liste.isEmpty) {
      await _prefs.remove(_anahtar('kahramanlar'));
    } else {
      await _prefs.setString(_anahtar('kahramanlar'), jsonEncode([for (final k in liste) k.toMap()]));
    }
  }

  List<OkunanHikaye> okuduklarim() {
    final ham = _prefs.getString(_anahtar('okunanlar'));
    if (ham == null) return const [];
    try {
      return [
        for (final m in (jsonDecode(ham) as List))
          OkunanHikaye(
            satir: OkumaKatalogSatiri.fromMap(Map<String, dynamic>.from((m as Map)['satir'] as Map)),
            okunduAt: DateTime.parse(m['at'] as String),
          ),
      ];
    } on Object {
      return const [];
    }
  }

  /// Hikâye tamamlandığında çağrılır: raf güncellenir ve son okuma zamanı yazılır.
  Future<void> okunduYaz(OkumaKatalogSatiri satir, {required DateTime simdi}) async {
    final liste = [
      OkunanHikaye(satir: satir, okunduAt: simdi),
      for (final o in okuduklarim())
        if (o.satir.hikayeId != satir.hikayeId) o,
    ];
    if (liste.length > kOkuduklarimSiniri) liste.removeRange(kOkuduklarimSiniri, liste.length);
    await _prefs.setString(
      _anahtar('okunanlar'),
      jsonEncode([
        for (final o in liste) {'satir': o.satir.toMap(), 'at': o.okunduAt.toIso8601String()},
      ]),
    );
    await _prefs.setString(_anahtar('son_okuma'), simdi.toIso8601String());
  }

  DateTime? get sonOkuma {
    final ham = _prefs.getString(_anahtar('son_okuma'));
    return ham == null ? null : DateTime.tryParse(ham);
  }
}
