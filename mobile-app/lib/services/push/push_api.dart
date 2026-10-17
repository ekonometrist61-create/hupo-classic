import 'package:supabase_flutter/supabase_flutter.dart';

/// Sunucudaki push tercihi (get_push_preference sonucu).
class PushPreference {
  const PushPreference({
    required this.enabled,
    required this.quietStart,
    required this.quietEnd,
    required this.needsParentConsent,
  });

  final bool enabled;

  /// "20:00" biçiminde.
  final String quietStart;
  final String quietEnd;

  /// Çocuk hesabı için velinin onayı yoksa true.
  final bool needsParentConsent;

  factory PushPreference.fromMap(Map<String, dynamic> map) => PushPreference(
        enabled: map['push_enabled'] as bool? ?? false,
        quietStart: map['quiet_start'] as String? ?? '20:00',
        quietEnd: map['quiet_end'] as String? ?? '08:00',
        needsParentConsent: map['veli_onayi_gerekli'] as bool? ?? true,
      );
}

/// Onay yokken açılmaya çalışıldı (sunucu 42501 döndü).
class PushConsentRequired implements Exception {
  const PushConsentRequired();
}

/// Sunucu tarafı (Supabase RPC) soyutlaması; testlerde sahtesi kullanılır.
abstract class PushApi {
  Future<PushPreference> getPreference();
  Future<PushPreference> setPreference(bool enabled);
  Future<void> registerToken(String token, String platform);
  Future<void> unregisterToken(String token);

  /// Ön izin gösterilebilir mi? 14 günde en fazla 2 gösterim. true dönerse gösterim sayılır.
  Future<bool> onIzinBaslat();

  /// Ön izin sonucunu ölçüme yazar: evet | ertele | sistem_verildi | sistem_reddedildi.
  Future<void> onIzinBildir(String sonuc);
}

class SupabasePushApi implements PushApi {
  SupabasePushApi(this._client);

  final SupabaseClient _client;

  @override
  Future<PushPreference> getPreference() async {
    final data = await _client.rpc('get_push_preference');
    return PushPreference.fromMap(Map<String, dynamic>.from(data as Map));
  }

  @override
  Future<PushPreference> setPreference(bool enabled) async {
    try {
      final data = await _client.rpc('set_push_preference', params: {'p_enabled': enabled});
      return PushPreference.fromMap(Map<String, dynamic>.from(data as Map));
    } on PostgrestException catch (e) {
      if (e.code == '42501') throw const PushConsentRequired();
      rethrow;
    }
  }

  @override
  Future<void> registerToken(String token, String platform) async {
    await _client.rpc('register_device_token', params: {'p_token': token, 'p_platform': platform});
  }

  @override
  Future<void> unregisterToken(String token) async {
    await _client.rpc('unregister_device_token', params: {'p_token': token});
  }

  @override
  Future<bool> onIzinBaslat() async {
    final data = await _client.rpc('push_on_izin_baslat');
    return data == true;
  }

  @override
  Future<void> onIzinBildir(String sonuc) async {
    await _client.rpc('push_on_izin_bildir', params: {'p_sonuc': sonuc});
  }
}
