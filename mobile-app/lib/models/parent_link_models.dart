/// Veli ↔ çocuk eşleştirme kodu sonucu (`redeem_parent_link_code` RPC'si).
///
/// Dönüş: {durum: 'baglandi', veli_ad} | {durum: 'gecersiz'} | {durum: 'cok_deneme'}.
enum ParentLinkStatus { baglandi, gecersiz, cokDeneme }

class ParentLinkResult {
  const ParentLinkResult({required this.durum, this.veliAd});

  final ParentLinkStatus durum;

  /// Yalnızca [ParentLinkStatus.baglandi] durumunda dolu.
  final String? veliAd;

  factory ParentLinkResult.fromMap(Map<String, dynamic> map) {
    final raw = map['durum'];
    final durum = switch (raw) {
      'baglandi' => ParentLinkStatus.baglandi,
      'gecersiz' => ParentLinkStatus.gecersiz,
      'cok_deneme' => ParentLinkStatus.cokDeneme,
      _ => throw FormatException('Bilinmeyen eşleştirme durumu: $raw'),
    };
    final ad = map['veli_ad']?.toString().trim();
    return ParentLinkResult(
      durum: durum,
      veliAd: (ad == null || ad.isEmpty) ? null : ad,
    );
  }
}
