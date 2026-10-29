// HUPO GİRİŞ FİLMİ: "Kelime Evreni" (yalnız cihazda ilk açılış, 5,0 sn).
//
// Gece olur, iki yıldız (Hupo'nun gözleri) yanar, gökyüzündeki noktalar Hupo'nun
// siluetinde toplanır, gözler açılır, "Hu-po-lin-go" imzası çalar, altın iz yazıyı
// sarar ve sabah olur. Senaryo ve zamanlar: docs/splash/GIRIS_FILMI.md; Remotion
// referansı: docs/splash/remotion/src/HupoGiris.tsx (aynı zaman çizelgesi, saniye cinsinden).
//
// Ağırlık kuralları (bilerek): video yok, yeni paket yok, Hupo'nun mevcut tek görseli
// (hero_splash.webp) + 28 KB göz yaması + 22 KB nokta verisi + 47 KB ses. Tek
// AnimationController, tek CustomPainter; çizim yalnız ilk açılışta çalışır. Kare
// süreleri yavaşsa (düşük uç cihaz) parçacıklar yarıya iner, izler ve ışımalar kalkar.
//
// Remotion sürümünden bilerek farklar: kanat sallanması yerine gövde hafifçe sallanır
// (kanat katmanı ≈ 190 KB ek görsel olurdu); bulanıklık/blur kullanılmaz.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../services/app_open_service.dart';
import '../../theme/app_theme.dart';

const String kGirisKaynakHero = 'assets/hupo/uygulama/hero_splash.webp';
const String kGirisKaynakGozKapali = 'assets/hupo/uygulama/hupo_goz_kapali.webp';
const String kGirisKaynakNoktalar = 'assets/hupo/uygulama/giris_noktalar.json';

/// Film süresi (saniye): zaman çizelgesi saniye cinsinden yazıldığı için karar katmanındaki süreden türetilir.
final double _kSure = kHupoSahneToplam.inMilliseconds / 1000;

// Hupo görseli 845x900 tuvalinde; göz yaması (165,121) konumundadır.
const double _kRW = 845;
const double _kRH = 900;
const Offset _kGozYamasi = Offset(165, 121);

/// Sistem (native) splash'indeki Hupo'nun boyu (dp): ilk karede aynı boyutta durur.
const double _kNativeBoy = 144;

const Color _kBirincil = AppColors.primary;
const List<Color> _kGece = [Color(0xFF021419), Color(0xFF06303A), Color(0xFF0A4651)];
const List<Color> _kSafak = [Color(0xFF0F6C78), Color(0xFF147D8A), Color(0xFF1B8A97)];
const String _kKelime = 'Hupolingo';
const String _kSlogan = 'Birlikte öğrenelim';

const Curve _kEaseOut = Cubic(0.16, 1, 0.3, 1);
const Curve _kEaseInOut = Cubic(0.65, 0, 0.35, 1);
const Curve _kEasePop = Cubic(0.34, 1.4, 0.64, 1);

/// Parçacık verisi (master Hupo'dan örneklenmiş; bkz. docs/splash/remotion/tools/noktalar_uret.py).
class _Noktalar {
  _Noktalar(this.adet, this.x, this.y, this.r, this.g, this.b, this.kenar, this.goz);

  final int adet;
  final List<double> x, y;
  final List<int> r, g, b;
  final List<bool> kenar;
  final List<Offset> goz;

  // Sabit tohumla üretilir: her çalıştırmada aynı görünüm.
  late final List<double> bx = _rastgele(adet, 1), by = _rastgele(adet, 2);
  late final List<double> gecik = _rastgele(adet, 3), yon = _rastgele(adet, 4);
  late final List<double> goruntu = _rastgele(adet, 5);

  /// Nokta başına başlangıç gecikmesi (sn): gözlerden uzaklaştıkça artar (yükleme anında bir kez hesaplanır).
  late final List<double> gecikS = [
    for (var i = 0; i < adet; i++)
      0.85 +
          0.5 * math.min(1.0, math.sqrt(math.pow(x[i] - (goz[0].dx + goz[1].dx) / 2, 2) + math.pow(y[i] - (goz[0].dy + goz[1].dy) / 2, 2)) / 620) +
          0.1 * gecik[i],
  ];

  static List<double> _rastgele(int n, int tohum) {
    final r = math.Random(tohum * 7919);
    return List<double>.generate(n, (_) => r.nextDouble());
  }

