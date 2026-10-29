/// Bir modüle erişim (Supabase `my_access()` RPC'si; 20261130 P1 migration'ı).
///
/// Sunucu alanları: erisim ('tam' | 'sinirli' | 'onizleme' | 'yok'), gunluk_kota, kaynak, paket_kod.
/// Eksik ya da bilinmeyen değer her zaman kapalı (yok) sayılır: fail-closed.
enum ModulErisimSeviyesi { yok, onizleme, sinirli, tam }

class ModulErisim {
  const ModulErisim({
    required this.seviye,
    this.gunlukKota,
    this.paketKod,
  });

  /// Erişim yok: istemci tarafında kapalı varsayılan.
  static const kapali = ModulErisim(seviye: ModulErisimSeviyesi.yok);

  final ModulErisimSeviyesi seviye;
  final int? gunlukKota;
  final String? paketKod;

  /// İstenen seviyeye ulaşılıyor mu? "sinirli" yeterlidir "tam" için de.
  bool yeterli(ModulErisimSeviyesi gereken) => seviye.index >= gereken.index;

  factory ModulErisim.fromMap(Map<String, dynamic> m) {
    final ham = m['erisim'];
    final seviye = switch (ham) {
      'tam' => ModulErisimSeviyesi.tam,
      'sinirli' => ModulErisimSeviyesi.sinirli,
      'onizleme' => ModulErisimSeviyesi.onizleme,
      _ => ModulErisimSeviyesi.yok,
    };
    final kota = m['gunluk_kota'];
    return ModulErisim(
      seviye: seviye,
      gunlukKota: kota is int ? kota : null,
      paketKod: m['paket_kod'] as String?,
    );
  }
}
