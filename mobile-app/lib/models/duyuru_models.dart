// Yönetim panelinden yayınlanan duyuru. `get_aktif_duyuru` yanıtının modeli.
//
// Yetkili kurallar sunucudadır (20261026000000 ve 20261030000000_duyuru_yuzeyler.sql).
// Buradaki kontroller yalnızca bozuk veriyi ekrana taşımamak içindir.

/// Duyuru: kimlik, başlık, metin ve (varsa) bitiş zamanı.
class Duyuru {
  const Duyuru({
    required this.id,
    required this.baslik,
    required this.metin,
    this.bitisAt,
  });

  final String id;
  final String baslik;
  final String metin;
  final DateTime? bitisAt;

  /// Eksik, boş veya tipi uymayan alan varsa null (duyuru gösterilmez).
  /// Geçersiz bitiş zamanı duyuruyu bozmaz; yalnızca bitiş bilgisi düşer.
  static Duyuru? fromJson(Object? ham) {
    if (ham is! Map) return null;
    final id = ham['id'];
    final baslik = ham['baslik'];
    final metin = ham['metin'];
    if (id is! String || id.trim().isEmpty) return null;
    if (baslik is! String || baslik.trim().isEmpty) return null;
    if (metin is! String || metin.trim().isEmpty) return null;

    final bitisHam = ham['bitis_at'];
    DateTime? bitis;
    if (bitisHam is String) bitis = DateTime.tryParse(bitisHam);

    return Duyuru(
      id: id.trim(),
      baslik: baslik.trim(),
      metin: metin.trim(),
      bitisAt: bitis,
    );
  }
}
