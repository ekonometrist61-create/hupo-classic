// Veli ana ekranı: çocuk listesi ve çocuk özeti veri katmanı.
//
// Yalnızca MEVCUT veri kaynakları kullanılır (yeni RPC yok):
//  * Çocuk listesi: public.profiles, parent_id = veli. Web veli panelinin
//    (web-panel/src/lib/veli-paneli/access.ts) birebir aynı sorgusu; RLS politikası
//    profiles_select_children (20260920000000_initial_schema.sql) veliye çocuğunu okutur.
//  * Çocuk özeti: public.get_student_dashboard(p_student_id, p_gun = 7)
//    (20261013000000_veli_riza_kapisi.sql). Veli rızası "verildi" değilse sunucu
//    öğrenci verisi dönmez, yalnızca "riza" alanını döner.
//
// Provider'lar kapsam kısıtı nedeniyle bu klasördedir; lib/providers/ altına taşınabilir.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../providers/app_providers.dart';

/// Velinin bağlı bir çocuğu (profiles satırı).
class VeliCocuk {
  const VeliCocuk({required this.id, this.adSoyad, this.kullaniciAdi});

  final String id;
  final String? adSoyad;
  final String? kullaniciAdi;

  /// Kartta gösterilen ad: önce ad-soyad, yoksa kullanıcı adı, o da yoksa genel etiket.
  String get gorunenAd => _temiz(adSoyad) ?? _temiz(kullaniciAdi) ?? 'Çocuğunuz';

  factory VeliCocuk.fromMap(Map<String, dynamic> map) => VeliCocuk(
        id: map['id'] as String,
        adSoyad: map['full_name'] as String?,
        kullaniciAdi: map['username'] as String?,
      );
}

/// Velinin çocuk verisine verdiği onay (get_student_dashboard → riza).
enum VeliRiza { verildi, yok, geriCekildi, bilinmiyor }

/// Çocuğun son 7 günlük özeti. Rıza "verildi" değilse yalnızca [riza] anlamlıdır.
class CocukOzeti {
  const CocukOzeti({
    required this.riza,
    this.xp = 0,
    this.seviye = 1,
    this.seriGun = 0,
    this.haftaDakika = 0,
    this.haftaSoru = 0,
    this.tekrarKonulari = const [],
  });

  final VeliRiza riza;

  /// Oyun ilerlemesi (XP). Öğrenme metriği değildir; ayrı gösterilir.
  final int xp;
  final int seviye;
  final int seriGun;

  /// Son 7 gün çalışma süresi (dk). Sunucuda cevap başına en fazla 5 dk sayılır.
  final double haftaDakika;

  /// Son 7 günde çözülen soru sayısı.
  final int haftaSoru;

  /// Tekrar önerilen konular (sunucu sırasına göre: en çok yanlıştan).
  final List<String> tekrarKonulari;

  bool get verisiGorunur => riza == VeliRiza.verildi;

  factory CocukOzeti.fromMap(Map<String, dynamic> map) {
    final riza = _rizaCevir(map['riza']);
    if (riza != VeliRiza.verildi) return CocukOzeti(riza: riza);

    final ozet = _harita(map['ozet']);
    var dakika = 0.0;
    var soru = 0;
    for (final gun in _liste(map['haftalik'])) {
      final g = _harita(gun);
      dakika += _sayi(g['sure_dk']);
      soru += _tamSayi(g['soru_sayisi']);
    }
    final konular = <String>[];
    for (final t in _liste(map['tekrar_konulari'])) {
      final konu = _temiz(_harita(t)['konu']);
      if (konu != null) konular.add(konu);
    }

    return CocukOzeti(
      riza: riza,
      xp: _tamSayi(ozet['xp']),
      seviye: ozet.containsKey('level') ? _tamSayi(ozet['level']) : 1,
      seriGun: _tamSayi(ozet['streak_count']),
      haftaDakika: dakika,
      haftaSoru: soru,
      tekrarKonulari: konular,
    );
  }
}

/// Çocuk listesi ve özet için sunucu katmanı. Hata yutulmaz; çağıran kullanıcıya gösterir.
class VeliCocukRepository {
  const VeliCocukRepository(this._client);

  final SupabaseClient _client;

  /// Velinin bağlı çocukları (ad sırasıyla). Çocuk yoksa boş liste.
  Future<List<VeliCocuk>> cocuklar(String veliId) async {
    final satirlar = await _client
        .from('profiles')
        .select('id, full_name, username')
        .eq('parent_id', veliId)
        .order('full_name');
    return [
      for (final satir in satirlar) VeliCocuk.fromMap(Map<String, dynamic>.from(satir)),
    ];
  }

  /// Çocuğun son 7 gün özeti. Veli rızası yoksa sunucu öğrenci verisi dönmez.
  Future<CocukOzeti> ozet(String cocukId) async {
    final veri = await _client.rpc(
      'get_student_dashboard',
      params: {'p_student_id': cocukId, 'p_gun': 7},
    );
    return CocukOzeti.fromMap(Map<String, dynamic>.from(veri as Map));
  }
}

final veliCocukRepositoryProvider = Provider<VeliCocukRepository>(
    (ref) => VeliCocukRepository(ref.watch(supabaseProvider)));

/// Oturumdaki velinin çocukları. Oturum yoksa boş liste.
final veliCocuklarProvider = FutureProvider.autoDispose<List<VeliCocuk>>((ref) async {
  final veliId = ref.watch(currentUserIdProvider);
  if (veliId == null) return const [];
  return ref.watch(veliCocukRepositoryProvider).cocuklar(veliId);
});

/// Bir çocuğun özeti. Her çocuk kartı kendi özetini ayrı ayrı yükler.
final veliCocukOzetiProvider =
    FutureProvider.autoDispose.family<CocukOzeti, String>((ref, cocukId) {
  return ref.watch(veliCocukRepositoryProvider).ozet(cocukId);
});

// --- Ayrıştırma yardımcıları (sunucu sayıları bazen metin olarak gelebilir) ---

String? _temiz(Object? metin) {
  if (metin is! String) return null;
  final t = metin.trim();
  return t.isEmpty ? null : t;
}

VeliRiza _rizaCevir(Object? deger) => switch (deger) {
      'verildi' => VeliRiza.verildi,
      'yok' => VeliRiza.yok,
      'geri_cekildi' => VeliRiza.geriCekildi,
      _ => VeliRiza.bilinmiyor,
    };

Map<String, dynamic> _harita(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : const <String, dynamic>{};

List<dynamic> _liste(Object? v) => v is List ? v : const <dynamic>[];

int _tamSayi(Object? v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _sayi(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}
