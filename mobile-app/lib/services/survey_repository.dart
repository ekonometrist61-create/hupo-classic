// Veli anketleri: Supabase RPC katmanı (`anket_aktif_listem`, `anket_yanit_gonder`)
// ve "Şimdi değil" ertelemesi. Sunucu hataları burada Türkçe kullanıcı mesajına çevrilir.

import 'package:shared_preferences/shared_preferences.dart';
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

  /// Yalnızca veli hesabında çağrılmalıdır; öğrenci hesabında sunucu 42501 döner.
  Future<List<Anket>> aktifAnketler({String? yuzey}) async {
    try {
      final veri = await _client.rpc(
        'anket_aktif_listem',
        params: {'p_yuzey': yuzey ?? anketYuzeyi()},
      );
      return anketListesiFromJson(veri);
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

/// "Şimdi değil": anket kimliği + sürümü başına 1 gün gösterilmez.
///
/// Kayıt SharedPreferences'a yazılır; yazılamazsa oturum boyunca bellekte tutulur,
/// böylece kart hemen geri gelmez. Yazma hatası çağıranda raporlanır.
class SurveyDeferral {
  SurveyDeferral(this._prefs, {DateTime Function()? simdi}) : _simdi = simdi ?? DateTime.now;

  static const String _onek = 'anket_ertele_';
  static const Duration _sure = Duration(days: 1);

  final SharedPreferences _prefs;
  final DateTime Function() _simdi;
  final Map<String, DateTime> _bellek = {};

  String _anahtar(Anket anket) => '$_onek${anket.ertelemeAnahtari}';

  bool erteleniyorMu(Anket anket) {
    final an = _simdi();
    final bellekte = _bellek[_anahtar(anket)];
    if (bellekte != null && an.isBefore(bellekte)) return true;
    final kayitli = _prefs.getInt(_anahtar(anket));
    if (kayitli == null) return false;
    return an.isBefore(DateTime.fromMillisecondsSinceEpoch(kayitli));
  }

  Future<void> ertele(Anket anket) async {
    final hedef = _simdi().add(_sure);
    _bellek[_anahtar(anket)] = hedef;
    await _prefs.setInt(_anahtar(anket), hedef.millisecondsSinceEpoch);
  }
}
