// Okuma Dünyası ("Senin Hikâyen"): Supabase RPC katmanı.
// Sözleşme: OKUMA_RPC_SOZLESMESI.md; migration: supabase/migrations/202610500*.sql.
//
// Gizlilik kuralı: Bu katman kahraman ya da yol arkadaşı adı ALMAZ. Metin parametreleri
// yalnız kod listesidir (kahraman_turu, okuma_modu, anket kodları). Hata mesajları sabittir;
// sunucu metni ya da herhangi bir ad kullanıcıya, günlüğe ya da Sentry'ye taşınmaz.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/okuma_models.dart';

enum OkumaHatasi {
  kapali,
  hikayeBulunamadi,
  kotaDoldu,
  hizSiniri,
  cakisma,
  gecersizIstek,
  oturumYok,
  oturumKapali,
  motorEski,
  baglanti,
  bilinmeyen,
}

class OkumaException implements Exception {
  const OkumaException(this.hata, this.mesaj);

  final OkumaHatasi hata;
  final String mesaj;

  @override
  String toString() => 'OkumaException(${hata.name})';
}

const String _mesajKapali = 'Senin Hikâyen şu an senin için açık değil.';
const String _mesajHikayeBulunamadi = 'Bu hikâye şu an açılamıyor. Başka bir hikâye seçelim.';
const String _mesajKotaDoldu = 'Bugünkü hikâyeni okudun. Yarın yeni bir hikâye seni bekliyor.';
const String _mesajHizSiniri = 'Biraz yavaşlayalım. Birkaç dakika sonra tekrar dene.';
const String _mesajCakisma = 'Bu hikâye başka bir ayarla başlatılmış. Hikâyeyi yeniden seç.';
const String _mesajGecersiz = 'Bu işlem yapılamadı. Hikâyeyi yeniden seçip dene.';
const String _mesajOturumYok = 'Okuma oturumun bulunamadı. Hikâyeyi yeniden seç.';
const String _mesajOturumKapali = 'Bu okuma zaten tamamlanmış.';
const String _mesajMotorEski = 'Bu hikâye için uygulamayı güncellemen gerekiyor.';
const String _mesajBaglanti = 'Bağlantı kurulamadı. İnternetini kontrol edip yeniden dene.';
const String _mesajBilinmeyen = 'Bir sorun oluştu. Birazdan yeniden deneyelim.';

OkumaException _hata(OkumaHatasi h, String m) => OkumaException(h, m);

/// Sunucu hata metni (ör. 'KOTA_DOLDU') → Türkçe, ad içermeyen kullanıcı mesajı.
OkumaException okumaHatasiCevir(String sunucuMesaji) {
  bool icerir(String kod) => sunucuMesaji.contains(kod);
  if (icerir('OKUMA_KAPALI') || icerir('STUDENT_ONLY') || icerir('AUTH_REQUIRED')) {
    return _hata(OkumaHatasi.kapali, _mesajKapali);
  }
  if (icerir('HIKAYE_BULUNAMADI')) return _hata(OkumaHatasi.hikayeBulunamadi, _mesajHikayeBulunamadi);
  if (icerir('KOTA_DOLDU')) return _hata(OkumaHatasi.kotaDoldu, _mesajKotaDoldu);
  if (icerir('RATE_LIMIT')) return _hata(OkumaHatasi.hizSiniri, _mesajHizSiniri);
  if (icerir('IDEMPOTENCY_CONFLICT')) return _hata(OkumaHatasi.cakisma, _mesajCakisma);
  if (icerir('OTURUM_BULUNAMADI')) return _hata(OkumaHatasi.oturumYok, _mesajOturumYok);
  if (icerir('OTURUM_KAPALI')) return _hata(OkumaHatasi.oturumKapali, _mesajOturumKapali);
  const gecersizler = [
    'INVALID_ATTEMPT_KEY',
    'BAD_KAHRAMAN_TURU',
    'KAHRAMAN_TURU_UYGUN_DEGIL',
    'BAD_OKUMA_MODU',
    'SORU_BULUNAMADI',
    'BAD_SORU',
    'BAD_OPTION',
    'BAD_HEDEF',
    'BAD_YILDIZ',
    'BAD_SAYFA',
    'BAD_KOD',
  ];
  if (gecersizler.any(icerir)) return _hata(OkumaHatasi.gecersizIstek, _mesajGecersiz);
  return _hata(OkumaHatasi.bilinmeyen, _mesajBilinmeyen);
}

/// Bağlantı kesintisi için ortak hata.
const OkumaException okumaBaglantiHatasi = OkumaException(OkumaHatasi.baglanti, _mesajBaglanti);

/// Paketin motor sürümü bu uygulamadan yeniyse atılır.
const OkumaException okumaMotorEskiHatasi = OkumaException(OkumaHatasi.motorEski, _mesajMotorEski);

abstract class OkumaRepository {
  /// Bayrak kapalıyken de çağrılabilir; `erisim` false ise modül hiç görünmez.
  Future<OkumaOzellikDurumu> ozellikDurumu();

  Future<List<OkumaKatalogSatiri>> katalog({String? kahramanTuru, int limit = 24});

  /// Paket (kota denetimli). Cihaz önbelleği bunun ÜSTÜNDE çalışır.
  Future<OkumaPaketi> hikayeGetir(String hikayeId);

  Future<OkumaOturum> oturumBaslat({
    required String hikayeId,
    required String kahramanTuru,
    required bool yoldasVar,
    required String okumaModu,
    required String istemciAnahtari,
  });

  /// Bırakılan sayfa analitiği; başarısızlığı akışı bozmaz.
  Future<void> ilerlemeKaydet({required String oturumId, required int sayfa});