  static _Noktalar coz(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    final dizi = (m['n'] as List).cast<num>();
    final adet = dizi.length ~/ 6;
    final x = <double>[], y = <double>[];
    final r = <int>[], g = <int>[], b = <int>[];
    final kenar = <bool>[];
    for (var i = 0; i < adet; i++) {
      final o = i * 6;
      x.add(dizi[o].toDouble());
      y.add(dizi[o + 1].toDouble());
      r.add(dizi[o + 2].toInt());
      g.add(dizi[o + 3].toInt());
      b.add(dizi[o + 4].toInt());
      kenar.add(dizi[o + 5] == 1);
    }
    final goz = [
      for (final e in (m['goz'] as List)) Offset((e[0] as num).toDouble(), (e[1] as num).toDouble()),
    ];
    return _Noktalar(adet, x, y, r, g, b, kenar, goz);
  }
}

/// Painter'ın okuduğu, yüklendikçe dolan veri.
class _FilmVerisi {
  _Noktalar? noktalar;
  ui.Image? hero;
  ui.Image? gozKapali;

  void dispose() {
    hero?.dispose();
    gozKapali?.dispose();
  }
}

/// Giriş filmi. [onFinished] film bitince bir kez çağrılır.
class HupoGirisFilmi extends StatefulWidget {
  const HupoGirisFilmi({
    super.key,
    required this.onFinished,
    this.sesiBaslat,
    this.hazirlikZamanAsimi = const Duration(milliseconds: 1500),
    this.dusukKalite = false,
    @visibleForTesting this.onBasladi,
  });

  final VoidCallback onFinished;

  /// Film oynamaya başladığında (varlıklar hazır, ses beklemesi bitti) bir kez çağrılır. Testler içindir.
  final VoidCallback? onBasladi;

  /// Film başlamadan çağrılır; ses çalmaya başlayana kadar (en çok 350 ms) beklenir.
  /// Böylece ses ile görüntü aynı anda başlar. Hata olursa film sessiz sürer.
  final Future<void> Function()? sesiBaslat;

  /// Görseller/veri hazır olmazsa bu süreden sonra film yine de başlar.
  final Duration hazirlikZamanAsimi;

  /// true ise baştan düşük kalite (parçacıklar yarım, iz ve ışıma yok).
  final bool dusukKalite;

  @override
  State<HupoGirisFilmi> createState() => _HupoGirisFilmiState();
}

class _HupoGirisFilmiState extends State<HupoGirisFilmi> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final _veri = _FilmVerisi();
  bool _bildirildi = false;
  bool _dusuk = false;
  int _kare = 0;
  int _toplamMs = 0;

  @override
  void initState() {
    super.initState();
    _dusuk = widget.dusukKalite;
    _c = AnimationController(vsync: this, duration: kHupoSahneToplam);
    _c.addStatusListener(_durum);
    SchedulerBinding.instance.addTimingsCallback(_sureleriDinle);
    _hazirla();
  }

  /// Kare süreleri: ilk 30 karede ortalama > 18 ms ise kalite düşer (yalnız aşağı yönde).
  void _sureleriDinle(List<ui.FrameTiming> sureler) {
    if (_dusuk || _kare >= 30) return;
    for (final s in sureler) {
      _kare++;
      _toplamMs += s.totalSpan.inMilliseconds;
    }
    if (_kare >= 12 && _toplamMs / _kare > 18) _dusuk = true;
  }

  Future<void> _hazirla() async {
    final isler = <Future<void>>[
      rootBundle.loadString(kGirisKaynakNoktalar).then((s) {
        _veri.noktalar = _Noktalar.coz(s);
        rootBundle.evict(kGirisKaynakNoktalar); // 22 KB'lık metin önbellekte kalmasın
      }, onError: (_) {}),
      _resim(kGirisKaynakHero).then((i) => _veri.hero = i, onError: (_) {}),
      _resim(kGirisKaynakGozKapali).then((i) => _veri.gozKapali = i, onError: (_) {}),
    ];
    // Hazır olmayan parça atlanır; film mevcut parçalarla oynar.
    await _bekle(Future.wait(isler), widget.hazirlikZamanAsimi);
    if (!mounted) return;
    final ses = widget.sesiBaslat;
    if (ses != null) {
      Future<void> baslayan;
      try {
        baslayan = ses();
      } catch (_) {
        baslayan = Future<void>.value();
      }
      // Ses başlamazsa (web otomatik oynatma engeli vb.) film sessiz oynar.
      await _bekle(baslayan, const Duration(milliseconds: 350));
    }
    if (!mounted) return;
    _c.forward();
    widget.onBasladi?.call();
  }

  final List<Timer> _zamanlayicilar = [];

  /// [is_] bitene (hata dahil) ya da [sure] dolana kadar bekler. Zamanlayıcı dispose'ta iptal edilir.
  Future<void> _bekle(Future<Object?> is_, Duration sure) {
    final bitti = Completer<void>();
    final zaman = Timer(sure, () {
      if (!bitti.isCompleted) bitti.complete();
    });
    _zamanlayicilar.add(zaman);
    void tamam() {
      zaman.cancel();
      if (!bitti.isCompleted) bitti.complete();
    }

    is_.then((_) => tamam(), onError: (_) => tamam());
    return bitti.future;
  }

  Future<ui.Image> _resim(String yol) {
    final bitti = Completer<ui.Image>();
    final akim = AssetImage(yol).resolve(ImageConfiguration.empty);
    late final ImageStreamListener dinleyici;
    dinleyici = ImageStreamListener(
      (bilgi, _) {
        akim.removeListener(dinleyici);
        if (!bitti.isCompleted) bitti.complete(bilgi.image.clone());
      },
      onError: (e, _) {
        akim.removeListener(dinleyici);
        if (!bitti.isCompleted) bitti.completeError(e);
      },
    );
    akim.addListener(dinleyici);
    return bitti.future;
  }

  void _durum(AnimationStatus d) {
    if (d == AnimationStatus.completed && !_bildirildi) {
      _bildirildi = true;
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    for (final z in _zamanlayicilar) {
      z.cancel();
    }
    SchedulerBinding.instance.removeTimingsCallback(_sureleriDinle);
    _c.removeStatusListener(_durum);
    _c.dispose();
    _veri.dispose();
    // Film yalnız ilk açılışta oynar: çözülmüş görseller (≈ 3,5 MB bellek) bırakılır.
    final onbellek = PaintingBinding.instance.imageCache;
    onbellek.evict(const AssetImage(kGirisKaynakHero));
    onbellek.evict(const AssetImage(kGirisKaynakGozKapali));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _FilmPainter(anim: _c, veri: _veri, dusuk: () => _dusuk),
        ),
      ),
    );
  }
}

