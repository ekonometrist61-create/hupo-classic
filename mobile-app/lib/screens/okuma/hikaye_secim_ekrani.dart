import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/okuma_degerler.dart';
import '../../models/okuma_models.dart';
import '../../widgets/hupo/hupo.dart';
import '../../widgets/okuma/okuma_bilesenler.dart';
import '../../widgets/okuma/okuma_v3.dart';
import 'okuma_tema.dart';

/// Hikâye seçme ekranı. Hedef: çocuk, kahramanına uygun hikâyelerden birini seçer.
/// Ana eylem: bir hikâye kartına dokunmak. Durumlar: yükleniyor, hata (yeniden dene), boş
/// (bu kahraman için hikâyeler hazırlanıyor), filtre boş, geri dönüş mesajı.
class HikayeSecimEkrani extends StatefulWidget {
  const HikayeSecimEkrani({
    super.key,
    this.ilkTur,
    required this.katalog,
    required this.kahramanAdi,
    required this.onSec,
    required this.onGeri,
    this.yukleniyor = false,
    this.hata,
    this.onYenidenDene,
    this.onOkuduklarim,
    this.geriDonusMesaji,
  });

  final List<OkumaKatalogSatiri> katalog;

  /// Verilirse liste bu türle filtreli açılır (kategori kapağından).
  final String? ilkTur;

  /// Başlıkta gösterilir; yalnız cihazda kalır.
  final String kahramanAdi;
  final void Function(OkumaKatalogSatiri) onSec;
  final VoidCallback onGeri;
  final bool yukleniyor;
  final String? hata;
  final VoidCallback? onYenidenDene;

  /// null ise "Okuduklarım" düğmesi gösterilmez.
  final VoidCallback? onOkuduklarim;

  /// Uzun süre okumayan çocuk için nazik geri dönüş mesajı (null ise gösterilmez).
  final String? geriDonusMesaji;

  @override
  State<HikayeSecimEkrani> createState() => _HikayeSecimEkraniState();
}

class _HikayeSecimEkraniState extends State<HikayeSecimEkrani> {
  late String? _tur = widget.ilkTur;

  /// Seçili değer (D-kodu). Hem ana hem yardımcı değere göre eşleşir.
  String? _deger;

  /// Yalnız veli tercihiyle eşleşen hikâyeler.
  bool _veliTercihi = false;

  void _filtreleriTemizle() => setState(() {
        _tur = null;
        _deger = null;
        _veliTercihi = false;
      });

