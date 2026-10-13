// Duyuru: Supabase RPC katmanı (`get_aktif_duyuru`) ve "Kapat" kaydı.
//
// Duyuru yardımcı bilgidir; hata durumunda ekran bozulmaz. Bu yüzden ağ/sunucu
// hatası kullanıcıya hata metni olarak çıkarılmaz: sessizce null döner ve hata
// raporlanır. Migration uygulanmamışsa da hiçbir şey görünmez.

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/duyuru_models.dart';
import 'error_reporting.dart';
import 'yayin_yuzeyi.dart';

class DuyuruRepository {
  const DuyuruRepository(this._client);

  final SupabaseClient _client;

  /// Bu mecrada gösterilecek aktif duyuru; yoksa veya hata varsa null.
  /// Giriş gerektirmez (anon ve authenticated çağırabilir); öğrenci ve veli aynı duyuruyu görür.
  Future<Duyuru?> aktifDuyuru({String? yuzey}) async {
    try {
      final veri = await _client.rpc(
        'get_aktif_duyuru',
        params: {'p_yuzey': yuzey ?? yayinYuzeyi()},
      );
      return Duyuru.fromJson(veri);
    } on Exception catch (e, s) {
      reportError(e, s);
      return null;
    }
  }
}

/// "Kapat": duyuru kimliği başına kalıcı kayıt. Kapatılan duyuru bir daha gösterilmez.
///
/// Kayıt SharedPreferences'a yazılır; yazılamazsa oturum boyunca bellekte tutulur.
/// Yazma hatası çağıranda raporlanır.
class DuyuruKapatma {
  DuyuruKapatma(this._prefs);

  static const String _onek = 'duyuru_kapatildi_';

  final SharedPreferences _prefs;
  final Set<String> _bellek = {};

  String _anahtar(String duyuruId) => '$_onek$duyuruId';

  bool kapatildiMi(Duyuru duyuru) {
    if (_bellek.contains(duyuru.id)) return true;
    return _prefs.getBool(_anahtar(duyuru.id)) ?? false;
  }

  Future<void> kapat(Duyuru duyuru) async {
    _bellek.add(duyuru.id);
    try {
      await _prefs.setBool(_anahtar(duyuru.id), true);
    } on Exception catch (e, s) {
      reportError(e, s);
    }
  }
}