// ── Yardımcılar ──────────────────────────────────────────────────────────────

/// Parça parça doğrusal eşleme (Remotion `interpolate` ile aynı): her aralıkta [egri] uygulanır, uçlarda sabitlenir.
double _ip(double x, List<double> xs, List<double> ys, [Curve egri = Curves.linear]) {
  if (x <= xs.first) return ys.first;
  if (x >= xs.last) return ys.last;
  for (var i = 0; i < xs.length - 1; i++) {
    if (x <= xs[i + 1]) {
      final u = ((x - xs[i]) / (xs[i + 1] - xs[i])).clamp(0.0, 1.0);
      return ys[i] + (ys[i + 1] - ys[i]) * egri.transform(u);
    }
  }
  return ys.last;
}

Color _a(Color c, double alpha) => c.withValues(alpha: alpha.clamp(0.0, 1.0));

class _Xf {
  const _Xf(this.cx, this.cy, this.k, this.tilt, this.sx, this.sy);
  final double cx, cy, k, tilt, sx, sy;

  /// Hupo tuvali (845x900) koordinatını ekrana çevirir.
  Offset ekran(double px, double py) {
    final x = (px - _kRW / 2) * k * sx;
    final y = (py - _kRH / 2) * k * sy;
    final a = tilt * math.pi / 180;
    return Offset(cx + x * math.cos(a) - y * math.sin(a), cy + x * math.sin(a) + y * math.cos(a));
  }
}

class _Yildiz {
  const _Yildiz(this.fx, this.fy, this.r, this.z, this.ph);
  final double fx, fy, r, z, ph;
}

class _Glif {
  const _Glif(this.g, this.fx, this.fy, this.s, this.z, this.rot);
  final String g;
  final double fx, fy, s, z, rot;
}

// ── Çizici ───────────────────────────────────────────────────────────────────

class _FilmPainter extends CustomPainter {
  _FilmPainter({required this.anim, required this.veri, required this.dusuk}) : super(repaint: anim);

  final Animation<double> anim;
  final _FilmVerisi veri;
  final bool Function() dusuk;