  @override
  Widget build(BuildContext context) {
    final uygunlar = widget.katalog;
    final turler = {for (final h in uygunlar) h.tur}.toList();
    final degerKumesi = <String>{};
    for (final h in uygunlar) {
      if (h.anaDeger != null) degerKumesi.add(h.anaDeger!);
      if (h.yardimciDeger != null) degerKumesi.add(h.yardimciDeger!);
    }
    final degerler = degerKumesi.toList()..sort((a, b) => okumaDegerSirasi(a).compareTo(okumaDegerSirasi(b)));
    final veliTercihiVar = uygunlar.any((h) => h.degerEslesmesi);
    final liste = uygunlar
        .where((h) => _tur == null || h.tur == _tur)
        .where((h) => _deger == null || h.anaDeger == _deger || h.yardimciDeger == _deger)
        .where((h) => !_veliTercihi || h.degerEslesmesi)
        .toList();
    return OkumaEkranIskeleti(
      baslik: OkumaMetin.uygulamaAdi,
      geri: widget.onGeri,
      eylemler: [
        if (widget.onOkuduklarim != null)
          IconButton(
            tooltip: OkumaMetin.okuduklarimBaslik,
            icon: const Icon(Icons.auto_stories_rounded),
            onPressed: widget.onOkuduklarim,
          ),
      ],
      icerik: [
        BaslikSatiri(
          baslik: OkumaMetin.hikayeBaslik,
          alt: OkumaMetin.hikayeAlt(widget.kahramanAdi),
          maskotSolda: false,
          maskot: const OkumaMaskot(poz: HupoPose.merakEdiyor, boyut: OkumaTema.hupoBaslik),
        ),
        if (widget.geriDonusMesaji != null) ...[
          const SizedBox(height: OkumaTema.bosluk16),
          Container(
            padding: const EdgeInsets.all(OkumaTema.bosluk16),
            decoration: BoxDecoration(color: OkumaTema.sunSoft, borderRadius: BorderRadius.circular(OkumaTema.koseKart)),
            child: Text(
              widget.geriDonusMesaji!,
              style: OkumaTema.yazi(OkumaTema.yaziSecenek, kalinlik: OkumaTema.kalinlikVurgu),
            ),
          ),
        ],
        const SizedBox(height: OkumaTema.bosluk20),
        if (widget.yukleniyor)
          const _Yukleniyor()
        else if (widget.hata != null)
          DurumEkrani(
            poz: HupoPose.birDahaDene,
            baslik: widget.hata!,
            birincilEtiket: OkumaMetin.yenidenDene,
            birincil: widget.onYenidenDene,
            ikincilEtiket: OkumaMetin.kahramanDegistir,
            ikincil: widget.onGeri,
          )
        else ...[
          if (turler.isNotEmpty)
            _TurIzgarasi(
              turler: turler,
              secili: _tur,
              onSec: (t) => setState(() => _tur = t),
            ),
          if (degerler.isNotEmpty || veliTercihiVar) ...[
            const SizedBox(height: OkumaTema.bosluk12),
            Wrap(
              spacing: OkumaTema.bosluk8,
              runSpacing: OkumaTema.bosluk8,
              children: [
                if (veliTercihiVar)
                  FilterChip(
                    label: const Text(OkumaMetin.degerVeliTercihi),
                    selected: _veliTercihi,
                    onSelected: (v) => setState(() => _veliTercihi = v),
                  ),
                for (final d in degerler)
                  FilterChip(
                    label: Text(okumaDegerAdi(d)),
                    selected: _deger == d,
                    onSelected: (v) => setState(() => _deger = v ? d : null),
                  ),
              ],
            ),
          ],
          const SizedBox(height: OkumaTema.bosluk20),
          if (uygunlar.isEmpty)
            DurumEkrani(
              poz: HupoPose.dusunuyor,
              baslik: OkumaMetin.hikayeKahramanYokBaslik,
              aciklama: OkumaMetin.hikayeKahramanYok,
              birincilEtiket: OkumaMetin.kahramanDegistir,
              birincil: widget.onGeri,
            )
          else if (liste.isEmpty)
            DurumEkrani(
              poz: HupoPose.dusunuyor,
              baslik: OkumaMetin.hikayeBos,
              aciklama: OkumaMetin.hikayeBosIpucu,
              birincilEtiket: OkumaMetin.hikayeFiltreTemizle,
              birincil: _filtreleriTemizle,
            )
          else
            for (final h in liste)
              Padding(
                padding: const EdgeInsets.only(bottom: OkumaTema.bosluk16),
                child: _HikayeKapak(hikaye: h, onTap: () => widget.onSec(h)),
              ),
        ],
      ],
    );
  }
}

/// Tür kapağı görselleri (vitrin illüstrasyonları). Görseli olmayan türler tür renginde zemin ve
/// ikon kullanır; yeni illüstrasyon gelince bu tabloya bir satır eklenir.
const _turGorselleri = <String, String>{
  'macera': 'assets/okuma/vitrin/macera_ust.jpg',
  'gizem': 'assets/okuma/vitrin/gizem_ust.jpg',
  'bilim_kurgu': 'assets/okuma/vitrin/uzay_ust.jpg',
};

/// Öncelikli türler (ızgarada görünür); katalogda olmayanlar atlanır, kalan türler "Daha fazla" altındadır.
const _anaTurler = ['macera', 'gizem', 'bilim', 'mizah', 'bilim_kurgu', 'arkadaslik'];

/// Tür seçimi: iki sütunlu, illüstrasyonlu kartlar. İlk kart "Hepsi"dir (tür filtresini kaldırır).
/// En çok 8 kart: Hepsi + en çok 6 öncelikli tür + "Daha fazla" (diğer türler alt sayfada).
class _TurIzgarasi extends StatelessWidget {
  const _TurIzgarasi({required this.turler, required this.secili, required this.onSec});

  final List<String> turler;

  /// Seçili tür kodu; null ise "Hepsi" seçilidir.
  final String? secili;
  final ValueChanged<String?> onSec;