  Future<OkumaCevapSonucu> cevapKontrol({
    required String oturumId,
    required String soruId,
    required String secenekId,
  });

  Future<OkumaSonuc> oturumBitir({required String oturumId, List<String> dokunulan = const []});

  Future<void> geriBildirimGonder({required String oturumId, required OkumaAnketYaniti yanit});

  Future<OkumaSeriVeOneri> seriVeOneri();

  Future<OkumaPdfHakki> pdfHakkiKullan(String hikayeId);
}

/// Anket seçeneği → sözleşmedeki beyaz liste kodu.
const List<String> kOkumaIyilestirmeKodlari = [
  'daha_kisa',
  'daha_uzun',
  'daha_komik',
  'daha_gizemli',
  'daha_kolay',
  'daha_zor',
  'daha_cok_macera',
  'daha_cok_bilgi',
];

class SupabaseOkumaRepository implements OkumaRepository {
  const SupabaseOkumaRepository(this._client);

  final SupabaseClient _client;

  Future<T> _rpc<T>(String fonksiyon, Map<String, dynamic>? params, T Function(dynamic veri) donustur) async {
    try {
      final veri = await _client.rpc(fonksiyon, params: params);
      return donustur(veri);
    } on PostgrestException catch (e) {
      throw okumaHatasiCevir(e.message);
    } on FormatException {
      throw const OkumaException(OkumaHatasi.bilinmeyen, _mesajBilinmeyen);
    } on TypeError {
      // Beklenmeyen yanıt biçimi; ham içerik gösterilmez.
      throw const OkumaException(OkumaHatasi.bilinmeyen, _mesajBilinmeyen);
    } on Exception {
      // Ağ kesintisi ve benzeri taşıma hataları.
      throw okumaBaglantiHatasi;
    }
  }

  static Map<String, dynamic> _nesne(dynamic veri) => Map<String, dynamic>.from(veri as Map);

  @override
  Future<OkumaOzellikDurumu> ozellikDurumu() =>
      _rpc('okuma_ozellik_durumu', null, (v) => OkumaOzellikDurumu.fromMap(_nesne(v)));

  @override
  Future<List<OkumaKatalogSatiri>> katalog({String? kahramanTuru, int limit = 24}) {
    return _rpc(
      'okuma_katalog_filtre',
      {if (kahramanTuru != null) 'p_kahraman_turu': kahramanTuru, 'p_limit': limit},
      (v) => [
        for (final h in (_nesne(v)['hikayeler'] as List? ?? const []))
          OkumaKatalogSatiri.fromMap(Map<String, dynamic>.from(h as Map)),
      ],
    );
  }

  @override
  Future<OkumaPaketi> hikayeGetir(String hikayeId) =>
      _rpc('okuma_hikaye_getir', {'p_hikaye_id': hikayeId}, (v) => OkumaPaketi.fromMap(_nesne(v)));

  @override
  Future<OkumaOturum> oturumBaslat({
    required String hikayeId,
    required String kahramanTuru,
    required bool yoldasVar,
    required String okumaModu,
    required String istemciAnahtari,
  }) {
    return _rpc(
      'okuma_oturum_baslat',
      {
        'p_hikaye_id': hikayeId,
        'p_kahraman_turu': kahramanTuru,
        'p_yoldas_var': yoldasVar,
        'p_okuma_modu': okumaModu,
        'p_istemci_anahtari': istemciAnahtari,
      },
      (v) => OkumaOturum.fromMap(_nesne(v)),
    );
  }

  @override
  Future<void> ilerlemeKaydet({required String oturumId, required int sayfa}) =>
      _rpc('okuma_ilerleme_kaydet', {'p_oturum_id': oturumId, 'p_sayfa': sayfa}, (_) {});

  @override
  Future<OkumaCevapSonucu> cevapKontrol({
    required String oturumId,
    required String soruId,
    required String secenekId,
  }) {
    return _rpc(
      'okuma_cevap_kontrol',
      {'p_oturum_id': oturumId, 'p_soru_id': soruId, 'p_secenek_id': secenekId},
      (v) => OkumaCevapSonucu.fromMap(_nesne(v)),
    );
  }

  @override
  Future<OkumaSonuc> oturumBitir({required String oturumId, List<String> dokunulan = const []}) {
    return _rpc(
      'okuma_oturum_bitir',
      {'p_oturum_id': oturumId, 'p_dokunulan': dokunulan},
      (v) => OkumaSonuc.fromMap(_nesne(v)),
    );
  }

  @override
  Future<void> geriBildirimGonder({required String oturumId, required OkumaAnketYaniti yanit}) {
    final yildiz = yanit.yildiz;
    // Sözleşme 1–5 yıldızı zorunlu tutar (BAD_YILDIZ). Yıldızsız anket gönderilmez; ekran da engeller.
    if (yildiz == null) return Future<void>.value();
    return _rpc(
      'okuma_geri_bildirim_gonder',
      {
        'p_oturum_id': oturumId,
        'p_yildiz': yildiz,
        'p_iyilestirme_kodlari': yanit.iyilestirmeKodlari.toList(),
        'p_baska_kahraman': yanit.baskaKahraman,
        'p_ayni_turden': yanit.ayniTurden,
        'p_sorun_kodlari': const <String>[],
      },
      (_) {},
    );
  }

  @override
  Future<OkumaSeriVeOneri> seriVeOneri() =>
      _rpc('okuma_seri_ve_oneri', null, (v) => OkumaSeriVeOneri.fromMap(_nesne(v)));

  @override
  Future<OkumaPdfHakki> pdfHakkiKullan(String hikayeId) =>
      _rpc('okuma_pdf_hakki_kullan', {'p_hikaye_id': hikayeId}, (v) => OkumaPdfHakki.fromMap(_nesne(v)));
}