  // Sabit tohumlu alan yıldızları ve harf bulutu (boyuttan bağımsız oranlar)
  static final List<_Yildiz> _yildizlar = () {
    final r = math.Random(31);
    return List<_Yildiz>.generate(110, (_) {
      final z = 0.35 + 0.65 * r.nextDouble();
      return _Yildiz(r.nextDouble(), r.nextDouble(), (0.9 + 2.2 * r.nextDouble()) * z * 1.4, z, r.nextDouble() * 6.28);
    });
  }();
  static final List<_Glif> _glifler = () {
    const harfler = ['ğ', 'ş', 'ı', 'ç', 'ö', 'ü', 'Ğ', 'Ş', 'İ', 'Ç', 'Ö', 'Ü', 'k', 'e', 'l', 'a'];
    final r = math.Random(47);
    return [
      for (final g in harfler)
        () {
          final z = 0.4 + 0.6 * r.nextDouble();
          return _Glif(g, r.nextDouble(), r.nextDouble(), 110 + 190 * z, z, (r.nextDouble() - 0.5) * 50);
        }(),
    ];
  }();
  static final List<List<List<double>>> _kivilcim = () {
    final r = math.Random(53);
    return List.generate(2, (_) => List.generate(7, (_) => [r.nextDouble() * 0.5, r.nextDouble(), r.nextDouble()]));
  }();
  static final Path _yildizYolu = Path()
    ..moveTo(0, -9)
    ..cubicTo(1, -2, 2, -1, 9, 0)
    ..cubicTo(2, 1, 1, 2, 0, 9)
    ..cubicTo(-1, 2, -2, 1, -9, 0)
    ..cubicTo(-2, -1, -1, -2, 0, -9)
    ..close();

  // Boyuta bağlı yazı önbelleği
  Size? _boyut;
  double _s = 1;
  bool _dikey = true;
  late List<TextPainter> _glifYazi;
  late List<TextPainter> _harfYazi;
  late List<double> _harfX;
  late TextPainter _sloganYazi;
  late Rect _kelimeKutu;
  late TextStyle _kelimeStil;

  final Paint _boya = Paint();