  void _digerTurler(BuildContext context, List<String> gizli) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: OkumaTema.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(OkumaTema.koseAltSayfa)),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(OkumaTema.bosluk16, OkumaTema.bosluk20, OkumaTema.bosluk16, OkumaTema.bosluk16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk8),
                  child: Text(
                    OkumaMetin.turDigerBaslik,
                    style: OkumaTema.yazi(OkumaTema.yaziSecenek, kalinlik: OkumaTema.kalinlikBaslik),
                  ),
                ),
              ),
              const SizedBox(height: OkumaTema.bosluk8),
              for (final t in gizli)
                Semantics(
                  button: true,
                  selected: secili == t,
                  label: okumaTurStili(t).etiket,
                  child: ExcludeSemantics(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        onSec(t);
                      },
                      borderRadius: BorderRadius.circular(OkumaTema.koseKart),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: OkumaTema.dokunmaMin),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk8, vertical: OkumaTema.bosluk8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  okumaTurStili(t).etiket,
                                  style: OkumaTema.yazi(
                                    OkumaTema.yaziSecenek,
                                    kalinlik: secili == t ? OkumaTema.kalinlikBaslik : OkumaTema.kalinlikVurgu,
                                  ),
                                ),
                              ),
                              if (secili == t) const Icon(Icons.check_circle_rounded, color: OkumaTema.primary, size: OkumaTema.ikonOrta),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gorunen = [for (final t in _anaTurler) if (turler.contains(t)) t];
    final gizli = [for (final t in turler) if (!gorunen.contains(t)) t];
    final kartlar = [
      _TurKarti(
        kod: null,
        etiket: OkumaMetin.hikayeHepsi,
        simge: 'book',
        secili: secili == null,
        onTap: () => onSec(null),
      ),
      for (final t in gorunen)
        _TurKarti(
          kod: t,
          etiket: okumaTurStili(t).etiket,
          simge: okumaTurStili(t).simge,
          secili: secili == t,
          onTap: () => onSec(t),
        ),
      if (gizli.isNotEmpty)
        _TurKarti(
          kod: 'daha',
          etiket: OkumaMetin.turDahaFazla,
          simge: 'book',
          secili: secili != null && gizli.contains(secili),
          onTap: () => _digerTurler(context, gizli),
        ),
    ];
    // Büyük yazıda (ölçek 1,5 üstü) tek sütun: etiketler kelime ortasından kırılmaz.
    final tekSutun = MediaQuery.textScalerOf(context).scale(OkumaTema.yaziYardimci) > 24;
    if (tekSutun) {
      return Column(
        children: [
          for (var i = 0; i < kartlar.length; i++) ...[
            if (i > 0) const SizedBox(height: OkumaTema.bosluk12),
            kartlar[i],
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < kartlar.length; i += 2) ...[
          if (i > 0) const SizedBox(height: OkumaTema.bosluk12),
          // Tek kalan kart tüm genişliği alır; yarım boş sütun bırakmaz.
          if (i + 1 < kartlar.length)
            Row(
              children: [
                Expanded(child: kartlar[i]),
                const SizedBox(width: OkumaTema.bosluk12),
                Expanded(child: kartlar[i + 1]),
              ],
            )
          else
            kartlar[i],
        ],
      ],
    );
  }
}

class _TurKarti extends StatelessWidget {
  const _TurKarti({
    required this.kod,
    required this.etiket,
    required this.simge,
    required this.secili,
    required this.onTap,
  });

