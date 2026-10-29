/// Bir modülün bugünkü ücretsiz kota durumu (`my_kota_durumu` RPC'si; 20261135).
/// Yalnız günlük kotası olan modüller gelir; tam erişim (sınırsız) modüller listede yoktur.
class ModulKota {
  const ModulKota({
    required this.gunlukKota,
    required this.kullanilan,
    required this.kalan,
  });

  final int gunlukKota;
  final int kullanilan;
  final int kalan;

  factory ModulKota.fromMap(Map<String, dynamic> m) {
    int sayi(Object? v) => v is int ? v : (v is num ? v.toInt() : 0);
    return ModulKota(
      gunlukKota: sayi(m['gunluk_kota']),
      kullanilan: sayi(m['kullanilan']),
      kalan: sayi(m['kalan']),
    );
  }
}