  void _yazilariKur(Size size) {
    _boyut = size;
    _parlakHarfler.clear();
    _dikey = size.height > size.width;
    _s = math.min(size.width, size.height) / 1080;

    _glifYazi = [
      for (final g in _glifler)
        TextPainter(
          text: TextSpan(
            text: g.g,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: g.s * _s,
              fontWeight: FontWeight.w900,
              color: _a(const Color(0xFFBFEAF0), 0.45 + 0.55 * g.z),
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];

    _kelimeStil = TextStyle(
      fontFamily: 'Nunito',
      fontSize: (_dikey ? 150 : 176) * _s,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      height: 1.15,
      letterSpacing: -2 * _s,
      shadows: [Shadow(color: const Color(0x52032830), blurRadius: 26 * _s, offset: Offset(0, 6 * _s))],
    );
    final tum = TextPainter(text: TextSpan(text: _kKelime, style: _kelimeStil), textDirection: TextDirection.ltr)..layout();
    _harfX = [
      for (var i = 0; i < _kKelime.length; i++) tum.getOffsetForCaret(TextPosition(offset: i), Rect.zero).dx,
    ];
    _harfYazi = [
      for (var i = 0; i < _kKelime.length; i++)
        TextPainter(text: TextSpan(text: _kKelime[i], style: _kelimeStil), textDirection: TextDirection.ltr)..layout(),
    ];
    final kw = tum.width, kh = tum.height;
    final sol = _dikey ? (size.width - kw) / 2 : size.width * 0.40;
    final ust = _dikey ? size.height * 0.645 : size.height * 0.40;
    _kelimeKutu = Rect.fromLTWH(sol, ust, kw, kh);

    _sloganYazi = TextPainter(
      text: TextSpan(
        text: _kSlogan,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: (_dikey ? 56 : 54) * _s,
          fontWeight: FontWeight.w700,
          color: _a(Colors.white, 0.96),
          letterSpacing: 1.5 * _s,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  final Map<int, TextPainter> _parlakHarfler = {};

  TextPainter _parlakHarf(int i, int kademe) => _parlakHarfler.putIfAbsent(
        i * 16 + kademe,
        () => TextPainter(
          text: TextSpan(
            text: _kKelime[i],
            style: _kelimeStil.copyWith(color: Color.lerp(Colors.white, const Color(0xFFFFE9A0), kademe / 8)),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
      );

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (_boyut != size) _yazilariKur(size);
    final w = size.width, h = size.height;
    final s = _s;
    final t = anim.value * _kSure;
    final dus = dusuk();

    // ── zaman değişkenleri (docs/splash/remotion/src/HupoGiris.tsx ile aynı) ──
    final faz = _ip(t, [0, 0.55, 1.9, 3.2], [0, 1, 1, 2], _kEaseInOut);
    final gece = _ip(faz, [0, 1, 2], [0, 1, 0]);
    final camS = _ip(t, [0.3, 2.6, 4.1], [1.0, 1.07, 1.0], _kEaseInOut);
    final c0 = Offset(w / 2, h / 2);

    final tabanCx = _dikey ? w / 2 : w * 0.21;
    final tabanCy = _dikey ? h * 0.41 : h * 0.5;
    final tabanK = (_dikey ? 0.86 : 0.74) * s;

    final havada = _ip(t, [0.9, 1.7], [0, 1]);
    final hover = math.sin((t - 0.9) * math.pi * 2 * 0.55) * 9 * s * havada;
    final hopT = t - 2.48;
    final sy = _ip(hopT, [-0.1, 0, 0.18, 0.42, 0.52, 0.66], [1, 0.93, 1.05, 1.0, 0.95, 1.0], _kEaseInOut);
    final sx = 1 + (1 - sy) * 0.55;
    final hopY = _ip(hopT, [0, 0.2, 0.42], [0, -46 * s, 0], _kEaseInOut);
    final nefes = 1 + 0.010 * math.sin((t - 3.3) * math.pi * 2 * 0.7) * _ip(t, [3.2, 3.6], [0, 1]);
    // Kanat katmanı yok: selam, gövdenin sönümlü hafif sallanmasıyla verilir.
    final selam = hopT > 0.1 ? -2.5 * math.sin((hopT - 0.1) * math.pi * 2 * 2.3) * math.exp(-(hopT - 0.1) * 2.4) : 0.0;
    final tilt = 1.6 * math.sin((t - 0.9) * math.pi * 2 * 0.37) * havada + _ip(hopT, [0, 0.2, 0.5], [0, -2.2, 0], _kEaseInOut) + selam;
    final xf = _Xf(tabanCx, tabanCy + hover + hopY, tabanK * nefes, tilt, sx, sy);

    final gozKapali = t < 2.52 || (t >= 3.08 && t < 3.2);
    final hupoOpak = _ip(t, [1.95, 2.45], [0, 1], _kEaseOut);
    final noktaOpak = _ip(t, [2.0, 2.55], [1, 0]);

    // ── 1) gökyüzü ──────────────────────────────────────────────────────────
    final bg = [
      for (var i = 0; i < 3; i++) faz <= 1 ? Color.lerp(_kBirincil, _kGece[i], faz)! : Color.lerp(_kGece[i], _kSafak[i], faz - 1)!,
    ];
    canvas.drawRect(
      Offset.zero & size,
      _boya
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, h), bg, const [0, 0.55, 1])
        ..color = Colors.white,
    );
    _boya.shader = null;

    final ufuk = _ip(t, [2.1, 3.3], [0, 1], _kEaseOut);
    if (ufuk > 0.01) {
      canvas.save();
      canvas.translate(w / 2, h * (_dikey ? 0.40 : 0.50));
      canvas.scale(w * 0.85, h * 0.42);
      canvas.drawCircle(
        Offset.zero,
        1,
        _boya
          ..shader = ui.Gradient.radial(Offset.zero, 1, [_a(const Color(0xFF96E1E8), 0.20 * ufuk), _a(const Color(0xFF96E1E8), 0)], const [0, 0.7])
          ..color = Colors.white,
      );
      _boya.shader = null;
      canvas.restore();
    }

    // ── 2) dünya (kamera itmesi) ───────────────────────────────────────────
    canvas.save();
    canvas.translate(c0.dx, c0.dy);
    canvas.scale(camS);
    canvas.translate(-c0.dx, -c0.dy);

    _glifBulutu(canvas, size, t, gece, ufuk, s);
    _alanYildizlari(canvas, size, t, gece, ufuk, s);
    _parcaciklar(canvas, size, t, xf, noktaOpak, s, tabanK, dus);
    _gozYildizlari(canvas, t, xf, s);

    // Hupo'nun arkasında yumuşak hale
    final haleOpak = _ip(t, [1.7, 2.3, 3.4], [0, 0.55, 0.22], _kEaseInOut);
    if (haleOpak > 0.01) {
      final r = 520 * s;
      canvas.drawCircle(
        Offset(xf.cx, xf.cy),
        r,
        _boya
          ..shader = ui.Gradient.radial(Offset(xf.cx, xf.cy), r, [_a(const Color(0xFFFFF3C8), 0.55 * haleOpak), _a(const Color(0xFFFFF3C8), 0)], const [0, 0.62])
          ..color = Colors.white,
      );
      _boya.shader = null;
    }

    _hupo(canvas, xf, hupoOpak, gozKapali);
    // Sistem splash'indeki Hupo: ilk kare onunla aynı, sonra gecede erir
    final hayalet = 1 - _kEaseInOut.transform((t / 0.35).clamp(0.0, 1.0));
    if (hayalet > 0.01) _hayaletHupo(canvas, size, hayalet);
    canvas.restore();

    // ── 3) marka katmanı: yazı, altın iz, slogan (kamera dışı) ─────────────────
    _kelimeVeIz(canvas, size, t, xf, camS, c0, s, dus);
  }

  // ---------- parçalar ----------

  void _glifBulutu(Canvas canvas, Size size, double t, double gece, double ufuk, double s) {
    final op = gece * (1 - ufuk * 0.9) * 0.10;
    if (op < 0.004) return;
    canvas.saveLayer(Offset.zero & size, Paint()..color = Color.fromRGBO(255, 255, 255, op.clamp(0.0, 1.0)));
    for (var i = 0; i < _glifler.length; i++) {
      final g = _glifler[i];
      final p = _glifYazi[i];
      canvas.save();
      canvas.translate(g.fx * size.width, g.fy * size.height - t * 14 * g.z * s);
      canvas.rotate((g.rot + t * 2 * g.z) * math.pi / 180);
      p.paint(canvas, Offset.zero);
      canvas.restore();
    }
    canvas.restore();
  }

  void _alanYildizlari(Canvas canvas, Size size, double t, double gece, double ufuk, double s) {
    final taban = gece * (1 - ufuk * 0.75);
    if (taban < 0.01) return;
    for (final y in _yildizlar) {
      final tw = 0.55 + 0.45 * math.sin(t * 2.2 + y.ph);
      final o = taban * tw * (0.35 + 0.65 * y.z);
      final yy = (((y.fy * size.height - t * 10 * y.z * s) % size.height) + size.height) % size.height;
      canvas.drawCircle(Offset(y.fx * size.width, yy), y.r * s, _boya..color = _a(const Color(0xFFE8FBFF), o));
    }
  }

  void _parcaciklar(Canvas canvas, Size size, double t, _Xf xf, double noktaOpak, double s, double tabanK, bool dus) {
    final nk = veri.noktalar;
    if (nk == null || noktaOpak <= 0.01 || t < 0.5) return;
    final adim = dus ? 2 : 1;
    final iz = _boya
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Hupo dönüşümü kare başına bir kez hesaplanır (nokta başına sin/cos yok).
    final aci = xf.tilt * math.pi / 180;
    final ca = math.cos(aci), sa = math.sin(aci);
    final kx = xf.k * xf.sx, ky = xf.k * xf.sy;
    final kenarR = 5.2 * tabanK * (dus ? 1.35 : 1.0);
    final icR = 6.4 * tabanK * (dus ? 1.35 : 1.0);
    final w = size.width, h = size.height;

    for (var i = 0; i < nk.adet; i += adim) {
      final ga = 0.55 + 0.4 * nk.goruntu[i];
      final gorunur = ((t - ga) / (1.0 + 0.3 * nk.goruntu[i] - ga)).clamp(0.0, 1.0);
      if (gorunur <= 0.01) continue;
      final u = ((t - nk.gecikS[i]) / 0.62).clamp(0.0, 1.0);
      final e = _kEaseOut.transform(u);

      final lx = (nk.x[i] - _kRW / 2) * kx, ly = (nk.y[i] - _kRH / 2) * ky;
      final hx = xf.cx + lx * ca - ly * sa, hy = xf.cy + lx * sa + ly * ca;
      final bx = nk.bx[i] * w, by = nk.by[i] * h;
      final yon = nk.yon[i] > 0.5 ? 0.35 : -0.35;
      final vx = hx - bx, vy = hy - by;
      final cx = (bx + hx) / 2 - vy * yon, cy = (by + hy) / 2 + vx * yon;

      final m = 1 - e;
      final px = m * m * bx + 2 * m * e * cx + e * e * hx;
      final py = m * m * by + 2 * m * e * cy + e * e * hy;
      final yolda = u > 0 && u < 1;
      final rHedef = nk.kenar[i] ? kenarR : icR;
      final r = u < 0.85 ? 1.4 * s + (rHedef * 0.9 - 1.4 * s) * (u / 0.85) : rHedef * 0.9 + (rHedef * 0.1) * ((u - 0.85) / 0.15);
      final o = gorunur * noktaOpak * (u < 1 ? 0.55 + 0.45 * u : 1.0);

      // Kısa kuyruk yalnız her üçüncü parçacıkta: görünüm aynı, çizim sayısı %33 az.
      if (yolda && !dus && i % 3 == 0) {
        final e2 = math.max(0.0, e - 0.05);
        final m2 = 1 - e2;
        iz
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.9
          ..color = _a(const Color(0xFFDFF7FB), 0.3 * (1 - u) * o);
        canvas.drawLine(
          Offset(m2 * m2 * bx + 2 * m2 * e2 * cx + e2 * e2 * hx, m2 * m2 * by + 2 * m2 * e2 * cy + e2 * e2 * hy),
          Offset(px, py),
          iz,
        );
      }
      iz
        ..style = PaintingStyle.fill
        ..color = u < 1 ? _a(const Color(0xFFEAFCFF), o) : _a(Color.fromARGB(255, nk.r[i], nk.g[i], nk.b[i]), o);
      canvas.drawCircle(Offset(px, py), r, iz);
    }
    iz.style = PaintingStyle.fill;
  }
  void _yildizCiz(Canvas canvas, Offset merkez, double boyut, double donus, Color renk) {
    canvas.save();
    canvas.translate(merkez.dx, merkez.dy);
    canvas.rotate(donus * math.pi / 180);
    canvas.scale(boyut / 18);
    canvas.drawPath(_yildizYolu, _boya..color = renk);
    canvas.restore();
  }

  void _gozYildizlari(Canvas canvas, double t, _Xf xf, double s) {
    final nk = veri.noktalar;
    if (nk == null) return;
    final opak = _ip(t, [0.45, 0.95], [0, 1], _kEaseOut) * _ip(t, [2.38, 2.52], [1, 0]);
    final nabiz = 1 + 0.12 * math.sin((t - 0.45) * math.pi * 2 * 1.4);
    final boyut = 112 * s * _ip(t, [0.45, 0.95], [0.2, 1], _kEasePop) * nabiz;
    for (var gi = 0; gi < 2; gi++) {
      final m = xf.ekran(nk.goz[gi].dx, nk.goz[gi].dy);
      if (opak > 0.01) {
        final r = boyut * 0.95;
        canvas.drawCircle(
          m,
          r,
          _boya
            ..shader = ui.Gradient.radial(m, r, [_a(Colors.white, 0.7 * opak), _a(const Color(0xFFFFF6CF), 0.4 * opak), _a(const Color(0xFFFFF6CF), 0)], const [0, 0.35, 1])
            ..color = Colors.white,
        );
        _boya.shader = null;
        _yildizCiz(canvas, m, boyut, gi == 0 ? -6 : 8, _a(Colors.white, opak));
      }
      // gözler açılınca küçük kıvılcım serpintisi
      final patla = t - 2.5;
      if (patla > 0 && patla < 0.7) {
        final pr = _kEaseOut.transform(patla / 0.7);
        for (var k = 0; k < 7; k++) {
          final v = _kivilcim[gi][k];
          final a = (k / 7) * math.pi * 2 + gi * 0.6 + v[0];
          final dist = (70 + 70 * v[1]) * s * pr;
          final sz = (14 + 14 * v[2]) * s * (1 - pr);
          _yildizCiz(canvas, m + Offset(math.cos(a) * dist, math.sin(a) * dist), sz, 0, _a(k.isOdd ? AppColors.sun : Colors.white, 1 - pr * 0.6));
        }
      }
    }
  }

  void _hupo(Canvas canvas, _Xf xf, double opak, bool gozKapali) {
    final hero = veri.hero;
    if (hero == null || opak <= 0.005) return;
    final boya = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = Color.fromRGBO(255, 255, 255, opak);
    canvas.save();
    canvas.translate(xf.cx, xf.cy);
    canvas.rotate(xf.tilt * math.pi / 180);
    canvas.scale(xf.k * xf.sx, xf.k * xf.sy);
    canvas.translate(-_kRW / 2, -_kRH / 2);
    canvas.drawImage(hero, Offset.zero, boya);
    final goz = veri.gozKapali;
    if (gozKapali && goz != null) canvas.drawImage(goz, _kGozYamasi, boya);
    canvas.restore();
  }

  void _hayaletHupo(Canvas canvas, Size size, double opak) {
    final hero = veri.hero;
    if (hero == null) return;
    const k = _kNativeBoy / _kRH;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(k);
    canvas.translate(-_kRW / 2, -_kRH / 2);
    canvas.drawImage(
      hero,
      Offset.zero,
      Paint()
        ..filterQuality = FilterQuality.medium
        ..color = Color.fromRGBO(255, 255, 255, opak),
    );
    canvas.restore();
  }

  void _kelimeVeIz(Canvas canvas, Size size, double t, _Xf xf, double camS, Offset c0, double s, bool dus) {
    final kutu = _kelimeKutu;

    // harfler: sırayla yükselir, sonra soldan sağa kısa bir parlama geçer
    if (t > 2.99) {
      for (var i = 0; i < _kKelime.length; i++) {
        final b = 3.0 + i * 0.055;
        final p = _ip(t, [b, b + 0.45], [0, 1], _kEaseOut);
        if (p <= 0.003) continue;
        final g = math.exp(-math.pow((t - (3.95 + i * 0.06)) / 0.11, 2));
        // Parlama 8 kademeye yuvarlanır: her harf için en çok 8 yazı nesnesi kurulur, kare başına yerleşim yapılmaz.
        final kademe = (g * 8).round();
        final yazi = kademe >= 1 ? _parlakHarf(i, kademe) : _harfYazi[i];
        final konum = Offset(kutu.left + _harfX[i], kutu.top + (1 - p) * 54 * s - g * 4 * s);
        if (p < 0.999) {
          canvas.saveLayer((konum & yazi.size).inflate(30 * s), Paint()..color = Color.fromRGBO(255, 255, 255, p));
          yazi.paint(canvas, konum);
          canvas.restore();
        } else {
          yazi.paint(canvas, konum);
        }
      }
    }

    // slogan
    final sloganOpak = _ip(t, [4.1, 4.55], [0, 1], _kEaseOut);
    if (sloganOpak > 0.01) {
      final x = _dikey ? (size.width - _sloganYazi.width) / 2 : kutu.left;
      final y = kutu.bottom + 84 * s + (1 - sloganOpak) * 16 * s;
      canvas.saveLayer(Rect.fromLTWH(x, y, _sloganYazi.width, _sloganYazi.height).inflate(8), Paint()..color = Color.fromRGBO(255, 255, 255, sloganOpak));
      _sloganYazi.paint(canvas, Offset(x, y));
      canvas.restore();
    }

    // altın kanat izi: kanat ucundan başlar, yazıyı sarıp altına oturur
    final ilerleme = _ip(t, [3.12, 3.95], [0, 1], _kEaseInOut);
    if (ilerleme <= 0.001) return;
    final tipDunya = xf.ekran(806, 100);
    final tip = Offset(c0.dx + (tipDunya.dx - c0.dx) * camS, c0.dy + (tipDunya.dy - c0.dy) * camS);
    final xL = kutu.left + kutu.width * 0.02;
    final xR = kutu.left + kutu.width * 0.98;
    final yU = kutu.bottom + 10 * s;
    final x1 = math.min(size.width - 70 * s, xR + 70 * s);
    final yol = Path()..moveTo(tip.dx, tip.dy);
    if (_dikey) {
      yol
        ..cubicTo(tip.dx + 190 * s, tip.dy + 30 * s, x1 + 40 * s, kutu.top - 380 * s, x1, kutu.top - 70 * s)
        ..cubicTo(x1 - 10 * s, kutu.top + kutu.height * 0.55, xR + 20 * s, yU + 38 * s, xR - 70 * s, yU + 30 * s);
    } else {
      yol
        ..cubicTo(tip.dx + 230 * s, tip.dy - 40 * s, x1 + 60 * s, kutu.top - 150 * s, x1, kutu.top + kutu.height * 0.15)
        ..cubicTo(x1 - 8 * s, kutu.top + kutu.height * 0.7, xR + 20 * s, yU + 38 * s, xR - 70 * s, yU + 30 * s);
    }
    yol.cubicTo(kutu.left + kutu.width * 0.62, yU + 46 * s, kutu.left + kutu.width * 0.28, yU + 40 * s, xL, yU - 6 * s);

    final olcu = yol.computeMetrics().first;
    final kisim = olcu.extractPath(0, olcu.length * ilerleme);
    final boya = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (!dus) {
      canvas.drawPath(kisim, boya..strokeWidth = 26 * s..color = _a(AppColors.sun, 0.16));
    }
    canvas.drawPath(
      kisim,
      boya
        ..strokeWidth = 10 * s
        ..color = Colors.white // gölge katmanın yarı saydam rengi gradyanı soldurmasın
        ..shader = ui.Gradient.linear(Offset(kutu.right, kutu.top), Offset(kutu.left, kutu.bottom), const [Color(0xFFFFE08A), AppColors.sun, AppColors.sunDark], const [0, 0.55, 1]),
    );
    if (ilerleme < 1) {
      final bas = olcu.getTangentForOffset(olcu.length * ilerleme)!.position;
      canvas.drawCircle(
        bas,
        46 * s,
        Paint()..shader = ui.Gradient.radial(bas, 46 * s, [Colors.white, _a(const Color(0xFFFFE9A0), 0.6), _a(const Color(0xFFFFE9A0), 0)], const [0, 0.4, 1]),
      );
      _yildizCiz(canvas, bas, 30 * s, 0, const Color(0xFFFFFBE6));
    }
  }

  @override
  bool shouldRepaint(covariant _FilmPainter old) => old.anim != anim || old.veri != veri;
}