  /// Tür kodu (sahne ve renkler için); null ise "Hepsi".
  final String? kod;
  final String etiket;
  final String simge;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sure = OkumaTema.sure(context, OkumaTema.hareketAciklama);
    final gorsel = _turGorselleri[kod];
    return Semantics(
      button: true,
      selected: secili,
      label: etiket,
      child: ExcludeSemantics(
        // Seçili kart etrafında marka renkli çerçeve; çerçeve her durumda yer kaplar, kayma olmaz.
        child: AnimatedContainer(
          duration: sure,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: secili ? OkumaTema.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(OkumaTema.koseKart + 3),
          ),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(OkumaTema.koseKart),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(OkumaTema.koseKart),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _turRenkleri(kod),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 80),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: gorsel == null
                            ? CustomPaint(painter: _TurSahnesi(kod))
                            : Image.asset(gorsel, fit: BoxFit.cover, alignment: const Alignment(0, -0.4), excludeFromSemantics: true),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [const Color(0x00000000), OkumaTema.ink.withAlpha(170)],
                              stops: const [0.4, 1],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(OkumaTema.bosluk8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: Color(0xEBFFFFFF), shape: BoxShape.circle),
                                  child: OkumaKatalogIkon(simge, boyut: 22),
                                ),
                                const Spacer(),
                                if (secili)
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(color: OkumaTema.primary, shape: BoxShape.circle),
                                    child: const Icon(Icons.check_rounded, color: OkumaTema.surface, size: 16),
                                  ),
                              ],
                            ),
                            const SizedBox(height: OkumaTema.bosluk8),
                            Text(
                              etiket,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikBaslik, renk: OkumaTema.surface, satir: 1.1)
                                  .copyWith(shadows: const [Shadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 1))]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tür kartının gradyan renkleri (üstten alta). Yalnız uygulama tokenları.
List<Color> _turRenkleri(String? kod) => switch (kod) {
      null || 'daha' => const [OkumaTema.primary, OkumaTema.primaryDark],
      'macera' => const [OkumaTema.sun, OkumaTema.coral],
      'bilim' => const [OkumaTema.skyDark, OkumaTema.primaryDark],
      'gizem' => const [OkumaTema.primary, OkumaTema.ink],
      'mizah' => const [OkumaTema.sun, OkumaTema.coralDark],
      'bilim_kurgu' => const [OkumaTema.skyDark, OkumaTema.ink],
      'arkadaslik' => const [OkumaTema.coral, OkumaTema.coralDark],
      'fantastik' => const [OkumaTema.primaryDark, OkumaTema.ink],
      'tarih_kultur' || 'gezi_kultur' => const [OkumaTema.sun, OkumaTema.mintDark],
      _ => const [OkumaTema.mint, OkumaTema.mintDark],
    };

/// Kartın arka plan sahnesi: düz şekillerle çizilir (görsel dosyası gerekmez).
class _TurSahnesi extends CustomPainter {
  const _TurSahnesi(this.kod);

  final String? kod;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    Paint dolu(Color c) => Paint()..color = c;
    Paint cizgi(Color c, double k) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = k
      ..strokeCap = StrokeCap.round;
    void tepe(double x, double tepeY, double g, Color c) {
      final p = Path()
        ..moveTo(x - g, h)
        ..lineTo(x, tepeY)
        ..lineTo(x + g, h)
        ..close();
      canvas.drawPath(p, dolu(c));
    }

