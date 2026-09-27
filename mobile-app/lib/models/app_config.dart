// Uygulama geneli yapılandırması (bakım modu, zorunlu sürüm, reklam ayarları).
//
// Kaynak: public.get_app_config() RPC'si.
// Bu dosya, sunucudan gelen yapılandırmayı tipli bir nesneye çevirir.
// Alan adları birebir veritabanı / APK ile aynıdır; değiştirme.

/// Zorunlu güncelleme için platform bazlı minimum sürüm.
class MinSurum {
  const MinSurum({
    required this.android,
    required this.ios,
    required this.web,
    this.mesaj,
  });

  final String android;
  final String ios;
  final String web;

  /// Boşsa uygulama kendi varsayılan mesajını gösterir.
  final String? mesaj;

  /// Verilen sürüm için gereken minimum sürüm.
  String forPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return android;
      case 'ios':
        return ios;
      case 'web':
        return web;
      default:
        return android;
    }
  }

  factory MinSurum.fromMap(Map<String, dynamic> map) => MinSurum(
        android: map['android'] as String? ?? '1.0.0',
        ios: map['ios'] as String? ?? '1.0.0',
        web: map['web'] as String? ?? '1.0.0',
        mesaj: map['mesaj'] as String?,
      );
}

/// Bakım modu açıksa uygulama kilitlenir.
class BakimModu {
  const BakimModu({required this.aktif, this.mesaj});

  final bool aktif;

  /// Sunucudan gelen özel bakım metni; yoksa Hupo'nun varsayılanı kullanılır.
  final String? mesaj;

  factory BakimModu.fromMap(Map<String, dynamic> map) => BakimModu(
        aktif: map['aktif'] as bool? ?? false,
        mesaj: map['mesaj'] as String?,
      );
}

/// Reklam ve panel açık/kapalı ayarları.
///
/// Çocuk uygulaması olduğu için varsayılanlar KAPALI. Sunucudan 'true' gelirse
/// uygulama reklamı yine göstermez; yalnızca kimlik çözülür (aşağıya bak).
class ReklamAyarlari {
  const ReklamAyarlari({
    required this.ogrenciAcik,
    required this.veliPaneliAcik,
    this.admobAppIdAndroid,
    this.admobAppIdIos,
    this.admobBannerIdAndroid,
    this.admobBannerIdIos,
    this.adsensePublisherId,
    this.adsenseSlotId,
  });

  /// Öğrenci uygulamasında reklam gösterilsin mi.
  final bool ogrenciAcik;
  final bool veliPaneliAcik;

  final String? admobAppIdAndroid;
  final String? admobAppIdIos;
  final String? admobBannerIdAndroid;
  final String? admobBannerIdIos;
  final String? adsensePublisherId;
  final String? adsenseSlotId;

  /// Öğrenci uygulamasında banner gösterilebilir mi.
  ///
  /// Hem sunucu bayrağı açık olmalı hem de kimlik dolu olmalıdır.
  /// Böylece yanlışlıkla açılan bir bayrak boş reklam alanı bırakmaz.
  bool get ogrencideReklamAktif =>
      ogrenciAcik && (admobBannerIdAndroid?.isNotEmpty ?? false);

  String? bannerIdFor(String platform) {
    if (!ogrenciAcik) return null;
    return platform.toLowerCase() == 'ios'
        ? admobBannerIdIos
        : admobBannerIdAndroid;
  }

  factory ReklamAyarlari.fromMap(Map<String, dynamic> map) => ReklamAyarlari(
        ogrenciAcik: map['ogrenci_acik'] as bool? ?? false,
        veliPaneliAcik: map['veli_paneli_acik'] as bool? ?? false,
        admobAppIdAndroid: map['admob_app_id_android'] as String?,
        admobAppIdIos: map['admob_app_id_ios'] as String?,
        admobBannerIdAndroid: map['admob_banner_id_android'] as String?,
        admobBannerIdIos: map['admob_banner_id_ios'] as String?,
        adsensePublisherId: map['adsense_publisher_id'] as String?,
        adsenseSlotId: map['adsense_slot_id'] as String?,
      );
}

/// public.get_app_config() yanıtının tamamı.
class AppConfig {
  const AppConfig({
    required this.bakimModu,
    required this.minSurum,
    required this.reklamlar,
  });

  final BakimModu bakimModu;
  final MinSurum minSurum;
  final ReklamAyarlari reklamlar;

  /// Uygulama şu anda bakımda mı.
  bool get bakimda => bakimModu.aktif;

  factory AppConfig.fromMap(Map<String, dynamic> map) => AppConfig(
        bakimModu: BakimModu.fromMap(
          (map['bakim_modu'] as Map<String, dynamic>?) ?? const {},
        ),
        minSurum: MinSurum.fromMap(
          (map['min_surum'] as Map<String, dynamic>?) ?? const {},
        ),
        reklamlar: ReklamAyarlari.fromMap(
          (map['reklamlar'] as Map<String, dynamic>?) ?? const {},
        ),
      );

  /// Sunucuya ulaşılamadığında kullanılacak güvenli varsayılan.
  ///
  /// Reklamlar ve bakım modu KAPALI, sürüm şartı YOK. Yani ağ hatası çocuğu
  /// kilitlemez.
  static const varsayilan = AppConfig(
    bakimModu: BakimModu(aktif: false),
    minSurum: MinSurum(android: '0.0.0', ios: '0.0.0', web: '0.0.0'),
    reklamlar: ReklamAyarlari(
      ogrenciAcik: false,
      veliPaneliAcik: false,
    ),
  );
}
