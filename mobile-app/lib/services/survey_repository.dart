// Veli anketleri: Supabase RPC katmanı (`anket_siradaki_kart`, `anket_kart_atla`,
// `anket_yanit_gonder`). Sessiz saat, günlük bütçe ve atlama takvimi sunucudadır; burada
// yerel bir erteleme kuralı tutulmaz. Sunucu hataları Türkçe kullanıcı mesajına çevrilir.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/survey_models.dart';
import 'yayin_yuzeyi.dart';

enum AnketHatasi { yetkisiz, yakinZamanda, gecersizYanit, bulunamadi, baglanti, bilinmeyen }

/// Kullanıcıya gösterilebilir anket hatası. [mesaj] doğrudan gösterilebilir.
class AnketException implements Exception {
  const AnketException(this.hata, this.mesaj);

  final AnketHatasi hata;
  final String mesaj;

  @override
  String toString() => 'AnketException(${hata.name}): $mesaj';
}

const String _mesajYetkisiz = 'Bu anket yalnızca veli hesapları içindir.';
const String _mesajYakinZamanda = 'Bu ankete yakın zamanda yanıt verilmiş. Teşekkürler!';
const String _mesajGecersizYanit =
    'Yanıtlar kaydedilemedi. Soruları kontrol edip tekrar deneyelim.';
const String _mesajBulunamadi = 'Bu anket artık yayında değil.';
const String _mesajBaglanti =
    'Yanıtlar kaydedilemedi. İnternet bağlantısı kontrol edilip tekrar denenebilir.';
const String _mesajBilinmeyen = 'Bir sorun oluştu. Birazdan tekrar deneyelim.';

/// Sunucu SQLSTATE kodu → hata sınıfı. Bilinmeyen kod genel mesaja düşer.
AnketHatasi anketHatasiKodu(String? kod) => switch (kod) {
      '42501' => AnketHatasi.yetkisiz,
      '23505' => AnketHatasi.yakinZamanda,
      '22023' => AnketHatasi.gecersizYanit,
      'P0002' => AnketHatasi.bulunamadi,
      _ => AnketHatasi.bilinmeyen,
    };

AnketException _hataCevir(PostgrestException e) {
  final hata = anketHatasiKodu(e.code);
  return switch (hata) {
    AnketHatasi.yetkisiz => const AnketException(AnketHatasi.yetkisiz, _mesajYetkisiz),
    AnketHatasi.yakinZamanda => const AnketException(AnketHatasi.yakinZamanda, _mesajYakinZamanda),
    AnketHatasi.gecersizYanit => const AnketException(AnketHatasi.gecersizYanit, _mesajGecersizYanit),
    AnketHatasi.bulunamadi => const AnketException(AnketHatasi.bulunamadi, _mesajBulunamadi),
    _ => const AnketException(AnketHatasi.bilinmeyen, _mesajBilinmeyen),
  };
}

/// Anketin yayınlandığı mecra: `mobil` (Android/iOS) veya `web_app` (Flutter Web).
String anketYuzeyi() => yayinYuzeyi();

class SurveyRepository {
  const SurveyRepository(this._client);

  final SupabaseClient _client;

  /// Veliye gösterilecek en fazla tek kart, yoksa null (sessiz saat, bütçe ve atlama
  /// beklemesi dahil sunucu karar verir). Yalnızca veli hesabında çağrılmalıdır;
  /// öğrenci hesabında sunucu 42501 döner.
  Future<Anket?> siradakiKart({String? yuzey, DateTime? yerelSaat}) async {
    try {
      final veri = await _client.rpc(
        'anket_siradaki_kart',
        params: {
          'p_yuzey': yuzey ?? anketYuzeyi(),
          'p_yerel_saat': yerelSaatMetni(yerelSaat ?? DateTime.now()),
        },
      );
      return Anket.fromJson(veri);
    } on PostgrestException catch (e) {
      throw _hataCevir(e);
    } on Exception {
      throw const AnketException(AnketHatasi.baglanti, _mesajBaglanti);
    }
  }

  /// Kartı kapatma = atlama (kart başına bir kez). Sonraki gösterim sunucu takvimine göredir.
  Future<void> atla({required String anketId, String? yuzey}) async {
    try {
      await _client.rpc('anket_kart_atla', params: {
        'p_anket_id': anketId,
        'p_yuzey': yuzey ?? anketYuzeyi(),
      });
    } on PostgrestException catch (e) {
      throw _hataCevir(e);
    } on Exception {
      throw const AnketException(AnketHatasi.baglanti, _mesajBaglanti);
    }
  }

  /// [yanitlar] = { soru_id: değer }. Görünmeyen ve boş sorular çağıran tarafça ayıklanmış olmalı.
  Future<void> yanitGonder({
    required String anketId,
    required Map<String, Object> yanitlar,
    String? yuzey,
  }) async {
    try {
      await _client.rpc('anket_yanit_gonder', params: {
        'p_anket_id': anketId,
        'p_yanitlar': yanitlar,
        'p_yuzey': yuzey ?? anketYuzeyi(),
      });
    } on PostgrestException catch (e) {
      throw _hataCevir(e);
    } on Exception {
      throw const AnketException(AnketHatasi.baglanti, _mesajBaglanti);
    }
  }
}

/// Sunucunun beklediği `time` biçimi ("HH:mm:ss"): cihazın yerel saati.
/// Sessiz saat kararını sunucu verir; istemci yalnızca saati bildirir.
String yerelSaatMetni(DateTime zaman) {
  String iki(int n) => n.toString().padLeft(2, '0');
  return '${iki(zaman.hour)}:${iki(zaman.minute)}:${iki(zaman.second)}';
}