    const yari = Color(0xB3FFFFFF);
    const hafif = Color(0x40FFFFFF);
    switch (kod) {
      case 'macera':
        canvas.drawCircle(Offset(w * 0.8, h * 0.3), h * 0.2, dolu(OkumaTema.sunSoft));
        tepe(w * 0.38, h * 0.22, w * 0.42, OkumaTema.mint.withAlpha(200));
        tepe(w * 0.72, h * 0.38, w * 0.46, OkumaTema.mintDark);
        tepe(w * 0.16, h * 0.56, w * 0.32, OkumaTema.mintDark.withAlpha(230));
      case 'bilim':
        final merkez = Offset(w * 0.74, h * 0.42);
        for (final aci in [-0.5, 0.9]) {
          canvas.save();
          canvas.translate(merkez.dx, merkez.dy);
          canvas.rotate(aci);
          canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.62, height: h * 0.3), cizgi(yari, 2.5));
          canvas.restore();
        }
        canvas.drawCircle(merkez, h * 0.1, dolu(OkumaTema.surface));
        canvas.drawCircle(Offset(w * 0.9, h * 0.22), h * 0.04, dolu(OkumaTema.sun));
      case 'gizem':
        canvas.drawCircle(Offset(w * 0.8, h * 0.3), h * 0.2, dolu(OkumaTema.surface.withAlpha(230)));
        canvas.drawCircle(Offset(w * 0.87, h * 0.24), h * 0.17, dolu(OkumaTema.primary));
        for (final p in [Offset(w * 0.12, h * 0.2), Offset(w * 0.4, h * 0.12), Offset(w * 0.55, h * 0.35), Offset(w * 0.25, h * 0.4)]) {
          canvas.drawCircle(p, 2.5, dolu(yari));
        }
        final colina = Path()
          ..moveTo(0, h * 0.8)
          ..quadraticBezierTo(w * 0.3, h * 0.55, w * 0.6, h * 0.78)
          ..quadraticBezierTo(w * 0.85, h * 0.6, w, h * 0.75)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();
        canvas.drawPath(colina, dolu(OkumaTema.ink.withAlpha(90)));
      case 'mizah':
        final merkez = Offset(w * 0.78, h * 0.3);
        for (var i = 0; i < 14; i++) {
          final aci = i * 2 * 3.14159265 / 14;
          canvas.drawLine(
            merkez + Offset(h * 0.24 * _cos(aci), h * 0.24 * _sin(aci)),
            merkez + Offset(h * 0.42 * _cos(aci), h * 0.42 * _sin(aci)),
            cizgi(hafif, 4),
          );
        }
        canvas.drawCircle(merkez, h * 0.18, dolu(OkumaTema.sunSoft));
      case 'bilim_kurgu':
        final gezegen = Offset(w * 0.74, h * 0.46);
        canvas.drawCircle(gezegen, h * 0.24, dolu(OkumaTema.primaryLight.withAlpha(220)));
        canvas.save();
        canvas.translate(gezegen.dx, gezegen.dy);
        canvas.rotate(-0.25);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.8, height: h * 0.22), cizgi(OkumaTema.sun, 5));
        canvas.restore();
        for (final p in [Offset(w * 0.12, h * 0.18), Offset(w * 0.3, h * 0.08), Offset(w * 0.9, h * 0.1)]) {
          canvas.drawCircle(p, 2.2, dolu(yari));
        }
      case 'arkadaslik':
        canvas.drawCircle(Offset(w * 0.6, h * 0.5), h * 0.22, dolu(OkumaTema.sun.withAlpha(200)));
        canvas.drawCircle(Offset(w * 0.82, h * 0.4), h * 0.22, dolu(OkumaTema.mint.withAlpha(200)));
        canvas.drawCircle(Offset(w * 0.72, h * 0.7), h * 0.2, dolu(OkumaTema.surface.withAlpha(170)));
      case null:
        for (final (c, r) in [(OkumaTema.sun, 0.5), (OkumaTema.coral, 0.4), (OkumaTema.mint, 0.3), (OkumaTema.surface, 0.2)]) {
          canvas.drawArc(
            Rect.fromCircle(center: Offset(w * 0.85, h * 1.05), radius: h * r),
            3.14159265,
            3.14159265,
            false,
            cizgi(c, 9),
          );
        }
      default:
        canvas.drawCircle(Offset(w * 0.85, h * 0.25), h * 0.3, dolu(hafif));
        canvas.drawCircle(Offset(w * 0.15, h * 0.95), h * 0.4, dolu(hafif));
    }
  }

  static double _cos(double a) => math.cos(a);
  static double _sin(double a) => math.sin(a);

  @override
  bool shouldRepaint(_TurSahnesi eski) => eski.kod != kod;
}

