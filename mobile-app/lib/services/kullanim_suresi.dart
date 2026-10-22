// Anonim kullanım süresi ölçümü (mobil + Flutter Web).
//
// Toplanan: yüzey, ekran adı (rota adı; sorgu/ID yok), süre (sn), başlangıç zamanı, rastgele oturum anahtarı,
// kaba rol. Toplanmayan: çocuk adı, e-posta, profil/hesap kimliği, serbest metin. Oturum anahtarı hesaba bağlı
// DEĞİL; uygulama her ön plana geldiğinde yenilenir. Sunucu: supabase/migrations/20261066000000_kullanim_suresi.sql
// (300 gün saklama). Ağ hataları sessizce yutulur; kullanıcıya hiçbir şey gösterilmez.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Toplu gönderici. true: grup işlendi (kuyruktan düşer); false: bağlantı yok, sonra yeniden denenir.
typedef KullanimGonderici = Future<bool> Function(List<Map<String, dynamic>> olaylar);

const int kullanimKuyrukLimiti = 200;
const int kullanimGonderimLimiti = 50;
const int kullanimEkranLimiti = 60;
const int kullanimEnUzunSureSn = 14400;

class KullanimRepository {
  KullanimRepository([SupabaseClient? istemci]) : _istemci = istemci;

  final SupabaseClient? _istemci;

  Future<bool> gonder(List<Map<String, dynamic>> olaylar) async {
    try {
      final c = _istemci ?? Supabase.instance.client;
      await c.rpc('kullanim_olaylari_gonder', params: {'p_olaylar': olaylar});
      return true;
    } on PostgrestException {
      // Sunucu reddetti (doğrulama/hız sınırı): aynı grubu tekrar denemenin anlamı yok.
      return true;
    } catch (_) {
      return false;
    }
  }
}

String kullanimOturumAnahtari([Random? rastgele]) {
  final r = rastgele ?? Random.secure();
  const harfler = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(24, (_) => harfler[r.nextInt(harfler.length)]).join();
}

/// Rota/ekran adını güvenli biçime getirir: sorgu ve parça atılır, ID benzeri bölümler maskelenir, ≤60 karakter.
String kullanimEkranAdi(String? ham) {
  var ad = (ham ?? '').trim();
  if (ad.isEmpty) return 'bilinmeyen';
  ad = ad.split('?').first.split('#').first;
  final bolumler = ad.split('/').map((b) {
    if (b.isEmpty) return b;
    final uuid = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (uuid.hasMatch(b) || RegExp(r'^\d+$').hasMatch(b) || (b.length > 20 && RegExp(r'\d').hasMatch(b))) {
      return ':id';
    }
    return b;
  }).join('/');
  var temiz = bolumler.replaceAll(RegExp(r'[^A-Za-z0-9_/.:\[\]-]'), '_');
  if (temiz.isEmpty) return 'bilinmeyen';
  if (temiz.length > kullanimEkranLimiti) temiz = temiz.substring(0, kullanimEkranLimiti);
  return temiz;
}

class KullanimSuresi with WidgetsBindingObserver {
  KullanimSuresi({
    required this.gonderici,
    String Function()? rolBulucu,
    DateTime Function()? simdi,
    String Function()? anahtarUretici,
    String? yuzey,
    this.gonderimAraligi = const Duration(seconds: 60),
  })  : _rolBulucu = rolBulucu ?? (() => 'ziyaretci'),
        _simdi = simdi ?? DateTime.now,
        _anahtarUretici = anahtarUretici ?? kullanimOturumAnahtari,
        yuzey = yuzey ?? (kIsWeb ? 'flutter_web' : 'mobil');

  static KullanimSuresi? instance;

  /// Uygulama başlangıcında bir kez çağrılır; ikinci çağrı mevcut örneği döndürür.
  static KullanimSuresi baslat({KullanimGonderici? gonderici, String Function()? rolBulucu}) {
    final var1 = instance;
    if (var1 != null) return var1;
    final k = KullanimSuresi(gonderici: gonderici ?? KullanimRepository().gonder, rolBulucu: rolBulucu);
    instance = k;
    k.baslat_();
    return k;
  }

  final KullanimGonderici gonderici;
  final String yuzey;
  final Duration gonderimAraligi;
  final String Function() _rolBulucu;
  final DateTime Function() _simdi;
  final String Function() _anahtarUretici;

  final List<Map<String, dynamic>> _kuyruk = [];
  String? _oturum;
  String? _ekran;
  DateTime? _ekranBaslangic;
  bool _onPlanda = true;
  bool _gonderiliyor = false;
  Timer? _zamanlayici;

  /// Sekmeli kabuğun güncel sekme adı (kök rota bu ada eşlenir).
  String? sekmeAdi;

