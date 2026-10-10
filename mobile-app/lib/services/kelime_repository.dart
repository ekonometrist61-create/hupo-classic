// Kelime Evreni: Supabase RPC katmanı. Tüm erişim SECURITY DEFINER RPC'lerle yapılır
// (tablolara doğrudan erişim yoktur; bkz. supabase/migrations/20261022000000_kelime_evreni.sql).

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kelime_models.dart';

/// Kullanıcıya gösterilecek hata sınıfları. Mesajlar Türkçedir ve doğrudan gösterilebilir.
enum KelimeHatasi {
  sinifGerekli,
  yetkisiz,
  soruBulunamadi,
  hizSiniri,
  cevapCakismasi,
  gecersizDeneme,
  baglanti,
  bilinmeyen,
}

class KelimeException implements Exception {
  const KelimeException(this.hata, this.mesaj);

  final KelimeHatasi hata;
  final String mesaj;

  @override
  String toString() => 'KelimeException(${hata.name}): $mesaj';
}

const String _mesajSinifGerekli = 'Kelime oyunları için önce sınıfını seçmelisin.';
const String _mesajYetkisiz = 'Bu oyun için öğrenci hesabınla giriş yapmalısın.';
const String _mesajSoruBulunamadi = 'Bu soru artık yok. Sıradaki soruya geçelim.';
const String _mesajHizSiniri = 'Biraz yavaşlayalım. Birkaç saniye sonra tekrar dene.';
const String _mesajCevapCakismasi = 'Bu cevap daha önce farklı kaydedilmiş. Sayfayı yenileyip tekrar dene.';
const String _mesajGecersizDeneme = 'Cevap gönderilemedi. Sayfayı yenileyip tekrar dene.';
const String _mesajBaglanti = 'Cevap kaydedilemedi. İnternet bağlantını kontrol edip tekrar dene.';
const String _mesajBilinmeyen = 'Bir sorun oluştu. Birazdan tekrar deneyelim.';

/// Sunucu hata metni (ör. 'SINIF_GEREKLI') → Türkçe kullanıcı mesajı. Bilinmeyen metin genel mesaja düşer.
KelimeException kelimeHatasiCevir(String sunucuMesaji) {
  if (sunucuMesaji.contains('SINIF_GEREKLI')) {
    return const KelimeException(KelimeHatasi.sinifGerekli, _mesajSinifGerekli);
  }
  if (sunucuMesaji.contains('STUDENT_ONLY') || sunucuMesaji.contains('AUTH_REQUIRED')) {
    return const KelimeException(KelimeHatasi.yetkisiz, _mesajYetkisiz);
  }
  if (sunucuMesaji.contains('SORU_BULUNAMADI')) {
    return const KelimeException(KelimeHatasi.soruBulunamadi, _mesajSoruBulunamadi);
  }
  if (sunucuMesaji.contains('RATE_LIMIT')) {
    return const KelimeException(KelimeHatasi.hizSiniri, _mesajHizSiniri);
  }
  if (sunucuMesaji.contains('IDEMPOTENCY_CONFLICT')) {
    return const KelimeException(KelimeHatasi.cevapCakismasi, _mesajCevapCakismasi);
  }
  if (sunucuMesaji.contains('INVALID_ATTEMPT_KEY') || sunucuMesaji.contains('BAD_OPTION')) {
    return const KelimeException(KelimeHatasi.gecersizDeneme, _mesajGecersizDeneme);
  }
  return const KelimeException(KelimeHatasi.bilinmeyen, _mesajBilinmeyen);
}

abstract class KelimeRepository {
  Future<KelimeOyunSorulari> oyunGetir({required KelimeIliskiTuru iliski, int limit = 8});

  Future<KelimeCevapSonucu> cevapGonder({
    required String soruId,
    required int secilenIndeks,
    required bool ipucuKullanildi,
    required String denemeAnahtari,
  });

  Future<KelimeOzet> ozet();

  Future<List<KelimeKaydi>> kaydedilenler();

  Future<void> kaydet({required String anlamId, required bool kaydet});

  Future<KelimeVeliOzeti> veliOzeti({required String cocukId});
}

class SupabaseKelimeRepository implements KelimeRepository {
  const SupabaseKelimeRepository(this._client);

  final SupabaseClient _client;

  Future<T> _rpc<T>(String fonksiyon, Map<String, dynamic> params, T Function(dynamic veri) donustur) async {
    try {
      final veri = await _client.rpc(fonksiyon, params: params);
      return donustur(veri);
    } on PostgrestException catch (e) {
      throw kelimeHatasiCevir(e.message);
    } on FormatException {
      // Sunucu beklenmeyen biçimde yanıt verdi; ham içerik gösterilmez.
      throw const KelimeException(KelimeHatasi.bilinmeyen, _mesajBilinmeyen);
    } on Exception {
      // Ağ kesintisi ve benzeri taşıma hataları.
      throw const KelimeException(KelimeHatasi.baglanti, _mesajBaglanti);
    }
  }

  @override
  Future<KelimeOyunSorulari> oyunGetir({required KelimeIliskiTuru iliski, int limit = 8}) {
    return _rpc(
      'kelime_oyun_getir',
      {'p_iliski_turu': iliski.veritabani, 'p_limit': limit},
      (veri) => KelimeOyunSorulari.fromMap(Map<String, dynamic>.from(veri as Map)),
    );
  }

  @override
  Future<KelimeCevapSonucu> cevapGonder({
    required String soruId,
    required int secilenIndeks,
    required bool ipucuKullanildi,
    required String denemeAnahtari,
  }) {
    return _rpc(
      'kelime_cevap_gonder',
      {
        'p_soru_id': soruId,
        'p_secilen_indeks': secilenIndeks,
        'p_ipucu_kullanildi': ipucuKullanildi,
        'p_deneme_anahtari': denemeAnahtari,
      },
      (veri) => KelimeCevapSonucu.fromMap(Map<String, dynamic>.from(veri as Map)),
    );
  }

  @override
  Future<KelimeOzet> ozet() {
    return _rpc(
      'kelime_ogrenci_ozeti',
      const {},
      (veri) => KelimeOzet.fromMap(Map<String, dynamic>.from(veri as Map)),
    );
  }

  @override
  Future<List<KelimeKaydi>> kaydedilenler() {
    return _rpc(
      'kelime_kaydedilenler_listele',
      const {},
      (veri) => [
        for (final e in (veri as List? ?? const []))
          KelimeKaydi.fromMap(Map<String, dynamic>.from(e as Map)),
      ],
    );
  }

  @override
  Future<void> kaydet({required String anlamId, required bool kaydet}) {
    return _rpc(
      'kelime_kaydet',
      {'p_anlam_id': anlamId, 'p_kaydet': kaydet},
      (_) {},
    );
  }

  @override
  Future<KelimeVeliOzeti> veliOzeti({required String cocukId}) {
    return _rpc(
      'kelime_veli_ozeti',
      {'p_cocuk_id': cocukId},
      (veri) => KelimeVeliOzeti.fromMap(Map<String, dynamic>.from(veri as Map)),
    );
  }
}