class _Yukleniyor extends StatelessWidget {
  const _Yukleniyor();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: OkumaMetin.hikayeYukleniyor,
      child: Column(
        children: [
          const OkumaMaskot(poz: HupoPose.dusunuyor, boyut: OkumaTema.hupoOrta),
          const SizedBox(height: OkumaTema.bosluk16),
          Text(
            OkumaMetin.hikayeYukleniyor,
            style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.muted),
          ),
          const SizedBox(height: OkumaTema.bosluk16),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

/// Tür görünümü: bant rengi, bant üstü metin rengi ve ikon. Renkler yalnız AppColors'tan gelir.
class _TurStili {
  const _TurStili({required this.etiket, required this.bant, required this.bantMetin, required this.ikon, required this.ikonRengi});

  final String etiket;
  final Color bant;
  final Color bantMetin;
  final IconData ikon;
  final Color ikonRengi;
}

_TurStili _turStili(String kod) => switch (kod) {
      'gizem' => const _TurStili(
          etiket: 'Gizem', bant: OkumaTema.primary, bantMetin: OkumaTema.surface, ikon: Icons.search_rounded, ikonRengi: OkumaTema.primary),
      'macera' => const _TurStili(
          etiket: 'Macera', bant: OkumaTema.coralDark, bantMetin: OkumaTema.surface, ikon: Icons.explore_rounded, ikonRengi: OkumaTema.coralDark),
      'bilim' => const _TurStili(
          etiket: 'Bilim', bant: OkumaTema.primaryDark, bantMetin: OkumaTema.surface, ikon: Icons.science_rounded, ikonRengi: OkumaTema.primaryDark),
      'doga' => const _TurStili(
          etiket: 'Doğa', bant: OkumaTema.mintDark, bantMetin: OkumaTema.surface, ikon: Icons.eco_rounded, ikonRengi: OkumaTema.mintDark),
      'mizah' => const _TurStili(
          etiket: 'Mizah', bant: OkumaTema.sun, bantMetin: OkumaTema.ink, ikon: Icons.sentiment_very_satisfied_rounded, ikonRengi: OkumaTema.ink),
      'hayvanlar' => const _TurStili(
          etiket: 'Hayvanlar', bant: OkumaTema.mintDark, bantMetin: OkumaTema.surface, ikon: Icons.pets_rounded, ikonRengi: OkumaTema.mintDark),
      'arkadaslik' => const _TurStili(
          etiket: 'Arkadaşlık', bant: OkumaTema.coralDark, bantMetin: OkumaTema.surface, ikon: Icons.people_rounded, ikonRengi: OkumaTema.coralDark),
      'fantastik' => const _TurStili(
          etiket: 'Fantastik', bant: OkumaTema.primaryDark, bantMetin: OkumaTema.surface, ikon: Icons.auto_awesome_rounded, ikonRengi: OkumaTema.primaryDark),
      'spor' => const _TurStili(
          etiket: 'Spor', bant: OkumaTema.mintDark, bantMetin: OkumaTema.surface, ikon: Icons.directions_bike_rounded, ikonRengi: OkumaTema.mintDark),
      'tarih_kultur' => const _TurStili(
          etiket: 'Tarih ve Kültür', bant: OkumaTema.sun, bantMetin: OkumaTema.ink, ikon: Icons.account_balance_rounded, ikonRengi: OkumaTema.ink),
      'bilim_kurgu' => const _TurStili(
          etiket: 'Bilim Kurgu', bant: OkumaTema.primaryDark, bantMetin: OkumaTema.surface, ikon: Icons.rocket_launch_rounded, ikonRengi: OkumaTema.primaryDark),
      'gezi_kultur' => const _TurStili(
          etiket: 'Gezi ve Kültür', bant: OkumaTema.primary, bantMetin: OkumaTema.surface, ikon: Icons.public_rounded, ikonRengi: OkumaTema.primary),
      _ => const _TurStili(
          etiket: 'Hikâye', bant: OkumaTema.lineDark, bantMetin: OkumaTema.ink, ikon: Icons.auto_stories_rounded, ikonRengi: OkumaTema.primaryDark),
    };

class _HikayeKapak extends StatelessWidget {
  const _HikayeKapak({required this.hikaye, required this.onTap});

  final OkumaKatalogSatiri hikaye;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stil = _turStili(hikaye.tur);
    final tanitim = hikaye.tanitim.isEmpty ? null : hikaye.tanitim;
    final sinifEtiketi = '${hikaye.anaSinif}. sınıf';
    final sure = hikaye.tahminiSureDk;
    final ayrinti = [
      sinifEtiketi,
      if (sure != null && sure > 0) OkumaMetin.hikayeSure(sure),
      if (hikaye.soruSayisi > 0) OkumaMetin.hikayeSoru(hikaye.soruSayisi),
    ].join(' · ');
    final degerAdi = hikaye.anaDeger == null ? null : okumaDegerAdi(hikaye.anaDeger!);
    return Semantics(
      button: true,
      label: 'Hikâye: ${hikaye.baslik}. ${stil.etiket}, $ayrinti.'
          '${degerAdi == null ? '' : ' Değer: $degerAdi.'}'
          '${hikaye.degerEslesmesi ? ' ${OkumaMetin.degerVeliTercihiRozet}.' : ''}'
          '${tanitim == null ? '' : ' $tanitim'}'
          '${hikaye.gorulmedi ? ' Yeni.' : ''} ${OkumaMetin.hikayeBasla}.',
      onTap: onTap,
      child: ExcludeSemantics(
        child: OkumaKart(
          padding: EdgeInsets.zero,
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(OkumaTema.koseKart),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Renkli üst bant ve merak simgesi (bandın alt kenarına taşar).
                SizedBox(
                  height: OkumaTema.hupoBos,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: OkumaTema.hupoBos,
                        color: stil.bant,
                        padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk16),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(stil.ikon, color: stil.bantMetin, size: OkumaTema.ikonOrta),
                            const SizedBox(width: OkumaTema.bosluk8),
                            Text(
                              stil.etiket,
                              style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, renk: stil.bantMetin),
                            ),
                            if (hikaye.gorulmedi) ...[
                              const SizedBox(width: OkumaTema.bosluk8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: OkumaTema.sunSoft,
                                  borderRadius: BorderRadius.circular(OkumaTema.koseCip),
                                ),
                                child: Text(
                                  OkumaMetin.hikayeYeni,
                                  style: OkumaTema.yazi(OkumaTema.yaziEtiket, kalinlik: OkumaTema.kalinlikVurgu),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        right: OkumaTema.bosluk16,
                        bottom: -OkumaTema.bosluk24,
                        child: Container(
                          width: OkumaTema.hupoKapakCikartma,
                          height: OkumaTema.hupoKapakCikartma,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: OkumaTema.surface,
                            border: Border.all(color: stil.bant, width: OkumaTema.kenarSecili),
                            boxShadow: OkumaTema.kartGolge,
                          ),
                          child: Icon(Icons.question_mark_rounded, color: stil.ikonRengi, size: OkumaTema.ikonBuyuk - 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(OkumaTema.bosluk16, OkumaTema.bosluk32, OkumaTema.bosluk16, OkumaTema.bosluk16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hikaye.baslik,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OkumaTema.yazi(OkumaTema.yaziKartBaslik, kalinlik: OkumaTema.kalinlikVurgu, satir: 1.25),
                      ),
                      if (tanitim != null) ...[
                        const SizedBox(height: OkumaTema.bosluk8),
                        Text(
                          tanitim,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: OkumaTema.yazi(OkumaTema.yaziYardimci, renk: OkumaTema.muted, satir: 1.4),
                        ),
                      ],
                      const SizedBox(height: OkumaTema.bosluk12),
                      Wrap(
                        spacing: OkumaTema.bosluk12,
                        runSpacing: OkumaTema.bosluk8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk12, vertical: OkumaTema.bosluk4),
                            decoration: BoxDecoration(
                              color: OkumaTema.background,
                              borderRadius: BorderRadius.circular(OkumaTema.koseCip),
                              border: Border.all(color: OkumaTema.lineDark, width: OkumaTema.kenarVarsayilan),
                            ),
                            child: Text(ayrinti, style: OkumaTema.yazi(OkumaTema.yaziEtiket, kalinlik: OkumaTema.kalinlikVurgu)),
                          ),
                          if (degerAdi != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk12, vertical: OkumaTema.bosluk4),
                              decoration: BoxDecoration(
                                color: OkumaTema.sunSoft,
                                borderRadius: BorderRadius.circular(OkumaTema.koseCip),
                              ),
                              child: Text(
                                hikaye.degerEslesmesi ? '$degerAdi · ${OkumaMetin.degerVeliTercihiRozet}' : degerAdi,
                                style: OkumaTema.yazi(OkumaTema.yaziEtiket, kalinlik: OkumaTema.kalinlikVurgu),
                              ),
                            ),
                          Container(
                            constraints: const BoxConstraints(minHeight: OkumaTema.dokunmaMin),
                            padding: const EdgeInsets.symmetric(horizontal: OkumaTema.bosluk16),
                            decoration: BoxDecoration(color: OkumaTema.primary, borderRadius: BorderRadius.circular(OkumaTema.koseButon)),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  OkumaMetin.hikayeBasla,
                                  style: OkumaTema.yazi(OkumaTema.yaziYardimci, kalinlik: OkumaTema.kalinlikVurgu, renk: OkumaTema.surface),
                                ),
                                const SizedBox(width: OkumaTema.bosluk4),
                                const Icon(Icons.arrow_forward_rounded, color: OkumaTema.surface, size: OkumaTema.ikonOrta),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