  int get kuyrukUzunlugu => _kuyruk.length;
  String? get aktifEkran => _ekran;
  List<Map<String, dynamic>> get bekleyenler => List.unmodifiable(_kuyruk);

  void baslat_() {
    WidgetsBinding.instance.addObserver(this);
    _zamanlayici?.cancel();
    _zamanlayici = Timer.periodic(gonderimAraligi, (_) => unawaited(gonder()));
  }

  void kapat() {
    WidgetsBinding.instance.removeObserver(this);
    _zamanlayici?.cancel();
    _zamanlayici = null;
  }

  /// Aktif ekranı değiştirir; öncekinin süresi kapanır. Aynı ad tekrarında bir şey yapmaz.
  void ekranDegis(String? ham) {
    final ad = kullanimEkranAdi(ham);
    if (ad == _ekran) return;
    _ekraniKapat();
    _ekran = ad;
    if (_onPlanda) _ekranBaslat();
  }

  void sekmeDegis(String ad) {
    sekmeAdi = ad;
    ekranDegis(ad);
  }

  void _ekranBaslat() {
    _oturum ??= _anahtarUretici();
    _ekranBaslangic = _simdi();
  }

  void _ekraniKapat() {
    final bas = _ekranBaslangic;
    final ekran = _ekran;
    final oturum = _oturum;
    _ekranBaslangic = null;
    if (bas == null || ekran == null || oturum == null) return;
    var sn = (_simdi().difference(bas).inMilliseconds / 1000).round();
    if (sn < 1) return;
    if (sn > kullanimEnUzunSureSn) sn = kullanimEnUzunSureSn;
    _kuyruk.add({
      'yuzey': yuzey,
      'ekran': ekran,
      'sure_sn': sn,
      'baslangic': bas.toUtc().toIso8601String(),
      'oturum_anahtari': oturum,
      'rol': _rol(),
    });
    while (_kuyruk.length > kullanimKuyrukLimiti) {
      _kuyruk.removeAt(0);
    }
  }

  String _rol() {
    try {
      final r = _rolBulucu();
      const gecerli = {'ogrenci', 'veli', 'ogretmen', 'admin', 'ziyaretci'};
      return gecerli.contains(r) ? r : 'ziyaretci';
    } catch (_) {
      return 'ziyaretci';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState durum) {
    arkaPlanDurumu(durum == AppLifecycleState.resumed);
  }

  /// Ön plan/arka plan geçişi. Arka plana gidince ekran ve oturum kapanır, bekleyenler gönderilir;
  /// boşta (arka plandaki) süre sayılmaz. Öne dönünce yeni oturum anahtarıyla aynı ekran yeniden başlar.
  void arkaPlanDurumu(bool onPlanda) {
    if (onPlanda == _onPlanda) return;
    _onPlanda = onPlanda;
    if (!onPlanda) {
      _ekraniKapat();
      _oturum = null;
      unawaited(gonder());
    } else if (_ekran != null) {
      _ekranBaslat();
    }
  }

  /// Bekleyen olayları 50'şerli gruplarla gönderir. Bağlantı yoksa kuyrukta kalır (en çok 200).
  Future<void> gonder() async {
    if (_gonderiliyor || _kuyruk.isEmpty) return;
    _gonderiliyor = true;
    try {
      while (_kuyruk.isNotEmpty) {
        final n = min(kullanimGonderimLimiti, _kuyruk.length);
        final grup = _kuyruk.sublist(0, n).map((e) => Map<String, dynamic>.from(e)).toList();
        bool islendi;
        try {
          islendi = await gonderici(grup);
        } catch (_) {
          islendi = false;
        }
        if (!islendi) break;
        _kuyruk.removeRange(0, min(n, _kuyruk.length));
      }
    } finally {
      _gonderiliyor = false;
    }
  }
}

/// Rota değişimlerinde ekran adını bildirir. Kök rota, sekmeli kabuk varken güncel sekme adına eşlenir.
class KullanimNavigatorObserver extends NavigatorObserver {
  KullanimNavigatorObserver(this._servis);

  final KullanimSuresi Function() _servis;

  String _ad(Route<dynamic>? r) {
    if (r == null) return 'bilinmeyen';
    final servis = _servis();
    final ad = r.settings.name;
    if (r.isFirst) return servis.sekmeAdi ?? (ad == null || ad == '/' ? 'kok' : ad);
    if (ad != null && ad.isNotEmpty) return ad;
    return r is PageRoute ? 'rota_adsiz' : 'iletisim_penceresi';
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _servis().ekranDegis(_ad(route));

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _servis().ekranDegis(_ad(previousRoute));

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _servis().ekranDegis(_ad(newRoute));

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _servis().ekranDegis(_ad(previousRoute));
}